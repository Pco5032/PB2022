//objectcomments Impression des cantonnements
forward
global type w_rpt_cantonnement from w_ancestor_rptpreview
end type
end forward

global type w_rpt_cantonnement from w_ancestor_rptpreview
string title = "Liste des cantonnements"
end type
global w_rpt_cantonnement w_rpt_cantonnement

on w_rpt_cantonnement.create
call super::create
end on

on w_rpt_cantonnement.destroy
call super::destroy
end on

event ue_init;call super::ue_init;wf_setmodel("CANTONNEMENT")

// pas de critères par défaut
wf_ResetDefaults()

// critères de tri par défaut
wf_setDefaultTri("cantonnement.d")
wf_setDefaultTri("cantonnement.cantonnement")
end event

event ue_retrieve;call super::ue_retrieve;long	ll_rows

ll_rows = AncestorReturnValue

IF ll_rows <= 0 THEN 
	gu_message.uf_info("Aucun cantonnement ne correspond à votre requête")
	return(ll_rows)
END IF

// imprimer requête en français
dw_1.object.t_requete.text = is_selectinfrench

// nom du service
dw_1.object.t_service.text = gs_nomservice

return(ll_rows)
end event

type cb_defaults from w_ancestor_rptpreview`cb_defaults within w_rpt_cantonnement
end type

type st_2 from w_ancestor_rptpreview`st_2 within w_rpt_cantonnement
end type

type st_1 from w_ancestor_rptpreview`st_1 within w_rpt_cantonnement
end type

type dw_papersize from w_ancestor_rptpreview`dw_papersize within w_rpt_cantonnement
end type

type cb_next from w_ancestor_rptpreview`cb_next within w_rpt_cantonnement
end type

type cb_prev from w_ancestor_rptpreview`cb_prev within w_rpt_cantonnement
end type

type dw_1 from w_ancestor_rptpreview`dw_1 within w_rpt_cantonnement
string dataobject = "d_rpt_cantonnement"
end type

type em_zoom from w_ancestor_rptpreview`em_zoom within w_rpt_cantonnement
end type

type st_zoom from w_ancestor_rptpreview`st_zoom within w_rpt_cantonnement
end type

type gb_1 from w_ancestor_rptpreview`gb_1 within w_rpt_cantonnement
end type

type dw_paperorient from w_ancestor_rptpreview`dw_paperorient within w_rpt_cantonnement
end type

