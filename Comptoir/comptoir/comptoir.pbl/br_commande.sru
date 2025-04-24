//objectcomments BR commandes
forward
global type br_commande from nonvisualobject
end type
end forward

global type br_commande from nonvisualobject
end type
global br_commande br_commande

type variables

end variables

forward prototypes
public function integer uf_check_ancmde (any aa_value, ref string as_message)
public function integer uf_check_numcat (any aa_value, ref string as_message)
public function integer uf_check_client (any aa_value, ref string as_message)
public function integer uf_check_statut (any aa_value, ref string as_message)
public function integer uf_check_dtcmde (any aa_value, ref string as_message)
public function integer uf_check_dtprepa (any aa_value, ref string as_message)
public function integer uf_check_dtliv (any aa_value, ref string as_message, string as_statut)
public function integer uf_check_detail_qteprepa (any aa_value, ref string as_message)
public function integer uf_check_detail_qtelivre (any aa_value, ref string as_message)
public function integer uf_check_detail_qtefacture (any aa_value, ref string as_message)
public function integer uf_check_numcmde (any aa_value, ref string as_message)
public function integer uf_check_detail_numbord (any aa_value, ref string as_message, integer ai_an, integer ai_num)
public function integer uf_check_detail_beforedelete (ref string as_message, string as_statut, integer ai_numbord)
public function integer uf_check_detail_qteconfirm (any aa_value, ref string as_message, decimal ad_qtestock)
public function integer uf_check_beforedelete (string as_statut, ref string as_message)
public function integer uf_check_detail_reflot (any aa_value, ref string as_message, integer ai_numcat)
public function integer uf_check_detail_qtecmde (any aa_value, ref string as_message)
public function integer uf_check_dtbordrecap (any aa_value, ref string as_message, string as_statut)
public function integer uf_check_rembordrecap (any aa_value, ref string as_message)
public function integer uf_check_montantrf (any aa_value, ref string as_message, decimal ad_mtcmde)
public function integer uf_check_detail_pretrt (any aa_value, ref string as_message, integer ai_an, integer ai_num)
public function integer uf_check_detail_numdfemis (any aa_value, ref string as_message, string as_client, string as_reflot, integer ai_numcat, integer ai_ancmde, integer ai_numcmde)
end prototypes

public function integer uf_check_ancmde (any aa_value, ref string as_message);// année de la commande
integer	li_data

li_data = integer(aa_value)
IF IsNull(li_data) OR li_data < 1980 OR li_data > 2050 THEN
	as_message = "L'année de la commande doit être comprise entre 1980 et 2050"
	return(-1)
END IF

return(1)


end function

public function integer uf_check_numcat (any aa_value, ref string as_message);// n° de catalogue obligatoire et doit exister
integer	li_data

li_data = integer(aa_value)
IF IsNull(li_data) OR li_data = 0 THEN
	as_message = "Le n° de catalogue doit être précisée"
	return(-1)
END IF

select saison into :as_message from cat_vente where num_cat = :li_data using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Catalogue inexistant"
	return(-1)
END IF

return(1)

end function

public function integer uf_check_client (any aa_value, ref string as_message);// client obligatoire, et doit être CLIENT=O
string	ls_data, ls_client

ls_data = string(aa_value)
IF f_IsEmptyString(ls_data) THEN
	as_message = "Le n° de client est obligatoire"
	return(-1)
END IF

select interlocuteur, client into :as_message, :ls_client from interlocuteur 
	where locu = :ls_data using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Client inexistant"
	return(-1)
END IF

IF ls_client <> "O" THEN
	as_message = "Cet interlocuteur n'est pas un client"
	return(-1)
END IF

return(1)


end function

public function integer uf_check_statut (any aa_value, ref string as_message);// Statut obligatoire et doit exister
string	ls_data

ls_data = string(aa_value)
IF f_IsEmptyString(ls_data) THEN
	as_message = "Le statut de la commande doit être précisée"
	return(-1)
END IF

select trad into :as_message from v_statutcmde where code = :ls_data using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Statut inexistant"
	return(-1)
END IF

return(1)

end function

public function integer uf_check_dtcmde (any aa_value, ref string as_message);// la date de commande est obligatoire
date	l_date

l_date = gu_datetime.uf_dfromdt(aa_value)

// date doit être comprise entre le 01/01/1980 et le 31/12/2050
IF IsNull(l_date) OR l_date < date("1980-01-01") OR l_date > date("2050-12-31") THEN
	as_message = "La date de commande doit être comprise entre le 01/01/1980 et le 31/12/2050"
	return(-1)
END IF


return(1)


end function

public function integer uf_check_dtprepa (any aa_value, ref string as_message);// si mentionnée, la date de préparation doit être correcte
date	l_date

l_date = gu_datetime.uf_dfromdt(aa_value)

IF IsNull(l_date) THEN
	return(1)
END IF

// date doit être comprise entre le 01/01/1980 et le 31/12/2050
IF IsNull(l_date) OR l_date < date("1980-01-01") OR l_date > date("2050-12-31") THEN
	as_message = "La date de commande doit être comprise entre le 01/01/1980 et le 31/12/2050"
	return(-1)
END IF


return(1)


end function

public function integer uf_check_dtliv (any aa_value, ref string as_message, string as_statut);// si mentionnée, la date de livraison doit être correcte
// Elle est obligatoire si le statut de la commande est au moins "Livré"
date	l_date

l_date = gu_datetime.uf_dfromdt(aa_value)

IF match(as_statut, "^[LTF]$") AND IsNull(l_date) THEN
	as_message = "La commande est livrée : sa date de livraison doit être mentionnée."
	return(-1)
END IF

IF IsNull(l_date) THEN
	return(1)
END IF
	
// date doit être comprise entre le 01/01/1980 et le 31/12/2050
IF IsNull(l_date) OR l_date < date("1980-01-01") OR l_date > date("2050-12-31") THEN
	as_message = "La date de livraison doit être comprise entre le 01/01/1980 et le 31/12/2050"
	return(-1)
END IF


return(1)


end function

public function integer uf_check_detail_qteprepa (any aa_value, ref string as_message);// qté préparée : ne peut pas être nulle
decimal	ld_data

ld_data = dec(aa_value)
IF IsNull(ld_data) THEN
	as_message = "La quantité préparée doit être précisée, même si elle est = 0."
	return(-1)
END IF

return(1)


end function

public function integer uf_check_detail_qtelivre (any aa_value, ref string as_message);// qté livrée : ne peut pas être nulle
decimal	ld_data

ld_data = dec(aa_value)
IF IsNull(ld_data) THEN
	as_message = "La quantité livrée doit être précisée, même si elle est = 0."
	return(-1)
END IF

return(1)


end function

public function integer uf_check_detail_qtefacture (any aa_value, ref string as_message);// qté facturée : ne peut pas être nulle
decimal	ld_data

ld_data = dec(aa_value)
IF IsNull(ld_data) THEN
	as_message = "La quantité facturée doit être précisée, même si elle est = 0."
	return(-1)
END IF

return(1)


end function

public function integer uf_check_numcmde (any aa_value, ref string as_message);// numéro de commande : entre 1 et 9999
integer	li_data

li_data = integer(aa_value)
IF IsNull(li_data) OR li_data <= 0 OR li_data > 9999 THEN
	as_message = "Le NUMERO de commande doit être compris entre 1 et 9999"
	return(-1)
END IF

return(1)


end function

public function integer uf_check_detail_numbord (any aa_value, ref string as_message, integer ai_an, integer ai_num);// n° de bordereau de livraison doit exister s'il est mentionné
integer	li_data

li_data = integer(aa_value)
IF isnull(li_data) OR li_data = 0 THEN
	return(1)
END IF

select type_liv into :as_message from bord_liv
	where an_cmde = :ai_an and num_cmde = :ai_num and num_bord = :li_data using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Bordereau de livraison inexistant"
	return(-1)
END IF

return(1)

end function

public function integer uf_check_detail_beforedelete (ref string as_message, string as_statut, integer ai_numbord);// vérification avant suppression d'une ligne de commande
long	ll_count

IF NOT match(as_statut, "^[RCP]$") THEN
	as_message = "Seules les lignes des commandes dont le statut est 'Réceptionnée', 'Confirmée' et 'Préparée' peuvent être supprimées."
	return(-1)
END IF

IF NOT isNull(ai_numbord) AND ai_numbord > 0 THEN
	as_message = "Les lignes de commande déjà livrées ne peuvent pas être supprimées."
	return(-1)
END IF

return(1)

end function

public function integer uf_check_detail_qteconfirm (any aa_value, ref string as_message, decimal ad_qtestock);// qté confirmée : ne peut pas être nulle ni > à la qté disponible
decimal	ld_data

ld_data = dec(aa_value)
IF IsNull(ld_data) THEN
	as_message = "La quantité confirmée doit être précisée, même si elle est = 0."
	return(-1)
END IF

IF ld_data > ad_qtestock THEN
	as_message = "La quantité confirmée ne peut pas dépasser la quantité disponible."
	return(-1)
END IF

return(1)


end function

public function integer uf_check_beforedelete (string as_statut, ref string as_message);// vérification avant suppression
long	ll_count

IF as_statut = "A" THEN
	as_message = "Cette commande est déjà annulée."
	return(-1)
END IF

IF as_statut <> "R" THEN
	as_message = "Seules les commandes dont le statut est 'Réceptionnée' peuvent être supprimées.~n~n" + &
					 "Pour les autres, il faut passer par le programme d'annulation de commande."
	return(-1)
END IF

return(1)

end function

public function integer uf_check_detail_reflot (any aa_value, ref string as_message, integer ai_numcat);// référence du lot obligatoire et doit exister, et le lot doit figurer dans le catalogue choisi
// NB : le test sur la qté se fait quand on encore la qté confirmée.
// --> on peut choisir un lot et puis ne pas savoir lui confirmer de qté
string	ls_data
decimal	ld_qte
long		ll_count

ls_data = string(aa_value)
IF f_IsEmptyString(ls_data) THEN
	as_message = "Le référence du LOT doit être précisée"
	return(-1)
END IF

select qte_restante into :ld_qte from v_totflux where ref_lot = :ls_data using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Référence de lot inexistante"
	return(-1)
END IF

// check présence du lot dans le catalogue
IF isNull(ai_numcat) OR ai_numcat = 0 THEN
	as_message = "Veuillez sélectionner le catalogue à utiliser pour cette commande"
	return(-1)
END IF
select count(*) into :ll_count from cat_vente_lot where 
		num_cat = :ai_numcat and ref_lot = :ls_data using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Erreur select CAT_VENTE_LOT"
	return(-1)
END IF
IF ll_count = 0 THEN
	as_message = "Le lot " + f_string(ls_data) + " n'est pas repris dans le catalogue choisi"
	return(-1)
END IF

return(1)

end function

public function integer uf_check_detail_qtecmde (any aa_value, ref string as_message);// qté commandée : ne peut pas être nulle ou 0
decimal	ld_data

ld_data = dec(aa_value)
IF IsNull(ld_data) OR ld_data <= 0 THEN
	as_message = "La quantité commandée doit être mentionnée."
	return(-1)
END IF

return(1)

end function

public function integer uf_check_dtbordrecap (any aa_value, ref string as_message, string as_statut);// Si mentionnée, la date du bordereau récapitulatif doit être correcte
// Elle est obligatoire si le statut de la commande est au moins "Terminée"
date	l_date

l_date = gu_datetime.uf_dfromdt(aa_value)

IF match(as_statut, "^[TF]$") AND IsNull(l_date) THEN
	as_message = "La commande est terminée : sa date de livraison doit être mentionnée."
	return(-1)
END IF

IF IsNull(l_date) THEN
	return(1)
END IF
	
// date doit être comprise entre le 01/01/1980 et le 31/12/2050
IF IsNull(l_date) OR l_date < date("1980-01-01") OR l_date > date("2050-12-31") THEN
	as_message = "La date d'impression du bordereau récapitulatif doit être comprise entre le 01/01/1980 et le 31/12/2050"
	return(-1)
END IF


return(1)


end function

public function integer uf_check_rembordrecap (any aa_value, ref string as_message);// remarque du bordereau récapitulatif

return(1)


end function

public function integer uf_check_montantrf (any aa_value, ref string as_message, decimal ad_mtcmde);// montant à rembourser/facturer : si le montant est négatif (à rembourser), il ne peut pas être > total commande
decimal	ld_data

ld_data = dec(aa_value)
IF ad_mtcmde + ld_data <= 0 THEN
	as_message = "Le montant à rembourser ne peut pas excéder le montant de la commande."
	return(-1)
END IF

return(1)

end function

public function integer uf_check_detail_pretrt (any aa_value, ref string as_message, integer ai_an, integer ai_num);// prix avec ou sans pretraitement : PRETRT = O ou N
string	ls_data

ls_data = string(aa_value)
IF f_isEmptyString(ls_data) THEN
	as_message = "Veuillez indiquer s'il y a prétraitement ou pas"
	return(-1)
END IF

IF ls_data <> "O" AND ls_data <> "N" THEN
	as_message = "PRETRT : valeurs possibles = O(ui) / N(on)"
	return(-1)
END IF

return(1)

end function

public function integer uf_check_detail_numdfemis (any aa_value, ref string as_message, string as_client, string as_reflot, integer ai_numcat, integer ai_ancmde, integer ai_numcmde);// s'il est mentionné, le n° de document fournisseur doit exister, être de type EMIS,
// du même client que la commande, faire référence au même lot que la ligne de commande, et
// faire référencer au même catalogue que la commande.
// Il ne peut pas être référencé par une autre commande que celle en cours.
string	ls_data, ls_type, ls_client, ls_reflot
integer	li_numcat
long		ll_count

ls_data = string(aa_value)
IF f_IsEmptyString(ls_data) THEN
	return(1)
END IF

select type_df, destinataire, ref_lot, num_cat into :ls_type, :ls_client, :ls_reflot, :li_numcat
	from docfrn where num_df = :ls_data using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Document fournisseur inexistant"
	return(-1)
END IF

IF ls_type <> "E" THEN
	as_message = "Ce document fournisseur a été RECU et non EMIS."
	return(-1)
END IF
IF ls_client <> as_client THEN
	as_message = "Ce document fournisseur n'a pas été émis pour ce client."
	return(-1)
END IF
IF ls_reflot <> as_reflot THEN
	as_message = "Ce document fournisseur n'a pas été émis pour ce lot."
	return(-1)
END IF
IF li_numcat <> ai_numcat THEN
	as_message = "Ce document fournisseur n'a pas été émis pour ce catalogue."
	return(-1)
END IF

select count(*) into :ll_count from detail_cmde where num_df_emis = :ls_data and 
	(an_cmde <> :ai_ancmde OR num_cmde <> :ai_numcmde) using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Erreur SELECT DETAIL_CMDE"
	return(-1)
END IF
IF ll_count > 0 THEN
	as_message = "Une autre commande fait référence à ce document fournisseur."
	return(-1)
END IF

return(1)

end function

on br_commande.create
call super::create
TriggerEvent( this, "constructor" )
end on

on br_commande.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

