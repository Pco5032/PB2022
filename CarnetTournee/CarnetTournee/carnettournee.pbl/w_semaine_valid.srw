//objectcomments Affichage/modification de la validation du planning ou du réalisée, semaine par semaine. Utilitaire, accès limité au correspondant du personnel.
forward
global type w_semaine_valid from w_ancestor_dataentry
end type
type dw_semaine from uo_datawindow_multiplerow within w_semaine_valid
end type
type dw_choix_agent from uo_datawindow_singlerow within w_semaine_valid
end type
type st_1 from uo_statictext within w_semaine_valid
end type
type ddlb_annee from uo_dropdownlistbox within w_semaine_valid
end type
type st_2 from uo_statictext within w_semaine_valid
end type
end forward

global type w_semaine_valid from w_ancestor_dataentry
string tag = "TEXT_00620"
integer width = 4000
integer height = 2244
string title = "Modification des validations"
boolean maxbox = true
boolean resizable = true
dw_semaine dw_semaine
dw_choix_agent dw_choix_agent
st_1 st_1
ddlb_annee ddlb_annee
st_2 st_2
end type
global w_semaine_valid w_semaine_valid

type variables
string	is_matricule
end variables

forward prototypes
public function integer wf_retrieve ()
public function integer wf_lecture ()
end prototypes

public function integer wf_retrieve ();DatawindowChild	ldwc_dropdown
long		ll_nbrows
string	ls_super

// Lire la liste des préposés du responsable auquel est ajouté l'utilisateur lui-même.
// Attention : si membre du groupe de superusers "FULL", accès à tous les agents paramétrés dans le système !
IF gu_privs.uf_super("FULL") THEN
	ls_super = "O"
ELSE
	ls_super = "N"
END IF
dw_choix_agent.GetChild("s_matricule", ldwc_dropdown)
ldwc_dropdown.settransobject(SQLCA)
ll_nbrows = ldwc_dropdown.retrieve(gs_username, ls_super)
IF ll_nbrows < 0 THEN
	dw_choix_agent.insertrow(0)
	populateError(20000, "Erreur lecture liste des semaines validées")
	GOTO ERREUR
ELSEIF ll_nbrows = 0 THEN
	gu_message.uf_info("Il n'existe aucune semaine validée pour vos agents.")
END IF

return(1)

ERREUR:
gu_message.uf_unexp("")
return(-1)
end function

public function integer wf_lecture ();string	ls_super, ls_annee
long		ll_nbrows, ll_row

IF f_isEmptyString(is_matricule) THEN
	return(-1)
END IF

// Attention : si membre du groupe de superusers "FULL", accès à tous les agents paramétrés dans le système !
IF gu_privs.uf_super("FULL") THEN
	ls_super = "O"
ELSE
	ls_super = "N"
END IF

ll_nbrows = dw_semaine.retrieve(is_matricule, ls_super)
IF ll_nbrows <= 0 THEN
	return(ll_nbrows)
END IF

wf_actif(true)
dw_choix_agent.uf_disableitems({"s_matricule"})

// garnir la ddlb permettant le filtrage sur l'année
dw_semaine.setredraw(false)

// NB : dw_semaiine doit être trié sur l'année pour que ça fonctionne !
// filtrer pour n'afficher qu'une row par année
dw_semaine.SetFilter("IsNull(semaine_valid_annee[-1]) OR semaine_valid_annee[-1] <> semaine_valid_annee")
dw_semaine.filter()

// parcourir les rows filtrées et ajouter année dans DDLB
FOR ll_row = 1 TO dw_semaine.rowCount()
	ls_annee = string(dw_semaine.object.semaine_valid_annee[ll_row])
	ddlb_annee.AddItem(ls_annee)
NEXT

// restaurer filtre et tri d'origine
dw_semaine.SetFilter("")
dw_semaine.filter()
dw_semaine.sort()
dw_semaine.setredraw(true)

// pas de choix d'année : pas de filtre
ddlb_annee.AddItem(" ")

return(ll_nbrows)

end function

event resize;call super::resize;dw_semaine.width = newwidth
dw_semaine.height = newheight - dw_semaine.y - 100
end event

on w_semaine_valid.create
int iCurrent
call super::create
this.dw_semaine=create dw_semaine
this.dw_choix_agent=create dw_choix_agent
this.st_1=create st_1
this.ddlb_annee=create ddlb_annee
this.st_2=create st_2
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_semaine
this.Control[iCurrent+2]=this.dw_choix_agent
this.Control[iCurrent+3]=this.st_1
this.Control[iCurrent+4]=this.ddlb_annee
this.Control[iCurrent+5]=this.st_2
end on

on w_semaine_valid.destroy
call super::destroy
destroy(this.dw_semaine)
destroy(this.dw_choix_agent)
destroy(this.st_1)
destroy(this.ddlb_annee)
destroy(this.st_2)
end on

event ue_init_menu;call super::ue_init_menu;f_menuaction({"m_enregistrer", "m_abandonner", "m_fermer"})
end event

event ue_init_win;call super::ue_init_win;// réinitialiser les semaines affichées
dw_semaine.uf_reset()
dw_semaine.SetFilter("")
dw_semaine.filter()
dw_semaine.sort()

// réinitialiser la liste des années affichées
ddlb_annee.reset()

// réinitiliser le préposé
setnull(is_matricule)
dw_choix_agent.uf_reset()
dw_choix_agent.insertrow(0)
dw_choix_agent.uf_enableitems({"s_matricule"})


end event

event ue_open;call super::ue_open;wf_SetDWList({dw_semaine})

dw_semaine.uf_sort(TRUE)

// lecture du contenu du DDDW
wf_retrieve()
end event

event ue_enregistrer;call super::ue_enregistrer;integer	li_status

// contrôle de validité de tous les champs
IF dw_semaine.event ue_checkall() < 0 THEN
	dw_semaine.SetFocus()
	return(-1)
END IF

li_status = gu_dwservices.uf_updatetransact(dw_semaine)
CHOOSE CASE li_status
	CASE 1
		wf_message("Validations enregistrées avec succès")
		this.event ue_abandonner()
		return(1)
	CASE -1
		populateerror(20000,"")
		gu_message.uf_unexp("SEMAINE_VALID : Erreur lors de la mise à jour de la base de données")
		return(-1)
END CHOOSE

end event

type ddlb_message from w_ancestor_dataentry`ddlb_message within w_semaine_valid
integer x = 110
integer y = 1904
end type

type dw_semaine from uo_datawindow_multiplerow within w_semaine_valid
integer y = 128
integer width = 3950
integer height = 1520
integer taborder = 10
boolean bringtotop = true
string dataobject = "d_semaine_valid"
boolean hscrollbar = true
boolean vscrollbar = true
end type

event clicked;call super::clicked;string	ls_name, ls_type

// Tri sur année, semaine, planning validé et réalisé validé est bloqué.
// Si clique sur matricule, nom ou service, trier aussi d'office sur année ET semaine croissants
IF this.uf_sort() THEN
	IF dwo.Type = "text" THEN
		ls_name = dwo.Name
		ls_name = LeftA(ls_name, LenA(ls_Name) - 9)
		ls_type = this.Describe(trim(ls_name) + ".type")
		IF ls_type = "column" OR ls_type = "compute" THEN
			IF gb_sort_asc THEN
				gu_dwservices.uf_sort(this, ls_name + " A, semaine_valid_annee A, semaine_valid_semaine A")
				IF NOT this.uf_autoselectrow() THEN this.selectrow(row, FALSE)
			ELSE
				gu_dwservices.uf_sort(this, ls_name + " D, semaine_valid_annee A, semaine_valid_semaine A")
				IF NOT this.uf_autoselectrow() THEN this.selectrow(row, FALSE)
			END IF
		END IF
	END IF
END IF

end event

type dw_choix_agent from uo_datawindow_singlerow within w_semaine_valid
integer x = 201
integer y = 16
integer width = 1042
integer height = 80
integer taborder = 10
boolean bringtotop = true
string dataobject = "d_choix_agent_valid"
end type

event ue_itemvalidated;call super::ue_itemvalidated;DatawindowChild	ldwc_dropdown
integer	li_row

// conserver matricule de l'agent sélectionné dans variable d'instance
is_matricule = as_data

wf_lecture()
end event

type st_1 from uo_statictext within w_semaine_valid
integer x = 18
integer y = 16
integer width = 183
boolean bringtotop = true
string text = "Agent"
end type

type ddlb_annee from uo_dropdownlistbox within w_semaine_valid
integer x = 2341
integer y = 16
integer width = 256
integer height = 512
integer taborder = 20
boolean bringtotop = true
integer textsize = -9
long backcolor = 16777215
boolean vscrollbar = true
end type

event selectionchanged;call super::selectionchanged;IF LenA(trim(this.Text)) = 0 THEN
	dw_semaine.SetFilter("")
ELSE
	dw_semaine.SetFilter("semaine_valid_annee = " + this.Text)
END IF
dw_semaine.Filter()
dw_semaine.sort()
end event

type st_2 from uo_statictext within w_semaine_valid
integer x = 1920
integer y = 32
boolean bringtotop = true
string text = "Tri sur l~'année"
alignment alignment = right!
end type

