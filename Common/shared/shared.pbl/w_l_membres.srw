//objectcomments Affichage des membres d'un groupe
forward
global type w_l_membres from w_ancestor
end type
type dw_1 from uo_ancestor_dwbrowse within w_l_membres
end type
type cb_1 from uo_cb_ok within w_l_membres
end type
end forward

global type w_l_membres from w_ancestor
integer width = 3182
integer height = 2092
string title = "Membres du groupe"
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
dw_1 dw_1
cb_1 cb_1
end type
global w_l_membres w_l_membres

type variables
integer	ii_groupe
end variables

on w_l_membres.create
int iCurrent
call super::create
this.dw_1=create dw_1
this.cb_1=create cb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_1
this.Control[iCurrent+2]=this.cb_1
end on

on w_l_membres.destroy
call super::destroy
destroy(this.dw_1)
destroy(this.cb_1)
end on

event ue_postopen;call super::ue_postopen;long		ll_row, ll_nbrows, ll_gr
string	ls_groups[]
boolean	lb_yes

dw_1.SetRedraw(FALSE)
ll_nbrows = dw_1.Retrieve()
FOR ll_row = 1 TO ll_nbrows
	lb_yes = FALSE
	f_parse(f_string(dw_1.object.groups[ll_row]), ",", ls_groups)
	FOR ll_gr = 1 TO UpperBound(ls_groups)
		IF integer(ls_groups[ll_gr]) = ii_groupe THEN
			lb_yes = TRUE
			EXIT
		END IF
	NEXT
	IF NOT lb_yes THEN
		dw_1.RowsDiscard(ll_row, ll_row, Primary!)
		ll_row = ll_row - 1
		ll_nbrows = ll_nbrows - 1
	END IF
NEXT
dw_1.SetRedraw(TRUE)
end event

event ue_open;call super::ue_open;f_centerInMdi(this)

// ne pas logger de message lors de l'utilisation de cette fenêtre
wf_logusage(FALSE)

// assigner les couleurs pour les lignes paires et impaires du DW principal
gu_dwservices.uf_setbrowsecol(dw_1)

ii_groupe = Message.DoubleParm
This.Title = "Membres du groupe " + string(ii_groupe)

end event

type dw_1 from uo_ancestor_dwbrowse within w_l_membres
integer width = 3163
integer height = 1808
integer taborder = 10
string dataobject = "d_l_users"
boolean vscrollbar = true
boolean border = true
end type

type cb_1 from uo_cb_ok within w_l_membres
integer x = 1381
integer y = 1856
integer taborder = 20
end type

event clicked;call super::clicked;close(parent)
end event

