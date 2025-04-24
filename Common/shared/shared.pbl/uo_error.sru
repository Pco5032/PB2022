forward
global type uo_error from error
end type
end forward

global type uo_error from error
end type
global uo_error uo_error

type variables
str_dberror	istr_dberror
end variables

forward prototypes
public subroutine uf_reset ()
public function integer uf_getsavedseverity ()
public function string uf_getsavedtext ()
public subroutine uf_savedberror (str_dberror astr_dberror)
public function long uf_getsavedsqldbcode ()
end prototypes

public subroutine uf_reset ();populateerror(0,"")
istr_dberror.l_sqldbcode = 0
istr_dberror.i_severity = 0
istr_dberror.s_sqlerrtext = ""
istr_dberror.s_sqlsyntax = ""
end subroutine

public function integer uf_getsavedseverity ();IF istr_dberror.i_severity > 0 THEN
	return(istr_dberror.i_severity)
ELSE
	return(-1)
END IF
end function

public function string uf_getsavedtext ();IF LenA(istr_dberror.s_sqlerrtext) > 0 THEN
	return(string(istr_dberror.l_sqldbcode) + " - " + istr_dberror.s_sqlerrtext)
ELSE
	return(gu_c.s_null)
END IF
end function

public subroutine uf_savedberror (str_dberror astr_dberror);istr_dberror = astr_dberror
end subroutine

public function long uf_getsavedsqldbcode ();IF istr_dberror.l_sqldbcode > 0 THEN
	return(istr_dberror.l_sqldbcode)
ELSE
	return(gu_c.l_null)
END IF
end function

on uo_error.create
call super::create
TriggerEvent( this, "constructor" )
end on

on uo_error.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

