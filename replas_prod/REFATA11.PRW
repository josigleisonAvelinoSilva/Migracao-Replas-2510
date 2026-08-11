#include "totvs.ch"


/*/{Protheus.doc} User Function REFATA11
Tela de atualização de regra de condicao de pagamento
@type  Function
@author DO THINK - ERIKE YURI
@since 26/04/2024
@version 1.0
/*/
User Function REFATA11()
    local oDlgR
    local oLstBx1
    local oLstBx2
    Local oFont    := TFont():New("Arial", , -17, .T.)
    Local cTitulo  := "Seleção de Condições de Pagamento"
    local cPesq1   := Space(40)
    local cPesq2   := Space(40)
    local aAllCPag := {}
    local aSelCPag := {}
    local aBkpOrig := {}

    //-- Carrega condições de pagamento nos arrays, conforme parametro
    CarregarCPag(@aAllCPag, @aSelCPag)

    //-- Salva backup do itens ja selecionados
    aBkpOrig := aClone(aSelCPag)

    DEFINE MSDIALOG oDlgR TITLE "Regras de Condição de Pagamento" FROM 0,0 TO 500,800 PIXEL

    oTitulo := TSay():New(01, 05, {||cTitulo}, oDlgR, ,oFont, , , , .T., RGB(031, 073, 125), , 200, 20)
    
    @ 040, 007   LISTBOX oLstBx1 Fields HEADER "CODIGO", "DESCRIÇÃO"  SIZE 165, 200 OF oDlgR  PIXEL
    oLstBx1:SetArray( aAllCPag )
    oLstBx1:bLine   := {|| aAllCPag[oLstBx1:nAt]}
    oLstBx1:refresh()    

    @ 040, 233   LISTBOX oLstBx2 Fields HEADER "CODIGO", "DESCRIÇÃO"  SIZE 165, 200 OF oDlgR  PIXEL
    oLstBx2:SetArray( aSelCPag )
    oLstBx2:bLine   := {|| aSelCPag[oLstBx2:nAt]}
    oLstBx2:refresh()   


    @ 017, 007 SAY "Condições de Pagamento Disponíveis:"   SIZE 140, 007 OF oDlgR  PIXEL
    @ 017, 233 SAY "Condições de Pagamento Selecionadas:"  SIZE 140, 007 OF oDlgR  PIXEL

    @ 026, 007 MSGET cPesq1 SIZE 140,11 OF oDlgR PIXEL
    @ 026, 233 MSGET cPesq2 SIZE 140,11 OF oDlgR PIXEL

	@ 026, 146 BUTTON "[ ? ]"           SIZE 26, 13 OF oDlgR PIXEL ACTION ( PesqList(cPesq1, @oLstBx1) )  
    @ 026, 372 BUTTON "[ ? ]"           SIZE 26, 13 OF oDlgR PIXEL ACTION ( PesqList(cPesq2, @oLstBx2) )  

	@ 050, 175 BUTTON "Adicionar >>"    SIZE 55, 20 OF oDlgR PIXEL ACTION ( AdicionCPag(oLstBx1:nAt, @aAllCPag, @aSelCPag, @oLstBx1, @oLstBx2) )
	@ 080, 175 BUTTON "<< Remover"	    SIZE 55, 20 OF oDlgR PIXEL ACTION ( RemoverCPag(oLstBx2:nAt, @aAllCPag, @aSelCPag, @oLstBx1, @oLstBx2) )
	@ 110, 175 BUTTON "Atualizar"	    SIZE 55, 20 OF oDlgR PIXEL ACTION ( oLstBx1:refresh(), oLstBx2:refresh() )

	@ 170, 175 BUTTON "Salvar"	        SIZE 55, 20 OF oDlgR PIXEL ACTION ( If(SalvarCPag(aSelCPag, aBkpOrig), oDlgR:End(),) )
	@ 200, 175 BUTTON "Fechar"	        SIZE 55, 20 OF oDlgR PIXEL ACTION ( If(CompararArrays(aSelCPag, aBkpOrig), If(FWAlertYesNo("Deseja sair sem Salvar as alterações?", "Atenção!!!"), oDlgR:End(),), oDlgR:End() ) )

    
    ACTIVATE MSDIALOG oDlgR CENTER

Return


/*/{Protheus.doc} AdicionCPag
Adiciona condicao de pagamento na lista para salvar
@type function
@version 1.0
@author DO THINK - ERIKE YURI
@since 27/04/2024
@param nAtP, numeric, Posicao do item selecionando na lista
@param aList1, array, Lista de condicoes de pagamento
@param aList2, array, Lista de condicoes de pagamento selecionados
@param oLstBx1, object, Listbox de condicoes de pagamento
@param oLstBx2, object, Listbox de condicoes de pagamento selecionados
/*/
Static Function AdicionCPag(nAtP, aList1, aList2, oLstBx1, oLstBx2)
    local nX := 0

    If Empty(aList1) .Or. Empty(aList1[1,1])
        FWAlertError("A lista de codindicação de pagamento esta vazia.", "Condição não adicionada")	
        Return
    EndIf

    Aadd( aList2, { aList1[nAtP, 1],  aList1[nAtP, 2]} )

    For nX:=1 To Len(aList2)
        If Empty(aList2[nX, 1])
            adel(aList2, nX)
            aSize(aList2, Len(aList2) - 1)
            Exit
        EndIf
    Next nX

    adel(aList1, nAtP)

    aSize(aList1, Len(aList1) - 1)

    If Empty(aList1)
        aadd(aList1, {"", ""} )
    EndIf

    If Len(aList1) < oLstBx1:nAt
        oLstBx1:nAt := 1
    EndIf

    If Len(aList2) < oLstBx2:nAt
        oLstBx2:nAt := 1
    EndIf

    oLstBx1:SetArray( aList1 )
    oLstBx1:bLine   := {|| aList1[oLstBx1:nAt]}
    oLstBx1:refresh()  

    oLstBx2:SetArray( aList2 )
    oLstBx2:bLine   := {|| aList2[oLstBx2:nAt]}
    oLstBx2:refresh()  

Return


/*/{Protheus.doc} RemoverCPag
Remove condicao de pagamento na lista para salvar
@type function
@version 1.0
@author DO THINK - ERIKE YURI
@since 28/04/2024
@param nAtP, numeric, Posicao do item selecionando na lista
@param aList1, array, Lista de condicoes de pagamento
@param aList2, array, Lista de condicoes de pagamento selecionados
@param oLstBx1, object, Listbox de condicoes de pagamento
@param oLstBx2, object, Listbox de condicoes de pagamento selecionados
/*/
Static Function RemoverCPag(nAtP, aList1, aList2, oLstBx1, oLstBx2)
    local nX := 0

    If Empty(aList2) .Or. Empty(aList2[1,1])
        FWAlertError("A lista de codindicação de pagamento esta vazia.", "Condição não removida")	
        Return
    EndIf

    Aadd( aList1, { aList2[nAtP, 1],  aList2[nAtP, 2]} )

    For nX:=1 To Len(aList1)
        If Empty(aList1[nX, 1])
            adel(aList1, nX)
            aSize(aList1, Len(aList1) - 1)
            Exit
        EndIf
    Next nX

    adel(aList2, nAtP)

    aSize(aList2, Len(aList2) - 1)

    If Empty(aList2)
        aadd(aList2, {"", ""} )
    EndIf

    oLstBx1:SetArray( aList1 )
    oLstBx1:bLine   := {|| aList1[oLstBx1:nAt]}
    oLstBx1:refresh()  

    oLstBx2:SetArray( aList2 )
    oLstBx2:bLine   := {|| aList2[oLstBx2:nAt]}
    oLstBx2:refresh()  

Return


/*/{Protheus.doc} PesqList
Pesquisa condicao de pagamento na lista de objeto
@type function
@version 1.0
@author DO THINK - ERIKE YURI
@since 5/04/2024
@param cProcura, character, Texto a ser pesquisado
@param oLista, object, Lista que será pesquisada
/*/
Static Function PesqList(cProcura, oLista)
    local nAt := 0

    If Empty(cProcura)
        Return
    EndIf

    nAt := AsCan( oLista:aARRAY, {|e| AllTrim(e[1]) == AllTrim(cProcura) } )

    If Empty(nAt)
        FWAlertInfo("Condição de Pagamento não Localizada","Atenção") 
        Return
    EndIf

    oLista:nAt := nAt
Return


/*/{Protheus.doc} SalvarCPag
Rotina que grava o conteudo do segundo ListBox, informando no campo especifico se a condicao de pagamento esta selecionada como liberada
@type function
@version 1.0
@author DO THINK - ERIKE YURI
@since 27/04/2024
@param aBrw2, array, Array que sera salva
@param aBkpOrig, array, Backup do Array original para verificar se teve alteracao
@return logical, Se gravar retornará .T. caso contrario e retornará .F.
/*/
Static Function SalvarCPag(aBrw2, aBkpOrig)
    Local aAreaAnt := GetArea()
    Local aAreaSE4 := SE4->(GetArea())
    Local cCodigos := ""
    Local nI       := 0
    Local lRet     := .T.
    
    //-- Se for igual nao grava
    If !CompararArrays(aBrw2, aBkpOrig)
        FWAlertInfo("Não será gravado, pois não teve alteração","Atenção") 
        Return .F.
    EndIf

    For nI := 1 To Len(aBrw2)
        cCodigos += AllTrim( aBrw2[nI,1] ) + ";"
    Next nI

    cCodigos := SubStr(cCodigos, 1, Len(cCodigos)-1)

    //-- Restaura todas as condicoes de pagamento
    cUpdate := " UPDATE " + RetSqlName("SE4") + " SET E4_XREGCPG = '2' WHERE E4_FILIAL = '" + xFilial("SE4") + "' AND E4_XREGCPG = '1' AND D_E_L_E_T_ = '' "	
    TcSqlExec(cUpdate)

    //-- Salva as novas condicoes de pagamento
    cUpdate := " UPDATE " + RetSqlName("SE4") + " SET E4_XREGCPG = '1' WHERE E4_FILIAL = '" + xFilial("SE4") + "' AND E4_CODIGO IN " + FormatIn(cCodigos, ";") +" AND D_E_L_E_T_ = '' "	
    TcSqlExec(cUpdate)

    FWAlertSuccess("Condições de pagamento salvas com sucesso!")

    RestArea(aAreaSE4)
    RestArea(aAreaAnt)

Return lRet


/*/{Protheus.doc} CarregarCPag
Rotina que carrega as condicoes de pagamento
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 23/05/2024
@param aAllCPag, array, Array com todas as condicoes
@param aSelCPag, array, Array com todas as condicoes selecionadas
/*/
Static Function CarregarCPag(aAllCPag, aSelCPag)
    Local aArea  := GetArea()
    Local cDescr := ""

    DbSelectArea("SE4")
    SE4->( DbSetOrder(1) )
    
    SE4->( DbSeek( xFilial() ) )

    While SE4->( !Eof() .And. E4_FILIAL == xFilial() )

        If Len( AllTrim( SE4->E4_COND ) ) > 10
            cDescr := SE4->E4_COND
        Else
            cDescr := SE4->E4_DESCRI
        EndIf 

        If SE4->E4_XREGCPG == "1"
            aadd(aSelCPag, {SE4->E4_CODIGO, cDescr } )
        Else
            aadd(aAllCPag, {SE4->E4_CODIGO, cDescr } )
        EndIf

        SE4->( DbSkip() )
    EndDo

    If Empty(aSelCPag)
        aadd(aSelCPag, {"", "" } )
    EndIf

    If Empty(aAllCPag)
        aadd(aAllCPag, {"", "" } )
    EndIf    

    RestArea(aArea)

Return


/*/{Protheus.doc} CompararArrays
Compara 2 arrays, para alertar usuário. Só compara a primeira coluna
@type function
@version 1.0
@author DO THINK - ERIKE YURI
@since 27/04/2024
@param aArray1, array, Primeiro array para comparacao
@param aArray2, array, Segundo array para comparacao
@return logical, variável lógica que indica se existe diferença entre os arrays. Inicialmente, é definida como .F. (falso).
/*/
Static Function CompararArrays(aArray1, aArray2)
    Local lDiferente := .F.
    Local nTamanho := 0
    Local nI := 0
    
    // Verifica se os arrays têm tamanhos diferentes
    If Len(aArray1) != Len(aArray2)
        lDiferente := .T.
    Else
        nTamanho := Len(aArray1)
        
        // Percorre os arrays comparando cada elemento
        For nI := 1 To nTamanho
            If aArray1[nI,1] != aArray2[nI,1]
                lDiferente := .T.
                Exit
            EndIf
        Next
    EndIf
    
Return lDiferente


/*/{Protheus.doc} RFATA11B
Rotina que indica se a condicao de pagamento esta contida selecionada como liberada
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 23/05/2024
@param cCondPag, character, Codigo da condicao de pagamento
@return logical, Indica se a condicao de pagamento foi selecionada
/*/
User Function RFATA11B(cCondPag)
Return GetAdvFVal("SE4", "E4_XREGCPG", xFilial("SE4") + cCondPag, 1, "") == "1"
