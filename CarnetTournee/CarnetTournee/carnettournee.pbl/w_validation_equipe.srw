//objectcomments Validation du planning ou du réalisé d'une semaine pour plusieurs préposés en une fois
forward
global type w_validation_equipe from w_ancestor_dataentry
end type
type uo_semaine from uvo_navweek within w_validation_equipe
end type
type dw_prepose from uo_datawindow_multiplerow within w_validation_equipe
end type
type rb_planifie from uo_radiobutton within w_validation_equipe
end type
type rb_realise from uo_radiobutton within w_validation_equipe
end type
type cb_valider from uo_cb within w_validation_equipe
end type
type gb_1 from uo_groupbox within w_validation_equipe
end type
end forward

global type w_validation_equipe from w_ancestor_dataentry
string tag = "TEXT_00566"
integer width = 3195
integer height = 2344
string title = "Validation pour plusieurs préposés"
boolean maxbox = true
boolean resizable = true
event ue_print ( )
event ue_duplicate ( )
event ue_attempt_reconnect ( )
uo_semaine uo_semaine
dw_prepose dw_prepose
rb_planifie rb_planifie
rb_realise rb_realise
cb_valider cb_valider
gb_1 gb_1
end type
global w_validation_equipe w_validation_equipe

type variables
integer	ii_year, ii_week
date		idt_from, idt_to

end variables

forward prototypes
public function integer wf_retrieve ()
public function integer wf_retrieve_valid ()
end prototypes

event ue_attempt_reconnect();// event à exécuter après une reconnexion à la DB suite à une perte de connexion
dw_prepose.settransobject(SQLCA)

end event

public function integer wf_retrieve ();string	ls_super, ls_matricule, ls_planning_valid, ls_realise_valid, ls_err
long		ll_row

// Lire la liste des préposés du responsable
// Attention : si membre du groupe de superusers "FULL", accès à tous les agents paramétrés dans le système !
IF gu_privs.uf_super("FULL") THEN
	ls_super = "O"
ELSE
	ls_super = "N"
END IF

// Pour modifier les validations, seul le droit d'accès au programme est nécessaire, pas de droit particuliers requis
IF dw_prepose.retrieve(gs_username, ls_super, "N", "N", "N", "N") <= 0 THEN
	ls_err = "Erreur lecture liste des préposés"
	populateError(20000, "")
	GOTO ERREUR
ELSE
	// Lire si l'état de validation de la semaine
	wf_retrieve_valid()
END IF
return(1)

ERREUR:
gu_message.uf_unexp(ls_err)
return(-1)
end function

public function integer wf_retrieve_valid ();// Lire si la semaine est déjà validée. On lit aussi bien la validation du planifié que du réalisé.
string	ls_matricule, ls_planning_valid, ls_realise_valid, ls_err
long		ll_row

FOR ll_row = 1 TO dw_prepose.rowCount()
	ls_matricule = f_string(dw_prepose.object.prep_matricule[ll_row])
	select planning_valid, realise_valid into :ls_planning_valid, :ls_realise_valid
		from semaine_valid where matricule=:ls_matricule and annee=:ii_year and semaine=:ii_week using ESQLCA;
	IF ESQLCA.sqlcode = -1 THEN 
		ls_err = "Erreur lecture SEMAINE_VALID"
		populateError(20000, "")
		GOTO ERREUR
	END IF
	IF ESQLCA.sqlcode = 100 THEN
		ls_planning_valid = "N"
		ls_realise_valid = "N"
	END IF
	dw_prepose.object.c_planning_valid[ll_row] = ls_planning_valid
	dw_prepose.object.c_realise_valid[ll_row] = ls_realise_valid
NEXT
return(1)

ERREUR:
gu_message.uf_unexp(ls_err)
return(-1)
end function

event ue_open;call super::ue_open;rb_planifie.checked = FALSE
rb_realise.checked = FALSE

// afficher les colonnes d'état des validations
dw_prepose.object.c_planning_valid.visible = TRUE
dw_prepose.object.c_realise_valid.visible = TRUE
dw_prepose.object.c_planning_valid_t.visible = TRUE
dw_prepose.object.c_realise_valid_t.visible = TRUE

end event

on w_validation_equipe.create
int iCurrent
call super::create
this.uo_semaine=create uo_semaine
this.dw_prepose=create dw_prepose
this.rb_planifie=create rb_planifie
this.rb_realise=create rb_realise
this.cb_valider=create cb_valider
this.gb_1=create gb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.uo_semaine
this.Control[iCurrent+2]=this.dw_prepose
this.Control[iCurrent+3]=this.rb_planifie
this.Control[iCurrent+4]=this.rb_realise
this.Control[iCurrent+5]=this.cb_valider
this.Control[iCurrent+6]=this.gb_1
end on

on w_validation_equipe.destroy
call super::destroy
destroy(this.uo_semaine)
destroy(this.dw_prepose)
destroy(this.rb_planifie)
destroy(this.rb_realise)
destroy(this.cb_valider)
destroy(this.gb_1)
end on

event resize;call super::resize;gb_1.width = newwidth - 32
dw_prepose.height = newheight - dw_prepose.y - cb_valider.height - 140
dw_prepose.width = gb_1.width
cb_valider.y = dw_prepose.y + dw_prepose.height + 20
cb_valider.x = (newwidth / 2) - (cb_valider.width / 2)
end event

event ue_init_menu;call super::ue_init_menu;f_menuaction({"m_fermer"})

end event

event ue_postopen;call super::ue_postopen;// lecture de la liste des préposés
IF wf_retrieve() = -1 THEN
	post close(this)
END IF
end event

type ddlb_message from w_ancestor_dataentry`ddlb_message within w_validation_equipe
end type

type uo_semaine from uvo_navweek within w_validation_equipe
integer x = 1353
integer y = 64
boolean bringtotop = true
end type

on uo_semaine.destroy
call uvo_navweek::destroy
end on

event ue_next;call super::ue_next;idt_from = uo_semaine.uf_getfrom()
idt_to = uo_semaine.uf_getto()
ii_year = uo_semaine.uf_getyear()
ii_week = uo_semaine.uf_getweek()

// actualisation statut validation
wf_retrieve_valid()
end event

event ue_prev;call super::ue_prev;idt_from = uo_semaine.uf_getfrom()
idt_to = uo_semaine.uf_getto()
ii_year = uo_semaine.uf_getyear()
ii_week = uo_semaine.uf_getweek()

// actualisation statut validation
wf_retrieve_valid()
end event

event ue_init;call super::ue_init;idt_from = uo_semaine.uf_getfrom()
idt_to = uo_semaine.uf_getto()
ii_year = uo_semaine.uf_getyear()
ii_week = uo_semaine.uf_getweek()

end event

type dw_prepose from uo_datawindow_multiplerow within w_validation_equipe
integer x = 18
integer y = 224
integer width = 2926
integer height = 1488
integer taborder = 10
boolean bringtotop = true
string dataobject = "d_prepose_multiple"
boolean hscrollbar = true
boolean vscrollbar = true
boolean border = true
end type

type rb_planifie from uo_radiobutton within w_validation_equipe
string tag = "TEXT_00567"
integer x = 55
integer y = 80
integer width = 567
boolean bringtotop = true
string text = "Valider le planning"
end type

type rb_realise from uo_radiobutton within w_validation_equipe
string tag = "TEXT_00568"
integer x = 658
integer y = 80
integer width = 544
boolean bringtotop = true
string text = "Valider le réalisé"
end type

type cb_valider from uo_cb within w_validation_equipe
string tag = "TEXT_00536"
integer x = 1189
integer y = 1968
integer width = 677
integer taborder = 20
boolean bringtotop = true
string text = "Valider"
end type

event clicked;call super::clicked;// Attention : aucun contrôle n'est effectué ici sur les activités des agents. Si on était amené à vérifier 
// certaines choses avant de valider, cela devrait être implémenté ici !
br_semaine	lbr_semaine
string	ls_msg, ls_PR, ls_matricule
long		ll_row
integer	li_rtn

// vérifier choix de valider le planifié ou le réalisé
IF NOT rb_planifie.checked AND NOT rb_realise.checked THEN
	ls_msg = f_translate_getlabel("TEXT_00779", "Veuillez sélectionner P(lanifié) ou R(éalisé)")
	gu_message.uf_info(ls_msg)
	return
END IF

// vérifier s'il y a au moins un préposé sélectionné
IF integer(dw_prepose.object.c_sum_selected[1]) = 0 THEN
	gu_message.uf_info(f_translate_getlabel("TEXT_00789", "Veuillez sélectionner un ou plusieurs préposé(s)"))
	dw_prepose.SetFocus()
	return
END IF

IF rb_planifie.checked THEN ls_PR = "planifiées" ELSE ls_PR = "réalisées"

// confirmation
IF gu_message.uf_query("Vous êtes sur le point de valider cette semaine d'activités " + ls_PR + &
			", pour chacun des agents sélectionnés.~n~nLes prestations réalisées au cours de cette semaine ne pourront plus être modifiées par la suite.~n~n" + &
			"Confirmez-vous votre choix ?", YesNo!, 2) = 2 THEN
	return
END IF

lbr_semaine = CREATE br_semaine
// Valider la semaine de chacun des préposés sélectionnés
FOR ll_row = 1 TO dw_prepose.rowCount()
	IF integer(dw_prepose.object.c_select[ll_row]) = 0 THEN 
		CONTINUE
	END IF
	ls_matricule = f_string(dw_prepose.object.prep_matricule[ll_row])
	// Soit le planifié...
	IF rb_planifie.checked THEN
		li_rtn = lbr_semaine.uf_valid_planning(ls_matricule, ii_year, ii_week)
	ELSE
	// ... soit le réalisé
		li_rtn = lbr_semaine.uf_valid_realise(ls_matricule, ii_year, ii_week)
	END IF
	IF li_rtn = 1 THEN
		wf_message("Activités " + ls_PR + " : semaine " + f_string(ii_year) + "/" + f_string(ii_week) + " validée pour l'agent " + ls_matricule)
	ELSE
		populateError(20000, "Erreur validation activités " + ls_PR + " " + f_string(ii_year) + "/" + f_string(ii_week) + " agent " + ls_matricule)
		gu_message.uf_unexp("")
		GOTO ERREUR
	END IF
NEXT
DESTROY lbr_semaine

// actualisation statut validation
wf_retrieve_valid()
return

ERREUR:
DESTROY lbr_semaine
return

end event

type gb_1 from uo_groupbox within w_validation_equipe
integer x = 18
integer width = 3127
integer height = 208
end type

