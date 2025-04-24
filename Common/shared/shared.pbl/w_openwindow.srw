//objectcomments Fenêtre de choix et d'ouverture d'un programme non prévu au menu
forward
global type w_openwindow from w_ancestor
end type
type ddlb_window from uo_dropdownlistbox within w_openwindow
end type
type st_1 from uo_statictext within w_openwindow
end type
type cb_open from uo_cb within w_openwindow
end type
end forward

global type w_openwindow from w_ancestor
string tag = "TEXT_00075"
integer x = 1074
integer y = 484
integer width = 1545
integer height = 632
string title = "Démarrer un programme non prévu au menu"
boolean maxbox = false
boolean resizable = false
long backcolor = 79741120
ddlb_window ddlb_window
st_1 st_1
cb_open cb_open
end type
global w_openwindow w_openwindow

type variables

end variables

on w_openwindow.create
int iCurrent
call super::create
this.ddlb_window=create ddlb_window
this.st_1=create st_1
this.cb_open=create cb_open
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.ddlb_window
this.Control[iCurrent+2]=this.st_1
this.Control[iCurrent+3]=this.cb_open
end on

on w_openwindow.destroy
call super::destroy
destroy(this.ddlb_window)
destroy(this.st_1)
destroy(this.cb_open)
end on

event ue_init_menu;call super::ue_init_menu;f_menuaction({"m_fermer"})
end event

event ue_postopen;call super::ue_postopen;string  s_profilestring
integer i_win

// lecture dans .ini service
FOR i_win=0 TO 99
	s_profilestring = ProfileString(gs_serviceinifile,"windowstest","win" + string(i_win),"")
	IF s_profilestring <> "" THEN
		ddlb_window.AddItem(s_profilestring)
	END IF
NEXT

// lecture dans .ini local (si ce fichier est différent du .ini service)
IF gs_locinifile <> gs_serviceinifile THEN
	FOR i_win=0 TO 99
		s_profilestring = ProfileString(gs_locinifile,"windowstest","win" + string(i_win),"")
		IF s_profilestring <> "" AND ddlb_window.FindItem(s_profilestring, 0) = -1 THEN
			ddlb_window.AddItem(s_profilestring)
		END IF
	NEXT
END IF

// lecture dans .ini global
FOR i_win=0 TO 99
	s_profilestring = ProfileString(gs_inifile,"windowstest","win" + string(i_win),"")
	IF s_profilestring <> ""  AND ddlb_window.FindItem(s_profilestring, 0) = -1 THEN
		ddlb_window.AddItem(s_profilestring)
	END IF
NEXT
ddlb_window.SelectItem(1)

end event

event ue_open;call super::ue_open;// ne pas logger de message lors de l'utilisation de cette fenêtre
wf_logusage(FALSE)
end event

type ddlb_window from uo_dropdownlistbox within w_openwindow
integer x = 585
integer y = 96
integer width = 896
integer height = 448
integer taborder = 10
integer textsize = -8
boolean allowedit = true
boolean autohscroll = true
boolean sorted = false
boolean vscrollbar = true
end type

type st_1 from uo_statictext within w_openwindow
string tag = "TEXT_00073"
integer x = 37
integer y = 96
integer width = 535
integer height = 76
string text = "Nom du programme"
end type

type cb_open from uo_cb within w_openwindow
string tag = "TEXT_00074"
integer x = 530
integer y = 288
integer width = 457
integer taborder = 20
string text = "&Ouvrir"
boolean default = true
end type

event clicked;window	l_window
string	ls_name
integer	li_rtn

ls_name = f_string(ddlb_window.text)
IF f_isEmptyString(ls_name) THEN return

try
	li_rtn = opensheet(l_window, ddlb_window.text, gw_mdiframe, 0, Original!)
	IF li_rtn <> 1 THEN gu_message.uf_error("Erreur ouverture programme " + ls_name)
catch (runtimeerror rt)
	gu_message.uf_error("Erreur ouverture programme " + ls_name)
end try
end event

