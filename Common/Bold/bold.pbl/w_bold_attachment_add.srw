forward
global type w_bold_attachment_add from w_ancestor
end type
type sle_desc from uo_sle within w_bold_attachment_add
end type
type st_4 from uo_statictext within w_bold_attachment_add
end type
type dw_1 from uo_ancestor_dwbrowse within w_bold_attachment_add
end type
type sle_filename from uo_sle within w_bold_attachment_add
end type
type st_3 from uo_statictext within w_bold_attachment_add
end type
type cb_cancel from uo_cb_cancel within w_bold_attachment_add
end type
type cb_ok from uo_cb_ok within w_bold_attachment_add
end type
type sle_typekey from uo_sle within w_bold_attachment_add
end type
type st_2 from uo_statictext within w_bold_attachment_add
end type
type st_1 from uo_statictext within w_bold_attachment_add
end type
end forward

global type w_bold_attachment_add from w_ancestor
integer width = 3771
integer height = 2060
string title = "Ajouter un document au dossier"
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
boolean center = true
event ue_folderopen ( )
sle_desc sle_desc
st_4 st_4
dw_1 dw_1
sle_filename sle_filename
st_3 st_3
cb_cancel cb_cancel
cb_ok cb_ok
sle_typekey sle_typekey
st_2 st_2
st_1 st_1
end type
global w_bold_attachment_add w_bold_attachment_add

forward prototypes
public function boolean wf_check_exists (string as_filename)
end prototypes

public function boolean wf_check_exists (string as_filename);IF dw_1.find("filename=~"" + as_filename + "~"", 1, dw_1.rowCount()) > 0 THEN
	gu_message.uf_error("Ce document existe déjà dans ce dossier")
	return(TRUE)
END IF
return(FALSE)
end function

on w_bold_attachment_add.create
int iCurrent
call super::create
this.sle_desc=create sle_desc
this.st_4=create st_4
this.dw_1=create dw_1
this.sle_filename=create sle_filename
this.st_3=create st_3
this.cb_cancel=create cb_cancel
this.cb_ok=create cb_ok
this.sle_typekey=create sle_typekey
this.st_2=create st_2
this.st_1=create st_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.sle_desc
this.Control[iCurrent+2]=this.st_4
this.Control[iCurrent+3]=this.dw_1
this.Control[iCurrent+4]=this.sle_filename
this.Control[iCurrent+5]=this.st_3
this.Control[iCurrent+6]=this.cb_cancel
this.Control[iCurrent+7]=this.cb_ok
this.Control[iCurrent+8]=this.sle_typekey
this.Control[iCurrent+9]=this.st_2
this.Control[iCurrent+10]=this.st_1
end on

on w_bold_attachment_add.destroy
call super::destroy
destroy(this.sle_desc)
destroy(this.st_4)
destroy(this.dw_1)
destroy(this.sle_filename)
destroy(this.st_3)
destroy(this.cb_cancel)
destroy(this.cb_ok)
destroy(this.sle_typekey)
destroy(this.st_2)
destroy(this.st_1)
end on

event ue_closebyxaccepted;call super::ue_closebyxaccepted;cb_cancel.Event clicked()
end event

event ue_open;call super::ue_open;str_params	lstr_params
string		ls_ndossier

// récupérer n° de dossier
lstr_params = Message.PowerObjectParm
IF IsValid(lstr_params) THEN 
	CHOOSE CASE upperbound(lstr_params.a_param)
		CASE 1
			ls_ndossier = string(lstr_params.a_param[1])
	END CHOOSE
END IF

IF f_isEmptyString(ls_ndossier) THEN
	post close(this)
	return
END IF


// Instancier BOLD si pas encore fait par un autre objet
IF NOT isValid(gu_bold) THEN
	gu_bold = CREATE uo_bold
END IF

// connexion BOLD
IF gu_bold.uf_connect() = -1 THEN
	post close(this)
	return
END IF

dw_1.setTransobject(gu_bold.itr_bold)

this.title = "Ajouter un document au dossier " + ls_ndossier
dw_1.retrieve(ls_ndossier)
end event

event ue_close;call super::ue_close;// déconnexion et destroy s'il n'y a plus de connexion en cours (par un autre objet éventuellement)
gu_bold.uf_disconnect()
IF gu_bold.uf_getconnectioncount() = 0 THEN
	DESTROY gu_bold
END IF

end event

type sle_desc from uo_sle within w_bold_attachment_add
integer x = 640
integer y = 224
integer width = 2999
integer height = 272
integer taborder = 20
integer textsize = -9
integer limit = 500
end type

type st_4 from uo_statictext within w_bold_attachment_add
integer x = 18
integer y = 784
integer width = 969
integer height = 80
string text = "Documents déjà joints au dossier"
end type

type dw_1 from uo_ancestor_dwbrowse within w_bold_attachment_add
integer x = 18
integer y = 864
integer width = 3730
integer height = 912
integer taborder = 0
string dataobject = "d_bold_attachments_list"
boolean hscrollbar = true
boolean vscrollbar = true
boolean border = true
end type

type sle_filename from uo_sle within w_bold_attachment_add
event se_dblclick pbm_lbuttondblclk
integer x = 640
integer y = 544
integer width = 2999
integer height = 96
integer taborder = 30
integer textsize = -9
integer weight = 700
string placeholder = "Double-clic pour sélectionner un fichier"
end type

event se_dblclick;string	ls_pathname, ls_filename, ls_foldername, ls_1, ls_2
long		ll_import
uo_fileservices	lu_fileservices

ls_foldername = profileString(gs_locinifile, gs_username, "BOLD_ATTACH", gs_MyDocuments)

// choix du fichier à joindre au dossier
IF GetFileOpenName("Sélection du fichier", ls_pathname, ls_filename, "", "Fichier,*.*", ls_foldername, 26) = 1 THEN
	// Vérifier que le fichier ne figure pas déjà dans les documents joints au dossier.
	// NB : seul le basename du fichier est pris en considération pour vérifier l'unicité.
	IF wf_check_exists(ls_filename) THEN
		return
	ELSE
		sle_filename.text = ls_pathname
		lu_fileservices = CREATE uo_fileservices
		lu_fileservices.uf_basename(ls_pathname, FALSE, ls_folderName, ls_1, ls_2)
		DESTROY lu_fileservices	
		setProfileString(gs_locinifile, gs_username, "BOLD_ATTACH", ls_foldername)
	END IF
END IF	

end event

type st_3 from uo_statictext within w_bold_attachment_add
integer x = 73
integer y = 544
integer width = 530
integer height = 144
string text = "Fichier à joindre au dossier"
end type

type cb_cancel from uo_cb_cancel within w_bold_attachment_add
integer x = 1920
integer y = 1824
end type

event clicked;call super::clicked;closeWithReturn(parent, -1)
end event

type cb_ok from uo_cb_ok within w_bold_attachment_add
integer x = 1280
integer y = 1824
boolean default = false
end type

event clicked;call super::clicked;str_params	lstr_params
string		ls_filename, ls_folderName, ls_2
uo_fileservices	lu_fileservices

// PCO 23/11/2023 : 2 messages séparés au lieu d'un message commun aux 2 erreurs possibles
IF f_isEmptyString(sle_typekey.text) THEN
	gu_message.uf_error("Le nom du document est obligatoire")
	return
END IF

IF f_isEmptyString(sle_filename.text) THEN
	gu_message.uf_error("Veuillez sélectionner le fichier à joindre au dossier")
	return
END IF

// Vérifier si le fichier existe
IF NOT fileExists(sle_filename.text) THEN
	gu_message.uf_error("Fichier inexistant")
	sle_filename.setFocus()
	return
END IF

// Vérifier que le fichier ne figure pas déjà dans les documents joints au dossier.
// NB : seul le basename du fichier est pris en considération pour vérifier l'unicité.
lu_fileservices = CREATE uo_fileservices
lu_fileservices.uf_basename(sle_filename.text, FALSE, ls_folderName, ls_filename, ls_2)
DESTROY lu_fileservices	
IF wf_check_exists(ls_filename) THEN
	sle_filename.setFocus()
	return
END IF

lstr_params.a_param[1] = sle_typekey.text
lstr_params.a_param[2] = sle_desc.text
lstr_params.a_param[3] = sle_filename.text

CloseWithReturn(Parent, lstr_params)
end event

type sle_typekey from uo_sle within w_bold_attachment_add
integer x = 640
integer y = 80
integer width = 2999
integer height = 96
integer taborder = 10
integer textsize = -9
integer limit = 20
end type

type st_2 from uo_statictext within w_bold_attachment_add
integer x = 73
integer y = 208
integer width = 512
integer height = 160
string text = "Descriptif du document"
end type

type st_1 from uo_statictext within w_bold_attachment_add
integer x = 73
integer y = 96
integer width = 512
string text = "Nom du document"
end type

