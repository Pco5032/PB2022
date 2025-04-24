//objectcomments Gestion des caractéristiques physiques des graines
forward
global type w_cphys from w_ancestor_dataentry
end type
type dw_cphys from uo_datawindow_singlerow within w_cphys
end type
end forward

global type w_cphys from w_ancestor_dataentry
integer width = 3858
integer height = 2152
string title = "Caractéristiques physiques des graines"
dw_cphys dw_cphys
end type
global w_cphys w_cphys

type variables
br_graine_cphys	ibr_cphys
uo_cpteur			iu_cpteur

boolean	ib_ajout, ib_readonly
string	is_reflot
integer	ii_numtest
end variables

forward prototypes
public function integer wf_init ()
public function integer wf_newtest ()
public function integer wf_valide_registre ()
public function integer wf_setkey (string as_reflot, integer ai_numtest, boolean ab_readonly)
end prototypes

public function integer wf_init ();string	ls_reflot

IF dw_cphys.uf_IsRecordNew() THEN
	// valeurs par défaut pour nouveau record
	dw_cphys.object.dt_mesure[1] = f_today()
	// défauts pour poids de 1000 graines
	dw_cphys.uf_setdefaultvalue(1, "pds_nbr", 4)
	dw_cphys.uf_setdefaultvalue(1, "pds_nbg", 100)
	// défaut pour test d'humidité
	dw_cphys.object.hum_nbr[1] = 4
END IF

// disabler la clé et enabler les datas (si pas mode disabled)
dw_cphys.setredraw(FALSE)
IF NOT ib_readonly THEN dw_cphys.uf_enableData()
dw_cphys.uf_disablekeys()
dw_cphys.setredraw(TRUE)

dw_cphys.SetColumn("dt_mesure")

dw_cphys.SetItemStatus(1,0,Primary!,NotModified!)
dw_cphys.SetFocus()

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
ld_numtest = iu_cpteur.uf_getnumcphys(is_reflot)
IF ld_numtest < 0 THEN
	gu_message.uf_error("Impossible d'obtenir un nouveau n° de test de caractéristiques physiques !")
	return(-1)
END IF
ib_ajout = TRUE
dw_cphys.setfocus()
dw_cphys.SetText(string(ld_numtest))
f_presskey ("TAB")

return(1)

end function

public function integer wf_valide_registre ();// Création ou mise à jour ligne caractéristiques graines dans REGISTRE_CPHYS
integer	li_status, li_num
long		ll_count
string		ls_rem, ls_err
date			ld_dtmesure
decimal{3}	ld_pds1000
decimal{2}	ld_purete_bon, ld_purete_autre, ld_purete_inerte, ld_humrap, ld_humdef, ld_teneurEau

// 1. récupérer les champs utiles pour la row à créer dans REGISTRE_CPHYS
ld_dtmesure = date(dw_cphys.object.dt_mesure[1])
ls_rem = string(dw_cphys.object.rem[1])
ld_pds1000 = dw_cphys.object.c_pds1000[1]
ld_purete_bon = dw_cphys.object.c_purete_bon[1]
ld_purete_autre = dw_cphys.object.c_purete_autre[1]
ld_purete_inerte = dw_cphys.object.c_purete_inerte[1]
ld_humrap = dw_cphys.object.hum_rap[1]
ld_humdef = dw_cphys.object.c_humdef[1]
// choix humidié selon ce qui est disponible
setNull(ld_teneurEau)
IF NOT isNull(ld_humrap) THEN ld_teneurEau = ld_humrap
IF NOT isNull(ld_humdef) THEN ld_teneurEau = ld_humdef

// 2. créer ou mettre à jour la ligne de caractéristiques éventuellement déjà générée
//    au niveau du registre. Utiliser SQLCA pour commiter en même temps que l'update de DW_CPHYS.
// Vérifier s'il existe déjà ou pas une ligne pour le test en cours dans REGISTRE_CPHYS.
select count(*) into :ll_count from registre_cphys where ref_lot = :is_reflot and num_test_cphys = :ii_numtest using SQLCA;
IF f_check_sql(SQLCA) = -1 THEN
	populateerror(20000, "")
	ls_err = "Erreur SELECT REGISTRE_CPHYS"
	GOTO ERREUR
END IF

// a. plusieurs lignes pour le test : théoriquement impossible --> ERREUR !
IF ll_count > 1 THEN
	populateerror(20000, "")
	ls_err = "Erreur : il existe plusieurs occurences dans REGISTRE_CPHYS pour le même test !~n" + &
				"Il faut régler cette situation (avec l'aide du support informatique) et enregistrer à nouveau !"
	GOTO ERREUR
END IF

CHOOSE CASE ll_count
	// b. il n'existe pas encore de row dans REGISTRE_CPHYS pour ce test : on la crée
	CASE 0
		// trouver prochain n° de ligne pour le lot dans REGISTRE_CPHYS
		select nvl(max(num_cphys),0) + 1 into :li_num from registre_cphys where ref_lot = :is_reflot using SQLCA;
		IF li_num > 99 THEN
			populateerror(20000, "")
			ls_err = "N° de ligne dans REGISTRE_CPHYS > 100, impossible de continuer !"
			GOTO ERREUR
		END IF
		IF isNull(li_num) THEN
			li_num = 1
		END IF
		insert into registre_cphys (REF_LOT,DT_CPHYS,NUM_CPHYS,REM,PURETE_BON,PURETE_INERTE,
											 PURETE_AUTRE,PDS1000,TENEUR_EAU,NUM_TEST_CPHYS) 
			values (:is_reflot,:ld_dtmesure,:li_num,:ls_rem,:ld_purete_bon,:ld_purete_inerte,
					  :ld_purete_autre,:ld_pds1000,:ld_teneureau,:ii_numtest) using SQLCA;
		IF f_check_sql(SQLCA) = -1 THEN
			populateerror(20000, "")
			ls_err = "Erreur INSERT INTO REGISTRE_CPHYS"
			GOTO ERREUR
		END IF
		
	// c. il existe déjà une (et une seule) ligne dans REGISTRE_CPHYS pour ce test : on la met à jour
	CASE 1
		update registre_cphys
			set dt_cphys = :ld_dtmesure, rem=:ls_rem, purete_bon=:ld_purete_bon, 
				 purete_inerte=:ld_purete_inerte, purete_autre=:ld_purete_autre,
				 pds1000=:ld_pds1000, teneur_eau=:ld_teneurEau
			where ref_lot=:is_reflot and num_test_cphys = :ii_numtest
			using SQLCA;
		IF f_check_sql(SQLCA) = -1 THEN
			populateerror(20000, "")
			ls_err = "Erreur UPDATE REGISTRE_CPHYS"
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

public function integer wf_setkey (string as_reflot, integer ai_numtest, boolean ab_readonly);// utilisé par un programme externe pour ouvrir un test
IF f_isEmptyString(as_reflot) OR isNull(ai_numtest) OR ai_numtest = 0 THEN
	return(-1)
END IF

IF dw_cphys.uf_SetDefaultValue(1, "ref_lot", as_reflot) < 0 THEN 
	return(-1)
END IF
IF dw_cphys.uf_SetDefaultValue(1, "num_test", ai_numtest) < 0 THEN 
	return(-1)
END IF

ib_readonly = ab_readonly

return(1)
end function

on w_cphys.create
int iCurrent
call super::create
this.dw_cphys=create dw_cphys
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_cphys
end on

on w_cphys.destroy
call super::destroy
destroy(this.dw_cphys)
end on

event ue_open;call super::ue_open;ibr_cphys = CREATE br_graine_cphys
iu_cpteur = CREATE uo_cpteur

// icône "ajouter" et "nullify" doivent être visibles dans le menu
wf_SetItemsToShow({"m_ajouter","m_nullify"})

wf_SetDWList({dw_cphys})

end event

event ue_init_menu;call super::ue_init_menu;string	ls_menu[], ls_colname
integer	li_item

li_item = 2
ls_menu = {"m_abandonner", "m_fermer"}
ls_colname = dw_cphys.GetColumnName()

IF wf_IsActif() AND NOT ib_readonly THEN
	// activer option "enregistrer" si modifications autorisées
	IF wf_canUpdate() THEN
		li_item++
		ls_menu[li_item] = "m_enregistrer"
	END IF
	// activer option "supprimer" si suppressions autorisées
	IF NOT dw_cphys.uf_IsRecordNew() AND wf_canDelete() THEN
		li_item++
		ls_menu[li_item] = "m_supprimer"
	END IF
	// activer option "nullify" pour certaines item, si modifications autorisées
	IF wf_canUpdate() AND (ls_colname = "purete_bon" OR &
			ls_colname = "purete_inerte" OR ls_colname = "purete_autre" OR &
			ls_colname = "hum_rap") OR match(ls_colname, "^hum_etuv_ps") THEN
		li_item++
		ls_menu[li_item] = "m_nullify"
	END IF
ELSE
	// activer bouton "ajouter" si curseur dans n° de test et modif.autorisées
	IF ls_colname = "num_test" AND wf_canUpdate() THEN
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

iu_cpteur.uf_rollback()

this.setredraw(FALSE)

dw_cphys.uf_reset()
dw_cphys.insertrow(0)

dw_cphys.uf_disabledata()
dw_cphys.uf_enablekeys()

IF f_isEmptyString(is_reflot) THEN
	dw_cphys.object.ref_lot[1] = ""
	dw_cphys.Setcolumn("ref_lot")
ELSE
	dw_cphys.uf_setdefaultvalue(1, "ref_lot", is_reflot)
	dw_cphys.Setcolumn("num_test")
END IF
dw_cphys.setfocus()

this.setredraw(TRUE)
end event

event ue_close;call super::ue_close;DESTROY ibr_cphys
DESTROY iu_cpteur
end event

event ue_ajouter;call super::ue_ajouter;long	ll_row

CHOOSE CASE wf_GetActivecontrolname()
	// ajouter une nouveau test si le curseur est sur DW_CPHYS et dans l'item NUM_TEST
	CASE "dw_cphys"
		IF dw_cphys.GetColumnName() = "num_test" THEN
			wf_newtest()
			return
		END IF
END CHOOSE
end event

event ue_supprimer;call super::ue_supprimer;string	ls_message
integer	li_numtest_cphys

// suppression des caractéristiques
// vérifier l'utilisation du test et construire message
li_numtest_cphys = ibr_cphys.uf_check_beforedelete(is_reflot, ii_numtest, ls_message)
IF li_numtest_cphys = -1 THEN
	gu_message.uf_error(ls_message)
	return
END IF

// confirmer ?
IF f_confirm_del(ls_message + "Confirmez-vous la suppression de ce test ?") = 1 THEN
	IF dw_cphys.event ue_delete() = 1 THEN
		// suppression des références dans DOCFRN
		IF li_numtest_cphys > 0 THEN
			update DOCFRN
				set NUM_CPHYS = null	where REF_LOT=:is_reflot and num_cphys=:li_numtest_cphys using ESQLCA;
			IF f_check_sql(ESQLCA) < 0 THEN
				rollback using ESQLCA;
				populateError(20000, "")
				gu_message.uf_unexp("ERREUR UPDATE DOCFRN~n~n" + &
					"La référence des caractéristiques supprimées n'a pas pu être annulées dans les documents fournisseur !")
			END IF
		END IF
		
		// normalement, les "many" sont supprimés par les contraintes mais...
		delete from registre_cphys where ref_lot = :is_reflot and num_test_cphys=:ii_numtest using ESQLCA;
		IF f_check_sql(ESQLCA) = 0 AND ESQLCA.sqlnrows <> 0 THEN
			commit using ESQLCA;
			populateerror(20000,"")
			gu_message.uf_unexp("Les contraintes d'intégrité entre GRAINE_CPHYS et REGISTRE_CPHYS ne sont pas actives !", 2)
		END IF

		// remarque : commit ou rollback nécessaire après les delete ci-dessus, même s'ils n'ont aucun effet !
		// Si on ne le fait pas, les LOCK subsistent !
		commit using ESQLCA;
		wf_message("Caractéristiques physiques supprimées...")
		this.event ue_init_win()
		END IF
END IF

end event

event ue_enregistrer;call super::ue_enregistrer;integer	li_status, li_num
long		ll_count
string		ls_rem, ls_err
date			ld_dtmesure
decimal{3}	ld_pds1000
decimal{2}	ld_purete_bon, ld_purete_autre, ld_purete_inerte, ld_humrap, ld_humdef, ld_teneurEau

// contrôle de validité de tous les champs
IF dw_cphys.event ue_checkall() < 0 THEN
	dw_cphys.SetFocus()
	return(-1)
END IF

// update DW_CPHYS
li_status = gu_dwservices.uf_updatetransact(dw_cphys)
CHOOSE CASE li_status
	CASE 1
		// si nouveau test, updater compteur
		IF dw_cphys.uf_IsRecordNew() THEN
			IF iu_cpteur.uf_update_numcphys(is_reflot, ii_numtest) = -1 THEN
				populateerror(20000, "")
				gu_message.uf_unexp("Erreur mise à jour du compteur CPHYS.NUM_TEST")
			END IF
		END IF
		
		// créer/mettre à jour caractéristiques dans le registre
		IF wf_valide_registre() = -1 THEN
			populateerror(20000, "")
			gu_message.uf_unexp("Erreur création des caractéristiques dans le registre !!!!")
			return(-1)
		END IF

		wf_message("Caractéristiques physiques " + is_reflot + "/" + f_string(ii_numtest) + " enregistré avec succès")
		This.event ue_init_win()
		return(1)
	CASE -1
		populateerror(20000,"")
		gu_message.uf_unexp("GRAINE_CPHYS : Erreur lors de la mise à jour de la base de données")
		return(-1)
END CHOOSE

return(1)
end event

event ue_nullify;call super::ue_nullify;dw_cphys.event ue_nullify()

end event

type ddlb_message from w_ancestor_dataentry`ddlb_message within w_cphys
integer y = 1968
end type

type dw_cphys from uo_datawindow_singlerow within w_cphys
integer width = 3840
integer height = 1968
integer taborder = 10
boolean bringtotop = true
string dataobject = "d_cphys"
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
		openwithparm(w_l_cphys, lstr_params)
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

event ue_checkitem;call super::ue_checkitem;integer		li_status, li_numtest, li_pdsnbr, li_humnbr
decimal{2}	ld_bon, ld_inerte, ld_autre, ld_humpf
long	ll_count

CHOOSE CASE as_item
	CASE "ref_lot"
		IF ibr_cphys.uf_check_reflot(as_data, as_message) = -1 THEN
			return(-1)
		ELSE
			is_reflot = as_data
			return(1)
		END IF
		
	// dernier élément de la clé, vérifier si record existe ou pas
	CASE "num_test"
		IF ibr_cphys.uf_check_numtest(as_data, as_message) = -1 THEN
			iu_cpteur.uf_rollback()
			return(-1)
		END IF
		li_numtest = integer(as_data)
		select count(*) into :ll_count from graine_cphys
				where ref_lot = :is_reflot and num_test=:li_numtest using ESQLCA;
		li_status = f_check_sql(ESQLCA)
		IF li_status < 0 OR ll_count > 1 THEN
			populateerror(20000,"")
			gu_message.uf_unexp("Erreur SELECT GRAINE_CPHYS")
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
						as_message = "Test inexistant. Utilisez l'action 'Ajouter' pour en créer un."
						return(-1)
					END IF
				ELSE
				// ...et on ne peut pas modifier les données
					as_message = "Test inexistant. Vous n'avez pas le droit d'en créer..."
					return(-1)
				END IF
			ELSE
			// test existe déjà : OK
				this.uf_NewRecord(FALSE)
				ii_numtest = li_numtest
				return(1)
			END IF
		END IF
		
	CASE "dt_mesure"
		return(ibr_cphys.uf_check_dtmesure(as_data, as_message))
		
	CASE "rem"
		return(ibr_cphys.uf_check_rem(as_data, as_message))

	CASE "purete_bon"
		ld_inerte = dec(this.object.purete_inerte[1])
		ld_autre = dec(this.object.purete_autre[1])
		return(ibr_cphys.uf_check_purete_bon(as_data, as_message, ld_inerte, ld_autre))
		
	CASE "purete_inerte"
		ld_bon = dec(this.object.purete_bon[1])
		ld_autre = dec(this.object.purete_autre[1])
		return(ibr_cphys.uf_check_purete_inerte(as_data, as_message, ld_bon, ld_autre))
		
	CASE "purete_autre"
		ld_inerte = dec(this.object.purete_inerte[1])
		ld_bon = dec(this.object.purete_bon[1])
		return(ibr_cphys.uf_check_purete_autre(as_data, as_message, ld_bon, ld_inerte))
		
	CASE "pds_nbr"
		return(ibr_cphys.uf_check_pdsnbr(as_data, as_message))
		
	CASE "pds_nbg"
		li_pdsnbr = int(this.object.pds_nbr[1])
		return(ibr_cphys.uf_check_pdsnbg(as_data, as_message, li_pdsnbr))
		
	CASE "qte_rep1", "qte_rep2", "qte_rep3", "qte_rep4", "qte_rep5", "qte_rep6", &
		  "qte_rep7", "qte_rep8", "qte_rep9", "qte_rep10", "qte_rep11", "qte_rep12"
		li_pdsnbr = int(this.object.pds_nbr[1])
		// ne tester que les items pour les répétitions demandées, ignorer les autres
		IF integer(mid(as_item, 8)) > li_pdsnbr THEN 
			return(1)
		ELSE
			return(ibr_cphys.uf_check_qterep(as_data, as_message))
		END IF
		
	CASE "pds1", "pds2", "pds3", "pds4", "pds5", "pds6", "pds7", "pds8", "pds9", "pds10", "pds11", "pds12"
		li_pdsnbr = int(this.object.pds_nbr[1])
		// ne tester que les items pour les répétitions demandées, ignorer les autres
		IF integer(mid(as_item, 4)) > li_pdsnbr THEN 
			return(1)
		ELSE
			return(ibr_cphys.uf_check_pds(as_data, as_message))
		END IF
	
	CASE "hum_rap"
		return(ibr_cphys.uf_check_humrap(as_data, as_message))
		
	CASE "hum_nbr"
		return(ibr_cphys.uf_check_humnbr(as_data, as_message))
		
	CASE "hum_etuv_pf1", "hum_etuv_pf2", "hum_etuv_pf3", "hum_etuv_pf4", "hum_etuv_pf5", "hum_etuv_pf6", &
		  "hum_etuv_pf7", "hum_etuv_pf8", "hum_etuv_pf9", "hum_etuv_pf10", "hum_etuv_pf11", "hum_etuv_pf12"
		li_humnbr = int(this.object.hum_nbr[1])
		// ne tester que les items pour les répétitions demandées, ignorer les autres
		IF integer(mid(as_item, 12)) > li_humnbr THEN 
			return(1)
		ELSE
			return(ibr_cphys.uf_check_humpf(as_data, as_message))
		END IF
		
	CASE "hum_etuv_ps1", "hum_etuv_ps2", "hum_etuv_ps3", "hum_etuv_ps4", "hum_etuv_ps5", "hum_etuv_ps6", &
		  "hum_etuv_ps7", "hum_etuv_ps8", "hum_etuv_ps9", "hum_etuv_ps10", "hum_etuv_ps11", "hum_etuv_ps12"
		li_humnbr = int(this.object.hum_nbr[1])
		// ne tester que les items pour les répétitions demandées, ignorer les autres
		IF integer(mid(as_item, 12)) > li_humnbr THEN 
			return(1)
		ELSE
			ld_humpf = this.getitemdecimal(1, "hum_etuv_pf" + mid(as_item, 12))
			return(ibr_cphys.uf_check_humps(as_data, as_message, ld_humpf))
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

event ue_itemvalidated;call super::ue_itemvalidated;integer	li_i, li_pdsnbr, li_pdsnbg, li_humnbr

CHOOSE CASE as_name
	// Poids de 1000 graines :
	// recopier le nombre de graines dans toutes les répétions demandées
	// + annuler les valeurs pour les répétitions au delà de celles demandées.
	CASE "pds_nbg"
		li_pdsnbg = integer(as_data)
		li_pdsnbr = int(this.object.pds_nbr[al_row])
		IF isNull(li_pdsnbr) OR li_pdsnbr = 0 THEN return
		FOR li_i = 1 TO li_pdsnbr
			this.setitem(al_row, "qte_rep" + string(li_i), li_pdsnbg)
		NEXT
		FOR li_i = li_pdsnbr + 1 TO 12
			this.setitem(al_row, "qte_rep" + string(li_i), gu_c.i_null)
		NEXT
	CASE "pds_nbr"
		li_pdsnbg = int(this.object.pds_nbg[al_row])
		li_pdsnbr = integer(as_data)
		IF isNull(li_pdsnbg) OR li_pdsnbg = 0 THEN return
		FOR li_i = 1 TO li_pdsnbr
			this.setitem(al_row, "qte_rep" + string(li_i), li_pdsnbg)
		NEXT
		FOR li_i = li_pdsnbr + 1 TO 12
			this.setitem(al_row, "qte_rep" + string(li_i), gu_c.i_null)
			this.setitem(al_row, "pds" + string(li_i), gu_c.i_null)
		NEXT
	// Test d'humidité :
	// annuler annuler les valeurs pour les répétitions au delà de celles demandées.
	CASE "hum_nbr"
		li_humnbr = integer(as_data)
		FOR li_i = li_humnbr + 1 TO 12
			this.setitem(al_row, "hum_etuv_pf" + string(li_i), gu_c.i_null)
			this.setitem(al_row, "hum_etuv_ps" + string(li_i), gu_c.i_null)
		NEXT
END CHOOSE
end event

event ue_checkall;call super::ue_checkall;decimal{2}	ld_bon, ld_inerte, ld_autre
string		ls_message

// si tous les tests précédents (par item) sont OK, pratiquer tests globaux.
IF ancestorReturnValue > 0 THEN
	ld_bon = dec(this.object.c_purete_bon[1])
	ld_inerte = dec(this.object.c_purete_inerte[1])
	ld_autre = dec(this.object.c_purete_autre[1])
	IF ibr_cphys.uf_check_purete(ls_message, ld_bon, ld_inerte, ld_autre) = -1 THEN
		gu_message.uf_error(ls_message)
		return(-1)
	END IF
ELSE
	return(ancestorReturnValue)
END IF
return(1)
end event

