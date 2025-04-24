//objectcomments Encodage des flux manuels
forward
global type w_flux from w_ancestor_dataentry
end type
type dw_l_flux from uo_ancestor_dwbrowse within w_flux
end type
type dw_flux from uo_datawindow_multiplerow within w_flux
end type
type gb_bottom from uo_groupbox within w_flux
end type
type dw_reflot from uo_datawindow_singlerow within w_flux
end type
end forward

global type w_flux from w_ancestor_dataentry
integer width = 3013
integer height = 2100
string title = "Flux manuels"
boolean resizable = true
dw_l_flux dw_l_flux
dw_flux dw_flux
gb_bottom gb_bottom
dw_reflot dw_reflot
end type
global w_flux w_flux

type variables
string	is_reflot
br_flux		ibr_flux
integer		ii_linked
uo_linkdw	iu_linkdw
end variables

forward prototypes
public function integer wf_newflux ()
end prototypes

public function integer wf_newflux ();// création d'une nouvelle ligne de flux
// return(-1) si erreur
// return(n° de row ajoutée) si OK
long		ll_row
integer	li_num

ll_row = dw_flux.event ue_addrow()
IF ll_row <= 0 THEN
	return(-1)
END IF

// initialiser 1ère partie de la PK
dw_flux.object.ref_lot[ll_row] = is_reflot

// numérotation auto.
li_num = dw_flux.object.c_maxnum[ll_row]
IF IsNull(li_num) THEN 
	li_num = 1
ELSE
	li_num++
END IF		

IF li_num > 0 AND li_num <= 999 THEN 
	dw_flux.uf_setdefaultvalue(ll_row, "num_flux", li_num)
	dw_flux.SetColumn("dt_op")
ELSE
	gu_message.uf_error("Trop de lignes de flux pour ce lot !")
	return(-1)
END IF

// initialiser les autres champs
dw_flux.uf_setdefaultvalue(ll_row, "dt_op", f_today())
dw_flux.object.qte[ll_row] = 0

dw_flux.SetColumn("dt_op")
dw_l_flux.object.datawindow.HorizontalScrollPosition = 1
dw_flux.SetFocus()

return(ll_row)
end function

on w_flux.create
int iCurrent
call super::create
this.dw_l_flux=create dw_l_flux
this.dw_flux=create dw_flux
this.gb_bottom=create gb_bottom
this.dw_reflot=create dw_reflot
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_l_flux
this.Control[iCurrent+2]=this.dw_flux
this.Control[iCurrent+3]=this.gb_bottom
this.Control[iCurrent+4]=this.dw_reflot
end on

on w_flux.destroy
call super::destroy
destroy(this.dw_l_flux)
destroy(this.dw_flux)
destroy(this.gb_bottom)
destroy(this.dw_reflot)
end on

event ue_open;call super::ue_open;integer	li_status

ibr_flux = CREATE br_flux

// objets pour faciliter la synchronisation entre DW
iu_linkdw = CREATE uo_linkDW

// les 2 DW doivent scroller de façon synchronisées
ii_linked = iu_linkdw.uf_setLinkedDW({dw_l_flux, dw_flux})
IF ii_linked = -1 THEN
	wf_executePostOpen(FALSE)
	post close(this)
	return
END IF

// assigner les couleurs pour les lignes paires et impaires
gu_dwservices.uf_setbrowsecol(dw_l_flux)

// ne pas sélectionner la row dans le DW d'encodage
dw_flux.uf_autoselectrow(FALSE)

// on ne peut pas modifier le tri
dw_l_flux.uf_sort(FALSE)

// on ne checke que les rows ajoutées
dw_flux.uf_checkallrow(FALSE)

// partage des données
li_status = dw_flux.ShareData(dw_l_flux)
IF li_status = -1 THEN
	wf_executePostOpen(FALSE)
	populateerror(20000,"")
	gu_message.uf_unexp("dw_l_flux : partage des données dw_flux impossible")
	post close(this)
	return
END IF

// icône "ajouter" doit être visible dans le menu
wf_SetItemsToShow({"m_ajouter"})

// DW à mettre à jour
wf_SetDWList({dw_flux})

end event

event ue_ajouter;call super::ue_ajouter;// ajouter une nouvelle ligne de flux
wf_newFlux()

end event

event ue_init_menu;call super::ue_init_menu;string	ls_menu[]
integer	li_item

li_item = 1
ls_menu = {"m_fermer"}

IF wf_IsActif() THEN
	li_item++
	ls_menu[li_item] = "m_abandonner"
	IF wf_canUpdate() THEN
		li_item++
		ls_menu[li_item] = "m_enregistrer"
		li_item++
		ls_menu[li_item] = "m_ajouter"
		li_item++
		ls_menu[li_item] = "m_supprimer"
	END IF
END IF

f_menuaction(ls_menu)


end event

event ue_close;call super::ue_close;DESTROY ibr_flux
DESTROY iu_linkdw
end event

event ue_init_win;call super::ue_init_win;dw_reflot.uf_reset()
dw_l_flux.uf_reset()

dw_l_flux.object.datawindow.HorizontalScrollPosition = 1

dw_reflot.insertrow(0)
dw_reflot.uf_enabledata()

dw_reflot.enabled = TRUE
dw_l_flux.enabled = FALSE
dw_flux.enabled = FALSE

dw_reflot.setfocus()


end event

event resize;call super::resize;gb_bottom.width = newwidth - 32
dw_l_flux.width = newwidth
dw_l_flux.height = newheight - 752
gb_bottom.y = dw_l_flux.y + dw_l_flux.height
dw_flux.y = gb_bottom.y + 48
end event

event ue_enregistrer;call super::ue_enregistrer;integer	li_status

// contrôle de validité de tous les champs
IF dw_flux.event ue_checkall() < 0 THEN
	dw_flux.SetFocus()
	return(-1)
END IF

// update
li_status = gu_dwservices.uf_updatetransact(dw_flux)
CHOOSE CASE li_status
	CASE 1
		wf_message("Flux sur le lot " + is_reflot + " enregistré(s) avec succès")
		This.event ue_init_win()
		return(1)
	CASE -1
		populateerror(20000,"")
		gu_message.uf_unexp("FLUX_REGISTRE : Erreur lors de la mise à jour de la base de données")
		return(-1)
END CHOOSE

end event

event ue_supprimer;call super::ue_supprimer;long		ll_row
dwItemStatus l_status

// suppression d'un flux (uniquement possible pour ceux qu'on vient d'ajouter)
ll_row = dw_flux.GetRow()
IF ll_row <= 0 THEN return

l_Status = dw_flux.GetItemStatus(ll_row, 0, Primary!)
IF l_status <> new! AND l_status <> newModified! THEN
	gu_message.uf_error("Vous ne pouvez pas supprimer un flux déjà enregistré.")
	return
END IF

IF f_confirm_del("Voulez-vous supprimer le flux n°  " + &
				  f_string(dw_flux.object.num_flux[ll_row]) + " ?") = 1 THEN
	IF dw_flux.event ue_delete() = 1 THEN
		wf_message("Flux supprimé avec succès")
	END IF
END IF

end event

type ddlb_message from w_ancestor_dataentry`ddlb_message within w_flux
integer y = 1904
end type

type dw_l_flux from uo_ancestor_dwbrowse within w_flux
integer y = 288
integer width = 2962
integer height = 1248
integer taborder = 10
boolean bringtotop = true
string dataobject = "d_l_flux"
boolean hscrollbar = true
boolean vscrollbar = true
boolean border = true
end type

event rowfocuschanged;call super::rowfocuschanged;iu_linkdw.uf_rowfocuschanged(this, currentrow)
end event

event rowfocuschanging;call super::rowfocuschanging;IF dw_flux.AcceptText() = -1 THEN
	return(1)
END IF
end event

event ue_synchro;call super::ue_synchro;// synchroniser
iu_linkdw.uf_scrollall(ii_linked, al_currentrow)
end event

event doubleclicked;call super::doubleclicked;// double-clic sur le n° de DF émis : ouvrir ce DF
string	ls_numdf
integer	li_status

IF row = 0 THEN return
IF dwo.name <> "detail_cmde_num_df_emis" THEN return
ls_numdf = dwo.Primary[row]
IF f_IsEmptyString(ls_numdf) THEN return

IF NOT IsValid(w_docfrn) THEN
	OpenSheet(w_docfrn, gw_mdiframe, 0, Original!)
END IF
IF IsValid(w_docfrn) THEN
	w_docfrn.SetFocus()
	li_status = w_docfrn.event ue_abandonner()
	IF li_status = 3 OR li_status < 0 THEN
		return
	END IF
	w_docfrn.post wf_SetKey(ls_numdf)
END IF
end event

type dw_flux from uo_datawindow_multiplerow within w_flux
integer x = 37
integer y = 1568
integer width = 2907
integer height = 304
integer taborder = 10
boolean bringtotop = true
string dataobject = "d_flux"
end type

event ue_checkitem;call super::ue_checkitem;string	ls_signe
decimal{3} ld_qte_restante

CHOOSE CASE as_item
	CASE "num_flux"
		return(ibr_flux.uf_check_numflux(as_data, as_message))

	CASE "dt_op"
		return(ibr_flux.uf_check_dtop(as_data, as_message))

	CASE "utilisation"
		IF ibr_flux.uf_check_utilisation(as_data, as_message) = -1 THEN
			return(-1)
		ELSE
			// lire le signe de ce code utilisation et le transmettre aux DW
			select abbrd into :ls_signe from v_utilflux where code=:as_data using ESQLCA;
			IF f_check_sql(ESQLCA) <> 0 THEN
				as_message = "Erreur SELECT v_utilflux"
				return(-1)
			END IF
			dw_l_flux.object.v_utilflux_abbrd[al_row] = ls_signe
			return(1)
		END IF
		
	CASE "qte"
		ls_signe = dw_l_flux.object.v_utilflux_abbrd[al_row]
		ld_qte_restante = dw_reflot.object.qte_restante[1]
		return(ibr_flux.uf_check_qte(as_data, as_message, ls_signe, ld_qte_restante))
		
	CASE "lieu_stock"
		return(ibr_flux.uf_check_lieustock(as_data, as_message))
		
	CASE "destinataire"
		IF ibr_flux.uf_check_destinataire(as_data, as_message) = -1 THEN
			return(-1)
		ELSE
			this.object.interlocuteur_interlocuteur[al_row] = as_message
			return(1)
		END IF
		
	CASE "remarque"
		return(ibr_flux.uf_check_rem(as_data, as_message))
		
END CHOOSE

return(1)
end event

event rowfocuschanging;call super::rowfocuschanging;// empêche de changer de row par les flèches haut et bas, PgUp, PgDwn, Home, End....
// (seulement quand le focus est sur le DW en question, car il faut permettre
//  la synchronisation si un autre DW le demande !)
IF GetFocus() = This AND (KeyDown(KeyDownArrow!) OR KeyDown(KeyUpArrow!) OR &
	KeyDown(KeyPageUp!) OR KeyDown(KeyPageDown!) OR &
	KeyDown(KeyLeftArrow!) OR KeyDown(KeyRightArrow!) OR &
	KeyDown(KeyHome!) OR KeyDown(KeyEnd!) OR KeyDown(KeyEnter!) OR KeyDown(KeyTab!)) THEN
		return(1)
END IF

end event

event we_vscroll;call super::we_vscroll;// disable mouse wheel and scrollbar scrolling
return(1)
end event

event ue_help;call super::ue_help;str_params	lstr_params

CHOOSE CASE idwo_currentItem.name
	CASE "destinataire"
		open(w_l_locu)
		IF Message.DoubleParm = -1 THEN 
			return
		ELSE
			lstr_params=Message.PowerObjectParm
			this.SetText(string(lstr_params.a_param[1]))
			f_presskey("tab")
		END IF
END CHOOSE
end event

type gb_bottom from uo_groupbox within w_flux
integer x = 18
integer y = 1520
integer width = 2944
integer height = 368
integer taborder = 20
end type

type dw_reflot from uo_datawindow_singlerow within w_flux
integer width = 2962
integer height = 288
integer taborder = 10
boolean bringtotop = true
string dataobject = "d_flux_reflot"
end type

event ue_help;call super::ue_help;str_params	lstr_params

IF IsNull(idwo_currentItem) THEN return

CHOOSE CASE idwo_currentItem.name
	CASE "ref_lot"
		open(w_l_registre)
		IF Message.DoubleParm = -1 THEN 
			return
		ELSE
			lstr_params=Message.PowerObjectParm
			this.SetText(f_string(lstr_params.a_param[1]))
			f_presskey("TAB")
		END IF
END CHOOSE


end event

event ue_checkitem;call super::ue_checkitem;CHOOSE CASE as_item
	CASE "ref_lot"
		IF ibr_flux.uf_check_reflot(as_data, as_message) = -1 THEN
			return(-1)
		ELSE
			is_reflot = as_data
			return(1)
		END IF
END CHOOSE

end event

event ue_itemvalidated;call super::ue_itemvalidated;dw_reflot.retrieve(is_reflot)

// quand on quitte le n° de lot, on lit les flux existant et on initialise la fenêtre
wf_actif(true)

// effacer les messages
ddlb_message.reset()

// lire les flux existant
dw_flux.retrieve(is_reflot)

// disabler/enabler
dw_reflot.uf_disableData()

dw_reflot.enabled = FALSE
dw_l_flux.enabled = TRUE
dw_flux.enabled = TRUE

parent.event ue_init_menu()

end event

