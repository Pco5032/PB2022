//objectcomments Sélection espèce DNF
forward
global type w_l_codesp from w_ancestor
end type
type cb_ok from uo_cb_ok within w_l_codesp
end type
type cb_cancel from uo_cb_cancel within w_l_codesp
end type
type dw_1 from uo_ancestor_dwbrowse within w_l_codesp
end type
end forward

global type w_l_codesp from w_ancestor
integer x = 498
integer width = 1221
integer height = 1488
string title = "Sélection d~'une espèce"
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
cb_ok cb_ok
cb_cancel cb_cancel
dw_1 dw_1
end type
global w_l_codesp w_l_codesp

type variables
string	is_preselect
end variables

event open;call super::open;str_params	lstr_params
boolean		lb_extended

// récupérer les paramètres (sélection étendue ou pas, liste des codes à préselectionner)
lb_extended = FALSE
lstr_params = Message.PowerObjectParm
IF IsValid(lstr_params) THEN 
	CHOOSE CASE upperbound(lstr_params.a_param)
		CASE 0
			lb_extended = FALSE
		CASE 1
			lb_extended = lstr_params.a_param[1]
		CASE 2
			lb_extended = lstr_params.a_param[1]
			is_preselect = lstr_params.a_param[2]
	END CHOOSE
END IF

// assigner les couleurs pour les lignes paires et impaires du DW principal
gu_dwservices.uf_setbrowsecol(dw_1)

// sens du tri=croissant en commençant
gb_sort_asc = true

// autoriser ou pas la sélection de plusieurs code en fonction du paramètre
dw_1.uf_extendedselect(lb_extended)
end event

event ue_postopen;call super::ue_postopen;string	ls_preselect[]
integer	li_i
long		ll_row

// lecture
dw_1.retrieve()

// s'il y a des codes à préselectionner, le faire maintenant
IF NOT f_IsEmptyString(is_preselect) THEN
	f_parse(is_preselect, ",", ls_preselect)
	FOR li_i = 1 TO upperbound(ls_preselect)
		ll_row = dw_1.find("sp='" + ls_preselect[li_i] + "'", 1, dw_1.RowCount())
		IF ll_row > 0 THEN
			dw_1.selectrow(ll_row, TRUE)
		END IF
	NEXT
END IF
end event

on w_l_codesp.create
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

on w_l_codesp.destroy
call super::destroy
destroy(this.cb_ok)
destroy(this.cb_cancel)
destroy(this.dw_1)
end on

event ue_closebyxaccepted;cb_cancel.triggerEvent("clicked")
end event

type cb_ok from uo_cb_ok within w_l_codesp
integer x = 146
integer y = 1264
integer width = 384
end type

event clicked;str_params	lstr_params
long 			ll_selrow
integer		li_param

li_param=0

// si multisélection autorisée, renvoyer toutes les rows sélectionnées, sinon renvoyer row en cours
IF dw_1.uf_extendedselect() THEN
	ll_selrow = dw_1.GetSelectedRow(0)
	DO WHILE ll_selrow > 0
		li_param++
		lstr_params.a_param[li_param] = dw_1.Object.sp[ll_selrow]
		ll_selrow = dw_1.GetSelectedRow(ll_selrow)
	LOOP
ELSE
	ll_selrow = dw_1.GetRow()
	IF ll_selrow > 0 THEN
		li_param++
		lstr_params.a_param[li_param] = dw_1.Object.sp[ll_selrow]
	END IF
END IF

IF li_param = 0 THEN
	IF dw_1.uf_extendedselect() THEN
		CloseWithReturn(Parent, lstr_params)
	ELSE
		CloseWithReturn(Parent, -1)
	END IF
ELSE
	CloseWithReturn(Parent, lstr_params)
END IF
end event

type cb_cancel from uo_cb_cancel within w_l_codesp
integer x = 677
integer y = 1264
integer width = 384
string text = "Abandonner"
end type

event clicked;CloseWithReturn(Parent, -1)
end event

type dw_1 from uo_ancestor_dwbrowse within w_l_codesp
integer width = 1189
integer height = 1216
string dataobject = "d_l_codesp"
boolean vscrollbar = true
boolean border = true
end type

event doubleclicked;call super::doubleclicked;cb_ok.postevent(clicked!)
end event

