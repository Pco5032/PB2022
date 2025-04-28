//objectcomments Gestion des plannings
forward
global type w_planning from w_ancestor_dataentry
end type
type dw_2 from uo_datawindow_multiplerow within w_planning
end type
type p_1 from picture within w_planning
end type
type uo_semaine from uvo_navweek within w_planning
end type
type st_prep from uo_statictext within w_planning
end type
type p_cadenas from uo_picture within w_planning
end type
type gb_1 from uo_groupbox within w_planning
end type
type dw_prepose from uo_datawindow_singlerow within w_planning
end type
type cb_valid from commandbutton within w_planning
end type
type cb_outlook from commandbutton within w_planning
end type
type cb_import from commandbutton within w_planning
end type
type cb_export from commandbutton within w_planning
end type
type cb_check from commandbutton within w_planning
end type
end forward

global type w_planning from w_ancestor_dataentry
string tag = "TEXT_00552"
integer width = 4695
integer height = 2344
string title = "Planification"
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
cb_outlook cb_outlook
cb_import cb_import
cb_export cb_export
cb_check cb_check
end type
global w_planning w_planning

type variables
br_saisie	ibr_planning
uo_ds			ids_planning_id
integer		ii_year, ii_week
string		is_prep_matricule, is_prep_codeservice, is_prep_mailbox
date			idt_from, idt_to
boolean		ib_planning_valid, ib_canValid

string		is_outlook // PCO 30/03/2021 : indique si on utilise EWS ou OLE pour mise à jour planning Outlook.
							  // valeur paramétrée dans table PARAMS pour pouvoir changer rapidement en cas de souci.
							  // Passage de EWS à OUTLOOK le 30/03/2021. On pourra supprimer ce paramètre et 
							  // laisser l'option OLE si tout est OK.
end variables

forward prototypes
public subroutine wf_calc_duree (long al_row, string as_name, string as_data)
public subroutine wf_initnewrow (long al_row)
public subroutine wf_lecture ()
public subroutine wf_print ()
public subroutine wf_idprest (long al_row, integer ai_idprest)
public function integer wf_retrieve ()
public subroutine wf_filter_prest (long al_row, string as_name, string as_data)
public function integer wf_sendtoexchange ()
public subroutine wf_filter_niveau2 (long al_row, string as_name, string as_data)
public function integer wf_exportxml ()
public function integer wf_importxml ()
public function integer wf_meeting ()
public function integer wf_getcleanpwd (ref string as_pwd)
end prototypes

event ue_print();wf_print()
end event

event ue_duplicate();// Déclenché par l'action "dupliquer" du menu.
// Dupliquer la ligne en cours en ajoutant un jour à la date
long	ll_currentrow, ll_newrow
integer	li_rc
datetime	l_datep

IF ib_planning_valid THEN return
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

dw_prepose.GetChild("prep_matricule", ldwc_dropdown)
ldwc_dropdown.settransobject(SQLCA)

dw_2.GetChild("niveau1", ldwc_dropdown)
ldwc_dropdown.settransobject(SQLCA)

dw_2.GetChild("niveau2", ldwc_dropdown)
ldwc_dropdown.settransobject(SQLCA)

dw_2.GetChild("idprest", ldwc_dropdown)
ldwc_dropdown.settransobject(SQLCA)

ids_planning_id.setTransObject(SQLCA)
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
		
		l_dt = datetime(l_date, lt_duree)
		dw_2.object.duree[al_row] = l_dt
END CHOOSE


end subroutine

public subroutine wf_initnewrow (long al_row);IF al_row > 0 THEN
	dw_2.object.matricule[al_row]	= is_prep_matricule
	dw_2.object.annee[al_row] = ii_year
	dw_2.object.semaine[al_row]= ii_week
	dw_2.object.irreg[al_row] = "N"
	// PCO 08/12/2015 : ajouter stockage du codeservice
	dw_2.object.codeservice[al_row]	= is_prep_codeservice
	// PCO 25/11/2016 : ajout colonne TRFREALISE
	dw_2.object.trfrealise[al_row] = "N"
	// version : 2 à partir des modif de MARS 2015
	// version : 3 à partir des modif de JUILLET 2015
	// version : 4 à partir du nouveau référentiel (NOV 2015 ?)
	// version : 5 à partir du 25 NOV 2016 : nouvelle colonne TRFREALISE
	dw_2.object.vers[al_row] = gi_dataVersion_planning
END IF

end subroutine

public subroutine wf_lecture ();// lecture des données pour le préposé sélectionné, pour la semaine sélectionnée
string	ls_planning_valid

IF f_isEmptyString(is_prep_matricule) THEN
	return
END IF

dw_prepose.uf_disableitems({"prep_matricule"})

// lecture de la semaine pour voir si elle est déjà validée
select planning_valid into :ls_planning_valid from semaine_valid
	where matricule=:is_prep_matricule and annee=:ii_year and semaine=:ii_week using ESQLCA;
IF f_check_sql(ESQLCA) < 0 THEN
	populateError(20000, "")
	gu_message.uf_unexp("Erreur SELECT SEMAINE_VALID")
	post close(this)
	return
END IF

// semaine n'existe pas encore --> forcément non validée
IF ESQLCA.sqlnrows = 100 THEN ib_planning_valid = FALSE

// bouton validation : uniquement si la semaine n'est pas déjà validée
// (on controlera aussi si l'utilisateur a le privilège de valider ou pas)
IF ls_planning_valid = "O" THEN
	cb_valid.enabled = FALSE
	ib_planning_valid = TRUE
ELSE
	IF ib_canValid AND wf_canUpdate() THEN cb_valid.enabled = TRUE
	ib_planning_valid = FALSE
END IF

// lecture des activités planifiées pour la semaine
IF dw_2.retrieve(is_prep_matricule, ii_year, ii_week) > 0 THEN
	// réappliquer le filtre des DDDW sur la row en cours
	wf_filter_niveau2(1, "", "")
	wf_filter_prest(1, "", "")
END IF

// lecture des ID (activités transférées dans Outlook)
ids_planning_id.retrieve(is_prep_matricule, ii_year, ii_week)

wf_actif(TRUE)

// si pas le droit d'update, on l'accorde malgré tout pour l'utilisateur lui-même
// 07/2015 : plus ici, voir code directement après sélection de l'agent
//IF NOT wf_canUpdate() THEN
//	IF is_prep_matricule = gs_username THEN
//		wf_canUpdate(TRUE)
//		wf_canDelete(TRUE)
//	END IF
//END IF

// activer ou pas les DW selon que la semaine est validée ou pas et selon que l'utilisateur
// a le droit de modifier ou pas.
// PCO 09/10/2015 : bouton R reste actif même si planning validé (si droit update REALISE!)
p_cadenas.visible = ib_planning_valid
IF ib_planning_valid OR wf_canupdate() = FALSE THEN
	dw_2.uf_disabledata()
	// désactiver bouton R
	// dw_2.object.b_real.Enabled = "No"
ELSE
	dw_2.uf_enabledata()
	// activer bouton R
	// dw_2.object.b_real.Enabled = "Yes"
END IF

// PCO 09/10/2015 : bouton R reste actif même si planning validé (si droit update dans REALISE
// ou son propre réalisé)
IF gu_privs.uf_canupdate("w_realise") = 1 OR is_prep_matricule = gs_username THEN
	dw_2.object.b_real.Enabled = "Yes"
ELSE
	dw_2.object.b_real.Enabled = "No"
END IF

// activer bouton de transfert vers Outlook
cb_outlook.enabled = TRUE

// importation de données : uniquement si droit de modifier les données et semaine non validée
IF NOT ib_planning_valid AND wf_canUpdate() THEN
	cb_import.enabled = TRUE
ELSE
	cb_import.enabled = FALSE
END IF

// exportation de donnés pour utilisation dans version light
cb_export.enabled = TRUE

// vérification de la cohérence des données : toujours possible
cb_check.enabled = TRUE

event post ue_init_menu()
end subroutine

public subroutine wf_print ();// impression du planning en cours
str_params	lstr_params

IF f_isEmptyString(is_prep_matricule) THEN
	gu_message.uf_info("Veuillez sélectionner un agent avant de demander d'imprimer")
	return
END IF

// enregistrer les modif. éventuelles
IF event ue_enregistrer() < 0 THEN
	return
END IF

IF IsValid(w_rpt_planning) THEN
	close(w_rpt_planning)
END IF

lstr_params.a_param[1] = is_prep_matricule
lstr_params.a_param[2] = ii_year
lstr_params.a_param[3] = ii_week
OpenSheetWithParm(w_rpt_planning, lstr_params, gw_mdiframe, 0, Original!)
IF IsValid(w_rpt_planning) THEN
	w_rpt_planning.SetFocus()
END IF
end subroutine

public subroutine wf_idprest (long al_row, integer ai_idprest);// lecture des propriétés de la prestation
string	ls_garde, ls_cumul, ls_irregcompat, ls_unite, ls_interim, ls_trad_unite
datetime	ldt_duree, ldt_duree_zero
decimal{2}	ld_nbre

IF isNull(ai_idprest) OR ai_idprest = 0 THEN
	return
END IF

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
	ld_nbre = dec(dw_2.object.nbre[al_row])
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
// 07/2015 : argument "P" : indique qu'on souhaite la liste des agents pour lesquels on a le droit 
// de consulter (et peut-être modifier) le Planning.
ll_nbrows = ldwc_dropdown.retrieve(gs_username, ls_super, "P")
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

public function integer wf_sendtoexchange ();// Envoyer les activités planifiées vers le planning Outlook.
// Fait usage des librairies EWS (Exchange Web Services Managed API) qui doivent se trouver
// dans le dossier Exchange sous le dossier où est installé l'application CARNET sur le PC.
// return(1) si OK
// return(-1) en cas d'erreur
uo_ds		lds_exchange
integer	li_fileRead, li_fileWrite, li_annee, li_semaine, li_num, li_rtc, li_importStatus
long		ll_row, ll_row_id, ll_rowCount
string	ls_cmd, ls_filename, ls_line, ls_matricule, ls_id, ls_err, ls_status, ls_ExchangePwd
uo_fileservices	lu_fileservices

ls_filename = gs_tmpfiles + "\CalendarItems.csv"
li_rtc = 1

// l'utilisateur en cours doit être le même que celui dont on veut envoyer les activités dans Exchange
IF is_prep_matricule <> gs_username THEN
	gu_message.uf_error("Vous ne pouvez pas synchroniser Outlook pour un autre utilisateur que vous-même...")
	return(-1)
END IF

lds_exchange = CREATE uo_ds
lds_exchange.dataObject = "ds_exchange"
lds_exchange.setTransObject(SQLCA)

// retrieve les rows sans planning ID ainsi que celles générées par EWS/OLE
lds_exchange.retrieve(is_prep_matricule, ii_year, ii_week)

// si méthode est EWS, traiter les rows sans planning (création) et celles générées par EWS (mise à jour)
IF is_outlook = "EWS" THEN
	lds_exchange.setfilter("tech='EWS' OR isNull(tech)")
ELSE
// si méthode est OLE, traiter uniquement les rows générées par EWS (mise à jour)
	lds_exchange.setfilter("tech='EWS'")
END IF
lds_exchange.filter()

// Pas de traiment EWS à faire
IF lds_exchange.rowCount() <= 0 THEN
	GOTO FIN
END IF

// PCO 31/03/2021 : demande PWD déplacée pour ne pas le demander si pas de traitement EWS à faire
IF wf_getcleanpwd(ls_ExchangePwd) = -1 THEN
	li_rtc = -1
	setNull(ls_err)
	GOTO FIN
END IF

// PCO 31/03/2021 : idem pour message absence adresse mail
IF f_isEmptyString(is_prep_mailbox) THEN
	gu_message.uf_error("AGENT : adresse mail indéterminée pour " + is_prep_matricule)
	li_rtc = -1
	setNull(ls_err)
	GOTO FIN
END IF

// PCO 31/03/2021 : idem pour vérification de la présence des librairies Exchange sur le PC
IF NOT fileExists(gs_startpath + "\Exchange") THEN
	gu_message.uf_error("Exécution impossible. Veuillez vérifier la présence du dossier " + &
								gs_startpath + "\Exchange sur ce PC")
	li_rtc = -1
	setNull(ls_err)
	GOTO FIN
END IF

IF lds_exchange.SaveAsFormattedText(ls_filename, EncodingUTF8!, ",", '"', "~r~n", true) = 1 THEN
	// lancer procédure PowerShell
	// PCO 07/08/2019 : ajout 4ème paramètre : mot de passe Windows (nécessaire pour les comptes passés en 
	// exchange ONLINE au lieu de ON PREMISE
	ls_cmd = gs_startpath + "\Exchange\CreateAppFromCsv.cmd ~"" + ls_filename + "~" ~"" + &
				is_prep_mailbox + "~" ~"" + gs_startpath + "\Exchange~" ~"" + ls_ExchangePwd + "~""
	wf_message(f_string(ls_cmd))
	f_runwait(ls_cmd)
		
	// PCO 29/08/2019 : read status file : contient 0 (échec) ou 1 (réussi)
	lu_fileservices = CREATE uo_fileservices
	lu_fileservices.uf_readfile(gs_tmpfiles + "\planningStatus.txt", ls_status)
	DESTROY lu_fileservices
	IF ls_status <> "1" THEN
		li_rtc = -1
		ls_err = "Erreur d'exécution de la procédure de mise à jour du planning Outlook - aucune modification effectuée"
		GOTO FIN
	END IF
		
	// relire le CSV qui contient maintenant l'ID des RDV créés (début à row n°2 pour skipper headers)
	li_importStatus = lds_exchange.importfile(CSV!, ls_filename, 2)
	IF li_importStatus < 0 THEN
		populateerror(20000,"")
		li_rtc = -1
		ls_err = "Erreur import lds_exchange : " + f_string(li_importStatus)
		GOTO FIN
	END IF
		
	// supprimer les rows dont NUM est null car elles indiquent que l'activité a été supprimée
	// dans "Carnet" et - si tout s'est bien passé - l'item Outlook vient d'être supprimé s'il existait.
	ids_planning_id.setfilter("isNull(num) and tech='EWS'")
	ids_planning_id.filter()
	ll_rowCount = ids_planning_id.rowcount()
	FOR ll_row = 1 TO ll_rowCount
		ids_planning_id.deleterow(1)
	NEXT
	ids_planning_id.setfilter("tech='EWS'")
	ids_planning_id.filter()
		
	// écrire l'ID dans PLANNING_ID
	FOR ll_row = 1 TO lds_exchange.rowCount()
		ls_matricule = lds_exchange.object.matricule[ll_row]
		li_annee = lds_exchange.object.annee[ll_row]
		li_semaine = lds_exchange.object.semaine[ll_row]
		li_num = lds_exchange.object.num[ll_row]
		ls_id = lds_exchange.object.id[ll_row]
		IF isNull(li_num) THEN 
			CONTINUE
		END IF
		IF NOT f_isEmptyString(ls_id) THEN
			ll_row_id = ids_planning_id.find("tech='EWS' and num=" + string(li_num), 1, ids_planning_id.rowCount())
			IF ll_row_id = 0 THEN
				ll_row_id = ids_planning_id.insertRow(0)
				ids_planning_id.object.matricule[ll_row_id] = ls_matricule
				ids_planning_id.object.annee[ll_row_id] = li_annee
				ids_planning_id.object.semaine[ll_row_id] = li_semaine
				ids_planning_id.object.num[ll_row_id] = li_num
				ids_planning_id.object.tech[ll_row_id] = is_outlook
			END IF
			ids_planning_id.object.id[ll_row_id] = ls_id
		END IF
	NEXT
	ids_planning_id.setfilter("")
	ids_planning_id.filter()
	IF ids_planning_id.update() = -1 THEN
		populateerror(20000,"")
		ls_err = "Erreur update PLANNING_ID"
		li_rtc = -1
		GOTO FIN
	END IF
ELSE
	populateerror(20000,"")
	ls_err = "Erreur création fichier d'échange pour Outlook"
	li_rtc = -1
	GOTO FIN
END IF

FIN:
IF li_rtc = 1 THEN
	commit using SQLCA;
ELSE
	rollback using SQLCA;
	IF NOT f_isEmptyString(ls_err) THEN
		gu_message.uf_unexp(ls_err)
	END IF
END IF

DESTROY lds_exchange
FileClose(li_fileRead)
FileClose(li_fileWrite)

return(li_rtc)
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
dw_2.SetItem(al_row,'niveau2',dw_2.object.niveau2[al_row])
dw_2.setItemStatus(al_row, 'niveau2', Primary!, l_status)
end subroutine

public function integer wf_exportxml ();// Exporter les prestations planifiées dans un fichier XML qui pourra être consulté dans la version light.
string	ls_text1, ls_text2, ls_initfolder, ls_folder, ls_filename, ls_basename, ls_suffix

ls_text1 = f_translate_getlabel("TEXT_00785", "Aucune donnée à exporter")
ls_text2 = f_translate_getlabel("TEXT_00770", "Aucun preposé sélectionné !")

IF f_isEmptyString(is_prep_matricule) THEN
	gu_message.uf_info(ls_text2)
	return(-1)
END IF

// enregistrer dernières modif
IF this.event ue_enregistrer() = -1 THEN
	return(-1)
END IF

IF dw_2.rowcount() = 0 THEN
	gu_message.uf_info(ls_text1)
	return(0)
END IF

// PCO 16FEV2016 : récupérer le dernier dossier utilisé. Par défaut = gs_myDocuments.
ls_folder = profileString(gs_locinifile, gs_username, "CT_exportPlanFolder", gs_myDocuments)

// demander le nom du fichier et y sauver les données 
ls_initfolder = ls_folder
ls_filename = "Planifie_"
CHOOSE CASE dw_2.uf_saveas(ls_initfolder, {xml!}, ls_folder, ls_filename)
	CASE -1
		gu_message.uf_error("Erreur lors de la création du fichier")
		return(-1)
	CASE 0
		gu_message.uf_info("Création du fichier abandonnée")
		return(0)
	CASE 1
		gu_message.uf_info("Le fichier " + ls_folder + "\" + ls_filename + " a bien été créé.")
		// PCO 16FEV2016 : stocker le dernier dossier utilisé
		setprofileString(gs_locinifile, gs_username, "CT_exportPlanFolder", ls_folder)
		return(1)
END CHOOSE

end function

public function integer wf_importxml ();// importer fichier XML
integer	li_rt, li_niveau1, li_niveau2, li_idprest
long		ll_row
string	ls_foldername, ls_pathname, ls_filename, ls_text1, ls_text2, ls_text3, ls_text4, &
			ls_basename, ls_suffix
uo_fileservices	lu_fileservices

ls_text1 = f_translate_getlabel("TEXT_00735", "Sélection du fichier d'activités planifiées")
ls_text2 = f_translate_getlabel("TEXT_00736", "Fichier de données XML,*.xml")
ls_text3 = f_translate_getlabel("TEXT_00737", "Aucun fichier sélectionné")
ls_text4 = f_translate_getlabel("TEXT_00770", "Aucun preposé sélectionné !")

IF f_isEmptyString(is_prep_matricule) THEN
	gu_message.uf_info(ls_text4)
	return(-1)
END IF

// PCO 16FEV2016 : récupérer le dernier dossier utilisé. Par défaut = gs_myDocuments.
ls_foldername = profileString(gs_locinifile, gs_username, "CT_importPlanFolder", gs_myDocuments)

// choix du fichier XML à importer
// PCO OCT 2016 : flags 26 = composition 2, 4 et 5 (voir PB help)
IF GetFileOpenName(ls_text1, ls_pathname, ls_filename, &
	"XML", ls_text2, ls_foldername, 26) < 1 THEN
		gu_message.uf_info(ls_text3)
		return(-1)
END IF	

// PCO 16FEV2016 : stocker le dernier dossier utilisé
lu_fileservices = CREATE uo_fileservices
lu_fileservices.uf_basename(ls_pathname, false, ls_foldername, ls_basename, ls_suffix)
DESTROY uo_fileservices
setprofileString(gs_locinifile, gs_username, "CT_importPlanFolder", ls_foldername)

li_rt = dw_2.importfile(XML!, ls_pathname)
IF li_rt < 0 THEN
	gu_message.uf_error("Erreur " + string(li_rt) + " importation " + ls_pathname)
	return(-1)
END IF

// pour chaque row importée, compléter les données sur base du code prestation
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
	li_idprest = ibr_planning.uf_convert_idprest(dw_2.object.vers[ll_row], dw_2.object.idprest[ll_row])

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
NEXT
dw_2.sort()
// sélectionner la 1ère row et appliquer le filtre des DDDW
dw_2.scrollTorow(1)
wf_filter_niveau2(1, "", "")
wf_filter_prest(1, "", "")
dw_2.setRedraw(TRUE)
return(1)

end function

public function integer wf_meeting ();uo_mailservices	l_mail
uo_wait				l_wait
uo_ds					lds_exchange
integer	li_num, li_annee, li_semaine
long		ll_row, ll_nbrows, ll_null, ll_row_id
string	ls_id, ls_subject, ls_body, ls_location, ls_empty[], ls_matricule
datetime	ldt_start, ldt_end
date		ldt_startDate, ldt_endDate
time		lt_startTime, lt_endTime
boolean	lb_allDay

// l'utilisateur en cours doit être le même que celui dont on veut envoyer les activités dans Exchange
// NB : on pourrait utiliser une invitation Outlook, mais dans ce cas le meeting serait planifié pour l'invité 
//      mais également pour celui qui a lancé la planification, ce qui ne semble pas souhaitable.
IF is_prep_matricule <> gs_username THEN
	gu_message.uf_error("Vous ne pouvez pas synchroniser Outlook pour un autre utilisateur que vous-même...")
	return(-1)
END IF

l_wait = CREATE uo_wait
l_mail = CREATE uo_mailservices
l_mail.uf_setdisplayinfo(FALSE)

lds_exchange = CREATE uo_ds
lds_exchange.dataObject = "ds_exchange"
lds_exchange.setTransObject(SQLCA)

lds_exchange.retrieve(is_prep_matricule, ii_year, ii_week, "OLE")
IF is_outlook = "OLE" THEN
	lds_exchange.setfilter("tech='OLE' OR isNull(tech)")
ELSE
	lds_exchange.setfilter("tech='OLE'")
END IF
lds_exchange.filter()

ll_nbrows = lds_exchange.rowCount()
FOR ll_row = 1 TO ll_nbrows
	l_wait.uf_addinfo("Outlook item " + string(ll_row))
	ls_id = string(lds_exchange.object.id[ll_row])
	ls_subject = f_string(lds_exchange.object.subject[ll_row])
	ls_body = f_string(lds_exchange.object.body[ll_row])
	ls_location = f_string(lds_exchange.object.location[ll_row])
	ldt_start = dateTime(lds_exchange.object.start[ll_row])
	ldt_startDate = date(ldt_start)
	lt_startTime = time(ldt_start)
	ldt_end = dateTime(lds_exchange.object.end[ll_row])
	ldt_endDate = date(ldt_end)
	lt_endTime = time(ldt_end)
	IF upper(f_string(lds_exchange.object.allDayEvent[ll_row])) = "TRUE" THEN
		lb_allDay = TRUE
	ELSE
		lb_allDay = FALSE
	END IF
	ls_id = l_mail.uf_meeting_ole_send(ls_id, ls_subject, ls_body, ls_location, ldt_startDate, lt_startTime, &
			  ldt_endDate, lt_endtime, lb_allDay, gu_c.l_null, ls_empty)

	// écrire l'ID dans PLANNING_ID
	ls_matricule = lds_exchange.object.matricule[ll_row]
	li_annee = lds_exchange.object.annee[ll_row]
	li_semaine = lds_exchange.object.semaine[ll_row]
	li_num = lds_exchange.object.num[ll_row]
	IF isNull(li_num) THEN 
		CONTINUE
	END IF
	IF NOT f_isEmptyString(ls_id) THEN
		ll_row_id = ids_planning_id.find("tech='OLE' and num=" + string(li_num), 1, ids_planning_id.rowCount())
		IF ll_row_id = 0 THEN
			ll_row_id = ids_planning_id.insertRow(0)
			ids_planning_id.object.matricule[ll_row_id] = ls_matricule
			ids_planning_id.object.annee[ll_row_id] = li_annee
			ids_planning_id.object.semaine[ll_row_id] = li_semaine
			ids_planning_id.object.num[ll_row_id] = li_num
			ids_planning_id.object.tech[ll_row_id] = is_outlook
		END IF
		ids_planning_id.object.id[ll_row_id] = ls_id
	END IF
NEXT

// Supprimer de PLANNING_ID les rows dont NUM est null dans table PLANNING_ID
// car cela indiquent que l'activité a été supprimée dans "Carnet".
ids_planning_id.setfilter("isNull(num) and tech='OLE'")
ids_planning_id.filter()
ll_nbrows = ids_planning_id.rowcount()
FOR ll_row = 1 TO ll_nbrows
	l_wait.uf_addinfo("Delete item " + string(ll_row))
	ls_id = ids_planning_id.object.id[1]
	IF NOT f_isEmptyString(ls_id) THEN
		l_mail.uf_meeting_ole_delete(ls_id)
	END IF
	ids_planning_id.deleterow(1)
NEXT
ids_planning_id.setfilter("")
ids_planning_id.filter()

DESTROY l_mail
DESTROY lds_exchange
DESTROY l_wait

// mise à jour PLANNING_ID
IF ids_planning_id.update() = 1 THEN
	commit using SQLCA;
	gu_message.uf_info("Mise à jour du planning Outlook terminée.")
	return(1)
ELSE
	populateerror(20000,"")
	rollback using SQLCA;
	gu_message.uf_unexp("Erreur update PLANNING_ID.~n" + &
			"Le planning Outlook a été mis à jour mais les modifications ultérieures dans le CT " + &
			"ne seront peut-être pas répliquées correctement.")
	return(1)
END IF

end function

public function integer wf_getcleanpwd (ref string as_pwd);string	ls_ExchangePwd

// PCO 07/08/2019 : demander le mot de passe Windows
IF f_getPassword("Mot de passe Windows", "NB : le mot de passe Windows vous est demandé afin de pouvoir accéder à l'agenda Outlook.", gs_ExchangePwd) = -1 THEN
	gu_message.uf_error("Le mot de passe Windows est nécessaire pour accéder à l'agenda Outlook")
	return(-1)
END IF

IF f_isEmptyString(gs_ExchangePwd) THEN
	gu_message.uf_error("Veuillez introduire le mot de passe Windows")
	return(-1)
END IF

// escape special characters in passwd
ls_ExchangePwd = gs_ExchangePwd
ls_ExchangePwd = gu_stringservices.uf_replaceall(ls_ExchangePwd, "'", "`'")
ls_ExchangePwd = gu_stringservices.uf_replaceall(ls_ExchangePwd, "&", "`&")
ls_ExchangePwd = gu_stringservices.uf_replaceall(ls_ExchangePwd, "(", "`(")
ls_ExchangePwd = gu_stringservices.uf_replaceall(ls_ExchangePwd, ")", "`)")
ls_ExchangePwd = gu_stringservices.uf_replaceall(ls_ExchangePwd, "{", "`{")
ls_ExchangePwd = gu_stringservices.uf_replaceall(ls_ExchangePwd, "}", "`}")
ls_ExchangePwd = gu_stringservices.uf_replaceall(ls_ExchangePwd, ",", "`,")
ls_ExchangePwd = gu_stringservices.uf_replaceall(ls_ExchangePwd, ";", "`;")

as_pwd = ls_ExchangePwd
end function

event ue_open;call super::ue_open;// Droits de modifier ou pas les données attribué par agent dont les données sont accessibles
// et non plus globalement au niveau du programme !
ids_planning_id = CREATE uo_ds
ids_planning_id.dataObject = "ds_planning_id"
ids_planning_id.setTransObject(SQLCA)

// BR encodage
ibr_planning = CREATE br_saisie

wf_SetDWList({dw_2})

// icône devant être visible dans le menu
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

// PCO 30/03/2021 voir explication variable is_outlook dans la déclaration de la variable
select tech into :is_outlook from params using ESQLCA;
IF isNull(is_outlook) THEN is_outlook = "OLE"
end event

on w_planning.create
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
this.cb_outlook=create cb_outlook
this.cb_import=create cb_import
this.cb_export=create cb_export
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
this.Control[iCurrent+9]=this.cb_outlook
this.Control[iCurrent+10]=this.cb_import
this.Control[iCurrent+11]=this.cb_export
this.Control[iCurrent+12]=this.cb_check
end on

on w_planning.destroy
call super::destroy
destroy(this.dw_2)
destroy(this.p_1)
destroy(this.uo_semaine)
destroy(this.st_prep)
destroy(this.p_cadenas)
destroy(this.gb_1)
destroy(this.dw_prepose)
destroy(this.cb_valid)
destroy(this.cb_outlook)
destroy(this.cb_import)
destroy(this.cb_export)
destroy(this.cb_check)
end on

event resize;call super::resize;gb_1.width=newwidth - 32
dw_2.width=newwidth - 32
dw_2.height=newheight - gb_1.height - 120

end event

event ue_init_menu;call super::ue_init_menu;IF wf_IsActif() AND NOT ib_planning_valid AND wf_canUpdate() THEN
	f_menuaction({"m_enregistrer", "m_supprimer", "m_ajouter", "m_inserer", "m_abandonner", "m_fermer", "m_dupliquer"})
ELSE
	f_menuaction({"m_abandonner", "m_fermer"})
END IF



end event

event ue_supprimer;call super::ue_supprimer;IF ib_planning_valid THEN return

// suppression de l'activité
dw_2.event ue_delete()

dw_2.setFocus()

end event

event ue_inserer;call super::ue_inserer;IF ib_planning_valid THEN return
dw_2.event ue_insertrow()
dw_2.setFocus()
end event

event ue_enregistrer;call super::ue_enregistrer;integer	li_status
long		ll_row, ll_row_id, ll_num, ll_maxnum

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

// attribuer un n° de séquence aux nouvelles rows
// NB : on refait un SELECT pour prendre en compte les rows éventuellement ajoutées depuis
//      la lecture du DW (par un autre utilisateur ou par la programmation par équipe)
select max(num) into :ll_maxnum from planning 
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

// Pour les activités supprimées, annuler le n° d'activité dans PLANNING_ID 
// si l'activité y contient l'ID d'un RDV outlook.
FOR ll_row = 1 TO dw_2.deletedCount()
	ll_num = long(dw_2.object.num.delete[ll_row])
	ll_row_id = ids_planning_id.find("num=" + string(ll_num), 1, ids_planning_id.rowCount())
	IF ll_row_id > 0 THEN
		ids_planning_id.object.num[ll_row_id] = gu_c.l_null
	END IF
NEXT

li_status = gu_dwservices.uf_updatetransact(dw_2)
CHOOSE CASE li_status
	CASE 1
		wf_message(f_translate_getlabel("TEXT_00738", "Planning enregistré avec succès"))
		IF ids_planning_id.update() = 1 THEN
			commit using SQLCA;
		ELSE
			rollback using SQLCA;
			gu_message.uf_error("Erreur update PLANNING_ID")
		END IF
		
		// rafraichissement
		wf_lecture()
		return(1)
	CASE -1
		populateerror(20000,"")
		gu_message.uf_unexp("PLANNING : Erreur lors de la mise à jour de la base de données")
		return(-1)
END CHOOSE

end event

event ue_ajouter;call super::ue_ajouter;IF ib_planning_valid THEN return
dw_2.event ue_addrow()
dw_2.setFocus()
end event

event ue_init_win;call super::ue_init_win;p_cadenas.visible = FALSE
cb_valid.enabled = FALSE
cb_outlook.enabled = FALSE
cb_import.enabled = FALSE
cb_export.enabled = FALSE
cb_check.enabled = FALSE

// réinitilise le préposé
setnull(is_prep_matricule)
dw_prepose.uf_reset()
dw_prepose.insertrow(0)
dw_prepose.uf_enableitems({"prep_matricule"})

// ré-initialiser les droits update/delete qu'on a peut-être forcés dans wf_lecture()
// 07/2015 : droits d'accès attribués directement après sélection de l'agent
//wf_resetprivs()

// réinitialise le planning
dw_2.uf_reset()
ids_planning_id.reset()

IF IsValid(w_realise) THEN
	w_realise.wf_setexternalNOTinitialised()
END IF
end event

event ue_close;call super::ue_close;DESTROY ids_planning_id
DESTROY ibr_planning
end event

type ddlb_message from w_ancestor_dataentry`ddlb_message within w_planning
integer y = 1936
end type

type dw_2 from uo_datawindow_multiplerow within w_planning
integer x = 18
integer y = 224
integer width = 3968
integer height = 1488
integer taborder = 20
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
				
	// Quand indiquées, heure de fin doit être > heure de début.
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

	// nombre d'unités : obligatoire pour intérim, facultatif sinon
	CASE "nbre"
		li_idprest = integer(this.object.idprest[al_row])
		return(ibr_planning.uf_check_nbre(as_data, as_message, li_idprest))

	// commentaire obligatoire si intérim
	CASE "lieu"
		return(ibr_planning.uf_check_lieu(this.object.v_dicoprest_interim[al_row], as_data, as_message))
		
	CASE "accomp"
		return(ibr_planning.uf_check_accomp(as_data, as_message))

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

event buttonclicked;call super::buttonclicked;// Transférer la prestation vers le réalisé
integer	li_status, li_idprest, li_niveau1, li_niveau2, li_num
long		ll_row
dwItemStatus	l_status

string	ls_irreg, ls_lieu
datetime	ldt_datep
decimal{2}	ld_nbre

IF row = 0 THEN return

// 1. vérifier si la ligne contient les infos à recopier
ldt_datep = datetime(dw_2.object.datep[row])
li_niveau1 = integer(dw_2.object.niveau1[row])
li_niveau2 = integer(dw_2.object.niveau2[row])
li_idprest = integer(dw_2.object.idprest[row])
ls_irreg = dw_2.object.irreg[row]
ld_nbre = dw_2.object.nbre[row]
ls_lieu = dw_2.object.lieu[row]
IF isNull(ldt_datep) OR isNull(li_niveau1) OR isNull(li_niveau2) OR isNull(li_idprest) OR isNull(ls_irreg) THEN
		gu_message.uf_error("Prestation incomplète : copie impossible")
		return(-1)
END IF

// 2. initialiser w_realise si pas encore fait
IF NOT IsValid(w_realise) THEN
	OpenSheet(w_realise, gw_mdiframe, 0, Original!)
END IF
IF IsValid(w_realise) THEN
	w_realise.SetFocus()
	IF NOT w_realise.wf_isexternalinitialised() THEN
		li_status = w_realise.event ue_abandonner()
		IF li_status = 3 OR li_status < 0 THEN
			return
		ELSE
			// initialiser n° de semaine et sélectionner préposé
			w_realise.post wf_initexternal(is_prep_matricule, idt_from)
		END IF
	END IF
END IF

// 3. recopier ligne de prestation planifiée dans le réalisé
w_realise.post wf_external_row(ldt_datep, li_niveau1, li_niveau2, li_idprest, ls_irreg, &
		gu_c.datetime_null, gu_c.datetime_null, gu_c.datetime_null, ld_nbre, ls_lieu)
		
// PCO 25/11/2016 : utiliser nouvelle colonne TRFREALISE pour indiquer que la prestation planifiée 
// a été transférée vers le REALISE avec le bouton R.
// NB : le flag reste tel quel même si le réalisé n'est finalement pas enregistré.
// Si la prestation existe déjà en DB, flaguer par un update.
// Sinon, juste modifier dans le datawindow, ce sera mis à jour lors de l'update
dw_2.object.trfrealise[row] = "O"

l_status = dw_2.GetItemStatus(row, 0, Primary!)
IF l_status = notModified! OR l_status = dataModified! THEN
	li_num = integer(dw_2.object.num[row])
	update planning set trfrealise='O' 
		where matricule=:is_prep_matricule and annee=:ii_year and semaine=:ii_week and num=:li_num
		using ESQLCA;
	IF f_check_sql(ESQLCA) = 0 THEN
		commit using ESQLCA;
		dw_2.SetItemStatus(row, "trfrealise", Primary!, NotModified!)
	ELSE
		rollback using ESQLCA;
	END IF
END IF


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

type p_1 from picture within w_planning
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

type uo_semaine from uvo_navweek within w_planning
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
	IF IsValid(w_realise) THEN
		w_realise.wf_setexternalNOTinitialised()
	END IF
	return(1)
END IF
end event

type st_prep from uo_statictext within w_planning
string tag = "TEXT_00535"
integer x = 2030
integer y = 80
integer width = 658
integer height = 80
boolean bringtotop = true
string text = "Planning pour le préposé"
end type

type p_cadenas from uo_picture within w_planning
integer x = 1847
integer y = 56
integer width = 146
integer height = 128
boolean bringtotop = true
boolean originalsize = false
string picturename = "..\bmp\cadenas_ferme.png"
boolean map3dcolors = true
string powertiptext = "Ce planning est validé et ne peut plus être modifé"
end type

type gb_1 from uo_groupbox within w_planning
integer x = 18
integer width = 4626
integer height = 208
end type

type dw_prepose from uo_datawindow_singlerow within w_planning
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

// mémoriser codeservice et adresse mail de l'agent pour usage ultérieur dans le programme
select codeservice, email into :is_prep_codeservice, :is_prep_mailbox
	from agent where matricule=:is_prep_matricule using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	gu_message.uf_error("AGENT : impossible de déterminer le codeservice et l'adresse mail pour " + is_prep_matricule)
	setNull(is_prep_codeservice)
	setNull(is_prep_mailbox)
END IF

// récupérer la valeur de MODIF_PLANNING qui permet de savoir si la modification des datas est autorisée
this.GetChild("prep_matricule", ldwc_dropdown)
li_row = ldwc_dropdown.GetRow()
IF ldwc_dropdown.GetItemString(li_row, "modif_planning") = "O" THEN
	wf_canUpdate(TRUE)
	wf_canDelete(TRUE)
ELSE
	wf_canUpdate(FALSE)
	wf_canDelete(FALSE)
END IF

wf_lecture()
end event

type cb_valid from commandbutton within w_planning
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
	gu_message.uf_info("Désolé, vous ne disposez pas des droits requis pour valider le planning...")
	return
END IF

// enregistrer les modif. éventuelles
IF event ue_enregistrer() < 0 THEN
	return
END IF

// On ne peut valider que s'il y a au moins 50% de la durée hebdomadaire de travail planifiée.
// PCO : contrainte supprimée suite GT technique CB C1 février 2015
//li_pc = integer(dw_2.object.c_pc_planifie[1])
//IF li_pc < gi_pc_planning THEN
//	gu_message.uf_error("Vous devez planifier au moins " + string(gi_pc_planning) + " % du temps de travail pour pouvoir valider la semaine")
//	return
//END IF
//
// confirmation
IF gu_message.uf_query("Vous êtes sur le point de valider ce planning. Il ne pourra plus être modifié par la suite.~n~n" + &
		"Confirmez-vous votre choix ?", YesNo!, 2) = 2 THEN
	return
END IF

lbr_semaine = CREATE br_semaine

IF lbr_semaine.uf_valid_planning(is_prep_matricule, ii_year, ii_week) = 1 THEN
	// refresh
	wf_lecture()
	gu_message.uf_info("Planning validé !")
ELSE
	post close(parent)
END IF

DESTROY lbr_semaine
end event

type cb_outlook from commandbutton within w_planning
string tag = "TEXT_00537"
integer x = 3968
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
string text = "-> Outlook"
end type

event clicked;// enregistrer les modif. éventuelles
IF event ue_enregistrer() < 0 THEN
	return(-1)
ELSE
	// PCO 30/03/2021 : utilisation OLE au lieu de EWS pour mise à jour planning Outlook. 
	// Paramétrage de la technique dans PARAMS.
	// On passe par les 2 fonctions car temporairement il faut pouvoir traiter les planifications
	// créées par l'une ou l'autre des techniques (pour les m-à-j et suppressions)
	wf_sendToExchange()
	wf_meeting()
//	END IF
END IF
end event

type cb_import from commandbutton within w_planning
string tag = "TEXT_00783"
integer x = 3968
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
string text = "Importer..."
end type

event clicked;wf_importXML()

end event

type cb_export from commandbutton within w_planning
string tag = "TEXT_00784"
integer x = 4297
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
string text = "Exporter..."
end type

event clicked;wf_exportxml()
end event

type cb_check from commandbutton within w_planning
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
string text = "Véri&fier"
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

IF isValid(w_rpt_planning_anomalies) THEN
	close(w_rpt_planning_anomalies)
END IF
openSheetWithParm(w_rpt_planning_anomalies, lstr_params, gw_mdiframe, 0, Original!)
end event

