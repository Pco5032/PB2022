forward
global type uo_publipostage from nonvisualobject
end type
end forward

global type uo_publipostage from nonvisualobject
end type
global uo_publipostage uo_publipostage

type variables
string	is_target
string	is_saveAsExt
integer	ii_saveAsFormat
boolean	ib_saveAs
boolean	ib_keepWord

end variables

forward prototypes
public subroutine uf_init_params (string as_target)
public subroutine uf_get_params (ref boolean ab_saveas, ref integer ai_saveasformat, ref string as_saveasext, ref boolean ab_keepword)
public subroutine uf_store_params (string as_target, ref integer ai_saveasformat, ref boolean ab_keepword)
private subroutine uf_validate_format (integer ai_saveasformat)
public function integer uf_choose_params ()
public function integer uf_get_picture (string as_supergroup, string as_typeimage, string as_cleimage, ref string as_picturefilename)
public function integer uf_publipostage (string as_document_principal, string as_ordre_sql, string as_type_action, string as_type_document, boolean ab_word_visible, string as_saveas_foldername, string as_saveas_filename, integer ai_saveas_format)
public function integer uf_publipostage (string as_document_principal, string as_ordre_sql)
end prototypes

public subroutine uf_init_params (string as_target);// initialisation des variables sur base des paramètres de l'utilisateur en cours pour le type de document voulu
// as_target : type de document. Correspond à une section dans le .INI local.	Exemple : BALISAGE.
// Si as_target n'est pas fourni ou  n'est pas encore dans le .ini, utilisation de paramètres par défaut :
//		ib_saveAs = FALSE
//		ib_keepWord = FALSE
integer	li_saveAsFormat

IF f_isEmptyString(as_target) THEN
	ib_saveAs = FALSE
	ib_keepWord = TRUE
	return
END IF

li_saveAsFormat = profileInt(gs_locinifile, gs_userName, as_target + "_PUBLIPOSTAGE_SAVEASFORMAT", 0)
uf_validate_format(li_saveAsFormat)

IF upper(profileString(gs_locinifile, gs_userName, as_target + "_PUBLIPOSTAGE_KEEPWORD", "TRUE")) = "TRUE" THEN
	ib_keepWord = TRUE
ELSE
	ib_keepWord = FALSE
END IF

end subroutine

public subroutine uf_get_params (ref boolean ab_saveas, ref integer ai_saveasformat, ref string as_saveasext, ref boolean ab_keepword);// renvoie les variables contenant les paramètres de publipostage
ab_saveAs = ib_saveAs
ai_saveAsFormat = ii_saveAsFormat
as_saveAsExt = is_saveAsExt
ab_keepWord = ib_keepWord

end subroutine

public subroutine uf_store_params (string as_target, ref integer ai_saveasformat, ref boolean ab_keepword);// stocker paramètres personnels de publipostage pour le target choisi
setProfileString(gs_locinifile, gs_userName, as_target + "_PUBLIPOSTAGE_SAVEASFORMAT", string(ai_saveAsFormat))
setProfileString(gs_locinifile, gs_userName, as_target + "_PUBLIPOSTAGE_KEEPWORD", string(ab_keepWord))

end subroutine

private subroutine uf_validate_format (integer ai_saveasformat);// vérifie validité du format d'enregistrement et détermine l'extension de fichier en conséquence
CHOOSE CASE ai_saveAsFormat
	CASE 16
		ii_saveasformat = ai_saveasformat
		is_saveAsExt = "docx"
		ib_saveAs = TRUE
	CASE 17
		ii_saveasformat = ai_saveasformat
		is_saveAsExt = "pdf"
		ib_saveAs = TRUE
	CASE ELSE
		ii_saveasformat = 0
		is_saveAsExt = ""
		ib_saveAs = FALSE
END CHOOSE

end subroutine

public function integer uf_choose_params ();// Affiche l'écran de choix des paramètres de publipostage.
// Les paramètres choisis remplacent les paramètres actuels. Le programme appelant devra utiliser uf_get_params()
// pour récupérer les nouvelles valeurs.
// return(1) si on abandonne la sélection.
str_params	lstr_params
integer		li_saveAsFormat

lstr_params.a_param[1] = ii_saveAsFormat
lstr_params.a_param[2] = ib_keepWord

openWithParm(w_publipostage_params, lstr_params)

IF Message.DoubleParm = -1 THEN 
	return(-1)
ELSE
	lstr_params=Message.PowerObjectParm
	li_saveAsFormat = lstr_params.a_param[1]
	uf_validate_format(li_saveAsFormat)

	IF lstr_params.a_param[2] = "O" THEN 
		ib_keepWord = TRUE
	ELSE
		ib_keepWord = FALSE
	END IF
	return(1)
END IF


end function

public function integer uf_get_picture (string as_supergroup, string as_typeimage, string as_cleimage, ref string as_picturefilename);// as_superGroup : vérifier dans ce groupe si l'utilisateur a accès à la signature ou pas
// 			Exemple : membre du super-groupe SIGNATURE_CC donne accès aux signatures des chefs de cantonnement
// as_typeImage : catégorie dans la table IMAGE
// as_cleImage : identifiant unique du blob dans la catégorie as_typeImage
// as_pictureFileName : renvoie le nom du fichier image généré (actuellement JPG only)
//
// Utilisation du fichier image : la requête doit mentionner le nom du fichier JPG contenant la signature.
// Attention : pour le publipostage de l'image, le path doit contenir des double-backslash.
//		as_pictureFilename = gu_stringservices.uf_replaceall(as_pictureFilename, "\", "\\")
// ls_sql = "select nom, '" + ls_tmpfiles ' as signature_path from agent where matricule=...
uo_blobservices	lu_blob
boolean	lb_Acces
string	ls_generatedFilename

lu_blob = CREATE uo_blobservices

// utilisation de la table IMAGE
lu_blob.uf_settableversion("I")

// Nom du fichier image à générer (sans l'extension qui sera complétée en fonction du type de fichier par 'lu_blob.uf_ReadAndExport')
ls_generatedFilename = gs_tmpFiles + "\" + as_typeimage + string(gd_session)

// vérifier si l'utilisateur fait partie du groupe donnant accès à la signature
lb_Acces = gu_privs.uf_super(as_supergroup)

// Accès image autorisé : l'exporter dans un fichier
IF lb_Acces THEN 
	IF lu_blob.uf_ReadAndExport(as_typeImage, as_cleImage, ls_generatedFilename, FALSE) = 1 THEN
		DESTROY lu_blob
		// attention : pour le publipostage de l'image, le path doit contenir des double-backslash
		as_pictureFilename = gu_stringservices.uf_replaceall(ls_generatedFilename, "\", "\\")
		return(1)
	END IF
END IF

// Si on arrive ici, c'est que accès image non autorisé ou blob n'existe pas : renvoyer -1 et nom de fichier vide
as_pictureFilename = ""
DESTROY lu_blob
return(-1)
end function

public function integer uf_publipostage (string as_document_principal, string as_ordre_sql, string as_type_action, string as_type_document, boolean ab_word_visible, string as_saveas_foldername, string as_saveas_filename, integer ai_saveas_format);// Remplace f_fusion_word (string as_document_principal, string as_ordre_sql, string as_connect_odbc, string as_type_action, string as_type_document, boolean ab_word_visible )
// publipostage effectué dans WORD via OLE2
// return(-1) en cas d'erreur
// return(1) si OK
// return(2) si OK avec saveAs
//
// as_Document_Principal : nom du document principal de fusion
// as_Ordre_SQL : ordre SQL
// ATTENTION : la longueur maxi de la requête est de 510 caractères !
// as_Type_Action : 	F = seulement fusionner (le paramètre ab_Word_Visible sera d'office considéré comme true)
//							I = fusionner et imprimer
//							S = fusionner et enregistrerSous (les arguments as_saveas_filename et ai_saveas_format doivent être fournis)
//							P = fusionner et prévisualiser (le paramètre ab_Word_Visible sera d'office considéré comme true)
// as_Type_Document : 	L = Lettres types
//								T = Etiquettes de publipostage
//								E = Enveloppes
//								C = Catalogues
// ab_Word_visible :	True = Word sera visible et ne sera pas fermé en fin de traitement
//							False = Word sera invisible et sera fermé en fin de traitement
// as_saveas_foldername : nom du dossier si on demande d'enregistrer le résultat du publipostage.
// as_saveas_filename : nom du fichier si on demande d'enregistrer le résultat du publipostage.
//								NB : les caractères non autorisés sont automatiquement supprimés : \/:*?"<>|
// ai_saveAs_format : format d'enregistrement du fichier. Constante WdSaveFormat (17=PDF, 16=DOCX). Voir https://learn.microsoft.com/fr-fr/office/vba/api/word.wdsaveformat.

// PCO juin 2013 : suite migration des bases de données vers Oracle XE et utilisation de datatypes Oracle en mode
//                 "char" au lieu de "byte" dans les VARCHAR2 et CHAR, la fusion ne fonctionne plus, des données
//                 vides sont renvoyées.
//                 Pour contourner ce problème, je crée un fichier xls qui va servir de source de données à WORD
//                 au lieu de demander à WORD d'aller chercher les données directement dans Oracle par ODBC.
//                 L'ancien code est conservé en commentaire en bas de fonction.
// nouveau code juin 2013 : datasource = fichier .xls 

// PCO 20/10/2022 : possibilité d'enregistrer le fichier. 2 arguments supplémentaires --> nouvelle fonction.
OLEObject	lole_Word, lole_doc
integer		li_Type_Document, result, n, li_rc
string		ls_syntax, ls_err, ls_DSfilename, ls_saveAsFullname
long			ll_retrieve
boolean		lb_saveAsSuccedded, lb_oleError
uo_ds			l_ds

// nom du fichier qui contiendra les données
ls_DSfilename = gs_tmpfiles + "\datasource.xlsx" 

// vérification des arguments
IF as_Document_Principal = "" THEN
	gu_message.uf_error("Le nom du document principal de fusion doit être spécifié")
	return(-1)
END IF

IF NOT FileExists(as_Document_Principal) THEN
	gu_message.uf_error("Le document principal de fusion (" + as_Document_Principal + ") n'existe pas")
	return(-1)
END IF

IF as_Ordre_SQL = "" THEN
	gu_message.uf_error("La requête SQL doit être spécifiée")
	return(-1)
END IF

as_Type_Action = upper(as_Type_Action)
as_Type_Document = upper(as_Type_Document)

IF as_Type_Action <> "F" AND as_Type_Action <> "I" AND as_Type_Action <> "P" AND as_Type_Action <> "S" THEN
	gu_message.uf_error("Le type d'action spécifié est incorrect : " + as_Type_Action + &
							  "~nChoix possibles : F(usionner seulement)/I(fusionner et Imprimer)/P(fusionner et prévisualiser)/S(fusionner et Sauver sous)")
	return(-1)
END IF

IF as_Type_Action = "S" THEN
	IF f_isEmptyString(as_saveas_foldername) OR f_isEmptyString(as_saveas_filename) OR isNull(ai_saveas_format) THEN
		gu_message.uf_error("L'action 'Enregistrer Sous' a été demandée. En conséquence, le nom du dossier et du fichier ainsi que son format doivent être spécifiés.")
		return(-1)
	END IF
END IF

// conversion des arguments
IF as_Type_Action = "F" OR as_Type_Action = "P" THEN
	ab_Word_Visible = True
END IF

CHOOSE CASE as_Type_Document
	CASE "L"
		li_Type_Document = 0
	CASE "T"
		li_Type_Document = 1
	CASE "E"
		li_Type_Document = 2
	CASE "C"
		li_Type_Document = 3
	CASE ""
		li_Type_Document = 3
	CASE ELSE
		gu_message.uf_error("Le type de document résultat est incorrect : " + as_Type_Document + &
								  "~nChoix possibles : L/T/E/C")
		return(-1)
END CHOOSE

// création d'une syntaxe pour créer un DS sur base de la requête SQL
ls_syntax = SQLCA.syntaxfromsql (as_Ordre_SQL, "", ls_err)
IF LenA(ls_err) > 0 THEN
	populateError(20000,"")
	gu_message.uf_unexp("Erreur SyntaxFromSQL : " + ls_err)
	return(-1)
END IF

// création du DS
l_ds = create uo_ds
l_ds.Create(ls_Syntax, ls_err)
IF LenA(ls_err) > 0 THEN
	DESTROY l_ds
	populateError(20000,"")
	gu_message.uf_unexp("Erreur Create Datastore : " + ls_err)
	return(-1)
END IF
l_ds.SetTransObject(SQLCA)

// lecture des données dans le DS
ll_retrieve = l_ds.retrieve()
IF ll_retrieve <= 0 THEN
	destroy l_ds
	gu_message.uf_info("Aucune donnée à fusionner (" + f_string(ll_retrieve) + ")  !")
	return(-1)
END IF

// sauver les données du DS dans un fichier .xls
li_rc = l_ds.saveas(ls_DSfilename, xlsx!, true)
IF li_rc = -1 THEN
	destroy l_ds
	populateError(20000,"")
	gu_message.uf_unexp("Erreur SaveAs .xlsx in " + ls_DSfilename)
	return(-1)
END IF
destroy l_ds

// démarrer Word et le rendre visible
lole_word = create oleobject
result = lole_word.ConnectToNewObject("word.application")
if result <> 0 then
	destroy lole_word
	gu_message.uf_error("OLE ERROR : unable to connect to MS-WORD",string(result))
	return(-1)
end if
lole_word.visible = ab_Word_Visible

TRY
	// ouvrir le document et le convertir vers le type choisi
	lole_doc = lole_word.documents.open(as_Document_Principal)
	lole_doc.MailMerge.MainDocumentType = li_Type_Document

	// ouvrir la source de données (fichier xls)
	lole_doc.MailMerge.OpenDataSource(ls_DSfilename, 0, False, True, False, False, "", "", False, "", "", "", &
												 "select * from [datasource$]", "", false, 0)

	/* void OpenDataSource(string Name, ref Object Format,ref Object ConfirmConversions,ref Object ReadOnly,
		ref Object LinkToSource,ref Object AddToRecentFiles,ref Object PasswordDocument,ref Object PasswordTemplate,
		ref Object Revert,ref Object WritePasswordDocument,ref Object WritePasswordTemplate,ref Object Connection,
		ref Object SQLStatement,ref Object SQLStatement1,ref Object OpenExclusive,ref Object SubType)
	*/

	// choix de la destination du document final
	lole_doc.MailMerge.Destination=0

	// GO
	lole_doc.MailMerge.Execute

	// fermer document d'origine
	lole_doc.close(0)

	// changer variable pour pointer vers document résultat
	lole_doc = lole_word.ActiveDocument

	// update peut-être nécessaire pour les champs INCLUDEPICTURE
	// lole_doc.Fields.Update
	// messagebox("", string(lole_doc.Fields.count))

	// imprimer si demandé
	IF as_Type_Action = "I" THEN
		lole_doc.PrintOut(false)
	END IF
CATCH (oleruntimeerror oleErr2)
	gu_message.uf_error("Publipostage OLE ERROR ", f_string(oleErr2.GetMessage()))
	lb_oleError = TRUE
END TRY

IF lb_oleError THEN
	destroy lole_word
	destroy lole_doc
	return(-1)
END IF

// saveAs si demandé (as_Type_Action="S")
setNull(lb_saveAsSuccedded)
IF as_Type_Action = "S" THEN
	// les caractères non autorisés sont supprimés : \/:*?"<>|
	as_saveas_filename = gu_stringServices.uf_replaceall(as_saveas_filename, &
								{'\', '/', ':', '*', '?', '"', '<', '>', '|'}, {'','','','','','','','',''})
	ls_saveAsFullname = as_saveas_foldername + "\" + as_saveas_filename
	fileDelete(ls_saveAsFullname)
	TRY
		lole_doc.SaveAs(ls_saveAsFullname, ai_saveAs_format)
	CATCH (oleruntimeerror oleErr)
		lb_saveAsSuccedded = FALSE
		gu_message.uf_error("Error SaveAs PDF : ", f_string(oleErr.GetMessage()))
	END TRY
	// vérifier que le fichier a bien été créé
	IF fileExists(ls_saveAsFullname) THEN
		lb_saveAsSuccedded = TRUE
	ELSE
		lb_saveAsSuccedded = FALSE
	END IF
END IF

// si WORD ne doit pas être visible, on ferme tout sinon on laisse ouvert
IF NOT ab_Word_visible THEN
	lole_word.documents.close(0)
	lole_word.Quit(0)
END IF

DESTROY lole_word
DESTROY lole_doc
IF isNull(lb_saveAsSuccedded) THEN
	return(1)
ELSE
	IF lb_saveAsSuccedded THEN
		return(2)
	ELSE
		return(-1)
	END IF
END IF

end function

public function integer uf_publipostage (string as_document_principal, string as_ordre_sql);// Remplace f_fusion_word (string as_document_principal, string as_ordre_sql, string as_connect_odbc, string as_type_action, string as_type_document, boolean ab_word_visible )
//
// Publipostage effectué dans WORD via OLE2
// return(-1) en cas d'erreur
// return(1) si OK
// return(2) si OK avec saveAs
//
// as_Document_Principal : nom du document principal de fusion
// as_Ordre_SQL : ordre SQL
// ATTENTION : la longueur maxi de la requête est de 510 caractères !


// Paramètres utilisés par défaut :
// as_Type_Document : C = Catalogues
// as_Type_Action : P = fusionner et prévisualiser
// as_saveas_foldername, as_saveas_filename : vides car as_Type_Action vaut toujours F
// ai_saveAs_format : null
// ab_word_visible : inutile car d'office TRUE avec type action="P"

return(this.uf_publipostage(as_document_principal, as_ordre_sql, "P", "C", TRUE, "", "", gu_c.i_null))

end function

on uo_publipostage.create
call super::create
TriggerEvent( this, "constructor" )
end on

on uo_publipostage.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

event constructor;// valeurs par défaut :
// Pas d'enregistrement du résultat du publipostage.
// Word reste ouvert et montre le résultat du publipostage.
ib_saveAs = FALSE
ii_saveAsFormat = 0
ib_keepWord = TRUE

end event

