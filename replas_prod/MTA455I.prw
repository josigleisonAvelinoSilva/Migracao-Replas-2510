#include 'protheus.ch'
#include 'parmtype.ch'

user function MTA455I()
	Local aArea		:= GetArea()
	Local cVldReser :=  GetNewPar("MV_XVLDRES","S")
	
	If !IsinCallStack("U_XRLSMOTOR") .and. cVldReser == "S"
		FwMsgRun(, {|| u_xValdRes(SC9->C9_PEDIDO) }, , 'Validando Reserva, aguarde...')
	EndIf
	
	RestArea(aArea)

return