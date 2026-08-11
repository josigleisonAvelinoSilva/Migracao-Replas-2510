

*-------------------*
User Function M460FIM		//PE - APOS FATURAMENTO
*-------------------*
Local aArea 	:= GetArea()
Local aAreaSD2	:= SD2->(GetArea())	//Salva a area atual da tabela SD2
Local aAreaSF2	:= SF2->(GetArea())	//Salva a area atual da tabela SF2
Local nQtdVol	:= 0
Local cDoc		:= ""
Local cSerie	:= ""
Local cCliente	:= ""
Local cLoja		:= ""
Local aPedido	:= {}
Local nI		:= 0
Local cVldReser := GetNewPar("MV_XVLDRES","S")
Local lVldMotor	:= .T.
Local cVldForMot:= GetNewPar("MV_XVLDFOR","")
Local cFilResev := GetMv( "RE_FILRSV", .F., "0101/0102/0103/0302/" ) //-- Filiais que teram a inclusao de Reservas. by Dener Lemos

If IsInCallStack("U_REESTA02")
	Return
EndIf

// Posicona Itens da Nota Fiscal                     
DbSelectArea("SD2")
DbSetOrder(3)	// D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA + D2_COD + D2_ITEM
If DbSeek(xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA)
	cDoc		:= SD2->D2_DOC
	cSerie		:= SD2->D2_SERIE
	cCliente	:= SD2->D2_CLIENTE
	cLoja		:= SD2->D2_LOJA
	SC0->(DbSetOrder(1))
	If SD2->(Found())
		While SD2->(!Eof()) .And. SD2->D2_DOC + SD2->D2_SERIE + SD2->D2_CLIENTE + SD2->D2_LOJA == SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA
			nQtdVol := nQtdVol + SD2->D2_QTSEGUM
			
			If Ascan(aPedido,{|x|  x = SD2->D2_PEDIDO }) == 0
				aadd(aPedido, SD2->D2_PEDIDO )
			Endif
	
			SD2->(DbSkip())
		End
		If nQtdVol > 0
			// Posiciona Cabeçalho da Nota Fiscal
			DbSelectArea("SF2")
			DbSetOrder(1)	// F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA + F2_FORMUL + F2_TIPO
			If DbSeek(xFilial("SF2") + cDoc + cSerie + cCliente + cLoja)
				If SF2->(Found())
					Begin Transaction
						RecLock("SF2",.F.)
						SF2->F2_VOLUME1 := nQtdVol
						MsUnlock("SF2")
					End Transaction
				EndIf
			Else
				MsgRun("Não atualizou o campo Volume com a Qtde da 2ª Unidade de Medida !!!" ,,{|| Sleep(4000) })
			EndIf
		EndIf
	EndIf
Else
	MsgRun("Não achou a Nota Fiscal !!! - " + cDoc,,{|| Sleep(4000) })
EndIf

// Tratamento para gravar os dados bancarios do Pedido de Venda no Titulo do Contas a Receber (Eduardo A. Pereira)
If !Empty(SC5->C5_BANCO) .And. SC5->C5_CONDPAG <> "001"
	cChave	:= SE1->(E1_FILIAL + E1_CLIENTE + E1_LOJA + E1_PREFIXO + E1_NUM)
	// Posiciona na Tabela do Contas a Receber
	DbSelectArea("SE1")
	SE1->(DbSetOrder(2))	// E1_FILIAL + E1_CLIENTE + E1_LOJA + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
	If SE1->( DbSeek(cChave) )
		While SE1->(!Eof()) .And. cChave == SE1->(E1_FILIAL + E1_CLIENTE + E1_LOJA + E1_PREFIXO + E1_NUM)
			SE1->(RecLock("SE1",.F.))
			SE1->E1_PORTADO	:= SC5->C5_BANCO
			SE1->E1_AGEDEP	:= SC5->C5_XAGENCI
			SE1->E1_CONTA	:= SC5->C5_XNUMCON
			SE1->(MsUnlock())
			SE1->(DbSkip())
		EndDo
	EndIf
EndIf
  
//PONTO DE ENTRADA - JOSE CARLOS_________[TOTVS]
If ExistBlock('RPMONTABOR') .and. cFilAnt == "0101"
	ExecBlock('RPMONTABOR')
EndIf 

//PONTO DE ENTRADA PARA CHAMADA DO MOTOR DE PROCESSO - GUSTAVO______[TOTVS]
If ExistBlock('RPEXECPE') .And. GetMV('RP_XMOTOR',.F.,.T.)
	//(TSM David-26/05/18)Tratamento para tratamento de poder de 3o armazem bandeirante que não deve executar motor
	If SF2->F2_TIPO = "B" .AND. Alltrim(SF2->(F2_CLIENTE+F2_LOJA)) $ cVldForMot
		lVldMotor := MsgYesNo('<FONT COLOR="red" SIZE="5">Motor deve ser executado para NF <b>'+SF2->F2_DOC+'/'+SF2->F2_SERIE+'</b> ?</FONT>')
	Else
		lVldMotor := .T.
	EndIf
	
	If lVldMotor
		Public _lUseRPEXECPE := iIF(Type('_lUseRPEXECPE')=='U', iif(Alltrim(FunName()) $ 'MATA461,MATA460B,MATA460A' ,.T.,.F.) ,.F.)
		ExecBlock('RPEXECPE',.F.,.F.,'MATA460')
		//_lUseRPEXECPE := nil
	EndIf
EndIf 

If cFilAnt $ cFilResev .and. cVldReser == "S"
	For nI:=1 to len(aPedido)
		FwMsgRun(, {|| u_xValdRes(aPedido[nI]) }, , 'Validando Reserva, aguarde...')
	Next
EndIf

RestArea(aAreaSF2)
RestArea(aAreaSD2)
RestArea(aArea)

Return

*-------------------*
User Function MA650GRPV		//PE - GRAVACAO DA OP
*-------------------*
Local cSql	:= ""
Local cFilOrig  := GetMV( "RE_FILORIG", .F., "0302" )
Local cFilDest  := GetMV( "RE_FILDEST", .F., "0201" )
Local lIntIndMM := GetMV( "RE_INTIND", .F., .T. ) //-- Parametro geral que indica se a integracao de pedidos com a industria mm (Filial 0201) esta ativa

If ( lIntIndMM .And. cFilAnt == cFilDest ) .Or.;
   ( lIntIndMM .And. cFilAnt == cFilOrig .And. IsInCallStack("U_REFATA06") )

	Return
EndIf

//(David-TSM) Reposicionado a tabela SC2 para que seja executado
//motor para todos os itens da ordem de produção
cSql	+= " SELECT R_E_C_N_O_ RECC2 "
cSql	+= " FROM "+RetSqlName("SC2")
cSql	+= " WHERE "
cSql	+= " C2_FILIAL = '"+xFilial("SC2")+"' AND "
cSql	+= " C2_PEDIDO = '"+SC6->C6_NUM+"' AND "
cSql	+= " C2_ITEMPV = '"+SC6->C6_ITEM+"' AND "
cSql	+= " D_E_L_E_T_ = ' ' "

If Select("TRBC2") > 0
	TRBC2->(DbCloseArea())
EndIf

dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBC2",.F.,.T.)

If !TRBC2->(EoF()) .AND. TRBC2->RECC2 <> SC2->(Recno()) 
	SC2->(DbGoTo(TRBC2->RECC2))
EndIf

TRBC2->(DbCloseArea())

//PONTO DE ENTRADA PARA CHAMADA DO MOTOR DE PROCESSO
If ExistBlock('RPEXECPE') .And. GetMV('RP_XMOTOR',.F.,.T.)
	ExecBlock('RPEXECPE',.F.,.F.,'MATA650')
	Public _lUseRPEXECPE := Nil
	Pergunte("MTA650",.F.)
EndIf
Return    


//--
User Function A250ETRAN()
	Local aAreaAnt  := GetArea()
	Local aAreaSC5  := SC5->(GetArea())
	//Local cFilOrig  := GetMV( "RE_FILORIG", .F., "0302" )
	Local cFilDest  := GetMV( "RE_FILDEST", .F., "0201" )
	Local lIntIndMM := GetMV( "RE_INTIND", .F., .T. ) //-- Parametro geral que indica se a integracao de pedidos com a industria mm (Filial 0201) esta ativa

	If lIntIndMM .And. cFilAnt == cFilDest 
		If Empty(SC2->C2_XFILORI) .Or. Empty(SC2->C2_XPVORIG) .Or. Empty(SC2->C2_PEDIDO) .Or. Empty(SC2->C2_ITEMPV)
			dbSelectArea("SC5")
			SC5->(dbSetOrder(1))

			//-- Pocisiona no pedido para ser possivel pegar a "Filial" e o "Numero do Pedido"
			SC5->(dbSeek(xFilial("SC5") + SC2->C2_NUM)) 

            //-- Faz o preenchimento da "Filial" e "Numero do Pedido" que originou a ordem de producao
            RecLock("SC2", .F.)
                SC2->C2_XFILORI := SC5->C5_XFILORI
                SC2->C2_XPVORIG := SC5->C5_XPVORIG
                SC2->C2_PEDIDO  := SC2->C2_NUM
                SC2->C2_ITEMPV  := SC2->C2_ITEM
            SC2->(MsUnlock())

			RestArea(aAreaSC5)
			RestArea(aAreaAnt)
		EndIf

		//-- Chama a rotina de Inclusao para o Novo Motor 
		U_REFATA8B()
		Return
	EndIf

	If lIntIndMM .And. IsInCallStack( "U_REFATA06" )
		Return
	EndIf

	//PONTO DE ENTRADA PARA CHAMADA DO MOTOR DE PROCESSO
	If ExistBlock('RPEXECPE') .And. GetMV('RP_XMOTOR',.F.,.T.)
		ExecBlock('RPEXECPE',.F.,.F.,'MATA250')
		Public _lUseRPEXECPE := Nil
		Pergunte("MTA250",.F.)
	EndIf

Return    


*----------------------*
User Function MT410CPY		//PE - COPIAR PEDIDO DE VENDA
*----------------------*                                  
Local _lRet   := .T.

If GetMV('RP_XMOTOR',.F.,.T.)
	M->C5_XMOTOR := CriaVar('C5_XMOTOR')
EndIf

//-- Limpa os campos de controle de producao entre as filiais
M->C5_XTOLERA := 0
M->C5_XFILORI := ""
M->C5_XPVORIG := ""
M->C5_XFILDES := ""
M->C5_XPVDEST := ""
M->C5_XCLIORI := ""

Return(_lRet)           
           
*--------------------*
User Function SF2520E		//PE - EXCLUSAO DOCUMENTO DE SAIDA (FATURAMENTO)
*--------------------*                                  
Local _lRet   := .T.

If ExistBlock('RPMOTORC5') .And. GetMV(	'RP_XMOTOR',.F.,.T.)
	_lRet := ExecBlock('RPMOTORC5',.F.,.F.,)
EndIf

Return(_lRet)                                   

*-------------------*
User Function MT103FIM		//PE - APOS ENTRADA DA NOTA
*-------------------*  
Local nOpcao 	:= paramixb[1]
Local nConfirma	:= paramixb[2]

Local cSerNot := "1  "
Local aArea := GetArea()
Local cUsrCompl:= GetNewPar( "MV_XUSRCMP", "000000,000056,000009" ) //usuários para validação de NF de complemento
Local cUsrExec := RetCodUsr()
Local cUpd	   := ""
Local lVldMotor	:= .T.
Local cVldForMot:= GetNewPar("MV_XVLDFOR","")
Local cFilOrig  := GetMV( "RE_FILORIG", .F., "0302" )
//Local cFilDest  := GetMV( "RE_FILDEST", .F., "0201" )
Local aAreaSD1  := {}
Local aItensSD1 := {}

If IsInCallStack("U_REESTA02") .Or.;
   !Empty( SF1->(F1_FILORIG + F1_CLIORI + F1_LOJAORI) ) .Or.;
   IsInCallStack("U_REFATA06")
   
	Return
EndIf

//-- Verifica se existem produtos do tipo Filme na documento de entrada
If cFilAnt == cFilOrig .And. U_REFATA02( 5, SF1->( F1_DOC + F1_SERIE ) ) .And. (nOpcao == 3 .or. nOpcao == 4) .And. nConfirma == 1
	aAreaSD1 := SD1->( GetArea() )

	DbSelectArea("SD1")
	SD1->( DbSetOrder(1) )
	SD1->( DbSeek( xFilial("SD1") + SF1->( F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA ) ) )

	While SD1->( !Eof() ) .And. SD1->( D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA ) == SF1->( F1_FILIAL + F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA ) 
		//-- Verifica se o produto e "Materia Prima" e "Filme"
		If U_REFATA02( 1, SD1->D1_COD ) .And. U_REFATA02( 4, SD1->D1_COD )
			//-- Array com os itens do Documento de Entrada
			aAdd( aItensSD1, { SD1->D1_COD,;
							   SD1->D1_LOCAL,;
							   SD1->D1_QUANT,;
							   SD1->D1_LOTECTL,;
							   SD1->D1_NUMLOTE,;
							   SD1->D1_DTVALID,;
							   " ",;
							   " ",;
							   " " } )
		EndIf

		SD1->( DbSkip() )
	EndDo

	RestArea( aAreaSD1 )

	//-- Funcao para inclusao de Solicitacao de Transferencia automaticamente apos a entrada de Filmes na Replas
    If Len( aItensSD1  ) <> 0
		U_REESTA04( aItensSD1 )
	Else
		FWAlertInfo("Existe(m) Produto(s) tipo Filme nesse Recebimento, porém não são MP !!! Favor verificar.")
	Endif  

	Return
EndIf

//PONTO DE ENTRADA PARA CHAMADA DO MOTOR DE PROCESSO - GUSTAVO______[TOTVS]
If ExistBlock('RPEXECPE') .And. GetMV('RP_XMOTOR',.F.,.T.) .AND. (nOpcao == 3 .or. nOpcao == 4) .and. nConfirma == 1 
	//(TSM David-26/05/18)Tratamento para tratamento de poder de 3o armazem bandeirante que não deve executar motor
	If Alltrim(SF1->(F1_FORNECE+F1_LOJA)) $ cVldForMot
		lVldMotor := MsgYesNo('<FONT COLOR="red" SIZE="5">Motor deve ser executado para NF <b>'+SF1->F1_DOC+'/'+SF1->F1_SERIE+'</b> ?</FONT>')
	Else
		lVldMotor := .T.
	EndIf
	
	If lVldMotor
		Public _lUseRPEXECPE := iIF(Type('_lUseRPEXECPE')=='U', iif('MATA103' $ FunName(),.T.,.F.) ,.F.)
		ExecBlock('RPEXECPE',.F.,.F.,'MATA103')
	EndIf
	//_lUseRPEXECPE := nil
EndIf 

//(TSM David-09/10/17)Tratamento para Nota FIscal de Complemento
If 	cUsrExec $ cUsrCompl .and.;
 	!SF1->F1_TIPO $ 'N,D,B' .and.;
 	SF1->F1_FORMUL $ 'N, ' .and.;
	MsgYesNo('<FONT COLOR="red" SIZE="5">Nota referente a Complemento que deve ser enviada a <b>SEFAZ</b>?</FONT>')
	
	cUpd := "UPDATE "+RetSqlName("SF1")
	cUpd += " SET F1_FORMUL = 'S' "
	cUpd += " WHERE F1_FILIAL = '"+xFilial("SF1")+"' AND "
	cUpd += " F1_DOC = '"+SF1->F1_DOC+"' AND "
	cUpd += " F1_SERIE = '"+SF1->F1_SERIE+"' AND"
	cUpd += " F1_TIPO = '"+SF1->F1_TIPO+"' AND"
	cUpd += " F1_FORMUL IN  ('N',' ') AND"
	cUpd += " D_E_L_E_T_ = ' ' "
	
	TcSqlExec(cUpd)
	
	cUpd := "UPDATE "+RetSqlName("SD1")
	cUpd += " SET D1_FORMUL = 'S' "
	cUpd += " WHERE D1_FILIAL = '"+xFilial("SD1")+"' AND "
	cUpd += " D1_DOC = '"+SF1->F1_DOC+"' AND "
	cUpd += " D1_SERIE = '"+SF1->F1_SERIE+"' AND"
	cUpd += " D1_TIPO = '"+SF1->F1_TIPO+"' AND"
	cUpd += " D1_FORMUL IN  ('N',' ') AND"
	cUpd += " D_E_L_E_T_ = ' ' "
	
	TcSqlExec(cUpd)
	
	cUpd := "UPDATE "+RetSqlName("SF3")
	cUpd += " SET F3_FORMUL = 'S' "
	cUpd += " WHERE F3_FILIAL = '"+xFilial("SF3")+"' AND "
	cUpd += " F3_NFISCAL = '"+SF1->F1_DOC+"' AND "
	cUpd += " F3_SERIE = '"+SF1->F1_SERIE+"' AND"
	cUpd += " F3_TIPO = '"+SF1->F1_TIPO+"' AND"
	cUpd += " F3_FORMUL IN  ('N',' ') AND"
	cUpd += " D_E_L_E_T_ = ' ' "
	
	TcSqlExec(cUpd)
	
Endif

//tratamento para envio de e-mail quando nf de devolução
//Rafael Domingues - 14.11.2019
If AllTrim(SF1->F1_TIPO) == 'D' .And. nOpcao == 3 .And. nConfirma == 1
	U_RECOMX01(SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA)
EndIf
RestArea(aArea)

Return
