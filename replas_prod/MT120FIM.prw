#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} MT120FIM
Processo de DI

@author TOTVS Serra do Mar [JOSE CARLOS]
@since 30/06/2016
@version P12
/*/
//-------------------------------------------------------------------
User Function MT120FIM()

Local nOpcao	:= PARAMIXB[1]
Local cNumPC	:= PARAMIXB[2]
Local aAreaAtu	:= GetArea()

If !IsInCallStack('MSEXECAUTO')
	If nOpcao == 3 .Or. nOpcao == 4 
		DbSelectArea('SC7')
		DbSetOrder(1)
		If DbSeek(xFilial('SC7')+cNumPC)
			While SC7->(!Eof()) .And. xFilial('SC7') == SC7->C7_FILIAL .And. SC7->C7_NUM == cNumPC
				RecLock('SC7',.F.)
					SC7->C7_XPROCES := cProcDI
					SC7->C7_XTXDOLA	:= nTxDolar
					SC7->C7_XQTDDOL	:= nQtdeDolar
				MsUnlock()
				SC7->(DbSkip())
			EndDo
		EndIF
	EndIf
EndIf

RestArea( aAreaAtu )
Return

