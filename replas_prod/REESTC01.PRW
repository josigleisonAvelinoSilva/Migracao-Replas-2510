#INCLUDE "TOTVS.CH"

#define _cFimLinha CHR(13) + CHR(10)

/*/{Protheus.doc} REESTC01
Consulta do Plano de Corte
@type function
@version 12.1.2310
@author DOTHINK - Erike Yuri
@since 30/10/2024
@obs Rotina funcionará tanto para consulta quanto para impressao
/*/
User Function REESTC01()
    Local aArea    := GetArea()
    Local cHtml    := ""
    Local cIdPlano := ""

    
    If Pergunte("REESTC01", .T.)
        cIdPlano := MV_PAR01

        If Empty(cIdPlano)
            FWAlertWarning("Favor informar o Plano de Corte!", "Plano de Corte Inválido")
        Else
            cHtml := GeraHtml( cIdPlano )
        EndIf

        

        If !Empty( cHtml )
            ViewHTML( cHtml )
        EndIf

    EndIf
     
    RestArea(aArea)
Return
 
 
/*/{Protheus.doc} HTML
Visualizacao do HTML (local)
@type function
@version 12.1.2310
@author DOTHINK - Erike Yuri
@since 30/10/2024
/*/
Static Function ViewHTML(cHtml)
    Local nPort       := 0
    Local aSize       := MsAdvSize()
    Local oModalView
    Local oWebEngine 

    Private oWebChannel := TWebChannel():New()
 
    oModalView := MSDialog():New(aSize[7], 0, aSize[6], aSize[5], "Consulta Plano de Corte", , , , , , , , , .T.)
 
        //--Prepara o conector
        nPort := oWebChannel::connect()

        //-- Cria o componente que irá carregar html
        oWebEngine := TWebEngine():New(oModalView, 0, 0, 100, 100, , nPort)
        oWebEngine:SetHtml( cHtml )
        oWebEngine:Align := CONTROL_ALIGN_ALLCLIENT

    oModalView:Activate()
Return

Static Function GeraHtml(cIdPlano)
    local cDtHoraPlano := ""
    local cHtml        := ""
    local cLinhas      := ""
    local nI           := 0
    local nTamMax      := 0
    local aBobinas     := {}
    local aTamBob      := {}
    local aResumo      := {0, 0, 0, 0, 0, 0}
    local cFile        := GetMv("RE_FMODPLA", .F., "modelo-view-plano.html")
    Private aCores     := {"#add8e6", "#90ee90", "#ffb6c1", "#ffa07a", "#ffe4b5", "#dda0dd", "#afeeee", "#f0e68c", "#f08080", "#e6e6fa", "#98fb98", "#ffdab9", "#bc8f8f", "#87cefa", "#ffd700", "#ff69b4", "#8fbc8f", "#ba55d3", "#cd853f", "#7b68ee", "#20b2aa", "#ff7f50", "#9370db", "#3cb371", "#f4a460", "#6a5acd", "#00ced1", "#ff4500", "#32cd32", "#db7093"}
    Private aCorUso    := {}

    If !File(cFile)
        FWAlertError("Arquivo de modelo de visualização da consulta de Plano de Corte não foi localizado! Favor notificar o administrador do sistema.", "Modelo: Não localizado")
        Return cHtml
    EndIf

    cHtml := MemoRead(cFile)

    If Empty(cHtml)
        FWAlertError("Arquivo de modelo de visualização da consulta de Plano de Corte pode estar sem conteúdo! Favor notificar o administrador do sistema.", "Modelo: Sem conteúdo")
        Return cHtml
    EndIf

    aBobinas := GetBobinas(@cIdPlano, @cDtHoraPlano, @nTamMax, @aResumo, @aTamBob)

    cHtml := StrTran(cHtml, "<!--ID-PLANO-->"       , cIdPlano     )
    cHtml := StrTran(cHtml, "<!--GERACAO-PLANO-->"  , cDtHoraPlano )

    cHtml := GeraResumo( cHtml, aResumo )
    cHtml := GeraEstNec( cHtml, aTamBob )

    For nI:=1 To Len(aBobinas)
       cLinhas += GerarLinhaRelatorio(aBobinas[nI, 1], aBobinas[nI, 2], aBobinas[nI, 3], aBobinas[nI, 4], aBobinas[nI, 5], nTamMax)
    Next nI

    cHtml := StrTran(cHtml, "<!--LINHA-AQUI-->", cLinhas)


Return cHtml



Static Function GetBobinas(cIdPlano, cDtHoraPlano, nTamMax, aResumo, aTamBob)
    local cQuery    := ""
    local cChave    := ""
    local nI        := 0
    local nResto    := 0
    local nPTamBob  := 0
    local aBobinas  := {}

    DbSelectArea("ZZE")
    ZZE->( DbSeek(xFilial() + cIdPlano) )
    
    cIdPlano        := AllTrim(ZZE->ZZE_COD) + " - " + AllTrim(ZZE->ZZE_DESC) 
    cDtHoraPlano    := DTOC(ZZE->ZZE_DATA )  + " - " + ZZE->ZZE_HORA

    cQuery := "SELECT * "
    cQuery += "FROM " + RetSQLName("ZZH") + ""
    cQuery += "WHERE ZZH_FILIAL = '" + xFilial("ZZH") + "'"
    cQuery += "AND ZZH_COD = '" + ZZE->ZZE_COD + "'"
    cQuery += "AND D_E_L_E_T_ = ' '"
    cQuery += "ORDER BY ZZH_FILIAL, ZZH_COD, ZZH_LAYOUT, ZZH_ITCORT"

    cQuery := ChangeQuery(cQuery)

    //-- Executa query
    cAliasQry := MPSysOpenQuery(cQuery)

    While (cAliasQry)->( !Eof() )
        
        aResumo[6] +=   (cAliasQry)->ZZH_QTDCORT //-- Número total de cortes

        If cChave <> (cAliasQry)->ZZH_LAYOUT
            cChave := (cAliasQry)->ZZH_LAYOUT

            aResumo[3] +=  (cAliasQry)->(ZZH_LARGEST * ZZH_REPET) //-- Comprimento total dos estoques usados (Rendimento)
            aResumo[5]++    //-- Total de Layouts de corte
            

            (cAliasQry)->( Aadd(aBobinas, {ZZH_LAYOUT, ZZH_LARGES, ZZH_REPET, {}, ZZH_LARGES} ) )

            If nTamMax < (cAliasQry)->ZZH_LARGES
                nTamMax := (cAliasQry)->ZZH_LARGES
            EndIf

            If Empty(aTamBob)
                nPTamBob := 0
            Else 
                nPTamBob := Ascan(aTamBob, {|x| x[1] == (cAliasQry)->ZZH_LARGES })
            EndIf

            //-- Informacoes de bobina
            If Empty(nPTamBob)
                Aadd(aTamBob, { (cAliasQry)->ZZH_LARGES, 1} )
            Else
                aTamBob[nPTamBob, 2]++
            EndIf

        EndIf

        For nI:=1 To (cAliasQry)->ZZH_QTDCOR
            aadd(aBobinas[Len(aBobinas), 4 ], { (cAliasQry)->ZZH_LARGCO, AllTrim( (cAliasQry)->ZZH_LABEL ) })
            aBobinas[Len(aBobinas), 5 ] -= (cAliasQry)->ZZH_LARGCO
            aResumo[2]++
        Next nI


        (cAliasQry)->( DbSkip() )
    End

    (cAliasQry)->( DbCloseArea() )

    //-- Calcula Comprimento total das peças (Quantidade)
    For nI:=1 To Len(aBobinas)
        nResto += ( aBobinas[nI, 2 ] - aBobinas[nI, 5 ] ) * aBobinas[nI, 3 ]
    Next nI

    aResumo[1] := aResumo[3] - nResto 
    aResumo[1] := aResumo[3] - aResumo[1] //-- Comprimento total das peças (Quantidade)

Return aBobinas



/*/{Protheus.doc} GerarLinhaRelatorio
Gera uma linha do relatório de corte de bobinas em formato HTML
@type function
@param cId, character, ID de execução
@param nTamanho, numeric, Tamanho da bobina mãe
@param nQuantidade, numeric, Quantidade de bobinas
@param aBobinas, array, Array com os tamanhos dos cortes
@param nResto, numeric, Tamanho do resto
@return character, cLinha = Linha HTML gerada
@author DOTHINK - ERIKE YURI
@since 30/10/2024
/*/
Static Function GerarLinhaRelatorio(cId, nTamanho, nQuantidade, aBobinas, nResto, nTamMax)
    Local cLinha   := ""
    Local cCor     := ""
    Local cAgluCor := ""
    Local nI       := 0
    Local nAt      := 0
    
    cLinha += '<div class="row">' + _cFimLinha
    cLinha += '<div class="execution-id">'  + AllTrim(cId)              + '</div>'  + _cFimLinha
    cLinha += '<div class="bobina-size">'   + cValToChar(nTamanho)      + '</div>'  + _cFimLinha
    cLinha += '<div class="row-label">'     + cValToChar(nQuantidade)   + 'x</div>' + _cFimLinha
    cLinha += '<div class="remainder">'     + cValToChar(nResto)        + '</div>'  + _cFimLinha
    
    For nI := 1 To Len(aBobinas)

        If MV_PAR02 == 2 
            cAgluCor := aBobinas[nI, 2]
        Else
            cAgluCor := aBobinas[nI, 1]
        EndIf

        
        nAt := Ascan(aCorUso, { |x| x[1] == cAgluCor } )
        
        If nAt > 0
            cCor := aCorUso[nAt, 2]        
        Else
            cCor := aCores[1]
            aadd(aCorUso, {cAgluCor, cCor})

            aDel(aCores, 1)
            aSize(aCores, Len(aCores) - 1 )
        EndIf

        cLinha += '<div class="cell" style="flex: ' + cValToChar(aBobinas[nI, 1] / nTamanho)    + '; background-color: ' + cCor + ';">' + _cFimLinha
        cLinha += '  <span class="cell-size">'      + cValToChar(aBobinas[nI, 1])               + '</span>' + _cFimLinha
        cLinha += '  <span class="cell-client">'    + If(MV_PAR03 == 1, aBobinas[nI,2], "")     + '</span>' + _cFimLinha
        cLinha += '</div>' + _cFimLinha
    
    Next nI
    
    If nResto > 0
        cLinha += '<div class="cell" style="flex: ' + cValToChar(nResto/nTamanho) + '; background-color: #000000;"></div>' + _cFimLinha
    EndIf
    
    cLinha += '</div>' + _cFimLinha
    
Return cLinha


Static Function GeraResumo( cHtml, aResumo )
    local cCompTotal := AllTrim( TRANSFORM(aResumo[1], "@E 999,999,999") ) + " (" + cValToChar(aResumo[2] ) + ")"
    local cCompRend  := AllTrim( TRANSFORM(aResumo[3], "@E 999,999,999") )
    
    aResumo[4] := (aResumo[1] / aResumo[3]) * 100

    cCompRend += " (" + AllTrim( TRANSFORM(aResumo[4], "@E 999.99") ) + "%)"

    cHtml := StrTran(cHtml, "<!--COMPRIMENTO-TOTAL-->"      , cCompTotal                ) //-- Comprimento total das peças (Quantidade)
    cHtml := StrTran(cHtml, "<!--COMPRIMENTO-RENDIMENTO-->" , cCompRend                 ) //-- Comprimento total dos estoques usados (Rendimento)
    cHtml := StrTran(cHtml, "<!--TOTAL-LAYOUTS-CORTES-->"   , cValToChar( aResumo[5] )  ) //-- Total de layouts de corte
    cHtml := StrTran(cHtml, "<!--NUM-TOTAL-CORTES-->"       , cValToChar( aResumo[6] )  ) //-- Número total de cortes

Return cHtml

Static Function GeraEstNec(cHtml, aTamBob)
    local nI
    local nTotal   := 0
    local cHtmlTmp := ""
    local cValComp := ""
    local cValQtd  := ""

//    For nI:=1 To 10 
//        Aadd(aTamBob, {10*nI,1*nI})
//    Next nI

    For nI:=1 To Len(aTamBob)
        
        cValComp:= AllTrim( TRANSFORM(aTamBob[nI, 1], "@E 999,999,999") )
        cValQtd := AllTrim( TRANSFORM(aTamBob[nI, 2], "@E 999,999,999") )

        cHtmlTmp+= "<tr><td>" + cValComp + "</td><td>" + cValQtd + "</td></tr>"

        nTotal  += aTamBob[nI, 2]

    Next nI

    If Empty(aTamBob)
        cHtmlTmp += "<tr><td></td><td></td></tr>"
    EndIf

    cHtmlTmp += "<tr><td><strong>Total</strong></td><td><strong>" + cValToChar(nTotal) + "</strong></td></tr>"

    cHtml := StrTran(cHtml, "<!--ITENS-COMPRIMENTO-ESTOQUE-->", cHtmlTmp )
    
Return cHtml
