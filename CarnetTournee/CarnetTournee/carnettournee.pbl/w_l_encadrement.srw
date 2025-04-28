//objectcomments Liste des responsables déjà encodés
forward
global type w_l_encadrement from w_ancestor
end type
type cb_cancel from uo_cb_cancel within w_l_encadrement
end type
type cb_ok from uo_cb_ok within w_l_encadrement
end type
type dw_1 from uo_ancestor_dwbrowse within w_l_encadrement
end type
end forward

global type w_l_encadrement from w_ancestor
integer x = 498
integer width = 2693
integer height = 1740
string title = "Agents d~'encadrement déjà encodés"
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
cb_cancel cb_cancel
cb_ok cb_ok
dw_1 dw_1
end type
global w_l_encadrement w_l_encadrement

event ue_postopen;call super::ue_postopen;dw_1.retrieve()

end event

on w_l_encadrement.create
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

on w_l_encadrement.destroy
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

// assigner les couleurs pour les lignes paires et impaires du DW principal
gu_dwservices.uf_setbrowsecol(dw_1)

// sens du tri=croissant en commençant
gb_sort_asc = true

// autoriser ou pas la sélection de plusieurs code en fonction du paramètre
dw_1.uf_extendedselect(lb_extended)
end event

event resize;call super::resize;dw_1.width = newwidth
dw_1.height = newheight - dw_1.y - cb_ok.height - 64
end event

type cb_cancel from uo_cb_cancel within w_l_encadrement
integer x = 1426
integer y = 1504
integer taborder = 30
end type

event clicked;call super::clicked;CloseWithReturn(Parent, -1)
end event

type cb_ok from uo_cb_ok within w_l_encadrement
integer x = 805
integer y = 1504
integer taborder = 20
end type

event clicked;call super::clicked;str_params	lstr_params
long 			ll_selrow
integer		li_param

li_param=0
ll_selrow = dw_1.GetSelectedRow(0)

// si multisélection autorisée, renvoyer toutes les rows sélectionnées, sinon renvoyer row en cours
IF dw_1.uf_extendedselect() THEN
	DO WHILE ll_selrow > 0
		li_param++
		lstr_params.a_param[li_param] = dw_1.Object.resp_matricule[ll_selrow]
		ll_selrow = dw_1.GetSelectedRow(ll_selrow)
	LOOP
ELSE
	IF dw_1.GetRow() > 0 THEN
		li_param++
		lstr_params.a_param[li_param] = dw_1.Object.resp_matricule[dw_1.GetRow()]
	END IF
END IF
IF li_param = 0 THEN
	CloseWithReturn(Parent, -1)
ELSE
	CloseWithReturn(Parent, lstr_params)
END IF
end event

type dw_1 from uo_ancestor_dwbrowse within w_l_encadrement
integer width = 2670
integer height = 1456
integer taborder = 10
string dataobject = "d_l_encadrement"
boolean hscrollbar = true
boolean vscrollbar = true
boolean border = true
end type

event doubleclicked;call super::doubleclicked;cb_ok.postevent(clicked!)
end event

