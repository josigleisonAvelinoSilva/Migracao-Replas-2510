#INCLUDE "PROTHEUS.CH"


/*/{Protheus.doc} REESTA07
Rotina que traduz de codigos da MM Manaus e Innova para codigos da Replas SP
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 17/07/2022
@param cCodFor, character, Codigo fornecedor
@param cCGCFor, character, CNPJ fornecedor
@obs Projeto Novo PCP
/*/
User Function REESTA07(cCodFor, cCGCFor)
    Local aAreaAnt := GetArea()
    Local aAreaSZ5 := SZ5->( GetArea() )
    
    Default cCodFor := ""
    Default cCGCFor := ""

    //-- Traduz produtos com base no Codigo do produto e CNPJ do fornecedor
    TraduzCod(cCodFor, cCGCFor)

    RestArea( aAreaSZ5 )
    RestArea( aAreaAnt )

Return


/*/{Protheus.doc} TraduzCod
Funcao que realiza a traducao de codigos da da MM Manaus e Innova
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 17/07/2022
@param cCodFor, character, Codigo fornecedor
@param cCGCFor, character, CNPJ fornecedor
/*/
Static Function TraduzCod(cCodFor, cCGCFor)
    Local cQuery  := ""
    Local cCGCMMM := GetMV( "RE_CGCMMM", .F., "21338912000148" ) //-- CNPJ da INDUSTRIA MM Manaus
    Local cCGCINM := GetMV( "RE_CGCINM", .F., "04229761000170" ) //-- CNPJ da INNOVA Manaus

    //-- Query para filtrar os produtos
    cQuery := " SELECT " + CRLF
    cQuery += "     SZ5.*, SZ5.R_E_C_N_O_ AS SZ5REC " + CRLF
    cQuery += " FROM " + CRLF
    cQuery += "     " + RetSqlName("SZ5") + " SZ5 " + CRLF
    cQuery += " WHERE " + CRLF
    cQuery += "     SZ5.Z5_FILIAL = '" + xFilial("SZ5") + "' " + CRLF
    cQuery += "     AND SZ5.Z5_CODPRD = ' ' " + CRLF
    If !Empty(cCodFor) .And. !Empty(cCGCFor)
        cQuery += "     AND SZ5.Z5_CODFOR = '" + cCodFor + "' " + CRLF
        cQuery += "     AND SZ5.Z5_CGCFOR = '" + cCGCFor + "' " + CRLF
    EndIf
    cQuery += "     AND SZ5.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += " ORDER BY SZ5.Z5_CODFOR, SZ5.Z5_CGCFOR " + CRLF

	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "_TMP", .F., .T. )

    While _TMP->( !Eof() )
        //-- Reinicia variaveis de validacao
        cMontMod  := ""
        lVldDigit := .T.

        If _TMP->Z5_CGCFOR == cCGCMMM
            //-- Monta o codigo de produto da REPLAS
            cCodReplas := U_REESTA7A(_TMP->Z5_MODELO, _TMP->Z5_DIAINT, _TMP->Z5_DIAEXT, _TMP->Z5_LARGURA)

            SZ5->( DbGoTo( _TMP->SZ5REC ) )
            RecLock( "SZ5", .F. )
                SZ5->Z5_CODPRD  := cCodReplas
            SZ5->( MsUnLock() )
        ElseIf _TMP->Z5_CGCFOR == cCGCINM
            //-- Traduz os codigos da INNOVA Manaus
            
        EndIf

        _TMP->( DbSkip() )
    EndDo

    _TMP->( DbCloseArea() )

Return


/*/{Protheus.doc} REESTA7A
Rotina que faz a traducao do codigo da INDUSTRIA MM MANAUS 
para o codigo interno da REPLAS SAO PAULO
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 17/07/2022
@param cModelo, character, Modelos
@param nDiamInt, numeric, Diametro interno
@param nDiamExt, numeric, Diametro externo
@param nLargura, numeric, Largura
@return character, Retorna codigo Replas
/*/
User Function REESTA7A(cModelo, nDiamInt, nDiamExt, nLargura)
    Local cBuffer   := AllTrim( cModelo )
    Local cByte     := ""
    Local cMontMod  := ""
    Local cRet      := ""
    Local nI        := 0
    Local lVldDigit := .T.

    For nI := 1 To Len( cBuffer )
        cByte := SubStr( cBuffer, nI, 1 )

        If lVldDigit .And. IsDigit( cByte )
            lVldDigit := !IsAlpha( SubStr( cBuffer, nI+1, 1 ) )
            Loop
        EndIf

        //-- Modelo de codigo da Replas
        cMontMod += UPPER( cByte ) 
    Next nI

    /*Tratamento para limitar o "Diametro Externo" em no maximo 700 mm.
    Solicitado pelo Jose e pelo Ricardo n dia 21/07/2022. 
    O diametro externo com no maximo 700 mm e o padrao do processo.*/
    /*If nDiamExt > 700
        nDiamExt := 700
    EndIf*/

    //-- Monta o codigo de produto da REPLAS
    cRet := "MP" + cMontMod + StrZero( nDiamInt, 2 ) + StrZero( nDiamExt, 3 ) + StrZero( nLargura, 4 )

Return cRet


/*/{Protheus.doc} REESTA7B
Rotina que faz a traducao do codigo da INNOVA MANAUS
para o codigo interno da REPLAS SAO PAULO
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 17/07/2022
@param cEtiqueta, character, Etiqueta Innova
@return character, Retorna codigo Replas
/*/
User Function REESTA7B(cEtiqueta)
    Local cBuffer   := AllTrim( cEtiqueta )
    Local cByte     := ""
    Local cMontMod  := ""
    Local cDiamInt  := ""
    Local cDiamExt  := ""
    Local cLargura  := ""
    Local cRet      := ""
    Local nI        := 0

    cDiamInt := SubStr( cBuffer, 15, 01 )
    cDiamExt := SubStr( cBuffer, 16, 04 )
    cLargura := SubStr( cBuffer, 11, 04 )

    For nI := 1 To Len( cBuffer )
        cByte := SubStr( cBuffer, nI, 1 )

        If IsDigit( cByte )
            Loop
        Else
            //-- Modelo de codigo da REPLAS
            cMontMod := UPPER( SubStr( cBuffer, nI+1 ) )
            Exit
        EndIf
    Next nI

    /*Tratamento para limitar o "Diametro Externo" em no maximo 700 mm.
    Solicitado pelo Jose e pelo Ricardo n dia 21/07/2022. 
    O diametro externo com no maximo 700 mm e o padrao do processo.*/
    /*If Val(cDiamExt) > 700
        cDiamExt := "700"
    EndIf*/

    //-- Monta o codigo de produto da REPLAS
    cRet := "MP" + AllTrim( cMontMod ) + StrZero( Val( cDiamInt ), 2 ) + StrZero( Val( cDiamExt ), 3 ) + StrZero( Val( cLargura ), 4 )

Return cRet


/*/{Protheus.doc} REESTA7C
Funcao que busca codigo da Replas SP
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 17/07/2022
@param cCodFor, character, Codigo fornecedor
@param cCGCFor, character, CNPJ fornecedor
@return character, Retorna codigo Replas
/*/
User Function REESTA7C(cCodFor, cCGCFor, nCodProd)
    Local aAreaAnt := GetArea()
    Local cRet     := ""

    Default nCodProd := 1

    DbSelectArea("SZ5")
    SZ5->( DbSetOrder(3) ) //-- Z5_FILIAL+Z5_CODFOR+Z5_CGCFOR  
    If SZ5->( DbSeek( xFilial("SZ5") + PadR(cCodFor, TamSX3("Z5_CODFOR")[1]) + PadR(cCGCFor, TamSX3("Z5_CGCFOR")[1]) ) )
        If nCodProd == 1
            cRet := SZ5->Z5_CODPRD
        Else
            cRet := SZ5->Z5_CODPRD2
        EndIf
    EndIf
    
    RestArea( aAreaAnt )

Return cRet











