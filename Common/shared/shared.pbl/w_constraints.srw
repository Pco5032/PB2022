//objectcomments Affichage des contraintes d'intégrité et de leur statut + possibilité de les activer/désactiver
forward
global type w_constraints from w_ancestor
end type
type cb_disable from uo_cb within w_constraints
end type
type cb_enable from uo_cb within w_constraints
end type
type dw_1 from uo_ancestor_dwbrowse within w_constraints
end type
end forward

global type w_constraints from w_ancestor
integer width = 3593
integer height = 2284
string title = "Liste des contraintes d~'intégrité"
cb_disable cb_disable
cb_enable cb_enable
dw_1 dw_1
end type
global w_constraints w_constraints

forward prototypes
public subroutine wf_setdefaultmsg ()
end prototypes

public subroutine wf_setdefaultmsg ();// appeler le code initial...
super::wf_setdefaultmsg()

// compléter par le code voulu
wf_setMessageNoUpdate("Vous n'avez pas le droit d'utiliser cette fonction")

end subroutine

event resize;call super::resize;dw_1.width = newwidth - 10
dw_1.height = newheight - 200
cb_disable.y = newheight - 150
cb_enable.y = cb_disable.y
end event

on w_constraints.create
int iCurrent
call super::create
this.cb_disable=create cb_disable
this.cb_enable=create cb_enable
this.dw_1=create dw_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_disable
this.Control[iCurrent+2]=this.cb_enable
this.Control[iCurrent+3]=this.dw_1
end on

on w_constraints.destroy
call super::destroy
destroy(this.cb_disable)
destroy(this.cb_enable)
destroy(this.dw_1)
end on

event ue_postopen;call super::ue_postopen;dw_1.retrieve()
end event

event ue_init_menu;call super::ue_init_menu;f_menuaction({"m_fermer"})
end event

event ue_open;call super::ue_open;// ne pas logger de message lors de l'utilisation de cette fenêtre
wf_logusage(FALSE)

// autoriser la sélection de plusieurs contraintes
dw_1.uf_extendedselect(TRUE)
end event

type cb_disable from uo_cb within w_constraints
integer x = 1810
integer y = 2032
integer taborder = 20
string text = "Disable"
end type

event clicked;call super::clicked;// disabler toutes les contraintes sélectionnées
long 		ll_row
string	ls_table, ls_constraint	

// Utilisation uniquement si l'utilisateur a le droit d'update dans cette fenêtre
IF NOT wf_canupdate() THEN
	gu_message.uf_info(wf_getMessageNoUpdate())
	return
END IF

ll_row = dw_1.GetSelectedRow(0)
DO WHILE ll_row > 0
	ls_table = dw_1.object.table_name[ll_row]
	ls_constraint = dw_1.object.constraint_name[ll_row]
	gu_db.uf_disableconstraint(ls_table, ls_constraint)
	ll_row = dw_1.GetSelectedRow(ll_row)
LOOP

dw_1.retrieve()
end event

type cb_enable from uo_cb within w_constraints
integer x = 1225
integer y = 2032
integer taborder = 20
string text = "Enable"
end type

event clicked;call super::clicked;// enabler toutes les contraintes sélectionnées
long 		ll_row
string	ls_table, ls_constraint	

// Utilisation uniquement si l'utilisateur a le droit d'update dans cette fenêtre
IF NOT wf_canupdate() THEN
	gu_message.uf_info(wf_getMessageNoUpdate())
	return
END IF

ll_row = dw_1.GetSelectedRow(0)
DO WHILE ll_row > 0
	ls_table = dw_1.object.table_name[ll_row]
	ls_constraint = dw_1.object.constraint_name[ll_row]
	gu_db.uf_enableconstraint(ls_table, ls_constraint)
	ll_row = dw_1.GetSelectedRow(ll_row)
LOOP

dw_1.retrieve()
end event

type dw_1 from uo_ancestor_dwbrowse within w_constraints
integer width = 3547
integer height = 2000
integer taborder = 10
string dataobject = "d_constraints"
boolean hscrollbar = true
boolean vscrollbar = true
boolean border = true
boolean hsplitscroll = true
end type

