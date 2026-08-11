#INCLUDE "PROTHEUS.CH"


/*/{Protheus.doc} MTA650MNU
Ponto de entrada permite adicinar botoes ao menu principal na rotina de Recursos
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 29/04/2022
/*/
User Function MTA650MNU()
    //Local cFilOrig := GetMV( "RE_FILORIG", .F., "0302" )
    Local cFilDest := GetMV( "RE_FILDEST", .F., "0201" )

    If cFilAnt $ cFilDest
        aAdd( aRotina, { "Relatorio OP", "U_REPCPR02()", 0 , 3, 0, Nil } ) 
        aAdd( aRotina, { "Imp.Etiq.Retorno", "U_fImpEtqRet(  SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN )", 0 , 3, 0, Nil } ) 
    EndIf

Return

User Function fImpEtqRet( cxOp )
    local lExisteRet := .F.

    lExisteRet := fVerSZ9( cxOp )
    
    If !lExisteRet
         FWAlertInfo( "Nao Existe Retorno para essa OP !!!", "OP")	
         Return
    Endif

    If FwAlertYesNo( "Imprime Etiquetas de Retorno ? ", "Etiquetas")
       If Pergunte("REPCPA1P", .T.)
            U_EtiqSZ9( cxOp )
       Endif
    Endif

Return()

Static Function fVerSZ9( cxOp )
    local lRet   := .F.
    local cQuery := ""

    cQuery := " SELECT *  " + CRLF
    cQuery += " FROM " + RetSqlName("SZ9") + " Z9 " + CRLF
    cQuery += " WHERE Z9.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += " AND Z9.Z9_FILIAL = '" + xFilial("SC2") + "' " + CRLF
    cQuery += " AND Z9.Z9_OP = '" + cxOp + "' " + CRLF
    cQuery += " AND Z9.Z9_LOCDES = '01' " + CRLF
    cQuery += " AND Z9.Z9_LOTORI != ' ' " + CRLF

    DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "XSZ9", .F., .T. )

    If XSZ9->( !Eof())
       lRet := .T.
    Endif

    XSZ9->( dbCloseArea() )    

Return lRet
