//objectcomments Impression d'étiquettes d'identification des lots
forward
global type w_rpt_etiqlot from w_ancestor
end type
type st_nbre from uo_statictext within w_rpt_etiqlot
end type
type em_nbre from uo_editmask within w_rpt_etiqlot
end type
type cbx_preview from uo_cbx within w_rpt_etiqlot
end type
type st_doc from uo_statictext within w_rpt_etiqlot
end type
type sle_doc from uo_sle within w_rpt_etiqlot
end type
type cb_doc from uo_cb within w_rpt_etiqlot
end type
type dw_typegraine from uo_datawindow_singlerow within w_rpt_etiqlot
end type
type sle_nomsp from uo_sle within w_rpt_etiqlot
end type
type sle_regmb from uo_sle within w_rpt_etiqlot
end type
type st_3 from uo_statictext within w_rpt_etiqlot
end type
type sle_nomprov from uo_sle within w_rpt_etiqlot
end type
type st_2 from uo_statictext within w_rpt_etiqlot
end type
type st_1 from uo_statictext within w_rpt_etiqlot
end type
type cb_ok from uo_cb_ok within w_rpt_etiqlot
end type
type cb_cancel from uo_cb_cancel within w_rpt_etiqlot
end type
type dw_1 from uo_ancestor_dwbrowse within w_rpt_etiqlot
end type
type gb_1 from uo_groupbox within w_rpt_etiqlot
end type
end forward

global type w_rpt_etiqlot from w_ancestor
integer height = 2104
string title = "Etiquettes d~'identification des lots"
st_nbre st_nbre
em_nbre em_nbre
cbx_preview cbx_preview
st_doc st_doc
sle_doc sle_doc
cb_doc cb_doc
dw_typegraine dw_typegraine
sle_nomsp sle_nomsp
sle_regmb sle_regmb
st_3 st_3
sle_nomprov sle_nomprov
st_2 st_2
st_1 st_1
cb_ok cb_ok
cb_cancel cb_cancel
dw_1 dw_1
gb_1 gb_1
end type
global w_rpt_etiqlot w_rpt_etiqlot

type variables
string	is_doc

end variables

forward prototypes
public subroutine wf_filtre ()
end prototypes

public subroutine wf_filtre ();// afficher les lots correspondant au filtre demandé
string	ls_filtre, ls_type

// filtre sur le type de graine
ls_type = dw_typegraine.object.s_type[1]
IF NOT f_IsEmptyString(ls_type) THEN
	ls_filtre = "type_graine = '" + upper(ls_type) + "'"
END IF

// filtre sur le nom de l'espèce
IF NOT f_IsEmptyString(sle_nomsp.text) THEN
	IF f_IsEmptyString(ls_filtre) THEN
		ls_filtre = "match(upper(espece_nom_fr), '" + upper(sle_nomsp.text) + "')"
	ELSE
		ls_filtre = ls_filtre + " and match(upper(espece_nom_fr), '" + upper(sle_nomsp.text) + "')"
	END IF
END IF

// filtre sur le nom de la provenance
IF NOT f_IsEmptyString(sle_nomprov.text) THEN
	IF f_IsEmptyString(ls_filtre) THEN
		ls_filtre = "match(upper(provenance_nom), '" + upper(sle_nomprov.text) + "')"
	ELSE
		ls_filtre = ls_filtre + " and match(upper(provenance_nom), '" + upper(sle_nomprov.text) + "')"
	END IF
END IF

// filtre sur la référence registre MB
IF NOT f_IsEmptyString(sle_regmb.text) THEN
	IF f_IsEmptyString(ls_filtre) THEN
		ls_filtre = "match(upper(provenance_code_prov), '" + upper(sle_regmb.text) + "')"
	ELSE
		ls_filtre = ls_filtre + " and match(upper(provenance_code_prov), '" + upper(sle_regmb.text) + "')"
	END IF
END IF

dw_1.SetFilter(ls_filtre)
dw_1.Filter()
dw_1.Sort()
end subroutine

on w_rpt_etiqlot.create
int iCurrent
call super::create
this.st_nbre=create st_nbre
this.em_nbre=create em_nbre
this.cbx_preview=create cbx_preview
this.st_doc=create st_doc
this.sle_doc=create sle_doc
this.cb_doc=create cb_doc
this.dw_typegraine=create dw_typegraine
this.sle_nomsp=create sle_nomsp
this.sle_regmb=create sle_regmb
this.st_3=create st_3
this.sle_nomprov=create sle_nomprov
this.st_2=create st_2
this.st_1=create st_1
this.cb_ok=create cb_ok
this.cb_cancel=create cb_cancel
this.dw_1=create dw_1
this.gb_1=create gb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.st_nbre
this.Control[iCurrent+2]=this.em_nbre
this.Control[iCurrent+3]=this.cbx_preview
this.Control[iCurrent+4]=this.st_doc
this.Control[iCurrent+5]=this.sle_doc
this.Control[iCurrent+6]=this.cb_doc
this.Control[iCurrent+7]=this.dw_typegraine
this.Control[iCurrent+8]=this.sle_nomsp
this.Control[iCurrent+9]=this.sle_regmb
this.Control[iCurrent+10]=this.st_3
this.Control[iCurrent+11]=this.sle_nomprov
this.Control[iCurrent+12]=this.st_2
this.Control[iCurrent+13]=this.st_1
this.Control[iCurrent+14]=this.cb_ok
this.Control[iCurrent+15]=this.cb_cancel
this.Control[iCurrent+16]=this.dw_1
this.Control[iCurrent+17]=this.gb_1
end on

on w_rpt_etiqlot.destroy
call super::destroy
destroy(this.st_nbre)
destroy(this.em_nbre)
destroy(this.cbx_preview)
destroy(this.st_doc)
destroy(this.sle_doc)
destroy(this.cb_doc)
destroy(this.dw_typegraine)
destroy(this.sle_nomsp)
destroy(this.sle_regmb)
destroy(this.st_3)
destroy(this.sle_nomprov)
destroy(this.st_2)
destroy(this.st_1)
destroy(this.cb_ok)
destroy(this.cb_cancel)
destroy(this.dw_1)
destroy(this.gb_1)
end on

event resize;call super::resize;this.setredraw(FALSE)
dw_1.width = newwidth
dw_1.height = newheight - 450
cb_ok.x = newwidth/2 - cb_ok.width - 100
cb_ok.y = newheight - 130
cb_cancel.x = newwidth/2 + 100
cb_cancel.y = cb_ok.y
cbx_preview.y = newheight - 230

st_doc.y = cbx_preview.y
sle_doc.y = cbx_preview.y
cb_doc.y = cbx_preview.y
st_nbre.y = cbx_preview.y
em_nbre.y = cbx_preview.y

em_nbre.x = newwidth - em_nbre.width - 12
st_nbre.x = em_nbre.x - st_nbre.width
this.setredraw(TRUE)
end event

event ue_closebyxaccepted;call super::ue_closebyxaccepted;cb_cancel.event clicked()
end event

event ue_open;call super::ue_open;string	ls_doc
long		ll_row
datawindowchild	ldwc_dropdown

dw_1.uf_sort(TRUE)

// document de fusion à utiliser par défaut
ls_doc = ProfileString(gs_inifile, "etiquettes", "docidlot", "")
ls_doc = ProfileString(gs_locinifile, "etiquettes", "docidlot", ls_doc)
IF FileExists(gs_cenpath + "\doc\" + ls_doc) THEN
	is_doc = ls_doc
	sle_doc.text = is_doc
END IF

// types de graine
dw_typegraine.insertRow(0)

// référence vers le DDDW de choix du type de graine
dw_typegraine.GetChild("s_type", ldwc_dropdown)
ldwc_dropdown.settransobject(sqlca)

// ajouter le type 'Tous les types' à la liste des types existant
ll_row = ldwc_dropdown.insertrow(0)
ldwc_dropdown.setitem(ll_row, "code", "")
ldwc_dropdown.setitem(ll_row, "trad", "Tous les types")
ldwc_dropdown.setitem(ll_row, "ordre", 0)
ldwc_dropdown.sort()
// sélectionner par défaut 'tous les types'
dw_typegraine.uf_setdefaultvalue(1, "s_type", "")

em_nbre.text = "1"
end event

event ue_postopen;call super::ue_postopen;dw_1.retrieve()

end event

event ue_init_menu;call super::ue_init_menu;f_menuaction({"m_fermer"})
end event

type st_nbre from uo_statictext within w_rpt_etiqlot
integer x = 2725
integer y = 1760
integer width = 517
string text = "Nbre d~'exemplaires"
end type

type em_nbre from uo_editmask within w_rpt_etiqlot
integer x = 3255
integer y = 1744
integer width = 219
integer height = 80
integer textsize = -9
alignment alignment = right!
string mask = "#0"
boolean spin = true
double increment = 1
string minmax = "1~~10"
end type

type cbx_preview from uo_cbx within w_rpt_etiqlot
integer x = 896
integer y = 1744
integer width = 786
string text = "Visualiser avant d~'imprimer"
boolean checked = true
boolean lefttext = true
end type

type st_doc from uo_statictext within w_rpt_etiqlot
integer y = 1744
integer width = 293
string text = "Document "
end type

type sle_doc from uo_sle within w_rpt_etiqlot
integer x = 293
integer y = 1744
integer width = 494
integer height = 80
integer textsize = -8
boolean enabled = false
end type

type cb_doc from uo_cb within w_rpt_etiqlot
integer x = 786
integer y = 1744
integer width = 73
integer height = 80
integer textsize = -8
integer weight = 700
string text = "..."
end type

event clicked;call super::clicked;string	ls_pathname, ls_filename

IF GetFileOpenName("Document 'étiquettes test de germination'", ls_pathname, ls_filename, ".doc", &
		 "Fichiers Word (.DOC), *.doc; *.docx", gs_cenpath + "\doc", 18) = 1 THEN // flag 18 = 2 + 16 (explore style dlg + hides the RO checkbox)
	is_doc = ls_filename
	sle_doc.text = is_doc
	SetProfileString(gs_locinifile, "etiquettes", "docadr", is_doc)
END IF

end event

type dw_typegraine from uo_datawindow_singlerow within w_rpt_etiqlot
integer x = 165
integer y = 64
integer width = 1042
integer height = 96
integer taborder = 0
string dataobject = "d_choix_typegraine"
end type

event ue_postitemvalidated;call super::ue_postitemvalidated;wf_filtre()
end event

type sle_nomsp from uo_sle within w_rpt_etiqlot
event we_changed pbm_enchange
integer x = 1463
integer y = 64
integer height = 80
boolean bringtotop = true
integer textsize = -9
end type

event we_changed;IF this <> GetFocus() THEN return

sle_nomprov.text = ""
sle_regmb.text = ""
wf_filtre()
end event

type sle_regmb from uo_sle within w_rpt_etiqlot
event we_changed pbm_enchange
integer x = 2944
integer y = 64
integer height = 80
boolean bringtotop = true
integer textsize = -9
end type

event we_changed;IF this <> GetFocus() THEN return

sle_nomsp.text = ""
sle_nomprov.text = ""
wf_filtre()
end event

type st_3 from uo_statictext within w_rpt_etiqlot
integer x = 2633
integer y = 80
integer width = 311
integer textsize = -9
string text = "Réf.reg. MB"
end type

type sle_nomprov from uo_sle within w_rpt_etiqlot
event we_changed pbm_enchange
integer x = 2176
integer y = 64
integer height = 80
boolean bringtotop = true
integer textsize = -9
end type

event we_changed;IF this <> GetFocus() THEN return

sle_nomsp.text = ""
sle_regmb.text = ""
wf_filtre()
end event

type st_2 from uo_statictext within w_rpt_etiqlot
integer x = 1902
integer y = 80
integer width = 256
integer textsize = -9
string text = "Nom prov."
end type

type st_1 from uo_statictext within w_rpt_etiqlot
integer x = 1243
integer y = 80
integer width = 219
integer textsize = -9
string text = "Nom SP"
end type

type cb_ok from uo_cb_ok within w_rpt_etiqlot
integer x = 1152
integer y = 1856
boolean default = false
end type

event clicked;call super::clicked;double	ld_nbre
string	ls_filename, ls_reflot, ls_provenance, ls_codesp, ls_nomsp, &
			ls_modeI, ls_sql, ls_odbc
long		ll_nbrows, ll_row
boolean	lb_visible
integer	li_nb, li_anmaturite, li_status

// vérifier si au moins un lot est sélectionné
ld_nbre = double(dw_1.object.c_nbselection[1])
IF ld_nbre = 0 THEN
	gu_message.uf_info("Veuillez sélectionner les lots pour lesquelles il faut imprimer des étiquettes")
	return
END IF

// vérification nombre d'exemplaires
em_nbre.GetData(ld_nbre)

IF ld_nbre <= 0 THEN
	gu_message.uf_info("Veuillez préciser le nombre d'exemplaires à imprimer")
	return
END IF

// vérification existence document de fusion
ls_filename = gs_cenpath + "\doc\" + is_doc
IF f_isEmptyString(is_doc) OR NOT FileExists(ls_filename) THEN
	gu_message.uf_error("Veuillez sélectionner le document de fusion")
	return
END IF

// insérer le contenu des étiquettes dans T_ETIQLOT
ll_nbrows = dw_1.RowCount()
FOR ll_row = 1 TO ll_nbrows
	IF dw_1.object.c_imprimer[ll_row] = 1 THEN
		FOR li_nb = 1 TO ld_nbre
			ls_reflot = dw_1.object.ref_lot[ll_row]
			ls_provenance = dw_1.object.provenance_nom[ll_row]
			ls_codesp = dw_1.object.code_sp[ll_row]
			ls_nomsp = dw_1.object.espece_nom_fr[ll_row]
			li_anmaturite = dw_1.object.an_maturite[ll_row]
			insert into t_etiqlot (sessionid, seq, ref_lot, provenance, code_sp, nom_sp, an_maturite)
				values(:gd_session, :id_sequence, :ls_reflot, :ls_provenance, :ls_codesp, :ls_nomsp, :li_anmaturite)
				USING ESQLCA;
			IF f_check_sql(ESQLCA) <> 0 THEN
				rollback USING ESQLCA;
				gu_message.uf_error("Erreur insert into t_etiqlot")
				return
			END IF
		NEXT
	END IF
NEXT
commit using ESQLCA;

// créer l'ordre SQL pour la fusion (en ajoutant l'ordre de tri choisi dans la sélection)
ls_sql = "select ref_lot barcode, provenance, code_sp, nom_sp, an_maturite from t_etiqlot " + &
			"where sessionid=" + string(gd_session) + " and seq=" + string(id_sequence) + &
			" order by ref_lot"

// connexion ODBC : entrée ODBC doit porter le même nom que l'alias de connexion à la DB
ls_ODBC = "DSN=" + SQLCA.database + ";UID=" + SQLCA.userid + ";PWD=" + SQLCA.dbpass + ";DBQ=" + SQLCA.database + ";"

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
delete from t_etiqlot where sessionid=:gd_session and seq=:id_sequence using ESQLCA;
execute immediate :ls_sql USING ESQLCA;
IF f_check_sql(ESQLCA) = -1 THEN
	rollback using ESQLCA;
	populateerror(20000,"")
	gu_message.uf_unexp("Problème dans la suppression des données temporaires t_etiqlot, session " + string(gd_session), 3)
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

type cb_cancel from uo_cb_cancel within w_rpt_etiqlot
integer x = 1829
integer y = 1856
end type

event clicked;call super::clicked;Close(Parent)
end event

type dw_1 from uo_ancestor_dwbrowse within w_rpt_etiqlot
integer y = 176
integer width = 3493
integer height = 1552
integer taborder = 10
string dataobject = "d_sel_etiqlot"
boolean hscrollbar = true
boolean vscrollbar = true
boolean border = true
boolean hsplitscroll = true
end type

event doubleclicked;call super::doubleclicked;cb_ok.event post clicked()
end event

event clicked;call super::clicked;// si click sur SP : tri sur SP/année
// si click sur année : tri sur année/SP
IF dwo.Type = "text" THEN
	IF dwo.name = "dt_t" THEN
		IF gb_sort_asc THEN
			gu_dwservices.uf_sort(this, "dt_creation A, code_sp A")
			IF NOT this.uf_autoselectrow() THEN this.selectrow(row, FALSE)
		ELSE
			gu_dwservices.uf_sort(this,"dt_creation D, code_sp D")
			IF NOT this.uf_autoselectrow() THEN this.selectrow(row, FALSE)
		END IF
	ELSEIF dwo.name = "sp_t" THEN
		IF gb_sort_asc THEN
			gu_dwservices.uf_sort(this,"code_sp A, dt_creation A")
			IF NOT this.uf_autoselectrow() THEN this.selectrow(row, FALSE)
		ELSE
			gu_dwservices.uf_sort(this,"code_sp D, dt_creation D")
			IF NOT this.uf_autoselectrow() THEN this.selectrow(row, FALSE)
		END IF
	END IF
END IF

end event

type gb_1 from uo_groupbox within w_rpt_etiqlot
integer width = 3493
integer height = 176
integer textsize = -9
integer weight = 700
long textcolor = 8388608
string text = "Filtre..."
end type

