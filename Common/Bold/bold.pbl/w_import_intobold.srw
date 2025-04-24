//objectcomments TEST Importation de fichiers vers CLOBs dans BOLD
forward
global type w_import_intobold from w_ancestor
end type
type sle_attachmentid from uo_sle within w_import_intobold
end type
type st_5 from uo_statictext within w_import_intobold
end type
type cb_importattach from uo_cb_ok within w_import_intobold
end type
type sle_doc from uo_sle within w_import_intobold
end type
type st_4 from uo_statictext within w_import_intobold
end type
type sle_dossier from uo_sle within w_import_intobold
end type
type st_3 from uo_statictext within w_import_intobold
end type
type cb_importpdf from uo_cb_ok within w_import_intobold
end type
type sle_pdf from uo_sle within w_import_intobold
end type
type st_2 from uo_statictext within w_import_intobold
end type
type sle_xml from uo_sle within w_import_intobold
end type
type st_1 from uo_statictext within w_import_intobold
end type
type cb_importxml from uo_cb_ok within w_import_intobold
end type
end forward

global type w_import_intobold from w_ancestor
integer width = 2176
integer height = 1256
string title = "Importation de fichiers vers BLOBs (table IMAGE_MAPS)"
sle_attachmentid sle_attachmentid
st_5 st_5
cb_importattach cb_importattach
sle_doc sle_doc
st_4 st_4
sle_dossier sle_dossier
st_3 st_3
cb_importpdf cb_importpdf
sle_pdf sle_pdf
st_2 st_2
sle_xml sle_xml
st_1 st_1
cb_importxml cb_importxml
end type
global w_import_intobold w_import_intobold

type variables
uo_blobservices	iu_bs
string	is_originalSQL, is_typeImage

end variables

on w_import_intobold.create
int iCurrent
call super::create
this.sle_attachmentid=create sle_attachmentid
this.st_5=create st_5
this.cb_importattach=create cb_importattach
this.sle_doc=create sle_doc
this.st_4=create st_4
this.sle_dossier=create sle_dossier
this.st_3=create st_3
this.cb_importpdf=create cb_importpdf
this.sle_pdf=create sle_pdf
this.st_2=create st_2
this.sle_xml=create sle_xml
this.st_1=create st_1
this.cb_importxml=create cb_importxml
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.sle_attachmentid
this.Control[iCurrent+2]=this.st_5
this.Control[iCurrent+3]=this.cb_importattach
this.Control[iCurrent+4]=this.sle_doc
this.Control[iCurrent+5]=this.st_4
this.Control[iCurrent+6]=this.sle_dossier
this.Control[iCurrent+7]=this.st_3
this.Control[iCurrent+8]=this.cb_importpdf
this.Control[iCurrent+9]=this.sle_pdf
this.Control[iCurrent+10]=this.st_2
this.Control[iCurrent+11]=this.sle_xml
this.Control[iCurrent+12]=this.st_1
this.Control[iCurrent+13]=this.cb_importxml
end on

on w_import_intobold.destroy
call super::destroy
destroy(this.sle_attachmentid)
destroy(this.st_5)
destroy(this.cb_importattach)
destroy(this.sle_doc)
destroy(this.st_4)
destroy(this.sle_dossier)
destroy(this.st_3)
destroy(this.cb_importpdf)
destroy(this.sle_pdf)
destroy(this.st_2)
destroy(this.sle_xml)
destroy(this.st_1)
destroy(this.cb_importxml)
end on

event ue_open;call super::ue_open;iu_bs = CREATE uo_blobservices

// Instancier BOLD si pas encore fait par un autre objet
IF NOT isValid(gu_bold) THEN
	gu_bold = CREATE uo_bold
END IF

// connexion BOLD
IF gu_bold.uf_connect() = -1 THEN
	post close(this)
	return
END IF

this.event ue_init_menu()

sle_dossier.text = '1196834-351654'
sle_attachmentid.text = "1d6faeeb-9edd-44b8-a2b2-ab1152fbff76"
end event

event ue_init_menu;call super::ue_init_menu;f_menuaction({"m_fermer"})
end event

event ue_close;call super::ue_close;// déconnexion et destroy s'il n'y a plus de connexion en cours (par un autre objet éventuellement)
gu_bold.uf_disconnect()
IF gu_bold.uf_getconnectioncount() = 0 THEN
	DESTROY gu_bold
END IF

DESTROY iu_bs

end event

type sle_attachmentid from uo_sle within w_import_intobold
event se_dblclick pbm_lbuttondblclk
integer x = 640
integer y = 784
integer width = 1445
integer height = 80
integer taborder = 10
integer textsize = -9
string pointer = "Help!"
end type

type st_5 from uo_statictext within w_import_intobold
integer x = 18
integer y = 800
integer width = 494
string text = "ID attachment"
end type

type cb_importattach from uo_cb_ok within w_import_intobold
integer x = 805
integer y = 976
integer taborder = 40
string text = "Importer"
end type

event clicked;call super::clicked;uo_fileservices	lu_fs
blob	lb_1
long	ll_count
string	ls_attachmentID

IF f_isEmptyString(sle_doc.text) THEN
	gu_message.uf_error("Veuillez sélectionner le document à importer")
	sle_pdf.setFocus()
	return
END IF

IF f_isEmptyString(sle_attachmentid.text) THEN
	gu_message.uf_error("Veuillez spécifier l'ID d'un attachment")
	sle_xml.setFocus()
	return
END IF

ls_attachmentID = sle_attachmentid.text

SELECT count(*) into :ll_count FROM USERDOSSIERATTACH where attachmentid=:ls_attachmentID using gu_bold.itr_bold;
IF f_check_sql(gu_bold.itr_bold) <> 0 THEN
	gu_message.uf_info("Attachment inexistant dans USERDOSSIERATTACH")
	return
END IF
IF ll_count = 0 THEN
	gu_message.uf_info("Attachment inexistant dans USERDOSSIERATTACH")
	return
END IF

lu_fs = CREATE uo_fileservices
IF lu_fs.uf_readfile(sle_doc.text, lb_1) = -1 THEN
	DESTROY lu_fs
	gu_message.uf_error("Erreur readfile")
	return
END IF
DESTROY lu_fs

UPDATEBLOB USERDOSSIERATTACH SET fileContent = :lb_1 where attachmentid=:ls_attachmentID using gu_bold.itr_bold;
IF f_check_sql(gu_bold.itr_bold) = 0 THEN
	gu_message.uf_info("Fichier importé avec succès")
ELSE
	rollback using gu_bold.itr_bold;
	gu_message.uf_error("Erreur UPDATEBLOB USERDOSSIERATTACH, fichier pas importé")
	return
END IF
commit using gu_bold.itr_bold;

end event

type sle_doc from uo_sle within w_import_intobold
event se_dblclick pbm_lbuttondblclk
integer x = 640
integer y = 880
integer width = 1445
integer height = 80
integer taborder = 40
integer textsize = -9
string pointer = "Help!"
end type

event se_dblclick;string	ls_pathname, ls_filename, ls_foldername
long		ll_import

// choix du fichier image à importer
IF GetFileOpenName("Sélection du fichier", ls_pathname, ls_filename, "", "Fichier,*.*", ls_foldername, 26) = 1 THEN
	sle_doc.text = ls_pathname
END IF	

end event

type st_4 from uo_statictext within w_import_intobold
integer x = 18
integer y = 896
integer width = 622
string text = "Doc à joindre"
end type

type sle_dossier from uo_sle within w_import_intobold
event se_dblclick pbm_lbuttondblclk
integer x = 640
integer y = 48
integer width = 1445
integer height = 80
integer taborder = 10
integer textsize = -9
string pointer = "Help!"
end type

type st_3 from uo_statictext within w_import_intobold
integer x = 18
integer y = 48
integer width = 494
string text = "N° dossier"
end type

type cb_importpdf from uo_cb_ok within w_import_intobold
integer x = 805
integer y = 592
string text = "Importer"
end type

event clicked;call super::clicked;uo_fileservices	lu_fs
blob	lb_1
long	ll_count
string	ls_ndossier

IF f_isEmptyString(sle_pdf.text) THEN
	gu_message.uf_error("Veuillez sélectionner le fichier PDF à importer")
	sle_pdf.setFocus()
	return
END IF

IF f_isEmptyString(sle_dossier.text) THEN
	gu_message.uf_error("Veuillez spécifier le n° de dossier")
	sle_xml.setFocus()
	return
END IF

ls_ndossier = sle_dossier.text

SELECT count(*) into :ll_count FROM USERDOSSIER where userDossierNumber=:ls_ndossier using gu_bold.itr_bold;
IF f_check_sql(gu_bold.itr_bold) <> 0 THEN
	gu_message.uf_info("Dossier inexistant dans USERDOSSIER")
	return
END IF
IF ll_count = 0 THEN
	gu_message.uf_info("Dossier inexistant dans USERDOSSIER")
	return
END IF

lu_fs = CREATE uo_fileservices
IF lu_fs.uf_readfile(sle_pdf.text, lb_1) = -1 THEN
	DESTROY lu_fs
	gu_message.uf_error("Erreur readfile")
	return
END IF
DESTROY lu_fs

UPDATEBLOB USERDOSSIER SET PdfContent = :lb_1 where userDossierNumber=:ls_ndossier  using gu_bold.itr_bold;
IF f_check_sql(gu_bold.itr_bold) = 0 THEN
	gu_message.uf_info("Fichier importé avec succès")
ELSE
	rollback using gu_bold.itr_bold;
	gu_message.uf_error("Erreur UPDATEBLOB USERDOSSIER, fichier pas importé")
	return
END IF
commit using gu_bold.itr_bold;

end event

type sle_pdf from uo_sle within w_import_intobold
event se_dblclick pbm_lbuttondblclk
integer x = 640
integer y = 496
integer width = 1445
integer height = 80
integer taborder = 30
integer textsize = -9
string pointer = "Help!"
end type

event se_dblclick;string	ls_pathname, ls_filename, ls_foldername
long		ll_import

// choix du fichier image à importer
IF GetFileOpenName("Sélection du fichier", ls_pathname, ls_filename, "", "Fichier,*.*", ls_foldername, 26) = 1 THEN
	sle_pdf.text = ls_pathname
END IF	

end event

type st_2 from uo_statictext within w_import_intobold
integer x = 18
integer y = 512
integer width = 622
string text = "Fichier PDF à importer"
end type

type sle_xml from uo_sle within w_import_intobold
event se_dblclick pbm_lbuttondblclk
integer x = 640
integer y = 192
integer width = 1445
integer height = 80
integer taborder = 20
integer textsize = -9
string pointer = "Help!"
end type

event se_dblclick;string	ls_pathname, ls_filename, ls_foldername
long		ll_import

// choix du fichier image à importer
IF GetFileOpenName("Sélection du fichier", ls_pathname, ls_filename, "", "Fichier,*.*", ls_foldername, 26) = 1 THEN
	sle_xml.text = ls_pathname
END IF	


end event

type st_1 from uo_statictext within w_import_intobold
integer x = 18
integer y = 192
integer width = 622
string text = "Fichier XML à importer"
end type

type cb_importxml from uo_cb_ok within w_import_intobold
integer x = 805
integer y = 288
string text = "Importer"
end type

event clicked;call super::clicked;uo_fileservices	lu_fs
string	ls_1, ls_ndossier
long		ll_count

IF f_isEmptyString(sle_dossier.text) THEN
	gu_message.uf_error("Veuillez spécifier le n° de dossier")
	sle_xml.setFocus()
	return
END IF

IF f_isEmptyString(sle_xml.text) THEN
	gu_message.uf_error("Veuillez sélectionner le fichier à importer")
	sle_xml.setFocus()
	return
END IF

ls_ndossier = sle_dossier.text

SELECT count(*) into :ll_count FROM USERDOSSIER where userDossierNumber=:ls_ndossier using gu_bold.itr_bold;
IF f_check_sql(gu_bold.itr_bold) <> 0 THEN
	gu_message.uf_info("Dossier inexistant dans USERDOSSIER")
	return
END IF
IF ll_count = 0 THEN
	gu_message.uf_info("Dossier inexistant dans USERDOSSIER")
	return
END IF

lu_fs = CREATE uo_fileservices
IF lu_fs.uf_readfile(sle_xml.text, ls_1, EncodingUTF8!) = -1 THEN
	DESTROY lu_fs
	gu_message.uf_error("Erreur readfile")
	return
END IF
DESTROY lu_fs

UPDATE USERDOSSIER SET XmlContent = :ls_1 where userDossierNumber=:ls_ndossier using gu_bold.itr_bold;
IF f_check_sql(gu_bold.itr_bold) = 0 THEN
	gu_message.uf_info("Fichier importé avec succès")
ELSE
	rollback using gu_bold.itr_bold;
	gu_message.uf_error("Erreur UPDATE USERDOSSIER, fichier pas importé")
	return
END IF
commit using gu_bold.itr_bold;

end event

