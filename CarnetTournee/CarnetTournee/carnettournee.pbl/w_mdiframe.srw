forward
global type w_mdiframe from window
end type
type mdi_1 from mdiclient within w_mdiframe
end type
type mdirbb_1 from ribbonbar within w_mdiframe
end type
type mditbb_1 from tabbedbar within w_mdiframe
end type
end forward

global type w_mdiframe from window
integer width = 4937
integer height = 3380
boolean titlebar = true
string title = "Carnet de tournée"
string menuname = "m_base"
boolean controlmenu = true
boolean minbox = true
boolean maxbox = true
boolean resizable = true
windowtype windowtype = mdihelp!
long backcolor = 67108864
string icon = "..\bmp\calendar.ico"
event ue_login ( )
mdi_1 mdi_1
mdirbb_1 mdirbb_1
mditbb_1 mditbb_1
end type
global w_mdiframe w_mdiframe

forward prototypes
public subroutine wf_cleantmp (boolean ab_all)
public function integer wf_init_languesession ()
public function integer wf_init_languetraduction ()
public function integer wf_attempt_reconnect (string as_origine)
end prototypes

event ue_login();integer	li_dockrow, li_offset, li_tbx, li_tby, li_tbwidth, li_tbheight, i
string	ls_truefalse, ls_tbalignment, ls_data, ls_sql
boolean	lb_tbvisible
date		l_dateactu
time		l_timeactu
datetime	l_dateoffi
double	ldb_filesize
long		ll_row, ll_count
uo_wait	lu_wait
uo_fileservices	lu_files
uo_ds		ds_constraints

// fenêtre de logon à la DB
//IF f_login() = -1 THEN
//	gu_message.uf_info("Pas de connexion à la base de données")
//	halt close
//END IF

//// initialisation de la langue dans la session Oracle de la langue du référentiel.
//IF wf_init_langueSession() = -1 THEN
//	halt close
//END IF

// initialiser objet pour traduction de l'application
wf_init_languetraduction()

// lecture nom de l'agent et code service
gs_nomAgent = ""
////select nom, codeservice into :gs_nomAgent, :gs_codeservice from agent where matricule = :gs_username;
////IF f_check_sql(SQLCA) <> 0 THEN
////	populateerror(20000,"")
////	gu_message.uf_unexp("Problème SELECT AGENT")
////	halt close
////END IF

// PCO 01/02/2018 : limiter le code service à 6 caractères pour tronquer au cantonnement quand c'est un
// titulaire de triage qui imprime les documents !
gs_codeservice = left(gs_codeservice, 6)

// lecture nom du service
//gs_nomservice = ""
//select service into :gs_nomservice from service where codeservice = :gs_codeservice;
//IF f_check_sql(SQLCA) <> 0 THEN
//	populateerror(20000,"")
//	gu_message.uf_unexp("Problème SELECT SERVICE")
//	halt close
//END IF

// constituer le titre
This.Title = "Carnet de tournée V" + f_string(gi_currentVersion) + "." +  f_string(gi_minorVersion) + &
				 " - " + gs_nomAgent + " - " + sqlca.userid + "@" + sqlca.database

// rétablir la position des toolbars + paramètres communs à tous les toolbars, par utilisateur (vient du .INI local)
ls_truefalse = upper(ProfileString(gs_locinifile,gs_username,"ToolBarUserControl","False"))
IF ls_truefalse = "TRUE" THEN
	GetApplication().ToolBarUserControl = TRUE
ELSE
	GetApplication().ToolBarUserControl = FALSE
END IF

ls_truefalse = upper(ProfileString(gs_locinifile,gs_username,"ToolBarText","True"))
IF ls_truefalse = "TRUE" THEN
	GetApplication().ToolBarText = TRUE
ELSE
	GetApplication().ToolBarText = FALSE
END IF

ls_truefalse = upper(ProfileString(gs_locinifile,gs_username,"EnterIsTab","True"))
IF ls_truefalse = "TRUE" THEN
	gb_EnterIsTab = TRUE
ELSE
	gb_EnterIsTab = FALSE
END IF

FOR i = 1 TO gi_toolbarscount
	ls_truefalse = upper(ProfileString(gs_locinifile,gs_username,"Toolbar"+string(i)+"Visible","True"))
	IF ls_truefalse = "TRUE" THEN
		lb_tbvisible = TRUE
	ELSE
		lb_tbvisible = FALSE
	END IF
	ls_tbalignment = upper(ProfileString(gs_locinifile,gs_username,"Toolbar"+string(i)+"Alignment",""))
// par défaut, toolbars sont au dessus
	IF ls_tbalignment = "" THEN
		ls_tbalignment = "TOP"
	END IF
	Choose Case ls_tbalignment
		Case "LEFT"
			This.SetToolbar(i, lb_tbVisible, alignatleft!)
		Case "RIGHT"
			This.SetToolbar(i, lb_tbVisible, alignatright!)
		Case "TOP"
			This.SetToolbar(i, lb_tbVisible, alignattop!)
		Case "BOTTOM"
			This.SetToolbar(i, lb_tbVisible, alignatbottom!)
		Case "FLOATING"
			This.SetToolbar(i, lb_tbVisible, floating!)
	End Choose
	li_dockrow = integer(ProfileString(gs_locinifile,gs_username,"Toolbar"+string(i)+"Dockrow","1"))
	li_offset = integer(ProfileString(gs_locinifile,gs_username,"Toolbar"+string(i)+"offset","0"))
	This.SetToolbarPos(i, li_dockrow, li_offset, False)
	li_tbx = integer(ProfileString(gs_locinifile,gs_username,"Toolbar"+string(i)+"x","0"))
	li_tby = integer(ProfileString(gs_locinifile,gs_username,"Toolbar"+string(i)+"y","0"))
	li_tbwidth = integer(ProfileString(gs_locinifile,gs_username,"Toolbar"+string(i)+"width","0"))
	li_tbheight = integer(ProfileString(gs_locinifile,gs_username,"Toolbar"+string(i)+"height","0"))
	This.SetToolbarPos(i, li_tbx, li_tby, li_tbwidth, li_tbheight)
NEXT

// initialiser la gestion des privilèges pour l'utilisateur en cours
//IF gu_privs.uf_initprivs() = -1 THEN
//	halt close
//END IF

// Montrer les points de menu réservés à la cellule informatique. Par défaut, ils sont cachés.
// Le groupe "4" est dans le carnet de tournée celui correspondant à "Maintenance IT"
IF gu_privs.uf_checkgroups({"4"}) THEN
	m_base.mf_showcellinfomsitems()
END IF

//// lecture des paramètres propres à l'application
//select tthebdo, pc_planning, pc_realise 
//	into :gd_tthebdo, :gi_pc_planning, :gi_pc_realise 
//	from params using SQLCA;
//IF f_check_sql(SQLCA) <> 0 THEN
//	populateerror(20000,"")
//	gu_message.uf_unexp("Problème SELECT PARAMS")
//	halt close
//END IF

// convertir temps de travail hebdo stocké en heure et centièmes en nombre de minutes
gi_tthebdo = (truncate(gd_tthebdo, 0) * 60) + (gd_tthebdo - truncate(gd_tthebdo, 0)) * 60

// temps de travail journalier en minutes
gi_ttjour = round(gi_tthebdo / 5, 0)

// 25FEV2016 : timer déclenché toutes les minutes pour vérifier la connexion DB et éventuellement tenter
// une reconnexion. Voir code dans le timer event.
// 21/12/2016 : suppression du timer après migration vers Oracle 12 qui doit être plus stable en télétravail.
// timer(60)

//// lecture du calendrier des jours fériés
//gds_cal_feries.setTransObject(SQLCA)
//gds_cal_feries.retrieve()

// Si la variable 'warning' est TRUE, on affiche la fenêtre d'avertissement (DB de test)
IF gb_warning_db THEN
	open(w_avertissement_db)
END IF

// si utilisateur a accès à w_constraints et que certaines contraintes sont disabled, afficher w_constraints
IF gu_privs.uf_canconsult("w_constraints") = 1 THEN
	ds_constraints = CREATE uo_ds
	ds_constraints.dataobject = "d_constraints"
	ds_constraints.SetTransObject(SQLCA)
	ds_constraints.retrieve()
	FOR ll_row = 1 TO ds_constraints.RowCount()
		IF ds_constraints.object.Status[ll_row] <> "ENABLED" THEN
			opensheet(w_constraints,gw_mdiframe,0,Original!)
			EXIT
		END IF
	NEXT
	DESTROY ds_constraints
END IF

// PCO 02MAR2016
// si utilisateur a accès à w_cal_feries et que le calendrier ne contient aucun jour pour l'année en cours, afficher info
//IF gu_privs.uf_canupdate("w_cal_feries") = 1 THEN
//	select count(*) into :ll_count from cal_feries 
//		where EXTRACT(year FROM dateferie) = EXTRACT(year FROM sysdate) using ESQLCA;
//	IF ESQLCA.sqlnrows=1 AND ll_count=0 THEN
//		gu_message.uf_info("NB : les jours fériés ne sont pas encore encodés pour l'année " + string(year(today())))
//	END IF
//END IF
end event

public subroutine wf_cleantmp (boolean ab_all);// effacer les données éventuellement laissées dans les tables temporaires
// les tables temporaires sont celles qui commencent par T_ et contiennent un n° de session nommé SESSIONID
// NB : certaines tables sont réellement des tables temporaires au sens "ORACLE" et ne contiennent
//      pas nécessairement la colonne SESSIONID. Il ne faut pas s'en occuper, Oracle en supprime
//      le contenu lui-même.
string	ls_tablename, ls_sql
integer	li_stat
uo_wait	lu_wait

// si demande de suppression du contenu des tables temp.toutes sessions confondues, confirmer
IF ab_all THEN
	IF gu_message.uf_query("Confirmez-vous la suppression des données temporaires de toutes les sessions ?") = 2 THEN
		return
	END IF
END IF

lu_wait = CREATE uo_wait
lu_wait.uf_openwindow()
DECLARE cur_temptables CURSOR FOR
	select table_name from user_tables where table_name like 'T\_%' escape '\' 
		AND temporary = 'N' USING SQLCA;
OPEN cur_temptables;
// boucle sur les tables sélectionnées pour effacer les données que la session en cours aurait laissées
// 11/09/2002 : si ab_all = TRUE, supprimer toutes les données des tables T_***, pas seulement celles
//					 de la session en cours
FETCH cur_temptables INTO :ls_tablename;
li_stat = f_check_sql(SQLCA)
DO WHILE li_stat = 0
	lu_wait.uf_addinfo("suppression données " + ls_tablename)
	IF ab_all THEN
		ls_sql = "truncate table " + ls_tablename
	ELSE
		ls_sql = "delete from " + ls_tablename + " where sessionid = " + string(gd_session)
	END IF
	EXECUTE IMMEDIATE :ls_sql USING ESQLCA;
	IF f_check_sql(ESQLCA) = 0 THEN
		commit USING ESQLCA;
	ELSE
		rollback USING ESQLCA;
	END IF
	FETCH cur_temptables INTO :ls_tablename;
	li_stat = f_check_sql(SQLCA)
LOOP
CLOSE cur_temptables;
lu_wait.uf_closewindow()
DESTROY lu_wait
end subroutine

public function integer wf_init_languesession ();// Initialisation de la langue dans les sessions Oracle de la langue du référentiel.
string	ls_sql

ls_sql = "execute DNF_vars.setLangue('" + gs_langue + "')"
execute immediate :ls_sql using SQLCA;
IF f_check_sql(SQLCA) <> 0 THEN
	populateerror(20000,"")
	gu_message.uf_unexp("SQLCA : Problème exec procédure - " + f_string(ls_sql))
	return(-1)
END IF

execute immediate :ls_sql using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	populateerror(20000,"")
	gu_message.uf_unexp("ESQLCA : Problème exec procédure - " + f_string(ls_sql))
	return(-1)
END IF

return(1)

end function

public function integer wf_init_languetraduction ();IF gu_translate.uf_setlanguage(gs_langue) < 0 THEN
	return(-1)
ELSE
	// traduction du menu
	gu_translate.uf_translateMenu(m_base)
	// Traductions des textes dans gu_dwservices car il est instancié au lancement de l'application,
	// ce qui est trop tôt pour les traductions...
	gu_dwservices.uf_translateText()
	return(1)
END IF
end function

public function integer wf_attempt_reconnect (string as_origine);// PCO FEV 2016
// Tentative de reconnexion à la DB après perte de connexion
// argument as_origine 
//		T si appel par le timer
//		M si appel manuel par le menu
// return(1) si OK
// return(-1) si erreur
integer	li_test
uo_Wait	lu_wait
window	ActiveSheet

// vérification de la connexion et demande de confirmation si elle est toujours fonctionnelle
select 1 into :li_test from dual using SQLCA;
IF SQLCA.sqlcode <> -1 THEN
	IF as_origine = "M" THEN
		IF gu_message.uf_query("La connexion semble toujours fonctionnelle.~n" + &
					"Voulez-vous néanmoins la réinitialiser, au risque de perdre certaines données ?", YesNo!, 2) = 2 THEN
			return(1)
		END IF
	ELSE
		return(1)
	END IF
END IF

lu_wait = CREATE uo_wait

lu_wait.uf_addinfo("Connexion en cours vers " + sqlca.database)

// "déconnexion" des connexions perdues
disconnect using sqlca;
disconnect using esqlca;

// reconnexion
connect using sqlca;
if sqlca.sqlcode <> 0 then
	DESTROY lu_wait
	gu_message.uf_error("SQLCA", "Impossible de se connecter à la base de données : ~n" + sqlca.sqlerrtext, StopSign!)
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
	gu_message.uf_error("ESQLCA", "Impossible de se connecter à la base de données : ~n" + esqlca.sqlerrtext, StopSign!)
	return(-1)
else
	execute immediate "alter session set NLS_LANGUAGE = French" USING ESQLCA;
	execute immediate "alter session set nls_date_format='DD/MM/YYYY'" USING ESQLCA;
	execute immediate "alter session set nls_numeric_characters=', '" USING ESQLCA;
	execute immediate "alter session set NLS_SORT = Binary" USING ESQLCA;
end if

// Parcourrir les fenêtres ouvertes et y exécuter l'event pour reconnecter les DW, DS etc à SQLCA
// NB : cet event doit être créé et codé explicitement par le développeur !
ActiveSheet = this.GetFirstSheet()
DO WHILE IsValid(ActiveSheet)
   ActiveSheet.event DYNAMIC ue_attempt_reconnect()
	ActiveSheet = this.GetNextSheet(ActiveSheet)
LOOP

DESTROY lu_wait
return(1)
end function

on w_mdiframe.create
if this.MenuName = "m_base" then this.MenuID = create m_base
this.mdi_1=create mdi_1
this.mditbb_1=create mditbb_1
this.mdirbb_1=create mdirbb_1
this.Control[]={this.mdi_1,&
this.mditbb_1,&
this.mdirbb_1}
end on

on w_mdiframe.destroy
if IsValid(MenuID) then destroy(MenuID)
destroy(this.mdi_1)
destroy(this.mdirbb_1)
destroy(this.mditbb_1)
end on

event open;integer	li_width, li_height, li_x, li_y, li_defaultWidth, li_defaultHeight

// initialiser pointeur vers la fenêtre MDI-FRAME
gw_mdiframe = This

// dimension originale de la fenêtre MDI
li_defaultWidth = 4300
li_defaultHeight = 2900

// rétablir position et dimensions de la fenêtre MDIFRAME
This.WindowState = Normal!

// PCO 08/03/2017 : utiliser fonction de calcul de la taille et position de la fenêtre MDI
f_getMdiPosAndSize(li_defaultWidth, li_defaultHeight, li_width, li_height, li_x, li_y)
This.x = li_x
This.y = li_y
This.width = li_width
This.height = li_height

// nombre de toolbars
gi_toolbarscount = 3

// place tous les toolbars sur la 1ère ligne (dans l'ordre inverse de celui souhaité 
// car les suivants vont s'intercaller) + leur donne un nom

// NB : tout ceci n'est utile que pour donner un nom à chaque toolbar et
// pour que l'aspect des toolbars soit correct avant le login
This.SetToolbar(3, true, AlignAtTop!, "Actions")
This.SetToolbarPos(3, 1, 0, False)

This.SetToolbar(2, true, AlignAtTop!, "Fenêtres")
This.SetToolbarPos(2, 1, 0, False)

This.SetToolbar(1, true, AlignAtTop!, "Fichier")
This.SetToolbarPos(1, 1, 0, False)

// PCO 24/03/2017
// Appel de la fonction de configuration du menu propre au carnet de tournée.
m_base.mf_carnet_spec()

This.Event post ue_login()

end event

event close;integer				li_nbAvailItems, li_dockrow, li_offset, li_tbx, li_tby, li_tbwidth, li_tbheight, i
toolbaralignment	lal_tbalignment
string				ls_tbalignment
boolean				lb_tbvisible

// conserver dans fichier INI et par utilisateur les options en cours (dans .INI local)
// 1. position des toolbars + paramètres communs à tous les toolbars
SetProfileString(gs_locinifile,gs_username,"ToolBarUserControl",string(GetApplication().ToolBarUserControl))
SetProfileString(gs_locinifile,gs_username,"ToolBarText",string(GetApplication().ToolBarText))

FOR i = 1 TO gi_toolbarscount
	This.GetToolbar(i, lb_tbvisible, lal_tbalignment)
	This.getToolbarPos(i, li_dockrow, li_offset)
	This.getToolbarPos(i, li_tbx, li_tby, li_tbwidth, li_tbheight)
	Choose Case lal_tbalignment
		Case alignatleft!
			ls_tbalignment = "Left"
		Case alignatright!
			ls_tbalignment = "Right"
		Case alignattop!
			ls_tbalignment = "Top"
		Case alignatbottom!
			ls_tbalignment = "Bottom"
		Case floating!
			ls_tbalignment = "Floating"

	End Choose
	SetProfileString(gs_locinifile,gs_username,"Toolbar"+string(i)+"Visible",string(lb_tbvisible))
	SetProfileString(gs_locinifile,gs_username,"Toolbar"+string(i)+"Alignment",ls_tbalignment)
	SetProfileString(gs_locinifile,gs_username,"Toolbar"+string(i)+"DockRow",string(li_dockrow))
	SetProfileString(gs_locinifile,gs_username,"Toolbar"+string(i)+"Offset",string(li_offset))
	SetProfileString(gs_locinifile,gs_username,"Toolbar"+string(i)+"x",string(li_tbx))
	SetProfileString(gs_locinifile,gs_username,"Toolbar"+string(i)+"y",string(li_tby))
	SetProfileString(gs_locinifile,gs_username,"Toolbar"+string(i)+"width",string(li_tbwidth))
	SetProfileString(gs_locinifile,gs_username,"Toolbar"+string(i)+"height",string(li_tbheight))	
NEXT

// 2. position et dimensions de la fenêtre MDIFRAME
IF This.WindowState <> Minimized! THEN
	SetProfileString(gs_locinifile,gs_username,"MDIHeight", string(This.height))
	SetProfileString(gs_locinifile,gs_username,"MDIWidth", string(This.width))
	SetProfileString(gs_locinifile,gs_username,"MDIx", string(This.x))
	SetProfileString(gs_locinifile,gs_username,"MDIy", string(This.y))
END IF

// 3. effacer les données éventuellement laissées dans les tables temporaires
//wf_cleantmp(FALSE)

end event

event timer;// PCO 21/12/2016 : suppression de la reconnexion automatique suite à la migration vers Oracle 12 qui
// doit être plus stable en télétravail.
// wf_attempt_reconnect("T")
end event

type mdi_1 from mdiclient within w_mdiframe
long BackColor=268435456
end type

type mdirbb_1 from ribbonbar within w_mdiframe
int X=0
int Y=0
int Width=0
int Height=596
end type

type mditbb_1 from tabbedbar within w_mdiframe
int X=0
int Y=0
int Width=0
int Height=104
end type

