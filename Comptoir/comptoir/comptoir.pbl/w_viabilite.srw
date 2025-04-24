//objectcomments Gestion des tests de viabilité
forward
global type w_viabilite from w_ancestor_dataentry
end type
type dw_viab from uo_datawindow_singlerow within w_viabilite
end type
end forward

global type w_viabilite from w_ancestor_dataentry
integer width = 2921
integer height = 1736
string title = "Tests de viabilité"
boolean maxbox = true
boolean resizable = true
dw_viab dw_viab
end type
global w_viabilite w_viabilite

type variables
string	is_reflot, is_typetest
integer	ii_numtest, ii_nbrep
boolean	ib_readonly, ib_ajout
uo_cpteur	iu_cpteur
br_graine_viabilite	ibr_viab

end variables

forward prototypes
public subroutine wf_init_position ()
public function integer wf_init ()
public function integer wf_newtest ()
public function integer wf_setkey (string as_reflot, integer ai_numtest, boolean ab_readonly)
public function integer wf_valide_registre ()
end prototypes

public subroutine wf_init_position ();// Lors du design du DW, les items pour un test à l'écrasement sont correctements positionnés
// tandis que ceux pour un test à la coupe sont déplacés pour ne pas chevaucher les autres.
// On replace ici correctement les items de tests à la coupe, une fois en début de programme.
// Le caractère visible ou pas est quant à lui géré par une expression sur chacun des items.
integer	li_x, li_esp

li_x = integer(dw_viab.object.t_e_vides1.x)
li_esp = 932

dw_viab.setRedraw(FALSE)
dw_viab.object.t_coupe_bons1.x = li_x
dw_viab.object.t_coupe_mauvais1.x = (li_x + 18) + integer(dw_viab.object.t_coupe_bons1.width)
	
dw_viab.object.t_coupe_bons2.x = li_x + li_esp
dw_viab.object.t_coupe_mauvais2.x = (li_x + li_esp + 18) + integer(dw_viab.object.t_coupe_bons2.width)
		
dw_viab.object.t_coupe_bons3.x = li_x + (li_esp * 2)
dw_viab.object.t_coupe_mauvais3.x = (li_x + (li_esp * 2) + 18) + integer(dw_viab.object.t_coupe_bons3.width)

dw_viab.object.nbre1.x = dw_viab.object.t_coupe_bons1.x
dw_viab.object.nbre2.x = dw_viab.object.nbre1.x
dw_viab.object.nbre3.x = dw_viab.object.nbre1.x
dw_viab.object.nbre4.x = dw_viab.object.nbre1.x
dw_viab.object.c_c_pcbons.x = dw_viab.object.nbre1.x
		
dw_viab.object.c_mauvais1.x = dw_viab.object.t_coupe_mauvais1.x
dw_viab.object.c_mauvais2.x = dw_viab.object.c_mauvais1.x
dw_viab.object.c_mauvais3.x = dw_viab.object.c_mauvais1.x
dw_viab.object.c_mauvais4.x = dw_viab.object.c_mauvais1.x
dw_viab.object.c_pcmauvais.x = dw_viab.object.c_mauvais1.x
		
dw_viab.object.qte_rep1_2.x = 18 + integer(dw_viab.object.c_mauvais1.x) + integer(dw_viab.object.c_mauvais1.width)
dw_viab.object.qte_rep2_2.x = dw_viab.object.qte_rep1_2.x
dw_viab.object.qte_rep3_2.x = dw_viab.object.qte_rep1_2.x
dw_viab.object.qte_rep4_2.x = dw_viab.object.qte_rep1_2.x
		
dw_viab.object.nbre5.x = dw_viab.object.t_coupe_bons2.x
dw_viab.object.nbre6.x = dw_viab.object.nbre5.x
dw_viab.object.nbre7.x = dw_viab.object.nbre5.x
dw_viab.object.nbre8.x = dw_viab.object.nbre5.x
		
dw_viab.object.c_mauvais5.x = dw_viab.object.t_coupe_mauvais2.x
dw_viab.object.c_mauvais6.x = dw_viab.object.c_mauvais5.x
dw_viab.object.c_mauvais7.x = dw_viab.object.c_mauvais5.x
dw_viab.object.c_mauvais8.x = dw_viab.object.c_mauvais5.x
		
dw_viab.object.qte_rep5_2.x = 18 + integer(dw_viab.object.c_mauvais5.x) + integer(dw_viab.object.c_mauvais5.width)
dw_viab.object.qte_rep6_2.x = dw_viab.object.qte_rep5_2.x
dw_viab.object.qte_rep7_2.x = dw_viab.object.qte_rep5_2.x
dw_viab.object.qte_rep8_2.x = dw_viab.object.qte_rep5_2.x
		
dw_viab.object.nbre9.x = dw_viab.object.t_coupe_bons3.x
dw_viab.object.nbre10.x = dw_viab.object.nbre9.x
dw_viab.object.nbre11.x = dw_viab.object.nbre9.x
dw_viab.object.nbre12.x = dw_viab.object.nbre9.x
		
dw_viab.object.c_mauvais9.x = dw_viab.object.t_coupe_mauvais3.x
dw_viab.object.c_mauvais10.x = dw_viab.object.c_mauvais9.x
dw_viab.object.c_mauvais11.x = dw_viab.object.c_mauvais9.x
dw_viab.object.c_mauvais12.x = dw_viab.object.c_mauvais9.x
		
dw_viab.object.qte_rep9_2.x = 18 + integer(dw_viab.object.c_mauvais9.x) + integer(dw_viab.object.c_mauvais9.width)
dw_viab.object.qte_rep10_2.x = dw_viab.object.qte_rep9_2.x
dw_viab.object.qte_rep11_2.x = dw_viab.object.qte_rep9_2.x
dw_viab.object.qte_rep12_2.x = dw_viab.object.qte_rep9_2.x

dw_viab.setRedraw(TRUE)

end subroutine

public function integer wf_init ();string	ls_reflot

IF dw_viab.uf_IsRecordNew() THEN
	// valeurs par défaut pour nouveau record
	dw_viab.object.dt_mesure[1] = f_today()
	dw_viab.uf_setdefaultvalue(1, "nb_rep", 4)
	dw_viab.uf_setdefaultvalue(1, "type_test", "C")
END IF

is_typetest = dw_viab.object.type_test[1]
ii_nbrep = dw_viab.object.nb_rep[1]

// disabler la clé et enabler les datas (si pas mode disabled)
dw_viab.setredraw(FALSE)
IF NOT ib_readonly THEN dw_viab.uf_enableData()
dw_viab.uf_disablekeys()
dw_viab.setredraw(TRUE)

dw_viab.SetColumn("type_test")

dw_viab.SetItemStatus(1,0,Primary!,NotModified!)
dw_viab.SetFocus()

return(1)
end function

public function integer wf_newtest ();// création d'un nouveau test
decimal	ld_numtest

// la ref. du lot doit être spécifié
IF f_isEmptyString(is_reflot) THEN
	gu_message.uf_error("Veuillez d'abord sélectionner la référence du lot")
	return(-1)
END IF

// prendre nouveau n° de commande via le compteur, le placer dans num_cmde et passer au champ suivant
ld_numtest = iu_cpteur.uf_getnumviab(is_reflot)
IF ld_numtest < 0 THEN
	gu_message.uf_error("Impossible d'obtenir un nouveau n° de test de viabilité !")
	return(-1)
END IF
ib_ajout = TRUE
dw_viab.setfocus()
dw_viab.SetText(string(ld_numtest))
f_presskey ("TAB")

return(1)

end function

public function integer wf_setkey (string as_reflot, integer ai_numtest, boolean ab_readonly);// utilisé par un programme externe pour ouvrir un test
IF f_isEmptyString(as_reflot) OR isNull(ai_numtest) OR ai_numtest = 0 THEN
	return(-1)
END IF

IF dw_viab.uf_SetDefaultValue(1, "ref_lot", as_reflot) < 0 THEN 
	return(-1)
END IF
IF dw_viab.uf_SetDefaultValue(1, "num_test", ai_numtest) < 0 THEN 
	return(-1)
END IF

ib_readonly = ab_readonly

return(1)
end function

public function integer wf_valide_registre ();// Création ou mise à jour ligne caractéristiques graines dans REGISTRE_QGERM
integer	li_status, li_num
long		ll_count
string	ls_rem, ls_err
date		ld_dtmesure
decimal	ld_viabilite

// 1. récupérer les champs utiles pour la row à créer dans REGISTRE_QGERM
ld_dtmesure = date(dw_viab.object.dt_mesure[1])
ls_rem = string(dw_viab.object.rem[1])
IF is_typetest = "C" THEN
	ld_viabilite = dw_viab.object.c_c_pcbons[1]
ELSE
	ld_viabilite = dw_viab.object.c_e_pcbons[1]
END IF

// 2. créer ou mettre à jour la ligne de caractéristiques éventuellement déjà générée
//    au niveau du registre. Utiliser SQLCA pour commiter en même temps que l'update de dw_qgerm.
// Vérifier s'il existe déjà ou pas une ligne pour le test en cours dans REGISTRE_QGERM.
select count(*) into :ll_count from registre_qgerm where ref_lot = :is_reflot and num_test_viab = :ii_numtest using SQLCA;
IF f_check_sql(SQLCA) = -1 THEN
	populateerror(20000, "")
	ls_err = "Erreur SELECT REGISTRE_QGERM"
	GOTO ERREUR
END IF

// a. plusieurs lignes pour le test : théoriquement impossible --> ERREUR !
IF ll_count > 1 THEN
	populateerror(20000, "")
	ls_err = "Erreur : il existe plusieurs occurences dans REGISTRE_QGERM pour le même test !~n" + &
				"Il faut régler cette situation (avec l'aide du support informatique) et enregistrer à nouveau !"
	GOTO ERREUR
END IF

CHOOSE CASE ll_count
	// b. il n'existe pas encore de row dans REGISTRE_QGERM pour ce test : on la crée
	CASE 0
		// trouver prochain n° de ligne pour le lot dans REGISTRE_QGERM
		select nvl(max(num_qgerm),0) + 1 into :li_num from registre_qgerm where ref_lot = :is_reflot using SQLCA;
		IF li_num > 99 THEN
			populateerror(20000, "")
			ls_err = "N° de ligne dans REGISTRE_QGERM > 100, impossible de continuer !"
			GOTO ERREUR
		END IF
		IF isNull(li_num) THEN
			li_num = 1
		END IF
		insert into registre_qgerm (REF_LOT,NUM_QGERM,DT_QGERM,REM,VIABILITE,NUM_TEST_VIAB) 
			values (:is_reflot,:li_num,:ld_dtmesure,:ls_rem,:ld_viabilite,:ii_numtest) using SQLCA;
		IF f_check_sql(SQLCA) = -1 THEN
			populateerror(20000, "")
			ls_err = "Erreur INSERT INTO REGISTRE_QGERM"
			GOTO ERREUR
		END IF
		
	// c. il existe déjà une (et une seule) ligne dans REGISTRE_QGERM pour ce test : on la met à jour
	CASE 1
		update registre_qgerm
			set dt_qgerm = :ld_dtmesure, rem=:ls_rem, viabilite=:ld_viabilite
			where ref_lot=:is_reflot and num_test_viab = :ii_numtest
			using SQLCA;
		IF f_check_sql(SQLCA) = -1 THEN
			populateerror(20000, "")
			ls_err = "Erreur UPDATE REGISTRE_QGERM"
			GOTO ERREUR
		END IF
END CHOOSE

commit using SQLCA;
return(1)

ERREUR:
rollback using SQLCA;
gu_message.uf_unexp(ls_err)
return(-1)
end function

on w_viabilite.create
int iCurrent
call super::create
this.dw_viab=create dw_viab
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_viab
end on

on w_viabilite.destroy
call super::destroy
destroy(this.dw_viab)
end on

event ue_init_menu;call super::ue_init_menu;string	ls_menu[]
integer	li_item

li_item = 2
ls_menu = {"m_abandonner", "m_fermer"}

IF wf_IsActif() AND NOT ib_readonly THEN
	// activer option "enregistrer" si modifications autorisées
	IF wf_canUpdate() THEN
		li_item++
		ls_menu[li_item] = "m_enregistrer"
	END IF
	// activer option "supprimer" si suppressions autorisées (suppression de tout le test)
	IF NOT dw_viab.uf_IsRecordNew() AND wf_canDelete() THEN
		li_item++
		ls_menu[li_item] = "m_supprimer"
	END IF
ELSE
	// activer bouton "ajouter" si curseur dans n° de test et modif.autorisées
	IF dw_viab.GetColumnName() = "num_test" AND wf_canUpdate() THEN
		li_item++
		ls_menu[li_item] = "m_ajouter"
	END IF
END IF

f_menuaction(ls_menu)



end event

event ue_init_win;call super::ue_init_win;ib_ajout = FALSE
ib_readonly = FALSE
SetNull(is_reflot)
SetNull(ii_numtest)
ii_nbrep = 0

iu_cpteur.uf_rollback()

this.setredraw(FALSE)

dw_viab.uf_reset()
dw_viab.insertrow(0)

dw_viab.uf_disabledata()
dw_viab.uf_enablekeys()

IF f_isEmptyString(is_reflot) THEN
	dw_viab.object.ref_lot[1] = ""
	dw_viab.Setcolumn("ref_lot")
ELSE
	dw_viab.uf_setdefaultvalue(1, "ref_lot", is_reflot)
	dw_viab.Setcolumn("num_test")
END IF

dw_viab.uf_setdefaultvalue(1, "type_test", "C")

dw_viab.setfocus()

this.setredraw(TRUE)
end event

event ue_open;call super::ue_open;ibr_viab = CREATE br_graine_viabilite
iu_cpteur = CREATE uo_cpteur

// icône "ajouter" doit être visible dans le menu
wf_SetItemsToShow({"m_ajouter"})

wf_SetDWList({dw_viab})

// voir commentaires dans la fonction
wf_init_position()
end event

event ue_close;call super::ue_close;DESTROY ibr_viab
DESTROY iu_cpteur
end event

event ue_ajouter;call super::ue_ajouter;long	ll_row

CHOOSE CASE wf_GetActivecontrolname()
	// ajouter une nouveau test si le curseur est sur DW_VIAB et dans l'item NUM_TEST
	CASE "dw_viab"
		IF dw_viab.GetColumnName() = "num_test" THEN
			wf_newtest()
			return
		END IF
END CHOOSE
end event

event ue_enregistrer;call super::ue_enregistrer;integer	li_status, li_num, li_i, li_qterep
long		ll_count
string	ls_rem, ls_err
date		ld_dtmesure

// s'assurer que la quantité de graines dans chaque répétition sauf la dernière est égale
// à la quantité initiale
li_qterep = dw_viab.object.qte_rep[1]
FOR li_i = 1 TO ii_nbrep - 1
	dw_viab.setitem(1, "qte_rep" + string(li_i), li_qterep)
NEXT
// s'assurer qu'il y a NULL dans le nombre de graines dans les répétitions non utilisées
FOR li_i = ii_nbrep + 1 TO 12
	dw_viab.setitem(1, "qte_rep" + string(li_i), gu_c.i_null)
	dw_viab.setitem(1, "nbre" + string(li_i), gu_c.i_null)
	dw_viab.setitem(1, "vide" + string(li_i), gu_c.i_null)
	dw_viab.setitem(1, "parasite" + string(li_i), gu_c.i_null)
NEXT
FOR li_i = 1 TO 12
	IF is_typetest = "C" THEN
		dw_viab.setitem(1, "vide" + string(li_i), gu_c.i_null)
		dw_viab.setitem(1, "parasite" + string(li_i), gu_c.i_null)
	ELSE
		dw_viab.setitem(1, "nbre" + string(li_i), gu_c.i_null)
	END IF
NEXT

// contrôle de validité de tous les champs
IF dw_viab.event ue_checkall() < 0 THEN
	dw_viab.SetFocus()
	return(-1)
END IF

// update dw_viab
li_status = gu_dwservices.uf_updatetransact(dw_viab)
CHOOSE CASE li_status
	CASE 1
		// si nouveau test, updater compteur
		IF dw_viab.uf_IsRecordNew() THEN
			IF iu_cpteur.uf_update_numviab(is_reflot, ii_numtest) = -1 THEN
				populateerror(20000, "")
				gu_message.uf_unexp("Erreur mise à jour du compteur VIABILITE.NUM_TEST")
			END IF
		END IF
		
		// créer/mettre à jour caractéristiques dans le registre
		IF wf_valide_registre() = -1 THEN
			populateerror(20000, "")
			gu_message.uf_unexp("Erreur création du test de viabilité dans le registre !!!!")
			return(-1)
		END IF

		wf_message("Test de viabilité " + is_reflot + "/" + f_string(ii_numtest) + " enregistré avec succès")
		This.event ue_init_win()
		return(1)
	CASE -1
		populateerror(20000,"")
		gu_message.uf_unexp("GRAINE_VIABILITE : Erreur lors de la mise à jour de la base de données")
		return(-1)
END CHOOSE

return(1)
end event

event ue_supprimer;call super::ue_supprimer;long		ll_row
string	ls_message
integer	li_numtest_qgerm

// vérifier l'utilisation du test et construire message
li_numtest_qgerm = ibr_viab.uf_check_beforedelete(is_reflot, ii_numtest, ls_message)
IF li_numtest_qgerm = -1 THEN
	gu_message.uf_error(ls_message)
	return
END IF
		
// confirmer ?
IF f_confirm_del(ls_message + "Confirmez-vous la suppression de ce test ?") = 1 THEN
	IF dw_viab.event ue_delete() = 1 THEN
		// suppression des références dans DOCFRN
		IF li_numtest_qgerm > 0 THEN
			update DOCFRN
				set NUM_QGERM = null	where REF_LOT=:is_reflot and num_qgerm=:li_numtest_qgerm using ESQLCA;
			IF f_check_sql(ESQLCA) < 0 THEN
				rollback using ESQLCA;
				populateError(20000, "")
				gu_message.uf_unexp("ERREUR UPDATE DOCFRN~n~n" + &
					"La référence du test supprimé n'a pas pu être annulée dans les documents fournisseur !")
			END IF
		END IF
		// normalement, les "many" sont supprimés par les contraintes mais...
		delete from registre_qgerm where ref_lot = :is_reflot and num_test_viab=:ii_numtest using ESQLCA;
		IF f_check_sql(ESQLCA) = 0 AND ESQLCA.sqlnrows <> 0 THEN
			commit using ESQLCA;
			populateerror(20000,"")
			gu_message.uf_unexp("Les contraintes d'intégrité entre GRAINE_VIABILITE et REGISTRE_QGERM ne sont pas actives !", 2)
		END IF

	// remarque : commit ou rollback nécessaire après les delete ci-dessus, même s'ils n'ont aucun effet !
	// Si on ne le fait pas, les LOCK subsistent !
	commit using ESQLCA;
	wf_message("Test de viabilité supprimé avec succès")
	this.event ue_init_win()
	END IF
END IF

end event

type ddlb_message from w_ancestor_dataentry`ddlb_message within w_viabilite
integer y = 1520
end type

type dw_viab from uo_datawindow_singlerow within w_viabilite
integer x = 18
integer width = 2853
integer height = 1504
integer taborder = 10
string dataobject = "d_viabilite"
end type

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

	CASE "num_test"
		lstr_params.a_param[1] = is_reflot
		lstr_params.a_param[2] = TRUE
		lstr_params.a_param[3] = FALSE
		openwithparm(w_l_viabilite, lstr_params)
		IF Message.DoubleParm = -1 THEN 
			return
		ELSE
			lstr_params=Message.PowerObjectParm
			this.uf_setdefaultvalue(1, "ref_lot", string(lstr_params.a_param[1]))
			this.SetText(f_string(lstr_params.a_param[2]))
			f_presskey("TAB")
		END IF


END CHOOSE


end event

event getfocus;call super::getfocus;parent.event post ue_init_menu()
end event

event itemfocuschanged;call super::itemfocuschanged;parent.event post ue_init_menu()
end event

event ue_checkitem;call super::ue_checkitem;integer	li_status, li_numtest, li_nbreinit, li_nbreVide, li_nbreParasite
long	ll_count

CHOOSE CASE as_item
	CASE "ref_lot"
		IF ibr_viab.uf_check_reflot(as_data, as_message) = -1 THEN
			return(-1)
		ELSE
			is_reflot = as_data
			return(1)
		END IF
		
	// dernier élément de la clé, vérifier si record existe ou pas
	CASE "num_test"
		IF ibr_viab.uf_check_numtest(as_data, as_message) = -1 THEN
			iu_cpteur.uf_rollback()
			return(-1)
		END IF
		li_numtest = integer(as_data)
		select count(*) into :ll_count from graine_viabilite
				where ref_lot = :is_reflot and num_test=:li_numtest using ESQLCA;
		li_status = f_check_sql(ESQLCA)
		IF li_status < 0 OR ll_count > 1 THEN
			populateerror(20000,"")
			gu_message.uf_unexp("Erreur SELECT GRAINE_VIABILITE")
			return(-1)
		ELSE
			// test inexistant...
			IF ll_count = 0 THEN
				// ...et on peut modifier les données...
				IF wf_canUpdate() THEN
					IF ib_ajout THEN
						this.uf_NewRecord(TRUE)
						ii_numtest = li_numtest
						return(1)
					ELSE
						as_message = "Test de viabilité inexistant. Utilisez l'action 'Ajouter' pour en créer un."
						return(-1)
					END IF
				ELSE
				// ...et on ne peut pas modifier les données
					as_message = "Test de viabilité inexistant. Vous n'avez pas le droit d'en créer..."
					return(-1)
				END IF
			ELSE
			// test existe déjà : OK
				this.uf_NewRecord(FALSE)
				ii_numtest = li_numtest
				return(1)
			END IF
		END IF
		
	CASE "type_test"
		return(ibr_viab.uf_check_typetest(as_data, as_message))
		
	CASE "dt_mesure"
		return(ibr_viab.uf_check_dtmesure(as_data, as_message))
		
	CASE "rem"
		return(ibr_viab.uf_check_rem(as_data, as_message))
		
	CASE "nb_rep"
		return(ibr_viab.uf_check_nbrep(as_data, as_message))
		
	CASE "qte_rep"
		return(ibr_viab.uf_check_qterep(as_data, as_message))
		
	CASE "qte_rep1", "qte_rep2", "qte_rep3", "qte_rep4", "qte_rep5", "qte_rep6", &
		  "qte_rep7", "qte_rep8", "qte_rep9", "qte_rep10", "qte_rep11", "qte_rep12"
		// ne tester que les items pour les répétitions demandées, ignorer les autres
		IF integer(mid(as_item, 8)) > ii_nbrep THEN 
			return(1)
		ELSE
			return(ibr_viab.uf_check_qterep(as_data, as_message))
		END IF
				
	CASE "nbre1", "nbre2", "nbre3", "nbre4", "nbre5", "nbre6", &
		  "nbre7", "nbre8", "nbre9", "nbre10", "nbre11", "nbre12"
		// uniquement pour les tests à la coupe
		IF is_typetest <> "C" THEN return(1)
		// ne tester que les items pour les répétitions demandées, ignorer les autres
		IF integer(mid(as_item, 5)) > ii_nbrep THEN 
			return(1)
		ELSE
			li_nbreinit = this.getitemnumber(1, "qte_rep" + mid(as_item, 5))
			return(ibr_viab.uf_check_nbre(as_data, as_message, is_typetest, li_nbreinit))
		END IF
		
	CASE "vide1", "vide2", "vide3", "vide4", "vide5", "vide6", &
		  "vide7", "vide8", "vide9", "vide10", "vide11", "vide12"
  		// uniquement pour les tests à l'écrasement
		IF is_typetest <> "E" THEN return(1)
		// ne tester que les items pour les répétitions demandées, ignorer les autres
		IF integer(mid(as_item, 5)) > ii_nbrep THEN 
			return(1)
		ELSE
			li_nbreinit = this.getitemnumber(1, "qte_rep" + mid(as_item, 5))
			li_nbreParasite = this.getitemnumber(1, "parasite" + mid(as_item, 5))
			return(ibr_viab.uf_check_vide(as_data, as_message, is_typetest, li_nbreinit, li_nbreParasite))
		END IF
		
	CASE "parasite1", "parasite2", "parasite3", "parasite4", "parasite5", "parasite6", &
		  "parasite7", "parasite8", "parasite9", "parasite10", "parasite11", "parasite12"
		// uniquement pour les tests à l'écrasement
		IF is_typetest <> "E" THEN return(1)
		// ne tester que les items pour les répétitions demandées, ignorer les autres
		IF integer(mid(as_item, 9)) > ii_nbrep THEN 
			return(1)
		ELSE
			li_nbreinit = this.getitemnumber(1, "qte_rep" + mid(as_item, 9))
			li_nbreVide = this.getitemnumber(1, "vide" + mid(as_item, 9))
			return(ibr_viab.uf_check_parasite(as_data, as_message, is_typetest, li_nbreinit, li_nbreVide))
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
	wf_message("Modification d'un test...")
	this.retrieve(is_reflot, ii_numtest)
ELSE
	wf_message("Nouveau test...")
END IF

parent.event ue_init_menu()
post wf_init()

end event

event ue_itemvalidated;call super::ue_itemvalidated;integer	li_i, li_qterep

CHOOSE CASE as_name
	CASE "type_test"
		is_typetest = as_data
		
	// recopier le nombre de graines dans toutes les répétions demandées
	// + annuler les valeurs pour les répétitions au delà de celles demandées.
	CASE "qte_rep"
		li_qterep = integer(as_data)
		FOR li_i = 1 TO ii_nbrep
			this.setitem(al_row, "qte_rep" + string(li_i), li_qterep)
		NEXT
		FOR li_i = ii_nbrep + 1 TO 12
			this.setitem(al_row, "qte_rep" + string(li_i), gu_c.i_null)
		NEXT
	CASE "nb_rep"
		li_qterep = int(this.object.qte_rep[al_row])
		ii_nbrep = integer(as_data)
		FOR li_i = 1 TO ii_nbrep
			this.setitem(al_row, "qte_rep" + string(li_i), li_qterep)
		NEXT
		FOR li_i = ii_nbrep + 1 TO 12
			this.setitem(al_row, "qte_rep" + string(li_i), gu_c.i_null)
			this.setitem(al_row, "nbre" + string(li_i), gu_c.i_null)
			this.setitem(al_row, "vide" + string(li_i), gu_c.i_null)
			this.setitem(al_row, "parasite" + string(li_i), gu_c.i_null)
		NEXT
END CHOOSE
end event

