#INCLUDE "PROTHEUS.CH"


/*/{Protheus.doc} XPROXLOT
Ponto de Entrada que manipula a numeracao do SubLote
@type function
@version 1.0 
@author Marcos P.Aversa
@since 03/02/2023
@return character, Novo SubLote gerado
/*/
User Function XPROXLOT()
    Local cNumLote := ParamIXB[01]

    If IsInCallStack("U_REPCPA10")
		//-- Sub-Lote
        cNumLote := aTransfSZ9[N+1, 22, 02]
    Else
        PutMV("MV_PRXLOTE", cNumLote)
    Endif

Return cNumLote
