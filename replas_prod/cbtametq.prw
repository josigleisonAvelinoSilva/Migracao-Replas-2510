#include "totvs.ch"


/*/{Protheus.doc} CBTamEtq
Altera o tamanho do campo etiqueta/produto quando não utiliza CB0
@type function
@version 1.0
@author erike
@since 11/03/2022
@return variant, Tamanho do campo
/*/
User Function CBTamEtq()
    Local nRet    := PARAMIXB[1]
    Local nNewTam := 120

    If nNewTam > nRet
        nRet := nNewTam
    EndIf

    //-- Tratamento para definir o armazem padrao para inventario
    If IsInCallStack("ACDV030") .And. Type("cArmazem") == "C" .And. Empty(cArmazem)
        cArmazem := "01"
    EndIf

Return nRet
