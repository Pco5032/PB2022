//objectcomments Ancêtre de toutes les fenêtres
forward
global type w_ancestor from window
end type
end forward

global type w_ancestor from window
integer x = 251
integer y = 252
integer width = 3538
integer height = 2304
boolean titlebar = true
string title = "Untitled"
boolean controlmenu = true
boolean minbox = true
boolean maxbox = true
boolean resizable = true
long backcolor = 67108864
string icon = "..\bmp\DNF.ico"
event ue_postopen ( )
event we_syscommand pbm_syscommand
event ue_closebyxrejected ( )
event ue_closebyxaccepted ( )
event ue_init_menu ( )
event ue_open ( )
event ue_close ( )
event type long ue_closequery ( )
event ue_cancel ( )
event ue_translate ( )
event ue_before_ueopen ( )
end type
global w_ancestor w_ancestor

type variables
PRIVATE string	is_MessageNoConsult, is_MessageNoUpdate, is_MessageNoDelete, is_itemstoshow[]
PRIVATE boolean	ib_CloseByXPermitted=TRUE, ib_ExecutePostopenEvent=TRUE, &
						ib_canconsult=TRUE, ib_canupdate=FALSE, ib_candelete=FALSE, &
						ib_logusage=TRUE, /* indique s'il faut enregistrer dans fichier log le nom du programme utilisé */ &
						ib_deferTranslate=FALSE /* indique si l'event ue_translate est déclenché automatiquement à l'open ou plus tard par le programmeur */
PRIVATEWRITE decimal{0}	id_sequence
end variables

forward prototypes
public subroutine wf_setitemstoshow (string as_itemstoshow[])
public subroutine wf_executepostopen (boolean ab_execute)
public function boolean wf_executepostopen ()
public function string wf_getactivecontrolname ()
public function boolean wf_canconsult ()
public subroutine wf_canconsult (boolean ab_canconsult)
public function boolean wf_candelete ()
public subroutine wf_candelete (boolean ab_candelete)
public function boolean wf_canupdate ()
public subroutine wf_canupdate (boolean ab_canupdate)
public subroutine wf_setmessagenoconsult (string as_message)
public subroutine wf_setmessagenoupdate (string as_message)
public subroutine wf_setmessagenodelete (string as_message)
public function string wf_getmessagenoconsult ()
public function string wf_getmessagenodelete ()
public function string wf_getmessagenoupdate ()
public function boolean wf_closebyxpermitted ()
public subroutine wf_closebyxpermitted (boolean ab_close)
public subroutine wf_setsequence (decimal ad_seq)
public function integer wf_getwsheight ()
public function integer wf_getwswidth ()
public subroutine wf_logusage (boolean ab_log)
public function boolean wf_logusage ()
public subroutine wf_defertranslate (boolean ab_defertranslate)
public function boolean wf_translatedeferred ()
public subroutine wf_setdefaultmsg ()
end prototypes

event ue_postopen();// si on ne veut pas que le code soit exécuté, on peut utiliser la fonction wf_executepostopen(FALSE)
// dans l'open et ici tester la condition avec la fonction wf_executepostopen() qui renvoie TRUE ou FALSE
IF NOT wf_executepostopen() THEN return

// PCO 29/04/2015 : enregistre une ligne dans le fichier d'utilisation des programmes
IF ib_logUsage THEN f_logusage(this.classname())

end event

event we_syscommand;// close par bouton X du coin sup droit de la fenêtre interdit ou autorisé suivant variable ib_CloseByXPermitted
IF commandtype = 61536 THEN
	IF ib_CloseByXPermitted THEN
		this.event ue_CloseByXAccepted()
		return(0)
	ELSE
		this.event ue_CloseByXRejected()
		return(1)
	END IF
END IF
end event

event ue_closebyxrejected;beep(1)
end event

event ue_close;// cet event n'est déclenché par l'event close() que si l'utilisateur a le droit d'ouvrir cette fenêtre
end event

event ue_closequery;// cet event n'est déclenché par l'event closequery() que si l'utilisateur a le droit d'ouvrir cette fenêtre
// return(1) pour empêcher la fermeture de la fenêtre
// return(0) pour autoriser la fermeture de la fenêtre
return(0)
end event

event ue_cancel;// event déclenché par une fenêtre externe (normalement w_cancel) quand on souhaite interrompre la lecture en cours

end event

event ue_translate();// Déclenché automatiquement par l'event "ue_open" si la traduction de l'application est demandée,
// OU par le programmeur.
gu_translate.uf_translatewindow(this)
end event

public subroutine wf_setitemstoshow (string as_itemstoshow[]);is_itemstoshow = as_itemstoshow[]
end subroutine

public subroutine wf_executepostopen (boolean ab_execute);ib_ExecutePostopenEvent = ab_execute
end subroutine

public function boolean wf_executepostopen ();return(ib_executepostopenevent)
end function

public function string wf_getactivecontrolname ();string 			ls_name
GraphicObject	l_control
datawindow		ldw_1
SingleLineEdit lsle_1
CommandButton 	lcb_1
EditMask			lem_1
StaticText		lst_1

l_control = GetFocus()
ls_name = ""
IF IsNull(l_control) OR NOT IsValid(l_control) THEN return(ls_name)

CHOOSE CASE TypeOf(l_control)
	CASE DataWindow!
		ldw_1 = l_control
		ls_name = ldw_1.classname()
	CASE CommandButton!
		lcb_1 = l_control
		ls_name = lcb_1.classname()
	CASE SingleLineEdit!
		lsle_1 = l_control
		ls_name = lsle_1.classname()
	CASE EditMask!
		lem_1 = l_control
		ls_name = lem_1.classname()
	CASE statictext!
		lst_1 = l_control
		ls_name = lst_1.classname()
END CHOOSE

return(ls_name)
end function

public function boolean wf_canconsult ();// renvoie TRUE si l'utilisateur a le droit de consulter la fenêtre
return(ib_canconsult)
end function

public subroutine wf_canconsult (boolean ab_canconsult);// modifie le droit en consultation de ce programme pour l'utilisateur en cours
ib_canconsult = ab_canconsult
end subroutine

public function boolean wf_candelete ();// renvoie TRUE si l'utilisateur a le droit de supprimer des occurences
return(ib_candelete)
end function

public subroutine wf_candelete (boolean ab_candelete);// modifie le droit de suppression de données dans ce programme pour l'utilisateur en cours
ib_candelete = ab_candelete
end subroutine

public function boolean wf_canupdate ();// renvoie TRUE si l'utilisateur a le droit de modifier la fenêtre
return(ib_canupdate)
end function

public subroutine wf_canupdate (boolean ab_canupdate);// modifie le droit de modification de données dans ce programme pour l'utilisateur en cours
ib_canupdate = ab_canupdate
end subroutine

public subroutine wf_setmessagenoconsult (string as_message);// modifie le message d'interdiction d'utiliser le programme
is_messagenoconsult = as_message

end subroutine

public subroutine wf_setmessagenoupdate (string as_message);// modifie le message d'interdiction d'apporter des modifications
is_MessageNoUpdate = as_message

end subroutine

public subroutine wf_setmessagenodelete (string as_message);// modifie le message d'interdiction de supprimer
is_MessageNoDelete = as_message

end subroutine

public function string wf_getmessagenoconsult ();// renvoie le message d'interdiction d'utiliser le programme
return(is_messagenoconsult)

end function

public function string wf_getmessagenodelete ();// renvoie le message d'interdiction de supprimer
return(is_MessageNoDelete)

end function

public function string wf_getmessagenoupdate ();// renvoie le message d'interdiction d'apporter des modifications
return(is_MessageNoUpdate)

end function

public function boolean wf_closebyxpermitted ();// renvoie TRUE si la fenêtre peut être fermée par le bouton X, FALSE sinon
return(ib_closebyxpermitted)
end function

public subroutine wf_closebyxpermitted (boolean ab_close);// initialise la variable permettant de spécifier si la fenêtre peut être fermée par le bouton X
// (par défaut, cette variable est à TRUE)
ib_closebyxpermitted = ab_close
end subroutine

public subroutine wf_setsequence (decimal ad_seq);// modifie le n° de séquence attribué à la fenêtre
id_sequence = ad_seq
end subroutine

public function integer wf_getwsheight ();return(this.workSpaceHeight())
end function

public function integer wf_getwswidth ();return(this.workSpaceWidth())
end function

public subroutine wf_logusage (boolean ab_log);// demande log ou pas de l'utilisation du programme
ib_logusage = ab_log
end subroutine

public function boolean wf_logusage ();// renvoie TRUE s'il faut logger l'utilisation de la fenêtre
return(ib_logusage)
end function

public subroutine wf_defertranslate (boolean ab_defertranslate);ib_defertranslate = ab_defertranslate
end subroutine

public function boolean wf_translatedeferred ();return(ib_defertranslate)
end function

public subroutine wf_setdefaultmsg ();// Initialise les messages par défaut. Fonction appelée dans l'event open.
// Pour modifier ces messages dans un descendant, le faire dans cette fonction. 
// Attention, d'abord appeler le code initial PUIS coder le code complémentaire.
// Pour appeler le code initial : super::wf_setdefaultmsg()
wf_SetMessageNoConsult(f_translate_getlabel("TEXT_00120", "Désolé, vous n'êtes pas autorisé à utiliser ce programme..."))
wf_setMessageNoUpdate(f_translate_getlabel("TEXT_00123", "Vous n'avez pas le droit de modifier et enregistrer ces données"))
wf_setMessageNoDelete(f_translate_getlabel("TEXT_00124", "Vous n'avez pas le droit de supprimer ces données"))
end subroutine

on w_ancestor.create
end on

on w_ancestor.destroy
end on

event open;// attribuer un n° de séquence unique par fenêtre ouverte dans une même session,
// qui peut être utilisé par exemple comme identifiant dans les tables temporaires
gd_sequence++
id_sequence=gd_sequence

// message par défaut si pas accès
wf_setdefaultmsg()

// adapter la hauteur au thème visuel de Windows
this.height = this.height + f_adjustHeight()

// initialiser les variables spécifiant les droits de l'utilisateur dans cette fenêtre
CHOOSE CASE gu_privs.uf_canconsult(this.classname())
	// pas de droits spécifique à l'utilisateur pour cette fenêtre : utiliser droits par défaut de la fenêtre
	CASE 0
		IF NOT wf_canconsult() THEN
			gu_message.uf_info(is_messagenoconsult)
			This.move(-5000, -5000)
			post close(this)
			return
		END IF
	// accès autorisé
	CASE 1
		wf_canconsult(TRUE)
	// accès interdit
	CASE -1
		wf_canconsult(FALSE)
		gu_message.uf_info(is_messagenoconsult)
		This.move(-5000, -5000)
		post close(this)
		return
END CHOOSE

CHOOSE CASE gu_privs.uf_canupdate(this.classname())
	// update autorisé
	CASE 1 
		wf_canupdate(TRUE)
	// update interdit
	CASE -1
		wf_canupdate(FALSE)
END CHOOSE

CHOOSE CASE gu_privs.uf_candelete(this.classname())
	// delete autorisé
	CASE 1 
		wf_candelete(TRUE)
	// delete interdit
	CASE -1
		wf_candelete(FALSE)
END CHOOSE

// si l'utilisateur n'a pas le droit d'ouvrir cette fenêtre, on fait le minimum lors de l'ouverture
// (donc on exécute ni ue_open(), ni ue_postopen())
this.event trigger ue_before_ueopen() // PCO 22/12/2015, pour de rares cas, notamment pour pouvoir agir avant que ue_translate soit déclenché...bof...
this.event trigger ue_open()

// si traduction nécessaire, déclencher ue_translate
IF isValid(this) THEN
	IF isValid(gu_translate) THEN
		IF gu_translate.uf_mustTranslate() AND NOT wf_translateDeferred() THEN
			this.event trigger ue_translate()
		END IF
	END IF
	
	// post open : initialisation après affichage de la fenêtre
	this.event post ue_postopen()
END IF


end event

event deactivate;// réinitialiser le menu ACTION
gw_mdiframe.menuid.DYNAMIC mf_hideaction(is_itemstoshow)
f_menuaction({""})

end event

event activate;gw_mdiframe.menuid.DYNAMIC mf_showaction(is_itemstoshow)
This.event ue_init_menu() 
end event

event rbuttondown;IF this.windowtype <> Response! THEN f_PopupAction(This)
end event

event close;// !!!! ajouter le code nécessaire dans ue_close() des descendants !!!!!!!

// si l'utilisateur n'a pas le droit d'ouvrir cette fenêtre, on fait le minimum lors de l'ouverture
// mais aussi lors de la fermeture de la fenêtre (donc on exécute ni ue_open(), ni ue_closequery(), ni ue_close())
IF wf_CanConsult() THEN
	this.event ue_close()
END IF
end event

event closequery;// !!!! ajouter le code nécessaire dans ue_closequery() des descendants !!!!!!!

// si l'utilisateur n'a pas le droit d'ouvrir cette fenêtre, on fait le minimum lors de l'ouverture
// mais aussi lors de la fermeture de la fenêtre (donc on exécute ni ue_open(), ni ue_closequery(), ni ue_close())
IF wf_CanConsult() THEN
	// fermeture en fonction du code de retour de ue_closequery()
	return(this.event ue_closequery())
ELSE
	// fermeture autorisée d'office
	return(0)
END IF
end event

event resize;// resize max width=4300, height=2300 for 1024 X 768
end event

