#include 'protheus.ch'
#include 'parmtype.ch'

user function FA060QRY()
	Local cAgen	:= paramixb[1]
	Local cConta := paramixb[2]
	Local cRet		:= ""
	
	cRet := " E1_AGEDEP  = '"+cAgen+"' AND E1_CONTA  = '"+cConta+"' "

return(cRet)