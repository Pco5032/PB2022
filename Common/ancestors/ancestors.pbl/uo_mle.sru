forward
global type uo_mle from multilineedit
end type
end forward

global type uo_mle from multilineedit
integer width = 480
integer height = 400
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
borderstyle borderstyle = stylelowered!
end type
global uo_mle uo_mle

event rbuttondown;window	lw_parent
IF f_GetParentWindow(this, lw_parent) = 1 THEN
	IF lw_parent.windowtype <> Response! THEN f_PopupAction(lw_parent)
END IF
end event

on uo_mle.create
end on

on uo_mle.destroy
end on

event help;string	ls_text

// zoom
ls_text = this.Text
IF f_zoom(ls_text, 0, this.DisplayOnly) = 1 THEN
	this.Text = ls_text
END IF

end event

event losefocus;gw_mdiframe.SetMicroHelp("")
end event

event getfocus;gw_mdiframe.SetMicroHelp(f_gethelpmsg(This.tag))
end event

