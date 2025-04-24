//objectcomments Paramétrage fusion/publipostage : enregistrer ou pas le résultat du publipostage, fermer ou pas Word...
forward
global type w_publipostage_params from w_ancestor
end type
type cb_cancel from uo_cb_cancel within w_publipostage_params
end type
type cb_ok from uo_cb_ok within w_publipostage_params
end type
type dw_1 from uo_datawindow_singlerow within w_publipostage_params
end type
end forward

global type w_publipostage_params from w_ancestor
integer width = 1961
integer height = 488
string title = "Paramètres de publipostage"
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
long backcolor = 16777215
cb_cancel cb_cancel
cb_ok cb_ok
dw_1 dw_1
end type
global w_publipostage_params w_publipostage_params

event ue_open;call super::ue_open;str_params	lstr_params
integer		li_saveFormat

// récupérer les paramètres (n° EA, renvoyer EA ou pas, sélection étendue ou pas)
lstr_params = Message.PowerObjectParm

f_centerInMdi(this)

dw_1.insertRow(0)

// initialisation sur base des paramètres en cours (ou par défaut)
IF IsValid(lstr_params) THEN 
	// format du fichier enregistré (0:pas d'enregistrement, 16:docx, 17:pdf)
	li_saveFormat = integer(lstr_params.a_param[1])
	IF li_saveFormat = 0 OR (li_saveFormat <> 16 AND li_saveFormat <> 17) THEN
		dw_1.object.n_saveformat[1] = 16
		dw_1.object.s_save[1] = "N"
	ELSE
		dw_1.object.n_saveformat[1] = li_saveFormat
		dw_1.object.s_save[1] = "O"
	END IF
	// conserver Word ouvert après le publipostage O/N
	IF lstr_params.a_param[2] THEN 
		dw_1.object.s_keepWord[1] = "O"
	ELSE
		dw_1.object.s_keepWord[1] = "N"
	END IF
ELSE
	dw_1.object.s_save[1] = "N"
	dw_1.object.s_saveformat[1] = 16
	dw_1.object.s_keepWord[1] = "O"
END IF

end event

on w_publipostage_params.create
int iCurrent
call super::create
this.cb_cancel=create cb_cancel
this.cb_ok=create cb_ok
this.dw_1=create dw_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_cancel
this.Control[iCurrent+2]=this.cb_ok
this.Control[iCurrent+3]=this.dw_1
end on

on w_publipostage_params.destroy
call super::destroy
destroy(this.cb_cancel)
destroy(this.cb_ok)
destroy(this.dw_1)
end on

event ue_closebyxaccepted;call super::ue_closebyxaccepted;cb_cancel.Event clicked()
end event

type cb_cancel from uo_cb_cancel within w_publipostage_params
integer x = 1042
integer y = 256
integer taborder = 30
end type

event clicked;call super::clicked;CloseWithReturn(parent, -1)
end event

type cb_ok from uo_cb_ok within w_publipostage_params
integer x = 494
integer y = 256
integer taborder = 20
boolean default = false
end type

event clicked;call super::clicked;str_params	lstr_params

IF dw_1.object.s_save[1] = "O" THEN
	lstr_params.a_param[1] = dw_1.object.n_saveformat[1]
ELSE
	lstr_params.a_param[1] = 0
END IF
lstr_params.a_param[2] = dw_1.object.s_keepWord[1]

CloseWithReturn(parent, lstr_params)
end event

type dw_1 from uo_datawindow_singlerow within w_publipostage_params
integer y = 32
integer width = 1957
integer height = 208
integer taborder = 10
string dataobject = "d_publipostage_params"
end type

event ue_itemvalidated;call super::ue_itemvalidated;CHOOSE CASE as_name
	CASE "s_save"
		IF as_data = "N" THEN 
			dw_1.object.s_keepWord[1] = "O"
		END IF
END CHOOSE

end event

