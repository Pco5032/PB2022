//objectcomments BR interlocuteurs
forward
global type br_interlocuteur from nonvisualobject
end type
end forward

global type br_interlocuteur from nonvisualobject
end type
global br_interlocuteur br_interlocuteur

type variables

end variables

forward prototypes
public function integer uf_check_locu (any aa_value, ref string as_message)
public function integer uf_check_interlocuteur (any aa_value, ref string as_message)
public function integer uf_check_type (any aa_value, ref string as_message)
public function integer uf_check_beforedelete (string as_locu, ref string as_message)
public function integer uf_check_pays (any aa_value, ref string as_message)
public function integer uf_check_client (any aa_value, ref string as_message)
public function integer uf_check_tvarn (any aa_value, ref string as_message)
public function integer uf_check_refrrw (any aa_value, ref string as_message)
end prototypes

public function integer uf_check_locu (any aa_value, ref string as_message);// n° obligatoire
string	ls_data

ls_data = string(aa_value)
IF f_IsEmptyString(ls_data) THEN
	as_message = "Le N° d'identification est obligatoire"
	return(-1)
END IF
return(1)


end function

public function integer uf_check_interlocuteur (any aa_value, ref string as_message);// nom obligatoire
string	ls_data

ls_data = string(aa_value)
IF f_IsEmptyString(ls_data) THEN
	as_message = "Le nom de l'interlocuteur est obligatoire"
	return(-1)
END IF
return(1)


end function

public function integer uf_check_type (any aa_value, ref string as_message);// le type d'interlocuteur doit exister
string	ls_data

ls_data = string(aa_value)
IF f_IsEmptyString(ls_data) THEN
	as_message = "Le TYPE d'interlocuteur doit être spécifié"
	return(-1)
END IF

select trad into :as_message from V_TYPELOCU where code=:ls_data using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Type d'interlocuteur inexistant"
	return(-1)
END IF

return(1)


end function

public function integer uf_check_beforedelete (string as_locu, ref string as_message);// vérification avant suppression
long	ll_count

as_message = "L'interlocuteur n° " + f_string(as_locu) + " est encore utilisé.~n~n" + &
"Si vous voulez le supprimer, il faut d'abord supprimer toute référence vers lui dans les provenances, &
les flux sur le registre, les documents fournisseur et les commandes."

select count(*) into :ll_count from provenance where gest_mb_prive = :as_locu using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Erreur select PROVENANCE"
	return(-1)
END IF
IF ll_count > 0 THEN
	return(-1)
END IF

select count(*) into :ll_count from provenance where prop_mb = :as_locu using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Erreur select PROVENANCE"
	return(-1)
END IF
IF ll_count > 0 THEN
	return(-1)
END IF

select count(*) into :ll_count from flux_registre where destinataire = :as_locu using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Erreur select FLUX_REGISTRE"
	return(-1)
END IF
IF ll_count > 0 THEN
	return(-1)
END IF

select count(*) into :ll_count from docfrn where destinataire = :as_locu using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Erreur select DOCFRN"
	return(-1)
END IF
IF ll_count > 0 THEN
	return(-1)
END IF

select count(*) into :ll_count from commande where client = :as_locu using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Erreur select COMMANDE"
	return(-1)
END IF
IF ll_count > 0 THEN
	return(-1)
END IF

return(1)

end function

public function integer uf_check_pays (any aa_value, ref string as_message);// le pays doit être mentionné et doit exister
string	ls_data

ls_data = string(aa_value)
IF f_IsEmptyString(ls_data) THEN
	as_message = "Veuillez spécifier le pays"
	return(1)
END IF

select trad into :as_message from V_PAYS where code=:ls_data using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Code pays inexistant"
	return(-1)
END IF

return(1)


end function

public function integer uf_check_client (any aa_value, ref string as_message);// client : O/N
string	ls_data

ls_data = string(aa_value)

IF NOT match(ls_data,"^[ON]$") THEN
	as_message = "Client : Oui, Non"
	return(-1)
END IF

return(1)

end function

public function integer uf_check_tvarn (any aa_value, ref string as_message);// n° de TVA ou de registre National

return(1)


end function

public function integer uf_check_refrrw (any aa_value, ref string as_message);// n° de répertoire régional SPW

return(1)


end function

on br_interlocuteur.create
call super::create
TriggerEvent( this, "constructor" )
end on

on br_interlocuteur.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

