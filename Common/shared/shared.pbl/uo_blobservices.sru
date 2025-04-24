//objectcomments Fonctions liées à les gestion d'objets BLOB et d'images stockées dans la table IMAGE
forward
global type uo_blobservices from nonvisualobject
end type
end forward

global type uo_blobservices from nonvisualobject
end type
global uo_blobservices uo_blobservices

type variables
// Table contenant les blobs
string	is_tableVersion	// I=IMAGE, M=IMAGE_MAPS
end variables

forward prototypes
public function integer uf_readimage (ref blob ab_data, string as_type, string as_cle)
public function integer uf_export (blob ab_data, string as_filename)
public function integer uf_export (blob ab_data, string as_filename, boolean ab_msg)
public function integer uf_readimage (ref blob ab_data, string as_type, string as_cle, boolean ab_msg)
public function string uf_settableversion (string as_tableversion)
public function integer uf_readandexport (string as_type, string as_cle, ref string as_filename, boolean ab_msg, transaction atr_transact)
public function integer uf_readandexport (string as_type, string as_cle, ref string as_filename, boolean ab_msg)
end prototypes

public function integer uf_readimage (ref blob ab_data, string as_type, string as_cle);// lire image si elle existe dans la DB (blob) et affiche les messages
return(uf_readimage(ab_data, as_type, as_cle, TRUE))
end function

public function integer uf_export (blob ab_data, string as_filename);// créer un fichier sur base du blob passé en argument
// afficher les messages
return(uf_Export(ab_data, as_filename, TRUE))
end function

public function integer uf_export (blob ab_data, string as_filename, boolean ab_msg);// créer un fichier sur base du blob passé en argument
// ab_data = blob qui doit servir à créer le fichier
// as_filename = nom du fichier à créer
// ab_msg = afficher message si TRUE, ne pas les afficher si FALSE
uo_fileservices	lu_fs

SetPointer(Hourglass!)

// PCO 31/01/2020 : NSI utilise le "/" comme séparateur dans les colonnes CLE, ce qui est incompatible avec un filename
as_filename = gu_stringServices.uf_replaceall(as_filename, "/", "_")

lu_fs = CREATE uo_fileservices

IF lu_fs.uf_writefile(ab_data, as_filename, replace!) < 0 THEN
	IF ab_msg THEN gu_message.uf_error("Erreur de création du fichier " + as_filename)
	DESTROY lu_fs
	return(-1)
ELSE
	IF ab_msg THEN gu_message.uf_info("Le fichier " + as_filename + " a été créé")
	DESTROY lu_fs
	return(1)
END IF

end function

public function integer uf_readimage (ref blob ab_data, string as_type, string as_cle, boolean ab_msg);// lire image si elle existe dans la DB (blob)
// ab_data = blob garni avec les données lûes si l'image existe
// as_type = type d'image à lire dans table IMAGE
// as_cle = n° d'identification de l'image
// ab_msg = afficher message si TRUE, ne pas les afficher si FALSE
// return(1) si OK
// return(-1) si erreur
blob	lb_1
long	ll_count

SetPointer(Hourglass!)

as_type = upper(as_type)
as_cle = upper(as_cle)
CHOOSE CASE is_tableVersion
	CASE "M"
		select count(*) into :ll_count from user_objects where object_name='IMAGE_MAPS' using ESQLCA;
		IF ll_count = 0 THEN 
			return(-1)
		ELSE
			SELECTBLOB image INTO :lb_1 FROM image_maps where type=:as_type and cle=:as_cle USING ESQLCA;
		END IF
	CASE ELSE
		select count(*) into :ll_count from user_objects where object_name='IMAGE' using ESQLCA;
		IF ll_count = 0 THEN 
			return(-1)
		ELSE
			SELECTBLOB image INTO :lb_1 FROM image where type=:as_type and cle=:as_cle USING ESQLCA;
		END IF
END CHOOSE

IF f_check_sql(ESQLCA) = 0 THEN
	ab_data = lb_1
	return(1)
ELSE
	IF ab_msg THEN gu_message.uf_info("Le fichier n'est pas stocké dans la base de données")
	return(-1)
END IF
end function

public function string uf_settableversion (string as_tableversion);CHOOSE CASE as_tableVersion
	CASE "M"
		is_tableVersion = "M"
	CASE ELSE
		is_tableVersion = "I"
END CHOOSE
return(is_tableVersion)
end function

public function integer uf_readandexport (string as_type, string as_cle, ref string as_filename, boolean ab_msg, transaction atr_transact);// lire image si elle existe dans la DB (blob) et créer un fichier
// as_type = type d'image à lire dans table IMAGE
// as_cle = n° d'identification de l'image
// as_filename = nom du fichier a créer
// PCO 23/05/2023 : 
//		- si la table est IMAGE_MAPS, ou si le nom de fichier contient une extension, on génère le fichier avec celle-ci.
//		- si la table est IMAGE et que le nom de fichier ne contient pas d'extension, on utilise celle stockée dans IMAGE (ou jpg si NULL)
//		- as_filename est passée par REF car l'extension est susceptible d'avoir été ajoutée au cours du présent traitement.
// ab_msg = afficher message si TRUE, ne pas les afficher si FALSE
// not default transaction object
uo_fileservices	lu_fs
blob		lb_1
long		ll_count
string	ls_path, ls_basename, ls_ext, ls_image_ext

SetPointer(Hourglass!)

// PCO 31/01/2020 : NSI utilise le "/" comme séparateur dans les colonnes CLE, ce qui est incompatible avec un filename
as_filename = gu_stringServices.uf_replaceall(as_filename, "/", "_")

filedelete(as_filename)

lu_fs = CREATE uo_fileservices

// sera nécessaire pour vérifier plus loin si le nom de fichier contient une extension
lu_fs.uf_basename(as_filename, FALSE, ls_path, ls_basename, ls_ext)

as_type = upper(as_type)
as_cle = upper(as_cle)
CHOOSE CASE is_tableVersion
	CASE "M"
		select count(*) into :ll_count from user_objects where object_name='IMAGE_MAPS' using atr_transact;
		IF ll_count = 0 THEN 
			return(-1)
		ELSE
			SELECTBLOB image INTO :lb_1 FROM image_maps where type=:as_type and cle=:as_cle USING atr_transact;
		END IF
	CASE ELSE
		select count(*) into :ll_count from user_objects where object_name='IMAGE' using atr_transact;
		IF ll_count = 0 THEN 
			return(-1)
		ELSE
			SELECTBLOB image INTO :lb_1 FROM image where type=:as_type and cle=:as_cle USING atr_transact;
			IF atr_transact.sqlcode = 0 THEN
				SELECT ext INTO :ls_image_ext FROM image where type=:as_type and cle=:as_cle USING atr_transact;
			END IF
			// si pas d'extension fournie dans le nom de fichier et qu'il en existe dans IMAGE, on l'utilise.
			IF f_isEmptyString(ls_ext) THEN
				IF f_isEmptyString(ls_image_ext) THEN
					as_filename = as_filename + "." + ls_image_ext + ".jpg"
				ELSE
					as_filename = as_filename + "." + ls_image_ext
				END IF
			END IF
		END IF
END CHOOSE
IF f_check_sql(atr_transact) = 0 THEN
	IF lu_fs.uf_writefile(lb_1, as_filename, replace!) < 0 THEN
		IF ab_msg THEN gu_message.uf_error("Erreur de création du fichier " + as_filename)
		DESTROY lu_fs
		return(-1)
	ELSE
		IF ab_msg THEN gu_message.uf_info("Le fichier " + as_filename + " a été créé")
		DESTROY lu_fs
		return(1)
	END IF
ELSE
	IF ab_msg THEN gu_message.uf_info("Le fichier n'est pas stocké dans la base de données")
	DESTROY lu_fs
	return(-1)
END IF
end function

public function integer uf_readandexport (string as_type, string as_cle, ref string as_filename, boolean ab_msg);// lire image si elle existe dans la DB (blob) et créer un .jpg 
// default transaction object (ESQLCA)
return(uf_ReadAndExport(as_type, as_cle, as_filename, ab_msg, ESQLCA))
end function

on uo_blobservices.create
call super::create
TriggerEvent( this, "constructor" )
end on

on uo_blobservices.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

