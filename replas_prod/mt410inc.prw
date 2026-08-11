#include 'protheus.ch'
#include 'parmtype.ch'

user function mt410inc()
	Local aArea		:= GetArea()
	Local cVldReser :=  GetNewPar("MV_XVLDRES","S")
	
	If !IsinCallStack("U_XRLSMOTOR") .and. cVldReser == "S"
		FwMsgRun(, {|| u_xValdRes(SC5->C5_NUM) }, , 'Validando Reserva, aguarde...')
	EndIf
	
	RestArea(aArea)
return