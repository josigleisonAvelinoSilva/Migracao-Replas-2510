#INCLUDE "Protheus.ch"


/*/{Protheus.doc} mta650ae
Após a exclusão da OP, ajustar Flag de Controle para possível nova inclusão da OP/ITEM
@type function
@version 1.0
@author Dothink - Marcos Aversa
@since 21/06/2023
@return variant, NIL
/*/
User Function mta650ae()
    Local aArea     := GetArea()
    Local aAreaSC6  := SC6->( GetArea() )
    Local lVerExcOP := GetMv( "RE_EXOPPRD",,.T.)  //Ativa Verif. de Exclusão OP    
    Local cFilDest  := GetMV( "RE_FILDEST", .F., "0201" )

    If lVerExcOP .AND. cFilAnt == cFilDest 
        dbSelectArea("SC6")
        SC6->(dbSetOrder(1)) //--C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO

        //-- Se estiver C6_OP == '03', não conseguimos gerar novamente essa OP para esse ITEM
        If SC6->(dbSeek(xFilial("SC6") + SC2->C2_PEDIDO + SC2->C2_ITEMPV)) //.AND. SC6->C6_OP == '03' 
            RecLock("SC6", .F.)
                SC6->C6_OP := Space(GetSX3Cache("C6_OP", "X3_TAMANHO"))
            SC6->(MsUnLock()) 
        Endif
    Endif

    RestArea( aAreaSC6 )
    RestArea( aArea )

Return
