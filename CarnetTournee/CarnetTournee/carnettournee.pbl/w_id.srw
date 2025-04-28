//objectcomments Modification domaine et username. RESERVE CELLULE INFORMATIQUE, NE PAS DIVULGUER, UTILISATION TEMPORAIRE !!!!! NB : version "CARNET" différente des versions EFOR/DBC : initialisation variable oracle spécifique.
forward
global type w_id from w_ancestor
end type
type sle_user from uo_sle within w_id
end type
type sle_domain from uo_sle within w_id
end type
type st_2 from uo_statictext within w_id
end type
type st_1 from uo_statictext within w_id
end type
type cb_1 from uo_cb_ok within w_id
end type
type gb_1 from uo_groupbox within w_id
end type
end forward

global type w_id from w_ancestor
integer width = 1376
integer height = 684
string title = ""
boolean minbox = false
boolean maxbox = false
boolean resizable = false
sle_user sle_user
sle_domain sle_domain
st_2 st_2
st_1 st_1
cb_1 cb_1
gb_1 gb_1
end type
global w_id w_id

forward prototypes
public function integer wf_init_oracle_logname ()
end prototypes

public function integer wf_init_oracle_logname ();// Spécifique carnet de tournée : initialiser le logname dans les paramètres des sessions Oracle.

string	ls_sql

ls_sql = "execute DNF_vars.setLogname('" + gs_username + "')"
execute immediate :ls_sql using SQLCA;
IF f_check_sql(SQLCA) <> 0 THEN
	populateerror(20000,"")
	gu_message.uf_unexp("SQLCA : Problème exec procédure - " + f_string(ls_sql))
	return(-1)
END IF

execute immediate :ls_sql using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	populateerror(20000,"")
	gu_message.uf_unexp("ESQLCA : Problème exec procédure - " + f_string(ls_sql))
	return(-1)
END IF

return(1)

end function

on w_id.create
int iCurrent
call super::create
this.sle_user=create sle_user
this.sle_domain=create sle_domain
this.st_2=create st_2
this.st_1=create st_1
this.cb_1=create cb_1
this.gb_1=create gb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.sle_user
this.Control[iCurrent+2]=this.sle_domain
this.Control[iCurrent+3]=this.st_2
this.Control[iCurrent+4]=this.st_1
this.Control[iCurrent+5]=this.cb_1
this.Control[iCurrent+6]=this.gb_1
end on

on w_id.destroy
call super::destroy
destroy(this.sle_user)
destroy(this.sle_domain)
destroy(this.st_2)
destroy(this.st_1)
destroy(this.cb_1)
destroy(this.gb_1)
end on

event ue_open;call super::ue_open;sle_domain.text = gs_domain
sle_user.text = gs_username
end event

type sle_user from uo_sle within w_id
integer x = 457
integer y = 224
integer width = 677
integer height = 80
integer taborder = 20
integer textsize = -9
textcase textcase = upper!
end type

type sle_domain from uo_sle within w_id
integer x = 457
integer y = 128
integer width = 677
integer height = 80
integer taborder = 10
integer textsize = -9
textcase textcase = upper!
end type

type st_2 from uo_statictext within w_id
integer x = 201
integer y = 240
integer width = 256
string text = "User :"
end type

type st_1 from uo_statictext within w_id
integer x = 201
integer y = 144
integer width = 251
string text = "Domain :"
end type

type cb_1 from uo_cb_ok within w_id
integer x = 512
integer y = 416
end type

event clicked;call super::clicked;gs_domain = sle_domain.text
gs_username = sle_user.text

// réinitialiser la gestion des privilèges
IF gu_privs.uf_initprivs() = -1 THEN
	gu_message.uf_unexp("Erreur gu_privs.uf_initprivs()")
	halt close
END IF

// Spécifique carnet de tournée : initialiser le logname dans les paramètres des sessions Oracle.
wf_init_Oracle_logname()

close(parent)
end event

type gb_1 from uo_groupbox within w_id
integer x = 165
integer y = 64
integer width = 1006
integer height = 288
end type

