//objectcomments Gestion des compteurs
forward
global type w_cpteur from w_ancestor_dataentry
end type
type dw_1 from uo_datawindow_multiplerow within w_cpteur
end type
type p_1 from picture within w_cpteur
end type
type cb_init from uo_cb within w_cpteur
end type
end forward

global type w_cpteur from w_ancestor_dataentry
integer width = 3474
integer height = 3060
string title = "Compteurs"
boolean maxbox = true
boolean resizable = true
dw_1 dw_1
p_1 p_1
cb_init cb_init
end type
global w_cpteur w_cpteur

type variables
uo_cpteur	iu_cpteur
end variables

on w_cpteur.create
int iCurrent
call super::create
this.dw_1=create dw_1
this.p_1=create p_1
this.cb_init=create cb_init
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_1
this.Control[iCurrent+2]=this.p_1
this.Control[iCurrent+3]=this.cb_init
end on

on w_cpteur.destroy
call super::destroy
destroy(this.dw_1)
destroy(this.p_1)
destroy(this.cb_init)
end on

event open;call super::open;iu_cpteur = CREATE uo_cpteur

// icône "ajouter" doit être visible dans le menu
wf_SetItemsToShow({"m_ajouter"})

// initialiser liste des DW modifiables
wf_SetDWList({dw_1})

dw_1.SetRowFocusIndicator(p_1)
dw_1.uf_autoselectrow(FALSE)

// lecture de tous les compteurs
IF dw_1.retrieve() < 0 THEN
	post close(this)
	return
END IF

end event

event ue_init_menu;call super::ue_init_menu;f_menuaction({"m_enregistrer","m_ajouter","m_supprimer","m_abandonner","m_fermer"})
end event

event ue_ajouter;call super::ue_ajouter;dw_1.event ue_addrow()
end event

event ue_enregistrer;call super::ue_enregistrer;// contrôle de validité de tous les champs
IF dw_1.event ue_checkall() < 0 THEN
	dw_1.SetFocus()
	return(-1)
END IF

IF dw_1.event ue_update() = 1 THEN
	post close(this)
	return(1)
ELSE
	populateerror(20000, "")
	gu_message.uf_unexp()
	return(-1)
END IF
end event

event ue_supprimer;call super::ue_supprimer;if f_confirm_del("Voulez-vous supprimer ce compteur ?") = 1 THEN
	dw_1.event ue_delete()
END IF

end event

event ue_init_win;call super::ue_init_win;// la fenêtre contient tout de suite des données actives (le retrieve est déjà fait)
wf_actif(true)

end event

event ue_abandonner;post close(this)
return(0)
end event

event close;call super::close;DESTROY iu_cpteur
end event

event resize;call super::resize;dw_1.width = newwidth
dw_1.height = newheight - 268

cb_init.y = dw_1.height + 60
end event

event ue_open;call super::ue_open;// ne pas logger de message lors de l'utilisation de cette fenêtre
wf_logusage(FALSE)
end event

type ddlb_message from w_ancestor_dataentry`ddlb_message within w_cpteur
integer y = 2800
end type

type dw_1 from uo_datawindow_multiplerow within w_cpteur
integer width = 3438
integer height = 1280
integer taborder = 10
boolean bringtotop = true
string dataobject = "d_cpteur"
boolean vscrollbar = true
boolean border = true
end type

event ue_checkitem;call super::ue_checkitem;CHOOSE CASE as_item
	CASE "usage"
		IF IsNull(as_data) OR LenA(trim(as_data)) = 0 THEN
			as_message = "L'usage du compteur doit être spécifié"
			return(-1)
		END IF
	CASE "lastused"
		IF IsNull(as_data) OR LenA(trim(as_data)) = 0 THEN
			as_message = "La dernière valeur du compteur doit être spécifiée"
			return(-1)
		END IF
	CASE "step"
		IF IsNull(as_data) OR LenA(trim(as_data)) = 0 OR long(as_data) <= 0 THEN
			as_message = "L'incrément doit être spécifié et > 0"
			return(-1)
		END IF
END CHOOSE
return(1)
end event

event ue_checkrow;call super::ue_checkrow;// ajout aux checkrow standard : on ne peut pas avoir 2 compteurs avec le même USAGE et les même ID
long	ll_row
string	ls_condition

IF ancestorreturnvalue = -1 THEN
	return(-1)
ELSE
	ls_condition = "usage = '" + this.object.usage[al_row] + "'"
	IF NOT IsNull(this.object.id1[al_row]) THEN
		ls_condition += " and id1 = '" + this.object.id1[al_row] + "'"
	END IF
	IF NOT IsNull(this.object.id2[al_row]) THEN
		ls_condition += " and id2 = '" + this.object.id2[al_row] + "'"
	END IF
	ll_row = This.Find(ls_condition, 1, This.RowCount())
	IF ll_row > 0 AND ll_row <> al_row THEN
		This.ScrolltoRow(al_row)
		this.SetColumn("usage")
		this.SetFocus()
		gu_message.uf_error("Ce compteur existe déjà")
		return(-1)
	ELSE
		return(1)
	END IF
END IF
end event

type p_1 from picture within w_cpteur
boolean visible = false
integer x = 2487
integer y = 2816
integer width = 73
integer height = 64
boolean bringtotop = true
boolean originalsize = true
string picturename = "..\bmp\currentrow.png"
boolean focusrectangle = false
end type

type cb_init from uo_cb within w_cpteur
integer x = 91
integer y = 2672
integer width = 933
integer height = 96
integer taborder = 20
boolean bringtotop = true
string text = "Initialiser le compteur sélectionné"
end type

event clicked;call super::clicked;// initialisation du compteur (si fonction prévue)
long	ll_row
string	ls_usage

dw_1.accepttext()
ll_row = dw_1.GetRow()
IF ll_row < 1 THEN
	gu_message.uf_info("Veuillez sélectionner un compteur...")
ELSE
	ls_usage = string(dw_1.object.usage[ll_row])
	IF iu_cpteur.uf_resetcompteur(ls_usage) = 1 THEN
		// si réinitialisation OK, relecture de tous les compteurs
		dw_1.retrieve()
	END IF
END IF
end event

