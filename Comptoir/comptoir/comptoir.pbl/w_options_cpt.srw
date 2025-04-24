forward
global type w_options_cpt from w_options
end type
type st_3 from uo_statictext within tabpage_2
end type
type ddlb_1 from uo_dropdownlistbox within tabpage_2
end type
end forward

global type w_options_cpt from w_options
end type
global w_options_cpt w_options_cpt

on w_options_cpt.create
int iCurrent
call super::create
end on

on w_options_cpt.destroy
call super::destroy
end on

event open;call super::open;string	ls_theme

// thème
ls_theme = getTheme()
IF f_isEmptyString(ls_theme) THEN ls_theme = "Aucun"
tab_1.tabpage_2.ddlb_1.text = ls_theme
end event

type tab_1 from w_options`tab_1 within w_options_cpt
end type

on tab_1.create
call super::create
this.Control[]={this.tabpage_1,&
this.tabpage_2}
end on

on tab_1.destroy
call super::destroy
end on

type tabpage_1 from w_options`tabpage_1 within tab_1
end type

type cbx_visible from w_options`cbx_visible within tabpage_1
end type

type cbx_showtext from w_options`cbx_showtext within tabpage_1
end type

type cbx_user_control from w_options`cbx_user_control within tabpage_1
end type

type cb_default from w_options`cb_default within tabpage_1
end type

type rb_top from w_options`rb_top within tabpage_1
end type

type rb_bottom from w_options`rb_bottom within tabpage_1
end type

type rb_right from w_options`rb_right within tabpage_1
end type

type rb_left from w_options`rb_left within tabpage_1
end type

type st_1 from w_options`st_1 within tabpage_1
end type

type gb_2 from w_options`gb_2 within tabpage_1
end type

type rb_floating from w_options`rb_floating within tabpage_1
end type

type gb_1 from w_options`gb_1 within tabpage_1
end type

type lb_toolbar from w_options`lb_toolbar within tabpage_1
end type

type tabpage_2 from w_options`tabpage_2 within tab_1
st_3 st_3
ddlb_1 ddlb_1
end type

on tabpage_2.create
this.st_3=create st_3
this.ddlb_1=create ddlb_1
int iCurrent
call super::create
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.st_3
this.Control[iCurrent+2]=this.ddlb_1
end on

on tabpage_2.destroy
call super::destroy
destroy(this.st_3)
destroy(this.ddlb_1)
end on

type st_2 from w_options`st_2 within tabpage_2
end type

type sle_1 from w_options`sle_1 within tabpage_2
end type

type cbx_enter from w_options`cbx_enter within tabpage_2
end type

type gb_3 from w_options`gb_3 within tabpage_2
end type

type st_3 from uo_statictext within tabpage_2
integer x = 37
integer y = 416
integer width = 475
integer height = 80
boolean bringtotop = true
string text = "Thème graphique"
end type

type ddlb_1 from uo_dropdownlistbox within tabpage_2
integer x = 549
integer y = 400
integer width = 603
integer height = 464
integer taborder = 30
boolean bringtotop = true
boolean sorted = false
string item[] = {"Aucun","Flat Design Blue","Flat Design Grey","Flat Design Silver"}
end type

event selectionchanged;call super::selectionchanged;string	ls_theme

ls_theme = this.text
ApplyTheme("..\pbrts\themes\" + ls_theme)
SetProfileString(gs_locinifile, gs_username, "theme", ls_theme)
end event

