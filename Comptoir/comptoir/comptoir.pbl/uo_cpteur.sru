forward
global type uo_cpteur from uo_ancestor_cpteur
end type
end forward

global type uo_cpteur from uo_ancestor_cpteur
end type
global uo_cpteur uo_cpteur

forward prototypes
public function long uf_getnumprov (string as_codesp)
public function integer uf_update_numprov (string as_codesp, decimal ad_valeur)
public function integer uf_resetnumprov ()
public function integer uf_resetcompteur (string as_usage)
public function long uf_getnumaut (integer ai_annee)
public function integer uf_update_numaut (integer ai_annee, decimal ad_valeur)
public function integer uf_resetnumaut ()
public function long uf_getnumcat ()
public function integer uf_update_numcat (decimal ad_valeur)
public function integer uf_resetnumcat ()
public function long uf_getnumcmde (integer ai_annee)
public function integer uf_update_numcmde (integer ai_annee, decimal ad_valeur)
public function integer uf_resetnumcmde ()
public function long uf_getnumbord (integer ai_ancmde, integer ai_numcmde)
public function integer uf_update_numbord (integer ai_ancmde, integer ai_numcmde, decimal ad_valeur)
public function integer uf_resetnumbord ()
public function long uf_getnumcphys (string as_reflot)
public function integer uf_update_numcphys (string as_reflot, decimal ad_valeur)
public function integer uf_resetnumcphys ()
public function long uf_getnumqgerm (string as_reflot)
public function integer uf_resetnumqgerm ()
public function integer uf_update_numqgerm (string as_reflot, decimal ad_valeur)
public function long uf_getnumviab (string as_reflot)
public function integer uf_update_numviab (string as_reflot, decimal ad_valeur)
public function integer uf_resetnumviab ()
end prototypes

public function long uf_getnumprov (string as_codesp);// Renvoie prochain n° de provenance dans l'espèce AS_CODESP

return(uf_getcpteur("PROVENANCE.NUM_PROV",FALSE,as_codesp,"","","",""))
end function

public function integer uf_update_numprov (string as_codesp, decimal ad_valeur);// mise à jour du compteur des numéro de provenance par espèce
IF uf_update("PROVENANCE.NUM_PROV", as_codesp, "", "", "", "", ad_valeur) = -1 THEN
	uf_rollback()
	return(-1)
ELSE
	uf_commit()
	return(1)
END IF

end function

public function integer uf_resetnumprov ();// initialiser le compteur PROVENANCE.NUM_PROV (un compteur par CODE_SP)
string	ls_sql, ls_codesp
integer	li_numprov

ls_sql = "select code_sp, max(num_prov) from PROVENANCE group by code_sp"
DECLARE l_cursor DYNAMIC CURSOR FOR SQLSA;
PREPARE SQLSA FROM :ls_sql USING itr_cpteur;
OPEN DYNAMIC l_cursor ;
IF f_check_sql(itr_cpteur) < 0 THEN
	GOTO ERREUR
END IF

delete cpteur where usage = 'PROVENANCE.NUM_PROV' using itr_cpteur;
IF f_check_sql(itr_cpteur) < 0 THEN
	GOTO ERREUR
END IF

FETCH l_cursor INTO :ls_codesp, :li_numprov;
DO WHILE f_check_sql(itr_cpteur) = 0
	insert into cpteur
		values ('PROVENANCE.NUM_PROV', :ls_codesp, :gu_c.s_null, :gu_c.s_null, :gu_c.s_null, :gu_c.s_null, to_char(:li_numprov), 1) USING itr_cpteur;
		IF f_check_sql(itr_cpteur) <> 0 THEN
			GOTO ERREUR
		END IF
	FETCH l_cursor INTO :ls_codesp, :li_numprov;
LOOP

commit using itr_cpteur;
CLOSE l_cursor;
return(1)

ERREUR:
rollback using itr_cpteur;
CLOSE l_cursor;
gu_message.uf_error("Erreur de réinitialisation du compteur PROVENANCE.NUM_PROV")
return(-1)



end function

public function integer uf_resetcompteur (string as_usage);CHOOSE CASE as_usage
	CASE "PROVENANCE.NUM_PROV"
		IF gu_message.uf_query("Voulez-vous initialiser le compteur " + as_usage, YesNO!,2) = 1 THEN
			IF uf_resetnumprov() = 1 THEN
				gu_message.uf_info("Initialisation OK")
				return(1)
			ELSE
				gu_message.uf_error("Problème d'initialisation du compteur " + as_usage)
				return(-1)
			END IF
		END IF
	CASE "AUTORISATION.NUM_AUT"
		IF gu_message.uf_query("Voulez-vous initialiser le compteur " + as_usage, YesNO!,2) = 1 THEN
			IF uf_resetnumaut() = 1 THEN
				gu_message.uf_info("Initialisation OK")
				return(1)
			ELSE
				gu_message.uf_error("Problème d'initialisation du compteur " + as_usage)
				return(-1)
			END IF
		END IF
	CASE "CAT_VENTE.NUM_CAT"
		IF gu_message.uf_query("Voulez-vous initialiser le compteur " + as_usage, YesNO!,2) = 1 THEN
			IF uf_resetnumcat() = 1 THEN
				gu_message.uf_info("Initialisation OK")
				return(1)
			ELSE
				gu_message.uf_error("Problème d'initialisation du compteur " + as_usage)
				return(-1)
			END IF
		END IF
	CASE "COMMANDE.NUM_CMDE"
		IF gu_message.uf_query("Voulez-vous initialiser le compteur " + as_usage, YesNO!,2) = 1 THEN
			IF uf_resetnumcmde() = 1 THEN
				gu_message.uf_info("Initialisation OK")
				return(1)
			ELSE
				gu_message.uf_error("Problème d'initialisation du compteur " + as_usage)
				return(-1)
			END IF
		END IF
	CASE "BORD_LIV.NUM_BORD"
		IF gu_message.uf_query("Voulez-vous initialiser le compteur " + as_usage, YesNO!,2) = 1 THEN
			IF uf_resetnumbord() = 1 THEN
				gu_message.uf_info("Initialisation OK")
				return(1)
			ELSE
				gu_message.uf_error("Problème d'initialisation du compteur " + as_usage)
				return(-1)
			END IF
		END IF
		
	CASE "CPHYS.NUM_TEST"
		IF gu_message.uf_query("Voulez-vous initialiser le compteur " + as_usage, YesNO!,2) = 1 THEN
			IF uf_resetnumcphys() = 1 THEN
				gu_message.uf_info("Initialisation OK")
				return(1)
			ELSE
				gu_message.uf_error("Problème d'initialisation du compteur " + as_usage)
				return(-1)
			END IF
		END IF
		
	CASE "QGERM.NUM_TEST"
		IF gu_message.uf_query("Voulez-vous initialiser le compteur " + as_usage, YesNO!,2) = 1 THEN
			IF uf_resetnumqgerm() = 1 THEN
				gu_message.uf_info("Initialisation OK")
				return(1)
			ELSE
				gu_message.uf_error("Problème d'initialisation du compteur " + as_usage)
				return(-1)
			END IF
		END IF
		
	CASE "VIABILITE.NUM_TEST"
		IF gu_message.uf_query("Voulez-vous initialiser le compteur " + as_usage, YesNO!,2) = 1 THEN
			IF uf_resetnumviab() = 1 THEN
				gu_message.uf_info("Initialisation OK")
				return(1)
			ELSE
				gu_message.uf_error("Problème d'initialisation du compteur " + as_usage)
				return(-1)
			END IF
		END IF
		
	CASE ELSE
		gu_message.uf_info("Initialisation non prévue pour ce compteur")
		return(0)
END CHOOSE

return(0)
end function

public function long uf_getnumaut (integer ai_annee);// Renvoie prochain n° d'autorisation dans l'année AI_ANNEE

return(uf_getcpteur("AUTORISATION.NUM_AUT",FALSE,string(ai_annee),"","","",""))
end function

public function integer uf_update_numaut (integer ai_annee, decimal ad_valeur);// mise à jour du compteur des numéro d'autorisation par année
IF uf_update("AUTORISATION.NUM_AUT", string(ai_annee), "", "", "", "", ad_valeur) = -1 THEN
	uf_rollback()
	return(-1)
ELSE
	uf_commit()
	return(1)
END IF

end function

public function integer uf_resetnumaut ();// initialiser le compteur AUTORISATION.NUM_AUT (un compteur par AN_AUT)
string	ls_sql
integer	li_anaut, li_numaut

ls_sql = "select an_aut, max(num_aut) from AUTORISATION group by an_aut"
DECLARE l_cursor DYNAMIC CURSOR FOR SQLSA;
PREPARE SQLSA FROM :ls_sql USING itr_cpteur;
OPEN DYNAMIC l_cursor ;
IF f_check_sql(itr_cpteur) < 0 THEN
	GOTO ERREUR
END IF

delete cpteur where usage = 'AUTORISATION.NUM_AUT' using itr_cpteur;
IF f_check_sql(itr_cpteur) < 0 THEN
	GOTO ERREUR
END IF

FETCH l_cursor INTO :li_anaut, :li_numaut;
DO WHILE f_check_sql(itr_cpteur) = 0
	insert into cpteur
		values ('AUTORISATION.NUM_AUT', to_char(:li_anaut), :gu_c.s_null, :gu_c.s_null, :gu_c.s_null, :gu_c.s_null, to_char(:li_numaut), 1) USING itr_cpteur;
		IF f_check_sql(itr_cpteur) <> 0 THEN
			GOTO ERREUR
		END IF
	FETCH l_cursor INTO :li_anaut, :li_numaut;
LOOP

commit using itr_cpteur;
CLOSE l_cursor;
return(1)

ERREUR:
rollback using itr_cpteur;
CLOSE l_cursor;
gu_message.uf_error("Erreur de réinitialisation du compteur AUTORISATION.NUM_AUT")
return(-1)



end function

public function long uf_getnumcat ();// Renvoie prochain n° de catalogue

return(uf_getcpteur("CAT_VENTE.NUM_CAT",FALSE,"","","","",""))
end function

public function integer uf_update_numcat (decimal ad_valeur);// mise à jour du compteur des catalogues
IF uf_update("CAT_VENTE.NUM_CAT", "", "", "", "", "", ad_valeur) = -1 THEN
	uf_rollback()
	return(-1)
ELSE
	uf_commit()
	return(1)
END IF

end function

public function integer uf_resetnumcat ();// initialiser le compteur CAT_VENTE.NUM_CAT
string	ls_sql
integer	li_numcat

ls_sql = "select max(num_cat) from CAT_VENTE"
DECLARE l_cursor DYNAMIC CURSOR FOR SQLSA;
PREPARE SQLSA FROM :ls_sql USING itr_cpteur;
OPEN DYNAMIC l_cursor ;
IF f_check_sql(itr_cpteur) < 0 THEN
	GOTO ERREUR
END IF

delete cpteur where usage = 'CAT_VENTE.NUM_CAT' using itr_cpteur;
IF f_check_sql(itr_cpteur) < 0 THEN
	GOTO ERREUR
END IF

FETCH l_cursor INTO :li_numcat;
DO WHILE f_check_sql(itr_cpteur) = 0
	insert into cpteur
		values ('CAT_VENTE.NUM_CAT', :gu_c.s_null, :gu_c.s_null, :gu_c.s_null, :gu_c.s_null, :gu_c.s_null, to_char(:li_numcat), 1) USING itr_cpteur;
		IF f_check_sql(itr_cpteur) <> 0 THEN
			GOTO ERREUR
		END IF
	FETCH l_cursor INTO :li_numcat;
LOOP

commit using itr_cpteur;
CLOSE l_cursor;
return(1)

ERREUR:
rollback using itr_cpteur;
CLOSE l_cursor;
gu_message.uf_error("Erreur de réinitialisation du compteur CAT_VENTE.NUM_CAT")
return(-1)



end function

public function long uf_getnumcmde (integer ai_annee);// Renvoie prochain n° de commande dans l'année AI_ANNEE

return(uf_getcpteur("COMMANDE.NUM_CMDE",FALSE,string(ai_annee),"","","",""))
end function

public function integer uf_update_numcmde (integer ai_annee, decimal ad_valeur);// mise à jour du compteur des numéro de commande par année
IF uf_update("COMMANDE.NUM_CMDE", string(ai_annee), "", "", "", "", ad_valeur) = -1 THEN
	uf_rollback()
	return(-1)
ELSE
	uf_commit()
	return(1)
END IF

end function

public function integer uf_resetnumcmde ();// initialiser le compteur AUTORISATION.NUM_CMDE (un compteur par AN_CMDE)
string	ls_sql
integer	li_ancmde, li_numcmde

ls_sql = "select an_cmde, max(num_cmde) from COMMANDE group by an_cmde"
DECLARE l_cursor DYNAMIC CURSOR FOR SQLSA;
PREPARE SQLSA FROM :ls_sql USING itr_cpteur;
OPEN DYNAMIC l_cursor ;
IF f_check_sql(itr_cpteur) < 0 THEN
	GOTO ERREUR
END IF

delete cpteur where usage = 'COMMANDE.NUM_CMDE' using itr_cpteur;
IF f_check_sql(itr_cpteur) < 0 THEN
	GOTO ERREUR
END IF

FETCH l_cursor INTO :li_ancmde, :li_numcmde;
DO WHILE f_check_sql(itr_cpteur) = 0
	insert into cpteur
		values ('COMMANDE.NUM_CMDE', to_char(:li_ancmde), :gu_c.s_null, :gu_c.s_null, :gu_c.s_null, :gu_c.s_null, to_char(:li_numcmde), 1) USING itr_cpteur;
		IF f_check_sql(itr_cpteur) <> 0 THEN
			GOTO ERREUR
		END IF
	FETCH l_cursor INTO :li_ancmde, :li_numcmde;
LOOP

commit using itr_cpteur;
CLOSE l_cursor;
return(1)

ERREUR:
rollback using itr_cpteur;
CLOSE l_cursor;
gu_message.uf_error("Erreur de réinitialisation du compteur COMMANDE.NUM_CMDE")
return(-1)



end function

public function long uf_getnumbord (integer ai_ancmde, integer ai_numcmde);// Renvoie prochain n° de bordereau pour la commande ai_ancmde/ai_numcmde

return(uf_getcpteur("BORD_LIV.NUM_BORD",FALSE,string(ai_ancmde),string(ai_numcmde),"","",""))
end function

public function integer uf_update_numbord (integer ai_ancmde, integer ai_numcmde, decimal ad_valeur);// mise à jour du compteur des numéro d'autorisation par commande
IF uf_update("BORD_LIV.NUM_BORD", string(ai_ancmde), string(ai_numcmde), "", "", "", ad_valeur) = -1 THEN
	uf_rollback()
	return(-1)
ELSE
	uf_commit()
	return(1)
END IF

end function

public function integer uf_resetnumbord ();// initialiser le compteur BORD_LIV.NUM_BORD (un compteur par AN_CMDE/NUM_CMDE)
string	ls_sql
integer	li_ancmde, li_numcmde, li_numbord

ls_sql = "select an_cmde, num_cmde, max(num_bord) from BORD_LIV group by an_cmde, num_cmde"
DECLARE l_cursor DYNAMIC CURSOR FOR SQLSA;
PREPARE SQLSA FROM :ls_sql USING itr_cpteur;
OPEN DYNAMIC l_cursor ;
IF f_check_sql(itr_cpteur) < 0 THEN
	GOTO ERREUR
END IF

delete cpteur where usage = 'BORD_LIV.NUM_BORD' using itr_cpteur;
IF f_check_sql(itr_cpteur) < 0 THEN
	GOTO ERREUR
END IF

FETCH l_cursor INTO :li_ancmde, :li_numcmde, :li_numbord;
DO WHILE f_check_sql(itr_cpteur) = 0
	insert into cpteur
		values ('BORD_LIV.NUM_BORD', to_char(:li_ancmde), to_char(:li_numcmde), :gu_c.s_null, :gu_c.s_null, :gu_c.s_null, to_char(:li_numbord), 1) USING itr_cpteur;
		IF f_check_sql(itr_cpteur) <> 0 THEN
			GOTO ERREUR
		END IF
	FETCH l_cursor INTO :li_ancmde, :li_numcmde, :li_numbord;
LOOP

commit using itr_cpteur;
CLOSE l_cursor;
return(1)

ERREUR:
rollback using itr_cpteur;
CLOSE l_cursor;
gu_message.uf_error("Erreur de réinitialisation du compteur BORD_LIV.NUM_CMDE")
return(-1)



end function

public function long uf_getnumcphys (string as_reflot);// Renvoie prochain n° de test de caractéristiques physiques pour le lot as_reflot

return(uf_getcpteur("CPHYS.NUM_TEST",FALSE,as_reflot,"","","",""))
end function

public function integer uf_update_numcphys (string as_reflot, decimal ad_valeur);// mise à jour du compteur des numéro de test de caractéristiques physiques pour un lot
IF uf_update("CPHYS.NUM_TEST", as_reflot, "", "", "", "", ad_valeur) = -1 THEN
	uf_rollback()
	return(-1)
ELSE
	uf_commit()
	return(1)
END IF

end function

public function integer uf_resetnumcphys ();// initialiser le compteur CPHYS.NUM_TEST (un n° par REF_LOT)
string	ls_sql, ls_reflot
integer	li_numtest

ls_sql = "select ref_lot, max(num_test) from GRAINE_CPHYS group by ref_lot"
DECLARE l_cursor DYNAMIC CURSOR FOR SQLSA;
PREPARE SQLSA FROM :ls_sql USING itr_cpteur;
OPEN DYNAMIC l_cursor ;
IF f_check_sql(itr_cpteur) < 0 THEN
	GOTO ERREUR
END IF

delete cpteur where usage = 'CPHYS.NUM_TEST' using itr_cpteur;
IF f_check_sql(itr_cpteur) < 0 THEN
	GOTO ERREUR
END IF

FETCH l_cursor INTO :ls_reflot, :li_numtest;
DO WHILE f_check_sql(itr_cpteur) = 0
	insert into cpteur
		values ('CPHYS.NUM_TEST', :ls_reflot, :gu_c.s_null, :gu_c.s_null, :gu_c.s_null, :gu_c.s_null, to_char(:li_numtest), 1) USING itr_cpteur;
		IF f_check_sql(itr_cpteur) <> 0 THEN
			GOTO ERREUR
		END IF
	FETCH l_cursor INTO :ls_reflot, :li_numtest;
LOOP

commit using itr_cpteur;
CLOSE l_cursor;
return(1)

ERREUR:
rollback using itr_cpteur;
CLOSE l_cursor;
gu_message.uf_error("Erreur de réinitialisation du compteur CPHYS.NUM_TEST")
return(-1)



end function

public function long uf_getnumqgerm (string as_reflot);// Renvoie prochain n° de test de qualités germinatives pour le lot as_reflot

return(uf_getcpteur("QGERM.NUM_TEST",FALSE,as_reflot,"","","",""))
end function

public function integer uf_resetnumqgerm ();// initialiser le compteur QGERM.NUM_TEST (un n° par REF_LOT)
string	ls_sql, ls_reflot
integer	li_numtest

ls_sql = "select ref_lot, max(num_test) from GRAINE_QGERM group by ref_lot"
DECLARE l_cursor DYNAMIC CURSOR FOR SQLSA;
PREPARE SQLSA FROM :ls_sql USING itr_cpteur;
OPEN DYNAMIC l_cursor ;
IF f_check_sql(itr_cpteur) < 0 THEN
	GOTO ERREUR
END IF

delete cpteur where usage = 'QGERM.NUM_TEST' using itr_cpteur;
IF f_check_sql(itr_cpteur) < 0 THEN
	GOTO ERREUR
END IF

FETCH l_cursor INTO :ls_reflot, :li_numtest;
DO WHILE f_check_sql(itr_cpteur) = 0
	insert into cpteur
		values ('QGERM.NUM_TEST', :ls_reflot, :gu_c.s_null, :gu_c.s_null, :gu_c.s_null, :gu_c.s_null, to_char(:li_numtest), 1) USING itr_cpteur;
		IF f_check_sql(itr_cpteur) <> 0 THEN
			GOTO ERREUR
		END IF
	FETCH l_cursor INTO :ls_reflot, :li_numtest;
LOOP

commit using itr_cpteur;
CLOSE l_cursor;
return(1)

ERREUR:
rollback using itr_cpteur;
CLOSE l_cursor;
gu_message.uf_error("Erreur de réinitialisation du compteur QGERM.NUM_TEST")
return(-1)



end function

public function integer uf_update_numqgerm (string as_reflot, decimal ad_valeur);// mise à jour du compteur des numéro de test de qualités germinatives pour un lot
IF uf_update("QGERM.NUM_TEST", as_reflot, "", "", "", "", ad_valeur) = -1 THEN
	uf_rollback()
	return(-1)
ELSE
	uf_commit()
	return(1)
END IF

end function

public function long uf_getnumviab (string as_reflot);// Renvoie prochain n° de test de viabilité pour le lot as_reflot

return(uf_getcpteur("VIABILITE.NUM_TEST",FALSE,as_reflot,"","","",""))
end function

public function integer uf_update_numviab (string as_reflot, decimal ad_valeur);// mise à jour du compteur des numéro de test de viabilité pour un lot
IF uf_update("VIABILITE.NUM_TEST", as_reflot, "", "", "", "", ad_valeur) = -1 THEN
	uf_rollback()
	return(-1)
ELSE
	uf_commit()
	return(1)
END IF

end function

public function integer uf_resetnumviab ();// initialiser le compteur VIABILITE.NUM_TEST (un n° par REF_LOT)
string	ls_sql, ls_reflot
integer	li_numtest

ls_sql = "select ref_lot, max(num_test) from GRAINE_VIABILITE group by ref_lot"
DECLARE l_cursor DYNAMIC CURSOR FOR SQLSA;
PREPARE SQLSA FROM :ls_sql USING itr_cpteur;
OPEN DYNAMIC l_cursor ;
IF f_check_sql(itr_cpteur) < 0 THEN
	GOTO ERREUR
END IF

delete cpteur where usage = 'VIABILITE.NUM_TEST' using itr_cpteur;
IF f_check_sql(itr_cpteur) < 0 THEN
	GOTO ERREUR
END IF

FETCH l_cursor INTO :ls_reflot, :li_numtest;
DO WHILE f_check_sql(itr_cpteur) = 0
	insert into cpteur
		values ('VIABILITE.NUM_TEST', :ls_reflot, :gu_c.s_null, :gu_c.s_null, :gu_c.s_null, :gu_c.s_null, to_char(:li_numtest), 1) USING itr_cpteur;
		IF f_check_sql(itr_cpteur) <> 0 THEN
			GOTO ERREUR
		END IF
	FETCH l_cursor INTO :ls_reflot, :li_numtest;
LOOP

commit using itr_cpteur;
CLOSE l_cursor;
return(1)

ERREUR:
rollback using itr_cpteur;
CLOSE l_cursor;
gu_message.uf_error("Erreur de réinitialisation du compteur VIABILITE.NUM_TEST")
return(-1)



end function

on uo_cpteur.create
call super::create
end on

on uo_cpteur.destroy
call super::destroy
end on

