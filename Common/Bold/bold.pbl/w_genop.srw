//objectcomments Opérations génériques
forward
global type w_genop from w_ancestor_dataentry
end type
type dw_genop from uo_datawindow_multiplerow within w_genop
end type
type cb_refresh from uo_cb within w_genop
end type
type cbx_1 from uo_cbx within w_genop
end type
end forward

global type w_genop from w_ancestor_dataentry
integer width = 4352
integer height = 2328
string title = "Opérations génériques"
boolean maxbox = true
boolean resizable = true
dw_genop dw_genop
cb_refresh cb_refresh
cbx_1 cbx_1
end type
global w_genop w_genop

forward prototypes
public function integer wf_trt_searchuserdossier (long al_row)
end prototypes

public function integer wf_trt_searchuserdossier (long al_row);// traitement résultat opération générique : 
// afficher la liste des dossiers trouvés et la correspondance (ou pas) avec les dossiers qui sont dans BOLD
string	ls_xml, ls_operation
blob		lb_result
integer	li_id

// lire résultat (xml)
li_id = integer(dw_genop.object.id[al_row])
SELECT operation, result INTO :ls_operation, :lb_result FROM GENOP where id=:li_id USING gu_bold.itr_bold;
IF gu_bold.itr_bold.sqlCode <> 0 THEN
	gu_message.uf_error("Erreur select GENOP : " + string(gu_bold.itr_bold.sqlDBCode) + " - " + gu_bold.itr_bold.sqlErrText)
	return(-1)
END IF

ls_xml = string(lb_result)

// Traiter résultat en fonction de l'opération
CHOOSE CASE upper(ls_operation)
	CASE "SEARCHUSERDOSSIERS"
		IF NOT IsValid(w_searchuserdossierresult) THEN
			OpenSheet(w_searchuserdossierresult, gw_mdiframe, 0, Original!)
		END IF
		IF IsValid(w_searchuserdossierresult) THEN
			w_searchuserdossierresult.SetFocus()
			w_searchuserdossierresult.post wf_importXml(ls_xml)
		END IF
END CHOOSE
return(1)
end function

on w_genop.create
int iCurrent
call super::create
this.dw_genop=create dw_genop
this.cb_refresh=create cb_refresh
this.cbx_1=create cbx_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_genop
this.Control[iCurrent+2]=this.cb_refresh
this.Control[iCurrent+3]=this.cbx_1
end on

on w_genop.destroy
call super::destroy
destroy(this.dw_genop)
destroy(this.cb_refresh)
destroy(this.cbx_1)
end on

event ue_postopen;call super::ue_postopen;dw_genop.retrieve()
end event

event ue_open;call super::ue_open;// Instancier BOLD si pas encore fait par un autre objet
IF NOT isValid(gu_bold) THEN
	gu_bold = CREATE uo_bold
END IF

// connexion BOLD
IF gu_bold.uf_connect() = -1 THEN
	post close(this)
	return
END IF

dw_genop.setTransObject(gu_bold.itr_bold)

// divers
this.event ue_init_menu()

end event

event ue_close;call super::ue_close;// déconnexion et destroy s'il n'y a plus de connexion en cours (par un autre objet éventuellement)
gu_bold.uf_disconnect()
IF gu_bold.uf_getconnectioncount() <= 0 THEN
	DESTROY gu_bold
END IF
end event

event resize;call super::resize;dw_genop.height = newHeight - 220
dw_genop.width = newwidth
end event

event ue_init_menu;call super::ue_init_menu;f_menuaction({"m_abandonner","m_fermer"})	
end event

type ddlb_message from w_ancestor_dataentry`ddlb_message within w_genop
end type

type dw_genop from uo_datawindow_multiplerow within w_genop
integer y = 112
integer width = 4315
integer height = 1920
integer taborder = 10
boolean bringtotop = true
string dataobject = "d_genop"
boolean vscrollbar = true
boolean border = true
end type

event buttonclicked;call super::buttonclicked;IF this.object.indic_exception[row] = 1 THEN
	gu_message.uf_info("Cette requête est en situation d'erreur.")
	return
END IF

// traiter résultat opération searchUserDossier
IF upper(this.object.operation[row]) = "SEARCHUSERDOSSIERS" THEN
	wf_trt_searchuserdossier(row)
END IF
end event

event ue_postitemvalidated;call super::ue_postitemvalidated;integer	li_status

IF as_name = "done" THEN
	li_status = dw_genop.update()
	IF li_status = -1 THEN
		gu_message.uf_error("Erreur update GENOP")
		rollback using gu_bold.itr_bold;
		return
	ELSE
		wf_message("Enregistrement OK")
		commit using gu_bold.itr_bold;
		return
	END IF
END IF
end event

type cb_refresh from uo_cb within w_genop
integer y = 8
integer width = 311
integer height = 96
integer taborder = 10
boolean bringtotop = true
integer textsize = -9
string text = "Actualiser"
end type

event clicked;call super::clicked;dw_genop.retrieve()

end event

type cbx_1 from uo_cbx within w_genop
integer x = 384
integer y = 16
boolean bringtotop = true
end type

