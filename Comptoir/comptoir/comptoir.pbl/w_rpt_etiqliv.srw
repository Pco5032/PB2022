//objectcomments Impression des étiquettes de livraison (fusion/publipostage WORD)
forward
global type w_rpt_etiqliv from w_ancestor_dataentry
end type
type dw_docfrn from uo_datawindow_singlerow within w_rpt_etiqliv
end type
type dw_eti from uo_ancestor_dwbrowse within w_rpt_etiqliv
end type
type cb_ok from uo_cb_ok within w_rpt_etiqliv
end type
type cbx_preview from uo_cbx within w_rpt_etiqliv
end type
type st_doc from uo_statictext within w_rpt_etiqliv
end type
type sle_doc from uo_sle within w_rpt_etiqliv
end type
type cb_doc from uo_cb within w_rpt_etiqliv
end type
type cb_cancel from uo_cb_cancel within w_rpt_etiqliv
end type
type st_etiq from uo_statictext within w_rpt_etiqliv
end type
type em_etiq from uo_editmask within w_rpt_etiqliv
end type
end forward

global type w_rpt_etiqliv from w_ancestor_dataentry
integer width = 3218
integer height = 1652
string title = "Etiquettes de livraison"
boolean maxbox = true
boolean resizable = true
dw_docfrn dw_docfrn
dw_eti dw_eti
cb_ok cb_ok
cbx_preview cbx_preview
st_doc st_doc
sle_doc sle_doc
cb_doc cb_doc
cb_cancel cb_cancel
st_etiq st_etiq
em_etiq em_etiq
end type
global w_rpt_etiqliv w_rpt_etiqliv

type variables
string	is_numdf, is_doc
end variables

forward prototypes
public function integer wf_init ()
public function integer wf_delete ()
end prototypes

public function integer wf_init ();dw_docfrn.object.c_nbre[1] = 0

// disabler la clé et enabler les datas
dw_docfrn.uf_enabledata()
dw_docfrn.uf_disablekeys()
dw_docfrn.SetColumn("c_nbre")
dw_docfrn.SetFocus()

return(1)
end function

public function integer wf_delete ();// supprimer des tables temporaires les données de cette session
delete t_etiqliv where sessionid=:gd_session and seq=:id_sequence using SQLCA;
IF f_check_sql(SQLCA) = -1 THEN
	rollback using SQLCA;
	populateerror(20000,"")
	gu_message.uf_unexp("Problème dans la suppression des données temporaires t_etiqliv, session " + string(gd_session), 3)
	return(-1)
ELSE
	commit USING SQLCA;
	return(-1)
END IF

end function

on w_rpt_etiqliv.create
int iCurrent
call super::create
this.dw_docfrn=create dw_docfrn
this.dw_eti=create dw_eti
this.cb_ok=create cb_ok
this.cbx_preview=create cbx_preview
this.st_doc=create st_doc
this.sle_doc=create sle_doc
this.cb_doc=create cb_doc
this.cb_cancel=create cb_cancel
this.st_etiq=create st_etiq
this.em_etiq=create em_etiq
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_docfrn
this.Control[iCurrent+2]=this.dw_eti
this.Control[iCurrent+3]=this.cb_ok
this.Control[iCurrent+4]=this.cbx_preview
this.Control[iCurrent+5]=this.st_doc
this.Control[iCurrent+6]=this.sle_doc
this.Control[iCurrent+7]=this.cb_doc
this.Control[iCurrent+8]=this.cb_cancel
this.Control[iCurrent+9]=this.st_etiq
this.Control[iCurrent+10]=this.em_etiq
end on

on w_rpt_etiqliv.destroy
call super::destroy
destroy(this.dw_docfrn)
destroy(this.dw_eti)
destroy(this.cb_ok)
destroy(this.cbx_preview)
destroy(this.st_doc)
destroy(this.sle_doc)
destroy(this.cb_doc)
destroy(this.cb_cancel)
destroy(this.st_etiq)
destroy(this.em_etiq)
end on

event ue_init_menu;call super::ue_init_menu;f_menuaction({"m_fermer", "m_abandonner"})
end event

event ue_init_win;call super::ue_init_win;this.setredraw(FALSE)

dw_eti.uf_reset()
dw_docfrn.uf_reset()
dw_docfrn.insertrow(0)

dw_docfrn.uf_disabledata()
dw_docfrn.uf_enablekeys()
dw_docfrn.Setcolumn("num_df")
dw_docfrn.setfocus()

this.setredraw(TRUE)
end event

event ue_open;call super::ue_open;string	ls_doc

// document de fusion à utiliser par défaut
ls_doc = ProfileString(gs_inifile, "etiquettes", "docliv", "")
ls_doc = ProfileString(gs_locinifile, "etiquettes", "docliv", ls_doc)
IF FileExists(gs_cenpath + "\doc\" + ls_doc) THEN
	is_doc = ls_doc
	sle_doc.text = is_doc
END IF

dw_docfrn.SetFocus()


end event

event closequery;call super::closequery;string	ls_sql

SetPointer(Hourglass!)

// supprimer des tables temporaires les données de cette session
wf_delete()

end event

event resize;call super::resize;dw_docfrn.width = newwidth - dw_eti.width
dw_docfrn.height = newheight - 412
dw_eti.height = dw_docfrn.height
dw_eti.x = dw_docfrn.x + dw_docfrn.width

cb_ok.x = newwidth / 2 - cb_ok.width - 25
cb_cancel.x = newwidth / 2 + 25

st_doc.y = dw_docfrn.y + dw_docfrn.height + 56
sle_doc.y = st_doc.y - 8
em_etiq.y = sle_doc.y
cb_doc.y = sle_doc.y
cbx_preview.y = st_doc.y
st_etiq.y = st_doc.y
cb_ok.y = sle_doc.y + 112
cb_cancel.y = cb_ok.y
end event

type ddlb_message from w_ancestor_dataentry`ddlb_message within w_rpt_etiqliv
integer y = 1440
integer width = 1719
end type

type dw_docfrn from uo_datawindow_singlerow within w_rpt_etiqliv
integer y = 16
integer width = 2011
integer height = 1136
integer taborder = 10
boolean bringtotop = true
string dataobject = "d_etiqliv"
boolean border = true
boolean livescroll = false
end type

event ue_leavekey;call super::ue_leavekey;// quand on quitte la clé, cela veut dire qu'on dispose de données actives dans la fenêtre
wf_actif(true)

// effacer les messages
ddlb_message.reset()

// lecture du DF
this.retrieve(is_numdf)

parent.event ue_init_menu()
post wf_init()
end event

event ue_checkitem;call super::ue_checkitem;string	ls_type

CHOOSE CASE as_item
	CASE "num_df"
		is_numdf = as_data
		// dernier élément de la clé, vérifier si DF existe et est du type EMIS
		select type_df into :ls_type from docfrn where num_df = :is_numdf using ESQLCA;
		IF f_check_sql(ESQLCA) <> 0 THEN
			as_message = "Document fournisseur inexistant"
			return(-1)
		ELSE
			IF ls_type <> "E" THEN
				as_message = "Ce document fournisseur n'est pas un document EMIS"
				return(-1)
			ELSE
				return(1)
			END IF
		END IF
		
	CASE "c_nbre"
		IF integer(as_data) <= 0 OR integer(as_data) > 99 THEN
			as_message = "Nombre d'étiquette(s) incorrect"
			return(-1)
		END IF
END CHOOSE
return(1)

end event

event ue_help;call super::ue_help;str_params	lstr_params

IF NOT isValid(idwo_currentItem) THEN return
IF isNull(idwo_currentItem) THEN return

CHOOSE CASE idwo_currentItem.name
	CASE "num_df"
		lstr_params.a_param[1] = "E"
		lstr_params.a_param[2] = FALSE
		openwithparm(w_l_docfrn, lstr_params)
		IF Message.DoubleParm = -1 THEN 
			return
		ELSE
			lstr_params=Message.PowerObjectParm
			this.SetText(string(lstr_params.a_param[1]))
			f_presskey("tab")
		END IF
END CHOOSE


end event

event ue_itemvalidated;call super::ue_itemvalidated;integer	li_nbre, li_i
long		ll_row

CHOOSE CASE as_name
	CASE "c_nbre"
		li_nbre = integer(as_data)
		dw_eti.uf_reset()
		wf_delete()
		FOR li_i = 1 TO li_nbre
			ll_row = dw_eti.insertRow(0)
			dw_eti.object.sessionid[ll_row] = gd_session
			dw_eti.object.seq[ll_row] = id_sequence
			dw_eti.object.num[ll_row] = li_i
			dw_eti.object.numdf[ll_row] = is_numdf
			dw_eti.object.client[ll_row] = this.object.client[1]
			dw_eti.object.catmfr[ll_row] = this.object.catmfr[1]
			dw_eti.object.espece[ll_row] = this.object.espece[1]
			dw_eti.object.regprov[ll_row] = this.object.regprov[1]
			dw_eti.object.prov[ll_row] = this.object.prov[1]
			dw_eti.object.maturite[ll_row] = string(this.object.maturite[1])
			dw_eti.object.poids[ll_row] = round(this.object.poids[1] / li_nbre, 3)
			dw_eti.object.poids_pt[ll_row] = round(this.object.docfrn_qte_avpretrt[1] / li_nbre, 3)
			dw_eti.object.numcm[ll_row] = this.object.numcm[1]
			dw_eti.object.numeti[ll_row] = string(li_i) + "/" + string(li_nbre)
			dw_eti.object.dup[ll_row] = "N"
		NEXT
		
END CHOOSE
end event

type dw_eti from uo_ancestor_dwbrowse within w_rpt_etiqliv
integer x = 2011
integer y = 16
integer width = 1152
integer height = 1136
integer taborder = 20
boolean bringtotop = true
string dataobject = "d_etiqliv_2"
boolean vscrollbar = true
boolean border = true
end type

type cb_ok from uo_cb_ok within w_rpt_etiqliv
integer x = 1061
integer y = 1312
boolean bringtotop = true
boolean default = false
end type

event clicked;call super::clicked;string	ls_sql, ls_modeI//, ls_odbc
boolean	lb_visible
integer	li_status, li_i
double	ld_etiq

IF dw_docfrn.acceptText() < 0 THEN
	dw_docfrn.setFocus()
	return
END IF

IF f_isEmptyString(is_numdf) THEN
	gu_message.uf_error("Veuillez introduire le n° de document fournisseur")
	dw_docfrn.setFocus()
	return
END IF

IF dw_eti.rowCount() = 0 THEN
	gu_message.uf_error("Veuillez introduire le nombre d'étiquette(s) à imprimer")
	dw_docfrn.setFocus()
	return
END IF

// vérification existence document de fusion
IF NOT FileExists(gs_cenpath + "\doc\" + is_doc) THEN
	gu_message.uf_error("Veuillez sélectionner le document de fusion")
	return
END IF

// enregistrer dans T_ETIQLIV
IF dw_eti.update() = -1 THEN
	rollback using SQLCA;
	gu_message.uf_error("Erreur d'enregistrement dans T_ETIQLIV")
	return
ELSE
	commit using SQLCA;
END IF

// ajouter les duplicatas (suivant le nombre d'exemplaires souhaité pour chaque étiquette)
em_etiq.GetData(ld_etiq)
FOR li_i = 2 TO ld_etiq
	insert into t_etiqliv (sessionid, seq, num, numdf, client, catmfr, espece, regprov, prov, maturite, poids, poids_pt, numcm, numeti, dup)
		select sessionid, seq, num, numdf, client, catmfr, espece, regprov, prov, maturite, poids, poids_pt, numcm, numeti, 'O' 
					from t_etiqliv where sessionid=:gd_session and seq=:id_sequence and dup = 'N' USING SQLCA;
	IF f_check_sql(SQLCA) <> 0 THEN
		rollback USING SQLCA;
		gu_message.uf_error("Erreur insert into t_etiqliv")
		return
	ELSE
		commit USING SQLCA;
	END IF
NEXT

// créer l'ordre SQL pour la fusion
ls_sql = "select numdf, client, catmfr, espece, regprov, prov, maturite, to_char(poids, '99990.000')|| ' kg' poids, " + &
			"to_char(poids_pt, '99990.000')|| ' kg' poids_pt, numcm, numeti " + &
			" from t_etiqliv where sessionid=" + string(gd_session) + " and seq=" + string(id_sequence) + &
			" order by num"

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

// supprimer les duplicatas
delete t_etiqliv where sessionid=:gd_session and seq=:id_sequence and dup = 'O' using SQLCA;
f_check_sql(SQLCA)
commit using SQLCA;
	
IF li_status = 1 THEN
	IF NOT lb_visible THEN
		gu_message.uf_info("La fusion s'est déroulée correctement")
	END IF
ELSE
	gu_message.uf_error("Il y a eu un problème lors de la fusion")
END IF


end event

type cbx_preview from uo_cbx within w_rpt_etiqliv
integer x = 1134
integer y = 1200
integer width = 786
boolean bringtotop = true
integer textsize = -9
string text = "Visualiser avant d~'imprimer"
boolean checked = true
boolean lefttext = true
end type

type st_doc from uo_statictext within w_rpt_etiqliv
integer x = 183
integer y = 1208
integer width = 293
boolean bringtotop = true
integer textsize = -9
string text = "Document "
end type

type sle_doc from uo_sle within w_rpt_etiqliv
integer x = 475
integer y = 1200
integer width = 494
integer height = 80
boolean bringtotop = true
integer textsize = -8
boolean enabled = false
end type

type cb_doc from uo_cb within w_rpt_etiqliv
integer x = 969
integer y = 1200
integer width = 73
integer height = 80
boolean bringtotop = true
integer textsize = -8
integer weight = 700
string text = "..."
end type

event clicked;call super::clicked;string	ls_pathname, ls_filename

IF GetFileOpenName("Document 'étiquettes de livraison'", ls_pathname, ls_filename, ".doc", &
		 "Fichiers Word (.DOC), *.doc;*.docx", gs_cenpath + "\doc", 18) = 1 THEN // flag 18 = 2 + 16 (explore style dlg + hides the RO checkbox)
	is_doc = ls_filename
	sle_doc.text = is_doc
	SetProfileString(gs_locinifile, "etiquettes", "docliv", is_doc)
END IF

end event

type cb_cancel from uo_cb_cancel within w_rpt_etiqliv
integer x = 1536
integer y = 1312
boolean bringtotop = true
end type

event clicked;call super::clicked;IF wf_isActif() THEN
	parent.event ue_abandonner()
ELSE
	close(parent)
END IF
end event

type st_etiq from uo_statictext within w_rpt_etiqliv
integer x = 2030
integer y = 1208
integer width = 457
boolean bringtotop = true
integer textsize = -9
string text = "Nbre d~'étiquettes"
end type

type em_etiq from uo_editmask within w_rpt_etiqliv
event ue_changed pbm_enchange
integer x = 2487
integer y = 1200
integer width = 183
integer height = 80
integer taborder = 40
boolean bringtotop = true
integer textsize = -9
string text = "2"
alignment alignment = center!
string mask = "#0"
boolean spin = true
double increment = 1
string minmax = "1~~99"
end type

