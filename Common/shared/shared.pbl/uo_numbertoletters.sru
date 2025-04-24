//objectcomments Conversion d'un nombre en toutes lettres
forward
global type uo_numbertoletters from nonvisualobject
end type
end forward

global type uo_numbertoletters from nonvisualobject
end type
global uo_numbertoletters uo_numbertoletters

forward prototypes
public function string uf_conv_num_ent_d (decimal ad_number, boolean ab_dec)
public function string uf_convert_d (decimal ad_number, boolean ab_euro)
public function string uf_conv_num_dizaines (integer ai_nombre, boolean ab_dec)
public function string uf_conv_num_ent (decimal ad_nombre)
public function string uf_conv_num_centaines (integer ai_nombre)
public function string uf_convert (decimal ad_number, boolean ab_euro)
end prototypes

public function string uf_conv_num_ent_d (decimal ad_number, boolean ab_dec);// ab_dec vaut TRUE quand on veut convertir la partie décimale du nombre (limité à 2 décimales)
// --> on obtient par exemple "zéro deux" quand le nombre à traduire est xxx,02

// max Anzahl von Dreierblöcken in einer Zahl (z.B. 4 = max bis 999 999 999 999)
// nombre maximum de blocs de trois dans un certain nombre (par exemple, 4 = max jusqu'à 999 999 999 999)
Int Blöcke = 4, posi, i

// on ne peut pas dimensionner un array avec une variable, donc "4" est hardcodé
string Block$[4], Text$[4], Gruppe$[4], GrEndSg$[4], GrEndPl$[4], Einer$[9], Einer2$[9]
string wert$, NK$, TextG$

wert$ = string(ad_number)

Einer$[1] = "eins"
Einer$[2] = "zwei"
Einer$[3] = "drei"
Einer$[4] = "vier"
Einer$[5] = "fünf"
Einer$[6] = "sechs"
Einer$[7] = "sieben"
Einer$[8] = "acht"
Einer$[9] = "neun"

Einer2$[1] = "ein"
Einer2$[2] = "zwei"
Einer2$[3] = "drei"
Einer2$[4] = "vier"
Einer2$[5] = "fünf"
Einer2$[6] = "sech"
Einer2$[7] = "sieb"
Einer2$[8] = "acht"
Einer2$[9] = "neun"

Gruppe$[2] = "tausend"
Gruppe$[3] = " Million"
Gruppe$[4] = " Milliarde"
// Gruppenendung Singular - Suffixe singulier de groupe
GrEndSg$[1] = ""
GrEndSg$[2] = ""
GrEndSg$[3] = " "
GrEndSg$[4] = " "
// Gruppenendung Plural - Suffixe du pluriel du Groupe
GrEndPl$[1] = ""
GrEndPl$[2] = ""
GrEndPl$[3] = "en "
GrEndPl$[4] = "n "

/**************************************************************************
 * Nachkommastellen NK$ schreiben - Ecrire décimales NK$
 **************************************************************************/
posi = pos(wert$, ",")
If posi > 0 Then
	NK$ = Right(wert$, Len(wert$) - posi)
	wert$ = Left(wert$, posi - 1)
Else
	NK$ = ""
End If

For i = 1 To Blöcke
	If Len(wert$) > 3 Then
		Block$[i] = Right(wert$, 3)
		wert$ = Left(wert$, Len(wert$) - 3)
	Else
		Block$[i] = wert$
		wert$ = ""
	End If
	If Block$[i] <> "" Then
		If Len(Block$[i]) = 3 Then
			If Block$[i] = "000" Then
				Text$[i] = ""
			ElseIf Left(Block$[i], 1) = "1" Then
				Text$[i] = "einhundert"
			ElseIf Left(Block$[i], 1) = "0" Then
				Text$[i] = ""
			Else
				Text$[i] = Text$[i] + Einer$[integer(Left(Block$[i], 1))] + "hundert"
			End If
		End If
	Block$[i] = Right(Block$[i], 2)
	END IF
	
	
	If Len(Block$[i]) = 2 Then
		If Left(Block$[i], 1) = "0" and Right(Block$[i], 1) <> "0" Then
			Text$[i] = Text$[i] + Einer$[integer(Right(Block$[i], 1))]
	// 10 ~ 19
		ElseIf Left(Block$[i], 1) = "1" Then
			If Left(Block$[i], 2) = "10" Then
				Text$[i] = Text$ [i] + "zehn"
			ElseIf Left(Block$[i], 2) = "11" Then
				Text$[i] = Text$ [i] + "elf"
			ElseIf Left(Block$[i], 2) = "12" Then
				Text$[i] = Text$[i] + "zwölf"
			Else
				Text$[i] = Text$[i] + Einer2$[integer(Right(Block$[i], 1))] + "zehn"
			End If
	// 20
		ElseIf Left(Block$[i], 1) = "2" Then
			If Right(Block$[i], 1) = "1" Then
				Text$[i] = Text$[i] + "ein"
			ElseIf Right(Block$[i], 1) <> "0" Then
				Text$[i] = Text$[i] + Einer$[integer(Right(Block$[i], 1))]
			End If
			If Right(Block$[i], 1) <> "0" Then
				Text$[i] = Text$[i] + "und"
			END IF
			Text$[i] = Text$[i] + "zwanzig"
	// 30
		ElseIf Left(Block$[i], 1) = "3" Then
			If Right(Block$[i], 1) = "1" Then
				Text$[i] = Text$[i] + "ein"
			ElseIf Right(Block$[i], 1) <> "0" Then
				Text$[i] = Text$[i] + Einer$[integer(Right(Block$[i], 1))]
			End If
			If Right(Block$[i], 1) <> "0" Then
				Text$[i] = Text$[i] + "und"
			END IF
			Text$[i] = Text$[i] + "dreißig"
	// autres que 10,20,30 :
			ElseIf Left(Block$[i], 1) <> "0" Then
			If Right(Block$[i], 1) = "1" Then
				Text$[i] = Text$[i] + "ein"
			Elseif Right(Block$[i], 1) <> "0" Then
				Text$[i] = Text$[i] + Einer$[integer(Right(Block$[i], 1))]
			End If
			If Right(Block$[i], 1) <> "0" Then
				Text$[i] = Text$[i] + "und"
			END IF
			Text$[i] = Text$[i] + Einer2$[integer(Left(Block$[i], 1))] + "zig"
			End If
		End If
	// 1 ~ 9
		If Len(Block$[i]) = 1 Then
			IF Right(Block$[i], 1) <> "0" THEN
				IF ab_dec THEN Text$[i] = Text$[i] + "null "
				Text$[i] = Text$[i] + Einer$[integer(Right(Block$[i], 1))]
			END IF
		End If
next

For i = Blöcke To 1 Step -1
	If Text$[i] <> "" Then
		If Text$[i] = "eins" Then
			If i > 2 Then
				Text$[i] = "eine"
			ElseIf i = 2 Then
				Text$[i] = "ein"
			End If
			Text$[i] = Text$[i] + Gruppe$[i]
			Text$[i] = Text$[i] + GrEndSg$[i]
		Else
			Text$[i] = Text$[i] + Gruppe$[i]
			Text$[i] = Text$[i] + GrEndPl$[i]
		End If
	End If
	TextG$ = TextG$ + Text$[i]
Next

If TextG$ = "" Then
	TextG$ = "null"
End If
If (NK$ <> "") And (NK$ <> "0") And (NK$ <> "00") Then
	If Len(NK$) = 1 Then
		NK$ = NK$ + "0"
	End If
	TextG$ = TextG$ + " und " + NK$ + "/100"
End If
// TextG$ = Chr$(Asc(Left$(TextG$, 1)) - 32) + Right$(TextG$, Len(TextG$) - 1)

return(TextG$)
end function

public function string uf_convert_d (decimal ad_number, boolean ab_euro);// conversion du nombre ad_number en toutes lettres, en langue allemande
// ab_euro indique si on veut un énoncé avec "euro" ou pas
// Le nombre est arrondi à 2 décimales.

boolean		lb_negative
decimal{2}	ld_decNumber
decimal{0}	ld_IntegerPart
integer		li_decimalPart
string		ls_IntegerPart, ls_decimalPart

IF isNull(ad_number) THEN
	return("")
END IF

// arrondi à 2 décimales
ld_decNumber = ad_number

IF ld_decNumber < 0 THEN
	lb_negative = TRUE
	ld_decNumber = abs(ld_decNumber)
END IF

// Partie entière du nombre
ld_IntegerPart = truncate(ld_decNumber, 0)

IF ld_IntegerPart > 999999999999 THEN
	return("Nummer zu groß !")
END IF

// Partie décimale du nombre
li_decimalPart = (ld_decNumber  * 100) - (ld_IntegerPart * 100)

// convertir la partie entière
ls_IntegerPart = uf_conv_num_ent_d(ld_IntegerPart, FALSE)

// convertir la partie décimale
ls_decimalPart = uf_conv_num_ent_d(li_decimalPart, TRUE)

IF ab_euro THEN
	ls_IntegerPart = ls_IntegerPart + " Euro"
	IF ld_IntegerPart > 1 THEN ls_IntegerPart = ls_IntegerPart + "s"
	IF li_decimalPart > 0 THEN
		// supprimer le "null" non significatif de la partie décimale
		IF left(ls_decimalPart, 4) = "null" THEN ls_decimalPart = mid(ls_decimalPart,6)
	END IF
		ls_decimalPart = " und " + ls_decimalPart + " Cent"
ELSE
	IF li_decimalPart > 0 THEN
		ls_decimalPart = " Komma " + ls_decimalPart
	ELSE
		ls_decimalPart = ""
	END IF
END IF

return(ls_IntegerPart + ls_decimalPart)

end function

public function string uf_conv_num_dizaines (integer ai_nombre, boolean ab_dec);		string	ls_tabdiz[], ls_tabUnit[], ls_liaison, ls_result
integer	li_diz, li_unit

ls_TabUnit = {"", "un", "deux", "trois", "quatre", "cinq", "six", "sept", "huit", "neuf", "dix", "onze", "douze", "treize", "quatorze", "quinze", "seize", "dix-sept", "dix-huit", "dix-neuf"}
ls_TabDiz = {"zéro", "", "vingt", "trente", "quarante", "cinquante", "soixante", "septante", "quatre-vingt", "nonante"}
// Si on n'est pas en cours de traitement de la partie décimale, le zéro ne se dit pas.
// Ex. : 10,07		--> dix virgule zéro sept
//       107		--> cent sept et non cent zéro sept
IF NOT ab_dec THEN
	ls_TabDiz[1] = ""
END IF

li_diz = Int(ai_nombre / 10)
li_unit = ai_nombre - (li_diz * 10)

ls_liaison = "-"
IF li_unit = 1 THEN ls_liaison = " et "

CHOOSE CASE li_diz
	CASE 0
		ls_liaison = " "
	CASE 1
		li_unit = li_unit + 10
		ls_liaison = ""
	CASE 8
		ls_liaison = "-"
END CHOOSE

// libellé des dizaines
ls_result = ls_tabDiz[li_diz + 1]
// ajouter le 's' au 'vingt' de 'quatre-vingt' s'il n'y a pas d''unité qui suit
IF li_diz = 8 AND li_unit = 0 THEN ls_result = ls_result + "s"
// ajouter libellé des unités avec la liaison requise (rien, 'et' ou '-')
IF ls_tabUnit[li_unit + 1] <> "" THEN
  ls_result = ls_result + ls_liaison + ls_tabUnit[li_unit + 1]
END IF

return(trim(ls_result))
end function

public function string uf_conv_num_ent (decimal ad_nombre);integer	li_cent, li_mille, li_million, li_milliard
string	ls_nombre, ls_tmp, ls_result

IF ad_nombre = 0 THEN
	return("zéro")
END IF

ls_nombre = string(ad_nombre, "000000000000")

// centaines
li_cent = integer(right(ls_nombre, 3))
ls_result = uf_conv_num_centaines(li_cent)

// reste-t-il qq chose à traiter ?
ls_nombre = left(ls_nombre, len(ls_nombre) - 3)
IF len(ls_nombre) = 0 THEN return(trim(ls_result))

// milliers
li_mille = integer(right(ls_nombre, 3))
IF li_mille <> 0 THEN
	ls_tmp = uf_conv_num_centaines(li_mille)
	CHOOSE CASE li_mille
		CASE 1
   	     ls_tmp = " mille "
		CASE ELSE
   	     ls_tmp = ls_tmp + " mille "
	END CHOOSE
	ls_result = ls_tmp + ls_result
END IF

// reste-t-il qq chose à traiter ?
ls_nombre = left(ls_nombre, len(ls_nombre) - 3)
IF len(ls_nombre) = 0 THEN return(trim(ls_result))

// millions
li_million = integer(right(ls_nombre, 3))
IF li_million <> 0 THEN
	ls_tmp = uf_conv_num_centaines(li_million)
	CHOOSE CASE li_million
		CASE 1
   	     ls_tmp = ls_tmp + " million "
		CASE ELSE
   	     ls_tmp = ls_tmp + " millions "
	END CHOOSE
	ls_result = ls_tmp + ls_result
END IF

// reste-t-il qq chose à traiter ?
ls_nombre = left(ls_nombre, len(ls_nombre) - 3)
IF len(ls_nombre) = 0 THEN return(trim(ls_result))

// milliard
li_milliard = integer(right(ls_nombre, 3))
IF li_milliard <> 0 THEN
	ls_tmp = uf_conv_num_centaines(li_milliard)
	CHOOSE CASE li_milliard
		CASE 1
   	     ls_tmp = ls_tmp + " milliard "
		CASE ELSE
   	     ls_tmp = ls_tmp + " milliards "
	END CHOOSE
	ls_result = ls_tmp + ls_result
END IF

return(trim(ls_result))
end function

public function string uf_conv_num_centaines (integer ai_nombre);string	ls_tabUnit[], ls_dizaines, ls_result
integer	li_cent, li_dizaines

// centaines
ls_tabUnit = {"", "un", "deux", "trois", "quatre", "cinq", "six", "sept", "huit", "neuf", "dix"}
li_cent = Int(ai_nombre / 100)

// dizaines
li_dizaines = ai_nombre - (li_cent * 100)
ls_dizaines = uf_conv_num_dizaines(li_dizaines, FALSE) // FALSE car on ne traite pas ici la pertie décimale du nombre

CHOOSE CASE li_cent
	CASE 0
		ls_result = ls_dizaines
	CASE 1
		IF li_dizaines = 0 THEN
			ls_result = "cent"
		ELSE
			ls_result = "cent " + ls_dizaines
		END IF
	CASE ELSE
		IF li_dizaines = 0 THEN
			ls_result = ls_tabUnit[li_cent + 1] + " cents"
		ELSE
			ls_result = ls_tabUnit[li_cent + 1] + " cent " + ls_dizaines
		END IF
END CHOOSE

return(ls_result)
end function

public function string uf_convert (decimal ad_number, boolean ab_euro);// conversion du nombre ad_number en toutes lettres, en langue française
// ab_euro indique si on veut un énoncé avec "euro" ou pas
// Le nombre est arrondi à 2 décimales.

// http://pbadonf.fr/forum/viewtopic.php?id=2232
// http://www.tools4noobs.com/online_tools/number_spell_words/

decimal{2}	ld_decNumber
decimal{0}	ld_IntegerPart
string		ls_result, ls_IntegerPart, ls_decimalPart
boolean		lb_negative
integer		li_decimalPart

IF isNull(ad_number) THEN
	return("")
END IF

// arrondi à 2 décimales
ld_decNumber = ad_number

IF ld_decNumber < 0 THEN
	lb_negative = TRUE
	ld_decNumber = abs(ld_decNumber)
END IF

// Partie entière du nombre
ld_IntegerPart = truncate(ld_decNumber, 0)

IF ld_IntegerPart > 999999999999 THEN
	return("Nombre trop grand !")
END IF

// Partie décimale du nombre
li_decimalPart = (ld_decNumber  * 100) - (ld_IntegerPart * 100)

// convertir la partie entière
ls_IntegerPart = uf_conv_num_ent(ld_IntegerPart)

// convertir la partie décimale
ls_decimalPart = uf_conv_num_dizaines(li_decimalPart, TRUE) // TRUE car on traite ici la pertie décimale du nombre

IF ab_euro THEN
	IF ld_IntegerPart >= 1000000 AND Right(string(ld_IntegerPart), 6) = "000000" THEN
		ls_IntegerPart = ls_IntegerPart + " d'euros"
	ELSE
		ls_IntegerPart = ls_IntegerPart + " euro"
		IF ld_IntegerPart > 1 THEN ls_IntegerPart = ls_IntegerPart + "s"
	END IF
	IF li_decimalPart > 0 THEN
		// supprimer le "zéro" non significatif de la partie décimale
		IF left(ls_decimalPart, 4) = "zéro" THEN ls_decimalPart = mid(ls_decimalPart,6)
	END IF
		ls_decimalPart = " et " + ls_decimalPart + " cent"
		IF li_decimalPart > 1 THEN ls_decimalPart = ls_decimalPart + "s"
ELSE
	IF li_decimalPart > 0 THEN
		ls_decimalPart = " virgule " + ls_decimalPart
	ELSE
		ls_decimalPart = ""
	END IF
END IF

return(ls_IntegerPart + ls_decimalPart)
end function

on uo_numbertoletters.create
call super::create
TriggerEvent( this, "constructor" )
end on

on uo_numbertoletters.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

