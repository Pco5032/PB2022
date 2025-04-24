//objectcomments Impression des étiquettes pour les tests de germination
forward
global type w_rpt_etiqgerm from w_ancestor
end type
type cb_doc from uo_cb within w_rpt_etiqgerm
end type
type sle_doc from uo_sle within w_rpt_etiqgerm
end type
type st_doc from uo_statictext within w_rpt_etiqgerm
end type
type cbx_preview from uo_cbx within w_rpt_etiqgerm
end type
type dw_1 from uo_datawindow_multiplerow within w_rpt_etiqgerm
end type
type cb_cancel from uo_cb_cancel within w_rpt_etiqgerm
end type
type cb_ok from uo_cb_ok within w_rpt_etiqgerm
end type
end forward

global type w_rpt_etiqgerm from w_ancestor
integer width = 3776
integer height = 2080
string title = "Etiquettes tests de germination"
cb_doc cb_doc
sle_doc sle_doc
st_doc st_doc
cbx_preview cbx_preview
dw_1 dw_1
cb_cancel cb_cancel
cb_ok cb_ok
end type
global w_rpt_etiqgerm w_rpt_etiqgerm

type variables
string	is_doc
end variables

on w_rpt_etiqgerm.create
int iCurrent
call super::create
this.cb_doc=create cb_doc
this.sle_doc=create sle_doc
this.st_doc=create st_doc
this.cbx_preview=create cbx_preview
this.dw_1=create dw_1
this.cb_cancel=create cb_cancel
this.cb_ok=create cb_ok
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_doc
this.Control[iCurrent+2]=this.sle_doc
this.Control[iCurrent+3]=this.st_doc
this.Control[iCurrent+4]=this.cbx_preview
this.Control[iCurrent+5]=this.dw_1
this.Control[iCurrent+6]=this.cb_cancel
this.Control[iCurrent+7]=this.cb_ok
end on

on w_rpt_etiqgerm.destroy
call super::destroy
destroy(this.cb_doc)
destroy(this.sle_doc)
destroy(this.st_doc)
destroy(this.cbx_preview)
destroy(this.dw_1)
destroy(this.cb_cancel)
destroy(this.cb_ok)
end on

event ue_closebyxaccepted;call super::ue_closebyxaccepted;cb_cancel.event clicked()
end event

event resize;call super::resize;dw_1.width = newwidth
dw_1.height = newheight - 270
cb_ok.x = newwidth/2 - cb_ok.width - 100
cb_ok.y = newheight - 130
cb_cancel.x = newwidth/2 + 100
cb_cancel.y = cb_ok.y
cbx_preview.y = newheight - 230

st_doc.y = cbx_preview.y
sle_doc.y = cbx_preview.y
cb_doc.y = cbx_preview.y
end event

event ue_init_menu;call super::ue_init_menu;f_menuaction({"m_fermer"})
end event

event ue_open;call super::ue_open;string	ls_doc

dw_1.uf_sort(TRUE)

// document de fusion à utiliser par défaut
ls_doc = ProfileString(gs_inifile, "etiquettes", "docgerm", "")
ls_doc = ProfileString(gs_locinifile, "etiquettes", "docgerm", ls_doc)
IF FileExists(gs_cenpath + "\doc\" + ls_doc) THEN
	is_doc = ls_doc
	sle_doc.text = is_doc
END IF
end event

event ue_postopen;call super::ue_postopen;dw_1.retrieve()
end event

type cb_doc from uo_cb within w_rpt_etiqgerm
integer x = 805
integer y = 1728
integer width = 73
integer height = 80
integer textsize = -8
integer weight = 700
string text = "..."
end type

event clicked;call super::clicked;string	ls_pathname, ls_filename

IF GetFileOpenName("Document 'étiquettes test de germination'", ls_pathname, ls_filename, ".doc", &
		 "Fichiers Word (.DOC), *.doc; *;docx", gs_cenpath + "\doc", 18) = 1 THEN // flag 18 = 2 + 16 (explore style dlg + hides the RO checkbox)
	is_doc = ls_filename
	sle_doc.text = is_doc
	SetProfileString(gs_locinifile, "etiquettes", "docgerm", is_doc)
END IF

end event

type sle_doc from uo_sle within w_rpt_etiqgerm
integer x = 311
integer y = 1728
integer width = 494
integer height = 80
integer textsize = -8
boolean enabled = false
end type

type st_doc from uo_statictext within w_rpt_etiqgerm
integer x = 18
integer y = 1728
integer width = 293
string text = "Document "
end type

type cbx_preview from uo_cbx within w_rpt_etiqgerm
integer x = 914
integer y = 1728
integer width = 786
string text = "Visualiser avant d~'imprimer"
boolean checked = true
boolean lefttext = true
end type

type dw_1 from uo_datawindow_multiplerow within w_rpt_etiqgerm
integer width = 3730
integer height = 1696
integer taborder = 10
string dataobject = "d_sel_etiqgerm"
boolean hscrollbar = true
boolean vscrollbar = true
boolean border = true
end type

event ue_checkitem;call super::ue_checkitem;CHOOSE CASE as_item
	case "c_nbre"
		IF this.object.c_imprimer[al_row] = 1 AND integer(as_data) = 0 THEN
			as_message = "Veuillez introduire le nombre d'étiquettes à imprimer (nombre de bacs)"
			return(-1)
		END IF
END CHOOSE

return(1)
end event

event ue_checkall;call super::ue_checkall;integer	li_ancestorReturnValue

li_ancestorReturnValue = AncestorReturnValue

IF li_ancestorReturnValue = 1 THEN
	IF this.object.c_nbretot[1] = 0 THEN
		gu_message.uf_error("Aucune étiquette à imprimer !")
		return(-1)
	END IF
ELSE
	return(li_ancestorReturnValue)
END IF

end event

type cb_cancel from uo_cb_cancel within w_rpt_etiqgerm
integer x = 1883
integer y = 1840
end type

event clicked;call super::clicked;close(parent)
end event

type cb_ok from uo_cb_ok within w_rpt_etiqgerm
integer x = 1262
integer y = 1840
boolean default = false
end type

event clicked;call super::clicked;string	ls_filename, ls_reflot, ls_typetest, ls_provenance, ls_codesp, ls_nomsp, ls_sslot, &
			ls_qte, ls_rep, ls_rem, ls_modeI, ls_sql
string	ls_repetition[12] = {"I","II","III","IV","V","VI","VII","VIII","IX","X","XI","XII"}		
long		ll_nbrows, ll_row
boolean	lb_visible
integer	li_nbetiq, li_nb, li_numtest, li_anmaturite, li_status
date		ld_dtdebut, ld_dtldorm

// vérification données sélectionnées
IF dw_1.event ue_checkall() < 0 THEN
	dw_1.setFocus()
	return
END IF

// vérification existence document de fusion
ls_filename = gs_cenpath + "\doc\" + is_doc
IF f_isEmptyString(is_doc) OR NOT FileExists(ls_filename) THEN
	gu_message.uf_error("Veuillez sélectionner le document de fusion")
	return
END IF

// insérer le contenu des étiquettes dans T_ETIQGERM
ll_nbrows = dw_1.RowCount()
FOR ll_row = 1 TO ll_nbrows
	IF dw_1.object.c_imprimer[ll_row] = 1 THEN
		li_nbetiq = dw_1.object.c_nbre[ll_row]
		FOR li_nb = 1 TO li_nbetiq
			ls_reflot = dw_1.object.ref_lot[ll_row]
			li_numtest = dw_1.object.num_test[ll_row]
			ls_typetest = dw_1.object.type_test[ll_row]
			IF ls_typetest = "P" THEN
				ls_rep = ls_repetition[li_nb]	// test en boîte de Pétri : imprime n° de répétition
			ELSE
				ls_rep = string(li_nb)	// test sur substrat : imprime n° de bac
			END IF
			ld_dtdebut = gu_datetime.uf_dfromdt(dw_1.object.dt_debut[ll_row])
			ls_provenance = dw_1.object.provenance_nom[ll_row]
			ls_codesp = dw_1.object.code_sp[ll_row]
			ls_nomsp = dw_1.object.espece_nom_fr[ll_row]
			li_anmaturite = dw_1.object.an_maturite[ll_row]
			ld_dtldorm = gu_datetime.uf_dfromdt(dw_1.object.dt_ldorm[ll_row])
			ls_sslot = dw_1.object.sslot[ll_row]
			ls_rem = left(dw_1.object.rem[ll_row], 40)
			IF ls_typetest = "P" THEN
				// test en boîte de Pétri : qté = nombre de graines pour la répétition en cours
				ls_qte = string(dw_1.getitemnumber(ll_row, "qte_rep" + string(li_nb)))
			ELSE
				// test sur substrat : qté = a X b, où a=nbre de logettes et b=nbre de graines par logettes
				ls_qte = string(dw_1.getitemnumber(ll_row, "nb_rep")) + 'x' + &
							string(dw_1.getitemnumber(ll_row, "qte_rep"))
			END IF
			insert into t_etiqgerm
				(sessionid, seq, ref_lot, num_test, num_eti, type_test, repetition, dt_debut, 
				 provenance, code_sp, nom_sp, an_maturite, dt_ldorm, sslot, qte_rep, rem)
				values(:gd_session, :id_sequence, :ls_reflot, :li_numtest, :li_nb, :ls_typetest, 
						 :ls_rep, :ld_dtdebut, :ls_provenance, :ls_codesp, :ls_nomsp, :li_anmaturite, 
						 :ld_dtldorm, :ls_sslot, :ls_qte, :ls_rem)
				USING ESQLCA;
			IF f_check_sql(ESQLCA) <> 0 THEN
				rollback USING ESQLCA;
				gu_message.uf_error("Erreur insert into t_etiqgerm")
				return
			END IF
		NEXT
	END IF
NEXT
commit using ESQLCA;

// créer l'ordre SQL pour la fusion (en ajoutant l'ordre de tri choisi dans la sélection)
ls_sql = "select ref_lot||'-'||num_test||'-'||num_eti barcode, num_test, num_eti, type_test, " + &
			"repetition, dt_debut, provenance, code_sp, nom_sp, an_maturite, dt_ldorm, sslot, " + &
			"qte_rep, rem from t_etiqgerm " + &
			"where sessionid=" + string(gd_session) + " and seq=" + string(id_sequence) + &
			" order by ref_lot, num_test, num_eti"

IF cbx_preview.checked THEN
	ls_modeI = "P"
	lb_visible = TRUE
ELSE
	ls_modeI = "I"
	lb_visible = FALSE
END IF
SetPointer(hourglass!)
li_status = f_fusion_word(gs_cenpath + "\doc\" + is_doc, ls_sql, "", ls_modeI,"",lb_visible)

// supprimer des tables temporaires les données de cette session
delete from t_etiqgerm where sessionid=:gd_session and seq=:id_sequence using ESQLCA;
execute immediate :ls_sql USING ESQLCA;
IF f_check_sql(ESQLCA) = -1 THEN
	rollback using ESQLCA;
	populateerror(20000,"")
	gu_message.uf_unexp("Problème dans la suppression des données temporaires t_etiqgerm, session " + string(gd_session), 3)
	post close(parent)
ELSE
	commit USING ESQLCA;
END IF

IF li_status = 1 THEN
	IF NOT lb_visible THEN
		gu_message.uf_info("La fusion s'est déroulée correctement")
	END IF
ELSE
	gu_message.uf_error("Il y a eu un problème lors de la fusion")
END IF

end event

