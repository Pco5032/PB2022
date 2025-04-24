//objectcomments BR des espèces
forward
global type br_espece from nonvisualobject
end type
end forward

global type br_espece from nonvisualobject
end type
global br_espece br_espece

forward prototypes
public function integer uf_check_code (any aa_value, ref string as_message)
public function integer uf_check_nomfr (any aa_value, ref string as_message)
public function integer uf_check_nomlat (any aa_value, ref string as_message)
public function integer uf_check_spdnf (any aa_value, ref string as_message)
public function integer uf_check_beforedelete (string as_code, ref string as_message)
public function integer uf_check_comm (any aa_value, ref string as_message)
public function integer uf_check_genre (any aa_value, ref string as_message)
public function integer uf_check_limpu1 (any aa_value, ref string as_message)
public function integer uf_check_limpu2 (any aa_value, ref string as_message)
public function integer uf_check_limpu3 (any aa_value, ref string as_message)
public function integer uf_check_libunitpu1 (any aa_value, ref string as_message)
public function integer uf_check_libunitpu2 (any aa_value, ref string as_message)
public function integer uf_check_libunitpu3 (any aa_value, ref string as_message)
public function integer uf_check_unitpu1 (any aa_value, ref string as_message)
public function integer uf_check_unitpu2 (any aa_value, ref string as_message, decimal a_limpu2)
public function integer uf_check_unitpu3 (any aa_value, ref string as_message, decimal a_limpu3)
public function integer uf_check_passphyto (any aa_value, ref string as_message)
public function integer uf_check_typeqte (any aa_value, ref string as_message)
end prototypes

public function integer uf_check_code (any aa_value, ref string as_message);// CODE_SP obligatoire
string	ls_code

ls_code = string(aa_value)

IF f_IsEmptyString(ls_code) THEN
	as_message = "L'identifiant de l'espèce doit être spécifié"
	return(-1)
END IF

return(1)

end function

public function integer uf_check_nomfr (any aa_value, ref string as_message);// NOM français obligatoire
string	ls_nom

ls_nom = string(aa_value)

IF f_IsEmptyString(ls_nom) THEN
	as_message = "Le NOM FRANCAIS doit être spécifié"
	return(-1)
END IF

return(1)

end function

public function integer uf_check_nomlat (any aa_value, ref string as_message);// NOM latin obligatoire
string	ls_nom

ls_nom = string(aa_value)

IF f_IsEmptyString(ls_nom) THEN
	as_message = "Le NOM LATIN doit être spécifié"
	return(-1)
END IF

return(1)

end function

public function integer uf_check_spdnf (any aa_value, ref string as_message);// code SP DNF obligatoire, doit exister dans CODESP
string	ls_sp

ls_sp = string(aa_value)

IF f_IsEmptyString(ls_sp) THEN
	as_message = "Le code ESPECE DNF doit être spécifié"
	return(-1)
END IF

select esnom into :as_message from CODESP where SP=:ls_sp using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Code espèce DNF inexistant"
	return(-1)
END IF

return(1)

end function

public function integer uf_check_beforedelete (string as_code, ref string as_message);// vérification avant suppression
long	ll_count

as_message = "L'espèce " + f_string(as_code) + " est encore utilisée.~n" + &
"Si vous voulez la supprimer, il faut d'abord supprimer toute référence vers elle dans les provenances &
ou le Registre."

select count(*) into :ll_count from provenance where code_sp = :as_code using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Erreur select PROVENANCE"
	return(-1)
END IF
IF ll_count > 0 THEN
	return(-1)
END IF

select count(*) into :ll_count from registre where code_sp = :as_code using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Erreur select REGISTRE"
	return(-1)
END IF
IF ll_count > 0 THEN
	return(-1)
END IF

return(1)

end function

public function integer uf_check_comm (any aa_value, ref string as_message);// COMM_CAT

return(1)

end function

public function integer uf_check_genre (any aa_value, ref string as_message);// GENRE : obligatoire et doit exister
string	ls_data

ls_data = string(aa_value)

IF f_IsEmptyString(ls_data) THEN
	as_message = "Le genre de l'espèce doit être spécifiée"
	return(-1)
END IF

select trad into :as_message from v_genresp where code=:ls_data using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Genre inexistant"
	return(-1)
END IF

return(1)

end function

public function integer uf_check_limpu1 (any aa_value, ref string as_message);// LIM_PU1
decimal{3}	ld_data

ld_data = dec(aa_value)

IF IsNull(ld_data) OR ld_data <= 0 THEN
	as_message = "Veuillez introduire une limite de poids pour le prix 1"
	return(-1)
END IF

return(1)

end function

public function integer uf_check_limpu2 (any aa_value, ref string as_message);// LIM_PU2
decimal{3}	ld_data

ld_data = dec(aa_value)

IF IsNull(ld_data) THEN
	as_message = "La limite de poids pour le prix 2 ne peut pas être NULL (mais peut valoir 0)"
	return(-1)
END IF

return(1)

end function

public function integer uf_check_limpu3 (any aa_value, ref string as_message);// LIM_PU3
decimal{3}	ld_data

ld_data = dec(aa_value)

IF IsNull(ld_data) THEN
	as_message = "La limite de poids pour le prix 3 ne peut pas être NULL (mais peut valoir 0)"
	return(-1)
END IF

return(1)

end function

public function integer uf_check_libunitpu1 (any aa_value, ref string as_message);// LIB_UNIT_PU1
string	ls_data

ls_data = string(aa_value)

IF f_IsEmptyString(ls_data) THEN
	as_message = "Veuillez spécifier pour quelle quantité se donne le prix 1"
	return(-1)
END IF

return(1)

end function

public function integer uf_check_libunitpu2 (any aa_value, ref string as_message);// LIB_UNIT_PU2

return(1)

end function

public function integer uf_check_libunitpu3 (any aa_value, ref string as_message);// LIB_UNIT_PU3

return(1)

end function

public function integer uf_check_unitpu1 (any aa_value, ref string as_message);// LIM_PU1 : nombre de kg pour lequel se donne le prix 1 
// Ex. : pour 100gr, on met 0.100 et pour 1kg on met 1.000
decimal{3}	ld_data

ld_data = dec(aa_value)

IF IsNull(ld_data) OR ld_data <= 0 THEN
	as_message = "Veuillez préciser pour combien de KG se donne le prix 1 (ex.: introduire 0.100 si le prix se donne pour 100g)"
	return(-1)
END IF

return(1)

end function

public function integer uf_check_unitpu2 (any aa_value, ref string as_message, decimal a_limpu2);// LIM_PU2 : nombre de kg pour lequel se donne le prix 2
// Ex. : pour 100gr, on met 0.100 et pour 1kg on met 1.000
// Si la limite de poids pour le prix 2 est donnée, il faut aussi donner l'unité dans lequel elle est donnée.
decimal{3}	ld_data

ld_data = dec(aa_value)

IF a_limpu2 > 0 AND (IsNull(ld_data) OR ld_data <= 0) THEN
	as_message = "Veuillez préciser pour combien de KG se donne le prix 2 (ex.: introduire 0.100 si le prix se donne pour 100g)"
	return(-1)
END IF

IF IsNull(ld_data) THEN
	as_message = "Le champ LIM_PU2 ne peut pas être NULL (mais peut valoir 0)"
	return(-1)
END IF
	
return(1)

end function

public function integer uf_check_unitpu3 (any aa_value, ref string as_message, decimal a_limpu3);// LIM_PU3 : nombre de kg pour lequel se donne le prix 3
// Ex. : pour 100gr, on met 0.100 et pour 1kg on met 1.000
// Si la limite de poids pour le prix 3 est donnée, il faut aussi donner l'unité dans lequel elle est donnée.
decimal{3}	ld_data

ld_data = dec(aa_value)

IF a_limpu3 > 0 AND (IsNull(ld_data) OR ld_data <= 0) THEN
	as_message = "Veuillez préciser pour combien de KG se donne le prix 3 (ex.: introduire 0.100 si le prix se donne pour 100g)"
	return(-1)
END IF

IF IsNull(ld_data) THEN
	as_message = "Le champ LIM_PU3 ne peut pas être NULL (mais peut valoir 0)"
	return(-1)
END IF
	
return(1)

end function

public function integer uf_check_passphyto (any aa_value, ref string as_message);// Passeport phytosanitaire : O/N
string	ls_data

ls_data = string(aa_value)

IF NOT match(ls_data,"^[ON]$") THEN
	as_message = "Passeport phytosanitaire : Oui ou Non"
	return(-1)
END IF

return(1)


end function

public function integer uf_check_typeqte (any aa_value, ref string as_message);// Mesure des caractéristiques : par pesée ou par comptage (P/C)
string	ls_data

ls_data = string(aa_value)

IF NOT match(ls_data,"^[PC]$") THEN
	as_message = "Mesure des caractéristiques : par pesée(P) ou par comptage(C)"
	return(-1)
END IF

return(1)


end function

on br_espece.create
call super::create
TriggerEvent( this, "constructor" )
end on

on br_espece.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

