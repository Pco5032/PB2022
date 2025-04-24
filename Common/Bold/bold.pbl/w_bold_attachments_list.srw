//objectcomments Userdossier : liste des pièces jointes
forward
global type w_bold_attachments_list from w_ancestor
end type
type dw_1 from uo_ancestor_dwbrowse within w_bold_attachments_list
end type
end forward

global type w_bold_attachments_list from w_ancestor
integer width = 4544
string title = "Liste des documents joints au dossier"
dw_1 dw_1
end type
global w_bold_attachments_list w_bold_attachments_list

type variables

end variables

forward prototypes
public function integer wf_openattachment (long al_row)
public function integer wf_retrieve (string as_ndossier)
end prototypes

public function integer wf_openattachment (long al_row);// Visualiser le document
// return(1) : OK
// return(-1) : Erreur d'extraction du document
uo_fileservices	lu_fs
integer	li_st, li_rtn, li_ordre
blob		lb_content
string	ls_attachmentRowID, ls_fileName, ls_err, ls_status

IF al_row <= 0 THEN
	return(-1)
END IF

lu_fs = CREATE uo_fileservices

li_ordre = integer(dw_1.object.ordre[al_row])
ls_attachmentRowID = dw_1.object.attachmentRowID[al_row]
ls_status = dw_1.object.status[al_row]

IF ls_status = "EMPTY" THEN
	gu_message.uf_error("Document non soumis par l'utilisateur")
	return(-1)
END IF

// export document in work folder
// lire dans les attachments déjà publiés ou ceux pas encore chargés dans la table finale
IF li_ordre = 1 THEN
	li_st = 	gu_bold.uf_getAttachmentContent(ls_attachmentRowID, ls_err, ls_fileName, lb_content)
ELSE
	li_st = 	gu_bold.uf_getPendingAttachmentContent(ls_attachmentRowID, ls_err, ls_fileName, lb_content)
END IF
IF li_st = 1 THEN
	ls_fileName = gs_tmpfiles + "\" + ls_fileName
	filedelete(ls_fileName)
	IF lu_fs.uf_writefile(lb_content, ls_fileName, replace!) < 0 THEN
		gu_message.uf_error("Erreur d'écriture du fichier " + ls_fileName)
		li_rtn = -1
	ELSE
		// open document
		f_openlink(ls_fileName)
		li_rtn = 1
	END IF
ELSE
	gu_message.uf_error(ls_err)
	li_rtn = -1
END IF

DESTROY lu_fs

// même en postant le fileDelete, le fichier est supprimé avant d'avoir été ouvert :-(
//post filedelete(ls_fileName)
return(li_rtn)

end function

public function integer wf_retrieve (string as_ndossier);IF f_isEmptyString(as_ndossier) THEN
	return(-1)
END IF

dw_1.setTransobject(gu_bold.itr_bold)

this.title = "Liste des documents joints au dossier " + as_ndossier
return(dw_1.retrieve(as_ndossier))
end function

on w_bold_attachments_list.create
int iCurrent
call super::create
this.dw_1=create dw_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_1
end on

on w_bold_attachments_list.destroy
call super::destroy
destroy(this.dw_1)
end on

event ue_open;call super::ue_open;// Instancier BOLD si pas encore fait par un autre objet
IF NOT isValid(gu_bold) THEN
	gu_bold = CREATE uo_bold
END IF

// connexion BOLD
IF gu_bold.uf_connect() = -1 THEN
	post close(this)
	return
END IF

end event

event ue_close;call super::ue_close;// déconnexion et destroy s'il n'y a plus de connexion en cours (par un autre objet éventuellement)
gu_bold.uf_disconnect()
IF gu_bold.uf_getconnectioncount() = 0 THEN
	DESTROY gu_bold
END IF

end event

event resize;call super::resize;dw_1.width = newwidth
dw_1.height = newheight
end event

type dw_1 from uo_ancestor_dwbrowse within w_bold_attachments_list
integer width = 4498
integer height = 2080
integer taborder = 10
string dataobject = "d_bold_attachments_list"
boolean hscrollbar = true
boolean vscrollbar = true
boolean border = true
end type

event ue_help;call super::ue_help;wf_openAttachment(al_row)
end event

