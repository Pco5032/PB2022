//objectcomments Fenêtre de connexion à la base de données. En test : liste des connexions possibles dans la DB.
forward
global type w_login_new from w_ancestor
end type
type ddlb_driver from uo_dropdownlistbox within w_login_new
end type
type st_1 from uo_statictext within w_login_new
end type
type ddlb_dbname from uo_dropdownlistbox within w_login_new
end type
type cb_cancel from uo_cb_cancel within w_login_new
end type
type cb_ok from uo_cb_ok within w_login_new
end type
type st_3 from uo_statictext within w_login_new
end type
type str_db from structure within w_login_new
end type
end forward

type str_db from structure
	string		dbdriver
	string		dbname
	boolean		warning
end type

global type w_login_new from w_ancestor
integer x = 1074
integer y = 484
integer width = 1527
integer height = 500
string title = "Connexion"
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
ddlb_driver ddlb_driver
st_1 st_1
ddlb_dbname ddlb_dbname
cb_cancel cb_cancel
cb_ok cb_ok
st_3 st_3
end type
global w_login_new w_login_new

type variables
integer	ii_dbindex, ii_driverIndex
uo_ds		ids_dblist
uo_encrypt	iu_encrypt
transaction	itr_authentification
string	is_bold_dbid_dvpt, is_bold_user_dvpt, is_bold_pwd_dvpt, &
			is_bold_dbid_prod, is_bold_user_prod, is_bold_pwd_prod
end variables

forward prototypes
public function integer wf_connect ()
end prototypes

public function integer wf_connect ();// connexion à la DB sélectionnée
// return(1) si OK
// return(-1) si erreur
long	ll_pos
date	ldt_date
string ls_pbDriver, ls_localPBDriver, ls_pwd, ls_user, ls_envApp, ls_bold_dbID
uo_Wait	lu_wait

lu_wait = CREATE uo_wait

IF ids_dblist.rowCount() = 1 THEN
	lu_wait.uf_addinfo("Connexion en cours vers " + ids_dblist.object.dbalias[ii_dbindex])
ELSE
	SetPointer(HourGlass!)
END IF

// afficher fenêtre d'avertissement ou pas
IF ids_dblist.object.warning[ii_dbindex] = "O" THEN
	gb_warning_db = TRUE
ELSE
	gb_warning_db = FALSE
END IF

// driver par défaut ou choix spécifique ?
IF ii_driverIndex = 1 THEN
	ls_pbDriver = ProfileString(gs_inifile, "DB", "DefaultDriver", "O84")
ELSE
	ls_pbDriver = ddlb_driver.text
END IF

ls_user = ids_dblist.object.schema[ii_dbindex]
ls_pwd = ids_dblist.object.passwd[ii_dbindex]

// sauver l'alias DB (peut être différent du nom de la DB stocké dans gs_dbname : par exemple avec Oracle XE,
// DBNAME vaut toujours XE tandis que l'alias représente bien le nom LDAP utilisé pour la connexion)
gs_dbalias = ids_dblist.object.dbalias[ii_dbindex]

// paramétrage de la connexion SQLCA
sqlca.DBMS = ls_pbDriver
sqlca.database = ids_dblist.object.dbalias[ii_dbindex]
sqlca.servername = ids_dblist.object.dbalias[ii_dbindex]
sqlca.userid = ls_user
sqlca.dbpass = ls_pwd
sqlca.logid = ls_user
sqlca.logpass = ls_pwd

// paramètres de connexion (decimalSeparator, bind, catalogue...)
sqlca.dbparm = ProfileString(gs_inifile,"DB","dbparm","")

// pour ODBC, on confectionne une chaîne de connection basée sur le nom de la DB, le username, password et autres param.
IF sqlca.DBMS = "ODBC" THEN
	sqlca.dbparm = "connectstring='DSN=" + sqlca.database + ";UID=" + sqlca.userid + ";PWD=" + sqlca.dbpass + "'" &
	+ ",ConnectOption='SQL_DRIVER_CONNECT,SQL_DRIVER_NOPROMPT'," + sqlca.dbparm
END IF

// paramétrage de la connexion ESQLCA = idem SQLCA
esqlca = create transaction
esqlca.DBMS = sqlca.DBMS
esqlca.database = sqlca.database
esqlca.servername = sqlca.servername
esqlca.userid = sqlca.userid
esqlca.dbpass = sqlca.dbpass
esqlca.logid = sqlca.logid
esqlca.logpass = sqlca.logpass
esqlca.dbparm = sqlca.dbparm

// connexion...
connect using sqlca;
if sqlca.sqlcode <> 0 then
	DESTROY lu_wait
	gu_message.uf_error("SQLCA", "Impossible de se connecter à la base de données : ~n" + sqlca.sqlerrtext,StopSign!)
	ddlb_dbname.setfocus()
	return(-1)
else
	execute immediate "alter session set NLS_LANGUAGE = French";
	execute immediate "alter session set nls_date_format='DD/MM/YYYY'";
	execute immediate "alter session set nls_numeric_characters=', '";
	execute immediate "alter session set NLS_SORT = Binary";
end if

connect using esqlca;
if esqlca.sqlcode <> 0 then
	DESTROY lu_wait
	gu_message.uf_error("ESQLCA", "Impossible de se connecter à la base de données : ~n" + esqlca.sqlerrtext,StopSign!)
	ddlb_dbname.setfocus()
	return(-1)
else
	execute immediate "alter session set NLS_LANGUAGE = French" USING ESQLCA;
	execute immediate "alter session set nls_date_format='DD/MM/YYYY'" USING ESQLCA;
	execute immediate "alter session set nls_numeric_characters=', '" USING ESQLCA;
	execute immediate "alter session set NLS_SORT = Binary" USING ESQLCA;
end if

// déterminer environnement : production (P) ou tests/développement (T). Autre valeur assimilée à T.
select envApp into :ls_envapp from params using ESQLCA;
gs_envapp = "T"
IF f_check_sql(ESQLCA) = 0 THEN
	gs_envapp = ls_envapp
END IF

// PCO 13/05/2022 : lire paramètres de connexion BOLD selon l'environnement (T/P)
IF gs_envapp = "T" THEN
	ls_bold_dbID = ProfileString(gs_inifile, "BOLD", "DBIDDVPT", "")
ELSEIF gs_envapp = "V" THEN
	ls_bold_dbID = ProfileString(gs_inifile, "BOLD", "DBIDVALID", "")
ELSE
	ls_bold_dbID = ProfileString(gs_inifile, "BOLD", "DBIDPROD", "")
END IF
IF NOT f_isEmptyString(ls_bold_dbID) THEN
	select dbalias,
			 dnf_decrypt_raw(schema, DNF_vars.getCryptKey()),
			 dnf_decrypt_raw(passwd, DNF_vars.getCryptKey())
		into :gs_boldDBAlias, :gs_bolduser, :gs_boldpwd from dnf_dbalias
		where dbid = :ls_bold_dbID using itr_authentification; 
END IF
IF f_check_sql(itr_authentification) <> 0 THEN
	gs_boldDBAlias = ""
	gs_bolduser = ""
	gs_boldpwd = ""
END IF

// stocker date de connexion et dernière DB utilisée
gs_dbdesc = ids_dblist.object.description[ii_dbindex]
ldt_date = f_today()
update dnf_user
  	set lastdb = :gs_dbdesc, lastlogon=:ldt_date, lastcomputer=:gs_computername
  	where domain = :gs_domain and logname=:gs_username using itr_authentification;
IF itr_authentification.SQLCode = 0 THEN
	commit using itr_authentification;
ELSE
	rollback using itr_authentification;
END IF

// plus besoin de la connexion d'authentification --> déconnexion
disconnect using itr_authentification;

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

// attribuer un n° de session unique
uo_cpteur	lu_cpteur
lu_cpteur = CREATE uo_cpteur
gd_session = lu_cpteur.uf_getsession()
DESTROY lu_cpteur

// PCO 05/07/2017 : cas où le compteur est en cours d'utilisation
IF gd_session < 0 THEN
	halt
END IF

// PCO 30/03/2017 : il arrive qu'on aie un message "null object reference" sur la ligne du IF ii_driverIndex.
// Je ne connais pas les conditions pour reproduire l'erreur, aussi j'ajoute un test isValid sur la fenêtre
// elle-même.
IF NOT isValid(this) THEN
	populateError(20000, "Erreur inattendue : objet n'existe plus, application arrêtée.")
	gu_message.uf_unexp()
	halt
END IF

// sauver le driver si on en a choisi un autre que le default
IF ii_driverIndex > 1 THEN
	SetProfileString(gs_locinifile, gs_computername, "LocalPBDriver", ls_pbDriver)
END IF

// si on a choisi le driver par défaut alors qu'on en avait auparavant choisi un spécifique,
// il faut annuler le paramétrage dans le .ini
IF ii_driverIndex = 1 THEN
	ls_localPBDriver = ProfileString(gs_locinifile, gs_computername, "LocalPBDriver", "")
	IF NOT f_isEmptyString(ls_localPBDriver) THEN
		SetProfileString(gs_locinifile, gs_computername, "LocalPBDriver", "")
	END IF
END IF

DESTROY lu_wait
return(1)
end function

on w_login_new.create
int iCurrent
call super::create
this.ddlb_driver=create ddlb_driver
this.st_1=create st_1
this.ddlb_dbname=create ddlb_dbname
this.cb_cancel=create cb_cancel
this.cb_ok=create cb_ok
this.st_3=create st_3
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.ddlb_driver
this.Control[iCurrent+2]=this.st_1
this.Control[iCurrent+3]=this.ddlb_dbname
this.Control[iCurrent+4]=this.cb_cancel
this.Control[iCurrent+5]=this.cb_ok
this.Control[iCurrent+6]=this.st_3
end on

on w_login_new.destroy
call super::destroy
destroy(this.ddlb_driver)
destroy(this.st_1)
destroy(this.ddlb_dbname)
destroy(this.cb_cancel)
destroy(this.cb_ok)
destroy(this.st_3)
end on

event ue_closebyxaccepted;call super::ue_closebyxaccepted;cb_cancel.event clicked()
end event

event ue_open;call super::ue_open;integer	li_index, li_i
string	ls_defaultDB, ls_driverList, ls_driver[], ls_PBDriver, ls_localPBDriver, &
			ls_initialDB, ls_initialUSER, ls_initialPWD, ls_sql
long		ll_row

wf_logusage(FALSE)

iu_encrypt = CREATE uo_encrypt
itr_authentification = CREATE transaction	

// lire la liste des driver PB disponibles
ls_driverList = ProfileString(gs_inifile, "DB", "DriverList", "")
f_parse(ls_driverList, ",", ls_driver)

// garnir dropdownlisbox avec les drivers disponibles
FOR li_index = 1 TO upperBound(ls_driver)
	ddlb_driver.AddItem(ls_driver[li_index])
NEXT

// normalement, driver PB est celui par défaut mais peut être modifié localement (par PC)
ls_PBDriver = ProfileString(gs_inifile, "DB", "DefaultDriver", "O84")
ls_localPBDriver = ProfileString(gs_locinifile, gs_computername, "LocalPBDriver", "")
li_index = ddlb_driver.SelectItem(ls_localPBDriver, 0)
// si pas de driver spécifique, sélectionner le 1er (qui est "default")
IF li_index = 0 THEN li_index = 1
ddlb_driver.SelectItem(li_index)
ii_driverIndex = li_index

// Connexion spéciale permettant de lire les connexions autorisées.
// Normalement, utilisation d'un schéma dans une DB centralisée, d'où la config dans le .ini global, 
// config. étant identique pour tous les sites.
// Si c'est trop pénalisant, on peut prévoir dans le .INI local d'autres paramètres de connexion
// initiale, par exemple si on créée un schéma particulier dans la DB locale où on réplique les données
// d'identification...
// Enfin, on peut aussi spécifier des paramètres propres à l'utilisateur, par exemple
// afin d'utiliser une connexion "connect manager", une connexion spéciale pour télétravail,...
ls_initialDB = ProfileString(gs_inifile, "DB", "InitialDB", "")
ls_initialDB = ProfileString(gs_locinifile, "DB", "InitialDB", ls_initialDB)
ls_initialDB = ProfileString(gs_locinifile, gs_computername, "InitialDB", ls_initialDB)
ls_initialUSER = ProfileString(gs_inifile, "DB", "InitialUSER", "")
ls_initialUSER = ProfileString(gs_locinifile, "DB", "InitialUSER", ls_initialUSER)
ls_initialUSER = ProfileString(gs_locinifile, gs_computername, "InitialUSER", ls_initialUSER)
ls_initialPWD = ProfileString(gs_inifile, "DB", "InitialPWD", "")
ls_initialPWD = ProfileString(gs_locinifile, "DB", "InitialPWD", ls_initialPWD)
ls_initialPWD = ProfileString(gs_locinifile, gs_computername, "InitialPWD", ls_initialPWD)
IF f_isEmptyString(ls_initialDB) OR f_isEmptyString(ls_initialUSER) OR f_isEmptyString(ls_initialPWD) THEN
	gu_message.uf_error("Connexion initiale", "Au moins un paramètre de connexion initiale est manquant : ~n~n"+ &
					"ls_initialDB=" + f_string(ls_initialDB) + "~n" + &
					"ls_initialUSER=" + f_string(ls_initialUSER) + "~n" + &
					"ls_initialPWD=" + f_string(ls_initialPWD), StopSign!)
	post CloseWithReturn(this, -1)
	return
END IF

// décryper user et passwd, stockés cryptés dans le .ini
ls_initialPWD = iu_encrypt.of_decrypt(ls_initialPWD, gs_CryptKey)
ls_initialUSER = iu_encrypt.of_decrypt(ls_initialUSER, gs_CryptKey)

IF NOT f_isEmptyString(ls_localPBDriver) THEN
	ls_PBDriver = ls_localPBDriver
END IF

itr_authentification = CREATE transaction

itr_authentification.DBMS = ls_PBDriver
itr_authentification.database = ls_initialDB
itr_authentification.servername = ls_initialDB
itr_authentification.userid = ls_initialUSER
itr_authentification.dbpass = ls_initialPWD
itr_authentification.logid = ls_initialUSER
itr_authentification.logpass = ls_initialPWD
connect using itr_authentification;
IF itr_authentification.sqlcode <> 0 then
	gu_message.uf_error("ltr_authentification", "Impossible de se connecter à la base de données : ~n" + itr_authentification.sqlerrtext,StopSign!)
	post CloseWithReturn(this, -1)
	return
END IF

// initialisation dans la session Oracle de la clé de cryptage
// (elle est utilisée par les fonctions Oracle de cryptage)
ls_sql = "begin DNF_vars.cryptKey := '" + gs_cryptkey + "'; end;"
execute immediate :ls_sql using itr_authentification;

// lire la liste des DB accessibles à l'utilisateur en cours
ids_dblist = CREATE uo_ds
ids_dblist.dataObject = "ds_dblist"
ids_dblist.settransobject(itr_authentification)

IF ids_dblist.retrieve(gs_domain, gs_username) < 0 THEN
	populateError(20000,"")
	gu_message.uf_unexp("Impossible de lire les connexions autorisées")
	disconnect using itr_authentification;
	post CloseWithReturn(this, -1)
	return
END IF

IF ids_dblist.rowCount() = 0 THEN
	gu_message.uf_info("Aucune base de données accessible !")
	post CloseWithReturn(this, -1)
	return
END IF

// ajouter les alias disponibles dans la dropdownlisbox
FOR ll_row = 1 TO ids_dblist.rowCount()
	ddlb_dbname.AddItem(ids_dblist.object.description[ll_row])
NEXT

// DB par défaut est la dernière utilisée sur le PC, ou à défaut celle qui apparaît 
//  en 1ère position dans la "drop down list box"
select lastdb into :ls_defaultDB from dnf_user 
	where domain = :gs_domain and logname=:gs_username using itr_authentification;

// PCO 18/12/2014 : SelectItem(ls_defaultDB, 0) trouve une correspondance si le texte dans la liste commence par
// le texte recherché, même s'il est plus long.
// Par exemple : si recherche DBCENTRALE et 1er élément de la liste est "DBCENTRALE TEST", 
//               2ème element est "DBCENTRALE" : l'index renvoyé est le 1, ce qui n'est pas correct.
// --> remplacer SelectItem(ls_defaultDB, 0) par une boucle de recherche sur le nom exact.
FOR li_i = 1 TO ddlb_dbname.totalitems()
	IF ls_defaultDB = ddlb_dbname.text(li_i) THEN
		li_index = li_i
		EXIT
	END IF
NEXT

// si pas trouvé dans la boucle ci-dessus, utiliser 1ère option de la liste
IF li_index = 0 OR isNull(li_index) THEN li_index = 1
ddlb_dbname.SelectItem(li_index)
ii_dbindex = li_index

f_centerInMdi(this)

// PCO 15/12/2015 : si une seule DB disponible, s'y connecter directement sans proposer de choix
// à l'utilisateur
IF ids_dblist.rowCount() = 1 THEN
	IF wf_connect() = 1 THEN 
		this.visible = FALSE
		post CloseWithReturn(this, 1)
	END IF
END IF



end event

event ue_close;call super::ue_close;DESTROY ids_dblist
DESTROY iu_encrypt
DESTROY itr_authentification
end event

type ddlb_driver from uo_dropdownlistbox within w_login_new
boolean visible = false
integer x = 530
integer y = 384
integer width = 366
integer height = 336
integer textsize = -8
boolean enabled = false
boolean sorted = false
boolean vscrollbar = true
string item[] = {"Standard"}
end type

event selectionchanged;call super::selectionchanged;ii_driverIndex = index

end event

type st_1 from uo_statictext within w_login_new
string tag = "TEXT_00072"
boolean visible = false
integer y = 384
integer width = 494
boolean enabled = false
string text = "Version pilote PB"
end type

type ddlb_dbname from uo_dropdownlistbox within w_login_new
integer x = 567
integer y = 80
integer width = 878
integer height = 848
integer textsize = -8
boolean sorted = false
boolean vscrollbar = true
end type

event selectionchanged;call super::selectionchanged;ii_dbindex = index

end event

type cb_cancel from uo_cb_cancel within w_login_new
string tag = "TEXT_00028"
integer x = 841
integer y = 240
integer width = 366
integer height = 120
integer taborder = 20
string text = "Abandonner"
end type

event clicked;CloseWithReturn(parent, -1)
end event

type cb_ok from uo_cb_ok within w_login_new
string tag = "TEXT_00027"
integer x = 329
integer y = 240
integer width = 366
integer height = 120
integer taborder = 10
end type

event clicked;call super::clicked;IF wf_connect() = 1 THEN
	CloseWithReturn(parent, 1)
ELSE
	CloseWithReturn(parent, -1)
END IF
end event

type st_3 from uo_statictext within w_login_new
string tag = "TEXT_00071"
integer x = 73
integer y = 96
integer width = 475
integer height = 76
string text = "Base de données"
end type

