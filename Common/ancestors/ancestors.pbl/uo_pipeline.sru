forward
global type uo_pipeline from pipeline
end type
end forward

global type uo_pipeline from pipeline
end type
global uo_pipeline uo_pipeline

on uo_pipeline.create
call super::create
TriggerEvent( this, "constructor" )
end on

on uo_pipeline.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

