//objectcomments Sélection d'un document fournisseur
forward
global type w_l_docfrn from w_ancestor
end type
type st_1 from uo_statictext within w_l_docfrn
end type
type ddlb_type from uo_dropdownlistbox within w_l_docfrn
end type
type cb_ok from uo_cb_ok within w_l_docfrn
end type
type cb_cancel from uo_cb_cancel within w_l_docfrn
end type
type dw_1 from uo_ancestor_dwbrowse within w_l_docfrn
end type
end forward

global type w_l_docfrn from w_ancestor
integer width = 3209
integer height = 2080
string title = "Sélection d~'un lot document fournisseur"
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
st_1 st_1
ddlb_type ddlb_type
cb_ok cb_ok
cb_cancel cb_cancel
dw_1 dw_1
end type
global w_l_docfrn w_l_docfrn

forward prototypes
public subroutine wf_filtre ()
end prototypes

public subroutine wf_filtre ();// afficher les documents du type sélectionné
string	ls_type, ls_filtre

// filtre sur le type
ls_type = ddlb_type.text
CHOOSE CASE ls_type
	CASE "Emis"
		ls_type = "E"
	CASE "Reçus"
		ls_type = "R"
	CASE ELSE
		ls_type = ""
END CHOOSE
IF NOT f_IsEmptyString(ls_type) THEN
	ls_filtre = "type_df = '" + ls_type + "'"
END IF

dw_1.SetFilter(ls_filtre)
dw_1.Filter()
dw_1.Sort()
end subroutine

on w_l_docfrn.create
int iCurrent
call super::create
this.st_1=create st_1
this.ddlb_type=create ddlb_type
this.cb_ok=create cb_ok
this.cb_cancel=create cb_cancel
this.dw_1=create dw_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.st_1
this.Control[iCurrent+2]=this.ddlb_type
this.Control[iCurrent+3]=this.cb_ok
this.Control[iCurrent+4]=this.cb_cancel
this.Control[iCurrent+5]=this.dw_1
end on

on w_l_docfrn.destroy
call super::destroy
destroy(this.st_1)
destroy(this.ddlb_type)
destroy(this.cb_ok)
destroy(this.cb_cancel)
destroy(this.dw_1)
end on

event resize;call super::resize;dw_1.width = newwidth
end event

event ue_closebyxaccepted;call super::ue_closebyxaccepted;cb_cancel.Event clicked()
end event

event ue_open;call super::ue_open;str_params	lstr_params
boolean		lb_extended
string		ls_type, ls_where, ls_sql

// récupérer les paramètres (type de document (E/F), clause where, sélection étendue ou pas)
lstr_params = Message.PowerObjectParm

lb_extended = FALSE

IF IsValid(lstr_params) THEN 
	CHOOSE CASE upperbound(lstr_params.a_param)
		CASE 0
			lb_extended = FALSE
		CASE 1
			lb_extended = lstr_params.a_param[1]
		CASE 2
			ls_type = string(lstr_params.a_param[1])
			lb_extended = lstr_params.a_param[2]
		CASE 3
			ls_type = string(lstr_params.a_param[1])
			ls_where = string(lstr_params.a_param[2])
			lb_extended = lstr_params.a_param[3]
	END CHOOSE
END IF

// lire uniquement les DF du type demandé
IF NOT f_IsEmptyString(ls_type) THEN
	ls_sql = dw_1.GetSqlSelect()
	ls_sql = f_modifySQL(ls_sql, "docfrn.type_df='" + ls_type + "'", "", "")
	dw_1.SetSQLSelect(ls_sql)
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

event ue_postopen;call super::ue_postopen;dw_1.retrieve()

end event

type st_1 from uo_statictext within w_l_docfrn
integer x = 18
integer y = 16
integer width = 535
string text = "Type de documents"
end type

type ddlb_type from uo_dropdownlistbox within w_l_docfrn
integer x = 567
integer y = 16
integer width = 585
integer taborder = 10
integer textsize = -9
boolean sorted = false
string item[] = {"  Tous les types","Emis","Reçus"}
end type

event selectionchanged;call super::selectionchanged;// changement de type : afficher les certificats du nouveau type
wf_filtre()
end event

type cb_ok from uo_cb_ok within w_l_docfrn
integer x = 1006
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
		lstr_params.a_param[li_param] = dw_1.Object.num_df[ll_selrow]
		ll_selrow = dw_1.GetSelectedRow(ll_selrow)
	LOOP
ELSE
	ll_selrow = dw_1.GetRow()
	IF ll_selrow > 0 THEN
		li_param++
		lstr_params.a_param[li_param] = dw_1.Object.num_df[ll_selrow]
	END IF
END IF

IF li_param = 0 THEN
	CloseWithReturn(Parent, -1)
ELSE
	CloseWithReturn(Parent, lstr_params)
END IF

end event

type cb_cancel from uo_cb_cancel within w_l_docfrn
integer x = 1682
integer y = 1856
end type

event clicked;call super::clicked;CloseWithReturn(Parent, -1)
end event

type dw_1 from uo_ancestor_dwbrowse within w_l_docfrn
integer y = 112
integer width = 3200
integer height = 1712
integer taborder = 10
string dataobject = "d_l_docfrn"
boolean hscrollbar = true
boolean vscrollbar = true
boolean border = true
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

