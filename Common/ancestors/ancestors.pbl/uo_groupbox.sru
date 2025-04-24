forward
global type uo_groupbox from groupbox
end type
end forward

global type uo_groupbox from groupbox
integer width = 786
integer height = 340
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
borderstyle borderstyle = stylelowered!
event we_rbuttondown pbm_rbuttondown
end type
global uo_groupbox uo_groupbox

event we_rbuttondown;window	lw_parent
IF f_GetParentWindow(this, lw_parent) = 1 THEN
	IF lw_parent.windowtype <> Response! THEN f_PopupAction(lw_parent)
END IF
end event

on uo_groupbox.create
end on

on uo_groupbox.destroy
end on

