forward
global type uo_db from nonvisualobject
end type
end forward

global type uo_db from nonvisualobject
end type
global uo_db uo_db

forward prototypes
public function integer uf_enableconstraint (string as_tablename)
public function integer uf_disableconstraint (string as_tablename, string as_constraintname)
public function integer uf_enableconstraint (string as_tablename, string as_constraintname)
public function integer uf_disableconstraint (string as_tablename)
public function integer uf_locktable (string as_table)
public function integer uf_locktable (string as_table, string as_mode)
public function integer uf_connect (ref transaction atr_site, string as_user, string as_pwd, string as_alias, ref string as_message)
public function integer uf_disableconstraint (string as_tablename, string as_constraintname, ref transaction atr_target)
public function integer uf_disableconstraint (string as_tablename, ref transaction atr_target)
public function integer uf_enableconstraint (string as_tablename, string as_constraintname, ref transaction atr_target)
public function integer uf_enableconstraint (string as_tablename, ref transaction atr_target)
public function integer uf_locktable (string as_table, string as_mode, ref transaction atr_target)
end prototypes

public function integer uf_enableconstraint (string as_tablename);// Enable toutes les contraintes d'intégrité dont la table as_tablename est à la base.
// Cette variante de la fonction utilise ESQLCA comme objet transaction par défaut.
// ex : uf_enableconstraint("PGR1") va disabler les contraintes qui relient PGR1 à PGR2, PGR1 à MART1...
// return(1) si OK
// return(-1) en cas d'erreur

return(uf_enableconstraint(as_tablename, ESQLCA))

end function

public function integer uf_disableconstraint (string as_tablename, string as_constraintname);// Disable la contrainte d'intégrité as_constraint de la table as_tablename.
// Cette variante de la fonction utilise ESQLCA comme objet transaction par défaut.
// ex : uf_disableconstraint("PGR2", "FK_PGR2_PGR1")
// return(1) si OK
// return(-1) en cas d'erreur

return(uf_disableconstraint(as_tablename, as_constraintname, ESQLCA))

end function

public function integer uf_enableconstraint (string as_tablename, string as_constraintname);// Enable la contrainte d'intégrité as_constraint de la table as_tablename.
// Cette variante de la fonction utilise ESQLCA comme objet transaction par défaut.
// ex : uf_enableconstraint("PGR2", "FK_PGR2_PGR1")
// return(1) si OK
// return(-1) en cas d'erreur

return(uf_enableconstraint(as_tablename, as_constraintname, ESQLCA))

end function

public function integer uf_disableconstraint (string as_tablename);// Disable toutes les contraintes d'intégrité dont la table as_tablename est à la base.
// Cette variante de la fonction utilise ESQLCA comme objet transaction par défaut.
// ex : uf_disableconstraint("PGR1") va disabler les contraintes qui relient PGR1 à PGR2, PGR1 à MART1...
// return(1) si OK
// return(-1) en cas d'erreur

return(uf_disableconstraint(as_tablename, ESQLCA))

end function

public function integer uf_locktable (string as_table);// LOCK la table passée en argument, suivant le mode EXCLUSIF NOWAIT
// utilise l'objet transaction ESQLCA
// return(1) si OK
// return(-1) si erreur
return(uf_locktable(as_table, "EXCLUSIVE MODE NOWAIT", ESQLCA))
end function

public function integer uf_locktable (string as_table, string as_mode);// LOCK la table passée en argument, suivant le mode as_mode, et affiche un message si le lock ne peut pas être acquis
// utilise l'objet transaction ESQLCA
// return(1) si OK
// return(-1) si erreur

return(uf_locktable(as_table, as_mode, ESQLCA))

end function

public function integer uf_connect (ref transaction atr_site, string as_user, string as_pwd, string as_alias, ref string as_message);// connexion de la transaction atr_site
// return(1) si OK
// return(-1) si erreur, message dans as_message
	
atr_site.DBMS = SQLCA.dbms			// même paramètre que transaction par défaut
atr_site.dbparm = SQLCA.dbparm	// idem
atr_site.database = as_alias
atr_site.servername = as_alias
atr_site.userid = as_user
atr_site.dbpass = as_pwd
atr_site.logid = as_user
atr_site.logpass = as_pwd
connect using atr_site;
IF atr_site.sqlcode <> 0 THEN
	as_message = "Erreur de connection au site " + as_alias + " : " + atr_site.sqlerrtext
	return(-1)
ELSE
	execute immediate "alter session set NLS_LANGUAGE = French" USING atr_site;
	execute immediate "alter session set nls_date_format='DD/MM/YYYY'" USING atr_site;
	execute immediate "alter session set nls_numeric_characters=', '" USING atr_site;
	execute immediate "alter session set NLS_SORT = Binary" USING atr_site;
END IF

return(1)
end function

public function integer uf_disableconstraint (string as_tablename, string as_constraintname, ref transaction atr_target);// Disable la contrainte d'intégrité as_constraint de la table as_tablename.
// Cette variante de la fonction utilise l'objet transaction atr_target passé en argument.
// ex : uf_disableconstraint("PGR2", "FK_PGR2_PGR1")
// return(1) si OK
// return(-1) en cas d'erreur

string	ls_sql

as_tablename = trim(upper(as_tablename))
as_constraintname = trim(upper(as_constraintname))
ls_sql = "ALTER TABLE " + as_tablename + " DISABLE CONSTRAINT " + as_constraintname
execute immediate :ls_sql using atr_target;
IF f_check_sql(atr_target) <> 0 THEN
	gu_message.uf_error("Erreur " + ls_sql)
	return(-1)
END IF
return(1)
end function

public function integer uf_disableconstraint (string as_tablename, ref transaction atr_target);// Disable toutes les contraintes d'intégrité dont la table as_tablename est à la base.
// Cette variante de la fonction utilise l'objet transaction atr_target passé en argument.
// ex : uf_disableconstraint("PGR1") va disabler les contraintes qui relient PGR1 à PGR2, PGR1 à MART1...
// return(1) si OK
// return(-1) en cas d'erreur

string	ls_sql, ls_table, ls_constraint

as_tablename = trim(upper(as_tablename))

ls_sql = "select table_name, constraint_name from user_constraints &
		where constraint_type = 'R' and r_constraint_name = &
			(select constraint_name from user_constraints where table_name = ? and constraint_type = 'P')"
DECLARE cur_ref DYNAMIC CURSOR FOR SQLSA;
PREPARE SQLSA FROM :ls_sql USING atr_target;
OPEN DYNAMIC cur_ref using :as_tablename;
IF f_check_sql(atr_target) <> 0 THEN
	populateerror(20000,"")
	gu_message.uf_unexp("Erreur OPEN CURSOR " + ls_sql)
	CLOSE cur_ref;
	return(-1)
END IF

FETCH cur_ref INTO :ls_table, :ls_constraint;
DO WHILE f_check_sql(atr_target) = 0
	ls_sql = "ALTER TABLE " + ls_table + " DISABLE CONSTRAINT " + ls_constraint
	execute immediate :ls_sql using atr_target;
	IF f_check_sql(atr_target) <> 0 THEN
		gu_message.uf_error("Erreur " + ls_sql)
		CLOSE cur_ref;
		return(-1)
	END IF
	FETCH cur_ref INTO :ls_table, :ls_constraint;
LOOP

CLOSE cur_ref;
return(1)
end function

public function integer uf_enableconstraint (string as_tablename, string as_constraintname, ref transaction atr_target);// Enable la contrainte d'intégrité as_constraint de la table as_tablename.
// Cette variante de la fonction utilise l'objet transaction atr_target passé en argument.
// ex : uf_enableconstraint("PGR2", "FK_PGR2_PGR1")
// return(1) si OK
// return(-1) en cas d'erreur

string	ls_sql

ls_sql = "ALTER TABLE " + as_tablename + " ENABLE CONSTRAINT " + as_constraintname
as_tablename = trim(upper(as_tablename))
as_constraintname = trim(upper(as_constraintname))
execute immediate :ls_sql using atr_target;
IF f_check_sql(atr_target) <> 0 THEN
	gu_message.uf_error("Erreur " + ls_sql)
	return(-1)
END IF
return(1)

end function

public function integer uf_enableconstraint (string as_tablename, ref transaction atr_target);// Enable toutes les contraintes d'intégrité dont la table as_tablename est à la base.
// Cette variante de la fonction utilise l'objet transaction atr_target passé en argument.
// ex : uf_enableconstraint("PGR1") va disabler les contraintes qui relient PGR1 à PGR2, PGR1 à MART1...
// return(1) si OK
// return(-1) en cas d'erreur

string	ls_sql, ls_table, ls_constraint

as_tablename = trim(upper(as_tablename))

ls_sql = "select table_name, constraint_name from user_constraints &
		where constraint_type = 'R' and r_constraint_name = &
			(select constraint_name from user_constraints where table_name = ? and constraint_type = 'P')"
DECLARE cur_ref DYNAMIC CURSOR FOR SQLSA;
PREPARE SQLSA FROM :ls_sql USING atr_target;
OPEN DYNAMIC cur_ref using :as_tablename;
IF f_check_sql(atr_target) <> 0 THEN
	populateerror(20000,"")
	gu_message.uf_unexp("Erreur OPEN CURSOR " + ls_sql)
	CLOSE cur_ref;
	return(-1)
END IF

FETCH cur_ref INTO :ls_table, :ls_constraint;
DO WHILE f_check_sql(atr_target) = 0
	ls_sql = "ALTER TABLE " + ls_table + " ENABLE CONSTRAINT " + ls_constraint
	execute immediate :ls_sql using atr_target;
	IF f_check_sql(atr_target) <> 0 THEN
		gu_message.uf_error("Erreur " + ls_sql)
		CLOSE cur_ref;
		return(-1)
	END IF
	FETCH cur_ref INTO :ls_table, :ls_constraint;
LOOP

CLOSE cur_ref;
return(1)
end function

public function integer uf_locktable (string as_table, string as_mode, ref transaction atr_target);// LOCK la table passée en argument, suivant le mode as_mode, et affiche un message si le lock ne peut pas être acquis
// atr_target = objet transaction à utiliser
// return(1) si OK
// return(-1) si erreur
string	ls_sql

ls_sql = "LOCK TABLE " + as_table + " IN " + as_mode
execute immediate :ls_sql using atr_target;
// test table déjà lockée
IF atr_target.sqldbcode = 54 THEN
	gu_message.uf_info("La table " + as_table + " ne peut être réservée pour l'instant")
	return(-1)
END IF
// test autre erreur
IF f_check_sql(atr_target) <> 0 THEN
	populateerror(20000, ls_sql)
	gu_message.uf_unexp("Erreur " + ls_sql)
	return(-1)
END IF
return(1)

end function

on uo_db.create
call super::create
TriggerEvent( this, "constructor" )
end on

on uo_db.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

