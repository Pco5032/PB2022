//objectcomments UO pour les déclarations de créances
forward
global type uo_creance from nonvisualobject
end type
end forward

global type uo_creance from nonvisualobject
end type
global uo_creance uo_creance

type variables
uo_wait	iu_wait
end variables

forward prototypes
public function integer uf_get_cpers (string as_codeservice, ref string as_matricule, ref string as_nom, ref string as_tel)
public function integer uf_get_agent (string as_matricule, ref string as_nom, ref string as_codeservice, ref string as_tel, ref string as_grade, ref string as_rang, ref string as_resadmin, ref string as_reseffect)
public function integer uf_get_services (string as_codeservice, ref string as_triage, ref string as_cantonnement, ref string as_direction)
public function integer uf_get_info (string as_typedoc, uo_dw adw_data, decimal ad_sequence)
public function integer uf_get_interim (integer ai_annee, integer ai_nummois, ref date adt_dateint, ref decimal ad_tauxtri, ref decimal ad_tauxbri, ref decimal ad_tauxbric1)
public function integer uf_publipostage (string as_typedoc, uo_dw adw_data, decimal ad_sequence)
public function integer uf_get_tauxft (integer ai_annee, integer ai_nummois, ref date adt_dateft, ref decimal ad_tauxft)
public function decimal uf_get_pointsft (string as_codeservice)
public function integer uf_get_chef (ref string as_codeservice, ref string as_nomcc, ref string as_gradecc, ref string as_nomdir, ref string as_gradedir)
end prototypes

public function integer uf_get_cpers (string as_codeservice, ref string as_matricule, ref string as_nom, ref string as_tel);// Retrouve le correspondant du service passé en argument.
//    On essaye de trouver un CP dans le CAN.
//    Si on en trouve plusieurs, on prend le 1er par ordre alphabétique.
// EDIT PCO 04/02/2019 : colonne CP_DOCUMENT vaut O pour indiquer le responsable à reprendre dans les documents
// Si on n'en trouve pas dans le CAN, on cherche dans la DIR.
//
// return(1) si OK
// return(0) si pas trouvé
// return(-1) : erreur de paramétrage
string	ls_codeservice

// codeservice = un cantonnement
ls_codeservice = left(as_codeservice, 6)

select matricule, nom, tel into :as_matricule, :as_nom, :as_tel
from
 (select r.matricule, a.nom, nvl(gsm,nvl(tel1,tel2)) tel
  from responsable r, agent a
  where r.codeservice=:ls_codeservice and r.cp_document='O' and a.matricule=r.matricule
  order by a.nom)
where rownum=1 using ESQLCA;

// 1 trouvé dans le cantonnement : on le sélectionne
IF ESQLCA.sqlnrows = 1 THEN
	return(1)
ELSEIF ESQLCA.sqlnrows > 1 THEN
	// plusieurs trouvés : erreur de paramétrage dans RESPONSABLE
	gu_message.uf_error("Erreur : plusieurs CP sélectionnés pour apparaître sur le document !")
	return(-1)
END IF

// Pas trouvé : chercher dans la Direction
// codeservice = une Direction
ls_codeservice = left(as_codeservice, 3)

select matricule, nom, tel into :as_matricule, :as_nom, :as_tel
from
 (select r.matricule, a.nom, nvl(gsm,nvl(tel1,tel2)) tel
  from responsable r, agent a
  where r.codeservice=:ls_codeservice and r.cp_document='O' and a.matricule=r.matricule
  order by a.nom)
where rownum=1 using ESQLCA;

// 1 trouvé dans la Direction : on le sélectionne
IF ESQLCA.sqlnrows = 1 THEN
	return(1)
ELSEIF ESQLCA.sqlnrows = 0 THEN
	// pas trouvé dans la Direction :
	return(0)
ELSE
	// plusieurs trouvés : erreur de paramétrage dans RESPONSABLE
	gu_message.uf_error("Erreur : plusieurs CP sélectionnés pour apparaître sur le document !")
	return(-1)
END IF
end function

public function integer uf_get_agent (string as_matricule, ref string as_nom, ref string as_codeservice, ref string as_tel, ref string as_grade, ref string as_rang, ref string as_resadmin, ref string as_reseffect);// Lecture des infos sur l'agent
// return(1)
		
SELECT a.nom, a.codeservice, nvl(gsm,nvl(tel1,tel2)) tel,
       g.trad grade, r.trad rang, act.comadmin, act.comeffect
INTO :as_nom, :as_codeservice, :as_tel, :as_grade, :as_rang, :as_resadmin, :as_reseffect
FROM agent a, agent_ct act, v_grade g, v_rang r
WHERE a.matricule=:as_matricule and a.matricule=act.matricule(+) 
      and g.code(+)=act.grade and r.code(+)=act.rang 
USING ESQLCA;

return(1)
end function

public function integer uf_get_services (string as_codeservice, ref string as_triage, ref string as_cantonnement, ref string as_direction);// Lecture des infos sur les services
// return(1)

SELECT decode(s.type, 'T', s.abbrvservice) triage, decode(s.ce, 'E', c.cantonnement) cantonnement, 
		 decode(s.ce, 'E', d.direction) direction 
INTO :as_triage, :as_cantonnement, :as_direction
FROM service s, cantonnement c, direction d
WHERE s.codeservice=:as_codeservice and c.can(+)=s.can and d.d(+)=s.d 
USING ESQLCA;

return(1)

end function

public function integer uf_get_info (string as_typedoc, uo_dw adw_data, decimal ad_sequence);// lire et garnir les infos pour imprimer le recto des demandes de créances
// - infos sur l'agent
// - infos sur la période
// - infos sur le CP
// - infos sur les services : DIR/CAN/TRI
// arguments :
// - as_typedoc : type de document (FT - Frais de tournée, INT - intérims, FP - frais de parcours/séjours)
// - adw_data : 
//		. pour tous les types de document, le DW doit contenir la liste des agents et la période 
//	  	  sous la forme des colonnes matricule, annee_cal, nummois, mois.
//		. selon le type de document, le DW doit aussi contenir les infos spécifiques :
//		  - pour FT : nombre de chèques-repas : adw_data.object.dw_cr[ll_row].object.nbcr[1]
//		  - pour FP : nombre de km et de séjours : adw_data.object.dw_km[ll_row].object.tot_kms[1])
//																 adw_data.object.dw_sejour[ll_row].object.tot_sejours[1]
// return(1) : OK
// return(-1) : erreur
long		ll_row
integer	li_annee, li_nummois, li_nbcr, li_kms, li_sejours
integer	li_codeprest_interim_triage, li_codeprest_interim_briC1, li_codeprest_interim_briAvC1
string	ls_sql, ls_mois, ls_codeservice, ls_nomAG, ls_matriculeAG, ls_matriculeCP, ls_nomCP, ls_telCP, ls_CP, &
			ls_telAG, ls_grade, ls_rang, ls_resadmin, ls_reseffect, ls_triage, ls_cantonnement, ls_direction, &
			ls_nomcc, ls_gradecc, ls_nomdir, ls_gradedir
date		ldt_dateft, ldt_dateint
decimal{2}	ld_tauxtri, ld_tauxbri, ld_tauxbric1, &
				ld_nbtri, ld_nbBriC1, ld_nbBri, &
				ld_totaltri, ld_totalBri, ld_totalBriC1, ld_totalint
decimal{4}	ld_pointsft, ld_tauxft, ld_totalft, ld_pointsft_justif

// string pour formatage des données pour le publipostage
string	ls_annee, ls_kms, ls_sejours
string	ls_pointsft, ls_dateft, ls_tauxft, ls_nbcr, ls_totalft, ls_pointsft_justif
string	ls_nbtri, ls_nbBri, ls_nbBriC1, ls_totaltri, ls_totalBri, ls_totalBriC1, ls_totalint, &
			ls_tauxtri, ls_tauxbri, ls_tauxbric1, ls_dateint

CHOOSE CASE as_typedoc
	CASE "INT"
		// code prestation pour les intérims de triage, brigade C1 et brigade avant C1
		li_codeprest_interim_triage = profileInt(gs_inifile, "creances", "codeprest_interim_triage", 290)
		li_codeprest_interim_briC1 = profileInt(gs_inifile, "creances", "codeprest_interim_brigade_C1", 0)
		li_codeprest_interim_briAvC1 = profileInt(gs_inifile, "creances", "codeprest_interim_brigade_avantC1", 0)
END CHOOSE

// parcourir les agents/année/mois à traiter
FOR ll_row = 1 TO adw_data.rowCount()
	// annuler toutes les infos entre chaque agent
	setnull(ls_nomAG)
	setnull(ls_codeservice)
	setnull(ls_telAG)
	setnull(ls_grade)
	setnull(ls_rang)
	setnull(ls_resadmin)
	setnull(ls_reseffect)
	setnull(ls_matriculeCP)
	setnull(ls_nomCP)
	setnull(ls_telCP)
	setnull(ls_triage)
	setnull(ls_cantonnement)
	setnull(ls_direction)
	setnull(ld_pointsft)
	setnull(ldt_dateft)
	setnull(ld_tauxft)
	setnull(ld_pointsft_justif)
	setnull(ld_totalft)
	setnull(li_nbcr)
	setnull(ldt_dateint)
	setnull(ld_tauxtri)
	setnull(ld_tauxbri)
	setnull(ld_tauxbric1)
	setnull(ld_totaltri)
	setnull(ld_totalint)
	setnull(ld_nbtri)
	setnull(li_kms)
	setnull(li_sejours)
	
	// matricule de l'agent
	ls_matriculeAG = adw_data.object.matricule[ll_row]
	// infos sur l'agent
	uf_get_agent(ls_matriculeAG, ls_nomAG, ls_codeservice, ls_telAG, ls_grade, ls_rang, ls_resadmin, ls_reseffect)
	// indemnités pour frais de tournée : uniquement pour les titulaires d'un triage
	IF as_typedoc = "FT" AND len(ls_codeservice) < 9 THEN
		CONTINUE
	END IF
	// infos sur la période
	li_annee = adw_data.object.annee_cal[ll_row]
	li_nummois = adw_data.object.nummois[ll_row]
	ls_mois = adw_data.object.mois[ll_row]
	// infos sur le CP
	uf_get_cpers(ls_codeservice, ls_matriculeCP, ls_nomCP, ls_telCP)
	// infos sur les services
	uf_get_services(ls_codeservice, ls_triage, ls_cantonnement, ls_direction)
	// infos sur les chefs de cantonnement et Directeur de l'agent
	uf_get_chef(ls_codeservice, ls_nomcc, ls_gradecc, ls_nomdir, ls_gradedir)
	
	// lire les infos relatives au document demandé
	CHOOSE CASE as_typedoc
		// frais de tournée
		CASE "FT"
			uf_get_tauxft(li_annee, li_nummois, ldt_dateft, ld_tauxft)
			ld_pointsft = uf_get_pointsft(ls_codeservice)
			// nbre de chèques-repas + calcul de ce qui en dépend
			li_nbcr = integer(adw_data.object.cr[ll_row])
			IF isNull(li_nbcr) OR li_nbcr = 0 THEN
				CONTINUE
			END IF
			ld_pointsft_justif = ld_pointsft / 220 * li_nbcr
			ld_totalft = ld_pointsft_justif * ld_tauxft
			
			// formatage des champs pour le publipostage
			ls_pointsft = string(ld_pointsft, "###0.0000")
			ls_dateft = string(ldt_dateft, "dd/mm/yyyy")
			ls_tauxft = string(ld_tauxft, "#0.0000")
			ls_nbcr = string(li_nbcr)
			ls_totalft = string(ld_totalft, "###0.0000")
			ls_pointsft_justif = string(ld_pointsft_justif, "###0.0000")
			
		// intérims
		CASE "INT"
			uf_get_interim(li_annee, li_nummois, ldt_dateint, ld_tauxtri, ld_tauxbri, ld_tauxbric1)
			// nbre d'intérims de triages, brigades C1, brigades avant C1 + calcul de ce qui en dépend
			SELECT sum(decode(idprest, :li_codeprest_interim_triage, nbre, 0)),
            	 sum(decode(idprest, :li_codeprest_interim_briC1, nbre, 0)),
            	 sum(decode(idprest, :li_codeprest_interim_briAvC1, nbre, 0))
				INTO :ld_nbtri, :ld_nbBriC1, :ld_nbBri
				FROM v_realise
				WHERE matricule=:ls_matriculeAG and annee_cal=:li_annee and nummois=:li_nummois and interim='O' 
				USING ESQLCA;
						
			// Situation transitoire suite ajout code "intérim brigade avant C1" dans le référentiel : 
			// tant que les codes intérim brigade C1 et avant C1 ne sont pas paramétrés dans le .ini,
			// on ne tient pas compte des intérims brigade.
			IF li_codeprest_interim_briC1 = 0 OR li_codeprest_interim_briAvC1 = 0 THEN
				ld_nbBriC1 = 0
				ld_nbBri = 0
			END IF
			
			// calcul des totaux par type d'intérim et total général
			// NB : calcul du total général poste par poste pour éviter résultat NULL si un des postes est NULL
			ld_totalint = 0
			IF ld_nbtri > 0 THEN
				ld_totaltri = ld_nbtri * ld_tauxtri
				ld_totalint = ld_totalint + ld_totaltri
			END IF
			
			IF ld_nbBriC1 > 0 THEN
				ld_totalBriC1 = ld_nbBriC1 * ld_tauxBriC1
				ld_totalint = ld_totalint + ld_totalBriC1
			END IF
			
			IF ld_nbBri > 0 THEN
				ld_totalBri = ld_nbBri * ld_tauxBri
				ld_totalint = ld_totalint + ld_totalBri
			END IF
			
			// formatage des champs pour le publipostage
			ls_dateint = string(ldt_dateint, "dd/mm/yyyy")
			IF ld_tauxtri = 0 THEN setnull(ls_tauxtri) ELSE ls_tauxtri = string(ld_tauxtri, "##0.00")
			IF ld_tauxbri = 0 THEN setnull(ls_tauxbri) ELSE ls_tauxbri = string(ld_tauxbri, "##0.00")
			IF ld_tauxbric1 = 0 THEN setnull(ls_tauxbric1) ELSE ls_tauxbric1 = string(ld_tauxbric1, "##0.00")
			
			IF ld_nbtri = 0 THEN 
				setnull(ls_nbtri)
				setnull(ls_totaltri)
			ELSE 
				ls_nbtri = string(ld_nbtri, "##0.00")
				ls_totaltri = string(ld_totaltri, "###0.00")
			END IF
	
			IF ld_nbBri = 0 THEN 
				setnull(ls_nbBri)
				setnull(ls_totalBri)
			ELSE 
				ls_nbBri = string(ld_nbBri, "##0.00")
				ls_totalBri = string(ld_totalBri, "###0.00")
			END IF
	
			IF ld_nbBriC1 = 0 THEN 
				setnull(ls_nbBriC1)
				setnull(ls_totalBriC1)
			ELSE 
				ls_nbBriC1 = string(ld_nbBriC1, "##0.00")
				ls_totalBriC1 = string(ld_totalBriC1, "###0.00")
			END IF
	
			IF ld_totalint = 0 THEN setnull(ls_totalint)	ELSE ls_totalint = string(ld_totalint, "###0.00")
			
		// frais de parcours et de séjours
		CASE "FP"
			// nbre de kms
			li_kms = integer(adw_data.object.dw_km[ll_row].object.tot_kms[1])
			// nbre de séjours
			li_sejours = integer(adw_data.object.dw_sejour[ll_row].object.tot_sejours[1])
			// formatage des champs pour le publipostage
			IF li_kms = 0 THEN setnull(ls_kms) ELSE ls_kms = string(li_kms)
			IF li_sejours = 0 THEN setnull(ls_sejours) ELSE ls_sejours = string(li_sejours)
			
	END CHOOSE
	
	ls_CP = ls_nomCP + " - " + f_string(ls_telCP)
	
	// formatage des champs pour le publipostage
	ls_annee = string(li_annee)
	
	// garnir table temporaire qui servira au publipostage
	insert into T_CREANCE 
		columns(SESSIONID, SEQ, MATRICULE, NOMPRENOM, GRADE, RANG, TEL, RESADMIN, RESEFFECT, DIRECTION, 
				  CANTONNEMENT, TRIAGE, ANNEE, MOIS, CPERS, POINTS_TRIAGE, NBJOURS, POINTS_JUSTIF, TX_POINT, 
				  DT_TX_POINT, TOTAL_FT, NBINTERIMTRI, NBINTERIMBRI, NBINTERIMC1, TX_INTERIMTRI, TX_INTERIMBRI, 
				  TX_INTERIMC1, DT_TX_INTERIM, TOTAL_INTERIMTRI, TOTAL_INTERIMBRI, TOTAL_INTERIMC1, TOTAL_INTERIM,
				  KMS, SEJOURS, NOMCC, GRADECC, NOMDIR, GRADEDIR)
		values(:gd_session, :ad_sequence, :ls_matriculeAG, :ls_nomAG, :ls_grade, :ls_rang, :ls_telAG, 
				 :ls_resadmin, :ls_reseffect, :ls_direction, :ls_cantonnement, :ls_triage, :ls_annee, :ls_mois, 
				 :ls_CP, :ls_pointsft, :ls_nbcr, :ls_pointsft_justif, :ls_tauxft, :ls_dateft, :ls_totalft, 
				 :ls_nbtri, :ls_nbBri, :ls_nbBriC1, :ls_tauxtri, :ls_tauxbri, :ls_tauxbric1, :ls_dateint, 
				 :ls_totaltri, :ls_totalBri, :ls_totalBriC1, :ls_totalint, :ls_kms, :ls_sejours,
				 :ls_nomcc, :ls_gradecc, :ls_nomdir, :ls_gradedir)
		using ESQLCA;
		IF f_check_sql(ESQLCA) <> 0 THEN
			populateError(20000, "")
			gu_message.uf_unexp("Erreur insert into T_CREANCE")
			rollback using ESQLCA;
			return(-1)
		END IF
NEXT
commit using ESQLCA;

return(1)
end function

public function integer uf_get_interim (integer ai_annee, integer ai_nummois, ref date adt_dateint, ref decimal ad_tauxtri, ref decimal ad_tauxbri, ref decimal ad_tauxbric1);// Lecture des infos nécessaires pour les allocations pour intérims
// return(1) si OK
// return(-1) si erreur

select tint.dateappl, tint.taux_tri, tint.taux_bri, tint.taux_bri_c1
	into :adt_dateint, :ad_tauxtri, :ad_tauxbri, :ad_tauxbric1
from taux_interim tint where tint.dateappl = 
	(select max(dateappl) from taux_interim where dateappl <= to_date('01/'||:ai_nummois||'/'||:ai_annee,'dd/mm/yyyy'))
USING ESQLCA;

IF f_check_sql(ESQLCA) <> 0 THEN
	gu_message.uf_error("Erreur SELECT TAUX_INTERIM pour " + string(ai_annee) + "/" + string(ai_nummois))
	return(-1)
END IF

return(1)

end function

public function integer uf_publipostage (string as_typedoc, uo_dw adw_data, decimal ad_sequence);// lancer fusion/publipostage pour impression des demandes de créance
// arguments :
// - as_typedoc : type de document (FT - Frais de tournée, INT - intérims, FP - frais de parcours/séjours)
// - adw_data : DW contenant au minium la liste des agents et la période
// - ad_sequence : id_sequence de la fenêtre appelante
// return(1) : OK
// return(-1) : erreur
string	ls_sql, ls_docfile
uo_publipostage	lu_publipostage

// lire nom du document de fusion/publipostage en fonction du type demandé
CHOOSE CASE as_typedoc
	// frais de tournée
	CASE "FT"
		ls_docFile = gs_cenpath + "\doc\" + profileString(gs_inifile, "creances", "doc_tournee", "")
	// intérim
	CASE "INT"
		ls_docFile = gs_cenpath + "\doc\" + profileString(gs_inifile, "creances", "doc_interim", "")
	// frais de parcours et de séjours
	CASE "FP"
		ls_docFile = gs_cenpath + "\doc\" + profileString(gs_inifile, "creances", "doc_parcours", "")
	CASE ELSE
		gu_message.uf_error("Le type de document demandé (" + f_string(as_typedoc) + &
							  ") n'est pas reconnu par l'application.")
		return(-1)
END CHOOSE

IF f_isEmptyString(ls_docFile) THEN
	gu_message.uf_error("Le document de base pour le publipostage " + as_typedoc + &
							  " n'est pas déterminé dans les paramètres.")
	return(-1)
END IF

IF NOT fileExists(ls_docfile) THEN
	gu_message.uf_error("Le document de base pour le publipostage " + as_typedoc + &
							  " n'existe pas : " + ls_docFile)
	return(-1)
END IF

iu_wait.uf_addinfo("Lecture des infos")

// lire les infos nécessaires et garnir T_CREANCE
IF uf_get_info(as_typedoc, adw_data, ad_sequence) = -1 THEN
	return(-1)
END IF

iu_wait.uf_addinfo("fusion/publipostage")

// publipostage
ls_sql = "select * from t_creance where sessionid=" + string(gd_session) + " and seq=" + string(ad_sequence)

lu_publipostage = CREATE uo_publipostage
// f_fusion_word(ls_docFile, ls_sql, "", "F", "L", true)
lu_publipostage.uf_publipostage(ls_docFile, ls_sql, "P", "L", true, "", "", 0)
DESTROY lu_publipostage

// suppression données temporaires
delete T_CREANCE where sessionid=:gd_session and seq=:ad_sequence using ESQLCA;
commit using ESQLCA;

iu_wait.uf_closeWindow()

return(1)
end function

public function integer uf_get_tauxft (integer ai_annee, integer ai_nummois, ref date adt_dateft, ref decimal ad_tauxft);// Lecture du taux du point pour les frais de tournée
// return(1) si OK
// return(-1) si erreur TAUX_FT

select tft.dateappl, tft.taux	into :adt_dateft, :ad_tauxft
from taux_ft tft where tft.dateappl = 
	(select max(dateappl) from taux_ft where dateappl <= to_date('01/'||:ai_nummois||'/'||:ai_annee,'dd/mm/yyyy'))
USING ESQLCA;

IF f_check_sql(ESQLCA) <> 0 THEN
	gu_message.uf_error("Erreur SELECT TAUX_FT pour " + string(ai_annee) + "/" + string(ai_nummois))
	return(-1)
END IF

return(1)

end function

public function decimal uf_get_pointsft (string as_codeservice);// Lecture des points annuels attribué au triage, nécessaires pour les indemnités de frais de tournée
// return : nombre de points
decimal{4}	ld_pointsft

select tct.points	into :ld_pointsft	from triage_ct tct
where tct.codeservice=:as_codeservice 
USING ESQLCA;

return(ld_pointsft)

end function

public function integer uf_get_chef (ref string as_codeservice, ref string as_nomcc, ref string as_gradecc, ref string as_nomdir, ref string as_gradedir);// Lecture du nom et grade du chef de cantonnement et du Directeur du service as_codeservice
// return(1)
integer	li_can, li_dir

li_can = integer(mid(as_codeservice, 4, 3))

IF li_can > 0 THEN
	SELECT ingenieur, grade, d INTO :as_nomcc, :as_gradecc, :li_dir 
	FROM cantonnement
	WHERE can=:li_can
	USING ESQLCA;	
	
	IF li_dir > 0 THEN
		SELECT directeur, grade INTO :as_nomdir, :as_gradedir 
		FROM direction
		WHERE d=:li_dir
		USING ESQLCA;	
	END IF
END IF

return(1)
end function

on uo_creance.create
call super::create
TriggerEvent( this, "constructor" )
end on

on uo_creance.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

event constructor;iu_Wait = create uo_Wait
end event

event destructor;destroy iu_Wait
end event

