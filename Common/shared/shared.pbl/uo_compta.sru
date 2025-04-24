//objectcomments Fonctions liées à  la comptabilité de portée très générale (validité du numéro de compte en banque...)
forward
global type uo_compta from nonvisualobject
end type
end forward

global type uo_compta from nonvisualobject
end type
global uo_compta uo_compta

forward prototypes
public function integer uf_check_tva (any aa_value, ref string as_message)
public function integer uf_check_cb (any aa_value, ref string as_message)
public function integer uf_check_bce (any aa_value, ref string as_message)
public function integer uf_check_iban (any aa_value, ref string as_message)
end prototypes

public function integer uf_check_tva (any aa_value, ref string as_message);// vérification de la validité d'un n° de TVA (belge)
dec ld_cd, ld_cd2, ld_tva
int li_check
string ls_tva

ls_tva = string(aa_value)

// N° ne peut contenir que des chiffres
IF NOT IsNumber(ls_tva) THEN
	as_message = "Le numéro de TVA contient des caractères non valides"
	return(-1)
END IF

// Vérification de la structure du string (= 9 chiffres)
// PCO 20/11/2020 : n° TVA précédé de 0 donc 10 chiffres
IF f_IsEmptyString(ls_tva) OR (LenA(trim(ls_tva)) <> 9 AND LenA(trim(ls_tva)) <> 10) THEN
	as_message = "Numéro de TVA non valide : structure incorrecte (0)XXX-XXX-XXX"
	return(-1)
end if

as_message = "Numéro de TVA non valide"

// Vérification du checkdigit
ld_tva=dec(aa_value)
IF IsNull(ld_tva) OR ld_tva = 0 THEN
	return(-1)
END IF

ls_tva = string(ld_tva, "0000000000")
ld_cd = dec(LeftA(ls_tva, 8))
ld_cd2 = truncate(ld_cd / 97,0) * 97
li_check = 97 - (ld_cd - ld_cd2)

IF li_check = integer(RightA(ls_tva,2)) THEN
	return(1)
ELSE
	return(-1)
END IF

end function

public function integer uf_check_cb (any aa_value, ref string as_message);// vérification de la validité d'un n° de compte bancaire (belge)
dec ld_cb, ld_10premiers
int li_checkdigit
string ls_cb

ls_cb=f_string(aa_value)

// N° ne peut contenir que des chiffres
IF NOT IsNumber(ls_cb) THEN
	as_message = "Le numéro de compte contient des caractères non valides"
	return(-1)
END IF

// Vérification de la structure du string (= 12 chiffres)
IF f_IsEmptyString(ls_cb) or LenA(trim(ls_cb)) <> 12 THEN
	as_message = "Numéro de compte invalide : structure incorrecte (###-#######-##)" 
	return(-1)
end if

//Vérification du checkdigit
// Le check-digit s'obtient en divisant les dix premiers chiffres du numéro de compte par 97. 
// Le reste de cette division correspond au chiffre de contrôle. 
// Si le reste est égal à 0, le chiffre de contrôle est 97. 

ld_cb=dec(aa_value)

ld_10premiers = truncate(ld_cb / 100,0)
li_checkdigit = ld_cb - (ld_10premiers * 100)

if li_checkdigit = 97 then 
	li_checkdigit = 0
end if

if ld_10premiers = 0 OR (mod(ld_10premiers,97) <> li_checkdigit) 	then
	as_message = "Numéro de compte invalide : chiffre(s) erroné(s)"
	return(-1)
end if

return(1)

end function

public function integer uf_check_bce (any aa_value, ref string as_message);// vérification de la validité d'un n° de BCE (banque carrefour des entreprises belges)
dec ld_cd, ld_cd2, ld_bce
int li_check
string ls_bce

ls_bce = string(aa_value)

// N° ne peut contenir que des chiffres
IF NOT IsNumber(ls_bce) THEN
	as_message = "Le numéro de BCE contient des caractères non valides"
	return(-1)
END IF

// Vérification de la structure du string (= 9 chiffres)
// PCO 20/11/2020 : n° BCE précédé de 0 donc 10 chiffres
IF f_IsEmptyString(ls_bce) OR (LenA(trim(ls_bce)) <> 9 AND LenA(trim(ls_bce)) <> 10) THEN
	as_message = "Numéro de BCE non valide : structure incorrecte (0)XXX-XXX-XXX"
	return(-1)
end if

as_message = "Numéro de BCE non valide"

// Vérification du checkdigit
ld_bce=dec(aa_value)
IF IsNull(ld_bce) OR ld_bce = 0 THEN
	return(-1)
END IF

ls_bce = string(ld_bce, "0000000000")
ld_cd = dec(LeftA(ls_bce, 8))
ld_cd2 = truncate(ld_cd / 97,0) * 97
li_check = 97 - (ld_cd - ld_cd2)

IF li_check = integer(RightA(ls_bce,2)) THEN
	return(1)
ELSE
	return(-1)
END IF

end function

public function integer uf_check_iban (any aa_value, ref string as_message);// vérification de la validité d'un n° de compte bancaire (IBAN)
int 		li_asc, li_reste, li_15
string	ls_iban, ls_bban, ls_pays_n, ls_full, ls_part, ls_sub
longlong	ll_calc

ls_iban = trim(upper(f_string(aa_value)))

IF f_isEmptyString(ls_iban) THEN
	return(1)
END IF

// extraire BBAN
ls_bban = mid(ls_iban, 5)

// convertir code pays en numérique (A=10, B=11...)
li_asc = asc(mid(ls_iban, 1, 1)) - 55
ls_pays_n = string(li_asc)

li_asc = asc(mid(ls_iban, 2, 1)) - 55
ls_pays_n = ls_pays_n + string(li_asc)

// string contenant le nombre de base du calcul
ls_full = ls_bban + ls_pays_n + mid(ls_iban, 3, 2)

// calculer check digit (en décomposant si nombre trop grand)
li_15 = 0
DO
	ls_part = left(ls_full, 15)
	ll_calc = longlong(ls_part)
	IF ll_calc = 0 THEN
		as_message = "Numéro de compte non valide"
 		return(-1)
	END IF
	// modulo 97
	li_reste = mod(ll_calc, 97)
	
	li_15++
	ls_sub = mid(ls_full, (li_15 * 15) + 1, (li_15 + 1) * 15)
	ls_full = string(li_reste) + ls_sub
LOOP WHILE len(ls_sub) > 0

IF li_reste <> 1 THEN
	as_message = "Numéro de compte non valide"
	return(-1)
end if

return(1)

end function

on uo_compta.create
call super::create
TriggerEvent( this, "constructor" )
end on

on uo_compta.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

