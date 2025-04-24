forward
global type w_b from window
end type
type st_4 from statictext within w_b
end type
type st_3 from statictext within w_b
end type
type st_2 from statictext within w_b
end type
type st_1 from statictext within w_b
end type
type em_dur from editmask within w_b
end type
type em_fr from editmask within w_b
end type
type cb_1 from commandbutton within w_b
end type
end forward

global type w_b from window
integer x = 1056
integer y = 484
integer width = 1390
integer height = 672
boolean titlebar = true
string title = "Untitled"
boolean controlmenu = true
windowtype windowtype = response!
long backcolor = 67108864
boolean contexthelp = true
st_4 st_4
st_3 st_3
st_2 st_2
st_1 st_1
em_dur em_dur
em_fr em_fr
cb_1 cb_1
end type
global w_b w_b

on w_b.create
this.st_4=create st_4
this.st_3=create st_3
this.st_2=create st_2
this.st_1=create st_1
this.em_dur=create em_dur
this.em_fr=create em_fr
this.cb_1=create cb_1
this.Control[]={this.st_4,&
this.st_3,&
this.st_2,&
this.st_1,&
this.em_dur,&
this.em_fr,&
this.cb_1}
end on

on w_b.destroy
destroy(this.st_4)
destroy(this.st_3)
destroy(this.st_2)
destroy(this.st_1)
destroy(this.em_dur)
destroy(this.em_fr)
destroy(this.cb_1)
end on

type st_4 from statictext within w_b
integer x = 640
integer y = 144
integer width = 91
integer height = 80
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
boolean enabled = false
string text = "Hz"
boolean focusrectangle = false
end type

type st_3 from statictext within w_b
integer x = 640
integer y = 288
integer width = 91
integer height = 80
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
boolean enabled = false
string text = "ms"
boolean focusrectangle = false
end type

type st_2 from statictext within w_b
integer x = 110
integer y = 288
integer width = 183
integer height = 80
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
boolean enabled = false
string text = "durée"
boolean focusrectangle = false
end type

type st_1 from statictext within w_b
integer x = 110
integer y = 144
integer width = 183
integer height = 80
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
boolean enabled = false
string text = "Fréq."
boolean focusrectangle = false
end type

type em_dur from editmask within w_b
integer x = 311
integer y = 280
integer width = 329
integer height = 96
integer taborder = 10
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
alignment alignment = right!
borderstyle borderstyle = stylelowered!
string mask = "####0"
boolean spin = true
double increment = 10
string minmax = "10~~1000"
end type

type em_fr from editmask within w_b
integer x = 311
integer y = 136
integer width = 329
integer height = 96
integer taborder = 10
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
alignment alignment = right!
borderstyle borderstyle = stylelowered!
string mask = "####0"
boolean spin = true
double increment = 100
string minmax = "40~~30000"
end type

type cb_1 from commandbutton within w_b
integer x = 805
integer y = 208
integer width = 247
integer height = 108
integer taborder = 20
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "test"
boolean default = true
end type

event clicked;beep(long(em_fr.text), long(em_dur.text))
end event

