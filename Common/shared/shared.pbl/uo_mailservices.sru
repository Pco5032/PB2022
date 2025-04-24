forward
global type uo_mailservices from nonvisualobject
end type
end forward

global type uo_mailservices from nonvisualobject
end type
global uo_mailservices uo_mailservices

type variables
mailSession 	im_session
boolean			ib_displayInfo
end variables

forward prototypes
public function integer uf_checkmailsession ()
public function integer uf_maillogon ()
public function integer uf_maillogoff ()
public function integer uf_sendmail (string as_subject, string as_body, string as_to[], string as_attach[])
public function integer uf_sendmail_ole (string as_subject, string as_body, string as_to[], string as_attach[])
public function integer uf_sendmail_mapi (string as_subject, string as_body, string as_to[], string as_attach[])
public function integer uf_sendmail_ews (string as_subject, string as_body, string as_to, string as_attach)
public function string uf_meeting_ole_send (string as_id, string as_subject, string as_body, string as_location, date a_startdate, time a_starttime, date a_enddate, time a_endtime, boolean ab_allday, long al_duration, string as_destinataires[])
public function boolean uf_meeting_ole_exists (string as_id)
public function integer uf_meeting_ole_delete (string as_outlookid)
public subroutine uf_setdisplayinfo (boolean ab_displayinfo)
public function string uf_activity_ole_send (string as_id, string as_subject, string as_body, string as_location, date a_startdate, time a_starttime, date a_enddate, time a_endtime, boolean ab_allday, long al_duration, string as_destinataire)
public function integer uf_check_modifyplanning (string as_destinataire)
end prototypes

public function integer uf_checkmailsession ();// vérification de la possibilité d'utiliser les services MAPI
// return(1) si OK, (-1) si erreur

mailReturnCode lm_rtc
integer	li_status

li_status = uf_maillogon()
IF li_status = 1 THEN 
	im_session.mailLogoff()
ELSE
	DESTROY im_session
END IF
return(li_status)
end function

public function integer uf_maillogon ();// connexion aux services MAPI
// return(1) si OK, (-1) si erreur

mailReturnCode lm_rtc

im_session = CREATE mailSession
lm_rtc = im_session.mailLogon()
IF lm_rtc = mailReturnSuccess! THEN
	return(1)
ELSE
	gu_message.uf_error("Erreur Mail", "Echec de la connexion à la mailbox")
	DESTROY im_session
	return(-1)
END IF

end function

public function integer uf_maillogoff ();// déconnexion des services MAPI
// return(1) si OK, (-1) si erreur

mailReturnCode lm_rtc

lm_rtc = im_session.maillogoff()
IF lm_rtc = mailReturnSuccess! THEN
	DESTROY im_session
	return(1)
ELSE
	gu_message.uf_error("Erreur Mail", "Echec de la déconnexion à la mailbox")
	DESTROY im_session
	return(-1)
END IF

end function

public function integer uf_sendmail (string as_subject, string as_body, string as_to[], string as_attach[]);// PCO 06/12/2018 : envoi mail via EWS au lieu de MAPI cause passage Office 365
// PCO 27/10/2020 : choix envoi par EWS ou OLE selon paramétrage .INI par PC. Par défaut : technique OLE.
string	ls_to, ls_attach, ls_methode
integer	li_i

ls_methode = profileString(gs_locinifile, gs_computername, "SendMailMethod", "OLE")

FOR li_i = 1 TO upperBound(as_to)
	ls_to = ls_to + as_to[li_i] + ","
NEXT
ls_to = left(ls_to, len(ls_to) - 1)

FOR li_i = 1 TO upperBound(as_attach)
	IF NOT isNull(as_attach[li_i]) THEN
		ls_attach = ls_attach + as_attach[li_i] + ","
	END IF
NEXT
ls_attach = left(ls_attach, len(ls_attach) - 1)

IF ls_methode = "EWS" THEN
	return(uf_sendmail_ews(as_subject, as_body, ls_to, ls_attach))
ELSE
	return(uf_sendmail_ole(as_subject, as_body, as_to, as_attach))
END IF
	
end function

public function integer uf_sendmail_ole (string as_subject, string as_body, string as_to[], string as_attach[]);// envoyer un e-mail à un ou plusieurs destinataires, avec ou sans fichiers attachés par OLE
// return(1) si OK
// return(-1) en cas d'échec
integer	li_session, li_i, li_st

// Outlook item type 0 = A MailItem object
// see https://docs.microsoft.com/en-us/office/vba/api/outlook.olitemtype
CONSTANT LONG olMailItem = 0

oleObject lole_outlook
oleObject mail_item, mail_attach
OLERuntimeError 	l_ex
uo_wait	lu_wait

li_st = 1
l_ex = CREATE OLERuntimeError 
lu_wait = CREATE uo_wait
lole_outlook = CREATE oleobject

TRY
	lu_wait.uf_addinfo("Connecting to existing Outlook session")
	li_session = lole_outlook.ConnectToObject("Outlook.application")
	IF li_session <> 0 THEN
		lu_wait.uf_addinfo("Connecting to new Outlook session")
		li_session = lole_outlook.ConnectToNewObject("Outlook.application")
		IF li_session <> 0 THEN
			l_ex.setMessage("Error connecting to Outlook session : " + string(li_session) + " in module " + string(l_ex.objectname))
			li_st = -1
			throw l_ex
		END IF
	END IF

	lu_wait.uf_addinfo("Sending mail")
	
	// create mail item
	mail_item = lole_outlook.CreateItem(olMailItem)
	
	// set the various properties
	// see https://docs.microsoft.com/en-us/office/vba/api/outlook.mailitem
	mail_item.Subject = as_subject
	mail_item.Body = as_body
	FOR li_i = 1 to upperbound(as_to)
		IF NOT f_isemptyString(as_to[li_i]) THEN
			mail_item.Recipients.Add(as_to[li_i])
		END IF
	NEXT
	FOR li_i = 1 to upperbound(as_attach)
		IF NOT f_isEmptyString(as_attach[li_i]) THEN
			mail_item.Attachments.Add(as_attach[li_i])
		END IF
	NEXT
	mail_item.Send()
CATCH (OLERuntimeError l_err)
	li_st = -2
	gu_message.uf_error(l_err.text)
FINALLY
	DESTROY lu_wait
	DESTROY lole_outlook
END TRY

return(li_st)

end function

public function integer uf_sendmail_mapi (string as_subject, string as_body, string as_to[], string as_attach[]);// envoyer un e-mail à un ou plusieurs destinataires, avec ou sans fichiers attachés
// return(1) si OK
// return(-1) en cas d'échec
integer			li_i
string			ls_rtc
mailReturnCode lm_rtc
mailMessage 	lm_msg

SetPointer(HourGlass!)

// create and open a mail session
IF uf_maillogon() = -1 THEN
	return(-1)
END IF

// Populate the mailMessage structure
lm_Msg.Subject = as_subject
lm_Msg.NoteText = as_body
FOR li_i = 1 to upperbound(as_to)
	IF NOT f_isemptyString(as_to[li_i]) THEN
		lm_Msg.Recipient[li_i].name = as_to[li_i]
	END IF
NEXT
FOR li_i = 1 to upperbound(as_attach)
	IF NOT f_isEmptyString(as_attach[li_i]) THEN
		lm_Msg.AttachmentFile[1].pathname = as_attach[li_i]
	END IF
NEXT

// Send the mail, destroy the session and quit
lm_rtc = im_session.mailSend(lm_msg)
CHOOSE CASE lm_rtc
	CASE mailReturnFailure!
		ls_rtc = "mailReturnFailure"
	CASE mailReturnInsufficientMemory!
		ls_rtc = "mailReturnInsufficientMemory"
	CASE mailReturnLoginFailure!
		ls_rtc = "mailReturnLoginFailure"
	CASE mailReturnUserAbort!
		ls_rtc = "mailReturnUserAbort"
	CASE mailReturnDiskFull!
		ls_rtc = "mailReturnDiskFull"
	CASE mailReturnTooManySessions!
		ls_rtc = "mailReturnTooManySessions"
	CASE mailReturnTooManyFiles!
		ls_rtc = "mailReturnTooManyFiles"
	CASE mailReturnTooManyRecipients!
		ls_rtc = "mailReturnTooManyRecipients"
	CASE mailReturnUnknownRecipient!
		ls_rtc = "mailReturnUnknownRecipient"
	CASE mailReturnAttachmentNotFound!
		ls_rtc = "mailReturnAttachmentNotFound"
END CHOOSE

IF lm_rtc = mailReturnSuccess! THEN
	uf_maillogoff()
	return(1)
ELSE
	gu_message.uf_error("Erreur Mail", "Le message n'a pas été envoyé : " + ls_rtc)
	uf_maillogoff()
	return(-1)
END IF

end function

public function integer uf_sendmail_ews (string as_subject, string as_body, string as_to, string as_attach);// Envoi mail au moyen de EWS (Exchange Web Service)
// Le script powershell et la librairie Microsoft.Exchange.WebServices.dll doivent se trouver
// dans un sous-dossier "Exchange" placé sous le dossier de l'application (gs_startpath)
// as_to : destinataire(s). Séparateur entre les destinataires : virgule.
// as_subject : objet du message.
// as_body : corps du message.
// as_attach : nom de fichier des pièces joints. Séparateur entre les pièces : virgule.
// PCO 07/08/2019 : avec les comptes ONLINE (au lieu de ON PREMISE), il faut fournir le mot de passe Windows
// à EWS, donc il faut le demander ici...

string	ls_cmd, ls_from, ls_path, ls_filename, ls_err, ls_status, ls_ExchangePwd
integer	li_rtc
uo_ds		lds_mail
uo_fileservices	lu_fileservices

li_rtc = 1
ls_path = gs_startpath + "\Exchange"
ls_filename = gs_tmpfiles + "\MailItems.csv"

// vérifier la présence des librairies Exchange sur le PC
IF NOT fileExists(ls_path) THEN
	ls_err = "Exécution impossible. Veuillez vérifier la présence du dossier " + ls_path
	li_rtc = -1
	GOTO FIN
END IF

// lecture adresse mail dans AGENT (doit être une adresse SPW !)
select email into :ls_from from agent where matricule=:gs_username using ESQLCA;
IF f_isEmptyString(ls_from) THEN
	ls_err = "Envoi de mail : l'adresse mail de l'utilisateur en cours n'est pas définie dans AGENT. Veuillez compléter."
	li_rtc = -1
	GOTO FIN
END IF

// PCO 07/08/2019 : demander le mot de passe Windows 
IF f_getPassword("Mot de passe Windows", "NB : le mot de passe Windows vous est demandé afin de pouvoir accéder à Outlook.", gs_ExchangePwd) = -1 THEN
	gu_message.uf_error("Le mot de passe Windows est nécessaire pour accéder à Outlook")
	return(-1)
END IF

// PCO 03/10/2019 : la fonction "SaveAsFormattedText" devrait remplacer les " par ' mais cela ne fonctionne 
// pas comme prévu --> je le fais manuellement...
as_subject = gu_stringservices.uf_replaceall(as_subject, '"', "'")
as_body = gu_stringservices.uf_replaceall(as_body, '"', "'")

lds_mail = CREATE uo_ds
lds_mail.dataobject = "ds_exchange_mail"
lds_mail.insertrow(0)
lds_mail.object.to[1] = as_to
lds_mail.object.subject[1] = as_subject
lds_mail.object.body[1] = as_body
lds_mail.object.attach[1] = as_attach
IF lds_mail.SaveAsFormattedText(ls_filename, EncodingUTF8!, ",", '"', "~r~n", true) = -1 THEN 
	ls_err = "Erreur export données vers " + ls_filename
	li_rtc = -1
	GOTO FIN
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

// exécution du script
ls_cmd = ls_path + "\sendMail.cmd ~"" + ls_from + "~" ~"" + ls_filename + "~" ~"" + ls_path + "~" ~"" + ls_ExchangePwd + "~""
f_runwait(ls_cmd)

// read status file : contient 0 (échec) ou 1 (réussi)
lu_fileservices = CREATE uo_fileservices
lu_fileservices.uf_readfile(gs_tmpfiles + "\mailStatus.txt", ls_status)
DESTROY lu_fileservices
IF ls_status <> "1" THEN
	li_rtc = -1
	ls_err = "Erreur lors de l'envoi du mail : aucun mail envoyé"
END IF

FIN:
IF li_rtc = -1 THEN
	gu_message.uf_unexp(ls_err)
END IF

DESTROY lds_mail

return(li_rtc)
end function

public function string uf_meeting_ole_send (string as_id, string as_subject, string as_body, string as_location, date a_startdate, time a_starttime, date a_enddate, time a_endtime, boolean ab_allday, long al_duration, string as_destinataires[]);// Création/modification d'une réunion dans Outlook par OLE.
// as_id contient l'éventuel ID d'un meeting existant. 
//		Ce meeting sera donc mis à jour (ou recréé s'il avait été supprimé dans Outlook).
// 	Si as_id est vide, un meeting sera créé.
// ab_allday : TRUE/FALSE. Réunion d'une journée entière.
// al_duration : duréer de la réunion (en minutes). Ignoré valeur=NULL ou si ab_allday = TRUE.
// Si OK : renvoie l'identifiant Outlook de la réunion.
// Si erreur : renvoie string NULL

// Outlook folder type 9 = the calendar folder
// see https://docs.microsoft.com/en-us/office/vba/api/outlook.oldefaultfolders
CONSTANT LONG olFolderCalendar = 9

// Outlook item type 1 = an AppointmentItem object
// see https://docs.microsoft.com/en-us/office/vba/api/outlook.olitemtype
CONSTANT LONG olAppointmentItem = 1

// Outlook meeting status 1 = the meeting has been scheduled
// see https://docs.microsoft.com/en-us/dotnet/api/microsoft.office.interop.outlook.olmeetingstatus?view=outlook-pia
CONSTANT LONG olMeetingStatus = 1

// Outlook busy status : 0=available, 2=busy, 3=out of office
CONSTANT LONG olBusyStatus = 0

oleObject	MapiNameSpace, lole_outlook
oleObject	appointment_item, calendar_folder
OLERuntimeError 	l_ex
uo_wait	lu_wait
integer	li_session, li_i
string	ls_data, ls_ID

setNull(ls_ID)

l_ex = CREATE OLERuntimeError 
lole_outlook = CREATE oleobject
IF ib_displayinfo THEN lu_wait = CREATE uo_wait

TRY
	IF ib_displayinfo THEN lu_wait.uf_addinfo("Connecting to existing Outlook session")
	li_session = lole_outlook.ConnectToObject("Outlook.application")
	IF li_session <> 0 THEN
		IF ib_displayinfo THEN lu_wait.uf_addinfo("Connecting to new Outlook session")
		li_session = lole_outlook.ConnectToNewObject("Outlook.application")
		IF li_session <> 0 THEN
			l_ex.setMessage("Error connecting to Outlook session : " + string(li_session) + " in module " + string(l_ex.objectname))
			throw l_ex
		END IF
	END IF

	IF ib_displayinfo THEN lu_wait.uf_addinfo("Creating meeting")
	MapiNameSpace = lole_outlook.GetNameSpace("MAPI")
	//calendar_folder = MapiNameSpace.GetDefaultFolder(olFolderCalendar)

	// find existing or create new appointment item
	TRY
		appointment_item = MapiNameSpace.GetItemFromID(as_id)
	CATCH (OLERuntimeError l_err2)
		// appointment_item = calendar_folder.Items.Add(olAppointmentItem)
		appointment_item = lole_outlook.CreateItem(olAppointmentItem)
	FINALLY
	END TRY

	// set the various properties
	// see https://docs.microsoft.com/en-us/office/vba/api/outlook.appointmentitem
	appointment_item.MeetingStatus = olMeetingStatus
	appointment_item.BusyStatus = olBusyStatus
	IF NOT isNull(a_startDate) THEN 
		ls_data = string(a_startDate, "yyyy/mm/dd")
		IF isNull(a_startTime) THEN 
			ls_data = ls_data + " 0:00:00 AM"
		ELSE
			ls_data = ls_data + " " + string(a_startTime, "h:mm:ss AM/PM")
		END IF
		appointment_item.Start = ls_data
	END IF
	IF NOT isNull(a_endDate) THEN 
		ls_data = string(a_endDate, "yyyy/mm/dd")
		IF isNull(a_endTime) THEN 
			ls_data = ls_data + " 0:00:00 PM"
		ELSE
			ls_data = ls_data + " " + string(a_endTime, "h:mm:ss AM/PM")
		END IF
		appointment_item.End = ls_data
	END IF
	IF ab_allday THEN
		appointment_item.AllDayEvent = ab_allday
	ELSEIF not isNull(al_duration) THEN
		appointment_item.Duration = al_duration
	END IF
	appointment_item.Subject = as_subject
	appointment_item.Location = as_location
	appointment_item.Body = as_body
	FOR li_i = 1 TO upperBound(as_destinataires)
		appointment_item.Recipients.Add(as_destinataires[li_i])
	NEXT
	appointment_item.Send()
	ls_ID = string(appointment_item.EntryID)
CATCH (OLERuntimeError l_err)
	gu_message.uf_error(l_err.text)
FINALLY
	IF ib_displayinfo THEN DESTROY lu_wait
	DESTROY lole_outlook
END TRY

return(ls_ID)

end function

public function boolean uf_meeting_ole_exists (string as_id);// Vérifier dans Outlook l'existence de la réunion d'identifiant as_id/
// as_ID : Outlook ID généré lors de la création du meeting
// return(1) si OK
// return(-1) si erreur

oleObject	MapiNameSpace, lole_outlook
OleObject	appointment_item, calendar_folder
OLERuntimeError 	l_ex
integer	li_session
boolean	lb_st

l_ex = CREATE OLERuntimeError 
lole_outlook = CREATE oleobject

TRY
	li_session = lole_outlook.ConnectToObject("Outlook.application")
	IF li_session <> 0 THEN
		li_session = lole_outlook.ConnectToNewObject("Outlook.application")
		IF li_session <> 0 THEN
			l_ex.setMessage("Error connecting to Outlook session : " + string(li_session) + " in module " + string(l_ex.objectname))
			throw l_ex
		END IF
	END IF

	MapiNameSpace = lole_outlook.GetNameSpace("MAPI")

	// retrouve l'item sur base de son ID
	appointment_item = MapiNameSpace.GetItemFromID(as_id)
	lb_st = TRUE

// catch les éventuelles erreurs mais n'affiche aucun message
CATCH (OLERuntimeError l_err)
	lb_st = FALSE
FINALLY
	DESTROY lole_outlook
END TRY

return(lb_st)

end function

public function integer uf_meeting_ole_delete (string as_outlookid);// Suppression d'une réunion dans Outlook par OLE.
// as_outlookID : Outlook ID généré lors de la création du meeting
// return(1) si OK
// return(-1) si erreur

oleObject	MapiNameSpace, lole_outlook
OleObject	appointment_item, calendar_folder
// Outlook meeting status 5 = the meeting has been canceled
// see https://docs.microsoft.com/en-us/dotnet/api/microsoft.office.interop.outlook.olmeetingstatus?view=outlook-pia
CONSTANT LONG olMeetingStatus = 5

OLERuntimeError 	l_ex
uo_wait	lu_wait
integer	li_session, li_st

l_ex = CREATE OLERuntimeError
lole_outlook = CREATE oleobject
IF ib_displayinfo THEN lu_wait = CREATE uo_wait

TRY
	IF ib_displayinfo THEN lu_wait.uf_addinfo("Connecting to existing Outlook session")
	li_session = lole_outlook.ConnectToObject("Outlook.application")
	IF li_session <> 0 THEN
		IF ib_displayinfo THEN lu_wait.uf_addinfo("Connecting to new Outlook session")
		li_session = lole_outlook.ConnectToNewObject("Outlook.application")
		IF li_session <> 0 THEN
			l_ex.setMessage("Error connecting to Outlook session : " + string(li_session) + " in module " + string(l_ex.objectname))
			throw l_ex
		END IF
	END IF

	IF ib_displayinfo THEN lu_wait.uf_addinfo("Deleting meeting")
	MapiNameSpace = lole_outlook.GetNameSpace("MAPI")

	// retrouve l'item meeting sur base de son ID, et le supprime
	appointment_item = MapiNameSpace.GetItemFromID(as_outlookID)
	appointment_item.MeetingStatus = olMeetingStatus
	appointment_item.Save
	appointment_item.Send
	appointment_item.Delete()
	li_st = 1

// catch les éventuelles erreurs mais n'affiche aucun message car le cas le plus probable
// est qu'on essaye de retrouver un item supprimé manuellement du planning Outlook
CATCH (OLERuntimeError l_err)
	li_st = -1
FINALLY
	IF ib_displayinfo THEN DESTROY lu_wait
	DESTROY lole_outlook
END TRY

return(li_st)

end function

public subroutine uf_setdisplayinfo (boolean ab_displayinfo);ib_displayInfo = ab_displayInfo
end subroutine

public function string uf_activity_ole_send (string as_id, string as_subject, string as_body, string as_location, date a_startdate, time a_starttime, date a_enddate, time a_endtime, boolean ab_allday, long al_duration, string as_destinataire);// Création/modification d'une activité dans un calendrier Outlook.
// 1 seul destinataire accepté.
// Le compte Office en cours doit avoir les droits de modification du planning destinataire.
// as_id contient l'éventuel ID d'un item existant. 
//		Cet item sera donc mis à jour (ou recréé s'il avait été supprimé dans Outlook).
// 	Si as_id est vide, un nouvel item sera créé.
// ab_allday : TRUE/FALSE. Activité d'une journée entière.
// al_duration : duréer de l'activité (en minutes). Ignoré valeur=NULL ou si ab_allday = TRUE.
// Si OK : renvoie l'identifiant Outlook de l'item.
// Si erreur : renvoie string NULL

// Outlook folder type 9 = the calendar folder
// see https://docs.microsoft.com/en-us/office/vba/api/outlook.oldefaultfolders
CONSTANT LONG olFolderCalendar = 9

// Outlook item type 1 = an AppointmentItem object
// see https://docs.microsoft.com/en-us/office/vba/api/outlook.olitemtype
CONSTANT LONG olAppointmentItem = 1

// Outlook meeting status 1 = the meeting has been scheduled
// see https://docs.microsoft.com/en-us/dotnet/api/microsoft.office.interop.outlook.olmeetingstatus?view=outlook-pia
CONSTANT LONG olMeetingStatus = 1

// Outlook busy status : 0=available, 2=busy, 3=out of office
CONSTANT LONG olBusyStatus = 0

oleObject	MapiNameSpace, lole_outlook, objOwner
oleObject	appointment_item, calendar_folder
OLERuntimeError 	l_ex
uo_wait	lu_wait
integer	li_session
string	ls_data, ls_ID

setNull(ls_ID)

l_ex = CREATE OLERuntimeError 
lole_outlook = CREATE oleobject
IF ib_displayinfo THEN lu_wait = CREATE uo_wait

TRY
	IF ib_displayinfo THEN lu_wait.uf_addinfo("Connecting to existing Outlook session")
	li_session = lole_outlook.ConnectToObject("Outlook.application")
	IF li_session <> 0 THEN
		IF ib_displayinfo THEN lu_wait.uf_addinfo("Connecting to new Outlook session")
		li_session = lole_outlook.ConnectToNewObject("Outlook.application")
		IF li_session <> 0 THEN
			l_ex.setMessage("Error connecting to Outlook session : " + string(li_session) + " in module " + string(l_ex.objectname))
			throw l_ex
		END IF
	END IF

	MapiNameSpace = lole_outlook.GetNameSpace("MAPI")
	
	// find recipient
	objOwner = MapiNameSpace.CreateRecipient(as_destinataire)
	objOwner.Resolve()
	
	// find recipient's shared folder
	calendar_folder = MapiNameSpace.GetSharedDefaultFolder(objOwner, olFolderCalendar)

	// find existing or create new appointment item
	IF ib_displayinfo THEN lu_wait.uf_addinfo("Creating activity for " + as_destinataire)
	TRY
		appointment_item = MapiNameSpace.GetItemFromID(as_id)
	CATCH (OLERuntimeError l_err2)
		appointment_item = calendar_folder.Items.Add(olAppointmentItem)
	FINALLY
	END TRY

	// set the various properties
	// see https://docs.microsoft.com/en-us/office/vba/api/outlook.appointmentitem
	appointment_item.MeetingStatus = olMeetingStatus
	appointment_item.BusyStatus = olBusyStatus
	IF NOT isNull(a_startDate) THEN 
		ls_data = string(a_startDate, "yyyy/mm/dd")
		IF isNull(a_startTime) THEN 
			ls_data = ls_data + " 0:00:00 AM"
		ELSE
			ls_data = ls_data + " " + string(a_startTime, "h:mm:ss AM/PM")
		END IF
		appointment_item.Start = ls_data
	END IF
	IF NOT isNull(a_endDate) THEN 
		ls_data = string(a_endDate, "yyyy/mm/dd")
		IF isNull(a_endTime) THEN 
			ls_data = ls_data + " 0:00:00 PM"
		ELSE
			ls_data = ls_data + " " + string(a_endTime, "h:mm:ss AM/PM")
		END IF
		appointment_item.End = ls_data
	END IF
	IF ab_allday THEN
		appointment_item.AllDayEvent = ab_allday
	ELSEIF not isNull(al_duration) THEN
		appointment_item.Duration = al_duration
	END IF
	appointment_item.Subject = as_subject
	appointment_item.Location = as_location
	appointment_item.Body = as_body
	appointment_item.Send()
	ls_ID = string(appointment_item.EntryID)
CATCH (OLERuntimeError l_err)
	gu_message.uf_error(l_err.text)
FINALLY
	IF ib_displayinfo THEN DESTROY lu_wait
	DESTROY lole_outlook
END TRY

return(ls_ID)

end function

public function integer uf_check_modifyplanning (string as_destinataire);// Vérifier si le profil Office en cours a le droit de modifier le planning d'un autre compte.
// as_destinataire : compte cible.
// return(1) : autorisé
// return(-1): pas autorisé ou autre erreur

// Outlook folder type 9 = the calendar folder
// see https://docs.microsoft.com/en-us/office/vba/api/outlook.oldefaultfolders
CONSTANT LONG olFolderCalendar = 9

// Outlook item type 1 = an AppointmentItem object
// see https://docs.microsoft.com/en-us/office/vba/api/outlook.olitemtype
CONSTANT LONG olAppointmentItem = 1

oleObject	MapiNameSpace, lole_outlook, objOwner
oleObject	appointment_item, calendar_folder
OLERuntimeError 	l_ex
uo_wait	lu_wait
integer	li_session
boolean	lb_autorised

l_ex = CREATE OLERuntimeError 
lole_outlook = CREATE oleobject
IF ib_displayinfo THEN lu_wait = CREATE uo_wait

// assume profile has authorisation
lb_autorised = TRUE

TRY
	IF ib_displayinfo THEN lu_wait.uf_addinfo("Connecting to existing Outlook session")
	li_session = lole_outlook.ConnectToObject("Outlook.application")
	IF li_session <> 0 THEN
		IF ib_displayinfo THEN lu_wait.uf_addinfo("Connecting to new Outlook session")
		li_session = lole_outlook.ConnectToNewObject("Outlook.application")
		IF li_session <> 0 THEN
			l_ex.setMessage("Error connecting to Outlook session : " + string(li_session) + " in module " + string(l_ex.objectname))
			throw l_ex
		END IF
	END IF

	MapiNameSpace = lole_outlook.GetNameSpace("MAPI")
	appointment_item = lole_outlook.CreateItem(olAppointmentItem)

	// find recipient
	objOwner = MapiNameSpace.CreateRecipient(as_destinataire)
	objOwner.Resolve()

	
	// find recipient's shared folder
	calendar_folder = MapiNameSpace.GetSharedDefaultFolder(objOwner, olFolderCalendar)

	// try to create new appointment item
	IF ib_displayinfo THEN lu_wait.uf_addinfo("Checking permissions on " + as_destinataire)
	appointment_item = calendar_folder.Items.Add(olAppointmentItem)

CATCH (OLERuntimeError l_err)
	lb_autorised = FALSE
//	gu_message.uf_error(l_err.text)
FINALLY
	IF ib_displayinfo THEN DESTROY lu_wait
	DESTROY lole_outlook
END TRY

IF lb_autorised THEN
	return(1)
ELSE
	return(-1)
END IF

end function

on uo_mailservices.create
call super::create
TriggerEvent( this, "constructor" )
end on

on uo_mailservices.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

event constructor;// par défaut, afficher les messages
ib_displayinfo = TRUE
end event

