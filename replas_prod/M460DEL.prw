#include 'protheus.ch'
#include 'parmtype.ch'

user function M460DEL()
	Local aArea		:= GetArea()
	Local cVldReser :=  GetNewPar("MV_XVLDRES","S")
	
	If !IsinCallStack("U_XRLSMOTOR") .and. cVldReser == "S"
		FwMsgRun(, {|| u_xValdRes(SC6->C6_NUM) }, , 'Validando Reserva, aguarde...')
	EndIf
	
	RestArea(aArea)
return