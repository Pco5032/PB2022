//objectcomments Sélection d'un utilisateur
forward
global type w_l_users from w_ancestor
end type
type sle_nom from uo_sle within w_l_users
end type
type st_1 from uo_statictext within w_l_users
end type
type cb_ok from uo_cb_ok within w_l_users
end type
type cb_cancel from uo_cb_cancel within w_l_users
end type
type dw_1 from uo_ancestor_dwbrowse within w_l_users
end type
end forward

global type w_l_users from w_ancestor
integer x = 498
integer width = 3191
integer height = 2028
string title = "Sélection d~'un utilisateur"
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
sle_nom sle_nom
st_1 st_1
cb_ok cb_ok
cb_cancel cb_cancel
dw_1 dw_1
end type
global w_l_users w_l_users

event ue_postopen;call super::ue_postopen;dw_1.retrieve()

end event

on w_l_users.create
int iCurrent
call super::create
this.sle_nom=create sle_nom
this.st_1=create st_1
this.cb_ok=create cb_ok
this.cb_cancel=create cb_cancel
this.dw_1=create dw_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.sle_nom
this.Control[iCurrent+2]=this.st_1
this.Control[iCurrent+3]=this.cb_ok
this.Control[iCurrent+4]=this.cb_cancel
this.Control[iCurrent+5]=this.dw_1
end on

on w_l_users.destroy
call super::destroy
destroy(this.sle_nom)
destroy(this.st_1)
destroy(this.cb_ok)
destroy(this.cb_cancel)
destroy(this.dw_1)
end on

event ue_closebyxaccepted;cb_cancel.event clicked()
end event

event ue_open;call super::ue_open;str_params	lstr_params
boolean		lb_extended

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

f_centerinMdi(this)
end event

type sle_nom from uo_sle within w_l_users
event we_changed pbm_enchange
integer x = 1189
integer width = 1006
integer height = 80
integer taborder = 10
integer textsize = -9
textcase textcase = upper!
end type

event we_changed;string	ls_nom

ls_nom = gu_stringservices.uf_removeaccent(this.text, "U")
dw_1.SetFilter("match(f_removeAccent(nom,'U'), ~"" + gu_stringservices.uf_embeddbq(ls_nom) + "~")")
dw_1.Filter()
end event

type st_1 from uo_statictext within w_l_users
integer x = 475
integer y = 8
integer width = 713
string text = "Filtre sur le nom de l~'agent"
end type

type cb_ok from uo_cb_ok within w_l_users
integer x = 1079
integer y = 1792
integer width = 384
integer taborder = 30
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
		lstr_params.a_param[li_param] = dw_1.Object.userid[ll_selrow]
		ll_selrow = dw_1.GetSelectedRow(ll_selrow)
	LOOP
ELSE
	li_param++
	lstr_params.a_param[li_param] = dw_1.Object.userid[dw_1.GetRow()]
END IF

IF li_param = 0 THEN
	CloseWithReturn(Parent, -1)
ELSE
	CloseWithReturn(Parent, lstr_params)
END IF
end event

type cb_cancel from uo_cb_cancel within w_l_users
integer x = 1627
integer y = 1792
integer width = 384
integer taborder = 40
string text = "Abandonner"
end type

event clicked;CloseWithReturn(Parent, -1)
end event

type dw_1 from uo_ancestor_dwbrowse within w_l_users
integer y = 96
integer width = 3163
integer height = 1664
integer taborder = 20
string dataobject = "d_l_users"
boolean vscrollbar = true
boolean border = true
end type

event doubleclicked;call super::doubleclicked;cb_ok.event post clicked()
end event

