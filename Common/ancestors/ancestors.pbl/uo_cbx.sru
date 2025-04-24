forward
global type uo_cbx from checkbox
end type
end forward

global type uo_cbx from checkbox
integer width = 402
integer height = 80
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "none"
borderstyle borderstyle = stylelowered!
end type
global uo_cbx uo_cbx

on uo_cbx.create
end on

on uo_cbx.destroy
end on

event rbuttondown;window	lw_parent
IF f_GetParentWindow(this, lw_parent) = 1 THEN
	IF lw_parent.windowtype <> Response! THEN f_PopupAction(lw_parent)
END IF
end event

event losefocus;gw_mdiframe.SetMicroHelp("")
end event

event getfocus;gw_mdiframe.SetMicroHelp(f_gethelpmsg(This.tag))
end event

