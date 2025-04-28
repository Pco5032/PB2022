forward
global type w_global from w_ancestor_global
end type
end forward

global type w_global from w_ancestor_global
end type
global w_global w_global

on w_global.create
call super::create
end on

on w_global.destroy
call super::destroy
end on

event ue_open;call super::ue_open;// variables globales propres à l'application
lb_1.AddItem("gs_nomAgent = " + gs_nomAgent)
lb_1.AddItem("gd_tthebdo = " + string(gd_tthebdo))
lb_1.AddItem("gi_tthebdo = " + string(gi_tthebdo))
lb_1.AddItem("gi_ttjour = " + string(gi_ttjour))
lb_1.AddItem("gi_pc_planning = " + string(gi_pc_planning))
lb_1.AddItem("gi_pc_realise = " + string(gi_pc_realise))
lb_1.AddItem("gs_langue = " + gs_langue)
lb_1.AddItem("gu_translate.ib_mustTranslate = " + string(gu_translate.uf_mustTranslate()))

end event

type lb_1 from w_ancestor_global`lb_1 within w_global
end type

