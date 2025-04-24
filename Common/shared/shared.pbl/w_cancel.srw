//objectcomments Interruption d'un retrieve en cours
forward
global type w_cancel from w_ancestor
end type
type st_rows from uo_statictext within w_cancel
end type
type cb_1 from uo_cb within w_cancel
end type
end forward

global type w_cancel from w_ancestor
string tag = "TEXT_00076"
integer width = 901
integer height = 468
string title = "Lecture en cours..."
boolean controlmenu = false
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = popup!
st_rows st_rows
cb_1 cb_1
end type
global w_cancel w_cancel

type variables

end variables

on w_cancel.create
int iCurrent
call super::create
this.st_rows=create st_rows
this.cb_1=create cb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.st_rows
this.Control[iCurrent+2]=this.cb_1
end on

on w_cancel.destroy
call super::destroy
destroy(this.st_rows)
destroy(this.cb_1)
end on

event open;call super::open;f_centerinmdi (this)
end event

event ue_open;call super::ue_open;// ne pas logger de message lors de l'utilisation de cette fenêtre
wf_logusage(FALSE)
end event

type st_rows from uo_statictext within w_cancel
integer x = 219
integer y = 48
integer height = 80
integer textsize = -12
integer weight = 700
long textcolor = 16711680
string text = "0"
alignment alignment = center!
end type

type cb_1 from uo_cb within w_cancel
string tag = "TEXT_00050"
integer x = 219
integer y = 176
integer taborder = 10
string text = "Arrêter"
end type

event clicked;call super::clicked;window w_parent, w_child

w_parent = parent.ParentWindow()
IF w_parent = gw_mdiframe THEN
	w_child = w_parent.getactivesheet()
ELSE
	w_child = parent.ParentWindow()
END IF

IF IsValid(w_child) THEN
	w_child.event dynamic ue_cancel()
END IF


end event

