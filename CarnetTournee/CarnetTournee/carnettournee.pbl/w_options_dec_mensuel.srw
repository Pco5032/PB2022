//objectcomments Paramètres pour la déclaration mensuelle
forward
global type w_options_dec_mensuel from w_ancestor
end type
type dw_annee from uo_datawindow_singlerow within w_options_dec_mensuel
end type
type dw_mois from uo_datawindow_singlerow within w_options_dec_mensuel
end type
type st_2 from uo_statictext within w_options_dec_mensuel
end type
type st_1 from uo_statictext within w_options_dec_mensuel
end type
type st_prep from uo_statictext within w_options_dec_mensuel
end type
type st_annee from uo_statictext within w_options_dec_mensuel
end type
type em_heures from uo_editmask within w_options_dec_mensuel
end type
type cb_ok from uo_cb_ok within w_options_dec_mensuel
end type
type cb_cancel from uo_cb_cancel within w_options_dec_mensuel
end type
type rb_no from uo_radiobutton within w_options_dec_mensuel
end type
type rb_all from uo_radiobutton within w_options_dec_mensuel
end type
type rb_bonif from uo_radiobutton within w_options_dec_mensuel
end type
type rb_xxxx from uo_radiobutton within w_options_dec_mensuel
end type
type gb_1 from uo_groupbox within w_options_dec_mensuel
end type
type dw_prepose from uo_datawindow_singlerow within w_options_dec_mensuel
end type
end forward

global type w_options_dec_mensuel from w_ancestor
string tag = "TEXT_00693"
integer width = 2002
integer height = 1084
string title = "Déclaration mensuelle"
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
dw_annee dw_annee
dw_mois dw_mois
st_2 st_2
st_1 st_1
st_prep st_prep
st_annee st_annee
em_heures em_heures
cb_ok cb_ok
cb_cancel cb_cancel
rb_no rb_no
rb_all rb_all
rb_bonif rb_bonif
rb_xxxx rb_xxxx
gb_1 gb_1
dw_prepose dw_prepose
end type
global w_options_dec_mensuel w_options_dec_mensuel

type variables
string	is_matricule
integer	ii_annee, ii_mois
end variables

forward prototypes
public subroutine wf_setrb ()
public subroutine wf_idchanged ()
end prototypes

public subroutine wf_setrb ();em_heures.enabled = rb_xxxx.checked
end subroutine

public subroutine wf_idchanged ();// PCO 10/01/2017 : lire et afficher l'éventuelle demande de paiement déjà stockée pour le préposé, l'année et la semaine choisie.
string	ls_dempaie
integer	li_heures

rb_no.checked = TRUE
em_heures.text = "0"

select dempaie into :ls_dempaie from mensuel_data 
	where matricule=:is_matricule and annee=:ii_annee and mois=:ii_mois using ESQLCA;

CHOOSE CASE f_check_sql(ESQLCA)
	CASE 0
		CHOOSE CASE ls_dempaie
			CASE "NO"
				rb_no.checked = TRUE
			CASE "BONIF"
				rb_bonif.checked = TRUE
			CASE "ALL"
				rb_all.checked = TRUE
			CASE ELSE
				IF isNumber(ls_dempaie) THEN
					em_heures.text = ls_dempaie
					rb_xxxx.checked = TRUE
				END IF
		END CHOOSE
END CHOOSE

wf_setRB()




end subroutine

on w_options_dec_mensuel.create
int iCurrent
call super::create
this.dw_annee=create dw_annee
this.dw_mois=create dw_mois
this.st_2=create st_2
this.st_1=create st_1
this.st_prep=create st_prep
this.st_annee=create st_annee
this.em_heures=create em_heures
this.cb_ok=create cb_ok
this.cb_cancel=create cb_cancel
this.rb_no=create rb_no
this.rb_all=create rb_all
this.rb_bonif=create rb_bonif
this.rb_xxxx=create rb_xxxx
this.gb_1=create gb_1
this.dw_prepose=create dw_prepose
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_annee
this.Control[iCurrent+2]=this.dw_mois
this.Control[iCurrent+3]=this.st_2
this.Control[iCurrent+4]=this.st_1
this.Control[iCurrent+5]=this.st_prep
this.Control[iCurrent+6]=this.st_annee
this.Control[iCurrent+7]=this.em_heures
this.Control[iCurrent+8]=this.cb_ok
this.Control[iCurrent+9]=this.cb_cancel
this.Control[iCurrent+10]=this.rb_no
this.Control[iCurrent+11]=this.rb_all
this.Control[iCurrent+12]=this.rb_bonif
this.Control[iCurrent+13]=this.rb_xxxx
this.Control[iCurrent+14]=this.gb_1
this.Control[iCurrent+15]=this.dw_prepose
end on

on w_options_dec_mensuel.destroy
call super::destroy
destroy(this.dw_annee)
destroy(this.dw_mois)
destroy(this.st_2)
destroy(this.st_1)
destroy(this.st_prep)
destroy(this.st_annee)
destroy(this.em_heures)
destroy(this.cb_ok)
destroy(this.cb_cancel)
destroy(this.rb_no)
destroy(this.rb_all)
destroy(this.rb_bonif)
destroy(this.rb_xxxx)
destroy(this.gb_1)
destroy(this.dw_prepose)
end on

event ue_open;call super::ue_open;DatawindowChild	ldwc_dropdown
long		ll_nbrows
string	ls_super

f_centerInMdi(this)

dw_prepose.insertrow(0)
dw_mois.insertrow(0)
dw_annee.insertrow(0)
dw_annee.uf_setdefaultvalue(1, "i_annee", year(today()))

// Lire la liste des préposés du responsable auquel est ajouté l'utilisateur lui-même
// Attention : si membre du groupe de superusers "FULL", accès à tous les agents paramétrés dans le système !
IF gu_privs.uf_super("FULL") THEN
	ls_super = "O"
ELSE
	ls_super = "N"
END IF
dw_prepose.GetChild("prep_matricule", ldwc_dropdown)
ldwc_dropdown.settransobject(SQLCA)
// 07/2015 : argument "R" : indique qu'on souhaite la liste des agents pour lesquels on a le droit 
// de consulter (et peut-être modifier) le Réalisé.
ll_nbrows = ldwc_dropdown.retrieve(gs_username, ls_super, "R")
IF ll_nbrows <= 0 THEN
	dw_prepose.insertrow(0)
	populateError(20000, "Erreur lecture des préposés pour " + f_string(gs_username))
ELSE
	// PCO 02MAI2016 : si on met 0 dans le nombre de lignes du DDDW, la liste est correcte mais très réduite 
	// et peu lisible si beaucoup d'agents à afficher. Si on met un nombre de ligne (20 par exemple), la liste
	// est correcte sauf si nombre à afficher est réduit (par exemple un seul préposé) car la ligne de titre
	// est prise en compte ! Ici, je force pour que la liste soit toujours correcte.
	IF ll_nbrows < 5 THEN
		dw_prepose.Object.prep_matricule.dddw.lines = 0
	END IF
END IF
end event

event ue_closebyxaccepted;call super::ue_closebyxaccepted;CloseWithReturn(this, -1)
end event

type dw_annee from uo_datawindow_singlerow within w_options_dec_mensuel
integer x = 622
integer y = 144
integer width = 311
integer height = 96
integer taborder = 20
string dataobject = "d_annee"
end type

event ue_itemvalidated;call super::ue_itemvalidated;ii_annee = integer(as_data)
wf_idChanged()
end event

event editchanged;call super::editchanged;this.acceptText()
end event

type dw_mois from uo_datawindow_singlerow within w_options_dec_mensuel
integer x = 1097
integer y = 144
integer width = 457
integer height = 96
integer taborder = 30
string dataobject = "d_mois"
end type

event ue_itemvalidated;call super::ue_itemvalidated;ii_mois = integer(as_data)
wf_idChanged()
end event

type st_2 from uo_statictext within w_options_dec_mensuel
string tag = "TEXT_00720"
integer x = 1207
integer y = 468
string text = "heure(s)"
end type

type st_1 from uo_statictext within w_options_dec_mensuel
string tag = "TEXT_00651"
integer x = 914
integer y = 144
integer width = 165
integer height = 80
boolean bringtotop = true
string text = "Mois"
alignment alignment = right!
end type

type st_prep from uo_statictext within w_options_dec_mensuel
string tag = "TEXT_00714"
integer x = 347
integer y = 32
integer width = 256
integer height = 80
boolean bringtotop = true
string text = "Préposé"
end type

type st_annee from uo_statictext within w_options_dec_mensuel
string tag = "TEXT_00621"
integer x = 347
integer y = 144
integer width = 256
integer height = 80
boolean bringtotop = true
string text = "Année"
end type

type em_heures from uo_editmask within w_options_dec_mensuel
integer x = 987
integer y = 464
integer width = 201
integer height = 80
integer taborder = 40
integer textsize = -9
boolean enabled = false
alignment alignment = right!
string mask = "###0"
end type

type cb_ok from uo_cb_ok within w_options_dec_mensuel
string tag = "TEXT_00027"
integer x = 421
integer y = 832
boolean default = false
end type

event clicked;call super::clicked;str_params	lstr_params
integer		li_heures, li_count
string		ls_dempaie

IF f_isEmptyString(is_matricule) THEN
	gu_message.uf_error("Veuillez sélectionner un préposé")
	return
END IF

IF isNull(ii_annee) OR ii_annee < 2000 THEN
	gu_message.uf_error("Veuillez sélectionner l'année de prestations")
	return
END IF

IF isNull(ii_mois) OR ii_mois = 0 THEN
	gu_message.uf_error("Veuillez sélectionner le mois de prestations")
	return
END IF

lstr_params.a_param[1] = is_matricule
lstr_params.a_param[2] = ii_annee
lstr_params.a_param[3] = ii_mois

setNull(li_heures)
IF rb_no.checked THEN
	ls_dempaie = "NO"
ELSEIF rb_xxxx.checked  THEN
	li_heures = double(em_heures.text)
	IF isNull(li_heures) OR li_heures= 0 THEN
		gu_message.uf_error("Veuillez saisir le nombre d'heures à payer")
		return
	END IF
	ls_dempaie = em_heures.text
ELSEIF rb_bonif.checked  THEN
	ls_dempaie = "BONIF"
ELSEIF rb_all.checked  THEN
	ls_dempaie = "ALL"
ELSE
	gu_message.uf_error("Veuillez sélectionner une option de paiement")
	return
END IF
lstr_params.a_param[4] = ls_dempaie

// PCO 24/11/2016 : stocker la demande de paiement pour pouvoir la réutiliser dans le document W_RPT_IRR
select count(*) into :li_count from mensuel_data 
	where matricule=:is_matricule and annee=:ii_annee and mois=:ii_mois using ESQLCA;
IF f_check_sql(ESQLCA) = 0 THEN
	IF li_count = 0 THEN
		insert into mensuel_data (matricule, annee, mois, dempaie)
			values (:is_matricule, :ii_annee, :ii_mois, :ls_dempaie) using ESQLCA;
	ELSE
		update mensuel_data set dempaie=:ls_dempaie
			where matricule=:is_matricule and annee=:ii_annee and mois=:ii_mois using ESQLCA;
	END IF
END IF
IF f_check_sql(ESQLCA) = 0 THEN
	commit using ESQLCA;
END IF

CloseWithReturn(Parent, lstr_params)
end event

type cb_cancel from uo_cb_cancel within w_options_dec_mensuel
string tag = "TEXT_00028"
integer x = 1115
integer y = 832
boolean cancel = false
end type

event clicked;call super::clicked;CloseWithReturn(Parent, -1)
end event

type rb_no from uo_radiobutton within w_options_dec_mensuel
string tag = "TEXT_00716"
integer x = 293
integer y = 384
integer width = 1010
string text = "Pas de demande"
end type

event clicked;call super::clicked;wf_setRB()
end event

type rb_all from uo_radiobutton within w_options_dec_mensuel
string tag = "TEXT_00719"
integer x = 293
integer y = 624
integer width = 1294
string text = "Je désire être payé de toutes les heures"
end type

event clicked;call super::clicked;wf_setRB()
end event

type rb_bonif from uo_radiobutton within w_options_dec_mensuel
string tag = "TEXT_00718"
integer x = 293
integer y = 544
integer width = 1294
string text = "Je désire être payé des heures de bonification"
end type

event clicked;call super::clicked;wf_setRB()
end event

type rb_xxxx from uo_radiobutton within w_options_dec_mensuel
string tag = "TEXT_00717"
integer x = 293
integer y = 464
integer width = 933
string text = "Je désire être payé de"
end type

event clicked;call super::clicked;wf_setRB()
end event

type gb_1 from uo_groupbox within w_options_dec_mensuel
string tag = "TEXT_00715"
integer x = 73
integer y = 288
integer width = 1829
integer height = 496
integer weight = 700
long textcolor = 8388608
string text = "Demande de paiement"
end type

type dw_prepose from uo_datawindow_singlerow within w_options_dec_mensuel
integer x = 603
integer y = 32
integer width = 933
integer height = 96
integer taborder = 10
boolean bringtotop = true
string dataobject = "d_choix_prepose"
end type

event ue_itemvalidated;call super::ue_itemvalidated;is_matricule = as_data
wf_idChanged()
end event

