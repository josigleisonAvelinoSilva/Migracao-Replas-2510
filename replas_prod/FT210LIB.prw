#Include "Protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} FT210LIB - Liberação de pedido de venda
(long_description) Utilizado para liberação dos Pedidos sem que limpe
a Reserva.

@type  
@author Eduardo Augusto
@since 07/12/2017
@version 1.0
@return ${return}, ${return_description} lRet
@exampleç
(examples)
@see (links_or_references)
/*/
//-------------------------------------------------------------------

User Function FT210LIB()

Local _cPedido := SC5->C5_NUM
Local aArea    := GetArea()
Local aAreaC5  := SC5->(GetArea())
Local aAreaC6  := SC6->(GetArea())
Local cVldReser :=  GetNewPar("MV_XVLDRES","S")

If !IsinCallStack("U_XRLSMOTOR")
	DbSelectArea("SC6")
	SC6->(DbSetOrder(1))	// C6_FILIAL + C6_NUM + C6_ITEM + C6_PRODUTO
	If SC6->(DbSeek(xFilial("SC6") + _cPedido))
		While SC6->(!Eof()) .And. _cPedido == SC6->C6_NUM
			RecLock("SC6",.F.)
			SC6->C6_QTDLIB := SC6->C6_QTDVEN 
			SC6->(MsUnLock())
		   	SC6->(DbSkip())
		End
		RecLock("SC5",.F.)
		SC5->C5_LIBEROK := "S"
		SC5->(MsUnLock())
		If cVldReser == "S"
			FwMsgRun(, {|| u_xValdRes(_cPedido) }, , 'Validando Reserva, aguarde...')
		Endif
	EndIf
EndIf

RestArea(aAreaC6)
RestArea(aAreaC5)
RestArea(aArea)
 
Return