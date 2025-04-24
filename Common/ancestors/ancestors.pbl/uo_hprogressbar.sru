forward
global type uo_hprogressbar from hprogressbar
end type
end forward

global type uo_hprogressbar from hprogressbar
integer width = 585
integer height = 64
unsignedinteger maxposition = 100
integer setstep = 1
end type
global uo_hprogressbar uo_hprogressbar

event losefocus;gw_mdiframe.SetMicroHelp("")
end event

event rbuttondown;window	lw_parent
IF f_GetParentWindow(this, lw_parent) = 1 THEN
	IF lw_parent.windowtype <> Response! THEN f_PopupAction(lw_parent)
END IF
end event

on uo_hprogressbar.create
end on

on uo_hprogressbar.destroy
end on

event getfocus;gw_mdiframe.SetMicroHelp(f_gethelpmsg(This.tag))
end event

