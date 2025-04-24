//objectcomments Fenêtre de connexion à la base de données
forward
global type w_login from w_ancestor
end type
type ddlb_dbname from uo_dropdownlistbox within w_login
end type
type sle_user from uo_sle within w_login
end type
type cb_cancel from uo_cb_cancel within w_login
end type
type cb_ok from uo_cb_ok within w_login
end type
type sle_passwd from uo_sle within w_login
end type
type st_3 from uo_statictext within w_login
end type
type st_2 from uo_statictext within w_login
end type
type st_1 from uo_statictext within w_login
end type
type r_1 from rectangle within w_login
end type
type str_db from structure within w_login
end type
end forward

type str_db from structure
	string		dbdriver
	string		dbname
	boolean		warning
end type

global type w_login from w_ancestor
string tag = "TEXT_00078"
integer x = 1074
integer y = 484
integer width = 1266
integer height = 932
string title = "Connexion à la base de données"
windowtype windowtype = response!
long backcolor = 12639424
ddlb_dbname ddlb_dbname
sle_user sle_user
cb_cancel cb_cancel
cb_ok cb_ok
sle_passwd sle_passwd
st_3 st_3
st_2 st_2
st_1 st_1
r_1 r_1
end type
global w_login w_login

type variables
private str_db	istr_db[]
integer	ii_dbindex, ii_maxindex
end variables

forward prototypes
public subroutine wf_initdbliste (string as_inidb)
end prototypes

public subroutine wf_initdbliste (string as_inidb);// garnir DDLB des alias
// les 2 premiers arguments sont le type de driver (suivant version du client Oracle) suivi
// du nom d'alias. S'il y a des arguments qui suivent, il s'agit de clé vers des listes de Users
// autorisés à utiliser cet alias. Dans ce cas, il faut vérifier si l'utilisateur est repris dans
// cette liste.
string	ls_db[], ls_dbnull[], ls_uliste, ls_dbusers[]
integer	li_uliste, li_dbuser
boolean	lb_autorise, lb_warning

as_inidb = trim(as_inidb)
IF f_IsEmptyString(as_inidb) THEN return

lb_autorise = TRUE
ls_db = ls_dbnull

// si on a une astérisque comme dernier argument dans les paramètres de connection, 
// il faudra afficher la fenêtre d'avertissement
IF RightA(as_inidb, 1) = "*" THEN
	lb_warning = TRUE
	as_inidb = LeftA(as_inidb, LenA(as_inidb) - 2) // enlever ",*"
ELSE
	lb_warning = FALSE
END IF


f_parse(as_inidb, ",", ls_db)

// s'il y a une liste de users pour cet alias, vérifier si l'utilisateur en cours est autorisé à l'utiliser
IF upperbound(ls_db) > 2 THEN
	lb_autorise = FALSE
	FOR li_uliste = 3 TO upperbound(ls_db)
		ls_uliste = ProfileString(gs_locinifile,"DBUSERS", ls_db[li_uliste], "")
		ls_dbusers = ls_dbnull
		f_parse(ls_uliste, ",", ls_dbusers)
		FOR li_dbuser = 1 TO upperbound(ls_dbusers)
			// utilisateur autorisé : quitter les boucles
			IF gs_username = ls_dbusers[li_dbuser] THEN
				lb_autorise = TRUE
				li_dbuser = upperbound(ls_dbusers)
				li_uliste = upperbound(ls_db)
			END IF
		NEXT
	NEXT
END IF

// ajouter l'alias dans la dropdownlisbox
IF lb_autorise AND LenA(ls_db[1]) > 0 AND LenA(ls_db[2]) > 0 THEN
	ii_maxindex++
	istr_db[ii_maxindex].dbdriver = ls_db[1]
	istr_db[ii_maxindex].dbname = ls_db[2]
	istr_db[ii_maxindex].warning = lb_warning
	ddlb_dbname.AddItem(ls_db[2])
END IF

end subroutine

on w_login.create
int iCurrent
call super::create
this.ddlb_dbname=create ddlb_dbname
this.sle_user=create sle_user
this.cb_cancel=create cb_cancel
this.cb_ok=create cb_ok
this.sle_passwd=create sle_passwd
this.st_3=create st_3
this.st_2=create st_2
this.st_1=create st_1
this.r_1=create r_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.ddlb_dbname
this.Control[iCurrent+2]=this.sle_user
this.Control[iCurrent+3]=this.cb_cancel
this.Control[iCurrent+4]=this.cb_ok
this.Control[iCurrent+5]=this.sle_passwd
this.Control[iCurrent+6]=this.st_3
this.Control[iCurrent+7]=this.st_2
this.Control[iCurrent+8]=this.st_1
this.Control[iCurrent+9]=this.r_1
end on

on w_login.destroy
call super::destroy
destroy(this.ddlb_dbname)
destroy(this.sle_user)
destroy(this.cb_cancel)
destroy(this.cb_ok)
destroy(this.sle_passwd)
destroy(this.st_3)
destroy(this.st_2)
destroy(this.st_1)
destroy(this.r_1)
end on

event ue_closebyxaccepted;call super::ue_closebyxaccepted;cb_cancel.event clicked()
end event

event ue_open;call super::ue_open;integer	li_db, li_index
string	ls_inidb, ls_defaultDB, ls_userid, ls_pass

// ne pas logger de message lors de l'utilisation de cette fenêtre
wf_logusage(FALSE)

f_centerInMdi(this)

// lire le user_id, le mot de passe et les DB disponibles dans le .INI global 
// ou dans le .INI local si ces variables y sont présentes
ls_userid = upper(ProfileString(gs_locinifile,"DB","userid",""))
IF f_IsEmptyString(ls_userid) THEN
	ls_userid = upper(ProfileString(gs_inifile,"DB","userid",""))
END IF
sle_user.text = ls_userid

ls_pass = upper(ProfileString(gs_locinifile,"DB","dbpass",""))
IF f_IsEmptyString(ls_pass) THEN
	ls_pass = upper(ProfileString(gs_inifile,"DB","dbpass",""))
END IF
sle_passwd.text = ls_pass

// garnir l'array contenant les DB possibles citées dans le .INI global 
//   (paramètres db1 à db99 de la section [DB])
ii_maxindex = 0
FOR li_db=1 TO 99	
	ls_inidb = ProfileString(gs_inifile,"DB","db" + string(li_db),"")
	wf_initdbliste(ls_inidb)
NEXT

// ajouter à cette liste d'éventuelles DB possibles citées dans le .INI local 
//   (par exemple avec autre driver Oracle), on les numérote à les suite des autres
FOR li_db=1 TO 99
	ls_inidb = ProfileString(gs_locinifile,"DB","db" + string(li_db),"")
	wf_initdbliste(ls_inidb)
NEXT

// DB par défaut est la dernière utilisée sur le PC, ou à défaut celle qui apparaît 
//  en 1ère position dans la "drop down list box"
ls_defaultDB = ProfileString(gs_locinifile, gs_computername, "LastDB", "")
li_index = ddlb_dbname.SelectItem(ls_defaultDB, 0)
IF li_index = 0 THEN li_index = 1
ddlb_dbname.SelectItem(li_index)
ii_dbindex = li_index

end event

type ddlb_dbname from uo_dropdownlistbox within w_login
integer x = 640
integer y = 460
integer height = 600
integer taborder = 30
integer textsize = -8
boolean sorted = false
boolean vscrollbar = true
end type

event selectionchanged;call super::selectionchanged;ii_dbindex = index

end event

type sle_user from uo_sle within w_login
integer x = 640
integer y = 100
integer width = 480
integer height = 80
integer taborder = 10
integer textsize = -8
boolean autohscroll = false
textcase textcase = upper!
end type

event getfocus;This.SelectText(1,LenA(this.text))

end event

type cb_cancel from uo_cb_cancel within w_login
string tag = "TEXT_00028"
integer x = 713
integer y = 672
integer width = 366
integer height = 120
integer taborder = 50
string text = "Abandonner"
end type

event clicked;CloseWithReturn(parent, -1)
end event

type cb_ok from uo_cb_ok within w_login
string tag = "TEXT_00027"
integer x = 165
integer y = 672
integer width = 366
integer height = 120
integer taborder = 40
end type

event clicked;call super::clicked;long	ll_pos

SetPointer(HourGlass!)

IF ii_dbindex = 0 OR ii_dbindex > upperBound(istr_db) THEN
	gu_message.uf_info("Veuillez sélectionner une base de données")
	return
END IF

gb_warning_db = istr_db[ii_dbindex].warning
sqlca.DBMS = istr_db[ii_dbindex].dbdriver
sqlca.database = istr_db[ii_dbindex].dbname
sqlca.servername = istr_db[ii_dbindex].dbname
sqlca.userid = sle_user.text
sqlca.dbpass = sle_passwd.text
sqlca.logid = sle_user.text
sqlca.logpass = sle_passwd.text

// pour ODBC, on confectionne une chaîne de connection basée sur le nom de la DB, le username, password et autres param.
sqlca.dbparm = ProfileString(gs_inifile,"DB","dbparm","")
IF sqlca.DBMS = "ODBC" THEN
	sqlca.dbparm = "connectstring='DSN=" + sqlca.database + ";UID=" + sqlca.userid + ";PWD=" + sqlca.dbpass + "'" &
	+ ",ConnectOption='SQL_DRIVER_CONNECT,SQL_DRIVER_NOPROMPT'," + sqlca.dbparm
END IF

esqlca = create transaction
esqlca.DBMS = sqlca.DBMS
esqlca.database = sqlca.database
esqlca.servername = sqlca.servername
esqlca.userid = sqlca.userid
esqlca.dbpass = sqlca.dbpass
esqlca.logid = sqlca.logid
esqlca.logpass = sqlca.logpass
esqlca.dbparm = sqlca.dbparm

connect using sqlca;
if sqlca.sqlcode <> 0 then
	gu_message.uf_error("SQLCA", "Impossible de se connecter à la base de données : ~n" + sqlca.sqlerrtext,StopSign!)
	sle_user.setfocus()
	return
else
	execute immediate "alter session set NLS_LANGUAGE = French";
	execute immediate "alter session set nls_date_format='DD/MM/YYYY'";
	execute immediate "alter session set nls_numeric_characters=', '";
	execute immediate "alter session set NLS_SORT = Binary";
end if

connect using esqlca;
if esqlca.sqlcode <> 0 then
	gu_message.uf_error("ESQLCA", "Impossible de se connecter à la base de données : ~n" + esqlca.sqlerrtext,StopSign!)
	sle_user.setfocus()
	return
else
	execute immediate "alter session set NLS_LANGUAGE = French" USING ESQLCA;
	execute immediate "alter session set nls_date_format='DD/MM/YYYY'" USING ESQLCA;
	execute immediate "alter session set nls_numeric_characters=', '" USING ESQLCA;
	execute immediate "alter session set NLS_SORT = Binary" USING ESQLCA;
end if

// récupérer le nom de la DB (différent du nom de l'alias utilisé pour la connexion !)
// select value into :gs_dbname from v$parameter where name = 'db_name' USING ESQLCA;
select global_name into :gs_dbname from global_name USING ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	gs_dbname = FillA("?", 20)
ELSE
	// supprimer le suffixe .world
	ll_pos = PosA(gs_dbname, ".", 1)
	IF ll_pos > 0 THEN
		gs_dbname = LeftA(gs_dbname, ll_pos - 1)
	END IF
END IF

// sauver dans .INI local l'alias utilisé pour pouvoir l'utiliser par défaut lors de la connexion suivante
SetProfileString(gs_locinifile, gs_computername, "LastDB", sqlca.database)

// attribuer un n° de session unique
uo_cpteur	lu_cpteur
lu_cpteur = CREATE uo_cpteur
gd_session = lu_cpteur.uf_getsession()
DESTROY lu_cpteur

CloseWithReturn(parent, 1)
end event

type sle_passwd from uo_sle within w_login
integer x = 640
integer y = 280
integer width = 480
integer height = 80
integer taborder = 20
integer textsize = -8
boolean autohscroll = false
boolean password = true
end type

event getfocus;This.SelectText(1,LenA(this.text))
end event

type st_3 from uo_statictext within w_login
integer x = 114
integer y = 460
integer width = 475
integer height = 76
string text = "Base de données"
end type

type st_2 from uo_statictext within w_login
integer x = 114
integer y = 280
integer width = 375
integer height = 76
string text = "Mot de passe"
end type

type st_1 from uo_statictext within w_login
integer x = 114
integer y = 100
integer width = 279
integer height = 76
string text = "Utilisateur"
end type

type r_1 from rectangle within w_login
long linecolor = 79741120
integer linethickness = 4
long fillcolor = 79741120
integer x = 91
integer y = 60
integer width = 1074
integer height = 560
end type

