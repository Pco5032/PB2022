//objectcomments Impression grade, rang, commune admin, commune effective.~r~nAffichage des agents dont l'utilisateur est responsable+ utilisateur lui-même + remplacements éventuels. Tous si superuser='O'.
forward
global type w_rpt_prepose_multiple_divers from w_ancestor_rptpreview
end type
end forward

global type w_rpt_prepose_multiple_divers from w_ancestor_rptpreview
string tag = "TEXT_00830"
string title = "Agents - informations personnelles"
end type
global w_rpt_prepose_multiple_divers w_rpt_prepose_multiple_divers

type variables
string	is_matricule, is_option_paiement
integer	ii_annee, ii_mois, ii_heures
end variables

on w_rpt_prepose_multiple_divers.create
call super::create
end on

on w_rpt_prepose_multiple_divers.destroy
call super::destroy
end on

event ue_init;call super::ue_init;str_params	lstr_params

// attribuer un nom de modèle
wf_setmodel("AGENT_CT")

// pas de critères de sélection
wf_showSelection(FALSE)

wf_sqlFromDW(FALSE)


end event

event ue_retrieve;// OVERRIDE Ancestor's script : retrieve avec arguments
long		ll_rows
string	ls_super

// Attention : si membre du groupe de superusers "FULL", accès à tous les agents paramétrés dans le système !
IF gu_privs.uf_super("FULL") THEN
	ls_super = "O"
ELSE
	ls_super = "N"
END IF

// Ne pas tenir compte des droits de consulter/modifier le planning ni le réalisé : arguments 3 à 6 ="N"
ll_rows = dw_1.retrieve(gs_username, ls_super)
IF ll_rows < 0 THEN
	populateError(20000, "Erreur lecture liste des préposés")
	gu_message.uf_unexp()
	return(-1)
END IF

// nom du service
dw_1.object.t_service.text = gs_nomservice

return(ll_rows)
end event

type cb_defaults from w_ancestor_rptpreview`cb_defaults within w_rpt_prepose_multiple_divers
end type

type st_2 from w_ancestor_rptpreview`st_2 within w_rpt_prepose_multiple_divers
end type

type st_1 from w_ancestor_rptpreview`st_1 within w_rpt_prepose_multiple_divers
end type

type dw_papersize from w_ancestor_rptpreview`dw_papersize within w_rpt_prepose_multiple_divers
end type

type cb_next from w_ancestor_rptpreview`cb_next within w_rpt_prepose_multiple_divers
end type

type cb_prev from w_ancestor_rptpreview`cb_prev within w_rpt_prepose_multiple_divers
end type

type dw_1 from w_ancestor_rptpreview`dw_1 within w_rpt_prepose_multiple_divers
string dataobject = "d_rpt_prepose_multiple_divers"
end type

type em_zoom from w_ancestor_rptpreview`em_zoom within w_rpt_prepose_multiple_divers
end type

type st_zoom from w_ancestor_rptpreview`st_zoom within w_rpt_prepose_multiple_divers
end type

type gb_1 from w_ancestor_rptpreview`gb_1 within w_rpt_prepose_multiple_divers
end type

type dw_paperorient from w_ancestor_rptpreview`dw_paperorient within w_rpt_prepose_multiple_divers
end type

