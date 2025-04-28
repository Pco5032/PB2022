//objectcomments BR pour le paramétrage des codes prestations
forward
global type br_referentiel from nonvisualobject
end type
end forward

global type br_referentiel from nonvisualobject
end type
global br_referentiel br_referentiel

forward prototypes
public function integer uf_check_duree (any aa_value, ref string as_message)
public function integer uf_check_absence (any aa_value, ref string as_message)
public function integer uf_check_irregcompat (any aa_value, ref string as_message)
public function integer uf_check_idprest (any aa_value, ref string as_message)
public function integer uf_check_unite (any aa_value, ref string as_message)
public function integer uf_check_garde (any aa_value, ref string as_message)
public function integer uf_check_cumul (any aa_value, ref string as_message)
public function integer uf_check_intitulef (any aa_value, ref string as_message)
public function integer uf_check_intituled (any aa_value, ref string as_message)
public function integer uf_check_interim (any aa_value, ref string as_message)
public function integer uf_check_beforedelete (integer ai_idprest, ref string as_message)
public function integer uf_check_codef (any aa_value, ref string as_message)
public function integer uf_check_coded (any aa_value, ref string as_message)
end prototypes

public function integer uf_check_duree (any aa_value, ref string as_message);// Durée : pas de test de validité
time	lt_data

lt_data = time(datetime(aa_value))

return(1)

end function

public function integer uf_check_absence (any aa_value, ref string as_message);// Absence O/N
string	ls_data

ls_data = f_string(aa_value)
IF f_isEmptyString(ls_data) OR NOT match(ls_data,"^[ON]$") THEN
	as_message = "Veuillez préciser s'il s'agit d'une prestation de type 'Absence' ou pas"
	return(-1)
END IF

return(1)
end function

public function integer uf_check_irregcompat (any aa_value, ref string as_message);// Type prestation pouvant être utilisé pour une prestation irrégulière O/N
string	ls_data

ls_data = f_string(aa_value)
IF f_isEmptyString(ls_data) OR NOT match(ls_data,"^[ON]$") THEN
	as_message = "Veuillez préciser s'il s'agit d'un type de prestation pouvant être utilisé pour une prestation irrégulière ou pas"
	return(-1)
END IF

return(1)
end function

public function integer uf_check_idprest (any aa_value, ref string as_message);// identifiant obligatoire, compris entre 1 et 999
integer	li_idprest

li_idprest = integer(aa_value)

IF IsNull(li_idprest) OR li_idprest <= 0 OR li_idprest > 999 THEN
	as_message = "L'identifiant de la prestation doit être compris entre 1 et 999"
	return(-1)
END IF

return(1)

end function

public function integer uf_check_unite (any aa_value, ref string as_message);// L'unité doit exister SI elle est spécifiée
string	ls_data

ls_data = string(aa_value)
IF f_isEmptyString(ls_data) THEN
	return(1)
END IF

select trad into :as_message from v_unitprest where code=:ls_data using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Unité inconnue"
	return(-1)
END IF

return(1)
end function

public function integer uf_check_garde (any aa_value, ref string as_message);// Garde O/N
string	ls_data

ls_data = f_string(aa_value)
IF f_isEmptyString(ls_data) OR NOT match(ls_data,"^[ON]$") THEN
	as_message = "Veuillez préciser s'il s'agit d'une prestation de type 'Garde' ou pas"
	return(-1)
END IF

return(1)
end function

public function integer uf_check_cumul (any aa_value, ref string as_message);// Cumuler O/N
string	ls_data

ls_data = f_string(aa_value)
IF f_isEmptyString(ls_data) OR NOT match(ls_data,"^[ON]$") THEN
	as_message = "Veuillez préciser si le temps encodé dans cette prestation doit ou non être cumulé au temps de prestation"
	return(-1)
END IF

return(1)
end function

public function integer uf_check_intitulef (any aa_value, ref string as_message);// intitulé F obligatoire
string	ls_data

ls_data = string(aa_value)

IF f_isEmptyString(ls_data) THEN
	as_message = "L'intitulé francophone de la prestation doit être précisé"
	return(-1)
END IF

return(1)

end function

public function integer uf_check_intituled (any aa_value, ref string as_message);// intitulé D
return(1)

end function

public function integer uf_check_interim (any aa_value, ref string as_message);// Interim O/N
string	ls_data

ls_data = f_string(aa_value)
IF f_isEmptyString(ls_data) OR NOT match(ls_data,"^[ON]$") THEN
	as_message = "Veuillez préciser s'il s'agit d'une prestation de type 'Intérim' ou pas"
	return(-1)
END IF

return(1)
end function

public function integer uf_check_beforedelete (integer ai_idprest, ref string as_message);// vérification avant suppression d'un code prestation
long	ll_count

// suppression de la root impossible (c'est un item virtuel)
IF isNull(ai_idprest) THEN
	as_message = "Suppression de la racine impossible"
	return(-1)
END IF

// Vérifier qu'il n'y a plus de dépendances à ce code dans le référentiel
select count(*) into :ll_count from referentiel where idpere=:ai_idprest using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "ERREUR select REFERENTIEL"
	return(-1)
END IF
IF ll_count > 0 THEN
	as_message = "Veuillez commencer par supprimer tous les codes prestations qui dépendent de celui-ci."
	return(-1)
END IF

// vérifier si ce code prestation est utilisé dans le planning ou le réalisé
select count(*) into :ll_count from planning where idprest=:ai_idprest using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	populateError(20000, "")
	gu_message.uf_unexp("ERREUR select PLANNING")
	return(-1)
END IF
IF isNull(ll_count) OR ll_count = 0 THEN
	select count(*) into :ll_count from realise where idprest=:ai_idprest using ESQLCA;
	IF f_check_sql(ESQLCA) <> 0 THEN
		populateError(20000, "")
		gu_message.uf_unexp("ERREUR select REALISE")
		return(-1)
	END IF
END IF
IF ll_count > 0 THEN
	as_message = "Le code prestation n° " + f_string(ai_idprest) + " est encore utilisé.~n~n" + &
					 "Si vous voulez le supprimer, il faut d'abord supprimer toute référence vers lui " + &
					 "dans le planning et les activités réalisées."
	return(-1)
END IF

return(1)

end function

public function integer uf_check_codef (any aa_value, ref string as_message);// code F obligatoire
string	ls_code

ls_code = string(aa_value)

IF f_isEmptyString(ls_code) THEN
	as_message = "Le code francophone de la prestation doit être spécifié"
	return(-1)
END IF

return(1)

end function

public function integer uf_check_coded (any aa_value, ref string as_message);// code D

return(1)

end function

on br_referentiel.create
call super::create
TriggerEvent( this, "constructor" )
end on

on br_referentiel.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

