//objectcomments Sélection bordereau de livraison
forward
global type w_l_bordliv from w_ancestor
end type
type em_annee from uo_editmask within w_l_bordliv
end type
type st_5 from uo_statictext within w_l_bordliv
end type
type cb_ok from uo_cb_ok within w_l_bordliv
end type
type cb_cancel from uo_cb_cancel within w_l_bordliv
end type
type dw_1 from uo_ancestor_dwbrowse within w_l_bordliv
end type
type gb_1 from uo_groupbox within w_l_bordliv
end type
end forward

global type w_l_bordliv from w_ancestor
integer x = 498
integer width = 2469
integer height = 2084
string title = "Sélection bordereau de livraison"
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
em_annee em_annee
st_5 st_5
cb_ok cb_ok
cb_cancel cb_cancel
dw_1 dw_1
gb_1 gb_1
end type
global w_l_bordliv w_l_bordliv

type variables
boolean	ib_renvoiANNEE, ib_renvoiNUM
end variables

forward prototypes
public subroutine wf_filtre ()
end prototypes

public subroutine wf_filtre ();// afficher les autorisations en fonction des filtres demandés
string	ls_filtre
double	ldb_annee

em_annee.GetData(ldb_annee)

// filtre sur l'année d'autorisation
IF ldb_annee > 0 THEN
	ls_filtre = "match(string(an_cmde), '" + string(ldb_annee) + "')"
END IF

dw_1.SetFilter(ls_filtre)
dw_1.Filter()
dw_1.Sort()
end subroutine

event ue_postopen;call super::ue_postopen;SetPointer(hourGlass!)
dw_1.retrieve()

end event

on w_l_bordliv.create
int iCurrent
call super::create
this.em_annee=create em_annee
this.st_5=create st_5
this.cb_ok=create cb_ok
this.cb_cancel=create cb_cancel
this.dw_1=create dw_1
this.gb_1=create gb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.em_annee
this.Control[iCurrent+2]=this.st_5
this.Control[iCurrent+3]=this.cb_ok
this.Control[iCurrent+4]=this.cb_cancel
this.Control[iCurrent+5]=this.dw_1
this.Control[iCurrent+6]=this.gb_1
end on

on w_l_bordliv.destroy
call super::destroy
destroy(this.em_annee)
destroy(this.st_5)
destroy(this.cb_ok)
destroy(this.cb_cancel)
destroy(this.dw_1)
destroy(this.gb_1)
end on

event ue_closebyxaccepted;cb_cancel.event clicked()
end event

event ue_open;call super::ue_open;str_params	lstr_params
boolean		lb_extended
string		ls_sql, ls_where
integer		li_annee, li_num

lb_extended = FALSE
ib_renvoiANNEE = FALSE

// récupérer les paramètres (année, renvoyer année ou pas, num.cmde, renvoyer num.cmde, sélection étendue ou pas)
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
			li_num = integer(lstr_params.a_param[3])
			lb_extended = lstr_params.a_param[4]
		CASE 5
			li_annee = integer(lstr_params.a_param[1])
			ib_renvoiANNEE = lstr_params.a_param[2]
			li_num = integer(lstr_params.a_param[3])
			ib_renvoiNUM = lstr_params.a_param[4]
			lb_extended = lstr_params.a_param[5]
	END CHOOSE
END IF

// tenir compte de l'année de commande passée éventuellement en paramètre
IF li_annee > 0 THEN
	ls_where = "bord_liv.an_cmde = " + string(li_annee)
END IF
// tenir compte du n° de commande passé éventuellement en paramètre
IF li_num > 0 THEN
	IF f_IsEmptyString(ls_where) THEN
		ls_where = "bord_liv.num_cmde = " + string(li_num)
	ELSE
		ls_where = ls_where + " AND bord_liv.num_cmde = " + string(li_num)
	END IF
END IF

IF NOT f_IsEmptyString(ls_where) THEN
	ls_sql = dw_1.GetSqlSelect()
	ls_sql = f_modifySQL(ls_sql, ls_where, "", "")
	dw_1.SetSQLSelect(ls_sql)
	em_annee.text = string(li_annee)
	em_annee.enabled = FALSE
END IF

// assigner les couleurs pour les lignes paires et impaires du DW principal
gu_dwservices.uf_setbrowsecol(dw_1)

// sens du tri=croissant en commençant
gb_sort_asc = true

// autoriser ou pas la sélection de plusieurs code en fonction du paramètre
dw_1.uf_extendedselect(lb_extended)

end event

type em_annee from uo_editmask within w_l_bordliv
event we_changed pbm_enchange
integer x = 658
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

type st_5 from uo_statictext within w_l_bordliv
integer x = 475
integer y = 72
integer width = 165
integer textsize = -9
string text = "Année"
end type

type cb_ok from uo_cb_ok within w_l_bordliv
integer x = 695
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
			lstr_params.a_param[li_param] = dw_1.Object.an_cmde[ll_selrow]
		END IF
		IF ib_renvoiNUM THEN
			li_param++
			lstr_params.a_param[li_param] = dw_1.Object.num_cmde[ll_selrow]
			ll_selrow = dw_1.GetSelectedRow(ll_selrow)
		END IF
		li_param++
		lstr_params.a_param[li_param] = dw_1.Object.num_bord[ll_selrow]
		ll_selrow = dw_1.GetSelectedRow(ll_selrow)
	LOOP
ELSE
	ll_selrow = dw_1.GetRow()
	IF ll_selrow > 0 THEN
		IF ib_renvoiANNEE THEN
			li_param++
			lstr_params.a_param[li_param] = dw_1.Object.an_cmde[ll_selrow]
		END IF
		IF ib_renvoiNUM THEN
			li_param++
			lstr_params.a_param[li_param] = dw_1.Object.num_cmde[ll_selrow]
		END IF
		li_param++
		lstr_params.a_param[li_param] = dw_1.Object.num_bord[ll_selrow]
	END IF
END IF

IF li_param = 0 THEN
	CloseWithReturn(Parent, -1)
ELSE
	CloseWithReturn(Parent, lstr_params)
END IF
end event

type cb_cancel from uo_cb_cancel within w_l_bordliv
integer x = 1335
integer y = 1856
integer width = 384
string text = "Abandonner"
end type

event clicked;CloseWithReturn(Parent, -1)
end event

type dw_1 from uo_ancestor_dwbrowse within w_l_bordliv
integer y = 176
integer width = 2450
integer height = 1648
integer taborder = 110
string dataobject = "d_l_bordliv"
boolean hscrollbar = true
boolean vscrollbar = true
boolean border = true
boolean hsplitscroll = true
end type

event doubleclicked;call super::doubleclicked;cb_ok.event post clicked()
end event

type gb_1 from uo_groupbox within w_l_bordliv
integer width = 2450
integer height = 176
integer textsize = -9
integer weight = 700
long textcolor = 8388608
string text = "Filtre..."
end type

