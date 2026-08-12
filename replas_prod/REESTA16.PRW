#include "totvs.ch"


/*/{Protheus.doc} REESTA16
Rotina tem o objetivo de automatizar o processo de transferencia entre as Empresas/Filiais da Replas, atraves de Solicitacoes de Transferecia
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 17/06/2024
/*/
User Function REESTA16()
    Local aSays    := {}
    Local aButtons := {}
    Local cPergSX1 := "REESTA16"
    Local cBkpFil  := FWCodFil()
    Local lOk      := .F.

    Private cEmpFilOri := Space(Len(SB1->B1_FILIAL))
    Private cEmpFilDes := Space(Len(SB1->B1_FILIAL))
    Private cTpSaida   := Space(Len(SB1->B1_TS))
    Private cTpEntra   := Space(Len(SB1->B1_TE))
    Private cProdDe    := Space(Len(SB1->B1_COD))
    Private cProdAte   := Replicate("Z", Len(SB1->B1_COD))
    Private cGrupDe    := Space(Len(SB1->B1_GRUPO))
    Private cGrupAte   := Replicate("Z", Len(SB1->B1_GRUPO))
    Private nGrupProd  := 2
    Private nTpDocEntr := 2
    Private nTpSolTran := 1
    Private nLimItemPV := GetMV("MV_NUMITEN", .F., 99)
    Private cArmOrigem := Space(Len(SB1->B1_LOCPAD))
    Private cArmDestin := Space(Len(SB1->B1_LOCPAD))
    Private nPreVisual := 2
    Private cPVPalete  := Space(Len(SC6->C6_NUM))
    Private cItPalete  := Space(Len(SC6->C6_ITEM))
    
    //-- Objetivo da rotina
    aAdd(aSays, "Esta rotina tem o objetivo de automatizar o processo de transferência entre as Empresas/Filiais da Replas.")
    aAdd(aSays, "Para o correto funcionamento dessa solução devem ser informados parametros e filtros pré-selecionados.")
    aAdd(aSays, "Basicamente o processo é feito em duas etapas, na primeira etapa são feitas as leituras dos saldos dos")
    aAdd(aSays, "produtos nas tabelas [SB2 e SB8], os produtos não podem ter reservas ou empenhos, ja na segunda etapa são")
    aAdd(aSays, "incluidas e/ou efetivadas Solicitações de Transferecia para que os saldos sejam transferidos entre as")
    aAdd(aSays, "Empresas/Filiais. A Solicitação de Transferência é um solução especifica da Replas que faz o faturamento")
    aAdd(aSays, "na Origem e a entrada no Destino de forma automatica.")

    aAdd(aButtons, {1, .T., {|| lOk := .T., FechaBatch()}})
    aAdd(aButtons, {2, .T., {|| lOk := .F., FechaBatch()}})

    FormBatch("Transferência Empresas/Filiais", aSays, aButtons,, 270, 620)

    If !lOk
        Return
    EndIf

	While .T.
        //-- Inicializa parametros
        SetMVValue(cPergSX1, "MV_PAR01", cEmpFilOri) //-- Emp./Filial Origem
        SetMVValue(cPergSX1, "MV_PAR02", cEmpFilDes) //-- Emp./Filial Destino
        SetMVValue(cPergSX1, "MV_PAR03", cTpSaida)   //-- Tipo Saida
        SetMVValue(cPergSX1, "MV_PAR04", cTpEntra)   //-- Tipo Entrada
        SetMVValue(cPergSX1, "MV_PAR05", cProdDe)    //-- Produto De
        SetMVValue(cPergSX1, "MV_PAR06", cProdAte)   //-- Produto Ate
        SetMVValue(cPergSX1, "MV_PAR07", cGrupDe)    //-- Grupo De
        SetMVValue(cPergSX1, "MV_PAR08", cGrupAte)   //-- Grupo Ate
        SetMVValue(cPergSX1, "MV_PAR09", nGrupProd)  //-- Grupo Produto Replas - [1=Outros;2=Filme;3=Resina Nacional;4=Resina Importada (Padrao deve ser "2")]
        SetMVValue(cPergSX1, "MV_PAR10", nTpDocEntr) //-- Tp. Doc. Entrada - [1=A Classificar;2=Classificado (Padrao deve ser "2")]
        SetMVValue(cPergSX1, "MV_PAR11", nTpSolTran) //-- Tp. Solic. Transf. - [1=Incluir;2=Incluir/Efetvar (Padrao deve ser "1")]
        SetMVValue(cPergSX1, "MV_PAR12", nLimItemPV) //-- Qtde. Max. Itens ST
        SetMVValue(cPergSX1, "MV_PAR13", cArmOrigem) //-- Armazem Origem
        SetMVValue(cPergSX1, "MV_PAR14", cArmDestin) //-- Armazem Destino
        SetMVValue(cPergSX1, "MV_PAR15", nPreVisual) //-- Pre-visualizar - [1=Sim;2=Nao (Padrao deve ser "2")]
        SetMVValue(cPergSX1, "MV_PAR16", cPVPalete)  //-- Pedido de Venda da paletizacao
        SetMVValue(cPergSX1, "MV_PAR17", cItPalete)  //-- Item do Pedido de Venda da paletizacao

        If !Pergunte(cPergSX1, .T., "Transferência Empresas/Filiais")
            Exit
        EndIf

        If TudoOk()
            //-- Inicializa as variaveis com os conteudos setados pelo usuario
            cEmpFilOri := MV_PAR01
            cEmpFilDes := MV_PAR02
            cTpSaida   := MV_PAR03
            cTpEntra   := MV_PAR04
            cProdDe    := MV_PAR05
            cProdAte   := MV_PAR06
            cGrupDe    := MV_PAR07
            cGrupAte   := MV_PAR08
            nGrupProd  := MV_PAR09
            nTpDocEntr := MV_PAR10
            nTpSolTran := MV_PAR11
            nLimItemPV := MV_PAR12
            cArmOrigem := MV_PAR13
            cArmDestin := MV_PAR14
            nPreVisual := MV_PAR15
            cPVPalete  := MV_PAR16
            cItPalete  := MV_PAR17

            //-- Altera variavel da filial
            cFilAnt := cEmpFilOri

            //-- Pre-visualiza os produtos
            If nPreVisual == 1
                //-- Chama a pre-visualizacao
                MsAguarde({|| PreVisual()}, "Aguarde...", "Carregando produtos para pré-visualização...")
                Loop
            EndIf

            If FWAlertYesNo( "Deseja incluir/efetivar <b>Solicitações de Transferência em Lote</b> para os produtos filtrados?", "Solicitação Transferência?" )
                //-- Chama a execuxao para incluir/efetivar as STs
                MsAguarde({|| ExecSTs()}, "Aguarde...", "Carregando produtos...")
            EndIf

            cFilAnt := cBkpFil
        EndIf
	EndDo

Return


/*/{Protheus.doc} TudoOk
Rotina de validacao tudo ok do parametros digitados pelo usuario
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 17/06/2024
@return logical, Retorno logico
/*/
Static Function TudoOk()
    Local nNumItem := GetMV("MV_NUMITEN", .F., 99)

    If MV_PAR01 == MV_PAR02
        Aviso("Atenção!", "A Emp./Filial Origem deve ser diferente da Emp./Filial Destino.", {"OK"})
        lIniVar := .F.
        Return .F.
    EndIf

    If MV_PAR12 > nNumItem
        Aviso("Atenção!", "A quantidade maxima de itens por solicitação de transferêcia não pode ser maior que [" + CValToChar(nNumItem) + "].", {"OK"})
        lIniVar := .F.
        Return .F.
    EndIf

Return .T.


/*/{Protheus.doc} ExecSTs
Rotina de execucao de solicitacao de transferencia
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 17/06/2024
@return logical, Retorno logico
/*/
Static Function ExecSTs()
    Local aCabecNNS := {}
    Local aItensNNT := {}
    Local aRet      := []
    Local cPath     := GetTempPath()
    Local cFile     := "migra_replas_" + Lower(GetNextAlias() + ".txt")
    Local cFullPath := cPath + cFile
    Local cCodUsr   := RetCodUsr()
    Local cQuery    := ""
    Local cProduto  := ""
    Local cLocOri   := ""
    Local cLocDest  := ""
    Local nCount    := 0
    Local nTotal    := 0
    Local nZ        := 0
    Local lRastroL  := .F.
    Local lRastroS  := .F.
    Local oFWriter  := Nil

    If Select("_QRY") > 0
        _QRY->(dbCloseArea())
    EndIf

    //-- Monta a query
    cQuery := GetQuery()

    cQuery := ChangeQuery(cQuery)
    dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), "_QRY")

    If _QRY->(!EoF())
        //-- Conta os registros da query
        Count To nTotal

        //-- Posiciona no primeiro registro
        _QRY->(dbGoTop())

        //-- Ambientes Unix ou Linux
        If IsSrvUnix()
            cPath     := StrTran(cPath, "\", "/")
            cFullPath := StrTran(cFullPath, "\", "/")
        EndIf

        //-- Se Arquivo existir, apaga
        If File(cFile)
            FErase(cFile)
        EndIf

        //-- Arquivo de logs
        oFWriter := FWFileWriter():new(cFullPath, .T.)

        //-- Se nao foi possivel criar o arquivo
        If !oFWriter:create()
            FWAlertError("Houve um erro ao criar o arquivo de log - " + oFWriter:error():Message, "Erro arquivo de log!")
            Return .F.
        EndIf

        //-- Inicia o texto do log
        oFWriter:write("Log iniciado, data [" + DToC(Date()) + "], hora [" + Time() + "]" + CRLF)
        oFWriter:write(Replicate("#", 100) + CRLF)
        oFWriter:write(CRLF)
        oFWriter:write("Tp. Doc. Entrada:  " + Iif(nTpDocEntr==1, "A Classificar", "Classificado") + CRLF)
        oFWriter:write("Código do Usuário: " + cCodUsr + CRLF)
        oFWriter:write("Nome do Usuário:   " + UsrRetName(cCodUsr) + CRLF)
        oFWriter:write(CRLF)
        oFWriter:write(Replicate("+", 100) + CRLF)
        oFWriter:write(CRLF)

        //-- Carrega cabecalho NNS
        aAdd(aCabecNNS, {CValToChar(nTpDocEntr)})
        aAdd(aCabecNNS, {" "})
        aAdd(aCabecNNS, {cCodUsr})
        aAdd(aCabecNNS, {UsrFullName(cCodUsr)})

        //-- Carrega itens NNT
        While _QRY->(!EoF())
            cProduto := _QRY->B1_COD
            cLocOri  := Iif(Empty(cArmOrigem), _QRY->B2_LOCAL, cArmOrigem)
            cLocDest := Iif(Empty(cArmDestin), _QRY->B2_LOCAL, cArmDestin)
            lRastroL := Rastro(cProduto, "L")
            lRastroS := Rastro(cProduto, "S")
            nCount++

            If nCount >= 10
                MsProcTxt("Carregando produto (" + CValToChar(nCount) + "). Total de produtos (" + CValToChar(nTotal) + ")...")
            EndIf

            If lRastroL
                aAdd(aItensNNT, {cEmpFilOri, cProduto, cLocOri, _QRY->B8_SALDO, _QRY->B8_LOTECTL, Nil, _QRY->B8_DTVALID, cEmpFilDes, cProduto, cLocDest, cTpSaida, cTpEntra})
            ElseIf lRastroS
                aAdd(aItensNNT, {cEmpFilOri, cProduto, cLocOri, _QRY->B8_SALDO, _QRY->B8_LOTECTL, _QRY->B8_NUMLOTE, _QRY->B8_DTVALID, cEmpFilDes, cProduto, cLocDest, cTpSaida, cTpEntra})
            Else
                aAdd(aItensNNT, {cEmpFilOri, cProduto, cLocOri, _QRY->B2_QATU, Nil, Nil, Nil, cEmpFilDes, cProduto, cLocDest, cTpSaida, cTpEntra})
            EndIf

            //-- Monta o texto da linha
            cLinha := ArrTokStr(aItensNNT[Len(aItensNNT)], ";")

            //-- Insere no arquivo
            oFWriter:write(cLinha + CRLF)

            If Len(aItensNNT) >= nLimItemPV
                //-- Chama a rotina de inclusao de ST
                aRet := U_REESTA17(aCabecNNS, aItensNNT)

                oFWriter:write(CRLF)
                For nZ := 2 To Len(aRet)
                    oFWriter:write(aRet[nZ] + CRLF)
                Next nZ

                //-- Insere separador de STs, cada separador indica que uma ST foi incluida
                oFWriter:write(CRLF)
                oFWriter:write(Replicate("+", 100) + CRLF)
                oFWriter:write(CRLF)

                aItensNNT := {}
            EndIf 

            _QRY->(dbSkip())
        EndDo
    Else
        FWAlertError("Não existem produtos para serem transferidos com os filtros pré-selecionados", "Solicitação Transferência!" )
        Return .F.
    EndIf

    If Select("_QRY") > 0
        _QRY->(dbCloseArea())
    EndIf

    If !Empty(aItensNNT)
        MsProcTxt("Carregando produto (" + CValToChar(nCount) + "). Total de produtos (" + CValToChar(nTotal) + ")...")

        //-- Chama a rotina de inclusao de ST
        aRet := U_REESTA17(aCabecNNS, aItensNNT)

        oFWriter:write(CRLF)
        For nZ := 2 To Len(aRet)
            oFWriter:write(aRet[nZ] + CRLF)
        Next nZ
    EndIf

    //-- Mostra um texto no fim do arquivo
    oFWriter:write(CRLF)
    oFWriter:write(Replicate("#", 100) + CRLF)
    oFWriter:write("Log encerrado, data [" + DToC(Date()) + "], hora [" + Time() + "]")

    //-- Encerra o arquivo
    oFWriter:close()

    //-- Se nao for via job/webservice, abre o arquivo
    If !IsBlind()
        ShellExecute("OPEN", cFile, "", cPath, 1)
    EndIf

Return .T.


/*/{Protheus.doc} GetQuery
Rotina que monta a query de busca dos saldos
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 17/06/2024
@return character, Query
/*/
Static Function GetQuery()
    Local cGetQry := ""

    cGetQry := " SELECT " + CRLF
    cGetQry += "     SB1.B1_COD, SB1.B1_DESC, SB1.B1_GRUPO, SB1.B1_XGRUPO, SB2.B2_LOCAL, " + CRLF
    cGetQry += "     SB2.B2_QATU, SB1.B1_RASTRO, SB8.B8_SALDO, SB8.B8_LOTECTL, SB8.B8_NUMLOTE, SB8.B8_DTVALID " + CRLF
    cGetQry += " FROM " + CRLF
    cGetQry += "     " + RetSQLName("SB1") + " SB1 " + CRLF
    cGetQry += " INNER JOIN " + CRLF
    cGetQry += "     " + RetSQLName("SB2") + " SB2 " + CRLF
    cGetQry += "     ON " + RetSQLCond("SB2") + CRLF
    cGetQry += "     AND SB2.B2_COD = SB1.B1_COD " + CRLF
    cGetQry += "     AND SB2.B2_QATU > 0 " + CRLF
    If !Empty(cArmOrigem)
        cGetQry += "     AND SB2.B2_LOCAL = '" + cArmOrigem + "' " + CRLF
    EndIf
    cGetQry += " LEFT JOIN " + CRLF
    cGetQry += "     " + RetSQLName("SB8") + " SB8 " + CRLF
    cGetQry += "     ON " + RetSQLCond("SB8") + CRLF
    cGetQry += "     AND SB8.B8_PRODUTO = SB2.B2_COD " + CRLF
    cGetQry += "     AND SB8.B8_LOCAL = SB2.B2_LOCAL " + CRLF
    cGetQry += "     AND SB8.B8_SALDO > 0 " + CRLF
    cGetQry += " WHERE " + CRLF
    cGetQry += "     " + RetSQLCond("SB1") + CRLF
    cGetQry += "     AND SB1.B1_COD BETWEEN '" + cProdDe + "' AND '" + cProdAte + "' " + CRLF
    cGetQry += "     AND SB1.B1_GRUPO BETWEEN '" + cGrupDe + "' AND '" + cGrupAte + "' " + CRLF
    cGetQry += "     AND SB1.B1_XGRUPO = '" + CValToChar((nGrupProd)-1) + "' " + CRLF
    If !Empty(cPVPalete) .And. !Empty(cItPalete)
        cGetQry += "     AND EXISTS (SELECT * FROM " + RetSQLName("SZH") + " SZH WHERE ZH_FILIAL = '" + GetMV("RE_FILORIG", .F., "0302") + "' AND ZH_PEDIDO = '" + cPVPalete + "' AND ZH_ITEMPV = '" + cItPalete + "' AND ZH_LOTECTL = SB8.B8_LOTECTL AND ZH_NUMLOTE = SB8.B8_NUMLOTE AND SZH.D_E_L_E_T_ = ' ') " + CRLF
    EndIf
    cGetQry += " ORDER BY SB1.B1_COD, SB2.B2_LOCAL, SB8.B8_LOTECTL, SB8.B8_NUMLOTE " + CRLF

Return cGetQry


/*/{Protheus.doc} PreVisual
Rotina que gera arquivo de pre-visualizacao
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 17/06/2024
/*/
Static Function PreVisual()
    Local aDados    := QryArray(GetQuery())
    Local cPath     := GetTempPath()
    Local cFile     := "migra_replas_" + Lower(GetNextAlias() + ".txt")
    Local cFullPath := cPath + cFile
    Local cCodUsr   := RetCodUsr()
    Local cLinha    := ""
    Local nZ        := 0
    Local nCount    := 0
    Local oFWriter  := Nil

    If Empty(aDados)
        FWAlertError("Não existem produtos para serem transferidos com os filtros pré-selecionados", "Solicitação Transferência!")
        Return .F.
    EndIf

    //-- Ambientes Unix ou Linux
    If IsSrvUnix()
        cPath     := StrTran(cPath, "\", "/")
        cFullPath := StrTran(cFullPath, "\", "/")
    EndIf

    //-- Se Arquivo existir, apaga
    If File(cFile)
        FErase(cFile)
    EndIf

    //-- Arquivo de logs
    oFWriter := FWFileWriter():new(cFullPath, .T.)

    //-- Se nao foi possível criar o arquivo, encerra o Protheus
    If !oFWriter:create()
        //Final("Houve um erro ao criar o arquivo - " + oFWriter:Error():Message)
        Return .F.
    EndIf

    //-- Inicia o texto do log
    oFWriter:write("PRÉ-VIZUALIZAÇÃO" + CRLF)
    oFWriter:write("Log iniciado, data [" + DToC(Date()) + "], hora [" + Time() + "]" + CRLF)
    oFWriter:write(Replicate("#", 100) + CRLF)
    oFWriter:write(CRLF)
    oFWriter:write("Tp. Doc. Entrada:  " + Iif(nTpDocEntr==1, "A Classificar", "Classificado") + CRLF)
    oFWriter:write("Código do Usuário: " + cCodUsr + CRLF)
    oFWriter:write("Nome do Usuário:   " + UsrRetName(cCodUsr) + CRLF)
    oFWriter:write(CRLF)
    oFWriter:write(Replicate("+", 100) + CRLF)
    oFWriter:write(CRLF)

    //Enquanto houver produtos
    For nZ := 1 To Len(aDados)
        nCount++

        //-- Monta o texto da linha
        cLinha := ArrTokStr(aDados[nZ], ";")

        //-- Insere no arquivo
        oFWriter:write(cLinha + CRLF)

        If nCount >= nLimItemPV
            nCount := 0

            //-- Insere separador de STs, cada separador indica que uma ST foi incluida
            oFWriter:write(CRLF)
            oFWriter:write(Replicate("+", 100) + CRLF)
            oFWriter:write(CRLF)
        EndIf
    Next nZ

    //Mostra um texto no fim do arquivo
    oFWriter:write(CRLF)
    oFWriter:write(Replicate("#", 100) + CRLF)
    oFWriter:write("Log encerrado, data [" + DToC(Date()) + "], hora [" + Time() + "]")

    //Encerra o arquivo
    oFWriter:close()

    //Se não for via job/webservice, abre o arquivo
    If !IsBlind()
        ShellExecute("OPEN", cFile, "", cPath, 1)
    EndIf

Return

