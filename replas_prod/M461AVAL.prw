#include 'protheus.ch'
#include 'parmtype.ch'

/*
Ponto de entrada executado ao selecionar carga para ser faturado
*/

user function M461AVAL()
	Local aArea		:= GetArea()
	Local lRet 		:= paramixb[1]
	
	DbSelectArea("DAI")
	DAI->(DbSetOrder(1))
	
	DbSelectArea("SC9")
	SC9->(DbSetOrder(1))
	
	If lRet .and. DAK->DAK_COD >= MV_PAR03 .and. DAK->DAK_COD <= MV_PAR04 .and. DAI->(DbSeek(xFilial("DAI")+DAK->DAK_COD)) 
	
		While (!DAI->(Eof()) .And. DAI->DAI_COD == DAK->DAK_COD )
			If SC9->(DbSeek(xFilial("SC9")+DAI->DAI_PEDIDO)) .and. SC9->C9_DATALIB >= MV_PAR07 .and. SC9->C9_DATALIB <= MV_PAR08
				If !u_fvldped(DAI->DAI_PEDIDO)
					lRet := .F.
				EndIf
			EndIf
			DAI->(DbSkip())
		EndDo
		
	Endif
	
	RestArea(aArea)
return(lRet)