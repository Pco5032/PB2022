//objectcomments Impression des ventes de semences
forward
global type w_rpt_vtesemences from w_ancestor_rptpreview
end type
end forward

global type w_rpt_vtesemences from w_ancestor_rptpreview
integer width = 3502
string title = "Ventes de semences"
end type
global w_rpt_vtesemences w_rpt_vtesemences

on w_rpt_vtesemences.create
call super::create
end on

on w_rpt_vtesemences.destroy
call super::destroy
end on

event ue_init;call super::ue_init;string	ls_sql
DataWindowChild l_dwc
integer	li_st

wf_setmodel("VTESEMENCES")

// critères par défaut
wf_ResetDefaults()

wf_TriEnabled(FALSE)

end event

event ue_retrieve;call super::ue_retrieve;long	ll_rows

ll_rows = ancestorreturnvalue

// imprimer requête en français
dw_1.object.t_requete.text = is_selectinfrench

// nom du service
dw_1.object.t_service.text = gs_nomservice

return(ll_rows)

end event

type cb_defaults from w_ancestor_rptpreview`cb_defaults within w_rpt_vtesemences
integer x = 3163
end type

type st_2 from w_ancestor_rptpreview`st_2 within w_rpt_vtesemences
integer x = 2267
integer y = 128
end type

type st_1 from w_ancestor_rptpreview`st_1 within w_rpt_vtesemences
integer x = 2267
integer y = 48
end type

type dw_papersize from w_ancestor_rptpreview`dw_papersize within w_rpt_vtesemences
integer x = 2615
end type

type cb_next from w_ancestor_rptpreview`cb_next within w_rpt_vtesemences
end type

type cb_prev from w_ancestor_rptpreview`cb_prev within w_rpt_vtesemences
end type

type dw_1 from w_ancestor_rptpreview`dw_1 within w_rpt_vtesemences
integer width = 3419
string dataobject = "d_rpt_vtesemences"
end type

type em_zoom from w_ancestor_rptpreview`em_zoom within w_rpt_vtesemences
integer x = 1774
integer y = 80
end type

type st_zoom from w_ancestor_rptpreview`st_zoom within w_rpt_vtesemences
integer x = 1591
integer y = 96
end type

type gb_1 from w_ancestor_rptpreview`gb_1 within w_rpt_vtesemences
integer width = 3419
end type

type dw_paperorient from w_ancestor_rptpreview`dw_paperorient within w_rpt_vtesemences
integer x = 2615
end type

