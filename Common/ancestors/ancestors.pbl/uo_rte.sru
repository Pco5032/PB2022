forward
global type uo_rte from richtextedit
end type
end forward

global type uo_rte from richtextedit
integer width = 411
integer height = 432
borderstyle borderstyle = stylelowered!
end type
global uo_rte uo_rte

on uo_rte.create
end on

on uo_rte.destroy
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

