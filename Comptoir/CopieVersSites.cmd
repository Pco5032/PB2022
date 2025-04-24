REM set USER=wallonie\al223
REM set PWD=***

copy /Y D:\PB125appl\Comptoir\comptoir\doc\*_org.doc L:\DGO3-DNF\Comptoir\doc
copy /Y D:\PB125appl\Common\ancestors\ancestors.pbd L:\DGO3-DNF\Comptoir\upgrade
copy /Y D:\PB125appl\Common\shared\shared.pbd L:\DGO3-DNF\Comptoir\upgrade
copy /Y D:\PB125appl\Common\carto\carto.pbd L:\DGO3-DNF\Comptoir\upgrade
copy /Y D:\PB125appl\Comptoir\comptoir\comptoir.pbd L:\DGO3-DNF\Comptoir\upgrade
copy /Y D:\PB125appl\Comptoir\comptoir\comptoir.exe L:\DGO3-DNF\Comptoir\upgrade
copy /Y D:\PB125appl\Comptoir\comptoir\comptoir.ini L:\DGO3-DNF\Comptoir\upgrade
copy /Y D:\PB125appl\Comptoir\comptoir\comptoirhelp.ini L:\DGO3-DNF\Comptoir\upgrade
copy /y d:\robocopy\version.txt L:\DGO3-DNF\Comptoir\Comptoir

REM DGA
REM 20/05/2015 : ce dossier a disparu !
REM net use Z: \\mrw.wallonie.int\dgarne\PRJ\APP\Comptoir_ISL /persistent:NO
REM copy /Y D:\PB125appl\Comptoir\comptoir\doc\*_org.doc Z:\Comptoir\doc
REM copy /Y D:\PB125appl\Common\ancestors\ancestors.pbd Z:\Comptoir\upgrade
REM copy /Y D:\PB125appl\Common\shared\shared.pbd Z:\Comptoir\upgrade
REM copy /Y D:\PB125appl\Common\carto\carto.pbd Z:\Comptoir\upgrade
REM copy /Y D:\PB125appl\Comptoir\comptoir\comptoir.pbd Z:\Comptoir\upgrade
REM copy /Y D:\PB125appl\Comptoir\comptoir\comptoir.exe Z:\Comptoir\upgrade
REM copy /Y D:\PB125appl\Comptoir\comptoir\comptoir.ini Z:\Comptoir\upgrade
REM copy /Y D:\PB125appl\Comptoir\comptoir\comptoirhelp.ini Z:\Comptoir\upgrade
REM copy /y d:\robocopy\version.txt Z:\Comptoir
REM net use Z: /delete
REM sleep 5

REM Direction de la Qualité O3030200 
REM remplacé par L:\DGO3-DNF\Comptoir
REM copy /Y D:\PB125appl\Comptoir\comptoir\doc\*_org.doc L:\DGO3-Direction_Qualite\DNF\Comptoir\doc
REM copy /Y D:\PB125appl\Common\ancestors\ancestors.pbd L:\DGO3-Direction_Qualite\DNF\Comptoir\upgrade
REM copy /Y D:\PB125appl\Common\shared\shared.pbd L:\DGO3-Direction_Qualite\DNF\Comptoir\upgrade
REM copy /Y D:\PB125appl\Common\carto\carto.pbd L:\DGO3-Direction_Qualite\DNF\Comptoir\upgrade
REM copy /Y D:\PB125appl\Comptoir\comptoir\comptoir.pbd L:\DGO3-Direction_Qualite\DNF\Comptoir\upgrade
REM copy /Y D:\PB125appl\Comptoir\comptoir\comptoir.exe L:\DGO3-Direction_Qualite\DNF\Comptoir\upgrade
REM copy /Y D:\PB125appl\Comptoir\comptoir\comptoir.ini L:\DGO3-Direction_Qualite\DNF\Comptoir\upgrade
REM copy /Y D:\PB125appl\Comptoir\comptoir\comptoirhelp.ini L:\DGO3-Direction_Qualite\DNF\Comptoir\upgrade
REM copy /y d:\robocopy\version.txt L:\DGO3-Direction_Qualite\DNF\Comptoir
