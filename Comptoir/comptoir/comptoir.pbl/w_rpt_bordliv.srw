//objectcomments Impression des bordereaux de livraison
forward
global type w_rpt_bordliv from w_ancestor_rptpreview
end type
end forward

global type w_rpt_bordliv from w_ancestor_rptpreview
string title = "Bordereaux de livraison"
end type
global w_rpt_bordliv w_rpt_bordliv

type variables
integer	ii_ancmde, ii_numcmde, ii_numbord
end variables

on w_rpt_bordliv.create
call super::create
end on

on w_rpt_bordliv.destroy
call super::destroy
end on

event ue_init;call super::ue_init;str_params	lstr_params

wf_setmodel("BORDLIV")

// init. critères par défaut
wf_ResetDefaults()

wf_setInsertionPoint("1=1")

// récupérer les paramètres (an_cmde, num_cmde et num_bord) : utilisé quand on imprime directement
// le bordereau lors de sa création
lstr_params = Message.PowerObjectParm

IF IsValid(lstr_params) THEN 
	IF upperbound(lstr_params.a_param) = 3 THEN
		ii_ancmde = integer(lstr_params.a_param[1])
		ii_numcmde = integer(lstr_params.a_param[2])
		ii_numbord = integer(lstr_params.a_param[3])
		wf_ShowSelection(FALSE)
		wf_SQLFromDW(FALSE)
	END IF
END IF

end event

event ue_retrieve;call super::ue_retrieve;long	ll_rows

ll_rows = AncestorReturnValue

IF ll_rows <= 0 THEN 
	gu_message.uf_info("Aucune commande ne correspond à votre requête")
	return(ll_rows)
END IF

return(ll_rows)
end event

event ue_manualsql;call super::ue_manualsql;string	ls_sql, ls_where

ls_sql = dw_1.GetSqlselect()
ls_where = "b.an_cmde=" + f_string(ii_ancmde) + " and b.num_cmde=" + f_string(ii_numcmde) + &
			  " and b.num_bord=" + f_string(ii_numbord)
ls_sql = f_modifysql(ls_sql, ls_where, "", "1=1")
dw_1.SetSqlselect(ls_sql)
return(1)
end event

type cb_defaults from w_ancestor_rptpreview`cb_defaults within w_rpt_bordliv
end type

type st_2 from w_ancestor_rptpreview`st_2 within w_rpt_bordliv
end type

type st_1 from w_ancestor_rptpreview`st_1 within w_rpt_bordliv
end type

type dw_papersize from w_ancestor_rptpreview`dw_papersize within w_rpt_bordliv
end type

type cb_next from w_ancestor_rptpreview`cb_next within w_rpt_bordliv
end type

type cb_prev from w_ancestor_rptpreview`cb_prev within w_rpt_bordliv
end type

type dw_1 from w_ancestor_rptpreview`dw_1 within w_rpt_bordliv
string dataobject = "d_rpt_bordliv"
end type

type em_zoom from w_ancestor_rptpreview`em_zoom within w_rpt_bordliv
end type

type st_zoom from w_ancestor_rptpreview`st_zoom within w_rpt_bordliv
end type

type gb_1 from w_ancestor_rptpreview`gb_1 within w_rpt_bordliv
end type

type dw_paperorient from w_ancestor_rptpreview`dw_paperorient within w_rpt_bordliv
end type

