//objectcomments Gestion des requêtes SQL stockées
forward
global type w_sqlreq from w_ancestor_dataentry
end type
type dw_sqlreq from uo_datawindow_singlerow within w_sqlreq
end type
end forward

global type w_sqlreq from w_ancestor_dataentry
integer width = 3241
integer height = 1772
string title = "Requêtes stockées"
boolean maxbox = true
boolean resizable = true
dw_sqlreq dw_sqlreq
end type
global w_sqlreq w_sqlreq

type variables
integer	ii_id


end variables

on w_sqlreq.create
int iCurrent
call super::create
this.dw_sqlreq=create dw_sqlreq
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_sqlreq
end on

on w_sqlreq.destroy
call super::destroy
destroy(this.dw_sqlreq)
end on

event ue_init_menu;call super::ue_init_menu;IF wf_IsActif() THEN
	IF dw_sqlreq.uf_isrecordnew() THEN
		f_menuaction({"m_enregistrer", "m_abandonner", "m_fermer"})
	ELSE
		f_menuaction({"m_enregistrer", "m_abandonner", "m_supprimer", "m_fermer"})
	END IF
ELSE
	f_menuaction({"m_abandonner", "m_fermer"})
END IF

end event

event ue_init_win;call super::ue_init_win;this.setredraw(FALSE)

dw_sqlreq.uf_reset()
dw_sqlreq.insertrow(0)
dw_sqlreq.uf_disabledata()
dw_sqlreq.uf_enablekeys()
dw_sqlreq.setfocus()

this.setredraw(TRUE)
end event

event ue_enregistrer;call super::ue_enregistrer;integer	li_status

// contrôle de validité de tous les champs
IF dw_sqlreq.event ue_checkall() < 0 THEN
	dw_sqlreq.SetFocus()
	return(-1)
END IF

li_status = gu_dwservices.uf_updatetransact(dw_sqlreq)
CHOOSE CASE li_status
	CASE 1
		wf_message("Requête " + string(ii_id) + " enregistrée avec succès")
		This.event ue_init_win()
		return(1)
	CASE -1
		populateerror(20000,"")
		gu_message.uf_unexp("SQLREQ : Erreur lors de la mise à jour de la base de données")
		return(-1)
END CHOOSE

end event

event ue_supprimer;call super::ue_supprimer;long	ll_count, ll_row

CHOOSE CASE wf_GetActivecontrolname()
	CASE "dw_sqlreq"
		if f_confirm_del("Voulez-vous supprimer cette requête ?") = 1 THEN
			IF dw_sqlreq.event ue_delete() = 1 THEN
				wf_message("requête supprimée avec succès")
				this.event ue_init_win()
			END IF
		END IF

	CASE ELSE
		gu_message.uf_info("Veuillez d'abord placer le curseur sur l'entité à supprimer")
END CHOOSE












end event

event ue_open;call super::ue_open;wf_SetDWList({dw_sqlreq})

end event

event resize;call super::resize;dw_sqlreq.height = wf_getWSheight() - dw_sqlreq.y
dw_sqlreq.width = wf_getWSwidth() 

dw_sqlreq.object.datawindow.detail.height = dw_sqlreq.height
dw_sqlreq.object.sql.height = long(dw_sqlreq.object.datawindow.detail.height) - 392
dw_sqlreq.object.sql.width = dw_sqlreq.width - 55
dw_sqlreq.object.gb_1.width = dw_sqlreq.object.sql.width
end event

type ddlb_message from w_ancestor_dataentry`ddlb_message within w_sqlreq
integer y = 1568
integer width = 2267
end type

type dw_sqlreq from uo_datawindow_singlerow within w_sqlreq
integer width = 3200
integer height = 1552
integer taborder = 10
boolean bringtotop = true
string dataobject = "d_sqlreq"
boolean livescroll = false
borderstyle borderstyle = stylebox!
end type

event ue_leavekey;call super::ue_leavekey;// quand on quitte la clé, cela veut dire qu'on dispose de données actives dans la fenêtre
wf_actif(true)

// effacer les messages
ddlb_message.reset()

// disabler la clé et enabler les datas
this.setredraw(FALSE)
this.uf_enabledata()
this.uf_disablekeys()
this.setredraw(TRUE)

// lecture du record si la requête existe déjà
IF NOT this.uf_IsRecordNew() THEN
	wf_message("Modification d'une requête...")
	this.retrieve(ii_id)
ELSE
// nouvelle requête : on dispose déjà d'un record vide (celui où on a introduit la clé)
	wf_message("Nouvelle requête...")
END IF

parent.event ue_init_menu()

end event

event ue_checkitem;call super::ue_checkitem;integer	li_status
long		ll_count

CHOOSE CASE as_item
	// dernier élément de la clé, vérifier si record existe ou pas
	CASE "id"
		ii_id = integer(as_data)
		select count(*) into :ll_count from sqlreq where id = :ii_id using ESQLCA;
		li_status = f_check_sql(ESQLCA)
		IF li_status < 0 OR ll_count > 1 THEN
			populateerror(20000,"")
			gu_message.uf_unexp("Erreur SELECT SQLREQ")
			return(-1)
		ELSE
			// requête inexistante...
			IF ll_count = 0 THEN
				this.uf_NewRecord(TRUE)
				return(1)
			ELSE
			// requête existe déjà
				this.uf_NewRecord(FALSE)
				return(1)
			END IF
		END IF
	CASE "appl"
		IF f_isEmptyString(as_data) THEN
			as_message = "Veuillez préciser l'application"
			return(-1)
		END IF
	CASE "intitule"
		IF f_isEmptyString(as_data) THEN
			as_message = "Veuillez introduire un intitulé"
			return(-1)
		END IF
	CASE "critere"
		IF f_isEmptyString(as_data) THEN
			as_message = "Veuillez spécifier les critères applicables"
			return(-1)
		END IF
	CASE "sql"
		IF f_isEmptyString(as_data) THEN
			as_message = "Veuillez introduire une requête SQL"
			return(-1)
		END IF
END CHOOSE
return(1)

end event

event ue_help;call super::ue_help;str_params lstr_params

CHOOSE CASE idwo_currentItem.name
	CASE "id"
		IF wf_IsActif() THEN return
		open(w_l_sqlreq)
		IF Message.DoubleParm = -1 THEN return
		lstr_params=Message.PowerObjectParm
		this.SetText(string (lstr_params.a_param[1]))
		f_presskey("tab")
END CHOOSE

end event

