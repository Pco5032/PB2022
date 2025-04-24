echo off

REM ATTENTION : ce script doit �tre appel� par un autre qui fournira les param�tres n�cessaires ET 
REM             sans doute installera le runtime PB (qui doit �tre pr�sent quand on lance le pr�sent script)
REM
REM 4 arguments obligatoires
REM %1 = le dossier o� il faut installer les fichiers
REM %2 = le dossier o� se trouvent la version officielle des fichiers sur le serveur (source de la synchronization) 
REM %3 = le dossier o� est install� le runtime PB
REM %4 = le dossier o� se trouvent la version officielle du runtime PB sur le serveur (source de la synchronization)

REM exemple :  L:\EFOR_2017\appldbusers\install_DBU c:\appldbusers  L:\EFOR_2017\appldbusers c:\pbrts  L:\EFOR_2017\pbrts

echo .
echo debut installation appldbusers

setlocal

REM substitution des param�tres de commandes : remplacer les noms longs par des noms courts
REM pour + d'info : taper help call dans une fen�tre DOS

set DEST=%~s1
set ORG=%~s2
set DESTPB=%~s3
set ORGPB=%~s4

if not defined DEST goto erreurARGS
if not defined ORG goto erreurARGS
if not defined DESTPB goto erreurARGS
if not defined ORGPB goto erreurARGS

if not exist %ORG% goto erreurORG
if not exist %DESTPB% goto erreurDESTPB

REM si dossier destination n'existe pas le cr�er
if exist %DEST%\nul goto DESTEXIST
mkdir %DEST%
if errorlevel 1 goto erreurDEST

:DESTEXIST
copy %ORG%\appldbusers.cmd %DEST%
copy %ORG%\appldbusers.exe %DEST%
copy %ORG%\*.pbd %DEST%

REM cr�ation du raccourci (c'est ici que le runtime PB est d�j� n�cessaire)
set PATH=%PATH%;%DESTPB%
%ORG%\createshortcut.exe Shortcut=ApplDBusers; target=%DEST%\appldbusers.cmd; WorkingDir=%DEST%; Arguments=%ORG% %ORGPB% %DESTPB%; SpecialFolder=Desktop, Programs; Icon=%DEST%\appldbusers.exe
if errorlevel 1 goto erreurSHORTCUT

goto fin_ok

:erreurARGS
cls
echo .
echo Erreur d'arguments - Installation abandonnee.
echo Valeur des arguments recus :
echo .
echo DEST=%DEST%
echo ORG=%ORG%
echo DESTPB=%DESTPB%
echo ORGPB=%ORGPB%
goto fin_err

:erreurDEST
cls
echo .
echo Creation du dossier %DEST% impossible - Installation abandonnee
goto fin_err

:erreurORG
cls
echo .
echo Le dossier source %ORG% n'existe pas - Installation abandonnee
goto fin_err

:erreurPB
cls
echo .
echo Le dossier runtime PB %DESTPB% n'existe pas - Installation abandonnee
goto fin_err

:erreurSHORTCUT
cls
echo .
echo Erreur de creation du raccourci - Installation abandonnee
goto fin_err

:fin_err
echo .
echo Erreur lors de l'installation de appldbusers !
pause
REM astuce pour provoquer un errorlevel > 0
dddd 2>nul
goto fin

goto fin

:fin_ok
echo .
echo Installation de appldbusers terminee !
goto fin

:fin
endlocal