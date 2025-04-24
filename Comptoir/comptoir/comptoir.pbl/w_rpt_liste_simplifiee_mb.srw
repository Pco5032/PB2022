//objectcomments Impression de la liste simplifiée du MB
forward
global type w_rpt_liste_simplifiee_mb from w_ancestor_rptpreview
end type
end forward

global type w_rpt_liste_simplifiee_mb from w_ancestor_rptpreview
string title = "Liste simplifiée du matériel de base"
end type
global w_rpt_liste_simplifiee_mb w_rpt_liste_simplifiee_mb

type variables

end variables

on w_rpt_liste_simplifiee_mb.create
call super::create
end on

on w_rpt_liste_simplifiee_mb.destroy
call super::destroy
end on

event ue_init;call super::ue_init;string	ls_sql
DataWindowChild l_dwc
integer	li_st

wf_setmodel("DICOPROVREC")

// pas de critères par défaut
wf_ResetDefaults()

// tri par défaut
wf_setDefaultTri("espece.nom_fr")
wf_setDefaultTri("provenance.code_dnf_dict")

// requête à utiliser dans la grille de critère
// (comme le report est en fait un nested report, on ne dispose pas automatiquement de la requête)
wf_sqlFromDW(FALSE)
li_st = dw_1.GetChild('dw_dico', l_dwc)
l_dwc.SetTransObject(SQLCA)
ls_sql = l_dwc.GetSQLSelect()
wf_setOriginalSelect(ls_sql)


end event

event ue_retrieve;// !!! OVERRIDE ANCESTOR'S SCRIPT
DataWindowChild l_dwc
integer	li_st
long	ll_rows

iu_wait.uf_openwindow()
iu_wait.uf_addinfo("Lecture des données")

// appliquer le retrieve sur le nested DW pour qu'il tienne compte du SELECT modifié
li_st = dw_1.GetChild('dw_dico', l_dwc)
l_dwc.SetTransObject(SQLCA)
ll_rows = l_dwc.retrieve()
iu_wait.uf_closewindow()
IF ll_rows <= 0 THEN
	gu_message.uf_info("Aucune donnée ne correspond à votre requête")
	return(0)
END IF

// imprimer requête en français
dw_1.object.t_requete.text = is_selectinfrench

return(ll_rows)

end event

event ue_manualsql;call super::ue_manualsql;// assigner select modifié au nested DW
dw_1.object.dw_dico.object.datawindow.table.select = as_newselect

return(1)

end event

type cb_defaults from w_ancestor_rptpreview`cb_defaults within w_rpt_liste_simplifiee_mb
end type

type st_2 from w_ancestor_rptpreview`st_2 within w_rpt_liste_simplifiee_mb
end type

type st_1 from w_ancestor_rptpreview`st_1 within w_rpt_liste_simplifiee_mb
end type

type dw_papersize from w_ancestor_rptpreview`dw_papersize within w_rpt_liste_simplifiee_mb
end type

type cb_next from w_ancestor_rptpreview`cb_next within w_rpt_liste_simplifiee_mb
end type

type cb_prev from w_ancestor_rptpreview`cb_prev within w_rpt_liste_simplifiee_mb
end type

type dw_1 from w_ancestor_rptpreview`dw_1 within w_rpt_liste_simplifiee_mb
string dataobject = "d_rpt_liste_simplifiee_mb_2"
end type

type em_zoom from w_ancestor_rptpreview`em_zoom within w_rpt_liste_simplifiee_mb
end type

type st_zoom from w_ancestor_rptpreview`st_zoom within w_rpt_liste_simplifiee_mb
end type

type gb_1 from w_ancestor_rptpreview`gb_1 within w_rpt_liste_simplifiee_mb
end type

type dw_paperorient from w_ancestor_rptpreview`dw_paperorient within w_rpt_liste_simplifiee_mb
end type

