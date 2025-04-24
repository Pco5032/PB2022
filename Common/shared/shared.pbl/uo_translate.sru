forward
global type uo_translate from nonvisualobject
end type
end forward

global type uo_translate from nonvisualobject
end type
global uo_translate uo_translate

type prototypes
FUNCTION uint  LocalizedMessageBox (long a, string b, string c, long d ,string e ) LIBRARY "g3.dll" alias for "LocalizedMessageBox;Ansi"  
FUNCTION ulong GetActiveWindow ( ) LIBRARY "USER32.dll"  alias for "GetActiveWindow;Ansi"  
end prototypes

type variables
PROTECTED String		is_lang, is_sepprop = '@'
PROTECTED boolean	ib_mustTranslate // indique si l'application doit être traduite ou pas
PROTECTED CONSTANT	integer ICI_COMPOSITE=5
PROTECTED uo_ds		ids_translation

//CONSTANT Long CI_OK=0
//CONSTANT Long CI_OKCANCEL=1
//CONSTANT Long CI_ABORTRETRYIGNORE=2
//CONSTANT Long CI_YESNOCANCEL=3
//CONSTANT Long CI_YESNO=4
//CONSTANT Long CI_RETRYCANCEL=5
//CONSTANT Long CI_ICONHAND=16
//CONSTANT Long CI_ICONQUESTION=32
//CONSTANT Long CI_ICONEXCLAMATION=48
//CONSTANT Long CI_ICONASTERISK=64
//CONSTANT Long CI_DEFBUTTON1=0
//CONSTANT Long CI_DEFBUTTON2=256
//CONSTANT Long CI_DEFBUTTON3=512
//CONSTANT Long CI_DEFBUTTON4=768
//CONSTANT Long CI_NOFOCUS=32768
//CONSTANT Long CI_APPLMODAL=0
//CONSTANT Long CI_SYSTEMMODAL=4096
//CONSTANT Long CI_TASKMODAL=8192
//CONSTANT Long CI_HELP=16384
//CONSTANT Long CI_SETFOREGROUND=65536
//CONSTANT Long CI_DEFAULT_DESKTOP_ONLY=131072
//CONSTANT Long CI_TOPMOST=262144
//CONSTANT Long CI_RIGHT=524288
//CONSTANT Long CI_RTLREADING=1048576
end variables

forward prototypes
public function integer uf_messagebox (string as_title, string as_text, icon aicon, button abutton, integer ai_return)
public function string uf_getlabel (string as_code, string as_default)
private function integer _datawindowgetobject (ref datawindow adw_data, ref string as_list[])
private function integer _datawindowchildgetobjects (ref datawindowchild adwc_data, ref string as_list[])
private function integer _datastoregetobjects (ref datastore ads_data, ref string as_list[])
public function integer uf_localizedmessagebox (string as_title, string as_text, icon aicon, button abutton, integer ai_return)
private function string _findcode (string as_tag)
private function integer _translatechildreport (ref datawindowchild adwc_data)
private function integer _translateprintdatastore (ref datastore ads_data)
public function string uf_getlanguage ()
public function integer uf_translatewindow (window aw_window)
public subroutine uf_translatemenu (ref menu am_menu)
public function integer uf_translatedw (ref datawindow adw_data)
public function integer uf_translateds (ref datastore ads_data)
public subroutine uf_translatecontrol (powerobject apo_control)
public function integer uf_setlanguage (string as_lang)
public function boolean uf_musttranslate ()
end prototypes

public function integer uf_messagebox (string as_title, string as_text, icon aicon, button abutton, integer ai_return);Long ll_res

ll_res = This.uf_localizedmessagebox(as_title, as_text, aicon, abutton, ai_return)

Return(ll_res)
end function

public function string uf_getlabel (string as_code, string as_default);// Recherche le TAG passé en argument dans ids_translation et renvoie le texte correspondant.
// Si TAG n'existe pas, renvoie as_default.
String	ls_ret

ls_ret = _findcode(as_code)
IF f_isEmptyString(ls_ret) THEN
	ls_ret = as_default
END IF

Return(ls_ret)
end function

private function integer _datawindowgetobject (ref datawindow adw_data, ref string as_list[]);// Accepte un DW comme argument et renvoie un array contenant la liste de ses objects.
// return : nombre d'objects dans le DW
// by ref : as_list[] contient la liste des objects
String	ls_ObjString, ls_ObjHolder
Integer	li_StartPos, li_TabPos, li_Count

// Store a list of the controls in the DataWindow object. The names are returned as a tab-separated list.
ls_ObjString = adw_data.describe("Datawindow.Objects")
li_StartPos = 1
li_TabPos = pos(ls_ObjString, "~t", li_StartPos)

DO WHILE li_TabPos > 0
	ls_ObjHolder = mid(ls_ObjString, li_StartPos, (li_TabPos - li_StartPos))
	li_Count = li_Count + 1
	as_list[li_Count] = ls_ObjHolder
	li_StartPos = li_TabPos + 1
	li_TabPos = POS(ls_ObjString, "~t", li_StartPos)
LOOP
ls_ObjHolder = MID(ls_ObjString, li_StartPos, LEN(ls_ObjString))
li_Count = li_Count + 1
as_list[li_Count] = ls_ObjHolder

return(li_Count)

end function

private function integer _datawindowchildgetobjects (ref datawindowchild adwc_data, ref string as_list[]);// Accepte un DWChild comme argument et renvoie un array contenant la liste de ses objects.
// return : nombre d'objects dans le DWChild
// by ref : as_list[] contient la liste des objects
String	ls_ObjString, ls_ObjHolder
Integer	li_StartPos, li_TabPos, li_Count

// Store a list of the controls in the DataWindowChild object. The names are returned as a tab-separated list.
ls_ObjString = adwc_data.describe("Datawindow.Objects")
li_StartPos = 1
li_TabPos = pos(ls_ObjString, "~t", li_StartPos)

DO WHILE li_TabPos > 0
	ls_ObjHolder = mid(ls_ObjString, li_StartPos, (li_TabPos - li_StartPos))
	li_Count = li_Count + 1
	as_list[li_Count] = ls_ObjHolder
	li_StartPos = li_TabPos + 1
	li_TabPos = POS(ls_ObjString, "~t", li_StartPos)
LOOP
ls_ObjHolder = MID(ls_ObjString, li_StartPos, LEN(ls_ObjString))
li_Count = li_Count + 1
as_list[li_Count] = ls_ObjHolder

return(li_Count)

end function

private function integer _datastoregetobjects (ref datastore ads_data, ref string as_list[]);// Accepte un DS comme argument et renvoie un array contenant la liste de ses objects.
// return : nombre d'objects dans le DS
// by ref : as_list[] contient la liste des objects
String	ls_ObjString, ls_ObjHolder
Integer	li_StartPos, li_TabPos, li_Count

// Store a list of the controls in the DataWindow object. The names are returned as a tab-separated list.
ls_ObjString = ads_data.describe("Datawindow.Objects")
li_StartPos = 1
li_TabPos = pos(ls_ObjString, "~t", li_StartPos)

DO WHILE li_TabPos > 0
	ls_ObjHolder = mid(ls_ObjString, li_StartPos, (li_TabPos - li_StartPos))
	li_Count = li_Count + 1
	as_list[li_Count] = ls_ObjHolder
	li_StartPos = li_TabPos + 1
	li_TabPos = POS(ls_ObjString, "~t", li_StartPos)
LOOP
ls_ObjHolder = MID(ls_ObjString, li_StartPos, LEN(ls_ObjString))
li_Count = li_Count + 1
as_list[li_Count] = ls_ObjHolder

return(li_Count)

end function

public function integer uf_localizedmessagebox (string as_title, string as_text, icon aicon, button abutton, integer ai_return);////************************************************************
//// Object: nvo_translate
//// Method: uf_localizedmessagebox
//// Author: FDE
//// Date  : 6/03/2015
////
//// Arg   :
//// Return: integer
////
//// Desc  :	appel de g3.dll pour traduire les bouttons de messagebox
////
////************************************************************
//// Modifications:
//// Date           		Author			Comments
////------------------------------------------------------------
//// 6/03/2015		FDE				Initial
////************************************************************
// 
//long ll_flag
//int ll_res
//long ll_handle 
//string ls_language
//
//ls_language = is_lang
//
//ll_handle = This.GetActiveWindow()
//
//Choose Case aicon
//	Case exclamation! 
//		ll_flag += ci_ICONEXCLAMATION
//	Case information! 
//		ll_flag += ci_ICONASTERISK
//	Case question! 
//		ll_flag += ci_ICONQUESTION
//	Case stopsign! 
//		ll_flag += ci_ICONHAND
//End Choose
//	
//Choose Case  abutton
//	Case abortretryignore! 
//		ll_flag += ci_ABORTRETRYIGNORE
//	Case okcancel! 
//		ll_flag += ci_OKCANCEL
//	Case retrycancel! 
//		ll_flag += ci_RETRYCANCEL
//	Case yesno! 
//		ll_flag += ci_YESNO
//	Case yesnocancel! 
//		ll_flag += ci_YESNOCANCEL
//End Choose
//	
//Choose Case ai_return
//	Case 2
//		ll_flag +=ci_DEFBUTTON2
//	Case 3
//		ll_flag +=ci_DEFBUTTON3
//	Case 4
//		ll_flag +=ci_DEFBUTTON4
//End Choose
//
//ll_res = This.LocalizedMessageBox(ll_handle, as_text, as_title, ll_flag, ls_language)
//
//Choose Case abutton
//	Case abortretryignore! 
//		ll_res -= 2
//	Case retrycancel! 
//		ll_res /= 2
//	Case yesno! 
//		ll_res -=  5
//	Case yesnocancel! 
//		if ll_res > 5 then 
//			ll_res -= 5 // yes no
//		else
//			ll_res = 3 // cancel
//		end if
//End Choose
//
//Return ll_res
return(-1)
end function

private function string _findcode (string as_tag);// Recherche le TAG passé en argument dans ids_translation et renvoie le texte correspondant.
// Si TAG n'existe pas, renvoie string vide (not null)
String 	ls_string, ls_find
Long		ll_count, ll_find

IF NOT f_isEmptyString(as_tag) THEN
	If IsValid(ids_translation) Then
		ll_count = ids_translation.RowCount()
		If ll_count > 0 Then
			ls_find = "Upper(Trim(tag_code)) = '" + Upper(Trim(as_tag)) + "'"
			ll_find = ids_translation.Find(ls_find, 1, ll_count)
			If Not(IsNull(ll_find)) And ll_find > 0 Then
				ls_string = Trim(string(ids_translation.object.tag_label[ll_find]))
			ELSE
				ls_string = ''
			End if
		ELSE
			ls_string = ''
		End if
	ELSE
		ls_string = ''
	End If 
ELSE
	ls_string = ''
END IF

Return(ls_string)
end function

private function integer _translatechildreport (ref datawindowchild adwc_data);integer	li_Bound, li_Ind, li_rtn
string	ls_objectlist[], ls_Tag, ls_temp, ls_text, ls_type, ls_style
datawindowchild	ldwc_child

// Charge dans ls_objectlist la liste des contrôles du DWchild
li_Bound = _DataWindowChildGetobjects(adwc_data, ls_objectlist)

for li_Ind = 1 to li_Bound
	ls_Tag = adwc_data.describe(ls_objectlist[li_Ind] + ".TAG" )
	if Trim(ls_Tag) <> "" AND ls_Tag <> "?" Then
		ls_text = _findcode(ls_Tag)
		IF f_isEmptyString(ls_text) THEN CONTINUE
		IF Pos(ls_text, "'") > 0 THEN
			ls_text = "~"" + ls_text + "~""
		ELSE
			ls_text = "'" + ls_text + "'"
		END IF
		//
		// Check the Edit Style
		//
		ls_temp = adwc_data.Describe(ls_objectlist[li_Ind] + ".Edit.Style")
		Choose Case adwc_data.Describe(ls_objectlist[li_Ind] + ".Edit.Style")
			Case "checkbox"
				adwc_data.Modify(ls_objectlist[li_Ind] + ".CheckBox.TEXT = " + ls_text)
			Case 'column'
				ls_style = adwc_data.Describe(ls_objectlist[li_Ind] + ".CheckBox.On")
				If ls_style = '?' Then
					ls_style = adwc_data.Describe(ls_objectlist[li_Ind] + ".RadioButtons.Columns")
					If ls_style = '?' Then
						adwc_data.Modify(ls_objectlist[li_Ind] + ".CheckBox.TEXT = ")
					Else
						adwc_data.modify(ls_objectlist[li_Ind] + ".TEXT = " + ls_text)
					End if
				Else
					adwc_data.Modify(ls_objectlist[li_Ind] + ".CheckBox.TEXT = " + ls_text)
				End if	
			Case Else
				adwc_data.modify(ls_objectlist[li_Ind] + ".TEXT = " + ls_text)
		End Choose
	Else
		// Maybe a report
		ls_type = adwc_data.Describe(ls_objectlist[li_Ind] + ".Type")
		If Lower(Trim(ls_type)) = 'report' Then
			li_rtn = adwc_data.GetChild(ls_objectlist[li_Ind], ldwc_child)
			IF li_rtn = 1 THEN 
				This._TranslateChildReport(ldwc_child)
			END IF
		End if
	end if
next

return(1)
end function

private function integer _translateprintdatastore (ref datastore ads_data);integer	li_Bound, li_Ind
string	ls_objectlist[], ls_Tag, ls_temp, ls_text, ls_style
datawindowchild	ldwc_child

// Charge dans ls_objectlist la liste des contrôles du DS
li_Bound = _DataStoreGetobjects(ads_data, ls_objectlist)

FOR li_Ind = 1 TO li_Bound
	ls_Tag = ads_data.describe(ls_objectlist[li_Ind] + ".TAG")
	if Trim(ls_Tag) <> "" AND ls_Tag <> "?" Then
		ls_text = _findcode(ls_Tag)
		IF f_isEmptyString(ls_text) THEN CONTINUE
		IF Pos(ls_text, "'") > 0 THEN
			ls_text = "~"" + ls_text + "~""
		ELSE
			ls_text = "'" + ls_text + "'"
		END IF
		//
		// Check the Edit Style
		//
		ls_temp = ads_data.Describe(ls_objectlist[li_Ind] + ".Edit.Style")
		Choose Case ads_data.Describe(ls_objectlist[li_Ind] + ".Edit.Style")
			Case "checkbox"
				ads_data.Modify(ls_objectlist[li_Ind] + ".CheckBox.TEXT = " + ls_text)
			Case "ddlb","radiobuttons"
				ads_data.Modify(ls_objectlist[li_Ind] + ".Values = " + ls_text)
			Case 'column'
				ls_style = ads_data.Describe(ls_objectlist[li_Ind] + ".CheckBox.On")
				If ls_style = '?' Then
					ls_style = ads_data.Describe(ls_objectlist[li_Ind] + ".RadioButtons.Columns")
					If ls_style = '?' Then
						ads_data.Modify(ls_objectlist[li_Ind] + ".CheckBox.TEXT = " + ls_text)
					Else
						ads_data.modify(ls_objectlist[li_Ind] + ".TEXT = " + ls_text)
					End if
				Else
					ads_data.Modify(ls_objectlist[li_Ind] + ".CheckBox.TEXT = " + ls_text)
				End if	
			Case Else
				ads_data.modify(ls_objectlist[li_Ind] + ".TEXT = " + ls_text)
		End Choose
	end if
NEXT

return(1)
end function

public function string uf_getlanguage ();// renvoie la langue courante
Return(is_lang)
end function

public function integer uf_translatewindow (window aw_window);// Traduction de la fenêtre passée en argument (son titre et les contrôles qui s'y trouvent)
// return : 1
string	ls_Tag, ls_text
integer	li_Bound, li_Ind

// traduction du titre de la fenêtre
ls_tag = aw_window.TAG
If Trim(ls_tag) <> "" Then
	ls_text = _findcode(ls_tag)
	IF NOT f_isEmptyString(ls_text) THEN
		aw_window.TITLE = ls_text
	END IF
End if

// traiter les contrôles contenus dans la fenêtre
li_Bound = upperbound(aw_window.control[])
FOR li_Ind = 1 TO li_Bound
	this.uf_TranslateControl(aw_window.control[li_Ind])
NEXT

return(1)
end function

public subroutine uf_translatemenu (ref menu am_menu);// Traduit tous les menu-items et du menu am_menu passé en argument. Cette fonction est appelée 
// récursivement pour traduire les sous-menuitems.
//	return : none
//
//	Dans la table de traduction, le texte doit être constitué comme suit, mais seul le "texte du menu"
// est indispensable : texte de menu@texte du microhelp@texte du tooltip
//
string	ls_Tag, ls_text, ls_col, las_col[]
CONSTANT integer li_itemtext = 1, li_MicroHelp = 2, li_ToolbarItemText = 3, li_shortcut = 4
integer	li_Ind, li_Bound, li_SubBound

if isnull(am_menu) then return
if not isvalid(am_menu) then return

// Loop on menu Item
li_Bound = UpperBound(am_menu.item[])
FOR li_Ind= 1 TO li_Bound
	// PCO pourquoi ne traiter que les invisibles ? Ils deviendront peut-être visibles ultérieurement !
	// if am_menu.item[li_Ind].visible then
		ls_Tag = (am_menu.item[li_Ind].TAG)
		IF (ls_Tag <> "" ) And pos(ls_Tag, ']') <= 0 THEN 
			ls_text = _FindCode(ls_Tag)
			IF NOT f_isEmptyString(ls_text) THEN
				// le texte de la table TAG peut comporter jusqu'à 4 sections décomposées ici
				f_parse(ls_text, is_sepprop, las_col)
				// attribuer les propriétés à l'élément de menu en cours
				// texte du menu
				IF upperbound(las_col) >= li_itemText AND NOT f_isEmptyString(las_col[li_itemText]) THEN
					am_menu.item[li_Ind].TEXT = las_col[li_itemText]
				END IF
				// texte microhelp
				IF upperbound(las_col) >= li_MicroHelp AND NOT f_isEmptyString(las_col[li_itemText]) THEN	
					am_menu.item[li_Ind].MICROHELP = las_col[li_MicroHelp]
				END IF
				// texte toolbarItem
				IF upperbound(las_col) >= li_ToolbarItemText AND NOT f_isEmptyString(las_col[li_itemText]) THEN
					am_menu.item[li_Ind].TOOLBARITEMTEXT = las_col[li_ToolbarItemText]
				END IF
				// info sur le raccourci clavier.
				// ! : le texte correspondant au raccourci clavier est concaténé au texte de l'élément de menu,
				//     il doit correspondre au raccourci réel programmé !
				// The problem is that the shortcut key's aren't actually a 'property' of the menu, so it can't
				// be determined at runtime.
				IF upperbound(las_col) = li_shortcut AND NOT f_isEmptyString(las_col[li_itemText]) THEN
					am_menu.item[li_Ind].TEXT = am_menu.item[li_Ind].TEXT + "~t" + las_col[li_shortcut]
				END IF
			END IF
		END IF

		li_SubBound = UpperBound(am_menu.item[li_Ind].item[])
		IF li_SubBound > 0 then uf_TranslateMenu(am_menu.item[li_Ind])
//	end if
NEXT

end subroutine

public function integer uf_translatedw (ref datawindow adw_data);// Traduit le contenu du DW adw_data passé en argument
// return(1)
integer	li_Bound, li_Ind, li_count, li_col, li_rtn
string	ls_objectlist[], ls_Tag, ls_temp, ls_text, ls_lang_object
string	ls_style, ls_type, ls_expression, ls_dddw_name, ls_display_col, ls_datacol
datawindowchild	ldwc_child

// Charge dans ls_objectlist la liste des contrôles du DW
li_Bound = _DataWindowGetobject(adw_data, ls_objectlist)

FOR li_Ind = 1 TO li_Bound
	ls_Tag = adw_data.describe(ls_objectlist[li_Ind] + ".TAG")

	IF Trim(ls_Tag) <> "" AND Trim(ls_Tag) <> "?" And Trim(Upper(ls_Tag)) <> 'NT' And Pos(ls_Tag,']') <= 0 THEN
		ls_text = _findcode(ls_Tag)
		IF f_isEmptyString(ls_text) THEN CONTINUE
		IF Pos(ls_text, "'") > 0 THEN
			ls_text = "~"" + ls_text + "~""
		ELSE
			ls_text = "'" + ls_text + "'"
		END IF
		//
		// Check the Edit Style
		//
		ls_temp = adw_data.Describe(ls_objectlist[li_Ind] + ".Edit.Style")
		Choose Case ls_temp
			Case "checkbox"
				adw_data.Modify(ls_objectlist[li_Ind] + ".CheckBox.TEXT = " + ls_text)
			Case 'column'
				ls_style = adw_data.Describe(ls_objectlist[li_Ind] + ".CheckBox.On")
				If ls_style = '?' Then
					ls_style = adw_data.Describe(ls_objectlist[li_Ind] + ".RadioButtons.Columns")
					If ls_style = '?' Then
						adw_data.Modify(ls_objectlist[li_Ind] + ".CheckBox.TEXT = " + ls_text)
					Else
						adw_data.modify(ls_objectlist[li_Ind] + ".TEXT = " + ls_text)
					End if
				Else
					adw_data.Modify(ls_objectlist[li_Ind] + ".CheckBox.TEXT = " + ls_text)
				End if
			Case Else
				adw_data.modify(ls_objectlist[li_Ind] + ".TEXT = " + ls_text)
		End Choose
	Else
		// Maybe a report
		ls_type = adw_data.Describe(ls_objectlist[li_Ind] + ".Type")
		If Lower(Trim(ls_type)) = 'report' Then
			// PCO : getChild fonctionne pour les composite, pas pour les nested. On tente en forçant
			// la propriété processing=5 (composite) !
			adw_data.object.Datawindow.processing = ICI_COMPOSITE
			li_rtn = adw_data.GetChild(ls_objectlist[li_Ind], ldwc_child)
			IF li_rtn = 1 THEN 
				This._TranslateChildReport(ldwc_child)
			END IF
		End if
	END IF
NEXT

// Traitement spécifique pour les DDDW : remplacement du dddw d'une langue par une autre.
// Autre possibilité : dans la propriété TEXT ou expression des items du DDDW, utiliser la fonction globale 
// f_translate_getlabel().
// Pas testé mais à vérifier : passer par la fonction de traduction d'un DWChild :
//			li_rtn = adw_data.GetChild(ls_datacol, ldwc_child)
//			IF li_rtn = 1 THEN 
//				This._TranslateChildReport(ldwc_child)
//			END IF
li_count = Integer(adw_data.Describe("DataWindow.Column.Count"))
FOR li_col = 1 TO li_count
	IF	adw_data.Describe("#" + String(li_col) + ".Edit.Style") <> "0" THEN
		ls_expression = adw_data.Describe("#" + String(li_col) + ".Edit.Style")
		If ls_expression = 'dddw' Then
			ls_dddw_name = adw_data.Describe("#" + String(li_col) + ".dddw.Name")
			IF ls_dddw_name <> "?" THEN
				ls_display_col = adw_data.Describe("#" + String(li_col) + ".dddw.DisplayColumn")
				ls_datacol = adw_data.Describe("#" + String(li_col) + ".dddw.DataColumn")
				// les 2 derniers caractères du nom du DDDW doivent indiquer la langue actuelle (fr ou de)
				ls_lang_object = Lower(Right(ls_dddw_name,2))				
				If ls_lang_object = 'fr' Or ls_lang_object = 'de' Then
					ls_dddw_name = gu_stringservices.uf_replaceall(ls_dddw_name, '_' + ls_lang_object, '_' + Lower(is_lang))
					adw_data.Modify("#" + String(li_col) + ".DDDW.Name = " + ls_dddw_name)
					adw_data.Modify("#" + String(li_col) + ".DDDW.DataColumn = '" + ls_datacol + "'")
					adw_data.Modify("#" + String(li_col) + ".DDDW.DisplayColumn = '" + ls_display_col + "'")
				End if
			End if
		End if
	End if
NEXT

return(1)
end function

public function integer uf_translateds (ref datastore ads_data);integer	li_Bound, li_Ind, li_count, li_col
string	ls_objectlist[], ls_Tag, ls_temp, ls_text, ls_lang_object, ls_style, ls_type
string	ls_expression, ls_dddw_name, ls_display_col, ls_datacol
datawindowchild	ldwc_child

// Charge dans ls_objectlist la liste des contrôles du DW
li_bound = _DataStoreGetobjects(ads_data, ls_objectlist)

FOR li_Ind = 1 TO li_Bound
	ls_Tag = ads_data.describe(ls_objectlist[li_Ind] + ".TAG")

	if Trim(ls_Tag) <> "" AND Trim(ls_Tag) <> "?" And Trim(Upper(ls_Tag)) <> 'NT' And Pos(ls_Tag,']') <= 0 Then
		ls_text = _findcode(ls_Tag)
		IF f_isEmptyString(ls_text) THEN CONTINUE
		IF Pos(ls_text, "'") > 0 THEN
			ls_text = "~"" + ls_text + "~""
		ELSE
			ls_text = "'" + ls_text + "'"
		END IF
		//
		// Check the Edit Style
		//
		ls_temp = ads_data.Describe(ls_objectlist[li_Ind] + ".Edit.Style")
		Choose Case ls_temp
			Case "checkbox"
				ads_data.Modify(ls_objectlist[li_Ind] + ".CheckBox.TEXT = " + ls_text)
			Case 'column'
				ls_style = ads_data.Describe(ls_objectlist[li_Ind] + ".CheckBox.On")
				If ls_style = '?' Then
					ls_style = ads_data.Describe(ls_objectlist[li_Ind] + ".RadioButtons.Columns")
					If ls_style = '?' Then
						ads_data.Modify(ls_objectlist[li_Ind] + ".CheckBox.TEXT = " + ls_text)
					Else
						ads_data.modify(ls_objectlist[li_Ind] + ".TEXT = " + ls_text)
					End if
				Else
					ads_data.Modify(ls_objectlist[li_Ind] + ".CheckBox.TEXT = " + ls_text)
				End if
			Case Else
				ads_data.modify(ls_objectlist[li_Ind] + ".TEXT = " + ls_text)
		End Choose
	Else
		// Maybe a report
		ls_type = ads_data.Describe(ls_objectlist[li_Ind] + ".Type")
		If Lower(Trim(ls_type)) = 'report' Then
			ads_data.GetChild(ls_objectlist[li_Ind], ldwc_child)
			This._TranslateChildReport(ldwc_child)
		End if
	end if
next

// traitement spécifique pour les DDDW : remplacement du dddw d'une langue par une autre
li_count = Integer(ads_data.Describe("DataWindow.Column.Count"))
FOR li_col = 1 TO li_count
	IF	ads_data.Describe("#" + String(li_col) + ".Edit.Style") <> "0" THEN
		ls_expression = ads_data.Describe("#" + String(li_col) + ".Edit.Style")
		If ls_expression = 'dddw' Then
			ls_dddw_name = ads_data.Describe("#" + String(li_col) + ".dddw.Name")
			IF ls_dddw_name <> "?" THEN
				ls_display_col = ads_data.Describe("#" + String(li_col) + ".dddw.DisplayColumn")
				ls_datacol = ads_data.Describe("#" + String(li_col) + ".dddw.DataColumn")
				// les 2 derniers caractères du nom du DDDW indiquent la langue actuelle (fr ou de)
				ls_lang_object = Lower(Right(ls_dddw_name,2))
				// Replace only if lang is valid
				// 06/05/2015 RTH -- HM 2015 ajout commentaire : test de la langue pour les DDDW
				If ls_lang_object = 'fr' Or ls_lang_object = 'de' Then
					ls_dddw_name = gu_stringservices.uf_replaceall(ls_dddw_name, '_' + ls_lang_object, '_' + Lower(is_lang))
					ads_data.Modify("#" + String(li_col) + ".DDDW.Name = " + ls_dddw_name)
					ads_data.Modify("#" + String(li_col) + ".DDDW.DataColumn = '" + ls_datacol + "'")
					ads_data.Modify("#" + String(li_col) + ".DDDW.DisplayColumn = '" + ls_display_col + "'")
				End if
			End if
		End if
	End if
NEXT

return(1)
end function

public subroutine uf_translatecontrol (powerobject apo_control);// traduire le contrôle apo_control passé en argument, en fonction de son type.
integer	li_Bound, li_Bound2, li_Ind, li_Ind2, li_NbrItem
string	ls_Tag, ls_Item[], ls_Data, ls_class, ls_type, ls_text
GraphicObject	lgo_object

SetPointer(hourglass!)

CHOOSE CASE apo_control.typeof()
	CASE userobject!
		USEROBJECT luo
		luo = apo_control
		// traiter tous les contrôles contenus dans le user-object
		li_Bound = upperbound(luo.control[])
		FOR li_Ind = 1 TO li_Bound
			lgo_Object = luo.control[li_Ind]
			this.uf_TranslateControl(lgo_Object)
		NEXT

	CASE checkbox!
		CHECKBOX lcbx
		lcbx = apo_control
		ls_Tag = lcbx.TAG
		IF (ls_Tag = "") or pos(ls_Tag,']') > 1 THEN return
		ls_text = this._findcode(ls_Tag)
		IF f_isEmptyString(ls_text) THEN return
		lcbx.TEXT = ls_text
	
	CASE commandbutton!
		COMMANDBUTTON lcb
		lcb = apo_control
		ls_Tag = lcb.TAG
		IF (ls_Tag = "") or pos(ls_Tag,']') > 1 THEN return
		ls_text = this._findcode(ls_Tag)
		IF f_isEmptyString(ls_text) THEN return
		lcb.TEXT = ls_text
	
	CASE groupbox!
		GROUPBOX lgb
		lgb = apo_control
		ls_Tag = lgb.TAG
		IF (ls_Tag = "") or pos(ls_Tag,']') > 1 THEN return
		ls_text = this._findcode(ls_Tag)
		IF f_isEmptyString(ls_text) THEN return
		lgb.TEXT = ls_text
	
	CASE picturebutton!
		PICTUREBUTTON lpb
		lpb = apo_control
		ls_Tag = lpb.TAG
		IF (ls_Tag = "") or pos(ls_Tag,']') > 1 THEN return
		ls_text = this._findcode(ls_Tag)
		IF f_isEmptyString(ls_text) THEN return
		lpb.TEXT = ls_text
	
	CASE radiobutton!
		RADIOBUTTON lrb
		lrb = apo_control
		ls_Tag = lrb.TAG
		IF (ls_Tag = "") or pos(ls_Tag,']') > 1 THEN return
		ls_text = this._findcode(ls_Tag)
		IF f_isEmptyString(ls_text) THEN return
		lrb.TEXT = ls_text
	
	CASE statictext!
		STATICTEXT lst
		lst = apo_control
		ls_Tag = lst.TAG
		IF (ls_Tag = "") or pos(ls_Tag,']') > 1 THEN return
		ls_text = this._findcode(ls_Tag)
		IF f_isEmptyString(ls_text) THEN return
		lst.TEXT = ls_text

	CASE multilineedit!
		MULTILINEEDIT mle
		mle = apo_control
		ls_Tag = mle.TAG
		IF (ls_Tag = "") or pos(ls_Tag,']') > 1 THEN return
		ls_text = this._findcode(ls_Tag)
		IF f_isEmptyString(ls_text) THEN return
		mle.TEXT = ls_text

	CASE datawindow!
		DATAWINDOW ldw
		ldw = apo_control
		ls_Tag = ldw.TAG
		IF Trim(ls_Tag) <> "" AND ldw.TitleBar THEN
			ls_text = this._findcode(ls_Tag)
			IF f_isEmptyString(ls_text) THEN return
			ldw.TITLE = ls_text
		END IF	
		this.uf_TranslateDw(ldw)
	
	CASE tab!
		TAB ltab
		ltab = apo_control
		li_Bound = upperbound(ltab.control[])
		// traduire chacun des tabpages
		FOR li_Ind = 1 to li_Bound
			ls_Tag = (ltab.control[li_Ind].tag)
			ls_text = this._findcode(ls_Tag)
			IF f_isEmptyString(ls_text) THEN continue
			ltab.control[li_Ind].text = ls_text
			// traduire les contrôles dans le tabpage
			li_Bound2 = upperbound(ltab.control[li_Ind].control[])
			FOR li_Ind2 = 1 to li_Bound2
				This.uf_TranslateControl(ltab.control[li_Ind].control[li_Ind2])
			NEXT	
		NEXT	
END CHOOSE

SetPointer(arrow!)

end subroutine

public function integer uf_setlanguage (string as_lang);// établi la langue courante et lit toutes les traductions disponibles dans ids_translation
// return : nombre de TAG lus dans la langue sélectionnée (-1 si erreur retrieve ou 0 rows)
long ll_ret

Choose Case Upper(Trim(as_lang))
	Case 'F','FR'
		is_lang = 'FR'
	Case 'D','DE'
		is_lang = 'DE'
	CASE ELSE
		is_lang = 'FR'
End Choose

If IsValid(ids_translation) Then 
	ids_translation.SetTransObject(sqlca)
	ll_ret = ids_translation.Retrieve(is_lang)
End if

// dès l'instant où une langue est sélectionnée, cela indique qu'on doit traduire l'application
IF ll_ret > 0 THEN
	ib_mustTranslate = TRUE
	return(ll_ret)
ELSE
	ib_mustTranslate = FALSE
	return(-1)
END IF

end function

public function boolean uf_musttranslate ();// Renvoie TRUE si l'application doit être traduite, FALSE sinon
return(ib_mustTranslate)
end function

on uo_translate.create
call super::create
TriggerEvent( this, "constructor" )
end on

on uo_translate.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

event constructor;ids_translation = Create uo_ds
ids_translation.DataObject = 'ds_translations'

// Par défaut l'application n'est pas traduite. Passe à TRUE dès qu'on sélectionne une langue.
ib_mustTranslate = FALSE

	
end event

event destructor;If IsValid(ids_translation) Then Destroy ids_translation

end event

