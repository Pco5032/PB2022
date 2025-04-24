//objectcomments BR catalogue de vente
forward
global type br_catalogue from nonvisualobject
end type
end forward

global type br_catalogue from nonvisualobject
end type
global br_catalogue br_catalogue

type variables

end variables

forward prototypes
public function integer uf_check_numcat (any aa_value, ref string as_message)
public function integer uf_check_saison (any aa_value, ref string as_message)
public function integer uf_check_beforedelete (integer ai_numcat, ref string as_message)
public function integer uf_check_reflot (any aa_value, ref string as_message)
public function integer uf_check_pu1 (any aa_value, ref string as_message)
public function integer uf_check_pu2 (any aa_value, ref string as_message)
public function integer uf_check_pu3 (any aa_value, ref string as_message)
public function integer uf_check_rem (any aa_value, ref string as_message)
public function integer uf_check_lot_beforedelete (integer ai_numcat, string as_reflot, ref string as_message)
public function integer uf_check_pup1 (any aa_value, ref string as_message)
public function integer uf_check_pup2 (any aa_value, ref string as_message)
public function integer uf_check_pup3 (any aa_value, ref string as_message)
end prototypes

public function integer uf_check_numcat (any aa_value, ref string as_message);// numéro de catalogue : entre 1 et 999
integer	li_data

li_data = integer(aa_value)
IF IsNull(li_data) OR li_data <= 0 OR li_data > 99 THEN
	as_message = "Le NUMERO du catalogue doit être compris entre 1 et 999"
	return(-1)
END IF

return(1)
end function

public function integer uf_check_saison (any aa_value, ref string as_message);// saison : obligatoire
string	ls_data

ls_data = string(aa_value)

IF f_IsEmptyString(ls_data) THEN
	as_message = "La saison du catalogue doit être mentionnée"
	return(-1)
END IF

return(1)

end function

public function integer uf_check_beforedelete (integer ai_numcat, ref string as_message);// vérification avant suppression du catalogue entier
long	ll_count

as_message = "Le catalogue n° " + f_string(ai_numcat) + &
" est encore utilisé.~n~n" + "Si vous voulez le supprimer, il faut d'abord supprimer toute référence " + &
"vers lui dans les documents-fournisseur et les commandes."

select count(*) into :ll_count from docfrn where num_cat = :ai_numcat
	 using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Erreur select DOCFRN"
	return(-1)
END IF
IF ll_count > 0 THEN
	return(-1)
END IF

select count(*) into :ll_count from commande where num_cat = :ai_numcat
	 using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Erreur select COMMANDE"
	return(-1)
END IF
IF ll_count > 0 THEN
	return(-1)
END IF

return(1)

end function

public function integer uf_check_reflot (any aa_value, ref string as_message);// référence du lot obligatoire et doit exister
string	ls_data

ls_data = string(aa_value)
IF f_IsEmptyString(ls_data) THEN
	as_message = "Le référence du LOT doit être précisée"
	return(-1)
END IF

select num_fiche into :as_message from registre where ref_lot = :ls_data using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Référence de lot inexistante"
	return(-1)
END IF
return(1)


end function

public function integer uf_check_pu1 (any aa_value, ref string as_message);// PU1 obligatoire
decimal{2}	ld_data

ld_data = dec(aa_value)
IF IsNull(ld_data) OR ld_data <= 0 THEN
	as_message = "Le prix unitaire 1 doit être spécifiée"
	return(-1)
END IF

return(1)


end function

public function integer uf_check_pu2 (any aa_value, ref string as_message);// PU2 not null mais 0 possible
decimal{2}	ld_data

ld_data = dec(aa_value)
IF IsNull(ld_data) THEN
	as_message = "Le prix unitaire 2 ne peut être NULL (mais peut valoir 0)"
	return(-1)
END IF

return(1)


end function

public function integer uf_check_pu3 (any aa_value, ref string as_message);// PU3 not null mais 0 possible
decimal{2}	ld_data

ld_data = dec(aa_value)
IF IsNull(ld_data) THEN
	as_message = "Le prix unitaire 3 ne peut être NULL (mais peut valoir 0)"
	return(-1)
END IF

return(1)


end function

public function integer uf_check_rem (any aa_value, ref string as_message);// REM
return(1)


end function

public function integer uf_check_lot_beforedelete (integer ai_numcat, string as_reflot, ref string as_message);// vérification avant suppression d'un lot du catalogie
long	ll_count

as_message = "La référence "+ as_reflot + " du catalogue n° " + f_string(ai_numcat) + &
" est encore utilisée.~n" + "Si vous voulez la supprimer, il faut d'abord supprimer toute référence " + &
"vers elle dans les documents-fournisseur et les commandes."

select count(*) into :ll_count from docfrn where num_cat = :ai_numcat and ref_lot = :as_reflot
	 using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Erreur select DOCFRN"
	return(-1)
END IF
IF ll_count > 0 THEN
	return(-1)
END IF

select count(*) into :ll_count from commande C, detail_cmde d 
	where c.an_cmde=d.an_cmde and c.num_cmde=d.num_cmde and c.num_cat = :ai_numcat and d.ref_lot = :as_reflot
	 using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Erreur select COMMANDE, DETAIL_CMDE"
	return(-1)
END IF
IF ll_count > 0 THEN
	return(-1)
END IF

return(1)

end function

public function integer uf_check_pup1 (any aa_value, ref string as_message);// PUP1 not null mais 0 possible
decimal{2}	ld_data

ld_data = dec(aa_value)
IF IsNull(ld_data) THEN
	as_message = "Le prix avec prétraitement 1 ne peut être NULL (mais peut valoir 0)"
	return(-1)
END IF

return(1)


end function

public function integer uf_check_pup2 (any aa_value, ref string as_message);// PUP2 not null mais 0 possible
decimal{2}	ld_data

ld_data = dec(aa_value)
IF IsNull(ld_data) THEN
	as_message = "Le prix avec prétraitement 2 ne peut être NULL (mais peut valoir 0)"
	return(-1)
END IF

return(1)


end function

public function integer uf_check_pup3 (any aa_value, ref string as_message);// PUP3 not null mais 0 possible
decimal{2}	ld_data

ld_data = dec(aa_value)
IF IsNull(ld_data) THEN
	as_message = "Le prix avec prétraitement 3 ne peut être NULL (mais peut valoir 0)"
	return(-1)
END IF

return(1)


end function

on br_catalogue.create
call super::create
TriggerEvent( this, "constructor" )
end on

on br_catalogue.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

