//objectcomments Gestion des 'set' de critères de tri par défaut par report
forward
global type w_report_predeftri from w_ancestor_dataentry
end type
type dw_1 from uo_datawindow_multiplerow within w_report_predeftri
end type
type ddlb_1 from uo_dropdownlistbox within w_report_predeftri
end type
type st_1 from uo_statictext within w_report_predeftri
end type
type st_copy from uo_statictext within w_report_predeftri
end type
type cb_copy from uo_cb within w_report_predeftri
end type
type sle_copy from uo_sle within w_report_predeftri
end type
end forward

global type w_report_predeftri from w_ancestor_dataentry
integer width = 2633
integer height = 1944
string title = "Critères de tri possibles par report"
boolean maxbox = true
boolean resizable = true
event ue_print ( )
dw_1 dw_1
ddlb_1 ddlb_1
st_1 st_1
st_copy st_copy
cb_copy cb_copy
sle_copy sle_copy
end type
global w_report_predeftri w_report_predeftri

type variables
integer	ii_item
boolean	ib_updatable


end variables

forward prototypes
public subroutine wf_sort ()
public function integer wf_addddlb (string as_item)
public function integer wf_newcrit (long al_row)
end prototypes

event ue_print;str_params	lstr_params

//  Ouverture de la fenêtre print_setup avec comme paramètre le nom du datawindow et l'autorisation ou pas de cancel
lstr_params.a_param[1] = dw_1
lstr_params.a_param[2] = TRUE

openwithparm(w_print_setup, lstr_params)


end event

public subroutine wf_sort ();long	ll_row
integer	li_col

dw_1.SetRedraw(FALSE)
ll_row = dw_1.GetRow()
li_col = dw_1.GetColumn()
dw_1.object.actuel[ll_row] = 1
dw_1.SetSort("report A,id A,ordretri A")
dw_1.Sort()
dw_1.GroupCalc()
ll_row = dw_1.find("actuel = 1", 0, dw_1.rowcount())
dw_1.object.actuel[ll_row] = 0
dw_1.ScrollToRow(ll_row)
dw_1.SetColumn(li_col)
dw_1.SetRedraw(TRUE)
end subroutine

public function integer wf_addddlb (string as_item);IF ddlb_1.FindItem(sle_copy.text, 0) = -1 THEN
	return(ddlb_1.AddItem(as_item))
ELSE
	return(0)
END IF

end function

public function integer wf_newcrit (long al_row);IF al_row <= 0 THEN return(-1)
IF al_row = 1 THEN
	IF dw_1.rowcount() > 1 THEN
		dw_1.uf_SetDefaultValue(al_row, "report", dw_1.object.report[al_row + 1])
		dw_1.uf_SetDefaultValue(al_row, "id", dw_1.object.id[al_row + 1])
	END IF
ELSE
	dw_1.uf_SetDefaultValue(al_row, "report", dw_1.object.report[al_row - 1])
	dw_1.uf_SetDefaultValue(al_row, "id", dw_1.object.id[al_row - 1])
END IF
dw_1.uf_SetDefaultValue(al_row, "groupe", "N")
dw_1.uf_SetDefaultValue(al_row, "newpage", "N")
dw_1.setfocus()
return(1)
end function

on w_report_predeftri.create
int iCurrent
call super::create
this.dw_1=create dw_1
this.ddlb_1=create ddlb_1
this.st_1=create st_1
this.st_copy=create st_copy
this.cb_copy=create cb_copy
this.sle_copy=create sle_copy
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_1
this.Control[iCurrent+2]=this.ddlb_1
this.Control[iCurrent+3]=this.st_1
this.Control[iCurrent+4]=this.st_copy
this.Control[iCurrent+5]=this.cb_copy
this.Control[iCurrent+6]=this.sle_copy
end on

on w_report_predeftri.destroy
call super::destroy
destroy(this.dw_1)
destroy(this.ddlb_1)
destroy(this.st_1)
destroy(this.st_copy)
destroy(this.cb_copy)
destroy(this.sle_copy)
end on

event ue_abandonner;post close(this)
return(0)
end event

event ue_ajouter;call super::ue_ajouter;wf_newcrit(dw_1.event ue_addrow())
end event

event ue_supprimer;call super::ue_supprimer;dw_1.event ue_delete()
end event

event ue_enregistrer;call super::ue_enregistrer;integer	li_status

ddlb_1.Selectitem(ii_item)
ddlb_1.event selectionchanged(ii_item)
// contrôle de validité de tous les champs
IF dw_1.event ue_checkall() < 0 THEN
	return(-1)
END IF

// update
SetPointer(HourGlass!)
li_status = gu_dwservices.uf_updateTransact(dw_1)
CHOOSE CASE li_status
	CASE 1
		wf_message("Enregistrement OK")
		return(1)
	CASE -1
		gu_message.uf_error("Erreur lors de la mise à jour de la base de données")
		return(-1)
END CHOOSE

end event

event resize;call super::resize;dw_1.height = wf_getWSHeight() - dw_1.y
dw_1.width = wf_getWSWidth()
end event

event ue_init_menu;call super::ue_init_menu;IF ib_updatable THEN
	f_menuaction({"m_enregistrer","m_ajouter","m_inserer","m_supprimer","m_abandonner","m_fermer"})
ELSE
	f_menuaction({"m_abandonner","m_fermer"})
END IF

end event

event ue_inserer;call super::ue_inserer;wf_newcrit(dw_1.event ue_insertrow())
end event

event ue_postopen;call super::ue_postopen;// garnir la ddlb permettant le filtrage sur le nom du report
string	ls_report

DECLARE filtre CURSOR FOR
	select distinct report from report_predeftri USING ESQLCA;

OPEN filtre;
FETCH filtre INTO :ls_report;
DO WHILE f_check_sql(ESQLCA) = 0
	ddlb_1.AddItem(ls_report)
	FETCH filtre INTO :ls_report;
LOOP
CLOSE filtre;
ii_item = ddlb_1.AddItem(" Tous")
ddlb_1.Selectitem(ii_item)
end event

event ue_init_win;call super::ue_init_win;IF ib_updatable THEN
	wf_actif(TRUE)
END IF
end event

event ue_open;call super::ue_open;// ne pas logger de message lors de l'utilisation de cette fenêtre
wf_logusage(FALSE)

wf_SetItemsToShow({"m_ajouter","m_inserer"})
wf_SetDWList({dw_1})
dw_1.uf_sort(TRUE)

// tester si on travaille sur une table ou un snapshot
IF f_tableExists('report_predeftri', ESQLCA) THEN
	ib_updatable = true
else
	ib_updatable = false
end if

dw_1.retrieve()
end event

type ddlb_message from w_ancestor_dataentry`ddlb_message within w_report_predeftri
integer y = 1696
integer width = 2267
end type

type dw_1 from uo_datawindow_multiplerow within w_report_predeftri
integer y = 128
integer width = 2578
integer height = 1264
integer taborder = 10
boolean bringtotop = true
string dataobject = "d_report_predeftri"
boolean hscrollbar = true
boolean vscrollbar = true
end type

event ue_postitemvalidated;call super::ue_postitemvalidated;CHOOSE CASE as_name
	CASE "report","id","ordretri"
		wf_sort()
END CHOOSE
end event

event ue_itemvalidated;call super::ue_itemvalidated;integer	li_ordre

CHOOSE CASE as_name
	CASE "report"
		// si le report n'avait pas encore de critères définis ajouter ce report dans la ddlb de filtre
		IF this.Find("report='" + as_data + "'",1, this.RowCount()) <= 0 THEN
			ddlb_1.AddItem(as_data)
		END IF
	CASE "id"
		// ajout d'un critère : si le report n'avait pas encore de critères définis pour cet id, n° ordre par défaut = 1
		IF this.Find("report='" + this.object.report[al_row] + "'" + " and id=" + as_data,1, this.RowCount()) <= 0 THEN
			this.object.ordretri[al_row] = 1
		ELSE
		// sinon n° d'ordre = celui du record précédent + 1 (voir expression ds le dwobject)
			li_ordre = this.object.maxordre[al_row]
			IF li_ordre > 999 THEN li_ordre = 999
			this.object.ordretri[al_row] = li_ordre
		END IF
END CHOOSE
end event

event ue_checkitem;call super::ue_checkitem;CHOOSE CASE as_item
	CASE "report", "critere"
		IF f_IsEmptyString(as_data) THEN
			as_message = "Champ obligatoire"
			return(-1)
		END IF
	CASE "id", "ordretri"
		IF IsNull(as_data) OR Integer(as_data) <= 0 THEN
			as_message = "Champ obligatoire"
			return(-1)
		END IF
END CHOOSE
return(1)
end event

type ddlb_1 from uo_dropdownlistbox within w_report_predeftri
integer x = 274
integer y = 16
integer width = 896
integer height = 624
integer taborder = 20
boolean bringtotop = true
integer textsize = -8
boolean vscrollbar = true
end type

event selectionchanged;call super::selectionchanged;IF upper(trim(ddlb_1.Text)) = "TOUS" THEN
	dw_1.SetFilter("")
	st_copy.enabled = FALSE
	sle_copy.enabled = FALSE
	cb_copy.enabled = FALSE
ELSE
	dw_1.SetFilter("report = '" + ddlb_1.Text + "'")
	st_copy.enabled = TRUE
	sle_copy.enabled = TRUE
	cb_copy.enabled = TRUE
END IF
dw_1.Filter()
wf_sort()


end event

type st_1 from uo_statictext within w_report_predeftri
integer x = 18
integer y = 16
integer width = 256
boolean bringtotop = true
string text = "Filtre sur "
end type

type st_copy from uo_statictext within w_report_predeftri
integer x = 1298
integer y = 16
integer width = 311
boolean bringtotop = true
boolean enabled = false
string text = "Copier vers"
end type

type cb_copy from uo_cb within w_report_predeftri
integer x = 2267
integer y = 16
integer width = 201
integer height = 80
integer taborder = 40
boolean bringtotop = true
boolean enabled = false
string text = "Copier"
end type

event clicked;call super::clicked;long	ll_nbrow, ll_row, ll_initrow

IF f_IsEmptyString(sle_copy.text) THEN
	return
END IF
ll_nbrow = dw_1.RowCount()
ll_initrow = ll_nbrow + 1
dw_1.SetRedraw(FALSE)
dw_1.RowsCopy (1, ll_nbrow, Primary!, dw_1, ll_initrow, Primary!)

FOR ll_row = ll_initrow TO dw_1.RowCount()
	dw_1.object.report[ll_row] = sle_copy.text
NEXT
dw_1.SetRedraw(TRUE)

wf_addddlb(sle_copy.text)
ddlb_1.SelectItem(sle_copy.text, 0)
dw_1.SetFilter("report = '" + ddlb_1.Text + "'")
dw_1.Filter()
end event

type sle_copy from uo_sle within w_report_predeftri
integer x = 1609
integer y = 16
integer width = 640
integer height = 80
integer taborder = 30
boolean bringtotop = true
integer textsize = -8
long backcolor = 16777215
boolean enabled = false
textcase textcase = upper!
integer limit = 50
end type

