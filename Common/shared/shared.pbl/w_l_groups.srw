﻿//objectcomments Sélection d'un groupe d'utilisateurs
forward
global type w_l_groups from w_ancestor
end type
type cb_ok from uo_cb_ok within w_l_groups
end type
type cb_cancel from uo_cb_cancel within w_l_groups
end type
type dw_1 from uo_ancestor_dwbrowse within w_l_groups
end type
end forward

global type w_l_groups from w_ancestor
integer x = 498
integer width = 1125
integer height = 1560
string title = "Sélection d~'un groupe d~'utilisateurs"
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
cb_ok cb_ok
cb_cancel cb_cancel
dw_1 dw_1
end type
global w_l_groups w_l_groups

event ue_postopen;call super::ue_postopen;dw_1.retrieve()

end event

on w_l_groups.create
int iCurrent
call super::create
this.cb_ok=create cb_ok
this.cb_cancel=create cb_cancel
this.dw_1=create dw_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_ok
this.Control[iCurrent+2]=this.cb_cancel
this.Control[iCurrent+3]=this.dw_1
end on

on w_l_groups.destroy
call super::destroy
destroy(this.cb_ok)
destroy(this.cb_cancel)
destroy(this.dw_1)
end on

event ue_closebyxaccepted;cb_cancel.event clicked()
end event

event ue_open;call super::ue_open;str_params	lstr_params
boolean		lb_extended

f_centerInMdi(this)

// récupérer le paramètre (sélection étendue ou pas)
lstr_params = Message.PowerObjectParm
IF NOT IsValid(lstr_params) THEN 
	lb_extended = FALSE
ELSE
	IF upperbound(lstr_params.a_param) = 0 THEN
		lb_extended = FALSE
	ELSE
		lb_extended = lstr_params.a_param[1]
	END IF
END IF

// ne pas logger de message lors de l'utilisation de cette fenêtre
wf_logusage(FALSE)

// assigner les couleurs pour les lignes paires et impaires du DW principal
gu_dwservices.uf_setbrowsecol(dw_1)

// sens du tri=croissant en commençant
gb_sort_asc = true

// autoriser ou pas la sélection de plusieurs code en fonction du paramètre
dw_1.uf_extendedselect(lb_extended)
end event

type cb_ok from uo_cb_ok within w_l_groups
integer x = 128
integer y = 1328
integer width = 347
integer taborder = 20
end type

event clicked;str_params	lstr_params
long 			ll_selrow
integer		li_param

IF dw_1.RowCount() = 0 THEN 
	cb_cancel.event clicked()
	return
END IF

li_param=0
ll_selrow = dw_1.GetSelectedRow(0)

// si multisélection autorisée, renvoyer toutes les rows sélectionnées, sinon renvoyer row en cours
IF dw_1.uf_extendedselect() THEN
	DO WHILE ll_selrow > 0
		li_param++
		lstr_params.a_param[li_param] = dw_1.Object.groupid[ll_selrow]
		ll_selrow = dw_1.GetSelectedRow(ll_selrow)
	LOOP
ELSE
	li_param++
	lstr_params.a_param[li_param] = dw_1.Object.groupid[dw_1.GetRow()]
END IF

IF li_param = 0 THEN
	CloseWithReturn(Parent, -1)
ELSE
	CloseWithReturn(Parent, lstr_params)
END IF
end event

type cb_cancel from uo_cb_cancel within w_l_groups
integer x = 622
integer y = 1328
integer width = 347
integer taborder = 20
string text = "Abandonner"
end type

event clicked;CloseWithReturn(Parent, -1)
end event

type dw_1 from uo_ancestor_dwbrowse within w_l_groups
integer width = 1097
integer height = 1296
integer taborder = 10
string dataobject = "d_l_groups"
boolean vscrollbar = true
boolean border = true
end type

event doubleclicked;call super::doubleclicked;cb_ok.event post clicked()
end event

