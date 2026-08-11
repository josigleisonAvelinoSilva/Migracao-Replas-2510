#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RESTFUL.CH"


WSRESTFUL mgv_salesorder DESCRIPTION "Sales Orders" FORMAT "application/json"

    WSDATA Page 		AS INTEGER OPTIONAL
	WSDATA PageSize		AS INTEGER OPTIONAL
    WSDATA Order        AS INTEGER OPTIONAL
    WSDATA Fields       AS CHARACTER OPTIONAL
    WSDATA Inirec       AS INTEGER OPTIONAL
    WSDATA Maxrec       AS INTEGER OPTIONAL

    WSMETHOD POST DESCRIPTION "Create Sales Order" ;
             WSSYNTAX "/replas/api/mgv_salesorder/" ;
             PATH "/replas/api/mgv_salesorder/" ;
             TTALK 'v1' ;
             PRODUCES APPLICATION_JSON
       
END WSRESTFUL



WSMETHOD POST WSREST mgv_salesorder
    Local cJson    := Self:getContent()
    Local oJson    := JsonObject():new()
    Local nStart   := Seconds()
    Local nElapsed := 0
  
    ::setContentType("application/json")
    ::setHeader("Access-Control-Allow-Origin", "*")
    ::setHeader("Access-Control-Allow-Headers", "*")
    ::setHeader("Access-Control-Allow-Credentials", "true")

    Default ::Inirec := 1 , ::Maxrec := 1 , ::PageSize := 10

    oJson:fromJson(U_XMGVCPV(cJson))    

    If (oJson["code"] == 142)
        ::setStatus(200)
    Else
        ::setStatus(400)        
    EndIf

    //-- Tempo decorrido em Milissegundo
    nElapsed := ((Seconds() - nStart) * 1000)

    Conout("---------------------------------------------------------")
    VarInfo("mgv_salesorder - nElapsedTime", nElapsed)
    Conout("---------------------------------------------------------")

    ::setResponse(oJson)

Return .T.
