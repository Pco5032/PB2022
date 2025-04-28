//objectcomments Sélection du(des) remplaçant(s) d'un responsable absent
forward
global type w_remplacement from w_ancestor_dataentry
end type
type dw_remp from uo_datawindow_multiplerow within w_remplacement
end type
type dw_resp from uo_datawindow_singlerow within w_remplacement
end type
end forward

global type w_remplacement from w_ancestor_dataentry
string tag = "TEXT_00607"
integer width = 3945
integer height = 2144
string title = "Remplacement d~'un responsable absent"
boolean maxbox = true
boolean resizable = true
dw_remp dw_remp
dw_resp dw_resp
end type
global w_remplacement w_remplacement

type variables
string	is_resp
end variables

forward prototypes
public subroutine wf_initnewrow (long al_row)
end prototypes

public subroutine wf_initnewrow (long al_row);IF al_row <= 0 THEN return
dw_remp.object.resp_matricule[al_row] = is_resp

end subroutine

on w_remplacement.create
int iCurrent
call super::create
this.dw_remp=create dw_remp
this.dw_resp=create dw_resp
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_remp
this.Control[iCurrent+2]=this.dw_resp
end on

on w_remplacement.destroy
call super::destroy
destroy(this.dw_remp)
destroy(this.dw_resp)
end on

event resize;call super::resize;dw_remp.width = newwidth
dw_remp.height = newheight - 100 - dw_remp.y
end event

event ue_open;call super::ue_open;// icône "ajouter" doit être visible dans le menu
wf_SetItemsToShow({"m_ajouter"})

// initialiser liste des DW modifiables
wf_SetDWList({dw_remp})

// divers settings des DW
dw_remp.uf_checkallrow(TRUE)
dw_remp.uf_sort(TRUE)
dw_remp.uf_createwhenlastdeleted(FALSE)


end event

event ue_supprimer;call super::ue_supprimer;string	ls_matricule, ls_message

IF dw_remp.GetRow() = 0 THEN return

ls_matricule = dw_remp.object.remp_matricule[dw_remp.GetRow()]

IF f_confirm_del("Voulez-vous supprimer l'agent " + f_string(ls_matricule) + " ?") = 1 THEN
	dw_remp.event ue_delete()
END IF

end event

event ue_init_menu;call super::ue_init_menu;IF wf_isactif() THEN
	f_menuaction({"m_enregistrer", "m_ajouter", "m_supprimer", "m_abandonner", "m_fermer"})
ELSE
	f_menuaction({"m_fermer"})
END IF



end event

event ue_enregistrer;call super::ue_enregistrer;// contrôle de validité de tous les champs
IF dw_remp.event ue_checkall() < 0 THEN
	dw_remp.SetFocus()
	return(-1)
END IF

IF dw_remp.event ue_update() = 1 THEN
	wf_message("Liste des remplaçants enregistrée avec succès")
	this.event ue_init_win()
	return(1)
ELSE
	populateerror(20000, "")
	gu_message.uf_unexp("REMPLACEMENT : Erreur lors de la mise à jour de la base de données")
	return(-1)
END IF
end event

event ue_ajouter;call super::ue_ajouter;long	ll_row

ll_row = dw_remp.event ue_addrow()
IF ll_row > 0 THEN wf_initnewrow(ll_row)
end event

event ue_init_win;call super::ue_init_win;is_resp = ""

dw_resp.uf_reset()
dw_remp.uf_reset()
dw_remp.enabled = FALSE
dw_resp.enabled = TRUE
dw_resp.uf_enabledata()
dw_resp.object.t_nom.text = ""

dw_resp.insertRow(0)
dw_resp.SetFocus()

end event

type ddlb_message from w_ancestor_dataentry`ddlb_message within w_remplacement
integer y = 1936
end type

type dw_remp from uo_datawindow_multiplerow within w_remplacement
integer y = 128
integer width = 3895
integer height = 1664
integer taborder = 10
boolean bringtotop = true
string dataobject = "d_remplacement"
boolean hscrollbar = true
boolean vscrollbar = true
end type

event ue_checkitem;call super::ue_checkitem;string	ls_nom, ls_codeservice, ls_service, ls_grade
integer	li_st
date		l_date, l_date_debut

CHOOSE CASE as_item
	CASE "remp_matricule"
		// s'assurer de l'unicité du matricule
		IF dw_remp.find("remp_matricule='" + as_data +"' and getrow()<>" + string(al_row), 1, dw_remp.RowCount()) > 0 THEN
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
		
		CASE "date_debut"
			l_date = date(as_data)
			IF isNull(l_date) THEN
				as_message = "Date incorrecte"
				return(-1)
			END IF
	
		CASE "date_fin"
			l_date_debut = date(this.object.date_debut[al_row])
			l_date = date(as_data)
			IF isNull(l_date) THEN
				as_message = "Date incorrecte"
				return(-1)
			END IF
			IF l_date < l_date_debut THEN
				as_message = "La date de fin doit être postérieure à la date de début"
				return(-1)
			END IF

END CHOOSE
return(1)

end event

event ue_help;call super::ue_help;str_params	lstr_params

IF NOT IsValid(idwo_currentItem) THEN return
CHOOSE CASE idwo_currentItem.name
	CASE "remp_matricule"
		open(w_l_agent)
		IF Message.DoubleParm = -1 THEN 
			return
		ELSE
			lstr_params = Message.PowerObjectParm
			this.uf_setdefaultvalue(al_row, "remp_matricule", string(lstr_params.a_param[1]))
		END IF
END CHOOSE
end event

type dw_resp from uo_datawindow_singlerow within w_remplacement
integer y = 16
integer width = 3877
integer height = 96
integer taborder = 10
boolean bringtotop = true
string dataobject = "d_remplacement_resp"
end type

event ue_help;call super::ue_help;string		ls_code
str_params	lstr_params

IF NOT IsValid(idwo_currentItem) THEN return

open(w_l_agent)
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

select nom into :ls_nom from agent where matricule=:as_data using ESQLCA;
li_st = f_check_sql(ESQLCA)
CHOOSE CASE li_st
	CASE 100
		as_message = "Matricule inexistant"
		return(-1)
	CASE -1
		as_message = "Erreur SELECT AGENT"
		return(-1)
	CASE 0
		this.object.t_nom.text = ls_nom
		return(1)
END CHOOSE
end event

event ue_itemvalidated;call super::ue_itemvalidated;is_resp = as_data
dw_remp.enabled = TRUE
dw_resp.enabled = FALSE
dw_resp.uf_disabledata()
wf_actif(true)

// Lecture du(des) remplaçants de ce responsable.
IF dw_remp.retrieve(as_data) = 0 THEN
	wf_message("Configuration d'un remplacement")
ELSE
	wf_message("Modification d'un remplacement")
END IF

parent.event ue_init_menu()


end event

event buttonclicked;call super::buttonclicked;string		ls_code
str_params	lstr_params

IF NOT IsValid(idwo_currentItem) THEN return

open(w_l_remplacement)
IF Message.DoubleParm = -1 THEN 
	return
ELSE
	lstr_params = Message.PowerObjectParm
	this.uf_setdefaultvalue(row, "s_resp", string(lstr_params.a_param[1]))
END IF
end event

