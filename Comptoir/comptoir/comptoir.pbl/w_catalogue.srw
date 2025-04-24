//objectcomments Encodage des catalogues de vente
forward
global type w_catalogue from w_ancestor_dataentry
end type
type dw_cat from uo_datawindow_singlerow within w_catalogue
end type
type dw_cat_lot from uo_datawindow_multiplerow within w_catalogue
end type
type st_lot from uo_statictext within w_catalogue
end type
type st_pup from uo_statictext within w_catalogue
end type
end forward

global type w_catalogue from w_ancestor_dataentry
integer width = 3035
integer height = 1992
string title = "Gestion des catalogues de vente"
boolean resizable = true
dw_cat dw_cat
dw_cat_lot dw_cat_lot
st_lot st_lot
st_pup st_pup
end type
global w_catalogue w_catalogue

type variables
integer	ii_numcat
boolean	ib_ajout
br_catalogue	ibr_catalogue
uo_cpteur		iu_cpteur

end variables

forward prototypes
public function integer wf_init ()
public function integer wf_newcat ()
public function integer wf_newlot ()
public function integer wf_init_sp (long al_row, string as_reflot)
public subroutine wf_initnewlot (long al_row)
end prototypes

public function integer wf_init ();long	ll_row

IF dw_cat.uf_IsRecordNew() THEN

ELSE
	// lectures des lots du catalogue
	dw_cat_lot.retrieve(ii_numcat)
	// afficher code espèce du lot
	FOR ll_row = 1 TO dw_cat_lot.RowCount()
		wf_init_sp(ll_row, dw_cat_lot.object.ref_lot[ll_row])
	NEXT
END IF

// créer 1ère ligne pour un lot s'il n'y en a pas
IF dw_cat_lot.RowCount() = 0 THEN
	wf_newlot()
END IF

// disabler la clé et enabler les datas
dw_cat.uf_enabledata()
dw_cat.uf_disablekeys()
dw_cat.SetColumn("saison")

dw_cat.SetItemStatus(1,0,Primary!,NotModified!)
dw_cat.SetFocus()

return(1)
end function

public function integer wf_newcat ();// création d'un nouveau catalogue
decimal	ld_numcat

// prendre nouveau n° de catalogue via le compteur, le placer dans numcat et passer au champ suivant
ld_numcat = iu_cpteur.uf_getnumcat()
IF ld_numcat < 0 THEN
	gu_message.uf_error("Impossible d'obtenir un nouveau n° de catalogue !")
	return(-1)
END IF
ib_ajout = TRUE
dw_cat.setfocus()
dw_cat.SetText(string(ld_numcat))
f_presskey ("TAB")

return(1)

end function

public function integer wf_newlot ();// ajout d'une référence de lot
// return(-1) si erreur
// return(n° de row ajoutée) si OK
long		ll_row

ll_row = dw_cat_lot.event ue_addrow()
IF ll_row <= 0 THEN
	return(-1)
ELSE
	wf_initnewlot(ll_row)
	return(ll_row)
END IF

end function

public function integer wf_init_sp (long al_row, string as_reflot);// afficher code espèce du lot
string	ls_codesp

select code_sp into :ls_codesp from registre where ref_lot = :as_reflot using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	return(-1)
ELSE
	dw_cat_lot.object.c_codesp[al_row] = ls_codesp
	dw_cat_lot.SetItemStatus(al_row, 0, Primary!, NotModified!)
END IF

return(1)
end function

public subroutine wf_initnewlot (long al_row);// initialiser nouvelle ligne de référence lot
// return(-1) si erreur
// return(n° de row ajoutée) si OK

// initialiser 1ère partie de la PK
dw_cat_lot.object.num_cat[al_row] = ii_numcat

// initialiser les prix à 0
dw_cat_lot.object.pu1[al_row] = 0
dw_cat_lot.object.pu2[al_row] = 0
dw_cat_lot.object.pu3[al_row] = 0
dw_cat_lot.object.pup1[al_row] = 0
dw_cat_lot.object.pup2[al_row] = 0
dw_cat_lot.object.pup3[al_row] = 0

dw_cat_lot.SetColumn("ref_lot")

dw_cat_lot.object.datawindow.HorizontalScrollPosition = 1
dw_cat_lot.SetFocus()

return
end subroutine

on w_catalogue.create
int iCurrent
call super::create
this.dw_cat=create dw_cat
this.dw_cat_lot=create dw_cat_lot
this.st_lot=create st_lot
this.st_pup=create st_pup
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_cat
this.Control[iCurrent+2]=this.dw_cat_lot
this.Control[iCurrent+3]=this.st_lot
this.Control[iCurrent+4]=this.st_pup
end on

on w_catalogue.destroy
call super::destroy
destroy(this.dw_cat)
destroy(this.dw_cat_lot)
destroy(this.st_lot)
destroy(this.st_pup)
end on

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
	END IF
	CHOOSE CASE wf_GetActivecontrolname()
		// menu si curseur est sur l'entête du catalogue
		CASE "dw_cat"
			IF NOT dw_cat.uf_IsRecordNew() AND wf_canDelete() THEN
				li_item++
				ls_menu[li_item] = "m_supprimer"
			END IF
		// menu si curseur est sur les références de lot
		CASE "dw_cat_lot"
			IF wf_canUpdate() THEN
				li_item++
				ls_menu[li_item] = "m_ajouter"
				li_item++
				ls_menu[li_item] = "m_supprimer"
			END IF
	END CHOOSE
ELSE
	IF dw_cat.GetColumnName() = "num_cat" AND wf_canUpdate() THEN
		li_item++
		ls_menu[li_item] = "m_ajouter"
	END IF
END IF

f_menuaction(ls_menu)
end event

event ue_open;call super::ue_open;ibr_catalogue = CREATE br_catalogue
iu_cpteur = CREATE uo_cpteur

// icône "ajouter" doit être visible dans le menu
wf_SetItemsToShow({"m_ajouter"})

wf_SetDWList({dw_cat, dw_cat_lot})

end event

event ue_close;call super::ue_close;DESTROY ibr_catalogue
DESTROY iu_cpteur
end event

event ue_init_win;call super::ue_init_win;ib_ajout = FALSE
iu_cpteur.uf_rollback()

this.setredraw(FALSE)

dw_cat.uf_reset()
dw_cat_lot.uf_reset()

dw_cat_lot.object.datawindow.HorizontalScrollPosition = 1

dw_cat.insertrow(0)
dw_cat.uf_disabledata()
dw_cat.uf_enablekeys()

dw_cat.Setcolumn("num_cat")
dw_cat.setfocus()

this.setredraw(TRUE)
end event

event ue_supprimer;call super::ue_supprimer;string	ls_message, ls_reflot
integer	li_st

CHOOSE CASE wf_GetActivecontrolname()
	// suppression de tout le catalogue
	CASE "dw_cat"
		IF ibr_catalogue.uf_check_beforedelete(ii_numcat, ls_message) = -1 THEN
			gu_message.uf_info(ls_message)
			return
		END IF
		IF f_confirm_del("Voulez-vous supprimer tout le catalogue ?") = 1 THEN
			IF dw_cat.event ue_delete() = 1 THEN
				// normalement, les "many" sont supprimés par les contraintes mais...
				delete from CAT_VENTE_LOT where num_cat=:ii_numcat using ESQLCA;
				IF f_check_sql(ESQLCA) = 0 AND ESQLCA.sqlnrows <> 0 THEN
					commit using ESQLCA;
					populateerror(20000,"")
					gu_message.uf_unexp("Les contraintes d'intégrité entre CAT_VENTE et CAT_VENTE_LOT ne sont pas actives !", 2)
				END IF
				// remarque : commit ou rollback nécessaire après les delete ci-dessus, même s'ils n'ont aucun effet !
				// Si on ne le fait pas, les LOCK subsistent !
				commit using ESQLCA;	
				wf_message("Catalogue supprimé avec succès")
				this.event ue_init_win()
			END IF
		END IF
	// suppression d'une référence de lot
	CASE  "dw_cat_lot"
		ls_reflot = f_string(dw_cat_lot.object.ref_lot[dw_cat_lot.GetRow()])
		IF ibr_catalogue.uf_check_lot_beforedelete(ii_numcat, ls_reflot, ls_message) = -1 THEN
			gu_message.uf_info(ls_message)
			return
		END IF
		IF f_confirm_del("Voulez-vous supprimer le lot n° " + ls_reflot + " du catalogue ?") = 1 THEN
			li_st = dw_cat_lot.event ue_delete()
			// li_st = 2 : création automatique d'une nouvelle row
			IF li_st = 2 THEN
				wf_initnewlot(1)
			END IF
			IF li_st > 0 THEN
				wf_message("Référence de lot supprimée avec succès du catalogue")
			END IF
		END IF
END CHOOSE

end event

event ue_enregistrer;call super::ue_enregistrer;integer	li_status

// contrôle de validité de tous les champs
IF dw_cat.event ue_checkall() < 0 THEN
	dw_cat.SetFocus()
	return(-1)
END IF
IF dw_cat_lot.event ue_checkall() < 0 THEN
	dw_cat_lot.SetFocus()
	return(-1)
END IF

li_status = gu_dwservices.uf_updatetransact(dw_cat, dw_cat_lot)
CHOOSE CASE li_status
	CASE 1
		wf_message("Catalogue " + string(ii_numcat) + " enregistré avec succès")
		// si nouveau catalogue, updater compteur
		IF dw_cat.uf_IsRecordNew() THEN
			IF iu_cpteur.uf_update_numcat(ii_numcat) = -1 THEN
				populateerror(20000, "")
				gu_message.uf_unexp("Erreur mise à jour du compteur CAT_VENTE.NUM_CAT")
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
		gu_message.uf_unexp("CAT_VENTE : Erreur lors de la mise à jour de la base de données")
		return(-1)
	CASE -2
		populateerror(20000,"")
		gu_message.uf_unexp("CAT_VENTE_LOT : Erreur lors de la mise à jour de la base de données")
		return(-1)
END CHOOSE

end event

event ue_ajouter;call super::ue_ajouter;long	ll_row

CHOOSE CASE wf_GetActivecontrolname()
	// ajouter un nouveau catalogue est sur DW_CAT et dans l'item NUM_CAT
	CASE "dw_cat"
		IF dw_cat.GetColumnName() = "num_cat" THEN
			wf_newcat()
			return
		END IF
		
	// ajouter une nouvelle référence de lot si le curseur est sur dw_cat_lot
	CASE "dw_cat_lot"
		wf_newlot()
END CHOOSE
end event

event resize;call super::resize;st_lot.width = newwidth
st_pup.width = newwidth
dw_cat_lot.width = newwidth
dw_cat_lot.height = newheight - 384
end event

type ddlb_message from w_ancestor_dataentry`ddlb_message within w_catalogue
integer y = 1792
end type

type dw_cat from uo_datawindow_singlerow within w_catalogue
integer width = 2999
integer height = 160
integer taborder = 10
boolean bringtotop = true
string dataobject = "d_cat"
end type

event ue_checkitem;call super::ue_checkitem;integer	li_status, li_numcat
long		ll_count

as_message = ""

CHOOSE CASE as_item
	// dernier élément de la clé, vérifier si record existe ou pas
	CASE "num_cat"
		IF ibr_catalogue.uf_check_numcat(as_data, as_message) = -1 THEN
			iu_cpteur.uf_rollback()
			return(-1)
		END IF
		li_numcat = integer(as_data)
		select count(*) into :ll_count from cat_vente
				where num_cat = :li_numcat using ESQLCA;
		li_status = f_check_sql(ESQLCA)
		IF li_status < 0 OR ll_count > 1 THEN
			populateerror(20000,"")
			gu_message.uf_unexp("Erreur SELECT CAT_VENTE")
			return(-1)
		ELSE
			// catalogue inexistant...
			IF ll_count = 0 THEN
				// ...et on peut modifier les données...
				IF wf_canUpdate() THEN
					IF ib_ajout THEN
						this.uf_NewRecord(TRUE)
						ii_numcat = li_numcat
						return(1)
					ELSE
						as_message = "Catalogue inexistant. Utilisez l'action 'Ajouter' pour en créer un."
						return(-1)
					END IF
				ELSE
				// ...et on ne peut pas modifier les données
					as_message = "Catalogue inexistant. Vous n'avez pas le droit d'en créer..."
					return(-1)
				END IF
			ELSE
			// Catalogue existe déjà : OK
				this.uf_NewRecord(FALSE)
				ii_numcat = li_numcat
				return(1)
			END IF
		END IF
		
	CASE "saison"
		return(ibr_catalogue.uf_check_saison(as_data, as_message))
		
END CHOOSE

return(1)
end event

event ue_leavekey;call super::ue_leavekey;// quand on quitte la clé, cela veut dire qu'on dispose de données actives dans la fenêtre
wf_actif(true)

// effacer les messages
ddlb_message.reset()

// lecture du record si existe déjà
IF NOT this.uf_IsRecordNew() THEN
	wf_message("Modification d'un catalogue...")
	this.retrieve(ii_numcat)
ELSE
	wf_message("Nouveau catalogue...")
END IF

parent.event ue_init_menu()
post wf_init()

end event

event ue_help;call super::ue_help;str_params	lstr_params

IF NOT isValid(idwo_currentItem) THEN return
IF isNull(idwo_currentItem) THEN return

CHOOSE CASE idwo_currentItem.name
	CASE "num_cat"
		open(w_l_catalogue)
		IF Message.DoubleParm = -1 THEN 
			return
		ELSE
			lstr_params=Message.PowerObjectParm
			this.SetText(f_string(lstr_params.a_param[1]))
			f_presskey("TAB")
		END IF
END CHOOSE


end event

event getfocus;call super::getfocus;w_ancestor_dataentry	lw_parent

// réactualiser le menu car l'option 'ajouter' n'est pas toujours disponible
IF f_GetParentWindow(this, lw_parent) = 1 THEN
	lw_parent.event ue_init_menu()
END IF

end event

type dw_cat_lot from uo_datawindow_multiplerow within w_catalogue
integer y = 288
integer width = 2999
integer height = 1504
integer taborder = 11
boolean bringtotop = true
string dataobject = "d_cat_lot"
boolean hscrollbar = true
boolean vscrollbar = true
boolean border = true
boolean hsplitscroll = true
end type

event getfocus;call super::getfocus;w_ancestor_dataentry	lw_parent

// réactualiser le menu car l'option 'ajouter' n'est pas toujours disponible
IF f_GetParentWindow(this, lw_parent) = 1 THEN
	lw_parent.event ue_init_menu()
END IF

end event

event ue_checkitem;call super::ue_checkitem;as_message = ""

CHOOSE CASE as_item
	CASE "ref_lot"
		IF ibr_catalogue.uf_check_reflot(as_data, as_message) = -1 THEN
			return(-1)
		ELSE
			IF gu_dwservices.uf_findduplicate(This, al_row, "ref_lot='" + as_data + "'") <> 0 THEN
				as_message = "Cette référence de lot existe déjà"
				return(-1)
			END IF
		END IF
		return(1)
		
	CASE "pu1"
		return(ibr_catalogue.uf_check_pu1(as_data, as_message))
		
	CASE "pu2"
		return(ibr_catalogue.uf_check_pu2(as_data, as_message))
	
	CASE "pu3"
		return(ibr_catalogue.uf_check_pu3(as_data, as_message))
		
	CASE "rem"
		return(ibr_catalogue.uf_check_rem(as_data, as_message))

END CHOOSE

return(1)
end event

event ue_help;call super::ue_help;str_params	lstr_params

IF NOT isValid(idwo_currentItem) THEN return
IF isNull(idwo_currentItem) THEN return

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

event ue_itemvalidated;call super::ue_itemvalidated;IF as_name = "ref_lot" THEN wf_init_sp(al_row, as_data)
end event

type st_lot from uo_statictext within w_catalogue
integer y = 160
integer width = 2981
boolean bringtotop = true
integer weight = 700
long textcolor = 8388608
string text = "Prix par LOT (cliquez sur ~'Ajouter~' pour ajouter une référence de lot)"
alignment alignment = center!
end type

type st_pup from uo_statictext within w_catalogue
integer y = 224
integer width = 2981
boolean bringtotop = true
integer textsize = -9
integer weight = 700
boolean italic = true
long textcolor = 8388608
string text = "(NB : les prix intitulés puP représentent les prix AVEC pré-traitement)"
alignment alignment = center!
end type

