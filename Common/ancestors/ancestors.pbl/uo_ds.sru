//objectcomments Ancêtre pour les DS control
forward
global type uo_ds from datastore
end type
end forward

global type uo_ds from datastore
event type integer ue_initial_dberror ( str_dberror astr_dberr )
event ue_message_dberror ( str_dberror astr_dberr )
end type
global uo_ds uo_ds

forward prototypes
public subroutine uf_message_dberror (str_dberror astr_dberror)
public function integer uf_saveas (string as_initfolder, saveastype a_saveastype[], ref string as_folder, ref string as_filename)
public function integer uf_saveas ()
public function integer uf_saveas (ref string as_folder)
public function integer uf_saveas (ref string as_folder, ref string as_filename)
public function integer uf_saveas (saveastype a_saveastype[])
end prototypes

event ue_initial_dberror;// event déclenché par l'event dberror avant d'exécuter le code standard, afin de pouvoir le personnaliser
// return(0) signifie qu'on exécutera le code standard de dberror après ce code-ci
// return(1) signifie qu'on n'exécutera pas le code standard de dberror après ce code-ci
return(0)
end event

public subroutine uf_message_dberror (str_dberror astr_dberror);// passer la structure globale à la fenêtre d'affichage d'erreur
openwithparm (w_dberror,astr_dberror)
end subroutine

public function integer uf_saveas (string as_initfolder, saveastype a_saveastype[], ref string as_folder, ref string as_filename);// as_initfolder : dossier de stockage proposé par défaut
// a_saveastype[] : liste des formats de fichiers possibles (excel, texte...)
// as_folder = nom du dossier sélectionné
// as_filename = nom du fichier créé
// return(1) si OK, et dans ce cas les arguments as_folder et as_filename sont initialisés
// return(0) si opération abandonnée par l'utilisateur
// return(-1) en cas d'erreur

integer	li_type, li_ret
string	ls_filter, ls_suffix, ls_pathname, ls_data
SaveAsType	l_SaveAsType
uo_fileservices	lu_fileservices

// créer le filtre en fonction des types de fichier possibles dont la liste est passée en argument
FOR li_type = 1 TO UpperBound(a_saveastype)
	CHOOSE CASE a_saveastype[li_type]
		CASE Excel!, Excel5!, Excel8!
			ls_filter = ls_filter + "Excel 8 (*.XLS),*.xls,"
		CASE Text!
			ls_filter = ls_filter + "Texte (*.TXT),*.txt,"
		CASE CSV!
			ls_filter = ls_filter + "Texte avec séparateur=virgule (*.CSV),*.csv,"
		CASE SQLInsert!
			ls_filter = ls_filter + "Syntaxe SQL (*.SQL),*.sql,"
		CASE WMF!
			ls_filter = ls_filter + "Windows Metafile format (*.WMF),*.wmf,"
		CASE HTMLTable!
			ls_filter = ls_filter + "HTML (*.html),*.html,"
		CASE XML!
			ls_filter = ls_filter + "Extensible Markup Language (*.XML),*.xml,"
// PCO 06/03/2017 : pouvoir enregistrer sous XLSX requiert la présence d'une DLL "Sybase.PowerBuilder.DataWindow.Excel12"
// dans les "assembly" de Windows, dossier C:\Windows\Microsoft.NET\assembly\GAC_MSIL. 
// Cela nécessite une installation et les droits pour le faire, ce qui est trop lourd. 
// J'ai donc désactivé cette option.
// PCO 06/01/2021 : en test avec PB2019R2 qui nécessite toujours la DLL, mais dans le runtime PB et non dans le GAC Windows.
		CASE XLSX!
			ls_filter = ls_filter + "Excel (*.XLSX),*.xlsx,"
		CASE PDF!
			ls_filter = ls_filter + "PDF (*.PDF),*.pdf,"
		CASE ELSE
			gu_message.uf_Error("Type de fichier non reconnu.")
			return(-1)
	END CHOOSE
NEXT
ls_filter = LeftA(ls_filter, LenA(ls_filter) - 1)

// choix du dossier et nom du fichier
// PCO OCT 2016 : flag 2(voir PB help)
// PCO 07/12/2022 : si le dossier par défaut n'est pas spécifié, utiliser le dossier "Documents" de windows.
IF f_isEmptyString(as_initfolder) THEN
	as_initfolder = gs_mydocuments
END IF
IF GetFileSaveName ("Sauver dans un fichier", ls_pathname, as_filename, "", ls_filter, as_initfolder, 2) <= 0 THEN
	return(0)
END IF

// écraser ou pas le fichier s'il existe déjà
IF FileExists(ls_pathname) THEN
	IF gu_message.uf_query("Sauver dans un fichier", "Le fichier " + ls_pathname + " existe déjà.~nVoulez-vous le remplacer ?", 2) = 2 THEN
		return(0)
	END IF
END IF

// en fonction de l'extension du fichier, déterminer le type choisi
lu_fileservices = CREATE uo_fileservices
lu_fileservices.uf_basename(ls_pathname, FALSE, as_folder, ls_data, ls_suffix)
DESTROY lu_fileservices
CHOOSE CASE upper(ls_suffix)
	CASE "XLS"
		l_SaveAsType = Excel8!
	CASE "TXT"
		l_SaveAsType = Text!
	CASE "CSV"
		l_SaveAsType = CSV!
	CASE "SQL"
		l_SaveAsType = SQLInsert!
	CASE "WMF"
		l_SaveAsType = WMF!
	CASE "HTML"
		l_SaveAsType = HTMLTable!
	CASE "XML"
		l_SaveAsType = XML!
	CASE "XLSX"
		l_SaveAsType = XLSX!
	CASE "PDF"
		l_SaveAsType = PDF!		
	CASE ELSE
		gu_message.uf_Error("Extension " + f_string(ls_suffix) + " non reconnue.")
		return(-1)
END CHOOSE

// sauver le fichier (toujours avec HEADERS)
li_ret = this.saveAs(as_filename, l_saveastype, TRUE)
IF IsNull(li_ret) THEN li_ret = -1

return(li_ret)
end function

public function integer uf_saveas ();string	ls_data1, ls_data2

return(uf_saveas("", {XLSX!, PDF!, Text!, CSV!, SQLInsert!, WMF!, HTMLTable!, XML!, Excel8!}, ls_data1, ls_data2))


end function

public function integer uf_saveas (ref string as_folder);string	ls_data

return(uf_saveas(as_folder, {XLSX!, PDF!, Text!, CSV!, SQLInsert!, WMF!, HTMLTable!, XML!, Excel8!}, as_folder, ls_data))

end function

public function integer uf_saveas (ref string as_folder, ref string as_filename);return(uf_saveas(as_folder, {XLSX!, PDF!, Text!, CSV!, SQLInsert!, WMF!, HTMLTable!, XML!, Excel8!}, as_folder, as_filename))
end function

public function integer uf_saveas (saveastype a_saveastype[]);string	ls_data1, ls_data2

return(uf_saveas("", a_saveastype[], ls_data1, ls_data2))

end function

on uo_ds.create
call super::create
TriggerEvent( this, "constructor" )
end on

on uo_ds.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

event dberror;// déclarer une variable de type structure dberror
str_dberror lstr_dberror

// placer dans la structure globale les variables propres à l'event dberror
lstr_dberror.l_sqldbcode = sqldbcode
lstr_dberror.s_sqlerrtext = sqlerrtext
lstr_dberror.s_sqlsyntax = sqlsyntax
lstr_dberror.l_row = row
lstr_dberror.dwb_buffer = buffer
/* severity 1 = info 
	severity 2 = warning
	severity 3 = error
	severity 4 = fatal */
IF sqldbcode = -3 THEN
	lstr_dberror.s_sqlerrtext = "Les données ont été modifiées (par un autre utilisateur) " + &
				"entre leur lecture et leur mise à jour. Vous devez annuler et recommencer votre mise à jour."
	lstr_dberror.i_severity = 2
ELSE
	lstr_dberror.i_severity = 3
END IF

// sauver les infos d'erreur dans l'objet error pour réutiliser + tard
error.uf_SaveDBerror(lstr_dberror)

// appel de ue_initial_dberror pour exécuter le code personnalisé éventuel pour l'instance de l'objet en cours
if this.event ue_initial_dberror(lstr_dberror) = 1 then
	return(1)
end if

// rollback ajouté le 16/06/2000 : on verra si ça ne pose jamais de problème...
rollback;

// appel de la fonction d'affichage d'erreur
uf_message_dberror(lstr_dberror)

// return 1 pour ne pas afficher le message PB standard
return (1)

end event

event sqlpreview;// si le traçage du code SQL est demandé, l'afficher
IF gb_sqlspy_on THEN
	w_sqlspy.wf_showsql(this.classname(), sqltype, sqlsyntax, buffer, row)
END IF
end event

