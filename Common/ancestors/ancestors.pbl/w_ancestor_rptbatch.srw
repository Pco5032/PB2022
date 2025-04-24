//objectcomments Ancêtre des reports sans prévisualisation
forward
global type w_ancestor_rptbatch from w_ancestor_rpt
end type
end forward

global type w_ancestor_rptbatch from w_ancestor_rpt
boolean visible = false
string title = "Impression sans visualisation"
boolean minbox = false
boolean maxbox = false
windowstate windowstate = minimized!
end type
global w_ancestor_rptbatch w_ancestor_rptbatch

type variables
uo_ds		ids_1
string	is_SelectInFrench
PRIVATE boolean	ib_confirm, ib_startauto

end variables

forward prototypes
public subroutine wf_setdataobject (string as_dataobject)
public subroutine wf_confirm (boolean ab_confirm)
public subroutine wf_startauto (boolean ab_auto)
public function boolean wf_startauto ()
public function integer wf_print ()
public function boolean wf_confirm ()
public function integer wf_start ()
end prototypes

public subroutine wf_setdataobject (string as_dataobject);ids_1.dataobject = as_dataobject
ids_1.SetTransObject(SQLCA)
end subroutine

public subroutine wf_confirm (boolean ab_confirm);ib_confirm = ab_confirm
end subroutine

public subroutine wf_startauto (boolean ab_auto);ib_startauto = ab_auto
end subroutine

public function boolean wf_startauto ();return(ib_startauto)
end function

public function integer wf_print ();// démarrage de l'impression
// Si démarrage automatique, le retrieve est suivi automatiquement de l'impression et la demande de
// confirmation est alors faite dans wf_start. 
// Sinon, le programmeur doit lui même invoquer la fonction wf_start pour initialiser et lire les data,
//        puis la fonction wf_print pour les imprimer. Dans ce cas, la confirmation se fait ici.
// return(1) : impression effectuée
// return(-1) : pas d'impression
boolean	lb_go

IF wf_confirm() THEN
	IF gu_message.uf_query("OK pour démarrer l'impression de : " + ids_1.Object.DataWindow.Print.Documentname + " ?") = 2 THEN
		return(-1)
	END IF
END IF

iu_wait.uf_openwindow()
this.event ue_print()
iu_wait.uf_closewindow()
return(1)

end function

public function boolean wf_confirm ();return(ib_confirm)
end function

public function integer wf_start ();// si démarrage automatique, l'introduction des critères, le retrieve et l'impression sont lancés automatiquement
// Sinon, le programmeur doit lui même invoquer la fonction wf_start pour initialiser et lire les date,
//        puis la fonction wf_print pour les imprimer
// return(1) : impression effectuée
// return(-1) : pas d'impression
integer	li_ret
boolean	lb_go

li_ret = this.event ue_beforeretrieve()
CHOOSE CASE li_ret
	CASE 0
//		gu_message.uf_info("Abandon demandé")
	CASE -1
		gu_message.uf_error("Erreur d'initialisation")
		return(-1)
	CASE 1
		// lecture des données et impression si l'utilisateur confirme son intention d'imprimer
		IF wf_startauto() THEN
			IF wf_confirm() THEN 
				IF gu_message.uf_query("OK pour démarrer l'impression de : " + ids_1.Object.DataWindow.Print.Documentname + " ?") = 1 THEN
					lb_go = TRUE
				ELSE
					lb_go = FALSE
				END IF
			ELSE
				lb_go = TRUE
			END IF
		ELSE
			lb_go = TRUE
		END IF
		IF lb_go THEN
			iu_wait.uf_openwindow()
			li_ret = this.event ue_retrieve()
			CHOOSE CASE li_ret
				CASE -1
					iu_wait.uf_closewindow()
					gu_message.uf_error("Erreur d'initialisation")
					return(-1)
				CASE 0
					iu_wait.uf_closewindow()
					return(-1)
				CASE ELSE
					IF wf_startauto() THEN
						this.event ue_print()
						iu_wait.uf_closewindow()
						return(1)
					END IF
			END CHOOSE
		ELSE
			gu_message.uf_info("Abandon demandé")
			return(-1)
		END IF
END CHOOSE
return(-1)
end function

on w_ancestor_rptbatch.create
call super::create
end on

on w_ancestor_rptbatch.destroy
call super::destroy
end on

event ue_beforeretrieve;call super::ue_beforeretrieve;// return 1 : OK
// return 0 : abandon lors de l'introduction des critères
// return -1 : erreur lors du SetSQLselect

integer		li_status
string		ls_originalselect, ls_newselect
w_selection	lw_selection

IF wf_sqlfromdw() THEN 
	ls_originalselect = ids_1.GetSQLSelect()
ELSE
	ls_originalselect = wf_getoriginalselect()
END IF

// les paramètres d'input destinés aux descendants de cet objet doivent être assigné avant d'arriver ici
// et être attribués au moyen de la fonction wf_setmoreselectparams
istr_inputparams.a_param[1] = wf_GetReportcritere()
istr_inputparams.a_param[2] = wf_getmodel()
istr_inputparams.a_param[3] = ls_originalselect
istr_inputparams.a_param[4] = wf_showselection()
istr_inputparams.a_param[5] = wf_trienabled()
istr_inputparams.a_param[6] = id_sequence
istr_inputparams.a_param[7] = wf_buttonsenabled()
istr_inputparams.a_param[8] = wf_getInsertionpoint()
istr_inputparams.a_param[9] = wf_getevalmsg()
istr_inputparams.a_param[10] = wf_getnbgroups()
istr_inputparams.a_param[11] = wf_appendorderby()

IF NOT wf_showselection() THEN
	// si on ne laisse pas l'utilisateur modifier la sélection par défaut, on utilise quand même le programme
	// de sélection de façon cachée pour créer l'ordre SQL complet
	opensheetWithParm(lw_selection, istr_inputparams, wf_getselectionwindow(), gw_mdiframe, 0, Original!)
	ls_newselect = lw_selection.wf_generateNewSelect(is_where, is_order)
	is_selectinfrench = lw_selection.wf_generatewherefr()
	close(lw_selection)
ELSE
	// la modification des critères est autorisée
	OpenWithparm(lw_selection, istr_inputparams, wf_getselectionwindow())
	IF Message.DoubleParm = -1 THEN
		return(0)
	ELSE
		istr_selectionparams = Message.PowerObjectParm
		ls_newselect = string(istr_selectionparams.a_param[1])
		is_selectinfrench = string(istr_selectionparams.a_param[2])
		is_where = string(istr_selectionparams.a_param[3])
		is_order = string(istr_selectionparams.a_param[4])
	END IF
END IF

IF IsNull(ls_newselect) THEN
	return(0)
ELSE
	IF LenA(trim(ls_newselect)) = 0 THEN
		return(1)
	ELSE
		// si l'ordre SQL provient du DW, on le remplace par le nouvel ordre SQL dans le DW
		IF wf_sqlfromdw() THEN 
			li_status = ids_1.SetSQLSelect(ls_newselect)
			IF li_status = 1 THEN
				return(1)
			ELSE
				gu_message.uf_error("Impossible d'assigner l'ordre SQL~n~n" + ls_newselect + "~n~n")
				return(-1)
			END IF
		// si l'ordre SQL ne provient pas du DW mais a été fournit directement par le programmeur, il faut 
		// compléter l'event ue_manualSQL avec ce qu'on veut
		ELSE
			return(this.event ue_manualSQL(ls_newselect))
		END IF
	END IF
END IF

end event

event ue_print;call super::ue_print;// impression du datastore
iu_wait.uf_addinfo(gu_translate.uf_getlabel(is_tag_printing, "Impression en cours"))
ids_1.print(wf_cancelpermitted())
return(1)


end event

event ue_retrieve;call super::ue_retrieve;// par défaut, simple retrieve mais on peut modifier ce comportement avec Override Ancestor SCript
// on passe comme argument de retrieve le n° de session et de séquence, à toutes fins utiles
iu_wait.uf_addinfo(gu_translate.uf_getlabel(is_tag_reading, "Lecture des données"))
return(ids_1.retrieve(gd_session, id_sequence))

end event

event ue_close;call super::ue_close;DESTROY ids_1
end event

event ue_open;call super::ue_open;string	ls_zoom
integer	li_ret
boolean	lb_go
str_params	lstr_params

/* par défaut :
	on ne montre pas l'écran de sélection des critères, 
	on peut canceler une impression lancée, 
	on peut modifier l'ordre de tri, 
	l'ordre SQL sur lequel s'appliquera les critères de sélection est obtenu à partir du DW,
	on doit confirmer l'impression,
	on démarre automatiquement la demande de critères, le retrieve et l'impression,
	le ORDER BY de la sélection remplace le ORDER BY original
*/
wf_showselection(FALSE)
wf_cancel(TRUE)
wf_trienabled(TRUE)
wf_buttonsenabled(TRUE)
wf_sqlfromdw(TRUE)
wf_confirm(TRUE)
wf_startauto(TRUE)
wf_appendorderby(FALSE)

// création du datastore
ids_1 = CREATE uo_ds

// initialiser 
this.event ue_init()

// zoom par défaut : vient du fichier .INI, défaut = 100
ls_zoom = ProfileString(gs_inifile,"zoom",ids_1.dataobject,"100")
ids_1.Object.DataWindow.Zoom = integer(ls_zoom)

// démarrage automatique ou pas
// si démarrage automatique, l'introduction des critères, le retrieve et l'impression sont lancés automatiquement
// Sinon, le programmeur doit lui même invoquer la fonction wf_start pour initialiser et lire les date,
//        puis la fonction wf_print pour les imprimer
IF wf_startauto() THEN
	wf_start()
	post close(this)
END IF


//li_ret = this.event ue_beforeretrieve()
//CHOOSE CASE li_ret
//	CASE 0
////		gu_message.uf_info("Abandon demandé")
//	CASE -1
//		gu_message.uf_error("Erreur d'initialisation")
//	CASE 1
//		// lecture des données et impression si l'utilisateur confirme son intention d'imprimer
//		IF wf_confirm() THEN 
//			IF gu_message.uf_query("OK pour démarrer l'impression de : " + ids_1.Object.DataWindow.Print.Documentname + " ?") = 1 THEN
//				lb_go = TRUE
//			ELSE
//				lb_go = FALSE
//			END IF
//		ELSE
//			lb_go = TRUE
//		END IF
//		IF lb_go THEN
//			iu_wait.uf_openwindow()
//			li_ret = this.event ue_retrieve()
//			CHOOSE CASE li_ret
//				CASE -1
//					iu_wait.uf_closewindow()
//					gu_message.uf_error("Erreur d'initialisation")
//				CASE 0
//					iu_wait.uf_closewindow()
//				CASE ELSE
//					this.event ue_print()
//					iu_wait.uf_closewindow()
//			END CHOOSE
//		ELSE
//			gu_message.uf_info("Abandon demandé")
//		END IF
//END CHOOSE
//

end event

