#include "totvs.ch"
#include "topconn.ch"


#define _ENTER Chr(13) + Chr(10)


/*/{Protheus.doc} REFATA06
Rotina que executa todos os faturamentos de retorno
para a REPLAS de forma automatica
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 28/06/2022
@obs Projeto Novo PCP
/*/
User Function REFATA06()
    Local aAreaAnt  := GetArea()
    Local aAreaSC2  := SC2->(GetArea())
    Local aAreaSD3  := SD3->(GetArea())
    Local aAreaSZ8  := SZ8->(GetArea())
    Local aTrfSZ9   := {}, aItensST := {}
    Local cCodMotor := SZ8->Z8_COD
    Local cNumST    := cMsg := "", cMsgProc := "", cQuery := "", cTimeIni := "", cTimeFim := ""
    Local cLocSuc   := GetMV("RE_ARMSUC", .F., "09")  //-- Define o armazem de sucata
    Local cTSaida   := GetMV("RE_TSREMI", .F., "600") //-- Tipo de Saida de remessa de Industrializacao
    Local cTEntra   := GetMV("RE_TEREMI", .F., "007") //-- Tipo de Entrada de remessa de Industrializacao
    Local nZ        := 0
    Local lContinua := .T.
    Local nDitolpv  := GetMv( "MV_DITOLPV", .F., 30 )
    Local dNewDtEnt := DaySum(dDataBase, nDitolpv) 

    Private aREFATA06 := Array(20)
    Private aDescProc := FWGetSX5("ZP")

    /*Array "aREFATA06" com os dados da execucao
    [01] -- Numero da Ordem de Producao da Industria MM SP
    [02] -- Filial da Industria MM SP
    [03] -- Numero do Pedido de Venda da Industria MM SP
    [04] -- Item do Pedido de Venda da Industria MM SP
    [05] -- Filial da Replas SP
    [06] -- Numero do Pedido de Venda da Replas SP
    [07] -- Item do Pedido de Venda da Replas SP
    [08] -- Numero do documento de saida do SERVICO na Industria MM SP
    [09] -- Serie do documento de saida do SERVICO na Industria MM SP
    [10] -- Numero do documento de entrada do SERVICO na Replas SP
    [11] -- Serie do documento de entrada do SERVICO na Replas SP
    [12] -- Numero da Solicitacao de Transferencia Replas
    [13] -- Numero da Ordem de Producao da Replas SP - OP Externa
    [14] -- Empenhos da Ordem de Producao da Replas SP - OP Externa
    */

    If Type("INCLUI") == "U"
        INCLUI := .T.
    EndIf

    DbSelectArea( "SZ8" )
    SZ8->( DbSetOrder(1) )
    SZ8->( dbSeek( xFilial("SZ8") + cCodMotor ))

    DbSelectArea( "SD3" )
    SD3->( DbGoTo( SZ8->Z8_SD3REC ) )

    aREFATA06[01] := SD3->D3_OP

    DbSelectArea( "SC2" )
    SC2->( DbSetOrder(1) )
    SC2->( DbSeek( xFilial("SC2") + aREFATA06[01] ) )

    //-- Pedido de venda destino (Industria MM SP)
    aREFATA06[02] := SZ8->Z8_FILIAL
    aREFATA06[03] := SZ8->Z8_PVDEST
    aREFATA06[04] := SZ8->Z8_ITEMPV

    //-- Pedido de venda origem (Replas SP)
    aREFATA06[05] := SZ8->Z8_FILORI
    aREFATA06[06] := SZ8->Z8_PVORIG
    aREFATA06[07] := SZ8->Z8_ITEMPV

    VarInfo("INICIO EFETIVAÇÃO OP " + AllTrim(aREFATA06[01]), Time())

    If lContinua
        //-- PROCESSO 01 - ALTERAR QTD. PV DESTINO
        If lContinua .And. !U_REFATA6A(cCodMotor, "01", "3")
            cMsg     := ""
            cMsgProc := "01 - " + aDescProc[01, 04]

            MsProcTxt(cMsgProc)
        
            cTimeIni  := Time()
            lContinua := U_REFATA05(aREFATA06[02], aREFATA06[03], aREFATA06[04], SZ8->Z8_QUANT, @cMsg, dNewDtEnt)
            cTimeFim  := Time()

            VarInfo(cMsgProc, ElapTime(cTimeIni, cTimeFim))

            //-- Atualiza o status do processo
            U_REFATA6B(cCodMotor, "01", cMsg, lContinua)
        EndIf
    EndIf 

    If lContinua
        //-- PROCESSO 02 - ALTERAR QTD. PV ORIGEM
        If lContinua .And. !U_REFATA6A(cCodMotor, "02", "3")
            cMsg     := ""
            cMsgProc := "02 - " + aDescProc[02, 04]

            MsProcTxt(cMsgProc)
            
            cTimeIni  := Time()
            lContinua := U_REFATA05(aREFATA06[05], aREFATA06[06], aREFATA06[07], SZ8->Z8_QUANT, @cMsg, Nil)
            cTimeFim  := Time()

            VarInfo(cMsgProc, ElapTime(cTimeIni, cTimeFim))

            //-- Atualiza o status do processo
            U_REFATA6B(cCodMotor, "02", cMsg, lContinua)
        EndIf
    EndIf

    If lContinua
        //-- PROCESSO 03 - LIBERAR PV DESTINO
        If lContinua .And. !U_REFATA6A(cCodMotor, "03", "3")
            cMsg     := ""
            cMsgProc := "03 - " + aDescProc[03, 04]

            MsProcTxt(cMsgProc)

            cTimeIni  := Time()
            lContinua := LibPVDest(aREFATA06[02], aREFATA06[03], aREFATA06[04], @cMsg)
            cTimeFim  := Time()

            VarInfo(cMsgProc, ElapTime(cTimeIni, cTimeFim))

            //-- Atualiza o status do processo
            U_REFATA6B(cCodMotor, "03", cMsg, lContinua)
        EndIf
    EndIf

    If lContinua
        //-- PROCESSO 04 - GERAR DOCUMENTO SAIDA PV DESTINO
        If lContinua .And. !U_REFATA6A(cCodMotor, "04", "3")
            cMsg     := ""
            cMsgProc := "04 - " + aDescProc[04, 04]

            MsProcTxt(cMsgProc)

            cTimeIni  := Time()
            lContinua := DocSaiPVDest(aREFATA06[02], aREFATA06[03], aREFATA06[04], @cMsg)
            cTimeFim  := Time()

            VarInfo(cMsgProc, ElapTime(cTimeIni, cTimeFim))

            //-- Atualiza o status do processo
            U_REFATA6B(cCodMotor, "04", cMsg, lContinua)
        EndIf
    EndIf

    DbSelectArea( "SD2" )
    SD2->( DbSetOrder(8) )

    If lContinua .And. SD2->( DbSeek( aREFATA06[02] + aREFATA06[03] + aREFATA06[04] ) )
        aREFATA06[08] := SD2->D2_DOC   
        aREFATA06[09] := SD2->D2_SERIE
        aREFATA06[10] := SD2->D2_DOC
        aREFATA06[11] := SD2->D2_SERIE
        aREFATA06[14] := {}
        aAdd(aREFATA06[14], {SD2->D2_COD, SD2->D2_LOCAL, SD2->D2_QUANT, "", "", CToD(""), "", "", "", .T.})
    Else
        lContinua := .F.       
    EndIf

    If lContinua
        //-- PROCESSO 05 - TRANSMITIR PV DESTINO
        If lContinua .And. !U_REFATA6A(cCodMotor, "05", "3")
            cMsg     := ""
            cMsgProc := "05 - " + aDescProc[05, 04]

            MsProcTxt(cMsgProc)

            //lContinua := U_REFATA07(_cNFS, _cSerieNFS, @cMsg) //-- A Partir da versao 2210 a transmissao e feita via JOB
            lContinua := .T.

            //-- Atualiza o status do processo
            U_REFATA6B(cCodMotor, "05", cMsg, lContinua)
        EndIf
    EndIf

    If lContinua
        //-- PROCESSO 06 - GERAR DOCUMENTO ENTRADA PV DESTINO
        If lContinua .And. !U_REFATA6A(cCodMotor, "06", "3")
            cMsg     := ""
            cMsgProc := "06 - " + aDescProc[06, 04]

            MsProcTxt(cMsgProc)

            cTimeIni  := Time()
            lContinua := DocEntPVDest(@cMsg)
            cTimeFim  := Time()

            VarInfo(cMsgProc, ElapTime(cTimeIni, cTimeFim))

            //-- Atualiza o status do processo
            U_REFATA6B(cCodMotor, "06", cMsg, lContinua)
        EndIf
    EndIf

    If lContinua
        //-- PROCESSO 07 - GERAR ST RETORNO MATERIA PRIMA
        If lContinua .And. !U_REFATA6A(cCodMotor, "07", "3")
            cMsg     := ""
            cMsgProc := "07 - " + aDescProc[07, 04]

            MsProcTxt(cMsgProc)

            cTimeIni  := Time()
            //-- Gerar Solicitacao de Transferencia
            lContinua := IncluiST(cCodMotor, @cNumST, @cMsg)
            cTimeFim  := Time()

            VarInfo(cMsgProc, ElapTime(cTimeIni, cTimeFim))

            //-- Atualiza o status do processo
            U_REFATA6B(cCodMotor, "07", cMsg, lContinua)
        EndIf
    EndIf

    If lContinua
        //-- PROCESSO 08 - EFETIVAR ST RETORNO MATERIA PRIMA
        If lContinua .And. !U_REFATA6A(cCodMotor, "08", "3")
            cMsg     := ""
            cMsgProc := "08 - " + aDescProc[08, 04]

            MsProcTxt(cMsgProc)

            cTimeIni  := Time()

            IF Empty(cNumST)
                //-- Busca Solic. de Transferência Correspondente caso Valor esteja em Branco
                cNumST := fBuscaST(cCodMotor)
            Endif

            //-- Efetiva Solicitacao de Transferencia Replas Automaticamente
            lContinua := EfetivaST(cNumST, @cMsg)
            cTimeFim  := Time()

            VarInfo(cMsgProc, ElapTime(cTimeIni, cTimeFim))

            //-- Atualiza o status do processo
            U_REFATA6B(cCodMotor, "08", cMsg, lContinua)
        EndIf
    EndIf

    NNS->( DbSetOrder(2) )
    If lContinua .And. NNS->( DbSeek( xFilial("NNS") + aREFATA06[01] ) )
        aREFATA06[12] := NNS->NNS_COD
        aItensST      := {}

        aItensST := GetItSD4(aREFATA06[01])
        For nZ := 1 To Len(aItensST)
            If aItensST[nZ, 10]
                aAdd(aREFATA06[14], aItensST[nZ])
            EndIf
        Next nZ
    Else
        lContinua := .F.
    EndIf

    If lContinua
        //-- PROCESSO 09 - GERAR OP EXTERNA ORIGEM
        If lContinua .And. !U_REFATA6A(cCodMotor, "09", "3")
            cMsg     := ""
            cMsgProc := "09 - " + aDescProc[09, 04]

            MsProcTxt(cMsgProc)

            cTimeIni  := Time()
            cFilAnt   := cFilOrig
            lContinua := IncOPExt(SC2->C2_XPVORIG, SC2->C2_ITEM, SC2->C2_SEQUEN, Iif(At("SV-", SC2->C2_PRODUTO) > 0, SubStr(SC2->C2_PRODUTO, 4), SC2->C2_PRODUTO), SC2->C2_LOCAL, SD3->D3_QUANT, @cMsg)
            cFilAnt   := cFilDest
            cTimeFim  := Time()

            VarInfo(cMsgProc, ElapTime(cTimeIni, cTimeFim))

            //-- Atualiza o status do processo
            U_REFATA6B(cCodMotor, "09", cMsg, lContinua)
        EndIf
    EndIf

    If lContinua
        //-- PROCESSO 10 - APONTAR OP EXTERNA ORIGEM
        If lContinua .And. !U_REFATA6A(cCodMotor, "10", "3")
            cMsg     := ""
            cMsgProc := "10 - " + aDescProc[10, 04]

            MsProcTxt(cMsgProc)

            cTimeIni  := Time()
            cFilAnt   := cFilOrig
            lContinua := AptOPExt(SC2->C2_XPVORIG+SC2->C2_ITEM+SC2->C2_SEQUEN, Iif(At("SV-", SC2->C2_PRODUTO) > 0, SubStr(SC2->C2_PRODUTO, 4), SC2->C2_PRODUTO), SC2->C2_LOCAL, SD3->D3_QUANT, @cMsg)
            cFilAnt   := cFilDest
            cTimeFim  := Time()

            VarInfo(cMsgProc, ElapTime(cTimeIni, cTimeFim))

            //-- Atualiza o status do processo
            U_REFATA6B(cCodMotor, "10", cMsg, lContinua)
        EndIf
    EndIf

    If lContinua
        //-- PROCESSO 11 - TRANSFORMAR MATERIA PRIMA ORIGEM
        If lContinua .And. !U_REFATA6A(cCodMotor, "11", "3")
            cMsg     := ""
            cMsgProc := "11 - " + aDescProc[11, 04]

            MsProcTxt(cMsgProc)

            cTimeIni  := Time()
            cFilAnt   := cFilOrig
            lContinua := U_REPCPA10(aREFATA06[01], @cMsg)
            cFilAnt   := cFilDest
            cTimeFim  := Time()

            VarInfo(cMsgProc, ElapTime(cTimeIni, cTimeFim))

            //-- Atualiza o status do processo
            U_REFATA6B(cCodMotor, "11", cMsg, lContinua)
        EndIf
    EndIf

    If lContinua
        //-- 12 - GERAR ST ENVIO MATERIA PRIMA DESTINO
        If lContinua .And. !U_REFATA6A(cCodMotor, "12", "3")
            cMsg     := ""
            cMsgProc := "12 - " + aDescProc[12, 04]

            MsProcTxt(cMsgProc)

            cTimeIni := Time()
            cFilAnt  := cFilOrig
            aItensST := {}

            cQuery := " SELECT SZ9.Z9_PRODDES, SZ9.Z9_LOCDES, SZ9.Z9_QTDDES, SZ9.Z9_LOTDES, SZ9.Z9_SBLTDES "
            cQuery += " FROM " + RetSQLName("SZ9") + " SZ9 "
            cQuery += " WHERE SZ9.Z9_FILIAL = '" + cFilDest + "' "
            cQuery += " AND SZ9.Z9_LOCDES <> '" + cLocSuc + "' "
            cQuery += " AND SZ9.Z9_OP = '" + aREFATA06[01] + "' "
            cQuery += " AND SZ9.D_E_L_E_T_ = ' ' "

            cQuery  := ChangeQuery(cQuery)
            aTrfSZ9 := QryArray(cQuery)

            For nZ := 1 To Len(aTrfSZ9)
                If !(aTrfSZ9[nZ, 02] == cLocSuc)
                    //-- Array com os itens para solicitacao de transferencia
                    aAdd(aItensST, {aTrfSZ9[nZ, 01],;
                                    aTrfSZ9[nZ, 02],;
                                    aTrfSZ9[nZ, 03],;
                                    aTrfSZ9[nZ, 04],;
                                    aTrfSZ9[nZ, 05],;
                                    CToD(""),;
                                    cFilDest,;
                                    cTSaida,;
                                    cTEntra,;
                                    .F.})
                EndIf

            Next nZ

            If !Empty(aItensST)
                //-- Gerar Solicitacao de Transferencia
                If lContinua := U_REESTA04(aItensST, @cNumST, @cMsg)
                    //-- Efetiva Solicitacao de Transferencia Replas Automaticamente
                    lContinua := EfetivaST(cNumST, @cMsg)
                EndIf
            EndIf

            cFilAnt  := cFilDest
            cTimeFim := Time()

            VarInfo(cMsgProc, ElapTime(cTimeIni, cTimeFim))

            //-- Atualiza o status do processo
            U_REFATA6B(cCodMotor, "12", cMsg, lContinua)
        EndIf
    EndIf

    //-- Tenta Liberacao do PA caso tenha Bloqueio de Estoque na Origem
    SC9->( dbSetOrder( 1 ) )
    If SC9->( dbSeek( SZ8->Z8_FILORI + SZ8->Z8_PVORIG +  SZ8->Z8_ITEMPV ) ) .AND. !Empty( SC9->C9_BLEST ) .AND. Empty( SC9->C9_BLCRED )
        //-- Rotina para gerar liberacoes manuais
        A455LibMan("SC9", SC9->(Recno()), 2, .T.) 
    Endif

    VarInfo("FIM EFETIVAÇÃO OP " + AllTrim(aREFATA06[01]), Time())

    If lContinua
        FWAlertSuccess("Sucesso ao efetivar o Motor Mod.2.", "Sucesso Efetivação!")
    Else
        FWAlertError("Erro ao efetivar o Motor Mod.2, verifique os campos de observação para mais detalhes.", "Erro Efetivação!")
    EndIf
    
    RestArea(aAreaSZ8)
    RestArea(aAreaSD3)
    RestArea(aAreaSC2)
    RestArea(aAreaAnt)

Return


/*/{Protheus.doc} LiberaPV
Rotina para Liberacao do Pedido de Venda
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 29/06/2022
@param cMsg, character, Mensagem de retorno
@return logical, Retorno logico
/*/
Static Function LibPVDest(cFilPVDest, cPedVen, cItPedVen, cMsg)
    Local aAreaAnt  := GetArea()
    Local aAreaSC5  := SC5->( GetArea() )
    Local aAreaSC6  := SC6->( GetArea() )
    Local lCredito  := .T.
    Local lEstoque  := .T.
    Local lAvCred   := .F.
    Local lAvEst    := .T.
    Local lLibPar   := .F.
    Local lTrfLocal := .F.
    Local lRet      := .T.

    Private aProdSBC       := {}
    Private lMsErroAuto    := .F.
    Private lAutoErrNoFile := .F.
    Private _cPedido       := cPedVen
    Private _cItem         := cItPedVen
    Private _cNFS          := ""
    Private _cSerieNFS     := "1"

    //-- LIBERACAO DO PV
    Pergunte( "MTALIB", .F. )
    MV_PAR01 := 2
    MV_PAR02 := _cPedido
    MV_PAR03 := _cPedido
    MV_PAR04 := "    "
    MV_PAR05 := "ZZZZ"
    MV_PAR06 := SToD( "20000101" )
    MV_PAR07 := SToD( "20490101" )
    MV_PAR08 := 2

    DbSelectArea("SC5")
    SC5->( DbSetOrder(1) )
    SC5->( DbSeek( xFilial("SC5") + _cPedido ) )
    
    DbSelectArea("SC6")
    SC6->( DbSetOrder(1) )
    SC6->( DbSeek( xFilial("SC6") + _cPedido + _cItem ) )

    //-- LIBERACAO POR ITENS
    While SC6->( !Eof() ) .And. SC6->( C6_FILIAL + C6_NUM + C6_ITEM ) == xFilial("SC6") + _cPedido + _cItem
        If !Empty( SC6->C6_NOTA ) 
            SC6->( DbSkip() )   
            Loop
        EndIf

        //-- Apaga a liberacao para que seja realizada novamente
        MaAvalSC6( "SC6", 4, "SC5" )
                                    
        //-- Liberacao	
        MaLibDoFat( SC6->( RecNo() ),; //-- 01 - Registro do SC6 
                    SC6->C6_QTDVEN  ,; //-- 02 - Quantidade a Liberar
                    @lCredito       ,; //-- 03 - Bloqueio de Credito 
                    @lEstoque       ,; //-- 04 - Bloqueio de Estoque  
                    lAvCred         ,; //-- 05 - Avaliacao de Credito
                    lAvEst          ,; //-- 06 - Avaliacao de Estoque
                    lLibPar         ,; //-- 07 - Permite Liberacao Parcial
                    lTrfLocal        ) //-- 08 - Tranfere Locais automaticamente 

        If !lCredito .Or. !lEstoque
            cMsg := "#" + DToC(Date()) + " - " + Time() + _ENTER
            cMsg += "Erro ao liberar pedido credito/estoque [" + AllTrim( SC6->C6_NUM ) + "-" + AllTrim( SC6->C6_ITEM ) + "]"  + _ENTER + _ENTER
            lRet := .F.
            Exit
        EndIf

        SC6->( DbSkip() )
    EndDo

    If lRet
        cMsg := "#" + DToC(Date()) + " - " + Time() + _ENTER
        cMsg += "Sucesso ao liberar pedido credito/estoque"  + _ENTER + _ENTER
    EndIF

    RestArea( aAreaSC6 )
    RestArea( aAreaSC5 )
    RestArea( aAreaAnt )

Return lRet


/*/{Protheus.doc} DocSaiPVDest
Rotina de Geracao do documento de saida - Faturamento
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 29/06/2022
@param cMsg, character, Mensagem de retorno
@return logical, Retorno logico
/*/
Static Function DocSaiPVDest(cFilPVDest, cPedVen, cItPedVen, cMsg)
    Local aAreaAnt     := GetArea()
    Local aAreaSE4     := SE4->( GetArea() )
    Local aAreaSB1     := SB1->( GetArea() )
    Local aAreaSB2     := SB2->( GetArea() )
    Local aAreaSF4     := SF4->( GetArea() )
    Local aAreaSC9     := SC9->( GetArea() )
    Local aPvlNFS      := {}
    Local lMostraCtb   := .F.
    Local lAglutCtb    := .F.
    Local lCtbOnLine   := .F.
    Local lCtbCusto    := .F.
    Local lReajuste    := .F.
    Local nCalAcrs     := 0
    Local nArredPrcLis := 0
    Local lAtuSA7      := .T.
    Local lECF         := .F.
    Local cEmbExp      := Nil
    Local bAtuFin      := {|| }
    Local bAtuPGerNF   := {|| }
    Local bAtuPvl      := {|| }
    Local bFatSE1      := {|| .T.}
    Local dDataMoe     := dDataBase
    Local lJunta       := .F.
    Local lRet         := .T.

    Private aProdSBC       := {}
    Private lMsErroAuto    := .F.
    Private lAutoErrNoFile := .F.
    Private _cPedido       := cPedVen
    Private _cItem         := cItPedVen
    Private _cNFS          := ""
    Private _cSerieNFS     := "1"

    DbSelectArea("SC5")
    SC5->( DbSetOrder(1) )
    SC5->( DbSeek( xFilial("SC5") + _cPedido ) )

    //-- GERACAO DO FATURAMENTO DO PV
    DbSelectArea("SE4")
    SE4->( DbSetOrder(1) )
    SE4->( DbSeek( xFilial("SE4") + SC5->C5_CONDPAG ) )

    DbSelectArea("SB1")
    SB1->( DbSetOrder(1) )

    DbSelectArea("SB2")
    SB2->( DbSetOrder(1) )

    DbSelectArea("SF4")
    SF4->( DbSetOrder(1) ) 

    DbSelectArea("SC9")
    SC9->( DbSetOrder(1) )	
    SC9->( DbSeek( xFilial("SC9") + _cPedido + _cItem ) )
                
    While SC9->( !Eof() ) .And. SC9->( C9_FILIAL + C9_PEDIDO + C9_ITEM ) == xFilial("SC9") + _cPedido + _cItem
        If ( !Empty( SC9->C9_BLCRED ) .Or. !Empty( SC9->C9_BLEST ) ) .Or. !Empty( SC9->C9_NFISCAL )
            SC9->(DbSkip())
            Loop
        EndIf
                        
        SC6->( DbSeek( xFilial("SC6") + _cPedido + SC9->C9_ITEM ) )
        SB1->( DbSeek( xFilial("SB1") + SC9->C9_PRODUTO ) )
        SB2->( DbSeek( xFilial("SB2") + SC9->C9_PRODUTO + SC6->C6_LOCAL ) )
        SF4->( DbSeek( xFilial("SF4") + SC6->C6_TES ) )
                        
        aAdd( aPvlNFs, { SC9->C9_PEDIDO    ,;
                         SC9->C9_ITEM      ,;
                         SC9->C9_SEQUEN    ,;
                         SC9->C9_QTDLIB    ,;
                         SC9->C9_PRCVEN    ,;
                         SC9->C9_PRODUTO   ,;
                         SF4->F4_ISS == "S",;
                         SC9->( Recno() )  ,;
                         SC5->( Recno() )  ,;
                         SC6->( Recno() )  ,;
                         SE4->( Recno() )  ,;
                         SB1->( Recno() )  ,;
                         SB2->( Recno() )  ,;
                         SF4->( Recno() ) } )										

        SC9->( DbSkip() )
    EndDo

    If !Empty( aPvlNFS )
        Pergunte( "MT460A", .F. )

        //-- Faturamento
        _cNFS := MaPvlNfs( aPvlNFS     ,; //-- 01 - Array com os itens a serem gerados
                           _cSerieNFS  ,; //-- 02 - Serie da Nota Fiscal
                           lMostraCtb  ,; //-- 03 - Mostra Lançamento Contabil
                           lAglutCtb   ,; //-- 04 - Aglutina Lançamento Contabil
                           lCtbOnLine  ,; //-- 05 - Contabiliza On-Line
                           lCtbCusto   ,; //-- 06 - Contabiliza Custo On-Line
                           lReajuste   ,; //-- 07 - Reajuste de preco na Nota Fiscal
                           nCalAcrs    ,; //-- 08 - Tipo de Acrescimo Financeiro
                           nArredPrcLis,; //-- 09 - Tipo de Arredondamento
                           lAtuSA7     ,; //-- 10 - Atualiza Amarracao Cliente X Produto
                           lECF        ,; //-- 11 - Cupom Fiscal
                           cEmbExp     ,; //-- 12 - Numero do Embarque de Exportacao
                           bAtuFin     ,; //-- 13 - Bloco de Codigo para complemento de atualizacao dos titulos financeiros
                           bAtuPGerNF  ,; //-- 14 - Bloco de Codigo para complemento de atualizacao dos dados apos a geracao da Nota Fiscal
                           bAtuPvl     ,; //-- 15 - Bloco de Codigo de atualizacao do Pedido de Venda antes da geracao da Nota Fiscal
                           bFatSE1     ,; //-- 16 - Bloco de Codigo para indicar se o valor do Titulo a Receber sera gravado no campo F2_VALFAT quando o parametro MV_TMSMFAT estiver com o valor igual a "2".
                           dDataMoe    ,; //-- 17 - Data da cotacao para conversao dos valores da Moeda do Pedido de Venda para a Moeda Forte
                           lJunta       ) //-- 18 - Aglutina Pedido Iguais  		            
  
        If Empty( _cNFS )
            cMsg := "#" + DToC(Date()) + " - " + Time() + _ENTER
            cMsg += "Erro ao gerar doc. saida SERVICO" + _ENTER + _ENTER
            
            lRet := .F.
        Else
            cMsg := "#" + DToC(Date()) + " - " + Time() + _ENTER
            cMsg += "Sucesso ao gerar doc. saida SERVICO [" + AllTrim( _cNFS ) + "]" + _ENTER + _ENTER
        EndIf
    EndIf

    RestArea( aAreaSC9 )
    RestArea( aAreaSF4 )
    RestArea( aAreaSB2 )
    RestArea( aAreaSB1 )
    RestArea( aAreaSE4 )
    RestArea( aAreaAnt )

Return lRet


/*/{Protheus.doc} DocEntPVDest
Rotina de Geracao do documento de entrada
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 29/06/2022
@param cMsg, character, Mensagem de retorno
@return logical, Retorno logico
/*/
Static Function DocEntPVDest(cFilPVDest, cPedVen, cItPedVen, cMsg)
    Local aCabec     := {}
    Local aLinha     := {}
    Local aItens     := {}
    Local cTERetS    := GetMV( "RE_TERETS" , .F., "014" ) //-- Tipo de Entrada para Retorno de Industrializacao do SERVICO
    Local cFileLog   := ""
    Local cMensLog   := ""
    Local lRet       := .F.

    Private aProdSBC       := {}
    Private lMsErroAuto    := .F.
    Private lAutoErrNoFile := .F.
    Private _cPedido       := cPedVen
    Private _cItem         := cItPedVen
    Private _cNFS          := aREFATA06[10]
    Private _cSerieNFS     := aREFATA06[11]

    DbSelectArea("SA1")
    SA1->( DbSetOrder(3) )
    
    DbSelectArea("SA2")
    SA2->( DbSetOrder(3) )

    DbSelectArea("SD2")
    SD2->( DbSetOrder(3) )

    //-- Localiza Cliente na origem atraves do CNPJ
    cCgc := A311FilCGC( cFilOrig )
    SA1->( DbSeek( xFilial("SA1") + cCgc ) )
    cCodCli := SA1->A1_COD
    cLjCli  := SA1->A1_LOJA

    cFilAnt := cFilOrig

    //-- Localiza Fornecedor no destino atraves do CNPJ
    cCgc := A311FilCGC( cFilDest )
    SA2->( DbSeek( xFilial("SA2") + cCgc ) )
    cCodForn := SA2->A2_COD
    cLjForn  := SA2->A2_LOJA

    cFilAnt    := cFilDest
    _cNFS      := PadR( _cNFS, TamSX3( "D2_DOC" )[1] )
    _cSerieNFS := PadR( _cSerieNFS, TamSX3( "D2_SERIE" )[1] )

    If SD2->( DbSeek( xFilial("SD2") + _cNFS + _cSerieNFS + cCodCli + cLjCli ) )
        //-- CABECALHO DA NF DE ENTRADA	
        aAdd( aCabec, { "F1_TIPO"   , "N" } )		
        aAdd( aCabec, { "F1_FORMUL" , "N" } )		
        aAdd( aCabec, { "F1_DOC"    , _cNFS } )		
        aAdd( aCabec, { "F1_SERIE"  , _cSerieNFS } )		
        aAdd( aCabec, { "F1_EMISSAO", dDataBase } )		
        aAdd( aCabec, { "F1_FORNECE", cCodForn } )	
        aAdd( aCabec, { "F1_LOJA"   , cLjForn } )		
        aAdd( aCabec, { "F1_ESPECIE", "NFE" } )		
        aAdd( aCabec, { "F1_COND"   , SA2->A2_COND } )

        While SD2->( !Eof() ) .And. xFilial("SD2") + _cNFS + _cSerieNFS + cCodCli + cLjCli == SD2->( D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA )
            aLinha := {}
            aAdd( aLinha, { "D1_ITEM" , StrZero( Val( SD2->D2_ITEM ), 4 ), Nil } )
            aAdd( aLinha, { "D1_COD"  , SD2->D2_COD, Nil } )
            aAdd( aLinha, { "D1_LOCAL", SD2->D2_LOCAL, Nil } )
            aAdd( aLinha, { "D1_UM"   , SD2->D2_UM, Nil } )
            aAdd( aLinha, { "D1_QUANT", SD2->D2_QUANT, Nil } )
            aAdd( aLinha, { "D1_VUNIT", SD2->D2_PRCVEN, Nil } )
            aAdd( aLinha, { "D1_TOTAL", SD2->D2_TOTAL, Nil } )
            aAdd( aLinha, { "D1_TES"  , cTERetS, Nil } ) 

            //-- Checa se utiliza rastreabilidade
            If Rastro( SD2->D2_COD )
                aAdd( aLinha, { "D1_LOTECTL", SD2->D2_LOTECTL, Nil } )

                If Rastro( SD2->D2_COD, "S" )
                    aAdd( aLinha, { "D1_NUMLOTE", SD2->D2_NUMLOTE, Nil } )
                EndIf
                
                aAdd( aLinha, { "D1_DTVALID", SD2->D2_DTVALID, Nil } )
                aAdd( aLinha, { "D1_DFABRIC", SD2->D2_DFABRIC, Nil } )
            EndIf

            aAdd( aLinha, { "D1_FCICOD", SD2->D2_FCICOD, Nil } )

            aAdd( aItens, aLinha )

            SD2->( DbSkip() )
        EndDo

        cFilAnt := cFilOrig

        If !Empty( aCabec ) .And. !Empty( aItens )
            //-- Reinicializa ambiente para o fiscal
            If MaFisFound()
                MaFisEnd()
            EndIf

            MsExecAuto( { |x, y, z| MATA103( x, y, z ) }, aCabec, aItens, 3 )
            
            If lMsErroAuto
                cFileLog := NomeAutoLog()
                cMensLog := MemoRead( cFileLog )
                If !Empty( cMensLog )
                    ConOut( cMensLog )
                Endif
                cMsg := "#" + DToC(Date()) + " - " + Time() + _ENTER
                cMsg += "Erro ao gerar doc. entrada SERVICO [" + _cNFS + "]" + _ENTER + _ENTER
                cMsg += cMensLog + _ENTER + _ENTER
            Else
                cMsg := "#" + DToC(Date()) + " - " + Time() + _ENTER
                cMsg += "Sucesso ao gerar doc. entrada SERVICO [" + _cNFS + "]" + _ENTER + _ENTER

                lRet := .T.
            EndIf
        EndIf
    EndIf

    cFilAnt := cFilDest

Return lRet


/*/{Protheus.doc} ZeraEmpOP
Rotina automatica para zerar os empenhos da OP
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 29/06/2022
@param cOP, character, Numero da Ordem de Producao
@param cMsg, character, Mensagem do historico
/*/
Static Function ZeraEmpOP(cOP, cMsg)
    Local aAreaAnt := GetArea()
    Local aAreaSC2 := SC2->( GetArea() )
	Local aCab     := {}
	Local aItens   := {}
    Local cFileLog := ""
    Local cMensLog := ""
    Local lRet     := .T.
    Local dBackOp  := Nil
    Local nRecSC2  := Nil

	Private lMsErroAuto := .F.

    nRecSC2 := SC2->( Recno() )
    dBackOp := SC2->C2_DATRF
    RecLock( "SC2", .F. )
        SC2->C2_DATRF := CToD("")
    SC2->( MsUnLock() )

	/*Monta o cabecalho com as informacoes da ordem de producao que terá os empenhos zerados. 
	O parametro AUTZERAEMP identifica que sera realizado o processo de zerar empenhos.*/
	aCab := { { "D4_OP"     , cOP, Nil },;
			  { "AUTZERAEMP", .T., Nil },;
			  { "INDEX"     , 2  , Nil } }

	//-- Executa o MATA381 com a operacao 4, e o indicador para zerar os empenhos.
	MSExecAuto( {|x,y,z| mata381(x,y,z)}, aCab, aItens, 4 )

	If lMsErroAuto
        cFileLog := NomeAutoLog()
        cMensLog := MemoRead( cFileLog )
        If !Empty( cMensLog )
            ConOut( cMensLog )
        Endif
        cMsg := "#" + DToC(Date()) + " - " + Time() + _ENTER
        cMsg += "Erro ao zerar empenhos [" + cOP + "]" + _ENTER + _ENTER
        cMsg += cMensLog + _ENTER + _ENTER

        lRet := .F.
    Else
        cMsg := "#" + DToC(Date()) + " - " + Time() + _ENTER
        cMsg += "Sucesso ao zerar empenhos [" + AllTrim( cOP ) + "]" + _ENTER + _ENTER
    EndIf

    If dBackOp <> Nil
        If nRecSC2 # SC2->( Recno() )
            SC2->( DbGoTo( nRecSC2 ) )
        EndIf
        RecLock( "SC2", .F. )
            SC2->C2_DATRF := dBackOp
        SC2->( MsUnLock() )
    EndIf

    RestArea( aAreaSC2 )
    RestArea( aAreaAnt )

Return lRet


/*/{Protheus.doc} IncluiST
Rotina de inclusao da solicitadao de transferencia no MOTOR MOD.2
@type function
@version 1.0
@author DO THINK - DENER LEMOS 
@since 01/06/2023
@param cXUserID, character, Codigo usuario
@param cCodMotor, character, Codigo motor
@param cNumST, character, Numero da ST
@param cMsg, character, Mensagem
@return logical, Retorno logico
/*/
Static Function IncluiST(cCodMotor, cNumST, cMsg)
    Local aItensST := {}
    Local lRet     := .T.

    If lRet
        If U_REFATA6A(cCodMotor, "07", "1")
            Begin Transaction
                aItensST := GetItSD4(aREFATA06[01])

                If lRet
                    //-- Inclui saldo inicial dos produtos na filial origem caso nao exista
                    SldIniOri(aItensST)
                EndIf

                /*Rotina automatica para zerar os empenhos da OP, apos o apontamento de producao.
                E necessario realizar o zeramento dos empenhos porque caso contrario nao existiria
                saldos disponivel em estoque para fazer as notas de retorno de industrializacao para
                a Replas SP. As materias primas do tipo Filme dos empenhos tem controle de lote e por
                isso precisam de saldo disponivel em estoque para retorno*/
                If lRet
                    lRet := ZeraEmpOP(aREFATA06[01], @cMsg)
                EndIf

                //-- Inclui Solicitacao de Transferencia Replas Automaticamente
                If lRet
                    lRet := U_REESTA04(aItensST, @cNumST, @cMsg)
                EndIf

                //-- Desarma a Transacao
                If !lRet
                    DisarmTransaction()
                EndIf
            End Transaction
        Else
            NNS->( DbSetOrder(2) )
            If NNS->(DbSeek(xFilial("NNS") + aREFATA06[01]))
                cNumST := NNS->NNS_COD
            Else
                lRet := .F.
            EndIf
        EndIf
    EndIf

Return lRet


/*/{Protheus.doc} SldIniOri
Rotina para inclusao de saldo inicial na filial origem
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 29/06/2022
@param aItensSD4, array, Itens da SD4
/*/
Static Function SldIniOri(aItensSD4)
    Local aAreaAnt := GetArea()
    Local aAreaSB2 := SB2->(GetArea())
    Local nX       := 0
    
    DbSelectArea("SB2")
    SB2->( DbSetOrder(1) )

    For nX := 1 To Len(aItensSD4)
        If !SB2->(DbSeek(cFilOrig + PadR( aItensSD4[nX, 01], TamSX3( "B2_COD" )[1] ) + aItensSD4[nX, 02]))
            CriaSB2(aItensSD4[nX, 01], aItensSD4[nX, 02], cFilOrig)	
        EndIf
    Next nX

    RestArea(aAreaSB2)
    RestArea(aAreaAnt)

Return


/*/{Protheus.doc} EfetivaST
Rotina que Efetiva Solicitacao de Transferencia Replas Automaticamente
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 29/06/2022
@param cNumST, character, Numero da Solic. de Transferencia
@param cMsg, character, Mensagem de retorno por referencia
@return logical, Retorno logico
/*/
Static Function EfetivaST(cNumST, cMsg)
    Local aLog      := {}
    Local cMensLog  := ""
    Local nX        := 0
    Local lRet      := .T.
    Local oModel    := Nil
    Local oModelNNT := Nil 

    Private cOpId311 := "011" //-- DECLARACAO PARA O REALIZAR A EFETIVACAO DA SOLICITACAO
    Private cErrComm := ""    //-- Preenche o erro de execucao dentro do Commit 

    DbSelectArea("NNS")
    NNS->( DbSetOrder(1) )
    If NNS->( DbSeek( xFilial("NNS") + cNumST ) )
        oModel := FWLoadModel( "REESTA01" ) //-- Carrega o modelo
        oModel:SetOperation( 4 ) //-- Seta operacao de alteracao para "efetivar"
        oModel:Activate() //-- Ativa o Modelo

        //-- Preenchimento dos campos da NNS
        oModel:SetValue( "NNSMASTER", "NNS_STATUS", "2" )
        oModel:SetValue( "NNSMASTER", "NNS_ESPECI", "NFE" )

        oModelNNT := oModel:GetModel( "NNTDETAIL" )
        For nX := 1 To oModelNNT:Length()
            oModelNNT:GoLine( nX )
            oModel:SetValue("NNTDETAIL", "NNT_SERIE", PadR("1", Len(NNT->NNT_SERIE))) //-- Informe a serie desejada
        Next nx

        //-- Validacao do modelo
        If oModel:VldData()
            //-- Gravacao do Modelo
            oModel:CommitData()

            //If Empty(cErrComm)
            If cNumST == NNT->NNT_COD
                If !Empty( NNT->NNT_DOC ) 
                    cMsg := "#" + DToC(Date()) + " - " + Time() + _ENTER
                    cMsg += "Sucesso ao efetivar Solicit. Transf. Replas [" + cNumST + "]" + _ENTER  + _ENTER
                Else
                    cMsg := "#" + DToC(Date()) + " - " + Time() + _ENTER
                    cMsg += "Erro ao efetivar Solicit. Transf. Replas [" + cNumST + "]" + _ENTER + _ENTER
                    cMsg += cErrComm + _ENTER + _ENTER

                    lRet := .F.
                EndIf
            Else
                cMsg := "#" + DToC(Date()) + " - " + Time() + _ENTER
                cMsg += "Sucesso ao efetivar Solicit. Transf. Replas [" + cNumST + "]" + _ENTER  + _ENTER
            Endif
        Else
            aLog     := oModel:GetErrorMessage() //-- Recupera o erro do model quando nao passou no VldData
            cMensLog := ""

            //-- Laco para gravar em string cLog conteudo do array aLog
            For nX := 1 To Len( aLog )
                If !Empty( aLog[nX] )
                    cMensLog += Alltrim( aLog[nX] ) + _ENTER
                EndIf
            Next nX

            ConOut( cMensLog )
            cMsg := "#" + DToC(Date()) + " - " + Time() + _ENTER
			cMsg += "Erro ao efetivar Solicit. Transf. Replas [" + cNumST + "]" + _ENTER + _ENTER
			cMsg += cMensLog + _ENTER + _ENTER

            lRet := .F.
        EndIf

        oModel:DeActivate() //-- Desativa modelo
    Else
        lRet := .F.
    EndIf

Return lRet


/*/{Protheus.doc} IncOPExt
Rotina de inclusao de OP Externa no MOTOR MOD.2
@type function
@version 1.0 
@author DO THINK - DENER LEMOS
@since 01/06/2023
@param cNumOP, character, Numeor OP
@param cItem, character, Item OP
@param cSequen, character, Sequencia OP
@param cCodCli, character, Codigo produto
@param cLocal, character, Armazem
@param nQuant, numeric, Quantidade
@param cMsg, character, Mensagem
@return logical, Retorno logico
/*/
Static Function IncOPExt(cNumOP, cItem, cSequen, cCodCli, cLocal, nQuant, cMsg)
    Local aAreaAnt  := GetArea()
    Local aAreaSC2  := SC2->(GetArea())
    Local aDadosSC2 := {}
    Local cFileLog  := ""
    Local cMensLog  := ""
    Local lRet      := .T.

    Private lMsErroAuto := .F.

    //-- Incluir OP Externa do produto acabado
    aAdd( aDadosSC2, { "C2_FILIAL" , xFilial("SC2"), Nil } )
    aAdd( aDadosSC2, { "C2_ITEM"   , cItem         , Nil } )    
    aAdd( aDadosSC2, { "C2_NUM"    , cNumOP        , Nil } )
    aAdd( aDadosSC2, { "C2_SEQUEN" , cSequen       , Nil } )
    aAdd( aDadosSC2, { "C2_PRODUTO", cCodCli       , Nil } )
    aAdd( aDadosSC2, { "C2_LOCAL"  , cLocal        , Nil } )
    aAdd( aDadosSC2, { "C2_QUANT"  , nQuant        , Nil } )
    aAdd( aDadosSC2, { "C2_DATPRI" , dDataBase     , Nil } )
    aAdd( aDadosSC2, { "C2_DATPRF" , dDataBase     , Nil } )
    aAdd( aDadosSC2, { "C2_OPTERCE", "1"           , Nil } ) //-- Op.Terceiros 1=Sim;2=Nao
    aAdd( aDadosSC2, { "AUTEXPLODE", "S"           , Nil } )

    MsExecAuto( {|x, y| Mata650(x, y)}, aDadosSC2, 3 )

    If lMsErroAuto
        cFileLog := NomeAutoLog()
        cMensLog := MemoRead( cFileLog )
        If !Empty( cMensLog )
            ConOut( cMensLog )
        Endif
        cMsg := "#" + DToC(Date()) + " - " + Time() + _ENTER
        cMsg += "Erro ao incluir OP Externa" + _ENTER + _ENTER
        cMsg += cMensLog + _ENTER + _ENTER

        lRet := .F.
    Else
        cMsg := "#" + DToC(Date()) + " - " + Time() + _ENTER
        cMsg += "Sucesso ao incluir OP Externa [" + cNumOP+cItem+cSequen + "]" + _ENTER + _ENTER
    EndIf

    RestArea(aAreaSC2)
    RestArea(aAreaAnt)

Return lRet


/*/{Protheus.doc} AptOPExt
Rotina de aponamento da OP Externa no MOTOR MOD.2
@type function
@version 1.0 
@author DO THINK - DENER LEMOS
@since 01/06/2023
@param cOPExt, character, Numero OP
@param cCodCli, character, Codigo produto
@param cLocal, character, Armazem
@param nQuant, numeric, Quantidade
@param cMsg, character, Mensagem
@return logical, Retorno logico
/*/
Static Function AptOPExt(cOPExt, cCodCli, cLocal, nQuant, cMsg)
    Local aAreaAnt  := GetArea()
    Local aAreaSC2  := SC2->(GetArea())
    Local aDadosSD3 := {}
    Local cFileLog  := ""
    Local cMensLog  := ""
    Local cQuery    := ""
    Local lRet      := .T.

    Private lMsErroAuto := .F.

    If Select("_QRY") > 0
        _QRY->(dbCloseArea())
    EndIf

    //-- Query para validar se os empenhos das OPs estao iguais, antes do apontamento
    cQuery := " SELECT DEST.D4_COD, DEST.NUM_DEST, ORIG.NUM_ORIG "
    cQuery += " FROM ( "
    cQuery += "         SELECT DEST.D4_COD, COUNT(DEST.D4_COD) NUM_DEST "
    cQuery += "         FROM " + RetSQLName("SD4") + " DEST "
    cQuery += "         WHERE DEST.D4_FILIAL = '" + cFilDest + "' "
    cQuery += "         AND DEST.D4_OP = '" + AllTrim(SZ8->Z8_PVDEST) + AllTrim(SZ8->Z8_ITEMPV) + "001' " 
    cQuery += "         AND DEST.D_E_L_E_T_ = ' ' "
    cQuery += "         GROUP BY D4_COD "
    cQuery += "         ) DEST
    cQuery += " LEFT JOIN ( "
    cQuery += "             SELECT ORIG.D4_COD, COUNT(ORIG.D4_COD) NUM_ORIG "
    cQuery += "             FROM " + RetSQLName("SD4") + " ORIG "
    cQuery += "             WHERE ORIG.D4_FILIAL = '" + cFilOrig + "' "
    cQuery += "             AND ORIG.D4_OP = '" + AllTrim(SZ8->Z8_PVORIG) + AllTrim(SZ8->Z8_ITEMPV) + "001' "
    cQuery += "             AND ORIG.D4_COD NOT LIKE '%SV-%' "
    cQuery += "             AND ORIG.D_E_L_E_T_ = ' ' "
    cQuery += "             GROUP BY D4_COD "
    cQuery += "             ) ORIG "
    cQuery += " ON ORIG.D4_COD = DEST.D4_COD "

    cQuery := ChangeQuery(cQuery)
    TCQUERY cQuery New Alias "_QRY"

    While _QRY->(!EoF())
        If !(_QRY->NUM_DEST == _QRY->NUM_ORIG)
            cMsg := "#" + DToC(Date()) + " - " + Time() + _ENTER
            cMsg += "Erro ao apontar OP Externa [" + cOPExt + "]" + _ENTER + _ENTER
            cMsg += "O produto [" + _QRY->D4_COD + "] " + " esta divergente nos empenhos da " + cFilDest + " e " + cFilOrig + ". Ajuste o empenho da OP externa manualmente antes de prosseguir." + _ENTER + _ENTER

            lRet := .F.
            Exit
        EndIf

        _QRY->(dbSkip())
    EndDo

    If Select("_QRY") > 0
        _QRY->(dbCloseArea())
    EndIf

    If lRet
        //-- Apontamento da OP Externa do produto acabado
        aAdd( aDadosSD3, { "D3_FILIAL" , xFilial("SD3"), Nil } )
        aAdd( aDadosSD3, { "D3_TM"     , "001"         , Nil } )
        aAdd( aDadosSD3, { "D3_OP"     , cOPExt        , Nil } )
        aAdd( aDadosSD3, { "D3_COD"    , cCodCli       , Nil } )
        aAdd( aDadosSD3, { "D3_QUANT"  , nQuant        , Nil } )
        aAdd( aDadosSD3, { "D3_LOCAL"  , cLocal        , Nil } )
        aAdd( aDadosSD3, { "D3_EMISSAO", dDatabase     , Nil } )
        //aAdd( aDadosSD3, { "ATUEMP"    , "T"           , Nil } )

        MSExecAuto( {|x, y| mata250(x, y)}, aDadosSD3, 3 ) 

        If lMsErroAuto
            cFileLog := NomeAutoLog()
            cMensLog := MemoRead( cFileLog )
            If !Empty( cMensLog )
                ConOut( cMensLog )
            Endif
            cMsg := "#" + DToC(Date()) + " - " + Time() + _ENTER
            cMsg += "Erro ao apontar OP Externa [" + cOPExt + "]" + _ENTER + _ENTER
            cMsg += cMensLog + _ENTER + _ENTER

            lRet := .F.
        Else
            cMsg := "#" + DToC(Date()) + " - " + Time() + _ENTER
            cMsg += "Sucesso ao apontar OP Externa [" + cOPExt + "]" + _ENTER + _ENTER           
        EndIf
    EndIf

    RestArea(aAreaSC2)
    RestArea(aAreaAnt)

Return lRet


/*/{Protheus.doc} REFATA6A
Rotina que verifica se um processo ja esta efetivado
@type function
@version 1.0 
@author DO THINK - DENER LEMOS
@since 01/06/2023
@param cCodMotor, character, Codigo motor
@param cCodProc, character, Codigo processo
@param cStatus, character, Status
@return logical, Retorno logico
/*/
User Function REFATA6A(cCodMotor, cCodProc, cStatus)
    Local aAreaAnt := GetArea()
    Local lRet

    DbSelectArea("SZA")
    SZA->(DbSetOrder(1))
    lRet := SZA->(DbSeek(xFilial("SZA") + cCodMotor + cCodProc)) .And. SZA->ZA_STATUS == cStatus

    RestArea(aAreaAnt)

Return lRet


/*/{Protheus.doc} REFATA6B
Rotina que atualiza o status do processo
@type function
@version 1.0 
@author DO THINK - DENER LEMOS
@since 01/06/2023
@param cCodMotor, character, Codigo motor
@param cCodProc, character, Codigo processo
@param cMsg, character, Mensagem
@param lOk, logical, Retorno logico
/*/
User Function REFATA6B(cCodMotor, cCodProc, cMsg, lOk)
    Local aAreaAnt := GetArea()
    Local cStatus  := Iif(lOk, "3", "2") //-- Status -> "1=A Efetivar;2=Efetivado com erro;3=Efetivado"

    DbSelectArea("SZ8")
    DbSelectArea("SZA")

    SZ8->(DbSetOrder(1))
    SZA->(DbSetOrder(1))

    SZ8->(DbSeek(xFilial("SZ8") + cCodMotor))
    SZA->(DbSeek(xFilial("SZA") + cCodMotor + cCodProc))

    //-- Cabecalho Motor Mod.2
    RecLock("SZ8", .F.)
        If cStatus == "2"
            SZ8->Z8_STATUS := cStatus
        ElseIf cCodProc == "12" .And. cStatus == "3"
            SZ8->Z8_DTEFET  := dDataBase
            SZ8->Z8_HREFET  := SubStr(Time(), 1, 5)
            SZ8->Z8_USREFET := __cUserId
            SZ8->Z8_STATUS  := cStatus
        EndIf
        SZ8->Z8_OBS := SZ8->Z8_OBS + cMsg
    SZ8->(MsUnlock())

    //-- Processos Motor Mod.2
    RecLock("SZA", .F.)
        SZA->ZA_OBS    := SZA->ZA_OBS + cMsg
        SZA->ZA_STATUS := cStatus
    SZA->(MsUnlock())

    RestArea(aAreaAnt)

Return


/*/{Protheus.doc} GetItSD4
Rotina que retorna os itens da SD4 com tratamento para a solicitacao de tranferencia
@type function
@version 1.0 
@author DO THINK - DENER LEMOS
@since 01/06/2023
@param cOrdProd, character, Numero da OP
@return array, Retorna array com itens
/*/
Static Function GetItSD4(cOrdProd)
    Local aAreaAnt  := GetArea()
    Local aAreaSD4  := SD4->(GetArea())
    Local aAreaSZ9  := SZ9->(GetArea()) 
    Local aRet      := {}
	Local cTSaidaSI := ""
	Local cTEntraSI := ""
    Local cChvSD4   := ""
    Local cTSaida   := GetMV( "RE_TSRETP", .F., "530" ) //-- Tipo de Saida do Retorno de Industrializacao para produtos
    Local cTEntra   := GetMV( "RE_TERETP", .F., "003" ) //-- Tipo de Entrada do Retorno de Industrializacao para produtos
    Local nQtdDes   := 0

	DbSelectArea("SD4")
	SD4->( DbSetOrder(2) )
	SD4->( DbSeek( xFilial("SD4") + cOrdProd ) )

	DbSelectArea("SZ9")
	SZ9->( DbSetOrder(1) )

	While SD4->( !Eof() ) .And. SD4->D4_OP == cOrdProd
    	cTSaidaSI := ""
	    cTEntraSI := ""
        nQtdDes   := 0

        /*If SD4->D4_QUANT == 0
           SD4->( dbSkip() )
           Loop
        Endif*/

        cChvSD4 := SD4->D4_FILIAL + SD4->D4_OP + SD4->D4_COD + SD4->D4_LOCAL + SD4->D4_LOTECTL + SD4->D4_NUMLOTE
        If SZ9->( DbSeek( cChvSD4 ))
            While SZ9->( !Eof() ) .AND. SZ9->Z9_FILIAL + SZ9->Z9_OP + SZ9->Z9_PRODORI + SZ9->Z9_LOCORI + SZ9->Z9_LOTORI + SZ9->Z9_SBLTORI ==  cChvSD4
                //-- Somatoria da quantidade que sera devolvida para a REPLAS
                nQtdDes += SZ9->Z9_QTDDES
                SZ9->( dbSkip() )
            Enddo

            If !Empty(nQtdDes)
                cTSaidaSI := GetMV( "RE_TSRETSI", .F., "531" ) //-- Tipo de Saida do Retorno de "SEM INDUTRIALIZACAO" 
                cTEntraSI := GetMV( "RE_TERETSI", .F., "206" ) //-- Tipo de Entrada do Retorno de "SEM INDUTRIALIZACAO"
                //-- Array com os itens do empenho, considerando somente o que sera retornado "SEM INDUTRIALIZACAO"
                aAdd(aRet, {SD4->D4_COD,;
                            SD4->D4_LOCAL,;
                            nQtdDes,;
                            SD4->D4_LOTECTL,;
                            SD4->D4_NUMLOTE,;
                            SD4->D4_DTVALID,;
                            cFilOrig,;
                            cTSaidaSI,; //-- TES de saida "SEM INDUTRIALIZACAO"
                            cTEntraSI,; //-- TES de entrada "SEM INDUTRIALIZACAO"
                            .F.})       //-- Indica se deve ser empenhado na OP Externa da REPLAS
            EndIf
        EndIf

        //-- Array com os itens do empenho
        aAdd(aRet, {SD4->D4_COD,;
                    SD4->D4_LOCAL,;
                    SD4->D4_QTDEORI - nQtdDes,;
                    SD4->D4_LOTECTL,;
                    SD4->D4_NUMLOTE,;
                    SD4->D4_DTVALID,;
                    cFilOrig,;
                    cTSaida,;
                    cTEntra,;
                    .T.})   //-- Indica se deve ser empenhado na OP Externa da REPLAS

		SD4->( DbSkip() )
	EndDo

    RestArea(aAreaSZ9)
    RestArea(aAreaSD4)
    RestArea(aAreaAnt)

Return aRet


//--
Static Function fBuscaST(cCodMotor)
    Local aAreaAnt := GetArea()
    Local aAreaNNS := NNS->( GetArea() )
    Local cSt      := ""

    //--NNS_FILIAL+NNS_XOP
    NNS->( dbSetOrder( 2 ))
    If xFilial( "SZ8") + cCodMotor == SZ8->Z8_FILIAL + SZ8->Z8_COD
       If NNS->( dbSeek( SZ8->Z8_FILIAL + SZ8->Z8_PVDEST + SZ8->Z8_ITEMPV )) .AND. NNS->NNS_STATUS == "1"
          cSt := NNS->NNS_COD
       Endif
    Endif

    RestArea( aAreaNNS )    
    RestArea( aAreaAnt )

Return cSt
