//objectcomments Affichage d'une image, avec ajustement des ascenseurs en fonction de la taille de l'image
forward
global type uo_carte from userobject
end type
type p_1 from uo_picture within uo_carte
end type
end forward

global type uo_carte from userobject
integer width = 1125
integer height = 764
boolean hscrollbar = true
boolean vscrollbar = true
long backcolor = 67108864
string text = "none"
long tabtextcolor = 33554432
long picturemaskcolor = 536870912
p_1 p_1
end type
global uo_carte uo_carte

forward prototypes
public subroutine uf_setpicture (blob ab_picture)
public subroutine uf_setpicturesize (integer ai_height, integer ai_width)
public subroutine uf_adjust ()
public subroutine uf_setoriginalpicturesize (boolean ab_originalsize)
public subroutine uf_setdisplaysize (integer ai_height, integer ai_width)
public subroutine uf_setpicture (string as_pic)
end prototypes

public subroutine uf_setpicture (blob ab_picture);// assigner directement un blob à l'image

// scroll to topmost position
Send(Handle(this), 277, 6, 0)
// scroll to leftmost position
Send(Handle(this), 276, 6, 0)

p_1.SetPicture(ab_picture)

uf_adjust()
end subroutine

public subroutine uf_setpicturesize (integer ai_height, integer ai_width);// dimensionne l'image aux dimensions passées en paramètre (en PBU)

// scroll to topmost position
Send(Handle(this), 277, 6, 0)
// scroll to leftmost position
Send(Handle(this), 276, 6, 0)

p_1.OriginalSize = FALSE
p_1.height = ai_height
p_1.width = ai_width

uf_adjust()

end subroutine

public subroutine uf_adjust ();this.vscrollbar = FALSE
this.hscrollbar = FALSE

// ajuster scrolling horizontal
IF This.Width < p_1.width THEN
	this.hscrollbar = TRUE
	This.UnitsPerColumn = p_1.width / 100
	This.ColumnsPerPage = (p_1.width / 4) / This.UnitsPerColumn
END IF
// ajuster scrolling vertical
IF This.Height < p_1.height THEN
	this.vscrollbar = TRUE
	This.UnitsPerLine = p_1.height / 100
	This.LinesPerPage = (p_1.height / 4) / This.UnitsPerLine
END IF


end subroutine

public subroutine uf_setoriginalpicturesize (boolean ab_originalsize);// rétablit l'image à sa dimension originale ou pas

// scroll to topmost position
Send(Handle(this), 277, 6, 0)
// scroll to leftmost position
Send(Handle(this), 276, 6, 0)

p_1.OriginalSize = ab_originalsize

uf_adjust()

end subroutine

public subroutine uf_setdisplaysize (integer ai_height, integer ai_width);// dimensionne l'objet d'affichage aux dimensions passées en paramètre (en PBU)
// (! ne redimensionne pas la dimension de l'image !)

// scroll to topmost position
Send(Handle(this), 277, 6, 0)
// scroll to leftmost position
Send(Handle(this), 276, 6, 0)

this.height = ai_height
this.width = ai_width
// recalcule la définition des scrollbars
uf_adjust()

end subroutine

public subroutine uf_setpicture (string as_pic);// spécifier le nom d'une image

// scroll to topmost position
Send(Handle(this), 277, 6, 0)
// scroll to leftmost position
Send(Handle(this), 276, 6, 0)

p_1.Setredraw(FALSE)
p_1.PictureName = ""
p_1.PictureName = as_pic
p_1.Setredraw(TRUE)

uf_adjust()
end subroutine

on uo_carte.create
this.p_1=create p_1
this.Control[]={this.p_1}
end on

on uo_carte.destroy
destroy(this.p_1)
end on

type p_1 from uo_picture within uo_carte
integer width = 622
integer height = 464
boolean border = true
end type

