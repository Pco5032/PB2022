//objectcomments Report contenant le résultat de la commande SQL demandée dans W_SQL
forward
global type w_rpt_sql from w_ancestor_rptpreview
end type
end forward

global type w_rpt_sql from w_ancestor_rptpreview
end type
global w_rpt_sql w_rpt_sql

on w_rpt_sql.create
call super::create
end on

on w_rpt_sql.destroy
call super::destroy
end on

event ue_init;call super::ue_init;str_params lstr_params
string	ls_sql, ls_syntax, ls_error
long	ll_rows

lstr_params = im_message.powerobjectparm
ls_sql = lstr_params.a_param[1]
ls_syntax = lstr_params.a_param[2]

// crée un datawindow sur base de la syntaxe reçue et l'associer au DW du report
dw_1.Create(ls_Syntax, ls_error)
IF LenA(ls_error) > 0 THEN
	gu_message.uf_error("Erreur Create Datawindow : " + ls_error)
	wf_executepostopen(FALSE)
	post close(this)
	return
END IF
dw_1.SetTransObject(SQLCA)



end event

event ue_retrieve;call super::ue_retrieve;long	ll_rows

ll_rows = AncestorReturnValue

IF AncestorReturnValue = 0 THEN
	gu_message.uf_info("Aucune donnée ne correspond à votre requête")
END IF
return(ll_rows)
end event

event ue_open;call super::ue_open;// ne pas logger de message lors de l'utilisation de cette fenêtre
wf_logusage(FALSE)

wf_showselection(FALSE)


end event

type cb_defaults from w_ancestor_rptpreview`cb_defaults within w_rpt_sql
end type

type st_2 from w_ancestor_rptpreview`st_2 within w_rpt_sql
end type

type st_1 from w_ancestor_rptpreview`st_1 within w_rpt_sql
end type

type dw_papersize from w_ancestor_rptpreview`dw_papersize within w_rpt_sql
end type

type cb_next from w_ancestor_rptpreview`cb_next within w_rpt_sql
end type

type cb_prev from w_ancestor_rptpreview`cb_prev within w_rpt_sql
end type

type dw_1 from w_ancestor_rptpreview`dw_1 within w_rpt_sql
end type

type em_zoom from w_ancestor_rptpreview`em_zoom within w_rpt_sql
end type

type st_zoom from w_ancestor_rptpreview`st_zoom within w_rpt_sql
end type

type gb_1 from w_ancestor_rptpreview`gb_1 within w_rpt_sql
end type

type dw_paperorient from w_ancestor_rptpreview`dw_paperorient within w_rpt_sql
end type

