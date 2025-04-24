//objectcomments Visualiser la valeur des variables globales qui existent dans toutes les applications
forward
global type w_ancestor_global from w_ancestor
end type
type lb_1 from uo_listbox within w_ancestor_global
end type
end forward

global type w_ancestor_global from w_ancestor
integer width = 2473
integer height = 2164
string title = "Variables globales"
event ue_print ( )
lb_1 lb_1
end type
global w_ancestor_global w_ancestor_global

event ue_print;integer	li_items, li_i
long	ll_pjob


ll_pjob = PrintOpen( )
Print(ll_pjob, 500, "Liste des variables globales et de leur valeur")
Print(ll_pjob, " ")
li_items = lb_1.TotalItems()
FOR li_i = 1 TO li_items
	Print(ll_pjob, lb_1.text(li_i))
NEXT

PrintClose(ll_pjob)

end event

event resize;call super::resize;lb_1.width = newwidth
lb_1.height = newheight
end event

on w_ancestor_global.create
int iCurrent
call super::create
this.lb_1=create lb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.lb_1
end on

on w_ancestor_global.destroy
call super::destroy
destroy(this.lb_1)
end on

event ue_init_menu;call super::ue_init_menu;f_menuaction({"m_fermer"})
end event

event ue_open;call super::ue_open;// boolean
lb_1.AddItem("gb_enteristab = " + string(gb_enteristab))
lb_1.AddItem("gb_sort_asc = " + string(gb_sort_asc))
lb_1.AddItem("gb_sqlspy_on = " + string(gb_sqlspy_on))
lb_1.AddItem("gb_warning_db = " + string(gb_warning_db))

// integer
lb_1.AddItem("gi_toolbarscount = " + string(gi_toolbarscount))
lb_1.AddItem("gi_zoomsize = " + string(gi_zoomsize))

// long
lb_1.AddItem("gl_browse_even_bckg_color = " + string(gl_browse_even_bckg_color))
lb_1.AddItem("gl_browse_odd_bckg_color = " + string(gl_browse_odd_bckg_color))
lb_1.AddItem("gl_keys_bckg_color = " + string(gl_keys_bckg_color))
lb_1.AddItem("gl_mandatory_bckg_color = " + string(gl_mandatory_bckg_color))
lb_1.AddItem("gl_lptgrey = " + string(gl_lptgrey))

// double
lb_1.AddItem("gd_sequence = " + string(gd_sequence))
lb_1.AddItem("gd_session = " + string(gd_session))

// string
lb_1.AddItem("gs_cenpath = " + gs_cenpath)
lb_1.AddItem("gs_codeservice = " + gs_codeservice)
lb_1.AddItem("gs_computername = " + gs_computername)
lb_1.AddItem("gs_dbname = " + gs_dbname)
lb_1.AddItem("gs_dbalias = " + gs_dbalias)
lb_1.AddItem("gs_domain = " + gs_domain)
lb_1.AddItem("gs_errorlog = " + gs_errorlog)
lb_1.AddItem("gs_helpfile = " + gs_helpfile)
lb_1.AddItem("gs_inifile = " + gs_inifile)
lb_1.AddItem("gs_locinifile = " + gs_locinifile)
lb_1.AddItem("gs_MyDocuments = " + gs_MyDocuments)
lb_1.AddItem("gs_nomservice = " + gs_nomservice)
lb_1.AddItem("gs_OSversion = " + gs_osversion)
lb_1.AddItem("gs_shell = " + gs_shell)
lb_1.AddItem("gs_startpath = " + gs_startpath)
lb_1.AddItem("gs_tmpfiles = " + gs_tmpfiles)
lb_1.AddItem("gs_username = " + gs_username)
lb_1.AddItem("gs_serviceIniFile = " + f_string(gs_serviceIniFile))

// transaction
lb_1.AddItem("sqlca = " + sqlca.DBMS + " " + sqlca.logid + "@"  + sqlca.database + &
					" DBPARM(" + sqlca.DBPARM + ")  Err(" + string(sqlca.sqlcode) + " - " + string(sqlca.sqldbcode) + " - " + &
					sqlca.sqlerrtext + ")")
lb_1.AddItem("esqlca = " + esqlca.DBMS + " " + esqlca.logid + "@"  + esqlca.database + &
					" DBPARM(" + esqlca.DBPARM + ")  Err(" + string(esqlca.sqlcode) + " - " + string(esqlca.sqldbcode) + " - " + &
					esqlca.sqlerrtext + ")")

end event

type lb_1 from uo_listbox within w_ancestor_global
integer width = 1573
integer height = 928
integer taborder = 10
boolean hscrollbar = true
boolean vscrollbar = true
end type

