//objectcomments Sélection d'un lot dans le registre des graines
forward
global type w_l_registre from w_ancestor
end type
type dw_typegraine from uo_datawindow_singlerow within w_l_registre
end type
type sle_nomsp from uo_sle within w_l_registre
end type
type sle_regmb from uo_sle within w_l_registre
end type
type st_3 from uo_statictext within w_l_registre
end type
type sle_nomprov from uo_sle within w_l_registre
end type
type st_2 from uo_statictext within w_l_registre
end type
type st_1 from uo_statictext within w_l_registre
end type
type cb_ok from uo_cb_ok within w_l_registre
end type
type cb_cancel from uo_cb_cancel within w_l_registre
end type
type dw_1 from uo_ancestor_dwbrowse within w_l_registre
end type
type gb_1 from uo_groupbox within w_l_registre
end type
end forward

global type w_l_registre from w_ancestor
integer width = 3511
integer height = 2080
string title = "Sélection d~'un lot dans le registre des graines"
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
dw_typegraine dw_typegraine
sle_nomsp sle_nomsp
sle_regmb sle_regmb
st_3 st_3
sle_nomprov sle_nomprov
st_2 st_2
st_1 st_1
cb_ok cb_ok
cb_cancel cb_cancel
dw_1 dw_1
gb_1 gb_1
end type
global w_l_registre w_l_registre

forward prototypes
public subroutine wf_filtre ()
end prototypes

public subroutine wf_filtre ();// afficher les lots correspondant au filtre demandé
string	ls_filtre, ls_type

// filtre sur le type de graine
ls_type = dw_typegraine.object.s_type[1]
IF NOT f_IsEmptyString(ls_type) THEN
	ls_filtre = "type_graine = '" + upper(ls_type) + "'"
END IF

// filtre sur le nom de l'espèce
IF NOT f_IsEmptyString(sle_nomsp.text) THEN
	IF f_IsEmptyString(ls_filtre) THEN
		ls_filtre = "match(upper(espece_nom_fr), '" + upper(sle_nomsp.text) + "')"
	ELSE
		ls_filtre = ls_filtre + " and match(upper(espece_nom_fr), '" + upper(sle_nomsp.text) + "')"
	END IF
END IF

// filtre sur le nom de la provenance
IF NOT f_IsEmptyString(sle_nomprov.text) THEN
	IF f_IsEmptyString(ls_filtre) THEN
		ls_filtre = "match(upper(provenance_nom), '" + upper(sle_nomprov.text) + "')"
	ELSE
		ls_filtre = ls_filtre + " and match(upper(provenance_nom), '" + upper(sle_nomprov.text) + "')"
	END IF
END IF

// filtre sur la référence registre MB
IF NOT f_IsEmptyString(sle_regmb.text) THEN
	IF f_IsEmptyString(ls_filtre) THEN
		ls_filtre = "match(upper(provenance_code_prov), '" + upper(sle_regmb.text) + "')"
	ELSE
		ls_filtre = ls_filtre + " and match(upper(provenance_code_prov), '" + upper(sle_regmb.text) + "')"
	END IF
END IF

dw_1.SetFilter(ls_filtre)
dw_1.Filter()
dw_1.Sort()
end subroutine

on w_l_registre.create
int iCurrent
call super::create
this.dw_typegraine=create dw_typegraine
this.sle_nomsp=create sle_nomsp
this.sle_regmb=create sle_regmb
this.st_3=create st_3
this.sle_nomprov=create sle_nomprov
this.st_2=create st_2
this.st_1=create st_1
this.cb_ok=create cb_ok
this.cb_cancel=create cb_cancel
this.dw_1=create dw_1
this.gb_1=create gb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_typegraine
this.Control[iCurrent+2]=this.sle_nomsp
this.Control[iCurrent+3]=this.sle_regmb
this.Control[iCurrent+4]=this.st_3
this.Control[iCurrent+5]=this.sle_nomprov
this.Control[iCurrent+6]=this.st_2
this.Control[iCurrent+7]=this.st_1
this.Control[iCurrent+8]=this.cb_ok
this.Control[iCurrent+9]=this.cb_cancel
this.Control[iCurrent+10]=this.dw_1
this.Control[iCurrent+11]=this.gb_1
end on

on w_l_registre.destroy
call super::destroy
destroy(this.dw_typegraine)
destroy(this.sle_nomsp)
destroy(this.sle_regmb)
destroy(this.st_3)
destroy(this.sle_nomprov)
destroy(this.st_2)
destroy(this.st_1)
destroy(this.cb_ok)
destroy(this.cb_cancel)
destroy(this.dw_1)
destroy(this.gb_1)
end on

event resize;call super::resize;dw_1.width = newwidth
end event

event ue_closebyxaccepted;call super::ue_closebyxaccepted;cb_cancel.Event clicked()
end event

event ue_open;call super::ue_open;str_params	lstr_params
boolean		lb_extended
string		ls_sql, ls_where
datawindowchild	ldwc_dropdown
long			ll_row

// récupérer les paramètres (clause where particulière, sélection étendue ou pas)
lstr_params = Message.PowerObjectParm

lb_extended = FALSE

IF IsValid(lstr_params) THEN 
	CHOOSE CASE upperbound(lstr_params.a_param)
		CASE 0
			lb_extended = FALSE
		CASE 1
			lb_extended = lstr_params.a_param[1]
		CASE 2
			ls_where = lstr_params.a_param[1]
			lb_extended = lstr_params.a_param[2]
	END CHOOSE
END IF

IF NOT f_IsEmptyString(ls_where) THEN
	ls_sql = f_modifySql(dw_1.GetSQLSelect(), ls_where, "", "")
	dw_1.SetSQLSelect(ls_sql)
END IF

// assigner les couleurs pour les lignes paires et impaires du DW principal
gu_dwservices.uf_setbrowsecol(dw_1)

// sens du tri=croissant en commençant
gb_sort_asc = true

// autoriser ou pas la sélection de plusieurs code en fonction du paramètre
dw_1.uf_extendedselect(lb_extended)

// types de graine
dw_typegraine.insertRow(0)

// référence vers le DDDW de choix du type de graine
dw_typegraine.GetChild("s_type", ldwc_dropdown)
ldwc_dropdown.settransobject(sqlca)

// ajouter le type 'Tous les types' à la liste des types existant
ll_row = ldwc_dropdown.insertrow(0)
ldwc_dropdown.setitem(ll_row, "code", "")
ldwc_dropdown.setitem(ll_row, "trad", "Tous les types")
ldwc_dropdown.setitem(ll_row, "ordre", 0)
ldwc_dropdown.sort()
// sélectionner par défaut 'tous les types'
dw_typegraine.uf_setdefaultvalue(1, "s_type", "")


end event

event ue_postopen;call super::ue_postopen;dw_1.retrieve()

end event

type dw_typegraine from uo_datawindow_singlerow within w_l_registre
integer x = 165
integer y = 64
integer width = 1042
integer height = 96
integer taborder = 40
string dataobject = "d_choix_typegraine"
end type

event ue_postitemvalidated;call super::ue_postitemvalidated;wf_filtre()
end event

type sle_nomsp from uo_sle within w_l_registre
event we_changed pbm_enchange
integer x = 1463
integer y = 64
integer height = 80
integer taborder = 30
boolean bringtotop = true
integer textsize = -9
end type

event we_changed;IF this <> GetFocus() THEN return

sle_nomprov.text = ""
sle_regmb.text = ""
wf_filtre()
end event

type sle_regmb from uo_sle within w_l_registre
event we_changed pbm_enchange
integer x = 2944
integer y = 64
integer height = 80
integer taborder = 50
boolean bringtotop = true
integer textsize = -9
end type

event we_changed;IF this <> GetFocus() THEN return

sle_nomsp.text = ""
sle_nomprov.text = ""
wf_filtre()
end event

type st_3 from uo_statictext within w_l_registre
integer x = 2633
integer y = 80
integer width = 311
integer textsize = -9
string text = "Réf.reg. MB"
end type

type sle_nomprov from uo_sle within w_l_registre
event we_changed pbm_enchange
integer x = 2176
integer y = 64
integer height = 80
integer taborder = 40
boolean bringtotop = true
integer textsize = -9
end type

event we_changed;IF this <> GetFocus() THEN return

sle_nomsp.text = ""
sle_regmb.text = ""
wf_filtre()
end event

type st_2 from uo_statictext within w_l_registre
integer x = 1902
integer y = 80
integer width = 256
integer textsize = -9
string text = "Nom prov."
end type

type st_1 from uo_statictext within w_l_registre
integer x = 1243
integer y = 80
integer width = 219
integer textsize = -9
string text = "Nom SP"
end type

type cb_ok from uo_cb_ok within w_l_registre
integer x = 1152
integer y = 1856
end type

event clicked;call super::clicked;// renvoyer info de la (ou des) row(s) sélectionnée(s)
integer	li_param
long		ll_selrow
str_params	lstr_params

li_param=0

IF dw_1.uf_extendedselect() THEN
	ll_selrow = dw_1.GetSelectedRow(0)
	DO WHILE ll_selrow > 0
		li_param++
		lstr_params.a_param[li_param] = dw_1.Object.ref_lot[ll_selrow]
		ll_selrow = dw_1.GetSelectedRow(ll_selrow)
	LOOP
ELSE
	ll_selrow = dw_1.GetRow()
	IF ll_selrow > 0 THEN
		li_param++
		lstr_params.a_param[li_param] = dw_1.Object.ref_lot[ll_selrow]
	END IF
END IF

IF li_param = 0 THEN
	CloseWithReturn(Parent, -1)
ELSE
	CloseWithReturn(Parent, lstr_params)
END IF

end event

type cb_cancel from uo_cb_cancel within w_l_registre
integer x = 1829
integer y = 1856
end type

event clicked;call super::clicked;CloseWithReturn(Parent, -1)
end event

type dw_1 from uo_ancestor_dwbrowse within w_l_registre
integer y = 176
integer width = 3493
integer height = 1648
integer taborder = 10
string dataobject = "d_l_registre"
boolean hscrollbar = true
boolean vscrollbar = true
boolean border = true
boolean hsplitscroll = true
end type

event doubleclicked;call super::doubleclicked;cb_ok.event post clicked()
end event

event clicked;call super::clicked;// si click sur SP : tri sur SP/année
// si click sur année : tri sur année/SP
IF dwo.Type = "text" THEN
	IF dwo.name = "dt_t" THEN
		IF gb_sort_asc THEN
			gu_dwservices.uf_sort(this, "dt_creation A, code_sp A")
			IF NOT this.uf_autoselectrow() THEN this.selectrow(row, FALSE)
		ELSE
			gu_dwservices.uf_sort(this,"dt_creation D, code_sp D")
			IF NOT this.uf_autoselectrow() THEN this.selectrow(row, FALSE)
		END IF
	ELSEIF dwo.name = "sp_t" THEN
		IF gb_sort_asc THEN
			gu_dwservices.uf_sort(this,"code_sp A, dt_creation A")
			IF NOT this.uf_autoselectrow() THEN this.selectrow(row, FALSE)
		ELSE
			gu_dwservices.uf_sort(this,"code_sp D, dt_creation D")
			IF NOT this.uf_autoselectrow() THEN this.selectrow(row, FALSE)
		END IF
	END IF
END IF

end event

type gb_1 from uo_groupbox within w_l_registre
integer width = 3493
integer height = 176
integer textsize = -9
integer weight = 700
long textcolor = 8388608
string text = "Filtre..."
end type

