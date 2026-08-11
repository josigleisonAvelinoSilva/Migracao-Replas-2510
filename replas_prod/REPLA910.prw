#Include 'Protheus.ch'

#DEFINE cFONTRed   '<b><font size="5" color="red"><b>'
#DEFINE cNOFONT    '</b></font></u></b>'

/*/{Protheus.doc} REPLA910
//Rotina que permite o usuário fazer estorno e exclusão do item ou do pedido de vendas.
@author Robson Gonçalves - Rleg
@since 09/03/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function REPLA910()
	Local aButton := {}
	Local aSay := {}
	
	Local nOpcao := 0
	
	Private cCadastro := 'Exclusão de Pedido de Vendas'
	
	AAdd( aSay, 'Esta programa tem como objetivo excluir os pedidos de vendas em situação de pedidos ')
	AAdd( aSay, 'em aberto, pedidos liberados e não faturados.')
	AAdd( aSay, '' )
	AAdd( aSay, '' )
	AAdd( aSay, '' )
	AAdd( aSay, 'Clique em OK para prosseguir...' )
	AAdd( aSay, 'F12 - Auditoria' )
		
	AAdd( aButton, { 01, .T., { || nOpcao := 1, FechaBatch() } } )
	AAdd( aButton, { 22, .T., { || FechaBatch() } } )
	
    SetKey( VK_F12, {|| R910Audit() } )
	
    FormBatch( cCadastro, aSay, aButton )
	
    SetKey( VK_F12, NIL )

	If nOpcao == 1
		R910Param()
	Endif
Return

/*/{Protheus.doc} R910Param
//Rotina para solicitar ao usuário os parâmetros de processamento.
@author Robson Gonçalves - Rleg
@since 09/03/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function R910Param()
    Local aPar := {}
    Local aRet := {}
	
    AAdd( aPar, {1,'Nº Pedido de' ,Space(6) ,'','','SC5','',50,.F.})
    AAdd( aPar, {1,'Nº Pedido até',Space(6) ,'','','SC5','',50,.T.})
    AAdd( aPar, {1,'Cliente de'   ,Space(6) ,'','','SA1CLI','',50,.F.})
    AAdd( aPar, {1,'Cliente até'  ,Space(6) ,'','','SA1CLI','',50,.T.})
    AAdd( aPar, {1,'Vendedor de'  ,Space(6) ,'','','SA3','',50,.F.})
    AAdd( aPar, {1,'Vendedor até' ,Space(6) ,'','','SA3','',50,.T.})
    AAdd( aPar, {1,'Produto de'   ,Space(15),'','','SB1','',80,.F.})
    AAdd( aPar, {1,'Produto até'  ,Space(15),'','','SB1','',80,.T.})
    AAdd( aPar, {1,'Emissão de'   ,Ctod('') ,'','','','',50,.F.})
    AAdd( aPar, {1,'Emissão até'  ,Ctod('') ,'','','(MV_PAR10>=MV_PAR09)','',50,.T.})
    AAdd( aPar, {1,'Entrega de'   ,Ctod('') ,'','','','',50,.F.})
    AAdd( aPar, {1,'Entrega até'  ,Ctod('') ,'','','(MV_PAR12>=MV_PAR11)','',50,.T.})
    
	If ParamBox( aPar, 'Parâmetros', @aRet )
        ProcessaDoc( {|| R910Process() }, cCadastro ,'Iniciando o processamento, aguarde...' )
	Endif
Return

/*/{Protheus.doc} R910Process
//Rotina de processamento dos dados conforme parâmetros.
@author Robson Gonçalves - Rleg
@since 09/03/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function R910Process()
    Local aCpos := {}
    Local aDados := {}
    Local cFrom := ''
    Local cOrder := ''
    Local cSelect := ''
    Local cSql := ''
    Local cSqlField := "SELECT C5_NUM "
    Local cSqlCount := ''
    Local cTRB := GetNextAlias()
    Local cWhere := ''
    Local nSqlCount := 0

    cSelect := "SELECT A1_NREDUZ, "
    cSelect += "       A3_NREDUZ, "
    cSelect += "       C5_NUM, "
    cSelect += "       C6_ITEM, "
    cSelect += "       C6_PRODUTO, "
    cSelect += "       C6_QTDVEN, "
    cSelect += "       C6_PRCVEN, "
    cSelect += "       C5_EMISSAO, "
    cSelect += "       C6_ENTREG, "
    cSelect += "       C6_QTDEMP, "
    cSelect += "       C6.R_E_C_N_O_ AS C6_RECNO "

    cFrom := "FROM "+RetSQLName("SC5")+" C5 "
    cFrom += "INNER JOIN "+RetSQLName("SA1")+" A1 "
    cFrom += "        ON A1_COD = C5_CLIENTE "
    cFrom += "           AND A1_LOJA = C5_LOJACLI "
    cFrom += "           AND A1.D_E_L_E_T_ = ' ' "
    cFrom += "INNER JOIN "+RetSQLName("SC6")+" C6 "
    cFrom += "        ON C6_FILIAL = "+ValToSql(xFilial("SC6"))+" "
    cFrom += "           AND C6_NUM = C5_NUM  "
    cFrom += "           AND C6.D_E_L_E_T_  = ' ' "
    cFrom += "LEFT JOIN "+RetSQLName("SA3")+" A3 "
    cFrom += "        ON A3_COD = C5_VEND1 "
    cFrom += "           AND A3.D_E_L_E_T_ = ' ' "

    cWhere := "WHERE C5_FILIAL = "+ValToSql(xFilial("SC5"))+" "
    cWhere += "      AND C5_NUM BETWEEN "+ValToSql(MV_PAR01)+" AND "+ValToSql(MV_PAR02)+" "
    cWhere += "      AND C5_CLIENT BETWEEN "+ValToSql(MV_PAR03)+" AND "+ValToSql(MV_PAR04)+" "
    cWhere += "      AND C5_VEND1 BETWEEN "+ValToSql(MV_PAR05)+" AND "+ValToSql(MV_PAR06)+" "
    cWhere += "      AND C6_PRODUTO BETWEEN "+ValToSql(MV_PAR07)+" AND "+ValToSql(MV_PAR08)+" "
    cWhere += "      AND C5_EMISSAO BETWEEN "+ValToSql(MV_PAR09)+" AND "+ValToSql(MV_PAR10)+" "
    cWhere += "      AND C6_ENTREG BETWEEN "+ValToSql(MV_PAR11)+" AND "+ValToSql(MV_PAR12)+" "
    cWhere += "      AND (C6_QTDVEN-C6_QTDENT)>0 "
    cWhere += "      AND C6_BLQ <> 'R' "
    cWhere += "      AND C6_NOTA = ' ' "
    cWhere += "      AND C5.D_E_L_E_T_ = ' ' "

    cOrder := "ORDER BY C5_FILIAL, C5_NUM, C6_ITEM "

   	cSqlCount := 'SELECT COUNT(*) nCOUNT FROM ( ' + ChangeQuery( cSqlField + cFrom + cWhere ) + ' ) QUERY '
    
   	DbUseArea( .T., 'TOPCONN', TCGENQRY(,,cSqlCount),'SQLCOUNT',.F.,.T.)
	nSqlCount := SQLCOUNT->nCOUNT
	SQLCOUNT->( DbCloseArea() )

   	If nSqlCount == 0
		MsgInfo('Não foi possível encontrar registros com os parâmetros informados.', cCadastro)
		Return
	Endif

	RegProcDoc( nSqlCount )
	
    cSql := cSelect + cFrom + cWhere + cOrder

	DbUseArea( .T., 'TOPCONN', TCGENQRY(,,cSql),cTRB,.F.,.T.)

    While (cTRB)->( .NOT. EOF() )
        IncProcDoc( 'Buscando os dados...' )

        AAdd( aDados, { .F. ,(cTRB)->A1_NREDUZ,;
        (cTRB)->A3_NREDUZ,;
        (cTRB)->C5_NUM,;
        (cTRB)->C6_ITEM,;
        (cTRB)->C6_PRODUTO,;
        Transform((cTRB)->C6_QTDVEN,'@E 999,999,999.99'),;
        Transform((cTRB)->C6_PRCVEN,'@E 999,999,999.99'),;
        Dtoc(Stod((cTRB)->C5_EMISSAO)),;
        Dtoc(Stod((cTRB)->C6_ENTREG)),;
        Transform((cTRB)->C6_QTDEMP,'@E 999,999,999.99'),;
        (cTRB)->C6_RECNO } )

        (cTRB)->( dbSkip() )
    End
    (cTRB)->(dbCloseArea())

    AAdd( aCpos, ' ' )
    AAdd( aCpos, 'Cliente' )
    AAdd( aCpos, 'Vendedor' )
    AAdd( aCpos, 'Nº Pedido' )
    AAdd( aCpos, 'Item PV' )
    AAdd( aCpos, FWX3Titulo('C6_PRODUTO' ) )
    AAdd( aCpos, FWX3Titulo('C6_QTDVEN' ) )
    AAdd( aCpos, FWX3Titulo('C6_PRCVEN' ) )
    AAdd( aCpos, FWX3Titulo('C5_EMISSAO' ) )
    AAdd( aCpos, FWX3Titulo('C6_ENTREG' ) )
    AAdd( aCpos, FWX3Titulo('C6_QTDEMP' ) )
    AAdd( aCpos, 'RECNO')

    R910Show(  aCpos, aDados )
Return

/*/{Protheus.doc} R910Show
//Rotina para apresentar os dados para o usuário fazer seleção.
@author Robson Gonçalves - Rleg
@since 09/03/2020
@version 1.0
@return ${return}, ${return_description}
@param aCpos, array, descricao
@param aDados, array, descricao
@type function
/*/
Static Function R910Show( aCpos, aDados )
	Local aC := {}
	Local aOrdem := {}
	
	Local cOrd := ''
	Local cSeek := Space( 100 )
	
	Local nOrd := 1
	
	Local oDlg 
    Local oExcl
	Local oOrdem 
	Local oPanelAll
	Local oPanelBot
	Local oPanelTop
	Local oPesq
    Local oSair
	Local oSeek
	
   	Local oMrk   := LoadBitmap(,'NGCHECKOK.PNG')
	Local oNoMrk := LoadBitmap(,'NGCHECKNO.PNG')

	AAdd( aOrdem, 'Cliente' )
	AAdd( aOrdem, 'Vendedor' )
	AAdd( aOrdem, 'Nº Pedido' )
	AAdd( aOrdem, 'Produto' )
	
	aC := FWGetDialogSize( oMainWnd )
	DEFINE MSDIALOG oDlg FROM aC[1],aC[2] TO aC[3]-50, aC[4]-50 TITLE cCadastro PIXEL OF oMainWnd STYLE DS_MODALFRAME STATUS
		oDlg:lEscClose := .F.
		
		oPanelTop := TPanel():New(0,0,'',oDlg,NIL,.F.,,,,0,19,.F.,.T.)
		oPanelTop:Align := CONTROL_ALIGN_TOP
		
        @ 1,001 COMBOBOX oOrdem VAR cOrd ITEMS aOrdem SIZE 80,36 ON CHANGE (nOrd:=oOrdem:nAt) PIXEL OF oPanelTop
		@ 1,082 MSGET    oSeek  VAR cSeek SIZE 160,9 PIXEL OF oPanelTop
		@ 1,243 BUTTON   oPesq  PROMPT 'Pesquisar' SIZE 40,11 PIXEL OF oPanelTop ACTION (R910Pesq(nOrd,cSeek,@oLbx))
		
		oPanelAll := TPanel():New(0,0,'',oDlg,NIL,.F.,,,,0,14,.F.,.T.)
		oPanelAll:Align := CONTROL_ALIGN_ALLCLIENT
		
		oPanelBot := TPanel():New(0,0,'',oDlg,NIL,.F.,,,,0,16,.F.,.T.)
		oPanelBot:Align := CONTROL_ALIGN_BOTTOM
		
		@ 2, 1 BUTTON oExcl PROMPT 'Prosseguir' ;
                            SIZE 42,11 ;
                            PIXEL OF oPanelBot ;
                            ACTION (Iif(AScan(oLbx:aArray,{|e| e[1]==.T.})>0,;
                                   (Iif(R010Resumo(@oLbx),(oDlg:End()),NIL)),;
                                   MsgInfo('Precisa selecionar registro para prosseguir.',cCadastro)))
        
		@ 2,46 BUTTON oSair PROMPT 'Sair' ;
		                      SIZE 42,11 ;
		                      PIXEL OF oPanelBot ;
		                      ACTION ( Iif( MsgYesNo( 'Realmente quer sair da rotina?', cCadastro ), ( oDlg:End() ), NIL ) )
    
        oLbx := TwBrowse():New(1,1,1000,1000,,aCpos,,oPanelAll,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
        oLbx:Align := CONTROL_ALIGN_ALLCLIENT
        oLbx:bLDblClick := {||  R910Mark(@oLbx)  }
        oLbx:SetArray(aDados)
        oLbx:bLine := {|| {Iif(aDados[oLbx:nAt,1],oMrk,oNoMrk),aDados[oLbx:nAt,2],;
        aDados[oLbx:nAt,3],aDados[oLbx:nAt,4],aDados[oLbx:nAt,5],aDados[oLbx:nAt,6],;
        aDados[oLbx:nAt,7],aDados[oLbx:nAt,8],aDados[oLbx:nAt,9],aDados[oLbx:nAt,10],;
        aDados[oLbx:nAt,11],aDados[oLbx:nAt,12]}}

	ACTIVATE MSDIALOG oDlg CENTERED
Return

/*/{Protheus.doc} R910Mark
//Rotina para marcar/desmarcar a seleção do que irá excluir.
@author Robson Gonçalves - Rleg
@since 09/03/2020
@version 1.0
@return ${return}, ${return_description}
@param oLbx, object, descricao
@type function
/*/
Static Function R910Mark( oLbx )
    Local i := 0
    Local cPV := ''
    Local lMark
    Local p := 0

    cPV := oLbx:aArray[ oLbx:nAt, 4 ]

    p := Ascan( oLbx:aArray, {|e| e[4]==oLbx:aArray[ oLbx:nAt, 4 ] } )

    lMark := oLbx:aArray[ oLbx:nAt, 1 ]

    For i := p To Len( oLbx:aArray )
        If oLbx:aArray[ i, 4 ] == cPV
            oLbx:aArray[ i, 1 ] := .NOT. lMark
        Else
            Exit
        Endif
    Next i
    oLbx:Refresh()
Return

/*/{Protheus.doc} R910Pesq
//Rotina que possibilita o usuário pesquisar o que deseja na tela.
@author Robson Gonçalves - Rleg
@since 09/03/2020
@version 1.0
@return ${return}, ${return_description}
@param nOrd, numeric, descricao
@param cSeek, characters, descricao
@param oLbx, object, descricao
@type function
/*/
Static Function R910Pesq( nOrd, cSeek, oLbx )
	Local aOrderNumber := {}
    Local bAScan := {|| .T. }

	Local nBegin := 0
	Local nColPesq := 0
	Local nEnd := 0
	Local nP := 0	
	
    aOrderNumber := {2,3,4,6}
    nColPesq := aOrderNumber[ nOrd ]

	If nColPesq > 0
		nBegin := Min( oLbx:nAt + 1, Len( oLbx:aArray ) )
		nEnd   := Len( oLbx:aArray )
		If oLbx:nAt == Len( oLbx:aArray )
			nBegin := 1
		Endif
		bAScan := {|p| Upper( AllTrim( cSeek ) ) $ AllTrim( p[nColPesq] ) } 
		nP := AScan( oLbx:aArray, bAScan, nBegin, nEnd )
		If nP > 0
			oLbx:nAt := nP
			oLbx:Refresh()
		Else
			nBegin := 1
			nP := AScan( oLbx:aArray, bAScan, nBegin, nEnd )
			If nP > 0
				oLbx:nAt := nP
				oLbx:Refresh()
				oLbx:SetFocus()
			Else
				MsgInfo('Produto não localizado.','Pesquisar')
			Endif
		Endif
	Endif
Return

/*/{Protheus.doc} R010Resumo
//Rotina que apresenta o resumo do que será excluído.
@author Robson Gonçalves - Rleg
@since 09/03/2020
@version 1.0
@return ${return}, ${return_description}
@param oLbx, object, descricao
@type function
/*/
Static Function R010Resumo( oLbx )
    Local aKey := {}
    Local aResumo := {}
    Local bSair
    Local bGoDel
    Local cDado := ''
    Local cMsg := ''
    Local i := 0
    Local j := 0
    Local lResumo := .F.
    Local nList := 0
    Local nT := 0
    Local nTrace := 150
    Local oBar
    Local oDlg
    Local oFnt := TFont():New('Arial',,,,.F.,,,8,.T.,,,,,,,)
    Local oFntBox := TFont():New( "Courier New",,-11)
    Local oPnl
    Local oPnlAll
    Local oThb1
    Local oThb2
    Local oTLbx

    cMsg := 'TEM  CERTEZA  QUE  QUER  REALMENTE  EXCLUIR  OS  PEDIDOS  DE  VENDAS<br>APRESENTADOS  '
    cMsg += 'NO  RESUMO  QUE  FORAM  SELECIONADOS  POR  VOCÊ?'

    AAdd( aResumo, Replicate( '-', nTrace ) )

    AAdd( aResumo, 'USUÁRIO (COD/NOME)..[' + __cUserID + '-' + UsrRetName( __cUserID ) + ']' )
    AAdd( aResumo, 'DATA/HORA...........[' + Dtoc(MsDate())+']' )
    AAdd( aResumo, 'IP COMPUTER.........[' + GetClientIP() +']' )
    AAdd( aResumo, 'NAME COMPUTER.......[' + GetComputerName() + ']' )

    AAdd( aResumo, Replicate( '-', nTrace ) )

    For i := 2 To Len( oLbx:aHeaders )-1
        nT := Max( Len( oLbx:aHeaders[ i ] ), Len( oLbx:aArray[ 1, i ] ) )
        cDado += PadR( oLbx:aHeaders[ i ], nT, ' ' ) + ' | '
    Next i

    cDado := SubStr( cDado, 1, Len( cDado )-2 )

    AAdd( aResumo, cDado )

    AAdd( aResumo, Replicate( '-', nTrace ) )

    For i :=  1 To Len( oLbx:aArray )
        If .NOT. oLbx:aArray[ i, 1 ]
            Loop
        Endif

        cDado := ''

        AAdd( aKey, { oLbx:aArray[ i, 4 ] + oLbx:aArray[ i, 5 ], '', NIL } )

        For j := 2 To Len( oLbx:aArray[ i ] )-1
            nT := Max( Len( oLbx:aHeaders[ j ] ), Len( oLbx:aArray[ 1, j ] ) )

            If ValType( oLbx:aArray[ i, j ] ) == 'N'
                cDado += PadL( LTrim( TransForm( oLbx:aArray[ i, j ], '@E 999,999,999.99' ) ), nT, ' ' ) + ' | '
            Else
                cDado += PadR( oLbx:aArray[ i, j ], nT, ' ' ) + ' | '
            Endif
        Next j

        cDado := SubStr( cDado, 1, Len( cDado )-2 )

        AAdd( aResumo, cDado )
    Next i

    AAdd( aResumo, Replicate( '-', nTrace ) )

    DEFINE MSDIALOG oDlg TITLE 'Resumo da exclusão do(s) pedido(s) de venda(s)' FROM 0,0 TO 360,750 PIXEL
		oPnlAll := TPanel():New(0,0,,oDlg,,,,,,13,0,.F.,.F.)
		oPnlAll:Align := CONTROL_ALIGN_ALLCLIENT
		
		oPnl := TPanel():New(0,0,,oDlg,,,,,,13,13,.F.,.F.)
		oPnl:Align := CONTROL_ALIGN_BOTTOM
		
		oBar := TBar():New( oPnl, 10, 9, .T.,'BOTTOM')

		bSair := {|| oDlg:End() }
		bGoDel := {|| lResumo := MsgYesNo(cFONTRed+cMsg+cNOFONT,cCadastro),;
		Iif(lResumo,(oDlg:End(),R910GoDel( aKey ),R910GrvLog(aResumo,aKey)),NIL) }

		oThb2 := THButton():New( 1, 1, '&Sair', oBar, bSair , 20, 12, oFnt ) ; oThb2:Align := CONTROL_ALIGN_RIGHT
		oThb1 := THButton():New( 1, 1, '&Excluir Pedidos', oBar, {|| MsAguarde(bGoDel,'Processando a exclusão','Iniciando processamento...', .F. ) }, 70, 12, oFnt ) ; oThb1:Align := CONTROL_ALIGN_RIGHT

		oTLbx := TListBox():New(0,0,{|u| Iif(PCount()>0,nList:=u,nList)},{},100,46,,oPnlAll,,,,.T.,,,oFntBox)
		oTLbx:Align := CONTROL_ALIGN_ALLCLIENT
		oTLbx:SetArray( aResumo )
		oTLbx:SetFocus()
	ACTIVATE MSDIALOG oDlg CENTERED
Return( lResumo )

/*/{Protheus.doc} R910GoDel
//Rotina que processa a exclusão do pedido de vendas.
@author Robson Gonçalves - Rleg
@since 09/03/2020
@version 1.0
@return ${return}, ${return_description}
@param aKey, array, descricao
@type function
/*/
Static Function R910GoDel( aKey )
    Local aCab := {}
	Local aLinha := {}
	Local aItens := {}
	 
	Local cPedido := ''
	 
    Local i := 0
	Local j := 0
	 
	Local nQtdItem := 0
	 
	Local p := 0
	 
	Private lMsErroAuto := .F.

    dbSelectArea( 'SC9' )
    dbSetOrder( 1 )

    dbSelectArea( 'SC5' )
    dbSetOrder( 1 )

    dbSelectArea( 'SC6' )
    dbSetOrder( 1 )

	// Estornar os pedidos de vendas.
    For i := 1 To Len( aKey )
		MsProcTxt('Estornando o pedido de venda ['+aKey[1,1]+']')
		ProcessMessage()

        If SC9->( dbSeek( xFilial('SC9')+ aKey[ i, 1 ] ) )
            If A460Estorna( .F., .T. )
                aKey[ i, 2 ] := 'PV estornado com sucesso.'
				aKey[ i, 3 ] := .T.
            Else
                aKey[ i, 2 ] := 'PV não estornado, não haverá tentativa de exclusão.'
				aKey[ i, 3 ] := .F.
            Endif
        Else
			aKey[ i, 2 ] := 'Não encontrei liberação do PV.'
			aKey[ i, 3 ] := .T.
		Endif
	Next i
	
	// Escluir o pedido de vendas. Se não conseguir, excluir o item do pedido de vendas.
	For i := 1 To Len( aKey )
		MsProcTxt('Excluindo o pedido de venda ['+aKey[i,1]+']')
		ProcessMessage()

		If aKey[ i, 3 ]
			
			cPedido := SubStr( aKey[ i, 1 ], 1, 6 )
			
			For j := i To Len( aKey )
				If SubStr( aKey[ j, 1 ], 1, 6 ) == cPedido
					nQtdItem++
				Else
					Exit
				Endif
			Next j
			
			SC5->( dbSeek( xFilial( 'SC5' ) + cPedido ) )
			
			AAdd( aCab, { 'C5_NUM'    , cPedido        , NIL } )
			AAdd( aCab, { 'C5_CLIENTE', SC5->C5_CLIENTE, NIL } )
			AAdd( aCab, { 'C5_LOJACLI', SC5->C5_LOJACLI, NIL } )
			
			SC6->( dbSeek( xFilial('SC6')+ cPedido ) )
			
			setupSC6( nQtdItem, @aLinha, @aItens, cPedido, @i, .F. )
			
			MSExecAuto( {|a, b, c| MATA410( a, b, c )}, aCab, aItens, 5 )
			
			// Se conseguiu excluir, vai para o próximo pedido ou saia do laço.
			If .NOT. lMsErroAuto
				p := AScan( aKey, {|e| SubStr( e[ 1 ], 1, 6 ) == cPedido } )
				For j := p To Len( aKey )
					If SubStr( aKey[ j, 1 ], 1 ,6 ) == cPedido
						aKey[ j, 2 ] += '| Pedido excluído com sucesso.'
					Else
						Exit
					Endif
				Next j
			Else
				// Se não conseguiu excluir o pedido, tente excluir o item do pedido.
				lMsErroAuto := .F.
				aLinha := {}
				aItens := {}
				
				SC6->( dbSeek( xFilial('SC6')+ cPedido ) )
				
				setupSC6( nQtdItem, @aLinha, @aItens, cPedido, @i, .T. )
				
				MSExecAuto( {|a, b, c| MATA410( a, b, c )}, aCab, aItens, 4 )
				
				// Se conseguiu excluir o item do pedido, vai para o próximo pedido ou saia do laço.
				If .NOT. lMsErroAuto
					p := AScan( aKey, {|e| SubStr( e[ 1 ], 1, 6 ) == cPedido } )
					For j := p To Len( aKey )
						If SubStr( aKey[ j, 1 ], 1 ,6 ) == cPedido
							aKey[ j, 2 ] += '| Item do pedido excluído com sucesso.'
						Else
							Exit
						Endif
					Next j
				Else
					// Se não conseguiu excluir o item do pedido, avise o usuário.
					p := AScan( aKey, {|e| SubStr( e[ 1 ], 1, 6 ) == cPedido } )
					For j := p To Len( aKey )
						If SubStr( aKey[ j, 1 ], 1 ,6 ) == cPedido
							aKey[ j, 2 ] += '| Tentativa de excluir o pedido e tentativa de excluir o item do pedido sem sucesso.'
						Else
							Exit
						Endif
					Next j
				Endif
			Endif
			lMsErroAuto := .F.
			aCab := {}
			aLinha := {}
			aItens := {}
			nQtdItem := 0
		Endif
	Next i
	MsProcTxt('Gravando o log para auditoria, aguarde...')
	ProcessMessage()
Return

/*/{Protheus.doc} setupSC6
//Rotina que elabora o array dos itens do pedido de vendas conforme necessidade de excluir o PV ou excluir o item do PV.
@author Robson Gonçalves - Rleg
@since 09/03/2020
@version 1.0
@return ${return}, ${return_description}
@param nQtdItem, numeric, descricao
@param aLinha, array, descricao
@param aItens, array, descricao
@param cPedido, characters, descricao
@param i, , descricao
@param lDelItem, logical, descricao
@type function
/*/
Static Function setupSC6( nQtdItem, aLinha, aItens, cPedido, i, lDelItem )
	If nQtdItem == 1
		If lDelItem
			AAdd( aLinha, { 'LINPOS'    , SC6->C6_ITEM   , NIL } )
			AAdd( aLinha, { 'AUTDELETA' , 'S'            , NIL } )
		Endif
		
		AAdd( aLinha, { 'C6_ITEM'   , SC6->C6_ITEM   , NIL } )
		AAdd( aLinha, { 'C6_PRODUTO', SC6->C6_PRODUTO, NIL } ) 
		AAdd( aItens, aLinha )
	Else
		While SC6->( .NOT. EOF() ) ;
			.AND. SC6->C6_FILIAL == xFilial( 'SC6' ) ;
			.AND. SC6->C6_NUM == cPedido
			
			If Len( aItens ) > 0
				i++
			Endif
			
			If lDelItem
				AAdd( aLinha, { 'LINPOS'    , SC6->C6_ITEM   , NIL } )
				AAdd( aLinha, { 'AUTDELETA' , 'S'            , NIL } )
			Endif
			
			AAdd( aLinha, { 'C6_ITEM'   , SC6->C6_ITEM   , NIL } )
			AAdd( aLinha, { 'C6_PRODUTO', SC6->C6_PRODUTO, NIL } ) 
			AAdd( aItens, aLinha )
			aLinha := {}
			SC6->( dbSkip() )
		End
	Endif
Return

/*/{Protheus.doc} R910GrvLog
//Rotina que grava o log do processamento.
@author Robson Gonçalves - Rleg
@since 09/03/2020
@version 1.0
@return ${return}, ${return_description}
@param aResumo, array, descricao
@param aKey, array, descricao
@type function
/*/
Static Function R910GrvLog( aResumo, aKey )
    Local i := 0
    Local nHdl := 0

    R910FileLog( @nHdl )

    For i := 1 To Len( aResumo )
        FWrite( nHdl, aResumo[ i ] + CRLF )
    Next i

	FWrite( nHdl, 'PEDIDO IT MENSAGEM DO PROCESSAMENTO' + CRLF )
	FWrite( nHdl, '-----------------------------------' + CRLF )

    For i := 1 To Len( aKey )
        FWrite( nHdl, SubStr( aKey[ i, 1 ], 1, 6 ) + ' ' +;
		              SubStr( aKey[ i, 1 ], 7, 2 ) + ' ' +;
					  aKey[ i, 2 ] + CRLF )
    Next i

    FClose( nHdl )
Return

/*/{Protheus.doc} R910FileLog
//Rotina que cria o arquivo de log no diretório específico.
@author Robson Gonçalves - Rleg
@since 09/03/2020
@version 1.0
@return ${return}, ${return_description}
@param nHdl, numeric, descricao
@type function
/*/
Static Function R910FileLog( nHdl )
    Local cData := Dtos(MsDate())
    Local cDir := '\del_pv\'
    Local cExtensao := '.log'
    Local cFile := ''
    Local cPrefixo := 'del_pv_'
    Local cSeconds := ''

    cSeconds := LTrim( Str( Int( Seconds() ) ) )
	cFile := cPrefixo + cData + '_' + cSeconds + cExtensao
    
    If .NOT. ExistDir( cDir )
	    FwMakeDir( cDir )
	Endif

	While .T.
		If File( cDir + cFile )
			Sleep( Randomize( 1, 999 ) )
			cSeconds := LTrim( Str ( Int( Seconds() ) ) )
	        cFile := cPrefixo + cData + '_' + cSeconds + cExtensao
		Else
			nHdl := FCreate( cDir + cFile )
			Exit
		Endif
	End	
Return

/*/{Protheus.doc} R910Audit
//Rotina que permite o usuário analisar os arquivos de log.
@author Robson Gonçalves - Rleg
@since 09/03/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function R910Audit()
	Local aDADOS := {'Selecione um arquivo para visualizar seu conteúdo...'}
	Local bSair := {|| oDlg:End() }
    Local cTitle := 'Auditoria de exclusão de pedido de vendas'
	Local cArq := ''
	Local cExt := 'Log exclusão de PV | del_pv*.log'
	Local nList := 0
	Local oBar
	Local oDlg
	Local oFnt := TFont():New('Arial',,,,.F.,,,8,.T.,,,,,,,)
	Local oFntBox := TFont():New( "Courier New",,-11)
	Local oPnlArq
	Local oPnlButton
	Local oPnlMaior
	Local oTLbx
	Local oThb
	
	DEFINE MSDIALOG oDlg TITLE cTitle FROM 0,0 TO 360,810 PIXEL
		
	oPnlArq := TPanel():New(0,0,,oDlg,,,,,,16,16,.F.,.F.)
	oPnlArq:Align := CONTROL_ALIGN_TOP
		
	@ 04,003 SAY 'Informe o arquivo' SIZE  65,07 PIXEL OF oPnlArq
	@ 03,050 MSGET cArq PICTURE '@!' SIZE 190,07 PIXEL OF oPnlArq
	@ 04,228 BUTTON '...'            SIZE  10,08 PIXEL OF oPnlArq ACTION cArq := cGetFile(cExt,'Selecione o arquivo',,'SERVIDOR\del_pv',.T.,1)
	@ 03,250 BUTTON 'Abrir'          SIZE  40,10 PIXEL OF oPnlArq ACTION R910Open( cArq, @oTLbx, @aDADOS, cTitle )
		
	oPnlMaior := TPanel():New(0,0,,oDlg,,,,,,13,0,.F.,.F.)
	oPnlMaior:Align := CONTROL_ALIGN_ALLCLIENT
		
	oPnlButton := TPanel():New(0,0,,oDlg,,,,,,13,13,.F.,.F.)
	oPnlButton:Align := CONTROL_ALIGN_BOTTOM
		
	oBar := TBar():New( oPnlButton, 10, 9, .T.,'BOTTOM')
		
	oThb := THButton():New( 1, 1, '&Sair', oBar, bSair , 20, 12, oFnt )
	oThb:Align := CONTROL_ALIGN_RIGHT
		
	oTLbx := TListBox():New(0,0,{|u| Iif(PCount()>0,nList:=u,nList)},{},100,46,,oPnlMaior,,,,.T.,,,oFntBox)
	oTLbx:Align := CONTROL_ALIGN_ALLCLIENT
	oTLbx:SetArray( aDADOS )
	oTLbx:SetFocus()
		
	ACTIVATE MSDIALOG oDlg CENTERED
Return

/*/{Protheus.doc} R910Open
//Rotina para abrir e ler o arquivo de log selecionado.
@author Robson Gonçalves - Rleg
@since 09/03/2020
@version 1.0
@return ${return}, ${return_description}
@param cArq, characters, descricao
@param oTLbx, object, descricao
@param aDADOS, array, descricao
@param cTitle, characters, descricao
@type function
/*/
Static Function R910Open( cArq, oTLbx, aDADOS, cTitle )
	If File( cArq )
		aDADOS := {}
		FT_FUSE( cArq )
		FT_FGOTOP()
		While .NOT. FT_FEOF()
			AAdd( aDADOS, FT_FREADLN() )
			FT_FSKIP()
		End
		FT_FUSE()
		oTLbx:SetArray( aDADOS )
		oTLbx:Refresh()
	Else
		MsgAlert( 'Arquivo informado não localizado, verifique...', cTitle )
	Endif
Return
