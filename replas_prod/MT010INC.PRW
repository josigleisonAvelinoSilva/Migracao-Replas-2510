#INCLUDE "PROTHEUS.CH"


/*/{Protheus.doc} MT010INC
Ponto de Entrada para complementar a inclusao no cadastro do Produto
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 05/07/2022
@obs Projeto Novo PCP - Esse ponto de entrada foi
criado para que os novos codigos de produto de "SERVICO"
sejam criados automaticamente apos a copia de um 
Produto Acabado do tipo "Filme"
/*/
User Function MT010INC()
    Local lA010Copia := IsInCallStack("A010Copia")
    Local lREPCPA02  := IsInCallStack("U_REPCPA02")
    Local cCodServ   := GetMV( "RP_CODSERV", .F., "" )
    Local cNewProd   := ""

    If !lREPCPA02 .And. lA010Copia .And. U_REFATA02( 1, SB1->B1_COD ) .And. U_REFATA02( 3, SB1->B1_COD )
        /*Cadastro o novo codigo de servico iniciado com "SV-" e terminado com o codigo 
        do PA para ser usado no novo processo de producao na industria.*/
        cNewProd := "SV-" + AllTrim( SB1->B1_COD )

        //-- Rotina para cadastro de produtos
        U_REPCPA02( cCodServ, cNewProd )
    EndIf

Return
