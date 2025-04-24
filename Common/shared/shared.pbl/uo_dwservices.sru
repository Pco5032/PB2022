forward
global type uo_dwservices from nonvisualobject
end type
end forward

global type uo_dwservices from nonvisualobject
end type
global uo_dwservices uo_dwservices

type variables
string	is_text_confirmTitre, is_text_confirmText, is_text_deletedText, is_text_et

end variables

forward prototypes
public subroutine uf_setbrowsecol (datawindow adw_1)
public subroutine uf_setinitial (datawindow adw_1, string as_colname, any aa_initialvalue)
public function integer uf_sort (datawindow ad_dwname, string as_expression)
public function long uf_width (datawindow adw_dwtocalc)
public function integer uf_updatetransact (datastore ads_dstoupdate[])
public subroutine uf_setinitial (datastore ads_1, string as_colname, any aa_initialvalue)
public function boolean uf_dwmodified (datawindow adw_dw[])
public function integer uf_updatetransact (datawindow adw_1, datawindow adw_2)
public function integer uf_updatetransact (datawindow adw_1, datawindow adw_2, datawindow adw_3)
public function integer uf_updatetransact (datawindow adw_1, datawindow adw_2, datawindow adw_3, datawindow adw_4)
public function integer uf_updatetransact (datawindow adw_1, datawindow adw_2, datawindow adw_3, datawindow adw_4, datawindow adw_5)
public function integer uf_updatetransact (datawindow adw_1, datawindow adw_2, datawindow adw_3, datawindow adw_4, datawindow adw_5, datawindow adw_6)
public function integer uf_updatetransact (datawindow adw_1, datawindow adw_2, datawindow adw_3, datawindow adw_4, datawindow adw_5, datawindow adw_6, datawindow adw_7)
public function integer uf_updatetransact (datawindow adw_1, datawindow adw_2, datawindow adw_3, datawindow adw_4, datawindow adw_5, datawindow adw_6, datawindow adw_7, datawindow adw_8)
public function integer uf_updatetransact (datawindow adw_1, datawindow adw_2, datawindow adw_3, datawindow adw_4, datawindow adw_5, datawindow adw_6, datawindow adw_7, datawindow adw_8, datawindow adw_9)
public function integer uf_updatetransact (datawindow adw_dwtoupdate[])
public function integer uf_updatetransact (datawindow adw_1)
public function integer uf_updatetransact (datawindow adw_1, datawindow adw_2, datawindow adw_3, datawindow adw_4, datawindow adw_5, datawindow adw_6, datawindow adw_7, datawindow adw_8, datawindow adw_9, datawindow adw_10)
public function integer uf_updatetransact (datastore ads_1)
public function integer uf_updatetransact (datastore ads_1, datastore ads_2)
public function integer uf_updatetransact (datastore ads_1, datastore ads_2, datastore ads_3)
public function integer uf_updatetransact (datastore ads_1, datastore ads_2, datastore ads_3, datastore ads_4)
public function integer uf_updatetransact (datastore ads_1, datastore ads_2, datastore ads_3, datastore ads_4, datastore ads_5)
public function integer uf_getnextupdateablecol (uo_ancestor_dw adw_1, integer ai_firstitem)
public function string uf_getcolumnname (uo_dw adw_1, string as_dbname)
public function integer uf_confirm_cancel (datawindow adw_dw[])
public function long uf_findduplicate (datawindow adw_1, long al_currentrow, string as_where)
public subroutine uf_translatetext ()
public function long uf_findduplicate (datastore ads_1, long al_currentrow, string as_where)
public function integer uf_updatetransact (datawindow adw_1, datawindow adw_2, datawindow adw_3, datawindow adw_4, datawindow adw_5, datawindow adw_6, datawindow adw_7, datawindow adw_8, datawindow adw_9, datawindow adw_10, datawindow adw_11)
public function integer uf_updatetransact (datawindow adw_1, datawindow adw_2, datawindow adw_3, datawindow adw_4, datawindow adw_5, datawindow adw_6, datawindow adw_7, datawindow adw_8, datawindow adw_9, datawindow adw_10, datawindow adw_11, datawindow adw_12)
public function integer uf_updatetransact (datawindow adw_1, datawindow adw_2, datawindow adw_3, datawindow adw_4, datawindow adw_5, datawindow adw_6, datawindow adw_7, datawindow adw_8, datawindow adw_9, datawindow adw_10, datawindow adw_11, datawindow adw_12, datawindow adw_13, datawindow adw_14, datawindow adw_15, datawindow adw_16, datawindow adw_17)
public function integer uf_updatetransact (datawindow adw_1, datawindow adw_2, datawindow adw_3, datawindow adw_4, datawindow adw_5, datawindow adw_6, datawindow adw_7, datawindow adw_8, datawindow adw_9, datawindow adw_10, datawindow adw_11, datawindow adw_12, datawindow adw_13)
public function integer uf_updatetransact (datawindow adw_1, datawindow adw_2, datawindow adw_3, datawindow adw_4, datawindow adw_5, datawindow adw_6, datawindow adw_7, datawindow adw_8, datawindow adw_9, datawindow adw_10, datawindow adw_11, datawindow adw_12, datawindow adw_13, datawindow adw_14)
public function integer uf_updatetransact (datawindow adw_1, datawindow adw_2, datawindow adw_3, datawindow adw_4, datawindow adw_5, datawindow adw_6, datawindow adw_7, datawindow adw_8, datawindow adw_9, datawindow adw_10, datawindow adw_11, datawindow adw_12, datawindow adw_13, datawindow adw_14, datawindow adw_15)
public function integer uf_updatetransact (datawindow adw_1, datawindow adw_2, datawindow adw_3, datawindow adw_4, datawindow adw_5, datawindow adw_6, datawindow adw_7, datawindow adw_8, datawindow adw_9, datawindow adw_10, datawindow adw_11, datawindow adw_12, datawindow adw_13, datawindow adw_14, datawindow adw_15, datawindow adw_16)
end prototypes

public subroutine uf_setbrowsecol (datawindow adw_1);// au moyen d'une expression, change la couleur de fond d'une ligne sur deux du DW passé en paramètre
string	ls_mod

IF len(GetTheme()) = 0 THEN
	ls_mod = "DataWindow.Detail.Color='0 ~t If (mod(getrow(),2) = 0, " + &
			string(gl_browse_odd_bckg_color) + &
			", " + string(gl_browse_even_bckg_color) + ")'"
	adw_1.modify(ls_mod)
END IF

end subroutine

public subroutine uf_setinitial (datawindow adw_1, string as_colname, any aa_initialvalue);/* définit la valeur initiale d'un item dans le DW
	as_colname = string donnant le nom de la colonne à laquelle il faut attribuer une valeur initiale
	aa_initialvalue = valeur initiale de la colonne (type any mais sera convertit en string */
string	ls_mod, ls_value, ls_datatype, ls_err

ls_datatype = classname(aa_initialvalue)
IF ls_datatype = "string" THEN
	ls_value = aa_initialvalue
ELSE
	ls_value = string(aa_initialvalue)
END IF
ls_mod = as_colname + ".Initial = '" + ls_value + "'"

ls_err = adw_1.modify(ls_mod)
IF LenA(ls_err) > 0 THEN
	gu_message.uf_error(ls_err)
END IF
end subroutine

public function integer uf_sort (datawindow ad_dwname, string as_expression);// tri d'un DW
integer i_status

// applique l'expression de tri
i_status = ad_dwname.SetSort(as_expression)

// lance le tri
IF i_status <> -1 THEN
	i_status = ad_dwname.Sort()
	ad_dwname.ScrollToRow(1)		// Place le pointeur sur le 1er record ...
	ad_dwname.SelectRow(0,false)	// ... désélectionne le record sélectionné ...
	ad_dwname.SelectRow(ad_dwname.getrow(),true)	// ... et sélectionne le record où se trouve le pointeur (1er record)
	ad_dwname.SetFocus()
	gb_sort_asc = NOT gb_sort_asc	// pour inverser l'ordre de tri la prochaine fois
ELSE
	gu_message.uf_error("Erreur de tri~n~nDatawindow~t: " + string(ad_dwname.dataobject) + &
	"~nExpression~t: " + as_expression, StopSign!)
END IF

return (i_status)
end function

public function long uf_width (datawindow adw_dwtocalc);// renvoie la largeur du DW en fonction des objets qui le composent

string	ls_object[]
long		ll_width, ll_maxwidth
integer	li_obj, li_maxobj, li_x
string	ls_desc

// obtient un array de string contenant tous les objets du DW
f_parse(adw_dwtocalc.Object.DataWindow.Objects,"~t",ls_object)

// recherche la position et la largeur de chaque objet et retient celui dont la combinaison X + largeur
// est la plus élevée
FOR li_obj = 1 TO upperbound(ls_object)
	li_x = integer(adw_dwtocalc.describe(trim(ls_object[li_obj]) + ".x"))
	ll_width = long(adw_dwtocalc.describe(trim(ls_object[li_obj]) + ".width"))
	IF (li_x + ll_width) > ll_maxwidth THEN 
		li_maxobj = li_obj
		ll_maxwidth = li_x + ll_width
	END IF
NEXT

return(ll_maxwidth)

end function

public function integer uf_updatetransact (datastore ads_dstoupdate[]);// update des DS passés en argument, dans l'ordre où ils apparaissent, en UNE SEULE TRANSACTION
// code de retour = 1 si la transaction a réussi
// code de retour est négatif et indique le n° du DS dont l'update a échoué et qui a provoqué l'échec de la transaction

integer	li_dscount, li_i, li_status

li_dscount = upperbound(ads_dstoupdate)

FOR li_i = 1 TO li_dscount
	li_status = ads_dstoupdate[li_i].Update(TRUE, FALSE)
	// PCO 26/03/2018 : malgré DB non connectée et message, li_status vaut 1 et non -1 !
	// --> ajout test sur SQLCA.sqlcode
	IF li_status = -1 OR SQLCA.SQLCode = -1 THEN
		ROLLBACK;
		return(li_i * -1)
	END IF
NEXT
FOR li_i = 1 TO li_dscount
	ads_dstoupdate[li_i].ResetUpdate()
NEXT
COMMIT;
return(1)

end function

public subroutine uf_setinitial (datastore ads_1, string as_colname, any aa_initialvalue);/* définit la valeur initiale d'un item dans le DS
	as_colname = string donnant le nom de la colonne à laquelle il faut attribuer une valeur initiale
	aa_initialvalue = valeur initiale de la colonne (type any mais sera convertit en string */
string	ls_mod, ls_value, ls_datatype, ls_err

ls_datatype = classname(aa_initialvalue)
IF ls_datatype = "string" THEN
	ls_value = aa_initialvalue
ELSE
	ls_value = string(aa_initialvalue)
END IF
ls_mod = as_colname + ".Initial = '" + ls_value + "'"

ls_err = ads_1.modify(ls_mod)
IF LenA(ls_err) > 0 THEN
	gu_message.uf_error(ls_err)
END IF
end subroutine

public function boolean uf_dwmodified (datawindow adw_dw[]);// renvoie TRUE si au moins un des DW passés en argument a été modifié, FALSE si rien de modifié
integer	li_i, li_max

li_max = upperbound(adw_dw)
FOR li_i = 1 TO li_max
	IF adw_dw[li_i].DeletedCount() > 0 OR adw_dw[li_i].ModifiedCount() > 0 THEN 
		return(TRUE)
	END IF
NEXT
return(FALSE)
end function

public function integer uf_updatetransact (datawindow adw_1, datawindow adw_2);return(uf_UpdateTransact({adw_1, adw_2}))
end function

public function integer uf_updatetransact (datawindow adw_1, datawindow adw_2, datawindow adw_3);return(uf_UpdateTransact({adw_1, adw_2, adw_3}))
end function

public function integer uf_updatetransact (datawindow adw_1, datawindow adw_2, datawindow adw_3, datawindow adw_4);return(uf_UpdateTransact({adw_1, adw_2, adw_3, adw_4}))
end function

public function integer uf_updatetransact (datawindow adw_1, datawindow adw_2, datawindow adw_3, datawindow adw_4, datawindow adw_5);return(uf_UpdateTransact({adw_1, adw_2, adw_3, adw_4, adw_5}))
end function

public function integer uf_updatetransact (datawindow adw_1, datawindow adw_2, datawindow adw_3, datawindow adw_4, datawindow adw_5, datawindow adw_6);return(uf_UpdateTransact({adw_1, adw_2, adw_3, adw_4, adw_5, adw_6}))
end function

public function integer uf_updatetransact (datawindow adw_1, datawindow adw_2, datawindow adw_3, datawindow adw_4, datawindow adw_5, datawindow adw_6, datawindow adw_7);return(uf_UpdateTransact({adw_1, adw_2, adw_3, adw_4, adw_5, adw_6, adw_7}))
end function

public function integer uf_updatetransact (datawindow adw_1, datawindow adw_2, datawindow adw_3, datawindow adw_4, datawindow adw_5, datawindow adw_6, datawindow adw_7, datawindow adw_8);return(uf_UpdateTransact({adw_1, adw_2, adw_3, adw_4, adw_5, adw_6, adw_7, adw_8}))
end function

public function integer uf_updatetransact (datawindow adw_1, datawindow adw_2, datawindow adw_3, datawindow adw_4, datawindow adw_5, datawindow adw_6, datawindow adw_7, datawindow adw_8, datawindow adw_9);return(uf_UpdateTransact({adw_1, adw_2, adw_3, adw_4, adw_5, adw_6, adw_7, adw_8, adw_9}))
end function

public function integer uf_updatetransact (datawindow adw_dwtoupdate[]);// update des DW passés en argument, dans l'ordre où ils apparaissent, en UNE SEULE TRANSACTION
// code de retour = 1 si la transaction a réussi
// code de retour est négatif et indique le n° du DW dont l'update a échoué et qui a provoqué l'échec de la transaction

integer	li_dwcount, li_i, li_status

li_dwcount = upperbound(adw_dwtoupdate)

FOR li_i = 1 TO li_dwcount
	li_status = adw_dwtoupdate[li_i].Update(TRUE, FALSE)
	// PCO 26/03/2018 : malgré DB non connectée et message d'erreur, li_status vaut 1 et non -1 !
	// --> ajout test sur SQLCA.sqlcode
	// PCO 22/05/2018 : OUI MAIS !!! SQLCA.SQLCode et SQLErrText conserve leur état d'une erreur précédente
	// n'ayant rien à voir avec l'update, donc un message d'erreur est généré ici pour une erreur en amont !!!
	//
	// You should always test the success or failure code (the SQLCode property of the Transaction object) 
	// after issuing one of the following statements in a script:
	//     - Transaction management statement (such as CONNECT, COMMIT, and DISCONNECT)
   // 	 - Embedded or dynamic SQL
	// Note : Not in DataWindows. Do not do this type of error checking following a retrieval 
	// 		 or update made in a DataWindow.
	//
	// IF li_status = -1 OR SQLCA.SQLCode = -1 THEN
	IF li_status = -1 THEN
		ROLLBACK;
		return(li_i * -1)
	END IF
NEXT
FOR li_i = 1 TO li_dwcount
	adw_dwtoupdate[li_i].ResetUpdate()
NEXT
COMMIT;
return(1)

end function

public function integer uf_updatetransact (datawindow adw_1);return(uf_UpdateTransact({adw_1}))
end function

public function integer uf_updatetransact (datawindow adw_1, datawindow adw_2, datawindow adw_3, datawindow adw_4, datawindow adw_5, datawindow adw_6, datawindow adw_7, datawindow adw_8, datawindow adw_9, datawindow adw_10);return(uf_UpdateTransact({adw_1, adw_2, adw_3, adw_4, adw_5, adw_6, adw_7, adw_8, adw_9, adw_10}))
end function

public function integer uf_updatetransact (datastore ads_1);return(uf_UpdateTransact({ads_1}))
end function

public function integer uf_updatetransact (datastore ads_1, datastore ads_2);return(uf_UpdateTransact({ads_1, ads_2}))
end function

public function integer uf_updatetransact (datastore ads_1, datastore ads_2, datastore ads_3);return(uf_UpdateTransact({ads_1, ads_2, ads_3}))
end function

public function integer uf_updatetransact (datastore ads_1, datastore ads_2, datastore ads_3, datastore ads_4);return(uf_UpdateTransact({ads_1, ads_2, ads_3, ads_4}))
end function

public function integer uf_updatetransact (datastore ads_1, datastore ads_2, datastore ads_3, datastore ads_4, datastore ads_5);return(uf_UpdateTransact({ads_1, ads_2, ads_3, ads_4, ads_5}))
end function

public function integer uf_getnextupdateablecol (uo_ancestor_dw adw_1, integer ai_firstitem);/* retourner le n° du 1er item éditable (tabsequence > 0) après celui passé en paramètre
   arguments : 
		1) adw_1 est le DW sur lequel il faut travailler (doit être hérité de uo_ancestor_dw !)
		2) ai_first est le n° du 1er item à partir duquel il faut chercher (0 pour renvoyer le n° du 1er item éditable)

	retour :
		1) entier donnant le n° du prochain item modifiable ou 0 s'il n'y en a pas
*/

integer	li_count, li_i, li_tabseq, li_tabseq0, li_id
string	ls_udata[], ls_protect

// nombre d'items éditables dans le DW
ls_udata = adw_1.uf_getUdata()
li_count = upperbound(ls_udata)

// tabsequence de l'item dont le n° est passé en paramètre (si ce n° est > 0) 
// 	(tabseq0 peut être 0 si cet item n'est pas modifiable)
li_tabseq0 = 0
IF ai_firstitem > 0 THEN
	li_tabseq0 = integer(adw_1.Describe("#" + string(ai_firstitem) + ".TabSequence"))
ELSE
	ai_firstitem = 1
END IF

// rechercher le premier item modifiable après celui passé en paramètre
FOR li_i = ai_firstitem TO li_count
	li_tabseq = integer(adw_1.Describe(ls_udata[li_i] + ".TabSequence"))
	ls_protect = adw_1.Describe(ls_udata[li_i] + ".Protect")
	IF li_tabseq > li_tabseq0 AND ls_protect = "0" THEN
		li_id = integer(adw_1.Describe(ls_udata[li_i] + ".ID"))
		return(li_id)
	END IF
NEXT

return(0)
end function

public function string uf_getcolumnname (uo_dw adw_1, string as_dbname);// parcourt toutes les columns du DW pour retrouver le nom de l'item sur base du nom dans la DB (passé en arg.)
// renvoie le nom de l'item si trouvé, chaîne vide si pas trouvé

integer li_c, li_nbcol
string ls_desc, ls_name, ls_dbname

as_dbName = gu_stringservices.uf_replaceall(as_dbName," ","")

li_nbcol = integer(adw_1.object.datawindow.column.count)
FOR li_c = 1 TO li_nbcol
	ls_desc = "#" + f_string(li_c) + ".dbName"
	ls_dbName = adw_1.Describe(ls_desc)
	IF upper(ls_dbName) = upper(as_dbname) THEN
		ls_desc = "#" + f_string(li_c) + ".Name"
		ls_name = adw_1.Describe(ls_desc)
		return(ls_name)
	END IF
NEXT

return("")
end function

public function integer uf_confirm_cancel (datawindow adw_dw[]);integer li_i, li_max
boolean lb_modif

li_max = UpperBound(adw_dw)
FOR li_i = 1 TO li_max
	IF adw_dw[li_i].DeletedCount() > 0 OR adw_dw[li_i].ModifiedCount() > 0 THEN 
		lb_modif = true
		exit
	end if
NEXT

IF lb_modif THEN 
	beep(1)
	IF li_max = 1 then
		return(gu_message.uf_query(is_text_confirmTitre, &
						string(adw_dw[1].DeletedCount()) + " " + is_text_deletedText + " " + is_text_et + " " + &
						string(adw_dw[1].ModifiedCount()) + &
						" créés/modifiés.~n" + is_text_confirmText, YesNoCancel!,1))
	ELSE
		return(gu_message.uf_query(is_text_confirmTitre, is_text_confirmText, YesNoCancel!,1))
	END IF
ELSE
	// pas besoin de sauver car rien n'a changé
	return(2)
END IF

end function

public function long uf_findduplicate (datawindow adw_1, long al_currentrow, string as_where);// recherche si la condition as_where est respectée dans le DW pour un autre record que al_currentrow
// return(-1) si erreur
// return(0) si un tel record n'existe pas
// return(row) : renvoie le 1er n° de row qui remplit la condition

long	ll_found

IF al_currentrow = 0 THEN 
	populateerror(20000,"")
	gu_message.uf_unexp("Argument al_currentrow = 0")
	return(-1)
END IF

// recherche depuis le 1er record
ll_found = adw_1.Find(as_where, 1, adw_1.RowCount())

// erreur
IF ll_found < 0 THEN 
	populateerror(20000,"")
	gu_message.uf_unexp("Erreur find " + as_where)
	return(-1)
END IF

// non trouvé
IF ll_found = 0 THEN return(ll_found)

// si record trouvé = record en cours (al_currentrow) et que ce n'est pas le dernier, continuer la recherche
// car il pourrait se trouver 1 record identique plus loin
IF ll_found = al_currentrow AND ll_found < adw_1.RowCount() THEN
	ll_found = adw_1.find(as_where, ll_found + 1, adw_1.RowCount())
END IF
IF ll_found > 0 AND ll_found <> al_currentrow THEN
	return(ll_found)
ELSE
	return(0)
END IF
end function

public subroutine uf_translatetext ();// initialiser les textes traduits
is_text_confirmTitre = f_translate_getlabel("TEXT_00125", "Confirmation")
is_text_confirmText = f_translate_getlabel("TEXT_00126", "Voulez-vous enregistrer les modifications en cours avant de quitter ?")
is_text_deletedText = f_translate_getlabel("TEXT_00127", "enregistrements ont été supprimés")
is_text_et = f_translate_getlabel("TEXT_00128", "et")
end subroutine

public function long uf_findduplicate (datastore ads_1, long al_currentrow, string as_where);// recherche si la condition as_where est respectée dans le DS pour un autre record que al_currentrow
// return(-1) si erreur
// return(0) si un tel record n'existe pas
// return(row) : renvoie le 1er n° de row qui remplit la condition

long	ll_found

IF al_currentrow = 0 THEN 
	populateerror(20000,"")
	gu_message.uf_unexp("Argument al_currentrow = 0")
	return(-1)
END IF

// recherche depuis le 1er record
ll_found = ads_1.Find(as_where, 1, ads_1.RowCount())

// erreur
IF ll_found < 0 THEN 
	populateerror(20000,"")
	gu_message.uf_unexp("Erreur find " + as_where)
	return(-1)
END IF

// non trouvé
IF ll_found = 0 THEN return(ll_found)

// si record trouvé = record en cours (al_currentrow) et que ce n'est pas le dernier, continuer la recherche
// car il pourrait se trouver 1 record identique plus loin
IF ll_found = al_currentrow AND ll_found < ads_1.RowCount() THEN
	ll_found = ads_1.find(as_where, ll_found + 1, ads_1.RowCount())
END IF
IF ll_found > 0 AND ll_found <> al_currentrow THEN
	return(ll_found)
ELSE
	return(0)
END IF
end function

public function integer uf_updatetransact (datawindow adw_1, datawindow adw_2, datawindow adw_3, datawindow adw_4, datawindow adw_5, datawindow adw_6, datawindow adw_7, datawindow adw_8, datawindow adw_9, datawindow adw_10, datawindow adw_11);return(uf_UpdateTransact({adw_1, adw_2, adw_3, adw_4, adw_5, adw_6, adw_7, adw_8, adw_9, adw_10, adw_11}))
end function

public function integer uf_updatetransact (datawindow adw_1, datawindow adw_2, datawindow adw_3, datawindow adw_4, datawindow adw_5, datawindow adw_6, datawindow adw_7, datawindow adw_8, datawindow adw_9, datawindow adw_10, datawindow adw_11, datawindow adw_12);return(uf_UpdateTransact({adw_1, adw_2, adw_3, adw_4, adw_5, adw_6, adw_7, adw_8, adw_9, adw_10, adw_11, adw_12}))
end function

public function integer uf_updatetransact (datawindow adw_1, datawindow adw_2, datawindow adw_3, datawindow adw_4, datawindow adw_5, datawindow adw_6, datawindow adw_7, datawindow adw_8, datawindow adw_9, datawindow adw_10, datawindow adw_11, datawindow adw_12, datawindow adw_13, datawindow adw_14, datawindow adw_15, datawindow adw_16, datawindow adw_17);return(uf_UpdateTransact({adw_1, adw_2, adw_3, adw_4, adw_5, adw_6, adw_7, adw_8, adw_9, adw_10, &
								  adw_11, adw_12, adw_13, adw_14, adw_15, adw_16, adw_17}))
end function

public function integer uf_updatetransact (datawindow adw_1, datawindow adw_2, datawindow adw_3, datawindow adw_4, datawindow adw_5, datawindow adw_6, datawindow adw_7, datawindow adw_8, datawindow adw_9, datawindow adw_10, datawindow adw_11, datawindow adw_12, datawindow adw_13);return(uf_UpdateTransact({adw_1, adw_2, adw_3, adw_4, adw_5, adw_6, adw_7, adw_8, adw_9, adw_10, adw_11, adw_12, adw_13}))
end function

public function integer uf_updatetransact (datawindow adw_1, datawindow adw_2, datawindow adw_3, datawindow adw_4, datawindow adw_5, datawindow adw_6, datawindow adw_7, datawindow adw_8, datawindow adw_9, datawindow adw_10, datawindow adw_11, datawindow adw_12, datawindow adw_13, datawindow adw_14);return(uf_UpdateTransact({adw_1, adw_2, adw_3, adw_4, adw_5, adw_6, adw_7, adw_8, adw_9, adw_10, &
								  adw_11, adw_12, adw_13, adw_14}))
end function

public function integer uf_updatetransact (datawindow adw_1, datawindow adw_2, datawindow adw_3, datawindow adw_4, datawindow adw_5, datawindow adw_6, datawindow adw_7, datawindow adw_8, datawindow adw_9, datawindow adw_10, datawindow adw_11, datawindow adw_12, datawindow adw_13, datawindow adw_14, datawindow adw_15);return(uf_UpdateTransact({adw_1, adw_2, adw_3, adw_4, adw_5, adw_6, adw_7, adw_8, adw_9, adw_10, &
		 						  adw_11, adw_12, adw_13, adw_14, adw_15}))
end function

public function integer uf_updatetransact (datawindow adw_1, datawindow adw_2, datawindow adw_3, datawindow adw_4, datawindow adw_5, datawindow adw_6, datawindow adw_7, datawindow adw_8, datawindow adw_9, datawindow adw_10, datawindow adw_11, datawindow adw_12, datawindow adw_13, datawindow adw_14, datawindow adw_15, datawindow adw_16);return(uf_UpdateTransact({adw_1, adw_2, adw_3, adw_4, adw_5, adw_6, adw_7, adw_8, adw_9, adw_10, &
		 						  adw_11, adw_12, adw_13, adw_14, adw_15, adw_16}))
end function

on uo_dwservices.create
call super::create
TriggerEvent( this, "constructor" )
end on

on uo_dwservices.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

event constructor;// initialiser les textes hors traduction (seront éventuellement traduits ultérieurement si l'application
// le nécessite par un appel à la fonction uf_setTranslateText)
is_text_confirmTitre = "Confirmation"
is_text_confirmText = "Voulez-vous enregistrer les modifications en cours avant de quitter ?"
is_text_deletedText = "enregistrements ont été supprimés"
is_text_et = "et"
end event

