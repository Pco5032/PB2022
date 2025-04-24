//objectcomments Fenêtre des options de l'application
forward
global type w_options from w_ancestor
end type
type tab_1 from tab within w_options
end type
type tabpage_1 from userobject within tab_1
end type
type cbx_visible from uo_cbx within tabpage_1
end type
type cbx_showtext from uo_cbx within tabpage_1
end type
type cbx_user_control from uo_cbx within tabpage_1
end type
type cb_default from uo_cb within tabpage_1
end type
type rb_top from uo_radiobutton within tabpage_1
end type
type rb_bottom from uo_radiobutton within tabpage_1
end type
type rb_right from uo_radiobutton within tabpage_1
end type
type rb_left from uo_radiobutton within tabpage_1
end type
type st_1 from uo_statictext within tabpage_1
end type
type gb_2 from uo_groupbox within tabpage_1
end type
type rb_floating from uo_radiobutton within tabpage_1
end type
type gb_1 from uo_groupbox within tabpage_1
end type
type lb_toolbar from uo_listbox within tabpage_1
end type
type tabpage_1 from userobject within tab_1
cbx_visible cbx_visible
cbx_showtext cbx_showtext
cbx_user_control cbx_user_control
cb_default cb_default
rb_top rb_top
rb_bottom rb_bottom
rb_right rb_right
rb_left rb_left
st_1 st_1
gb_2 gb_2
rb_floating rb_floating
gb_1 gb_1
lb_toolbar lb_toolbar
end type
type tabpage_2 from userobject within tab_1
end type
type st_2 from uo_statictext within tabpage_2
end type
type sle_1 from uo_sle within tabpage_2
end type
type cbx_enter from uo_cbx within tabpage_2
end type
type gb_3 from uo_groupbox within tabpage_2
end type
type tabpage_2 from userobject within tab_1
st_2 st_2
sle_1 sle_1
cbx_enter cbx_enter
gb_3 gb_3
end type
type tab_1 from tab within w_options
tabpage_1 tabpage_1
tabpage_2 tabpage_2
end type
type wstr_toolbar from structure within w_options
end type
end forward

type wstr_toolbar from structure
	string		s_title
	boolean		b_visible
	toolbaralignment		al_alignment
end type

global type w_options from w_ancestor
string tag = "TEXT_00001"
integer x = 1056
integer y = 484
integer width = 1819
integer height = 1156
string title = "Options"
boolean maxbox = false
boolean resizable = false
long backcolor = 79741120
tab_1 tab_1
end type
global w_options w_options

type variables
PRIVATE	wstr_toolbar istr_toolbar[]
Integer	ii_CurrentToolbar

end variables

forward prototypes
public subroutine wf_toolbarprop (integer ai_index)
public subroutine wf_settbarray ()
end prototypes

public subroutine wf_toolbarprop (integer ai_index);// Set alignment radio button
Choose Case istr_toolbar[ai_index].al_alignment
	Case alignatleft!
		tab_1.Tabpage_1.rb_left.Checked = True
	Case alignatright!
		tab_1.Tabpage_1.rb_right.Checked = True
	Case alignattop!
		tab_1.Tabpage_1.rb_top.Checked = True
	Case alignatbottom!
		tab_1.Tabpage_1.rb_bottom.Checked = True
	Case floating!
		tab_1.Tabpage_1.rb_floating.Checked = True
End Choose

// Set visibility checkbox appropriately
tab_1.Tabpage_1.cbx_visible.Checked = istr_toolbar[ai_index].b_Visible


end subroutine

public subroutine wf_settbarray ();integer i

FOR i = 1 to gi_toolbarscount
	tab_1.Tabpage_1.lb_toolbar.DeleteItem(1)	
NEXT

FOR i = 1 to gi_toolbarscount
	gw_mdiframe.GetToolbar(i, istr_toolbar[i].b_visible, istr_toolbar[i].al_alignment, istr_toolbar[i].s_title)
	tab_1.Tabpage_1.lb_toolbar.addItem(istr_toolbar[i].s_title)
NEXT

//sélectionner le 1er toolbar de la liste
tab_1.Tabpage_1.lb_toolbar.SelectItem(1)
wf_toolbarprop(1)
ii_currenttoolbar = 1

end subroutine

on w_options.create
int iCurrent
call super::create
this.tab_1=create tab_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.tab_1
end on

on w_options.destroy
call super::destroy
destroy(this.tab_1)
end on

event ue_init_menu;call super::ue_init_menu;f_menuaction({"m_fermer"})

end event

event ue_open;call super::ue_open;integer	i

// ne pas logger de message lors de l'utilisation de cette fenêtre
wf_logusage(FALSE)

// garnir listebox et array des toolbars
wf_SetTBArray()

// garnir options communes à tous les toolbars
tab_1.Tabpage_1.cbx_user_control.Checked = GetApplication().ToolBarUserControl
tab_1.Tabpage_1.cbx_showtext.Checked = GetApplication().ToolbarText

// garnir les options du tab "divers"
tab_1.Tabpage_2.sle_1.text = gs_tmpfiles
tab_1.Tabpage_2.cbx_enter.checked = gb_EnterIsTab




end event

type tab_1 from tab within w_options
integer width = 1792
integer height = 1056
integer taborder = 10
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long backcolor = 67108864
boolean raggedright = true
integer selectedtab = 1
tabpage_1 tabpage_1
tabpage_2 tabpage_2
end type

on tab_1.create
this.tabpage_1=create tabpage_1
this.tabpage_2=create tabpage_2
this.Control[]={this.tabpage_1,&
this.tabpage_2}
end on

on tab_1.destroy
destroy(this.tabpage_1)
destroy(this.tabpage_2)
end on

event rightclicked;window	lw_parent

IF f_getparentwindow(this,lw_parent) = 1 THEN
	f_PopupAction(lw_parent)
END IF
end event

type tabpage_1 from userobject within tab_1
event create ( )
event destroy ( )
string tag = "TEXT_00002"
integer x = 18
integer y = 112
integer width = 1755
integer height = 928
long backcolor = 79741120
string text = "Barres d~'outils"
long tabtextcolor = 33554432
long tabbackcolor = 79741120
long picturemaskcolor = 536870912
cbx_visible cbx_visible
cbx_showtext cbx_showtext
cbx_user_control cbx_user_control
cb_default cb_default
rb_top rb_top
rb_bottom rb_bottom
rb_right rb_right
rb_left rb_left
st_1 st_1
gb_2 gb_2
rb_floating rb_floating
gb_1 gb_1
lb_toolbar lb_toolbar
end type

on tabpage_1.create
this.cbx_visible=create cbx_visible
this.cbx_showtext=create cbx_showtext
this.cbx_user_control=create cbx_user_control
this.cb_default=create cb_default
this.rb_top=create rb_top
this.rb_bottom=create rb_bottom
this.rb_right=create rb_right
this.rb_left=create rb_left
this.st_1=create st_1
this.gb_2=create gb_2
this.rb_floating=create rb_floating
this.gb_1=create gb_1
this.lb_toolbar=create lb_toolbar
this.Control[]={this.cbx_visible,&
this.cbx_showtext,&
this.cbx_user_control,&
this.cb_default,&
this.rb_top,&
this.rb_bottom,&
this.rb_right,&
this.rb_left,&
this.st_1,&
this.gb_2,&
this.rb_floating,&
this.gb_1,&
this.lb_toolbar}
end on

on tabpage_1.destroy
destroy(this.cbx_visible)
destroy(this.cbx_showtext)
destroy(this.cbx_user_control)
destroy(this.cb_default)
destroy(this.rb_top)
destroy(this.rb_bottom)
destroy(this.rb_right)
destroy(this.rb_left)
destroy(this.st_1)
destroy(this.gb_2)
destroy(this.rb_floating)
destroy(this.gb_1)
destroy(this.lb_toolbar)
end on

event rbuttondown;window	lw_parent

IF f_getparentwindow(this,lw_parent) = 1 THEN
	f_PopupAction(lw_parent)
END IF
end event

type cbx_visible from uo_cbx within tabpage_1
string tag = "TEXT_00013"
integer x = 1280
integer y = 144
integer width = 347
integer textsize = -9
string facename = "MS Sans Serif"
string text = "Visible"
end type

event clicked;call super::clicked;istr_toolbar[ii_currenttoolbar].b_Visible = cbx_visible.Checked

gw_mdiframe.SetToolbar(ii_CurrentToolbar, &
							istr_toolbar[ii_CurrentToolbar].b_Visible, &
							istr_toolbar[ii_CurrentToolbar].al_Alignment)

end event

type cbx_showtext from uo_cbx within tabpage_1
string tag = "TEXT_00006"
integer x = 1280
integer y = 640
integer width = 457
integer taborder = 50
integer textsize = -9
string facename = "MS Sans Serif"
string text = "Afficher le texte"
end type

event clicked;call super::clicked;// Show/Hide text on application toolbars
GetApplication().ToolbarText = This.Checked
end event

type cbx_user_control from uo_cbx within tabpage_1
string tag = "TEXT_00005"
integer x = 37
integer y = 640
integer width = 1189
integer taborder = 40
integer textsize = -9
string facename = "MS Sans Serif"
string text = "Les barres d~'outils peuvent être déplacées"
end type

event clicked;call super::clicked;// Allow/Disallow changes to application toolbars
GetApplication().ToolBarUserControl = This.Checked

end event

type cb_default from uo_cb within tabpage_1
string tag = "TEXT_00007"
integer x = 567
integer y = 768
integer width = 594
integer height = 128
integer taborder = 60
string text = "Rappeler les défauts"
end type

event clicked;call super::clicked;integer i

// toolbars en haut sauf celui des filières, à gauche
FOR i = gi_toolbarscount TO 1 STEP -1
	IF i = 4 THEN
		gw_mdiframe.SetToolbar (i, true, AlignAtLeft!)
	ELSE
		gw_mdiframe.SetToolbar (i, true, AlignAtTop!)
	END IF
	gw_mdiframe.SetToolbarPos (i, 1, 0, False)
NEXT

// on ne peut pas déplacer les toolbars
tab_1.Tabpage_1.cbx_user_control.Checked = FALSE
GetApplication().ToolBarUserControl = FALSE

// le texte n'est pas affiché
tab_1.Tabpage_1.cbx_showtext.Checked = FALSE
GetApplication().ToolbarText = FALSE

// garnir listebox et array des toolbars
wf_SetTBArray()

end event

type rb_top from uo_radiobutton within tabpage_1
string tag = "TEXT_00011"
integer x = 713
integer y = 400
integer width = 375
integer height = 72
integer textsize = -9
string facename = "MS Sans Serif"
long textcolor = 41943040
long backcolor = 74481808
string text = "&Dessus"
end type

event clicked;istr_toolbar[ii_currenttoolbar].al_Alignment = alignattop!

gw_mdiframe.SetToolbar(ii_CurrentToolbar, &
							istr_toolbar[ii_CurrentToolbar].b_Visible, &
							istr_toolbar[ii_CurrentToolbar].al_Alignment)

gw_mdiframe.SetToolbarPos (ii_CurrentToolbar, 1, 0, False)
end event

type rb_bottom from uo_radiobutton within tabpage_1
string tag = "TEXT_00012"
integer x = 713
integer y = 464
integer width = 375
integer height = 88
integer textsize = -9
string facename = "MS Sans Serif"
long textcolor = 41943040
long backcolor = 74481808
string text = "De&ssous"
end type

event clicked;istr_toolbar[ii_currenttoolbar].al_Alignment = alignatbottom!

gw_mdiframe.SetToolbar(ii_CurrentToolbar, &
							istr_toolbar[ii_CurrentToolbar].b_Visible, &
							istr_toolbar[ii_CurrentToolbar].al_Alignment)

gw_mdiframe.SetToolbarPos (ii_CurrentToolbar, 1, 0, False)
end event

type rb_right from uo_radiobutton within tabpage_1
string tag = "TEXT_00010"
integer x = 713
integer y = 272
integer width = 375
integer height = 72
integer textsize = -9
string facename = "MS Sans Serif"
long textcolor = 41943040
long backcolor = 74481808
string text = "&Droite"
end type

event clicked;istr_toolbar[ii_currenttoolbar].al_Alignment = alignatright!

gw_mdiframe.SetToolbar(ii_CurrentToolbar, &
							istr_toolbar[ii_CurrentToolbar].b_Visible, &
							istr_toolbar[ii_CurrentToolbar].al_Alignment)

gw_mdiframe.SetToolbarPos (ii_CurrentToolbar, 1, 0, False)
end event

type rb_left from uo_radiobutton within tabpage_1
string tag = "TEXT_00009"
integer x = 713
integer y = 192
integer width = 375
integer height = 72
integer textsize = -9
string facename = "MS Sans Serif"
long textcolor = 41943040
long backcolor = 74481808
string text = "&Gauche"
end type

event clicked;istr_toolbar[ii_currenttoolbar].al_Alignment = alignatleft!

gw_mdiframe.SetToolbar(ii_CurrentToolbar, &
							istr_toolbar[ii_CurrentToolbar].b_Visible, &
							istr_toolbar[ii_CurrentToolbar].al_Alignment)

gw_mdiframe.SetToolbarPos (ii_CurrentToolbar, 1, 0, False)

end event

type st_1 from uo_statictext within tabpage_1
string tag = "TEXT_00004"
integer y = 16
integer width = 613
integer textsize = -9
string facename = "MS Sans Serif"
long textcolor = 41943040
long backcolor = 74481808
string text = "Selectionner la barre d~'outils"
end type

type gb_2 from uo_groupbox within tabpage_1
integer x = 1207
integer y = 64
integer width = 457
integer height = 208
integer taborder = 30
integer textsize = -9
string facename = "MS Sans Serif"
end type

type rb_floating from uo_radiobutton within tabpage_1
string tag = "TEXT_00008"
integer x = 713
integer y = 112
integer width = 375
integer height = 72
integer textsize = -9
string facename = "MS Sans Serif"
long textcolor = 41943040
long backcolor = 74481808
string text = "&Flottant"
end type

event clicked;istr_toolbar[ii_currenttoolbar].al_Alignment = floating!

gw_mdiframe.SetToolbar(ii_CurrentToolbar, &
							istr_toolbar[ii_CurrentToolbar].b_Visible, &
							istr_toolbar[ii_CurrentToolbar].al_Alignment)

gw_mdiframe.SetToolbarPos (ii_CurrentToolbar, 1, 0, False)
end event

type gb_1 from uo_groupbox within tabpage_1
integer x = 640
integer y = 64
integer width = 475
integer height = 512
integer taborder = 20
integer textsize = -9
string facename = "MS Sans Serif"
long textcolor = 41943040
long backcolor = 74481808
end type

type lb_toolbar from uo_listbox within tabpage_1
integer x = 37
integer y = 80
integer width = 544
integer height = 496
integer taborder = 50
integer textsize = -9
string facename = "MS Sans Serif"
boolean sorted = false
end type

event selectionchanged;call super::selectionchanged;wf_toolbarprop(index)
ii_currenttoolbar = index

end event

type tabpage_2 from userobject within tab_1
string tag = "TEXT_00003"
integer x = 18
integer y = 112
integer width = 1755
integer height = 928
long backcolor = 67108864
string text = "Divers"
long tabtextcolor = 33554432
long picturemaskcolor = 536870912
st_2 st_2
sle_1 sle_1
cbx_enter cbx_enter
gb_3 gb_3
end type

on tabpage_2.create
this.st_2=create st_2
this.sle_1=create sle_1
this.cbx_enter=create cbx_enter
this.gb_3=create gb_3
this.Control[]={this.st_2,&
this.sle_1,&
this.cbx_enter,&
this.gb_3}
end on

on tabpage_2.destroy
destroy(this.st_2)
destroy(this.sle_1)
destroy(this.cbx_enter)
destroy(this.gb_3)
end on

event rbuttondown;window	lw_parent

IF f_getparentwindow(this,lw_parent) = 1 THEN
	f_PopupAction(lw_parent)
END IF
end event

type st_2 from uo_statictext within tabpage_2
string tag = "TEXT_00014"
integer x = 37
integer y = 48
integer width = 1230
string text = "Dossier pour création des fichiers temporaires"
end type

type sle_1 from uo_sle within tabpage_2
integer x = 37
integer y = 128
integer width = 1646
integer height = 80
integer taborder = 20
integer textsize = -9
integer weight = 700
long backcolor = 79741120
boolean displayonly = true
end type

type cbx_enter from uo_cbx within tabpage_2
string tag = "TEXT_00015"
integer x = 37
integer y = 304
integer width = 1445
boolean bringtotop = true
string text = "Utiliser ENTER pour passer d~'un champ à l~'autre"
boolean lefttext = true
end type

event clicked;IF SetProfileString(gs_locinifile,gs_username,"EnterIsTab",string(this.checked)) = 1 THEN
	gb_EnterIsTab = this.checked
END IF
end event

type gb_3 from uo_groupbox within tabpage_2
integer width = 1719
integer height = 896
integer taborder = 10
end type

