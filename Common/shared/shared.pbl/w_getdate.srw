//objectcomments Encodage d'une date
forward
global type w_getdate from w_ancestor
end type
type em_date from uo_editmask within w_getdate
end type
type st_1 from uo_statictext within w_getdate
end type
type cb_cancel from uo_cb_cancel within w_getdate
end type
type cb_ok from uo_cb_ok within w_getdate
end type
end forward

global type w_getdate from w_ancestor
integer width = 1637
integer height = 656
string title = ""
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
em_date em_date
st_1 st_1
cb_cancel cb_cancel
cb_ok cb_ok
end type
global w_getdate w_getdate

event ue_open;call super::ue_open;//++++++++++++++++++++++++++++++++++++++++++
// Instructions de la fenêtre appelante :
//++++++++++++++++++++++++++++++++++++++++++
//date l_date
//str_Params lstr_Params
//
//lstr_Params.a_param[1]  = ls_label
//lstr_Params.a_param[2]  = l_date
//
//OpenWithParm(W_GetDate, lstr_Params)
// IF IsDate(lstr_Params.a_param[2]) THEN
//		l_date = Date(lstr_Params.a_param[2])
// END IF
//
//+++++++++++++++++++++++++++++++++++++++++

string		ls_label, ls_text
str_params	lstr_params

f_centerinMdi(this)

lstr_params = message.PowerObjectParm
IF NOT IsValid(lstr_params) THEN 
	post close(this)
ELSE
	IF UpperBound(lstr_params.a_param) >= 1 THEN
		st_1.text = string(lstr_params.a_param[1])
	END IF
	IF UpperBound(lstr_params.a_param) >= 2 THEN
		em_date.text = string(lstr_params.a_param[2])
	END IF
END IF
end event

on w_getdate.create
int iCurrent
call super::create
this.em_date=create em_date
this.st_1=create st_1
this.cb_cancel=create cb_cancel
this.cb_ok=create cb_ok
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.em_date
this.Control[iCurrent+2]=this.st_1
this.Control[iCurrent+3]=this.cb_cancel
this.Control[iCurrent+4]=this.cb_ok
end on

on w_getdate.destroy
call super::destroy
destroy(this.em_date)
destroy(this.st_1)
destroy(this.cb_cancel)
destroy(this.cb_ok)
end on

event ue_closebyxaccepted;call super::ue_closebyxaccepted;cb_cancel.Event clicked()
end event

type em_date from uo_editmask within w_getdate
integer x = 603
integer y = 256
integer width = 421
integer height = 96
integer taborder = 10
alignment alignment = center!
maskdatatype maskdatatype = datemask!
string mask = "dd/mm/yyyy"
end type

type st_1 from uo_statictext within w_getdate
integer x = 18
integer y = 16
integer width = 1591
integer height = 208
integer weight = 700
long textcolor = 8388608
string text = ""
alignment alignment = center!
end type

type cb_cancel from uo_cb_cancel within w_getdate
string tag = "TEXT_00028"
integer x = 896
integer y = 400
integer taborder = 20
end type

event clicked;call super::clicked;CloseWithReturn (Parent, -1)

end event

type cb_ok from uo_cb_ok within w_getdate
string tag = "TEXT_00027"
integer x = 329
integer y = 400
integer taborder = 10
end type

event clicked;call super::clicked;// si date valide, la retourner au programme appelant, sinon renvoyer NULL
date l_date
str_params	lstr_params

IF em_date.GetData(l_date) = 1 THEN
	lstr_params.a_param[1] = l_date
	CloseWithReturn (Parent, lstr_params)
ELSE
	lstr_params.a_param[1] = gu_c.d_null
	CloseWithReturn (Parent, lstr_params)
END IF
end event

