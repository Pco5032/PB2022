//objectcomments BR bordereau de livraison
forward
global type br_bordliv from nonvisualobject
end type
end forward

global type br_bordliv from nonvisualobject
end type
global br_bordliv br_bordliv

type variables

end variables

forward prototypes
public function integer uf_check_ancmde (any aa_value, ref string as_message)
public function integer uf_check_numcmde (any aa_value, ref string as_message, integer ai_ancmde)
public function integer uf_check_dtbord (any aa_value, ref string as_message)
public function integer uf_check_typeliv (any aa_value, ref string as_message)
public function integer uf_check_fraisport (any aa_value, ref string as_message)
public function integer uf_check_numbord (any aa_value, ref string as_message, integer ai_ancmde, integer ai_numcmde)
public function integer uf_check_beforedelete (integer ai_ancmde, integer ai_numcmde, integer ai_numbord, string as_statut, ref string as_message)
end prototypes

public function integer uf_check_ancmde (any aa_value, ref string as_message);// année du bordereau = année d'un bon de commande existant
integer	li_data
long		ll_count

li_data = integer(aa_value)
IF IsNull(li_data) OR li_data = 0 THEN
	as_message = "Veuillez spécifier l'année de la commande"
	return(-1)
END IF

select count(*) into :ll_count from commande where an_cmde=:li_data using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Erreur select COMMANDE"
	return(-1)
END IF
IF ll_count = 0 THEN
	as_message = "Il n'existe aucune commande pour cette année"
	return(-1)
END IF

return(1)


end function

public function integer uf_check_numcmde (any aa_value, ref string as_message, integer ai_ancmde);// num. de commande du bordereau = n° d'un bon de commande existant
// as_message renvoie le statut de la commande si le n° de commande est valide
integer	li_data

li_data = integer(aa_value)

IF uf_check_ancmde(ai_ancmde, as_message) = -1 THEN
	return(-1)
END IF

IF IsNull(li_data) OR li_data = 0 THEN
	as_message = "Veuillez spécifier un n° de commande"
	return(-1)
END IF

select statut into :as_message from commande where an_cmde=:ai_ancmde and num_cmde=:li_data using ESQLCA;
IF f_check_sql(ESQLCA) < 0 THEN
	as_message = "Erreur select COMMANDE"
	return(-1)
END IF
IF ESQLCA.SQLnrows = 0 THEN
	as_message = "N° de commande inexistant"
	return(-1)
END IF

return(1)


end function

public function integer uf_check_dtbord (any aa_value, ref string as_message);// Date du bordereau : obligatoire
date	l_date

l_date = gu_datetime.uf_dfromdt(aa_value)

// date doit être comprise entre le 01/01/1980 et le 31/12/2050
IF IsNull(l_date) OR l_date < date("1980-01-01") OR l_date > date("2050-12-31") THEN
	as_message = "La date du bordereau de livraison doit être comprise entre le 01/01/1980 et le 31/12/2050"
	return(-1)
END IF

return(1)

end function

public function integer uf_check_typeliv (any aa_value, ref string as_message);// TYPE_LIV : obligatoire et doit exister
string	ls_data

ls_data = string(aa_value)
IF f_IsEmptyString(ls_data) THEN
	as_message = "Le mode de livraison doit être précisé"
	return(-1)
END IF

select trad into :as_message from v_typlivcmde where code = :ls_data using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Code TYPE_LIV incorrect"
	return(-1)
END IF
return(1)


end function

public function integer uf_check_fraisport (any aa_value, ref string as_message);// frais de port : not null
decimal{2}	ld_data

ld_data = dec(aa_value)
IF IsNull(ld_data) THEN
	as_message = "Le champ 'frais de port' ne peut être NULL (0 est par contre autorisé)"
	return(-1)
END IF

return(1)


end function

public function integer uf_check_numbord (any aa_value, ref string as_message, integer ai_ancmde, integer ai_numcmde);// numéro de bordereau : entre 1 et 99
integer	li_data

li_data = integer(aa_value)

IF uf_check_numcmde(ai_numcmde, as_message, ai_ancmde) = -1 THEN
	return(-1)
END IF

IF IsNull(li_data) OR li_data <= 0 OR li_data > 99 THEN
	as_message = "Le NUMERO d'un bordereau de livraison doit être compris entre 1 et 99"
	return(-1)
END IF

return(1)


end function

public function integer uf_check_beforedelete (integer ai_ancmde, integer ai_numcmde, integer ai_numbord, string as_statut, ref string as_message);// vérification avant suppression

IF as_statut <> "C" and as_statut <> "P" THEN
	as_message = "On ne peut pas supprimer les bordereaux de commandes dont le statut est autre que 'confirmé' ou 'Préparé'"
	return(-1)
END IF

return(1)

end function

on br_bordliv.create
call super::create
TriggerEvent( this, "constructor" )
end on

on br_bordliv.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

