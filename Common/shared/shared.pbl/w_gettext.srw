//objectcomments Encodage d'un paramètre libre (texte)
forward
global type w_gettext from w_ancestor
end type
type st_1 from uo_statictext within w_gettext
end type
type sle_1 from uo_sle within w_gettext
end type
type cb_cancel from uo_cb_cancel within w_gettext
end type
type cb_ok from uo_cb_ok within w_gettext
end type
end forward

global type w_gettext from w_ancestor
integer width = 1344
integer height = 560
string title = ""
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
st_1 st_1
sle_1 sle_1
cb_cancel cb_cancel
cb_ok cb_ok
end type
global w_gettext w_gettext

event ue_open;call super::ue_open;//++++++++++++++++++++++++++++++++++++++++++
// Instructions de la fenêtre appelante :
//++++++++++++++++++++++++++++++++++++++++++
//string ls_text
//str_Params lstr_Params
//
//lstr_Params.a_param[1]  = as_label
//lstr_Params.a_param[2]  = as_text
//
//OpenWithParm(W_GetText, lstr_Params)
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
		sle_1.text = lstr_params.a_param[2]
	END IF
END IF
end event

on w_gettext.create
int iCurrent
call super::create
this.st_1=create st_1
this.sle_1=create sle_1
this.cb_cancel=create cb_cancel
this.cb_ok=create cb_ok
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.st_1
this.Control[iCurrent+2]=this.sle_1
this.Control[iCurrent+3]=this.cb_cancel
this.Control[iCurrent+4]=this.cb_ok
end on

on w_gettext.destroy
call super::destroy
destroy(this.st_1)
destroy(this.sle_1)
destroy(this.cb_cancel)
destroy(this.cb_ok)
end on

event ue_closebyxaccepted;call super::ue_closebyxaccepted;cb_cancel.Event clicked()
end event

type st_1 from uo_statictext within w_gettext
integer x = 18
integer y = 16
integer width = 1280
integer height = 128
integer weight = 700
long textcolor = 8388608
string text = ""
alignment alignment = center!
end type

type sle_1 from uo_sle within w_gettext
integer x = 18
integer y = 160
integer width = 1280
integer height = 96
integer taborder = 10
integer textsize = -9
end type

type cb_cancel from uo_cb_cancel within w_gettext
string tag = "TEXT_00028"
integer x = 731
integer y = 304
integer taborder = 20
end type

event clicked;call super::clicked;CloseWithReturn (Parent, -1)
end event

type cb_ok from uo_cb_ok within w_gettext
string tag = "TEXT_00027"
integer x = 183
integer y = 304
integer taborder = 10
end type

event clicked;call super::clicked;CloseWithReturn (Parent, sle_1.text)
end event

