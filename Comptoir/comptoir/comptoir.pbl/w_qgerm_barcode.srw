//objectcomments Saisie relevés test de germination via barcode
forward
global type w_qgerm_barcode from w_ancestor_dataentry
end type
type dw_qgerm from uo_datawindow_singlerow within w_qgerm_barcode
end type
type st_1 from uo_statictext within w_qgerm_barcode
end type
type em_dtcomptage from uo_editmask within w_qgerm_barcode
end type
type dw_cpt from uo_datawindow_singlerow within w_qgerm_barcode
end type
type st_2 from uo_statictext within w_qgerm_barcode
end type
type sle_barcode from uo_sle within w_qgerm_barcode
end type
type cb_ok from uo_cb_ok within w_qgerm_barcode
end type
type cb_cancel from uo_cb_cancel within w_qgerm_barcode
end type
type gb_cpt from uo_groupbox within w_qgerm_barcode
end type
end forward

global type w_qgerm_barcode from w_ancestor_dataentry
integer width = 2601
integer height = 1788
string title = "Relevé test de germination"
dw_qgerm dw_qgerm
st_1 st_1
em_dtcomptage em_dtcomptage
dw_cpt dw_cpt
st_2 st_2
sle_barcode sle_barcode
cb_ok cb_ok
cb_cancel cb_cancel
gb_cpt gb_cpt
end type
global w_qgerm_barcode w_qgerm_barcode

type variables
boolean	ib_cpt, ib_dejavalide, ib_new
string	is_reflot, is_typetest, is_typeqte
integer	ii_numtest, ii_numrep, ii_nbrep, ii_idbac, ii_nbretot, ii_nbreinitial
decimal{2}	id_qte	// qté initiale de graines (total de toutes les répétitions)
date		idt_comptage


end variables

forward prototypes
public function integer wf_init ()
public function long wf_newcpt ()
public function integer wf_init_substrat ()
public function integer wf_init_petri ()
end prototypes

public function integer wf_init ();// initialisation après saisie du barcode
long		ll_count
string	ls_sp

wf_message("")

// lecture entête du test
IF dw_qgerm.retrieve(is_reflot, ii_numtest) <= 0 THEN
	gu_message.uf_error("Test de germination inexistant, pas de relevé possible")
	GOTO ERREUR
END IF

// voir si ce test a déjà été validé
select count(*) into :ll_count from registre_qgerm 
	where ref_lot=:is_reflot and num_test_qgerm=:ii_numtest using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN GOTO ERREUR
IF ll_count > 0 THEN	
	ib_dejaValide = TRUE
	wf_message("Test déjà validé : pour le modifier, veuillez passer par le programme 'complet'")
END IF

// lecture essence du lot
select code_sp into :ls_sp from registre where ref_lot=:is_reflot using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN GOTO ERREUR

// lecture type de quantité (poids ou comptage) utilisé dans les tests de germination
select type_qte into :is_typeqte from espece where code_sp=:ls_sp using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN GOTO ERREUR

// type de test : Pétri/Substrat
is_typetest = dw_qgerm.object.type_test[1]

// lire qté initiale
id_qte = dw_qgerm.object.c_nbredepart[1]

// lecture du nombre de germes déjà encodés dans ce test
// (uniquement pour le bac mentionné dans le barcode si test sur substrat)
IF is_typetest = "S" THEN
	select sum(nvl(nbre1,0)+nvl(nbre2,0)+nvl(nbre3,0)+nvl(nbre4,0)+nvl(nbre5,0)+nvl(nbre6,0) +
		    nvl(nbre7,0)+nvl(nbre8,0)+nvl(nbre9,0)+nvl(nbre10,0)+nvl(nbre11,0)+nvl(nbre12,0)) 
		into :ii_nbretot
		from graine_qgerm_cpt where ref_lot=:is_reflot and num_test=:ii_numtest and idbac=:ii_idbac using ESQLCA;
ELSE
		select sum(nvl(nbre1,0)+nvl(nbre2,0)+nvl(nbre3,0)+nvl(nbre4,0)+nvl(nbre5,0)+nvl(nbre6,0) +
		    nvl(nbre7,0)+nvl(nbre8,0)+nvl(nbre9,0)+nvl(nbre10,0)+nvl(nbre11,0)+nvl(nbre12,0)) 
		into :ii_nbretot
		from graine_qgerm_cpt where ref_lot=:is_reflot and num_test=:ii_numtest using ESQLCA;
END IF
IF f_check_sql(ESQLCA) <> 0 THEN GOTO ERREUR
IF isNull(ii_nbretot) THEN ii_nbretot = 0

// nombre de répétitions dans le test
ii_nbrep = dw_qgerm.object.nb_rep[1]

// désactiver les champs date et barcode
sle_barcode.enabled = FALSE
em_dtcomptage.enabled = FALSE

/* initialisation différenciée en fonction du type de test */
IF is_typetest = "S" THEN
	IF wf_init_substrat() = -1 THEN
		GOTO ERREUR
	END IF
ELSE
	IF wf_init_petri() = -1 THEN
		GOTO ERREUR
	END IF
END IF

IF NOT ib_dejaValide THEN
	dw_cpt.uf_enabledata()
	dw_cpt.enabled = TRUE
	dw_cpt.setFocus()
	cb_ok.enabled = TRUE
	IF is_typetest = "P" THEN
		cb_ok.default = TRUE
	ELSE
		cb_ok.default = FALSE
	END IF
ELSE
	dw_cpt.uf_disabledata()
END IF
cb_cancel.enabled = TRUE
cb_cancel.default = FALSE

return(1)

ERREUR:
event ue_abandonner()
return(-1)

end function

public function long wf_newcpt ();// création d'une nouvelle ligne de relevé
// return(-1) si erreur
// return(n° de row ajoutée) si OK
long		ll_row
integer	li_i

ll_row = dw_cpt.event ue_addrow()
IF ll_row <= 0 THEN
	return(-1)
END IF

// initialiser 1ère partie de la PK
dw_cpt.object.ref_lot[ll_row] = is_reflot
dw_cpt.object.num_test[ll_row] = ii_numtest

// initialier les autres champs
IF dw_cpt.uf_setdefaultvalue(ll_row, "dt_cpt", idt_comptage) = -1 THEN
	gu_message.uf_error("Impossible d'assigner la date de comptage au relevé")
	return(-1)
END IF

// S'assurer qu'il y a 0 dans le nombre de germes des répétitions.
FOR li_i = 1 TO ii_nbrep
	dw_cpt.setitem(ll_row, "nbre" + string(li_i), 0)
NEXT

IF is_typetest = "S" THEN
	dw_cpt.object.idbac[ll_row] = ii_idbac
END IF

ib_new = TRUE
return(ll_row)
end function

public function integer wf_init_substrat ();// initialisation pour test sur substrat
long		ll_count
integer	li_i
string	ls_mod

IF ii_idbac < 1 OR ii_idbac > 9 THEN
	gu_message.uf_error("Barcode non valide : le n° de bac doit être compris entre 1 et 9")
	GOTO ERREUR
END IF

dw_cpt.uf_changedataobject("d_qgerm_cpt_barcode_substrat")
dw_cpt.height = 840
gb_cpt.height = dw_cpt.height + 80

// s'il existe déjà un relevé pour la date de comptage et le n° de bac, le lire, sinon en créer un
IF dw_cpt.retrieve(is_reflot, ii_numtest, idt_comptage, ii_idbac) = 0 THEN
	IF wf_newCpt() = -1 THEN
		gu_message.uf_error("Impossible de créer un nouveau relevé")
		GOTO ERREUR
	END IF
END IF

// faire connaître le nombre de répétitions et le nombre initial de graines par répétition à DW_CPT
dw_cpt.object.c_nbrerep.expression = "number('" + string(ii_nbrep) + "')"

FOR li_i = 1 TO ii_nbrep
	ls_mod = "c_qterep" + string(li_i) + ".expression = ~"number('" + &
				f_string(dw_qgerm.getitemdecimal(1, "qte_rep" + string(li_i))) + "')~""
	dw_cpt.modify(ls_mod)
NEXT

// relevé existe déjà : lire le nombre de germes éventuellement déjà encodé pour le bac
ii_nbreinitial = dw_cpt.object.c_nbretot[1]
IF isNull(ii_nbreinitial) THEN ii_nbreinitial = 0

dw_cpt.setcolumn("nbre1")

return(1)

ERREUR:
event ue_abandonner()
return(-1)

end function

public function integer wf_init_petri ();// initialisation pour test en boîte de Pétri
long		ll_count
string	ls_repetition[12] = {"I","II","III","IV","V","VI","VII","VIII","IX","X","XI","XII"}

dw_cpt.uf_changedataobject("d_qgerm_cpt_barcode_petri")
dw_cpt.height = 336
gb_cpt.height = dw_cpt.height + 80

IF ii_numrep > ii_nbrep THEN
	gu_message.uf_error("Barcode non valide : n° de répétition supérieur au nombre de répétitions prévu dans le test")
	GOTO ERREUR
END IF

IF ii_numrep < 1 OR ii_numrep > 12 THEN
	gu_message.uf_error("Barcode non valide : le n° de répétition doit être compris entre 1 et 12")
	GOTO ERREUR
END IF

// s'il existe déjà un relevé pour la date de comptage, le lire, sinon en créer un
IF dw_cpt.retrieve(is_reflot, ii_numtest, idt_comptage) = 0 THEN
	IF wf_newCpt() = -1 THEN
		gu_message.uf_error("Impossible de créer un nouveau relevé")
		GOTO ERREUR
	END IF
END IF

// afficher n° de répétition, qté de départ et nombre éventuel déjà encodé
dw_cpt.setRedraw(FALSE)
dw_cpt.object.c_numrep.expression = "'" + ls_repetition[ii_numrep] + "'"
// pas trouvé mieux que ceci pour assigner une valeur avec décimale (virgule) à un computed field...
dw_cpt.object.c_qte.expression = "number('" + string(id_qte * 100) + "') / 100"
dw_cpt.object.c_nbre[1] = ii_nbreinitial
dw_cpt.setRedraw(TRUE)
dw_cpt.setcolumn("c_nbre")

// lire le nombre de germes éventuellement déjà encodé pour la répétition
ii_nbreinitial = dw_cpt.getItemNumber(1, "nbre" + string(ii_numrep))
IF isNull(ii_nbreinitial) THEN ii_nbreinitial = 0

return(1)

ERREUR:
event ue_abandonner()
return(-1)

end function

on w_qgerm_barcode.create
int iCurrent
call super::create
this.dw_qgerm=create dw_qgerm
this.st_1=create st_1
this.em_dtcomptage=create em_dtcomptage
this.dw_cpt=create dw_cpt
this.st_2=create st_2
this.sle_barcode=create sle_barcode
this.cb_ok=create cb_ok
this.cb_cancel=create cb_cancel
this.gb_cpt=create gb_cpt
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_qgerm
this.Control[iCurrent+2]=this.st_1
this.Control[iCurrent+3]=this.em_dtcomptage
this.Control[iCurrent+4]=this.dw_cpt
this.Control[iCurrent+5]=this.st_2
this.Control[iCurrent+6]=this.sle_barcode
this.Control[iCurrent+7]=this.cb_ok
this.Control[iCurrent+8]=this.cb_cancel
this.Control[iCurrent+9]=this.gb_cpt
end on

on w_qgerm_barcode.destroy
call super::destroy
destroy(this.dw_qgerm)
destroy(this.st_1)
destroy(this.em_dtcomptage)
destroy(this.dw_cpt)
destroy(this.st_2)
destroy(this.sle_barcode)
destroy(this.cb_ok)
destroy(this.cb_cancel)
destroy(this.gb_cpt)
end on

event ue_open;call super::ue_open;str_params	lstr_params

wf_SetDWList({dw_cpt})

// par défaut, date de comptage = date du jour
em_dtcomptage.text = string(f_today(), "dd/mm/yyyy")
em_dtcomptage.getdata(idt_comptage)
end event

event ue_init_win;call super::ue_init_win;ib_dejaValide = FALSE
ib_new = FALSE

is_reflot = ""
ii_numtest = 0
ii_numrep = 0
ii_nbreinitial = 0
ii_nbretot = 0

cb_ok.enabled = FALSE
cb_cancel.enabled = FALSE
em_dtcomptage.enabled = TRUE
sle_barcode.enabled = TRUE
sle_barcode.text = ""
dw_qgerm.uf_reset()
dw_cpt.uf_reset()
dw_cpt.enabled = FALSE

dw_qgerm.uf_disabledata()

sle_barcode.setfocus()
end event

event ue_init_menu;call super::ue_init_menu;string	ls_menu[]
integer	li_item

li_item = 2
ls_menu = {"m_abandonner", "m_fermer"}

f_menuaction(ls_menu)



end event

type ddlb_message from w_ancestor_dataentry`ddlb_message within w_qgerm_barcode
integer x = 37
integer y = 1600
end type

type dw_qgerm from uo_datawindow_singlerow within w_qgerm_barcode
integer x = 37
integer y = 320
integer width = 2505
integer height = 96
integer taborder = 0
boolean enabled = false
string dataobject = "d_qgerm_barcode"
end type

type st_1 from uo_statictext within w_qgerm_barcode
integer x = 603
integer y = 64
integer width = 658
integer height = 80
boolean bringtotop = true
integer textsize = -12
integer weight = 700
long textcolor = 8388608
boolean enabled = false
string text = "Date de comptage"
boolean disabledlook = false
end type

type em_dtcomptage from uo_editmask within w_qgerm_barcode
integer x = 1262
integer y = 64
integer width = 457
integer height = 92
boolean bringtotop = true
integer textsize = -12
integer weight = 700
long textcolor = 8388608
alignment alignment = center!
maskdatatype maskdatatype = datemask!
string mask = "dd/mm/yyyy"
end type

event modified;call super::modified;date	ldt_comptage

this.getdata(ldt_comptage)
IF isNull(ldt_comptage) OR Year(ldt_comptage) < 2000 THEN
	gu_message.uf_error("Veuillez saisir une date du comptage correcte")
	this.text = string(idt_comptage, "dd/mm/yyyy")
	this.setFocus()
	return
END IF

idt_comptage = ldt_comptage
end event

type dw_cpt from uo_datawindow_singlerow within w_qgerm_barcode
integer x = 183
integer y = 512
integer width = 2194
integer height = 336
integer taborder = 20
boolean bringtotop = true
string dataobject = "d_qgerm_cpt_barcode_petri"
borderstyle borderstyle = stylebox!
end type

type st_2 from uo_statictext within w_qgerm_barcode
integer x = 603
integer y = 176
integer width = 622
integer height = 80
boolean bringtotop = true
integer textsize = -12
integer weight = 700
long textcolor = 8388608
boolean enabled = false
string text = "Code barre"
boolean disabledlook = false
end type

type sle_barcode from uo_sle within w_qgerm_barcode
integer x = 1262
integer y = 176
integer width = 677
integer height = 92
integer taborder = 10
boolean bringtotop = true
integer textsize = -12
integer weight = 700
long textcolor = 8388608
textcase textcase = upper!
end type

event modified;call super::modified;string	ls_barcode, ls_reflot, ls_rep_bac
integer	li_numtest, li_numrep
long		ll_pos1, ll_pos2

// décomposer le barcode en n° de référence du lot, n° de test, n) de répétition (ou de bac)
ls_barcode = sle_barcode.text

// position des 2 tirets
ll_pos1 = pos(ls_barcode, "-")
ll_pos2 = pos(ls_barcode, "-", ll_pos1 + 1)

// n° de lot
ls_reflot = left(ls_barcode, ll_pos1 - 1)

// n° de test
li_numtest = integer(mid(ls_barcode, ll_pos1 + 1, ll_pos2 - (ll_pos1 + 1)))

// n° de répétition/bac
ls_rep_bac = mid(ls_barcode, ll_pos2 + 1)

// barcode à priori valide ?
IF f_isEmptyString(ls_reflot) OR isNull(li_numtest) OR li_numtest=0 OR f_isEmptyString(ls_rep_bac) THEN
	gu_message.uf_error("Barcode non valide : n° de lot, de test ou de répétition/bac nul")
	this.setFocus()
	return
END IF
is_reflot = ls_reflot
ii_numtest = li_numtest
ii_numrep = integer(ls_rep_bac)
ii_idbac = integer(ls_rep_bac)
post wf_init()

end event

type cb_ok from uo_cb_ok within w_qgerm_barcode
integer x = 713
integer y = 1440
integer width = 439
integer height = 144
boolean bringtotop = true
end type

event clicked;call super::clicked;integer	li_nbre, li_newnbretot, li_status, li_num

dw_cpt.accepttext()

// message d'information si le nombre de germes saisi est supérieur au nombre de graines de départ
// (uniquement pour les espèces comptabilisables)
// question : test à confirmer car pas le même que dans l'autre programme !
IF is_typeqte = "C" THEN
	IF is_typetest = "P" THEN
		// test en boîte de Pétri : c_nbre contient le nombre introduit.
		// ii_nbretot contient le nombre total déjà introduit pour tout le test.
		// id_qte contient la quantité initiale de graines.
		li_nbre = dw_cpt.object.c_nbre[1]
		li_newnbretot = ii_nbretot + li_nbre - ii_nbreinitial
	ELSE
		// test sur substrat : c_nbretot contient la somme des nombres introduits nbre1~nbre12.
		// ii_nbretot contient le nombre total déjà introduit pour tout le test, uniquement pour 
		// le bac en cours.
		// id_qte contient la quantité initiale de graines.
		li_nbre = dw_cpt.object.c_nbretot[1]
		li_newnbretot = ii_nbretot + li_nbre - ii_nbreinitial
	END IF
	IF li_newnbretot > id_qte THEN
		IF gu_message.uf_query("Le nombre de germes dénombré (" + &
			f_string(li_newnbretot) + ") est supérieur au nombre de graines initial (" + &
			string(id_qte, "####0") + "). Enregistrer quand même ?", YesNo!, 1) = 2 THEN
			return(-1)
		END IF
	END IF
END IF

// test en boîte de Pétri : recopier le nombre de germes saisi dans le nombre 
//	correspondant à la répétition
IF is_typetest = "P" THEN
	dw_cpt.setitem(1, "nbre" + string(ii_numrep), li_nbre)
END IF

// si nouvelle date de relevé et donc nouvelle row créée dans dw_cpt, trouver prochain n° NUM_CPT
IF ib_new THEN
	select max(num_cpt) into :li_num from graine_qgerm_cpt 
		where ref_lot=:is_reflot and num_test=:ii_numtest using ESQLCA;
	IF isNull(li_num) THEN li_num = 1
	li_num = li_num + 1
	IF li_num > 99 THEN
		gu_message.uf_error("Nombre maximum (99) atteint !")
		return(-1)
	END IF
	dw_cpt.object.num_cpt[1] = li_num
END IF

// update DW
li_status = gu_dwservices.uf_updatetransact(dw_cpt)
CHOOSE CASE li_status
	CASE 1
		wf_message("Relevé enregistré avec succès")
		parent.event ue_init_win()
		return(1)
	CASE -1
		populateerror(20000,"")
		gu_message.uf_unexp("GRAINE_QGERM_CPT : Erreur lors de la mise à jour de la base de données")
		return(-1)
END CHOOSE

end event

type cb_cancel from uo_cb_cancel within w_qgerm_barcode
integer x = 1390
integer y = 1440
integer width = 439
integer height = 144
boolean bringtotop = true
end type

event clicked;call super::clicked;parent.event ue_abandonner()
end event

type gb_cpt from uo_groupbox within w_qgerm_barcode
integer x = 37
integer y = 464
integer width = 2523
integer height = 416
boolean enabled = false
end type

