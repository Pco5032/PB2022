forward
global type uo_bold from nonvisualobject
end type
end forward

global type uo_bold from nonvisualobject
end type
global uo_bold uo_bold

type variables
string		is_debugText, is_debugFile
boolean		ib_debug
transaction	itr_bold
integer		ii_connectionCount

end variables

forward prototypes
public function integer uf_connect ()
public function integer uf_getpdfcontent (string as_ndossier, ref string as_message, ref blob ab_pdfcontent)
public function integer uf_getxmlcontent (string as_ndossier, ref string as_message, ref string as_xmlcontent)
public function integer uf_disconnect ()
public function integer uf_publishstatus (string as_ndossier, string as_status, ref string as_message)
public function integer uf_publishattach (string as_ndossier, string as_typekey, string as_typelabel, string as_description, string as_filename, ref string as_message)
public function integer uf_inputattach (string as_ndossier, ref string as_typekey, ref string as_description, ref string as_filename)
public function integer uf_getallattachmentcontent (string as_ndossier, ref string as_filename[], ref blob ab_content[])
public function integer uf_writebudata (string as_ndossier, string as_description, ref string as_message)
public function integer uf_getconnectioncount ()
public function integer uf_check_rfai_pending (string as_ndossier, ref string as_message)
public function string uf_getmimetype (string as_fileext)
public function integer uf_getattachmentcontent (string as_attachmentrowid, ref string as_message, ref string as_filename, ref blob ab_content)
public function integer uf_getpendingattachmentcontent (string as_attachmentrowid, ref string as_message, ref string as_filename, ref blob ab_content)
public function integer uf_getpendingstatus (string as_ndossier, ref string as_pendingstatus, ref string as_message)
public function integer uf_getfinalstatus (string as_ndossier, ref string as_finalstatus, ref string as_message)
public function integer uf_getcurrentstatus (string as_ndossier, ref string as_currentstatus, ref string as_processingstatus, ref string as_message)
public subroutine uf_logdebug ()
public function integer uf_getvalue (string as_ndossier, string as_fieldname, ref any aa_value, ref string as_message)
public function integer uf_inputcancelrfai (string as_ndossier, ref string as_justif)
public function integer uf_publishcancelrfai (string as_ndossier, string as_justif, ref string as_message)
public function long uf_getlistdossier (string as_where, ref uo_ds ads_listdossier, ref string as_message)
public function integer uf_inputrfai (string as_ndossier, ref string as_subject, ref string as_description, ref date adt_expirydate, ref str_params astr_target[])
public function integer uf_publishrfai (string as_ndossier, string as_subject, string as_description, date adt_expirydate, str_params astr_target[], ref string as_message)
public function integer uf_publishstatus (string as_ndossier, string as_status, boolean ab_confirmended, ref string as_message)
public function integer uf_publishstatus (string as_ndossier, string as_userdossierstatus, string as_processingstatus, string as_details, boolean ab_confirmended, ref string as_message)
public function integer uf_scrolltodossier (string as_ndossier)
public function integer uf_getprocedureref (string as_ndossier, ref string as_procedureref, ref string as_message)
public function integer uf_publishgetuserdossier (string as_ndossier, integer ai_version, ref string as_message)
public function integer uf_inputgetuserdossier (ref string as_ndossier, ref integer ai_version, ref string as_message)
public function boolean uf_inchoosenprocref (string as_ndossier)
end prototypes

public function integer uf_connect ();// connexion à la DB BOLD
// NB : une seule connexion physique par objet instancié
// return(1) : OK
// return(-1) : erreur
IF ib_debug THEN
	is_debugtext = "Connect() - Initial connectionCount=" + string(ii_connectionCount) + &
						" DBalias=" + gs_boldDBAlias + " DBuser=" + gs_boldUser
	uf_logdebug()
END IF

// connection BOLD
// NB : les variables gs_boldDBAlias, gs_bolduser et gs_boldpwd sont initialisées dès le logon de l'application
IF f_isEmptyString(gs_boldDBAlias) OR f_isEmptyString(gs_boldUser) OR f_isEmptyString(gs_boldPwd) THEN
	IF ii_connectionCount > 0 THEN this.uf_disconnect()
	gu_message.uf_unexp("Paramètres de connexion BOLD non initialisés, connexion impossible")
	return(-1)
END IF

// une seule connexion physique par objet instancié
ii_connectionCount = ii_connectionCount + 1

IF ii_connectionCount > 1 THEN
	return(1)
END IF

itr_bold.DBMS = sqlca.DBMS
itr_bold.database = gs_boldDBAlias
itr_bold.servername = gs_boldDBAlias
itr_bold.userid = gs_boldUser
itr_bold.dbpass = gs_boldPwd
itr_bold.logid = itr_bold.userid
itr_bold.logpass = itr_bold.dbpass
itr_bold.dbparm = sqlca.dbparm
connect using itr_bold;
IF f_check_sql(itr_bold) <> 0 THEN
	populateError(-20000, "")
	gu_message.uf_unexp("Erreur connexion BOLD")
	return(-1)
ELSE
	return(1)
END IF

end function

public function integer uf_getpdfcontent (string as_ndossier, ref string as_message, ref blob ab_pdfcontent);// retrieve PDF content from userDossier
// return(-1) : Data error. Error message returned in as_message.
// return(-2) : SQL error. Error message returned in as_message.
// return(1) : OK. Content returned in ab_PDFcontent. Message is empty.
blob	lb_pdf

SELECTBLOB pdfcontent INTO :lb_pdf FROM userDossier where userdossiernumber=:as_ndossier USING itr_bold;
CHOOSE CASE itr_bold.sqlCode
	CASE 0
		IF isNull(lb_pdf) OR len(lb_pdf) = 0 THEN
			as_message = "PDFcontent for " + as_ndossier + " is null."
			return(-1)
		ELSE
			ab_PDfcontent = lb_pdf
			as_message = ""
			return(1)
		END IF
	CASE 100
		as_message = "NO userDossier for " + as_ndossier + "."
		return(-1)
	CASE ELSE
		as_message = "Erreur SELECTBLOB PDFContent from userDossier " + string(itr_bold.sqlDBcode) + " - " + itr_bold.SQLErrText + "."
		return(-2)
END CHOOSE
end function

public function integer uf_getxmlcontent (string as_ndossier, ref string as_message, ref string as_xmlcontent);// retrieve XML content from userDossier
// return(-1) : Data error. Error message returned in as_message.
// return(-2) : SQL error. Error message returned in as_message.
// return(1) : OK. Content returned in as_XMLcontent. Message is empty.
string	ls_xml
blob		lb_xml

SELECT xmlcontent INTO :lb_xml FROM userDossier where userdossiernumber=:as_ndossier USING itr_bold;
CHOOSE CASE itr_bold.sqlCode
	CASE 0
		ls_xml = string(lb_xml)
		IF f_isEmptyString(ls_xml) THEN
			as_message = "XMLcontent for " + as_ndossier + " is null."
			return(-1)
		ELSE
			as_XMLcontent = ls_xml
			as_message = ""
			return(1)
		END IF
	CASE 100
		as_message = "NO userDossier for " + as_ndossier + "."
		return(-1)
	CASE ELSE
		as_message = "Erreur SELECT XMLContent from userDossier " + string(itr_bold.sqlDBcode) + " - " + itr_bold.SQLErrText + "."
		return(-2)
END CHOOSE
end function

public function integer uf_disconnect ();// Déconnexion logique de la DB BOLD.
// S'il n'y a plus de session logique en cours, on déconnecte la session physique.
// return(1) : OK
// return(-1) : erreur
IF ib_debug THEN
	is_debugtext = "Disconnect() - Initial connectionCount=" + string(ii_connectionCount) + &
						" DBalias=" + gs_boldDBAlias + " DBuser=" + gs_boldUser
	uf_logdebug()
END IF

// déconnexion logique : soustraire une unité du compteur de sessions
ii_connectionCount = ii_connectionCount - 1

// s'il n'y a plus de session logique en cours, on déconnecte la session physique, sinon on la maintient
IF ii_connectionCount <= 0 AND NOT f_isEmptyString(itr_bold.servername) THEN
	disconnect using itr_bold;
	IF f_check_sql(itr_bold) <> 0 THEN
		populateError(-20000, "")
		gu_message.uf_unexp("Erreur déconnexion BOLD")
		return(-1)
	ELSE
		return(1)
	END IF
END IF
return(1)
end function

public function integer uf_publishstatus (string as_ndossier, string as_status, ref string as_message);// Requête de modification du statut d'un dossier.
// as_ndossier : n° du dossier
// as_status : statut demandé
// return(-1) : logical error. Error message returned in as_message.
// return(-2) : SQL error. Error message returned in as_message.
// return(0) : Opération abandonnée par l'utilisateur.
// return(1) : OK. as_message is empty.

// PCO 01/02/2023 : utiliser fonction avec arguments confirmEnded, processingStatus et Details
return(this.uf_publishstatus(as_ndossier, as_status, "", "", TRUE, as_message))

end function

public function integer uf_publishattach (string as_ndossier, string as_typekey, string as_typelabel, string as_description, string as_filename, ref string as_message);// Requête de publication d'une pièce jointe à un dossier.
// as_ndossier : n° du dossier
// as_filename : pièce à joindre au dossier
// return(-1) : logical error. Error message returned in as_message.
// return(-2) : SQL error. Error message returned in as_message.
// return(1) : OK. as_message is empty.
string	ls_finalStatus, ls_ext, ls_mimeType, ls_baseName, ls_folderName, ls_data
blob		lb_fileContent
integer	li_seq, li_st
uo_fileservices	lu_fileservices

IF f_isEmptyString(as_ndossier) THEN
	as_message = "N° de dossier non mentionné"
	return(-1)
END IF

// Le dossier doit avoir le statut PROCESSING (en cours ou en attente de publication)
li_st = uf_getfinalstatus(as_ndossier, ls_finalStatus, as_message)
IF li_st < 0 THEN
	return(li_st)
END IF

CHOOSE CASE ls_finalStatus
	CASE "PROCESSING"
		
	CASE "ENDED"
		as_message = "Ce dossier est clôturé et ne peut plus être modifié"
		return(-1)
		
	CASE ELSE
		as_message = "Ce dossier n'est pas en cours de traitement, statut actuel : " + ls_finalStatus
		return(-1)
END CHOOSE

// autres vérifications
IF f_isEmptyString(as_filename) THEN
	as_message = "Nom de la pièce jointe non mentionné"
	return(-1)
END IF

IF f_isEmptyString(as_typekey) OR f_isEmptyString(as_typeLabel) THEN
	as_message = "L'identifiant technique indiquant le type d’annexe, ainsi que le libellé du type d’annexe, sont tous deux obligatoires"
END IF

IF NOT fileExists(as_filename) THEN
	as_message = "Fichier " + as_filename + " inexistant"
	return(-1)
END IF

// obtenir nom de base du fichier et son extension, ainsi que le contenu du fichier
lu_fileservices = CREATE uo_fileservices
lu_fileservices.uf_basename(as_filename, FALSE, ls_folderName, ls_baseName, ls_ext)
IF lu_fileservices.uf_readfile(as_filename, lb_fileContent) = -1 THEN
	DESTROY lu_fileservices
	as_message = "Error reading " + as_filename + " into blob variable"
	return(-2)
END IF
DESTROY lu_fileservices

// déterminer le mimeType sur base de l'extension du fichier sélectionné
ls_mimeType = uf_getMimeType(ls_ext)

select max(seq) into :li_seq from publishAttach where userDossierNumber = :as_ndossier using itr_bold;
IF isNull(li_seq) OR li_seq = 0 THEN
	li_seq = 1 
ELSE
	li_seq++
END IF

// un getUserDossier ne doit pas être en cours pour le dossier
select userdossiernumber into :ls_data from getUserDossier where userdossiernumber=:as_ndossier using itr_bold;
IF itr_bold.sqlCode = -1 THEN
	as_message = "Erreur SELECT into :ls_data " + string(itr_bold.sqlDBcode) + " - " + itr_bold.SQLErrText
	return(-2)
END IF
IF NOT f_isEmptyString(ls_data) THEN
	as_message = "Une opération getUserDossier est en attente pour ce dossier, veuillez réessayer dans quelques instants"
	return(-1)
END IF

// insérer la demande d'attachment
insert into publishAttach (userDossierNumber, seq, typekey, typelabel, filename, mimeType, description, visible, fileContent) 
	values (:as_ndossier, :li_seq, :as_typekey, :as_typeLabel, :ls_baseName, :ls_mimeType, :as_description, 'true', :lb_fileContent) 
	using itr_bold;
IF itr_bold.sqlCode = -1 THEN
	as_message = "Erreur INSERT into publishAttach " + string(itr_bold.sqlDBcode) + " - " + itr_bold.SQLErrText
	rollback using itr_bold;
	return(-2)
ELSE
	commit using itr_bold;
	return(1)
END IF
return(1)
end function

public function integer uf_inputattach (string as_ndossier, ref string as_typekey, ref string as_description, ref string as_filename);str_params	lstr_params
string		ls_finalStatus, ls_message

// Le dossier doit avoir le statut PROCESSING (en cours ou en attente de publication)
IF uf_getfinalstatus(as_ndossier, ls_finalStatus, ls_message) < 0 THEN
	gu_message.uf_Error(ls_message)
	return(-1)
END IF

CHOOSE CASE ls_finalStatus
	CASE "PROCESSING"
		
	CASE "ENDED"
		gu_message.uf_error("Ce dossier est clôturé et ne peut plus être modifié")
		return(-1)
		
	CASE ELSE
		gu_message.uf_error("Ce dossier n'est pas en cours de traitement, statut actuel : " + ls_finalStatus)
		return(-1)
END CHOOSE

// fenêtre de sélection de la pièce à joindre
lstr_params.a_param[1] = as_ndossier

openwithparm(w_bold_attachment_add, lstr_params)
IF Message.DoubleParm = -1 THEN 
	return(-1)
ELSE
	lstr_params = Message.powerobjectparm
	as_typekey = lstr_params.a_param[1]
	as_description = lstr_params.a_param[2]
	as_filename = lstr_params.a_param[3]
	return(1)
END IF

end function

public function integer uf_getallattachmentcontent (string as_ndossier, ref string as_filename[], ref blob ab_content[]);// retrieve all attachments content from userDossierAttach
// return(n) : nombre de fichiers créés
blob		lb_content
string	ls_fileName, ls_attachmentRowID
uo_ds		lds_attachmentList
long		ll_nbrows, ll_row
integer	li_created

lds_attachmentList = CREATE uo_ds
lds_attachmentList.dataObject = "d_bold_attachments_list"
lds_attachmentList.setTransObject(itr_bold)

// lire liste des fichiers attachés au dossier
ll_nbrows = lds_attachmentList.retrieve(as_ndossier)

// lire le contenu de chaque fichier
FOR ll_row = 1 TO ll_nbrows
	ls_filename = lds_attachmentList.object.fileNAme[ll_row]
	ls_attachmentRowID = lds_attachmentList.object.attachmentRowID[ll_row]
	// lecture du contenu du fichier
	SELECTBLOB fileContent INTO :lb_content FROM userDossierAttach where rowid=:ls_attachmentRowID USING itr_bold;
	IF itr_bold.sqlCode = 0 THEN
		as_filename[ll_row] = as_ndossier + "_" + ls_filename
		ab_content[ll_row] = lb_content
		li_created++
	END IF
NEXT

return(li_created)
end function

public function integer uf_writebudata (string as_ndossier, string as_description, ref string as_message);// Ecriture de la dernière opération par l'application business
// as_ndossier : n° du dossier
// as_description : description de l'opération

// return(-1) : Error. Error message returned in as_message.
// return(1) : OK. as_message is empty.
integer	li_lastDossierVersion
datetime	l_date

IF f_isEmptyString(as_ndossier) THEN
	as_message = "N° de dossier non mentionné"
	return(-1)
END IF

IF f_isEmptyString(as_description) THEN
	as_message = "La description de l'opération est obligatoire"
	return(-1)
END IF

// Lire n° de version actuelle du dossier
select lastDossierVersion into :li_lastDossierVersion
		from userDossier where userdossiernumber=:as_ndossier USING itr_bold;
CHOOSE CASE itr_bold.sqlCode
	CASE 100
		as_message = "Le dossier " + as_ndossier + " n'existe pas dans le back office DNF (BOLD)."
		return(-1)
	CASE -1
		as_message = "Erreur SELECT from userDossier " + string(itr_bold.sqlDBcode) + " - " + itr_bold.SQLErrText + "."
		return(-1)
END CHOOSE

// stocker l'info
l_date = datetime(today(), now())
delete BUDATA where userdossiernumber=:as_ndossier using itr_bold;
insert into BUDATA 
		 columns (userDossierNumber, lastOpDate, lastOpAut, lastOpDesc, lastOpDossierVersion) 
		 values  (:as_ndossier, :l_date, :gs_username, :as_description, :li_lastDossierVersion) using itr_bold;
IF itr_bold.sqlCode = -1 THEN
	as_message = "Erreur INSERT into publishRfai " + string(itr_bold.sqlDBcode) + " - " + itr_bold.SQLErrText + "."
	rollback using itr_bold;
	return(-1)
ELSE
	commit using itr_bold;
	return(1)
END IF
return(1)
end function

public function integer uf_getconnectioncount ();return(ii_connectioncount)
end function

public function integer uf_check_rfai_pending (string as_ndossier, ref string as_message);// Vérification qu'une DRC n'est pas en attente de publication ou en attente de réponse de l'utilisateur
// as_ndossier : n° du dossier
// return(-1) : RFAI pending. Message returned in as_message.
// return(-2) : SQL error. Error message returned in as_message.
// return(-3) : other error. Error message returned in as_message.
// return(1) : pas de RFAI en attente. as_message is empty.
string	ls_currentStatus, ls_processingStatus
long		ll_count

IF f_isEmptyString(as_ndossier) THEN
	as_message = "N° de dossier non mentionné"
	return(-3)
END IF

// Vérifier qu'une DRC n'est pas en attente de réponse de l'utilisateur.
CHOOSE CASE uf_getCurrentStatus(as_ndossier, ls_currentStatus, ls_processingStatus, as_message)
	CASE 1
		IF ls_processingStatus = "RFAI" THEN
			as_message = "Une DRC est en attente de réponse de l'usager pour le dossier " + as_ndossier
			return(-1)
		END IF
	CASE ELSE
		return(-2)
END CHOOSE
		
// vérifier qu'il n'y a pas une DRC en attente de publication
select count(*) into :ll_count from publishRfai where userdossiernumber=:as_ndossier USING itr_bold;
CHOOSE CASE itr_bold.sqlCode
	CASE 0
		IF ll_count > 0 THEN
			as_message = "Une DRC est en attente de soumission pour le dossier " + as_ndossier
			return(-1)
		END IF
	CASE -1
		as_message = "Erreur SELECT from publishRfai " + string(itr_bold.sqlDBcode) + " - " + itr_bold.SQLErrText + "."
		return(-2)
END CHOOSE

return(1)
end function

public function string uf_getmimetype (string as_fileext);// déterminer le mimeType sur base de l'extension du fichier
// as_fileExt : extension du fichier
// return : mimeType, ou l'extension si pas de correspondance trouvée
str_params	l_mimeTypes[]
integer		li_i

l_mimeTypes[1].a_param[1] = "pdf"
l_mimeTypes[1].a_param[2] = "application/pdf"
l_mimeTypes[2].a_param[1] = "doc"
l_mimeTypes[2].a_param[2] = "application/msword"
l_mimeTypes[3].a_param[1] = "docx"
l_mimeTypes[3].a_param[2] = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
l_mimeTypes[4].a_param[1] = "ppt"
l_mimeTypes[4].a_param[2] = "application/vnd.ms-powerpoint"
l_mimeTypes[5].a_param[1] = "pptx"
l_mimeTypes[5].a_param[2] = "application/vnd.openxmlformats-officedocument.presentationml.presentation"
l_mimeTypes[6].a_param[1] = "bmp"
l_mimeTypes[6].a_param[2] = "image/bmp"
l_mimeTypes[7].a_param[1] = "tiff"
l_mimeTypes[7].a_param[2] = "image/tiff"
l_mimeTypes[8].a_param[1] = "tif"
l_mimeTypes[8].a_param[2] = "image/tiff"
l_mimeTypes[9].a_param[1] = "pjp"
l_mimeTypes[9].a_param[2] = "image/jpeg"
l_mimeTypes[10].a_param[1] = "jpg"
l_mimeTypes[10].a_param[2] = "image/jpeg"
l_mimeTypes[11].a_param[1] = "pjpeg"
l_mimeTypes[11].a_param[2] = "image/jpeg"
l_mimeTypes[12].a_param[1] = "jpeg"
l_mimeTypes[12].a_param[2] = "image/jpeg"
l_mimeTypes[13].a_param[1] = "jfif"
l_mimeTypes[13].a_param[2] = "image/jpeg"
l_mimeTypes[14].a_param[1] = "gif"
l_mimeTypes[14].a_param[2] = "image/gif"
l_mimeTypes[15].a_param[1] = "png"
l_mimeTypes[15].a_param[2] = "image/png"
l_mimeTypes[16].a_param[1] = "xls"
l_mimeTypes[16].a_param[2] = "application/vnd.ms-excel"
l_mimeTypes[17].a_param[1] = "xlsx"
l_mimeTypes[17].a_param[2] = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
l_mimeTypes[18].a_param[1] = "gpx"
l_mimeTypes[18].a_param[2] = "application/gpx+xml"
l_mimeTypes[19].a_param[1] = "txt"
l_mimeTypes[19].a_param[2] = "text/plain"
l_mimeTypes[20].a_param[1] = "csv"
l_mimeTypes[20].a_param[2] = "text/csv"
l_mimeTypes[21].a_param[1] = "json"
l_mimeTypes[21].a_param[2] = "application/json"

FOR li_i = 1 TO upperBound(l_mimeTypes)
	IF upper(as_fileext) = upper(l_mimeTypes[li_i].a_param[1]) THEN
		return(l_mimeTypes[li_i].a_param[2])
	END IF
NEXT

return(as_fileext)
end function

public function integer uf_getattachmentcontent (string as_attachmentrowid, ref string as_message, ref string as_filename, ref blob ab_content);// retrieve attachment content from userDossierAttach
// return(-1) : Data error. Error message returned in as_message.
// return(-2) : SQL error. Error message returned in as_message.
// return(1) : OK. Filename returned in as_filename, content returned in ab_content. Message is empty.
blob		lb_content
string	ls_fileName

SELECT fileName INTO :ls_fileName FROM userDossierAttach where ROWIDTOCHAR(ROWID)=:as_attachmentrowid USING itr_bold;
CHOOSE CASE itr_bold.sqlCode
	CASE 0
		IF f_isEmptyString(ls_fileName) THEN
			as_message = "Filename not given for attached file " + as_attachmentrowid + "."
			return(-1)
		END IF
		as_filename = ls_filename
	CASE 100
		as_message = "NO data for attached file " + as_attachmentrowid + "."
		return(-1)
	CASE ELSE
		as_message = "Erreur SELECT fileName from userDossierAttach " + string(itr_bold.sqlDBcode) + " - " + itr_bold.SQLErrText + "."
		return(-2)
END CHOOSE

// lecture du contenu du fichier
SELECTBLOB fileContent INTO :lb_content FROM userDossierAttach where ROWIDTOCHAR(ROWID)=:as_attachmentrowid USING itr_bold;
CHOOSE CASE itr_bold.sqlCode
	CASE 0
		IF isNull(lb_content) OR len(lb_content) = 0 THEN
			as_message = "Content for " + as_attachmentrowid + " is null."
			return(-1)
		ELSE
			ab_content = lb_content
			as_message = ""
			return(1)
		END IF
	CASE 100
		as_message = "NO attached file for ID " + as_attachmentrowid + "."
		return(-1)
	CASE ELSE
		as_message = "Erreur SELECTBLOB fileContent from userDossierAttach " + string(itr_bold.sqlDBcode) + " - " + itr_bold.SQLErrText + "."
		return(-2)
END CHOOSE
end function

public function integer uf_getpendingattachmentcontent (string as_attachmentrowid, ref string as_message, ref string as_filename, ref blob ab_content);// retrieve attachment content from publishAttach
// return(-1) : Data error. Error message returned in as_message.
// return(-2) : SQL error. Error message returned in as_message.
// return(1) : OK. Filename returned in as_filename, content returned in ab_content. Message is empty.
blob		lb_content
string	ls_fileName

SELECT fileName INTO :ls_fileName FROM publishAttach where ROWIDTOCHAR(ROWID)=:as_attachmentrowid USING itr_bold;
CHOOSE CASE itr_bold.sqlCode
	CASE 0
		IF f_isEmptyString(ls_fileName) THEN
			as_message = "Filename not given for attached file " + as_attachmentrowid + "."
			return(-1)
		END IF
		as_filename = ls_filename
	CASE 100
		as_message = "NO data for attached file " + as_attachmentrowid + "."
		return(-1)
	CASE ELSE
		as_message = "Erreur SELECT fileName from userDossierAttach " + string(itr_bold.sqlDBcode) + " - " + itr_bold.SQLErrText + "."
		return(-2)
END CHOOSE

// lecture du contenu du fichier
SELECTBLOB fileContent INTO :lb_content FROM publishAttach where ROWIDTOCHAR(ROWID)=:as_attachmentrowid USING itr_bold;
CHOOSE CASE itr_bold.sqlCode
	CASE 0
		IF isNull(lb_content) OR len(lb_content) = 0 THEN
			as_message = "Content for " + as_attachmentrowid + " is null."
			return(-1)
		ELSE
			ab_content = lb_content
			as_message = ""
			return(1)
		END IF
	CASE 100
		as_message = "NO attached file for ID " + as_attachmentrowid + "."
		return(-1)
	CASE ELSE
		as_message = "Erreur SELECTBLOB fileContent from userDossierAttach " + string(itr_bold.sqlDBcode) + " - " + itr_bold.SQLErrText + "."
		return(-2)
END CHOOSE
end function

public function integer uf_getpendingstatus (string as_ndossier, ref string as_pendingstatus, ref string as_message);// Renvoie le statut en attente de publication
// as_ndossier : n° du dossier
// as_pendingStatus : statut en attente ou vide s'il n'y en a pas
// return(-2) : SQL error. Error message returned in as_message.
// return(1) : OK. as_message is empty. Statuses returned bey REF.
// return(0) : pas de modification de statut en attente

select userDossierStatus into :as_pendingstatus
	from publishStatus where userdossiernumber=:as_ndossier USING itr_bold;

CHOOSE CASE itr_bold.sqlCode
	CASE 0
		return(1)
	CASE 100
		return(0)
	CASE -1
		as_message = "Erreur SELECT from publishStatus " + string(itr_bold.sqlDBcode) + " - " + itr_bold.SQLErrText + "."
		return(-2)
END CHOOSE
return(1)
end function

public function integer uf_getfinalstatus (string as_ndossier, ref string as_finalstatus, ref string as_message);// Renvoie le statut finale en tenant compte de l'éventuel statut en attente de publication
// as_ndossier : n° du dossier
// as_pendingStatus : statut en attente ou vide s'il n'y en a pas
// return(<0) : error. Error message returned in as_message.
// return(1) : OK. as_message is empty. Statuses returned bey REF.
integer	li_st
string	ls_currentStatus, ls_processingStatus, ls_pendingStatus, ls_message

// 1. get pending status
li_st = uf_getPendingStatus(as_ndossier, ls_pendingStatus, ls_message)
IF li_st < 0 THEN
	gu_message.uf_Error(ls_message)
	return(li_st)
END IF

// 2. get currentStatus
li_st = uf_getCurrentStatus(as_ndossier, ls_currentStatus, ls_processingStatus, ls_message)
IF li_st < 0 THEN
	gu_message.uf_Error(ls_message)
	return(li_st)
END IF

// 3. set final status
IF NOT f_isEmptyString(ls_pendingStatus) THEN
	as_finalStatus = ls_pendingStatus
ELSE
	as_finalStatus = ls_currentStatus
END IF
return(1)
end function

public function integer uf_getcurrentstatus (string as_ndossier, ref string as_currentstatus, ref string as_processingstatus, ref string as_message);// Renvoie currentStatus et processingStatus
// as_ndossier : n° du dossier
// return(-2) : SQL error ou dossier inexistant. Error message returned in as_message.
// return(1) : OK. as_message is empty. Statuses returned bey REF.

select currentStatus, processingStatus into :as_currentStatus, :as_processingstatus
	from userDossier where userdossiernumber=:as_ndossier USING itr_bold;

CHOOSE CASE itr_bold.sqlCode
	CASE 0
		return(1)
	CASE 100
		as_message = "Le dossier " + as_ndossier + " n'existe pas dans le back office DNF (BOLD)."
		return(-2)
	CASE -1
		as_message = "Erreur SELECT from userDossier " + string(itr_bold.sqlDBcode) + " - " + itr_bold.SQLErrText + "."
		return(-2)
END CHOOSE
return(1)
end function

public subroutine uf_logdebug ();gu_logmessage.uf_logmessage(is_debugFile, string(today(), "dd/mm/yyyy hh:mm") + &
		" " + gs_userName + " - " + is_debugText, 500, FALSE)
end subroutine

public function integer uf_getvalue (string as_ndossier, string as_fieldname, ref any aa_value, ref string as_message);// retrieve field value from userDossier
// return(-1) : Data error. Error message returned in as_message.
// return(-2) : SQL error. Error message returned in as_message.
// return(1) : OK. Content returned in aa_value. Message is empty.
string	ls_value, ls_selectField
string	ls_sql

CHOOSE CASE upper(as_fieldname)
	CASE "CREATIONDATE", "MODIFICATIONDATE", "SUBMISSIONDATE"
		ls_selectField = "to_char(" + as_fieldname + ", 'dd/mm/yyyy hh24:mm:ss')"
	CASE ELSE
		ls_selectField = as_fieldname
END CHOOSE

ls_sql = "SELECT " + ls_selectField + " FROM userDossier where userdossiernumber='" + as_ndossier + "'"
DECLARE my_cursor DYNAMIC CURSOR FOR SQLSA;
PREPARE SQLSA FROM :ls_sql using itr_bold;
OPEN DYNAMIC my_cursor;
FETCH my_cursor INTO :ls_value;
CLOSE my_cursor;

CHOOSE CASE itr_bold.sqlCode
	CASE 0
		IF f_isEmptyString(ls_value) THEN
			as_message = as_fieldname + " for " + as_ndossier + " is null."
			return(-1)
		ELSE
			aa_value = ls_value
			as_message = ""
			return(1)
		END IF
	CASE 100
		as_message = "NO userDossier for " + as_ndossier + "."
		return(-1)
	CASE ELSE
		as_message = "Erreur " + ls_sql + " : " + string(itr_bold.sqlDBcode) + " - " + itr_bold.SQLErrText + "."
		return(-2)
END CHOOSE
end function

public function integer uf_inputcancelrfai (string as_ndossier, ref string as_justif);// Annulation d'une RFAI : introduction motif et confirmation
integer		li_st
str_params	lstr_params
string		ls_currentStatus, ls_processingStatus, ls_message

// Le dossier doit avoir PROCESSINGSTATUS=RFAI
li_st = uf_getcurrentstatus(as_ndossier, ls_currentStatus, ls_processingStatus, ls_message)
IF li_st < 0 THEN
	gu_message.uf_Error(ls_message)
	return(li_st)
END IF

IF ls_currentStatus <> "PROCESSING" OR isNull(ls_processingStatus) OR ls_processingStatus <> "RFAI" THEN
	gu_message.uf_Error("Pas de DRC en cours pour ce dossier")
	return(-1)
END IF

// fenêtre de saisie de l'annulation de la DRC
lstr_params.a_param[1] = as_ndossier

openwithparm(w_bold_drc_cancel, lstr_params)
IF Message.DoubleParm = -1 THEN 
	return(-1)
ELSE
	// récupérer les données introduites
	lstr_params = Message.powerobjectparm
	as_justif = lstr_params.a_param[1]
	return(1)
END IF

end function

public function integer uf_publishcancelrfai (string as_ndossier, string as_justif, ref string as_message);// Annulation d'une DRC (demande de renseignement complémentaire)
// Le dossier doit avoir PROCESSINGSTATUS=RFAI (DRC en cours, pas en attente de publication)
// as_ndossier : n° du dossier
// as_justification : justification de l'annulation (facultatif)

// return(-1) : logical error. Error message returned in as_message.
// return(-2) : SQL error. Error message returned in as_message.
// return(1) : OK. as_message is empty.
string	ls_currentStatus, ls_processingStatus, ls_data
boolean	lb_confirmEnded
integer	li_st

IF f_isEmptyString(as_ndossier) THEN
	as_message = "N° de dossier non mentionné"
	return(-1)
END IF

// Le dossier doit avoir PROCESSINGSTATUS=RFAI
li_st = uf_getcurrentstatus(as_ndossier, ls_currentStatus, ls_processingStatus, as_message)
IF li_st < 0 THEN
	return(li_st)
END IF

IF ls_processingStatus <> "RFAI" THEN
	as_message = "Pas de DRC en cours pour ce dossier"
	return(-1)
END IF

// publier le changement de statut
setNull(lb_confirmEnded)
li_st = uf_publishStatus(as_ndossier, "PROCESSING", "CANCELLED_RFAI", as_justif, lb_confirmEnded, as_message)

// cancel RFAI published
return(li_st)

end function

public function long uf_getlistdossier (string as_where, ref uo_ds ads_listdossier, ref string as_message);// Renvoie liste de dossiers répondant aux critères fournis en argument
// as_where : critères de recherche
// ads_listdossier : liste des dossiers trouvés. DataObject renvoyé sera du type ds_listDossier.
// return(-1) : error. Error message returned in as_message.
// return(0~n) : OK. Nombre de dossiers trouvés. as_message is empty.
string	ls_sql
long		ll_nbrows
integer	li_st

IF NOT isValid(ads_listDossier) THEN
	as_message = "Target dataObject must be created before calling bold.uf_getlistdossier function"
	return(-1)
END IF

ads_listDossier.dataObject = "ds_listDossier" 
ads_listDossier.setTransObject(itr_bold)
ls_sql = ads_listDossier.getsqlselect()

// assigner critères de recherche
ls_sql = f_modifySql(ls_sql, as_where, "", "")
IF ads_listDossier.setsqlselect(ls_sql) = -1 THEN
	as_message = "Error ads_listDossier.setsqlselect() : " + ls_sql
	return(-1)
END IF

// lecture des dossiers
ll_nbrows = ads_listDossier.retrieve()
IF ll_nbrows = -1 THEN
	as_message = "Erreur ads_listDossier.retrieve()"
	return(-1)
ELSE
	return(ll_nbrows)
END IF

end function

public function integer uf_inputrfai (string as_ndossier, ref string as_subject, ref string as_description, ref date adt_expirydate, ref str_params astr_target[]);// Saisie d'une DRC
integer		li_st
str_params	lstr_params
string		ls_currentStatus, ls_processingStatus, ls_pendingStatus, ls_message

// Le dossier doit avoir le statut PROCESSING (en cours, pas en attente de publication)
li_st = uf_getCurrentStatus(as_ndossier, ls_currentStatus, ls_processingStatus, ls_message)
IF li_st < 0 THEN
	gu_message.uf_Error(ls_message)
	return(li_st)
END IF

// Voir s'il y a une modification de statut en attente de publication
li_st = uf_getPendingStatus(as_ndossier, ls_pendingStatus, ls_message)
IF li_st < 0 THEN
	gu_message.uf_Error(ls_message)
	return(li_st)
END IF

// NB : la fonction uf_getFinalStatus renverrait PROCESSING alors que ce statut est en attente de publication
//      et que le statut courant est RECEIVED. Si une RFAI suit trop vite le changement de status, 
//      cela peut provoquer une erreur due à une "race condition". On ne l'utilise donc pas.

CHOOSE CASE ls_currentStatus
	// statut en cours est PROCESSING mais en attente de ENDED : plus de RFAI possible.
	CASE "PROCESSING"
		IF ls_pendingStatus = "ENDED" THEN
			gu_message.uf_error("Ce dossier va être clôturé et ne peut plus être modifié")
			return(-1)
		END IF
		
	CASE "ENDED"
		gu_message.uf_error("Ce dossier est clôturé et ne peut plus être modifié")
		return(-1)
		
	CASE ELSE
		gu_message.uf_error("Ce dossier n'est pas en cours de traitement, statut actuel : " + ls_currentStatus)
		return(-1)
END CHOOSE

// vérifier qu'il n'y aucune RFAI en attente de publication ou de réponse de l'utilisateur
CHOOSE CASE uf_check_rfai_pending(as_ndossier, ls_message)
	CASE -1
		gu_message.uf_error(ls_message)
		return(-1)
	CASE -2
		gu_message.uf_Error(ls_message)
		return(-1)
END CHOOSE

// fenêtre de saisie de la DRC
lstr_params.a_param[1] = as_ndossier

openwithparm(w_bold_drc_add, lstr_params)
IF Message.DoubleParm = -1 THEN 
	return(-1)
ELSE
	// récupérer les données introduites
	lstr_params = Message.powerobjectparm
	as_subject = lstr_params.a_param[1]
	as_description = lstr_params.a_param[2]
	adt_expiryDate = lstr_params.a_param[3]
	// target(s) éventuel(s)
	astr_target = lstr_params.a_param[4]
	return(1)
END IF

end function

public function integer uf_publishrfai (string as_ndossier, string as_subject, string as_description, date adt_expirydate, str_params astr_target[], ref string as_message);// Introduction d'une DRC (demande de renseignement complémentaire)
// NB : pas de pièce jointe prévue.
// as_ndossier : n° du dossier
// as_subject : sujet de la DRC
// as_description : description de la DRC
// astr_target : liste (optionnelle) des formulaires ou pièces jointes concernées par la DRC

// return(-1) : logical error. Error message returned in as_message.
// return(-2) : SQL error. Error message returned in as_message.
// return(1) : OK. as_message is empty.
string	ls_currentStatus, ls_processingStatus, ls_pendingStatus, ls_attachType, ls_id, ls_name, ls_data
long		ll_count
integer	li_st, li_i

IF f_isEmptyString(as_ndossier) THEN
	as_message = "N° de dossier non mentionné"
	return(-1)
END IF

IF f_isEmptyString(as_subject) THEN
	as_message = "Le sujet de la DRC est obligatoire"
	return(-1)
END IF

IF f_isEmptyString(as_description) THEN
	as_message = "La description de la DRC est obligatoire"
	return(-1)
END IF

// Le dossier doit avoir le statut PROCESSING (en cours, pas en attente de publication)
li_st = uf_getCurrentStatus(as_ndossier, ls_currentStatus, ls_processingStatus, as_message)
IF li_st < 0 THEN
	return(-1)
END IF

// Vois si modification de statut en attente
li_st = uf_getPendingStatus(as_ndossier, ls_pendingStatus, as_message)
IF li_st < 0 THEN
	return(-1)
END IF

// NB : la fonction uf_getFinalStatus renverrait PROCESSING alors que ce statut est en attente de publication
//      et que le statut courant est RECEIVED. Si une RFAI suit trop vite le changement de status, 
//      cela peut provoquer une erreur due à une "race condition". On ne l'utilise donc pas.

CHOOSE CASE ls_currentStatus
	CASE "PROCESSING"
		IF ls_pendingStatus = "ENDED" THEN
			gu_message.uf_error("Ce dossier va être clôturé et ne peut plus être modifié")
			return(-1)
		END IF
		
	CASE "ENDED"
		as_message = "Ce dossier est clôturé et ne peut plus être modifié"
		return(-1)
		
	CASE ELSE
		as_message = "Ce dossier n'est pas en cours de traitement, statut actuel : " + ls_currentStatus
		return(-1)
END CHOOSE


// vérifier qu'il n'y aucune RFAI en attente de publication ou de réponse de l'utilisateur
li_st = uf_check_rfai_pending(as_ndossier, as_message)
IF li_st <> 1 THEN
	return(li_st)
END IF

// un getUserDossier ne doit pas être en cours pour le dossier
select userdossiernumber into :ls_data from getUserDossier where userdossiernumber=:as_ndossier using itr_bold;
IF itr_bold.sqlCode = -1 THEN
	as_message = "Erreur SELECT into :ls_data " + string(itr_bold.sqlDBcode) + " - " + itr_bold.SQLErrText
	return(-2)
END IF
IF NOT f_isEmptyString(ls_data) THEN
	as_message = "Une opération getUserDossier est en attente pour ce dossier, veuillez réessayer dans quelques instants"
	return(-1)
END IF

// insérer la DRC
insert into publishRfai (userDossierNumber, subject, description, expiryDate) 
		 values (:as_ndossier, :as_subject, :as_description, :adt_expiryDate) using itr_bold;
IF itr_bold.sqlCode = -1 THEN
	as_message = "Erreur INSERT into publishRfai " + string(itr_bold.sqlDBcode) + " - " + itr_bold.SQLErrText
	rollback using itr_bold;
	return(-2)
END IF

// insérer les targets de la DRC
FOR li_i = 1 TO upperBound(astr_target)
	ls_attachType = astr_target[li_i].a_param[1]
	ls_id = astr_target[li_i].a_param[2]
	ls_name = astr_target[li_i].a_param[3]
	
	insert into targetRfai (userDossierNumber, attachType, targetID, targetName) 
			 values (:as_ndossier, :ls_attachType, :ls_id, :ls_name) using itr_bold;
	IF itr_bold.sqlCode = -1 THEN
		as_message = "Erreur INSERT into targetRfai " + string(itr_bold.sqlDBcode) + " - " + itr_bold.SQLErrText
		rollback using itr_bold;
		return(-2)
	END IF
NEXT

commit using itr_bold;

return(1)

end function

public function integer uf_publishstatus (string as_ndossier, string as_status, boolean ab_confirmended, ref string as_message);// Requête de modification du statut d'un dossier.
// as_ndossier : n° du dossier
// as_status : statut demandé
// ab_confirmEnded : demande confirmation ou pas en cas de demande de clôture. TRUE/FALSE/NULL (s/o si statut demandé différent de ENDED)
// return(-1) : logical error. Error message returned in as_message.
// return(-2) : SQL error. Error message returned in as_message.
// return(0) : Opération abandonnée par l'utilisateur.
// return(1) : OK. as_message is empty.

// PCO 01/02/2023 : utiliser fonction avec arguments confirmEnded, processingStatus et Details
return(this.uf_publishstatus(as_ndossier, as_status, "", "", ab_confirmEnded, as_message))

end function

public function integer uf_publishstatus (string as_ndossier, string as_userdossierstatus, string as_processingstatus, string as_details, boolean ab_confirmended, ref string as_message);// Requête de modification du statut d'un dossier.
// as_ndossier : n° du dossier
// as_userdossierstatus : nouveau statut demandé
// as_processingstatus : nouveau processingStatus demandé
// ab_confirmEnded : demande confirmation ou pas en cas de demande de clôture. TRUE/FALSE/NULL (s/o si statut demandé différent de ENDED)
// return(-1) : logical error. Error message returned in as_message.
// return(-2) : SQL error. Error message returned in as_message.
// return(0) : Opération abandonnée par l'utilisateur.
// return(1) : OK. as_message is empty.
string	ls_currentStatus, ls_processingStatus, ls_data
long		ll_count
integer	li_st

IF f_isEmptyString(as_ndossier) THEN
	as_message = "N° de dossier non mentionné"
	return(-1)
END IF

as_userdossierstatus = upper(as_userdossierstatus)

// seuls statuts autorisés
IF as_userdossierstatus <> "PROCESSING" AND as_userdossierstatus <> "RECEIVED" AND as_userdossierstatus <> "ENDED" THEN
	as_message = "Status demandé " + as_userdossierstatus + " non valide"
	return(-1)
END IF

// vérifier qu'il n'y a pas une autre demande de changement de statut en attente
select count(*) into :ll_count from publishStatus where userdossiernumber=:as_ndossier USING itr_bold;
CHOOSE CASE itr_bold.sqlCode
	CASE 0
		IF ll_count > 0 THEN
			as_message = "Une demande de changement de statut est déjà en attente de publication pour le dossier " + as_ndossier
			return(-1)
		END IF
	CASE -1
		as_message = "Erreur SELECT from publishStatus " + string(itr_bold.sqlDBcode) + " - " + itr_bold.SQLErrText + "."
		return(-2)
END CHOOSE

// demande de clôture : vérifier qu'il n'y a pas de RFAI en attente de publication ou de réponse de l'usager
IF as_userdossierstatus = "ENDED" THEN
	li_st = uf_check_rfai_pending(as_ndossier, as_message)
	IF li_st <> 1 THEN
		return(li_st)
	END IF
END IF

// Vérifier compatibilité statut en cours / statut demandé
CHOOSE CASE uf_getCurrentStatus(as_ndossier, ls_currentStatus, ls_processingStatus, as_message)
	CASE 1
		// statut PROCESSING : reste au même statut mais on peut modifier PROCESSINGSTATUS si on souhaite 
		// créer des sous-étapes ou annuler une DRC
		IF as_userdossierstatus = ls_currentStatus AND &
				(ls_currentStatus <> "PROCESSING" OR &
				 (ls_currentStatus = "PROCESSING" AND f_isEmptyString(as_processingstatus)) &
				) THEN
			as_message = "Le dossier " + as_ndossier + " est déjà dans le statut " + ls_currentStatus
			return(-1)
		END IF
		
		// dossier clôturé : ne peut plus être modifié
		IF ls_currentStatus = "ENDED" OR ls_currentStatus = "CANCELLED" THEN
			as_message = "Le dossier " + as_ndossier + " est clôturé ou annulé, son statut ne peut plus être modifié."
			return(-1)
		END IF
		
		// autres vérifications de compatibilité
		as_message = "Le dossier " + as_ndossier + " est " + ls_currentStatus + ", son statut ne peut devenir " + as_userdossierstatus + "."
		CHOOSE CASE as_userdossierstatus
			CASE "RECEIVED"
				IF ls_currentStatus <> "SUBMITTED" THEN
					return(-1)
				END IF
			CASE "PROCESSING"
				IF ls_currentStatus <> "RECEIVED" AND ls_currentStatus <> "PROCESSING" THEN
					return(-1)
				END IF
				IF NOT f_isEmptyString(as_processingstatus) AND as_processingstatus <> "CANCELLED_RFAI" THEN
					return(-1)
				END IF
			CASE "ENDED"
				IF ls_currentStatus <> "PROCESSING" THEN
					return(-1)
				END IF
		END CHOOSE
		
	// situation d'erreur
	CASE ELSE
		return(-2)
END CHOOSE

// demande de clôture : demander confirmation si l'argument ab_confirmEnded vaut TRUE
IF as_userdossierstatus = "ENDED" AND ab_confirmEnded THEN
	IF gu_message.uf_query("Clôture de dossier", "Confirmez-vous la clôture du dossier " + as_ndossier + " ?", YesNo!, 2) = 2 THEN
		as_message = "Opération abandonnée"
		return(0)
	END IF
END IF

// un getUserDossier ne doit pas être en cours pour le dossier
select userdossiernumber into :ls_data from getUserDossier where userdossiernumber=:as_ndossier using itr_bold;
IF itr_bold.sqlCode = -1 THEN
	as_message = "Erreur SELECT into :ls_data " + string(itr_bold.sqlDBcode) + " - " + itr_bold.SQLErrText
	return(-2)
END IF
IF NOT f_isEmptyString(ls_data) THEN
	as_message = "Une opération getUserDossier est en attente pour ce dossier, veuillez réessayer dans quelques instants"
	return(-1)
END IF

// insérer la demande de changement
insert into publishStatus (userDossierNumber, userDossierStatus, processingStatus, details) 
	values (:as_ndossier, :as_userdossierstatus, :as_processingStatus, :as_details) using itr_bold;
IF itr_bold.sqlCode = -1 THEN
	as_message = "Erreur INSERT into publishStatus " + string(itr_bold.sqlDBcode) + " - " + itr_bold.SQLErrText
	rollback using itr_bold;
	return(-2)
ELSE
	commit using itr_bold;
	return(1)
END IF
return(1)
end function

public function integer uf_scrolltodossier (string as_ndossier);// Depuis autre programme : ouvrir la fenêtre BOLD et se positionner sur le dossier passé en argument.
// Si le dossier est au statut ENDED, modifier boutons de masquage des dossiers clôturés pour que les dossiers clôturés soient affichés.
// return(-1) : le dossier n'existe pas
// return(1) : le dossier existe.
string	ls_currentStatus, ls_procedureRef, ls_message, ls_filter_pRef, ls_choixListe, ls_choix[]

IF f_isEmptyString(as_ndossier) THEN
	return(-1)
END IF

// Ouvrir fenêtre principale BOLD
IF NOT IsValid(w_userdossier) THEN
	OpenSheet(w_userdossier, gw_mdiframe, 0, Original!)
END IF
IF IsValid(w_userdossier) THEN
	IF w_userdossier.wf_getStatus(as_ndossier, ls_currentStatus) THEN
		w_userdossier.SetFocus()
		
		// PCO 19/02/2024 : comparer les types de dossiers que l'utilisateur a choisi de voir et le type du dossier 
		// à mettre en évidence. Si l'utilisateur a choisi de ne pas voir ce type de dossier, 
		// un message est affiché.
		IF NOT uf_inChoosenProcRef(as_ndossier) THEN
			gu_message.uf_info("Ce type de démarche ne figure pas dans celles " + &
				"que vous avez choisies. Modifiez votre sélection " + &
				"si vous souhaitez mettre ce dossier en évidence (bouton 'Choix').")
			return(-1)
		END IF

		// si le dossier est clôturé, modifier bouton de masquage des dossiers clôturés pour que les dossiers clôturés soient affichés
		IF ls_currentStatus = "ENDED" THEN
			w_userdossier.wf_setmaskbuttons(FALSE, TRUE)
		END IF

		// PCO 19/02/2024 : modifier les filtres pour que le dossier demandé soit visible
		// 1. Retrouver l'identifiant de la démarche (procedureRef) du dossier.
		IF uf_getprocedureref(as_ndossier, ls_procedureRef, ls_message) <> 1 THEN
			return(-1)
		END IF
		// 2. activer filtre sur le type de dossier
		w_userdossier.dw_filter.object.n_pRef[1] = long(ls_procedureref)
		// 3. annuler les fitres sauf le type de dossier
		w_userdossier.post wf_resetfilter_exceptpref()
		
		// filtrer et positionner sur le dossier
		w_userdossier.post wf_filter(as_ndossier)
	ELSE
		gu_message.uf_info("Dossier " + as_ndossier + " inexistant dans BOLD.")
		return(-1)
	END IF
END IF
return(1)

end function

public function integer uf_getprocedureref (string as_ndossier, ref string as_procedureref, ref string as_message);// Renvoie le n° de démarche (procedureRef)
// as_ndossier : n° du dossier
// return(-2) : SQL error ou dossier inexistant. Error message returned in as_message.
// return(1) : OK. as_message is empty. as_procedureRef returned bey REF.

select procedureRef into :as_procedureRef
	from userDossier where userdossiernumber=:as_ndossier USING itr_bold;

CHOOSE CASE itr_bold.sqlCode
	CASE 0
		return(1)
	CASE 100
		as_message = "Le dossier " + as_ndossier + " n'existe pas dans le back office DNF (BOLD)."
		return(-2)
	CASE -1
		as_message = "Erreur SELECT from userDossier " + string(itr_bold.sqlDBcode) + " - " + itr_bold.SQLErrText + "."
		return(-2)
END CHOOSE
return(1)
end function

public function integer uf_publishgetuserdossier (string as_ndossier, integer ai_version, ref string as_message);// Requête de demande d'importation d'un dossier depuis MonEspace
// NB : le dossier ne doit pas nécessairement déjà exister dans BOLD.
// as_ndossier : n° du dossier
// ai_version : version du dossier ou vide (0 ou null) pour la dernière version 
// return(-1) : logical error. Error message returned in as_message.
// return(-2) : SQL error. Error message returned in as_message.
// return(1) : OK. as_message is empty.
integer	li_seq, li_st
long		ll_count
string	ls_data

IF f_isEmptyString(as_ndossier) THEN
	as_message = "N° de dossier non mentionné"
	return(-1)
END IF

IF ai_version=0 OR ai_version >= 100 THEN
	setNull(ai_version)
END IF

// Une demande du même type ne doit pas déjà être en cours
select count(*) into :ll_count from getUserDossier where userDossierNumber = :as_ndossier using itr_bold;
IF itr_bold.sqlCode = -1 THEN
	as_message = "Erreur select from getUserDossier " + string(itr_bold.sqlDBcode) + " - " + itr_bold.SQLErrText + "."
	return(-1)
END IF
IF ll_count > 0 THEN
	as_message = "Une demande d'importation est déjà en attente pour ce dossier"
	return(-1)
END IF

// un autre type de publication ne doit pas être en cours pour le dossier
select userdossiernumber into :ls_data from
(select userdossiernumber from publishStatus where userdossiernumber=:as_ndossier
union
select userdossiernumber from publishAttach where userdossiernumber=:as_ndossier
union
select userdossiernumber from publishRfai where userdossiernumber=:as_ndossier)
using itr_bold;
IF itr_bold.sqlCode = -1 THEN
	as_message = "Erreur SELECT into :ls_data " + string(itr_bold.sqlDBcode) + " - " + itr_bold.SQLErrText
	return(-2)
END IF
IF NOT f_isEmptyString(ls_data) THEN
	as_message = "Une opération est déjà en attente pour ce dossier, veuillez réessayer dans quelques instants"
	return(-1)
END IF

// insérer la demande d'importation
insert into getuserdossier (userdossiernumber, userdossierversion) values (:as_ndossier, :ai_version) using itr_bold;
IF itr_bold.sqlCode = -1 THEN
	as_message = "Erreur INSERT into getUserDossier " + string(itr_bold.sqlDBcode) + " - " + itr_bold.SQLErrText
	rollback using itr_bold;
	return(-2)
ELSE
	commit using itr_bold;
	return(1)
END IF

return(1)
end function

public function integer uf_inputgetuserdossier (ref string as_ndossier, ref integer ai_version, ref string as_message);// Publie vers l'ESB une demande de renvoyer le dossier spécifié en argument.
// NB : le dossier ne doit pas nécessairement déjà exister dans BOLD.
// as_ndossier : n° du dossier
// ai_version : version du dossier à recharger. Si pas de version : la dernière version est rechargée.
// return(0) : opération abandonnée.
// return(-1) : SQL error. Error message returned in as_message.
// return(1) : OK. as_message is empty. Statuses returned bey REF.
str_params	lstr_params
string		ls_message

// fenêtre de saisie du n° de dossier et version
lstr_params.a_param[1] = as_ndossier
openwithparm(w_bold_getUserDossier, lstr_params)
IF Message.DoubleParm = -1 THEN 
	return(-1)
ELSE
	// récupérer les données introduites
	lstr_params = Message.powerobjectparm
	as_ndossier = lstr_params.a_param[1]
	ai_version = integer(lstr_params.a_param[2])
	return(1)
END IF

end function

public function boolean uf_inchoosenprocref (string as_ndossier);// Vérifier si le dossier passé en argument correspond à un type de démarche que l'utilisateur
// a choisi de visualiser.
// return(TRUE) : 
//			1. l'utilisateur n'a pas réalisé de selection de démarche.
//			2. l'utilisateur a réalisé une sélection qui ne contient pas le type de démarche du dossier
//			3. en cas d'erreur, afin de ne pas tenir compte du test sur la sélection du type de démarche
// return(FALSE) : l'utilisateur a réalisé une sélection de démarche qui ne reprend
//				pas la démarche du dossier en cours.
string	ls_data, ls_message, ls_procedureref, ls_choix[], ls_demconfig[], ls_dem[], ls_pRef[]
integer	li_i, li_j

// 1. Lecture du choix de l'utilisateur des démarches visibles dans le .ini local.
//    Si aucun choix paramétré par l'utilisateur, pas de test sur ce qu'il a paramétré.
ls_data = profileString(gs_locinifile, gs_username, "BOLD_DEMARCHES_CHOISIES", "")
IF f_isEmptyString(ls_data) THEN
	return(TRUE)
END IF
// ls_choix : array contenant les démarches sélectionnées par l'utilisateur,
// sous la forme "nom du programme de gestion". Par ex. w_prelevcyne, w_balisage...
f_parse(ls_data, ",", ls_choix)

// 2. Retrouver l'identifiant de la démarche (procedureRef).
IF uf_getprocedureref(as_ndossier, ls_procedureRef, ls_message) <> 1 THEN
	return(TRUE)
END IF

// 3. Lire la liste des démarches gérées par BOLD dans l'application.
//    La config dans le .ini est structurée comme suit : nom_programme~nom_démarche;nom_programme~nom_démarche;...
ls_data = profileString(gs_inifile, "BOLD", "list", "")
IF f_isEmptyString(ls_data) THEN
	return(TRUE)
END IF
f_parse(ls_data, ";", ls_demconfig)

// 4. Isoler le nom du programme (par ex. w_balisage) pour chaque config
FOR li_i = 1 TO upperBound(ls_demconfig)
	f_parse(ls_demconfig[li_i], "~~", ls_dem)
	// 5. Retrouver la liste des ProcedureRef (identifiants des types de dossiers dans le NEP)
	ls_data = profileString(gs_inifile, "BOLD", ls_dem[1], "")
	f_parse(ls_data, ',', ls_pRef)
	// 6. Le procedureRef du dossier fait-il partie des procedureRef de la boucle en cours ?
	IF gu_stringservices.uf_SearchInArray(ls_pRef, ls_procedureRef) > 0 THEN
		// 7. Le type de démarche de la boucle en cours a été choisi par l'utilisateur
		IF gu_stringservices.uf_SearchInArray(ls_choix, ls_dem[1]) > 0 THEN
			return(TRUE)
		ELSE
			// L'utilisateur a sélectionné certains types de démarches et le type de démarche du dossier 
			// ne figure pas dans celles-ci.
			return(FALSE)
		END IF
	END IF
NEXT

return(FALSE)
end function

on uo_bold.create
call super::create
TriggerEvent( this, "constructor" )
end on

on uo_bold.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

event constructor;IF upper(profileString(gs_locinifile, "misc", "bold_debug", "false")) = "TRUE" THEN
	ib_debug = true
ELSE
	ib_debug = false
END IF
is_debugFile = gs_cenpath + "\" + "boldDebug.log"

itr_bold = CREATE transaction
ii_connectionCount = 0

end event

event destructor;rollback using itr_bold;
disconnect using itr_bold;
DESTROY itr_bold
ii_connectionCount = 0

IF ib_debug THEN
	is_debugtext = "destructor - ii_connectionCount=" + string(ii_connectionCount) + &
						" DBalias=" + gs_boldDBAlias + " DBuser=" + gs_boldUser
	uf_logdebug()
END IF
end event

