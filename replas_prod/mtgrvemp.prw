#include 'protheus.ch'
#include 'parmtype.ch'

user function mtgrvemp()
	Local cProduto	:= paramixb[1]
	Local cLocal	:= paramixb[2]
	Local nQtd		:= paramixb[3]
	Local nQtd2UM	:= paramixb[4]
	Local cLoteCtl	:= paramixb[5]
	Local cNumLote	:= paramixb[6]
	Local cLocaliza	:= paramixb[7]
	Local cNumSerie	:= paramixb[8]
	Local cOp		:= paramixb[9]
	Local cTrt		:= paramixb[10]
	Local cPedido	:= paramixb[11]
	Local cItem		:= paramixb[12]
	Local cOrigem	:= paramixb[13]
	Local lEstorno	:= paramixb[14]
	Local aSalvCols	:= paramixb[15]
	Local nSG1		:= paramixb[16]
	Local aArea		:= GetArea()
	
	If !IsinCallStack("U_XRLSMOTOR") .AND. FunName() == 'MATA450'
		GravaB2Emp("-",nQtd,"F",!Empty(cPedido).And.cOrigem!="SDD",nQtd2UM)		
	EndIf
	
	RestArea(aArea)
return