#Include "Protheus.ch"       
#Include "TbiConn.ch"
#Include "FwCommand.ch"

// ---------------------------------------------------------------
/*/{Protheus.doc} M410STTS
(long_description) Ponto de Entrada executado após geração do 
pedido de venda 
@type function
@author Eduardo Augusto
@since 08/11/2017
@version 1.0
@return ${return}, ${return_description} Nil
@example
(examples)
@see (links_or_references) http://tdn.totvs.com/pages/releaseview.action?pageId=6784155
/*/
// ---------------------------------------------------------------

User Function M410STTS()

Local aArea		:= GetArea()
Local aAreaC5	:= SC5->(GetArea())
Local aAreaC6	:= SC6->(GetArea())
Local aAreaC9	:= SC9->(GetArea())
Local lBlqReg	:= .T.	// Gravo 
Local cXTesAmo	:= GetMv("MV_XTESAMO")	// Parametro que trata TES de Amostra
Local cQuery	:= ""
Local lTabPrc	:= .F.
Local nPrcTab	:= 0
Local cVldReser :=  GetNewPar("MV_XVLDRES","S")
Local cFilialFat := GetMv("MV_XFILFAT")
Local lFilialFat:= .F.
Local lAmostra := .F.
Local lAvista := .F.
Local lIntIndMM := GetMV( "RE_INTIND", .F., .T. ) //-- Parametro geral que indica se a integracao de pedidos com a industria mm (Filial 0201) esta ativa

Local cFilOrig  := GetMV( "RE_FILORIG", .F., "0302" ) 
Local lVerExcPd := GetMv( "RE_PEDDEST",,.T.)  //Ativa Verif. de Exclusão Pedido Destino
Local nOpc      := 5   //Exclusao
Local cFilDes   := SC5->C5_XFILDES
Local cPedDes   := SC5->C5_XPVDEST

If lIntIndMM .And. IsInCallStack( "A410Deleta" )  .And. ;
   lVerExcPd .And. ;
   SC5->C5_FILIAL == cFilOrig  .And. ;
   !Empty( cFilDes ) .And. ;
   !Empty( cPedDes )    

   SC5->( dbSetOrder(1))

   //-- Chama a rotina de Inclusao/Alteracao/Exclusão dos Pedidos de Venda Destino
   U_REFATA01( { FWCodEmp()       ,; //-- Empresa
                 SC5->C5_FILIAL,; //-- Filial Origem
                 SC5->C5_NUM   ,; //-- Pedido Origem
                 cFilDes       ,; //-- Filial Destino
                 cPedDes       ,; //-- Pedido Destino
                 nOpc }         ) //-- Tipo operacao

   //-- Caso localize o Pedido destino, significa que o Pedido não foi cancelado e todo o Processo será Abortado
   If SC5->( dbSeek( cFilDes + cPedDes ))
      MsgAlert("Atenção. Ocorreu Erro ao tentar Excluir o Pedido Destino : " + cFilDes +"/"+ cPedDes + ". Favor verificar Status deste Pedido!!!!","A410DEL")
      DisarmTransaction()
      Final()
   Endif    

Endif       


If !IsinCallStack("U_XRLSMOTOR") .AND. !SC5->C5_TIPO $ "D,B"
	If ( lIntIndMM .And. U_REFATA02( 2, SC5->C5_NUM ) ) .Or.;
	   ( lIntIndMM .And. IsInCallStack("U_REESTA02") ) .Or.;
	   ( lIntIndMM .And. IsInCallStack("U_REFATA01") ) .Or.;
	   ( lIntIndMM .And. IsInCallStack("U_REFATA05") )
		
		Return
	Else
		//-- Verifica se Filial é valida para faturamento
		lFilialFat := FWCodFil() $ cFilialFat

		DbSelectArea("DA1")
		DbSetOrder(4)	// DA1_FILIAL + DA1_CODTAB + DA1_GRUPO + DA1_INDLOT + DA1_ITEM
		DbSelectArea("SC6")
		DbSetOrder(1)	// C6_FILIAL + C6_NUM + C6_ITEM + C6_PRODUTO
		DbSelectArea("SC9")
		DbSetOrder(1)	// C9_FILIAL + C9_PEDIDO + C9_ITEM + C9_SEQUEN + C9_PRODUTO + C9_BLEST + C9_BLCRED
		If Select("TMP") > 0
			TMP->(DbCloseArea())
		EndIf
		cQuery := " SELECT C6_FILIAL, C6_PRODUTO, C6_QTDVEN, C6_PRCVEN, C6_TES, C6_BLOQUEI, B1_GRUPO, C9_BLCRED FROM " + RetSqlName("SC6") + " SC6  "
		cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_COD = C6_PRODUTO AND SB1.D_E_L_E_T_ = '' "
		cQuery += " INNER JOIN " + RetSqlName("SC9") + " SC9 ON C9_PRODUTO = C6_PRODUTO AND C9_ITEM = C6_ITEM AND C9_PEDIDO = C6_NUM AND SC9.D_E_L_E_T_ = '' "
		cQuery += " INNER JOIN " + RetSqlName("SF4") + " SF4 ON F4_CODIGO = C6_TES AND SF4.D_E_L_E_T_ = '' "
		cQuery += " WHERE SC6.D_E_L_E_T_ = '' "
		cQuery += " 	AND C6_FILIAL = '" + SC5->C5_FILIAL + "' "
		cQuery += " 	AND C6_NUM    = '" + SC5->C5_NUM + "' "
		cQuery += " 	AND B1_XGRUPO IN ('2','3') "
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TMP', .T., .F.)
		DbSelectArea("TMP")
		DbGoTop()
		While TMP->(!Eof())
			lTabPrc := .F.
			
			If DA1->(DbSeek(xFilial("DA1") + SC5->C5_TABELA + TMP->B1_GRUPO))	// Posiciono na Tabela de Preço para saber qual o Preço  de Lista
				
				nPrcTab := TMP->C6_PRCVEN
				
				While DA1->(!Eof()) .And. !lTabPrc .and. DA1->DA1_GRUPO == TMP->B1_GRUPO
					If TMP->C6_QTDVEN <= DA1->DA1_QTDLOT
						nPrcTab := DA1->DA1_PRCVEN
						lTabPrc := .T.
					EndIf
					DA1->(DbSkip())
				End
				
				If TMP->C6_PRCVEN < nPrcTab  
					lTabPrc := .F.
				EndIf
			Else
				lTabPrc := .T.
			EndIf

			//-- Valida se regra de condicao de pagamento devera bloquear
			If lTabPrc .and. lFilialFat .and. !u_RFATA11B(SC5->C5_CONDPAG)
				lTabPrc := .F. //-- ira utilizar o bloco abaixo para bloqueio
			EndIf

			If !lTabPrc .and. lFilialFat
				// Atualizo o campo de Bloqueio do Pedido da SC5
				SC5->(RecLock("SC5", .F.))
				SC5->C5_BLQ := "1"
				SC5->(MsUnlock())
				lBlqReg := .T.
			Else
				lBlqReg := .F.
			EndIf
			
			lAvista := (SC5->C5_CONDPAG == "001")
			lAmostra := (TMP->C6_TES $ cXTesAmo)

			If lBlqReg
				// Atualizo o campo de Bloqueio do Item da SC6
				TcSqlExec("UPDATE "+RetSqlName("SC6")+" SET C6_BLOQUEI = '01' WHERE C6_FILIAL = '"+xFilial("SC6")+"' AND C6_NUM = '"+SC5->C5_NUM+"' ")
				
				If lAvista .OR. lAmostra
					SC9->(DbSeek(xFilial("SC9") + SC5->C5_NUM))
					While SC9->(!Eof()) .And. xFilial("SC9") + SC5->C5_NUM == SC9->C9_FILIAL + SC9->C9_PEDIDO
						SC9->(RecLock("SC9",.F.))
						SC9->C9_BLCRED := "01"
						SC9->(MsUnLock())
						SC9->(DbSkip())
					End
				EndIf
			Else
				//-----------------------------------------------------------------------------------------------------------
				//| Se for venda a vista ou produto para amostra e não houve bloqueio de regra, forçar o bloqueio de crédito.
				//-----------------------------------------------------------------------------------------------------------
				If lAvista .OR. lAmostra
					SC9->(DbSeek(xFilial("SC9") + SC5->C5_NUM))
					While SC9->(!Eof()) .And. xFilial("SC9") + SC5->C5_NUM == SC9->C9_FILIAL + SC9->C9_PEDIDO
						If SC9->C9_BLCRED <> "01"
							SC9->(RecLock("SC9",.F.))
							SC9->C9_BLCRED := "01"
							SC9->(MsUnLock())
						Endif
						SC9->(DbSkip())
					End
				Else
					SC9->(DbSeek(xFilial("SC9") + SC5->C5_NUM))
					While SC9->(!Eof()) .And. xFilial("SC9") + SC5->C5_NUM == SC9->C9_FILIAL + SC9->C9_PEDIDO
						SC9->(RecLock("SC9",.F.))
						SC9->C9_BLCRED := TMP->C9_BLCRED
						SC9->(MsUnLock())
						SC9->(DbSkip())
					End
				Endif
			EndIf
			TMP->(DbSkip())
		End

		TMP->( DbCloseArea() )
		
		//Caso se refira a exclusão refaz reserva dos pedidos
		If !Altera .and. !Inclui .and. cVldReser == "S"
			FwMsgRun(, {|| u_xValdRes(SC5->C5_NUM) }, , 'Validando Reserva, aguarde...')
			TcSqlExec("UPDATE "+RetSqlName("SC0")+" SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE C0_NUM = '"+SC5->C5_NUM+"' ")
		EndIf
	EndIf
EndIf

RestArea(aAreaC9)
RestArea(aAreaC6)
RestArea(aAreaC5)
RestArea(aArea)

Return
