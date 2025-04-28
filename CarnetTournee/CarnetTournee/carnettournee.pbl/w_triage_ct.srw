//objectcomments Par triage, données propres au carnet de tournée : nombre de points annuels
forward
global type w_triage_ct from w_ancestor_dataentry
end type
type dw_triage from uo_datawindow_multiplerow within w_triage_ct
end type
end forward

global type w_triage_ct from w_ancestor_dataentry
string tag = "TEXT_00825"
integer width = 2784
integer height = 2244
string title = "Points annuels attribué aux triages"
boolean maxbox = true
boolean resizable = true
dw_triage dw_triage
end type
global w_triage_ct w_triage_ct

type variables
uo_ds	ids_triage_ct
end variables

forward prototypes
public function integer wf_init ()
end prototypes

public function integer wf_init ();// initialiser DW et DS
string	ls_super
long		ll_row, ll_found, ll_new, ll_st

// Constituer la liste des triages accessibles à l'utilisateur (Correspondant du Personnel)
// Attention : si membre du groupe de superusers "FULL", accès à tous les triages !
IF gu_privs.uf_super("FULL") THEN
	ls_super = "O"
ELSE
	ls_super = "N"
END IF

ll_st = dw_triage.retrieve(ls_super, gs_username) 
CHOOSE CASE ll_st
	CASE 0
		gu_message.uf_info("Aucun triage configuré - Etes-vous Correspondant du Personnel ou Chef de Cantonnement ?")
		return(-1)
	CASE -1
		populateError(20000, "Erreur lecture liste des triages")
		gu_message.uf_unexp()
		return(-1)
END CHOOSE

// Lecture des triages déjà présents dans TRIAGE_CT
ids_triage_ct.retrieve()

// Récupérer valeur POINTS dans table TRIAGE_CT.
// Si le triage n'existe pas encore dans TRIAGE_CT, le créer.
FOR ll_row = 1 TO dw_triage.rowcount()
	ll_found = ids_triage_ct.find("codeservice='" + dw_triage.object.codeservice[ll_row] + "'", 1, ids_triage_ct.rowcount())
	IF ll_found = 0 THEN
		ll_new = ids_triage_ct.insertrow(0)
		ids_triage_ct.object.codeservice[ll_new] = dw_triage.object.codeservice[ll_row]
	ELSE
		dw_triage.object.c_points[ll_row] = ids_triage_ct.object.points[ll_found]
		dw_triage.SetItemStatus(ll_row, 0, Primary!, NotModified!)
	END IF
NEXT

wf_actif(true)

return(1)
end function

on w_triage_ct.create
int iCurrent
call super::create
this.dw_triage=create dw_triage
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_triage
end on

on w_triage_ct.destroy
call super::destroy
destroy(this.dw_triage)
end on

event ue_open;call super::ue_open;// DS pour mise à jour AGENT_CT
ids_triage_ct = CREATE uo_ds
ids_triage_ct.dataobject = "ds_triage_ct"
ids_triage_ct.setTransObject(SQLCA)

// initialiser liste des DW modifiables
wf_SetDWList({dw_triage})

dw_triage.uf_autoselectrow(FALSE)
end event

event resize;call super::resize;dw_triage.height = wf_getwsheight() - 20
dw_triage.width = wf_getwswidth()
end event

event ue_close;call super::ue_close;DESTROY ids_triage_ct
end event

event ue_enregistrer;call super::ue_enregistrer;long	ll_row, ll_found

// contrôle de validité de tous les champs
IF dw_triage.event ue_checkall() < 0 THEN
	dw_triage.SetFocus()
	return(-1)
END IF

// Mettre à jour valeurs dans table AGENT_CT sur base de la valeur dans le DW affiché.
FOR ll_row = 1 TO dw_triage.rowcount()
	ll_found = ids_triage_ct.find("codeservice='" + dw_triage.object.codeservice[ll_row] + "'", 1, ids_triage_ct.rowcount())
	IF ll_found > 0 THEN
		ids_triage_ct.object.points[ll_found] = dw_triage.object.c_points[ll_row]
	ELSE
		// ne devrait jamais arriver ici car les triages pas encore dans TRIAGE_CT y ont été ajoutés à l'open !
		CONTINUE
	END IF
NEXT

IF gu_dwservices.uf_updatetransact(ids_triage_ct) = 1 THEN
	wf_message("Liste des triages enregistrée avec succès")
	wf_init()
	return(1)
ELSE
	populateerror(20000, "")
	gu_message.uf_unexp("TRIAGE_CT : Erreur lors de la mise à jour de la base de données")
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

type ddlb_message from w_ancestor_dataentry`ddlb_message within w_triage_ct
integer x = 18
integer y = 1984
integer width = 1573
end type

type dw_triage from uo_datawindow_multiplerow within w_triage_ct
integer width = 2743
integer height = 1952
integer taborder = 10
boolean bringtotop = true
string dataobject = "d_triage_ct"
boolean vscrollbar = true
boolean border = true
end type

