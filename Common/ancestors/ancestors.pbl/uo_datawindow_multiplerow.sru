//objectcomments Ancêtre pour les DW control de modification de données plusieurs records à la fois
forward
global type uo_datawindow_multiplerow from uo_ancestor_dw
end type
end forward

global type uo_datawindow_multiplerow from uo_ancestor_dw
integer width = 494
integer height = 360
event type long ue_addrow ( )
event type integer ue_delete ( )
event type integer ue_update ( )
event type long ue_insertrow ( )
event ue_rowdeleted ( long al_row,  long al_rowid )
end type
global uo_datawindow_multiplerow uo_datawindow_multiplerow

type variables
PRIVATE boolean	ib_extendedselect, ib_sort, ib_autoselectrow, ib_createwhenlastdeleted
PRIVATE long		il_lastclickedrow
end variables

forward prototypes
public subroutine uf_extendedselect (boolean ab_extended)
public subroutine uf_shiftselect (long al_rowclicked)
public function boolean uf_extendedselect ()
public subroutine uf_sort (boolean ab_sort)
public subroutine uf_createwhenlastdeleted (boolean ab_create)
public function boolean uf_createwhenlastdeleted ()
public subroutine uf_autoselectrow (boolean ab_select)
public function boolean uf_sort ()
public function boolean uf_autoselectrow ()
end prototypes

event type long ue_addrow();long	ll_row

// bloquer la synchro via rowfocuschanged
uf_inserting(TRUE)
ll_row = this.InsertRow(0)
IF ll_row = -1 THEN
	uf_inserting(FALSE)
	gu_message.uf_error("Erreur lors de l'ajout d'un enregistrement ")
	return(-1)
ELSE
// sélectionner le nouveau record + placer le curseur sur la 1ère colonne éditable
	this.ScrollToRow(ll_row)
	this.SetColumn(gu_dwservices.uf_getNextUpdateableCol(this,0))
	// déclencher la synchro
	this.event ue_synchro(ll_row)
	uf_inserting(FALSE)
	return(ll_row)
END IF

end event

event type integer ue_delete();/* Supprimer le record en cours.
	Si le dernier record est supprimé, on en crée un nouveau.
	Déclenche l'event ue_rowdeleted(row) si "row" a bien été supprimée du DW.
	return(0) : pas de suppression (n° de row non valide)
	return(1) : suppression OK et ce n'était pas le dernier record
	return(2) : suppression du dernier record OK et création d'un nouveau record OK
	return(3) : suppression du dernier record OK et pas de création d'un nouveau record car non souhaité
	return(-1) : erreur de suppression
	return(-2) : suppression du dernier record OK mais création d'un nouveau record a échoué */
long	ll_row, ll_rowID, ll_newCurrentRow

ll_row = this.GetRow()
ll_rowID = this.GetRowIdFromRow(ll_row)
IF ll_row <= 0 OR ll_row > this.Rowcount() THEN
	return(0)
END IF

uf_deleting(TRUE)
IF this.DeleteRow(ll_row) = -1 THEN
	uf_deleting(FALSE)
	gu_message.uf_error("Erreur delete", "Erreur lors de la suppression, enregistrement " + string(this.GetRow()))
	return(-1)
ELSE
	uf_deleting(FALSE)
	this.event ue_rowdeleted(ll_row, ll_rowID)
	this.event post ue_dwmessage("Suppression OK")
// si il n'y a plus de record, on en crée un vide si demandé
	IF this.RowCount() = 0 THEN
		IF uf_CreateWhenLastDeleted() THEN
			IF this.event ue_addrow() = -1 THEN
				ll_newCurrentRow = this.GetRow()
				this.event ue_synchro(ll_newCurrentRow)
				return(-2)
			ELSE
				ll_newCurrentRow = this.GetRow()
//				this.event ue_synchro(ll_newCurrentRow) 	à priori pas nécessaire car fait dans ue_Addrow
				return(2)
			END IF
		ELSE
			ll_newCurrentRow = this.GetRow()
			this.event ue_synchro(ll_newCurrentRow)
			return(3)
		END IF
	ELSE
		ll_newCurrentRow = this.GetRow()
		this.event ue_synchro(ll_newCurrentRow)
		return(1)
	END IF
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

event type long ue_insertrow();long	ll_row

// bloquer la synchro via rowfocuschanged
uf_inserting(TRUE)
// ajouter un record vide avant le record en cours
ll_row = this.InsertRow(this.getrow())
IF ll_row = -1 THEN
	uf_inserting(FALSE)
	gu_message.uf_error("Erreur lors de l'insertion d'un enregistrement ")
	return(-1)
ELSE
// sélectionner le nouveau record + placer le curseur sur la 1ère colonne éditable
	this.ScrollToRow(ll_row)
	this.SetColumn(gu_dwservices.uf_getNextUpdateableCol(this,0))
	// déclencher la synchro
	this.event ue_synchro(ll_row)
	uf_inserting(FALSE)
	return(ll_row)
END IF

end event

event ue_rowdeleted(long al_row, long al_rowid);// event déclenché par ue_delete si un row a bien été supprimé du DW
// al_row = N° original de la row qui a été supprimée
//          attention : cette row n'existe donc plus dans le buffer primary! du DW, et ne correspond pas
//                      au n° de row dans le buffer delete.
// al_rowID = unique row ID de la row supprimée
end event

public subroutine uf_extendedselect (boolean ab_extended);ib_extendedselect = ab_extended
end subroutine

public subroutine uf_shiftselect (long al_rowclicked);//**********************************************************************
//		This function will verify that there is a prior selected row and
//		then highlight all Rows between the two.  If there is no previously
//		Selected row then it will highlight only the row clicked.  
//		This function will not unhighlight any other rows to allow for a 
//		mix of shift and Control key inter mingling.  This will have to be
//		aware of the relation between the rows to know which way to 
//		highlight.
//
//		The arguement passed will be the currently clicked row.  This 
//		function will use the existing DataWindow and the instance variable
//		iLastClickedRow to perform it's scrolling.
//**********************************************************************
integer	li_Idx

// file manager functionality ... turn off all rows then select new range
This.setredraw(false)
// This.selectrow(0,false)

// no previously selected row : just select clicked row
If il_lastclickedrow = 0 then
	This.SelectRow(al_rowclicked,TRUE)
	This.setredraw(true)
	return
end if

// selection moving backward
if il_lastclickedrow > al_rowclicked then
	For li_Idx = il_lastclickedrow to al_rowclicked STEP -1
		This.selectrow(li_Idx,TRUE)	
	end for	
else
// selection moving forward
	For li_Idx = il_lastclickedrow to al_rowclicked
		This.selectrow(li_Idx,TRUE)	
	next	
end if

This.setredraw(true)

end subroutine

public function boolean uf_extendedselect ();return(ib_extendedselect)
end function

public subroutine uf_sort (boolean ab_sort);// spécifie si les données doivent être triées quand on clique sur l'entête de la colonne ou pas
ib_sort = ab_sort
end subroutine

public subroutine uf_createwhenlastdeleted (boolean ab_create);ib_createwhenlastdeleted = ab_create
end subroutine

public function boolean uf_createwhenlastdeleted ();return(ib_createwhenlastdeleted)
end function

public subroutine uf_autoselectrow (boolean ab_select);ib_autoselectrow = ab_select
end subroutine

public function boolean uf_sort ();// renvoie la valeur de ib_sort
return(ib_sort)
end function

public function boolean uf_autoselectrow ();// renvoie la valeur de ib_autoselectrow
return(ib_autoselectrow)
end function

on uo_datawindow_multiplerow.create
call super::create
end on

on uo_datawindow_multiplerow.destroy
call super::destroy
end on

event rowfocuschanged;call super::rowfocuschanged;IF uf_autoselectrow() AND NOT uf_extendedselect() THEN
	IF getfocus() = this THEN
		this.SelectRow(0,false)
		this.SelectRow(currentrow,true)
	END IF
END IF

end event

event getfocus;call super::getfocus;IF ib_autoselectrow AND NOT ib_extendedselect THEN
	this.SelectRow(0,false)
	this.SelectRow(this.getrow(),true)
END IF
end event

event losefocus;call super::losefocus;IF ib_autoselectrow AND NOT ib_extendedselect THEN
	this.SelectRow(0,false)
END IF
end event

event constructor;call super::constructor;uf_sort(FALSE)
uf_autoselectrow(TRUE)
uf_extendedselect(FALSE)
uf_setmultiplerow(TRUE)
uf_CreateWhenLastDeleted(TRUE)
end event

event clicked;call super::clicked;string	ls_name, ls_KeyDownType, ls_type

// tri sur la colonne cliquée si le tri est autorisé
IF ib_sort THEN
	IF dwo.Type = "text" THEN
		ls_name = dwo.Name
		ls_name = LeftA(ls_name, LenA(ls_name) - 2)
		// si une colonne correspond à la zone de texte cliquée, on trie sur cette colonne
		ls_type = this.Describe(trim(ls_name) + ".type")
		IF ls_type = "column" OR ls_type = "compute" THEN
//		IF IsNumber(this.Describe(trim(ls_name) + ".ID")) THEN
			IF gb_sort_asc THEN
				gu_dwservices.uf_sort(this,ls_name + " A")
				IF NOT ib_autoselectrow THEN this.selectrow(row, FALSE)
			ELSE
				gu_dwservices.uf_sort(this,ls_name + " D")
				IF NOT ib_autoselectrow THEN this.selectrow(row, FALSE)
			END IF
		END IF
	END IF
END IF

// gestion de la sélection étendue si elle est permise, sinon juste sélectionner le record
IF NOT ib_extendedselect THEN 
	this.post ScrollToRow(row) // !!! post rajouté le 26 mai 2004
	return
END IF

//////////////////////////////////////////////////////////////////////////////////////////////////
//		First make sure the user clicked on a Row.  Clicking on WhiteSpace
//		or in the header will return a clicked row value of 0.  If that 
//		occurs, just leave this event.
//////////////////////////////////////////////////////////////////////////////////////////////////
If row = 0 then Return

//case of select multiple rows range using the shift key
If Keydown(KeyShift!) then
	uf_shiftselect(row)
	il_LastClickedRow = row
ElseIf Keydown(KeyControl!) then
	// (CTRL KEY) keep other rows highlighted and highlight a new row or
	// turn off the current row highlight
	IF this.IsSelected(row) THEN
		il_LastClickedRow = 0
		this.SelectRow(row,FALSE)
	ELSE
		il_LastClickedRow = row
		this.SelectRow(row,TRUE)
	END IF
Else
	il_LastClickedRow = row
	this.SelectRow(0,FALSE)
	this.SelectRow(row,TRUE)
End If

end event

