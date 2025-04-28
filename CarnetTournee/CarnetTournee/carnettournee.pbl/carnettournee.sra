//objectcomments Generated Application Object
forward
global type carnettournee from application
end type
global transaction sqlca
global dynamicdescriptionarea sqlda
global dynamicstagingarea sqlsa
global uo_error error
global message message
end forward

global variables
// variables globales communes à toutes les applications
string	gs_shell, gs_inifile, gs_locinifile, gs_helpfile, gs_errorlog, gs_serviceIniFile, &
			gs_usagelog, gs_username, gs_computername, gs_tmpfiles, gs_startpath, gs_cenpath, &
			gs_dbname, gs_dbalias, gs_domain, gs_codeservice, gs_nomservice, gs_MyDocuments, gs_osversion, &
			gs_CryptKey, gs_dbdesc
string	gs_envapp	// PCO 09/01/2017 : environnement Production (P) ou Développement/Tests (T)
string	gs_ExchangePwd	// PCO 07/08/2019 : mot de passe à demander à l'utilisateur s'il utilise un transfert vers Outlook
string	gs_boldDBAlias, gs_bolduser, gs_boldpwd	// PCO 13/05/2022 : dbalias/user/pwd connexion schéma BOLD
long	gl_keys_bckg_color=16763035, gl_browse_even_bckg_color, gl_browse_odd_bckg_color, &
		gl_mandatory_bckg_color=14483455, gl_disabled_bckg_color=12632256, gl_lptgrey=13158600
decimal{0}	gd_session=1, gd_sequence=0
boolean	gb_sort_ASC=true, gb_sqlspy_on, gb_EnterIsTab, gb_warning_db
integer	gi_toolbarscount, gi_zoomsize, gi_pchoixfiliere

w_mdiframe		gw_mdiframe
uo_message		gu_message
uo_logmessage	gu_logmessage
uo_dwservices	gu_dwservices
uo_stringservices	gu_stringservices
uo_datetime		gu_datetime
uo_constantes	gu_c
uo_db				gu_db
uo_applprivs	gu_privs
transaction		ESQLCA

// UO pour la traduction de l'application
uo_translate	gu_translate

// variables globales spécifiques à l'application
string		gs_nomAgent	// nom de l'utilisateur (gs_username est en réalité le logname...)
decimal{2}	gd_tthebdo	// temps de travail hebdomadaire en heures et centièmes d'heures
integer		gi_tthebdo  // temps de travail hebdomadaire en minutes
integer		gi_ttjour   // temps de travail journalier en minutes
integer		gi_pc_planning, gi_pc_realise // % minimum du temps de travail qui doit être planifié ou réalisé pour pouvoir valider la semaine
string		gs_langue	// langue à utiliser pour le référentiel (F/D)
integer		gi_currentVersion	// major version number : 4 à partir du nouveau référentiel (NOV2015)
integer		gi_minorVersion	// minor version number : 0 pour la 1ère release, incrémenter ensuite.
integer		gi_dataVersion_planning
integer		gi_dataVersion_realise
uo_ds			gds_cal_feries		// DS contenant les jours fériés
boolean		gb_autoSelectRow	// mise en évidence ou pas de l'activité sélectionnée

end variables

global type carnettournee from application
string appname = "carnettournee"
string themepath = "C:\Program Files (x86)\Appeon\PowerBuilder 22.0\IDE\theme"
string themename = "Do Not Use Themes"
boolean nativepdfvalid = true
boolean nativepdfincludecustomfont = false
string nativepdfappname = ""
long richtextedittype = 5
long richtexteditx64type = 5
long richtexteditversion = 3
string richtexteditkey = ""
string appicon = "..\bmp\calendar.ico"
string appruntimeversion = "25.0.0.3674"
boolean manualsession = false
boolean unsupportedapierror = false
boolean ultrafast = false
boolean bignoreservercertificate = false
uint ignoreservercertificate = 0
long webview2distribution = 0
boolean webview2checkx86 = false
boolean webview2checkx64 = false
string webview2url = "https://developer.microsoft.com/en-us/microsoft-edge/webview2/"
integer highdpimode = 0
end type
global carnettournee carnettournee

type prototypes
SUBROUTINE keybd_event(int bVk, int bScan, int dwFlags, int dwExtraInfo) LIBRARY "user32.dll"
FUNCTION boolean Beep(ulong dwFreq, ulong dwDuration)  LIBRARY "kernel32.dll"
FUNCTION boolean PeekMessageA(ref blob lpMsg, long hWnd, UINT uMsgFilterMin, UINT uMsgFilterMax, UINT wRemoveMsg) LIBRARY "user32.dll"
FUNCTION boolean GetComputerNameA(REF string lpBuffer, REF ulong lpnSize) LIBRARY "kernel32.dll" alias for "GetComputerNameA;Ansi"
FUNCTION boolean GetUserNameA(REF string  lpBuffer, REF ulong nSize) LIBRARY "ADVAPI32.DLL" alias for "GetUserNameA;Ansi"
FUNCTION long GetTempPath(long nBufferLength, ref string lpBuffer) LIBRARY "kernel32.dll" ALIAS FOR "GetTempPathA;Ansi"
FUNCTION ulong SendMessageTimeoutA(ulong hwnd, ulong msg, ulong wparam, string lparam, ulong flags, ulong timeout, ref ulong result) library "USER32.DLL" alias for "SendMessageTimeoutA;Ansi"
FUNCTION integer GetSystemMetrics ( int nIndex ) LIBRARY "user32.dll" 
FUNCTION Boolean WritePrivateProfileStringA( string s_Section, string s_Entry, string s_String, string s_Filename) Library "Kernel32.dll" ALIAS FOR "WritePrivateProfileStringA;Ansi"
FUNCTION ULONG ShellExecute( ulong hwdn, string operation, string file, string params, string parth, long nShowCmd) Library "shell32.dll" Alias For "ShellExecuteW"

end prototypes

on carnettournee.create
appname="carnettournee"
message=create message
sqlca=create transaction
sqlda=create dynamicdescriptionarea
sqlsa=create dynamicstagingarea
error=create uo_error
end on

on carnettournee.destroy
destroy(sqlca)
destroy(sqlda)
destroy(sqlsa)
destroy(error)
destroy(message)
end on

event systemerror;integer	li_reponse

IF LenA(error.text) <= 0 THEN error.text = "Erreur d'exécution"

CHOOSE CASE error.number
	// erreurs provoquées par le programmeur (via fonction signalerror() )
	CASE 20000 TO 30000
		gu_message.uf_unexp("Erreur de l'application. ~r~nFaut-il stopper l'application (conseillé) ?", 3, TRUE, 2)
		li_reponse = integer(message.doubleparm)
		IF li_reponse = 1 THEN
			Halt close
		END IF
	
	// autres erreurs provoquées par PB : demande s'il faut arrêter l'application ou pas (normalement c'est préférable)
	CASE ELSE
		gu_message.uf_unexp("Erreur système. ~r~nFaut-il stopper l'application (conseillé) ?", 4, TRUE, 2)
		li_reponse = integer(message.doubleparm)
		IF li_reponse = 1 THEN
			Halt close
		END IF
END CHOOSE

end event

event open;ulong		lul_maxlen
string	ls_dtreg, ls_reg, ls_delPB, ls_commandline, ls_theme, ls_pbrtsPath
boolean	lb_wmodif
uo_fileservices	lu_files
environment			le_env
OleObject	l_wsh
Integer		li_rc

ESQLCA = CREATE transaction

// version : 2 à partir des modif de MARS 2015 (hdeb et hfin obligatoires)
// version : 3 à partir des modif de JUILLET 2015
// version : 4 à partir du nouveau référentiel (NOV 2015 ?)
gi_currentVersion = 4

// minor version : 0 pour installation du 4/12/2015, 1ère release V4
// Version 1, probablement xxJAN2016
// Version 2, 9 MARS 2016
// Version 3, 22 MARS 2016
// Version 4, 6 AVRIL 2016
// Version 5, 10 MAI 2016
// Version 6, à partir du 24 NOV 2016
// Version 7 : environ 10 mars 2017
// Version 8 : 30 juin 2017 - recto déclarations de créances
gi_minorversion = 8

// version des données
gi_dataVersion_planning = 5
gi_dataVersion_realise = 4

// UO utilitaires traitement de fichiers
lu_files = CREATE uo_fileservices

// UO pour la traduction de l'application
gu_translate = CREATE uo_translate

// clé de cryptage pour objet uo_encrypt
gs_CryptKey = "ci617"

// déterminer la version de l'OS
IF GetEnvironment(le_env) = 1 THEN
	IF le_env.OSType = WindowsNT! THEN
		CHOOSE CASE le_env.OSMajorRevision
			CASE 5
				CHOOSE CASE le_env.OSMinorRevision
					CASE 0
						gs_osversion = "2000"
					CASE 1
						gs_osversion = "XP"
				END CHOOSE
			CASE 6
				CHOOSE CASE le_env.OSMinorRevision
					CASE 0
						gs_osversion = "VISTA"
					CASE 1
						gs_osversion = "Seven"
				END CHOOSE
			CASE ELSE
				gs_osversion = "NT"
		END CHOOSE
	END IF
END IF
IF f_isEmptyString(gs_osversion) THEN gs_osversion = "?"

// créer objet 'constantes'
gu_c = CREATE uo_constantes

// créer objet message
gu_message = CREATE uo_message

// créer objet "services liés aux DW"
gu_dwservices = CREATE uo_dwservices

// créer objet "services liés aux strings"
gu_stringservices = CREATE uo_stringservices

// créer objet "utilitaires date/datetime"
gu_datetime = CREATE uo_datetime

// créer objet contenant les fonctions utilitaires DB
gu_db = CREATE uo_db

// créer objet contenant la gestion des privilèges
gu_privs = CREATE uo_applprivs

// créer objet contenant les fonctions de gestion des fichiers de log
gu_logmessage = CREATE uo_logmessage

// récupérer le dossier d'où on a lancé l'application
gs_startpath = GetCurrentDirectory()

// récupérer le nom de la machine
lul_maxlen = 255
gs_computername = Space(lul_maxlen)
IF GetComputerNameA(gs_computername, lul_maxlen) THEN
	gs_computername = upper(gs_computername)
ELSE
	gs_computername = "???????"
END IF

// récupérer le nom de l'utilisateur
lul_maxlen = 255
gs_username = space(lul_maxlen)
IF GetUserNameA (gs_username, lul_maxlen) THEN 
	gs_username = upper(gs_username)
ELSE
	gs_username = "???????"
END IF

// récupérer le nom de domaine
l_wsh = CREATE OleObject
li_rc = l_wsh.ConnectToNewObject( "WScript.Network" )
IF li_rc = 0 THEN
	gs_domain = l_wsh.UserDomain
ELSE
	gu_message.uf_error("Impossible de lire le nom de domaine")
	halt close
END IF

// récupérer le dossier temporaire de Windows
lul_maxlen = 255
gs_tmpfiles = Space(lul_maxlen)
IF GetTempPath(lul_maxlen, gs_tmpfiles) <= 0 THEN
	gs_tmpfiles = "C:\TEMP"
ELSE
	gs_tmpfiles = LeftA(gs_tmpfiles, LenA(gs_tmpfiles) - 1)
END IF

// récupérer le nom du dossier personnel de l'utilisateur
IF RegistryGet("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders", "Personal", RegString!, gs_MyDocuments) = -1 THEN
	gs_MyDocuments = "D:\"
END IF

// vérifier que la date est configurée en dd/MM/yyyy dans Windows
RegistryGet("HKEY_CURRENT_USER\Control Panel\International", "sShortDate", RegString!, ls_dtreg) 
ls_dtreg = upper(ls_dtreg)
IF ls_dtreg <> "DD/MM/YYYY" THEN
	ls_dtreg = "dd/MM/yyyy"
	IF RegistrySet("HKEY_CURRENT_USER\Control Panel\International", "sShortDate", RegString!, ls_dtreg) = 1 THEN
		lb_wmodif = TRUE
	ELSE
		gu_message.uf_error("Le paramètre régional Windows 'Style de date courte' n'a pas pû être modifié en jj/MM/aaaa")
		halt close
	END IF
END IF

// vérifier que le séparateur des milliers est l'espace
RegistryGet("HKEY_CURRENT_USER\Control Panel\International", "sThousand", RegString!, ls_reg) 
IF ls_reg <> " " THEN
	IF RegistrySet("HKEY_CURRENT_USER\Control Panel\International",  "sThousand", RegString!, " ") = 1 THEN
		lb_wmodif = TRUE
	ELSE
		gu_message.uf_error("Le paramètre régional Windows 'Symbole de groupement des chiffres' n'a pas pû être remplacé par l'espace")
		halt close
	END IF
END IF

// vérifier que le sigle monétaire est l'Euro
RegistryGet("HKEY_CURRENT_USER\Control Panel\International", "sCurrency", RegString!, ls_reg) 
IF ls_reg <> "€" THEN
	IF RegistrySet("HKEY_CURRENT_USER\Control Panel\International",  "sCurrency", RegString!, "€") = 1 THEN
		lb_wmodif = TRUE
	ELSE
		gu_message.uf_error("Le paramètre régional Windows 'Symbole monétaire' n'a pas pû être remplacé par '€'")
		halt close
	END IF
END IF

// vérifier que le séparateur décimal est la virgule
RegistryGet("HKEY_CURRENT_USER\Control Panel\International", "sDecimal", RegString!, ls_reg) 
IF ls_reg <> "," THEN
	IF RegistrySet("HKEY_CURRENT_USER\Control Panel\International",  "sDecimal", RegString!, ",") = 1 THEN
		lb_wmodif = TRUE
	ELSE
		gu_message.uf_error("Le paramètre régional Windows 'Symbole décimal' n'a pas pû être remplacé par ','")
		halt close
	END IF
END IF

// si un paramètre windows a été modifié, il faut relancer l'application pour en tenir compte
IF lb_wmodif THEN
	gu_message.uf_info("Certains paramètres Windows ont été modifiés. Veuillez relancer l'application.")
	halt close
END IF

// récupérer l'argument passé lors du lancement de l'application, qui contient le dossier où se trouvent
// les fichiers .INI et .LOG (fichiers identiques pour tous les PC)
// NB : supprimer l'argument éventuel '/pbdebug' qui permet de générer un trace file
ls_commandline = gu_stringservices.uf_replaceall(commandline, "/pbdebug", "")
gs_cenpath = trim(ls_commandline)
IF f_IsEmptyString(gs_cenpath) THEN
	gs_cenpath = gs_startpath
	gu_message.uf_error("Le dossier contenant les fichiers .INI et .LOG n'est pas spécifié.~n~n" + &
							  "Le dossier " + gs_startpath + " va être utilisé.~nCette situation est " + &
							  "normale en développement mais pas en exploitation !")
END IF

// initialiser variable globale contenant le path et le nom du fichier .INI commun (le même sur tous les postes)
gs_inifile = f_string(gs_cenpath + "\carnet.ini")

// initialiser variable globale contenant le path et le nom du fichier .INI local pour le site
gs_locinifile = f_string(gs_cenpath + "\carnetloc.ini")

// fichier INI service = .ini local
gs_serviceinifile = gs_locinifile

// si fichier .INI global n'existe pas, erreur
IF NOT fileExists(gs_inifile) THEN
	gu_message.uf_error("", "Le fichier de configuration " + gs_inifile + " est introuvable.~n~nL'application ne peut continuer.")
	halt close
END IF

// si fichier .INI local n'existe pas, le créer
IF NOT fileExists(gs_locinifile) THEN
	lu_files.uf_writefile ("#", gs_locinifile)
END IF

// initialiser variable globale contenant le path et le nom du fichier des aides microhelp.INI
gs_helpfile = gs_cenpath + "\carnethelp.ini"

// initialiser variable globale contenant le path et le nom du fichier de log des erreurs
gs_errorlog = gs_cenpath + "\" + ProfileString(gs_inifile,"misc","logerror","error.log")

// initialiser variable globale contenant le nom du programme de commande (shell)
gs_shell = f_getenvvar("windir") + "\system32\cmd.exe /c"

// initialiser variable globale contenant la taille minimum des champs caractères pour afficher fenêtre Zoom 
gi_zoomsize = integer(ProfileString(gs_inifile,"misc","zoomsize","20"))

// initialiser variable globale indiquant la langue à utiliser pour le référentiel (F/D)
gs_langue = upper(ProfileString(gs_locinifile, gs_username, "langue", "F"))

// PCO 31/10/2016 : initialiser variable globale du choix de l'utilisateur concernant la mise en évidence
// de la prestation sélectionnée
IF upper(ProfileString(gs_locinifile, gs_username, "AutoSelectRow", "false")) = "TRUE" THEN
	gb_autoSelectRow = TRUE
ELSE
	gb_autoSelectRow = FALSE
END IF

// variable donnant le n° du point de menu où on choisit la filière (si utilisé)
// gi_pchoixfiliere = 3

// calculer la couleur de fond par défaut des keys sur base du paramètre du fichier .INI
gl_keys_bckg_color = f_color_from_inifile("colors","keys_background")

// calculer la couleur de fond par défaut des items obligatoires sur base du paramètre du fichier .INI
gl_mandatory_bckg_color = f_color_from_inifile("colors","mandatory_background")

// calculer la couleur de fond par défaut des items disablés sur base du paramètre du fichier .INI
gl_disabled_bckg_color = f_color_from_inifile("colors","disabled_background")

// calculer la couleur des lignes paires et impaires dans les DW multi-occurences
gl_browse_even_bckg_color = f_color_from_inifile("colors","browse_even")
gl_browse_odd_bckg_color = f_color_from_inifile("colors","browse_odd")

// calculer la couleur de fond pour mise en évidence d'une ligne à l'imprimante
gl_lptgrey = f_color_from_inifile("colors","lptgrey")

// Suppression anciens runtimes : ne fonctionne que si dossier d'installation du RTS est D:\DnfAPPL\pbrts
ls_pbrtsPath = "D:\DnfAPPL\pbrts"

// voir s'il faut supprimer certaines versions du runtime PB sur le PC client
ls_delPB = ProfileString(gs_inifile, "misc", "DelPB125", "FALSE")
ls_delPB = ProfileString(gs_LOCinifile, "misc", "DelPB125", ls_delPB)
IF upper(ls_delPB) = "TRUE" THEN
	lu_files.uf_deletefile_pattern(ls_pbrtsPath, "*125.*")
END IF

ls_delPB = ProfileString(gs_inifile, "misc", "DelPB170", "FALSE")
ls_delPB = ProfileString(gs_LOCinifile, "misc", "DelPB170", ls_delPB)
IF upper(ls_delPB) = "TRUE" THEN
	lu_files.uf_deletefile_pattern(ls_pbrtsPath, "*170.*")
END IF

// stockage du calendrier des jours fériés (lecture après connexion)
gds_cal_feries = CREATE uo_ds
gds_cal_feries.dataobject = "ds_cal_feries"

// appliquer le thème éventuel
ls_theme = ProfileString(gs_locinifile, gs_username, "theme", "Aucun")
IF upper(ls_theme) <> "AUCUN" THEN
	ApplyTheme("..\pbrts\themes\" + ls_theme)
END IF

DESTROY lu_files

// ouvrir frame MDI
open(w_mdiframe)

end event

event close;IF IsValid(SQLCA) THEN 
	disconnect using sqlca;
END IF
IF IsValid(ESQLCA) THEN 
	disconnect using esqlca;
	DESTROY esqlca
END IF

DESTROY gu_translate
DESTROY gu_message
DESTROY gu_dwservices
DESTROY gu_stringservices
DESTROY gu_datetime
DESTROY gu_c
DESTROY gu_db
DESTROY gu_privs
DESTROY gu_logmessage
DESTROY gds_cal_feries
end event

