//objectcomments Fenêtre d'attente affichée lors d'un traitement long
forward
global type w_wait from w_ancestor
end type
type cb_cancel from uo_cb within w_wait
end type
type st_info from uo_statictext within w_wait
end type
type st_msg from uo_statictext within w_wait
end type
end forward

global type w_wait from w_ancestor
integer width = 1682
integer height = 496
string title = ""
boolean controlmenu = false
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = popup!
long backcolor = 79741120
string pointer = "HourGlass!"
cb_cancel cb_cancel
st_info st_info
st_msg st_msg
end type
global w_wait w_wait

on w_wait.create
int iCurrent
call super::create
this.cb_cancel=create cb_cancel
this.st_info=create st_info
this.st_msg=create st_msg
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_cancel
this.Control[iCurrent+2]=this.st_info
this.Control[iCurrent+3]=this.st_msg
end on

on w_wait.destroy
call super::destroy
destroy(this.cb_cancel)
destroy(this.st_info)
destroy(this.st_msg)
end on

event ue_open;call super::ue_open;// ne pas logger de message lors de l'utilisation de cette fenêtre
wf_logusage(FALSE)

IF f_getPBMajor() < 22 THEN
	this.Height = 530
ELSE
	this.Height = 570
END IF

f_centerInMdi(this)

end event

event resize;call super::resize;st_info.width = newwidth - (st_info.x * 2)
cb_cancel.x = (newwidth / 2) - (cb_cancel.width / 2)
st_msg.x = (newwidth / 2) - (st_msg.width / 2)

end event

type cb_cancel from uo_cb within w_wait
string tag = "TEXT_00050"
boolean visible = false
integer x = 549
integer y = 96
integer taborder = 10
string text = "Arrêter"
end type

event clicked;call super::clicked;window w_parent, w_child

// recherche fenêtre appelante
w_parent = parent.ParentWindow()
IF w_parent = gw_mdiframe THEN
	w_child = w_parent.getactivesheet()
ELSE
	w_child = parent.ParentWindow()
END IF
IF NOT IsValid(w_child) THEN
	w_child = gw_mdiframe.getactivesheet()
END IF

// déclencher ue_cancel dans fenêtre appelante
IF IsValid(w_child) THEN
	w_child.event dynamic ue_cancel()
END IF


end event

type st_info from uo_statictext within w_wait
integer x = 18
integer y = 320
integer width = 1243
integer height = 80
long textcolor = 65535
long backcolor = 276856960
string text = ""
end type

type st_msg from uo_statictext within w_wait
string tag = "TEXT_00112"
integer x = 329
integer y = 112
integer width = 805
integer height = 96
integer textsize = -12
integer weight = 700
string pointer = "HourGlass!"
string text = "Veuillez patienter..."
alignment alignment = center!
end type

