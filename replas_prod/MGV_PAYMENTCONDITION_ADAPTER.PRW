#INCLUDE "TOTVS.CH"
#INCLUDE "PARMTYPE.CH"


/*/{Protheus.doc} mgv_PaymentConditionAdapter
Classe de consulta de condicoes de paramento para utilizacao do FWAdapterBaseV2
@type class
@version 1.0   
@author DO THINK - DENER LEMOS
@since 15/10/2025
/*/
CLASS mgv_PaymentConditionAdapter FROM FWAdapterBaseV2

	METHOD new()
	METHOD getListPaymentCondition()

EndClass


/*/{Protheus.doc} mgv_PaymentConditionAdapter::New
Classe de criacao do metodo mgv_PaymentConditionAdapter
@type method
@version 1.0   
@author DO THINK - DENER LEMOS
@since 15/10/2025
@param cVerb, character, Verbo usado
/*/
Method new(cVerb) CLASS mgv_PaymentConditionAdapter

	_Super:new(cVerb, .T.)

Return


/*/{Protheus.doc} mgv_PaymentConditionAdapter::getListPaymentCondition
Metodo de listagem de condicoes de pagamento
@type method
@version 1.0   
@author DO THINK - DENER LEMOS
@since 15/10/2025
/*/
Method getListPaymentCondition() CLASS mgv_PaymentConditionAdapter
	Local aAreaAnt AS ARRAY
	Local cWhere   AS CHAR

	aAreaAnt := FWGetArea()

	//-- Adiciona o mapa de campos Json/ResultSet
	AddMapFields(self)

	//-- Informa a Query a ser utilizada pela API
	::setQuery(GetQuery())

	//-- Informa a clausula Where da Query
	cWhere := " SE4.E4_FILIAL = '" + FWxFilial('SE4') + "' AND SE4.D_E_L_E_T_ = ' ' "

	::setWhere(cWhere)

	//-- Informa a ordenacao padrao a ser utilizada pela Query
	::setOrder(SE4->(StrTran(IndexKey(1), "+", ",")))

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

	oSelf:addMapFields("branchId"        , "E4_FILIAL" , .T., .T.,  {"E4_FILIAL" , FWGetSX3Cache("E4_FILIAL" , "X3_TIPO"),  FWGetSX3Cache("E4_FILIAL" , "X3_TAMANHO"), FWGetSX3Cache("E4_FILIAL" , "X3_DECIMAL")})		
	oSelf:addMapFields("paymentCondCode" , "E4_CODIGO" , .T., .T.,  {"E4_CODIGO" , FWGetSX3Cache("E4_CODIGO" , "X3_TIPO"),  FWGetSX3Cache("E4_CODIGO" , "X3_TAMANHO"), FWGetSX3Cache("E4_CODIGO" , "X3_DECIMAL")})
	oSelf:addMapFields("paymentCondType" , "E4_TIPO"   , .T., .T.,  {"E4_TIPO"   , FWGetSX3Cache("E4_TIPO"   , "X3_TIPO"),  FWGetSX3Cache("E4_TIPO"   , "X3_TAMANHO"), FWGetSX3Cache("E4_TIPO"   , "X3_DECIMAL")})		
	oSelf:addMapFields("paymentCondition", "E4_COND"   , .T., .T.,  {"E4_COND"   , FWGetSX3Cache("E4_COND"   , "X3_TIPO"),  FWGetSX3Cache("E4_COND"   , "X3_TAMANHO"), FWGetSX3Cache("E4_COND"   , "X3_DECIMAL")})
	oSelf:addMapFields("paymentCondDesc" , "E4_DESCRI" , .T., .T.,  {"E4_DESCRI" , FWGetSX3Cache("E4_DESCRI" , "X3_TIPO"),  FWGetSX3Cache("E4_DESCRI" , "X3_TAMANHO"), FWGetSX3Cache("E4_DESCRI" , "X3_DECIMAL")})

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
	cQuery += " FROM " + RetSqlName("SE4") + " SE4 "
	cQuery += " WHERE #QueryWhere# "

Return cQuery
