//objectcomments Sélection qualités germinatives du lot (voir document fournisseur)
forward
global type w_l_registre_qgerm from w_ancestor
end type
type cb_ok from uo_cb_ok within w_l_registre_qgerm
end type
type cb_cancel from uo_cb_cancel within w_l_registre_qgerm
end type
type dw_1 from uo_ancestor_dwbrowse within w_l_registre_qgerm
end type
end forward

global type w_l_registre_qgerm from w_ancestor
integer x = 498
integer width = 2784
integer height = 2084
string title = "Sélection des qualités germimnatives des graines"
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
cb_ok cb_ok
cb_cancel cb_cancel
dw_1 dw_1
end type
global w_l_registre_qgerm w_l_registre_qgerm

type variables

end variables

on w_l_registre_qgerm.create
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

on w_l_registre_qgerm.destroy
call super::destroy
destroy(this.cb_ok)
destroy(this.cb_cancel)
destroy(this.dw_1)
end on

event ue_closebyxaccepted;cb_cancel.event clicked()
end event

event ue_open;call super::ue_open;str_params	lstr_params
string		ls_reflot, ls_where, ls_sql

// récupérer les paramètres (n° lot)
lstr_params = Message.PowerObjectParm
IF NOT IsValid(lstr_params) THEN 
	gu_message.uf_error("Erreur d'argument")
	post close(this)
	return
END IF
IF IsValid(lstr_params) THEN 
	CHOOSE CASE upperbound(lstr_params.a_param)
		CASE 1
			ls_reflot = lstr_params.a_param[1]
		CASE ELSE
			gu_message.uf_error("Erreur d'argument")
			post close(this)
			return
	END CHOOSE
END IF

IF f_isEmptyString(ls_reflot) THEN
	gu_message.uf_error("Erreur d'argument")
	post close(this)
	return
END IF

// assigner les couleurs pour les lignes paires et impaires du DW principal
gu_dwservices.uf_setbrowsecol(dw_1)

// pas de modification du tri possible
dw_1.uf_sort(FALSE)


// adapter la requête et lire les données
ls_where = "ref_lot = '" + ls_reflot + "'"
ls_sql = dw_1.GetSqlSelect()
ls_sql = f_modifySQL(ls_sql, ls_where, "", "")
dw_1.setSQLSelect(ls_sql)
dw_1.setTransObject(SQLCA)
dw_1.retrieve(ls_reflot)


end event

type cb_ok from uo_cb_ok within w_l_registre_qgerm
integer x = 823
integer y = 1856
integer width = 384
end type

event clicked;str_params	lstr_params
long 			ll_selrow

// renvoyer la row sélectionnée
ll_selrow = dw_1.GetRow()
IF ll_selrow > 0 THEN
	lstr_params.a_param[1] = dw_1.Object.num_qgerm[ll_selrow]
	CloseWithReturn(Parent, lstr_params)
ELSE
	CloseWithReturn(Parent, -1)
END IF

end event

type cb_cancel from uo_cb_cancel within w_l_registre_qgerm
integer x = 1463
integer y = 1856
integer width = 384
string text = "Abandonner"
end type

event clicked;CloseWithReturn(Parent, -1)
end event

type dw_1 from uo_ancestor_dwbrowse within w_l_registre_qgerm
integer width = 2761
integer height = 1824
integer taborder = 110
string dataobject = "d_l_registre_qgerm"
boolean hscrollbar = true
boolean vscrollbar = true
boolean border = true
boolean hsplitscroll = true
end type

event doubleclicked;call super::doubleclicked;cb_ok.event post clicked()
end event

