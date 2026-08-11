#INCLUDE "TOTVS.CH"


/*/{Protheus.doc} M410INIC
Ponto de entrada chamado antes da abertura da tela de INCLUSAO do pedido de vendas 
com o objetivo de permitir validacoes de usuarios e preenchimento de campos do pedido
@type function
@version 1.0 
@author DO THINK - DENER LEMOS
@since 23/02/2025
/*/
User Function M410INIC()
	Local cFilOrig := GetMV("RE_FILORIG", .F., "0302")

	If cFilAnt == cFilOrig .And. (INCLUI .Or. ALTERA)
		SetKey(VK_F6,{|| U_REPLAA18()})
	EndIf

Return

