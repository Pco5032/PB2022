//objectcomments Affichage des ordres SQL générés par un DW.update
forward
global type w_sqlspy from w_ancestor
end type
type cbx_delete from uo_cbx within w_sqlspy
end type
type cbx_insert from uo_cbx within w_sqlspy
end type
type cbx_update from uo_cbx within w_sqlspy
end type
type cbx_select from uo_cbx within w_sqlspy
end type
type cb_clear from uo_cb within w_sqlspy
end type
type rte_1 from uo_rte within w_sqlspy
end type
type rte_tmp from richtextedit within w_sqlspy
end type
end forward

global type w_sqlspy from w_ancestor
string tag = "TEXT_00110"
integer width = 2053
integer height = 1380
string title = "Traçage SQL"
event ue_enregistrer ( )
event ue_pre_enregistrer ( )
cbx_delete cbx_delete
cbx_insert cbx_insert
cbx_update cbx_update
cbx_select cbx_select
cb_clear cb_clear
rte_1 rte_1
rte_tmp rte_tmp
end type
global w_sqlspy w_sqlspy

type variables
string	is_sqlsyntax


end variables

forward prototypes
public subroutine wf_showsql (string as_objet, sqlpreviewtype a_sqltype, string as_sqlstring, dwbuffer a_buffer, long al_row)
end prototypes

event ue_enregistrer;string ls_pathname, ls_file
integer li_stat
filetype	lft_1

ls_pathname = gs_MyDocuments + "\sqlspy.rtf"
IF GetFileSaveName("Choisissez le nom du fichier", ls_pathname, ls_file, "RTF", &
		"Texte mis en forme (*.RTF), *.RTF" + " *.RTF Fichier texte (*.TXT),*.TXT") <> 1 THEN return

IF upper(RightA(ls_file, 3)) = "RTF" THEN
	lft_1 = FileTypeRichText!
ELSE
	lft_1 = FileTypeText!
END IF

li_stat = rte_1.SaveDocument(ls_pathname, lft_1)
IF li_stat = 1 THEN
	gu_message.uf_info("Le fichier " + ls_pathname + " a été enregistré avec succès")
ELSE
	gu_message.uf_error("Le fichier " + ls_pathname + " n'a pas pu être enregistré")
END IF

end event

event ue_pre_enregistrer;IF wf_canupdate() THEN
	this.event ue_enregistrer()
ELSE
	gu_message.uf_info(wf_GetMessageNoUpdate())
	return
END IF
end event

public subroutine wf_showsql (string as_objet, sqlpreviewtype a_sqltype, string as_sqlstring, dwbuffer a_buffer, long al_row);string	ls_buffer, ls_text, ls_rtf

CHOOSE CASE a_buffer
	CASE Primary!
		ls_buffer = "Primary!"
	CASE Filter!
		ls_buffer = "Filter!"
	CASE Delete!
		ls_buffer = "Delete!"
END CHOOSE

CHOOSE CASE a_sqltype
	CASE PreviewSelect!
		IF NOT cbx_select.checked THEN return
	CASE PreviewInsert!
		IF NOT cbx_insert.checked THEN return
	CASE PreviewDelete!
		IF NOT cbx_delete.checked THEN return
	CASE PreviewUpdate!
		IF NOT cbx_update.checked THEN return
END CHOOSE

// HEADER
ls_text = "DW : " + as_objet + "  Buffer : " + ls_buffer + "  record : " + string(al_row) + "~r~n"
rte_tmp.SelectTextAll()
rte_tmp.Clear()
rte_tmp.ReplaceText(ls_text)
rte_tmp.SelectTextAll()
// underlined
rte_tmp.SetTextStyle (FALSE, TRUE, FALSE, FALSE, FALSE,FALSE)
// blue
rte_tmp.SetTextColor(rgb(0,0,255))
ls_rtf = rte_tmp.Copyrtf()
rte_1.scroll(rte_1.linecount())
rte_1.pastertf(ls_rtf)

// DETAIL
ls_text = as_sqlstring + "~r~n~r~n"
rte_tmp.SelectTextAll()
rte_tmp.Clear()
rte_tmp.ReplaceText(ls_text)
rte_tmp.SelectTextAll()
// not underlined
rte_tmp.SetTextStyle (FALSE, FALSE, FALSE, FALSE, FALSE,FALSE)
// black
rte_tmp.SetTextColor(rgb(0,0,0))
ls_rtf = rte_tmp.Copyrtf()
rte_1.scroll(rte_1.linecount())
rte_1.pastertf(ls_rtf)

rte_1.scroll(rte_1.linecount())

end subroutine

on w_sqlspy.create
int iCurrent
call super::create
this.cbx_delete=create cbx_delete
this.cbx_insert=create cbx_insert
this.cbx_update=create cbx_update
this.cbx_select=create cbx_select
this.cb_clear=create cb_clear
this.rte_1=create rte_1
this.rte_tmp=create rte_tmp
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cbx_delete
this.Control[iCurrent+2]=this.cbx_insert
this.Control[iCurrent+3]=this.cbx_update
this.Control[iCurrent+4]=this.cbx_select
this.Control[iCurrent+5]=this.cb_clear
this.Control[iCurrent+6]=this.rte_1
this.Control[iCurrent+7]=this.rte_tmp
end on

on w_sqlspy.destroy
call super::destroy
destroy(this.cbx_delete)
destroy(this.cbx_insert)
destroy(this.cbx_update)
destroy(this.cbx_select)
destroy(this.cb_clear)
destroy(this.rte_1)
destroy(this.rte_tmp)
end on

event resize;rte_1.width = wf_getwswidth()
rte_1.height = wf_getwsheight() - rte_1.y

end event

event ue_closebyxrejected;call super::ue_closebyxrejected;gu_message.uf_info("Utilisez le menu pour stopper le traçage SQL")

end event

event ue_init_menu;call super::ue_init_menu;f_menuaction({"m_enregistrer"})
end event

event deactivate;call super::deactivate;// reset current directory to gs_startpath
ChangeDirectory(gs_startpath)
end event

event open;call super::open;wf_CloseByXPermitted(FALSE)
end event

event ue_open;call super::ue_open;// ne pas logger de message lors de l'utilisation de cette fenêtre
wf_logusage(FALSE)
end event

type cbx_delete from uo_cbx within w_sqlspy
integer x = 969
integer y = 16
integer width = 311
integer taborder = 40
string text = "Delete"
boolean checked = true
end type

type cbx_insert from uo_cbx within w_sqlspy
integer x = 640
integer y = 16
integer width = 311
integer taborder = 30
string text = "Insert"
boolean checked = true
end type

type cbx_update from uo_cbx within w_sqlspy
integer x = 311
integer y = 16
integer width = 311
integer taborder = 20
string text = "Update"
boolean checked = true
end type

type cbx_select from uo_cbx within w_sqlspy
integer y = 16
integer width = 311
integer taborder = 10
string text = "Select"
boolean checked = true
end type

type cb_clear from uo_cb within w_sqlspy
string tag = "TEXT_00111"
integer x = 1499
integer width = 311
integer height = 96
integer taborder = 50
string text = "Clear"
end type

event clicked;call super::clicked;//rte_1.displayonly = FALSE
rte_1.selectTextAll()
rte_1.clear()
is_sqlsyntax = ""
//rte_1.displayonly = TRUE
end event

type rte_1 from uo_rte within w_sqlspy
integer y = 96
integer width = 1993
integer height = 1008
boolean init_vscrollbar = true
boolean init_wordwrap = true
end type

type rte_tmp from richtextedit within w_sqlspy
boolean visible = false
integer x = 18
integer y = 1136
integer width = 421
integer height = 112
borderstyle borderstyle = stylelowered!
end type

