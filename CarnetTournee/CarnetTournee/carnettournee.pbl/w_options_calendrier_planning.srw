//objectcomments Calendrier des activités planifiées : sélection des données
forward
global type w_options_calendrier_planning from w_ancestor
end type
type cb_invert from uo_cb within w_options_calendrier_planning
end type
type st_3 from uo_statictext within w_options_calendrier_planning
end type
type st_2 from uo_statictext within w_options_calendrier_planning
end type
type st_1 from uo_statictext within w_options_calendrier_planning
end type
type em_fin from uo_editmask within w_options_calendrier_planning
end type
type em_debut from uo_editmask within w_options_calendrier_planning
end type
type cb_2 from uo_cb_cancel within w_options_calendrier_planning
end type
type cb_1 from uo_cb_ok within w_options_calendrier_planning
end type
type dw_prepose from uo_datawindow_multiplerow within w_options_calendrier_planning
end type
end forward

global type w_options_calendrier_planning from w_ancestor
string tag = "TEXT_00721"
integer width = 2171
integer height = 2412
string title = "Calendrier des activités planifiées : sélection"
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
cb_invert cb_invert
st_3 st_3
st_2 st_2
st_1 st_1
em_fin em_fin
em_debut em_debut
cb_2 cb_2
cb_1 cb_1
dw_prepose dw_prepose
end type
global w_options_calendrier_planning w_options_calendrier_planning

type variables
date	idt_debut, idt_fin
end variables

event ue_postopen;call super::ue_postopen;string	ls_super

// Lire la liste des préposés du responsable.
// Attention : si membre du groupe de superusers "FULL", accès à tous les agents paramétrés dans le système !
IF gu_privs.uf_super("FULL") THEN
	ls_super = "O"
ELSE
	ls_super = "N"
END IF

// ) le droit de consulter le planning est nécessaire, pas celui de le modifier : 3ème argument="O" et 4ème argument="N"
// - concernant le réalisé, aucun droit n'est impliqué : 5 et 6ème arguments = "N"
IF dw_prepose.retrieve(gs_username, ls_super, "O", "N", "N", "N") <= 0 THEN
	populateError(20000, "Erreur lecture liste des préposés")
	post CloseWithReturn(this, -1)
	return
END IF


end event

on w_options_calendrier_planning.create
int iCurrent
call super::create
this.cb_invert=create cb_invert
this.st_3=create st_3
this.st_2=create st_2
this.st_1=create st_1
this.em_fin=create em_fin
this.em_debut=create em_debut
this.cb_2=create cb_2
this.cb_1=create cb_1
this.dw_prepose=create dw_prepose
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_invert
this.Control[iCurrent+2]=this.st_3
this.Control[iCurrent+3]=this.st_2
this.Control[iCurrent+4]=this.st_1
this.Control[iCurrent+5]=this.em_fin
this.Control[iCurrent+6]=this.em_debut
this.Control[iCurrent+7]=this.cb_2
this.Control[iCurrent+8]=this.cb_1
this.Control[iCurrent+9]=this.dw_prepose
end on

on w_options_calendrier_planning.destroy
call super::destroy
destroy(this.cb_invert)
destroy(this.st_3)
destroy(this.st_2)
destroy(this.st_1)
destroy(this.em_fin)
destroy(this.em_debut)
destroy(this.cb_2)
destroy(this.cb_1)
destroy(this.dw_prepose)
end on

event ue_open;call super::ue_open;f_centerInMdi(this)

setNull(idt_debut)
setNull(idt_fin)
end event

event ue_closebyxaccepted;call super::ue_closebyxaccepted;CloseWithReturn(this, -1)
end event

type cb_invert from uo_cb within w_options_calendrier_planning
string tag = "TEXT_00791"
integer x = 1719
integer y = 2192
integer width = 421
integer height = 96
integer taborder = 30
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

type st_3 from uo_statictext within w_options_calendrier_planning
string tag = "TEXT_00531"
integer x = 567
integer y = 48
integer width = 128
integer height = 80
string text = "du"
alignment alignment = center!
end type

type st_2 from uo_statictext within w_options_calendrier_planning
string tag = "TEXT_00532"
integer x = 1207
integer y = 48
integer width = 128
integer height = 80
string text = "au"
alignment alignment = center!
end type

type st_1 from uo_statictext within w_options_calendrier_planning
string tag = "TEXT_00697"
integer x = 18
integer y = 48
integer width = 549
integer height = 80
string text = "Activités planifiées"
end type

type em_fin from uo_editmask within w_options_calendrier_planning
integer x = 1335
integer y = 32
integer width = 494
integer height = 96
integer taborder = 20
alignment alignment = center!
maskdatatype maskdatatype = datemask!
string mask = "dd/mm/yyyy"
boolean dropdowncalendar = true
end type

event modified;call super::modified;this.getdata(idt_fin)
end event

type em_debut from uo_editmask within w_options_calendrier_planning
integer x = 695
integer y = 32
integer width = 494
integer height = 96
integer taborder = 10
alignment alignment = center!
maskdatatype maskdatatype = datemask!
string mask = "dd/mm/yyyy"
boolean dropdowncalendar = true
end type

event modified;call super::modified;this.getdata(idt_debut)

end event

type cb_2 from uo_cb_cancel within w_options_calendrier_planning
string tag = "TEXT_00028"
integer x = 1115
integer y = 2176
end type

event clicked;call super::clicked;CloseWithReturn(parent, -1)
end event

type cb_1 from uo_cb_ok within w_options_calendrier_planning
string tag = "TEXT_00027"
integer x = 585
integer y = 2176
end type

event clicked;call super::clicked;str_params	lstr_params
string		ls_prepose[]
long			ll_row, ll_index

// verification des dates
IF isNull(idt_debut) OR isNull(idt_fin) THEN
	gu_message.uf_info(f_translate_getlabel("TEXT_00772", "Veuillez spécifier la période à prendre en compte (date de début et de fin)"))
	em_debut.setFocus()
	return
END IF

IF idt_fin < idt_debut THEN
	gu_message.uf_info(f_translate_getlabel("TEXT_00773", "La date de début doit être antérieure à la date de fin"))
	em_debut.setFocus()
	return
END IF

// vérifier qu'il y a au moins un préposé sélectionné
IF integer(dw_prepose.object.c_sum_selected[1]) = 0 THEN
	gu_message.uf_info(f_translate_getlabel("TEXT_00774", "Veuillez sélectionner le(s) préposé(s) dont vous souhaitez le planning"))
	dw_prepose.SetFocus()
	return
END IF

// garnir array contenant les préposés sélectionnés
ll_index = 0
FOR ll_row = 1 TO dw_prepose.rowcount()
	IF dw_prepose.object.c_select[ll_row] = 1 THEN
		ll_index++
		ls_prepose[ll_index] = dw_prepose.object.prep_matricule[ll_row] 
	END IF
NEXT

// renvoyer les arguments
lstr_params.a_param[1] = idt_debut
lstr_params.a_param[2] = idt_fin
lstr_params.a_param[3] = ls_prepose

CloseWithReturn(Parent, lstr_params)
end event

type dw_prepose from uo_datawindow_multiplerow within w_options_calendrier_planning
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

