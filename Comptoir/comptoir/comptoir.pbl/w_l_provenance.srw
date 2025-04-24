//objectcomments Sélection provenance
forward
global type w_l_provenance from w_ancestor
end type
type sle_region from uo_sle within w_l_provenance
end type
type st_8 from uo_statictext within w_l_provenance
end type
type sle_pays from uo_sle within w_l_provenance
end type
type st_7 from uo_statictext within w_l_provenance
end type
type rb_listemb_n from uo_radiobutton within w_l_provenance
end type
type rb_listemb_o from uo_radiobutton within w_l_provenance
end type
type st_6 from uo_statictext within w_l_provenance
end type
type rb_provrec_n from uo_radiobutton within w_l_provenance
end type
type rb_provrec_o from uo_radiobutton within w_l_provenance
end type
type st_5 from uo_statictext within w_l_provenance
end type
type st_4 from uo_statictext within w_l_provenance
end type
type st_3 from uo_statictext within w_l_provenance
end type
type st_2 from uo_statictext within w_l_provenance
end type
type st_1 from uo_statictext within w_l_provenance
end type
type cb_ok from uo_cb_ok within w_l_provenance
end type
type cb_cancel from uo_cb_cancel within w_l_provenance
end type
type dw_1 from uo_ancestor_dwbrowse within w_l_provenance
end type
type sle_nomsp from uo_sle within w_l_provenance
end type
type sle_nomprov from uo_sle within w_l_provenance
end type
type sle_cdreg from uo_sle within w_l_provenance
end type
type sle_regprov from uo_sle within w_l_provenance
end type
type gb_1 from uo_groupbox within w_l_provenance
end type
end forward

global type w_l_provenance from w_ancestor
integer x = 498
integer width = 3515
integer height = 2084
string title = "Sélection d~'une provenance"
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
sle_region sle_region
st_8 st_8
sle_pays sle_pays
st_7 st_7
rb_listemb_n rb_listemb_n
rb_listemb_o rb_listemb_o
st_6 st_6
rb_provrec_n rb_provrec_n
rb_provrec_o rb_provrec_o
st_5 st_5
st_4 st_4
st_3 st_3
st_2 st_2
st_1 st_1
cb_ok cb_ok
cb_cancel cb_cancel
dw_1 dw_1
sle_nomsp sle_nomsp
sle_nomprov sle_nomprov
sle_cdreg sle_cdreg
sle_regprov sle_regprov
gb_1 gb_1
end type
global w_l_provenance w_l_provenance

type variables
boolean	ib_renvoiSP
end variables

forward prototypes
public subroutine wf_filtre ()
end prototypes

public subroutine wf_filtre ();// afficher les provenances en fonction des filtres demandés
string	ls_filtre

// uniquement les provenances présentes dans le dico des prov. recommandables
IF rb_provrec_o.checked THEN
	ls_filtre = "presence_dict = 'O'"
END IF

// uniquement les provenances présentes dans la liste simplifiée MB
IF rb_listemb_o.checked THEN
	IF f_IsEmptyString(ls_filtre) THEN
		ls_filtre = "presence_liste_mb = 'O'"
	ELSE
		ls_filtre = ls_filtre + " and presence_liste_mb = 'O'"
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
		ls_filtre = "match(upper(nom), '" + upper(sle_nomprov.text) + "')"
	ELSE
		ls_filtre = ls_filtre + " and match(upper(nom), '" + upper(sle_nomprov.text) + "')"
	END IF
END IF

// filtre sur le code régional
IF NOT f_IsEmptyString(sle_cdreg.text) THEN
	IF f_IsEmptyString(ls_filtre) THEN
		ls_filtre = "match(upper(region_prov_code_regprov), '" + upper(sle_cdreg.text) + "')"
	ELSE
		ls_filtre = ls_filtre + " and match(upper(region_prov_code_regprov), '" + upper(sle_cdreg.text) + "')"
	END IF
END IF

// filtre sur la région de provenance
IF NOT f_IsEmptyString(sle_regprov.text) THEN
	IF f_IsEmptyString(ls_filtre) THEN
		ls_filtre = "match(upper(region_prov_nom), '" + upper(sle_regprov.text) + "')"
	ELSE
		ls_filtre = ls_filtre + " and match(upper(region_prov_nom), '" + upper(sle_regprov.text) + "')"
	END IF
END IF

// filtre sur le pays
IF NOT f_IsEmptyString(sle_pays.text) THEN
	IF f_IsEmptyString(ls_filtre) THEN
		ls_filtre = "match(upper(region_prov_pays), '" + upper(sle_pays.text) + "')"
	ELSE
		ls_filtre = ls_filtre + " and match(upper(region_prov_pays), '" + upper(sle_pays.text) + "')"
	END IF
END IF

// filtre sur la région (W,V,B)
IF NOT f_IsEmptyString(sle_region.text) THEN
	IF f_IsEmptyString(ls_filtre) THEN
		ls_filtre = "match(upper(region_prov_region), '" + upper(sle_region.text) + "')"
	ELSE
		ls_filtre = ls_filtre + " and match(upper(region_prov_region), '" + upper(sle_region.text) + "')"
	END IF
END IF

dw_1.SetFilter(ls_filtre)
dw_1.Filter()
dw_1.Sort()
end subroutine

event ue_postopen;call super::ue_postopen;SetPointer(hourGlass!)
dw_1.retrieve()

end event

on w_l_provenance.create
int iCurrent
call super::create
this.sle_region=create sle_region
this.st_8=create st_8
this.sle_pays=create sle_pays
this.st_7=create st_7
this.rb_listemb_n=create rb_listemb_n
this.rb_listemb_o=create rb_listemb_o
this.st_6=create st_6
this.rb_provrec_n=create rb_provrec_n
this.rb_provrec_o=create rb_provrec_o
this.st_5=create st_5
this.st_4=create st_4
this.st_3=create st_3
this.st_2=create st_2
this.st_1=create st_1
this.cb_ok=create cb_ok
this.cb_cancel=create cb_cancel
this.dw_1=create dw_1
this.sle_nomsp=create sle_nomsp
this.sle_nomprov=create sle_nomprov
this.sle_cdreg=create sle_cdreg
this.sle_regprov=create sle_regprov
this.gb_1=create gb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.sle_region
this.Control[iCurrent+2]=this.st_8
this.Control[iCurrent+3]=this.sle_pays
this.Control[iCurrent+4]=this.st_7
this.Control[iCurrent+5]=this.rb_listemb_n
this.Control[iCurrent+6]=this.rb_listemb_o
this.Control[iCurrent+7]=this.st_6
this.Control[iCurrent+8]=this.rb_provrec_n
this.Control[iCurrent+9]=this.rb_provrec_o
this.Control[iCurrent+10]=this.st_5
this.Control[iCurrent+11]=this.st_4
this.Control[iCurrent+12]=this.st_3
this.Control[iCurrent+13]=this.st_2
this.Control[iCurrent+14]=this.st_1
this.Control[iCurrent+15]=this.cb_ok
this.Control[iCurrent+16]=this.cb_cancel
this.Control[iCurrent+17]=this.dw_1
this.Control[iCurrent+18]=this.sle_nomsp
this.Control[iCurrent+19]=this.sle_nomprov
this.Control[iCurrent+20]=this.sle_cdreg
this.Control[iCurrent+21]=this.sle_regprov
this.Control[iCurrent+22]=this.gb_1
end on

on w_l_provenance.destroy
call super::destroy
destroy(this.sle_region)
destroy(this.st_8)
destroy(this.sle_pays)
destroy(this.st_7)
destroy(this.rb_listemb_n)
destroy(this.rb_listemb_o)
destroy(this.st_6)
destroy(this.rb_provrec_n)
destroy(this.rb_provrec_o)
destroy(this.st_5)
destroy(this.st_4)
destroy(this.st_3)
destroy(this.st_2)
destroy(this.st_1)
destroy(this.cb_ok)
destroy(this.cb_cancel)
destroy(this.dw_1)
destroy(this.sle_nomsp)
destroy(this.sle_nomprov)
destroy(this.sle_cdreg)
destroy(this.sle_regprov)
destroy(this.gb_1)
end on

event ue_closebyxaccepted;cb_cancel.event clicked()
end event

event ue_open;call super::ue_open;str_params	lstr_params
boolean		lb_extended
string		ls_sp, ls_sql

lb_extended = FALSE
ib_renvoiSP = FALSE

// récupérer les paramètres (n° SP, renvoyer SP ou pas, sélection étendue ou pas)
lstr_params = Message.PowerObjectParm
IF IsValid(lstr_params) THEN 
	CHOOSE CASE upperbound(lstr_params.a_param)
		CASE 0
			lb_extended = FALSE
		CASE 1
			lb_extended = lstr_params.a_param[1]
		CASE 2
			ls_sp = string(lstr_params.a_param[1])
			lb_extended = lstr_params.a_param[2]
		CASE 3
			ls_sp = string(lstr_params.a_param[1])
			ib_renvoiSP = lstr_params.a_param[2]
			lb_extended = lstr_params.a_param[3]
	END CHOOSE
END IF

// tenir compte de l'espèce passée éventuellement en paramètre
IF NOT f_IsEmptyString(ls_sp) THEN
	ls_sql = dw_1.GetSqlSelect()
	ls_sql = f_modifySQL(ls_sql, "provenance.code_sp = '" + ls_sp + "'", "", "")
	dw_1.SetSQLSelect(ls_sql)
END IF

// assigner les couleurs pour les lignes paires et impaires du DW principal
gu_dwservices.uf_setbrowsecol(dw_1)

// sens du tri=croissant en commençant
gb_sort_asc = true

// autoriser ou pas la sélection de plusieurs code en fonction du paramètre
dw_1.uf_extendedselect(lb_extended)

end event

type sle_region from uo_sle within w_l_provenance
event we_changed pbm_enchange
integer x = 3255
integer y = 144
integer width = 128
integer height = 80
integer taborder = 100
boolean bringtotop = true
integer textsize = -9
textcase textcase = upper!
integer limit = 1
end type

event we_changed;IF this <> GetFocus() THEN return

sle_nomsp.text = ""
sle_nomprov.text = ""
sle_cdreg.text = ""
sle_regprov.text = ""
sle_pays.text = ""
wf_filtre()
end event

type st_8 from uo_statictext within w_l_provenance
integer x = 2889
integer y = 160
integer width = 352
integer textsize = -8
string text = "Région (W,V,B)"
end type

type sle_pays from uo_sle within w_l_provenance
event we_changed pbm_enchange
integer x = 2706
integer y = 144
integer width = 128
integer height = 80
integer taborder = 90
boolean bringtotop = true
integer textsize = -9
textcase textcase = upper!
integer limit = 2
end type

event we_changed;IF this <> GetFocus() THEN return

sle_nomsp.text = ""
sle_nomprov.text = ""
sle_cdreg.text = ""
sle_regprov.text = ""
sle_region.text = ""

wf_filtre()
end event

type st_7 from uo_statictext within w_l_provenance
integer x = 2578
integer y = 160
integer width = 128
integer textsize = -8
string text = "Pays"
end type

type rb_listemb_n from uo_radiobutton within w_l_provenance
integer x = 3017
integer y = 64
integer width = 165
integer height = 64
integer taborder = 40
integer textsize = -8
string text = "Non"
boolean checked = true
boolean automatic = false
end type

event clicked;call super::clicked;rb_listemb_o.checked = FALSE
rb_listemb_n.checked = TRUE
wf_filtre()
end event

type rb_listemb_o from uo_radiobutton within w_l_provenance
integer x = 2834
integer y = 64
integer width = 165
integer height = 64
integer taborder = 30
integer textsize = -8
string text = "Oui"
boolean automatic = false
end type

event clicked;call super::clicked;rb_listemb_o.checked = TRUE
rb_listemb_n.checked = FALSE
wf_filtre()
end event

type st_6 from uo_statictext within w_l_provenance
integer x = 1810
integer y = 64
integer width = 1006
integer textsize = -8
string text = "Seulement présentes dans liste simplifiée MB"
end type

type rb_provrec_n from uo_radiobutton within w_l_provenance
integer x = 1536
integer y = 64
integer width = 165
integer height = 64
integer taborder = 20
integer textsize = -8
string text = "Non"
boolean checked = true
boolean automatic = false
end type

event clicked;call super::clicked;rb_provrec_n.checked = TRUE
rb_provrec_o.checked = FALSE
wf_filtre()
end event

type rb_provrec_o from uo_radiobutton within w_l_provenance
integer x = 1353
integer y = 64
integer width = 165
integer height = 64
integer taborder = 10
integer textsize = -8
string text = "Oui"
boolean automatic = false
end type

event clicked;call super::clicked;rb_provrec_n.checked = FALSE
rb_provrec_o.checked = TRUE
wf_filtre()
end event

type st_5 from uo_statictext within w_l_provenance
integer x = 37
integer y = 64
integer width = 1298
integer textsize = -8
string text = "Seulement présentes dans dico des prov.recommandables"
end type

type st_4 from uo_statictext within w_l_provenance
integer x = 1829
integer y = 160
integer width = 302
integer textsize = -8
string text = "Région prov."
end type

type st_3 from uo_statictext within w_l_provenance
integer x = 1353
integer y = 160
integer width = 183
integer textsize = -8
string text = "Cd Rég."
end type

type st_2 from uo_statictext within w_l_provenance
integer x = 677
integer y = 160
integer width = 247
integer textsize = -8
string text = "Nom prov."
end type

type st_1 from uo_statictext within w_l_provenance
integer x = 37
integer y = 160
integer width = 183
integer textsize = -8
string text = "nom SP"
end type

type cb_ok from uo_cb_ok within w_l_provenance
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
		IF ib_renvoiSP THEN
			li_param++
			lstr_params.a_param[li_param] = dw_1.Object.code_sp[ll_selrow]
		END IF
		li_param++
		lstr_params.a_param[li_param] = dw_1.Object.num_prov[ll_selrow]
		ll_selrow = dw_1.GetSelectedRow(ll_selrow)
	LOOP
ELSE
	ll_selrow = dw_1.GetRow()
	IF ll_selrow > 0 THEN
		IF ib_renvoiSP THEN
			li_param++
			lstr_params.a_param[li_param] = dw_1.Object.code_sp[ll_selrow]
		END IF
		li_param++
		lstr_params.a_param[li_param] = dw_1.Object.num_prov[ll_selrow]
	END IF
END IF

IF li_param = 0 THEN
	CloseWithReturn(Parent, -1)
ELSE
	CloseWithReturn(Parent, lstr_params)
END IF
end event

type cb_cancel from uo_cb_cancel within w_l_provenance
integer x = 1865
integer y = 1856
integer width = 384
string text = "Abandonner"
end type

event clicked;CloseWithReturn(Parent, -1)
end event

type dw_1 from uo_ancestor_dwbrowse within w_l_provenance
integer y = 240
integer width = 3493
integer height = 1584
integer taborder = 110
string dataobject = "d_l_provenance"
boolean hscrollbar = true
boolean vscrollbar = true
boolean border = true
boolean hsplitscroll = true
end type

event doubleclicked;call super::doubleclicked;cb_ok.event post clicked()
end event

type sle_nomsp from uo_sle within w_l_provenance
event we_changed pbm_enchange
integer x = 238
integer y = 144
integer height = 80
integer taborder = 50
boolean bringtotop = true
integer textsize = -9
end type

event we_changed;IF this <> GetFocus() THEN return

sle_nomprov.text = ""
sle_cdreg.text = ""
sle_regprov.text = ""
sle_pays.text = ""
sle_region.text = ""
wf_filtre()
end event

type sle_nomprov from uo_sle within w_l_provenance
event we_changed pbm_enchange
integer x = 914
integer y = 144
integer height = 80
integer taborder = 60
boolean bringtotop = true
integer textsize = -9
end type

event we_changed;IF this <> GetFocus() THEN return

sle_nomsp.text = ""
sle_cdreg.text = ""
sle_regprov.text = ""
sle_pays.text = ""
sle_region.text = ""
wf_filtre()
end event

type sle_cdreg from uo_sle within w_l_provenance
event we_changed pbm_enchange
integer x = 1536
integer y = 144
integer width = 256
integer height = 80
integer taborder = 70
boolean bringtotop = true
integer textsize = -9
end type

event we_changed;IF this <> GetFocus() THEN return

sle_nomsp.text = ""
sle_nomprov.text = ""
sle_regprov.text = ""
sle_pays.text = ""
sle_region.text = ""
wf_filtre()
end event

type sle_regprov from uo_sle within w_l_provenance
event we_changed pbm_enchange
integer x = 2121
integer y = 144
integer height = 80
integer taborder = 80
boolean bringtotop = true
integer textsize = -9
end type

event we_changed;IF this <> GetFocus() THEN return

sle_nomsp.text = ""
sle_nomprov.text = ""
sle_cdreg.text = ""
sle_pays.text = ""
sle_region.text = ""
wf_filtre()
end event

type gb_1 from uo_groupbox within w_l_provenance
integer width = 3493
integer height = 240
integer textsize = -9
integer weight = 700
long textcolor = 8388608
string text = "Filtre..."
end type

