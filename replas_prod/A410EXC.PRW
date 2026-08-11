#Include "protheus.ch"


/*/{Protheus.doc} A410EXC
Ponto de entrada para validar a exclusão de um pedido de venda
@type function
@version 1.0 
@author Marcos P.Aversa
@since 16/02/2023
@return logical, Permite ou não continuidade na Exclusão
/*/
User Function A410EXC()
    local aArea     := GetArea()
    local aAreaSC5  := SC5->( GetArea() )
    local aAreaSC6  := SC6->( GetArea() )    
    local aAreaSC2  := SC2->( GetArea() )    
    local lRet      := .T.
    local cFilOrig  := GetMV( "RE_FILORIG", .F., "0302" ) 
    local lVerExcPd := GetMv( "RE_PEDDEST",,.T.)  //Ativa Verif. de Exclusão Pedido Destino
    local cFilDes   := SC5->C5_XFILDES
    local cPedDes   := SC5->C5_XPVDEST

    SC6->( dbSetOrder(1))
    SC2->( dbSetOrder(1))    
    SC5->( dbSetOrder(1))

    If lVerExcPd .And. ;
        SC5->C5_FILIAL == cFilOrig  .And. ;
        !Empty( cFilDes ) .And. ;
        !Empty( cPedDes )        

        If SC2->( dbSeek( cFilDes + cPedDes  ))
            Help(Nil, Nil, "EXISTOP" + cFilDes, Nil, "Não é permitido excluir esse pedido origem, pois existe um pedido destino [" + cFilDes + "-" + cPedDes + "] com ordem de produção.", 1, 0, Nil, Nil, Nil, Nil, Nil)
            lRet := .F.
        Endif

        If lRet .AND.  SC5->( dbSeek( cFilDes + cPedDes )) 
            If !Empty( SC5->C5_NOTA ) .OR.  !Empty( SC5->C5_SERIE )
                Help(Nil, Nil, "PVJAFAT" + cFilDes, Nil, "Não é permitido excluir esse pedido origem, pois existe um pedido destino [" + cFilDes + "-" + cPedDes + "] já faturado.", 1, 0, Nil, Nil, Nil, Nil, Nil)        
                lRet := .F.
            Endif           
        Endif

        If lRet .AND.  SC6->( dbSeek( cFilDes + cPedDes )) 
            If Alltrim(SC6->C6_XJAPROD) == "1"
                Help(Nil, Nil, "JAPROD" + cFilDes, Nil, "Não é permitido excluir esse pedido origem, pois existe um pedido destino [" + cFilDes + "-" + cPedDes + "] já produzido.", 1, 0, Nil, Nil, Nil, Nil, Nil)
                lRet := .F.
            Endif

            If !Empty( SC6->C6_NOTA ) .OR.  !Empty( SC6->C6_SERIE ) .OR.  SC6->C6_QTDENT > 0
                Help(Nil, Nil, "ITJAFAT" + cFilDes, Nil, "Não é permitido excluir esse pedido origem, pois existe um pedido destino [" + cFilDes + "-" + cPedDes + "] já faturado.", 1, 0, Nil, Nil, Nil, Nil, Nil)        
                lRet := .F.
            Endif
        Endif
    Endif

    If !IsBlind() .And. !lRet .And. FWAlertYesNo("Deseja realmente excluir o pedido origem [" + SC5->C5_FILIAL + "-" + SC5->C5_NUM + "]?", "Exclusão de Pedido Origem?")
        lRet := .T.
    EndIf

    RestArea( aAreaSC2 )
    RestArea( aAreaSC6 )    
    RestArea( aAreaSC5 )
    RestArea( aArea )

Return lRet
