//objectcomments usage général : affichage d'un texte
forward
global type w_rpt_texte from w_ancestor_rptpreview
end type
end forward

global type w_rpt_texte from w_ancestor_rptpreview
string title = ""
end type
global w_rpt_texte w_rpt_texte

forward prototypes
public subroutine wf_settext (string as_text)
end prototypes

public subroutine wf_settext (string as_text);dw_1.object.s_texte[1] = as_text
end subroutine

on w_rpt_texte.create
call super::create
end on

on w_rpt_texte.destroy
call super::destroy
end on

event ue_init;call super::ue_init;wf_showselection(FALSE)
wf_cancel(TRUE)
wf_trienabled(FALSE)
wf_buttonsenabled(FALSE)
wf_sqlfromdw(FALSE)
end event

event ue_retrieve;// !! override ancestor's script
dw_1.insertrow(0)
return(1)
end event

event ue_open;call super::ue_open;// ne pas logger de message lors de l'utilisation de cette fenêtre
wf_logusage(FALSE)
end event

type cb_defaults from w_ancestor_rptpreview`cb_defaults within w_rpt_texte
end type

type st_2 from w_ancestor_rptpreview`st_2 within w_rpt_texte
end type

type st_1 from w_ancestor_rptpreview`st_1 within w_rpt_texte
end type

type dw_papersize from w_ancestor_rptpreview`dw_papersize within w_rpt_texte
end type

type cb_next from w_ancestor_rptpreview`cb_next within w_rpt_texte
end type

type cb_prev from w_ancestor_rptpreview`cb_prev within w_rpt_texte
end type

type dw_1 from w_ancestor_rptpreview`dw_1 within w_rpt_texte
string dataobject = "d_rpt_texte"
end type

type em_zoom from w_ancestor_rptpreview`em_zoom within w_rpt_texte
end type

type st_zoom from w_ancestor_rptpreview`st_zoom within w_rpt_texte
end type

type gb_1 from w_ancestor_rptpreview`gb_1 within w_rpt_texte
end type

type dw_paperorient from w_ancestor_rptpreview`dw_paperorient within w_rpt_texte
end type

