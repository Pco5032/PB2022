//objectcomments Ancêtre pour tous les types de DW control
forward
global type uo_dw from datawindow
end type
end forward

global type uo_dw from datawindow
integer width = 306
integer height = 132
string title = "none"
boolean border = false
borderstyle borderstyle = stylelowered!
event type integer ue_initial_dberror ( str_dberror astr_dberror )
event type integer ue_reset ( )
event we_vscroll pbm_vscroll
event ue_help ( long al_row )
event ue_keypressed pbm_dwnkey
event ue_enterpressed pbm_dwnprocessenter
event ue_synchro ( long al_currentrow )
end type
global uo_dw uo_dw

type prototypes

end prototypes

type variables
dwobject	idwo_currentItem

private:
boolean	ib_canCancelRetrieve, ib_CancelRetrieve, &
			ib_synchronizing, ib_inserting, ib_deleting // variables utilisées pour la synchronisation entre DW
uo_stringservices	iu_stringservices
string	is_excludeSaveList[] // liste de noms de fichiers qui ne peuvent être utilisée pour le saveAs
end variables

forward prototypes
public function any uf_getitemany (long al_row, string as_column, dwbuffer adw_buffer, boolean ab_orig_value)
public function any uf_getitemany (long al_row, string as_column)
public function any uf_getitemany (long al_row, integer ai_column, dwbuffer adw_buffer, boolean ab_orig_value)
public subroutine uf_message_dberror (str_dberror astr_dberror)
public function integer uf_reset ()
public function any uf_getitemany (long al_row, integer ai_column)
public subroutine uf_changedataobject (string as_dataobject)
public function integer uf_isretrievecanceled (long al_row)
public subroutine uf_cancelretrieve ()
public subroutine uf_cancancelretrieve (boolean ab_can)
public subroutine uf_inserting (boolean ab_inserting)
public function boolean uf_inserting ()
public function boolean uf_synchronizing ()
public subroutine uf_synchronizing (boolean ab_synchro)
public subroutine uf_deleting (boolean ab_deleting)
public function boolean uf_deleting ()
public function integer uf_saveas ()
public function integer uf_saveas (ref string as_folder, ref string as_filename)
public function integer uf_saveas (ref string as_folder)
public function integer uf_saveas (string as_initfolder, saveastype a_saveastype[], ref string as_folder, ref string as_filename)
public function integer uf_saveas (saveastype a_saveastype[])
public subroutine uf_setexcludesavelist (string as_filelist[])
end prototypes

event ue_initial_dberror;// event déclenché par l'event dberror avant d'exécuter le code standard, afin de pouvoir le personnaliser
// return(0) signifie qu'on exécutera le code standard de dberror après ce code-ci
// return(1) signifie qu'on n'exécutera pas le code standard de dberror après ce code-ci
return(0)
end event

event type integer ue_reset();// event appelé avant la fonction uf_reset() pour permettre sa personnalisation
// ATTENTION : ne pas placer de fonction UF_RESET() ici !!!!!!!!!!
// return 1 si OK (la fonction reset sera exécutée)
// return -1 si pas OK (la fonction reset ne sera pas exécutée)
SetNull(idwo_currentitem)
return(1)
end event

event ue_help(long al_row);string	ls_text, ls_coltype
integer	li_colsize

IF IsNull(idwo_currentitem) THEN return
IF NOT IsValid(idwo_currentitem) THEN return
IF idwo_currentitem.Type <> "column" THEN	return

// pour les DropDownDW uniquement, envoyer ALT DOWN ARROW pour dérouler la liste lors d'une pression sur F1
IF string(idwo_currentitem.edit.style) = "dddw" OR string(idwo_currentitem.edit.style) = "ddlb"THEN
	f_presskey("ADA")
END IF

end event

event ue_keypressed;blob {28} Msg
string	ls_text, ls_coltype
integer	li_colsize
boolean	lb_displayonly

// touche F1 : déclencher event ue_help
IF key = KEYF1! THEN
	this.event post ue_help(this.GetRow())
END IF

// touche F2 : pour les champs de type column, dont le type de données est character d'une longueur > gi_zoomsize,
// on affiche la fenêtre de zoom
IF key = KEYF2! THEN
	IF IsValid(idwo_currentitem) THEN
		IF idwo_currentitem.type = "column" THEN
			ls_coltype = LeftA(idwo_currentitem.coltype, 4)
			IF ls_coltype = "char" THEN
				ls_coltype = MidA(idwo_currentitem.coltype, 6)
				li_colsize = integer(LeftA(ls_coltype, LenA(ls_coltype) - 1))
				IF li_colsize >= gi_zoomsize THEN
					IF idwo_currentitem.edit.style = "edit" AND idwo_currentitem.edit.displayOnly = 'yes' THEN
						lb_displayOnly = TRUE
					END IF
					IF idwo_currentitem.edit.style = "editmask" AND idwo_currentitem.editmask.readOnly = 'yes' THEN
						lb_displayOnly = TRUE
					END IF
					IF string(idwo_currentitem.protect) = "1" OR string(idwo_currentitem.tabSequence) = "0" THEN
						lb_displayOnly = TRUE
					END IF
					ls_text = This.GetText()
					IF f_zoom(ls_text, li_colsize, lb_displayOnly) = 1 THEN
						This.SetText(Message.StringParm)
					END IF
				END IF
			END IF
		END IF
	END IF
END IF

// suite du traitement quand on souhaite que ENTER agisse comme un TAB (voir début du traitement dans ue_enterpressed)
IF gb_enteristab AND key = KEYENTER! AND NOT KeyDown(KeyControl!) THEN
	PeekMessageA(Msg, 0, 256, 264, 1) // suppression du ENTER tappé
	Message.processed = TRUE
	Message.returnvalue = 0
	f_presskey("TAB")
END IF
end event

event ue_enterpressed;// suppression du comportement standard du ENTER si on veut que ENTER agisse comme TAB
// (voir suite du traitement dans ue_keypressed, car quand on met tout ici, il y a un problème (bug?) dans les mle
if gb_enteristab then
	return(1)
end if

end event

public function any uf_getitemany (long al_row, string as_column, dwbuffer adw_buffer, boolean ab_orig_value);//////////////////////////////////////////////////////////////////////////////
//	Public Function:  of_GetItemAny (FORMAT 4) 
//	Arguments:   	al_row			   : The row reference
//   					as_column    		: The column name reference
//   					adw_buffer   		: The dw buffer from which to get the column's data value.
//   					ab_orig_value		: When True, returns the original values that were 
//							  					  retrieved from the database.
//	Returns:			Any - The column value cast to an any datatype
//	Description:	Returns a column's value cast to an any datatype
//////////////////////////////////////////////////////////////////////////////
//	Rev. History	Version
//						5.0   Initial version
//						7.0	Removed test on computed columns.  They can be treated
//								as normal columns.
//////////////////////////////////////////////////////////////////////////////
//	Copyright © 1996-1999 Sybase, Inc. and its subsidiaries.  All rights reserved.  Any distribution of the 
// PowerBuilder Foundation Classes (PFC) source code by other than Sybase, Inc. and its subsidiaries is prohibited.
//////////////////////////////////////////////////////////////////////////////
any	la_value

/*  Determine the datatype of the column and then call the appropriate 
	 GetItemxxx function and cast the returned value */
CHOOSE CASE Lower ( LeftA ( this.Describe ( as_column + ".ColType" ) , 5 ) )

		CASE "char(", "char"		//  CHARACTER DATATYPE
			la_value = This.GetItemString ( al_row, as_column, adw_buffer, ab_orig_value ) 
	
		CASE "date"					//  DATE DATATYPE
			la_value = This.GetItemDate ( al_row, as_column, adw_buffer, ab_orig_value ) 

		CASE "datet"				//  DATETIME DATATYPE
			la_value = This.GetItemDateTime ( al_row, as_column, adw_buffer, ab_orig_value ) 

		CASE "decim"				//  DECIMAL DATATYPE
			la_value = This.GetItemDecimal ( al_row, as_column, adw_buffer, ab_orig_value ) 
	
		CASE "numbe", "long", "ulong", "real", "int"		//  NUMBER DATATYPE	
			la_value = This.GetItemNumber ( al_row, as_column, adw_buffer, ab_orig_value ) 
	
		CASE "time", "times"		//  TIME DATATYPE
			la_value = This.GetItemTime ( al_row, as_column, adw_buffer, ab_orig_value ) 

		CASE ELSE 	
			SetNull ( la_value ) 

END CHOOSE

Return la_value
end function

public function any uf_getitemany (long al_row, string as_column);return uf_getitemany(al_row, as_column, PRIMARY!, FALSE)
end function

public function any uf_getitemany (long al_row, integer ai_column, dwbuffer adw_buffer, boolean ab_orig_value);string ls_columnname 

ls_columnname = This.Describe ( "#" + String(ai_column) + ".name" )

Return uf_GetItemany (al_row, ls_columnname, adw_buffer, ab_orig_value)
end function

public subroutine uf_message_dberror (str_dberror astr_dberror);// passer la structure globale à la fenêtre d'affichage d'erreur
openwithparm (w_dberror,astr_dberror)

end subroutine

public function integer uf_reset ();// appel de l'event ue_reset() qui permet de customizer le reset standard
IF this.event ue_reset() = 1 THEN
	return(this.reset())
ELSE
	return(-1)
END IF
end function

public function any uf_getitemany (long al_row, integer ai_column);string ls_columnname 

ls_columnname = This.Describe ( "#" + String(ai_column) + ".name" )

Return uf_GetItemany (al_row, ls_columnname, PRIMARY!, FALSE)
end function

public subroutine uf_changedataobject (string as_dataobject);// assigne un autre dataobject au DWControl lorsqu'il en utilisait déjà un
This.DataObject = as_dataobject

end subroutine

public function integer uf_isretrievecanceled (long al_row);// fonction à appeler dans retrieverow pour arrêter le retrieve si cela a été demandé,
// ou afficher le nbre de rows lûs sinon
IF NOT ib_CanCancelRetrieve THEN return(0)
IF ib_CancelRetrieve THEN return(1)
IF IsValid(w_cancel) THEN w_cancel.st_rows.text = string(al_row)
return(0)
end function

public subroutine uf_cancelretrieve ();// demande l'interruption du retrieve
ib_CancelRetrieve = TRUE
this.DBCancel()
end subroutine

public subroutine uf_cancancelretrieve (boolean ab_can);// spécifie si le retrieve pourra être interrompu ou pas
ib_canCancelRetrieve = ab_can
end subroutine

public subroutine uf_inserting (boolean ab_inserting);// initialise ib_inserting
// (utilisé pour la synchronisation entre DW)
ib_inserting = ab_inserting

end subroutine

public function boolean uf_inserting ();// renvoie la valeur de ib_inserting
// (utilisé pour la synchronisation entre DW)
return(ib_inserting)
end function

public function boolean uf_synchronizing ();// renvoie la valeur de ib_synchronizing
// (utilisé pour la synchronisation entre DW)
return(ib_synchronizing)
end function

public subroutine uf_synchronizing (boolean ab_synchro);// initialise ib_synchronizing
// (utilisé pour la synchronisation entre DW)
ib_synchronizing = ab_synchro

end subroutine

public subroutine uf_deleting (boolean ab_deleting);// initialise ib_deleting
// (utilisé pour la synchronisation entre DW)
ib_deleting = ab_deleting

end subroutine

public function boolean uf_deleting ();// renvoie la valeur de ib_deleting
// (utilisé pour la synchronisation entre DW)
return(ib_deleting)

end function

public function integer uf_saveas ();string	ls_data1, ls_data2

return(uf_saveas("", {XLSX!, PDF!, Text!, CSV!, SQLInsert!, WMF!, HTMLTable!, XML!, Excel8!}, ls_data1, ls_data2))
//return(uf_saveas("", {Excel8!, Text!, CSV!, SQLInsert!, WMF!, HTMLTable!, XML!}, ls_data1, ls_data2))

end function

public function integer uf_saveas (ref string as_folder, ref string as_filename);return(uf_saveas(as_folder, {XLSX!, PDF!, Text!, CSV!, SQLInsert!, WMF!, HTMLTable!, XML!, Excel8!}, as_folder, as_filename))
// return(uf_saveas(as_folder, {Excel8!, Text!, CSV!, SQLInsert!, WMF!, HTMLTable!, XML!}, as_folder, as_filename))

end function

public function integer uf_saveas (ref string as_folder);string	ls_data

return(uf_saveas(as_folder, {XLSX!, PDF!, Text!, CSV!, SQLInsert!, WMF!, HTMLTable!, XML!, Excel8!}, as_folder, ls_data))
// return(uf_saveas(as_folder, {Excel8!, Text!, CSV!, SQLInsert!, WMF!, HTMLTable!, XML!}, as_folder, ls_data))

end function

public function integer uf_saveas (string as_initfolder, saveastype a_saveastype[], ref string as_folder, ref string as_filename);// as_initfolder : dossier de stockage proposé par défaut
// a_saveastype[] : liste des formats de fichiers possibles (excel, texte...)
// as_folder = nom du dossier sélectionné
// as_filename = nom du fichier créé
// return(1) si OK, et dans ce cas les arguments as_folder et as_filename sont initialisés
// return(0) si opération abandonnée par l'utilisateur
// return(-1) en cas d'erreur

integer		li_type, li_ret, li_i
string		ls_filter, ls_suffix, ls_pathname, ls_data
boolean		lb_valid
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
// PCO 06/03/20174 : pouvoir enregistrer sous XLSX requiert la présence d'une DLL "Sybase.PowerBuilder.DataWindow.Excel12"
// dans les "assembly" de Windows, dossier C:\Windows\Microsoft.NET\assembly\GAC_MSIL. 
// Cela nécessite une installation et les droits pour le faire, ce qui est trop lourd. 
// J'ai donc désactivé cette option.
// PCO 06/01/2021 : en test avec PB2019R2 qui nécessite toujours la DLL, mais dans le dossier de l'appli et non dans le GAC Windows.
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

// seule solution que j'ai trouvé pour afficher un nom de fichier par défaut, que l'on aie ou non
// spécifié un folder par défaut dans as_initfolder
// PCO 07/12/2022 : si le dossier par défaut n'est pas spécifié, utiliser le dossier "Documents" de windows.
IF f_isEmptyString(as_initfolder) THEN
	as_initfolder = gs_mydocuments
END IF
IF NOT f_isEmptyString(as_initfolder) AND NOT f_isEmptyString(as_filename) THEN
	ls_pathname = as_initfolder + "\" + as_filename
END IF

// choix du dossier et nom du fichier
DO
	// PCO OCT 2016 : flag 2(voir PB help)
	IF GetFileSaveName("Sauver dans un fichier", ls_pathname, as_filename, "", ls_filter, as_initfolder, 2) <= 0 THEN
		return(0)
	END IF
	
	lb_valid = TRUE
	
	// vérifier que le nom de fichier choisi (folder non compris) n'est pas dans la liste d'exclusion
	FOR li_i = 1 TO UpperBound(is_excludeSaveList)
		IF upper(as_filename) = upper(is_excludeSaveList[li_i]) THEN
			gu_message.uf_info("Ce nom de fichier est réservé au système, veuillez en choisir un autre.")
			lb_valid = FALSE
			EXIT
		END IF
	NEXT

	// écraser ou pas le fichier s'il existe déjà
	IF lb_valid THEN
		lu_fileservices = CREATE uo_fileservices
		lu_fileservices.uf_basename(ls_pathname, FALSE, as_folder, ls_data, ls_suffix)
		DESTROY lu_fileservices
		IF FileExists(ls_pathname) THEN
			IF gu_message.uf_query("Sauver dans un fichier", "Le fichier " + ls_pathname + " existe déjà.~nVoulez-vous le remplacer ?", 2) = 2 THEN
				lb_valid = FALSE
			END IF
		END IF
	END IF
LOOP WHILE NOT lb_valid

// en fonction de l'extension du fichier, déterminer le type choisi
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
// PCO 06/03/20174 : pouvoir enregistrer sous XLSX requiert la présence d'une DLL "Sybase.PowerBuilder.DataWindow.Excel12"
// dans les "assembly" de Windows, dossier C:\Windows\Microsoft.NET\assembly\GAC_MSIL. 
// Cela nécessite une installation et les droits pour le faire, ce qui est trop lourd. 
// J'ai donc désactivé cette option.
// PCO 06/01/2021 : en test avec PB2019R2 qui nécessite toujours la DLL, mais dans le dossier de l'appli et non dans le GAC Windows.
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

public function integer uf_saveas (saveastype a_saveastype[]);string	ls_data1, ls_data2

return(uf_saveas("", a_saveastype[], ls_data1, ls_data2))

end function

public subroutine uf_setexcludesavelist (string as_filelist[]);is_excludeSaveList = as_filelist
end subroutine

on uo_dw.create
end on

on uo_dw.destroy
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

// poster fonction pour afficher l'erreur et continuer l'event dberror
// post uf_message_dberror(str_dberr)

// rectification : trigger et non post car poster l'affichage d'une fenêtre modale provoque des trucs bizarres 
// (par ex. le non affichage de cette fenêtre)
uf_message_dberror(lstr_dberror)

// return 1 pour ne pas afficher le message PB standard
return (1)
end event

event sqlpreview;// si le traçage du code SQL est demandé, l'afficher
IF gb_sqlspy_on THEN
	w_sqlspy.wf_showsql(Parent.classname() + "." + this.classname(), sqltype, sqlsyntax, buffer, row)
END IF

end event

event rbuttondown;window	lw_parent
IF f_GetParentWindow(this, lw_parent) = 1 THEN
	IF lw_parent.windowtype <> Response! THEN f_PopupAction(lw_parent)
END IF
end event

event doubleclicked;this.event post ue_help(row)
end event

event itemfocuschanged;idwo_currentitem = dwo

IF GetFocus() = This THEN
	gw_mdiframe.SetMicroHelp(f_gethelpmsg(dwo.tag))
END IF
end event

event getfocus;IF IsNull(idwo_currentitem) THEN return
IF IsValid(idwo_currentitem) THEN
	IF idwo_currentitem.type <> "datawindow" THEN
		gw_mdiframe.SetMicroHelp(f_gethelpmsg(idwo_currentitem.tag))
	END IF
END IF

end event

event losefocus;gw_mdiframe.SetMicroHelp("")
end event

event clicked;// affichage microhelp si on clique sur un champ (fonctionne même si champ non éditable)
IF IsValid(dwo) THEN
	IF dwo.type <> "datawindow" THEN
		gw_mdiframe.SetMicroHelp(f_gethelpmsg(dwo.tag))
	END IF
END IF
end event

event retrievestart;ib_CancelRetrieve = FALSE
IF ib_canCancelRetrieve THEN
	open(w_cancel)
END IF
end event

event retrieveend;IF ib_canCancelRetrieve AND IsValid(w_cancel) THEN 
	close(w_cancel)
END IF
IF ib_canCancelRetrieve AND ib_CancelRetrieve THEN
	// seul moyen trouvé pour réinitialiser la transaction après un DBCancel()...
	uo_resetsqlca	lu_reset
	lu_reset = CREATE uo_resetsqlca
	DESTROY lu_reset
END IF
ib_CancelRetrieve = FALSE
end event

event constructor;ib_canCancelRetrieve = FALSE
ib_CancelRetrieve = FALSE
ib_synchronizing = FALSE
ib_inserting = FALSE
ib_deleting = FALSE
end event

