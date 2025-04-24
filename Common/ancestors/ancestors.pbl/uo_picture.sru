forward
global type uo_picture from picture
end type
end forward

global type uo_picture from picture
integer width = 165
integer height = 144
boolean originalsize = true
boolean focusrectangle = false
end type
global uo_picture uo_picture

on uo_picture.create
end on

on uo_picture.destroy
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

