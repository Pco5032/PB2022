//objectcomments Sélection des agents d'encadrement par préposé
forward
global type w_encadrement_inv from w_ancestor_dataentry
end type
type dw_resp from uo_datawindow_multiplerow within w_encadrement_inv
end type
type dw_prep from uo_datawindow_singlerow within w_encadrement_inv
end type
type st_1 from uo_statictext within w_encadrement_inv
end type
type cb_info from uo_cb within w_encadrement_inv
end type
end forward

global type w_encadrement_inv from w_ancestor_dataentry
integer width = 4425
integer height = 2264
string title = "Sélection des agents qui ont accès aux données d~'un autre"
boolean maxbox = true
boolean resizable = true
dw_resp dw_resp
dw_prep dw_prep
st_1 st_1
cb_info cb_info
end type
global w_encadrement_inv w_encadrement_inv

type variables
string	is_prep, is_prep_codeservice, is_info_filename, is_info_title
uo_ds		ids_resp

end variables

forward prototypes
public subroutine wf_initnewrow (long al_row, string as_matricule, string as_role)
end prototypes

public subroutine wf_initnewrow (long al_row, string as_matricule, string as_role);IF al_row <= 0 THEN return
dw_resp.object.prep_matricule[al_row] = is_prep
dw_resp.object.consult_planning[al_row] = "O"
dw_resp.object.modif_planning[al_row] = "O"
dw_resp.object.consult_realise[al_row] = "O"
dw_resp.object.modif_realise[al_row] = "O"

IF NOT f_isEmptyString(as_matricule) THEN
	dw_resp.uf_setdefaultvalue(al_row, "resp_matricule", as_matricule)
END IF

IF NOT f_isEmptyString(as_role) THEN
	dw_resp.uf_setdefaultvalue(al_row, "c_role", as_role)
END IF
end subroutine

on w_encadrement_inv.create
int iCurrent
call super::create
this.dw_resp=create dw_resp
this.dw_prep=create dw_prep
this.st_1=create st_1
this.cb_info=create cb_info
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_resp
this.Control[iCurrent+2]=this.dw_prep
this.Control[iCurrent+3]=this.st_1
this.Control[iCurrent+4]=this.cb_info
end on

on w_encadrement_inv.destroy
call super::destroy
destroy(this.dw_resp)
destroy(this.dw_prep)
destroy(this.st_1)
destroy(this.cb_info)
end on

event resize;call super::resize;cb_info.x = newwidth - cb_info.width
dw_resp.width = newwidth
dw_resp.height = newheight - 100 - dw_resp.y
end event

event ue_open;call super::ue_open;is_info_title = "Droits d'accès officiels"
is_info_filename = gs_cenpath + "\DroitsSTD.txt"

ids_resp = CREATE uo_ds
ids_resp.dataobject = "ds_responsable"
ids_resp.setTransobject(SQLCA)

// icône "ajouter" doit être visible dans le menu
wf_SetItemsToShow({"m_ajouter"})

// initialiser liste des DW modifiables
wf_SetDWList({dw_resp})

// divers settings des DW
dw_resp.uf_checkallrow(TRUE)
dw_resp.uf_sort(TRUE)
dw_resp.uf_createwhenlastdeleted(FALSE)

end event

event ue_supprimer;call super::ue_supprimer;string	ls_matricule, ls_message

IF dw_resp.GetRow() = 0 THEN return

ls_matricule = dw_resp.object.resp_matricule[dw_resp.GetRow()]

IF f_confirm_del("Voulez-vous supprimer l'agent " + f_string(ls_matricule) + " ?") = 1 THEN
	dw_resp.event ue_delete()
END IF

end event

event ue_init_menu;call super::ue_init_menu;IF wf_isactif() THEN
	f_menuaction({"m_enregistrer", "m_ajouter", "m_supprimer", "m_abandonner", "m_fermer"})
ELSE
	f_menuaction({"m_fermer"})
END IF



end event

event ue_enregistrer;call super::ue_enregistrer;// contrôle de validité de tous les champs
IF dw_resp.event ue_checkall() < 0 THEN
	dw_resp.SetFocus()
	return(-1)
END IF

IF dw_resp.event ue_update() = 1 THEN
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

ll_row = dw_resp.event ue_addrow()
IF ll_row > 0 THEN wf_initnewrow(ll_row, "", "")
end event

event ue_init_win;call super::ue_init_win;is_prep = ""
is_prep_codeservice = ""

dw_prep.uf_reset()
dw_resp.uf_reset()
dw_resp.enabled = FALSE
dw_prep.enabled = TRUE
dw_prep.uf_enabledata()
dw_prep.object.t_nom.text = ""
dw_prep.object.t_codeservice.text = ""

dw_prep.insertRow(0)
dw_prep.SetFocus()

end event

event ue_close;call super::ue_close;DESTROY ids_resp
end event

type ddlb_message from w_ancestor_dataentry`ddlb_message within w_encadrement_inv
integer y = 1936
end type

type dw_resp from uo_datawindow_multiplerow within w_encadrement_inv
integer y = 192
integer width = 4389
integer height = 1600
integer taborder = 10
boolean bringtotop = true
string dataobject = "d_encadrement_inv"
boolean hscrollbar = true
boolean vscrollbar = true
end type

event ue_checkitem;call super::ue_checkitem;string	ls_nom, ls_codeservice, ls_service, ls_grade, ls_role
integer	li_st
long		ll_row

CHOOSE CASE as_item
	CASE "resp_matricule"
		// s'assurer de l'unicité du matricule
		IF dw_resp.find("resp_matricule='" + as_data +"' and getrow()<>" + string(al_row), 1, dw_resp.RowCount()) > 0 THEN
			as_message = "Cet agent figure déjà dans la liste"
			return(-1)
		END IF
		
		// Vérifier existence et lire infos sur l'agent.
		// Si le matricule de l'agent est le même que le matricule dans son SERVICE, c'est qu'il en est le responsable.
		// Utiliser alors le titre du responsable dans ce service en guise de rôle.
		select a.nom, a.grade, a.codeservice, s.service, decode(a.matricule, s.matricule, s.titre, '') c_role
				into :ls_nom, :ls_grade, :ls_codeservice, :ls_service, :ls_role
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
				this.object.c_role[al_row] = ls_role
				// si l'agent est un responsable connu dans le service, lire son rôle et l'afficher
				ll_row = ids_resp.find("matricule='" + as_data + "'", 1, dw_resp.rowCount())
				IF ll_row > 0 THEN
					this.object.c_role[al_row] = string(ids_resp.object.role[ll_row])
				END IF
				
				return(1)
		END CHOOSE				
END CHOOSE
return(1)

end event

event ue_help;call super::ue_help;str_params	lstr_params

IF al_row = 0 THEN return
IF NOT IsValid(idwo_currentItem) THEN return
CHOOSE CASE idwo_currentItem.name
	CASE "resp_matricule"
		open(w_l_agent)
		IF Message.DoubleParm = -1 THEN 
			return
		ELSE
			lstr_params = Message.PowerObjectParm
			this.uf_setdefaultvalue(al_row, "resp_matricule", string(lstr_params.a_param[1]))
		END IF
END CHOOSE
end event

type dw_prep from uo_datawindow_singlerow within w_encadrement_inv
integer y = 16
integer width = 3419
integer height = 96
integer taborder = 10
boolean bringtotop = true
string dataobject = "d_encadrement_inv_prep"
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

select nom, codeservice into :ls_nom, :is_prep_codeservice 
	from agent where matricule=:as_data using ESQLCA;
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
		this.object.t_codeservice.text = is_prep_codeservice
		return(1)
END CHOOSE
end event

event ue_itemvalidated;call super::ue_itemvalidated;string	ls_matricule, ls_role
long		ll_rowresp, ll_row

is_prep = as_data
dw_resp.enabled = TRUE
dw_prep.enabled = FALSE
dw_prep.uf_disabledata()
wf_actif(true)

// lecture des agents concernés par le service du préposé (responsables connus)
ids_resp.retrieve(is_prep_codeservice)

// Lecture des responsables de ce préposé.
// S'il n'y en n'a pas encore, on ajoute d'office ceux qui sont connus du système :
//		- chef de cantonnement
//		- directeur
//		- CP
//		- C1
IF dw_resp.retrieve(as_data) = 0 THEN
	wf_message("Configuration d'un nouvel agent : ajout automatique des responsables connus")
	FOR ll_rowresp = 1 TO ids_resp.rowCount()
		ls_matricule = string(ids_resp.object.matricule[ll_rowresp])
		ls_role = string(ids_resp.object.role[ll_rowresp])
		ll_row = dw_resp.event ue_addrow()
		wf_initnewrow(ll_row, ls_matricule, ls_role)
	NEXT
ELSE
	// configuration existante : relire et afficher le rôle de chaque agent ayant accès aux données
	FOR ll_rowresp = 1 TO dw_resp.rowCount()
		// si l'agent est un responsable connu dans le service de l'agent, lire son rôle et l'afficher
		ls_matricule = string(dw_resp.object.resp_matricule[ll_rowresp])
		ll_row = ids_resp.find("matricule='" + ls_matricule + "'", 1, dw_resp.rowCount())
		IF ll_row > 0 THEN
			ls_role = string(ids_resp.object.role[ll_row])
		ELSE
			// Si pas trouvé et que le matricule du responsable est le même que le matricule dans SERVICE,
			// utiliser le titre du responsable dans ce service en guise de rôle
			// (voir 'calcul' du titre dans la requête du DW : decode(agent.matricule,service.matricule,service.titre,'') c_titre
			// Autre cas : ne pas afficher de rôle particulier
			ls_role = f_string(dw_resp.object.c_titre[ll_rowresp])
		END IF
		dw_resp.object.c_role[ll_rowresp] = ls_role
		dw_resp.setItemstatus(ll_rowresp, "c_role", Primary!, notmodified!)
	NEXT
	wf_message("Configuration existante")
END IF

parent.event ue_init_menu()


end event

event buttonclicked;call super::buttonclicked;string		ls_code
str_params	lstr_params

IF NOT IsValid(idwo_currentItem) THEN return

open(w_l_encadrement_inv)
IF Message.DoubleParm = -1 THEN 
	return
ELSE
	lstr_params = Message.PowerObjectParm
	this.uf_setdefaultvalue(row, "s_prep", string(lstr_params.a_param[1]))
END IF
end event

type st_1 from uo_statictext within w_encadrement_inv
integer x = 18
integer y = 112
integer width = 1152
boolean bringtotop = true
string text = "sont accessibles par les agents suivants :"
end type

type cb_info from uo_cb within w_encadrement_inv
integer x = 3456
integer width = 219
integer height = 96
integer taborder = 20
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

