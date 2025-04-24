//objectcomments BR autorisations de récolte/transport
forward
global type br_autorisation from nonvisualobject
end type
end forward

global type br_autorisation from nonvisualobject
end type
global br_autorisation br_autorisation

type variables

end variables

forward prototypes
public function integer uf_check_codesp (any aa_value, ref string as_message)
public function integer uf_check_anaut (any aa_value, ref string as_message)
public function integer uf_check_numaut (any aa_value, ref string as_message)
public function integer uf_check_dtdemande (any aa_value, ref string as_message)
public function integer uf_check_numprov (any aa_value, ref string as_message, string as_sp)
public function integer uf_check_beforedelete (integer ai_anaut, integer ai_numaut, ref string as_message)
public function integer uf_check_qtemfrtr (any aa_value, ref string as_message)
public function integer uf_check_destmfrtr (any aa_value, ref string as_message)
public function integer uf_check_remmfrtr (any aa_value, ref string as_message)
public function integer uf_check_numtr (any aa_value, ref string as_message)
public function integer uf_check_dttr (any aa_value, ref string as_message, date adt_aut)
public function integer uf_check_naturemat (any aa_value, ref string as_message, string as_typedem)
public function integer uf_check_typedem (any aa_value, ref string as_message)
public function integer uf_check_anmaturite (any aa_value, ref string as_message, string as_typedem)
public function integer uf_check_dtreceptionformulaire (any aa_value, ref string as_message)
public function integer uf_check_autorisationobtenue (any aa_value, ref string as_message)
end prototypes

public function integer uf_check_codesp (any aa_value, ref string as_message);// code espece obligatoire et doit exister
string	ls_data

ls_data = string(aa_value)
IF f_IsEmptyString(ls_data) THEN
	as_message = "L'espèce doit être précisée"
	return(-1)
END IF

select nom_fr into :as_message from espece where code_sp = :ls_data using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Code espèce incorrect"
	return(-1)
END IF
return(1)


end function

public function integer uf_check_anaut (any aa_value, ref string as_message);// année de l'autorisation
integer	li_data

li_data = integer(aa_value)
IF IsNull(li_data) OR li_data < 1980 OR li_data > 2050 THEN
	as_message = "L'année d'autorisation doit être comprise entre 1980 et 2050"
	return(-1)
END IF

return(1)


end function

public function integer uf_check_numaut (any aa_value, ref string as_message);// numéro d'autorisation : entre 1 et 99
integer	li_data

li_data = integer(aa_value)
IF IsNull(li_data) OR li_data <= 0 OR li_data > 99 THEN
	as_message = "Le NUMERO d'autorisation de récolte doit être compris entre 1 et 99"
	return(-1)
END IF

return(1)


end function

public function integer uf_check_dtdemande (any aa_value, ref string as_message);// Date de demande : obligatoire
date	l_date

l_date = gu_datetime.uf_dfromdt(aa_value)

// date doit être comprise entre le 01/01/1980 et le 31/12/2050
IF IsNull(l_date) OR l_date < date("1980-01-01") OR l_date > date("2050-12-31") THEN
	as_message = "La date de demande doit être comprise entre le 01/01/1980 et le 31/12/2050"
	return(-1)
END IF

return(1)

end function

public function integer uf_check_numprov (any aa_value, ref string as_message, string as_sp);// NUM_PROV : obligatoire et doit exister
integer	li_data

IF uf_check_codesp(as_sp, as_message) = -1 THEN
	as_message = "Veuillez d'abord introduire une espèce correcte"
	return(-1)
END IF

li_data = integer(aa_value)
IF IsNull(li_data) OR li_data = 0 THEN
	as_message = "La provenance doit être spécifiée"
	return(-1)
END IF

select nom into :as_message from provenance where code_sp = :as_sp and num_prov = :li_data using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Provenance inexistante"
	return(-1)
END IF
return(1)


end function

public function integer uf_check_beforedelete (integer ai_anaut, integer ai_numaut, ref string as_message);// vérification avant suppression
long	ll_count

as_message = "L'autorisation n° " + f_string(ai_numaut) + " de l'année " + f_string(ai_anaut) + &
" est encore utilisée.~n~n" + "Si vous voulez la supprimer, il faut d'abord supprimer toute référence " + &
"vers elle dans les certificats-maître."

select count(*) into :ll_count from certificat where an_aut = :ai_anaut and num_aut = :ai_numaut
	 using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Erreur select CERTIFICAT"
	return(-1)
END IF
IF ll_count > 0 THEN
	return(-1)
END IF

return(1)

end function

public function integer uf_check_qtemfrtr (any aa_value, ref string as_message);// si on ajoute une ligne d'autorisation de transport, la quantité est obligatoire
decimal{3}	ld_data

ld_data = dec(aa_value)
IF IsNull(ld_data) OR ld_data <= 0 THEN
	as_message = "La quantité autorisée doit être spécifiée"
	return(-1)
END IF

return(1)


end function

public function integer uf_check_destmfrtr (any aa_value, ref string as_message);// destinataire mentionné sur l'autorisation de transport
return(1)


end function

public function integer uf_check_remmfrtr (any aa_value, ref string as_message);// remarque mentionnée sur l'autorisation de transport
return(1)


end function

public function integer uf_check_numtr (any aa_value, ref string as_message);// numéro d'autorisation de transport : entre 1 et 99
integer	li_data

li_data = integer(aa_value)
IF IsNull(li_data) OR li_data <= 0 OR li_data > 99 THEN
	as_message = "Le NUMERO d'autorisation de transport doit être compris entre 1 et 99"
	return(-1)
END IF

return(1)


end function

public function integer uf_check_dttr (any aa_value, ref string as_message, date adt_aut);// Date de transport : facultative, si elle est mentionnée elle doit être >= date de l'autorisation de récolte
date	l_date_tr

l_date_tr = gu_datetime.uf_dfromdt(aa_value)

IF IsNull(l_date_tr) THEN
	return(1)
END IF

IF IsNull(adt_aut) THEN
	as_message = "Veuillez spécifier la date d'autorisation de récolte avant la date de transport."
	return(-1)
END IF

// date doit être >= à la date d'autorisation de récolte
IF l_date_tr < adt_aut THEN
	as_message = "La date de transport, si mentionnée, doit être >= " + string(adt_aut, "dd/mm/yyyy")
	return(-1)
END IF

return(1)

end function

public function integer uf_check_naturemat (any aa_value, ref string as_message, string as_typedem);// NATUREMAT : obligatoire et doit exister. 
// Attention : le choix 'Graines' est réservé aux autorisations pour mélange !
string	ls_data

ls_data = string(aa_value)
IF f_IsEmptyString(ls_data) THEN
	as_message = "La nature du matériel doit être précisée"
	return(-1)
END IF

IF f_IsEmptyString(as_typedem) THEN
	as_message = "Le type de demande doit être précisé"
	return(-1)
END IF

select trad into :as_message from v_naturemat where code = :ls_data using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Code NATURE_MAT incorrect"
	return(-1)
END IF

IF as_typedem = 'R' AND ls_data = 'G' THEN
	as_message = "Ce choix est réservé aux demandes pour MELANGE de graines"
	return(-1)
END IF

IF as_typedem <> 'R' AND ls_data <> 'G' THEN
	as_message = "Seul le choix 'GRAINES' est possible pour les demandes de MELANGE"
	return(-1)
END IF

return(1)


end function

public function integer uf_check_typedem (any aa_value, ref string as_message);// Type de demande : obligatoire
string	ls_data

ls_data = string(aa_value)
IF f_IsEmptyString(ls_data) THEN
	as_message = "Le type de demande doit être précisé"
	return(-1)
END IF

IF NOT match(ls_data,"^[RAP]$") THEN
	as_message = "Type de demande incorrect. Choix possibles : R, A, P"
	return(-1)
END IF
return(1)


end function

public function integer uf_check_anmaturite (any aa_value, ref string as_message, string as_typedem);// année de maturité : obligatoire pour les demandes de Récolte ou les mélanges de provenances
integer	li_data

li_data = integer(aa_value)

IF as_typedem = "A" THEN
	return(1)
END IF

IF IsNull(li_data) THEN
	as_message = "L'année de maturité doit être spécifiée"
	return(-1)
END IF

IF IsNull(li_data) OR li_data < 1980 OR li_data > 2050 THEN
	as_message = "L'année de maturité doit être comprise entre 1980 et 2050"
	return(-1)
END IF

return(1)


end function

public function integer uf_check_dtreceptionformulaire (any aa_value, ref string as_message);// Date de réception du formulaire de demande d'autorisation
date	l_date

l_date = gu_datetime.uf_dfromdt(aa_value)

// date doit être comprise entre le 01/01/1980 et le 31/12/2050
IF IsNull(l_date) OR l_date < date("1980-01-01") OR l_date > date("2050-12-31") THEN
	as_message = "La date doit être comprise entre le 01/01/1980 et le 31/12/2050"
	return(-1)
END IF

return(1)

end function

public function integer uf_check_autorisationobtenue (any aa_value, ref string as_message);// Autorisation obtenue : Oui - Non - en Attente
string	ls_data

ls_data = f_string(aa_value)

IF f_isEmptyString(ls_data) OR NOT match(ls_data, "[ONA]") THEN
	as_message = "Autorisation obtenue : Oui - Non - en Attente"
	return(-1)
END IF

return(1)

end function

on br_autorisation.create
call super::create
TriggerEvent( this, "constructor" )
end on

on br_autorisation.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

