#include "totvs.ch"


/*/{Protheus.doc} ma650qtd
Ponto de entrada que permite manipular a quantidade da OP aberta por PV
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 25/06/2025
@return numeric, Quantidade do item do PV
/*/
User Function ma650qtd()
    Local nQtdItPV := ParamIXB[01]

    If !(nQtdItPV == SC6->C6_QTDVEN)
        nQtdItPV := SC6->C6_QTDVEN
    EndIf

Return nQtdItPV
