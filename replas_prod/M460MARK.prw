#include 'protheus.ch'
#include 'parmtype.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ M460MARK    ºAutor³ Flávio Dentello    º Data ³ 09/07/2021     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ WebService que recebe os pedidos separados pelo WMS e atualizaº±±
±±º          ³ os pedidos com base nas quantidades enviadas                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SuperMix                                    	                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function M460MARK()
	Local aAreaAnt  := GetArea()
	Local aAreaSC5 := SC5->(GetArea())
	//Local cMark   := PARAMIXB[1] // MARCA UTILIZADA
	//Local lInvert := PARAMIXB[2] // SELECIONOU "MARCA TODOS"
	Local lRet 	  := .T.
	
	If IsInCallStack("MATA460A")

		DbSelectArea('SC5')
		DbSetOrder(1)
		If SC5->(DbSeek(xFilial("SC5")+SC9->C9_PEDIDO))
			If SC5->C5_BLQ <> '1'
				If U_REFATA02(2, SC5->C5_NUM) .And. (Empty(SC5->C5_PESOL) .Or. Empty(SC5->C5_PBRUTO) .Or. Empty(SC5->C5_VOLUME1))
					FWAlertHelp("O pedido de venda <b>" + AllTrim(SC5->C5_NUM) + "</b> possui campos obrigatórios que não foram preenchidos. ",;
					 			"Para prosseguir com o faturamento será necessário informar os campos <b>" + AllTrim(GetSX3Cache("C5_PESOL", "X3_TITULO")) + "/" + AllTrim(GetSX3Cache("C5_PBRUTO", "X3_TITULO")) + "/" + AllTrim(GetSX3Cache("C5_VOLUME1", "X3_TITULO")) + "</b>.")
					lRet := .F.
				Else
					lRet := .T.
				EndIf
			Else
				Aviso("PEDIDO NÃO FATURADO","Pedido possui bloqueio de Regras, para faturar será necessário a liberação do mesmo!")
				lRet := .F.
			EndIf		
		EndIf			
	EndIf

	RestArea(aAreaSC5)
	RestArea(aAreaAnt)

Return lRet
