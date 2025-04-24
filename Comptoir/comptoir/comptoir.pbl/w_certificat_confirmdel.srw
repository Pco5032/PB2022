//objectcomments Confirmation suppression certificat-maître avec obligation de donner et logger la raison de la suppression
forward
global type w_certificat_confirmdel from w_ancestor
end type
type p_1 from uo_picture within w_certificat_confirmdel
end type
type cb_non from uo_cb_ok within w_certificat_confirmdel
end type
type sle_1 from uo_sle within w_certificat_confirmdel
end type
type st_1 from uo_statictext within w_certificat_confirmdel
end type
type cb_oui from uo_cb_ok within w_certificat_confirmdel
end type
end forward

global type w_certificat_confirmdel from w_ancestor
integer width = 2080
integer height = 716
string title = "CONFIRMATION de la suppression d~'une fiche"
boolean controlmenu = false
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
p_1 p_1
cb_non cb_non
sle_1 sle_1
st_1 st_1
cb_oui cb_oui
end type
global w_certificat_confirmdel w_certificat_confirmdel

on w_certificat_confirmdel.create
int iCurrent
call super::create
this.p_1=create p_1
this.cb_non=create cb_non
this.sle_1=create sle_1
this.st_1=create st_1
this.cb_oui=create cb_oui
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_1
this.Control[iCurrent+2]=this.cb_non
this.Control[iCurrent+3]=this.sle_1
this.Control[iCurrent+4]=this.st_1
this.Control[iCurrent+5]=this.cb_oui
end on

on w_certificat_confirmdel.destroy
call super::destroy
destroy(this.p_1)
destroy(this.cb_non)
destroy(this.sle_1)
destroy(this.st_1)
destroy(this.cb_oui)
end on

event open;call super::open;f_centerinmdi (this)
end event

type p_1 from uo_picture within w_certificat_confirmdel
integer x = 37
integer y = 32
integer width = 187
integer height = 160
string picturename = "..\bmp\question.bmp"
end type

type cb_non from uo_cb_ok within w_certificat_confirmdel
integer x = 1079
integer y = 448
integer width = 421
integer height = 128
integer taborder = 30
integer textsize = -8
string text = "&Non"
boolean cancel = true
end type

event clicked;call super::clicked;CloseWithReturn(parent, 2)

end event

type sle_1 from uo_sle within w_certificat_confirmdel
integer x = 37
integer y = 256
integer width = 1993
integer height = 144
integer taborder = 10
integer textsize = -9
integer limit = 50
end type

type st_1 from uo_statictext within w_certificat_confirmdel
integer x = 238
integer y = 16
integer width = 1792
integer height = 224
integer textsize = -12
integer weight = 700
long textcolor = 8388608
boolean enabled = false
string text = "Veuillez indiquer le motif de la suppression de ce certificat et confirmer votre choix en cliquant sur OUI"
alignment alignment = center!
boolean disabledlook = false
end type

type cb_oui from uo_cb_ok within w_certificat_confirmdel
integer x = 512
integer y = 448
integer width = 421
integer height = 128
integer taborder = 20
integer textsize = -8
string text = "&Oui"
boolean default = false
end type

event clicked;call super::clicked;IF f_isEmptyString(sle_1.text) THEN
	gu_message.uf_error("Veuillez indiquer le motif de suppression de ce certificat")
	return
ELSE
	CloseWithReturn(parent, sle_1.text)
END IF

end event

