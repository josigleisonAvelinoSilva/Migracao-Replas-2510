#include "totvs.ch"


/*/{Protheus.doc} REFATA10
Rotina de rastreabilidade das transacoes do PV Destino e PV Origem atraves do Motor Mod.2
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 04/04/2024
/*/
User Function REFATA10()
    Local aButtons := {}

	Private cFolderA   := "FOLDER5"
	Private cFolderF   := "FOLDER6"
    Private cFilOrig   := SZ8->Z8_FILORI //GetMV("RE_FILORIG", .F., "0302")
    Private cFilDest   := SZ8->Z8_FILIAL //GetMV("RE_FILDEST", .F., "0201")
    Private cPVOrig    := SZ8->Z8_PVORIG
    Private cPVDest    := SZ8->Z8_PVDEST
    Private cItemPV    := SZ8->Z8_ITEMPV
    Private cNotaServ  := ""
    Private cSerieServ := ""
    Private cNotaST    := ""
    Private cSerieST   := ""
    Private oDlg       := Nil
    Private oPnlTree   := Nil
    Private oLayer     := Nil
    Private oLeftBox   := Nil
    Private oRigthBox  := Nil
    Private oDBTreeL   := Nil
    Private oDBTreeR   := Nil

    aAdd(aButtons, {"", "Fechar", {|| oDlg:deactivate()},,, .T., .F.})

    //-- Dialog Traceability
    oDlg := FWDialogModal():new()
    oDlg:setBackground(.T.)
    oDlg:setEscClose(.T.)
    oDlg:setSize(220, 520)
    oDlg:setTitle("Traceability")
    oDlg:setSubTitle("O objetivo dessa rotina é rastrear as transações do PV Destino [" + cFilDest + "] e PV Origem [" + cFilOrig + "].")
    oDlg:setCloseButton(.F.)
    oDlg:createDialog()
    oDlg:enableFormBar(.T.)
    oDlg:addButtons(aButtons)
    oPnlTree := oDlg:getPanelMain()

    oLayer := FWLayer():new()
    oLayer:init(oPnlTree, .F.)

    oLayer:addCollumn("LEFT_BOX", 50, .T.)
    oLeftBox := oLayer:getColPanel("LEFT_BOX")

    oLayer:addCollumn("RIGTH_BOX", 50, .T.)
    oRigthBox := oLayer:getColPanel("RIGTH_BOX")

    //-- Ordem Producao
    dbSelectArea("SC2")
    SC2->(dbSetOrder(1)) //-- C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD

    //-- Lote
    dbSelectArea("SB8")
    SB8->(dbSetOrder(2)) //-- B8_FILIAL+B8_NUMLOTE+B8_LOTECTL+B8_PRODUTO+B8_LOCAL+DTOS(B8_DTVALID)

    //-- Pedido Venda Itens 
    dbSelectArea("SC6")
    SC6->(dbSetOrder(1)) //-- C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO

    //-- Nota Fiscal Entrada Itens 
    dbSelectArea("SD1")
    SD1->(dbSetOrder(1)) //-- D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
    
    //-- Nota Fiscal Saida Itens 
    dbSelectArea("SD2")
    SD2->(dbSetOrder(3)) //-- D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM

    //-- movimentacoes internas
    dbSelectArea("SD3")
    SD3->(dbSetOrder(1)) //-- D3_FILIAL+D3_OP+D3_COD+D3_LOCAL
    
    //-- Ordem Producao Empenho
    dbSelectArea("SD4")
    SD4->(dbSetOrder(2)) //-- D4_FILIAL+D4_OP+D4_COD+D4_LOCAL

    //-- Devolucao/Retorno para Estoque
    dbSelectArea("SZ9")
    SZ9->(dbSetOrder(1)) //-- Z9_FILIAL+Z9_OP+Z9_PRODORI+Z9_LOCORI+Z9_LOTORI+Z9_SBLTORI

    //-- Solicitacao Transferencia
    dbSelectArea("NNS")
    NNS->(dbSetOrder(2)) //-- NNS_FILIAL+NNS_XOP

    //-- Solicitacao Transferencia Itens
    dbSelectArea("NNT")
    NNT->(dbSetOrder(1)) //-- NNT_FILIAL+NNT_COD+NNT_FILORI+NNT_PROD+NNT_LOCAL+NNT_LOCALI+NNT_NSERIE+NNT_LOTECT+NNT_NUMLOT+NNT_FILDES+NNT_PRODD+NNT_LOCLD+NNT_LOCDES+NNT_LOTED

    //-- Carrega dados na Tree
    FWMsgRun(, {|oSay| LoadDados(oSay)}, "Rastreando...", "Aguarde...")

    oDlg:activate()

Return


/*/{Protheus.doc} LoadDados
Rotina chama a carga os dados
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 04/04/2024
@param oSay, object, Objeto para carga de mensagem
/*/
Static Function LoadDados(oSay)
    Local cFilBkp := cFilAnt

    cFilAnt := cFilDest
    //-- PV Destino
    LoadPVDest()

    cFilAnt := cFilOrig
    //-- PV Origem
    LoadPVOrig()

    cFilAnt := cFilBkp

Return 


/*/{Protheus.doc} LoadPVDest
Rotina que carrega os dados do pedido de venda de destino na arvore
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 04/04/2024
/*/
Static Function LoadPVDest()
    Local cPrompt     := ""
    Local cCodMPOri   := ""
    Local cLoteOri    := ""
    Local cSubLoteOri := ""
    Local cCodMPDes   := ""
    Local cLoteDes    := ""
    Local cSubLoteDes := ""
    Local cCodCli     := ""
    Local cLjCli      := ""
    Local cCgc        := ""
    Local nQtdOri     := 0
    Local nQtdDes     := 0
    Local nJanAltu    := 0
    Local nJanLarg    := 0

    nJanAltu := oLeftBox:nClientHeight 
    nJanLarg := oLeftBox:nClientWidth

    //-- Criando o DbTree
    oDBTreeL := DBTree():new(3,;              //-- nTop
                             3,;              //-- nLeft
                             (nJanAltu/2)-3,; //-- nBottom
                             (nJanLarg/2)-3,; //-- nRight
                             oLeftBox,;       //-- oWnd
                             {|| .T.},;       //-- bChange
                             ,;               //-- bRClick
                             .F.)             //-- lCargo

    cPrompt := cPVDest + " | #PV DESTINO" + Space(90)
    If SC6->(dbSeek(xFilial("SC6") + cPVDest + cItemPV))
        //-- Abre Pedido de Venda
        oDBTreeL:addTree(cPrompt,;  //-- cPrompt
                         .T.,;      //-- lOpened
                         cFolderA,; //-- cRes1
                         cFolderF,; //-- cRes2
                         ,;         //-- cFile1
                         ,;         //-- cFile2
                         )          //-- cCargo

            cPrompt := AllTrim(SC6->C6_ITEM) + " | " + AllTrim(SC6->C6_PRODUTO) + " | " + AllTrim(CValToChar(SC6->C6_QTDVEN))
            If SC2->(dbSeek(xFilial("SC2") + SC6->(C6_NUM + C6_ITEM)))
                //-- Abre Pedido Venda Itens
                oDBTreeL:addTree(cPrompt,;  //-- cPrompt
                                 .T.,;      //-- lOpened
                                 cFolderA,; //-- cRes1
                                 cFolderF,; //-- cRes2
                                 ,;         //-- cFile1
                                 ,;         //-- cFile2
                                 )          //-- cCargo

                    //-- PRODUCAO SERVICO
                    cNumOP  := PadR(SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN, Len(SD4->D4_OP))
                    cPrompt := AllTrim(cNumOP) + " | " + AllTrim(CValToChar(SC2->C2_QUANT))
                    If SD4->(dbSeek(xFilial("SD4") + cNumOP))
                        //-- Abre Ordem de Producao
                        oDBTreeL:addTree(cPrompt,;  //-- cPrompt
                                         .T.,;      //-- lOpened
                                         cFolderA,; //-- cRes1
                                         cFolderF,; //-- cRes2
                                         ,;         //-- cFile1
                                         ,;         //-- cFile2
                                         )          //-- cCargo

                            cPrompt := "#EMPENHOS"
                            //-- Abre #EMPENHOS
                            oDBTreeL:addTree(cPrompt,;  //-- cPrompt
                                             .T.,;      //-- lOpened
                                             cFolderA,; //-- cRes1
                                             cFolderF,; //-- cRes2
                                             ,;         //-- cFile1
                                             ,;         //-- cFile2
                                             )          //-- cCargo

                                While SD4->(!EoF()) .And. SD4->(D4_FILIAL + D4_OP) == xFilial("SD4") + cNumOP
                                    cCodMPOri   := SD4->D4_COD
                                    cLoteOri    := SD4->D4_LOTECTL
                                    cSubLoteOri := SD4->D4_NUMLOTE
                                    nQtdOri     := SD4->D4_QTDEORI

                                    cPrompt := AllTrim(cCodMPOri) + " | " + AllTrim(CValToChar(nQtdOri))
                                    If Rastro(cCodMPOri) .And. !Empty(cLoteOri + cSubLoteOri)
                                        //-- Adiciona raiz da Ordem Producao Empenho
                                        oDBTreeL:addTree(cPrompt,;  //-- cPrompt
                                                        .T.,;      //-- lOpened
                                                        cFolderA,; //-- cRes1
                                                        cFolderF,; //-- cRes2
                                                        ,;         //-- cFile1
                                                        ,;         //-- cFile2
                                                        )          //-- cCargo

                                            //-- Posiciona na SB8
                                            SB8->(dbSeek(xFilial("SB8") + cSubLoteOri + cLoteOri + cCodMPOri))

                                            //-- Chave para a tabela de Devolucao/Retorno para Estoque
                                            cChavD4Z9 := SD4->(D4_FILIAL + D4_OP + D4_COD + D4_LOCAL + D4_LOTECTL + D4_NUMLOTE)
                                            cPrompt   := AllTrim(cLoteOri) + "+" + AllTrim(cSubLoteOri) + " | #QTD. ORIGINAL LOTE " + AllTrim(CValToChar(SB8->B8_QTDORI))
                                            If SZ9->(dbSeek(cChavD4Z9))
                                                //-- Adiciona raiz do lote origem
                                                oDBTreeL:addTree(cPrompt,;  //-- cPrompt
                                                                .T.,;      //-- lOpened
                                                                cFolderA,; //-- cRes1
                                                                cFolderF,; //-- cRes2
                                                                ,;         //-- cFile1
                                                                ,;         //-- cFile2
                                                                )          //-- cCargo

                                                    While SZ9->(!EoF()) .And. SZ9->(Z9_FILIAL + Z9_OP + Z9_PRODORI + Z9_LOCORI + Z9_LOTORI + Z9_SBLTORI) == cChavD4Z9
                                                        cCodMPDes   := SZ9->Z9_PRODDES
                                                        cLoteDes    := SZ9->Z9_LOTDES
                                                        cSubLoteDes := SZ9->Z9_SBLTDES
                                                        nQtdDes     := SZ9->Z9_QTDDES

                                                        cPrompt := AllTrim(cCodMPDes)
                                                        If Rastro(cCodMPDes) .And. !Empty(cLoteDes + cSubLoteDes)
                                                            cPrompt += " | " + AllTrim(CValToChar(nQtdDes))

                                                            //-- Adiciona raiz da Devolucao/Retorno para Estoque
                                                            oDBTreeL:addTree(cPrompt,;  //-- cPrompt
                                                                            .T.,;      //-- lOpened
                                                                            cFolderA,; //-- cRes1
                                                                            cFolderF,; //-- cRes2
                                                                            ,;         //-- cFile1
                                                                            ,;         //-- cFile2
                                                                            )          //-- cCargo

                                                                cPrompt := AllTrim(cLoteDes) + "+" + AllTrim(cSubLoteDes) + " | " + AllTrim(CValToChar(nQtdDes))

                                                                //-- Adiciona raiz do lote destino
                                                                oDBTreeL:addTreeItem(cPrompt,;  //-- cPrompt
                                                                                    cFolderA,; //-- cRes
                                                                                    ,;         //-- cFile
                                                                                    )          //-- cCargo
                                                            
                                                            //-- Finaliza da Devolucao/Retorno para Estoque
                                                            oDBTreeL:endTree()
                                                        Else
                                                            cLoteDes    := ""
                                                            cSubLoteDes := ""
                                                            nQtdDes     := 0

                                                            While SZ9->(!EoF()) .And. SZ9->(Z9_FILIAL + Z9_OP + Z9_PRODORI + Z9_LOCORI + Z9_LOTORI + Z9_SBLTORI) == cChavD4Z9
                                                                //-- Somatoria da quantidade que sera devolvida para a REPLAS
                                                                nQtdDes += SZ9->Z9_QTDDES
                                                                SZ9->(dbSkip())
                                                            EndDo

                                                            cPrompt += " | " + AllTrim(CValToChar(nQtdDes))

                                                            oDBTreeL:addTreeItem(cPrompt,;  //-- cPrompt
                                                                                cFolderA,; //-- cRes
                                                                                ,;         //-- cFile
                                                                                )          //-- cCargo
                                                        EndIf

                                                        SZ9->(dbSkip())
                                                    EndDo
                                                
                                                //-- Finaliza do lote origem
                                                oDBTreeL:endTree()
                                            Else
                                                //-- Adiciona raiz do lote origem
                                                oDBTreeL:addTreeItem(cPrompt,;  //-- cPrompt
                                                                    cFolderA,; //-- cRes
                                                                    ,;         //-- cFile
                                                                    )          //-- cCargo
                                            EndIf

                                        //-- Finaliza da Ordem Producao Empenho
                                        oDBTreeL:endTree()
                                    Else
                                        //-- Adiciona raiz da Ordem Producao Empenho
                                        oDBTreeL:addTreeItem(cPrompt,;  //-- cPrompt
                                                            cFolderA,; //-- cRes
                                                            ,;         //-- cFile
                                                            )          //-- cCargo
                                    EndIf

                                    SD4->(dbSkip())
                                EndDo

                            //-- Fecha #EMPENHOS
                            oDBTreeL:endTree()

                            cPrompt := "#CONSUMOS"
                            //-- Abre #CONSUMOS
                            oDBTreeL:addTree(cPrompt,;  //-- cPrompt
                                             .T.,;      //-- lOpened
                                             cFolderA,; //-- cRes1
                                             cFolderF,; //-- cRes2
                                             ,;         //-- cFile1
                                             ,;         //-- cFile2
                                             )          //-- cCargo

                                If SD3->(dbSeek(xFilial("SD3") + cNumOP))
                                    While SD3->(!EoF()) .And. SD3->(D3_FILIAL + D3_OP) == xFilial("SD3") + cNumOP
                                        cCodMPOri   := SD3->D3_COD
                                        cLoteOri    := SD3->D3_LOTECTL
                                        cSubLoteOri := SD3->D3_NUMLOTE
                                        nQtdOri     := SD3->D3_QUANT

                                        If SD3->D3_ESTORNO == "S" .Or. SubStr(SD3->D3_CF, 1, 1) == "P"
                                            SD3->(dbSkip())
                                            Loop
                                        EndIf

                                        cPrompt := AllTrim(cCodMPOri) + " | " + AllTrim(CValToChar(nQtdOri))
                                        If Rastro(cCodMPOri) .And. !Empty(cLoteOri + cSubLoteOri)
                                            //-- Abre Ordem Producao Empenhos
                                            oDBTreeL:addTree(cPrompt,;  //-- cPrompt
                                                             .T.,;      //-- lOpened
                                                             cFolderA,; //-- cRes1
                                                             cFolderF,; //-- cRes2
                                                             ,;         //-- cFile1
                                                             ,;         //-- cFile2
                                                             )          //-- cCargo

                                                cPrompt := AllTrim(cLoteOri) + "+" + AllTrim(cSubLoteOri)
                                                //-- Adiciona raiz do lote origem
                                                oDBTreeL:addTreeItem(cPrompt,;  //-- cPrompt
                                                                     cFolderA,; //-- cRes
                                                                     ,;         //-- cFile
                                                                     )          //-- cCargo

                                            //-- Fecha Ordem Producao Empenhos
                                            oDBTreeL:endTree()
                                        Else
                                            //-- Consumos
                                            oDBTreeL:addTreeItem(cPrompt,;  //-- cPrompt
                                                                 cFolderA,; //-- cRes
                                                                 ,;         //-- cFile
                                                                 )          //-- cCargo
                                        EndIf

                                        SD3->(dbSkip())
                                    EndDo
                                EndIf

                            //-- Fecha #CONSUMOS
                            oDBTreeL:endTree()

                        //-- Fecha da Ordem de Producao
                        oDBTreeL:endTree()
                    Else
                        //-- Ordem de Producao
                        oDBTreeL:addTreeItem(cPrompt,;  //-- cPrompt
                                             cFolderA,; //-- cRes
                                             ,;         //-- cFile
                                             )          //-- cCargo
                    EndIf

                    //-- FATURAMENTO SERVICO
                    cNotaServ  := SC6->C6_NOTA
                    cSerieServ := SC6->C6_SERIE
                    cPrompt    := AllTrim(cNotaServ) + "/" + AllTrim(cSerieServ)
                    If SD2->(dbSeek(xFilial("SD2") + cNotaServ + cSerieServ + SC6->(C6_CLI + C6_LOJA + C6_PRODUTO)))
                        //-- Adiciona raiz Nota Fiscal Saida Servico Itens
                        oDBTreeL:addTree(cPrompt,;  //-- cPrompt
                                         .T.,;      //-- lOpened
                                         cFolderA,; //-- cRes1
                                         cFolderF,; //-- cRes2
                                         ,;         //-- cFile1
                                         ,;         //-- cFile2
                                         )          //-- cCargo
                        
                            cPrompt := AllTrim(SD2->D2_ITEM) + " | " + AllTrim(SD2->D2_COD) + " | " + AllTrim(CValToChar(SD2->D2_QUANT)) + " | #TS " + AllTrim(SD2->D2_TES)

                            //-- Adiciona Nota Fiscal Saida Servico Itens
                            oDBTreeL:addTreeItem(cPrompt,;  //-- cPrompt
                                                 cFolderA,; //-- cRes
                                                 ,;         //-- cFile
                                                 )          //-- cCargo

                        //-- Finaliza raiz Nota Fiscal Saida Servico Itens
                        oDBTreeL:endTree()
                    EndIf

                    //-- Localiza Cliente na origem atraves do CNPJ
                    cCgc := A311FilCGC(cFilOrig)
                    SA1->(dbSetOrder(3))
                    SA1->(dbSeek(xFilial("SA1") + cCgc))
                    cCodCli := SA1->A1_COD
                    cLjCli  := SA1->A1_LOJA

                    //-- SOLICITACAO DE TRASFERENCIA - RETORNO MPs
                    If NNS->(dbSeek(xFilial("NNS") + cNumOP))
                        cNumST := NNS->NNS_COD

                        //-- Posiciona na NNT
                        If NNT->(dbSeek(xFilial("NNT") + cNumST))
                            cNotaST  := NNT->NNT_DOC
                            cSerieST := NNT->NNT_SERIE
                            cPrompt  := AllTrim(cNotaST) + "/" + AllTrim(cSerieST)

                            If SD2->(dbSeek(xFilial("SD2") + cNotaST + cSerieST + cCodCli + cLjCli))
                                //-- Abre Solicitacao Transferencia
                                oDBTreeL:addTree(cPrompt,;  //-- cPrompt
                                                 .T.,;      //-- lOpened
                                                 cFolderA,; //-- cRes1
                                                 cFolderF,; //-- cRes2
                                                 ,;         //-- cFile1
                                                 ,;         //-- cFile2
                                                 )          //-- cCargo

                                    cPrompt := "#ST " + AllTrim(cNumST)
                                    //-- Abre #ST
                                    oDBTreeL:addTree(cPrompt,;  //-- cPrompt
                                                     .T.,;      //-- lOpened
                                                     cFolderA,; //-- cRes1
                                                     cFolderF,; //-- cRes2
                                                     ,;         //-- cFile1
                                                     ,;         //-- cFile2
                                                     )          //-- cCargo

                                        While SD2->(!EoF()) .And. SD2->(D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA) == xFilial("SD2") + cNotaST + cSerieST + cCodCli + cLjCli
                                            cCodMPOri   := SD2->D2_COD
                                            cLoteOri    := SD2->D2_LOTECTL
                                            cSubLoteOri := SD2->D2_NUMLOTE
                                            nQtdOri     := SD2->D2_QUANT
                                            
                                            cPrompt := AllTrim(SD2->D2_ITEM) + " | " + AllTrim(cCodMPOri) + " | " + AllTrim(CValToChar(nQtdOri))
                                            If Rastro(cCodMPOri) .And. !Empty(cLoteOri + cSubLoteOri)
                                                cPrompt += " | #TS " + AllTrim(SD2->D2_TES)

                                                //-- Adiciona raiz da Solicitacao Transferencia Itens
                                                oDBTreeL:addTree(cPrompt,;  //-- cPrompt
                                                                .T.,;      //-- lOpened
                                                                cFolderA,; //-- cRes1
                                                                cFolderF,; //-- cRes2
                                                                ,;         //-- cFile1
                                                                ,;         //-- cFile2
                                                                )          //-- cCargo

                                                    cPrompt := AllTrim(cLoteOri) + "+" + AllTrim(cSubLoteOri)

                                                    //-- Adiciona raiz do lote destino
                                                    oDBTreeL:addTreeItem(cPrompt,;  //-- cPrompt
                                                                        cFolderA,; //-- cRes
                                                                        ,;         //-- cFile
                                                                        )          //-- cCargo
                                                
                                                //-- Finaliza raiz da Solicitacao Transferencia Itens
                                                oDBTreeL:endTree()
                                            Else
                                                //-- Adiciona raiz da Solicitacao Transferencia Itens
                                                oDBTreeL:addTreeItem(cPrompt,;  //-- cPrompt
                                                                    cFolderA,; //-- cRes
                                                                    ,;         //-- cFile
                                                                    )          //-- cCargo
                                            EndIf

                                            SD2->(dbSkip())
                                        EndDo

                                    //-- Fecha #ST
                                    oDBTreeL:endTree()

                                //-- Fecha Solicitacao Transferencia
                                oDBTreeL:endTree()
                            EndIf
                        EndIf
                    EndIf

                //-- Fecha raiz Pedido Venda Itens
                oDBTreeL:endTree()
            Else
                //-- Adiciona raiz Pedido Venda Itens
                oDBTreeL:addTreeItem(cPrompt,;  //-- cPrompt
                                     cFolderA,; //-- cRes
                                     ,;         //-- cFile
                                     )          //-- cCargo
            EndIf

        //-- Fecha Pedido de Venda
        oDBTreeL:endTree()
    Else
        //-- Adiciona raiz do Pedido de Venda
        oDBTreeL:addTreeItem(cPrompt,;  //-- cPrompt
                             cFolderA,; //-- cRes
                             ,;         //-- cFile
                             )          //-- cCargo
    EndIf

Return


/*/{Protheus.doc} LoadPVOrig
Rotina que carrega os dados do pedido de venda de origem na arvore
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 04/04/2024
/*/
Static Function LoadPVOrig()
    Local cPrompt     := ""
    Local cCodMPOri   := ""
    Local cLoteOri    := ""
    Local cSubLoteOri := ""
    Local cCodForn    := ""
    Local cLjForn     := ""
    Local cCgc        := ""
    Local nQtdOri     := 0
    Local nJanAltu    := 0
    Local nJanLarg    := 0

    nJanAltu := oRigthBox:nClientHeight 
    nJanLarg := oRigthBox:nClientWidth

    //-- Criando o DbTree
    oDBTreeR := DBTree():new(3,;              //-- nTop
                             3,;              //-- nLeft
                             (nJanAltu/2)-3,; //-- nBottom
                             (nJanLarg/2)-3,; //-- nRight
                             oRigthBox,;       //-- oWnd
                             {|| .T.},;       //-- bChange
                             ,;               //-- bRClick
                             .F.)             //-- lCargo

    cPrompt := cPVOrig + " | #PV ORIGEM" + Space(90)
    If SC6->(dbSeek(xFilial("SC6") + cPVOrig + cItemPV))
        //-- Adiciona raiz do Pedido de Venda
        oDBTreeR:addTree(cPrompt,;  //-- cPrompt
                         .T.,;      //-- lOpened
                         cFolderA,; //-- cRes1
                         cFolderF,; //-- cRes2
                         ,;         //-- cFile1
                         ,;         //-- cFile2
                         )          //-- cCargo

            cPrompt := AllTrim(SC6->C6_ITEM) + " | " + AllTrim(SC6->C6_PRODUTO) + " | " + AllTrim(CValToChar(SC6->C6_QTDVEN))
            If SC2->(dbSeek(xFilial("SC2") + SC6->(C6_NUM + C6_ITEM)))
                //-- Adiciona raiz Pedido Venda Itens
                oDBTreeR:addTree(cPrompt,;  //-- cPrompt
                                 .T.,;      //-- lOpened
                                 cFolderA,; //-- cRes1
                                 cFolderF,; //-- cRes2
                                 ,;         //-- cFile1
                                 ,;         //-- cFile2
                                 )          //-- cCargo

                    
                    //-- Localiza Fornecedor no destino atraves do CNPJ
                    cCgc := A311FilCGC(cFilDest)
                    SA2->(dbSeek(xFilial("SA2") + cCgc))
                    cCodForn := SA2->A2_COD
                    cLjForn  := SA2->A2_LOJA

                    //-- MPs RETORNADAS PARA EMPENHO DA OP EXTERNA
                    cPrompt := AllTrim(cNotaST) + "/" + AllTrim(cSerieST)
                    If SD1->(dbSeek(xFilial("SD1") + cNotaST + cSerieST + cCodForn + cLjForn))
                        //-- Adiciona raiz Nota Fiscal Entrada MPs Itens
                        oDBTreeR:addTree(cPrompt,;  //-- cPrompt
                                            .T.,;      //-- lOpened
                                            cFolderA,; //-- cRes1
                                            cFolderF,; //-- cRes2
                                            ,;         //-- cFile1
                                            ,;         //-- cFile2
                                            )          //-- cCargo

                            While SD1->(!EoF()) .And. SD1->(D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA) == xFilial("SD2") + cNotaST + cSerieST + cCodForn + cLjForn
                                cCodMPOri   := SD1->D1_COD
                                cLoteOri    := SD1->D1_LOTECTL
                                cSubLoteOri := SD1->D1_NUMLOTE
                                nQtdOri     := SD1->D1_QUANT
                                
                                cPrompt := AllTrim(SD1->D1_ITEM) + " | " + AllTrim(cCodMPOri) + " | " + AllTrim(CValToChar(nQtdOri))
                                If Rastro(cCodMPOri) .And. !Empty(cLoteOri + cSubLoteOri)
                                    cPrompt += " | #TE " + AllTrim(SD1->D1_TES)

                                    //-- Adiciona raiz da Solicitacao Transferencia Itens
                                    oDBTreeR:addTree(cPrompt,;  //-- cPrompt
                                                     .T.,;      //-- lOpened
                                                     cFolderA,; //-- cRes1
                                                     cFolderF,; //-- cRes2
                                                     ,;         //-- cFile1
                                                     ,;         //-- cFile2
                                                     )          //-- cCargo

                                        cPrompt := AllTrim(cLoteOri) + "+" + AllTrim(cSubLoteOri)

                                        //-- Adiciona raiz do lote destino
                                        oDBTreeR:addTreeItem(cPrompt,;  //-- cPrompt
                                                             cFolderA,; //-- cRes
                                                             ,;         //-- cFile
                                                             )          //-- cCargo
                                    
                                    //-- Finaliza raiz da Solicitacao Transferencia Itens
                                    oDBTreeR:endTree()
                                Else
                                    //-- Adiciona raiz da Solicitacao Transferencia Itens
                                    oDBTreeR:addTreeItem(cPrompt,;  //-- cPrompt
                                                            cFolderA,; //-- cRes
                                                            ,;         //-- cFile
                                                            )          //-- cCargo
                                EndIf

                                SD1->(dbSkip())
                            EndDo

                        //-- Finaliza raiz Nota Fiscal Entrada MPs Itens
                        oDBTreeR:endTree()
                    EndIf

                    //-- ENTRADA SERVICO
                    cPrompt := AllTrim(cNotaServ) + "/" + AllTrim(cSerieServ)
                    If SD1->(dbSeek(xFilial("SD1") + cNotaServ + cSerieServ + cCodForn + cLjForn))
                        //-- Adiciona raiz Nota Fiscal Entrada Servico Itens
                        oDBTreeR:addTree(cPrompt,;  //-- cPrompt
                                         .T.,;      //-- lOpened
                                         cFolderA,; //-- cRes1
                                         cFolderF,; //-- cRes2
                                         ,;         //-- cFile1
                                         ,;         //-- cFile2
                                         )          //-- cCargo
                        
                            cPrompt := AllTrim(SD1->D1_ITEM) + " | " + AllTrim(SD1->D1_COD) + " | " + AllTrim(CValToChar(SD1->D1_QUANT)) + " | #TE " + AllTrim(SD1->D1_TES)

                            //-- Adiciona Nota Fiscal Entrada Servico Itens
                            oDBTreeR:addTreeItem(cPrompt,;  //-- cPrompt
                                                 cFolderA,; //-- cRes
                                                 ,;         //-- cFile
                                                 )          //-- cCargo

                        //-- Finaliza raiz Nota Fiscal Entrada Servico Itens
                        oDBTreeR:endTree()
                    EndIf

                    //-- PRODUCAO OP EXTERNA
                    cNumOP  := PadR(SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN, Len(SD4->D4_OP))
                    cPrompt := AllTrim(cNumOP) + " | " + AllTrim(CValToChar(SC2->C2_QUANT))
                    If SD4->(dbSeek(xFilial("SD4") + cNumOP))
                        //-- Abre Ordem de Producao
                        oDBTreeR:addTree(cPrompt,;  //-- cPrompt
                                         .T.,;      //-- lOpened
                                         cFolderA,; //-- cRes1
                                         cFolderF,; //-- cRes2
                                         ,;         //-- cFile1
                                         ,;         //-- cFile2
                                         )          //-- cCargo

                            cPrompt := "#EMPENHOS"
                            //-- Abre #EMPENHOS
                            oDBTreeR:addTree(cPrompt,;  //-- cPrompt
                                             .T.,;      //-- lOpened
                                             cFolderA,; //-- cRes1
                                             cFolderF,; //-- cRes2
                                             ,;         //-- cFile1
                                             ,;         //-- cFile2
                                             )          //-- cCargo
                                While SD4->(!EoF()) .And. SD4->(D4_FILIAL + D4_OP) == xFilial("SD4") + cNumOP
                                    cCodMPOri   := SD4->D4_COD
                                    cLoteOri    := SD4->D4_LOTECTL
                                    cSubLoteOri := SD4->D4_NUMLOTE
                                    nQtdOri     := SD4->D4_QTDEORI

                                    cPrompt := AllTrim(cCodMPOri) + " | " + AllTrim(CValToChar(nQtdOri))
                                    If Rastro(cCodMPOri) .And. !Empty(cLoteOri + cSubLoteOri)
                                        //-- Abre Ordem Producao Empenhos
                                        oDBTreeR:addTree(cPrompt,;  //-- cPrompt
                                                        .T.,;      //-- lOpened
                                                        cFolderA,; //-- cRes1
                                                        cFolderF,; //-- cRes2
                                                        ,;         //-- cFile1
                                                        ,;         //-- cFile2
                                                        )          //-- cCargo

                                            //-- Posiciona na SB8
                                            SB8->(dbSeek(xFilial("SB8") + cSubLoteOri + cLoteOri + cCodMPOri))

                                            cPrompt   := AllTrim(cLoteOri) + "+" + AllTrim(cSubLoteOri) + " | #QTD. ORIGINAL LOTE " + AllTrim(CValToChar(SB8->B8_QTDORI))
                                            //-- Adiciona raiz do lote origem
                                            oDBTreeR:addTreeItem(cPrompt,;  //-- cPrompt
                                                                cFolderA,; //-- cRes
                                                                ,;         //-- cFile
                                                                )          //-- cCargo

                                        //-- Fecha Ordem Producao Empenhos
                                        oDBTreeR:endTree()
                                    Else
                                        //-- Ordem Producao Empenhos
                                        oDBTreeR:addTreeItem(cPrompt,;  //-- cPrompt
                                                             cFolderA,; //-- cRes
                                                             ,;         //-- cFile
                                                             )          //-- cCargo
                                    EndIf

                                    SD4->(dbSkip())
                                EndDo

                            //-- Fecha #EMPENHOS
                            oDBTreeR:endTree()

                            cPrompt := "#CONSUMOS"
                            //-- Abre #CONSUMOS
                            oDBTreeR:addTree(cPrompt,;  //-- cPrompt
                                             .T.,;      //-- lOpened
                                             cFolderA,; //-- cRes1
                                             cFolderF,; //-- cRes2
                                             ,;         //-- cFile1
                                             ,;         //-- cFile2
                                             )          //-- cCargo

                                If SD3->(dbSeek(xFilial("SD3") + cNumOP))
                                    While SD3->(!EoF()) .And. SD3->(D3_FILIAL + D3_OP) == xFilial("SD3") + cNumOP
                                        cCodMPOri   := SD3->D3_COD
                                        cLoteOri    := SD3->D3_LOTECTL
                                        cSubLoteOri := SD3->D3_NUMLOTE
                                        nQtdOri     := SD3->D3_QUANT

                                        If SD3->D3_ESTORNO == "S" .Or. SubStr(SD3->D3_CF, 1, 1) == "P"
                                            SD3->(dbSkip())
                                            Loop
                                        EndIf

                                        cPrompt := AllTrim(cCodMPOri) + " | " + AllTrim(CValToChar(nQtdOri))
                                        If Rastro(cCodMPOri) .And. !Empty(cLoteOri + cSubLoteOri)
                                            //-- Abre Ordem Producao Empenhos
                                            oDBTreeR:addTree(cPrompt,;  //-- cPrompt
                                                            .T.,;      //-- lOpened
                                                            cFolderA,; //-- cRes1
                                                            cFolderF,; //-- cRes2
                                                            ,;         //-- cFile1
                                                            ,;         //-- cFile2
                                                            )          //-- cCargo

                                                cPrompt := AllTrim(cLoteOri) + "+" + AllTrim(cSubLoteOri)
                                                //-- Adiciona raiz do lote origem
                                                oDBTreeR:addTreeItem(cPrompt,;  //-- cPrompt
                                                                     cFolderA,; //-- cRes
                                                                     ,;         //-- cFile
                                                                     )          //-- cCargo

                                            //-- Fecha Ordem Producao Empenhos
                                            oDBTreeR:endTree()
                                        Else
                                            //-- Consumos
                                            oDBTreeR:addTreeItem(cPrompt,;  //-- cPrompt
                                                                 cFolderA,; //-- cRes
                                                                 ,;         //-- cFile
                                                                 )          //-- cCargo
                                        EndIf

                                        SD3->(dbSkip())
                                    EndDo
                                EndIf
                                
                            //-- Fecha #CONSUMOS
                            oDBTreeR:endTree()

                        //-- Fecha Ordem de Producao
                        oDBTreeR:endTree()
                    Else
                        //-- Ordem de Producao
                        oDBTreeR:addTreeItem(cPrompt,;  //-- cPrompt
                                             cFolderA,; //-- cRes
                                             ,;         //-- cFile
                                             )          //-- cCargo
                    EndIf

                    //-- FATURAMENTO
                    cPrompt := AllTrim(SC6->C6_NOTA) + "/" + AllTrim(SC6->C6_SERIE)
                    If SD2->(dbSeek(xFilial("SD2") + SC6->(C6_NOTA + C6_SERIE + C6_CLI + C6_LOJA + C6_PRODUTO)))
                        //-- Adiciona raiz Nota Fiscal Saida Itens
                        oDBTreeR:addTree(cPrompt,;  //-- cPrompt
                                        .T.,;      //-- lOpened
                                        cFolderA,; //-- cRes1
                                        cFolderF,; //-- cRes2
                                        ,;         //-- cFile1
                                        ,;         //-- cFile2
                                        )          //-- cCargo
                        
                            cPrompt := AllTrim(SD2->D2_ITEM) + " | " + AllTrim(SD2->D2_COD) + " | " + AllTrim(CValToChar(SD2->D2_QUANT)) + " | #TS " + AllTrim(SD2->D2_TES)

                            //-- Adiciona raiz do lote destino
                            oDBTreeR:addTreeItem(cPrompt,;  //-- cPrompt
                                                 cFolderA,; //-- cRes
                                                 ,;         //-- cFile
                                                 )          //-- cCargo

                        //-- Finaliza raiz Nota Fiscal Saida Itens
                        oDBTreeR:endTree()
                    EndIf

                //-- Finaliza raiz Pedido Venda Itens
                oDBTreeR:endTree()
            Else
                //-- Adiciona raiz Pedido Venda Itens
                oDBTreeR:addTreeItem(cPrompt,;  //-- cPrompt
                                     cFolderA,; //-- cRes
                                     ,;         //-- cFile
                                     )          //-- cCargo
            EndIf

        //-- Finaliza raiz do Pedido de Venda
        oDBTreeR:endTree()
    Else
        //-- Adiciona raiz do Pedido de Venda
        oDBTreeR:addTreeItem(cPrompt,;  //-- cPrompt
                             cFolderA,; //-- cRes
                             ,;         //-- cFile
                             )          //-- cCargo
    EndIf

Return
