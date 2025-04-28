//objectcomments Synthèse annuelle des heures réalisées, mois par mois
forward
global type w_rpt_annuel from w_ancestor_rptpreview
end type
end forward

global type w_rpt_annuel from w_ancestor_rptpreview
string tag = "TEXT_00650"
string title = "Synthèse annuelle des prestations"
end type
global w_rpt_annuel w_rpt_annuel

type variables
string	is_matricule, is_option_paiement
integer	ii_annee, ii_mois, ii_heures
end variables

on w_rpt_annuel.create
call super::create
end on

on w_rpt_annuel.destroy
call super::destroy
end on

event ue_init;call super::ue_init;str_params	lstr_params

// attribuer un nom de modèle
wf_setmodel("ANNUEL")

// init. critères par défaut
wf_ResetDefaults()


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

type cb_defaults from w_ancestor_rptpreview`cb_defaults within w_rpt_annuel
end type

type st_2 from w_ancestor_rptpreview`st_2 within w_rpt_annuel
end type

type st_1 from w_ancestor_rptpreview`st_1 within w_rpt_annuel
end type

type dw_papersize from w_ancestor_rptpreview`dw_papersize within w_rpt_annuel
end type

type cb_next from w_ancestor_rptpreview`cb_next within w_rpt_annuel
end type

type cb_prev from w_ancestor_rptpreview`cb_prev within w_rpt_annuel
end type

type dw_1 from w_ancestor_rptpreview`dw_1 within w_rpt_annuel
string dataobject = "d_rpt_annuel"
end type

type em_zoom from w_ancestor_rptpreview`em_zoom within w_rpt_annuel
end type

type st_zoom from w_ancestor_rptpreview`st_zoom within w_rpt_annuel
end type

type gb_1 from w_ancestor_rptpreview`gb_1 within w_rpt_annuel
end type

type dw_paperorient from w_ancestor_rptpreview`dw_paperorient within w_rpt_annuel
end type

