//objectcomments Fenêtre permettant d'introduire une commande sql SELECT et d'en afficher le résultat dans un DW
forward
global type w_sql from w_ancestor
end type
type cb_mle from uo_cb within w_sql
end type
type st_dw from uo_statictext within w_sql
end type
type st_mle from uo_statictext within w_sql
end type
type mle_sql from uo_mle within w_sql
end type
type cb_dw from uo_cb_ok within w_sql
end type
type dw_sql from uo_ancestor_dwbrowse within w_sql
end type
type p_1 from picture within w_sql
end type
end forward

global type w_sql from w_ancestor
string tag = "TEXT_00100"
integer width = 2930
integer height = 2244
string title = "Visualiser/enregistrer le résultat d~'une requête SQL"
event type integer ue_abandonner ( )
event type integer ue_enregistrer ( )
event ue_folderopen ( )
event type integer ue_pre_enregistrer ( )
cb_mle cb_mle
st_dw st_dw
st_mle st_mle
mle_sql mle_sql
cb_dw cb_dw
dw_sql dw_sql
p_1 p_1
end type
global w_sql w_sql

type variables
string	is_modele, is_select, is_insertion, is_where, is_whereFR

string	is_initdir
uo_wait	iu_wait
uo_fileservices	iu_fileservices
end variables

forward prototypes
public function integer wf_criteres_selection (string as_selection)
public function integer wf_traitesql (long al_row)
public subroutine wf_setdefaultmsg ()
end prototypes

event type integer ue_abandonner();mle_sql.SelectText(1, LenA(mle_sql.text))
mle_sql.Clear()
return(1)


end event

event type integer ue_enregistrer();string	ls_pathname, ls_filename, ls_text, ls_data
integer	li_status, li_file

ls_text = mle_sql.text
IF f_IsEmptyString(ls_text) THEN
	gu_message.uf_info("Aucune requête à enregistrer")
	return(0)
END IF

li_status = GetFileSaveName("Sauver la requête SQL sous le nom...", ls_pathname, ls_filename, "sql", + &
								"Requêtes SQL (*.SQL),*.SQL", is_initdir)
								
IF li_status = 1 THEN 
	// sauver dossier choisi pour le proposer par défaut si on sauve une autre requête
	iu_fileservices.uf_basename(ls_pathname, false, is_initdir, ls_data, ls_data)
	li_file = FileOpen(ls_filename, StreamMode!, write!, LockReadWrite!, Replace!)
	IF li_file > 0 THEN
		IF FileWrite(li_file, ls_text) < 0 THEN
			gu_message.uf_error("Impossible de créer le fichier")
		END IF
		FileClose(li_file)
	END IF
END IF
return(1)
end event

event ue_folderopen();string	ls_pathname, ls_filename, ls_text
integer	li_status, li_file

li_status = GetFileOpenName("Selectionnez une requête", ls_pathname, ls_filename, "sql", + &
								"Requêtes SQL (*.SQL),*.SQL, Fichiers Texte (*.TXT),*.TXT")
IF li_status = 1 THEN 
	li_file = FileOpen(ls_filename, StreamMode!)
	IF li_file > 0 THEN
		IF FileRead(li_file, ls_text) > 0 THEN
			mle_sql.text = ls_text
		END IF
		FileClose(li_file)
	END IF
END IF
end event

event type integer ue_pre_enregistrer();IF wf_canupdate() THEN
	return(this.event ue_enregistrer())
ELSE
	gu_message.uf_info(wf_getMessageNoUpdate())
	return(-1)
END IF
end event

public function integer wf_criteres_selection (string as_selection);// afficher la grille de critères basée sur la requête passée en argument
// La variable is_modele (et si nécessaire is_insertion) doit déjà être intialisée.
// return(1) si OK et dans ce cas garni les variables is_where et is_whereFR
// return(-1) si abandon ou erreur

str_params	lstr_inputparams, lstr_selectionparams
uo_critselect	lu_critselect

is_where = ""
is_whereFR = ""
IF f_IsEmptyString(is_modele) THEN
	return(1)
END IF

lu_critselect = CREATE uo_critselect

// pas de critères par défaut
lu_critselect.uf_ResetDefaults(is_modele)

// définir les paramètres pour utiliser l'écran de sélection
lstr_inputparams.a_param[1] = is_modele
lstr_inputparams.a_param[2] = is_modele
lstr_inputparams.a_param[3] = as_selection
lstr_inputparams.a_param[4] = TRUE
lstr_inputparams.a_param[5] = FALSE
lstr_inputparams.a_param[6] = id_sequence
lstr_inputparams.a_param[7] = TRUE
lstr_inputparams.a_param[8] = is_insertion
lstr_inputparams.a_param[9] = " enregistrement(s) répond(ent) aux critères"

// choix des critères
OpenWithparm(w_selection, lstr_inputparams)
IF Message.DoubleParm = -1 THEN
	return(-1)
ELSE
	lstr_selectionparams = Message.PowerObjectParm
	is_whereFR = string(lstr_selectionparams.a_param[2])
	is_where = string(lstr_selectionparams.a_param[3])
END IF

DESTROY lu_critselect

return(1)
end function

public function integer wf_traitesql (long al_row);// traite la requête choisie
string	ls_select, ls_syntax, ls_error, ls_sql
str_params	lstr_params
window		lw_sheet

IF al_row < 1 THEN
	return(-1)
END IF

// les critères de sélection disponibles dépendent de la requête choisie
is_modele = dw_sql.object.critere[al_row]
is_insertion = dw_sql.object.insertion[al_row]
is_select = dw_sql.object.sql[al_row]

// demander les critères de sélection 
IF wf_criteres_selection(is_select) = -1 THEN
	return(-1)
END IF

// appliquer la sélection dans la requête sur les objets
ls_select = f_modifySQL(is_select, is_where, "", is_insertion)

// crée la syntaxe d'un datawindow sur base de l'ordre SQL
iu_wait.uf_addInfo("Génération syntaxe")
ls_Syntax = SQLCA.SyntaxFromSQL(ls_select, "", ls_error)
IF LenA(ls_error) > 0 THEN
	iu_wait.uf_closewindow()
	gu_message.uf_error("Ordre SQL non valide : " + ls_error)
	return(-1)
END IF

// fermer la fenêtre de preview si elle est déjà ouverte
lw_Sheet = gw_mdiframe.GetFirstSheet()
DO WHILE IsValid(lw_Sheet)
	IF lw_sheet.classname() = "w_rpt_sql" THEN
		close(lw_sheet)
		exit
	ELSE
		lw_Sheet = gw_mdiframe.GetNExtSheet(lw_sheet)
	END IF
LOOP

lstr_params.a_param[1] = ls_sql
lstr_params.a_param[2] = ls_syntax
OpenSheetWithparm(w_rpt_sql, lstr_params, gw_mdiframe, 0, Original!)

return(1)
end function

public subroutine wf_setdefaultmsg ();// d'abord appeler le code initial...
super::wf_setdefaultmsg()

// puis le code complémentaire
wf_setMessageNoUpdate("Vous n'avez pas le droit de sauver cette requête")
end subroutine

on w_sql.create
int iCurrent
call super::create
this.cb_mle=create cb_mle
this.st_dw=create st_dw
this.st_mle=create st_mle
this.mle_sql=create mle_sql
this.cb_dw=create cb_dw
this.dw_sql=create dw_sql
this.p_1=create p_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_mle
this.Control[iCurrent+2]=this.st_dw
this.Control[iCurrent+3]=this.st_mle
this.Control[iCurrent+4]=this.mle_sql
this.Control[iCurrent+5]=this.cb_dw
this.Control[iCurrent+6]=this.dw_sql
this.Control[iCurrent+7]=this.p_1
end on

on w_sql.destroy
call super::destroy
destroy(this.cb_mle)
destroy(this.st_dw)
destroy(this.st_mle)
destroy(this.mle_sql)
destroy(this.cb_dw)
destroy(this.dw_sql)
destroy(this.p_1)
end on

event ue_open;call super::ue_open;application app

iu_fileservices = CREATE uo_fileservices
iu_wait = CREATE uo_wait

// ne pas logger de message lors de l'utilisation de cette fenêtre
wf_logusage(FALSE)

app = GetApplication()

// icône "ouvrir" doit être visible dans le menu action
wf_SetItemsToShow({"m_ouvrir"})

// set current directory to gs_cenpath
ChangeDirectory(gs_cenpath)

// lire les requêtes qui concernent l'application en cours
dw_sql.retrieve(upper(app.appname))

dw_sql.SetRowFocusIndicator(p_1)
end event

event ue_init_menu;call super::ue_init_menu;f_menuaction({"m_ouvrir","m_enregistrer","m_abandonner", "m_fermer"})
end event

event resize;call super::resize;mle_sql.width = wf_getwswidth()
mle_sql.height = (newheight - 500) / 2

cb_mle.y = mle_sql.y + mle_sql.height + 32
cb_mle.x = newwidth / 2 - cb_dw.width / 2

st_dw.y = cb_mle.y + cb_mle.height - 16

dw_sql.y = st_dw.y + 96
dw_sql.width = mle_sql.width
dw_sql.height = mle_sql.height

cb_dw.y = dw_sql.y + dw_sql.height + 36
cb_dw.x = cb_mle.x
end event

event ue_close;call super::ue_close;DESTROY iu_fileservices
DESTROY iu_wait

// reset current directory to gs_startpath
ChangeDirectory(gs_startpath)

end event

type cb_mle from uo_cb within w_sql
string tag = "TEXT_00102"
integer x = 1042
integer y = 864
integer width = 695
string text = "Exécuter la requête"
end type

event clicked;call super::clicked;str_params	lstr_params
window		lw_sheet
string		ls_syntax, ls_error, ls_sql

ls_sql = trim(mle_sql.text)
IF f_IsEmptyString(ls_sql) THEN
	gu_message.uf_error("Veuillez introduire une requête ou sélectionner une requête enregistrée.")
	mle_sql.SetFocus()
	return
END IF

// crée la syntaxe d'un datawindow sur base de l'ordre SQL
ls_Syntax = SQLCA.SyntaxFromSQL(ls_sql, "", ls_error)
IF LenA(ls_error) > 0 THEN
	gu_message.uf_error("Requête SQL non valide : " + ls_error)
	mle_sql.SetFocus()
	return
END IF

// fermer la fenêtre de preview si elle est déjà ouverte
lw_Sheet = gw_mdiframe.GetFirstSheet()
DO WHILE IsValid(lw_Sheet)
	IF lw_sheet.classname() = "w_rpt_sql" THEN
		close(lw_sheet)
		exit
	ELSE
		lw_Sheet = gw_mdiframe.GetNExtSheet(lw_sheet)
	END IF
LOOP

lstr_params.a_param[1] = ls_sql
lstr_params.a_param[2] = ls_syntax
OpenSheetWithparm(w_rpt_sql, lstr_params, gw_mdiframe, 0, Original!)

end event

type st_dw from uo_statictext within w_sql
string tag = "TEXT_00103"
integer x = 18
integer y = 992
integer width = 914
integer height = 80
integer textsize = -12
integer weight = 700
long textcolor = 8388608
string text = "Requête enregistrée :"
end type

type st_mle from uo_statictext within w_sql
string tag = "TEXT_00101"
integer x = 18
integer y = 16
integer width = 914
integer height = 80
integer textsize = -12
integer weight = 700
long textcolor = 8388608
string text = "Requête libre :"
end type

type mle_sql from uo_mle within w_sql
integer y = 96
integer width = 2871
integer height = 736
integer taborder = 10
boolean vscrollbar = true
boolean autovscroll = true
boolean ignoredefaultbutton = true
end type

type cb_dw from uo_cb_ok within w_sql
string tag = "TEXT_00102"
integer x = 1042
integer y = 1984
integer width = 695
string text = "Exécuter la requête"
boolean default = false
end type

event clicked;call super::clicked;wf_traitesql(dw_sql.getrow())
end event

type dw_sql from uo_ancestor_dwbrowse within w_sql
integer y = 1088
integer width = 2871
integer height = 864
integer taborder = 0
string dataobject = "d_storedsql"
boolean hscrollbar = true
boolean vscrollbar = true
boolean border = true
end type

event clicked;call super::clicked;// si clique sur entête de la matière, trier aussi sur l'ID
IF this.uf_sort() THEN
	IF dwo.Type = "text" THEN
		IF dwo.Name = "matiere_id_t" THEN
			IF gb_sort_asc THEN
				gu_dwservices.uf_sort(this, "matiere A, id A")
				IF NOT this.uf_autoselectrow() THEN this.selectrow(row, FALSE)
			ELSE
				gu_dwservices.uf_sort(this, "matiere D, id A")
				IF NOT this.uf_autoselectrow() THEN this.selectrow(row, FALSE)
			END IF
		END IF
	END IF
END IF

end event

type p_1 from picture within w_sql
boolean visible = false
integer x = 2743
integer y = 2016
integer width = 73
integer height = 64
boolean bringtotop = true
boolean originalsize = true
string picturename = "..\bmp\currentrow.png"
boolean focusrectangle = false
end type

