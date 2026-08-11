#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} DL200TRB
Ponto de entrada para adicionar campos na tela de montagem de carga - OMS

@author Rafael Domingues
@since 10.03.2018
@obs DL200BRW, DL200TRB, 0M200GRV -> Pontos de entrada que compõe a montagem dos campos
/*/

User Function DL200TRB()

Local aRet := PARAMIXB

Aadd(aRet,{"PED_ENDENT",TamSx3("A1_ENDENT")[3],TamSx3("A1_ENDENT")[1],TamSx3("A1_ENDENT")[2]})
//Aadd(aRet,{"PED_REDESP",TamSx3("A4_NOME")[3],TamSx3("A4_NOME")[1],TamSx3("A4_NOME")[2]})

Return aRet
