//objectcomments Encodage des espèces
forward
global type w_espece from w_ancestor_dataentry
end type
type dw_1 from uo_datawindow_singlerow within w_espece
end type
end forward

global type w_espece from w_ancestor_dataentry
integer width = 2999
integer height = 1860
string title = "Espèces"
dw_1 dw_1
end type
global w_espece w_espece

type variables
br_espece	ibr_espece
string		is_codesp
end variables

forward prototypes
public function integer wf_init ()
end prototypes

public function integer wf_init ();string	ls_nom, ls_spdnf

IF dw_1.uf_IsRecordNew() THEN
	// valeurs par défaut pour nouveau record
	dw_1.object.passphyto[1] = "N"
	dw_1.object.type_qte[1] = "C"
	dw_1.object.lim_pu1[1] = 0
	dw_1.object.lim_pu2[1] = 0
	dw_1.object.lim_pu3[1] = 0
	dw_1.object.unit_pu1[1] = 0
	dw_1.object.unit_pu2[1] = 0
	dw_1.object.unit_pu3[1] = 0
ELSE
	// lecture des traductions pour record existant
	ls_spdnf = dw_1.object.sp_dnf[1]
	select esnom into :ls_nom from codesp where sp = :ls_spdnf using ESQLCA;
	IF f_check_sql(ESQLCA) = 0 THEN
		dw_1.object.c_spdnf[1] = ls_nom
	END IF
END IF

dw_1.SetItemStatus(1,0,Primary!,NotModified!)

// disabler la clé et enabler les datas
dw_1.uf_enabledata()
dw_1.uf_disablekeys()

dw_1.SetColumn("nom_fr")

return(1)
end function

on w_espece.create
int iCurrent
call super::create
this.dw_1=create dw_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_1
end on

on w_espece.destroy
call super::destroy
destroy(this.dw_1)
end on

event ue_open;call super::ue_open;ibr_espece = CREATE br_espece

// initialiser liste des DW modifiables
wf_SetDWList({dw_1})

dw_1.SetFocus()

end event

event ue_close;call super::ue_close;DESTROY ibr_espece
end event

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

	IF NOT dw_1.uf_IsRecordNew() AND wf_canDelete() THEN
		li_item++
		ls_menu[li_item] = "m_supprimer"
	END IF
END IF

f_menuaction(ls_menu)


end event

event ue_init_win;call super::ue_init_win;SetNull(is_codesp)

this.setredraw(FALSE)

dw_1.uf_reset()
dw_1.insertrow(0)

dw_1.uf_disabledata()
dw_1.uf_enablekeys()
dw_1.Setcolumn("code_sp")
dw_1.setfocus()

this.setredraw(TRUE)
end event

event ue_enregistrer;call super::ue_enregistrer;integer	li_status

// contrôle de validité de tous les champs
IF dw_1.event ue_checkall() < 0 THEN
	dw_1.SetFocus()
	return(-1)
END IF

li_status = gu_dwservices.uf_updatetransact(dw_1)
CHOOSE CASE li_status
	CASE 1
		wf_message("Espèce " + is_codesp + " enregistrée avec succès")
		This.event ue_init_win()
		return(1)
	CASE -1
		populateerror(20000,"")
		gu_message.uf_unexp("ESPECE : Erreur lors de la mise à jour de la base de données")
		return(-1)
END CHOOSE

end event

event ue_supprimer;call super::ue_supprimer;string	ls_message

IF ibr_espece.uf_check_beforedelete(is_codesp, ls_message) = -1 THEN
	gu_message.uf_info(ls_message)
	return
END IF

IF f_confirm_del("Voulez-vous supprimer cette espèce ?") = 1 THEN
	IF dw_1.event ue_delete() = 1 THEN
		wf_message("Espèce supprimée avec succès")
		this.event ue_init_win()
	END IF
END IF

end event

type ddlb_message from w_ancestor_dataentry`ddlb_message within w_espece
integer x = 18
integer y = 1680
integer width = 2103
end type

type dw_1 from uo_datawindow_singlerow within w_espece
integer width = 2981
integer height = 1680
integer taborder = 11
boolean bringtotop = true
string dataobject = "d_espece"
end type

event ue_help;call super::ue_help;str_params	lstr_params

CHOOSE CASE idwo_currentItem.name
	CASE "code_sp"
		open(w_l_espece)
		IF Message.DoubleParm = -1 THEN 
			return
		ELSE
			lstr_params=Message.PowerObjectParm
			this.SetText(string(lstr_params.a_param[1]))
			f_presskey("tab")
		END IF
		
	CASE "sp_dnf"
		open(w_l_codesp)
		IF Message.DoubleParm = -1 THEN 
			return
		ELSE
			lstr_params=Message.PowerObjectParm
			this.uf_SetDefaultValue(al_row, "sp_dnf", f_string(lstr_params.a_param[1]))
		END IF
END CHOOSE
end event

event ue_checkitem;call super::ue_checkitem;integer	li_status
long		ll_count

CHOOSE CASE as_item
	CASE "code_sp"
		IF ibr_espece.uf_check_code(as_data, as_message) = -1 THEN
			return(-1)
		ELSE
			is_codesp = as_data
		END IF
		// dernier élément de la clé, vérifier si record existe ou pas		
		select count(*) into :ll_count from espece
				where code_sp = :is_codesp using ESQLCA;
		li_status = f_check_sql(ESQLCA)
		IF li_status < 0 OR ll_count > 1 THEN
			populateerror(20000,"")
			gu_message.uf_unexp("Erreur SELECT ESPECE")
			return(-1)
		ELSE
			// espèce inexistante...
			IF ll_count = 0 THEN
				// ...et on peut modifier les données...
				IF wf_canUpdate() THEN
					this.uf_NewRecord(TRUE)
					return(1)
				ELSE
				// ...et on ne peut pas modifier les données
					as_message = "Espèce inexistante. Vous n'avez pas le droit d'en créer..."
					return(-1)
				END IF
			ELSE
			// espèce existe déjà : OK
				this.uf_NewRecord(FALSE)
				return(1)
			END IF
		END IF

	CASE "nom_fr"
		return(ibr_espece.uf_check_nomfr(as_data, as_message))
		
	CASE "nom_lat"
		return(ibr_espece.uf_check_nomlat(as_data, as_message))
		
	CASE "genre"
		return(ibr_espece.uf_check_genre(as_data, as_message))
		
	CASE "sp_dnf"
		IF ibr_espece.uf_check_spdnf(as_data, as_message) = -1 THEN
			return(-1)
		ELSE
			this.object.c_spdnf[al_row] = as_message
			return(1)
		END IF
	
	CASE "passphyto"
		return(ibr_espece.uf_check_passphyto(as_data, as_message))
		
	CASE "type_qte"
		return(ibr_espece.uf_check_typeqte(as_data, as_message))
		
	CASE "lim_pu1"
		return(ibr_espece.uf_check_limpu1(as_data, as_message))
		
	CASE "lim_pu2"
		return(ibr_espece.uf_check_limpu2(as_data, as_message))
		
	CASE "lim_pu3"
		return(ibr_espece.uf_check_limpu3(as_data, as_message))
		
	CASE "lib_unit_pu1"
		return(ibr_espece.uf_check_libunitpu1(as_data, as_message))
		
	CASE "lib_unit_pu2"
		return(ibr_espece.uf_check_libunitpu2(as_data, as_message))
		
	CASE "lib_unit_pu3"
		return(ibr_espece.uf_check_libunitpu3(as_data, as_message))

	CASE "unit_pu1"
		return(ibr_espece.uf_check_unitpu1(as_data, as_message))
		
	CASE "unit_pu2"
		return(ibr_espece.uf_check_unitpu2(as_data, as_message, this.object.lim_pu2[al_row]))
		
	CASE "unit_pu3"
		return(ibr_espece.uf_check_unitpu3(as_data, as_message, this.object.lim_pu3[al_row]))
		
	CASE "comm_cat"
		return(ibr_espece.uf_check_comm(as_data, as_message))
		
END CHOOSE
return(1)
end event

event ue_leavekey;call super::ue_leavekey;// quand on quitte la clé, cela veut dire qu'on dispose de données actives dans la fenêtre
wf_actif(true)

// effacer les messages
ddlb_message.reset()

// lecture du record si existe déjà
IF NOT this.uf_IsRecordNew() THEN
	wf_message("Modification d'une espèce...")
	this.retrieve(is_codesp)
ELSE
	wf_message("Nouvelle espèce...")
END IF

parent.event ue_init_menu()
post wf_init()

end event

