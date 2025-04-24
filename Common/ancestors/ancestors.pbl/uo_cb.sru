forward
global type uo_cb from commandbutton
end type
end forward

global type uo_cb from commandbutton
integer width = 402
integer height = 112
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "none"
end type
global uo_cb uo_cb

on uo_cb.create
end on

on uo_cb.destroy
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

