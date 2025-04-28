forward
global type w_options_carnet from w_options
end type
type rb_f from uo_radiobutton within tabpage_2
end type
type st_3 from uo_statictext within tabpage_2
end type
type rb_d from uo_radiobutton within tabpage_2
end type
type cbx_autoselectrow from uo_cbx within tabpage_2
end type
type st_4 from uo_statictext within tabpage_2
end type
type ddlb_1 from uo_dropdownlistbox within tabpage_2
end type
end forward

global type w_options_carnet from w_options
integer width = 1810
end type
global w_options_carnet w_options_carnet

event ue_open;call super::ue_open;string	ls_theme

// langue du référentiel
IF gs_langue = "F" THEN
	tab_1.tabpage_2.rb_f.checked = TRUE
	tab_1.tabpage_2.rb_d.checked = FALSE
ELSE
	tab_1.tabpage_2.rb_f.checked = TRUE
	tab_1.tabpage_2.rb_d.checked = TRUE
END IF

// mise en évidence ou non de l'activité sélectionnée
IF gb_autoSelectRow THEN
	tab_1.tabpage_2.cbx_autoselectrow.checked = TRUE
ELSE
	tab_1.tabpage_2.cbx_autoselectrow.checked = FALSE
END IF

// thème
ls_theme = getTheme()
IF f_isEmptyString(ls_theme) THEN ls_theme = "Aucun"
tab_1.tabpage_2.ddlb_1.text = ls_theme
end event

on w_options_carnet.create
int iCurrent
call super::create
end on

on w_options_carnet.destroy
call super::destroy
end on

type tab_1 from w_options`tab_1 within w_options_carnet
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
integer width = 1134
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
integer width = 768
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
rb_f rb_f
st_3 st_3
rb_d rb_d
cbx_autoselectrow cbx_autoselectrow
st_4 st_4
ddlb_1 ddlb_1
end type

on tabpage_2.create
this.rb_f=create rb_f
this.st_3=create st_3
this.rb_d=create rb_d
this.cbx_autoselectrow=create cbx_autoselectrow
this.st_4=create st_4
this.ddlb_1=create ddlb_1
int iCurrent
call super::create
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.rb_f
this.Control[iCurrent+2]=this.st_3
this.Control[iCurrent+3]=this.rb_d
this.Control[iCurrent+4]=this.cbx_autoselectrow
this.Control[iCurrent+5]=this.st_4
this.Control[iCurrent+6]=this.ddlb_1
end on

on tabpage_2.destroy
call super::destroy
destroy(this.rb_f)
destroy(this.st_3)
destroy(this.rb_d)
destroy(this.cbx_autoselectrow)
destroy(this.st_4)
destroy(this.ddlb_1)
end on

type st_2 from w_options`st_2 within tabpage_2
end type

type sle_1 from w_options`sle_1 within tabpage_2
integer taborder = 0
end type

type cbx_enter from w_options`cbx_enter within tabpage_2
end type

type gb_3 from w_options`gb_3 within tabpage_2
integer taborder = 0
end type

type rb_f from uo_radiobutton within tabpage_2
string tag = "TEXT_00501"
integer x = 1024
integer y = 520
integer width = 311
boolean bringtotop = true
string text = "français"
end type

event clicked;call super::clicked;IF SetProfileString(gs_locinifile,gs_username,"langue", "F") = 1 THEN
	gs_langue = "F"
	// initialisation de la langue dans la session Oracle de la langue du référentiel.
	IF w_mdiframe.wf_init_langueSession() = -1 THEN
		halt close
	END IF
	// initialisation de la langue dans l'objet "translate"
	w_mdiframe.wf_init_langueTraduction() 
END IF
end event

type st_3 from uo_statictext within tabpage_2
string tag = "TEXT_00500"
integer x = 37
integer y = 528
integer width = 969
boolean bringtotop = true
string text = "Langue de l~'utilisateur"
end type

type rb_d from uo_radiobutton within tabpage_2
string tag = "TEXT_00502"
integer x = 1353
integer y = 520
integer width = 329
boolean bringtotop = true
string text = "allemand"
end type

event clicked;call super::clicked;IF SetProfileString(gs_locinifile,gs_username,"langue", "D") = 1 THEN
	gs_langue = "D"
		// initialisation de la langue dans la session Oracle de la langue du référentiel.
	IF w_mdiframe.wf_init_langueSession() = -1 THEN
		halt close
	END IF
	// initialisation de la langue dans l'objet "translate"
	w_mdiframe.wf_init_langueTraduction() 
END IF
end event

type cbx_autoselectrow from uo_cbx within tabpage_2
integer x = 37
integer y = 416
integer width = 1445
boolean bringtotop = true
string text = "Mise en évidence de la prestation sélectionnée"
boolean lefttext = true
end type

event clicked;call super::clicked;IF SetProfileString(gs_locinifile, gs_username, "AutoSelectRow" ,string(this.checked)) = 1 THEN
	gb_autoSelectRow = this.checked
END IF
end event

type st_4 from uo_statictext within tabpage_2
integer x = 37
integer y = 640
integer width = 475
integer height = 80
boolean bringtotop = true
string text = "Thème graphique"
end type

type ddlb_1 from uo_dropdownlistbox within tabpage_2
integer x = 549
integer y = 624
integer width = 603
integer height = 464
integer taborder = 60
boolean bringtotop = true
boolean sorted = false
string item[] = {"Aucun","Flat Design Blue","Flat Design Grey","Flat Design Silver"}
end type

event selectionchanged;call super::selectionchanged;string	ls_theme

ls_theme = this.text
ApplyTheme("..\pbrts\themes\" + ls_theme)
SetProfileString(gs_locinifile, gs_username, "theme", ls_theme)
end event

