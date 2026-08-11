/*/{Protheus.doc} User Function M450Leg
    Ponto de entrada acionado após a montagem do array de cores para o Browse da rotina de liberação de crédito MATA450.
    @type  User Function
    @author Robson Gonçalves - RLEG
    @since 22/09/2020
    @version 12.1.27
    @param aLegenda, array, títulos e cores das legendas.
    @return aNewLegend, array, títulos e cores das legendas.
    /*/
User Function M450Leg()
    Local aNewCores := {}
    Local aParam := {}

    aParam := AClone( ParamIXB )

    ChkPadrao( aParam )

    aNewCores := {;
    { "C9_BLCRED=='  ' .And. C9_BLEST=='  ' .And. Iif(SC9->((FieldPos('C9_BLTMS') > 0)), Empty(C9_BLTMS), .T.)",'ENABLE' },;//Item Liberado
    { "(C9_BLCRED=='10'.And.C9_BLEST=='10').Or.(C9_BLCRED=='ZZ'.And.C9_BLEST=='ZZ')",'DISABLE'},;//Item Faturado
    { "!C9_BLCRED=='  ' .And.C9_BLCRED <> '09' .And. C9_BLCRED<>'10' .And. C9_BLCRED<>'ZZ'",'BR_BRANCO'},;//Item Bloqueado - Credito
    { "C9_BLCRED=='09'",'BR_MARROM'},;//Item Bloqueado - Credito	
    { "!C9_BLEST=='  '.And. C9_BLEST<>'10'.And.C9_BLEST<>'ZZ'",'BR_PRETO'},;//Item Bloqueado - Estoque
    { "C9_BLWMS<='05'.And.!C9_BLWMS=='  '",'BR_AMARELO'},;//Item Bloqueado - WMS
    { "Iif(SC9->((FieldPos('C9_BLTMS') > 0)), !Empty(C9_BLTMS), .F.)"  ,'BR_LARANJA'}}//Item Bloqueado - TMS

Return( aNewCores )

/*/{Protheus.doc} ChkPadrao
    Montar a estrutura igual o padrão para comparar.
    @type  Static Function
    @author Robson Gonçalves - RLEG
    @since 22/09/2020
    @version 12.1.27
    /*/
Static Function ChkPadrao( aParam )
    Local aCores := {}

    aCores := {;
    { "C9_BLCRED=='  ' .And. C9_BLEST=='  ' .And. Iif(SC9->((FieldPos('C9_BLTMS') > 0)), Empty(C9_BLTMS), .T.)",'ENABLE' },;//Item Liberado
    { "(C9_BLCRED=='10'.And.C9_BLEST=='10').Or.(C9_BLCRED=='ZZ'.And.C9_BLEST=='ZZ')",'DISABLE'},;//Item Faturado
    { "!C9_BLCRED=='  ' .And.C9_BLCRED <> '09' .And. C9_BLCRED<>'10' .And. C9_BLCRED<>'ZZ'",'BR_AZUL'},;//Item Bloqueado - Credito
    { "C9_BLCRED=='09'",'BR_MARROM'},;//Item Bloqueado - Credito	
    { "!C9_BLEST=='  '.And. C9_BLEST<>'10'.And.C9_BLEST<>'ZZ'",'BR_PRETO'},;//Item Bloqueado - Estoque
    { "C9_BLWMS<='05'.And.!C9_BLWMS=='  '",'BR_AMARELO'},;//Item Bloqueado - WMS
    { "Iif(SC9->((FieldPos('C9_BLTMS') > 0)), !Empty(C9_BLTMS), .F.)"  ,'BR_LARANJA'}}//Item Bloqueado - TMS

    U_ChkLegCor( aParam, aCores )
Return
