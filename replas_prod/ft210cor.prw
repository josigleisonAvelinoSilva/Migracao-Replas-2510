#include "totvs.ch"


/*/{Protheus.doc} FT210COR
Ponto de entrada possibilita alterar as regras e cores dos pedidos bloqueados por verbas ou regras.
@type function
@version 2310
@author DO THINK - ERIKE YURI
@since 04/05/2024
@return array, Array com nova cor
/*/
User Function FT210COR()
    Local aRet  := {}
    Local aCores:= paramixb
    Local nI    := 1

    //-- Garantir que esta condição esteja na frente
    aAdd(aRet, {"C5_BLQ == '1' .and. !u_RFATA11B( C5_CONDPAG )", 'BR_AZUL_CLARO'})

    For nI := 1 To Len(aCores)
        aAdd(aRet, aClone(aCores[nI]) )
    Next nI

Return aRet
