forward
global type w_mdiframe from window
end type
type mdi_1 from mdiclient within w_mdiframe
end type
type mditbb_1 from tabbedbar within w_mdiframe
end type
type mdirbb_1 from ribbonbar within w_mdiframe
end type
end forward

global type w_mdiframe from window
integer width = 4366
integer height = 3080
boolean titlebar = true
string title = "Comptoir forestier"
string menuname = "m_base"
boolean controlmenu = true
boolean minbox = true
boolean maxbox = true
boolean resizable = true
windowtype windowtype = mdihelp!
long backcolor = 67108864
string icon = "AppIcon!"
event ue_login ( )
mdi_1 mdi_1
mditbb_1 mditbb_1
mdirbb_1 mdirbb_1
end type
global w_mdiframe w_mdiframe

forward prototypes
public subroutine wf_cleantmp (boolean ab_all)
end prototypes

event ue_login();integer	li_dockrow, li_offset, li_tbx, li_tby, li_tbwidth, li_tbheight, i
string	ls_filiere, ls_truefalse, ls_tbalignment, ls_data
boolean	lb_tbvisible
date		l_dateactu
time		l_timeactu
datetime	l_dateoffi
double	ldb_filesize
long		ll_row
uo_wait	lu_wait
uo_fileservices	lu_files
uo_ds		ds_constraints

// fenêtre de logon à la DB
IF f_login() = -1 THEN
	gu_message.uf_info("Pas de connexion à la base de données")
	halt close
END IF

// lecture code service et du n° d'interlocuteur qui représente le Comptoir lui-même
select codeservice, locu_cpt into :gs_codeservice, :gs_locucpt from params using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	populateerror(20000,"")
	gu_message.uf_unexp("Problème SELECT PARAMS")
	halt close
END IF
IF f_IsEmptyString(gs_codeservice) THEN
	gu_message.uf_error("Veuillez spécifier le code service qui représente le Comptoir (table PARAMS)")
	halt close
END IF
IF f_IsEmptyString(gs_locucpt) THEN
	gu_message.uf_error("Veuillez spécifier le n° d'interlocuteur qui représente le Comptoir (table PARAMS)")
	halt close
END IF

// lecture nom du service
gs_nomservice = ""
select service into :gs_nomservice from service where codeservice = :gs_codeservice;
IF f_check_sql(SQLCA) <> 0 THEN
	populateerror(20000,"")
	gu_message.uf_unexp("Problème SELECT SERVICE")
	halt close
END IF

// lire le nom d'interlocuteur qui représente le Comptoir lui-même
select interlocuteur into :ls_data from interlocuteur where locu=:gs_locucpt using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	populateerror(20000,"")
	gu_message.uf_unexp("Le n° d'interlocuteur (n° " + f_string(gs_locucpt) + &
							  ") paramétré dans PARAMS pour représenter le Comptoir n'existe pas.")
	halt close
END IF

This.Title = gs_nomservice + " - " + sqlca.userid + "@" + sqlca.database

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

// rétablir le menu de la dernière filière utilisée par l'utilisateur (vient du .INI local)
ls_filiere = ProfileString(gs_locinifile,gs_username,"Filière","")
IF NOT f_IsEmptyString(ls_filiere) THEN
	this.menuid.DYNAMIC mf_CheckFiliere(ls_filiere)
	this.menuid.DYNAMIC mf_ChangeMenu(ls_filiere)
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
IF gu_privs.uf_initprivs() = -1 THEN
	halt close
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

filedelete(gs_cenpath + "\version.txt")

// ajout 25/05/2011 : création entrée ODBC EFOR
// pco 2013 : ne plus utiliser ODBC mais un fichier Excel (voir f_fusion_word)
//wf_cree_odbc_efor()

// PCO 07/01/2013 - workaround, bug à poursuivre !
uo_ds	lds_1
lds_1 = CREATE uo_ds
lds_1.dataobject = 'd_registre_flux'
lds_1.setTransObject(SQLCA)
lds_1.retrieve("LDE11001")
DESTROY lds_1
end event

public subroutine wf_cleantmp (boolean ab_all);// effacer les données éventuellement laissées dans les tables temporaires
// les tables temporaires sont celles qui commencent par T_ et contiennent un n° de session nommé SESSIONID
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
	select table_name from user_tables where table_name like 'T\_%' escape '\' USING SQLCA;
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
destroy(this.mditbb_1)
destroy(this.mdirbb_1)
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
gi_toolbarscount = 4

// place tous les toolbars sur la 1ère ligne (dans l'ordre inverse de celui souhaité 
// car les suivants vont s'intercaller) + leur donne un nom

// NB : tout ceci n'est utile que pour donner un nom à chaque toolbar et
// pour que l'aspect des toolbars soit correct avant le login
This.SetToolbar (4, true, AlignAtTop!,"Filières")
This.SetToolbarPos (4, 1, 0, False)

This.SetToolbar (3, true, AlignAtTop!,"Actions")
This.SetToolbarPos (3, 1, 0, False)

This.SetToolbar (2, true, AlignAtTop!,"Fenêtres")
This.SetToolbarPos (2, 1, 0, False)

This.SetToolbar (1, true, AlignAtTop!,"Fichier")
This.SetToolbarPos (1, 1, 0, False)

This.Event post ue_login()

end event

event close;integer				li_nbAvailItems, li_dockrow, li_offset, li_tbx, li_tby, li_tbwidth, li_tbheight, i
toolbaralignment	lal_tbalignment
string				ls_tbalignment
boolean				lb_tbvisible

// conserver dans fichier INI et par utilisateur les options en cours (dans .INI local)
// 1. filière en cours
li_nbAvailItems = upperbound(this.menuid.item[gi_pchoixfiliere].item)
FOR i = 1 TO li_nbAvailItems
	IF this.menuid.item[gi_pchoixfiliere].item[i].checked THEN
		SetProfileString(gs_locinifile,gs_username,"Filière",this.menuid.item[gi_pchoixfiliere].item[i].classname())
	END IF
NEXT

// 2. position des toolbars + paramètres communs à tous les toolbars
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

// 3. position et dimensions de la fenêtre MDIFRAME
IF This.WindowState <> Minimized! THEN
	SetProfileString(gs_locinifile,gs_username,"MDIHeight", string(This.height))
	SetProfileString(gs_locinifile,gs_username,"MDIWidth", string(This.width))
	SetProfileString(gs_locinifile,gs_username,"MDIx", string(This.x))
	SetProfileString(gs_locinifile,gs_username,"MDIy", string(This.y))
END IF

// 4. effacer les données éventuellement laissées dans les tables temporaires
wf_cleantmp(FALSE)

end event

type mdi_1 from mdiclient within w_mdiframe
long BackColor=268435456
end type

type mditbb_1 from tabbedbar within w_mdiframe
int X=0
int Y=0
int Width=0
int Height=104
end type

type mdirbb_1 from ribbonbar within w_mdiframe
int X=0
int Y=0
int Width=0
int Height=596
end type

