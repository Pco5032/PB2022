//objectcomments Calendrier des activités planifiées
forward
global type w_rpt_calendrier_planning from w_ancestor_rptpreview
end type
end forward

global type w_rpt_calendrier_planning from w_ancestor_rptpreview
string tag = "TEXT_00695"
string title = "Calendrier des activités planifiées"
end type
global w_rpt_calendrier_planning w_rpt_calendrier_planning

type variables
string	is_prepose[]
date		idt_debut, idt_fin
end variables

on w_rpt_calendrier_planning.create
call super::create
end on

on w_rpt_calendrier_planning.destroy
call super::destroy
end on

event ue_init;call super::ue_init;str_params	lstr_params
long	ll_row

// attribuer un nom de modèle
wf_setmodel("CALPLAN")

// Choix de l'intervale de dates et des préposés
Open(w_options_calendrier_planning)
IF Message.DoubleParm = -1 THEN
	post close(this)
	return
END IF
lstr_params = Message.PowerObjectParm
IF upperbound(lstr_params.a_param) = 3 THEN
	idt_debut = date(lstr_params.a_param[1])
	idt_fin = date(lstr_params.a_param[2])
	is_prepose = lstr_params.a_param[3]
ELSE
	gu_message.uf_unexp("Erreur d'initialisation")
	post close(this)
END IF

// stocker dans table temporaire (au sens oracle) la liste des préposés. Cette table
// sera utilisée dans les nested DW et vidée lors du commit après retrieve.
FOR ll_row = 1 TO upperbound(is_prepose)
	insert into t_matricule (matricule) values (:is_prepose[ll_row]) using SQLCA;
NEXT
	
// pas de critères par défaut
wf_ResetDefaults()
wf_ShowSelection(FALSE)
// ne pas modifier le SQL dans le DW principal car il contient des arguments de retrieve
wf_sqlfromdw(FALSE)

end event

event ue_retrieve;// OVERRIDE ancestor's script (retrieve avec arguments)
long	ll_rows

iu_wait.uf_openwindow()
iu_wait.uf_addinfo(gu_translate.uf_getlabel(is_tag_reading, "Lecture des données"))
ll_rows = dw_1.retrieve(idt_debut, idt_fin)

// commit pour s'assurer que le contenu de la table temporaire T_MATRICULE sera supprimé
commit using SQLCA;

IF ll_rows = -1 THEN
	iu_wait.uf_closewindow()
	return(-1)
END IF
iu_wait.uf_closewindow()

IF ll_rows = 0 THEN
	gu_message.uf_info(gu_translate.uf_getlabel(is_tag_nodata, "Aucune donnée ne correspond à votre requête"))
	return(ll_rows)
END IF

// traduction après le retrieve sinon les nested reports ne sont pas disponibles
this.setredraw(FALSE)
event ue_translate()
this.setredraw(TRUE)

return(ll_rows)

end event

event ue_before_ueopen;call super::ue_before_ueopen;// Report avec nested : reporter traduction après lecture des données (voir ue_retrieve)
wf_deferTranslate(TRUE)
end event

type cb_defaults from w_ancestor_rptpreview`cb_defaults within w_rpt_calendrier_planning
end type

type st_2 from w_ancestor_rptpreview`st_2 within w_rpt_calendrier_planning
end type

type st_1 from w_ancestor_rptpreview`st_1 within w_rpt_calendrier_planning
end type

type dw_papersize from w_ancestor_rptpreview`dw_papersize within w_rpt_calendrier_planning
end type

type cb_next from w_ancestor_rptpreview`cb_next within w_rpt_calendrier_planning
end type

type cb_prev from w_ancestor_rptpreview`cb_prev within w_rpt_calendrier_planning
end type

type dw_1 from w_ancestor_rptpreview`dw_1 within w_rpt_calendrier_planning
string dataobject = "d_rpt_calendrier_planning"
end type

type em_zoom from w_ancestor_rptpreview`em_zoom within w_rpt_calendrier_planning
end type

type st_zoom from w_ancestor_rptpreview`st_zoom within w_rpt_calendrier_planning
end type

type gb_1 from w_ancestor_rptpreview`gb_1 within w_rpt_calendrier_planning
end type

type dw_paperorient from w_ancestor_rptpreview`dw_paperorient within w_rpt_calendrier_planning
end type

