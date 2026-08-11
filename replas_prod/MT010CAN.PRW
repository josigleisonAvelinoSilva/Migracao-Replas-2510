#INCLUDE "PROTHEUS.CH"


/*/{Protheus.doc} MT010CAN
Ponto de Entrada para executar customizacoes 
no final da inclusao/alteracao/exclusao do 
cadastro de produtos
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 26/06/2022
@obs Projeto Novo PCP - Esse ponto de entrada foi
criado para que os novos codigos de produto de "SERVICO"
sejam criados automaticamente apos a inclusao ou alteracao
de um Produto Acabado do tipo "Filme"
/*/
User Function MT010CAN()
    //Local nOpc     := ParamIXB[01]
    Local cCodServ := GetMV( "RP_CODSERV", .F., "" )
    Local cNewProd := ""

    If ( IsInCallStack( "A010Inclui" ) .Or. IsInCallStack( "A010Altera" ) ) .And.;
       U_REFATA02( 1, SB1->B1_COD ) .And. U_REFATA02( 3, SB1->B1_COD ) 

        /*Cadastro o novo codigo de servico iniciado com "SV-" e terminado com o codigo 
        do PA para ser usado no novo processo de producao na industria.*/
        cNewProd := "SV-" + AllTrim( SB1->B1_COD )

        //-- Rotina para cadastro de produtos
        U_REPCPA02( cCodServ, cNewProd )
    EndIf

Return
