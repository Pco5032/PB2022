forward
global type w_sql_ct from w_sql
end type
end forward

global type w_sql_ct from w_sql
end type
global w_sql_ct w_sql_ct

on w_sql_ct.create
call super::create
end on

on w_sql_ct.destroy
call super::destroy
end on

event ue_open;call super::ue_open;long		ll_row, ll_nbrows
integer	li_id

// Masquer les requêtes auxquelles l'utilisateur n'a pas droit.
// On utilise le système des droits d'accès classique, mais le nom de programme est remplacé
// par l'identifiant de la requête sous la forme "sqlreq/nnn" 
ll_nbrows = dw_sql.rowcount()
FOR ll_row = 1 TO ll_nbrows
	li_id = integer(dw_sql.object.id[ll_row])
	IF gu_privs.uf_canconsult("sqlreq/" + string(li_id)) = -1 THEN
		dw_sql.RowsDiscard(ll_row, ll_row, Primary!)
		ll_nbrows = ll_nbrows - 1
		ll_row = ll_row - 1
	END IF
NEXT
end event

type cb_mle from w_sql`cb_mle within w_sql_ct
end type

type st_dw from w_sql`st_dw within w_sql_ct
end type

type st_mle from w_sql`st_mle within w_sql_ct
end type

type mle_sql from w_sql`mle_sql within w_sql_ct
end type

type cb_dw from w_sql`cb_dw within w_sql_ct
end type

type dw_sql from w_sql`dw_sql within w_sql_ct
end type

type p_1 from w_sql`p_1 within w_sql_ct
end type

