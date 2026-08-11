/* Bibliotecas */
#Include 'Protheus.ch'
  
/*/{Protheus.doc} M461COR
Ponto de Entrada para alterar a cor de status no browse da Nota Fiscal de Saída (Documento de Saída)
@author Caio César Henrique
@since 30/05/2019
@version 1.0
@type function
@example U_M461COR()
@obs Se o pedido estiver com bloqueio de Regras (C5_BLQ) ficará com a legenda Preta.
/*/
  
User Function M461COR()
  
    Local aArea  := GetArea()
    Local aCores := PARAMIXB

    aCores[1,1] += " .and. !( Posicione('SC5',1,XFILIAL('SC5')+SC9->C9_PEDIDO,'C5_BLQ') == '1' )"  
    AAdd(aCores,{ " Posicione('SC5',1,XFILIAL('SC5')+SC9->C9_PEDIDO,'C5_BLQ') == '1' " , "BR_PRETO"})
        
    RestArea(aArea)

Return ( aCores )
