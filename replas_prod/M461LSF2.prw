#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M461LSF2  ºAutor  ³Leandro Dentello    º Data ³ 03/10/2017  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada utilizado para gravar os dados da trans-  º±±
±±º          ³portadora da carga na Nota Fiscal para integracao com GFE.  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ REPLAS                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


User Function M461LSF2()
	Local aArea    := GetArea()
	Local aAreaDAK := DAK->(GetArea())
	Local aAreaSA4 := SA4->(GetArea())
	Local aAreaSC5 := SC5->(GetArea())
	If !Empty(SC9->C9_CARGA)
		DbSelectArea("DAK")
		DbSetOrder(1)
		DbSeek(xFilial("DAK")+SC9->C9_CARGA+SC9->C9_SEQCAR)

		SF2->F2_TRANSP  := DAK->DAK_TRANSP
		If DAK->(FieldPos("DAK_RDESP1")) > 0
			If !Empty(DAK->DAK_RDESP1)
				DbSelectArea("SA4")
				DbSetOrder(1)
				DbSeek(xFilial("SA4")+DAK->DAK_RDESP1)

				If SF2->(FieldPos("F2_REDESP")) > 0
					SF2->F2_REDESP  := DAK->DAK_RDESP1
					If DAK->DAK_TFRDP1 == 'C'
						SF2->F2_TFRDP1  := 'C'
					Else
						SF2->F2_TFRDP1 := 'F'
					EndIf
					SF2->F2_ESTRDP1 := SA4->A4_EST
					SF2->F2_CMURDP1 := SA4->A4_COD_MUN
				EndIf
			Else
				If !Empty(SC5->C5_REDESP)
					DbSelectArea("SA4")
					DbSetOrder(1)
					DbSeek(xFilial("SA4")+SC5->C5_REDESP)
		
					If SF2->(FieldPos("F2_REDESP")) > 0
						SF2->F2_REDESP  := SC5->C5_REDESP
						If SC5->C5_TFRDP1 == 'C'
							SF2->F2_TFRDP1  := 'C'
						Else
							SF2->F2_TFRDP1 := 'F'
						EndIf
						SF2->F2_ESTRDP1 := SA4->A4_EST
						SF2->F2_CMURDP1 := SA4->A4_COD_MUN
					EndIf
				EndIf
			EndIf
		EndIf
	Else // Quando nao tem carga
		If !Empty(SC5->C5_REDESP)
			DbSelectArea("SA4")
			DbSetOrder(1)
			DbSeek(xFilial("SA4")+SC5->C5_REDESP)

			If SF2->(FieldPos("F2_REDESP")) > 0
				SF2->F2_REDESP  := SC5->C5_REDESP
				If SC5->C5_TFRDP1 == 'C'
					SF2->F2_TFRDP1  := 'C'
				Else
					SF2->F2_TFRDP1 := 'F'
				EndIf
				SF2->F2_ESTRDP1 := SA4->A4_EST
				SF2->F2_CMURDP1 := SA4->A4_COD_MUN
			EndIf
		EndIf
	EndIf

	conout("[M461LSF2] Processamento "+SF2->F2_DOC+" \ "+SF2->F2_SERIE+" "+DtoC(dDatabase)+" "+Time())

	RestArea(aAreaSA4)
	RestArea(aAreaDAK)
	RestArea(aArea)
Return