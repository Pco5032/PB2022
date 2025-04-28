//objectcomments Gestion des activités réalisées
forward
global type w_realise from w_ancestor_dataentry
end type
type dw_2 from uo_datawindow_multiplerow within w_realise
end type
type p_1 from picture within w_realise
end type
type uo_semaine from uvo_navweek within w_realise
end type
type st_prep from uo_statictext within w_realise
end type
type p_cadenas from uo_picture within w_realise
end type
type gb_1 from uo_groupbox within w_realise
end type
type dw_prepose from uo_datawindow_singlerow within w_realise
end type
type cb_valid from commandbutton within w_realise
end type
type dw_debrief from uo_datawindow_singlerow within w_realise
end type
type cb_import from commandbutton within w_realise
end type
type cb_check from commandbutton within w_realise
end type
end forward

global type w_realise from w_ancestor_dataentry
string tag = "TEXT_00570"
integer width = 4389
integer height = 2344
string title = "Réalisation"
boolean maxbox = true
boolean resizable = true
event ue_print ( )
event ue_duplicate ( )
event ue_attempt_reconnect ( )
dw_2 dw_2
p_1 p_1
uo_semaine uo_semaine
st_prep st_prep
p_cadenas p_cadenas
gb_1 gb_1
dw_prepose dw_prepose
cb_valid cb_valid
dw_debrief dw_debrief
cb_import cb_import
cb_check cb_check
end type
global w_realise w_realise

type variables
br_saisie	ibr_realise
integer		ii_year, ii_week
string		is_prep_matricule, is_prep_codeservice
date			idt_from, idt_to
boolean		ib_realise_valid, ib_canValid, ib_external_initialised

end variables

forward prototypes
public subroutine wf_calc_duree (long al_row, string as_name, string as_data)
public subroutine wf_initnewrow (long al_row)
public subroutine wf_lecture ()
public subroutine wf_print ()
public subroutine wf_idprest (long al_row, integer ai_idprest)
public function integer wf_retrieve ()
public subroutine wf_filter_prest (long al_row, string as_name, string as_data)
public function integer wf_initexternal (string as_matricule, date adt_from)
public function boolean wf_isexternalinitialised ()
public subroutine wf_setexternalnotinitialised ()
public function integer wf_importxml (string as_filename)
public function integer wf_convertxml (string as_filename)
public subroutine wf_filter_niveau2 (long al_row, string as_name, string as_data)
public function long wf_external_row (datetime a_datep, integer ai_niveau1, integer ai_niveau2, integer ai_idprest, string as_irreg, datetime a_debut, datetime a_fin, datetime a_duree, decimal ad_nbre, string as_commentaire)
end prototypes

event ue_print();wf_print()
end event

event ue_duplicate();// Déclenché par l'action "dupliquer" du menu.
// Dupliquer la ligne en cours en ajoutant un jour à la date
long	ll_currentrow, ll_newrow
integer	li_rc
datetime	l_datep

IF ib_realise_valid THEN return
ll_currentrow = dw_2.getRow()
IF ll_currentrow <= 0 THEN return
dw_2.setFocus()

ll_newrow = ll_currentrow + 1
li_rc = dw_2.RowsCopy(ll_currentrow, ll_currentrow, Primary!, dw_2, ll_newrow, Primary!)
IF li_rc = 1 THEN
	l_datep = dw_2.object.datep[ll_newrow]
	dw_2.object.datep[ll_newrow] = RelativeDate(date(l_datep), 1)
	dw_2.object.num[ll_newrow] = 0
	dw_2.scrollTorow(ll_newrow)
END IF

end event

event ue_attempt_reconnect();// event à exécuter après une reconnexion à la DB suite à une perte de connexion
DatawindowChild	ldwc_dropdown

dw_2.setTransObject(SQLCA)
dw_debrief.setTransObject(SQLCA)

dw_prepose.GetChild("prep_matricule", ldwc_dropdown)
ldwc_dropdown.settransobject(SQLCA)

dw_2.GetChild("niveau1", ldwc_dropdown)
ldwc_dropdown.settransobject(SQLCA)

dw_2.GetChild("niveau2", ldwc_dropdown)
ldwc_dropdown.settransobject(SQLCA)

dw_2.GetChild("idprest", ldwc_dropdown)
ldwc_dropdown.settransobject(SQLCA)


end event

public subroutine wf_calc_duree (long al_row, string as_name, string as_data);// Prestations irrégulières : calculer la durée entre l'heure de début et l'heure de fin d'activité.
// Cas particulier : on ne sait pas encoder 24:00 pour signifier une fin d'activité à minuit.
// On encode donc 00:00, mais il faut l'interpréter manuellement.
time		lt_duree
date		l_date
datetime	l_dt, l_debut, l_fin
integer	li_hours, li_minutes

CHOOSE CASE as_name
	CASE "hdebut", "hfin"
		IF as_name = "hdebut" THEN
			l_debut = datetime(as_data)
			l_fin = datetime(dw_2.object.hfin[al_row])
		ELSE
			l_debut = datetime(dw_2.object.hdebut[al_row])
			l_fin = datetime(as_data)
		END IF
		// interprétation particulière si heure et minute de fin = 0 (encodage 00:00)
		IF hour(time(l_fin)) = 0 AND minute(time(l_fin)) = 0 THEN
			li_minutes = (24 * 60) - (f_datetimetominutes(l_debut))
		ELSE
			li_minutes = ((f_datetimetominutes(l_fin)) - (f_datetimetominutes(l_debut)))
		END IF
		
		IF isnull(li_minutes) or li_minutes <= 0 THEN
			setnull(lt_duree)
		ELSE
			lt_duree = time(string(truncate(li_minutes / 60, 0),"00") + ":" + string(mod(li_minutes, 60), "00") + ":00")
		END IF
		
		l_dt = datetime(l_date,lt_duree)
		dw_2.object.duree[al_row] = l_dt
END CHOOSE




end subroutine

public subroutine wf_initnewrow (long al_row);// initialiser nouvelle ligne d'encodage
IF al_row > 0 THEN
	dw_2.object.matricule[al_row]	= is_prep_matricule
	dw_2.object.annee[al_row] = ii_year
	dw_2.object.semaine[al_row]= ii_week
	dw_2.object.rappel[al_row] = "N"
	dw_2.object.irreg[al_row] = "N"
	dw_2.object.km[al_row] = 0
	// version 3 : nouvelle colonne séjour = "N" par défaut
	dw_2.object.sejour[al_row] = "N"
	// PCO 08/12/2015 : ajouter stockage du codeservice
	dw_2.object.codeservice[al_row]	= is_prep_codeservice
	// version : 2 à partir des modif de MARS 2015 (hdeb et hfin obligatoires)
	// version : 3 à partir des modif de JUILLET 2015
	// version : 4 à partir du nouveau référentiel (NOV 2015 ?)
	dw_2.object.vers[al_row] = gi_dataVersion_realise
END IF

end subroutine

public subroutine wf_lecture ();// lecture des données pour le préposé sélectionné, pour la semaine sélectionnée
string	ls_realise_valid
long		ll_row_debrief

IF f_isEmptyString(is_prep_matricule) THEN
	return
END IF

dw_prepose.uf_disableitems({"prep_matricule"})

// lecture de la semaine pour voir si elle est déjà validée
select realise_valid into :ls_realise_valid from semaine_valid
	where matricule=:is_prep_matricule and annee=:ii_year and semaine=:ii_week using ESQLCA;
IF f_check_sql(ESQLCA) < 0 THEN
	populateError(20000, "")
	gu_message.uf_unexp("Erreur SELECT SEMAINE_VALID")
	post close(this)
	return
END IF

// semaine n'existe pas encore --> forcément non validée
IF ESQLCA.sqlnrows = 100 THEN ib_realise_valid = FALSE

// bouton validation : uniquement si la semaine n'est pas déjà validée
// (on controlera aussi si l'utilisateur a le privilège de valider ou pas, et de modifier les data ou pas)
IF ls_realise_valid = "O" THEN
	cb_valid.enabled = FALSE
	ib_realise_valid = TRUE
ELSE
	IF ib_canValid AND wf_canUpdate() THEN 
		cb_valid.enabled = TRUE
	END IF
	ib_realise_valid = FALSE
END IF

// importation de données : uniquement si droit de modifier les données et semaine non validée
IF NOT ib_realise_valid AND wf_canUpdate() THEN
	cb_import.enabled = TRUE
ELSE
	cb_import.enabled = FALSE
END IF

// vérification de la cohérence des données : toujours possible
cb_check.enabled = TRUE

// lecture des activités réalisées pour la semaine
IF dw_2.retrieve(is_prep_matricule, ii_year, ii_week) > 0 THEN
	// réappliquer le filtre des DDDW sur la row en cours
	wf_filter_niveau2(1, "", "")
	wf_filter_prest(1, "", "")
END IF

// lecture du débriefing opérationnel technique de la semaine
IF dw_debrief.retrieve(is_prep_matricule, ii_year, ii_week) = 0 THEN
	ll_row_debrief = dw_debrief.insertrow(0)
	dw_debrief.object.matricule[ll_row_debrief] = is_prep_matricule
	dw_debrief.object.annee[ll_row_debrief] = ii_year
	dw_debrief.object.semaine[ll_row_debrief] = ii_week
	dw_debrief.setitemstatus(ll_row_debrief, 0, Primary!, notmodified!)
END IF

wf_actif(TRUE)

// si pas le droit d'update, on l'accorde malgré tout pour l'utilisateur lui-même
// 07/2015 : plus ici, voir code directement après sélection de l'agent
//IF NOT wf_canUpdate() THEN
//	IF is_prep_matricule = gs_username THEN
//		wf_canUpdate(TRUE)
//		wf_canDelete(TRUE)
//	END IF
//END IF

// activer ou pas les DW selon que la semaine est validée ou pas, et selon que l'utilisateur
// a le droit de modifier ou pas
p_cadenas.visible = ib_realise_valid
IF ib_realise_valid OR wf_canupdate()=FALSE THEN
	dw_2.uf_disabledata()
	dw_debrief.uf_disabledata()
ELSE
	dw_2.uf_enabledata()
	dw_debrief.uf_enabledata()
END IF

event post ue_init_menu()
end subroutine

public subroutine wf_print ();// impression de la semaine d'activité en cours
str_params	lstr_params

IF f_isEmptyString(is_prep_matricule) THEN
	gu_message.uf_info("Veuillez sélectionner un agent avant de demander d'imprimer")
	return
END IF

// enregistrer les modif. éventuelles
IF event ue_enregistrer() < 0 THEN
	return
END IF

IF IsValid(w_rpt_realise) THEN
	close(w_rpt_realise)
END IF

lstr_params.a_param[1] = is_prep_matricule
lstr_params.a_param[2] = ii_year
lstr_params.a_param[3] = ii_week
OpenSheetWithParm(w_rpt_realise, lstr_params, gw_mdiframe, 0, Original!)
IF IsValid(w_rpt_realise) THEN
	w_rpt_realise.SetFocus()
END IF
end subroutine

public subroutine wf_idprest (long al_row, integer ai_idprest);// lecture des propriétés de la prestation
string	ls_garde, ls_cumul, ls_irregcompat, ls_unite, ls_interim, ls_absence, ls_trad_unite
datetime	ldt_duree, ldt_duree_zero
decimal{2}	ld_nbre

IF isNull(ai_idprest) OR ai_idprest = 0 THEN
	return
END IF

select d.duree, d.garde, d.cumul, d.irregcompat, d.unite, d.interim, d.absence, v_unitprest.trad
	into :ldt_duree, :ls_garde, :ls_cumul, :ls_irregcompat, :ls_unite, :ls_interim, :ls_absence, :ls_trad_unite
	from v_dicoprest d, v_unitprest
	where d.idprest = :ai_idprest and v_unitprest.code (+) = d.unite
	using ESQLCA;

IF f_check_sql(ESQLCA) <> 0 THEN
	populateError(20000, "")
	gu_message.uf_unexp("Erreur SELECT V_DICOPREST " + f_string(ai_idprest))
	return
END IF

IF NOT isNull(ldt_duree) THEN
	dw_2.object.duree[al_row] = ldt_duree
	dw_2.object.hdebut[al_row] = gu_c.date_null
	dw_2.object.hfin[al_row] = gu_c.date_null
END IF

IF ls_garde = "O" OR ls_interim = "O" THEN
	dw_2.object.duree[al_row] = ldt_duree_zero
	dw_2.object.hdebut[al_row] = gu_c.date_null
	dw_2.object.hfin[al_row] = gu_c.date_null
END IF

// PCO 10/03/2016 : on peut dorénavant encoder un nombre pour les intérims. Par défaut : 1
IF ls_interim = "O" THEN
	ld_nbre = dec(dw_2.object.nbre[al_row])
	IF isNull(ld_nbre) OR ld_nbre = 0 THEN
		dw_2.object.nbre[al_row] = 1
	END IF
END IF

IF ls_irregcompat = "N" THEN
	dw_2.object.irreg[al_row] = "N"
	dw_2.object.rappel[al_row] = "N"
END IF

IF isNull(ls_unite) THEN
	dw_2.object.nbre[al_row] = gu_c.d_null
END IF

dw_2.object.v_dicoprest_duree[al_row] = ldt_duree
dw_2.object.v_dicoprest_garde[al_row] = ls_garde
dw_2.object.v_dicoprest_cumul[al_row] = ls_cumul
dw_2.object.v_dicoprest_unite[al_row] = ls_unite
dw_2.object.v_dicoprest_interim[al_row] = ls_interim
dw_2.object.v_dicoprest_absence[al_row] = ls_absence
dw_2.object.v_unitprest_trad[al_row] = ls_trad_unite

end subroutine

public function integer wf_retrieve ();DatawindowChild	ldwc_dropdown
long		ll_nbrows
string	ls_err, ls_super

// I. Lire la liste des préposés du responsable auquel est ajouté l'utilisateur lui-même
// Attention : si membre du groupe de superusers "FULL", accès à tous les agents paramétrés dans le système !
ls_err = "Erreur lecture liste des préposés"
IF gu_privs.uf_super("FULL") THEN
	ls_super = "O"
ELSE
	ls_super = "N"
END IF
dw_prepose.GetChild("prep_matricule", ldwc_dropdown)
ldwc_dropdown.settransobject(SQLCA)
// 07/2015 : argument "R" : indique qu'on souhaite la liste des agents pour lesquels on a le droit 
// de consulter (et peut-être modifier) le Réalisé.
ll_nbrows = ldwc_dropdown.retrieve(gs_username, ls_super, 'R')
IF ll_nbrows <= 0 THEN
	dw_prepose.insertrow(0)
	populateError(20000, ls_err)
	GOTO ERREUR
ELSE
	// PCO 02MAI2016 : si on met 0 dans le nombre de lignes du DDDW, la liste est correcte mais très réduite 
	// et peu lisible si beaucoup d'agents à afficher. Si on met un nombre de ligne (20 par exemple), la liste
	// est correcte sauf si nombre à afficher est réduit (par exemple un seul préposé) car la ligne de titre
	// est prise en compte ! Ici, je force pour que la liste soit toujours correcte.
	IF ll_nbrows < 5 THEN
		dw_prepose.Object.prep_matricule.dddw.lines = 0
	END IF
END IF

// II. lecture des catégories de prestation - niveau 1
ls_err = "Erreur lecture catégories de prestations niveau 1"
dw_2.GetChild("niveau1", ldwc_dropdown)
ldwc_dropdown.settransobject(SQLCA)
IF ldwc_dropdown.retrieve() <= 0 THEN
	populateError(20000, ls_err)
	GOTO ERREUR
END IF

// III. lecture des catégories de prestation - niveau 2
ls_err = "Erreur lecture catégories de prestations niveau 2"
dw_2.GetChild("niveau2", ldwc_dropdown)
ldwc_dropdown.settransobject(SQLCA)
IF ldwc_dropdown.retrieve() <= 0 THEN
	populateError(20000, ls_err)
	GOTO ERREUR
END IF
ldwc_dropdown.setfilter("1=2")
ldwc_dropdown.filter()

// IV. lecture de la liste des codes prestations - détail
ls_err = "Erreur lecture codes prestations - détail"
dw_2.GetChild("idprest", ldwc_dropdown)
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

public subroutine wf_filter_prest (long al_row, string as_name, string as_data);// Afficher les catégories de prestations de 3ème niveau correspondant à la catégorie de 2ème niveau sélectionnée
DatawindowChild	ldwc_dropdown
integer				li_niveau2

IF al_row <= 0 THEN return

// si fonction lancée par ue_itemvalidated, prendre la nouvelle valeur
IF as_name = "niveau2" THEN
	li_niveau2 = integer(as_data)
ELSE
	li_niveau2 = integer(dw_2.object.niveau2[al_row])
END IF

// PCO 21/04/2016 : 0 si null (conséquence du déplacement décrit ci-dessous, même date)
IF isNull(li_niveau2) THEN li_niveau2 = 0

dw_2.GetChild("idprest", ldwc_dropdown)
ldwc_dropdown.setfilter("idpere = " + string(li_niveau2))
ldwc_dropdown.filter()
ldwc_dropdown.sort()

// PCO 21/04/2016 : faire le test et le return après le filtre, sinon la liste montre
// les actions de la dernière filière choisie (dans une autre ligne)
IF li_niveau2 = 0 THEN return

// bug pb workaround. Après filtre, c'est la DATA qui est affichée et non l'intitulé
dwItemStatus l_status
l_status = dw_2.getItemStatus(al_row, 'idprest', Primary!)
dw_2.SetItem(al_row,'idprest',dw_2.object.idprest[al_row])
dw_2.setItemStatus(al_row, 'idprest', Primary!, l_status)
end subroutine

public function integer wf_initexternal (string as_matricule, date adt_from);// initialisation par un programme externe
IF f_isEmptyString(as_matricule) THEN
	return(-1)
END IF

IF isNull(adt_from) THEN
	return(-1)
END IF

// initialiser n° de semaine sur base de la date passée en argument
uo_semaine.uf_init(adt_from)

// sélectionner préposé passé en argument
IF dw_prepose.uf_setdefaultvalue(1, "prep_matricule", as_matricule) < 0 THEN return(-1)

ib_external_initialised = TRUE

return(1)
end function

public function boolean wf_isexternalinitialised ();return(ib_external_initialised)
end function

public subroutine wf_setexternalnotinitialised ();ib_external_initialised = FALSE
end subroutine

public function integer wf_importxml (string as_filename);// importer fichier XML
integer	li_rt, li_niveau1, li_niveau2, li_idprest
long		ll_row

li_rt = dw_2.importfile(XML!, as_filename)

// pour chaque row importée, compléter les données sur base du code prestation
IF li_rt > 0 THEN
	dw_2.setRedraw(FALSE)
	FOR ll_row = 1 TO dw_2.rowCount()
		// initialiser valeurs non fournies par le fichier importé
		dw_2.object.matricule[ll_row] = is_prep_matricule
		dw_2.object.annee[ll_row] = ii_year
		dw_2.object.semaine[ll_row]= ii_week
		dw_2.object.num[ll_row] = 0
		
		// PCO 08/12/2015 : ajouter stockage du codeservice
		dw_2.object.codeservice[ll_row]	= is_prep_codeservice
		
		// version du fichier (1 par défaut, n'existait pas lors de la création du fichier)
		IF isNull(integer(dw_2.object.vers[ll_row])) THEN
			dw_2.object.vers[ll_row] = 1
		END IF
		
		// conversion éventuelle du code prestation (nécessaire si modification du dictionnaire
		// entre version light et full)
		li_idprest = ibr_realise.uf_convert_idprest(dw_2.object.vers[ll_row], dw_2.object.idprest[ll_row])
		
		// lire niveaux 1 et 2 hiérarchiques du code prestation importé
		select idpere into :li_niveau2 from v_dicoprest where idprest=:li_idprest using ESQLCA;
		IF f_check_sql(ESQLCA) = 0 THEN 
			select idpere into :li_niveau1 from v_dicoprest where idprest=:li_niveau2 using ESQLCA;
			IF f_check_sql(ESQLCA) = 0 THEN 
				// garnir identification du code prestation
				dw_2.uf_setdefaultvalue(ll_row, "niveau1", li_niveau1)
				dw_2.uf_setdefaultvalue(ll_row, "niveau2", li_niveau2)
				dw_2.uf_setdefaultvalue(ll_row, "idprest", li_idprest)
			END IF
		END IF
		// valeurs par défaut si non fournies
		IF isNull(integer(dw_2.object.km[ll_row])) THEN
			dw_2.object.km[ll_row] = 0
		END IF
		IF isNull(integer(dw_2.object.sejour[ll_row])) THEN
			dw_2.object.sejour[ll_row] = "N"
		END IF
	NEXT
	dw_2.sort()
	// sélectionner la 1ère row et appliquer le filtre des DDDW
	dw_2.scrollTorow(1)
	wf_filter_niveau2(1, "", "")
	wf_filter_prest(1, "", "")
	dw_2.setRedraw(TRUE)
	return(1)
ELSE
	return(li_rt)
END IF
end function

public function integer wf_convertxml (string as_filename);// convertir fichier XML sans template (ancienne version avant MARS 2015) en fichier avec template
uo_ds	lds_old, lds_new
long	ll_row, ll_new
	
lds_old = CREATE uo_ds
lds_new = CREATE uo_ds
lds_old.dataobject = "d_realise_tab_old"
lds_new.dataobject = "d_realise_tab"
IF lds_old.importfile(XML!, as_filename) < 0 THEN
	DESTROY lds_old
	DESTROY lds_new
	return(-1)
ELSE
	FOR ll_row = 1 TO lds_old.rowcount()
		ll_new = lds_new.insertrow(0)
		lds_new.object.matricule[ll_new]=lds_old.object.matricule[ll_row]
		lds_new.object.annee[ll_new]=lds_old.object.annee[ll_row]
		lds_new.object.semaine[ll_new]=lds_old.object.semaine[ll_row]
		lds_new.object.num[ll_new]=lds_old.object.num[ll_row]
		lds_new.object.datep[ll_new]=lds_old.object.datep[ll_row]
		lds_new.object.idprest[ll_new]=lds_old.object.idprest[ll_row]
		lds_new.object.rappel[ll_new]=lds_old.object.rappel[ll_row]
		lds_new.object.irreg[ll_new]=lds_old.object.irreg[ll_row]
		lds_new.object.hdebut[ll_new]=lds_old.object.hdebut[ll_row]
		lds_new.object.hfin[ll_new]=lds_old.object.hfin[ll_row]
		lds_new.object.duree[ll_new]=lds_old.object.duree[ll_row]
		lds_new.object.nbre[ll_new]=lds_old.object.nbre[ll_row]
		lds_new.object.commentaire[ll_new]=lds_old.object.commentaire[ll_row]
// NOV2015 : données du référentiel lues directement dans le référentiel lors de l'importation
//		lds_new.object.dicoprest_catprest[ll_new]=lds_old.object.dicoprest_catprest[ll_row]
//		lds_new.object.dicoprest_duree[ll_new]=lds_old.object.dicoprest_duree[ll_row]
//		lds_new.object.dicoprest_garde[ll_new]=lds_old.object.dicoprest_garde[ll_row]
//		lds_new.object.dicoprest_cumul[ll_new]=lds_old.object.dicoprest_cumul[ll_row]
//		lds_new.object.dicoprest_unite[ll_new]=lds_old.object.dicoprest_unite[ll_row]
//		lds_new.object.v_unitprest_trad[ll_new]=lds_old.object.v_unitprest_trad[ll_row]
		// version : 2 à partir des modif de MARS 2015 (hdeb et hfin obligatoires)
		// n'existait pas avant --> 1
		lds_new.object.vers[ll_new] = 1
		// km : idem
		lds_new.object.km[ll_new] = 0
	NEXT
	lds_new.saveas(as_filename, XML!, false)
	DESTROY lds_old
	DESTROY lds_new
	return(1)
END IF
end function

public subroutine wf_filter_niveau2 (long al_row, string as_name, string as_data);// Afficher les catégories de prestations de 2ème niveau correspondant à la catégorie de 1er niveau sélectionnée
DatawindowChild	ldwc_dropdown
integer				li_niveau1

IF al_row <= 0 THEN return

// si fonction lancée par ue_itemvalidated, prendre la nouvelle valeur
IF as_name = "niveau1" THEN
	li_niveau1 = integer(as_data)
ELSE
	li_niveau1 = integer(dw_2.object.niveau1[al_row])
END IF

// PCO 21/04/2016 : 0 si null (conséquence du déplacement décrit ci-dessous, même date)
IF isNull(li_niveau1) THEN li_niveau1 = 0

dw_2.GetChild("niveau2", ldwc_dropdown)
ldwc_dropdown.setfilter("idpere = " + string(li_niveau1))
ldwc_dropdown.filter()
ldwc_dropdown.sort()

// PCO 21/04/2016 : faire le test et le return après le filtre, sinon la liste montre
// les filières de la dernière matière choisie (dans une autre ligne)
IF li_niveau1 = 0 THEN return

// bug pb workaround. Après filtre, c'est la DATA qui est affichée et non l'intitulé
dwItemStatus l_status
l_status = dw_2.getItemStatus(al_row, 'niveau2', Primary!)
Dw_2.SetItem(al_row,'niveau2',dw_2.object.niveau2[al_row])
dw_2.setItemStatus(al_row, 'niveau2', Primary!, l_status)

end subroutine

public function long wf_external_row (datetime a_datep, integer ai_niveau1, integer ai_niveau2, integer ai_idprest, string as_irreg, datetime a_debut, datetime a_fin, datetime a_duree, decimal ad_nbre, string as_commentaire);// Appel d'un programme extérieur : création d'une row
long	ll_row

IF ib_realise_valid THEN 
	gu_message.uf_error("Semaine validée : modification impossible")
	return(0)
END IF

ll_row = dw_2.event ue_addrow()

IF ll_row > 0 THEN
	dw_2.uf_setdefaultvalue(ll_row, "datep", a_datep)
	dw_2.uf_setdefaultvalue(ll_row, "niveau1", ai_niveau1)
	dw_2.uf_setdefaultvalue(ll_row, "niveau2", ai_niveau2)
	dw_2.uf_setdefaultvalue(ll_row, "idprest", ai_idprest)
	dw_2.uf_setdefaultvalue(ll_row, "irreg", as_irreg)
// PCO 27/02/2015 : durée pas transférée (demande du GT)
//	dw_2.uf_setdefaultvalue(ll_row, "hdebut", a_debut, datetime!)
//	dw_2.uf_setdefaultvalue(ll_row, "hfin", a_fin, datetime!)
//	dw_2.uf_setdefaultvalue(ll_row, "duree", a_duree)
	dw_2.uf_setdefaultvalue(ll_row, "nbre", ad_nbre, decimal!)
	dw_2.uf_setdefaultvalue(ll_row, "commentaire", as_commentaire, string!)
	// PCO 08/12/2015 : ajouter stockage du codeservice
	dw_2.object.codeservice[ll_row] = is_prep_codeservice
END IF

return(ll_row)


end function

event ue_open;call super::ue_open;// BR encodage
ibr_realise = CREATE br_saisie

wf_SetDWList({dw_2, dw_debrief})

// actions devant être visibles dans le menu
wf_SetItemsToShow({"m_ajouter", "m_inserer", "m_dupliquer"})

// initialiser le droit de valider
IF gu_privs.uf_canupdate("validation") = 1 THEN
	ib_canValid = TRUE
ELSE
	ib_canValid = FALSE
END IF

// PCO 31/10/2016 : autoselectrow en fonction du choix de l'utilisateur dans les options
dw_2.uf_autoselectrow(gb_autoSelectRow)
dw_2.SetRowFocusIndicator(p_1, 16)
dw_2.uf_createwhenlastdeleted(FALSE)
// PCO 29/02/2016
dw_2.uf_checkallrow(FALSE)

// stocker dans le DW le temps de travail hebdomadaire en minutes
dw_2.object.c_tthebdo_minutes.expression = "'" + string(gi_tthebdo) + "'"

// lecture du contenu des DDDW
wf_retrieve()
end event

on w_realise.create
int iCurrent
call super::create
this.dw_2=create dw_2
this.p_1=create p_1
this.uo_semaine=create uo_semaine
this.st_prep=create st_prep
this.p_cadenas=create p_cadenas
this.gb_1=create gb_1
this.dw_prepose=create dw_prepose
this.cb_valid=create cb_valid
this.dw_debrief=create dw_debrief
this.cb_import=create cb_import
this.cb_check=create cb_check
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_2
this.Control[iCurrent+2]=this.p_1
this.Control[iCurrent+3]=this.uo_semaine
this.Control[iCurrent+4]=this.st_prep
this.Control[iCurrent+5]=this.p_cadenas
this.Control[iCurrent+6]=this.gb_1
this.Control[iCurrent+7]=this.dw_prepose
this.Control[iCurrent+8]=this.cb_valid
this.Control[iCurrent+9]=this.dw_debrief
this.Control[iCurrent+10]=this.cb_import
this.Control[iCurrent+11]=this.cb_check
end on

on w_realise.destroy
call super::destroy
destroy(this.dw_2)
destroy(this.p_1)
destroy(this.uo_semaine)
destroy(this.st_prep)
destroy(this.p_cadenas)
destroy(this.gb_1)
destroy(this.dw_prepose)
destroy(this.cb_valid)
destroy(this.dw_debrief)
destroy(this.cb_import)
destroy(this.cb_check)
end on

event resize;call super::resize;integer	li_avlHeight

li_avlHeight = this.workspaceheight() - gb_1.height - 120

gb_1.width=newwidth - 32

// calculer hauteur dw_debrief = 2/7 de la hauteur disponible mais limité à max 400 et min 150
dw_debrief.height = max(min(li_avlHeight / 7 * 2, 400), 150)
dw_debrief.object.debrief.height = dw_debrief.height - integer(dw_debrief.object.debrief_t.height) - 16

// hauteur dw_2 = hauteur disponible restante
dw_2.height = li_avlHeight - dw_debrief.height

// position dw_debrief dépend de la hauteur de dw_2
dw_debrief.y = dw_2.y + dw_2.height

// largeur des dw
dw_2.width=newwidth - 32
dw_debrief.width = dw_2.width
dw_debrief.object.debrief.width = dw_debrief.width


end event

event ue_init_menu;call super::ue_init_menu;IF wf_IsActif() AND NOT ib_realise_valid AND wf_canupdate() THEN
	f_menuaction({"m_enregistrer", "m_supprimer", "m_ajouter", "m_inserer", "m_abandonner", "m_fermer", "m_dupliquer"})
ELSE
	f_menuaction({"m_abandonner", "m_fermer"})
END IF



end event

event ue_supprimer;call super::ue_supprimer;IF ib_realise_valid THEN return
dw_2.event ue_delete()
dw_2.setFocus()
end event

event ue_inserer;call super::ue_inserer;IF ib_realise_valid THEN return
dw_2.event ue_insertrow()
dw_2.setFocus()
end event

event ue_enregistrer;call super::ue_enregistrer;integer	li_status
long		ll_row, ll_num, ll_maxnum

IF wf_isActif() = FALSE THEN
	return(0)
END IF

IF NOT wf_canUpdate() THEN
	return(0)
END IF

// contrôle de validité de tous les champs
IF dw_2.event ue_checkall() < 0 THEN
	dw_2.SetFocus()
	return(-1)
END IF

IF dw_debrief.event ue_checkall() < 0 THEN
	dw_debrief.SetFocus()
	return(-1)
END IF

// attribuer un n° de séquence aux nouvelles rows
// NB : on refait un SELECT pour prendre en compte les rows éventuellement ajoutées depuis
//      la lecture du DW (par un autre utilisateur)
select max(num) into :ll_maxnum from realise 
	where matricule=:is_prep_matricule and annee=:ii_year and semaine=:ii_week using ESQLCA;
IF isNull(ll_maxnum) THEN ll_maxnum=0
FOR ll_row = 1 TO dw_2.rowCount()
	ll_num = long(dw_2.object.num[ll_row])
	IF ll_num = 0 OR isNull(ll_num) THEN
		ll_maxnum = ll_maxnum + 1
		IF ll_maxnum >= 1000 THEN
			gu_message.uf_error("La numérotation des prestations dépasse 999 !")
			return(-1)
		END IF
		dw_2.object.num[ll_row] = ll_maxnum
	END IF
NEXT

// si pas de Notes du Chef de brigade/Débriefing opérationnel technique : supprimer
// pour ne pas générer une row vide
IF dw_debrief.rowcount() > 0 THEN
	IF f_isEmptyString(dw_debrief.object.debrief[1]) THEN
		dw_debrief.deleterow(1)
	END IF
END IF

li_status = gu_dwservices.uf_updatetransact(dw_2, dw_debrief)
CHOOSE CASE li_status
	CASE 1
		wf_message(f_translate_getlabel("TEXT_00740", "Activités réalisées enregistrées avec succès"))
		// rafraichissement
		wf_lecture()
		return(1)
	CASE -1
		populateerror(20000,"")
		gu_message.uf_unexp("REALISE : Erreur lors de la mise à jour de la base de données")
		return(-1)
	CASE -2
		populateerror(20000,"")
		gu_message.uf_unexp("REALISE_DEBRIEF : Erreur lors de la mise à jour de la base de données")
		return(-1)
END CHOOSE

end event

event ue_ajouter;call super::ue_ajouter;IF ib_realise_valid THEN return
dw_2.event ue_addrow()
dw_2.setFocus()
end event

event ue_init_win;call super::ue_init_win;p_cadenas.visible = FALSE
cb_valid.enabled = FALSE
cb_import.enabled = FALSE
cb_check.enabled = FALSE

// réinitilise le préposé
setnull(is_prep_matricule)
dw_prepose.uf_reset()
dw_prepose.insertrow(0)
dw_prepose.uf_enableitems({"prep_matricule"})

// ré-initialiser les droits update/delete qu'on a peut-être forcés dans wf_lecture()
// 07/2015 : droits d'accès attribués directement après sélection de l'agent
// wf_resetprivs()

// réinitialise le réalisé
dw_2.uf_reset()
dw_debrief.uf_reset()

// indique si le programme a été initialisé (ou pas) pour la copie de prestations planifiées
// (au départ du programme w_planning)
ib_external_initialised = FALSE
end event

event ue_close;call super::ue_close;DESTROY ibr_realise
end event

type ddlb_message from w_ancestor_dataentry`ddlb_message within w_realise
end type

type dw_2 from uo_datawindow_multiplerow within w_realise
integer x = 18
integer y = 224
integer width = 3968
integer height = 1488
integer taborder = 20
boolean bringtotop = true
string dataobject = "d_realise_tab"
boolean hscrollbar = true
boolean vscrollbar = true
boolean border = true
end type

event ue_itemvalidated;call super::ue_itemvalidated;DatawindowChild	ldwc_dropdown

CHOOSE CASE as_name
	CASE "niveau1"
		// annuler choix précédent niveau 2 et 3
		this.object.niveau2[al_row] = gu_c.i_null
		this.object.c_niveau2_display[al_row] = gu_c.s_null
		this.object.idprest[al_row] = gu_c.i_null
		this.object.c_idprest_display[al_row] = gu_c.s_null
		this.GetChild("idprest", ldwc_dropdown)
		ldwc_dropdown.setfilter("1=2")
		ldwc_dropdown.filter()
		// filtrer niveau 2 sur base nouveau niveau 1
		wf_filter_niveau2(al_row, as_name, as_data)
						
	CASE "niveau2"
		// annuler choix précédent niveau 3
		this.object.idprest[al_row] = gu_c.i_null
		this.object.c_idprest_display[al_row] = gu_c.s_null
		// filtrer niveau 3 sur base nouveau niveau 2
		wf_filter_prest(al_row, as_name, as_data)
		
	CASE "idprest"
		wf_idprest(al_row, integer(as_data))
		
	CASE "hdebut", "hfin"
		wf_calc_duree(al_row, as_name, as_data)
		
	CASE "rappel"
		// rappel : d'office prestation irrégulière
		IF as_data = "O" THEN
			this.object.irreg[al_row] = "O"
		END IF
		
	CASE "irreg"
		IF as_data = "N" THEN
			// rappel : d'office N
			this.object.rappel[al_row] = "N"
			// réinitialisation durée de prestation éventuelle
			wf_idprest(al_row, this.object.idprest[al_row])
		END IF
		
	CASE "duree"
		// si on encode manuellement la durée, on annule hdébut et hfin
		// (ne concerne que les prestations régulières version 1, pas possible pour les irrég)
		this.object.hdebut[al_row] = gu_c.date_null
		this.object.hfin[al_row] = gu_c.date_null
		
END CHOOSE




end event

event ue_checkitem;call super::ue_checkitem;integer	li_ret, li_niveau1, li_niveau2, li_idprest

CHOOSE CASE as_item
	// la date doit se trouver dans la semaine choisie
	CASE "datep"
		return(ibr_realise.uf_check_datep(as_data, as_message, ii_year, ii_week))
	
	// la catégorie de prestation (niveau 1) doit être spécifiée et doit exister
	CASE "niveau1"
		return(ibr_realise.uf_check_niveau1(as_data, as_message))
	
	// la catégorie de prestation (niveau 2) doit être spécifiée et doit exister dans la catégorie (niveau1) choisie
	CASE "niveau2"
		li_niveau1 = integer(this.object.niveau1[al_row])
		IF ibr_realise.uf_check_niveau2(li_niveau1, as_data, as_message) = -1 THEN
			return(-1)
		ELSE
			// stocker le code du niveau 2 choisi dans une zone d'affichage car quand on filtre
			// la DDDW pour une autre ligne qui a un autre niveau 1, le DDDW ne sait plus afficher le
			// code et affiche l'ID. 
			// niveau2 et c_niveau2_display sont superposés et affichés soit l'un soit l'autre
			// suivant que la row est active ou non
			this.object.c_niveau2_display[al_row] = as_message
			return(1)
		END IF
	
	// la prestation doit être spécifiée et doit exister dans la catégorie (niveau2) choisie
	CASE "idprest"
		li_niveau2 = integer(this.object.niveau2[al_row])
		IF ibr_realise.uf_check_idprest(li_niveau2, as_data, as_message) = -1 THEN
			return(-1)
		ELSE
			// stocker l'intitulé de la prestation choisie dans une zone d'affichage car quand on filtre
			// la DDDW pour une autre ligne qui a un autre niveau 2, le DDDW ne sait plus afficher le
			// code et affiche l'ID. 
			// idprest et c_idprest_display sont superposés et affichés soit l'un soit l'autre
			// suivant que la row est active ou non
			this.object.c_idprest_display[al_row] = as_message
			return(1)
		END IF
		
	// type de prestation : irrégulière O/N
	CASE "irreg"
		return(ibr_realise.uf_check_irreg(this.object.idprest[al_row], as_data, as_message))

	// rappel O/N
	CASE "rappel"
		return(ibr_realise.uf_check_rappel(this.object.idprest[al_row], as_data, as_message))
		
	// Prestations irrégulières : heures de début et de fin doivent être spécifiées
	// Prestations régulières : heures de début et de fin doivent être spécifiées
	//                          SAUF s'il y a une durée forfaitaire ou GARDE.
	//                          Concerne uniquement les nouveaux encodages (modif MARS 2015, vers>=2).
	CASE "hdebut"
		// cas particulier anciens encodages
		IF this.object.irreg[al_row] = "N" AND this.object.vers[al_row] < 2 AND isNull(as_data) THEN
			return(1)
		END IF
		
		// check normal
		li_ret = ibr_realise.uf_check_hdeb("R", this.object.irreg[al_row], &
					datetime(this.object.v_dicoprest_duree[al_row]), string(this.object.v_dicoprest_garde[al_row]), &
					string(this.object.v_dicoprest_interim[al_row]), &
					date(this.object.datep[al_row]), datetime(this.object.hfin[al_row]), as_data, as_message)
		IF li_ret = 0 THEN
			IF gu_message.uf_query(as_message + "~n~nConfirmez-vous l'encodage ?", YesNo!, 2) = 2 THEN
				li_ret = -1
			ELSE
				li_ret = 1
			END IF
		END IF
		return(li_ret)
						
	// Quand indiquées, heure de fin doit être > heure de début
	// Cas particulier : on ne sait pas encoder 24:00 pour signifier une fin d'activité à minuit.
	// On encode donc 00:00, mais il faut l'interpréter manuellement.
	CASE "hfin"
		// cas particulier anciens encodages
		IF this.object.irreg[al_row] = "N" AND this.object.vers[al_row] < 2 AND isNull(as_data) THEN
			return(1)
		END IF
		
		return(ibr_realise.uf_check_hfin("R", this.object.irreg[al_row], &
				 datetime(this.object.v_dicoprest_duree[al_row]), string(this.object.v_dicoprest_garde[al_row]), &
				 string(this.object.v_dicoprest_interim[al_row]), &
				 date(this.object.datep[al_row]), datetime(this.object.hdebut[al_row]), as_data, as_message))

	// la durée de l'activité doit être indiquée (même si elle vaut 0)
	CASE "duree"
		return(ibr_realise.uf_check_duree(as_data, as_message))
		
	// les km parcourus doivent être indiqués (même si vaut 0)
	CASE "km"
		return(ibr_realise.uf_check_km(as_data, as_message))

	// nombre d'unités : obligatoire pour intérim, facultatif sinon
	CASE "nbre"
		li_idprest = integer(this.object.idprest[al_row])
		return(ibr_realise.uf_check_nbre(as_data, as_message, li_idprest))

	// frais de séjour s'appliquent O/N
	CASE "sejour"
		return(ibr_realise.uf_check_sejour(as_data, as_message))
	
	// commentaire obligatoire s'il y a des km parcourus ou si intérim
	CASE "commentaire"
		return(ibr_realise.uf_check_commentaire(this.object.km[al_row], this.object.v_dicoprest_interim[al_row], &
															 as_data, as_message))

END CHOOSE
return(1)
end event

event ue_addrow;call super::ue_addrow;long	ll_row

ll_row = AncestorReturnValue
IF ll_row >= 1000 THEN
	gu_message.uf_error("Le maximum de 999 prestations par semaine est atteint !")
	return(-1)
END IF

wf_initNewRow(ll_row)

return(ll_row)
end event

event ue_insertrow;call super::ue_insertrow;long	ll_row

ll_row = AncestorReturnValue
wf_initNewRow(ll_row)

return(ll_row)
end event

event rowfocuschanging;call super::rowfocuschanging;// réappliquer le filtre des DDDW sur la row en cours
wf_filter_niveau2(newrow, "", "")
wf_filter_prest(newrow, "", "")
end event

event ue_rowdeleted;call super::ue_rowdeleted;long	ll_newcurrentrow

ll_newcurrentrow = dw_2.getrow()
IF ll_newcurrentrow > 0 THEN
	wf_filter_niveau2(ll_newcurrentrow, "", "")
	wf_filter_prest(ll_newcurrentrow, "", "")
END IF

end event

event ue_checkrow;call super::ue_checkrow;string	ls_message
integer	li_ancestorStatus

li_ancestorStatus = ancestorReturnValue

// PCO 13/01/2023 : on ne peut plus utiliser la filière Adm dans la matière Poli à partir des prestations du 16/01/2023
IF li_ancestorStatus = 1 THEN
	IF ibr_realise.uf_check_row(date(this.object.datep[al_row]), integer(this.object.niveau2[al_row]), ls_message) = -1 THEN
		this.scrollToRow(al_row)
		gu_message.uf_error(ls_message)
		return(-1)
	END IF
END IF
return(li_ancestorStatus)
end event

type p_1 from picture within w_realise
boolean visible = false
integer x = 2523
integer y = 1936
integer width = 73
integer height = 64
boolean bringtotop = true
boolean enabled = false
boolean originalsize = true
string picturename = "..\bmp\currentrow.png"
boolean focusrectangle = false
end type

type uo_semaine from uvo_navweek within w_realise
integer x = 55
integer y = 72
boolean bringtotop = true
end type

on uo_semaine.destroy
call uvo_navweek::destroy
end on

event ue_next;call super::ue_next;idt_from = this.uf_getfrom()
idt_to = this.uf_getto()
ii_year = this.uf_getyear()
ii_week = this.uf_getweek()

wf_lecture()
end event

event ue_prev;call super::ue_prev;idt_from = this.uf_getfrom()
idt_to = this.uf_getto()
ii_year = this.uf_getyear()
ii_week = this.uf_getweek()

wf_lecture()
end event

event ue_init;call super::ue_init;idt_from = this.uf_getfrom()
idt_to = this.uf_getto()
ii_year = this.uf_getyear()
ii_week = this.uf_getweek()

end event

event ue_check_before_nav;call super::ue_check_before_nav;// enregistrer les modif. éventuelles
IF event ue_enregistrer() < 0 THEN
	return(-1)
ELSE
	return(1)
END IF
end event

type st_prep from uo_statictext within w_realise
string tag = "TEXT_00576"
integer x = 2085
integer y = 80
integer width = 603
integer height = 80
boolean bringtotop = true
string text = "Activités réalisées par"
alignment alignment = right!
end type

type p_cadenas from uo_picture within w_realise
integer x = 1847
integer y = 56
integer width = 146
integer height = 128
boolean bringtotop = true
boolean originalsize = false
string picturename = "..\bmp\cadenas_ferme.png"
boolean map3dcolors = true
string powertiptext = "Cette semaine est validée et ne peut plus être modifée"
end type

type gb_1 from uo_groupbox within w_realise
integer x = 18
integer width = 4315
integer height = 208
end type

type dw_prepose from uo_datawindow_singlerow within w_realise
integer x = 2688
integer y = 80
integer width = 914
integer height = 96
integer taborder = 10
boolean bringtotop = true
string dataobject = "d_choix_prepose"
end type

event ue_itemvalidated;call super::ue_itemvalidated;DatawindowChild	ldwc_dropdown
integer	li_row

// conserver matricule de l'agent sélectionné dans variable d'instance
is_prep_matricule = as_data

// mémoriser codeservice de l'agent pour usage ultérieur dans le programme
select codeservice into :is_prep_codeservice
	from agent where matricule=:is_prep_matricule using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	gu_message.uf_error("AGENT : impossible de déterminer le codeservice pour " + is_prep_matricule)
	setNull(is_prep_codeservice)
END IF

// récupérer la valeur de MODIF_PLANNING qui permet de savoir si la modification des datas est autorisée
this.GetChild("prep_matricule", ldwc_dropdown)
li_row = ldwc_dropdown.GetRow()
IF ldwc_dropdown.GetItemString(li_row, "modif_realise") = "O" THEN
	wf_canUpdate(TRUE)
	wf_canDelete(TRUE)
ELSE
	wf_canUpdate(FALSE)
	wf_canDelete(FALSE)
END IF

wf_lecture()
end event

type cb_valid from commandbutton within w_realise
string tag = "TEXT_00536"
integer x = 3639
integer y = 40
integer width = 329
integer height = 80
boolean bringtotop = true
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "Valider"
end type

event clicked;br_semaine	lbr_semaine

// validation possible uniquement si l'utilisateur en a le privilège
IF NOT ib_canValid THEN
	gu_message.uf_info("Désolé, vous ne disposez pas des droits requis pour valider les activités réalisées...")
	return
END IF


// enregistrer les modif. éventuelles
IF event ue_enregistrer() < 0 THEN
	return
END IF

// On ne peut valider que s'il y a au moins 100% de la durée hebdomadaire de travail planifiée.
// PCO : contrainte supprimée suite GT technique CB C1 février 2015
//li_pc = integer(dw_2.object.c_pc_realise[1])
//IF li_pc < gi_pc_realise THEN
//	gu_message.uf_error("Vous devez encoder au moins " + string(gi_pc_realise) + " % du temps de travail pour pouvoir valider la semaine")
//	return
//END IF

// confirmation
IF gu_message.uf_query("Vous êtes sur le point de valider cette semaine d'activités. Elle ne pourra plus être modifiée par la suite.~n~n" + &
		"Confirmez-vous votre choix ?", YesNo!, 2) = 2 THEN
	return
END IF

lbr_semaine = CREATE br_semaine

IF lbr_semaine.uf_valid_realise(is_prep_matricule, ii_year, ii_week) = 1 THEN
	// refresh
	wf_lecture()
	gu_message.uf_info("Semaine validée !")
ELSE
	post close(parent)
END IF

DESTROY lbr_semaine
end event

type dw_debrief from uo_datawindow_singlerow within w_realise
integer x = 18
integer y = 1760
integer width = 2450
integer height = 352
integer taborder = 0
boolean bringtotop = true
string dataobject = "d_realise_debrief"
boolean border = true
end type

type cb_import from commandbutton within w_realise
string tag = "TEXT_00783"
integer x = 3968
integer y = 40
integer width = 338
integer height = 80
boolean bringtotop = true
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "Importer..."
end type

event clicked;// importer fichier XML
integer	li_rt
long		ll_row
string	ls_foldername, ls_pathname, ls_filename, ls_text1, ls_text2, ls_text3, ls_text4, &
			ls_basename, ls_suffix
uo_fileservices	lu_fileservices

ls_text1 = f_translate_getlabel("TEXT_00739", "Sélection du fichier d'activités réalisées")
ls_text2 = f_translate_getlabel("TEXT_00736", "Fichier de données XML,*.xml")
ls_text3 = f_translate_getlabel("TEXT_00737", "Aucun fichier sélectionné")
ls_text4 = f_translate_getlabel("TEXT_00770", "Aucun preposé sélectionné !")

IF f_isEmptyString(is_prep_matricule) THEN
	gu_message.uf_info(ls_text4)
	return(-1)
END IF

// PCO 16FEV2016 : récupérer le dernier dossier utilisé. Par défaut = gs_myDocuments.
ls_foldername = profileString(gs_locinifile, gs_username, "CT_importRealFolder", gs_myDocuments)

// choix du fichier XML à importer
// PCO OCT 2016 : flags 26 = composition 2, 4 et 5 (voir PB help)
IF GetFileOpenName(ls_text1, ls_pathname, ls_filename, &
	"XML", ls_text2, ls_foldername, 26) < 1 THEN
		gu_message.uf_info(ls_text3)
		return
END IF	

// PCO 16FEV2016 : stocker le dernier dossier utilisé
lu_fileservices = CREATE uo_fileservices
lu_fileservices.uf_basename(ls_pathname, false, ls_foldername, ls_basename, ls_suffix)
DESTROY uo_fileservices
setprofileString(gs_locinifile, gs_username, "CT_importRealFolder", ls_foldername)

// importer le fichier
IF wf_importXML(ls_pathname) < 0 THEN
	// si erreur, tenter conversion vers fichier avec template puis nouvelle tentative import
	li_rt = wf_convertXML(ls_pathname)
	IF li_rt = 1 THEN
		li_rt = wf_importXML(ls_pathname)
		IF li_rt < 0 THEN
			gu_message.uf_error("Erreur " + string(li_rt) + " importation " + ls_pathname)
		END IF
	ELSE
		gu_message.uf_error("Erreur " + string(li_rt) + " importation/conversion " + ls_pathname)
	END IF
END IF

end event

type cb_check from commandbutton within w_realise
string tag = "TEXT_00538"
integer x = 3639
integer y = 120
integer width = 329
integer height = 80
boolean bringtotop = true
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "Vérifier"
end type

event clicked;str_params	lstr_params
string		ls_prepose[]

// enregistrer les modif. éventuelles
IF event ue_enregistrer() < 0 THEN
	return(-1)
END IF

ls_prepose[1] = is_prep_matricule

lstr_params.a_param[1] = ii_year
lstr_params.a_param[2] = ii_week
lstr_params.a_param[3] = idt_from
lstr_params.a_param[4] = idt_to
lstr_params.a_param[5] = ls_prepose

IF isValid(w_rpt_realise_anomalies) THEN
	close(w_rpt_realise_anomalies)
END IF
openSheetWithParm(w_rpt_realise_anomalies, lstr_params, gw_mdiframe, 0, Original!)
end event

