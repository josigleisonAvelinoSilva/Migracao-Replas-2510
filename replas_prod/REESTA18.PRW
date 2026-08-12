#include "totvs.ch"
#include "topconn.ch"
#include "apvt100.ch"


/*/{Protheus.doc} REESTA18
Rotina para inclusao de solicitacao de transferencia via coletor de dados
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 17/02/2025
/*/
User Function REESTA18()
    Local aAreaAnt  := GetArea()
    Local aKey      := Array(2)
    Local cNumST    := ""
    Local cMsg      := ""

    Private aItensST  := {}
    Private cCodBarra := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) ) //Space(75)
    Private cFOrig    := FWCodFil() //Space(Len(NNT->NNT_FILORI))
    Private cFDest    := Space(Len(NNT->NNT_FILDES))
    Private cAOrig    := "01"
    Private cADest    := Space(Len(NNT->NNT_LOCLD))
    Private cTSaida   := Space(Len(NNT->NNT_TS))
    Private cTEntrada := Space(Len(NNT->NNT_TE))
    Private cFilOrig  := GetMV("RE_FILORIG", .F., "0302")
    Private cFilDest  := GetMV("RE_FILDEST", .F., "0201")
    Private cFilGalp  := GetMV("RE_FILARM", .F., "0303")

    aKey[01] := VTSetKey(18, {|| Registros()}, "Registros") //-- CTRL + R - Registros
    akey[02] := VTSetKey(24, {|| Exclui()}, "Exclui Reg.") //-- CTRL + X - Exclui registro

    While .T.
        If VTLastKey() == 27 .And. !Empty(aItensST)
            If VTYesNo("Deseja finalizar a inclusao de ST?", "ATENCAO")
                If Type("INCLUI") == "U"
                    INCLUI := .T.
                EndIf

                If U_REESTA04(aItensST, @cNumST, @cMsg)
                    VTBeep(2)
                    VTAlert("ST [" + cNumST + "] incluida com sucesso!", "ATENCAO", .T., 5000)
                Else
                    VTBeep(2)
                    VTAlert("Erro ao incluir ST!", "ATENCAO", .T., 3000)
                EndIf
                Exit
            ElseIf VTYesNo("Deseja sair?", "ATENCAO")
                Exit
            Else
                Loop
            EndIf
        EndIf

        If VTLastKey() == 27 .And. Empty(aItensST)
            Exit
        EndIf

        VTClear()                        
        @ 0,0 VTSay PadC("*SOLICIT. TRANSF.*", VTMaxCol())
        @ 2,0 VTSay "Filial Origem"
        @ 3,0 VTGet cFOrig  Pict "@!" Valid VldFil("O", cFOrig) F3 "SM0" When .F.
        @ 4,0 VTSay "Filial Destino"
        @ 5,0 VTGet cFDest  Pict "@!" Valid VldFil("D", cFDest) F3 "SM0"
        VTRead

        If VTLastKey() == 27 .And. Empty(aItensST)
            Loop
        EndIf

        VTClear()                        
        @ 0,0 VTSay PadC("*SOLICIT. TRANSF.*", VTMaxCol())
        @ 2,0 VTSay "Arm. Origem"
        @ 3,0 VTGet cAOrig  Pict "@!" Valid VldArm("O", cAOrig) F3 "NNR" When VTLastKey() == 5
        @ 4,0 VTSay "Arm. Destino"
        @ 5,0 VTGet cADest  Pict "@!" Valid VldArm("D", cADest) F3 "NNR"
        VTRead

        If VTLastKey() == 27 .And. Empty(aItensST)
            Loop
        EndIf

        VTClear()                        
        @ 0,0 VTSay PadC("*SOLICIT. TRANSF.*", VTMaxCol())
        @ 2,0 VTSay "TES Saida"
        @ 3,0 VTGet cTSaida  Pict "@!" Valid VldTES("S") F3 "SF4"
        @ 4,0 VTSay "TES Entrada"
        @ 5,0 VTGet cTEntrada  Pict "@!" Valid VldTES("E") F3 "NNTSF4"
        VTRead

        If VTLastKey() == 27 .And. Empty(aItensST)
            Loop
        EndIf

        While .T. .And. !Empty(cFOrig) .And. !Empty(cFDest) .And. !Empty(cAOrig) .And. !Empty(cADest) .And. !Empty(cTSaida) .And. !Empty(cTEntrada)
            cCodBarra := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) ) // Space(75)

            VTClear()
            @ 0,0 VTSay PadC("*SOLICIT. TRANSF.*", VTMaxCol())
            @ 2,0 VTSay "Leia Etiqueta"
            @ 3,0 VTGet cCodBarra  Pict "@!" Valid VldCodBar("1")
            VTRead

            If VtLastKey() == 27
                Exit
            EndIf
        EndDo
    EndDo

    VTSetKey(24, aKey[02])
    VTSetKey(18, aKey[01])
    
    RestArea(aAreaAnt)

Return


/*/{Protheus.doc} VldFil
Rotina de validacao da filial digitada pelo usuario
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 17/02/2025
@return logical, Retorno logico
/*/
Static Function VldFil(cOriDest, cODFil)
    Local cCodFil	:= FWCodFil()  

    If Empty(cODFil)
        Return .T.
    EndIf

    If cOriDest == "D"
        If cCodFil == cFDest
            VTBeep(2)
            VTAlert("Filial destino nao pode ser igual origem " + cCodFil + "!", "ATENCAO", .T., 3000)
            VTKeyboard(chr(20))
            Return .F.
        EndIf

        If !(cCodFil == cFilOrig) .And. !(cFDest == cFilOrig)
            VTBeep(2)
            VTAlert("Filial destino " + cFDest + " nao pemitida!", "ATENCAO", .T., 3000)
            VTKeyboard(chr(20))
            Return .F.
        EndIf
    EndIf

Return .T.


/*/{Protheus.doc} VldTES
Rotina de validacao da TES digitada pelo usuario
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 17/02/2025
@param cTipo, character, Tipo da TES
@return logical, Retorno logico
/*/
Static Function VldTES(cTipo)
    Local aAreaAnt := GetArea()
    Local aAreaSF4 := SF4->(GetArea())
    Local cTES     := ""

    If cTipo == "S"
        If Empty(cTSaida)
            Return .T.
        EndIf
    
        If cTSaida <= "500"
            VTBeep(2)
            VTAlert("TES saida deve ser maior que 500!", "ATENCAO", .T., 3000)
            VTKeyboard(chr(20))
            Return .F.
        EndIf

        cTES := cTSaida
    EndIf

    If cTipo == "E"
        If Empty(cTEntrada)
            Return .T.
        EndIf    
    
        If cTEntrada >= "501"
            VTBeep(2)
            VTAlert("TES entrada deve ser menor ou igual a 500!", "ATENCAO", .T., 3000)
            VTKeyboard(chr(20))
            Return .F.
        EndIf

        cTES := cTEntrada
    EndIf

    dbSelectArea("SF4")
    SF4->(dbSetOrder(1))
    If !SF4->(dbSeek(xFilial("SF4") + cTES))
        VTBeep(2)
        VTAlert("TES informada nao existe!", "ATENCAO", .T., 3000)
        VTKeyboard(chr(20))
        Return .F.
    EndIf

    RestArea(aAreaSF4)
    RestArea(aAreaAnt)

Return .T.


/*/{Protheus.doc} VldCodBar
Rotina de validacao do codigo de barras bipado pelo usuario
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 17/02/2025
@param cTipo, character, Tipo da operacao, sendo inclusao ou exclusao
@return logical, Retorno logico
/*/
Static Function VldCodBar(cTipo)
    Local aAreaAnt  := GetArea()
    Local aAreaSB8  := SB8->(GetArea())
    Local aEtiqueta := {}
    Local cTipId    := ""
    Local cProduto  := Space(Len(SB8->B8_PRODUTO))
    Local cLote     := Space(Len(SB8->B8_LOTECTL))
    Local cSLote    := Space(Len(SB8->B8_NUMLOTE))
    Local cQuery    := ""
    Local nQuant    := 0
    Local nPos
    Local cCodFil	:= FWCodFil() 
    

    If Empty(cCodBarra)
        Return .F.
    EndIf

	cTipId := CBRetTipo(cCodBarra)
	If !(cTipId $ "EAN8OU13-EAN14-EAN128")
        VTBeep(2)
		VTAlert("Etiqueta invalida.", "ATENCAO", .T., 3000)
		VTKeyboard(chr(20))
		Return .F.
	EndIf

    //-- ETIQUETA INNOVA
    If !("(91)" $ cCodBarra) .And. !("(92)" $ cCodBarra) .And. (Len(AllTrim(cCodBarra)) >= 36) .And. (Len(AllTrim(cCodBarra)) <= 45)
        If Select("_QRYINN") > 0
            _QRYINN->(dbCloseArea())
        EndIf

        cQuery := " SELECT SB8.B8_PRODUTO, SB8.B8_LOTECTL, SB8.B8_NUMLOTE "
        cQuery += " FROM " + RetSQLName("SB8") + " SB8 "
        cQuery += " WHERE SB8.B8_FILIAL = '" + xFilial("SB8") + "' "
        cQuery += " AND (SB8.B8_LOTECTL = '" + SubStr(cCodBarra, 1, 10) + "' OR SB8.B8_LOTEFOR = '" + SubStr(cCodBarra, 1, 10) + "') "
        cQuery += " AND SB8.D_E_L_E_T_ = ' '

        cQuery := ChangeQuery(cQuery)
        TCQUERY cQuery New Alias "_QRYINN"

        If _QRYINN->(!EoF())
            aEtiqueta := {_QRYINN->B8_PRODUTO, (Val(SubStr(cCodBarra, 20, 6))/100), _QRYINN->B8_LOTECTL, CTOD("//"), "", _QRYINN->B8_NUMLOTE}
        EndIf

        If Select("_QRYINN") > 0
            _QRYINN->(dbCloseArea())
        EndIf
    Else
        If ExistBlock("CBRETEAN")
            aEtiqueta := ExecBlock("CBRETEAN",,,{cCodBarra})
        EndIf
    EndIf

    If Empty(aEtiqueta) .Or. Empty(aEtiqueta[2])
        VTBeep(2)
        VTAlert("Etiqueta invalida, bobina nao localizada!", "ATENCAO", .T., 3000)
        VTKeyboard(chr(20))
        Return .F.
    EndIf

    cProduto := aEtiqueta[1]
    nQuant   := aEtiqueta[2]
    cLote    := aEtiqueta[3]
    cSLote   := aEtiqueta[6]

    If !CBRastro(cProduto, @cLote, @cSLote)
        VTKeyboard(chr(20))
        Return .F.
    EndIf

    If cTipo == "1"
        If Select("_QRYSLD") > 0
            _QRYSLD->(dbCloseArea())
        EndIf

        cQuery := " SELECT SB8.* "
        cQuery += " FROM " + RetSQLName("SB8") + " SB8 "
        cQuery += " WHERE SB8.B8_FILIAL = '" + xFilial("SB8") + "' "
        cQuery += " AND SB8.B8_PRODUTO = '" + cProduto + "' "
        cQuery += " AND SB8.B8_LOTECTL = '" + cLote + "' "
        cQuery += " AND SB8.B8_NUMLOTE = '" + cSLote + "' "
        cQuery += " AND SB8.D_E_L_E_T_ = ' '

        cQuery := ChangeQuery(cQuery)
        TCQUERY cQuery New Alias "_QRYSLD"

        If _QRYSLD->(!EoF())
            If Empty(_QRYSLD->B8_SALDO)
                VTBeep(2)
                VTAlert("Bobina sem saldo na " + cCodFil + "!", "ATENCAO", .T., 3000)
                VTKeyboard(chr(20))
                Return .F.
            EndIf

            If !Empty(_QRYSLD->B8_EMPENHO)
                VTBeep(2)
                VTAlert("Bobina com saldo empenhado na " + cCodFil + "!", "ATENCAO", .T., 3000)
                VTKeyboard(chr(20))
                Return .F.
            EndIf

            If QtdComp(_QRYSLD->B8_SALDO) != QtdComp(nQuant)
                If !VTYesNo("Saldo diferente, " + AllTrim(Transform(_QRYSLD->B8_SALDO, "@E 999,999.99")) + " Kg na " + cCodFil + ", deseja continuar?", "ATENCAO")
                    VTKeyboard(chr(20))  
                    Return .F.
                EndIf
            EndIf

            nPos := aScan(aItensST, {|x| x[1] + x[4] + x[5] == _QRYSLD->(B8_PRODUTO + B8_LOTECTL + B8_NUMLOTE)})
            If nPos > 0
                VTBeep(2)
                VTAlert("Bobina ja lida!", "ATENCAO", .T., 3000)
                VTKeyboard(chr(20))
                Return .F.
            EndIf
        Else
            VTBeep(2)
            VTAlert("Bobina nao existe na " + cCodFil + "!", "ATENCAO", .T., 3000)
            VTKeyboard(chr(20))
            Return .F.
        EndIf

        //-- Carrega os itens que serao incluidos na ST
        aAdd(aItensST, {_QRYSLD->B8_PRODUTO, _QRYSLD->B8_LOCAL, _QRYSLD->B8_SALDO, _QRYSLD->B8_LOTECTL, _QRYSLD->B8_NUMLOTE, _QRYSLD->B8_DTVALID, cFOrig, cFDest, cAOrig, cADest, cTSaida, cTEntrada})

        If Select("_QRYSLD") > 0
            _QRYSLD->(dbCloseArea())
        EndIf
    Else
        If VTYesNo("Confirma exclusao?", "ATENCAO")
            nPos := aScan(aItensST, {|x| x[1] + x[4] + x[5] == cProduto + cLote + cSLote})
            If nPos > 0
                aDel(aItensST, nPos)
                aSize(aItensST, Len(aItensST)-1)
            EndIf
        EndIf
    EndIf

    RestArea(aAreaSB8)
    RestArea(aAreaAnt)

Return .T.


/*/{Protheus.doc} Registros
Rotina que apresenta lista de bobinas bipadas
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 17/02/2025
/*/
Static Function Registros()
    Local aCab   := {"Produto", "Qtde", "Lote", "Sub-Lote"} 
    Local aLista := {}
    Local aSize  := {18, 07, 12, 09}
    Local aSave  := VTSave()
    Local nZ  

    For nZ := 1 To Len(aItensST)
        aAdd(aLista, {aItensST[nZ, 01], aItensST[nZ, 03], aItensST[nZ, 04], aItensST[nZ, 05]})
    Next nZ

    VTClear()
    @ 0,0 VTSay PadC("*REGISTROS*", VTMaxCol())
    VTaBrowse(2, 0, 7, 19, aCab, aLista, aSize)

    VTRestore(,,,, aSave)
    
Return


/*/{Protheus.doc} Exclui
Rotina que faz a delecao das bobinas bipadas
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 17/02/2025
/*/
Static Function Exclui()
    Local aSave := VTSave()

    cCodBarra := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) ) // Space(75)

    VTClear()
    @ 0,0 VTSay PadC("*EXCLUI REGISTRO*", VTMaxCol())
    @ 2,0 VTSay "Etiqueta"
    @ 3,0 VTGet cCodBarra  Pict "@!" Valid VldCodBar("2")
    VTRead

    VTRestore(,,,, aSave)

Return

/*/{Protheus.doc} VldArm
Valida armazem
@type function
@version 1.0  
@author dener.lemos@dothink.com.br
@since 03/05/2026
@return logical, Retorno logico
/*/
Static Function VldArm(cOriDest, cArm)

    If Empty(cArm)
        Return .F.
    EndIf	                 

    NNR->( DbSetOrder(1) )
    If !NNR->( MsSeek( xFilial("NNR") + AvKey(cArm, "NNR_CODIGO") ) )  
		VtBeep(2)
		VtAlert( "Armazem nao encontrado.", "ATENCAO", .T., 3000 )
		VTKeyboard(chr(20))
        Return .F.
    EndIf

Return .T.
