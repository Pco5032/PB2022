//objectcomments Encodage d'un texte libre via un MLE
forward
global type w_getlongtext from w_ancestor
end type
type mle_1 from uo_mle within w_getlongtext
end type
type st_1 from uo_statictext within w_getlongtext
end type
type cb_cancel from uo_cb_cancel within w_getlongtext
end type
type cb_ok from uo_cb_ok within w_getlongtext
end type
end forward

global type w_getlongtext from w_ancestor
integer width = 3214
integer height = 2060
string title = ""
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
mle_1 mle_1
st_1 st_1
cb_cancel cb_cancel
cb_ok cb_ok
end type
global w_getlongtext w_getlongtext

event ue_open;call super::ue_open;//++++++++++++++++++++++++++++++++++++++++++
// Instructions de la fenêtre appelante :
//++++++++++++++++++++++++++++++++++++++++++
//string		 ls_text
//str_Params lstr_Params
//
//lstr_Params.a_param[1]  = as_label
//lstr_Params.a_param[2]  = as_text
//
//OpenWithParm(W_GetLongText, lstr_Params)
//ls_text=Message.StringParm
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
		st_1.text = lstr_params.a_param[1]
	END IF
	IF UpperBound(lstr_params.a_param) >= 2 THEN
		mle_1.text = lstr_params.a_param[2]
	END IF
END IF
end event

on w_getlongtext.create
int iCurrent
call super::create
this.mle_1=create mle_1
this.st_1=create st_1
this.cb_cancel=create cb_cancel
this.cb_ok=create cb_ok
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.mle_1
this.Control[iCurrent+2]=this.st_1
this.Control[iCurrent+3]=this.cb_cancel
this.Control[iCurrent+4]=this.cb_ok
end on

on w_getlongtext.destroy
call super::destroy
destroy(this.mle_1)
destroy(this.st_1)
destroy(this.cb_cancel)
destroy(this.cb_ok)
end on

event ue_closebyxaccepted;call super::ue_closebyxaccepted;cb_cancel.Event clicked()
end event

type mle_1 from uo_mle within w_getlongtext
integer y = 80
integer width = 3200
integer height = 1712
integer taborder = 20
boolean vscrollbar = true
end type

type st_1 from uo_statictext within w_getlongtext
integer width = 3200
integer height = 80
integer weight = 700
long textcolor = 8388608
string text = ""
alignment alignment = center!
end type

type cb_cancel from uo_cb_cancel within w_getlongtext
string tag = "TEXT_00028"
integer x = 1646
integer y = 1824
integer taborder = 20
end type

event clicked;call super::clicked;CloseWithReturn (Parent, -1)
end event

type cb_ok from uo_cb_ok within w_getlongtext
string tag = "TEXT_00027"
integer x = 1097
integer y = 1824
integer taborder = 10
end type

event clicked;call super::clicked;CloseWithReturn (Parent, mle_1.text)
end event

