//objectcomments Impression des bordereaux récapitulatif de facturation
forward
global type w_rpt_recapliv from w_ancestor_rptpreview
end type
end forward

global type w_rpt_recapliv from w_ancestor_rptpreview
string title = "Bordereau récapitulatif de facturation"
end type
global w_rpt_recapliv w_rpt_recapliv

type variables
integer	ii_ancmde, ii_numcmde, ii_numbord
end variables

on w_rpt_recapliv.create
call super::create
end on

on w_rpt_recapliv.destroy
call super::destroy
end on

event ue_init;call super::ue_init;wf_setmodel("RECAPLIV")

// init. critères par défaut
wf_ResetDefaults()

wf_setInsertionPoint("1=1")

wf_setDefault("c.statut","=","L")
end event

event ue_retrieve;call super::ue_retrieve;long	ll_rows, ll_row
string	ls_err

ll_rows = AncestorReturnValue

IF ll_rows <= 0 THEN 
	gu_message.uf_info("Aucune commande ne correspond à votre requête")
	return(ll_rows)
END IF

// message pour informer des commandes dont le montant à rembourser est > au montant de la facture
FOR ll_row = 1 TO ll_rows
	IF (dw_1.object.v_montant_cmde_pv[ll_row] + dw_1.object.v_montant_cmde_montantrf[ll_row] + dw_1.object.v_montant_cmde_montantrf2[ll_row]) < 0 THEN
		ls_err = ls_err + "Commande " + f_string(dw_1.object.commande_an_cmde[ll_row]) + " / " + &
					f_string(dw_1.object.commande_num_cmde[ll_row]) + " : commande= " + &
					f_string(dw_1.object.v_montant_cmde_pv[ll_row]) + " €, remboursement= " + &
					f_string(dw_1.object.v_montant_cmde_montantrf[ll_row] + dw_1.object.v_montant_cmde_montantrf2[ll_row]) + " €~n"
	END IF
NEXT

// filtrer pour éliminer les commandes dont le montant à rembourser est > au montant de la facture
dw_1.SetFilter("v_montant_cmde_pv + v_montant_cmde_montantrf + v_montant_cmde_montantrf2 >= 0")
dw_1.Filter()

// afficher message avec commande dont le montant à rembourser est > au montant de la facture
IF NOT f_IsEmptyString(ls_err) THEN
	gu_message.uf_info("Attention : le bordereau récapitulatif des commandes suivantes n'est pas imprimé car~n" + &
		 "le montant à rembourser est > au montant de la facture.~n~n" + &
		 "Vous devez corriger cette situation en appelant ces commandes pour modifier le montant à rembourser.~n~n" + ls_err)
END IF

return(ll_rows)
end event

event ue_print;call super::ue_print;string	ls_sql

// Si l'impression a eut lieu et s'est déroulée correctement, les commandes imprimées
// passent à l'état "Terminée" et on met à jour la date du bordereau
IF AncestorReturnValue = 0 THEN return(0)	// = abandon de l'impression

IF gu_message.uf_query("L'impression s'est-elle bien déroulée ?~n~n" + &
	"Si vous le confirmez, les commandes imprimées passeront au statut 'Terminé' et " + &
	"la date d'impression du bordereau sera mise à jour.", YesNo!, 1) = 2 THEN
	gu_message.uf_info("Aucune modification n'a été apportée aux commandes imprimées.")
	return(0)
END IF

//ls_sql = "update commande set statut='T', dt_bord_recap='" + string(f_today()) + &
//			"' where statut='L' and " + is_where
			
ls_sql = "update commande c set c.statut='T', c.dt_bord_recap='" + + string(f_today()) + "' " + &
"where (c.an_cmde, c.num_cmde) in &
(select c.an_cmde, c.num_cmde from commande c, detail_cmde d &
where c.an_cmde=d.an_cmde and c.num_cmde=d.num_cmde and c.statut='L' &
	  and 1=2 &
group by c.an_cmde, c.num_cmde &
having sum(decode(d.qte_confirm,0,0,1)) = sum(decode(num_df_emis, null, 0, 1)))"

ls_sql = f_modifySQL(ls_sql, is_where, "", "1=2")

execute immediate :ls_sql using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	populateError(2000, "")
	rollback using ESQLCA;
	gu_message.uf_unexp("Erreur update COMMANDE : " + f_string(ls_sql))
	return(-1)
ELSE
	IF ESQLCA.sqlnRows > 0 THEN
		gu_message.uf_info(f_string(ESQLCA.sqlnRows) + " commande(s) est (sont) passée(s) au statut 'Terminé'.")
		commit using ESQLCA;
		return(1)
	ELSE
		gu_message.uf_info("Aucune commande ne remplissait les critères pour passer au statut 'Terminé'.")
		return(1)
	END IF
END IF
end event

type cb_defaults from w_ancestor_rptpreview`cb_defaults within w_rpt_recapliv
end type

type st_2 from w_ancestor_rptpreview`st_2 within w_rpt_recapliv
end type

type st_1 from w_ancestor_rptpreview`st_1 within w_rpt_recapliv
end type

type dw_papersize from w_ancestor_rptpreview`dw_papersize within w_rpt_recapliv
end type

type cb_next from w_ancestor_rptpreview`cb_next within w_rpt_recapliv
end type

type cb_prev from w_ancestor_rptpreview`cb_prev within w_rpt_recapliv
end type

type dw_1 from w_ancestor_rptpreview`dw_1 within w_rpt_recapliv
string dataobject = "d_rpt_recapliv"
end type

type em_zoom from w_ancestor_rptpreview`em_zoom within w_rpt_recapliv
end type

type st_zoom from w_ancestor_rptpreview`st_zoom within w_rpt_recapliv
end type

type gb_1 from w_ancestor_rptpreview`gb_1 within w_rpt_recapliv
end type

type dw_paperorient from w_ancestor_rptpreview`dw_paperorient within w_rpt_recapliv
end type

