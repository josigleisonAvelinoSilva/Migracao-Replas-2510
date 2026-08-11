#include "totvs.ch"


/*/{Protheus.doc} mt260nlot
Ponto de entrda que permite manter o numero do sub-lote nas tranferencias multiplas
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 05/08/2025
@return logical, Retorno logico
/*/
User Function mt260nlot()
Return If(SuperGetMV("MV_MTNLOTE",,"N")=="S",.T.,.F.)
