//objectcomments Object 'bidon' qui sert à réinitialiser la transaction après un DBcancel : faire 1 CREATE et 1 DESTROY de cet objet
forward
global type uo_resetsqlca from nonvisualobject
end type
type ids_dummy from uo_ds within uo_resetsqlca
end type
end forward

global type uo_resetsqlca from nonvisualobject
ids_dummy ids_dummy
end type
global uo_resetsqlca uo_resetsqlca

on uo_resetsqlca.create
call super::create
this.ids_dummy=create ids_dummy
TriggerEvent( this, "constructor" )
end on

on uo_resetsqlca.destroy
TriggerEvent( this, "destructor" )
call super::destroy
destroy(this.ids_dummy)
end on

event constructor;// seul moyen trouvé pour réinitialiser la transaction après un DBCancel() : 
//     faire une lecture bidon, qui provoque une erreur qu'on affiche pas, puis ça va...
// Attention : ue_initial_dberror doit contenir 'return(1)' pour éviter 1 second message
string	ls_sql, ls_err, ls_syntax

ids_dummy.SetTransObject(SQLCA)
ids_dummy.retrieve()

end event

type ids_dummy from uo_ds within uo_resetsqlca descriptor "pb_nvo" = "true" 
string dataobject = "ds_dummy"
end type

event ue_initial_dberror;call super::ue_initial_dberror;// pour éviter d'afficher message d'erreur
return(1)
end event

on ids_dummy.create
call super::create
end on

on ids_dummy.destroy
call super::destroy
end on

