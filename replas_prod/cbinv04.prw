#include "totvs.ch"


/*/{Protheus.doc} cbinv04
Ponto de entrada para validacao da etiqueta de produto
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 30/11/2023
/*/
User Function cbinv04()
    Local aDadosEtq := u_CbGetReadN()

    //-- Tratamento para preencher o sub-lote na variavel private do programa padrao antes de abrir a tela de preenchimento do lote e sub-lote
    If !Empty(aDadosEtq) .And. !Empty(aDadosEtq[04]) .And. ValType(cSLote) == "C" .And. Empty(cSLote)
        //-- Preenche a variavel private do sub-lote
        cSLote := aDadosEtq[04]
    EndIf

Return
