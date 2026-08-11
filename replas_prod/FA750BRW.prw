#Include 'Protheus.ch'
//-------------------------------------------------------------------
/*/{Protheus.doc} FA750BRW
Processo de DI

@author TOTVS Serra do Mar [JOSE CARLOS]
@since 30/06/2016
@version P12
/*/
//-------------------------------------------------------------------
User Function FA750BRW()
Local aButtons	:= {} 
Public nCount	:= 0
aAdd( aButtons,	{ 'Baixa Processo [DI]',"U_CALC_DI()", 0 , 3,,.F.})  

Return(aButtons)

//-------------------------------------------------------------------
/*/{Protheus.doc} CALC_DI
Processo de DI
Calculo da variação cambial
@author TOTVS Serra do Mar [JOSE CARLOS]
@since 30/06/2016
@version P12
/*/
//-------------------------------------------------------------------
User Function CALC_DI()
Local aAreaAtu	:= GetArea()
Local oDlgDI
Local nQtdeDolar:= 0
Local nTaxaDI	:= 0
Local lOK		:= .F.
Local nVlrDTit	:= 0
Local nVlrBaixa	:= 0
Local nVlrVaria	:= 0

If nCount > 1
	RestArea(aAreaAtu)
	Return()
ElseIf Empty(SE2->E2_XPROCES)
	ApMsgInfo('Titulo sem vinculo com processo [DI].')
	RestArea(aAreaAtu)
	Return()
ElseIf SE2->E2_SALDO == 0 
	ApMsgInfo('Titulo já Baixado.')
	RestArea(aAreaAtu)
	Return()
EndIf

nCount ++

DEFINE MSDIALOG oDlgDI FROM 25,1 TO 250,400 TITLE "Dados Processo [DI]" PIXEL 
	
	@ 10,06 SAY "Qtde. Dolar" SIZE 50, 09 OF oDlgDI PIXEL
	@ 10,60	MSGET nQtdeDolar Picture PesqPict('SE2','E2_XQTDDOL') SIZE 80, 09 OF oDlgDI PIXEL Hasbutton

	@ 25,06 SAY "Taxa Dolar" SIZE 50, 09 OF oDlgDI PIXEL
	@ 25,60	MSGET nTaxaDI Picture PesqPict('SE2','E2_XTXDOLA') SIZE 80, 09 OF oDlgDI PIXEL Hasbutton

	DEFINE SBUTTON FROM 90,120 TYPE 1 ENABLE OF oDlgDI ACTION ( lOK:=.T.,oDlgDI:End() )
	DEFINE SBUTTON FROM 90,150 TYPE 2 ENABLE OF oDlgDI ACTION oDlgDI:End() 

ACTIVATE MSDIALOG oDlgDI CENTERED

If lOk

//-------------------------------------------------------------------
/*/DEFINIÇÃO CONFORME APRESENTAÇÃO NO DIA 24/08/2016 (MATHEUS)
Tx.Baixa - Tx.Nota Fiscal = (+) Decrescimo
                            (-) Acrescimo
/*/
//-------------------------------------------------------------------

	nVlrDTit	:= (SE2->E2_XQTDDOL * SE2->E2_XTXDOLA)
	nVlrBaixa	:= (nQtdeDolar	* nTaxaDI)
	
//	nVlrVaria	:= nVlrDTit - nVlrBaixa
	nVlrVaria	:= nVlrBaixa - nVlrDTit 

	
	If nVlrBaixa > 0
		RecLock('SE2',.F.)
			SE2->E2_XTXBAIX	:= nTaxaDI
			If nVlrVaria < 0	// Valor Negativo
				SE2->E2_ACRESC	:= ABS(nVlrVaria)
				SE2->E2_SDACRES	:= ABS(nVlrVaria)
			Else
				SE2->E2_DECRESC	:= nVlrVaria
				SE2->E2_SDDECRE	:= nVlrVaria
			EndIf
		MsUnlock()
		FINA080(,3,.T.)
	EndIf
	nCount ++
EndIf

RestArea( aAreaAtu )
Return()

