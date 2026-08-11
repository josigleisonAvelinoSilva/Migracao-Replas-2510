#include 'protheus.ch'
#include 'parmtype.ch'

/*
=========================================================================================================
Programa.................: OMS200FIM
Autor:...................: Leandro Dentello
Data.....................: 09/19/2017
Descrição / Objetivo.....: Integrar o Tipo de Operação no Romaneio de Frete pela Carga do OMS.
Doc. Origem..............: GAP
Solicitante..............: Cliente
Uso......................: Replas
Obs......................: Ponto de entrada executado no momento da integração com o SIGAGFE.
=========================================================================================================
*/            

User Function OM200FIM()

	Local aArea := GetArea()

	dBselectArea('GWN')
	dBsetOrder(1)

	If DbSeek(xFilial('GWN')+DAK->DAK_COD + DAK->DAK_SEQCAR) //GWN->NRROM

		RecLock('GWN',.F.)

		GWN->GWN_CDTPOP := DAK->DAK_CDTPOP

		MsUnlock()

	EndIf

	RestArea(aArea)
Return