#INCLUDE "PROTHEUS.CH"


/*/{Protheus.doc} REFATA03
Funcao que retorna o Pedido de Venda Remoto, se o mesmo existir
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 17/05/2022
@param cFil, character, Filial
@param cPV, character, Pedido
@return array, Array que indica se existe
@obs Projeto Novo PCP
/*/
User Function REFATA03( cFil, cPV )
	Local aArea    := GetArea()
    Local aRet     := {}
    Local cFilOrig := GetMV( "RE_FILORIG", .F., "0302" )
    Local cFilDest := GetMV( "RE_FILDEST", .F., "0201" )
	Local cQuery   := ""

    cQuery := " SELECT " + CRLF
    cQuery += "     SC5.C5_FILIAL, SC5.C5_NUM " + CRLF  
    cQuery += " FROM " + CRLF
    cQuery += "     " + RetSqlName("SC5") + " SC5 " + CRLF
    cQuery += " WHERE " + CRLF
    If cFil == cFilOrig
        cQuery += "     SC5.C5_FILIAL = '" + cFilDest + "' " + CRLF
        cQuery += "     AND SC5.C5_XFILORI = '" + cFil + "' " + CRLF
        cQuery += "     AND SC5.C5_XPVORIG = '" + cPV + "' " + CRLF
    ElseIf cFil == cFilDest
        cQuery += "     SC5.C5_FILIAL = '" + cFilOrig + "' " + CRLF
        cQuery += "     AND SC5.C5_XFILDES = '" + cFil + "' " + CRLF
        cQuery += "     AND SC5.C5_XPVDEST = '" + cPV + "' " + CRLF
    EndIf
    cQuery += "     AND SC5.D_E_L_E_T_ = ' ' " + CRLF

	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "_XFIL", .F., .T. )

	If _XFIL->( !Eof() )
		aAdd( aRet, .T. )
		aAdd( aRet, _XFIL->C5_FILIAL)
		aAdd( aRet, _XFIL->C5_NUM)
	Else
		aAdd( aRet, .F. )
		aAdd( aRet, "" )
		aAdd( aRet, "" )
	Endif

	_XFIL->( DbCloseArea() )

	RestArea( aArea )

Return aClone( aRet )
