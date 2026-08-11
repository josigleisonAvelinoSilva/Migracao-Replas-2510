#INCLUDE "PROTHEUS.CH"


Static aXREESTA05 := {}


/*/{Protheus.doc} REESTA05
Rotina para salvar o arrary de itens do pedido de vendas 
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 28/05/2022
/*/
User Function REESTA05(aItens)
    Local lMntLote := GetMV( "RE_MTNLOTE", .F., .T. )

    aXREESTA05 := {}
    If lMntLote
        aXREESTA05 := aClone( aItens )
    EndIf

Return


/*/{Protheus.doc} GREESTA05
Retorna os itens do pedido de vendas no array com variavel static
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 28/05/2022
@return array, Array com itens do PV
/*/
User Function GREESTA05()
Return aClone( aXREESTA05 )
