#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RESTFUL.CH"


WSRESTFUL mgv_customer DESCRIPTION "Customer Data" FORMAT "application/json"
	
    WSDATA Page     AS INTEGER OPTIONAL
	WSDATA PageSize AS INTEGER OPTIONAL
    WSDATA Order    AS CHARACTER OPTIONAL
    WSDATA Fields   AS CHARACTER OPTIONAL

    WSMETHOD POST DESCRIPTION  "Returns Customer Data" ;
             WSSYNTAX "/replas/api/mgv_customer/" ;
             PATH "/replas/api/mgv_customer/" ;
             TTALK 'v1' ;
             PRODUCES APPLICATION_JSON

END WSRESTFUL


WSMETHOD POST WSREST mgv_customer

    If Select("SM0") == 0
        RpcSetEnv("00")
    EndIf

Return getCustomerData(self)


/*/{Protheus.doc} getCustomerData
Rotina que retorna os dados dos Clientes
@type function
@@version 1.0  
@author DO THINK - DENER LEMOS
@since 15/10/2025
@param oWS, object, Objeto web
@return logical, indica se foi ou nao processado corretamente
/*/
Static Function getCustomerData(oWS)
    Local lRet          := .T.  as logical 
    Local nPage       
    Local nPageSize   
    Local cOrder      
    Local cFields     
    Local aQueryString := {}
    Local cErroBlk     := ''
    Local oDataBase    as object
    Local oBody        as object    
    Local oException   := ErrorBlock({|e| cErroBlk := + e:Description + e:ErrorStack, lRet := .F. })
    Local oResponse    := JsonObject():new()
    Local cJSONReq     := FWCutOff(oWS:getContent())
    Local cJSONResp    := ""
    
    lRet := .T.

    Begin Sequence

        oBody  := JsonObject():new()
        cCatch := oBody:fromJSON(cJSONReq) 

        If cCatch == Nil 
            oWS:Page     := If(oBody:hasProperty("page")    , oBody["page"]    , 1)
            oWS:PageSize := If(oBody:hasProperty("pageSize"), oBody["pageSize"], 10)

            If oBody:hasProperty("fields")
                oWS:Fields := oBody["fields"]
            EndIf

            If oBody:hasProperty("filterString")
                oWS:aQueryString := u_StrFilter(oBody["filterString"])
            Endif
        EndIf

        If Empty(oWS:Page)
            oWS:Page := 1
        EndIf

        If Empty(oWS:PageSize)
            oWS:PageSize := 10
        EndIf

        nPage        := oWS:Page
        nPageSize    := oWS:PageSize
        cOrder       := oWS:Order
        cFields      := oWS:Fields
        aQueryString := oWS:aQueryString

        Conout("---------------------------------------------------------")
        VarInfo("cJSONReq", cJSONReq)
        Conout("---------------------------------------------------------")

        Conout("---------------------------------------------------------")
        VarInfo("oBody", oBody)
        Conout("---------------------------------------------------------")

        Conout("---------------------------------------------------------")
        VarInfo("oWS:aQueryString", oWS:aQueryString)
        Conout("---------------------------------------------------------")

        Conout("---------------------------------------------------------")
        VarInfo("nPage", nPage)
        Conout("---------------------------------------------------------")

        Conout("---------------------------------------------------------")
        VarInfo("nPageSize", nPageSize)
        Conout("---------------------------------------------------------")

        Conout("---------------------------------------------------------")
        VarInfo("cOrder", cOrder)
        Conout("---------------------------------------------------------")

        Conout("---------------------------------------------------------")
        VarInfo("cFields", cFields)
        Conout("---------------------------------------------------------")

        Conout("---------------------------------------------------------")
        VarInfo("aQueryString", aQueryString)
        Conout("---------------------------------------------------------")

        Conout("---------------------------------------------------------")
        VarInfo("oWs novo", oWS)
        Conout("---------------------------------------------------------")  

        oDataBase := mgv_CustomerDataAdapter():new("GET") 
        oDataBase:setPage(nPage)
        oDataBase:setPageSize(nPageSize)
        oDataBase:setOrderQuery(cOrder)
        oDataBase:setFields(cFields)  
        oDataBase:setUrlFilter(aQueryString)
        oDataBase:getListCustomerData()
  
    End Sequence

    ErrorBlock(oException)
  
    If lRet
        //-- Verifica execucao da query
        If oDataBase:lOk
            //-- Chama funcao para incluir mensagem adicional 
            cJSONResp := u_AdicResp(oDataBase:getJSONResponse(), 142, "Success", "Operation success")
            cJSONResp := EncodeUTF8(cJSONResp)

            oWS:setResponse(cJSONResp)
            oWS:setStatus(200)
        Else
            oResponse["code"           ] := 134 
            oResponse["status"         ] := 400
            oResponse["message"        ] := "Error"
            oResponse["detailedMessage"] := "It was not possible to filter the records! " + oDataBase:GetMessage()
            
            lRet := .F.
        EndIf
    Else
        oResponse["code"            ] := 133
        oResponse["status"          ] := 500
        oResponse["message"         ] := "Error"
        oResponse["detailedMessage" ] := "An unexpected error occurred in the service! " + cErroBlk
    EndIf

    If !lRet
        SetRestFault( oResponse["code"]             ,;
                      oResponse["message"]          ,;
                      .T.                           ,;
                      oResponse["status"]           ,;
                      oResponse["detailedMessage"]  ;
                    )
    EndIf
  
    oDataBase:deActivate()

    FreeObj(oDataBase)
    FreeObj(oResponse)  
    
Return lRet
