#INCLUDE "PROTHEUS.CH"


/*/{Protheus.doc} REPCPA07
Funcao principal da Sugestao de Bobinas (Tela)
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 29/04/2022
@param cAlias, character, Alias em execucao (SC2)
@param cMarca, character, Marcacao da tela
@param aPergSgt, array, Conteudo das perguntas
@return logical, Retorno logico
@obs Projeto Novo PCP (Sugestao de Bobinas)
/*/
User Function REPCPA07(cAlias, cMarca, aPergSgt)
    Local aPedFilter := {}
    Local aCoors     := FWGetDialogSize()
    Local aAlter     := {}
    Local cAlter     := "C6_NUM;B8_PRODUTO;XX_QTDSGT;XX_QTDBOB;D4_LOTECTL;D4_NUMLOTE"
    Local cLinhaOk   := "U_REPCPA7L"
    Local cFieldOk   := "U_REPCPA7C"
    Local cFont      := "Tahoma"
    Local oFont01    := TFont():New( cFont,, -20 )
    Local oFont02    := TFont():New( cFont,, -20,, .T. )
    Local oFont03    := TFont():New( cFont,, -14,, .T. )
    Local oFont04    := TFont():New( cFont,, -14 )
    Local lRet       := .F.

    Private aHeadSB8   := {}
    Private aColsSB8   := {}
    Private _aSugest   := {}
    Private _aREPCPA7P := aClone(aPergSgt) //-- Conteudo das perguntas REPCPA7P
    Private cIdSgt     := FWTimeStamp(1) //-- 20190414084826
    Private oMsGet     := Nil
    Private nPosLotCtl := 0
    Private nPosLote   := 0
    Private nPosDValid := 0

    //-- Filtra os pedido de acordo com a selecao feita pelo usuario (Default)
    aPedFilter := PedFilter(cAlias, cMarca)

    If Empty(aPedFilter)
        MsgInfo("Selecione pelo menos um pedido para serem realizadas as sugestões de bobinas.", "Sem Seleção!")
        Return 
    EndIf

    //-- Montagem de listagem de bobinas sugeridas
    MsAguarde( {|| MontaLst(aPedFilter) }, "Aguarde...", "Sugerindo bobinas..." )

    //-- Carrga aHeader
    aHeadSB8 := LoadHeader()

    //-- Carrega aCols
    aColsSB8 := LoadCols()

    aAlter := StrTokArr(cAlter, ";")

    SetKey( VK_F4, {|| ShowF4() } )

    DEFINE MSDIALOG oDlg TITLE "Sugestao de Bobinas" FROM aCoors[01], aCoors[02] TO aCoors[03], aCoors[04] PIXEL
        //-- Labels
        @ 004, 003 SAY "Listagem de"       SIZE 200, 030 FONT oFont01 OF oDlg COLORS RGB(031,073,125) PIXEL
        @ 014, 003 SAY "Bobinas Sugeridas" SIZE 200, 030 FONT oFont02 OF oDlg COLORS RGB(031,073,125) PIXEL

        //-- Botoes
        @ 006, (aCoors[04]/2-001)-(052*1) BUTTON oBtn01 PROMPT "Salvar"     SIZE 050, 018 OF oDlg ACTION Iif(lRet := Salvar(), oDlg:End(), oDlg) FONT oFont03 PIXEL 
        @ 006, (aCoors[04]/2-001)-(052*2) BUTTON oBtn02 PROMPT "Cancelar"   SIZE 050, 018 OF oDlg ACTION Iif(Cancelar(), oDlg:End(), oDlg)       FONT oFont03 PIXEL
        @ 006, (aCoors[04]/2-015)-(052*3) BUTTON oBtn03 PROMPT "&Exp.Excel" SIZE 050, 018 OF oDlg ACTION ExpExcel()                              FONT oFont04 PIXEL
        @ 006, (aCoors[04]/2-015)-(052*4) BUTTON oBtn04 PROMPT "&Detalhes"  SIZE 050, 018 OF oDlg ACTION Detalhes()                              FONT oFont04 PIXEL

        //-- Grid
        oMsGet := MsNewGetDados():New( 029,;                               //-- nTop      - Linha Inicial
                                       003,;                               //-- nLeft     - Coluna Inicial
                                       (aCoors[03]/2)-3,;                  //-- nBottom   - Linha Final
                                       (aCoors[04]/2)-3,;                  //-- nRight    - Coluna Final
                                       GD_INSERT + GD_UPDATE + GD_DELETE,; //-- nStyle    - Estilos para edicao da Grid (GD_INSERT = Inclusao de Linha; GD_UPDATE = Alteracao de Linhas; GD_DELETE = Exclusao de Linhas)
                                       cLinhaOk,;                          //-- cLinhaOk  - Validacao da linha
                                       ,;                                  //-- cTudoOk   - Validacao de todas as linhas
                                       "",;                                //-- cIniCpos  - Funcao para inicializacao de campos
                                       aAlter,;                            //-- aAlter    - Colunas que podem ser alteradas
                                       ,;                                  //-- nFreeze   - Numero da coluna que será congelada
                                       999,;                               //-- nMax      - Maximo de Linhas
                                       cFieldOk,;                          //-- cFieldOk  - Validacao da coluna
                                       ,;                                  //-- cSuperDel - Validacao ao apertar '+'
                                       ,;                                  //-- cDelOk    - Validacao na exclusao da linha
                                       oDlg,;                              //-- oWnd      - Janela que e a dona da grid
                                       aHeadSB8,;                          //-- aHeader   - Cabecalho da Grid
                                       aColsSB8 )                          //-- aCols     - Dados da Grid
    ACTIVATE MSDIALOG oDlg CENTERED

    SetKey( VK_F4, {|| } )

Return lRet


/*/{Protheus.doc} PedFilter
Funcao que verifica filtra os pedidos selecionados na tela
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 29/04/2022
@param cAlias, character, Alias em execucao (SC2)
@param cMarca, character, Marcacao da tela
@return array, Array dos PVs selecionas na tela
/*/
Static Function PedFilter(cAlias, cMarca)
    Local aArea	   := GetArea()
    Local aAreaSC6 := SC6->(GetArea())
    Local aRet     := {}

    DbSelectArea(cAlias)
    SC6->( DbSetOrder(1) )
    SC6->( DbSetFilter( { || &cCondicao }, cCondicao ) )
    SC6->( DbGoTop() )
    SC6->( DbSeek( xFilial(cAlias) ) )

    While (cAlias)->( !Eof() ) .And. (cAlias)->(C6_FILIAL) == xFilial("SC6")
        If oMarkBrw:IsMark(cMarca)
            aAdd( aRet, { SC6->C6_NUM, SC6->C6_ITEM, SC6->C6_PRODUTO, SC6->C6_QTDVEN, SC6->(Recno()) } )
        EndIf 

        (cAlias)->( DbSkip() )
    EndDo

    SC6->( DbClearFilter() )

    (cAlias)->( DbCloseArea() )

    RestArea( aAreaSC6 )
    RestArea( aArea )

    //-- Ordenacao dos produtos acabados para analise
    If _aREPCPA7P[3] == 1
        //-- Crescente
        aSort( aRet, , , { |x, y| x[3] < y[3] } )
    ElseIf _aREPCPA7P[3] == 2
        //-- Decrescente
        aSort( aRet, , , { |x, y| x[3] > y[3] } )
    EndIf

Return aClone(aRet)


/*/{Protheus.doc} MontaLst
Funcao que monta a lista de Pedidos de Venda X Bobinas sugeridas
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 29/04/2022
@param aPedidos, array, Pedidos para sugestao
/*/
Static Function MontaLst(aPedidos)
    Local aArea	   := GetArea()
    Local aAreaSC6 := SC6->(GetArea())
    Local aAreaSG1 := SG1->(GetArea())
    Local cPedido  := ""
    Local cItem    := ""
    Local cLocal   := ""
    Local cProduto := ""
    Local nQtdVen  := 0
    Local nI       := 0
    
    DbSelectArea("SC6")
    DbSelectArea("SG1")
    SG1->( DbSetOrder(1) ) //-- G1_FILIAL+G1_COD+G1_COMP+G1_TRT

    For nI := 1 To Len(aPedidos)
        SC6->( DbGoTo(aPedidos[nI, 05]) )

        MsProcTxt("Sugerindo bobinas Pedido: " + SC6->C6_NUM + "-" + SC6->C6_ITEM )
       
        cPedido  := SC6->C6_NUM
        cItem    := SC6->C6_ITEM
        cProduto := SC6->C6_PRODUTO
        nQtdVen  := SC6->C6_QTDVEN
        cLocal   := SC6->C6_LOCAL

        //-- Verifica se sugere bobinas para produtos sem estrutura
        If !SG1->( DbSeek( xFilial("SG1") + cProduto ) ) .And. aSav651[02] # 1
            Loop
        EndIf

        //-- Funcao que carrega os lotes aptos a serem usados (Analise dos Lotes)
        U_REPCPA06(cPedido, cItem, cProduto, nQtdVen, cLocal, _aSugest, cIdSgt, _aREPCPA7P)

    Next nI

    //-- Atualiza o parametro com o Id da ultima sugestao
    If !Empty(_aSugest)
        PutMV("RE_IDSGT", cIdSgt)
    EndIf

    RestArea( aAreaSG1 )
    RestArea( aAreaSC6 )
    RestArea( aArea )

Return 


/*/{Protheus.doc} LoadHeader
Funcao que carrega os dados para o aheader
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 29/04/2022
@return array, Array com campos do header
/*/
Static Function LoadHeader()
    Local aArea     := GetArea()
    Local aAreaSX3  := SX3->( GetArea() )
    Local aRet      := {}
    Local aB8Saldo  := TamSX3("B8_SALDO")
    Local aCpos     := {}
    Local cIncCpo   := "C6_NUM;C6_ITEM;C6_PRODUTO;B8_PRODUTO;B8_SALDO;XX_QTDSGT;XX_QTDBOB;D4_LOTECTL;D4_NUMLOTE;D4_DTVALID;B8_DFABRIC;XX_SEQ;XX_EMP"
    Local cTitulo   := ""
    Local cValid    := ""
    Local cF3       := ""
    Local nI        := 0

    aAdd(aB8Saldo, X3Picture("B8_SALDO"))

    aCpos := StrTokArr(cIncCpo, ";")

    //-- Carrega campos
    DbSelectArea("SX3")
    SX3->( DbSetOrder(2) )

    For nI := 1 To Len(aCpos)
        If SX3->( DbSeek( aCpos[nI] ) )
            cTitulo := SX3->X3_TITULO
            cValid  := SX3->X3_VALID
            cF3     := SX3->X3_F3

            If "C6_NUM" $ SX3->X3_CAMPO
                cValid := "ExistCPO('SC6')"
                cF3    := "SC6BOB"
            ElseIf "C6_PRODUTO" $ SX3->X3_CAMPO
                cTitulo := "Produto Acabado"
                cValid  := ""
                cF3     := "SB1"
            ElseIf "B8_PRODUTO" $ SX3->X3_CAMPO
                cTitulo := "Materia Prima"
                cValid  := "ExistCPO('SB1')"
                cF3     := "SB1"
            ElseIf "B8_SALDO" $ SX3->X3_CAMPO
                cTitulo := "Peso MP (KG)"
            ElseIf "D4_LOTECTL" $ SX3->X3_CAMPO
                cValid  := "NaoVazio()"
            ElseIf "D4_NUMLOTE" $ SX3->X3_CAMPO
                cValid  := "NaoVazio()"
            EndIf

            aAdd( aRet, { cTitulo, SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, cValid, SX3->X3_USADO, SX3->X3_TIPO, cF3, SX3->X3_CBOX } )
        ElseIf "XX_QTDSGT" $ aCpos[nI]
            aAdd( aRet, { "Peso Aprox. Sugest. (KG)", "XX_QTDSGT", aB8Saldo[04], aB8Saldo[01], aB8Saldo[02], "NaoVazio() .And. Positivo()", Space(2), aB8Saldo[03], "", "" } )
        ElseIf "XX_QTDBOB" $ aCpos[nI]
            aAdd( aRet, { "Qtd. Aprox. Bobinas (UN)", "XX_QTDBOB", "999", 3, 0, "NaoVazio() .And. Positivo()", Space(2), "N", "", "" } )
        ElseIf "XX_SEQ" $ aCpos[nI]
            aAdd( aRet, { "Seq. Bobinas", "XX_SEQ", "@!", 3, 0, "Vazio()", Space(3), "C", "", "" } )
        ElseIf "XX_EMP" $ aCpos[nI]
            aAdd( aRet, { "Empenho", "XX_EMP", aB8Saldo[04], aB8Saldo[01], aB8Saldo[02], "NaoVazio() .And. Positivo()", Space(2), "N", "", "" } )
        EndIf
    Next nI

    RestArea(aAreaSX3)
    RestArea(aArea)

Return aClone(aRet)


/*/{Protheus.doc} LoadCols
Funcao que carrega os dados para o acols
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 29/04/2022
@return array, Array com campos do cols
/*/
Static Function LoadCols()
    Local aRet := {}
    Local nX   := 0

    //-- Adiciona o itens sugeridos no array que sera o aCols
    For nX := 1 To Len(_aSugest)
        aAdd(aRet, { _aSugest[nX, 01],;
                     _aSugest[nX, 02],;
                     _aSugest[nX, 03],;
                     _aSugest[nX, 04],;
                     _aSugest[nX, 12],;
                     _aSugest[nX, 05] * _aSugest[nX, 06],; //-- Solicitado pelo Jose para colocar o valor multiplicado
                     _aSugest[nX, 06],;
                     _aSugest[nX, 07],;
                     _aSugest[nX, 08],;
                     _aSugest[nX, 09],;
                     _aSugest[nX, 10],;
                     "",;
                     0,;
                     .F. } )
    Next nX

    //-- Funcao que calcula os empenhos
    CalcEmpenho(aRet)

Return aClone(aRet)


/*/{Protheus.doc} ExpExcel
Funcao que exporta para excel os dados da tela de sugestao
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 29/04/2022
/*/
Static Function ExpExcel()
    Local cTable     := "P L A N O   D E   C O R T E"
	Local cPlan      := "Bobinas"
    Local cTmpPath   := GetTempPath()
    Local cArquivo   := ""
    Local nI         := 0
    Local oFWMsExcel := Nil
    Local oExcel     := Nil

    If Aviso("Exporta Excel?", "Deseja exportar o plano de corte para excel?", {"Não", "Sim"}) == 1 
        Return
    EndIf

    //-- Criando o objeto que ira gerar o conteudo do Excel
    oFWMsExcel := FWMsExcelEx():New()

    //-- Aba
	oFWMsExcel:AddworkSheet(cPlan)
	oFWMsExcel:AddTable(cPlan, cTable)

    //-- Colunas aba
    oFWMsExcel:AddColumn(cPlan, cTable, "Num. Pedido", 2, 1)
    oFWMsExcel:AddColumn(cPlan, cTable, "Item", 2, 1)
    oFWMsExcel:AddColumn(cPlan, cTable, "Produto Acabado", 1, 1)
    oFWMsExcel:AddColumn(cPlan, cTable, "Materia Prima", 1, 1)
    oFWMsExcel:AddColumn(cPlan, cTable, "Peso Bobina (KG)", 2, 1)
    oFWMsExcel:AddColumn(cPlan, cTable, "Peso Aprox. Sugest. (KG)", 2, 1)
    oFWMsExcel:AddColumn(cPlan, cTable, "Qtd. Aprox. Bobina (UN)", 2, 1)
    oFWMsExcel:AddColumn(cPlan, cTable, "Lote", 2, 1)
    oFWMsExcel:AddColumn(cPlan, cTable, "Sub-Lote", 2, 1)
    oFWMsExcel:AddColumn(cPlan, cTable, "Data Validade", 2, 1)
    oFWMsExcel:AddColumn(cPlan, cTable, "Data Fabricacao", 2, 1)
    oFWMsExcel:AddColumn(cPlan, cTable, "Seq. Bobinas", 2, 1)
    oFWMsExcel:AddColumn(cPlan, cTable, "Empenho", 2, 1)

    //-- Funcao que calcula os empenhos - Faz a atualizacao
    CalcEmpenho(oMsGet:aCols)

    //-- Carregando os conteudos
    For nI := 1 To Len(oMsGet:aCols)
        If GdDeleted(nI, oMsGet:aHeader, oMsGet:aCols)
            Loop
        EndIf

        oFWMsExcel:AddRow( cPlan, cTable, { oMsGet:aCols[nI, 01],;
                                            oMsGet:aCols[nI, 02],;
                                            oMsGet:aCols[nI, 03],;
                                            oMsGet:aCols[nI, 04],;
                                            oMsGet:aCols[nI, 05],;
                                            oMsGet:aCols[nI, 06],;
                                            oMsGet:aCols[nI, 07],;
                                            oMsGet:aCols[nI, 08],;
                                            oMsGet:aCols[nI, 09],;
                                            oMsGet:aCols[nI, 10],;
                                            oMsGet:aCols[nI, 11],;
                                            oMsGet:aCols[nI, 12],;
                                            oMsGet:aCols[nI, 13] } )
    Next nI

    //-- Ativando o arquivo e gerando o xml
    oFWMsExcel:Activate()
    cArquivo := CriaTrab(Nil, .F.) + ".xml"

    oFWMsExcel:GetXMLFile(cArquivo)
    oFWMSExcel:DeActivate()

    If !File(cArquivo)
        MsgAlert("Nao foi possivel gerar o arquivo Excel.", "Erro geracao arquivo!")
        oFWMSExcel := FreeObj(oFWMSExcel)
        Return
    EndIf

    //-- Copia um arquivo do ambiente do servidor, para a maquina
    If CpyS2T("\SYSTEM\" + cArquivo, cTmpPath)
        //-- Abrindo o excel e abrindo o arquivo xml
        oExcel := MsExcel():New()                  //-- Abre uma nova conexao com Excel
        oExcel:WorkBooks:Open(cTmpPath + cArquivo) //-- Abre uma planilha
        oExcel:SetVisible(.T.)                     //-- Visualiza a planilha
        //oExcel:Destroy()                         //-- Encerra o processo do gerenciador de tarefas
        oExcel := oExcel:Destroy()
    Else
        MsgAlert("Erro ao copiar o arquivo Excel do [Servidor] para [" + cTmpPath + "].", "Erro copia arquivo!")
    EndIf

    oFWMSExcel := FreeObj(oFWMSExcel)

Return


/*/{Protheus.doc} Detalhes
Funcao que apresentela os detalhes de cada PV
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 29/04/2022
/*/
Static Function Detalhes()
    Local aArea       := GetArea()
    Local aAreaSA1    := SA1->( GetArea() )
    Local aAreaSC5    := SC5->( GetArea() )
    Local aAreaSC6    := SC6->( GetArea() )
    Local aMvPar      := GetMvPar()
    Local aParamBox   := {}
    Local cCadBak     := ""
    Local cPedido     := ""
    Local cItem       := ""
    Local cProduto    := ""
    Local cTolera     := ""
    Local nLine       := oMsGet:nAt
    Local nQtdPv      := 0
    Local nQtdSgt     := 0
    Local nQtdBob     := 0
    Local nI          := 0
    Local nTolerancia := 0
    Local nTolPad     := GetMv("RE_TOLPAD", .F., 10) //-- % Tolerancia padrao para a producao 

    If GdDeleted(nLine, oMsGet:aHeader, oMsGet:aCols)
        MsgAlert("Não é permitido visualizar detalhes de linhas deletadas.", "Linha deletada!")
        Return
    EndIf

    SC5->( DbSetOrder(1) )
    SC5->( DbSeek( xFilial("SC5") + oMsGet:aCols[nLine, 01] ) )
    nTolerancia := SC5->C5_XTOLERA

    If Empty(nTolerancia)
        SA1->( DbSetOrder(1) )
        SA1->( DbSeek( xFilial("SA1") + SC5->(C5_CLIENTE + C5_LOJACLI) ) )
        nTolerancia := Iif( !Empty(SA1->A1_XTOLERA), SA1->A1_XTOLERA, nTolPad )
    EndIf

    cTolera := "± " + cValToChar( nTolerancia ) + "%"

    SC6->( DbSetOrder(1) )
    SC6->( DbSeek(xFilial("SC6") + oMsGet:aCols[nLine, 01] + oMsGet:aCols[nLine, 02]) )
    cPedido  := SC6->C6_NUM
    cItem    := SC6->C6_ITEM
    cProduto := SC6->C6_PRODUTO
    nQtdPv   := SC6->C6_QTDVEN

    For nI := 1 To Len(oMsGet:aCols)
        If oMsGet:aCols[nI, 01] + oMsGet:aCols[nI, 02] == cPedido + cItem .And. !GdDeleted(nI, oMsGet:aHeader, oMsGet:aCols)
            nQtdSgt += oMsGet:aCols[nI, 06] //* oMsGet:aCols[nI, 07]
            nQtdBob += oMsGet:aCols[nI, 07]
        EndIf
    Next nI

    cCadBak   := cCadastro
    cCadastro := ""

    aAdd(aParamBox, {1, "Pedido"                  , cPedido , "@!"                 , , "SC6", ".F.", 70, .F.})
    aAdd(aParamBox, {1, "Item"                    , cItem   , "@!"                 , ,      , ".F.", 20, .F.})
    aAdd(aParamBox, {1, "Produto Acabado"         , cProduto, "@!"                 , , "SB1", ".F.", 70, .F.})
    aAdd(aParamBox, {1, "Peso Solicitado (KG)"    , nQtdPv  , X3Picture("B8_SALDO"), ,      , ".F.", 70, .F.})
    aAdd(aParamBox, {1, "Tolerância"              , cTolera , "@!"                 , ,      , ".F.", 20, .F.})
    aAdd(aParamBox, {1, "Peso Aprox. Sugest. (KG)", nQtdSgt , X3Picture("B8_SALDO"), ,      , ".F.", 70, .T.})
    aAdd(aParamBox, {1, "Qtd. Aprox. Bobinas (UN)", nQtdBob , "999"                , ,      , ".F.", 50, .T.})

    ParamBox(aParamBox, "Detalhes", {}, {|| AllwaysTrue() },,.T.,,,,, .F., .F.)

    cCadastro := cCadBak

    RestMvPar(aMvPar)
    RestArea(aAreaSC6)
    RestArea(aAreaSC5)
    RestArea(aAreaSA1)
    RestArea(aArea)

Return 


/*/{Protheus.doc} REPCPA7P
Funcao que carrega os parametros da sugestao de bobinas
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 29/04/2022
/*/
User Function REPCPA7P()
    Pergunte("REPCPA7P", .T.)
Return


/*/{Protheus.doc} REPCPA7L
Funcao que realiza a validacao do linha ok
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 29/04/2022
@return logical, Retorno logico
/*/
User Function REPCPA7L()
    Local cNumPV  := GdFieldGet( "C6_NUM", N, , , )
    Local cItemPV := GdFieldGet( "C6_ITEM", N, , , )
    Local cProd   := GdFieldGet( "C6_PRODUTO", N, , , )
    Local cMP     := GdFieldGet( "B8_PRODUTO", N, , , )
    Local nQtdSgt := GdFieldGet( "XX_QTDSGT", N, , , )
    Local nQtdBob := GdFieldGet( "XX_QTDBOB", N, , , )
    Local lRet    := .T.

    If Empty(cItemPV + cProd)
        Help(Nil, Nil, "Não Informado", Nil, "Produto Acabado/Item não foram informados para o pedido de venda [" + cNumPV + "].", 1, 0, Nil, Nil, Nil, Nil, Nil, {"Informe o pedido de venda clicando na Lupa ou no F3 do campo para que o Item e o Produto Acabado sejam preenchidos automaticamente."})
        lRet := .F.
    /*ElseIf aScan( _aSugest, { |x| x[1] + x[2] == cNumPV + cItemPV } ) == 0
        Help(Nil, Nil, "Não Pemitido", Nil, "Numero de Pedido [" + cNumPV + "-" + cItemPV + "] informado não foi selecionado para abertura de OP.", 1, 0, Nil, Nil, Nil, Nil, Nil, {"Informe um numero de pedido de venda que foi selecionada para abertura de Ordens de Produção."})
        lRet := .F.*/
    ElseIf !Empty(cMP) .And. ( Empty(nQtdSgt) .Or. Empty(nQtdBob) )
        Help(Nil, Nil, "Não Informado", Nil, "Peso Aprox. Sugest. (KG) ou Qtd. Aprox. Bobina (UN) da bobina não foram informados.", 1, 0, Nil, Nil, Nil, Nil, Nil, {"Informe o Peso Aprox. Sugest. (KG) e a Qtd. Aprox. Bobina (UN) da bobina para prosseguir."})
        lRet := .F.
    EndIf

Return lRet


/*/{Protheus.doc} REPCPA7C
Funcao que realiza a validacao da coluna ok 
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 29/04/2022
@return logical, Retorno logico
/*/
User Function REPCPA7C()
    Local aArea    := GetArea()
    Local aAreaSB8 := SB8->( GetArea() )
    Local cCampo   := ReadVar()
    Local cLocal   := _aREPCPA7P[02]
    Local cNumPV   := GdFieldGet( "C6_NUM", N, .T., , )
    Local cCodMP   := GdFieldGet( "B8_PRODUTO", N, .T., , )
    Local cLotCtl  := GdFieldGet( "D4_LOTECTL", N, .T., , )
    Local cLote    := GdFieldGet( "D4_NUMLOTE", N, .T., , )
    Local lRet     := .T.

    If cCampo $ "M->C6_NUM" .And. aScan( _aSugest, { |x| x[1] == cNumPV } ) == 0
        Help(Nil, Nil, "Não Pemitido", Nil, "Numero de Pedido [" + cNumPV + "] não foi selecionado para abertura de OP.", 1, 0, Nil, Nil, Nil, Nil, Nil, {"Informe um numero de pedido de venda que foi selecionada para abertura de Ordens de Produção."})
        lRet := .F.
    ElseIf cCampo $ "M->D4_LOTECTL" .Or. cCampo $ "M->D4_NUMLOTE"
        DbSelectArea("SB8")
        SB8->( DbSetOrder(2) ) //-- B8_FILIAL+B8_NUMLOTE+B8_LOTECTL+B8_PRODUTO+B8_LOCAL+DTOS(B8_DTVALID)

        If SB8->( DbSeek( xFilial("SB8") + cLote + cLotCtl + cCodMP + cLocal ) )
            GdFieldPut( "B8_SALDO", SB8->B8_SALDO, N )
            GdFieldPut( "B8_DFABRIC", SB8->B8_DFABRIC, N )
            GdFieldPut( "XX_QTDSGT", 0, N )
            GdFieldPut( "XX_QTDBOB", 0, N )
        Else
            Help(Nil, Nil, "Não Existe", Nil, "Lote/Sublote não encontrado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {"Informe um Lote/Sublote que exista."})
            lRet := .F.
        EndIf
    EndIf

    RestArea(aAreaSB8)
    RestArea(aArea)

Return lRet


/*/{Protheus.doc} ShowF4
Mostra a tela dos saldos no F4
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 29/04/2022
/*/
Static Function ShowF4()
    Local cCampo := ReadVar()
    Local cCodMP := ""
    Local cLocal := _aREPCPA7P[02]

    If cCampo == "M->B8_PRODUTO" .Or. cCampo == "M->D4_LOTECTL" .Or. cCampo == "M->D4_NUMLOTE"
        If Empty( cCodMP := GdFieldGet( "B8_PRODUTO", N, , , ) )
            Help(Nil, Nil, "Não Informado", Nil, "Materia Prima não informada.", 1, 0, Nil, Nil, Nil, Nil, Nil, {"Informe uma Materia Prima clicando na Lupa ou F3 do campo."})
            Return
        EndIf

        nPosLotCtl := GdFieldPos( "D4_LOTECTL", )
        nPosLote   := GdFieldPos( "D4_NUMLOTE", )
        nPosDValid := GdFieldPos( "D4_DTVALID", )

        If cCampo == "M->D4_LOTECTL" .Or. cCampo == "M->D4_NUMLOTE"
            F4Lote( ,,, "A381", cCodMP, cLocal )
        ElseIf cCampo == "M->B8_PRODUTO"
            MaViewSB2( cCodMP )
        EndIf
    EndIf

Return


/*/{Protheus.doc} Salvar
Confirmacao da sugestao de bobinas
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 29/04/2022
@return logical, Retorno logico
/*/
Static Function Salvar()
    Local lRet := .F.

    If !TudoOk()
        Return lRet
    EndIf

    If Aviso("Confirma Sugestão?", "Confirma a sugestão das bobinas listadas para os pedidos selecionados para produção?", {"Não", "Sim"}) == 2
        //-- Salvando, realiza a gravacao das sugestoes na tabela SZ4
        lRet := GravaSgtBob()
    EndIf

Return lRet


/*/{Protheus.doc} GravaSgtBob
Gravacao das bobinas sugeridas na tabela de LOG
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 29/04/2022
@return logical, Retorno logico
/*/
Static Function GravaSgtBob()
    Local dEmissao := ""
    Local cHora    := ""
    Local nI       := 0

    dEmissao := SToD( SubStr(cIdSgt, 1, 8) ) //-- 20190414084826
    cHora    := Transform( SubStr(cIdSgt, 9, 4), "@R 99:99" )

    //-- Grava os itens sugesridos na tabela SZ4 de historicos
    DbSelectArea("SZ4")

    For nI := 1 To Len(oMsGet:aCols)
        If GdDeleted(nI, oMsGet:aHeader, oMsGet:aCols)
            Loop
        EndIf

        RecLock("SZ4", .T.)
            SZ4->Z4_FILIAL  := xFilial("SZ4")
            SZ4->Z4_NUMPV   := oMsGet:aCols[nI, 01]
            SZ4->Z4_ITEM    := oMsGet:aCols[nI, 02]
            SZ4->Z4_CODPA   := oMsGet:aCols[nI, 03]
            SZ4->Z4_CODMP   := oMsGet:aCols[nI, 04]
            SZ4->Z4_SLDMP   := oMsGet:aCols[nI, 05]
            SZ4->Z4_QTDSGT  := oMsGet:aCols[nI, 06]
            SZ4->Z4_QTDBOB  := oMsGet:aCols[nI, 07]
            SZ4->Z4_LOTECTL := oMsGet:aCols[nI, 08]
            SZ4->Z4_NUMLOTE := oMsGet:aCols[nI, 09]
            SZ4->Z4_DTVALID := oMsGet:aCols[nI, 10]
            SZ4->Z4_DFABRIC := oMsGet:aCols[nI, 11]
            SZ4->Z4_LOCAL   := _aREPCPA7P[02]
            SZ4->Z4_EMISSAO := dEmissao
            SZ4->Z4_HORA    := cHora
            SZ4->Z4_ID      := cIdSgt
            SZ4->Z4_SEQ     := oMsGet:aCols[nI, 12]
            SZ4->Z4_EMP     := oMsGet:aCols[nI, 13]
        SZ4->( MsUnLock() )
    Next nI

Return .T.


/*/{Protheus.doc} TudoOk
Realiza a verificacao do Tudo Ok
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 29/04/2022
@return logical, Retorno logico
/*/
Static Function TudoOk()
    Local nI, nJ := 0
    Local nCount := 0
    Local lRet   := .T.

    //-- Funcao que calcula os empenhos
    CalcEmpenho(oMsGet:aCols)

    For nI := 1 To Len(oMsGet:aCols)
        If GdDeleted(nI, oMsGet:aHeader, oMsGet:aCols)
            Loop
        EndIf

        //-- Conta a quantidades de linha ativas
        nCount++

        For nJ := 1 To Len(oMsGet:aCols[nI]) - 1
            If Empty( oMsGet:aCols[nI, nJ] )
                lRet := .F.
            EndIf 
        Next nJ

        If !lRet
            Exit
        EndIf
    Next nI

    If Empty(nCount)
        MsgStop("Todas as linhas de bobinas sugeridas foram deletadas. " + chr(13) + chr(10) + "Não é permitido prosseguir.", "Linhas Deletadas!")
        lRet := .F.
    ElseIf !lRet
        Help(Nil, Nil, "Obrigatorio", Nil, "Existem informações obrigatorias que não foram preenchidas.", 1, 0, Nil, Nil, Nil, Nil, Nil, {"Preencha todos os dados obrigatorios. Exemplo: Num. Pedido, Materia Prima, Peso Aprox., Qtd. Aprox., Lote, ..."})
    EndIf

Return lRet


/*/{Protheus.doc} Cancelar
Ao realizar o cancelamento
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 29/04/2022
@return logical, Retorno logico
/*/
Static Function Cancelar()
    Local aArea    := GetArea()
    Local aAreaSB8 := SB8->(GetArea())
    Local nX       := 0
    Local lRet     := .F.

    If Aviso("Cancelar?", "Realmente deseja cancelar a sugestão das bobinas listadas?", {"Sim", "Não"}) == 1

        //-- Limpa o Id de sugestao do campo B8_XIDSGT, quando o cancelamento e confirmado
        DbSelectArea("SB8")
        For nX := 1 To Len(_aSugest)
            SB8->( DbGoTo(_aSugest[nX, 13]) )

            RecLock("SB8", .F.)
                SB8->B8_XIDSGT := ""
            SB8->( MsUnLock() )
        Next nX

        lRet := .T.
    EndIf

    RestArea(aAreaSB8)
    RestArea(aArea)

Return lRet


/*/{Protheus.doc} CalcEmpenho
Realiza o calculo dos empenhos com base nas sugestoes
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 29/04/2022
@param aAuxCols, array, Array com as bobinas da tela
/*/
Static Function CalcEmpenho(aAuxCols)
    Local aAuxSgt   := aClone(aAuxCols)
    Local cNumPV    := ""
    Local cItemPV   := ""
    Local cLote     := ""
    Local cNumLote  := ""
    Local nX        := 0 
    Local nPos      := 0
    Local nSeq      := 0
    Local nQtdSum   := 0
    Local lLoadCols := IsInCallStack("LoadCols")  

    //-- Re-ordena o array auxiliar pelo PA e sub-lote
    If _aREPCPA7P[3] == 1
        //-- Crescente
        aSort( aAuxSgt, , , { |x, y| x[8] + x[3] < y[8] + y[3] } )
    ElseIf _aREPCPA7P[3] == 2
        //-- Decrescente
        aSort( aAuxSgt, , , { |x, y| x[8] + x[3] > y[8] + y[3] } )
    EndIf

    If !lLoadCols    
        //-- Remove as linhas deletadas do array auxiliar de sugestoes
        aAuxSgt := GetUnDeleted(aAuxSgt)
    EndIf

    If !Empty(aAuxSgt)
        For nX := 1 To Len(aAuxSgt)
            cNumPV   := aAuxSgt[nX, 01]
            cItemPV  := aAuxSgt[nX, 02]
            cLote    := aAuxSgt[nX, 08]
            cNumLote := aAuxSgt[nX, 09]

            If Len(aAuxSgt) # nX .And. cLote + cNumLote == aAuxSgt[nX+1, 08] + aAuxSgt[nX+1, 09]
                //-- Ajustes apos testes do Ricardo 19/05/2022. by Dener Lemos
                nQtdEmp := aAuxSgt[nX, 06]
                nQtdSum += nQtdEmp
            Else
                nQtdEmp := aAuxSgt[nX, 05] - nQtdSum
                nQtdSum := 0
            EndIf

            nPos := aScan( aAuxCols, { |x| x[1] + x[2] + x[8] + x[9] == cNumPV + cItemPV + cLote + cNumLote } )
            
            nSeq++
            aAuxCols[nPos, 12] := StrZero(nSeq, 3)
            aAuxCols[nPos, 13] := nQtdEmp

            If Len(aAuxSgt) # nX .And. aAuxSgt[nX, 08] + aAuxSgt[nX, 09] # aAuxSgt[nX+1, 08] + aAuxSgt[nX+1, 09]
                nSeq := 0
            EndIf
        Next nX
    EndIf
    
Return


/*/{Protheus.doc} GetUnDeleted
Retorna apenas as linhas nao deletadas
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 01/05/2022
@param aAuxSgt, array, Array auxiliar da tela
@return array, Array nao deletados
/*/
Static Function GetUnDeleted(aAuxSgt)
    Local aTmp := {}
    Local nI   := 0

    For nI := 1 To Len(aAuxSgt)
        If aAuxSgt[nI, 14]
            Loop
        EndIf

        aAdd( aTmp, aAuxSgt[nI] )
    Next

Return aClone(aTmp)


/*/{Protheus.doc} GetMvPar
Guarda o conteudo dos parametros MV_PAR
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 02/05/2022
@return array, Conteudo MV_PAR
/*/
Static Function GetMvPar()
    Local aRet := {}
    Local nX   := 0

    For nX := 1 To 10
        aAdd( aRet, &( "MV_PAR" + StrZero( nX, 2, 0 ) ) )
    Next nX

Return aClone(aRet)


/*/{Protheus.doc} RestMvPar
Retorna conteudo dos parametros MV_PAR
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 02/05/2022
@param aMvPar, array, Conteudo MV_PAR
/*/
Static Function RestMvPar(aMvPar)
    Local nX := 0

    For nX := 1 To Len(aMvPar)
        &( "MV_PAR" + StrZero( nX, 2, 0 ) ) := aMvPar[nX]
    Next nX

Return
