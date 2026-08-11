#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} DL200BRW
Ponto de entrada para adicionar campos na tela de montagem de carga - OMS

@author Rafael Domingues
@since 10.03.2018
@obs DL200BRW, DL200TRB, 0M200GRV -> Pontos de entrada que compõe a montagem dos campos
/*/

User Function DL200BRW()

	Local aRet := PARAMIXB

	Aadd(aRet,{"PED_ENDENT",,RetTitle("A1_ENDENT")})
	Aadd(aRet,{"PED_REDESP",,RetTitle("C5_REDESP")})

Return aRet