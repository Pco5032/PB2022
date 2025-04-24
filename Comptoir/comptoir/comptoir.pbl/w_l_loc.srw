//objectcomments Sélection d'une localité
forward
global type w_l_loc from w_ancestor
end type
type sle_loc from uo_sle within w_l_loc
end type
type st_1 from uo_statictext within w_l_loc
end type
type dw_prov from uo_datawindow_singlerow within w_l_loc
end type
type cb_cancel from uo_cb_cancel within w_l_loc
end type
type cb_ok from uo_cb_ok within w_l_loc
end type
type dw_1 from uo_ancestor_dwbrowse within w_l_loc
end type
end forward

global type w_l_loc from w_ancestor
integer x = 498
integer width = 2016
integer height = 1984
string title = "Sélection d~'une localité"
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
sle_loc sle_loc
st_1 st_1
dw_prov dw_prov
cb_cancel cb_cancel
cb_ok cb_ok
dw_1 dw_1
end type
global w_l_loc w_l_loc

type variables
integer	ii_cp
string	is_sort
end variables

forward prototypes
public subroutine wf_filtre ()
end prototypes

public subroutine wf_filtre ();// filtre sur province et/ou localite
string	ls_loc, ls_prov, ls_filtre

// filtre sur la province
ls_prov = dw_prov.object.s_iprov[1]
IF upper(ls_prov) <> "TOUTES" THEN
	ls_filtre = "localite_iprov='" + ls_prov + "'"
END IF

// filtre sur la localité
ls_loc = trim(sle_loc.text)
IF NOT f_IsEmptyString(ls_loc) THEN
	IF f_IsEmptyString(ls_filtre) THEN
		ls_filtre = "match(upper(localite_localite), '" + ls_loc + "')"
	ELSE
		ls_filtre = ls_filtre + " and match(upper(localite_localite), '" + ls_loc + "')"
	END IF
END IF

dw_1.SetFilter(ls_filtre)
dw_1.Filter()
dw_1.Sort()

end subroutine

event ue_postopen;call super::ue_postopen;long		ll_nbrows, ll_row
string	ls_sql, ls_newsql

// si CP passé en paramètre, ne lire que les localités de ce CP, et s'il n'y en a pas lire tout et
// scroll vers 1ere loc. dont le CP est approchant
ll_nbrows = 0
IF ii_cp <> 0 THEN
	ls_sql = dw_1.GetSQLSelect()
	ls_newsql = f_modifysql(ls_sql, "localite.cploc like '" + f_string(ii_cp) + "%'", "", "")
	dw_1.SetSQLselect(ls_newsql)
	dw_1.SetTransObject(SQLCA)
	ll_nbrows = dw_1.retrieve()
	IF ll_nbrows = 0 THEN
		dw_1.SetSQLselect(ls_sql)
		dw_1.SetTransObject(SQLCA)
		ll_nbrows = dw_1.retrieve()
	END IF
ELSE	
	ll_nbrows = dw_1.retrieve()
END IF

// si CP passé en paramètre, scroll vers 1ere loc. correspondante
is_sort = "localite_localite"
IF ii_cp <> 0 THEN
	dw_1.SetRedraw(FALSE)
	is_sort = "localite_cploc, localite_localite"
	dw_1.SetSort(is_sort)
	dw_1.Sort()
	ll_row = dw_1.Find ("localite_cploc = " + string(ii_cp), 1, ll_nbrows)
	IF ll_row > 0 THEN
		dw_1.ScrollToRow(ll_row)
		DO UNTIL long(dw_1.object.dataWindow.firstRowOnPage) = ll_row or dw_1.GetRow() = ll_nbrows
	   	dw_1.ScrollNextRow()
		LOOP
		dw_1.SetRow(ll_row)
	ELSE
		dw_1.SetSort(is_sort)
		dw_1.Sort()
	END IF
	dw_1.SetRedraw(TRUE)
END IF


end event

on w_l_loc.create
int iCurrent
call super::create
this.sle_loc=create sle_loc
this.st_1=create st_1
this.dw_prov=create dw_prov
this.cb_cancel=create cb_cancel
this.cb_ok=create cb_ok
this.dw_1=create dw_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.sle_loc
this.Control[iCurrent+2]=this.st_1
this.Control[iCurrent+3]=this.dw_prov
this.Control[iCurrent+4]=this.cb_cancel
this.Control[iCurrent+5]=this.cb_ok
this.Control[iCurrent+6]=this.dw_1
end on

on w_l_loc.destroy
call super::destroy
destroy(this.sle_loc)
destroy(this.st_1)
destroy(this.dw_prov)
destroy(this.cb_cancel)
destroy(this.cb_ok)
destroy(this.dw_1)
end on

event ue_closebyxaccepted;cb_cancel.Event clicked()
end event

event ue_open;call super::ue_open;str_params	lstr_params
boolean		lb_extended
long			ll_row
string		ls_param

// récupérer les paramètres (présélection code postal, sélection étendue ou pas)
lstr_params = Message.PowerObjectParm

IF NOT IsValid(lstr_params) THEN 
	lb_extended = FALSE
ELSE
	CHOOSE CASE upperbound(lstr_params.a_param)
		CASE 0
			lb_extended = FALSE
		CASE 1
			lb_extended = lstr_params.a_param[1]
		CASE 2
			ls_param = f_string(lstr_params.a_param[1])
			IF IsNumber(ls_param) THEN
				ii_cp = integer(lstr_params.a_param[1])
			ELSE
				ii_cp = 0
			END IF
			lb_extended = lstr_params.a_param[2]
	END CHOOSE
END IF

// assigner les couleurs pour les lignes paires et impaires du DW principal
gu_dwservices.uf_setbrowsecol(dw_1)

// sens du tri=croissant en commençant
gb_sort_asc = true

// autoriser ou pas la sélection de plusieurs code en fonction du paramètre
dw_1.uf_extendedselect(lb_extended)

// dddw sur province pour filtrer, mais on ajoute l'option 'Toutes les provinces'
dw_prov.insertrow(0)
datawindowchild	ldwc_dropdown

dw_prov.GetChild("s_iprov", ldwc_dropdown)
ll_row = ldwc_dropdown.InsertRow(1)
ldwc_dropdown.SetItem(ll_row, 'c_prov', 'Toutes')
end event

type sle_loc from uo_sle within w_l_loc
event we_changed pbm_enchange
integer x = 1170
integer width = 494
integer height = 80
integer taborder = 20
integer textsize = -9
textcase textcase = upper!
end type

event we_changed;// appliquer filtre sur la localite
wf_filtre()

end event

type st_1 from uo_statictext within w_l_loc
integer x = 951
integer y = 8
integer width = 219
string text = "Localité"
end type

type dw_prov from uo_datawindow_singlerow within w_l_loc
integer width = 878
integer height = 80
integer taborder = 10
string dataobject = "d_choix_prov"
end type

event ue_itemvalidated;call super::ue_itemvalidated;// appliquer filtre sur province sélectionnée ce qui a pour effet d'annuler celui sur la localite
// sle_loc.text = ""

//IF upper(as_data) <> "TOUTES" THEN
//	dw_1.SetFilter("localite_iprov='" + as_data + "'")
//ELSE
//	dw_1.SetFilter("")
//END IF
//dw_1.Filter()
//dw_1.Sort()
end event

event ue_postitemvalidated;call super::ue_postitemvalidated;// appliquer filtre sur la province sélectionnée
wf_filtre()
end event

type cb_cancel from uo_cb_cancel within w_l_loc
integer x = 1061
integer y = 1728
end type

event clicked;call super::clicked;CloseWithReturn(Parent, -1)
end event

type cb_ok from uo_cb_ok within w_l_loc
integer x = 439
integer y = 1728
end type

event clicked;call super::clicked;str_params	lstr_params
long 			ll_selrow
integer		li_param

li_param=0
ll_selrow = dw_1.GetSelectedRow(0)

// si multisélection autorisée, renvoyer toutes les rows sélectionnées, sinon renvoyer row en cours
IF dw_1.uf_extendedselect() THEN
	DO WHILE ll_selrow > 0
		li_param++
		lstr_params.a_param[li_param] = dw_1.Object.localite_id[ll_selrow]
		ll_selrow = dw_1.GetSelectedRow(ll_selrow)
	LOOP
ELSE
	IF dw_1.GetRow() > 0 THEN
		li_param++
		lstr_params.a_param[li_param] = dw_1.Object.localite_id[dw_1.GetRow()]
	END IF
END IF

IF li_param = 0 THEN
	CloseWithReturn(Parent, -1)
ELSE
	CloseWithReturn(Parent, lstr_params)
END IF
end event

type dw_1 from uo_ancestor_dwbrowse within w_l_loc
integer y = 96
integer width = 1975
integer height = 1600
integer taborder = 30
string dataobject = "d_l_loc"
boolean hscrollbar = true
boolean vscrollbar = true
boolean border = true
boolean hsplitscroll = true
end type

event doubleclicked;call super::doubleclicked;cb_ok.postevent(clicked!)
end event

