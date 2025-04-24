//objectcomments Ancêtre pour les DW control utilisés dans les reports
forward
global type uo_ancestor_dwreport from uo_dw
end type
end forward

global type uo_ancestor_dwreport from uo_dw
integer width = 183
integer height = 84
integer taborder = 1
boolean livescroll = true
end type
global uo_ancestor_dwreport uo_ancestor_dwreport

type variables

end variables

forward prototypes
public subroutine uf_changedataobject (string as_dataobject)
end prototypes

public subroutine uf_changedataobject (string as_dataobject);// assigne un autre dataobject au DWControl lorsqu'il en utilisait déjà un
This.DataObject = as_dataobject
This.SetTransObject(SQLCA)	
end subroutine

on uo_ancestor_dwreport.create
end on

on uo_ancestor_dwreport.destroy
end on

event constructor;call super::constructor;This.SetTransObject(SQLCA)
end event

