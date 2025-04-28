//objectcomments Relevé mensuel
forward
global type w_rpt_mensuel from w_ancestor_rptpreview
end type
end forward

global type w_rpt_mensuel from w_ancestor_rptpreview
string tag = "TEXT_00693"
string title = "Déclaration mensuelle"
end type
global w_rpt_mensuel w_rpt_mensuel

type variables
string	is_matricule, is_option_paiement
integer	ii_annee, ii_mois
end variables

on w_rpt_mensuel.create
call super::create
end on

on w_rpt_mensuel.destroy
call super::destroy
end on

event ue_init;call super::ue_init;str_params	lstr_params

// attribuer un nom de modèle
wf_setmodel("MENSUEL")

// Choix du matricule, année, mois et choix de paiement
Open(w_options_dec_mensuel)
IF Message.DoubleParm = -1 THEN
	post close(this)
	return
END IF
lstr_params = Message.PowerObjectParm
IF upperbound(lstr_params.a_param) = 4 THEN
	is_matricule = string(lstr_params.a_param[1])
	ii_annee = integer(lstr_params.a_param[2])
	ii_mois = integer(lstr_params.a_param[3])
	is_option_paiement = string(lstr_params.a_param[4])
ELSE
	gu_message.uf_unexp("Erreur d'initialisation")
	post close(this)
	return
END IF

// pas de critères par défaut
wf_ResetDefaults()
wf_ShowSelection(FALSE)
wf_SQLFromDW(FALSE)

end event

event ue_manualsql;call super::ue_manualsql;string	ls_sql, ls_where

ls_sql = dw_1.GetSqlselect()
ls_where = "v_realise.matricule='" + is_matricule + "' and v_realise.annee_cal=" + string(ii_annee) + &
			  " and to_char(v_realise.datep,'MM')='" + string(ii_mois,"00") + "'"
ls_sql = f_modifysql(ls_sql, ls_where, "", "")
dw_1.SetSqlselect(ls_sql)
return(1)
end event

event ue_retrieve;call super::ue_retrieve;long		ll_rows, ll_count
string	ls_texte_paiement

ll_rows = AncestorReturnValue

IF ll_rows <= 0 THEN 
	gu_message.uf_info(gu_translate.uf_getlabel(is_tag_nodata, "Aucune donnée ne correspond à votre requête"))
	return(ll_rows)
ELSE
	// traduction après le retrieve sinon les nested reports ne sont pas disponibles
	this.setredraw(FALSE)
	event ue_translate()
	this.setredraw(TRUE)
	
	// mode de paiement
	CHOOSE CASE is_option_paiement
		CASE "NO"
			ls_texte_paiement = gu_translate.uf_getlabel("TEXT_00716", "Pas de demande.")
		CASE "BONIF"
			ls_texte_paiement = gu_translate.uf_getlabel("TEXT_00718", "Je désire être payé des heures de bonification") + "."
		CASE "ALL"
			ls_texte_paiement = gu_translate.uf_getlabel("TEXT_00719", "Je désire être payé de toutes les heures") + "."
		CASE ELSE
			ls_texte_paiement = gu_translate.uf_getlabel("TEXT_00717", "Je désire être payé de") + &
									  " " + is_option_paiement + " " + &
									  gu_translate.uf_getlabel("TEXT_00720", "heure(s)") + "."
	END CHOOSE
	
	// afficher complément d'info (demande de paiement et/ou allocation travaux lourds) s'il y en a
	// PCO 07/06/2016 : suite problèmes de mise en page (page blanche si calendrier des CR est en bas de page
	// et qu'il n'y a ni allocation pour TL ni demande de paiement), j'affiche maintenant toujours une DP.
	dw_1.object.t_paiement.text = gu_translate.uf_getlabel("TEXT_00715", "Demande de paiement ") + &
											" : " + ls_texte_paiement

END IF

return(ll_rows)
end event

event ue_before_ueopen;call super::ue_before_ueopen;// Report avec nested : reporter traduction après lecture des données (voir ue_retrieve)
wf_deferTranslate(TRUE)
end event

type cb_defaults from w_ancestor_rptpreview`cb_defaults within w_rpt_mensuel
end type

type st_2 from w_ancestor_rptpreview`st_2 within w_rpt_mensuel
end type

type st_1 from w_ancestor_rptpreview`st_1 within w_rpt_mensuel
end type

type dw_papersize from w_ancestor_rptpreview`dw_papersize within w_rpt_mensuel
end type

type cb_next from w_ancestor_rptpreview`cb_next within w_rpt_mensuel
end type

type cb_prev from w_ancestor_rptpreview`cb_prev within w_rpt_mensuel
end type

type dw_1 from w_ancestor_rptpreview`dw_1 within w_rpt_mensuel
string dataobject = "d_rpt_mensuel"
end type

type em_zoom from w_ancestor_rptpreview`em_zoom within w_rpt_mensuel
end type

type st_zoom from w_ancestor_rptpreview`st_zoom within w_rpt_mensuel
end type

type gb_1 from w_ancestor_rptpreview`gb_1 within w_rpt_mensuel
end type

type dw_paperorient from w_ancestor_rptpreview`dw_paperorient within w_rpt_mensuel
end type

