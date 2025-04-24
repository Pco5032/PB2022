forward
global type uo_stringservices from nonvisualobject
end type
end forward

global type uo_stringservices from nonvisualobject
end type
global uo_stringservices uo_stringservices

forward prototypes
public function string uf_replaceall (string as_var, string as_search, string as_replace)
public function string uf_embeddbq (string as_texte)
public function string uf_replaceall (string as_var, string as_search[], string as_replace[])
public function string uf_removeaccent (string as_string, string as_case)
public function string uf_removeaccent (string as_string)
public function long uf_searchinarray (string as_tab[], string as_search)
public function long uf_adduniquetoarray (ref string as_tab[], string as_data)
public function string uf_createstringfromarray (any aa_tab[])
end prototypes

public function string uf_replaceall (string as_var, string as_search, string as_replace);// remplace toutes les occurrences de la string as_search par la string as_replace dans la string as_var et renvoie le résultat
// return = le résultat

long		ll_pos

ll_pos = PosA(as_var, as_search, 1)
DO WHILE ll_pos > 0
	as_var = ReplaceA(as_var, ll_pos, LenA(as_search), as_replace)
	ll_pos = PosA(as_var, as_search, ll_pos + LenA(as_replace))
LOOP
return(as_var)
end function

public function string uf_embeddbq (string as_texte);// renvoie la string passée en paramètre en remplaçant les embedded double-quotes (") par une escaped double-quotes
return(uf_replaceall(as_texte, '"', '~~~"'))
end function

public function string uf_replaceall (string as_var, string as_search[], string as_replace[]);// remplace dans la string as_var toutes les occurrences de chaque string de as_search 
// par la string correspondante de as_replace
// return = le résultat (ou la string as_var d'origine en cas d'erreur)
long		ll_pos
integer	li_i

// à chaque string cherchée doit correspondre une string remplacée
IF upperBound(as_search) <> upperBound(as_replace) THEN
	populateError(20000, "Le nombre de search-string ne correspond pas au nombre de replace-string")
	gu_message.uf_unexp()
	return(as_var)
END IF

FOR li_i = 1 TO upperBound(as_search)
	ll_pos = PosA(as_var, as_search[li_i], 1)
	DO WHILE ll_pos > 0
		as_var = ReplaceA(as_var, ll_pos, LenA(as_search[li_i]), as_replace[li_i])
		ll_pos = PosA(as_var, as_search[li_i], ll_pos + LenA(as_replace[li_i]))
	LOOP
NEXT
return(as_var)
end function

public function string uf_removeaccent (string as_string, string as_case);/************************************************************************/
/* Nom : Permet de reconvertir en minuscule-majuscule sans les accents  */
/************************************************************************/
// as_string : chaîne de caractères à convertir
// as_case : U pour renvoyer la chaîne en majuscules, L pour minuscules, autre chose : pas de conversion de casse
string  ls_mot, ls_caractereactuel, ls_caracterearemplace
long    ll_len , ll_cpt, ll_cptequivalent
boolean  lb_caractereautre

string  ls_caracterenormale, ls_caractere[], ls_equivalent[]

ls_caractere[1]  = 'ÀÁÂÃÄÅ'
ls_caractere[2]  = 'Ç'
ls_caractere[3]  = 'ÈÉÊË'
ls_caractere[4]  = 'ÌÍÎÏ'
ls_caractere[5]  = 'Ñ'
ls_caractere[6]  = 'ñ'
ls_caractere[7]  = 'ÒÓÔÕÖ'
ls_caractere[8]  = 'ÙÚÛÜ'
ls_caractere[9]  = 'Ý'
ls_caractere[10] = 'àáâãäå'
ls_caractere[11] = 'ç'
ls_caractere[12] = 'èéêë'
ls_caractere[13] = 'ìíîï'
ls_caractere[14] = 'ðòóôõö'
ls_caractere[15] = 'ùúûü'
ls_caractere[16] = 'ý'


ls_equivalent[1]  = 'A'
ls_equivalent[2]  = 'C'
ls_equivalent[3]  = 'E'
ls_equivalent[4]  = 'I'
ls_equivalent[5]  = 'N'
ls_equivalent[6]  = 'n'
ls_equivalent[7]  = 'O'
ls_equivalent[8]  = 'U'
ls_equivalent[9]  = 'Y'
ls_equivalent[10] = 'a'
ls_equivalent[11] = 'c'
ls_equivalent[12] = 'e'
ls_equivalent[13] = 'i'
ls_equivalent[14] = 'o'
ls_equivalent[15] = 'u'
ls_equivalent[16] = 'y'


ls_mot = as_string
ll_len = len(ls_mot)

choose case as_case    
  case 'U', 'UPPER'
    // mode majuscule
    ls_mot = upper(ls_mot)
    ls_caracterenormale = "^[A-Z]$"
  case 'L', 'LOWER'
    // mode minuscule
    ls_mot = lower(ls_mot)
    ls_caracterenormale = "^[a-z]$"
  case else
	 // pas de conversion de casse
	 ls_caracterenormale = "^[a-zA-Z]$"
end choose

lb_caractereautre  = true

for ll_cpt = 1 to ll_len
  ls_caractereactuel = mid(ls_mot,ll_cpt,1)
  ls_caracterearemplace = ''  
  lb_caractereautre = Match(ls_caractereactuel, ls_caracterenormale)
  if lb_caractereautre = false then
    for ll_cptequivalent = 1 to upperbound(ls_caractere[])
      if pos(ls_caractere[ll_cptequivalent],ls_caractereactuel) > 0 then
        ls_caracterearemplace = ls_equivalent[ll_cptequivalent]
        ls_mot = Replace(ls_mot, ll_cpt, 1, ls_caracterearemplace)
        exit
      end if
    next
  end if
next

return(ls_mot)

end function

public function string uf_removeaccent (string as_string);/************************************************************************/
/* Nom : Permet de reconvertir en minuscule-majuscule sans les accents  */
/************************************************************************/
// as_string : chaîne de caractères à convertir
// pas de conversion de casse : 2ème paramètre = ""

return(uf_removeaccent(as_string, ""))

end function

public function long uf_searchinarray (string as_tab[], string as_search);// cherche si as_search existe dans l'array as_tab[]
// return 0 si pas trouvé
// return la position de as_search dans l'array si trouvé
long	ll_item
boolean	lb_found

FOR ll_item = 1 TO upperBound(as_tab)
	IF as_search = as_tab[ll_item] THEN
		lb_found = TRUE
		EXIT
	END IF
NEXT

IF lb_found THEN
	return(ll_item)
ELSE
	return(0)
END IF
end function

public function long uf_adduniquetoarray (ref string as_tab[], string as_data);// Ajoute as_data dans l'array as_tab[], en éliminant les doublons.
// return index de l'élément ajouté, 0 si élément pas ajouté (doublon)
long		ll_item

FOR ll_item = 1 TO upperBound(as_tab)
	IF as_data = as_tab[ll_item] THEN
		return(0)
	END IF
NEXT

// ajoute l'élément
as_tab[upperBound(as_tab) + 1] = as_data

return(upperBound(as_tab))

end function

public function string uf_createstringfromarray (any aa_tab[]);// Constitue une string constituée des éléments de l'array aa_tab, séparés par une virgule.
// Les éléments alphanumériques sont entre single-quotes.
// Les éléments vides sont exclus.
// return string
long		ll_item
string	ls_string

FOR ll_item = 1 TO upperBound(aa_tab)
	IF NOT f_isEmptyString(aa_tab[ll_item]) THEN
		IF ClassName(aa_tab[ll_item]) = "string" THEN
			ls_string = ls_string + "'" + string(aa_tab[ll_item]) + "',"
		ELSE
			ls_string = ls_string + string(aa_tab[ll_item]) + ","
		END IF
	END IF
NEXT

ls_string = Left(ls_string, Len(ls_string) - 1)
return(ls_string)

end function

on uo_stringservices.create
call super::create
TriggerEvent( this, "constructor" )
end on

on uo_stringservices.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

