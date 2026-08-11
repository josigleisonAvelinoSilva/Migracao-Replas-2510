#Include 'Protheus.Ch'

/*/{Protheus.doc USER FUNCTION REPLA940
    @author ROBSON GONÇALVES - RLEG
    @since 21/09/2020
    @return lógico - função acionada pelo X3_VLDUSER dos campos C6_QTDVEN, C6_TES, C6_LOCAL.
    /*/
User Function REPLA940()
    Local aArea := {}

    Local cC6_LOCAL := ''
    Local cC6_PRODUTO := ''
    Local cC6_TES := ''
    Local cReadVar := ''

    Local lRet := .T.

    Local nC6_QTDVEN := 0
    Local nSaldo := 0
    Local cFilOrig := GetMV("RE_FILORIG", .F., "0302")
    
    // Se não for interface de usuário, sair.
    If IsBlind()
        Return( .T. )
    Endif

    // Se parâmetro da rotina estiver desligado, sair.
    If GetNewPar( 'MV_XVLDEST', '1') <> '1'
        Return( .T. )
    Endif

    // Se for execução pelo motor, sair.
    If IsInCallStack( 'XRLSMOTOR' )
        Return( .T. )
    Endif

    // Se não for para estas filiais, sair.
    If .NOT. (FwCodFil() $ '0101|0102|0103|' + cFilOrig)
        Return( .T. )
    Endif

    // Capturar o código do produto.
    cC6_PRODUTO := aCOLS[ n, GdFieldPos( 'C6_PRODUTO' ) ]

    // Qual campo acionou a rotina?
    cReadVar := ReadVar()

    If cReadVar == 'M->C6_QTDVEN'
        nC6_QTDVEN := M->C6_QTDVEN
    Else
        nC6_QTDVEN := aCOLS[ n, GdFieldPos( 'C6_QTDVEN' ) ]
    Endif

    If cReadVar == 'M->C6_LOCAL'
        cC6_LOCAL := M->C6_LOCAL
    Else
        cC6_LOCAL := aCOLS[ n, GdFieldPos( 'C6_LOCAL' ) ]
    Endif

    If cReadVar == 'M->C6_TES'
        cC6_TES := M->C6_TES
    Else
        cC6_TES := aCOLS[ n, GdFieldPos( 'C6_TES' ) ]
    Endif

    // Se todos os campos não estiverem preenchidos, sair.
    If Empty( cC6_PRODUTO ) .OR. nC6_QTDVEN == 0 .OR. Empty( cC6_LOCAL ) .OR. Empty( cC6_TES )
        Return( .T. )
    Endif 

    // Salvar as áreas e seus atributos.
    aArea := { GetArea(), SB1->( GetArea() ), SB2->( GetArea() ), SC0->( GetArea() ), SF4->( GetArea() ) }

    dbSelectArea( 'SB1 ')
    dbSetOrder( 1 )
    MsSeek( FWxFilial( 'SB1' ) + cC6_PRODUTO )

    // Se o produto não fizer parte do grupo 2 e 3, sair.
    If .NOT. ( SB1->B1_XGRUPO $ '2|3' )
        RestArea( aArea[ 2 ] )
        Return( .T. )
    Endif

    // Buscar o saldo atual do produto.
    dbSelectArea( 'SB2' )
    dbSetOrder( 1 )
    If SB2->( MsSeek( FWxFilial( 'SB2') + cC6_PRODUTO + cC6_LOCAL ) )
       nSaldo := SaldoSB2()
    Endif

    // Em caso de alteração do pedido considerar a diferenca para compor o saldo da SB2
    If Type('ALTERA') == 'L' .AND. ALTERA
        SC0->( dbSetOrder( 1 ) )
        If SC0->( MsSeek( FWxFilial( 'SC0' ) + M->C5_NUM + cC6_PRODUTO ) )
            nSaldo := nSaldo + SC0->C0_QTDORIG
        Endif
    EndIf

    If nC6_QTDVEN > nSaldo
        SF4->( dbSetOrder( 1 ) )
        If SF4->( MsSeek( FWxFilial( 'SF4' ) + cC6_TES ) )  
            If SF4->F4_ESTOQUE == 'S'
                lRet := .F.	
            Endif
        Endif
    Endif

    If .NOT. lRet
        MsgCritical( Alltrim( cC6_PRODUTO ), cC6_LOCAL, nC6_QTDVEN, nSaldo )
    Endif

    // Restaurar as áreas e seus atributos.
    AEval( aArea, {|xArea| RestArea( xArea ) } )
Return( lRet )

/*/{Protheus.doc} Static Function MsgCritical
    Função para enviar uma mensagem de critica via interface para ao usuário.
    @type  Static Function
    @author ROBSON GNCALVES - RLEG
    /*/
Static Function MsgCritical( cProd, cLocal, nQtde, nSaldo )
    Local aSay := Array (8)

    Local cPict := X3Picture( 'C6_QTDVEN' )

	Local oContainer
    Local oFntFx := TFont():New('Verdana',,18,,.T.,,,,,.F.,.F.)
    Local oFntVar := TFont():New('Courier',,20,,.T.,,,,,.F.,.F.)
    Local oModal

	oModal  := FWDialogModal():New()        
	oModal:setEscClose( .F. )
    oModal:setCloseButton( .F. )
	oModal:setTitle( 'ATENÇÃO - SALDO INSUFICIENTE' )
    oModal:setSubTitle( 'NÃO SERÁ POSSÍVEL GRAVAR O PEDIDO DE VENDAS.')
	oModal:setSize( 140, 300 )
	oModal:createDialog()
	oModal:addCloseButton({|| oModal:Deactivate() }, 'Ok, entendi' )

	oContainer := TPanel():New( ,,, oModal:getPanelMain() ) 
	oContainer:Align := CONTROL_ALIGN_ALLCLIENT
	
    @ 20,05 SAY aSay[ 1 ] PROMPT 'CÓDIGO DO PRODUTO: '  SIZE 100,50 FONT oFntFx OF oContainer PIXEL
    @ 30,05 SAY aSay[ 2 ] PROMPT 'ARMAZÉM INDICADO: '   SIZE 100,50 FONT oFntFx OF oContainer PIXEL
    @ 40,05 SAY aSay[ 3 ] PROMPT 'QTDE A SER VENDIDA: ' SIZE 100,50 FONT oFntFx OF oContainer PIXEL
    @ 50,05 SAY aSay[ 4 ] PROMPT 'SALDO DISPONÍVEL: '   SIZE 100,50 FONT oFntFx OF oContainer PIXEL

    @ 20,105 SAY aSay[ 5 ] PROMPT cProd  SIZE 100,50 FONT oFntVar COLOR CLR_HRED OF oContainer PIXEL
    @ 30,105 SAY aSay[ 6 ] PROMPT cLocal SIZE 100,50 FONT oFntVar COLOR CLR_HRED OF oContainer PIXEL
    @ 40,105 SAY aSay[ 7 ] PROMPT LTrim( TransForm( nQtde, cPict ) )  SIZE 100,50 FONT oFntVar COLOR CLR_HRED OF oContainer PIXEL
    @ 50,105 SAY aSay[ 8 ] PROMPT LTrim( TransForm( nSaldo, cPict ) ) SIZE 100,50 FONT oFntVar COLOR CLR_HRED OF oContainer PIXEL

	oModal:Activate()
Return

