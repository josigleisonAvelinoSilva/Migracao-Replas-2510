#INCLUDE "TOTVS.CH"
#INCLUDE "PARMTYPE.CH"


/*/{Protheus.doc} mgv_SalesOrderStatusAdapter
Classe de consulta dos status dos pedidos de venda para utilizacao do FWAdapterBaseV2
@type class
@version 1.0   
@author DO THINK - DENER LEMOS
@since 15/10/2025
/*/
CLASS mgv_SalesOrderStatusAdapter FROM FWAdapterBaseV2

	METHOD new()
	METHOD getListSalesOrderStatus()

EndClass


/*/{Protheus.doc} mgv_SalesOrderStatusAdapter::New
Classe de criacao do metodo mgv_SalesOrderStatusAdapter
@type method
@version 1.0   
@author DO THINK - DENER LEMOS
@since 15/10/2025
@param cVerb, character, Verbo usado
/*/
Method new(cVerb) CLASS mgv_SalesOrderStatusAdapter

	_Super:new(cVerb, .T.)

Return


/*/{Protheus.doc} mgv_SalesOrderStatusAdapter::getListSalesOrderStatus
Metodo de listagem dos status dos pedidos de venda
@type method
@version 1.0   
@author DO THINK - DENER LEMOS
@since 15/10/2025
/*/
Method getListSalesOrderStatus() CLASS mgv_SalesOrderStatusAdapter
	Local aAreaAnt AS ARRAY
	Local cWhere   AS CHAR

	aAreaAnt := FWGetArea()

	//-- Adiciona o mapa de campos Json/ResultSet
	AddMapFields(self)

	//-- Informa a Query a ser utilizada pela API
	::setQuery(GetQuery())

	//-- Informa a clausula Where da Query
	cWhere := " C6_FILIAL = '" + FWxFilial('SC6') + "' "

	::setWhere(cWhere)

	//-- Informa a ordenacao padrao a ser utilizada pela Query
	//::setOrder(SC6->(StrTran(IndexKey(1), "+", ",")))
	::setOrder("C6_FILIAL, C6_NUM DESC, C6_ITEM")

	//-- Executa a consulta, se retornar .T. tudo ocorreu conforme esperado
	If ::execute()
		//-- Gera o arquivo Json com o retorno da Query
		::fillGetResponse()
	EndIf

	FWRestArea(aAreaAnt)

Return


/*/{Protheus.doc} AddMapFields
Rotina que adiciona mapeamento de campos utilizado no Adapter
@type function
@version 1.0   
@author DO THINK - DENER LEMOS
@since 15/10/2025
@param oSelf, object, objeto WS
/*/
Static Function AddMapFields(oSelf)

	oSelf:addMapFields("statusColor"      , "C6_XSTCOR" , .T., .T., {"C6_XSTCOR" , "C"                                   , 01                                       , 0                                        })
	oSelf:addMapFields("statusDesc"       , "C6_XSTDESC", .T., .T., {"C6_XSTDESC", "C"                                   , 99                                       , 0                                        })
	oSelf:addMapFields("branchId"         , "C6_FILIAL" , .T., .T., {"C6_FILIAL" , FWGetSX3Cache("C6_FILIAL" , "X3_TIPO"), FWGetSX3Cache("C6_FILIAL" , "X3_TAMANHO"), FWGetSX3Cache("C6_FILIAL" , "X3_DECIMAL")})
	oSelf:addMapFields("salesOrderNum"    , "C6_NUM"    , .T., .T., {"C6_NUM"    , FWGetSX3Cache("C6_NUM"    , "X3_TIPO"), FWGetSX3Cache("C6_NUM"    , "X3_TAMANHO"), FWGetSX3Cache("C6_NUM"    , "X3_DECIMAL")})
	oSelf:addMapFields("salesOrderItem"   , "C6_ITEM"   , .T., .T., {"C6_ITEM"   , FWGetSX3Cache("C6_ITEM"   , "X3_TIPO"), FWGetSX3Cache("C6_ITEM"   , "X3_TAMANHO"), FWGetSX3Cache("C6_ITEM"   , "X3_DECIMAL")})
	oSelf:addMapFields("productCode"      , "C6_PRODUTO", .T., .T., {"C6_PRODUTO", FWGetSX3Cache("C6_PRODUTO", "X3_TIPO"), FWGetSX3Cache("C6_PRODUTO", "X3_TAMANHO"), FWGetSX3Cache("C6_PRODUTO", "X3_DECIMAL")})
	oSelf:addMapFields("productDesc"      , "C6_DESCRI" , .T., .T., {"C6_DESCRI" , FWGetSX3Cache("C6_DESCRI" , "X3_TIPO"), FWGetSX3Cache("C6_DESCRI" , "X3_TAMANHO"), FWGetSX3Cache("C6_DESCRI" , "X3_DECIMAL")})
	oSelf:addMapFields("measureUnit"      , "C6_UM"     , .T., .T., {"C6_UM"     , FWGetSX3Cache("C6_UM"     , "X3_TIPO"), FWGetSX3Cache("C6_UM"     , "X3_TAMANHO"), FWGetSX3Cache("C6_UM"     , "X3_DECIMAL")})
	oSelf:addMapFields("salesQuantity"    , "C6_QTDVEN" , .T., .T., {"C6_QTDVEN" , FWGetSX3Cache("C6_QTDVEN" , "X3_TIPO"), FWGetSX3Cache("C6_QTDVEN" , "X3_TAMANHO"), FWGetSX3Cache("C6_QTDVEN" , "X3_DECIMAL")})
	oSelf:addMapFields("salesNetPrice"    , "C6_PRCVEN" , .T., .T., {"C6_PRCVEN" , FWGetSX3Cache("C6_PRCVEN" , "X3_TIPO"), FWGetSX3Cache("C6_PRCVEN" , "X3_TAMANHO"), FWGetSX3Cache("C6_PRCVEN" , "X3_DECIMAL")})
	oSelf:addMapFields("itemTotalValue"   , "C6_VALOR"  , .T., .T., {"C6_VALOR"  , FWGetSX3Cache("C6_VALOR"  , "X3_TIPO"), FWGetSX3Cache("C6_VALOR"  , "X3_TAMANHO"), FWGetSX3Cache("C6_VALOR"  , "X3_DECIMAL")})
	oSelf:addMapFields("warehouseCode"    , "C6_LOCAL"  , .T., .T., {"C6_LOCAL"  , FWGetSX3Cache("C6_LOCAL"  , "X3_TIPO"), FWGetSX3Cache("C6_LOCAL"  , "X3_TAMANHO"), FWGetSX3Cache("C6_LOCAL"  , "X3_DECIMAL")})
	oSelf:addMapFields("outflowType"      , "C6_TES"    , .T., .T., {"C6_TES"    , FWGetSX3Cache("C6_TES"    , "X3_TIPO"), FWGetSX3Cache("C6_TES"    , "X3_TAMANHO"), FWGetSX3Cache("C6_TES"    , "X3_DECIMAL")})
	oSelf:addMapFields("customerCode"     , "C6_CLI"    , .T., .T., {"C6_CLI"    , FWGetSX3Cache("C6_CLI"    , "X3_TIPO"), FWGetSX3Cache("C6_CLI"    , "X3_TAMANHO"), FWGetSX3Cache("C6_CLI"    , "X3_DECIMAL")})
	oSelf:addMapFields("customerBranch"   , "C6_LOJA"   , .T., .T., {"C6_LOJA"   , FWGetSX3Cache("C6_LOJA"   , "X3_TIPO"), FWGetSX3Cache("C6_LOJA"   , "X3_TAMANHO"), FWGetSX3Cache("C6_LOJA"   , "X3_DECIMAL")})
	oSelf:addMapFields("customerName"     , "A1_NOME"   , .T., .T., {"A1_NOME"   , FWGetSX3Cache("A1_NOME"   , "X3_TIPO"), FWGetSX3Cache("A1_NOME"   , "X3_TAMANHO"), FWGetSX3Cache("A1_NOME"   , "X3_DECIMAL")})
	oSelf:addMapFields("customerShortName", "A1_NREDUZ" , .T., .T., {"A1_NREDUZ" , FWGetSX3Cache("A1_NREDUZ" , "X3_TIPO"), FWGetSX3Cache("A1_NREDUZ" , "X3_TAMANHO"), FWGetSX3Cache("A1_NREDUZ" , "X3_DECIMAL")})
	oSelf:addMapFields("deliveryDate"     , "C6_ENTREG" , .T., .T., {"C6_ENTREG" , FWGetSX3Cache("C6_ENTREG" , "X3_TIPO"), FWGetSX3Cache("C6_ENTREG" , "X3_TAMANHO"), FWGetSX3Cache("C6_ENTREG" , "X3_DECIMAL")})
	oSelf:addMapFields("sellerCode1"      , "C5_VEND1"  , .T., .T., {"C5_VEND1"  , FWGetSX3Cache("C5_VEND1"  , "X3_TIPO"), FWGetSX3Cache("C5_VEND1"  , "X3_TAMANHO"), FWGetSX3Cache("C5_VEND1"  , "X3_DECIMAL")})
	oSelf:addMapFields("issueDate"        , "C5_EMISSAO", .T., .T., {"C5_EMISSAO", FWGetSX3Cache("C5_EMISSAO", "X3_TIPO"), FWGetSX3Cache("C5_EMISSAO", "X3_TAMANHO"), FWGetSX3Cache("C5_EMISSAO", "X3_DECIMAL")})
	oSelf:addMapFields("paymentCond"      , "C5_CONDPAG", .T., .T., {"C5_CONDPAG", FWGetSX3Cache("C5_CONDPAG", "X3_TIPO"), FWGetSX3Cache("C5_CONDPAG", "X3_TAMANHO"), FWGetSX3Cache("C5_CONDPAG", "X3_DECIMAL")})
	oSelf:addMapFields("invoiceMessage1"  , "C5_MENNOTA", .T., .T., {"C5_MENNOTA", FWGetSX3Cache("C5_MENNOTA", "X3_TIPO"), FWGetSX3Cache("C5_MENNOTA", "X3_TAMANHO"), FWGetSX3Cache("C5_MENNOTA", "X3_DECIMAL")})
	oSelf:addMapFields("invoiceMessage2"  , "C5_XMENOTA", .T., .T., {"C5_XMENOTA", FWGetSX3Cache("C5_XMENOTA", "X3_TIPO"), FWGetSX3Cache("C5_XMENOTA", "X3_TAMANHO"), FWGetSX3Cache("C5_XMENOTA", "X3_DECIMAL")})

Return


/*/{Protheus.doc} GetQuery
Rotina que monta a query que sera utilizado no metodo SetQuery
@type function
@version 1.0   
@author DO THINK - DENER LEMOS
@since 15/10/2025
@return character, Retorna query
/*/
Static Function GetQuery()
	Local cQuery AS CHARACTER

	cQuery := " SELECT #QueryFields# "
	cQuery += " FROM ( "

	//-- Consultando pedidos em aberto...
	cQuery += " SELECT 'BR_VERDE' C6_XSTCOR, 'Em aberto' C6_XSTDESC, C6_FILIAL, C6_NUM, C6_ITEM, C6_PRODUTO, C6_DESCRI, C6_UM, C6_QTDVEN, C6_PRCVEN, C6_VALOR, C6_LOCAL, C6_TES, C6_CLI, C6_LOJA, A1_NOME, A1_NREDUZ, C6_ENTREG, C5_VEND1, C5_EMISSAO, C5_CONDPAG, C5_MENNOTA, ISNULL(CAST(CAST(C5_XMENOTA AS VARBINARY(8000)) AS VARCHAR(8000)), '') AS C5_XMENOTA "
	cQuery += " FROM " + RetSqlName("SC5") + " SC5 "
	cQuery += " INNER JOIN " + RetSqlName("SC6") + " SC6 ON C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM AND SC6.D_E_L_E_T_ = '' "
	cQuery += " INNER JOIN " + RetSqlName("SA1") + " SA1 ON A1_FILIAL = '" + xFilial("SA1") + "' AND A1_COD = C6_CLI AND A1_LOJA = C6_LOJA AND SA1.D_E_L_E_T_ = '' "
	cQuery += " WHERE C5_FILIAL = '" + xFilial("SC5") + "' "
	cQuery += " AND SC5.D_E_L_E_T_ = '' "
	cQuery += " AND NOT EXISTS (SELECT 1 "
	cQuery += "                 FROM " + RetSqlName("SC9") + " SC9 "
	cQuery += "                 WHERE C9_FILIAL  = C6_FILIAL "
	cQuery += "                 AND   C9_PEDIDO  = C6_NUM "
	cQuery += " 				AND   C9_ITEM    = C6_ITEM "
	cQuery += " 				AND   C9_PRODUTO = C6_PRODUTO "
	cQuery += " 				AND   SC9.D_E_L_E_T_ = ' ') "
	cQuery += " AND C6_BLQ = '' "
	cQuery += " AND C6_BLOQUEI = '' "
	cQuery += " UNION "

	//-- Consultando pedidos liberados...
	cQuery += " SELECT 'BR_AMARELO' C6_XSTCOR, 'Liberado' C6_XSTDESC, C6_FILIAL, C6_NUM, C6_ITEM, C6_PRODUTO, C6_DESCRI, C6_UM, C6_QTDVEN, C6_PRCVEN, C6_VALOR, C6_LOCAL, C6_TES, C6_CLI, C6_LOJA, A1_NOME, A1_NREDUZ, C6_ENTREG, C5_VEND1, C5_EMISSAO, C5_CONDPAG, C5_MENNOTA, ISNULL(CAST(CAST(C5_XMENOTA AS VARBINARY(8000)) AS VARCHAR(8000)), '') AS C5_XMENOTA "
	cQuery += " FROM " + RetSqlName("SC5") + " SC5 "
	cQuery += " INNER JOIN " + RetSqlName("SC6") +  " SC6 ON SC6.D_E_L_E_T_ = '' AND C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM "
	cQuery += " INNER JOIN " + RetSqlName("SC9") +  " SC9 ON SC9.D_E_L_E_T_ = '' AND C9_FILIAL = C6_FILIAL AND C9_PEDIDO = C6_NUM AND C9_ITEM = C6_ITEM AND C6_PRODUTO = C9_PRODUTO "
	cQuery += " INNER JOIN " + RetSqlName("SA1") + " SA1 ON A1_FILIAL = '" + xFilial("SA1") + "' AND A1_COD = C6_CLI AND A1_LOJA = C6_LOJA AND SA1.D_E_L_E_T_ = '' "
	cQuery += " WHERE SC5.D_E_L_E_T_ = '' "
	cQuery += " AND C5_FILIAL = '"+xFilial("SC5")+"' "
	cQuery += " AND C6_BLOQUEI = '' "
	cQuery += " AND C6_BLQ = '' "
	cQuery += " AND C9_CARGA = '' "
	cQuery += " AND C9_NFISCAL = '' "
	cQuery += " AND C9_SERIENF = '' "
	cQuery += " AND C9_BLCRED = '' "
	cQuery += " AND C9_BLEST = '' "
	cQuery += " UNION "

	//-- Consultando pedidos faturados...
	cQuery += " SELECT 'BR_VERMELHO' C6_XSTCOR, 'Faturado' C6_XSTDESC, C6_FILIAL, C6_NUM, C6_ITEM, C6_PRODUTO, C6_DESCRI, C6_UM, C6_QTDVEN, C6_PRCVEN, C6_VALOR, C6_LOCAL, C6_TES, C6_CLI, C6_LOJA, A1_NOME, A1_NREDUZ, C6_ENTREG, C5_VEND1, C5_EMISSAO, C5_CONDPAG, C5_MENNOTA, ISNULL(CAST(CAST(C5_XMENOTA AS VARBINARY(8000)) AS VARCHAR(8000)), '') AS C5_XMENOTA "
	cQuery += " FROM " + RetSqlName("SC5") + " SC5 "
	cQuery += " INNER JOIN " + RetSqlName("SC6") + " SC6 ON SC6.D_E_L_E_T_ = '' AND C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM "
	cQuery += " INNER JOIN " + RetSqlName("SC9") + " SC9 ON SC9.D_E_L_E_T_ = '' AND C9_FILIAL = C6_FILIAL AND C9_PEDIDO = C6_NUM AND C9_ITEM = C6_ITEM AND C6_PRODUTO = C9_PRODUTO "
	cQuery += " INNER JOIN " + RetSqlName("SA1") + " SA1 ON A1_FILIAL = '" + xFilial("SA1") + "' AND A1_COD = C6_CLI AND A1_LOJA = C6_LOJA AND SA1.D_E_L_E_T_ = '' "
	cQuery += " WHERE SC5.D_E_L_E_T_ = '' "
	cQuery += " AND C5_FILIAL = '"+xFilial("SC5")+"' "
	cQuery += " AND C9_NFISCAL <> '' "
	cQuery += " AND C9_SERIENF <> '' "
	cQuery += " UNION "

	//-- Consultando pedidos eliminado residuos...
	cQuery += " SELECT 'BR_PRETO' C6_XSTCOR, 'Eliminado Residuo' C6_XSTDESC, C6_FILIAL, C6_NUM, C6_ITEM, C6_PRODUTO, C6_DESCRI, C6_UM, C6_QTDVEN, C6_PRCVEN, C6_VALOR, C6_LOCAL, C6_TES, C6_CLI, C6_LOJA, A1_NOME, A1_NREDUZ, C6_ENTREG, C5_VEND1, C5_EMISSAO, C5_CONDPAG, C5_MENNOTA, ISNULL(CAST(CAST(C5_XMENOTA AS VARBINARY(8000)) AS VARCHAR(8000)), '') AS C5_XMENOTA "
	cQuery += " FROM " + RetSqlName("SC5") + " SC5 "
	cQuery += " INNER JOIN " + RetSqlName("SC6") + " SC6 ON SC6.D_E_L_E_T_ = '' AND C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM "
	cQuery += " INNER JOIN " + RetSqlName("SA1") + " SA1 ON A1_FILIAL = '" + xFilial("SA1") + "' AND A1_COD = C6_CLI AND A1_LOJA = C6_LOJA AND SA1.D_E_L_E_T_ = '' "
	cQuery += " WHERE SC5.D_E_L_E_T_ = '' "
	cQuery += " AND C5_FILIAL = '"+xFilial("SC5")+"' "
	cQuery += " AND C6_BLQ = 'R' "
	cQuery += " UNION "

	//-- Consultando pedidos em carga...
	cQuery += " SELECT 'BR_LARANJA' C6_XSTCOR, 'Item Em Carga (Aguardando Faturamento)' C6_XSTDESC, C6_FILIAL, C6_NUM, C6_ITEM, C6_PRODUTO, C6_DESCRI, C6_UM, C6_QTDVEN, C6_PRCVEN, C6_VALOR, C6_LOCAL, C6_TES, C6_CLI, C6_LOJA, A1_NOME, A1_NREDUZ, C6_ENTREG, C5_VEND1, C5_EMISSAO, C5_CONDPAG, C5_MENNOTA, ISNULL(CAST(CAST(C5_XMENOTA AS VARBINARY(8000)) AS VARCHAR(8000)), '') AS C5_XMENOTA "
	cQuery += " FROM " + RetSqlName("SC5") + " SC5 "
	cQuery += " INNER JOIN " + RetSqlName("SC6") + " SC6 ON SC6.D_E_L_E_T_ = '' AND C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM "
	cQuery += " INNER JOIN " + RetSqlName("SC9") + " SC9 ON SC9.D_E_L_E_T_ = '' AND C9_FILIAL = C6_FILIAL AND C9_PEDIDO = C6_NUM AND C9_ITEM = C6_ITEM AND C6_PRODUTO = C9_PRODUTO "
	cQuery += " INNER JOIN " + RetSqlName("SA1") + " SA1 ON A1_FILIAL = '" + xFilial("SA1") + "' AND A1_COD = C6_CLI AND A1_LOJA = C6_LOJA AND SA1.D_E_L_E_T_ = '' "
	cQuery += " WHERE SC5.D_E_L_E_T_ = '' "
	cQuery += " AND C5_FILIAL = '"+xFilial("SC5")+"' "
	cQuery += " AND C9_CARGA <> '' "
	cQuery += " AND C9_NFISCAL = '' "
	cQuery += " AND C9_SERIENF = '' "
	cQuery += " UNION "

	//-- Consultando pedidos bloqueio de credito e estoque...
	cQuery += " SELECT 'BR_VIOLETA' C6_XSTCOR, 'Bloqueio Credito e Estoque' C6_XSTDESC, C6_FILIAL, C6_NUM, C6_ITEM, C6_PRODUTO, C6_DESCRI, C6_UM, C6_QTDVEN, C6_PRCVEN, C6_VALOR, C6_LOCAL, C6_TES, C6_CLI, C6_LOJA, A1_NOME, A1_NREDUZ, C6_ENTREG, C5_VEND1, C5_EMISSAO, C5_CONDPAG, C5_MENNOTA, ISNULL(CAST(CAST(C5_XMENOTA AS VARBINARY(8000)) AS VARCHAR(8000)), '') AS C5_XMENOTA "
	cQuery += " FROM " + RetSqlName("SC5") + " SC5 "
	cQuery += " INNER JOIN " + RetSqlName("SC6") + " SC6 ON SC6.D_E_L_E_T_ = '' AND C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM "
	cQuery += " INNER JOIN " + RetSqlName("SC9") + " SC9 ON SC9.D_E_L_E_T_ = '' AND C9_FILIAL = C6_FILIAL AND C9_PEDIDO = C6_NUM AND C9_ITEM = C6_ITEM AND C6_PRODUTO = C9_PRODUTO "
	cQuery += " INNER JOIN " + RetSqlName("SA1") + " SA1 ON A1_FILIAL = '" + xFilial("SA1") + "' AND A1_COD = C6_CLI AND A1_LOJA = C6_LOJA AND SA1.D_E_L_E_T_ = '' "
	cQuery += " WHERE SC5.D_E_L_E_T_ = '' "
	cQuery += " AND C5_FILIAL = '"+xFilial("SC5")+"' "
	cQuery += " AND C6_BLOQUEI = '' "
	cQuery += " AND C6_BLQ = '' "
	cQuery += " AND C9_CARGA = '' "
	cQuery += " AND C9_NFISCAL = '' "
	cQuery += " AND C9_SERIENF = '' "
	cQuery += " AND C9_BLCRED = '01' "
	cQuery += " AND C9_BLEST = '02' "
	cQuery += " UNION "

	//-- Consultando pedidos bloqueio somente credito...
	cQuery += " SELECT 'BR_BRANCO' C6_XSTCOR, 'Bloqueio somente Credito' C6_XSTDESC, C6_FILIAL, C6_NUM, C6_ITEM, C6_PRODUTO, C6_DESCRI, C6_UM, C6_QTDVEN, C6_PRCVEN, C6_VALOR, C6_LOCAL, C6_TES, C6_CLI, C6_LOJA, A1_NOME, A1_NREDUZ, C6_ENTREG, C5_VEND1, C5_EMISSAO, C5_CONDPAG, C5_MENNOTA, ISNULL(CAST(CAST(C5_XMENOTA AS VARBINARY(8000)) AS VARCHAR(8000)), '') AS C5_XMENOTA "
	cQuery += " FROM " + RetSqlName("SC5") + " SC5 "
	cQuery += " INNER JOIN " + RetSqlName("SC6") + " SC6 ON SC6.D_E_L_E_T_ = '' AND C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM "
	cQuery += " INNER JOIN " + RetSqlName("SC9") + " SC9 ON SC9.D_E_L_E_T_ = '' AND C9_FILIAL = C6_FILIAL AND C9_PEDIDO = C6_NUM AND C9_ITEM = C6_ITEM AND C6_PRODUTO = C9_PRODUTO "
	cQuery += " INNER JOIN " + RetSqlName("SA1") + " SA1 ON A1_FILIAL = '" + xFilial("SA1") + "' AND A1_COD = C6_CLI AND A1_LOJA = C6_LOJA AND SA1.D_E_L_E_T_ = '' "
	cQuery += " WHERE SC5.D_E_L_E_T_ = '' "
	cQuery += " AND C5_FILIAL = '"+xFilial("SC5")+"' "
	cQuery += " AND C6_BLOQUEI = '' "
	cQuery += " AND C6_BLQ = '' "
	cQuery += " AND C9_CARGA = '' "
	cQuery += " AND C9_NFISCAL = '' "
	cQuery += " AND C9_SERIENF = '' "
	cQuery += " AND C9_BLCRED = '01' "
	cQuery += " AND C9_BLEST = '' "
	cQuery += " UNION "

	//-- Consultando pedidos bloqueio somente estoque...
	cQuery += " SELECT 'BR_CINZA' C6_XSTCOR, 'Bloqueio somente Estoque' C6_XSTDESC, C6_FILIAL, C6_NUM, C6_ITEM, C6_PRODUTO, C6_DESCRI, C6_UM, C6_QTDVEN, C6_PRCVEN, C6_VALOR, C6_LOCAL, C6_TES, C6_CLI, C6_LOJA, A1_NOME, A1_NREDUZ, C6_ENTREG, C5_VEND1, C5_EMISSAO, C5_CONDPAG, C5_MENNOTA, ISNULL(CAST(CAST(C5_XMENOTA AS VARBINARY(8000)) AS VARCHAR(8000)), '') AS C5_XMENOTA "
	cQuery += " FROM " + RetSqlName("SC5") + " SC5 "
	cQuery += " INNER JOIN " + RetSqlName("SC6") + " SC6 ON SC6.D_E_L_E_T_ = '' AND C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM "
	cQuery += " INNER JOIN " + RetSqlName("SC9") + " SC9 ON SC9.D_E_L_E_T_ = '' AND C9_FILIAL = C6_FILIAL AND C9_PEDIDO = C6_NUM AND C9_ITEM = C6_ITEM AND C6_PRODUTO = C9_PRODUTO "
	cQuery += " INNER JOIN " + RetSqlName("SA1") + " SA1 ON A1_FILIAL = '" + xFilial("SA1") + "' AND A1_COD = C6_CLI AND A1_LOJA = C6_LOJA AND SA1.D_E_L_E_T_ = '' "
	cQuery += " WHERE SC5.D_E_L_E_T_ = '' "
	cQuery += " AND C5_FILIAL = '"+xFilial("SC5")+"' "
	cQuery += " AND C6_BLOQUEI = '' "
	cQuery += " AND C6_BLQ = '' "
	cQuery += " AND C9_CARGA = '' "
	cQuery += " AND C9_NFISCAL = '' "
	cQuery += " AND C9_SERIENF = '' "
	cQuery += " AND C9_BLCRED = '' "
	cQuery += " AND C9_BLEST = '02' "
	cQuery += " UNION "

	//-- Consultando pedidos bloqueio por regra...
	cQuery += " SELECT 'BR_AZUL' C6_XSTCOR, 'Bloqueio por Regra' C6_XSTDESC, C6_FILIAL, C6_NUM, C6_ITEM, C6_PRODUTO, C6_DESCRI, C6_UM, C6_QTDVEN, C6_PRCVEN, C6_VALOR, C6_LOCAL, C6_TES, C6_CLI, C6_LOJA, A1_NOME, A1_NREDUZ, C6_ENTREG, C5_VEND1, C5_EMISSAO, C5_CONDPAG, C5_MENNOTA, ISNULL(CAST(CAST(C5_XMENOTA AS VARBINARY(8000)) AS VARCHAR(8000)), '') AS C5_XMENOTA "
	cQuery += " FROM " + RetSqlName("SC5") + " SC5 "
	cQuery += " INNER JOIN " + RetSqlName("SC6") + " SC6 ON SC6.D_E_L_E_T_ = '' AND C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM "
	cQuery += " INNER JOIN " + RetSqlName("SC9") + " SC9 ON SC9.D_E_L_E_T_ = '' AND C9_FILIAL = C6_FILIAL AND C9_PEDIDO = C6_NUM AND C9_ITEM = C6_ITEM AND C6_PRODUTO = C9_PRODUTO "
	cQuery += " INNER JOIN " + RetSqlName("SA1") + " SA1 ON A1_FILIAL = '" + xFilial("SA1") + "' AND A1_COD = C6_CLI AND A1_LOJA = C6_LOJA AND SA1.D_E_L_E_T_ = '' "
	cQuery += " WHERE SC5.D_E_L_E_T_ = '' "
	cQuery += " AND C5_FILIAL = '"+xFilial("SC5")+"' "
	cQuery += " AND C6_BLOQUEI = '01' "
	cQuery += " AND C9_CARGA = '' "
	cQuery += " AND C9_NFISCAL = '' "
	cQuery += " AND C9_SERIENF = '' "

	cQuery += " ) TRB "
	cQuery += " WHERE #QueryWhere# "

Return cQuery
