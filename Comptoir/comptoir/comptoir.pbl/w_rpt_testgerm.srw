//objectcomments Impression de la liste des tests de germination
forward
global type w_rpt_testgerm from w_ancestor_rptpreview
end type
end forward

global type w_rpt_testgerm from w_ancestor_rptpreview
string title = "Liste des tests de germination"
end type
global w_rpt_testgerm w_rpt_testgerm

type variables
uo_ds		ids_petri, ids_substrat
end variables

on w_rpt_testgerm.create
call super::create
end on

on w_rpt_testgerm.destroy
call super::destroy
end on

event ue_init;call super::ue_init;wf_setmodel("TESTGERM")

// init. critères par défaut
wf_ResetDefaults()


end event

event ue_retrieve;call super::ue_retrieve;long		ll_row, ll_nbrows
string	ls_reflot, ls_typetest, ls_typeqte, ls_mod, ls_result
integer	li_numtest, li_nbrep, li_i
decimal	ld_fg

ll_nbrows = AncestorReturnValue

IF ll_nbrows <= 0 THEN 
	gu_message.uf_info("Aucun test ne correspond à votre requête")
	return(ll_nbrows)
END IF

FOR ll_row = 1 TO ll_nbrows
	ls_reflot = dw_1.object.ref_lot[ll_row]
	li_numtest = dw_1.object.num_Test[ll_row]
	ls_typetest = dw_1.object.type_test[ll_row]
	ls_typeqte = dw_1.object.type_qte[ll_row]
	li_nbrep = dw_1.object.nb_rep[ll_row]

	// recopier dans détail infos nécessaires au calcul de la FG
	ids_petri.object.c_type_qte.expression = "'" + ls_typeqte + "'"
	ids_petri.object.c_nbrerep.expression = "'" + string(li_nbrep) + "'"
	ids_substrat.object.c_nbrerep.expression = "'" + string(li_nbrep) + "'"
	
	// copier qté de graines par répétition de l'entête DW_QGERM vers le détail DW_CPT
	FOR li_i = 1 TO li_nbrep
		ls_mod = "c_qterep" + string(li_i) + ".expression = ~"number('" + &
					f_string(dw_1.getitemdecimal(ll_row, "qte_rep" + string(li_i))) + "')~""
		ls_result = ids_petri.modify(ls_mod)
		IF NOT f_isEmptyString(ls_result) THEN 
			gu_message.uf_error("Erreur ids_petri.modify(" + f_string(ls_mod) + ")")
		END IF
		ls_result = ids_substrat.modify(ls_mod)
		IF NOT f_isEmptyString(ls_result) THEN 
			gu_message.uf_error("Erreur ids_substrat.modify(" + f_string(ls_mod) + ")")
		END IF
	NEXT
	
	// annuler les qtés dans les répétitions non utilisées
	FOR li_i = (li_nbrep + 1) TO 12
		ls_mod = "c_qterep" + string(li_i) + ".expression = ~"dec(c_null)~""
		ids_petri.modify(ls_mod)
		ids_substrat.modify(ls_mod)
	NEXT
	ids_petri.groupcalc()
	ids_substrat.groupcalc()
	
	IF ls_typetest = 'P' THEN
		ids_petri.retrieve(ls_reflot, li_numtest)
		ld_fg = dec(ids_petri.object.c_moygen[1])
	ELSE
		ids_substrat.retrieve(ls_reflot, li_numtest)
		ld_fg = dec(ids_substrat.object.c_moygen[1])
	END IF
	IF ld_fg = 0 THEN setnull(ld_fg)
	dw_1.object.c_fg[ll_row] = ld_fg
NEXT

// imprimer requête en français
dw_1.object.t_requete.text = is_selectinfrench

// nom du service
dw_1.object.t_service.text = gs_nomservice

return(ll_nbrows)
end event

event ue_open;call super::ue_open;ids_petri = CREATE uo_ds
ids_substrat = CREATE uo_ds

ids_petri.dataObject = "d_qgerm_cpt_petri"
ids_petri.setTransObject(SQLCA)

ids_substrat.dataObject = "d_qgerm_cpt_substrat"
ids_substrat.setTransObject(SQLCA)

end event

event ue_close;call super::ue_close;DESTROY ids_petri
DESTROY ids_substrat

end event

type cb_defaults from w_ancestor_rptpreview`cb_defaults within w_rpt_testgerm
end type

type st_2 from w_ancestor_rptpreview`st_2 within w_rpt_testgerm
end type

type st_1 from w_ancestor_rptpreview`st_1 within w_rpt_testgerm
end type

type dw_papersize from w_ancestor_rptpreview`dw_papersize within w_rpt_testgerm
end type

type cb_next from w_ancestor_rptpreview`cb_next within w_rpt_testgerm
end type

type cb_prev from w_ancestor_rptpreview`cb_prev within w_rpt_testgerm
end type

type dw_1 from w_ancestor_rptpreview`dw_1 within w_rpt_testgerm
string dataobject = "d_rpt_testgerm"
end type

type em_zoom from w_ancestor_rptpreview`em_zoom within w_rpt_testgerm
end type

type st_zoom from w_ancestor_rptpreview`st_zoom within w_rpt_testgerm
end type

type gb_1 from w_ancestor_rptpreview`gb_1 within w_rpt_testgerm
end type

type dw_paperorient from w_ancestor_rptpreview`dw_paperorient within w_rpt_testgerm
end type

