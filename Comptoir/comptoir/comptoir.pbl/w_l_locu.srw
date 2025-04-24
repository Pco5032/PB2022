//objectcomments Sélection interlocuteur
forward
global type w_l_locu from w_ancestor
end type
type dw_typelocu from uo_datawindow_singlerow within w_l_locu
end type
type sle_nom from uo_sle within w_l_locu
end type
type st_2 from uo_statictext within w_l_locu
end type
type cb_ok from uo_cb_ok within w_l_locu
end type
type cb_cancel from uo_cb_cancel within w_l_locu
end type
type dw_1 from uo_ancestor_dwbrowse within w_l_locu
end type
end forward

global type w_l_locu from w_ancestor
integer x = 498
integer width = 3758
integer height = 2472
string title = "Sélection d~'un interlocuteur"
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
dw_typelocu dw_typelocu
sle_nom sle_nom
st_2 st_2
cb_ok cb_ok
cb_cancel cb_cancel
dw_1 dw_1
end type
global w_l_locu w_l_locu

type variables

end variables

forward prototypes
public subroutine wf_filtre ()
end prototypes

public subroutine wf_filtre ();// afficher les interlocuteurs du type sélectionné, et tenir compte du filtre sur le nom
string	ls_type, ls_filtre

// filtre sur le type
ls_type = dw_typelocu.object.s_type[1]
IF NOT f_IsEmptyString(ls_type) THEN
	ls_filtre = "type = '" + ls_type + "'"
END IF

// filtre sur le nom
IF NOT f_IsEmptyString(sle_nom.text) THEN
	IF f_IsEmptyString(ls_filtre) THEN
		ls_filtre = "match(upper(interlocuteur), '" + upper(sle_nom.text) + "')"
	ELSE
		ls_filtre = ls_filtre + " and match(upper(interlocuteur), '" + upper(sle_nom.text) + "')"
	END IF
END IF

dw_1.SetFilter(ls_filtre)
dw_1.Filter()
dw_1.Sort()
end subroutine

event ue_postopen;call super::ue_postopen;SetPointer(hourGlass!)
IF dw_1.retrieve() = 0 THEN
	gu_message.uf_info("Aucun interlocuteur enregistré !")
	cb_cancel.event clicked()
	return
END IF

dw_1.SetFocus( )
end event

on w_l_locu.create
int iCurrent
call super::create
this.dw_typelocu=create dw_typelocu
this.sle_nom=create sle_nom
this.st_2=create st_2
this.cb_ok=create cb_ok
this.cb_cancel=create cb_cancel
this.dw_1=create dw_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_typelocu
this.Control[iCurrent+2]=this.sle_nom
this.Control[iCurrent+3]=this.st_2
this.Control[iCurrent+4]=this.cb_ok
this.Control[iCurrent+5]=this.cb_cancel
this.Control[iCurrent+6]=this.dw_1
end on

on w_l_locu.destroy
call super::destroy
destroy(this.dw_typelocu)
destroy(this.sle_nom)
destroy(this.st_2)
destroy(this.cb_ok)
destroy(this.cb_cancel)
destroy(this.dw_1)
end on

event ue_closebyxaccepted;cb_cancel.event clicked()
end event

event ue_open;call super::ue_open;str_params	lstr_params
boolean		lb_extended
string		ls_type, ls_client, ls_sql
datawindowchild	ldwc_dropdown
long			ll_row

// récupérer les paramètres optionnels 	:
// 1. type d'interlocuteur :
//    Attention : on peut avoir plusieurs types autorisés. La liste est fournie sous forme :
//     'type1','type'2,.... (attention aux ' qui entourent chaque item) et dans cette situation 
//		 La DDDW de sélection ne doit contenir que les types voulus.
// 2. uniquement les clients ou tous
// 3. sélection étendue ou pas)
lb_extended = FALSE
lstr_params = Message.PowerObjectParm
IF IsValid(lstr_params) THEN
	CHOOSE CASE upperbound(lstr_params.a_param)
		CASE 1
			lb_extended = lstr_params.a_param[1]
		CASE 2
			ls_type = lstr_params.a_param[1]
			lb_extended = lstr_params.a_param[2]
		CASE 3
			ls_type = lstr_params.a_param[1]
			ls_client = lstr_params.a_param[2]
			lb_extended = lstr_params.a_param[3]
	END CHOOSE
END IF

// référence vers le DDDW
dw_typelocu.GetChild("s_type", ldwc_dropdown)
ldwc_dropdown.settransobject(sqlca)

// seulement les clients ou tous
IF ls_client = "O" THEN
	ls_sql = dw_1.GetSqlSelect()
	ls_sql = f_modifySQL(ls_sql, "interlocuteur.client = 'O'", "", "")
	dw_1.SetSQLSelect(ls_sql)
END IF

// pas de type passé en paramètre :
IF f_IsEmptyString(ls_type) THEN
	// lire la liste de tous les types disponibles
	dw_typelocu.insertrow(0)
ELSE
// un ou plusieurs types passés en paramètre :	
	//	. assigner le(s) type(s) au SELECT pour ne lire que les interlocuteurs correspondant
	ls_sql = dw_1.GetSqlSelect()
	ls_sql = f_modifySQL(ls_sql, "interlocuteur.type in (" + ls_type + ")", "", "")
	dw_1.SetSQLSelect(ls_sql)
	// . lire dans la DDDW le(s) type(s) disponibles en tenant compte des paramètres demandés
	ls_sql = ldwc_dropdown.GetSqlSelect()
	ls_sql = f_modifySQL(ls_sql, "interlocuteur.type in (" + ls_type + ")", "", "")
	ldwc_dropdown.SetSQLSelect(ls_sql)
	// lire la liste des types dans la DDDW
	dw_typelocu.insertrow(0)
END IF

// si un seul type disponible, on le sélectionne et désactive le choix
IF ldwc_dropdown.Rowcount() = 1 THEN
	dw_typelocu.uf_setdefaultvalue(1, "s_type", ldwc_dropdown.getitemstring(1, "code"))
	dw_typelocu.uf_disableData()
	sle_nom.SetFocus()
ELSE
// si plus d'un type disponible :
	// . ajouter le type 'Tous les types' à la liste des types existant
	ll_row = ldwc_dropdown.insertrow(0)
	ldwc_dropdown.setitem(ll_row, "code", "")
	ldwc_dropdown.setitem(ll_row, "trad", "   Tous les types")
	ldwc_dropdown.setitem(ll_row, "ordre", 0)
	ldwc_dropdown.sort()
	// . sélectionner par défaut 'tous les types'
	dw_typelocu.uf_setdefaultvalue(1, "s_type", "")
END IF

// assigner les couleurs pour les lignes paires et impaires du DW principal
gu_dwservices.uf_setbrowsecol(dw_1)

// sens du tri=croissant en commençant
gb_sort_asc = true

// autoriser ou pas la sélection de plusieurs code en fonction du paramètre
dw_1.uf_extendedselect(lb_extended)

end event

type dw_typelocu from uo_datawindow_singlerow within w_l_locu
integer y = 16
integer width = 1481
integer height = 96
integer taborder = 10
string dataobject = "d_choix_typelocu"
end type

event ue_postitemvalidated;call super::ue_postitemvalidated;// changement de type : afficher les interlocuteurs du nouveau type en annulant le filtre sur le nom
sle_nom.text = ""
wf_filtre()
end event

type sle_nom from uo_sle within w_l_locu
event we_changed pbm_enchange
integer x = 1719
integer y = 16
integer width = 677
integer height = 88
integer taborder = 20
integer textsize = -9
end type

event we_changed;wf_filtre()
end event

type st_2 from uo_statictext within w_l_locu
integer x = 1573
integer y = 24
integer width = 146
string text = "Nom"
end type

type cb_ok from uo_cb_ok within w_l_locu
integer x = 1262
integer y = 2240
integer width = 384
end type

event clicked;str_params	lstr_params
long 			ll_selrow
integer		li_param

// si multisélection autorisée, renvoyer toutes les rows sélectionnées, sinon renvoyer row en cours
// attention : on renvoie ou pas le type suivant le paramètre ib_renvoiType passé en paramètre
li_param=0
IF dw_1.uf_extendedselect() THEN
	ll_selrow = dw_1.GetSelectedRow(0)
	DO WHILE ll_selrow > 0
		li_param++
		lstr_params.a_param[li_param] = dw_1.Object.locu[ll_selrow]
		ll_selrow = dw_1.GetSelectedRow(ll_selrow)
	LOOP
ELSE
	ll_selrow = dw_1.GetRow()
	IF ll_selrow > 0 THEN
		li_param++
		lstr_params.a_param[li_param] = dw_1.Object.locu[ll_selrow]
	END IF
END IF

IF li_param = 0 THEN
	CloseWithReturn(Parent, -1)
ELSE
	CloseWithReturn(Parent, lstr_params)
END IF
end event

type cb_cancel from uo_cb_cancel within w_l_locu
integer x = 1902
integer y = 2240
integer width = 384
string text = "Abandonner"
end type

event clicked;CloseWithReturn(Parent, -1)
end event

type dw_1 from uo_ancestor_dwbrowse within w_l_locu
integer y = 112
integer width = 3730
integer height = 2080
integer taborder = 30
string dataobject = "d_l_locu"
boolean hscrollbar = true
boolean vscrollbar = true
boolean border = true
end type

event doubleclicked;call super::doubleclicked;cb_ok.event post clicked()
end event

