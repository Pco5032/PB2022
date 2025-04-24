//objectcomments BR caractéristiques physiques des graines (GRAINE_CPHYS)
forward
global type br_graine_cphys from nonvisualobject
end type
end forward

global type br_graine_cphys from nonvisualobject
end type
global br_graine_cphys br_graine_cphys

type variables

end variables

forward prototypes
public function integer uf_check_reflot (any aa_value, ref string as_message)
public function integer uf_check_numtest (any aa_value, ref string as_message)
public function integer uf_check_dtmesure (any aa_value, ref string as_message)
public function integer uf_check_rem (any aa_value, ref string as_message)
public function integer uf_check_pdsnbr (any aa_value, ref string as_message)
public function integer uf_check_qterep (any aa_value, ref string as_message)
public function integer uf_check_pds (any aa_value, ref string as_message)
public function integer uf_check_purete_bon (any aa_value, ref string as_message, decimal ad_inerte, decimal ad_autre)
public function integer uf_check_purete_inerte (any aa_value, ref string as_message, decimal ad_bon, decimal ad_autre)
public function integer uf_check_purete_autre (any aa_value, ref string as_message, decimal ad_bon, decimal ad_inerte)
public function integer uf_check_purete (ref string as_message, decimal ad_bon, decimal ad_inerte, decimal ad_autre)
public function integer uf_check_humnbr (any aa_value, ref string as_message)
public function integer uf_check_humpf (any aa_value, ref string as_message)
public function integer uf_check_humrap (any aa_value, ref string as_message)
public function integer uf_check_pdsnbg (any aa_value, ref string as_message, integer ai_nbr)
public function integer uf_check_beforedelete (string as_reflot, integer ai_numtest, ref string as_message)
public function integer uf_check_humps (any aa_value, ref string as_message, decimal ad_pf)
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

public function integer uf_check_pdsnbr (any aa_value, ref string as_message);// Poids de 1000 graines - Nbre de répétitions : 2 ~ 12.
// Exception : 0 qui sera interprété comme "absence de mesures"
integer	li_data

li_data = integer(aa_value)

IF IsNull(li_data) OR li_data < 0 OR (li_data <> 0 AND (li_data < 2 OR li_data > 12)) THEN
	as_message = "Nombre de répétitions / poids de 1000 graines : doit être compris entre 2 et 12.~n~n" + &
					 "Si vous ne souhaitez pas encoder les données maintenant, introduisez 0."
	return(-1)
END IF

return(1)


end function

public function integer uf_check_qterep (any aa_value, ref string as_message);// Nombre de graines à tester pour les répétitions demandées doit être > 0
integer	li_data

li_data = integer(aa_value)
IF isNull(li_data) OR li_data <= 0 THEN
	as_message = "Le nombre de graines à tester doit être précisé pour chaque répétition"
	return(-1)
END IF

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

public function integer uf_check_purete_bon (any aa_value, ref string as_message, decimal ad_inerte, decimal ad_autre);// Si une des données concernant la pureté des graines est introduites, les autres doivent l'être
// aussi (elles ne peuvent pas rester nulles, mais peuvent valoir 0)
decimal{2}	ld_data

ld_data = dec(aa_value)
IF (NOT isNull(ad_inerte) OR NOT isNull(ad_autre)) AND IsNull(ld_data) THEN
	as_message = "Le poids de semences pures doit être spécifié car au moins une des 2 autres valeurs l'est."
	return(-1)
END IF

return(1)

end function

public function integer uf_check_purete_inerte (any aa_value, ref string as_message, decimal ad_bon, decimal ad_autre);// Si une des données concernant la pureté des graines est introduites, les autres doivent l'être
// aussi (elles ne peuvent pas rester nulles, mais peuvent valoir 0)
decimal{2}	ld_data

ld_data = dec(aa_value)
IF (NOT isNull(ad_bon) OR NOT isNull(ad_autre)) AND IsNull(ld_data) THEN
	as_message = "Le poids de matière inerte doit être spécifié (même s'il vaut 0) car au moins une des 2 autres valeurs l'est."
	return(-1)
END IF

return(1)

end function

public function integer uf_check_purete_autre (any aa_value, ref string as_message, decimal ad_bon, decimal ad_inerte);// Si une des données concernant la pureté des graines est introduites, les autres doivent l'être
// aussi (elles ne peuvent pas rester nulles, mais peuvent valoir 0)
decimal{2}	ld_data

ld_data = dec(aa_value)
IF (NOT isNull(ad_bon) OR NOT isNull(ad_inerte)) AND IsNull(ld_data) THEN
	as_message = "Le poids des autres graines doit être spécifié (même s'il vaut 0) car au moins une des 2 autres valeurs l'est."
	return(-1)
END IF

return(1)

end function

public function integer uf_check_purete (ref string as_message, decimal ad_bon, decimal ad_inerte, decimal ad_autre);// La somme des 3 pourcentages obtenus dans le test de pureté doit faire 100%
decimal{2}	ld_data

ld_data = ad_bon + ad_inerte + ad_autre
IF ld_data <> 100 THEN
	as_message = "La somme des 3 pourcentages obtenus dans le test de pureté doit faire 100 %.~n~n" + &
					 "Veuillez adapter les poids pour y arriver..."
	return(-1)
END IF

return(1)

end function

public function integer uf_check_humnbr (any aa_value, ref string as_message);// test d'humidité - Nbre de répétitions : 2 ~ 12.
// Exception : 0 qui sera interprété comme "absence de mesures"
integer	li_data

li_data = integer(aa_value)

IF IsNull(li_data) OR li_data < 0 OR (li_data <> 0 AND (li_data < 2 OR li_data > 12)) THEN
	as_message = "Nombre de répétitions / test d'humidité : doit être compris entre 2 et 12.~n~n" + &
					 "Si vous ne souhaitez pas encoder les données maintenant, introduisez 0."
	return(-1)
END IF

return(1)


end function

public function integer uf_check_humpf (any aa_value, ref string as_message);// Poids Frais mesuré dans le test d'humidité doit être > 0 pour les répétitions demandées
decimal{2}	ld_data

ld_data = dec(aa_value)
IF isNull(ld_data) OR ld_data <= 0 THEN
	as_message = "Le poids frais (PF) doit être > 0 pour chaque répétition.~n" + &
		 "Si vous ne souhaitez pas introduire ces données maintenant, encodez 0 dans le nombre de répétitions."
	return(-1)
END IF

return(1)

end function

public function integer uf_check_humrap (any aa_value, ref string as_message);// Test d'humidité rapide
decimal{2}	ld_data

ld_data = dec(aa_value)
IF ld_data > 100 THEN
	as_message = "% d'humidité (détermination rapide) incorrect"
	return(-1)
END IF

return(1)

end function

public function integer uf_check_pdsnbg (any aa_value, ref string as_message, integer ai_nbr);// Poids de 1000 graines. 
// Si le nombre de répétitions est spécifié, le nbre de graines initial doit être > 0 (max 9999).
integer	li_data

IF isNull(ai_nbr) OR ai_nbr = 0 THEN return(1)

li_data = integer(aa_value)

IF IsNull(li_data) OR li_data <= 0 OR li_data > 9999 THEN
	as_message = "Nombre de graines initial par répétition / poids de 1000 graines : doit être > 0."
	return(-1)
END IF

return(1)


end function

public function integer uf_check_beforedelete (string as_reflot, integer ai_numtest, ref string as_message);// vérification avant suppression : messages spécifiques si :
// 1. le test correspond à une ligne générée dans le lot (REGISTRE_CPHYS) - normalement TJS le cas !
// 2. la ligne générée dans le lot (REGISTRE_CPHYS) est référencée dans un document fournisseur
// return(-1) : erreur
// return(0) : pas de ligne correspondante dans REGISTRE_CPHYS, donc forcément pas de référence
//             non plus dans DOCFRN
// return(999) : il existe une ligne correspondante dans REGISTRE_CPHYS, mais non référencée dans DOCFRN
// return > 0 : utilisation dans un DOCFRN, et donc forcément il existe aussi une ligne dans REGISTRE_CPHYS. 
//					 Il faut afficher le message et demander confirmation.
//					 La valeur retournée est le n° de REGISTRE_CPHYS (num_qgerm) dans DOCFRN
long	ll_count
integer	li_numcphys
string	ls_msg1, ls_msg2

select num_cphys into :li_numcphys from REGISTRE_CPHYS where ref_lot=:as_reflot and num_test_cphys=:ai_numtest using ESQLCA;
IF f_check_sql(ESQLCA) < 0 THEN
	as_message = "Erreur select REGISTRE_CPHYS"
	return(-1)
END IF

// pas de ligne dans le lot
IF ESQLCA.sqlnrows = 0 THEN
	as_message = ""
	return(0)
END IF

// il existe un ligne dans le lot, constituer 1ère partie du message...
ls_msg1 = "Il existe dans le lot une ligne synthétique représentant ces caractéristiques physiques.~n" + &
			 "Si vous les supprimez, la ligne correspondante sera également supprimée du lot."
// ... et voir si elle est référencée dans DOCFRN
select count(*) into :ll_count from DOCFRN where ref_lot=:as_reflot and num_cphys=:li_numcphys using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Erreur select DOCFRN"
	return(-1)
END IF

IF ll_count > 0 THEN
	// la ligne présente dans le lot est référencée dans DOCFRN : 2ème partie du message
	ls_msg2 = "Ces caractéristiques physiques sont par ailleurs utilisées dans " + f_string(ll_count) + &
				 " document(s) fournisseur.~nSi vous les supprimez, la référence vers elles" + &
			 	 " sera annulée dans ce(s) document(s) fournisseur."
ELSE
	// la ligne présente dans le lot n'est pas référencée dans DOCFRN
	as_message = ls_msg1 + "~n~n"
	return(999)
END IF

// construire le message et sortir
as_message = ls_msg1 + "~n~n" + ls_msg2 + "~n~n"
return(li_numcphys)
end function

public function integer uf_check_humps (any aa_value, ref string as_message, decimal ad_pf);// Poids Sec mesuré dans le test d'humidité doit être > 0 pour les répétitions demandées
// et inférieur au poids Frais de la même répétition.
// Le Poids sec étant disponible quelque temps après le poids frais, on peut également
// le laisser à une valeur nulle en attendant d'en disposer. Aucun % d'humidité n'est alors calculé.
decimal{2}	ld_data

ld_data = dec(aa_value)
IF isNull(ld_data) THEN return(1)
IF ld_data <= 0 THEN
	as_message = "Le poids sec (PS) doit être > 0 (ou NULL) pour chaque répétition.~n" + &
	"Si vous ne souhaitez pas introduire ces données maintenant, encodez 0 dans le nombre de répétitions~n" + &
	"pour annuler tant les PF que les PS, ou annulez les PS seuls au moyen de l'option 'nullify'."	 
	return(-1)
END IF

IF ld_data > ad_pf THEN
	as_message = "Le poids sec ne peut être plus élevé que le poids frais"
	return(-1)
END IF

return(1)

end function

on br_graine_cphys.create
call super::create
TriggerEvent( this, "constructor" )
end on

on br_graine_cphys.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

