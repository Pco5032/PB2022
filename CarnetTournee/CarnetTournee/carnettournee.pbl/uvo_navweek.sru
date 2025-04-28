//objectcomments Sélection semaine "Carnet"
forward
global type uvo_navweek from userobject
end type
type em_to from uo_editmask within uvo_navweek
end type
type em_from from uo_editmask within uvo_navweek
end type
type dw_liste_semaines from uo_datawindow_singlerow within uvo_navweek
end type
type st_3 from uo_statictext within uvo_navweek
end type
type st_2 from uo_statictext within uvo_navweek
end type
type st_1 from uo_statictext within uvo_navweek
end type
type pb_next from uo_pictbutton within uvo_navweek
end type
type pb_prev from uo_pictbutton within uvo_navweek
end type
end forward

global type uvo_navweek from userobject
integer width = 1783
integer height = 116
long backcolor = 67108864
string text = "none"
long tabtextcolor = 33554432
long picturemaskcolor = 536870912
event ue_prev ( )
event ue_next ( )
event ue_init ( )
event type integer ue_check_before_nav ( )
em_to em_to
em_from em_from
dw_liste_semaines dw_liste_semaines
st_3 st_3
st_2 st_2
st_1 st_1
pb_next pb_next
pb_prev pb_prev
end type
global uvo_navweek uvo_navweek

type variables
private date		idt_from, idt_to
private integer	ii_year, ii_week
private string		is_mode
private boolean	ib_manualyModified
uo_ds	ids_semaines
end variables

forward prototypes
public function date uf_getfrom ()
public function date uf_getto ()
public function integer uf_getyear ()
public function integer uf_getweek ()
public subroutine uf_init (date adt_date)
public subroutine uf_select_semaine_dans_liste ()
public function integer uf_setweek (date a_date)
public function integer uf_valid ()
public subroutine uf_setmanual ()
public function integer uf_check_dates ()
public function integer uf_setdates (integer ai_year, integer ai_week)
public function integer uf_init_liste_semaines ()
end prototypes

event type integer ue_check_before_nav();// event déclenché avant de passer d'une semaine à l'autre
// return(1) si navigation autorisée
// return(-1) si navigation non autorisée

return(1)
end event

public function date uf_getfrom ();// renvoie la date de début de la semaine
return(idt_from)
end function

public function date uf_getto ();// renvoie la date de fin de la semaine
return(idt_to)
end function

public function integer uf_getyear ();// Renvoie NULL si les dates ont été modifiées manuellement, l'année sélectionnée dans le cas contraire
IF ib_manualyModified THEN
	return(gu_c.i_null)
ELSE
	return(ii_year)
END IF
end function

public function integer uf_getweek ();// Renvoie NULL si les dates ont été modifiées manuellement, la semaine sélectionnée dans le cas contraire
IF ib_manualyModified THEN
	return(gu_c.i_null)
ELSE
	return(ii_Week)
END IF
end function

public subroutine uf_init (date adt_date);// semaine
uf_setweek(adt_date)

// date de début et de fin de la semaine
uf_setdates(ii_year, ii_week)

event ue_init()
end subroutine

public subroutine uf_select_semaine_dans_liste ();// PCO 22 MARS 2016 : sélectionner la semaine en cours dans la DDDW.
// Si la semaine n'existe pas, on ne la sélectionne pas (forcément) mais on l'affiche quand même
datawindowchild	ldwc_child
long		ll_row
integer	li_rtn

li_rtn = dw_liste_semaines.getchild("semaine", ldwc_child)
IF li_rtn = 1 THEN 
	ll_row = ldwc_child.find("c_display='" + string(ii_year) + "/" + string(ii_week) + "'", 1, 99)
	IF ll_row > 0 THEN ldwc_child.scrollToRow(ll_row)
END IF
dw_liste_semaines.object.semaine[1] = string(ii_year) + "/" + string(ii_week)

end subroutine

public function integer uf_setweek (date a_date);// calcule la semaine (YYYY/SS) dans laquelle se trouve la date passée en argument
// et garni les variables ii_year et ii_week 
// return(1) s'il y a eu recalcul du n° de semaine
// return(0) sinon
// return(-1) : erreur SQL
integer	li_year, li_week

select substr(SemaineFromDate_CT(:a_date), 1, 4), substr(SemaineFromDate_CT(:a_date), 6) 
	into :li_year, :li_week from dual using ESQLCA;

IF f_check_sql(ESQLCA) = 0 THEN
	IF li_year <> ii_year OR li_week <> ii_week THEN
		ii_year = li_year
		ii_week = li_week
		return(1)
	ELSE
		return(0)
	END IF
ELSE
	populateError(20000, "")
	gu_message.uf_unexp("Erreur SELECT semaine !")
	return(-1)
END IF




end function

public function integer uf_valid ();// PCO 04/04/2016. Fonction à lancer depuis le programme container pour déclencher la validation de la semaine
// éventuellement saisie manuellement.
// NB : j'abandonne la possibilité car trop de soucis de validation à gérer dans chaque programme utilisateur.
// Je laisse malgré tout le code qui le permettait au cas où je changerais d'avis.
IF dw_liste_semaines.accepttext() = -1 THEN
	dw_liste_semaines.setFocus()
	return(-1)
ELSE
	return(1)
END IF

end function

public subroutine uf_setmanual ();// Mode manuel : permet d'encoder directement un intervalle de dates, on ne tient plus compte de la semaine.
// L'objet renverra uniquement les dates, année et semaine seront NULLS.
is_mode = "M"
em_from.displayonly = FALSE
em_to.displayonly = FALSE
em_from.backcolor = f_mandcolor()
em_to.backcolor = f_mandcolor()

end subroutine

public function integer uf_check_dates ();date	ldt_from, ldt_to

em_from.getdata(ldt_from)
em_to.getdata(ldt_to)

IF ldt_from > ldt_to THEN
	em_from.setFocus()
	gu_message.uf_error("La date de départ doit être < à la date finale")
	return(-1)
ELSE
	return(1)
END IF
end function

public function integer uf_setdates (integer ai_year, integer ai_week);// affiche les dates de début et de fin de la semaine passée en argument et garni les variables idt_from et idt_to
long	ll_found

// chercher la semaine dans les semaines précalculées
ll_found = ids_semaines.find("year=" + string(ai_year) + " and week=" + string(ai_week), 1, ids_semaines.rowCount())
IF ll_found > 0 THEN
	idt_from = date(ids_semaines.object.dt_from[ll_found])
	idt_to = date(ids_semaines.object.dt_to[ll_found])
ELSE
	// si la semaine recherchée n'est pas précalculée, la calculer maintenant
	select DateFromSemaine_CT(:ai_year, :ai_week), DateFromSemaine_CT(:ai_year, :ai_week) + 6 
		into :idt_from, :idt_to from dual USING ESQLCA;
	IF f_check_sql(ESQLCA) <> 0 THEN
		populateError(20000, "")
		gu_message.uf_unexp("Erreur SELECT dates !")
		return(-1)
	END IF
END IF

em_from.text = string(idt_from, "dd/mm/yyyy")
em_to.text = string(idt_to, "dd/mm/yyyy")
ib_manualyModified = FALSE
return(1)

end function

public function integer uf_init_liste_semaines ();// PCO 22 MARS 2016 : garnir une liste de semaines 3 ans avant et 16 semaines après la semaine en cours pour accès direct
// PCO AVRIL 2020 : lire les semaines dans table SEMAINES pré-remplie (voir w_init_semaines) pour gagner en rapidité.
integer	li_year, li_week, li_trav_year, li_start_week, li_end_week, li_row, li_rtn
long		ll_row, ll_nbrows
date		ldt_from, ldt_to
datawindowchild	ldwc_child

li_rtn = dw_liste_semaines.getchild("semaine", ldwc_child)
IF li_rtn = -1 THEN return(-1)

li_trav_year = uf_getYear()
li_start_week = uf_getWeek() - 156
li_end_week = uf_getWeek() + 16

// calcule date de début et de fin sur base 1ère et dernière semaines demandées
select DateFromSemaine_CT(:li_trav_year, :li_start_week), DateFromSemaine_CT(:li_trav_year, :li_end_week) 
	into :ldt_from, :ldt_to from dual using ESQLCA;
IF f_check_sql(ESQLCA) <> 0 THEN
	return(-1)
END IF

// lire les semaines dans l'intervalle des dates souhaitées
ll_nbrows = ids_semaines.retrieve(ldt_from, ldt_to)

// ajouter la semaine et les dates au DDDW
FOR ll_row = 1 TO ll_nbrows
	li_year = ids_semaines.object.year[ll_row]
	li_week = ids_semaines.object.week[ll_row]
	ldt_from = date(ids_semaines.object.dt_from[ll_row])
	ldt_to = date(ids_semaines.object.dt_to[ll_row])
	
	li_row = ldwc_child.insertRow(0)
	ldwc_child.setItem(li_row, "n_year", li_year)
	ldwc_child.setItem(li_row, "n_week", li_week)
	ldwc_child.setItem(li_row, "d_from", ldt_from)
	ldwc_child.setItem(li_row, "d_to", ldt_to)
NEXT

// sélectionner la semaine en cours et l'afficher
uf_select_semaine_dans_liste()

return(1)
end function

on uvo_navweek.create
this.em_to=create em_to
this.em_from=create em_from
this.dw_liste_semaines=create dw_liste_semaines
this.st_3=create st_3
this.st_2=create st_2
this.st_1=create st_1
this.pb_next=create pb_next
this.pb_prev=create pb_prev
this.Control[]={this.em_to,&
this.em_from,&
this.dw_liste_semaines,&
this.st_3,&
this.st_2,&
this.st_1,&
this.pb_next,&
this.pb_prev}
end on

on uvo_navweek.destroy
destroy(this.em_to)
destroy(this.em_from)
destroy(this.dw_liste_semaines)
destroy(this.st_3)
destroy(this.st_2)
destroy(this.st_1)
destroy(this.pb_next)
destroy(this.pb_prev)
end on

event constructor;ids_semaines = CREATE uo_ds
ids_semaines.dataobject = "ds_liste_semaines"
ids_semaines.setTransObject(SQLCA)

// par défaut : mode automatique. On ne peut pas changer les dates autrement qu'en sélectionnant une semaine
// Manuel : on sait modifier les dates. Le n° de semaine n'a alors plus de sens.
is_mode = "A"

ib_manualyModified = FALSE

// initialise à la date du jour
date	ldt_today

// date du jour
ldt_today = f_today()

// créer une row pour que le DDDW soit visible et utilisable dans l'initilisation
dw_liste_semaines.insertRow(0)

// calcul n° de semaine en cours
uf_init(ldt_today)

// liste des semaines
uf_init_liste_semaines()
end event

event destructor;DESTROY ids_semaines
end event

type em_to from uo_editmask within uvo_navweek
integer x = 1317
integer y = 16
integer width = 311
integer height = 80
integer taborder = 40
integer textsize = -9
long backcolor = 67108864
boolean displayonly = true
borderstyle borderstyle = stylebox!
maskdatatype maskdatatype = datemask!
string mask = "dd/mm/yyyy"
end type

event modified;call super::modified;this.getData(idt_to)
ib_manualyModified = TRUE

end event

event getfocus;call super::getfocus;this.selecttext(1, Len(this.text))
end event

type em_from from uo_editmask within uvo_navweek
integer x = 878
integer y = 16
integer width = 311
integer height = 80
integer taborder = 30
integer textsize = -9
long backcolor = 67108864
boolean displayonly = true
borderstyle borderstyle = stylebox!
maskdatatype maskdatatype = datemask!
string mask = "dd/mm/yyyy"
end type

event modified;call super::modified;this.getData(idt_from)
ib_manualyModified = TRUE
end event

event getfocus;call super::getfocus;this.selecttext(1, Len(this.text))
end event

type dw_liste_semaines from uo_datawindow_singlerow within uvo_navweek
integer x = 384
integer y = 16
integer width = 366
integer height = 96
integer taborder = 0
string dataobject = "d_liste_semaines"
boolean livescroll = false
borderstyle borderstyle = stylebox!
end type

event ue_itemvalidated;call super::ue_itemvalidated;string	ls_data[]
integer	li_year, li_week, li_selectedYear, li_selectedWeek

li_year = ii_year
li_week = ii_week

// extraire année et semaine de as_data
f_parse(as_data,"/",ls_data)
li_selectedYear = integer(ls_data[1])
li_selectedWeek = integer(ls_data[2])

// calculer et afficher date de début et de fin de la semaine
IF uf_setdates(li_selectedYear, li_selectedWeek) = 1 THEN
	ii_year = li_selectedYear
	ii_week = li_selectedWeek
ELSE
	// en cas d'erreur dans uf_setDates, resélectionner la semaine en cours dans la liste
	post uf_select_semaine_dans_liste()
	return
END IF

// Recalcule le n° de semaine sur base de la date car on est peut-être passé à l'année suivante.
// Afficher année et semaine correctes s'il y a eu recalcul
IF uf_setweek(idt_from) = 1 THEN
	post uf_select_semaine_dans_liste()
END IF

IF ii_year > li_year OR (ii_year = li_year AND ii_week > li_week) THEN
	event ue_next()
ELSE
	event ue_prev()
END IF
end event

event ue_checkitem;call super::ue_checkitem;string	ls_data[]
integer	li_year, li_week

// vérifier validité du format : doit être yyyy/[w]w
IF f_parse(as_data, "/", ls_data) <> 2 THEN
	as_message = "Format incorrect : veuillez introduire l'année et la semaine séparés par '/'. Exemple : 2016/9"
	return(-1)
END IF

// vérifier validité de l'année et de la semaine
li_year = integer(ls_data[1])
li_week = integer(ls_data[2])
IF li_year < 2000 OR li_year > 2099 OR li_week < 1 OR li_week > 55 THEN
	as_message = "Année ou semaine incorrecte"
	return(-1)
END IF

// Sauver les données de la semaine en cours avant d'en changer
IF event ue_check_before_nav() = -1 THEN 
	uf_select_semaine_dans_liste()
	return(-3)
END IF
end event

type st_3 from uo_statictext within uvo_navweek
string tag = "TEXT_00532"
integer x = 1170
integer y = 16
integer width = 128
integer height = 80
string text = "au"
alignment alignment = right!
end type

type st_2 from uo_statictext within uvo_navweek
string tag = "TEXT_00531"
integer x = 750
integer y = 16
integer width = 110
integer height = 88
string text = "du"
alignment alignment = right!
end type

type st_1 from uo_statictext within uvo_navweek
string tag = "TEXT_00530"
integer x = 146
integer y = 16
integer width = 229
integer height = 80
string text = "semaine"
alignment alignment = right!
end type

type pb_next from uo_pictbutton within uvo_navweek
integer x = 1646
integer y = 8
integer width = 110
integer height = 96
string text = ""
boolean originalsize = false
string picturename = "..\bmp\vcrnext.bmp"
boolean map3dcolors = true
end type

event clicked;call super::clicked;IF event ue_check_before_nav() = -1 THEN return

// incrémente la semaine
// date de début et de fin de la semaine
IF uf_setdates(ii_year, ii_week + 1) = -1 THEN
	return
ELSE
	ii_week = ii_week + 1
END IF

// recalcule le n° de semaine sur base de la date car on est peut-être passé à l'année suivante
IF uf_setweek(idt_from) = -1 THEN
	return
END IF

// sélectionner la semaine en cours et l'afficher
uf_select_semaine_dans_liste()

event ue_next()
end event

type pb_prev from uo_pictbutton within uvo_navweek
integer x = 18
integer y = 8
integer width = 110
integer height = 96
string text = ""
string picturename = "..\bmp\vcrprev.bmp"
boolean map3dcolors = true
end type

event clicked;call super::clicked;IF event ue_check_before_nav() = -1 THEN return

// décrémente la semaine
// date de début et de fin de la semaine
IF uf_setdates(ii_year, ii_week - 1) = -1 THEN
	return
ELSE
	ii_week = ii_week - 1
END IF

// recalcule le n° de semaine sur base de la date car on est peut-être passé à l'année précédente
IF uf_setweek(idt_from) = -1 THEN
	return
END IF

// sélectionner la semaine en cours et l'afficher
uf_select_semaine_dans_liste()

event ue_prev()
end event

