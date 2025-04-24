//objectcomments Affichage des privilèges de l'utilisateur en cours
forward
global type w_showprivs from w_ancestor
end type
type dw_3 from uo_ancestor_dwbrowse within w_showprivs
end type
type dw_1 from uo_ancestor_dwbrowse within w_showprivs
end type
end forward

global type w_showprivs from w_ancestor
integer width = 2450
integer height = 1736
string title = "Privilèges spécifiques à ...."
dw_3 dw_3
dw_1 dw_1
end type
global w_showprivs w_showprivs

on w_showprivs.create
int iCurrent
call super::create
this.dw_3=create dw_3
this.dw_1=create dw_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_3
this.Control[iCurrent+2]=this.dw_1
end on

on w_showprivs.destroy
call super::destroy
destroy(this.dw_3)
destroy(this.dw_1)
end on

event resize;call super::resize;dw_1.height = newheight
dw_3.height = newheight

end event

event ue_init_menu;call super::ue_init_menu;f_menuaction({"m_fermer"})
end event

event ue_open;call super::ue_open;this.Title = "Privilèges spécifiques à " + gs_username
// assigner les couleurs pour les lignes paires et impaires du DW principal
gu_dwservices.uf_setbrowsecol(dw_1)
gu_dwservices.uf_setbrowsecol(dw_3)

gu_privs.ids_privs.RowsCopy(1, 999999999, Primary!, dw_1, 999999999, Primary!)
gu_privs.ids_superprivs.RowsCopy(1, 999999999, Primary!, dw_3, 999999999, Primary!)

// ne pas logger de message lors de l'utilisation de cette fenêtre
wf_logusage(FALSE)
end event

type dw_3 from uo_ancestor_dwbrowse within w_showprivs
integer x = 1664
integer width = 731
integer height = 1616
integer taborder = 10
string dataobject = "d_superprivs"
boolean vscrollbar = true
boolean border = true
end type

type dw_1 from uo_ancestor_dwbrowse within w_showprivs
integer width = 1646
integer height = 1616
integer taborder = 10
string dataobject = "d_privs"
boolean vscrollbar = true
boolean border = true
end type

