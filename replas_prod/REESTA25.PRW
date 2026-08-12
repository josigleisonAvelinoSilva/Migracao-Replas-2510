#include "totvs.ch"
#include "topconn.ch"
#include "apvt100.ch"


/*/{Protheus.doc} REESTA25
Rotina de contagem de filmes especifica da Replas
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 21/04/2025
/*/
User Function REESTA25()
    Local aAreaAnt  := GetArea()
    Local aKey      := Array(2)

    Private cArm      := "01"
    Private cCodBarra := Space(75)
    Private lSetOff   := .F.

    aKey[01] := VTSetKey(18, {|| Registros()}, "Registros")  //-- CTRL + R - Registros de produtos ja contados
    akey[02] := VTSetKey(15, {|| SetOff()}, "Habilita Off" ) //-- CTRL + O - Atalho para setar contagem de produtos do tido OFF (Segunda Linha)

    While .T.
        cCodBarra := Space(75)

        VTClear()                        
        @ 0,0 VTSay PadC("INVENTARIO", VTMaxCol(), "*")
        @ 2,0 VTSay "Armazem" //-- Armazem onde o inventario sera realizado
        @ 3,0 VTGet cArm Pict "@!" Valid VldArm() F3 "NNR" When VTLastKey() == 5
        @ 5,0 VTSay "Leia Etiqueta"
        @ 6,0 VTGet cCodBarra Pict "@!" Valid VldCodBar(cCodBarra)
        VTRead

        If VTLastKey() == 27
            If VTYesNo("Deseja sair do inventario?", "ATENCAO", .T.)
                Exit 
            EndIf
        EndIf
    EndDo

    VTSetKey(18, aKey[01])
    VTSetKey(15, aKey[02])

    RestArea(aAreaAnt)

Return


/*/{Protheus.doc} VldArm
Rotina de validacao de armazem
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 21/04/2025
@return logical, Retorno logico
/*/
Static Function VldArm()

    If Empty(cArm)
        Return .F.
    EndIf	                 

    dbSelectArea("NNR")
    NNR->(dbSetOrder(1) )
    If !NNR->(dbSeek( xFilial("NNR") + cArm)) 
		VTBeep(2)
		VTAlert("Armazem nao encontrado.", "ATENCAO", .T., 3000)
        VTKeyboard(chr(20))
        Return .F.
    EndIf

Return .T.


/*/{Protheus.doc} VldCodBar
Rotina que faz a validacao do codigo de barras lido
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 21/04/2025
@param cCodBarra, character, Conteudo do codigo de barras lido
@return logical, Retorno logico
/*/
Static Function VldCodBar(cCodBarra)
    Local aEtiqueta  := {}
    Local cTipId     := ""
    Local cProduto   := Space(Len(SB8->B8_PRODUTO))
    Local cLote      := Space(Len(SB8->B8_LOTECTL))
    Local cSLote     := Space(Len(SB8->B8_NUMLOTE))
    Local cQuery     := ""
    Local nQuant     := 0
    Local nQtdOri    := 0
    Local cAuxProd   := ""
    Local cAuxLote   := ""
    Local cAuxSLot   := ""
    Local nAuxQtde   := 0
    Local cObserv    := ""
    Local dDtValid   := Nil
    Local cEtqOrigem := ""

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

    If !("(91)" $ cCodBarra) .And. !("(92)" $ cCodBarra) .And. (Len(AllTrim(cCodBarra)) >= 36) .And. (Len(AllTrim(cCodBarra)) <= 45)
        //-- ETIQUETA "INNOVA"
        cEtqOrigem := "INNOVA"

        nAuxQtde := (Val(SubStr(cCodBarra, 20, 6))/100)
        cAuxLote := SubStr(cCodBarra, 1, 10)

        If Select("_QRY") > 0
            _QRY->(dbCloseArea())
        EndIf

        cQuery := " SELECT SB8.B8_PRODUTO, SB8.B8_LOTECTL, SB8.B8_NUMLOTE "
        cQuery += " FROM " + RetSQLName("SB8") + " SB8 "
        cQuery += " WHERE (SB8.B8_LOTECTL = '" + cAuxLote + "' OR SB8.B8_LOTEFOR = '" + cAuxLote + "') "
        cQuery += " AND SB8.D_E_L_E_T_ = ' '

        cQuery := ChangeQuery(cQuery)
        TCQUERY cQuery New Alias "_QRY"

        If _QRY->(!EoF())
            aEtiqueta := {_QRY->B8_PRODUTO, nAuxQtde, cAuxLote, CTOD("//"), "", _QRY->B8_NUMLOTE}
        EndIf

        If Select("_QRY") > 0
            _QRY->(dbCloseArea())
        EndIf

        If Empty(aEtiqueta)
            cAuxProd := U_REESTA7B(cCodBarra)

            If lSetOff
                //-- Habilita a contagem de produtos do tido OFF (Segunda Linha)
                cAuxProd := PadR(AllTrim(cAuxProd) + "R", TamSX3("B1_COD")[01])
                lSetOff  := .F.
            Else
                cAuxProd := PadR(cAuxProd, TamSX3("B1_COD")[01])
            EndIf

            cAuxSLot := NextLote(cAuxProd, "S")
            If Empty(cAuxSLot)
                cAuxSLot := StrZero(1, TamSX3("B8_NUMLOTE")[01])
            EndIf

            aEtiqueta := {cAuxProd, nAuxQtde, cAuxLote, CTOD("//"), "", cAuxSLot}

            SB1->(dbSetOrder(1))
            If SB1->(dbSeek(xFilial("SB1") + cAuxProd))
                cObserv += "Produto Replas nao cadastrado.|"
            EndIf
        EndIf
    ElseIf ("(91)" $ cCodBarra) .Or. ("(92)" $ cCodBarra)
        //-- ETIQUETA "MM DA AMAZONIA" OU "INDUSTRIA MM" 
        cEtqOrigem := "MM"

        If ExistBlock("CBRETEAN")
            aEtiqueta := ExecBlock("CBRETEAN",,,{cCodBarra})
        EndIf

        If Empty(aEtiqueta[1])
            VTBeep(2)
            VTAlert("Produto Replas nao traduzido.", "ATENCAO", .T., 3000)
            VTKeyboard(chr(20))
            Return .F.
        EndIf

        SB1->(dbSetOrder(1))
        If !SB1->(dbSeek(xFilial("SB1") + aEtiqueta[1]))
            cObserv += "Produto Replas nao cadastrado.|"
        EndIf
    Else
        VTBeep(2)
		VTAlert("Etiqueta invalida. Leia etiqueta MM ou INNOVA", "ATENCAO", .T., 3000)
		VTKeyboard(chr(20))
		Return .F.
    EndIf

    If Empty(aEtiqueta)
        VTBeep(2)
		VTAlert("Etiqueta invalida. Conteudo. ", "ATENCAO", .T., 3000)
		VTKeyboard(chr(20))
		Return .F.
    EndIf

    cProduto := aEtiqueta[1]
    nQuant   := aEtiqueta[2]
    cLote    := aEtiqueta[3]
    cSLote   := aEtiqueta[6]

    If !FilmRastro(cProduto, @cLote, @cSLote)
        VTKeyboard(chr(20))
        Return .F.
    EndIf

    //-- Valida se a contagem da bobina ja feita realizada
    If ExistSZ7(cEtqOrigem, cProduto, cLote, cSLote, nQuant)
        VTBeep(2)
        VTAlert("Bobina ja contado.", "ATENCAO", .T., 3000)
        VTKeyboard(chr(20))
        Return .F.
    EndIf

    If !(ValType(cSLote) == "C") .Or. !IsNumeric(cSLote)
        VTBeep(2)
		VTAlert("Sub-Lote invalido.", "ATENCAO", .T., 3000)
		VTKeyboard(chr(20))
        cCodBarra := Space(75)
		Return .F.
    EndIf

    If Select("_QRYSLD") > 0
        _QRYSLD->(dbCloseArea())
    EndIf

    cQuery := " SELECT SB8.* "
    cQuery += " FROM " + RetSQLName("SB8") + " SB8 "
    cQuery += " WHERE SB8.B8_LOTECTL = '" + cLote + "' "
    cQuery += " AND SB8.B8_NUMLOTE = '" + cSLote + "' "
    cQuery += " AND SB8.B8_SALDO > 0 "
    cQuery += " AND SB8.D_E_L_E_T_ = ' '

    cQuery := ChangeQuery(cQuery)
    TCQUERY cQuery New Alias "_QRYSLD"

    If _QRYSLD->(!EoF())
        If !(_QRYSLD->B8_FILIAL == FWCodFil())
            cObserv += "Bobina com saldo na filial [" + _QRYSLD->B8_FILIAL + "].|"
        EndIf

        If !(AllTrim(_QRYSLD->B8_PRODUTO) == AllTrim(cProduto))
            cObserv += "Produto diferente, mesmo lote.|"

            cProd1 := AllTrim(_QRYSLD->B8_PRODUTO)
            cProd2 := AllTrim(cProduto)

            nNumCar1 := u_xNCarFilm(cProd1)
            nNumCar2 := u_xNCarFilm(cProd2)

            cFam1 := SubStr(cProd1, 1, Len(cProd1)-nNumCar1)
            cFam2 := SubStr(cProd2, 1, Len(cProd2)-nNumCar2)

            //-- Familia
            If !(cFam1 == cFam2)
                cObserv += "Familia diferente [" + cFam1 + "].|"
            EndIf

            aDimen1 := u_xGetDimen(cProd1)
            aDimen2 := u_xGetDimen(cProd2)

            //-- Diamentro interno
            If !(aDimen1[1] == aDimen2[1])
                cObserv += "Diamentro interno diferente [" + aDimen1[1] + "].|"
            EndIf

            //-- Diamentro externo
            If !(aDimen1[2] == aDimen2[2])
                cObserv += "Diamentro externo diferente [" + aDimen1[2] + "].|"
            EndIf

            //-- Largura
            If !(aDimen1[3] == aDimen2[3])
                cObserv += "Largura diferente [" + aDimen1[3] + "].|"
            EndIf
        EndIf

        If !(AllTrim(_QRYSLD->B8_LOCAL) == AllTrim(cArm))
            cObserv += "Bobina com armazem diferente [" + AllTrim(_QRYSLD->B8_LOCAL) + "].|"
        EndIf

        If !(AllTrim(_QRYSLD->B8_LOTECTL) == AllTrim(cLote))
            cObserv += "Bobina com lote diferente [" + AllTrim(_QRYSLD->B8_LOTECTL) + "].|"
        EndIf

        If !(AllTrim(_QRYSLD->B8_NUMLOTE) == AllTrim(cSLote))
            cObserv += "Bobina com sub-lote diferente [" + AllTrim(_QRYSLD->B8_NUMLOTE) + "].|"
        EndIf

        If !Empty(_QRYSLD->B8_EMPENHO)
            cObserv += "Bobina com saldo empenhado [" + AllTrim(Transform(_QRYSLD->B8_EMPENHO, "@E 999,999.99")) + "].|"
        EndIf

        If (QtdComp(_QRYSLD->B8_SALDO) <> QtdComp(nQuant))
            nQtdOri := _QRYSLD->B8_SALDO
            cObserv += "Bobina com saldo diferente [" + AllTrim(Transform(_QRYSLD->B8_SALDO, "@E 999,999.99")) + "].|"
            //VTBeep(2)
            //VTAlert("Bobina com saldo diferente " + AllTrim(Transform(_QRYSLD->B8_SALDO, "@E 999,999.99")) + ".", "ATENCAO", .T., 5000)
        EndIf

        dDtValid := STOD(_QRYSLD->B8_DTVALID)
    EndIf

    If !u_xIsMP(cProduto)
        cObserv += "Tipo diferente de [MP].|"
    EndIf

    If u_xIsMP(cProduto) .And. !Rastro(cProduto, "S")
        cObserv += "Rastro diferente de [S].|"
    EndIf

    If Empty(nQtdOri)
        nQtdOri := nQuant
    EndIf

    If Select("_QRYSLD") > 0
        _QRYSLD->(dbCloseArea())
    EndIf

    If Empty(dDtValid)
        dDtValid := dDataBase
    EndIf


    // If !UpdRegistro(cProduto, cArm, nQuant, cLote, cSLote, cCodBarra, cObserv)
        If !UpdRegistro(cProduto,cArm,nQuant,cLoteCtl,cNumLote,cCodBarra,cObserv)
        IncRegistro(cProduto, cArm, nQuant, nQtdOri, cLote, cSLote, dDtValid, cCodBarra, cObserv)

    EndIf

Return .T.


/*/{Protheus.doc} IncRegistro
Rotina que inclui o registro de contagem na tabela SZ7 de contem as contagens de filmes
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 21/04/2025
@param cCodProd, character, Codigo do produto
@param cLocal, character, Armazem
@param nQuant, numeric, Quantidade
@param cLoteCtl, character, Lote
@param cNumLote, character, Sub-lote
@param dDtValid, date, Data de validade
@param cCodEtiq, character, Conteudo do codigo de barras lido
@param cObserv, character, Observacoes da bobina lida
/*/
Static Function IncRegistro(cCodProd, cLocal, nQuant, nQtdOri, cLoteCtl, cNumLote, dDtValid, cCodEtiq, cObserv)
    Local aDocInv  := GetDocInv(cCodProd, cLocal)
    Local cDocInv  := aDocInv[1]
    Local dDataInv := aDocInv[2]

    cObserv := AllTrim(cObserv)
    If Right(cObserv,1) == "|"
        cObserv := SubStr(cObserv,1,Len(cObserv)-1)
    EndIf

    dbSelectArea("SZ7")
    SZ7->(dbSetOrder(4)) //-- Z7_FILIAL+Z7_NUMLOTE+Z7_LOTECTL+Z7_COD+DTOS(Z7_DTINV) 
    If SZ7->(dbSeek(xFilial("SZ7") + cNumLote + cLoteCtl + cCodProd + DTOS(dDataInv)))
        RecLock("SZ7", .F.)
            SZ7->Z7_QUANT   := nQuant
        SZ7->(MsUnLock())
    Else
        RecLock("SZ7", .T.)
            SZ7->Z7_FILIAL  := xFilial("SZ7")
            SZ7->Z7_DOCINV  := cDocInv
            SZ7->Z7_COD     := cCodProd
            SZ7->Z7_LOCAL   := cLocal
            SZ7->Z7_QUANT   := nQuant
            SZ7->Z7_QTDORI  := nQtdOri //-- Quantidade original serve como referencia caso o campo "Z7_QUANT"
            SZ7->Z7_LOTECTL := cLoteCtl
            SZ7->Z7_NUMLOTE := cNumLote
            SZ7->Z7_DTVALID := dDtValid
            SZ7->Z7_DATA    := Date() //-- Data serve como referencia caso o campo "Z7_DTINV" esteja com data diferente
            SZ7->Z7_DTINV   := dDataInv
            SZ7->Z7_HRINV   := SubStr(Time(),1,5)
            SZ7->Z7_USER    := cUserName
            SZ7->Z7_TIPO    := GetAdvFVal("SB1", "B1_TIPO", xFilial("SB1") + PadR(cCodProd, Len(SB1->B1_COD)), 1, " ")
            SZ7->Z7_GRUPO   := GetAdvFVal("SB1", "B1_GRUPO", xFilial("SB1") + PadR(cCodProd, Len(SB1->B1_COD)), 1, " ")
            SZ7->Z7_STATUS  := "1" //-- 1=Contado;2=Finalizado;3=Processado
            SZ7->Z7_CODETI  := cCodEtiq
            SZ7->Z7_OBS     := cObserv
        SZ7->(MsUnLock())
    EndIf

Return


//--
Static Function GetDocInv(cCodProd, cLocal)
    Local cQuery := ""
    Local aRet   := Array(2)

    If Select("_QRYDOC") > 0
        _QRYDOC->(dbCloseArea())
    EndIf

    //-- Query buscar o numero do documento de inventario
    cQuery := " SELECT Z7_DOCINV DOC, Z7_DTINV DTINV "
    cQuery += " FROM " + RetSQLName("SZ7")
    cQuery += " WHERE Z7_FILIAL = '" + xFilial("SZ7") + "' "
    cQuery += " AND Z7_COD = '" + cCodProd + "' "
    cQuery += " AND Z7_LOCAL = '" + cLocal + "' "
    cQuery += " AND Z7_STATUS = '1' "
    cQuery += " AND D_E_L_E_T_ = ' ' "

    cQuery := ChangeQuery(cQuery)
    TCQUERY cQuery New Alias "_QRYDOC"

    If _QRYDOC->(!EoF()) .And. !Empty(_QRYDOC->DOC)
        aRet[1] := _QRYDOC->DOC
        aRet[2] := STOD(_QRYDOC->DTINV)
    EndIf

    If Select("_QRYDOC") > 0
        _QRYDOC->(dbCloseArea())
    EndIf

    If Empty(aRet[1])
        aRet[1] := u_xNextNum("SB7", "B7_DOC")
        aRet[2] := dDataBase
    EndIf

Return aRet


/*/{Protheus.doc} ExistSZ7
Rotina que valida a existencia da contagem na tabela SZ7
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 21/04/2025
@param cEtqOrigem, character, Origem/fornecedor da bobina
@param cCodProd, character, Codigo do produto
@param cLoteCtl, character, Lote
@param cNumLote, character, Sub-lote
@return logical, Retorno logico
/*/
Static Function ExistSZ7(cEtqOrigem, cCodProd, cLoteCtl, cNumLote, nQuant)
    Local aAreaAnt := GetArea()
    Local cQuery   := ""
    Local lExist   := .F.
    Local dDataInv := GetDocInv(cCodProd, cArm)[2]

    Default cNumLote := ""

    If Select("_QRY") > 0
        _QRY->(dbCloseArea())
    EndIf

    //-- Query para validar se a bobina ja foi contada
    cQuery := " SELECT ISNULL(SUM(Z7_QUANT),0) Z7_QUANT, COUNT(*) JACONT "
    cQuery += " FROM " + RetSQLName("SZ7")
    cQuery += " WHERE Z7_FILIAL = '" + xFilial("SZ7") + "' "
    cQuery += " AND Z7_COD = '" + cCodProd + "' "
    cQuery += " AND Z7_LOCAL = '" + cArm + "' "
    cQuery += " AND Z7_DTINV = '" + DTOS(dDataInv) + "' "
    If cEtqOrigem == "INNOVA"
        cQuery += " AND Z7_LOTECTL = '" + cLoteCtl + "' "
    Else
        cQuery += " AND Z7_LOTECTL = '" + cLoteCtl + "' AND Z7_NUMLOTE = '" + cNumLote + "' "
    EndIf
    cQuery += " AND Z7_STATUS = '1' "
    cQuery += " AND Z7_TIPO <> 'PA' "
    cQuery += " AND D_E_L_E_T_ = ' ' "

    cQuery := ChangeQuery(cQuery)
    TCQUERY cQuery New Alias "_QRY"

    _QRY->(dbGoTop())
    If _QRY->(!EoF()) .And. _QRY->JACONT > 0
        lExist := .T.
    EndIf

    If lExist .And. (QtdComp(_QRY->Z7_QUANT) <> QtdComp(nQuant))
        If lExist .And. VTYesNo("Deseja alterar o peso da bobina ja contado?", "ATENCAO", .T.)
            lExist := .F.
        EndIf
    EndIf

    If Select("_QRY") > 0
        _QRY->(dbCloseArea())
    EndIf

    RestArea(aAreaAnt)

Return lExist


/*/{Protheus.doc} Registros
Rotina que apresenta os registros de produtos ja contados, lista somente as 10 ultimas bobinas contadas
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 21/04/2025
/*/
Static Function Registros()
    Local aCab   := { "Produto", "Qtde", "Lote", "Sub-Lote" } 
    Local aLista := {}
    Local aSize  := { 18, 07, 12, 09 }
    Local aSave  := VTSave()
    Local cQuery := ""      

    cQuery := " SELECT TOP 10 " + CRLF
    cQuery += "     * " + CRLF 
    cQuery += " FROM " + CRLF 
    cQuery += "     " + RetSqlName("SZ7") + " SZ7 " + CRLF
    cQuery += " WHERE " + CRLF
    cQuery += "     SZ7.Z7_FILIAL = '" + xFilial("SZ7") + "' " + CRLF
    cQuery += "     AND SZ7.Z7_QUANT > 0 " + CRLF 
    cQuery += "     AND SZ7.Z7_DTINV = '" + DToS(dDataBase) + "' " + CRLF
    cQuery += "     AND SZ7.Z7_USER = '" + cUserName + "' " + CRLF
    cQuery += "     AND SZ7.Z7_STATUS = '1' " + CRLF
    cQuery += "     AND SZ7.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += " ORDER BY SZ7.R_E_C_N_O_ DESC " + CRLF

	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), "_TMP", .F., .T.)

    While _TMP->(!EoF())
        aAdd(aLista, {_TMP->Z7_COD, Str( _TMP->Z7_QUANT, 6, 1 ), _TMP->Z7_LOTECTL, _TMP->Z7_NUMLOTE})

        _TMP->(dbSkip())
    EndDo

    _TMP->(dbCloseArea())

    VTClear()
    @ 0,0 VtSay PadC("REGISTROS 10 ULT.", VTMaxCol(), "*")
    VTaBrowse(2, 0, 7, 19, aCab, aLista, aSize)
    VTRestore(,,,, aSave)

Return


/*/{Protheus.doc} SetOff
Rotina que seta a contagem de produtos do Tipo OFF (Segunda linha)- CTRL + O
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 21/04/2025
/*/
Static Function SetOff()

    If lSetOff .And. VtYesNo("Desabilita contagem OFF?", "ATENCAO", .T.)
        lSetOff := .F.
    ElseIf !lSetOff .And. VtYesNo("Habilita contagem OFF?", "ATENCAO", .T.)
        lSetOff := .T.
    EndIf

Return


/*/{Protheus.doc} FilmRastro
Rotina que valida o lote do filme lido, somente se o produto for uma "MP"
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 21/04/2025
@param cProduto, character, Codigo do produto
@param cLote, character, Lote
@param cSubLote, character, Sub-lote
@param dValid, date, Data de validade
@param lEmpty, logical, Valida vazio
@return logical, Retorno logico
/*/
Static Function FilmRastro(cProduto,cLote,cSubLote,dValid,lEmpty)
    Local aSave := VTSave()

    Default lEmpty := .F.

    If !(SubStr(cProduto,1,2) == "MP")
        Return .T.
    EndIf

    If VTModelo()=="RF"
        VTClear
        @ 0,0 VTSay "Produto com rastro"
        @ 2,0 VtSay "Lote"
        @ 3,0 VtGet cLote /*pict '@!'*/  valid If(lEmpty,.t.,!Empty(cLote)) when Empty(cLote)
        If cSubLote <> Nil
            @ 5,0 VtSay "Sub-Lote"
            @ 6,0 VtGet cSubLote pict '@!' valid If(lEmpty,.t.,!Empty(cSubLote))
        EndIf
        VTREAD
		If dValid <> NIL
            VTClear()
			@ 0,0 VtSay "Validade"
			@ 1,0 VtGet dValid pict '@D' valid If(lEmpty,.t.,!Empty(dValid))
			VTREAD
		EndIf
    EndIf

    VtRestore(,,,,aSave)

    If VTLastKey() == 27
        VTAlert("Lote invalido","Aviso",.t.,3000)
        Return .F.
    EndIf

Return .T.



// Static Function UpdRegistro(cCodProd, cLocal, nQuant, cLoteCtl, cNumLote, cCodEtiq, cObserv)

//     Local lAchou := .F.

//         DbSelectArea("SZ7")
//         SZ7->(DbSetOrder(4))

//         If SZ7->(DbSeek(xFilial("SZ7") + cNumLote + cLoteCtl + cCodProd))

//             While !SZ7->(Eof()) .And. ;
//                 SZ7->Z7_FILIAL  == xFilial("SZ7") .And. ;
//                 SZ7->Z7_NUMLOTE == cNumLote .And. ;
//                 SZ7->Z7_LOTECTL == cLoteCtl .And. ;
//                 SZ7->Z7_COD     == cCodProd

//                 If SZ7->Z7_STATUS == "4" 

//                     RecLock("SZ7", .F.)
//                         SZ7->Z7_QUANT  := nQuant    // Atualiza a quantidade bipada
//                         SZ7->Z7_DTINV  := Date()    // Inclui a data 
//                         SZ7->Z7_HRINV  := SubStr(Time(),1,5) // Inclui a hora
//                         SZ7->Z7_STATUS := "1"      // Atualiza o status para contado
//                         SZ7->Z7_USER   := cUserName //Grava o nome do usuário.
//                         SZ7->Z7_CODETI  := cCodEtiq // Grava a etiqueta
//                         SZ7->Z7_OBS     := cObserv  // Grava a observação
//                     SZ7->(MsUnlock())

//                 lAchou := .T.
//                 Exit

//             EndIf

//             SZ7->(DbSkip())

//         EndDo

//     EndIf

// Return lAchou

Static Function UpdRegistro(cCodProd, cLocal, nQuant, cLoteCtl, cNumLote, cCodEtiq, cObserv)

    DbSelectArea("SZ7")
    SZ7->(DbSetOrder(3))

    If SZ7->(DbSeek(xFilial("SZ7") + cNumLote + cLoteCtl))

        While !SZ7->(Eof()) .And. ;
            SZ7->Z7_FILIAL  == xFilial("SZ7") .And. ;
            SZ7->Z7_NUMLOTE == cNumLote .And. ;
            SZ7->Z7_LOTECTL == cLoteCtl .And. ;
            SZ7->Z7_COD     == cCodProd .And. ;
            SZ7->Z7_LOCAL   == cLocal

            RecLock("SZ7", .F.)
                SZ7->Z7_QUANT  := nQuant
                SZ7->Z7_DTINV  := Date()
                SZ7->Z7_HRINV  := SubStr(Time(),1,5)
                SZ7->Z7_STATUS := "1"
                SZ7->Z7_USER   := cUserName
                SZ7->Z7_CODETI := cCodEtiq
                SZ7->Z7_OBS    := cObserv
            SZ7->(MsUnlock())

            Return .T.

        EndDo

    EndIf

Return .F.

