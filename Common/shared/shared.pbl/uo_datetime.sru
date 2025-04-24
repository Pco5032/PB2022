//objectcomments diverses fonctions utiles dans le traitement des dates et datetimes
forward
global type uo_datetime from nonvisualobject
end type
end forward

global type uo_datetime from nonvisualobject
end type
global uo_datetime uo_datetime

forward prototypes
public function date uf_dfromdt (any aa_datetime)
public function integer uf_nbmonths (date a_date1, date a_date2)
end prototypes

public function date uf_dfromdt (any aa_datetime);// renvoie une variable de type DATE sur base d'une variable de type ANY contenant une datetime
// renvoie une date à NULL si argument n'est pas une date valide
string	ls_date, ls_datetime
long		ll_pos

ls_datetime = string(aa_datetime)

// la partie correspondant à la DATE dans la string contenant le DATETIME est la 1ère partie avant un espace
ll_pos = PosA(ls_datetime, " ")
IF ll_pos > 0 THEN
	ls_date = LeftA(ls_datetime, ll_pos)
ELSE
	ls_date = ls_datetime
END IF
IF IsDate(ls_date) THEN
	return(date(ls_date))
ELSE
	return(gu_c.date_null)
END IF
end function

public function integer uf_nbmonths (date a_date1, date a_date2);// renvoie le nombre de mois entre 2 dates
// nombre négatif : date 1 est postérieure à date 2
// nombre positif : date 2 est postérieure à date 1
// attention : ne tient pas compte du jour, donc par exemple renvoie -1 si
//             date1=01/09/2006 et date2=31/08/2006
integer	li_years, li_months

li_years = Year(a_Date2) - Year(a_Date1) 
li_months = Month(a_Date2) - Month(a_Date1) + (li_years * 12) 

return(li_months)
end function

on uo_datetime.create
call super::create
TriggerEvent( this, "constructor" )
end on

on uo_datetime.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

