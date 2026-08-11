#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} OM200GRV
Ponto de entrada para adicionar campos na tela de montagem de carga - OMS

@author Rafael Domingues
@since 10.03.2018
@obs DL200BRW, DL200TRB, 0M200GRV -> Pontos de entrada que compõe a montagem dos campos
/*/

User Function OM200GRV()

TRBPED->PED_ENDENT := SA1->A1_ENDENT
TRBPED->PED_REDESP := Posicione("SA4",1,xFilial("SA4")+SC5->C5_REDESP,"A4_NOME")

MsUnlock()

Return Nil