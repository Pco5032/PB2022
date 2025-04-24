//objectcomments BR flux
forward
global type br_flux from nonvisualobject
end type
end forward

global type br_flux from nonvisualobject
end type
global br_flux br_flux

type variables

end variables

forward prototypes
public function integer uf_check_reflot (any aa_value, ref string as_message)
public function integer uf_check_rem (any aa_value, ref string as_message)
public function integer uf_check_numflux (any aa_value, ref string as_message)
public function integer uf_check_utilisation (any aa_value, ref string as_message)
public function integer uf_check_dtop (any aa_value, ref string as_message)
public function integer uf_check_lieustock (any aa_value, ref string as_message)
public function integer uf_check_destinataire (any aa_value, ref string as_message)
public function integer uf_check_qte (any aa_value, ref string as_message, string as_signe, decimal ad_qterestante)
end prototypes

public function integer uf_check_reflot (any aa_value, ref string as_message);// référence du lot obligatoire et doit exister
string	ls_data

ls_data = string(aa_value)
IF f_IsEmptyString(ls_data) THEN
	as_message = "Le référence du LOT doit être précisée"
	return(-1)
END IF

select num_fiche into :as_message from registre where ref_lot = :ls_data using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Référence de lot inexistante"
	return(-1)
END IF

return(1)

end function

public function integer uf_check_rem (any aa_value, ref string as_message);// Remarque
return(1)


end function

public function integer uf_check_numflux (any aa_value, ref string as_message);// numéro de ligne de flux : entre 1 et 999
integer	li_data

li_data = integer(aa_value)
IF IsNull(li_data) OR li_data <= 0 OR li_data > 999 THEN
	as_message = "Le NUMERO d'une ligne de flux doit être compris entre 1 et 999"
	return(-1)
END IF

return(1)
end function

public function integer uf_check_utilisation (any aa_value, ref string as_message);// code utilisation : obligatoire et doit exister
// Les codes pour les mélanges et les ventes ne peuvent pas être utilisés
string	ls_data

ls_data = string(aa_value)
IF f_IsEmptyString(ls_data) THEN
	as_message = "L'utilisation doit être précisée"
	return(-1)
END IF

select trad into :as_message from v_utilflux where code = :ls_data using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Code UTILISATION FLUX incorrect"
	return(-1)
END IF

IF ls_data = "V" OR ls_data = "M" THEN
	as_message = "L'utilisation de ce code est réservée aux programmes prévus pour cela"
	return(-1)
END IF

return(1)


end function

public function integer uf_check_dtop (any aa_value, ref string as_message);// date du flux : obligatoire
date	l_date

l_date = gu_datetime.uf_dfromdt(aa_value)

// date doit être comprise entre le 01/01/1980 et le 31/12/2050
IF IsNull(l_date) OR l_date < date("1980-01-01") OR l_date > date("2050-12-31") THEN
	as_message = "La date doit être comprise entre le 01/01/1980 et le 31/12/2050"
	return(-1)
END IF

return(1)

end function

public function integer uf_check_lieustock (any aa_value, ref string as_message);// lieu de stockage : obligatoire
string	ls_data

ls_data = string(aa_value)
IF f_IsEmptyString(ls_data) THEN
	as_message = "Le lieu de stockage doit être précisé"
	return(-1)
END IF

return(1)


end function

public function integer uf_check_destinataire (any aa_value, ref string as_message);// DESTINATAIRE :  doit exister dans les interlocuteurs
string	ls_data

ls_data = string(aa_value)

select interlocuteur into :as_message from interlocuteur where locu = :ls_data using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Interlocuteur inexistant"
	return(-1)
END IF

return(1)


end function

public function integer uf_check_qte (any aa_value, ref string as_message, string as_signe, decimal ad_qterestante);// quantité obligatoire et on ne peut pas soustraire + que la qté en stock
// as_signe = + ou - en fonction du type d'opération choisi
decimal{3}	ld_data

IF f_IsEmptyString(as_signe) THEN
	as_message = "Veuillez choisir le type d'utilisation avant d'introduire la quantité."
	return(-1)
END IF

ld_data = dec(aa_value)
IF IsNull(ld_data) OR ld_data <= 0 THEN
	as_message = "La quantité doit être spécifiée"
	return(-1)
END IF

// tester que la quantité soustraite n'est pas < à la quantité en stock
IF as_signe = "-" THEN
	IF (ad_qterestante - ld_data) < 0 THEN
		as_message = "Vous ne pouvez pas retirer + que la quantitié en stock."
		return(-1)
	END IF
END IF

return(1)


end function

on br_flux.create
call super::create
TriggerEvent( this, "constructor" )
end on

on br_flux.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

