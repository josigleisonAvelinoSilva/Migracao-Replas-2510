#INCLUDE "TOTVS.CH"
#INCLUDE "PARMTYPE.CH"


/*/{Protheus.doc} mgv_StockBalanceAdapter
Classe de consulta de estoque atual para utilizacao do FWAdapterBaseV2
@type class
@version 1.0   
@author DO THINK - DENER LEMOS
@since 15/10/2025
/*/
CLASS mgv_StockBalanceAdapter FROM FWAdapterBaseV2

	METHOD new()
	METHOD getListStockBalance()

EndClass


/*/{Protheus.doc} mgv_StockBalanceAdapter::New
Classe de criacao do metodo mgv_StockBalanceAdapter
@type method
@version 1.0   
@author DO THINK - DENER LEMOS
@since 15/10/2025
@param cVerb, character, Verbo usado
/*/
Method new(cVerb) CLASS mgv_StockBalanceAdapter

	_Super:new(cVerb, .T.)

Return


/*/{Protheus.doc} mgv_StockBalanceAdapter::getListStockBalance
Metodo de listagem de estoque atual
@type method
@version 1.0   
@author DO THINK - DENER LEMOS
@since 15/10/2025
/*/
Method getListStockBalance() CLASS mgv_StockBalanceAdapter
	Local aAreaAnt AS ARRAY
	Local cWhere   AS CHAR

	aAreaAnt := FWGetArea()

	//-- Adiciona o mapa de campos Json/ResultSet
	AddMapFields(self)

	//-- Informa a Query a ser utilizada pela API
	::setQuery(GetQuery())

	//-- Informa a clausula Where da Query
	cWhere := " SB2.B2_FILIAL = '" + FWxFilial('SB2') + "' AND SB2.B2_LOCAL IN ('01','07') AND SB2.D_E_L_E_T_ = ' ' "

	::setWhere(cWhere)

	//-- Informa a ordenacao padrao a ser utilizada pela Query
	::setOrder(SB2->(StrTran(IndexKey(1), "+", ",")))

	//-- Executa a consulta, se retornar .T. tudo ocorreu conforme esperado
	If ::execute()
		//-- Gera o arquivo Json com o retorno da Query
		::fillGetResponse()
	EndIf

	FWrestArea(aAreaAnt)

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

	oSelf:addMapFields("branchId"      , "B2_FILIAL" , .T., .T., {"B2_FILIAL" , FWGetSX3Cache("B2_FILIAL" , "X3_TIPO"), FWGetSX3Cache("B2_FILIAL" , "X3_TAMANHO"), FWGetSX3Cache("B2_FILIAL" , "X3_DECIMAL")})
	oSelf:addMapFields("productCode"   , "B2_COD"    , .T., .T., {"B2_COD"    , FWGetSX3Cache("B2_COD"    , "X3_TIPO"), FWGetSX3Cache("B2_COD"    , "X3_TAMANHO"), FWGetSX3Cache("B2_COD"    , "X3_DECIMAL")})
	oSelf:addMapFields("productDesc"   , "B1_DESC"   , .T., .T., {"B1_DESC"   , FWGetSX3Cache("B1_DESC"   , "X3_TIPO"), FWGetSX3Cache("B1_DESC"   , "X3_TAMANHO"), FWGetSX3Cache("B1_DESC"   , "X3_DECIMAL")})
	oSelf:addMapFields("warehouseCode" , "B2_LOCAL"  , .T., .T., {"B2_LOCAL"  , FWGetSX3Cache("B2_LOCAL"  , "X3_TIPO"), FWGetSX3Cache("B2_LOCAL"  , "X3_TAMANHO"), FWGetSX3Cache("B2_LOCAL"  , "X3_DECIMAL")})
	oSelf:addMapFields("currentBalance", "SB2SALDO"  , .T., .T., {"SB2SALDO"  , FWGetSX3Cache("B2_QATU"   , "X3_TIPO"), FWGetSX3Cache("B2_QATU"   , "X3_TAMANHO"), FWGetSX3Cache("B2_QATU"   , "X3_DECIMAL")}, "B2_QATU - B2_RESERVA - B2_QEMP")
	oSelf:addMapFields("productGroup"  , "B1_GRUPO"  , .T., .T., {"B1_GRUPO"  , FWGetSX3Cache("B1_GRUPO"  , "X3_TIPO"), FWGetSX3Cache("B1_GRUPO"  , "X3_TAMANHO"), FWGetSX3Cache("B1_GRUPO"  , "X3_DECIMAL")})
	oSelf:addMapFields("fluidityIndex" , "B1_XINDFLU", .T., .T., {"B1_XINDFLU", FWGetSX3Cache("B1_XINDFLU", "X3_TIPO"), FWGetSX3Cache("B1_XINDFLU", "X3_TAMANHO"), FWGetSX3Cache("B1_XINDFLU", "X3_DECIMAL")})
	oSelf:addMapFields("manufacturer"  , "B1_FABRIC" , .T., .T., {"B1_FABRIC" , FWGetSX3Cache("B1_FABRIC" , "X3_TIPO"), FWGetSX3Cache("B1_FABRIC" , "X3_TAMANHO"), FWGetSX3Cache("B1_FABRIC" , "X3_DECIMAL")})

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
	cQuery += " FROM " + RetSqlName("SB2") + " SB2 "
	cQuery += " INNER JOIN "+ RetSqlName("SB1") + " SB1 ON B1_FILIAL = '" + xFilial("SB1") + "' AND B1_COD = B2_COD AND B1_TIPO = 'ME' AND SB1.D_E_L_E_T_= ' ' "
	cQuery += " WHERE #QueryWhere# "

Return cQuery
