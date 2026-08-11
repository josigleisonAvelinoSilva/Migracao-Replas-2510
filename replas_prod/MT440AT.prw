#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

// ----------------------------------------------------------
/*/{Protheus.doc} MT440AT - Impedir liberação do pedido de venda
(long_description) Este ponto de entrada é executado antes da 
visualização da liberação do pedido de venda e permite ao 
desenvolvedor impedir a utilização da rotina.

Tratamento para bloquear a Liberação de Pedido quando
Pedido estiver bloqueado por regra.
@type function
@author Eduardo
@since 09/11/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
// ----------------------------------------------------------

User Function MT440AT()()

Local lRet   := .F. // Por padrão, retorna falso, só terá tratamento caso seja da rotina xrlsmotor
Local lBloq  := .F. // Variavel logica pra identificar se algum item do pedido está bloqueado
Local cQuery  := ""
Local lXRLSMOTOR := IsInCallStack("U_XRLSMOTOR")
Local lIntIndMM  := GetMV( "RE_INTIND", .F., .T. ) //-- Parametro geral que indica se a integracao de pedidos com a industria mm (Filial 0201) esta ativa

If !lXRLSMOTOR .And. lIntIndMM .And. U_REFATA02( 2, SC5->C5_NUM )
	Return .T.
EndIf

If !lXRLSMOTOR
	If SC5->C5_BLQ == "1" // Se tiver bloqueio, analisa se tem algum item bloqueado da SC6, se tiver pelo menos 1, bloqueia o pedido inteiro
		If Select("TMP") > 0
			TPMP->(DbCloseArea())
		EndIf
		cQuery := " SELECT C6_BLOQUEI FROM " + RetSqlName("SC6")
		cQuery += " WHERE D_E_L_E_T_ = '' "
		cQuery += " AND C6_FILIAL    = '" + SC5->C5_FILIAL + "' "
		cQuery += " AND C6_NUM       = '" + SC5->C5_NUM + "' "
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TMP', .T., .F.)
		DbSelectArea("TMP")
		DbGoTop()
		While TMP->(!Eof())
			If TMP->C6_BLOQUEI == "01"
				lBloq := .T.
			EndIf
			//DbSelectArea("TMP")
			TMP->(DbSkip())
		End
		If !lBloq
			lRet := .T.
		Else
			MsgInfo("Liberação de Pedido Bloqueada por Regra, faça o desbloqueio e repita a operação!!!")
		EndIf
	EndIf
EndIf

Return lRet

/*
User Function MT440AT()

Local lConfirm := .F.
Local _cPedido := SC5->C5_NUM

If !IsinCallStack("U_XRLSMOTOR")
	// Posicionando na Tabela dos Itens do Pedido de Venda
	DbSelectArea("SC6")
	DbSetOrder(1)		// C6_FILIAL + C6_NUM + C6_ITEM + C6_PRODUTO
	If SC6->(DbSeek(xFilial("SC6") + _cPedido ))
		If SC5->C5_BLQ == "1" .And. SC6->C6_BLOQUEI == "01"
			MsgInfo("Liberação de Pedido Bloqueada por Regra, faça o desbloqueio e repita a operação!!!")
		Else
			lConfirm := .T.
		EndIf
	EndIf
EndIf

Return lConfirm
*/
