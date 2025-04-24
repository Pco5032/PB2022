//objectcomments Ensemble de fonctions permettant de définir les critères de sélection et de tri qui doivent être utilisés par l'écran de sélection
forward
global type uo_critselect from nonvisualobject
end type
end forward

global type uo_critselect from nonvisualobject
end type
global uo_critselect uo_critselect

type variables

end variables

forward prototypes
public function integer uf_setdefault (string as_reportcritere, string as_modele, integer ai_numcrit, string as_critere, string as_operateur)
public function integer uf_setdefault (string as_reportcritere, string as_modele, integer ai_numcrit, string as_critere, string as_operateur, any aa_valeur)
public function integer uf_setdefault (string as_reportcritere, string as_modele, integer ai_numcrit, string as_critere, string as_operateur, any aa_valeur, boolean ab_obligatoire)
public function integer uf_setdefault (string as_reportcritere, string as_modele, integer ai_numcrit, string as_critere, string as_operateur, boolean ab_obligatoire)
public function integer uf_setdefault (string as_reportcritere, string as_modele, integer ai_numcrit, string as_par1, string as_critere, string as_operateur, string as_par2, boolean ab_obligatoire)
public function integer uf_setdefault (string as_reportcritere, string as_modele, integer ai_numcrit, string as_par1, string as_critere, string as_operateur, any aa_valeur, string as_par2, boolean ab_obligatoire)
public function integer uf_setdefault (string as_reportcritere, string as_modele, integer ai_numcrit, string as_par1, string as_critere, string as_operateur, any aa_valeur, string as_par2, string as_connect, boolean ab_obligatoire, boolean ab_valeurmodifiable)
public function integer uf_setdefaulttri (string as_reportcritere, string as_modele, integer ai_numcrittri, string as_critere, string as_ordre, string as_groupe, string as_newpage)
public function integer uf_setdefaulttri (string as_reportcritere, string as_modele, integer ai_numcrittri, string as_critere, string as_ordre)
public function integer uf_resetdefaults (string as_modele)
public function integer uf_setdefaulttri (string as_reportcritere, string as_modele, integer ai_numcrittri, string as_critere)
end prototypes

public function integer uf_setdefault (string as_reportcritere, string as_modele, integer ai_numcrit, string as_critere, string as_operateur);return(uf_setdefault(as_reportcritere, as_modele, ai_numcrit, "",as_critere,as_operateur,"","","and",FALSE, TRUE))
end function

public function integer uf_setdefault (string as_reportcritere, string as_modele, integer ai_numcrit, string as_critere, string as_operateur, any aa_valeur);return(uf_setdefault(as_reportcritere, as_modele, ai_numcrit, "",as_critere,as_operateur,aa_valeur,"","and",FALSE,TRUE))

end function

public function integer uf_setdefault (string as_reportcritere, string as_modele, integer ai_numcrit, string as_critere, string as_operateur, any aa_valeur, boolean ab_obligatoire);return(uf_setdefault(as_reportcritere, as_modele, ai_numcrit, "",as_critere,as_operateur,aa_valeur,"","and",ab_obligatoire,TRUE))

end function

public function integer uf_setdefault (string as_reportcritere, string as_modele, integer ai_numcrit, string as_critere, string as_operateur, boolean ab_obligatoire);return(uf_setdefault(as_reportcritere, as_modele, ai_numcrit, "",as_critere,as_operateur,"","","and",ab_obligatoire,TRUE))
end function

public function integer uf_setdefault (string as_reportcritere, string as_modele, integer ai_numcrit, string as_par1, string as_critere, string as_operateur, string as_par2, boolean ab_obligatoire);return(uf_setdefault(as_reportcritere, as_modele, ai_numcrit, as_par1,as_critere,as_operateur,"",as_par2,"and",ab_obligatoire,TRUE))


end function

public function integer uf_setdefault (string as_reportcritere, string as_modele, integer ai_numcrit, string as_par1, string as_critere, string as_operateur, any aa_valeur, string as_par2, boolean ab_obligatoire);return(uf_setdefault(as_reportcritere, as_modele, ai_numcrit, as_par1,as_critere,as_operateur,aa_valeur,as_par2,"and",ab_obligatoire,TRUE))


end function

public function integer uf_setdefault (string as_reportcritere, string as_modele, integer ai_numcrit, string as_par1, string as_critere, string as_operateur, any aa_valeur, string as_par2, string as_connect, boolean ab_obligatoire, boolean ab_valeurmodifiable);// insérer dans la table report_select le critère de sélection dont 
// les éléments sont passés en argument
// return(1) = OK
// return(-1) = le critère passé en argument n'est pas valide
// return(-2) = erreur insert du nouveau critère
string	ls_datatype, ls_operateur, ls_operateur_long, ls_val, ls_obligatoire, ls_valeurmodifiable
long		ll_count
decimal	ld_val
date		ldt_val

as_reportcritere = upper(as_reportcritere)
as_critere = upper(as_critere)
as_modele = upper(as_modele)

IF ab_obligatoire THEN 
	ls_obligatoire = "O"
ELSE
	ls_obligatoire = "N"
END IF
IF ab_valeurmodifiable THEN 
	ls_valeurmodifiable = "O"
ELSE
	ls_valeurmodifiable = "N"
END IF

SELECT count(critere) into :ll_count from report_critere 
	WHERE report = :as_reportcritere and critere = :as_critere USING ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	gu_message.uf_error("REPORT_CRITERE","Critère " + as_critere + " non valide dans report " + as_reportcritere)
	return(-1)
END IF

SELECT detail_critere.datatype INTO :ls_datatype
	FROM detail_critere, report_critere  
	WHERE detail_critere.num_detail_critere = report_critere.num_detail_critere AND
         report_critere.report = :as_reportcritere AND  
         report_critere.critere = :as_critere USING ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	gu_message.uf_error("DETAIL_CRITERE","Critère " + as_critere + " non valide dans report " + as_reportcritere)
	return(-1)
END IF

SetNull(ldt_val)
SetNull(ld_val)
SetNull(ls_val)

IF PosA(upper(as_operateur),"BETWEEN") > 0 OR PosA(upper(as_operateur),"IN") > 0 OR &
	PosA(upper(as_operateur),"LIKE") > 0 THEN
		ls_val = aa_valeur
ELSE
	CHOOSE CASE ls_datatype
		CASE "D"
			IF NOT f_IsEmptyString(string(aa_valeur)) THEN ldt_val = aa_valeur
		CASE "N"
			IF NOT f_IsEmptyString(string(aa_valeur)) THEN ld_val = aa_valeur
		CASE "S"
			IF NOT f_IsEmptyString(string(aa_valeur)) THEN ls_val = aa_valeur
	END CHOOSE
END IF

IF ls_datatype = "L" THEN
	ls_operateur_long = as_operateur
	SetNull(ls_operateur)
ELSE
	ls_operateur = as_operateur
	SetNull(ls_operateur_long)
END IF

INSERT INTO report_select
	COLUMNS(USERNAME, MODELE, TYPE, TRI, PAR1, PAR2, CRITERE, OPERATEUR, OPERATEUR_LONG, VALEUR_STRING, 
			  VALEUR_NUMBER, VALEUR_DATE, CONNECTEUR, OBLIGATOIRE, VALEURMODIFIABLE)
	VALUES(:gs_username, :as_modele, 'D', :ai_numcrit,:as_par1, :as_par2, :as_critere, :ls_operateur, :ls_operateur_long, 
			 :ls_val, :ld_val, :ldt_val, :as_connect, :ls_obligatoire, :ls_valeurmodifiable) USING ESQLCA;
IF f_check_sql(ESQLCA) = 0 THEN
	commit USING ESQLCA;
	return(1)
ELSE
	rollback USING ESQLCA;
	gu_message.uf_error("Erreur création du critère " + as_critere + " dans report " + as_reportcritere)
	return(-2)
END IF

end function

public function integer uf_setdefaulttri (string as_reportcritere, string as_modele, integer ai_numcrittri, string as_critere, string as_ordre, string as_groupe, string as_newpage);// insérer dans la table report_selecttri le critère de tri 'as_critere' et l'ordre souhaité 'as_ordre'
// return(1) = OK
// return(-1) = erreur dans les arguments
// return(-2) = erreur insert du nouveau critère de tri
long		ll_count

as_reportcritere = upper(as_reportcritere)
as_critere = upper(as_critere)
as_modele = upper(as_modele)
as_ordre = upper(as_ordre)

IF as_ordre <> "A" and as_ordre <> "D" THEN
	gu_message.uf_error("Ordre de tri demandé (" + as_ordre + ") non valide")
	return(-1)
END IF
IF as_ordre = "A" THEN 
	as_ordre = "O"
ELSE
	as_ordre = "N"
END IF

SELECT count(critere) into :ll_count from report_critere 
	WHERE report = :as_reportcritere and critere = :as_critere USING ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	gu_message.uf_error("REPORT_CRITERE","Critère " + as_critere + " non valide dans report " + as_reportcritere)
	return(-1)
END IF

INSERT INTO report_selecttri
	VALUES(:gs_username, :as_modele, 'D', :ai_numcrittri, :as_critere, :as_ordre, :as_groupe, :as_newpage) USING ESQLCA;
IF f_check_sql(ESQLCA) = 0 THEN
	commit USING ESQLCA;
	return(1)
ELSE
	rollback USING ESQLCA;
	gu_message.uf_error("Erreur création du critère de tri " + as_critere + " dans report " + as_reportcritere)
	return(-2)
END IF

end function

public function integer uf_setdefaulttri (string as_reportcritere, string as_modele, integer ai_numcrittri, string as_critere, string as_ordre);// si on ne précise pas les paramètres de regroupements, on ne prévoit pas de regroupement dynamique
return(uf_setdefaulttri(as_reportcritere, as_modele, ai_numcrittri, as_critere, as_ordre, "N", "N"))
end function

public function integer uf_resetdefaults (string as_modele);// effacer les critères de sélection par défaut existant pour le modèle passé en argument
// return 1 si OK
// return -1 en cas d'erreur
as_modele = upper(as_modele)
DELETE FROM report_select 
	WHERE username = :gs_username AND modele = :as_modele AND type='D' USING ESQLCA;
IF f_check_sql(ESQLCA) = 0 THEN 
	commit USING ESQLCA;
ELSE
	rollback USING ESQLCA;
	return(-1)
END IF

DELETE FROM report_selecttri
	WHERE username = :gs_username AND modele = :as_modele AND type='D' USING ESQLCA;
IF f_check_sql(ESQLCA) = 0 THEN 
	commit USING ESQLCA;
ELSE
	rollback USING ESQLCA;
	return(-1)
END IF

return(1)
end function

public function integer uf_setdefaulttri (string as_reportcritere, string as_modele, integer ai_numcrittri, string as_critere);// si on ne précise pas l'ordre de tri ni les paramètres de regroupements, 
// ascendant est utilisé par défaut et on ne prévoit pas de regroupement dynamique
return(uf_setdefaulttri(as_reportcritere, as_modele, ai_numcrittri, as_critere, "A", "N", "N"))
end function

on uo_critselect.create
call super::create
TriggerEvent( this, "constructor" )
end on

on uo_critselect.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

