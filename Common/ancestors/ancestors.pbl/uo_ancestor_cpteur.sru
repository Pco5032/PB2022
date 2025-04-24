forward
global type uo_ancestor_cpteur from nonvisualobject
end type
end forward

global type uo_ancestor_cpteur from nonvisualobject
end type
global uo_ancestor_cpteur uo_ancestor_cpteur

type variables
transaction	itr_cpteur
end variables

forward prototypes
public function decimal uf_getsession ()
public function long uf_update (string as_usage, string as_id1, string as_id2, string as_id3, string as_id4, string as_id5, decimal ad_valeur)
public function long uf_rollback ()
public function integer uf_resetcompteur (string as_usage)
public function long uf_commit ()
protected function decimal uf_getcpteur (string as_usage, boolean ab_auto, string as_id1, string as_id2, string as_id3, string as_id4, string as_id5)
protected function decimal uf_getcpteur (string as_usage, boolean ab_auto, boolean ab_commitimmediate, string as_id1, string as_id2, string as_id3, string as_id4, string as_id5)
end prototypes

public function decimal uf_getsession ();// renvoie un n° de session unique, utilisé une seule fois au début de l'application
return(uf_getcpteur("SESSION",TRUE,"","","","",""))
end function

public function long uf_update (string as_usage, string as_id1, string as_id2, string as_id3, string as_id4, string as_id5, decimal ad_valeur);// updater le compteur passé en paramètre avec la valeur passée en paramètre

// les arguments non utilisés sont nullifiés
as_usage = trim(upper(as_usage))
IF LenA(as_usage) = 0 THEN SetNull(as_usage)
as_id1 = trim(as_id1)
IF LenA(as_id1) = 0 THEN SetNull(as_id1)
as_id2 = trim(as_id2)
IF LenA(as_id2) = 0 THEN SetNull(as_id2)
as_id3 = trim(as_id3)
IF LenA(as_id3) = 0 THEN SetNull(as_id3)
as_id4 = trim(as_id4)
IF LenA(as_id4) = 0 THEN SetNull(as_id4)
as_id5 = trim(as_id5)
IF LenA(as_id5) = 0 THEN SetNull(as_id5)

// type de compteur doit être précisé dans les arguments
IF IsNull(as_usage) THEN
	gu_message.uf_error("Le compteur à utiliser n'est pas précisé")
	return(-1)
END IF

// nouvelle valeur du compteur doit être précisée
IF IsNull(ad_valeur) THEN
	gu_message.uf_error("La valeur du compteur n'est pas précisée")
	return(-1)
END IF

// 'where' suivant les arguments utilisés
IF IsNull(as_id1) THEN
	update cpteur
	set lastused = :ad_valeur
		where usage = :as_usage	USING itr_cpteur;
ELSEIF IsNull(as_id2) THEN
	update cpteur
		set lastused = :ad_valeur
		where usage = :as_usage	AND id1 = :as_id1 USING itr_cpteur;
ELSEIF IsNull(as_id3) THEN
	update cpteur
		set lastused = :ad_valeur
		where usage = :as_usage	AND id1 = :as_id1	AND id2 = :as_id2 USING itr_cpteur;
ELSEIF IsNull(as_id4) THEN
	update cpteur
		set lastused = :ad_valeur
		where usage = :as_usage	AND id1 = :as_id1	AND id2 = :as_id2	AND id3 = :as_id3 USING itr_cpteur;
ELSEIF IsNull(as_id5) THEN
	update cpteur
		set lastused = :ad_valeur
		where usage = :as_usage	AND id1 = :as_id1	AND id2 = :as_id2	AND id3 = :as_id3	AND id4 = :as_id4 USING itr_cpteur;
ELSE
	update cpteur
		set lastused = :ad_valeur
		where usage = :as_usage	AND id1 = :as_id1	AND id2 = :as_id2	AND id3 = :as_id3	AND id4 = :as_id4	AND id5 = :as_id5 USING itr_cpteur;
END IF
f_check_sql(itr_cpteur)
return(itr_cpteur.sqlcode)

end function

public function long uf_rollback ();rollback USING itr_cpteur;
f_check_sql(itr_cpteur)
return(itr_cpteur.sqlcode)
end function

public function integer uf_resetcompteur (string as_usage);// fonction appelée par le bouton de réinitialisation du compteur sélectionné
// Cette fonction doit être complétée dans le descendant de uo_ancestor_cpteur
// car c'est seulement là qu'on connait les compteurs possibles de l'application
// as_usage est le nom du compteur à réinitialiser
// return(1) si le compteur a bien été initialisé
// return(0) si pas de compteur sélectionné
// return(-1) si erreur lors de la réinitialisation

// exemple de code pour le descendant :
//
//CHOOSE CASE as_usage
//	CASE "MART1.NOFI"
//		IF gu_message.uf_query("Voulez-vous initialiser le compteur " + as_usage, YesNO!,2) = 1 THEN
//			IF uf_resetnofi() = 1 THEN
//				gu_message.uf_info("Initialisation OK")
//				return(1)
//			ELSE
//				gu_message.uf_error("Problème d'initialisation")
//				return(-1)
//			END IF
//		END IF
//	CASE ELSE
//		gu_message.uf_info("Initialisation non prévue pour ce compteur")
//		return(0)
//END CHOOSE

return(0)
end function

public function long uf_commit ();commit using itr_cpteur;
f_check_sql(itr_cpteur)
return(itr_cpteur.sqlcode)
end function

protected function decimal uf_getcpteur (string as_usage, boolean ab_auto, string as_id1, string as_id2, string as_id3, string as_id4, string as_id5);// Sur base d'un nom de compteur (as_usage) et de paramètres (as_id?), fournit le prochain n° de séquence utilisable.
// Si le compteur cité par l'argument USAGE n'existe pas, on le crée.
//
// IN : 
//		. as_usage : nom (utilisation) du compteur (par exemple, pour n° de fiche de martelage, mart1.nofi)
//		. ab_auto : si TRUE, le compteur est automatiquement updaté après avoir fournit le n°
//					   si FALSE, le compteur est locké après avoir fournit le n°, il doit être updaté ou libéré explicitement
//									 dès que possible (fonction uf_update() ou uf_release()
//		. as_id1 à as_id5 : jusqu'à 5 paramètres pour identifier le compteur (par exemple, pour n° de fiche de martelage, as_id1=année de martelage)
//
// OUT :
// 	. un n° de séquence utilisable pour le compteur et les arguments listés en arguments,
// 	. -1 si l'argument USAGE n'est pas garni ou en cas d'erreur SQL
// 	. -2 si le compteur est locked

return(uf_getcpteur(as_usage, ab_auto, TRUE, as_id1, as_id2, as_id3, as_id4, as_id5))
end function

protected function decimal uf_getcpteur (string as_usage, boolean ab_auto, boolean ab_commitimmediate, string as_id1, string as_id2, string as_id3, string as_id4, string as_id5);// Sur base d'un nom de compteur (as_usage) et de paramètres (as_id?), fournit le prochain n° de séquence utilisable.
// Si le compteur cité par l'argument USAGE n'existe pas, on le crée.
//
// IN : 
//		. as_usage : nom (utilisation) du compteur (par exemple, pour n° de fiche de martelage, mart1.nofi)
//		. ab_auto : si TRUE, le compteur est automatiquement updaté après avoir fournit le n°. Voir aussi ab_commitImmediate.
//					   si FALSE, le compteur est locké après avoir fournit le n°, il doit être updaté ou libéré explicitement
//									 dès que possible (fonction uf_update() ou uf_release()
//	   . ab_commitImmediate : si ab_auto=TRUE, ab_commitImmediate indique s'il faut commiter le changement immédiatement
//									  ou s'il le sera ultérieurement, manuellement. Cela permet de pratiquer plusieurs incrémentation
//									  du compteur et de faire un rollback ensuite si nécessaire.
//		. as_id1 à as_id5 : jusqu'à 5 paramètres pour identifier le compteur (par exemple, pour n° de fiche de martelage, as_id1=année de martelage)
//
// OUT :
// 	. un n° de séquence utilisable pour le compteur et les arguments listés en arguments,
// 	. -1 si l'argument USAGE n'est pas garni ou en cas d'erreur SQL
// 	. -2 si le compteur est locked

decimal{0}	ld_cpteur,ld_step
long			ll_code

// les arguments non utilisés sont nullifiés
as_usage = trim(upper(as_usage))
IF LenA(as_usage) = 0 THEN SetNull(as_usage)
as_id1 = trim(as_id1)
IF LenA(as_id1) = 0 THEN SetNull(as_id1)
as_id2 = trim(as_id2)
IF LenA(as_id2) = 0 THEN SetNull(as_id2)
as_id3 = trim(as_id3)
IF LenA(as_id3) = 0 THEN SetNull(as_id3)
as_id4 = trim(as_id4)
IF LenA(as_id4) = 0 THEN SetNull(as_id4)
as_id5 = trim(as_id5)
IF LenA(as_id5) = 0 THEN SetNull(as_id5)

// type de compteur doit être précisé dans les arguments
IF IsNull(as_usage) THEN
	gu_message.uf_error("Le compteur à utiliser n'est pas précisé")
	return(-1)
END IF

// lecture du compteur demandé; 'where' suivant les arguments utilisés
IF IsNull(as_id1) THEN
	select lastused, step into :ld_cpteur, :ld_step from cpteur 
		where usage = :as_usage FOR UPDATE NOWAIT
		USING itr_cpteur;
ELSEIF IsNull(as_id2) THEN
	select lastused, step into :ld_cpteur, :ld_step from cpteur 
		where usage = :as_usage and id1 = :as_id1 FOR UPDATE NOWAIT
		USING itr_cpteur;
ELSEIF IsNull(as_id3) THEN
	select lastused, step into :ld_cpteur, :ld_step from cpteur 
		where usage = :as_usage and id1 = :as_id1 and id2 = :as_id2 FOR UPDATE NOWAIT
		USING itr_cpteur;
ELSEIF IsNull(as_id4) THEN
	select lastused, step into :ld_cpteur, :ld_step from cpteur 
		where usage = :as_usage and id1 = :as_id1 and id2 = :as_id2 and id3 = :as_id3 FOR UPDATE NOWAIT
		USING itr_cpteur;
ELSEIF IsNull(as_id5) THEN
	select lastused, step into :ld_cpteur, :ld_step from cpteur 
		where usage = :as_usage and id1 = :as_id1 and id2 = :as_id2 and id3 = :as_id3 and id4 = :as_id4 FOR UPDATE NOWAIT
		USING itr_cpteur;		
ELSE
	select lastused, step into :ld_cpteur, :ld_step from cpteur 
		where usage = :as_usage and id1 = :as_id1 and id2 = :as_id2 and id3 = :as_id3 and id4 = :as_id4 and id5 = :as_id5 FOR UPDATE NOWAIT
		USING itr_cpteur;		
END IF

	// on n'utilise pas la fonction f_check_sql() car on veut éviter le message d'erreur standard
CHOOSE CASE itr_cpteur.sqlcode
	// si le compteur existe bien, l'incrémenter
	CASE 0
		ld_cpteur = ld_cpteur + ld_step
		IF ld_cpteur > 999999000000.0 THEN ld_cpteur = 1.0
		// si pas de mise à jour automatique du compteur, on renvoie le n° de séquence en laissant le compteur locké
		IF NOT ab_auto THEN
			return(ld_cpteur)
		END IF
		// si mise à jour automatique, on update directement le compteur et on renvoie le n° de séquence
		IF uf_update(as_usage, as_id1, as_id2, as_id3, as_id4, as_id5, ld_cpteur) = -1 THEN
			return(-1)
		ELSE
			IF ab_commitImmediate THEN
				uf_commit()
			END IF
			return(ld_cpteur)
		END IF
	// si le compteur n'existe pas encore, le créer	(avec compteur=0, step=1) puis l'utiliser
	CASE 100
		insert into cpteur
			values (:as_usage, :as_id1, :as_id2, :as_id3, :as_id4, :as_id5, 0, 1) USING itr_cpteur;
		IF f_check_sql(itr_cpteur) <> 0 THEN
			rollback USING itr_cpteur;
			gu_message.uf_error("Erreur de création du compteur " + as_usage)
			return(-1)
		ELSE
			return(uf_getcpteur(as_usage, ab_auto, as_id1, as_id2, as_id3, as_id4, as_id5))
		END IF
	// autre erreur SQL
	CASE -1
		ll_code = itr_cpteur.sqldbcode
		rollback USING itr_cpteur;
		// si le compteur est locké par un autre utilisateur, message spécifique
		IF ll_code = 54 THEN
			gu_message.uf_error("Le compteur " + as_usage + " est en cours d'utilisation. Réessayez plus tard.")
			return(-2)
		ELSE
			gu_message.uf_error("Erreur SQL lors de l'utilisation du compteur " + as_usage)
			return(-1)
		END IF
END CHOOSE

end function

on uo_ancestor_cpteur.create
call super::create
TriggerEvent( this, "constructor" )
end on

on uo_ancestor_cpteur.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

event constructor;itr_cpteur = create transaction
itr_cpteur.DBMS = sqlca.DBMS
itr_cpteur.database = sqlca.database
itr_cpteur.servername = sqlca.servername
itr_cpteur.userid = sqlca.userid
itr_cpteur.dbpass = sqlca.dbpass
itr_cpteur.logid = sqlca.logid
itr_cpteur.logpass = sqlca.logpass
itr_cpteur.dbparm = sqlca.dbparm
connect using itr_cpteur;

end event

event destructor;rollback using itr_cpteur;
disconnect using itr_cpteur;
end event

