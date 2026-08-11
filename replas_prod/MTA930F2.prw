#include 'protheus.ch'
#include 'parmtype.ch'

user function MTA930F2()
	Local cAlias	:= paramixb[1]
	Local lRet		:= .T.
	
	If (cAlias)->F2_TIPO $ "I,P"
		lRet := .F.
	EndIf
	
	
return(lRet)