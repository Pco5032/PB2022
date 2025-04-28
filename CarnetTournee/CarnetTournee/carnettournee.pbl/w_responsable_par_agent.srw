//objectcomments Visualisation/suppression des services dont un agent est responsable
forward
global type w_responsable_par_agent from w_ancestor_dataentry
end type
type dw_responsable from uo_datawindow_multiplerow within w_responsable_par_agent
end type
end forward

global type w_responsable_par_agent from w_ancestor_dataentry
integer width = 3547
integer height = 2096
string title = "Liste des responsables (C1, CP, GR) de service(s)"
boolean maxbox = true
boolean resizable = true
dw_responsable dw_responsable
end type
global w_responsable_par_agent w_responsable_par_agent

type variables
string	is_codeservice
end variables

on w_responsable_par_agent.create
int iCurrent
call super::create
this.dw_responsable=create dw_responsable
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_responsable
end on

on w_responsable_par_agent.destroy
call super::destroy
destroy(this.dw_responsable)
end on

event resize;call super::resize;dw_responsable.width = newwidth - 8
dw_responsable.height = newheight - 100
end event

event ue_open;call super::ue_open;// initialiser liste des DW modifiables
wf_SetDWList({dw_responsable})

// divers settings des DW
dw_responsable.uf_checkallrow(TRUE)
dw_responsable.uf_sort(TRUE)
dw_responsable.uf_createwhenlastdeleted(FALSE)


end event

event ue_supprimer;call super::ue_supprimer;string	ls_matricule, ls_service, ls_role
long		ll_row

ll_row = dw_responsable.GetRow()
IF ll_row = 0 THEN return

ls_matricule = f_string(dw_responsable.object.responsable_matricule[ll_row])
ls_service = f_string(dw_responsable.object.responsable_codeservice[ll_row])
ls_role = f_string(dw_responsable.object.responsable_role[ll_row])

IF f_confirm_del("Voulez-vous supprimer l'agent " + ls_matricule + &
					  " comme " + ls_role + " du service " + ls_service) = 1 THEN
	dw_responsable.event ue_delete()
	IF ll_row <= dw_responsable.rowCount() THEN
		dw_responsable.scrollToRow(ll_row + 1)
		dw_responsable.scrollToRow(ll_row)
	ELSEIF ll_row - 1 >= dw_responsable.rowCount() THEN
		dw_responsable.scrollToRow(ll_row - 1)
	END IF
END IF

end event

event ue_init_menu;call super::ue_init_menu;IF wf_isactif() THEN
	f_menuaction({"m_enregistrer", "m_supprimer", "m_fermer"})
ELSE
	f_menuaction({"m_fermer"})
END IF



end event

event ue_enregistrer;call super::ue_enregistrer;// contrôle de validité de tous les champs
IF dw_responsable.event ue_checkall() < 0 THEN
	dw_responsable.SetFocus()
	return(-1)
END IF

IF dw_responsable.event ue_update() = 1 THEN
	wf_message("Liste des agents enregistrée avec succès")
	this.event ue_init_win()
	return(1)
ELSE
	populateerror(20000, "")
	gu_message.uf_unexp("RESPONSABLE : Erreur lors de la mise à jour de la base de données")
	return(-1)
END IF
end event

event ue_postopen;call super::ue_postopen;// lecture des agents qui exercent une responsabilité C1/CP
dw_responsable.retrieve()
wf_actif(true)
end event

type ddlb_message from w_ancestor_dataentry`ddlb_message within w_responsable_par_agent
integer y = 1888
end type

type dw_responsable from uo_datawindow_multiplerow within w_responsable_par_agent
integer width = 3511
integer height = 1728
integer taborder = 10
boolean bringtotop = true
string dataobject = "d_responsable_par_agent"
boolean hscrollbar = true
boolean vscrollbar = true
boolean border = true
end type

