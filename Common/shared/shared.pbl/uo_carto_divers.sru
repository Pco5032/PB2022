//objectcomments Carto : fonctions diverses
forward
global type uo_carto_divers from nonvisualobject
end type
end forward

global type uo_carto_divers from nonvisualobject
end type
global uo_carto_divers uo_carto_divers

forward prototypes
public function integer uf_initvar (string as_defsection, string as_section, ref str_params astr_params)
end prototypes

public function integer uf_initvar (string as_defsection, string as_section, ref str_params astr_params);/* lire variables dans le .INI et les renvoyer dans la structure passée en argument
(NB : lecture dans .INI global et ensuite dans .INI local pour pouvoir modifier
      dans ce dernier les valeurs spécifiées dans le 1er)

as_defsection : section où il faut lire les valeurs par défaut des différentes variables
as_section : section où il faut lire les valeurs différentes des valeurs par défaut
astr_params : contiendra les valeurs lûes pour les différentes variables */

string		ls_prefixe
integer		li_dumpwidth, li_dumpheight
str_params	lstr_params_alias

// au moins 1 des 2 arguments as_defsection et as_section doit être fourni
IF f_IsEmptyString(as_defsection) AND f_IsEmptyString(as_section) THEN
	gu_message.uf_error("Aucun nom de section n'est spécifié")
	return(-1)
END IF

// I. lecture dans fichier .INI global
// 1. lecture des valeurs par défaut pour chaque variable (quand il existe une valeur par défaut)
IF NOT f_IsEmptyString(as_defsection) THEN
	// dimension carte
	li_dumpwidth = integer(ProfileString(gs_inifile, as_defsection, "larg_carte", "3250"))
	li_dumpheight = integer(ProfileString(gs_inifile, as_defsection, "haut_carte", "3700"))
END IF

// 2. lecture des valeurs différentes du défaut pour chaque variable
IF NOT f_IsEmptyString(as_section) THEN
	// dimension carte
	li_dumpwidth = integer(ProfileString(gs_inifile, as_section, "larg_carte", f_string(li_dumpwidth)))
	li_dumpheight = integer(ProfileString(gs_inifile, as_section, "haut_carte", f_string(li_dumpheight)))
	// préfixe (valeur de la colonne TYPE de la table IMAGE_MAPS)
	ls_prefixe = ProfileString(gs_inifile, as_section, "prefixe", ls_prefixe)
END IF	

// II. lecture dans fichier .INI local ou service. Si le paramètre cherché ne s'y trouve pas, on utilise
//     la valeur lûe avant dans le .INI global.
// 1. lecture des valeurs par défaut pour chaque variable
IF NOT f_IsEmptyString(as_defsection) THEN
	// dimension carte
	li_dumpwidth = integer(ProfileString(gs_locinifile, as_defsection, "larg_carte", f_string(li_dumpwidth)))
	li_dumpheight = integer(ProfileString(gs_locinifile, as_defsection, "haut_carte", f_string(li_dumpheight)))
	// préfixe (valeur de la colonne TYPE de la table IMAGE_MAPS)
	ls_prefixe = ProfileString(gs_locinifile, as_defsection, "prefixe", ls_prefixe)
END IF

// 2. lecture des valeurs différentes du défaut pour chaque variable
IF NOT f_IsEmptyString(as_section) THEN
	// dimension carte
	li_dumpwidth = integer(ProfileString(gs_locinifile, as_section, "larg_carte", f_string(li_dumpwidth)))
	li_dumpheight = integer(ProfileString(gs_locinifile, as_section, "haut_carte", f_string(li_dumpheight)))
	// préfixe (valeur de la colonne TYPE de la table IMAGE_MAPS)
	ls_prefixe = ProfileString(gs_locinifile, as_section, "prefixe", ls_prefixe)
END IF

// garnir structure résultat
astr_params.a_param[1] = li_dumpwidth
astr_params.a_param[2] = li_dumpheight
astr_params.a_param[3] = ls_prefixe

return(1)
end function

on uo_carto_divers.create
call super::create
TriggerEvent( this, "constructor" )
end on

on uo_carto_divers.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

