forward
global type w_encodage_longueduree from w_ancestor_dataentry
end type
type dw_options from uo_datawindow_singlerow within w_encodage_longueduree
end type
type dw_prepose from uo_datawindow_multiplerow within w_encodage_longueduree
end type
end forward

global type w_encodage_longueduree from w_ancestor_dataentry
string tag = "TEXT_00793"
integer width = 3355
integer height = 2180
string title = "Tâches de longue durée"
boolean maxbox = true
boolean resizable = true
long backcolor = 16777215
dw_options dw_options
dw_prepose dw_prepose
end type
global w_encodage_longueduree w_encodage_longueduree

type variables
integer	ii_jours[], ii_idprest
integer	ii_auth_niveau1[] // n° des matières autorisées
integer	ii_auth_niveau2[] // n° des filières autorisées
integer	ii_auth_niveau3[] // n° des actions autorisées
string	is_plreal
uo_wait	iu_wait
br_saisie	ibr_saisie
end variables

forward prototypes
public function integer wf_retrieve_referentiel ()
public subroutine wf_filter_niveau2 (string as_data)
public function integer wf_retrieve_prepose (string as_plreal)
public function integer wf_generate ()
public subroutine wf_filter_niveau3 (string as_data)
public subroutine wf_filter_niveau1 ()
end prototypes

public function integer wf_retrieve_referentiel ();DatawindowChild	ldwc_dropdown
string	ls_err

// I. lecture des catégories de prestation - niveau 1
ls_err = "Erreur lecture catégories de prestations niveau 1"
dw_options.GetChild("niveau1", ldwc_dropdown)
ldwc_dropdown.settransobject(SQLCA)
IF ldwc_dropdown.retrieve() <= 0 THEN
	populateError(20000, ls_err)
	GOTO ERREUR
END IF

// II. lecture des catégories de prestation - niveau 2
ls_err = "Erreur lecture catégories de prestations niveau 2"
dw_options.GetChild("niveau2", ldwc_dropdown)
ldwc_dropdown.settransobject(SQLCA)
IF ldwc_dropdown.retrieve() <= 0 THEN
	populateError(20000, ls_err)
	GOTO ERREUR
END IF
ldwc_dropdown.setfilter("1=2")
ldwc_dropdown.filter()

// III. lecture de la liste des codes prestations - détail
ls_err = "Erreur lecture codes prestations - détail"
dw_options.GetChild("idprest", ldwc_dropdown)
ldwc_dropdown.settransobject(SQLCA)
IF ldwc_dropdown.retrieve() <= 0 THEN
	populateError(20000, ls_err)
	GOTO ERREUR
END IF
ldwc_dropdown.setfilter("1=2")
ldwc_dropdown.filter()

return(1)

ERREUR:
gu_message.uf_unexp("")
return(-1)
end function

public subroutine wf_filter_niveau2 (string as_data);// Afficher les catégories de prestations de 2ème niveau correspondant à la catégorie de 1er niveau sélectionnée
// PCO 27/04/2017 : on n'affiche que les filières autorisées et reprises dans la variable ii_auth_niveau2
DatawindowChild	ldwc_dropdown
integer				li_niveau1, li_i
string				ls_filter, ls_filter2

li_niveau1 = integer(as_data)
IF isNull(li_niveau1) THEN li_niveau1 = 0

// filtre de base : matière sélectionnée
ls_filter = "idpere = " + string(li_niveau1)

// filtre secondaire : afficher uniquement les filières autorisées
ls_filter2 = ""
FOR li_i = 1 TO upperBound(ii_auth_niveau2)
	IF f_isEmptyString(ls_filter2) THEN
		ls_filter2 = "idprest=" + string(ii_auth_niveau2[li_i])
	ELSE
		ls_filter2 = ls_filter2 + " OR idprest=" + string(ii_auth_niveau2[li_i])
	END IF
NEXT
ls_filter = ls_filter + " AND (" + ls_filter2 + ")"

dw_options.GetChild("niveau2", ldwc_dropdown)
ldwc_dropdown.setfilter(ls_filter)
ldwc_dropdown.filter()
ldwc_dropdown.sort()

end subroutine

public function integer wf_retrieve_prepose (string as_plreal);string	ls_err, ls_super, ls_plan, ls_real

IF as_plreal <> "P" and as_plreal <> "R" THEN
	return(-1)
END IF

IF as_plreal = "P" THEN ls_plan = "O" ELSE ls_real = "O"

// Lire la liste des préposés du responsable
// Attention : si membre du groupe de superusers "FULL", accès à tous les agents paramétrés dans le système !
ls_err = "Erreur lecture liste des préposés"
IF gu_privs.uf_super("FULL") THEN
	ls_super = "O"
ELSE
	ls_super = "N"
END IF

// Adapter la liste des agents sur lesquels l'utilisateur a un droit de modifier le planning ou le réalisé,
// en fonction du choix dans les options d'agir sur le planifié ou le réalisé.
// - 3ème et 5ème arguments concernent la consultation : pas utile ici.
// - lire les préposés avec droit de modifier le planning : 4ème argument="O"
// - lire les préposés avec droit de modifier le réalisé : 6ème argument="O"
IF dw_prepose.retrieve(gs_username, ls_super, "N", ls_plan, "N", ls_real) <= 0 THEN
	populateError(20000, ls_err)
	GOTO ERREUR
END IF

return(1)

ERREUR:
gu_message.uf_unexp("")
return(-1)
end function

public function integer wf_generate ();// générer les activités
// return(-1) : erreur 
// return(0) : aucune activité générée
// return(1) : OK
integer	li_nbjours, li_d, li_j, li_daynum, li_year, li_week, li_status
date		ldt_du, ldt_au, ldt_jour
string	ls_ouvrable, ls_matricule, ls_commentaire, ls_unite, ls_prep_codeservice, ls_absence
long		ll_rowprep, ll_num, ll_nbre_prest
datetime		ldt_duree, ldt_duree_zero
decimal{2}	ld_nbre

iu_wait.uf_addInfo("Génération des prestations")

ls_absence = string(dw_options.object.absence[1])
ls_ouvrable = string(dw_options.object.ouvrable[1])
ls_commentaire = string(dw_options.object.commentaire[1])
ld_nbre = dec(dw_options.object.nbre[1])
ldt_duree = dw_options.object.duree[1]
IF isNull(ldt_duree) THEN ldt_duree = ldt_duree_zero

// PCO 05/05/2017 : lors des tests réalisés par Vincent, on a eu un cas où une prestation d'absence avait été générée
// sans aucune durée. Pas réussi à reproduire l'anomalie, j'ai donc ajouté le test suivant.
IF ls_absence = "O" AND ldt_duree = ldt_duree_zero THEN
	populateerror(20000,"")
	gu_message.uf_unexp("Prestation d'absence sans indication de durée !~n" + &
							  "Traitement interrompu, aucune mise à jour effectuée.")
	GOTO ERREUR
END IF

// nombre de jours entre la date de début et de fin
ldt_du = dw_options.object.periode_du[1]
ldt_au = dw_options.object.periode_au[1]
li_nbjours = daysAfter(ldt_du, ldt_au)

// Ajouter la prestation à tous les préposés sélectionnés
FOR ll_rowprep = 1 TO dw_prepose.rowCount()
	IF integer(dw_prepose.object.c_select[ll_rowprep]) = 0 THEN 
		CONTINUE
	END IF
	
	ls_matricule = f_string(dw_prepose.object.prep_matricule[ll_rowprep])
	// mémoriser codeservice de l'agent
	select codeservice into :ls_prep_codeservice from agent where matricule=:ls_matricule using ESQLCA;
	IF f_check_sql(ESQLCA) <> 0 THEN
		populateerror(20000,"")
		gu_message.uf_unexp("Impossible de déterminer le codeservice de l'agent " + ls_matricule + "." + &
								  "Traitement interrompu, aucune mise à jour effectuée.")
		GOTO ERREUR
	END IF
	
	// parcourir tous les jours de la période et ne traiter que ceux qui répondent aux options choisies
	FOR li_j = 0 TO li_nbjours
		ldt_jour = RelativeDate(ldt_du, li_j)
		// dayNumber renvoie 1 pour le dimanche, 2 pour le lundi etc...
		li_daynum = dayNumber(ldt_jour) - 1
		IF li_daynum = 0 THEN li_daynum = 7
		
		FOR li_d = 1 TO upperBound(ii_jours)
			IF li_daynum = ii_jours[li_d] THEN
				// si c'est demandé dans les options, faire le test "jour férié ou non"
				IF ls_ouvrable = "O" THEN
					IF f_isFerie(string(ldt_jour,"dd/mm/yyyy")) THEN CONTINUE
				END IF
				// calculer la semaine sur base de la date
				f_weekFromDate(ldt_jour, li_year, li_week)
				// compte le nombre de prestations générées
				ll_nbre_prest++
				
				// ajouter la prestation
				// 1. trouver NUM libre pour le préposé et la semaine en cours
				IF is_plreal = "P" THEN
					select max(num) into :ll_num from planning 
						where matricule=:ls_matricule and annee=:li_year and semaine=:li_week using ESQLCA;
				ELSE
					select max(num) into :ll_num from realise 
						where matricule=:ls_matricule and annee=:li_year and semaine=:li_week using ESQLCA;
				END IF
				IF f_check_sql(ESQLCA) <> 0 THEN
					populateerror(20000,"")
					gu_message.uf_unexp("Erreur SELECT max(num) - " + is_plreal + "." + &
											  "Traitement interrompu, aucune mise à jour effectuée.")
					GOTO ERREUR
				END IF
				IF isNull(ll_num) THEN ll_num = 0
				ll_num = ll_num + 1
				IF ll_num >= 1000 THEN
					populateerror(20000,"")
					gu_message.uf_unexp("La numérotation des prestations dépasse 999 pour " + ls_matricule + &
											  " semaine " + string(li_year) + "/" + string(li_week) + "." + &
											  "Traitement interrompu, aucune mise à jour effectuée.")
					GOTO ERREUR
				END IF
				
				// 2. insert dans la DB
				IF is_plreal = "P" THEN
					insert into planning (matricule, annee, semaine, num, datep, idprest, irreg, duree, nbre, lieu, vers, 
												 codeservice, trfrealise)
							VALUES (:ls_matricule, :li_year, :li_week, :ll_num, :ldt_jour, :ii_idprest, 'N', :ldt_duree, :ld_nbre,
									 :ls_commentaire, :gi_dataVersion_planning, :ls_prep_codeservice, 'N')
					using ESQLCA;
				ELSE
					insert into realise (matricule, annee, semaine, num, datep, idprest, rappel, irreg, duree, nbre,
												commentaire, vers, km, sejour, codeservice)
							VALUES (:ls_matricule, :li_year, :li_week, :ll_num, :ldt_jour, :ii_idprest, 'N', 'N', :ldt_duree, :ld_nbre,
									 :ls_commentaire, :gi_dataVersion_realise, 0, 'N', :ls_prep_codeservice)
					using ESQLCA;
				END IF
				IF f_check_sql(ESQLCA) <> 0 THEN
					populateerror(20000,"")
					gu_message.uf_unexp("Erreur insert " + is_plreal + " " + ls_matricule + "/" + string(li_year) + &
											  "/" + string(li_week) + "/" + string(ll_num) + "." + &
											  "Traitement interrompu, aucune mise à jour effectuée.")
					GOTO ERREUR
				END IF
				
			END IF
		NEXT
	NEXT // jour suivant de la période
NEXT // préposé suivant


// OK
iu_wait.uf_closewindow()
IF ll_nbre_prest > 0 THEN
	commit using ESQLCA;
	gu_message.uf_info(string(ll_nbre_prest) + " prestations ont été générées.")
	return(1)
ELSE
	gu_message.uf_info("Aucune prestation n'a été générée. Vérifiez la période, les jours sélectionnés...")
	return(0)
END IF

// ERREUR
ERREUR:
rollback using ESQLCA;
iu_wait.uf_closewindow()
return(-1)
end function

public subroutine wf_filter_niveau3 (string as_data);// Afficher les catégories de prestations de 3ème niveau correspondant à la catégorie de 2ème niveau sélectionnée
// PCO 27/04/2017 : on n'affiche que les actions autorisées et reprises dans la variable ii_auth_niveau3
DatawindowChild	ldwc_dropdown
integer				li_niveau2, li_i
string				ls_filter, ls_filter2

li_niveau2 = integer(as_data)
IF isNull(li_niveau2) THEN li_niveau2 = 0

// filtre de base : filière sélectionnée
ls_filter = "idpere = " + string(li_niveau2)

// filtre secondaire : afficher uniquement les filières autorisées
ls_filter2 = ""
FOR li_i = 1 TO upperBound(ii_auth_niveau3)
	IF f_isEmptyString(ls_filter2) THEN
		ls_filter2 = "idprest=" + string(ii_auth_niveau3[li_i])
	ELSE
		ls_filter2 = ls_filter2 + " OR idprest=" + string(ii_auth_niveau3[li_i])
	END IF
NEXT
ls_filter = ls_filter + " AND (" + ls_filter2 + ")"

dw_options.GetChild("idprest", ldwc_dropdown)
ldwc_dropdown.setfilter(ls_filter)
ldwc_dropdown.filter()
ldwc_dropdown.sort()

end subroutine

public subroutine wf_filter_niveau1 ();// Afficher les catégories de prestations de 2ème niveau correspondant à la catégorie de 1er niveau sélectionnée
// PCO 27/04/2017 : on n'affiche que les matières autorisées et reprises dans la variable ii_auth_niveau1
DatawindowChild	ldwc_dropdown
integer				li_i
string				ls_filter

// filtre : afficher uniquement les filières autorisées
ls_filter = ""
FOR li_i = 1 TO upperBound(ii_auth_niveau1)
	IF f_isEmptyString(ls_filter) THEN
		ls_filter = "idprest=" + string(ii_auth_niveau1[li_i])
	ELSE
		ls_filter = ls_filter + " OR idprest=" + string(ii_auth_niveau1[li_i])
	END IF
NEXT

dw_options.GetChild("niveau1", ldwc_dropdown)
ldwc_dropdown.setfilter(ls_filter)
ldwc_dropdown.filter()
ldwc_dropdown.sort()

end subroutine

on w_encodage_longueduree.create
int iCurrent
call super::create
this.dw_options=create dw_options
this.dw_prepose=create dw_prepose
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_options
this.Control[iCurrent+2]=this.dw_prepose
end on

on w_encodage_longueduree.destroy
call super::destroy
destroy(this.dw_options)
destroy(this.dw_prepose)
end on

event ue_open;call super::ue_open;iu_wait = CREATE uo_wait
ibr_saisie = CREATE br_saisie

// PCO 27/04/2017 : 
// - matières sélectionnables doivent être paramétrées dans ii_auth_niveau1
// - filières sélectionnables doivent être paramétrées dans ii_auth_niveau2
// - actions sélectionnables doivent être paramétrées dans ii_auth_niveau3
// (auparavant, seule la matière/filière ULIS/ABSENCE était disponible)
ii_auth_niveau1 = {9} // matières autorisées : ULIS
ii_auth_niveau2 = {76,77} // filières autorisées : SITUATION ou ABSENCES
ii_auth_niveau3 = {288,289,290,291,292,293,294,295,296,297,298,299,302,417} // actions autorisées (toutes filières autorisées confondues)

wf_retrieve_referentiel()

dw_options.insertRow(0)

// affichage des matières disponibles
wf_filter_niveau1()

dw_options.uf_setdefaultvalue(1, "ouvrable", "O")
end event

event ue_init_menu;call super::ue_init_menu;f_menuaction({"m_fermer", "m_enregistrer"})
end event

event ue_enregistrer;call super::ue_enregistrer;date		ldt_du, ldt_au
string	ls_message
integer	li_j, li_jours[]

IF dw_options.event ue_checkall() = -1 THEN
	return(-1)
END IF

// vérifier validité de la période introduite
ldt_du = dw_options.object.periode_du[1]
ldt_au = dw_options.object.periode_au[1]
IF ldt_du > ldt_au THEN
	ls_message = f_translate_getlabel("TEXT_00788", "La date de départ doit être antérieure à la date de fin de période")
	gu_message.uf_error(ls_message)
	return(-1)
END IF

// vérifier s'il y a au moins un préposé sélectionné
IF integer(dw_prepose.object.c_sum_selected[1]) = 0 THEN
	gu_message.uf_info(f_translate_getlabel("TEXT_00789", "Veuillez sélectionner un ou plusieurs préposé(s)"))
	dw_prepose.SetFocus()
	return(-1)
END IF

// vérifier s'il y a au moins un jour sélectionné et stocker les jours sélectionnés dans un array d'integer
ii_jours = li_jours
IF string(dw_options.object.lu[1]) = "O" THEN 
	li_j++
	ii_jours[li_j] = 1
END IF
IF string(dw_options.object.ma[1]) = "O" THEN 
	li_j++
	ii_jours[li_j] = 2
END IF
IF string(dw_options.object.me[1]) = "O" THEN 
	li_j++
	ii_jours[li_j] = 3
END IF
IF string(dw_options.object.je[1]) = "O" THEN 
	li_j++
	ii_jours[li_j] = 4
END IF
IF string(dw_options.object.ve[1]) = "O" THEN 
	li_j++
	ii_jours[li_j] = 5
END IF
IF string(dw_options.object.sa[1]) = "O" THEN 
	li_j++
	ii_jours[li_j] = 6
END IF
IF string(dw_options.object.di[1]) = "O" THEN 
	li_j++
	ii_jours[li_j] = 7
END IF

IF li_j = 0 THEN
	ls_message = f_translate_getlabel("TEXT_00794", "Veuillez sélectionner au moins un jour")
	gu_message.uf_error(ls_message)
	return(-1)
END IF

// demander confirmation
IF gu_message.uf_query("confirmez-vous la génération des prestations ?", YesNo!, 2) = 1 THEN
	// générer les activités
	wf_generate()
ELSE
	gu_message.uf_info("Opération abandonnée")
END IF



end event

event ue_close;call super::ue_close;DESTROY iu_wait
DESTROY ibr_saisie
end event

event resize;call super::resize;dw_prepose.height = newheight - dw_options.height - 60
end event

type ddlb_message from w_ancestor_dataentry`ddlb_message within w_encodage_longueduree
boolean visible = false
integer x = 3017
integer y = 1984
integer width = 293
end type

type dw_options from uo_datawindow_singlerow within w_encodage_longueduree
integer y = 16
integer width = 3310
integer height = 480
integer taborder = 10
boolean bringtotop = true
string dataobject = "d_encodage_longueduree"
end type

event ue_itemvalidated;call super::ue_itemvalidated;DatawindowChild	ldwc_dropdown

CHOOSE CASE as_name
	CASE "niveau1"
		// annuler choix précédent niveau 2 et 3
		this.object.niveau2[al_row] = gu_c.i_null
		this.object.idprest[al_row] = gu_c.i_null
		this.GetChild("idprest", ldwc_dropdown)
		ldwc_dropdown.setfilter("1=2")
		ldwc_dropdown.filter()
		// filtrer niveau 2 sur base nouveau niveau 1
		wf_filter_niveau2(as_data)
						
	CASE "niveau2"
		// annuler choix précédent niveau 3
		this.object.idprest[al_row] = gu_c.i_null
		// filtrer niveau 3 sur base nouveau niveau 2
		wf_filter_niveau3(as_data)
		
	CASE "idprest"
		// NB : d'autres variables d'instance liées au code prestation sont initialisées dans ue_checkitem
		ii_idprest = integer(as_data)
	
	CASE "plreal"
		is_plreal = as_data
		wf_retrieve_prepose(as_data)

	CASE "ouvrable"
		// jours ouvrables seulement : d'office samedi et dimanche ne sont pas sélectionnés
		IF as_data = "O" THEN
			dw_options.object.sa[1] = "N"
			dw_options.object.di[1] = "N"
		END IF

END CHOOSE




end event

event ue_checkitem;call super::ue_checkitem;date		ldt_date
datetime	ldt_duree
integer	li_idprest
string	ls_garde, ls_absence, ls_interim, ls_unite, ls_trad

CHOOSE CASE as_item
	CASE "idprest"
		li_idprest = integer(as_data)
		IF isNull(li_idprest) THEN
			as_message = f_translate_getlabel("TEXT_00754", "Veuillez sélectionner une action")
			return(-1)
		END IF
		// vérification et lecture des données nécessaires à la validation
		select garde, absence, duree, interim, unite into :ls_garde, :ls_absence, :ldt_duree, :ls_interim, :ls_unite
			from referentiel where idprest = :li_idprest using ESQLCA;
		IF f_check_sql(ESQLCA) <> 0 THEN
			as_message = "Code " + as_data + " inexistant"
			return(-1)
		END IF
		// Seules les prestations de type GARDE, INTERIM, ABSENCE avec durée forfaitaire sont acceptées.
		// PCO 27/04/2017 : ce test est un garde-fou. En effet, normalement c'est la liste des actions autorisées
		// paramétrée dans ii_auth_niveau3 qui ne doit permettre que les actions autorisées, sans qu'une autre 
		// vérification soit nécessaire ici.
		// Ce test pourra disparaître à l'avenir en fonction des développements.
		IF NOT (ls_garde = "O" OR ls_interim = "O" OR (ls_absence = "O" AND not isNull(ldt_duree))) THEN
			as_message = "Types de prestations autorisés : ~n" + &
							 "- Intérims~n" + &
							 "- Garde~n" + &
							 "- Absences avec durée forfaitaire"
			return(-1)
		END IF
	
		dw_options.object.duree[1] = ldt_duree
		dw_options.object.interim[1] = ls_interim
		dw_options.object.absence[1] = ls_absence
		
		IF f_isEmptyString(ls_unite) THEN
			dw_options.object.trad_unite[1] = gu_c.s_null
			dw_options.object.nbre[1] = gu_c.d_null
		ELSE
			select trad into :ls_trad from v_unitprest where code=:ls_unite using ESQLCA;
			IF ESQLCA.sqlnrows = 1 THEN
				dw_options.object.trad_unite[1] = ls_trad
			END IF
		END IF
	
	CASE "commentaire"
		ls_interim = dw_options.object.interim[1] 
		IF ibr_saisie.uf_check_commentaire(0, ls_interim, as_data, as_message) = -1 THEN
			return(-1)
		ELSE
			return(1)
		END IF
		
	CASE "nbre"
		IF ibr_saisie.uf_check_nbre(as_data, as_message, ii_idprest) = -1 THEN
			return(-1)
		ELSE
			return(1)
		END IF
	
	CASE "plreal"
		IF NOT match(as_data,"^[PR]$") THEN
			as_message = f_translate_getlabel("TEXT_00779", "Veuillez sélectionner P(lanifié) ou R(éalisé)")
			return(-1)
		END IF
		
	CASE "ouvrable"
		IF NOT match(as_data,"^[ON]$") THEN
			as_message = f_translate_getlabel("TEXT_00782", "Faites un choix : uniquement les jours ouvrables ou tous")
			return(-1)
		END IF
		
	CASE "periode_du"
		ldt_date = date(as_data)
		IF isNull(ldt_date) THEN
			as_message = f_translate_getlabel("TEXT_00786", "Veuillez saisir une date de départ")
			return(-1)
		END IF
		
	CASE "periode_au"
		ldt_date = date(as_data)
		IF isNull(ldt_date) THEN
			as_message = f_translate_getlabel("TEXT_00787", "Veuillez saisir une date de fin")
			return(-1)
		END IF
END CHOOSE

return(1)
end event

type dw_prepose from uo_datawindow_multiplerow within w_encodage_longueduree
integer x = 567
integer y = 528
integer width = 2103
integer height = 1520
integer taborder = 11
boolean bringtotop = true
string dataobject = "d_prepose_multiple"
boolean vscrollbar = true
boolean border = true
end type

