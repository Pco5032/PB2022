//objectcomments Sélection cantonnement (CAN)
forward
global type w_l_can from w_ancestor
end type
type cb_cancel from uo_cb_cancel within w_l_can
end type
type cb_ok from uo_cb_ok within w_l_can
end type
type dw_1 from uo_ancestor_dwbrowse within w_l_can
end type
end forward

global type w_l_can from w_ancestor
integer x = 498
integer width = 1728
integer height = 1740
string title = "Sélection d~'un cantonnement"
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
cb_cancel cb_cancel
cb_ok cb_ok
dw_1 dw_1
end type
global w_l_can w_l_can

type variables

end variables

event ue_postopen;call super::ue_postopen;dw_1.retrieve()
dw_1.SetFocus()

end event

on w_l_can.create
int iCurrent
call super::create
this.cb_cancel=create cb_cancel
this.cb_ok=create cb_ok
this.dw_1=create dw_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_cancel
this.Control[iCurrent+2]=this.cb_ok
this.Control[iCurrent+3]=this.dw_1
end on

on w_l_can.destroy
call super::destroy
destroy(this.cb_cancel)
destroy(this.cb_ok)
destroy(this.dw_1)
end on

event ue_closebyxaccepted;cb_cancel.Event clicked()
end event

event ue_open;call super::ue_open;str_params	lstr_params
boolean		lb_extended

f_centerInMdi(this)

// récupérer les paramètres (sélection étendue ou pas)
lstr_params = Message.PowerObjectParm

lb_extended = FALSE

IF IsValid(lstr_params) THEN 
	CHOOSE CASE upperbound(lstr_params.a_param)
		CASE 0
			lb_extended = FALSE
		CASE 1
			lb_extended = lstr_params.a_param[1]
	END CHOOSE
END IF

// autoriser ou pas la sélection de plusieurs code en fonction du paramètre
dw_1.uf_extendedselect(lb_extended)

// assigner les couleurs pour les lignes paires et impaires du DW principal
gu_dwservices.uf_setbrowsecol(dw_1)

// sens du tri=croissant en commençant
gb_sort_asc = true
end event

type cb_cancel from uo_cb_cancel within w_l_can
integer x = 969
integer y = 1488
integer taborder = 40
end type

event clicked;call super::clicked;CloseWithReturn(Parent, -1)
end event

type cb_ok from uo_cb_ok within w_l_can
integer x = 384
integer y = 1488
integer taborder = 30
end type

event clicked;call super::clicked;// renvoyer info de la (ou des) row(s) sélectionnée(s) suivant valeur de ib_extendedselect
integer	li_param
long		ll_selrow
str_params	lstr_params

li_param=0

IF dw_1.uf_extendedselect() THEN
	ll_selrow = dw_1.GetSelectedRow(0)
	DO WHILE ll_selrow > 0
		li_param++
		lstr_params.a_param[li_param] = dw_1.Object.can[ll_selrow]
		ll_selrow = dw_1.GetSelectedRow(ll_selrow)
	LOOP
ELSE
	ll_selrow = dw_1.GetRow()
	IF ll_selrow > 0 THEN
		li_param++
		lstr_params.a_param[li_param] = dw_1.Object.can[ll_selrow]
	END IF
END IF

IF li_param = 0 THEN
	CloseWithReturn(Parent, -1)
ELSE
	CloseWithReturn(Parent, lstr_params)
END IF

end event

type dw_1 from uo_ancestor_dwbrowse within w_l_can
integer width = 1701
integer height = 1456
integer taborder = 10
string title = ""
string dataobject = "d_l_can"
boolean hscrollbar = true
boolean vscrollbar = true
boolean border = true
end type

event doubleclicked;call super::doubleclicked;cb_ok.postevent(clicked!)
end event

