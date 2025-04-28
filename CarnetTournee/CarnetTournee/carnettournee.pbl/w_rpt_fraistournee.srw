//objectcomments Déclaration de créance - indemnités pourfrais de tournée
forward
global type w_rpt_fraistournee from w_ancestor_rptpreview
end type
type cb_recto from uo_cb within w_rpt_fraistournee
end type
end forward

global type w_rpt_fraistournee from w_ancestor_rptpreview
string tag = "TEXT_00821"
string title = "Indemnités pour frais de tournée"
cb_recto cb_recto
end type
global w_rpt_fraistournee w_rpt_fraistournee

type variables
string	is_matricule
integer	ii_annee, ii_mois
end variables

on w_rpt_fraistournee.create
int iCurrent
call super::create
this.cb_recto=create cb_recto
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_recto
end on

on w_rpt_fraistournee.destroy
call super::destroy
destroy(this.cb_recto)
end on

event ue_init;call super::ue_init;str_params	lstr_params

// attribuer un nom de modèle : le même que pour les frais de parcours et de séjours
wf_setreportcritere("w_rpt_kmmensuel")
wf_setmodel("KMMENSUEL")

// critères par défaut
wf_ResetDefaults()
wf_setdefault("v_realise.matricule", "=")
wf_setdefault("v_realise.annee_cal", "=", year(today()))
wf_setdefault("v_realise.nummois", "=", month(today()))
end event

event ue_retrieve;call super::ue_retrieve;long		ll_rows, ll_row

ll_rows = AncestorReturnValue

IF ll_rows <= 0 THEN 
	gu_message.uf_info(gu_translate.uf_getlabel(is_tag_nodata, "Aucune donnée ne correspond à votre requête"))
	return(ll_rows)
END IF

return(ll_rows)
end event

type cb_defaults from w_ancestor_rptpreview`cb_defaults within w_rpt_fraistournee
end type

type st_2 from w_ancestor_rptpreview`st_2 within w_rpt_fraistournee
end type

type st_1 from w_ancestor_rptpreview`st_1 within w_rpt_fraistournee
end type

type dw_papersize from w_ancestor_rptpreview`dw_papersize within w_rpt_fraistournee
end type

type cb_next from w_ancestor_rptpreview`cb_next within w_rpt_fraistournee
end type

type cb_prev from w_ancestor_rptpreview`cb_prev within w_rpt_fraistournee
end type

type dw_1 from w_ancestor_rptpreview`dw_1 within w_rpt_fraistournee
string dataobject = "d_rpt_fraistournee"
end type

type em_zoom from w_ancestor_rptpreview`em_zoom within w_rpt_fraistournee
end type

type st_zoom from w_ancestor_rptpreview`st_zoom within w_rpt_fraistournee
end type

type gb_1 from w_ancestor_rptpreview`gb_1 within w_rpt_fraistournee
end type

type dw_paperorient from w_ancestor_rptpreview`dw_paperorient within w_rpt_fraistournee
end type

type cb_recto from uo_cb within w_rpt_fraistournee
integer x = 1006
integer y = 80
integer width = 494
integer taborder = 30
boolean bringtotop = true
string text = "Impression recto"
end type

event clicked;call super::clicked;// On dispose maintenant de la liste des agents et de la période qui répondent aux critères. On doit ajouter
// toutes les infos manquantes avant de pouvoir lancer le publipostage.
uo_creance	lu_creance
lu_creance = CREATE uo_creance
lu_creance.uf_publipostage("FT", dw_1, id_sequence)
DESTROY lu_creance
end event

