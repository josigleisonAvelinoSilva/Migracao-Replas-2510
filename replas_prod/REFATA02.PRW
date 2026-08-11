#INCLUDE "PROTHEUS.CH"


/*/{Protheus.doc} REFATA02
Rotina generica de verificacao de condicoes para o pedido destino, com retorno logico
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 11/05/2022
@param nOpc, numeric, Numero opcao
@param xCont, variant, Conteudo da opcao
@return logical, Retorno logico
@obs Projeto Novo PCP
@history 08/12/2023, DO THINK - DENER LEMOS, Alteracao de algumas funcoes de Static para User function, para ser chamada de outros locais.
Tambem foi criado um novo arquivo chamado "rpsxfun.prw", e essas nova User function foram passadas para esse arquivo, "u_xIsFilme()", "u_xIsPA()" e "u_xIsMP()"
/*/
User Function REFATA02( nOpc, xCont )
    Local lRet

    Do Case
        Case nOpc == 1
            lRet := u_xIsFilme( xCont )
        Case nOpc == 2
            lRet := ExtFilmSC6( xCont )
        Case nOpc == 3
            lRet := u_xIsPA( xCont )
        Case nOpc == 4
            lRet := u_xIsMP( xCont )
		Case nOpc == 5
			lRet := ExtFilmSD1( xCont )
    EndCase

Return lRet


/*/{Protheus.doc} ExtFilmSC6
Verifica se existe FILME/BOPP no pedido de venda
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 11/05/2022
@param cPedido, character, Numero pedido
@return logical, Retorno logico
/*/
Static Function ExtFilmSC6( cPedido )
    Local aArea  := GetArea()
    Local cQuery := ""
	Local nProd  := ""
	Local nX     := 0
    Local lRet   := .F.

    cQuery := " SELECT " + CRLF
    cQuery += "     COUNT(SB1.B1_XGRUPO) AS QTD " + CRLF
    cQuery += " FROM " + CRLF
    cQuery += "     " + RetSqlName("SC6") + " SC6 " + CRLF
    cQuery += "     INNER JOIN " + RetSqlName("SB1") + " SB1 ON " + CRLF
    cQuery += "     SB1.B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
    cQuery += "     AND SB1.B1_COD = SC6.C6_PRODUTO " + CRLF
    cQuery += "     AND SB1.B1_XGRUPO = '1' " + CRLF
    cQuery += "     AND SB1.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += " WHERE " + CRLF
    cQuery += "     SC6.C6_FILIAL = '" + xFilial("SC6") + "' " + CRLF
    cQuery += "     AND SC6.C6_NUM = '" + cPedido + "' " + CRLF
    cQuery += "     AND SC6.D_E_L_E_T_ = ' ' " + CRLF

	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "_BOPP", .F., .T. )

	lRet := _BOPP->( !Eof() ) .And. _BOPP->QTD > 0 
    
	_BOPP->( DbCloseArea() )

	//-- Verifica se no aCols existe Filmes 
	If !lRet .And.;
	   Type("aHeader") == "A" .And. !Empty(aHeader) .And.;
	   Type("aCols") == "A" .And. !Empty(aCols)

		nProd := aScan( aHeader, {|x| AllTrim(x[02]) == "C6_PRODUTO" } )
	   
		For nX := 1 To Len(aCols)
			If U_REFATA02(1, aCols[nX, nProd])
				lRet := .T.
				Exit
			EndIf
		Next nX	
	EndIf 

	RestArea( aArea )

Return lRet


/*/{Protheus.doc} ExtFilmSD1
Verifica se existe FILME/BOPP no documento de entrada
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 30/05/2022
@param cDocSerie, character, Numero da NF + Serie
@return logical, Retorno logico
/*/
Static Function ExtFilmSD1( cDocSerie )
    Local aArea  := GetArea()
    Local cQuery := ""
    Local lRet   := .F.

	cQuery := " SELECT " + CRLF
	cQuery += " 	COUNT(SB1.B1_XGRUPO) AS QTD " + CRLF
	cQuery += " FROM " + CRLF
	cQuery += " 	" + RetSqlName("SD1") + " SD1 " + CRLF
	cQuery += " 	INNER JOIN " + RetSqlName("SB1") + " SB1 ON " + CRLF
	cQuery += " 	SB1.B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
	cQuery += " 	AND SB1.B1_COD = SD1.D1_COD " + CRLF
	cQuery += " 	AND SB1.B1_XGRUPO = '1' " + CRLF
	cQuery += " 	AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += " WHERE " + CRLF
	cQuery += " 	SD1.D1_FILIAL = '" + xFilial("SD1") + "' " + CRLF
	cQuery += " 	AND SD1.D1_DOC + SD1.D1_SERIE = '" + cDocSerie + "' " + CRLF
	cQuery += " 	AND SD1.D_E_L_E_T_ = ' ' " + CRLF

	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "_FILM", .F., .T. )

	lRet := _FILM->( !Eof() ) .And. _FILM->QTD > 0 
    
	_FILM->( DbCloseArea() )

	RestArea( aArea )

Return lRet
