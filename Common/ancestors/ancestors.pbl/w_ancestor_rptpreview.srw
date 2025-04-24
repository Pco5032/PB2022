//objectcomments Ancêtre des reports avec prévisualisation
forward
global type w_ancestor_rptpreview from w_ancestor_rpt
end type
type cb_defaults from uo_cb within w_ancestor_rptpreview
end type
type st_2 from uo_statictext within w_ancestor_rptpreview
end type
type st_1 from uo_statictext within w_ancestor_rptpreview
end type
type dw_papersize from uo_ancestor_dw within w_ancestor_rptpreview
end type
type cb_next from uo_cb within w_ancestor_rptpreview
end type
type cb_prev from uo_cb within w_ancestor_rptpreview
end type
type dw_1 from uo_ancestor_dwreport within w_ancestor_rptpreview
end type
type em_zoom from uo_editmask within w_ancestor_rptpreview
end type
type st_zoom from uo_statictext within w_ancestor_rptpreview
end type
type gb_1 from uo_groupbox within w_ancestor_rptpreview
end type
type dw_paperorient from uo_ancestor_dw within w_ancestor_rptpreview
end type
end forward

global type w_ancestor_rptpreview from w_ancestor_rpt
string tag = "TEXT_00090"
integer width = 3785
integer height = 2404
event ue_preview ( )
cb_defaults cb_defaults
st_2 st_2
st_1 st_1
dw_papersize dw_papersize
cb_next cb_next
cb_prev cb_prev
dw_1 dw_1
em_zoom em_zoom
st_zoom st_zoom
gb_1 gb_1
dw_paperorient dw_paperorient
end type
global w_ancestor_rptpreview w_ancestor_rptpreview

type prototypes

end prototypes

type variables
string	is_selectinfrench
PRIVATE integer	ii_defzoom, ii_defsize, ii_deforient, ii_style, ii_printed
PRIVATE string		is_savefolder, is_saveFileName

datawindow	i_dwdebut, i_dwfin

// usage : voir ue_closequery
boolean	ib_initializing

end variables

forward prototypes
public subroutine wf_zoomenabled (boolean ab_zoom)
public subroutine wf_setsize ()
public subroutine wf_setorient ()
public subroutine wf_setdwdebut (datawindow adw_1)
public subroutine wf_setdwfin (datawindow adw_1)
public subroutine wf_setdataobject (string as_dataobject)
public subroutine wf_initformat ()
public function boolean wf_printed ()
public function string wf_getsavefolder ()
public function string wf_getsavefilename ()
public function integer wf_getwsheight ()
public function integer wf_getwswidth ()
end prototypes

event ue_preview;string ls_zoom
// zoom par défaut du preview (pas des données DW !): vient du fichier .INI, défaut = 100
ls_zoom = ProfileString(gs_inifile,"zoom","previewzoom","100")
dw_1.SetRedraw(FALSE)
dw_1.object.datawindow.print.preview.zoom = integer(ls_zoom)
dw_1.object.datawindow.print.preview = "yes"
dw_1.SetRedraw(TRUE)
end event

public subroutine wf_zoomenabled (boolean ab_zoom);em_zoom.enabled = ab_zoom
end subroutine

public subroutine wf_setsize ();// modifier taille du papier suivant choix, et adapter le zoom en conséquence
integer	li_oldzoom, li_newzoom

iu_wait.uf_openwindow()
iu_wait.uf_addinfo(gu_translate.uf_getlabel(is_tag_resizing, "Redimensionnement en cours..."))

li_oldzoom = integer(dw_1.Object.DataWindow.Zoom)

dw_1.Object.DataWindow.Print.paper.size = integer(dw_papersize.object.code[1])

CHOOSE CASE dw_papersize.object.code[1]
	CASE 9
		IF ii_style <> 3 THEN
			li_newzoom = li_oldzoom / 1.35
			dw_1.Object.DataWindow.Zoom = li_newzoom
			em_zoom.text = string(li_newzoom)
		END IF
		this.triggerevent("ue_preview")
	CASE 8
		IF ii_style <> 3 THEN
			li_newzoom = li_oldzoom * 1.35
			dw_1.Object.DataWindow.Zoom = li_newzoom
			em_zoom.text = string(li_newzoom)
		END IF
		this.triggerevent("ue_preview")
	CASE ELSE
		IF ii_style <> 3 THEN
			dw_1.Object.DataWindow.Zoom = ii_defzoom
			em_zoom.text = string(ii_defzoom)
		END IF
		this.triggerevent("ue_preview")
END CHOOSE

iu_wait.uf_closewindow()
end subroutine

public subroutine wf_setorient ();// modifier orientation du papier suivant choix, et adapter le zoom en conséquence
integer	li_oldzoom, li_newzoom

iu_wait.uf_openwindow()
iu_wait.uf_addinfo(gu_translate.uf_getlabel(is_tag_resizing, "Redimensionnement en cours..."))

li_oldzoom = integer(dw_1.Object.DataWindow.Zoom)

dw_1.Object.DataWindow.Print.Orientation = integer(dw_paperorient.object.code[1])
CHOOSE CASE dw_paperorient.object.code[1]
	CASE 2
		IF ii_style <> 3 THEN
			li_newzoom = li_oldzoom / 1.35
			dw_1.Object.DataWindow.Zoom = li_newzoom
			em_zoom.text = string(li_newzoom)
		END IF
		this.triggerevent("ue_preview")
	CASE 1
		IF ii_style <> 3 THEN
			li_newzoom = li_oldzoom * 1.35
			dw_1.Object.DataWindow.Zoom = li_newzoom
			em_zoom.text = string(li_newzoom)
		END IF
		this.triggerevent("ue_preview")
	CASE ELSE
		IF ii_style <> 3 THEN
			dw_1.Object.DataWindow.Zoom = ii_defzoom
			em_zoom.text = string(ii_defzoom)
		END IF
		this.triggerevent("ue_preview")
END CHOOSE

iu_wait.uf_closewindow()
end subroutine

public subroutine wf_setdwdebut (datawindow adw_1);// assigner le DW à utiliser pour imprimer la page de garde
i_dwdebut = adw_1
end subroutine

public subroutine wf_setdwfin (datawindow adw_1);// assigner le DW à utiliser pour imprimer la page de cloture
i_dwfin = adw_1
end subroutine

public subroutine wf_setdataobject (string as_dataobject);dw_1.uf_changedataobject(as_dataobject)
dw_1.SetTransObject(SQLCA)
end subroutine

public subroutine wf_initformat ();string	ls_zoom

// orientation par défaut si pas précisée dans le DW = PORTRAIT
IF integer(dw_1.Object.DataWindow.Print.Orientation) = 0 THEN
	dw_1.Object.DataWindow.Print.Orientation = 2
END IF
ii_deforient = integer(dw_1.Object.DataWindow.Print.orientation)

// taille de papier par défaut si pas précisée dans le DW = A4
IF integer(dw_1.Object.DataWindow.Print.Paper.Size) = 0 THEN
	dw_1.Object.DataWindow.Print.Paper.Size = 9
END IF
ii_defsize = integer(dw_1.Object.DataWindow.Print.Paper.Size)

// initialiser les listes de choix d'orientation et de taille papier
dw_paperorient.insertrow(0)
dw_papersize.insertrow(0)
dw_paperorient.object.code[1] = integer(dw_1.Object.DataWindow.Print.Orientation)
dw_papersize.object.code[1] = integer(dw_1.Object.DataWindow.Print.Paper.Size)

// type de datawindow (graph, tabular...)
ii_style = integer(dw_1.Object.DataWindow.Processing)

// zoom par défaut : vient du fichier .INI, défaut = 100
// attention : la valeur de ZOOM n'est pas modifiables sur les DW de type GRAPH (propriété processing=3)
IF ii_style = 3 THEN
	wf_zoomenabled(FALSE)
ELSE
	ls_zoom = ProfileString(gs_inifile,"zoom",dw_1.dataobject,"100")
	dw_1.Object.DataWindow.Zoom = integer(ls_zoom)
	em_zoom.text = ls_zoom
	ii_defzoom = integer(ls_zoom)
END IF

end subroutine

public function boolean wf_printed ();// renvoie TRUE si on a effectivement demandé l'impression (on a cliqué sur OK dans W_PRINT_SETUP),
// ou FALSE si on a cliqué sur ANNULER

IF ii_printed = 1 THEN
	return(TRUE)
ELSE
	return(FALSE)
END IF
end function

public function string wf_getsavefolder ();// renvoie le nom du dossier sélectionné par l'utilisateur pour sauver les données dans un fichier
return(is_SaveFolder)
end function

public function string wf_getsavefilename ();// renvoie le nom de fichier choisi par l'utilisateur pour sauver les données
return(is_savefilename)
end function

public function integer wf_getwsheight ();// renvoie en PBU la hauteur de travail disponible pour le DW dans la fenêtre
return(this.workSpaceHeight() - dw_1.y)
end function

public function integer wf_getwswidth ();// renvoie en PBU la largeur de travail disponible dans la fenêtre
return(this.workSpaceWidth() - dw_1.x)
end function

event ue_beforeretrieve;call super::ue_beforeretrieve;// return 1 : OK
// return 0 : rien à imprimer pur cause d'abandon lors de l'introduction des critères ou autre raison
// return -1 : erreur lors du SetSQLselect

integer		li_status
string		ls_originalselect, ls_newselect
w_selection	lw_selection

IF wf_sqlfromdw() THEN 
	ls_originalselect = dw_1.GetSQLSelect()
ELSE
	ls_originalselect = wf_getoriginalselect()
END IF
	
// les paramètres d'input destinés aux descendants de cet objet doivent être assigné avant d'arriver ici
// et être attribués au moyen de la fonction wf_setmoreselectparams
istr_inputparams.a_param[1] = wf_GetReportcritere()
istr_inputparams.a_param[2] = wf_getmodel()
istr_inputparams.a_param[3] = ls_originalselect
istr_inputparams.a_param[5] = wf_trienabled()
istr_inputparams.a_param[4] = wf_showselection()
istr_inputparams.a_param[6] = id_sequence
istr_inputparams.a_param[7] = wf_buttonsenabled()
istr_inputparams.a_param[8] = wf_getInsertionpoint()
istr_inputparams.a_param[9] = wf_getevalmsg()
istr_inputparams.a_param[10] = wf_getnbgroups()
istr_inputparams.a_param[11] = wf_appendorderby()

IF NOT wf_showselection() THEN
	// si on ne laisse pas l'utilisateur modifier la sélection par défaut, on utilise quand même le programme
	// de sélection de façon cachée pour créer l'ordre SQL complet
	opensheetWithParm(lw_selection, istr_inputparams, wf_getselectionwindow(), gw_mdiframe, 0, Original!)
	IF NOT isValid(this) THEN
		return(-1)
	END IF
	IF NOT IsValid(lw_selection) THEN
		populateError(20000,"")
		gu_message.uf_unexp("Erreur d'initialisation")
		post close(this)
		return(-1)
	END IF
	IF IsNull(lw_selection) THEN 
		populateError(20000,"")
		gu_message.uf_unexp("Erreur d'initialisation")
		post close(this)
		return(-1)
	END IF
	ls_newselect = lw_selection.wf_generateNewSelect(is_where, is_order)
	is_selectinfrench = lw_selection.wf_generatewherefr()
	close(lw_selection)
ELSE
	// la modification des critères est autorisée
	OpenWithparm(lw_selection, istr_inputparams, wf_getselectionwindow())
	// PCO 26/04/2016 et 13/06 : click sur bouton CANCEL renvoie(-1). ALT-F4 ou clic sur le bouton de fermeture Windows 
	// (bouton X en haut à droite) ou clic sur coin en haut à gauche (menu fenêtre Windows) puis choix fermeture
	// est sensé déclencher l'event du bouton abandonner. Cela fonctionne 9 fois sur 10, mais aléatoirement ça ne
	// fonctionne pas, donc ce n'est pas (-1) qui est renvoyé dans MESSAGE, et ce n'est pas non plus la structure
	// attendue, d'où plantage dans le ELSE. J'y ai donc rajouté certains tests.
	IF NOT isValid(this) THEN
		return(-1)
	END IF
	IF Message.DoubleParm = -1 THEN
		return(0)
	ELSE
		istr_selectionparams = Message.PowerObjectParm
		IF isNull(istr_selectionparams) THEN
			return(0)
		ELSE
			ls_newselect = string(istr_selectionparams.a_param[1])
			is_selectinfrench = string(istr_selectionparams.a_param[2])
			is_where = string(istr_selectionparams.a_param[3])
			is_order = string(istr_selectionparams.a_param[4])
		END IF
	END IF
END IF

IF IsNull(ls_newselect) THEN
	return(0)
ELSE
	IF LenA(trim(ls_newselect)) = 0 THEN
		IF wf_sqlfromdw() THEN
			return(1)
		ELSE
			return(this.event ue_manualSQL(""))
		END IF
	ELSE
		// si l'ordre SQL provient du DW, on le remplace par le nouvel ordre SQL dans le DW
		IF wf_sqlfromdw() THEN 
			li_status = dw_1.SetSQLSelect(ls_newselect)
			IF li_status = 1 THEN
				return(1)
			ELSE
				gu_message.uf_error("Impossible d'assigner l'ordre SQL~n~n" + ls_newselect + "~n~n")
				return(-1)
			END IF

		// si l'ordre SQL ne provient pas du DW mais a été fournit directement par le programmeur, il faut 
		// compléter l'event ue_manualSQL avec ce qu'on veut
		ELSE
			return(this.event ue_manualSQL(ls_newselect))
		END IF
	END IF
END IF

end event

event ue_enregistrer;call super::ue_enregistrer;integer	li_st

li_st = dw_1.uf_SaveAs(is_SaveFolder, is_SaveFileName)

// ouverture du document
IF li_st = 1 THEN
	f_runFile(is_SaveFolder + "\" + is_SaveFileName)
END IF
end event

event ue_print;call super::ue_print;str_params	lstr_params

// Ouverture de la fenêtre print_setup avec comme paramètre 
// 1) le datawindow principal
// 2) l'autorisation ou pas de cancel
// 3) le datawindow pour imprimer la page de garde (facultatif)
// 4) le datawindow pour imprimer la page de cloture (facultatif)
lstr_params.a_param[1] = dw_1
lstr_params.a_param[2] = wf_cancelpermitted()
IF IsValid(i_dwdebut) THEN lstr_params.a_param[3] = i_dwdebut
IF IsValid(i_dwfin) THEN lstr_params.a_param[4] = i_dwfin

openwithparm(w_print_setup, lstr_params)
ii_printed = Message.doubleparm

// rafraichir le preview est nécessaire si on a changé d'imprimante, de format ...
dw_1.object.datawindow.print.preview = "yes"

return(ii_printed)

end event

on w_ancestor_rptpreview.create
int iCurrent
call super::create
this.cb_defaults=create cb_defaults
this.st_2=create st_2
this.st_1=create st_1
this.dw_papersize=create dw_papersize
this.cb_next=create cb_next
this.cb_prev=create cb_prev
this.dw_1=create dw_1
this.em_zoom=create em_zoom
this.st_zoom=create st_zoom
this.gb_1=create gb_1
this.dw_paperorient=create dw_paperorient
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_defaults
this.Control[iCurrent+2]=this.st_2
this.Control[iCurrent+3]=this.st_1
this.Control[iCurrent+4]=this.dw_papersize
this.Control[iCurrent+5]=this.cb_next
this.Control[iCurrent+6]=this.cb_prev
this.Control[iCurrent+7]=this.dw_1
this.Control[iCurrent+8]=this.em_zoom
this.Control[iCurrent+9]=this.st_zoom
this.Control[iCurrent+10]=this.gb_1
this.Control[iCurrent+11]=this.dw_paperorient
end on

on w_ancestor_rptpreview.destroy
call super::destroy
destroy(this.cb_defaults)
destroy(this.st_2)
destroy(this.st_1)
destroy(this.dw_papersize)
destroy(this.cb_next)
destroy(this.cb_prev)
destroy(this.dw_1)
destroy(this.em_zoom)
destroy(this.st_zoom)
destroy(this.gb_1)
destroy(this.dw_paperorient)
end on

event ue_init_menu;call super::ue_init_menu;f_menuaction({"m_enregistrer","m_fermer"})
end event

event resize;call super::resize;// adapter la hauteur du DW et du groupbox
dw_1.width = this.wf_getwsWidth()
dw_1.height = this.wf_getwsHeight()
gb_1.width = this.wf_getwsWidth()

end event

event ue_retrieve;call super::ue_retrieve;long	ll_rows

// par défaut, simple retrieve mais on peut modifier ce comportement avec Override Ancestor SCript
// on passe comme argument de retrieve le n° de session et de séquence, à toutes fins utiles
iu_wait.uf_openwindow()
iu_wait.uf_addinfo(gu_translate.uf_getlabel(is_tag_reading, "Lecture des données"))
ll_rows = dw_1.retrieve(gd_session, id_sequence)
IF ll_rows = -1 THEN
	iu_wait.uf_closewindow()
	return(-1)
END IF
iu_wait.uf_closewindow()
return(ll_rows)

end event

event ue_postopen;call super::ue_postopen;integer	li_ret

IF NOT wf_executepostopen() THEN return

// usage : voir ue_closequery
ib_initializing = TRUE

wf_initformat()

li_ret = this.event ue_beforeretrieve()
IF NOT isValid(this) THEN
	return
END IF
CHOOSE CASE li_ret
	CASE 0
		ib_initializing = FALSE
		close(this)
	CASE -1
		ib_initializing = FALSE
		gu_message.uf_error("Erreur d'initialisation")
		close(this)
	CASE ELSE
		this.event ue_preview()
		li_ret = this.event ue_retrieve()
		ib_initializing = FALSE
		CHOOSE CASE li_ret
			// erreur de lecture
			CASE -1
				gu_message.uf_error("Erreur de lecture (ue_retrieve)")
				close(this)
			// no rows
			CASE 0
				close(this)
		END CHOOSE
END CHOOSE

end event

event ue_open;call super::ue_open;integer	li_ret

/* par défaut : 
	on montre l'écran de sélection des critères, 
	on peut canceler une impression lancée, 
	on peut modifier l'ordre de tri,
	l'ordre SQL sur lequel s'appliquera les critères de sélection est obtenu à partir du DW,
	le ORDER BY de la sélection remplace le ORDER BY original
*/
wf_showselection(TRUE)
wf_cancel(TRUE)
wf_trienabled(TRUE)
wf_buttonsenabled(TRUE)
wf_sqlfromdw(TRUE)
wf_appendorderby(FALSE)

// initialiser
this.event ue_init()
end event

event ue_closequery;call super::ue_closequery;// PCO 24/03/2017 : empêche la fermeture de la fenêtre alors que son initialisation n'est pas terminée
// (ce qui entraîne des erreurs "Null object reference").
IF ib_initializing THEN
	return(1)
ELSE
	return(0)
END IF
end event

type cb_defaults from uo_cb within w_ancestor_rptpreview
string tag = "TEXT_00096"
integer x = 3346
integer y = 48
integer width = 256
integer height = 160
integer taborder = 60
string text = "Défauts"
end type

event clicked;call super::clicked;dw_papersize.object.code[1] = ii_defsize
wf_setsize()

dw_paperorient.object.code[1] = ii_deforient
wf_setorient()

IF ii_style <> 3 THEN
	dw_1.Object.DataWindow.Zoom = ii_defzoom
	em_zoom.text = string(ii_defzoom)
END IF
this.triggerevent("ue_preview")

end event

type st_2 from uo_statictext within w_ancestor_rptpreview
string tag = "TEXT_00095"
integer x = 2450
integer y = 128
integer width = 347
integer textsize = -8
string text = "Orientation"
end type

type st_1 from uo_statictext within w_ancestor_rptpreview
string tag = "TEXT_00094"
integer x = 2450
integer y = 56
integer width = 347
integer textsize = -8
string text = "Taille du papier"
end type

type dw_papersize from uo_ancestor_dw within w_ancestor_rptpreview
integer x = 2798
integer y = 48
integer width = 530
integer height = 80
integer taborder = 40
string dataobject = "d_papersize"
end type

event ue_postitemvalidated;call super::ue_postitemvalidated;wf_setsize()
end event

type cb_next from uo_cb within w_ancestor_rptpreview
string tag = "TEXT_00092"
integer x = 384
integer y = 80
integer width = 293
integer height = 108
integer taborder = 20
string text = "&Suiv."
end type

event clicked;call super::clicked;dw_1.ScrollNextPage()
end event

type cb_prev from uo_cb within w_ancestor_rptpreview
string tag = "TEXT_00091"
integer x = 73
integer y = 80
integer width = 293
integer height = 108
integer taborder = 10
string text = "&Préc."
end type

event clicked;call super::clicked;dw_1.ScrollPriorPage()
end event

type dw_1 from uo_ancestor_dwreport within w_ancestor_rptpreview
integer x = 18
integer y = 240
integer width = 3712
integer height = 2032
integer taborder = 70
boolean hscrollbar = true
boolean vscrollbar = true
end type

type em_zoom from uo_editmask within w_ancestor_rptpreview
event ue_changing pbm_enchange
integer x = 1957
integer y = 92
integer width = 238
integer height = 80
integer taborder = 30
string text = "100"
string mask = "###"
boolean spin = true
double increment = 1
string minmax = "50~~200"
end type

event ue_changing;integer li_zoom

li_zoom = integer(this.text)
if li_zoom < 50 then
	li_zoom = 50
else
	if li_zoom > 200 then
		li_zoom = 200
	end if
end if
dw_1.Object.DataWindow.Zoom = li_zoom
Parent.triggerevent("ue_preview")
end event

type st_zoom from uo_statictext within w_ancestor_rptpreview
string tag = "TEXT_00093"
integer x = 1682
integer y = 96
integer width = 256
string text = "Zoom"
alignment alignment = right!
end type

type gb_1 from uo_groupbox within w_ancestor_rptpreview
integer x = 18
integer width = 3712
integer height = 224
end type

type dw_paperorient from uo_ancestor_dw within w_ancestor_rptpreview
integer x = 2798
integer y = 128
integer width = 530
integer height = 80
integer taborder = 50
boolean bringtotop = true
string dataobject = "d_paperorient"
end type

event ue_postitemvalidated;call super::ue_postitemvalidated;wf_setorient()
end event

