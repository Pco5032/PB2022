//objectcomments Sélection d'un test de viabilite
forward
global type w_l_viabilite from w_ancestor
end type
type cb_ok from uo_cb_ok within w_l_viabilite
end type
type cb_cancel from uo_cb_cancel within w_l_viabilite
end type
type dw_1 from uo_ancestor_dwbrowse within w_l_viabilite
end type
end forward

global type w_l_viabilite from w_ancestor
integer x = 498
integer width = 2981
integer height = 1916
string title = "Sélection d~'un test de viabilité"
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
cb_ok cb_ok
cb_cancel cb_cancel
dw_1 dw_1
end type
global w_l_viabilite w_l_viabilite

type variables
boolean	ib_renvoiLOT
end variables

event ue_postopen;call super::ue_postopen;SetPointer(hourGlass!)
dw_1.retrieve()

end event

on w_l_viabilite.create
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

on w_l_viabilite.destroy
call super::destroy
destroy(this.cb_ok)
destroy(this.cb_cancel)
destroy(this.dw_1)
end on

event ue_closebyxaccepted;cb_cancel.event clicked()
end event

event ue_open;call super::ue_open;str_params	lstr_params
boolean		lb_extended
string		ls_sql, ls_reflot

lb_extended = FALSE
ib_renvoiLOT = FALSE

// récupérer les paramètres (réf.lot, renvoyer réf.lot ou pas, sélection étendue ou pas)
lstr_params = Message.PowerObjectParm
IF IsValid(lstr_params) THEN 
	CHOOSE CASE upperbound(lstr_params.a_param)
		CASE 0
			lb_extended = FALSE
		CASE 1
			lb_extended = lstr_params.a_param[1]
		CASE 2
			ls_reflot = string(lstr_params.a_param[1])
			lb_extended = lstr_params.a_param[2]
		CASE 3
			ls_reflot = string(lstr_params.a_param[1])
			ib_renvoiLOT = lstr_params.a_param[2]
			lb_extended = lstr_params.a_param[3]
	END CHOOSE
END IF

// tenir compte de la référence du lot éventuellement passé en paramètre
IF NOT f_isEmptyString(ls_reflot) THEN
	ls_sql = dw_1.GetSqlSelect()
	ls_sql = f_modifySQL(ls_sql, "graine_viabilite.ref_lot = '" + ls_reflot + "'", "", "")
	dw_1.SetSQLSelect(ls_sql)
END IF

// assigner les couleurs pour les lignes paires et impaires du DW principal
gu_dwservices.uf_setbrowsecol(dw_1)

// sens du tri=croissant en commençant
gb_sort_asc = true

// autoriser ou pas la sélection de plusieurs code en fonction du paramètre
dw_1.uf_extendedselect(lb_extended)

end event

type cb_ok from uo_cb_ok within w_l_viabilite
integer x = 951
integer y = 1680
integer width = 384
end type

event clicked;str_params	lstr_params
long 			ll_selrow
integer		li_param

// si multisélection autorisée, renvoyer toutes les rows sélectionnées, sinon renvoyer row en cours
li_param=0
IF dw_1.uf_extendedselect() THEN
	ll_selrow = dw_1.GetSelectedRow(0)
	DO WHILE ll_selrow > 0
		IF ib_renvoiLOT THEN
			li_param++
			lstr_params.a_param[li_param] = dw_1.Object.ref_lot[ll_selrow]
		END IF
		li_param++
		lstr_params.a_param[li_param] = dw_1.Object.num_test[ll_selrow]
		ll_selrow = dw_1.GetSelectedRow(ll_selrow)
	LOOP
ELSE
	ll_selrow = dw_1.GetRow()
	IF ll_selrow > 0 THEN
		IF ib_renvoiLOT THEN
			li_param++
			lstr_params.a_param[li_param] = dw_1.Object.ref_lot[ll_selrow]
		END IF
		li_param++
		lstr_params.a_param[li_param] = dw_1.Object.num_test[ll_selrow]
	END IF
END IF

IF li_param = 0 THEN
	CloseWithReturn(Parent, -1)
ELSE
	CloseWithReturn(Parent, lstr_params)
END IF
end event

type cb_cancel from uo_cb_cancel within w_l_viabilite
integer x = 1591
integer y = 1680
integer width = 384
string text = "Abandonner"
end type

event clicked;CloseWithReturn(Parent, -1)
end event

type dw_1 from uo_ancestor_dwbrowse within w_l_viabilite
integer width = 2962
integer height = 1648
integer taborder = 50
string dataobject = "d_l_viabilite"
boolean hscrollbar = true
boolean vscrollbar = true
boolean border = true
boolean hsplitscroll = true
end type

event doubleclicked;call super::doubleclicked;cb_ok.event post clicked()
end event

