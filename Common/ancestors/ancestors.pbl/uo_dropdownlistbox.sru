forward
global type uo_dropdownlistbox from dropdownlistbox
end type
end forward

global type uo_dropdownlistbox from dropdownlistbox
integer width = 480
integer height = 400
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
string text = ""
borderstyle borderstyle = stylelowered!
end type
global uo_dropdownlistbox uo_dropdownlistbox

event rbuttondown;window	lw_parent
IF f_GetParentWindow(this, lw_parent) = 1 THEN
	IF lw_parent.windowtype <> Response! THEN f_PopupAction(lw_parent)
END IF
end event

on uo_dropdownlistbox.create
end on

on uo_dropdownlistbox.destroy
end on

event losefocus;gw_mdiframe.SetMicroHelp("")
end event

event getfocus;gw_mdiframe.SetMicroHelp(f_gethelpmsg(This.tag))
end event

