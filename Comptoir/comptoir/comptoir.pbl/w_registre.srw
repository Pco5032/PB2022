//objectcomments Gestion du registre des graines
forward
global type w_registre from w_ancestor_dataentry
end type
type dw_reg_key from uo_datawindow_singlerow within w_registre
end type
type tab_1 from tab within w_registre
end type
type tabpage_reg from userobject within tab_1
end type
type dw_reg from uo_datawindow_singlerow within tabpage_reg
end type
type tabpage_reg from userobject within tab_1
dw_reg dw_reg
end type
type tabpage_caract from userobject within tab_1
end type
type dw_qgerm from uo_datawindow_multiplerow within tabpage_caract
end type
type dw_cphys from uo_datawindow_multiplerow within tabpage_caract
end type
type tabpage_caract from userobject within tab_1
dw_qgerm dw_qgerm
dw_cphys dw_cphys
end type
type tabpage_flux from userobject within tab_1
end type
type dw_qtestock from uo_datawindow_singlerow within tabpage_flux
end type
type dw_lastinv from uo_datawindow_singlerow within tabpage_flux
end type
type dw_flux from uo_ancestor_dwbrowse within tabpage_flux
end type
type tabpage_flux from userobject within tab_1
dw_qtestock dw_qtestock
dw_lastinv dw_lastinv
dw_flux dw_flux
end type
type tabpage_inv from userobject within tab_1
end type
type dw_inv from uo_ancestor_dwbrowse within tabpage_inv
end type
type tabpage_inv from userobject within tab_1
dw_inv dw_inv
end type
type tabpage_cat from userobject within tab_1
end type
type st_pup from uo_statictext within tabpage_cat
end type
type dw_cat from uo_ancestor_dwbrowse within tabpage_cat
end type
type tabpage_cat from userobject within tab_1
st_pup st_pup
dw_cat dw_cat
end type
type tabpage_melange from userobject within tab_1
end type
type st_2 from uo_statictext within tabpage_melange
end type
type dw_estds1melange from uo_ancestor_dwbrowse within tabpage_melange
end type
type dw_est1melange from uo_ancestor_dwbrowse within tabpage_melange
end type
type st_1 from uo_statictext within tabpage_melange
end type
type tabpage_melange from userobject within tab_1
st_2 st_2
dw_estds1melange dw_estds1melange
dw_est1melange dw_est1melange
st_1 st_1
end type
type tab_1 from tab within w_registre
tabpage_reg tabpage_reg
tabpage_caract tabpage_caract
tabpage_flux tabpage_flux
tabpage_inv tabpage_inv
tabpage_cat tabpage_cat
tabpage_melange tabpage_melange
end type
end forward

global type w_registre from w_ancestor_dataentry
integer width = 3141
integer height = 2096
string title = "Registre des graines"
boolean resizable = true
event ue_print ( )
dw_reg_key dw_reg_key
tab_1 tab_1
end type
global w_registre w_registre

type variables
string		is_reflot, is_typeqte
boolean		ib_estDansUnMelange

dw_reg		idw_reg
dw_cphys		idw_cphys
dw_qgerm		idw_qgerm
dw_flux		idw_flux
dw_cat		idw_cat
dw_inv		idw_inv
dw_lastinv	idw_lastinv
dw_qtestock idw_qtestock
dw_est1melange	idw_est1melange
dw_estds1melange	idw_estds1melange
br_registre	ibr_registre

end variables

forward prototypes
public function integer wf_init ()
public function integer wf_setkey (string as_reflot)
public subroutine wf_print ()
public function integer wf_newcphys ()
public function integer wf_newqgerm ()
public subroutine wf_initcalcngv (long al_row)
end prototypes

event ue_print();wf_print()
end event

public function integer wf_init ();string	ls_nom, ls_codesp, ls_type, ls_numcm
integer	li_num, li_anaut, li_numaut
long		ll_row
decimal{3}	ld_qtecm, ld_qteaut
boolean	lb_melprov

tab_1.enabled = TRUE

idw_qtestock.insertRow(0)

IF dw_reg_key.uf_IsRecordNew() THEN
	// valeurs par défaut pour nouveau record
	dw_reg_key.uf_setdefaultvalue(1, "type_graine", "P")
	dw_reg_key.uf_setdefaultvalue(1, "num_cm", "BRW")
	dw_reg_key.uf_setdefaultvalue(1, "dt_creation", f_today())
	idw_reg.uf_setdefaultvalue(1, "qte_initiale", 0)
	idw_reg.uf_setdefaultvalue(1, "qte_admise", 0)
	idw_reg.uf_setdefaultvalue(1, "motif_derog", "0")
ELSE
	// lecture des traductions pour record existant
	ls_codesp = dw_reg_key.object.code_sp[1]
	select nom_fr, type_qte into :ls_nom, :is_typeqte from espece where code_sp = :ls_codesp using ESQLCA;
	IF f_check_sql(ESQLCA) = 0 THEN
		dw_reg_key.object.c_nomespece[1] = ls_nom
		idw_qgerm.object.c_typeqte.expression = "'" + is_typeqte + "'"
	ELSE
		idw_qgerm.object.c_typeqte.expression = "''"
	END IF
	
	// lecture nom provenance
	li_num = dw_reg_key.object.num_prov[1]
	select nom into :ls_nom from provenance where code_sp = :ls_codesp and num_prov = :li_num using ESQLCA;
	IF f_check_sql(ESQLCA) = 0 THEN
		dw_reg_key.object.c_nomprov[1] = ls_nom
	END IF
	
	// adapter titre du cadre au type de graine
	ls_type = dw_reg_key.object.type_graine[1]
	IF ls_type = "P" THEN
		dw_reg_key.object.gb_sp.text = 'Préparée'
		ELSEIF ls_type = "A" THEN
			dw_reg_key.object.gb_sp.text = 'Achat / Négoce'
		ELSEIF ls_type = "N" THEN
			dw_reg_key.object.gb_sp.text = 'Non soumise'
		ELSE
			dw_reg_key.object.gb_sp.text = ''
	END IF
	
	// si lot préparé, afficher qté du CM et de l'autorisation
	IF ls_type = "P" THEN
		ls_numcm = dw_reg_key.object.num_cm[1]
		select an_aut, num_aut, qte_mfr into :li_anaut, :li_numaut, :ld_qtecm 
			from certificat where num_cm = :ls_numcm using ESQLCA;
		IF f_check_sql(ESQLCA) <> 0 THEN
			gu_message.uf_error("ERREUR SELECT CERTIFICAT")
		ELSE
			select qte_mfr_total into :ld_qteaut 
				from autorisation	where an_aut = :li_anaut and num_aut = :li_numaut using ESQLCA;
				IF f_check_sql(ESQLCA) <> 0 THEN
					gu_message.uf_error("ERREUR SELECT AUTORISATION")
				END IF
		END IF
		dw_reg_key.object.c_qtecm[1] = ld_qtecm
		dw_reg_key.object.c_qteaut[1] = ld_qteaut
	END IF
	
	// lecture des caractéristiques physiques et qualités germinatives des graines de ce lot
	IF idw_cphys.retrieve(is_reflot) > 0 THEN 
		// sélectionner 1ère row de CPHYS
		idw_cphys.object.c_select[1] = 1
		// faire connaître PDS1000 et Pureté à dw_qgerm pour évaluation du NBGvivant/kilo
		// dans le cas où il n'est pas connu par un test de germination
		wf_initcalcngv(1)
	END IF
	idw_qgerm.retrieve(is_reflot)
	
	// lecture des flux sur ce lot
	IF idw_flux.retrieve(is_reflot) > 0 THEN
		// placer qté totale des flux dans le DW sur quantité en stock
		idw_qtestock.object.d_qteflux[1] = idw_flux.object.c_qtetot[1]
	ELSE
		idw_qtestock.object.d_qteflux[1] = 0
	END IF
	
	// lecture qté totale du dernier inventaire
	IF idw_lastinv.retrieve(is_reflot) = 0 THEN
		idw_lastinv.insertRow(0)
	END IF
	
	// lecture des catalogues sur ce lot
	idw_cat.retrieve(is_reflot)

	// lecture des inventaires sur ce lot
	idw_inv.retrieve(is_reflot)

	// lecture des composants (lots mélangés ou faisant partie d'un mélange)
	// + initialiser les variables qui indiquent si le lot est un mélange ou s'il est dans 1 mélange (ou les 2)
	ls_numcm = dw_reg_key.object.num_cm[1]
	idw_est1melange.retrieve(ls_numcm)
	idw_estds1melange.retrieve(ls_numcm)
	IF idw_estds1melange.rowCount() > 0 THEN
		ib_estDansUnMelange = TRUE
		// on a besoin de savoir si au moins un des mélanges dans lequel le lot se trouve
		// est un mélange de provenances
		FOR ll_row = 1 TO idw_estds1melange.rowCount()
			IF idw_estds1melange.object.registre_melange[ll_row] = "P" THEN
				lb_melprov = TRUE
				EXIT
			END IF
		NEXT
	END IF
	
	// placer la qté admise dans le DW 'qté en stock'
	idw_qtestock.object.d_qteadmise[1] = idw_reg.object.qte_admise[1]
	
	// bouton d'initialisation du texte pour la proportion des mélanges
	IF idw_reg.object.melange[1] <> "N" THEN
		idw_reg.object.b_calc.enabled = TRUE
	END IF
	
END IF
idw_reg.SetItemStatus(1,0,Primary!,NotModified!)

// disabler la clé et enabler les datas
idw_reg.uf_enabledata()
idw_reg.SetColumn("qte_initiale")

dw_reg_key.uf_enabledata()
dw_reg_key.uf_disablekeys()

// 12/11/2008 : l'année de maturité n'est accessible que pour les lot achetés. Pour les autres,
//     elle a été recopiée de l'autorisation de récolte.
// voir dans le DW object

// si le lot est un mélange, on ne peut pas modifier sa quantité admise car elle a été (ou sera) calculée 
// lors de la composition du mélange (=somme des quantités mélangées).
IF idw_reg.object.melange[1] <> "N" THEN
	idw_reg.uf_disableItems({"qte_admise"})
END IF
// Si le lot est DANS un mélange ou est lui-même un mélange :
//		. on ne peut plus modifier son CM
//		. si le lot est dans un mélange de provenances, on ne peut plus modifier son ANNEE de maturité
IF ib_estDansUnMelange OR idw_reg.object.melange[1] <> "N" THEN
	dw_reg_key.uf_disableItems({"num_cm", "type_graine"})
	IF lb_melprov THEN
		idw_reg.uf_disableItems({"an_maturite"})
	END IF
END IF

tab_1.enabled = TRUE

return(1)
end function

public function integer wf_setkey (string as_reflot);// utilisé par un programme externe pour ouvrir un lot
IF f_isEmptyString(as_reflot) THEN
	return(-1)
END IF

IF dw_reg_key.uf_SetDefaultValue(1, "ref_lot", as_reflot) < 0 THEN return(-1)

return(1)
end function

public subroutine wf_print ();// impression du lot en cours
str_params	lstr_params
long	ll_count

IF f_isEmptyString(is_reflot) THEN
	gu_message.uf_info("Veuillez d'abord afficher le lot")
	return
END IF

select count(*) into :ll_count from REGISTRE where ref_lot=:is_reflot using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	return
END IF
IF ll_count = 0 THEN
	gu_message.uf_info("Vous devez d'abord enregistrer le lot avant de pouvoir l'imprimer")
	return
END IF

IF IsValid(w_rpt_registre) THEN
	close(w_rpt_registre)
END IF

lstr_params.a_param[1] = is_reflot
OpenSheetWithParm(w_rpt_registre, lstr_params, gw_mdiframe, 0, Original!)
IF IsValid(w_rpt_registre) THEN
	w_rpt_registre.SetFocus()
END IF
end subroutine

public function integer wf_newcphys ();// création d'une nouvelle ligne de caractéristiques physiques
// return(-1) si erreur
// return(n° de row ajoutée) si OK
long	ll_row
integer	li_nextnum

IF idw_cphys.rowCount() = 0 THEN
	li_nextnum = 1
ELSE
	li_nextnum = idw_cphys.object.c_maxnum[1] + 1
	IF li_nextnum > 99 THEN 
		gu_message.uf_error("Nombre max de ligne (99) atteint !")
		return(-1)
	END IF
END IF

ll_row = idw_cphys.event ue_addrow()
IF ll_row <= 0 THEN
	return(-1)
END IF

// initialiser 1ère partie de la PK
idw_cphys.object.ref_lot[ll_row] = is_reflot

// chercher prochain n° test libre
idw_cphys.object.num_cphys[ll_row] = li_nextnum

// date par défaut = date du jour
idw_cphys.object.dt_cphys[ll_row] = f_today()

idw_cphys.SetColumn("dt_cphys")
idw_cphys.object.datawindow.HorizontalScrollPosition = 1
idw_cphys.SetFocus()

return(ll_row)
end function

public function integer wf_newqgerm ();// création d'une nouvelle ligne de facultés germinatives
// return(-1) si erreur
// return(n° de row ajoutée) si OK
long	ll_row
integer	li_nextnum

IF idw_qgerm.rowCount() = 0 THEN
	li_nextnum = 1
ELSE
	li_nextnum = idw_qgerm.object.c_maxnum[1] + 1
	IF li_nextnum > 99 THEN 
		gu_message.uf_error("Nombre max de ligne (99) atteint !")
		return(-1)
	END IF
END IF

ll_row = idw_qgerm.event ue_addrow()
IF ll_row <= 0 THEN
	return(-1)
END IF

// initialiser 1ère partie de la PK
idw_qgerm.object.ref_lot[ll_row] = is_reflot

// chercher prochain n° test libre
idw_qgerm.object.num_qgerm[ll_row] = li_nextnum

// date par défaut = date du jour
idw_qgerm.object.dt_qgerm[ll_row] = f_today()

idw_qgerm.SetColumn("dt_qgerm")
idw_qgerm.object.datawindow.HorizontalScrollPosition = 1
idw_qgerm.SetFocus()

return(ll_row)
end function

public subroutine wf_initcalcngv (long al_row);// faire connaître PDS1000 et Pureté à dw_qgerm pour évaluation du NBGvivant/kilo
// dans le cas où il n'est pas connu par un test de germination
decimal{2}	ld_pds1000, ld_purete_bon

idw_qgerm.setRedraw(FALSE)
ld_pds1000 = idw_cphys.object.pds1000[al_row]
ld_purete_bon = idw_cphys.object.purete_bon[al_row] 
IF isNull(ld_pds1000) THEN ld_pds1000 = 0
IF isNull(ld_purete_bon) THEN ld_purete_bon = 0
idw_qgerm.object.c_pds1000.expression = &
	"number('" + string(ld_pds1000 * 1000) + "') / 1000"
idw_qgerm.object.c_purete.expression = &
	"number('" + string(ld_purete_bon * 100) + "') / 100"
idw_qgerm.setRedraw(TRUE)

idw_cphys.setitemstatus(al_row, "c_select", Primary!, NotModified!)

end subroutine

on w_registre.create
int iCurrent
call super::create
this.dw_reg_key=create dw_reg_key
this.tab_1=create tab_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_reg_key
this.Control[iCurrent+2]=this.tab_1
end on

on w_registre.destroy
call super::destroy
destroy(this.dw_reg_key)
destroy(this.tab_1)
end on

event ue_close;call super::ue_close;dw_reg_key.ShareDataOff()

DESTROY ibr_registre
end event

event ue_open;call super::ue_open;integer	li_status

ibr_registre = CREATE br_registre

// initialiser les pointeurs vers les DW
idw_reg = tab_1.tabpage_reg.dw_reg
idw_cphys = tab_1.tabpage_caract.dw_cphys
idw_qgerm = tab_1.tabpage_caract.dw_qgerm
idw_flux = tab_1.tabpage_flux.dw_flux
idw_lastinv = tab_1.tabpage_flux.dw_lastinv
idw_qtestock = tab_1.tabpage_flux.dw_qtestock
idw_cat = tab_1.tabpage_cat.dw_cat
idw_inv = tab_1.tabpage_inv.dw_inv
idw_est1melange = tab_1.tabpage_melange.dw_est1melange
idw_estds1melange = tab_1.tabpage_melange.dw_estds1melange

// ne pas créer automatiquement une nouvelle ligne 'caractéristiques graine' quand on supprime la dernière
idw_cphys.uf_createwhenlastdeleted(FALSE)
idw_qgerm.uf_createwhenlastdeleted(FALSE)

// assigner les couleurs pour les lignes paires et impaires du DW FLUX, DW_CAT, DW_INV, ...
gu_dwservices.uf_setbrowsecol(idw_flux)
gu_dwservices.uf_setbrowsecol(idw_cat)
gu_dwservices.uf_setbrowsecol(idw_inv)
gu_dwservices.uf_setbrowsecol(idw_est1melange)
gu_dwservices.uf_setbrowsecol(idw_estDs1melange)

// partage des données
li_status = dw_reg_key.ShareData(idw_reg)
IF li_status = -1 THEN
	wf_executePostOpen(FALSE)
	populateerror(20000,"")
	gu_message.uf_unexp("idw_reg_data : partage des données dw_reg_key impossible")
	post close(this)
	return
END IF

// DW à mettre à jour
wf_SetDWList({idw_reg, idw_cphys, idw_qgerm})

// action(s) à rendre visible(s) dans le menu
wf_SetItemsToShow({"m_ajouter", "m_nullify"})
end event

event ue_init_win;call super::ue_init_win;ib_estDansUnMelange = FALSE
SetNull(is_reflot)

this.setredraw(FALSE)
tab_1.enabled = FALSE
tab_1.selecttab(1)

dw_reg_key.uf_reset()
idw_reg.uf_reset()
idw_flux.uf_reset()
idw_cat.uf_reset()
idw_inv.uf_reset()
idw_cphys.uf_reset()
idw_est1melange.uf_reset()
idw_estds1melange.uf_reset()

idw_cphys.object.datawindow.HorizontalScrollPosition = 1
idw_flux.object.datawindow.HorizontalScrollPosition = 1
idw_cat.object.datawindow.HorizontalScrollPosition = 1

dw_reg_key.insertrow(0)
dw_reg_key.uf_disabledata()
dw_reg_key.uf_enablekeys()
dw_reg_key.enabled = TRUE

idw_reg.uf_disabledata()
idw_reg.object.b_calc.enabled = FALSE

dw_reg_key.object.gb_sp.text = ''

this.setredraw(TRUE)

dw_reg_key.setfocus()


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
		// menu si le curseur est dans le DW hors de l'onglet (dw_reg_key) 
		CASE "dw_reg_key"
			IF NOT dw_reg_key.uf_IsRecordNew() AND wf_canDelete() THEN
				li_item++
				ls_menu[li_item] = "m_supprimer"
			END IF
	
		// menu si le curseur est sur le DW de l'onglet REGISTRE
		CASE "dw_reg"
			IF NOT dw_reg_key.uf_IsRecordNew() AND wf_canDelete() THEN
				li_item++
				ls_menu[li_item] = "m_supprimer"
				li_item++
				ls_menu[li_item] = "m_nullify"
			END IF
	
		// menu si curseur est sur un DW de l'onglet CARACTERISTIQUES DES GRAINES
		CASE "dw_cphys", "dw_qgerm"
			IF wf_canUpdate() THEN
				li_item++
				ls_menu[li_item] = "m_ajouter"
				li_item++
				ls_menu[li_item] = "m_supprimer"
				li_item++
				ls_menu[li_item] = "m_nullify"
			END IF
	END CHOOSE
END IF

f_menuaction(ls_menu)


end event

event ue_enregistrer;call super::ue_enregistrer;integer	li_status, li_num
long		ll_row
date		ldt_date

// contrôle de validité de tous les champs
IF dw_reg_key.event ue_checkall() < 0 THEN
	dw_reg_key.SetFocus()
	return(-1)
END IF

IF idw_reg.event ue_checkall() < 0 THEN
	tab_1.selecttab("tabpage_reg")
	idw_reg.SetFocus()
	return(-1)
END IF

IF idw_cphys.event ue_checkall() < 0 THEN
	tab_1.selecttab("tabpage_caract")
	idw_cphys.SetFocus()
	return(-1)
END IF

IF idw_qgerm.event ue_checkall() < 0 THEN
	tab_1.selecttab("tabpage_caract")
	idw_qgerm.SetFocus()
	return(-1)
END IF

// les rows de caractéristiques graines supprimées provoquent le mise à NULL 
// de la colonne NUM_CPHYS dans DOCFRN pour les documents du lot en cours
FOR ll_row = 1 TO idw_cphys.deletedCount()
	li_num = integer(idw_cphys.object.num_cphys.delete[ll_row])
	update docfrn set num_cphys = null
		where ref_lot = :is_reflot and num_cphys = :li_num using SQLCA;
	IF f_check_sql(SQLCA) <> 0 THEN
		populateerror(20000,"")
		gu_message.uf_unexp("DOCFRN : Erreur lors de la mise à jour de la base de données")
		return(-1)
	END IF
NEXT

// idem pour les qualités germinatives, pour la colonne NUM_QGERM de DOCFRN
FOR ll_row = 1 TO idw_qgerm.deletedCount()
	li_num = integer(idw_qgerm.object.num_qgerm.delete[ll_row])
	update docfrn set num_qgerm = null
		where ref_lot = :is_reflot and num_qgerm = :li_num using SQLCA;
	IF f_check_sql(SQLCA) <> 0 THEN
		populateerror(20000,"")
		gu_message.uf_unexp("DOCFRN : Erreur lors de la mise à jour de la base de données")
		return(-1)
	END IF
NEXT

li_status = gu_dwservices.uf_updatetransact(idw_reg, idw_cphys, idw_qgerm)
CHOOSE CASE li_status
	CASE 1
		wf_message("Lot de graines " + is_reflot + " enregistré avec succès")
		This.event ue_init_win()
		return(1)
	CASE -1
		populateerror(20000,"")
		gu_message.uf_unexp("REGISTRE : Erreur lors de la mise à jour de la base de données")
		return(-1)
	CASE -2
		populateerror(20000,"")
		gu_message.uf_unexp("REGISTRE_CPHYS : Erreur lors de la mise à jour de la base de données")
		return(-1)
	CASE -3
		populateerror(20000,"")
		gu_message.uf_unexp("REGISTRE_QGERM : Erreur lors de la mise à jour de la base de données")
		return(-1)
END CHOOSE

end event

event resize;call super::resize;tab_1.width = newwidth
tab_1.height = newheight - 720

IF isValid(idw_cphys) THEN
	idw_cphys.width = tab_1.tabpage_caract.width
	idw_cphys.height = tab_1.tabpage_caract.height / 2
END IF
IF isValid(idw_qgerm) THEN
	idw_qgerm.width = tab_1.tabpage_caract.width
	idw_qgerm.y = idw_cphys.y + idw_cphys.height
	idw_qgerm.height = tab_1.tabpage_caract.height - idw_cphys.height
END IF

IF isValid(idw_flux) THEN
	idw_flux.width = tab_1.tabpage_flux.width
	idw_flux.height = tab_1.tabpage_flux.height - 96
END IF

IF isValid(idw_lastinv) THEN
	idw_lastinv.y = idw_flux.y + idw_flux.height + 16
	idw_qtestock.y = idw_lastinv.y
END IF

IF isValid(idw_cat) THEN
	idw_cat.width = tab_1.tabpage_cat.width
	idw_cat.height = tab_1.tabpage_cat.height - 80
END IF
tab_1.tabpage_cat.st_pup.width = tab_1.tabpage_cat.width

IF isValid(idw_inv) THEN
	idw_inv.width = tab_1.tabpage_inv.width
	idw_inv.height = tab_1.tabpage_inv.height
END IF

IF isValid(idw_est1melange) THEN
	idw_est1melange.height = tab_1.tabpage_melange.height - 100
	idw_estDs1melange.height = idw_est1melange.height
END IF
end event

event ue_ajouter;call super::ue_ajouter;CHOOSE CASE wf_GetActivecontrolname()
	// ajouter une nouvelle ligne de caractéristiques physiques des graines
	CASE "dw_cphys"
		wf_newcphys()
		
	// ajouter une nouvelle ligne de qualités germinatives des graines
	CASE "dw_qgerm"
		wf_newqgerm()
END CHOOSE
end event

event ue_supprimer;call super::ue_supprimer;string	ls_message
date		ldt_date
integer	li_st, li_num, li_num_test_cphys, li_num_test_qgerm
long		ll_row

CHOOSE CASE wf_GetActivecontrolname()
	// suppression de tout le lot
	CASE "dw_reg_key", "dw_reg"
		IF ibr_registre.uf_check_beforedelete(is_reflot, ls_message, ib_estDansUnMelange) = -1 THEN
			gu_message.uf_info(ls_message)
			return
		END IF
		IF f_confirm_del("Voulez-vous supprimer ce lot du registre (y compris le catalogue de vente et les inventaires) ?") = 1 THEN
			IF idw_reg.event ue_delete() = 1 THEN
				// normalement, les "many" sont supprimés par les contraintes mais...
				delete from registre_cphys where ref_lot = :is_reflot using ESQLCA;
				IF f_check_sql(ESQLCA) = 0 AND ESQLCA.sqlnrows <> 0 THEN
					commit using ESQLCA;
					populateerror(20000,"")
					gu_message.uf_unexp("Les contraintes d'intégrité entre REGISTRE et REGISTRE_CPHYS ne sont pas actives !", 2)
				END IF
				delete from registre_qgerm where ref_lot = :is_reflot using ESQLCA;
				IF f_check_sql(ESQLCA) = 0 AND ESQLCA.sqlnrows <> 0 THEN
					commit using ESQLCA;
					populateerror(20000,"")
					gu_message.uf_unexp("Les contraintes d'intégrité entre REGISTRE et REGISTRE_QGERM ne sont pas actives !", 2)
				END IF
				delete from flux_registre where ref_lot = :is_reflot using ESQLCA;
				IF f_check_sql(ESQLCA) = 0 AND ESQLCA.sqlnrows <> 0 THEN
					commit using ESQLCA;
					populateerror(20000,"")
					gu_message.uf_unexp("Les contraintes d'intégrité entre REGISTRE et FLUX_REGISTRE ne sont pas actives !", 2)
				END IF
				delete from cat_vente_lot where ref_lot = :is_reflot using ESQLCA;
				IF f_check_sql(ESQLCA) = 0 AND ESQLCA.sqlnrows <> 0 THEN
					commit using ESQLCA;
					populateerror(20000,"")
					gu_message.uf_unexp("Les contraintes d'intégrité entre REGISTRE et CAT_VENTE_LOT ne sont pas actives !", 2)
				END IF
				delete from inventaire where ref_lot = :is_reflot using ESQLCA;
				IF f_check_sql(ESQLCA) = 0 AND ESQLCA.sqlnrows <> 0 THEN
					commit using ESQLCA;
					populateerror(20000,"")
					gu_message.uf_unexp("Les contraintes d'intégrité entre REGISTRE et INVENTAIRE ne sont pas actives !", 2)
				END IF
				
				// remarque : commit ou rollback nécessaire après les delete ci-dessus, même s'ils n'ont aucun effet !
				// Si on ne le fait pas, les LOCK subsistent !
				commit using ESQLCA;	
				wf_message("Lot supprimé du registre avec succès")
				this.event ue_init_win()
			END IF
		END IF
		
	// suppression d'une ligne de caractéristiques physiques
	CASE  "dw_cphys"
		ll_row = idw_cphys.GetRow()
		IF ll_row <= 0 THEN return
		ldt_date = date(idw_cphys.object.dt_cphys[ll_row])
		li_num = integer(idw_cphys.object.num_cphys[ll_row])
		li_num_test_cphys = integer(idw_cphys.object.num_test_cphys[ll_row])
		// Vérification avant suppression
		li_st = ibr_registre.uf_check_cphys_beforedelete(is_reflot, ldt_date, li_num, li_num_test_cphys, ls_message)
		IF li_st = -1 THEN
			gu_message.uf_error(ls_message)
			return
		END IF
		IF li_st = 0 THEN
			gu_message.uf_info(ls_message)
		END IF
		IF f_confirm_del("Voulez-vous supprimer les caractéristiques physiques n° " + &
					f_string(idw_cphys.object.num_cphys[ll_row]) + " du " + &
					string(idw_cphys.object.dt_cphys[ll_row], "dd/mm/yyyy") + " ?") = 1 THEN
			IF idw_cphys.event ue_delete() = 1 THEN
				wf_message("Caractéristiques physiques supprimées avec succès")
			END IF
		END IF
		
	// suppression d'une ligne de facultés germinatives
	CASE  "dw_qgerm"
		ll_row = idw_qgerm.GetRow()
		IF ll_row <= 0 THEN return
		ldt_date = date(idw_qgerm.object.dt_qgerm[ll_row])
		li_num = integer(idw_qgerm.object.num_qgerm[ll_row])
		li_num_test_qgerm = integer(idw_qgerm.object.num_test_qgerm[ll_row])
		// Vérification avant suppression
		li_st = ibr_registre.uf_check_qgerm_beforedelete(is_reflot, ldt_date, li_num, li_num_test_qgerm, ls_message)
		IF li_st = -1 THEN
			gu_message.uf_error(ls_message)
			return
		END IF
		IF li_st = 0 THEN
			gu_message.uf_info(ls_message)
		END IF
		IF f_confirm_del("Voulez-vous supprimer les facultés germinatives n° " + &
					f_string(idw_qgerm.object.num_qgerm[ll_row]) + " du " + &
					string(idw_qgerm.object.dt_qgerm[ll_row], "dd/mm/yyyy") + " ?") = 1 THEN
			IF idw_qgerm.event ue_delete() = 1 THEN
				wf_message("Facultés germinatives supprimées avec succès")
			END IF
		END IF
END CHOOSE

end event

event ue_nullify;call super::ue_nullify;CHOOSE CASE wf_GetActivecontrolname()
	CASE "dw_cphys"
		idw_cphys.event ue_nullify()
	CASE "dw_qgerm"
		idw_qgerm.event ue_nullify()
	CASE "dw_reg"
		idw_reg.event ue_nullify()
END CHOOSE
end event

type ddlb_message from w_ancestor_dataentry`ddlb_message within w_registre
integer y = 1888
integer width = 3054
end type

type dw_reg_key from uo_datawindow_singlerow within w_registre
integer width = 3090
integer height = 624
integer taborder = 10
boolean bringtotop = true
string dataobject = "d_registre_key"
end type

event ue_checkitem;call super::ue_checkitem;integer	li_status
long		ll_count

CHOOSE CASE as_item
	CASE "ref_lot"
		IF ibr_registre.uf_check_reflot(as_data, as_message) = -1 THEN
			return(-1)
		ELSE
			is_reflot = as_data
		END IF
		
		// dernier élément de la clé, vérifier si record existe ou pas		
		select count(*) into :ll_count from registre
				where ref_lot = :is_reflot using ESQLCA;
		li_status = f_check_sql(ESQLCA)
		IF li_status < 0 OR ll_count > 1 THEN
			populateerror(20000,"")
			gu_message.uf_unexp("Erreur SELECT REGISTRE")
			return(-1)
		ELSE
			// lot inexistant...
			IF ll_count = 0 THEN
				// ...et on peut modifier les données...
				IF wf_canUpdate() THEN
					this.uf_NewRecord(TRUE)
					return(1)
				ELSE
				// ...et on ne peut pas modifier les données
					as_message = "Lot inexistant. Vous n'avez pas le droit d'en créer..."
					return(-1)
				END IF
			ELSE
			// lot existe déjà : OK
				this.uf_NewRecord(FALSE)
				return(1)
			END IF
		END IF
		
	CASE "dt_creation"
		return(ibr_registre.uf_check_dtentree(as_data, as_message))
		
	CASE "type_graine"
		return(ibr_registre.uf_check_typegraine(as_data, as_message))
		
	CASE "num_fiche"
		return(ibr_registre.uf_check_numfiche(as_data, as_message))

	CASE "num_cm"
		return(ibr_registre.uf_check_numcm(as_data, as_message, this.object.type_graine[1], is_reflot))
		
	CASE "num_df_recu"
		return(ibr_registre.uf_check_numdf_recu(as_data, as_message, this.object.type_graine[1]))
		
	CASE "num_cm_frn"
		return(ibr_registre.uf_check_numcmfrn(as_data, as_message))

	CASE "code_sp"
		IF ibr_registre.uf_check_codesp(as_data, as_message) = -1 THEN
			return(-1)
		ELSE
			this.object.c_nomespece[al_row] = as_message
		END IF
		
	CASE "num_prov"
		IF ibr_registre.uf_check_numprov(as_data, as_message, string(this.object.code_sp[al_row])) = -1 THEN
			return(-1)
		ELSE
			this.object.c_nomprov[al_row] = as_message
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
	wf_message("Modification d'un lot...")
	this.retrieve(is_reflot)
ELSE
	wf_message("Nouveau lot...")
END IF

parent.event ue_init_menu()
post wf_init()

end event

event ue_itemvalidated;call super::ue_itemvalidated;integer	li_anaut, li_numaut, li_numprov, li_anmaturite
string	ls_codesp, ls_melange, ls_typeqte
decimal{3}	ld_qtecm, ld_qteaut

CHOOSE CASE as_name
	CASE "type_graine"
		// modifier libellé du cadre et annuler certains champs en fonction du type de graine
		// attention : uf_check_num_cm et uf_check_num_cm_recu font intervenir le type de graine,
		//             donc il faut éviter d'utiliser les fonctions uf_setdefaultvalue(..) sur
		//             ces 2 items quand on modifie le type de graine, car dans ce cas la nouvelle
		//             valeur du type de graine n'est pas encore dans le buffer quand la fonction
		//             uf_check...() est exécutée !
		// workaround : forcer le passage ! Placer la nouvelle valeur dans le buffer !
		// NB : jamais fait ça...on verra bien ;-)
		this.object.type_graine[1] = as_data
		
		IF as_data = "P" THEN
			this.uf_setdefaultvalue(1, "num_df_recu", gu_c.s_null, string!)
			this.uf_setdefaultvalue(1, "num_cm_frn", gu_c.s_null, string!)
			this.object.num_cm[1] = "BRW"
			this.object.gb_sp.text = 'Préparée'
		ELSEIF as_data = "A" THEN
			this.uf_setdefaultvalue(1, "num_cm", gu_c.s_null, string!)
			this.object.gb_sp.text = 'Achat / Négoce'
		ELSEIF as_data = "N" THEN
			this.uf_setdefaultvalue(1, "num_cm", gu_c.s_null, string!)
			this.object.gb_sp.text = 'Non soumise'
		ELSE
			this.uf_setdefaultvalue(1, "num_cm", gu_c.s_null, string!)
			this.uf_setdefaultvalue(1, "num_df_recu", gu_c.s_null, string!)
			this.uf_setdefaultvalue(1, "num_cm_frn", gu_c.s_null, string!)
			this.object.gb_sp.text = ''
		END IF

	CASE "num_cm"
		// l'espèce et la provenance proviennent de l'autorisation de récolte
		// NB 24/09/2008 : divers errements ont fait qu'il a été un moment possible de créer un lot préparé
		// sans donner le n° de CM. Dans ce cas, il fallait introduire soi-même l'espèce et la provenance.
		// Ce n'est plus possible.
		// 29/09/2008 : le code MELANGE du CM doit être recopié dans celui du LOT
		// 06/11/2008 : afficher la qté du CM et celle de l'autorisation
		// 12/11/2008 : recopier l'année de maturité de l'autorisation dans l'année de mat. du registre
		// 10/12/2008 : correction bug : quand on annule le n° de CM pour une bonne raison (type de graine A ou N),
		//              on ne doit pas passer par les initialisation sur base du CM !
		IF NOT f_IsEmptyString(as_data) THEN
			select an_aut, num_aut, melange, qte_mfr into :li_anaut, :li_numaut, :ls_melange, :ld_qtecm
				from certificat where num_cm = :as_data using ESQLCA;
			IF f_check_sql(ESQLCA) <> 0 THEN
				gu_message.uf_error("ERREUR SELECT CERTIFICAT")
				return
			END IF
			
			select code_sp, num_prov, qte_mfr_total, an_maturite 
				into :ls_codesp, :li_numprov, :ld_qteaut, :li_anmaturite
				from autorisation	where an_aut = :li_anaut and num_aut = :li_numaut using ESQLCA;
			IF f_check_sql(ESQLCA) <> 0 THEN
				gu_message.uf_error("ERREUR SELECT AUTORISATION")
				return
			END IF
		
			this.uf_setdefaultvalue(1, "code_sp", ls_codesp)
			this.uf_setdefaultvalue(1, "num_prov", li_numprov)
			this.uf_setdefaultvalue(1, "melange", ls_melange)
			this.uf_setdefaultvalue(1, "an_maturite", li_anmaturite, integer!)
			
			this.object.c_qtecm[1] = ld_qtecm
			this.object.c_qteaut[1] = ld_qteaut
		END IF

	CASE "code_sp"
		this.uf_setdefaultvalue(1, "num_prov", gu_c.i_null, integer!)
		this.uf_setdefaultvalue(1, "c_nomprov", gu_c.s_null, string!)
		// lecture type de quantité (comptage/poids)
		select type_qte into :ls_typeqte from espece where code_sp=:as_data using ESQLCA;
		IF f_check_sql(ESQLCA) <> 0 THEN
			gu_message.uf_error("ERREUR SELECT ESPECE")
			idw_qgerm.object.c_typeqte.expression = "''"
		ELSE
			idw_qgerm.object.c_typeqte.expression = "'" + ls_typeqte + "'"
		END IF
		
END CHOOSE
end event

event ue_help;call super::ue_help;str_params	lstr_params

CHOOSE CASE idwo_currentItem.name
	CASE "ref_lot"
		open(w_l_registre)
		IF Message.DoubleParm = -1 THEN 
			return
		ELSE
			lstr_params=Message.PowerObjectParm
			this.SetText(f_string(lstr_params.a_param[1]))
			f_presskey("TAB")
		END IF

	CASE "num_cm"
		open(w_l_certificat)
		IF Message.DoubleParm = -1 THEN 
			return
		ELSE
			lstr_params=Message.PowerObjectParm
			this.SetText(f_string(lstr_params.a_param[1]))
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

event ue_postitemvalidated;call super::ue_postitemvalidated;IF as_name = "type_graine" THEN
	idw_reg.SetColumn("qte_initiale")
END IF
end event

type tab_1 from tab within w_registre
event ue_focusondw ( )
integer y = 624
integer width = 3090
integer height = 1248
integer taborder = 20
boolean bringtotop = true
integer textsize = -10
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
tabpage_reg tabpage_reg
tabpage_caract tabpage_caract
tabpage_flux tabpage_flux
tabpage_inv tabpage_inv
tabpage_cat tabpage_cat
tabpage_melange tabpage_melange
end type

event ue_focusondw();w_ancestor_dataentry	lw_parent

CHOOSE CASE This.SelectedTab
	CASE 1
		idw_reg.SetFocus()
	CASE 2
		idw_cphys.object.datawindow.HorizontalScrollPosition = 1
		idw_cphys.SetFocus()
	CASE 3
		idw_flux.object.datawindow.HorizontalScrollPosition = 1
		idw_flux.SetFocus()
	CASE 4
		idw_inv.object.datawindow.HorizontalScrollPosition = 1
		idw_inv.SetFocus()
	CASE 5
		idw_cat.object.datawindow.HorizontalScrollPosition = 1
		idw_cat.SetFocus()
	CASE ELSE
		// réactualiser le menu car l'option 'ajouter' n'est pas toujours disponible
		IF f_GetParentWindow(this, lw_parent) = 1 THEN
			lw_parent.event ue_init_menu()
		END IF
END CHOOSE

end event

on tab_1.create
this.tabpage_reg=create tabpage_reg
this.tabpage_caract=create tabpage_caract
this.tabpage_flux=create tabpage_flux
this.tabpage_inv=create tabpage_inv
this.tabpage_cat=create tabpage_cat
this.tabpage_melange=create tabpage_melange
this.Control[]={this.tabpage_reg,&
this.tabpage_caract,&
this.tabpage_flux,&
this.tabpage_inv,&
this.tabpage_cat,&
this.tabpage_melange}
end on

on tab_1.destroy
destroy(this.tabpage_reg)
destroy(this.tabpage_caract)
destroy(this.tabpage_flux)
destroy(this.tabpage_inv)
destroy(this.tabpage_cat)
destroy(this.tabpage_melange)
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

type tabpage_reg from userobject within tab_1
integer x = 18
integer y = 112
integer width = 3054
integer height = 1120
long backcolor = 67108864
string text = "Registre"
long tabtextcolor = 33554432
long picturemaskcolor = 536870912
dw_reg dw_reg
end type

on tabpage_reg.create
this.dw_reg=create dw_reg
this.Control[]={this.dw_reg}
end on

on tabpage_reg.destroy
destroy(this.dw_reg)
end on

type dw_reg from uo_datawindow_singlerow within tabpage_reg
integer x = 91
integer y = 64
integer width = 2889
integer height = 912
integer taborder = 11
string dataobject = "d_registre_data"
end type

event ue_checkitem;call super::ue_checkitem;CHOOSE CASE as_item
	CASE "qte_initiale"
		return(ibr_registre.uf_check_qteinit(as_data, as_message))
		
	CASE "qte_admise"
		return(ibr_registre.uf_check_qteadm(as_data, as_message))
		
	CASE "rem_qte"
		return(ibr_registre.uf_check_remqte(as_data, as_message))
		
	CASE "melange"
		return(ibr_registre.uf_check_melange(as_data, as_message))
		
	CASE "ogm"
		return(ibr_registre.uf_check_ogm(as_data, as_message))
		
	CASE "admission_prov"
		return(ibr_registre.uf_check_admprov(as_data, as_message))
		
	CASE "paysreg_derog"
		return(ibr_registre.uf_check_paysreg_derog(as_data, as_message))
		
	CASE "motif_derog"
		return(ibr_registre.uf_check_derog(as_data, as_message))
		
	CASE "an_maturite"
		return(ibr_registre.uf_check_anmaturite(as_data, as_message))
		
	CASE "an_inventaire"
		return(ibr_registre.uf_check_aninvent(as_data, as_message))
		
	CASE "num_farde"
		return(ibr_registre.uf_check_numfarde(as_data, as_message))
END CHOOSE

return(1)
end event

event ue_itemvalidated;call super::ue_itemvalidated;CHOOSE CASE as_name
	CASE "qte_admise"
		// placer la qté admise dans le DW 'qté en stock'
		idw_qtestock.object.d_qteadmise[1] = dec(as_data)
	
END CHOOSE
end event

event getfocus;call super::getfocus;w_ancestor_dataentry	lw_parent

// réactualiser le menu car l'option 'ajouter' n'est pas toujours disponible
IF f_GetParentWindow(this, lw_parent) = 1 THEN
	lw_parent.event ue_init_menu()
END IF

end event

event buttonclicked;call super::buttonclicked;// initialiser le commentaire avec le calcul des proportions en cas de mélange
// bouton actif uniquement pour les lots déjà enregistrés et de type mélange

string	ls_texte

ls_texte = ibr_registre.uf_init_remqte(is_reflot)

IF NOT f_IsEmptyString(ls_texte) THEN
	idw_reg.object.rem_qte[1] = ls_texte
END IF

return

end event

type tabpage_caract from userobject within tab_1
integer x = 18
integer y = 112
integer width = 3054
integer height = 1120
long backcolor = 67108864
string text = "Caractéristiques graines"
long tabtextcolor = 33554432
long picturemaskcolor = 536870912
dw_qgerm dw_qgerm
dw_cphys dw_cphys
end type

on tabpage_caract.create
this.dw_qgerm=create dw_qgerm
this.dw_cphys=create dw_cphys
this.Control[]={this.dw_qgerm,&
this.dw_cphys}
end on

on tabpage_caract.destroy
destroy(this.dw_qgerm)
destroy(this.dw_cphys)
end on

type dw_qgerm from uo_datawindow_multiplerow within tabpage_caract
integer y = 592
integer width = 3054
integer height = 480
integer taborder = 11
string dataobject = "d_registre_qgerm"
boolean hscrollbar = true
boolean vscrollbar = true
boolean border = true
end type

event doubleclicked;call super::doubleclicked;// double-clic sur une ligne de caractéristique issue d'un test complet : ouvrir ce test
integer	li_status, li_numtestQGERM, li_numtestVIAB

IF row = 0 THEN return

li_numtestQGERM = this.object.num_test_qgerm[row]
li_numtestVIAB = this.object.num_test_viab[row]
IF (li_numtestQGERM = 0 OR isNull(li_numtestQGERM)) AND (li_numtestVIAB = 0 OR isNull(li_numtestVIAB))THEN 
//	gu_message.uf_info("Ces caractéristiques ne sont pas issues d'un test encodés en détail...")
	return
END IF

// ouvrir test de germination ou viabilité selon le cas
// 1. ouvrir w_qgerm
IF NOT (li_numtestQGERM = 0 OR isNull(li_numtestQGERM)) THEN
	// si w_qgerm ouvert en mode validation, le fermer !
	IF isValid(w_qgerm_validation) THEN
		close(w_qgerm_validation)
	END IF
	IF NOT isValid(w_qgerm) THEN
		OpenSheet(w_qgerm, gw_mdiframe, 0, Original!)
	END IF
	// provoquer lecture des données dans w_qgerm
	IF IsValid(w_qgerm) THEN
		w_qgerm.SetFocus()
		li_status = w_qgerm.event ue_abandonner()
		IF li_status = 3 OR li_status < 0 THEN
			return
		ELSE
			w_qgerm.post wf_SetKey(is_reflot, li_numtestQGERM, TRUE) // TRUE indique "readonly"
		END IF
	END IF
END IF
// 2. ouvrir w_viabilite
IF NOT (li_numtestVIAB = 0 OR isNull(li_numtestVIAB)) THEN
	IF NOT isValid(w_viabilite) THEN
		OpenSheet(w_viabilite, gw_mdiframe, 0, Original!)
	END IF
	// provoquer lecture des données dans w_viabilite
	IF IsValid(w_viabilite) THEN
		w_viabilite.SetFocus()
		li_status = w_viabilite.event ue_abandonner()
		IF li_status = 3 OR li_status < 0 THEN
			return
		ELSE
			w_viabilite.post wf_SetKey(is_reflot, li_numtestVIAB, TRUE) // TRUE indique "readonly"
		END IF
	END IF
END IF

end event

event getfocus;call super::getfocus;w_ancestor_dataentry	lw_parent

// réactualiser le menu car l'option 'ajouter' n'est pas toujours disponible
IF f_GetParentWindow(this, lw_parent) = 1 THEN
	lw_parent.event ue_init_menu()
END IF

end event

event ue_postitemvalidated;call super::ue_postitemvalidated;long	ll_rowID, ll_row
integer	li_num

IF al_row <= 0 THEN return

CHOOSE CASE as_name
	// après encodage de la date, retrier le DW et resélectionner la bonne row
	CASE "dt_qgerm"
		ll_rowID = this.GetRowIdFromRow(al_row)
		this.sort()
		ll_row = this.GetRowFromRowId(ll_rowID)
		this.scrollToRow(ll_row)
		this.SetColumn("fg")
END CHOOSE


end event

event ue_checkitem;call super::ue_checkitem;integer	li_numorg

CHOOSE CASE as_item
	CASE "num_qgerm"
		// s'assurer que cette ligne n'est pas référencée par les documents fournisseurs
		li_numorg = integer(this.object.num_qgerm.original[al_row])
		IF integer(as_data) <> li_numorg THEN
			IF ibr_registre.uf_check_qgerm_beforeUpdate(is_reflot, li_numorg, as_message) = -1 THEN
				return(-1)
			END IF
		END IF
		IF ibr_registre.uf_check_qgerm_num(as_data, as_message) = -1 THEN
			return(-1)
		ELSE
			IF gu_dwservices.uf_findduplicate(This, al_row, "num_qgerm=" + as_data) <> 0 THEN
				as_message = "Ce n° de mesure existe déjà"
				return(-1)
			END IF
		END IF
		return(1)
	CASE "dt_qgerm"
		return(ibr_registre.uf_check_qgerm_dt(as_data, as_message))
	CASE "rem"
		return(ibr_registre.uf_check_qgerm_rem(as_data, as_message))
	CASE "viabilite"
		IF ibr_registre.uf_check_qgerm_viabilite(as_data, as_message) = -1 THEN
			return(-1)
		ELSE
			// viabilite et faculté germinative/gvkilo s'excluent mutuellement
			IF dec(as_data) <> 0 THEN
				this.object.fg[al_row] = gu_c.d_null
				this.object.gvkilo[al_row] = gu_c.d_null
			END IF
		END IF
	CASE "fg"
		IF ibr_registre.uf_check_qgerm_fg(as_data, as_message) = -1 THEN
			return(-1)
		ELSE
			// faculté germinative et gvkilo/viabilite s'excluent mutuellement
			IF dec(as_data) <> 0 THEN
				this.object.viabilite[al_row] = gu_c.d_null
				this.object.gvkilo[al_row] = gu_c.d_null
			END IF
		END IF
	CASE "gvkilo"
		IF ibr_registre.uf_check_qgerm_gvkilo(as_data, as_message) = -1 THEN
			return(-1)
		ELSE
			// gvkilo et faculté germinative/viabilité s'excluent mutuellement
			IF dec(as_data) <> 0 THEN
				this.object.fg[al_row] = gu_c.d_null
				this.object.viabilite[al_row] = gu_c.d_null
			END IF
		END IF
END CHOOSE
return(1)
end event

type dw_cphys from uo_datawindow_multiplerow within tabpage_caract
integer width = 3054
integer height = 592
integer taborder = 11
string dataobject = "d_registre_cphys"
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

event ue_checkitem;call super::ue_checkitem;integer	li_numorg

CHOOSE CASE as_item
	CASE "num_cphys"
		// s'assurer que cette ligne n'est pas référencée par les documents fournisseurs
		li_numorg = integer(this.object.num_cphys.original[al_row])
		IF integer(as_data) <> li_numorg THEN
			IF ibr_registre.uf_check_cphys_beforeUpdate(is_reflot, li_numorg, as_message) = -1 THEN
				return(-1)
			END IF
		END IF
		IF ibr_registre.uf_check_cphys_num(as_data, as_message) = -1 THEN
			return(-1)
		ELSE
			IF gu_dwservices.uf_findduplicate(This, al_row, "num_cphys=" + as_data) <> 0 THEN
				as_message = "Ce n° de mesure existe déjà"
				return(-1)
			END IF
		END IF
		return(1)
	CASE "dt_cphys"
		return(ibr_registre.uf_check_cphys_dt(as_data, as_message))
	CASE "rem"
		return(ibr_registre.uf_check_cphys_rem(as_data, as_message))
	CASE "purete_bon"
		return(ibr_registre.uf_check_cphys_purete_bon(as_data, as_message))
	CASE "purete_inerte"
		return(ibr_registre.uf_check_cphys_purete_inerte(as_data, as_message))
	CASE "purete_autre"
		return(ibr_registre.uf_check_cphys_purete_autre(as_data, as_message))
	CASE "pds1000"
		return(ibr_registre.uf_check_cphys_pds1000(as_data, as_message))
	CASE "teneur_eau"
		return(ibr_registre.uf_check_cphys_teneureau(as_data, as_message))
	CASE "c_select"
		// on ne peut pas désélectionner une ligne sélectionnée, il faut pour cela
		// en sélectionner une autre
		IF integer(as_data) = 0 AND this.object.c_select[al_row] = 1 THEN
			return(-3)
		END IF
END CHOOSE
return(1)
end event

event ue_postitemvalidated;call super::ue_postitemvalidated;long	ll_rowID, ll_row
integer	li_num

IF al_row <= 0 THEN return

CHOOSE CASE as_name
	// après encodage de la date, retrier le DW et resélectionner la bonne row
	CASE "dt_cphys"
		ll_rowID = this.GetRowIdFromRow(al_row)
		this.sort()
		ll_row = this.GetRowFromRowId(ll_rowID)
		this.scrollToRow(ll_row)
		this.SetColumn("purete_bon")
		
	CASE "c_select"
		// faire connaître PDS1000 et Pureté à dw_qgerm pour évaluation du NBGvivant/kilo
		// dans le cas où il n'est pas connu par un test de germination
		wf_initcalcngv(al_row)		
END CHOOSE


end event

event doubleclicked;call super::doubleclicked;// double-clic sur une ligne de caractéristique issue d'un test complet : ouvrir ce test
integer	li_status, li_numtest

IF row = 0 THEN return

li_numtest = this.object.num_test_cphys[row]
IF li_numtest = 0 OR isNull(li_numtest) THEN 
//	gu_message.uf_info("Ces caractéristiques ne sont pas issues d'un test encodés en détail...")
	return
END IF

// ouvrir w_cphys
IF NOT isValid(w_cphys) THEN
	OpenSheet(w_cphys, gw_mdiframe, 0, Original!)
END IF

// provoquer lecture des données dans w_cphys
IF IsValid(w_cphys) THEN
	w_cphys.SetFocus()
	li_status = w_cphys.event ue_abandonner()
	IF li_status = 3 OR li_status < 0 THEN
		return
	ELSE
		w_cphys.post wf_SetKey(is_reflot, li_numtest, TRUE) // TRUE indique "readonly"
	END IF
END IF

end event

event ue_checkrow;call super::ue_checkrow;string	ls_message

IF AncestorReturnValue > 0 THEN
	IF ibr_registre.uf_check_cphys_purete(ls_message, dec(this.object.purete_bon[al_row]), &
			 dec(this.object.purete_inerte[al_row]), dec(this.object.purete_autre[al_row])) = -1 THEN
		gu_message.uf_error(ls_message)
		return(-1)
	END IF
END IF
return(AncestorReturnValue)

end event

event ue_itemvalidated;call super::ue_itemvalidated;long	ll_row

IF as_name = "c_select" THEN
	IF integer(as_data) = 1 THEN
		// désélectionner les autres rows que celle qu'on vient de sélectionner
		FOR ll_row = 1 TO this.rowCount()
			IF ll_row <> al_row THEN 
				this.object.c_select[ll_row] = 0
				this.setitemstatus(ll_row, "c_select", Primary!, NotModified!)
			END IF
		NEXT
	END IF
END IF
end event

type tabpage_flux from userobject within tab_1
integer x = 18
integer y = 112
integer width = 3054
integer height = 1120
long backcolor = 67108864
string text = "Flux"
long tabtextcolor = 33554432
long picturemaskcolor = 536870912
dw_qtestock dw_qtestock
dw_lastinv dw_lastinv
dw_flux dw_flux
end type

on tabpage_flux.create
this.dw_qtestock=create dw_qtestock
this.dw_lastinv=create dw_lastinv
this.dw_flux=create dw_flux
this.Control[]={this.dw_qtestock,&
this.dw_lastinv,&
this.dw_flux}
end on

on tabpage_flux.destroy
destroy(this.dw_qtestock)
destroy(this.dw_lastinv)
destroy(this.dw_flux)
end on

type dw_qtestock from uo_datawindow_singlerow within tabpage_flux
integer y = 1040
integer width = 1463
integer height = 80
integer taborder = 11
string dataobject = "d_registre_qtestock"
end type

type dw_lastinv from uo_datawindow_singlerow within tabpage_flux
integer x = 1646
integer y = 1040
integer width = 1408
integer height = 80
integer taborder = 20
string dataobject = "d_registre_last_inv"
end type

type dw_flux from uo_ancestor_dwbrowse within tabpage_flux
integer width = 3054
integer height = 1024
integer taborder = 11
string dataobject = "d_registre_flux"
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

event doubleclicked;call super::doubleclicked;// double-clic sur le n° de DF émis : ouvrir ce DF
string	ls_numdf
integer	li_status

IF row = 0 THEN return
IF dwo.name <> "detail_cmde_num_df_emis" THEN return
ls_numdf = dwo.Primary[row]
IF f_IsEmptyString(ls_numdf) THEN return

IF NOT IsValid(w_docfrn) THEN
	OpenSheet(w_docfrn, gw_mdiframe, 0, Original!)
END IF
IF IsValid(w_docfrn) THEN
	w_docfrn.SetFocus()
	li_status = w_docfrn.event ue_abandonner()
	IF li_status = 3 OR li_status < 0 THEN
		return
	END IF
	w_docfrn.post wf_SetKey(ls_numdf)
END IF
end event

type tabpage_inv from userobject within tab_1
integer x = 18
integer y = 112
integer width = 3054
integer height = 1120
long backcolor = 67108864
string text = "Inventaires"
long tabtextcolor = 33554432
long picturemaskcolor = 536870912
dw_inv dw_inv
end type

on tabpage_inv.create
this.dw_inv=create dw_inv
this.Control[]={this.dw_inv}
end on

on tabpage_inv.destroy
destroy(this.dw_inv)
end on

type dw_inv from uo_ancestor_dwbrowse within tabpage_inv
integer width = 3054
integer height = 1088
integer taborder = 11
string dataobject = "d_registre_inv"
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

type tabpage_cat from userobject within tab_1
integer x = 18
integer y = 112
integer width = 3054
integer height = 1120
long backcolor = 67108864
string text = "Prix Catalogue"
long tabtextcolor = 33554432
long picturemaskcolor = 536870912
st_pup st_pup
dw_cat dw_cat
end type

on tabpage_cat.create
this.st_pup=create st_pup
this.dw_cat=create dw_cat
this.Control[]={this.st_pup,&
this.dw_cat}
end on

on tabpage_cat.destroy
destroy(this.st_pup)
destroy(this.dw_cat)
end on

type st_pup from uo_statictext within tabpage_cat
integer y = 16
integer width = 3054
integer textsize = -9
integer weight = 700
boolean italic = true
long textcolor = 8388608
string text = "(NB : les prix intitulés puP représentent les prix AVEC pré-traitement)"
alignment alignment = center!
end type

type dw_cat from uo_ancestor_dwbrowse within tabpage_cat
integer y = 80
integer width = 3054
integer height = 1040
integer taborder = 11
string dataobject = "d_registre_cat"
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

type tabpage_melange from userobject within tab_1
integer x = 18
integer y = 112
integer width = 3054
integer height = 1120
long backcolor = 67108864
string text = "Mélanges"
long tabtextcolor = 33554432
long picturemaskcolor = 536870912
st_2 st_2
dw_estds1melange dw_estds1melange
dw_est1melange dw_est1melange
st_1 st_1
end type

on tabpage_melange.create
this.st_2=create st_2
this.dw_estds1melange=create dw_estds1melange
this.dw_est1melange=create dw_est1melange
this.st_1=create st_1
this.Control[]={this.st_2,&
this.dw_estds1melange,&
this.dw_est1melange,&
this.st_1}
end on

on tabpage_melange.destroy
destroy(this.st_2)
destroy(this.dw_estds1melange)
destroy(this.dw_est1melange)
destroy(this.st_1)
end on

type st_2 from uo_statictext within tabpage_melange
integer x = 1719
integer y = 16
integer width = 1317
integer weight = 700
long textcolor = 8388608
string text = "Ce lot est repris dans le mélange suivant :"
alignment alignment = center!
end type

type dw_estds1melange from uo_ancestor_dwbrowse within tabpage_melange
integer x = 1737
integer y = 96
integer width = 1317
integer height = 1008
integer taborder = 11
string dataobject = "d_registre_estdans1melange"
boolean vscrollbar = true
boolean border = true
end type

event doubleclicked;call super::doubleclicked;string	ls_reflot, ls_cm
integer	li_status

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
			ELSE
				w_registre.post wf_SetKey(ls_reflot)
			END IF
		END IF

	// double-clic sur le n° de CM : ouvrir ce CM
	CASE "cm_melange_num_cm"
		ls_cm = dwo.Primary[row]
		IF f_IsEmptyString(ls_cm) THEN return
		
		IF NOT IsValid(w_certificat) THEN
			OpenSheet(w_certificat, gw_mdiframe, 0, Original!)
		END IF
		IF IsValid(w_certificat) THEN	
			w_certificat.SetFocus()
			li_status = w_certificat.event ue_abandonner()
			IF li_status = 3 OR li_status < 0 THEN
				return
			ELSE
				w_certificat.post wf_SetKey(ls_cm)
			END IF
		END IF
		
	CASE ELSE
		return
END CHOOSE
end event

type dw_est1melange from uo_ancestor_dwbrowse within tabpage_melange
integer y = 96
integer width = 1719
integer height = 1008
integer taborder = 11
string dataobject = "d_registre_est1melange"
boolean hscrollbar = true
boolean vscrollbar = true
boolean border = true
end type

event doubleclicked;call super::doubleclicked;string	ls_reflot, ls_cm
integer	li_status

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
			ELSE
				w_registre.post wf_SetKey(ls_reflot)
			END IF
		END IF

	// double-clic sur le n° de CM : ouvrir ce CM
	CASE "cm_melange_num_cm_melange"
		ls_cm = dwo.Primary[row]
		IF f_IsEmptyString(ls_cm) THEN return
		
		IF NOT IsValid(w_certificat) THEN
			OpenSheet(w_certificat, gw_mdiframe, 0, Original!)
		END IF
		IF IsValid(w_certificat) THEN	
			w_certificat.SetFocus()
			li_status = w_certificat.event ue_abandonner()
			IF li_status = 3 OR li_status < 0 THEN
				return
			ELSE
				w_certificat.post wf_SetKey(ls_cm)
			END IF
		END IF
		
	CASE ELSE
		return
END CHOOSE
end event

type st_1 from uo_statictext within tabpage_melange
integer x = 55
integer y = 16
integer width = 1518
integer weight = 700
long textcolor = 8388608
string text = "Composant(s) de ce lot mélangé :"
alignment alignment = center!
end type

