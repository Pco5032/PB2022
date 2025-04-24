//objectcomments Affichage d'une erreur DB inattendue
forward
global type w_dberror from w_ancestor
end type
type p_1 from picture within w_dberror
end type
type cb_detail from uo_cb within w_dberror
end type
type cb_ok from uo_cb_ok within w_dberror
end type
type mle_sqlerrtext from uo_mle within w_dberror
end type
type gb_1 from uo_groupbox within w_dberror
end type
type sle_buffer from uo_sle within w_dberror
end type
type mle_sqlsyntax from uo_mle within w_dberror
end type
type sle_row from uo_sle within w_dberror
end type
type sle_sqldbcode from uo_sle within w_dberror
end type
type st_4 from uo_statictext within w_dberror
end type
type st_3 from uo_statictext within w_dberror
end type
type st_1 from uo_statictext within w_dberror
end type
type st_5 from uo_statictext within w_dberror
end type
end forward

global type w_dberror from w_ancestor
string tag = "TEXT_00077"
integer x = 759
integer y = 368
integer width = 2158
integer height = 1508
string title = "ERREUR BASE DE DONNEES"
boolean controlmenu = false
windowtype windowtype = response!
long backcolor = 79741120
p_1 p_1
cb_detail cb_detail
cb_ok cb_ok
mle_sqlerrtext mle_sqlerrtext
gb_1 gb_1
sle_buffer sle_buffer
mle_sqlsyntax mle_sqlsyntax
sle_row sle_row
sle_sqldbcode sle_sqldbcode
st_4 st_4
st_3 st_3
st_1 st_1
st_5 st_5
end type
global w_dberror w_dberror

on w_dberror.create
int iCurrent
call super::create
this.p_1=create p_1
this.cb_detail=create cb_detail
this.cb_ok=create cb_ok
this.mle_sqlerrtext=create mle_sqlerrtext
this.gb_1=create gb_1
this.sle_buffer=create sle_buffer
this.mle_sqlsyntax=create mle_sqlsyntax
this.sle_row=create sle_row
this.sle_sqldbcode=create sle_sqldbcode
this.st_4=create st_4
this.st_3=create st_3
this.st_1=create st_1
this.st_5=create st_5
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_1
this.Control[iCurrent+2]=this.cb_detail
this.Control[iCurrent+3]=this.cb_ok
this.Control[iCurrent+4]=this.mle_sqlerrtext
this.Control[iCurrent+5]=this.gb_1
this.Control[iCurrent+6]=this.sle_buffer
this.Control[iCurrent+7]=this.mle_sqlsyntax
this.Control[iCurrent+8]=this.sle_row
this.Control[iCurrent+9]=this.sle_sqldbcode
this.Control[iCurrent+10]=this.st_4
this.Control[iCurrent+11]=this.st_3
this.Control[iCurrent+12]=this.st_1
this.Control[iCurrent+13]=this.st_5
end on

on w_dberror.destroy
call super::destroy
destroy(this.p_1)
destroy(this.cb_detail)
destroy(this.cb_ok)
destroy(this.mle_sqlerrtext)
destroy(this.gb_1)
destroy(this.sle_buffer)
destroy(this.mle_sqlsyntax)
destroy(this.sle_row)
destroy(this.sle_sqldbcode)
destroy(this.st_4)
destroy(this.st_3)
destroy(this.st_1)
destroy(this.st_5)
end on

event ue_open;call super::ue_open;str_dberror str_dberr

str_dberr = Message.PowerObjectParm

// ne pas logger de message lors de l'utilisation de cette fenêtre
wf_logusage(FALSE)

f_centerInMdi(this)

// taille initiale de la fenêtre (sans le détail)
IF f_getPBMajor() < 22 THEN
	This.Height = 450
ELSE
	This.Height = 490
END IF

sle_row.text = string(str_dberr.l_row)
mle_sqlerrtext.text = str_dberr.s_sqlerrtext
mle_sqlsyntax.text = str_dberr.s_sqlsyntax
sle_sqldbcode.text = string(str_dberr.l_sqldbcode)

CHOOSE CASE str_dberr.dwb_buffer
	CASE Primary!
		sle_buffer.text = "Primary"
	CASE Delete!
		sle_buffer.text = "Deleted"
	CASE Filter!
		sle_buffer.text = "Filtered"
END CHOOSE

/* severity 1 = info 
	severity 2 = warning
	severity 3 = error
	severity 4 = fatal */

CHOOSE CASE str_dberr.i_severity
	CASE 1
		this.title = "Information"
		p_1.picturename = "..\bmp\info.bmp"
	CASE 2
		this.title = "Avertissement"
		p_1.picturename = "..\bmp\exclamation.bmp"
	CASE 3,4
		this.title = "ERREUR !"
		p_1.picturename = "..\bmp\stop.bmp"
END CHOOSE

end event

type p_1 from picture within w_dberror
integer y = 16
integer width = 224
integer height = 172
boolean enabled = false
string picturename = "..\bmp\exclamation.bmp"
boolean focusrectangle = false
end type

type cb_detail from uo_cb within w_dberror
string tag = "TEXT_00051"
integer x = 1152
integer y = 208
integer width = 347
integer height = 108
integer taborder = 20
string text = "Détail >>>"
end type

event clicked;IF f_getPBMajor() < 22 THEN
	Parent.Height = 1512
ELSE
	Parent.Height = 1552
END IF
This.hide()
cb_ok.y = 1270
cb_ok.x = 859
end event

type cb_ok from uo_cb_ok within w_dberror
event clicked pbm_bnclicked
string tag = "TEXT_00027"
integer x = 585
integer y = 208
integer width = 347
integer taborder = 10
boolean bringtotop = true
end type

event clicked;close(parent)
end event

type mle_sqlerrtext from uo_mle within w_dberror
integer x = 238
integer y = 16
integer width = 1865
integer height = 160
boolean bringtotop = true
integer textsize = -8
boolean vscrollbar = true
boolean displayonly = true
end type

type gb_1 from uo_groupbox within w_dberror
integer x = 18
integer y = 352
integer width = 2103
integer height = 880
end type

type sle_buffer from uo_sle within w_dberror
integer x = 1426
integer y = 416
integer width = 366
integer height = 80
boolean bringtotop = true
integer textsize = -8
boolean autohscroll = false
boolean displayonly = true
end type

type mle_sqlsyntax from uo_mle within w_dberror
integer x = 37
integer y = 704
integer width = 2034
integer height = 500
boolean bringtotop = true
integer textsize = -8
boolean vscrollbar = true
boolean displayonly = true
end type

type sle_row from uo_sle within w_dberror
integer x = 603
integer y = 416
integer width = 366
integer height = 80
boolean bringtotop = true
integer textsize = -8
boolean autohscroll = false
boolean displayonly = true
end type

type sle_sqldbcode from uo_sle within w_dberror
integer x = 603
integer y = 512
integer width = 366
integer height = 80
boolean bringtotop = true
integer textsize = -8
boolean autohscroll = false
boolean displayonly = true
end type

type st_4 from uo_statictext within w_dberror
string tag = "TEXT_00055"
integer x = 1115
integer y = 416
integer width = 293
boolean bringtotop = true
long backcolor = 79741120
string text = "Buffer"
alignment alignment = right!
boolean disabledlook = false
end type

type st_3 from uo_statictext within w_dberror
string tag = "TEXT_00054"
integer x = 55
integer y = 624
integer width = 1719
integer height = 80
boolean bringtotop = true
long backcolor = 79741120
string text = "Ordre SQL"
boolean disabledlook = false
end type

type st_1 from uo_statictext within w_dberror
string tag = "TEXT_00053"
integer x = 55
integer y = 512
integer width = 530
boolean bringtotop = true
long backcolor = 79741120
string text = "Code d~'erreur"
boolean disabledlook = false
end type

type st_5 from uo_statictext within w_dberror
string tag = "TEXT_00052"
integer x = 55
integer y = 416
integer width = 549
boolean bringtotop = true
long backcolor = 79741120
string text = "N° d~'enregistrement"
boolean disabledlook = false
end type

