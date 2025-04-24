//objectcomments Impression des demandes d'autorisation de récolte
forward
global type w_rpt_demautorisation from w_ancestor_rptpreview
end type
end forward

global type w_rpt_demautorisation from w_ancestor_rptpreview
string title = "Demande d~'autorisation de récolte"
end type
global w_rpt_demautorisation w_rpt_demautorisation

type variables
integer	ii_anaut, ii_numaut
end variables

on w_rpt_demautorisation.create
call super::create
end on

on w_rpt_demautorisation.destroy
call super::destroy
end on

event ue_init;call super::ue_init;str_params	lstr_params

wf_setmodel("DEMAUTORIS")

// init. critères par défaut
wf_ResetDefaults()

// récupérer les paramètres (an_aut, num_aut) : utilisé quand on imprime directement à partir du programme d'encodage
lstr_params = Message.PowerObjectParm

IF IsValid(lstr_params) THEN 
	IF upperbound(lstr_params.a_param) = 2 THEN
		ii_anaut = integer(lstr_params.a_param[1])
		ii_numaut = integer(lstr_params.a_param[2])
		wf_ShowSelection(FALSE)
		wf_SQLFromDW(FALSE)
	END IF
ELSE
	wf_setDefault("autorisation.an_aut","=")
	wf_setDefault("autorisation.num_aut","=")
END IF

end event

event ue_retrieve;call super::ue_retrieve;long	ll_rows

ll_rows = AncestorReturnValue

IF ll_rows <= 0 THEN 
	gu_message.uf_info("Aucune autorisation ne correspond à votre requête")
	return(ll_rows)
END IF

return(ll_rows)
end event

event ue_manualsql;call super::ue_manualsql;string	ls_sql, ls_where

ls_sql = dw_1.GetSqlselect()
ls_where = "autorisation.an_aut=" + f_string(ii_anaut) + " and autorisation.num_aut=" + f_string(ii_numaut)
ls_sql = f_modifysql(ls_sql, ls_where, "", "")
dw_1.SetSqlselect(ls_sql)
return(1)
end event

type cb_defaults from w_ancestor_rptpreview`cb_defaults within w_rpt_demautorisation
end type

type st_2 from w_ancestor_rptpreview`st_2 within w_rpt_demautorisation
end type

type st_1 from w_ancestor_rptpreview`st_1 within w_rpt_demautorisation
end type

type dw_papersize from w_ancestor_rptpreview`dw_papersize within w_rpt_demautorisation
end type

type cb_next from w_ancestor_rptpreview`cb_next within w_rpt_demautorisation
end type

type cb_prev from w_ancestor_rptpreview`cb_prev within w_rpt_demautorisation
end type

type dw_1 from w_ancestor_rptpreview`dw_1 within w_rpt_demautorisation
string dataobject = "d_rpt_demautorisation"
end type

type em_zoom from w_ancestor_rptpreview`em_zoom within w_rpt_demautorisation
end type

type st_zoom from w_ancestor_rptpreview`st_zoom within w_rpt_demautorisation
end type

type gb_1 from w_ancestor_rptpreview`gb_1 within w_rpt_demautorisation
end type

type dw_paperorient from w_ancestor_rptpreview`dw_paperorient within w_rpt_demautorisation
end type

