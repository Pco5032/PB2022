//objectcomments Par agent : droit à l'allocation pour travaux lourds et dangereux.
forward
global type w_agent_alloc from w_ancestor_dataentry
end type
type dw_prepose from uo_datawindow_multiplerow within w_agent_alloc
end type
end forward

global type w_agent_alloc from w_ancestor_dataentry
string tag = "TEXT_00780"
integer width = 2441
integer height = 2888
string title = "Droit à l~'allocation pour travaux lourds et dangereux"
boolean maxbox = true
boolean resizable = true
dw_prepose dw_prepose
end type
global w_agent_alloc w_agent_alloc

type variables
uo_ds	ids_agent_alloc
end variables

forward prototypes
public function integer wf_init ()
end prototypes

public function integer wf_init ();// initialiser DW et DS
string	ls_super
long		ll_row, ll_found, ll_new, ll_st

// Lire la liste des préposés du responsable.
// Attention : si membre du groupe de superusers "FULL", accès à tous les agents paramétrés dans le système !
IF gu_privs.uf_super("FULL") THEN
	ls_super = "O"
ELSE
	ls_super = "N"
END IF

// Ne pas tenir compte des droits de consulter/modifier le planning ni le réalisé : arguments 3 à 6 ="N"
ll_st = dw_prepose.retrieve(gs_username, ls_super, "N", "N", "N", "N")
CHOOSE CASE ll_st
	CASE 0
		gu_message.uf_info("Aucun agent configuré - Etes-vous Correspondant du Personnel ou Chef de Cantonnement ?")
		return(-1)
	CASE -1
		populateError(20000, "Erreur lecture liste des agents")
		gu_message.uf_unexp()
		return(-1)
END CHOOSE

// Lecture des agents déjà présents dans AGENT_CT
ids_agent_alloc.retrieve()

// Récupérer valeur O/N dans table AGENT_CT.
// Placer cette valeur O/N sous la forme 0/1 dans C_SELECT.
// Si l'agent n'existe pas encore dans AGENT_CT, le créer.
FOR ll_row = 1 TO dw_prepose.rowcount()
	ll_found = ids_agent_alloc.find("matricule='" + dw_prepose.object.prep_matricule[ll_row] + "'", 1, ids_agent_alloc.rowcount())
	IF ll_found = 0 THEN
		ll_new = ids_agent_alloc.insertrow(0)
		ids_agent_alloc.object.matricule[ll_new] = dw_prepose.object.prep_matricule[ll_row]
		ids_agent_alloc.object.alloc_travlourds[ll_new] = "N"
		dw_prepose.object.c_select[ll_row] = 0
	ELSE
		IF ids_agent_alloc.object.alloc_travlourds[ll_found] = "O" THEN
			dw_prepose.object.c_select[ll_row] = 1
		ELSE
			dw_prepose.object.c_select[ll_row] = 0
		END IF
		dw_prepose.SetItemStatus(ll_row, 0, Primary!, NotModified!)
	END IF
NEXT

wf_actif(true)

return(1)
end function

on w_agent_alloc.create
int iCurrent
call super::create
this.dw_prepose=create dw_prepose
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_prepose
end on

on w_agent_alloc.destroy
call super::destroy
destroy(this.dw_prepose)
end on

event ue_open;call super::ue_open;// DS pour mise à jour AGENT_CT
ids_agent_alloc = CREATE uo_ds
ids_agent_alloc.dataobject = "ds_agent_alloc"
ids_agent_alloc.setTransObject(SQLCA)

// Elargir colonne de sélection pour pouvoir donner un titre
dw_prepose.object.c_select.width = 320
dw_prepose.object.t_select.text = "Allocation"

// initialiser liste des DW modifiables
wf_SetDWList({dw_prepose})
end event

event resize;call super::resize;dw_prepose.height = wf_getwsheight() - 20
dw_prepose.width = wf_getwswidth()
end event

event ue_close;call super::ue_close;DESTROY ids_agent_alloc
end event

event ue_enregistrer;call super::ue_enregistrer;long	ll_row, ll_found

// contrôle de validité de tous les champs
IF dw_prepose.event ue_checkall() < 0 THEN
	dw_prepose.SetFocus()
	return(-1)
END IF

// Mettre à jour valeur O/N dans table AGENT_CT sur base de la valeur 0/1 dans C_SELECT.
FOR ll_row = 1 TO dw_prepose.rowcount()
	ll_found = ids_agent_alloc.find("matricule='" + dw_prepose.object.prep_matricule[ll_row] + "'", 1, ids_agent_alloc.rowcount())
	IF ll_found > 0 THEN
		IF dw_prepose.object.c_select[ll_row] = 0 THEN
			ids_agent_alloc.object.alloc_travlourds[ll_found] = "N"
		ELSE
			ids_agent_alloc.object.alloc_travlourds[ll_found] = "O"
		END IF
	ELSE
		// ne devrait jamais arriver ici car les agents pas encore dans AGENT_CT y ont été ajoutés à l'open !
		CONTINUE
	END IF
NEXT

IF gu_dwservices.uf_updatetransact(ids_agent_alloc) = 1 THEN
	wf_message("Liste des agents enregistrée avec succès")
	wf_init()
	return(1)
ELSE
	populateerror(20000, "")
	gu_message.uf_unexp("AGENT_CT : Erreur lors de la mise à jour de la base de données")
	return(-1)
END IF

end event

event ue_init_menu;call super::ue_init_menu;f_menuaction({"m_enregistrer", "m_abandonner", "m_fermer"})
end event

event ue_init_win;call super::ue_init_win;IF wf_init() = -1 THEN
	post Close(this)
	return
END IF
end event

type ddlb_message from w_ancestor_dataentry`ddlb_message within w_agent_alloc
integer y = 1760
integer width = 2103
end type

type dw_prepose from uo_datawindow_multiplerow within w_agent_alloc
integer width = 2176
integer height = 1280
integer taborder = 10
boolean bringtotop = true
string dataobject = "d_prepose_multiple"
boolean vscrollbar = true
boolean border = true
end type

