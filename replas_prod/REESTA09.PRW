#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} REESTA09
Função de inclusao de solicitação de transferencia em lote
@type function
@version 1.0
@author DOTHINK - Erike
@since 10/02/2023
/*/
User Function REESTA09()
    Local aPergs   := {}
    Local cProdDe  := Space(TamSX3('B1_COD')[01])
    Local cProdAt  := REPLICATE("Z", TamSX3('B1_COD')[01])
    Local cTipo    := Space(TamSX3('B1_TIPO')[01])
    Local cTSaida  := Space(TamSX3('B1_TS')[01])
    Local cTEntra  := Space(TamSX3('B1_TE')[01])
    Local cFilDes  := Space(TamSX3('B1_FILIAL')[01])    
    
    aAdd(aPergs, {1, "Produto De"    , cProdDe   ,  "", ".T.", "SB1" , ".T.", 80,  .F.})
    aAdd(aPergs, {1, "Produto Até"   , cProdAt   ,  "", ".T.", "SB1" , ".T.", 80,  .T.})
    aAdd(aPergs, {1, "Tipo"          , cTipo     ,  "", 'vazio() .or. ExistCpo("SX5", "02" + MV_PAR03)', "02"  , ".T.", 30,  .T.})
    aAdd(aPergs, {1, "Tipo Saida"    , cTSaida   ,  "", 'vazio() .or. ExistCpo("SF4") .And. MV_PAR04 > "500"', "SF4"  , ".T.", 50,  .T.})
    aAdd(aPergs, {1, "Tipo Entrada"  , cTEntra   ,  "", 'vazio() .or. ExistCpo("SF4") .And. MV_PAR05 <= "500"', "SF4"  , ".T.", 50,  .T.})
    aAdd(aPergs, {1, "Filial Destino", cFilDes   ,  "", "","SM0",".T.", 50,  .T.})    
    
    If !ParamBox(aPergs, "Informe os parâmetros - Solicitação de Tranferencia em Lote")
        FWAlertWarning("Cancelado pelo operador", "Solicitação de Transferencia em Lote")
        return
    EndIf

    If FWAlertYesNo( "Deseja incluir uma <b>Solicitação de Transferencia em Lote</b> para os produtos do tipo <b style='color:red;'>" + MV_PAR03 + "</b> ?", "Incluir Solicitação Transferência em Lote?" )
        cProdDe := MV_PAR01
        cProdAt := MV_PAR02
        cTipo   := MV_PAR03
        cTSaida := MV_PAR04
        cTEntra := MV_PAR05
        cFilDes := Alltrim(MV_PAR06)

        MsAguarde({|| GetPrdTrans( cProdDe, cProdAt, cTipo, cTSaida, cTEntra, cFilDes ) }, "Aguarde...", "Analisando Registros...")
    EndIf

Return


/*/{Protheus.doc} GetPrdTrans
Seleciona produtos que serão transferidos
@type function
@version  1.0
@author DOTHINK - Erike
@since 10/02/2023
@param cCodPrdDe, character, Produto Inicial (De)
@param cCodPrdAte, character, Produto Final (Ate)
@param cTipo, character, Tipo de Material
@param cTSaida, character, Codigo do tipo saida
@param cTEntra, character, Codigo do tipo de entrada
/*/
Static Function GetPrdTrans( cCodPrdDe, cCodPrdAte, cTipo, cTSaida, cTEntra, cFilDes )
    Local cMAlias   := GetNextAlias()
    Local cQuery    := ""
    Local aItens    := {}
    Local nAtual    := 0
    Local nTotal    := 0
    Local nTotSol   := 0
    Local nCount    := 0
    Local cFile     := GetTempPath() + "Tlog_" + FWTimeStamp(1) + ".csv"
    Local cTimeIn   := Time()
    Local cMsgFim   := ""
    Private nHndf   := 0
    Private nMErros := 0

    DbSelectArea("SB2")
    SB2->( DbSetOrder(1) )

    cQuery += " SELECT B8_FILIAL AS FILORI, Z7_FILIAL AS FILDES, SB1.B1_DESC, "
    cQuery += " B8_PRODUTO, B8_LOCAL, B8_LOTECTL, B8_NUMLOTE, B8_DTVALID, B8_EMPENHO, B8_SALDO"
    cQuery += " FROM " + RetSqlName("SB8") + " SB8   "
    cQuery += "  INNER JOIN " + RetSqlName("SB1") + "  SB1 ON B1_COD = B8_PRODUTO AND B1_TIPO = 'MP' AND B1_RASTRO IN ('L', 'S') AND SB1.D_E_L_E_T_ = ' ' "
    cQuery += "  INNER JOIN " + RetSqlName("SZ7") + "  SZ7 ON Z7_COD = B8_PRODUTO AND SZ7.D_E_L_E_T_ = ' ' AND B8_LOTECTL = Z7_LOTECTL AND B8_NUMLOTE = Z7_NUMLOTE "
    cQuery += " WHERE  "
    cQuery += "  SB8.B8_FILIAL = '" + xFilial("SB8") + "' AND "
    cQuery += "  SB8.B8_SALDO > 0 AND  "
    cQuery += "  SB8.B8_PRODUTO BETWEEN '" + cCodPrdDe + "' AND '" + cCodPrdAte + "'  AND "
    cQuery += "  SB8.D_E_L_E_T_ = ' ' AND    "  
    cQuery += "  SZ7.Z7_FILIAL = '" + cFilDes + "' "     

    cQuery := ChangeQuery(cQuery)
	DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cMAlias, .F., .T.)

    If (cMAlias)->( Eof() )
        (cMAlias)->( DbCloseArea() )
        FWAlertError( "Não existem itens para serem transferidos", "Solicitação Transferência!" )
        return
    EndIf

    FERASE(cFile)
    nHndf := FCREATE(cFile)
    If nHndf < 0
        (cMAlias)->( DbCloseArea() )
        FWAlertError("Arquivo = " + cFile + " - ferror " + Str(Ferror()), "ERRO AO CRIAR ARQUIVO DE LOG")
        return
    EndIf

    FWRITE(nHndf, "SOLICITACAO;PRODUTO;LOCAL;LOTE;SUB-LOTE;QUANTIDADE;ORIGEM;DESTINO;STATUS;DATA;HORA;ERRO;" + CRLF)

    While (cMAlias)->( !Eof() )
        nCount++
        nAtual++

        If nCount >= 10
            MsProcTxt("Analisando registro (" + cValToChar(nAtual) + ")... já processados (" + cValToChar(nTotal) + ")...")
            nCount := 0
        EndIf
        /*
        aAdd(aItens, {(cMAlias)->B8_PRODUTO  ,;  //-- 01 - Codigo do produto
                      (cMAlias)->B1_DESC     ,;  //-- 02 - Descricao do produto
                      (cMAlias)->B8_LOCAL    ,;  //-- 03 - Armazem
                      (cMAlias)->B8_LOTECTL  ,;  //-- 04 - Lote
                      (cMAlias)->B8_NUMLOTE  ,;  //-- 05 - Sub-lote
                      (cMAlias)->B8_DTVALID  ,;  //-- 06 - Data de validade
                      (cMAlias)->B8_EMPENHO  ,;  //-- 07 - Quantidade empenhada
                      (cMAlias)->B8_SALDO    ,;  //-- 08 - Saldo 
                      (cMAlias)->FILORI      ,;  //-- 09 - Filial de Origem 
                      (cMAlias)->FILDES}   )     //-- 10 - Filial de Destino
        */                      
        aAdd(aItens, {(cMAlias)->B8_PRODUTO  ,;  //-- 01 - Codigo do produto
                      (cMAlias)->B1_DESC     ,;  //-- 02 - Descricao do produto
                      (cMAlias)->B8_LOCAL    ,;  //-- 03 - Armazem
                      (cMAlias)->B8_LOTECTL  ,;  //-- 04 - Lote
                      (cMAlias)->B8_NUMLOTE  ,;  //-- 05 - Sub-lote
                      (cMAlias)->B8_DTVALID  ,;  //-- 06 - Data de validade
                      (cMAlias)->B8_EMPENHO  ,;  //-- 07 - Quantidade empenhada
                      (cMAlias)->B8_SALDO    ,;  //-- 08 - Saldo 
                      (cMAlias)->FILORI      ,;  //-- 09 - Filial de Origem 
                      cFilDes}   )               //-- 10 - Filial de Destino -- 


        If Len(aItens) >= 99
            IncTrasf(aItens, RetCodUsr(), cTSaida, cTEntra)
            nTotal  += Len(aItens)
            aItens  := {}
            nTotSol++
        EndIf 

        (cMAlias)->( DbSkip() )
    EndDo

    (cMAlias)->( DbCloseArea() )

    If !Empty(aItens)
        MsProcTxt("Analisando registro (" + cValToChar(nAtual) + ")... já processados (" + cValToChar(nTotal) + ")...")
        nTotSol++
        IncTrasf(aItens, RetCodUsr(), cTSaida, cTEntra)
    EndIf

    FClose(nHndf)

    cMsgFim := "TOTAL DE REGISTROS PROCESSADOS = " + cValToChar(nAtual)  + CRLF
    cMsgFim += "TOTAL DE SOLICITAÇÃO DE TRANSFERÊNCIAS = " + cValToChar(nTotSol)  + CRLF
    cMsgFim += "HORA DE INICIO = " + cTimeIn + "   HORA DE FIM = " + Time() + CRLF
    cMsgFim += "ERROS = " + cValToChar(nMErros)  + CRLF 
    cMsgFim += "LOG = " + cFile

    FWAlertInfo(cMsgFim, "Fim da Execução")

Return



/*/{Protheus.doc} REESTA04
Rotina para inclusao de Solicitacao de Tranferencia Replas automaticamente
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 23/06/2022
@param aItens, array, Array com os dados
@param cXUserID, character, Codigo user
@param cNumST, character, Numero da ST
@param cMsg, character, Mensagem do historico
@return logical, Retorno logico
/*/
Static Function IncTrasf(aItens, cXUserID, cTSaida, cTEntra)
	Local aLog      := {}
	Local cMensLog  := ""
    Local cNumST    := ""
	Local nX        := 0
	Local lRet      := .T.
	Local oModel    := Nil
    Private INCLUI  := .T.
    Private ALTERA  := .F.

    If Empty(cXUserID)
        cXUserID := "000000"
    EndIf

    oModel := FWLoadModel( "REESTA01" ) //-- Carrega o modelo
    oModel:SetOperation( MODEL_OPERATION_INSERT ) //-- Seta operacao de inclusao
    oModel:Activate() //-- Ativa o Modelo

    //-- Cabecalho da solicitacao
    oModel:SetValue( "NNSMASTER", "NNS_CLASS", "2" )
    oModel:SetValue( "NNSMASTER", "NNS_ESPECI", " " )
    oModel:SetValue( "NNSMASTER", "NNS_SOLICT", cXUserID )
    oModel:SetValue( "NNSMASTER", "NNS_XNOMST", UsrFullName( cXUserID ) )
    
    For nX := 1 To Len( aItens )
        //-- Verifica se no destino existe o armazém de destino, se não tiver cria
        If !SB2->(DbSeek( aItens[nX, 10] + aItens[nX, 01] + aItens[nX, 03]   ))
			CriaSB2( aItens[nX, 01], aItens[nX, 03] , aItens[nX, 10] )	
		EndIf

        If nX > 1
            oModel:GetModel( "NNTDETAIL" ):AddLine()
        EndIf

        //-- Itens da solicitacao, origem
        oModel:SetValue( "NNTDETAIL", "NNT_FILORI"  , FWCodFil() )
        oModel:SetValue( "NNTDETAIL", "NNT_PROD"    , aItens[nX, 01] )
        oModel:SetValue( "NNTDETAIL", "NNT_LOCAL"   , aItens[nX, 03] )
        oModel:SetValue( "NNTDETAIL", "NNT_QUANT"   , aItens[nX, 08] )

        //-- Checa se utiliza rastreabilidade por lote
        If Rastro( aItens[nX, 01], "L" )
            oModel:SetValue( "NNTDETAIL", "NNT_LOTECT", aItens[nX, 04] )
            oModel:SetValue( "NNTDETAIL", "NNT_DTVALI", aItens[nX, 06] )
        EndIf

        //-- Checa se utiliza rastreabilidade por sub-lote
        If Rastro( aItens[nX, 01], "S" )
            oModel:SetValue( "NNTDETAIL", "NNT_LOTECT", aItens[nX, 04] )
            oModel:SetValue( "NNTDETAIL", "NNT_NUMLOT", aItens[nX, 05] )
            oModel:SetValue( "NNTDETAIL", "NNT_DTVALI", aItens[nX, 06] )
        EndIf

        //-- Itens da solicitacao, destino
        oModel:SetValue( "NNTDETAIL", "NNT_FILDES"  , aItens[nX, 10] )
        oModel:SetValue( "NNTDETAIL", "NNT_PRODD"   , aItens[nX, 01] )
        oModel:SetValue( "NNTDETAIL", "NNT_LOCLD"   , aItens[nX, 03] )
        oModel:SetValue( "NNTDETAIL", "NNT_TS"      , AllTrim( cTSaida ) )
        oModel:SetValue( "NNTDETAIL", "NNT_TE"      , AllTrim( cTEntra ) )

        //-- GRAVA LOG
        //FWRITE(nHndf, "SOLICITACAO;PRODUTO;LOCAL;LOTE;SUB-LOTE;QUANTIDADE;ORIGEM;DESTINO;STATUS;DATA;HORA;ERRO;" + CRLF)
        cNumST := oModel:aAllSubModels[01]:aDataModel[01][02][02]
        FWRITE(nHndf,  cNumST + ";" +                                   ; //"SOLICITACAO
                       aItens[nX, 01] + ";" +                           ; //PRODUTO
                       aItens[nX, 03] + ";" +                           ; //LOCAL
                       aItens[nX, 04] + ";" +                           ; //LOTE
                       aItens[nX, 05] + ";" +                           ; //SUB-LOTE
                       cValToChar(aItens[nX, 08]) + ";" +               ; //QUANTIDADE
                       aItens[nX, 01] + ";" +                           ; //ORIGEM
                       aItens[nX, 01] + ";" +                           ; //DESTINO
                       "DIGITADO;" +                                    ; //STATUS
                       DToC(Date()) + ";" +                             ; //DATA
                       Time() + ";" +                                   ; //HORA
                       ";" +                                            ; //ERRO (nao listar erro aqui)
                       CRLF )

    Next nX

    //-- Validacao do modelo
    If oModel:VldData()
        //-- Gravacao do Modelo
        oModel:CommitData()

        cNumST := oModel:aAllSubModels[01]:aDataModel[01][02][02]
        FWRITE(nHndf, cNumST +";;;;;;;;GRAVADO;"  + DToC(Date()) + ";"+ Time() +";;" + CRLF)
    Else
        aLog     := oModel:GetErrorMessage() //-- Recupera o erro do model quando nao passou no VldData
        cMensLog := ""

        //-- Laco para gravar em string cLog conteudo do array aLog
        For nX := 1 To Len( aLog )
            If !Empty( aLog[nX] )
                cMensLog += Alltrim( aLog[nX] ) //+ Chr(13) + Chr(10)
            EndIf
        Next nX

        FWRITE(nHndf, cNumST + ";;;;;;;;ERRO;"  + DToC(Date()) + ";" + Time() + ";" + cMensLog + ";" + CRLF)

        lRet := .F.
    EndIf

    oModel:DeActivate() //-- Desativa modelo

Return lRet

