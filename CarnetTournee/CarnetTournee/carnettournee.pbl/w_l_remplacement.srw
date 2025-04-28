//objectcomments Liste des remplacements encodés
forward
global type w_l_remplacement from w_ancestor
end type
type cb_cancel from uo_cb_cancel within w_l_remplacement
end type
type cb_ok from uo_cb_ok within w_l_remplacement
end type
type dw_1 from uo_ancestor_dwbrowse within w_l_remplacement
end type
end forward

global type w_l_remplacement from w_ancestor
string tag = "TEXT_00600"
integer x = 498
integer width = 3250
integer height = 1964
string title = "Remplacements"
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
cb_cancel cb_cancel
cb_ok cb_ok
dw_1 dw_1
end type
global w_l_remplacement w_l_remplacement

event ue_postopen;call super::ue_postopen;dw_1.retrieve()

end event

on w_l_remplacement.create
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

on w_l_remplacement.destroy
call super::destroy
destroy(this.cb_cancel)
destroy(this.cb_ok)
destroy(this.dw_1)
end on

event ue_closebyxaccepted;cb_cancel.Event clicked()
end event

event ue_open;call super::ue_open;f_centerInMdi(this)

// assigner les couleurs pour les lignes paires et impaires du DW principal
gu_dwservices.uf_setbrowsecol(dw_1)

// sens du tri=croissant en commençant
gb_sort_asc = true


end event

event resize;call super::resize;dw_1.width = newwidth
dw_1.height = newheight - dw_1.y - cb_ok.height - 64
end event

type cb_cancel from uo_cb_cancel within w_l_remplacement
string tag = "TEXT_00028"
integer x = 1682
integer y = 1728
integer taborder = 30
end type

event clicked;call super::clicked;CloseWithReturn(Parent, -1)
end event

type cb_ok from uo_cb_ok within w_l_remplacement
string tag = "TEXT_00027"
integer x = 1061
integer y = 1728
integer taborder = 20
end type

event clicked;call super::clicked;str_params	lstr_params
long 			ll_selrow
integer		li_param

li_param=0
ll_selrow = dw_1.GetSelectedRow(0)

IF dw_1.GetRow() > 0 THEN
	li_param++
	lstr_params.a_param[li_param] = dw_1.Object.remplacement_resp_matricule[dw_1.GetRow()]
END IF

IF li_param = 0 THEN
	CloseWithReturn(Parent, -1)
ELSE
	CloseWithReturn(Parent, lstr_params)
END IF
end event

type dw_1 from uo_ancestor_dwbrowse within w_l_remplacement
integer width = 3218
integer height = 1712
integer taborder = 10
string dataobject = "d_l_remplacement"
boolean hscrollbar = true
boolean vscrollbar = true
boolean border = true
end type

event doubleclicked;call super::doubleclicked;cb_ok.postevent(clicked!)
end event

