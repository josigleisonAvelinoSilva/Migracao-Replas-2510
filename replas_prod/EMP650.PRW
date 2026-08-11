#INCLUDE "PROTHEUS.CH"


/*/{Protheus.doc} EMP650
Ponto de Entrada permite edicao de itens Empenhados na Abertura da OP
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 29/04/2022
/*/
User Function EMP650()
    //Local cStrOpc  := ParamIXB[01]
    Local aPergSgt := GetPergSgt()
    Local cFilOrig := GetMV( "RE_FILORIG", .F., "0302" )
    Local cFilDest := GetMV( "RE_FILDEST", .F., "0201" )
    Local lSgtBob  := GetMV("RE_SGTBOB", .F., .T.)

    If ( IsInCallStack("MATA650C") .And. cFilAnt $ cFilDest .And. lSgtBob .And. aPergSgt[01] == 1 ) .Or.;
       ( IsInCallStack("U_REFATA06") .And. cFilAnt $ cFilOrig )

        U_REPCPA08()
    EndIf

Return


/*/{Protheus.doc} GetPergSgt
Funcao que carrega o conteudo das perguntas
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 01/05/2022
@return array, Array com conteudo da pergunta
/*/
Static Function GetPergSgt()
    Local aMvPar := {}
    Local aRet   := {}
    Local nI, nX := 0

    //-- No inicio, guarda o conteudo dos parametros MV_PAR
    For nX := 1 To 10
        aAdd( aMvPar, &( "MV_PAR" + StrZero( nX, 2, 0 ) ) )
    Next nX

    //-- Pega o conteudo das perguntas do usuario
	Pergunte("REPCPA7P", .F.)
	For nI := 1 To 5
        aAdd( aRet, &( "MV_PAR" + StrZero(nI, 2) ) )
	Next nI

    //-- No final, retorna conteudo dos parametros MV_PAR
    For nX := 1 To Len(aMvPar)
        &( "MV_PAR" + StrZero( nX, 2, 0 ) ) := aMvPar[nX]
    Next nX

Return aClone(aRet)
