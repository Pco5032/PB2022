//objectcomments Fenêtre d'affichage d'une erreur inattendue
forward
global type w_error from w_ancestor
end type
type cb_oui from uo_cb within w_error
end type
type p_1 from picture within w_error
end type
type mle_text from uo_mle within w_error
end type
type sle_errnum from uo_sle within w_error
end type
type st_6 from uo_statictext within w_error
end type
type sle_object from uo_sle within w_error
end type
type cb_detail from uo_cb within w_error
end type
type mle_errtext from uo_mle within w_error
end type
type gb_1 from uo_groupbox within w_error
end type
type sle_line from uo_sle within w_error
end type
type sle_window from uo_sle within w_error
end type
type sle_event from uo_sle within w_error
end type
type st_4 from uo_statictext within w_error
end type
type st_3 from uo_statictext within w_error
end type
type st_1 from uo_statictext within w_error
end type
type st_5 from uo_statictext within w_error
end type
type cb_ok from uo_cb_ok within w_error
end type
type cb_non from uo_cb within w_error
end type
end forward

global type w_error from w_ancestor
string tag = "TEXT_00063"
integer x = 759
integer y = 368
integer width = 2158
integer height = 1512
string title = "Erreur inattendue"
boolean controlmenu = false
windowtype windowtype = response!
long backcolor = 79741120
cb_oui cb_oui
p_1 p_1
mle_text mle_text
sle_errnum sle_errnum
st_6 st_6
sle_object sle_object
cb_detail cb_detail
mle_errtext mle_errtext
gb_1 gb_1
sle_line sle_line
sle_window sle_window
sle_event sle_event
st_4 st_4
st_3 st_3
st_1 st_1
st_5 st_5
cb_ok cb_ok
cb_non cb_non
end type
global w_error w_error

type variables
integer	ii_button
end variables

on w_error.create
int iCurrent
call super::create
this.cb_oui=create cb_oui
this.p_1=create p_1
this.mle_text=create mle_text
this.sle_errnum=create sle_errnum
this.st_6=create st_6
this.sle_object=create sle_object
this.cb_detail=create cb_detail
this.mle_errtext=create mle_errtext
this.gb_1=create gb_1
this.sle_line=create sle_line
this.sle_window=create sle_window
this.sle_event=create sle_event
this.st_4=create st_4
this.st_3=create st_3
this.st_1=create st_1
this.st_5=create st_5
this.cb_ok=create cb_ok
this.cb_non=create cb_non
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_oui
this.Control[iCurrent+2]=this.p_1
this.Control[iCurrent+3]=this.mle_text
this.Control[iCurrent+4]=this.sle_errnum
this.Control[iCurrent+5]=this.st_6
this.Control[iCurrent+6]=this.sle_object
this.Control[iCurrent+7]=this.cb_detail
this.Control[iCurrent+8]=this.mle_errtext
this.Control[iCurrent+9]=this.gb_1
this.Control[iCurrent+10]=this.sle_line
this.Control[iCurrent+11]=this.sle_window
this.Control[iCurrent+12]=this.sle_event
this.Control[iCurrent+13]=this.st_4
this.Control[iCurrent+14]=this.st_3
this.Control[iCurrent+15]=this.st_1
this.Control[iCurrent+16]=this.st_5
this.Control[iCurrent+17]=this.cb_ok
this.Control[iCurrent+18]=this.cb_non
end on

on w_error.destroy
call super::destroy
destroy(this.cb_oui)
destroy(this.p_1)
destroy(this.mle_text)
destroy(this.sle_errnum)
destroy(this.st_6)
destroy(this.sle_object)
destroy(this.cb_detail)
destroy(this.mle_errtext)
destroy(this.gb_1)
destroy(this.sle_line)
destroy(this.sle_window)
destroy(this.sle_event)
destroy(this.st_4)
destroy(this.st_3)
destroy(this.st_1)
destroy(this.st_5)
destroy(this.cb_ok)
destroy(this.cb_non)
end on

event ue_open;call super::ue_open;/* paramètres passés à cette fenêtre :
string	message principal d'erreur
integer	severity
boolean	TRUE=afficher d'office le detail
integer	1 = bouton OK seulement
			2 = boutons OUI et NON
*/
integer		li_severity, li_dberrorseverity
boolean		lb_detail
str_params	lstr_params

lstr_params = Message.PowerObjectParm
li_severity = lstr_params.a_param[2]
lb_detail = lstr_params.a_param[3]
ii_button = lstr_params.a_param[4]

// ne pas logger de message lors de l'utilisation de cette fenêtre
wf_logusage(FALSE)

f_centerInMdi(this)

// taille initiale de la fenêtre (sans le détail)
IF f_getPBMajor() < 22 THEN
	This.Height = 450
ELSE
	This.Height = 490
END IF

// boutons
CHOOSE CASE ii_button
	CASE 1
		cb_oui.visible = FALSE
		cb_non.visible = FALSE
		cb_ok.visible = TRUE
		cb_detail.x = 1152
		cb_detail.y = 208		
	CASE 2
		cb_OK.visible = FALSE
		cb_oui.visible = TRUE
		cb_non.visible = TRUE
		cb_detail.x = 1627
		cb_detail.y = 208
END CHOOSE


/* s'il y a une structure str_dberror valide sauvée dans l'objet error, on utilise le code severity qui s'y trouve */
li_DBerrorSeverity = error.uf_GetSavedSeverity()
IF li_DBerrorSeverity > 0 THEN
	li_severity = li_DBerrorSeverity
END IF

IF IsNull(li_severity) OR li_severity < 1 OR li_severity > 4 THEN
	gu_message.uf_error("Le code de gravité d'erreur doit être compris entre 1 et 4, et il est de " &
			+ string(li_severity))
	li_severity = 2
END IF

/* severity 1 = info 
	severity 2 = warning
	severity 3 = error
	severity 4 = fatal */
CHOOSE CASE li_severity
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

// si le n° d'erreur est 0, cela signifie qu'aucun détail n'est disponible. On fait donc disparaître
// le bouton détail et on recentre le bouton OK
IF error.Number = 0 THEN
	cb_detail.hide()
	cb_ok.x = 859
ELSE
	sle_window.text = error.WindowMenu
	sle_object.text = error.object
	sle_event.text = error.ObjectEvent
	sle_line.text = string(error.Line)
	sle_errnum.text = string(error.Number)
	mle_errtext.text = error.Text
	// si le message d'erreur affiché dans le détail est vide, on reprend celui qui est peut-être sauvé dans l'objet error,
	// dans la structure str_dberror
	IF IsNull(mle_errtext.text) OR LenA(mle_errtext.text) = 0 THEN
		mle_errtext.text = error.uf_GetSavedText()
	END IF
	IF lb_detail THEN
		cb_detail.event clicked()
	END IF
END IF

/* le message à afficher est passé en paramètre. Si le texte est vide, on reprend celui de l'objet error
   s'il est toujours vide, on prend celui sauvé dans la structure str_dberror de l'objet error */
mle_text.text = lstr_params.a_param[1]
IF IsNull(mle_text.text) OR LenA(mle_text.text) = 0 THEN
	mle_text.text = error.Text
END IF
IF IsNull(mle_text.text) OR LenA(mle_text.text) = 0 THEN
	mle_text.text = error.uf_GetSavedText()
END IF

// enregistrer l'erreur dans fichier log
f_logerror(sle_errnum.text + "/" + mle_errtext.text + "(" + mle_text.text + ") /" + sle_window.text + "/" + &
			 sle_object.text + "/" + sle_event.text + "/" + sle_line.text)

end event

type cb_oui from uo_cb within w_error
string tag = "TEXT_00064"
boolean visible = false
integer x = 658
integer y = 208
integer width = 347
integer taborder = 30
string text = "Oui"
end type

event clicked;call super::clicked;// réinitialise l'objet error s'il avait été utilisé et quitter la fenêtre
error.uf_reset()

closewithreturn(parent,1)
end event

type p_1 from picture within w_error
integer y = 16
integer width = 224
integer height = 172
boolean enabled = false
boolean originalsize = true
string picturename = "..\bmp\exclamation.bmp"
boolean focusrectangle = false
end type

type mle_text from uo_mle within w_error
integer x = 238
integer y = 16
integer width = 1865
integer height = 160
integer taborder = 10
boolean bringtotop = true
integer textsize = -8
boolean vscrollbar = true
boolean autovscroll = true
boolean displayonly = true
end type

type sle_errnum from uo_sle within w_error
integer x = 603
integer y = 800
integer width = 201
integer height = 80
integer taborder = 40
boolean bringtotop = true
integer textsize = -8
boolean autohscroll = false
boolean displayonly = true
end type

type st_6 from uo_statictext within w_error
string tag = "TEXT_00069"
integer x = 55
integer y = 720
integer width = 530
boolean bringtotop = true
long backcolor = 79741120
string text = "N° de ligne"
boolean disabledlook = false
end type

type sle_object from uo_sle within w_error
integer x = 603
integer y = 512
integer width = 585
integer height = 80
integer taborder = 30
boolean bringtotop = true
integer textsize = -8
boolean autohscroll = false
boolean displayonly = true
end type

type cb_detail from uo_cb within w_error
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
IF ii_button = 1 THEN
	cb_ok.y = 1270
	cb_ok.x = 859
END IF
end event

type mle_errtext from uo_mle within w_error
integer x = 37
integer y = 928
integer width = 2066
integer height = 272
boolean bringtotop = true
integer textsize = -8
boolean vscrollbar = true
boolean displayonly = true
end type

type gb_1 from uo_groupbox within w_error
integer x = 18
integer y = 352
integer width = 2103
integer height = 880
end type

type sle_line from uo_sle within w_error
integer x = 603
integer y = 704
integer width = 201
integer height = 80
boolean bringtotop = true
integer textsize = -8
boolean autohscroll = false
boolean displayonly = true
end type

type sle_window from uo_sle within w_error
integer x = 603
integer y = 416
integer width = 585
integer height = 80
boolean bringtotop = true
integer textsize = -8
boolean autohscroll = false
boolean displayonly = true
end type

type sle_event from uo_sle within w_error
integer x = 603
integer y = 608
integer width = 585
integer height = 80
boolean bringtotop = true
integer textsize = -8
boolean autohscroll = false
boolean displayonly = true
end type

type st_4 from uo_statictext within w_error
string tag = "TEXT_00070"
integer x = 55
integer y = 816
integer width = 530
boolean bringtotop = true
long backcolor = 79741120
string text = "N° d~'erreur"
boolean disabledlook = false
end type

type st_3 from uo_statictext within w_error
string tag = "TEXT_00068"
integer x = 55
integer y = 608
integer width = 530
integer height = 80
boolean bringtotop = true
long backcolor = 79741120
string text = "Event"
boolean disabledlook = false
end type

type st_1 from uo_statictext within w_error
string tag = "TEXT_00067"
integer x = 55
integer y = 512
integer width = 530
boolean bringtotop = true
long backcolor = 79741120
string text = "Objet"
boolean disabledlook = false
end type

type st_5 from uo_statictext within w_error
string tag = "TEXT_00066"
integer x = 55
integer y = 416
integer width = 530
integer height = 76
boolean bringtotop = true
long backcolor = 79741120
string text = "Fenêtre/Menu"
boolean disabledlook = false
end type

type cb_ok from uo_cb_ok within w_error
event clicked pbm_bnclicked
string tag = "TEXT_00027"
integer x = 585
integer y = 208
integer width = 347
integer taborder = 10
boolean bringtotop = true
end type

event clicked;// réinitialise l'objet error s'il avait été utilisé et quitter la fenêtre
error.uf_reset()

close(parent)
end event

type cb_non from uo_cb within w_error
string tag = "TEXT_00065"
boolean visible = false
integer x = 1042
integer y = 208
integer width = 347
integer taborder = 30
string text = "Non"
end type

event clicked;call super::clicked;// réinitialise l'objet error s'il avait été utilisé et quitter la fenêtre
error.uf_reset()

closewithreturn(parent, 2)
end event

