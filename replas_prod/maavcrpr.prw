#include "totvs.ch"


/*/{Protheus.doc} maavcrpr
Ponto de entrada executado na rotina de avalizacao de credito de clientes, MaAvalCred() – FATXFUN(). 
Ele permite que, apas a avaliacao padrao do sistema, o usuario possa fazer a sua propria.
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 11/07/2024
@return logical, Retorno logico
@obs Criacao de regra especifica da Replas para bloquear no credito caso a condicao de pagamento seja a vista
/*/
User Function maavcrpr()
    //Local cCodCli    := ParamIxb[1]  //-- Codigo do Cliente
    //Local cLoja      := ParamIxb[2]  //-- Codigo da loja
    //Local nValor     := ParamIxb[3]  //-- Preco da Venda
    //Local nMoeda     := ParamIxb[4]  //-- Moeda
    //Local lPedido    := ParamIxb[5]  //-- Inclusao de um pedido de venda
    //Local cTipoLim   := ParamIxb[6]  //-- Controle de credito
    Local lRetorno   := ParamIxb[7]  //-- Indica se existe bloqueio na validacao padrao (.F.) ou se nao existe bloqueio (.T.)
    //Local cCodigo    := ParamIxb[8]  //-- Codigo com o tipo de bloqueio de credito
    Local cFilialFat := GetMv("MV_XFILFAT")

    If FWCodFil() $ cFilialFat .And. AllTrim(SC5->C5_CONDPAG) $ "001/"
        lRetorno := .F.
    EndIf

Return lRetorno
