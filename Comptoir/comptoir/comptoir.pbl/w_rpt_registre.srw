//objectcomments Impression du registre des MFR
forward
global type w_rpt_registre from w_ancestor_rptpreview
end type
end forward

global type w_rpt_registre from w_ancestor_rptpreview
string title = "Registre des MFR"
end type
global w_rpt_registre w_rpt_registre

type variables
string	is_reflot
end variables

on w_rpt_registre.create
call super::create
end on

on w_rpt_registre.destroy
call super::destroy
end on

event ue_init;call super::ue_init;str_params	lstr_params

wf_setmodel("REGISTRE")

// init. critères par défaut
wf_ResetDefaults()

// récupérer les paramètres (num_df) : utilisé quand on imprime directement à partir du programme d'encodage
lstr_params = Message.PowerObjectParm

IF IsValid(lstr_params) THEN 
	IF upperbound(lstr_params.a_param) = 1 THEN
		is_REFLOT = string(lstr_params.a_param[1])
		wf_ShowSelection(FALSE)
		wf_SQLFromDW(FALSE)
	END IF
ELSE
	wf_setDefault("registre.ref_lot","=")
END IF
end event

event ue_retrieve;call super::ue_retrieve;long	ll_rows

ll_rows = AncestorReturnValue

IF ll_rows <= 0 THEN 
	gu_message.uf_info("Aucun lot ne correspond à votre requête")
	return(ll_rows)
END IF

return(ll_rows)
end event

event ue_manualsql;call super::ue_manualsql;string	ls_sql, ls_where

ls_sql = dw_1.GetSqlselect()
ls_where = "registre.ref_lot='" + is_reflot + "'"
ls_sql = f_modifysql(ls_sql, ls_where, "", "")
dw_1.SetSqlselect(ls_sql)
return(1)
end event

type cb_defaults from w_ancestor_rptpreview`cb_defaults within w_rpt_registre
end type

type st_2 from w_ancestor_rptpreview`st_2 within w_rpt_registre
end type

type st_1 from w_ancestor_rptpreview`st_1 within w_rpt_registre
end type

type dw_papersize from w_ancestor_rptpreview`dw_papersize within w_rpt_registre
end type

type cb_next from w_ancestor_rptpreview`cb_next within w_rpt_registre
end type

type cb_prev from w_ancestor_rptpreview`cb_prev within w_rpt_registre
end type

type dw_1 from w_ancestor_rptpreview`dw_1 within w_rpt_registre
string dataobject = "d_rpt_registre"
end type

type em_zoom from w_ancestor_rptpreview`em_zoom within w_rpt_registre
end type

type st_zoom from w_ancestor_rptpreview`st_zoom within w_rpt_registre
end type

type gb_1 from w_ancestor_rptpreview`gb_1 within w_rpt_registre
end type

type dw_paperorient from w_ancestor_rptpreview`dw_paperorient within w_rpt_registre
end type

