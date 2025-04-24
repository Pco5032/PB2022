//objectcomments Encodage des options d'impression du dico des provenances recommandables
forward
global type w_option_dico_prov from w_ancestor
end type
type cb_cancel from uo_cb_cancel within w_option_dico_prov
end type
type cb_ok from uo_cb_ok within w_option_dico_prov
end type
type dw_1 from uo_datawindow_singlerow within w_option_dico_prov
end type
end forward

global type w_option_dico_prov from w_ancestor
integer width = 1627
integer height = 600
string title = "Options d~'impression du dictionnaire des provenances"
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
cb_cancel cb_cancel
cb_ok cb_ok
dw_1 dw_1
end type
global w_option_dico_prov w_option_dico_prov

on w_option_dico_prov.create
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

on w_option_dico_prov.destroy
call super::destroy
destroy(this.cb_cancel)
destroy(this.cb_ok)
destroy(this.dw_1)
end on

event ue_open;call super::ue_open;f_centerInMdi(this)

dw_1.reset()
dw_1.retrieve()
end event

event ue_closebyxaccepted;call super::ue_closebyxaccepted;cb_cancel.event clicked()
end event

type cb_cancel from uo_cb_cancel within w_option_dico_prov
integer x = 859
integer y = 336
end type

event clicked;call super::clicked;CloseWithReturn(Parent, -1)
end event

type cb_ok from uo_cb_ok within w_option_dico_prov
integer x = 293
integer y = 336
end type

event clicked;call super::clicked;// structure renvoyée à l'appelant :
// [1] = date de mise à jour
str_params	lstr_params

IF dw_1.event ue_checkAll() < 0 THEN 
	dw_1.setFocus()
	return
END IF

lstr_params.a_param[1] = dw_1.object.dt_maj_dico[1]
CloseWithReturn(Parent, lstr_params)
end event

type dw_1 from uo_datawindow_singlerow within w_option_dico_prov
integer width = 1609
integer height = 288
integer taborder = 10
string dataobject = "d_rpt_option_dico_prov"
end type

event ue_checkitem;call super::ue_checkitem;date	l_date

CHOOSE CASE as_item
	CASE "dt_maj_dico"
		l_date = gu_datetime.uf_dfromdt(as_data)
		IF isNull(l_date) THEN
			as_message = "Veuillez introduire la date de mise à jour du dictionnaire"
			return(-1)
		END IF
		IF year(l_date) < 1990 OR year(l_date) > 2050 THEN
			as_message = "Date incorrecte"
			return(-1)
		END IF
END CHOOSE



end event

