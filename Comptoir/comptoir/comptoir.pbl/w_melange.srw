//objectcomments Constitution des mélanges de CM
forward
global type w_melange from w_ancestor_dataentry
end type
type dw_entete from uo_datawindow_singlerow within w_melange
end type
type dw_detail from uo_datawindow_multiplerow within w_melange
end type
end forward

global type w_melange from w_ancestor_dataentry
integer width = 2994
integer height = 2152
string title = "Constitution des mélanges de CM"
dw_entete dw_entete
dw_detail dw_detail
end type
global w_melange w_melange

type variables
string	is_numcm, is_typemelange, is_typemfr, is_codesp, is_reflotP
CONSTANT string is_codeFluxMelange="M", is_codeFluxRectifP="R+"
integer	ii_numprov, ii_numregprov, ii_anmaturite

br_certificat	ibr_certificat
br_registre		ibr_registre
end variables

forward prototypes
public function integer wf_init ()
public function integer wf_newcomposant ()
public function integer wf_update ()
end prototypes

public function integer wf_init ();// lecture du record
dw_entete.retrieve(is_numcm)
is_reflotp = dw_entete.object.registre_ref_lot[1]
is_typemelange = dw_entete.object.melange[1]

// lecture des composants actuels du mélange
dw_detail.retrieve(is_numcm)

// disabler la clé et enabler les datas
dw_detail.uf_enabledata()
dw_detail.SetColumn("num_cm_melange")
dw_detail.SetFocus()

dw_entete.uf_enabledata()
dw_entete.uf_disablekeys()

// si pas de mélange : interdire d'ajouter des composants
IF dw_entete.object.melange[1] = "N" THEN
	dw_detail.enabled = FALSE
ELSE
	dw_detail.enabled = TRUE
END IF
return(1)
end function

public function integer wf_newcomposant ();// ajout d'un nouveau composant au mélange
long	ll_row

ll_row = dw_detail.event ue_addrow()
IF ll_row <= 0 THEN
	return(-1)
END IF

// initialiser 1ère partie de la PK
dw_detail.object.num_cm[ll_row] = is_numcm

dw_detail.SetColumn("num_cm_melange")

return(1)
end function

public function integer wf_update ();// validation des modifications
// NB : on fait tous les updates/insert/delete dans SQLCA

long		ll_row
string	ls_reflotm, ls_err, ls_rem, ls_codeFlux, ls_texte
integer	li_numflux, li_status, li_anaut, li_numaut
decimal{3}	ld_totqte, ld_qte_init, ld_qte_new, ld_qte
date		l_dtdemande
dwItemStatus l_status

// 1. m-à-j du lot lié au CM principal :
//    - code mélange = même valeur que le CM principal
//    - quantité admise = somme des quantités à mélanger de tous les composants du mélange (0 si pas de mélange)
IF is_typeMelange = "N" THEN
	ld_totqte = 0
ELSE
	ld_totqte = dw_detail.object.c_totqte[1]
END IF
update registre
	set melange = :is_typemelange, qte_admise = :ld_totqte where ref_lot=:is_reflotp using SQLCA;
IF f_check_sql(SQLCA) <> 0 THEN
	populateError(20000, "")
	ls_err = "Erreur update registre"
	GOTO ERREUR
END IF

// 1bis. m-à-j du CM principal :
//    - quantité de MFR = somme des quantités à mélanger de tous les composants du mélange
IF is_typeMelange <> "N" THEN
	dw_entete.object.qte_mfr[1] = dw_detail.object.c_totqte[1]
END IF

// 1ter. m-à-j de l'autorisation liée au CM principal :
//    - quantité totale autorisée = somme des quantités à mélanger de tous les composants du mélange
IF is_typeMelange <> "N" THEN
	li_anaut = dw_entete.object.an_aut[1]
	li_numaut = dw_entete.object.num_aut[1]
	ld_totqte = dw_detail.object.c_totqte[1]
	update autorisation
		set QTE_MFR_TOTAL = :ld_totqte where an_aut=:li_anaut and num_aut=:li_numaut using SQLCA;
	IF f_check_sql(SQLCA) <> 0 THEN
		populateError(20000, "")
		ls_err = "Erreur update autorisation"
		GOTO ERREUR
	END IF
END IF

// 21/01/2009 : date des flux = date de la demande d'autorisation et non date du jour
select dt_demande into :l_dtdemande from autorisation
		where an_aut=:li_anaut and num_aut=:li_numaut using SQLCA;
IF f_check_sql(SQLCA) <> 0 THEN
	populateError(20000, "")
	ls_err = "Erreur select AUTORISATION"
	GOTO ERREUR
END IF

// 2. il faut corriger les qté en stock des constituants effacés du mélange en faisant des flux de correction 
// en sens inverse (rajouter ce qui avait été soustrait).
// NB : si on a changé le type de mélange (ou annulé le mélange), les composants du mélanges ont été effacés 
// et doivent être traités de la même façon.
FOR ll_row = 1 TO dw_detail.deletedCount()
	ls_reflotm = dw_detail.object.registre_ref_lot.delete.original[ll_row]
	ld_qte_init = dw_detail.object.qte.delete.original[ll_row]
	ls_rem = "Annulation du mélange avec CM n° " + is_numcm + " (lot n° " + is_reflotP + ")"

	// chercher prochain n° de flux
	select max(num_flux) into :li_numflux from flux_registre where ref_lot=:ls_reflotm using SQLCA;
	IF f_check_sql(SQLCA) <> 0 THEN
		populateError(20000, "")
		ls_err = "Erreur select flux_registre"
		GOTO ERREUR
	END IF
	IF IsNull(li_numflux) OR li_numflux = 0 THEN
		li_numflux = 1
	ELSE
		li_numflux = li_numflux + 1
	END IF
	IF li_numflux > 999 THEN
		populateError(20000, "")
		ls_err = "Nombre maximum de flux dépassé pour le lot n° " + f_string(ls_reflotm)
		GOTO ERREUR
	END IF
	
	insert into flux_registre columns(REF_LOT, NUM_FLUX, UTILISATION, LIEU_STOCK, DT_OP, QTE, DESTINATAIRE, REMARQUE)
		VALUES (:ls_reflotm, :li_numflux, :is_codeFluxRectifP, '-', :l_dtdemande, :ld_qte_init, :gs_locuCPT, :ls_rem) 
		using SQLCA;
	IF f_check_sql(SQLCA) <> 0 THEN
		populateError(20000, "")
		ls_err = "Erreur insert into flux_registre (1)"
		GOTO ERREUR
	END IF
NEXT

// 3. créer les flux de soustraction des qté mélangées sur les lots inclus dans le mélange
//    Attention : ne créer des mouvements de flux que pour les nouveaux composants du mélange,
//    ou si on a modifié la quantité. Dans ce cas, on crée un flux MELANGE si on a augmenté la quantité,
//    et un flux RECTIFICATION+ si on l'a diminuée.
FOR ll_row = 1 TO dw_detail.rowCount()
	ls_reflotm = dw_detail.object.registre_ref_lot[ll_row]
	l_status = dw_detail.getitemstatus(ll_row, 0, Primary!)
	// bizarrement, ...qte.original[] ne donne pas null ou 0 pour les nouvelles rows...
	IF l_status = new! OR l_status= newModified! THEN
		ld_qte_init = 0
	ELSE
		ld_qte_init = dw_detail.object.qte.original[ll_row]
	END IF
	ld_qte_new = dw_detail.object.qte[ll_row]
	ld_qte = ld_qte_new - ld_qte_init
	IF ld_qte = 0 THEN
		CONTINUE // pas de modif. des la quantité
	END IF
	IF ld_qte > 0 THEN
		ls_codeFlux = is_codeFluxMelange
		ls_rem = "Mélangé au CM n° " + is_numcm + " (lot n° " + is_reflotP + ")"
	ELSE
		ls_codeFlux = is_codeFluxRectifP
		ld_qte = ld_qte * -1
		ls_rem = "Retiré du mélange avec CM n° " + is_numcm + " (lot n° " + is_reflotP + ")"
	END IF
	
	// chercher prochain n° de flux
	select max(num_flux) into :li_numflux from flux_registre where ref_lot=:ls_reflotm using SQLCA;
	IF f_check_sql(SQLCA) <> 0 THEN
		populateError(20000, "")
		ls_err = "Erreur select flux_registre"
		GOTO ERREUR
	END IF
	IF IsNull(li_numflux) OR li_numflux = 0 THEN
		li_numflux = 1
	ELSE
		li_numflux = li_numflux + 1
	END IF
	IF li_numflux > 999 THEN
		populateError(20000, "")
		ls_err = "Nombre maximum de flux dépassé pour le lot n° " + f_string(ls_reflotm)
		GOTO ERREUR
	END IF
	
	insert into flux_registre columns(REF_LOT, NUM_FLUX, UTILISATION, LIEU_STOCK, DT_OP, QTE, DESTINATAIRE, REMARQUE)
		VALUES (:ls_reflotm, :li_numflux, :ls_codeFlux, '-', :l_dtdemande, :ld_qte, :gs_locuCPT, :ls_rem) 
		using SQLCA;
	IF f_check_sql(SQLCA) <> 0 THEN
		populateError(20000, "")
		ls_err = "Erreur insert into flux_registre (2)"
		GOTO ERREUR
	END IF
NEXT

// 4. update CERTIFICAT et CM_MELANGE
li_status = gu_dwservices.uf_updatetransact(dw_entete, dw_detail)
CHOOSE CASE li_status
	CASE 1
		wf_message("Modifications enregistrées avec succès")
		GOTO OK
	CASE -1
		populateerror(20000,"")
		ls_err = "CERTIFICAT : Erreur lors de la mise à jour de la base de données"
		GOTO ERREUR
	CASE -2
		populateerror(20000,"")
		ls_err = "CM_MELANGE : Erreur lors de la mise à jour de la base de données"
		GOTO ERREUR
END CHOOSE

OK:
// m-à-j OK
commit using SQLCA;

// Lot de base : initialiser le commentaire avec le calcul des proportions du mélange
ls_texte = ibr_registre.uf_init_remqte(is_reflotP)
IF NOT f_IsEmptyString(ls_texte) THEN
	update registre
		set rem_qte = :ls_texte where ref_lot=:is_reflotp using SQLCA;
	IF f_check_sql(SQLCA) = 0 THEN
		commit using SQLCA;
	ELSE
		rollback using SQLCA;
	END IF
END IF

This.event ue_init_win()
return(1)

ERREUR:
rollback using SQLCA;
gu_message.uf_unexp(ls_err)
return(-1)
end function

on w_melange.create
int iCurrent
call super::create
this.dw_entete=create dw_entete
this.dw_detail=create dw_detail
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_entete
this.Control[iCurrent+2]=this.dw_detail
end on

on w_melange.destroy
call super::destroy
destroy(this.dw_entete)
destroy(this.dw_detail)
end on

event ue_init_win;call super::ue_init_win;this.setredraw(FALSE)

dw_entete.uf_reset()
dw_detail.uf_reset()

dw_entete.insertrow(0)
dw_entete.uf_disabledata()
dw_entete.uf_enablekeys()
dw_entete.enabled = TRUE

dw_detail.uf_disabledata()

this.setredraw(TRUE)

dw_entete.setfocus()


end event

event ue_open;call super::ue_open;ibr_certificat = CREATE br_certificat
ibr_registre = CREATE br_registre

// icône "ajouter" doit être visible dans le menu
wf_SetItemsToShow({"m_ajouter"})

// DW à mettre à jour
wf_SetDWList({dw_entete, dw_detail})

end event

event ue_close;call super::ue_close;DESTROY ibr_certificat
DESTROY ibr_registre
end event

event ue_init_menu;call super::ue_init_menu;string	ls_menu[]
integer	li_item

li_item = 1
ls_menu = {"m_fermer"}

IF wf_IsActif() THEN
	li_item++
	ls_menu[li_item] = "m_abandonner"
	IF wf_canUpdate() THEN
		li_item++
		ls_menu[li_item] = "m_enregistrer"
	END IF
	CHOOSE CASE wf_GetActivecontrolname()
		// menu si curseur est sur le DW détail
		CASE "dw_detail"
			IF wf_canUpdate() THEN
				li_item++
				ls_menu[li_item] = "m_ajouter"
				li_item++
				ls_menu[li_item] = "m_supprimer"				
			END IF
	
	END CHOOSE
END IF

f_menuaction(ls_menu)


end event

event ue_ajouter;call super::ue_ajouter;long	ll_row

CHOOSE CASE wf_GetActivecontrolname()
	// ajouter un nouveau composant au mélange
	CASE "dw_detail"
		IF dw_detail.accepttext() < 0 THEN return
		wf_newComposant()
END CHOOSE
end event

event ue_supprimer;call super::ue_supprimer;long		ll_row

CHOOSE CASE wf_GetActivecontrolname()
	// suppression d'un composant du mélange
	CASE  "dw_detail"
		ll_row = dw_detail.GetRow()
		IF ll_row <= 0 THEN return
		IF f_confirm_del("Voulez-vous supprimer du mélange le CM n°  " + &
							  f_string(dw_detail.object.num_cm_melange[ll_row]) + " ?") = 1 THEN
			IF dw_detail.event ue_delete() = 1 THEN
				wf_message("CM supprimé avec succès du mélange")
			END IF
		END IF
END CHOOSE

end event

event ue_enregistrer;call super::ue_enregistrer;integer	li_status
long		ll_row
dwItemStatus l_status

// supprimer les lignes ajoutées mais vides
FOR ll_row = dw_detail.rowCount() TO 1 step -1
	l_Status = dw_detail.GetItemStatus(ll_row, 0, Primary!)
	IF l_status = new! THEN
		dw_detail.RowsDiscard(ll_row, ll_row, Primary!)
	END IF
NEXT

// il faut au moins 1 CM pour constituer le mélange
IF is_typeMelange <> "N" AND dw_detail.rowcount() = 0 THEN
	gu_message.uf_info("Veuillez décrire les CM qui constituent le mélange.")
	dw_detail.SetFocus()
	return(-1)
END IF

// contrôle de validité de tous les champs
IF dw_entete.event ue_checkall() < 0 THEN
	dw_entete.SetFocus()
	return(-1)
END IF
IF dw_detail.event ue_checkall() < 0 THEN
	dw_detail.SetFocus()
	return(-1)
END IF

return(wf_update())

end event

type ddlb_message from w_ancestor_dataentry`ddlb_message within w_melange
integer x = 18
integer y = 1984
integer width = 2578
end type

type dw_entete from uo_datawindow_singlerow within w_melange
integer width = 2999
integer height = 464
integer taborder = 10
boolean bringtotop = true
string dataobject = "d_melange_entete"
borderstyle borderstyle = stylebox!
end type

event ue_help;call super::ue_help;str_params	lstr_params

IF NOT isValid(idwo_currentItem) THEN return
IF isNull(idwo_currentItem) THEN return

CHOOSE CASE idwo_currentItem.name
	CASE "num_cm"
		lstr_params.a_param[1] = gu_c.s_null
		lstr_params.a_param[2] = "certificat.melange<>'N'"
		lstr_params.a_param[3] = FALSE
		openwithparm(w_l_certificat, lstr_params)
		IF Message.DoubleParm = -1 THEN 
			return
		ELSE
			lstr_params=Message.PowerObjectParm
			this.SetText(f_string(lstr_params.a_param[1]))
			f_presskey("TAB")
		END IF
END CHOOSE


end event

event ue_checkitem;call super::ue_checkitem;string	ls_typemfr, ls_codesp, ls_melange
integer	li_numprov, li_numregprov, li_anmaturite

CHOOSE CASE as_item
	CASE "num_cm"
		// lire si le CM peut être utilisé et lire les données qui seront nécessaires au contrôle de validité 
		// de chaque composant du mélange
		SELECT c.type_mfr, c.melange, p.code_sp, p.num_prov, p.num_regprov, r.an_maturite
			into :ls_typemfr, :ls_melange, :ls_codesp, :li_numprov, :li_numregprov, :li_anmaturite
			FROM certificat c, provenance p, registre r  
			WHERE r.num_cm = c.num_cm and p.code_sp = r.code_sp and p.num_prov = r.num_prov and  
	   	      c.num_cm = :as_data using ESQLCA;
		IF ESQLCA.sqlnRows = 0 THEN
			as_message = "Certificat-maître inexistant, ou pas lié à un lot."
			return(-1)
		END IF
	
		IF ls_melange = "N" THEN
			as_message = "Ce certificat n'est pas destiné à devenir un mélange"
			return(-1)
		END IF
	
		IF ls_typemfr <> '1' and ls_typemfr <> '2' THEN
			as_message = "Les mélanges ne sont pas possibles pour les clônes et mélanges clonaux."
			return(-1)
		END IF
		
		is_numcm = as_data
		is_typemfr = ls_typemfr
		is_codesp = ls_codesp
		ii_numprov = li_numprov
		ii_numregprov = li_numregprov
		ii_anmaturite = li_anmaturite
		return(1)
		
	CASE "melange"
		// le changement de type de mélange a une influence sur le contenu, donc on s'assure qu'il est correct
		// avant d'accepter le changement
		IF dw_detail.acceptText() < 0 THEN
			dw_detail.SetFocus()
			return(-2)
		END IF
		IF ibr_certificat.uf_check_melange(as_data, as_message) = -1 THEN
			return(-1)
		ELSE
			// si mélange de provenances, le CM principal doit avoir une année de maturité
			IF as_data = "P" AND (isNull(ii_anmaturite) OR ii_anmaturite=0) THEN
				as_message = "Mélange de provenances : l'année de maturité du lot principal doit être indiquée."
				return(-1)
			END IF
			is_typemelange = as_data
			return(1)
		END IF
END CHOOSE

return(1)
end event

event ue_leavekey;call super::ue_leavekey;// quand on quitte la clé, cela veut dire qu'on dispose de données actives dans la fenêtre
wf_actif(true)

// effacer les messages
ddlb_message.reset()

parent.event ue_init_menu()

post wf_init()



end event

event getfocus;call super::getfocus;w_ancestor_dataentry	lw_parent

// réactualiser le menu car l'option 'ajouter' n'est pas toujours disponible
IF f_GetParentWindow(this, lw_parent) = 1 THEN
	lw_parent.event ue_init_menu()
END IF

end event

event ue_itemvalidated;call super::ue_itemvalidated;long	ll_row
dwItemStatus l_status

CHOOSE CASE as_name
	// Annulation du mélange ou changement de type : supprimer les composants actuels
	// Attention : lors de l'enregistrement il faudra modifier les flux etc...
	CASE "melange"
		// si pas de mélange : interdire d'ajouter des composants
		IF as_data = "N" THEN
			dw_detail.enabled = FALSE
		ELSE
			dw_detail.enabled = TRUE
		END IF
		// si on revient au type qu'il y avait au départ, on annule la suppression sinon on supprime
		IF this.object.melange.original[al_row] = as_data THEN
			dw_detail.RowsMove(1, dw_detail.DeletedCount(), Delete!, dw_detail, 1, Primary!)
		ELSE
			// NB : on ne tient pas compte des nouvelles rows (d'où le discard avant le delete)
			FOR ll_row = dw_detail.rowCount() TO 1 step -1
				l_Status = dw_detail.GetItemStatus(ll_row, 0, Primary!)
				IF l_status = new! OR l_status = newModified! THEN
					dw_detail.RowsDiscard(ll_row, ll_row, Primary!)
				END IF
			NEXT
			dw_detail.RowsMove(1, dw_detail.rowCount(), Primary!, dw_detail, 1, Delete!)
		END IF
END CHOOSE
end event

type dw_detail from uo_datawindow_multiplerow within w_melange
integer x = 18
integer y = 464
integer width = 2944
integer height = 1488
integer taborder = 11
boolean bringtotop = true
string dataobject = "d_melange_detail"
boolean minbox = true
boolean vscrollbar = true
boolean border = true
end type

event getfocus;call super::getfocus;w_ancestor_dataentry	lw_parent

// réactualiser le menu car l'option 'ajouter' n'est pas toujours disponible
IF f_GetParentWindow(this, lw_parent) = 1 THEN
	lw_parent.event ue_init_menu()
END IF

end event

event ue_help;call super::ue_help;str_params	lstr_params

IF NOT isValid(idwo_currentItem) THEN return
IF isNull(idwo_currentItem) THEN return

CHOOSE CASE idwo_currentItem.name
	CASE "num_cm_melange"
		open(w_l_certificat)
		IF Message.DoubleParm = -1 THEN 
			return
		ELSE
			lstr_params=Message.PowerObjectParm
			this.SetText(f_string(lstr_params.a_param[1]))
			f_presskey("TAB")
		END IF
END CHOOSE


end event

event ue_checkitem;call super::ue_checkitem;string	ls_typemfr, ls_codesp, ls_cm, ls_reflot
integer	li_anmaturite, li_numprov, li_numregprov
decimal{3}	ld_QteRestante, ld_qte
long		ll_row
dwItemStatus l_status

CHOOSE CASE as_item
	CASE "num_cm_melange"
		// on ne peut pas modifier le CM une fois que le mélange a été enregistré
		l_status = this.getitemstatus(al_row, 0, Primary!)
		IF NOT (l_status = new! OR l_status= newModified!) AND &
			as_data <> this.object.num_cm_melange.original[al_row] THEN
				as_message = "On ne peut pas modifier le n° de CM une fois que le mélange a été enregistré.~n" + &
							 "Vous devez supprimer cette ligne et en créer une nouvelle avec le N° de CM souhaité."
			return(-1)
		END IF
		
		// CM doit être différent du CM principal
		IF as_data = is_numcm THEN
			as_message = "Vous ne pouvez pas inclure un lot dans lui-même !"
			return(-1)
		END IF

		// On ne peut pas avoir 2 fois le même CM dans les composants du mélange
		IF gu_dwservices.uf_findduplicate(This, al_row, "num_cm_melange='" + as_data + "'") <> 0 THEN
			as_message = "Ce n° de certificat est déjà inclus dans le mélange."
			return(-1)
		END IF
		
		// On ne peut pas créer un composant qui reprend le même n° de CM qu'un composant
		// qu'on vient de supprimer. Il faut enregistrer les modif. avant.
		FOR ll_row = 1 TO this.deletedCount()
			IF as_data = this.object.num_cm_melange.delete[ll_row] THEN
				as_message = "Ce n° de certificat est repris dans un constituant en attente de suppression.~n" + &
								 "Pour l'y ajouter à nouveau, vous devez enregistrer les modifications " + &
								 "en cours, puis rappeler et modifier la quantité utilisée pour ce CM."
				return(-1)
			END IF
		NEXT

		// lire les données nécessaires au contrôle de validité du CM dans le mélange
		SELECT c.type_mfr, r.an_maturite, p.code_sp, p.num_prov, p.num_regprov, r.ref_lot
			into :ls_typemfr, :li_anmaturite, :ls_codesp, :li_numprov, :li_numregprov, :ls_reflot
			FROM certificat c, provenance p, registre r  
			WHERE r.code_sp = p.code_sp and r.num_prov = p.num_prov and  
	   	      r.num_cm = c.num_cm and c.num_cm = :as_data
			using ESQLCA;
		IF ESQLCA.sqlnRows = 0 THEN
			as_message = "Certificat-maître inexistant, ou pas lié à un lot."
			return(-1)
		END IF
		
		// verifier si le CM existe et s'il est bien du type 1 ou 2
		IF ls_typemfr <> '1' and ls_typemfr <> '2' THEN
			as_message = "Les clônes et mélanges clonaux ne peuvent être inclus dans un mélange."
			return(-1)
		END IF
	
		// vérifier si le CM peut être utilisé dans ce mélange
		// 1. Quel que soit le type de mélange : code espèce doit être le même pour tous les composants
		IF ls_codesp <> is_codesp THEN
			as_message = "L'espèce est différente de celle du lot principal, on ne peut pas l'inclure dans ce mélange."
			return(-1)
		END IF
		// 2. mélange de type 'provenances' : ne peut contenir que des lots d'une seule 
		//    REGION de provenance ET une seule année de maturité.
		//    L'année de maturité est donc indispensable.
		IF is_typemelange = "P" THEN
			IF li_anmaturite = 0 OR IsNull(li_anmaturite) THEN
				as_message = "Mélange de provenances : l'année de maturité du lot doit être indiquée."
				return(-1)
			END IF
			IF li_numregprov <> ii_numregprov THEN
				as_message = "Mélange de provenances : la région de provenance de ce lot est différente " + &
								 "de celle du lot principal, on ne peut pas l'inclure dans ce mélange."
				return(-1)
			END IF
			IF li_anmaturite <> ii_anmaturite THEN
				as_message = "Mélange de provenances : l'année de maturité de ce lot est différente " + &
								 "de celle du lot principal, on ne peut pas l'inclure dans ce mélange."
				return(-1)
			END IF
		END IF
		// 3. mélange d'années de maturité : ne peut contenir que des lots issus d'une seule provenance
		IF is_typemelange = "A" THEN
			IF li_numprov <> ii_numprov THEN
				as_message = "Mélange d'années de maturité : la provenance de ce lot est différente " + &
								 "de celle du lot principal, on ne peut pas l'inclure dans ce mélange."
				return(-1)
			END IF
		END IF

		// 4. qté stock restante : on refuse le CM s'il n'y a pas de stock
		select qte_restante into :ld_QteRestante from v_totflux where num_cm = :as_data using ESQLCA;
		IF f_check_sql(ESQLCA) <> 0 THEN
			as_message = "Erreur SELECT V_TOTFLUX : impossible de déterminer la quantité restante."
			return(-1)
		END IF
		
		ld_qte = this.object.qte.original[al_row]
		IF IsNull(ld_Qte) THEN ld_qte = 0
		ld_QteRestante = ld_QteRestante + ld_qte
		IF IsNull(ld_QteRestante) OR ld_QteRestante <= 0 THEN
			as_message = "Il ne reste rien en stock pour ce lot (n° " + f_string(ls_reflot) + ")"
			return(-1)
		END IF
		
		// afficher les données dans le DW
		this.object.registre_ref_lot[al_row] = ls_reflot
		this.object.registre_an_maturite[al_row] = li_anmaturite
		this.object.v_totflux_qte_restante[al_row] = ld_QteRestante
		
		return(1)
	
	CASE "qte"
		// vérifier que la qté à mélanger est > 0 et qu'on n'utilise pas plus que la quantité restant en stock
		ld_qte = dec(as_data)
		IF IsNull(ld_qte) OR ld_qte <= 0 THEN
			as_message = "Veuillez spécifier la quantité à utiliser dans le mélange."
			return(-1)
		END IF
		ld_QteRestante = this.object.v_totflux_qte_restante[al_row] + this.object.qte.original[al_row]
		IF ld_qte > ld_QteRestante THEN
			as_message = "Quantité supérieure à la quantité en stock."
			return(-1)
		END IF
		
		return(1)
				
END CHOOSE

return(1)
end event

event ue_itemvalidated;call super::ue_itemvalidated;CHOOSE CASE as_name
	CASE "num_cm_melange"
		this.object.qte[al_row] = gu_c.d_null
END CHOOSE
end event

