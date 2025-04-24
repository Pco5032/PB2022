//objectcomments Fenêtre utilisée pour copier les privilèges d'1 user vers 1 autre
forward
global type w_copyuser from w_ancestor
end type
type cb_2 from uo_cb_cancel within w_copyuser
end type
type cb_1 from uo_cb_ok within w_copyuser
end type
type st_1 from uo_statictext within w_copyuser
end type
type em_1 from uo_editmask within w_copyuser
end type
end forward

global type w_copyuser from w_ancestor
integer width = 1445
integer height = 528
string title = ""
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
cb_2 cb_2
cb_1 cb_1
st_1 st_1
em_1 em_1
end type
global w_copyuser w_copyuser

type variables
integer	ii_param
end variables

on w_copyuser.create
int iCurrent
call super::create
this.cb_2=create cb_2
this.cb_1=create cb_1
this.st_1=create st_1
this.em_1=create em_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_2
this.Control[iCurrent+2]=this.cb_1
this.Control[iCurrent+3]=this.st_1
this.Control[iCurrent+4]=this.em_1
end on

on w_copyuser.destroy
call super::destroy
destroy(this.cb_2)
destroy(this.cb_1)
destroy(this.st_1)
destroy(this.em_1)
end on

event ue_open;call super::ue_open;ii_param = Integer(Message.DoubleParm)
// param=1 pour copier un groupe
// param=2 pour copier un user
IF ii_param = 1 THEN
	em_1.SetMask(NumericMask!, "###")
ELSE
	em_1.SetMask(NumericMask!, "####")
END IF
	
// ne pas logger de message lors de l'utilisation de cette fenêtre
wf_logusage(FALSE)

f_centerInMdi(this)
end event

type cb_2 from uo_cb_cancel within w_copyuser
integer x = 768
integer y = 256
integer taborder = 30
end type

event clicked;call super::clicked;CloseWithReturn(Parent, -1)
end event

type cb_1 from uo_cb_ok within w_copyuser
integer x = 201
integer y = 256
integer taborder = 20
end type

event clicked;call super::clicked;decimal	ld_id
string	ls_desc, ls_domain, ls_logname

em_1.GetData(ld_id)

IF ii_param = 1 THEN
	IF IsNull(ld_id) OR ld_id < 1 OR ld_id > 999 THEN
		gu_message.uf_error("Le n° de groupe doit être compris entre 1 et 999")
		em_1.SetFocus()
		return
	END IF
	select description into :ls_desc from dnfgroups where groupid=:ld_id using ESQLCA;
	IF f_check_sql(ESQLCA) <> 100 THEN
		gu_message.uf_error("Ce groupe existe déjà, sa description est : " + ls_desc)
		em_1.SetFocus()
		return
	END IF
ELSE
	IF IsNull(ld_id) OR ld_id < 1001 OR ld_id > 9999 THEN
		gu_message.uf_error("Le n° d'utilisateur doit être compris entre 1001 et 9999")
		em_1.SetFocus()
		return
	END IF
	select domain, logname into :ls_domain, :ls_logname from dnfusers where userid=:ld_id using ESQLCA;
	IF f_check_sql(ESQLCA) <> 100 THEN
		gu_message.uf_error("Cet utilisateur existe déjà, il s'agit de : " + ls_domain + "\\" + ls_logname)
		em_1.SetFocus()
		return
	END IF
END IF
CloseWithReturn(Parent, integer(ld_id))
end event

type st_1 from uo_statictext within w_copyuser
integer x = 366
integer y = 80
integer width = 384
string text = "Copier vers n° "
end type

type em_1 from uo_editmask within w_copyuser
integer x = 750
integer y = 80
integer width = 201
integer height = 80
integer taborder = 10
integer textsize = -9
alignment alignment = right!
string mask = "###"
end type

event getfocus;call super::getfocus;This.SelectText(1, 4)
end event

