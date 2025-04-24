//objectcomments initialisation et état des privilèges de l'utilisateur
forward
global type uo_privs from nonvisualobject
end type
end forward

global type uo_privs from nonvisualobject
end type
global uo_privs uo_privs

type variables
uo_ds		ids_privs, ids_superprivs
string	is_groups[]
end variables

forward prototypes
public function integer uf_canupdate (string as_prog)
public function integer uf_candelete (string as_prog)
public function integer uf_initprivs ()
public function integer uf_initprivs (string as_domain, string as_username)
public function integer uf_canconsult (string as_prog)
public function boolean uf_super (string as_categorie)
public function boolean uf_checkgroups (string as_grouplist[])
end prototypes

public function integer uf_canupdate (string as_prog);// renvoie 1 si l'utilisateur à le droit de modifier les données dans le programme as_prog
// renvoie 0 s'il faut utiliser les droits d'accès par défaut du programme as_prog
// renvoie -1 si l'utilisateur n'a pas le droit de modifier les données dans le programme as_prog

long	ll_found

as_prog = lower(as_prog)
ll_found = ids_privs.Find("prog='" + as_prog + "'", 1, 999999999)
IF ll_found = 0 THEN
	return(0)
END IF
IF ids_privs.object.modif[ll_found] = "N" THEN
	return(-1)
ELSE
	return(1)
END IF

end function

public function integer uf_candelete (string as_prog);// renvoie 1 si l'utilisateur à le droit de supprimer des records dans le programme as_prog
// renvoie 0 s'il faut utiliser les droits d'accès par défaut du programme as_prog
// renvoie -1 si l'utilisateur n'a pas le droit de supprimer des records dans le programme as_prog

long	ll_found

as_prog = lower(as_prog)
ll_found = ids_privs.Find("prog='" + as_prog + "'", 1, 999999999)
IF ll_found = 0 THEN
	return(0)
END IF
IF ids_privs.object.suppres[ll_found] = "N" THEN
	return(-1)
ELSE
	return(1)
END IF

end function

public function integer uf_initprivs ();// initialiser le datastore qui contiendra les privilèges de l'utilisateur en cours
// (seulement les privilèges différents des privilèges standards)
// return(1) si ok
// return(-1) si erreur

return(uf_initprivs(gs_domain, gs_username))
end function

public function integer uf_initprivs (string as_domain, string as_username);// initialiser le datastore qui contiendra les privilèges de l'utilisateur 
// (seulement les privilèges différents des privilèges standards)
// return(1) si ok
// return(-1) si erreur

integer	li_userid, li_stat, li_i
string	ls_usergroups, ls_prog, ls_consult, ls_modif, ls_suppres
uo_ds		lds_privs, lds_superprivs
long		ll_nb, ll_j, ll_found

select userid, groups into :li_userid, :ls_usergroups from dnfusers
	where domain=:as_domain and logname=:as_username using ESQLCA;
li_stat = f_check_sql(ESQLCA)
IF li_stat < 0 THEN
	populateerror(20000,"")
	gu_message.uf_unexp("Erreur SELECT DNFUSERS")
	return(-1)
END IF

ids_privs.reset()
ids_superprivs.reset()

// lire les droits des groupes auxquels le user appartient (programmes, superuser)
lds_privs = CREATE uo_ds
lds_privs.dataobject = "d_privslu"
lds_privs.SetTransObject(SQLCA)

lds_superprivs = CREATE uo_ds
lds_superprivs.dataobject = "d_superprivslu"
lds_superprivs.SetTransObject(SQLCA)

// user non défini : on utilisera les droits d'accès par défaut définis dans le groupe 1 (Public)
IF li_stat = 100 THEN
	li_userid = 0
	ls_usergroups = "1"
END IF
f_parse(ls_usergroups, ",", is_groups)
FOR li_i = 1 TO upperbound(is_groups)
	// droits par programme
	ll_nb = lds_privs.retrieve(integer(is_groups[li_i]))
	FOR ll_j = 1 TO ll_nb
		ll_found = ids_privs.Find("prog='" + lds_privs.object.prog[ll_j] + "'", 1, 999999999)
		IF ll_found > 0 THEN
			IF lds_privs.object.consult[ll_j] = "O" THEN
				ids_privs.object.consult[ll_found] = "O"
			END IF
			IF lds_privs.object.modif[ll_j] = "O" THEN
				ids_privs.object.modif[ll_found] = "O"
			END IF
			IF lds_privs.object.suppres[ll_j] = "O" THEN
				ids_privs.object.suppres[ll_found] = "O"
			END IF
		ELSE
			lds_privs.RowsCopy(ll_j, ll_j, Primary!, ids_privs, 999999999, Primary!)
		END IF
	NEXT
	// super-privilèges par catégorie
	ll_nb = lds_superprivs.retrieve(integer(is_groups[li_i]))
	FOR ll_j = 1 TO ll_nb
		ll_found = ids_superprivs.Find("categorie='" + lds_superprivs.object.categorie[ll_j] + "'", 1, 999999999)
		IF ll_found > 0 THEN
		ELSE
			lds_superprivs.RowsCopy(ll_j, ll_j, Primary!, ids_superprivs, 999999999, Primary!)
		END IF
	NEXT
NEXT

// lire les droits spécifiques de l'utilisateur (droits supplémentaires ou en moins par rapport aux groupes)
// droits par programme
ll_nb = lds_privs.retrieve(li_userid)
FOR ll_j = 1 TO ll_nb
	ll_found = ids_privs.Find("prog='" + lds_privs.object.prog[ll_j] + "'", 1, 999999999)
	IF ll_found > 0 THEN
		ids_privs.object.consult[ll_found] = lds_privs.object.consult[ll_j]
		ids_privs.object.modif[ll_found] = lds_privs.object.modif[ll_j]
		ids_privs.object.suppres[ll_found] = lds_privs.object.suppres[ll_j]
	ELSE
		lds_privs.RowsCopy(ll_j, ll_j, Primary!, ids_privs, 999999999, Primary!)
	END IF
NEXT

// superdroits par catégorie
ll_nb = lds_superprivs.retrieve(li_userid)
FOR ll_j = 1 TO ll_nb
	ll_found = ids_superprivs.Find("categorie='" + lds_superprivs.object.categorie[ll_j] + "'", 1, 999999999)
	IF ll_found > 0 THEN
	ELSE
		lds_superprivs.RowsCopy(ll_j, ll_j, Primary!, ids_superprivs, 999999999, Primary!)
	END IF
NEXT

ids_privs.sort()
ids_superprivs.sort()
DESTROY lds_privs
DESTROY lds_superprivs
return(1)
end function

public function integer uf_canconsult (string as_prog);// renvoie 1 si l'utilisateur à le droit de consulter le programme as_prog
// renvoie 0 s'il faut utiliser les droits d'accès par défaut du programme as_prog
// renvoie -1 si l'utilisateur n'a pas accès au programme as_prog

long	ll_found

as_prog = lower(as_prog)
ll_found = ids_privs.Find("prog='" + as_prog + "'", 1, 999999999)
IF ll_found = 0 THEN
	return(0)
END IF
IF ids_privs.object.consult[ll_found] = "N" THEN
	return(-1)
ELSE
	return(1)
END IF

end function

public function boolean uf_super (string as_categorie);// renvoie TRUE si l'utilisateur est 'superuser' de la catégorie as_categorie
// renvoie FALSE si l'utilisateur n'est pas 'superuser' de la catégorie as_categorie

long	ll_found

as_categorie = upper(as_categorie)
ll_found = ids_superprivs.Find("categorie='" + as_categorie + "'", 1, 999999999)
IF ll_found = 0 THEN
	return(FALSE)
ELSE
	return(TRUE)
END IF

end function

public function boolean uf_checkgroups (string as_grouplist[]);// PCO 18/02/2016
// Vérifie si au moins l'un des groupes passés en argument fait partie des groupes de l'utilisateur.
// return TRUE ou FALSE
integer	li_i, li_g

FOR li_i = 1 TO upperBound(as_grouplist)
	FOR li_g = 1 TO upperBound(is_groups)
		IF as_grouplist[li_i] = is_groups[li_g] THEN
			return(TRUE)
		END IF
	NEXT
NEXT

return(FALSE)
end function

on uo_privs.create
call super::create
TriggerEvent( this, "constructor" )
end on

on uo_privs.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

event constructor;// créer datastore (type external) qui contiendra les droits d'accès de l'utilisateurs
ids_privs = CREATE uo_ds
ids_privs.DataObject = "d_privs"
ids_superprivs = CREATE uo_ds
ids_superprivs.DataObject = "d_superprivs"


end event

event destructor;DESTROY ids_privs
DESTROY ids_superprivs
end event

