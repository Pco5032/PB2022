//objectcomments Encrypts and decrypts strings
forward
global type uo_encrypt from nonvisualobject
end type
end forward

global type uo_encrypt from nonvisualobject
end type
global uo_encrypt uo_encrypt

type variables
string is_raw, is_encrypted, is_key="CGI"


end variables

forward prototypes
public function STRING of_getraw ()
public function string of_decrypt (string thetext, string thekey)
public function string of_decrypt (string thestr)
public function string of_getencrypted ()
public function string of_setkey (string thekey)
public function string of_encrypt (string thestr)
public function string of_encrypt (string thetext, string thekey)
public function string uf_encrypt_aes (string as_data, string as_key)
public function string uf_decrypt_aes (string as_encrypteddata, string as_key)
end prototypes

public function STRING of_getraw ();return is_raw
end function

public function string of_decrypt (string thetext, string thekey);// Chagned input variable order to match documentation

of_setKey(theKey)
return of_decrypt(theText)
end function

public function string of_decrypt (string thestr);string retVal, tempStr, tStr
int sourcePtr, keyPtr, keyLen, sourceLen, tempVal, tempKey

is_encrypted = thestr

keyPtr = 1
keyLen = LenA(is_key)
// Fixed so that decryption is done on encrypted input string of proper length
//sourceLen = len(is_raw)
sourceLen = LenA(is_encrypted)
is_raw = ""
for sourcePtr = 1 to sourceLen
	tempVal = AscA(RightA(is_encrypted, LenA(is_encrypted) - sourcePtr + 1))
	tempKey = AscA(RightA(is_key, LenA(is_key) - keyPtr + 1))
	tempVal -= tempKey
	// Added this section to ensure that ASCII codes stay in 0 to 255 range
	DO WHILE tempVal < 0
		if tempVal < 0 then
			tempVal = tempVal + 255
		end if
	LOOP
	// end of section
	tStr = CharA(tempVal)
	is_raw += tStr
	keyPtr ++
	if keyPtr > LenA(is_key) then keyPtr = 1
next

retVal = is_raw

return retVal
end function

public function string of_getencrypted ();return is_encrypted
end function

public function string of_setkey (string thekey);string retVal
retVal = is_key
is_key = theKey
return retVal
end function

public function string of_encrypt (string thestr);string retVal, tempStr, tStr
int sourcePtr, keyPtr, keyLen, sourceLen, tempVal, tempKey

retVal = is_raw
is_raw = thestr

keyPtr = 1
keyLen = LenA(is_key)
sourceLen = LenA(is_raw)
is_encrypted = ""
for sourcePtr = 1 to sourceLen
	tempVal = AscA(RightA(is_raw, sourceLen - sourcePtr + 1))
	tempKey = AscA(RightA(is_key, keyLen - keyPtr + 1))
	tempVal += tempKey
	// Added this section to ensure that ASCII Values stay within 0 to 255 range
	DO WHILE tempVal > 255
		if tempVal > 255 then
			tempVal = tempVal - 255
		end if
	LOOP
	// End of Section
	tStr = CharA(tempVal)
	is_encrypted += tStr
	keyPtr ++
	if keyPtr > LenA(is_key) then keyPtr = 1
next

return is_encrypted
end function

public function string of_encrypt (string thetext, string thekey);of_setKey(theKey)
return of_encrypt(theText)
end function

public function string uf_encrypt_aes (string as_data, string as_key);// Cryptage AES
// as_data : données à crypter
// as_key : clé de cryptage. Doit faire 128,192 ou 256 bits.
// return string : données cryptées ou NULL si erreur
CrypterObject	lnv_CrypterObject
Coderobject		lnv_Coderobject
Blob				lblb_data, lblb_key, lblb_encrypt
string			ls_data
integer			li_keyLength

IF f_isEmptyString(as_data) THEN
	gu_message.uf_error("Cryptage de données", "La chaîne de caractère à crypter ne peut être vide")
	return(gu_c.s_null)
END IF

// fill crypt key with spaces so that it is 16 chars (128bits)
as_key = left(as_key + fill(" ", 15), 16)
li_keyLength = len(as_key) * 8
CHOOSE CASE li_keyLength
	CASE 128,192,256
	CASE ELSE
		gu_message.uf_error("Cryptage de données", "La clé de cryptage doit faire 128,192 ou 256 bits")
		return(gu_c.s_null)
END CHOOSE

lnv_CrypterObject = CREATE CrypterObject
lnv_Coderobject = CREATE coderobject

// convert strings to blob
lblb_data = Blob(as_data, EncodingUTF8!)
lblb_key = Blob(as_key, EncodingUTF8!)

// Encrypt blob
lblb_encrypt = lnv_CrypterObject.SymmetricEncrypt(AES!, lblb_data, lblb_key)

// Encode the SHA blob data to be hex data and output as a string
ls_data = lnv_Coderobject.hexencode(lblb_encrypt)

DESTROY lnv_CrypterObject
DESTROY lnv_Coderobject
return(ls_data)
end function

public function string uf_decrypt_aes (string as_encrypteddata, string as_key);CrypterObject	lnv_CrypterObject
Coderobject		lnv_Coderobject
Blob				lblb_data, lblb_key, lblb_decrypt
string			ls_data
integer			li_keyLength

IF f_isEmptyString(as_encrypteddata) THEN
	gu_message.uf_error("Cryptage de données", "La chaîne de caractère à décrypter ne peut être vide")
	return(gu_c.s_null)
END IF

// fill crypt key with spaces so that it is 16 chars (128bits)
as_key = left(as_key + fill(" ", 15), 16)
li_keyLength = len(as_key) * 8
CHOOSE CASE li_keyLength
	CASE 128,192,256
	CASE ELSE
		gu_message.uf_error("Cryptage de données", "La clé de cryptage doit faire 128,192 ou 256 bits")
		return(gu_c.s_null)
END CHOOSE

lnv_CrypterObject = CREATE CrypterObject
lnv_Coderobject = CREATE coderobject

// Decode hex data and output as blob
// Convert key string to blob
lblb_data = lnv_Coderobject.hexdecode(as_encrypteddata)
lblb_key = Blob(as_key, EncodingUTF8!)

// Decrypt blob
lblb_decrypt = lnv_CrypterObject.SymmetricDecrypt(AES!, lblb_data, lblb_key)

// convert blob to string
ls_data = string(lblb_decrypt, EncodingUTF8!)

DESTROY lnv_CrypterObject
DESTROY lnv_Coderobject

return(ls_data)
end function

on uo_encrypt.create
call super::create
TriggerEvent( this, "constructor" )
end on

on uo_encrypt.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

