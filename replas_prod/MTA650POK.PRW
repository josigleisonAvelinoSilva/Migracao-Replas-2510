#INCLUDE "PROTHEUS.CH"


/*/{Protheus.doc} MTA650POK
Ponto de entrada permite validar Itens do Pedido de Vendas
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 29/04/2022
@return logical, Retorno logico
/*/
User Function MTA650POK()                             
    Local _cAlias   := ParamIXB[1]       
    Local _cMarca   := ParamIXB[2]
    Local aPergSgt  := GetPergSgt()
    //Local cFilOrig  := GetMV( "RE_FILORIG", .F., "0302" )
    Local cFilDest  := GetMV( "RE_FILDEST", .F., "0201" )
    Local lSgtBob   := GetMV( "RE_SGTBOB", .F., .T. )
    Local lIntIndMM := GetMV( "RE_INTIND", .F., .T. ) //-- Parametro geral que indica se a integracao de pedidos com a industria mm (Filial 0201) esta ativa
    Local _lRet     := .T.

    //-- Faz parte do processo atual do MOTOR e serve para inclusao de estrutura de produtos antes da aberutra da OP
    If ExistBlock('RPMONTASG1') .And. GetMV('RP_XMOTOR',.F.,.T.)
        _lRet := ExecBlock("RPMONTASG1",.F.,.F.,{_cAlias,_cMarca})
    EndIf

    //-- Faz parte no novo processo do PCP
    If lSgtBob .And. lIntIndMM .And. cFilAnt $ cFilDest .And. aPergSgt[01] == 1  
        _lRet := U_REPCPA07(_cAlias, _cMarca, aPergSgt)
    EndIf

Return _lRet


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

