//objectcomments Encodage des documents fournisseurs
forward
global type w_docfrn from w_ancestor_dataentry
end type
type dw_docfrn from uo_datawindow_singlerow within w_docfrn
end type
end forward

global type w_docfrn from w_ancestor_dataentry
integer width = 2999
integer height = 2108
string title = "Documents fournisseurs"
event ue_print ( )
dw_docfrn dw_docfrn
end type
global w_docfrn w_docfrn

type variables
string	is_docfrn
br_interlocuteur	ibr_interlocuteur
br_docfrn	ibr_docfrn
end variables

forward prototypes
public function integer wf_init ()
public function integer wf_setkey (string as_numdf)
public function integer wf_infolot (string as_reflot)
public subroutine wf_print ()
public function integer wf_infocaract (string as_reflot, integer ai_cphys, integer ai_qgerm)
end prototypes

event ue_print();wf_print()
end event

public function integer wf_init ();string	ls_destinataire, ls_interlocuteur, ls_saison
integer	li_numcat
long		ll_count

IF dw_docfrn.uf_IsRecordNew() THEN
	// valeurs par défaut pour nouveau record
	dw_docfrn.uf_setDefaultValue(1, "type_df", "E")
	dw_docfrn.uf_setDefaultValue(1, "conserv", "S")
	dw_docfrn.uf_setDefaultValue(1, "qte_avpretrt", 0)
	dw_docfrn.uf_setDefaultValue(1, "qte_sspretrt", 0)
	dw_docfrn.uf_setDefaultValue(1, "nb_colis", 0)
	dw_docfrn.uf_setDefaultValue(1, "dt_sign", f_today())
	dw_docfrn.object.num_cat[1] = 0
ELSE
	// lecture des traductions pour record existant
	// destinataire
	ls_destinataire = dw_docfrn.object.destinataire[1]
	select interlocuteur into :ls_interlocuteur from interlocuteur 
		where locu = :ls_destinataire using ESQLCA;
	IF f_check_sql(ESQLCA) = 0 THEN
		dw_docfrn.object.c_destinataire[1] = ls_interlocuteur
	END IF
	
	// saison
	li_numcat = dw_docfrn.object.num_cat[1]
	select saison into :ls_saison from cat_vente 
		where num_cat = :li_numcat using ESQLCA;
	IF f_check_sql(ESQLCA) = 0 THEN
		dw_docfrn.object.c_saison[1] = ls_saison
	END IF
	
	// lire et afficher les caract. du lot (espèce, région prov., provenance, année maturité)
	wf_infolot(dw_docfrn.object.ref_lot[1])
	
	// lire et afficher les infos sur les caractéristiques des graines
	wf_infocaract(dw_docfrn.object.ref_lot[1], dw_docfrn.object.num_cphys[1], dw_docfrn.object.num_qgerm[1])
	
END IF

dw_docfrn.SetItemStatus(1,0,Primary!,NotModified!)

// disabler la clé et enabler les datas
dw_docfrn.uf_enabledata()
dw_docfrn.uf_disablekeys()
dw_docfrn.SetColumn("type_df")

// si le docfrn est utilisée dans une ligne de commande, certains champs ne sont plus modifiables
select count(*) into :ll_count from detail_cmde where num_df_emis=:is_docfrn using ESQLCA;
IF ll_count > 0 THEN
	dw_docfrn.uf_disableItems({"type_df", "destinataire", "ref_lot", "num_cat"})
END IF

return(1)
end function

public function integer wf_setkey (string as_numdf);// utilisé par un programme externe pour ouvrir un document fournisseur
IF f_isEmptyString(as_numdf) THEN
	return(-1)
END IF

IF dw_docfrn.uf_SetDefaultValue(1, "num_df", as_numdf) < 0 THEN return(-1)

return(1)
end function

public function integer wf_infolot (string as_reflot);// lire et afficher les caract. du lot (espèce, région prov., provenance, année maturité)

string	ls_codesp, ls_nomprov, ls_coderegprov, ls_nomregprov, ls_passphyto
integer	li_numprov, li_anmaturite, li_numregprov

select code_sp, num_prov, an_maturite into :ls_codesp, :li_numprov, :li_anmaturite
	from registre where ref_lot = :as_reflot using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	populateError(20000,"")
	gu_message.uf_unexp("Erreur SELECT REGISTRE")
ELSE
	select num_regprov, nom into :li_numregprov, :ls_nomprov 
		from provenance where code_sp = :ls_codesp and num_prov = :li_numprov using ESQLCA;
	IF f_check_sql(ESQLCA) <> 0 THEN
		populateError(20000,"")
		gu_message.uf_unexp("Erreur SELECT PROVENANCE")
	ELSE
		select code_regprov, nom into :ls_coderegprov, :ls_nomregprov
			from region_prov where num_regprov = :li_numregprov using ESQLCA;
		IF f_check_sql(ESQLCA) <> 0 THEN
			populateError(20000,"")
			gu_message.uf_unexp("Erreur SELECT REGION_PROV")
		END IF
	END IF
	select passphyto into :ls_passphyto from espece where code_sp=:ls_codesp using ESQLCA;
	IF f_check_sql(ESQLCA) <> 0 THEN
		populateError(20000,"")
		gu_message.uf_unexp("Erreur SELECT ESPECE")
	ELSE
		IF ls_passphyto = "O" THEN
			dw_docfrn.post uf_enableItems({"rp"})
		ELSE
			dw_docfrn.post uf_disableItems({"rp"})
		END IF
	END IF
END IF
dw_docfrn.object.c_codesp[1] = ls_codesp
dw_docfrn.object.c_nomprov[1] = ls_nomprov
dw_docfrn.object.c_coderegprov[1] = ls_coderegprov
dw_docfrn.object.c_nomregprov[1] = ls_nomregprov
dw_docfrn.object.c_anmaturite[1] = li_anmaturite
		
return(1)
end function

public subroutine wf_print ();// impression du document fournisseur
str_params	lstr_params
string	ls_type

IF f_isEmptyString(is_docfrn) THEN
	gu_message.uf_info("Veuillez d'abord afficher le document-fournisseur")
	return
END IF

select type_df into :ls_type from DOCFRN where num_df=:is_docfrn using ESQLCA;
IF f_check_sql(ESQLCA) < 0 THEN
	return
END IF
IF ESQLCA.sqlnrows = 0 THEN
	gu_message.uf_info("Vous devez d'abord enregistrer le document fournisseur avant de pouvoir l'imprimer")
	return
END IF
IF ls_type <> "E" THEN
	gu_message.uf_info("Impression des documents fournisseurs EMIS uniquement")
	return
END IF

IF IsValid(w_rpt_docfrn) THEN
	close(w_rpt_docfrn)
END IF

lstr_params.a_param[1] = is_docfrn
OpenSheetWithParm(w_rpt_docfrn, lstr_params, gw_mdiframe, 0, Original!)
IF IsValid(w_rpt_docfrn) THEN
	w_rpt_docfrn.SetFocus()
END IF
end subroutine

public function integer wf_infocaract (string as_reflot, integer ai_cphys, integer ai_qgerm);// lire et afficher les infos sur les caractéristiques des graines
date		l_date
string	ls_rem

// caractéristiques physiques
select dt_cphys, rem into :l_date, :ls_rem from registre_cphys
	where ref_lot = :as_reflot and num_cphys = :ai_cphys using ESQLCA;
IF f_check_sql(ESQLCA) < 0 THEN
	populateError(20000,"")
	gu_message.uf_unexp("Erreur SELECT REGISTRE_CPHYS")
END IF
IF esqlca.sqlnrows = 1 THEN
	ls_rem = gu_stringservices.uf_replaceall(ls_rem, '"', "'")
	dw_docfrn.object.t_cphys.text = string(l_date, "dd/mm/yyyy") + " - " + f_string(ls_rem)
ELSE
	dw_docfrn.object.t_cphys.text = ""
END IF

// qualités germinatives
select dt_qgerm, rem into :l_date, :ls_rem from registre_qgerm
	where ref_lot = :as_reflot and num_qgerm = :ai_qgerm using ESQLCA;
IF f_check_sql(ESQLCA) < 0 THEN
	populateError(20000,"")
	gu_message.uf_unexp("Erreur SELECT REGISTRE_QGERM")
END IF
IF esqlca.sqlnrows = 1 THEN
	ls_rem = gu_stringservices.uf_replaceall(ls_rem, '"', "'")
	dw_docfrn.object.t_qgerm.text = string(l_date, "dd/mm/yyyy") + " - " + f_string(ls_rem)
ELSE
	dw_docfrn.object.t_qgerm.text = ""
END IF
		
return(1)
end function

on w_docfrn.create
int iCurrent
call super::create
this.dw_docfrn=create dw_docfrn
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_docfrn
end on

on w_docfrn.destroy
call super::destroy
destroy(this.dw_docfrn)
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
	
	IF NOT dw_docfrn.uf_IsRecordNew() AND wf_canDelete() THEN
		li_item++
		ls_menu[li_item] = "m_supprimer"
	END IF
END IF

f_menuaction(ls_menu)
end event

event ue_init_win;call super::ue_init_win;SetNull(is_docfrn)

this.setredraw(FALSE)

dw_docfrn.uf_reset()
dw_docfrn.insertrow(0)

dw_docfrn.uf_disabledata()
dw_docfrn.uf_enablekeys()
dw_docfrn.Setcolumn("num_df")
dw_docfrn.setfocus()

dw_docfrn.object.t_cphys.text = ""
dw_docfrn.object.t_qgerm.text = ""

this.setredraw(TRUE)
end event

event ue_enregistrer;call super::ue_enregistrer;integer	li_status

// si référence vers n° cphys ou qgerm = 0, mettre NULL
IF integer(dw_docfrn.object.num_cphys[1]) = 0 THEN
	dw_docfrn.object.num_cphys[1] = gu_c.i_null
END IF
IF integer(dw_docfrn.object.num_qgerm[1]) = 0 THEN
	dw_docfrn.object.num_qgerm[1] = gu_c.i_null
END IF


// contrôle de validité de tous les champs
IF dw_docfrn.event ue_checkall() < 0 THEN
	dw_docfrn.SetFocus()
	return(-1)
END IF

li_status = gu_dwservices.uf_updatetransact(dw_docfrn)
CHOOSE CASE li_status
	CASE 1
		wf_message("Document fournisseur " + is_docfrn + " enregistré avec succès")
		This.event ue_init_win()
		return(1)
	CASE -1
		populateerror(20000,"")
		gu_message.uf_unexp("DOCFRN : Erreur lors de la mise à jour de la base de données")
		return(-1)
END CHOOSE

return(1)
end event

event ue_supprimer;call super::ue_supprimer;string	ls_message

IF ibr_docfrn.uf_check_beforedelete(is_docfrn, ls_message) = -1 THEN
	gu_message.uf_info(ls_message)
	return
END IF

IF f_confirm_del("Voulez-vous supprimer ce document fournisseur ?") = 1 THEN
	IF dw_docfrn.event ue_delete() = 1 THEN
		wf_message("Document fournisseur supprimé avec succès")
		this.event ue_init_win()
	END IF
END IF

end event

event ue_close;call super::ue_close;DESTROY br_docfrn

end event

event ue_open;call super::ue_open;ibr_docfrn = CREATE br_docfrn

// initialiser liste des DW modifiables
wf_SetDWList({dw_docfrn})

dw_docfrn.SetFocus()


end event

type ddlb_message from w_ancestor_dataentry`ddlb_message within w_docfrn
integer y = 1920
integer width = 1719
integer height = 336
end type

type dw_docfrn from uo_datawindow_singlerow within w_docfrn
integer y = 16
integer width = 2981
integer height = 1904
integer taborder = 10
boolean bringtotop = true
string dataobject = "d_docfrn"
boolean livescroll = false
end type

event ue_leavekey;call super::ue_leavekey;// quand on quitte la clé, cela veut dire qu'on dispose de données actives dans la fenêtre
wf_actif(true)

// effacer les messages
ddlb_message.reset()

// lecture du record si existe déjà
IF NOT this.uf_IsRecordNew() THEN
	wf_message("Modification d'un document fournisseur...")
	this.retrieve(is_docfrn)
ELSE
	wf_message("Nouveau document fournisseur...")
END IF

parent.event ue_init_menu()
post wf_init()
end event

event ue_checkitem;call super::ue_checkitem;integer	li_status
long		ll_count
date		l_dtcaract

CHOOSE CASE as_item
	CASE "num_df"
		IF ibr_docfrn.uf_check_numdf(as_data, as_message) = -1 THEN
			return(-1)
		ELSE
			is_docfrn = as_data
		END IF
		// dernier élément de la clé, vérifier si record existe ou pas		
		select count(*) into :ll_count from docfrn where num_df = :is_docfrn using ESQLCA;
		li_status = f_check_sql(ESQLCA)
		IF li_status < 0 OR ll_count > 1 THEN
			populateerror(20000,"")
			gu_message.uf_unexp("Erreur SELECT DOCFRN")
			return(-1)
		ELSE
			// document fournisseur inexistant...
			IF ll_count = 0 THEN
				// ...et on peut modifier les données...
				IF wf_canUpdate() THEN
					this.uf_NewRecord(TRUE)
					return(1)
				ELSE
				// ...et on ne peut pas modifier les données
					as_message = "Document fournisseur inexistant. Vous n'avez pas le droit d'en ajouter..."
					return(-1)
				END IF
			ELSE
			// document fournisseur existe déjà : OK
				this.uf_NewRecord(FALSE)
				return(1)
			END IF
		END IF
		
	CASE "type_df"
		return(ibr_docfrn.uf_check_type(as_data, as_message, is_docfrn))
		
	CASE "ref_lot"
		return(ibr_docfrn.uf_check_reflot(as_data, as_message,this.object.type_df[al_row]))
		
	CASE "num_cphys"
		IF ibr_docfrn.uf_check_cphys(as_data, as_message, this.object.ref_lot[al_row]) = -1 THEN
			return(-1)
		ELSE
			this.object.t_cphys.text = as_message
		END IF
		
	CASE "num_qgerm"
		IF ibr_docfrn.uf_check_qgerm(as_data, as_message, this.object.ref_lot[al_row]) = -1 THEN
			return(-1)
		ELSE
			this.object.t_qgerm.text = as_message
		END IF

	CASE "conserv"
		return(ibr_docfrn.uf_check_conserv(as_data, as_message))
		
	CASE "duree_conserv"
		return(ibr_docfrn.uf_check_dureeconserv(as_data, as_message))
		
	CASE "pretrt"
		return(ibr_docfrn.uf_check_pretrt(as_data, as_message))
		
	CASE "qte_avpretrt"
		return(ibr_docfrn.uf_check_qteavpretrt(as_data, as_message))
		
	CASE "qte_sspretrt"
		return(ibr_docfrn.uf_check_qtesspretrt(as_data, as_message))
		
	CASE "nb_colis"
		return(ibr_docfrn.uf_check_nbcolis(as_data, as_message))
		
	CASE "dt_sign"
		return(ibr_docfrn.uf_check_dtsign(as_data, as_message))
		
	CASE "num_cat"
		IF ibr_docfrn.uf_check_numcat(as_data, as_message, this.object.type_df[al_row], this.object.ref_lot[al_row]) = -1 THEN
			return(-1)
		ELSE
			this.object.c_saison[al_row] = as_message
			return(1)
		END IF
		
	CASE "destinataire"
		IF ibr_docfrn.uf_check_destinataire(as_data, as_message, this.object.type_df[al_row]) = -1 THEN
			return(-1)
		ELSE
			this.object.c_destinataire[al_row] = as_message
			return(1)
		END IF
		
	CASE "remarque"
		return(ibr_docfrn.uf_check_remarque(as_data, as_message))
		
	CASE "autres_info"
		return(ibr_docfrn.uf_check_autresinfo(as_data, as_message))
		
	CASE "rp"
		return(ibr_docfrn.uf_check_rp(as_data, as_message))
END CHOOSE
return(1)

end event

event ue_help;call super::ue_help;str_params	lstr_params

IF NOT isValid(idwo_currentItem) THEN return
IF isNull(idwo_currentItem) THEN return

CHOOSE CASE idwo_currentItem.name
	CASE "num_df"
		open(w_l_docfrn)
		IF Message.DoubleParm = -1 THEN 
			return
		ELSE
			lstr_params=Message.PowerObjectParm
			this.SetText(string(lstr_params.a_param[1]))
			f_presskey("tab")
		END IF

	CASE "ref_lot"
		// si docfrn RECU, on ne peut choisir qu'un lot achat/négoce
		IF this.object.type_df[al_row] = "R" THEN
			lstr_params.a_param[1] = "registre.type_graine='A'"
			lstr_params.a_param[2] = FALSE
		ELSE
			lstr_params.a_param[1] = FALSE
		END IF
		openwithparm(w_l_registre, lstr_params)
		IF Message.DoubleParm = -1 THEN 
			return
		ELSE
			lstr_params=Message.PowerObjectParm
			this.SetText(string(lstr_params.a_param[1]))
			f_presskey("tab")
		END IF
		
	CASE "num_cphys"
		lstr_params.a_param[1] = this.object.ref_lot[al_row]
		openwithparm(w_l_registre_cphys, lstr_params)
		IF Message.DoubleParm = -1 THEN 
			return
		ELSE
			lstr_params=Message.PowerObjectParm
			this.SetText(f_string(lstr_params.a_param[1]))
			f_presskey("TAB")
		END IF

	CASE "num_qgerm"
		lstr_params.a_param[1] = this.object.ref_lot[al_row]
		openwithparm(w_l_registre_qgerm, lstr_params)
		IF Message.DoubleParm = -1 THEN 
			return
		ELSE
			lstr_params=Message.PowerObjectParm
			this.SetText(f_string(lstr_params.a_param[1]))
			f_presskey("TAB")
		END IF

	CASE "num_cat"
		open(w_l_catalogue)
		IF Message.DoubleParm = -1 THEN 
			return
		ELSE
			lstr_params=Message.PowerObjectParm
			this.SetText(f_string(lstr_params.a_param[1]))
			f_presskey("TAB")
		END IF

	CASE "destinataire"
		// types d'interlocuteurs autorisés : seulement les clients
		lstr_params.a_param[1] = ""
		lstr_params.a_param[2] = "O"
		lstr_params.a_param[3] = FALSE
		openwithparm(w_l_locu, lstr_params)
		IF Message.DoubleParm = -1 THEN 
			return
		ELSE
			lstr_params=Message.PowerObjectParm
			this.SetText(string(lstr_params.a_param[1]))
			f_presskey("tab")
		END IF
END CHOOSE

end event

event ue_itemvalidated;call super::ue_itemvalidated;string	ls_codesp, ls_nomprov, ls_coderegprov, ls_nomregprov
integer	li_numprov, li_anmaturite, li_numregprov

CHOOSE CASE as_name
	CASE "type_df"
		IF as_data = "R" THEN
			this.object.num_cat[al_row] = 0
			this.object.c_saison[al_row] = gu_c.s_null
			this.object.destinataire[al_row] = gu_c.s_null
			this.object.c_destinataire[al_row] = gu_c.s_null
		END IF
		
	CASE "ref_lot"
		// si on change de lot, annuler l'identitifation des caract. dees graines
		this.uf_setdefaultvalue(al_row, "num_cphys", gu_c.i_null, integer!)
		this.uf_setdefaultvalue(al_row, "num_qgerm", gu_c.i_null, integer!)
		
		// lire et afficher les caract. du lot (espèce, région prov., provenance, année maturité)
		wf_infolot(as_data)
END CHOOSE


end event

