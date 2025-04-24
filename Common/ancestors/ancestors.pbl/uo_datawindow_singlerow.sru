//objectcomments Ancêtre pour les DW control de modification de données 1 record à la fois
forward
global type uo_datawindow_singlerow from uo_ancestor_dw
end type
end forward

global type uo_datawindow_singlerow from uo_ancestor_dw
event type integer ue_addrow ( )
event type integer ue_delete ( )
event type integer ue_update ( )
end type
global uo_datawindow_singlerow uo_datawindow_singlerow

type variables

end variables

event ue_addrow;long	ll_row

// ajouter un record vide
ll_row = this.InsertRow(0)
IF ll_row = -1 THEN
	gu_message.uf_error("Erreur lors de l'ajout d'un enregistrement")
	return(-1)
ELSE
	IF ll_row > 1 THEN
		this.DeleteRow(ll_row)
		gu_message.uf_error("Impossible de créer plus d'un enregistrement dans ce contexte")
		return(-1)
	END IF
	// et le sélectionner + placer le curseur sur la 1ère colonne éditable
	this.SetColumn(gu_dwservices.uf_getNextUpdateableCol(this,0))
	this.ScrollToRow(1)
	return(1)
END IF

end event

event ue_delete;IF this.DeleteRow(0) = 1 THEN
	// deleterow a fonctionné, faire l'update
	IF this.Update() = 1 THEN
		// l'update a fonctionné
		commit using SQLCA;
		this.event post ue_dwmessage("Suppression OK")
		return(1)
	ELSE
		// l'update a échoué : rollback puis on doit undeleter la row
		rollback using SQLCA;
		This.RowsMove(1, 1, Delete!, This, 1, Primary!)
		this.SetFocus()
		return(-1)
	END IF
ELSE
	// deleterow n'a pas fonctionné
	gu_message.uf_error("Erreur DELETE", "Erreur lors de la suppression de l'enregistrement " + string(this.GetRow()))
	this.SetFocus()
	return(-1)
END IF

end event

event ue_update;IF this.update() <> 1 THEN
	rollback;
	this.SetFocus()
	return(-1)
ELSE
	commit;
	this.event post ue_dwmessage("Enregistrement OK")
	return(1)
END IF

end event

on uo_datawindow_singlerow.create
end on

on uo_datawindow_singlerow.destroy
end on

event constructor;call super::constructor;uf_setmultiplerow(FALSE)
end event

event we_vscroll;call super::we_vscroll;// return(1) ici empeche de scroller (par exemple avec la roulette de souris) dans un DW single row
return(1)
end event

