forward
global type uo_logmessage from nonvisualobject
end type
end forward

global type uo_logmessage from nonvisualobject
end type
global uo_logmessage uo_logmessage

forward prototypes
public function integer uf_logmessage (string as_filename, string as_message, boolean ab_standard)
public function integer uf_logmessage (string as_filename, string as_message)
public function integer uf_logmessage (string as_filename, string as_message, integer ai_maxsize, boolean ab_standard)
end prototypes

public function integer uf_logmessage (string as_filename, string as_message, boolean ab_standard);// quand on appelle la fonction sans préciser de taille maxi de fichier, on utilise 10Mo
return(uf_logmessage(as_filename, as_message, 10000, ab_standard))

end function

public function integer uf_logmessage (string as_filename, string as_message);// quand on appelle la fonction sans préciser de taille maxi de fichier, on utilise 10Mo
return(uf_logmessage(as_filename, as_message, 10000, TRUE))

end function

public function integer uf_logmessage (string as_filename, string as_message, integer ai_maxsize, boolean ab_standard);// enregistre le message 'as_message' dans le fichier d'enregistrement 'as_filename'
// si la taille du fichier est > ai_maxsize (donnée en Ko), il est renommé en 'as_filename.OLOG'

string	ls_parse[], ls_basename
integer	li_file
long		ll_length

// PCO 29/04/2015 : si nom de fichier pas spécifié, on quitte la fonction.
IF f_isEmptyString(as_filename) THEN return(-1)

// extraire le nom de base (sans l'extension ni le dossier qui le contient)
f_parse(as_filename, ".", ls_parse)
f_parse(ls_parse[1], "\", ls_parse)
ls_basename = ls_parse[upperbound(ls_parse)]

// si fichier log dépasse ai_maxsize, le renommer en filename.OLOG (supprimer ancien .OLOG si existe déjà)
ll_length = FileLength(as_filename)
IF ll_length > (ai_maxsize * 1024) THEN
	IF fileExists(gs_cenpath + "\" + ls_basename + ".OLOG") THEN
		FileDelete(gs_cenpath + "\" + ls_basename + ".OLOG")
	END IF
	f_runwait(gs_shell + " rename " + as_filename + " " + ls_basename + ".OLOG")
END IF

li_File = FileOpen(as_filename, LineMode!, Write!, Shared!, Append!)
IF li_file = -1 THEN return(-1)

// si ab_standard=TRUE, ajouter l'entête standard au message
IF ab_standard THEN
	as_message = gs_computername + "/" + gs_username + "/" + String(Today(), "dd-mm-yyyy hh:mm") + &
					"~r~n" + as_message+ "~r~n"
	ELSE
		as_message = as_message + "~r~n"
END IF

IF	FileWrite(li_file, as_message) = -1 THEN 
	FileClose(li_file)
	return(-1)
END IF
return(FileClose(li_file))

end function

on uo_logmessage.create
call super::create
TriggerEvent( this, "constructor" )
end on

on uo_logmessage.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

