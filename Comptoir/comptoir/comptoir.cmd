@echo off
cls
REM Le dossier en cours doit être le dossier qui contient les programmes de l'application.
REM Les .DLL du runtime PowerBuilder doivent se trouver dans le dossier local spécifié par 
REM     la variable de script PBRTS (normalement d:\pbrts).
REM Les nouvelles versions doivent être copiées soit directement dans le dossier %1, soit
REM     dans le sous-dossier %1%\Upgrade.Dans ce cas, le fichier version.txt indique la présence d'une mise à jour.
REM
REM argument %1 (obligatoire) = le dossier où se trouvent la version officielle des fichiers sur le serveur 
REM                             (source de la synchronization) ET les fichiers .INI 
REM                             ("global" pour tous les sites et "local" propre au site).
REM argument %2 (obligatoire) = le dossier où se trouvent la version officielle des .DLL du runtime PB sur le serveur 
REM                             (source de la synchronization du runtime)
REM argument %3 (facultatif) = le dossier où se trouve le runtime PB en local si <> d:\pbrts 
REM argument %4 (facultatif) = le dossier où se trouvent les exécutables oracle si <> de ceux prévus (voir variable ORABIN)

REM exemple de raccourci : comptoir.cmd o:\comptoir o:\pbrts
REM			   démarrer en : D:\comptoir
REM			   icone d:\comptoir\comptoir.exe

REM variable pour compatibilité du XCOPY sous Win2000 
REM (pour éviter que XCOPY demande confirmation pour écraser les fichiers)
set COPYCMD=/Y

REM emplacement par défaut du runtime PB
set DEFPBRTS=d:\pbrts

REM vérification des arguments
if "%1"=="" goto erreursynchro
if "%2"=="" goto erreurrts

set TRANSITDIR=%1%\Upgrade

REM dossier runtime PB : valeur par défaut ou donnée dans le 3eme argument de la ligne de commande.
if "%3"=="" (
  set PBRTS=%DEFPBRTS%
) else (
  set PBRTS=%3
)

REM dossier client Oracle : valeur sélectionnée parmi les clients standards ou  
REM     donnée dans le 4eme argument de la ligne de commande.
if "%4"=="" goto choix_client_Oracle
set ORABIN=%4
goto verifdossiers

:choix_client_Oracle
REM tester présence client(s) oracle et assigner le PATH
set ORATMP=C:\Oracle\product\18c\Client_x86\bin
if exist %ORATMP%\nul (
   set ORABIN=%ORATMP%
   goto verifdossiers
   )

set ORATMP=C:\oracle\product\11.2.0\client\BIN
if exist %ORATMP%\nul (
   set ORABIN=%ORATMP%
   goto verifdossiers
   )

set ORATMP=C:\oracle\product\11.2.0\client_1\BIN
if exist %ORATMP%\nul (
   set ORABIN=%ORATMP%
   goto verifdossiers
   )

set ORATMP=C:\oracle\product\11.2.0\client32\BIN
if exist %ORATMP%\nul (
   set ORABIN=%ORATMP%
   goto verifdossiers
   )

set ORATMP=C:\oracle\product\10.2.0\client\BIN
if exist %ORATMP%\nul (
   set ORABIN=%ORATMP%
   goto verifdossiers
   )

set ORATMP=C:\oracle\product\10.2.0\client_1\BIN
if exist %ORATMP%\nul (
   set ORABIN=%ORATMP%
   goto verifdossiers
   )

set ORATMP=C:\oracle\product\10.2.0\client32\BIN
if exist %ORATMP%\nul (
   set ORABIN=%ORATMP%
   goto verifdossiers
   )

REM Si on arrive ici, c'est qu'aucun des clients testé n'est présent,
REM ou que le dossier d'installation est différent.
REM Dans ce cas, on utilise la variable PATH qui doit contenir, entre autre,
REM le dossier réel du client oracle.
set ORABIN=%PATH%

:verifdossiers
echo Client Oracle : %ORABIN%
if not exist %1%\nul goto erreurarg1
if not exist %2%\nul goto erreurarg2
if not exist %3%\nul goto erreurarg3
if not exist %4%\nul goto erreurarg4
if not exist %PBRTS%\nul goto erreurPBRTS

REM copier au bon endroit l'éventuelle nouvelle version envoyée sur %TRANSITDIR%
if not exist %1\version.txt goto suitecopy
if not exist %TRANSITDIR%\nul goto suitecopy
xcopy /e /r %TRANSITDIR% %1

:suitecopy
REM copie version officielle programmes + RTS
xcopy /d "%1\comptoir.exe" .
xcopy /d "%1\*.pbd" .
REM si pbrts.zip n'est plus le même, il faut le désarchiver pour l'installer (ErrorLevel 0 means files were copied without error, 1 means no file were found to copy)
robocopy "%2" "%PBRTS%" pbrts.zip /r:2 /NFL /NDL /NJH /NJS
if %errorlevel% equ 1 powershell expand-archive -literalPath $env:PBRTS\pbrts.zip -DestinationPath $env:PBRTS -Force
xcopy /d /s "%PBRTS%\Sybase.PowerBuilder.DataWindow.Excel12.dll" .

path=%PBRTS%;%ORABIN%;c:\;%windir%;%windir%\system32;

start comptoir.exe %1
goto fin

:erreursynchro
echo .
echo Erreur : le dossier contenant, sur le serveur, les programmes originaux et les .INI doit etre mentionne dans le 1er argument de la commande
goto syntaxe

:erreurrts
echo .
echo Erreur : le dossier contenant, sur le serveur, la version officielle du runtime PowerBuilder doit etre mentionne dans le 2eme argument de la commande
goto syntaxe

:erreurarg1
echo .
echo Erreur : le dossier %1 mentionne dans le 1er argument n'existe pas
echo .
pause
goto fin

:erreurarg2
echo .
echo Erreur : le dossier %2 mentionne dans le 2eme argument n'existe pas
echo .
pause
goto fin

:erreurarg3
echo .
echo Erreur : le dossier %3 mentionne dans le 3eme argument n'existe pas
echo .
pause
goto fin

:erreurarg4
echo .
echo Erreur : le dossier %4 mentionne dans le 4eme argument n'existe pas
echo .
pause
goto fin

:erreurPBRTS
echo .
echo Erreur : le dossier %PBRTS% (runtime PB) n'existe pas
echo .
pause
goto fin

:syntaxe
echo .
echo . syntaxe de la commande : comptoir.cmd  dossier_source_programmes  dossier_source_runtimePB  {dossier_local_runtimePB} {dossier_ORACLE_BIN}
echo .
pause

:fin
xcopy /d "%1\comptoir.cmd" .