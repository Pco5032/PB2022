//objectcomments Sélection code CHAMP de table TRADUC
forward
global type w_l_champtraduc from w_ancestor
end type
type cb_cancel from uo_cb_cancel within w_l_champtraduc
end type
type cb_ok from uo_cb_ok within w_l_champtraduc
end type
type dw_1 from uo_ancestor_dwbrowse within w_l_champtraduc
end type
end forward

global type w_l_champtraduc from w_ancestor
integer x = 498
integer width = 1001
integer height = 1612
string title = "Sélection classe traduction"
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
cb_cancel cb_cancel
cb_ok cb_ok
dw_1 dw_1
end type
global w_l_champtraduc w_l_champtraduc

event ue_postopen;call super::ue_postopen;dw_1.retrieve()

end event

on w_l_champtraduc.create
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

on w_l_champtraduc.destroy
call super::destroy
destroy(this.cb_cancel)
destroy(this.cb_ok)
destroy(this.dw_1)
end on

event ue_closebyxaccepted;cb_cancel.Event clicked()
end event

event ue_open;call super::ue_open;str_params	lstr_params
boolean		lb_extended

// récupérer le paramètre (sélection étendue ou pas)
lstr_params = Message.PowerObjectParm
IF upperbound(lstr_params.a_param) = 0 THEN
	lb_extended = FALSE
ELSE
	lb_extended = lstr_params.a_param[1]
END IF

// assigner les couleurs pour les lignes paires et impaires du DW principal
gu_dwservices.uf_setbrowsecol(dw_1)

// sens du tri=croissant en commençant
gb_sort_asc = true

// autoriser ou pas la sélection de plusieurs code en fonction du paramètre
dw_1.uf_extendedselect(lb_extended)
end event

type cb_cancel from uo_cb_cancel within w_l_champtraduc
integer x = 549
integer y = 1376
integer width = 411
integer taborder = 40
end type

event clicked;call super::clicked;CloseWithReturn(Parent, -1)
end event

type cb_ok from uo_cb_ok within w_l_champtraduc
integer x = 37
integer y = 1376
integer width = 411
integer taborder = 30
end type

event clicked;call super::clicked;str_params	lstr_params
integer		li_param
long 			ll_selrow

li_param=0
ll_selrow = dw_1.GetSelectedRow(0)

// si multisélection autorisée, renvoyer toutes les rows sélectionnées, sinon renvoyer row en cours
IF dw_1.uf_extendedselect() THEN
	DO WHILE ll_selrow > 0
		li_param++
		lstr_params.a_param[li_param] = dw_1.Object.champ[ll_selrow]
		ll_selrow = dw_1.GetSelectedRow(ll_selrow)
	LOOP
ELSE
	li_param++
	lstr_params.a_param[li_param] = dw_1.Object.champ[dw_1.GetRow()]
END IF

IF li_param = 0 THEN
	CloseWithReturn(Parent, -1)
ELSE
	CloseWithReturn(Parent, lstr_params)
END IF
end event

type dw_1 from uo_ancestor_dwbrowse within w_l_champtraduc
integer width = 969
integer height = 1328
integer taborder = 10
string dataobject = "d_l_champtraduc"
boolean hscrollbar = true
boolean vscrollbar = true
boolean border = true
end type

event doubleclicked;call super::doubleclicked;cb_ok.postevent(clicked!)
end event

