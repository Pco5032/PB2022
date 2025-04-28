//objectcomments Absences, prestations irrégulières, gardes et rappels
forward
global type w_rpt_irr from w_ancestor_rptpreview
end type
end forward

global type w_rpt_irr from w_ancestor_rptpreview
string tag = "TEXT_00803"
string title = "Absences, prestations irrégulières, gardes et rappels"
end type
global w_rpt_irr w_rpt_irr

type variables
string	is_matricule, is_option_paiement
integer	ii_annee, ii_mois, ii_heures
end variables

on w_rpt_irr.create
call super::create
end on

on w_rpt_irr.destroy
call super::destroy
end on

event ue_init;call super::ue_init;str_params	lstr_params

// Critères et nom de modèle. PCO 08/11/2016 : les mêmes que pour les frais de parcours et de séjours
wf_setreportcritere("w_rpt_kmmensuel")
wf_setmodel("KMMENSUEL")

// init. critères par défaut
wf_ResetDefaults()

// critères de sélection par défaut
wf_setdefault("v_realise.annee_cal", "=", year(today()))
wf_setdefault("v_realise.nummois", "=", month(today()))

// pas de modification possible des critères de tri
wf_trienabled(FALSE)

end event

event ue_retrieve;call super::ue_retrieve;long		ll_rows

ll_rows = AncestorReturnValue

IF ll_rows <= 0 THEN 
	gu_message.uf_info(gu_translate.uf_getlabel(is_tag_nodata, "Aucune donnée ne correspond à votre requête"))
ELSE
	// traduction après le retrieve sinon les nested reports ne sont pas disponibles
	this.setredraw(FALSE)
	event ue_translate()
	this.setredraw(TRUE)

	// PCO 07/10/2019 : Marc Pirlot rencontre occasionnellement d'incompréhensibles problèmes avec ce rapport 
	// (mélange entre matricule, nom et prestations). Ajout d'un tri forcé pour tenter d'y remédier.
	dw_1.setSort("v_realise_annee_cal, v_realise_nummois, v_realise_matricule")
	dw_1.sort()
	dw_1.groupCalc()

	// imprimer requête en français
	dw_1.object.t_requete.text = is_selectinfrench

	// nom du service
	dw_1.object.t_service.text = gs_nomservice
END IF

return(ll_rows)


end event

event ue_before_ueopen;call super::ue_before_ueopen;// Report avec nested : reporter traduction après lecture des données (voir ue_retrieve)
wf_deferTranslate(TRUE)
end event

type cb_defaults from w_ancestor_rptpreview`cb_defaults within w_rpt_irr
end type

type st_2 from w_ancestor_rptpreview`st_2 within w_rpt_irr
end type

type st_1 from w_ancestor_rptpreview`st_1 within w_rpt_irr
end type

type dw_papersize from w_ancestor_rptpreview`dw_papersize within w_rpt_irr
end type

type cb_next from w_ancestor_rptpreview`cb_next within w_rpt_irr
end type

type cb_prev from w_ancestor_rptpreview`cb_prev within w_rpt_irr
end type

type dw_1 from w_ancestor_rptpreview`dw_1 within w_rpt_irr
string dataobject = "d_rpt_irr"
end type

type em_zoom from w_ancestor_rptpreview`em_zoom within w_rpt_irr
end type

type st_zoom from w_ancestor_rptpreview`st_zoom within w_rpt_irr
end type

type gb_1 from w_ancestor_rptpreview`gb_1 within w_rpt_irr
end type

type dw_paperorient from w_ancestor_rptpreview`dw_paperorient within w_rpt_irr
end type

