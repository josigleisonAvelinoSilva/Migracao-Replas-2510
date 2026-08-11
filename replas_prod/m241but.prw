#include "totvs.ch"

/*/{Protheus.doc} M241BUT
Ponte de Entrada de inclusao de botoes em Movimentos Internos Modelo II
@type function
@version 1.0
@author erike
@since 09/06/2022
@obs Ojetivo e incluir facilitador para que o Silvio possa importar planilha de ajuste
/*/
User Function M241BUT()
    local aButtons := {}

    aAdd( aButtons, { "BOTAO1", {|| u_regcsv01() }, "Importar CSV" } )  
Return(aButtons)


/*/{Protheus.doc} regcsv01
Funcao que faz a importacao de planilha csv para a tela de  Movimentos Internos Modelo II
@type function
@version  1.0
@author erike
@since 09/06/2022
@obs Devera ter como atencao as colunas obrigatorias do arquivo CSV, alem disso o campo de quantidade so podera ter virgulas para decimais e nao podera ter ponto
/*/
user function regcsv01()

    local aArea     := GetArea()
    local aParamBox := {}
    local cFile     := Space(100)

    If Empty(cTM)
        Alert("Informe primeiro o tipo de movimentação", "Vazio.")
        Return
    EndIf

    aAdd(aParamBox, {6, "Buscar arquivo"    , cFile, "", ""          ,""       , 100, .T., "Arquivos (*.csv) |*.csv"})

    If !ParamBox(aParamBox, "Importa Mov.Interno via Planilha CSV")   
        Return
    EndIf

    cFile := AllTrim(MV_PAR01)

    If !File(cFile)
        Alert("Aquivo [" + cFile + "] não localizado!", "Arquivo")
        return
    EndIf

    FwMsgRun(NIL, {|oSay| lecsv(oSay, cFile)}, "Processando", "Iniciando o processamento...")

    RestArea(aArea)
return


static function lecsv(oSay, cFile)
    local nTotal    := 0
    local nAtual    := 0
    local nCount    := 0
    local cBkpRdVar := __READVAR 
    local cErro     := ""
    local cLinha    := ""
    local cProduto  := ""
    local cLocal    := ""
    local nQtd      := 0
    local nCusto1   := 0
    local cLoteCTL  := ""
    local cNumLote  := ""
    local lFirst    := .T.
    local aCab      := {"PRODUTO", "LOCAL", "QUANTIDADE", "CUSTO"}
    local aLinha    := {}
    local nLenCab   := Len(aCab)
    local nX        := 0
    local nTProduto := TamSx3("D3_COD")[1]
    local nTLocal   := TamSx3("D3_LOCAL")[1]
    local nTLoteCTL := TamSx3("D3_LOTECTL")[1]
    local nTNumLote := TamSx3("D3_NUMLOTE")[1]
    local nLinCols  := Len(aCols)
    local nUsado    := Len(aHeader)

    FT_FUSE(cFile)
    nTotal := FT_FLASTREC()

    //MsgInfo("O arquivo selecionado possui um total de [" + CValToChar(nTotal) + "] linhas contando com o cabeçalho.", "SOMENTE INFORMATIVO!")

    if nTotal > 100 .and. !MsgYesNo("O arquivo possui mais de " + CValToChar(nTotal) +  " linhas,e talvez a rotina de Mov.Interna não suporte." + chr(13) + chr(10) + "Deseja continuar?", "Atenção")
        FT_FUSE()
        Alert("Cancelado pelo operador")
        return
    endif
    
    //-- Marca como deletado a ultima linha que não tem conteudo
    If nLinCols > 0 .and. Empty(aCols[nLinCols, nPosCod]) 
        aCols[nLinCols, Len(aHeader) + 1 ] := .T.
    EndIf

    FT_FGOTOP()
    
    While !FT_FEOF()
        //-- Trata mensagens de processamento
        nAtual++
        nCount++
        oSay:SetText("Analisando registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")
        If nCount > 10
            ProcessMessage()
            nCount := 0
        EndIf

        //-- Leitura de linha
        cLinha := LeLinha()

        //-- Nao processa linha vazia
        If Empty(cLinha)
            FT_FSKIP()
            Loop
        EndIf

        //-- Nao processa csv sem conteudo 
        If (!lFirst .and. cLinha == Replicate(";", nLenCab - 1))
            FT_FSKIP()
            Loop
        EndIf

        //-- Trata linha lida
        aLinha := strtokarr(cLinha, ";")

        If lFirst
            //-- Valida cabecalho
            //-- Nao me preocupe se a linha possui mais informações, porém garanto que as colunas do cabeçalho estejam corretas
            For nX:=1 To Len(aCab)
                If aCab[nX] != Upper(aLinha[nX])
                    FT_FUSE()
                    cErro := 'Cabeçalho do arquivo, deverá conter as seguintes colunas separadas por ";" :'+ CRLF
                    aEval(aCab, {|x| cErro += x + CRLF})
                    Alert(cErro)    
                    return
                EndIf
            Next nX

            lFirst := .F.            
        Else
            If Len(aLinha) < 3
                cErro := "Existe menos colunas informadas"
            EndIf

            If Empty(cErro) .and. ( Empty( aLinha[1] ) .or. Empty( aLinha[2] ) )
                cErro := "O PRODUTO ou LOCAL esta vazio"
            EndIf

            If Empty(cErro)
                cProduto  := PadR(aLinha[1], nTProduto)
                cLocal    := PadR(aLinha[2], nTLocal)
                nQtd      := TrataVal(aLinha[3])
                nCusto1   := TrataVal(aLinha[4])
                cLoteCTL  := PadR(aLinha[5], nTLoteCTL)
                cNumLote  := PadR(aLinha[6], nTNumLote)
            EndIf

            If Empty(cErro) .and. !ExistCpo("SB1", cProduto)
                cErro := "PRODUTO nao cadastrado"
            EndIf

            If Empty(cErro) .and. !ExistCpo("NNR", cLocal)
                cErro := "LOCAL nao cadastrado"
            EndIf

            If Empty(cErro)
                //Faz a montagem de uma linha do aCols.
                aadd(aCols, Array(nUsado + 1))
                nLinCols  := Len(aCols)
                N         := nLinCols

                For nX := 1 To nUsado
                        If AllTrim(aHeader[nX][2]) == "D3_ALI_WT"
                            aCols[nLinCols][nX] := "SD3"
                        ElseIf AllTrim(aHeader[nX][2]) == "D3_REC_WT"
                            aCols[nLinCols][nX] := 0
                        Else
                            aCols[nLinCols][nX] := CriaVar( aHeader[nX][2] )
                        EndIf
                Next nX

                For nX := 1 To nUsado
                    If Trim(aHeader[nX][2]) == "D3_COD"
                        aCols[nLinCols][nX] 	:= cProduto
                        If !vldcampo(nLinCols, 'D3_COD', cProduto)
                            cErro := "Erro na validacao do D3_COD"
                        EndIf
                        If GDFieldGet("D3_LOCAL", N, .F. , aHeader, aCols) != cLocal
                            aCols[nLinCols][GdFieldPos("D3_LOCAL")] := cLocal
                            If !vldcampo(nLinCols, 'D3_LOCAL', cLocal)
                                cErro := "Erro na validacao do D3_LOCAL"
                            EndIf
                        EndIf
                    ElseIf Trim(aHeader[nX][2]) == "D3_LOCAL"
                        aCols[nLinCols][nX] 	:= cLocal
                        If !vldcampo(nLinCols, 'D3_LOCAL', cLocal)
                            cErro := "Erro na validacao do D3_LOCAL"
                        EndIf                        
                    ElseIf Trim(aHeader[nX][2]) == "D3_QUANT"
                        aCols[nLinCols][nX] 	:= nQtd       
                        If !vldcampo(nLinCols, 'D3_QUANT', nQtd)
                            cErro := "Erro na validacao do D3_QUANT"
                        EndIf               
                    ElseIf Trim(aHeader[nX][2]) == "D3_CUSTO1"
                        aCols[nLinCols][nX] 	:= nCusto1       
                        If !vldcampo(nLinCols, 'D3_CUSTO1', nCusto1)
                            cErro := "Erro na validacao do D3_CUSTO1"
                        EndIf   
                    ElseIf Trim(aHeader[nX][2]) == "D3_LOTECTL"
                        aCols[nLinCols][nX] 	:= cLoteCTL       
                        If !vldcampo(nLinCols, 'D3_LOTECTL', cLoteCTL)
                            cErro := "Erro na validacao do D3_LOTECTL"
                        EndIf       
                    ElseIf Trim(aHeader[nX][2]) == "D3_NUMLOTE"
                        aCols[nLinCols][nX] 	:= cNumLote       
                        If !vldcampo(nLinCols, 'D3_NUMLOTE', cNumLote)
                            cErro := "Erro na validacao do D3_NUMLOTE"
                        EndIf                            
                    EndIf                
                Next nX
                aCols[nLinCols][nUsado + 1] := .F.

                If !A241LinOk(nil, nLinCols)
                    cErro := "Erro validação A241LinOk"
                    aCols[nLinCols][nUsado + 1] := .T.
                EndIf

            EndIf
        Endif

        If !Empty(cErro)
            Alert("Na linha " + cValToChar(nAtual) + " do arquivo." + CRLF + cErro + "! Operacao foi cancelada")
            exit
        EndIf

        FT_FSKIP()
    End
    FT_FUSE()
    
    If Type("oGet") == "O"
        //-- Forca atualizacao da GetDados
        oGet:Refresh()
    EndIf
    
    __READVAR := cBkpRdVar
return



/*/{Protheus.doc} LeLinha
Tratamento de leitura de linha TXT, principalmente para casos de ultrapassar 1Kb por linha 
@type function
@version 1.0  
@author erike
@since 10/06/2022
@return variant, Linha posicionada no arquivo csv
/*/
Static Function LeLinha()
    
    local cRetLinha := ""
    local cLinhaTmp := ""
    local cLinProx  := ""
    local cLinAnt   := ""
    local cByte     := ""    

    cLinhaTmp := FT_FReadLN()

    If !Empty(cLinhaTmp)
        cByte := Substr(cLinhaTmp, 1, 1)
        If Len(cLinhaTmp) < 1023
            cRetLinha := cLinhaTmp
        Else
            cLinAnt     := cLinhaTmp
            cRetLinha   += cLinAnt
            FT_FSkip()
            cLinProx := FT_FReadLN()
            If Len(cLinProx) >= 1023 .and. Substr(cLinProx, 1, 1) <> cByte
                While !Ft_fEof() .and. Len(cLinProx) >= 1023 .and. Substr(cLinProx, 1, 1) <> cByte
                    cRetLinha += cLinProx
                    FT_FSkip()
                    cLinProx := FT_FReadLn()
                    If Len(cLinProx) < 1023 .and. Substr(cLinProx, 1, 1) <> cByte
                        cRetLinha += cLinProx
                    Endif
                Enddo
            Else
                cRetLinha += cLinProx
            Endif
        Endif
    Endif

Return cRetLinha

/*/{Protheus.doc} TrataVal
Trata valores com virgula
@type function
@version 1.0  
@author dothink
@since 07/06/2022
@param cVal, character, Valor com virgula
@return numeric, Retorna novo valor numerico
/*/
Static Function TrataVal(cVal)
    Local nVal := 0

    cVal := StrTran(cVal, ",", ".")
    nVal := Val(cVal)

Return nVal


/*/{Protheus.doc} vldcampo
Valida entrada de dado como se fosse uma digitacao
@type function
@version 1.0
@author erike
@since 10/06/2022
@param nLinCols, numeric, Linha Posicionada
@param cNCampo, character, Nome do Campo
@param cConteudo, character, Conteudo que sera gravado
@return variant, Logico indicando se teve erro (.F.) ou sucess (.T.) na validacao
/*/
static function vldcampo(nLinCols, cNCampo, cConteudo)
    local lRet := .T.

    __ReadVar       := cNCampo
    M->&(cNCampo)   := cConteudo

    If cNCampo == "D3_COD"
        A240IniCpo()
    Else
        lRet := ( CheckSx3(cNCampo) .and. VldUser(cNCampo) )
    EndIf

    If ExistTrigger(cNCampo) 
        RunTrigger(2, nLinCols, nil, , cNCampo)
    EndIf

return lRet
