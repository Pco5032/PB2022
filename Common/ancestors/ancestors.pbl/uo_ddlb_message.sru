forward
global type uo_ddlb_message from uo_dropdownlistbox
end type
end forward

global type uo_ddlb_message from uo_dropdownlistbox
integer width = 1367
integer height = 372
integer textsize = -9
long textcolor = 65535
long backcolor = 276856960
boolean sorted = false
boolean vscrollbar = true
event ue_message ( string as_message )
end type
global uo_ddlb_message uo_ddlb_message

event ue_message;// ajouter un message
this.additem(as_message)

// ne garder que les 20 derniers messages
IF this.TotalItems() > 20 THEN
	this.DeleteItem(this.selectitem(1))
END IF

// sélectionner le message ajouté
this.selectitem(this.TotalItems())

end event

on uo_ddlb_message.create
end on

on uo_ddlb_message.destroy
end on

event losefocus;call super::losefocus;this.SelectItem(this.TotalItems())
end event

