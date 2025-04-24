forward
global type uo_fileservices from nonvisualobject
end type
type ostr_filedatetime from structure within uo_fileservices
end type
type ostr_finddata from structure within uo_fileservices
end type
type ostr_systemtime from structure within uo_fileservices
end type
end forward

type ostr_filedatetime from structure
	unsignedlong		ul_lowdatetime
	unsignedlong		ul_highdatetime
end type

type ostr_finddata from structure
	unsignedlong		ul_fileattributes
	ostr_filedatetime		str_creationtime
	ostr_filedatetime		str_lastaccesstime
	ostr_filedatetime		str_lastwritetime
	unsignedlong		ul_filesizehigh
	unsignedlong		ul_filesizelow
	unsignedlong		ul_reserved0
	unsignedlong		ul_reserved1
	character		ch_filename[260]
	character		ch_alternatefilename[14]
end type

type ostr_systemtime from structure
	unsignedinteger		ui_wyear
	unsignedinteger		ui_wmonth
	unsignedinteger		ui_wdayofweek
	unsignedinteger		ui_wday
	unsignedinteger		ui_whour
	unsignedinteger		ui_wminute
	unsignedinteger		ui_wsecond
	unsignedinteger		ui_wmilliseconds
end type

global type uo_fileservices from nonvisualobject
end type
global uo_fileservices uo_fileservices

type prototypes
Function ulong FindFirstFileA (ref string filename, ref ostr_finddata findfiledata) library "KERNEL32.DLL" alias for "FindFirstFileA;Ansi"
Function Boolean FindNextFileA( Long handle, Ref ostr_finddata findfiledata ) Library "KERNEL32.DLL" alias for "FindNextFileA;Ansi"
Function boolean FileTimeToLocalFileTime(ref ostr_filedatetime lpFileTime, ref ostr_filedatetime lpLocalFileTime) library "KERNEL32.DLL" alias for "FileTimeToLocalFileTime;Ansi"
Function boolean FileTimeToSystemTime(ref ostr_filedatetime lpFileTime, ref ostr_systemtime lpSystemTime) library "KERNEL32.DLL" alias for "FileTimeToSystemTime;Ansi"
Function boolean FindClose (ulong handle) library "KERNEL32.DLL"

end prototypes

type variables

end variables

forward prototypes
public function integer uf_createfolder (string as_folder)
public function integer uf_writefile (string as_text, string as_filename)
public function integer uf_writefile (blob a_blob, string as_filename, any a_wmode)
public function integer uf_writefile (string as_text, string as_filename, any a_wmode)
public function integer uf_readfile (string as_filename, ref blob ab_blob)
public function integer uf_readfile (string as_filename, ref string as_text)
public function integer uf_getfileattrib (string as_filename, ref date ad_date, ref time at_time, ref double adb_filesize)
public function integer uf_convertfiledatetimetopb (ostr_filedatetime astr_filetime, ref date ad_filedate, ref time at_filetime)
public function integer uf_basename (string as_inputfilename, boolean ab_stripsuffix, ref string as_path, ref string as_basename, ref string as_suffix)
public function integer uf_deleteprofilestring (string as_filename, string as_section, string as_key)
public function integer uf_dirlist (string as_path, string as_mask, ref string as_dirlist[])
public function integer uf_getxlsfilesavename (ref string as_filename)
public function integer uf_getfilesavename (ref string as_filename, string as_extension, string as_filter)
public subroutine uf_deletefile (string as_path, string as_dirlist[])
public subroutine uf_deletefile_pattern (string as_path, string as_mask)
public function integer uf_writefile (string as_text, string as_filename, any a_wmode, any a_encoding)
public function integer uf_readfile (string as_filename, ref string as_text, any a_encoding)
public subroutine uf_discardfile (ref string as_dirlist[], string as_match)
end prototypes

public function integer uf_createfolder (string as_folder);// création du dossier passé en argument (crée le chemin complet s'il n'existe pas)
// Arguments:		as_folder	nom du dossier à créer
//	Returns:			Integer
integer	li_status, li_i
string	ls_folder[], ls_dir

f_parse(as_folder, "\", ls_folder)
FOR li_i = 1 TO UpperBound(ls_folder)
	IF li_i = 1 THEN
		ls_dir = ls_folder[1]
	ELSE
		ls_dir = ls_dir + "\" + ls_folder[li_i]
	END IF
	IF NOT FileExists(ls_dir) THEN
		IF CreateDirectory(ls_dir) = -1 THEN
			return(-1)
		END IF
	END IF
NEXT
return(1)



end function

public function integer uf_writefile (string as_text, string as_filename);// écrit le texte de la variable as_text dans le fichier as_filename passé en argument
// mode d'écriture : replace!
// return(1) si OK, -1 en cas d'erreur

return(uf_writefile(as_text, as_filename, replace!))

end function

public function integer uf_writefile (blob a_blob, string as_filename, any a_wmode);// écrit le blob de la variable a_blob dans le fichier as_filename passé en argument
// mode d'écriture (a_wmode) = replace! ou append!
// return(1) si OK, -1 en cas d'erreur
integer	li_FileNum
long 		ll_pos

IF f_IsEmptyString(as_filename) THEN
	gu_message.uf_error("Le nom du fichier doit être spécifié")
	return(-1)
END IF

IF a_wmode <> append! AND a_wmode <> replace! THEN
	gu_message.uf_error("Le mode d'écriture dans le fichier est incorrect (doit être append! ou replace!)")
	return(-1)
END IF

SetPointer(HourGlass!)

// open the file
li_FileNum = FileOpen(as_filename, StreamMode!, Write!, LockWrite!, a_wmode)

IF li_filenum = -1 THEN
	gu_message.uf_error("Erreur à l'ouverture (write) du fichier " + as_filename)
	return(-1)	
END IF

ll_pos = FileWriteEX(li_filenum, a_blob)
IF ll_pos = -1 THEN
	FileClose(li_FileNum)
	gu_message.uf_error("Erreur d'écriture dans le fichier " + as_filename)
	return(-1)
END IF

// PCO 20/12/2024 : utiliser FileWriteEX au lieu de FileWrite pour éviter la limitation du nbre de caractères
//// Write chunks of the file until the end
//ll_pos = 0
//DO WHILE ll_pos < LenA(a_blob) 
//	a_blob = blobmid(a_blob, ll_pos + 1)
//   ll_pos = FileWrite(li_filenum, a_blob)
//	IF ll_pos = -1 THEN
//		FileClose(li_FileNum)
//		gu_message.uf_error("Erreur d'écriture dans le fichier " + as_filename)
//		return(-1)
//	END IF
//LOOP

FileClose(li_FileNum)
return(1)
end function

public function integer uf_writefile (string as_text, string as_filename, any a_wmode);// écrit le texte de la variable as_text dans le fichier as_filename passé en argument
// mode d'écriture (a_wmode) = replace! ou append!
// return(1) si OK, -1 en cas d'erreur

return(uf_writefile(as_text, as_filename, a_wmode, EncodingANSI!))

end function

public function integer uf_readfile (string as_filename, ref blob ab_blob);// lit le fichier passé en argument et renvoie son contenu dans la variable ab_blob
// return(1) si OK, -1 en cas d'erreur
integer li_FileNum
long ll_bytesread
blob b_b1

IF f_IsEmptyString(as_filename) THEN
	gu_message.uf_error("Le nom du fichier doit être spécifié")
	return(-1)
END IF

IF NOT FileExists(as_filename) THEN
	gu_message.uf_error("Fichier " + as_filename + " inexistant !")
	return(-1)
END IF

SetPointer(HourGlass!)

// open the file in stream mode
li_FileNum = FileOpen(as_filename, StreamMode!, Read!, LockRead!)

IF li_filenum = -1 THEN
	gu_message.uf_error("Erreur à l'ouverture (read) du fichier " + as_filename)
	return(-1)
END IF

// Read the file
ll_bytesread = FileReadEx(li_FileNum, b_b1)
IF ll_bytesread = -1 THEN
	FileClose(li_FileNum)
	gu_message.uf_error("Erreur de lecture du fichier " + as_filename)
	return(-1)
END IF

ab_blob = b_b1
FileClose(li_FileNum)
return(1)
end function

public function integer uf_readfile (string as_filename, ref string as_text);// lit le fichier passé en argument et renvoie son contenu dans la variable as_text
// return(1) si OK, -1 en cas d'erreur
integer	li_st

li_st = uf_readfile(as_filename, as_text, EncodingANSI!)
return(li_st)
	

end function

public function integer uf_getfileattrib (string as_filename, ref date ad_date, ref time at_time, ref double adb_filesize);// renvoie les date et heure de dernière modification du fichier dont le nom est passé en paramètre
//	Arguments:		as_FileName			The name of the file for which you want its date
//												and time; an absolute path may be specified or it
//												will be relative to the current working directory
//						ad_Date				The date the file was last modified, passed by reference.
//						at_Time				The time the file was last modified, passed by reference.
//						adb_filesize		the file size
// return -1 en cas d'erreur
// return 1 si OK

ulong			lul_Handle
ostr_finddata	lstr_FindData

IF NOT FileExists(as_filename) THEN
	gu_message.uf_error("Fichier " + as_filename + " inexistant !")
	return(-1)
END IF

// Get the file information
lul_Handle = FindFirstFileA(as_FileName, lstr_FindData)
If lul_Handle <= 0 Then Return -1
FindClose(lul_Handle)

adb_FileSize = (lstr_FindData.ul_FileSizeHigh * (2.0 ^ 32))  + lstr_FindData.ul_FileSizeLow

// Convert the date and time
Return uf_ConvertFileDatetimeToPB(lstr_FindData.str_LastWriteTime, ad_Date, at_Time)


end function

public function integer uf_convertfiledatetimetopb (ostr_filedatetime astr_filetime, ref date ad_filedate, ref time at_filetime);//	Convert a sytem file type to PowerBuilder Date and Time
// Arguments:		astr_FileTime		The ostr_filedatetime structure containing the system date/time for the file.
//						ad_FileDate			The file date in PowerBuilder Date format	passed by reference.
//						at_FileTime			The file time in PowerBuilder Time format	passed by reference.
//	Returns:			Integer

string				ls_Time
ostr_filedatetime	lstr_LocalTime
ostr_systemtime	lstr_SystemTime

If Not FileTimeToLocalFileTime(astr_FileTime, lstr_LocalTime) Then Return(-1)

If Not FileTimeToSystemTime(lstr_LocalTime, lstr_SystemTime) Then Return(-1)

// works with all date formats
ad_FileDate = Date(lstr_SystemTime.ui_wyear, lstr_SystemTime.ui_WMonth, lstr_SystemTime.ui_WDay)

ls_Time = String(lstr_SystemTime.ui_wHour) + ":" + &
			 String(lstr_SystemTime.ui_wMinute) + ":" + &
			 String(lstr_SystemTime.ui_wSecond) + ":" + &
			 String(lstr_SystemTime.ui_wMilliseconds)
at_FileTime = Time(ls_Time)

Return(1)


end function

public function integer uf_basename (string as_inputfilename, boolean ab_stripsuffix, ref string as_path, ref string as_basename, ref string as_suffix);// Cherche le nom de base du fichier as_filename passé en argument
// (le nom de base est le nom du fichier débarrassé du nom de dossier et du suffixe)
// Input:
//		as_inputfilename = le nom de fichier complet, avec son dossier et suffixe
//		as_stripsuffix = TRUE si on veut que le nom renvoyé soit débarrassé de son suffixe, FALSE sinon
// output:
//		as_path = le nom du dossier seul, SANS le '\' à la fin (exemple = d:\tmp)
//		as_basename = le nom du fichier seul, éventuellement débarrasé du suffixe si ab_stripsuffix = TRUE
//    as_suffix = le suffixe du fichier SANS le '.' (exemple = xls)

long		ll_pos, ll_pos2

as_path = ""
as_basename = ""
as_suffix = ""

// isoler le dossier : ce qui se trouve devant le dernier '\' ou '/'
as_inputfilename = gu_stringservices.uf_replaceall(as_inputfilename, "/", "\")
DO
	ll_pos2 = ll_pos
	ll_pos = PosA(as_inputfilename, "\", ll_pos2 + 1)
LOOP WHILE ll_pos > 0
IF ll_pos2 = 0 THEN
	as_basename = as_inputfilename
ELSE
	as_path = LeftA(as_inputfilename, ll_pos2 - 1)
	as_basename = MidA(as_inputfilename, ll_pos2 + 1)
END IF

// isoler le suffixe : ce qui se trouve après le dernier '.' qui figure dans le nom du fichier
ll_pos = 0
DO
	ll_pos2 = ll_pos
	ll_pos = PosA(as_basename, ".", ll_pos2 + 1)
LOOP WHILE ll_pos > 0
IF ll_pos2 > 0 THEN
	as_suffix = MidA(as_basename, ll_pos2 + 1)
	// supprimer le suffixe si demandé
	IF ab_stripsuffix THEN as_basename = LeftA(as_basename, ll_pos2 - 1)
END IF

return(1)
end function

public function integer uf_deleteprofilestring (string as_filename, string as_section, string as_key);// supprimer la clé "as_key" dans la section "as_section" du .INI "as_filename"
// Attention : traitement long (plusieurs secondes) si le fichier .ini est long...
Long ll_file, ll_return 
String ls_data, ls_newdata 
Boolean lb_sectionFound=FALSE, lb_keyfound=FALSE

IF f_IsEmptySTring(as_filename) OR f_IsEmptySTring(as_section) OR f_IsEmptySTring(as_key) THEN
	return(-1)
END IF

// ouvre le fichier .INI en lecture
ll_file = FileOpen(as_filename, LineMode!, Read!) 
IF ll_file <=0 THEN RETURN (-1 )

// lit 1 à 1 les lignes du .INI dans la variable ls_data
DO UNTIL FileRead(ll_file, ls_data) = -100 
	// la ligne lue est-elle une section ?
	IF leftA(ls_data,1) = "[" AND rightA(ls_data,1) = "]" THEN
		lb_SectionFound = FALSE
		// la section est-elle celle recherchée ?
	   IF PosA(upper(ls_data), '[' + upper(as_section) + ']') > 0 THEN 
   	   lb_SectionFound = TRUE
	   END IF
	END IF

	// Pas dans la bonne section ? conserver la ligne telle quelle dans le nouveau fichier
   IF NOT lb_SectionFound THEN 
      IF LenA(ls_newdata) = 0 THEN 
         ls_newdata = ls_data 
      ELSE 
         ls_newdata = ls_newdata + '~r~n' + ls_data 
      END IF 
	ELSE
	// dans la bonne section ? skipper la ligne qui contient la bonne KEY et conserver les autres
		IF PosA(upper(ls_data), upper(as_key) + "=") = 0 THEN
		   IF LenA(ls_newdata) = 0 THEN 
            ls_newdata = ls_data 
			ELSE 
         	ls_newdata = ls_newdata + '~r~n' + ls_data 
	      END IF 
		END IF
   END IF 
LOOP 

// refermer le .INI
ll_return = FileClose(ll_file) 
IF ll_return <=0 THEN RETURN(-1)

// backup du .ini puis écriture du .ini modifié
IF FileCopy(as_filename, as_filename + "_bkp", true) = 1 THEN
	// réouvrir le .INI en écriture pour remplacer l'ancien
	ll_file = FileOpen(as_filename, LineMode!, Write!, LockWrite!, Replace!) 
	IF ll_file <=0 THEN RETURN(-1 )

	// écrire le contenu du fichier
	ll_return = FileWriteEX(ll_file, ls_newdata) 
	IF ll_return <=0 THEN RETURN(-1)

	// refermer le .INI
	ll_return = FileClose(ll_file) 
	IF ll_return <=0 THEN RETURN(-1)
ELSE
	return(-1)
END IF

return(1)
end function

public function integer uf_dirlist (string as_path, string as_mask, ref string as_dirlist[]);// récupération de la liste des fichiers d'un dossier
// as_path : chemin (ex: 'c\temp')
// as_mask : filtre (ex : *.txt')
// as_dirlist[] : tableau des noms de fichiers
// return(>=0) : nb fichiers

Long		ll_handle, ll_file_nr = 0
String	ls_empty[], ls_file, ls_pathmask
Boolean	lb_more_files   
ostr_finddata	lstr_finddata

// ràz tableau
as_dirlist = ls_empty

// cherche le 1er fichier correspondant au chemin + filtre
ls_pathmask = as_path + "\" + as_mask
ll_handle = FindFirstFileA(ls_pathmask, lstr_finddata)

// si aucun fichier trouvé : retourne 0, sinon : boucle sur les fichiers
IF ll_handle <> -1 THEN
	DO
		ls_file = lstr_finddata.ch_filename
		// ajout du nom de fichier au tableau (s'il ne s'agit pas d'un dossier !)
		IF NOT DirectoryExists(as_path + "\" + ls_file) THEN
			ll_file_nr ++
			as_dirlist[ ll_file_nr ] = ls_file
		END IF
		// Récupère le fichier suivant
		lb_more_files = FindNextFileA(ll_handle, lstr_finddata)
	LOOP WHILE lb_more_files 
END IF

// fermeture
FindClose(ll_handle)

Return(ll_file_nr)

end function

public function integer uf_getxlsfilesavename (ref string as_filename);// Demande nom d'un fichier EXCEL et confirme écrasement s'il existe déjà.
// Si on confirme l'écrasement, le fichier est supprimé.
// Nom du fichier proposé = as_filename (basename).
// return(1) si OK. L'argument as_filename prend alors comme valeur le nom du fichier (full pathname)
// return(-1) si erreur ou abandon par l'utilisateur
return uf_GetFileSaveName(as_filename, "xls", "Fichier Excel (*.xls),*.xls")
end function

public function integer uf_getfilesavename (ref string as_filename, string as_extension, string as_filter);// Demande nom du fichier et confirme écrasement s'il existe déjà.
// Si on confirme l'écrasement, le fichier est supprimé.
// Nom du fichier proposé = as_filename (basename).
// return(1) si OK. L'argument as_filename prend alors comme valeur le nom du fichier (full pathname)
// return(-1) si erreur ou abandon par l'utilisateur
string	ls_file, ls_filename
integer	li_st

ls_filename = as_filename

DO
	IF GetFileSaveName("Nom du fichier ?", ls_filename, ls_file, as_extension, as_filter) <> 1 THEN
		return(-1)
	END IF
	li_st = 1
	IF FileExists(ls_filename) THEN
		IF gu_message.uf_query("Le fichier '" + ls_filename + "' existe déjà.~n" + & 
								 	  "Voulez-vous le remplacer ?", YesNo!, 2) = 2 THEN
			li_st = -1
			CONTINUE
		ELSE
			IF fileDelete(ls_filename) = FALSE THEN
				gu_message.uf_error("Impossible de supprimer le fichier '" + ls_filename + "'~n" + &
										  "Vérifiez que ce fichier n'est pas en cours d'utilisation.")
				li_St = -1
			END IF
		END IF
	END IF
LOOP UNTIL li_st = 1

as_filename = ls_filename

return(1)

end function

public subroutine uf_deletefile (string as_path, string as_dirlist[]);// suppression des fichiers du dossier AS_PATH dont la liste est donnée par AS_DIRLIST.
// as_path : chemin (ex: 'c\temp')
// as_dirlist[] : tableau des noms de fichiers
integer	li_file

FOR li_file = 1 TO upperBound(as_dirlist)
	fileDelete(as_path + "\" + as_dirlist[li_file])
NEXT
end subroutine

public subroutine uf_deletefile_pattern (string as_path, string as_mask);// suppression des fichiers du dossier AS_PATH qui correspondent au pattern AS_MASK
// as_path : chemin (ex: 'c\temp')
// as_mask : pattern (par exemple doc.*)
string	ls_dirlist[]

uf_dirlist(as_path, as_mask, ls_dirlist)

uf_deletefile(as_path, ls_dirlist)


end subroutine

public function integer uf_writefile (string as_text, string as_filename, any a_wmode, any a_encoding);// écrit le texte de la variable as_text dans le fichier as_filename passé en argument
// mode d'écriture (a_wmode) = replace! ou append!
// return(1) si OK, -1 en cas d'erreur
// as_encoding valid values : ANSI, UTF8, UTF16LE, UTF16BE
integer	li_FileNum
long 		ll_pos

IF f_IsEmptyString(as_filename) THEN
	gu_message.uf_error("Le nom du fichier doit être spécifié")
	return(-1)
END IF

IF a_wmode <> append! AND a_wmode <> replace! THEN
	gu_message.uf_error("Le mode d'écriture dans le fichier est incorrect (doit être append! ou replace!)")
	return(-1)
END IF

// as_encoding valid values : ANSI, UTF8, UTF16LE, UTF16BE
CHOOSE CASE a_encoding
	CASE EncodingANSI!, EncodingUTF8!, EncodingUTF16LE!, EncodingUTF16BE!
	CASE ELSE
		gu_message.uf_error("Erreur paramètre 'encoding' : " + string(a_encoding))
		return(-1)
END CHOOSE

SetPointer(HourGlass!)

// open the file
li_FileNum = FileOpen(as_filename, TextMode!, Write!, LockWrite!, a_wmode, a_encoding)

IF li_filenum = -1 THEN
	gu_message.uf_error("Erreur à l'ouverture (write) du fichier " + as_filename)
	return(-1)	
END IF

ll_pos = FileWriteEX(li_filenum, as_text)
IF ll_pos = -1 THEN
	FileClose(li_FileNum)
	gu_message.uf_error("Erreur d'écriture dans le fichier " + as_filename)
	return(-1)
END IF

// PCO 20/12/2024 : utiliser FileWriteEX au lieu de FileWrite pour éviter la limitation du nbre de caractères
//// Write chunks of the file until the end
//ll_pos = 0
//DO WHILE ll_pos < LenA(as_text) 
//	as_text = MidA(as_text, ll_pos + 1)
//   ll_pos = FileWrite(li_filenum, as_text)
//	IF ll_pos = -1 THEN
//		FileClose(li_FileNum)
//		gu_message.uf_error("Erreur d'écriture dans le fichier " + as_filename)
//		return(-1)
//	END IF
//LOOP
//
FileClose(li_FileNum)
return(1)
end function

public function integer uf_readfile (string as_filename, ref string as_text, any a_encoding);// lit le fichier passé en argument et renvoie son contenu dans la variable as_text
// return(1) si OK, -1 en cas d'erreur
blob		b_b1
integer	li_st

// as_encoding valid values : ANSI, UTF8, UTF16LE, UTF16BE
CHOOSE CASE a_encoding
	CASE EncodingANSI!, EncodingUTF8!, EncodingUTF16LE!, EncodingUTF16BE!
	CASE ELSE
		gu_message.uf_error("Erreur paramètre 'encoding' : " + string(a_encoding))
		return(-1)
END CHOOSE

li_st = uf_readfile(as_filename, b_b1)
IF li_st < 0 THEN
	return(-1)
END IF

as_text = string(b_b1, a_encoding)

return(1)

end function

public subroutine uf_discardfile (ref string as_dirlist[], string as_match);// éliminer les fichiers répondant au pattern AS_MASK de la liste des fichier as_dirlist
// as_dirlist : array contenant une liste de nom de fichiers
// as_match : pattern(s) des fichiers à retirer de la liste (par exemple *.csv;.txt). Séparateur est le point-virgule.
integer	li_match, li_i, li_index
string	ls_match[], ls_dirlist[], ls_empty[]

f_parse(as_match, ";", ls_match)

FOR li_match = 1 TO upperbound(ls_match)
	FOR li_i = 1 TO upperbound(as_dirlist)
		IF NOT match(upper(as_dirlist[li_i]), upper(ls_match[li_match])) THEN
			li_index++
			ls_dirlist[li_index] = as_dirlist[li_i]
		END IF
	NEXT
	as_dirlist = ls_dirlist
	ls_dirlist = ls_empty
	li_index = 0
NEXT

end subroutine

on uo_fileservices.create
call super::create
TriggerEvent( this, "constructor" )
end on

on uo_fileservices.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

