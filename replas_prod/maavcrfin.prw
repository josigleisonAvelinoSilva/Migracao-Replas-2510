#include "totvs.ch"


/*/{Protheus.doc} maavcrfin
Ponto de Entrada que faz a substituicao da query da avaliacao de credito financeiro do Cliente
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 21/03/2024
@return character, Nova query
/*/
User Function maavcrfin()
    Local cQuery     := ParamIxb[01]
    Local cCodCli    := ParamIxb[02]
    Local cSepNeg    := If("|"$MV_CRNEG,"|",",")
    Local cSepProv   := If("|"$MVPROVIS,"|",",")
    Local cSepRec    := If("|"$MVRECANT,"|",",")
    Local cFilialFat := GetMv("MV_XFILFAT")

    //-- Query sem "Filail" e sem "Loja" para considerar os titulos de todas as empresas
    cQuery := " SELECT "
    cQuery += "     MIN(SE1.E1_VENCREA) VENCREAL "
    cQuery += " FROM "
    cQuery += "     " + RetSqlName("SE1") + " SE1 "
    cQuery += " WHERE "
    cQuery += "     SE1.E1_FILIAL IN " + FormatIn(cFilialFat, ";") + " "
    cQuery += "     AND SE1.E1_CLIENTE = '" + cCodCli + "' "
    cQuery += "     AND SE1.E1_STATUS = 'A' "
    If !(cCodCli $ "06083686/")
        //-- Excecao para o Cliente "Lira Flex". Essa excecao foi solicitada pelo Silvio no dia 12/07/2024
        cQuery += "     AND SE1.E1_TIPO <> 'ADV' "
    EndIf
    cQuery += "     AND SE1.E1_TIPO NOT IN " + FormatIn(MVABATIM, "|") + " "
    cQuery += "     AND SE1.E1_TIPO NOT IN " + FormatIn(MV_CRNEG, cSepNeg) + " "
    cQuery += "     AND SE1.E1_TIPO NOT IN " + FormatIn(MVPROVIS, cSepProv) + " "
    cQuery += "     AND SE1.E1_TIPO NOT IN " + FormatIn(MVRECANT, cSepRec) + " "
    cQuery += "     AND SE1.D_E_L_E_T_ = ' ' "

    cQuery := ChangeQuery(cQuery)

Return cQuery
