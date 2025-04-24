//objectcomments Encodage des provenances
forward
global type w_provenance from w_ancestor_dataentry
end type
type dw_prov from uo_datawindow_singlerow within w_provenance
end type
end forward

global type w_provenance from w_ancestor_dataentry
integer width = 3122
integer height = 2212
string title = "Provenances"
dw_prov dw_prov
end type
global w_provenance w_provenance

type variables
string	is_codesp
integer	ii_numprov
boolean	ib_ajout
br_provenance	ibr_provenance
uo_cpteur		iu_cpteur

end variables

forward prototypes
public function integer wf_newprov ()
public function integer wf_init ()
public function integer wf_init_croise (string as_item, string as_data)
public subroutine wf_init_croise ()
public function integer wf_check_croise (string as_item, string as_data)
end prototypes

public function integer wf_newprov ();// création d'une nouvelle provenance
decimal	ld_numprov

// le code espèce doit être spécifié
IF f_IsEmptyString(is_codesp) THEN
	gu_message.uf_error("Veuillez d'abord sélectionner une espèce")
	return(-1)
END IF

// prendre nouveau n° de fiche via le compteur, le placer dans nofi et passer au champ suivant
ld_numprov = iu_cpteur.uf_getnumprov(is_codesp)
IF ld_numprov < 0 THEN
	gu_message.uf_error("Impossible d'obtenir un nouveau n° de provenance pour cette espèce !")
	return(-1)
END IF
ib_ajout = TRUE
dw_prov.setfocus()
dw_prov.SetText(string(ld_numprov))
f_presskey ("TAB")

return(1)

end function

public function integer wf_init ();string	ls_data, ls_locu, ls_code, ls_nom, ls_pays, ls_region
integer	li_can, li_code

IF dw_prov.uf_IsRecordNew() THEN
	// valeurs par défaut pour nouveau record
	dw_prov.uf_setdefaultvalue(1, "abattu", "N")
ELSE
	// lecture des traductions pour record existant
	ls_code = dw_prov.object.code_sp[1]
	select nom_fr into :ls_data from espece where code_sp = :ls_code using ESQLCA;
	IF f_check_sql(ESQLCA) = 0 THEN
		dw_prov.object.c_nomfr_sp[1] = ls_data
	END IF
	
	li_code = dw_prov.object.num_regprov[1]
	select code_regprov, nom, pays, region into :ls_code, :ls_nom, :ls_pays, :ls_region 
		from region_prov where num_regprov = :li_code using ESQLCA;
	IF f_check_sql(ESQLCA) = 0 THEN
		dw_prov.object.c_prov_code_regprov[1] = ls_code
		dw_prov.object.c_prov_nom[1] = ls_nom
		dw_prov.object.c_prov_pays[1] = ls_pays
		dw_prov.object.c_prov_region[1] = ls_region
	END IF
	
	ls_locu = dw_prov.object.prop_mb[1]
	select interlocuteur into :ls_data from interlocuteur where locu = :ls_locu using ESQLCA;
	IF f_check_sql(ESQLCA) = 0 THEN
		dw_prov.object.c_nom_prop[1] = ls_data
	END IF
	
	ls_locu = dw_prov.object.gest_mb_prive[1]
	select interlocuteur into :ls_data from interlocuteur where locu = :ls_locu using ESQLCA;
	IF f_check_sql(ESQLCA) = 0 THEN
		dw_prov.object.c_nom_gestprive[1] = ls_data
	END IF
	
	li_can = dw_prov.object.gest_mb_public[1]
	select cantonnement into :ls_data from cantonnement where can = :li_can using ESQLCA;
	IF f_check_sql(ESQLCA) = 0 THEN
		dw_prov.object.c_can_gest[1] = ls_data
	END IF

	li_can = dw_prov.object.sit_admin_mb[1]
	select cantonnement into :ls_data from cantonnement where can = :li_can using ESQLCA;
	IF f_check_sql(ESQLCA) = 0 THEN
		dw_prov.object.c_can_sit[1] = ls_data
	END IF
	
	ls_code = dw_prov.object.code_leg[1]
	select texte into :ls_data from legislation where code_leg = :ls_code using ESQLCA;
	IF f_check_sql(ESQLCA) = 0 THEN
		dw_prov.object.c_texte_leg[1] = ls_data
	END IF
END IF

// disabler la clé et enabler les datas
dw_prov.uf_enabledata()
dw_prov.uf_disablekeys()
dw_prov.SetColumn("code_prov")

wf_init_croise()

dw_prov.SetItemStatus(1,0,Primary!,NotModified!)

return(1)
end function

public function integer wf_init_croise (string as_item, string as_data);// activer/désactiver certains champs en fonction des autres
// Attention : on ne modifie aucune valeur ici
string	ls_type, ls_pays
decimal{2}	ld_alt1

CHOOSE CASE as_item
	// Si le pays de provenance n'est pas la Belgique, la présence dans la liste simplifiée du catalogue des MB
	// est impossible --> d'office NON et non modifiable. La remarque sur la liste du catalogue des MB 
	// est vide et non modifiable.
	// De +, si le pays est autre que la Belgique, il n'y a jamais de code provenance
	CASE "num_regprov"
		select pays into :ls_pays from region_prov where num_regprov = :as_data using ESQLCA;
		IF f_check_sql(ESQLCA) <> 0 THEN
			return(-1)
		END IF
		IF ls_pays = "BE" THEN
			dw_prov.uf_enableItems({"code_prov"})
			dw_prov.uf_enableItems({"presence_liste_mb"})
			dw_prov.Modify("presence_liste_mb.RadioButtons.3D=Yes") // aspect normal
		ELSE
			dw_prov.uf_disableItems({"code_prov"})
			dw_prov.uf_disableItems({"presence_liste_mb"})
			dw_prov.Modify("presence_liste_mb.RadioButtons.3D=No") // simule l'aspect disabled...
		END IF
		return(1)

	// Si présence dans liste simplifié du catalogue = "N", la remarque sur la liste du catalogue des MB 
	// est vide et non modifiable.
	CASE "presence_liste_mb"
		IF as_data = "O" THEN
			dw_prov.uf_enableItems({"remliste_mb"})
		ELSE
			dw_prov.uf_disableItems({"remliste_mb"})
		END IF
		return(1)
		
	// si le propriétaire est public, seul le type "Soumis" de NATURE_PROP est possible, 
	// et seul un GEST_MB_PUBLIC est possible (pas de GEST_MB_PRIVE)
	CASE "prop_mb"
		select type into :ls_type from interlocuteur where locu = :as_data using ESQLCA;
		IF f_check_sql(ESQLCA) <> 0 THEN
			return(-1)
		END IF
		IF ls_type = "PPU" THEN
			dw_prov.uf_disableItems({"nature_prop"})
			dw_prov.uf_disableItems({"gest_mb_prive"})
		ELSE
			dw_prov.uf_enableItems({"nature_prop"})
			dw_prov.uf_enableItems({"gest_mb_prive"})
		END IF
		return(1)

	// si pas de alt1, pas de alt2 possible
	CASE "alt1"
		ld_alt1 = dec(as_data)
		IF IsNull(ld_alt1) OR ld_alt1 = 0 THEN
			dw_prov.uf_disableItems({"alt2"})
		ELSE
			dw_prov.uf_enableItems({"alt2"})
		END IF
		
	// si la provenance n'est pas présente dans le dictionnaire des provenance, on ne met pas de réf. DNF
	CASE "presence_dict"
		IF as_data = "N" THEN
			dw_prov.uf_disableItems({"code_dnf_dict"})
		ELSE
			dw_prov.uf_enableItems({"code_dnf_dict"})
		END IF
	
	// origine : uniquement si autotochnie = "2"
	CASE "autotochnie"
		IF as_data <> "2" THEN
			dw_prov.uf_disableItems({"origine"})
		ELSE
			dw_prov.uf_enableItems({"origine"})
		END IF
		
END CHOOSE
return(1)
end function

public subroutine wf_init_croise ();wf_init_croise("prop_mb", string(dw_prov.object.prop_mb[1]))
wf_init_croise("alt1", string(dw_prov.object.alt1[1]))
wf_init_croise("presence_dict", string(dw_prov.object.presence_dict[1]))
wf_init_croise("autotochnie", string(dw_prov.object.autotochnie[1]))
wf_init_croise("num_regprov", string(dw_prov.object.num_regprov[1]))
wf_init_croise("presence_liste_mb", string(dw_prov.object.presence_liste_mb[1]))

end subroutine

public function integer wf_check_croise (string as_item, string as_data);// modifier certaine valeurs et activer/désactiver certains champs en fonction des autres
string	ls_type, ls_pays
decimal{2}	ld_alt1

CHOOSE CASE as_item
	// si le pays de provenance n'est pas la Belgique, la présence dans la liste simplifiée du catalogue des MB
	// est impossible --> d'office NON et non modifiable. 
	// De +, si le pays est autre que la Belgique, il n'y a jamais de code provenance
	CASE "num_regprov"
		select pays into :ls_pays from region_prov where num_regprov = :as_data using ESQLCA;
		IF f_check_sql(ESQLCA) <> 0 THEN
			return(-1)
		END IF
		IF ls_pays = "BE" THEN
			dw_prov.uf_enableItems({"code_prov"})
			dw_prov.uf_enableItems({"presence_liste_mb"})
			dw_prov.Modify("presence_liste_mb.RadioButtons.3D=Yes") // aspect normal
		ELSE
			dw_prov.uf_disableItems({"code_prov"})
			dw_prov.uf_setDefaultValue(1, "code_prov", "")
			dw_prov.uf_setDefaultValue(1, "presence_liste_mb", "N")
			dw_prov.uf_disableItems({"presence_liste_mb"})
			dw_prov.Modify("presence_liste_mb.RadioButtons.3D=No") // simule l'aspect disabled...
		END IF
		return(1)
	
	// Si présence dans liste simplifié du catalogue = "N", la remarque sur la liste du catalogue des MB 
	// est vide et non modifiable.
	CASE "presence_liste_mb"
		IF as_data = "O" THEN
			dw_prov.uf_enableItems({"remliste_mb"})
		ELSE
			dw_prov.uf_setDefaultValue(1, "remliste_mb", gu_c.s_null, string!)
			dw_prov.uf_disableItems({"remliste_mb"})
		END IF
		
	// si le propriétaire est public, seul le type "Soumis" de NATURE_PROP est possible, 
	// et seul un GEST_MB_PUBLIC est possible (pas de GEST_MB_PRIVE)
	CASE "prop_mb"
		select type into :ls_type from interlocuteur where locu = :as_data using ESQLCA;
		IF f_check_sql(ESQLCA) <> 0 THEN
			return(-1)
		END IF
		IF ls_type = "PPU" THEN
			dw_prov.uf_setDefaultValue(1, "nature_prop", "S")
			dw_prov.uf_setDefaultValue(1, "gest_mb_prive", gu_c.s_null, string!)
			dw_prov.uf_disableItems({"nature_prop"})
			dw_prov.uf_disableItems({"gest_mb_prive"})
		ELSE
			dw_prov.uf_enableItems({"nature_prop"})
			dw_prov.uf_enableItems({"gest_mb_prive"})
		END IF
		return(1)

	// si pas de alt1, pas de alt2 possible
	CASE "alt1"
		ld_alt1 = dec(as_data)
		IF IsNull(ld_alt1) OR ld_alt1 = 0 THEN
			dw_prov.uf_setDefaultValue(1, "alt2", gu_c.i_null, integer!)
			dw_prov.uf_disableItems({"alt2"})
		ELSE
			dw_prov.uf_enableItems({"alt2"})
		END IF
	
	// si la provenance n'est pas présente dans le dictionnaire des provenance, on ne met pas de réf. DNF
	CASE "presence_dict"
		IF as_data = "N" THEN
			dw_prov.uf_setDefaultValue(1, "code_dnf_dict", gu_c.s_null, string!)
			dw_prov.uf_disableItems({"code_dnf_dict"})
		ELSE
			dw_prov.uf_enableItems({"code_dnf_dict"})
		END IF
		
	// origine : uniquement si autotochnie = "2"	
	CASE "autotochnie"
		IF as_data <> "2" THEN
			dw_prov.uf_setDefaultValue(1, "origine", gu_c.s_null, string!)
			dw_prov.uf_disableItems({"origine"})
		ELSE
			dw_prov.uf_enableItems({"origine"})
		END IF

END CHOOSE
return(1)
end function

on w_provenance.create
int iCurrent
call super::create
this.dw_prov=create dw_prov
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_prov
end on

on w_provenance.destroy
call super::destroy
destroy(this.dw_prov)
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
	
	IF NOT dw_prov.uf_IsRecordNew() AND wf_canDelete() THEN
		li_item++
		ls_menu[li_item] = "m_supprimer"
	END IF
ELSE
	IF dw_prov.GetColumnName() = "num_prov" AND wf_canUpdate() THEN
		li_item++
		ls_menu[li_item] = "m_ajouter"
	END IF
END IF

f_menuaction(ls_menu)
end event

event ue_open;call super::ue_open;ibr_provenance = CREATE br_provenance
iu_cpteur = CREATE uo_cpteur

// icône "ajouter" doit être visible dans le menu
wf_SetItemsToShow({"m_ajouter"})

wf_SetDWList({dw_prov})
end event

event ue_close;call super::ue_close;DESTROY ibr_provenance
DESTROY iu_cpteur
end event

event ue_init_win;call super::ue_init_win;ib_ajout = FALSE
SetNull(is_codesp)
SetNull(ii_numprov)
iu_cpteur.uf_rollback()

this.setredraw(FALSE)

dw_prov.uf_reset()
dw_prov.insertrow(0)

dw_prov.uf_disabledata()
dw_prov.uf_enablekeys()
dw_prov.Setcolumn("code_sp")
dw_prov.setfocus()

this.setredraw(TRUE)
end event

event ue_supprimer;call super::ue_supprimer;string	ls_message

IF ibr_provenance.uf_check_beforedelete(is_codesp, ii_numprov, ls_message) = -1 THEN
	gu_message.uf_info(ls_message)
	return
END IF

IF f_confirm_del("Voulez-vous supprimer cette provenance ?") = 1 THEN
	IF dw_prov.event ue_delete() = 1 THEN
		wf_message("provenance supprimée avec succès")
		this.event ue_init_win()
	END IF
END IF

end event

event ue_enregistrer;call super::ue_enregistrer;integer	li_status

// contrôle de validité de tous les champs
IF dw_prov.event ue_checkall() < 0 THEN
	dw_prov.SetFocus()
	return(-1)
END IF

li_status = gu_dwservices.uf_updatetransact(dw_prov)
CHOOSE CASE li_status
	CASE 1
		wf_message("Provenance " + is_codesp + "/" + f_string(ii_numprov) + " enregistrée avec succès")
		// si nouvelle provenance, updater compteur
		IF dw_prov.uf_IsRecordNew() THEN
			IF iu_cpteur.uf_update_numprov(is_codesp, ii_numprov) = -1 THEN
				populateerror(20000, "")
				gu_message.uf_unexp("Erreur mise à jour du compteur PROVENANCE.NUM_PROV")
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
		gu_message.uf_unexp("PROVENANCE : Erreur lors de la mise à jour de la base de données")
		return(-1)
END CHOOSE

end event

event ue_ajouter;call super::ue_ajouter;// ajouter une nouvelle fiche si le curseur est dans l'item NUM_PROV
IF dw_prov.GetColumnName() = "num_prov" THEN
	wf_newprov()
	return
END IF
end event

event ue_init_inactivewin;call super::ue_init_inactivewin;dw_prov.uf_setdefaultvalue(1, "code_sp", gu_c.s_null, string!)
end event

type ddlb_message from w_ancestor_dataentry`ddlb_message within w_provenance
integer y = 2032
end type

type dw_prov from uo_datawindow_singlerow within w_provenance
integer width = 3109
integer height = 2032
integer taborder = 10
boolean bringtotop = true
string dataobject = "d_provenance"
end type

event itemfocuschanged;call super::itemfocuschanged;parent.event post ue_init_menu()
end event

event ue_checkitem;call super::ue_checkitem;integer	li_status, li_numprov, li_code
long		ll_count
string	ls_code, ls_nom, ls_pays, ls_region 

as_message = ""

CHOOSE CASE as_item
	CASE "code_sp"
		IF ibr_provenance.uf_check_codesp(as_data, as_message) = -1 THEN
			return(-1)
		ELSE
			is_codesp = as_data
			this.object.c_nomfr_sp[al_row] = as_message
		END IF
		
	// dernier élément de la clé, vérifier si record existe ou pas
	CASE "num_prov"
		IF ibr_provenance.uf_check_numprov(as_data, as_message) = -1 THEN
			iu_cpteur.uf_rollback()
			return(-1)
		END IF
		li_numprov = long(as_data)
		select count(*) into :ll_count from provenance
				where code_sp = :is_codesp and num_prov=:li_numprov using ESQLCA;
		li_status = f_check_sql(ESQLCA)
		IF li_status < 0 OR ll_count > 1 THEN
			populateerror(20000,"")
			gu_message.uf_unexp("Erreur SELECT PROVENANCE")
			return(-1)
		ELSE
			// provenance inexistante...
			IF ll_count = 0 THEN
				// ...et on peut modifier les données...
				IF wf_canUpdate() THEN
					IF ib_ajout THEN
						this.uf_NewRecord(TRUE)
						ii_numprov = li_numprov
						return(1)
					ELSE
						as_message = "Provenance inexistante. Utilisez l'action 'Ajouter' pour en créer une."
						return(-1)
					END IF
				ELSE
				// ...et on ne peut pas modifier les données
					as_message = "Provenance inexistante. Vous n'avez pas le droit d'en créer..."
					return(-1)
				END IF
			ELSE
			// provenance existe déjà : OK
				this.uf_NewRecord(FALSE)
				ii_numprov = li_numprov
				return(1)
			END IF
		END IF
	
	CASE "presence_liste_mb"
		return(ibr_provenance.uf_check_presence_liste_mb(as_data, as_message, integer(this.object.num_regprov[1])))
		
	CASE "presence_dict"
		return(ibr_provenance.uf_check_presence_dict(as_data, as_message))
		
	CASE "code_dnf_dict"
		return(ibr_provenance.uf_check_code_dnf(as_data, as_message, this.object.presence_dict[1], is_codesp, ii_numprov))
		
	CASE "num_regprov"
		IF ibr_provenance.uf_check_num_regprov(as_data, as_message) = -1 THEN
			return(-1)
		ELSE
			li_code = integer(as_data)
			select code_regprov, nom, pays, region into :ls_code, :ls_nom, :ls_pays, :ls_region 
				from region_prov where num_regprov = :li_code using ESQLCA;
			IF f_check_sql(ESQLCA) = 0 THEN
				this.object.c_prov_code_regprov[1] = ls_code
				this.object.c_prov_nom[1] = ls_nom
				this.object.c_prov_pays[1] = ls_pays
				this.object.c_prov_region[1] = ls_region
			END IF
		END IF
		
	CASE "alt1"
		return(ibr_provenance.uf_check_alt1(as_data, as_message))
	CASE "alt2"
		return(ibr_provenance.uf_check_alt2(as_data, as_message, this.object.alt1[1]))
		
	CASE "nom"
		return(ibr_provenance.uf_check_nomprov(as_data, as_message))

	CASE "latitude"
		return(ibr_provenance.uf_check_latitude(as_data, as_message))
		
	CASE "longitude"
		return(ibr_provenance.uf_check_longitude(as_data, as_message))
		
	CASE "abattu"
		return(ibr_provenance.uf_check_abattu(as_data, as_message))
		
	CASE "fins"
		return(ibr_provenance.uf_check_fins(as_data, as_message))
		
	CASE "type_mb"
		return(ibr_provenance.uf_check_typemb(as_data, as_message))
		
	CASE "autotochnie"
		return(ibr_provenance.uf_check_autotochnie(as_data, as_message))
		
	CASE "categorie"
		return(ibr_provenance.uf_check_categorie(as_data, as_message))
		
	CASE "code_leg"
		IF ibr_provenance.uf_check_code_leg(as_data, as_message) = -1 THEN
			return(-1)
		ELSE
			this.object.c_texte_leg[1] = as_message
		END IF
		
	CASE "prop_mb"
		IF ibr_provenance.uf_check_prop_mb(as_data, as_message) = -1 THEN
			return(-1)
		ELSE
			this.object.c_nom_prop[1] = as_message
		END IF
		
	CASE "nature_prop"
		return(ibr_provenance.uf_check_nature_prop(as_data, as_message))
		
	CASE "gest_mb_prive"
		IF ibr_provenance.uf_check_gest_mb_prive(as_data, as_message, integer(this.object.gest_mb_public[1])) = -1 THEN
			return(-1)
		ELSE
			this.object.c_nom_gestprive[1] = as_message
		END IF
		
	CASE "gest_mb_public"
		IF ibr_provenance.uf_check_gest_mb_public(as_data, as_message, string(this.object.gest_mb_prive[1])) = -1 THEN
			return(-1)
		ELSE
			this.object.c_can_gest[1] = as_message
		END IF
		
	CASE "sit_admin_mb"
		IF ibr_provenance.uf_check_sit_admin_mb(as_data, as_message) = -1 THEN
			return(-1)
		ELSE
			this.object.c_can_sit[1] = as_message
		END IF
END CHOOSE

return(1)
end event

event ue_leavekey;call super::ue_leavekey;// quand on quitte la clé, cela veut dire qu'on dispose de données actives dans la fenêtre
wf_actif(true)

// effacer les messages
ddlb_message.reset()

// lecture du record si existe déjà
IF NOT this.uf_IsRecordNew() THEN
	wf_message("Modification d'une provenance...")
	this.retrieve(is_codesp, ii_numprov)
ELSE
	wf_message("Nouvelle provenance...")
END IF

parent.event ue_init_menu()
post wf_init()

end event

event ue_help;call super::ue_help;str_params	lstr_params

IF al_row = 0 THEN return
IF NOT IsValid(idwo_currentItem) THEN return
IF IsNull(idwo_currentItem) THEN return

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
	
	CASE "num_prov"
		lstr_params.a_param[1] = is_codesp
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
		
	CASE "num_regprov"
		open(w_l_regprov)
		IF Message.DoubleParm = -1 THEN 
			return
		ELSE
			lstr_params=Message.PowerObjectParm
			this.SetText(string(lstr_params.a_param[1]))
			f_presskey("tab")
		END IF
		
	CASE "code_leg"
		open(w_l_legislation)
		IF Message.DoubleParm = -1 THEN 
			return
		ELSE
			lstr_params=Message.PowerObjectParm
			this.SetText(string(lstr_params.a_param[1]))
			f_presskey("tab")
		END IF
		
	CASE "prop_mb"
		// types d'interlocuteurs autorisés : propriétaires privés ou public
		lstr_params.a_param[1] = "'PPR','PPU'"
		lstr_params.a_param[2] = FALSE
		openwithparm(w_l_locu, lstr_params)
		IF Message.DoubleParm = -1 THEN 
			return
		ELSE
			lstr_params=Message.PowerObjectParm
			this.SetText(string(lstr_params.a_param[1]))
			f_presskey("tab")
		END IF
		
	CASE "gest_mb_prive"
		// types d'interlocuteurs autorisés : gestionnaires
		lstr_params.a_param[1] = "'G'"
		lstr_params.a_param[2] = FALSE
		openwithparm(w_l_locu, lstr_params)
		IF Message.DoubleParm = -1 THEN 
			return
		ELSE
			lstr_params=Message.PowerObjectParm
			this.SetText(string(lstr_params.a_param[1]))
			f_presskey("tab")
		END IF
		
	CASE "gest_mb_public"
		open(w_l_can)
		IF Message.DoubleParm = -1 THEN return
		lstr_params=Message.PowerObjectParm
		this.SetText(string (lstr_params.a_param[1]))
		f_presskey("tab")
		
	CASE "sit_admin_mb"
		open(w_l_can)
		IF Message.DoubleParm = -1 THEN return
		lstr_params=Message.PowerObjectParm
		this.SetText(string (lstr_params.a_param[1]))
		f_presskey("tab")
		
END CHOOSE


end event

event ue_itemvalidated;call super::ue_itemvalidated;wf_check_croise(as_name, as_data)
end event

event doubleclicked;call super::doubleclicked;string	ls_url

// ouverture du fichier renseigné dans le champ CARTE_SCAN
IF row = 0 THEN return
IF dwo.name <> "carte_scan" THEN return
IF f_IsEmptyString(this.object.carte_scan[row]) THEN return
ls_url = this.object.carte_scan[row]
f_openlink(ls_url)

end event

