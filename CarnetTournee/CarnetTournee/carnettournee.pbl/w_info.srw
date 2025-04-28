forward
global type w_info from w_ancestor
end type
type mle_info from uo_mle within w_info
end type
end forward

global type w_info from w_ancestor
integer width = 2386
integer height = 1348
string title = "Info..."
mle_info mle_info
end type
global w_info w_info

forward prototypes
public function integer wf_loadtext (string as_title, string as_filename)
end prototypes

public function integer wf_loadtext (string as_title, string as_filename);string	ls_text
integer	li_st
uo_fileservices	lu_files

IF f_isEmptyString(as_filename) THEN
	gu_message.uf_error("Nom de fichier non fourni !")
	return(-1)
END IF

IF NOT fileExists(as_filename) THEN
	gu_message.uf_error("Le fichier " + as_filename + " n'existe pas !")
	return(-1)
END IF

IF NOT f_isEmptyString(as_title) THEN
	this.title = as_title + " - " + as_filename
END IF

lu_files = CREATE uo_fileservices
li_st = lu_files.uf_readfile(as_filename, ls_text)
DESTROY lu_files

IF li_st = 1 THEN
	mle_info.text = ls_text
	return(1)
ELSE
	gu_message.uf_error("Erreur de lecture du fichier " + as_filename + " !")
	return(-1)	
END IF

end function

on w_info.create
int iCurrent
call super::create
this.mle_info=create mle_info
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.mle_info
end on

on w_info.destroy
call super::destroy
destroy(this.mle_info)
end on

event resize;call super::resize;mle_info.height = newheight
mle_info.width = newwidth
end event

event ue_init_menu;call super::ue_init_menu;f_menuaction({"m_fermer"})
end event

event ue_open;call super::ue_open;f_centerInMdi(this)
end event

type mle_info from uo_mle within w_info
integer width = 2322
integer height = 1216
integer taborder = 10
boolean vscrollbar = true
boolean autovscroll = true
boolean displayonly = true
end type

