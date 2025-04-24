//objectcomments Sélection espèce Comptoir
forward
global type w_l_espece from w_ancestor
end type
type sle_nomlat from uo_sle within w_l_espece
end type
type st_1 from uo_statictext within w_l_espece
end type
type sle_nomfr from uo_sle within w_l_espece
end type
type cb_ok from uo_cb_ok within w_l_espece
end type
type cb_cancel from uo_cb_cancel within w_l_espece
end type
type dw_1 from uo_ancestor_dwbrowse within w_l_espece
end type
end forward

global type w_l_espece from w_ancestor
integer x = 498
integer width = 2491
integer height = 2084
string title = "Sélection d~'une espèce"
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
sle_nomlat sle_nomlat
st_1 st_1
sle_nomfr sle_nomfr
cb_ok cb_ok
cb_cancel cb_cancel
dw_1 dw_1
end type
global w_l_espece w_l_espece

type variables

end variables

forward prototypes
public subroutine wf_filtre ()
end prototypes

public subroutine wf_filtre ();// afficher les régions en fonction des filtres demandés
string	ls_filtre

// filtre sur le nom français
IF NOT f_IsEmptyString(sle_nomfr.text) THEN
	IF f_IsEmptyString(ls_filtre) THEN
		ls_filtre = "match(upper(nom_fr), '" + upper(sle_nomfr.text) + "')"
	ELSE
		ls_filtre = ls_filtre + " and match(upper(nom_fr), '" + upper(sle_nomfr.text) + "')"
	END IF
END IF

// filtre sur le nom latin
IF NOT f_IsEmptyString(sle_nomlat.text) THEN
	IF f_IsEmptyString(ls_filtre) THEN
		ls_filtre = "match(upper(nom_lat), '" + upper(sle_nomlat.text) + "')"
	ELSE
		ls_filtre = ls_filtre + " and match(upper(nom_lat), '" + upper(sle_nomlat.text) + "')"
	END IF
END IF

dw_1.SetFilter(ls_filtre)
dw_1.Filter()
dw_1.Sort()
end subroutine

event ue_postopen;call super::ue_postopen;SetPointer(hourGlass!)
dw_1.retrieve()

end event

on w_l_espece.create
int iCurrent
call super::create
this.sle_nomlat=create sle_nomlat
this.st_1=create st_1
this.sle_nomfr=create sle_nomfr
this.cb_ok=create cb_ok
this.cb_cancel=create cb_cancel
this.dw_1=create dw_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.sle_nomlat
this.Control[iCurrent+2]=this.st_1
this.Control[iCurrent+3]=this.sle_nomfr
this.Control[iCurrent+4]=this.cb_ok
this.Control[iCurrent+5]=this.cb_cancel
this.Control[iCurrent+6]=this.dw_1
end on

on w_l_espece.destroy
call super::destroy
destroy(this.sle_nomlat)
destroy(this.st_1)
destroy(this.sle_nomfr)
destroy(this.cb_ok)
destroy(this.cb_cancel)
destroy(this.dw_1)
end on

event ue_closebyxaccepted;cb_cancel.event clicked()
end event

event ue_open;call super::ue_open;str_params	lstr_params
boolean		lb_extended
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

// assigner les couleurs pour les lignes paires et impaires du DW principal
gu_dwservices.uf_setbrowsecol(dw_1)

// sens du tri=croissant en commençant
gb_sort_asc = true

// autoriser ou pas la sélection de plusieurs code en fonction du paramètre
dw_1.uf_extendedselect(lb_extended)

end event

type sle_nomlat from uo_sle within w_l_espece
event we_changed pbm_enchange
integer x = 1079
integer y = 16
integer width = 859
integer height = 80
integer taborder = 20
integer textsize = -9
end type

event we_changed;IF this <> GetFocus() THEN return

sle_nomfr.text = ""
wf_filtre()
end event

type st_1 from uo_statictext within w_l_espece
integer x = 55
integer y = 28
integer width = 146
string text = "Filtre"
end type

type sle_nomfr from uo_sle within w_l_espece
event we_changed pbm_enchange
integer x = 219
integer y = 16
integer width = 859
integer height = 80
integer taborder = 10
integer textsize = -9
end type

event we_changed;IF this <> GetFocus() THEN return

sle_nomlat.text = ""
wf_filtre()
end event

type cb_ok from uo_cb_ok within w_l_espece
integer x = 713
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
		lstr_params.a_param[li_param] = dw_1.Object.code_sp[ll_selrow]
		ll_selrow = dw_1.GetSelectedRow(ll_selrow)
	LOOP
ELSE
	ll_selrow = dw_1.GetRow()
	IF ll_selrow > 0 THEN
		li_param++
		lstr_params.a_param[li_param] = dw_1.Object.code_sp[ll_selrow]
	END IF
END IF

IF li_param = 0 THEN
	CloseWithReturn(Parent, -1)
ELSE
	CloseWithReturn(Parent, lstr_params)
END IF
end event

type cb_cancel from uo_cb_cancel within w_l_espece
integer x = 1353
integer y = 1856
integer width = 384
string text = "Abandonner"
end type

event clicked;CloseWithReturn(Parent, -1)
end event

type dw_1 from uo_ancestor_dwbrowse within w_l_espece
integer y = 112
integer width = 2469
integer height = 1712
integer taborder = 30
string dataobject = "d_l_espece"
boolean vscrollbar = true
boolean border = true
end type

event doubleclicked;call super::doubleclicked;cb_ok.event post clicked()
end event

