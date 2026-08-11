#include "totvs.ch"
#include "apvt100.ch"


/*/{Protheus.doc} cbinvval
Ponto de entrada que e executado dentro da validacao da etiqueta de produtos, 
retornando um valor logico .T. para continuar a validacao padrao ou .F. para abortar a validacao
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 08/12/2023
@return logical, Retorno logico
/*/
User Function cbinvval()
    Local aAreaAnt := GetArea()
    Local aAreaCBB := CBB->(GetArea())
    Local aAreaCBC := CBC->(GetArea())
    Local cAlias   := GetNextAlias()
    Local cQuery   := ""
    Local cProduto := ""
    Local lRet     := .T.

    If lModelo1
        cProduto := u_CbGetReadN()[01]

        If u_xIsFilme(cProduto) .And. u_xIsMP(cProduto) //.And. CBA->CBA_CONTS == 1
            //-- Consulta
            cQuery := " SELECT "
            cQuery += "     CBC.CBC_CODINV, CBB.CBB_USU "
            cQuery += " FROM " + RetSqlName("CBC") + " CBC "
            cQuery += "     INNER JOIN " + RetSqlName("CBB") + " CBB "
            cQuery += "     ON CBB.CBB_FILIAL = '" + xFilial("CBB") + "' "
            cQuery += "     AND CBB.CBB_CODINV = CBC.CBC_CODINV "
            cQuery += "     AND CBB.CBB_NUM = CBC.CBC_NUM "
            cQuery += "     AND CBB.D_E_L_E_T_ = ' ' "
            cQuery += " WHERE "
            cQuery += "     CBC.CBC_FILIAL = '" + xFilial("CBC") + "' "
            cQuery += "     AND CBC.CBC_COD = '" + cProduto + "' "
            cQuery += "     AND CBC.CBC_LOCAL = '" + cArmazem + "' "
            cQuery += "     AND CBC.CBC_LOTECT = '" + cLote + "' "
            cQuery += "     AND CBC.CBC_NUMLOT = '" + cSLote + "' "
            cQuery += "     AND CBC.CBC_QUANT > 0 "
            cQuery += "     AND CBC.D_E_L_E_T_ = ' ' "

            cQuery := ChangeQuery(cQuery)
            DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.T.)

            While (cAlias)->(!EoF())
                //-- Valida se o operador ja contou a bobina
                If (cAlias)->CBB_USU == cCodOpe
                    VTBeep(3)
                    VTAlert("Bobina ja contada", "Aviso", .t., 4000)
                    VTKeyBoard(chr(20))

                    lRet := .F.
                    Exit
                EndIf

                (cAlias)->(dbSkip())
            EndDo

            If Select(cAlias) > 0
                (cAlias)->(dbCloseArea())
            EndIf
        EndIf
    EndIf

    RestArea(aAreaCBC)
    RestArea(aAreaCBB)
    RestArea(aAreaAnt)

Return lRet
