//objectcomments Gestion des tests de germination
forward
global type w_qgerm from w_ancestor_dataentry
end type
type dw_cpt from uo_datawindow_multiplerow within w_qgerm
end type
type dw_qgerm from uo_datawindow_singlerow within w_qgerm
end type
end forward

global type w_qgerm from w_ancestor_dataentry
integer width = 3278
integer height = 2172
string title = "Tests de germination"
boolean maxbox = true
boolean resizable = true
dw_cpt dw_cpt
dw_qgerm dw_qgerm
end type
global w_qgerm w_qgerm

type variables
uo_cpteur	iu_cpteur
br_graine_qgerm	ibr_qgerm

boolean	ib_ajout, ib_readonly, ib_cpt, ib_validation=FALSE, ib_dejaValide
string	is_reflot, is_typetest, is_typeqte
integer	ii_numtest, ii_nbrep


end variables

forward prototypes
public function integer wf_setkey (string as_reflot, integer ai_numtest, boolean ab_readonly)
public function integer wf_init ()
public subroutine wf_init_nbrep ()
public subroutine wf_init_qterep ()
public subroutine wf_init_typetest ()
public subroutine wf_lastcpt ()
public function integer wf_newtest ()
public function long wf_newcpt ()
public function integer wf_valid_registre ()
end prototypes

public function integer wf_setkey (string as_reflot, integer ai_numtest, boolean ab_readonly);// utilisé par un programme externe pour ouvrir un test
IF f_isEmptyString(as_reflot) OR isNull(ai_numtest) OR ai_numtest = 0 THEN
	return(-1)
END IF

ib_readonly = ab_readonly

IF dw_qgerm.uf_SetDefaultValue(1, "ref_lot", as_reflot) < 0 THEN 
	return(-1)
END IF
IF dw_qgerm.uf_SetDefaultValue(1, "num_test", ai_numtest) < 0 THEN 
	return(-1)
END IF

return(1)
end function

public function integer wf_init ();string	ls_sp
long		ll_count

// lecture essence du lot
select code_sp into :ls_sp from registre where ref_lot=:is_reflot using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN return(-1)

// lecture type de quantité (poids ou comptage) utilisé dans les tests de germination
select type_qte into :is_typeqte from espece where code_sp=:ls_sp using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN return(-1)

// valeurs par défaut pour nouveau record
IF dw_qgerm.uf_IsRecordNew() THEN
	dw_qgerm.uf_setdefaultvalue(1, "type_test", "P")
	dw_qgerm.object.dt_debut[1] = f_today()
ELSE
	// voir si ce test a déjà été validé
	select count(*) into :ll_count from registre_qgerm 
		where ref_lot=:is_reflot and num_test_qgerm=:ii_numtest using ESQLCA;
		IF f_check_sql(ESQLCA) <> 0 THEN return(-1)
		IF ll_count > 0 THEN	ib_dejaValide = TRUE
END IF

dw_qgerm.object.c_type_qte.expression = "'" + is_typeqte + "'"
is_typetest = dw_qgerm.object.type_test[1]
ii_nbrep = dw_qgerm.object.nb_rep[1]

// initialise l'écran des comptages en fonction du type de test, du nombre de répétitions, 
// du nombre de graines par répétitions...
wf_init_typetest()
wf_init_nbrep()
wf_init_qterep()

dw_cpt.setredraw(FALSE)
// lecture des comptages
IF dw_cpt.retrieve(is_reflot, ii_numtest) > 0 THEN
	ib_cpt = TRUE
	wf_lastcpt()
END IF

// placer curseur sur dernier comptage
IF dw_cpt.rowCount() > 0 THEN
	dw_cpt.scrollToRow(dw_cpt.rowCount())
	dw_cpt.selectRow(dw_cpt.rowCount(), FALSE)
END IF

// disabler la clé et enabler les datas (si pas mode disabled ou validation)
dw_qgerm.setredraw(FALSE)
IF NOT ib_readonly THEN 
	dw_qgerm.uf_enableData()
	dw_cpt.uf_enableData()
ELSE
	dw_cpt.uf_disableData()
END IF
dw_qgerm.uf_disablekeys()
dw_qgerm.setredraw(TRUE)
dw_cpt.setredraw(TRUE)

dw_qgerm.SetItemStatus(1,0,Primary!,NotModified!)
dw_qgerm.SetColumn("type_test")
dw_qgerm.SetFocus()

IF ib_dejaValide THEN
	IF ib_validation THEN
		gu_message.uf_info("Ce test a déjà été validé.~n" + &
			"S'il a été modifié, il est néanmoins nécessaire de le valider à nouveau.")
	ELSE
		IF NOT ib_readonly THEN
			gu_message.uf_info("Attention, ce test a déjà été validé.~n" + &
				"Vous pouvez néanmoins le modifier, vous aurez la possibilité de le revalider.")
		END IF
	END IF
END IF

return(1)
end function

public subroutine wf_init_nbrep ();// initialisation dans DW_CPT du nombre de graines initial pour toutes les répétitions
integer	li_i
string	ls_mod
long		ll_row

// recopier dans DW_CPT le nombre de répétitions et de graines par répétition
dw_cpt.object.c_nbrerep.expression = "'" + string(ii_nbrep) + "'"

dw_cpt.setRedraw(FALSE)
// Pétri : cacher répétitions non utilisées (ne fonctionne pas bien avec une expression dans le dw...)
// NB : si on augmente le nombre de répétitions, il faut rendre visible plus de colonnes,
//      et ces colonnes se placent à la suite des autres colonnes visibles et non à leur
//      emplacement initial. Pour résoudre ce problème, il faut rendre toutes les colonnes
//      invisibles et ensuite visibles dans l'ordre où on veut les voir !
IF is_typetest = "P" THEN
	// Concatenate into a string, all the Modifies to make all columns invisible
	ls_mod = "nbre1.Visible='0' nbre2.Visible='0' nbre3.Visible='0' nbre4.Visible='0' " + &
			"nbre5.Visible='0' nbre6.Visible='0' nbre7.Visible='0' nbre8.Visible='0' " + &
			"nbre9.Visible='0' nbre10.Visible='0' nbre11.Visible='0' nbre12.Visible='0' " + &
			"c_somme.Visible='0' c_moy.Visible='0' rem.Visible='0'"
	// Do the actual Modify to make the columns invisible
	dw_cpt.Modify(ls_mod)
	// Do a Modify on each number column visible, one by one, listing them in the desired order
	FOR li_i = 1 TO ii_nbrep
		dw_cpt.Modify("nbre" + string(li_i) + ".Visible=1")
	NEXT
	// afficher les colonnes qui suivent les nombres
	ls_mod = "c_somme.Visible='1' c_moy.Visible='1' rem.Visible='1'"
	dw_cpt.Modify(ls_mod)
END IF

// annuler le nombre de germes dans les répétitions non utilisées
FOR ll_row = 1 TO dw_cpt.rowCount()
	FOR li_i = ii_nbrep + 1 TO 12
		dw_cpt.setitem(ll_row, "nbre" + string(li_i), gu_c.i_null)
	NEXT
NEXT

dw_cpt.setRedraw(TRUE)
end subroutine

public subroutine wf_init_qterep ();// initialisation dans DW_CPT du nombre de graines par répétitions
integer	li_i
string	ls_mod

// copier qté de graines par répétition de l'entête DW_QGERM vers le détail DW_CPT
FOR li_i = 1 TO ii_nbrep
	ls_mod = "c_qterep" + string(li_i) + ".expression = ~"number('" + &
				f_string(dw_qgerm.getitemdecimal(1, "qte_rep" + string(li_i))) + "')~""
	dw_cpt.modify(ls_mod)
NEXT

// annuler les qtés dans les répétitions non utilisées
FOR li_i = (ii_nbrep + 1) TO 12
	ls_mod = "c_qterep" + string(li_i) + ".expression = ~"dec(c_null)~""
	dw_cpt.modify(ls_mod)
NEXT

end subroutine

public subroutine wf_init_typetest ();// adapte l'écran au type de test et assigne les valeurs par défaut
integer	li_i

CHOOSE CASE is_typetest
	CASE "P"
		dw_cpt.uf_changedataobject("d_qgerm_cpt_petri")
		dw_cpt.uf_autoselectrow (TRUE)
		// quantité : pesée/comptage
		dw_cpt.object.c_type_qte.expression = "'" + is_typeqte + "'"
		
	CASE "S"
		dw_cpt.uf_changedataobject("d_qgerm_cpt_substrat")
		dw_cpt.uf_autoselectrow (FALSE)
END CHOOSE

wf_init_nbrep()
wf_init_qterep()

end subroutine

public subroutine wf_lastcpt ();// permet le calcul du nombre de jours écoulés entre la date de mise en test et la
// date du dernier relevé
dw_qgerm.setredraw(FALSE)
dw_qgerm.object.c_lastcpt.expression = "~"" + "date('" + &
		string(dw_cpt.object.c_lastcpt[1], "dd/mm/yyyy") +	"')" + "~""
dw_qgerm.setredraw(TRUE)
end subroutine

public function integer wf_newtest ();// création d'un nouveau test
decimal	ld_numtest

// la ref. du lot doit être spécifié
IF f_isEmptyString(is_reflot) THEN
	gu_message.uf_error("Veuillez d'abord sélectionner la référence du lot")
	return(-1)
END IF

// prendre nouveau n° de commande via le compteur, le placer dans num_cmde et passer au champ suivant
ld_numtest = iu_cpteur.uf_getnumqgerm(is_reflot)
IF ld_numtest < 0 THEN
	gu_message.uf_error("Impossible d'obtenir un nouveau n° de test de germination !")
	return(-1)
END IF
ib_ajout = TRUE
dw_qgerm.setfocus()
dw_qgerm.SetText(string(ld_numtest))
f_presskey ("TAB")

return(1)

end function

public function long wf_newcpt ();// création d'une nouvelle ligne de relevé
// return(-1) si erreur
// return(n° de row ajoutée) si OK
long		ll_row
integer	li_num

IF NOT wf_IsActif() THEN return(0)
IF dw_cpt.accepttext() < 0 THEN return(-1)

ll_row = dw_cpt.event ue_addrow()
IF ll_row <= 0 THEN
	return(-1)
END IF

// initialiser 1ère partie de la PK
dw_cpt.object.ref_lot[ll_row] = is_reflot
dw_cpt.object.num_test[ll_row] = ii_numtest

// initialier les autres champs
IF dw_cpt.uf_setdefaultvalue(ll_row, "dt_cpt", f_today()) = -1 THEN
	dw_cpt.uf_setdefaultvalue(ll_row, "dt_cpt", gu_c.d_null, date!)
END IF
li_num = dw_cpt.object.c_maxnum[ll_row]
IF isNull(li_num) THEN li_num = 0
li_num = li_num + 1
IF li_num > 99 THEN
	gu_message.uf_error("Nombre maximum (99) atteint !")
	return(-1)
END IF
dw_cpt.object.num_cpt[ll_row] = li_num

IF is_typetest = "P" THEN
	dw_cpt.SetColumn("dt_cpt")
ELSE
	dw_cpt.SetColumn("idbac")
END IF
dw_cpt.object.datawindow.HorizontalScrollPosition = 1
dw_cpt.SetFocus()

return(ll_row)
end function

public function integer wf_valid_registre ();// Création ou mise à jour ligne caractéristiques graines dans REGISTRE_QGERM
// return(1) : OK
// return(0) : validation sans objet
// return(-1) : erreur
integer	li_status, li_num
long		ll_count, ll_gvkilo
string	ls_rem, ls_err
date		ld_dtdebut
decimal	ld_fg

// 1. récupérer les champs utiles pour la row à créer dans REGISTRE_QGERM
ld_dtdebut = date(dw_qgerm.object.dt_debut[1])
ls_rem = string(dw_qgerm.object.rem[1])
IF is_typetest = "P" THEN
	IF is_typeqte = "C" THEN
		setNull(ll_gvkilo)
		ld_fg = dec(dw_cpt.object.c_moygen[1])
		IF isNull(ld_fg) OR ld_fg = 0 THEN
			gu_message.uf_info("Faculté germinative nulle, pas de validation !")
			return(0)
		END IF
	ELSE
		setNull(ld_fg)
		ll_gvkilo = long(dw_cpt.object.c_moygen[1])
		IF isNull(ll_gvkilo) OR ll_gvkilo = 0 THEN
			gu_message.uf_info("Faculté germinative nulle, pas de validation !")
			return(0)
		END IF
	END IF
ELSE
	setNull(ll_gvkilo)
	ld_fg = dec(dw_cpt.object.c_moygen[1])
	IF isNull(ld_fg) OR ld_fg = 0 THEN
		gu_message.uf_info("Faculté germinative nulle, pas de validation !")
		return(0)
	END IF
END IF

// 2. créer ou mettre à jour la ligne de caractéristiques éventuellement déjà générée
//    au niveau du registre. Utiliser SQLCA pour commiter en même temps que l'update de dw_qgerm.
// Vérifier s'il existe déjà ou pas une ligne pour le test en cours dans REGISTRE_QGERM.
select count(*) into :ll_count from registre_qgerm where ref_lot = :is_reflot and num_test_qgerm = :ii_numtest using SQLCA;
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
		insert into registre_qgerm (REF_LOT,NUM_QGERM,DT_QGERM,REM,FG,GVKILO,NUM_TEST_QGERM) 
			values (:is_reflot,:li_num,:ld_dtdebut,:ls_rem,:ld_fg,:ll_gvkilo,:ii_numtest) using SQLCA;
		IF f_check_sql(SQLCA) = -1 THEN
			populateerror(20000, "")
			ls_err = "Erreur INSERT INTO REGISTRE_QGERM"
			GOTO ERREUR
		END IF
		
	// c. il existe déjà une (et une seule) ligne dans REGISTRE_QGERM pour ce test : on la met à jour
	CASE 1
		update registre_qgerm
			set dt_qgerm = :ld_dtdebut, rem=:ls_rem, fg=:ld_fg, gvkilo=:ll_gvkilo
			where ref_lot=:is_reflot and num_test_qgerm = :ii_numtest
			using SQLCA;
		IF f_check_sql(SQLCA) = -1 THEN
			populateerror(20000, "")
			ls_err = "Erreur UPDATE REGISTRE_QGERM"
			GOTO ERREUR
		END IF
END CHOOSE

commit using SQLCA;

// Vérifier si la fenêtre permettant de valider des tests l'un à la suite de l'autre est ouverte.
// Si c'est le cas, y exécuter une fonction pour rechercher et modifier l'aspect du test validé
IF IsValid(w_validqgerm_liste) THEN
	w_validqgerm_liste.SetFocus()
	w_validqgerm_liste.wf_search_test(is_reflot, ii_numtest)
END IF

return(1)

ERREUR:
rollback using SQLCA;
gu_message.uf_unexp(ls_err)
return(-1)
end function

on w_qgerm.create
int iCurrent
call super::create
this.dw_cpt=create dw_cpt
this.dw_qgerm=create dw_qgerm
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_cpt
this.Control[iCurrent+2]=this.dw_qgerm
end on

on w_qgerm.destroy
call super::destroy
destroy(this.dw_cpt)
destroy(this.dw_qgerm)
end on

event resize;call super::resize;// ce resize n'est valide que hors-validation, quand le bouton de validation n'existe pas
IF NOT ib_validation THEN
	dw_cpt.height = newheight - dw_qgerm.height - 100
	dw_cpt.width = newwidth
END IF
end event

event ue_open;call super::ue_open;// REM : le programme W_QGERM est en mode "encodage", avec ib_validation=false, 
// tandis que W_QGERM_VALIDATION qui en est un descendant place ib_validation 
// à true AVANT d'exécuter ue_open
str_params	lstr_params

ibr_qgerm = CREATE br_graine_qgerm
iu_cpteur = CREATE uo_cpteur

dw_cpt.uf_createwhenlastdeleted(FALSE)
dw_cpt.uf_sort(FALSE)

// icône "ajouter" doit être visible dans le menu
wf_SetItemsToShow({"m_ajouter"})

wf_SetDWList({dw_qgerm, dw_cpt})

end event

event ue_close;call super::ue_close;DESTROY ibr_qgerm
DESTROY iu_cpteur
end event

event ue_init_win;call super::ue_init_win;ib_ajout = FALSE
ib_dejaValide = FALSE

// mode validation : d'office RO, sinon sera déterminé plus tard
ib_readonly = ib_validation

ib_cpt = FALSE
SetNull(is_reflot)
SetNull(ii_numtest)
ii_nbrep = 0

iu_cpteur.uf_rollback()

this.setredraw(FALSE)

dw_qgerm.uf_reset()
dw_qgerm.object.c_lastcpt.expression = "~"" + "date('00/00/0000')" + "~""
dw_qgerm.insertrow(0)
dw_cpt.uf_reset()

dw_qgerm.uf_disabledata()
dw_qgerm.uf_enablekeys()
dw_cpt.uf_disabledata()

IF f_isEmptyString(is_reflot) THEN
	dw_qgerm.object.ref_lot[1] = ""
	dw_qgerm.Setcolumn("ref_lot")
ELSE
	dw_qgerm.uf_setdefaultvalue(1, "ref_lot", is_reflot)
	dw_qgerm.Setcolumn("num_test")
END IF

dw_qgerm.uf_setdefaultvalue(1, "type_test", "")
wf_init_typetest()

dw_qgerm.setfocus()

this.setredraw(TRUE)
end event

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
	// options dépendantes du DW qui a le focus
	CHOOSE CASE wf_GetActivecontrolname()
		CASE "dw_qgerm"
			// activer option "supprimer" si suppressions autorisées (suppression de tout le test)
			IF NOT dw_qgerm.uf_IsRecordNew() AND wf_canDelete() THEN
				li_item++
				ls_menu[li_item] = "m_supprimer"
			END IF
			
		CASE "dw_cpt"
			// activer option "supprimer" si modifications autorisées (suppresion d'un comptage)
			// ou si on veut supprimer une ligne qu'on vient de créer
			IF dw_cpt.uf_IsRecordNew() OR wf_canUpdate() THEN
				li_item++
				ls_menu[li_item] = "m_supprimer"
			END IF
			// activer option "ajouter" si modifications autorisées (ajout d'un comptage)
			IF wf_canUpdate() THEN
				li_item++
				ls_menu[li_item] = "m_ajouter"
			END IF
	END CHOOSE
ELSE
	// activer bouton "ajouter" si curseur dans n° de test et modif.autorisées
	IF dw_qgerm.GetColumnName() = "num_test" AND wf_canUpdate() AND NOT ib_readonly THEN
		li_item++
		ls_menu[li_item] = "m_ajouter"
	END IF
END IF

f_menuaction(ls_menu)



end event

event ue_enregistrer;call super::ue_enregistrer;integer	li_i, li_status
long		ll_row, ll_somme_germes, ll_nbredepart
decimal{2}	ld_qte 

// s'assurer que la quantité de graines dans chaque répétition sauf la dernière est égale
// à la quantité initiale
ld_qte = dw_qgerm.object.qte_rep[1]
FOR li_i = 1 TO ii_nbrep - 1
	dw_qgerm.setitem(1, "qte_rep" + string(li_i), ld_qte)
NEXT

// s'assurer qu'il y a NULL dans le nombre de graines dans les répétitions non utilisées
FOR li_i = ii_nbrep + 1 TO 12
	dw_qgerm.setitem(1, "qte_rep" + string(li_i), gu_c.i_null)
NEXT
		
// s'assurer qu'il y a NULL dans le nombre de germes des répétitions non utilisées
FOR ll_row = 1 TO dw_cpt.rowCount()
	FOR li_i = ii_nbrep + 1 TO 12
		dw_cpt.setitem(ll_row, "nbre" + string(li_i), gu_c.i_null)
	NEXT
NEXT

// contrôle de validité de tous les champs
IF dw_qgerm.event ue_checkall() < 0 THEN
	dw_qgerm.SetFocus()
	return(-1)
END IF

IF dw_cpt.event ue_checkall() < 0 THEN
	dw_cpt.SetFocus()
	return(-1)
END IF

// message d'information si le nombre de germes compté est supérieur au nombre de graines de départ
// (uniquement pour les espèces comptabilisables)
IF is_typeqte = "C" THEN
	ll_somme_germes = long(dw_cpt.object.c_somme_germes[1])
	ll_nbredepart = long(dw_cpt.object.c_nbredepart[1])
	IF ll_somme_germes > ll_nbredepart THEN
		IF gu_message.uf_query("Le nombre de germes dénombré (" + &
			f_string(ll_somme_germes) + ") est supérieur au nombre de graines initial (" + &
			f_string(ll_nbredepart) + "). Enregistrer quand même ?", YesNo!, 1) = 2 THEN
			return(-1)
		END IF
	END IF
END IF

// update DW
li_status = gu_dwservices.uf_updatetransact(dw_qgerm, dw_cpt)
CHOOSE CASE li_status
	CASE 1
		// si nouveau test, updater compteur
		IF dw_qgerm.uf_IsRecordNew() THEN
			IF iu_cpteur.uf_update_numqgerm(is_reflot, ii_numtest) = -1 THEN
				populateerror(20000, "")
				gu_message.uf_unexp("Erreur mise à jour du compteur QGERM.NUM_TEST")
			END IF
		END IF
		// si test avait déjà été validé au préalable, demander s'il faut le revalider maintenant
		IF ib_dejaValide THEN
			IF gu_message.uf_query("Ce test avait déjà été validé et ses résultats existent donc dans le registre.~n~n" + &
					  "Souhaitez-vous le revalider dès maintenant afin que les valeurs soient à jour dans le registre" + &
				  " (et le(s) document(s) fournisseur éventuels) ?", YesNo!, 1) = 1 THEN
				IF wf_valid_registre() = 1 THEN
					  gu_message.uf_info("Test validé avec succès")
				END IF
			END IF
		END IF
		wf_message("Test de germination " + is_reflot + "/" + f_string(ii_numtest) + " enregistré avec succès")
		This.event ue_init_win()
		return(1)
	CASE -1
		populateerror(20000,"")
		gu_message.uf_unexp("GRAINE_QGERM : Erreur lors de la mise à jour de la base de données")
		return(-1)
	CASE -2
		populateerror(20000,"")
		gu_message.uf_unexp("GRAINE_QGERM_CPT : Erreur lors de la mise à jour de la base de données")
		return(-1)
END CHOOSE

return(1)
end event

event ue_ajouter;call super::ue_ajouter;CHOOSE CASE wf_GetActivecontrolname()
	// ajouter une nouveau test si le curseur est sur DW_QGERM et dans l'item NUM_TEST
	CASE "dw_qgerm"
		IF dw_qgerm.GetColumnName() = "num_test" THEN
			wf_newtest()
			return
		END IF
	
	// ajoute nouveau relevé
	CASE "dw_cpt"
		wf_newcpt()
END CHOOSE
end event

event ue_supprimer;call super::ue_supprimer;long		ll_row
string	ls_message
integer	li_numtest_qgerm

CHOOSE CASE wf_GetActivecontrolname()
	// supprimer tout le test si le curseur est sur DW_QGERM
	CASE "dw_qgerm"
		// vérifier l'utilisation du test et construire message
		li_numtest_qgerm = ibr_qgerm.uf_check_beforedelete(is_reflot, ii_numtest, ls_message)
		IF li_numtest_qgerm = -1 THEN
			gu_message.uf_error(ls_message)
			return
		END IF
		
		// confirmer ?
		IF f_confirm_del(ls_message + "Confirmez-vous la suppression de ce test ?") = 1 THEN
			IF dw_qgerm.event ue_delete() = 1 THEN
				// suppression des références dans DOCFRN
				IF li_numtest_qgerm > 0 THEN
					update DOCFRN
						set NUM_QGERM = null	where REF_LOT=:is_reflot and num_qgerm=:li_numtest_qgerm using ESQLCA;
					IF f_check_sql(ESQLCA) < 0 THEN
						rollback using ESQLCA;
						populateError(20000, "")
						gu_message.uf_unexp("ERREUR UPDATE DOCFRN~n~n" + &
							"La référence des qualités germinatives supprimées n'a pas pu être annulées dans les documents fournisseur !")
					END IF
				END IF
				// normalement, les "many" sont supprimés par les contraintes mais...
				delete from graine_qgerm_cpt where ref_lot = :is_reflot and num_test=:ii_numtest using ESQLCA;
				IF f_check_sql(ESQLCA) = 0 AND ESQLCA.sqlnrows <> 0 THEN
					commit using ESQLCA;
					populateerror(20000,"")
					gu_message.uf_unexp("Les contraintes d'intégrité entre GRAINE_QGERM et GRAINE_QGERM_CPT ne sont pas actives !", 2)
				END IF
				delete from registre_qgerm where ref_lot = :is_reflot and num_test_qgerm=:ii_numtest using ESQLCA;
				IF f_check_sql(ESQLCA) = 0 AND ESQLCA.sqlnrows <> 0 THEN
					commit using ESQLCA;
					populateerror(20000,"")
					gu_message.uf_unexp("Les contraintes d'intégrité entre GRAINE_QGERM et REGISTRE_QGERM ne sont pas actives !", 2)
				END IF

			// remarque : commit ou rollback nécessaire après les delete ci-dessus, même s'ils n'ont aucun effet !
			// Si on ne le fait pas, les LOCK subsistent !
			commit using ESQLCA;
			wf_message("Test de qualités germinatives supprimé avec succès")
			this.event ue_init_win()
			END IF
		END IF
	
	// supprimer une ligne de relevé
	CASE "dw_cpt"
		ll_row = dw_cpt.GetRow()
		IF ll_row <= 0 THEN return
		IF f_confirm_del("Voulez-vous supprimer le relevé n° " + &
			f_string(dw_cpt.object.num_cpt[ll_row]) + " du " + &
			string(dw_cpt.object.dt_cpt[ll_row], "dd/mm/yyyy") + " ?") = 1 THEN
			IF dw_cpt.event ue_delete() = 1 THEN
				wf_lastcpt()
				wf_message("Relevé supprimé avec succès")
			END IF
		END IF
END CHOOSE
end event

type ddlb_message from w_ancestor_dataentry`ddlb_message within w_qgerm
integer y = 1968
end type

type dw_cpt from uo_datawindow_multiplerow within w_qgerm
integer y = 928
integer width = 3237
integer height = 896
integer taborder = 11
boolean bringtotop = true
string title = "Résultats des tests"
string dataobject = "d_qgerm_cpt_petri"
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

event ue_checkitem;call super::ue_checkitem;string	ls_find
integer	li_idbac
date		l_date

CHOOSE CASE as_item
	CASE "dt_cpt"
		l_date = gu_datetime.uf_dfromdt(as_data)
		// Test en boîte de Pétri : date unique dans le test, on ne peut pas avoir 2 relevés le même jour dans un même test.
		// Test sur substrat : date unique dans le test pour un même bac
		IF is_typetest = "P" THEN
			ls_find = "dt_cpt=date('" + string(l_date) + "')"
			IF gu_dwservices.uf_findduplicate(dw_cpt, al_row, ls_find) > 0 THEN
				as_message = "Il y a déjà un relevé pour cette date"
				return(-1)
			END IF
		ELSE
			li_idbac = this.object.idbac[al_row]
			ls_find = "dt_cpt=date('" + string(l_date) + "')"
			IF isNull(li_idbac) THEN
				ls_find = ls_find + " and isNull(idbac)"
			ELSE
				ls_find = ls_find + " and idbac=" + string(li_idbac)
			END IF
			IF gu_dwservices.uf_findduplicate(dw_cpt, al_row, ls_find) > 0 THEN
				as_message = "Il y a déjà un relevé pour ce bac et cette date, vous devez modifier l'un ou l'autre."
				return(-1)
			END IF
		END IF
		return(ibr_qgerm.uf_check_cpt_dtcpt(as_data, as_message))
		
	CASE "nbre1", "nbre2", "nbre3", "nbre4", "nbre5", "nbre6", &
		  "nbre7", "nbre8", "nbre9", "nbre10", "nbre11", "nbre12"
	  return(ibr_qgerm.uf_check_cpt_qterepn(as_data, as_message, as_item, ii_nbrep))
	
	CASE "idbac"
		// Test sur substrat : date unique dans le test pour un même bac
		IF is_typetest = "S" THEN
			l_date = date(this.object.dt_cpt[al_row])
			ls_find = "dt_cpt=date('" + string(l_date) + "')"
			IF isNull(as_data) THEN
				ls_find = ls_find + " and isNull(idbac)"
			ELSE
				ls_find = ls_find + " and idbac=" + as_data
			END IF
			IF gu_dwservices.uf_findduplicate(dw_cpt, al_row, ls_find) > 0 THEN
				as_message = "Il y a déjà un relevé pour ce bac et cette date, vous devez modifier l'un ou l'autre."
				return(-1)
			END IF
		END IF
		return(ibr_qgerm.uf_check_cpt_idbac(as_data, as_message))
	
	CASE "rem"
		return(ibr_qgerm.uf_check_cpt_rem(as_data, as_message))
END CHOOSE
return(1)
end event

event ue_postitemvalidated;call super::ue_postitemvalidated;long	ll_rowID, ll_row
integer	li_num

IF al_row <= 0 THEN return


CHOOSE CASE as_name
	// après encodage de l'année ou du n° de bac, retrier le DW et resélectionner la bonne row
	CASE "dt_cpt"
		// faire connaitre la date du dernier relevé à W_QGERM pour actualiser calcul du nombre de jours
		wf_lastcpt()
		
		ll_rowID = this.GetRowIdFromRow(al_row)
		this.sort()
		ll_row = this.GetRowFromRowId(ll_rowID)
		this.scrollToRow(ll_row)
		IF is_typetest = "S" THEN
			this.SetColumn("rem")
		ELSE
			this.SetColumn("nbre1")
		END IF
		
	CASE "idbac"
		ll_rowID = this.GetRowIdFromRow(al_row)
		this.sort()
		ll_row = this.GetRowFromRowId(ll_rowID)
		this.groupcalc()
		this.scrollToRow(ll_row)
		this.setColumn("dt_cpt")
END CHOOSE

end event

type dw_qgerm from uo_datawindow_singlerow within w_qgerm
integer x = 238
integer width = 2761
integer height = 928
integer taborder = 10
string dataobject = "d_qgerm"
end type

event getfocus;call super::getfocus;parent.event post ue_init_menu()
end event

event ue_checkitem;call super::ue_checkitem;integer	li_status, li_numtest
long		ll_count
decimal{2}	ld_qte

CHOOSE CASE as_item
	CASE "ref_lot"
		IF ibr_qgerm.uf_check_reflot(as_data, as_message) = -1 THEN
			return(-1)
		ELSE
			is_reflot = as_data
			return(1)
		END IF
		
	// dernier élément de la clé, vérifier si record existe ou pas
	CASE "num_test"
		IF ibr_qgerm.uf_check_numtest(as_data, as_message) = -1 THEN
			iu_cpteur.uf_rollback()
			return(-1)
		END IF
		li_numtest = integer(as_data)
		select count(*) into :ll_count from graine_qgerm
				where ref_lot = :is_reflot and num_test=:li_numtest using ESQLCA;
		li_status = f_check_sql(ESQLCA)
		IF li_status < 0 OR ll_count > 1 THEN
			populateerror(20000,"")
			gu_message.uf_unexp("Erreur SELECT GRAINE_QGERM")
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
		
	CASE "type_test"
		// s'il y a déjà des relevés dans DW_CPT, on ne peut plus modifier le type de test
		IF as_data <> is_typetest AND ib_cpt THEN
			as_message = "Il existe déjà des relevés pour ce test, on ne peut plus en modifier le type."
			return(-1)
		END IF
		return(ibr_qgerm.uf_check_typetest(as_data, as_message, is_typeqte))
		
	CASE "dt_debut"
		return(ibr_qgerm.uf_check_dtdebut(as_data, as_message))
		
	CASE "dt_ldorm"
		return(ibr_qgerm.uf_check_dtldorm(as_data, as_message))
		
	CASE "rem"
		return(ibr_qgerm.uf_check_rem(as_data, as_message))
		
	CASE "sslot"
		return(ibr_qgerm.uf_check_sslot(as_data, as_message))
		
	CASE "nb_rep"
		return(ibr_qgerm.uf_check_nbrep(as_data, as_message))	
		
	CASE "qte_rep"
		return(ibr_qgerm.uf_check_qterep(as_data, as_message, is_typeqte))
		
	// modification du nombre de graines initial d'une répétition
	// (seule le nombre de la dernière répétition peut être modifié)
	CASE "qte_rep1", "qte_rep2", "qte_rep3", "qte_rep4", "qte_rep5", "qte_rep6", &
		  "qte_rep7", "qte_rep8", "qte_rep9", "qte_rep10", "qte_rep11", "qte_rep12"
		ld_qte = this.object.qte_rep[1]
		return(ibr_qgerm.uf_check_qterepn(as_data, as_message, as_item, ii_nbrep, ld_qte, is_typeqte))
		 
END CHOOSE
end event

event ue_leavekey;call super::ue_leavekey;// quand on quitte la clé, cela veut dire qu'on dispose de données actives dans la fenêtre
wf_actif(true)

// effacer les messages
ddlb_message.reset()

// lecture du record si existe déjà
IF NOT this.uf_IsRecordNew() THEN
	IF ib_validation THEN
		wf_message("Validation d'un test...")
	ELSEIF ib_readonly THEN
		wf_message("Visualisation d'un test...")
	ELSE
		wf_message("Modification d'un test...")
	END IF
	this.retrieve(is_reflot, ii_numtest)
ELSE
	wf_message("Nouveau test...")
END IF

parent.event ue_init_menu()
post wf_init()

end event

event ue_itemvalidated;call super::ue_itemvalidated;decimal{2}	ld_qterep
integer		li_i
string		ls_mod

CHOOSE CASE as_name
	// modification du type de test
	CASE "type_test"
		is_typetest = as_data

		CHOOSE CASE is_typetest
			CASE "P"
				// nombre de répétitions par défaut
				dw_qgerm.uf_setdefaultvalue(1, "nb_rep", 4)
				// quantité de graines par défaut dépend du type de graine (nombre ou poids)
				IF is_typeqte = "C" THEN
					dw_qgerm.uf_setdefaultvalue(1, "qte_rep", 100)
				ELSE
					dw_qgerm.uf_setdefaultvalue(1, "qte_rep", 0.25)
				END IF
			CASE "S"
				// nombre de logettes par bac par défaut
				dw_qgerm.uf_setdefaultvalue(1, "nb_rep", 10)
				// nombre de graines par défaut
				dw_qgerm.uf_setdefaultvalue(1, "qte_rep", 20)
		END CHOOSE
		
		wf_init_typetest()
		
	// modification du nombre de répétitions
	CASE "nb_rep"
		ii_nbrep = integer(as_data)
		ld_qterep = this.object.qte_rep[1]
		// recopier le nombre de graines dans chacune des répétitions
		FOR li_i = 1 TO ii_nbrep
			dw_qgerm.setitem(1, "qte_rep" + string(li_i), ld_qterep)
		NEXT
		// annuler ce nombre dans les répétitions non utilisées
		FOR li_i = ii_nbrep + 1 TO 12
			this.setitem(al_row, "qte_rep" + string(li_i), gu_c.i_null)
		NEXT
		
		// les recopier également dans le DW détail DW_CPT
		wf_init_nbrep()
		wf_init_qterep()
	
	// modification du nombre de graines initial pour toutes les répétitions
	CASE "qte_rep"	
		ld_qterep = dec(as_data)
		// recopier le nombre de graines initial dans chacune des répétitions
		FOR li_i = 1 TO ii_nbrep
			dw_qgerm.setitem(1, "qte_rep" + string(li_i), ld_qterep)
		NEXT
		// annuler ce nombre dans les répétitions non utilisées
		FOR li_i = ii_nbrep + 1 TO 12
			dw_qgerm.setitem(1, "qte_rep" + string(li_i), gu_c.i_null)
		NEXT
		
		// les recopier également dans le DW détail DW_CPT
		wf_init_qterep()
		
	// modification du nombre de graines initial d'une répétition
	CASE "qte_rep1", "qte_rep2", "qte_rep3", "qte_rep4", "qte_rep5", "qte_rep6", &
		  "qte_rep7", "qte_rep8", "qte_rep9", "qte_rep10", "qte_rep11", "qte_rep12"
	 	// recopier qté initiale de graines modifiée dans une répétition vers le DW détail
		ls_mod = "c_qterep" + mid(as_name, 8) + ".expression = ~"number('" +	f_string(dec(as_data)) + "')~""
		dw_cpt.setRedraw(FALSE)
		dw_cpt.modify(ls_mod)
		dw_cpt.setRedraw(TRUE)
END CHOOSE
end event

event itemfocuschanged;call super::itemfocuschanged;parent.event post ue_init_menu()
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

	CASE "num_test"
		lstr_params.a_param[1] = is_reflot
		lstr_params.a_param[2] = TRUE
		lstr_params.a_param[3] = FALSE
		openwithparm(w_l_qgerm, lstr_params)
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

