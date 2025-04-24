//objectcomments BR documents fournisseurs
forward
global type br_docfrn from nonvisualobject
end type
end forward

global type br_docfrn from nonvisualobject
end type
global br_docfrn br_docfrn

type variables

end variables

forward prototypes
public function integer uf_check_beforedelete (string as_docfrn, ref string as_message)
public function integer uf_check_numcaract (any aa_value, ref string as_message, string as_reflot, date a_dtcaract)
public function integer uf_check_dtcaract (any aa_value, ref string as_message, string as_reflot)
public function integer uf_check_conserv (any aa_value, ref string as_message)
public function integer uf_check_dureeconserv (any aa_value, ref string as_message)
public function integer uf_check_pretrt (any aa_value, ref string as_message)
public function integer uf_check_avpretrt (any aa_value, ref string as_message)
public function integer uf_check_sspretrt (any aa_value, ref string as_message)
public function integer uf_check_nbcolis (any aa_value, ref string as_message)
public function integer uf_check_remarque (any aa_value, ref string as_message)
public function integer uf_check_autresinfo (any aa_value, ref string as_message)
public function integer uf_check_destinataire (any aa_value, ref string as_message, string as_type)
public function integer uf_check_numdf (any aa_value, ref string as_message)
public function integer uf_check_qteavpretrt (any aa_value, ref string as_message)
public function integer uf_check_qtesspretrt (any aa_value, ref string as_message)
public function integer uf_check_dtsign (any aa_value, ref string as_message)
public function integer uf_check_rp (any aa_value, ref string as_message)
public function integer uf_check_type (any aa_value, ref string as_message, string as_numdf)
public function integer uf_check_numcat (any aa_value, ref string as_message, string as_type, string as_lot)
public function integer uf_check_reflot (any aa_value, ref string as_message, string as_typedf)
public function integer uf_check_cphys (any aa_value, ref string as_message, string as_reflot)
public function integer uf_check_qgerm (any aa_value, ref string as_message, string as_reflot)
end prototypes

public function integer uf_check_beforedelete (string as_docfrn, ref string as_message);// vérification avant suppression
long	ll_count

as_message = "Le document fournisseur n° " + f_string(as_docfrn) + " est encore utilisé.~n~n" + &
"Si vous voulez le supprimer, il faut d'abord supprimer toute référence vers lui dans le détail des commandes."

select count(*) into :ll_count from DETAIL_CMDE where num_df_emis = :as_docfrn using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Erreur select DETAIL_CMDE"
	return(-1)
END IF
IF ll_count > 0 THEN
	return(-1)
END IF

return(1)

end function

public function integer uf_check_numcaract (any aa_value, ref string as_message, string as_reflot, date a_dtcaract);// PCO NOV 2013 : ancienne structure de caractéristiques plus utilisée
// Si mentionnée, l'identification des caractéristiques des graines doit exister 
integer	li_data
long		ll_count

li_data = integer(aa_value)

IF IsNull(a_dtcaract) AND IsNull(li_data) THEN
	return(1)
END IF

IF f_IsEmptyString(as_reflot) OR IsNull(a_dtcaract) THEN
	as_message = "Il faut d'abord spécifier la référence du lot et la date des caractéristiques avant son n°"
	return(-1)
END IF

IF IsNull(li_data) OR li_data = 0 THEN
	as_message = "Le n° doit être précisé"
	return(-1)
END IF

select count(*) into :ll_count from caract_graine
	where ref_lot = :as_reflot and dt_caract = :a_dtcaract and num_caract = :li_data using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Erreur SELECT CARACT_GRAINE"
	return(-1)
END IF
IF ll_count = 0 THEN
	as_message = "Caractéristiques des graines inexistantes"
	return(-1)
END IF

return(1)


end function

public function integer uf_check_dtcaract (any aa_value, ref string as_message, string as_reflot);// PCO NOV 2013 : ancienne structure de caractéristiques plus utilisée
// Si mentionnée, l'identification des caractéristiques des graines doit exister
date	l_date
long	ll_count

IF f_IsEmptyString(as_reflot) THEN
	as_message = "Il faut d'abord spécifier la référence du lot avant d'en identifier les caractéristiques de graines"
	return(-1)
END IF

l_date = gu_datetime.uf_dfromdt(aa_value)

IF IsNull(l_date) THEN
	return(1)
END IF

select count(*) into :ll_count from caract_graine
	where ref_lot = :as_reflot and dt_caract = :l_date using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Erreur SELECT CARACT_GRAINE"
	return(-1)
END IF
IF ll_count = 0 THEN
	as_message = "Il n'existe aucune caractéristique de graines à cette date."
	return(-1)
END IF

return(1)


end function

public function integer uf_check_conserv (any aa_value, ref string as_message);// conservation : O/N/S
string	ls_data

ls_data = string(aa_value)
IF f_IsEmptyString(ls_data) THEN
	as_message = "Le champ CONSERVATION doit être spécifié"
	return(-1)
END IF

IF NOT match(ls_data,"^[ONS]$") THEN
	as_message = "Conservation : Oui, Non, S/O"
	return(-1)
END IF

return(1)


end function

public function integer uf_check_dureeconserv (any aa_value, ref string as_message);// duree conservation

return(1)


end function

public function integer uf_check_pretrt (any aa_value, ref string as_message);// pré-traitement

return(1)


end function

public function integer uf_check_avpretrt (any aa_value, ref string as_message);// qté avec pré-traitement : ne peut pas être nulle ou 0
decimal	ld_data

ld_data = dec(aa_value)
IF IsNull(ld_data) OR ld_data <= 0 THEN
	as_message = "La quantité avec pré-traitement doit être mentionnée"
	return(-1)
END IF

return(1)


end function

public function integer uf_check_sspretrt (any aa_value, ref string as_message);// qté sans pré-traitement : ne peut pas être nulle ou 0
decimal	ld_data

ld_data = dec(aa_value)
IF IsNull(ld_data) OR ld_data <= 0 THEN
	as_message = "La quantité sans pré-traitement doit être mentionnée"
	return(-1)
END IF

return(1)


end function

public function integer uf_check_nbcolis (any aa_value, ref string as_message);// nombre de colis : ne peut pas être nulle ou 0
integer	li_data

li_data = integer(aa_value)
IF IsNull(li_data) OR li_data <= 0 THEN
	as_message = "Le nombre de colis doit être mentionné"
	return(-1)
END IF

return(1)


end function

public function integer uf_check_remarque (any aa_value, ref string as_message);// remarque

return(1)


end function

public function integer uf_check_autresinfo (any aa_value, ref string as_message);// autres infos

return(1)


end function

public function integer uf_check_destinataire (any aa_value, ref string as_message, string as_type);// destinataire obligatoire pour les docfrn émis, et doit être CLIENT=O
string	ls_data, ls_client

IF as_type = "R" THEN
	as_message = ""
	return(1)
END IF

ls_data = string(aa_value)
IF f_IsEmptyString(ls_data) THEN
	as_message = "Le destinataire est obligatoire dans les documents fournisseurs EMIS"
	return(-1)
END IF

select interlocuteur, client into :as_message, :ls_client from interlocuteur 
	where locu = :ls_data using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Destinataire inexistant"
	return(-1)
END IF

IF ls_client <> "O" THEN
	as_message = "Cet interlocuteur n'est pas un client"
	return(-1)
END IF

return(1)


end function

public function integer uf_check_numdf (any aa_value, ref string as_message);// n° obligatoire
string	ls_data

ls_data = string(aa_value)
IF f_IsEmptyString(ls_data) THEN
	as_message = "Le N° de document founisseur est obligatoire"
	return(-1)
END IF
return(1)


end function

public function integer uf_check_qteavpretrt (any aa_value, ref string as_message);// quantité avec prétraitement : ne peut pas être nulle
decimal	ld_data

ld_data = dec(aa_value)
IF IsNull(ld_data) THEN
	as_message = "La quantité avec pré-traitement doit être mentionnée"
	return(-1)
END IF

return(1)


end function

public function integer uf_check_qtesspretrt (any aa_value, ref string as_message);// quantité sans prétraitement : ne peut pas être nulle
decimal	ld_data

ld_data = dec(aa_value)
IF IsNull(ld_data) THEN
	as_message = "La quantité sans pré-traitement doit être mentionnée"
	return(-1)
END IF

return(1)


end function

public function integer uf_check_dtsign (any aa_value, ref string as_message);// la date de signature doit être mentionnée
date	l_date

l_date = gu_datetime.uf_dfromdt(aa_value)

IF IsNull(l_date) THEN
	as_message = "La date de signature doit être mentionnée"
	return(-1)
END IF

return(1)


end function

public function integer uf_check_rp (any aa_value, ref string as_message);// colonne RP

return(1)

end function

public function integer uf_check_type (any aa_value, ref string as_message, string as_numdf);// le type de document fournisseur doit valoir E ou R
// Le type ne PEUT pas valoir E si la longueur du n° de DF est > 10 caractères
string	ls_data

ls_data = string(aa_value)
IF f_IsEmptyString(ls_data) THEN
	as_message = "Le TYPE de document fournisseur doit être spécifié"
	return(-1)
END IF

IF ls_data <> "E" AND ls_data <> "R" THEN
	as_message = "Type de document fournisseur incorrect"
	return(-1)
END IF

IF ls_data = "E" AND LenA(as_numdf) > 10 THEN
	as_message = "Le n° du DF dépasse 10 caractères : il ne peut s'agir d'un document EMIS."
	return(-1)
END IF

return(1)


end function

public function integer uf_check_numcat (any aa_value, ref string as_message, string as_type, string as_lot);// le n° de catalogue est obligatoire pour les docfrn émis, il doit exister, et le lot indiqué
// dans le docfrn doit figurer au catalogue
integer	li_data
string	ls_data

li_data = integer(aa_value)
IF IsNull(li_data) THEN
	as_message = "Le n° de catalogue doit être mentionné (donner la valeur 0 pour les documents reçus)"
	return(-1)
END IF

IF as_type = "R" THEN
	return(1)
END IF

select saison into :as_message from cat_vente where num_cat = :li_data using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "N° de catalogue inexistant"
	return(-1)
END IF

select ref_lot into :ls_data from cat_vente_lot where num_cat = :li_data and ref_lot = :as_lot using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Le lot indiqué dans ce document fournisseur ne figure pas au catalogue choisi"
	return(-1)
END IF

return(1)


end function

public function integer uf_check_reflot (any aa_value, ref string as_message, string as_typedf);// référence du lot obligatoire et doit exister
// Si on est dans un docfrn RECU, on doit choisir un lot de type Achat/négoce
string	ls_data, ls_typegraine

ls_data = string(aa_value)
IF f_IsEmptyString(ls_data) THEN
	as_message = "Le référence du LOT doit être précisée"
	return(-1)
END IF

select type_graine into :ls_typegraine from registre where ref_lot = :ls_data using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Référence de lot inexistante"
	return(-1)
END IF
IF as_typedf = "R" and ls_typegraine <> "A" THEN
	as_message = "Document fournisseur reçu : le lot doit être de type achat/négoce"
	return(-1)
END IF
	

return(1)

end function

public function integer uf_check_cphys (any aa_value, ref string as_message, string as_reflot);// Si mentionné, le n° des caractéristiques physiques des graines doit exister dans le lot
integer	li_data
long		ll_count
date		l_date
string	ls_rem

li_data = integer(aa_value)

IF IsNull(li_data) OR li_data = 0 THEN
	as_message = ""
	return(1)
END IF

IF f_IsEmptyString(as_reflot) THEN
	as_message = "Il faut spécifier la référence du lot avant le n° de ses caractéristiques"
	return(-1)
END IF

select dt_cphys, rem into :l_date, :ls_rem from registre_cphys
	where ref_lot = :as_reflot and num_cphys = :li_data using ESQLCA;
IF f_check_sql(ESQLCA) < 0 THEN
	as_message = "Erreur SELECT REGISTRE_CPHYS"
	return(-1)
END IF
IF esqlca.sqlnrows = 0 THEN
	as_message = "Caractéristiques physiques des graines inexistantes dans ce lot"
	return(-1)
ELSE
	ls_rem = gu_stringservices.uf_replaceall(ls_rem, '"', "'")
	as_message = string(l_date, "dd/mm/yyyy") + " - " + f_string(ls_rem)
	return(1)
END IF

return(1)


end function

public function integer uf_check_qgerm (any aa_value, ref string as_message, string as_reflot);// Si mentionné, le n° des qualités germinatives des graines doit exister dans le lot
integer	li_data
long		ll_count
string	ls_rem
date		l_date

li_data = integer(aa_value)

IF IsNull(li_data) OR li_data = 0 THEN
	as_message = ""
	return(1)
END IF

IF f_IsEmptyString(as_reflot) THEN
	as_message = "Il faut spécifier la référence du lot avant le n° de ses qualités germinatives"
	return(-1)
END IF

select dt_qgerm, rem into :l_date, :ls_rem from registre_qgerm
	where ref_lot = :as_reflot and num_qgerm = :li_data using ESQLCA;
IF f_check_sql(ESQLCA) < 0 THEN
	as_message = "Erreur SELECT REGISTRE_QGERM"
	return(-1)
END IF
IF esqlca.sqlnrows = 0 THEN
	as_message = "Qualités germinatives des graines inexistantes dans ce lot"
	return(-1)
ELSE
	ls_rem = gu_stringservices.uf_replaceall(ls_rem, '"', "'")
	as_message = string(l_date, "dd/mm/yyyy") + " - " + f_string(ls_rem)
	return(1)
END IF

return(1)


end function

on br_docfrn.create
call super::create
TriggerEvent( this, "constructor" )
end on

on br_docfrn.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

