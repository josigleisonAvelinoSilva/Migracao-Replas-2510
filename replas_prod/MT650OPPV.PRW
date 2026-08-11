#INCLUDE "PROTHEUS.CH"


/*/{Protheus.doc} MT650OPPV
Ponto de Entrada permite realizar customizacoes apos a geracao de OPs por Venda (fora da transacao)
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 29/04/2022
/*/
User Function MT650OPPV()
    //Local aPedOP    := ParamIXB[01]
    Local aPedOP1   := ParamIXB[02]
    //Local cFilOrig  := GetMV( "RE_FILORIG", .F., "0302" )
    Local cFilDest  := GetMV( "RE_FILDEST", .F., "0201" )
    Local lImpOP    := GetMV( "RE_IMPOP", .F., .T. )
    Local lIntIndMM := GetMV( "RE_INTIND", .F., .T. ) //-- Parametro geral que indica se a integracao de pedidos com a industria mm (Filial 0201) esta ativa

    If IsInCallStack("MATA650C") .And. cFilAnt $ cFilDest
        If lIntIndMM
            //-- Preenchimento da "Filial" e o "Pedido" origem
            GrvFilPVOri( aPedOP1 )
        EndIf

        //-- Impresssao OP
        If lImpOP .And. MsgYesNo("Deseja realizar a impressão das OPs?", "Imprimir Relatorio OP?")
            U_REPCPR02(aPedOP1)
        EndIf
    EndIf

Return


/*/{Protheus.doc} GrvFilPVOri
Faz o preenchimento da "Filial" e o "Pedido" origem nas OPs geradas apartir dos PVs
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 19/05/2022
@param aPedOP1, array, Array com os pedidos
/*/
Static Function GrvFilPVOri( aPedOP1 )
    Local aArea    := GetArea() 
    Local aAreaSC2 := SC2->( GetArea() )
    Local aAreaSC5 := SC5->( GetArea() )
    Local nI       := 0

    DbSelectArea("SC2")
    SC2->( DbSetOrder(1) )

    DbSelectArea("SC5")
    SC5->( DbSetOrder(1) )

    //-- Laco que faz o preenchimento da "Filial origem" e "Numero do Pedido origem" em todas as OPs do PV destino
    For nI := 1 To Len(aPedOP1)
        //-- Pocisiona no pedido para ser possivel pegar a "Filial" e o "Numero do Pedido"
        SC5->( DbSeek( xFilial("SC5") + aPedOP1[nI, 01] ) ) 

        If SC2->( DbSeek( xFilial("SC2") + aPedOP1[nI, 01] + aPedOP1[nI, 02] + aPedOP1[nI, 03] ) )
            //-- Faz o preenchimento da "Filial" e "Numero do Pedido" que originou a ordem de producao
            RecLock( "SC2", .F. )
                SC2->C2_XFILORI := SC5->C5_XFILORI
                SC2->C2_XPVORIG := SC5->C5_XPVORIG
                SC2->C2_PEDIDO  := SC2->C2_NUM
                SC2->C2_ITEMPV  := SC2->C2_ITEM
            SC2->( MsUnlock() )
        EndIf
    Next nI

    RestArea( aAreaSC5 )
    RestArea( aAreaSC2 )
    RestArea( aArea )

Return
