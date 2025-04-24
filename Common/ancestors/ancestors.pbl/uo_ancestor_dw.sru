//objectcomments Ancêtre pour les types de DW control permettant la modification de données - pas utilisé directement mais un de ses descendants
forward
global type uo_ancestor_dw from uo_dw
end type
type str_item from structure within uo_ancestor_dw
end type
type str_rowkey from structure within uo_ancestor_dw
end type
end forward

type str_item from structure
	string		s_name
	integer		i_tabseq
end type

type str_rowkey from structure
	boolean		b_itemisvalid[]
end type

global type uo_ancestor_dw from uo_dw
integer width = 183
integer height = 84
integer taborder = 1
boolean livescroll = true
event type integer ue_checkrow ( long al_row )
event type integer ue_checkitem ( long al_row,  string as_item,  string as_data,  ref string as_message )
event ue_itemvalidated ( long al_row,  string as_name,  string as_data )
event ue_postitemvalidated ( long al_row,  string as_name )
event ue_dwmessage ( string as_dwmessage )
event type integer ue_checkall ( )
event ue_leavekey ( long al_row,  string as_keyitem )
event ue_leavelastitem ( long al_row,  string as_itemname )
event ue_nullify ( )
end type
global uo_ancestor_dw uo_ancestor_dw

type variables
PRIVATE boolean	ib_dwspecificerror, ib_RecordIsNew, ib_checkeveryrow=TRUE, ib_displaymessage, ib_multiplerow
PRIVATE string	is_errormessage
PRIVATE string	 is_udata[], is_keys[], is_ItemsToValidate[]
str_itemprop	istr_itemprop[]
PRIVATE	str_rowkey	istr_rowkey
end variables

forward prototypes
public subroutine uf_disablekeys ()
public function boolean uf_isrecordnew ()
public subroutine uf_newrecord (boolean ab_new)
public subroutine uf_checkallrow (boolean ab_check)
public subroutine uf_excludeitemsfromcheck (string as_items[])
public function integer uf_checkkeyitems (integer ai_itemnumber)
private subroutine uf_setvalidtofalse ()
private subroutine uf_setvalidtofalse (string as_item)
public subroutine uf_setmultiplerow (boolean ab_multiplerow)
public function integer uf_setdefaultvalue (long al_row, string as_itemname, any aa_value, boolean ab_checkitem)
public function integer uf_setdefaultvalue (long al_row, string as_itemname, any aa_value)
public function integer uf_setdefaultvalue (long al_row, string as_itemname, any aa_value, object ao_datatype, boolean ab_checkitem)
public subroutine uf_selecttext ()
public subroutine uf_changedataobject (string as_dataobject)
public function integer uf_setdefaultvalue (long al_row, string as_itemname, any aa_value, object ao_datatype)
public subroutine uf_disabledata ()
private subroutine uf_init ()
public subroutine uf_enabledata ()
public subroutine uf_enablekeys ()
public subroutine uf_enableitems (string as_items[])
public subroutine uf_enableitems (string as_item[], boolean ab_key)
public subroutine uf_disableitems (string as_item[])
public subroutine uf_additemstocheck (string as_items[])
public subroutine uf_additemstokey (string as_items[])
public subroutine uf_excludeitemsfromkey (string as_items[])
public subroutine uf_displaymessage (boolean ab_display)
public subroutine uf_setkeys (string as_keys[])
public subroutine uf_setudata (string as_udata[])
public subroutine uf_setitemstovalidate (string as_itemstovalidate[])
public function any uf_getudata ()
public function integer uf_setdefaultvalue (long al_row, string as_itemname, any aa_value, object ao_datatype, boolean ab_checkitem, ref string as_message)
public function integer uf_setdefaultvalue (long al_row, string as_itemname, any aa_value, object ao_datatype, ref string as_message)
public function integer uf_setdefaultvalue (long al_row, string as_itemname, any aa_value, boolean ab_checkitem, ref string as_message)
public function integer uf_setdefaultvalue (long al_row, string as_itemname, any aa_value, ref string as_message)
end prototypes

event type integer ue_checkrow(long al_row);string	ls_desc, ls_err, ls_data, ls_colname
long		ll_rownum
integer	li_col, li_nbItemsToValidate, li_colID, li_colnum, li_tabseq, &
			li_firsteditable, li_protected, li_st

// si le n° de record n'est pas spécifié, on prend celui en cours
IF al_row = 0 THEN
	al_row = This.GetRow()
END IF

// si le n° de record est incorrect, erreur
IF isnull(al_row) OR al_row <= 0 OR al_row > This.RowCount() THEN
	return(-1)
END IF

// valider l'item en cours
IF This.AcceptText() = -1 THEN
	return(-1)
END IF

// Vérifier qu'il n'existe pas de champs 'required' vides dans le record en cours
li_nbItemsToValidate = UpperBound(is_itemstovalidate)
li_colnum = 1
ll_rownum = al_row
this.FindRequired(PRIMARY!, ll_rownum, li_colnum, ls_colname, False)
// s'il y a des champs required vides mais dans un autre record, on ne le traite pas maintenant mais quand le tour de ce record viendra !
DO WHILE ll_rownum = al_row
	// si le champs required n'est pas dans la liste des champs updatable, on en tient pas compte
	FOR li_col = 1 to li_nbItemsToValidate
		IF f_IsEmptyString(is_itemstovalidate[li_col]) THEN CONTINUE
		IF ls_colname = is_itemstovalidate[li_col] THEN
			This.ScrolltoRow(al_row)
			this.SetColumn(li_colnum)
			this.SetFocus()
			gu_message.uf_error("Le champ " + ls_colname + " ne peut être vide")
			// on quitte la boucle et l'event dès qu'il y a 1 champ required vide
			return(-1)
		END IF
	NEXT
	li_colnum = li_colnum + 1
	this.FindRequired(PRIMARY!, ll_rownum, li_colnum, ls_colname, False)
LOOP

/* vérifier tous les items de la liste is_itemsToValidate sauf ceux exclus */
FOR li_col = 1 to li_nbItemsToValidate
	IF f_IsEmptyString(is_itemstovalidate[li_col]) THEN CONTINUE
	ls_desc = is_itemstovalidate[li_col] + ".TabSequence"
	li_tabseq = integer(This.Describe(ls_desc))
	ls_desc = is_itemstovalidate[li_col] + ".Protect"
	li_protected = integer(This.Describe(ls_desc))
//	IF li_tabseq > 0 THEN
		ls_desc = is_itemstovalidate[li_col] + ".ID"
		li_colID = integer(This.Describe(ls_desc))
		ls_data = string(This.object.data[al_row, li_colID])
		li_st = This.event ue_CheckItem(al_row, is_itemstovalidate[li_col], ls_data, ls_err)
		IF li_st = -1 OR li_st = -4 THEN
			This.ScrolltoRow(al_row)
			IF li_tabseq > 0 AND li_protected = 0 THEN
				This.SetColumn(is_itemstovalidate[li_col])
				IF li_st = -1 THEN
					gu_message.uf_error(ls_err)
				END IF
			ELSE
				li_firsteditable = gu_dwservices.uf_getnextupdateablecol(this, 0)
				This.SetColumn(li_firsteditable)
				IF li_st = -1 THEN
					gu_message.uf_error("Erreur dans une zone non modifiable", f_string(ls_err))
				END IF
			END IF
			This.Setfocus()
			return(-1)
		END IF
//	END IF
NEXT

// si on arrive ici c'est que tout est OK
return(1)

end event

event ue_checkitem;/* return(1) = valeur correcte
   return(-1) = valeur incorrecte, message d'erreur affiché, le focus doit rester sur le même item
	return(-2) = valeur incorrecte remplacée automatiquement par une valeur correcte (ou remise à sa valeur initiale),
					 le focus peut quitter l'item
	return(-3) = valeur incorrecte NON remplacée par valeur correcte, mais le focus peut quitter l'item 
	return(-4) = valeur incorrecte, pas de message d'erreur affiché, le focus doit rester sur le même item */
	
/* ATTENTION : éviter SETTEXT() ici car cet event est appelé non seulement par ITEMCHANGED mais aussi par UE_CHECKROW
   et dans ce cas, l'item ayant le focus est indéterminé */
return(1)
end event

event ue_itemvalidated;integer	li_keyitem, li_maxkeyitem

This.event post ue_postitemvalidated(al_row, as_name)

li_maxkeyitem = upperbound(is_keys)

// si l'item validé est un élément de la clé, mettre à TRUE l'indicateur signalant que l'item de clé en cours est validé
IF NOT ib_multiplerow THEN
	FOR li_keyitem = 1 TO li_maxkeyitem
		IF as_name = is_keys[li_keyitem] THEN
			istr_rowkey.b_itemisvalid[li_keyitem] = TRUE
			exit
		END IF
	NEXT
END IF

// si l'item validé est le dernier élément de la clé, déclencher event UE_LEAVEKEY
IF li_maxkeyitem > 0 THEN
	IF as_name = is_keys[li_maxkeyitem] THEN
		This.event ue_leavekey(al_row, as_name)
	END IF
END IF

// si l'item validé est le dernier élément des items modifiables, déclencher event UE_LEAVELASTITEM
IF upperbound(is_udata) > 0 THEN
	IF as_name = is_udata[upperbound(is_udata)] THEN
		This.event ue_leavelastitem(al_row, as_name)
	END IF
END IF

end event

event ue_postitemvalidated;// comme cet event est "posted", le record peut ne plus être disponible quand l'event est exécuté
IF This.RowCount() <=  0 THEN return
end event

event ue_checkall;// vérification de la validité de tous les records ou seulement de ceux modifiés, suivant état de ib_checkeveryrow
long	ll_nbrows, ll_row, ll_

// valider l'item en cours avant d'aller + loin
IF This.AcceptText() = -1 THEN
	return(this.getrow() * -1)
END IF

ll_nbrows = This.RowCount()
IF ib_CheckEveryRow THEN
	FOR ll_row = 1 TO ll_nbrows
		IF This.event ue_checkrow(ll_row) = -1 THEN
			return(ll_row * -1)
		END IF
	NEXT
END IF

IF NOT ib_CheckEveryRow THEN
	ll_row = This.GetNextModified(0, Primary!)
	DO WHILE ll_row <> 0
		IF This.event ue_checkrow(ll_row) = -1 THEN
			return(ll_row * -1)
		END IF
		ll_row = This.GetNextModified(ll_row, Primary!)
	LOOP
END IF

return(1)


end event

event ue_leavekey;/* ATTENTION : cet item étant 'triggered', le dernier élément de la clé n'est pas encore disponible par Getitem(), 
il faut utiliser gettext() */

// al_row = n° de row
// as_keyitem = nom de l'élément de clé qui a provoqué le déclenchement de cet event

end event

event ue_leavelastitem;/* ATTENTION : cet item étant 'triggered', le dernier élément de la liste n'est pas encore disponible par Getitem(), 
il faut utiliser gettext() */

// al_row = n° de row
// as_keyitem = nom de l'élément de clé qui a provoqué le déclenchement de cet event
end event

event ue_nullify();// Mettre à NULL la colonne en cours. 
// NB : Pour une item de type EDIT, on peut toujours utilise la propriété 'empty string is null', 
// 	  mais pour un EDITMASK une telle propriété n'existe pas.
long		ll_row
string	ls_colName, ls_colType

IF NOT IsValid(idwo_currentItem) THEN return
IF IsNull(idwo_currentItem) THEN return

IF idwo_currentItem.Type = "column" THEN
	ll_row = this.GetRow()
	IF ll_row <= 0 THEN return
	ls_colName = idwo_currentItem.name
	ls_colType = this.Describe(ls_colName + ".Coltype")
	CHOOSE CASE LeftA(ls_colType, 4)
		CASE "char"
			this.setItem(ll_row, ls_colName, gu_c.s_null)
		CASE "deci"
			this.setItem(ll_row, ls_colName, gu_c.d_null)
		CASE "date"
			this.setItem(ll_row, ls_colName, gu_c.date_null)
		CASE "numb"
			this.setItem(ll_row, ls_colName, gu_c.d_null)
		CASE ELSE
			gu_message.uf_error("Datatype " + ls_colType + " pas pris en charge. ColName=" + ls_colName)
	END CHOOSE
	
END IF
end event

public subroutine uf_disablekeys ();uf_DisableItems(is_keys[])
end subroutine

public function boolean uf_isrecordnew ();return(ib_recordisnew)
end function

public subroutine uf_newrecord (boolean ab_new);ib_recordisnew = ab_new
end subroutine

public subroutine uf_checkallrow (boolean ab_check);ib_checkeveryrow = ab_check
end subroutine

public subroutine uf_excludeitemsfromcheck (string as_items[]);// exclure de la liste des items à valider les items passés en paramètre. Ils ne seront donc pas vérifiés
// lors de ue_checkrow

long	ll_items1, ll_items2, ll_max1, ll_max2

ll_max1 = upperbound(as_items)
ll_max2 = upperbound(is_itemstovalidate)

FOR ll_items1 = 1 TO ll_max1
	FOR ll_items2 = 1 TO ll_max2
		IF as_items[ll_items1] = is_itemstovalidate[ll_items2] THEN
			SetNull(is_itemstovalidate[ll_items2])
			exit
		END IF
	NEXT
NEXT

end subroutine

public function integer uf_checkkeyitems (integer ai_itemnumber);// verifier que les éléments de clé jusque celui dont le n° est passé en paramètre sont valides
// return -1 si un élément n'est pas valide, 1 s'ils sont tous valides
integer	li_keyitem

IF upperbound(istr_rowkey.b_itemisvalid) < ai_itemnumber THEN return(-1)

FOR li_keyitem = 1 TO ai_itemnumber
	IF istr_rowkey.b_itemisvalid[li_keyitem] = FALSE THEN return(-1)
NEXT

return(1)
end function

private subroutine uf_setvalidtofalse ();// on réinitialise à FALSE l'indicateur de validité de tous les composants de la clé
integer	li_keyitem

FOR li_keyitem = 1 TO upperbound(is_keys)
	istr_rowkey.b_itemisvalid[li_keyitem] = FALSE
NEXT


end subroutine

private subroutine uf_setvalidtofalse (string as_item);// on réinitialise à FALSE l'indicateur de validité de l'élément de clé as_item
integer	li_keyitem

FOR li_keyitem = 1 TO upperbound(is_keys)
	IF as_item = is_keys[li_keyitem] THEN 
		istr_rowkey.b_itemisvalid[li_keyitem] = FALSE
		exit
	END IF
NEXT



end subroutine

public subroutine uf_setmultiplerow (boolean ab_multiplerow);ib_multiplerow = ab_multiplerow
end subroutine

public function integer uf_setdefaultvalue (long al_row, string as_itemname, any aa_value, boolean ab_checkitem);// assigner une valeur par défaut en déclenchant la séquence de validation (checkitem - itemvalidated) ou
// uniquement itemvalidated.
// Il semble que le setitem ne fonctionne pas avec un argument de type ANY si la valeur est nulle.
// Il faut dans ce cas utiliser la variante de cette fonction où on peut explicitement décrire le datatype

string	ls_message

IF Isnull(aa_value) THEN
	populateerror(20000,"")
	gu_message.uf_unexp("La valeur est nulle, il faut explicitement citer le type de donnée")
	return(-1)
ELSE
	return(uf_setdefaultvalue(al_row, as_itemname, aa_value, any!, ab_checkitem))
END IF

end function

public function integer uf_setdefaultvalue (long al_row, string as_itemname, any aa_value);// assigner une valeur par défaut en déclenchant la séquence de validation (checkitem - itemvalidated) ou
// uniquement itemvalidated.
// Il semble que le setitem ne fonctionne pas avec un argument de type ANY si la valeur est nulle.
// Il faut dans ce cas utiliser la variante de cette fonction où on peut explicitement décrire le datatype

IF Isnull(aa_value) THEN
	populateerror(20000,"")
	gu_message.uf_unexp("La valeur est nulle, il faut explicitement citer le type de donnée")
	return(-1)
ELSE
	return(uf_setdefaultvalue(al_row, as_itemname, aa_value, any!, TRUE))
END IF

end function

public function integer uf_setdefaultvalue (long al_row, string as_itemname, any aa_value, object ao_datatype, boolean ab_checkitem);// assigner une valeur par défaut en déclenchant la séquence de validation (checkitem - itemvalidated) ou
// uniquement itemvalidated si il n'est pas possible de déclencher la validation (checkitem) également : cela
// peut-être le cas si dans checkitem de l'élément qu'on veut modifier on utilise l'élément qui a provoqué
// cette modif. 
// Ex : quand je modifie l'item A, j'utilise setdefaultvalue() pour modifier l'item B, mais la validation
// de l'item B fait intervenir la valeur de l'item A. La valeur de A n'est pas encore dans le DWbuffer car à ce stade-ci
// sa validation n'est pas encore terminée !

// il semble que le setitem ne fonctionne pas avec un argument de type ANY si la valeur est nulle.
// Il faut dans ce cas utiliser la variante de cette fonction où on peut explicitement décrire le datatype

string	ls_message

IF IsNull(aa_value) THEN
	CHOOSE CASE ao_datatype
		CASE date!
			aa_value = gu_c.date_null
		CASE integer!
			aa_value = gu_c.i_null
		CASE decimal!
			aa_value = gu_c.d_null
		CASE long!
			aa_value = gu_c.l_null
		CASE string!
			aa_value = gu_c.s_null
	END CHOOSE
END IF

IF this.setitem(al_row, as_itemname, aa_value) = -1 THEN
	IF NOT ib_multiplerow THEN	uf_setvalidtofalse(as_itemname)
	return(-1)
END IF

IF ab_checkitem THEN
	// avec validation
	IF this.event ue_checkitem (al_row, as_itemname, string(aa_value), ls_message) = 1 THEN
		this.event ue_itemvalidated(al_row, as_itemname, string(aa_value))
		return(1)
	ELSE
		IF NOT ib_multiplerow THEN	uf_setvalidtofalse(as_itemname)
		return(-1)
	END IF
ELSE
	// sans validation
	this.event ue_itemvalidated(al_row, as_itemname, string(aa_value))
	return(1)
END IF
end function

public subroutine uf_selecttext ();// sélection automatique du contenu de l'item en cours, sauf pour les champs de type CHAR de + de 4 positions
string	ls_coltype
uint		li_n

IF NOT IsValid(idwo_currentitem) THEN return
IF IsNull(idwo_currentitem) THEN return
IF idwo_currentitem.Type <> "column" AND idwo_currentitem.Type <> "compute" THEN	return

ls_coltype = idwo_currentitem.coltype
IF PosA(ls_coltype, "char") = 0 THEN
	This.SelectText(1, 999)
ELSE
	li_n = integer(MidA(ls_coltype,6,LenA(ls_coltype) - 6))
	IF li_n <= 5 THEN
		This.SelectText(1, LenA(This.Gettext()))
	END IF
END IF
	
end subroutine

public subroutine uf_changedataobject (string as_dataobject);This.DataObject = as_dataobject
This.uf_init()
This.SetTransObject(SQLCA)
end subroutine

public function integer uf_setdefaultvalue (long al_row, string as_itemname, any aa_value, object ao_datatype);// assigner une valeur par défaut en déclenchant la séquence de validation (checkitem - itemvalidated) ou
// uniquement itemvalidated.
// Il semble que le setitem ne fonctionne pas avec un argument de type ANY si la valeur est nulle.
// Il faut dans ce cas utiliser la variante de cette fonction où on peut explicitement décrire le datatype

return(uf_setdefaultvalue(al_row, as_itemname, aa_value, ao_datatype, TRUE))
end function

public subroutine uf_disabledata ();uf_DisableItems(is_udata[])
end subroutine

private subroutine uf_init ();integer	li_count, li_i, li_j, li_k, li_tabseq
string	ls_key, ls_updt, ls_switch
str_item	lstr_item[], lstr_keys[], lstr_itemswitch
dwobject	ldw_1

idwo_currentitem = ldw_1
li_count = integer(This.Object.DataWindow.Column.Count)

/* 1. la valeur initiale des propriétés 'protect', bgcolor, pointer est sauvée afin de pouvoir être restorée + tard
   2. mémoriser toutes les colonnes modifiables (tabsequence <> 0) 
	3. mémoriser toutes les colonnes composant la clé (key=YES) */
FOR li_i = 1 TO li_count
	istr_itemprop[li_i].s_item = this.describe("#" + string(li_i) + ".name")
	istr_itemprop[li_i].s_protect = this.describe("#" + string(li_i) + ".protect")
	istr_itemprop[li_i].s_bgcolor = this.describe("#" + string(li_i) + ".background.color")
	istr_itemprop[li_i].s_pointer = this.describe("#" + string(li_i) + ".pointer")
	li_tabseq = integer(This.Describe("#" + string(li_i) + ".TabSequence"))
	ls_key = upper(This.Describe("#" + string(li_i) + ".Key"))
	IF li_tabseq > 0 THEN // AND ls_key = "NO" THEN
		li_j ++
		lstr_item[li_j].s_name = This.Describe("#" + string(li_i) + ".Name")
		lstr_item[li_j].i_tabseq = li_tabseq
	END IF
	IF li_tabseq > 0 AND ls_key = "YES" THEN
		li_k ++
		lstr_keys[li_k].s_name = this.Describe("#" + string(li_i) + ".Name")
		lstr_keys[li_k].i_tabseq = li_tabseq
	END IF
NEXT

// trier par ordre croissant de n° de séquence la table des items modifiables
FOR li_i = 1 TO upperbound(lstr_item)
	FOR li_j = li_i + 1 TO upperbound(lstr_item)
		IF lstr_item[li_j].i_tabseq < lstr_item[li_i].i_tabseq THEN
			lstr_itemswitch = lstr_item[li_i]
			lstr_item[li_i] = lstr_item[li_j]
			lstr_item[li_j] = lstr_itemswitch
		END IF
	NEXT
NEXT

// garnir array contenant le nom des champs modifiables dans l'ordre de tabulation
li_j = 0
FOR li_i = 1 TO upperbound(lstr_item)
	li_j ++
	is_udata[li_j] = lstr_item[li_i].s_name
NEXT

// par défaut, les items à valider sont les mêmes que les items modifiables, mais il existe une fonction permettant
// d'exclure certaines items ou d'en ajouter
is_itemstovalidate = is_udata

// trier par ordre croissant de n° de séquence la table des éléments de clé
FOR li_i = 1 TO upperbound(lstr_keys)
	FOR li_j = li_i + 1 TO upperbound(lstr_keys)
		IF lstr_keys[li_j].i_tabseq < lstr_keys[li_i].i_tabseq THEN
			lstr_itemswitch = lstr_keys[li_i]
			lstr_keys[li_i] = lstr_keys[li_j]
			lstr_keys[li_j] = lstr_itemswitch
		END IF
	NEXT
NEXT

// garnir array contenant le nom des éléments de la clé
li_j = 0
FOR li_i = 1 TO upperbound(lstr_keys)
	li_j ++
	is_keys[li_j] = lstr_keys[li_i].s_name
NEXT

end subroutine

public subroutine uf_enabledata ();uf_EnableItems(is_udata[])
end subroutine

public subroutine uf_enablekeys ();uf_EnableItems(is_keys[],true)
end subroutine

public subroutine uf_enableitems (string as_items[]);uf_EnableItems(as_items[],false)
end subroutine

public subroutine uf_enableitems (string as_item[], boolean ab_key);/* restaurer les valeurs initiales des propriétés protect et bgcolor des items passés en paramètre
   IN : as_items = array contenant les items à enabler 
		  ab_key = true si on enable des champs clé, dans ce cas la couleur de fond viend du .INI */

integer li_i, li_id

//this.setredraw(false)
for li_i = 1 to UpperBound(as_item)
	li_id = integer(this.describe(as_item[li_i] + ".id"))
	this.Modify(as_item[li_i] + ".protect="  + istr_itemprop[li_id].s_protect)
	this.Modify(as_item[li_i] + ".pointer="  + istr_itemprop[li_id].s_pointer)
	IF ab_key THEN
		this.Modify(as_item[li_i] + ".background.color=" + string (gl_keys_bckg_color))
	ELSE
		this.Modify(as_item[li_i] + ".background.color=" + istr_itemprop[li_id].s_bgcolor)
	END IF
next
//this.setredraw(true)
end subroutine

public subroutine uf_disableitems (string as_item[]);// 'protect' tous les items passés en paramètre et changer leur couleur de fond en gris (simulation état disabled)
integer li_i

//this.setredraw(false)
for li_i = 1 to UpperBound(as_item)
	this.Modify(as_item[li_i] + ".protect='1'")
	this.Modify(as_item[li_i] + ".pointer=''")
	this.Modify(as_item[li_i] + ".background.color='" + string(f_disabcolor()) + "'")
next
//this.setredraw(true)

end subroutine

public subroutine uf_additemstocheck (string as_items[]);// ajouter à la liste des items à valider les items passés en paramètre. Ils seront donc vérifiés lors de ue_checkrow

long	ll_items1, ll_items2, ll_max
boolean	lb_exist

ll_max = upperbound(is_itemstovalidate) + 1

// ajouter chaque item qui ne figure pas encore dans l'array
FOR ll_items1 = 1 TO upperbound(as_items)
	lb_exist = FALSE
	FOR ll_items2 = 1 TO upperbound(is_itemstovalidate)
		IF as_items[ll_items1] = is_itemstovalidate[ll_items2] THEN
			lb_exist = TRUE
			EXIT // l'item à ajouter existe déjà dans l'array : sortir de la boucle
		END IF
	NEXT
	IF NOT lb_exist THEN
		is_itemstovalidate[ll_max] = as_items[ll_items1]
		ll_max++
	END IF
NEXT
end subroutine

public subroutine uf_additemstokey (string as_items[]);// ajouter à la liste des éléments de clé les items passés en paramètre.

long	ll_items1, ll_items2, ll_max
boolean	lb_exist

ll_max = upperbound(is_keys) + 1

// ajouter chaque item qui ne figure pas encore dans l'array
FOR ll_items1 = 1 TO upperbound(as_items)
	lb_exist = FALSE
	FOR ll_items2 = 1 TO upperbound(is_keys)
		IF as_items[ll_items1] = is_keys[ll_items2] THEN
			lb_exist = TRUE
			EXIT // l'item à ajouter existe déjà dans l'array : sortir de la boucle
		END IF
	NEXT
	IF NOT lb_exist THEN
		is_keys[ll_max] = as_items[ll_items1]
		ll_max++
	END IF
NEXT
end subroutine

public subroutine uf_excludeitemsfromkey (string as_items[]);// exclure de la liste des éléments de clé les items passés en paramètre.

long	ll_items1, ll_items2, ll_max1, ll_max2
string ls_keys[]

ll_max1 = upperbound(as_items)
ll_max2 = upperbound(is_keys)

FOR ll_items1 = 1 TO ll_max1
	FOR ll_items2 = 1 TO ll_max2
		IF as_items[ll_items1] = is_keys[ll_items2] THEN
			SetNull(is_keys[ll_items2])
			EXIT // passe à l'item à supprimer suivant
		END IF
	NEXT
NEXT

// création d'un nouvel array ne contenant que les items restant
ll_items1 = 0
FOR ll_items2 = 1 TO ll_max2
	IF NOT IsNull(is_keys[ll_items2]) THEN
		ll_items1++
		ls_keys[ll_items1] = is_keys[ll_items2]
	END IF
NEXT

is_keys = ls_keys
end subroutine

public subroutine uf_displaymessage (boolean ab_display);ib_displaymessage = ab_display
end subroutine

public subroutine uf_setkeys (string as_keys[]);is_keys = as_keys
end subroutine

public subroutine uf_setudata (string as_udata[]);is_udata = as_udata
end subroutine

public subroutine uf_setitemstovalidate (string as_itemstovalidate[]);is_ItemsToValidate = as_ItemsToValidate
end subroutine

public function any uf_getudata ();return(is_udata)
end function

public function integer uf_setdefaultvalue (long al_row, string as_itemname, any aa_value, object ao_datatype, boolean ab_checkitem, ref string as_message);// assigner une valeur par défaut en déclenchant la séquence de validation (checkitem - itemvalidated) ou
// uniquement itemvalidated si il n'est pas possible de déclencher la validation (checkitem) également : cela
// peut-être le cas si dans checkitem de l'élément qu'on veut modifier on utilise l'élément qui a provoqué
// cette modif. 
// Ex : quand je modifie l'item A, j'utilise setdefaultvalue() pour modifier l'item B, mais la validation
// de l'item B fait intervenir la valeur de l'item A. La valeur de A n'est pas encore dans le DWbuffer car à ce stade-ci
// sa validation n'est pas encore terminée !

// il semble que le setitem ne fonctionne pas avec un argument de type ANY si la valeur est nulle.
// Il faut dans ce cas utiliser la variante de cette fonction où on peut explicitement décrire le datatype

IF IsNull(aa_value) THEN
	CHOOSE CASE ao_datatype
		CASE date!
			aa_value = gu_c.date_null
		CASE integer!
			aa_value = gu_c.i_null
		CASE decimal!
			aa_value = gu_c.d_null
		CASE long!
			aa_value = gu_c.l_null
		CASE string!
			aa_value = gu_c.s_null
	END CHOOSE
END IF

IF this.setitem(al_row, as_itemname, aa_value) = -1 THEN
	IF NOT ib_multiplerow THEN	uf_setvalidtofalse(as_itemname)
	return(-1)
END IF

IF ab_checkitem THEN
	// avec validation
	IF this.event ue_checkitem (al_row, as_itemname, string(aa_value), as_message) = 1 THEN
		this.event ue_itemvalidated(al_row, as_itemname, string(aa_value))
		return(1)
	ELSE
		IF NOT ib_multiplerow THEN	uf_setvalidtofalse(as_itemname)
		return(-1)
	END IF
ELSE
	// sans validation
	this.event ue_itemvalidated(al_row, as_itemname, string(aa_value))
	return(1)
END IF
end function

public function integer uf_setdefaultvalue (long al_row, string as_itemname, any aa_value, object ao_datatype, ref string as_message);// assigner une valeur par défaut en déclenchant la séquence de validation (checkitem - itemvalidated) ou
// uniquement itemvalidated.
// Il semble que le setitem ne fonctionne pas avec un argument de type ANY si la valeur est nulle.
// Il faut dans ce cas utiliser la variante de cette fonction où on peut explicitement décrire le datatype

return(uf_setdefaultvalue(al_row, as_itemname, aa_value, ao_datatype, TRUE, as_message))
end function

public function integer uf_setdefaultvalue (long al_row, string as_itemname, any aa_value, boolean ab_checkitem, ref string as_message);// assigner une valeur par défaut en déclenchant la séquence de validation (checkitem - itemvalidated) ou
// uniquement itemvalidated.
// Il semble que le setitem ne fonctionne pas avec un argument de type ANY si la valeur est nulle.
// Il faut dans ce cas utiliser la variante de cette fonction où on peut explicitement décrire le datatype

string	ls_message

IF Isnull(aa_value) THEN
	populateerror(20000,"")
	gu_message.uf_unexp("La valeur est nulle, il faut explicitement citer le type de donnée")
	return(-1)
ELSE
	return(uf_setdefaultvalue(al_row, as_itemname, aa_value, any!, ab_checkitem, as_message))
END IF

end function

public function integer uf_setdefaultvalue (long al_row, string as_itemname, any aa_value, ref string as_message);// assigner une valeur par défaut en déclenchant la séquence de validation (checkitem - itemvalidated) ou
// uniquement itemvalidated.
// Il semble que le setitem ne fonctionne pas avec un argument de type ANY si la valeur est nulle.
// Il faut dans ce cas utiliser la variante de cette fonction où on peut explicitement décrire le datatype

IF Isnull(aa_value) THEN
	populateerror(20000,"")
	gu_message.uf_unexp("La valeur est nulle, il faut explicitement citer le type de donnée")
	return(-1)
ELSE
	return(uf_setdefaultvalue(al_row, as_itemname, aa_value, any!, TRUE, as_message))
END IF

end function

event itemerror;call super::itemerror;string ls_ValidationMsg

// utilisation d'un message particulier affecté à is_ErrorMessage dans itemchanged event
IF ib_dwspecificerror THEN
	ib_dwspecificerror = false
	ls_ValidationMsg = is_errormessage
ELSE
// utilisation du message standard définit dans le datawindow
	ls_ValidationMsg = f_clean_validmsg (string(dwo.ValidationMsg))
END IF

// si message = NULL, en assigner un sinon le messagebox ne s'affiche pas du tout !
IF f_IsEmptyString(ls_ValidationMsg) THEN
	ls_ValidationMsg = "Valeur (" + f_string(data) + ") incorrecte"
END IF

// affichage du message standard dans un messagebox personnalisé
// poster fonction pour afficher l'erreur et continuer l'event
//gu_message.post uf_error(ls_ValidationMsg)
// essai avec trigger au lieu de post ...
IF ib_displaymessage THEN gu_message.uf_error(ls_ValidationMsg)

// suppression du messagebox standard
return(1)

end event

event itemfocuschanged;call super::itemfocuschanged;post uf_selecttext()
end event

event itemchanged;call super::itemchanged;// NB : ne pas coder ici ce qui doit pouvoir être appelé d'un autre endroit
dwItemStatus	l_rowstatus
integer			li_status, li_maxkeyitems

li_maxkeyitems = upperbound(is_keys)
l_rowstatus = this.GetItemStatus(row, 0, primary!)
ib_displaymessage = TRUE

// si l'item modifié est le dernier élément de la clé d'un dw qui n'est pas multiplerow et qu'on le quitte avec 
// TAB ou ENTER accompagné de SHIFT, ALT ou CTRL, on n'essaye pas de valider
IF (NOT ib_multiplerow) AND li_maxkeyitems > 0 THEN
	IF dwo.name = is_keys[li_maxkeyitems] THEN
		IF (keyDown(Keytab!) OR keyDown(KeyEnter!)) AND (KeyDown(KeyAlt!) OR KeyDown(KeyControl!) OR KeyDown(KeyShift!)) THEN
			return(2)
		END IF
	END IF
END IF

// si on est dans un nouveau record d'un datawindow qui n'est PAS multiplerow et
// si l'item modifié est le dernier élément d'une clé qui comporte plusieurs éléments, 
// on vérifie que les éléments précédents de la clé ont été validés
IF (NOT ib_multiplerow) AND li_maxkeyitems > 1 AND (l_rowstatus=new! OR l_rowstatus=newmodified!) THEN
	IF dwo.name = is_keys[li_maxkeyitems] THEN
		IF uf_checkkeyitems(li_maxkeyitems - 1) = -1 THEN
			is_errormessage = "Veuillez compléter tous les éléments de la clé"
			ib_dwspecificerror = true
			ib_displaymessage = TRUE
			return(1)
		END IF
	END IF
END IF

// empêcher les caractères " -> " car interprété et modifié par le driver PB !
IF PosA(data, "->") > 0 THEN
	is_errormessage = "Veuillez ne pas utiliser les caractères ' -> ' dans les commentaires."
	ib_dwspecificerror = TRUE
	ib_displaymessage = TRUE
	return(1)
END IF

// vérifier l'item en cours
li_status = This.event ue_CheckItem(row, dwo.name, data, is_errormessage)

CHOOSE CASE li_status
	// rejet avec message d'erreur et focus ne peut pas changer
	CASE -1
		ib_displaymessage = TRUE
		IF LenA(is_errormessage) > 0 THEN
			ib_dwspecificerror = true
		ELSE
			ib_dwspecificerror = false
		END IF
		return(1)
		
	// rejet sans message d'erreur et focus peut changer (cas où la valeur introduite est
	// incorrecte et EST automatiquement remplacée par une autre correcte dans la fonction de check)
	CASE -2
		This.event ue_ItemValidated(row, dwo.name, string(dwo.data.primary[row]))
		return(2)

	// rejet sans message d'erreur et focus peut changer (cas où la valeur introduite est
	// incorrecte et N'EST PAS remplacée par une autre correcte dans la fonction de check)
	CASE -3
		return(2)

	// rejet sans message d'erreur et focus ne peut pas changer
	CASE -4
		IF LenA(is_errormessage) > 0 THEN
			ib_dwspecificerror = true
			ib_displaymessage = FALSE
		END IF
		return(1)
	
	// la valeur est acceptée sans nécessiter de modification
	CASE ELSE
		This.event ue_ItemValidated(row, dwo.name, data)
		return(0)
END CHOOSE

end event

event getfocus;call super::getfocus;uf_selecttext()

end event

event editchanged;call super::editchanged;/* pour les champs qui NE peuvent PAS être négatifs (absence du code NEG dans le tag de l'item) , 
   on interdit le caractère '-' */
string	ls_val

IF LeftA(data, 1) = "-" AND lower(LeftA(dwo.coltype,4)) <> "char" THEN
	IF f_gettag(dwo.tag, "NEG", ls_val) = 0 THEN
		beep(1)
		This.SetText(RightA(data, LenA(data) - 1))
		gw_mdiframe.SetMicroHelp(f_gethelpmsg("help=3"))
	END IF
END IF
end event

on uo_ancestor_dw.create
call super::create
end on

on uo_ancestor_dw.destroy
call super::destroy
end on

event constructor;call super::constructor;This.uf_init()
This.SetTransObject(SQLCA)
end event

event ue_reset;call super::ue_reset;// on réinitialise à FALSE l'indicateur de validité des divers composants de la clé, pour la prochaine utilisation
str_rowkey	lstr_rowkey

istr_rowkey = lstr_rowkey
return(1)
end event

