#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "RPTDEF.CH"                                      
#INCLUDE "FWPRINTSETUP.CH" 
#INCLUDE "TOTVS.CH"
#INCLUDE "PARMTYPE.CH"


/*/{Protheus.doc} REPCPR02
Relatorio de Ordens de Producao especifica Industria MM - Sao Paulo
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 28/04/2022
@param aOrdProd, array, Array de OPs
@obs Projeto Novo PCP (Relatorio de OP)
/*/
User Function REPCPR02(aOrdProd)
    Local cPathDest := GetTempPath()
    Local oPrinter  := Nil

    Private aPerg      := {}
    Private cFile      := FWTimeStamp(1)
    Private cBitmap    := GetSrvProfString( "Startpath", "" ) + "rpsoplogo.jpg"
    Private nLin 	   := 0
    Private nCol       := 0
    Private nTamMarg   := 15
    Private nSizePage  := 0
    Private nFolha     := 1
    Private lMT650OPPV := IsInCallStack( "U_MT650OPPV" )
    Private oFont01    := TFont():New( "Courier new", , -14, , .F., , , , , , )
    Private oFont02    := TFont():New( "Courier new", , -14, , .T., , , , , , )
    Private oFont03    := TFont():New( "Courier new", , -22, , .T., , , , , , )

    oPrinter := FWMSPrinter():New( cFile, IMP_PDF, .F., /*cPathDest*/, .T. )

    If !lMT650OPPV
        Pergunte( "REPCPR2P", .T. )
	EndIf

    oPrinter:nDevice  := IMP_PDF
    oPrinter:cPathPDF := cPathDest
    oPrinter:SetLandScape()
    oPrinter:SetMargin( nTamMarg, nTamMarg, nTamMarg, nTamMarg )
    oPrinter:SetPaperSize(DMPAPER_A4)

    //-- Inicia processo de impressao
    If lMT650OPPV
        IniProcImp(@oPrinter, aOrdProd)
    Else
        aPerg := GetPerg()
        MsAguarde( { || IniProcImp( @oPrinter, aOrdProd ) }, "Aguarde...", "Imprimindo Relatorio OP..." )
    EndIf

    //oPrinter:Deactivate()
    FreeObj(oPrinter)
    
Return


/*/{Protheus.doc} IniProcImp
Inicializa a impressao das OPs
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 28/04/2022
@param oPrinter, object, Objeto de impressao
@param aOrdProd, array, Array de OPs
/*/
Static Function IniProcImp(oPrinter, aOrdProd)
    Local nX := 0

    If !lMT650OPPV .And. Empty(aOrdProd)
        //--Pega ordem de producao filtradas pelo usuario
        aOrdProd := GetSC2()
    EndIf

    nSizePage := oPrinter:nPageWidth / oPrinter:nFactorHor

    For nX := 1 To Len(aOrdProd)
        If !lMT650OPPV
            MsProcTxt( "Imprimindo Relatorio OP: " + aOrdProd[nX, 01] + aOrdProd[nX, 02] + aOrdProd[nX, 03] )
        EndIf
        //-- Inicia a pagina
        oPrinter:StartPage()

        //-- Informacoes da OP, Cliente e do cabecalho do pedido
        Cabecalho(@oPrinter, aOrdProd[nX])

        //-- Informacoes dos empenhos da OP
        Empenho(@oPrinter, aOrdProd[nX])

        nFolha := 1
    Next nX

    //-- Finaliza a pagina
    oPrinter:EndPage()
    oPrinter:Preview()

Return


/*/{Protheus.doc} TituloOP
Imprime o titulo da OP
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 28/04/2022
@param oPrinter, object, Objeto de impressao
@param cOrdem, character, Numero OP
/*/
Static Function TituloOP(oPrinter, cOrdem)
    Local cFolha  := cValToChar( nFolha++ )
    Local dDtEmis := SToD( SubStr( cFile, 1, 8 ) )
    Local cHrEmis := Transform( SubStr(cFile, 9, 4), "@R 99:99" )
    Local cFilOri := "N/A"

    SC2->( DbSetOrder(1) )
    If SC2->( DbSeek( xFilial("SC2") + cOrdem ) )
        If !Empty( SC2->C2_XFILORI ) 
            cFilOri := SC2->C2_XFILORI
        EndIf
    EndIf

    oPrinter:SayBitmap( 028, 020, cBitmap, 150, 049 )

    //-- Cabecalho
    nLin := 25
    oPrinter:Line( nLin, 15, nLin, nSizePage-(nTamMarg*4) )
    nLin += 15
    nCol := (oPrinter:nHorzSize / 2) + nTamMarg
    oPrinter:Say( nLin, nCol, "ORDEM DE PRODUÇÃO: ", oFont01 )
    oPrinter:Say( nLin, nCol+125, cOrdem, oFont02 )
    oPrinter:Say( nLin, nCol+350, "Dt. Emissão: " + DToC( dDtEmis ), oFont01 )
    nLin += 15
    oPrinter:Say( nLin, nCol-25, "Filial Origem: " + cFilOri + " - " + FWFilName( cEmpAnt, cFilOri ), oFont01 )
    oPrinter:Say( nLin, nCol+350, "Hr. Emissão: " + cHrEmis, oFont01 )
    nLin += 15
    oPrinter:Say( nLin, nCol-35, "Filial Destino: " + cFilAnt + " - " + FWFilName( cEmpAnt, cFilAnt ), oFont01 )
    oPrinter:Say( nLin, nCol+350, "Folha: " + cFolha, oFont01 )
	nLin += 10		
	oPrinter:Line( nLin, 15, nLin, nSizePage-(nTamMarg*4) )
    nCol := nTamMarg

Return


/*/{Protheus.doc} Cabecalho
Imprime o cabecalho da OP, principais informacoes
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 28/04/2022
@param oPrinter, object, Objeto de impressao
@param aOP, array, Numero OP
/*/
Static Function Cabecalho(oPrinter, aOP)
    Local aArea       := GetArea()
    Local aAreaSA1    := SA1->( GetArea() )
    Local aAreaSB1    := SB1->( GetArea() )
    Local aAreaSC2    := SC2->( GetArea() )
    Local aAreaSC5    := SC5->( GetArea() )
    Local aDimen      := {}
    Local cOrdProd    := aOP[01] + aOP[02] + aOP[03]
    Local cProduto    := ""
    Local cQuant      := ""
    Local cDtPFim     := ""
    Local cObs        := ""
    Local cDiamIntCli := ""
    Local cDiamExtCli := ""
    Local cLarguraCli := ""
    Local cDescCod    := ""
    Local cUM         := ""
    Local cCliente    := "N/A"
    Local cLoja       := "N/A"
    Local cNomeCli    := "N/A"
    //Local cFilOri     := "N/A"
    Local cPVOrig     := "N/A"
    Local cSeek       := ""
    Local nTolerancia := 0
    Local nTolPad     := GetMv("RE_TOLPAD", .F., 10) //-- % Tolerancia padrao para a producao 
    Local cObsPrd     := ""

    //-- Carrega o titulo da OP
    TituloOP(@oPrinter, cOrdProd)

    If !Empty(SC2->C2_XFILORI) .AND. !Empty( SC2->C2_XPVORIG)
       cObsPrd := GetAdvFVal( "SC5","C5_XOBSPRD", SC2->C2_XFILORI + SC2->C2_XPVORIG, 1, "" )
    Endif

    cProduto := AllTrim( SC2->C2_PRODUTO )
    cQuant   := AllTrim( Transform( SC2->C2_QUANT, PesqPictQt( "C2_QUANT",TamSX3( "C2_QUANT" )[1] ) ) )
    cDtPFim  := dToC( SC2->C2_DATPRF )
    cObs     := UPPER( AllTrim( SC2->C2_OBS ) )
    If Empty(cObs)
        cObs := "TROCAR ETIQUETAS..."
    EndIf

    //-- Pega as dimensoes do PA
    aDimen := u_xGetDimen(cProduto)
    
    cDiamIntCli := aDimen[01]
    cDiamExtCli := aDimen[02]
    cLarguraCli := aDimen[03]

    SB1->( DbSetOrder(1) )
    SB1->( DbSeek( xFilial("SB1") + cProduto ) )
    cDescCod := AllTrim( SB1->B1_DESC )
    cUM      := SB1->B1_UM

    SC5->( DbSetOrder(1) )
    //-- Procura pelo pedido, verificando se existe pedido origem
    If Empty( SC2->C2_XFILORI ) .And. Empty( SC2->C2_XPVORIG )
        cSeek := xFilial("SC2") + SC2->C2_PEDIDO
    Else
        cSeek   := SC2->C2_XFILORI + SC2->C2_XPVORIG
        cPVOrig := SC2->C2_XPVORIG
    EndIf

    If SC5->( DbSeek( cSeek) )
        cCliente    := SC5->C5_CLIENTE
        cLoja       := SC5->C5_LOJACLI
        nTolerancia := SC5->C5_XTOLERA

        SA1->( DbSetOrder(1) )
        SA1->( DbSeek( xFilial("SA1") + cCliente + cLoja ) )
        cNomeCli := AllTrim( SA1->A1_NOME )
        If Empty(nTolerancia)
            nTolerancia := SA1->A1_XTOLERA
        EndIf
    EndIf

    If Empty(nTolerancia)
        nTolerancia := nTolPad
    EndIf

    nLin += 20
    oPrinter:Say( nLin, nCol, "Produto: ", oFont01 )
    oPrinter:Say( nLin, nCol+058, cProduto, oFont02 )
    oPrinter:Say( nLin, nCol+220, "Descrição: " + cDescCod, oFont01 )
    nLin += 15
    oPrinter:Say( nLin, nCol, "Ø Interno: " + cDiamIntCli + " in", oFont01 )
    oPrinter:Say( nLin, nCol+220, "Ø Externo: " + cDiamExtCli + " mm", oFont01 )
    oPrinter:Say( nLin, nCol+400, "Largura: " + cLarguraCli + " mm", oFont01 )
    nLin += 25
    oPrinter:Say( nLin, nCol, "Peso Solicitado: ", oFont01 )
    oPrinter:Say( nLin, nCol+110, cQuant, oFont02 )
    oPrinter:Say( nLin, nCol+220, "Unidade: " + cUM, oFont01 )
    oPrinter:Say( nLin, nCol+400, "Tolerância: ", oFont01 )
    oPrinter:Say( nLin, nCol+480, "± " + cValToChar( nTolerancia ) + "%", oFont02 )
    nLin += 15
    oPrinter:Say( nLin, nCol, "Dt. Entrega: ", oFont01 )
    oPrinter:Say( nLin, nCol+082, cDtPFim, oFont02 )
    nLin += 15
    oPrinter:Say( nLin, nCol, "PV Origem: ", oFont01 )
    oPrinter:Say( nLin, nCol+072, cPVOrig, oFont02 )
    nLin += 15
    oPrinter:Say( nLin, nCol, "Cliente Origem: ", oFont01 )
    oPrinter:Say( nLin, nCol+105, cNomeCli + " (" + cCliente + "-" + cLoja + ")", oFont02 )
    nLin += 25
    oPrinter:Say( nLin, nCol, "Informações Produção: ", oFont01 )
    nLin += 15
    oPrinter:Say( nLin, nCol, "Data Inicio: " + "    /    /    ", oFont01 )
    oPrinter:Say( nLin, nCol+220, "Data Fim: " + "    /    /    ", oFont01 )
    nLin += 15
    oPrinter:Say( nLin, nCol, "Hora Inicio: ", oFont01 )
    oPrinter:Say( nLin, nCol+220, "Hora Fim: ", oFont01 )
    nLin += 25
    oPrinter:Say( nLin, nCol, "Observações: ", oFont01 )
    nLin += 15
    oPrinter:Say( nLin, nCol, cObs, oFont02 )
    nLin += 15
    If !Empty(cObsPrd )
        oPrinter:Say( nLin, nCol, "Mens.Produção : ", oFont01 )    
        oPrinter:Say( nLin, nCol+105, cObsPrd, oFont02 )    
    Endif

    //-- BarCode
    oPrinter:FWMSBar( "CODE128", 007.5, 054, AllTrim(cOrdProd), oPrinter,,,,, 0.7,,,, .F.,,, ) 

    //-- Numero da OP
    oPrinter:Say( 135, nCol+580, "OP: " + cOrdProd, oFont03 ) 
    //-- Quantidade de bobinas apos producao
    oPrinter:Say( 180, nCol+580, "Qtd. Bobinas: ", oFont03 ) 
    //-- Quantidade de pallets apos producao
    oPrinter:Say( 210, nCol+580, "Qtd. Pallets: ", oFont03 ) 
    //-- Peso liquido apos producao
    oPrinter:Say( 240, nCol+580, "Peso Líquido: ", oFont03 )
    //-- Peso bruto apos producao
    oPrinter:Say( 270, nCol+580, "Peso Bruto: ", oFont03 ) 

    //-- Inicio da area dos empenhos
    nLin += 25
    oPrinter:Say( nLin, nCol, "Código", oFont01 )
    oPrinter:Say( nLin, nCol+160, "Descrição", oFont01 )
    oPrinter:Say( nLin, nCol+380, "Quantidade", oFont01 )
    oPrinter:Say( nLin, nCol+480, "UM", oFont01 )
    oPrinter:Say( nLin, nCol+510, "Arm.", oFont01 )
    oPrinter:Say( nLin, nCol+545, "Lote", oFont01 )
    oPrinter:Say( nLin, nCol+630, "Sub-Lote", oFont01 )
    oPrinter:Say( nLin, nCol+705, "Custo Unit.", oFont01 )
    nLin += 05		
    oPrinter:Line( nLin, 15, nLin, nSizePage-(nTamMarg*4) )

    RestArea(aAreaSC5)
    RestArea(aAreaSC2)
    RestArea(aAreaSB1)
    RestArea(aAreaSA1)
    RestArea(aArea)

Return


/*/{Protheus.doc} Empenho
Imprime o empenho da OP, materiais
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 28/04/2022
@param oPrinter, object, Objeto de impressao
@param aOP, array, Numero OP
/*/
Static Function Empenho(oPrinter, aOP)
    Local aEmpOP   := {}
    Local cOrdProd := aOP[01] + aOP[02] + aOP[03]
    Local nI       := 0
    Local lIsMP    := .F.
    Local lImpTab  := Iif(lMT650OPPV, .T., aPerg[06] == 1)

    //-- Retorno os empenhos da OP em execucao e retorno array
    aEmpOP := GetSD4(cOrdProd)

    For nI := 1 To Len(aEmpOP)
        If lImpTab
            lIsMP := IsMP(aEmpOP[nI, 01])
        EndIf

        If nLin+Iif(lIsMP, 185, 0) >= 585
            //-- Finaliza a pagina
            oPrinter:EndPage()

            //-- Inicia uma nova pagina
            oPrinter:StartPage()

            //-- Carrega o titulo da OP
            TituloOP(@oPrinter, cOrdProd)
            nLin += 05
        EndIf

        nLin += 15
        oPrinter:Say( nLin, nCol, aEmpOP[nI, 01], oFont01 )
        oPrinter:Say( nLin, nCol+160, aEmpOP[nI, 02], oFont01 )
        oPrinter:Say( nLin, nCol+350, aEmpOP[nI, 03], oFont01 )
        oPrinter:Say( nLin, nCol+480, aEmpOP[nI, 04], oFont01 )
        oPrinter:Say( nLin, nCol+510, aEmpOP[nI, 05], oFont01 )
        oPrinter:Say( nLin, nCol+545, aEmpOP[nI, 06], oFont01 )
        oPrinter:Say( nLin, nCol+630, aEmpOP[nI, 07], oFont01 ) 
        oPrinter:Say( nLin, nCol+680, aEmpOP[nI, 08], oFont01 ) 

        If lIsMP
            nLin  += 15
            nLinI := nLin - 10
            oPrinter:Box( nLinI, nCol+050, nLin+010, 650 )
            oPrinter:Say( nLin+003, nCol+060, "Operação", oFont02 )
            oPrinter:Say( nLin+003, nCol+165, "Produto", oFont02 )
            oPrinter:Say( nLin+003, nCol+450, "Peso (KG)", oFont02 )
            oPrinter:Say( nLin+003, nCol+550, "Localização", oFont02 )
            oPrinter:Box( nLinI+020, nCol+050, nLin+040, 650 )
            oPrinter:Box( nLinI+040, nCol+050, nLin+050, 650 )
            oPrinter:Line( nLinI, 165, nLin+050, 165 )
            oPrinter:Box( nLinI+060, nCol+050, nLin+170, 165 )
            oPrinter:Box( nLinI+060, nCol+150, nLin+070, 650 )
            oPrinter:Box( nLinI+080, nCol+150, nLin+090, 650 )
            oPrinter:Box( nLinI+100, nCol+150, nLin+110, 650 )
            oPrinter:Box( nLinI+120, nCol+150, nLin+130, 650 )
            oPrinter:Box( nLinI+140, nCol+150, nLin+150, 650 )
            oPrinter:Box( nLinI+160, nCol+150, nLin+170, 650 )
            oPrinter:Line( nLinI, 450, nLin+170, 450 )
            oPrinter:Line( nLinI, 550, nLin+170, 550 )
            oPrinter:Say( nLin+023, nCol+60, "Retorno:", oFont01 )
            oPrinter:Say( nLin+043, nCol+60, "Sucata:", oFont01 )
            oPrinter:Say( nLin+113, nCol+60, "Apontamento:", oFont01 )
            nLin += 185
        EndIf

    Next nI

Return


/*/{Protheus.doc} GetSC2
Busca as OPs filtradas pelo usuario
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 28/04/2022
@return array, Array com as OPs
/*/
Static Function GetSC2()
    Local aRet   := {}
    Local cQuery := ""
    Local cEoL   := chr(13) + chr(10)

    cQuery := " SELECT " + cEoL
    cQuery += "     SC2.*, SC2.R_E_C_N_O_ AS REC " + cEoL
    cQuery += " FROM " + cEoL
    cQuery += "     " + RetSQLName("SC2") + " SC2 " + cEoL
    cQuery += " WHERE " + cEoL
    cQuery += "     SC2.C2_FILIAL = '" + xFilial("SC2") + "' " + cEoL 
	cQuery += "     AND SC2.C2_NUM + SC2.C2_ITEM + SC2.C2_SEQUEN >= '" + aPerg[01] + "' " + cEoL 
	cQuery += "     AND SC2.C2_NUM + SC2.C2_ITEM + SC2.C2_SEQUEN <= '" + aPerg[02] + "' " + cEoL 
    cQuery += "     AND SC2.C2_DATPRF BETWEEN '" + Dtos(aPerg[03]) + "' AND '" + Dtos(aPerg[04]) + "' " + cEoL
    If aPerg[05] == 2
        cQuery += "     AND SC2.C2_DATRF = ' ' " + cEoL
    Endif	
    cQuery += "     AND SC2.D_E_L_E_T_ = ' ' " + cEoL
    cQuery += " ORDER BY " + SqlOrder( SC2->( IndexKey(1) ) ) + cEoL

    cQuery := ChangeQuery(cQuery)
	DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), "_TMP", .F., .T.)

    While _TMP->( !Eof() )
        aAdd( aRet, { _TMP->C2_NUM, _TMP->C2_ITEM, _TMP->C2_SEQUEN } )

        _TMP->( DbSkip() ) 
    EndDo

    _TMP->( DbCloseArea() )

Return aClone(aRet)


/*/{Protheus.doc} GetSD4
Busca os empenhos das OPs
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 28/04/2022
@param cOrdem, character, Numero ordem
@return array, Array com os empenhos
/*/
Static Function GetSD4(cOrdem)
    Local aArea     := GetArea()
    Local aAreaSB1  := SB1->( GetArea() )
    Local aAreaSB2  := SB2->( GetArea() )
    Local aRet      := {}
    Local cQuery    := ""
    Local cEoL      := chr(13) + chr(10)
    Local cCodMP    := ""
    Local cDescMP   := "" 
    Local cQtdMP    := ""
    Local cUniMP    := ""
    Local cArmMP    := ""
    Local cLoteCtl  := ""
    Local cNumLote  := ""
    Local cCustUnit := ""

    cQuery := " SELECT " + cEoL
    cQuery += "     SD4.* " + cEoL
    cQuery += " FROM " + cEoL
    cQuery += "     " + RetSQLName("SD4") + " SD4 " + cEoL 
    cQuery += " WHERE " + cEoL 
    cQuery += "     SD4.D4_FILIAL = '" + xFilial("SB8") + "' " + cEoL 
    cQuery += "     AND SD4.D4_OP = '" + cOrdem + "' " + cEoL
    cQuery += "     AND SD4.D_E_L_E_T_ = ' ' " + cEoL
    cQuery += " ORDER BY D4_TRT, D4_COD " + cEoL

    cQuery := ChangeQuery(cQuery)
	DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), "_TMP", .F., .T.)
    
    SB1->( DbSetOrder(1) )
    SB2->( DbSetOrder(1) )

    While _TMP->( !Eof() )
        //-- B1_FILIAL+B1_COD
        SB1->( DbSeek( xFilial("SB1") + _TMP->D4_COD ) )

        //-- B2_FILIAL+B2_COD+B2_LOCAL
        SB2->( DbSeek( xFilial("SB2") + _TMP->(D4_COD + D4_LOCAL) ) )

        cCodMP    := AllTrim( _TMP->D4_COD )
        cDescMP   := AllTrim( SB1->B1_DESC ) 
        cQtdMP    := Transform( _TMP->D4_QUANT, PesqPictQt( "D4_QUANT",TamSX3( "D4_QUANT" )[1] ) )
        cUniMP    := SB1->B1_UM
        cArmMP    := _TMP->D4_LOCAL
        cLoteCtl  := AllTrim( _TMP->D4_LOTECTL )
        cNumLote  := AllTrim( _TMP->D4_NUMLOTE )
        cCustUnit := Transform( SB2->B2_CM1, PesqPictQt( "B2_CM1",TamSX3( "B2_CM1" )[1] ) )

        aAdd( aRet, { cCodMP, cDescMP, cQtdMP, cUniMP, cArmMP, cLoteCtl, cNumLote, cCustUnit } )

        _TMP->( DbSkip() ) 

    EndDo

    _TMP->( DbCloseArea() )

    RestArea(aAreaSB2)
    RestArea(aAreaSB1)
    RestArea(aArea)

Return aClone(aRet)


/*/{Protheus.doc} IsMP
Verifica se o produto e uma MP
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 28/04/2022
@param cCodProd, character, Codido do material
@return logical, Retorno logico
/*/
Static Function IsMP(cCodProd)
Return SubStr(cCodProd, 01, 02) = "MP"


/*/{Protheus.doc} GetPerg
Funcao que carrega o conteudo das perguntas
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 28/04/2022
@return array, Array com as respostas das perguntas
/*/
Static Function GetPerg()
    Local aMvPar := {}
    Local aRet   := {}
    Local nI, nX := 0

    //-- No inicio, guarda o conteudo dos parametros MV_PAR
    For nX := 1 To 10
        aAdd( aMvPar, &( "MV_PAR" + StrZero( nX, 2, 0 ) ) )
    Next nX

    //-- Pega o conteudo das perguntas do usuario
	Pergunte("REPCPR2P", .F.)
	For nI := 1 To 6
        aAdd( aRet, &( "MV_PAR" + StrZero(nI, 2) ) )
	Next nI

    //-- No final, retorna conteudo dos parametros MV_PAR
    For nX := 1 To Len(aMvPar)
        &( "MV_PAR" + StrZero( nX, 2, 0 ) ) := aMvPar[nX]
    Next nX

Return aClone(aRet)
