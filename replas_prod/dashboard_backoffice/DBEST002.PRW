#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

//-- API Grafico Saldos por Bobina
WSRESTFUL dbest002 DESCRIPTION "Saldos por Bobina"
    WSDATA JsonFilter       AS STRING   OPTIONAL
    WSDATA drillDownFilter  AS STRING   OPTIONAL
    WSDATA Page             AS INTEGER  OPTIONAL
    WSDATA PageSize         AS INTEGER  OPTIONAL

    WSMETHOD GET form ;
        DESCRIPTION "Form de Cadastro do Gráfico" ;
        WSSYNTAX "/charts/form/" ;
        PATH "/charts/form";
        PRODUCES APPLICATION_JSON
  
    WSMETHOD POST retdados ;
        DESCRIPTION "Retorna as Informações do Gráfico" ;
        WSSYNTAX "/charts/retdados/{JsonFilter}" ;
        PATH "/charts/retdados";
        PRODUCES APPLICATION_JSON
  
    WSMETHOD POST itemsDetails ;
        DESCRIPTION "Carrega o detalhamento do gráfico" ;
        WSSYNTAX "/charts/itemsDetails/{JsonFilter}" ;
        PATH "/charts/itemsDetails";
        PRODUCES APPLICATION_JSON
  
ENDWSRESTFUL

/*Retorna os campos que apresentados no Cadastro do Grafico.
Devera seguir o formato do Dynamic Form do PO-UI.
https://po-ui.io/tools/dynamic-form*/
WSMETHOD GET form WSSERVICE dbest002
    Local oResponse   := JsonObject():New()
    Local oCoreDash   := CoreDash():New()

    oCoreDash:SetPOForm("Tipo de Gráfico", "charttype"  , 6, "Tipo de Gráfico", .T., "string", oCoreDash:SetPOCombo({{"pie","Pizza"},{"polarArea","Polar"}}))
    oCoreDash:SetPOForm("Filial"         , "filial"     , 6, "Filial"         , .T.,         , GetFil(), .T.)
    oCoreDash:SetPOForm("Armazém"        , "armazem"    , 6, "Armazém"        , .T.,         , GetArm(), .T.)

    oResponse  := oCoreDash:GetPOForm()
  
    Self:SetResponse( EncodeUtf8(oResponse:ToJson()))

Return .T.

/*Retorna um objeto JSON com as informações e valores do Grafico*/
WSMETHOD POST retdados WSRECEIVE JsonFilter WSSERVICE dbest002
    Local oResponse   := JsonObject():New()
    Local oCoreDash   := CoreDash():New()
    Local oJson       := JsonObject():New()
  
    oJson:FromJson(DecodeUtf8(Self:GetContent()))
  
    retDados(@oResponse, oCoreDash, oJson)
  
    Self:SetResponse( EncodeUtf8(oResponse:ToJson()))
  
    oResponse := Nil
    FreeObj( oResponse )
  
    oCoreDash:Destroy()
    FreeObj( oCoreDash )
  
Return .T.

/*Retorna os items utilizado no Drilldown*/
WSMETHOD POST itemsDetails WSRECEIVE JsonFilter, drillDownFilter WSRESTFUL dbest002
    Local aHeader       := {}
    Local aItems        := {}
    Local aRet          := {}
    Local cBody         := DecodeUtf8(Self:GetContent())
    Local cError        := "Erro na Requisição"
    Local cSelect       := ""
    Local cWhere        := ""
    Local cGroup        := ""
    Local cOrder        := ""
    Local lRet          := .T.
    Local oCoreDash     := CoreDash():New()
    Local oBody         := JsonObject():New()
    Local oJsonFilter   := JsonObject():New()
    Local oJsonDD       := JsonObject():New()
    Local aQueryString  := {}
  
    If !Empty(cBody)
        oBody:FromJson(cBody)
  
        If ValType(oBody["chartFilter"]) == "J"
            oJsonFilter := oBody["chartFilter"]
        EndIf
  
        If ValType(oBody["detailFilter"]) == "A"
            oJsonDD := oBody["detailFilter"]
        EndIf
    EndIf

    Self:SetContentType("application/json")

    If oJsonFilter:GetJsonText("level") == "null" .Or. Len(oJsonFilter["level"]) == 0
        If Len(oJsonDD) == 0 //Nivel 1 do Drilldown
            aHeader := {;
                {"B1_XTPFILM"       , "Tipo Filme", "link"},;
                {"B8_SALDO"         , "Saldo", "number", "1.2-5"},;
                {"ZF_SALDO_RESERVA" , "Reserva", "number", "1.2-5"},;
                {"B8_DISPONIVEL"    , "Disponivel", "number", "1.2-5"},;
                {"X5_DESCRI"        , "Descrição"         };
                }

            aItems := {;
                {"B1_XTPFILM"       , "B1_XTPFILM"},;
                {"B8_SALDO"         , "SLDTOTAL" },;
                {"ZF_SALDO_RESERVA" , "RESERVTOTAL" },;
                {"B8_DISPONIVEL"    , "DISPONIVEL" },;
                {"X5_DESCRI"        , "X5_DESCRI" };
                }

            cSelect := " tbl.B1_XTPFILM, tbl.X5_DESCRI, SUM(B8_SALDO) SLDTOTAL, SUM(ZF_SALDO_RESERVA) RESERVTOTAL, SUM(B8_SALDO) - SUM(ZF_SALDO_RESERVA) DISPONIVEL "
            cWhere  := " "
            cGroup  := " tbl.B1_XTPFILM, tbl.X5_DESCRI "
            cOrder  := " B1_XTPFILM "

            aQueryString  := {}
            aAdd(aQueryString, {"order", cOrder})
            //aAdd(aQueryString, {"page", 1})
            //aAdd(aQueryString, {"pagesize", 25})

            aRet := QryLevel(cSelect, cWhere, cGroup, oJsonFilter["filial"])

        ElseIf Len(oJsonDD) == 1 //Nivel 2 do Drilldown
            aHeader := {;
                {"B1_XTPFILM"       , "Tipo Filme"},;
                {"FAMILIA"          , "Familia","link"},;
                {"B8_SALDO"         , "Saldo", "number", "1.2-5"},;
                {"ZF_SALDO_RESERVA" , "Reserva", "number", "1.2-5"},;
                {"B1_DESC"          , "Descrição"         };
                }

            aItems := {;
                {"B1_XTPFILM"        , "B1_XTPFILM"},;
                {"FAMILIA"           , "FAMILIA"     },;
                {"B8_SALDO"          , "SLDTOTAL" },;
                {"ZF_SALDO_RESERVA"  , "RESERVTOTAL" },;
                {"B1_DESC"           , "B1_DESC"     };
                }

            cSelect := " tbl.B1_XTPFILM, tbl.FAMILIA, tbl.B1_DESC, SUM(B8_SALDO) SLDTOTAL, SUM(ZF_SALDO_RESERVA) RESERVTOTAL "
            cWhere  := " B1_XTPFILM = '" + oJsonDD[1]["B1_XTPFILM"] + "' "
            cGroup  := " tbl.B1_XTPFILM, tbl.FAMILIA, tbl.B1_DESC "
            cOrder  := " B1_XTPFILM, FAMILIA "

            aQueryString  := {}
            aAdd(aQueryString, {"order", cOrder})
            //aAdd(aQueryString, {"page", 1})
            //aAdd(aQueryString, {"pagesize", 25})

            aRet := QryLevel(cSelect, cWhere, cGroup, oJsonFilter["filial"])

        Elseif Len(oJsonDD) == 2 //Nivel 3 do Drilldown
            aHeader := {;
                {"B1_XTPFILM"       , "Tipo Filme"},;
                {"FAMILIA"          , "Familia" },;
                {"B8_PRODUTO"       , "Produto", "link" },;
                {"B8_SALDO"         , "Saldo", "number", "1.2-5"},;
                {"ZF_SALDO_RESERVA" , "Reserva", "number", "1.2-5"},;
                {"B8_LOCAL"         , "Local"           },;
                {"B8_FILIAL"        , "Filial" };
                }

            aItems := {;
                {"B1_XTPFILM"       , "B1_XTPFILM"},;
                {"FAMILIA"          , "FAMILIA"     },;
                {"B8_PRODUTO"       , "B8_PRODUTO"},;
                {"B8_SALDO"         , "SLDTOTAL"},;
                {"ZF_SALDO_RESERVA" , "RESERVTOTAL" },;
                {"B8_LOCAL"         , "B8_LOCAL"},;
                {"B8_FILIAL"        , "B8_FILIAL"};
                }

            cSelect := " tbl.B8_FILIAL, tbl.B1_XTPFILM, tbl.FAMILIA, tbl.B8_PRODUTO, tbl.B8_LOCAL, SUM(B8_SALDO) SLDTOTAL, SUM(ZF_SALDO_RESERVA) RESERVTOTAL "
            cWhere  := " FAMILIA = '" + oJsonDD[2]["FAMILIA"] + "' "
            cGroup  := " tbl.B8_FILIAL, tbl.B1_XTPFILM, tbl.FAMILIA, tbl.B8_PRODUTO, tbl.B8_LOCAL "
            cOrder  := " B8_FILIAL, B1_XTPFILM, FAMILIA, B8_PRODUTO, B8_LOCAL "

            aQueryString  := {}
            aAdd(aQueryString, {"order", cOrder})
            //aAdd(aQueryString, {"page", 1})
            //aAdd(aQueryString, {"pagesize", 25})

            aRet := QryLevel(cSelect, cWhere, cGroup, oJsonFilter["filial"])

        Elseif Len(oJsonDD) == 3 //Nivel 4 do Drilldown
            aHeader := {;
                {"B1_XTPFILM"           , "Tipo Filme"},;
                {"FAMILIA"              , "Familia" },;
                {"B8_PRODUTO"           , "Produto"},;
                {"B8_LOTECTL"           , "Lote", "link"},;
                {"B8_SALDO"             , "Saldo", "number", "1.2-5"},;
                {"ZF_SALDO_RESERVA"     , "Reserva", "number", "1.2-5"},;
                {"B8_LOCAL"             , "Local"},;
                {"B8_FILIAL"            , "Filial"};
                }

            aItems := {;
                {"B1_XTPFILM"           , "B1_XTPFILM"},;
                {"FAMILIA"              , "FAMILIA"     },;
                {"B8_PRODUTO"           , "B8_PRODUTO"},;
                {"B8_LOTECTL"           , "B8_LOTECTL"},;
                {"B8_SALDO"             , "SLDTOTAL"},;
                {"ZF_SALDO_RESERVA"     , "RESERVTOTAL"},;
                {"B8_LOCAL"             , "B8_LOCAL"},;
                {"B8_FILIAL"            , "B8_FILIAL"};
                }

            cSelect := " tbl.B8_FILIAL, tbl.B1_XTPFILM, tbl.FAMILIA, tbl.B8_PRODUTO, tbl.B8_LOTECTL, tbl.B8_LOCAL, SUM(B8_SALDO) SLDTOTAL, SUM(ZF_SALDO_RESERVA) RESERVTOTAL "
            cWhere  := " B8_FILIAL = '" + oJsonDD[3]["B8_FILIAL"] + "' AND B8_PRODUTO = '" + oJsonDD[3]["B8_PRODUTO"] + "' "
            cGroup  := " tbl.B8_FILIAL, tbl.B1_XTPFILM, tbl.FAMILIA, tbl.B8_PRODUTO, tbl.B8_LOTECTL, tbl.B8_LOCAL "
            cOrder  := " B8_FILIAL, B1_XTPFILM, FAMILIA, B8_PRODUTO, B8_LOTECTL, B8_LOCAL "

            aQueryString  := {}
            aAdd(aQueryString, {"order", cOrder})
            //aAdd(aQueryString, {"page", 1})
            //aAdd(aQueryString, {"pagesize", 25})

            aRet := QryLevel(cSelect, cWhere, cGroup, oJsonFilter["filial"])

        Elseif Len(oJsonDD) == 4 //Nivel 5 do Drilldown
            aHeader := {;
                {"B1_XTPFILM"           , "Tipo Filme"},;
                {"FAMILIA"              , "Familia" },;
                {"B8_PRODUTO"           , "Produto"},;
                {"B8_LOTECTL"           , "Lote"},;
                {"B8_NUMLOTE"           , "Sub-Lote"},;
                {"B8_SALDO"             , "Saldo", "number", "1.2-5"},;
                {"ZF_SALDO_RESERVA"     , "Reserva", "number", "1.2-5"},;
                {"B8_LOCAL"             , "Local"           },;
                {"B8_FILIAL"            , "Filial"};
                }

            aItems := {;
                {"B1_XTPFILM"           , "B1_XTPFILM"},;
                {"FAMILIA"              , "FAMILIA"     },;
                {"B8_PRODUTO"           , "B8_PRODUTO"},;
                {"B8_LOTECTL"           , "B8_LOTECTL"},;
                {"B8_NUMLOTE"           , "B8_NUMLOTE"},;
                {"B8_SALDO"             , "B8_SALDO"},;
                {"ZF_SALDO_RESERVA"     , "ZF_SALDO_RESERVA"},;
                {"B8_LOCAL"             , "B8_LOCAL"},;
                {"B8_FILIAL"            , "B8_FILIAL"};
                }

            cSelect := " tbl.B8_FILIAL, tbl.B1_XTPFILM, tbl.FAMILIA, tbl.B8_PRODUTO, tbl.B8_LOTECTL, tbl.B8_NUMLOTE, B8_SALDO, ZF_SALDO_RESERVA, tbl.B8_LOCAL "
            cWhere  := " B8_FILIAL = '" + oJsonDD[4]["B8_FILIAL"] + "' AND B8_PRODUTO = '" + oJsonDD[4]["B8_PRODUTO"] + "' AND B8_LOTECTL = '" + oJsonDD[4]["B8_LOTECTL"] + "' "
            cGroup  := "  "
            cOrder  := " B8_FILIAL, B1_XTPFILM, FAMILIA, B8_NUMLOTE, B8_LOTECTL, B8_PRODUTO, B8_LOCAL "

            aQueryString  := {}
            aAdd(aQueryString, {"order", cOrder})
            //aAdd(aQueryString, {"page", 1})
            //aAdd(aQueryString, {"pagesize", 25})

            aRet := QryLevel(cSelect, cWhere, cGroup, oJsonFilter["filial"])

        Elseif Len(oJsonDD) == 5 //Nivel 6 do Drilldown
            aHeader := {;
                {"ZF_PEDIDO_RESERVA"    , "Pedido - Reserva"},;
                {"ZF_ITEMPV_RESERVA"    , "Item PV - Reserva"},;
                {"C5_XDESCLI_RESERVA"   , "Cliente - Reserva"},;
                {"ZF_SALDO_RESERVA"     , "Reserva", "number", "1.2-5"},;
                {"ZF_USRRES_RESERVA"    , "Usuario - Reserva"},;
                {"ZF_DTRES_RESERVA"     , "Data - Reserva"},;
                {"ZF_HRRES_RESERVA"     , "Hora - Reserva"};
                }

            aItems := {;
                {"ZF_PEDIDO_RESERVA"    , "ZF_PEDIDO_RESERVA"},;
                {"ZF_ITEMPV_RESERVA"    , "ZF_ITEMPV_RESERVA"},;
                {"C5_XDESCLI_RESERVA"   , "C5_XDESCLI_RESERVA"},;
                {"ZF_SALDO_RESERVA"     , "ZF_SALDO_RESERVA"},;
                {"ZF_USRRES_RESERVA"    , "ZF_USRRES_RESERVA"},;
                {"ZF_DTRES_RESERVA"     , "ZF_DTRES_RESERVA"},;
                {"ZF_HRRES_RESERVA"     , "ZF_HRRES_RESERVA"};
                }

            cSelect := " tbl.ZF_PEDIDO_RESERVA, tbl.ZF_ITEMPV_RESERVA, tbl.C5_XDESCLI_RESERVA, tbl.ZF_SALDO_RESERVA, tbl.ZF_USRRES_RESERVA, tbl.ZF_DTRES_RESERVA, tbl.ZF_HRRES_RESERVA "
            cWhere  := " ZF_PEDIDO_RESERVA = '" + oJsonDD[5]["ZF_PEDIDO_RESERVA"] "
            cGroup  := " "
            cOrder  := " ZF_PEDIDO_RESERVA, ZF_ITEMPV_RESERVA "

            aQueryString  := {}
            aAdd(aQueryString, {"order", cOrder})
            //aAdd(aQueryString, {"page", 1})
            //aAdd(aQueryString, {"pagesize", 25})

            aRet := QryLevel(cSelect, cWhere, cGroup, oJsonFilter["filial"])
        Endif
    /*Else
        //Monta o Drilldown do grafico nivel 2
        aHeader := {;
            {"document"     , "Documento"   },;
            {"series"       , "Serie"               },;
            {"state"        , "UF"                  },;
            {"documentType" , "Tipo"                },;
            {"dateOfIssue"  , "Emissão"             };
            }
  
        aItems := {;
            {"document"     , "F2_DOC"      },;
            {"series"       , "F2_SERIE"    },;
            {"state"        , "F2_EST"      },;
            {"documentType" , "F2_TIPO"     },;
            {"dateOfIssue"  , "F2_EMISSAO"  };
            }
  
        cSelect := " F2_DOC, F2_SERIE, F2_EST, F2_TIPO, F2_EMISSAO, F2_TIPO "
  
        aRet := QuerySF2(cSelect)*/
    EndIf

    oCoreDash:SetQuery(aRet[1])
    oCoreDash:SetWhere(aRet[2])
    oCoreDash:SetGroupBy(aRet[3])
    oCoreDash:SetFields(aItems)
    //oCoreDash:SetApiQstring(aQueryString)
    oCoreDash:SetApiQstring(Self:aQueryString)
    oCoreDash:BuildJson()
  
    If lRet
        oCoreDash:SetPOHeader(aHeader)
        Self:SetResponse( oCoreDash:ToObjectJson() )
    Else
        cError := oCoreDash:GetJsonError()
        SetRestFault( 500,  EncodeUtf8(cError) )
    EndIf
  
    oCoreDash:Destroy()
    FreeObj(oJsonDD)
    FreeObj(oJsonFilter)
    FreeObj(oBody)
  
    aSize(aRet, 0)
    aSize(aItems, 0)
    aSize(aHeader, 0)
  
Return lRet

/*Retorna os dados que poderão ser apresentados no Grafico*/
Static Function retDados(oResponse, oCoreDash, oJson)
    Local aData     := {}
    Local aDataFim  := {}
    Local aCab      := {}
    Local aCores    := oCoreDash:GetColorChart()
    Local nLoop     := 0
  
    If oJson:GetJsonText("level") == "null" .Or. Len(oJson["level"]) == 0
        aCab := GetTpFilme()
        aAdd(aCab, "OUTROS") //-- Adiciona itens vazios

        For nLoop := 1 To Len(aCab)
            aAdd(aData, RetTotSB8(aCab[nLoop]))
        Next nLoop
  
        aDataFim := {}
        aAdd(aDataFim, oCoreDash:SetChart(aCab, aData, .F.,, "Saldos por Bobina"))
    ElseIf Len(oJson["level"]) == 1
        aCab := GetTipoNF()
  
        For nLoop := 1 To Len(aCab)
            aAdd(aData, Randomize(1,999) )
        Next nLoop
  
        aAdd(aDataFim, oCoreDash:SetChart(aCab,aData,/*lCurrency*/,"pie","Quantidade de Notas por Tipos"))
  
    ElseIf Len(oJson["level"]) == 2
        aCab := GetTopCli()
  
        For nLoop := 1 To Len(aCab)
            aAdd(aData, Randomize(1, 999) )
        Next nLoop
  
        oCoreDash:SetChartInfo( aData, 'Notas', 'bar', aCores[8][3] ) //Cor utilizada: OrangeLht
        aAdd(aDataFim, oCoreDash:SetChart(aCab,,/*lCurrency*/,"bar","TOP 10 Clientes por Tipo de Nota"))
  
    Endif
  
    oResponse["items"] := aDataFim
  
Return Nil

/*Retorna as filiais disponiveis no sistema para montar o combo de opcoes. O padrao do campo deve seguir o Dynamic Form do PO UI.*/
Static Function GetFil()
    Local aAreaAnt  := GetArea()
    Local aAreaSM0  := SM0->(GetArea())
    Local aSM0      := FWLoadSM0(.T., .T.)
    Local aFil      := {}
    Local nI        := 0

    For nI := 1 to Len(aSM0)
        If nI <= Len(aSM0)
            //aAdd(aFil, AllTrim(aSM0[nI][2]) + " - " + AllTrim(aSM0[nI][7]))
            aAdd(aFil, aSM0[nI][2])
        Endif
    Next

    RestArea(aAreaSM0)
    RestArea(aAreaAnt)

Return aFil

//--
Static Function GetArm()
	Local aArm      := {}
	Local cQuery    := ""
	Local cAlias    := GetNextAlias()

	cQuery := " SELECT NNR_CODIGO, NNR_DESCRI "
	cQuery += " FROM " + RetSqlName("NNR") + " NNR "
	cQuery += " WHERE NNR.NNR_FILIAL = '" + xFilial("NNR") + "' "
	cQuery += " AND NNR.D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY NNR_FILIAL, NNR_CODIGO "

	dbUseArea(.T., "TOPCONN", TCGenQry( ,, cQuery ), cAlias, .F., .T.)

	While (cAlias)->( !Eof() )
		//aAdd(aArm, AllTrim((cAlias)->NNR_CODIGO) + " - " + AllTrim((cAlias)->NNR_DESCRI))
        aAdd(aArm, AllTrim((cAlias)->NNR_CODIGO))
		(cAlias)->(DbSkip())
	EndDo

	(cAlias)->( DBCloseArea() )

Return aArm

/*Retorna tipos de filme*/
Static Function GetTpFilme()
    Local aTpFilme  := {}
    Local aSX5      := {}
    Local nI        := 0
  
    aSX5 := FWGetSX5("Z1")
    For nI := 1 To Len(aSX5)
        aAdd(aTpFilme, RTrim(aSX5[nI, 3])) //X5_CHAVE
    Next

Return aTpFilme

Static Function RetTotSB8(cFilme)
	Local cAliasQry := GetNextAlias()
    Local nRet      := 0

	BeginSQL Alias cAliasQry
        %NoPARSER%
		SELECT SUM(B8_SALDO) TOTALSB8
		FROM vw_est_saldos_bobina_2
		WHERE B1_XTPFILM = %Exp:cFilme%
	EndSQL

	If !(cAliasQry)->(EoF())
		nRet := (cAliasQry)->TOTALSB8
	EndIf
	(cAliasQry)->(dbCloseArea())

Return nRet

Static Function QryLevel(cSelect, cFilter, cGroup, aFil)
    Local cQuery := ""
    Local cWhere := ""
    Local cFil   := ""
    Local nX     := 0

    Default aFil    := {}
    Default cSelect := " tbl.* "
    Default cFilter := " "
    Default cGroup  := " "

    cQuery := " SELECT " + cSelect + " FROM vw_est_saldos_bobina_2 tbl "

    For nX := 1 to Len(aFil)
        If nX < Len(aFil)
            cFil += " '" + aFil[nX] + "', "
        else
            cFil += " '" + aFil[nX] + "'"
        Endif
    Next

    If !Empty(aFil)
        cWhere += " B8_FILIAL IN (" + cFil + ") "
    Else
        cWhere += " B8_FILIAL IN ('" + xFilial("SB8") + "') "
    EndIf

    If !Empty(cFilter)
        cWhere += " AND " + cFilter
    Endif

Return {cQuery, cWhere, cGroup}

