forward
global type w_about from w_ancestor
end type
type sle_encours from uo_sle within w_about
end type
type st_c4 from uo_statictext within w_about
end type
type st_c3 from uo_statictext within w_about
end type
type st_c1 from uo_statictext within w_about
end type
type st_c2 from uo_statictext within w_about
end type
type st_6 from uo_statictext within w_about
end type
type st_1 from uo_statictext within w_about
end type
type st_dirlist from uo_statictext within w_about
end type
type lb_1 from uo_listbox within w_about
end type
type cb_1 from uo_cb_ok within w_about
end type
type gb_1 from uo_groupbox within w_about
end type
end forward

global type w_about from w_ancestor
integer width = 1970
integer height = 1692
string title = "A propos de l~'application COMPTOIR FORESTIER"
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
sle_encours sle_encours
st_c4 st_c4
st_c3 st_c3
st_c1 st_c1
st_c2 st_c2
st_6 st_6
st_1 st_1
st_dirlist st_dirlist
lb_1 lb_1
cb_1 cb_1
gb_1 gb_1
end type
global w_about w_about

type variables
uo_fileservices	iu_fileservices
end variables

on w_about.create
int iCurrent
call super::create
this.sle_encours=create sle_encours
this.st_c4=create st_c4
this.st_c3=create st_c3
this.st_c1=create st_c1
this.st_c2=create st_c2
this.st_6=create st_6
this.st_1=create st_1
this.st_dirlist=create st_dirlist
this.lb_1=create lb_1
this.cb_1=create cb_1
this.gb_1=create gb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.sle_encours
this.Control[iCurrent+2]=this.st_c4
this.Control[iCurrent+3]=this.st_c3
this.Control[iCurrent+4]=this.st_c1
this.Control[iCurrent+5]=this.st_c2
this.Control[iCurrent+6]=this.st_6
this.Control[iCurrent+7]=this.st_1
this.Control[iCurrent+8]=this.st_dirlist
this.Control[iCurrent+9]=this.lb_1
this.Control[iCurrent+10]=this.cb_1
this.Control[iCurrent+11]=this.gb_1
end on

on w_about.destroy
call super::destroy
destroy(this.sle_encours)
destroy(this.st_c4)
destroy(this.st_c3)
destroy(this.st_c1)
destroy(this.st_c2)
destroy(this.st_6)
destroy(this.st_1)
destroy(this.st_dirlist)
destroy(this.lb_1)
destroy(this.cb_1)
destroy(this.gb_1)
end on

event ue_close;call super::ue_close;DESTROY	iu_fileservices
end event

event ue_open;call super::ue_open;integer	li_item, li_max, li_nbitems, li_ctrl
string	ls_item, ls_liste[], ls_contact
double	ldb_filesize
date		ld_date
time		lt_time
window	lw_encours
staticText	l_st

f_centerInMdi(this)

iu_fileservices = CREATE uo_fileservices

// lire et afficher les contacts
FOR li_item = 1 TO 4
	ls_contact = profileString(gs_inifile, "about_contacts", "c" + string(li_item), "")
	IF f_isEmptyString(ls_contact) THEN continue
	// trouver le bon contrôle dans la fenêtre
	FOR li_ctrl = 1 TO upperbound(this.control[])
		IF this.control[li_ctrl].classname() = "st_c" + string(li_item) THEN
			l_st = this.control[li_ctrl]
			l_st.text = ls_contact
		END IF
	NEXT
NEXT

// liste des .exe
lb_1.dirlist("*.exe",0,st_dirlist)
li_nbitems = lb_1.Totalitems()
FOR li_item = 1 TO li_nbitems
	lb_1.SelectItem(li_item)
	ls_liste[li_item] = lb_1.Selecteditem()
NEXT
li_max = li_nbitems

// liste des .pbd
lb_1.dirlist("*.pbd",0)
li_nbitems = lb_1.Totalitems()
FOR li_item = 1 TO li_nbitems
	lb_1.SelectItem(li_item)
	ls_liste[li_max + li_item] = lb_1.Selecteditem()
NEXT

li_max = li_max + li_nbitems

// garnir la listbox avec la liste des fichiers + leur date de dernière modif.
lb_1.reset()
FOR li_item = 1 TO li_max
	iu_fileservices.uf_getfileattrib(ls_liste[li_item], ld_date, lt_time, ldb_filesize)
	ls_item = LeftA(ls_liste[li_item] + space(40), 25) + "~t" + string(ld_date) + " " + string(lt_time) &
					+ "~t" + string(ldb_filesize,"##,###,##0")
	lb_1.additem(ls_item)
NEXT

// afficher le nom de la fenêtre active s'il y en a une
lw_encours = gw_mdiframe.GetActiveSheet()
IF IsValid(lw_encours) THEN
	sle_encours.text = lw_encours.classname()
END IF

end event

type sle_encours from uo_sle within w_about
integer x = 402
integer y = 1376
integer width = 1536
integer height = 64
integer taborder = 20
integer weight = 700
long textcolor = 8388608
long backcolor = 67108864
boolean border = false
boolean displayonly = true
borderstyle borderstyle = stylebox!
end type

type st_c4 from uo_statictext within w_about
integer x = 1024
integer y = 272
integer width = 896
integer height = 80
string text = ""
end type

type st_c3 from uo_statictext within w_about
integer x = 1024
integer y = 192
integer width = 896
integer height = 80
string text = ""
end type

type st_c1 from uo_statictext within w_about
integer x = 55
integer y = 192
integer width = 896
integer height = 80
string text = ""
end type

type st_c2 from uo_statictext within w_about
integer x = 55
integer y = 272
integer width = 896
integer height = 80
string text = ""
end type

type st_6 from uo_statictext within w_about
integer x = 677
integer y = 32
integer width = 567
integer height = 112
integer textsize = -14
integer weight = 700
long textcolor = 8388608
string text = "COMPTOIR"
alignment alignment = center!
end type

type st_1 from uo_statictext within w_about
integer x = 18
integer y = 1376
integer width = 384
string text = "Prg en cours :"
end type

type st_dirlist from uo_statictext within w_about
integer x = 18
integer y = 416
integer width = 1920
end type

type lb_1 from uo_listbox within w_about
integer x = 18
integer y = 496
integer width = 1920
integer height = 864
boolean hscrollbar = true
boolean vscrollbar = true
boolean sorted = false
end type

type cb_1 from uo_cb_ok within w_about
integer x = 731
integer y = 1456
integer taborder = 10
boolean cancel = true
end type

event clicked;call super::clicked;close(parent)
end event

type gb_1 from uo_groupbox within w_about
integer x = 18
integer y = 128
integer width = 1920
integer height = 256
integer taborder = 10
end type

