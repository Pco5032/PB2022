//objectcomments Rapport : liste des privilèges spécifiques à chaque utilisateur
forward
global type w_rpt_userprivs from w_ancestor_rptpreview
end type
end forward

global type w_rpt_userprivs from w_ancestor_rptpreview
string title = "Impression des privilèges des utilisateurs"
end type
global w_rpt_userprivs w_rpt_userprivs

type variables
string	is_det
integer	ii_groupe1, ii_groupe2
end variables

on w_rpt_userprivs.create
call super::create
end on

on w_rpt_userprivs.destroy
call super::destroy
end on

event ue_init;call super::ue_init;wf_setmodel("USERPRIVS")

end event

event ue_retrieve;call super::ue_retrieve;long			ll_row, ll_nbrows

ll_nbrows = AncestorReturnValue

// aucune donnée ne correspond aux critères
IF ll_nbrows = 0 THEN
	gu_message.uf_info("Aucune donnée ne correspond aux critères choisis")
	return(0)
END IF

FOR ll_row = 1 TO ll_nbrows
	// établir liste des droits de chaque user
	gu_privs.uf_initprivs(dw_1.Object.domain[ll_row], dw_1.Object.logname[ll_row])
	dw_1.Object.dw_privs[ll_row].Object.Data = gu_privs.ids_privs.object.data
NEXT

// rétablir la liste des droits du user en cours
gu_privs.uf_initprivs()

// imprimer requête en français
dw_1.object.t_requete.text = is_selectinfrench

dw_1.object.t_service.text = gs_nomservice

return(ll_nbrows)

end event

event ue_open;call super::ue_open;// ne pas logger de message lors de l'utilisation de cette fenêtre
wf_logusage(FALSE)
end event

type cb_defaults from w_ancestor_rptpreview`cb_defaults within w_rpt_userprivs
end type

type st_2 from w_ancestor_rptpreview`st_2 within w_rpt_userprivs
end type

type st_1 from w_ancestor_rptpreview`st_1 within w_rpt_userprivs
end type

type dw_papersize from w_ancestor_rptpreview`dw_papersize within w_rpt_userprivs
end type

type cb_next from w_ancestor_rptpreview`cb_next within w_rpt_userprivs
end type

type cb_prev from w_ancestor_rptpreview`cb_prev within w_rpt_userprivs
end type

type dw_1 from w_ancestor_rptpreview`dw_1 within w_rpt_userprivs
integer width = 2560
string dataobject = "d_rpt_userprivs"
end type

type em_zoom from w_ancestor_rptpreview`em_zoom within w_rpt_userprivs
end type

type st_zoom from w_ancestor_rptpreview`st_zoom within w_rpt_userprivs
end type

type gb_1 from w_ancestor_rptpreview`gb_1 within w_rpt_userprivs
end type

type dw_paperorient from w_ancestor_rptpreview`dw_paperorient within w_rpt_userprivs
end type

