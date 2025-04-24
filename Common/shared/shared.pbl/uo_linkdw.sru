//objectcomments Objet pour faciliter la synchronisation entre DW
forward
global type uo_linkdw from nonvisualobject
end type
type str_master_detail from structure within uo_linkdw
end type
type str_linkdw from structure within uo_linkdw
end type
end forward

type str_master_detail from structure
	uo_dw		dw_master
	string		s_masterjoincolumns
	uo_dw		dw_detail[]
	string		s_detailjoincolumns[]
end type

type str_linkdw from structure
	uo_dw		dw_linked[]
end type

global type uo_linkdw from nonvisualobject
end type
global uo_linkdw uo_linkdw

type variables
PRIVATE:
str_master_detail	istr_masdet[]
str_linkdw			istr_linkdw[]
integer	ii_nbmasdet, ii_nblink
end variables

forward prototypes
public subroutine uf_filterdetail (uo_dw adw_master, long al_row)
public function integer uf_setlinkeddw (uo_dw adw_linked[])
public subroutine uf_scrollall (integer ai_structnum, long al_currentrow)
public function integer uf_setmasterdetail (uo_dw adw_master, string as_masterjoincolumns, uo_dw adw_detail[], string as_detailjoincolumns[])
private function string uf_getcolexpr (uo_dw adw_dw, long al_row, string as_master_colname, string as_detail_colname)
public subroutine uf_rowfocuschanged (uo_dw adw_current, long al_newcurrentrow)
end prototypes

public subroutine uf_filterdetail (uo_dw adw_master, long al_row);// filtrer les dw 'detail' pour qu'elles correspondent à la row al_row du master adw_master
// adw_master = dw master pour lequel les dw 'detail' doivent afficher les données correspondantes
// al_row = current row du dw master
integer	li_m, li_d, li_c
string	ls_filter, ls_master_colname[], ls_detail_colname[]

// recheche la structure où sont stockées les infos de la relation Master/Detail de adw_master
FOR li_m = 1 TO ii_nbmasdet
	IF istr_masdet[li_m].dw_master = adw_master THEN
		// construire l'expression du filtre en fonction des colonnes qui composent le join entre les tables
		IF al_row > 0 AND al_row <= adw_master.rowCount() THEN
			// extraire liste des colonnes du dw master à utiliser dans le filtre
			f_parse (istr_masdet[li_m].s_masterjoincolumns, ",", ls_master_colname)
			
			// créer l'expression de filtre pour chaque dw detail (le nom des colonnes peut être différent 
			// entre les différents dw detail)
			FOR li_d = 1 TO UpperBound(istr_masdet[li_m].dw_detail)
				ls_filter = ""
				// utiliser chaque colonne dans l'expression du filtre
				FOR li_c = 1 TO UpperBound(ls_master_colname)
					f_parse(istr_masdet[li_m].s_detailjoincolumns[li_d], ",", ls_detail_colname)
					ls_filter = ls_filter + &
						uf_getcolexpr(adw_master, al_row, ls_master_colname[li_c], ls_detail_colname[li_c]) + " and "
				NEXT
				ls_filter = LeftA(ls_filter, LenA(ls_filter) - 5)
				// appliquer le filtre au dw 'detail' en cours
				IF f_IsEmptyString(ls_filter) THEN
					ls_filter = "1=2"
				END IF
				istr_masdet[li_m].dw_detail[li_d].SetFilter(ls_filter)
				istr_masdet[li_m].dw_detail[li_d].Filter()
				istr_masdet[li_m].dw_detail[li_d].Sort()
			NEXT
		ELSE
			// pas de row en cours : on s'arrange pour que le résultat du filtre soit toujours faux !
			ls_filter = "1=2"
			FOR li_d = 1 TO UpperBound(istr_masdet[li_m].dw_detail)
				istr_masdet[li_m].dw_detail[li_d].SetFilter(ls_filter)
				istr_masdet[li_m].dw_detail[li_d].Filter()
				istr_masdet[li_m].dw_detail[li_d].Sort()
			NEXT
		END IF
	END IF
NEXT

end subroutine

public function integer uf_setlinkeddw (uo_dw adw_linked[]);// initialise la liste des DW liés pour lesquels il faut gérer la synchronisation du rowfocuschanged
// adw_linked = array contenant les dw liés
// return le n° de la structure utilisée (devra être utilisée comme argument d'autres fonctions)
// (return -1 en cas d'erreur)
integer	li_i, li_j, li_k

// vérifications de la validité des paramètres passés
// un DW ne peut figurer dans 2 listes de dw liés
FOR li_i = 1 TO ii_nblink
	FOR li_j = 1 TO UpperBound(adw_linked)
		FOR li_k = 1 TO UpperBound(istr_linkdw[li_i].dw_linked)
			IF istr_linkdw[li_i].dw_linked[li_k] = adw_linked[li_j] THEN
				populateError(20000, "")
				gu_message.uf_unexp("Le datawindow " + adw_linked[li_j].ClassName() + " est déclaré dans 2 listes de dw liés")
				return(-1)
			END IF
		NEXT
	NEXT
NEXT

// incrémente le nbre de structures de liaisons utilisées
ii_nblink++

istr_linkdw[ii_nblink].dw_linked = adw_linked

FOR li_i = 1 TO upperBound(istr_linkdw[ii_nblink].dw_linked)
	istr_linkdw[ii_nblink].dw_linked[li_i].uf_synchronizing(FALSE)
NEXT

return(ii_nblink)
end function

public subroutine uf_scrollall (integer ai_structnum, long al_currentrow);// scroll tous les DW liés vers la même row
// ai_structnum = n° de la structure où sont stockés les DW liés concernés
//                (ce n° est obtenu quand on inscrit la liste des dw par la fonction uf_setLinkedDW)
// NB : utiliser cette fonction dans ue_synchro (car à ce moment le flag 'synchro en cours' est TRUE) 
//      de sorte que les changements de row ne provoque pas de déclenchements intempestifs des event ue_synchro
//      des divers DW
integer	li_i

IF ai_structnum = 0 OR ai_structnum > ii_nblink THEN
	return
END IF

FOR li_i = 1 TO UpperBound(istr_linkdw[ai_structnum].dw_linked)
	istr_linkdw[ai_structnum].dw_linked[li_i].scrollToRow(al_currentrow)
NEXT
return
end subroutine

public function integer uf_setmasterdetail (uo_dw adw_master, string as_masterjoincolumns, uo_dw adw_detail[], string as_detailjoincolumns[]);// initialise une nouvelle structure avec le dw MASTER et le(s) dw DETAILS
// adw_master = dw master
// as_masterjoincolumns = liste des colonnes clés du master DW (sous la forme col1, col2, ...)
// adw_detail = array contenant le(s) dw 'detail'
// as_detailjoincolumns = array contenant la liste des colonnes qui constituent le join entre le detail dw
//                        et le master dw. Il faut un élément par dw spécifié dans adw_detail.
// return le n° de la structure utilisée (-1 en cas d'erreur)

integer	li_i, li_j, li_k
string	ls_detcols[], ls_mastcols[]

// vérifications de la validité des paramètres passés
// 1. un DW ne peut être master dans 2 structures différentes (il faut les regrouper en une seule)
FOR li_i = 1 TO ii_nbmasdet
	IF istr_masdet[li_i].dw_master = adw_master THEN
		populateError(20000, "")
		gu_message.uf_unexp("Le datawindow " + adw_master.ClassName() + " est déclaré comme master dans 2 structures")
		return(-1)
	END IF
NEXT

// 2. un DW ne peut être slave dans 2 structures différentes (il faut les regrouper en une seule)
FOR li_i = 1 TO ii_nbmasdet
	FOR li_j = 1 TO UpperBound(adw_detail)
		FOR li_k = 1 TO UpperBound(istr_masdet[li_i].dw_detail)
			IF istr_masdet[li_i].dw_detail[li_k] = adw_detail[li_j] THEN
				populateError(20000, "")
				gu_message.uf_unexp("Le datawindow " + adw_detail[li_j].ClassName() + " est déclaré comme slave dans 2 structures")
				return(-1)
			END IF
		NEXT
	NEXT
NEXT

// 3. le nombre d'éléments dans l'array des 'detailjoincolumns' doit être = à celui des dw 'detail'
IF UpperBound(adw_detail) <> UpperBound(as_detailjoincolumns) THEN
	populateError(20000, "")
	gu_message.uf_unexp("Incohérence entre nombre de 'detailjoincolumns' et de 'dw_detail' ")
	return(-1)
END IF

// 4. nombre de colonnes dans tous les éléments as_detailjoincolumns[] doit être le même que dans as_masterjoincolumns
f_parse(as_masterjoincolumns, ",", ls_mastcols)
FOR li_i = 1 TO UpperBound(adw_detail)
	f_parse(as_detailjoincolumns[li_i], ",", ls_detcols)
	IF UpperBound(ls_mastcols) <> UpperBound(ls_detcols) THEN
		populateError(20000, "")
		gu_message.uf_unexp("Incohérence entre nombre de colonnes dans 'as_masterjoincolumns' et 'as_detailjoincolumns' ")
		return(-1)
	END IF
NEXT

// incrémente le nbre de structures master/detail utilisées
ii_nbmasdet++

istr_masdet[ii_nbmasdet].dw_master = adw_master
istr_masdet[ii_nbmasdet].s_masterjoincolumns = as_masterjoincolumns
istr_masdet[ii_nbmasdet].dw_detail = adw_detail
istr_masdet[ii_nbmasdet].s_detailjoincolumns = as_detailjoincolumns

return(ii_nbmasdet)
end function

private function string uf_getcolexpr (uo_dw adw_dw, long al_row, string as_master_colname, string as_detail_colname);// renvoie la colonne et sa valeur à ajouter au filtre
string	ls_coltype, ls_expr
date		ldt_date

ls_coltype = Lower(LeftA(adw_dw.Describe(as_master_colname + ".ColType"), 5))
CHOOSE CASE ls_coltype
	CASE "char(", "char"		//  CHARACTER DATATYPE
		ls_expr = as_detail_colname + "='" + adw_dw.GetItemString(al_row, as_master_colname, Primary!, FALSE) + "'"

	CASE "decim"				//  DECIMAL DATATYPE
		ls_expr = as_detail_colname + "=" + string(adw_dw.GetItemDecimal(al_row, as_master_colname, Primary!, FALSE))

	CASE "numbe", "long", "ulong", "real", "int"		//  NUMBER DATATYPE	
		ls_expr = as_detail_colname + "=" + string(adw_dw.GetItemNumber(al_row, as_master_colname, Primary!, FALSE))
		
// pas testé : !!!!!!!!!!!
	CASE "date"					//  DATE DATATYPE
		ldt_date = adw_dw.GetItemDate(al_row, as_master_colname, Primary!, FALSE)
		ls_expr = "string(" + as_detail_colname + ", 'dd/mm/yyyy') ='" + string(ldt_date, "dd/mm/yyyy") + "'"

//		CASE "datet"				//  DATETIME DATATYPE
//			la_value = This.GetItemDateTime ( al_row, as_column, adw_buffer, ab_orig_value ) 
//
//	
//		CASE "time", "times"		//  TIME DATATYPE
//			la_value = This.GetItemTime ( al_row, as_column, adw_buffer, ab_orig_value ) 
//
		CASE ELSE 	
			SetNull(ls_expr)
END CHOOSE

return(ls_expr)
end function

public subroutine uf_rowfocuschanged (uo_dw adw_current, long al_newcurrentrow);// fonction à appeler à partir de l'event rowfocuschanged des DW liés pour déclencher l'event ue_synchro
// du DW adw_current (et pas des autres DW liés à celui-ci)
// adw_current = dw qui a provoqué l'appel à cette fonction
// al_newcurrentrow = nouvelle row en cours de adw_current
integer	li_i, li_m, li_structnum

// recherche la structure où sont stockés les dw liés à adw_current
li_structnum = 0
FOR li_m = 1 TO ii_nblink
	FOR li_i = 1 TO UpperBound(istr_linkdw[li_m].dw_linked)
		IF istr_linkdw[li_m].dw_linked[li_i] = adw_current THEN
			li_structnum = li_m
			EXIT
		END IF
	NEXT
	IF li_structnum > 0 THEN
		EXIT
	END IF
NEXT

// le DW ne figure pas dans une liste = on ne fait rien
//
// ** MODIF en test à partir du 12/12/2007 : quand le DW en cours ne doit pas être synchronisé à un autre,
// on souhaite quand même déclencher ue_synchro pour pouvoir y placer du code de filtrage 
// entre ce DW et ses éventuels DW 'details'
// **
//IF li_structnum = 0 THEN
//	return
//END IF

// parmi les dw liés, s'il y a en a déjà un dont la synchro est active, ou si un 'insert' 
// ou 'delete' est en cours(et risque de provoquer des changements de row intempestifs) : 
// on ne fait rien (pas de déclenchement de l'event de synchro)

// ** MODIF en test à partir du 12/12/2007 : on regarde ds le DW current également !
IF adw_current.uf_synchronizing() OR adw_current.uf_inserting() OR adw_current.uf_deleting() THEN
	return
END IF
IF li_structnum > 0 THEN
// ** END_MODIF
	FOR li_i = 1 TO UpperBound(istr_linkdw[li_structnum].dw_linked)
		IF istr_linkdw[li_structnum].dw_linked[li_i].uf_synchronizing() OR &
				istr_linkdw[li_structnum].dw_linked[li_i].uf_inserting() OR &
				istr_linkdw[li_structnum].dw_linked[li_i].uf_deleting() THEN
			return
		END IF
	NEXT
END IF

// pas encore de synchro en cours :
// 1. on flague le DW en cours pour signaler qu'une synchro est en cours, ce qui bloquera les demandes
//    de synchronization provenant des autres DW liés au DW en cours
// 2. on déclenche ue_synchro sur adw_current. Les 'scrollToRow' appliqués aux DW liés ne provoqueront
//    pas de demande de synchronization grâce que flag 'synchro en cours' appliqué au DW en cours
// 3. on met à FALSE le flag 'synchro en cours'
adw_current.uf_synchronizing(TRUE)
adw_current.event ue_synchro(al_newcurrentrow)
adw_current.uf_synchronizing(FALSE)
return
end subroutine

on uo_linkdw.create
call super::create
TriggerEvent( this, "constructor" )
end on

on uo_linkdw.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

