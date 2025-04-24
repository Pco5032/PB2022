//objectcomments Annulation d'une commande
forward
global type w_annulation_commande from w_ancestor_dataentry
end type
type dw_entete from uo_datawindow_singlerow within w_annulation_commande
end type
type dw_detail from uo_datawindow_multiplerow within w_annulation_commande
end type
type cb_annul from uo_cb within w_annulation_commande
end type
type dw_flux from uo_datawindow_multiplerow within w_annulation_commande
end type
type str_del from structure within w_annulation_commande
end type
end forward

type str_del from structure
	string		s_reflot
	decimal { 3}		d_qtedel
end type

global type w_annulation_commande from w_ancestor_dataentry
integer width = 3397
integer height = 2416
string title = "Annulation d~'une commande"
boolean resizable = true
dw_entete dw_entete
dw_detail dw_detail
cb_annul cb_annul
dw_flux dw_flux
end type
global w_annulation_commande w_annulation_commande

type variables
integer		ii_ancmde, ii_numcmde

end variables

forward prototypes
public function integer wf_init ()
public function integer wf_newflux (string as_reflot, string as_utilisation, decimal ad_qte, string as_remarque)
end prototypes

public function integer wf_init ();string	ls_saison, ls_client, ls_nom, ls_reflot, ls_codesp
integer	li_cat
long		ll_row
decimal{3}	ld_qte

// lecture des traductions pour record existant
// nom du client
ls_client = dw_entete.object.client[1]
select interlocuteur into :ls_nom from interlocuteur where locu = :ls_client using ESQLCA;
IF f_check_sql(ESQLCA) = 0 THEN
	dw_entete.object.c_client[1] = ls_nom
END IF
	
// saison du catalogue
li_cat = dw_entete.object.num_cat[1]
select saison into :ls_saison from cat_vente where num_cat = :li_cat using ESQLCA;
IF f_check_sql(ESQLCA) = 0 THEN
	dw_entete.object.c_saison[1] = ls_saison
END IF
	
// lectures des lignes de la commande
dw_detail.retrieve(ii_ancmde, ii_numcmde)
	
// disabler la clé
dw_entete.uf_disablekeys()

// activer le bouton d'annulation
cb_annul.enabled = TRUE

return(1)
end function

public function integer wf_newflux (string as_reflot, string as_utilisation, decimal ad_qte, string as_remarque);long		ll_newrow
integer	li_maxnum

IF ad_qte = 0 THEN
	return(1)
END IF

ll_newrow = dw_flux.insertrow(0)
IF ll_newrow < 0 THEN 
	populateerror(20000,"")
	gu_message.uf_unexp("erreur insertrow ads_flux")
	return(-1)
END IF

dw_flux.object.ref_lot[ll_newrow] = as_reflot
// lire le n° de flux max dans les flux du lot en cours
dw_flux.GroupCalc()
li_maxnum = dw_flux.object.c_maxnum[ll_newrow]
IF IsNull(li_maxnum) OR li_maxnum = 0 THEN
	select max(num_flux) into :li_maxnum from flux_registre 
		where ref_lot=:as_reflot group by ref_lot using ESQLCA;
	IF f_check_sql(ESQLCA) < 0 THEN
		populateerror(20000,"")
		gu_message.uf_unexp("erreur select FLUX_REGISTRE")
		return(-1)
	END IF
END IF
IF isNull(li_maxnum) OR li_maxnum = 0 THEN
	li_maxnum = 1
ELSE
	li_maxnum = li_maxnum + 1
END IF
IF li_maxnum > 999 THEN
	gu_message.uf_error("Erreur : plus de 999 flux pour le même lot !")
	return(-1)
END IF

dw_flux.object.num_flux[ll_newrow] = li_maxnum
dw_flux.object.utilisation[ll_newrow] = as_utilisation
dw_flux.object.lieu_stock[ll_newrow] = "-"
dw_flux.object.dt_op[ll_newrow] = f_today()
dw_flux.object.qte[ll_newrow] = ad_qte
dw_flux.object.destinataire[ll_newrow] = dw_entete.object.client[1]
dw_flux.object.remarque[ll_newrow] = as_remarque
dw_flux.object.an_cmde[ll_newrow] = ii_ancmde
dw_flux.object.num_cmde[ll_newrow] = ii_numcmde

return(1)
end function

on w_annulation_commande.create
int iCurrent
call super::create
this.dw_entete=create dw_entete
this.dw_detail=create dw_detail
this.cb_annul=create cb_annul
this.dw_flux=create dw_flux
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_entete
this.Control[iCurrent+2]=this.dw_detail
this.Control[iCurrent+3]=this.cb_annul
this.Control[iCurrent+4]=this.dw_flux
end on

on w_annulation_commande.destroy
call super::destroy
destroy(this.dw_entete)
destroy(this.dw_detail)
destroy(this.cb_annul)
destroy(this.dw_flux)
end on

event ue_open;call super::ue_open;ii_ancmde = year(today())
end event

event ue_init_win;call super::ue_init_win;SetNull(ii_numcmde)
cb_annul.enabled = FALSE

this.setredraw(FALSE)

dw_entete.uf_reset()
dw_detail.uf_reset()
dw_flux.uf_reset()

dw_entete.insertrow(0)

dw_entete.uf_disabledata()
dw_entete.uf_enablekeys()
dw_detail.uf_disabledata()

IF IsNull(ii_ancmde) THEN
	dw_entete.object.an_cmde[1] = 0
	dw_entete.Setcolumn("an_cmde")
ELSE
	dw_entete.uf_setdefaultvalue(1, "an_cmde", ii_ancmde)
	dw_entete.Setcolumn("num_cmde")
END IF
dw_entete.setfocus()

this.setredraw(TRUE)
end event

event ue_init_inactivewin;call super::ue_init_inactivewin;SetNull(ii_ancmde)
end event

event ue_init_menu;call super::ue_init_menu;string	ls_menu[]
integer	li_item

li_item = 2
ls_menu = {"m_abandonner", "m_fermer"}

f_menuaction(ls_menu)
end event

event resize;call super::resize;dw_detail.height = newheight - 900
dw_detail.width = newwidth
cb_annul.y = dw_detail.y + dw_detail.height + 32
cb_annul.x = newwidth / 2 - cb_annul.width / 2

end event

type ddlb_message from w_ancestor_dataentry`ddlb_message within w_annulation_commande
integer y = 2208
end type

type dw_entete from uo_datawindow_singlerow within w_annulation_commande
integer width = 3346
integer height = 640
integer taborder = 10
boolean bringtotop = true
string dataobject = "d_commande"
end type

event ue_leavekey;call super::ue_leavekey;// quand on quitte la clé, cela veut dire qu'on dispose de données actives dans la fenêtre
wf_actif(true)

// effacer les messages
ddlb_message.reset()

// lecture du record
this.retrieve(ii_ancmde, ii_numcmde)

parent.event ue_init_menu()
post wf_init()

end event

event ue_help;call super::ue_help;str_params	lstr_params

IF IsNull(idwo_currentItem) THEN return
IF idwo_currentItem.protect = "1" THEN return

CHOOSE CASE idwo_currentItem.name
	CASE "an_cmde"
		lstr_params.a_param[1] = 0
		lstr_params.a_param[2] = TRUE
		lstr_params.a_param[3] = FALSE
		openwithparm(w_l_commande, lstr_params)
		IF Message.DoubleParm = -1 THEN 
			return
		ELSE
			lstr_params=Message.PowerObjectParm
			this.SetText(f_string(lstr_params.a_param[1]))
			f_presskey("TAB")
		END IF

	CASE "num_cmde"
		lstr_params.a_param[1] = ii_ancmde
		lstr_params.a_param[2] = TRUE
		lstr_params.a_param[3] = FALSE
		openwithparm(w_l_commande, lstr_params)
		IF Message.DoubleParm = -1 THEN 
			return
		ELSE
			lstr_params=Message.PowerObjectParm
			this.uf_setdefaultvalue(1, "an_cmde", integer(lstr_params.a_param[1]))
			this.SetText(f_string(lstr_params.a_param[2]))
			f_presskey("TAB")
		END IF
END CHOOSE


end event

event ue_checkitem;call super::ue_checkitem;string	ls_statut
integer	li_numcmde
long		ll_count

CHOOSE CASE as_item
	CASE "an_cmde"
		ii_ancmde = integer(as_data)
		return(1)
		
	CASE "num_cmde"
		li_numcmde = integer(as_data)
		select statut into :ls_statut from commande where an_cmde = :ii_ancmde and num_cmde = :li_numcmde
			using ESQLCA;
		IF f_check_sql(ESQLCA) <> 0 THEN
			as_message = "Commande inexistante"
			return(-1)
		END IF
		
		IF ls_statut = "A" THEN
			as_message = "Cette commande a déjà été annulée."
			return(-1)
		END IF
		
		// seules les commandes dont le statut = 'Réceptionnée' ou 'Confirmée/Préparée' peuvent être annulées,
		// et seulement si elles ne contiennent aucune ligne livrée (c-à-d avec un n° de bordereau)
		//
		// Modifications 25/11/2008 : on décide d'autoriser l'annulation d'une commande tant qu'elle n'est
		// pas FACTUREE (c-à-d tant qu'on n'a pas fait la demande de recette).
		IF NOT match(ls_statut,"^[RCPLT]$") THEN
			as_message = "Les commandes facturées ne peuvent pas être annulées"
			return(-1)
		END IF
		
//		select count(*) into :ll_count from detail_cmde where an_cmde = :ii_ancmde and num_cmde = :li_numcmde
//			and num_bord is not null using ESQLCA;
//		IF f_check_sql(ESQLCA) <> 0 THEN
//			as_message = "Erreur SELECT DETAIL_CMDE"
//			return(-1)
//		END IF
//		IF ll_count > 0 THEN
//			as_message = "Au moins une ligne de cette commande a été livrée, elle ne peut être annulée."
//			return(-1)
//		END IF
		
		ii_numcmde = integer(as_data)
		return(1)
		
END CHOOSE

return(1)

end event

type dw_detail from uo_datawindow_multiplerow within w_annulation_commande
integer y = 640
integer width = 3346
integer height = 1392
integer taborder = 11
boolean bringtotop = true
string dataobject = "d_detailcmde"
boolean vscrollbar = true
boolean border = true
end type

type cb_annul from uo_cb within w_annulation_commande
integer x = 933
integer y = 2064
integer width = 1298
integer taborder = 21
boolean bringtotop = true
boolean enabled = false
string text = "Annuler cette commande"
end type

event clicked;call super::clicked;// annuler la commande
long	ll_row
integer	li_status
string	ls_client
decimal{2}	ld_montantrf, ld_montantrf2

IF gu_message.uf_query("Désirez-vous réellement annuler cette commande ?~n~n" + &
		"Si la commande était déjà confirmée, les quantités confirmées seront rajoutées au stock.~n~n" + &
		"Attention : cette opération est irréversible, une commande annulée ne pourra plus changer de statut !", YesNo!, 2) = 2 THEN
	gu_message.uf_info("Aucune modification effectuée")
	return
END IF

// si la commande avait atteint le statut "confirmé", annuler les sorties de stock
IF match(dw_entete.object.statut[1],"^[CPLT]$") THEN
	FOR ll_row = 1 TO dw_detail.RowCount()
		IF dw_detail.object.qte_confirm[ll_row] = 0 THEN
			CONTINUE
		ELSE
			IF wf_newflux(dw_detail.object.ref_lot[ll_row], "R+", &
					  dw_detail.object.qte_confirm[ll_row], &
					  "Annulation commande " + f_string(ii_ancmde) + "/" + f_string(ii_numcmde)) = -1 THEN
				return(-1)
			END IF
		END IF
	NEXT
END IF

// si la commande prévoyait un remboursement/refacturation, on rajoute le montant au solde du client
IF dw_entete.object.statut[1] <> "R" THEN 
	ls_client = dw_entete.object.client[1]
	ld_montantrf = dw_entete.object.montantrf[1]
	ld_montantrf2 = dw_entete.object.montantrf2[1]
	IF ld_montantrf <> 0 THEN
		update interlocuteur
			set montantrf = montantrf + :ld_montantrf where locu = :ls_client using SQLCA;
		IF f_check_sql(SQLCA) <> 0 THEN
			populateerror(20000,"")
			rollback using SQLCA;
			gu_message.uf_unexp("INTERLOCUTEUR : Erreur lors de la mise à jour de la base de données")
			return(-1)
		END IF
	END IF
	IF ld_montantrf2 <> 0 THEN
		update interlocuteur
			set montantrf2 = montantrf2 + :ld_montantrf2 where locu = :ls_client using SQLCA;
		IF f_check_sql(SQLCA) <> 0 THEN
			populateerror(20000,"")
			rollback using SQLCA;
			gu_message.uf_unexp("INTERLOCUTEUR : Erreur lors de la mise à jour de la base de données")
			return(-1)
		END IF
	END IF
END IF

// annuler les n° de document fournisseur des lignes de commande de sorte qu'on puisse les réutiliser
// dans une nouvelle commande
update detail_cmde
	set num_df_emis = null where an_cmde = :ii_ancmde and num_cmde= :ii_numcmde using SQLCA;
IF f_check_sql(SQLCA) <> 0 THEN
	populateerror(20000,"")
	rollback using SQLCA;
	gu_message.uf_unexp("DETAIL_CMDE : Erreur lors de la mise à jour de la base de données")
	return(-1)
END IF

// conserver le statut initial de la commande et la date d'annulation
dw_entete.object.annul_statut[1] = dw_entete.object.statut[1]
dw_entete.object.annul_dt[1] = f_today()

// changer le statut de la commande
dw_entete.object.statut[1] = "A"

// update le DW contenant les flux dans la même transaction que les DW entête
li_status = gu_dwservices.uf_updatetransact(dw_entete, dw_flux)
CHOOSE CASE li_status
	CASE 1
		gu_message.uf_info("Commande " + string(ii_ancmde) + "/" + f_string(ii_numcmde) + " annulée avec succès")
		parent.event ue_init_win()
		return(1)
	CASE -1
		populateerror(20000,"")
		gu_message.uf_unexp("COMMANDE : Erreur lors de la mise à jour de la base de données")
		return(-1)
	CASE -2
		populateerror(20000,"")
		gu_message.uf_unexp("FLUX_REGISTRE : Erreur lors de la mise à jour de la base de données")
		return(-1)
END CHOOSE

end event

type dw_flux from uo_datawindow_multiplerow within w_annulation_commande
boolean visible = false
integer x = 2505
integer y = 2208
integer width = 640
integer height = 80
integer taborder = 11
boolean bringtotop = true
string dataobject = "ds_cmde_flux"
boolean border = true
borderstyle borderstyle = stylebox!
end type

