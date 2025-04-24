//objectcomments BR registre des graines - avant 27/11/2013
forward
global type br_registre_old from nonvisualobject
end type
end forward

global type br_registre_old from nonvisualobject
end type
global br_registre_old br_registre_old

type variables

end variables

forward prototypes
public function integer uf_check_codesp (any aa_value, ref string as_message)
public function integer uf_check_numprov (any aa_value, ref string as_message, string as_sp)
public function integer uf_check_reflot (any aa_value, ref string as_message)
public function integer uf_check_dtentree (any aa_value, ref string as_message)
public function integer uf_check_typegraine (any aa_value, ref string as_message)
public function integer uf_check_numfiche (any aa_value, ref string as_message)
public function integer uf_check_qteinit (any aa_value, ref string as_message)
public function integer uf_check_qteadm (any aa_value, ref string as_message)
public function integer uf_check_remqte (any aa_value, ref string as_message)
public function integer uf_check_melange (any aa_value, ref string as_message)
public function integer uf_check_admprov (any aa_value, ref string as_message)
public function integer uf_check_derog (any aa_value, ref string as_message)
public function integer uf_check_aninvent (any aa_value, ref string as_message)
public function integer uf_check_numfarde (any aa_value, ref string as_message)
public function integer uf_check_ogm (any aa_value, ref string as_message)
public function integer uf_check_anmaturite (any aa_value, ref string as_message)
public function integer uf_check_numcmfrn (any aa_value, ref string as_message)
public function integer uf_check_caract_purete_graine (any aa_value, ref string as_message)
public function integer uf_check_caract_purete_autregraine (any aa_value, ref string as_message)
public function integer uf_check_caract_poids1000 (any aa_value, ref string as_message)
public function integer uf_check_caract_teneureau (any aa_value, ref string as_message)
public function integer uf_check_caract_faculgerm (any aa_value, ref string as_message)
public function integer uf_check_caract_viabilite (any aa_value, ref string as_message)
public function integer uf_check_caract_comment (any aa_value, ref string as_message)
public function integer uf_check_numdf_recu (any aa_value, ref string as_message, string as_typegraine)
public function integer uf_check_caract_num (any aa_value, ref string as_message)
public function integer uf_check_caract_beforedelete (string as_reflot, date adt_date, integer ai_num, ref string as_message)
public function integer uf_check_numcm (any aa_value, ref string as_message, string as_typegraine, string as_reflot)
public function integer uf_check_paysreg_derog (any aa_value, ref string as_message)
public function integer uf_check_beforedelete (string as_reflot, ref string as_message, boolean ab_estdansunmelange)
public function string uf_init_remqte (string as_reflot)
public function integer uf_check_caract_beforeupdate (string as_reflot, date adt_date, integer ai_num, ref string as_message)
public function integer uf_check_caract_dt (any aa_value, ref string as_message)
end prototypes

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

public function integer uf_check_numprov (any aa_value, ref string as_message, string as_sp);// NUM_PROV : obligatoire et doit exister
integer	li_data

IF uf_check_codesp(as_sp, as_message) = -1 THEN
	as_message = "Veuillez d'abord introduire une espèce correcte"
	return(-1)
END IF

li_data = integer(aa_value)
IF IsNull(li_data) OR li_data = 0 THEN
	as_message = "La provenance doit être spécifiée"
	return(-1)
END IF

select nom into :as_message from provenance where code_sp = :as_sp and num_prov = :li_data using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Provenance inexistante"
	return(-1)
END IF
return(1)


end function

public function integer uf_check_reflot (any aa_value, ref string as_message);// référence interne du lot : obligatoire
string	ls_data

ls_data = string(aa_value)
IF f_IsEmptyString(ls_data) THEN
	as_message = "La référence interne du lot est obligatoire"
	return(-1)
END IF

return(1)


end function

public function integer uf_check_dtentree (any aa_value, ref string as_message);// Date d'entrée : obligatoire
date	l_date

l_date = gu_datetime.uf_dfromdt(aa_value)

// date doit être comprise entre le 01/01/1980 et le 31/12/2050
IF IsNull(l_date) OR l_date < date("1980-01-01") OR l_date > date("2050-12-31") THEN
	as_message = "La date d'entrée doit être comprise entre le 01/01/1980 et le 31/12/2050"
	return(-1)
END IF

return(1)

end function

public function integer uf_check_typegraine (any aa_value, ref string as_message);// Type de graine : obligatoire et doit exister
string	ls_data

ls_data = string(aa_value)
IF f_IsEmptyString(ls_data) THEN
	as_message = "Le type de graine doit être précisé"
	return(-1)
END IF

select trad into :as_message from v_typgraine where code = :ls_data using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Code TYPE_GRAINE incorrect"
	return(-1)
END IF
return(1)


end function

public function integer uf_check_numfiche (any aa_value, ref string as_message);// N° de fiche

return(1)


end function

public function integer uf_check_qteinit (any aa_value, ref string as_message);// Qté initiale : not null
decimal{3}	ld_data

ld_data = dec(aa_value)
IF IsNull(ld_data) THEN
	as_message = "La quantité initiale doit être spécifiée"
	return(-1)
END IF

return(1)


end function

public function integer uf_check_qteadm (any aa_value, ref string as_message);// Qté admise : not null
decimal{3}	ld_data

ld_data = dec(aa_value)
IF IsNull(ld_data) THEN
	as_message = "La quantité admise doit être spécifiée"
	return(-1)
END IF

return(1)


end function

public function integer uf_check_remqte (any aa_value, ref string as_message);// remarque sur les quantités

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

public function integer uf_check_admprov (any aa_value, ref string as_message);// admission provisoire : O/N/S
string	ls_data

ls_data = string(aa_value)

IF NOT match(ls_data,"^[ONS]$") THEN
	as_message = "Admission provisoire : Oui, Non, S/O"
	return(-1)
END IF

return(1)


end function

public function integer uf_check_derog (any aa_value, ref string as_message);// Motif dérogatoire : obligatoire et doit exister
string	ls_data

ls_data = string(aa_value)
IF f_IsEmptyString(ls_data) THEN
	as_message = "Le motif dérogatoire doit être précisé"
	return(-1)
END IF

select trad into :as_message from v_derog where code = :ls_data using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Code MOTIF_DEROG incorrect"
	return(-1)
END IF
return(1)


end function

public function integer uf_check_aninvent (any aa_value, ref string as_message);// année d'inventaire
integer	li_data

li_data = integer(aa_value)
IF IsNull(li_data) OR li_data < 1980 OR li_data > 2050 THEN
	as_message = "L'année d'inventaire doit être comprise entre 1980 et 2050"
	return(-1)
END IF

return(1)


end function

public function integer uf_check_numfarde (any aa_value, ref string as_message);// N° de farde

return(1)


end function

public function integer uf_check_ogm (any aa_value, ref string as_message);// OGM : O/N/S
string	ls_data

ls_data = string(aa_value)

IF NOT match(ls_data,"^[ONS]$") THEN
	as_message = "OGM : Oui, Non, S/O"
	return(-1)
END IF

return(1)


end function

public function integer uf_check_anmaturite (any aa_value, ref string as_message);// année de maturite
integer	li_data

li_data = integer(aa_value)
IF li_data < 1900 THEN
	as_message = "Année de maturité incorrecte"
	return(-1)
END IF

return(1)


end function

public function integer uf_check_numcmfrn (any aa_value, ref string as_message);// N° de certificat maître du fournisseur
return(1)

end function

public function integer uf_check_caract_purete_graine (any aa_value, ref string as_message);// Caractéristiques des graines : % purete_graine obligatoire
decimal{2}	ld_data

ld_data = dec(aa_value)

IF IsNull(ld_data) THEN
	as_message = "Une valeur doit être donnée pour le champ '% pureté graines'"
	return(-1)
END IF

IF ld_data > 100 THEN
	as_message = "Le pourcentage ne peut excéder 100%"
	return(-1)
END IF

return(1)

end function

public function integer uf_check_caract_purete_autregraine (any aa_value, ref string as_message);// Caractéristiques des graines : % purete_autregraine obligatoire
decimal{2}	ld_data

ld_data = dec(aa_value)

IF IsNull(ld_data) THEN
	as_message = "Une valeur doit être donnée pour le champ '% pureté autres graines'"
	return(-1)
END IF

IF ld_data > 100 THEN
	as_message = "Le pourcentage ne peut excéder 100%"
	return(-1)
END IF

return(1)

end function

public function integer uf_check_caract_poids1000 (any aa_value, ref string as_message);// Caractéristiques des graines : poids de 1000 graines obligatoire
IF IsNull(aa_value) THEN
	as_message = "Une valeur doit être donnée pour le champ 'poids de 1000 graines'"
	return(-1)
END IF

return(1)

end function

public function integer uf_check_caract_teneureau (any aa_value, ref string as_message);// Caractéristiques des graines : % teneur en eau 
decimal{2}	ld_data

ld_data = dec(aa_value)

IF ld_data > 100 THEN
	as_message = "Le pourcentage ne peut excéder 100%"
	return(-1)
END IF

return(1)

end function

public function integer uf_check_caract_faculgerm (any aa_value, ref string as_message);// Caractéristiques des graines : % faculté germinative 
decimal{2}	ld_data

ld_data = dec(aa_value)

IF ld_data > 100 THEN
	as_message = "Le pourcentage ne peut excéder 100%"
	return(-1)
END IF

return(1)

end function

public function integer uf_check_caract_viabilite (any aa_value, ref string as_message);// Caractéristiques des graines : % viabilité
decimal{2}	ld_data

ld_data = dec(aa_value)

IF ld_data > 100 THEN
	as_message = "Le pourcentage ne peut excéder 100%"
	return(-1)
END IF

return(1)


end function

public function integer uf_check_caract_comment (any aa_value, ref string as_message);// Caractéristiques des graines : commentaire
return(1)

end function

public function integer uf_check_numdf_recu (any aa_value, ref string as_message, string as_typegraine);// N° de document fournisseur reçu : obligatoire (et doit exister) si type de graine = achat/négoce (A)
// 10/12/2008 : même traitement pour type de graine = non soumis (N)
string	ls_data

ls_data = string(aa_value)

IF as_typegraine <> "A" AND as_typegraine <> "N" THEN
	return(1)
END IF

IF as_typegraine = "A" AND f_IsEmptyString(ls_data) THEN
	as_message = "Le n° de document-fournisseur reçu doit être spécifié car il s'agit d'un achat/négoce"
	return(-1)
END IF

IF as_typegraine = "N" AND f_IsEmptyString(ls_data) THEN
	as_message = "Le n° de document-fournisseur reçu doit être spécifié car il s'agit d'une espèce non soumise"
	return(-1)
END IF

return(1)


end function

public function integer uf_check_caract_num (any aa_value, ref string as_message);// Caractéristiques des graines : n° des mesures (souvent 1 seul)
integer	li_data

li_data = integer(aa_value)

IF IsNull(li_data) OR li_data =0 THEN
	as_message = "Le n° de la mesure doit être > 0"
	return(-1)
END IF

return(1)

end function

public function integer uf_check_caract_beforedelete (string as_reflot, date adt_date, integer ai_num, ref string as_message);// vérification avant suppression d'une ligne de caractéristiques graine
long	ll_count

as_message = "Les caractéristiques n° " + f_string(ai_num) + " du " + string(adt_date, "dd/mm/yyyy") + &
	" sont encore utilisées dans les documents fournisseur.~n" + &
	"Si vous les supprimez, la date de ces caractéristiques sera annulée dans ces documents fournisseurs."

select count(*) into :ll_count from docfrn where ref_lot = :as_reflot and dt_caract=:adt_date 
		and num_caract = :ai_num using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Erreur select DOCFRN"
	return(-1)
END IF
IF ll_count > 0 THEN
	return(-1)
END IF

return(1)

return(1)

end function

public function integer uf_check_numcm (any aa_value, ref string as_message, string as_typegraine, string as_reflot);// N° de certificat maître : 
//		.seulement si type de graine = préparé (P) 
//		. obligatoire et doit exister
//		. un seul lot peut porter le même n° de CM
string	ls_data, ls_autreLot

ls_data = string(aa_value)

IF as_typegraine <> "P" THEN
	return(1)
END IF

IF f_IsEmptyString(ls_data) THEN
	as_message = "Le n° de certificat-maître doit être mentionné dans le cas des lots préparés par le Comptoir"
	return(-1)
END IF

select type_mfr into :as_message from certificat where num_cm = :ls_data using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Certificat-maître inexistant"
	return(-1)
END IF

select ref_lot into :ls_autreLot from registre where num_cm = :ls_data and ref_lot <> :as_reflot using ESQLCA;
IF f_check_sql(ESQLCA) <> 100 THEN
	as_message = "Le lot n° " + ls_autreLot + " fait déjà référence à ce n° de certificat"
	return(-1)
END IF

return(1)


end function

public function integer uf_check_paysreg_derog (any aa_value, ref string as_message);// Catégorie dérogatoire : Pays/Région
return(1)

end function

public function integer uf_check_beforedelete (string as_reflot, ref string as_message, boolean ab_estdansunmelange);// vérification avant suppression
long	ll_count

// suppression : seulement si le lot n'est pas dans un mélange
IF ab_estDansUnMelange THEN
	as_message = "Ce lot fait partie d'un (ou plusieurs) mélange(s). Si vous voulez le supprimer, il faut d'abord le retirer de ce mélange."
	return(-1)
END IF

as_message = "Le lot n° " + f_string(as_reflot) + " est encore utilisé.~n~n" + &
"Si vous voulez le supprimer, il faut d'abord supprimer toute référence vers lui dans les &
documents fournisseur et les commandes client."

select count(*) into :ll_count from docfrn where ref_lot = :as_reflot using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Erreur select DOCFRN"
	return(-1)
END IF
IF ll_count > 0 THEN
	return(-1)
END IF

select count(*) into :ll_count from DETAIL_CMDE where ref_lot = :as_reflot using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Erreur select DETAIL_CMDE"
	return(-1)
END IF
IF ll_count > 0 THEN
	return(-1)
END IF

return(1)

end function

public function string uf_init_remqte (string as_reflot);// Initialiser le commentaire avec le calcul des proportions en cas de mélange.
// Uniquement pour les lots déjà enregistrés et de type mélange.
// return = le texte calculé
uo_ds		lds_composants
string	ls_numcm, ls_melange, ls_texte
long		ll_row

select melange, num_cm into :ls_melange, :ls_numcm from registre
	where ref_lot = :as_reflot using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	return(gu_c.s_null)
END IF

IF f_isEmptyString(ls_numcm) THEN return(gu_c.s_null)
IF ls_melange = "N" THEN return(gu_c.s_null)

lds_composants = CREATE uo_ds

// mélange d'années de maturité ou de provenance : DS différent
IF ls_melange = "A" THEN
	lds_composants.dataobject = "ds_melange_anmaturite_prop"
ELSE
	lds_composants.dataobject = "ds_melange_provenance_prop"
END IF

// concaténer pour créer un seul string
lds_composants.setTransObject(SQLCA)
lds_composants.retrieve(ls_numcm)
FOR ll_row = 1 TO lds_composants.rowCount()
	ls_texte = ls_texte + lds_composants.object.pc[ll_row] + " + "
NEXT
IF NOT f_IsEmptyString(ls_texte) THEN
	ls_texte = LeftA(ls_texte, LenA(ls_texte) - 3)
END IF

DESTROY lds_composants

IF NOT f_IsEmptyString(ls_texte) THEN
	return(ls_texte)
ELSE
	return(gu_c.s_null)
END IF

end function

public function integer uf_check_caract_beforeupdate (string as_reflot, date adt_date, integer ai_num, ref string as_message);// vérification avant modification date et n° d'une ligne de caractéristiques graine
long	ll_count

as_message = "Les caractéristiques n° " + f_string(ai_num) + " du " + string(adt_date, "dd/mm/yyyy") + &
	" sont utilisées dans les documents fournisseur.~n" + &
	"Leur date et n° ne peuvent plus être modifiés."

select count(*) into :ll_count from docfrn where ref_lot = :as_reflot and dt_caract=:adt_date 
		and num_caract = :ai_num using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = "Erreur select DOCFRN"
	return(-1)
END IF
IF ll_count > 0 THEN
	return(-1)
END IF

return(1)

return(1)

end function

public function integer uf_check_caract_dt (any aa_value, ref string as_message);// Caractéristiques des graines : date d'entrée de mesure obligatoire
// Attention : si les caractéristiques sont utilisées dans un document fournisseur, on ne peut plus
//             en modifier la date et le n° (car utilisés comme foreign key dans table DOCFRN)
//		--> utiliser uf_check_caract_beforeUpdate() AVANT de faire les check normaux.
date	l_date

l_date = gu_datetime.uf_dfromdt(aa_value)

// date doit être comprise entre le 01/01/1980 et le 31/12/2050
IF IsNull(l_date) OR l_date < date("1980-01-01") OR l_date > date("2050-12-31") THEN
	as_message = "La date de mesure doit être comprise entre le 01/01/1980 et le 31/12/2050"
	return(-1)
END IF

return(1)

end function

on br_registre_old.create
call super::create
TriggerEvent( this, "constructor" )
end on

on br_registre_old.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

