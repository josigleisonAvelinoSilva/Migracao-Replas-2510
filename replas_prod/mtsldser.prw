#include 'protheus.ch'
#include 'parmtype.ch'

user function mtsldser()
	Local cProd := PARAMIXB[1]
	Local lRet	:= .T.
	
	If IsinCallStack("A440GERAC9") .OR. IsinCallStack("MATA450")  
		lRet	:= .F.
	EndIf
	
return(lRet)