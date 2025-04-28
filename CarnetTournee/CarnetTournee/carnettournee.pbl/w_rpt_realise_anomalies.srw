//objectcomments Activités réalisées : détection des anomalies d'encodage
forward
global type w_rpt_realise_anomalies from w_ancestor_rptpreview
end type
end forward

global type w_rpt_realise_anomalies from w_ancestor_rptpreview
string tag = "TEXT_00815"
string title = "Vérification de la cohérence des activités réalisées"
end type
global w_rpt_realise_anomalies w_rpt_realise_anomalies

type variables
string	is_prepose[]
date		idt_debut, idt_fin
integer	ii_annee, ii_semaine
date		idt_from, idt_to
end variables

on w_rpt_realise_anomalies.create
call super::create
end on

on w_rpt_realise_anomalies.destroy
call super::destroy
end on

event ue_init;call super::ue_init;str_params	lstr_params
long	ll_row

// attribuer un nom de modèle
wf_setmodel("REALANO")

// Si la sélection n'est pas directement passée en argument (cas où l'on a cliqué sur le bouton
// de vérification à partir du programme d'encodage des activités), alors on affiche l'écran de sélection.
lstr_params = im_Message.PowerObjectParm
IF NOT isValid(lstr_params) THEN
	// Choix de la semaine et des préposés dont on veut vérifier les activités planifiées
	// Argument "R" indique au programme de sélection qu'on traite du réalisé.
	OpenWithParm(w_selection_rpt_anomalies_encodage, "R")
	IF Message.DoubleParm = -1 THEN
		post close(this)
		return
	END IF
	lstr_params = Message.PowerObjectParm
END IF

// Récupérer les arguments.
// Si la période est une semaine particulière, elle est donnée par les arguments 1 et 2. 
// Sinon, si la période a été choisie en encodant directement des dates de début et de fin, ces arguments sont NULLS 
// et il faut utiliser les dates de début et de fin données par les arguments 3 et 4.
IF upperbound(lstr_params.a_param) = 5 THEN
	ii_annee = integer(lstr_params.a_param[1])
	ii_semaine = integer(lstr_params.a_param[2])
	idt_from = date(lstr_params.a_param[3])
	idt_to = date(lstr_params.a_param[4])
	is_prepose = lstr_params.a_param[5]
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

iu_wait.uf_addinfo(gu_translate.uf_getlabel(is_tag_reading, "Lecture des données"))
ll_rows = dw_1.retrieve(ii_annee, ii_semaine, idt_from, idt_to)

// commit pour s'assurer que le contenu de la table temporaire T_MATRICULE sera supprimé
commit using SQLCA;

IF ll_rows = -1 THEN
	iu_wait.uf_closewindow()
	return(-1)
END IF

IF ll_rows = 0 THEN
	iu_wait.uf_closewindow()
	gu_message.uf_info(gu_translate.uf_getlabel(is_tag_nodata, "Aucune donnée ne correspond à votre requête"))
	return(ll_rows)
END IF

// traduction après le retrieve sinon les nested reports ne sont pas disponibles
this.setredraw(FALSE)
event ue_translate()
this.setredraw(TRUE)

iu_wait.uf_closewindow()

return(ll_rows)

end event

event ue_before_ueopen;call super::ue_before_ueopen;// Report avec nested : reporter traduction après lecture des données (voir ue_retrieve)
wf_deferTranslate(TRUE)
end event

type cb_defaults from w_ancestor_rptpreview`cb_defaults within w_rpt_realise_anomalies
end type

type st_2 from w_ancestor_rptpreview`st_2 within w_rpt_realise_anomalies
end type

type st_1 from w_ancestor_rptpreview`st_1 within w_rpt_realise_anomalies
end type

type dw_papersize from w_ancestor_rptpreview`dw_papersize within w_rpt_realise_anomalies
end type

type cb_next from w_ancestor_rptpreview`cb_next within w_rpt_realise_anomalies
end type

type cb_prev from w_ancestor_rptpreview`cb_prev within w_rpt_realise_anomalies
end type

type dw_1 from w_ancestor_rptpreview`dw_1 within w_rpt_realise_anomalies
string dataobject = "d_rpt_realise_anomalies"
end type

type em_zoom from w_ancestor_rptpreview`em_zoom within w_rpt_realise_anomalies
end type

type st_zoom from w_ancestor_rptpreview`st_zoom within w_rpt_realise_anomalies
end type

type gb_1 from w_ancestor_rptpreview`gb_1 within w_rpt_realise_anomalies
end type

type dw_paperorient from w_ancestor_rptpreview`dw_paperorient within w_rpt_realise_anomalies
end type

