#INCLUDE "PROTHEUS.CH"


/*/{Protheus.doc} REPCPA06
Rotina de calculo e sugestao da melhor bobina
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 29/04/2022
@param cPedido, character, Pedido de Venda
@param cItem, character, Item do pedido
@param cCodCli, character, Codigo do cliente
@param nQtdVen, numeric, Quantidade venda
@param cArm, character, Armazem
@param _aSugest, variant, Array com a sugestoes
@param cIdSgt, character, ID da sugestao
@param _aREPCPA7P, variant, Array com conteudo das perguntas
@obs Projeto Novo PCP (Sugestao de Bobinas)
/*/
User Function REPCPA06(cPedido, cItem, cCodCli, nQtdVen, cArm, _aSugest, cIdSgt, _aREPCPA7P)
    Local aDimen     := {}
    Local aCalcBob   := {}
    Local cQuery     := ""
    Local cEoL       := chr(13) + chr(10)
    Local cMsg       := ""
    Local cCodMP     := ""
    Local cLocal     := ""
    Local cLote      := ""
    Local cSubLote   := ""
    Local nSaldo     := 0
    Local nVldDias   := 0
    Local nPesoAprx  := 0
    Local nQtdBob    := 0
    Local nPesoTAprx := 0
    Local dDtValid   := CToD("//")
    Local dDtFabric  := CToD("//")
    Local dDtLote    := CToD("//")

    Private cFamCodCli  := ""
    Private cRaizCod    := "" //-- Essa variavel sera alimentada com a raiz do codigo do material a ser usado
    Private nDiamIntCli := ""
    Private nDiamExtCli := ""
    Private nLarguraCli := ""
    Private cArmSuc     := GetMv("RE_ARMSUC", .F., "09") //-- Armazem de sucatas
    Private lChkOff     := GetMV("RE_CHKOFF", .F., .T.)

    SC5->( DbSetOrder(1) )
    SB1->( DbSetOrder(1) ) //-- B1_FILIAL+B1_COD
    SDD->( DbSetOrder(2) ) //-- DD_FILIAL+DD_PRODUTO+DD_LOCAL+DD_LOTECTL+DD_NUMLOTE+DD_MOTIVO

    //-- Pega a Familia do PA (MATERIAL)
    cFamCodCli  := SubStr( cCodCli, 01, (Len( AllTrim(cCodCli) ) - 9) ) 
    If At("SV-", cFamCodCli) > 0
        cFamCodCli := SubStr( cFamCodCli, 4 )
    EndIf

    //-- Pega as dimensoes do PA
    aDimen := GetDimen(cCodCli, "N")
    
    nDiamIntCli := aDimen[01]
    nDiamExtCli := aDimen[02]
    nLarguraCli := aDimen[03]

    If GetMv("RE_MPESTRU",,.T.)
        cRaizCod := GetMPEstr(cCodCli)
    Else
        cRaizCod := "MP" + cFamCodCli // MP - Toda materia prima sempre iniciara como MP. cFamCodCli - Estrutura do PA
    EndIf


    If !SC5->(DbSeek(xFilial("SC5") + cPedido))
        RestArea(aAreaSC5)
        RestArea(aArea)
        Return aRet
    Endif

    cCliente := SC5->C5_CLIENTE
    cLoja	 := SC5->C5_LOJACLI

    cQuery := " SELECT " + cEoL
    cQuery += "     SB8.*, SB8.R_E_C_N_O_ AS REC " + cEoL
    cQuery += " FROM " + cEoL
    cQuery += "     " + RetSQLName("SB8") + " SB8 " + cEoL
    cQuery += " WHERE " + cEoL
    cQuery += "     SB8.B8_FILIAL = '" + xFilial("SB8") + "' " + cEoL 
    cQuery += "     AND SB8.B8_LOCAL = '" + _aREPCPA7P[02] + "' " + cEoL
    cQuery += "     AND SB8.B8_PRODUTO LIKE '" + cRaizCod + "%' " + cEoL
    If !(lChkOff .And. _aREPCPA7P[04] == 1)
        cQuery += "     AND SB8.B8_PRODUTO NOT LIKE '%R' " + cEoL
    EndIf
    cQuery += "     AND SB8.B8_SALDO > 0 " + cEoL
    cQuery += "     AND SB8.D_E_L_E_T_ = ' ' " + cEoL
    cQuery += " ORDER BY B8_XIDSGT DESC, B8_PRODUTO, B8_DTVALID " + cEoL

    cQuery := ChangeQuery(cQuery)
	DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), "TRB", .F., .T.)

    While TRB->( !Eof() )
        cCodMP    := TRB->B8_PRODUTO
        cLocal    := TRB->B8_LOCAL
        //cLote     := AllTrim(TRB->B8_LOTECTL)
        //cSubLote  := AllTrim(TRB->B8_NUMLOTE)
        //--Comentado 28/02/23
        //--Pesquisa na Fungco ShelfLife nco estava sendo efetuada com sucesso
        cLote     := TRB->B8_LOTECTL
        cSubLote  := TRB->B8_NUMLOTE
        nSaldo    := TRB->B8_SALDO
        dDtValid  := SToD(TRB->B8_DTVALID)
        dDtFabric := SToD(TRB->B8_DFABRIC)

        //-- Verifica o produto
        If SB1->( DbSeek(xFilial("SB1") + cCodMP) ) .And. SB1->B1_MSBLQL $ "1"
            TRB->( DbSkip() )
            Loop 
        EndIf

        nVldDias := SB1->B1_PRVALID
        dDtLote  := dDtValid - nVldDias

        //-- Verifica se o saldo ja esta totalmente empenhado
        If TRB->(B8_SALDO == B8_EMPENHO)
            TRB->( DbSkip() )
            Loop
        EndIf 

        //-- Verifica se o lote/sub-lote esta bloqueado
        If SDD->( DbSeek(xFilial("SDD") + cCodMP + cLocal + cLote + cSubLote) )
            TRB->( DbSkip() )
            Loop
        EndIf 

        //-- Verifica se as Dimensoes (Diametro Interno/Externo e Largura) da MP atendem
        If !ChkDimen(cCodMP, @cMsg)
            TRB->( DbSkip() ) 
            Loop 
        EndIf

        //-- Verifica se o Shelf-life do lote atende o cliente
        If !ShelfLife(cCodMP, cLocal, cLote, cSubLote, cCliente, cLoja, @cMsg)
            TRB->( DbSkip() ) 
            Loop 
        EndIf

        //-- Calcula bobina
        aCalcBob := CalcBob(cCodMP, nSaldo, cLote, cSubLote)

        If !Empty(aCalcBob)
            nPesoAprx  := aCalcBob[01]
            nQtdBob    := aCalcBob[02] * aCalcBob[03]
            ChkQtdBob(nPesoTAprx, nQtdVen, nPesoAprx, @nQtdBob)
            nPesoTAprx += nPesoAprx * nQtdBob
        
            //-- Gravacao dos lotes que estao aptos a serem sugeridos
            aAdd( _aSugest, {cPedido, cItem, cCodCli, cCodMP, nPesoAprx, nQtdBob, cLote, cSubLote, dDtValid, dDtFabric, dDtLote, nSaldo, TRB->REC} )

            //-- Grava o Id da sugestao realizada
            If TRB->B8_XIDSGT # cIdSgt
                GrvIdSgt(TRB->REC, cIdSgt)
            EndIf

            If nPesoTAprx >= nQtdVen
                Exit
            EndIf
        EndIf

        TRB->( DbSkip() ) 

    EndDo

    TRB->( DbCloseArea() )

Return


/*/{Protheus.doc} GetDimen
Funcao que retorna as dimensoes do codigo/produto
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 29/04/2022
@param cCod, character, Codigo do produto
@param cRetType, character, Tipo de retorno
@return array, Array com as dimensoes
/*/
Static Function GetDimen(cCod, cRetType)
    Local aRet    := {}
    Local nI      := 0
    Local cAllDim := ""

    Default cRetType := "C"

    cAllDim := Right( AllTrim( cCod ), IIf( u_xIsOff(cCod), 10, 09 ) )

    aAdd(aRet, SubStr( cAllDim, 01, 02 ) ) //-- Diametro interno do tubo da bobina (Polegadas)
    aAdd(aRet, SubStr( cAllDim, 03, 03 ) ) //-- Diametro externo da bobina (mm)
    aAdd(aRet, SubStr( cAllDim, 06, 04 ) ) //-- Largura da bobina (mm)

    If cRetType == "N"
        For nI := 1 To Len(aRet)
            aRet[nI] := Val(aRet[nI])
        Next nI
    EndIf

    /* OBS!
    Desmembramento do codigo da REPLAS
    Exemplo: MPCS20E067000070
    
    MP    = Indica que o codigo do produto e uma materia prima
    CS20E = Indica qual e o MATERIAL (Familia do codigo do produto) 
    06    = Diametro interno do tudo da bobina (Polegadas)
    700   = Diametro externo da bobina (mm)
    0070  = Largura da bobina (mm)
    */

Return aClone(aRet)


/*/{Protheus.doc} ShelfLife
Funcao que verifica se o shelf life do Lote para atende o Cliente
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 29/04/2022
@param cCodMP, character, Codigo do produto
@param cArm, character, Armazem
@param cLotectl, character, Lote
@param cNumLote, character, Sub0lote
@param cCliente, character, Codigo cliente
@param cLoja, character, Loja cliente
@param cMsg, character, Mensagem de retorno
@return logical, Retorno logico
/*/
Static Function ShelfLife(cCodMP, cArm, cLotectl, cNumLote, cCliente, cLoja, cMsg)
    Local aArea      := GetArea()
    Local aAreaSA1   := SA1->(GetArea())
    Local aAreaSB8   := SB8->(GetArea())
    Local nVldDias 	 := 0
    Local nShelfLife := 0
    Local nSLPadrao	 := GetMV("RE_SLPAD", .F., 0)
    Local dDtValid   := ctod("")
    Local dDataIni   := ctod("")
    Local lRet 		 := .T.

    cMsg := ""

    SB8->( DbSetOrder(3) ) //-- B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL+B8_NUMLOTE+DTOS(B8_DTVALID)
    If !SB8->( DbSeek(xFilial("SB8") + cCodMP +  cArm + cLotectl + cNumLote) )
        RestArea(aAreaSB8)
        RestArea(aAreaSA1)
        RestArea(aArea)
        Return .F.
    EndIf 

    nVldDias := (SB8->B8_DTVALID - SB8->B8_DFABRIC)
    dDtValid := SB8->B8_DTVALID

    SA1->( DbSetOrder(1) ) //-- A1_FILIAL+A1_COD+A1_LOJA
    If SA1->( DbSeek(xFilial("SA1") + cCliente + cLoja) )
        nShelfLife := SA1->A1_XSL
        cMsgRef    := "Cliente + Loja (SA1)"
    EndIf 

    If Empty(nShelfLife)
        nShelfLife := nSLPadrao
        cMsgRef    := "Parametro (IM_SLPAD)"
    Endif

    dDataIni      := dDtValid - nVldDias
    nDiasPassados := Abs(dDatabase - dDataIni) 

    If nDiasPassados > nShelfLife .And. !Empty(nShelfLife)
        cMsg := "Shelf-life de [" + cValToChar(nDiasPassados) + "] dias, superior a [" + cValToChar(nShelfLife) + "] conforme " + cMsgRef + "!"
        lRet := .F.
    Endif
    
    RestArea(aAreaSB8)
    RestArea(aAreaSA1)
    RestArea(aArea)

Return lRet


/*/{Protheus.doc} ChkDimen
Funcao que verifica se as Dimensoes (Diametro Interno/Externo e Largura) da MP atendem
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 29/04/2022
@param cCodMP, character, Codigo do produto
@param cMsg, character, Mensagem de retorno
@return logical, Retorno logico
/*/
Static Function ChkDimen(cCodMP, cMsg)
    Local aDimenMP   := GetDimen(cCodMP, "N")
    Local nDiamIntMP := aDimenMP[01]
    Local nDiamExtMP := aDimenMP[02]
    Local nLarguraMP := aDimenMP[03]
    Local lRet       := .T.

    cMsg := ""

    If nDiamIntMP < nDiamIntCli
        cMsg := "Diametro interno menor!"
        lRet := .F.
    ElseIf nDiamExtMP < nDiamExtCli
        cMsg := "Diametro externo menor!"
        lRet := .F.
    ElseIf nLarguraMP < nLarguraCli
        cMsg := "Largura menor!"
        lRet := .F.
    EndIf

Return lRet


/*/{Protheus.doc} CalcBob
Funcao que realiza o calculo das bobinas, calculo do JOSE e outros
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 29/04/2022
@param cCodMP, character, Codigo do produto
@param nPesoMP, numeric, Peso da MP
@param cLote, character, Lote 
@param cSubLote, character, Sub-lote
@return array, Array com as bobinas calculadas
/*/
Static Function CalcBob(cCodMP, nPesoMP, cLote, cSubLote)
    Local aRet       := {}
    Local aDimenMP   := GetDimen(cCodMP, "N")
    //Local nDiamIntMP := aDimenMP[01]
    Local nDiamExtMP := aDimenMP[02]
    Local nLarguraMP := aDimenMP[03]
    Local nCalc01    := 0
    //Local nCalc02    := 0
    Local nCalc03    := 0
    Local nCalc04    := 0
    Local nCalc05    := 0
    Local nCalc06    := 0
    Local nX         := 0

    //-- Trecho que verifica se o lote/sub-lote ja esta sugerido
    For nX := 1 To Len(_aSugest)
        If _aSugest[nx, 07] + _aSugest[nx, 08] # cLote + cSubLote
            Loop
        EndIf

        //-- Calculo 01, Pega a largura que ja esta reservada
        nCalc01 += GetDimen(_aSugest[nx, 03], "N")[03] * _aSugest[nx, 06]
    
        //-- Calculo 02, Pega o peso que ja esta reservado
        //nCalc02 += _aSugest[nx, 05] * _aSugest[nx, 06]
    Next nX

    //-- Calculo 03, Pega a lagura da bobina que esta disponivel para uso
    nCalc03 := nLarguraMP - nCalc01

    If nCalc03 >= nLarguraCli
        //-- Calculo 04, Regra de 3 feita pelo "Jose", para calcula o peso aproximado da bobina
        nCalc04 := Round( ( ( nPesoMP / nLarguraMP ) * nLarguraCli ), 1 ) 
        //aAdd( aRet, nCalc04 )

        //-- Calculo 05, Retorna a quantidade de bobinas que podem ser feitas de acordo com a largura
        nCalc05 := Int( nCalc03 / nLarguraCli ) //Int(nLarguraMP / nLarguraCli)
        //aAdd( aRet, nCalc05 )

        //-- Calculo 06, Retorna a quantidade de bobinas que podem ser feitas de acordo com o diametro externo
        nCalc06 := Int( nDiamExtMP / nDiamExtCli )
        //aAdd( aRet, nCalc06 )

        //-- Tratamento necessario para quando e possivel fazer mais de uma bobina com a mesma MP considerando o diametro externo
        If nCalc06 > 1
            nCalc04 := nCalc04 / nCalc06
        EndIf

        aAdd( aRet, nCalc04 )
        aAdd( aRet, nCalc05 )
        aAdd( aRet, nCalc06 )
    EndIf

Return aClone(aRet)


/*/{Protheus.doc} GrvIdSgt
Funcao que grava o ID da sugestao na SB8
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 29/04/2022
@param nRecno, numeric, Recno da SB8
@param cIdSgt, character, ID da sugestao
/*/
Static Function GrvIdSgt(nRecno, cIdSgt)
    Local aArea    := GetArea()
    Local aAreaSB8 := SB8->(GetArea())

    DbSelectArea("SB8")
    SB8->( DbGoTo(nRecno) )

    RecLock("SB8", .F.)
        SB8->B8_XIDSGT := cIdSgt
    SB8->( MsUnLock() )

    RestArea(aAreaSB8)
    RestArea(aArea)

Return


/*/{Protheus.doc} ChkQtdBob
Funcao que checa se a quantidade de bobinas ja atende o peso do cliente
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 29/04/2022
@param nPesoTAprx, numeric, Peso total aproximado
@param nQtdVen, numeric, Quantidade vendida
@param nPesoAprx, numeric, Peso aproximado
@param nQtdBob, numeric, Quantidade de bobinas
/*/
Static Function ChkQtdBob(nPesoTAprx, nQtdVen, nPesoAprx, nQtdBob)
    Local nPesotAux := nPesoTAprx
    Local nX        := 0

    For nX := 1 To nQtdBob
        nPesotAux += nPesoAprx * nX

        If nPesotAux >= nQtdVen
            nQtdBob := nX
            Exit
        EndIf

        nPesotAux := nPesoTAprx
    Next nX

Return

Static Function GetMPEstr(cCodCli)
    local aArea     := GetArea()
    local cFamCod   := " "
    local cCodMP    := " "
    local cQuery    := " "

    cCodCli := Alltrim( cCodCli )

    cQuery := " SELECT G1_COMP " + CRLF
    cQuery += " FROM " + RetSqlName("SG1") + " G1 " + CRLF
    cQuery += " WHERE G1.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += " AND G1.G1_FILIAL = '" + xFilial("SG1") + "' " + CRLF
    cQuery += " AND G1.G1_COD = '" + cCodCli + "' " + CRLF
    cQuery += " AND G1.G1_COMP LIKE 'MP%' " + CRLF

    DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "XSG1", .F., .T. )

	If XSG1->( !Eof() )
	   cCodMP := Alltrim(XSG1->G1_COMP)
	EndIf
    
	XSG1->( DbCloseArea() )   

    If !Empty( cCodMP )
        cFamCod  := SubStr( cCodMP, 01, (Len( AllTrim( cCodMP ) ) - IIf( u_xIsOff( cCodMP ), 10, 09 )) ) 
    Endif

    RestArea( aArea ) 

Return cFamCod
