#include "totvs.ch"
#include "fwmvcdef.ch"


/*/{Protheus.doc} REFATA09
Rotina que faz o preenchimento automatico dos itens na tela de pedido de vendas, 
esse preenchimento e feito com base de solicitacoes de transferencia
@type function
@version 1.0
@author DO THINK - DENER LEMOS
@since 08/02/2024
/*/
User Function REFATA09()
    Local cFilBrw  := ""
    Local cFilBkp  := FWCodFil()
    Local lTudoOk  := .F.
    Local oAutDlg  := Nil
    Local oPnlGrid := Nil

    Private aItDados := {}
    Private cFilOrig := GetMV("RE_FILORIG", .F., "0302")
	Private cFilDest := GetMV("RE_FILDEST", .F., "0201")
    Private cFilArm  := GetMV("RE_FILARM", .F., "0303")
    Private oMarkBrw := Nil

    //-- So faz o Auto Preenchimento se nao for devolucao ou beneficiamento
	If M->C5_TIPO $ "DB"
		Return
	EndIf

	If Empty(M->C5_CLIENTE) .Or. Empty(M->C5_LOJACLI)
		FWAlertError("Favor informar um <b>Cliente</b> e <b>Loja</b> no Pedido de Venda," + Chr(13) + Chr(10) + "antes de realizar o Auto Preenchimento.", "Não Permitido!")
		Return
	EndIf

	If !Pergunte("REFATA09", .T., "Parâmetros Auto Preenchimento")
	   Return
	EndIf

    //-- Seta a filial
    cFilAnt := MV_PAR01

    //-- Filtro da Solicitacao de Transferencia
    cFilBrw := "NNS_FILIAL=='"+FWCodFil()+"'"
    cFilBrw += ".And.NNS_STATUS=='2'"
    cFilBrw += ".And.NNS_XOP==' '"

    If !Empty(MV_PAR02) .And. !Empty(MV_PAR03)
        cFilBrw += ".And.DToS(NNS_DATA)>='"+DToS(MV_PAR02)+"'"
        cFilBrw += ".And.DToS(NNS_DATA)<='"+DToS(MV_PAR03)+"'"
    EndIf

    If !Empty(MV_PAR04)
        cFilBrw += ".And.NNS_SOLICT=='"+MV_PAR04+"'
    EndIf

    //-- Telinha customizada
	oAutDlg := FWDialogModal():new()
	oAutDlg:setBackground(.T.)
	oAutDlg:setEscClose(.F.)
    oAutDlg:setSize(220, 520)
    oAutDlg:setTitle("Auto Preenchimento - Solicitação de Transferência")
    oAutDlg:setSubTitle("Esse programa tem como objetivo fazer o preenchimento automático dos itens do pedido de venda, com base em solicitaçõs de transferência.")
	oAutDlg:enableFormBar(.T.)
	oAutDlg:createDialog()
	oAutDlg:addButton("Confirmar", {|| lTudoOk := VldTudoOk(), Iif(lTudoOk, oAutDlg:deactivate(), oAutDlg)}, "Confirmar",,.T.,.F.,.T.)
    oAutDlg:addButton("Detalhes", {|| GetDetails()}, "Detalhes",,.T.,.F.,.T.)
	oAutDlg:setEscClose(.T.)
    oPnlGrid := oAutDlg:getPanelMain()

    //-- MarkBrowse
    oMarkBrw := FWMarkBrowse():new()
    oMarkBrw:setAlias("NNS")
    oMarkBrw:setFieldMark("NNS_XOK")
    oMarkBrw:setFilterDefault(cFilBrw)
    oMarkBrw:setCustomMarkRec({|| CustomMark(oMarkBrw)})
    oMarkBrw:setIgnoreARotina(.T.)
    oMarkBrw:setMenuDef("")
    oMarkBrw:setOwner(oPnlGrid)
    oMarkBrw:setSemaphore(.T.)
    oMarkBrw:disableFilter()
    oMarkBrw:disableConfig()
    oMarkBrw:disableReport()
    oMarkBrw:disableSeek()
    oMarkBrw:disableSaveConfig()

    oMarkBrw:activate()

	oAutDlg:activate()

    //-- Processa o preenchimento dos itens
    If lTudoOk
        FWMsgRun(, {|oSay| LoadItens(oSay) }, "Aguarde", "Preenchimento os itens no pedido de venda")
    EndIf

    //-- Restaura filial
    cFilAnt := cFilBkp

Return


/*/{Protheus.doc} CustomMark
Rotina que faz a marcacao customizada
@type function
@version 1.0
@author DO THINK - DENER LEMOS
@since 08/02/2024
@param oMrkBrowse, object, Objeto do MarkBrowse
@return logical, Retorno logico
/*/
Static Function CustomMark(oMrkBrowse)
    Local cAlias := oMrkBrowse:alias()

    If !oMrkBrowse:isMark()
        RecLock(cAlias, .F.)
            (cAlias)->NNS_XOK := oMrkBrowse:mark()
        (cAlias)->(MsUnLock())
    Else
        RecLock(cAlias, .F.)
            (cAlias)->NNS_XOK := ""
        (cAlias)->(MsUnLock())
    EndIf     

Return .T.


/*/{Protheus.doc} VldTudoOk
Rotina de validacao tudo ok
@type function
@version 1.0
@author DO THINK - DENER LEMOS
@since 08/02/2024
@return logical, Retorno logico
/*/
Static Function VldTudoOk()
    Local nMaxSelect := 3

    //-- Pega os itens selecionados
    aItDados := GetItDados()

    //-- Valida se alguma solicitacao de transferencia foi marcada
    If Empty(aItDados)
        FWAlertError("Nenhuma solicitação de transferência foi marcada.", "Sem Marcação!")
        Return .F.
    EndIf

    //-- Valida a quantidade maxima de solicitacoes de transferencia a serem marcadas
    If Len(aItDados) > nMaxSelect
        FWAlertError("A quantidade máxima de solicitações de transferência a serem marcadas de uma só vez é de " + CValToChar(nMaxSelect) + ".", "Marcação Máxima!")
        Return .F.
    EndIf

Return .T.


/*/{Protheus.doc} GetItDados
Rotina que carrega os itens que foram marcados
@type function
@version 1.0
@author DO THINK - DENER LEMOS
@since 08/02/2024
@return array, Array com itens marcados na tela
/*/
Static Function GetItDados()
    Local aAreaNNS := NNS->(GetArea())
    Local aRet     := {}
    Local cAlias   := oMarkBrw:alias()

    (cAlias)->(dbGoTop())
    While (cAlias)->(!EoF())
        If (oMarkBrw:isMark())
            //-- Pega as STs selecionadas
            aAdd(aRet, NNS->NNS_COD)

            //-- Desmarca
            RecLock(cAlias, .F.)
                (cAlias)->NNS_XOK := ""
            (cAlias)->(MsUnLock())
        EndIf
        (cAlias)->( DbSkip() )
    EndDo

    RestArea(aAreaNNS)

Return aRet


/*/{Protheus.doc} GetDetails
Rotina que chama a tela padrao de visualizacao da solicitacao de transferencia
@type function
@version 1.0
@author DO THINK - DENER LEMOS
@since 08/02/2024
@return object, Retorna a classe FWExecView
/*/
Static Function GetDetails()
Return FWExecView("Detalhes", "REESTA01", MODEL_OPERATION_VIEW,, {|| .T.})


/*/{Protheus.doc} LoadItens
Rotina que carrega os itens do pedido de venda
@type function
@version 1.0
@author DO THINK - DENER LEMOS
@since 08/02/2024
@param cPerg, character, Codigo da pergunta
/*/
Static Function LoadItens(oSay)
    Local aAreaAnt := GetArea()
    Local aAreaSC6 := SC6->(GetArea())
    Local aAreaSB2 := SB2->(GetArea())
    Local cQuery   := ""
    Local nZ,nX    := 0
    Local nPProd   := aScan(aHeader, {|x| AllTrim(x[2]) == "C6_PRODUTO"})
    Local nPTES    := aScan(aHeader, {|x| AllTrim(x[2]) == "C6_TES"})
    Local nPItem   := aScan(aHeader, {|x| AllTrim(x[2]) == "C6_ITEM"})
    Local nPPrcVen := aScan(aHeader, {|x| AllTrim(x[2]) == "C6_PRCVEN"})
    Local nPTotal  := aScan(aHeader, {|x| AllTrim(x[2]) == "C6_VALOR"})
    Local nPLoteCT := aScan(aHeader, {|x| AllTrim(x[2]) == "C6_LOTECTL"})
    Local nPNumLot := aScan(aHeader, {|x| AllTrim(x[2]) == "C6_NUMLOTE"})
    Local nTotal   := 0
    Local nCount   := 1

    SB2->(dbSetOrder(1))
    
    For nZ := 1 To Len(aItDados)
        If Select("TMP") > 0
            TMP->(dbCloseArea())
        EndIf
        
        //-- Query para consultar itens na NNT
        cQuery := " SELECT "
        cQuery += "     NNT_PROD, NNT_QUANT, "
        cQuery += "     NNT_LOTECT, NNT_NUMLOT "
        cQuery += " FROM "
        cQuery += "     " + RetSQLName("NNT") + " "
        cQuery += " WHERE "
        cQuery += "     NNT_FILIAL = '" + xFilial("NNT") + "' "
        cQuery += "     AND NNT_COD = '" + aItDados[nZ] + "' "
        cQuery += "     AND D_E_L_E_T_ = ' ' "

        cQuery := ChangeQuery(cQuery)
        DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), "TMP", .F., .T.)

        //-- Conta os registros e volta vai para o topo
        Count To nTotal
        TMP->(DbGoTop())

        ProcRegua(nTotal)

        While TMP->(!Eof())
            //-- Incrementa na barra de processamento
            IncProc()

            N := Len(aCols)

            If N == 1
                aCols[N, Len(aHeader)+1] := .F.
            EndIf
            
            A410Produto(TMP->NNT_PROD, .F.)

            aCols[N, nPProd] := TMP->NNT_PROD
            A410MultT("M->C6_PRODUTO", TMP->NNT_PROD)

            If ExistTrigger("C6_PRODUTO")
                RunTrigger(2, N, Nil,, "C6_PRODUTO")
            EndIf

            A410SegUm(.T.)
            A410MultT("M->C6_QTDVEN", TMP->NNT_QUANT)

            If ExistTrigger("C6_QTDVEN")
                RunTrigger(2, N, Nil,, "C6_QTDVEN")
            EndIf

            //-- Obtem preco - custo medio unitario da filial da REPLAS
            If SB2->(dbSeek(xFilial("SB2") + TMP->NNT_PROD))
                aCols[N, nPPrcVen] := SB2->B2_CM1

                A410QtdGra()
                A410MultT("M->C6_PRCVEN", SB2->B2_CM1)

                If ExistTrigger("C6_PRCVEN")
                    RunTrigger(2, N, Nil,, "C6_PRCVEN")
                EndIf
            EndIf

            aCols[N, nPLoteCT] := TMP->NNT_LOTECT
            If ExistTrigger("C6_LOTECTL")
                RunTrigger(2, N, Nil,, "C6_LOTECTL")
            EndIf

            aCols[N, nPNumLot] := TMP->NNT_NUMLOT
            If ExistTrigger("C6_NUMLOTE")
                RunTrigger(2, N, Nil,, "C6_NUMLOTE")
            EndIf

            If Empty(aCols[N, nPTotal]) .Or. Empty(aCols[N, nPTES])
                aCOLS[N, Len(aHeader)+1] := .T.
            EndIf

            //-- Pega item atual
            cItem := aCols[Len(aCols), nPItem]

            //-- Tratamento para inclusao de uma nova linha na grid
            If nCount <= nTotal
                //-- Adiciona um nova linha na grid
                aAdd(aCols, Array(Len(aHeader)+1))

                For nX := 1 To Len(aHeader)
                    If AllTrim(aHeader[nX, 02]) == "C6_ITEM"
                        aCols[Len(aCols), nX] := Soma1(cItem)
                    Else
                        If aHeader[nX, 02] # "C6_REC_WT" .And. aHeader[nX, 02] # "C6_ALI_WT"
                            aCols[Len(aCols), nX] := CriaVar(aHeader[nX, 02])
                        EndIf
                    EndIf
                Next nX

                nCount++
            EndIf

            TMP->(DbSkip())
        EndDo
    Next nZ

    If Select("TMP") > 0
        TMP->(dbCloseArea())
    EndIf

    oGetDad:refresh()

    RestArea(aAreaSB2)
    RestArea(aAreaSC6)
    RestArea(aAreaAnt)

Return


/*/{Protheus.doc} RFATA09A
Rotina de validacao da filial no pergunte REFATA09
@type function
@version 1.0
@author DO THINK - DENER LEMOS
@since 21/02/2024
@param cFilPerg, character, Filial atual
@return logical, Retorno logico
/*/
User Function RFATA09A(cFilPerg)
    Local lRet := .T.

    If ValType(cFilDest) != "C"
        cFilDest := GetMV("RE_FILDEST", .F., "0201")
    EndIf

    If ValType(cFilDest) != "C"
        cFilArm := GetMV("RE_FILARM", .F., "0303")
    EndIf

    If !(cFilPerg == cFilDest) .And. !(cFilPerg == cFilArm)
        Aviso("Filial Inválida!", "A Filial Origem deve ser igual a [" + cFilDest + "] ou ["+ cFilArm +"]!", {"OK"})
        lRet := .F.
    EndIf

Return lRet
