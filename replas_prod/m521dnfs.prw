#include 'protheus.ch'
#include 'parmtype.ch'

user function m521dnfs()
	Local aArea		:= GetArea()
	Local aPedido	:= Paramixb[1]
	Local nI		:= 0
	Local cVldReser := GetNewPar("MV_XVLDRES","S")
	
	If !IsinCallStack("U_XRLSMOTOR") .and. cVldReser == "S"
		For nI:=1 to len(aPedido)
			FwMsgRun(, {|| u_xValdRes(aPedido[nI]) }, , 'Validando Reserva, aguarde...')
		Next
	EndIf
	
	RestArea(aArea)
	
return