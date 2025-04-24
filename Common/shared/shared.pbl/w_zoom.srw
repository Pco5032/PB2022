//objectcomments Fenêtre permettant d'afficher un champ dans un espace plus grand : affichée pour les item de type character lors d'une pression sur F2
forward
global type w_zoom from w_ancestor
end type
type cb_cancel from uo_cb_cancel within w_zoom
end type
type cb_ok from uo_cb_ok within w_zoom
end type
type mle_1 from uo_mle within w_zoom
end type
end forward

global type w_zoom from w_ancestor
integer x = 201
integer y = 352
integer width = 2400
integer height = 1292
string title = "Zoom"
windowtype windowtype = response!
long backcolor = 79741120
cb_cancel cb_cancel
cb_ok cb_ok
mle_1 mle_1
end type
global w_zoom w_zoom

on w_zoom.create
int iCurrent
call super::create
this.cb_cancel=create cb_cancel
this.cb_ok=create cb_ok
this.mle_1=create mle_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_cancel
this.Control[iCurrent+2]=this.cb_ok
this.Control[iCurrent+3]=this.mle_1
end on

on w_zoom.destroy
call super::destroy
destroy(this.cb_cancel)
destroy(this.cb_ok)
destroy(this.mle_1)
end on

event ue_closebyxaccepted;cb_cancel.Event clicked()
end event

event ue_open;call super::ue_open;str_params	lstr_params
string		ls_DisplayOnly

f_centerInMdi(this)

// ne pas logger de message lors de l'utilisation de cette fenêtre
wf_logusage(FALSE)

// récupération des paramètres (texte, longueur max (0=unlimited), facultatif : texte modifiable ou pas)
lstr_params = message.powerobjectParm
mle_1.text = lstr_params.a_param[1]
mle_1.limit = lstr_params.a_param[2]
IF UpperBound(lstr_params.a_param) = 3 THEN
	mle_1.DisplayOnly = lstr_params.a_param[3]
ELSE
	mle_1.DisplayOnly = FALSE
END IF

IF mle_1.DisplayOnly THEN
	ls_DisplayOnly = " - Lecture seulement"
END IF

IF mle_1.limit = 0 THEN
	this.title = "Zoom (nombre de caractères illimité)" + ls_DisplayOnly
ELSE
	this.title = "Zoom (max. " + string(mle_1.limit) + " caractères)" + ls_DisplayOnly
END IF
end event

type cb_cancel from uo_cb_cancel within w_zoom
string tag = "TEXT_00028"
integer x = 1225
integer y = 1040
integer taborder = 30
integer weight = 700
end type

event clicked;call super::clicked;CloseWithReturn(Parent,-1)
end event

type cb_ok from uo_cb_ok within w_zoom
string tag = "TEXT_00027"
integer x = 658
integer y = 1040
integer taborder = 20
end type

event clicked;call super::clicked;CloseWithReturn(Parent, mle_1.text)
end event

type mle_1 from uo_mle within w_zoom
integer width = 2359
integer height = 1008
integer taborder = 10
boolean vscrollbar = true
integer limit = 32000
boolean ignoredefaultbutton = true
end type

