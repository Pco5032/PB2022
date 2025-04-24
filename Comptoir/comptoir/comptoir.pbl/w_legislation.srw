//objectcomments Encodage des textes législatifs
forward
global type w_legislation from w_ancestor_dataentry
end type
type dw_leg from uo_datawindow_singlerow within w_legislation
end type
end forward

global type w_legislation from w_ancestor_dataentry
integer width = 3049
integer height = 840
string title = "Textes législatifs"
dw_leg dw_leg
end type
global w_legislation w_legislation

type variables
string	is_leg
br_legislation	ibr_legislation
end variables

on w_legislation.create
int iCurrent
call super::create
this.dw_leg=create dw_leg
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_leg
end on

on w_legislation.destroy
call super::destroy
destroy(this.dw_leg)
end on

event ue_init_menu;call super::ue_init_menu;string	ls_menu[]
integer	li_item

li_item = 1
ls_menu[li_item] = "m_fermer"

IF wf_IsActif() THEN
	li_item++
	ls_menu[li_item] = "m_abandonner"
	IF wf_canUpdate() THEN
		li_item++
		ls_menu[li_item] = "m_enregistrer"
	END IF
	IF NOT dw_leg.uf_IsRecordNew() AND wf_canDelete() THEN
		li_item++
		ls_menu[li_item] = "m_supprimer"
	END IF
END IF

f_menuaction(ls_menu)

end event

event ue_init_win;call super::ue_init_win;setNull(is_leg)

dw_leg.uf_reset()
dw_leg.insertrow(0)

dw_leg.uf_disabledata()
dw_leg.uf_enablekeys()
dw_leg.Setcolumn("code_leg")
dw_leg.setfocus()

end event

event ue_supprimer;call super::ue_supprimer;string	ls_message

IF ibr_legislation.uf_check_beforedelete(dw_leg.object.texte[1], ls_message) = -1 THEN
	gu_message.uf_info(ls_message)
	return
END IF

IF f_confirm_del("Voulez-vous supprimer ce texte ?") = 1 THEN
	IF dw_leg.event ue_delete() = 1 THEN
		wf_message("Texte supprimé avec succès")
		this.event ue_init_win()
	END IF
END IF

end event

event ue_enregistrer;call super::ue_enregistrer;integer	li_status

// contrôle de validité de tous les champs
IF dw_leg.event ue_checkall() < 0 THEN
	dw_leg.SetFocus()
	return(-1)
END IF

li_status = gu_dwservices.uf_updatetransact(dw_leg)
CHOOSE CASE li_status
	CASE 1
		wf_message("Texte " + is_leg + " enregistré avec succès")
		This.event ue_init_win()
		return(1)
	CASE -1
		populateerror(20000,"")
		gu_message.uf_unexp("LEGISLATION : Erreur lors de la mise à jour de la base de données")
		return(-1)
END CHOOSE

end event

event ue_open;call super::ue_open;ibr_legislation = CREATE br_legislation
end event

event ue_close;call super::ue_close;DESTROY ibr_legislation
end event

type ddlb_message from w_ancestor_dataentry`ddlb_message within w_legislation
integer y = 656
end type

type dw_leg from uo_datawindow_singlerow within w_legislation
integer x = 18
integer y = 16
integer width = 3017
integer height = 640
integer taborder = 10
boolean bringtotop = true
string dataobject = "d_legislation"
end type

event ue_checkitem;call super::ue_checkitem;integer	li_status
long		ll_count

CHOOSE CASE as_item
	// dernier élément de la clé, vérifier si record existe ou pas
	CASE "code_leg"
		IF ibr_legislation.uf_check_code(as_data, as_message) = -1 THEN
			return(-1)
		END IF
		select count(*) into :ll_count from legislation
				where code_leg=:as_data using ESQLCA;
		li_status = f_check_sql(ESQLCA)
		IF li_status < 0 OR ll_count > 1 THEN
			populateerror(20000,"")
			gu_message.uf_unexp("Erreur SELECT LEGISLATION")
			return(-1)
		ELSE
			is_leg = as_data
			// texte inexistant...
			IF ll_count = 0 THEN
				// ... et on peut modifier le fichier
				IF wf_canUpdate() THEN
					this.uf_NewRecord(TRUE)
				ELSE
				// ... et on ne peut pas modifier le fichier
					as_message = "Texte inexistant. Vous n'avez pas le droit d'en ajouter..."
					return(-1)
				END IF
			ELSE
			// texte existe déjà
				this.uf_NewRecord(FALSE)
				return(1)
			END IF
		END IF
		
	CASE "texte"
		return(ibr_legislation.uf_check_texte(as_data, as_message))
END CHOOSE

return(1)

end event

event ue_leavekey;call super::ue_leavekey;// quand on quitte la clé, cela veut dire qu'on dispose de données actives dans la fenêtre
wf_actif(true)

// effacer les messages
ddlb_message.reset()

// disabler la clé et enabler les datas
this.uf_enabledata()
this.uf_disablekeys()

// lecture du record si existe déjà
IF NOT this.uf_IsRecordNew() THEN
	wf_message("Modification d'un texte...")
	this.retrieve(is_leg)
ELSE
// nouveau record : on dispose déjà d'un record vide (celui où on a introduit la clé)
	wf_message("Nouveau texte...")
END IF

parent.event ue_init_menu()

end event

event ue_help;call super::ue_help;str_params	lstr_params

CHOOSE CASE idwo_currentItem.name
	CASE "code_leg"
		IF wf_IsActif() THEN return 
		open(w_l_legislation)
		IF Message.DoubleParm = -1 THEN 
			return
		ELSE
			lstr_params=Message.PowerObjectParm
			this.uf_SetDefaultValue(1, "code_leg", f_string(lstr_params.a_param[1]))
		END IF
END CHOOSE
end event

