/*/{Protheus.doc} User Function MA450Cor
    Ponto de entrada acionado antes de apresentar a legenda na rotina de liberação de crédito MATA450.
    @type  User Function
    @author Robson Gonçalves - RLEG
    @since 22/09/2020
    @version 12.1.27
    @param aLegenda, array, títulos e cores das legendas.
    @return aNewLegend, array, títulos e cores das legendas.
    /*/
User Function MA450Cor()
    Local aNewLegend := {}
    Local aParam := {}

    aParam := AClone( ParamIXB )

    ChkPadrao( aParam )

    AAdd( aNewLegend, { "ENABLE"    , "Liberado" } )
    AAdd( aNewLegend, { "DISABLE"   , "Faturado" } )
    AAdd( aNewLegend, { "BR_BRANCO" , "Bloqueado no credito - ®Replas" } )
    AAdd( aNewLegend, { "BR_MARROM" , "Rejeitado" } )
    AAdd( aNewLegend, { "BR_PRETO"  , "Bloqueado no estoque" } )

    If !__lPyme
        AAdd( aNewLegend, { "BR_AMARELO", "Bloqueado - WMS" } )
        AAdd( aNewLegend, { "BR_LARANJA", "Bloqueado - TMS" } )
    EndIf

Return( aNewLegend )

/*/{Protheus.doc} ChkPadrao
    Montar a estrutura igual o padrão para comparar.
    @type  Static Function
    @author Robson Gonçalves - RLEG
    @since 22/09/2020
    @version 12.1.27
    /*/
Static Function ChkPadrao( aParam )
    Local aLegenda := {}

    AAdd( aLegenda, { "ENABLE"    , "Liberado" } )
    AAdd( aLegenda, { "DISABLE"   , "Faturado" } )
    AAdd( aLegenda, { "BR_AZUL"   , "Bloqueado - Credito" } )
    AAdd( aLegenda, { "BR_MARROM" , "Rejeitado" } )
    AAdd( aLegenda, { "BR_PRETO"  , "Bloqueado - Estoque" } )

    If !__lPyme
        AAdd( aLegenda, { "BR_AMARELO", "Bloqueado - WMS" } )
        AAdd( aLegenda, { "BR_LARANJA", "Bloqueado - TMS" } )
    Endif

    U_ChkLegCor( aParam, aLegenda )
Return

/*/{Protheus.doc} ChkLegCor
    Verificar se a estrutura do array de cores e legenda que o padrão fornece é igual a que está no ponto de entrada, do contrário criticar.
    @type  Static Function
    @author Robson Gonçalves - RLEG
    @since 22/09/2020
    @version 12.1.27
    /*/
User Function ChkLegCor( aParam, aLegenda )
    Local i := 0
    Local lDiff := .F. 

    If Len( aParam ) == Len( aLegenda )
        For i := 1 To Len( aParam )
            If aParam[ i, 1 ] <> aLegenda[ i, 1 ] .OR. aParam[ i, 2 ] <> aLegenda[ i, 2 ]
                lDiff := .T.
                Exit
            Endif
        Next i
    Else
        lDiff := .T.
    Endif

    If lDiff
        FwAlertWarning('O ponto de entrada MA450Cor identificou divergência nas legendas padrões do Protheus. Informe o administrador do sistema','Divergência de legenda')
    Endif
Return
