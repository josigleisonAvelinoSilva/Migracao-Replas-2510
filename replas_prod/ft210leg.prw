#include "totvs.ch"


/*/{Protheus.doc} FT210LEG
Ponto de entrada possibilita configurar as informacoes da legenda conforme a necessidade.
@type function
@version 2310
@author DO THINK - ERIKE YURI
@since 06/05/2024
@return array, Array com nova cor
/*/
User Function FT210LEG()
    Local aRet := paramixb

    aAdd(aRet, {'BR_AZUL_CLARO', "Pedido Bloqueado por Regra (Cond. Pagamento)"})

Return aRet
