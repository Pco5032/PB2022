//objectcomments BR inventaire
forward
global type br_inventaire from nonvisualobject
end type
end forward

global type br_inventaire from nonvisualobject
end type
global br_inventaire br_inventaire

type variables

end variables

forward prototypes
public function integer uf_check_reflot (any aa_value, ref string as_message)
public function integer uf_check_rem (any aa_value, ref string as_message)
public function integer uf_check_qte (any aa_value, ref string as_message)
public function integer uf_check_numinv (any aa_value, ref string as_message)
public function integer uf_check_dtinv (any aa_value, ref string as_message)
public function integer uf_check_cond (any aa_value, ref string as_message)
public function integer uf_check_util (any aa_value, ref string as_message)
public function integer uf_check_chfroide (any aa_value, ref string as_message)
public function integer uf_check_beforedelete (date adt_dtinv, ref string as_message)
public function integer uf_check_numinv_beforedelete (date adt_dtinv, integer ai_numinv, ref string as_message)
end prototypes

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

public function integer uf_check_rem (any aa_value, ref string as_message);// Remarque
return(1)


end function

public function integer uf_check_qte (any aa_value, ref string as_message);// quantité obligatoire
decimal{3}	ld_data

ld_data = dec(aa_value)
IF IsNull(ld_data) OR ld_data < 0 THEN
	as_message = "La quantité inventoriée doit être spécifiée (0 est une valeur correcte)"
	return(-1)
END IF

return(1)


end function

public function integer uf_check_numinv (any aa_value, ref string as_message);// numéro de ligne d'inventaire : entre 1 et 9999
integer	li_data

li_data = integer(aa_value)
IF IsNull(li_data) OR li_data <= 0 OR li_data > 9999 THEN
	as_message = "Le NUMERO d'une ligne d'inventaire doit être compris entre 1 et 9999"
	return(-1)
END IF

return(1)
end function

public function integer uf_check_dtinv (any aa_value, ref string as_message);// date d'inventaire : obligatoire
date	l_date

l_date = gu_datetime.uf_dfromdt(aa_value)

// date doit être comprise entre le 01/01/1980 et le 31/12/2050
IF IsNull(l_date) OR l_date < date("1980-01-01") OR l_date > date("2050-12-31") THEN
	as_message = "La date d'inventaire doit être comprise entre le 01/01/1980 et le 31/12/2050"
	return(-1)
END IF

return(1)

end function

public function integer uf_check_cond (any aa_value, ref string as_message);// Conditionnement
return(1)


end function

public function integer uf_check_util (any aa_value, ref string as_message);// Utilisation : obligatoire et doit exister
string	ls_data

ls_data = string(aa_value)
IF f_IsEmptyString(ls_data) THEN
	as_message = "L'utilisation doit être précisée"
	return(-1)
END IF

select trad into :as_message from v_utilinvent where code = :ls_data using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Code UTILISATION incorrect"
	return(-1)
END IF
return(1)


end function

public function integer uf_check_chfroide (any aa_value, ref string as_message);// N° chambre froide : obligatoire et doit exister
string	ls_data

ls_data = string(aa_value)
IF f_IsEmptyString(ls_data) THEN
	as_message = "La chambre froide de stockage doit être précisée"
	return(-1)
END IF

select trad into :as_message from v_chfroide where code = :ls_data using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Code CHAMBRE FROIDE incorrect"
	return(-1)
END IF
return(1)


end function

public function integer uf_check_beforedelete (date adt_dtinv, ref string as_message);// vérification avant suppression de l'inventaire entier
return(1)

end function

public function integer uf_check_numinv_beforedelete (date adt_dtinv, integer ai_numinv, ref string as_message);// vérification avant suppression d'un lot de l'inventaire

return(1)

end function

on br_inventaire.create
call super::create
TriggerEvent( this, "constructor" )
end on

on br_inventaire.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

