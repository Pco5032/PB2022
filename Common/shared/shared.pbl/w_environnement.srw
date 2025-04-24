//objectcomments Affichage des variables d'environnement globales communes à toutes les applications ET celles propres à l'application en cours
forward
global type w_environnement from w_ancestor
end type
type sle_appname from uo_sle within w_environnement
end type
type st_6 from uo_statictext within w_environnement
end type
type sle_processbitness from uo_sle within w_environnement
end type
type st_5 from uo_statictext within w_environnement
end type
type cb_msinfo from uo_cb within w_environnement
end type
type cb_ok from uo_cb_ok within w_environnement
end type
type st_4 from uo_statictext within w_environnement
end type
type st_3 from uo_statictext within w_environnement
end type
type sle_screen from uo_sle within w_environnement
end type
type sle_rtspath from uo_sle within w_environnement
end type
type st_2 from uo_statictext within w_environnement
end type
type st_1 from uo_statictext within w_environnement
end type
type sle_pbtype from uo_sle within w_environnement
end type
type sle_ostype from uo_sle within w_environnement
end type
end forward

global type w_environnement from w_ancestor
string tag = "TEXT_00062"
integer x = 1170
integer y = 804
integer width = 1733
integer height = 1104
string title = "Environnement"
windowtype windowtype = response!
long backcolor = 79741120
sle_appname sle_appname
st_6 st_6
sle_processbitness sle_processbitness
st_5 st_5
cb_msinfo cb_msinfo
cb_ok cb_ok
st_4 st_4
st_3 st_3
sle_screen sle_screen
sle_rtspath sle_rtspath
st_2 st_2
st_1 st_1
sle_pbtype sle_pbtype
sle_ostype sle_ostype
end type
global w_environnement w_environnement

on w_environnement.create
int iCurrent
call super::create
this.sle_appname=create sle_appname
this.st_6=create st_6
this.sle_processbitness=create sle_processbitness
this.st_5=create st_5
this.cb_msinfo=create cb_msinfo
this.cb_ok=create cb_ok
this.st_4=create st_4
this.st_3=create st_3
this.sle_screen=create sle_screen
this.sle_rtspath=create sle_rtspath
this.st_2=create st_2
this.st_1=create st_1
this.sle_pbtype=create sle_pbtype
this.sle_ostype=create sle_ostype
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.sle_appname
this.Control[iCurrent+2]=this.st_6
this.Control[iCurrent+3]=this.sle_processbitness
this.Control[iCurrent+4]=this.st_5
this.Control[iCurrent+5]=this.cb_msinfo
this.Control[iCurrent+6]=this.cb_ok
this.Control[iCurrent+7]=this.st_4
this.Control[iCurrent+8]=this.st_3
this.Control[iCurrent+9]=this.sle_screen
this.Control[iCurrent+10]=this.sle_rtspath
this.Control[iCurrent+11]=this.st_2
this.Control[iCurrent+12]=this.st_1
this.Control[iCurrent+13]=this.sle_pbtype
this.Control[iCurrent+14]=this.sle_ostype
end on

on w_environnement.destroy
call super::destroy
destroy(this.sle_appname)
destroy(this.st_6)
destroy(this.sle_processbitness)
destroy(this.st_5)
destroy(this.cb_msinfo)
destroy(this.cb_ok)
destroy(this.st_4)
destroy(this.st_3)
destroy(this.sle_screen)
destroy(this.sle_rtspath)
destroy(this.st_2)
destroy(this.st_1)
destroy(this.sle_pbtype)
destroy(this.sle_ostype)
end on

event ue_open;call super::ue_open;environment e_env
integer i_status

f_centerInMdi(this)

// ne pas logger de message lors de l'utilisation de cette fenêtre
wf_logusage(FALSE)

sle_appname.text = GetApplication().appName

i_status = GetEnvironment(e_env)
IF i_status <> 1 THEN RETURN

CHOOSE CASE e_env.OSType
	CASE Windows!, WindowsNT!
		sle_OSTYPE.text = "Windows"
	CASE ELSE
		sle_OSTYPE.text = "Autre"
END CHOOSE

sle_OSTYPE.text = sle_OSTYPE.text + " " + string(e_env.OSMajorRevision) + "." + string(e_env.OSMinorRevision) &
						+ string(e_env.OSFixesRevision) + " (" + f_string(gs_osversion) + ")"
				
sle_PBTYPE.text = "Powerbuilder " + string(e_env.PBMajorRevision) + "." + string(e_env.PBMinorRevision) &
						+ string(e_env.PBFixesRevision) + " build " + string(e_env.PBBuildNumber)

sle_ProcessBitness.text = string(e_env.ProcessBitness) + " bits"

sle_rtspath.text = string(e_env.RuntimePath)

sle_SCREEN.text = string(e_env.ScreenWidth) + " X " + string(e_env.ScreenHeight)
end event

type sle_appname from uo_sle within w_environnement
integer x = 677
integer y = 64
integer width = 951
integer height = 80
integer taborder = 10
boolean autohscroll = false
boolean displayonly = true
end type

type st_6 from uo_statictext within w_environnement
integer x = 37
integer y = 64
integer width = 613
integer height = 76
string text = "Application"
end type

type sle_processbitness from uo_sle within w_environnement
integer x = 677
integer y = 352
integer width = 951
integer height = 80
boolean autohscroll = false
boolean displayonly = true
end type

type st_5 from uo_statictext within w_environnement
integer x = 37
integer y = 352
integer width = 631
integer height = 76
string text = "Processing"
end type

type cb_msinfo from uo_cb within w_environnement
string tag = "TEXT_00061"
integer x = 549
integer y = 704
integer width = 494
integer height = 128
string text = "Infos Système..."
end type

event clicked;IF run ("MSINFO32.EXE") = -1 THEN
	gu_message.uf_error("Le programme MSINFO32.EXE n'est pas accessible")
END IF
end event

type cb_ok from uo_cb_ok within w_environnement
string tag = "TEXT_00027"
integer x = 549
integer y = 848
integer width = 494
integer height = 128
integer taborder = 20
boolean cancel = true
end type

event clicked;close(parent)
end event

type st_4 from uo_statictext within w_environnement
string tag = "TEXT_00058"
integer x = 37
integer y = 544
integer width = 613
integer height = 76
string text = "Résolution écran"
end type

type st_3 from uo_statictext within w_environnement
string tag = "TEXT_00059"
integer x = 37
integer y = 448
integer width = 622
string text = "Runtime path"
end type

type sle_screen from uo_sle within w_environnement
integer x = 677
integer y = 544
integer width = 512
integer height = 80
boolean autohscroll = false
boolean displayonly = true
end type

type sle_rtspath from uo_sle within w_environnement
integer x = 677
integer y = 448
integer width = 951
integer height = 80
boolean displayonly = true
end type

type st_2 from uo_statictext within w_environnement
string tag = "TEXT_00057"
integer x = 37
integer y = 256
integer width = 631
integer height = 76
string text = "Outil de développement"
end type

type st_1 from uo_statictext within w_environnement
string tag = "TEXT_00056"
integer x = 37
integer y = 160
integer width = 613
integer height = 76
string text = "Système d~'exploitation"
end type

type sle_pbtype from uo_sle within w_environnement
integer x = 677
integer y = 256
integer width = 951
integer height = 80
boolean autohscroll = false
boolean displayonly = true
end type

type sle_ostype from uo_sle within w_environnement
integer x = 677
integer y = 160
integer width = 951
integer height = 80
boolean autohscroll = false
boolean displayonly = true
end type

