//objectcomments Userdossier : liste des drc
forward
global type w_bold_drc_list from w_ancestor
end type
type dw_1 from uo_ancestor_dwbrowse within w_bold_drc_list
end type
end forward

global type w_bold_drc_list from w_ancestor
integer width = 4960
integer height = 2524
string title = "Liste des DRC du dossier"
dw_1 dw_1
end type
global w_bold_drc_list w_bold_drc_list

type variables

end variables

forward prototypes
public function integer wf_retrieve (string as_ndossier)
end prototypes

public function integer wf_retrieve (string as_ndossier);IF f_isEmptyString(as_ndossier) THEN
	return(-1)
END IF

dw_1.setTransobject(gu_bold.itr_bold)

this.title = "Liste des DRC du dossier " + as_ndossier
return(dw_1.retrieve(as_ndossier))
end function

on w_bold_drc_list.create
int iCurrent
call super::create
this.dw_1=create dw_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_1
end on

on w_bold_drc_list.destroy
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

end event

event ue_close;call super::ue_close;// déconnexion et destroy s'il n'y a plus de connexion en cours (par un autre objet éventuellement)
gu_bold.uf_disconnect()
IF gu_bold.uf_getconnectioncount() = 0 THEN
	DESTROY gu_bold
END IF

end event

event resize;call super::resize;dw_1.width = newwidth
dw_1.height = newheight
end event

type dw_1 from uo_ancestor_dwbrowse within w_bold_drc_list
integer width = 4919
integer height = 2224
integer taborder = 10
string dataobject = "d_bold_drc_list"
boolean hscrollbar = true
boolean vscrollbar = true
boolean border = true
end type

