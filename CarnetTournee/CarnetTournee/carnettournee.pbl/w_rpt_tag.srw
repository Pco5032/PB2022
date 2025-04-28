forward
global type w_rpt_tag from w_ancestor_rptpreview
end type
type cb_1 from commandbutton within w_rpt_tag
end type
end forward

global type w_rpt_tag from w_ancestor_rptpreview
string tag = "TEXT_00016"
string title = "Table TAG"
cb_1 cb_1
end type
global w_rpt_tag w_rpt_tag

type variables

end variables

on w_rpt_tag.create
int iCurrent
call super::create
this.cb_1=create cb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_1
end on

on w_rpt_tag.destroy
call super::destroy
destroy(this.cb_1)
end on

event ue_init;call super::ue_init;str_params	lstr_params

// attribuer un nom de modèle
wf_setmodel("TAG")

// pas de critères par défaut
wf_ResetDefaults()
wf_ShowSelection(FALSE)




end event

event ue_retrieve;call super::ue_retrieve;long	ll_rows
string	ls_paiement

ll_rows = AncestorReturnValue

IF ll_rows <= 0 THEN 
	gu_message.uf_info("Aucune donnée ne correspond à votre requête")
	return(ll_rows)
END IF

return(ll_rows)
end event

event ue_open;call super::ue_open;gu_translate.uf_setlanguage("FR")

end event

type cb_defaults from w_ancestor_rptpreview`cb_defaults within w_rpt_tag
end type

type st_2 from w_ancestor_rptpreview`st_2 within w_rpt_tag
end type

type st_1 from w_ancestor_rptpreview`st_1 within w_rpt_tag
end type

type dw_papersize from w_ancestor_rptpreview`dw_papersize within w_rpt_tag
end type

type cb_next from w_ancestor_rptpreview`cb_next within w_rpt_tag
end type

type cb_prev from w_ancestor_rptpreview`cb_prev within w_rpt_tag
end type

type dw_1 from w_ancestor_rptpreview`dw_1 within w_rpt_tag
string dataobject = "d_rpt_translate"
end type

type em_zoom from w_ancestor_rptpreview`em_zoom within w_rpt_tag
end type

type st_zoom from w_ancestor_rptpreview`st_zoom within w_rpt_tag
end type

type gb_1 from w_ancestor_rptpreview`gb_1 within w_rpt_tag
end type

type dw_paperorient from w_ancestor_rptpreview`dw_paperorient within w_rpt_tag
end type

type cb_1 from commandbutton within w_rpt_tag
integer x = 896
integer y = 64
integer width = 425
integer height = 112
integer taborder = 40
boolean bringtotop = true
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "Toggle langue"
end type

event clicked;IF gu_translate.uf_getlanguage() = "FR" THEN
	gu_translate.uf_setlanguage("DE")
ELSE
	gu_translate.uf_setlanguage("FR")
END IF
gu_translate.uf_translatewindow(parent)

end event

