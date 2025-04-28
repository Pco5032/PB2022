//objectcomments Sélection de la semaine et des agents pour le rapport de vérification de la cohérence de l'encodage
forward
global type w_selection_rpt_anomalies_encodage from w_ancestor
end type
type cb_invert from uo_cb within w_selection_rpt_anomalies_encodage
end type
type uo_semaine from uvo_navweek within w_selection_rpt_anomalies_encodage
end type
type cb_2 from uo_cb_cancel within w_selection_rpt_anomalies_encodage
end type
type cb_1 from uo_cb_ok within w_selection_rpt_anomalies_encodage
end type
type dw_prepose from uo_datawindow_multiplerow within w_selection_rpt_anomalies_encodage
end type
end forward

global type w_selection_rpt_anomalies_encodage from w_ancestor
string tag = "TEXT_00804"
integer width = 2171
integer height = 2412
string title = "Vérification de la cohérence des activités encodées : sélection"
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
cb_invert cb_invert
uo_semaine uo_semaine
cb_2 cb_2
cb_1 cb_1
dw_prepose dw_prepose
end type
global w_selection_rpt_anomalies_encodage w_selection_rpt_anomalies_encodage

type variables
string	is_type

end variables

event ue_postopen;call super::ue_postopen;string	ls_super, ls_plan_consult, ls_plan_modif, ls_real_consult, ls_real_modif

// Lire la liste des préposés du responsable.
// Attention : si membre du groupe de superusers "FULL", accès à tous les agents paramétrés dans le système !
IF gu_privs.uf_super("FULL") THEN
	ls_super = "O"
ELSE
	ls_super = "N"
END IF

// En fonction du type passé en argument (P ou R) :
// - si P : 
//		+ aucun droit n'est impliqué pour le réalisé : 5 et 6ème arguments = "N"
//		+ le droit de consulter le planifié est nécessaire, pas celui de le modifier : 3ème argument="O" et 4ème argument="N"
// - si R : 
//		+ aucun droit n'est impliqué pour le planifié : 3 et 4ème arguments = "N"
// 	+ le droit de consulter le réalisé est nécessaire, pas celui de le modifier : 5ème argument="O" et 6ème argument="N"
IF is_type = "P" THEN
	ls_plan_consult = "O"
	ls_plan_modif = "N"
	ls_real_consult = "N"
	ls_real_modif = "N"
ELSE
	ls_plan_consult = "N"
	ls_plan_modif = "N"
	ls_real_consult = "O"
	ls_real_modif = "N"
END IF
IF dw_prepose.retrieve(gs_username, ls_super, ls_plan_consult, ls_plan_modif, ls_real_consult, ls_real_modif) <= 0 THEN
	populateError(20000, "Erreur lecture liste des préposés")
	post CloseWithReturn(this, -1)
	return
END IF


end event

on w_selection_rpt_anomalies_encodage.create
int iCurrent
call super::create
this.cb_invert=create cb_invert
this.uo_semaine=create uo_semaine
this.cb_2=create cb_2
this.cb_1=create cb_1
this.dw_prepose=create dw_prepose
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_invert
this.Control[iCurrent+2]=this.uo_semaine
this.Control[iCurrent+3]=this.cb_2
this.Control[iCurrent+4]=this.cb_1
this.Control[iCurrent+5]=this.dw_prepose
end on

on w_selection_rpt_anomalies_encodage.destroy
call super::destroy
destroy(this.cb_invert)
destroy(this.uo_semaine)
destroy(this.cb_2)
destroy(this.cb_1)
destroy(this.dw_prepose)
end on

event ue_open;call super::ue_open;// récupérer le type d'activité : R ou P
is_type = message.stringparm

f_centerInMdi(this)

// choix de la semaine = manuel : permet de modifier les dates, le n° de semaine n'a alors plus de sens.
uo_semaine.uf_setmanual()

end event

event ue_closebyxaccepted;call super::ue_closebyxaccepted;CloseWithReturn(this, -1)
end event

type cb_invert from uo_cb within w_selection_rpt_anomalies_encodage
string tag = "TEXT_00791"
integer x = 1719
integer y = 2192
integer width = 421
integer height = 96
integer textsize = -8
string text = "Inverser sélection"
end type

event clicked;call super::clicked;// inverser sélection
long	ll_nbrows, ll_row

dw_prepose.SetRedraw(FALSE)
ll_nbrows = dw_prepose.RowCount()
FOR ll_row = 1 TO ll_Nbrows
	IF dw_prepose.object.c_select[ll_row] = 0 THEN
		dw_prepose.object.c_select[ll_row] = 1
	ELSE
		dw_prepose.object.c_select[ll_row] = 0
	END IF
NEXT
dw_prepose.SetRedraw(TRUE)
end event

type uo_semaine from uvo_navweek within w_selection_rpt_anomalies_encodage
integer x = 201
integer y = 16
integer taborder = 10
end type

on uo_semaine.destroy
call uvo_navweek::destroy
end on

type cb_2 from uo_cb_cancel within w_selection_rpt_anomalies_encodage
string tag = "TEXT_00028"
integer x = 1115
integer y = 2176
end type

event clicked;call super::clicked;CloseWithReturn(parent, -1)
end event

type cb_1 from uo_cb_ok within w_selection_rpt_anomalies_encodage
string tag = "TEXT_00027"
integer x = 585
integer y = 2176
boolean default = false
end type

event clicked;call super::clicked;str_params	lstr_params
string		ls_prepose[]
long			ll_row, ll_index
integer		li_year, li_week
date			ldt_from, ldt_to

// vérifier qu'il y a au moins un préposé sélectionné
IF integer(dw_prepose.object.c_sum_selected[1]) = 0 THEN
	gu_message.uf_info(f_translate_getlabel("TEXT_00789", "Veuillez sélectionner un ou plusieurs préposé(s)"))
	dw_prepose.SetFocus()
	return
END IF

// vérifier l'intervalle de dates
IF uo_semaine.uf_check_dates() = -1 THEN
	uo_semaine.setFocus()
	return
END IF

// récupérer n°semaine et dates
li_year = uo_semaine.uf_getyear()
li_week = uo_semaine.uf_getweek()
ldt_from = uo_semaine.uf_getfrom()
ldt_to = uo_semaine.uf_getto()

// garnir array contenant les préposés sélectionnés
ll_index = 0
FOR ll_row = 1 TO dw_prepose.rowcount()
	IF dw_prepose.object.c_select[ll_row] = 1 THEN
		ll_index++
		ls_prepose[ll_index] = dw_prepose.object.prep_matricule[ll_row] 
	END IF
NEXT

// renvoyer les arguments
lstr_params.a_param[1] = li_year
lstr_params.a_param[2] = li_week
lstr_params.a_param[3] = ldt_from
lstr_params.a_param[4] = ldt_to
lstr_params.a_param[5] = ls_prepose

CloseWithReturn(Parent, lstr_params)
end event

type dw_prepose from uo_datawindow_multiplerow within w_selection_rpt_anomalies_encodage
integer x = 18
integer y = 160
integer width = 2121
integer height = 1968
integer taborder = 0
boolean bringtotop = true
string dataobject = "d_prepose_multiple"
boolean hscrollbar = true
boolean vscrollbar = true
boolean border = true
end type

