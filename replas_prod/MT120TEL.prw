#Include 'Protheus.ch'
//-------------------------------------------------------------------
/*/{Protheus.doc} MT120TEL
Ponto de entrada Pedido de compra
Criar novos dados: Numero do Processo, Quantidade de Dolar e Vlr.Dolar
@author TOTVS Serra do Mar [JOSE CARLOS]
@since 18/07/2016
@version P12
/*/
//-------------------------------------------------------------------
User Function MT120TEL()
Local oBjtTela	:= ParamIxb[1]
Local aPosTela	:= ParamIxb[2]

Local oProcDI
Local oQtdeDolar
Local oTxDolar

/*
@ aPosTela[1][1]+28,550 SAY   "Nr.Processo" OF oBjtTela PIXEL SIZE 030,006               
@ aPosTela[1][1]+28,590 MSGET oProcDI Var cProcDI WHEN (INCLUI .OR. ALTERA) PICTURE "@!"   OF oBjtTela PIXEL SIZE 060,006

@ aPosTela[1][1]+40,430 SAY   "Qtde.Dolar" OF oBjtTela PIXEL SIZE 030,006               
@ aPosTela[1][1]+40,470 MSGET oQtdeDolar Var nQtdeDolar WHEN (INCLUI .OR. ALTERA) Picture "@e 99,999,999.99" OF oBjtTela PIXEL SIZE 060,006 HASBUTTON

@ aPosTela[1][1]+40,540 SAY   "Tx.Dolar" OF oBjtTela PIXEL SIZE 030,006               
@ aPosTela[1][1]+40,580 MSGET oTxDolar Var nTxDolar WHEN (INCLUI .OR. ALTERA) Picture "@e 9999.9999" OF oBjtTela PIXEL SIZE 060,006 HASBUTTON
*/

@ aPosTela[1][1]+31,550 SAY   "Nr.Processo" OF oBjtTela PIXEL SIZE 030,006               
@ aPosTela[1][1]+30,590 MSGET oProcDI Var cProcDI WHEN (INCLUI .OR. ALTERA) PICTURE "@!"   OF oBjtTela PIXEL SIZE 060,006

@ aPosTela[1][1]+31,670 SAY   "Qtde.Dolar" OF oBjtTela PIXEL SIZE 030,006               
@ aPosTela[1][1]+30,710 MSGET oQtdeDolar Var nQtdeDolar WHEN (INCLUI .OR. ALTERA) Picture "@e 99,999,999.99" OF oBjtTela PIXEL SIZE 060,006 HASBUTTON

@ aPosTela[1][1]+31,790 SAY   "Tx.Dolar" OF oBjtTela PIXEL SIZE 030,006               
@ aPosTela[1][1]+30,830 MSGET oTxDolar Var nTxDolar WHEN (INCLUI .OR. ALTERA) Picture "@e 9999.9999" OF oBjtTela PIXEL SIZE 060,006 HASBUTTON

Return
