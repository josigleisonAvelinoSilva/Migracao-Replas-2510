#INCLUDE "PROTHEUS.CH"


/*/{Protheus.doc} A200GRVE
Ponto de Entrada chamado na confirmacao de dados da Estrutura,
nas transacoes de Visualizacao, Inclusao, Alteracao e Exclusao
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 27/06/2022
@obs Projeto Novo PCP
/*/
User Function A200GRVE()
    Local nOpcX    := ParamIXB[01]
    Local cFilOrig := GetMV( "RE_FILORIG", .F., "0302" )
    //Local cFilDest := GetMV( "RE_FILDEST", .F., "0201" )

    If ( nOpcX == 3 .Or. nOpcX == 4 ) .And. FWCodFil() == cFilOrig .And.;
       U_REFATA02( 1, cProduto ) .And. U_REFATA02( 3, cProduto ) .And.;
       !IsInCallStack( "U_REESTA06" )

        //-- Rotina para inclusao de entrutura na filial da Industria MM SP
        U_REESTA06()
    EndIf

Return

