#include 'protheus.ch'
#include 'parmtype.ch'

user function M440SC9I()
	Local aArea 	:= GetArea()
	Local cTpPed	:= Alltrim(SC5->C5_TIPO)
	Local cNomePed	:= ""
	Local cCgcPed	:= ""
	
	//(David - TSM 19/01/2018) - Tratamento para grava Nome e CGC Cli/For na Liberação de pedidos
	If SC9->(FieldPos("C9_XNOME")) > 0 .AND. SC9->(FieldPos("C9_XCGC")) > 0 
		If cTpPed $ 'D,B'
			SA2->(DbSetOrder(1))
			SA2->(DbSeek(xFilial("SA2")+SC5->(C5_CLIENTE+C5_LOJACLI)))
			cNomePed := SA2->A2_NOME
			cCgcPed	 := SA2->A2_CGC	
		Else
			SA1->(DbSetOrder(1))
			SA1->(DbSeek(xFilial("SA1")+SC5->(C5_CLIENTE+C5_LOJACLI)))
			cNomePed := SA1->A1_NOME
			cCgcPed	 := SA1->A1_CGC	
		Endif
		
		SC9->C9_XNOME := cNomePed
		SC9->C9_XCGC  := cCgcPed
	EndIf
	
	RestArea(aArea)
return