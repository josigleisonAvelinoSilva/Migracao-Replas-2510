#INCLUDE "PROTHEUS.CH"


/*/{Protheus.doc} REPCPA03
Rotina de apontamento de perda customizada
@type function
@version 1.0 
@author Dener Lemos - DOTHINK
@since 10/01/2022
@param aPerda, array, Array com os produtos da perda
@param cErro, character, Variavel que grava os erros
@return logical, Retorno logico
@obs Projeto Novo PCP (Retorno para Estoque e Sucata)
/*/
User Function REPCPA03(aPerda, cErro)
    Local aCab     := {}
    Local aLinha   := {}
    Local aItens   := {}
    Local cOP      := ""
    Local cProduto := ""
    Local cArmOri  := ""
    Local cTipo    := ""
    Local cMotivo  := ""
    Local nI
    Local lREPCPA03 := .T.

    Begin Transaction

        For nI := 1 To Len(aPerda)
            aLinha := {}

            If AllTrim(aPerda[nI,01]) # AllTrim(cOP)
                cOP := Padr(aPerda[nI,01], TamSX3("BC_OP")[1])

                //-- Cabecalho
                aAdd(aCab, {"BC_OP", cOP, Nil})
            EndIf

            cProduto := Padr(aPerda[nI,02], TamSX3("BC_PRODUTO")[1])
            cArmOri  := Padr(aPerda[nI,03], TamSX3("BC_LOCORIG")[1])
            cTipo    := Padr(aPerda[nI,04], TamSX3("BC_TIPO")[1])
            cMotivo  := Padr(aPerda[nI,05], TamSX3("BC_MOTIVO")[1])

            //-- Linhas
            aAdd(aLinha, {"BC_FILIAL" , xFilial("SBC"), Nil})
            aAdd(aLinha, {"BC_PRODUTO", cProduto      , Nil})
            aAdd(aLinha, {"BC_LOCORIG", cArmOri       , Nil})
            aAdd(aLinha, {'BC_TIPO'   , cTipo         , Nil})
            aAdd(aLinha, {'BC_MOTIVO' , cMotivo       , Nil})
            aAdd(aLinha, {"BC_QUANT"  , aPerda[nI,06] , Nil})
            aAdd(aLinha, {"BC_CODDEST", aPerda[nI,07] , Nil})
            aAdd(aLinha, {"BC_LOCAL"  , aPerda[nI,08] , Nil})
            aAdd(aLinha, {"BC_QTDDEST", aPerda[nI,06] , Nil})
            aAdd(aLinha, {"BC_DATA"   , dDataBase     , Nil})
            If Rastro(cProduto)
                aAdd(aLinha, {"BC_LOTECTL", aPerda[nI,09] , Nil})
                aAdd(aLinha, {"BC_NUMLOTE", aPerda[nI,10] , Nil})
                aAdd(aLinha, {"BC_DTVALID", aPerda[nI,11] , Nil})
            EndIf
            If !Empty(aPerda[nI,12])
                aAdd(aLinha, {"BC_XPESBRT"    , aPerda[nI,12]  , Nil})
            EndIf

            //-- Itens
            aAdd(aItens, aLinha)
        Next nI

        lMSErroAuto := .F.
        MSExecAuto({|x,y,z| MATA685(x,y,z)},aCab,aItens,3)
        If lMSErroAuto
            //MostraErro()
            cErro := "Erro no apontamento de Retorno para Estoque e/ou Sucata ["+AllTrim(cOP)+"]."
            lREPCPA03 := .F.
        EndIf

    End Transaction

Return lREPCPA03
