//objectcomments Validation de tests de germination par choix dans liste des tests pas encore validés
forward
global type w_validqgerm_liste from w_ancestor
end type
type dw_1 from uo_datawindow_multiplerow within w_validqgerm_liste
end type
end forward

global type w_validqgerm_liste from w_ancestor
integer width = 4155
integer height = 2260
string title = "Validation de tests de germination"
dw_1 dw_1
end type
global w_validqgerm_liste w_validqgerm_liste

type variables
string	is_doc
end variables

forward prototypes
public subroutine wf_search_test (string as_reflot, integer ai_numtest)
end prototypes

public subroutine wf_search_test (string as_reflot, integer ai_numtest);long	ll_row

IF f_isEmptyString(as_reflot) OR isNull(ai_numtest) OR ai_numtest = 0 THEN return

ll_row = dw_1.find("ref_lot='" + as_reflot + "' and num_test=" + string(ai_numtest), 1, dw_1.rowCount())
IF ll_row > 0 THEN
	dw_1.setRedraw(FALSE)
	dw_1.object.c_validated[ll_row] = 1
	dw_1.setRedraw(TRUE)
END IF

end subroutine

on w_validqgerm_liste.create
int iCurrent
call super::create
this.dw_1=create dw_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_1
end on

on w_validqgerm_liste.destroy
call super::destroy
destroy(this.dw_1)
end on

event resize;call super::resize;dw_1.width = newwidth
dw_1.height = newheight

end event

event ue_init_menu;call super::ue_init_menu;f_menuaction({"m_fermer"})
end event

event ue_open;call super::ue_open;dw_1.uf_sort(FALSE)


end event

event ue_postopen;call super::ue_postopen;IF dw_1.retrieve() = 0 THEN
	gu_message.uf_info("Tous les tests sont validés")
	post close(this)
END IF
end event

type dw_1 from uo_datawindow_multiplerow within w_validqgerm_liste
integer width = 4114
integer height = 2000
integer taborder = 10
string dataobject = "d_sel_validqgerm"
boolean hscrollbar = true
boolean vscrollbar = true
boolean border = true
end type

event ue_help;call super::ue_help;string	ls_reflot
integer	li_numtest, li_status

IF isNull(al_row) OR al_row = 0 THEN return

ls_reflot = string(this.object.ref_lot[al_row])
li_numtest = integer(this.object.num_test[al_row])

IF this.object.c_validated[al_row] = 1 THEN
	gu_message.uf_info("Vous avez déjà validé ce test")
	return
END IF

// si w_qgerm ouvert PAS en mode validation, le fermer et l'ouvrir en mode validation
IF isValid(w_qgerm) THEN
	close(w_qgerm)
END IF
IF NOT isValid(w_qgerm_validation) THEN
	OpenSheet(w_qgerm_validation, gw_mdiframe, 0, Original!)
END IF
// provoquer lecture des données dans w_qgerm_validation
IF IsValid(w_qgerm_validation) THEN
	w_qgerm_validation.SetFocus()
	li_status = w_qgerm_validation.event ue_abandonner()
	IF li_status = 3 OR li_status < 0 THEN
		return
	ELSE
		w_qgerm_validation.post wf_SetKey(ls_reflot, li_numtest, TRUE) // TRUE indique "readonly"
	END IF
END IF

end event

