#INCLUDE "PROTHEUS.CH"


/*/{Protheus.doc} A650VMNU
Ponto de Entrada permite adicionar mais opcoes no menu da Mbrowse
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 29/04/2022
@return array, Array dos menus
/*/
User Function A650VMNU()
    Local aRotina := {}
    //Local cFilOrig  := GetMV( "RE_FILORIG", .F., "0302" )
    Local cFilDest  := GetMV( "RE_FILDEST", .F., "0201" )

    If FWCodFil() $ cFilDest
        aAdd( aRotina, {"Param. Sugestao Bobinas", "U_REPCPA7P()", 0, 0} )
    EndIf

Return aRotina
