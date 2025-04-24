forward
global type w_global from w_ancestor_global
end type
end forward

global type w_global from w_ancestor_global
end type
global w_global w_global

on w_global.create
call super::create
end on

on w_global.destroy
call super::destroy
end on

type lb_1 from w_ancestor_global`lb_1 within w_global
end type

