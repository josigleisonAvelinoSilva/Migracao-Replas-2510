#INCLUDE "TOTVS.CH"
#INCLUDE "PARMTYPE.CH"


/*/{Protheus.doc} mgv_SellerDataAdapter
Classe de consulta de vendedores para utilizacao do FWAdapterBaseV2
@type class
@version 1.0   
@author DO THINK - DENER LEMOS
@since 15/10/2025
/*/
CLASS mgv_SellerDataAdapter FROM FWAdapterBaseV2

	METHOD new()
	METHOD getListSellerData()

EndClass


/*/{Protheus.doc} mgv_SellerDataAdapter::New
Classe de criacao do metodo mgv_SellerDataAdapter
@type method
@version 1.0   
@author DO THINK - DENER LEMOS
@since 15/10/2025
@param cVerb, character, Verbo usado
/*/
Method new(cVerb) CLASS mgv_SellerDataAdapter

	_Super:new(cVerb, .T.)

Return


/*/{Protheus.doc} mgv_SellerDataAdapter::getListSellerData
Metodo de listagem de vendedores
@type method
@version 1.0   
@author DO THINK - DENER LEMOS
@since 15/10/2025
/*/
Method getListSellerData() CLASS mgv_SellerDataAdapter
	Local aAreaAnt AS ARRAY
	Local cWhere   AS CHAR

	aAreaAnt := FWGetArea()

	//-- Adiciona o mapa de campos Json/ResultSet
	AddMapFields(self)

	//-- Informa a Query a ser utilizada pela API
	::setQuery(GetQuery())

	//-- Informa a clausula Where da Query
	cWhere := " SA3.A3_FILIAL = '" + FWxFilial('SA3') + "' AND SA3.D_E_L_E_T_ = ' ' "

	::setWhere(cWhere)

	//-- Informa a ordenacao padrao a ser utilizada pela Query
	::setOrder(SA3->(StrTran(IndexKey(1), "+", ",")))

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

	oSelf:addMapFields("branchId"       , "A3_FILIAL", .T., .T.,  {"A3_FILIAL", FWGetSX3Cache("A3_FILIAL", "X3_TIPO"), FWGetSX3Cache("A3_FILIAL", "X3_TAMANHO"), FWGetSX3Cache("A3_FILIAL", "X3_DECIMAL")})		
	oSelf:addMapFields("sellerCode"     , "A3_COD"   , .T., .T.,  {"A3_COD"   , FWGetSX3Cache("A3_COD"   , "X3_TIPO"), FWGetSX3Cache("A3_COD"   , "X3_TAMANHO"), FWGetSX3Cache("A3_COD"   , "X3_DECIMAL")})
	oSelf:addMapFields("sellerShortName", "A3_NREDUZ", .T., .T.,  {"A3_NREDUZ", FWGetSX3Cache("A3_NREDUZ", "X3_TIPO"), FWGetSX3Cache("A3_NREDUZ", "X3_TAMANHO"), FWGetSX3Cache("A3_NREDUZ", "X3_DECIMAL")})		
	oSelf:addMapFields("dddCode"        , "A3_DDDTEL", .T., .T.,  {"A3_DDDTEL", FWGetSX3Cache("A3_DDDTEL", "X3_TIPO"), FWGetSX3Cache("A3_DDDTEL", "X3_TAMANHO"), FWGetSX3Cache("A3_DDDTEL", "X3_DECIMAL")})
	oSelf:addMapFields("phoneNumber"    , "A3_TEL"   , .T., .T.,  {"A3_TEL"   , FWGetSX3Cache("A3_TEL"   , "X3_TIPO"), FWGetSX3Cache("A3_TEL"   , "X3_TAMANHO"), FWGetSX3Cache("A3_TEL"   , "X3_DECIMAL")})

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
	cQuery += " FROM " + RetSqlName("SA3") + " SA3 "
	cQuery += " WHERE #QueryWhere# "

Return cQuery
