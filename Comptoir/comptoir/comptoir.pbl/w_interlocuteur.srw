//objectcomments Encodage des interlocuteurs
forward
global type w_interlocuteur from w_ancestor_dataentry
end type
type dw_locu from uo_datawindow_singlerow within w_interlocuteur
end type
end forward

global type w_interlocuteur from w_ancestor_dataentry
integer width = 2034
integer height = 1792
string title = "Interlocuteurs"
dw_locu dw_locu
end type
global w_interlocuteur w_interlocuteur

type variables
string	is_locu
boolean	ib_autocp
br_interlocuteur	ibr_interlocuteur
end variables

on w_interlocuteur.create
int iCurrent
call super::create
this.dw_locu=create dw_locu
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_locu
end on

on w_interlocuteur.destroy
call super::destroy
destroy(this.dw_locu)
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
	
	IF NOT dw_locu.uf_IsRecordNew() AND wf_canDelete() THEN
		li_item++
		ls_menu[li_item] = "m_supprimer"
	END IF
END IF

f_menuaction(ls_menu)
end event

event ue_init_win;call super::ue_init_win;ib_autocp = FALSE
SetNull(is_locu)
this.setredraw(FALSE)

dw_locu.uf_reset()
dw_locu.insertrow(0)

dw_locu.uf_disabledata()
dw_locu.uf_enablekeys()
dw_locu.Setcolumn("locu")
dw_locu.setfocus()

this.setredraw(TRUE)
end event

event ue_enregistrer;call super::ue_enregistrer;integer	li_status

// contrôle de validité de tous les champs
IF dw_locu.event ue_checkall() < 0 THEN
	dw_locu.SetFocus()
	return(-1)
END IF

li_status = gu_dwservices.uf_updatetransact(dw_locu)
CHOOSE CASE li_status
	CASE 1
		wf_message("Interlocuteur " + is_locu + " enregistré avec succès")
		This.event ue_init_win()
		return(1)
	CASE -1
		populateerror(20000,"")
		gu_message.uf_unexp("INTERLOCUTEUR : Erreur lors de la mise à jour de la base de données")
		return(-1)
END CHOOSE

end event

event ue_supprimer;call super::ue_supprimer;string	ls_message

IF ibr_interlocuteur.uf_check_beforedelete(dw_locu.object.locu[1], ls_message) = -1 THEN
	gu_message.uf_info(ls_message)
	return
END IF

IF f_confirm_del("Voulez-vous supprimer cet interlocuteur ?") = 1 THEN
	IF dw_locu.event ue_delete() = 1 THEN
		wf_message("Interlocuteur supprimé avec succès")
		this.event ue_init_win()
	END IF
END IF

end event

event ue_close;call super::ue_close;DESTROY ibr_interlocuteur

end event

event ue_open;call super::ue_open;//datawindowchild	ldwc_dropdown
//long	ll_row

ibr_interlocuteur = CREATE br_interlocuteur

wf_SetDWList({dw_locu})

//// ajouter le code 'Non précisé' à la liste des pays
//dw_locu.GetChild("pays", ldwc_dropdown)
//ldwc_dropdown.settransobject(sqlca)
//ldwc_dropdown.retrieve()
//ll_row = ldwc_dropdown.insertrow(0)
//ldwc_dropdown.setitem(ll_row, "code", "")
//ldwc_dropdown.setitem(ll_row, "trad", "   Non précisé")
//ldwc_dropdown.setitem(ll_row, "ordre", 0)
//ldwc_dropdown.sort()
//// sélectionner par défaut 'Non précisé'
//dw_locu.uf_setdefaultvalue(1, "pays", "")
end event

type ddlb_message from w_ancestor_dataentry`ddlb_message within w_interlocuteur
integer y = 1616
integer width = 1719
end type

type dw_locu from uo_datawindow_singlerow within w_interlocuteur
integer y = 16
integer width = 2011
integer height = 1584
integer taborder = 10
boolean bringtotop = true
string dataobject = "d_interlocuteur"
boolean livescroll = false
end type

event ue_leavekey;call super::ue_leavekey;// quand on quitte la clé, cela veut dire qu'on dispose de données actives dans la fenêtre
wf_actif(true)

// effacer les messages
ddlb_message.reset()

// disabler la clé et enabler les datas (si elles sont modifiables)
this.setredraw(FALSE)
this.uf_enabledata()
this.uf_disablekeys()
this.setredraw(TRUE)

// lecture du record si existe déjà
IF NOT this.uf_IsRecordNew() THEN
	wf_message("Modification d'un interlocuteur...")
	this.retrieve(is_locu)
ELSE
// nouveau record : on dispose déjà d'un record vide (celui où on a introduit la clé)
	this.object.pays[1] = "BE"
	this.object.montantrf[1] = 0
	this.object.montantrf2[1] = 0
	wf_message("Nouvel interlocuteur...")
END IF

parent.event ue_init_menu()

end event

event ue_checkitem;call super::ue_checkitem;integer	li_status
long		ll_count

CHOOSE CASE as_item
	// dernier élément de la clé, vérifier si record existe ou pas
	CASE "locu"
		IF ibr_interlocuteur.uf_check_locu(as_data, as_message) = -1 THEN
			return(-1)
		END IF
		is_locu = as_data
		select count(*) into :ll_count from interlocuteur
				where locu=:is_locu using ESQLCA;
		li_status = f_check_sql(ESQLCA)
		IF li_status < 0 OR ll_count > 1 THEN
			populateerror(20000,"")
			gu_message.uf_unexp("Erreur SELECT INTERLOCUTEUR")
			return(-1)
		ELSE
			// interlocuteur inexistant...
			IF ll_count = 0 THEN
				// ...et on peut modifier les données...
				IF wf_canUpdate() THEN
					this.uf_NewRecord(TRUE)
				ELSE
				// ...et on ne peut pas modifier les données
					as_message = "Interlocuteur inexistant. Vous n'avez pas le droit d'en ajouter..."
					return(-1)
				END IF
			ELSE
			// interlocuteur existe déjà : OK
				this.uf_NewRecord(FALSE)
				return(1)
			END IF
		END IF
		
	CASE "type"
		return(ibr_interlocuteur.uf_check_type(as_data, as_message))
		
	CASE "client"
		return(ibr_interlocuteur.uf_check_client(as_data, as_message))
		
	CASE "tvarn"
		return(ibr_interlocuteur.uf_check_tvarn(as_data, as_message))
		
	CASE "refrrw"
		return(ibr_interlocuteur.uf_check_refrrw(as_data, as_message))
		
	CASE "interlocuteur"
		return(ibr_interlocuteur.uf_check_interlocuteur(as_data, as_message))
		
	CASE "pays"
		return(ibr_interlocuteur.uf_check_pays(as_data, as_message))
END CHOOSE
return(1)

end event

event ue_help;call super::ue_help;str_params	lstr_params
integer		li_id, li_cp
string		ls_loc

CHOOSE CASE idwo_currentItem.name
	CASE "locu"
		IF wf_IsActif() THEN return 
		open(w_l_locu)
		IF Message.DoubleParm = -1 THEN 
			return
		ELSE
			lstr_params=Message.PowerObjectParm
			this.uf_SetDefaultValue(1, "locu", f_string(lstr_params.a_param[1]))
		END IF
	CASE "cpost"
		open(w_l_loc)
		IF Message.DoubleParm = -1 THEN 
			return
		ELSE
			lstr_params=Message.PowerObjectParm
			li_id = integer(lstr_params.a_param[1])
			select cploc, localite into :li_cp, :ls_loc from localite where id = :li_id using ESQLCA;
			IF f_check_sql(ESQLCA) <> 0 THEN
				return
			END IF
			this.uf_SetDefaultValue(1, "localite", ls_loc)
			ib_autocp = TRUE
			this.SetText(f_string(li_cp))
			f_presskey("tab")
		END IF
	CASE "localite"
		lstr_params.a_param[1] = This.object.cpost[1]
		lstr_params.a_param[2] = FALSE
		openwithparm(w_l_loc, lstr_params)
		IF Message.DoubleParm = -1 THEN 
			return
		ELSE
			lstr_params=Message.PowerObjectParm
			li_id = integer(lstr_params.a_param[1])
			select cploc, localite into :li_cp, :ls_loc from localite where id = :li_id using ESQLCA;
			IF f_check_sql(ESQLCA) <> 0 THEN
				return
			END IF
			this.uf_SetDefaultValue(1, "cpost", f_string(li_cp))
			this.SetText(ls_loc)
			f_presskey("tab")
		END IF
END CHOOSE


end event

event ue_postitemvalidated;call super::ue_postitemvalidated;str_params	lstr_params
integer		li_id, li_cp
string		ls_loc

IF NOT wf_isactif() THEN return

CHOOSE CASE as_name
	// si on a changé le code postal manuellement, afficher liste des localités possibles
	// (pas si on a changé le CP en faisant F1 car dans ce cas la localité est choisie simultanément)
	CASE "cpost"
		IF ib_autocp THEN 
			ib_autocp = FALSE
			return
		END IF
		IF NOT IsNumber(this.object.cpost[1]) THEN return
		IF long(this.object.cpost[1]) > 9999 THEN return
		lstr_params.a_param[1] = this.object.cpost[1]
		lstr_params.a_param[2] = FALSE
		openwithparm(w_l_loc, lstr_params)
		IF Message.DoubleParm = -1 THEN 
			return
		ELSE
			lstr_params=Message.PowerObjectParm
			li_id = integer(lstr_params.a_param[1])
			select cploc, localite into :li_cp, :ls_loc from localite where id = :li_id using ESQLCA;
			IF f_check_sql(ESQLCA) <> 0 THEN
				return
			END IF
			this.object.cpost[1] = f_string(li_cp)
			this.SetColumn("localite")
			this.SetText(ls_loc)
			f_presskey("TAB")
		END IF
END CHOOSE

end event

event ue_itemvalidated;call super::ue_itemvalidated;CHOOSE CASE as_name
	CASE "client"
		// annuler montant, n° TVA/RN et n° RRW pour les interlocuteurs qui ne sont pas des clients
		IF as_data="N" THEN
			this.object.montantrf[1] = 0
			this.object.montantrf2[1] = 0
			this.object.tvarn[1] = gu_c.s_null
			this.object.refrrw[1] = gu_c.s_null
		END IF
END CHOOSE
end event

