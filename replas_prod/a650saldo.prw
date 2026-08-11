
#include "totvs.ch"


/*/{Protheus.doc} a650saldo
Ponto de entrada que permite tratar Saldo Disponível na abertura de OP por PV
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 11/07/2025
@return numeric, Retorna a quantidade de saldo
/*/
User Function a650saldo()
    Local nQtdStok := ParamIXB
    //Local cFilOrig := GetMV( "RE_FILORIG", .F., "0302" )
    Local cFilDest := GetMV( "RE_FILDEST", .F., "0201" )

    If cFilAnt == cFilDest .And. IsInCallStack("MATA650C") .And. nQtdStok > 0
        nQtdStok := 0
    EndIf

Return nQtdStok
