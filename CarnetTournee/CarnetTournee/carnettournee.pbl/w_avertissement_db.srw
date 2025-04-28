forward
global type w_avertissement_db from w_ancestor
end type
type cb_1 from uo_cb_ok within w_avertissement_db
end type
type st_site from uo_statictext within w_avertissement_db
end type
type st_1 from uo_statictext within w_avertissement_db
end type
end forward

global type w_avertissement_db from w_ancestor
integer width = 1998
integer height = 936
string title = "Attention !"
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
cb_1 cb_1
st_site st_site
st_1 st_1
end type
global w_avertissement_db w_avertissement_db

on w_avertissement_db.create
int iCurrent
call super::create
this.cb_1=create cb_1
this.st_site=create st_site
this.st_1=create st_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_1
this.Control[iCurrent+2]=this.st_site
this.Control[iCurrent+3]=this.st_1
end on

on w_avertissement_db.destroy
call super::destroy
destroy(this.cb_1)
destroy(this.st_site)
destroy(this.st_1)
end on

event ue_open;call super::ue_open;st_site.text = gs_dbdesc

f_centerInMdi(this)
end event

type cb_1 from uo_cb_ok within w_avertissement_db
string tag = "TEXT_00027"
integer x = 695
integer y = 576
integer width = 494
integer height = 192
integer taborder = 10
integer textsize = -14
integer weight = 700
boolean default = false
end type

event clicked;call super::clicked;close(parent)
end event

type st_site from uo_statictext within w_avertissement_db
integer x = 73
integer y = 224
integer width = 1792
integer height = 272
integer textsize = -20
integer weight = 700
boolean underline = true
long textcolor = 255
string text = ""
alignment alignment = center!
end type

type st_1 from uo_statictext within w_avertissement_db
string tag = "TEXT_00590"
integer y = 48
integer width = 1961
integer height = 112
integer textsize = -14
integer weight = 700
long textcolor = 8388608
string text = "Attention, vous êtes connecté à :"
alignment alignment = center!
end type

