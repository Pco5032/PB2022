forward
global type w_qgerm_validation from w_qgerm
end type
type cb_valid from uo_cb within w_qgerm_validation
end type
end forward

global type w_qgerm_validation from w_qgerm
string title = "Validation d~'un test de germination"
cb_valid cb_valid
end type
global w_qgerm_validation w_qgerm_validation

on w_qgerm_validation.create
int iCurrent
call super::create
this.cb_valid=create cb_valid
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_valid
end on

on w_qgerm_validation.destroy
call super::destroy
destroy(this.cb_valid)
end on

event ue_open;// ATTENTION : override ancestor's script pour pouvoir initialise ib_validation à TRUE
ib_validation = TRUE
call super::ue_open
end event

event resize;call super::resize;dw_cpt.height = newheight - dw_qgerm.height - cb_valid.height - 120
dw_cpt.width = newwidth
cb_valid.y = dw_cpt.y + dw_cpt.height + 20
cb_valid.x = (newwidth / 2) - (cb_valid.width / 2)

end event

type ddlb_message from w_qgerm`ddlb_message within w_qgerm_validation
end type

type dw_cpt from w_qgerm`dw_cpt within w_qgerm_validation
end type

type dw_qgerm from w_qgerm`dw_qgerm within w_qgerm_validation
end type

type cb_valid from uo_cb within w_qgerm_validation
integer x = 1189
integer y = 1840
integer width = 805
integer taborder = 31
boolean bringtotop = true
integer textsize = -12
string text = "Valider ce test"
end type

event clicked;call super::clicked;IF wf_valid_registre() = 1 THEN
	gu_message.uf_info("Test validé avec succès")
	parent.event ue_init_win()
END IF
end event

