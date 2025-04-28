forward
global type w_rpt_realise from w_ancestor_rptpreview
end type
end forward

global type w_rpt_realise from w_ancestor_rptpreview
string tag = "TEXT_00670"
string title = "Activités réalisées"
end type
global w_rpt_realise w_rpt_realise

type variables
string	is_matricule
integer	ii_year, ii_week
end variables

on w_rpt_realise.create
call super::create
end on

on w_rpt_realise.destroy
call super::destroy
end on

event ue_init;call super::ue_init;str_params	lstr_params

// attribuer un nom de modèle
wf_setmodel("REALISE")

// ce report doit recevoir un paramètre lui indiquant le réalisé à imprimer
lstr_params = Message.PowerObjectParm
IF upperbound(lstr_params.a_param) = 3 THEN
	is_matricule = string(lstr_params.a_param[1])
	ii_year = integer(lstr_params.a_param[2])
	ii_week = integer(lstr_params.a_param[3])
ELSE
	gu_message.uf_unexp("Erreur d'initialisation")
	post close(this)
END IF

// pas de critères par défaut
wf_ResetDefaults()
wf_ShowSelection(FALSE)
wf_SQLFromDW(FALSE)

end event

event ue_manualsql;call super::ue_manualsql;string	ls_sql, ls_where

ls_sql = dw_1.GetSqlselect()
ls_where = "realise.matricule='" + is_matricule + "' and realise.annee=" + string(ii_year) + &
			  " and realise.semaine=" + string(ii_week)
ls_sql = f_modifysql(ls_sql, ls_where, "", "")
dw_1.SetSqlselect(ls_sql)
return(1)
end event

event ue_retrieve;call super::ue_retrieve;long	ll_rows
string	ls_paiement

ll_rows = AncestorReturnValue

IF ll_rows <= 0 THEN 
	gu_message.uf_info(gu_translate.uf_getlabel(is_tag_nodata, "Aucune donnée ne correspond à votre requête"))
	return(ll_rows)
END IF

// traduction après le retrieve sinon les nested reports ne sont pas disponibles
event ue_translate()

return(ll_rows)
end event

event ue_before_ueopen;call super::ue_before_ueopen;// Report avec nested : reporter traduction après lecture des données (voir ue_retrieve)
wf_deferTranslate(TRUE)
end event

type cb_defaults from w_ancestor_rptpreview`cb_defaults within w_rpt_realise
end type

type st_2 from w_ancestor_rptpreview`st_2 within w_rpt_realise
end type

type st_1 from w_ancestor_rptpreview`st_1 within w_rpt_realise
end type

type dw_papersize from w_ancestor_rptpreview`dw_papersize within w_rpt_realise
end type

type cb_next from w_ancestor_rptpreview`cb_next within w_rpt_realise
end type

type cb_prev from w_ancestor_rptpreview`cb_prev within w_rpt_realise
end type

type dw_1 from w_ancestor_rptpreview`dw_1 within w_rpt_realise
string dataobject = "d_rpt_realise"
end type

type em_zoom from w_ancestor_rptpreview`em_zoom within w_rpt_realise
end type

type st_zoom from w_ancestor_rptpreview`st_zoom within w_rpt_realise
end type

type gb_1 from w_ancestor_rptpreview`gb_1 within w_rpt_realise
end type

type dw_paperorient from w_ancestor_rptpreview`dw_paperorient within w_rpt_realise
end type

