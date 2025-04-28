//objectcomments BR pour la validation des semaines
forward
global type br_semaine from nonvisualobject
end type
end forward

global type br_semaine from nonvisualobject
end type
global br_semaine br_semaine

forward prototypes
public function integer uf_valid_planning (string as_matricule, integer ai_year, integer ai_week)
public function integer uf_valid_semaine (string as_pr, string as_matricule, integer ai_year, integer ai_week)
public function integer uf_valid_realise (string as_matricule, integer ai_year, integer ai_week)
end prototypes

public function integer uf_valid_planning (string as_matricule, integer ai_year, integer ai_week);// validation du planning dont l'identification est passée en argument
// as_matricule : n° de matricule du préposé
// ai_year : année
// ai_week : n° de semaine
// return(1) si OK
// return(-1) en cas d'erreur SQL

return(uf_valid_semaine('P', as_matricule, ai_year, ai_week))
end function

public function integer uf_valid_semaine (string as_pr, string as_matricule, integer ai_year, integer ai_week);// Validation du planning ou du réalisé dont l'identification est passée en argument.
// as_pr : validation d'un planning (P) ou d'un réalisé (R)
// as_matricule : n° de matricule du préposé
// ai_year : année
// ai_week : n° de semaine
// return(1) si OK
// return(-1) en cas d'erreur SQL

integer	li_count

// lecture de la semaine pour voir si elle existe déjà
select count(*) into :li_count from semaine_valid
	where matricule=:as_matricule and annee=:ai_year and semaine=:ai_week using ESQLCA;
IF f_check_sql(ESQLCA) < 0 THEN
	populateError(20000, "")
	gu_message.uf_unexp("Erreur SELECT SEMAINE_VALID")
	return(-1)
END IF

// semaine n'existe pas encore --> la créer
IF li_count = 0 THEN 
	insert into semaine_valid values (:as_matricule,:ai_year,:ai_week,'N','N') using ESQLCA;
	IF f_check_sql(ESQLCA) < 0 THEN
		populateError(20000, "")
		gu_message.uf_unexp("Erreur INSERT SEMAINE_VALID")
		rollback using ESQLCA;
		return(-1)
	ELSE
		commit using ESQLCA;
	END IF
END IF

// validation Planning ou Réalisé selon paramètre
CHOOSE CASE as_pr
	CASE "P"
		update semaine_valid set planning_valid='O' 
			where matricule=:as_matricule and annee=:ai_year and semaine=:ai_week using ESQLCA;
	CASE "R"
		update semaine_valid set realise_valid='O' 
			where matricule=:as_matricule and annee=:ai_year and semaine=:ai_week using ESQLCA;
	CASE ELSE
		populateError(20000, "")
		gu_message.uf_unexp("Erreur de paramètre : " + f_string(as_pr) + " au lieu de P ou R")
		return(-1)
END CHOOSE
	
IF f_check_sql(ESQLCA) < 0 THEN
	populateError(20000, "")
	gu_message.uf_unexp("Erreur UPDATE SEMAINE_VALID")
	rollback using ESQLCA;
	return(-1)
END IF

commit using ESQLCA;
return(1)

end function

public function integer uf_valid_realise (string as_matricule, integer ai_year, integer ai_week);// validation du réalisé dont l'identification est passée en argument
// as_matricule : n° de matricule du préposé
// ai_year : année
// ai_week : n° de semaine
// return(1) si OK
// return(-1) en cas d'erreur SQL

return(uf_valid_semaine('R', as_matricule, ai_year, ai_week))
end function

on br_semaine.create
call super::create
TriggerEvent( this, "constructor" )
end on

on br_semaine.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

