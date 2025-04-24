forward
global type uo_pictbutton from picturebutton
end type
end forward

global type uo_pictbutton from picturebutton
integer width = 402
integer height = 224
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "none"
boolean originalsize = true
vtextalign vtextalign = multiline!
end type
global uo_pictbutton uo_pictbutton

on uo_pictbutton.create
end on

on uo_pictbutton.destroy
end on

event getfocus;gw_mdiframe.SetMicroHelp(f_gethelpmsg(This.tag))
end event

event losefocus;gw_mdiframe.SetMicroHelp("")
end event

event rbuttondown;window	lw_parent
IF f_GetParentWindow(this, lw_parent) = 1 THEN
	IF lw_parent.windowtype <> Response! THEN f_PopupAction(lw_parent)
END IF
end event

