//objectcomments BOLD : gestion userDossier - ancêtre commun à toutes les applications
forward
global type w_userdossier_common from w_ancestor
end type
type cb_open from uo_cb within w_userdossier_common
end type
type cb_choix_demarche from uo_cb within w_userdossier_common
end type
type cb_getuserdossier from uo_cb within w_userdossier_common
end type
type cb_cancelrfai from uo_cb within w_userdossier_common
end type
type st_nbdisplayed from uo_statictext within w_userdossier_common
end type
type cb_listdrc from uo_cb within w_userdossier_common
end type
type st_2 from uo_statictext within w_userdossier_common
end type
type rb_mask_non from uo_radiobutton within w_userdossier_common
end type
type rb_mask_oui from uo_radiobutton within w_userdossier_common
end type
type cb_refresh from uo_cb within w_userdossier_common
end type
type dw_filter from uo_ancestor_dw within w_userdossier_common
end type
type st_1 from uo_statictext within w_userdossier_common
end type
type cb_listattach from uo_cb within w_userdossier_common
end type
type cb_show from uo_cb within w_userdossier_common
end type
type cb_export from uo_cb within w_userdossier_common
end type
type cb_import from uo_cb within w_userdossier_common
end type
type cb_attach from uo_cb within w_userdossier_common
end type
type cb_rfai from uo_cb within w_userdossier_common
end type
type cb_end from uo_cb within w_userdossier_common
end type
type cb_process from uo_cb within w_userdossier_common
end type
type sle_dest from uo_sle within w_userdossier_common
end type
type dw_select from uo_ancestor_dwbrowse within w_userdossier_common
end type
type str_access from structure within w_userdossier_common
end type
end forward

type str_access from structure
	string		s_mat
	long		l_pref[]
end type

global type w_userdossier_common from w_ancestor
integer width = 6446
integer height = 2924
string title = "Suivi formulaires électroniques (BOLD)"
cb_open cb_open
cb_choix_demarche cb_choix_demarche
cb_getuserdossier cb_getuserdossier
cb_cancelrfai cb_cancelrfai
st_nbdisplayed st_nbdisplayed
cb_listdrc cb_listdrc
st_2 st_2
rb_mask_non rb_mask_non
rb_mask_oui rb_mask_oui
cb_refresh cb_refresh
dw_filter dw_filter
st_1 st_1
cb_listattach cb_listattach
cb_show cb_show
cb_export cb_export
cb_import cb_import
cb_attach cb_attach
cb_rfai cb_rfai
cb_end cb_end
cb_process cb_process
sle_dest sle_dest
dw_select dw_select
end type
global w_userdossier_common w_userdossier_common

type variables
long		il_pRef[]
string	is_demarche_visible[], is_nom_demarche_visible[]
private	str_access	istr_access[]
boolean	ib_retrieving
end variables

forward prototypes
public subroutine wf_initdddw ()
public function integer wf_accessrights_read ()
public subroutine wf_retrieve ()
public function long wf_filter (string as_ndossier)
public function integer wf_publishattach (string as_ndossier, string as_typekey, string as_typelabel, string as_description, string as_filename)
public subroutine wf_listattachment (string as_ndossier)
public function integer wf_publishstatus (string as_ndossier, string as_status)
public function integer wf_showpdf (string as_ndossier)
public function integer wf_export (string as_ndossier)
public subroutine wf_listdrc (string as_ndossier)
public subroutine wf_setmaskbuttons (boolean ab_oui, boolean ab_non)
public function boolean wf_getstatus (string as_ndossier, ref string as_currentstatus)
public subroutine wf_accessrights_modify (long al_row)
public function integer wf_importxml (string as_ndossier, string as_userdossierid, long al_procedureref, string as_procedurename)
public function integer wf_publishcancelrfai (string as_ndossier, string as_justif)
public function integer wf_publishrfai (string as_ndossier, string as_subject, string as_description, date adt_expirydate, str_params astr_target[])
public function integer wf_selectprocedureref (string as_ndossier)
public function integer wf_publishgetuserdossier (string as_ndossier, integer ai_version)
public subroutine wf_cb_open ()
public function integer wf_open (string as_ndossier, long al_procedureref, string as_procedurename)
public subroutine wf_resetfilter_exceptpref ()
end prototypes

public subroutine wf_initdddw ();// initialiser le contenu des listes de filtres
long		ll_row, ll_new, ll_data
integer	li_item
string	ls_data
datawindowchild	ldwc_pRef, ldwc_status, ldwc_service, ldwc_auteur

IF dw_filter.GetChild("n_pref", ldwc_pRef) < 0 THEN
	gu_message.uf_info("ERREUR dw_filter.GetChild() procedure")
END IF

IF dw_filter.GetChild("s_status", ldwc_status) < 0 THEN
	gu_message.uf_info("ERREUR dw_filter.GetChild() status")
END IF

IF dw_filter.GetChild("s_service", ldwc_service) < 0 THEN
	gu_message.uf_info("ERREUR dw_filter.GetChild() service")
END IF

IF dw_filter.GetChild("s_auteur", ldwc_auteur) < 0 THEN
	gu_message.uf_info("ERREUR dw_filter.GetChild() auteur")
END IF

ldwc_status.reset()
ldwc_pRef.reset()
ldwc_service.reset()
ldwc_auteur.reset()

// garnir la DDLB pour le tri par status, par type de dossier et par service, et par auteur
dw_select.setFilter("")
dw_select.filter()
FOR ll_row = 1 TO dw_select.rowCount()
	// status
	ls_data = dw_select.object.currentStatus[ll_row]
	IF ldwc_status.Find("s_status = '" + ls_data + "'", 1, ldwc_status.rowCount()) = 0 THEN
		ll_new = ldwc_status.insertrow(0)
		ldwc_status.setItem(ll_new, "s_status", ls_data)
	END IF
	
	// type de dossier
	ll_data = dw_select.object.procedureRef[ll_row]
	IF ldwc_pRef.Find("n_procedureref = " + string(ll_data), 1, ldwc_pRef.rowCount()) = 0 THEN
		ll_new = ldwc_pRef.insertrow(0)
		ldwc_pRef.setItem(ll_new, "n_procedureref", ll_data)
		ldwc_pRef.setItem(ll_new, "s_procedurename", dw_select.object.procedureName[ll_row])
	END IF
	
	// service
	ls_data = upper(dw_select.object.service[ll_row])
	IF ldwc_service.Find("s_service = '" + ls_data + "'", 1, ldwc_service.rowCount()) = 0 THEN
		ll_new = ldwc_service.insertrow(0)
		ldwc_service.setItem(ll_new, "s_service", ls_data)
	END IF
	
	// auteur
	ls_data = upper(dw_select.object.budata_lastopaut[ll_row])
	IF ldwc_auteur.Find("s_auteur = '" + ls_data + "'", 1, ldwc_auteur.rowCount()) = 0 THEN
		ll_new = ldwc_auteur.insertrow(0)
		ldwc_auteur.setItem(ll_new, "s_auteur", ls_data)
	END IF
NEXT

ll_new = ldwc_status.insertrow(0)
ldwc_status.setItem(ll_new, "s_status", " Tous")
ldwc_status.sort()
ldwc_status.selectRow(0, FALSE)

ll_new = ldwc_pRef.insertrow(0)
ldwc_pRef.setItem(ll_new, "n_procedureref", 0)
ldwc_pRef.setItem(ll_new, "s_procedurename", " Tous")
ldwc_pRef.sort()
ldwc_pRef.selectRow(0, FALSE)

ll_new = ldwc_service.insertrow(0)
ldwc_service.setItem(ll_new, "s_service", " Tous")
ldwc_service.sort()
ldwc_service.selectRow(0, FALSE)

ll_new = ldwc_auteur.insertrow(0)
ldwc_auteur.setItem(ll_new, "s_auteur", " Tous")
ldwc_auteur.sort()
ldwc_auteur.selectRow(0, FALSE)
end subroutine

public function integer wf_accessrights_read ();// Déterminer les types de démarches visibles par l'utilisateur sur base des paramètres
// du .INI global et des droits d'accès de l'utilisateur dans l'application.
// Attention : le droit doit être spécifié explicitement (dans un groupe ou individuellement). Le droit
// d'accès implicite (lecture) octroyé par défaut aux programmes ne suffit pas.
// Pour un accès en lecture par tout le monde, il faut ajouter le nom du programme dans le groupe PUBLIC avec droit en consultation.
string	ls_data, ls_mat[], ls_nom[], ls_demconfig[], ls_dem[], ls_pRef[], ls_choixListe, &
			ls_choix[], ls_vide[]
long		ll_vide[]
str_access	lstr_vide[]
integer	li_m, li_i, li_j, li_index
boolean	lb_choisi

// lire la liste des démarches gérées par BOLD
// la config dans le .ini est structurée comme suit : nom_programme~nom_démarche;nom_programme~nom_démarche;...
ls_data = profileString(gs_inifile, "BOLD", "list", "")
IF f_isEmptyString(ls_data) THEN
	gu_message.uf_error("BOLD : les démarches gérées doivent être paramétrées dans le fichier .INI global")
	return(-1)
END IF
f_parse(ls_data, ";", ls_demconfig)

// décomposer chaque config en nom programme et nom de la démarche
FOR li_i = 1 TO upperBound(ls_demconfig)
	f_parse(ls_demconfig[li_i], "~~", ls_dem)
	ls_mat[li_i] = ls_dem[1]
	ls_nom[li_i] = ls_dem[2]
NEXT

// lecture des choix de l'utilisateur dans le .ini local
ls_choixListe = profileString(gs_locinifile, gs_username, "BOLD_DEMARCHES_CHOISIES", "")
f_parse(ls_choixListe, ",", ls_choix)

// pour chaque démarches gérée par BOLD, liste la liste des identifiants des types de dossiers dans le NEP
is_demarche_visible = ls_vide
il_pref = ll_vide
istr_access = lstr_vide
FOR li_m = 1 TO upperBound(ls_mat)
	istr_access[li_m].s_mat = ls_mat[li_m]
	// Si l'utilisateur peut consulter le dossier dans DBCentrale, il peut aussi lire les dossiers dans BOLD.
	IF gu_privs.uf_canconsult(ls_mat[li_m]) = 1 THEN
		is_demarche_visible[upperbound(is_demarche_visible) + 1] = ls_mat[li_m]
		is_nom_demarche_visible[upperbound(is_nom_demarche_visible) + 1] = ls_nom[li_m]
		
		// PCO 06/11/2023 : tenir compte du choix de l'utilisateur des démarches à afficher.
		IF upperbound(ls_choix) > 0 THEN
			lb_choisi = FALSE
			FOR li_j = 1 TO upperbound(ls_choix)
				IF ls_mat[li_m] = ls_choix[li_j] THEN
					lb_choisi = TRUE
					EXIT
				END IF
			NEXT
			IF NOT lb_choisi THEN CONTINUE // passe à la démarche suivante
		END IF
		
		ls_data = profileString(gs_inifile, "BOLD", ls_mat[li_m], "")
		f_parse(ls_data, ',', ls_pRef)
		FOR li_i = 1 TO upperBound(ls_pRef)
			li_index++
			// array contenant l'ID des types de dossiers visibles par l'utilisateur. Utilisé dans le retrieve.
			il_pRef[li_index] = long(ls_pRef[li_i])
			// array contenant l'ID dans la structure qui permet de retrouver la matière sur base de cet ID
			istr_access[li_m].l_pRef[li_i] = long(ls_pRef[li_i])
		NEXT
	END IF
NEXT

// accès à aucune démarche
IF li_index = 0 THEN
	gu_message.uf_info("Désolé, aucun type de démarche ne vous est accessible.")
	return(-1)
END IF


end function

public subroutine wf_retrieve ();long		ll_row
string	ls_ndossier

ib_retrieving = TRUE
ll_row = dw_select.getRow()
IF ll_row > 0 THEN
	ls_ndossier = dw_select.object.userdossiernumber[ll_row]
END IF

// lecture des dossiers dont les types sont dans l'array il_pRef
dw_select.setRedraw(FALSE)
IF dw_select.retrieve(il_pRef) > 0 THEN
	wf_accessrights_modify(1)
END IF

// initialiser les listes permettant de filtrer
wf_initdddw()

// appliquer les filtres en cours
wf_filter(ls_ndossier)

dw_select.setRedraw(TRUE)

ib_retrieving = FALSE

end subroutine

public function long wf_filter (string as_ndossier);// filtrer les dossiers affichés
// as_ndossier : n° de dossier en cours au moment de l'appel de la fonction. Permet de se repositionner dessus.
// return : nombre de rows affichées
string	ls_filter, ls_pRef, ls_status, ls_service, ls_auteur, ls_eval
long		ll_found

IF dw_filter.rowCount() <= 0 THEN
	return(0)
END IF

ls_pRef = f_string(dw_filter.object.n_pRef[1])
IF NOT f_isEmptyString(ls_pRef) AND ls_pRef <> "0" THEN
	ls_filter = "procedureRef = " + ls_pRef
END IF

ls_status = f_string(trim(upper(dw_filter.object.s_status[1])))
IF NOT f_isEmptyString(ls_status) AND ls_status <> "TOUS" THEN
	IF NOT f_isEmptyString(ls_filter) THEN
		ls_filter = ls_filter + " and "
	END IF
	ls_filter = ls_filter + "currentStatus = '" + ls_status + "'"
END IF

ls_service = f_string(trim(upper(dw_filter.object.s_service[1])))
IF NOT f_isEmptyString(ls_service) AND ls_service <> "TOUS" THEN
	IF NOT f_isEmptyString(ls_filter) THEN
		ls_filter = ls_filter + " and "
	END IF
	ls_filter = ls_filter + "upper(service) = '" + ls_service + "'"
END IF

ls_auteur = f_string(trim(upper(dw_filter.object.s_auteur[1])))
IF NOT f_isEmptyString(ls_auteur) AND ls_auteur <> "TOUS" THEN
	IF NOT f_isEmptyString(ls_filter) THEN
		ls_filter = ls_filter + " and "
	END IF
	ls_filter = ls_filter + "upper(budata_lastopaut) = '" + ls_auteur + "'"
END IF

IF rb_mask_oui.checked THEN
	IF NOT f_isEmptyString(ls_filter) THEN
		ls_filter = ls_filter + " and "
	END IF
	ls_filter = ls_filter + "currentStatus <> 'ENDED'"
END IF

dw_select.setRedraw(FALSE)
dw_select.setFilter(ls_filter)
dw_select.Filter()

// se repositionner sur le dossier qui était sélectionné
IF NOT f_isEmptyString(as_ndossier) THEN
	ll_found = dw_select.find("userdossiernumber='" + as_ndossier + "'", 1, dw_select.rowCount())
END IF

dw_select.selectRow(0, FALSE)
IF ll_found > 0 THEN
	dw_select.scrollToRow(ll_found)
	dw_select.selectRow(ll_found, TRUE)
ELSE
	dw_select.scrollToRow(1)
	dw_select.selectRow(1, TRUE)	
END IF
dw_select.setRedraw(TRUE)
wf_accessrights_modify(dw_select.getRow())

// PCO 08/02/2024 : si le dossier a déjà été importé, permettre d'ouvrir le programme
// correspondant et de l'afficher. Pour cela, activer le bouton cb_open.
wf_cb_open()

// PCO 25/11/2022 : afficher le nombre de dossiers correspondant à la sélection
ls_eval = dw_select.Describe("Evaluate('count(userdossiernumber for all)',1)")
st_nbdisplayed.text = "Nombre de dossiers affichés : " + ls_eval

return(dw_select.rowCount())

end function

public function integer wf_publishattach (string as_ndossier, string as_typekey, string as_typelabel, string as_description, string as_filename);// Joindre un fichier au dossier.
// return(1) : OK
// return(-1) : Erreur
string	ls_message

IF f_isEmptyString(as_ndossier) THEN
	return(-1)
END IF

IF gu_bold.uf_publishAttach(as_ndossier, as_typeKey, as_typeLabel, as_Description, as_fileName, ls_message) = 1 THEN
	wf_retrieve()
	gu_message.uf_info("Le fichier " + as_fileName + " a été joint au dossier " + as_ndossier)
	return(1)
ELSE
	gu_message.uf_error(ls_message)
	return(-1)
END IF

end function

public subroutine wf_listattachment (string as_ndossier);integer	li_status

IF f_isEmptyString(as_ndossier) THEN
	return
END IF

IF NOT IsValid(w_bold_attachments_list) THEN
	OpenSheet(w_bold_attachments_list, gw_mdiframe, 0, Original!)
END IF
IF IsValid(w_bold_attachments_list) THEN
	w_bold_attachments_list.SetFocus()
	w_bold_attachments_list.post wf_retrieve(as_ndossier)
END IF

end subroutine

public function integer wf_publishstatus (string as_ndossier, string as_status);// Modifier le statut du dossier
// return(1) : OK
// return(-1) : Erreur
string	ls_message
integer	li_st

IF f_isEmptyString(as_ndossier) THEN
	return(-1)
END IF

li_st = gu_bold.uf_publishStatus(as_ndossier, as_status, ls_message)
CHOOSE CASE li_st
	CASE 0 
		gu_message.uf_info(ls_message)
		return(1)
	CASE 1
		wf_retrieve()
		gu_message.uf_info("Le changement de status " + as_status + " a été soumis pour le dossier " + as_ndossier)
		return(1)
	CASE ELSE
		gu_message.uf_error(ls_message)
		return(-1)
END CHOOSE

end function

public function integer wf_showpdf (string as_ndossier);// Visualiser le PDF
// return(1) : OK
// return(-1) : Erreur d'extraction du PDF
uo_fileservices	lu_fs
integer	li_status
blob		lb_pdfContent
string	ls_PDFfileName, ls_pdfErr

IF f_isEmptyString(as_ndossier) THEN
	return(-1)
END IF

lu_fs = CREATE uo_fileservices

// export PDF in work folder
IF gu_bold.uf_getPDFcontent(as_ndossier, ls_pdfErr, lb_pdfContent) = 1 THEN
	ls_PDFfileName = gs_tmpfiles + "\" + as_ndossier + ".pdf"
	filedelete(ls_PDFfileName)
	IF lu_fs.uf_writefile(lb_pdfContent, ls_PDFfileName, replace!) < 0 THEN
		gu_message.uf_error("Erreur d'écriture du fichier " + ls_PDFfileName)
		li_status = -1
	ELSE
		// open PDF
		f_openlink(ls_PDFfileName)
		li_status = 1
	END IF
ELSE
	gu_message.uf_error(ls_pdfErr)
	li_status = -1
END IF

DESTROY lu_fs
// même en postant le fileDelete, le fichier est supprimé avant d'avoir été ouvert :-(
//post filedelete(ls_PDFfileName)
return(li_status)

end function

public function integer wf_export (string as_ndossier);// exporter fichier XML, PDF et documents joints
// return(1) : les fichiers ont été générés sans erreur
// return(-1) : au moins un des fichiers n'a pas été généré
uo_fileservices	lu_fs
integer	li_attachNr, li_row
long		ll_count
blob		lb_pdfContent, lb_attachContent[]
string	ls_xmlContent, ls_PDFfileName, ls_XMLfileName, ls_folderName, ls_fullFileName, ls_message, &
			ls_pdfErr, ls_xmlErr, ls_attachErr, ls_XMLCreated, ls_PDFCreated, ls_attachCreated, ls_attachFileName[]

IF f_isEmptyString(as_ndossier) THEN
	return(-1)
END IF

IF f_isEmptyString(sle_dest.text) THEN
	sle_dest.setFocus()
	gu_message.uf_info("Veuillez spécifier le dossier de destination.~n~nUn sous-dossier " + as_ndossier + " sera créé à cet endroit.")
	return(-1)
END IF

ls_folderName = sle_dest.text + "\" + as_ndossier

IF NOT directoryExists(ls_folderName) THEN
	createDirectory(ls_folderName)
END IF

lu_fs = CREATE uo_fileservices

// export PDF
IF gu_bold.uf_getPDFcontent(as_ndossier, ls_pdfErr, lb_pdfContent) = 1 THEN
	ls_PDFfileName = ls_folderName + "\" + as_ndossier + ".pdf"
	filedelete(ls_PDFfileName)
	IF lu_fs.uf_writefile(lb_pdfContent, ls_PDFfileName, replace!) < 0 THEN
		ls_PDFerr = "Erreur d'écriture du fichier " + ls_PDFfileName
	ELSE
		ls_PDFCreated = ls_PDFfileName
	END IF
END IF
	
// export XML
IF gu_bold.uf_getXMLcontent(as_ndossier, ls_xmlErr, ls_xmlcontent) = 1 THEN
	ls_XMLfileName = ls_folderName + "\" + as_ndossier + ".xml"
	filedelete(ls_XMLfileName)
	IF lu_fs.uf_writefile(ls_xmlContent, ls_XMLfileName, replace!, EncodingUTF8!) < 0 THEN
		ls_xmlErr = "Erreur d'écriture du fichier " + ls_XMLfileName
	ELSE
		ls_XMLCreated = ls_XMLfileName
	END IF
END IF

// export pièces jointes
li_attachNr = gu_bold.uf_getallattachmentcontent(as_ndossier, ls_attachFileName, lb_attachContent)
FOR li_row = 1 TO li_attachNr
	ls_fullFileName = ls_folderName + "\" + ls_attachFileName[li_row]
	filedelete(ls_fullFileName)
	IF lu_fs.uf_writefile(lb_attachContent[li_row], ls_fullFileName, replace!) < 0 THEN
		ls_attachErr = ls_attachErr + "Erreur d'écriture du fichier " + ls_fullFileName + ".~n"
	ELSE
		ls_attachCreated = ls_attachCreated + ls_fullFileName + "~n"
	END IF
NEXT

DESTROY lu_fs

// constitution message créations fichiers réussies
IF NOT f_isEmptyString(ls_PDFCreated) OR NOT f_isEmptyString(ls_XMLCreated) OR NOT f_isEmptyString(ls_attachCreated) THEN
	ls_message = "Les fichiers suivant ont été créés :~n"
END IF
IF NOT f_isEmptyString(ls_PDFCreated) THEN
	ls_message = ls_message + ls_PDFCreated + "~n"
END IF
IF NOT f_isEmptyString(ls_XMLCreated) THEN
	ls_message = ls_message + ls_XMLCreated + "~n"
END IF
IF NOT f_isEmptyString(ls_attachCreated) THEN
	ls_message = ls_message + ls_attachCreated + "~n"
END IF

// constitution créations fichiers échouées
IF NOT f_isEmptyString(ls_pdfErr) THEN
	ls_message = ls_message + "~n" + f_string(ls_pdfErr)
END IF
IF NOT f_isEmptyString(ls_xmlErr) THEN
	ls_message = ls_message + "~n" + f_string(ls_xmlErr)
END IF
IF NOT f_isEmptyString(ls_attachErr) THEN
	ls_message = ls_message + "~n" + f_string(ls_attachErr)
END IF

// affichage du message
gu_message.uf_info(ls_message)

IF NOT f_isEmptyString(ls_pdfErr) OR NOT f_isEmptyString(ls_xmlErr) OR NOT f_isEmptyString(ls_attachErr) THEN
	return(-1)
ELSE
	return(1)
END IF

end function

public subroutine wf_listdrc (string as_ndossier);integer	li_status

IF f_isEmptyString(as_ndossier) THEN
	return
END IF

IF NOT IsValid(w_bold_drc_list) THEN
	OpenSheet(w_bold_drc_list, gw_mdiframe, 0, Original!)
END IF
IF IsValid(w_bold_drc_list) THEN
	w_bold_drc_list.SetFocus()
	w_bold_drc_list.post wf_retrieve(as_ndossier)
END IF

end subroutine

public subroutine wf_setmaskbuttons (boolean ab_oui, boolean ab_non);rb_mask_oui.checked = ab_oui
rb_mask_non.checked = ab_non
end subroutine

public function boolean wf_getstatus (string as_ndossier, ref string as_currentstatus);// Vérifie si le dossier existe et renvoie son status.
// A priori, utilisation de cette fonction par programme externe.
// return(TRUE) si le dossier existe, FALSE sinon.
// Si le dossier existe, son statut est renvoyé dans as_currentStatus
string	ls_currentstatus, ls_processingstatus, ls_message
integer	li_status

as_currentstatus = ""
li_status = gu_bold.uf_getcurrentstatus(as_ndossier, ls_currentstatus, ls_processingstatus, ls_message)

IF li_status < 0 THEN
	return(FALSE)
ELSE
	as_currentstatus = ls_currentstatus
	return(TRUE)
END IF

end function

public subroutine wf_accessrights_modify (long al_row);// Déterminer droits d'accès en modification du dossier (importation, DRC, changement de statut)
integer	li_i, li_j
long		ll_pRef

IF al_row <= 0 THEN
	return
END IF

ll_pRef = dw_select.object.procedureRef[al_row]

// Rechercher l'ID du dossier sélectionné, retrouver de quelle matière il s'agit,
// et vérifier si l'utilisateur a le droit de modifier (importer, faire une DRC, changer le statut) ou pas 
FOR li_i = 1 TO upperBound(istr_access)
	FOR li_j = 1 TO upperBound(istr_access[li_i].l_pRef)
		IF ll_pRef = istr_access[li_i].l_pRef[li_j] THEN
			IF gu_privs.uf_canupdate(istr_access[li_i].s_mat) = 1 THEN
				cb_import.enabled = TRUE
				cb_process.enabled = TRUE
				cb_rfai.enabled = TRUE
				cb_cancelRfai.enabled = TRUE
				cb_attach.enabled = TRUE
				cb_end.enabled = TRUE
				// 09/03/2023 : fonctionnalités dispo uniquement en TEST
				// 16/04 : aussi en VALID
				// 20/04 : mise en prod --> accès dans tous les environnements
				// IF gs_envapp = "T" OR gs_envapp = "V" THEN
				cb_getuserdossier.enabled = TRUE
			ELSE
				cb_import.enabled = FALSE
				cb_process.enabled = FALSE
				cb_rfai.enabled = FALSE
				cb_cancelRfai.enabled = FALSE
				cb_attach.enabled = FALSE
				cb_end.enabled = FALSE
				cb_getuserdossier.enabled = FALSE
			END IF
		END IF
	NEXT
NEXT


end subroutine

public function integer wf_importxml (string as_ndossier, string as_userdossierid, long al_procedureref, string as_procedurename);// Fonction vide dans l'objet ancêtre, à adapter par application dans un objet hérité.
// Lancer la fonction d'importation XML du programme de gestion du dossier sélectionné

return(1)
end function

public function integer wf_publishcancelrfai (string as_ndossier, string as_justif);// Publier l'annulation d'une DRC
// return(1) : OK
// return(-1) : Erreur
string	ls_message

IF f_isEmptyString(as_ndossier) THEN
	return(-1)
END IF

IF gu_bold.uf_publishCancelRfai(as_ndossier, as_justif, ls_message) = 1 THEN
	wf_retrieve()
	gu_message.uf_info("La demande d'annulation de la DRC du dossier " + as_ndossier + " a été soumise")
	return(1)
ELSE
	gu_message.uf_error(ls_message)
	return(-1)
END IF

end function

public function integer wf_publishrfai (string as_ndossier, string as_subject, string as_description, date adt_expirydate, str_params astr_target[]);// Introduire une demande de renseignement complémentaire.
// return(1) : OK
// return(-1) : Erreur
string	ls_message

IF f_isEmptyString(as_ndossier) THEN
	return(-1)
END IF

IF gu_bold.uf_publishRfai(as_ndossier, as_subject, as_description, adt_expiryDate, astr_target, ls_message) = 1 THEN
	wf_retrieve()
	gu_message.uf_info("La DRC a été soumise pour le dossier " + as_ndossier)
	return(1)
ELSE
	gu_message.uf_error(ls_message)
	return(-1)
END IF

end function

public function integer wf_selectprocedureref (string as_ndossier);// Vérifie si le dossier existe et sélectionne son n° de démarche dans le DDDW
// A priori, utilisation de cette fonction par programme externe.
string	ls_procedureRef, ls_message
integer	li_status

li_status = gu_bold.uf_getProcedureRef(as_ndossier, ls_procedureRef, ls_message)

IF li_status < 0 THEN
	return(-1)
ELSE
	return(1)
END IF

end function

public function integer wf_publishgetuserdossier (string as_ndossier, integer ai_version);// Envoyer demande de rechargement du dossier sélectionné ou d'un dossier inexistant dans BOLD mais bien dans MonEspace
// return(1) : OK
// return(-1) : Erreur
string	ls_message

IF f_isEmptyString(as_ndossier) THEN
	return(-1)
END IF

IF gu_bold.uf_publishGetUserDossier(as_ndossier, ai_version, ls_message) = 1 THEN
	gu_message.uf_info("La demande d'importation a été soumise pour le dossier " + as_ndossier)
	return(1)
ELSE
	gu_message.uf_error(ls_message)
	return(-1)
END IF

end function

public subroutine wf_cb_open ();long	ll_row

ll_row = dw_select.getRow()
IF ll_row <= 0 THEN return

// PCO 08/02/2024 : activer ou pas le bouton cb_open selon que le dossier a déjà été importé ou pas
IF upper(dw_select.object.budata_lastopdesc[ll_row]) = "IMPORTATION" THEN
	cb_open.enabled = TRUE
ELSE
	cb_open.enabled = FALSE
END IF

end subroutine

public function integer wf_open (string as_ndossier, long al_procedureref, string as_procedurename);// Fonction vide dans l'objet ancêtre, à adapter par application dans un objet hérité.
// Lancer la fonction d'ouverture du programme de gestion du dossier sélectionné

return(1)
end function

public subroutine wf_resetfilter_exceptpref ();// Supprimer les filtres sauf type de dossier
dw_filter.object.s_status[1] = " Tous"
dw_filter.object.s_service[1] = " Tous"
dw_filter.object.s_auteur[1] = " Tous"

end subroutine

on w_userdossier_common.create
int iCurrent
call super::create
this.cb_open=create cb_open
this.cb_choix_demarche=create cb_choix_demarche
this.cb_getuserdossier=create cb_getuserdossier
this.cb_cancelrfai=create cb_cancelrfai
this.st_nbdisplayed=create st_nbdisplayed
this.cb_listdrc=create cb_listdrc
this.st_2=create st_2
this.rb_mask_non=create rb_mask_non
this.rb_mask_oui=create rb_mask_oui
this.cb_refresh=create cb_refresh
this.dw_filter=create dw_filter
this.st_1=create st_1
this.cb_listattach=create cb_listattach
this.cb_show=create cb_show
this.cb_export=create cb_export
this.cb_import=create cb_import
this.cb_attach=create cb_attach
this.cb_rfai=create cb_rfai
this.cb_end=create cb_end
this.cb_process=create cb_process
this.sle_dest=create sle_dest
this.dw_select=create dw_select
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_open
this.Control[iCurrent+2]=this.cb_choix_demarche
this.Control[iCurrent+3]=this.cb_getuserdossier
this.Control[iCurrent+4]=this.cb_cancelrfai
this.Control[iCurrent+5]=this.st_nbdisplayed
this.Control[iCurrent+6]=this.cb_listdrc
this.Control[iCurrent+7]=this.st_2
this.Control[iCurrent+8]=this.rb_mask_non
this.Control[iCurrent+9]=this.rb_mask_oui
this.Control[iCurrent+10]=this.cb_refresh
this.Control[iCurrent+11]=this.dw_filter
this.Control[iCurrent+12]=this.st_1
this.Control[iCurrent+13]=this.cb_listattach
this.Control[iCurrent+14]=this.cb_show
this.Control[iCurrent+15]=this.cb_export
this.Control[iCurrent+16]=this.cb_import
this.Control[iCurrent+17]=this.cb_attach
this.Control[iCurrent+18]=this.cb_rfai
this.Control[iCurrent+19]=this.cb_end
this.Control[iCurrent+20]=this.cb_process
this.Control[iCurrent+21]=this.sle_dest
this.Control[iCurrent+22]=this.dw_select
end on

on w_userdossier_common.destroy
call super::destroy
destroy(this.cb_open)
destroy(this.cb_choix_demarche)
destroy(this.cb_getuserdossier)
destroy(this.cb_cancelrfai)
destroy(this.st_nbdisplayed)
destroy(this.cb_listdrc)
destroy(this.st_2)
destroy(this.rb_mask_non)
destroy(this.rb_mask_oui)
destroy(this.cb_refresh)
destroy(this.dw_filter)
destroy(this.st_1)
destroy(this.cb_listattach)
destroy(this.cb_show)
destroy(this.cb_export)
destroy(this.cb_import)
destroy(this.cb_attach)
destroy(this.cb_rfai)
destroy(this.cb_end)
destroy(this.cb_process)
destroy(this.sle_dest)
destroy(this.dw_select)
end on

event ue_open;call super::ue_open;// Instancier BOLD si pas encore fait par un autre objet
IF NOT isValid(gu_bold) THEN
	gu_bold = CREATE uo_bold
END IF

// initialiser les types de dossiers accessibles
IF wf_accessrights_read() = -1 THEN
	post close(this)
	return
END IF

// connexion BOLD
IF gu_bold.uf_connect() = -1 THEN
	post close(this)
	return
END IF

dw_select.setTransObject(gu_bold.itr_bold)

// divers
this.event ue_init_menu()
cb_import.enabled = FALSE
cb_open.enabled = FALSE
cb_getuserdossier.enabled = FALSE
dw_filter.insertrow(0)
sle_dest.text = profileString(gs_locinifile, gs_username, "BOLD_EXPORT", gs_MyDocuments)

ib_retrieving = FALSE

// rafraichissement toutes les 30 secondes
timer(30)
end event

event ue_init_menu;call super::ue_init_menu;f_menuaction({"m_fermer"})
end event

event resize;call super::resize;dw_select.height = newheight - 350
dw_select.width = newwidth

sle_dest.y = dw_select.y + dw_select.height + 24

cb_import.y = dw_select.y + dw_select.height + 16
cb_listattach.y = cb_import.y
cb_listdrc.y = cb_import.y
cb_export.y = cb_import.y
cb_show.y = cb_import.y
cb_open.y = cb_import.y

cb_process.y = cb_import.y + 100
cb_end.y = cb_process.y
cb_rfai.y = cb_process.y
cb_cancelRfai.y = cb_process.y
cb_attach.y = cb_process.y
cb_getuserdossier.y = cb_process.y

st_nbdisplayed.x = newwidth - st_nbdisplayed.width - 32
st_nbdisplayed.y = cb_process.y + 32


end event

event ue_postopen;call super::ue_postopen;wf_retrieve()
end event

event ue_close;call super::ue_close;IF IsValid(w_bold_attachments_list) THEN
	close(w_bold_attachments_list)
END IF

IF IsValid(w_bold_attachment_add) THEN
	close(w_bold_attachment_add)
END IF

IF IsValid(w_bold_drc_add) THEN
	close(w_bold_drc_add)
END IF

// déconnexion et destroy s'il n'y a plus de connexion en cours (par un autre objet éventuellement)
gu_bold.uf_disconnect()
IF gu_bold.uf_getconnectioncount() <= 0 THEN
	DESTROY gu_bold
END IF


end event

event timer;call super::timer;wf_retrieve()
end event

type cb_open from uo_cb within w_userdossier_common
integer x = 2505
integer y = 2592
integer width = 622
integer height = 96
integer taborder = 20
integer textsize = -9
boolean enabled = false
string text = "Ouvrir dossier importé"
end type

event clicked;call super::clicked;long		ll_row, ll_procedureRef
string	ls_ndossier, ls_procedureName

ll_row = dw_select.getRow()
IF ll_row <= 0 THEN
	return(-1)
END IF

ls_ndossier = dw_select.object.userdossiernumber[ll_row]
ll_procedureRef = abs(long(dw_select.object.procedureRef[ll_row]))
ls_procedureName = f_string(dw_select.object.procedureName[ll_row])

wf_open(ls_ndossier, ll_procedureRef, ls_procedureName)
end event

type cb_choix_demarche from uo_cb within w_userdossier_common
integer x = 6144
integer y = 16
integer width = 238
integer height = 96
integer textsize = -9
string text = "Choix"
end type

event clicked;call super::clicked;str_params	lstr_params

lstr_params.a_param[1] = is_demarche_visible
lstr_params.a_param[2] = is_nom_demarche_visible
openwithParm(w_bold_demarche_choix, lstr_params)
IF Message.DoubleParm = -1 THEN
	// pas de changement : ne rien faire
	return
ELSE
	// réinitialiser pour tenir compte des changements dans les démarches choisies
	IF wf_accessRights_read() = -1 THEN
		post close(parent)
		return
	ELSE
		// Après changement choix des démarches visibles, filtre sur type de démarche = Tous 
		dw_filter.object.n_pref[1] = 0
		wf_retrieve()
	END IF
END IF
end event

type cb_getuserdossier from uo_cb within w_userdossier_common
integer x = 3127
integer y = 2704
integer width = 622
integer height = 96
integer taborder = 20
integer textsize = -9
boolean enabled = false
string text = "Synchroniser avec Nep"
end type

event clicked;call super::clicked;// Envoyer demande de rechargement du dossier sélectionné ou d'un dossier inexistant dans BOLD mais bien dans MonEspace
string	ls_ndossier, ls_message
integer	li_version

IF dw_select.getRow() > 0 THEN
	ls_ndossier = dw_select.object.userdossiernumber[dw_select.getRow()]
END IF

IF gu_bold.uf_inputGetUserDossier(ls_ndossier, li_version, ls_message) = 1 THEN
	wf_publishGetUserDossier(ls_ndossier, li_version)
END IF

end event

type cb_cancelrfai from uo_cb within w_userdossier_common
integer x = 1262
integer y = 2704
integer width = 622
integer height = 96
integer textsize = -9
boolean enabled = false
string text = "Annuler DRC"
end type

event clicked;call super::clicked;string	ls_ndossier, ls_justif

IF dw_select.getRow() <= 0 THEN
	return(-1)
END IF

ls_ndossier = dw_select.object.userdossiernumber[dw_select.getRow()]
IF gu_bold.uf_inputCancelRfai(ls_ndossier, ls_justif) = 1 THEN
	wf_publishCancelRfai(ls_ndossier, ls_justif)
END IF
end event

type st_nbdisplayed from uo_statictext within w_userdossier_common
integer x = 5431
integer y = 2720
integer width = 951
integer textsize = -9
string text = ""
alignment alignment = right!
end type

type cb_listdrc from uo_cb within w_userdossier_common
integer x = 640
integer y = 2592
integer width = 622
integer height = 96
integer textsize = -9
string text = "Afficher DRC"
end type

event clicked;call super::clicked;string ls_ndossier

IF dw_select.getRow() <= 0 THEN
	return(-1)
END IF

ls_ndossier = dw_select.object.userdossiernumber[dw_select.getRow()]

wf_listdrc(ls_ndossier)

end event

type st_2 from uo_statictext within w_userdossier_common
integer x = 4974
integer y = 16
integer width = 713
string text = "Masquer dossiers clôturés"
end type

type rb_mask_non from uo_radiobutton within w_userdossier_common
integer x = 5906
integer y = 16
integer width = 183
string text = "non"
end type

event clicked;call super::clicked;long		ll_row
string	ls_ndossier

ll_row = dw_select.getRow()
IF ll_row > 0 THEN
	ls_ndossier = dw_select.object.userdossiernumber[ll_row]
END IF

wf_filter(ls_ndossier)
end event

type rb_mask_oui from uo_radiobutton within w_userdossier_common
integer x = 5705
integer y = 16
integer width = 183
string text = "oui"
boolean checked = true
end type

event clicked;call super::clicked;long		ll_row
string	ls_ndossier

ll_row = dw_select.getRow()
IF ll_row > 0 THEN
	ls_ndossier = dw_select.object.userdossiernumber[ll_row]
END IF

wf_filter(ls_ndossier)
end event

type cb_refresh from uo_cb within w_userdossier_common
integer y = 8
integer width = 311
integer height = 96
integer textsize = -9
string text = "Actualiser"
end type

event clicked;call super::clicked;wf_retrieve()

end event

type dw_filter from uo_ancestor_dw within w_userdossier_common
integer x = 549
integer y = 16
integer width = 4498
integer height = 96
integer taborder = 0
string dataobject = "d_bold_pref"
end type

event ue_postitemvalidated;call super::ue_postitemvalidated;long		ll_row
string	ls_ndossier

ll_row = dw_select.getRow()
IF ll_row > 0 THEN
	ls_ndossier = dw_select.object.userdossiernumber[ll_row]
END IF

wf_filter(ls_ndossier)

end event

type st_1 from uo_statictext within w_userdossier_common
integer x = 329
integer y = 24
integer width = 233
string text = "Filtres : "
end type

type cb_listattach from uo_cb within w_userdossier_common
integer x = 1262
integer y = 2592
integer width = 622
integer height = 96
integer textsize = -9
string text = "Lister documents joints"
end type

event clicked;call super::clicked;string ls_ndossier

IF dw_select.getRow() <= 0 THEN
	return(-1)
END IF

ls_ndossier = dw_select.object.userdossiernumber[dw_select.getRow()]

wf_listattachment(ls_ndossier)

end event

type cb_show from uo_cb within w_userdossier_common
integer x = 18
integer y = 2592
integer width = 622
integer height = 96
integer textsize = -9
string text = "Ouvrir PDF"
end type

event clicked;call super::clicked;string	ls_ndossier

IF dw_select.getRow() <= 0 THEN
	return(-1)
END IF

ls_ndossier = dw_select.object.userdossiernumber[dw_select.getRow()]

wf_showPDF(ls_ndossier)

end event

type cb_export from uo_cb within w_userdossier_common
integer x = 3127
integer y = 2592
integer width = 622
integer height = 96
integer textsize = -9
string text = "Exporter"
end type

event clicked;call super::clicked;string	ls_ndossier

IF dw_select.getRow() <= 0 THEN
	return(-1)
END IF

ls_ndossier = dw_select.object.userdossiernumber[dw_select.getRow()]

wf_export(ls_ndossier)

end event

type cb_import from uo_cb within w_userdossier_common
integer x = 1883
integer y = 2592
integer width = 622
integer height = 96
integer textsize = -9
boolean enabled = false
string text = "Importer dossier"
end type

event clicked;call super::clicked;long		ll_row, ll_procedureRef
string	ls_ndossier, ls_userDossierID, ls_procedureName

ll_row = dw_select.getRow()
IF ll_row <= 0 THEN
	return(-1)
END IF

ls_ndossier = dw_select.object.userdossiernumber[ll_row]
ls_userDossierID = dw_select.object.userDossierId[ll_row]
ll_procedureRef = abs(long(dw_select.object.procedureRef[ll_row]))
ls_procedureName = f_string(dw_select.object.procedureName[ll_row])

wf_importXml(ls_ndossier, ls_userDossierID, ll_procedureRef, ls_procedureName)
end event

type cb_attach from uo_cb within w_userdossier_common
integer x = 1883
integer y = 2704
integer width = 622
integer height = 96
integer textsize = -9
boolean enabled = false
string text = "Joindre document"
end type

event clicked;call super::clicked;string	ls_ndossier, ls_typekey, ls_description, ls_fileName

IF dw_select.getRow() <= 0 THEN
	return(-1)
END IF

ls_ndossier = dw_select.object.userdossiernumber[dw_select.getRow()]

IF gu_bold.uf_inputAttach(ls_ndossier, ls_typekey, ls_description, ls_fileName) = 1 THEN
	wf_publishAttach(ls_ndossier, ls_typekey, ls_typekey, ls_description, ls_fileName)
END IF
end event

type cb_rfai from uo_cb within w_userdossier_common
integer x = 640
integer y = 2704
integer width = 622
integer height = 96
integer textsize = -9
boolean enabled = false
string text = "Introduire DRC"
end type

event clicked;call super::clicked;string	ls_ndossier, ls_subject, ls_description
date		ldt_expiryDate
str_params	lstr_target[]

IF dw_select.getRow() <= 0 THEN
	return(-1)
END IF

ls_ndossier = dw_select.object.userdossiernumber[dw_select.getRow()]

IF gu_bold.uf_inputrfai(ls_ndossier, ls_subject, ls_description, ldt_expiryDate, lstr_target) = 1 THEN
	wf_publishrfai(ls_ndossier, ls_subject, ls_description, ldt_expiryDate, lstr_target)
END IF
end event

type cb_end from uo_cb within w_userdossier_common
integer x = 2505
integer y = 2704
integer width = 622
integer height = 96
integer textsize = -9
boolean enabled = false
string text = "Clôturer le dossier"
end type

event clicked;call super::clicked;string	ls_ndossier

IF dw_select.getRow() <= 0 THEN
	return(-1)
END IF

ls_ndossier = dw_select.object.userdossiernumber[dw_select.getRow()]

wf_publishstatus(ls_ndossier, "ENDED")
end event

type cb_process from uo_cb within w_userdossier_common
integer x = 18
integer y = 2704
integer width = 622
integer height = 96
integer textsize = -9
boolean enabled = false
string text = "Traiter le dossier"
end type

event clicked;call super::clicked;string	ls_ndossier

IF dw_select.getRow() <= 0 THEN
	return(-1)
END IF

ls_ndossier = dw_select.object.userdossiernumber[dw_select.getRow()]

wf_publishstatus(ls_ndossier, "PROCESSING")
end event

type sle_dest from uo_sle within w_userdossier_common
event se_dblclick pbm_lbuttondblclk
integer x = 3767
integer y = 2592
integer width = 768
integer height = 80
integer textsize = -8
boolean displayonly = true
string placeholder = "Double-clic pour sélectionner un dossier"
end type

event se_dblclick;string	ls_folderName, ls_pathname, ls_filename, ls_1, ls_2
uo_fileservices	lu_fileservices

ls_folderName = sle_dest.text
IF GetFileSaveName ("Sélection du dossier de stockage", ls_pathname, ls_filename, "", "", ls_folderName, 2) = 1 THEN
	lu_fileservices = CREATE uo_fileservices
	lu_fileservices.uf_basename(ls_pathname, FALSE, ls_folderName, ls_1, ls_2)
	DESTROY lu_fileservices	
	sle_dest.text = ls_folderName
	setProfileString(gs_locinifile, gs_username, "BOLD_EXPORT", sle_dest.text)
END IF

end event

type dw_select from uo_ancestor_dwbrowse within w_userdossier_common
integer y = 112
integer width = 6400
integer height = 2432
integer taborder = 10
string dataobject = "d_userdossier"
boolean hscrollbar = true
boolean vscrollbar = true
boolean border = true
end type

event losefocus;// Override ancestor's script afin que la ligne en cours reste mise en évidence même que le DW n'a pas le focus

end event

event rowfocuschanged;call super::rowfocuschanged;IF currentRow <= 0 THEN return
IF ib_retrieving THEN return

wf_accessrights_modify(currentRow)

// PCO 08/02/2024 : si le dossier a déjà été  importé, permettre d'ouvrir le programme
// correspondant et de l'afficher. Pour cela, activer le bouton cb_open.
wf_cb_open()
end event

event ue_keypressed;call super::ue_keypressed;string	ls_userdossiernumber

// CTRL-C : copier n° de dossier de le clipboard
// NB : There is a datawindow function "clipboard" to copy a bitmap image of a datawindow graph control to clipboard. 
// And there is a global function "clipboard" to copy a text to clipboard or get a text from clipboard.
// If you call "clipboard" from a datawindow event it calls the datawindow function.
// To call the global function from a datawindow event you have to call ::clipboard(text)
IF key=keyc! AND keyflags=2 AND this.getRow() > 0 THEN
	ls_userdossiernumber = f_string(this.object.userdossiernumber[this.getRow()])
	::clipboard(ls_userdossiernumber)
END IF
end event

