//objectcomments Utilitaire de calcul des semaines : INSERT INTO SEMAINES
forward
global type w_init_semaines from w_ancestor
end type
type cb_1 from uo_cb within w_init_semaines
end type
end forward

global type w_init_semaines from w_ancestor
integer width = 1609
integer height = 556
string title = "Calcul des semaines INSERT INTO SEMAINES"
cb_1 cb_1
end type
global w_init_semaines w_init_semaines

forward prototypes
public function integer wf_init_semaines ()
end prototypes

public function integer wf_init_semaines ();// PCO AVRIL 2020 : remplir une table avec la liste des semaines et dates de début/fin. On lira cette table dans uvo_navweek
// au lieu de calculer les dates à chaque execution car c'est devenu très lent suite à migration DB !
//CREATE TABLE semaines
//(
//  year  NUMBER(4),
//  week  NUMBER(2),
//  dt_from  DATE,
//  dt_to    DATE
//);
// ALTER TABLE SEMAINES ADD CONSTRAINT SEMAINES_PK PRIMARY KEY (YEAR, WEEK);

uo_wait		lu_wait
integer	li_year, li_week, li_trav_year, li_trav_week, li_row, li_rtn
long		ll_row
date		ldt_from, ldt_to

lu_wait=CREATE uo_wait

// on part de 2020 et on va calculer les dates pour 250 semaines dans le passé et 500 dans l'avenir
li_trav_year = 2020

FOR li_trav_week = -250 TO 500
	// calcule date de début et de fin sur base de la semaine demandée
	select DateFromSemaine_CT(:li_trav_year, :li_trav_week), DateFromSemaine_CT(:li_trav_year, :li_trav_week) + 6 
		into :ldt_from, :ldt_to from dual using ESQLCA;
	// recalcule le n° de semaine sur base de la date calculée car on est peut-être passé à l'année précédente ou suivante
	select substr(SemaineFromDate_CT(:ldt_from), 1, 4), substr(SemaineFromDate_CT(:ldt_from), 6) 
		into :li_year, :li_week from dual using ESQLCA;
	lu_wait.uf_addinfo(string(li_year) + "/" + string(li_week))
	// ajouter la semaine et les dates correspondantes dans la table SEMAINES
	insert into semaines(year,week,dt_from,dt_to) values (:li_year, :li_week,:ldt_from,:ldt_to) using ESQLCA;
	IF f_check_sql(ESQLCA) <> 0 THEN
		rollback using ESQLCA;
		DESTROY lu_wait
		return(-1)
	END IF
NEXT
commit using ESQLCA;
DESTROY lu_wait
return(1)

end function

on w_init_semaines.create
int iCurrent
call super::create
this.cb_1=create cb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_1
end on

on w_init_semaines.destroy
call super::destroy
destroy(this.cb_1)
end on

type cb_1 from uo_cb within w_init_semaines
integer x = 329
integer y = 144
integer width = 859
integer taborder = 10
boolean bringtotop = true
string text = "Lancer le calcul des semaines"
end type

event clicked;call super::clicked;wf_init_semaines()
end event

