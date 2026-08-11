#include "totvs.ch"


/*/{Protheus.doc} MT450COLS
Ponto de entrada para alteracao do acols antes da apresentacao da tela de Liberacao Manual. 
Recebe como parametro o "aHeader" e a linha do "aCols" e deve obrigatoriamente retornar a linha do acols alterada.
@type function
@version 2310
@author DO THINK - ERIKE YURI
@since 06/05/2024
@return array, Array com nova cor
/*/
User Function MT450COLS()
    Local aRet  := paramixb[2]

    aRet[Len(aRet), 5] := "Desc.Cond.Pagto"
    aRet[Len(aRet), 6] := AllTrim(SC5->C5_XDCONDP)

Return aRet
