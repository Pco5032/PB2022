//objectcomments BR provenances
forward
global type br_provenance from nonvisualobject
end type
end forward

global type br_provenance from nonvisualobject
end type
global br_provenance br_provenance

type variables

end variables

forward prototypes
public function integer uf_check_beforedelete (string as_codesp, integer ai_numprov, ref string as_message)
public function integer uf_check_codesp (any aa_value, ref string as_message)
public function integer uf_check_numprov (any aa_value, ref string as_message)
public function integer uf_check_presence_dict (any aa_value, ref string as_message)
public function integer uf_check_abattu (any aa_value, ref string as_message)
public function integer uf_check_fins (any aa_value, ref string as_message)
public function integer uf_check_typemb (any aa_value, ref string as_message)
public function integer uf_check_autotochnie (any aa_value, ref string as_message)
public function integer uf_check_categorie (any aa_value, ref string as_message)
public function integer uf_check_sit_admin_mb (any aa_value, ref string as_message)
public function integer uf_check_nomprov (any aa_value, ref string as_message)
public function integer uf_check_code_leg (any aa_value, ref string as_message)
public function integer uf_check_prop_mb (any aa_value, ref string as_message)
public function integer uf_check_nature_prop (any aa_value, ref string as_message)
public function integer uf_check_gest_mb_prive (any aa_value, ref string as_message, integer ai_gest_mb_public)
public function integer uf_check_gest_mb_public (any aa_value, ref string as_message, string as_gest_mb_prive)
public function integer uf_check_alt1 (any aa_value, ref string as_message)
public function integer uf_check_alt2 (any aa_value, ref string as_message, integer ai_alt1)
public function integer uf_check_code_dnf (any aa_value, ref string as_message, string as_presence_dict, string as_sp, integer ai_numprov)
public function integer uf_check_latitude (any aa_value, ref string as_message)
public function integer uf_check_longitude (any aa_value, ref string as_message)
public function integer uf_check_presence_liste_mb (any aa_value, ref string as_message, integer ai_regprov)
public function integer uf_check_num_regprov (any aa_value, ref string as_message)
end prototypes

public function integer uf_check_beforedelete (string as_codesp, integer ai_numprov, ref string as_message);// vérification avant suppression
long	ll_count

as_message = "La provenance n° " + f_string(ai_numprov) + " de l'espèce " + f_string(as_codesp) + &
" est encore utilisée.~n~n" + "Si vous voulez la supprimer, il faut d'abord supprimer toute référence " + &
"vers elle dans les autorisations et le registre."

select count(*) into :ll_count from autorisation where code_sp = :as_codesp 
	and num_prov = :ai_numprov using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Erreur select AUTORISATION"
	return(-1)
END IF
IF ll_count > 0 THEN
	return(-1)
END IF

select count(*) into :ll_count from registre where code_sp = :as_codesp 
	and num_prov = :ai_numprov using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Erreur select REGISTRE"
	return(-1)
END IF
IF ll_count > 0 THEN
	return(-1)
END IF

return(1)

end function

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

public function integer uf_check_numprov (any aa_value, ref string as_message);// numéro de provenance : entre 1 et 999
integer	li_data

li_data = integer(aa_value)
IF IsNull(li_data) OR li_data <= 0 OR li_data > 999 THEN
	as_message = "Le NUMERO de provenance par espèce doit être compris entre 1 et 999"
	return(-1)
END IF

return(1)


end function

public function integer uf_check_presence_dict (any aa_value, ref string as_message);string	ls_data

ls_data = string(aa_value)
IF NOT match(ls_data,"^[ON]$") THEN
	as_message = "Valeurs possibles pour la présence dans le dictionnaire des provenances : O ou N"
	return(-1)
END IF
return(1)


end function

public function integer uf_check_abattu (any aa_value, ref string as_message);string	ls_data

ls_data = string(aa_value)
IF NOT match(ls_data,"^[ONS]$") THEN
	as_message = "Valeurs possibles pour indiquer que le peuplement est abattu ou pas : Oui, Non, S/O"
	return(-1)
END IF
return(1)


end function

public function integer uf_check_fins (any aa_value, ref string as_message);// fins : obligatoire et doit exister
string	ls_data

ls_data = string(aa_value)
IF f_IsEmptyString(ls_data) THEN
	as_message = "La finalité de la provenance doit être précisée"
	return(-1)
END IF

select trad into :as_message from v_finsprov where code = :ls_data using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Code FINALITE incorrect"
	return(-1)
END IF
return(1)


end function

public function integer uf_check_typemb (any aa_value, ref string as_message);// TYPE_MB : obligatoire et doit exister
string	ls_data

ls_data = string(aa_value)
IF f_IsEmptyString(ls_data) THEN
	as_message = "Le type de matériel de base doit être précisée"
	return(-1)
END IF

select trad into :as_message from v_typemb where code = :ls_data using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Code TYPE DE MATERIEL DE BASE incorrect"
	return(-1)
END IF
return(1)


end function

public function integer uf_check_autotochnie (any aa_value, ref string as_message);// AUTOTOCHNIE : obligatoire et doit exister
string	ls_data

ls_data = string(aa_value)
IF f_IsEmptyString(ls_data) THEN
	as_message = "Le caractère d'autochtonie de la provenance doit être précisé"
	return(-1)
END IF

select trad into :as_message from v_autotochnie where code = :ls_data using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Code AUTOTOCHNIE incorrect"
	return(-1)
END IF
return(1)


end function

public function integer uf_check_categorie (any aa_value, ref string as_message);// CATEGORIE : obligatoire et doit exister
string	ls_data

ls_data = string(aa_value)
IF f_IsEmptyString(ls_data) THEN
	as_message = "La catégorie de la provenance doit être précisée"
	return(-1)
END IF

select trad into :as_message from v_catprov where code = :ls_data using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Code CATEGORIE incorrect"
	return(-1)
END IF
return(1)


end function

public function integer uf_check_sit_admin_mb (any aa_value, ref string as_message);// SIT_ADMIN_MB :  si mentionné, doit exister dans les cantonnements
integer	li_data

li_data = integer(aa_value)
IF IsNull(li_data) OR li_data = 0 THEN
	return(1)
END IF

select cantonnement into :as_message from cantonnement where can = :li_data using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Cantonnement inexistant"
	return(-1)
END IF
return(1)


end function

public function integer uf_check_nomprov (any aa_value, ref string as_message);// Nom doit être mentionné
string	ls_data

ls_data = string(aa_value)
IF f_IsEmptyString(ls_data) THEN
	as_message = "L'intitulé de la provenance doit être spécifié"
	return(-1)
END IF

return(1)


end function

public function integer uf_check_code_leg (any aa_value, ref string as_message);// CODE_LEG :  si mentionné, doit exister dans les textes législatifs
string	ls_data

ls_data = string(aa_value)
IF f_IsEmptyString(ls_data) THEN
	return(1)
END IF

select texte into :as_message from legislation where code_leg = :ls_data using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Texte inexistant"
	return(-1)
END IF

return(1)


end function

public function integer uf_check_prop_mb (any aa_value, ref string as_message);// PROP_MB :  si mentionné, doit exister dans les interlocuteurs de type propriétaire privé ou public
string	ls_data, ls_type

ls_data = string(aa_value)
IF f_IsEmptyString(ls_data) THEN
	return(1)
END IF

select type, interlocuteur into :ls_type, :as_message from interlocuteur where locu = :ls_data using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Interlocuteur inexistant"
	return(-1)
END IF
IF ls_type <> "PPR" AND ls_type <> "PPU" THEN
	as_message = "L'interlocuteur doit être un propriétaire privé ou public"
	return(-1)
END IF
return(1)


end function

public function integer uf_check_nature_prop (any aa_value, ref string as_message);// NATURE_PROP : obligatoire et doit exister
string	ls_data

ls_data = string(aa_value)
IF f_IsEmptyString(ls_data) THEN
	as_message = "La nature de la propriété doit être précisée"
	return(-1)
END IF

select trad into :as_message from v_natureprop where code = :ls_data using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Code NATURE DE LA PROPRIETE incorrect"
	return(-1)
END IF
return(1)


end function

public function integer uf_check_gest_mb_prive (any aa_value, ref string as_message, integer ai_gest_mb_public);// GEST_MB_PRIVE :  si mentionné, doit exister dans les interlocuteurs de type "gestionnaire"
string	ls_data, ls_type

ls_data = string(aa_value)
IF f_IsEmptyString(ls_data) THEN
	return(1)
END IF

// si un gestionnaire public est déjà spécifié, on ne peut pas en même temps spécifier un gestionnaire privé
IF ai_gest_mb_public > 0 THEN
	as_message = "Un gestionnaire public est déjà spécifié. Vous ne pouvez pas simultanément spécifier un gestionnaire privé."
	return(-1)
END IF

select type, interlocuteur into :ls_type, :as_message from interlocuteur where locu = :ls_data using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Interlocuteur inexistant"
	return(-1)
END IF
IF ls_type <> "G" THEN
	as_message = "L'interlocuteur doit être du type 'Gestionnaire'"
	return(-1)
END IF
return(1)


end function

public function integer uf_check_gest_mb_public (any aa_value, ref string as_message, string as_gest_mb_prive);// GEST_MB_PUBLIC :  si mentionné, doit exister dans les cantonnements
integer	li_data

li_data = integer(aa_value)
IF IsNull(li_data) OR li_data = 0 THEN
	return(1)
END IF

// si un gestionnaire privé est déjà spécifié, on ne peut pas en même temps spécifier un gestionnaire public
IF NOT f_IsEmptyString(as_gest_mb_prive) THEN
	as_message = "Un gestionnaire privé est déjà spécifié. Vous ne pouvez pas simultanément spécifier un gestionnaire public."
	return(-1)
END IF

select cantonnement into :as_message from cantonnement where can = :li_data using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Cantonnement inexistant"
	return(-1)
END IF
return(1)


end function

public function integer uf_check_alt1 (any aa_value, ref string as_message);return(1)
end function

public function integer uf_check_alt2 (any aa_value, ref string as_message, integer ai_alt1);// ALT2 n'a de signification que s'il existe une ALT1 (signifie altitude de ... à ...)
integer	li_data

li_data = integer(aa_value)
IF li_data > 0 AND (IsNull(ai_alt1) OR ai_alt1 = 0) THEN
	as_message = "Pour spécifier une altitude finale, vous devez d'abord préciser une altitude initiale"
	return(-1)
END IF

IF li_data > 0 AND li_data < ai_alt1 THEN
	as_message = "Veuillez préciser une altitude finale supérieure à l'altitude initiale"
	return(-1)
END IF

return(1)
end function

public function integer uf_check_code_dnf (any aa_value, ref string as_message, string as_presence_dict, string as_sp, integer ai_numprov);// référence DNF : doit exister si as_presence_dict = O, interdit sinon
// De plus, elle doit être unique dans la table PROVENANCE
string	ls_data, ls_codesp
integer	li_numprov

ls_data = string(aa_value)

IF as_presence_dict = "O" THEN
	IF f_IsEmptyString(ls_data) THEN
		as_message = "Le CODE DE REFERENCE DNF doit être spécifié si la provenance figure au dictionnaire"
		return(-1)
	END IF
ELSE
	IF NOT f_IsEmptyString(ls_data) THEN
		as_message = "Le CODE DE REFERENCE DNF ne peut pas être spécifié si la provenance ne figure pas au dictionnaire"
		return(-1)
	END IF
END IF

select code_sp, num_prov into :ls_codesp, :li_numprov from provenance where code_dnf_dict = :ls_data 
	and (code_sp <> :as_sp OR num_prov <> :ai_numprov) using ESQLCA;
IF f_check_sql(ESQLCA) < 0 THEN
	as_message = "erreur select PROVENANCE"
	return(-1)
END IF
IF ESQLCA.sqlNrows > 0 THEN
	as_message = "Cette référence DNF est déjà utilisée par la provenance " + ls_codesp + "/" + f_string(li_numprov)
	return(-1)
END IF

return(1)


end function

public function integer uf_check_latitude (any aa_value, ref string as_message);string	ls_data

ls_data = string(aa_value)
IF NOT match(ls_data,"^[0-9]+[.][0-9][0-9][NS]$") THEN
	as_message = "Format incorrect. Introduisez les latitudes sous la forme dd.mmN/S"
	return(-1)
END IF
return(1)


end function

public function integer uf_check_longitude (any aa_value, ref string as_message);string	ls_data

ls_data = string(aa_value)
IF NOT match(ls_data,"^[0-9]+[.][0-9][0-9][EW]$") THEN
	as_message = "Format incorrect. Introduisez les longitudes sous la forme ddd.mmE/W"
	return(-1)
END IF
return(1)


end function

public function integer uf_check_presence_liste_mb (any aa_value, ref string as_message, integer ai_regprov);// présence dans liste simplifiée : O/N.
// Si le pays de la région de provenance n'est pas la Belgique, valeur O pas possible

string	ls_data, ls_pays

ls_data = string(aa_value)
IF NOT match(ls_data,"^[ON]$") THEN
	as_message = "Valeurs possibles pour la présence dans la liste simplifiée des espèces : O ou N"
	return(-1)
END IF

IF ls_data = "O" THEN
	select pays into :ls_pays from region_prov where num_regprov = :ai_regprov using ESQLCA;
	IF f_check_sql(ESQLCA) <> 0 THEN
		return(-1)
	END IF
	IF ls_pays <> "BE" THEN
		as_message = "La région de provenance n'étant pas en Belgique, la provenance ne PEUT PAS figurer &
dans la liste simplifiée du catalogue des MB. Veuillez corriger."
		return(-1)
	END IF
END IF
	

return(1)


end function

public function integer uf_check_num_regprov (any aa_value, ref string as_message);// région de provenance : obligatoire et doit exister dans REGION_PROV
integer	li_data

li_data = integer(aa_value)
IF IsNull(li_data) OR li_data = 0 THEN
	as_message = "Le numéro d'identification de la REGION DE PROVENANCE est obligatoire"
	return(-1)
END IF

select nom into :as_message from region_prov where num_regprov=:li_data using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "N° de région de provenance inexistant"
	return(-1)
END IF
return(1)


end function

on br_provenance.create
call super::create
TriggerEvent( this, "constructor" )
end on

on br_provenance.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

