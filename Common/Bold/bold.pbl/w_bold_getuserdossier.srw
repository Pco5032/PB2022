forward
global type w_bold_getuserdossier from w_ancestor
end type
type cb_cancel from uo_cb_cancel within w_bold_getuserdossier
end type
type cb_ok from uo_cb_ok within w_bold_getuserdossier
end type
type sle_ndossier from uo_sle within w_bold_getuserdossier
end type
type st_1 from uo_statictext within w_bold_getuserdossier
end type
end forward

global type w_bold_getuserdossier from w_ancestor
integer width = 1806
integer height = 640
string title = "Demande d~'importation/synchronisation d~'un dossier depuis MonEspace"
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
boolean center = true
cb_cancel cb_cancel
cb_ok cb_ok
sle_ndossier sle_ndossier
st_1 st_1
end type
global w_bold_getuserdossier w_bold_getuserdossier

on w_bold_getuserdossier.create
int iCurrent
call super::create
this.cb_cancel=create cb_cancel
this.cb_ok=create cb_ok
this.sle_ndossier=create sle_ndossier
this.st_1=create st_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_cancel
this.Control[iCurrent+2]=this.cb_ok
this.Control[iCurrent+3]=this.sle_ndossier
this.Control[iCurrent+4]=this.st_1
end on

on w_bold_getuserdossier.destroy
call super::destroy
destroy(this.cb_cancel)
destroy(this.cb_ok)
destroy(this.sle_ndossier)
destroy(this.st_1)
end on

event ue_closebyxaccepted;call super::ue_closebyxaccepted;cb_cancel.Event clicked()
end event

event ue_open;call super::ue_open;string	ls_ndossier
str_params	lstr_params

// récupérer n° de dossier en cours
lstr_params = Message.PowerObjectParm
IF IsValid(lstr_params) THEN 
	CHOOSE CASE upperbound(lstr_params.a_param)
		CASE 1
			ls_ndossier = string(lstr_params.a_param[1])
	END CHOOSE
END IF

sle_ndossier.text = ls_ndossier
end event

type cb_cancel from uo_cb_cancel within w_bold_getuserdossier
integer x = 969
integer y = 352
end type

event clicked;call super::clicked;closeWithReturn(parent, -1)
end event

type cb_ok from uo_cb_ok within w_bold_getuserdossier
integer x = 366
integer y = 352
boolean default = false
end type

event clicked;call super::clicked;str_params	lstr_params, lstr_target[]
long		ll_row
integer	li_i
date		ldt_expiryDate

IF f_isEmptyString(sle_ndossier.text) THEN
	gu_message.uf_error("Le n° du dossier à importer/synchroniser doit être spécifié")
	return
END IF

lstr_params.a_param[1] = sle_ndossier.text
// version
lstr_params.a_param[2] = 0

CloseWithReturn(Parent, lstr_params)
end event

type sle_ndossier from uo_sle within w_bold_getuserdossier
integer x = 640
integer y = 208
integer width = 494
integer height = 96
integer taborder = 10
integer textsize = -9
integer limit = 100
string placeholder = "1898639-096905"
end type

type st_1 from uo_statictext within w_bold_getuserdossier
integer x = 73
integer y = 96
integer width = 1682
string text = "N° du dossier à importer ou synchroniser depuis MonEspace :"
end type

