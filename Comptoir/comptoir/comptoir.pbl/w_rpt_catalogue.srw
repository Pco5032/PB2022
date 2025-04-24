//objectcomments Impression du catalogue
forward
global type w_rpt_catalogue from w_ancestor_rptpreview
end type
end forward

global type w_rpt_catalogue from w_ancestor_rptpreview
string title = "Impression du catalogue"
end type
global w_rpt_catalogue w_rpt_catalogue

on w_rpt_catalogue.create
call super::create
end on

on w_rpt_catalogue.destroy
call super::destroy
end on

event ue_init;call super::ue_init;wf_setmodel("CATALOGUE")

// on ne peut pas modifier les critères de tri
wf_triEnabled(FALSE)

// init. critères par défaut
wf_ResetDefaults()
wf_setDefault("cat_vente.num_cat","=")


end event

event ue_retrieve;call super::ue_retrieve;long	ll_rows

ll_rows = AncestorReturnValue

IF ll_rows <= 0 THEN 
	gu_message.uf_info("Aucune donnée ne correspond à votre requête")
	return(ll_rows)
END IF

return(ll_rows)
end event

type cb_defaults from w_ancestor_rptpreview`cb_defaults within w_rpt_catalogue
end type

type st_2 from w_ancestor_rptpreview`st_2 within w_rpt_catalogue
end type

type st_1 from w_ancestor_rptpreview`st_1 within w_rpt_catalogue
end type

type dw_papersize from w_ancestor_rptpreview`dw_papersize within w_rpt_catalogue
end type

type cb_next from w_ancestor_rptpreview`cb_next within w_rpt_catalogue
end type

type cb_prev from w_ancestor_rptpreview`cb_prev within w_rpt_catalogue
end type

type dw_1 from w_ancestor_rptpreview`dw_1 within w_rpt_catalogue
string dataobject = "d_rpt_catalogue"
end type

type em_zoom from w_ancestor_rptpreview`em_zoom within w_rpt_catalogue
end type

type st_zoom from w_ancestor_rptpreview`st_zoom within w_rpt_catalogue
end type

type gb_1 from w_ancestor_rptpreview`gb_1 within w_rpt_catalogue
end type

type dw_paperorient from w_ancestor_rptpreview`dw_paperorient within w_rpt_catalogue
end type

