forward
global type uo_runwait from nonvisualobject
end type
end forward

global type uo_runwait from nonvisualobject
end type
global uo_runwait uo_runwait

type prototypes
FUNCTION boolean CreateProcessW(string AppName, string CommLine, long l1, long l2, boolean binh, long creationflags, long l3, string dir, str_startupinfo startupinfo, ref str_processinformation pi ) library 'kernel32.dll' alias for "CreateProcessW"
FUNCTION long WaitForSingleObject ( ulong ul_Notification, long lmillisecs ) library "kernel32.dll"


end prototypes

type variables

end variables

forward prototypes
public function boolean uf_runandwait (string as_command)
public function boolean uf_runandwait (string as_command)
end prototypes

public function boolean uf_runandwait (string as_command);CONSTANT long STARTF_USESHOWWINDOW = 1
CONSTANT long CREATE_NEW_CONSOLE = 16
CONSTANT long NORMAL_PRIORITY_CLASS = 32
CONSTANT long INFINITE = -1

long		ll_CreationFlags
string 	ls_CurDir
boolean	lb_stat

SetNull(ls_CurDir)

str_StartupInfo 			lstr_Start
str_Processinformation	lstr_PI

lstr_Start.cb 				= 72
lstr_Start.dwFlags 		= STARTF_USESHOWWINDOW
lstr_Start.wShowWindow 	= 1

ll_CreationFlags = CREATE_NEW_CONSOLE + NORMAL_PRIORITY_CLASS

lb_stat = CreateProcessW(gu_c.s_Null, as_command, gu_c.l_Null, gu_c.l_Null, FALSE, ll_CreationFlags, &
								 gu_c.l_Null, ls_CurDir, lstr_Start, lstr_PI)

WaitForSingleObject(lstr_PI.hProcess, INFINITE)

return(lb_stat)
end function

on uo_runwait.create
call super::create
TriggerEvent( this, "constructor" )
end on

on uo_runwait.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

