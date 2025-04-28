//objectcomments Synthèse des heures réalisées par quadrimestre
forward
global type w_rpt_quadri from w_ancestor_rptpreview
end type
end forward

global type w_rpt_quadri from w_ancestor_rptpreview
string tag = "TEXT_00709"
string title = "Synthèse des prestations par quadrimestre"
end type
global w_rpt_quadri w_rpt_quadri

type variables
string	is_matricule, is_option_paiement
integer	ii_annee, ii_mois, ii_heures
end variables

forward prototypes
public function integer wf_ttquadri_datemax (ref string as_quadri_heures[3], date a_datemax)
public function integer wf_ttquadri (ref string as_quadri_heures[3], ref string as_mois_heures[12])
end prototypes

public function integer wf_ttquadri_datemax (ref string as_quadri_heures[3], date a_datemax);// calculer le temps de prestation théorique par quadrimestre, en s'arrêtant à la date de prestation passée en argument
// return(1) si OK et résultats passés dans l'argument as_quadri_heures[3]
// return(-1) si erreur
integer		li_i, li_annee, li_mois, li_nbjours, li_quadri_jours[3]
long			ll_ttjour, ll_quadri_min

// 1. Extraire l'année sélectionnée de la variable is_where (ex. de contenu : S.ANNEE_CAL = '2015')
li_annee = integer(mid(trim(is_where), 16, 4))
IF isNull(li_annee) OR li_annee = 0 THEN
	return(-1)
END IF

// 2. lire le temps de travail journalier et le convertir en minutes
select datetimetominutes(ttjour) into :ll_ttjour from params using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	return(-1)
END IF

// 3. boucler jusqu'au mois en cours et pour ce dernier se limiter à la date max passée en argument,
//    et cumuler les jours par quadrimestre
FOR li_mois = 1 TO month(a_datemax)
	IF li_mois = month(a_datemax) THEN
		select workingDays(:li_annee, :li_mois, :a_datemax) into :li_nbjours from dual using ESQLCA;
	ELSE
		select workingDays(:li_annee, :li_mois, '') into :li_nbjours from dual using ESQLCA;
	END IF
	IF f_check_sql(ESQLCA) <> 0 THEN
		return(-1)
	END IF
	CHOOSE CASE li_mois
		CASE 1 TO 4
			li_quadri_jours[1] = li_quadri_jours[1] + li_nbjours
		CASE 5 TO 8
			li_quadri_jours[2] = li_quadri_jours[2] + li_nbjours
		CASE 9 TO 12
			li_quadri_jours[3] = li_quadri_jours[3] + li_nbjours
	END CHOOSE
NEXT

// 4. calculer le nombre de minutes par quadrimestre et convertir en heures
FOR li_i = 1 TO 3
	ll_quadri_min = li_quadri_jours[li_i] * ll_ttjour
	select minutestohhmm(:ll_quadri_min) into :as_quadri_heures[li_i] from dual using ESQLCA;
	IF f_check_sql(ESQLCA) <> 0 THEN
		return(-1)
	END IF
NEXT

return(1)
end function

public function integer wf_ttquadri (ref string as_quadri_heures[3], ref string as_mois_heures[12]);// calculer le temps de prestation théorique par quadrimestre
// return(1) si OK et résultats passés dans l'argument as_quadri_heures[3]
// return(-1) si erreur
integer		li_i, li_annee, li_mois, li_nbjours, li_mois_jours[12], li_quadri_jours[3]
long			ll_ttjour, ll_min

// 1. Extraire l'année sélectionnée de la variable is_where (ex. de contenu : S.ANNEE_CAL = '2015')
li_annee = integer(mid(trim(is_where), 16, 4))
IF isNull(li_annee) OR li_annee = 0 THEN
	return(-1)
END IF

// 2. lire le temps de travail journalier et le convertir en minutes
select datetimetominutes(ttjour) into :ll_ttjour from params using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	return(-1)
END IF

// 3. boucler sur les 12 mois et cumuler les jours par mois et quadrimestre
FOR li_mois = 1 TO 12
	select workingDays(:li_annee, :li_mois, '') into :li_nbjours from dual using ESQLCA;
	IF f_check_sql(ESQLCA) <> 0 THEN
		return(-1)
	END IF
	// nombre de jours par mois
	li_mois_jours[li_mois] = li_nbjours
	// nombre de jours par quadri
	CHOOSE CASE li_mois
		CASE 1 TO 4
			li_quadri_jours[1] = li_quadri_jours[1] + li_nbjours
		CASE 5 TO 8
			li_quadri_jours[2] = li_quadri_jours[2] + li_nbjours
		CASE 9 TO 12
			li_quadri_jours[3] = li_quadri_jours[3] + li_nbjours
	END CHOOSE
NEXT

// 4. calculer le nombre de minutes par quadrimestre et convertir en heures
FOR li_i = 1 TO 3
	ll_min = li_quadri_jours[li_i] * ll_ttjour
	select minutestohhmm(:ll_min) into :as_quadri_heures[li_i] from dual using ESQLCA;
	IF f_check_sql(ESQLCA) <> 0 THEN
		return(-1)
	END IF
NEXT

// 5. calculer le nombre de minutes par mois et convertir en heures
FOR li_i = 1 TO 12
	ll_min = li_mois_jours[li_i] * ll_ttjour
	select minutestohhmm(:ll_min) into :as_mois_heures[li_i] from dual using ESQLCA;
	IF f_check_sql(ESQLCA) <> 0 THEN
		return(-1)
	END IF
NEXT

return(1)
end function

on w_rpt_quadri.create
call super::create
end on

on w_rpt_quadri.destroy
call super::destroy
end on

event ue_init;call super::ue_init;str_params	lstr_params

// attribuer un nom de modèle
wf_setmodel("QUADRI")

// init. critères par défaut
wf_ResetDefaults()

// critère par défaut obligatoire : année des prestations. IL ne peut figurer qu'une seule fois !
wf_setdefault("s.annee_cal", "=", year(today()), TRUE)

wf_setinsertionpoint("1=1")



end event

event ue_retrieve;call super::ue_retrieve;long		ll_rows, ll_i
string	ls_quadri_heures[3], ls_quadri_heures_datemax[3], ls_sql_datemax, &
			ls_mois_heures[12]
date		ldt_datemax

ll_rows = AncestorReturnValue

IF ll_rows <= 0 THEN 
	gu_message.uf_info(gu_translate.uf_getlabel(is_tag_nodata, "Aucune donnée ne correspond à votre requête"))
	return(ll_rows)
END IF

// I. calculer le temps de prestation théorique par quadrimestre et l'indiquer dans le rapport
IF wf_ttquadri(ls_quadri_heures, ls_mois_heures) = 1 THEN
	dw_1.object.t_quadri1.text = ls_quadri_heures[1]
	dw_1.object.t_quadri2.text = ls_quadri_heures[2]
	dw_1.object.t_quadri3.text = ls_quadri_heures[3]
	FOR ll_i = 1 TO 12
		dw_1.modify("t_mois" + string(ll_i) + ".text = '" + ls_mois_heures[ll_i] + "'")
	NEXT
END IF

// II. PCO 01MAR2016 : calculer le temps de prestation théorique par quadrimestre jusqu'à la date de prestation 
//     la plus récente, plafonnée à la date du jour (pour éviter de prendre en compte des congés déjà encodés + tard)
// a. Attention : le sql est adapté pour pouvoir répondre aux mêmes critères de sélection que le rapport lui-même.
ls_sql_datemax = "select least(max(datep), sysdate) c_datemax from &
	(select r.annee_cal, r.matricule, r.datep, a.codeservice from v_realise r,  agent a &
 	 where a.matricule=r.matricule and r.irreg='N' and r.cumul='O') s &
	 where 1=1"
ls_sql_datemax = f_modifysql(ls_sql_datemax, is_where, "", "1=1")

// b. lire la date de prestation la plus élevée
DECLARE l_cursor DYNAMIC CURSOR FOR SQLSA;
PREPARE SQLSA FROM :ls_sql_datemax USING ESQLCA;
OPEN DYNAMIC l_cursor;
FETCH l_cursor INTO :ldt_datemax;
CLOSE l_cursor;

// c. calculer le temps de prestation théorique par quadri jusqu'à la date trouvée
IF NOT IsNull(ldt_datemax) THEN
	dw_1.object.t_titre_datemax.text = gu_translate.uf_getlabel("TEXT_00802", "Idem mais cumul arrêté au") + &
												  " " + string(ldt_datemax, "dd/mm/yyyy") + " : "
	IF wf_ttquadri_datemax(ls_quadri_heures_datemax, ldt_datemax) = 1 THEN
		dw_1.object.t_quadri1_datemax.text = ls_quadri_heures_datemax[1]
		dw_1.object.t_quadri2_datemax.text = ls_quadri_heures_datemax[2]
		dw_1.object.t_quadri3_datemax.text = ls_quadri_heures_datemax[3]
	END IF
END IF

// III. imprimer requête en français
dw_1.object.t_requete.text = is_selectinfrench

// IV. nom du service
dw_1.object.t_service.text = gs_nomservice

return(ll_rows)
end event

type cb_defaults from w_ancestor_rptpreview`cb_defaults within w_rpt_quadri
end type

type st_2 from w_ancestor_rptpreview`st_2 within w_rpt_quadri
end type

type st_1 from w_ancestor_rptpreview`st_1 within w_rpt_quadri
end type

type dw_papersize from w_ancestor_rptpreview`dw_papersize within w_rpt_quadri
end type

type cb_next from w_ancestor_rptpreview`cb_next within w_rpt_quadri
end type

type cb_prev from w_ancestor_rptpreview`cb_prev within w_rpt_quadri
end type

type dw_1 from w_ancestor_rptpreview`dw_1 within w_rpt_quadri
string dataobject = "d_rpt_quadri"
end type

type em_zoom from w_ancestor_rptpreview`em_zoom within w_rpt_quadri
end type

type st_zoom from w_ancestor_rptpreview`st_zoom within w_rpt_quadri
end type

type gb_1 from w_ancestor_rptpreview`gb_1 within w_rpt_quadri
end type

type dw_paperorient from w_ancestor_rptpreview`dw_paperorient within w_rpt_quadri
end type

