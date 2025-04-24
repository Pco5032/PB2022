//objectcomments Impression des documents fournisseurs (EMIS) hors wallonie
forward
global type w_rpt_docfrn_horswal from w_ancestor_rptpreview
end type
end forward

global type w_rpt_docfrn_horswal from w_ancestor_rptpreview
string title = "Documents fournisseurs émis hors Wallonie"
end type
global w_rpt_docfrn_horswal w_rpt_docfrn_horswal

type variables
uo_ds		ids_df
string	is_sql
end variables

on w_rpt_docfrn_horswal.create
call super::create
end on

on w_rpt_docfrn_horswal.destroy
call super::destroy
end on

event ue_init;call super::ue_init;ids_df = CREATE uo_ds

ids_df.dataobject = "ds_rpt_df_horswal"
ids_df.setTransobject(SQLCA)

wf_setmodel("DOCFRNHW")

// init. critères par défaut
wf_ResetDefaults()

wf_SQLFromDW(FALSE)

is_sql = ids_df.getsqlselect()

wf_setoriginalselect(is_sql)
wf_setinsertionpoint("1=1")

wf_setDefault("df.dt_sign","between")

end event

event ue_retrieve;call super::ue_retrieve;long	ll_rows

ll_rows = AncestorReturnValue

IF ll_rows <= 0 THEN 
	gu_message.uf_info("Aucun document fournisseur émis ne correspond à votre requête")
	return(ll_rows)
END IF

return(ll_rows)
end event

event ue_manualsql;call super::ue_manualsql;long		ll_nbrows, ll_row
string	ls_inList, ls_where, ls_sql

// lire la liste des DF hors wallonie correspondant aux critères introduits
ids_df.object.datawindow.table.select = as_newSelect
ll_nbrows = ids_df.retrieve()
IF ll_nbrows <= 0 THEN
	return(-1)
END IF

// créer une clause "IN" contenant la liste des DF à imprimer
FOR ll_row = 1 TO ll_nbrows
	ls_inList = ls_inList + "'" + ids_df.object.num_df[ll_row] + "',"
NEXT

// ajouter la clause "IN" au DW d'impression
ls_sql = dw_1.GetSqlselect()
ls_where = "docfrn.num_df in (" + left(ls_inList, len(ls_inList) - 1) + ")"
ls_sql = f_modifysql(ls_sql, ls_where, "", "")
dw_1.SetSqlselect(ls_sql)

// modifier le titre du document
dw_1.Object.DataWindow.Print.DocumentName = "Documents fournisseurs hors Wallonie"

return(1)

end event

event ue_close;call super::ue_close;DESTROY ids_df
end event

type cb_defaults from w_ancestor_rptpreview`cb_defaults within w_rpt_docfrn_horswal
end type

type st_2 from w_ancestor_rptpreview`st_2 within w_rpt_docfrn_horswal
end type

type st_1 from w_ancestor_rptpreview`st_1 within w_rpt_docfrn_horswal
end type

type dw_papersize from w_ancestor_rptpreview`dw_papersize within w_rpt_docfrn_horswal
end type

type cb_next from w_ancestor_rptpreview`cb_next within w_rpt_docfrn_horswal
end type

type cb_prev from w_ancestor_rptpreview`cb_prev within w_rpt_docfrn_horswal
end type

type dw_1 from w_ancestor_rptpreview`dw_1 within w_rpt_docfrn_horswal
string dataobject = "d_rpt_docfrn"
end type

type em_zoom from w_ancestor_rptpreview`em_zoom within w_rpt_docfrn_horswal
end type

type st_zoom from w_ancestor_rptpreview`st_zoom within w_rpt_docfrn_horswal
end type

type gb_1 from w_ancestor_rptpreview`gb_1 within w_rpt_docfrn_horswal
end type

type dw_paperorient from w_ancestor_rptpreview`dw_paperorient within w_rpt_docfrn_horswal
end type

