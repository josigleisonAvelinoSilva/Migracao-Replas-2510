#INCLUDE "TOTVS.CH"
#INCLUDE "PARMTYPE.CH"


/*/{Protheus.doc} mgv_CarrierDataAdapter
Classe de consulta dos dados das transportadoras para utilizacao do FWAdapterBaseV2
@type class
@version 1.0   
@author DO THINK - DENER LEMOS
@since 15/10/2025
/*/
CLASS mgv_CarrierDataAdapter FROM FWAdapterBaseV2

	METHOD new()
	METHOD getListCarrierData()

EndClass


/*/{Protheus.doc} mgv_CarrierDataAdapter::New
Classe de criacao do metodo mgv_CarrierDataAdapter
@type method
@version 1.0   
@author DO THINK - DENER LEMOS
@since 15/10/2025
@param cVerb, character, Verbo usado
/*/
Method new(cVerb) CLASS mgv_CarrierDataAdapter

	_Super:new(cVerb, .T.)

Return


/*/{Protheus.doc} mgv_CarrierDataAdapter::getListCarrierData
Metodo de listagem dos dados das transportadoras
@type method
@version 1.0   
@author DO THINK - DENER LEMOS
@since 15/10/2025
/*/
Method getListCarrierData() CLASS mgv_CarrierDataAdapter
	Local aAreaAnt AS ARRAY
	Local cWhere   AS CHAR

	aAreaAnt := FWGetArea()

	//-- Adiciona o mapa de campos Json/ResultSet
	AddMapFields(self)

	//-- Informa a Query a ser utilizada pela API
	::setQuery(GetQuery())

	//-- Informa a clausula Where da Query
	cWhere := " SA4.A4_FILIAL = '" + FWxFilial('SA4') + "' AND SA4.D_E_L_E_T_ = ' ' "

	::setWhere(cWhere)

	//-- Informa a ordenacao padrao a ser utilizada pela Query
	::setOrder(SA4->(StrTran(IndexKey(1), "+", ",")))

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

	oSelf:addMapFields("branchId"         , "A4_FILIAL" , .T., .T.,  {"A4_FILIAL" , FWGetSX3Cache("A4_FILIAL" , "X3_TIPO"),  FWGetSX3Cache("A4_FILIAL" , "X3_TAMANHO"), FWGetSX3Cache("A4_FILIAL" , "X3_DECIMAL")})		
	oSelf:addMapFields("carrierCode"      , "A4_COD"    , .T., .T.,  {"A4_COD"    , FWGetSX3Cache("A4_COD"    , "X3_TIPO"),  FWGetSX3Cache("A4_COD"    , "X3_TAMANHO"), FWGetSX3Cache("A4_COD"    , "X3_DECIMAL")})
	oSelf:addMapFields("carrierName"      , "A4_NOME"   , .T., .T.,  {"A4_NOME"   , FWGetSX3Cache("A4_NOME"   , "X3_TIPO"),  FWGetSX3Cache("A4_NOME"   , "X3_TAMANHO"), FWGetSX3Cache("A4_NOME"   , "X3_DECIMAL")})		
	oSelf:addMapFields("carrierShortName" , "A4_NREDUZ" , .T., .T.,  {"A4_NREDUZ" , FWGetSX3Cache("A4_NREDUZ" , "X3_TIPO"),  FWGetSX3Cache("A4_NREDUZ" , "X3_TAMANHO"), FWGetSX3Cache("A4_NREDUZ" , "X3_DECIMAL")})
	oSelf:addMapFields("cnpj"             , "A4_CGC"    , .T., .T.,  {"A4_CGC"    , FWGetSX3Cache("A4_CGC"    , "X3_TIPO"),  FWGetSX3Cache("A4_CGC"    , "X3_TAMANHO"), FWGetSX3Cache("A4_CGC"    , "X3_DECIMAL")})
	oSelf:addMapFields("dddCode"          , "A4_DDD"    , .T., .T.,  {"A4_DDD"    , FWGetSX3Cache("A4_DDD"    , "X3_TIPO"),  FWGetSX3Cache("A4_DDD"    , "X3_TAMANHO"), FWGetSX3Cache("A4_DDD"    , "X3_DECIMAL")})
	oSelf:addMapFields("carrierPhone"     , "A4_TEL"    , .T., .T.,  {"A4_TEL"    , FWGetSX3Cache("A4_TEL"    , "X3_TIPO"),  FWGetSX3Cache("A4_TEL"    , "X3_TAMANHO"), FWGetSX3Cache("A4_TEL"    , "X3_DECIMAL")})

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
	cQuery += " FROM " + RetSqlName("SA4") + " SA4 "
	cQuery += " WHERE #QueryWhere# "

Return cQuery
