﻿forward
global type pbdom_builder from nonvisualobject
end type
end forward

global type pbdom_builder from nonvisualobject native "PBDOM.pbx"
public function  pbdom_document BuildFromString(string strXMLString)
public function  pbdom_document BuildFromDataStore(datastore datastore_ref)
public function  pbdom_document BuildFromFile(string strURL)
public function  boolean		 GetParseErrors(ref string strErrorMessageArray[])
public subroutine  		 SetDisableEntityResolution(boolean bDisableEntityResolution)
end type
global pbdom_builder pbdom_builder

on pbdom_builder.create
call super::create
TriggerEvent( this, "constructor" )
end on

on pbdom_builder.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

