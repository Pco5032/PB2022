//objectcomments Sélection des responsables (C1, CP) par service
forward
global type w_responsable from w_ancestor_dataentry
end type
type dw_responsable from uo_datawindow_multiplerow within w_responsable
end type
type dw_service from uo_datawindow_singlerow within w_responsable
end type
type dw_responsable_automatique from uo_ancestor_dwbrowse within w_responsable
end type
type st_auto from uo_statictext within w_responsable
end type
end forward

global type w_responsable from w_ancestor_dataentry
integer width = 4009
integer height = 2096
string title = "Sélection des responsables (C1, CP, GR) par service"
boolean maxbox = true
boolean resizable = true
dw_responsable dw_responsable
dw_service dw_service
dw_responsable_automatique dw_responsable_automatique
st_auto st_auto
end type
global w_responsable w_responsable

type variables
string	is_codeservice
end variables

forward prototypes
public subroutine wf_initnewrow (long al_row)
end prototypes

public subroutine wf_initnewrow (long al_row);IF al_row <= 0 THEN return
dw_responsable.object.codeservice[al_row] = is_codeservice
dw_responsable.object.cp_document[al_row] = "N"

end subroutine

on w_responsable.create
int iCurrent
call super::create
this.dw_responsable=create dw_responsable
this.dw_service=create dw_service
this.dw_responsable_automatique=create dw_responsable_automatique
this.st_auto=create st_auto
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_responsable
this.Control[iCurrent+2]=this.dw_service
this.Control[iCurrent+3]=this.dw_responsable_automatique
this.Control[iCurrent+4]=this.st_auto
end on

on w_responsable.destroy
call super::destroy
destroy(this.dw_responsable)
destroy(this.dw_service)
destroy(this.dw_responsable_automatique)
destroy(this.st_auto)
end on

event resize;call super::resize;dw_responsable.width = newwidth - 8
dw_responsable.height = newheight - dw_responsable.y - dw_responsable_automatique.height - st_auto.height - 100

st_auto.width = newwidth - 8
dw_responsable_automatique.width = newwidth - 8
st_auto.y = dw_responsable.y + dw_responsable.height
dw_responsable_automatique.y = st_auto.y + st_auto.height
end event

event ue_open;call super::ue_open;// icône "ajouter" doit être visible dans le menu
wf_SetItemsToShow({"m_ajouter"})

// initialiser liste des DW modifiables
wf_SetDWList({dw_responsable})

// divers settings des DW
dw_responsable.uf_checkallrow(TRUE)
dw_responsable.uf_sort(TRUE)
dw_responsable.uf_createwhenlastdeleted(FALSE)


end event

event ue_supprimer;call super::ue_supprimer;string	ls_matricule, ls_message

IF dw_responsable.GetRow() = 0 THEN return

ls_matricule = dw_responsable.object.matricule[dw_responsable.GetRow()]

IF f_confirm_del("Voulez-vous supprimer l'agent " + f_string(ls_matricule) + " ?") = 1 THEN
	dw_responsable.event ue_delete()
END IF

end event

event ue_init_menu;call super::ue_init_menu;IF wf_isactif() THEN
	f_menuaction({"m_enregistrer", "m_ajouter", "m_supprimer", "m_abandonner", "m_fermer"})
ELSE
	f_menuaction({"m_fermer"})
END IF



end event

event ue_enregistrer;call super::ue_enregistrer;// contrôle de validité de tous les champs
IF dw_responsable.event ue_checkall() < 0 THEN
	dw_responsable.SetFocus()
	return(-1)
END IF

IF dw_responsable.event ue_update() = 1 THEN
	wf_message("Liste des agents enregistrée avec succès")
	this.event ue_init_win()
	return(1)
ELSE
	populateerror(20000, "")
	gu_message.uf_unexp("RESPONSABLE : Erreur lors de la mise à jour de la base de données")
	return(-1)
END IF
end event

event ue_ajouter;call super::ue_ajouter;long	ll_row

ll_row = dw_responsable.event ue_addrow()
wf_initnewrow(ll_row)
end event

event ue_init_win;call super::ue_init_win;is_codeservice = ""

dw_service.uf_reset()
dw_responsable.uf_reset()
dw_responsable_automatique.uf_reset()
dw_responsable.enabled = FALSE
dw_service.enabled = TRUE
dw_service.uf_enabledata()
dw_service.object.t_nom.text = ""

dw_service.insertRow(0)
dw_service.SetFocus()

end event

type ddlb_message from w_ancestor_dataentry`ddlb_message within w_responsable
integer y = 1888
end type

type dw_responsable from uo_datawindow_multiplerow within w_responsable
integer y = 112
integer width = 3968
integer height = 1152
integer taborder = 10
boolean bringtotop = true
string dataobject = "d_responsable"
boolean hscrollbar = true
boolean vscrollbar = true
boolean border = true
end type

event ue_checkitem;call super::ue_checkitem;string	ls_nom, ls_codeservice, ls_service, ls_grade
integer	li_st

CHOOSE CASE as_item
	CASE "matricule"
		// s'assurer de l'unicité du matricule
		IF dw_responsable.find("matricule='" + as_data +"' and getrow()<>" + string(al_row), 1, dw_responsable.RowCount()) > 0 THEN
			as_message = "Cet agent figure déjà dans la liste"
			return(-1)
		END IF
		
		// vérifier existence		
		select a.nom, a.grade, a.codeservice, s.service 
				into :ls_nom, :ls_grade, :ls_codeservice, :ls_service 
				from agent a, service s
				where s.codeservice=a.codeservice and a.matricule=:as_data using ESQLCA;
		li_st = f_check_sql(ESQLCA)
		CHOOSE CASE li_st
			CASE 100
				as_message = "Matricule inexistant"
				return(-1)
			CASE -1
				as_message = "Erreur SELECT AGENT"
				return(-1)
			CASE 0
				this.object.agent_nom[al_row] = ls_nom
				this.object.agent_grade[al_row] = ls_grade
				this.object.agent_codeservice[al_row] = ls_codeservice
				this.object.service_service[al_row] = ls_service
				return(1)
		END CHOOSE
		
	CASE "role"
		IF f_isEmptyString(as_data) THEN
			as_message = "Veuillez sélectionner un rôle"
			return(-1)
		ELSE
			return(1)
		END IF
		
	CASE "cp_document"
		IF NOT match(as_data, "^[ON]$") THEN
			as_message = "Veuillez préciser si ce responsable est imprimé comme 'CP' sur les documents"
			return(-1)
		ELSE
			return(1)
		END IF
		
END CHOOSE
return(1)

end event

event ue_help;call super::ue_help;string		ls_matricule
str_params	lstr_params

IF NOT IsValid(idwo_currentItem) THEN return
CHOOSE CASE idwo_currentItem.name
	CASE "matricule"
		open(w_l_agent)
		IF Message.DoubleParm = -1 THEN 
			return
		ELSE
			lstr_params = Message.PowerObjectParm
			this.uf_setdefaultvalue(al_row, "matricule", string(lstr_params.a_param[1]))
		END IF
END CHOOSE
end event

event ue_itemvalidated;call super::ue_itemvalidated;long	ll_row

// un seul CP doit être sélectionné pour apparaître sur les documents
IF as_name = "cp_document" THEN
	IF as_data = "O" THEN
		FOR ll_row = 1 TO this.rowCount()
			IF ll_row <> al_row AND this.object.cp_document[ll_row] = "O" THEN
				this.object.cp_document[ll_row] = "N"
			END IF
		NEXT
	END IF
END IF
end event

type dw_service from uo_datawindow_singlerow within w_responsable
integer y = 16
integer width = 2322
integer height = 96
integer taborder = 10
boolean bringtotop = true
string dataobject = "d_responsable_service"
end type

event ue_help;call super::ue_help;string		ls_code
str_params	lstr_params

IF NOT IsValid(idwo_currentItem) THEN return

open(w_l_service)
IF Message.DoubleParm = -1 THEN 
	return
ELSE
	lstr_params = Message.PowerObjectParm
	this.SetText(string(lstr_params.a_param[1]))
	f_presskey("tab")
END IF
end event

event ue_checkitem;call super::ue_checkitem;integer	li_st
string	ls_nom

select service into :ls_nom from service where codeservice=:as_data using ESQLCA;
li_st = f_check_sql(ESQLCA)
CHOOSE CASE li_st
	CASE 100
		as_message = "Service inexistant"
		return(-1)
	CASE -1
		as_message = "Erreur SELECT SERVICE"
		return(-1)
	CASE 0
		this.object.t_nom.text = ls_nom
		return(1)
END CHOOSE
end event

event ue_itemvalidated;call super::ue_itemvalidated;IF dw_responsable.retrieve(as_data) = 0 THEN
	wf_message("1ère configuration des responsables du service")
ELSE
	wf_message("Modification des responsables du service")
END IF

dw_responsable_automatique.retrieve(as_data)

dw_responsable.enabled = TRUE
dw_service.enabled = FALSE
dw_service.uf_disabledata()
wf_actif(true)
parent.event ue_init_menu()

is_codeservice = as_data

end event

type dw_responsable_automatique from uo_ancestor_dwbrowse within w_responsable
integer y = 1360
integer width = 3950
integer height = 464
integer taborder = 11
boolean bringtotop = true
string dataobject = "d_responsable_automatique"
boolean hscrollbar = true
boolean vscrollbar = true
boolean border = true
end type

type st_auto from uo_statictext within w_responsable
integer y = 1280
integer width = 3840
integer height = 80
boolean bringtotop = true
integer textsize = -9
integer weight = 700
long textcolor = 8388608
string text = "Responsables déduits de la table SERVICE"
alignment alignment = center!
end type

