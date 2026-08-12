#INCLUDE "PROTHEUS.CH"
#INCLUDE "APVT100.CH"


/*/{Protheus.doc} REESTA13
Rotina de Recebimento Innova especifico da Replas
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 29/02/2024
/*/
User Function REESTA13()
    Local aArea     := GetArea()
    Local aAreaSZB  := SZB->(GetArea())
    Local aAreaSZD  := SZD->(GetArea())
    Local aKey      := Array(2)
    Local cINNOVA   := GetMV("RE_FINNOVA", .F.,  "042297610001")         
    Local cFilOrig  := GetMV("RE_FILORIG", .F., "0302")

    Private nLCodFor  := Len(SZ5->Z5_CODFOR)
    Private nLCodBar  := Len(SZD->ZD_CODBAR)
    Private nLLoteFor := Len(SZD->ZD_LOTE)
    Private cCodBarra := Space(nLCodBar)
    Private cTipo     := "1" //--Grava Registro
    Private cForIN    := ""  //--Cod.Fornecedor Innova 
    Private cLjIN     := ""  //--Loja Forneceor Innova
    Private cCodRps   := ""
    Private lSetOff   := .F.

	If FWCodFil() # cFilOrig
        VtBeep(2)
        VtAlert("Recebimento Innova permitido somente na Filial " + cFilOrig, "ATENCAO", .T., 3000)
		Return
	EndIf

    cForIN := LEFT(cINNOVA, 8)
    cLjIN  := RIGHT(cINNOVA, 4)

    SZD->(dbSetOrder(1))  //--ZD_FILIAL + ZD_DOC + ZD_SERIE + ZD_CODBAR
    SZB->(dbSetOrder(1))  //--ZB_FILIAL + ZB_DOC + ZB_SERIE + ZB_FORNEC + ZB_LOJA

    akey[01] := VTSetKey(24, {|| Exclui()}, "Exclui Receb.") //-- CTRL + X - Exclui registro do Recebimento Innova
    akey[02] := VTSetKey(15, {|| SetOff()}, "Habilita Off" ) //-- CTRL + O - Atalho para setar produtos do tido OFF (Segunda Linha)

    While .T.
        VtClear()    
        cTipo     := "1"
        cCodBarra := Space(nLCodBar)
        cLoteFor  := Space(nLLoteFor)

        @ 0,0 VtSay Padc("RECEBIMENTO INNOVA", VTMaxCol())
        @ 1,0 VtSay "Leia Etiqueta"
        @ 3,0 VtGet cCodBarra  Pict "@!" Valid VldCodBar(cCodBarra)
        VTRead
        If VtLastKey() == 27
            If VtYesNo("Deseja Finalizar o Recebimento Innova?", "ATENCAO")
                cTipo := "2"
            Else 
                Exit
            EndIf
        EndIf

        nQtdPeso := GetQtdPeso(cCodBarra)
        cLoteFor := PadR(GetLotForn(cCodBarra), nLLoteFor)

        If lSetOff
            cProdFor := PadR(GetProdFor(cCodBarra) + "R", nLCodFor)
        Else
            cProdFor := PadR(GetProdFor(cCodBarra), nLCodFor)
        EndIf

        //-- Grava registros
        If cTipo == "1"
            fGrvSZD(cForIN, cLjIN, cLoteFor, nQtdPeso, cProdFor)
        Elseif cTipo == "2"
            fGrvFinRec()
            Exit
        Endif
    Enddo

    VTSetKey(24, aKey[01])
    VTSetKey(15, aKey[02])

    RestArea(aAreaSZD)
    RestArea(aAreaSZB)
    RestArea(aArea)

Return


/*/{Protheus.doc} VldCodBar
Rotina de validacao do codigo de barras lido
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 29/02/2024
@param cCodBarra, character, Codigo de barras
@return logical, Retorno logico
/*/
Static Function VldCodBar(cCodBarra)
    Local aAreaAnt := GetArea()
    local aAreaSZ5 := SZ5->(GetArea()) 
    Local aAreaSZD := SZD->(GetArea())
    Local cLoteFor := PadR(GetLotForn(cCodBarra), nLLoteFor)
    Local cProdFor := ""
    Local cTipId   := CBRetTipo(cCodBarra)

    If Empty(cCodBarra)
        Return .F.
    EndIf

    If lSetOff
        cProdFor := PadR(GetProdFor(cCodBarra) + "R", nLCodFor)
    Else
        cProdFor := PadR(GetProdFor(cCodBarra), nLCodFor)
    EndIf

    If ("(91)" $ cCodBarra) .Or. ("(92)" $ cCodBarra)
        VtBeep(2)
        VtAlert("Permitida leitura somente de etiquetas da Innova!", "ATENCAO", .T., 3000)
		VTKeyboard(chr(20))
        RestArea(aAreaSZD)
        RestArea(aAreaSZ5)
        RestArea(aAreaAnt)    
        Return .F.
    EndIf

    If (cTipId != "EAN128") .Or. (Len(AllTrim(cCodBarra)) < 36) .Or. (Len(AllTrim(cCodBarra)) > 45)
        VtBeep(2)
        VtAlert("Codigo de barras invalido!", "ATENCAO", .T., 3000)
		VTKeyboard(chr(20))  
        RestArea(aAreaSZD)
        RestArea(aAreaSZ5)
        RestArea(aAreaAnt)
        Return .F.
    Endif

    dbSelectArea("SZ5")
    SZ5->(dbSetOrder(1)) //-- Z5_FILIAL+Z5_CODFOR  
    If SZ5->(dbSeek( xFilial("SZ5") + cProdFor))
        cCodRps := SZ5->Z5_CODPRD
    Else
        VtBeep(2)
        VtAlert(AllTrim(cProdFor) + " sem traducao de codigos Replas!", "ATENCAO", .T., 3000)

        //-- Parametro para gerar codigo da REPLAS automaticamente com base na etiqueta lida da Innova
        If GetMV("RE_CRPSAUT", .F., "N") == "S"
            //-- Retorna o codigo do produto da REPLAS com base na etiqueta lida da Innova
            cCodRps := U_REESTA7B(cCodBarra)
        Else
            VTKeyboard(chr(20))
            RestArea(aAreaSZD)
            RestArea(aAreaSZ5)
            RestArea(aAreaAnt)        
            Return .F.
        EndIf
    Endif

    dbSelectArea("SZD")
    SZD->( dbSetOrder(5)) //-- ZD_FILIAL+ZD_LOTE
    If SZD->(dbSeek( xFilial("SZD") + cLoteFor))
        VtBeep(2)
		VtAlert("Etiqueta ja lida!", "ATENCAO", .T., 3000)
        VTKeyboard(chr(20))
        RestArea(aAreaSZD)
        RestArea(aAreaSZ5)
        RestArea(aAreaAnt)        
        Return .F. 
    Endif

    RestArea(aAreaSZD)
    RestArea(aAreaSZ5)
    RestArea(aAreaAnt)      

Return .T.


/*/{Protheus.doc} fGrvSZD
Rotina de gravacao do Recebimento Innova
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 29/02/2024
@param cForIN, character, Fornecedor
@param cLjIN, character, Loja
@param cLoteFor, character, Lote do fornecedor
@param nQtdPeso, numeric, Peso
@param cProdFor, character, Produto do fornecedor
/*/
Static Function fGrvSZD(cForIN, cLjIN, cLoteFor, nQtdPeso, cProdFor)
    Local aArea    := GetArea()
    Local aAreaSZD := SZD->(GetArea())

    dbSelectArea("SZD")
    SZD->( dbSetOrder(5)) //-- ZD_FILIAL+ZD_LOTE

    If SZD->(dbSeek( xFilial("SZD") + cLoteFor))
        VtBeep(2)
        VtAlert("Etiqueta ja lida, lote " + cLoteFor + " ja incluido!", "ATENCAO", .T., 3000)
    Else 
        RecLock( "SZD", .T.)
            SZD->ZD_FILIAL  := xFilial("SZD")
            SZD->ZD_FORNECE := cForIN
            SZD->ZD_LOJA    := cLjIN
            SZD->ZD_COD     := cCodRps
            SZD->ZD_CODBAR  := cCodBarra
            SZD->ZD_CODINN  := cProdFor
            SZD->ZD_LOTE    := cLoteFor
            SZD->ZD_VALID   := Ctod("  /  /  ")
            SZD->ZD_QTD     := nQtdPeso
            SZD->ZD_DCONF   := dDataBase
            SZD->ZD_HCONF   := Left(Time(), 5) 
            SZD->ZD_USER    := RetCodUsr()
        SZD->(dbUnLock())
    Endif

    RestArea(aAreaSZD)
    RestArea(aArea)

Return


/*/{Protheus.doc} fGrvFinRec
Rotina de gravacao da finalizacao do Recebimento Innova
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 29/02/2024
/*/
Static Function fGrvFinRec()
    Local aArea     := GetArea()
    Local aAreaSZD  := SZD->( GetArea() )
    Local cxDoc     := Space( TamSX3("ZD_DOC")[1] )
    Local lAchouBob := .F.   //--Verifica se Existem Bobinas para serem finalizadas
    Local nQtdBob   := 0

    SZD->(dbSetOrder(1))

    If SZD->( dbSeek( xFilial("SZD") + cxDoc  ))  
        While SZD->( !Eof() ) .AND. SZD->ZD_DOC == cxDoc
            If Empty( SZD->ZD_DFIM )
                nQtdBob++
                RecLock("SZD", .F.)
                    SZD->ZD_DFIM := dDataBase                 
                SZD->(dbUnLock())
                lAchouBob := .T.
            Endif
            SZD->( dbSkip() )
        EndDo

        VtBeep(2)
        If !lAchouBob
            VtAlert("Nao foram lidas bobinas no Recebimento Innova", "ATENCAO", .T., 3000 )
        Else
            VtAlert("Recebimento Innova finalizado com " + Alltrim(Str( nQtdBob )) + " bobina(s) lida(s)", "SUCESSO", .T., 3000 )         
        Endif 
    Else
        VtBeep(2)
        VtAlert("Nao foram lozalizados bobinas no Recebimento Innova", "ATENCAO", .T., 3000 )
    Endif

    RestArea(aAreaSZD)
    RestArea(aArea)

Return


/*/{Protheus.doc} GetLotForn
Rotina que retorna o codigo do lote do fornecedor contido na etiqueta da Innova
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 29/02/2024
@param cEtiq, character, Codigo de barras
@return character, Retorna lote do fornecedor
/*/
Static Function GetLotForn(cEtiq)
Return SubStr(cEtiq, 1, 10)


/*/{Protheus.doc} GetQtdPeso
Rotina que retorna a quantidade (Peso) da bobina contido na etiqueta da Innova
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 29/02/2024
@param cEtiq, character, Codigo de barras
@return numeric, Retorna peso
/*/
Static Function GetQtdPeso(cEtiq)
Return (Val(SubStr(cEtiq, 20, 6))/100)


/*/{Protheus.doc} GetProdFor
Rotina que retorna o produto do fornecedor (Produto + Largura)
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 29/02/2024
@param cEtiq, character, Codigo de barras
@return character, Retorna produto do fornecedor
/*/
Static Function GetProdFor(cEtiq)
Return AllTrim(SubStr(cEtiq, (At("B", cEtiq))+1)) + AllTrim(SubStr(cEtiq, 11, 04))


/*/{Protheus.doc} Exclui
Rotina de exclusao de registros lidos no recebimento da Innova
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 29/02/2024
/*/
Static Function Exclui()
    Local aSave     := VTSave()
    Local cEtiqueta := Space(75)

    VTClear()
    @ 0,0 VtSay PadC("**EXCLUI RECEB.**", VTMaxCol())
    @ 2,0 VtSay "Leia Etiqueta"
    @ 3,0 VtGet cEtiqueta pict "@!" Valid VldExclui(cEtiqueta)
    VtRead

    VTRestore(,,,,aSave)

Return


/*/{Protheus.doc} VldExclui
Rotina de validacao de exclusao de registros lidos no recebimento da Innova
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 29/02/2024
@param cEtiqueta, character, Codigo de barras
@return logical, Retorno logico
/*/
Static Function VldExclui(cEtiqueta)
    Local aAreaAnt := GetArea()
    Local aAreaSZD := SZD->(GetArea())
    Local cTipId   := CBRetTipo(cEtiqueta)

    If Empty(cEtiqueta)
        Return .F.
    EndIf

    If ("(91)" $ cEtiqueta) .Or. ("(92)" $ cEtiqueta)
        VtBeep(2)
        VtAlert("Permitida leitura somente de etiquetas da Innova!", "ATENCAO", .T., 3000)
		VTKeyboard(chr(20))     
        Return .F.
    EndIf

	If (cTipId != "EAN128") .Or. (Len(AllTrim(cEtiqueta)) < 36) .Or. (Len(AllTrim(cEtiqueta)) > 45)
        VtBeep(2)
        VtAlert("Codigo de barras invalido!", "ATENCAO", .T., 3000)
		VTKeyboard(chr(20))
		Return .F.
	EndIf

    dbSelectArea("SZD")
    SZD->( dbSetOrder(5)) //-- ZD_FILIAL+ZD_LOTE

    cLoteFor := PadR(GetLotForn(cEtiqueta), nLLoteFor)

    If !SZD->(dbSeek( xFilial("SZD") + cLoteFor))
        VtBeep(2)
		VtAlert("Registro nao localizado.", "Aviso", .T., 3000 )
		VTKeyboard(chr(20))
		Return .F.
    EndIf

    If !Empty(SZD->(ZD_DOC+ZD_SERIE)) .And. !VtYesNo("Produto ja tem NF, confirma exclusao?", "ATENCAO")
		VTKeyboard(chr(20))
		Return .F.
    EndIf

	If Empty(SZD->(ZD_DOC+ZD_SERIE)) .And. !VtYesNo("Confirma exclusao?", "ATENCAO")
		VTKeyboard(chr(20))
		Return .F.
	EndIf

    //-- Exclui o registro
    RecLock("SZD", .F.)
        DbDelete()
    SZD->(MsUnlock())

    RestArea(aAreaSZD)
    RestArea(aAreaAnt)

Return .T.


/*/{Protheus.doc} SetOff
Rotina que seta o recebimento de produtos do Tipo OFF (Segunda linha)- CTRL + O
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 29/02/2024
/*/
Static Function SetOff()

    If lSetOff .And. VtYesNo("Desabilita recebimento OFF?", "ATENCAO")
        lSetOff := .F.
    ElseIf !lSetOff .And. VtYesNo("Habilita recebimento OFF?", "ATENCAO")
        lSetOff := .T.
    EndIf

Return
