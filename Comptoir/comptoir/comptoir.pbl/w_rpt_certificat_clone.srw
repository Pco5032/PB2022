//objectcomments Impression des documents d'identification des mélanges clonaux
forward
global type w_rpt_certificat_clone from w_ancestor_rptpreview
end type
end forward

global type w_rpt_certificat_clone from w_ancestor_rptpreview
string title = "Certificats-maîtres : mélanges clonaux"
end type
global w_rpt_certificat_clone w_rpt_certificat_clone

type variables
integer	ii_choix
end variables

on w_rpt_certificat_clone.create
call super::create
end on

on w_rpt_certificat_clone.destroy
call super::destroy
end on

event ue_init;call super::ue_init;// attribuer un nom de modèle
wf_setmodel("CM_CLONE")

// effacer les anciens critères par défaut et en établir de nouveaux
wf_ResetDefaults()
wf_setDefault("certificat.num_cm","=")

end event

event ue_retrieve;call super::ue_retrieve;long	ll_rows

ll_rows = AncestorReturnValue

IF ll_rows <= 0 THEN 
	gu_message.uf_info("Aucun certificat ne correspond à votre requête")
	return(ll_rows)
END IF

return(ll_rows)
end event

type cb_defaults from w_ancestor_rptpreview`cb_defaults within w_rpt_certificat_clone
end type

type st_2 from w_ancestor_rptpreview`st_2 within w_rpt_certificat_clone
end type

type st_1 from w_ancestor_rptpreview`st_1 within w_rpt_certificat_clone
end type

type dw_papersize from w_ancestor_rptpreview`dw_papersize within w_rpt_certificat_clone
end type

type cb_next from w_ancestor_rptpreview`cb_next within w_rpt_certificat_clone
end type

type cb_prev from w_ancestor_rptpreview`cb_prev within w_rpt_certificat_clone
end type

type dw_1 from w_ancestor_rptpreview`dw_1 within w_rpt_certificat_clone
string dataobject = "d_rpt_certificat_clone"
end type

type em_zoom from w_ancestor_rptpreview`em_zoom within w_rpt_certificat_clone
end type

type st_zoom from w_ancestor_rptpreview`st_zoom within w_rpt_certificat_clone
end type

type gb_1 from w_ancestor_rptpreview`gb_1 within w_rpt_certificat_clone
end type

type dw_paperorient from w_ancestor_rptpreview`dw_paperorient within w_rpt_certificat_clone
end type

