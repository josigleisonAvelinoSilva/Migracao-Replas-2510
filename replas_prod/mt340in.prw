#include "totvs.ch"


//--
User Function mt340in()
    Local lRet := .T.

    If IsInCallStack("ACDA030")
        lRet := VldCBCXSB7()
    EndIf

Return lRet


//--
Static Function VldCBCXSB7()
    Local aDados   := {}
    Local cQuery   := ""
    Local cLoteCBC := ""
    Local cSLotCBC := ""
    Local cLoteSB7 := ""
    Local cSLotSB7 := ""
    Local nZ       := 0
    Local lDiff    := .F.

    //-- Query
    cQuery := " SELECT " + CRLF
    cQuery += "     CBC.CBC_CODINV, CBC.CBC_COD, CBC.CBC_LOCAL, CBC.CBC_QUANT, CBC.CBC_LOTECT, " + CRLF
    cQuery += "     CBC.CBC_NUMLOT, SB7.B7_QUANT, SB7.B7_LOTECTL, SB7.B7_NUMLOTE " + CRLF
    cQuery += " FROM " + CRLF
    cQuery += "     " + RetSQLName("CBC") + " CBC " + CRLF
    cQuery += "     LEFT JOIN " + RetSqlName("SB7") + " SB7 " + CRLF
    cQuery += "     ON " + RetSQLCond("SB7") + CRLF
    cQuery += "     AND SB7.B7_LOTECTL = CBC.CBC_LOTECT " + CRLF
    cQuery += "     AND SB7.B7_NUMLOTE = CBC.CBC_NUMLOT " + CRLF
    cQuery += " WHERE " + CRLF
    cQuery += "     " + RetSQLCond("CBC") + CRLF
    cQuery += "     AND CBC.CBC_CODINV = '" + CBA->CBA_CODINV + "' " + CRLF

    aDados := QryArray(cQuery)

    For nZ := 1 To Len(aDados)
        If Rastro(aDados[nZ, 02])
            //-- CBC
            cLoteCBC := aDados[nZ, 05]
            cSLotCBC := aDados[nZ, 06]

            //-- SB7
            cLoteSB7 := aDados[nZ, 08]
            cSLotSB7 := aDados[nZ, 09]

            If (cLoteCBC + cSLotCBC) <> (cLoteSB7 + cSLotSB7)
                lDiff := .T.
                Exit
            EndIf
        EndIf
    Next nZ

    If lDiff
        Aviso("Atenção!", "O inventário [" + AllTrim(CBA->CBA_CODINV) + "] está com desbalanceamento entre as tabelas de contagens CBC e SB7 respectivamente. " + ;
        "Será gerado uma planilha excel automaticamente para analise e correção do desbalanceamente, faça os ajustes atráves da rotina [Inventário], ou procure o Administrador do sistema." + Chr(10) + Chr(13) + Chr(10) + Chr(13) + ;
        "Essa mensagem será fechada em 5 segundos.", {"OK"}, 2, "Desbalanceamento de Inventário",,,, 5000)

        //-- Query para excel
        u_xQry2Excel(cQuery, "Desbalanceamento de Inventário")
    EndIf

Return !lDiff
