#INCLUDE "PROTHEUS.CH"  

/*/{Protheus.doc} A300USRF
Funcção resposanvel por retornar o saldo disponivel no campo B1_XSLDISP

@author Jean Inacio Silva
@since  13/01/2017
/*/


User function XCRM001()
	Local aArea :=  GetArea()
	
	dbSelectArea("SB2")
	dbSeek(xFilial("SB2") + SB1->B1_COD + SB1->B1_LOCPAD)
	nSaldo := SaldoSb2()
	
	RestArea(aArea)

Return nSaldo


