//objectcomments Impression des textes legislatifs
forward
global type w_rpt_legislation from w_ancestor_rptpreview
end type
end forward

global type w_rpt_legislation from w_ancestor_rptpreview
string title = "Liste des textes législatifs"
end type
global w_rpt_legislation w_rpt_legislation

on w_rpt_legislation.create
call super::create
end on

on w_rpt_legislation.destroy
call super::destroy
end on

event ue_init;call super::ue_init;wf_setmodel("LEGIS")

// init. critères par défaut
wf_ResetDefaults()


end event

event ue_retrieve;call super::ue_retrieve;long	ll_rows

ll_rows = AncestorReturnValue

IF ll_rows <= 0 THEN 
	gu_message.uf_info("Aucun texte ne correspond à votre requête")
	return(ll_rows)
END IF

// imprimer requête en français
// dw_1.object.t_requete.text = is_selectinfrench

// nom du service
// dw_1.object.t_service.text = gs_nomservice

return(ll_rows)
end event

type cb_defaults from w_ancestor_rptpreview`cb_defaults within w_rpt_legislation
end type

type st_2 from w_ancestor_rptpreview`st_2 within w_rpt_legislation
end type

type st_1 from w_ancestor_rptpreview`st_1 within w_rpt_legislation
end type

type dw_papersize from w_ancestor_rptpreview`dw_papersize within w_rpt_legislation
end type

type cb_next from w_ancestor_rptpreview`cb_next within w_rpt_legislation
end type

type cb_prev from w_ancestor_rptpreview`cb_prev within w_rpt_legislation
end type

type dw_1 from w_ancestor_rptpreview`dw_1 within w_rpt_legislation
string dataobject = "d_rpt_legislation"
end type

type em_zoom from w_ancestor_rptpreview`em_zoom within w_rpt_legislation
end type

type st_zoom from w_ancestor_rptpreview`st_zoom within w_rpt_legislation
end type

type gb_1 from w_ancestor_rptpreview`gb_1 within w_rpt_legislation
end type

type dw_paperorient from w_ancestor_rptpreview`dw_paperorient within w_rpt_legislation
end type

