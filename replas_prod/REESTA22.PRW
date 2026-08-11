#INCLUDE "TOTVS.CH"


/*/{Protheus.doc} REESTA22
Rotina que faz a validacao do percentual maximo e minimo 
no momento do apontamento de producao da Industria MM 0201
@type function
@version 1.0 
@author DO THINK - DENER LEMOS
@since 05/12/2024
@return logical, Retorno logico
/*/
User Function REESTA22()
    Local aAreaAnt := GetArea()
    Local aAreaSA1 := SA1->(GetArea())
    Local aAreaSC2 := SC2->(GetArea())
    Local aAreaSC5 := SC5->(GetArea())
    Local aAreaSC6 := SC6->(GetArea())
    //Local cFilOrig := GetMV("RE_FILORIG", .F., "0302")
    Local cFilDest := GetMV("RE_FILDEST", .F., "0201")
    Local cCliente := ""
    Local cLoja    := ""
    Local cSeekSC5 := ""
    Local cSeekSC6 := ""
    Local nToleran := 0
    Local nTolPad  := GetMv("RE_TOLPAD", .F., 10) //-- % Tolerancia padrao para a producao
    Local nQtdAtpo := M->D3_QUANT
    Local nQtdPV   := 0
    Local lRet     := .T.

    If !IsBlind() .And. IsInCallStack("MATA250") .And. cFilAnt == cFilDest
        //-- Procura pelo pedido, verificando se existe pedido origem
        If Empty(SC2->C2_XFILORI) .And. Empty(SC2->C2_XPVORIG)
            cSeekSC5 := xFilial("SC2") + SC2->C2_NUM
        Else
            cSeekSC5 := SC2->C2_XFILORI + SC2->C2_XPVORIG
        EndIf

        SC5->(dbSetOrder(1))
        If SC5->(dbSeek(cSeekSC5))
            cCliente := SC5->C5_CLIENTE
            cLoja    := SC5->C5_LOJACLI
            nToleran := SC5->C5_XTOLERA

            SA1->(dbSetOrder(1))
            SA1->(dbSeek(xFilial("SA1") + cCliente + cLoja))
            cNomeCli := AllTrim( SA1->A1_NOME )
            If Empty(nToleran)
                nToleran := SA1->A1_XTOLERA
            EndIf
        EndIf

        If Empty(nToleran)
            nToleran := nTolPad
        EndIf

        If !Empty(nToleran)
            cSeekSC6 := xFilial("SC2") + SC2->C2_NUM + SC2->C2_ITEM

            SC6->(dbSetOrder(1))
            If SC6->(dbSeek(cSeekSC6))
                nQtdPV := SC6->C6_QTDVEN

                nQtdToleran := nQtdPV * (nToleran / 100)
                nQtdMaxApto := nQtdPV + nQtdToleran
                nQtdMinApto := nQtdPV - nQtdToleran

                If nQtdAtpo > nQtdMaxApto .Or. nQtdAtpo < nQtdMinApto
                    Help(Nil, Nil, "ERRQTD", Nil, "O peso informado <b>"+AllTrim(Transform(nQtdAtpo, "@E 9,999,999.999"))+" Kg</b> está fora da tolerância permitida, " + "± " + cValToChar(nToleran) + "%.", 1, 0, Nil, Nil, Nil, Nil, Nil,;
                    {"A quantidade do PV é <b>"+AllTrim(Transform(nQtdPV, "@E 9,999,999.999"))+" Kg</b>. " + Chr(10) + Chr(10) +;
                    "Peso máx. permitido: <b>"+AllTrim(Transform(nQtdMaxApto, "@E 9,999,999.999"))+" Kg</b>." + Chr(10) +;
                    "Peso min. permitido: <b>"+AllTrim(Transform(nQtdMinApto, "@E 9,999,999.999"))+" Kg</b>."})                      
                    lRet := .F.
                EndIf
            EndIf
        EndIf
    EndIf

    RestArea(aAreaSC6)
    RestArea(aAreaSC5)
    RestArea(aAreaSC2)
    RestArea(aAreaSA1)
    RestArea(aAreaAnt)

Return lRet
