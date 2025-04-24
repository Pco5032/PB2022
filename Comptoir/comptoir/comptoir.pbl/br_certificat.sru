//objectcomments BR certificats-maître
forward
global type br_certificat from nonvisualobject
end type
end forward

global type br_certificat from nonvisualobject
end type
global br_certificat br_certificat

type variables

end variables

forward prototypes
public function integer uf_check_cm (any aa_value, ref string as_message)
public function integer uf_check_typemfr (any aa_value, ref string as_message)
public function integer uf_check_commfr (any aa_value, ref string as_message)
public function integer uf_check_pollinisation (any aa_value, ref string as_message)
public function integer uf_check_beforedelete (string as_cm, ref string as_message)
public function integer uf_check_qtemfr (any aa_value, ref string as_message)
public function integer uf_check_tpselevage (any aa_value, ref string as_message)
public function integer uf_check_methreprod (any aa_value, ref string as_message)
public function integer uf_check_hybridation (any aa_value, ref string as_message)
public function integer uf_check_info (any aa_value, ref string as_message)
public function integer uf_check_scan (any aa_value, ref string as_message)
public function integer uf_check_subdivlot (any aa_value, ref string as_message)
public function integer uf_check_reprodveget (any aa_value, ref string as_message)
public function integer uf_check_melange (any aa_value, ref string as_message)
public function integer uf_check_qtelotinitial (any aa_value, ref string as_message)
public function integer uf_check_nbcycle (any aa_value, ref string as_message)
public function integer uf_check_clonecomposant (any aa_value, ref string as_message)
public function integer uf_check_pchybridation (any aa_value, ref string as_message)
public function integer uf_check_nbclonemel (any aa_value, ref string as_message)
public function integer uf_check_pcclonemel (any aa_value, ref string as_message)
public function integer uf_check_famillecomposant (any aa_value, ref string as_message)
public function integer uf_check_anaut (any aa_value, ref string as_message)
public function integer uf_check_clone_num (any aa_value, ref string as_message)
public function integer uf_check_clone_clone (any aa_value, ref string as_message)
public function integer uf_check_clone_pcnb (any aa_value, ref string as_message)
public function integer uf_check_naturemfr (any aa_value, ref string as_message, string as_typemfr)
public function integer uf_check_numaut (any aa_value, ref string as_message, integer ai_annee, string as_typemfr, string as_currentcm)
public function integer uf_check_numcmdiv (any aa_value, ref string as_message, string as_subdiv)
public function integer uf_check_remdiv (any aa_value, ref string as_message)
end prototypes

public function integer uf_check_cm (any aa_value, ref string as_message);// format du n° de certificat
// Au 25/09/2008, seuls les certificats pour récolte par le Comptoir en Wallonie sont autorisés
string	ls_data

ls_data = string(aa_value)

// 25/11/2008 : le contrôle de validité du CM est différent pour les anciens n° et les nouveaux.
// on repère les nouveaux n° car ils ont les caractères CF en position 6 et 7
IF MidA(ls_data, 6, 2) = 'CF' THEN
	IF NOT match(ls_data, "^BRW[0-9][0-9][A-Z][A-Z][0-9][0-9][0-9][0-9]$") THEN
		as_message = "Le format du n° de certificat-maître est incorrect. Format correct : B-RW/nn-CF-nn-nn"
		return(-1)
	END IF
ELSE
	IF NOT match(ls_data, "^BRW") THEN
		as_message = "Le format du n° de certificat-maître est incorrect. Format correct : B-RW/aaaaaaaa"
		return(-1)
	END IF
END IF

return(1)


end function

public function integer uf_check_typemfr (any aa_value, ref string as_message);// TYPEMFR : obligatoire et doit exister
string	ls_data

ls_data = string(aa_value)
IF f_IsEmptyString(ls_data) THEN
	as_message = "Le type de matériel de reproduction doit être précisé"
	return(-1)
END IF

select trad into :as_message from v_typemfr where code = :ls_data using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Type de matériel de reproduction incorrect"
	return(-1)
END IF
return(1)


end function

public function integer uf_check_commfr (any aa_value, ref string as_message);// COMMFR : obligatoire et doit exister
string	ls_data

ls_data = string(aa_value)
IF f_IsEmptyString(ls_data) THEN
	as_message = "Le type de législation suivie doit être précisé"
	return(-1)
END IF

select trad into :as_message from v_commfr where code = :ls_data using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Type de législation suivi incorrect"
	return(-1)
END IF
return(1)


end function

public function integer uf_check_pollinisation (any aa_value, ref string as_message);// POLINISATION : obligatoire et doit exister
string	ls_data

ls_data = string(aa_value)
IF f_IsEmptyString(ls_data) THEN
	as_message = "Le type de pollinisation doit être précisé"
	return(-1)
END IF

select trad into :as_message from v_pollinisation where code = :ls_data using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Type de pollinisation incorrect"
	return(-1)
END IF
return(1)


end function

public function integer uf_check_beforedelete (string as_cm, ref string as_message);// vérification avant suppression
long	ll_count

as_message = "Le certificat-maître n° " + as_cm + " est encore utilisé.~n~n" + &
"Si vous voulez le supprimer, il faut d'abord supprimer toute référence vers lui dans le registre."

select count(*) into :ll_count from registre where num_cm = :as_cm using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Erreur select REGISTRE"
	return(-1)
END IF
IF ll_count > 0 THEN
	return(-1)
END IF

return(1)

end function

public function integer uf_check_qtemfr (any aa_value, ref string as_message);// quantité de MFR obligatoire
decimal{3}	ld_data

ld_data = dec(aa_value)
IF IsNull(ld_data) OR ld_data <= 0 THEN
	as_message = "La quantité de MFR doit être spécifiée"
	return(-1)
END IF

return(1)


end function

public function integer uf_check_tpselevage (any aa_value, ref string as_message);// temps d'élevage
return(1)


end function

public function integer uf_check_methreprod (any aa_value, ref string as_message);// méthode de reproduction
return(1)


end function

public function integer uf_check_hybridation (any aa_value, ref string as_message);// schéma d'hynridation
return(1)


end function

public function integer uf_check_info (any aa_value, ref string as_message);// autres infos
return(1)


end function

public function integer uf_check_scan (any aa_value, ref string as_message);// scan
return(1)


end function

public function integer uf_check_subdivlot (any aa_value, ref string as_message);// subdivision d'un lot
string	ls_data

ls_data = string(aa_value)

IF NOT match(ls_data,"^[ON]$") THEN
	as_message = "Subdivision d'un lot + important : Oui, Non"
	return(-1)
END IF

return(1)


end function

public function integer uf_check_reprodveget (any aa_value, ref string as_message);// reproduction végétative
string	ls_data

ls_data = string(aa_value)

IF NOT match(ls_data,"^[ON]$") THEN
	as_message = "Reproduction végétative ultérieure : Oui ou Non"
	return(-1)
END IF

return(1)


end function

public function integer uf_check_melange (any aa_value, ref string as_message);// mélange : N=Non, P=Mélange de provenances, A=Mélange d'années de maturité
string	ls_data

ls_data = string(aa_value)

IF NOT match(ls_data,"^[NPA]$") THEN
	as_message = "Mélange : N=Non, P=mélange de Provenances, A=mélange d'Années de maturité"
	return(-1)
END IF

return(1)


end function

public function integer uf_check_qtelotinitial (any aa_value, ref string as_message);// qté lot initial
return(1)


end function

public function integer uf_check_nbcycle (any aa_value, ref string as_message);// nombre de cycles
return(1)


end function

public function integer uf_check_clonecomposant (any aa_value, ref string as_message);// clone composant
return(1)

end function

public function integer uf_check_pchybridation (any aa_value, ref string as_message);// % hybridation
return(1)

end function

public function integer uf_check_nbclonemel (any aa_value, ref string as_message);// nombre de clones dans le mélange
return(1)

end function

public function integer uf_check_pcclonemel (any aa_value, ref string as_message);// % relatif de clones composant
return(1)

end function

public function integer uf_check_famillecomposant (any aa_value, ref string as_message);// famille composant
return(1)

end function

public function integer uf_check_anaut (any aa_value, ref string as_message);// année de l'autorisation de récolte
integer	li_data

li_data = integer(aa_value)
IF IsNull(li_data) OR li_data < 1980 OR li_data > 2050 THEN
	as_message = "L'année d'autorisation de récolte doit être comprise entre 1980 et 2050"
	return(-1)
END IF

return(1)
end function

public function integer uf_check_clone_num (any aa_value, ref string as_message);// n° de ligne 'composant clone'
integer	li_data

li_data = integer(aa_value)
IF IsNull(li_data) OR li_data <= 0 THEN
	as_message = "Le NUMERO de la ligne 'clone' doit être compris entre 1 et 999"
	return(-1)
END IF

return(1)
end function

public function integer uf_check_clone_clone (any aa_value, ref string as_message);// info clone
string	ls_data

ls_data = string(aa_value)
IF f_isEmptyString(ls_data) THEN
	as_message = "L'info sur le CLONE doit être donnée"
	return(-1)
END IF

return(1)
end function

public function integer uf_check_clone_pcnb (any aa_value, ref string as_message);// info clone : % / nbre

return(1)
end function

public function integer uf_check_naturemfr (any aa_value, ref string as_message, string as_typemfr);// NATUREMFR : obligatoire et doit exister, type 'semences' pas possible avec type de certificat 3
string	ls_data

ls_data = string(aa_value)
IF f_IsEmptyString(ls_data) THEN
	as_message = "La nature des matériels de reproduction doit être précisée"
	return(-1)
END IF

select trad into :as_message from v_naturemfr where code = :ls_data using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Nature des matériels de reproduction incorrect"
	return(-1)
END IF

IF as_typemfr = "3" AND ls_data = "1" THEN
	as_message = "La nature 'Semences' n'est pas valide avec ce type de certificat"
	return(-1)
END IF

return(1)


end function

public function integer uf_check_numaut (any aa_value, ref string as_message, integer ai_annee, string as_typemfr, string as_currentcm);// autorisation de récolte obligatoire et doit exister
// En fonction du type de certificat, on ne peut choisir que des autorisations portant sur des
// provenances de certains types de matériel de base.
// Idem pour la catégorie de matériel de reproduction.
// Une autorisation ne peut être référencée que par un seul CM
integer	li_data, li_numprov
string	ls_codesp, ls_typemb, ls_categorie, ls_numcm

IF IsNull(ai_annee) OR ai_annee = 0 THEN
	as_message = "Il faut d'abord spécifier l'année d'autorisation avant son n°."
	return(-1)
END IF

li_data = integer(aa_value)
IF IsNull(li_data) OR li_data = 0 THEN
	as_message = "Le n° d'autorisation doit être précisé"
	return(-1)
END IF

select code_sp, num_prov into :ls_codesp, :li_numprov from autorisation 
	where an_aut = :ai_annee and num_aut = :li_data using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "N° d'autorisation inexistant"
	return(-1)
END IF

select type_mb, categorie into :ls_typemb, :ls_categorie from provenance
	where code_sp=:ls_codesp and num_prov=:li_numprov using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Erreur de lecture de la provenance de cette autorisation"
	return(-1)
END IF

as_message = "Le type de matériel de base de la provenance n'est pas compatible avec ce type de certificat"
CHOOSE CASE as_typemfr
	CASE "1"
		IF ls_typemb <> "1" AND ls_typemb <> "2" THEN
			return(-1)
		END IF
	CASE "2"
		IF ls_typemb <> "3" AND ls_typemb <> "4" THEN
			return(-1)
		END IF
	CASE "3"
		IF ls_typemb <> "5" AND ls_typemb <> "6" THEN
			return(-1)
		END IF
END CHOOSE

as_message = "La catégorie des matériels de reproduction de la provenance n'est pas compatible avec ce type de certificat"
CHOOSE CASE as_typemfr
	CASE "1"
		IF ls_categorie <> "I" AND ls_categorie <> "S" AND ls_categorie <> "T" THEN
			return(-1)
		END IF
	CASE "2", "3"
		IF ls_categorie <> "Q" AND ls_categorie <> "T" THEN
			return(-1)
		END IF
END CHOOSE

select num_cm into :ls_numcm from certificat where an_aut = :ai_annee 
	and num_aut = :li_data and num_cm <> :as_currentcm using ESQLCA;
IF f_check_sql(ESQLCA) <> 100 THEN
	as_message = "Le certificat n° " + ls_numcm + " fait déjà référence à cette autorisation"
	return(-1)
END IF

return(1)


end function

public function integer uf_check_numcmdiv (any aa_value, ref string as_message, string as_subdiv);// N° de certificat maître antérieur pour les lots divisés: 
//		. obligatoire et doit exister si le CM est issu d'une division de lot
string	ls_data

ls_data = string(aa_value)

IF as_subdiv = "N" THEN
	return(1)
END IF

IF f_IsEmptyString(ls_data) THEN
	as_message = "Matériel issus d'une subdivision d'un lot + important : le n° de certificat-maître d'origine doit être mentionné"
	return(-1)
END IF

select type_mfr into :as_message from certificat where num_cm = :ls_data using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Certificat-maître inexistant"
	return(-1)
END IF

return(1)


end function

public function integer uf_check_remdiv (any aa_value, ref string as_message);// remarque pour les CM issus d'une subdivision d'un lot + important
return(1)


end function

on br_certificat.create
call super::create
TriggerEvent( this, "constructor" )
end on

on br_certificat.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

