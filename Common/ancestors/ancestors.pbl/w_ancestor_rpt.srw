//objectcomments Ancêtre de base des reports - pas utilisé directement mais un de ses descendants
forward
global type w_ancestor_rpt from w_ancestor
end type
end forward

global type w_ancestor_rpt from w_ancestor
integer width = 2642
integer height = 1920
string title = "Visualisation avant impression"
boolean ib_canupdate = true
event type integer ue_beforeretrieve ( )
event ue_enregistrer ( )
event ue_init ( )
event type integer ue_print ( )
event type long ue_retrieve ( )
event type integer ue_manualsql ( string as_newselect )
event ue_pre_enregistrer ( )
end type
global w_ancestor_rpt w_ancestor_rpt

type variables
PRIVATE boolean	ib_cancelpermitted, ib_trienabled, ib_appendOrderBy, ib_buttons, ib_selection, ib_sqlfromdw
PRIVATE integer	ii_nbcrit, ii_nbcrittri, ii_nbgroups
PRIVATE string		is_insertionpoint, is_evalmsg, is_selectionwindow, is_reportcritere, is_modele, &
						is_originalselect
string	is_where, is_order
string	is_tag_reading="TEXT_00113", is_tag_nodata="TEXT_00114",  is_tag_printing="TEXT_00115", &
			is_tag_resizing="TEXT_00116"
message	im_message
uo_wait	iu_wait
str_params		istr_inputparams, istr_selectionparams
uo_critselect	iu_critselect
end variables

forward prototypes
public subroutine wf_settitle (string as_title)
public subroutine wf_setmodel (string as_modele)
public subroutine wf_showselection (boolean ab_selection)
public subroutine wf_sqlfromdw (boolean ab_sqlfromdw)
public subroutine wf_setoriginalselect (string as_select)
public subroutine wf_setselectionwindow (string as_selectionwindow)
public function integer wf_setmoreselectparams (any aa_param)
public subroutine wf_setreportcritere (string as_reportcritere)
public subroutine wf_trienabled (boolean ab_selection)
public function integer wf_resetdefaults ()
public subroutine wf_setinsertionpoint (string as_insertionpoint)
public subroutine wf_cancel (boolean ab_cancel)
public subroutine wf_setevalmsg (string as_msg)
public function integer wf_setdefault (string as_critere, string as_operateur)
public function integer wf_setdefault (string as_critere, string as_operateur, any aa_valeur)
public function integer wf_setdefault (string as_critere, string as_operateur, any aa_valeur, boolean ab_obligatoire)
public function integer wf_setdefault (string as_critere, string as_operateur, boolean ab_obligatoire)
public function integer wf_setdefault (string as_par1, string as_critere, string as_operateur, any aa_valeur, string as_par2, boolean ab_obligatoire)
public function integer wf_setdefault (string as_par1, string as_critere, string as_operateur, any aa_valeur, string as_par2, string as_connect, boolean ab_obligatoire)
public function integer wf_setdefault (string as_par1, string as_critere, string as_operateur, any aa_valeur, string as_par2, string as_connect, boolean ab_obligatoire, boolean ab_valeurmodifiable)
public function integer wf_setdefault (string as_par1, string as_critere, string as_operateur, string as_par2, boolean ab_obligatoire)
public function integer wf_setdefaulttri (string as_critere)
public subroutine wf_buttonsenabled (boolean ab_buttons)
public function integer wf_setdefaulttri (string as_critere, string as_order)
public function integer wf_setdefaulttri (string as_critere, string as_ordre, string as_groupe, string as_newpage)
public function integer wf_setpredeftri (integer ai_id)
public subroutine wf_setnbgroups (integer ai_nbgroups)
public function integer wf_getnbgroups ()
public function boolean wf_cancelpermitted ()
public function boolean wf_trienabled ()
public function boolean wf_buttonsenabled ()
public function boolean wf_showselection ()
public function boolean wf_sqlfromdw ()
public function string wf_getinsertionpoint ()
public function string wf_getevalmsg ()
public function string wf_getselectionwindow ()
public function string wf_getreportcritere ()
public function string wf_getmodel ()
public function string wf_getoriginalselect ()
public subroutine wf_setdefaultmsg ()
public subroutine wf_appendorderby (boolean ab_selection)
public function boolean wf_appendorderby ()
end prototypes

event ue_init;// ATTENTION : cet event est déclenché (trigger) par l'event UE_OPEN, donc on ne peut encore rien afficher à ce stade

// exemples d'initialisation possibles :
// spécifier le titre de la fenêtre
// wf_settitle("titre")

// spécifier le nom du datawindowobject s'il n'est pas défini directement dans les propriété du DW control ou datastore
// wf_setdataobject("d_xxxx")

// spécifier le noms du modèle
// wf_setmodel("PARCELLE1")

// initialiser les critères de sélection par défaut
// 1 : effacer les anciens critères par wf_resetdefaults()
// 2 : ajouter un à un les critères voulus : wf_setdefault(......)

end event

event type integer ue_print();// modif. 04/11/2008 : return(ii_printed) qui donne 0 si pas d'impression (annulation), > 0 en cas d'impression
// Le code de retour correct est renvoyé par les descendants
return(0)
end event

event ue_retrieve;return(0)
end event

event ue_manualsql;// event appelé (trigger) par ue_beforeretrieve quand le SELECT d'origine ne provient pas du DW, que l'utilisateur
// a éventuellement fait sa sélection et que le nouvel ordre SQL est donc disponible pour faire le traitement nécessaire
// return -1 en cas d'erreur
// return 1 si OK
return 1
end event

event ue_pre_enregistrer();// event déclenché quand on demande d'enregistrer le rapport
// Si l'utilisateur a le droit d'update dans cette fenêtre, on déclenche ue_enregistrer, sinon pas
IF wf_canupdate() THEN
	this.event ue_enregistrer()
ELSE
	gu_message.uf_info(wf_getMessageNoUpdate())
	return
END IF
end event

public subroutine wf_settitle (string as_title);this.title = as_title
end subroutine

public subroutine wf_setmodel (string as_modele);is_modele = as_modele
end subroutine

public subroutine wf_showselection (boolean ab_selection);// initialise la variable ib_selection
ib_selection = ab_Selection
end subroutine

public subroutine wf_sqlfromdw (boolean ab_sqlfromdw);// initialise la variable ib_sqlfromdw
ib_sqlfromdw = ab_sqlfromdw
end subroutine

public subroutine wf_setoriginalselect (string as_select);is_originalselect = as_select
end subroutine

public subroutine wf_setselectionwindow (string as_selectionwindow);// choix de la fenêtre de sélection à utiliser
is_selectionwindow = as_selectionwindow
end subroutine

public function integer wf_setmoreselectparams (any aa_param);/* initialiser un paramètre supplémentaire qui devra être passé à l'écran de sélection en même temps que les
   paramètres normaux (normalement, on utilise cela que pour passer des paramètres à un descendant de la fenêtre
	de sélection standard
	return = n° du paramètre supplémentaire dans l'array
*/
integer	li_pos

li_pos = upperbound(istr_inputparams.a_param) + 1
istr_inputparams.a_param[li_pos] = aa_param
return(li_pos)
end function

public subroutine wf_setreportcritere (string as_reportcritere);// permet de spécifier le nom du report duquel il faut utiliser les critères de sélection (pour utiliser 
// dans un report les mêmes critères de sélection que dans un autre)
is_reportcritere = as_reportcritere
end subroutine

public subroutine wf_trienabled (boolean ab_selection);// initialise la variable ib_trienabled
ib_trienabled = ab_Selection
end subroutine

public function integer wf_resetdefaults ();IF iu_critselect.uf_resetdefaults(is_modele) = 1 THEN
	ii_nbcrit = 0
	ii_nbcrittri = 0
	return(1)
ELSE
	return(-1)
END IF
	

end function

public subroutine wf_setinsertionpoint (string as_insertionpoint);is_insertionpoint = as_insertionpoint
end subroutine

public subroutine wf_cancel (boolean ab_cancel);// initialise la variable ib_cancelpermitted
ib_cancelpermitted = ab_cancel
end subroutine

public subroutine wf_setevalmsg (string as_msg);is_evalmsg = as_msg
end subroutine

public function integer wf_setdefault (string as_critere, string as_operateur);return(wf_setdefault("",as_critere,as_operateur,"","","and",FALSE,TRUE))
end function

public function integer wf_setdefault (string as_critere, string as_operateur, any aa_valeur);return(wf_setdefault("",as_critere,as_operateur,aa_valeur,"","and",FALSE,TRUE))
end function

public function integer wf_setdefault (string as_critere, string as_operateur, any aa_valeur, boolean ab_obligatoire);return(wf_setdefault("",as_critere,as_operateur,aa_valeur,"","and",ab_obligatoire,TRUE))
end function

public function integer wf_setdefault (string as_critere, string as_operateur, boolean ab_obligatoire);return(wf_setdefault("",as_critere,as_operateur,"","","and",ab_obligatoire,TRUE))
end function

public function integer wf_setdefault (string as_par1, string as_critere, string as_operateur, any aa_valeur, string as_par2, boolean ab_obligatoire);return(wf_setdefault(as_par1,as_critere,as_operateur,aa_valeur,as_par2,"and",ab_obligatoire,TRUE))
end function

public function integer wf_setdefault (string as_par1, string as_critere, string as_operateur, any aa_valeur, string as_par2, string as_connect, boolean ab_obligatoire);// insérer dans la table report_select le critère de sélection dont 
// les éléments sont passés en argument
// return(1) = OK, ii_nbcrit est incrémenté de 1
// return(-1) = le critère passé en argument n'est pas valide
// return(-2) = erreur insert du nouveau critère
integer	li_status
li_status = iu_critselect.uf_setdefault(is_reportcritere, is_modele, ii_nbcrit, as_par1, as_critere, &
									 				 as_operateur, aa_valeur, as_par2, as_connect, ab_obligatoire,TRUE)
IF li_status = 1 THEN
	ii_nbcrit++
	return(1)
ELSE
	return(li_status)
END IF

end function

public function integer wf_setdefault (string as_par1, string as_critere, string as_operateur, any aa_valeur, string as_par2, string as_connect, boolean ab_obligatoire, boolean ab_valeurmodifiable);// insérer dans la table report_select le critère de sélection dont 
// les éléments sont passés en argument
// return(1) = OK, ii_nbcrit est incrémenté de 1
// return(-1) = le critère passé en argument n'est pas valide
// return(-2) = erreur insert du nouveau critère
integer	li_status
li_status = iu_critselect.uf_setdefault(is_reportcritere, is_modele, ii_nbcrit, as_par1, as_critere, &
									 as_operateur, aa_valeur, as_par2, as_connect, ab_obligatoire, ab_valeurmodifiable)
IF li_status = 1 THEN
	ii_nbcrit++
	return(1)
ELSE
	return(li_status)
END IF

end function

public function integer wf_setdefault (string as_par1, string as_critere, string as_operateur, string as_par2, boolean ab_obligatoire);return(wf_setdefault(as_par1,as_critere,as_operateur,"",as_par2,"and",ab_obligatoire,TRUE))
end function

public function integer wf_setdefaulttri (string as_critere);// si on ne précise pas l'ordre de tri ni les paramètres de regroupements, 
// ascendant est utilisé par défaut et on ne prévoit pas de regroupement dynamique
return(wf_setdefaulttri(as_critere, "A", "N", "N"))
end function

public subroutine wf_buttonsenabled (boolean ab_buttons);// initialise la variable ib_buttons
ib_buttons = ab_buttons
end subroutine

public function integer wf_setdefaulttri (string as_critere, string as_order);// si on ne précise pas les paramètres de regroupements, on ne prévoit pas de regroupement dynamique
return(wf_setdefaulttri(as_critere, as_order, "N", "N"))
end function

public function integer wf_setdefaulttri (string as_critere, string as_ordre, string as_groupe, string as_newpage);// insérer dans la table report_selecttri le critère de tri 'as_critere' et l'ordre souhaité 'as_ordre'
// return(1) = OK, ii_nbcrittri est incrémenté de 1
// return(-1) = erreur dans les arguments
// return(-2) = erreur insert du nouveau critère de tri
integer	li_status
li_status = iu_critselect.uf_setdefaulttri(is_reportcritere, is_modele, ii_nbcrittri, &
														 as_critere, as_ordre, as_groupe, as_newpage)
IF li_status = 1 THEN
	ii_nbcrittri++
	return(1)
ELSE
	return(li_status)
END IF

end function

public function integer wf_setpredeftri (integer ai_id);// insérer dans la table report_selecttri le set de critères de tri choisi (ai_id)
// return(1) = OK, ii_nbcrittri est incrémenté du nombre de critères de la sélection
// return(-1) = erreur dans les arguments
// return(-2) = erreur insert du nouveau critère de tri

string	ls_critere, ls_ordre, ls_groupe, ls_newpage
integer	li_status

DECLARE tri CURSOR FOR
	SELECT critere, ordre, groupe, newpage FROM report_predeftri 
			WHERE report = :is_reportcritere AND id = :ai_id
			ORDER BY ordretri;
OPEN tri;
FETCH tri INTO :ls_critere, :ls_ordre, :ls_groupe, :ls_newpage;
DO WHILE f_check_sql(SQLCA) = 0
	IF ls_ordre = "O" THEN
		ls_ordre = "A"
	ELSE
		ls_ordre = "D"
	END IF
	li_status = iu_critselect.uf_setdefaulttri(is_reportcritere, is_modele, ii_nbcrittri, &
 															 ls_critere, ls_ordre, ls_groupe, ls_newpage)
	IF li_status = 1 THEN
		ii_nbcrittri++
	ELSE
		return(li_status)
	END IF
	FETCH tri INTO :ls_critere, :ls_ordre, :ls_groupe, :ls_newpage;
LOOP
CLOSE tri;

return(1)

end function

public subroutine wf_setnbgroups (integer ai_nbgroups);// permet de spécifier le nombre de groupes dynamiques (DW object doit être prévu pour !)
ii_nbgroups = ai_nbgroups
end subroutine

public function integer wf_getnbgroups ();// renvoie le nombre de groupes dynamiques spécifié par wf_Setnbgroups
return(ii_nbgroups)

end function

public function boolean wf_cancelpermitted ();// renvoie la valeur de la variable ib_cancelpermitted
return(ib_cancelpermitted)
end function

public function boolean wf_trienabled ();// renvoie la valeur de la variable ib_trienabled
return(ib_trienabled)
end function

public function boolean wf_buttonsenabled ();// renvoie la valeur de la variable ib_buttons
return(ib_buttons)
end function

public function boolean wf_showselection ();// renvoie la valeur de la variable ib_selection
return(ib_selection)
end function

public function boolean wf_sqlfromdw ();// renvoie la valeur de la variable ib_sqlfromdw
return(ib_sqlfromdw)
end function

public function string wf_getinsertionpoint ();return(is_insertionpoint)
end function

public function string wf_getevalmsg ();return(is_evalmsg)
end function

public function string wf_getselectionwindow ();// renvoie le nom de la fenêtre de sélection à utiliser
return(is_selectionwindow)
end function

public function string wf_getreportcritere ();// renvoie le nom du report duquel il faut utiliser les critères de sélection (pour utiliser 
// dans un report les mêmes critères de sélection que dans un autre)
return(is_reportcritere)
end function

public function string wf_getmodel ();return(is_modele)
end function

public function string wf_getoriginalselect ();return(is_originalselect)
end function

public subroutine wf_setdefaultmsg ();// exécuter le code initial...
super::wf_setdefaultmsg()

// ...puis le code complémentaire
wf_SetMessageNoConsult(f_translate_getlabel("TEXT_00121", "Désolé, vous n'avez pas le droit de consulter et/ou imprimer ce rapport"))
wf_SetMessageNoUpdate(f_translate_getlabel("TEXT_00122", "Vous n'avez pas le droit d'enregistrer ce rapport sous un autre format"))

end subroutine

public subroutine wf_appendorderby (boolean ab_selection);// FALSE (default)=Remplace le ORDER BY original, TRUE=compléter le ORDER BY originale
ib_appendOrderBy = ab_selection
end subroutine

public function boolean wf_appendorderby ();// // renvoie la valeur de la variable ib_appendOrderBy
return(ib_appendOrderBy)
end function

on w_ancestor_rpt.create
call super::create
end on

on w_ancestor_rpt.destroy
call super::destroy
end on

event ue_close;call super::ue_close;DESTROY iu_wait
DESTROY iu_critselect
end event

event ue_open;call super::ue_open;integer	li_i

// récupérer les paramètres directement dans une variable d'instance pour pouvoir les traiter + tard
im_message = Message

// instancier l'objet uo_wait et uo_selection
iu_wait = CREATE uo_wait
iu_critselect = CREATE uo_critselect

// par défaut, les critères de sélection sont définis pour le report en cours, mais on pourrait utiliser ceux d'un autre report
wf_setreportcritere(this.classname())

// par défaut, la fenêtre de sélection = W_SELECTION, mais on pourrait on spécifier une autre (un descendant de w_selection)
wf_SetSelectionWindow("w_selection")

// par défaut, les critères sont donnés par report dans la table report_critere
wf_setReportCritere(upper(this.classname()))

/* dans l'écran de sélection standard, les 20 premiers paramètres d'input sont réservés,
   mais la fonction wf_setmoreselectparams() permet d'en ajouter plus. Pour que ces paramètres supplémentaires
	viennent se placer APRES les autres, on réserve déjà les 20 premiers */
FOR li_i = 1 TO 20
	SetNull(istr_inputparams.a_param[li_i])
NEXT
end event

