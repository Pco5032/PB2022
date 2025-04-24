forward
global type w_crypt from w_ancestor
end type
type cb_3 from commandbutton within w_crypt
end type
type cb_2 from commandbutton within w_crypt
end type
type st_3 from uo_statictext within w_crypt
end type
type sle_key from uo_sle within w_crypt
end type
type cb_1 from uo_cb within w_crypt
end type
type cb_encrypt from uo_cb within w_crypt
end type
type st_2 from uo_statictext within w_crypt
end type
type st_1 from uo_statictext within w_crypt
end type
type sle_crypt from uo_sle within w_crypt
end type
type sle_data from uo_sle within w_crypt
end type
end forward

global type w_crypt from w_ancestor
integer width = 2053
integer height = 780
string title = "Encrypte - Décrypte"
cb_3 cb_3
cb_2 cb_2
st_3 st_3
sle_key sle_key
cb_1 cb_1
cb_encrypt cb_encrypt
st_2 st_2
st_1 st_1
sle_crypt sle_crypt
sle_data sle_data
end type
global w_crypt w_crypt

type variables
uo_encrypt	iu_encrypt
end variables

on w_crypt.create
int iCurrent
call super::create
this.cb_3=create cb_3
this.cb_2=create cb_2
this.st_3=create st_3
this.sle_key=create sle_key
this.cb_1=create cb_1
this.cb_encrypt=create cb_encrypt
this.st_2=create st_2
this.st_1=create st_1
this.sle_crypt=create sle_crypt
this.sle_data=create sle_data
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_3
this.Control[iCurrent+2]=this.cb_2
this.Control[iCurrent+3]=this.st_3
this.Control[iCurrent+4]=this.sle_key
this.Control[iCurrent+5]=this.cb_1
this.Control[iCurrent+6]=this.cb_encrypt
this.Control[iCurrent+7]=this.st_2
this.Control[iCurrent+8]=this.st_1
this.Control[iCurrent+9]=this.sle_crypt
this.Control[iCurrent+10]=this.sle_data
end on

on w_crypt.destroy
call super::destroy
destroy(this.cb_3)
destroy(this.cb_2)
destroy(this.st_3)
destroy(this.sle_key)
destroy(this.cb_1)
destroy(this.cb_encrypt)
destroy(this.st_2)
destroy(this.st_1)
destroy(this.sle_crypt)
destroy(this.sle_data)
end on

event ue_open;call super::ue_open;iu_encrypt = CREATE uo_encrypt

sle_key.text = gs_CryptKey

end event

event ue_close;call super::ue_close;DESTROY iu_encrypt
end event

type cb_3 from commandbutton within w_crypt
integer x = 969
integer y = 512
integer width = 805
integer height = 112
integer taborder = 30
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Decrypt AES CrypterObject"
end type

event clicked;string	ls_key

ls_key = sle_key.text
sle_data.text = iu_encrypt.uf_decrypt_aes(sle_crypt.text, ls_key)
end event

type cb_2 from commandbutton within w_crypt
integer x = 165
integer y = 512
integer width = 805
integer height = 112
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Encrypt AES CrypterObject"
end type

event clicked;string	ls_key

ls_key = sle_key.text
sle_crypt.text = iu_encrypt.uf_encrypt_aes(sle_data.text, ls_key)
end event

type st_3 from uo_statictext within w_crypt
integer x = 37
integer y = 176
integer textsize = -9
string text = "Key"
end type

type sle_key from uo_sle within w_crypt
integer x = 457
integer y = 168
integer width = 1499
integer height = 80
integer taborder = 20
integer textsize = -9
end type

type cb_1 from uo_cb within w_crypt
integer x = 969
integer y = 384
integer width = 805
string text = "Décrypte simple"
end type

event clicked;call super::clicked;sle_data.text = iu_encrypt.of_decrypt(sle_crypt.text, sle_key.text)
end event

type cb_encrypt from uo_cb within w_crypt
integer x = 165
integer y = 384
integer width = 805
string text = "Encrypte simple"
end type

event clicked;call super::clicked;sle_crypt.text = iu_encrypt.of_encrypt(sle_data.text, sle_key.text)
end event

type st_2 from uo_statictext within w_crypt
integer x = 37
integer y = 272
string text = "Valeur cryptée"
end type

type st_1 from uo_statictext within w_crypt
integer x = 37
integer y = 80
string text = "Valeur en clair"
end type

type sle_crypt from uo_sle within w_crypt
integer x = 457
integer y = 256
integer width = 1499
integer height = 80
integer taborder = 30
integer textsize = -9
end type

type sle_data from uo_sle within w_crypt
integer x = 457
integer y = 80
integer width = 1499
integer height = 80
integer taborder = 10
integer textsize = -9
end type

