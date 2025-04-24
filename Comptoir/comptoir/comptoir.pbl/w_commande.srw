//objectcomments Gestion des commandes
forward
global type w_commande from w_ancestor_dataentry
end type
type dw_entete from uo_datawindow_singlerow within w_commande
end type
type dw_detail from uo_datawindow_multiplerow within w_commande
end type
type cb_confirm from uo_cb within w_commande
end type
type dw_flux from uo_datawindow_multiplerow within w_commande
end type
type str_del from structure within w_commande
end type
end forward

type str_del from structure
	string		s_reflot
	decimal { 3}		d_qtedel
end type

global type w_commande from w_ancestor_dataentry
integer width = 3397
integer height = 2416
string title = "Gestion des commandes"
boolean resizable = true
dw_entete dw_entete
dw_detail dw_detail
cb_confirm cb_confirm
dw_flux dw_flux
end type
global w_commande w_commande

type variables
integer		ii_ancmde, ii_numcmde
string		is_stored_status	// indique le statut de la commande dans la DB
string		is_current_status // indique le statut actuel de la commande (peut être différent du statut
									   // de la commande dans la DB en fonction des opérations réalisées dans le programme
br_commande	ibr_commande
boolean		ib_ajout
uo_cpteur	iu_cpteur

PRIVATE str_del	istr_del[], istr_null[]
end variables

forward prototypes
public function integer wf_init ()
public function integer wf_newcmde ()
public function integer wf_init_statut ()
public subroutine wf_change_statut (string as_statut)
public function integer wf_init_newligne (long al_row)
public function integer wf_newflux (string as_reflot, string as_utilisation, decimal ad_qte, string as_remarque)
public function integer wf_init_pu (long al_row, decimal ad_qte_cmde, decimal ad_qte_confirm, string as_pretrt)
end prototypes

public function integer wf_init ();string	ls_saison, ls_client, ls_nom, ls_reflot, ls_codesp
integer	li_cat
long		ll_row
decimal{3}	ld_qte, ld_qte_confirm
decimal{2}	ld_montantrf, ld_montantrf2

IF dw_entete.uf_IsRecordNew() THEN
	// valeurs par défaut pour nouveau record
	dw_entete.object.statut[1] = "R"
	dw_entete.object.montantrf[1] = 0
	dw_entete.object.montantrf2[1] = 0
ELSE
	// lecture des traductions pour record existant
	// nom du client + montant restant à rembourser ou facturer
	ls_client = dw_entete.object.client[1]
	select interlocuteur, montantrf, montantrf2 into :ls_nom, :ld_montantrf, :ld_montantrf2 from interlocuteur 
		where locu = :ls_client using ESQLCA;
	IF f_check_sql(ESQLCA) = 0 THEN
		dw_entete.object.c_client[1] = ls_nom
		dw_entete.object.c_montantrf[1] = ld_montantrf
		dw_entete.object.c_montantrf2[1] = ld_montantrf2
	END IF
	
	// saison du catalogue
	li_cat = dw_entete.object.num_cat[1]
	select saison into :ls_saison from cat_vente where num_cat = :li_cat using ESQLCA;
	IF f_check_sql(ESQLCA) = 0 THEN
		dw_entete.object.c_saison[1] = ls_saison
	END IF
	
	// lectures des lignes de la commande
	dw_detail.retrieve(ii_ancmde, ii_numcmde)
	
	// initialiser le prix unitaire, le code espèce et la qté en stock de chaque ligne de commande
	FOR ll_row = 1 TO dw_detail.rowCount()
		ls_reflot = dw_Detail.object.ref_lot[ll_row]
		select code_sp, qte_restante into :ls_codesp, :ld_qte from v_totflux where ref_lot = :ls_reflot using ESQLCA;
		IF f_check_sql(ESQLCA) = 0 THEN
			dw_Detail.object.c_codesp[ll_row] = ls_codesp
			IF dw_entete.object.statut[1] = "R" THEN
				dw_Detail.object.c_qtestock[ll_row] = ld_qte
			ELSE
				ld_qte_confirm = dw_Detail.object.qte_confirm[ll_row]
				dw_Detail.object.c_qtestock[ll_row] = ld_qte + ld_qte_confirm
			END IF
		ELSE
			dw_Detail.object.c_qtestock[ll_row] = 0
		END IF
		dw_detail.SetItemStatus(ll_row, 0, Primary!, NotModified!)
		// Attention : on reprend le prix du catalogue seulement pour les commandes pas encore confirmées
		IF dw_entete.object.statut[1] = "R" THEN 
			wf_init_pu(ll_row, gu_c.d_null, gu_c.d_null, gu_c.s_null)
		END IF
	NEXT
END IF

// mémoriser le status de la commande tel qu'il est dans la DB...
is_stored_status = dw_entete.object.statut[1]

// ...et le statut en cours : au départ, idem que le statut dans la DB mais peut évoluer au fil des opérations
// dans le programme.
is_current_status = is_stored_status

// disabler la clé
dw_entete.uf_disablekeys()

// en fonction du statut, activer ou désactiver certains champs
wf_init_statut()

dw_entete.SetColumn("client")

dw_entete.SetItemStatus(1,0,Primary!,NotModified!)
dw_entete.SetFocus()

return(1)
end function

public function integer wf_newcmde ();// création d'une nouvelle commande
decimal	ld_numcmde

// l'année doit être spécifiée
IF IsNull(ii_ancmde) OR ii_ancmde = 0 THEN
	gu_message.uf_error("Veuillez d'abord sélectionner l'année de la commande")
	return(-1)
END IF

// prendre nouveau n° de commande via le compteur, le placer dans num_cmde et passer au champ suivant
ld_numcmde = iu_cpteur.uf_getnumcmde(ii_ancmde)
IF ld_numcmde < 0 THEN
	gu_message.uf_error("Impossible d'obtenir un nouveau n° de commande !")
	return(-1)
END IF
ib_ajout = TRUE
dw_entete.setfocus()
dw_entete.SetText(string(ld_numcmde))
f_presskey ("TAB")

return(1)

end function

public function integer wf_init_statut ();// en fonction du statut, activer ou désactiver certains champs
// (on tient compte du statut en cours, qui peut être différent du statut dans la DB en fonction
//  des opérations réalisées depuis la lecture de la commande)

// NB : certains champs sont toujours désactivés car ils sont mis à jour par des programmes spécialisés.
// Dans l'entête de la commande : date de livraison, date du bordereau récapitulatif.
// Dans le détail : n° de bordereau de livraison

dw_entete.setRedraw(FALSE)
dw_detail.setRedraw(FALSE)

// on désactive tout, on réactive ensuite sélectivement
dw_entete.uf_disabledata()
dw_detail.uf_disabledata()

// champs accessibles tant que la commande n'est pas facturée
IF match(is_current_status, "^[RCPLT]$") THEN
	dw_detail.uf_enableitems({"num_df_emis"})
	// le n° de document fournisseur n'est plus accessible si la ligne a un n° de bordereau de livraison 
	// indiquant qu'elle est livrée
	dw_detail.object.num_df_emis.protect = "0~tif(num_bord > 0, 1, 0)"
	dw_detail.object.num_df_emis.Background.Color = '1~tIf (num_bord > 0, f_disabcolor(), rgb(255,255,255))'
END IF

// champs accessibles tant que le bordereau récapitulatif n'est pas envoyé
IF match(is_current_status, "^[RCPL]$") THEN
	dw_entete.uf_enableitems({"rem_bord_recap"})
	dw_entete.uf_enableitems({"montantrf","montantrf2"})
END IF

// champs accessibles uniquement si la commande est confirmée ou préparée
// NB : au niveau des lignes détail, la qté livrée et facturée ne sont plus accessibles si la ligne 
// a un n° de bordereau de livraison indiquant qu'elle est livrée
IF match(is_current_status, "^[CP]$") THEN
	dw_entete.uf_enableitems({"dt_prepa"})
	dw_detail.uf_enableitems({"qte_livre", "qte_facture"})
	dw_detail.object.qte_livre.protect = "0~tif(num_bord > 0, 1, 0)"
	dw_detail.object.qte_livre.Background.Color = '1~tIf (num_bord > 0, f_disabcolor(), f_mandcolor())'
	// ATTENTION : pour les commandes Confirmées ou Préparées, on ne peut pas modifier les lignes
	// existantes mais on peut en ajouter de nouvelles. Dans ce cas, les colonnes doivent être
	// accessibles indépendamment des autres conditions.
	dw_detail.object.ref_lot.protect = '1~tIf(IsRowNew(),0,1)'
	dw_detail.Object.ref_lot.Background.Color = '1~tIf (IsRowNew(), f_mandcolor(), f_disabcolor())'
	dw_detail.object.qte_cmde.protect = '1~tIf(IsRowNew(),0,1)'
	dw_detail.Object.qte_cmde.Background.Color = '1~tIf (IsRowNew(), f_mandcolor(), f_disabcolor())'
	dw_detail.object.qte_confirm.protect = '1~tIf(IsRowNew(),0,1)'
	dw_detail.Object.qte_confirm.Background.Color = '1~tIf (IsRowNew(), f_mandcolor(), f_disabcolor())'
END IF

// champs accessibles uniquement si la commande est préparée
IF match(is_current_status, "^[P]$") THEN
	dw_detail.uf_enableitems({"qte_prepa"})
END IF

// champs accessibles tant que la commande n'est pas confirmée
IF match(is_current_status, "^[R]$") THEN
	dw_entete.uf_enableitems({"client", "num_cat", "dt_cmde"})
	dw_detail.uf_enableitems({"ref_lot", "qte_cmde", "qte_confirm", "pretrt"})
END IF

dw_entete.setRedraw(TRUE)
dw_detail.setRedraw(TRUE)

// bouton de confirmation de commande disponible ou pas en fonction du status de la commande
IF is_current_status = "R" THEN
	cb_confirm.enabled = TRUE
ELSE
	cb_confirm.enabled = FALSE
END IF

return(1)

end function

public subroutine wf_change_statut (string as_statut);// changer le statut de la commande

dw_entete.object.statut[1] = as_statut
is_current_status = as_statut

// tenir compte de la modification du statut dans l'accessibilité des champs
wf_init_statut()
end subroutine

public function integer wf_init_newligne (long al_row);// création d'une nouvelle ligne de commande
// return(-1) si erreur
// return(1) si OK
integer	li_num

// initialiser 1ère partie de la PK
dw_detail.object.an_cmde[al_row] = ii_ancmde
dw_detail.object.num_cmde[al_row] = ii_numcmde

// initialiser les autres colonnes
dw_detail.object.c_qtestock[al_row] = 0
dw_detail.object.pu[al_row] = 0
dw_detail.object.pretrt[al_row] = "N"
dw_detail.object.qte_cmde[al_row] = 0
dw_detail.object.qte_confirm[al_row] = 0
dw_detail.object.qte_prepa[al_row] = 0
dw_detail.object.qte_livre[al_row] = 0
dw_detail.object.qte_facture[al_row] = 0

dw_detail.SetColumn("ref_lot")
dw_detail.SetFocus()

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

public function integer wf_init_pu (long al_row, decimal ad_qte_cmde, decimal ad_qte_confirm, string as_pretrt);// initialiser le PU de la ligne de commande passée en paramètre
// Le PU 1, 2 ou 3 est sélectionné dans le catalogue sur base de la qté confirmée, ou commandée si elle n'est pas encore donnée
// si ad_qte_cmde et ad_qte_confirm sont NULL, c'est qu'on doit utiliser les qté déjà dans le DW
// sinon, c'est qu'on est en train d'encoder la qté et c'est celle-la qu'on doit utiliser
integer		li_numcat
decimal{3}	ld_qte, ld_lim_pu1, ld_lim_pu2, ld_lim_pu3, ld_unit_pu1, ld_unit_pu2, ld_unit_pu3
decimal{2}	ld_pu1, ld_pu2, ld_pu3, ld_selected_pu
string		ls_reflot, ls_codesp

ls_reflot = dw_detail.object.ref_lot[al_row]
ls_codesp = dw_detail.object.c_codesp[al_row]
li_numcat = dw_entete.object.num_cat[1]

IF isNull(as_pretrt) THEN
	as_pretrt = dw_detail.object.pretrt[al_row]
END IF
	
ld_qte = gu_c.d_null
IF NOT IsNull(ad_qte_confirm) THEN
	ld_qte = ad_qte_confirm
ELSE
	ld_qte = dw_detail.object.qte_confirm[al_row]
	IF ld_qte = 0 THEN 
		IF NOT IsNull(ad_qte_cmde) THEN
			ld_qte = ad_qte_cmde
		ELSE
			ld_qte = dw_detail.object.qte_cmde[al_row]
		END IF
	END IF
END IF

// lire les 3 PU (avec ou sans prétraitement suivant le choix)
IF as_pretrt = "N" THEN
	select pu1, pu2, pu3 into :ld_pu1, :ld_pu2, :ld_pu3 from cat_vente_lot where 
		num_cat = :li_numcat and ref_lot = :ls_reflot using ESQLCA;
ELSE
	select pup1, pup2, pup3 into :ld_pu1, :ld_pu2, :ld_pu3 from cat_vente_lot where 
		num_cat = :li_numcat and ref_lot = :ls_reflot using ESQLCA;
END IF
		
IF f_check_sql(ESQLCA) < 0 THEN
	populateError(20000, "")
	gu_message.uf_unexp("Erreur select CAT_VENTE_LOT")
	return(-1)
END IF
IF ESQLCA.SQLCode = 100 THEN
	gu_message.uf_error("Le lot " + f_string(ls_reflot) + " n'est pas repris dans le catalogue choisi")
	return(-1)
END IF

// lire les limites et les unités
select lim_pu1, lim_pu2, lim_pu3, unit_pu1, unit_pu2, unit_pu3 
	into :ld_lim_pu1, :ld_lim_pu2, :ld_lim_pu3, :ld_unit_pu1, :ld_unit_pu2, :ld_unit_pu3
	from espece where code_sp = :ls_codesp using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	populateError(20000, "")
	gu_message.uf_unexp("Erreur select ESPECE")
	return(-1)
END IF

// ramener le PU à un prix au kg
IF ld_unit_pu1 > 0 THEN
	ld_pu1 = ld_pu1 / ld_unit_pu1
END IF
IF ld_unit_pu2 > 0 THEN
	ld_pu2 = ld_pu2 / ld_unit_pu2
END IF
IF ld_unit_pu3 > 0 THEN
	ld_pu3 = ld_pu3 / ld_unit_pu3
END IF

// déterminer le prix en fonction de la quantité confirmée
ld_selected_pu = ld_pu1
IF ld_pu2 > 0 THEN
	IF ld_qte >= ld_lim_pu2 THEN ld_selected_pu = ld_pu2
END IF
IF ld_pu3 > 0 THEN
	IF ld_qte >= ld_lim_pu3 THEN ld_selected_pu = ld_pu3
END IF

IF dw_detail.object.pu[al_row] <> ld_selected_pu THEN
	dw_detail.object.pu[al_row] = ld_selected_pu
END IF

return(1)

end function

on w_commande.create
int iCurrent
call super::create
this.dw_entete=create dw_entete
this.dw_detail=create dw_detail
this.cb_confirm=create cb_confirm
this.dw_flux=create dw_flux
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_entete
this.Control[iCurrent+2]=this.dw_detail
this.Control[iCurrent+3]=this.cb_confirm
this.Control[iCurrent+4]=this.dw_flux
end on

on w_commande.destroy
call super::destroy
destroy(this.dw_entete)
destroy(this.dw_detail)
destroy(this.cb_confirm)
destroy(this.dw_flux)
end on

event ue_open;call super::ue_open;ibr_commande = CREATE br_commande
iu_cpteur = CREATE uo_cpteur

// icône "ajouter" doit être visible dans le menu
wf_SetItemsToShow({"m_ajouter"})

wf_SetDWList({dw_entete, dw_detail})

ii_ancmde = year(today())
end event

event ue_close;call super::ue_close;DESTROY ibr_commande
DESTROY iu_cpteur
end event

event ue_init_win;call super::ue_init_win;ib_ajout = FALSE
SetNull(ii_numcmde)
istr_del[] = istr_null[]
iu_cpteur.uf_rollback()
cb_confirm.enabled = FALSE

this.setredraw(FALSE)

dw_entete.uf_reset()
dw_detail.uf_reset()
dw_flux.uf_reset()

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
dw_entete.setfocus()

this.setredraw(TRUE)
end event

event ue_init_inactivewin;call super::ue_init_inactivewin;SetNull(ii_ancmde)
end event

event ue_init_menu;call super::ue_init_menu;string	ls_menu[]
integer	li_item

li_item = 2
ls_menu = {"m_abandonner", "m_fermer"}

IF wf_IsActif() THEN
	IF wf_canUpdate() THEN
		li_item++
		IF dw_entete.object.statut[1] <> "A" THEN
			ls_menu[li_item] = "m_enregistrer"
		END IF
	END IF
	CHOOSE CASE wf_GetActivecontrolname()
		// menu si curseur est sur l'entête de la commande
		CASE "dw_entete"
			IF NOT dw_entete.uf_IsRecordNew() AND wf_canDelete() THEN
				li_item++
				ls_menu[li_item] = "m_supprimer"
			END IF
		// menu si curseur est sur le détail de la commande
		CASE "dw_detail"
			IF wf_canUpdate() AND match(is_stored_status, "^[RCP]$") THEN
				li_item++
				ls_menu[li_item] = "m_ajouter"
				li_item++
				ls_menu[li_item] = "m_supprimer"				
			END IF
	END CHOOSE
ELSE
	IF wf_GetActivecontrolname() = "dw_entete" AND dw_entete.GetColumnName() = "num_cmde" AND wf_canUpdate() THEN
		li_item++
		ls_menu[li_item] = "m_ajouter"
	END IF
END IF

f_menuaction(ls_menu)
end event

event ue_ajouter;call super::ue_ajouter;long	ll_row

CHOOSE CASE wf_GetActivecontrolname()
	// ajouter une nouvelle commande si le curseur est sur DW_ENTETE et dans l'item NUM_CMDE
	CASE "dw_entete"
		IF dw_entete.GetColumnName() = "num_cmde" THEN
			wf_newcmde()
			return
		END IF
		
	// ajouter une nouvelle ligne de commande si le curseur est sur DW_DETAIL
	CASE "dw_detail"
		IF NOT wf_IsActif() THEN return
		IF NOT match(is_stored_status, "^[RCP]$") THEN
			gu_message.uf_error("On ne peut ajouter des lignes que pour les commandes dont le statut est &
Réceptionnée, Confirmée ou préparée.")
			return
		END IF
		IF dw_detail.accepttext() < 0 THEN return
		ll_row = dw_detail.event ue_addrow() // init.new row : voir event ue_addrow
END CHOOSE
end event

event resize;call super::resize;dw_detail.height = newheight - 900
dw_detail.width = newwidth
cb_confirm.y = dw_detail.y + dw_detail.height + 32
cb_confirm.x = newwidth / 2 - cb_confirm.width / 2

end event

event ue_supprimer;call super::ue_supprimer;string	ls_message, ls_reflot
decimal{3}	ld_qte
long		ll_row, ll_item
boolean	lb_found

CHOOSE CASE wf_GetActivecontrolname()
	// suppression de toute la commande
	CASE "dw_entete"
		IF ibr_commande.uf_check_beforedelete(is_stored_status, ls_message) = -1 THEN
			gu_message.uf_info(ls_message)
			return
		END IF
		IF f_confirm_del("Voulez-vous supprimer toute la commande ?") = 1 THEN
			IF dw_entete.event ue_delete() = 1 THEN
				// normalement, les "many" sont supprimés par les contraintes mais...
				delete from detail_cmde where an_cmde = :ii_ancmde and num_cmde=:ii_numcmde using ESQLCA;
				IF f_check_sql(ESQLCA) = 0 AND ESQLCA.sqlnrows <> 0 THEN
					commit using ESQLCA;
					populateerror(20000,"")
					gu_message.uf_unexp("Les contraintes d'intégrité entre COMMANDE et DETAIL_CMDE ne sont pas actives !", 2)
				END IF
				
				delete from bord_liv where an_cmde = :ii_ancmde and num_cmde=:ii_numcmde using ESQLCA;
				IF f_check_sql(ESQLCA) = 0 AND ESQLCA.sqlnrows <> 0 THEN
					commit using ESQLCA;
					populateerror(20000,"")
					gu_message.uf_unexp("Les contraintes d'intégrité entre COMMANDE et BORD_LIV ne sont pas actives !", 2)
				END IF
				// remarque : commit ou rollback nécessaire après les delete ci-dessus, même s'ils n'ont aucun effet !
				// Si on ne le fait pas, les LOCK subsistent !
				commit using ESQLCA;
				wf_message("Commande supprimée avec succès")
				this.event ue_init_win()
			END IF
		END IF
		
	// suppression d'une ligne de la commande
	CASE  "dw_detail"
		ll_row = dw_detail.GetRow()
		IF ll_row <= 0 THEN return
		ls_reflot = f_string(dw_detail.object.ref_lot[ll_row])
		ld_qte = dw_detail.object.c_qtestock[ll_row]
		IF ibr_commande.uf_check_detail_beforedelete(ls_message, is_stored_status, dw_detail.object.num_bord[ll_row]) = -1 THEN
			gu_message.uf_info(ls_message)
			return
		END IF
		IF f_confirm_del("Voulez-vous supprimer la ligne de commande pour le lot n° " + ls_reflot + " ?") = 1 THEN
			// NB : si suppression de la dernière ligne il y a création d'une nouvelle
			//      via dw_detail.event ue_addrow()
			IF dw_detail.event ue_delete() > 1 THEN
				wf_message("Ligne de commande supprimée avec succès")
			END IF
			// ajouter la référence de ce lot dans la structure des lots supprimés, qui sera nécessaire
			// pour le contrôle de la qté confirmée si on ajoute à nouveau ce lot dans la commande
			// sans l'avoir sauvée au préalable
			lb_found = FALSE
			FOR ll_item = 1 TO UpperBound(istr_del)
				IF istr_del[ll_item].s_reflot = ls_reflot THEN
					lb_found = TRUE
					EXIT
				END IF
			NEXT
			IF NOT lb_found THEN
				ll_item = UpperBound(istr_del) + 1
				istr_del[ll_item].s_reflot = ls_reflot
				istr_del[ll_item].d_qtedel = ld_qte
			END IF
		END IF
END CHOOSE

end event

event ue_enregistrer;call super::ue_enregistrer;integer	li_status
date		l_dtprepa
long		ll_row
decimal{2}	ld_montantrf, ld_montantCmde, ld_montantrf2
string		ls_client
dwItemStatus l_status

// contrôle de validité de tous les champs
IF dw_entete.event ue_checkall() < 0 THEN
	dw_entete.SetFocus()
	return(-1)
END IF
IF dw_detail.event ue_checkall() < 0 THEN
	dw_detail.SetFocus()
	return(-1)
END IF

// il faut au moins une ligne de commande
IF dw_detail.RowCount() = 0 THEN
	gu_message.uf_info("Il faut au moins une ligne de commande...")
	return(-1)
END IF

// Si la commande prévoit le remboursement d'un montant, celui-ci ne peut excéder le montant de la commande en cours
// On ne fait ce contrôle que lorsque la commande est prête à être facturée car avant cela
// les quantités facturées (qui servent à calculer le montant de la commande) peuvent varier.
ld_montantCmde = dw_detail.object.c_mt_facture[1]
ld_montantrf = dw_entete.object.montantrf[1]
ld_montantrf2 = dw_entete.object.montantrf2[1]
IF match(is_current_status,"^[LT]$") THEN
	IF (ld_montantrf + ld_montantrf2) < 0 AND ((ld_montantrf + ld_montantrf2) * -1) > ld_montantCmde THEN
		gu_message.uf_error("Le montant remboursé est supérieur au montant facturé !")
		return(-1)
	END IF
END IF
// si la commande est confirmée/préparée, on informe mais on ne bloque pas
IF match(is_current_status,"^[CP]$") THEN
	IF (ld_montantrf + ld_montantrf2) < 0 AND ((ld_montantrf + ld_montantrf2) * -1) > ld_montantCmde THEN
		IF gu_message.uf_query("Le montant remboursé est supérieur au montant facturé.~n" + &
				"Vous pouvez magré tout enregistrer la commande mais vous devrez la modifier avant de la facturer.~n~n" + &
				"Voulez-vous l'enregistrer maintenant ?", YesNo!, 1) = 2 THEN
			return(-1)
		END IF
	END IF
END IF

// si pas de date de préparation, annuler toutes les qté préparées dans le détail
l_dtprepa = date(dw_entete.object.dt_prepa[1])
IF isNull(l_dtprepa) THEN
	FOR ll_row = 1 TO dw_detail.rowCount()
		dw_detail.object.qte_prepa[ll_row] = 0
	NEXT
END IF

// Si la commande est passée de Réceptionnée à autre chose : créer les lignes de flux à créer :
IF is_stored_status = "R" AND is_current_status <> "R" THEN
	FOR ll_row = 1 TO dw_detail.rowCount()
		IF dw_detail.object.qte_confirm[ll_row] = 0 THEN
			CONTINUE
		ELSE
			IF wf_newflux(dw_detail.object.ref_lot[ll_row], "V", &
						  dw_detail.object.qte_confirm[ll_row], &
						  "Commande " + f_string(ii_ancmde) + "/" + f_string(ii_numcmde)) = -1 THEN
				return(-1)
			END IF
		END IF
	NEXT
END IF

// On peut encore supprimer et ajouter des lignes dans les commandes confirmées et préparées :
// 1. traiter les lignes de commandes supprimées des commandes confirmées/préparées : créer un flux
//    de rectification positive pour rajouter dans le stock ce qu'on avait enlevée lors de la confirmation
IF is_stored_status = "C" OR is_stored_status = "P" THEN
	FOR ll_row = 1 TO dw_detail.deletedCount()
		IF dw_detail.object.qte_confirm.delete[ll_row] = 0 THEN
			CONTINUE
		ELSE
			IF wf_newflux(dw_detail.object.ref_lot.delete[ll_row], "R+", &
					  dw_detail.object.qte_confirm.delete[ll_row], &
					  "Annulation ligne commande " + f_string(ii_ancmde) + "/" + f_string(ii_numcmde)) = -1 THEN
				return(-1)
			END IF
		END IF
	NEXT
END IF

// 2. traiter les lignes de commandes ajoutées à des commandes déjà confirmées/préparées
IF is_stored_status = "C" OR is_stored_status = "P" THEN
	FOR ll_row = 1 TO dw_detail.rowCount()
		// ne traiter que les nouvelles lignes
		l_status = dw_detail.GetItemStatus(ll_row, 0, Primary!)
		IF l_status <> NewModified!	THEN
			CONTINUE
		END IF
		IF dw_detail.object.qte_confirm[ll_row] = 0 THEN
			CONTINUE
		ELSE
			IF wf_newflux(dw_detail.object.ref_lot[ll_row], "V", &
						  dw_detail.object.qte_confirm[ll_row], &
						  "Commande " + f_string(ii_ancmde) + "/" + f_string(ii_numcmde)) = -1 THEN
				return(-1)
			END IF
		END IF
	NEXT
END IF

// mise à jour du montant à rembourser/refacturer pour le client en fonction de ce qu'on prend en compte
// dans la commande en cours. 
// On ne fait cette mise à jour qu'une fois la commande confirmée et pas encore facturée.
IF match(is_current_status,"^[CPLT]$") THEN
	IF is_stored_status = "R" THEN
		ld_montantrf = dw_entete.object.montantrf[1] * -1
		ld_montantrf2 = dw_entete.object.montantrf2[1] * -1
	ELSE
		ld_montantrf = dw_entete.object.montantrf.original[1] - dw_entete.object.montantrf[1]
		ld_montantrf2 = dw_entete.object.montantrf2.original[1] - dw_entete.object.montantrf2[1]
	END IF
	ls_client = dw_entete.object.client[1]
	update interlocuteur
		set montantrf = montantrf + :ld_montantrf, 
			 montantrf2 = montantrf2 + :ld_montantrf2
		where locu = :ls_client using SQLCA;
	IF f_check_sql(SQLCA) <> 0 THEN
		populateerror(20000, "")
		rollback using SQLCA;
		gu_message.uf_unexp("Erreur mise à jour INTERLOCUTEUR")
		return(-1)
	END IF
END IF

// update le DW contenant les flux dans la même transaction que les DW entête et détail
li_status = gu_dwservices.uf_updatetransact(dw_entete, dw_detail, dw_flux)
CHOOSE CASE li_status
	CASE 1
		wf_message("Commande " + string(ii_ancmde) + "/" + f_string(ii_numcmde) + " enregistrée avec succès")
		// si nouvelle commande, updater compteur
		IF dw_entete.uf_IsRecordNew() THEN
			IF iu_cpteur.uf_update_numcmde(ii_ancmde, ii_numcmde) = -1 THEN
				populateerror(20000, "")
				gu_message.uf_unexp("Erreur mise à jour du compteur COMMANDE.NUM_CMDE")
				return(-1)
			ELSE
				This.event ue_init_win()
				return(1)
			END IF
		ELSE
			This.event ue_init_win()
			return(1)
		END IF
	CASE -1
		populateerror(20000,"")
		gu_message.uf_unexp("COMMANDE : Erreur lors de la mise à jour de la base de données")
		return(-1)
	CASE -2
		populateerror(20000,"")
		gu_message.uf_unexp("DETAIL_CMDE : Erreur lors de la mise à jour de la base de données")
		return(-1)
	CASE -3
		populateerror(20000,"")
		gu_message.uf_unexp("FLUX_REGISTRE : Erreur lors de la mise à jour de la base de données")
		return(-1)
END CHOOSE

end event

type ddlb_message from w_ancestor_dataentry`ddlb_message within w_commande
integer y = 2208
end type

type dw_entete from uo_datawindow_singlerow within w_commande
integer width = 3346
integer height = 640
integer taborder = 10
boolean bringtotop = true
string dataobject = "d_commande"
end type

event getfocus;call super::getfocus;w_ancestor_dataentry	lw_parent

// réactualiser le menu car l'option 'ajouter' n'est pas toujours disponible
IF f_GetParentWindow(this, lw_parent) = 1 THEN
	lw_parent.event ue_init_menu()
END IF

end event

event itemfocuschanged;call super::itemfocuschanged;parent.event post ue_init_menu()
end event

event ue_checkitem;call super::ue_checkitem;integer	li_status, li_numcmde
long		ll_count

CHOOSE CASE as_item
	CASE "an_cmde"
		IF ibr_commande.uf_check_ancmde(as_data, as_message) = -1 THEN
			return(-1)
		ELSE
			ii_ancmde = integer(as_data)
			return(1)
		END IF
		
	// dernier élément de la clé, vérifier si record existe ou pas
	CASE "num_cmde"
		IF ibr_commande.uf_check_numcmde(as_data, as_message) = -1 THEN
			iu_cpteur.uf_rollback()
			return(-1)
		END IF
		li_numcmde = integer(as_data)
		select count(*) into :ll_count from commande
				where an_cmde = :ii_ancmde and num_cmde=:li_numcmde using ESQLCA;
		li_status = f_check_sql(ESQLCA)
		IF li_status < 0 OR ll_count > 1 THEN
			populateerror(20000,"")
			gu_message.uf_unexp("Erreur SELECT COMMANDE")
			return(-1)
		ELSE
			// commande inexistante...
			IF ll_count = 0 THEN
				// ...et on peut modifier les données...
				IF wf_canUpdate() THEN
					IF ib_ajout THEN
						this.uf_NewRecord(TRUE)
						ii_numcmde = li_numcmde
						return(1)
					ELSE
						as_message = "Commande inexistante. Utilisez l'action 'Ajouter' pour en créer une."
						return(-1)
					END IF
				ELSE
				// ...et on ne peut pas modifier les données
					as_message = "Commande inexistante. Vous n'avez pas le droit d'en créer..."
					return(-1)
				END IF
			ELSE
			// Commande existe déjà : OK
				this.uf_NewRecord(FALSE)
				ii_numcmde = li_numcmde
				return(1)
			END IF
		END IF
	
	CASE "client"
		IF ibr_commande.uf_check_client(as_data, as_message) = -1 THEN
			return(-1)
		ELSE
			this.object.c_client[al_row] = as_message
			return(1)
		END IF
		
	CASE "montantrf", "montantrf2"
		// seulement vérifié lors de l'enregistrement d'une commande livrée, quand son montant total est connu
		
	CASE "num_cat"
		IF ibr_commande.uf_check_numcat(as_data, as_message) = -1 THEN
			return(-1)
		ELSE
			this.object.c_saison[al_row] = as_message
			return(1)
		END IF

	CASE "dt_cmde"
		return(ibr_commande.uf_check_dtcmde(as_data, as_message))
		
	CASE "dt_prepa"
		return(ibr_commande.uf_check_dtprepa(as_data, as_message))
		
	CASE "dt_liv"
		return(ibr_commande.uf_check_dtliv(as_data, as_message, is_stored_status))
		
	CASE "dt_bord_recap"
		return(ibr_commande.uf_check_dtBordRecap(as_data, as_message, is_stored_status))
		
	CASE "rem_bord_recap"
		return(ibr_commande.uf_check_remBordRecap(as_data, as_message))
END CHOOSE

return(1)
end event

event ue_leavekey;call super::ue_leavekey;// quand on quitte la clé, cela veut dire qu'on dispose de données actives dans la fenêtre
wf_actif(true)

// effacer les messages
ddlb_message.reset()

// lecture du record si existe déjà
IF NOT this.uf_IsRecordNew() THEN
	wf_message("Modification d'une commande...")
	this.retrieve(ii_ancmde, ii_numcmde)
ELSE
	wf_message("Nouvelle commande...")
END IF

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

	CASE "num_cat"
		open(w_l_catalogue)
		IF Message.DoubleParm = -1 THEN 
			return
		ELSE
			lstr_params=Message.PowerObjectParm
			this.SetText(f_string(lstr_params.a_param[1]))
			f_presskey("TAB")
		END IF
	
	CASE "client"
		// types d'interlocuteurs autorisés : seulement les clients
		lstr_params.a_param[1] = ""
		lstr_params.a_param[2] = "O"
		lstr_params.a_param[3] = FALSE
		openwithparm(w_l_locu, lstr_params)
		IF Message.DoubleParm = -1 THEN 
			return
		ELSE
			lstr_params=Message.PowerObjectParm
			this.SetText(string(lstr_params.a_param[1]))
			f_presskey("tab")
		END IF
		
END CHOOSE


end event

event ue_itemvalidated;call super::ue_itemvalidated;decimal{2}	ld_montantrf, ld_montantrf2

CHOOSE CASE as_name
	// si on met une date de préparation, on fait passer le statut à Préparé sinon on revient à confirmé
	// (NB : la date de préparation n'est accessible que si la cmde est confirmée ou préparée)
	CASE "dt_prepa"
		IF f_IsEmptyString(as_data) THEN
			wf_change_statut("C")
		ELSE
			wf_change_statut("P")
		END IF
		
	// afficher montant restant à rembourser ou facturer pour le client
	CASE "client"
		select montantrf, montantrf2 into :ld_montantrf, :ld_montantrf2 from interlocuteur where locu=:as_data using ESQLCA;
		IF f_check_sql(ESQLCA) = 0 THEN
			this.object.c_montantrf[1] = ld_montantrf
			this.object.c_montantrf2[1] = ld_montantrf2
		END IF
		
END CHOOSE
end event

type dw_detail from uo_datawindow_multiplerow within w_commande
integer y = 640
integer width = 3346
integer height = 1392
integer taborder = 11
boolean bringtotop = true
string dataobject = "d_detailcmde"
boolean vscrollbar = true
boolean border = true
end type

event getfocus;call super::getfocus;w_ancestor_dataentry	lw_parent

// réactualiser le menu car l'option 'ajouter' n'est pas toujours disponible
IF f_GetParentWindow(this, lw_parent) = 1 THEN
	lw_parent.event ue_init_menu()
END IF

end event

event ue_help;call super::ue_help;str_params	lstr_params
string	ls_where

IF al_row = 0 THEN return
IF isNull(idwo_currentItem) THEN return

CHOOSE CASE idwo_currentItem.name
	CASE "ref_lot"
		ls_where =  "registre.ref_lot in (select ref_lot from cat_vente_lot where num_cat = '" + &
						f_string(dw_entete.object.num_cat[1]) + "')"
		lstr_params.a_param[1] = ls_where
		lstr_params.a_param[2] = FALSE
		openwithparm(w_l_registre, lstr_params)
		IF Message.DoubleParm = -1 THEN 
			return
		ELSE
			lstr_params=Message.PowerObjectParm
			this.SetText(f_string(lstr_params.a_param[1]))
			f_presskey("TAB")
		END IF
		
	CASE "num_df_emis"
		ls_where = "docfrn.destinataire='" + f_string(dw_entete.object.client[1]) + + "'" + &
					  " and docfrn.ref_lot='" + f_string(this.object.ref_lot[al_row]) + "'" + &
					  " and docfrn.num_cat=" + f_string(dw_entete.object.num_cat[1])
		lstr_params.a_param[1] = "E"
		lstr_params.a_param[2] = ls_where
		lstr_params.a_param[3] = FALSE
		openwithparm(w_l_docfrn, lstr_params)
		IF Message.DoubleParm = -1 THEN 
			return
		ELSE
			lstr_params=Message.PowerObjectParm
			this.SetText(string(lstr_params.a_param[1]))
			f_presskey("tab")
		END IF
END CHOOSE
end event

event ue_checkitem;call super::ue_checkitem;decimal{3}	ld_qte

CHOOSE CASE as_item
	CASE "ref_lot"
		IF ibr_commande.uf_check_detail_reflot(as_data, as_message, dw_entete.object.num_cat[1]) = -1 THEN
			return(-1)
		ELSE
			IF gu_dwservices.uf_findduplicate(This, al_row, "ref_lot='" + as_data + "'") <> 0 THEN
				as_message = "Ce n° de lot figure déjà dans la commande"
				return(-1)
			END IF
		END IF

	CASE "qte_cmde"
		return(ibr_commande.uf_check_detail_qtecmde(as_data, as_message))

	CASE "qte_confirm"
		ld_qte = this.object.c_qtestock[al_row]
		return(ibr_commande.uf_check_detail_qteconfirm(as_data, as_message, ld_qte))

	CASE "qte_prepa"
		return(ibr_commande.uf_check_detail_qteprepa(as_data, as_message))

	CASE "qte_livre"
		return(ibr_commande.uf_check_detail_qtelivre(as_data, as_message))

	CASE "qte_facture"
		return(ibr_commande.uf_check_detail_qtefacture(as_data, as_message))

	CASE "num_df_emis"
		IF ibr_commande.uf_check_detail_numdfemis(as_data, as_message, &
				 string(dw_entete.object.client[1]), string(this.object.ref_lot[al_row]), &
				 integer(dw_entete.object.num_cat[1]), ii_ancmde, ii_numcmde) = -1 THEN
			return(-1)
		ELSE
			IF gu_dwservices.uf_findduplicate(This, al_row, "num_df_emis='" + as_data + "'") <> 0 THEN
				as_message = "Ce document founisseur est déjà utilisé dans la commande"
				return(-1)
			END IF
		END IF

	CASE "num_bord"
		return(ibr_commande.uf_check_detail_numbord(as_data, as_message, ii_ancmde, ii_numcmde))
		
END CHOOSE

return(1)
end event

event ue_itemvalidated;call super::ue_itemvalidated;decimal{3}	ld_qte
string		ls_codesp
long			ll_item

CHOOSE CASE as_name
	CASE "ref_lot"
		select code_sp, qte_restante into :ls_codesp, :ld_qte 
			from v_totflux where ref_lot = :as_data using ESQLCA;
		IF f_check_sql(ESQLCA) = 0 THEN
			this.object.c_codesp[al_row] = ls_codesp
			this.object.c_qtestock[al_row] = ld_qte
		ELSE
			this.object.c_qtestock[al_row] = 0
		END IF
		
		// si on vient d'ajouter une ligne pour un lot effacé au préalable de la commande sans l'avoir sauvée,
		// les flux ne sont pas encore à jour et il faut tenir compte de la qté supprimée
		FOR ll_item = 1 TO UpperBound(istr_del)
			IF istr_del[ll_item].s_reflot = as_data THEN
				this.object.c_qtestock[al_row] = istr_del[ll_item].d_qtedel
				EXIT
			END IF
		NEXT

	// réactualiser le PU si on modifie 'pré-traitement O/N'
	CASE "pretrt"
		wf_init_pu(al_row, gu_c.d_null, gu_c.d_null, as_data)
	
	// chercher PU suivant qté
	CASE "qte_cmde"
		ld_qte = dec(as_data)
		wf_init_pu(al_row, ld_qte, gu_c.d_null, gu_c.s_null)
		
	// chercher PU suivant qté
	CASE "qte_confirm"
		ld_qte = dec(as_data)
		wf_init_pu(al_row, gu_c.d_null, ld_qte, gu_c.s_null)

END CHOOSE
end event

event ue_addrow;call super::ue_addrow;IF AncestorReturnValue >= 1 THEN
	wf_init_newligne(AncestorReturnValue)
END IF
return(AncestorReturnValue)

end event

type cb_confirm from uo_cb within w_commande
integer x = 549
integer y = 2064
integer width = 2176
integer taborder = 21
boolean bringtotop = true
boolean enabled = false
string text = "Confirmer la commande (ne sera effectif qu~'après enregistrement de celle-ci)"
end type

event clicked;call super::clicked;IF is_stored_status <> "R" THEN return

// d'abord checker pour voir si tout est OK, car la confirmation va rendre certains champs inaccessibles
IF dw_entete.event ue_checkAll() < 0 THEN
	dw_entete.setFocus()
	return
END IF
IF dw_detail.event ue_checkAll() < 0 THEN
	dw_detail.setFocus()
	return
END IF

// il faut au moins une ligne de commande
IF dw_detail.RowCount() = 0 THEN
	gu_message.uf_info("Il faut au moins une ligne de commande...")
	return
END IF

wf_change_statut("C")

end event

type dw_flux from uo_datawindow_multiplerow within w_commande
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

