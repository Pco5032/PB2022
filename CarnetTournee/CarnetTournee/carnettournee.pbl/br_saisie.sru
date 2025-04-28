//objectcomments BR pour l'encodage des plannings et des activités réalisées
forward
global type br_saisie from nonvisualobject
end type
end forward

global type br_saisie from nonvisualobject
end type
global br_saisie br_saisie

type variables

end variables

forward prototypes
public function integer uf_check_datep (any aa_value, ref string as_message, integer ai_year, integer ai_week)
public function integer uf_check_accomp (any aa_value, ref string as_message)
public function integer uf_check_duree (any aa_value, ref string as_message)
public function integer uf_check_irreg (integer ai_idprest, any aa_value, ref string as_message)
public function integer uf_check_rappel (integer ai_idprest, any aa_value, ref string as_message)
public function integer uf_check_km (any aa_value, ref string as_message)
public function integer uf_check_sejour (any aa_value, ref string as_message)
public function integer uf_check_niveau1 (any aa_value, ref string as_message)
public function integer uf_check_niveau2 (integer ai_niveau1, any aa_value, ref string as_message)
public function integer uf_check_idprest (integer ai_niveau2, any aa_value, ref string as_message)
public function integer uf_check_hdeb (string as_pr, string as_irreg, datetime adt_dureeforfait, string as_garde, string as_interim, date ad_datep, datetime adt_hfin, any aa_value, ref string as_message)
public function integer uf_check_hfin (string as_pr, string as_irreg, datetime adt_dureeforfait, string as_garde, string as_interim, date ad_datep, datetime adt_hdebut, any aa_value, ref string as_message)
public function integer uf_check_prest (string as_par, string aa_value, ref string as_message)
public function integer uf_convert_idprest (integer ai_version, integer ai_idprest)
public function integer uf_check_commentaire (integer ai_km, string as_interim, any aa_value, ref string as_message)
public function integer uf_check_lieu (string as_interim, any aa_value, ref string as_message)
public function integer uf_check_nbre (any aa_value, ref string as_message, integer ai_idprest)
public function integer uf_check_row (date adt_datep, integer ai_niveau2, ref string as_message)
end prototypes

public function integer uf_check_datep (any aa_value, ref string as_message, integer ai_year, integer ai_week);// la date doit se trouver dans la semaine choisie
date	l_date
integer	li_year, li_week

// l_date = date(aa_value)
l_date = gu_datetime.uf_dfromdt(aa_value)

IF isNull(l_date) THEN
	as_message = f_translate_getlabel("TEXT_00776", "Veuillez saisir une date de prestation")
	return(-1)
END IF

// calculer la semaine dans laquelle se trouve la date encodée
select substr(SemaineFromDate_CT(:l_date), 1, 4), substr(SemaineFromDate_CT(:l_date), 6) 
	into :li_year, :li_week from dual using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = f_translate_getlabel("TEXT_00775", "Erreur lecture SEMAINE : connexion perdue base de données perdue ?")
	return(-1)
END IF

IF li_year <> ai_year OR li_week <> ai_week THEN
	as_message = f_translate_getlabel("TEXT_00743", "La date encodée n'est pas dans la semaine choisie")
	return(-1)
END IF

return(1)
end function

public function integer uf_check_accomp (any aa_value, ref string as_message);// personnes ayant participé à l'activité (facultatif)

return(1)
end function

public function integer uf_check_duree (any aa_value, ref string as_message);// la durée de l'activité doit être indiquée (même si elle vaut 0)
time	lt_data

lt_data = time(datetime(aa_value))
IF isNull(lt_data) THEN
	as_message = f_translate_getlabel("TEXT_00744", "Veuillez saisir la durée de l'activité")
	return(-1)
END IF

return(1)

end function

public function integer uf_check_irreg (integer ai_idprest, any aa_value, ref string as_message);// Type prestation irrégulière O/N.
// Le code prestation doit être compatible.
string	ls_data, ls_compat

ls_data = f_string(aa_value)
IF f_isEmptyString(ls_data) OR NOT match(ls_data,"^[ON]$") THEN
	as_message = f_translate_getlabel("TEXT_00757", "Veuillez préciser s'il s'agit d'une prestation irrégulière ou pas")
	return(-1)
END IF

IF NOT isNull(ai_idprest) THEN
	select irregcompat into :ls_compat from v_dicoprest where idprest=:ai_idprest using ESQLCA;
	IF ESQLCA.sqlnrows = 1 THEN
		IF ls_data = "O" AND ls_compat = "N" THEN
			as_message = f_translate_getlabel("TEXT_00758", "Le code prestation sélectionné ne peut pas être utilisé pour une prestation irrégulière et/ou un rappel")
			return(-1)
		END IF
	ELSE
		// code inexistant : on laisse passer, ce sera revérifié après correction du code
		return(1)
	END IF
END IF

return(1)
end function

public function integer uf_check_rappel (integer ai_idprest, any aa_value, ref string as_message);// Rappel O/N. 
// "O" possible uniquemenent dans le cas de prestation irrégulière (irreg="O")
string	ls_data, ls_compat

ls_data = f_string(aa_value)
IF f_isEmptyString(ls_data) OR NOT match(ls_data,"^[ON]$") THEN
	as_message = f_translate_getlabel("TEXT_00767", "Veuillez préciser s'il s'agit d'un rappel ou pas")
	return(-1)
END IF

// Le code prestation doit être compatible.
IF ls_data = "O" THEN
	IF NOT isNull(ai_idprest) THEN
		select irregcompat into :ls_compat from v_dicoprest where idprest=:ai_idprest using ESQLCA;
		IF ESQLCA.sqlnrows = 1 THEN
			IF ls_compat = "N" THEN
				as_message = f_translate_getlabel("TEXT_00758", "Le code prestation sélectionné ne peut pas être utilisé pour une prestation irrégulière et/ou un rappel")
				return(-1)
			END IF
		ELSE
			// code inexistant : on laisse passer, ce sera revérifié après correction du code
			return(1)
		END IF
	END IF
END IF

return(1)
end function

public function integer uf_check_km (any aa_value, ref string as_message);// km parcourus
integer	li_km

li_km = integer(aa_value)
IF isNull(li_km) THEN
	as_message = f_translate_getlabel("TEXT_00759", "Veuillez spécifier le nombre de km parcourus (même si c'est 0)")
	return(-1)
END IF
return(1)
end function

public function integer uf_check_sejour (any aa_value, ref string as_message);// Frais de séjour s'appliquent O/N.
string	ls_data, ls_compat

ls_data = f_string(aa_value)
IF f_isEmptyString(ls_data) OR NOT match(ls_data,"^[ON]$") THEN
	as_message = f_translate_getlabel("TEXT_00768", "Veuillez préciser si des frais de séjour s'appliquent ou pas")
	return(-1)
END IF

return(1)
end function

public function integer uf_check_niveau1 (any aa_value, ref string as_message);// la catégorie de prestation niveau 1 doit être spécifiée et doit exister
integer	li_data

li_data = integer(aa_value)
IF isNull(li_data) Or li_data = 0 THEN
	as_message = f_translate_getlabel("TEXT_00761", "Veuillez sélectionner une matière")
	return(-1)
END IF

select intitule into :as_message from v_dicoprest where niveau= 1 and idprest=:li_data using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = f_translate_getlabel("TEXT_00762", "Matière inconnue")
	return(-1)
END IF

return(1)
end function

public function integer uf_check_niveau2 (integer ai_niveau1, any aa_value, ref string as_message);// la catégorie de prestation niveau 2 doit être spécifiée et doit exister dans le niveau1 de la catégorie
integer	li_data, li_idNiveau1
string	ls_code

IF isnull(ai_niveau1) OR ai_niveau1 = 0 THEN
	as_message = f_translate_getlabel("TEXT_00763", "Veuillez d'abord sélectionner la matière de la prestation")
	return(-1)
END IF

li_data = integer(aa_value)
IF isNull(li_data) Or li_data = 0 THEN
	as_message = f_translate_getlabel("TEXT_00764", "Veuillez sélectionner une filière")
	return(-1)
END IF

select idpere, code into :li_idNiveau1, :ls_code 
	from v_dicoprest where niveau= 2 and idprest=:li_data using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = f_translate_getlabel("TEXT_00765", "Filière inconnue")
	return(-1)
END IF

IF li_idNiveau1 <> ai_niveau1 THEN
	as_message = f_translate_getlabel("TEXT_00766", "Cette filière n'appartient pas à la matière choisie")
	return(-1)
END IF

as_message = ls_code
return(1)
end function

public function integer uf_check_idprest (integer ai_niveau2, any aa_value, ref string as_message);// La prestation doit être spécifiée et doit exister dans le niveau 2 sélectionné.
integer	li_data, li_idNiveau2
string	ls_intitule

IF isnull(ai_niveau2) OR ai_niveau2 = 0 THEN
	as_message = f_translate_getlabel("TEXT_00753", "Veuillez d'abord sélectionner la matière et/ou la filière")
	return(-1)
END IF

li_data = integer(aa_value)
IF isNull(li_data) THEN
	as_message = f_translate_getlabel("TEXT_00754", "Veuillez sélectionner une action")
	return(-1)
END IF

select idpere,  code||'. '||intitule into :li_idNiveau2, :ls_intitule
	from v_dicoprest where niveau = 3 and idprest = :li_data using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	as_message = f_translate_getlabel("TEXT_00755", "Code prestation inconnu")
	return(-1)
END IF

IF li_idNiveau2 <> ai_niveau2 THEN
	as_message = f_translate_getlabel("TEXT_00756", "L'action sélectionnée n'appartient pas à la filière choisie")
	return(-1)
END IF

as_message = ls_intitule
return(1)

end function

public function integer uf_check_hdeb (string as_pr, string as_irreg, datetime adt_dureeforfait, string as_garde, string as_interim, date ad_datep, datetime adt_hfin, any aa_value, ref string as_message);/////////////////////////////////////////////////////////////////////////////////////////////
// AU 20/10/2014 : vérif. se limite à avoir une heure de fin > heure de début !
// (pas de vérif WE, jours fériés, congés et plage de 18:30 à 7h30)
// Edit FEV 2015 : si on implémente un jour ces vérif, attention à distinguer les règles pour les
//						 prestations régulières et irrégulières.
/////////////////////////////////////////////////////////////////////////////////////////////

// Prestations irrégulières : heure de début et de fin d'activité doivent être précisées.
// Edit FEv 2015 : 
// 	. planning : possibilité d'encoder hdeb et hfin pour des prestations régulières.
//		. réalisé : obligation d'encoder hdeb et hfin pour des prestations régulières, pour les 
//						nouvelles prestations uniquement !
//
// L'heure de début doit être >= 18h30. !!! voir edit plus haut
// Cas particulier : on ne sait pas encoder 24:00 pour signifier un début d'activité à minuit.
// On encode donc 00:00, mais il faut l'interpréter manuellement.
// as_irreg : O si prestation irrégulières, N si prestation normale
// ad_datep : date de la prestation
// return(1) si ok
// return(-1) si erreur
// return(0) : indécision, heure pas dans la plage de validité, l'utilisateur devra confirmer

time		lt_debut, lt_fin, lt_dureeforfait
integer	li_daynr

lt_debut = time(datetime(aa_value))
lt_fin = time(adt_hfin)
lt_dureeforfait = time(adt_dureeforfait)

// PLANNING, prestation normale : heures de début et de fin d'activité facultatives
// MAIS INTERDITE s'il y a une durée forfaitaire ou si GARDE/INTERIM
// Validité : 07h30 - 18h30
IF as_pr = "P" AND as_irreg = "N" THEN
	IF isNull(lt_debut) AND isNull(lt_fin) THEN
		return(1)
	ELSEIF NOT isNull(lt_dureeforfait) AND NOT isNull(lt_debut) THEN
		as_message = f_translate_getlabel("TEXT_00745", "Prestation régulière avec durée forfaitaire : pas d'encodage des heures de début et de fin d'activité")
		return(-1)
	ELSEIF as_garde = "O" AND NOT isNull(lt_debut) THEN
		as_message = f_translate_getlabel("TEXT_00746", "Permanence : pas d'encodage des heures de début et de fin d'activité")
		return(-1)
	ELSEIF as_interim = "O" AND NOT isNull(lt_debut) THEN
		as_message = f_translate_getlabel("TEXT_00747", "Intérim : pas d'encodage des heures de début et de fin d'activité")
		return(-1)
	ELSEIF isNull(lt_debut) AND NOT isNull(lt_fin) THEN
		as_message = f_translate_getlabel("TEXT_00748", "Vous avez introduit une heure de fin. Veuillez introduire une heure de début ou saisir directement une durée.")
		return(-1)
	ELSEIF NOT isNull(lt_debut) AND (lt_debut < time("7:30") OR lt_debut > time("18:30")) THEN
		as_message = f_translate_getlabel("TEXT_00749", "Les prestations régulières doivent être comprises entre 7h30 et 18h30")
		return(-1)
	END IF
END IF

// REALISE, prestation normale : heures de debut et de fin obligatoires
// SAUF s'il y a une durée forfaitaire ou si GARDE/INTERIM (elle est dans ce cas interdite)
// Validité : 07h30 - 18h30
IF as_pr = "R" AND as_irreg = "N" THEN
	IF as_garde = "O" THEN
		IF isNull(lt_debut) THEN
			return(1)
		ELSE
			as_message = f_translate_getlabel("TEXT_00746", "Permanence : pas d'encodage des heures de début et de fin d'activité")
			return(-1)
		END IF
	END IF
	IF as_interim = "O" THEN
		IF isNull(lt_debut) THEN
			return(1)
		ELSE
			as_message = f_translate_getlabel("TEXT_00747", "Intérim : pas d'encodage des heures de début et de fin d'activité")
			return(-1)
		END IF
	END IF
	
	IF NOT isNull(lt_dureeforfait) THEN
		IF isNull(lt_debut) THEN
			return(1)
		ELSE
			as_message = f_translate_getlabel("TEXT_00745", "Prestation régulière avec durée forfaitaire : pas d'encodage des heures de début et de fin d'activité")
			return(-1)
		END IF
	ELSE
		IF isNull(lt_debut) THEN
			as_message = f_translate_getlabel("TEXT_00750", "Veuillez indiquer les heures de début et de fin d'activité")
			return(-1)
		ELSEIF lt_debut < time("7:30") OR lt_debut > time("18:30") THEN
			as_message = f_translate_getlabel("TEXT_00749", "Les prestations régulières doivent être comprises entre 7h30 et 18h30")
			return(-1)
		END IF
	END IF
END IF

// PLANNING et REALISE, prestations irrégulières : heures de debut et de fin obligatoires
// MEME s'il y a une durée forfaitaire (elle est alors remplacée par la durée calculée)
IF as_irreg = "O" AND as_garde = "N" AND as_interim = "N" THEN
	IF isNull(lt_debut) THEN
		as_message = f_translate_getlabel("TEXT_00750", "Veuillez indiquer les heures de début et de fin d'activité")
		return(-1)
	END IF
END IF

// heure introduite = 00:00 : OK
IF hour(lt_debut) = 0 AND minute(lt_debut) = 0 THEN
	return(1)
END IF

return(1)

/*
// Hors WE : vérification plage de validité (18h30 - 7h30)
// jour de la semaine : dimanche=1, samedi=7
li_daynr = dayNumber(ad_datep)

IF li_daynr <> 1 AND li_daynr <> 7 THEN
	IF (lt_debut >= time("18:30") AND lt_debut <= time("23:59")) OR &
		(lt_debut >= time("00:01") AND lt_debut <= time("07:30")) THEN
		return(1)
	ELSE
		as_message = "Une prestation irrégulière doit se situer entre 18h30 et 7h30 excepté les WE, jours fériés et congés."
		return(0)
	END IF
END IF

return(1)
*/
end function

public function integer uf_check_hfin (string as_pr, string as_irreg, datetime adt_dureeforfait, string as_garde, string as_interim, date ad_datep, datetime adt_hdebut, any aa_value, ref string as_message);/////////////////////////////////////////////////////////////////////////////////////////////
// AU 20/10/2014 : vérif. se limite à avoir une heure de fin > heure de début !
// (pas de vérif WE, jours fériés, congés et plage de 18:30 à 7h30)
// Edit FEV 2015 : si on implémente un jour ces vérif, attention à distinguer les règles pour les
//						 prestations régulières et irrégulières.
/////////////////////////////////////////////////////////////////////////////////////////////

// Prestations irrégulières : heure de fin doit être > heure de début.
// Edit FEv 2015 : possibilité d'encoder hdeb et hfin pour des prestations régulières.
// L'heure de fin doit être <= 7h30.
// Cas particulier : on ne sait pas encoder 24:00 pour signifier une fin d'activité à minuit.
// On encode donc 00:00, mais il faut l'interpréter manuellement.
// as_irreg : O si prestation irrégulières, N si prestation normale
// adt_hdebut : heures de début d'activité
// ad_datep : date de la prestation
// return(1) si ok
// return(-1) si erreur
// return(0) : indécision, heure pas dans la plage de validité, l'utilisateur devra confirmer

time		lt_debut, lt_fin, lt_dureeforfait
integer	li_daynr

lt_debut = time(adt_hdebut)
lt_fin = time(datetime(aa_value))
lt_dureeforfait = time(adt_dureeforfait)

// PLANNING, prestation normale : heures de début et de fin d'activité facultatives
// MAIS INTERDITE s'il y a une durée forfaitaire ou si GARDE/INTERIM
// Validité : 07h30 - 18h30
IF as_pr = "P" AND as_irreg = "N" THEN
	IF isNull(lt_debut) AND isNull(lt_fin) THEN
		return(1)
	ELSEIF NOT isNull(lt_dureeforfait) AND NOT isNull(lt_fin) THEN
		as_message = f_translate_getlabel("TEXT_00745", "Prestation régulière avec durée forfaitaire : pas d'encodage des heures de début et de fin d'activité")
		return(-1)
	ELSEIF as_garde = "O" AND NOT isNull(lt_fin) THEN
		as_message = f_translate_getlabel("TEXT_00746", "Permanence : pas d'encodage des heures de début et de fin d'activité")
		return(-1)
	ELSEIF as_interim = "O" AND NOT isNull(lt_fin) THEN
		as_message = f_translate_getlabel("TEXT_00747", "Intérim : pas d'encodage des heures de début et de fin d'activité")
		return(-1)
	ELSEIF NOT isNull(lt_debut) AND isNull(lt_fin) THEN
		as_message = f_translate_getlabel("TEXT_00751", "Vous avez introduit une heure de début. Veuillez introduire une heure de fin ou saisir directement une durée.")
		return(-1)
	ELSEIF NOT isNull(lt_fin) AND (lt_fin < time("7:30") OR lt_fin > time("18:30")) THEN
		as_message = f_translate_getlabel("TEXT_00749", "Les prestations régulières doivent être comprises entre 7h30 et 18h30")
		return(-1)
	END IF
END IF

// REALISE, prestation normale : heures de debut et de fin obligatoires 
// SAUF s'il y a une durée forfaitaire ou si GARDE/INTERIM (elle est dans ce cas interdite)
// Validité : 07h30 - 18h30
IF as_pr = "R" AND as_irreg = "N" THEN
	IF as_garde = "O" THEN
		IF isNull(lt_fin) THEN
			return(1)
		ELSE
			as_message = f_translate_getlabel("TEXT_00746", "Permanence : pas d'encodage des heures de début et de fin d'activité")
			return(-1)
		END IF
	END IF
	IF as_interim = "O" THEN
		IF isNull(lt_fin) THEN
			return(1)
		ELSE
			as_message = f_translate_getlabel("TEXT_00747", "Intérim : pas d'encodage des heures de début et de fin d'activité")
			return(-1)
		END IF
	END IF
	
	IF NOT isNull(lt_dureeforfait) THEN
		IF isNull(lt_fin) THEN
			return(1)
		ELSE
			as_message = f_translate_getlabel("TEXT_00745", "Prestation régulière avec durée forfaitaire : pas d'encodage des heures de début et de fin d'activité")
			return(-1)
		END IF
	ELSE
		IF isNull(lt_fin) THEN
			as_message = f_translate_getlabel("TEXT_00750", "Veuillez indiquer les heures de début et de fin d'activité")
			return(-1)
		ELSEIF lt_fin < time("7:30") OR lt_fin > time("18:30") THEN
			as_message = f_translate_getlabel("TEXT_00749", "Les prestations régulières doivent être comprises entre 7h30 et 18h30")
			return(-1)
		END IF
	END IF
END IF

// PLANNING et REALISE, prestations irrégulières : heures de debut et de fin obligatoires
// MEME s'il y a une durée forfaitaire (elle est alors remplacée par la durée calculée)
IF as_irreg = "O" AND as_garde = "N" AND as_interim = "N" THEN
	IF isNull(lt_fin) THEN
		as_message = f_translate_getlabel("TEXT_00750", "Veuillez indiquer les heures de début et de fin d'activité")
		return(-1)
	END IF
END IF

// heure de fin doit être > heure de début 
IF (hour(lt_fin) <> 0 OR minute(lt_fin) <> 0) AND lt_fin <= lt_debut THEN
	as_message = f_translate_getlabel("TEXT_00752", "L'heure de fin d'activité doit être supérieure à l'heure de début.~n~n" + &
			"Si la prestation commence avant minuit et se termine après, vous devez l'encoder sur 2 jours.~n~n" + &
			"L'heure de fin du 1er jour et l'heure de début du 2ème devra être 00:00")
	return(-1)
END IF

return(1)

/*
// jour de la semaine : dimanche=1, samedi=7
li_daynr = dayNumber(ad_datep)

// Hors WE : vérification plage de validité (18h30 - 7h30)
// si heure de début est avant minuit, heure de fin doit être entre 18h30 et 00h00
// si heure de début est après minuit, heure de fin doit être entre 00h01 et 7h30
IF li_daynr <> 1 AND li_daynr <> 7 THEN
	IF lt_debut >= time("18:30") AND lt_debut <= time("23:59") THEN
		IF NOT (lt_fin = time("00:00") OR (lt_fin >= time("18:30") AND lt_fin <= time("23:59"))) THEN
			as_message = "Si la prestation commence avant minuit et se termine après, vous devez l'encoder sur 2 jours.~n" + &
							 "L'heure de fin du 1er jour et l'heure de début du 2ème devra être 00:00"		
			return(-1)
		END IF
	END IF
	IF lt_debut >= time("00:00") AND lt_debut <= time("07:30") THEN
		IF NOT (lt_fin > time("00:00") AND lt_fin <= time("07:30")) THEN
			as_message = "Une prestation irrégulière doit se situer entre 18h30 et 7h30"
			return(-1)
		END IF
	END IF
END IF

// heure de fin doit être > heure de début 
IF (hour(lt_fin) <> 0 OR minute(lt_fin) <> 0) AND lt_fin <= lt_debut THEN
	as_message = "Prestations irrégulières : l'heure de fin d'activité doit être supérieure à l'heure de début.~n~n" + &
			"Si la prestation commence avant minuit et se termine après, vous devez l'encoder sur 2 jours.~n" + &
			"L'heure de fin du 1er jour et l'heure de début du 2ème devra être 00:00"	
	return(-1)
END IF

return(1)
*/
end function

public function integer uf_check_prest (string as_par, string aa_value, ref string as_message);return(1)
end function

public function integer uf_convert_idprest (integer ai_version, integer ai_idprest);// Lors de l'importation de fichiers XML en provenance de l'application light, on vérifie s'il n'y à pas 
// de conversion de code prestation à effectuer. Cela peut être le cas si on importe un fichier généré 
// par une version plus ancienne de l'application light, où si le dictionnaire des codes prestations
// n'est pas la dernière version.
// ai_version = version de la donnée importée
// ai_idprest : code à vérifier
// return : code à utiliser (peut être identique ou différent de ai_idprest) si OK
// 		   -1 si ancien code pas trouvé dans le nouveau dictionnaire.
integer	li_newid

IF ai_version = 1 THEN
	CHOOSE CASE ai_idprest
		// mars 2015
		CASE 55
			ai_idprest = 77
		CASE 83,84,85,86,87
			ai_idprest = 120
	END CHOOSE
END IF

// NOV2015, nouveau référentiel : versions supérieures à 1 et < 4 
IF ai_version < gi_currentVersion THEN
	// rechercher correspondance entre ancien et nouveau code
	select newid into :li_newid from trfref_v4 where oldid=:ai_idprest using ESQLCA;
	IF f_check_sql(ESQLCA) <> 0 THEN
		return(-1)
	ELSE
		ai_idprest = li_newid
	END IF
END IF

return(ai_idprest)
end function

public function integer uf_check_commentaire (integer ai_km, string as_interim, any aa_value, ref string as_message);// commentaire sur l'activité. Obligatoire s'il y a des km parcourus ou si intérim.
string	ls_data

ls_data = string(aa_value)
IF f_isEmptyString(ls_data) THEN
	IF ai_km > 0 THEN
		as_message = f_translate_getlabel("TEXT_00741", "Veuillez justifier les km parcourus au moyen du commentaire")
		return(-1)
	ELSEIF as_interim = "O" THEN
		as_message = f_translate_getlabel("TEXT_00742", "Veuillez expliquer en commentaire les prestations en situation d'intérim")
		return(-1)
	END IF
END IF
return(1)
end function

public function integer uf_check_lieu (string as_interim, any aa_value, ref string as_message);// Lieu, RDV, commentaire... Obligatoire s'il y a des km parcourus ou si intérim.
// (ce champ concerne uniquement le planifié)
string	ls_data

ls_data = string(aa_value)
IF	as_interim = "O" AND f_isEmptyString(ls_data) THEN
	as_message = f_translate_getlabel("TEXT_00760", "Veuillez expliquer en commentaire les prestations en situation d'intérim")
	return(-1)
END IF

return(1)


end function

public function integer uf_check_nbre (any aa_value, ref string as_message, integer ai_idprest);// Nombre d'items sur lequel porte la prestation. Facultatif.
// PCO 16MARS2016 : facultatif, sauf pour les prestations de type INTERIM où il faut > 0.
string	ls_interim
decimal{2}	ld_nbre

ld_nbre = dec(aa_value)
IF isNull(ld_nbre) THEN ld_nbre = 0

// PCO 31/10/2019 : max 9999,99
IF ld_nbre >= 10000 THEN
	as_message = f_translate_getlabel("TEXT_00831", "Valeur maximum : 9999,99")
	return(-1)
END IF

select interim into :ls_interim from referentiel where idprest=:ai_idprest using ESQLCA;
IF ls_interim = "O" AND ld_nbre <= 0 THEN
	as_message = f_translate_getlabel("TEXT_00810", "Intérim : veuillez introduire un nombre supérieur à 0")
	return(-1)
END IF

return(1)
end function

public function integer uf_check_row (date adt_datep, integer ai_niveau2, ref string as_message);// PCO 13/01/2023 : on ne peut plus utiliser la filière Adm dans la matière Poli à partir des prestations du 16/01/2023
IF adt_datep >= date(2023,01,16) AND ai_niveau2=104 THEN
	as_message = "A partir du 16/01/2023, veuillez utiliser les autres filières que 'Divers et travail administratif' dans la matière 'Police'"
	return(-1)
END IF

return(1)
end function

on br_saisie.create
call super::create
TriggerEvent( this, "constructor" )
end on

on br_saisie.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

