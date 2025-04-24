forward
global type w_bold_drc_cancel from w_ancestor
end type
type mle_justif from uo_mle within w_bold_drc_cancel
end type
type cb_cancel from uo_cb_cancel within w_bold_drc_cancel
end type
type cb_ok from uo_cb_ok within w_bold_drc_cancel
end type
type st_2 from uo_statictext within w_bold_drc_cancel
end type
end forward

global type w_bold_drc_cancel from w_ancestor
integer width = 3771
integer height = 792
string title = "Annulation d~'une demande de renseignement complémentaire"
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
boolean center = true
mle_justif mle_justif
cb_cancel cb_cancel
cb_ok cb_ok
st_2 st_2
end type
global w_bold_drc_cancel w_bold_drc_cancel

on w_bold_drc_cancel.create
int iCurrent
call super::create
this.mle_justif=create mle_justif
this.cb_cancel=create cb_cancel
this.cb_ok=create cb_ok
this.st_2=create st_2
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.mle_justif
this.Control[iCurrent+2]=this.cb_cancel
this.Control[iCurrent+3]=this.cb_ok
this.Control[iCurrent+4]=this.st_2
end on

on w_bold_drc_cancel.destroy
call super::destroy
destroy(this.mle_justif)
destroy(this.cb_cancel)
destroy(this.cb_ok)
destroy(this.st_2)
end on

event ue_closebyxaccepted;call super::ue_closebyxaccepted;cb_cancel.Event clicked()
end event

event ue_open;call super::ue_open;string	ls_ndossier
str_params	lstr_params

// récupérer n° de dossier
lstr_params = Message.PowerObjectParm
IF IsValid(lstr_params) THEN 
	CHOOSE CASE upperbound(lstr_params.a_param)
		CASE 1
			ls_ndossier = string(lstr_params.a_param[1])
	END CHOOSE
END IF

IF f_isEmptyString(ls_ndossier) THEN
	post close(this)
	return
END IF

// Instancier BOLD si pas encore fait par un autre objet
IF f_boldCreate() = -1 THEN
	post close(this)
	return
END IF

this.title = "Annulation demande de renseignement complémentaire pour le dossier " + ls_ndossier

end event

event ue_close;call super::ue_close;// déconnexion et destroy s'il n'y a plus de connexion en cours (par un autre objet éventuellement)
gu_bold.uf_disconnect()
IF gu_bold.uf_getconnectioncount() = 0 THEN
	DESTROY gu_bold
END IF

end event

type mle_justif from uo_mle within w_bold_drc_cancel
integer x = 640
integer y = 80
integer width = 2999
integer taborder = 20
boolean autovscroll = true
integer limit = 250
end type

type cb_cancel from uo_cb_cancel within w_bold_drc_cancel
integer x = 1975
integer y = 544
end type

event clicked;call super::clicked;closeWithReturn(parent, -1)
end event

type cb_ok from uo_cb_ok within w_bold_drc_cancel
integer x = 1335
integer y = 544
boolean default = false
end type

event clicked;call super::clicked;str_params	lstr_params

lstr_params.a_param[1] = mle_justif.text

CloseWithReturn(Parent, lstr_params)
end event

type st_2 from uo_statictext within w_bold_drc_cancel
integer x = 73
integer y = 96
integer width = 530
integer height = 208
string text = "Justification de l~'annulation de la demande"
end type

