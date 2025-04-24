//objectcomments Impression du tableau de recettes à établir
forward
global type w_rpt_recette from w_ancestor_rptpreview
end type
end forward

global type w_rpt_recette from w_ancestor_rptpreview
string title = "Tableau des ordres de recettes"
end type
global w_rpt_recette w_rpt_recette

type variables
integer	ii_ancmde, ii_numcmde, ii_numbord
end variables

on w_rpt_recette.create
call super::create
end on

on w_rpt_recette.destroy
call super::destroy
end on

event ue_init;call super::ue_init;wf_setmodel("RECETTE")

// init. critères par défaut
wf_ResetDefaults()

wf_setInsertionPoint("1=1")
end event

event ue_retrieve;call super::ue_retrieve;long	ll_rows
uo_ds	lds_saison
string	ls_sql

ll_rows = AncestorReturnValue

IF ll_rows <= 0 THEN 
	gu_message.uf_info("Aucune commande ne correspond à votre requête")
	return(ll_rows)
END IF

// impossible de changer le SELECT dans le nested report, donc astuce :
// utiliser le même dataobject dans un DW que dans le nested report, changer le SELECT,
// faire le retrieve, et recopier le dataset dans le nested !
lds_saison = CREATE uo_ds
lds_saison.dataObject = "d_rpt_recette_saison"
lds_saison.setTransObject(SQLCA)
ls_sql = f_modifySQL(lds_saison.getSQlselect(), is_where, "", "1 = 2")
lds_saison.setSqlSelect(ls_sql)
IF lds_saison.retrieve() > 0 THEN
	dw_1.object.dw_saison[1].object.data = lds_saison.object.data 
END IF
DESTROY lds_saison

return(ll_rows)
end event

event ue_print;call super::ue_print;string	ls_sql

// Si l'impression a eut lieu et s'est déroulée correctement, les commandes imprimées
// passent à l'état "Facturée" et on met à jour la date du bordereau
IF AncestorReturnValue = 0 THEN return(0)	// = abandon de l'impression

IF gu_message.uf_query("L'impression s'est-elle bien déroulée ?~n~n" + &
	"Si vous le confirmez, les commandes imprimées passeront au statut 'Facturée'.~n~n" + &
	"Remarque : après confirmation, il n'est plus possible d'imprimer ce document...", YesNo!, 1) = 2 THEN
	gu_message.uf_info("Aucune modification n'a été apportée aux commandes imprimées.")
	return(0)
END IF

ls_sql = "update commande set statut='F' where (an_cmde, num_cmde) in &
 (SELECT c.an_cmde, c.num_cmde &
  FROM v_montant_cmde c, detail_cmde d &
  WHERE c.an_cmde=d.an_cmde and c.num_cmde=d.num_cmde and c.statut = 'T' and c.pv + c.port > 0 and 1=2 &
  GROUP BY c.an_cmde, c.num_cmde &
  HAVING sum(decode(d.qte_confirm,0,0,1)) = sum(decode(num_df_emis, null, 0, 1)))"
ls_sql = f_modifySql(ls_sql, is_where, "", "1=2")
			
execute immediate :ls_sql using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	populateError(2000, "")
	rollback using ESQLCA;
	gu_message.uf_unexp("Erreur update COMMANDE : " + f_string(ls_sql))
	return(-1)
ELSE
	IF ESQLCA.sqlnRows > 0 THEN
		gu_message.uf_info(f_string(ESQLCA.sqlnRows) + " commande(s) est (sont) passée(s) au statut 'Facturé'.")
		commit using ESQLCA;
		return(1)
	ELSE
		gu_message.uf_info("Aucune commande ne remplissait les critères pour passer au statut 'Facturé'.")
		return(1)
	END IF
END IF
end event

type cb_defaults from w_ancestor_rptpreview`cb_defaults within w_rpt_recette
end type

type st_2 from w_ancestor_rptpreview`st_2 within w_rpt_recette
end type

type st_1 from w_ancestor_rptpreview`st_1 within w_rpt_recette
end type

type dw_papersize from w_ancestor_rptpreview`dw_papersize within w_rpt_recette
end type

type cb_next from w_ancestor_rptpreview`cb_next within w_rpt_recette
end type

type cb_prev from w_ancestor_rptpreview`cb_prev within w_rpt_recette
end type

type dw_1 from w_ancestor_rptpreview`dw_1 within w_rpt_recette
string dataobject = "d_rpt_recette"
end type

type em_zoom from w_ancestor_rptpreview`em_zoom within w_rpt_recette
end type

type st_zoom from w_ancestor_rptpreview`st_zoom within w_rpt_recette
end type

type gb_1 from w_ancestor_rptpreview`gb_1 within w_rpt_recette
end type

type dw_paperorient from w_ancestor_rptpreview`dw_paperorient within w_rpt_recette
end type

