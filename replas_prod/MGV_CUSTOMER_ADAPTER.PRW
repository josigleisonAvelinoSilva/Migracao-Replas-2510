#INCLUDE "TOTVS.CH"
#INCLUDE "PARMTYPE.CH"


/*/{Protheus.doc} mgv_CustomerDataAdapter
Classe de consulta dos dados dos Clientes para utilizacao do FWAdapterBaseV2
@type class
@version 1.0   
@author DO THINK - DENER LEMOS
@since 15/10/2025
/*/
CLASS mgv_CustomerDataAdapter FROM FWAdapterBaseV2

	METHOD new()
	METHOD getListCustomerData()

EndClass


/*/{Protheus.doc} mgv_CustomerDataAdapter::New
Classe de criacao do metodo mgv_CustomerDataAdapter
@type method
@version 1.0   
@author DO THINK - DENER LEMOS
@since 15/10/2025
@param cVerb, character, Verbo usado
/*/
Method new(cVerb) CLASS mgv_CustomerDataAdapter

	_Super:new(cVerb, .T.)

Return


/*/{Protheus.doc} mgv_CustomerDataAdapter::getListCustomerData
Metodo de listagem dos dados os Clientes
@type method
@version 1.0   
@author DO THINK - DENER LEMOS
@since 15/10/2025
/*/
Method getListCustomerData() CLASS mgv_CustomerDataAdapter
	Local aAreaAnt AS ARRAY
	Local cWhere   AS CHAR

	aAreaAnt := FWGetArea()

	//-- Adiciona o mapa de campos Json/ResultSet
	AddMapFields(self)

	//-- Informa a Query a ser utilizada pela API
	::setQuery(GetQuery())

	//-- Informa a clausula Where da Query
	cWhere := " SA1.A1_FILIAL = '" + FWxFilial('SA1') + "' AND SA1.D_E_L_E_T_ = ' ' "

	::setWhere(cWhere)

	//-- Informa a ordenacao padrao a ser utilizada pela Query
	::setOrder(SA1->(StrTran(IndexKey(1), "+", ",")))

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

	oSelf:addMapFields("branchId"         , "A1_FILIAL" , .T., .T.,  {"A1_FILIAL" , FWGetSX3Cache("A1_FILIAL" , "X3_TIPO"),  FWGetSX3Cache("A1_FILIAL" , "X3_TAMANHO"), FWGetSX3Cache("A1_FILIAL" , "X3_DECIMAL")})		
	oSelf:addMapFields("customerCode"     , "A1_COD"    , .T., .T.,  {"A1_COD"    , FWGetSX3Cache("A1_COD"    , "X3_TIPO"),  FWGetSX3Cache("A1_COD"    , "X3_TAMANHO"), FWGetSX3Cache("A1_COD"    , "X3_DECIMAL")})
	oSelf:addMapFields("customerBranch"   , "A1_LOJA"   , .T., .T.,  {"A1_LOJA"   , FWGetSX3Cache("A1_LOJA"   , "X3_TIPO"),  FWGetSX3Cache("A1_LOJA"   , "X3_TAMANHO"), FWGetSX3Cache("A1_LOJA"   , "X3_DECIMAL")})		
	oSelf:addMapFields("customerName"     , "A1_NOME"   , .T., .T.,  {"A1_NOME"   , FWGetSX3Cache("A1_NOME"   , "X3_TIPO"),  FWGetSX3Cache("A1_NOME"   , "X3_TAMANHO"), FWGetSX3Cache("A1_NOME"   , "X3_DECIMAL")})
	oSelf:addMapFields("customerShortName", "A1_NREDUZ" , .T., .T.,  {"A1_NREDUZ" , FWGetSX3Cache("A1_NREDUZ" , "X3_TIPO"),  FWGetSX3Cache("A1_NREDUZ" , "X3_TAMANHO"), FWGetSX3Cache("A1_NREDUZ" , "X3_DECIMAL")})
	oSelf:addMapFields("natLegalPerson"   , "A1_PESSOA" , .T., .T.,  {"A1_PESSOA" , FWGetSX3Cache("A1_PESSOA" , "X3_TIPO"),  FWGetSX3Cache("A1_PESSOA" , "X3_TAMANHO"), FWGetSX3Cache("A1_PESSOA" , "X3_DECIMAL")})
	oSelf:addMapFields("address"          , "A1_END"    , .T., .T.,  {"A1_END"    , FWGetSX3Cache("A1_END"    , "X3_TIPO"),  FWGetSX3Cache("A1_END"    , "X3_TAMANHO"), FWGetSX3Cache("A1_END"    , "X3_DECIMAL")})
	oSelf:addMapFields("district"         , "A1_BAIRRO" , .T., .T.,  {"A1_BAIRRO" , FWGetSX3Cache("A1_BAIRRO" , "X3_TIPO"),  FWGetSX3Cache("A1_BAIRRO" , "X3_TAMANHO"), FWGetSX3Cache("A1_BAIRRO" , "X3_DECIMAL")})
	oSelf:addMapFields("type"             , "A1_TIPO"   , .T., .T.,  {"A1_TIPO"   , FWGetSX3Cache("A1_TIPO"   , "X3_TIPO"),  FWGetSX3Cache("A1_TIPO"   , "X3_TAMANHO"), FWGetSX3Cache("A1_TIPO"   , "X3_DECIMAL")})
	oSelf:addMapFields("state"            , "A1_EST"    , .T., .T.,  {"A1_EST"    , FWGetSX3Cache("A1_EST"    , "X3_TIPO"),  FWGetSX3Cache("A1_EST"    , "X3_TAMANHO"), FWGetSX3Cache("A1_EST"    , "X3_DECIMAL")})
	oSelf:addMapFields("zipCode"          , "A1_CEP"    , .T., .T.,  {"A1_CEP"    , FWGetSX3Cache("A1_CEP"    , "X3_TIPO"),  FWGetSX3Cache("A1_CEP"    , "X3_TAMANHO"), FWGetSX3Cache("A1_CEP"    , "X3_DECIMAL")})
	oSelf:addMapFields("cityCode"         , "A1_COD_MUN", .T., .T.,  {"A1_COD_MUN", FWGetSX3Cache("A1_COD_MUN", "X3_TIPO"),  FWGetSX3Cache("A1_COD_MUN", "X3_TAMANHO"), FWGetSX3Cache("A1_COD_MUN", "X3_DECIMAL")})
	oSelf:addMapFields("cityDescription"  , "A1_MUN"    , .T., .T.,  {"A1_MUN"    , FWGetSX3Cache("A1_MUN"    , "X3_TIPO"),  FWGetSX3Cache("A1_MUN"    , "X3_TAMANHO"), FWGetSX3Cache("A1_MUN"    , "X3_DECIMAL")})
	oSelf:addMapFields("customerEmail"    , "A1_EMAIL"  , .T., .T.,  {"A1_EMAIL"  , FWGetSX3Cache("A1_EMAIL"  , "X3_TIPO"),  FWGetSX3Cache("A1_EMAIL"  , "X3_TAMANHO"), FWGetSX3Cache("A1_EMAIL"  , "X3_DECIMAL")})
	oSelf:addMapFields("dddCode"          , "A1_DDD"    , .T., .T.,  {"A1_DDD"    , FWGetSX3Cache("A1_DDD"    , "X3_TIPO"),  FWGetSX3Cache("A1_DDD"    , "X3_TAMANHO"), FWGetSX3Cache("A1_DDD"    , "X3_DECIMAL")})
	oSelf:addMapFields("phoneNumber"      , "A1_TEL"    , .T., .T.,  {"A1_TEL"    , FWGetSX3Cache("A1_TEL"    , "X3_TIPO"),  FWGetSX3Cache("A1_TEL"    , "X3_TAMANHO"), FWGetSX3Cache("A1_TEL"    , "X3_DECIMAL")})
	oSelf:addMapFields("contactName"      , "A1_CONTATO", .T., .T.,  {"A1_CONTATO", FWGetSX3Cache("A1_CONTATO", "X3_TIPO"),  FWGetSX3Cache("A1_CONTATO", "X3_TAMANHO"), FWGetSX3Cache("A1_CONTATO", "X3_DECIMAL")})
	oSelf:addMapFields("countryCode"      , "A1_PAIS"   , .T., .T.,  {"A1_PAIS"   , FWGetSX3Cache("A1_PAIS"   , "X3_TIPO"),  FWGetSX3Cache("A1_PAIS"   , "X3_TAMANHO"), FWGetSX3Cache("A1_PAIS"   , "X3_DECIMAL")})
	oSelf:addMapFields("cnpj"             , "A1_CGC"    , .T., .T.,  {"A1_CGC"    , FWGetSX3Cache("A1_CGC"    , "X3_TIPO"),  FWGetSX3Cache("A1_CGC"    , "X3_TAMANHO"), FWGetSX3Cache("A1_CGC"    , "X3_DECIMAL")})
	oSelf:addMapFields("stateRegistration", "A1_INSCR"  , .T., .T.,  {"A1_INSCR"  , FWGetSX3Cache("A1_INSCR"  , "X3_TIPO"),  FWGetSX3Cache("A1_INSCR"  , "X3_TAMANHO"), FWGetSX3Cache("A1_INSCR"  , "X3_DECIMAL")})
	oSelf:addMapFields("cityRegistration" , "A1_INSCRM" , .T., .T.,  {"A1_INSCRM" , FWGetSX3Cache("A1_INSCRM" , "X3_TIPO"),  FWGetSX3Cache("A1_INSCRM" , "X3_TAMANHO"), FWGetSX3Cache("A1_INSCRM" , "X3_DECIMAL")})
	oSelf:addMapFields("sellerCode1"      , "A1_VEND"   , .T., .T.,  {"A1_VEND"   , FWGetSX3Cache("A1_VEND"   , "X3_TIPO"),  FWGetSX3Cache("A1_VEND"   , "X3_TAMANHO"), FWGetSX3Cache("A1_VEND"   , "X3_DECIMAL")})
	oSelf:addMapFields("sellerCode2"      , "A1_XVEND2" , .T., .T.,  {"A1_XVEND2" , FWGetSX3Cache("A1_XVEND2" , "X3_TIPO"),  FWGetSX3Cache("A1_XVEND2" , "X3_TAMANHO"), FWGetSX3Cache("A1_XVEND2" , "X3_DECIMAL")})
	oSelf:addMapFields("purchaserEmail"   , "A1_XEMAIL" , .T., .T.,  {"A1_XEMAIL" , FWGetSX3Cache("A1_XEMAIL" , "X3_TIPO"),  FWGetSX3Cache("A1_XEMAIL" , "X3_TAMANHO"), FWGetSX3Cache("A1_XEMAIL" , "X3_DECIMAL")})
	oSelf:addMapFields("creditLimit"      , "A1_LC"     , .T., .T.,  {"A1_LC"     , FWGetSX3Cache("A1_LC"     , "X3_TIPO"),  FWGetSX3Cache("A1_LC"     , "X3_TAMANHO"), FWGetSX3Cache("A1_LC"     , "X3_DECIMAL")})
	oSelf:addMapFields("bondBalance"      , "A1_SALDUP" , .T., .T.,  {"A1_SALDUP" , FWGetSX3Cache("A1_SALDUP" , "X3_TIPO"),  FWGetSX3Cache("A1_SALDUP" , "X3_TAMANHO"), FWGetSX3Cache("A1_SALDUP" , "X3_DECIMAL")})
	oSelf:addMapFields("availCreditLimit" , "CREDDISP"  , .T., .T.,  {"CREDDISP"  , FWGetSX3Cache("A1_LC"     , "X3_TIPO"),  FWGetSX3Cache("A1_LC"     , "X3_TAMANHO"), FWGetSX3Cache("A1_LC"     , "X3_DECIMAL")}, "A1_LC - A1_SALDUP")
	oSelf:addMapFields("delayedValues"    , "A1_ATR"    , .T., .T.,  {"A1_ATR"    , FWGetSX3Cache("A1_ATR"    , "X3_TIPO"),  FWGetSX3Cache("A1_ATR"    , "X3_TAMANHO"), FWGetSX3Cache("A1_ATR"    , "X3_DECIMAL")})
	oSelf:addMapFields("paymentCond"      , "A1_COND"   , .T., .T.,  {"A1_COND"   , FWGetSX3Cache("A1_COND"   , "X3_TIPO"),  FWGetSX3Cache("A1_COND"   , "X3_TAMANHO"), FWGetSX3Cache("A1_COND"   , "X3_DECIMAL")})
	oSelf:addMapFields("carrierType"      , "A1_TPFRET" , .T., .T.,  {"A1_TPFRET" , FWGetSX3Cache("A1_TPFRET" , "X3_TIPO"),  FWGetSX3Cache("A1_TPFRET" , "X3_TAMANHO"), FWGetSX3Cache("A1_TPFRET" , "X3_DECIMAL")})
	oSelf:addMapFields("carrierCode"      , "A1_TRANSP" , .T., .T.,  {"A1_TRANSP" , FWGetSX3Cache("A1_TRANSP" , "X3_TIPO"),  FWGetSX3Cache("A1_TRANSP" , "X3_TAMANHO"), FWGetSX3Cache("A1_TRANSP" , "X3_DECIMAL")})

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
	cQuery += " FROM " + RetSqlName("SA1") + " SA1 "
	cQuery += " WHERE #QueryWhere# "

Return cQuery
