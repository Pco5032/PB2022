//objectcomments Opérations génériques : résultat d'une opération searchUserDossier
forward
global type w_searchuserdossierresult from w_ancestor
end type
type dw_1 from uo_ancestor_dwbrowse within w_searchuserdossierresult
end type
end forward

global type w_searchuserdossierresult from w_ancestor
integer width = 6162
integer height = 2800
string title = "Résultat SearchUserDossier"
dw_1 dw_1
end type
global w_searchuserdossierresult w_searchuserdossierresult

forward prototypes
public function integer wf_importxml (string as_xml)
end prototypes

public function integer wf_importxml (string as_xml);uo_ds		lds_dossier, lds_status
long		ll_importedRows, ll_importedStatus, ll_row, ll_addedRow, ll_existingRow, ll_r
string	ls_ndossier, ls_status

// importer xml pour extraire la liste des dossiers répondant aux critères de la requête
lds_dossier = CREATE uo_ds
lds_dossier.dataobject = "ds_import_searchuserdossierresult"
ll_importedRows = lds_dossier.importstring(XML!, as_xml)
IF ll_importedRows < 0 THEN
	gu_message.uf_info("Erreur importation résultat : " + string(ll_importedRows))
	DESTROY lds_dossier
	return(-1)
END IF

// vérifier présence ou absence de chaque dossier dans BOLD
dw_1.setRedraw(FALSE)
dw_1.reset()
FOR ll_row = 1 TO ll_importedRows
	ls_ndossier = lds_dossier.object.userDossierNumber[ll_row]
	dw_1.retrieve(ls_ndossier)
	ll_existingRow = dw_1.find("userDossierNumber='" + ls_ndossier + "'", 1, dw_1.rowCount())
	IF ll_existingRow = 0 THEN
		ll_addedRow = dw_1.insertRow(0)
		dw_1.object.userDossierNumber[ll_addedRow] = ls_ndossier
		dw_1.object.c_currentStatus[ll_addedRow] = lds_dossier.object.currentStatus[ll_row]
		dw_1.object.c_processingStatus[ll_addedRow] = lds_dossier.object.processingStatus[ll_row]
		dw_1.object.procedureName[ll_addedRow] = lds_dossier.object.procedureName[ll_row]
		dw_1.object.c_modificationDate[ll_addedRow] = lds_dossier.object.modificationDate[ll_row]
		dw_1.object.c_submissionDate[ll_addedRow] = lds_dossier.object.submissionDate[ll_row]
		dw_1.object.c_agentDossier[ll_addedRow] = lds_dossier.object.agentDossier[ll_row]
	ELSE
		dw_1.object.c_currentStatus[ll_existingRow] = lds_dossier.object.currentStatus[ll_row]
		dw_1.object.c_processingStatus[ll_existingRow] = lds_dossier.object.processingStatus[ll_row]
		dw_1.object.c_modificationDate[ll_existingRow] = lds_dossier.object.modificationDate[ll_row]
		dw_1.object.c_submissionDate[ll_existingRow] = lds_dossier.object.submissionDate[ll_row]
		dw_1.object.c_agentDossier[ll_existingRow] = lds_dossier.object.agentDossier[ll_row]
	END IF
NEXT
DESTROY lds_dossier

dw_1.sort()
dw_1.setRedraw(TRUE)
dw_1.SelectRow(0,false)
dw_1.scrollToRow(1)
dw_1.SelectRow(1,true)

// importer status de la réponse et vérifier s'il existe un warning
lds_status = CREATE uo_ds
lds_status.dataobject = "ds_genop_status"
ll_importedStatus = lds_status.importstring(XML!, as_xml)
FOR ll_row = 1 TO ll_importedStatus
	ls_status = lds_status.object.status[ll_row]
	IF pos(upper(ls_status), "WARNING") > 0 THEN
		gu_message.uf_info(ls_status)
	END IF
NEXT
DESTROY lds_status

return(1)
end function

on w_searchuserdossierresult.create
int iCurrent
call super::create
this.dw_1=create dw_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_1
end on

on w_searchuserdossierresult.destroy
call super::destroy
destroy(this.dw_1)
end on

event ue_open;call super::ue_open;// Instancier BOLD si pas encore fait par un autre objet
IF NOT isValid(gu_bold) THEN
	gu_bold = CREATE uo_bold
END IF

// connexion BOLD
IF gu_bold.uf_connect() = -1 THEN
	post close(this)
	return
END IF

dw_1.setTransObject(gu_bold.itr_bold)

end event

event ue_close;call super::ue_close;// déconnexion et destroy s'il n'y a plus de connexion en cours (par un autre objet éventuellement)
gu_bold.uf_disconnect()
IF gu_bold.uf_getconnectioncount() <= 0 THEN
	DESTROY gu_bold
END IF
end event

event resize;call super::resize;dw_1.width = newWidth
dw_1.height = newHeight - 16
end event

type dw_1 from uo_ancestor_dwbrowse within w_searchuserdossierresult
integer width = 6107
integer height = 2192
integer taborder = 10
string dataobject = "d_searchuserdossierresult"
boolean hscrollbar = true
boolean vscrollbar = true
end type

event retrievestart;call super::retrievestart;// Do not reset the rows and buffers before retrieving data
return(2)
end event

event buttonclicked;call super::buttonclicked;string	ls_ndossier, ls_message

ls_ndossier = this.object.userDossierNumber[row]
IF NOT f_isEmptyString(ls_ndossier) THEN
	IF gu_bold.uf_publishGetUserDossier(ls_ndossier, 0, ls_message) = 1 THEN
		gu_message.uf_info("La demande d'importation a été soumise pour le dossier " + ls_ndossier)
		return(1)
	ELSE
		gu_message.uf_error(ls_message)
		return(-1)
	END IF
END IF
end event

