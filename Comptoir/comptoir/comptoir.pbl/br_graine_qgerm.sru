//objectcomments BR qualités germinative des graines (GRAINE_QGERM)
forward
global type br_graine_qgerm from nonvisualobject
end type
end forward

global type br_graine_qgerm from nonvisualobject
end type
global br_graine_qgerm br_graine_qgerm

type variables

end variables

forward prototypes
public function integer uf_check_reflot (any aa_value, ref string as_message)
public function integer uf_check_numtest (any aa_value, ref string as_message)
public function integer uf_check_rem (any aa_value, ref string as_message)
public function integer uf_check_pds (any aa_value, ref string as_message)
public function integer uf_check_sslot (any aa_value, ref string as_message)
public function integer uf_check_dtdebut (any aa_value, ref string as_message)
public function integer uf_check_dtldorm (any aa_value, ref string as_message)
public function integer uf_check_nbrep (any aa_value, ref string as_message)
public function integer uf_check_cpt_qterepn (any aa_value, ref string as_message, string as_item, integer ai_nbrep)
public function integer uf_check_cpt_dtcpt (any aa_value, ref string as_message)
public function integer uf_check_cpt_rem (any aa_value, ref string as_message)
public function integer uf_check_typetest (any aa_value, ref string as_message, string as_typeqte)
public function integer uf_check_cpt_idbac (any aa_value, ref string as_message)
public function integer uf_check_beforedelete (string as_reflot, integer ai_numtest, ref string as_message)
public function integer uf_check_qterep (any aa_value, ref string as_message, string as_typeqte)
public function integer uf_check_qterepn (any aa_value, ref string as_message, string as_item, integer ai_nbrep, decimal ad_qte, string as_typeqte)
end prototypes

public function integer uf_check_reflot (any aa_value, ref string as_message);// Référence du lot obligatoire et doit exister.
// Si OK, as_message renvoie le code de l'espèce.
string	ls_data

ls_data = string(aa_value)
IF f_IsEmptyString(ls_data) THEN
	as_message = "Le référence du LOT doit être spécifiée"
	return(-1)
END IF

select code_sp into :as_message from registre where ref_lot = :ls_data using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Référence de lot inexistante"
	return(-1)
END IF

return(1)

end function

public function integer uf_check_numtest (any aa_value, ref string as_message);// numéro de test : entre 1 et 99
integer	li_data

li_data = integer(aa_value)
IF IsNull(li_data) OR li_data <= 0 OR li_data > 99 THEN
	as_message = "Le NUMERO de test doit être compris entre 1 et 99"
	return(-1)
END IF

return(1)


end function

public function integer uf_check_rem (any aa_value, ref string as_message);// remarque

return(1)

end function

public function integer uf_check_pds (any aa_value, ref string as_message);// Poids mesuré dans le test "poids de 1000 graines" doit être > 0 pour les répétitions demandées
decimal{2}	ld_data

ld_data = dec(aa_value)
IF isNull(ld_data) OR ld_data <= 0 THEN
	as_message = "Le poids doit être > 0 pour chaque répétition"
	return(-1)
END IF

return(1)

end function

public function integer uf_check_sslot (any aa_value, ref string as_message);// n° sous-lot
return(1)


end function

public function integer uf_check_dtdebut (any aa_value, ref string as_message);// la date de début du test est obligatoire
date	l_date

l_date = gu_datetime.uf_dfromdt(aa_value)

// date doit être comprise entre le 01/01/1980 et le 31/12/2050
IF IsNull(l_date) OR l_date < date("1980-01-01") OR l_date > date("2050-12-31") THEN
	as_message = "La date de début du test est obligatoire et doit être comprise entre le 01/01/1980 et le 31/12/2050"
	return(-1)
END IF


return(1)


end function

public function integer uf_check_dtldorm (any aa_value, ref string as_message);// date de levée de dormance
date	l_date

l_date = gu_datetime.uf_dfromdt(aa_value)

// date doit être comprise entre le 01/01/1980 et le 31/12/2050
IF NOT IsNull(l_date) AND l_date < date("1980-01-01") OR l_date > date("2050-12-31") THEN
	as_message = "La date de levée de dormance, si mentionnée, doit être comprise entre le 01/01/1980 et le 31/12/2050"
	return(-1)
END IF


return(1)


end function

public function integer uf_check_nbrep (any aa_value, ref string as_message);// Nbre de répétitions : 2 ~ 12.
integer	li_data

li_data = integer(aa_value)

IF li_data < 2 OR li_data > 12 THEN
	as_message = "Nombre de répétitions : doit être compris entre 2 et 12."
	return(-1)
END IF

return(1)


end function

public function integer uf_check_cpt_qterepn (any aa_value, ref string as_message, string as_item, integer ai_nbrep);// Nombre de germes de toutes les répétitions d'un relevé doit être introduit (mais peut valoir 0)
integer	li_data, li_nrep

li_data = integer(aa_value)
li_nrep = integer(mid(as_item, 5))

IF li_nrep > ai_nbrep THEN
	IF NOT isNull(li_data) THEN
		as_message = "On ne peut pas introduire de valeur au delà des répétitions demandées."
		return(-1)
	ELSE
		return(1)
	END IF
ELSE
	IF isNull(li_data) THEN
		as_message = "Le nombre de germes doit être mentionné, même s'il est égal à 0"
		return(-1)
	END IF
END IF

return(1)

end function

public function integer uf_check_cpt_dtcpt (any aa_value, ref string as_message);// la date du relevé est obligatoire
date	l_date

l_date = gu_datetime.uf_dfromdt(aa_value)

// date doit être comprise entre le 01/01/1980 et le 31/12/2050
IF IsNull(l_date) OR l_date < date("1980-01-01") OR l_date > date("2050-12-31") THEN
	as_message = "La date du relevé est obligatoire et doit être comprise entre le 01/01/1980 et le 31/12/2050"
	return(-1)
END IF


return(1)


end function

public function integer uf_check_cpt_rem (any aa_value, ref string as_message);// remarque dans un relevé

return(1)

end function

public function integer uf_check_typetest (any aa_value, ref string as_message, string as_typeqte);// Type de test : boîte de Pétri (P) ou substrat (S)
// Pour les espèces dont les espèces ne sont pas comptabilisables (bouleau), seul le test en Pétri est possible
string	ls_data

ls_data = string(aa_value)

IF NOT match(ls_data, "[PS]") THEN
	as_message = "Type de test obligatoire : boîte de Pétri (P) ou substrat (S)"
	return(-1)
END IF

IF as_typeqte = "P" AND ls_data = "S" THEN
	as_message = "Pour cette espèce, seuls les tests en boîtes de Pétri sont réalisables"
	return(-1)
END IF

return(1)

end function

public function integer uf_check_cpt_idbac (any aa_value, ref string as_message);// N° de bac dans un relevé (test sur substrat uniquement) : obligatoire
integer	li_data

li_data = integer(aa_value)
IF isNull(li_data) OR li_data = 0 THEN
	as_message = "Le n° du bac doit être mentionné"
	return(-1)
END IF

return(1)

end function

public function integer uf_check_beforedelete (string as_reflot, integer ai_numtest, ref string as_message);// vérification avant suppression : messages spécifiques si :
// 1. le test correspond à une ligne générée dans le lot (REGISTRE_QGERM), donc a été validé
// 2. la ligne générée dans le lot (REGISTRE_QGERM) est référencée dans un document fournisseur
// return(-1) : erreur
// return(0) : pas de ligne correspondante dans REGISTRE_QGERM, donc forcément pas de référence
//             non plus dans DOCFRN
// return(999) : il existe une ligne correspondante dans REGISTRE_QGERM, mais non référencée dans DOCFRN
// return > 0 : utilisation dans un DOCFRN, et donc forcément il existe aussi une ligne dans REGISTRE_QGERM. 
//					 Il faut afficher le message et demander confirmation.
//					 La valeur retournée est le n° de REGISTRE_QGERM (num_qgerm) dans DOCFRN
long	ll_count
integer	li_numqgerm
string	ls_msg1, ls_msg2

select num_qgerm into :li_numqgerm from REGISTRE_QGERM where ref_lot=:as_reflot and num_test_qgerm=:ai_numtest using ESQLCA;
IF f_check_sql(ESQLCA) < 0 THEN
	as_message = "Erreur select REGISTRE_QGERM"
	return(-1)
END IF

// pas de ligne dans le lot
IF ESQLCA.sqlnrows = 0 THEN
	as_message = ""
	return(0)
END IF

// il existe un ligne dans le lot, constituer 1ère partie du message...
ls_msg1 = "Ce test de germination a été validé et une ligne synthétique le représente dans le lot.~n" + &
			 "Si vous le supprimez, la ligne correspondante sera également supprimée du lot."
// ... et voir si elle est référencée dans DOCFRN
select count(*) into :ll_count from DOCFRN where ref_lot=:as_reflot and num_qgerm=:li_numqgerm using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Erreur select DOCFRN"
	return(-1)
END IF

IF ll_count > 0 THEN
	// la ligne présente dans le lot est référencée dans DOCFRN : 2ème partie du message
	ls_msg2 = "Ces qualités germinatives sont par ailleurs utilisées dans " + f_string(ll_count) + &
				 " document(s) fournisseur.~nSi vous les supprimez, la référence vers elles" + &
				 " sera annulée dans ce(s) document(s) fournisseur."
ELSE
	// la ligne présente dans le lot n'est pas référencée dans DOCFRN
	as_message = ls_msg1 + "~n~n"
	return(999)
END IF

// construire le message et sortir
as_message = ls_msg1 + "~n~n" + ls_msg2 + "~n~n"
return(li_numqgerm)
end function

public function integer uf_check_qterep (any aa_value, ref string as_message, string as_typeqte);// Nombre de graines initial par répétition doit être > 0
decimal{2}	ld_data
integer		li_data

ld_data = dec(aa_value)
li_data = round(ld_data, 0)

// si qté graine exprimé en nombre : nombre entier doit être encodé
IF as_typeqte = "C" THEN
	IF ld_data - li_data <> 0 THEN
		as_message = "Pour cette espèce, il faut introduire un nombre entier de graines"
		return(-1)
	END IF
END IF

IF isNull(ld_data) OR ld_data <= 0 THEN
	as_message = "La quantité initiale de graines doit être mentionnée"
	return(-1)
END IF

return(1)

end function

public function integer uf_check_qterepn (any aa_value, ref string as_message, string as_item, integer ai_nbrep, decimal ad_qte, string as_typeqte);// Quantité de graines de la dernière répétition est modifiable et doit être > 0
integer		li_nrep, li_data
decimal{2}	ld_data

ld_data = dec(aa_value)
li_data = round(ld_data, 0)
li_nrep = integer(mid(as_item, 8))

// si qté graine exprimé en nombre : nombre entier doit être encodé
IF as_typeqte = "C" THEN
	IF ld_data - li_data <> 0 THEN
		as_message = "Pour cette espèce, il faut introduire un nombre entier de graines"
		return(-1)
	END IF
END IF

IF li_nrep <> ai_nbrep AND ld_data <> ad_qte THEN
	as_message = "Seul le nombre de la dernière répétition peut être modifié"
	return(-1)
END IF

IF li_nrep = ai_nbrep AND (isNull(ld_data) OR ld_data <= 0) THEN
	as_message = "La quantité de graines doit être supérieur à 0"
	return(-1)
END IF

return(1)

end function

on br_graine_qgerm.create
call super::create
TriggerEvent( this, "constructor" )
end on

on br_graine_qgerm.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

