//objectcomments Encodage des certificats-maître
forward
global type w_certificat from w_ancestor_dataentry
end type
type dw_cm_key from uo_datawindow_singlerow within w_certificat
end type
type tab_1 from tab within w_certificat
end type
type tabpage_cm from userobject within tab_1
end type
type dw_cm from uo_datawindow_singlerow within tabpage_cm
end type
type tabpage_cm from userobject within tab_1
dw_cm dw_cm
end type
type tabpage_lot from userobject within tab_1
end type
type st_reflot from uo_statictext within tabpage_lot
end type
type st_2 from uo_statictext within tabpage_lot
end type
type st_1 from uo_statictext within tabpage_lot
end type
type dw_melange from uo_ancestor_dwbrowse within tabpage_lot
end type
type tabpage_lot from userobject within tab_1
st_reflot st_reflot
st_2 st_2
st_1 st_1
dw_melange dw_melange
end type
type tabpage_clone from userobject within tab_1
end type
type dw_clone from uo_datawindow_multiplerow within tabpage_clone
end type
type tabpage_clone from userobject within tab_1
dw_clone dw_clone
end type
type tab_1 from tab within w_certificat
tabpage_cm tabpage_cm
tabpage_lot tabpage_lot
tabpage_clone tabpage_clone
end type
end forward

global type w_certificat from w_ancestor_dataentry
integer width = 3063
integer height = 2380
string title = "Certificats-maître"
boolean resizable = true
event ue_print ( )
dw_cm_key dw_cm_key
tab_1 tab_1
end type
global w_certificat w_certificat

type variables
string			is_numcm, is_logfile

br_certificat	ibr_certificat
dw_cm				idw_cm
dw_clone			idw_clone
dw_melange		idw_melange
end variables

forward prototypes
public function integer wf_init ()
public function integer wf_logdelete (string as_message)
public function integer wf_newclone ()
public subroutine wf_deleteallclones ()
public subroutine wf_init_onglet_clone (string as_typemfr)
public function integer wf_setkey (string as_cm)
public subroutine wf_print ()
end prototypes

event ue_print();wf_print()
end event

public function integer wf_init ();integer	li_anaut, li_numaut, li_numprov, li_numregprov, li_anmaturite
string	ls_codesp, ls_nom, ls_reflot, ls_nomprov, ls_coderegprov, ls_nomregprov, ls_codeprov

tab_1.enabled = TRUE

IF dw_cm_key.uf_IsRecordNew() THEN
	// valeurs par défaut pour nouveau record
	idw_cm.uf_setDefaultValue(1, "melange", "N")
	idw_cm.uf_setDefaultValue(1, "subdiv_lot", "N")
	idw_cm.uf_setDefaultValue(1, "reprod_vegetative", "N")
	idw_cm.uf_setDefaultValue(1, "pollinisation", "0")
	idw_cm.uf_setDefaultValue(1, "qte_mfr", 0)
ELSE
	// lecture du code de l'espèce dans l'autorisation de récolte
	// 12/11/08 : lecture de l'année de maturité
	li_anaut = idw_cm.object.an_aut[1]
	li_numaut = idw_cm.object.num_aut[1]
	select code_sp, num_prov, an_maturite into :ls_codesp, :li_numprov, :li_anmaturite from autorisation 
		where an_aut = :li_anaut and num_aut = :li_numaut using ESQLCA;
	IF f_check_sql(ESQLCA) <> 0 THEN
		gu_message.uf_error("Erreur lecture AUTORISATION n° " + f_string(li_anaut) + "/" + f_string(li_numaut))
	ELSE
		idw_cm.object.c_codesp[1] = ls_codesp
		idw_cm.object.c_anmaturite[1] = li_anmaturite
//		// lecture du nom latin de l'espèce
// 01/10/2008 : on affiche plus le nom de l'espèce, AS préfère avoir des infos sur la provenance
//		select nom_lat into :ls_nom from espece where code_sp = :ls_codesp using ESQLCA;
//		IF f_check_sql(ESQLCA) <> 0 THEN
//			gu_message.uf_error("Erreur lecture ESPECE n° " + f_string(ls_codesp))
//		ELSE
//			idw_cm.object.c_nomespece[1] = ls_nom
//		END IF
		// lecture des infos sur la provenance et région de provenance
		select num_regprov, nom, code_prov into :li_numregprov, :ls_nomprov , :ls_codeprov
			from provenance where code_sp = :ls_codesp and num_prov = :li_numprov using ESQLCA;
		IF f_check_sql(ESQLCA) <> 0 THEN
			gu_message.uf_error("Erreur lecture PROVENANCE n° " + ls_codesp + "/" + f_string(li_numprov))
		ELSE
			idw_cm.object.c_nomprov[1] = ls_nomprov
			idw_cm.object.c_codeprov[1] = ls_codeprov
			select code_regprov, nom into :ls_coderegprov, :ls_nomregprov
				from region_prov where num_regprov = :li_numregprov using ESQLCA;
			IF f_check_sql(ESQLCA) <> 0 THEN
				gu_message.uf_error("Erreur lecture REGION_PROV n° " + f_string(li_numregprov))
			ELSE
				idw_cm.object.c_coderegprov[1] = ls_coderegprov
				idw_cm.object.c_nomregprov[1] = ls_nomregprov
			END IF
		END IF
	END IF
	
	// lecture des clones
	idw_clone.retrieve(is_numcm)
	
	// lecture des mélanges
	idw_melange.retrieve(is_numcm)

END IF
idw_cm.SetItemStatus(1,0,Primary!,NotModified!)

// enabler/disabler l'onglet clone
wf_init_onglet_clone(dw_cm_key.object.type_mfr[1])

// disabler la clé et enabler les datas
idw_cm.uf_enabledata()
idw_cm.SetColumn("com_mfr")

dw_cm_key.uf_enabledata()
dw_cm_key.uf_disablekeys()
dw_cm_key.post SetFocus()

// si le certificat est utilisée dans un lot, certains champs ne sont plus modifiables
select ref_lot into :ls_reflot from registre where num_cm=:is_numcm using ESQLCA;
IF ESQLCA.SQLnRows > 0 THEN
	tab_1.tabpage_lot.st_reflot.text = ls_reflot
	idw_cm.uf_disableItems({"an_aut", "num_aut"})
END IF

// si le certificat est un mélange, la qté a été mise à jours lors du mélanger et n'est pas modifiable
IF idw_cm.object.melange[1] <> "N" THEN
	idw_cm.uf_disableItems({"qte_mfr"})
END IF

tab_1.enabled = TRUE

return(1)
end function

public function integer wf_logdelete (string as_message);// Enregistre le message passé en paramètre dans le fichier d'enregistrement des certificats effacés
// Dans l'appel à la fonction logmessage, on demande un plafonnement de la taille du fichier à 1Mo
integer	li_stat

li_stat = gu_logmessage.uf_logmessage(is_logfile, as_message, 1000, TRUE)

return(li_stat)

end function

public function integer wf_newclone ();// création d'une nouvelle ligne de clone
// return(-1) si erreur
// return(n° de row ajoutée) si OK
long		ll_row
integer	li_num

ll_row = idw_clone.event ue_addrow()
IF ll_row <= 0 THEN
	return(-1)
END IF

// initialiser 1ère partie de la PK
idw_clone.object.num_cm[ll_row] = is_numcm

// numérotation auto.
li_num = idw_clone.object.c_maxnum[ll_row]
IF IsNull(li_num) THEN 
	li_num = 1
ELSE
	li_num++
END IF		

IF li_num > 0 AND li_num <= 999 THEN 
	idw_clone.object.num_clone[ll_row] = li_num
	idw_clone.SetColumn("clone")
ELSE
	idw_clone.SetColumn("num_clone")
END IF

idw_clone.SetFocus()

return(ll_row)
end function

public subroutine wf_deleteallclones ();// supprimer toutes les lignes "clone" pour les certificat qui ne sont pas de ce type
long	ll_row

FOR ll_row = idw_clone.RowCount() TO 1 STEP -1
	idw_clone.deleteRow(ll_row)
NEXT
end subroutine

public subroutine wf_init_onglet_clone (string as_typemfr);// disable onglet 'clone' pour les certificats qui ne sont pas de ce type
IF as_typemfr = "3" THEN
	tab_1.tabpage_clone.enabled = TRUE
ELSE
	tab_1.tabpage_clone.enabled = FALSE
	tab_1.selectTab(1)
END IF

end subroutine

public function integer wf_setkey (string as_cm);// utilisé par un programme externe pour ouvrir un CM
IF f_isEmptyString(as_cm) THEN
	return(-1)
END IF

IF dw_cm_key.uf_SetDefaultValue(1, "num_cm", as_cm) < 0 THEN return(-1)

return(1)
end function

public subroutine wf_print ();// impression du certificat en cours
str_params	lstr_params
long	ll_count

IF f_isEmptyString(is_numcm) THEN
	gu_message.uf_info("Veuillez d'abord afficher le certificat")
	return
END IF

select count(*) into :ll_count from CERTIFICAT where num_cm=:is_numcm using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	return
END IF
IF ll_count = 0 THEN
	gu_message.uf_info("Vous devez d'abord enregistrer le certificat avant de pouvoir l'imprimer")
	return
END IF

IF IsValid(w_rpt_certificat) THEN
	close(w_rpt_certificat)
END IF

lstr_params.a_param[1] = dw_cm_key.object.type_mfr[1]
lstr_params.a_param[2] = is_numcm
OpenSheetWithParm(w_rpt_certificat, lstr_params, gw_mdiframe, 0, Original!)
IF IsValid(w_rpt_certificat) THEN
	w_rpt_certificat.SetFocus()
END IF
end subroutine

on w_certificat.create
int iCurrent
call super::create
this.dw_cm_key=create dw_cm_key
this.tab_1=create tab_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_cm_key
this.Control[iCurrent+2]=this.tab_1
end on

on w_certificat.destroy
call super::destroy
destroy(this.dw_cm_key)
destroy(this.tab_1)
end on

event ue_open;call super::ue_open;integer	li_status

// nom du fichier LOG des suppressions de certificat
is_logfile = gs_cenpath + "\CertificatsEffaces.log"

ibr_certificat = CREATE br_certificat

// initialisation des pointeurs vers les DW
idw_cm = tab_1.tabpage_cm.dw_cm
idw_clone = tab_1.tabpage_clone.dw_clone
idw_melange = tab_1.tabpage_lot.dw_melange

// ne pas créer automatiquement une nouvelle ligne 'clone' quand on supprime la dernière
idw_clone.uf_createwhenlastdeleted(FALSE)

// assigner les couleurs pour les lignes paires et impaires de dw_melange
gu_dwservices.uf_setbrowsecol(idw_melange)

// partage des données
li_status = dw_cm_key.ShareData(idw_cm)
IF li_status = -1 THEN
	wf_executePostOpen(FALSE)
	populateerror(20000,"")
	gu_message.uf_unexp("idw_cm_data : partage des données dw_cm_key impossible")
	post close(this)
	return
END IF

// icône "ajouter" doit être visible dans le menu
wf_SetItemsToShow({"m_ajouter"})

// DW à mettre à jour
wf_SetDWList({idw_cm, idw_clone})

end event

event ue_close;call super::ue_close;dw_cm_key.ShareDataOff()

DESTROY ibr_certificat
end event

event ue_init_menu;call super::ue_init_menu;string	ls_menu[]
integer	li_item

li_item = 1
ls_menu = {"m_fermer"}

IF wf_IsActif() THEN
	li_item++
	ls_menu[li_item] = "m_abandonner"
	IF wf_canUpdate() THEN
		li_item++
		ls_menu[li_item] = "m_enregistrer"
	END IF
	CHOOSE CASE wf_GetActivecontrolname()
		// menu si le curseur est dans le DW hors de l'onglet (dw_cm_key) ou sur le DW de l'onglet CERTIFICAT
		CASE "dw_cm_key", "dw_cm"
			IF NOT dw_cm_key.uf_IsRecordNew() AND wf_canDelete() THEN
				li_item++
				ls_menu[li_item] = "m_supprimer"
			END IF

		// menu si curseur est sur le DW de l'onglet CLONES
		CASE "dw_clone"
			IF wf_canUpdate() THEN
				li_item++
				ls_menu[li_item] = "m_ajouter"
				li_item++
				ls_menu[li_item] = "m_supprimer"				
			END IF
	
	END CHOOSE
END IF

f_menuaction(ls_menu)


end event

event ue_init_win;call super::ue_init_win;this.setredraw(FALSE)
tab_1.enabled = FALSE
tab_1.selecttab(1)
SetNull(is_numcm)

tab_1.tabpage_clone.enabled = FALSE

dw_cm_key.uf_reset()
idw_cm.uf_reset()
idw_clone.uf_reset()
idw_melange.uf_reset()
tab_1.tabpage_lot.st_reflot.text = "Aucun"

dw_cm_key.insertrow(0)
dw_cm_key.object.num_cm[1] =  "BRW"
dw_cm_key.uf_disabledata()
dw_cm_key.uf_enablekeys()
dw_cm_key.enabled = TRUE

idw_cm.uf_disabledata()

this.setredraw(TRUE)

dw_cm_key.setfocus()


end event

event resize;call super::resize;tab_1.width = newwidth
tab_1.height = newheight - 356

IF isValid(idw_clone) THEN
	idw_clone.height = tab_1.tabpage_clone.height - 8
	idw_clone.x = tab_1.tabpage_clone.width / 2 - (idw_clone.width / 2)
END IF

IF isValid(idw_melange) THEN idw_melange.height = tab_1.tabpage_lot.height - 108
	


end event

event ue_enregistrer;call super::ue_enregistrer;integer	li_status

// RAZ certains champs en fonction du type de certificat
CHOOSE CASE dw_cm_key.object.type_mfr[1]
	CASE "1"
		dw_cm_key.object.pollinisation[1] = "0"
		dw_cm_key.object.famille_composant[1] = gu_c.i_null
		dw_cm_key.object.clone_composant[1] = gu_c.i_null
		dw_cm_key.object.hybridation[1] = gu_c.s_null
		dw_cm_key.object.pc_hybridation[1] = gu_c.d_null
		dw_cm_key.object.nb_clone_mel[1] = gu_c.i_null
		dw_cm_key.object.pc_clone_mel[1] = gu_c.d_null
		dw_cm_key.object.info_clone[1] = gu_c.s_null
		wf_deleteAllClones()
	CASE "2"
		dw_cm_key.object.nb_clone_mel[1] = gu_c.i_null
		dw_cm_key.object.pc_clone_mel[1] = gu_c.d_null
		dw_cm_key.object.info_clone[1] = gu_c.s_null
		wf_deleteAllClones()
	CASE "3"
		dw_cm_key.object.pollinisation[1] = "0"
		dw_cm_key.object.famille_composant[1] = gu_c.i_null
		dw_cm_key.object.clone_composant[1] = gu_c.i_null
		dw_cm_key.object.hybridation[1] = gu_c.s_null
		dw_cm_key.object.pc_hybridation[1] = gu_c.d_null
		dw_cm_key.object.reprod_vegetative[1] = "N"
		dw_cm_key.object.melange[1] = "N"
END CHOOSE
IF dw_cm_key.object.subdiv_lot[1] = "N" THEN
	dw_cm_key.object.num_cm_div[1] = gu_c.s_null
	dw_cm_key.object.rem_div[1] = gu_c.s_null
	dw_cm_key.object.qte_lot_initial[1] = gu_c.d_null
END IF
IF dw_cm_key.object.melange[1] = "N" THEN
	dw_cm_key.object.info_melange[1] = gu_c.s_null
END IF
IF dw_cm_key.object.reprod_vegetative[1] = "N" THEN
	dw_cm_key.object.meth_reprod[1] = gu_c.s_null
	dw_cm_key.object.nb_cycle[1] = gu_c.i_null
END IF

// contrôle de validité de tous les champs
IF dw_cm_key.event ue_checkall() < 0 THEN
	dw_cm_key.SetFocus()
	return(-1)
END IF

IF idw_cm.event ue_checkall() < 0 THEN
	tab_1.selecttab("tabpage_cm")
	idw_cm.SetFocus()
	return(-1)
END IF

IF idw_clone.event ue_checkall() < 0 THEN
	tab_1.selecttab("tabpage_clone")
	idw_clone.SetFocus()
	return(-1)
END IF

li_status = gu_dwservices.uf_updatetransact(idw_cm, idw_clone)
CHOOSE CASE li_status
	CASE 1
		wf_message("Certificat-maître " + is_numcm + " enregistré avec succès")
		This.event ue_init_win()
		return(1)
	CASE -1
		populateerror(20000,"")
		gu_message.uf_unexp("CERTIFICAT : Erreur lors de la mise à jour de la base de données")
		return(-1)
	CASE -2
		populateerror(20000,"")
		gu_message.uf_unexp("CM_CLONE : Erreur lors de la mise à jour de la base de données")
		return(-1)
END CHOOSE

return(1)
end event

event ue_supprimer;call super::ue_supprimer;string	ls_message
date		ldt_date
integer	li_num
long		ll_row

CHOOSE CASE wf_GetActivecontrolname()
	// suppression de tout le certificat, avec LOG du motif de la suppression
	CASE "dw_cm_key", "dw_cm"
		IF ibr_certificat.uf_check_beforedelete(is_numcm, ls_message) = -1 THEN
			gu_message.uf_info(ls_message)
			return
		END IF
		Open(w_certificat_confirmdel)
		IF Message.doubleparm = 2 THEN 
			return
		END IF
		ls_message = Message.Stringparm
		IF idw_cm.event ue_delete() = 1 THEN
			wf_logdelete("Certificat " + string(is_numcm) + " effacé.~nMotif : " + ls_message)
			// normalement, les "many" sont supprimés par les contraintes mais...
			delete cm_clone where num_cm = :is_numcm using ESQLCA;
			IF f_check_sql(ESQLCA) = 0 AND ESQLCA.sqlnrows <> 0 THEN
				commit using ESQLCA;
				populateerror(20000,"")
				gu_message.uf_unexp("Les contraintes d'intégrité entre CERTIFICAT et CM_CLONE ne sont pas actives !", 2)
			END IF
			delete cm_melange where num_cm = :is_numcm using ESQLCA;
			IF f_check_sql(ESQLCA) = 0 AND ESQLCA.sqlnrows <> 0 THEN
				commit using ESQLCA;
				populateerror(20000,"")
				gu_message.uf_unexp("Les contraintes d'intégrité entre CERTIFICAT et CM_MELANGE ne sont pas actives !", 2)
			END IF
			// remarque : commit ou rollback nécessaire après les delete ci-dessus, même s'ils n'ont aucun effet !
			// Si on ne le fait pas, les LOCK subsistent !
			commit using ESQLCA;
			wf_message("Certificat-maître supprimé avec succès")
			this.event ue_init_win()
		END IF
		
	// suppression d'une ligne CLONE
		CASE "dw_clone"
			ll_row = idw_clone.GetRow()
			IF ll_row <= 0 THEN return
			IF f_confirm_del("Voulez-vous supprimer le clone " + &
					 string(idw_clone.object.num_clone[ll_row]) + &
					 " : " + f_string(idw_clone.object.clone[ll_row]) + " ?") = 1 THEN
			IF idw_clone.event ue_delete() = 1 THEN
				wf_message("Clone supprimé avec succès")
			END IF
		END IF
END CHOOSE

end event

event ue_ajouter;call super::ue_ajouter;CHOOSE CASE wf_GetActivecontrolname()
	// ajouter une nouvelle ligne de clone
	CASE "dw_clone"
		wf_newclone()
END CHOOSE
end event

type ddlb_message from w_ancestor_dataentry`ddlb_message within w_certificat
integer y = 2192
end type

type dw_cm_key from uo_datawindow_singlerow within w_certificat
integer x = 18
integer width = 2999
integer height = 256
integer taborder = 10
boolean bringtotop = true
string dataobject = "d_certificat_key"
end type

event ue_help;call super::ue_help;str_params	lstr_params

IF NOT isValid(idwo_currentItem) THEN return
IF isNull(idwo_currentItem) THEN return

CHOOSE CASE idwo_currentItem.name
	CASE "num_cm"
		open(w_l_certificat)
		IF Message.DoubleParm = -1 THEN 
			return
		ELSE
			lstr_params=Message.PowerObjectParm
			this.SetText(f_string(lstr_params.a_param[1]))
			f_presskey("TAB")
		END IF
END CHOOSE


end event

event ue_checkitem;call super::ue_checkitem;integer	li_status
long		ll_count

CHOOSE CASE as_item
	CASE "num_cm"
		IF ibr_certificat.uf_check_cm(as_data, as_message) = -1 THEN
			return(-1)
		ELSE
			is_numcm = as_data
		END IF
		
		// dernier élément de la clé, vérifier si record existe ou pas		
		select count(*) into :ll_count from certificat
				where num_cm = :is_numcm using ESQLCA;
		li_status = f_check_sql(ESQLCA)
		IF li_status < 0 OR ll_count > 1 THEN
			populateerror(20000,"")
			gu_message.uf_unexp("Erreur SELECT CERTIFICAT")
			return(-1)
		ELSE
			// CM inexistant...
			IF ll_count = 0 THEN
				// ...et on peut modifier les données...
				IF wf_canUpdate() THEN
					this.uf_NewRecord(TRUE)
					return(1)
				ELSE
				// ...et on ne peut pas modifier les données
					as_message = "Certificat inexistant. Vous n'avez pas le droit d'en créer..."
					return(-1)
				END IF
			ELSE
			// CM existe déjà : OK
				this.uf_NewRecord(FALSE)
				return(1)
			END IF
		END IF
		
	CASE "type_mfr"
		return(ibr_certificat.uf_check_typemfr(as_data, as_message))

END CHOOSE
return(1)

end event

event ue_leavekey;call super::ue_leavekey;// quand on quitte la clé, cela veut dire qu'on dispose de données actives dans la fenêtre
wf_actif(true)

// effacer les messages
ddlb_message.reset()

// lecture du record si existe déjà
IF NOT this.uf_IsRecordNew() THEN
	wf_message("Modification d'un certificat...")
	this.retrieve(is_numcm)
ELSE
	wf_message("Nouveau certificat...")
END IF

parent.event ue_init_menu()
post wf_init()

end event

event getfocus;call super::getfocus;w_ancestor_dataentry	lw_parent

// réactualiser le menu car l'option 'ajouter' n'est pas toujours disponible
IF f_GetParentWindow(this, lw_parent) = 1 THEN
	lw_parent.event ue_init_menu()
END IF

end event

event ue_itemvalidated;call super::ue_itemvalidated;wf_init_onglet_clone(as_data)
end event

type tab_1 from tab within w_certificat
event ue_focusondw ( )
integer y = 256
integer width = 3017
integer height = 1920
integer taborder = 20
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long backcolor = 67108864
boolean raggedright = true
boolean focusonbuttondown = true
boolean boldselectedtext = true
integer selectedtab = 1
tabpage_cm tabpage_cm
tabpage_lot tabpage_lot
tabpage_clone tabpage_clone
end type

event ue_focusondw();w_ancestor_dataentry	lw_parent

CHOOSE CASE This.SelectedTab
	CASE 1
		idw_cm.SetFocus()
	CASE 2
		idw_melange.SetFocus()
	CASE 3
		idw_clone.SetFocus()
	CASE ELSE
		// réactualiser le menu car l'option 'ajouter' n'est pas toujours disponible
		IF f_GetParentWindow(this, lw_parent) = 1 THEN
			lw_parent.event ue_init_menu()
		END IF
END CHOOSE

end event

on tab_1.create
this.tabpage_cm=create tabpage_cm
this.tabpage_lot=create tabpage_lot
this.tabpage_clone=create tabpage_clone
this.Control[]={this.tabpage_cm,&
this.tabpage_lot,&
this.tabpage_clone}
end on

on tab_1.destroy
destroy(this.tabpage_cm)
destroy(this.tabpage_lot)
destroy(this.tabpage_clone)
end on

event rightclicked;window	lw_parent

IF f_getparentwindow(this,lw_parent) = 1 THEN
	f_PopupAction(lw_parent)
END IF
end event

event getfocus;This.event post ue_FocusOnDw()
end event

event selectionchanged;This.event post ue_FocusOnDw()
end event

type tabpage_cm from userobject within tab_1
integer x = 18
integer y = 108
integer width = 2981
integer height = 1796
long backcolor = 67108864
string text = "Certificat"
long tabtextcolor = 33554432
long picturemaskcolor = 536870912
dw_cm dw_cm
end type

on tabpage_cm.create
this.dw_cm=create dw_cm
this.Control[]={this.dw_cm}
end on

on tabpage_cm.destroy
destroy(this.dw_cm)
end on

type dw_cm from uo_datawindow_singlerow within tabpage_cm
integer y = 4
integer width = 2981
integer height = 1792
integer taborder = 11
string dataobject = "d_certificat"
borderstyle borderstyle = stylebox!
end type

event ue_help;call super::ue_help;str_params	lstr_params

IF NOT isValid(idwo_currentItem) THEN return
IF isNull(idwo_currentItem) THEN return

CHOOSE CASE idwo_currentItem.name
	CASE "an_aut"
		lstr_params.a_param[1] = 0
		lstr_params.a_param[2] = TRUE
		// ne pas montrer les autorisations déjà utilisées dans un certificat
		lstr_params.a_param[3] = "(an_aut, num_aut) not in (select an_aut, num_aut from certificat " + &
										 "where num_cm <> '" + is_numcm + "')"
		lstr_params.a_param[4] = FALSE
		openwithparm(w_l_autorisation, lstr_params)
		IF Message.DoubleParm = -1 THEN 
			return
		ELSE
			lstr_params=Message.PowerObjectParm
			this.SetText(f_string(lstr_params.a_param[1]))
			f_presskey("TAB")
		END IF

	CASE "num_aut"
		lstr_params.a_param[1] = integer(this.object.an_aut[1])
		lstr_params.a_param[2] = TRUE
		// ne pas montrer les autorisations déjà utilisées dans un certificat
		lstr_params.a_param[3] = "(an_aut, num_aut) not in (select an_aut, num_aut from certificat " + &
										 "where num_cm <> '" + is_numcm + "')"
		lstr_params.a_param[4] = FALSE
		openwithparm(w_l_autorisation, lstr_params)
		IF Message.DoubleParm = -1 THEN 
			return
		ELSE
			lstr_params=Message.PowerObjectParm
			this.uf_setdefaultvalue(1, "an_aut", integer(lstr_params.a_param[1]))
			this.SetText(f_string(lstr_params.a_param[2]))
			f_presskey("TAB")
		END IF
		
	CASE "num_cm_div"
		open(w_l_certificat)
		IF Message.DoubleParm = -1 THEN 
			return
		ELSE
			lstr_params=Message.PowerObjectParm
			this.SetText(f_string(lstr_params.a_param[1]))
			f_presskey("TAB")
		END IF
END CHOOSE


end event

event ue_itemvalidated;call super::ue_itemvalidated;string	ls_codesp, ls_nom, ls_nomprov, ls_coderegprov, ls_nomregprov, ls_codeprov, ls_typeaut
integer	li_anaut, li_numaut, li_numprov, li_numregprov, li_anmaturite
decimal{3}	ld_qte

CHOOSE CASE as_name
	CASE "an_aut"
		this.uf_setdefaultvalue(1, "num_aut", gu_c.i_null, integer!)
	CASE "subdiv_lot"
		IF as_data = "N" THEN
			dw_cm_key.object.num_cm_div[1] = gu_c.s_null
			dw_cm_key.object.rem_div[1] = gu_c.s_null
			dw_cm_key.object.qte_lot_initial[1] = gu_c.d_null
		END IF
	CASE "melange"
		IF as_data = "N" THEN
			dw_cm_key.object.info_melange[1] = gu_c.s_null
		END IF

	CASE "num_aut"
		li_anaut = integer(this.object.an_aut[al_row])
		li_numaut = integer(as_data)
		IF IsNull(li_numaut) THEN
			this.object.c_nomespece[al_row] = gu_c.s_null
			return
		END IF
		// lire le code de l'espèce et n° de provenance dans l'autorisation
		// 06/11/2008 : lire aussi la qté autorisée et la recopier dans la qté de MFR si elle est vide
		// 12/11/08 : lecture de l'année de maturité
		// 13/11/08 : lire le type de mélange et le recopier dans le CM
		select code_sp, num_prov, qte_mfr_total, an_maturite, type_aut
				into :ls_codesp, :li_numprov, :ld_qte, :li_anmaturite, :ls_typeaut from autorisation
				where an_aut = :li_anaut and num_aut = :li_numaut using ESQLCA;
		IF f_check_sql(ESQLCA) <> 0 THEN
			gu_message.uf_error("ERREUR SELECT AUTORISATION")
			return
		END IF
		
		IF this.object.qte_mfr[1] = 0 THEN
			this.object.qte_mfr[1] = ld_qte
		END IF
		
		IF ls_typeaut = "R" THEN
			this.uf_setDefaultValue(1, "melange", "N")
		ELSE
			this.uf_setDefaultValue(1, "melange", ls_typeaut)
		END IF
		
		// 01/10/2008 : on affiche plus le nom de l'espèce, AS préfère avoir des infos sur la provenance
//		// lire le nom de l'espèce
//		select nom_lat into :ls_nom from espece where code_sp = :ls_codesp using ESQLCA;
//		IF f_check_sql(ESQLCA) <> 0 THEN
//			gu_message.uf_error("Erreur lecture ESPECE n° " + f_string(ls_codesp))
//			return
//		END IF
		this.object.c_codesp[al_row] = ls_codesp
		this.object.c_anmaturite[al_row] = li_anmaturite
		
		// lecture des infos sur la provenance et région de provenance
		select num_regprov, nom, code_prov into :li_numregprov, :ls_nomprov, :ls_codeprov
			from provenance where code_sp = :ls_codesp and num_prov = :li_numprov using ESQLCA;
		IF f_check_sql(ESQLCA) <> 0 THEN
			gu_message.uf_error("Erreur lecture PROVENANCE n° " + ls_codesp + "/" + f_string(li_numprov))
		ELSE
			idw_cm.object.c_nomprov[1] = ls_nomprov
			idw_cm.object.c_codeprov[1] = ls_codeprov
			select code_regprov, nom into :ls_coderegprov, :ls_nomregprov
				from region_prov where num_regprov = :li_numregprov using ESQLCA;
			IF f_check_sql(ESQLCA) <> 0 THEN
				gu_message.uf_error("Erreur lecture REGION_PROV n° " + f_string(li_numregprov))
			ELSE
				idw_cm.object.c_coderegprov[1] = ls_coderegprov
				idw_cm.object.c_nomregprov[1] = ls_nomregprov
			END IF
		END IF
END CHOOSE
end event

event ue_checkitem;call super::ue_checkitem;string	ls_typemfr

ls_typemfr = string(this.object.type_mfr[al_row])

CHOOSE CASE as_item
	CASE "com_mfr"
		return(ibr_certificat.uf_check_commfr(as_data, as_message))
	CASE "an_aut"
		return(ibr_certificat.uf_check_anaut(as_data, as_message))
	CASE "num_aut"
		return(ibr_certificat.uf_check_numaut(as_data, as_message, integer(this.object.an_aut[al_row]), &
				 ls_typemfr, is_numcm))
	CASE "nature_mfr"
		return(ibr_certificat.uf_check_naturemfr(as_data, as_message, ls_typemfr))
	CASE "qte_mfr"
		return(ibr_certificat.uf_check_qtemfr(as_data, as_message))
	CASE "tps_elevage"
		return(ibr_certificat.uf_check_tpselevage(as_data, as_message))
	CASE "subdiv_lot"
		return(ibr_certificat.uf_check_subdivlot(as_data, as_message))
	CASE "num_cm_div"
		return(ibr_certificat.uf_check_numcmdiv(as_data, as_message, this.object.subdiv_lot[al_row]))
	CASE "rem_div"
		return(ibr_certificat.uf_check_remdiv(as_data, as_message))
	CASE "qte_lot_initial"
		return(ibr_certificat.uf_check_qtelotinitial(as_data, as_message))
	CASE "reprod_vegetative"
		return(ibr_certificat.uf_check_reprodveget(as_data, as_message))
	CASE "meth_reprod"
		return(ibr_certificat.uf_check_methreprod(as_data, as_message))
	CASE "nb_cycle"
		return(ibr_certificat.uf_check_nbcycle(as_data, as_message))
	CASE "pollinisation"
		return(ibr_certificat.uf_check_pollinisation(as_data, as_message))
	CASE "famille_composant"
		return(ibr_certificat.uf_check_famillecomposant(as_data, as_message))
	CASE "clone_composant"
		return(ibr_certificat.uf_check_clonecomposant(as_data, as_message))
	CASE "hybridation"
		return(ibr_certificat.uf_check_hybridation(as_data, as_message))
	CASE "pc_hybridation"
		return(ibr_certificat.uf_check_pchybridation(as_data, as_message))
	CASE "nb_clone_mel"
		return(ibr_certificat.uf_check_nbclonemel(as_data, as_message))
	CASE "pc_clone_mel"
		return(ibr_certificat.uf_check_pcclonemel(as_data, as_message))
	CASE "info"
		return(ibr_certificat.uf_check_info(as_data, as_message))
	CASE "scan"
		return(ibr_certificat.uf_check_scan(as_data, as_message))
	CASE "melange"
		return(ibr_certificat.uf_check_melange(as_data, as_message))
		
END CHOOSE
return(1)
end event

event getfocus;call super::getfocus;w_ancestor_dataentry	lw_parent

// réactualiser le menu car l'option 'ajouter' n'est pas toujours disponible
IF f_GetParentWindow(this, lw_parent) = 1 THEN
	lw_parent.event ue_init_menu()
END IF

end event

event doubleclicked;call super::doubleclicked;string	ls_url

// ouverture du fichier renseigné dans le champ SCAN
IF row = 0 THEN return
IF dwo.name <> "scan" THEN return
IF f_IsEmptyString(this.object.scan[row]) THEN return
ls_url = this.object.scan[row]
f_openlink(ls_url)

end event

type tabpage_lot from userobject within tab_1
integer x = 18
integer y = 108
integer width = 2981
integer height = 1796
long backcolor = 67108864
string text = "Lot (et mélanges)"
long tabtextcolor = 33554432
long picturemaskcolor = 536870912
st_reflot st_reflot
st_2 st_2
st_1 st_1
dw_melange dw_melange
end type

on tabpage_lot.create
this.st_reflot=create st_reflot
this.st_2=create st_2
this.st_1=create st_1
this.dw_melange=create dw_melange
this.Control[]={this.st_reflot,&
this.st_2,&
this.st_1,&
this.dw_melange}
end on

on tabpage_lot.destroy
destroy(this.st_reflot)
destroy(this.st_2)
destroy(this.st_1)
destroy(this.dw_melange)
end on

type st_reflot from uo_statictext within tabpage_lot
integer x = 73
integer y = 228
integer height = 80
integer textsize = -9
integer weight = 700
string pointer = "HyperLink!"
string text = "Aucun"
alignment alignment = center!
boolean border = true
borderstyle borderstyle = stylelowered!
end type

event doubleclicked;call super::doubleclicked;// double-clic sur le n° de lot : ouvrir ce lot
string	ls_reflot
integer	li_status

ls_reflot = this.text
IF f_IsEmptyString(ls_reflot) OR ls_reflot = "Aucun" THEN return

IF NOT IsValid(w_registre) THEN
	OpenSheet(w_registre, gw_mdiframe, 0, Original!)
END IF
IF IsValid(w_registre) THEN
	w_registre.SetFocus()
	li_status = w_registre.event ue_abandonner()
	IF li_status = 3 OR li_status < 0 THEN
		return
	END IF
	w_registre.post wf_SetKey(ls_reflot)
END IF
end event

type st_2 from uo_statictext within tabpage_lot
integer y = 20
integer width = 585
integer height = 192
integer weight = 700
long textcolor = 8388608
string text = "Lot faisant référence au certificat :"
alignment alignment = center!
end type

type st_1 from uo_statictext within tabpage_lot
integer x = 1207
integer y = 20
integer width = 1371
integer weight = 700
long textcolor = 8388608
string text = "Composant(s) de ce lot (pour les mélanges) :"
alignment alignment = center!
end type

type dw_melange from uo_ancestor_dwbrowse within tabpage_lot
integer x = 622
integer y = 100
integer width = 2341
integer height = 1600
integer taborder = 11
string dataobject = "d_registre_est1melange"
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

event doubleclicked;call super::doubleclicked;string	ls_reflot, ls_cm
integer	li_status
w_ancestor_dataentry	l_parent

IF row = 0 THEN return

CHOOSE CASE dwo.name
	// double-clic sur le n° de lot : ouvrir ce lot
	CASE "registre_ref_lot"
		ls_reflot = dwo.Primary[row]
		IF f_IsEmptyString(ls_reflot) THEN return

		IF NOT IsValid(w_registre) THEN
			OpenSheet(w_registre, gw_mdiframe, 0, Original!)
		END IF
		IF IsValid(w_registre) THEN
			w_registre.SetFocus()
			li_status = w_registre.event ue_abandonner()
			IF li_status = 3 OR li_status < 0 THEN
				return
			END IF
			w_registre.post wf_SetKey(ls_reflot)
		END IF

	// double-clic sur le n° de CM : ouvrir ce CM
	CASE "cm_melange_num_cm_melange"
		ls_cm = dwo.Primary[row]
		IF f_IsEmptyString(ls_cm) THEN return
	
		// afficher CM sur lequel on a cliqué après avoir quitté celui en cours
		f_getparentwindow (this, l_parent)
		li_status = l_parent.event ue_abandonner()
		IF li_status = 3 OR li_status < 0 THEN
			return
		ELSE
			dw_cm_key.uf_SetDefaultValue(1, "num_cm", ls_cm)
		END IF
		
	CASE ELSE
		return
END CHOOSE
end event

type tabpage_clone from userobject within tab_1
integer x = 18
integer y = 108
integer width = 2981
integer height = 1796
long backcolor = 67108864
string text = "Composition clonale"
long tabtextcolor = 33554432
long picturemaskcolor = 536870912
dw_clone dw_clone
end type

on tabpage_clone.create
this.dw_clone=create dw_clone
this.Control[]={this.dw_clone}
end on

on tabpage_clone.destroy
destroy(this.dw_clone)
end on

type dw_clone from uo_datawindow_multiplerow within tabpage_clone
integer x = 677
integer y = 4
integer width = 1573
integer height = 1712
integer taborder = 11
string dataobject = "d_certificat_clone"
boolean vscrollbar = true
boolean border = true
end type

event getfocus;call super::getfocus;w_ancestor_dataentry	lw_parent

// réactualiser le menu car l'option 'ajouter' n'est pas toujours disponible
IF f_GetParentWindow(this, lw_parent) = 1 THEN
	lw_parent.event ue_init_menu()
END IF

end event

event ue_checkitem;call super::ue_checkitem;CHOOSE CASE as_item
	CASE "num_clone"
		IF ibr_certificat.uf_check_clone_num(as_data, as_message) = -1 THEN
			return(-1)
		ELSE
			IF gu_dwservices.uf_findduplicate(This, al_row, "num_clone=" + as_data) <> 0 THEN
				as_message = "Ce n° de ligne existe déjà"
				return(-1)
			END IF
		END IF
		return(1)
		
	CASE "clone"
		return(ibr_certificat.uf_check_clone_clone(as_data, as_message))
		
	CASE "pc_nb"
		return(ibr_certificat.uf_check_clone_pcnb(as_data, as_message))
	
END CHOOSE

return(1)
end event

