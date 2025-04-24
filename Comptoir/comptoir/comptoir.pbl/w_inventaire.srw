//objectcomments Encodage des inventaires
forward
global type w_inventaire from w_ancestor_dataentry
end type
type dw_date from uo_datawindow_singlerow within w_inventaire
end type
type dw_inv from uo_datawindow_multiplerow within w_inventaire
end type
type gb_dt from groupbox within w_inventaire
end type
end forward

global type w_inventaire from w_ancestor_dataentry
integer height = 1992
string title = "Encodage des inventaires"
boolean resizable = true
dw_date dw_date
dw_inv dw_inv
gb_dt gb_dt
end type
global w_inventaire w_inventaire

type variables
date		idt_date
br_inventaire	ibr_inventaire

end variables

forward prototypes
public function integer wf_init ()
public function integer wf_newlig ()
public function integer wf_initnewlig (long al_row)
end prototypes

public function integer wf_init ();// lectures des ligens de l'inventaire et si pas de ligne, en créer une
dw_inv.retrieve(idt_date)

// créer 1ère ligne s'il n'y en a pas
IF dw_inv.RowCount() = 0 THEN
	wf_newlig()
END IF

// disabler la clé et enabler les datas
dw_date.uf_disabledata()
dw_inv.uf_enabledata()
dw_inv.SetFocus()

this.event ue_init_menu()
return(1)
end function

public function integer wf_newlig ();// ajout d'une ligne inventaire
// return(-1) si erreur
// return(n° de row ajoutée) si OK
long		ll_row

ll_row = dw_inv.event ue_addrow()
IF ll_row <= 0 THEN
	return(-1)
ELSE
	return(ll_row)
END IF

end function

public function integer wf_initnewlig (long al_row);// initialiser nouvelle ligne inventaire
// return(-1) si erreur
// return(n° de row ajoutée) si OK

integer	li_num

// initialiser 1ère partie de la PK
dw_inv.object.dt_inv[al_row] = idt_date

// numérotation auto.
li_num = dw_inv.object.c_maxnum[al_row]
IF IsNull(li_num) THEN 
	li_num = 1
ELSE
	li_num++
END IF		

IF li_num > 0 AND li_num <= 9999 THEN 
	dw_inv.object.num_inv[al_row] = li_num
	dw_inv.SetColumn("ref_lot")
ELSE
	dw_inv.SetColumn("num_inv")
END IF

dw_inv.object.datawindow.HorizontalScrollPosition = 1
dw_inv.SetFocus()

return(al_row)
end function

on w_inventaire.create
int iCurrent
call super::create
this.dw_date=create dw_date
this.dw_inv=create dw_inv
this.gb_dt=create gb_dt
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_date
this.Control[iCurrent+2]=this.dw_inv
this.Control[iCurrent+3]=this.gb_dt
end on

on w_inventaire.destroy
call super::destroy
destroy(this.dw_date)
destroy(this.dw_inv)
destroy(this.gb_dt)
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
		// menu si curseur est sur la date de l'inventaire
		CASE "dw_date"
			IF NOT dw_date.uf_IsRecordNew() AND wf_canDelete() THEN
				li_item++
				ls_menu[li_item] = "m_supprimer"
			END IF
		// menu si curseur est sur les lignes détail
		CASE "dw_inv"
			IF wf_canUpdate() THEN
				li_item++
				ls_menu[li_item] = "m_ajouter"
				li_item++
				ls_menu[li_item] = "m_supprimer"				
			END IF
	END CHOOSE
END IF

f_menuaction(ls_menu)
end event

event ue_open;call super::ue_open;ibr_inventaire = CREATE br_inventaire

// icône "ajouter" doit être visible dans le menu
wf_SetItemsToShow({"m_ajouter"})

wf_SetDWList({dw_inv})

end event

event ue_close;call super::ue_close;DESTROY ibr_inventaire

end event

event ue_init_win;call super::ue_init_win;this.setredraw(FALSE)

dw_date.uf_reset()
dw_inv.uf_reset()

dw_inv.object.datawindow.HorizontalScrollPosition = 1

dw_date.insertrow(0)
dw_date.uf_enabledata()
dw_date.setfocus()

this.setredraw(TRUE)
end event

event ue_supprimer;call super::ue_supprimer;string	ls_message
integer	li_num

CHOOSE CASE wf_GetActivecontrolname()
	// suppression de tout l'inventaire
	CASE "dw_date"
		IF ibr_inventaire.uf_check_beforedelete(idt_date, ls_message) = -1 THEN
			gu_message.uf_info(ls_message)
			return
		END IF
		IF f_confirm_del("Voulez-vous supprimer tout l'inventaire du " + string(idt_date, "dd/mm/yyyy") + " ?") = 1 THEN
			delete INVENTAIRE where dt_inv=:idt_date using ESQLCA;
			IF f_check_sql(ESQLCA) <> 0 THEN
				rollback using ESQLCA;
				populateerror(20000, "")
				gu_message.uf_unexp("Erreur DELETE INVENTAIRE")
			ELSE
				commit using ESQLCA;
				wf_message("Inventaire supprimé avec succès")
				this.event ue_init_win()
			END IF
		END IF
		
	// suppression d'une ligne inventaire
	CASE  "dw_inv"
		li_num = integer(dw_inv.object.num_inv[dw_inv.GetRow()])
		IF ibr_inventaire.uf_check_numinv_beforedelete(idt_date, li_num, ls_message) = -1 THEN
			gu_message.uf_info(ls_message)
			return
		END IF
		IF f_confirm_del("Voulez-vous supprimer la ligne d'inventaire n° " + f_string(li_num) + " ?") = 1 THEN
			IF dw_inv.event ue_delete() = 1 THEN
				wf_message("Ligne " + string(li_num) + " supprimée avec succès de l'inventaire")
			END IF
		END IF
END CHOOSE

end event

event ue_enregistrer;call super::ue_enregistrer;integer	li_status

// contrôle de validité de tous les champs
IF dw_inv.event ue_checkall() < 0 THEN
	dw_inv.SetFocus()
	return(-1)
END IF

li_status = gu_dwservices.uf_updatetransact(dw_inv)
CHOOSE CASE li_status
	CASE 1
		wf_message("Inventaire de " + string(idt_date, "dd/mm/yyyy") + " enregistré avec succès")
		This.event ue_init_win()
		return(1)
	CASE -1
		populateerror(20000,"")
		gu_message.uf_unexp("INVENTAIRE : Erreur lors de la mise à jour de la base de données")
		return(-1)
END CHOOSE

end event

event ue_ajouter;call super::ue_ajouter;long	ll_row

CHOOSE CASE wf_GetActivecontrolname()
	// ajouter une nouvelle ligne si le curseur est sur dw_inv
	CASE "dw_inv"
		wf_newlig()
END CHOOSE
end event

event resize;call super::resize;gb_dt.width = newwidth
dw_inv.width = newwidth
dw_inv.height = newheight - 176
end event

type ddlb_message from w_ancestor_dataentry`ddlb_message within w_inventaire
integer y = 1792
end type

type dw_date from uo_datawindow_singlerow within w_inventaire
integer x = 1152
integer y = 48
integer width = 951
integer height = 112
integer taborder = 10
boolean bringtotop = true
string dataobject = "d_inventaire_dt"
end type

event ue_checkitem;call super::ue_checkitem;date	ldt_date
long	ll_count
integer	li_status

CHOOSE CASE as_item
	CASE "dt_inventaire"
		IF ibr_inventaire.uf_check_dtinv(as_data, as_message) = -1 THEN
			return(-1)
		END IF
		// vérifier s'il existe déjà des inventaires à cette date
		ldt_date = date(as_data)
		select count(*) into :ll_count from inventaire
				where dt_inv = :ldt_date using ESQLCA;
		li_status = f_check_sql(ESQLCA)
		IF li_status < 0 THEN
			populateerror(20000,"")
			gu_message.uf_unexp("Erreur SELECT INVENTAIRE")
			return(-1)
		ELSE
			// inventaire inexistant...
			IF ll_count = 0 THEN
				// ...et on peut modifier les données...
				IF wf_canUpdate() THEN
						idt_date = ldt_date
						return(1)
				ELSE
				// ...et on ne peut pas modifier les données
					as_message = "Inventaire inexistant. Vous n'avez pas le droit d'en créer..."
					return(-1)
				END IF
			ELSE
			// Inventaire existe déjà : OK
				idt_date = ldt_date
				return(1)
			END IF
		END IF
END CHOOSE

return(1)
end event

event ue_help;call super::ue_help;str_params	lstr_params

CHOOSE CASE idwo_currentItem.name
	CASE "dt_inventaire"
		open(w_l_inventaire)
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

event ue_postitemvalidated;call super::ue_postitemvalidated;wf_actif(true)

// effacer les messages
ddlb_message.reset()

wf_message("Encodage inventaire")

wf_init()

end event

type dw_inv from uo_datawindow_multiplerow within w_inventaire
integer y = 176
integer width = 3493
integer height = 1616
integer taborder = 11
boolean bringtotop = true
string dataobject = "d_inventaire"
boolean hscrollbar = true
boolean vscrollbar = true
boolean border = true
end type

event getfocus;call super::getfocus;w_ancestor_dataentry	lw_parent

// réactualiser le menu car l'option 'ajouter' n'est pas toujours disponible
IF f_GetParentWindow(this, lw_parent) = 1 THEN
	lw_parent.event ue_init_menu()
END IF

end event

event ue_checkitem;call super::ue_checkitem;CHOOSE CASE as_item
	CASE "num_inv"
		IF ibr_inventaire.uf_check_numinv(as_data, as_message) = -1 THEN
			return(-1)
		ELSE
			IF gu_dwservices.uf_findduplicate(This, al_row, "num_inv=" + as_data) <> 0 THEN
				as_message = "Ce n° de ligne inventaire existe déjà"
				return(-1)
			END IF
		END IF
		return(1)
	CASE "ref_lot"
		return(ibr_inventaire.uf_check_reflot(as_data, as_message))

	CASE "qte"
		return(ibr_inventaire.uf_check_qte(as_data, as_message))
		
	CASE "conditionnement"
		return(ibr_inventaire.uf_check_cond(as_data, as_message))
	
	CASE "utilisation"
		return(ibr_inventaire.uf_check_util(as_data, as_message))
		
	CASE "num_chfroide"
		return(ibr_inventaire.uf_check_chfroide(as_data, as_message))
		
	CASE "remarque"
		return(ibr_inventaire.uf_check_rem(as_data, as_message))

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

event ue_synchro;call super::ue_synchro;wf_initnewlig(al_currentrow)
end event

type gb_dt from groupbox within w_inventaire
integer width = 3493
integer height = 176
integer taborder = 10
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 8388608
long backcolor = 67108864
end type

