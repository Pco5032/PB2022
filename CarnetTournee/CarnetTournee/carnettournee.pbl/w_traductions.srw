forward
global type w_traductions from w_ancestor_dataentry
end type
type dw_1 from uo_datawindow_multiplerow within w_traductions
end type
type ddlb_1 from uo_dropdownlistbox within w_traductions
end type
type st_1 from uo_statictext within w_traductions
end type
end forward

global type w_traductions from w_ancestor_dataentry
integer width = 4073
integer height = 2392
string title = "Traductions"
boolean maxbox = true
boolean resizable = true
dw_1 dw_1
ddlb_1 ddlb_1
st_1 st_1
end type
global w_traductions w_traductions

type variables
integer	li_cle
boolean	ib_updatable
end variables

forward prototypes
public subroutine wf_initnew (long al_row)
end prototypes

public subroutine wf_initnew (long al_row);dw_1.SetColumn("champ")

// initialiser 'champ' avec valeur de la ligne précédente (ou suivante si on est sur la 1ère ligne
IF al_row > 1 THEN
	dw_1.SetText(dw_1.object.champ[al_row - 1])
ELSE
	IF dw_1.RowCount() > 1 THEN
		dw_1.SetText(dw_1.object.champ[al_row + 1])
	END IF
END IF

end subroutine

on w_traductions.create
int iCurrent
call super::create
this.dw_1=create dw_1
this.ddlb_1=create ddlb_1
this.st_1=create st_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_1
this.Control[iCurrent+2]=this.ddlb_1
this.Control[iCurrent+3]=this.st_1
end on

on w_traductions.destroy
call super::destroy
destroy(this.dw_1)
destroy(this.ddlb_1)
destroy(this.st_1)
end on

event ue_init_menu;call super::ue_init_menu;string	ls_menu, ls_item[]

ls_menu = "m_abandonner,m_fermer"
IF wf_canupdate() THEN
	ls_menu = ls_menu + ",m_enregistrer,m_ajouter,m_inserer,m_abandonner,m_fermer"
END IF
IF wf_candelete() THEN
	ls_menu = ls_menu + ",m_supprimer"
END IF
f_parse(ls_menu, ",", ls_item)
f_menuaction(ls_item)
end event

event ue_ajouter;call super::ue_ajouter;long		ll_row

ll_row = dw_1.event ue_addrow()
wf_initnew(ll_row)
end event

event ue_enregistrer;call super::ue_enregistrer;// contrôle de validité de tous les champs
IF dw_1.event ue_checkall() < 0 THEN
	dw_1.SetFocus()
	return(-1)
END IF

IF dw_1.event ue_update() = 1 THEN
	return(1)
ELSE
	populateerror(20000, "")
	gu_message.uf_unexp()
	return(-1)
END IF
end event

event ue_init_win;call super::ue_init_win;// la fenêtre contient tout de suite des données actives (le retrieve est déjà fait)
IF wf_canupdate() THEN
	wf_actif(TRUE)
END IF

end event

event ue_supprimer;call super::ue_supprimer;if f_confirm_del("Voulez-vous supprimer cette traduction ?") = 1 THEN
	dw_1.event ue_delete()
END IF

end event

event ue_abandonner;post close(this)
return(0)
end event

event ue_inserer;call super::ue_inserer;long	ll_row
ll_row = dw_1.event ue_insertrow()
wf_initnew(ll_row)
end event

event resize;call super::resize;dw_1.height = wf_getWSHeight() - dw_1.y
dw_1.width = wf_getWSWidth()
end event

event ue_postopen;call super::ue_postopen;IF NOT wf_Executepostopen() THEN return

// garnir la ddlb permettant le filtrage sur 'champ'
string	ls_champ

DECLARE filtre CURSOR FOR
	SELECT DISTINCT champ FROM traduc USING ESQLCA;

OPEN filtre;
FETCH filtre INTO :ls_champ;
DO WHILE f_check_sql(ESQLCA) = 0
	ddlb_1.AddItem(ls_champ)
	FETCH filtre INTO :ls_champ;
LOOP
CLOSE filtre;
ddlb_1.AddItem(" ")

end event

event ue_open;call super::ue_open;integer	li_status

// icône "ajouter" doit être visible dans le menu
wf_SetItemsToShow({"m_ajouter","m_inserer"})

// initialiser liste des DW modifiables
wf_SetDWList({dw_1})

dw_1.uf_checkallrow(FALSE)
dw_1.uf_sort(TRUE)

// lecture de toutes les traductions
IF dw_1.retrieve() < 0 THEN
	wf_Executepostopen(FALSE)
	post close(this)
	return
END IF

// tester si on travaille sur une table ou un snapshot
update traduc set trad = '' using esqlca;
if esqlca.sqlcode <> 0 then
	wf_canupdate(FALSE)
	wf_candelete(FALSE)
end if
rollback using esqlca;

dw_1.SetFocus()
end event

type ddlb_message from w_ancestor_dataentry`ddlb_message within w_traductions
integer y = 1712
integer width = 3035
end type

type dw_1 from uo_datawindow_multiplerow within w_traductions
integer y = 112
integer width = 3785
integer height = 1584
integer taborder = 11
boolean bringtotop = true
string dataobject = "d_traduction"
boolean hscrollbar = true
boolean vscrollbar = true
boolean hsplitscroll = true
end type

event rowfocuschanging;call super::rowfocuschanging;IF dw_1.accepttext() < 0 THEN
	return(1)
END IF

end event

event ue_dwmessage;call super::ue_dwmessage;wf_message(as_dwmessage)
end event

event ue_checkitem;call super::ue_checkitem;CHOOSE CASE as_item
	// interdire le caractère " dans les traductions et les abréviations
	CASE "trad","abbr","abbrd","abbrfd","liblong","tradd"
		IF match(as_data, '"') THEN
			as_message = "le caractère ~" n'est pas autorisé"
			return(-1)
		ELSE
			return(1)
		END IF
	CASE "champ"
		IF IsNull(as_data) OR LenA(trim(as_data)) = 0 THEN
			as_message = "Le champ ne peut être vide"
			return(-1)
		ELSE
			return(1)
		END IF
END CHOOSE

return(1)
end event

type ddlb_1 from uo_dropdownlistbox within w_traductions
integer x = 329
integer y = 16
integer width = 658
integer height = 624
integer taborder = 10
boolean bringtotop = true
integer textsize = -8
boolean vscrollbar = true
end type

event selectionchanged;call super::selectionchanged;IF LenA(trim(ddlb_1.Text)) = 0 THEN
	dw_1.SetFilter("")
ELSE
	dw_1.SetFilter("champ = '" + ddlb_1.Text + "'")
END IF
dw_1.Filter()
end event

type st_1 from uo_statictext within w_traductions
integer x = 73
integer y = 16
integer width = 256
boolean bringtotop = true
string text = "Filtre sur "
end type

