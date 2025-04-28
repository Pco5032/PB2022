forward
global type uo_tv_referentiel from treeview
end type
end forward

global type uo_tv_referentiel from treeview
integer width = 1426
integer height = 1480
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
borderstyle borderstyle = stylelowered!
boolean tooltips = false
string picturename[] = {"..\bmp\folderclosed.bmp","..\bmp\folderopened.bmp","..\bmp\activite.bmp"}
long picturemaskcolor = 536870912
long statepicturemaskcolor = 536870912
end type
global uo_tv_referentiel uo_tv_referentiel

type variables
long	il_rootHandle, il_currenthandle
treeviewitem	itvi_currentitem
end variables

forward prototypes
public function long uf_insertitem (integer ai_niveau, any a_data, string as_label, long al_handle, boolean ab_children)
public function long uf_findid (long al_starthandle, integer ai_searchid)
public subroutine uf_deleteallchildrens (long al_starthandle)
public function integer uf_refresh_item (long al_handle)
public function integer uf_populate (long al_handle)
end prototypes

public function long uf_insertitem (integer ai_niveau, any a_data, string as_label, long al_handle, boolean ab_children);TreeViewItem	ltvi_Item

// définir les propriétés de l'item
ltvi_Item.expanded = FALSE
ltvi_Item.data = a_data
ltvi_Item.Label = as_label
// NB : root = niveau 1
IF ai_niveau = 4 THEN
	ltvi_Item.PictureIndex = 3
	ltvi_Item.SelectedPictureIndex = 3
ELSE
	ltvi_Item.PictureIndex = 1
	ltvi_Item.SelectedPictureIndex = 2
END IF
ltvi_Item.children = ab_children

// ajouter l'item
return(this.InsertItemLast(al_handle, ltvi_item))


end function

public function long uf_findid (long al_starthandle, integer ai_searchid);// recherche dans les fils de ai_starthandle le handle de l'item dont l'ID est passé en argument
long	ll_h1, ll_h2
TreeViewItem	ltvi_Item
integer	li_id

// first child under al_starthandle
ll_h1 = this.FindItem(ChildTreeItem!, al_starthandle)
DO UNTIL ll_h1 = -1
	IF this.GetItem(ll_h1, ltvi_Item) = -1 THEN
		return(-1)
	END IF

	// récupérer l'ID
	li_id = integer(ltvi_Item.data)
	IF li_id = ai_searchID THEN
		return(ll_h1)
	ELSE
		// next child
		ll_h1 = this.FindItem(NextTreeItem!, ll_h1)
	END IF
LOOP

// pas trouvé
return(-1)

end function

public subroutine uf_deleteallchildrens (long al_starthandle);// supprimer les items "fils" de l'item dont le handle est passé en argument
long	ll_h1, ll_h2

ll_h1 = this.FindItem(ChildTreeItem!, al_starthandle)
DO UNTIL ll_h1 = -1
	ll_h2 = this.FindItem(NextTreeItem!, ll_h1)
	this.DeleteItem(ll_h1)
	ll_h1 = ll_h2
LOOP

end subroutine

public function integer uf_refresh_item (long al_handle);// relit et réaffiche l'item dont le handle est passé en argument
uo_ds				lds_1
TreeViewItem	ltvi_Item
integer			li_idprest

IF al_handle < 0 THEN return(-1)

lds_1 = CREATE uo_ds
lds_1.dataobject = "ds_referentiel_tv_idprest"
lds_1.SetTransObject(SQLCA)

// récupérer l'item pointé par le handle
IF this.GetItem(al_handle, ltvi_Item) = -1 THEN
	return(-1)
END IF

// récupérer l'ID de cet item
li_idprest = integer(ltvi_Item.data)

// lire l'item et rafraichir l'intitulé dans le TV
IF lds_1.retrieve(li_idprest) <> 1 THEN
	return(-1)
ELSE
	ltvi_Item.label = lds_1.object.intitule[1]
	this.setitem(al_handle, ltvi_Item)
END IF

DESTROY lds_1


end function

public function integer uf_populate (long al_handle);// garnir le niveau sous le handle passé en argument
uo_ds				lds_1, lds_2
long				ll_nbrows, ll_row
TreeViewItem	ltvi_Item
string			ls_texte
integer			li_parent, li_idprest, li_level
boolean			lb_children

lds_1 = CREATE uo_ds
lds_1.dataobject = "ds_referentiel_tv_idpere"
lds_1.SetTransObject(SQLCA)

lds_2 = CREATE uo_ds
lds_2.dataobject = "ds_referentiel_tv_idpere"
lds_2.SetTransObject(SQLCA)

// récupérer l'item pointé par le handle
IF this.GetItem(al_handle, ltvi_Item) = -1 THEN
	return(-1)
END IF

// récupérer l'ID et le niveau de cet item
li_parent = integer(ltvi_Item.data)
li_level = integer(ltvi_Item.level)

// si ce niveau a déjà été déployé, supprimer pour rafraichir ensuite
IF ltvi_item.level > 1 AND ltvi_item.ExpandedOnce THEN
	uf_DeleteAllChildrens(al_handle)
END IF

// lire tous les items au niveau en dessous et les ajouter dans le treeview
ll_nbrows = lds_1.retrieve(li_parent)
IF ll_nbrows = 0 THEN
	ltvi_Item.children = FALSE
ELSE
	FOR ll_row = 1 TO ll_nbrows
		li_idprest = lds_1.object.idprest[ll_row]
		ls_texte = lds_1.object.intitule[ll_row]
		// voir si l'item a des fils
		IF lds_2.retrieve(li_idprest) > 0 THEN
			lb_children = TRUE
		ELSE
			lb_children = FALSE
		END IF
		uf_InsertItem(li_level + 1, li_idprest, ls_texte, al_handle, lb_children)
	NEXT
END IF

DESTROY lds_1
DESTROY lds_2

end function

on uo_tv_referentiel.create
end on

on uo_tv_referentiel.destroy
end on

event itemcollapsing;// empêcher de réduire le 1er niveau (root)
TreeViewItem	ltvi_item

this.GetItem(handle, ltvi_item)
IF ltvi_item.level = 1 THEN
	return(1)
END IF

end event

event itemexpanding;IF handle <> il_rootHandle THEN uf_populate(handle)
end event

event selectionchanged;il_currenthandle = newhandle
this.GetItem(newhandle, itvi_currentitem)
end event

event constructor;// garnir base et 1er niveau
long		ll_handle
string	ls_title

ls_title = f_translate_getlabel("TEXT_00509", "Référentiel")
ll_handle = uf_InsertItem(1, 0, ls_title, 0, TRUE)
il_rootHandle = ll_handle
uf_populate(ll_handle)

// base, d'office expanded
this.ExpandItem(ll_handle)

end event

event rightclicked;window	lw_parent
IF f_GetParentWindow(this, lw_parent) = 1 THEN
	IF lw_parent.windowtype <> Response! THEN f_PopupAction(lw_parent)
END IF
end event

