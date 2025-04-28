//objectcomments Paramètres pour la déclaration hebdomadaire
forward
global type w_options_dec_hebdo from w_ancestor
end type
type uo_semaine from uvo_navweek within w_options_dec_hebdo
end type
type st_prep from uo_statictext within w_options_dec_hebdo
end type
type cb_ok from uo_cb_ok within w_options_dec_hebdo
end type
type cb_cancel from uo_cb_cancel within w_options_dec_hebdo
end type
type dw_prepose from uo_datawindow_singlerow within w_options_dec_hebdo
end type
end forward

global type w_options_dec_hebdo from w_ancestor
string tag = "TEXT_00696"
integer width = 1870
integer height = 640
string title = "Déclaration hebdomadaire"
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
uo_semaine uo_semaine
st_prep st_prep
cb_ok cb_ok
cb_cancel cb_cancel
dw_prepose dw_prepose
end type
global w_options_dec_hebdo w_options_dec_hebdo

type variables
string	is_matricule
integer	ii_year, ii_week

end variables

on w_options_dec_hebdo.create
int iCurrent
call super::create
this.uo_semaine=create uo_semaine
this.st_prep=create st_prep
this.cb_ok=create cb_ok
this.cb_cancel=create cb_cancel
this.dw_prepose=create dw_prepose
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.uo_semaine
this.Control[iCurrent+2]=this.st_prep
this.Control[iCurrent+3]=this.cb_ok
this.Control[iCurrent+4]=this.cb_cancel
this.Control[iCurrent+5]=this.dw_prepose
end on

on w_options_dec_hebdo.destroy
call super::destroy
destroy(this.uo_semaine)
destroy(this.st_prep)
destroy(this.cb_ok)
destroy(this.cb_cancel)
destroy(this.dw_prepose)
end on

event ue_open;call super::ue_open;DatawindowChild	ldwc_dropdown
long		ll_nbrows
string	ls_super

f_centerInMdi(this)

dw_prepose.insertrow(0)

// Lire la liste des préposés du responsable auquel est ajouté l'utilisateur lui-même
// Attention : si membre du groupe de superusers "FULL", accès à tous les agents paramétrés dans le système !
IF gu_privs.uf_super("FULL") THEN
	ls_super = "O"
ELSE
	ls_super = "N"
END IF
dw_prepose.GetChild("prep_matricule", ldwc_dropdown)
ldwc_dropdown.settransobject(SQLCA)
// 07/2015 : argument "R" : indique qu'on souhaite la liste des agents pour lesquels on a le droit 
// de consulter (et peut-être modifier) le Réalisé.
ll_nbrows = ldwc_dropdown.retrieve(gs_username, ls_super, "R")
IF ll_nbrows <= 0 THEN
	dw_prepose.insertrow(0)
	populateError(20000, "Erreur lecture des préposés pour " + f_string(gs_username))
ELSE
	// PCO 02MAI2016 : si on met 0 dans le nombre de lignes du DDDW, la liste est correcte mais très réduite 
	// et peu lisible si beaucoup d'agents à afficher. Si on met un nombre de ligne (20 par exemple), la liste
	// est correcte sauf si nombre à afficher est réduit (par exemple un seul préposé) car la ligne de titre
	// est prise en compte ! Ici, je force pour que la liste soit toujours correcte.
	IF ll_nbrows < 5 THEN
		dw_prepose.Object.prep_matricule.dddw.lines = 0
	END IF
END IF
end event

event ue_closebyxaccepted;call super::ue_closebyxaccepted;CloseWithReturn(this, -1)
end event

type uo_semaine from uvo_navweek within w_options_dec_hebdo
event destroy ( )
integer x = 55
integer y = 208
integer taborder = 30
boolean bringtotop = true
end type

on uo_semaine.destroy
call uvo_navweek::destroy
end on

event ue_prev;call super::ue_prev;ii_year = uo_semaine.uf_getyear()
ii_week = uo_semaine.uf_getweek()


end event

event ue_next;call super::ue_next;ii_year = uo_semaine.uf_getyear()
ii_week = uo_semaine.uf_getweek()


end event

event ue_init;call super::ue_init;ii_year = uo_semaine.uf_getyear()
ii_week = uo_semaine.uf_getweek()

end event

type st_prep from uo_statictext within w_options_dec_hebdo
string tag = "TEXT_00714"
integer x = 293
integer y = 48
integer width = 256
integer height = 80
boolean bringtotop = true
string text = "Préposé"
end type

type cb_ok from uo_cb_ok within w_options_dec_hebdo
string tag = "TEXT_00027"
integer x = 366
integer y = 384
boolean default = false
end type

event clicked;call super::clicked;str_params	lstr_params

IF f_isEmptyString(is_matricule) THEN
	gu_message.uf_error("Veuillez sélectionner un préposé")
	return
END IF

lstr_params.a_param[1] = is_matricule
lstr_params.a_param[2] = ii_year
lstr_params.a_param[3] = ii_week

CloseWithReturn(Parent, lstr_params)
end event

type cb_cancel from uo_cb_cancel within w_options_dec_hebdo
string tag = "TEXT_00028"
integer x = 1061
integer y = 384
end type

event clicked;call super::clicked;CloseWithReturn(Parent, -1)
end event

type dw_prepose from uo_datawindow_singlerow within w_options_dec_hebdo
integer x = 549
integer y = 48
integer width = 914
integer height = 96
integer taborder = 10
boolean bringtotop = true
string dataobject = "d_choix_prepose"
end type

event ue_itemvalidated;call super::ue_itemvalidated;is_matricule = as_data
end event

