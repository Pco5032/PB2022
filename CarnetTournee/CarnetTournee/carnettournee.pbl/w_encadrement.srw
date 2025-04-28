//objectcomments Sélection des préposés par agent d'encadrement
forward
global type w_encadrement from w_ancestor_dataentry
end type
type dw_prep from uo_datawindow_multiplerow within w_encadrement
end type
type dw_resp from uo_datawindow_singlerow within w_encadrement
end type
type rb_service from uo_radiobutton within w_encadrement
end type
type rb_agent from uo_radiobutton within w_encadrement
end type
type st_1 from uo_statictext within w_encadrement
end type
type cb_info from uo_cb within w_encadrement
end type
end forward

global type w_encadrement from w_ancestor_dataentry
integer width = 4018
integer height = 2296
string title = "Sélection des agents dont les données sont accessibles par un autre"
boolean maxbox = true
boolean resizable = true
dw_prep dw_prep
dw_resp dw_resp
rb_service rb_service
rb_agent rb_agent
st_1 st_1
cb_info cb_info
end type
global w_encadrement w_encadrement

type variables
string	is_resp, is_info_filename, is_info_title
end variables

forward prototypes
public subroutine wf_initnewrow (long al_row)
end prototypes

public subroutine wf_initnewrow (long al_row);IF al_row <= 0 THEN return
dw_prep.object.resp_matricule[al_row] = is_resp
dw_prep.object.consult_planning[al_row] = "O"
dw_prep.object.modif_planning[al_row] = "O"
dw_prep.object.consult_realise[al_row] = "O"
dw_prep.object.modif_realise[al_row] = "O"

end subroutine

on w_encadrement.create
int iCurrent
call super::create
this.dw_prep=create dw_prep
this.dw_resp=create dw_resp
this.rb_service=create rb_service
this.rb_agent=create rb_agent
this.st_1=create st_1
this.cb_info=create cb_info
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_prep
this.Control[iCurrent+2]=this.dw_resp
this.Control[iCurrent+3]=this.rb_service
this.Control[iCurrent+4]=this.rb_agent
this.Control[iCurrent+5]=this.st_1
this.Control[iCurrent+6]=this.cb_info
end on

on w_encadrement.destroy
call super::destroy
destroy(this.dw_prep)
destroy(this.dw_resp)
destroy(this.rb_service)
destroy(this.rb_agent)
destroy(this.st_1)
destroy(this.cb_info)
end on

event resize;call super::resize;cb_info.x = newwidth - cb_info.width

dw_prep.width = newwidth
dw_prep.height = newheight - 100 - dw_prep.y
end event

event ue_open;call super::ue_open;is_info_title = "Droits d'accès officiels"
is_info_filename = gs_cenpath + "\DroitsSTD.txt"

// icône "ajouter" doit être visible dans le menu
wf_SetItemsToShow({"m_ajouter"})

// initialiser liste des DW modifiables
wf_SetDWList({dw_prep})

// divers settings des DW
dw_prep.uf_checkallrow(TRUE)
dw_prep.uf_sort(TRUE)
dw_prep.uf_createwhenlastdeleted(FALSE)


end event

event ue_supprimer;call super::ue_supprimer;string	ls_matricule, ls_message

IF dw_prep.GetRow() = 0 THEN return

ls_matricule = dw_prep.object.prep_matricule[dw_prep.GetRow()]

IF f_confirm_del("Voulez-vous supprimer l'agent " + f_string(ls_matricule) + " ?") = 1 THEN
	dw_prep.event ue_delete()
END IF

end event

event ue_init_menu;call super::ue_init_menu;IF wf_isactif() THEN
	f_menuaction({"m_enregistrer", "m_ajouter", "m_supprimer", "m_abandonner", "m_fermer"})
ELSE
	f_menuaction({"m_fermer"})
END IF



end event

event ue_enregistrer;call super::ue_enregistrer;// contrôle de validité de tous les champs
IF dw_prep.event ue_checkall() < 0 THEN
	dw_prep.SetFocus()
	return(-1)
END IF

IF dw_prep.event ue_update() = 1 THEN
	wf_message("Liste des agents enregistrée avec succès")
	this.event ue_init_win()
	return(1)
ELSE
	populateerror(20000, "")
	gu_message.uf_unexp("ENCADREMENT : Erreur lors de la mise à jour de la base de données")
	return(-1)
END IF
end event

event ue_ajouter;call super::ue_ajouter;long	ll_row

ll_row = dw_prep.event ue_addrow()
wf_initnewrow(ll_row)
end event

event ue_init_win;call super::ue_init_win;dw_resp.uf_reset()
dw_prep.uf_reset()
dw_prep.enabled = FALSE
dw_resp.enabled = TRUE
dw_resp.uf_enabledata()
dw_resp.object.t_nom.text = ""

dw_resp.insertRow(0)
dw_resp.SetFocus()
end event

type ddlb_message from w_ancestor_dataentry`ddlb_message within w_encadrement
integer y = 1936
end type

type dw_prep from uo_datawindow_multiplerow within w_encadrement
integer y = 192
integer width = 3968
integer height = 1664
integer taborder = 10
boolean bringtotop = true
string dataobject = "d_encadrement"
boolean hscrollbar = true
boolean vscrollbar = true
end type

event ue_checkitem;call super::ue_checkitem;string	ls_nom, ls_codeservice, ls_service
integer	li_st

CHOOSE CASE as_item
	CASE "prep_matricule"
		// s'assurer de l'unicité du matricule
		IF dw_prep.find("prep_matricule='" + as_data +"' and getrow()<>" + string(al_row), 1, dw_prep.RowCount()) > 0 THEN
			as_message = "Cet agent figure déjà dans la liste"
			return(-1)
		END IF
		
		// vérifier existence		
		select a.nom, a.codeservice, s.service into :ls_nom, :ls_codeservice, :ls_service 
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
				this.object.agent_codeservice[al_row] = ls_codeservice
				this.object.service_service[al_row] = ls_service
				return(1)
		END CHOOSE				
END CHOOSE
return(1)

end event

event ue_help;call super::ue_help;string		ls_code, ls_matricule, ls_codeservice
integer		li_i
long			ll_row
str_params	lstr_params

IF al_row = 0 THEN return
IF NOT IsValid(idwo_currentItem) THEN return
CHOOSE CASE idwo_currentItem.name
	CASE "prep_matricule"
		// PCO 01/2014 : affichage service ou agent selon option choisie.
		// Utile pour ajouter un agent spécifique qui n'est pas responsable d'un service
		// (par exemple pour ajouter les agents C1 dans la liste des agents du chef de cantonnement)
		IF rb_service.checked THEN
			// sélection étendue pour pouvoir sélectionner plusieurs services en une fois
			lstr_params.a_param[1] = TRUE
			openWithParm(w_l_service, lstr_params)
			IF Message.DoubleParm = -1 THEN 
				return
			ELSE
				// récupérer liste des services sélectionnés (un ou plusieurs)
				lstr_params = Message.PowerObjectParm
				FOR li_i = 1 TO upperbound(lstr_params.a_param)
					// lire le matricule correspondant au responsable du du service
					ls_codeservice = string(lstr_params.a_param[li_i])
					select matricule into :ls_matricule from service where codeservice = :ls_codeservice using ESQLCA;
					IF f_check_sql(ESQLCA) = 0 THEN
						IF li_i = 1 THEN
							ll_row = al_row
						ELSE
							ll_row = dw_prep.event ue_addrow()
							wf_initnewrow(ll_row)
						END IF
						this.uf_setdefaultvalue(ll_row, "prep_matricule", ls_matricule)
					END IF
				NEXT
			END IF
		ELSE
			open(w_l_agent)
			IF Message.DoubleParm = -1 THEN 
				return
			ELSE
				lstr_params = Message.PowerObjectParm
				this.uf_setdefaultvalue(al_row, "prep_matricule", string(lstr_params.a_param[1]))
			END IF
		END IF
END CHOOSE
end event

type dw_resp from uo_datawindow_singlerow within w_encadrement
integer y = 16
integer width = 2103
integer height = 96
integer taborder = 10
boolean bringtotop = true
string dataobject = "d_encadrement_resp"
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

event ue_itemvalidated;call super::ue_itemvalidated;dw_prep.retrieve(as_data)
dw_prep.enabled = TRUE
dw_resp.enabled = FALSE
dw_resp.uf_disabledata()
wf_actif(true)
parent.event ue_init_menu()

is_resp = as_data

wf_message("")
end event

event buttonclicked;call super::buttonclicked;string		ls_code
str_params	lstr_params

IF NOT IsValid(idwo_currentItem) THEN return

open(w_l_encadrement)
IF Message.DoubleParm = -1 THEN 
	return
ELSE
	lstr_params = Message.PowerObjectParm
	this.uf_setdefaultvalue(row, "s_resp", string(lstr_params.a_param[1]))
END IF
end event

type rb_service from uo_radiobutton within w_encadrement
integer x = 2286
integer y = 16
integer width = 293
boolean bringtotop = true
string text = "Service"
boolean checked = true
end type

type rb_agent from uo_radiobutton within w_encadrement
integer x = 2633
integer y = 16
integer width = 293
boolean bringtotop = true
string text = "Agent"
end type

type st_1 from uo_statictext within w_encadrement
integer x = 18
integer y = 112
integer width = 1170
boolean bringtotop = true
string text = "a accès aux données des agents suivants :"
end type

type cb_info from uo_cb within w_encadrement
integer x = 3456
integer width = 219
integer height = 96
integer taborder = 10
boolean bringtotop = true
integer textsize = -8
string text = "Info..."
end type

event clicked;call super::clicked;IF NOT IsValid(w_info) THEN
	OpenSheet(w_info, gw_mdiframe, 0, original!)
END IF
IF IsValid(w_info) THEN
	w_info.SetFocus()
	w_info.wf_loadText(is_info_title, is_info_filename)
END IF
end event

