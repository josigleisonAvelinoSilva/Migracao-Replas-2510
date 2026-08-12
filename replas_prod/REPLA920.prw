#Include 'Protheus.ch'

STATIC aC6_RECNO := {}

User Function R920Begin()
	Local aArea := SC6->(GetArea())
    Local cSQL := ''
    Local cTRB := GetNextAlias()
    Local i := 0
    Local nElem := 0
    Local nFCount := 0

    dbSelectArea('SC6')
	dbSetOrder(1)
	dbCommit() //-- Atualiza as gravacoes pendentes na tabela

    cSQL := "SELECT C6_FILIAL, "
    cSQL += "       C6_NUM, "
    cSQL += "       C6_ITEM, "
    cSQL += "       R_E_C_N_O_ AS C6_RECNO "
    cSQL += "  FROM "+RetSqlName("SC6")+" SC6 "
    cSQL += " WHERE C6_FILIAL = "+ValToSql(xFilial("SC6"))+" "
    cSQL += "       AND C6_NUM = "+ValToSql(SC5->C5_NUM)+" "
    cSQL += "       AND (C6_BLOQUEI = '01'  "
    cSQL += "	         OR C6_BLOQUEI = '02') "
    cSQL += "       AND SC6.D_E_L_E_T_ = ' ' "
    cSQL += " ORDER BY 1, "
    cSQL += "          2, "
    cSQL += "          3 "

	cSQL := ChangeQuery( cSQL )
	dbUseArea( .T., 'TOPCONN', TCGENQRY(,, cSQL ), cTRB, .F., .T. )
    nFCount := (cTRB)->(FCount())

    aC6_RECNO := {}
    While (cTRB)->( .NOT. EOF() )
        AAdd( aC6_RECNO, Array( nFCount ) )
        nElem := Len( aC6_RECNO )
        For i := 1 To nFCount
            aC6_RECNO[ nElem, i ] := (cTRB)->( FieldGet( i ) )
        Next i
        (cTRB)->( dbSkip() )
    End
    (cTRB)->( dbCloseArea() )
    SC6->( dbGoTo( RecNo() ) )
    RestArea( aArea )
Return

User Function R920End()
    Local cDado := ''
    Local i := 0
    Local nHdl := 0

    If Len(aC6_RECNO) > 0
        R920FileLog( @nHdl, aC6_RECNO[ 1, 1 ], aC6_RECNO[ 1, 2 ] )

        FWrite( nHdl, Replicate( '-', 40 ) + CRLF )
        FWrite( nHdl, '*** LOG DE LIBERAÇÃO DE PV POR REGRA ***' + CRLF  )
        FWrite( nHdl, Replicate( '-', 40 ) + CRLF )
        FWrite( nHdl, 'USUÁRIO (COD/NOME)..[' + RetCodUsr() + '-' + UsrRetName( RetCodUsr() ) + ']' + CRLF  )
        FWrite( nHdl, 'DATA/HORA...........[' + Dtoc(MsDate())+']' + CRLF  )
        FWrite( nHdl, 'IP MÁQUINA..........[' + GetClientIP() +']' + CRLF  )
        FWrite( nHdl, 'NOME MÁQUINA........[' + GetComputerName() + ']' + CRLF  )
        FWrite( nHdl, Replicate( '-', 40 )  + CRLF )
        FWrite( nHdl, 'FILIAL PEDIDO ITEM RECNO' + CRLF )
        //             0101xxx123456x11xxx999999

        For i := 1 To Len( aC6_RECNO )
            cDado := aC6_RECNO[ i, 1 ] + '   ' + aC6_RECNO[ i, 2 ] + '  ' + aC6_RECNO[ i, 3 ] + '   ' + LTrim( Str( aC6_RECNO[ i, 4 ] ) )
            FWRITE( nHdl, cDado + CRLF  )
        Next i
        FWrite( nHdl, Replicate( '-', 40 )  + CRLF )
        FClose( nHdl )
        aC6_RECNO := {}
    Endif
Return

Static Function R920FileLog( nHdl, cFIL, cPV )
    Local cData := Dtos(MsDate())
    Local cDir := '\lib_pv_regra\'
    Local cExtensao := '.log'
    Local cFile := ''
    Local cPrefixo := 'pv_regra'
    Local cSeconds := ''

    cSeconds := LTrim( Str( Int( Seconds() ) ) )
	cFile := cPrefixo + '_' + cData + '_' + cSeconds + '_' + cFIL + '_' + cPV + cExtensao
    
    If .NOT. ExistDir( cDir )
	    FwMakeDir( cDir )
	Endif

	While .T.
		If File( cDir + cFile )
			Sleep( Randomize( 1, 999 ) )
			cSeconds := LTrim( Str ( Int( Seconds() ) ) )
            cFile := cPrefixo + '_' + cData + '_' + cSeconds + '_' + cFIL + '_' + cPV + cExtensao
		Else
			nHdl := FCreate( cDir + cFile )
			Exit
		Endif
	End	
Return

User Function REPLA920()
	Local aButton := {}
	Local aSay := {}
	
	Local nOpcao := 0
	
	Private cCadastro := 'Auditoria de LOG - Liberação de PV por Regra'
	
	AAdd( aSay, 'Este programa permite visualizar o log gerado na liberação do pedido de vendas')
	AAdd( aSay, 'por regra')
	AAdd( aSay, '' )
	AAdd( aSay, '' )
	AAdd( aSay, '' )
	AAdd( aSay, '' )
	AAdd( aSay, 'Clique em OK para prosseguir...' )
		
	AAdd( aButton, { 01, .T., { || nOpcao := 1, FechaBatch() } } )
	AAdd( aButton, { 22, .T., { || FechaBatch() } } )
	
    FormBatch( cCadastro, aSay, aButton )
	
	If nOpcao == 1
		R920Audit()
	Endif

Return

Static Function R920Audit()
	Local aDADOS := {'Selecione um arquivo para visualizar seu conteúdo...'}
	Local bSair := {|| oDlg:End() }
    Local cTitle := 'Auditoria de log de liberação de pedido de venda por regra'
	Local cArq := ''
	Local cExt := 'Log | *.log'
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
	@ 04,228 BUTTON '...'            SIZE  10,08 PIXEL OF oPnlArq ACTION cArq := cGetFile(cExt,'Selecione o arquivo',NIL,'SERVIDOR\lib_pv_regra',.T.,1,NIL,NIL)
    @ 03,250 BUTTON 'Abrir'          SIZE  40,10 PIXEL OF oPnlArq ACTION R920Open( cArq, @oTLbx, @aDADOS, cTitle )
	
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

Static Function R920Open( cArq, oTLbx, aDADOS, cTitle )
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
