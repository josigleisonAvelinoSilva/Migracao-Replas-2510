#include 'protheus.ch'
#include 'parmtype.ch'

user function mt410alt()
	Local aArea		:= GetArea()
	Local cVldReser :=  GetNewPar("MV_XVLDRES","S")
	Local lIntIndMM := GetMV( "RE_INTIND", .F., .T. ) //-- Parametro geral que indica se a integracao de pedidos com a industria mm (Filial 0201) esta ativa
	
	If !IsinCallStack("U_XRLSMOTOR") .and. cVldReser == "S"
		If ( lIntIndMM .And. U_REFATA02( 2, SC5->C5_NUM ) ) .Or.;
		   ( lIntIndMM .And. IsInCallStack("U_REFATA05") )
		   
			Return
		Else
			FwMsgRun(, {|| u_xValdRes(SC5->C5_NUM) }, , 'Validando Reserva, aguarde...')
		EndIf
	EndIf
	
	RestArea(aArea)
return
