#include 'protheus.ch'
#include 'parmtype.ch'


/*/{Protheus.doc} MTA450I
Replicacao da Regra do PT.mt450fim
@type function
@version 1.0
@author Marcos P.Aversa
@since 03/03/2023
@return variant, gravacao do Pedido Destino
/*/
user function MTA450I()
	Local axArea     := GetArea()
    Local cPedido    := SC9->C9_PEDIDO
    Local cVldReser  := GetNewPar("MV_XVLDRES","S")
    Local lXRLSMOTOR := IsInCallStack("U_XRLSMOTOR")
    Local cFilOrig   := GetMV( "RE_FILORIG", .F., "0302" )
    Local cFilDest   := GetMV( "RE_FILDEST", .F., "0201" )
	Local lIntIndMM  := GetMV( "RE_INTIND", .F., .T. ) //-- Parametro geral que indica se a integracao de pedidos com a industria mm (Filial 0201) esta ativa

  	If !lXRLSMOTOR .And. lIntIndMM .And. U_REFATA02( 2, cPedido )
        If SC5->C5_FILIAL = cFilOrig
		    ExecPVRmt( cPedido, cFilOrig, cFilDest )
        EndIf
	ElseIf !lXRLSMOTOR .and. cVldReser == "S"
		FwMsgRun(, {|| u_xValdRes(cPedido) }, , 'Validando Reserva, aguarde...')
	EndIf
    
	RestArea(axArea)
    
return 


/*/{Protheus.doc} ExecPVRmt
Rotina que inicia a inclusao/alteracao do pedido remoto apos a liberacao de credito
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 14/05/2022
@param cPedido, character, Pedido de Venda
@param cFilOrig, character, Filial origem
@param cFilDest, character, Filial destino
@obs Projeto Novo PCP (Ajustes MOTOR)
/*/
Static Function ExecPVRmt( cPedido, cFilOrig, cFilDest )
	Local aArea     := GetArea()
    Local aAreaSC9  := SC9->( GetArea() )
    Local aItLibCre := {}
    Local aPVRmt    := {}
    Local cPVDest   := ""
    Local nOpc      := 3

    DbSelectArea("SC9")
    SC9->( DbSetOrder(1) )

    If SC9->( DbSeek( xFilial("SC9") + cPedido ) )
        While SC9->( !Eof() ) .And. SC9->C9_PEDIDO == cPedido
            If !Empty( SC9->C9_BLCRED )
                aAdd( aItLibCre, { cPedido, SC9->C9_ITEM, SC9->C9_BLCRED, SC9->C9_BLEST } )
                Exit
            EndIf

            SC9->( DbSkip() )
        EndDo
    EndIf

    If Empty(aItLibCre)	
        //-- Retorna o Pedido de Venda Remoto, se o mesmo existir
        aPVRmt := U_REFATA03( SC5->C5_FILIAL, SC5->C5_NUM )

        If aPVRmt[01]
            //cFilDest := aPVRmt[02]
            cPVDest  := aPVRmt[03]
            nOpc     := 4
        EndIf

        //-- Chama a rotina de Inclusao/Alteracao dos Pedidos de Venda Destino
        U_REFATA01( { cEmpAnt       ,; //-- Empresa
                      SC5->C5_FILIAL,; //-- Filial Origem
                      SC5->C5_NUM   ,; //-- Pedido Origem
                      cFilDest      ,; //-- Filial Destino
                      cPVDest       ,; //-- Pedido Destino
                      nOpc }         ) //-- Tipo operacao
    Endif

    RestArea( aAreaSC9 )
    RestArea( aArea )

Return
