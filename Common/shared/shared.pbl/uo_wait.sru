forward
global type uo_wait from nonvisualobject
end type
end forward

global type uo_wait from nonvisualobject
end type
global uo_wait uo_wait

type variables
string	is_tag_wip="TEXT_00117", is_tag_wip_wait="TEXT_00118"
end variables

forward prototypes
public subroutine uf_closewindow ()
public subroutine uf_openwindow (string as_title, boolean ab_cancancel)
public subroutine uf_openwindow (string as_title)
public subroutine uf_addinfo (string as_info)
public subroutine uf_openwindow ()
public subroutine uf_openwindow (boolean ab_cancancel)
public function boolean uf_isopened ()
end prototypes

public subroutine uf_closewindow ();IF IsValid(w_wait) THEN
	close(w_wait)
END IF

end subroutine

public subroutine uf_openwindow (string as_title, boolean ab_cancancel);IF uf_IsOpened() THEN
	w_wait.SetFocus()
ELSE
	Open(w_wait)
END IF
w_wait.cb_cancel.visible = ab_CanCancel
w_wait.st_msg.visible = NOT ab_CanCancel
//OpenSheet(w_wait,gw_MDIFrame,0,Original!)
w_wait.SetRedraw(TRUE)
w_wait.title = as_title
SetPointer(hourglass!)

end subroutine

public subroutine uf_openwindow (string as_title);uf_openwindow(as_title, FALSE)
end subroutine

public subroutine uf_addinfo (string as_info);IF NOT IsValid(w_wait) THEN
	uf_OpenWindow()
END IF
IF IsValid(w_wait) THEN
	w_wait.st_info.text=as_info
	w_wait.SetFocus()
END IF

end subroutine

public subroutine uf_openwindow ();string	ls_title

ls_title = gu_translate.uf_getlabel(is_tag_wip, "Traitement en cours")
uf_openwindow(ls_title, FALSE)
end subroutine

public subroutine uf_openwindow (boolean ab_cancancel);string	ls_title

IF ab_CanCancel THEN
	ls_title = gu_translate.uf_getlabel(is_tag_wip_wait, "Traitement en cours, patientez...")
ELSE
	ls_title = gu_translate.uf_getlabel(is_tag_wip, "Traitement en cours")
END IF
uf_openwindow(ls_title, ab_CanCancel)
end subroutine

public function boolean uf_isopened ();// return TRUE si la fenêtre de wait est déjà ouverte, FALSE sinon
IF IsValid(w_wait) THEN
	return(TRUE)
ELSE
	return(FALSE)
END IF

end function

on uo_wait.create
call super::create
TriggerEvent( this, "constructor" )
end on

on uo_wait.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

event destructor;IF IsValid(w_wait) THEN
	uf_CloseWindow()
END IF
end event

