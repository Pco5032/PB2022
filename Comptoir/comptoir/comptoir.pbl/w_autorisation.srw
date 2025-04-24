//objectcomments Encodage des autorisations de récolte et transport
forward
global type w_autorisation from w_ancestor_dataentry
end type
type dw_aut from uo_datawindow_singlerow within w_autorisation
end type
type dw_tr from uo_datawindow_multiplerow within w_autorisation
end type
end forward

global type w_autorisation from w_ancestor_dataentry
integer width = 3035
integer height = 2348
string title = "Autorisations de récolte/mélange"
boolean resizable = true
event ue_print ( )
dw_aut dw_aut
dw_tr dw_tr
end type
global w_autorisation w_autorisation

type variables
integer	ii_anaut, ii_numaut
boolean	ib_ajout
br_autorisation	ibr_autorisation
uo_cpteur		iu_cpteur

end variables

forward prototypes
public function integer wf_init ()
public function integer wf_newaut ()
public function integer wf_newtr ()
public subroutine wf_print ()
end prototypes

event ue_print();wf_print()
end event

public function integer wf_init ();string	ls_codesp, ls_nom, ls_numcm, ls_propmb, ls_interlocuteur
integer	li_num, ll_count

IF dw_aut.uf_IsRecordNew() THEN
	// valeurs par défaut pour nouveau record
	dw_aut.uf_SetDefaultValue(1, "type_aut", "R")
	dw_aut.uf_SetDefaultValue(1, "AUTORISATION_OBTENUE", "A")
ELSE
	// lecture des traductions pour record existant
	ls_codesp = dw_aut.object.code_sp[1]
	select nom_fr into :ls_nom from espece where code_sp = :ls_codesp using ESQLCA;
	IF f_check_sql(ESQLCA) = 0 THEN
		dw_aut.object.c_nomespece[1] = ls_nom
	END IF
	
	// lecture nom provenance et propriétaire MB
	li_num = dw_aut.object.num_prov[1]
	select nom, prop_mb into :ls_nom, :ls_propmb from provenance 
		where code_sp = :ls_codesp and num_prov = :li_num using ESQLCA;
	IF f_check_sql(ESQLCA) = 0 THEN
		select interlocuteur into :ls_interlocuteur from interlocuteur where locu=:ls_propmb using ESQLCA;
		IF f_check_sql(ESQLCA) = 0 THEN
			dw_aut.object.c_nomprov[1] = ls_nom + " / Prop.MB : " + f_string(ls_interlocuteur)
		ELSE
			dw_aut.object.c_nomprov[1] = ls_nom
		END IF
	END IF
	
	// lectures des autorisations de transport
	dw_tr.retrieve(ii_anaut, ii_numaut)
	
END IF

// disabler la clé et enabler les datas
dw_aut.uf_enabledata()
dw_aut.uf_disablekeys()
dw_aut.SetColumn("type_aut")

// si l'autorisation est utilisée dans un CM, certains champs ne sont plus modifiables
select num_cm into :ls_numcm from certificat where an_aut=:ii_anaut and num_aut=:ii_numaut using ESQLCA;
IF ESQLCA.SQLnRows = 1 THEN
	dw_aut.object.c_numcm[1] = ls_numcm
	// PCO 09/02/2010 : suite demande Alain Servais, la quantité totale autorisée (qte_mfr_total) ne doit plus
	// être désactivée, elle doit rester accessible. Je la retire donc de la liste des items disabled.
	dw_aut.uf_disableItems({"type_aut", "dt_demande", "nature_mat", "code_sp", "num_prov"})
	// autorisation pour un mélange de provenance, et cette autorisation est référencée par un CM pour
	// lequel le mélange est déjà constitué : l'année de maturité ne peut plus être modifiée.
	select count(*) into :ll_count from cm_melange where num_cm = :ls_numcm using ESQLCA;
	IF ll_count > 0 THEN
		dw_aut.uf_disableItems({"an_maturite"})
	END IF
END IF

// si autorisation pour un mélange, il n'y a pas d'autorisation de transport
IF dw_aut.object.type_aut[1] <> "R" THEN
	dw_tr.enabled = FALSE
	dw_tr.visible = FALSE
ELSE
	dw_tr.enabled = TRUE
	dw_tr.visible = TRUE
END IF

dw_aut.SetItemStatus(1,0,Primary!,NotModified!)
dw_aut.SetFocus()

return(1)
end function

public function integer wf_newaut ();// création d'une nouvelle autorisation de récolte
decimal	ld_numaut

// l'année doit être spécifiée
IF IsNull(ii_anaut) OR ii_anaut = 0 THEN
	gu_message.uf_error("Veuillez d'abord sélectionner une année d'autorisation")
	return(-1)
END IF

// prendre nouveau n° d'autorisation via le compteur, le placer dans numaut et passer au champ suivant
ld_numaut = iu_cpteur.uf_getnumaut(ii_anaut)
IF ld_numaut < 0 THEN
	gu_message.uf_error("Impossible d'obtenir un nouveau n° d'autorisation pour cette année !")
	return(-1)
END IF
ib_ajout = TRUE
dw_aut.setfocus()
dw_aut.SetText(string(ld_numaut))
f_presskey ("TAB")

return(1)

end function

public function integer wf_newtr ();// création d'une nouvelle autorisation de transport
// return(-1) si erreur
// return(n° de row ajoutée) si OK
integer	li_num
long		ll_row
decimal{3}	ld_qtetot

// pour pouvoir créer une ligne d'autorisation de transport, il faut que la quantité totale autorisée
// soit mentionnée
ld_qtetot = dw_aut.object.qte_mfr_total[1]
IF IsNull(ld_qtetot) OR ld_qtetot = 0 THEN
	gu_message.uf_error("Veuillez introduire la quantité totale autorisée avant de créer les autorisations de transport")
	return(-1)
END IF

ll_row = dw_tr.event ue_addrow()
IF ll_row <= 0 THEN
	return(-1)
END IF

// initialiser 1ère partie de la PK
dw_tr.object.an_aut[ll_row] = ii_anaut
dw_tr.object.num_aut[ll_row] = ii_numaut

// numérotation auto.
li_num = dw_tr.object.c_maxnum[ll_row]
IF IsNull(li_num) THEN 
	li_num = 1
ELSE
	li_num++
END IF		

IF li_num > 0 AND li_num <= 99 THEN 
	dw_tr.object.num_tr[ll_row] = li_num
	dw_tr.SetColumn("dt_tr")
ELSE
	dw_tr.SetColumn("num_tr")
END IF

dw_tr.object.datawindow.HorizontalScrollPosition = 1
dw_tr.SetFocus()

return(ll_row)
end function

public subroutine wf_print ();// impression de l'autorisation
str_params	lstr_params
long			ll_count

IF ii_anaut = 0 OR ii_numaut = 0 THEN
	gu_message.uf_info("Veuillez d'abord afficher l'autorisation")
	return
END IF

select count(*) into :ll_count from autorisation where an_aut=:ii_anaut and num_aut=:ii_numaut
		using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	return
END IF
IF ll_count = 0 THEN
	gu_message.uf_info("Vous devez d'abord enregistrer l'autorisation avant de pouvoir l'imprimer")
	return
END IF

IF IsValid(w_rpt_demautorisation) THEN
	close(w_rpt_demautorisation)
END IF

lstr_params.a_param[1] = ii_anaut
lstr_params.a_param[2] = ii_numaut
OpenSheetWithParm(w_rpt_demautorisation, lstr_params, gw_mdiframe, 0, Original!)
IF IsValid(w_rpt_demautorisation) THEN
	w_rpt_demautorisation.SetFocus()
END IF
end subroutine

on w_autorisation.create
int iCurrent
call super::create
this.dw_aut=create dw_aut
this.dw_tr=create dw_tr
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_aut
this.Control[iCurrent+2]=this.dw_tr
end on

on w_autorisation.destroy
call super::destroy
destroy(this.dw_aut)
destroy(this.dw_tr)
end on

event ue_init_menu;call super::ue_init_menu;string	ls_menu[]
integer	li_item

li_item = 2
ls_menu = {"m_abandonner", "m_fermer"}

IF wf_IsActif() THEN
	IF wf_canUpdate() THEN
		li_item++
		ls_menu[li_item] = "m_enregistrer"
	END IF
	CHOOSE CASE wf_GetActivecontrolname()
		// menu si curseur est sur l'autorisation de récolte
		CASE "dw_aut"
			IF NOT dw_aut.uf_IsRecordNew() AND wf_canDelete() THEN
				li_item++
				ls_menu[li_item] = "m_supprimer"
			END IF
		// menu si curseur est sur les autorisations de transport	
		CASE "dw_tr"
			IF wf_canUpdate() THEN
				li_item++
				ls_menu[li_item] = "m_ajouter"
				li_item++
				ls_menu[li_item] = "m_supprimer"				
			END IF
	END CHOOSE
ELSE
	CHOOSE CASE wf_GetActivecontrolname()
		CASE "dw_aut"
			IF dw_aut.GetColumnName() = "num_aut" AND wf_canUpdate() THEN
				li_item++
				ls_menu[li_item] = "m_ajouter"
			END IF
	END CHOOSE
END IF

f_menuaction(ls_menu)
end event

event ue_open;call super::ue_open;ibr_autorisation = CREATE br_autorisation
iu_cpteur = CREATE uo_cpteur

// ne pas créer automatiquement une nouvelle ligne 'autorisation de transport' quand on supprime la dernière
dw_tr.uf_createwhenlastdeleted(FALSE)

// action "ajouter" doit être visible dans le menu
wf_SetItemsToShow({"m_ajouter"})

wf_SetDWList({dw_aut, dw_tr})

ii_anaut = year(today())
// setNull(ii_anaut)
end event

event ue_close;call super::ue_close;DESTROY ibr_autorisation
DESTROY iu_cpteur
end event

event ue_init_win;call super::ue_init_win;ib_ajout = FALSE
SetNull(ii_numaut)
iu_cpteur.uf_rollback()

this.setredraw(FALSE)

dw_aut.uf_reset()
dw_tr.uf_reset()
dw_tr.visible = TRUE

dw_tr.object.datawindow.HorizontalScrollPosition = 1

dw_aut.insertrow(0)

dw_aut.uf_disabledata()
dw_aut.uf_enablekeys()
IF IsNull(ii_anaut) THEN
	dw_aut.object.an_aut[1] = 0
	dw_aut.Setcolumn("an_aut")
ELSE
	dw_aut.uf_setdefaultvalue(1, "an_aut", ii_anaut)
	dw_aut.Setcolumn("num_aut")
END IF
dw_aut.setfocus()

this.setredraw(TRUE)
end event

event ue_supprimer;call super::ue_supprimer;string	ls_message
long		ll_row

CHOOSE CASE wf_GetActivecontrolname()
	// suppression de toute l'autorisation de récolte
	CASE "dw_aut"
		IF ibr_autorisation.uf_check_beforedelete(ii_anaut, ii_numaut, ls_message) = -1 THEN
			gu_message.uf_info(ls_message)
			return
		END IF
		IF f_confirm_del("Voulez-vous supprimer toute l'autorisation de récolte ?") = 1 THEN
			IF dw_aut.event ue_delete() = 1 THEN
				// normalement, les "many" sont supprimés par les contraintes mais...
				delete from autorisation_tr where an_aut = :ii_anaut and num_aut=:ii_numaut using ESQLCA;
				IF f_check_sql(ESQLCA) = 0 AND ESQLCA.sqlnrows <> 0 THEN
					commit using ESQLCA;
					populateerror(20000,"")
					gu_message.uf_unexp("Les contraintes d'intégrité entre AUTORISATION et AUTORISATION_TR ne sont pas actives !", 2)
				END IF
				// remarque : commit ou rollback nécessaire après les delete ci-dessus, même s'ils n'ont aucun effet !
				// Si on ne le fait pas, les LOCK subsistent !
				commit using ESQLCA;
				wf_message("Autorisation de récolte supprimée avec succès")
				this.event ue_init_win()
			END IF
		END IF
	// suppression d'une autorisation de transport
	CASE  "dw_tr"
		ll_row = dw_tr.GetRow()
		IF ll_row <= 0 THEN return
		IF f_confirm_del("Voulez-vous supprimer l'autorisation de transport n° " + &
							  f_string(dw_tr.object.num_tr[ll_row]) + " ?") = 1 THEN
			IF dw_tr.event ue_delete() = 1 THEN
				wf_message("Autorisation de transport supprimée avec succès")
			END IF
		END IF
END CHOOSE

end event

event ue_enregistrer;call super::ue_enregistrer;integer	li_status, li_anaut, li_numaut, li_anmaturite
string	ls_reflot, ls_numcm

// contrôle de validité de tous les champs
IF dw_aut.event ue_checkall() < 0 THEN
	dw_aut.SetFocus()
	return(-1)
END IF
IF dw_tr.event ue_checkall() < 0 THEN
	dw_tr.SetFocus()
	return(-1)
END IF

// l'année de maturité doit être recopiée dans le lot auquel fait référence l'autorisation (via le CM)
li_anaut = dw_aut.object.an_aut[1]
li_numaut = dw_aut.object.num_aut[1]
li_anmaturite = dw_aut.object.an_maturite[1]
select num_cm into :ls_numcm from certificat where an_aut = :li_anaut and num_aut = :li_numaut using ESQLCA;
IF f_check_sql(ESQLCA) = 0 THEN
	update registre
		set an_maturite = :li_anmaturite
		where num_cm = :ls_numcm using SQLCA; // même transaction que l'update des DW
	IF SQLCA.sqlnRows > 1 THEN
		populateerror(20000, "")
		gu_message.uf_unexp("Erreur mise à jour année de maturité dans REGISTRE : plus d'un lot serait mis à jour !")
		return(-1)
		rollback using SQLCA;
	END IF
END IF

li_status = gu_dwservices.uf_updatetransact(dw_aut, dw_tr)
CHOOSE CASE li_status
	CASE 1
		wf_message("Autorisation " + string(ii_anaut) + "/" + f_string(ii_numaut) + " enregistrée avec succès")
		// si nouvelle autorisation, updater compteur
		IF dw_aut.uf_IsRecordNew() THEN
			IF iu_cpteur.uf_update_numaut(ii_anaut, ii_numaut) = -1 THEN
				populateerror(20000, "")
				gu_message.uf_unexp("Erreur mise à jour du compteur AUTORISATION.NUM_AUT")
				return(-1)
			ELSE
				This.event ue_init_win()
				return(1)
			END IF
		ELSE
			This.event ue_init_win()
			return(1)
		END IF
	CASE -1
		populateerror(20000,"")
		gu_message.uf_unexp("AUTORISATION : Erreur lors de la mise à jour de la base de données")
		return(-1)
	CASE -2
		populateerror(20000,"")
		gu_message.uf_unexp("AUTORISATION_TR : Erreur lors de la mise à jour de la base de données")
		return(-1)
END CHOOSE

end event

event ue_ajouter;call super::ue_ajouter;long	ll_row

CHOOSE CASE wf_GetActivecontrolname()
	// ajouter une nouvelle autorisation de récolte si le curseur est sur DW_AUT et dans l'item NUM_AUT
	CASE "dw_aut"
		IF dw_aut.GetColumnName() = "num_aut" THEN
			wf_newaut()
			return
		END IF
		
	// ajouter une nouvelle autorisation de transport si le curseur est sur DW_TR
	CASE "dw_tr"
		IF dw_tr.accepttext() < 0 THEN return
		wf_newtr()
END CHOOSE
end event

event ue_init_inactivewin;call super::ue_init_inactivewin;SetNull(ii_anaut)
end event

event resize;call super::resize;dw_tr.width = newwidth
dw_tr.height = newheight - dw_aut.height - 100
end event

type ddlb_message from w_ancestor_dataentry`ddlb_message within w_autorisation
integer x = 18
integer y = 2144
end type

type dw_aut from uo_datawindow_singlerow within w_autorisation
integer width = 2999
integer height = 1504
integer taborder = 10
boolean bringtotop = true
string dataobject = "d_autorisation"
end type

event itemfocuschanged;call super::itemfocuschanged;parent.event post ue_init_menu()
end event

event ue_checkitem;call super::ue_checkitem;integer	li_status, li_numaut, li_code
long		ll_count
string	ls_code, ls_nom, ls_pays, ls_region 

as_message = ""

CHOOSE CASE as_item
	CASE "an_aut"
		IF ibr_autorisation.uf_check_anaut(as_data, as_message) = -1 THEN
			return(-1)
		ELSE
			ii_anaut = integer(as_data)
			return(1)
		END IF
		
	// dernier élément de la clé, vérifier si record existe ou pas
	CASE "num_aut"
		IF ibr_autorisation.uf_check_numaut(as_data, as_message) = -1 THEN
			iu_cpteur.uf_rollback()
			return(-1)
		END IF
		li_numaut = integer(as_data)
		select count(*) into :ll_count from autorisation
				where an_aut = :ii_anaut and num_aut=:li_numaut using ESQLCA;
		li_status = f_check_sql(ESQLCA)
		IF li_status < 0 OR ll_count > 1 THEN
			populateerror(20000,"")
			gu_message.uf_unexp("Erreur SELECT AUTORISATION")
			return(-1)
		ELSE
			// autorisation inexistante...
			IF ll_count = 0 THEN
				// ...et on peut modifier les données...
				IF wf_canUpdate() THEN
					IF ib_ajout THEN
						this.uf_NewRecord(TRUE)
						ii_numaut = li_numaut
						return(1)
					ELSE
						as_message = "Autorisation inexistante. Utilisez l'action 'Ajouter' pour en créer une."
						return(-1)
					END IF
				ELSE
				// ...et on ne peut pas modifier les données
					as_message = "Autorisation inexistante. Vous n'avez pas le droit d'en créer..."
					return(-1)
				END IF
			ELSE
			// Autorisation existe déjà : OK
				this.uf_NewRecord(FALSE)
				ii_numaut = li_numaut
				return(1)
			END IF
		END IF
		
	CASE "dt_demande"
		return(ibr_autorisation.uf_check_dtdemande(as_data, as_message))
		
	CASE "nature_mat"
		return(ibr_autorisation.uf_check_naturemat(as_data, as_message, this.object.type_aut[1]))
	
	CASE "code_sp"
		IF ibr_autorisation.uf_check_codesp(as_data, as_message) = -1 THEN
			return(-1)
		ELSE
			this.object.c_nomespece[al_row] = as_message
			return(1)
		END IF
		
	CASE "num_prov"
		return(ibr_autorisation.uf_check_numprov(as_data, as_message, string(this.object.code_sp[al_row])))

	CASE "an_maturite"
		return(ibr_autorisation.uf_check_anmaturite(as_data, as_message, this.object.type_aut[1]))
		
	CASE "dt_reception_formulaire"
		return(ibr_autorisation.uf_check_dtreceptionformulaire(as_data, as_message))
		
	CASE "autorisation_obtenue"
		return(ibr_autorisation.uf_check_autorisationobtenue(as_data, as_message))
		
END CHOOSE

return(1)
end event

event ue_leavekey;call super::ue_leavekey;// quand on quitte la clé, cela veut dire qu'on dispose de données actives dans la fenêtre
wf_actif(true)

// effacer les messages
ddlb_message.reset()

// lecture du record si existe déjà
IF NOT this.uf_IsRecordNew() THEN
	wf_message("Modification d'une autorisation...")
	this.retrieve(ii_anaut, ii_numaut)
ELSE
	wf_message("Nouvelle autorisation...")
END IF

parent.event ue_init_menu()
post wf_init()

end event

event ue_help;call super::ue_help;str_params	lstr_params

IF NOT isValid(idwo_currentItem) THEN return
IF isNull(idwo_currentItem) THEN return

CHOOSE CASE idwo_currentItem.name
	CASE "an_aut"
		lstr_params.a_param[1] = 0
		lstr_params.a_param[2] = TRUE
		lstr_params.a_param[3] = FALSE
		openwithparm(w_l_autorisation, lstr_params)
		IF Message.DoubleParm = -1 THEN 
			return
		ELSE
			lstr_params=Message.PowerObjectParm
			this.SetText(f_string(lstr_params.a_param[1]))
			f_presskey("TAB")
		END IF

	CASE "num_aut"
		lstr_params.a_param[1] = ii_anaut
		lstr_params.a_param[2] = TRUE
		lstr_params.a_param[3] = FALSE
		openwithparm(w_l_autorisation, lstr_params)
		IF Message.DoubleParm = -1 THEN 
			return
		ELSE
			lstr_params=Message.PowerObjectParm
			this.uf_setdefaultvalue(1, "an_aut", integer(lstr_params.a_param[1]))
			this.SetText(f_string(lstr_params.a_param[2]))
			f_presskey("TAB")
		END IF

	CASE "code_sp"
		open(w_l_espece)
		IF Message.DoubleParm = -1 THEN 
			return
		ELSE
			lstr_params=Message.PowerObjectParm
			this.SetText(string(lstr_params.a_param[1]))
			f_presskey("tab")
		END IF
	
	CASE "num_prov"
		lstr_params.a_param[1] = this.object.code_sp[1]
		lstr_params.a_param[2] = TRUE
		lstr_params.a_param[3] = FALSE
		openwithparm(w_l_provenance, lstr_params)
		IF Message.DoubleParm = -1 THEN 
			return
		ELSE
			lstr_params=Message.PowerObjectParm
			this.uf_setdefaultvalue(1, "code_sp", f_string(lstr_params.a_param[1]))
			this.SetText(f_string(lstr_params.a_param[2]))
			f_presskey("TAB")
		END IF
		
END CHOOSE


end event

event getfocus;call super::getfocus;w_ancestor_dataentry	lw_parent

// réactualiser le menu car l'option 'ajouter' n'est pas toujours disponible
IF f_GetParentWindow(this, lw_parent) = 1 THEN
	lw_parent.event ue_init_menu()
END IF

end event

event doubleclicked;call super::doubleclicked;string	ls_url, ls_numcm
integer	li_status

IF row = 0 THEN return
CHOOSE CASE dwo.name
	// ouverture du lien renseigné dans le champ SCAN
	CASE "scan"
		IF f_IsEmptyString(this.object.scan[row]) THEN return
		ls_url = this.object.scan[row]
		f_openlink(ls_url)

	// double-clic sur le n° de CM : ouvrir ce CM
	CASE "c_numcm"
		ls_numcm = dwo.Primary[row]
		IF f_IsEmptyString(ls_numcm) THEN return

		IF NOT IsValid(w_certificat) THEN
			OpenSheet(w_certificat, gw_mdiframe, 0, Original!)
		END IF
		IF IsValid(w_certificat) THEN
			w_certificat.SetFocus()
			li_status = w_certificat.event ue_abandonner()
			IF li_status = 3 OR li_status < 0 THEN
				return
			END IF
			w_certificat.post wf_SetKey(ls_numcm)
		END IF
END CHOOSE
end event

event ue_itemvalidated;call super::ue_itemvalidated;integer	li_num
string	ls_codesp, ls_nom, ls_propmb, ls_interlocuteur
long		ll_row

CHOOSE CASE as_name
	CASE "type_aut"
		// mélange : nature du matériel = d'office "G", et pas d'accès aux autorisations de transport
		IF as_data <> "R" THEN
			this.uf_SetDefaultValue(al_row, "nature_mat", "G")
			dw_tr.enabled = FALSE
			dw_tr.visible = FALSE
			FOR ll_row = dw_tr.rowCount() TO 1 step -1
				dw_tr.deleterow(ll_row)
			NEXT
		ELSE
			dw_tr.enabled = TRUE
			dw_tr.visible = TRUE
		END IF
		// mélange d'années de maturité : année de maturité = null
		IF as_data = "A" THEN
			this.uf_SetDefaultValue(al_row, "an_maturite", gu_c.i_null, Integer!)
		END IF
		
	CASE "num_prov"
		// lecture nom provenance et propriétaire MB
		li_num = integer(as_data)
		ls_codesp = string(this.object.code_sp[al_row])
		select nom, prop_mb into :ls_nom, :ls_propmb from provenance 
			where code_sp = :ls_codesp and num_prov = :li_num using ESQLCA;
		IF f_check_sql(ESQLCA) = 0 THEN
			select interlocuteur into :ls_interlocuteur from interlocuteur where locu=:ls_propmb using ESQLCA;
			IF f_check_sql(ESQLCA) = 0 THEN
				this.object.c_nomprov[1] = ls_nom + " / Prop.MB : " + f_string(ls_interlocuteur)
			ELSE
				this.object.c_nomprov[1] = ls_nom
			END IF
		END IF
END CHOOSE
end event

type dw_tr from uo_datawindow_multiplerow within w_autorisation
integer x = 18
integer y = 1504
integer width = 2999
integer height = 624
integer taborder = 11
boolean bringtotop = true
string dataobject = "d_autorisation_tr"
boolean hscrollbar = true
boolean vscrollbar = true
boolean border = true
end type

event getfocus;call super::getfocus;w_ancestor_dataentry	lw_parent

// réactualiser le menu car l'option 'ajouter' n'est pas toujours disponible
IF f_GetParentWindow(this, lw_parent) = 1 THEN
	lw_parent.event ue_init_menu()
END IF

end event

event ue_checkitem;call super::ue_checkitem;date	l_date_aut

as_message = ""

CHOOSE CASE as_item
	CASE "num_tr"
		IF ibr_autorisation.uf_check_numtr(as_data, as_message) = -1 THEN
			return(-1)
		ELSE
			IF gu_dwservices.uf_findduplicate(This, al_row, "num_tr=" + as_data) <> 0 THEN
				as_message = "Ce n° de ligne existe déjà"
				return(-1)
			END IF
		END IF
		return(1)
		
	CASE "dt_tr"
		l_date_aut = gu_datetime.uf_dfromdt(dw_aut.object.dt_demande[1])
		return(ibr_autorisation.uf_check_dttr(as_data, as_message, l_date_aut))
		
	CASE "qte_mfr_tr"
		return(ibr_autorisation.uf_check_qtemfrtr(as_data, as_message))
	
	CASE "dest_mfr_tr"
		return(ibr_autorisation.uf_check_destmfrtr(as_data, as_message))
		
	CASE "rem_mfr_tr"
		return(ibr_autorisation.uf_check_remmfrtr(as_data, as_message))

END CHOOSE

return(1)
end event

event ue_itemvalidated;call super::ue_itemvalidated;decimal{3}	ld_qtetot, ld_qtetot_tr, ld_new_qte_mfr_tr, ld_old_qte_mfr_tr

// après encodage d'une quantité de transport autorisée, vérifier si la quantité totale
// n'est pas supérieure à la quantitié de récolte autorisée. Message d'avertissement seulement.
CHOOSE CASE as_name
	CASE "qte_mfr_tr"
		ld_new_qte_mfr_tr = dec(as_data)
		ld_old_qte_mfr_tr = this.object.qte_mfr_tr[al_row]
		IF isNull(ld_old_qte_mfr_tr) THEN ld_old_qte_mfr_tr = 0
		ld_qtetot = dw_aut.object.qte_mfr_total[1]
		ld_qtetot_tr = dw_tr.object.c_qtetot_tr[1] - ld_old_qte_mfr_tr + ld_new_qte_mfr_tr
		IF ld_qtetot_tr > ld_qtetot THEN
			gu_message.uf_info("Attention, la quantité de transport autorisée dépasse la quantité de récolte autorisée...")
		END IF
END CHOOSE

end event

