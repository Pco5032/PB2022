//objectcomments Encodage des régions de provenance
forward
global type w_regionprov from w_ancestor_dataentry
end type
type dw_1 from uo_datawindow_multiplerow within w_regionprov
end type
type p_1 from uo_picture within w_regionprov
end type
end forward

global type w_regionprov from w_ancestor_dataentry
integer height = 2172
string title = "Régions de provenance"
boolean maxbox = true
boolean resizable = true
dw_1 dw_1
p_1 p_1
end type
global w_regionprov w_regionprov

type variables
br_regionprov	ibr_regionprov
end variables

on w_regionprov.create
int iCurrent
call super::create
this.dw_1=create dw_1
this.p_1=create p_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_1
this.Control[iCurrent+2]=this.p_1
end on

on w_regionprov.destroy
call super::destroy
destroy(this.dw_1)
destroy(this.p_1)
end on

event resize;call super::resize;dw_1.width = newwidth
dw_1.height = newheight - 90
end event

event ue_open;call super::ue_open;ibr_regionprov = CREATE br_regionprov

// icône "ajouter" doit être visible dans le menu (si on a le droit de modifier les données)
IF wf_canUpdate() THEN
	wf_SetItemsToShow({"m_ajouter","m_inserer"})
END IF

// initialiser liste des DW modifiables
wf_SetDWList({dw_1})

// divers settings des DW
dw_1.setrowfocusindicator(p_1)
dw_1.uf_checkallrow(FALSE)
dw_1.uf_sort(TRUE)

// lecture de tout
IF dw_1.retrieve() < 0 THEN
	wf_Executepostopen(FALSE)
	post close(this)
	return
END IF

dw_1.SetFocus()
end event

event ue_close;call super::ue_close;DESTROY ibr_regionprov
end event

event ue_init_menu;call super::ue_init_menu;string	ls_menu[]
integer	li_item

ls_menu = {"m_abandonner", "m_fermer"}
li_item = 2

// NB : quand on a les droits d'update, on doit pouvoir ajouter des régions, donc on doit pouvoir supprimer
//   aussi une région qu'on vient d'ajouter et qu'on a pas encore enregistré --> la suppression est active
IF wf_canUpdate() THEN
	li_item++
	ls_menu[li_item] = "m_enregistrer"
	li_item++
	ls_menu[li_item] = "m_ajouter"
	li_item++
	ls_menu[li_item] = "m_inserer"
	li_item++
	ls_menu[li_item] = "m_supprimer"
END IF
// NB : avoir uniquement le droit de supprimer (sans update) est inutile car on ne pourra pas enregistrer
//      les modif --> on n'active pas l'action supprimer

f_menuaction(ls_menu)


end event

event ue_init_win;call super::ue_init_win;// la fenêtre contient tout de suite des données actives (le retrieve est déjà fait)
IF wf_canupdate() THEN
	wf_actif(TRUE)
END IF
end event

event ue_abandonner;// OVERRIDE ancestor's script 
post close(this)
return(0)

end event

event ue_ajouter;call super::ue_ajouter;long	ll_row

ll_row = dw_1.event ue_addrow()
dw_1.SetColumn("num_regprov")
end event

event ue_enregistrer;call super::ue_enregistrer;// contrôle de validité de tous les champs
IF dw_1.event ue_checkall() < 0 THEN
	dw_1.SetFocus()
	return(-1)
END IF

IF dw_1.event ue_update() = 1 THEN
	wf_message("Régions de provenances enregistrées avec succès")
	post close(this)
	return(1)
ELSE
	populateerror(20000, "")
	gu_message.uf_unexp("REGION_PROV : Erreur lors de la mise à jour de la base de données")
	return(-1)
END IF
end event

event ue_inserer;call super::ue_inserer;long	ll_row

ll_row = dw_1.event ue_insertrow()
dw_1.SetColumn("num_regprov")
end event

event ue_supprimer;call super::ue_supprimer;string	ls_message
integer	li_code
dwItemStatus l_status

IF dw_1.GetRow() = 0 THEN return

// NB : quand on a les droits d'update, on doit pouvoir ajouter des régions, donc on doit pouvoir supprimer
//   aussi une région qu'on vient d'ajouter et qu'on a pas encore enregistré --> la suppression est active
//   dans ce cas de figure alors qu'on a pas le droit DELETE !
l_status = dw_1.GetItemStatus(dw_1.GetRow(), 0, Primary!)
IF NOT wf_canDelete() AND l_status <> new! and l_status <> newModified! THEN
	gu_message.uf_info(wf_getMessageNoDelete())
	return
END IF

li_code = dw_1.object.num_regprov[dw_1.GetRow()]

IF ibr_regionprov.uf_check_beforedelete(li_code, ls_message) = -1 THEN
	gu_message.uf_info(ls_message)
	return
END IF

IF f_confirm_del("Voulez-vous supprimer la région de provenance n° " + f_string(li_code) + " ?") = 1 THEN
	dw_1.event ue_delete()
END IF

end event

event ue_pre_supprimer;// ! override ancestror's script car contrôle se fera dans ue_supprimer
// pour qu'on puisse supprimer certaines choses quand on a les droits 'update'
IF wf_candelete() OR wf_canupdate() THEN
	this.event ue_supprimer()
ELSE
	gu_message.uf_info(wf_getMessageNoDelete())
	return
END IF

end event

type ddlb_message from w_ancestor_dataentry`ddlb_message within w_regionprov
integer x = 18
integer y = 1968
end type

type dw_1 from uo_datawindow_multiplerow within w_regionprov
integer width = 3493
integer height = 1952
integer taborder = 10
boolean bringtotop = true
string dataobject = "d_regionprog"
boolean vscrollbar = true
boolean border = true
end type

event ue_checkitem;call super::ue_checkitem;long	ll_row

CHOOSE CASE as_item
	CASE "num_regprov"
		IF ibr_regionprov.uf_check_num(as_data, as_message) = -1 THEN
			return(-1)
		END IF
		// s'assurer de l'unicité du code
		IF dw_1.find("num_regprov=" + as_data +" and getrow()<>" + string(al_row), 1, dw_1.RowCount()) > 0 THEN
			as_message = "Ce n° d'identification d'une provenance existe déjà"
			return(-1)
		END IF

	CASE "code_regprov"
		return(ibr_regionprov.uf_check_coderegprov(as_data, as_message))
		
	CASE "nom"
		return(ibr_regionprov.uf_check_nom(as_data, as_message))
		
	CASE "pays"
		return(ibr_regionprov.uf_check_pays(as_data, as_message))
		
	CASE "region"
		return(ibr_regionprov.uf_check_region(as_data, as_message, this.object.pays[al_row]))		
END CHOOSE
return(1)
end event

event ue_itemvalidated;call super::ue_itemvalidated;CHOOSE CASE as_name
	CASE "pays"
		IF as_data <> "BE" THEN
			this.uf_setdefaultvalue(al_row, "region", "0")
		END IF
END CHOOSE
end event

type p_1 from uo_picture within w_regionprov
boolean visible = false
integer x = 2505
integer y = 1984
integer width = 73
integer height = 64
boolean bringtotop = true
string picturename = "..\bmp\currentrow.png"
end type

