//objectcomments Impression des certificats maîtres
forward
global type w_rpt_certificat from w_ancestor_rptpreview
end type
end forward

global type w_rpt_certificat from w_ancestor_rptpreview
string title = "Certificats-maîtres"
end type
global w_rpt_certificat w_rpt_certificat

type variables
string	is_numcm
end variables

on w_rpt_certificat.create
call super::create
end on

on w_rpt_certificat.destroy
call super::destroy
end on

event ue_init;call super::ue_init;integer	li_choix
str_params	lstr_params

// attribuer un nom de modèle
wf_setmodel("CERTIFICATM")

// ce report doit recevoir un paramètre lui indiquant le type de certificat à imprimer (1, 2 ou 3)
// (si 2 paramètres et non 1 seul, c'est que l'impression est demandée directement depuis le programme d'encodage)
lstr_params = Message.PowerObjectParm
IF upperbound(lstr_params.a_param) = 1 THEN
	li_choix = integer(lstr_params.a_param[1])
END IF

IF upperbound(lstr_params.a_param) = 2 THEN
	li_choix = integer(lstr_params.a_param[1])
	is_numcm = string(lstr_params.a_param[2])
END IF

// modifications du DWObject en fonction du choix de report
CHOOSE CASE li_choix
	CASE 1
		wf_SetDataobject("d_rpt_certificat_1")
		wf_setTitle("MFR issus de sources de graines et de peuplements")
		wf_setReportCritere("w_rpt_certificat1")
	CASE 2
		wf_SetDataobject("d_rpt_certificat_2")
		wf_setTitle("MFR issus de vergers à graines ou de parents de famille(s)")
		wf_setReportCritere("w_rpt_certificat2")
	CASE 3
		wf_SetDataobject("d_rpt_certificat_3")
		wf_setTitle("MFR issus de clones et de mélanges clonaux")
		wf_setReportCritere("w_rpt_certificat3")
END CHOOSE

IF upperbound(lstr_params.a_param) = 1 THEN
	// effacer les anciens critères par défaut et en établir de nouveaux
	wf_ResetDefaults()
	wf_setDefault("certificat.num_cm","=")
ELSE
	// pas de critères par défaut
	wf_ResetDefaults()
	wf_ShowSelection(FALSE)
	wf_SQLFromDW(FALSE)
END IF


end event

event ue_retrieve;call super::ue_retrieve;long	ll_rows

ll_rows = AncestorReturnValue

IF ll_rows <= 0 THEN 
	gu_message.uf_info("Aucun certificat ne correspond à votre requête")
	return(ll_rows)
END IF

return(ll_rows)
end event

event ue_manualsql;call super::ue_manualsql;string	ls_sql, ls_where

ls_sql = dw_1.GetSqlselect()
ls_where = "certificat.num_cm='" + is_numcm + "'"
ls_sql = f_modifysql(ls_sql, ls_where, "", "")
dw_1.SetSqlselect(ls_sql)
return(1)
end event

type cb_defaults from w_ancestor_rptpreview`cb_defaults within w_rpt_certificat
end type

type st_2 from w_ancestor_rptpreview`st_2 within w_rpt_certificat
end type

type st_1 from w_ancestor_rptpreview`st_1 within w_rpt_certificat
end type

type dw_papersize from w_ancestor_rptpreview`dw_papersize within w_rpt_certificat
end type

type cb_next from w_ancestor_rptpreview`cb_next within w_rpt_certificat
end type

type cb_prev from w_ancestor_rptpreview`cb_prev within w_rpt_certificat
end type

type dw_1 from w_ancestor_rptpreview`dw_1 within w_rpt_certificat
string dataobject = "d_rpt_certificat_1"
end type

type em_zoom from w_ancestor_rptpreview`em_zoom within w_rpt_certificat
end type

type st_zoom from w_ancestor_rptpreview`st_zoom within w_rpt_certificat
end type

type gb_1 from w_ancestor_rptpreview`gb_1 within w_rpt_certificat
end type

type dw_paperorient from w_ancestor_rptpreview`dw_paperorient within w_rpt_certificat
end type

