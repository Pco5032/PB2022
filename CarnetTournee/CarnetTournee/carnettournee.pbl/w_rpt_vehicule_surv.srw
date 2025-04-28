//objectcomments Rapport du véhicule de surveillance
forward
global type w_rpt_vehicule_surv from w_ancestor_rptpreview
end type
end forward

global type w_rpt_vehicule_surv from w_ancestor_rptpreview
string tag = "TEXT_00820"
string title = "Rapport du véhicule de surveillance"
end type
global w_rpt_vehicule_surv w_rpt_vehicule_surv

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

on w_rpt_vehicule_surv.create
call super::create
end on

on w_rpt_vehicule_surv.destroy
call super::destroy
end on

event ue_init;call super::ue_init;str_params	lstr_params

// attribuer un nom de modèle
wf_setmodel("VEHICULESURV")

// init. critères par défaut
wf_ResetDefaults()

wf_setdefault("v_realise.annee", "=", year(today()))
wf_setdefault("v_realise.semaine", "=")

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// ATTENTION : les codes 7 (matière "Police et contrôles") et 104 (filière "Divers et travail administratif") //
// sont hardcodés dans la source du datawindow !!                                                             //
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
end event

event ue_retrieve;call super::ue_retrieve;long	ll_rows

ll_rows = AncestorReturnValue

IF ll_rows <= 0 THEN 
	gu_message.uf_info(gu_translate.uf_getlabel(is_tag_nodata, "Aucune donnée ne correspond à votre requête"))
	return(ll_rows)
END IF

// imprimer requête en français
dw_1.object.t_requete.text = is_selectinfrench

// nom du service
dw_1.object.t_service.text = gs_nomservice

return(ll_rows)

end event

type cb_defaults from w_ancestor_rptpreview`cb_defaults within w_rpt_vehicule_surv
end type

type st_2 from w_ancestor_rptpreview`st_2 within w_rpt_vehicule_surv
end type

type st_1 from w_ancestor_rptpreview`st_1 within w_rpt_vehicule_surv
end type

type dw_papersize from w_ancestor_rptpreview`dw_papersize within w_rpt_vehicule_surv
end type

type cb_next from w_ancestor_rptpreview`cb_next within w_rpt_vehicule_surv
end type

type cb_prev from w_ancestor_rptpreview`cb_prev within w_rpt_vehicule_surv
end type

type dw_1 from w_ancestor_rptpreview`dw_1 within w_rpt_vehicule_surv
string dataobject = "d_rpt_vehicule_surv"
end type

type em_zoom from w_ancestor_rptpreview`em_zoom within w_rpt_vehicule_surv
end type

type st_zoom from w_ancestor_rptpreview`st_zoom within w_rpt_vehicule_surv
end type

type gb_1 from w_ancestor_rptpreview`gb_1 within w_rpt_vehicule_surv
end type

type dw_paperorient from w_ancestor_rptpreview`dw_paperorient within w_rpt_vehicule_surv
end type

