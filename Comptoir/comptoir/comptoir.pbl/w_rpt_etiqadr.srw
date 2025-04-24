forward
global type w_rpt_etiqadr from w_ancestor
end type
type cb_doc from uo_cb within w_rpt_etiqadr
end type
type sle_doc from uo_sle within w_rpt_etiqadr
end type
type st_doc from uo_statictext within w_rpt_etiqadr
end type
type cb_invert from uo_cb within w_rpt_etiqadr
end type
type em_etiq from uo_editmask within w_rpt_etiqadr
end type
type st_etiq from uo_statictext within w_rpt_etiqadr
end type
type st_series from uo_statictext within w_rpt_etiqadr
end type
type em_series from uo_editmask within w_rpt_etiqadr
end type
type cbx_preview from uo_cbx within w_rpt_etiqadr
end type
type mle_req from uo_mle within w_rpt_etiqadr
end type
type dw_1 from uo_datawindow_multiplerow within w_rpt_etiqadr
end type
type cb_cancel from uo_cb_cancel within w_rpt_etiqadr
end type
type cb_ok from uo_cb_ok within w_rpt_etiqadr
end type
end forward

global type w_rpt_etiqadr from w_ancestor
integer width = 3109
integer height = 1972
string title = "Etiquettes adresses des interlocuteurs"
cb_doc cb_doc
sle_doc sle_doc
st_doc st_doc
cb_invert cb_invert
em_etiq em_etiq
st_etiq st_etiq
st_series st_series
em_series em_series
cbx_preview cbx_preview
mle_req mle_req
dw_1 dw_1
cb_cancel cb_cancel
cb_ok cb_ok
end type
global w_rpt_etiqadr w_rpt_etiqadr

type variables
string	is_select, is_newselect, is_where, is_order, is_doc
uo_wait	iu_wait
uo_critselect	iu_critselect
integer	ii_etiq
end variables

on w_rpt_etiqadr.create
int iCurrent
call super::create
this.cb_doc=create cb_doc
this.sle_doc=create sle_doc
this.st_doc=create st_doc
this.cb_invert=create cb_invert
this.em_etiq=create em_etiq
this.st_etiq=create st_etiq
this.st_series=create st_series
this.em_series=create em_series
this.cbx_preview=create cbx_preview
this.mle_req=create mle_req
this.dw_1=create dw_1
this.cb_cancel=create cb_cancel
this.cb_ok=create cb_ok
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_doc
this.Control[iCurrent+2]=this.sle_doc
this.Control[iCurrent+3]=this.st_doc
this.Control[iCurrent+4]=this.cb_invert
this.Control[iCurrent+5]=this.em_etiq
this.Control[iCurrent+6]=this.st_etiq
this.Control[iCurrent+7]=this.st_series
this.Control[iCurrent+8]=this.em_series
this.Control[iCurrent+9]=this.cbx_preview
this.Control[iCurrent+10]=this.mle_req
this.Control[iCurrent+11]=this.dw_1
this.Control[iCurrent+12]=this.cb_cancel
this.Control[iCurrent+13]=this.cb_ok
end on

on w_rpt_etiqadr.destroy
call super::destroy
destroy(this.cb_doc)
destroy(this.sle_doc)
destroy(this.st_doc)
destroy(this.cb_invert)
destroy(this.em_etiq)
destroy(this.st_etiq)
destroy(this.st_series)
destroy(this.em_series)
destroy(this.cbx_preview)
destroy(this.mle_req)
destroy(this.dw_1)
destroy(this.cb_cancel)
destroy(this.cb_ok)
end on

event ue_postopen;call super::ue_postopen;// initialiser les paramètres d'input pour la fenêtre de sélection
// (on utilise la même fenêtre de sélection que pour les reports)
str_params	lstr_inputparams, lstr_selectionparams
string		ls_modele, ls_prog, ls_sql
long			ll_rows

ls_modele = "ETIQADR"
ls_prog = upper(this.classname())
is_select = "select * from interlocuteur"

// définir les critères par défaut
iu_critselect.uf_ResetDefaults(ls_modele)
iu_critselect.uf_setdefault(ls_prog, ls_modele, 1, "interlocuteur.type", "=")

iu_critselect.uf_setdefaulttri(ls_prog, ls_modele, 1, "interlocuteur.interlocuteur")

// définir les paramètres pour utiliser l'écran de sélection
lstr_inputparams.a_param[1] = ls_prog
lstr_inputparams.a_param[2] = ls_modele
lstr_inputparams.a_param[3] = is_select
lstr_inputparams.a_param[4] = TRUE
lstr_inputparams.a_param[5] = TRUE
lstr_inputparams.a_param[6] = id_sequence
lstr_inputparams.a_param[7] = TRUE
lstr_inputparams.a_param[8] = ""
lstr_inputparams.a_param[9] = ""

// choix des critères
OpenWithparm(w_selection, lstr_inputparams)
IF Message.DoubleParm = -1 THEN
	post close(this)
	return
ELSE
	lstr_selectionparams = Message.PowerObjectParm
	is_select = string(lstr_selectionparams.a_param[1])
	mle_req.text = trim(string(lstr_selectionparams.a_param[2]))
	is_where = string(lstr_selectionparams.a_param[3])
	is_order = string(lstr_selectionparams.a_param[4])
END IF

// insérer résultat de la sélection dans table temporaire
ls_sql = "insert into t_etiqadr select " + string(gd_session)  + "," + string(id_sequence) + &
			",1, type, locu, interlocuteur, intitule, attention, rue, cpost," + &
			"localite, decode(pays,'BE','',v_pays.trad), '1'" + &
			" from interlocuteur, v_pays where interlocuteur.pays=v_pays.code"
			
// Ajouter le where généré par la sélection
ls_sql = f_modifySql(ls_sql, is_where, "", "")

iu_wait.uf_OpenWindow()
iu_wait.uf_AddInfo("Lecture des interlocuteurs sélectionnés")
execute immediate :ls_sql USING ESQLCA;
IF f_check_sql(ESQLCA) = -1 THEN
	rollback using ESQLCA;
	iu_wait.uf_CloseWindow()
	populateerror(20000, ls_sql)
	gu_message.uf_unexp("Erreur insert t_etiqadr")
	post close(this)
	return
ELSE
	commit USING ESQLCA;
END IF

// appliquer les critères et afficher le résultat de la sélection
dw_1.retrieve(gd_session, id_sequence)
iu_wait.uf_CloseWindow()
dw_1.SetFocus()

IF dw_1.RowCount() = 0 THEN
	gu_message.uf_error("Aucun interlocuteur ne correspond à votre requête.")
	post close(this)
	return
END IF

end event

event ue_closebyxaccepted;call super::ue_closebyxaccepted;cb_cancel.event clicked()
end event

event resize;call super::resize;dw_1.width = newwidth
dw_1.height = newheight - 400
mle_req.width = newwidth
cb_ok.x = newwidth/2 - cb_ok.width - 200
cb_ok.y = newheight - 120
cb_cancel.x = newwidth/2 + 200
cb_cancel.y = cb_ok.y
cb_invert.x = newwidth - 450
cb_invert.y = cb_ok.y
cbx_preview.y = newheight - 230
st_series.y = cbx_preview.y
st_etiq.y = cbx_preview.y
em_series.y = cbx_preview.y
em_etiq.y = cbx_preview.y

st_doc.y = cbx_preview.y
sle_doc.y = cbx_preview.y
cb_doc.y = cbx_preview.y
end event

event closequery;call super::closequery;string	ls_sql

SetPointer(Hourglass!)

// supprimer des tables temporaires les données de cette session
ls_sql = "delete from t_etiqadr where sessionid=" + string(gd_session) + " and seq=" + string(id_sequence)

execute immediate :ls_sql USING ESQLCA;
IF f_check_sql(ESQLCA) = -1 THEN
	rollback using ESQLCA;
	populateerror(20000,"")
	gu_message.uf_unexp("Problème dans la suppression des données temporaires t_etiqadr, session " + string(gd_session), 3)
ELSE
	commit USING ESQLCA;
END IF

end event

event ue_init_menu;call super::ue_init_menu;f_menuaction({"m_fermer"})
end event

event ue_close;call super::ue_close;DESTROY iu_wait
end event

event ue_open;call super::ue_open;string	ls_doc

// instancier les objets nécessaires
iu_wait = CREATE uo_wait
iu_critselect = CREATE uo_critselect

dw_1.uf_sort(TRUE)

em_etiq.text = "1"
em_series.text = "1"

ii_etiq = 1

// document de fusion à utiliser par défaut
ls_doc = ProfileString(gs_inifile, "etiquettes", "docadr", "")
ls_doc = ProfileString(gs_locinifile, "etiquettes", "docadr", ls_doc)
IF FileExists(gs_cenpath + "\doc\" + ls_doc) THEN
	is_doc = ls_doc
	sle_doc.text = is_doc
END IF
end event

type cb_doc from uo_cb within w_rpt_etiqadr
integer x = 2158
integer y = 1616
integer width = 73
integer height = 80
integer taborder = 50
integer textsize = -8
integer weight = 700
string text = "..."
end type

event clicked;call super::clicked;string	ls_pathname, ls_filename

IF GetFileOpenName("Document 'étiquettes adresses'", ls_pathname, ls_filename, ".doc", &
		 "Fichiers Word (.DOC), *.doc;*.docx", gs_cenpath + "\doc", 18) = 1 THEN // flag 18 = 2 + 16 (explore style dlg + hides the RO checkbox)
	is_doc = ls_filename
	sle_doc.text = is_doc
	SetProfileString(gs_locinifile, "etiquettes", "docadr", is_doc)
END IF

end event

type sle_doc from uo_sle within w_rpt_etiqadr
integer x = 1664
integer y = 1616
integer width = 494
integer height = 80
integer taborder = 40
integer textsize = -8
boolean enabled = false
end type

type st_doc from uo_statictext within w_rpt_etiqadr
integer x = 1371
integer y = 1616
integer width = 293
string text = "Document "
end type

type cb_invert from uo_cb within w_rpt_etiqadr
integer x = 2615
integer y = 1728
integer width = 439
integer taborder = 50
integer textsize = -8
string text = "Inverser selection"
end type

event clicked;call super::clicked;// inverser sélection de tout

long	ll_nbrows, ll_row

dw_1.SetRedraw(FALSE)
ll_nbrows = dw_1.RowCount()
FOR ll_row = 1 TO ll_Nbrows
	IF dw_1.object.selected[ll_row] = 0 THEN
		dw_1.uf_setDefaultValue(ll_row, "selected", 1)
	ELSE
		dw_1.uf_setDefaultValue(ll_row, "selected", 0)
	END IF
NEXT
dw_1.SetRedraw(TRUE)
end event

type em_etiq from uo_editmask within w_rpt_etiqadr
event ue_changed pbm_enchange
integer x = 1134
integer y = 1616
integer width = 183
integer height = 80
integer taborder = 30
integer textsize = -9
alignment alignment = center!
string mask = "#0"
boolean spin = true
double increment = 1
string minmax = "1~~99"
end type

event ue_changed;double	ld_etiq
long		ll_nbrows, ll_row

em_etiq.GetData(ld_etiq)
IF ii_etiq <> ld_etiq THEN
	SetPointer(Hourglass!)
	dw_1.setredraw(FALSE)
	ll_nbrows = dw_1.RowCount()
	FOR ll_row = 1 TO ll_nbrows
		IF dw_1.object.Selected[ll_row] = 1 THEN
			dw_1.object.nbre[ll_row] = ld_etiq
		ELSE
			dw_1.object.nbre[ll_row] = 0
		END IF
	NEXT
	ii_etiq = ld_etiq
	dw_1.setredraw(TRUE)
END IF
end event

type st_etiq from uo_statictext within w_rpt_etiqadr
integer x = 677
integer y = 1616
integer width = 457
string text = "Nbre d~'étiquettes"
end type

type st_series from uo_statictext within w_rpt_etiqadr
integer x = 37
integer y = 1616
string text = "Nbre de séries"
end type

type em_series from uo_editmask within w_rpt_etiqadr
integer x = 439
integer y = 1616
integer width = 183
integer height = 80
integer taborder = 30
integer textsize = -9
alignment alignment = center!
string mask = "#0"
boolean spin = true
double increment = 1
string minmax = "1~~99"
end type

type cbx_preview from uo_cbx within w_rpt_etiqadr
integer x = 2267
integer y = 1616
integer width = 786
string text = "Visualiser avant d~'imprimer"
boolean checked = true
boolean lefttext = true
end type

type mle_req from uo_mle within w_rpt_etiqadr
integer width = 3054
integer height = 144
integer taborder = 10
integer textsize = -9
boolean vscrollbar = true
boolean autovscroll = true
boolean displayonly = true
boolean hideselection = false
end type

type dw_1 from uo_datawindow_multiplerow within w_rpt_etiqadr
integer y = 144
integer width = 3054
integer height = 1456
integer taborder = 20
string dataobject = "d_etiqadr"
boolean hscrollbar = true
boolean vscrollbar = true
boolean border = true
end type

event ue_itemvalidated;call super::ue_itemvalidated;CHOOSE CASE as_name
	CASE "selected"
		IF integer(as_data) = 0 THEN
			dw_1.object.nbre[al_row] = 0
		ELSE
			dw_1.object.nbre[al_row] = ii_etiq
		END IF
END CHOOSE
end event

type cb_cancel from uo_cb_cancel within w_rpt_etiqadr
integer x = 1499
integer y = 1728
integer taborder = 40
end type

event clicked;call super::clicked;close(parent)
end event

type cb_ok from uo_cb_ok within w_rpt_etiqadr
integer x = 878
integer y = 1728
integer taborder = 30
end type

event clicked;call super::clicked;string	ls_sql, ls_modeI, ls_order, ls_locu//, ls_odbc
long		ll_nbrows, ll_row
boolean	lb_visible
integer	li_status, li_nbetiq, li_nb
double	ld_series, ld_etiq

IF dw_1.object.c_selected[1] = 0 THEN
	gu_message.uf_error("Veuillez sélectionner au moins un interlocuteur")
	return
END IF

em_series.GetData(ld_series)
em_etiq.GetData(ld_etiq)

IF ld_series = 0 THEN
	gu_message.uf_error("Il faut au moins une série de l'ensemble des adresses sélectionnées")
	em_series.Setfocus()
	return
END IF

IF ld_etiq = 0 THEN
	gu_message.uf_error("Il faut au moins un exemplaire de chaque adresse sélectionnée")
	em_etiq.Setfocus()
	return
END IF

// vérification existence document de fusion
IF NOT FileExists(gs_cenpath + "\doc\" + is_doc) THEN
	gu_message.uf_error("Veuillez sélectionner le document de fusion")
	return
END IF

// enregistrer les éventuelles modifications apportées à la sélection
IF dw_1.event ue_update() = -1 THEN
	gu_message.uf_error("Erreur d'enregistrement de la sélection")
	return
END IF

// ajouter au fichier temporaire le nombre d'exemplaires d'étiquettes requis en fct du nbre d'étiq.
delete t_etiqadr where sessionid=:gd_session and seq=:id_sequence and selected=2 USING ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	rollback USING ESQLCA;
	gu_message.uf_error("Erreur delete t_etiqadr where selected=2")
	return
END IF
ll_nbrows = dw_1.RowCount()
FOR ll_row = 1 TO ll_nbrows
	IF dw_1.object.selected[ll_row] = 1 THEN
		li_nbetiq = dw_1.object.nbre[ll_row]
		FOR li_nb = 2 TO li_nbetiq
			ls_locu = dw_1.object.locu[ll_row]
			insert into t_etiqadr
				select sessionid, seq, serie, type, locu, interlocuteur, intitule, attention, rue, cpost, localite, pays, 2 
					from t_etiqadr where sessionid=:gd_session and seq=:id_sequence and 
						  locu=:ls_locu and selected=1 USING ESQLCA;
			IF f_check_sql(ESQLCA) <> 0 THEN
				rollback USING ESQLCA;
				gu_message.uf_error("Erreur insert into t_etiqadr (nbetiq)")
				return
			END IF
		NEXT
	END IF
NEXT

// ajouter au fichier temporaire le nombre d'exemplaires d'étiquettes requis en fct du nbre de séries
FOR li_nb = 2 TO ld_series
	insert into t_etiqadr
		select sessionid, seq, :li_nb, type, locu, interlocuteur, intitule, attention, rue, cpost, localite, pays, 2 
			from t_etiqadr where sessionid=:gd_session and seq=:id_sequence
				  and serie=1 and selected > 0 USING ESQLCA;
	IF f_check_sql(ESQLCA) <> 0 THEN
		rollback USING ESQLCA;
		gu_message.uf_error("Erreur insert into t_etiqadr (nbseries)")
		return
	END IF
NEXT
commit using ESQLCA;

// créer l'ordre SQL pour la fusion (en ajoutant l'ordre de tri choisi dans la sélection)
ls_sql = "select interlocuteur, intitule, attention, rue, cpost, localite, pays from t_etiqadr where sessionid=" + &
			string(gd_session) + " and seq=" + string(id_sequence) + " and selected<>0 order by serie " + ls_order

// ajouter le ORDER BY généré par la sélection
ls_order = gu_stringservices.uf_replaceall(is_order, "INTERLOCUTEUR.", "")
ls_sql = f_modifySql2(ls_sql, "", ls_order, FALSE, "")

// connexion ODBC : entrée ODBC doit porter le même nom que l'alias de connexion à la DB
// ls_ODBC = "DSN=" + SQLCA.database + ";UID=" + SQLCA.userid + ";PWD=" + SQLCA.dbpass + ";DBQ=" + SQLCA.database + ";"

IF cbx_preview.checked THEN
	ls_modeI = "P"
	lb_visible = TRUE
ELSE
	ls_modeI = "I"
	lb_visible = FALSE
END IF
SetPointer(hourglass!)
li_status = f_fusion_word(gs_cenpath + "\doc\" + is_doc, ls_sql, "", ls_modeI,"",lb_visible)

// effacer les adresses dupliquées
delete t_etiqadr where sessionid=:gd_session and seq=:id_sequence and selected=2 USING ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	rollback USING ESQLCA;
	gu_message.uf_error("Erreur delete t_etiqadr where selected=2")
ELSE
	commit using ESQLCA;
END IF

IF li_status = 1 THEN
	IF NOT lb_visible THEN
		gu_message.uf_info("La fusion s'est déroulée correctement")
	END IF
ELSE
	gu_message.uf_error("Il y a eu un problème lors de la fusion")
END IF


end event

