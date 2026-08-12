#INCLUDE "PROTHEUS.CH"


/*/{Protheus.doc} REFATA05
Rotina para alteracao da quantidade do item do pedido
apos o apontamento de producao na INDUSTRIA MM SP
Altera o pedido origem e destino
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 28/06/2022
@param cXFilial, character, Filial
@param cPedido, character, Pedido de Venda
@param cItemPV, character, Item Pedido
@param nNewQtd, numeric, Nova quantidade
@param cMsg, character, Mensagem do historico
@obs Projeto Novo PCP
/*/
User Function REFATA05(cXFilial, cPedido, cItemPV, nNewQtd, cMsg, dNewDtEnt)
    Local aArea      := GetArea()
    Local aAreaSC5	 := SC5->( GetArea() )
    Local aAreaSC6	 := SC6->( GetArea() )
    Local aAreaSX3   := {}
    Local aCpoSC5    := {}
    Local aCpoSC6    := {}
    Local aCabecPV   := {}
    Local aItensPV   := {}
    Local aItem      := {}
    Local cNaoCampo  := "C5_LOJAENT/C5_XFILORI/C5_XPVORIG/C5_MENPAD/C5_XFILDES/C5_XPVDEST/C5_XCLIORI/C5_XDESCLI"
    Local cIncCampo  := "C6_ITEM/C6_PRODUTO/C6_PRUNIT/C6_PRCVEN/C6_TES/C6_QTDVEN"
    Local nI         := 0
    Local xConteudo  := Nil
    Local cFileLog   := ""
    Local cMensLog   := ""
    Local cBkpFilAnt := FWCodFil()
    Local lRet       := .T.
    Local lUpdDate   := !Empty(dNewDtEnt)

    Private lMsErroAuto := .F.

    DbSelectArea( "SC5" )
    SC5->( DbSetOrder(1) )

    DbSelectArea( "SC6" )
    SC6->( DbSetOrder(1) )

    cFilAnt := cXFilial

    If SC6->( DbSeek( xFilial("SC6") + cPedido + cItemPV ) )
        If (QtdComp(SC6->C6_QTDVEN) # QtdComp(nNewQtd)) .Or. (lUpdDate .And. SC6->C6_ENTREG <= dNewDtEnt)
            //-- Salva area do SX3
            aAreaSX3 := SX3->( GetArea("SX3") )

            DbSelectArea("SX3")
            SX3->( DbSetOrder(1) )

            //-- Carrega campos da SC5
            SX3->( DbSeek( "SC5" ) )
            While SX3->( !Eof() ) .And. SX3->X3_ARQUIVO == "SC5"
                If X3Uso( SX3->X3_USADO ) .And.  ( SX3->X3_TIPO $ "C/N/D" ) .And.;
                ( SX3->X3_CONTEXT # "V" ) .And.  !( AllTrim( SX3->X3_CAMPO ) $ cNaoCampo )

                    //-- Retorna os campos da tabela SC5
                    aAdd( aCpoSC5, { SX3->X3_CAMPO, SX3->X3_TIPO } )
                Endif

                SX3->( DbSkip() )
            Enddo

            //-- Carrega campos da SC6
            SX3->( DbSeek( "SC6" ) )
            While SX3->( !Eof() ) .And. SX3->X3_ARQUIVO == "SC6"
                If X3Uso( SX3->X3_USADO ) .And. ( SX3->X3_TIPO $ "C/N/D" ) .And. ( SX3->X3_CONTEXT # "V" ) .And.;
                ( ( AllTrim( SX3->X3_CAMPO ) $ cIncCampo ) .Or. X3Obrigat( SX3->X3_CAMPO ) ) .And. ( SX3->X3_NIVEL <= 1 )

                    //-- Retorna os campos da tabela SC6
                    aAdd( aCpoSC6, { SX3->X3_CAMPO, SX3->X3_TIPO } )
                Endif

                SX3->( DbSkip() )
            Enddo

            //-- Restaura area do SX3
            RestArea( aAreaSX3 )

            //-- Cabecalho SC5, Campos e Conteudos
            If !Empty( aCpoSC5 ) .And. SC5->( DbSeek( xFilial("SC5") + cPedido ) )
                cCliOrig := SC5->C5_XDESCLI
                
                For nI := 1 to Len( aCpoSC5 )
                    If ( aCpoSC5[nI, 02] == "C" .And. !Empty( SC5->&(aCpoSC5[nI, 01]) ) ) .Or.;
                        ( aCpoSC5[nI, 02] == "N" .And. SC5->&( aCpoSC5[nI, 01] ) # 0 ) .Or.;
                        ( aCpoSC5[nI, 02] == "D" .And. SC5->&( aCpoSC5[nI, 01] ) # CToD("  /  /  ") )

                        If lUpdDate .And. AllTrim(aCpoSC5[nI, 01]) == "C5_FECENT"
                            xConteudo := dNewDtEnt
                        Else
                            xConteudo := SC5->&( aCpoSC5[nI, 01] )
                        EndIf
                        
                        aAdd( aCabecPV, { AllTrim( aCpoSC5[nI, 01] ), xConteudo , Nil } )
                    EndIf
                Next nI
            EndIf

            //-- Itens SC6, Campos e Conteudos
            If !Empty( aCpoSC6 ) .And. SC6->( DbSeek( xFilial("SC6") + cPedido ) )
                While SC6->( !Eof() .And. SC6->C6_FILIAL + SC6->C6_NUM == xFilial("SC6") + cPedido )
                    aItem := {}
                    If SC6->C6_NUM + SC6->C6_ITEM == cPedido + cItemPV
                        For nI := 1 To Len( aCpoSC6 )
                            If AllTrim( aCpoSC6[nI, 01] ) == "C6_QTDVEN"
                                xConteudo := nNewQtd
                            ElseIf AllTrim( aCpoSC6[nI, 01] ) == "C6_VALOR"
                                xConteudo := Round( SC6->&( aCpoSC6[nI-1, 01] ) * nNewQtd, 2 )
                            ElseIf lUpdDate .And. AllTrim( aCpoSC6[nI, 01] ) == "C6_ENTREG"
                                xConteudo := dNewDtEnt
                            Else
                                xConteudo := SC6->&( aCpoSC6[nI, 01] )
                            EndIf

                            aAdd( aItem, { AllTrim( aCpoSC6[nI, 01] ), xConteudo, Nil } )
                        Next nI
                    Else
                        For nI := 1 To Len( aCpoSC6 )
                            xConteudo := SC6->&( aCpoSC6[nI, 01] )
                            aAdd( aItem, { AllTrim( aCpoSC6[nI, 01] ), xConteudo, Nil } )
                        Next nI
                    EndIf

                    aAdd( aItensPV, aItem )

                    SC6->( DbSkip() )
                EndDo
            EndIf

            //-- Grava a alteracao no pedido de venda destino apos a producao
            If !Empty( aCabecPV ) .And. !Empty( aItensPV )
                //-- Reliza a gravacao da alteracao pedido destino apos a producao
                MsExecAuto( { |x, y, z| Mata410( x, y, z ) }, aCabecPV, aItensPV, 4 )
            
                If lMsErroAuto
                    cFileLog := NomeAutoLog()
                    cMensLog := MemoRead( cFileLog )
                    If !Empty( cMensLog )
                        ConOut( cMensLog )
                    Endif
                    cMsg += "#" + DToC(Date()) + " - " + Time() + Chr(13) + Chr(10)
                    cMsg += "Erro ao alterar pedido [" + cPedido + "]" + Chr(13) + Chr(10)
                    cMsg += cMensLog + Chr(13) + Chr(10) + Chr(13) + Chr(10)

                    lRet := .F.
                Else
                    cMsg += "#" + DToC(Date()) + " - " + Time() + Chr(13) + Chr(10)
                    cMsg += "Sucesso ao alterar pedido [" + cPedido + "]" + Chr(13) + Chr(10) + Chr(13) + Chr(10)
                EndIf
            EndIf
        EndIf
    EndIf

    If !lMsErroAuto
        If SC6->( DbSeek( xFilial("SC6") + cPedido + cItemPV ) )
            RecLock( "SC6", .F. )
                //-- Campo que indica se o produto ja foi produzido
                SC6->C6_XJAPROD := "1" //-- 1=Sim;2=Nao
            SC6->( MsUnLock() )
        EndIf
    EndIf

    cFilAnt := cBkpFilAnt
    Restarea( aAreaSC6 )
    Restarea( aAreaSC5 ) 
	RestArea( aArea )

Return lRet
