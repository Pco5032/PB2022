//objectcomments Gestion du référentiel au moyen d'un treeview
forward
global type w_referentiel from w_ancestor_dataentry
end type
type tv_referentiel from uo_tv_referentiel within w_referentiel
end type
type dw_referentiel from uo_datawindow_singlerow within w_referentiel
end type
type sle_search from uo_sle within w_referentiel
end type
type st_1 from uo_statictext within w_referentiel
end type
type pb_search from uo_pictbutton within w_referentiel
end type
end forward

global type w_referentiel from w_ancestor_dataentry
string tag = "TEXT_00503"
integer width = 3749
integer height = 2260
string title = "Référentiels des codes prestations"
boolean maxbox = true
boolean resizable = true
tv_referentiel tv_referentiel
dw_referentiel dw_referentiel
sle_search sle_search
st_1 st_1
pb_search pb_search
end type
global w_referentiel w_referentiel

type variables
br_referentiel	ibr_referentiel
end variables

forward prototypes
public function integer wf_initnewrow (integer ai_idpere)
public function integer wf_deleteitem ()
public function integer wf_additem ()
public function integer wf_insertitem ()
end prototypes

public function integer wf_initnewrow (integer ai_idpere);// Créer un nouvel idem dans le DW.
// return le ID de l'item créé si OK
// return(-1) si erreur
long		ll_row
integer	li_maxID, li_newID
string	ls_message

// On prend le prochain IDPREST libre, mais s'il est >= 990 alors on 
// recherche le 1er ID libre > 50 dans la table REFERENTIEL.
select max(idprest) + 1 into :li_maxID from referentiel using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	populateError(20000,"")
	gu_message.uf_unexp("Erreur SELECT from referentiel (I)")
	return(-1)
END IF

IF isNull(li_maxID) THEN 
	li_newID = 1
ELSEIF li_maxID < 990 THEN
	li_newID = li_maxID
ELSE
	select min(idprest) + 1 into :li_newID from
		(select idprest, lead(idprest) over (order by idprest) next_idprest from referentiel where idprest > 50)
	where idprest <> next_idprest-1 using ESQLCA;
	IF f_check_sql(ESQLCA) <> 0 THEN
		populateError(20000,"")
		gu_message.uf_unexp("Erreur SELECT from referentiel (II)")
		return(-1)
	END IF
END IF

// check de IDPREST via les BR
IF ibr_referentiel.uf_check_idprest(string(li_newID), ls_message) = -1 THEN
	gu_message.uf_error(ls_message)
	return(-1)
END IF

// Créer, initialiser et enregistrer un nouvel item
dw_referentiel.reset()
ll_row = dw_referentiel.insertrow(0)
dw_referentiel.object.idprest[ll_row] = li_newID
dw_referentiel.object.idpere[ll_row] = ai_idpere
dw_referentiel.object.codef[ll_row] = string(li_newID)
dw_referentiel.object.coded[ll_row] = string(li_newID)
dw_referentiel.object.ordre[ll_row] = 999
dw_referentiel.object.intitulef[ll_row] = "Nouveau"
dw_referentiel.object.absence[ll_row] = "N"
dw_referentiel.object.garde[ll_row] = "N"
dw_referentiel.object.irregcompat[ll_row] = "O"
dw_referentiel.object.cumul[ll_row] = "O"
dw_referentiel.object.interim[ll_row] = "N"

// contrôle de validité de tous les champs et enregistrer
IF event ue_enregistrer() >= 0 THEN
	return(li_newID)
ELSE
	return(-1)
END IF

end function

public function integer wf_deleteitem ();// suppression de l'item en cours
// return(1) si item supprimé
// return(-1) si erreur ou abandon
integer	li_currentID
long		ll_currentHandle, ll_count
string	ls_message
treeviewitem ltvi_item

ll_currentHandle = tv_referentiel.FindItem(CurrentTreeItem!, 0)
tv_referentiel.GetItem(ll_currentHandle, ltvi_item)
li_currentID = ltvi_item.data

// vérifier s'il est possible de supprimer ce code
IF ibr_referentiel.uf_check_beforedelete(li_currentID, ls_message) = -1 THEN
	gu_message.uf_error(ls_message)
	return(-1)
END IF

// confirmation ?
IF gu_message.uf_query("Confirmez-vous la suppression de cet item (pas d'annulation possible) ?", YesNo!, 2) = 2 THEN
	return(-1)
END IF

// suppression dans la DB
delete referentiel where idprest=:li_currentID using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	populateError(20000, "")
	gu_message.uf_unexp("ERREUR delete from REFERENTIEL")
	rollback using ESQLCA;
	return(-1)
END IF

// supprimer dans le treeview
tv_referentiel.deleteitem(ll_currentHandle)

// commit si OK
commit using ESQLCA;

tv_referentiel.setFocus()

return(1)
end function

public function integer wf_additem ();// ajouter un item dans le même niveau que l'item en cours
// return(-1) si erreur
// return n° nouvel ID si OK
integer	li_niveau, li_newID, li_currentID, li_currentIDPere
long		ll_currentHandle, ll_ParentHandle, ll_newHandle
treeviewitem ltvi_item

// retrouver le handle de l'item en cours, ce qui permet de récupérer son ID et level
ll_currentHandle = tv_referentiel.FindItem(CurrentTreeItem!, 0)
tv_referentiel.GetItem(ll_currentHandle, ltvi_item)
li_niveau = ltvi_item.level
li_currentID = ltvi_item.data
IF li_niveau = 1 THEN 
	ddlb_message.reset()
	wf_message("Impossible d'ajouter un item à ce niveau")
	return(-1)
END IF

// récupérer le handle de l'item père, et ensuite son ID
ll_ParentHandle = tv_referentiel.FindItem(ParentTreeItem!, ll_currentHandle)
tv_referentiel.GetItem(ll_ParentHandle, ltvi_item)
li_currentIDPere = ltvi_item.data

// créer une row dans la DB et récupérer l'ID généré
li_newID = wf_initnewrow(li_currentIDPere)

// créer un item dans le treeview
ll_newHandle = tv_referentiel.uf_InsertItem(li_niveau, li_newID, "Nouveau", ll_ParentHandle, FALSE)

// sélectionner l'item créé
IF ll_newHandle > 0 THEN 
	tv_referentiel.SelectItem(ll_newHandle)
END IF

tv_referentiel.setFocus()

return(li_newID)
end function

public function integer wf_insertitem ();// ajouter un item sous le niveau de l'item en cours en cours
// return(-1) si erreur
// return n° nouvel ID si OK
integer	li_niveau, li_newID, li_currentID
long		ll_currentHandle, ll_newHandle, ll_ParentHandle
treeviewitem ltvi_item

// retrouver le handle de l'item en cours, ce qui permet de récupérer son ID et level
ll_currentHandle = tv_referentiel.FindItem(CurrentTreeItem!, 0)
tv_referentiel.GetItem(ll_currentHandle, ltvi_item)
li_niveau = ltvi_item.level
li_currentID = ltvi_item.data
IF li_niveau = 4 THEN 
	ddlb_message.reset()
	wf_message("Impossible d'ajouter un niveau supplémentaire")
	return(-1)
END IF

// créer une row dans la DB et récupérer l'ID généré
li_newID = wf_initnewrow(li_currentID)

// l'item en cours a maintenant des fils puisqu'on vient d'en ajouter un
ltvi_item.children = TRUE
tv_referentiel.SetItem(ll_currentHandle, ltvi_item)

// Si l'item en cours n'est pas encore déployé, l'ouvrir (ce qui chargera aussi le nouvel item)
// et retrouver son handle sur base de l'ID
IF NOT ltvi_item.ExpandedOnce THEN
	tv_referentiel.expandItem(ll_currentHandle)
	ll_newHandle = tv_referentiel.uf_findid(ll_currentHandle, li_newID)
ELSE
	ll_newHandle = tv_referentiel.uf_InsertItem(li_niveau + 1, li_newID, "Nouveau", ll_currentHandle, FALSE)
END IF

// sélectionner l'item créé
IF ll_newHandle > 0 THEN 
	tv_referentiel.SelectItem(ll_newHandle)
END IF

tv_referentiel.setFocus()
return(li_newID)
end function

event ue_open;call super::ue_open;ibr_referentiel = CREATE br_referentiel

// icônes visibles dans le menu
wf_SetItemsToShow({"m_ajouter","m_inserer", "m_nullify"})

// initialiser liste des DW modifiables
wf_SetDWList({dw_referentiel})

IF NOT wf_canupdate() THEN
	dw_referentiel.enabled = FALSE
END IF
end event

event resize;call super::resize;tv_referentiel.width = (newwidth - dw_referentiel.width)
tv_referentiel.height = newheight - tv_referentiel.y - 100
dw_referentiel.x = tv_referentiel.x + tv_referentiel.width
dw_referentiel.height = tv_referentiel.height
end event

on w_referentiel.create
int iCurrent
call super::create
this.tv_referentiel=create tv_referentiel
this.dw_referentiel=create dw_referentiel
this.sle_search=create sle_search
this.st_1=create st_1
this.pb_search=create pb_search
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.tv_referentiel
this.Control[iCurrent+2]=this.dw_referentiel
this.Control[iCurrent+3]=this.sle_search
this.Control[iCurrent+4]=this.st_1
this.Control[iCurrent+5]=this.pb_search
end on

on w_referentiel.destroy
call super::destroy
destroy(this.tv_referentiel)
destroy(this.dw_referentiel)
destroy(this.sle_search)
destroy(this.st_1)
destroy(this.pb_search)
end on

event ue_init_win;call super::ue_init_win;// la fenêtre contient tout de suite des données actives (le retrieve est déjà fait)
IF wf_canupdate() THEN
	wf_actif(TRUE)
END IF
end event

event ue_init_menu;call super::ue_init_menu;IF wf_canupdate() THEN
	f_menuaction({"m_enregistrer", "m_ajouter", "m_inserer", "m_supprimer", "m_fermer", "m_nullify"})
ELSE
	f_menuaction({"m_fermer"})
END IF

end event

event ue_enregistrer;call super::ue_enregistrer;long	ll_tvHandle

// contrôle de validité de tous les champs
IF dw_referentiel.event ue_checkall() < 0 THEN
	dw_referentiel.SetFocus()
	return(-1)
END IF

IF dw_referentiel.event ue_update() = 1 THEN
	wf_message("Référentiel enregistré avec succès")
	// retrouver le handle de l'item en cours et le rafraîchir
	ll_tvHandle = tv_referentiel.finditem(CurrentTreeItem!, 0)
	tv_referentiel.uf_refresh_item(ll_tvHandle)
	return(1)
ELSE
	populateerror(20000, "")
	gu_message.uf_unexp("REFERENTIEL : Erreur lors de la mise à jour de la base de données")
	return(-1)
END IF
end event

event ue_supprimer;call super::ue_supprimer;// supprimer l'item en cours
wf_deleteItem()

end event

event ue_ajouter;call super::ue_ajouter;wf_addItem()
end event

event ue_inserer;call super::ue_inserer;wf_insertItem()
end event

event ue_close;call super::ue_close;DESTROY ibr_referentiel
end event

event ue_nullify;call super::ue_nullify;// permet d'annuler l'unité
CHOOSE CASE wf_GetActivecontrolname()
	CASE "dw_referentiel"
		IF dw_referentiel.getcolumnname() = "unite" THEN
			dw_referentiel.event ue_nullify()
		END IF
END CHOOSE
end event

type ddlb_message from w_ancestor_dataentry`ddlb_message within w_referentiel
integer x = 18
integer y = 2000
end type

type tv_referentiel from uo_tv_referentiel within w_referentiel
integer y = 128
integer width = 1682
integer height = 1856
integer taborder = 10
boolean bringtotop = true
end type

event selectionchanged;call super::selectionchanged;integer	li_idprest
TreeViewItem	ltvi_ParentItem

this.GetItem(newHandle, ltvi_parentitem)
li_idprest = integer(ltvi_parentitem.data)
IF li_idprest > 0 THEN
	dw_referentiel.retrieve(li_idprest)
ELSE
	dw_referentiel.reset()
END IF
end event

event selectionchanging;call super::selectionchanging;// demander s'il faut enregistrer quand on change d'item
// return 0 Allow the selection to change
// return 1 Prevent the selection from changing
IF wf_canupdate() THEN
	IF dw_referentiel.accepttext() = -1 THEN
		return(1)
	ELSE
		CHOOSE CASE gu_dwservices.uf_confirm_cancel(idw_dwlist)
			CASE 1
				IF parent.event ue_enregistrer() >= 0 THEN
					return(0)
				ELSE
					return(1)
				END IF
			CASE 2
				wf_message(f_translate_getlabel("TEXT_00778", "Modifications abandonnées"))
				return(0)
			CASE 3
				return(1)
		END CHOOSE
	END IF
ELSE
	return(0)
END IF
end event

type dw_referentiel from uo_datawindow_singlerow within w_referentiel
integer x = 2066
integer y = 128
integer width = 1426
integer height = 1600
integer taborder = 20
boolean bringtotop = true
string dataobject = "d_referentiel"
boolean border = true
end type

event ue_checkitem;call super::ue_checkitem;long	ll_row

CHOOSE CASE as_item
	CASE "codef"
		return(ibr_referentiel.uf_check_codef(as_data, as_message))
		
	CASE "coded"
		return(ibr_referentiel.uf_check_coded(as_data, as_message))

	CASE "intitulef"
		return(ibr_referentiel.uf_check_intitulef(as_data, as_message))

	CASE "intituled"
		return(ibr_referentiel.uf_check_intituled(as_data, as_message))

	CASE "unite"
		return(ibr_referentiel.uf_check_unite(as_data, as_message))

	CASE "duree"
		return(ibr_referentiel.uf_check_duree(as_data, as_message))
		
	CASE "absence"
		return(ibr_referentiel.uf_check_absence(as_data, as_message))
		
	CASE "garde"
		return(ibr_referentiel.uf_check_garde(as_data, as_message))
		
	CASE "irregcompat"
		return(ibr_referentiel.uf_check_irregcompat(as_data, as_message))
		
	CASE "cumul"
		return(ibr_referentiel.uf_check_cumul(as_data, as_message))
		
	CASE "interim"
		return(ibr_referentiel.uf_check_interim(as_data, as_message))
END CHOOSE
return(1)
end event

type sle_search from uo_sle within w_referentiel
integer x = 2066
integer y = 16
integer width = 786
integer height = 96
boolean bringtotop = true
end type

type st_1 from uo_statictext within w_referentiel
string tag = "TEXT_00510"
integer x = 18
integer y = 32
integer width = 2048
boolean bringtotop = true
string text = "Rechercher une prestation (recherche insensible aux accents et à la casse) :"
end type

type pb_search from uo_pictbutton within w_referentiel
integer x = 2871
integer y = 16
integer width = 110
integer height = 96
boolean bringtotop = true
string text = ""
boolean default = true
string picturename = "..\bmp\search.bmp"
end type

event clicked;call super::clicked;// rechercher un item avec un intitulé contenant la chaîne de recherche saisie
treeviewitem ltvi_item
long		ll_handle
string	ls_label, ls_search
boolean	lb_found

// supprime les caractères accentués et convertit en MAJ
ls_search = gu_stringservices.uf_removeaccent(sle_search.text, "U")
IF f_isEmptyString(ls_search) THEN
	gu_message.uf_info("Veuillez saisir un critère de recherche")
	return
END IF
ll_handle = tv_referentiel.FindItem(RootTreeItem!, 0)
tv_referentiel.ExpandAll(ll_handle)

ll_handle = tv_referentiel.FindItem(CurrentTreeItem!, 0)
ll_handle = tv_referentiel.FindItem(NextVisibleTreeItem!, ll_handle)
do until ll_handle = -1 OR lb_found
	tv_referentiel.GetItem(ll_handle, ltvi_item)
	ls_label = gu_stringservices.uf_removeaccent(ltvi_item.label, "U")
	IF pos(ls_label, ls_search) > 0 THEN 
		tv_referentiel.selectItem(ll_handle)
		tv_referentiel.setFocus()
		lb_found = TRUE
	END IF
	ll_handle = tv_referentiel.FindItem(NextVisibleTreeItem!, ll_handle)
loop

IF NOT lb_found THEN
	gu_message.uf_info("Fin de la recherche")
END IF

end event

