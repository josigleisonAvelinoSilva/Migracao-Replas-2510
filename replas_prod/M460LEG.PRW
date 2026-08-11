/* Bibliotecas */
#Include 'Protheus.ch'
  
/*/{Protheus.doc} M461LEG
Ponto de Entrada para alterar a cor da legenda (Documento de Saída)
@author Flávio Dentello
@since 26/03/2023
@version 1.0
@type function
@example U_M461LEG()
@obs Se o pedido estiver com bloqueio de Regras (C5_BLQ) ficará com a legenda Preta.
/*/
  
User Function M461LEG()

    Local aArea  := GetArea()
    Local aCores := PARAMIXB
       
    AAdd(aCores,{"BR_PRETO"    , "Bloqueio por Regra"    } )
        
    RestArea(aArea)
  
Return ( aCores )
