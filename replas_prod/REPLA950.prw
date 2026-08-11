#Include 'Protheus.ch'

STATIC aCell := { 1, 2, 3, 4, 5 }

#DEFINE PRETO  '#000000'
#DEFINE BRANCO '#FFFFFF'
#DEFINE CINZA  '#BFBFBF'

/*/{Protheus.doc} REPLA950
    Relatório de llistagem de cargas.
    @type  User Function
    @author Robson Gonçalves - RLEG
    @since 23/09/2020
    /*/
User Function REPLA950()
    Local aSay := {}
    
    Local nOpc := 0

    Private cTitulo := 'Listagem de Cargas - ®Replas'

    AAdd( aSay, 'Este programa gera a listagem de cargas de acordo com os parâmetros informados pelo' )
    AAdd( aSay, 'usuário e com as montagens de cargas efetuadas.' )
    AAdd( aSay, ' ' )
    AAdd( aSay, 'Clique em avançar par prosseguir... ' )

    ShowForm( cTitulo, aSay, @nOpc)

    iF nOpc == 1
        ParamUsr()
    Endif
Return

/*/{Protheus.doc} ProcQuery
    Processamento da query.
    @type  Static Function
    @author Robson Gonçalves - RLEG
    @since 23/09/2020
    /*/
Static Function ProcQuery()
    Local cSQL := ''
    Local cTRB := GetNextAlias()
    Local nCount := 0

    cSQL := "SELECT DAK_FILIAL, "
    cSQL += "       DAK_COD, "
    cSQL += "       DAK_SEQCAR, "
    cSQL += "       DAK_ROTEIR, "
    cSQL += "       DAK_PESO, "
    cSQL += "       DAK_FEZNF, "
    cSQL += "       DAK_TRANSP, "
    cSQL += "       DAK_DATA, "
    cSQL += "       A4_NREDUZ,    "
    cSQL += "       DAK_CAMINH, "
    cSQL += "       DAK_MOTORI, "
    cSQL += "       DA3_COD, "
    cSQL += "       DA3_DESC, "
    cSQL += "       DA3_PLACA, "
    cSQL += "       DA3_TIPVEI, "
    cSQL += "       DAI_PEDIDO, "
    cSQL += "       DAI_PESO, "
    cSQL += "       DAI_ROTA, "
    cSQL += "       DAI_ROTEIR, "
    cSQL += "       C9_PRODUTO, "
    cSQL += "       C6_DESCRI, "
    cSQL += "       C9_QTDLIB, "
    cSQL += "       C9_QTDLIB2, "
    cSQL += "       C5_CLIENTE, "
    cSQL += "       C5_LOJACLI, "
    cSQL += "       C5_CLIENT, "
    cSQL += "       C5_LOJAENT "
    cSQL += "  FROM "+RetSqlName("DAK")+" DAK "
    cSQL += "       INNER JOIN "+RetSqlName("DA3")+" DA3  "
    cSQL += "               ON DA3_FILIAL = "+ValToSQL(FWxFilial("DA3"))+" "
    cSQL += "                  AND DA3_COD = DAK_CAMINH "
    cSQL += "                  AND DA3_ATIVO = '1' "
    cSQL += "                  AND DA3.D_E_L_E_T_ = ' ' "
    cSQL += "       INNER JOIN "+RetSqlName("DAI")+" DAI "
    cSQL += "               ON DAI_FILIAL = "+ValToSQL(FWxFilial("DAI"))+" "
    cSQL += "                  AND DAI_COD = DAK_COD "
    cSQL += "                  AND DAI_SEQCAR = DAK_SEQCAR "
    cSQL += "                  AND DAI.D_E_L_E_T_ = ' ' "
    cSQL += "       INNER JOIN "+RetSqlName("SA4")+" SA4 "
    cSQL += "               ON A4_FILIAL = "+ValToSQL(FWxFilial("SA4"))+" "
    cSQL += "                  AND A4_COD = DAK_TRANSP "
    cSQL += "                  AND SA4.D_E_L_E_T_ = ' ' "
    cSQL += "       INNER JOIN "+RetSqlName("SC9")+" SC9 "
    cSQL += "               ON C9_FILIAL = "+ValToSQL(FWxFilial("SC9"))+" "
    cSQL += "                  AND C9_PEDIDO = DAI_PEDIDO "
    cSQL += "                  AND C9_CARGA = DAI_COD "
    cSQL += "                  AND C9_SEQCAR = DAI_SEQCAR "
    cSQL += "                  AND C9_SEQENT = DAI_SEQUEN "
    cSQL += "                  AND SC9.D_E_L_E_T_ = ' ' "
    cSQL += "       INNER JOIN "+RetSqlName("SC6")+" SC6 "
    cSQL += "               ON C6_FILIAL = "+ValToSQL(FWxFilial("SC6"))+" "
    cSQL += "                  AND C6_NUM = C9_PEDIDO "
    cSQL += "                  AND C6_ITEM = C9_ITEM "
    cSQL += "                  AND SC6.D_E_L_E_T_ = ' ' "
    cSQL += "       INNER JOIN "+RetSqlName("SC5")+" SC5 "
    cSQL += "               ON C5_FILIAL = "+ValToSQL(FWxFilial("SC5"))+" "
    cSQL += "                  AND C5_NUM = C9_PEDIDO "
    cSQL += "                  AND SC5.D_E_L_E_T_ = ' ' "
    cSQL += " WHERE DAK_FILIAL = "+ValToSQL(FWxFilial("DAK"))+" "
    cSQL += "       AND DAK_COD BETWEEN "+ValToSQL(MV_PAR01)+" AND "+ValToSQL(MV_PAR02)+" "
    cSQL += "       AND DAK_DATA BETWEEN "+ValToSQL(MV_PAR03)+" AND "+ValToSQL(MV_PAR04)+" "
    cSQL += "       AND DAK.D_E_L_E_T_ = ' '  "
    cSQL += "ORDER BY DAK_COD, "
    cSQL += "         DAK_SEQCAR, "
    cSQL += "         DAK_ROTEIR "

	countRecord( cSQL, @nCount )
	
	If nCount == 0
		FwAlertInfo('Não foi possível encontrar registros com os parâmetros informados.', cTitulo)
		Return
	Endif
	
	RegProcDoc( nCount )
	
	DbUseArea( .T., 'TOPCONN', TCGENQRY(,,cSQL),cTRB,.F.,.T.)

	ProcView( cTRB )
Return

/*/{Protheus.doc} ProcView
    Processamento da view.
    @type  Static Function
    @author Robson Gonçalves - RLEG
    @since 23/09/2020
    /*/
Static Function ProcView( cTRB )
    Local aHead1 := {}
    Local aHead2 := {}
    Local aHead3 := {}
    Local aItemPV := {}

    Local cBai := ''
    Local cCarga := ''
    Local cCli := ''
    Local cEnd := ''
    Local cMun := ''
    Local cPed := ''
    Local cPict := '@E 999,999'

    Local cVazio := '  '
    Local cWorkSheet := ''

    Local i := 0

    Local nQtd1UM := 0
    Local nQtd2UM := 0

    Private cDirTmp := ''
    Private cFile := ''
    
    Private oFwMsEx

	cDirTmp := GetTempPath()
	cFile := CriaTrab( NIL, .F. ) + '.xls'

	cTable := 'LISTAGEM DE CARGA [ de ' + MV_PAR01 + ' até ' + MV_PAR02 +;
	          ' - Data de ' + Dtoc( MV_PAR03 ) + ' até ' + Dtoc( MV_PAR04 ) + ' ] Emissão: ' + Dtoc( MsDate() ) + ' ' + Time()

    cWorkSheet := 'CARGAS'

    dbSelectArea( 'SA1' )
    dbSetOrder( 1 )

	oFwMsEx := FWMsExcelEx():New()
	oFwMsEx:AddWorkSheet( cWorkSheet )
	oFwMsEx:AddTable( cWorkSheet, cTable )

    oFwMsEx:AddColumn( cWorkSheet, cTable , cVazio, 1, 1 )
    oFwMsEx:AddColumn( cWorkSheet, cTable , cVazio, 1, 1 )
    oFwMsEx:AddColumn( cWorkSheet, cTable , cVazio, 1, 1 )
    oFwMsEx:AddColumn( cWorkSheet, cTable , cVazio, 1, 1 )
    oFwMsEx:AddColumn( cWorkSheet, cTable , cVazio, 1, 1 )

    aHead1 := {'Nº CARGA','PESO TOTAL','TRANSPORTADORA','VEÍCULO','MODELO'}
    aHead2 := {'Nº PEDIDO','CLIENTE','ENDEREÇO','BAIRRO','MUNICÍPIO/UF'}
    aHead3 := {'DESCR. PRODUTO','PESO','SACOS',cVazio,cVazio}

	While (cTRB)->( .NOT. EOF() ) 
        oFwMsEx:SetCelBold(.T.)
        oFwMsEx:SetCelFrColor(BRANCO)
        oFwMsEx:SetCelBgColor(PRETO)
        
        oFwMsEx:AddRow( cWorkSheet, cTable, aHead1, aCell )
        oFwMsEx:AddRow( cWorkSheet, cTable, { (cTRB)->DAK_COD,;
                                              LTrim(TransForm((cTRB)->DAK_PESO,cPict)),;
                                              (cTRB)->DAK_TRANSP + ' ' + AllTrim((cTRB)->A4_NREDUZ),;
                                              (cTRB)->DA3_COD,;
                                              AllTrim((cTRB)->DA3_DESC)}, aCell )
        oFwMsEx:SetCelBold(.F.)

        cCarga := (cTRB)->DAK_COD

        While (cTRB)->( .NOT. EOF() ) .AND. (cTRB)->DAK_COD == cCarga
            IncProcDoc( 'Carga ' + (cTRB)->DAK_COD )

            If (cTRB)->C5_CLIENTE == (cTRB)->C5_CLIENT
                SA1->( MsSeek( FwxFilial( 'SA1') + (cTRB)->C5_CLIENTE + (cTRB)->C5_LOJACLI ) )
                cCli := (cTRB)->C5_CLIENTE
                cEnd := AllTrim( SA1->A1_END )
                cBai := AllTrim( SA1->A1_BAIRRO )
                cMun := AllTrim( SA1->A1_MUN ) + ' / ' + SA1->A1_EST
            Else
                SA1->( MsSeek( FwxFilial( 'SA1') + (cTRB)->C5_CLIENT + (cTRB)->C5_LOJAENT ) )
                cCli := (cTRB)->C5_CLIENT
                cEnd := AllTrim( SA1->A1_ENDENT )
                cBai := AllTrim( SA1->A1_BAIRROE )
                cMun := AllTrim( SA1->A1_MUNE ) + '/' + SA1->A1_ESTE
            Endif

            oFwMsEx:SetCelFrColor(PRETO)
            oFwMsEx:SetCelBgColor(BRANCO)

            oFwMsEx:SetCelUnderLine(.T.)
            oFwMsEx:SetCelBold(.T.)
            oFwMsEx:AddRow( cWorkSheet, cTable, aHead2, aCell )
            oFwMsEx:SetCelUnderLine(.F.)
            oFwMsEx:SetCelBold(.F.)
            oFwMsEx:AddRow( cWorkSheet, cTable, { (cTRB)->DAI_PEDIDO, cCli + '-' + Alltrim(SA1->A1_NREDUZ), cEnd, cBai, cMun }, aCell )       
            
            oFwMsEx:SetCelItalic(.T.)
            cPed := (cTRB)->DAI_PEDIDO

            While (cTRB)->( .NOT. EOF() ) .AND. (cTRB)->DAK_COD == cCarga .AND. (cTRB)->DAI_PEDIDO == cPed
                AAdd( aItemPV, { AllTrim((cTRB)->C6_DESCRI),;
                                 LTrim(TransForm((cTRB)->C9_QTDLIB,cPict)),;
                                 LTrim(TransForm((cTRB)->C9_QTDLIB2,cPict)),cVazio,cVazio } )
                nQtd1UM += (cTRB)->C9_QTDLIB
                nQtd2UM += (cTRB)->C9_QTDLIB2
                (cTRB)->( dbSkip() )
            End
            
            oFwMsEx:SetCelUnderLine(.T.)
            oFwMsEx:SetCelBold(.T.)
            oFwMsEx:AddRow( cWorkSheet, cTable, aHead3, aCell )
            oFwMsEx:SetCelUnderLine(.F.)
            oFwMsEx:SetCelBold(.F.)

            For i := 1 To Len( aItemPV )
                If i == Len( aItemPV )
                    aItemPV[ i, 4 ] := 'OBSERV'
                    aItemPV[ i, 5 ] := Replicate('_',30)
                Endif
                oFwMsEx:AddRow( cWorkSheet, cTable, aItemPV[ i ], aCell )
            Next i
            
            oFwMsEx:SetCelFrColor(PRETO)
			oFwMsEx:SetCelBgColor(CINZA)
            oFwMsEx:SetCelBold(.T.)
            oFwMsEx:AddRow( cWorkSheet, cTable, { 'TOTAL DO PEDIDO >>>',;
                                                  LTrim(TransForm(nQtd1UM,cPict)),;
                                                  LTrim(TransForm(nQtd2UM,cPict)),cVazio,cVazio}, aCell )

            oFwMsEx:SetCelItalic(.F.)
            oFwMsEx:SetCelFrColor(PRETO)
			oFwMsEx:SetCelBgColor(BRANCO)
            oFwMsEx:SetCelBold(.F.)

            oFwMsEx:AddRow( cWorkSheet, cTable, { cVazio, cVazio, cVazio, cVazio, cVazio }, aCell )

            aItemPV := {}
            nQtd1UM := 0
            nQtd2UM := 0
        End
    End

    (cTRB)->( dbCloseArea() )

    FwMsgRun(,{|| oFwMsEx:Activate(), OpenXML( cFile ) },,'Gerando a planilha com os dados...')
Return

/*/{Protheus.doc} OpenXML
    Rotina para abertura do arquivo de planilha Excel.
    @type  Static Function
    @author Robson Gonçalves - RLEG
    @since 23/09/2020
    /*/
Static Function OpenXML( cFile )
	Local nTentar := 0
	
	Local oExcelApp
	
	LjMsgRun( 'Gerando o arquivo Ms-Excel, por favor, aguarde...', cTitulo, {|| oFwMsEx:GetXMLFile( cFile ), Sleep( 1000 ) } )
	
	If __CopyFile( cFile, cDirTmp + cFile )
		If ApOleClient( 'MsExcel' )
			While .T.
				nTentar++
				If nTentar <= 3
					oExcelApp := MsExcel():New()
					oExcelApp:WorkBooks:Open( cDirTmp + cFile )
					oExcelApp:SetVisible(.T.)
					oExcelApp:Destroy()
					If FWAlertYesNo()( 'O Ms-Excel conseguiu abrir a planilha de dados gerado pelo ERP Protheus?'+CRLF+CRLF+;
					'[ Tentativa '+LTrim(Str(nTentar))+'/3 ]', cTitulo )
						Exit
					Endif
				Else
					MsgInfo( 'Se o Ms-Excel não conseguiu abrir a planilha de dados gerada pelo ERP Protheus, '+;
					'solicite a área de TI para buscar o arquivo no seguinte endereço: ' + cDirTmp + cFile, cTitulo )
					Exit
				Endif
			End
		Else
			MsgAlert( 'MsExcel não instalado. Para abrir o arquivo, localize-o na pasta %temp%.', cTitulo )
		Endif
	Else
		MsgInfo( 'Arquivo não copiado para temporário do usuário, por favor, tente gerar novamente.', cTitulo )
	Endif
Return

/*/{Protheus.doc} OpenXML
    Rotina para contagem de registros.
    @type  Static Function
    @author Robson Gonçalves - RLEG
    @since 23/09/2020
    /*/
Static Function countRecord( cSQL, nCount )
	Local cCount := ''
	Local cTRB := 'SQL' + LTrim( Str( Int( Seconds() ) ) )

	cCount := 'SELECT COUNT(*) nCOUNT FROM ( ' + cSQL + ' ) QUERY '
	
	If At('ORDER BY', Upper(cCount)) > 0
		cCount := SubStr( cCount, 1, At( 'ORDER BY', cCount )-1 ) + SubStr( cCount, RAt( ')', cCount ) )
	Endif
	
	cCount := ChangeQuery( cCount )
	
	DbUseArea( .T., 'TOPCONN', TCGENQRY(,,cCount),cTRB,.F.,.T.)
	nCount := (cTRB)->nCOUNT
	(cTRB)->( DbCloseArea() )
Return

/*/{Protheus.doc} ParamUsr
    Rotina para solicitar os parâmetros do usuário.
    @type  Static Function
    @author Robson Gonçalves - RLEG
    @since 23/09/2020
    /*/
Static Function ParamUsr()
	Local aPar := {}
	Local aRet := {}

	AAdd( aPar, { 1, 'A partir da carga',Space(Len(DAK->DAK_COD)),'','','DAK', '', 50, .F. } )
	AAdd( aPar, { 1, 'Até a carga'      ,Space(Len(DAK->DAK_COD)),'','','DAK', '', 50, .T. } )

	AAdd( aPar, { 1, 'A partir da data',Ctod('  /  /    '),'','','', '', 60, .F. } )
	AAdd( aPar, { 1, 'Até a data'      ,Ctod('  /  /    '),'','','', '', 60, .T. } )

	If ParamBox( aPar, 'Parâmetros de processamento', @aRet )
		ProcessaDoc( {|| ProcQuery() }, cTitulo ,'Iniciando o processamento, aguarde...' )
	Endif
Return

/*/{Protheus.doc} ShowForm
    Rotina para solicitar os parâmetros ao usuário.
    @type  Static Function
    @author Robson Gonçalves - RLEG
    @since 23/09/2020
    /*/
Static Function ShowForm( cDialogTitle, aDialogSay, nDialogOpc )
    Local aObjSay := {}
    Local bAvancar
    Local bVoltar
    
    Local i := 0
    Local nLin := 20 

    Local oContainer
    Local oDialog
    Local oFnt := TFont():New('Verdana',,16,,.T.,,,,,.F.,.F.)
    Local oPanel

    aObjSay := Array( Len( aDialogSay ) )

	bAvancar := {|| nDialogOpc := 1, oDialog:DeActivate() }
	bVoltar  := {|| Iif(FWAlertNoYes('Tem certeza que deseja sair da rotina?',cDialogTitle),(nDialogOpc := 0, oDialog:DeActivate()),NIL)}

	oDialog := FWDialogModal():New()

	oDialog:SetBackground( .T. )
	oDialog:SetTitle( cDialogTitle )
	oDialog:SetSize( 150, 300 )
	oDialog:EnableFormBar( .T. )
	oDialog:SetCloseButton( .F. )
	oDialog:SetEscClose( .F. )
	oDialog:CreateDialog()
	oDialog:CreateFormBar()
	oDialog:AddButton( 'Avançar', bAvancar, 'Avançar', , .T., .F., .T., )
	oDialog:AddButton( 'Voltar' , bVoltar , 'Voltar' , , .T., .F., .T., )
	
	//oDialog:AddYesNoButton()
	
    oPanel := oDialog:GetPanelMain()

	oContainer := TPanel():New( ,,, oPanel ) 
	oContainer:Align := CONTROL_ALIGN_ALLCLIENT

    For i := 1 To Len( aDialogSay )
        cTextSay:= "{||'" + aDialogSay[ i ] + "'}"
	    aObjSay[ i ] := TSay():New( nLin, 5, MontaBlock( cTextSay ),oContainer,, oFnt, .F., .F., .F., .T.,,, 350, 10, .F., .F., .F., .F., .F. )
        nLin += 10
    Next i

    oDialog:Activate()
	//lRet := Iif(oDialog:GetButtonSelected()>0,.T.,.F.)//pegando a resposta do usuario na tela.
Return
