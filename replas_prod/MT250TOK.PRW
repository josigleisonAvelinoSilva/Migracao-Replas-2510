#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"


/*/{Protheus.doc} MT250TOK
Ponto de entrada usado para fazer manipulacao antes do apontamento simples da OP
@type function
@version 1.0 
@author Dener Lemos - DOTHINK
@since 10/01/2022
@return logical, Retorno logico, indicando se pode prosseguir com o apontamento da OP
@obs Projeto Apontamento de Perda (Retorno para Estoque e Sucata)
/*/
User Function MT250TOK()
    Local aArea      := GetArea()
    Local aBobina    := {}
    Local lRet       := .T.
    Local lAptPerda  := GetMv( "RE_APTPRD", .F., .T. )
    Local lIntIndMM  := GetMV( "RE_INTIND", .F., .T. )
    //Local cFilOrig   := GetMV( "RE_FILORIG", .F., "0302" )
    Local cFilDest   := GetMV( "RE_FILDEST", .F., "0201" )
    Local nQtdMPUti  := 0
    Local nPerAceite := GetMv( "RE_PACEITE", .F., 5 )
    Local cMsg       := "Apontamento de produção." 

    SZ9->( dbSetOrder(1))  // --Z9_FILIAL + Z9_OP

    If (lIntIndMM .And. !IsInCallStack("U_REFATA06")) .And. (lAptPerda .And. cFilAnt == cFilDest) .And. SC2->C2_XITOK .And. lRet
        If lRet
            //-- Validacao para verificar se a OP ja foi apontada
            lRet := VldJaApto()
        EndIf

        If lRet
            //-- Validacao do percentual maximo e minimo 
            lRet := U_REESTA22()
        EndIf

        If lRet .And. FWAlertYesNo(cMsg, "Confirma Apontamento?")
            //-- Inicio do tratamento para apontamento do Retorno/Sucata
            aBobina := GetBobina(M->D3_OP)

            If !Empty(aBobina) .And. FWAlertYesNo("Deseja apontar <b>Retorno para Estoque</b> e/ou <b>Sucata</b>?", "Apontamento Retorno/Sucata?")
                Begin Transaction
                    If lRet
                        lRet := U_REPCPA01(aBobina)
                    EndIf

                    If lRet
                        //-- Quantidade de materia prima usada na OP menos as perda apontadas
                        nQtdMPUti := fQtdMPUtiz(SC2->C2_FILIAL, SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN)

                        If ABS( nQtdMPUti/m->D3_QUANT - 1 ) * 100  > nPerAceite .OR. ABS( m->D3_QUANT/nQtdMPUti - 1 ) * 100  > nPerAceite
                            Help(Nil, Nil, "QTDEMP", Nil, "O peso informado <b>"+AllTrim(Transform(M->D3_QUANT, "@E 9,999,999.999"))+" Kg</b> está fora da tolerância de <strong>empenho</strong> permitida, " + "± " + cValToChar(nPerAceite) + "%.", 1, 0, Nil, Nil, Nil, Nil, Nil,;
                            {"A quantidade do empenho é <b>"+AllTrim(Transform(nQtdMPUti, "@E 9,999,999.999"))+" Kg</b>. Ajuste o empenho antes de prosseguir com o apontamento."})
                            lRet := .F.
                        Endif
                    EndIf

                    If lRet
                        If !lRet
                            DisarmTransaction()
                            lRet := .F.
                        Endif
                    Endif
                End Transaction
            Else
                //-- Quantidade de materia prima usada na OP menos as perda apontadas
                nQtdMPUti := fQtdMPUtiz(SC2->C2_FILIAL, SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN)

                If lRet .And. (ABS( nQtdMPUti/m->D3_QUANT - 1 ) * 100  > nPerAceite .OR. ABS( m->D3_QUANT/nQtdMPUti - 1 ) * 100  > nPerAceite)
                    Help(Nil, Nil, "QTDEMP", Nil, "O peso informado <b>"+AllTrim(Transform(M->D3_QUANT, "@E 9,999,999.999"))+" Kg</b> está fora da tolerância de <strong>empenho</strong> permitida, " + "± " + cValToChar(nPerAceite) + "%.", 1, 0, Nil, Nil, Nil, Nil, Nil,;
                    {"A quantidade do empenho é <b>"+AllTrim(Transform(nQtdMPUti, "@E 9,999,999.999"))+" Kg</b>. Ajuste o empenho antes de prosseguir com o apontamento."})
                    lRet := .F.
                EndIf
            EndIf

            If !SC2->C2_XITOK
                lRet := SC2->C2_XITOK
            EndIf

            If !Empty(aBobina) .And. lRet
                lRet := VldBobSemCorte(aBobina)
            EndIf
        Else
            //--Caso o usuario desejar cancelar apontamento, mudar o C2_XITOK para .F.
            RecLock("SC2", .F.)
                SC2->C2_XITOK := .F.
            SC2->(MsUnlock())
            lRet := .F.
        EndIf
    EndIf

    RestArea(aArea)
 
Return lRet


/*/{Protheus.doc} GetBobina
Funcao responsavel por pegar os codigos de MP
@type function
@version 1.0 
@author Dener Lemos - DOTHINK
@since 10/01/2022
@param cOP, character, Numero da OP
@return array, Array com os codigos das MPs
/*/
Static Function GetBobina(cOP)
    Local cAlias := GetNextAlias()
    Local cQuery := ""
    Local aRet   := {}

    cOP := AllTrim(cOP)

    cQuery += " SELECT SD4.D4_COD, SD4.D4_LOCAL, SD4.D4_LOTECTL, SD4.D4_NUMLOTE, SD4.D4_DTVALID, SD4.D4_QTDEORI, SD4.D4_QUANT, SD4.R_E_C_N_O_ AS REC "
	cQuery += " FROM " + RetSqlName("SD4") + " SD4 "
	cQuery += " WHERE SD4.D4_FILIAL ='" + xFilial("SD4") + "' AND "
	cQuery += " SD4.D4_OP = '" + cOP + "' AND "
    cQuery += " SD4.D4_COD LIKE 'MP%' AND "//-- Foi incluido esse tratamento, pois todas as materias prima tem codigo iniciado com 'MP'
    cQuery += " SD4.D4_QUANT != 0  AND "    
	cQuery += " SD4.D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY SD4.D4_COD "

    cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.T.)

    While (cAlias)->(!Eof())
        aAdd( aRet, { (cAlias)->D4_COD,;                                              //-- 01 - Codigo do produto
                      Posicione('SB1',1,xFilial('SB1')+(cAlias)->D4_COD, 'B1_DESC'),; //-- 02 - Descricao do produto
                      (cAlias)->D4_LOCAL,;                                            //-- 03 - Armazem
                      (cAlias)->D4_LOTECTL,;                                          //-- 04 - Lote
                      (cAlias)->D4_NUMLOTE,;                                          //-- 05 - Sub-lote
                      (cAlias)->D4_DTVALID,;                                          //-- 06 - Data de validade
                      (cAlias)->D4_QTDEORI,;                                          //-- 07 - Quantidade empenhada
                      (cAlias)->D4_QUANT,;                                            //-- 08 - Saldo empenhado
                      (cAlias)->REC } )                                               //-- 09 - Recno

        (cAlias)->( DbSkip() )
    EndDo

    (cAlias)->(DbCloseArea())

Return aRet


/*/{Protheus.doc} fQtdMPUtiz
Retorna a Quantidade de MP/KG de Bobinas utilizadas para OP
@type function
@version 1.0
@author Marcos Aversa - Dothink
@since 08/12/2023
@param cxFil, character, Filial
@param cxOP, character, Ordem de Producao
@return numeric, Quant.MP/KG
/*/
Static Function fQtdMPUtiz( cxFil, cxOP )
    local aArea  := GetArea()
    local cQuery := " "
    local nQtdMP := 0

	cQuery  := " SELECT XX.D4_FILIAL,XX.D4_OP,SUM(XX.D4_QTDEORI) QUANT,SUM(ISNULL(XZ9.Z9_QTDDES,0)) QTDDES "+ CRLF
	cQuery  += " FROM "+ CRLF
	cQuery  += "    (SELECT D4_FILIAL,D4_COD,D4_LOCAL,D4_OP,D4_DATA,D4_LOTECTL,D4_NUMLOTE,D4_QTDEORI "+ CRLF
	cQuery  += "     FROM " + RetSqlName("SD4") + " D4 "+ CRLF
    cQuery  += "     INNER JOIN " + RetSqlName("SB1") + " SB1 "+ CRLF
    cQuery  += "     ON SB1.B1_FILIAL = '"+xFilial("SB1")+"' "+ CRLF
    cQuery  += "     AND SB1.B1_COD = D4_COD "+ CRLF
    cQuery  += "     AND SB1.B1_TIPO = 'MP' "+ CRLF
    cQuery  += "     AND SB1.D_E_L_E_T_ = ' ' "+ CRLF
	cQuery  += "     WHERE D4.D_E_L_E_T_ = ' ' "+ CRLF
	cQuery  += "       AND D4.D4_FILIAL = '" + cxFil + "' "+ CRLF
	cQuery  += "       AND D4.D4_OP  = '" + cxOP + "' "+ CRLF
    // cQuery  += "       AND D4_COD LIKE 'MP%' "+ CRLF
	cQuery  += "     ) XX "+ CRLF
	cQuery  += " LEFT JOIN ( "+ CRLF
	cQuery  += "     SELECT Z9_FILIAL,Z9_OP,Z9_PRODORI,Z9_LOCORI,Z9_LOTORI,Z9_SBLTORI,SUM(Z9_QTDDES) Z9_QTDDES "+ CRLF
	cQuery  += "     FROM " + RetSqlName("SZ9") + " Z9 "+ CRLF
	cQuery  += "     WHERE Z9.D_E_L_E_T_ = ' ' "+ CRLF
	cQuery  += "     AND Z9.Z9_FILIAL = '" + cxFil + "' "+ CRLF
	cQuery  += "     AND Z9.Z9_OP  = '" + cxOP + "' "+ CRLF
	cQuery  += "     GROUP BY Z9_FILIAL,Z9_OP,Z9_PRODORI,Z9_LOCORI,Z9_LOTORI,Z9_SBLTORI "+ CRLF
	cQuery  += "     ) XZ9 "+ CRLF 
	cQuery  += "       ON  XZ9.Z9_FILIAL  = XX.D4_FILIAL "+ CRLF
	cQuery  += "       AND XZ9.Z9_OP      = XX.D4_OP "+ CRLF
	cQuery  += "       AND XZ9.Z9_PRODORI = XX.D4_COD "+ CRLF
	cQuery  += "       AND XZ9.Z9_LOCORI  = XX.D4_LOCAL "+ CRLF
	cQuery  += "       AND XZ9.Z9_LOTORI  = XX.D4_LOTECTL "+ CRLF
	cQuery  += "       AND XZ9.Z9_SBLTORI = XX.D4_NUMLOTE "+ CRLF
	cQuery  += " GROUP BY XX.D4_FILIAL,XX.D4_OP "+ CRLF

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "XMP", .F., .T.)
	If XMP->( !Eof() )
	   nQtdMP := XMP->QUANT - XMP->QTDDES
	Endif
    XMP->(dbCloseArea() )

    RestArea( aArea )

Return nQtdMP


/*/{Protheus.doc} VldBobSemCorte
Rotina que faz as validacoes para setar as bobinas/filmes que nao passaram por processo de corte automaticamente.
E feita a comparacao de das MP usadas com o PA, asim de verificar se tem as mesmas dimencoes.
@type function
@version 1.0
@author DO THINK - DENER LEMOS
@since 07/03/2024
@param aMPs, array, Array com as MPs do empenho
/*/
Static Function VldBobSemCorte(aMPs)
    Local aDimenPA := {}
    Local aDimenMP := {}
    Local aList    := {}
    Local cCodPA   := ""
    Local cDIntPA  := ""
    Local cDExtPA  := ""
    Local cLargPA  := ""
    Local cCodMP   := ""
    Local cDIntMP  := ""
    Local cDExtMP  := ""
    Local cLargMP  := ""
    Local nCount   := 0
    Local lMark    := .F.
    Local lOk      := .F.
    Local nZ       := 0
    Local oOK      := LoadBitmap(GetResources(), "LBOK")
	Local oNO      := LoadBitmap(GetResources(), "LBNO")
    Local oDlg,oBar,oList,oBtnCanc,oBtnConf

    cCodPA   := AllTrim(SubStr(M->D3_COD, 4))
    aDimenPA := u_xGetDimen(cCodPA)
    cDIntPA  := aDimenPA[01]
    cDExtPA  := aDimenPA[02]
    cLargPA  := aDimenPA[03]

    For nZ := 1 To Len(aMPs)
        cCodMP   := AllTrim(SubStr(aMPs[nZ, 01], 3))
        aDimenMP := u_xGetDimen(cCodMP)
        cDIntMP  := aDimenMP[01]
        cDExtMP  := aDimenMP[02]
        cLargMP  := aDimenMP[03]
        lMark    := .F.

        //-- Regra para verificar se a bobina tem o diam. interno e largura iguais
        If (cDIntPA == cDIntMP) .And. (cLargPA == cLargMP)
            lMark := .T.
            nCount++
        EndIf

        //-- Monta lista para marcacao
        aAdd(aList, {lMark, aMPs[nZ, 01], aMPs[nZ, 04], aMPs[nZ, 05], aMPs[nZ, 09]}) 
    Next nZ

    //-- Somente mostra a tela caso exista bobina tem o diam. interno e largura iguais
    If nCount > 0
        //-- Telinha para marcacao das MPs que nao foram cortadas
        DEFINE MSDIALOG oDlg TITLE "Marque MPs não Cortadas" FROM 001, 002 TO 300, 550 PIXEL 
            oBar := TPanel():new(01, 01, "", oDlg, ,.T., , , ,100,25)
            oBar:Align := CONTROL_ALIGN_BOTTOM
            
            oList := TCBrowse():new(000,000,277,125,,{"", "Materia Prima", "Lote", "Sub-lote"},{015, 100, 070, 060},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,,) 
            oList:setArray(aList) 
            oList:bLine        := {|| {If(aList[oList:nAt,01], oOK, oNO), aList[oList:nAt,02], aList[oList:nAt,03], aList[oList:nAt,04]}} 
            oList:bLDblClick   := {|| aList[oList:nAt][1] := !aList[oList:nAt][1], oList:refresh()}
            oList:bHeaderClick := {|oBrw,nCol| IIf(nCol == 1, (aEval(aList, {|a,n| aList[n, 1] := !aList[n,1]}), oList:refresh()), Nil)}

            @ 004,165 BUTTON oBtnCanc PROMPT "Cancelar"  SIZE 50,14 ACTION oDlg:End() OF oBar PIXEL
            @ 004,220 BUTTON oBtnConf PROMPT "Confirmar" SIZE 50,14 ACTION {|| lOk := VldMark(aList), IIf(lOk,oDlg:end(),oDlg)} OF oBar PIXEL
        ACTIVATE MSDIALOG oDlg CENTERED

        If lOk
            For nZ := 1 To Len(aList)
                If aList[nZ, 01]
                    //-- Seta bobina sem corte
                    SetBobSemCorte(aList[nZ, 05])
                EndIf
            Next nZ
        EndIf
    Else
        lOk := .T.
    EndIf

Return lOk


/*/{Protheus.doc} VldMark
Rotina de validacao da marcacao da MPs nao cortadas
@type function
@version 1.0
@author DO THINK - DENER LEMOS
@since 08/03/2024
@param aList, array, Array com as MPs 
@return logical, Retorno logico
/*/
Static Function VldMark(aList)
    Local nI     := 0
    Local cCount := 0
    Local lRet   := .T.

    For nI := 1 To Len(aList)
        If aList[nI, 01]
            cCount++
        EndIf
    Next nI

    If Empty(cCount) .And. Aviso("Marcação Vazia!", "Deseja realmente prosseguir sem a marcar MPs não cortadas?", {"Sim","Não"}) == 2
        lRet := .F.
    EndIf

Return lRet


/*/{Protheus.doc} SetBobSemCorte
Rotina que seta a bobina/filme que nao passou por processo de corte em campo especifico da SD4
@type function
@version 1.0
@author DO THINK - DENER LEMOS
@since 07/03/2024
@param cRecnoSD4, character, Recno da tabela SD4
/*/
Static Function SetBobSemCorte(cRecnoSD4)
    Local aAreaAnt := GetArea()
    Local aAreaSD4 := SD4->(GetArea())

    dbSelectArea("SD4")
    SD4->(dbGoTo(cRecnoSD4))

    RecLock("SD4", .F.)
        SD4->D4_XBOBSCT := "S"
    SD4->(MsUnlock())

    RestArea(aAreaAnt)
    RestArea(aAreaSD4)

Return


//--
Static Function VldJaApto()
    Local cQuery   := ""
	Local cFilDest := GetMV("RE_FILDEST", .F., "0201")
    Local lRet     := .T.

    If Select("_QRY") > 0
        _QRY->(dbCloseArea())
    EndIf

    cQuery := " SELECT COUNT(*) D3_APTO "
    cQuery += " FROM " + RetSQLName("SD3") + " SD3 "
    cQuery += " WHERE D3_FILIAL = '" + cFilDest + "' "
    cQuery += " AND SD3.D3_OP = '" + M->D3_OP + "   ' "
    cQuery += " AND SD3.D3_CF = 'PR0' "
    cQuery += " AND SD3.D3_ESTORNO = ' ' "
    cQuery += " AND SD3.D_E_L_E_T_ = ' ' "

    cQuery := ChangeQuery(cQuery)
    TCQUERY cQuery New Alias "_QRY"

    _QRY->(dbGoTop())
    If _QRY->(!EoF()) .And. _QRY->D3_APTO > 0
        Help(Nil, Nil, "JAAPTO", Nil, "Ordem de produção já apontada.", 1, 0, Nil, Nil, Nil, Nil, Nil,;
        {"Estorne o apontamento existente e tente novamente."})       

        lRet := .F.
    EndIf

    If Select("_QRY") > 0
        _QRY->(dbCloseArea())
    EndIf

Return lRet
