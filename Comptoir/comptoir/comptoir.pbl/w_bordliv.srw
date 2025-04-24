//objectcomments Création d'un bordereau de livraison pour 1 ou plusieurs ligne(s) de commande
forward
global type w_bordliv from w_ancestor_dataentry
end type
type dw_entete from uo_datawindow_singlerow within w_bordliv
end type
type dw_detail from uo_datawindow_multiplerow within w_bordliv
end type
end forward

global type w_bordliv from w_ancestor_dataentry
integer width = 3077
integer height = 2328
string title = "Gestion des bordereaux de livraison"
boolean resizable = true
event ue_print ( )
dw_entete dw_entete
dw_detail dw_detail
end type
global w_bordliv w_bordliv

type variables
uo_cpteur	iu_cpteur
br_bordliv	ibr_bordliv
integer	ii_ancmde, ii_numcmde, ii_numbord, ii_numcat
boolean	ib_ajout, ib_canupdate_org
string	is_statut
end variables

forward prototypes
public function integer wf_init ()
public function integer wf_newbord ()
public subroutine wf_print ()
end prototypes

event ue_print();wf_print()
end event

public function integer wf_init ();string	ls_codesp, ls_reflot
integer	li_num
long		ll_row

// le DW détail doit connaître le statut de la commande
dw_detail.object.c_statut.expression = "'" + is_statut + "'"

IF dw_entete.uf_IsRecordNew() THEN
	// valeurs par défaut pour nouveau record
	dw_entete.uf_setdefaultvalue(1, "dt_bord", f_today())
	dw_entete.uf_setdefaultvalue(1, "frais_port", 0)
END IF

// affichage du n° de catalogue de la commande
dw_entete.object.c_numcat[1] = ii_numcat

// affichage du statut de la commande
dw_entete.object.c_statut[1] = is_statut

// lectures du détail de la commande à laquelle le bordereau fait référence
dw_detail.retrieve(ii_ancmde, ii_numcmde, ii_numbord)

// initialiser le code espèce et le PU de chaque ligne de commande
FOR ll_row = 1 TO dw_detail.RowCount()
	ls_reflot = dw_detail.object.ref_lot[ll_row]
	select code_sp into :ls_codesp
		from v_totflux where ref_lot = :ls_reflot using ESQLCA;
	IF f_check_sql(ESQLCA) = 0 THEN
		dw_detail.object.c_codesp[ll_row] = ls_codesp
	END IF
	dw_detail.SetItemStatus(ll_row,0,Primary!,NotModified!)
NEXT

// disabler la clé et enabler les datas
// Attention : si la commande a un statut autre que 'confirmé' ou 'Préparé', on ne peut plus modifier
//             les bordereaux existants
IF is_statut = "C" OR is_statut = "P" THEN
	dw_entete.uf_enabledata()
	dw_detail.uf_enabledata()
ELSE
	wf_canupdate(FALSE)
	dw_detail.uf_disabledata()
END IF
dw_entete.uf_disablekeys()
dw_entete.SetColumn("dt_bord")

dw_entete.SetItemStatus(1,0,Primary!,NotModified!)
dw_entete.SetFocus()

return(1)
end function

public function integer wf_newbord ();// création d'un nouveau bordereau
decimal	ld_numbord

// le n° commande doit être spécifiée
IF IsNull(ii_ancmde) OR ii_ancmde = 0 OR IsNull(ii_numcmde) OR ii_numcmde = 0 THEN
	gu_message.uf_error("Veuillez d'abord identifier la commande (année et n°)")
	return(-1)
END IF

// prendre nouveau n° d'autorisation via le compteur, le placer dans numaut et passer au champ suivant
ld_numbord = iu_cpteur.uf_getnumbord(ii_ancmde, ii_numcmde)
IF ld_numbord < 0 THEN
	gu_message.uf_error("Impossible d'obtenir un nouveau n° de bordereau pour cette commande !")
	return(-1)
END IF
ib_ajout = TRUE
dw_entete.setfocus()
dw_entete.SetText(string(ld_numbord))
f_presskey ("TAB")

return(1)

end function

public subroutine wf_print ();// impression du bordereau
str_params	lstr_params
long			ll_count

IF ii_ancmde = 0 OR ii_numcmde = 0 OR ii_numbord = 0 THEN
	gu_message.uf_info("Veuillez d'abord afficher le bordereau")
	return
END IF

select count(*) into :ll_count from bord_liv where an_cmde=:ii_ancmde and num_cmde=:ii_numcmde
		and num_bord=:ii_numbord using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	return
END IF
IF ll_count = 0 THEN
	gu_message.uf_info("Vous devez d'abord enregistrer le bordereau avant de pouvoir l'imprimer")
	return
END IF

IF IsValid(w_rpt_bordliv) THEN
	close(w_rpt_bordliv)
END IF

lstr_params.a_param[1] = ii_ancmde
lstr_params.a_param[2] = ii_numcmde
lstr_params.a_param[3] = ii_numbord
OpenSheetWithParm(w_rpt_bordliv, lstr_params, gw_mdiframe, 0, Original!)
IF IsValid(w_rpt_bordliv) THEN
	w_rpt_bordliv.SetFocus()
END IF
end subroutine

on w_bordliv.create
int iCurrent
call super::create
this.dw_entete=create dw_entete
this.dw_detail=create dw_detail
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_entete
this.Control[iCurrent+2]=this.dw_detail
end on

on w_bordliv.destroy
call super::destroy
destroy(this.dw_entete)
destroy(this.dw_detail)
end on

event ue_init_win;call super::ue_init_win;ib_ajout = FALSE

// restaurer le privilège d'update car on a pû le manipuler
wf_canupdate(ib_canupdate_org)

SetNull(ii_numcmde)
this.setredraw(FALSE)

dw_entete.uf_reset()
dw_detail.uf_reset()

dw_entete.insertrow(0)

dw_entete.uf_disabledata()
dw_entete.uf_enablekeys()
IF IsNull(ii_ancmde) THEN
	dw_entete.object.an_cmde[1] = 0
	dw_entete.Setcolumn("an_cmde")
ELSE
	dw_entete.uf_setdefaultvalue(1, "an_cmde", ii_ancmde)
	dw_entete.Setcolumn("num_cmde")
END IF
ii_numcmde = 0
ii_numbord = 0
dw_entete.setfocus()

this.setredraw(TRUE)
end event

event ue_init_inactivewin;call super::ue_init_inactivewin;SetNull(ii_ancmde)
end event

event ue_open;call super::ue_open;ibr_bordliv = CREATE br_bordliv
iu_cpteur = CREATE uo_cpteur

ii_ancmde = year(today())

// action "ajouter" doit être visible dans le menu
wf_SetItemsToShow({"m_ajouter"})

// DW à updater
wf_SetDWList({dw_entete, dw_detail})

// sauver le privilège d'update car on va le manipuler
ib_canupdate_org = wf_canUpdate()
end event

event ue_close;call super::ue_close;DESTROY iu_cpteur
DESTROY ibr_bordliv
end event

event ue_init_menu;call super::ue_init_menu;string	ls_menu[]
integer	li_item

li_item = 2
ls_menu = {"m_abandonner", "m_fermer"}

IF wf_IsActif() THEN
	IF wf_canUpdate() THEN
		li_item++
		ls_menu[li_item] = "m_enregistrer"
	END IF
	CHOOSE CASE wf_GetActivecontrolname()
		// menu si curseur est sur l'entête du bordereau
		CASE "dw_entete"
			IF NOT dw_entete.uf_IsRecordNew() AND wf_canDelete() THEN
				li_item++
				ls_menu[li_item] = "m_supprimer"
			END IF
	END CHOOSE
ELSE
	IF dw_entete.GetColumnName() = "num_bord" AND wf_canUpdate() THEN
		li_item++
		ls_menu[li_item] = "m_ajouter"
	END IF
END IF

f_menuaction(ls_menu)
end event

event ue_ajouter;call super::ue_ajouter;long	ll_row

CHOOSE CASE wf_GetActivecontrolname()
	// ajouter un nouveaux bordereau si le curseur est sur DW_ENTETE et dans l'item NUM_BORD
	CASE "dw_entete"
		IF dw_entete.GetColumnName() = "num_bord" THEN
			wf_newbord()
			return
		END IF
		
END CHOOSE
end event

event ue_enregistrer;call super::ue_enregistrer;long		ll_row
integer	li_Status, li_tot_selected, li_cmde_selected, li_tot_selectable
date		ldt_today

// contrôle de validité de tous les champs
IF dw_entete.event ue_checkall() < 0 THEN
	dw_entete.SetFocus()
	return(-1)
END IF
IF dw_detail.event ue_checkall() < 0 THEN
	dw_detail.SetFocus()
	return(-1)
END IF

// il faut au moins une ligne de commande dans le bordereau, sinon autant le supprimer
li_cmde_selected = dw_detail.object.c_cmde_selected[1]
li_tot_selected = dw_detail.object.c_tot_selected[1]
IF li_cmde_selected = 0 THEN
	gu_message.uf_info("Ce bordereau ne contient rien. Vous devriez le supprimer.")
	return(-1)
END IF

// si toutes les lignes dont la quantité confirmée est > 0 sont dans un bordereau, 
// la commande change de statut et devient "livrée"
dw_detail.setfilter("qte_confirm > 0")
dw_detail.Filter()
li_tot_selectable = dw_detail.rowCount()
dw_detail.setfilter("")
dw_detail.Filter()
IF li_tot_selected = li_tot_selectable THEN
	IF gu_message.uf_query("Toutes les lignes de la commandes étant livrées, la commande va passer au statut 'Livrée'.~n" + &
			  "Par la suite, il sera impossible de modifier le contenu des bordereaux de livraison.~n~n" + &
			  "Etes-vous d'accord pour continuer ?", YesNo!, 1) = 2 THEN
		return(-1)
	ELSE
		ldt_today = f_today()
		// même transaction que les updates de DW
		update commande set statut='L', dt_liv=:ldt_today 
				where an_cmde=:ii_ancmde and num_cmde=:ii_numcmde using SQLCA;
		IF f_check_sql(SQLCA) <> 0 THEN
			populateError(20000, "")
			gu_message.uf_unexp("Erreur update COMMANDE")
			return(-1)
		END IF
	END IF
END IF

// UPDATE
li_status = gu_dwservices.uf_updatetransact(dw_entete, dw_detail)
CHOOSE CASE li_status
	CASE 1
		wf_message("Bordereau " + string(ii_ancmde) + "/" + f_string(ii_numcmde) + "/" + f_string(ii_numbord) + &
					  " enregistré avec succès")
		// si nouveau bordereau, updater compteur
		IF dw_entete.uf_IsRecordNew() THEN
			IF iu_cpteur.uf_update_numbord(ii_ancmde, ii_numcmde, ii_numbord) = -1 THEN
				populateerror(20000, "")
				gu_message.uf_unexp("Erreur mise à jour du compteur BORD_LIV.NUM_BORD")
				return(-1)
			ELSE
				// impression du bordereau ?
				IF gu_message.uf_query("Voulez-vous imprimer ce bordereau immédiatement ?", YesNo!, 2) = 1 THEN
					wf_print()
				END IF
				This.event ue_init_win()
				return(1)
			END IF
		ELSE
			// impression du bordereau ?
			IF gu_message.uf_query("Voulez-vous imprimer ce bordereau immédiatement ?", YesNo!, 2) = 1 THEN
				wf_print()
			END IF
			This.event ue_init_win()
			return(1)
		END IF
	CASE -1
		populateerror(20000,"")
		gu_message.uf_unexp("BORD_LIV : Erreur lors de la mise à jour de la base de données")
		return(-1)
	CASE -2
		populateerror(20000,"")
		gu_message.uf_unexp("DETAIL_CMDE : Erreur lors de la mise à jour de la base de données")
		return(-1)
END CHOOSE


return(1)
end event

event resize;call super::resize;dw_detail.width = newwidth
dw_detail.height = newheight - 500
end event

event ue_supprimer;call super::ue_supprimer;string	ls_message
long		ll_row

CHOOSE CASE wf_GetActivecontrolname()
	// suppression de tout le bordereau
	CASE "dw_entete"
		IF ibr_bordliv.uf_check_beforedelete(ii_ancmde, ii_numcmde, ii_numbord, is_statut, ls_message) = -1 THEN
			gu_message.uf_info(ls_message)
			return
		END IF
		IF f_confirm_del("Voulez-vous supprimer ce bordereau ?") = 1 THEN
			// annuler le n° de bordereau dans les lignes de commandes, puis le deleter, dans la même transaction
			FOR ll_row = 1 TO dw_detail.RowCount()
				IF dw_detail.object.num_bord[ll_row] = ii_numbord THEN
					dw_detail.object.num_bord[ll_row] = gu_c.i_null
				END IF
			NEXT
			IF dw_detail.update() = 1 THEN
				IF dw_entete.event ue_delete() = 1 THEN
					wf_message("Bordereau supprimée avec succès")
					this.event ue_init_win()
				ELSE
					populateError(20000, "")
					gu_message.uf_unexp("Erreur DELETE DW_ENTETE")
					return
				END IF
			ELSE
				populateError(20000, "")
				gu_message.uf_unexp("Erreur UPDATE DW_DETAIL")
				return
			END IF
		END IF
		
END CHOOSE

end event

type ddlb_message from w_ancestor_dataentry`ddlb_message within w_bordliv
end type

type dw_entete from uo_datawindow_singlerow within w_bordliv
integer width = 3035
integer height = 416
integer taborder = 10
boolean bringtotop = true
string dataobject = "d_bord_liv"
end type

event ue_help;call super::ue_help;str_params	lstr_params

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
		
	CASE "num_bord"
		lstr_params.a_param[1] = ii_ancmde
		lstr_params.a_param[2] = TRUE
		lstr_params.a_param[3] = ii_numcmde
		lstr_params.a_param[4] = TRUE
		lstr_params.a_param[5] = FALSE
		openwithparm(w_l_bordliv, lstr_params)
		IF Message.DoubleParm = -1 THEN 
			return
		ELSE
			lstr_params=Message.PowerObjectParm
			this.uf_setdefaultvalue(1, "an_cmde", integer(lstr_params.a_param[1]))
			this.uf_setdefaultvalue(1, "num_cmde", integer(lstr_params.a_param[2]))
			this.SetText(f_string(lstr_params.a_param[3]))
			f_presskey("TAB")
		END IF

END CHOOSE


end event

event ue_checkitem;call super::ue_checkitem;integer	li_numbord, li_status
long		ll_count
string	ls_statut

CHOOSE CASE as_item
	CASE "an_cmde"
		IF ibr_bordliv.uf_check_ancmde(as_data, as_message) = -1 THEN
			return(-1)
		ELSE
			ii_ancmde = integer(as_data)
			return(1)
		END IF
		
	CASE "num_cmde"
		IF ibr_bordliv.uf_check_numcmde(as_data, as_message, ii_ancmde) = -1 THEN
			return(-1)
		ELSE
			ii_numcmde = integer(as_data)
			is_statut = as_message
			return(1)
		END IF
		
	// dernier élément de la clé, vérifier si record existe ou pas
	CASE "num_bord"
		IF ibr_bordliv.uf_check_numbord(as_data, as_message, ii_ancmde, ii_numcmde) = -1 THEN
			iu_cpteur.uf_rollback()
			return(-1)
		END IF
		li_numbord = integer(as_data)
		select count(*) into :ll_count from bord_liv
				where an_cmde = :ii_ancmde and num_cmde = :ii_numcmde and num_bord = :li_numbord using ESQLCA;
		li_status = f_check_sql(ESQLCA)
		IF li_status < 0 OR ll_count > 1 THEN
			populateerror(20000,"")
			gu_message.uf_unexp("Erreur SELECT BORD_LIV")
			return(-1)
		ELSE
			// bordereau inexistant...
			IF ll_count = 0 THEN
				// si le statut de la commande est différent de 'confirmé' ou 'préparé', on ne peut pas
				// créer de bordereau
				IF is_statut <> "C" AND is_statut <> "P" THEN
					as_message = "On ne peut pas créer de bordereau de livraison pour les commandes " + &
									 " dont le statut n'est pas 'confirmé' ni 'Préparé'"
					return(-1)
				END IF
				// ...et on peut modifier les données...
				IF wf_canUpdate() THEN
					IF ib_ajout THEN
						this.uf_NewRecord(TRUE)
						ii_numbord = li_numbord
						return(1)
					ELSE
						as_message = "Bordereau inexistant. Utilisez l'action 'Ajouter' pour en créer un."
						return(-1)
					END IF
				ELSE
				// ...et on ne peut pas modifier les données
					as_message = "Bordereau inexistant. Vous n'avez pas le droit d'en créer..."
					return(-1)
				END IF
			ELSE
			// Bordereau existe déjà : OK
				this.uf_NewRecord(FALSE)
				ii_numbord = li_numbord
				return(1)
			END IF
		END IF

	CASE "dt_bord"
		return(ibr_bordliv.uf_check_dtbord(as_data, as_message))
		
	CASE "type_liv"
		return(ibr_bordliv.uf_check_typeliv(as_data, as_message))
		
	CASE "frais_port"
		return(ibr_bordliv.uf_check_fraisport(as_data, as_message))
	
END CHOOSE

return(1)

end event

event ue_leavekey;call super::ue_leavekey;// quand on quitte la clé, cela veut dire qu'on dispose de données actives dans la fenêtre
wf_actif(true)

// effacer les messages
ddlb_message.reset()

// lecture du record si existe déjà
IF NOT this.uf_IsRecordNew() THEN
	wf_message("Modification d'un bordereau...")
	this.retrieve(ii_ancmde, ii_numcmde, ii_numbord)
ELSE
	wf_message("Nouveau bordereau...")
END IF

parent.event ue_init_menu()
post wf_init()

end event

event getfocus;call super::getfocus;w_ancestor_dataentry	lw_parent

// réactualiser le menu car l'option 'ajouter' n'est pas toujours disponible
IF f_GetParentWindow(this, lw_parent) = 1 THEN
	lw_parent.event ue_init_menu()
END IF

end event

event itemfocuschanged;call super::itemfocuschanged;parent.event post ue_init_menu()
end event

event ue_itemvalidated;call super::ue_itemvalidated;integer	li_numcat, li_numcmde

CHOOSE CASE as_name
	CASE "num_cmde"
		// lecture du n° de catalogue de la commande
		li_numcmde = integer(as_data)
		select num_cat into :li_numcat from commande where an_cmde=:ii_ancmde and num_cmde=:li_numcmde using ESQLCA;
		IF f_check_sql(ESQLCA) = 0 THEN ii_numcat = li_numcat
END CHOOSE
end event

type dw_detail from uo_datawindow_multiplerow within w_bordliv
integer y = 416
integer width = 3035
integer height = 1696
integer taborder = 11
boolean bringtotop = true
string dataobject = "d_detailbordliv"
boolean vscrollbar = true
boolean border = true
end type

event getfocus;call super::getfocus;w_ancestor_dataentry	lw_parent

// réactualiser le menu car l'option 'ajouter' n'est pas toujours disponible
IF f_GetParentWindow(this, lw_parent) = 1 THEN
	lw_parent.event ue_init_menu()
END IF

end event

event ue_itemvalidated;call super::ue_itemvalidated;CHOOSE CASE as_name
	CASE "c_select"
		IF integer(as_data) = 1 THEN
			this.object.num_bord[al_row] = ii_numbord
		ELSE
			this.object.num_bord[al_row] = gu_c.i_null
		END IF
END CHOOSE
end event

event ue_checkitem;call super::ue_checkitem;integer	li_numbord

CHOOSE CASE as_item
	CASE "c_select"
		IF integer(as_data) = 1 THEN
			// on ne peut pas sélectionner une ligne qui est déjà dans un autre bordereau 
			li_numbord = this.object.num_bord[al_row]
			IF NOT IsNull(li_numbord) AND li_numbord > 0 AND li_numbord <> ii_numbord THEN
				as_message = "Cette ligne de commande est dans un autre bordereau de livraison.~n~nElle ne peut pas être incluse dans celui-ci."
				return(-1)
			END IF
			// on ne peut pas sélectionner une ligne dont la qté livrée = 0 
			IF this.object.qte_livre[al_row] = 0 THEN
				as_message = "La quantité livrée de cette ligne de commande = 0.~n~nElle ne peut pas être incluse dans un bordereau de livraison."
				return(-1)
			END IF
			// on ne peut pas sélectionner une ligne qui n'a pas de n° de DF
			IF f_IsEmptyString(this.object.num_df_emis[al_row]) THEN
				as_message = "Le n° de document-fournisseur n'est pas spécifié de cette ligne de commande.~n~nElle ne peut pas être incluse dans un bordereau de livraison."
				return(-1)
			END IF
		END IF
END CHOOSE

return(1)
end event

