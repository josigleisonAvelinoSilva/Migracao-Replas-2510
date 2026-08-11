#include 'protheus.ch'
#include 'parmtype.ch'

user function MTA930F1()
	Local cAlias	:= paramixb[1]
	Local lRet		:= .T.
	
	If (cAlias)->F1_TIPO $ "I,C,P"
		lRet := .F.
	EndIf
	
	
return(lRet)