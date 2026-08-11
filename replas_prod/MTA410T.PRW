#INCLUDE "PROTHEUS.CH"


/*/{Protheus.doc} MTA410T
Ponto de entrada para validar todos os itens do pedido
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 11/05/2022
/*/
User Function MTA410T()
    Local cPedido   := SC5->C5_NUM
    Local cFilOrig  := GetMV( "RE_FILORIG", .F., "0302" )
    Local cFilDest  := GetMV( "RE_FILDEST", .F., "0201" )
    Local lIntIndMM := GetMV( "RE_INTIND", .F., .T. ) //-- Parametro geral que indica se a integracao de pedidos com a industria mm (Filial 0201) esta ativa

    If IsInCallStack("U_REESTA02") .Or. IsInCallStack("U_REFATA06")
        Return
    EndIf

    //-- Verifica se existe FILME/BOPP no pedido de venda
    If lIntIndMM .And. U_REFATA02( 2, cPedido )
        If SC5->C5_FILIAL = cFilOrig
            ExecPVRmt( cPedido, cFilOrig, cFilDest )
        EndIf
    EndIf

Return


/*/{Protheus.doc} ExecPVRmt
Rotina que inicia a inclusao/alteracao do pedido remoto,
apos a liberacao se nao houver bloqueio de credito
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 11/05/2022
@param cPedido, character, Pedido de Venda
@param cFilOrig, character, Filial origem
@param cFilDest, character, Filial destino
@obs Projeto Novo PCP (Ajustes MOTOR)
/*/
Static Function ExecPVRmt( cPedido, cFilOrig, cFilDest )
	Local aArea     := GetArea()
    Local aAreaSC6  := SC6->( GetArea() )
    Local aAreaSC9  := SC9->( GetArea() )
    Local aAreaSF4  := SF4->( GetArea() )
    Local aItLibCre := {}
    Local aPVRmt    := {}
    Local cPVDest   := ""
    Local nOpc      := 3
    Local cXFilOri := GetMV( "RE_FILORIG", .F., "0302" )
    Local cXFilDes := GetMV( "RE_FILDEST", .F., "0201" )
    Local lAtuDest  := .T. 

    DbSelectArea("SC6")
    SC6->( DbSetOrder(1) )

    DbSelectArea("SC9")
    SC9->( DbSetOrder(1) )

    DbSelectArea("SF4")
    SF4->( DbSetOrder(1) )

    If SC9->( DbSeek( xFilial("SC9") + cPedido ) )
        While SC9->( !Eof() ) .And. SC9->C9_PEDIDO == cPedido
            If SC6->( DbSeek( xFilial("SC6") + SC9->(C9_PEDIDO + C9_ITEM) ) ) .And.;
               SF4->( DbSeek( xFilial("SF4") + SC6->C6_TES ) ) .And.;
               SF4->F4_DUPLIC == "S"

                If !Empty( SC9->C9_BLCRED )
                    aAdd( aItLibCre, { cPedido, SC9->C9_ITEM, SC9->C9_BLCRED } )
                    Exit
                EndIf
            EndIf

            SC9->( DbSkip() )
        EndDo
    EndIf

    aItLibCre := {}
    
    If Empty(aItLibCre)
        //-- Retorna o Pedido de Venda Remoto, se o mesmo existir
        aPVRmt := U_REFATA03( SC5->C5_FILIAL, SC5->C5_NUM )

        If aPVRmt[01]
            //cFilDest := aPVRmt[02]
            cPVDest  := aPVRmt[03]
            nOpc     := 4
        EndIf
        
        If nOpc == 4 .And. !Empty( cPVDest )
           //Só Altera Destino caso não tenha ocorrido Faturamento
           lAtuDest := fFatDest( cFilDest, cPVDest  ) 
        Endif
                
        //-- Chama a rotina de Inclusao/Alteracao dos Pedidos de Venda Destino
        If lAtuDest 
            U_REFATA01( { cEmpAnt       ,; //-- Empresa
                        SC5->C5_FILIAL,; //-- Filial Origem
                        SC5->C5_NUM   ,; //-- Pedido Origem
                        cFilDest      ,; //-- Filial Destino
                        cPVDest       ,; //-- Pedido Destino
                        nOpc }         ) //-- Tipo operacao
        Endif                      
    ElseIf !Empty(aItLibCre) .And. !IsBlind() .And. ALTERA .And. !Empty(SC5->C5_XFILDES) .And. !Empty(SC5->C5_XPVDEST)
        FWAlertWarning("A alteração do pedido da filial [" + cXFilDes + "] somente será concluida após a liberação do crédito do pedido origem da filial [" + cXFilOri + "].", "Alteração Pedido " + cXFilDes + "!")
    Endif

    RestArea( aAreaSF4 )
    RestArea( aAreaSC9 )
    RestArea( aAreaSC6 )
    RestArea( aArea )

Return


Static Function fFatDest( cFilDest, cPVDest  )
    local aArea     := GetArea()
    local lAtualiza := .T.
    local cQuery    := ""

    cQuery := " SELECT COUNT(*) REGS " + CRLF
    cQuery += " FROM " + RetSqlName("SD2") + " D2 " + CRLF
    cQuery += " WHERE D2.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += " AND D2_FILIAL = '" + cFilDest + "' " + CRLF
    cQuery += " AND D2_PEDIDO = '" + cPvDest + "' " + CRLF

    DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "XDEST", .F., .T. )

    If XDEST->( !Eof()) .AND. XDEST->REGS >= 1
        lAtualiza := .F.
    Endif 
 
    XDEST->( dbCloseArea() )

    RestArea( aArea )
Return lAtualiza
