//objectcomments Calendrier des jours fériés
forward
global type w_cal_feries from w_ancestor_dataentry
end type
type dw_cal_feries from uo_datawindow_multiplerow within w_cal_feries
end type
type dw_annee from uo_datawindow_singlerow within w_cal_feries
end type
end forward

global type w_cal_feries from w_ancestor_dataentry
string tag = "TEXT_00800"
integer width = 1874
integer height = 1720
string title = "Calendrier des jours fériés"
boolean maxbox = true
boolean resizable = true
dw_cal_feries dw_cal_feries
dw_annee dw_annee
end type
global w_cal_feries w_cal_feries

type variables
uo_ds	ids_agent_alloc
end variables

forward prototypes
public subroutine wf_init ()
end prototypes

public subroutine wf_init ();datawindowchild	ldwc_annee

// lecture des années où il y a des congés encodés
IF dw_annee.getchild("n_annee", ldwc_annee) = 1 THEN
	ldwc_annee.setTransObject(SQLCA)
	dw_annee.insertrow(0)
	ldwc_annee.retrieve()
END IF

// lecture des congés
dw_cal_feries.retrieve()
wf_actif(true)


end subroutine

on w_cal_feries.create
int iCurrent
call super::create
this.dw_cal_feries=create dw_cal_feries
this.dw_annee=create dw_annee
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_cal_feries
this.Control[iCurrent+2]=this.dw_annee
end on

on w_cal_feries.destroy
call super::destroy
destroy(this.dw_cal_feries)
destroy(this.dw_annee)
end on

event ue_open;call super::ue_open;// icône(s) à rendre visible(s) dans le menu
wf_SetItemsToShow({"m_ajouter"})

// initialiser liste des DW modifiables
wf_SetDWList({dw_cal_feries})

// divers settings des DW
dw_cal_feries.uf_autoselectrow(FALSE)
dw_cal_feries.uf_checkallrow(TRUE)
dw_cal_feries.uf_sort(TRUE)
dw_cal_feries.uf_createwhenlastdeleted(FALSE)

// lecture 
wf_init()

// filtre par défaut sur l'année en cours
dw_annee.setItem(1, "n_annee", year(today()))
dw_cal_feries.setFilter("year(dateferie)=" + string(year(today())))
dw_cal_feries.Filter()
dw_cal_feries.Sort()

end event

event resize;call super::resize;dw_cal_feries.height = wf_getwsheight() - dw_cal_feries.y - 20
dw_cal_feries.width = wf_getwswidth()
end event

event ue_enregistrer;call super::ue_enregistrer;long	ll_row, ll_found

// contrôle de validité de tous les champs
IF dw_cal_feries.event ue_checkall() < 0 THEN
	dw_cal_feries.SetFocus()
	return(-1)
END IF

IF gu_dwservices.uf_updatetransact(dw_cal_feries) = 1 THEN
	// rafraîchir affichage
	wf_init()
	wf_message("Calendrier enregistré avec succès")
	return(1)
ELSE
	populateerror(20000, "")
	gu_message.uf_unexp("CAL_FERIES : Erreur lors de la mise à jour de la base de données")
	return(-1)
END IF

end event

event ue_init_menu;call super::ue_init_menu;f_menuaction({"m_ajouter", "m_supprimer", "m_enregistrer", "m_abandonner", "m_fermer"})
end event

event ue_supprimer;call super::ue_supprimer;IF dw_cal_feries.GetRow() = 0 THEN return
dw_cal_feries.event ue_delete()

end event

event ue_ajouter;call super::ue_ajouter;dw_cal_feries.event ue_addrow()

end event

type ddlb_message from w_ancestor_dataentry`ddlb_message within w_cal_feries
integer y = 1440
integer width = 1646
end type

type dw_cal_feries from uo_datawindow_multiplerow within w_cal_feries
integer y = 128
integer width = 1810
integer height = 1280
integer taborder = 10
boolean bringtotop = true
string dataobject = "d_cal_feries"
boolean hscrollbar = true
boolean vscrollbar = true
boolean border = true
end type

event ue_checkitem;call super::ue_checkitem;CHOOSE CASE as_item
	CASE "dateferie"
		IF f_isEmptyString(as_data) THEN
			as_message = "Veuillez préciser une date"
			return(-1)
		END IF
	CASE "motif"
		IF f_isEmptyString(as_data) THEN
			as_message = "Veuillez préciser le motif"
			return(-1)
		END IF
END CHOOSE

return(1)
end event

type dw_annee from uo_datawindow_singlerow within w_cal_feries
integer x = 37
integer y = 16
integer width = 658
integer height = 96
integer taborder = 10
boolean bringtotop = true
string dataobject = "d_cal_feries_annee"
end type

event ue_checkitem;call super::ue_checkitem;// filtre sur l'année sélectionnée

// sauver données en cours
IF wf_canupdate() THEN
	IF event ue_enregistrer() = -1 THEN
		this.setText(string(this.object.n_annee[1]))
		return(-2)
	END IF
END IF

// appliquer le filtre
dw_cal_feries.setFilter("year(dateferie)=" + as_data)
dw_cal_feries.Filter()
dw_cal_feries.Sort()

end event

