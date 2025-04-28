//objectcomments Gestion des plannings pour plusieurs préposés en une fois
forward
global type w_planning_equipe from w_ancestor_dataentry
end type
type dw_2 from uo_datawindow_multiplerow within w_planning_equipe
end type
type p_1 from picture within w_planning_equipe
end type
type uo_semaine from uvo_navweek within w_planning_equipe
end type
type dw_prepose from uo_datawindow_multiplerow within w_planning_equipe
end type
type rb_individuel from uo_radiobutton within w_planning_equipe
end type
type rb_equipe from uo_radiobutton within w_planning_equipe
end type
type gb_1 from uo_groupbox within w_planning_equipe
end type
end forward

global type w_planning_equipe from w_ancestor_dataentry
string tag = "TEXT_00565"
integer width = 4069
integer height = 2344
string title = "Planification pour plusieurs préposés"
boolean maxbox = true
boolean resizable = true
event ue_print ( )
event ue_duplicate ( )
event ue_attempt_reconnect ( )
dw_2 dw_2
p_1 p_1
uo_semaine uo_semaine
dw_prepose dw_prepose
rb_individuel rb_individuel
rb_equipe rb_equipe
gb_1 gb_1
end type
global w_planning_equipe w_planning_equipe

type variables
br_saisie	ibr_planning
integer		ii_year, ii_week
date			idt_from, idt_to

end variables

forward prototypes
public subroutine wf_calc_duree (long al_row, string as_name, string as_data)
public subroutine wf_initnewrow (long al_row)
public subroutine wf_idprest (long al_row, integer ai_idprest)
public function integer wf_confirm_cancel ()
public function integer wf_retrieve ()
public subroutine wf_check_valid ()
public subroutine wf_filter_prest (long al_row, string as_name, string as_data)
public subroutine wf_change_semaine ()
public subroutine wf_filter_niveau2 (long al_row, string as_name, string as_data)
end prototypes

event ue_duplicate();// Déclenché par l'action "dupliquer" du menu.
// Dupliquer la ligne en cours en ajoutant un jour à la date
long	ll_currentrow, ll_newrow
integer	li_rc
datetime	l_datep

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

dw_prepose.settransobject(SQLCA)

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

public subroutine wf_initnewrow (long al_row);IF al_row > 0 THEN
	dw_2.object.annee[al_row] = ii_year
	dw_2.object.semaine[al_row]= ii_week
	dw_2.object.irreg[al_row] = "N"
	// PCO 25/11/2016 : ajout colonne TRFREALISE
	dw_2.object.trfrealise[al_row] = "N"
	// version : 2 à partir des modif de MARS 2015
	// version : 4 à partir du nouveau référentiel (NOV 2015 ?)
	// version : 5 à partir du 25 NOV 2016 : nouvelle colonne TRFREALISE
	dw_2.object.vers[al_row] = gi_dataVersion_planning
END IF

end subroutine

public subroutine wf_idprest (long al_row, integer ai_idprest);// lecture des propriétés de la prestation
string	ls_garde, ls_cumul, ls_irregcompat, ls_unite, ls_interim, ls_trad_unite
datetime	ldt_duree, ldt_duree_zero
decimal{2}	ld_nbre

select d.duree, d.garde, d.cumul, d.irregcompat, d.unite, d.interim, v_unitprest.trad
	into :ldt_duree, :ls_garde, :ls_cumul, :ls_irregcompat, :ls_unite, :ls_interim, :ls_trad_unite
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
	ld_nbre = int(dw_2.object.nbre[al_row])
	IF isNull(ld_nbre) OR ld_nbre = 0 THEN
		dw_2.object.nbre[al_row] = 1
	END IF
END IF

IF ls_irregcompat = "N" THEN
	dw_2.object.irreg[al_row] = "N"
END IF

IF isNull(ls_unite) THEN
	dw_2.object.nbre[al_row] = gu_c.d_null
END IF

dw_2.object.v_dicoprest_duree[al_row] = ldt_duree
dw_2.object.v_dicoprest_garde[al_row] = ls_garde
dw_2.object.v_dicoprest_cumul[al_row] = ls_cumul
dw_2.object.v_dicoprest_unite[al_row] = ls_unite
dw_2.object.v_dicoprest_interim[al_row] = ls_interim
dw_2.object.v_unitprest_trad[al_row] = ls_trad_unite
end subroutine

public function integer wf_confirm_cancel ();// Enregistrer les modif avant de passer à d'autres données
// return(1) : OK pour passer à la suite du traitement, soit après enregistrement réussi des données
//             soit si on décide de ne pas enregistrer.
// return(-1) : ne pas passer à la suite du traitement, soir après échec de l'enregistrement
//              soit si on décide d'abandonner.
CHOOSE CASE gu_dwservices.uf_confirm_cancel(idw_dwlist)
	CASE 1
		IF event ue_enregistrer() >= 0 THEN
			return(1)
		ELSE
			return(-1)
		END IF
	CASE 2
		wf_message("Modifications abandonnées")
		return(1)
	CASE 3
		return(-1)
END CHOOSE
end function

public function integer wf_retrieve ();DatawindowChild	ldwc_dropdown
string	ls_err, ls_super

// I. Lire la liste des préposés du responsable
// Attention : si membre du groupe de superusers "FULL", accès à tous les agents paramétrés dans le système !
ls_err = "Erreur lecture liste des préposés"
IF gu_privs.uf_super("FULL") THEN
	ls_super = "O"
ELSE
	ls_super = "N"
END IF
// 07/2015 : pour modifier le planning de plusieurs agents, le droit de modifier les données est nécessaire
// - le droit de modifier le planning est nécessaire, pas celui de le consulter : 3ème argument="N" et 4ème argument="O"
// - concernant le réalisé, aucun droit n'est impliqué : 5 et 6ème arguments = "N"
IF dw_prepose.retrieve(gs_username, ls_super, "N", "O", "N", "N") <= 0 THEN
	populateError(20000, ls_err)
	GOTO ERREUR
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

public subroutine wf_check_valid ();// Vérification des agents sélectionnés : si la semaine a déjà été validée, on désélectionne l'agent.
long		ll_row
string	ls_valid, ls_matricule, ls_nom, ls_listeNoms

FOR ll_row = 1 TO dw_prepose.rowCount()
	// ne vérifier que les agents sélectionnés
	IF integer(dw_prepose.object.c_select[ll_row]) = 0 THEN CONTINUE
	ls_matricule = f_string(dw_prepose.object.prep_matricule[ll_row])
	ls_nom = f_string(dw_prepose.object.agent_nom[ll_row])
	select planning_valid into :ls_valid from semaine_valid
		where matricule=:ls_matricule and annee=:ii_year and semaine=:ii_week using ESQLCA;
	CHOOSE CASE f_check_sql(ESQLCA)
		CASE 100
			CONTINUE
		CASE 0
			IF ls_valid = "O" THEN
				dw_prepose.object.c_select[ll_row] = 0
				ls_listeNoms = ls_listeNoms + ls_nom + ", "
			END IF
		CASE -1
			populateError(20000, "")
			gu_message.uf_unexp("Erreur SELECT PLANNING_VALID " + ls_matricule + " - " + ls_nom)
	END CHOOSE
NEXT

IF NOT f_isEmptyString(ls_listeNoms) THEN
	ls_listeNoms = left(ls_listeNoms, len(ls_listeNoms) - 2)
	gu_message.uf_info("Le planning de cette semaine est déjà validé pour les agents suivants : " + &
	ls_listeNoms + ".~nIls ont été supprimés de la sélection.")
END IF

end subroutine

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
Dw_2.SetItem(al_row,'idprest',dw_2.object.idprest[al_row])
end subroutine

public subroutine wf_change_semaine ();// si on change de semaine, il faut également la modifier dans les rows déjà encodées
long	ll_row

FOR ll_row = 1 TO dw_2.rowCount()
	dw_2.object.annee[ll_row] = ii_year
	dw_2.object.semaine[ll_row] = ii_week
NEXT
end subroutine

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
Dw_2.SetItem(al_row,'niveau2',dw_2.object.niveau2[al_row])
	
end subroutine

event ue_open;call super::ue_open;// BR encodage
ibr_planning = CREATE br_saisie

wf_SetDWList({dw_2})

// icône "ajouter" doit être visible dans le menu
wf_SetItemsToShow({"m_ajouter", "m_inserer", "m_dupliquer"})

// PCO 31/10/2016 : autoselectrow en fonction du choix de l'utilisateur dans les options
dw_2.uf_autoselectrow(gb_autoSelectRow)
dw_2.SetRowFocusIndicator(p_1, 16)
dw_2.uf_createwhenlastdeleted(FALSE)

rb_equipe.checked = TRUE
rb_individuel.checked = FALSE

// bouton de transfert du planning vers le réalisé est sans objet ici
dw_2.object.b_real.visible = FALSE

// stocker dans le DW le temps de travail hebdomadaire en minutes
dw_2.object.c_tthebdo_minutes.expression = "'" + string(gi_tthebdo) + "'"
	
// lecture du contenu des DDDW et de la liste des préposés
wf_retrieve()
end event

on w_planning_equipe.create
int iCurrent
call super::create
this.dw_2=create dw_2
this.p_1=create p_1
this.uo_semaine=create uo_semaine
this.dw_prepose=create dw_prepose
this.rb_individuel=create rb_individuel
this.rb_equipe=create rb_equipe
this.gb_1=create gb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_2
this.Control[iCurrent+2]=this.p_1
this.Control[iCurrent+3]=this.uo_semaine
this.Control[iCurrent+4]=this.dw_prepose
this.Control[iCurrent+5]=this.rb_individuel
this.Control[iCurrent+6]=this.rb_equipe
this.Control[iCurrent+7]=this.gb_1
end on

on w_planning_equipe.destroy
call super::destroy
destroy(this.dw_2)
destroy(this.p_1)
destroy(this.uo_semaine)
destroy(this.dw_prepose)
destroy(this.rb_individuel)
destroy(this.rb_equipe)
destroy(this.gb_1)
end on

event resize;call super::resize;gb_1.width=newwidth - 32
dw_2.width=newwidth - 32 - dw_prepose.width
dw_2.height=newheight - gb_1.height - 110
dw_prepose.height = dw_2.height

end event

event ue_init_menu;call super::ue_init_menu;IF wf_canupdate() THEN
	f_menuaction({"m_enregistrer", "m_supprimer", "m_ajouter", "m_inserer", "m_abandonner", "m_fermer", "m_dupliquer"})
ELSE
	f_menuaction({"m_fermer"})
END IF

end event

event ue_supprimer;call super::ue_supprimer;dw_2.event ue_delete()
dw_2.setFocus()
end event

event ue_inserer;call super::ue_inserer;dw_2.event ue_insertrow()
dw_2.setFocus()
end event

event ue_enregistrer;call super::ue_enregistrer;integer	li_status
string	ls_matricule, ls_listeNoms, ls_nom, ls_nom_st, ls_prep_codeservice
long		ll_rowprep, ll_row, ll_num, ll_maxnum
uo_ds		lds_copie, lds_planning

// contrôle de validité de tous les champs
IF dw_2.event ue_checkall() < 0 THEN
	dw_2.SetFocus()
	return(-1)
END IF

// vérifier présence d'au moins une ligne
IF dw_2.rowCount() = 0 THEN
	gu_message.uf_info(f_translate_getlabel("TEXT_00769", "Aucune prestation planifiée !"))
	dw_2.SetFocus()
	return(-1)
END IF

// vérifier qu'il y a au moins un préposé sélectionné
IF integer(dw_prepose.object.c_sum_selected[1]) = 0 THEN
	gu_message.uf_info(f_translate_getlabel("TEXT_00770", "Aucun preposé sélectionné !"))
	dw_prepose.SetFocus()
	return(-1)
END IF

// si planification pour une équipe, constituer string contenant la liste des agents sélectionnés
// PCO 26/01/2016 : si un seul préposé sélectionné, ne pas constituer de liste de noms
IF rb_equipe.checked AND integer(dw_prepose.object.c_sum_selected[1]) > 1 THEN
	FOR ll_rowprep = 1 TO dw_prepose.rowCount()
		IF integer(dw_prepose.object.c_select[ll_rowprep]) = 0 THEN CONTINUE
		ls_listeNoms = ls_listeNoms + f_string(dw_prepose.object.agent_nom[ll_rowprep]) + ", "
	NEXT
	ls_listeNoms = left(ls_listeNoms, len(ls_listeNoms) - 2)
END IF

// dans une copie du planning, constituer le champ "accompagné de" en concaténant ce qu'on y a 
// saisi et la liste des agents sélectionnés
// PCO 13/02/2015 : on n'ajoute la liste des agents au champ "accompagné de" uniquement en cas
//                  de planification par équipe, pas dans le cas d'une planification individuelle.
//                  Le datastore COPIE est néanmoins conservé.
lds_copie = CREATE uo_ds
lds_copie.dataObject = "d_planning_tab"
lds_copie.object.data = dw_2.object.data
IF rb_equipe.checked THEN
	FOR ll_row = 1 TO lds_copie.rowCount()
		IF f_isEmptyString(lds_copie.object.accomp[ll_row]) THEN
			lds_copie.object.accomp[ll_row] = ls_listeNoms
		ELSE
			lds_copie.object.accomp[ll_row] = lds_copie.object.accomp[ll_row] + " - " + ls_listeNoms
		END IF
	NEXT
END IF

// créer un DS qui contiendra le planning pré-existant du préposé, dans lequel on ajoutera le
// planning d'équipe
lds_planning = CREATE uo_ds
lds_planning.dataObject = "d_planning_tab"
lds_planning.settransobject(SQLCA)

// Ajouter le planning à tous les préposés sélectionnés
FOR ll_rowprep = 1 TO dw_prepose.rowCount()
	IF integer(dw_prepose.object.c_select[ll_rowprep]) = 0 THEN CONTINUE
	ls_matricule = f_string(dw_prepose.object.prep_matricule[ll_rowprep])
	ls_nom = f_string(dw_prepose.object.agent_nom[ll_rowprep])
	ls_prep_codeservice = f_string(dw_prepose.object.agent_codeservice[ll_rowprep])
	
	// lire le planning qui existe peut-être déjà pour le préposé
	lds_planning.retrieve(ls_matricule, ii_year, ii_week)
	
	// ajouter le nouveau planning à l'existant éventuel
	lds_copie.rowscopy(1, lds_copie.rowCount(), Primary!, lds_planning, lds_planning.rowcount() + 1, Primary!)
	
	// attribuer matricule et n° de séquence aux nouvelles rows
	ll_maxnum = long(lds_planning.object.c_maxnum[1])
	IF isNull(ll_maxnum) THEN ll_maxnum=0
	FOR ll_row = 1 TO lds_planning.rowCount()
		lds_planning.object.matricule[ll_row] = ls_matricule
		// PCO 08/12/2015 : stocker codeservice
		lds_planning.object.codeservice[ll_row] = ls_prep_codeservice
		ll_num = long(lds_planning.object.num[ll_row])
		IF ll_num = 0 OR isNull(ll_num) THEN
			ll_maxnum = ll_maxnum + 1
			IF ll_maxnum >= 1000 THEN
				gu_message.uf_error("La numérotation des prestations dépasse 999 pour le matricule " + ls_matricule + &
										  ".~nLa mise à jour ne peut avoir lieu MAIS se poursuit pour l'agent suivant.")
			END IF
			lds_planning.object.num[ll_row] = ll_maxnum
		END IF
	NEXT
	
	// update DB
	li_status = gu_dwservices.uf_updatetransact(lds_planning)
	CHOOSE CASE li_status
		CASE 1
			ls_nom_st = ls_nom_st + ls_nom + " " + &
							f_translate_getlabel("TEXT_00771", "enregistré avec succès") + ".~n"
			wf_message("Planning de " + ls_nom + " enregistré avec succès")
		CASE -1
			ls_nom_st = ls_nom_st + ls_nom + " : erreur lors de la mise à jour de la base de données.~n"
			wf_message("Planning de " + ls_nom + " : erreur lors de la mise à jour de la base de données")
			populateerror(20000,"")
			gu_message.uf_unexp("Planning de " + ls_nom + " : erreur lors de la mise à jour de la base de données")
			return(-1)
	END CHOOSE
NEXT

DESTROY lds_planning
DESTROY lds_copie

dw_2.uf_reset()

gu_message.uf_info(ls_nom_st)
end event

event ue_ajouter;call super::ue_ajouter;dw_2.event ue_addrow()
dw_2.setFocus()
end event

event ue_init_win;call super::ue_init_win;// réinitialise le planning
dw_2.uf_reset()
end event

event ue_close;call super::ue_close;DESTROY ibr_planning
end event

type ddlb_message from w_ancestor_dataentry`ddlb_message within w_planning_equipe
integer y = 1936
end type

type dw_2 from uo_datawindow_multiplerow within w_planning_equipe
integer x = 841
integer y = 224
integer width = 3163
integer height = 592
integer taborder = 30
boolean bringtotop = true
string dataobject = "d_planning_tab"
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
		
	CASE "duree"
		// si on encode manuellement la durée, on annule hdébut et hfin
		// (ne concerne que les prestations régulières, pas possible pour les irrég)
		this.object.hdebut[al_row] = gu_c.date_null
		this.object.hfin[al_row] = gu_c.date_null
END CHOOSE




end event

event ue_checkitem;call super::ue_checkitem;integer	li_ret, li_niveau1, li_niveau2, li_idprest

CHOOSE CASE as_item
	// la date doit se trouver dans la semaine choisie
	CASE "datep"
		return(ibr_planning.uf_check_datep(as_data, as_message, ii_year, ii_week))
	
	// la catégorie de prestation (niveau 1) doit être spécifiée et doit exister
	CASE "niveau1"
		return(ibr_planning.uf_check_niveau1(as_data, as_message))
		
	// la catégorie de prestation (niveau 2) doit être spécifiée et doit exister dans la catégorie (niveau1) choisie
	CASE "niveau2"
		li_niveau1 = integer(this.object.niveau1[al_row])
		IF ibr_planning.uf_check_niveau2(li_niveau1, as_data, as_message) = -1 THEN
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
		IF ibr_planning.uf_check_idprest(li_niveau2, as_data, as_message) = -1 THEN
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
		return(ibr_planning.uf_check_irreg(this.object.idprest[al_row], as_data, as_message))
		
	// Prestations irrégulières : heures de début et de fin doivent être spécifiées
	// Prestations régulières : heures de début et de fin facultatives
	CASE "hdebut"
		li_ret = ibr_planning.uf_check_hdeb("P", this.object.irreg[al_row], &
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
				
	// Si indiquées, heure de fin doit être > heure de début.
	// Cas particulier : on ne sait pas encoder 24:00 pour signifier une fin d'activité à minuit.
	// On encode donc 00:00, mais il faut l'interpréter manuellement.
	CASE "hfin"
		return(ibr_planning.uf_check_hfin("P", this.object.irreg[al_row], &
				 datetime(this.object.v_dicoprest_duree[al_row]), string(this.object.v_dicoprest_garde[al_row]), &
				 string(this.object.v_dicoprest_interim[al_row]), &
				 date(this.object.datep[al_row]), datetime(this.object.hdebut[al_row]), as_data, as_message))

	// la durée de l'activité doit être indiquée (même si elle vaut 0)
	CASE "duree"
		return(ibr_planning.uf_check_duree(as_data, as_message))

	CASE "nbre"
		li_idprest = integer(this.object.idprest[al_row])
		return(ibr_planning.uf_check_nbre(as_data, as_message, li_idprest))

	CASE "lieu"
		return(ibr_planning.uf_check_lieu(this.object.v_dicoprest_interim[al_row], as_data, as_message))
		
	CASE "accomp"
		return(ibr_planning.uf_check_accomp(as_data, as_message))

END CHOOSE
return(1)
end event

event ue_addrow;call super::ue_addrow;long	ll_row

ll_row = AncestorReturnValue
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
	IF ibr_planning.uf_check_row(date(this.object.datep[al_row]), integer(this.object.niveau2[al_row]), ls_message) = -1 THEN
		this.scrollToRow(al_row)
		gu_message.uf_error(ls_message)
		return(-1)
	END IF
END IF
return(li_ancestorStatus)
end event

type p_1 from picture within w_planning_equipe
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

type uo_semaine from uvo_navweek within w_planning_equipe
integer x = 933
integer y = 76
boolean bringtotop = true
end type

on uo_semaine.destroy
call uvo_navweek::destroy
end on

event ue_next;call super::ue_next;idt_from = uo_semaine.uf_getfrom()
idt_to = uo_semaine.uf_getto()
ii_year = uo_semaine.uf_getyear()
ii_week = uo_semaine.uf_getweek()
wf_check_valid()
wf_change_semaine()

end event

event ue_prev;call super::ue_prev;idt_from = uo_semaine.uf_getfrom()
idt_to = uo_semaine.uf_getto()
ii_year = uo_semaine.uf_getyear()
ii_week = uo_semaine.uf_getweek()
wf_check_valid()
wf_change_semaine()

end event

event ue_init;call super::ue_init;idt_from = uo_semaine.uf_getfrom()
idt_to = uo_semaine.uf_getto()
ii_year = uo_semaine.uf_getyear()
ii_week = uo_semaine.uf_getweek()

end event

event ue_check_before_nav;call super::ue_check_before_nav;return(wf_confirm_cancel())
end event

type dw_prepose from uo_datawindow_multiplerow within w_planning_equipe
integer x = 18
integer y = 224
integer width = 823
integer height = 1488
integer taborder = 11
boolean bringtotop = true
string dataobject = "d_prepose_multiple"
boolean hscrollbar = true
boolean vscrollbar = true
boolean border = true
end type

event ue_checkitem;call super::ue_checkitem;string ls_valid, ls_matricule

// vérifier que la semaine n'est pas déjà validée pour l'agent sélectionné
IF integer(as_data) = 1 THEN
	ls_matricule = dw_prepose.object.prep_matricule[al_row]
	select planning_valid into :ls_valid from semaine_valid
		where matricule=:ls_matricule and annee=:ii_year and semaine=:ii_week using ESQLCA;
	IF ls_valid = "O" THEN
		as_message = "Semaine déjà validée pour cet agent, elle ne peut plus être modifiée."
		return(-1)
	END IF
END IF

return(1)
end event

type rb_individuel from uo_radiobutton within w_planning_equipe
string tag = "TEXT_00561"
integer x = 494
integer y = 80
integer width = 384
boolean bringtotop = true
string text = "individuel"
end type

type rb_equipe from uo_radiobutton within w_planning_equipe
string tag = "TEXT_00560"
integer x = 73
integer y = 80
boolean bringtotop = true
string text = "par équipe"
end type

type gb_1 from uo_groupbox within w_planning_equipe
integer x = 18
integer width = 3986
integer height = 208
end type

