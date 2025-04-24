//objectcomments Gestion des super groupes
forward
global type w_supergroupe from w_ancestor_dataentry
end type
type dw_group from uo_datawindow_singlerow within w_supergroupe
end type
type dw_privs from uo_datawindow_multiplerow within w_supergroupe
end type
type cb_membres from uo_cb within w_supergroupe
end type
type cb_copy from uo_cb within w_supergroupe
end type
end forward

global type w_supergroupe from w_ancestor_dataentry
integer width = 1755
integer height = 2164
string title = "Gérer les super privilèges des groupes d~'utilisateurs"
boolean maxbox = true
boolean resizable = true
dw_group dw_group
dw_privs dw_privs
cb_membres cb_membres
cb_copy cb_copy
end type
global w_supergroupe w_supergroupe

type variables
integer	ii_groupe

end variables

forward prototypes
public function long wf_addprivs ()
public subroutine wf_initprivs (long al_row)
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
dw_privs.object.id[al_row] = ii_groupe
dw_privs.setItemStatus(al_row, 0, PRIMARY!, notmodified!)
end subroutine

on w_supergroupe.create
int iCurrent
call super::create
this.dw_group=create dw_group
this.dw_privs=create dw_privs
this.cb_membres=create cb_membres
this.cb_copy=create cb_copy
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_group
this.Control[iCurrent+2]=this.dw_privs
this.Control[iCurrent+3]=this.cb_membres
this.Control[iCurrent+4]=this.cb_copy
end on

on w_supergroupe.destroy
call super::destroy
destroy(this.dw_group)
destroy(this.dw_privs)
destroy(this.cb_membres)
destroy(this.cb_copy)
end on

event ue_init_menu;call super::ue_init_menu;dwItemStatus	l_RowStatus

l_RowStatus = dw_group.GetItemStatus(1, 0, PRIMARY!)

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

cb_membres.enabled = FALSE
cb_copy.enabled = FALSE
dw_privs.uf_reset()
dw_group.uf_reset()
dw_group.insertrow(0)

dw_privs.uf_disabledata()
dw_group.uf_disabledata()
dw_group.uf_enablekeys()
dw_group.setfocus()

this.setredraw(TRUE)
end event

event ue_enregistrer;call super::ue_enregistrer;integer	li_status
long		ll_nbrows, ll_row

// contrôle de validité de tous les champs
IF dw_group.event ue_checkall() < 0 THEN
	dw_group.SetFocus()
	return(-1)
END IF
IF dw_privs.event ue_checkall() < 0 THEN
	dw_privs.SetFocus()
	return(-1)
END IF

// supprimer les lignes vides de dw_privs
ll_nbrows = dw_privs.RowCount()
FOR ll_row = 1 TO ll_nbrows
	IF f_IsEmptyString(dw_privs.object.categorie[ll_row]) THEN
		dw_privs.RowsDiscard(ll_row, ll_row, Primary!)
		ll_nbrows = ll_nbrows - 1
		ll_row = ll_row - 1
	END IF
NEXT

li_status = gu_dwservices.uf_updatetransact(dw_group, dw_privs)
CHOOSE CASE li_status
	CASE 1
		// réactualiser liste des privilèges du user en cours
		gu_privs.uf_initprivs()
		wf_message("Groupe " + string(ii_groupe) + " enregistré avec succès")
		This.event ue_init_win()
		return(1)
	CASE -1
		populateerror(20000,"")
		gu_message.uf_unexp("DNFGROUPS : Erreur lors de la mise à jour de la base de données")
		return(-1)
	CASE -2
		populateerror(20000,"")
		gu_message.uf_unexp("DNFSUPERPRIVS : Erreur lors de la mise à jour de la base de données")
		return(-1)		
END CHOOSE

end event

event ue_supprimer;call super::ue_supprimer;integer	li_stat
long		ll_row, ll_nbrows

// supprimer tout le groupe ou uniquement les droits d'accès de la catégorie sélectionnée en fontion du DW actif
IF wf_GetActivecontrolname() = "dw_privs" THEN
	li_stat = dw_privs.event ue_delete()
	IF li_stat = 2 THEN
		wf_initprivs(1)
	END IF
ELSE
	// interdit de supprimer le groupe 1 (public)
	IF dw_group.object.groupid[1] = 1 THEN
		gu_message.uf_info("Il est interdit de supprimer le groupe 1 (Public)")
		return
	END IF
	IF f_confirm_del("Voulez-vous supprimer ce groupe ?") = 1 THEN
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
		IF dw_group.event ue_delete() = 1 THEN
			wf_message("Groupe supprimé avec succès")
			this.event ue_init_win()
		ELSE
			populateerror(20000,"Erreur delete dw_group")
			GOTO ERREUR
		END IF
	END IF
END IF
return
	
ERREUR:
rollback;
gu_message.uf_unexp("Erreur lors de la suppression du groupe")
wf_Actif(FALSE)
post close(THIS)
return
end event

event ue_ajouter;call super::ue_ajouter;wf_addprivs()
end event

event ue_open;call super::ue_open;string	ls_groupe

// ne pas logger de message lors de l'utilisation de cette fenêtre
wf_logusage(FALSE)

wf_SetItemsToShow({"m_ajouter"})
wf_SetDWList({dw_group, dw_privs})
dw_privs.uf_autoselectrow(FALSE)
dw_privs.uf_createwhenlastdeleted(FALSE)

// création du groupe 1 - Public
select description into :ls_groupe from dnfgroups where groupid = 1 using ESQLCA;
IF f_check_sql(ESQLCA) = 100 THEN
	insert into dnfgroups values (1, 'Public') using ESQLCA;
	IF f_check_sql(ESQLCA) = 0 THEN
		commit using ESQLCA;
	ELSE
		rollback using ESQLCA;
		populateerror(20000, "")
		gu_message.uf_unexp("Impossible de créer le groupe '1 - Public'")
		wf_executepostopen(FALSE)
		post close(this)
		return
	END IF
END IF
end event

event resize;call super::resize;dw_privs.height = newheight - 332
end event

type ddlb_message from w_ancestor_dataentry`ddlb_message within w_supergroupe
integer y = 1952
integer width = 1737
end type

type dw_group from uo_datawindow_singlerow within w_supergroupe
integer x = 18
integer y = 16
integer width = 1701
integer height = 96
integer taborder = 10
boolean bringtotop = true
string dataobject = "d_dnfgroups"
boolean livescroll = false
end type

event ue_leavekey;call super::ue_leavekey;// quand on quitte la clé, cela veut dire qu'on dispose de données actives dans la fenêtre
wf_actif(true)

// effacer les messages
ddlb_message.reset()

// lecture du groupe s'il existe déjà
IF NOT this.uf_IsRecordNew() THEN
	this.retrieve(ii_groupe)
	wf_message("Modification d'un groupe...")
ELSE
// nouveau groupe : on dispose déjà d'un record vide (celui où on a introduit la clé)
	wf_message("Nouveau groupe...")
END IF

// disabler la clé et enabler les datas
cb_membres.enabled = TRUE
cb_copy.enabled = TRUE
this.uf_enabledata()
this.uf_disablekeys()

// groupe 1 = Public
IF ii_groupe = 1 THEN
	this.object.description[1] = "Public"
	dw_group.uf_disableitems({"description"})
END IF

// lire les privilèges du groupe
dw_privs.retrieve(ii_groupe)
dw_privs.uf_enabledata()

parent.event ue_init_menu()


end event

event ue_checkitem;call super::ue_checkitem;integer	li_status
long		ll_count

ii_groupe = this.object.groupid[1]

CHOOSE CASE as_item
	CASE "description"
		IF f_IsEmptyString(as_data) THEN
			as_message = "Une description doit être fournie"
			return(-1)
		END IF
		
	// dernier élément de la clé, vérifier si record existe ou pas
	CASE "groupid"
		ii_groupe = integer(as_data)
		IF IsNull(ii_groupe) OR ii_groupe < 1 OR ii_groupe > 999 THEN
			as_message = "Le n° de groupe doit être compris entre 1 et 999"
			return(-1)
		END IF
		select count(*) into :ll_count from dnfgroups
			where groupid=:ii_groupe using ESQLCA;
		li_status = f_check_sql(ESQLCA)
		IF li_status < 0 THEN
			populateerror(20000,"")
			gu_message.uf_unexp("Erreur SELECT DNFGROUPS")
			return(-1)
		ELSE
			// groupe inexistant
			IF ll_count = 0 THEN
				this.uf_NewRecord(TRUE)
			ELSE
			// groupe existe déjà
				this.uf_NewRecord(FALSE)
			END IF
		END IF
END CHOOSE
return(1)

end event

event ue_help;call super::ue_help;str_params lstr_params

CHOOSE CASE idwo_currentItem.name
	CASE "groupid"
		IF wf_IsActif() THEN return
		openwithparm(w_l_groups,lstr_params)
		IF Message.DoubleParm = -1 THEN return
		lstr_params=Message.PowerObjectParm
		this.SetText(string (lstr_params.a_param[1]))
		f_presskey("tab")
END CHOOSE

end event

event getfocus;call super::getfocus;parent.event ue_init_menu()
end event

event ue_postitemvalidated;call super::ue_postitemvalidated;IF as_name = "groupid" THEN
	This.setItemStatus(1, 0, PRIMARY!, notmodified!)
END IF

end event

type dw_privs from uo_datawindow_multiplerow within w_supergroupe
integer x = 329
integer y = 208
integer width = 987
integer height = 1728
integer taborder = 11
boolean bringtotop = true
string dataobject = "d_dnfsuperprivs"
boolean vscrollbar = true
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

type cb_membres from uo_cb within w_supergroupe
integer x = 183
integer y = 112
integer width = 658
integer height = 80
integer taborder = 20
boolean bringtotop = true
string text = "Afficher les membres..."
end type

event clicked;call super::clicked;openWithParm(w_l_membres, ii_groupe)
end event

event getfocus;call super::getfocus;parent.event ue_init_menu()
end event

type cb_copy from uo_cb within w_supergroupe
integer x = 841
integer y = 112
integer width = 622
integer height = 80
integer taborder = 20
boolean bringtotop = true
string text = "Copier ce groupe..."
end type

event clicked;call super::clicked;integer	li_id
long		ll_row

openwithparm(w_copyuser, 1)
li_id = message.doubleparm
IF li_id = -1 THEN
	return
END IF

dw_group.uf_NewRecord(TRUE)
wf_message("Nouveau groupe...")
dw_group.SetItemStatus(1, 0, Primary!, NewModified!)

ii_groupe = li_id
dw_group.object.groupid[1] = ii_groupe
dw_group.object.description[1] = "Copie de " + dw_group.object.description[1]
dw_group.uf_enableitems({"description"})

FOR ll_row = 1 TO dw_privs.RowCount()
	dw_privs.object.id[ll_row] = ii_groupe
	dw_privs.SetItemStatus(ll_row, 0, Primary!, NewModified!)
NEXT

end event

