//objectcomments Ancêtre des DW control de visualisation de données en mode 'browse'
forward
global type uo_ancestor_dwbrowse from uo_dw
end type
end forward

global type uo_ancestor_dwbrowse from uo_dw
integer width = 183
integer height = 84
integer taborder = 1
boolean livescroll = true
event ue_enterpressed pbm_dwnprocessenter
end type
global uo_ancestor_dwbrowse uo_ancestor_dwbrowse

type variables
PRIVATE boolean	ib_extendedselect, ib_autoselectrow, ib_sort
PRIVATE long		il_lastclickedrow

end variables

forward prototypes
public subroutine uf_shiftselect (long al_rowclicked)
public subroutine uf_extendedselect (boolean ab_extended)
public function boolean uf_extendedselect ()
public subroutine uf_changedataobject (string as_dataobject)
public subroutine uf_autoselectrow (boolean ab_select)
public subroutine uf_sort (boolean ab_sort)
public function boolean uf_autoselectrow ()
public function boolean uf_sort ()
end prototypes

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

public subroutine uf_extendedselect (boolean ab_extended);ib_extendedselect = ab_extended
end subroutine

public function boolean uf_extendedselect ();return(ib_extendedselect)
end function

public subroutine uf_changedataobject (string as_dataobject);// assigne un autre dataobject au DWControl lorsqu'il en utilisait déjà un
This.Dataobject = as_dataobject
This.SetTransObject(SQLCA)
end subroutine

public subroutine uf_autoselectrow (boolean ab_select);// initialise ib_autoselectrow à la valeur voulue
ib_autoselectrow = ab_select
end subroutine

public subroutine uf_sort (boolean ab_sort);// spécifie si les données doivent être triées quand on clique sur l'entête de la colonne ou pas
ib_sort = ab_sort
end subroutine

public function boolean uf_autoselectrow ();// renvoie la valeur de ib_autoselectrow
return(ib_autoselectrow)
end function

public function boolean uf_sort ();// renvoie la valeur de ib_sort
return(ib_sort)
end function

on uo_ancestor_dwbrowse.create
call super::create
end on

event constructor;call super::constructor;This.SetTransObject(SQLCA)
uf_sort(TRUE)
uf_autoselectrow(TRUE)
uf_extendedselect(FALSE)
end event

event losefocus;call super::losefocus;IF ib_autoselectrow AND NOT ib_extendedselect THEN
	this.SelectRow(0,false)
END IF
end event

event rowfocuschanged;call super::rowfocuschanged;IF uf_autoselectrow() AND NOT uf_extendedselect() THEN
	IF getfocus() = this THEN
		this.SelectRow(0,false)
		this.SelectRow(currentrow,true)
	END IF
END IF

end event

on uo_ancestor_dwbrowse.destroy
call super::destroy
end on

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

event getfocus;call super::getfocus;IF ib_autoselectrow AND NOT ib_extendedselect THEN
	this.SelectRow(0,false)
	this.SelectRow(this.getrow(),true)
END IF
end event

