//objectcomments Sélection région de provenance
forward
global type w_l_regprov from w_ancestor
end type
type st_2 from uo_statictext within w_l_regprov
end type
type sle_origine from uo_sle within w_l_regprov
end type
type st_1 from uo_statictext within w_l_regprov
end type
type dw_pays from uo_datawindow_singlerow within w_l_regprov
end type
type sle_nom from uo_sle within w_l_regprov
end type
type cb_ok from uo_cb_ok within w_l_regprov
end type
type cb_cancel from uo_cb_cancel within w_l_regprov
end type
type dw_1 from uo_ancestor_dwbrowse within w_l_regprov
end type
end forward

global type w_l_regprov from w_ancestor
integer x = 498
integer width = 3168
integer height = 2084
string title = "Sélection d~'une région de provenance"
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
st_2 st_2
sle_origine sle_origine
st_1 st_1
dw_pays dw_pays
sle_nom sle_nom
cb_ok cb_ok
cb_cancel cb_cancel
dw_1 dw_1
end type
global w_l_regprov w_l_regprov

type variables

end variables

forward prototypes
public subroutine wf_filtre ()
end prototypes

public subroutine wf_filtre ();// afficher les régions en fonction des filtres demandés
string	ls_pays, ls_filtre

// filtre sur le pays
ls_pays = dw_pays.object.s_pays[1]
IF NOT f_IsEmptyString(ls_pays) THEN
	ls_filtre = "region_prov_pays = '" + ls_pays + "'"
END IF

// filtre sur le nom
IF NOT f_IsEmptyString(sle_nom.text) THEN
	IF f_IsEmptyString(ls_filtre) THEN
		ls_filtre = "match(upper(region_prov_nom), '" + upper(sle_nom.text) + "')"
	ELSE
		ls_filtre = ls_filtre + " and match(upper(region_prov_nom), '" + upper(sle_nom.text) + "')"
	END IF
END IF

// filtre sur le code d'origine
IF NOT f_IsEmptyString(sle_origine.text) THEN
	IF f_IsEmptyString(ls_filtre) THEN
		ls_filtre = "match(upper(region_prov_code_regprov), '" + upper(sle_origine.text) + "')"
	ELSE
		ls_filtre = ls_filtre + " and match(upper(region_prov_code_regprov), '" + upper(sle_origine.text) + "')"
	END IF
END IF

dw_1.SetFilter(ls_filtre)
dw_1.Filter()
dw_1.Sort()
end subroutine

event ue_postopen;call super::ue_postopen;SetPointer(hourGlass!)
dw_1.retrieve()

end event

on w_l_regprov.create
int iCurrent
call super::create
this.st_2=create st_2
this.sle_origine=create sle_origine
this.st_1=create st_1
this.dw_pays=create dw_pays
this.sle_nom=create sle_nom
this.cb_ok=create cb_ok
this.cb_cancel=create cb_cancel
this.dw_1=create dw_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.st_2
this.Control[iCurrent+2]=this.sle_origine
this.Control[iCurrent+3]=this.st_1
this.Control[iCurrent+4]=this.dw_pays
this.Control[iCurrent+5]=this.sle_nom
this.Control[iCurrent+6]=this.cb_ok
this.Control[iCurrent+7]=this.cb_cancel
this.Control[iCurrent+8]=this.dw_1
end on

on w_l_regprov.destroy
call super::destroy
destroy(this.st_2)
destroy(this.sle_origine)
destroy(this.st_1)
destroy(this.dw_pays)
destroy(this.sle_nom)
destroy(this.cb_ok)
destroy(this.cb_cancel)
destroy(this.dw_1)
end on

event ue_closebyxaccepted;cb_cancel.event clicked()
end event

event ue_open;call super::ue_open;str_params	lstr_params
boolean		lb_extended
datawindowchild	ldwc_dropdown
long			ll_row

// récupérer le paramètre optionnel : sélection étendue ou pas
lb_extended = FALSE
lstr_params = Message.PowerObjectParm
IF IsValid(lstr_params) THEN
	CHOOSE CASE upperbound(lstr_params.a_param)
		CASE 1
			lb_extended = lstr_params.a_param[1]
	END CHOOSE
END IF

// lire les pays disponibles
dw_pays.insertRow(0)
// ajouter le code 'Tous les pays' à la liste des pays existant
dw_pays.GetChild("s_pays", ldwc_dropdown)
ldwc_dropdown.settransobject(sqlca)
ll_row = ldwc_dropdown.insertrow(0)
ldwc_dropdown.setitem(ll_row, "code", "")
ldwc_dropdown.setitem(ll_row, "trad", "   Tous les pays")
ldwc_dropdown.setitem(ll_row, "ordre", 0)
ldwc_dropdown.sort()
// sélectionner par défaut 'tous les pays'
dw_pays.uf_setdefaultvalue(1, "s_pays", "")

// assigner les couleurs pour les lignes paires et impaires du DW principal
gu_dwservices.uf_setbrowsecol(dw_1)

// sens du tri=croissant en commençant
gb_sort_asc = true

// autoriser ou pas la sélection de plusieurs code en fonction du paramètre
dw_1.uf_extendedselect(lb_extended)

end event

type st_2 from uo_statictext within w_l_regprov
integer x = 603
integer y = 28
integer width = 146
string text = "Nom"
end type

type sle_origine from uo_sle within w_l_regprov
event we_changed pbm_enchange
integer x = 219
integer y = 16
integer width = 329
integer height = 88
integer taborder = 10
integer textsize = -9
end type

event we_changed;IF this <> GetFocus() THEN return

sle_nom.text = ""
wf_filtre()
end event

type st_1 from uo_statictext within w_l_regprov
integer x = 128
integer y = 28
integer width = 91
string text = "Cd"
end type

type dw_pays from uo_datawindow_singlerow within w_l_regprov
integer x = 1810
integer y = 16
integer width = 1097
integer height = 96
integer taborder = 30
string dataobject = "d_choix_pays"
end type

event ue_postitemvalidated;call super::ue_postitemvalidated;// changement de pays : afficher les provenances du pays choisi et annuler les autres filtres
sle_nom.text = ""
sle_origine.text = ""
wf_filtre()
end event

type sle_nom from uo_sle within w_l_regprov
event we_changed pbm_enchange
integer x = 750
integer y = 16
integer width = 1042
integer height = 88
integer taborder = 20
integer textsize = -9
end type

event we_changed;IF this <> GetFocus() THEN return

sle_origine.text = ""
wf_filtre()
end event

type cb_ok from uo_cb_ok within w_l_regprov
integer x = 1042
integer y = 1856
integer width = 384
end type

event clicked;str_params	lstr_params
long 			ll_selrow
integer		li_param

// si multisélection autorisée, renvoyer toutes les rows sélectionnées, sinon renvoyer row en cours
li_param=0
IF dw_1.uf_extendedselect() THEN
	ll_selrow = dw_1.GetSelectedRow(0)
	DO WHILE ll_selrow > 0
		li_param++
		lstr_params.a_param[li_param] = dw_1.Object.region_prov_num_regprov[ll_selrow]
		ll_selrow = dw_1.GetSelectedRow(ll_selrow)
	LOOP
ELSE
	ll_selrow = dw_1.GetRow()
	IF ll_selrow > 0 THEN
		li_param++
		lstr_params.a_param[li_param] = dw_1.Object.region_prov_num_regprov[ll_selrow]
	END IF
END IF

IF li_param = 0 THEN
	CloseWithReturn(Parent, -1)
ELSE
	CloseWithReturn(Parent, lstr_params)
END IF
end event

type cb_cancel from uo_cb_cancel within w_l_regprov
integer x = 1682
integer y = 1856
integer width = 384
string text = "Abandonner"
end type

event clicked;CloseWithReturn(Parent, -1)
end event

type dw_1 from uo_ancestor_dwbrowse within w_l_regprov
integer y = 112
integer width = 3145
integer height = 1712
integer taborder = 40
string dataobject = "d_l_regprov"
boolean vscrollbar = true
boolean border = true
end type

event doubleclicked;call super::doubleclicked;cb_ok.event post clicked()
end event

