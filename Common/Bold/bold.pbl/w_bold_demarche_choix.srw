//objectcomments Choix par l'utilisateur des démarches qu'il souhaite voir (parmi celles dont les droits en lecture lui sont octroyés)
forward
global type w_bold_demarche_choix from w_ancestor
end type
type cb_ok from uo_cb_ok within w_bold_demarche_choix
end type
type cb_cancel from uo_cb_cancel within w_bold_demarche_choix
end type
type dw_1 from uo_datawindow_multiplerow within w_bold_demarche_choix
end type
end forward

global type w_bold_demarche_choix from w_ancestor
integer width = 2208
integer height = 1556
string title = "Choix des démarches visibles"
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
cb_ok cb_ok
cb_cancel cb_cancel
dw_1 dw_1
end type
global w_bold_demarche_choix w_bold_demarche_choix

type variables
string	is_oldChoix
end variables

on w_bold_demarche_choix.create
int iCurrent
call super::create
this.cb_ok=create cb_ok
this.cb_cancel=create cb_cancel
this.dw_1=create dw_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_ok
this.Control[iCurrent+2]=this.cb_cancel
this.Control[iCurrent+3]=this.dw_1
end on

on w_bold_demarche_choix.destroy
call super::destroy
destroy(this.cb_ok)
destroy(this.cb_cancel)
destroy(this.dw_1)
end on

event ue_open;call super::ue_open;// garnir DW avec les démarches visibles selon les droits d'accès et choix de l'utilisateur
str_params	lstr_params
string	ls_choixListe, ls_choix[], ls_prog[], ls_nom[]
integer	li_i, li_j
long		ll_row

f_centerinmdi(this)

// Le paramètre reçu est un array contenant la liste des démarches que l'utilisateur à au miniumum le droit de visualiser
lstr_params = message.powerobjectparm

// lecture des choix actuels de l'utilisateur dans le .ini local
ls_choixListe = profileString(gs_locinifile, gs_username, "BOLD_DEMARCHES_CHOISIES", "")
f_parse(ls_choixListe, ",", ls_choix)

// Garnir DW avec les démarches autorisées et le choix actuel de visibilité
// Si aucun choix actuel stocké dans le .ini, toutes les démarches sont choisies par défaut.
dw_1.setRedraw(FALSE)
ls_prog = lstr_params.a_param[1]
ls_nom = lstr_params.a_param[2]
FOR li_i = 1 TO upperBound(ls_prog)
	ll_row = dw_1.insertrow(0)
	dw_1.object.s_demarche[ll_row] = ls_nom[li_i]
	dw_1.object.s_prog[ll_row] = ls_prog[li_i]
	IF f_isEmptyString(ls_choixListe) THEN
		dw_1.object.s_choix[ll_row] = "O"
	ELSE
		dw_1.object.s_choix[ll_row] = "N"
		FOR li_j = 1 TO upperBound(ls_choix)
			IF upper(ls_prog[li_i]) = upper(ls_choix[li_j]) THEN
				dw_1.object.s_choix[ll_row] = "O"
				EXIT
			END IF
		NEXT
	END IF
NEXT

// trier le DW
dw_1.setSort("s_prog")
dw_1.sort()
dw_1.setRedraw(TRUE)

// construire liste (triée par démarche) des choix actuels
FOR ll_row = 1 TO dw_1.rowCount()
	IF dw_1.object.s_choix[ll_row] = "O" THEN
		is_oldChoix = is_oldChoix + dw_1.object.s_prog[ll_row] + ","
	END IF
NEXT
is_oldChoix = left(is_oldChoix, len(is_oldChoix) - 1)
end event

event ue_closebyxaccepted;call super::ue_closebyxaccepted;cb_cancel.Event clicked()
end event

type cb_ok from uo_cb_ok within w_bold_demarche_choix
integer x = 585
integer y = 1312
end type

event clicked;call super::clicked;// Si modification, enregistrer les choix de l'utilisateur dans le .ini local
long	ll_row
string	ls_newChoix
str_params	lstr_params

// construire liste (triée par démarche) des nouveaux choix
FOR ll_row = 1 TO dw_1.rowCount()
	IF dw_1.object.s_choix[ll_row] = "O" THEN
		ls_newChoix = ls_newChoix + dw_1.object.s_prog[ll_row] + ","
	END IF
NEXT
ls_newchoix = left(ls_newchoix, len(ls_newchoix) - 1)

IF ls_newChoix <> is_oldChoix THEN
	setProfileString(gs_locinifile, gs_username, "BOLD_DEMARCHES_CHOISIES", ls_newchoix)
	CloseWithReturn(Parent, 1)
ELSE
	CloseWithReturn(Parent, -1)
END IF

end event

type cb_cancel from uo_cb_cancel within w_bold_demarche_choix
integer x = 1207
integer y = 1312
end type

event clicked;call super::clicked;CloseWithReturn(Parent, -1)
end event

type dw_1 from uo_datawindow_multiplerow within w_bold_demarche_choix
integer width = 2194
integer height = 1280
integer taborder = 10
string dataobject = "d_bold_demarche_choix"
boolean hscrollbar = true
boolean vscrollbar = true
boolean border = true
end type

