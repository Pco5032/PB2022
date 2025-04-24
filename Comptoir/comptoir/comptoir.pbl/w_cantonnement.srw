//objectcomments Encodage des cantonnements
forward
global type w_cantonnement from w_ancestor_dataentry
end type
type tab_1 from tab within w_cantonnement
end type
type tabpage_1 from userobject within tab_1
end type
type gb_2 from uo_groupbox within tabpage_1
end type
type dw_can from uo_datawindow_singlerow within tabpage_1
end type
type tabpage_1 from userobject within tab_1
gb_2 gb_2
dw_can dw_can
end type
type tab_1 from tab within w_cantonnement
tabpage_1 tabpage_1
end type
type dw_key from uo_datawindow_singlerow within w_cantonnement
end type
type st_1 from uo_statictext within w_cantonnement
end type
type gb_1 from uo_groupbox within w_cantonnement
end type
end forward

global type w_cantonnement from w_ancestor_dataentry
integer width = 3131
integer height = 1960
string title = "Cantonnements"
boolean resizable = true
tab_1 tab_1
dw_key dw_key
st_1 st_1
gb_1 gb_1
end type
global w_cantonnement w_cantonnement

type variables
integer	ii_can
long		il_oldw
dw_can	idw_can

end variables

on w_cantonnement.create
int iCurrent
call super::create
this.tab_1=create tab_1
this.dw_key=create dw_key
this.st_1=create st_1
this.gb_1=create gb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.tab_1
this.Control[iCurrent+2]=this.dw_key
this.Control[iCurrent+3]=this.st_1
this.Control[iCurrent+4]=this.gb_1
end on

on w_cantonnement.destroy
call super::destroy
destroy(this.tab_1)
destroy(this.dw_key)
destroy(this.st_1)
destroy(this.gb_1)
end on

event ue_init_menu;call super::ue_init_menu;f_menuaction({"m_abandonner", "m_fermer"})

end event

event ue_init_win;call super::ue_init_win;this.setredraw(FALSE)

dw_key.uf_reset()
dw_key.insertrow(0)

dw_key.uf_enablekeys()
dw_key.enabled = TRUE
dw_key.setfocus()

tab_1.SelectTab(1)
tab_1.enabled = FALSE

this.setredraw(TRUE)

end event

event ue_close;call super::ue_close;idw_can.ShareDataOff()

end event

event ue_open;call super::ue_open;integer	li_status

il_oldw = this.width

idw_can = tab_1.tabpage_1.dw_can

dw_key.uf_additemstokey ({'can'})

// partage des données entre dw key et data
li_status = dw_key.ShareData(idw_can)
IF li_status = -1 THEN
	populateerror(20000,"")
	gu_message.uf_unexp("dw_key : partage des données impossible")
	post close(this)
	return
END IF

end event

event resize;call super::resize;tab_1.height = newheight - 410
tab_1.width = newwidth

end event

type ddlb_message from w_ancestor_dataentry`ddlb_message within w_cantonnement
integer y = 1760
integer width = 1810
end type

type tab_1 from tab within w_cantonnement
integer y = 320
integer width = 3090
integer height = 1424
integer taborder = 20
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long backcolor = 67108864
boolean raggedright = true
boolean focusonbuttondown = true
boolean boldselectedtext = true
integer selectedtab = 1
tabpage_1 tabpage_1
end type

on tab_1.create
this.tabpage_1=create tabpage_1
this.Control[]={this.tabpage_1}
end on

on tab_1.destroy
destroy(this.tabpage_1)
end on

event rightclicked;window	lw_parent

IF f_getparentwindow(this,lw_parent) = 1 THEN
	f_PopupAction(lw_parent)
END IF
end event

type tabpage_1 from userobject within tab_1
integer x = 18
integer y = 108
integer width = 3054
integer height = 1300
long backcolor = 67108864
string text = "Description"
long tabtextcolor = 33554432
long picturemaskcolor = 536870912
gb_2 gb_2
dw_can dw_can
end type

on tabpage_1.create
this.gb_2=create gb_2
this.dw_can=create dw_can
this.Control[]={this.gb_2,&
this.dw_can}
end on

on tabpage_1.destroy
destroy(this.gb_2)
destroy(this.dw_can)
end on

event rbuttondown;window	lw_parent
IF f_GetParentWindow(this, lw_parent) = 1 THEN
	IF lw_parent.windowtype <> Response! THEN f_PopupAction(lw_parent)
END IF
end event

type gb_2 from uo_groupbox within tabpage_1
integer x = 18
integer y = 4
integer width = 3017
integer height = 1280
integer taborder = 30
end type

type dw_can from uo_datawindow_singlerow within tabpage_1
integer x = 475
integer y = 100
integer width = 2066
integer height = 1120
integer taborder = 20
boolean bringtotop = true
string dataobject = "d_cantonnement"
boolean livescroll = false
end type

type dw_key from uo_datawindow_singlerow within w_cantonnement
integer x = 512
integer y = 192
integer width = 2066
integer height = 96
integer taborder = 10
boolean bringtotop = true
string dataobject = "d_cantonnement_key"
boolean livescroll = false
end type

event ue_leavekey;call super::ue_leavekey;// lecture du record
this.retrieve(ii_can)

// effacer les messages
ddlb_message.reset()

// disabler la clé
this.enabled = FALSE
this.uf_disablekeys()

tab_1.enabled = TRUE

parent.event ue_init_menu()


end event

event ue_help;call super::ue_help;str_params lstr_params

CHOOSE CASE idwo_currentItem.name
	CASE "can"
		openwithparm(w_l_can,lstr_params)
		IF Message.DoubleParm = -1 THEN return
		lstr_params=Message.PowerObjectParm
		this.SetText(string (lstr_params.a_param[1]))
		f_presskey("tab")
END CHOOSE

end event

event ue_checkitem;call super::ue_checkitem;integer	li_can
string	ls_message

CHOOSE CASE as_item
	CASE "can"
		IF f_check_can (integer(as_data), ls_message) = 1 THEN
			ii_can = integer(as_data)
			return(1)
		ELSE
			as_message = "Cantonnement inexistant"
			return(-1)
		END IF	
	
END CHOOSE
return(1)

end event

type st_1 from uo_statictext within w_cantonnement
integer width = 3072
integer height = 160
boolean bringtotop = true
integer textsize = -12
integer weight = 700
long textcolor = 255
string text = "Remarque : les modifications se font dans DBCentrale au moyen des programmes Agents et Services"
alignment alignment = center!
end type

type gb_1 from uo_groupbox within w_cantonnement
integer x = 37
integer y = 128
integer width = 3017
integer height = 176
end type

