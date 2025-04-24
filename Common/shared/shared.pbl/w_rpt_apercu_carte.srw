//objectcomments Rapport : aperçu de la carte
forward
global type w_rpt_apercu_carte from w_ancestor_rptpreview
end type
end forward

global type w_rpt_apercu_carte from w_ancestor_rptpreview
string title = "Aperçu de la carte"
end type
global w_rpt_apercu_carte w_rpt_apercu_carte

type variables
integer	ii_an, ii_anprec, ii_choix
end variables

forward prototypes
public subroutine wf_setdwtitle (string as_title)
public subroutine wf_adjustrowheight ()
public subroutine wf_setimgsize (integer ai_width, integer ai_height)
end prototypes

public subroutine wf_setdwtitle (string as_title);// modifier titre du DW
as_title = gu_stringservices.uf_replaceall(as_title, '"', "'")
dw_1.object.t_titre.text = as_title
end subroutine

public subroutine wf_adjustrowheight ();// le cadre autour de l'image n'est pas fermé quand le detail band est en autosize height,
// workaround : fixer la hauteur un peu plus grande après le calcul automatique
// (fonction posted après modification taille de l'image)
integer	li_height

li_height = integer(dw_1.describe("evaluate('rowheight()',1)"))
dw_1.object.datawindow.detail.height = li_height + 10

end subroutine

public subroutine wf_setimgsize (integer ai_width, integer ai_height);// dimenssionner l'image
dw_1.SetRedraw(FALSE)
dw_1.object.img.width = ai_width
dw_1.object.img.height = ai_height
dw_1.SetRedraw(TRUE)
post wf_adjustrowheight()


end subroutine

on w_rpt_apercu_carte.create
call super::create
end on

on w_rpt_apercu_carte.destroy
call super::destroy
end on

event ue_init;call super::ue_init;// pas de choix de critères
wf_showselection(FALSE)

// l'ordre SQL sur lequel on doit appliquer les critères vient du DW mais on veut passer par ue_manualsql
wf_sqlfromdw(FALSE)
wf_setoriginalselect(dw_1.GetSQLSelect())

end event

event ue_retrieve;call super::ue_retrieve;long		ll_nbrows

ll_nbrows = AncestorReturnValue

// rien à imprimer
IF ll_nbrows <= 0 THEN
	gu_message.uf_info("Aucune donnée à imprimer")
	return(0)
END IF

dw_1.object.t_service.text = gs_nomservice

return(ll_nbrows)
end event

event ue_manualsql;call super::ue_manualsql;integer	li_status

as_newselect = gu_stringservices.uf_replaceall(as_newselect, "path", gs_tmpfiles + "\")
li_status = dw_1.SetSQLSelect(as_newselect)
IF li_status = -1 THEN 
	gu_message.uf_error("Impossible d'assigner l'ordre SQL~n~n" + as_newselect + "~n~n")
	return(-1)
END IF
return(1)

end event

event ue_close;call super::ue_close;filedelete(gs_tmpfiles + "\vwcarte.jpg")
end event

type cb_defaults from w_ancestor_rptpreview`cb_defaults within w_rpt_apercu_carte
end type

type st_2 from w_ancestor_rptpreview`st_2 within w_rpt_apercu_carte
end type

type st_1 from w_ancestor_rptpreview`st_1 within w_rpt_apercu_carte
end type

type dw_papersize from w_ancestor_rptpreview`dw_papersize within w_rpt_apercu_carte
end type

type cb_next from w_ancestor_rptpreview`cb_next within w_rpt_apercu_carte
end type

type cb_prev from w_ancestor_rptpreview`cb_prev within w_rpt_apercu_carte
end type

type dw_1 from w_ancestor_rptpreview`dw_1 within w_rpt_apercu_carte
integer width = 3694
string dataobject = "d_rpt_apercu_carte"
end type

type em_zoom from w_ancestor_rptpreview`em_zoom within w_rpt_apercu_carte
end type

type st_zoom from w_ancestor_rptpreview`st_zoom within w_rpt_apercu_carte
end type

type gb_1 from w_ancestor_rptpreview`gb_1 within w_rpt_apercu_carte
end type

type dw_paperorient from w_ancestor_rptpreview`dw_paperorient within w_rpt_apercu_carte
end type

