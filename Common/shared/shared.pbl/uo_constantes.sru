forward
global type uo_constantes from nonvisualobject
end type
end forward

global type uo_constantes from nonvisualobject
end type
global uo_constantes uo_constantes

type variables
privatewrite integer	i_null
privatewrite long		l_null
privatewrite string	s_null
privatewrite decimal	d_null
privatewrite date			date_null
privatewrite datetime	datetime_null
privatewrite time			time_null
end variables

event constructor;SetNull(i_null)
SetNull(l_null)
SetNull(s_null)
SetNull(d_null)
SetNull(date_null)
SetNull(datetime_null)
SetNull(time_null)
end event

on uo_constantes.create
call super::create
TriggerEvent( this, "constructor" )
end on

on uo_constantes.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

