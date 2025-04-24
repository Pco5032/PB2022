forward
global type w_bold_drc_add from w_ancestor
end type
type em_expirydate from uo_editmask within w_bold_drc_add
end type
type st_expirydate from uo_statictext within w_bold_drc_add
end type
type mle_desc from uo_mle within w_bold_drc_add
end type
type st_3 from uo_statictext within w_bold_drc_add
end type
type dw_target from uo_datawindow_multiplerow within w_bold_drc_add
end type
type cb_cancel from uo_cb_cancel within w_bold_drc_add
end type
type cb_ok from uo_cb_ok within w_bold_drc_add
end type
type sle_subject from uo_sle within w_bold_drc_add
end type
type st_2 from uo_statictext within w_bold_drc_add
end type
type st_1 from uo_statictext within w_bold_drc_add
end type
end forward

global type w_bold_drc_add from w_ancestor
integer width = 3771
integer height = 2056
string title = "Demande de renseignement complémentaire"
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
boolean center = true
em_expirydate em_expirydate
st_expirydate st_expirydate
mle_desc mle_desc
st_3 st_3
dw_target dw_target
cb_cancel cb_cancel
cb_ok cb_ok
sle_subject sle_subject
st_2 st_2
st_1 st_1
end type
global w_bold_drc_add w_bold_drc_add

forward prototypes
public function integer wf_check_expirydate ()
end prototypes

public function integer wf_check_expirydate ();date	ldt_expiryDate

em_expirydate.getdata(ldt_expiryDate)

IF isNull(ldt_expiryDate) OR ldt_expiryDate <= f_today() THEN
	gu_message.uf_error("La date d'échéance est obligatoire et doit être > à la date du jour")
	return(-1)
END IF

return(1)
end function

on w_bold_drc_add.create
int iCurrent
call super::create
this.em_expirydate=create em_expirydate
this.st_expirydate=create st_expirydate
this.mle_desc=create mle_desc
this.st_3=create st_3
this.dw_target=create dw_target
this.cb_cancel=create cb_cancel
this.cb_ok=create cb_ok
this.sle_subject=create sle_subject
this.st_2=create st_2
this.st_1=create st_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.em_expirydate
this.Control[iCurrent+2]=this.st_expirydate
this.Control[iCurrent+3]=this.mle_desc
this.Control[iCurrent+4]=this.st_3
this.Control[iCurrent+5]=this.dw_target
this.Control[iCurrent+6]=this.cb_cancel
this.Control[iCurrent+7]=this.cb_ok
this.Control[iCurrent+8]=this.sle_subject
this.Control[iCurrent+9]=this.st_2
this.Control[iCurrent+10]=this.st_1
end on

on w_bold_drc_add.destroy
call super::destroy
destroy(this.em_expirydate)
destroy(this.st_expirydate)
destroy(this.mle_desc)
destroy(this.st_3)
destroy(this.dw_target)
destroy(this.cb_cancel)
destroy(this.cb_ok)
destroy(this.sle_subject)
destroy(this.st_2)
destroy(this.st_1)
end on

event ue_closebyxaccepted;call super::ue_closebyxaccepted;cb_cancel.Event clicked()
end event

event ue_open;call super::ue_open;string	ls_ndossier
str_params	lstr_params

// 09/02/2023 : fonctionnalités dispo uniquement en TEST
// 06/04/2023 : dispo an valid
// 20/04/2023 : dispo dans tous les environnements
//IF gs_envapp = "P" THEN
//	em_expirydate.enabled = FALSE
//	st_expirydate.enabled = FALSE
//END IF

// récupérer n° de dossier
lstr_params = Message.PowerObjectParm
IF IsValid(lstr_params) THEN 
	CHOOSE CASE upperbound(lstr_params.a_param)
		CASE 1
			ls_ndossier = string(lstr_params.a_param[1])
	END CHOOSE
END IF

IF f_isEmptyString(ls_ndossier) THEN
	post close(this)
	return
END IF

// Instancier BOLD si pas encore fait par un autre objet
IF NOT isValid(gu_bold) THEN
	gu_bold = CREATE uo_bold
END IF

// connexion BOLD
IF gu_bold.uf_connect() = -1 THEN
	post close(this)
	return
END IF

dw_target.setTransobject(gu_bold.itr_bold)

this.title = "Demande de renseignement complémentaire pour le dossier " + ls_ndossier
dw_target.retrieve(ls_ndossier)
end event

event ue_close;call super::ue_close;// déconnexion et destroy s'il n'y a plus de connexion en cours (par un autre objet éventuellement)
gu_bold.uf_disconnect()
IF gu_bold.uf_getconnectioncount() = 0 THEN
	DESTROY gu_bold
END IF

end event

type em_expirydate from uo_editmask within w_bold_drc_add
integer x = 640
integer y = 704
integer width = 475
integer height = 96
integer taborder = 30
maskdatatype maskdatatype = datemask!
string mask = "dd/mm/yyyy"
boolean dropdowncalendar = true
end type

type st_expirydate from uo_statictext within w_bold_drc_add
integer x = 73
integer y = 704
integer width = 530
string text = "Date d~'échéance"
end type

type mle_desc from uo_mle within w_bold_drc_add
integer x = 640
integer y = 224
integer width = 2999
integer height = 432
integer taborder = 20
boolean autovscroll = true
integer limit = 500
end type

type st_3 from uo_statictext within w_bold_drc_add
integer x = 73
integer y = 848
integer width = 549
integer height = 240
string text = "Document(s) concerné(s) par la demande"
end type

type dw_target from uo_datawindow_multiplerow within w_bold_drc_add
integer x = 640
integer y = 848
integer width = 2999
integer height = 928
integer taborder = 40
string dataobject = "d_bold_drc_target"
boolean vscrollbar = true
boolean border = true
end type

type cb_cancel from uo_cb_cancel within w_bold_drc_add
integer x = 1957
integer y = 1824
end type

event clicked;call super::clicked;closeWithReturn(parent, -1)
end event

type cb_ok from uo_cb_ok within w_bold_drc_add
integer x = 1317
integer y = 1824
boolean default = false
end type

event clicked;call super::clicked;str_params	lstr_params, lstr_target[]
long		ll_row
integer	li_i
date		ldt_expiryDate

IF f_isEmptyString(sle_subject.text) OR f_isEmptyString(mle_desc.text) THEN
	gu_message.uf_error("Le sujet ET la description de la DRC sont obligatoires")
	return
END IF

// 09/02/2023 : dispo uniquement en TEST
// 20/04 : dispo dans tous les environnements
IF wf_check_ExpiryDate() = -1 THEN
	return
ELSE
	em_expirydate.getdata(ldt_expiryDate)
END IF

FOR ll_row = 1 TO dw_target.rowcount()
	IF dw_target.object.c_select[ll_row] = "Y" THEN
		li_i++
		lstr_target[li_i].a_param[1] = dw_target.object.attachtype[ll_row]
		lstr_target[li_i].a_param[2] = dw_target.object.id[ll_row]
		lstr_target[li_i].a_param[3] = dw_target.object.nom[ll_row]
	END IF
NEXT

// PCO 24/04/2024 : msg avertissement si aucun target sélectionné
IF li_i = 0 THEN
	IF gu_message.uf_query("Aucun document sélectionné pour la DRC. Etes-vous certain de vouloir poursuivre ?", YesNo!, 2) = 2 THEN
		gu_message.uf_info("DRC abandonnée")
		return
	END IF
END IF

lstr_params.a_param[1] = sle_subject.text
lstr_params.a_param[2] = mle_desc.text
lstr_params.a_param[3] = ldt_expiryDate
lstr_params.a_param[4] = lstr_target

CloseWithReturn(Parent, lstr_params)
end event

type sle_subject from uo_sle within w_bold_drc_add
integer x = 640
integer y = 80
integer width = 2999
integer height = 96
integer taborder = 10
integer textsize = -9
integer limit = 100
end type

type st_2 from uo_statictext within w_bold_drc_add
integer x = 73
integer y = 224
integer width = 549
integer height = 144
string text = "Description de la demande"
end type

type st_1 from uo_statictext within w_bold_drc_add
integer x = 73
integer y = 96
integer width = 558
string text = "Sujet de la demande"
end type

