#include "totvs.ch"


/*/{Protheus.doc} cbinvfim
Ponto de Entrada que e executado ao finalizar um contagem pelo coletor de dados
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 17/05/2024
@return logical, Retorno logico
@obs Esse ponto de entrada foi criado para fazer um tratamento especifico na contagem
de "Filmes" pois na contagem desse tipo de produto, e acerto um inventario com somente
umm contagem e o sistema so considera a primeira contagem quando vai gerar o SB7.
/*/
User Function cbinvfim()
    Local aAreaAnt  := GetArea()
    Local aAreaCBC  := CBC->(GetArea())
    Local cAlias    := GetNextAlias()
    Local cQuery    := ""
    Local cProduto  := ""
    Local cContagem := ""
    Local cNumOri   := ""
    Local nQuant    := 0
    Local nQtdOri   := 0
    Local lRet      := .T.

    If lModelo1
        cProduto := CBA->CBA_PROD

        /*O tratamento abaixo serve para consolidar as contagens dos filmes somente da 
        primeira contagem realizada, ou no primeiro registro do campo CBC_NUM.*/
        If u_xIsFilme(cProduto) .And. u_xIsMP(cProduto) .And. CBA->CBA_CONTS == 1
            If IsTelNet()
                VTClear()
                VTMsg("Consolidando Contagens...")
            EndIf

            //-- Consulta para consolidar as contagens
            cQuery := " SELECT "
            cQuery += "     CBC_NUM,CBC_COD,CBC_LOCAL,CBC_LOCALI, "
            cQuery += "     CBC_LOTECT,CBC_NUMLOT,CBC_QUANT,CBC_QTDORI,R_E_C_N_O_ AS REC "
            cQuery += " FROM "
            cQuery += "     " + RetSqlName("CBC") + " CBC "
            cQuery += " WHERE "
            cQuery += "     CBC.CBC_FILIAL = '" + xFilial("CBC") + "' "
            cQuery += "     AND CBC_CODINV = '" + CBA->CBA_CODINV + "' "
            cQuery += "     AND CBC.D_E_L_E_T_ = ' ' "
            cQuery += " GROUP BY CBC_NUM,CBC_COD,CBC_LOCAL,CBC_LOCALI,CBC_LOTECT,CBC_NUMLOT,CBC_QUANT,CBC_QTDORI,R_E_C_N_O_ "
            cQuery += " HAVING SUM(CBC_QUANT) > 0 "
            cQuery += " ORDER BY CBC_NUM, CBC_LOTECT, CBC_NUMLOT "

            cQuery := ChangeQuery(cQuery)
            dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.T.)

            (cAlias)->(dbGoTop())
            While (cAlias)->(!EoF())
                //-- Pega codigo da primeira contagem
                If Empty(cContagem)
                    cContagem := (cAlias)->CBC_NUM
                EndIf

                If (cAlias)->CBC_NUM != cContagem
                    cNumOri := (cAlias)->CBC_NUM
                    nQuant  := (cAlias)->CBC_QUANT
                    nQtdOri := (cAlias)->CBC_QTDORI

                    CBC->(dbSetOrder(2)) //-- CBC_FILIAL+CBC_NUM+CBC_COD+CBC_LOCAL+CBC_LOCALI+CBC_LOTECT+CBC_NUMLOT+CBC_NUMSER+CBC_IDUNIT
                    If CBC->(dbSeek(xFilial("CBC") + cContagem + (cAlias)->(CBC_COD+CBC_LOCAL+CBC_LOCALI+CBC_LOTECT+CBC_NUMLOT)))
                        //-- Posiciona na primeiro contagem e informa as quantidades
                        RecLock("CBC", .F.)
                            CBC->CBC_QUANT  := nQuant
                            CBC->CBC_QTDORI := nQtdOri
                            If CBC->(FieldPos("CBC_XNUMOR")) > 0
                                CBC->CBC_XNUMOR := cNumOri
                            EndIf
                        CBC->(MsUnLock())

                        //-- Posiciona na contagem original e zera as quantidades
                        CBC->(dbGoTo((cAlias)->REC))
                        RecLock("CBC", .F.)
                            CBC->CBC_QUANT  := 0
                            CBC->CBC_QTDORI := 0
                        CBC->(MsUnLock())
                    EndIf
                EndIf

                (cAlias)->(dbSkip())
            EndDo

            If Select(cAlias) > 0
                (cAlias)->(dbCloseArea())
            EndIf
        EndIf
    EndIf

    RestArea(aAreaCBC)
    RestArea(aAreaAnt)

Return lRet
