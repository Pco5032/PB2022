forward
global type uo_message from nonvisualobject
end type
end forward

global type uo_message from nonvisualobject
end type
global uo_message uo_message

type variables
string	is_ErrorDefaultTitle = "ERREUR", is_InfoDefaultTitle = "Information"
end variables

forward prototypes
public function integer uf_error (string as_message, icon a_icone)
public function integer uf_error (string as_titre, string as_message)
public function integer uf_query (string as_message)
public function integer uf_query (string as_message, integer ai_default)
public function integer uf_info (string as_message, icon a_icone)
public function integer uf_info (string as_titre, string as_message)
public function integer uf_info (string as_message)
public function integer uf_query (string as_message, button a_button, integer ai_default)
public function integer uf_query (string as_titre, string as_message, integer ai_default)
public function integer uf_query (string as_titre, string as_message, button a_button, integer ai_default)
public function integer uf_error (string as_titre, string as_message, icon a_icone)
public function integer uf_info (string as_titre, string as_message, icon a_icone)
public function integer uf_unexp ()
public function integer uf_unexp (string as_message, integer ai_severity)
public function integer uf_error (string as_message)
public function integer uf_unexp (string as_message, integer ai_severity, boolean ab_detail, integer ai_button)
public function integer uf_unexp (integer ai_severity)
public function integer uf_unexp (string as_message)
end prototypes

public function integer uf_error (string as_message, icon a_icone);return(uf_error(is_ErrorDefaultTitle,as_message,a_icone))

end function

public function integer uf_error (string as_titre, string as_message);return(uf_error(as_titre,as_message,Exclamation!))

end function

public function integer uf_query (string as_message);return(uf_query("Question",as_message,YesNo!,1))

end function

public function integer uf_query (string as_message, integer ai_default);return(uf_query("Question",as_message,YesNo!,ai_default))

end function

public function integer uf_info (string as_message, icon a_icone);return(uf_info(is_infodefaulttitle,as_message,a_icone))

end function

public function integer uf_info (string as_titre, string as_message);return(uf_info(as_titre,as_message,information!))
end function

public function integer uf_info (string as_message);return(uf_info(is_infodefaulttitle,as_message,Information!))

end function

public function integer uf_query (string as_message, button a_button, integer ai_default);return(uf_query("Question",as_message,a_button,ai_default))

end function

public function integer uf_query (string as_titre, string as_message, integer ai_default);return(uf_query(as_titre,as_message,YesNo!,ai_default))

end function

public function integer uf_query (string as_titre, string as_message, button a_button, integer ai_default);return(MessageBox(f_string(as_titre), f_string(as_message),Question!,a_button,ai_default))

end function

public function integer uf_error (string as_titre, string as_message, icon a_icone);return(MessageBox(f_string(as_titre), f_string(as_message),a_icone))

end function

public function integer uf_info (string as_titre, string as_message, icon a_icone);return(MessageBox(f_string(as_titre), f_string(as_message),a_icone))

end function

public function integer uf_unexp ();return(uf_unexp("",3,FALSE,1))

end function

public function integer uf_unexp (string as_message, integer ai_severity);return(uf_unexp(as_message, ai_severity, FALSE, 1))


end function

public function integer uf_error (string as_message);return(uf_error(is_ErrorDefaulttitle,as_message,Exclamation!))

end function

public function integer uf_unexp (string as_message, integer ai_severity, boolean ab_detail, integer ai_button);str_params	lstr_params

lstr_params.a_param[1] = f_string(as_message)
lstr_params.a_param[2] = ai_severity
lstr_params.a_param[3] = ab_detail
lstr_params.a_param[4] = ai_button
openwithParm(w_error, lstr_params)
return(1)
end function

public function integer uf_unexp (integer ai_severity);return(uf_unexp("",ai_severity,FALSE,1))

end function

public function integer uf_unexp (string as_message);return(uf_unexp(as_message,3,FALSE,1))

end function

on uo_message.create
call super::create
TriggerEvent( this, "constructor" )
end on

on uo_message.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

