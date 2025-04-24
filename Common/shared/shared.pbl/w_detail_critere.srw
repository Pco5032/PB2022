//objectcomments Gestion du détail de chaque critère qui pourra ensuite être utilisé comme critère de sélection ou de tri dans w_report_critere et w_report_predeftri
forward
global type w_detail_critere from w_ancestor_dataentry
end type
type dw_1 from uo_datawindow_multiplerow within w_detail_critere
end type
end forward

global type w_detail_critere from w_ancestor_dataentry
integer width = 3739
integer height = 2148
string title = "Détail des critères de sélection"
boolean maxbox = true
boolean resizable = true
event ue_print ( )
dw_1 dw_1
end type
global w_detail_critere w_detail_critere

type variables
boolean	ib_updatable
end variables

event ue_print;str_params	lstr_params

//  Ouverture de la fenêtre print_setup avec comme paramètre le nom du datawindow et l'autorisation ou pas de cancel
lstr_params.a_param[1] = dw_1
lstr_params.a_param[2] = TRUE

openwithparm(w_print_setup, lstr_params)


end event

on w_detail_critere.create
int iCurrent
call super::create
this.dw_1=create dw_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_1
end on

on w_detail_critere.destroy
call super::destroy
destroy(this.dw_1)
end on

event ue_abandonner;post close(this)
return(0)
end event

event ue_ajouter;call super::ue_ajouter;long	 ll_row
ll_row = dw_1.event ue_addrow()
IF ll_row > 0 THEN
	dw_1.object.ucase[ll_row] = "N"
END IF
end event

event ue_supprimer;call super::ue_supprimer;dw_1.event ue_delete()
end event

event ue_enregistrer;call super::ue_enregistrer;integer	li_status

SetPointer(HOURGLASS!)
// contrôle de validité de tous les champs
IF dw_1.event ue_checkall() < 0 THEN
	return(-1)
END IF

// update
li_status = gu_dwservices.uf_updateTransact(dw_1)
CHOOSE CASE li_status
	CASE 1
		wf_message("Enregistrement OK")
		return(1)
	CASE -1
		gu_message.uf_error("Erreur lors de la mise à jour de la base de données")
		return(-1)
END CHOOSE

end event

event resize;call super::resize;dw_1.height = wf_getWSHeight()
dw_1.width = wf_getWSWidth()
end event

event ue_init_menu;call super::ue_init_menu;IF ib_updatable THEN
	f_menuaction({"m_enregistrer","m_ajouter","m_supprimer","m_abandonner","m_fermer"})
ELSE
	f_menuaction({"m_abandonner","m_fermer"})
END IF

end event

event ue_init_win;call super::ue_init_win;IF ib_updatable THEN
	wf_actif(TRUE)
END IF
end event

event ue_open;call super::ue_open;// ne pas logger de message lors de l'utilisation de cette fenêtre
wf_logusage(FALSE)

wf_SetItemsToShow({"m_ajouter"})
wf_SetDWList({dw_1})
dw_1.uf_sort(TRUE)

// tester si on travaille sur une table ou un snapshot
IF f_tableExists('detail_critere', ESQLCA) THEN
	ib_updatable = true
else
	ib_updatable = false
end if

dw_1.retrieve()
end event

type ddlb_message from w_ancestor_dataentry`ddlb_message within w_detail_critere
integer y = 1904
end type

type dw_1 from uo_datawindow_multiplerow within w_detail_critere
integer width = 3694
integer height = 1808
integer taborder = 10
boolean bringtotop = true
string dataobject = "d_detail_critere"
boolean hscrollbar = true
boolean vscrollbar = true
end type

