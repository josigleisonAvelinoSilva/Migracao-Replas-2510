#INCLUDE "PROTHEUS.CH"


/*/{Protheus.doc} SD3250E
Ponto de entrada no estorno das tabelas de apontamento de producao
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 15/08/2022
/*/
User Function SD3250E()
    //Local cFilOrig  := GetMV( "RE_FILORIG", .F., "0302" )
    Local cFilDest  := GetMV( "RE_FILDEST", .F., "0201" )
    Local lIntIndMM := GetMV( "RE_INTIND", .F., .T. ) //-- Parametro geral que indica se a integracao de pedidos com a industria mm (Filial 0201) esta ativa

    If lIntIndMM .And. cFilAnt == cFilDest 
        DbSelectArea("SZ8")
        SZ8->(DbSelectArea(1))
        If SZ8->(DbSeek(xFilial("SZ8") + SC2->(C2_PEDIDO + C2_ITEMPV)))
            RecLock("SZ8", .F.)
                DbDelete()
            SZ8->(MsUnlock())
        EndIf
    EndIf

Return
