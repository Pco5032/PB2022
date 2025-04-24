//objectcomments BR viabilité des graines (GRAINE_VIABILITE)
forward
global type br_graine_viabilite from nonvisualobject
end type
end forward

global type br_graine_viabilite from nonvisualobject
end type
global br_graine_viabilite br_graine_viabilite

type variables

end variables

forward prototypes
public function integer uf_check_reflot (any aa_value, ref string as_message)
public function integer uf_check_numtest (any aa_value, ref string as_message)
public function integer uf_check_dtmesure (any aa_value, ref string as_message)
public function integer uf_check_rem (any aa_value, ref string as_message)
public function integer uf_check_beforedelete (string as_reflot, integer ai_numtest, ref string as_message)
public function integer uf_check_typetest (any aa_value, ref string as_message)
public function integer uf_check_nbrep (any aa_value, ref string as_message)
public function integer uf_check_qterep (any aa_value, ref string as_message)
public function integer uf_check_nbre (any aa_value, ref string as_message, string as_typetest, integer ai_nbreinit)
public function integer uf_check_parasite (any aa_value, ref string as_message, string as_typetest, integer ai_nbreinit, integer ai_nbrevide)
public function integer uf_check_vide (any aa_value, ref string as_message, string as_typetest, integer ai_nbreinit, integer ai_nbreparasite)
end prototypes

public function integer uf_check_reflot (any aa_value, ref string as_message);// Référence du lot obligatoire et doit exister.
// Si OK, as_message renvoie le code de l'espèce.
string	ls_data, ls_typeqte, ls_codesp

ls_data = string(aa_value)
IF f_IsEmptyString(ls_data) THEN
	as_message = "Le référence du LOT doit être spécifiée"
	return(-1)
END IF

select code_sp into :ls_codesp from registre where ref_lot = :ls_data using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Référence de lot inexistante"
	return(-1)
END IF

// lecture type de quantité (poids ou comptage) de l'essence du lot
select type_qte into :ls_typeqte from espece where code_sp=:ls_codesp using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN 
	as_message = "L'essence " + f_string(ls_codesp) + &
					 " mentionnée dans le lot n'existe pas dans le fichier des espèces !"
	return(-1)
END IF

// on ne pratique pas de test de viabilité pour les essences dont on ne peut pas compter les graines (typeqte='P')
IF ls_typeqte <> "C" THEN
	as_message = "Test de viabilité incompatible avec l'espèce de ce lot"
	return(-1)
END IF

// renvoyer le code de l'espèce
as_message = ls_codesp
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

public function integer uf_check_dtmesure (any aa_value, ref string as_message);// la date de mesure est obligatoire
date	l_date

l_date = gu_datetime.uf_dfromdt(aa_value)

// date doit être comprise entre le 01/01/1980 et le 31/12/2050
IF IsNull(l_date) OR l_date < date("1980-01-01") OR l_date > date("2050-12-31") THEN
	as_message = "La date de mesure est obligatoire et doit être comprise entre le 01/01/1980 et le 31/12/2050"
	return(-1)
END IF


return(1)


end function

public function integer uf_check_rem (any aa_value, ref string as_message);// remarque

return(1)

end function

public function integer uf_check_beforedelete (string as_reflot, integer ai_numtest, ref string as_message);// vérification avant suppression : messages spécifiques si :
// 1. le test correspond à une ligne générée dans le lot (REGISTRE_QGERM) - normalement TJS le cas !
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

select num_qgerm into :li_numqgerm from REGISTRE_QGERM where ref_lot=:as_reflot and num_test_viab=:ai_numtest using ESQLCA;
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
ls_msg1 = "Il existe dans le lot une ligne synthétique représentant ce test de viabilité.~n" + &
			 "Si vous le supprimez, la ligne correspondante sera également supprimée du lot."
// ... et voir si elle est référencée dans DOCFRN
select count(*) into :ll_count from DOCFRN where ref_lot=:as_reflot and num_qgerm=:li_numqgerm using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Erreur select DOCFRN"
	return(-1)
END IF

IF ll_count > 0 THEN
	// la ligne présente dans le lot est référencée dans DOCFRN : 2ème partie du message
	ls_msg2 = "Ce test de viabilité est par ailleurs utilisé dans " + f_string(ll_count) + &
				 " document(s) fournisseur.~nSi vous le supprimez, la référence vers lui" + &
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

public function integer uf_check_typetest (any aa_value, ref string as_message);// Type de test : coupe ou écrasement
string	ls_data

ls_data = string(aa_value)

IF f_isEmptyString(ls_data) OR NOT MATCH(ls_data, "[CE]") THEN
	as_message = "Type de test : à la Coupe(C) ou à l'Ecrasement (E)"
	return(-1)
END IF

return(1)


end function

public function integer uf_check_nbrep (any aa_value, ref string as_message);// Nbre de répétitions : 2 ~ 12.
integer	li_data

li_data = integer(aa_value)

IF IsNull(li_data) OR li_data < 0 OR li_data < 2 OR li_data > 12 THEN
	as_message = "Le nombre de répétitions doit être compris entre 2 et 12."
	return(-1)
END IF

return(1)


end function

public function integer uf_check_qterep (any aa_value, ref string as_message);// Le nbre de graines par répétition doit être > 0 (max 9999).
integer	li_data

li_data = integer(aa_value)

IF IsNull(li_data) OR li_data <= 0 OR li_data > 9999 THEN
	as_message = "Le nombre de graines par répétition doit être > 0."
	return(-1)
END IF

return(1)


end function

public function integer uf_check_nbre (any aa_value, ref string as_message, string as_typetest, integer ai_nbreinit);// Test à la coupe :
// le nombre de bonnes graines de toutes les répétitions doit être introduit (mais peut valoir 0).
integer	li_data, li_nrep

IF as_typetest <> "C" THEN return(1)

li_data = integer(aa_value)
IF isNull(li_data) THEN
	as_message = "Le nombre de bonnes graines doit être mentionné, même s'il est égal à 0"
	return(-1)
END IF

IF li_data > ai_nbreinit THEN
	as_message = "Le nombre introduit ne peut dépasser le nombre de graines initial (" + f_string(ai_nbreinit) + ")"
	return(-1)
END IF

return(1)

end function

public function integer uf_check_parasite (any aa_value, ref string as_message, string as_typetest, integer ai_nbreinit, integer ai_nbrevide);// Test à l'écrasement :
// . le nombre de graines avec parasites, pour toutes les répétitions, doit être introduit (mais peut valoir 0)
// . le nombre de vides + le nombre de parasités ne peut dépasser le nombre de graines initial
integer	li_data, li_nrep

IF as_typetest <> "E" THEN return(1)

li_data = integer(aa_value)
IF isNull(li_data) THEN
	as_message = "Le nombre de graines parasitées doit être mentionné, même s'il est égal à 0"
	return(-1)
END IF

IF li_data > ai_nbreinit THEN
	as_message = "Le nombre introduit ne peut dépasser le nombre de graines initial (" + f_string(ai_nbreinit) + ")"
	return(-1)
END IF

IF ai_nbrevide > 0 AND (li_data + ai_nbrevide) > ai_nbreinit THEN
	as_message = "La somme des graines 'vides' et des 'parasitées' ne peut dépasser le nombre de graines initial (" + f_string(ai_nbreinit) + ")"
	return(-1)
END IF

return(1)

end function

public function integer uf_check_vide (any aa_value, ref string as_message, string as_typetest, integer ai_nbreinit, integer ai_nbreparasite);// Test à l'écrasement :
// . le nombre de graines vides, pour toutes les répétitions, doit être introduit (mais peut valoir 0)
// . le nombre de vides + le nombre de parasités ne peut dépasser le nombre de graines initial
integer	li_data, li_nrep

IF as_typetest <> "E" THEN return(1)

li_data = integer(aa_value)
IF isNull(li_data) THEN
	as_message = "Le nombre de graines vides doit être mentionné, même s'il est égal à 0"
	return(-1)
END IF

IF li_data > ai_nbreinit THEN
	as_message = "Le nombre introduit ne peut dépasser le nombre de graines initial (" + f_string(ai_nbreinit) + ")"
	return(-1)
END IF

IF ai_nbreparasite > 0 AND (li_data + ai_nbreparasite) > ai_nbreinit THEN
	as_message = "La somme des graines 'vides' et des 'parasitées' ne peut dépasser le nombre de graines initial (" + f_string(ai_nbreinit) + ")"
	return(-1)
END IF

return(1)

end function

on br_graine_viabilite.create
call super::create
TriggerEvent( this, "constructor" )
end on

on br_graine_viabilite.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

