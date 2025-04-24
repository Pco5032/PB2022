forward
global type uo_xml from nonvisualobject
end type
end forward

global type uo_xml from nonvisualobject
end type
global uo_xml uo_xml

forward prototypes
public function pbdom_element uf_get_element (pbdom_element a_root, string as_searchedelement)
public function string uf_get_value (pbdom_element a_root, string as_searchedelement)
public function pbdom_element uf_get_rootelement_inxml (string as_xml)
public function pbdom_element uf_get_rootelement_infile (string as_filename)
end prototypes

public function pbdom_element uf_get_element (pbdom_element a_root, string as_searchedelement);// Recherche et renvoie un élément PBDOM XML.
// a_root : élément PBDOM à partir duquel on effectue la recherche
// as_searchedelement : élément recherché sous la forme xxxx>yyyy
// return : élément PBDOM trouvé (NULL si pas trouvé)

PBDOM_Element	pbdom_children, pbdom_found, pbdom_null
integer	li_i, li_e
string	ls_base[], ls_searchElement

f_parse(as_searchedElement, ">", ls_base)
IF upperBound(ls_base) = 0 THEN
	return(pbdom_null)
END IF

IF a_root.hasChildElements() THEN
	pbdom_children = a_root.GetChildElement(ls_base[1])
	IF NOT isNull(pbdom_children) THEN
		IF upperBound(ls_base) = 1 THEN
			return(pbdom_children)
		ELSE
			FOR li_e = 2 TO upperBound(ls_base)
				ls_searchElement = ls_searchElement + ls_base[li_e] + ">"
			NEXT
			ls_searchElement = left(ls_searchElement, len(ls_searchElement) - 1)
			return(uf_get_element(pbdom_children, ls_searchElement))
		END IF
	END IF
END IF

return(pbdom_null)
end function

public function string uf_get_value (pbdom_element a_root, string as_searchedelement);// Recherche et renvoie la valeur d'un élément PBDOM XML.
// a_root : élément PBDOM à partir duquel on effectue la recherche
// as_searchedelement : élément recherché sous la forme xxxx>yyyy
// return : texte trouvé (NULL si pas trouvé)
//
// NB : pour récupérer une valeur non liée à un nom d'élément, utiliser getText().
// Exemple : dans la construction suivante : 
//		<typeDestruction>
//			<item class="String">battue</item>
//			<item class="String">affutNuit</item>
//			<item class="String">piegeage</item>
//		</typeDestruction>
//
// Pour récupérer la valeur de chaque item (battue, affutNuit...), le code serait le suivant : 
// 1. get reference to root element (point de départ de la structure XML)
//	   pbdom_root = iu_xml.uf_get_rootElement_inXML(as_xml)
// 2. trouver l'élément de base "demande>typeDestruction"
//		pbdom_typedest = iu_xml.uf_get_element(pbdom_root, "demande>typeDestruction")
// 3. parcourir les items (= les différents types de demandes repris dans le formulaire)
// 	pbdom_typedest.GetChildElements(pbdom_array_types)
// 	FOR li_i = 1 TO upperBound(pbdom_array_types)
// 		ls_text = pbdom_array_types[li_i].getText()
// 	NEXT

PBDOM_Element	pbdom_children
integer	li_i, li_e
string	ls_base[], ls_searchElement, ls_text

f_parse(as_searchedElement, ">", ls_base)
IF upperBound(ls_base) = 0 THEN
	return(gu_c.s_null)
END IF

IF a_root.hasChildElements() THEN
	pbdom_children = a_root.GetChildElement(ls_base[1])
	IF NOT isNull(pbdom_children) THEN
		IF upperBound(ls_base) = 1 THEN
			ls_text = pbdom_children.gettext()
			return(ls_text)
		ELSE
			FOR li_e = 2 TO upperBound(ls_base)
				ls_searchElement = ls_searchElement + ls_base[li_e] + ">"
			NEXT
			ls_searchElement = left(ls_searchElement, len(ls_searchElement) - 1)
			return(uf_get_value(pbdom_children, ls_searchElement))
		END IF
	END IF
END IF

return(gu_c.s_null)
end function

public function pbdom_element uf_get_rootelement_inxml (string as_xml);long		ll_ret
integer	li_i, li_j
string	ls_text
PBDOM_Builder	pbdom_bldr
PBDOM_Document	pbdom_doc
PBDOM_Element	pbdom_root, pbdom_null

ll_ret = XMLParseString(as_xml, ValNever!)
if ll_ret < 0 then
	gu_message.uf_error("Erreur ParseString : " + string(ll_ret))
	return(pbdom_null)
end if

// Create a PBDOM_DOCUMENT from the XML stream
pbdom_bldr = CREATE PBDOM_Builder
pbdom_doc = pbdom_bldr.BuildFromString(as_xml)

// get reference to root element
pbdom_root = pbdom_doc.GetRootElement()

DESTROY pbdom_bldr

return(pbdom_root)
end function

public function pbdom_element uf_get_rootelement_infile (string as_filename);long		ll_ret
integer	li_i, li_j
string	ls_text
PBDOM_Builder	pbdom_bldr
PBDOM_Document	pbdom_doc
PBDOM_Element	pbdom_root, pbdom_null

ll_ret = XMLParseFile(as_fileName, ValNever!)
if ll_ret < 0 then
	gu_message.uf_error("Erreur ParseFile : " + string(ll_ret))
	return(pbdom_null)
end if

// Create a PBDOM_DOCUMENT from the XML file
pbdom_bldr = CREATE PBDOM_Builder
pbdom_doc = pbdom_bldr.BuildFromFile(as_fileName)

// get reference to root element
pbdom_root = pbdom_doc.GetRootElement()

DESTROY pbdom_bldr

return(pbdom_root)
end function

on uo_xml.create
call super::create
TriggerEvent( this, "constructor" )
end on

on uo_xml.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

