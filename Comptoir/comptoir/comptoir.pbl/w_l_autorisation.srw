//objectcomments Sélection autorisation
forward
global type w_l_autorisation from w_ancestor
end type
type dw_nature from uo_datawindow_singlerow within w_l_autorisation
end type
type em_annee from uo_editmask within w_l_autorisation
end type
type st_5 from uo_statictext within w_l_autorisation
end type
type st_2 from uo_statictext within w_l_autorisation
end type
type st_1 from uo_statictext within w_l_autorisation
end type
type cb_ok from uo_cb_ok within w_l_autorisation
end type
type cb_cancel from uo_cb_cancel within w_l_autorisation
end type
type dw_1 from uo_ancestor_dwbrowse within w_l_autorisation
end type
type sle_nomsp from uo_sle within w_l_autorisation
end type
type sle_nomprov from uo_sle within w_l_autorisation
end type
type gb_1 from uo_groupbox within w_l_autorisation
end type
end forward

global type w_l_autorisation from w_ancestor
integer x = 498
integer width = 3515
integer height = 2084
string title = "Sélection d~'une autorisation"
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
dw_nature dw_nature
em_annee em_annee
st_5 st_5
st_2 st_2
st_1 st_1
cb_ok cb_ok
cb_cancel cb_cancel
dw_1 dw_1
sle_nomsp sle_nomsp
sle_nomprov sle_nomprov
gb_1 gb_1
end type
global w_l_autorisation w_l_autorisation

type variables
boolean	ib_renvoiANNEE
end variables

forward prototypes
public subroutine wf_filtre ()
end prototypes

public subroutine wf_filtre ();// afficher les autorisations en fonction des filtres demandés
string	ls_nature, ls_filtre
double	ldb_annee

em_annee.GetData(ldb_annee)

// filtre sur l'année d'autorisation
IF ldb_annee > 0 THEN
	ls_filtre = "match(string(an_aut), '" + string(ldb_annee) + "')"
END IF

// filtre sur la nature du matériel
ls_nature = dw_nature.object.s_natmat[1]
IF NOT f_IsEmptyString(ls_nature) THEN
	IF f_IsEmptyString(ls_filtre) THEN
		ls_filtre = "match(upper(nature_mat), '" + upper(ls_nature) + "')"
	ELSE
		ls_filtre = ls_filtre + " and match(upper(nature_mat), '" + upper(ls_nature) + "')"
	END IF
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

dw_1.SetFilter(ls_filtre)
dw_1.Filter()
dw_1.Sort()
end subroutine

event ue_postopen;call super::ue_postopen;SetPointer(hourGlass!)
dw_1.retrieve()

end event

on w_l_autorisation.create
int iCurrent
call super::create
this.dw_nature=create dw_nature
this.em_annee=create em_annee
this.st_5=create st_5
this.st_2=create st_2
this.st_1=create st_1
this.cb_ok=create cb_ok
this.cb_cancel=create cb_cancel
this.dw_1=create dw_1
this.sle_nomsp=create sle_nomsp
this.sle_nomprov=create sle_nomprov
this.gb_1=create gb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_nature
this.Control[iCurrent+2]=this.em_annee
this.Control[iCurrent+3]=this.st_5
this.Control[iCurrent+4]=this.st_2
this.Control[iCurrent+5]=this.st_1
this.Control[iCurrent+6]=this.cb_ok
this.Control[iCurrent+7]=this.cb_cancel
this.Control[iCurrent+8]=this.dw_1
this.Control[iCurrent+9]=this.sle_nomsp
this.Control[iCurrent+10]=this.sle_nomprov
this.Control[iCurrent+11]=this.gb_1
end on

on w_l_autorisation.destroy
call super::destroy
destroy(this.dw_nature)
destroy(this.em_annee)
destroy(this.st_5)
destroy(this.st_2)
destroy(this.st_1)
destroy(this.cb_ok)
destroy(this.cb_cancel)
destroy(this.dw_1)
destroy(this.sle_nomsp)
destroy(this.sle_nomprov)
destroy(this.gb_1)
end on

event ue_closebyxaccepted;cb_cancel.event clicked()
end event

event ue_open;call super::ue_open;str_params	lstr_params
boolean		lb_extended
string		ls_sql, ls_where
integer		li_annee
long			ll_row
datawindowchild	ldwc_dropdown

lb_extended = FALSE
ib_renvoiANNEE = FALSE

// récupérer les paramètres (année, renvoyer année ou pas, clause where, sélection étendue ou pas)
lstr_params = Message.PowerObjectParm
IF IsValid(lstr_params) THEN 
	CHOOSE CASE upperbound(lstr_params.a_param)
		CASE 0
			lb_extended = FALSE
		CASE 1
			lb_extended = lstr_params.a_param[1]
		CASE 2
			li_annee = integer(lstr_params.a_param[1])
			lb_extended = lstr_params.a_param[2]
		CASE 3
			li_annee = integer(lstr_params.a_param[1])
			ib_renvoiANNEE = lstr_params.a_param[2]
			lb_extended = lstr_params.a_param[3]
		CASE 4
			li_annee = integer(lstr_params.a_param[1])
			ib_renvoiANNEE = lstr_params.a_param[2]
			ls_where = string(lstr_params.a_param[3])
			lb_extended = lstr_params.a_param[4]
	END CHOOSE
END IF

// tenir compte de l'année passée éventuellement en paramètre
IF li_annee > 0 THEN
	ls_sql = dw_1.GetSqlSelect()
	ls_sql = f_modifySQL(ls_sql, "autorisation.an_aut = " + string(li_annee), "", "")
	dw_1.SetSQLSelect(ls_sql)
	em_annee.text = string(li_annee)
	em_annee.enabled = FALSE
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

// lire contenu du dddw nature MFR
dw_nature.insertrow(0)

// ajouter le code 'Toutes' à la liste des natures existant
dw_nature.GetChild("s_natmat", ldwc_dropdown)
ldwc_dropdown.settransobject(sqlca)
ll_row = ldwc_dropdown.insertrow(0)
ldwc_dropdown.setitem(ll_row, "code", "")
ldwc_dropdown.setitem(ll_row, "trad", "   Toutes")
ldwc_dropdown.setitem(ll_row, "ordre", 0)
ldwc_dropdown.sort()
// sélectionner par défaut 'Toutes les natures'
dw_nature.uf_setdefaultvalue(1, "s_natmat", "")

end event

type dw_nature from uo_datawindow_singlerow within w_l_autorisation
integer x = 859
integer y = 64
integer width = 1097
integer height = 96
integer taborder = 20
string dataobject = "d_choix_naturemat"
end type

event ue_postitemvalidated;call super::ue_postitemvalidated;wf_filtre()
end event

type em_annee from uo_editmask within w_l_autorisation
event we_changed pbm_enchange
integer x = 567
integer y = 64
integer width = 201
integer height = 80
integer taborder = 10
integer textsize = -9
alignment alignment = center!
string mask = "####"
end type

event we_changed;IF this <> GetFocus() THEN return

wf_filtre()
end event

type st_5 from uo_statictext within w_l_autorisation
integer x = 37
integer y = 80
integer width = 530
integer textsize = -9
string text = "Année d~'autorisation"
end type

type st_2 from uo_statictext within w_l_autorisation
integer x = 2761
integer y = 80
integer width = 256
integer textsize = -9
string text = "Nom prov."
end type

type st_1 from uo_statictext within w_l_autorisation
integer x = 2048
integer y = 80
integer width = 219
integer textsize = -9
string text = "nom SP"
end type

type cb_ok from uo_cb_ok within w_l_autorisation
integer x = 1225
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
		IF ib_renvoiANNEE THEN
			li_param++
			lstr_params.a_param[li_param] = dw_1.Object.an_aut[ll_selrow]
		END IF
		li_param++
		lstr_params.a_param[li_param] = dw_1.Object.num_aut[ll_selrow]
		ll_selrow = dw_1.GetSelectedRow(ll_selrow)
	LOOP
ELSE
	ll_selrow = dw_1.GetRow()
	IF ll_selrow > 0 THEN
		IF ib_renvoiANNEE THEN
			li_param++
			lstr_params.a_param[li_param] = dw_1.Object.an_aut[ll_selrow]
		END IF
		li_param++
		lstr_params.a_param[li_param] = dw_1.Object.num_aut[ll_selrow]
	END IF
END IF

IF li_param = 0 THEN
	CloseWithReturn(Parent, -1)
ELSE
	CloseWithReturn(Parent, lstr_params)
END IF
end event

type cb_cancel from uo_cb_cancel within w_l_autorisation
integer x = 1865
integer y = 1856
integer width = 384
string text = "Abandonner"
end type

event clicked;CloseWithReturn(Parent, -1)
end event

type dw_1 from uo_ancestor_dwbrowse within w_l_autorisation
integer y = 176
integer width = 3493
integer height = 1648
integer taborder = 50
string dataobject = "d_l_autorisation"
boolean hscrollbar = true
boolean vscrollbar = true
boolean border = true
boolean hsplitscroll = true
end type

event doubleclicked;call super::doubleclicked;cb_ok.event post clicked()
end event

type sle_nomsp from uo_sle within w_l_autorisation
event we_changed pbm_enchange
integer x = 2267
integer y = 64
integer height = 80
integer taborder = 30
boolean bringtotop = true
integer textsize = -9
end type

event we_changed;IF this <> GetFocus() THEN return

sle_nomprov.text = ""
wf_filtre()
end event

type sle_nomprov from uo_sle within w_l_autorisation
event we_changed pbm_enchange
integer x = 3035
integer y = 64
integer height = 80
integer taborder = 40
boolean bringtotop = true
integer textsize = -9
end type

event we_changed;IF this <> GetFocus() THEN return

sle_nomsp.text = ""
wf_filtre()
end event

type gb_1 from uo_groupbox within w_l_autorisation
integer width = 3493
integer height = 176
integer textsize = -9
integer weight = 700
long textcolor = 8388608
string text = "Filtre..."
end type

