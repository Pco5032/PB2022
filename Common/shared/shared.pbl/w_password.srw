forward
global type w_password from w_ancestor
end type
type cbx_show from uo_cbx within w_password
end type
type st_info from uo_statictext within w_password
end type
type cb_cancel from uo_cb_cancel within w_password
end type
type cb_ok from uo_cb_ok within w_password
end type
type st_1 from uo_statictext within w_password
end type
type sle_password from uo_sle within w_password
end type
end forward

global type w_password from w_ancestor
integer width = 1495
integer height = 588
string title = ""
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
cbx_show cbx_show
st_info st_info
cb_cancel cb_cancel
cb_ok cb_ok
st_1 st_1
sle_password sle_password
end type
global w_password w_password

on w_password.create
int iCurrent
call super::create
this.cbx_show=create cbx_show
this.st_info=create st_info
this.cb_cancel=create cb_cancel
this.cb_ok=create cb_ok
this.st_1=create st_1
this.sle_password=create sle_password
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cbx_show
this.Control[iCurrent+2]=this.st_info
this.Control[iCurrent+3]=this.cb_cancel
this.Control[iCurrent+4]=this.cb_ok
this.Control[iCurrent+5]=this.st_1
this.Control[iCurrent+6]=this.sle_password
end on

on w_password.destroy
call super::destroy
destroy(this.cbx_show)
destroy(this.st_info)
destroy(this.cb_cancel)
destroy(this.cb_ok)
destroy(this.st_1)
destroy(this.sle_password)
end on

event ue_open;call super::ue_open;str_params	lstr_params

f_centerInMdi(this)

// récupération du paramètre (titre, message d'info éventuel, pwd actuel)
lstr_params = message.powerobjectParm

IF upperbound(lstr_params.a_param) = 3 THEN
	this.title = lstr_params.a_param[1]
	st_info.text = lstr_params.a_param[2]
	sle_password.text = lstr_params.a_param[3]
END IF

IF f_isEmptyString(st_info.text) THEN
	sle_password.y = sle_password.y - 32
	st_1.y = sle_password.y
END IF
end event

event ue_closebyxaccepted;call super::ue_closebyxaccepted;cb_cancel.event clicked()
end event

type cbx_show from uo_cbx within w_password
integer x = 1170
integer y = 176
integer width = 293
integer height = 64
integer textsize = -9
string text = "Montrer"
end type

event clicked;call super::clicked;IF this.checked THEN
	sle_password.Password = FALSE
ELSE
	sle_password.Password = TRUE
END IF

end event

type st_info from uo_statictext within w_password
integer x = 18
integer width = 1298
integer height = 112
integer textsize = -8
boolean italic = true
long textcolor = 8388608
string text = ""
end type

type cb_cancel from uo_cb_cancel within w_password
string tag = "TEXT_00028"
integer x = 750
integer y = 336
end type

event clicked;call super::clicked;closewithreturn(parent, -1)
end event

type cb_ok from uo_cb_ok within w_password
string tag = "TEXT_00027"
integer x = 165
integer y = 336
end type

event clicked;call super::clicked;closewithreturn(parent, f_string(sle_password.text))
end event

type st_1 from uo_statictext within w_password
integer x = 18
integer y = 176
integer height = 80
string text = "Mot de passe"
end type

type sle_password from uo_sle within w_password
integer x = 421
integer y = 176
integer width = 713
integer height = 80
integer taborder = 10
boolean password = true
end type

