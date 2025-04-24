//objectcomments Fenêtre de choix des critères de sélection et de tri (surtout utilisée dans les reports)
forward
global type w_selection from w_ancestor
end type
type tab_1 from tab within w_selection
end type
type tabpage_1 from userobject within tab_1
end type
type dw_1 from uo_datawindow_multiplerow within tabpage_1
end type
type tabpage_1 from userobject within tab_1
dw_1 dw_1
end type
type tabpage_2 from userobject within tab_1
end type
type st_2 from uo_statictext within tabpage_2
end type
type ddlb_tri from uo_dropdownlistbox within tabpage_2
end type
type dw_tri from uo_datawindow_multiplerow within tabpage_2
end type
type tabpage_2 from userobject within tab_1
st_2 st_2
ddlb_tri ddlb_tri
dw_tri dw_tri
end type
type tab_1 from tab within w_selection
tabpage_1 tabpage_1
tabpage_2 tabpage_2
end type
type dw_2 from uo_dw within w_selection
end type
type st_1 from statictext within w_selection
end type
type ddlb_1 from dropdownlistbox within w_selection
end type
type cb_sql from uo_cb within w_selection
end type
type cb_count from uo_cb within w_selection
end type
type cb_delete from uo_cb within w_selection
end type
type cb_add from uo_cb within w_selection
end type
type cb_insert from uo_cb within w_selection
end type
type cb_cancel from uo_cb within w_selection
end type
type cb_ok from uo_cb within w_selection
end type
end forward

global type w_selection from w_ancestor
integer x = 283
integer y = 496
integer width = 2898
integer height = 1156
string title = "Sélection"
windowtype windowtype = response!
long backcolor = 79741120
event ue_supprimer ( )
event ue_ajouter ( )
tab_1 tab_1
dw_2 dw_2
st_1 st_1
ddlb_1 ddlb_1
cb_sql cb_sql
cb_count cb_count
cb_delete cb_delete
cb_add cb_add
cb_insert cb_insert
cb_cancel cb_cancel
cb_ok cb_ok
end type
global w_selection w_selection

type variables
string	is_reportName, is_originalselect, is_modele, is_insertionpoint, is_evalmsg
integer	ii_par, ii_preselindex, ii_nbgroups
dw_1		idw_1
dw_tri	idw_tri
boolean	ib_trienabled, ib_appendOrderBy, ib_buttons
str_params	istr_params
decimal{0}	id_rptseq
uo_wait		iu_wait
end variables

forward prototypes
public function integer wf_par ()
public function long wf_insertcritere ()
public function long wf_inserttri ()
public function integer wf_deletecritere ()
public subroutine wf_restoretri (character ac_type)
public function string wf_generateorder ()
public function string wf_generatenewselect ()
public function string wf_generatenewselect (ref string as_where, ref string as_order)
public subroutine wf_inittri (long al_row)
public function integer wf_deletetri ()
public subroutine wf_initnewtri (long al_row)
public function integer wf_check_tri ()
public function long wf_addtri ()
public function integer wf_check_criteres ()
public function string wf_generatewherefr ()
public subroutine wf_setmask (long al_row)
public function string wf_generatewhere ()
public function long wf_addcritere ()
public subroutine wf_initnewrow (long al_row)
public subroutine wf_restorecrit (character ac_type)
public subroutine wf_initcrit (long al_row, string as_crit)
public function string wf_stringvalfr (long al_row)
public function string wf_stringval (long al_row)
end prototypes

public function integer wf_par ();// compter les parenthèses ouvertes et fermées (dans les critères utilisés seulement)

string	ls_datatype, ls_operateur
long		ll_row, ll_nrows
integer	li_par, li_par1, li_par2

ll_nrows = idw_1.RowCount()
FOR ll_row = 1 TO ll_nrows
	ls_datatype = idw_1.Object.datatype[ll_row]
	IF ls_datatype = "L" THEN
		ls_operateur = idw_1.Object.operateur_long[ll_row]
	ELSE
		ls_operateur = idw_1.Object.operateur[ll_row]
	END IF
	// s'il n'y a pas de champ ou d'opérateur, on ignore le critère
	IF IsNull(idw_1.Object.critere[ll_row]) OR IsNull(ls_operateur) THEN
		continue
	END IF
	li_par1 = LenA(trim(idw_1.object.par1[ll_row]))
	IF NOT isnull(li_par1) THEN li_par = li_par + li_par1
	li_par2 = LenA(trim(idw_1.object.par2[ll_row]))
	IF NOT isnull(li_par2) THEN li_par = li_par - li_par2
NEXT
return(li_par)

end function

public function long wf_insertcritere ();long	ll_row

IF idw_1.accepttext() = -1 THEN
	idw_1.setfocus()
	return(-1)
END IF
ll_row = idw_1.event ue_insertrow()
IF ll_row <> -1 THEN
	wf_initnewrow(ll_row)
END IF
return(ll_row)
end function

public function long wf_inserttri ();long	ll_row
	
IF idw_tri.accepttext() = -1 THEN
	idw_tri.setfocus()
	return(-1)
END IF
ll_row = idw_tri.event ue_insertrow()
IF ll_row <> -1 THEN
	wf_initnewtri(ll_row)
END IF
return(ll_row)
end function

public function integer wf_deletecritere ();integer	li_status

li_status = idw_1.event ue_delete()
IF li_status = 2 THEN
	wf_initnewrow(1)
END IF
return(li_status)
end function

public subroutine wf_restoretri (character ac_type);// s'il n'y a pas de sélection antérieure, utiliser la sélection par défaut
long	ll_nbrows,ll_row

CHOOSE CASE ac_type
	// rappeler les critères de tri par défaut pour le report en cours
	CASE "D"
		idw_tri.retrieve(gs_username, is_modele, "D")
	// ou rappeler les derniers critères de tri utilisés par l'utilisateur choisi pour le report en cours
	CASE "U"
		idw_tri.retrieve(dw_2.gettext(), is_modele, "U")
	CASE ELSE
		idw_tri.reset()
END CHOOSE

// s'il n'y a pas de critères de tri par défaut ou d'une utilisation antérieure, créer un critère vide
ll_nbrows = idw_tri.RowCount()
IF ll_nbrows = 0 THEN
	wf_initnewtri(idw_tri.event ue_addrow())
ELSE
// changer le status en "newmodified" pour forcer la réécriture de tous les critères à l'update
	FOR ll_row = 1 TO ll_nbrows
		idw_tri.SetItemStatus(ll_row, 0, Primary!, NewModified!)
	NEXT		
	idw_tri.scrolltorow(1)
END IF

end subroutine

public function string wf_generateorder ();integer	li_status
long		ll_nrows, ll_row
string	ls_order, ls_asc

li_status = wf_check_tri()
IF li_status = -1 THEN
	setnull(ls_order)
	return(ls_order)
END IF

/* si la fonction check renvoie 0, cela veut dire qu'il n'y a pas de critères de tri donc on sort directement */
IF li_status = 0 THEN
	return("")
END IF

// construction du order by (sans le mot-clé 'order by' lui-même)
ll_nrows = idw_tri.RowCount()
FOR ll_row = 1 TO ll_nrows
	ls_asc = ""
	IF idw_tri.Object.ordre_1[ll_row] = "N" THEN ls_asc = "DESC"
	IF LenA(ls_order) > 0 THEN ls_order = ls_order + " ,"
	ls_order = ls_order + idw_tri.Object.critere_1[ll_row] + " " + ls_asc
NEXT

return(ls_order)
end function

public function string wf_generatenewselect ();string	ls_where, ls_order
return(wf_generatenewselect(ls_where, ls_order))
end function

public function string wf_generatenewselect (ref string as_where, ref string as_order);// génère l'ordre SQL complet
// renvoie une string contenant l'ordre SQL ou une string nulle en cas de problème

string	ls_morewhere, ls_suite, ls_newselect, ls_orderby

// si pas d'ordre SQL initial, il n'y a rien a faire
// MODIFICATION 22/12/2006 : on garnit quand même le where et le order by correspondant à la sélection
// --> voir + loin
// IF len(trim(is_originalselect)) = 0 THEN
// 	return("")
// END IF

// générer la clause where correspondant à la sélection
ls_morewhere = wf_generatewhere()
as_where = ls_morewhere
IF IsNull(ls_morewhere) THEN
	gu_message.uf_error("Problème de génération du WHERE")
	return(gu_c.s_null)
END IF

// générer la clause order by correspondant à la sélection
IF ib_trienabled THEN
	ls_orderby = wf_generateorder()
	as_order = ls_orderby
	IF IsNull(ls_orderby) THEN
		gu_message.uf_error("Problème de génération du ORDER BY")
		return(gu_c.s_null)
	END IF
ELSE
	ls_orderby=""
END IF

// suite modif du 22/12/2006 (voir + haut) si pas d'ordre SQL initial
IF LenA(trim(is_originalselect)) = 0 THEN
	return("")
END IF

// ajouter la sélection et les critères de tri au select de départ
// PCO 17/08/2020 : replacer or append order by
// ls_newselect = f_modifysql(is_originalselect, ls_morewhere, ls_orderby, is_insertionpoint)
IF ib_appendOrderBy THEN
	ls_newselect = f_modifysql2(is_originalselect, ls_morewhere, ls_orderby, FALSE, is_insertionpoint)
ELSE
	ls_newselect = f_modifysql2(is_originalselect, ls_morewhere, ls_orderby, TRUE, is_insertionpoint)
END IF

// renvoyer le nouvel ordre SQL complet
return(ls_newselect)
end function

public subroutine wf_inittri (long al_row);idw_tri.Object.type[al_row] = "U"
idw_tri.Object.username[al_row] = gs_username
idw_tri.Object.modele[al_row] = is_modele

end subroutine

public function integer wf_deletetri ();integer	li_status

li_status = idw_tri.event ue_delete()
IF li_status = 2 THEN
	wf_initnewtri(1)
END IF
return(li_status)
end function

public subroutine wf_initnewtri (long al_row);idw_tri.Object.username[al_row] = gs_username
idw_tri.Object.modele[al_row] = is_modele
idw_tri.Object.type[al_row] = "U"
idw_tri.Object.ordre[al_row] = "O"
idw_tri.Object.groupe[al_row] = "N"
idw_tri.Object.newpage[al_row] = "N"
idw_tri.Object.c_pic[al_row] = "..\bmp\disablednocheck.bmp"
end subroutine

public function integer wf_check_tri ();// vérification de validité des critères de tri
// return(-1) en cas d'erreur
// return(0) si pas de critères de tri
// return(1) s'il y a des critères et qu'ils sont corrects
long		ll_nrows, ll_row

IF idw_tri.accepttext() = -1 THEN
	tab_1.SelectTab(2)
	idw_tri.SetFocus()
	return(-1)
END IF

ll_nrows = idw_tri.RowCount()

/* contrôle de validité de tous les critères (il faut que le nom du champ soit spécifié
pour prendre le critère en considération */
FOR ll_row = 1 TO ll_nrows
	// s'il n'y a pas de champ, on supprime le critère
	IF IsNull(idw_tri.Object.critere_1[ll_row]) THEN
		idw_tri.RowsDiscard(ll_row, ll_row, PRIMARY!)
		ll_nrows = ll_nrows - 1
		ll_row = ll_row - 1
		continue
	ELSE
		IF idw_tri.event ue_checkrow(ll_row) = -1 THEN
			tab_1.SelectTab(2)
			idw_tri.SetFocus()
			return(-1)
		END IF
	END IF
NEXT

/* si tous les critères ont été "discardés" ici au dessus, on en recrée un vide car cela veut dire
   qu'il n'y a aucun critère (ce qui n'est pas une erreur) */ 
IF ll_nrows = 0 THEN
	wf_addtri()
	return(0)
END IF
return(1)
end function

public function long wf_addtri ();long	ll_row
	
IF idw_tri.accepttext() = -1 THEN
	idw_tri.setfocus()
	return(-1)
END IF
ll_row = idw_tri.event ue_addrow()
IF ll_row <> -1 THEN
	wf_initnewtri(ll_row)
END IF
return(ll_row)
end function

public function integer wf_check_criteres ();// vérification de validité des critères de sélection
// return(-1) en cas d'erreur
// return(0) si pas de critères
// return(1) s'il y a des critères et qu'ils sont corrects
long	ll_nrows, ll_row
string	ls_operateur

IF idw_1.accepttext() = -1 THEN
	tab_1.SelectTab(1)
	idw_1.SetFocus()
	return(-1)
END IF

ll_nrows = idw_1.RowCount()

/* contrôle de validité de tous les critères (il faut au moins que le nom du champ et l'opérateur soit spécifiés
pour prendre le critère en considération */
FOR ll_row = 1 TO ll_nrows
	// s'il n'y a pas de champ ou d'opérateur, on supprime le critère
	IF idw_1.Object.datatype[ll_row] = "L" THEN
		ls_operateur = upper(idw_1.Object.operateur_long[ll_row])
	ELSE
		ls_operateur = upper(idw_1.Object.operateur[ll_row])
	END IF
	IF IsNull(idw_1.Object.critere[ll_row]) OR IsNull(ls_operateur) THEN
		idw_1.RowsDiscard(ll_row, ll_row, PRIMARY!)
		ll_nrows = ll_nrows - 1
		ll_row = ll_row - 1
		continue
	ELSE
		IF idw_1.event ue_checkrow(ll_row) = -1 THEN
			tab_1.SelectTab(1)
			idw_1.SetFocus()
			return(-1)
		END IF
	END IF
NEXT

// contrôle cohérence entre parenthèses ouvertes et fermées
IF wf_par() <> 0 THEN
	gu_message.uf_error("Parenthèses incorrectes")
	tab_1.SelectTab(1)
	idw_1.SetFocus()
	return(-1)
END IF

/* si tous les critères ont été "discardés" ici au dessus, on en recrée un vide car cela veut dire
   qu'il n'y a aucun critère (ce qui n'est pas une erreur) */ 
IF ll_nrows = 0 THEN
	wf_addcritere()
	return(0)
END IF

return(1)
end function

public function string wf_generatewherefr ();integer	li_status
long		ll_nrows, ll_row
string	ls_par1, ls_par2, ls_valeur, ls_datatype, ls_operateur, &
			ls_wherefr, ls_operateurfr, ls_criterefr, ls_connectfr

li_status = wf_check_criteres()
IF li_status = -1 THEN
	setnull(ls_wherefr)
	return(ls_wherefr)
END IF

/* si la fonction check renvoie 0, cela veut dire qu'il n'y a pas de critères donc on sort directement */
IF li_status = 0 THEN
	return("")
END IF

// construction de la sélection en français
ll_nrows = idw_1.RowCount()
FOR ll_row = 1 TO ll_nrows
	ls_datatype = idw_1.Object.datatype[ll_row]
	IF ls_datatype = "L" THEN
		ls_operateur = upper(idw_1.Object.operateur_long[ll_row])
		ls_operateurfr = idw_1.Describe("Evaluate('LookUpDisplay(operateur_long)'," + string(ll_row) + ")")
	ELSE
		ls_operateur = upper(idw_1.Object.operateur[ll_row])
		// on prend le texte affiché pour la plupart des opérateurs, mais pour certains on modifie un peu
		CHOOSE CASE ls_operateur
			CASE "BETWEEN"
				ls_operateurfr = "entre"
			CASE "IN"
				ls_operateurfr = "est dans la liste"
			CASE "NOT IN"
				ls_operateurfr = "n'est pas dans la liste"
			CASE ELSE
				ls_operateurfr = lower(idw_1.Describe("Evaluate('LookUpDisplay(operateur)'," + string(ll_row) + ")"))
		END CHOOSE
	END IF
	IF LenA(ls_wherefr) = 0 THEN
		ls_connectfr = " "
	ELSE
		ls_connectfr = idw_1.Describe("Evaluate('LookUpDisplay(connecteur)'," + string(ll_row - 1) + ")")
	END IF
	ls_par1 = ""
	ls_par2 = ""
	IF NOT IsNull(idw_1.Object.par1[ll_row]) THEN
		ls_par1 = idw_1.Object.par1[ll_row]
	END IF
	IF NOT IsNull(idw_1.Object.par2[ll_row]) THEN
		ls_par2 = idw_1.Object.par2[ll_row]
	END IF
		
	ls_valeur = wf_stringvalfr(ll_row)
	ls_criterefr = idw_1.Describe("Evaluate('LookUpDisplay(critere)'," + string(ll_row) + ")")
	ls_wherefr = ls_wherefr + " " + ls_connectfr + " " + ls_par1 + ls_criterefr + " " + ls_operateurfr
	// les opérateurs de type "IS NULL" ou "IS NOT NULL" ne nécessitent pas de valeur, les autres bien					
	IF	PosA(ls_operateur,"NULL") > 0 THEN
		ls_wherefr = ls_wherefr + ls_par2
	ELSE
		ls_wherefr = ls_wherefr + " " + ls_valeur + ls_par2
	END IF
NEXT

return(trim(ls_wherefr))
end function

public subroutine wf_setmask (long al_row);string	ls_operateur, ls_err

IF al_row <= 0 OR al_row > idw_1.rowCount() THEN return

IF idw_1.object.datatype[al_row] = "L" THEN
	ls_operateur = upper(idw_1.object.operateur_long[al_row])
ELSE
	ls_operateur = upper(idw_1.object.operateur[al_row])
END IF

// pour les opérateurs like, between et in, on utilise un masque général acceptant tout
// et uniquement pour 'valeur_string' car c'est celui là qui est utilisé quelque soit le type de critère
IF ls_operateur = "LIKE" OR ls_operateur = "NOT LIKE" OR ls_operateur = "BETWEEN" OR &
	ls_operateur = "IN" OR ls_operateur = "NOT IN" THEN
		idw_1.modify("valeur_string.editmask.mask='" + FillA("X",255) + "'")
else
// masque = format du critère sélectionné (ou un masque par défaut si pas de masque particulier)
	idw_1.modify("valeur_string.editmask.mask='" + FillA("X",255) + "~tformat'")
	idw_1.modify("valeur_number.editmask.mask='###,###,###,###.000000~tformat'")
END IF

end subroutine

public function string wf_generatewhere ();integer	li_status
long		ll_nrows, ll_row
string	ls_par1, ls_par2, ls_where, ls_connect, ls_valeur, ls_datatype, ls_operateur, ls_ucase

li_status = wf_check_criteres()
IF li_status = -1 THEN
	setnull(ls_where)
	return(ls_where)
END IF

/* si la fonction check renvoie 0, cela veut dire qu'il n'y a pas de critères donc on sort directement */
IF li_status = 0 THEN
	return("")
END IF

// construction du where (sans le mot-clé 'where' lui-même)
ll_nrows = idw_1.RowCount()
FOR ll_row = 1 TO ll_nrows
	ls_datatype = idw_1.Object.datatype[ll_row]
	ls_ucase = idw_1.Object.ucase[ll_row]
	IF ls_datatype = "L" THEN
		ls_operateur = upper(idw_1.Object.operateur_long[ll_row])
	ELSE
		ls_operateur = upper(idw_1.Object.operateur[ll_row])
	END IF
	IF LenA(ls_where) = 0 THEN
		ls_connect = " "
	ELSE
		ls_connect = idw_1.Object.connecteur[ll_row - 1]
	END IF
	ls_par1 = ""
	ls_par2 = ""
	IF NOT IsNull(idw_1.Object.par1[ll_row]) THEN
		ls_par1 = idw_1.Object.par1[ll_row]
	END IF
	IF NOT IsNull(idw_1.Object.par2[ll_row]) THEN
		ls_par2 = idw_1.Object.par2[ll_row]
	END IF
		
	ls_valeur = wf_stringval(ll_row)
	
	// annulation de la différence MAJ/MIN et des caractères accentués (si UCASE="O" dans DETAIL_CRITERE)
	IF ls_datatype = "S" AND ls_ucase = "O" THEN
		ls_where = ls_where + " " + ls_connect + " " + ls_par1 + &
			 "translate(Upper(" + idw_1.Object.critere[ll_row] + "),'ÀÂÄÉÈÊËÎÖÔÜÙÛÇ','AAAEEEEIOOUUUC')" + &
			 " " + ls_operateur
	ELSE
		ls_where = ls_where + " " + ls_connect + " " + ls_par1 + &
					  idw_1.Object.critere[ll_row] + " " + ls_operateur
	END IF
	
	// les opérateurs de type "IS NULL" ou "IS NOT NULL" ne nécessitent pas de valeur, les autres bien					
	IF	PosA(ls_operateur,"NULL") > 0 THEN
		ls_where = ls_where + ls_par2
	ELSE
		IF ls_operateur = "BETWEEN" OR ls_operateur = "IN" OR ls_operateur = "NOT IN" THEN
			ls_where = ls_where + " " + ls_valeur + ls_par2
		ELSE
			IF ls_datatype = "N" THEN
				ls_where = ls_where + " " + ls_valeur + ls_par2
			ELSE
				ls_where = ls_where + " '" + ls_valeur + "'" + ls_par2
			END IF
		END IF
	END IF
NEXT

return(trim(ls_where))
end function

public function long wf_addcritere ();long	ll_row

IF idw_1.accepttext() = -1 THEN
	idw_1.setfocus()
	return(-1)
END IF
ll_row = idw_1.event ue_addrow()
IF ll_row <> -1 THEN
	wf_initnewrow(ll_row)
END IF
return(ll_row)
end function

public subroutine wf_initnewrow (long al_row);idw_1.Object.connecteur[al_row] = "and"
idw_1.Object.valeur_string[al_row] = ""
idw_1.Object.valeur_number[al_row] = 0
idw_1.Object.obligatoire[al_row] = "N"
idw_1.Object.valeurmodifiable[al_row] = "O"



end subroutine

public subroutine wf_restorecrit (character ac_type);long	ll_nbrows, ll_row
uo_ds	lds_selection
string	ls_critere

CHOOSE CASE ac_type
	// Appeler les critères par défaut pour le report en cours...
	CASE "D"
		idw_1.retrieve(gs_username, is_modele, "D")
		
	// ...ou rappeler les derniers critères utilisés par l'utilisateur choisi pour le report en cours.
	// Si pas d'anciens critères pour l'utilisateur en cours, afficher ceux par défaut.
	// PCO 11/09/2018 : s'il y a des critères obligatoires dans la sélection par défaut,
	// s'assurer qu'ils sont bien présents lors du rappel d'une sélection précédente. C'est utile
	// dans le cas où les critères par défaut ont changé dans la version de l'application.
	CASE "U"
		// 1. Lire sélection par défaut et ne conserver que les critères obligatoires
		lds_selection = create uo_ds
		lds_selection.dataobject = idw_1.dataobject
		lds_selection.setTransobject(SQLCA)
		lds_selection.retrieve(gs_username, is_modele, "D")
		lds_selection.setFilter("obligatoire='O'")
		lds_selection.filter()
		lds_selection.rowCount()
		// 2. relire critères utilisateurs
		IF	idw_1.retrieve(dw_2.gettext(), is_modele, "U") = 0 THEN
			idw_1.retrieve(gs_username, is_modele, "D")
		END IF
		// 3. vérifier si les critères obligatoires de la sélection par défaut sont présents dans la sélection rechargée
		FOR ll_row = 1 TO lds_selection.rowCount()
			ls_critere = lds_selection.object.critere[ll_row]
			IF idw_1.find("critere='" + ls_critere + "'", 1, 999) = 0 THEN
				// 4. critère obligatoire pas présent dans la sélection rechargée : l'y ajouter et l'initialiser
				lds_selection.rowscopy(ll_row, ll_row, Primary!, idw_1, 999, Primary!)
				wf_initcrit(idw_1.rowcount(), ls_critere)
			END IF
		NEXT
	CASE ELSE
		idw_1.reset()
END CHOOSE

// s'il n'y a pas de critères par défaut ou d'une utilisation antérieure, créer un critère vide
ll_nbrows = idw_1.RowCount()
IF ll_nbrows = 0 THEN
	wf_initnewrow(idw_1.event ue_addrow())
ELSE
// changer le status en "newmodified" pour forcer la réécriture de tous les critères à l'update
	FOR ll_row = 1 TO ll_nbrows
		idw_1.SetItemStatus(ll_row, 0, Primary!, NewModified!)
	NEXT		
	idw_1.scrolltorow(1)
END IF

// idem pour les critères de tri
wf_restoretri(ac_type)
end subroutine

public subroutine wf_initcrit (long al_row, string as_crit);string	ls_datatype, ls_format, ls_unique, ls_ecran_aide, ls_param_aide, ls_validation, ls_ucase
decimal	ld_min, ld_max

SELECT report_critere.usunique, detail_critere.datatype, detail_critere.min, detail_critere.max, 
		 detail_critere.format, detail_critere.ecran_aide, detail_critere.param_aide, 
		 detail_critere.validation, detail_critere.ucase
	into :ls_unique, :ls_datatype, :ld_min, :ld_max, :ls_format, :ls_ecran_aide, :ls_param_aide, 
		  :ls_validation, :ls_ucase
	FROM report_critere, detail_critere  
	WHERE (detail_critere.num_detail_critere = report_critere.num_detail_critere) and  
     	    (report_critere.report = :is_reportname) and 
			 (report_critere.critere = :as_crit) USING ESQLCA;
f_check_sql(ESQLCA)

idw_1.Object.type[al_row] = "U"
idw_1.Object.username[al_row] = gs_username
idw_1.Object.modele[al_row] = is_modele
idw_1.Object.usunique[al_row] = ls_unique
idw_1.Object.datatype[al_row] = ls_datatype
idw_1.Object.min[al_row] = ld_min
idw_1.Object.max[al_row] = ld_max	
idw_1.Object.format[al_row] = ls_format
idw_1.Object.ecran_aide[al_row] = ls_ecran_aide
idw_1.Object.param_aide[al_row] = ls_param_aide
idw_1.Object.validation[al_row] = ls_validation
idw_1.Object.ucase[al_row] = ls_ucase

IF f_IsEmptyString(idw_1.Object.operateur[al_row]) THEN
	idw_1.Object.operateur[al_row] = "="
END IF

wf_setmask(al_row)

end subroutine

public function string wf_stringvalfr (long al_row);// convertit la valeur en string, quel que soit son datatype

string	ls_operateur, ls_val, ls_format
decimal	ld_val

IF idw_1.Object.datatype[al_row] = "L" THEN
	ls_operateur = upper(idw_1.Object.operateur_long[al_row])
ELSE
	ls_operateur = upper(idw_1.Object.operateur[al_row])
END IF

CHOOSE CASE idw_1.Object.datatype[al_row]
	CASE "N"
		CHOOSE CASE ls_operateur
			CASE "LIKE", "NOT LIKE", "BETWEEN", "IN", "NOT IN"
				ls_val = idw_1.Describe("Evaluate('LookUpDisplay(valeur_string)'," + string(al_row) + ")")
			CASE ELSE
				ld_val = idw_1.object.valeur_number[al_row]
				ls_format = trim(idw_1.object.format[al_row])
				IF f_IsEmptyString(ls_format) THEN
					ls_val = string(ld_val)
				ELSE
					ls_val = string(ld_val, ls_format)
				END IF
		END CHOOSE
	CASE "D"
		CHOOSE CASE ls_operateur
			CASE "LIKE", "NOT LIKE", "BETWEEN", "IN", "NOT IN"
				ls_val = idw_1.Describe("Evaluate('LookUpDisplay(valeur_string)'," + string(al_row) + ")")
			CASE ELSE
				ls_val = idw_1.Describe("Evaluate('LookUpDisplay(valeur_date)'," + string(al_row) + ")")
		END CHOOSE
	CASE ELSE
		ls_val = idw_1.Describe("Evaluate('LookUpDisplay(valeur_string)'," + string(al_row) + ")")
END CHOOSE
ls_val = gu_stringservices.uf_replaceall(ls_val, "~"", "~~~"")

return(trim(ls_val))
end function

public function string wf_stringval (long al_row);// convertit la valeur en string, quel que soit son datatype

string	ls_operateur, ls_val1, ls_val2, ls_in[], ls_valeur
long		ll_pos
date		ld_dt1, ld_dt2
dec		ld_val1, ld_val2
integer	li_i

IF idw_1.Object.datatype[al_row] = "L" THEN
	ls_operateur = upper(idw_1.Object.operateur_long[al_row])
ELSE
	ls_operateur = upper(idw_1.Object.operateur[al_row])
END IF

CHOOSE CASE idw_1.Object.datatype[al_row]
	CASE "N"
		CHOOSE CASE ls_operateur
			CASE "LIKE", "NOT LIKE"
				// return(idw_1.Object.valeur_string[al_row])
				return("'" + idw_1.Object.valeur_string[al_row] + "'")
			CASE "BETWEEN"
				ll_pos = PosA(upper(idw_1.Object.valeur_string[al_row]), "ET")
				ld_val1 = dec(LeftA(idw_1.Object.valeur_string[al_row],ll_pos - 1))
				ld_val2 = dec(MidA(idw_1.Object.valeur_string[al_row],ll_pos+3))
				// return("'" + string(ld_val1) + "' and '" + string(ld_val2) + "'")
				return(string(ld_val1) + " and " + string(ld_val2))
			CASE "IN", "NOT IN"
				f_parse(string(idw_1.Object.valeur_string[al_row]), ',', ls_in)
				FOR li_i = 1 TO upperbound(ls_in)
					// ls_val1 = ls_val1 + "'" + ls_in[li_i] + "',"
					ls_val1 = ls_val1 + ls_in[li_i] + ","
				NEXT
				// enlever la dernière virgule, non nécessaire
				ls_val1 = LeftA(ls_val1, LenA(ls_val1) - 1)
				return("(" + ls_val1 + ")")
			CASE ELSE
				IF idw_1.Object.valeur_number[al_row] = round(idw_1.Object.valeur_number[al_row],0) THEN
					ld_val1 = round(idw_1.Object.valeur_number[al_row], 0)
				ELSE
					ld_val1 = idw_1.Object.valeur_number[al_row]
				END IF
				return(string(ld_val1))
		END CHOOSE
	CASE "D"
		CHOOSE CASE ls_operateur
			CASE "LIKE", "NOT LIKE"
				return(idw_1.Object.valeur_string[al_row])
			CASE "BETWEEN"
				ll_pos = PosA(upper(idw_1.Object.valeur_string[al_row]), "ET")
				ld_dt1 = date(LeftA(idw_1.Object.valeur_string[al_row],ll_pos - 1))
				ld_dt2 = date(MidA(idw_1.Object.valeur_string[al_row],ll_pos+3))
				return("'" + string(ld_dt1) + "' and '" + string(ld_dt2) + "'")
			CASE "IN", "NOT IN"
				f_parse(string(idw_1.Object.valeur_string[al_row]), ',', ls_in)
				FOR li_i = 1 TO upperbound(ls_in)
					ls_val1 = ls_val1 + "'" + string(date(ls_in[li_i])) + "',"
				NEXT
				// enlever la dernière virgule, non nécessaire
				ls_val1 = LeftA(ls_val1, LenA(ls_val1) - 1)
				return("(" + ls_val1 + ")")
			CASE ELSE
				return(string(idw_1.Object.valeur_date[al_row], "dd/mm/yyyy"))
		END CHOOSE
	CASE ELSE
		// doubler les singles quotes (format Oracle)
		ls_valeur = gu_stringservices.uf_replaceall(idw_1.Object.valeur_string[al_row], "'", "''")
		// annulation de la différence MAJ/MIN et des caractères accentués
		IF idw_1.Object.ucase[al_row] = "O" THEN
			// PCO 29/03/2017 : utilisation fonction spécifique dans uo_stringservices qui prend + d'accents en charge
			// ls_valeur = upper(ls_valeur)
			// ls_valeur = gu_stringservices.uf_replaceall(ls_valeur, &
			//	{"À","Â","É","È","Ê","Î","Ô","Ù","Û","Ç"}, {"A","A","E","E","E","I","O","U","U","C"})
			ls_valeur = gu_stringservices.uf_removeaccent(ls_valeur, "U")
		END IF

		CHOOSE CASE ls_operateur
			CASE "BETWEEN"
				ll_pos = PosA(upper(ls_valeur), "ET")
				ls_val1 = trim(LeftA(ls_valeur,ll_pos - 1))
				ls_val2 = trim(MidA(ls_valeur,ll_pos+3))
				return("'" + ls_val1 + "' and '" + ls_val2 + "'")
			CASE "IN", "NOT IN"
				f_parse(trim(string(ls_valeur)), ',', ls_in)
				FOR li_i = 1 TO upperbound(ls_in)
					ls_val1 = ls_val1 + "'" + ls_in[li_i] + "',"
				NEXT
				// enlever la dernière virgule, non nécessaire
				ls_val1 = LeftA(ls_val1, LenA(ls_val1) - 1)
				return("(" + ls_val1 + ")")
			CASE ELSE
				return(trim(ls_valeur))
		END CHOOSE
END CHOOSE

end function

on w_selection.create
int iCurrent
call super::create
this.tab_1=create tab_1
this.dw_2=create dw_2
this.st_1=create st_1
this.ddlb_1=create ddlb_1
this.cb_sql=create cb_sql
this.cb_count=create cb_count
this.cb_delete=create cb_delete
this.cb_add=create cb_add
this.cb_insert=create cb_insert
this.cb_cancel=create cb_cancel
this.cb_ok=create cb_ok
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.tab_1
this.Control[iCurrent+2]=this.dw_2
this.Control[iCurrent+3]=this.st_1
this.Control[iCurrent+4]=this.ddlb_1
this.Control[iCurrent+5]=this.cb_sql
this.Control[iCurrent+6]=this.cb_count
this.Control[iCurrent+7]=this.cb_delete
this.Control[iCurrent+8]=this.cb_add
this.Control[iCurrent+9]=this.cb_insert
this.Control[iCurrent+10]=this.cb_cancel
this.Control[iCurrent+11]=this.cb_ok
end on

on w_selection.destroy
call super::destroy
destroy(this.tab_1)
destroy(this.dw_2)
destroy(this.st_1)
destroy(this.ddlb_1)
destroy(this.cb_sql)
destroy(this.cb_count)
destroy(this.cb_delete)
destroy(this.cb_add)
destroy(this.cb_insert)
destroy(this.cb_cancel)
destroy(this.cb_ok)
end on

event ue_closebyxaccepted;cb_cancel.Event clicked()
end event

event ue_open;call super::ue_open;// ATTENTION : on réserve les 20 premiers paramètres d'INPUT aux paramètres existant et à ceux qui
// pourraient suivre. Si un descendant de W_SELECTION doit lui-même passer des paramètres, il doit
// utiliser les paramètres à partir de 21 !!!!

/* critères INPUT
	1. string	nom du report (ou du report duquel il faut utiliser les critères de sélection et de tri prédéfinis)
	2. string	nom du modèle
	3. string	ordre SQL d'origine
	4. boolean	TRUE=fenêtre de sélection est visible
					FALSE=fenêtre de sélection est non visible et minimized (commandée directement par le programme appelant)
	5. boolean	TRUE=l'onglet TRI est accessible
					FALSE=l'onglet TRI est inaccessible et on ne modifie pas la clause ORDER BY d'origine 
	6. decimal{0} : n° de séquence unique attribué au report en cours
	7. boolean	TRUE=les boutons INSERER, AJOUTER, SUPPRIMER sont enabled
					FALSE=ces boutons sont disabled
	8. string	point d'insertion du where (si nécessaire)
	9. string	message à afficher quand on demande d'évaluer le nombre de records concernés par la sélection
	10. integer = nombre de groupes possibles au choix, 0 = choix des groupes pas possible
	// PCO 17/09/2020
	11. boolean : FALSE(default)=remplacer ORDER BY d'origine, TRUE=compléter ORDER BY d'origine
*/
long					ll_row, ll_nbrows, ll_pos
DatawindowChild	ldwc_critere, ldwc_user
integer	li_id, li_saveid, li_i
string	ls_critere, ls_ordre, ls_tri

istr_params = Message.PowerObjectParm

iu_wait = CREATE uo_wait

// ne pas logger de message lors de l'utilisation de cette fenêtre
wf_logusage(FALSE)

f_centerInMdi(this)

IF UpperBound(istr_params.a_param) < 20 THEN
	FOR li_i = UpperBound(istr_params.a_param) + 1 TO 20
		SetNull(istr_params.a_param[li_i])
	NEXT
END IF

idw_1 = tab_1.tabpage_1.dw_1
idw_tri = tab_1.tabpage_2.dw_tri

idw_1.object.valeur_string.format = FillA("@", 255)

idw_1.uf_displaymessage(TRUE)

is_reportName = upper(string(istr_params.a_param[1]))
// PCO 28/01/2019 : modèle = 20 caractères, tronquer pour être sûr
is_modele = left(string(istr_params.a_param[2]), 20)
is_originalselect = string(istr_params.a_param[3])
ib_trienabled = istr_params.a_param[5]
id_rptseq = istr_params.a_param[6]
is_insertionpoint = istr_params.a_param[8]
is_evalmsg = istr_params.a_param[9]

// PCO 17/09/2020
IF IsNull(istr_params.a_param[11]) THEN
	ib_appendOrderBy = FALSE
ELSE
	ib_appendOrderBy = istr_params.a_param[11]
END IF

IF IsNull(istr_params.a_param[7]) THEN
	ib_buttons = TRUE
ELSE
	ib_buttons = istr_params.a_param[7]
END IF

IF NOT ib_buttons THEN
	cb_add.enabled = FALSE
	cb_insert.enabled = FALSE
	cb_delete.enabled = FALSE
END IF

IF NOT istr_params.a_param[4] THEN
	this.visible = istr_params.a_param[4]
	this.windowstate = minimized!
END IF

IF ib_trienabled THEN
	tab_1.tabpage_2.enabled = TRUE
ELSE
	tab_1.tabpage_2.enabled = FALSE
END IF

// afficher ou pas le choix des regroupements
IF IsNull(istr_params.a_param[10]) THEN
	ii_nbgroups = 0
ELSE
	ii_nbgroups = integer(istr_params.a_param[10])
END IF
IF ii_nbgroups > 0 THEN
	idw_tri.object.c_choixgroups.expression = "1"
ELSE
	idw_tri.object.c_choixgroups.expression = "0"
END IF

idw_1.uf_AutoSelectRow(FALSE)
idw_tri.uf_AutoSelectRow(FALSE)

// initialiser le ddlb de présélection
ddlb_1.additem("Critères par défaut")
ddlb_1.additem("Derniers critères utilisés par ...")
ddlb_1.selectitem(1)
ii_preselindex = 1

// lire les critères de sélection possibles pour le report actuel
idw_1.GetChild("critere", ldwc_critere)
ldwc_critere.settransobject(sqlca)
ldwc_critere.retrieve(is_reportname)
IF ldwc_critere.rowcount() = 0 THEN
	ldwc_critere.insertrow(0)
END IF

// lire les critères de tri possibles pour le report actuel
idw_tri.GetChild("critere_1", ldwc_critere)
ldwc_critere.settransobject(sqlca)
ldwc_critere.retrieve(is_reportname)
IF ldwc_critere.rowcount() = 0 THEN
	ldwc_critere.insertrow(0)
END IF
idw_tri.GetChild("critere_2", ldwc_critere)
ldwc_critere.settransobject(sqlca)
ldwc_critere.retrieve(is_reportname)
IF ldwc_critere.rowcount() = 0 THEN
	ldwc_critere.insertrow(0)
END IF

// lire les derniers utilisateurs du modèle en cours
dw_2.GetChild("as_user", ldwc_user)
ldwc_user.settransobject(sqlca)
ldwc_user.retrieve(is_modele)
IF ldwc_user.rowcount() = 0 THEN
	ldwc_user.insertrow(0)
END IF

// garnir la ddlb des critères de tri prédéfinis
IF ib_trienabled THEN
	tab_1.tabpage_2.ddlb_tri.AddItem("A la carte...")
	tab_1.tabpage_2.ddlb_tri.AddItem("Rappel du tri par défaut")
	li_saveid = -1
	DECLARE tri CURSOR FOR
		SELECT id, critere, ordre FROM report_predeftri WHERE report = :is_reportname 
				ORDER BY id, ordretri;
	OPEN tri;
	FETCH tri INTO :li_id, :ls_critere, :ls_ordre;
	DO WHILE f_check_sql(SQLCA) = 0
		// dans la table, le critère est sous la forme TABLE.CRITERE, et on le souhaite sous la forme CRITERE uniquement
		ll_pos = PosA(ls_critere, ".")
		IF ll_pos > 0 THEN
			ls_critere = lower(MidA(ls_critere, ll_pos + 1))
		END IF
		IF li_saveid <> li_id THEN
			IF li_saveid <> -1 THEN
				tab_1.tabpage_2.ddlb_tri.AddItem(ls_tri)
			END IF
			li_saveid = li_id
			ls_tri = string(li_id) + ") " + ls_critere
		ELSE
			ls_tri = ls_tri + ", " + ls_critere
		END IF
		FETCH tri INTO :li_id, :ls_critere, :ls_ordre;
	LOOP
	CLOSE tri;
	IF li_saveid <> -1 THEN
		tab_1.tabpage_2.ddlb_tri.AddItem(ls_tri)
	END IF
	tab_1.tabpage_2.ddlb_tri.SelectItem(1)
END IF

// réafficher la sélection par défaut pour le report en cours
wf_restorecrit("D")

end event

event ue_close;call super::ue_close;DESTROY iu_wait
end event

type tab_1 from tab within w_selection
integer x = 18
integer y = 128
integer width = 2834
integer height = 752
integer taborder = 10
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long backcolor = 79741120
boolean raggedright = true
boolean focusonbuttondown = true
boolean boldselectedtext = true
integer selectedtab = 1
tabpage_1 tabpage_1
tabpage_2 tabpage_2
end type

on tab_1.create
this.tabpage_1=create tabpage_1
this.tabpage_2=create tabpage_2
this.Control[]={this.tabpage_1,&
this.tabpage_2}
end on

on tab_1.destroy
destroy(this.tabpage_1)
destroy(this.tabpage_2)
end on

type tabpage_1 from userobject within tab_1
event create ( )
event destroy ( )
string tag = "TEXT_00022"
integer x = 18
integer y = 112
integer width = 2798
integer height = 624
long backcolor = 79741120
string text = "Sélection"
long tabtextcolor = 33554432
long tabbackcolor = 79741120
long picturemaskcolor = 536870912
dw_1 dw_1
end type

on tabpage_1.create
this.dw_1=create dw_1
this.Control[]={this.dw_1}
end on

on tabpage_1.destroy
destroy(this.dw_1)
end on

type dw_1 from uo_datawindow_multiplerow within tabpage_1
integer width = 2798
integer height = 624
integer taborder = 20
boolean bringtotop = true
string dataobject = "d_selection"
boolean vscrollbar = true
end type

event retrieverow;call super::retrieverow;wf_initcrit(row, this.object.critere[row])
end event

event ue_help;call super::ue_help;str_params	lstr_params
integer	li_par
string	ls_par, ls_operateur, ls_ecran_aide
long		ll_row
window	lw_window

IF LeftA(This.GetColumnName(), 6) <> "valeur" THEN return

ll_row = this.getrow()

// écran d'aide/sélection éventuel
ls_ecran_aide = trim(this.object.ecran_aide[ll_row])

// paramètre éventuel à passer au programme d'aide/sélection ou au tag
ls_par = trim(this.object.param_aide[ll_row])

// si pas d'écran ni paramètre d'aide prévu, on sort directement
IF (IsNull(ls_ecran_aide) OR LenA(ls_ecran_aide) = 0) AND (IsNull(ls_par) OR LenA(ls_par) = 0) THEN 
	return
END IF

// s'il y a un paramètre d'aide mais pas d'écran d'aide, on suppose que ce paramètre permet d'aller rechercher
// un message dans le fichier d'aide.INI, donc on affiche ce message dans la ligne microhelp
IF (IsNull(ls_ecran_aide) OR LenA(ls_ecran_aide) = 0) THEN
	gw_mdiframe.SetMicroHelp(f_gethelpmsg(ls_par))
	return
END IF

// assigner un array contenant le(s) paramètres à fournir à l'écran d'aide
li_par = 1
IF NOT IsNull(ls_par) AND LenA(ls_par) > 0 THEN
	lstr_params.a_param[li_par] = ls_par
	li_par++
END IF

// plusieurs sélections possibles pour les opérateurs between et in, un seul pour les autres
lstr_params.a_param[li_par] = FALSE
IF this.Object.datatype[ll_row] = "L" THEN
	ls_operateur = upper(this.Object.operateur_long[ll_row])
ELSE
	ls_operateur = upper(this.Object.operateur[ll_row])
END IF
IF dw_1.Object.datatype[ll_row] <> "L" THEN
	IF ls_operateur = "IN" OR ls_operateur = "NOT IN" OR ls_operateur = "BETWEEN" THEN
		lstr_params.a_param[li_par] = TRUE
	END IF
END IF

// la fenêtre de sélection dépend du critère
openwithparm (lw_window,lstr_params,ls_ecran_aide,gw_mdiframe)
IF Message.DoubleParm = -1 THEN 
	this.SetFocus()
	return
END IF
lstr_params = Message.PowerObjectParm
ls_par=""
FOR li_par = 1 TO upperbound(lstr_params.a_param)
	// si opérateur=IN ou NOT IN, liste des valeurs séparées par une virgule
	IF ls_operateur = "IN" OR ls_operateur = "NOT IN" THEN
		IF li_par > 1 THEN ls_par = ls_par + ","
	END IF
	// si opérateur=BETWEEN, liste des valeurs (maximum 2) séparées par "ET"
	IF ls_operateur = "BETWEEN" THEN
		IF li_par > 2 THEN exit
		IF li_par = 2 THEN ls_par = ls_par + " ET "
	END IF
	ls_par = ls_par + string(lstr_params.a_param[li_par])
NEXT
This.SetText(ls_par)
this.SetFocus()
end event

event ue_checkitem;string	ls_operateur, ls_datatype, ls_unique
integer	li_par
long		ll_row

ls_datatype = upper(This.Object.datatype[al_row])
ls_unique = upper(This.Object.usunique[al_row])
IF ls_datatype = "L" THEN
	ls_operateur = upper(This.Object.operateur_long[al_row])
ELSE
	ls_operateur = upper(This.Object.operateur[al_row])
END IF

CHOOSE CASE as_item
	CASE "critere"
		IF isnull(as_data) OR LenA(trim(as_data)) = 0 THEN
			as_message = "Le critère est obligatoire"
			return(-1)
		END IF
	// si le critère ne peut être utilisé qu'une seule fois dans la sélection, erreur si on essaye de l'utiliser + d'une fois
		SELECT report_critere.usunique into :ls_unique
			FROM report_critere
			WHERE (report_critere.report = :is_reportname) and (report_critere.critere = :as_data);
		IF f_check_sql (SQLCA) = 0 THEN
			IF ls_unique = "O" THEN
				ll_row = this.find("critere = '" + as_data + "'",0,this.rowcount())
				IF ll_row > 0 AND ll_row <> al_row THEN
					as_message = "Ce critère ne peut figurer qu'une seule fois dans la sélection"
					return(-1)
				END IF
			END IF
		END IF
	CASE "connecteur"
		IF isnull(as_data) OR LenA(trim(as_data)) = 0 THEN
			as_message = "Le connecteur est obligatoire"
			return(-1)
		END IF
	CASE "operateur"
		IF ls_datatype <> "L" THEN
			IF isnull(as_data) OR LenA(trim(as_data)) = 0 THEN
				as_message = "L'opérateur est obligatoire"
				return(-1)
			END IF
		END IF
	CASE "operateur_long"
		IF ls_datatype = "L" THEN
			IF isnull(as_data) OR LenA(trim(as_data)) = 0 THEN
				as_message = "L'opérateur est obligatoire"
				return(-1)
			END IF
		END IF

// controle de la valeur introduite :
// valeur de type string : doit être introduite sauf pour les opérateurs "IS NULL" et "IS NOT NULL"
	CASE "valeur_string"
		IF (ls_datatype = "S" AND PosA(ls_operateur,"NULL") = 0) OR &
			(ls_datatype <> "S" AND (PosA(ls_operateur,"LIKE") > 0 OR ls_operateur = "BETWEEN" &
			OR ls_operateur = "IN" OR ls_operateur = "NOT IN")) THEN
				IF isnull(as_data) OR LenA(trim(as_data)) = 0 THEN
					as_message = "La valeur est obligatoire"
					return(-1)
				END IF
		END IF

// valeur de type number : doit être introduite sauf pour les opérateurs "IS NULL", "IS NOT NULL", "LIKE", "BETWEEN", "IN"
// (car pour like, between, in et not in on utilise "valeur_string" et non "valeur_number" pour les champs numériques)
	CASE "valeur_number"
		IF ls_datatype = "N" AND PosA(ls_operateur,"NULL")=0 AND &
				PosA(ls_operateur,"LIKE")=0 AND ls_operateur <> "BETWEEN" AND ls_operateur <> "IN" AND ls_operateur <> "NOT IN" THEN
			IF isnull(as_data) OR LenA(trim(as_data)) = 0 THEN
				as_message = "La valeur est obligatoire"
				return(-1)
			ELSE
// valeur introduite doit être dans les limites
				IF dec(as_data) < This.Object.min[al_row] OR dec(as_data) > This.Object.max[al_row] THEN
					as_message = "Cette valeur doit être comprise entre " + string(This.Object.min[al_row]) + &
									" et " + string(This.Object.max[al_row])
					return(-1)
				END IF
			END IF
		END IF

// valeur de type date : doit être introduite sauf pour les opérateurs "IS NULL", "IS NOT NULL", "LIKE", "BETWEEN", "IN", "NOT IN"
// (car pour like, between et in on utilise "valeur_string" et non "valeur_date" pour les champs date)
	CASE "valeur_date"
		IF ls_datatype = "D"  AND PosA(ls_operateur,"NULL") = 0 AND &
				PosA(ls_operateur,"LIKE")=0 AND ls_operateur <> "BETWEEN" AND ls_operateur <> "IN" AND ls_operateur <> "NOT IN" THEN
			IF isnull(as_data) OR LenA(trim(as_data)) = 0 THEN
				as_message = "La valeur est obligatoire"
				return(-1)
			END IF
		END IF

END CHOOSE
return(0)
end event

event ue_itemvalidated;call super::ue_itemvalidated;string ls_oldoperateur		

CHOOSE CASE as_name
	CASE "critere"
		wf_initcrit(al_row, as_data)
	CASE "operateur"
		ls_oldoperateur = upper(this.object.operateur[al_row])
		IF ls_oldoperateur = "IN" OR ls_oldoperateur = "NOT IN" OR ls_oldoperateur = "BETWEEN" OR &
			ls_oldoperateur = "LIKE" OR ls_oldoperateur = "NOT LIKE" THEN 
			  this.object.valeur_string[al_row] = ""
		END IF
	CASE "operateur_long"
		ls_oldoperateur = upper(this.object.operateur[al_row])
		IF ls_oldoperateur = "IN" OR ls_oldoperateur = "NOT IN" OR ls_oldoperateur = "BETWEEN" OR &
			ls_oldoperateur = "LIKE" OR ls_oldoperateur = "NOT LIKE"THEN 
			  this.object.valeur_string[al_row] = ""
		END IF		
END CHOOSE
end event

event ue_postitemvalidated;call super::ue_postitemvalidated;CHOOSE CASE as_name
	CASE "operateur", "operateur_long"
		wf_setmask(al_row)
END CHOOSE
end event

event ue_delete;// les critères obligatoires ne peuvent être effacés
IF this.Object.Obligatoire[this.GetRow()] = "O" THEN
	gu_message.uf_error("Ce critère est obligatoire et ne peut être supprimé")
	return(-1)
ELSE
	return super::event ue_delete()
END IF

end event

event itemfocuschanged;call super::itemfocuschanged;// quand il existe une expression de vérification, l'assigner à l'expression de validation pour que PB fasse le check
string	ls_operateur, ls_validation

IF This.Object.datatype[row] = "L" THEN
	ls_operateur = upper(This.Object.operateur_long[row])
ELSE
	ls_operateur = upper(This.Object.operateur[row])
END IF
	
ls_validation = This.Object.validation[row]

// assigner expression de validation sauf pour les opérateurs "IS NULL","IS NOT NULL", "IN", "NOT IN", "BETWEEN", "LIKE", "NOT LIKE"
CHOOSE CASE dwo.name
	CASE "valeur_string", "valeur_number", "valeur_date"
		IF NOT f_IsEmptyString(ls_validation) AND PosA(ls_operateur,"NULL") = 0 AND ls_operateur <> "LIKE" &
			AND ls_operateur <> "NOT LIKE" AND ls_operateur <> "BETWEEN" AND ls_operateur <> "IN" AND ls_operateur <> "NOT IN" THEN
				this.setvalidate(this.getcolumn(), ls_validation)
		ELSE
				this.setvalidate(this.getcolumn(), "")
		END IF
END CHOOSE
end event

event rowfocuschanged;call super::rowfocuschanged;wf_setmask(currentrow)
end event

type tabpage_2 from userobject within tab_1
string tag = "TEXT_00023"
integer x = 18
integer y = 112
integer width = 2798
integer height = 624
long backcolor = 79741120
string text = "Tri"
long tabtextcolor = 33554432
long tabbackcolor = 79741120
long picturemaskcolor = 536870912
st_2 st_2
ddlb_tri ddlb_tri
dw_tri dw_tri
end type

on tabpage_2.create
this.st_2=create st_2
this.ddlb_tri=create ddlb_tri
this.dw_tri=create dw_tri
this.Control[]={this.st_2,&
this.ddlb_tri,&
this.dw_tri}
end on

on tabpage_2.destroy
destroy(this.st_2)
destroy(this.ddlb_tri)
destroy(this.dw_tri)
end on

type st_2 from uo_statictext within tabpage_2
string tag = "TEXT_00031"
integer x = 73
integer y = 32
integer width = 640
string text = "Critères de tri prédéfinis"
end type

type ddlb_tri from uo_dropdownlistbox within tabpage_2
integer x = 731
integer y = 16
integer width = 1445
integer height = 608
integer taborder = 30
integer textsize = -9
boolean sorted = false
boolean vscrollbar = true
end type

event selectionchanged;call super::selectionchanged;// afficher le set de critères de tri choisi
long		ll_pos, ll_row
integer	li_id
string	ls_critere, ls_ordre, ls_groupe, ls_newpage

idw_tri.reset()

ll_pos = PosA(this.text, ")")

IF ll_pos <> 0 THEN
	li_id = integer(LeftA(this.text, ll_pos - 1))
	DECLARE tri CURSOR FOR
		SELECT critere, ordre, groupe, newpage FROM report_predeftri 
				WHERE report = :is_reportname AND id = :li_id
				ORDER BY ordretri;
	OPEN tri;
	FETCH tri INTO :ls_critere, :ls_ordre, :ls_groupe, :ls_newpage;
	DO WHILE f_check_sql(SQLCA) = 0
		ll_row = idw_tri.event ue_addrow()
		wf_initnewtri(ll_row)
		idw_tri.object.critere_1[ll_row] = ls_critere
		idw_tri.object.ordre_1[ll_row] = ls_ordre
		idw_tri.object.groupe_1[ll_row] = ls_groupe
		idw_tri.object.newpage_1[ll_row] = ls_newpage
		FETCH tri INTO :ls_critere, :ls_ordre, :ls_groupe, :ls_newpage;
	LOOP
	CLOSE tri;
ELSE
	// index 2 : rappel du tri par défaut
	IF index = 2 THEN
		wf_restoretri("D")
	END IF
	// index 1 : tri à la carte
END IF

IF idw_tri.RowCount() = 0 THEN
	wf_initnewtri(idw_tri.event ue_addrow())
END IF
idw_tri.scrolltorow(1)

end event

type dw_tri from uo_datawindow_multiplerow within tabpage_2
integer y = 128
integer width = 2834
integer height = 496
integer taborder = 11
string dataobject = "d_selectiontri"
boolean vscrollbar = true
end type

event retrieverow;call super::retrieverow;wf_inittri(row)
end event

event ue_checkitem;call super::ue_checkitem;long	ll_row

// tester si nombre de groupes sélectionnés n'excède pas le nombre max.
IF LeftA(as_item, 6) = "groupe" THEN
	IF this.object.c_nbgroups[1] = ii_nbgroups AND as_data = "O" AND this.object.groupe.original[al_row] = "N" THEN
		as_message = "Maximum " + f_string(ii_nbgroups) + " groupes peuvent être sélectionnés"
		return(-1)
	END IF
END IF

// si on remet sous-total à N, remettre aussi saut de page à "N"
IF LeftA(as_item, 6) = "groupe" AND as_data = "N" THEN
	this.uf_setdefaultvalue(al_row, "newpage", "N", FALSE)
END IF

// on ne peut pas sélectionner sous-total sans sélectionner sous-total des critères de tri précédent
// (mais on ne peut pas dépasser le nombre de groupes max.possible)
// - sélection des critères précédent
IF LeftA(as_item, 6) = "groupe" AND as_data = "O" THEN
	IF al_row > ii_nbgroups THEN
		as_message = "Maximum " + f_string(ii_nbgroups) + " groupes peuvent être sélectionnés"
		return(-1)
	END IF
	FOR ll_row = 1 TO al_row - 1
		this.uf_setdefaultvalue(ll_row, "groupe", "O", FALSE)
	NEXT
END IF
// - désélection des critères suivant
IF LeftA(as_item, 6) = "groupe" AND as_data = "N" THEN
	FOR ll_row = al_row TO this.rowcount()
		this.uf_setdefaultvalue(ll_row, "groupe", "N", FALSE)
		// si on remet sous-total à N, remettre aussi saut de page à "N"
		this.uf_setdefaultvalue(ll_row, "newpage", "N", FALSE)
	NEXT
END IF

// on ne peut pas sélectionner saut de page sans sélectionner saut de page des critères de tri précédent
// - sélection des critères précédent
IF LeftA(as_item, 7) = "newpage" AND as_data = "O" THEN
	FOR ll_row = 1 TO al_row - 1
		this.uf_setdefaultvalue(ll_row, "groupe", "O", FALSE)
		this.uf_setdefaultvalue(ll_row, "newpage", "O", FALSE)
	NEXT
END IF
// - désélection des critères suivant
IF LeftA(as_item, 7) = "newpage" AND as_data = "N" THEN
	FOR ll_row = al_row TO this.rowcount()
		this.uf_setdefaultvalue(ll_row, "newpage", "N", FALSE)
	NEXT
END IF

return(1)
end event

type dw_2 from uo_dw within w_selection
integer x = 1573
integer y = 16
integer width = 987
integer height = 92
string dataobject = "d_reportuser"
end type

event itemchanged;call super::itemchanged;wf_restorecrit("U")
end event

type st_1 from statictext within w_selection
string tag = "TEXT_00021"
integer x = 146
integer y = 32
integer width = 347
integer height = 80
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "Présélection"
boolean focusrectangle = false
end type

type ddlb_1 from dropdownlistbox within w_selection
integer x = 494
integer y = 16
integer width = 896
integer height = 336
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
string text = "none"
boolean border = false
boolean sorted = false
borderstyle borderstyle = stylelowered!
end type

event selectionchanged;IF index <> ii_preselindex THEN
	ii_preselindex = index
	CHOOSE CASE index
		CASE 1
			wf_restorecrit("D")
			dw_2.reset()
		CASE 2
			dw_2.insertrow(0)
			dw_2.object.as_user[1] = gs_username
			wf_restorecrit("U")
	END CHOOSE
END IF
idw_1.Setfocus()
end event

type cb_sql from uo_cb within w_selection
string tag = "TEXT_00030"
integer x = 2597
integer y = 928
integer width = 219
integer height = 96
integer taborder = 80
string text = "SQL"
end type

event clicked;call super::clicked;string	ls_where

ls_where = wf_generatewhere()
IF NOT IsNull(ls_where) THEN
	gu_message.uf_info("clause WHERE générée",ls_where)
END IF
idw_1.SetFocus()

end event

type cb_count from uo_cb within w_selection
string tag = "TEXT_00029"
integer x = 2377
integer y = 928
integer width = 219
integer height = 96
integer taborder = 70
string text = "Eval"
end type

event clicked;call super::clicked;string	ls_newselect, ls_error, ls_dsSyntax
long 		ll_nrows
uo_ds		lds_tmp

// pas d'ordre SQL au départ : pas d'évaluation possible (par ex. composite report ne contient pas de
// select en lui-même)
IF f_isEmptyString(is_originalselect) THEN
	gu_message.uf_info("Evaluation non disponible pour ce rapport")
	return
END IF

ls_newselect = wf_GenerateNewSelect()
IF f_isEmptyString(ls_newselect) THEN
//	gu_message.uf_info("Evaluation impossible pour l'instant, les critères sont incorrects")
	return
END IF

iu_wait.uf_addinfo("Evaluation en cours")

// crée l'objet datastore
lds_tmp = CREATE uo_ds

// crée la syntaxe d'un datawindow sur base de l'ordre SQL
ls_dsSyntax = SQLCA.SyntaxFromSQL(ls_newselect, "", ls_error)
IF LenA(ls_error) > 0 THEN
	gu_message.uf_error("Erreur SyntaxFromSQL", ls_error)
	GOTO ERREUR
END IF

// crée un datastore sur base de la syntaxe et l'associe à la variable locale de type datastore
lds_tmp.Create(ls_dsSyntax, ls_error)
IF LenA(ls_error) > 0 THEN
	gu_message.uf_error("Erreur Create Datastore", ls_error)
	GOTO ERREUR
END IF

// lecture
lds_tmp.settransobject(sqlca)
ll_nrows = lds_tmp.Retrieve()
IF ll_nrows = -1 THEN
	gu_message.uf_error("Erreur retrieve Datastore")
	GOTO ERREUR
END IF

// normal end
DESTROY lds_tmp
iu_wait.uf_closewindow()

IF f_IsEmptyString(is_evalmsg) THEN
	gu_message.uf_info(string(ll_nrows) + " enregistrement(s) répond(ent) aux critères")
ELSE
	gu_message.uf_info(string(ll_nrows) + " " + is_evalmsg)
END IF
idw_1.SetFocus()
return

// abnormal end
ERREUR:
DESTROY lds_tmp
iu_wait.uf_closewindow()
return

end event

type cb_delete from uo_cb within w_selection
string tag = "TEXT_00026"
integer x = 786
integer y = 912
integer width = 366
integer height = 108
integer taborder = 40
string text = "&Supprimer"
end type

event clicked;call super::clicked;// si 1ère tabpage est sélectionnée : supprimer le critère de sélection
IF tab_1.SelectedTab = 1 THEN
	wf_deletecritere()

	idw_1.SetFocus()
END IF

// si 2ème tabpage est sélectionnée : supprimer le critère de tri
IF tab_1.SelectedTab = 2 THEN
	wf_deletetri()
	idw_tri.SetFocus()
END IF
end event

type cb_add from uo_cb within w_selection
string tag = "TEXT_00025"
integer x = 421
integer y = 912
integer width = 366
integer height = 108
integer taborder = 30
string text = "&Ajouter"
end type

event clicked;call super::clicked;long	ll_row 

// si 1ère tabpage est sélectionnée : ajouter un critère de sélection
IF tab_1.SelectedTab = 1 THEN
	wf_addcritere()
	idw_1.SetFocus()
END IF

// si 2ème tabpage est sélectionnée : ajouter un critère de tri
IF tab_1.SelectedTab = 2 THEN
	wf_addtri()
	idw_tri.SetFocus()
END IF
end event

type cb_insert from uo_cb within w_selection
string tag = "TEXT_00024"
integer x = 55
integer y = 912
integer width = 366
integer height = 108
integer taborder = 20
string text = "&Insérer"
end type

event clicked;call super::clicked;long	ll_row

// si 1ère tabpage est sélectionnée : ajouter un critère de sélection
IF tab_1.SelectedTab = 1 THEN
	wf_insertcritere()
	idw_1.SetFocus()
END IF

// si 2ème tabpage est sélectionnée : ajouter un critère de tri
IF tab_1.SelectedTab = 2 THEN
	wf_inserttri()
	idw_tri.SetFocus()
END IF
end event

type cb_cancel from uo_cb within w_selection
string tag = "TEXT_00028"
integer x = 1755
integer y = 912
integer width = 370
integer height = 108
integer taborder = 60
string text = "Abandonner"
end type

event clicked;call super::clicked;CloseWithReturn(Parent, -1)
end event

type cb_ok from uo_cb within w_selection
event type integer ue_moreok ( ref str_params astr_params )
string tag = "TEXT_00027"
integer x = 1390
integer y = 912
integer width = 366
integer height = 108
integer taborder = 50
string text = "OK"
boolean default = true
end type

event type integer ue_moreok(ref str_params astr_params);// dans un descendant de cette fenêtre, on peut compléter ici la liste des paramètres renvoyés
// (à partir du paramètre n° 11 pour laisser libre les 10 premiers)
// PCO 26/04/2016 : ajouter un return code
// 1 : OK
// -1 : erreur ou abandon
return(1)
end event

event clicked;call super::clicked;long		ll_row, ll_nrows
string	ls_newselect, ls_datatype, ls_connect, ls_operateur, ls_par1, ls_par2, ls_valeur, ls_critere, &
			ls_w, ls_o, ls_groupe[], ls_newpage[]
str_params	lstr_params

IF wf_check_criteres() = -1 THEN return(-1)

lstr_params.a_param[1] = ""
lstr_params.a_param[2] = ""

// générer le nouvel ordre SQL
ls_newselect = wf_GenerateNewSelect(ls_w, ls_o)
IF IsNull(ls_newselect) THEN
	return(-1)
END IF

// sauver groupes et sauts de page choisis
IF ii_nbgroups > 0 THEN
	ll_nrows = idw_tri.RowCount()
	FOR ll_row=1 TO ll_nrows
		ls_groupe[ll_row] = idw_tri.object.groupe[ll_row]
		ls_newpage[ll_row] = idw_tri.object.newpage[ll_row]
	NEXT
END IF

// enregistrer la sélection après suppression des anciens critères
delete from report_select where username = :gs_username AND modele = :is_modele AND type='U';
IF f_check_sql(SQLCA) = -1 THEN
	rollback USING SQLCA;
	populateerror(20000, "Erreur lors de la suppression des anciens critères de sélection")
	gu_message.uf_unexp()
	return(-1)
ELSE
	commit USING SQLCA;
END IF
ll_nrows = idw_1.RowCount()
FOR ll_row = 1 TO ll_nrows
	// numérotation des critères
	idw_1.Object.tri[ll_row] = ll_row
	ls_critere = idw_1.Object.critere[ll_row]
	ls_datatype = idw_1.Object.datatype[ll_row]
	ls_connect = idw_1.Object.connecteur[ll_row]
	IF ls_datatype = "L" THEN
		ls_operateur = idw_1.Object.operateur_long[ll_row]
	ELSE
		ls_operateur = idw_1.Object.operateur[ll_row]
	END IF
	// s'il n'y a pas de champ ou d'opérateur, on ignore le critère
	IF IsNull(ls_critere) OR IsNull(ls_operateur) THEN
		idw_1.RowsDiscard(ll_row, ll_row, PRIMARY!)
		ll_nrows = ll_nrows - 1
		ll_row = ll_row - 1
		continue
	END IF
NEXT
IF idw_1.update() = 1 THEN
	commit;
ELSE
	rollback;
	populateerror(20000, "Erreur lors de l'enregistrement de la sélection")
	gu_message.uf_unexp()	
	return(-1)
END IF

// enregistrer les nouveaux critères de tri après suppression des anciens
IF ib_trienabled THEN
	delete from report_selecttri where username = :gs_username AND modele = :is_modele AND type='U';
	IF f_check_sql(SQLCA) = -1 THEN
		rollback USING SQLCA;
		populateerror(20000, "Erreur lors de la suppression des anciens critères de tri")
		gu_message.uf_unexp()
		return(-1)
	ELSE
		commit USING SQLCA;
	END IF
	ll_nrows = idw_tri.RowCount()
	FOR ll_row = 1 TO ll_nrows
		// numérotation des critères
		idw_tri.Object.tri[ll_row] = ll_row
		// s'il n'y a pas de champ on ignore le critère
		IF IsNull(idw_tri.Object.critere_1[ll_row]) THEN
			idw_tri.RowsDiscard(ll_row, ll_row, PRIMARY!)
			ll_nrows = ll_nrows - 1
			ll_row = ll_row - 1
			continue
		END IF
	NEXT
	IF idw_tri.update() = 1 THEN
		commit;
	ELSE
		rollback;
		populateerror(20000, "Erreur lors de l'enregistrement des critères de tri")
		gu_message.uf_unexp()	
		return(-1)
	END IF
END IF

// renvoyer le nouvel ordre SQL, la sélection en français, le where et le order by à la fenêtre appelante
lstr_params.a_param[1] = ls_newselect
lstr_params.a_param[2] = wf_generatewherefr()
lstr_params.a_param[3] = ls_w
lstr_params.a_param[4] = ls_o
lstr_params.a_param[5] = ls_groupe
lstr_params.a_param[6] = ls_newpage
// il est possible de créer des descendants de cette fenêtre et d'ajouter certains paramètres
// PCO 26/04/2016 : interruption si ue_moreOK renvoie -1
IF this.event ue_moreok(lstr_params) = -1 THEN
	CloseWithReturn(Parent, -1)
ELSE
	CloseWithReturn(Parent, lstr_params)
END IF

end event

