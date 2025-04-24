//objectcomments Impression du dictionnaire des provenances recommandables
forward
global type w_rpt_dico_prov_rec from w_ancestor_rptpreview
end type
end forward

global type w_rpt_dico_prov_rec from w_ancestor_rptpreview
string title = "Dictionnaire des provenances recommandables"
end type
global w_rpt_dico_prov_rec w_rpt_dico_prov_rec

type variables
date	idt_datemaj
end variables

on w_rpt_dico_prov_rec.create
call super::create
end on

on w_rpt_dico_prov_rec.destroy
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

// imprimer légende des codes législatifs
// dw_legende.retrieve()
// wf_setDWFin(dw_legende)

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
// dw_1.object.t_requete.text = is_selectinfrench

// passer date de mise à jour du dico
dw_1.setRedraw(FALSE)
dw_1.object.c_datemaj.expression = "'" + string(idt_datemaj, "dd/mm/yyyy") + "'"
dw_1.setRedraw(TRUE)

// update date de m-à-j
update params set dt_maj_dico=:idt_datemaj using ESQLCA;
IF f_check_sql(ESQLCA) = 0 THEN
	commit using ESQLCA;
ELSE
	rollback using ESQLCA;
END IF

return(ll_rows)

end event

event ue_manualsql;call super::ue_manualsql;// assigner select modifié au nested DW
dw_1.object.dw_dico.object.datawindow.table.select = as_newselect

return(1)

end event

event ue_beforeretrieve;call super::ue_beforeretrieve;// après la sélection, on doit introduire les options d'impression (date de mise à jour du dico)
integer	li_ancestorReturn
str_params	lstr_params

li_ancestorReturn = AncestorReturnValue
IF li_ancestorReturn <> 1 THEN return li_ancestorReturn

Open(w_option_dico_prov)
IF Message.DoubleParm = -1 THEN
	return(0)
END IF

lstr_params = Message.PowerObjectParm
idt_datemaj = date(lstr_params.a_param[1])

return(li_AncestorReturn)

end event

type cb_defaults from w_ancestor_rptpreview`cb_defaults within w_rpt_dico_prov_rec
end type

type st_2 from w_ancestor_rptpreview`st_2 within w_rpt_dico_prov_rec
end type

type st_1 from w_ancestor_rptpreview`st_1 within w_rpt_dico_prov_rec
end type

type dw_papersize from w_ancestor_rptpreview`dw_papersize within w_rpt_dico_prov_rec
end type

type cb_next from w_ancestor_rptpreview`cb_next within w_rpt_dico_prov_rec
end type

type cb_prev from w_ancestor_rptpreview`cb_prev within w_rpt_dico_prov_rec
end type

type dw_1 from w_ancestor_rptpreview`dw_1 within w_rpt_dico_prov_rec
integer width = 3657
integer height = 1920
string dataobject = "d_rpt_dico_prov_rec_2"
end type

type em_zoom from w_ancestor_rptpreview`em_zoom within w_rpt_dico_prov_rec
end type

type st_zoom from w_ancestor_rptpreview`st_zoom within w_rpt_dico_prov_rec
end type

type gb_1 from w_ancestor_rptpreview`gb_1 within w_rpt_dico_prov_rec
end type

type dw_paperorient from w_ancestor_rptpreview`dw_paperorient within w_rpt_dico_prov_rec
end type

