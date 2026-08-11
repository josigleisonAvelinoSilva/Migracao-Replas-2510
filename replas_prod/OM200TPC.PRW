#Include "Protheus.ch"
/*/{Protheus.doc} OM200TPC
Permite selecionar os pedidos que serão exibidos
@type function
@version 1.0
@author Marcos Aversa - Dothink
@since 07/06/2023
@return logical, Se Pedido deve ou não ser incluido no Array Pedidos/Carga
/*/
User Function OM200TPC()
    local aArea     := GetArea()
    local aAreaSC6  := SC6->( GetArea() )
    local lRet      := .T.
    local lVerPdBlq := GetMv( "RE_PEDIBLQ",,.T.)  //Verifica Pedidos Bloqueados    
    
    //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
    SC6->( dbSetOrder( 1 )) 
    If SC6->( dbSeek( SC9->C9_FILIAL + SC9->C9_PEDIDO + SC9->C9_ITEM + SC9->C9_PRODUTO ) ) .AND.;
       SC6->C6_BLOQUEI == "01" .AND.;
       lVerPdBlq
       lRet := .F.
    Endif
    RestArea( aAreaSC6 )
    RestArea( aArea )
Return lRet
