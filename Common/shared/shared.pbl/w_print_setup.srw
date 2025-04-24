//objectcomments Fenêtre de setup de l'imprimante
forward
global type w_print_setup from w_ancestor
end type
type cb_options from uo_cb within w_print_setup
end type
type cb_cancel from uo_cb_cancel within w_print_setup
end type
type cb_ok from uo_cb_ok within w_print_setup
end type
type em_copies from uo_editmask within w_print_setup
end type
type mle_texte from uo_mle within w_print_setup
end type
type sle_page_range from uo_sle within w_print_setup
end type
type rb_pages from uo_radiobutton within w_print_setup
end type
type rb_tout from uo_radiobutton within w_print_setup
end type
type st_copies from uo_statictext within w_print_setup
end type
type st_imprimante from uo_statictext within w_print_setup
end type
type st_currentprinter from uo_statictext within w_print_setup
end type
type gb_etendue from uo_groupbox within w_print_setup
end type
end forward

global type w_print_setup from w_ancestor
string tag = "TEXT_00079"
integer x = 832
integer y = 360
integer width = 2226
integer height = 1032
string title = "Setup d~'impression"
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
long backcolor = 12632256
cb_options cb_options
cb_cancel cb_cancel
cb_ok cb_ok
em_copies em_copies
mle_texte mle_texte
sle_page_range sle_page_range
rb_pages rb_pages
rb_tout rb_tout
st_copies st_copies
st_imprimante st_imprimante
st_currentprinter st_currentprinter
gb_etendue gb_etendue
end type
global w_print_setup w_print_setup

type variables
datawindow  i_dwtoacton, i_dwdebut, i_dwfin
boolean		ib_cancelpermitted
uo_wait		iu_wait

end variables

on w_print_setup.create
int iCurrent
call super::create
this.cb_options=create cb_options
this.cb_cancel=create cb_cancel
this.cb_ok=create cb_ok
this.em_copies=create em_copies
this.mle_texte=create mle_texte
this.sle_page_range=create sle_page_range
this.rb_pages=create rb_pages
this.rb_tout=create rb_tout
this.st_copies=create st_copies
this.st_imprimante=create st_imprimante
this.st_currentprinter=create st_currentprinter
this.gb_etendue=create gb_etendue
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_options
this.Control[iCurrent+2]=this.cb_cancel
this.Control[iCurrent+3]=this.cb_ok
this.Control[iCurrent+4]=this.em_copies
this.Control[iCurrent+5]=this.mle_texte
this.Control[iCurrent+6]=this.sle_page_range
this.Control[iCurrent+7]=this.rb_pages
this.Control[iCurrent+8]=this.rb_tout
this.Control[iCurrent+9]=this.st_copies
this.Control[iCurrent+10]=this.st_imprimante
this.Control[iCurrent+11]=this.st_currentprinter
this.Control[iCurrent+12]=this.gb_etendue
end on

on w_print_setup.destroy
call super::destroy
destroy(this.cb_options)
destroy(this.cb_cancel)
destroy(this.cb_ok)
destroy(this.em_copies)
destroy(this.mle_texte)
destroy(this.sle_page_range)
destroy(this.rb_pages)
destroy(this.rb_tout)
destroy(this.st_copies)
destroy(this.st_imprimante)
destroy(this.st_currentprinter)
destroy(this.gb_etendue)
end on

event ue_close;call super::ue_close;DESTROY iu_wait
end event

event ue_open;call super::ue_open;/* paramètres INPUT :
		1) datawindow	: DW principal à imprimer
		2) boolean		: autorisation ou pas de canceler l'impression 
		3) datawindow	: DW page de garde à imprimer (facultatif)
		4) datawindow	: DW page de cloture à imprimer (facultatif)
*/

integer li_copies
str_params	lstr_params

// ne pas logger de message lors de l'utilisation de cette fenêtre
wf_logusage(FALSE)

f_centerInMdi(this)

// Récupération des paramètres
lstr_params = message.powerobjectparm
i_dwtoacton = lstr_params.a_param[1]
ib_cancelpermitted = lstr_params.a_param[2]

IF upperbound(lstr_params.a_param) >= 3 THEN
	IF NOT classname(lstr_params.a_param[3]) = "any" THEN // teste si la variable a été initialisée ou pas
		i_dwdebut = lstr_params.a_param[3]
	END IF
END IF
IF upperbound(lstr_params.a_param) = 4 THEN
	IF NOT classname(lstr_params.a_param[4]) = "any" THEN // teste si la variable a été initialisée ou pas
		i_dwfin = lstr_params.a_param[4]
	END IF
END IF

iu_wait = CREATE uo_wait

// Récupération de l'imprimante par défaut
st_CurrentPrinter.text = string(i_dwtoacton.object.datawindow.printer)

// Initialisation du nombre de copies 
li_copies = integer(i_dwtoacton.object.datawindow.print.copies)
if li_copies > 0 then
	em_copies.text = string(li_copies)
else
	em_copies.text = "1"
end if
// PCO 31/07/2015 : la propriété .copies du DW et le nombre d'exemplaires demandé dans le présent écran
// se multiplient --> je remets à 1 la propriété .copies
i_dwtoacton.object.datawindow.print.copies = 1

	
end event

type cb_options from uo_cb within w_print_setup
string tag = "TEXT_00086"
integer x = 1755
integer y = 752
integer width = 384
integer height = 108
integer taborder = 60
string text = "&Options..."
end type

event clicked;// appel de l'écran de choix de l'imprimante 
printsetup()

// raffraichir l'affichage du nom de l'imprimante en cours
st_CurrentPrinter.text = string(i_dwtoacton.object.datawindow.printer)


end event

type cb_cancel from uo_cb_cancel within w_print_setup
string tag = "TEXT_00028"
integer x = 1751
integer y = 616
integer width = 389
integer height = 108
integer taborder = 50
string text = "&Annuler"
end type

event clicked;closeWithReturn(parent, 0)
end event

type cb_ok from uo_cb_ok within w_print_setup
string tag = "TEXT_00027"
integer x = 1746
integer y = 480
integer width = 398
integer height = 116
integer taborder = 40
end type

event clicked;string s_page
integer	li_copies, li_n

// nombre de copies
// on n'utilise plus la propriété 'copies' du DW car on veut pouvoir imprimer en séquence plusieurs DW (voir param.)
// i_dwtoacton.Object.Datawindow.print.copies = integer(em_copies.text)
li_copies = integer(em_copies.text)

// Choix de l'étendue
if rb_tout.checked then
	i_dwtoacton.Object.Datawindow.print.page.range=""
	else
	i_dwtoacton.Object.Datawindow.print.page.range = sle_page_range.text
end if
	
// parent.visible = false

iu_wait.uf_openwindow()
iu_wait.uf_addinfo("Impression en cours")
FOR li_n = 1 TO li_copies
	IF IsValid(i_dwdebut) THEN
		IF NOT isNull(i_dwdebut) THEN i_dwdebut.print(FALSE)
	END IF
	i_dwtoacton.print(ib_cancelpermitted)
	// PCO 30/03/2017 : lorsque ib_cancelpermitted vaut TRUE, il est possible de cliquer sur le bouton "fermer"
	// de la fenêtre w_print_setup, ce qui entraîne un null object ref plus loin, d'où ajout du test isValid(this)
	IF NOT isValid(this) THEN
		return
	END IF
	IF IsValid(i_dwfin) THEN
		IF NOT isNull(i_dwfin) THEN i_dwfin.print(FALSE)
	END IF
NEXT
iu_wait.uf_closewindow()

this.setfocus()

closeWithReturn(parent, 1)

end event

type em_copies from uo_editmask within w_print_setup
integer x = 384
integer y = 128
integer width = 183
integer height = 80
integer taborder = 10
long backcolor = 16777215
alignment alignment = center!
string mask = "##"
boolean spin = true
string displaydata = ""
double increment = 1
string minmax = "1~~99"
end type

type mle_texte from uo_mle within w_print_setup
string tag = "TEXT_00085"
integer x = 91
integer y = 624
integer width = 1481
integer height = 144
long backcolor = 12632256
string text = "Tapez les n° des pages et/ou les groupes de pages à imprimer, séparés par des virgules (1,3,5-12,14)."
boolean border = false
end type

type sle_page_range from uo_sle within w_print_setup
integer x = 457
integer y = 480
integer width = 1033
integer height = 92
integer taborder = 30
long backcolor = 16777215
boolean enabled = false
boolean autohscroll = false
end type

type rb_pages from uo_radiobutton within w_print_setup
string tag = "TEXT_00084"
integer x = 91
integer y = 480
integer width = 366
long backcolor = 12632256
string text = "Pages : "
end type

event clicked;sle_page_range.enabled = this.checked
end event

type rb_tout from uo_radiobutton within w_print_setup
string tag = "TEXT_00083"
integer x = 91
integer y = 352
integer width = 366
long backcolor = 12632256
string text = "Tout"
boolean checked = true
end type

event clicked;sle_page_range.enabled = not this.checked
end event

type st_copies from uo_statictext within w_print_setup
string tag = "TEXT_00081"
integer x = 73
integer y = 128
integer width = 302
integer height = 76
integer weight = 700
long backcolor = 12632256
string text = "Copies : "
end type

type st_imprimante from uo_statictext within w_print_setup
string tag = "TEXT_00080"
integer x = 73
integer y = 32
integer width = 366
integer height = 80
long backcolor = 12632256
string text = "Imprimante : "
end type

type st_currentprinter from uo_statictext within w_print_setup
integer x = 439
integer y = 32
integer width = 1614
integer height = 76
integer weight = 700
long textcolor = 255
long backcolor = 12632256
end type

type gb_etendue from uo_groupbox within w_print_setup
string tag = "TEXT_00082"
integer x = 27
integer y = 236
integer width = 1591
integer height = 628
integer taborder = 20
long backcolor = 12632256
string text = "Etendue"
end type

