//objectcomments Impression des documents fournisseurs (EMIS) - avant 27/11/2013
forward
global type w_rpt_docfrn_old from w_ancestor_rptpreview
end type
end forward

global type w_rpt_docfrn_old from w_ancestor_rptpreview
string title = "Documents fournisseurs émis"
end type
global w_rpt_docfrn_old w_rpt_docfrn_old

type variables
string	is_numdf
end variables

on w_rpt_docfrn_old.create
call super::create
end on

on w_rpt_docfrn_old.destroy
call super::destroy
end on

event ue_init;call super::ue_init;str_params	lstr_params

wf_setmodel("DOCFRN")

// init. critères par défaut
wf_ResetDefaults()

// récupérer les paramètres (num_df) : utilisé quand on imprime directement à partir du programme d'encodage
lstr_params = Message.PowerObjectParm

IF IsValid(lstr_params) THEN 
	IF upperbound(lstr_params.a_param) = 1 THEN
		is_numdf = string(lstr_params.a_param[1])
		wf_ShowSelection(FALSE)
		wf_SQLFromDW(FALSE)
	END IF
ELSE
	wf_setDefault("docfrn.num_df","=")
END IF
end event

event ue_retrieve;call super::ue_retrieve;long	ll_rows

ll_rows = AncestorReturnValue

IF ll_rows <= 0 THEN 
	gu_message.uf_info("Aucun document fournisseur émis ne correspond à votre requête")
	return(ll_rows)
END IF

return(ll_rows)
end event

event ue_manualsql;call super::ue_manualsql;string	ls_sql, ls_where

ls_sql = dw_1.GetSqlselect()
ls_where = "docfrn.num_df='" + is_numdf + "'"
ls_sql = f_modifysql(ls_sql, ls_where, "", "")
dw_1.SetSqlselect(ls_sql)
return(1)
end event

type cb_defaults from w_ancestor_rptpreview`cb_defaults within w_rpt_docfrn_old
end type

type st_2 from w_ancestor_rptpreview`st_2 within w_rpt_docfrn_old
end type

type st_1 from w_ancestor_rptpreview`st_1 within w_rpt_docfrn_old
end type

type dw_papersize from w_ancestor_rptpreview`dw_papersize within w_rpt_docfrn_old
end type

type cb_next from w_ancestor_rptpreview`cb_next within w_rpt_docfrn_old
end type

type cb_prev from w_ancestor_rptpreview`cb_prev within w_rpt_docfrn_old
end type

type dw_1 from w_ancestor_rptpreview`dw_1 within w_rpt_docfrn_old
string dataobject = "d_rpt_docfrn"
end type

type em_zoom from w_ancestor_rptpreview`em_zoom within w_rpt_docfrn_old
end type

type st_zoom from w_ancestor_rptpreview`st_zoom within w_rpt_docfrn_old
end type

type gb_1 from w_ancestor_rptpreview`gb_1 within w_rpt_docfrn_old
end type

type dw_paperorient from w_ancestor_rptpreview`dw_paperorient within w_rpt_docfrn_old
end type

