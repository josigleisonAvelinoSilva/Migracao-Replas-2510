#include "totvs.ch"
#include "fwmvcdef.ch"


/*/{Protheus.doc} REESTA17
Rotina generica de inclusao de Solicitacao de Tranferencia Replas
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 17/06/2024
@param aCabecNNS, array, Cabecalho da ST - NNS
@param aItensNNT, array, Itens da ST - NNS
@return array, Retorno da inclusao
/*/
User Function REESTA17(aCabecNNS, aItensNNT)
    Local aAreaAnt := GetArea()
    Local aRet     := Array(3)
    Local aError   := {}
    Local cMsgErr  := ""
    Local nZ,nX    := 0
    Local oModel   := Nil

    If Type("INCLUI") == "U"
        INCLUI := .T.
    EndIf

	dbSelectArea("SB2")
	SB2->(dbSetorder(1))

    //-- Carrega o modelo
    oModel := FWLoadModel("REESTA01")

    //-- Seta operacao de inclusao
    oModel:setOperation(MODEL_OPERATION_INSERT)
    
    //-- Ativa o Modelo
    oModel:activate()

    //-- Cabecalho
    oModel:setValue("NNSMASTER", "NNS_CLASS" , aCabecNNS[01, 01])
    oModel:setValue("NNSMASTER", "NNS_ESPECI", aCabecNNS[02, 01])
    oModel:setValue("NNSMASTER", "NNS_SOLICT", aCabecNNS[03, 01])
    oModel:setValue("NNSMASTER", "NNS_XNOMST", aCabecNNS[04, 01])

    //-- Itens
    For nZ := 1 To Len(aItensNNT)
        //-- Cria saldo inicial no destino, caso nao exista
        If !SB2->(dbSeek(aItensNNT[nZ, 08] + aItensNNT[nZ, 09] + aItensNNT[nZ, 10]))
			CriaSB2(aItensNNT[nZ, 09], aItensNNT[nZ, 10], aItensNNT[nZ, 08])	
		EndIf

        If nZ > 1
            oModel:getModel("NNTDETAIL"):addLine()
        EndIf

        //-- Origem
        oModel:setValue("NNTDETAIL", "NNT_FILORI", aItensNNT[nZ, 01])
        oModel:setValue("NNTDETAIL", "NNT_PROD"  , aItensNNT[nZ, 02])
        oModel:setValue("NNTDETAIL", "NNT_LOCAL" , aItensNNT[nZ, 03])
        oModel:setValue("NNTDETAIL", "NNT_QUANT" , aItensNNT[nZ, 04])

        //-- Rastreabilidade
        If Rastro(aItensNNT[nZ, 02])
            If Rastro(aItensNNT[nZ, 02], "L")
                //-- Rastreabilidade por Lote
                oModel:setValue( "NNTDETAIL", "NNT_LOTECT", aItensNNT[nZ, 05])
                oModel:setValue( "NNTDETAIL", "NNT_DTVALI", SToD(aItensNNT[nZ, 07]))
            Else
                //-- Rastreabilidade por Sub-Lote
                oModel:setValue("NNTDETAIL", "NNT_LOTECT", aItensNNT[nZ, 05])
                oModel:setValue("NNTDETAIL", "NNT_NUMLOT", aItensNNT[nZ, 06])
                oModel:setValue("NNTDETAIL", "NNT_DTVALI", SToD(aItensNNT[nZ, 07]))
            EndIf
        Else
            oModel:setValue("NNTDETAIL", "NNT_LOTECT", " ")
            oModel:setValue("NNTDETAIL", "NNT_NUMLOT", " ")
            oModel:setValue("NNTDETAIL", "NNT_DTVALI", CToD("  /  /  "))
        EndIf

        //-- Destino
        oModel:setValue("NNTDETAIL", "NNT_FILDES", aItensNNT[nZ, 08])
        oModel:setValue("NNTDETAIL", "NNT_PRODD" , aItensNNT[nZ, 09])
        oModel:setValue("NNTDETAIL", "NNT_LOCLD" , aItensNNT[nZ, 10])
        oModel:setValue("NNTDETAIL", "NNT_TS"    , aItensNNT[nZ, 11])
        oModel:setValue("NNTDETAIL", "NNT_TE"    , aItensNNT[nZ, 12])
    Next nZ

    //-- Validacao
    If oModel:vldData()
        //-- Gravacao
        oModel:commitData()

        aRet[01] := .T.
        aRet[02] := oModel:aAllSubModels[01]:aDataModel[01][02][02]
        aRet[03] := "Sucesso ao incluir Solicit. Transf. Replas"
    Else
        //-- Recupera o erro do model quando nao passou no VldData
        aError  := oModel:getErrorMessage() 
        cMsgErr := ""

        //-- Laco para gravar em string "cMsgErr" conteudo do array
        For nX := 1 To Len(aError)
            If !Empty(aError[nX])
                cMsgErr += Alltrim(aError[nX]) + Chr(13) + Chr(10)
            EndIf
        Next nX

        aRet[01] := .F.
        aRet[02] := ""
        aRet[03] := "Erro ao incluir Solicit. Transf. Replas" + Chr(13) + Chr(10) + cMsgErr
    EndIf

    RestArea(aAreaAnt)

Return aRet
