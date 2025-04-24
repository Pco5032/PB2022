//objectcomments BR des textes législatifs
forward
global type br_legislation from nonvisualobject
end type
end forward

global type br_legislation from nonvisualobject
end type
global br_legislation br_legislation

forward prototypes
public function integer uf_check_code (any aa_value, ref string as_message)
public function integer uf_check_beforedelete (string as_code, ref string as_message)
public function integer uf_check_texte (any aa_value, ref string as_message)
end prototypes

public function integer uf_check_code (any aa_value, ref string as_message);// CODE_LEG obligatoire
string	ls_code

ls_code = string(aa_value)

IF f_IsEmptyString(ls_code) THEN
	as_message = "L'identifiant du texte doit être spécifié"
	return(-1)
END IF

return(1)

end function

public function integer uf_check_beforedelete (string as_code, ref string as_message);// vérification avant suppression
long	ll_count

as_message = "Le texte " + f_string(as_code) + " est encore utilisé.~n~n" + &
"Si vous voulez le supprimer, il faut d'abord supprimer toute référence vers lui dans les provenances."

select count(*) into :ll_count from provenance where code_sp = :as_code using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Erreur select PROVENANCE"
	return(-1)
END IF
IF ll_count > 0 THEN
	return(-1)
END IF

return(1)

end function

public function integer uf_check_texte (any aa_value, ref string as_message);// TEXTE obligatoire
string	ls_texte

ls_texte = string(aa_value)

IF f_IsEmptyString(ls_texte) THEN
	as_message = "Le TEXTE ne peut être vide"
	return(-1)
END IF

return(1)

end function

on br_legislation.create
call super::create
TriggerEvent( this, "constructor" )
end on

on br_legislation.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

