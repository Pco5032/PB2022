forward
global type w_l_traduction from w_ancestor
end type
type sle_preselect from uo_sle within w_l_traduction
end type
type st_1 from uo_statictext within w_l_traduction
end type
type cb_ok from uo_cb_ok within w_l_traduction
end type
type cb_cancel from uo_cb_cancel within w_l_traduction
end type
type dw_1 from uo_ancestor_dwbrowse within w_l_traduction
end type
end forward

global type w_l_traduction from w_ancestor
integer x = 498
integer width = 1778
integer height = 1644
string title = "Sélection code(s)"
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
sle_preselect sle_preselect
st_1 st_1
cb_ok cb_ok
cb_cancel cb_cancel
dw_1 dw_1
end type
global w_l_traduction w_l_traduction

type variables
string	is_champ, is_codes[]
boolean	ib_preselect
end variables

forward prototypes
public subroutine wf_preselect ()
public subroutine wf_setpreselect (any aa_preselect, boolean ab_isarray)
end prototypes

public subroutine wf_preselect ();// sélectionne la liste des codes passée en argument sous forme d'1 array de strings

integer	li_i
long		ll_row

IF NOT ib_preselect THEN 
	return
END IF

FOR li_i = 1 TO upperbound(is_codes)
	ll_row = dw_1.Find("code='" + is_codes[li_i] + "'", 0, dw_1.RowCount())
	IF ll_row > 0 THEN
		dw_1.selectrow(ll_row, true)
		sle_preselect.text = sle_preselect.text + is_codes[li_i] + ","
	END IF
NEXT
sle_preselect.text = LeftA(sle_preselect.text, LenA(sle_preselect.text) - 1)
end subroutine

public subroutine wf_setpreselect (any aa_preselect, boolean ab_isarray);// si il y a une série de codes à présélectionner, elle peut être passée sous forme de string
// où les codes sont séparés par des virgules, ou sous forme d'un array de string.
// Si elle est passée sous forme de string, on la converti ici en array.
// Si elle est déjà passée sous forme d'un array, elle est utilisable directement

IF IsNull(aa_preselect) THEN return

IF ab_IsArray THEN
	is_codes = aa_preselect
ELSE
	f_parse(aa_preselect, ",", is_codes)
END IF

IF upperbound(is_codes) > 0 THEN ib_preselect = TRUE
end subroutine

event ue_postopen;call super::ue_postopen;// lecture
dw_1.retrieve(is_champ)

// présélection ?
wf_preselect()

end event

on w_l_traduction.create
int iCurrent
call super::create
this.sle_preselect=create sle_preselect
this.st_1=create st_1
this.cb_ok=create cb_ok
this.cb_cancel=create cb_cancel
this.dw_1=create dw_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.sle_preselect
this.Control[iCurrent+2]=this.st_1
this.Control[iCurrent+3]=this.cb_ok
this.Control[iCurrent+4]=this.cb_cancel
this.Control[iCurrent+5]=this.dw_1
end on

on w_l_traduction.destroy
call super::destroy
destroy(this.sle_preselect)
destroy(this.st_1)
destroy(this.cb_ok)
destroy(this.cb_cancel)
destroy(this.dw_1)
end on

event ue_closebyxaccepted;cb_cancel.triggerEvent("clicked")
end event

event ue_open;call super::ue_open;str_params	lstr_params
boolean		lb_extended, lb_IsArray

// récupérer les paramètres (valeur de la colonne 'champ', présélection ou pas, sélection étendue ou pas)
// L'argument 'sélection étendue' vient toujours en dernière position
//
// Présélection = une string où les codes sont séparés par des virgules. 
//                Si on veut passer directement un array de string, il faut le spécifier en 
//                passant l'argument TRUE en 2ème position et l'array en 3ème

ib_preselect = FALSE
lstr_params = Message.PowerObjectParm
CHOOSE CASE upperbound(lstr_params.a_param)
	CASE 1
		lb_extended = lstr_params.a_param[1]
	CASE 2
		is_champ = string(lstr_params.a_param[1])
		lb_extended = lstr_params.a_param[2]
	CASE 3
		is_champ = string(lstr_params.a_param[1])
		wf_setpreselect(lstr_params.a_param[2], FALSE)
		lb_extended = lstr_params.a_param[3]
	CASE 4
		is_champ = string(lstr_params.a_param[1])
		lb_IsArray = lstr_params.a_param[2]
		wf_setpreselect(lstr_params.a_param[3], lb_IsArray)
		lb_extended = lstr_params.a_param[4]
END CHOOSE

// assigner les couleurs pour les lignes paires et impaires du DW principal
gu_dwservices.uf_setbrowsecol(dw_1)

// sens du tri=croissant en commençant
gb_sort_asc = true

// autoriser ou pas la sélection de plusieurs code en fonction du paramètre
dw_1.uf_extendedselect(lb_extended)

// même si une présélection est passée en argument, on en fait rien si multiselect pas autorisé
IF NOT lb_extended THEN ib_preselect = FALSE

// champs affichage présélection invisibles si pas de présélection...
IF NOT ib_preselect THEN
	st_1.visible = FALSE
	sle_preselect.visible = FALSE
	dw_1.y = 0
	dw_1.height = dw_1.height + 80
END IF

end event

type sle_preselect from uo_sle within w_l_traduction
integer x = 366
integer width = 1371
integer height = 64
integer textsize = -8
long backcolor = 79741120
string text = ""
boolean displayonly = true
end type

type st_1 from uo_statictext within w_l_traduction
integer x = 18
integer width = 347
string text = "Présélection"
end type

type cb_ok from uo_cb_ok within w_l_traduction
integer x = 384
integer y = 1408
integer width = 347
integer taborder = 20
end type

event clicked;str_params	lstr_params
long 			ll_selrow
integer		li_param

li_param=0
ll_selrow = dw_1.GetSelectedRow(0)

// si multisélection autorisée, renvoyer toutes les rows sélectionnées, sinon renvoyer row en cours
IF dw_1.uf_extendedselect() THEN
	DO WHILE ll_selrow > 0
		li_param++
		lstr_params.a_param[li_param] = dw_1.Object.code[ll_selrow]
		ll_selrow = dw_1.GetSelectedRow(ll_selrow)
	LOOP
ELSE
	li_param++
	lstr_params.a_param[li_param] = dw_1.Object.code[dw_1.GetRow()]
END IF

IF li_param = 0 THEN
	CloseWithReturn(Parent, -1)
ELSE
	CloseWithReturn(Parent, lstr_params)
END IF
end event

type cb_cancel from uo_cb_cancel within w_l_traduction
integer x = 933
integer y = 1408
integer width = 347
integer taborder = 30
string text = "Abandonner"
end type

event clicked;CloseWithReturn(Parent, -1)
end event

type dw_1 from uo_ancestor_dwbrowse within w_l_traduction
integer y = 80
integer width = 1755
integer height = 1280
integer taborder = 10
string dataobject = "d_l_traduction"
boolean vscrollbar = true
boolean border = true
end type

event doubleclicked;call super::doubleclicked;cb_ok.event post clicked()
end event

event clicked;call super::clicked;// après tri ou sélection d'un record, la présélection n'est plus valide donc on l'annule

IF ib_preselect THEN
	ib_preselect = FALSE
	st_1.visible = FALSE
	sle_preselect.visible = FALSE
	dw_1.y = 0
	dw_1.height = dw_1.height + 80
END IF
end event

