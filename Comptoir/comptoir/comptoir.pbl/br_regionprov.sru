//objectcomments BR des codes de régions de provenance
forward
global type br_regionprov from nonvisualobject
end type
end forward

global type br_regionprov from nonvisualobject
end type
global br_regionprov br_regionprov

forward prototypes
public function integer uf_check_nom (any aa_value, ref string as_message)
public function integer uf_check_pays (any aa_value, ref string as_message)
public function integer uf_check_beforedelete (integer ai_code, ref string as_message)
public function integer uf_check_region (any aa_value, ref string as_message, string as_pays)
public function integer uf_check_num (any aa_value, ref string as_message)
public function integer uf_check_coderegprov (any aa_value, ref string as_message)
end prototypes

public function integer uf_check_nom (any aa_value, ref string as_message);// NOM obligatoire
string	ls_nom

ls_nom = string(aa_value)

IF f_IsEmptyString(ls_nom) THEN
	as_message = "Le NOM doit être spécifié"
	return(-1)
END IF

return(1)

end function

public function integer uf_check_pays (any aa_value, ref string as_message);// PAYS obligatoire, doit exister dans TRADUC
string	ls_pays

ls_pays = string(aa_value)

IF f_IsEmptyString(ls_pays) THEN
	as_message = "Le PAYS doit être spécifié"
	return(-1)
END IF

select trad into :as_message from V_PAYS where code=:ls_pays using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Code pays inexistant"
	return(-1)
END IF

return(1)

end function

public function integer uf_check_beforedelete (integer ai_code, ref string as_message);// vérification avant suppression
long	ll_count

as_message = "Le code région n° " + f_string(ai_code) + " est encore utilisé.~n~n" + &
"Si vous voulez le supprimer, il faut d'abord supprimer toute référence vers lui dans les provenances."

select count(*) into :ll_count from provenance where num_regprov = :ai_code using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Erreur select PROVENANCE"
	return(-1)
END IF
IF ll_count > 0 THEN
	return(-1)
END IF

return(1)

end function

public function integer uf_check_region (any aa_value, ref string as_message, string as_pays);// La REGION (Wallonie, Flandre ou Brabant - code W, V ou B) est obligatoire si le pays est la BELGIQUE.
// --> NON, contrainte annulée suite visite de ME au Comptoir le 16/09/2008.

// Elle doit être = "0" pour les autres pays.
string	ls_region

ls_region = string(aa_value)

IF as_pays <> "BE" AND ls_region <> "0" THEN
	as_message = "Pour les pays autres que la Belgique, le code région doit être '0'"
	return(-1)
END IF

select trad into :as_message from V_REGION where code=:ls_region using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Code région inexistant"
	return(-1)
END IF

return(1)

end function

public function integer uf_check_num (any aa_value, ref string as_message);// num_regprov obligatoire, compris entre 1 et 999
integer	li_code

li_code = integer(aa_value)

IF IsNull(li_code) OR li_code <= 0 OR li_code > 999 THEN
	as_message = "L'identifiant de la région de provenance doit être compris entre 1 et 999"
	return(-1)
END IF

return(1)

end function

public function integer uf_check_coderegprov (any aa_value, ref string as_message);return(1)

end function

on br_regionprov.create
call super::create
TriggerEvent( this, "constructor" )
end on

on br_regionprov.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

