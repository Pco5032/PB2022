//objectcomments Sélection certificat maître
forward
global type w_l_certificat from w_ancestor
end type
type sle_regmb from uo_sle within w_l_certificat
end type
type st_3 from uo_statictext within w_l_certificat
end type
type sle_nomprov from uo_sle within w_l_certificat
end type
type st_2 from uo_statictext within w_l_certificat
end type
type sle_nomsp from uo_sle within w_l_certificat
end type
type st_1 from uo_statictext within w_l_certificat
end type
type dw_typemfr from uo_datawindow_singlerow within w_l_certificat
end type
type cb_ok from uo_cb_ok within w_l_certificat
end type
type cb_cancel from uo_cb_cancel within w_l_certificat
end type
type dw_1 from uo_ancestor_dwbrowse within w_l_certificat
end type
type gb_1 from uo_groupbox within w_l_certificat
end type
end forward

global type w_l_certificat from w_ancestor
integer x = 498
integer width = 3511
integer height = 2084
string title = "Sélection d~'un certificat maître"
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
sle_regmb sle_regmb
st_3 st_3
sle_nomprov sle_nomprov
st_2 st_2
sle_nomsp sle_nomsp
st_1 st_1
dw_typemfr dw_typemfr
cb_ok cb_ok
cb_cancel cb_cancel
dw_1 dw_1
gb_1 gb_1
end type
global w_l_certificat w_l_certificat

type variables

end variables

forward prototypes
public subroutine wf_filtre ()
end prototypes

public subroutine wf_filtre ();// afficher les certificats correspondant au filtre demandé
string	ls_typemfr, ls_filtre

// filtre sur le type
ls_typemfr = dw_typemfr.object.s_typemfr[1]
IF NOT f_IsEmptyString(ls_typemfr) THEN
	ls_filtre = "certificat_type_mfr = '" + ls_typemfr + "'"
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

event ue_postopen;call super::ue_postopen;SetPointer(hourGlass!)
dw_1.retrieve()

end event

on w_l_certificat.create
int iCurrent
call super::create
this.sle_regmb=create sle_regmb
this.st_3=create st_3
this.sle_nomprov=create sle_nomprov
this.st_2=create st_2
this.sle_nomsp=create sle_nomsp
this.st_1=create st_1
this.dw_typemfr=create dw_typemfr
this.cb_ok=create cb_ok
this.cb_cancel=create cb_cancel
this.dw_1=create dw_1
this.gb_1=create gb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.sle_regmb
this.Control[iCurrent+2]=this.st_3
this.Control[iCurrent+3]=this.sle_nomprov
this.Control[iCurrent+4]=this.st_2
this.Control[iCurrent+5]=this.sle_nomsp
this.Control[iCurrent+6]=this.st_1
this.Control[iCurrent+7]=this.dw_typemfr
this.Control[iCurrent+8]=this.cb_ok
this.Control[iCurrent+9]=this.cb_cancel
this.Control[iCurrent+10]=this.dw_1
this.Control[iCurrent+11]=this.gb_1
end on

on w_l_certificat.destroy
call super::destroy
destroy(this.sle_regmb)
destroy(this.st_3)
destroy(this.sle_nomprov)
destroy(this.st_2)
destroy(this.sle_nomsp)
destroy(this.st_1)
destroy(this.dw_typemfr)
destroy(this.cb_ok)
destroy(this.cb_cancel)
destroy(this.dw_1)
destroy(this.gb_1)
end on

event ue_closebyxaccepted;cb_cancel.event clicked()
end event

event ue_open;call super::ue_open;str_params	lstr_params
boolean		lb_extended
long			ll_row
string		ls_typemfr, ls_where, ls_sql
datawindowchild	ldwc_dropdown

// récupérer le paramètre optionnel : sélection étendue ou pas, type de certificat (null=tous, 1, 2 ou 3), clause where
lb_extended = FALSE
lstr_params = Message.PowerObjectParm
IF IsValid(lstr_params) THEN
	CHOOSE CASE upperbound(lstr_params.a_param)
		CASE 1
			lb_extended = lstr_params.a_param[1]
		CASE 2
			ls_typemfr = string(lstr_params.a_param[1])
			lb_extended = lstr_params.a_param[2]
		CASE 3
			ls_typemfr = string(lstr_params.a_param[1])
			ls_where = string(lstr_params.a_param[2])
			lb_extended = lstr_params.a_param[3]
	END CHOOSE
END IF

// référence vers le DDDW
dw_typemfr.GetChild("s_typemfr", ldwc_dropdown)
ldwc_dropdown.settransobject(sqlca)

// lire la liste des types disponibles
dw_typemfr.insertrow(0)

// pas de type passé en paramètre :
IF f_IsEmptyString(ls_typemfr) THEN
	// ajouter le type 'Tous les types' à la liste des types existant
	ll_row = ldwc_dropdown.insertrow(0)
	ldwc_dropdown.setitem(ll_row, "code", "")
	ldwc_dropdown.setitem(ll_row, "liblong", "   Tous les types")
	ldwc_dropdown.setitem(ll_row, "ordre", 0)
	ldwc_dropdown.sort()
	// . sélectionner par défaut 'tous les types'
	dw_typemfr.uf_setdefaultvalue(1, "s_typemfr", "")
ELSE
	// un type passé en paramètre :	
	//	. assigner le type au SELECT pour ne lire que les certificats correspondant
	ls_sql = dw_1.GetSqlSelect()
	ls_sql = f_modifySQL(ls_sql, "certificat.type_mfr = '" + ls_typemfr + "'", "", "")
	dw_1.SetSQLSelect(ls_sql)
	// . sélectionner le type et désactiver le choix
	dw_typemfr.uf_setdefaultvalue(1, "s_typemfr", ls_typemfr)
	dw_typemfr.uf_disableData()
END IF

// appliquer la clause where éventuelle
IF NOT f_IsEmptyString(ls_where) THEN
	ls_sql = dw_1.GetSqlSelect()
	ls_sql = f_modifySQL(ls_sql, ls_where, "", "")
	dw_1.SetSQLSelect(ls_sql)
END IF


// assigner les couleurs pour les lignes paires et impaires du DW principal
gu_dwservices.uf_setbrowsecol(dw_1)

// sens du tri=croissant en commençant
gb_sort_asc = true

// autoriser ou pas la sélection de plusieurs code en fonction du paramètre
dw_1.uf_extendedselect(lb_extended)
end event

event resize;call super::resize;dw_1.width = newwidth
end event

type sle_regmb from uo_sle within w_l_certificat
event we_changed pbm_enchange
integer x = 3054
integer y = 64
integer height = 80
integer taborder = 40
boolean bringtotop = true
integer textsize = -9
end type

event we_changed;IF this <> GetFocus() THEN return

sle_nomsp.text = ""
sle_nomprov.text = ""
wf_filtre()
end event

type st_3 from uo_statictext within w_l_certificat
integer x = 2743
integer y = 80
integer width = 311
integer textsize = -9
string text = "Réf.reg. MB"
end type

type sle_nomprov from uo_sle within w_l_certificat
event we_changed pbm_enchange
integer x = 2286
integer y = 64
integer height = 80
integer taborder = 30
boolean bringtotop = true
integer textsize = -9
end type

event we_changed;IF this <> GetFocus() THEN return

sle_nomsp.text = ""
sle_regmb.text = ""
wf_filtre()
end event

type st_2 from uo_statictext within w_l_certificat
integer x = 2011
integer y = 80
integer width = 256
integer textsize = -9
string text = "Nom prov."
end type

type sle_nomsp from uo_sle within w_l_certificat
event we_changed pbm_enchange
integer x = 1573
integer y = 64
integer height = 80
integer taborder = 20
boolean bringtotop = true
integer textsize = -9
end type

event we_changed;IF this <> GetFocus() THEN return

sle_nomprov.text = ""
sle_regmb.text = ""
wf_filtre()
end event

type st_1 from uo_statictext within w_l_certificat
integer x = 1353
integer y = 80
integer width = 219
integer textsize = -9
string text = "Nom SP"
end type

type dw_typemfr from uo_datawindow_singlerow within w_l_certificat
integer x = 18
integer y = 64
integer width = 1298
integer height = 80
integer taborder = 10
string dataobject = "d_typemfr"
end type

event ue_postitemvalidated;call super::ue_postitemvalidated;// changement de type : afficher les certificats du nouveau type
wf_filtre()
end event

type cb_ok from uo_cb_ok within w_l_certificat
integer x = 1152
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
		lstr_params.a_param[li_param] = dw_1.Object.num_cm[ll_selrow]
		ll_selrow = dw_1.GetSelectedRow(ll_selrow)
	LOOP
ELSE
	ll_selrow = dw_1.GetRow()
	IF ll_selrow > 0 THEN
		li_param++
		lstr_params.a_param[li_param] = dw_1.Object.num_cm[ll_selrow]
	END IF
END IF

IF li_param = 0 THEN
	CloseWithReturn(Parent, -1)
ELSE
	CloseWithReturn(Parent, lstr_params)
END IF
end event

type cb_cancel from uo_cb_cancel within w_l_certificat
integer x = 1847
integer y = 1856
integer width = 384
string text = "Abandonner"
end type

event clicked;CloseWithReturn(Parent, -1)
end event

type dw_1 from uo_ancestor_dwbrowse within w_l_certificat
integer y = 176
integer width = 3493
integer height = 1648
integer taborder = 50
string dataobject = "d_l_certificat"
boolean hscrollbar = true
boolean vscrollbar = true
boolean border = true
boolean hsplitscroll = true
end type

event doubleclicked;call super::doubleclicked;cb_ok.event post clicked()
end event

type gb_1 from uo_groupbox within w_l_certificat
integer width = 3493
integer height = 176
integer textsize = -9
integer weight = 700
long textcolor = 8388608
string text = "Filtre..."
end type

