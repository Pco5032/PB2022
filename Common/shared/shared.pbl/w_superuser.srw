//objectcomments Gestion des super utilisateurs
forward
global type w_superuser from w_ancestor_dataentry
end type
type dw_user from uo_datawindow_singlerow within w_superuser
end type
type dw_privs from uo_datawindow_multiplerow within w_superuser
end type
type st_2 from uo_statictext within w_superuser
end type
type dw_groups from uo_ancestor_dwbrowse within w_superuser
end type
type pb_copy from uo_pictbutton within w_superuser
end type
type gb_1 from uo_groupbox within w_superuser
end type
end forward

global type w_superuser from w_ancestor_dataentry
integer width = 1755
integer height = 2804
string title = "Gérer les super privilèges des utilisateurs"
boolean maxbox = true
boolean resizable = true
dw_user dw_user
dw_privs dw_privs
st_2 st_2
dw_groups dw_groups
pb_copy pb_copy
gb_1 gb_1
end type
global w_superuser w_superuser

type variables
integer	ii_user
string	is_groups[]


end variables

forward prototypes
public function long wf_addprivs ()
public subroutine wf_initprivs (long al_row)
public subroutine wf_nom_agent (string as_logname)
end prototypes

public function long wf_addprivs ();long	ll_row

// ajouter une ligne dans dw_privs
IF wf_IsActif() THEN
	dw_privs.SetFocus()
	ll_row = dw_privs.event ue_addrow()
	IF ll_row <= 0 THEN return(-1)
	wf_initprivs(ll_row)
END IF
return(ll_row)
end function

public subroutine wf_initprivs (long al_row);// initialiser nouvelle occurence de dw_privs
dw_privs.object.id[al_row] = ii_user
dw_privs.setItemStatus(al_row, 0, PRIMARY!, notmodified!)
end subroutine

public subroutine wf_nom_agent (string as_logname);// tentative de lecture du nom, si le logname est le code ULYS
string	ls_nom

select nom into :ls_nom from agent where matricule = :as_logname using ESQLCA;
IF ESQLCA.sqlnrows = 1 THEN
	dw_user.object.c_nom_agent[1] = ls_nom
ELSE
	dw_user.object.c_nom_agent[1] = gu_c.s_null
END IF

end subroutine

on w_superuser.create
int iCurrent
call super::create
this.dw_user=create dw_user
this.dw_privs=create dw_privs
this.st_2=create st_2
this.dw_groups=create dw_groups
this.pb_copy=create pb_copy
this.gb_1=create gb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_user
this.Control[iCurrent+2]=this.dw_privs
this.Control[iCurrent+3]=this.st_2
this.Control[iCurrent+4]=this.dw_groups
this.Control[iCurrent+5]=this.pb_copy
this.Control[iCurrent+6]=this.gb_1
end on

on w_superuser.destroy
call super::destroy
destroy(this.dw_user)
destroy(this.dw_privs)
destroy(this.st_2)
destroy(this.dw_groups)
destroy(this.pb_copy)
destroy(this.gb_1)
end on

event ue_init_menu;call super::ue_init_menu;dwItemStatus	l_RowStatus

l_RowStatus = dw_user.GetItemStatus(1, 0, PRIMARY!)

// menu réduit si la fenêtre ne contient pas de données actives
IF NOT wf_isactif() THEN
	f_menuaction({"m_fermer"})
	return
END IF

// options accessibles du menu actions varient en fonction de la position du curseur et du status du record
IF wf_GetActivecontrolname() = "dw_privs" THEN
	f_menuaction({"m_enregistrer", "m_ajouter", "m_supprimer", "m_abandonner", "m_fermer"})
	return
END IF

IF l_RowStatus = New! or l_RowStatus = NewModified! THEN
	f_menuaction({"m_enregistrer", "m_ajouter", "m_abandonner", "m_fermer"})
ELSE
	f_menuaction({"m_enregistrer", "m_ajouter", "m_supprimer", "m_abandonner", "m_fermer"})
END IF



end event

event ue_init_win;call super::ue_init_win;this.setredraw(FALSE)

pb_copy.enabled = FALSE
dw_groups.enabled = FALSE
dw_groups.uf_reset()
dw_privs.uf_reset()
dw_user.uf_reset()
dw_user.insertrow(0)

dw_privs.uf_disabledata()
dw_user.uf_disabledata()
dw_user.uf_enablekeys()
dw_user.setfocus()

this.setredraw(TRUE)
end event

event ue_enregistrer;call super::ue_enregistrer;integer	li_status, li_id
long		ll_row, ll_nbrows
string	ls_groups, ls_domain, ls_logname

// contrôle de validité de tous les champs
IF dw_user.event ue_checkall() < 0 THEN
	dw_user.SetFocus()
	return(-1)
END IF
// + contrôler que le même domain//logname n'existe pas déjà sous un autre n°
ls_domain = dw_user.object.domain[1]
ls_logname = dw_user.object.logname[1]
select userid into :li_id from dnfusers where domain=:ls_domain and logname=:ls_logname
	using ESQLCA;
IF f_check_sql(ESQLCA) <> 100 AND li_id <> ii_user THEN
	gu_message.uf_error("Cet utilisateur existe déjà sous le n° " + string(li_id))
	dw_user.SetFocus()
	return(-1)
END IF

IF dw_privs.event ue_checkall() < 0 THEN
	dw_privs.SetFocus()
	return(-1)
END IF

// construire une string avec les groupes sélectionnés
ls_groups = ""
ll_row = dw_groups.GetSelectedRow(0)
DO WHILE ll_row > 0
	ls_groups = ls_groups + string(dw_groups.object.groupid[ll_row]) + ","
	ll_row = dw_groups.GetSelectedRow(ll_row)
LOOP
IF NOT f_IsEmptyString(ls_groups) THEN
	ls_groups = LeftA(ls_groups, LenA(ls_groups) - 1)
END IF
dw_user.object.groups[1] = ls_groups

// supprimer les lignes vides de dw_privs
ll_nbrows = dw_privs.RowCount()
FOR ll_row = 1 TO ll_nbrows
	IF f_IsEmptyString(dw_privs.object.categorie[ll_row]) THEN
		dw_privs.RowsDiscard(ll_row, ll_row, Primary!)
		ll_nbrows = ll_nbrows - 1
		ll_row = ll_row - 1
	END IF
NEXT

// il faut au moins une catégorie ou un groupe sinon le user ne sert à rien
IF dw_privs.RowCount() = 0 AND f_IsEmptyString(ls_groups) THEN
	gu_message.uf_error("Un utilisateur doit au moins appartenir à un group OU spécifier les droits d'accès à 1 catégorie")
	return(-1)
END IF

li_status = gu_dwservices.uf_updatetransact(dw_user, dw_privs)
CHOOSE CASE li_status
	CASE 1
		wf_message("Utilisateur " + string(ii_user) + " enregistré avec succès")
		// si on a modifié les droits de l'utilisateur en cours, réactualiser liste
		IF ls_domain = gs_domain AND ls_logname = gs_username THEN
			gu_privs.uf_initprivs()
		END IF
		This.event ue_init_win()
		return(1)
	CASE -1
		populateerror(20000,"")
		gu_message.uf_unexp("DNFUSERS : Erreur lors de la mise à jour de la base de données")
		return(-1)
	CASE -2
		populateerror(20000,"")
		gu_message.uf_unexp("DNFSUPERPRIVS : Erreur lors de la mise à jour de la base de données")
		return(-1)		
END CHOOSE

end event

event ue_supprimer;call super::ue_supprimer;integer	li_stat
long		ll_row, ll_nbrows

// supprimer tout le user ou uniquement les droits d'accès de la catégorie sélectionnée en fontion du DW actif
IF wf_GetActivecontrolname() = "dw_privs" THEN
	li_stat = dw_privs.event ue_delete()
	IF li_stat = 2 THEN
		wf_initprivs(1)
	END IF
ELSE
	IF f_confirm_del("Voulez-vous supprimer cet utilisateur ?") = 1 THEN
		ll_nbrows = dw_privs.RowCount()
		FOR ll_row = 1 TO ll_nbrows
			IF dw_privs.deleterow(1) = -1 THEN
				populateerror(20000,"Erreur suppression dw_privs")
				GOTO ERREUR
			END IF
		NEXT
		IF dw_privs.update() = -1 THEN
			populateerror(20000,"Erreur update dw_privs")
			GOTO ERREUR			
		END IF
		IF dw_user.event ue_delete() = 1 THEN
			wf_message("Utilisateur supprimé avec succès")
			this.event ue_init_win()
		ELSE
			populateerror(20000,"Erreur delete dw_user")
			GOTO ERREUR
		END IF
	END IF
END IF
return
	
ERREUR:
rollback;
gu_message.uf_unexp("Erreur lors de la suppression de l'utilisateur")
wf_Actif(FALSE)
post close(THIS)
return	
end event

event ue_ajouter;call super::ue_ajouter;wf_addprivs()
end event

event ue_open;call super::ue_open;// ne pas logger de message lors de l'utilisation de cette fenêtre
wf_logusage(FALSE)

dw_groups.object.datawindow.header.height = 0
dw_groups.uf_extendedselect(TRUE)

wf_SetItemsToShow({"m_ajouter"})
wf_SetDWList({dw_user, dw_privs})
dw_privs.uf_autoselectrow(FALSE)
dw_privs.uf_createwhenlastdeleted(FALSE)

end event

event resize;call super::resize;dw_groups.height = (newheight - 300) * 40 /100
gb_1.height = dw_groups.height + 72
dw_privs.y = gb_1.y + gb_1.height + 16
dw_privs.height = newheight - dw_privs.y - 112
end event

type ddlb_message from w_ancestor_dataentry`ddlb_message within w_superuser
integer y = 2272
integer width = 1664
end type

type dw_user from uo_datawindow_singlerow within w_superuser
integer y = 16
integer width = 1701
integer height = 240
integer taborder = 10
boolean bringtotop = true
string dataobject = "d_dnfusers"
boolean livescroll = false
end type

event ue_leavekey;call super::ue_leavekey;integer	li_i
long		ll_row, ll_upper
string	ls_groups[]

// quand on quitte la clé, cela veut dire qu'on dispose de données actives dans la fenêtre
wf_actif(true)

// effacer les messages
ddlb_message.reset()

// lecture du user s'il existe déjà
IF NOT this.uf_IsRecordNew() THEN
	this.retrieve(ii_user)
	// tentative de lecture du nom, si le logname est le code ULYS
	wf_nom_agent(string(this.object.logname[1]))
	wf_message("Modification d'un utilisateur...")
ELSE
// nouveau user : on dispose déjà d'un record vide (celui où on a introduit la clé)
	wf_message("Nouvel utilisateur...")
END IF

pb_copy.enabled = TRUE

// disabler la clé et enabler les datas
this.uf_enabledata()
this.uf_disablekeys()

// lire les privilèges propres au user
dw_privs.retrieve(ii_user)
dw_privs.uf_enabledata()

// lire les groupes
dw_groups.retrieve()
dw_groups.enabled = TRUE

// resélectionner les groupes auxquels le user appartient déjà
is_groups = ls_groups
f_parse(dw_user.object.groups[1], ",", is_groups)
ll_upper = upperbound(is_groups)
FOR li_i = 1 TO ll_upper
	ll_row = dw_groups.Find("groupid=" + is_groups[li_i], 1, dw_groups.RowCount())
	IF ll_row > 0 THEN
		dw_groups.selectrow(ll_row, TRUE)
	END IF
NEXT

// nouveau user : sélectionner d'office groupe 1
IF this.uf_IsRecordNew() THEN
	ll_row = dw_groups.Find("groupid=1", 1, dw_groups.RowCount())
	IF ll_row > 0 THEN
		dw_groups.selectrow(ll_row, TRUE)
	END IF
END IF

parent.event ue_init_menu()

end event

event ue_checkitem;call super::ue_checkitem;integer	li_status
long		ll_count

ii_user = this.object.userid[1]

CHOOSE CASE as_item
	CASE "domain"
		IF f_IsEmptyString(as_data) THEN
			as_message = "Un nom de domaine doit être fourni"
			return(-1)
		END IF
	CASE "logname"
		IF f_IsEmptyString(as_data) THEN
			as_message = "Un logname doit être fourni"
			return(-1)
		END IF
		
	// dernier élément de la clé, vérifier si record existe ou pas
	CASE "userid"
		ii_user = integer(as_data)
		IF IsNull(ii_user) OR ii_user < 1001 OR ii_user > 9999 THEN
			as_message = "Le n° d'utilisateur doit être compris entre 1001 et 9999"
			return(-1)
		END IF
		select count(*) into :ll_count from dnfusers
			where userid=:ii_user using ESQLCA;
		li_status = f_check_sql(ESQLCA)
		IF li_status < 0 THEN
			populateerror(20000,"")
			gu_message.uf_unexp("Erreur SELECT DNFUSERS")
			return(-1)
		ELSE
			// user inexistant
			IF ll_count = 0 THEN
				this.uf_NewRecord(TRUE)
			ELSE
			// user existe déjà
				this.uf_NewRecord(FALSE)
			END IF
		END IF
END CHOOSE
return(1)

end event

event ue_help;call super::ue_help;str_params lstr_params

CHOOSE CASE idwo_currentItem.name
	CASE "userid"
		IF wf_IsActif() THEN return
		openwithparm(w_l_users,lstr_params)
		IF Message.DoubleParm = -1 THEN return
		lstr_params=Message.PowerObjectParm
		this.SetText(string (lstr_params.a_param[1]))
		f_presskey("tab")
END CHOOSE

end event

event getfocus;call super::getfocus;parent.event ue_init_menu()
end event

event ue_postitemvalidated;call super::ue_postitemvalidated;IF as_name = "userid" THEN
	This.setItemStatus(1, 0, PRIMARY!, notmodified!)
END IF
end event

event ue_itemvalidated;call super::ue_itemvalidated;string	ls_nom
long		ll_ulys

CHOOSE CASE as_name
	CASE "logname"
		// tentative de lecture du nom, si le logname est le code ULYS
		wf_nom_agent(as_data)
END CHOOSE
end event

type dw_privs from uo_datawindow_multiplerow within w_superuser
integer x = 347
integer y = 672
integer width = 969
integer height = 1584
integer taborder = 30
boolean bringtotop = true
string dataobject = "d_dnfsuperprivs"
boolean vscrollbar = true
borderstyle borderstyle = stylebox!
end type

event getfocus;call super::getfocus;parent.event ue_init_menu()
end event

event ue_checkitem;call super::ue_checkitem;long	ll_row

CHOOSE CASE as_item
	// la catégorie est obligatoire, et ne peut être citée qu'une seule fois
	CASE "categorie"
		IF f_IsEmptyString(as_data) THEN
			as_message = "Catégorie obligatoire"
			return(-1)
		END IF
		ll_row = This.Find("categorie = '" + as_data + "'", 1, This.RowCount())
		IF ll_row > 0 AND ll_row <> al_row THEN
			as_message = "Cette catégorie est déjà citée dans la liste des privilèges"
			return(-1)
		ELSE
			return(1)
		END IF
END CHOOSE
return(1)
end event

type st_2 from uo_statictext within w_superuser
integer x = 18
integer y = 304
integer width = 567
integer height = 320
boolean bringtotop = true
integer textsize = -9
string text = "Sélectionnez le(s) groupe(s) auxquel(s) cet utilisateur appartient    (ALT/SHIFT + click)"
alignment alignment = center!
end type

event getfocus;call super::getfocus;parent.event ue_init_menu()
end event

type dw_groups from uo_ancestor_dwbrowse within w_superuser
integer x = 603
integer y = 304
integer width = 1079
integer height = 336
integer taborder = 11
boolean bringtotop = true
string dataobject = "d_l_groups"
boolean vscrollbar = true
borderstyle borderstyle = stylebox!
end type

event clicked;call super::clicked;long	ll_row

// groupe 1 ne peut pas être désélectionné : on le resélectionne d'office
ll_row = dw_groups.Find("groupid=1", 1, dw_groups.RowCount())
IF ll_row > 0 THEN
	dw_groups.selectrow(ll_row, TRUE)
END IF

end event

type pb_copy from uo_pictbutton within w_superuser
integer x = 1481
integer y = 16
integer width = 219
integer height = 160
integer taborder = 21
boolean bringtotop = true
integer textsize = -8
string text = "Copier user..."
end type

event clicked;call super::clicked;integer	li_id
long		ll_row

openwithparm(w_copyuser, 2)
li_id = message.doubleparm
IF li_id = -1 THEN
	return
END IF

dw_user.uf_NewRecord(TRUE)
wf_message("Nouvel utilisateur...")
dw_user.SetItemStatus(1, 0, Primary!, NewModified!)

ii_user = li_id
dw_user.object.userid[1] = ii_user
dw_user.object.logname[1] = dw_user.object.logname[1]

FOR ll_row = 1 TO dw_privs.RowCount()
	dw_privs.object.id[ll_row] = ii_user
	dw_privs.SetItemStatus(ll_row, 0, Primary!, NewModified!)
NEXT

end event

type gb_1 from uo_groupbox within w_superuser
integer y = 256
integer width = 1701
integer height = 400
integer taborder = 21
end type

