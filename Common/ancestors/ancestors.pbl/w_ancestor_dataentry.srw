//objectcomments Ancêtre des fenêtres de gestion de données
forward
global type w_ancestor_dataentry from w_ancestor
end type
type ddlb_message from uo_ddlb_message within w_ancestor_dataentry
end type
end forward

global type w_ancestor_dataentry from w_ancestor
boolean maxbox = false
boolean resizable = false
event type integer ue_abandonner ( )
event ue_ajouter ( )
event type integer ue_enregistrer ( )
event ue_init_win ( )
event ue_supprimer ( )
event ue_inserer ( )
event ue_init_inactivewin ( )
event type integer ue_pre_enregistrer ( )
event ue_pre_supprimer ( )
event ue_pre_ajouter ( )
event ue_pre_inserer ( )
event ue_nullify ( )
ddlb_message ddlb_message
end type
global w_ancestor_dataentry w_ancestor_dataentry

type variables
PRIVATE boolean	ib_actif
datawindow	idw_dwlist[]

end variables

forward prototypes
public subroutine wf_message (string as_message)
public function boolean wf_isactif ()
public subroutine wf_setdwlist (datawindow adw_list[])
public subroutine wf_actif (boolean ab_actif)
public function integer wf_getwsheight ()
public function integer wf_getwswidth ()
end prototypes

event type integer ue_abandonner();// si l'utilisateur a le privilège d'update et que la fenêtre contient des données modifiées, 
// on demande s'il faut enregistrer avant d'abandonner, sinon on ne le demande pas
// return(1) si on a enregistré avant de quitter
// return(-1) si on a voulu enregistrer avant de quitter mais l'enregistrement n'a pas fonctionné
// return(2) si on n'enregistre pas
// return(3) pour abandonner (aucune action effectuée)
// return(4) si l'event a été déclenché dans une fenêtre ne contenant pas de données actives

IF wf_IsActif() AND wf_canupdate() THEN
	CHOOSE CASE gu_dwservices.uf_confirm_cancel(idw_dwlist)
		CASE 1
			IF this.event ue_enregistrer() >= 0 THEN
				return(1)
			ELSE
				return(-1)
			END IF
		CASE 2
			wf_message("Modifications abandonnées")
			This.event ue_init_win()
			return(2)
		CASE 3
			return(3)
	END CHOOSE
ELSE
	// abandon d'une fenêtre inactive (par exemple, abandon demandé quand on est dans la clé), on déclenche
	// un event particulier avant ue_init_win afin de pouvoir faire un traitement particulier
	IF NOT wf_IsActif() THEN
		This.event ue_init_inactivewin()
	END IF
	wf_message("")
	This.event ue_init_win()
	return(4)
END IF
end event

event ue_enregistrer;return(0)
end event

event ue_init_win;// dans cet event, on réinitialise toute la fenêtre donc il n'y a plus de données actives
wf_actif(false)

// intialiser le menu avec ce qui est nécessaire pour cette fenêtre
This.event post ue_init_menu()
end event

event ue_init_inactivewin;// déclenché quand on demande d'abandonner (bouton abandonner et event ue_abandonner) une fenêtre inactive 
// (ne contenant pas de données)
end event

event ue_pre_enregistrer;// event déclenché quand on demande d'enregistrer le contenu de la fenêtre
// Si l'utilisateur a le droit d'update dans cette fenêtre, on déclenche ue_enregistrer, sinon pas
IF wf_canupdate() THEN
	return(this.event ue_enregistrer())
ELSE
	gu_message.uf_info(wf_getMessageNoUpdate())
	return(-1)
END IF
end event

event ue_pre_supprimer;IF wf_candelete() THEN
	this.event ue_supprimer()
ELSE
	gu_message.uf_info(wf_getMessageNoDelete())
	return
END IF
end event

event ue_pre_ajouter;// event déclenché quand on demande d'ajouter un record aux données contenues dans la fenêtre.
// Si l'utilisateur a le droit d'update dans cette fenêtre, on déclenche ue_ajouter, sinon pas
IF wf_canupdate() THEN
	this.event ue_ajouter()
ELSE
	gu_message.uf_info(wf_getMessageNoUpdate())
	return
END IF
end event

event ue_pre_inserer;// event déclenché quand on demande d'insérer un record dans les données contenues dans la fenêtre.
// Si l'utilisateur a le droit d'update dans cette fenêtre, on déclenche ue_inserer, sinon pas
IF wf_canupdate() THEN
	this.event ue_inserer()
ELSE
	gu_message.uf_info(wf_getMessageNoUpdate())
	return
END IF
end event

event ue_nullify();// Déclenché par l'action "nullify" du menu.
// Prévu pour déclenche l'event ue_nullify d'un DW et de permettre de rendre NULL l'item en cours
end event

public subroutine wf_message (string as_message);ddlb_message.Event ue_message(as_message)
end subroutine

public function boolean wf_isactif ();return(ib_actif)
end function

public subroutine wf_setdwlist (datawindow adw_list[]);idw_dwlist = adw_list

end subroutine

public subroutine wf_actif (boolean ab_actif);ib_actif = ab_actif
end subroutine

public function integer wf_getwsheight ();// renvoie en PBU la hauteur de travail disponible dans la fenêtre, déduction faite de ddlb_message
return(this.workSpaceHeight() - 92) // 92 est une estimation de la hauteur de ddlb_message non déployée
end function

public function integer wf_getwswidth ();// renvoie en PBU la largeur de travail disponible dans la fenêtre
return(this.workSpaceWidth())
end function

on w_ancestor_dataentry.create
int iCurrent
call super::create
this.ddlb_message=create ddlb_message
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.ddlb_message
end on

on w_ancestor_dataentry.destroy
call super::destroy
destroy(this.ddlb_message)
end on

event resize;call super::resize;// adapter la position de la ddlb_message à la fenêtre (en tenant compte thème visuel de Windows)
ddlb_message.x = 0
ddlb_message.y = wf_getwsheight()
ddlb_message.width = wf_getwswidth()

// avant nov 2012 et Win 7 :
//integer	li_XP
//
//li_XP = f_adjustHeight()
//
//IF li_XP > 0 THEN
//	ddlb_message.width = this.width - 40
//ELSE
//	ddlb_message.width = this.width - 25
//END IF
//
//ddlb_message.x = 1
//IF this.Hscrollbar THEN
//	ddlb_message.y = this.height - (250 + li_XP)
//ELSE
//	ddlb_message.y = this.height - (190 + li_XP)
//END IF
//
end event

event ue_open;call super::ue_open;This.event post ue_init_win()
end event

event ue_closequery;call super::ue_closequery;// SetFocus permet de donner le focus à la fenêtre quand la demande de fermeture provient du frame MDI plutôt que
// de la fenêtre elle-même
This.SetFocus()

// demande d'enregistrement avant de quitter si la fenêtre contient des données modifiées ET
// si l'utilisateur a le droit de modifier les données
IF wf_IsActif() AND wf_canupdate() THEN
	CHOOSE CASE gu_dwservices.uf_confirm_cancel(idw_dwlist)
		CASE 1
			IF this.event ue_enregistrer() = 1 THEN
				return(0)
			ELSE
				return(1)
			END IF
		CASE 2
			return(0)
		CASE 3
			return(1)
	END CHOOSE
ELSE
	return(0)
END IF

return(0)
end event

type ddlb_message from uo_ddlb_message within w_ancestor_dataentry
integer y = 2128
integer width = 2469
integer height = 368
end type

