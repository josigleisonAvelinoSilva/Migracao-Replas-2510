/*/{Protheus.doc} User Function REPLA930
	Este programa tem por objetivo buscar o custo atual do produto e somar ao icms da última nf de entrada.
	@type  User Function
	@author Robson Gonçalves - Rleg Brasil
	@since 14/08/2020
	@version version
	@param NIL
	@return cRet - retornar o valor de venda ou de custo.
	@example - Este programa está sendo acionado pelo gatilho do C6_PRODUTO.
	(examples)
	@see (links_or_references)
	@history 15/06/2022, Dener Lemos - DOTHINK, Criação de nova condicao para ser caclulado o preco quando cliente for a nova filial de Sao Paulo.
	Foi alterado tambem o When do gatilho do campo C6_PRODUTO para entrar nesse gatilho quando a filial for 0103.
	/*/

#Include 'Protheus.ch'

User Function REPLA930()
	Local aArea := {}
	Local cC6_PRODUTO := ''
	Local cSQL := ''
	Local cTRB := ''
	//Local lCliente := (M->C5_CLIENTE=='14555032'.AND.M->C5_LOJACLI=='0003')
	Local nB2_CM1 := 0
	Local nD1_PICM := 0
	Local nRet := 0

	Local cXGrupo := ""
	Local nSD1Rec := 0
	Local nIPI    := 0
	Local nICMS   := 0
	Local nImp5   := 0
	Local nImp6   := 0
	Local nSumImp := 0
	
	aArea := GetArea()

	If cFilAnt=='0102' .And. ( M->C5_CLIENTE + M->C5_LOJACLI $ "145550320003;" ) //.AND. lCliente
		cC6_PRODUTO := aCOLS[n,GdFieldPos('C6_PRODUTO')]

		nB2_CM1 := SB2->(Posicione('SB2',1,xFilial('SB2')+cC6_PRODUTO+'02','B2_CM1'))

		cSQL := "SELECT RTCUSTO.D1_PICM "
		cSQL += "  FROM "+RetSqlName("SD1")+" RTCUSTO "
		cSQL += " WHERE RTCUSTO.R_E_C_N_O_ = ( SELECT MAX( SD1.R_E_C_N_O_ ) AS D1_RECNO "
		cSQL += "								FROM "+RetSqlName("SD1")+" SD1 "
		cSQL += "							WHERE SD1.D1_FILIAL = "+ValToSql(cFilAnt)+" "
		cSQL += "									AND SD1.D1_COD = "+ValToSql(cC6_PRODUTO)+" "
		cSQL += "									AND SD1.D_E_L_E_T_ = ' ' ) "

		cSQL := ChangeQuery( cSQL )
		cTRB := GetNextAlias()
		dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cSQL),cTRB,.F.,.T.)
		nD1_PICM := (cTRB)->D1_PICM
		(cTRB)->( dbCloseArea() )
		
		If nD1_PICM > 0
			nRet := nB2_CM1 + ( ( nB2_CM1 * nD1_PICM ) / 100 )
		Else
			nRet := nB2_CM1
		Endif
	ElseIf cFilAnt = "0103" .And. ( M->C5_CLIENTE + M->C5_LOJACLI $ "092600110002;" ) .And. !Empty( aCOLS[n, GdFieldPos( "C6_PRODUTO" )] )
		cC6_PRODUTO := aCOLS[n, GdFieldPos( "C6_PRODUTO" )]		
		cXGrupo     := Posicione( "SB1", 1, xFilial("SB1") + cC6_PRODUTO + "01", "B1_XGRUPO" ) //-- 0=Outros; 1=Filme; 2=Resina Nacional; 3=Resina Importada
		nB2_CM1     := Posicione( "SB2", 1, xFilial("SB2") + cC6_PRODUTO + "01", "B2_CM1" )

		If cXGrupo $ "2;3"
			cSQL := " SELECT " 
			cSQL += " 	MAX( SD1.R_E_C_N_O_ ) AS RECNOSD1 " 
			cSQL += " FROM " 
			cSQL += " 	" + RetSqlName("SD1") + " SD1 " 
			cSQL += " WHERE " 
			If cXGrupo == "3"
				cSQL += " 	SD1.D1_FILIAL IN ('0102', '0103') " 
				cSQL += " 	AND SD1.D1_TES IN ('026', '051') " //-- TES de importados
			ElseIf cXGrupo == "2"
				cSQL += " 	SD1.D1_FILIAL = '0103' " 
				cSQL += " 	AND SD1.D1_TES IN ('050') " //-- TES de nacionais
			Else
				cSQL += " 	SD1.D1_FILIAL = ' " + xFilial("SD1") + " ' " 
			EndIf
			cSQL += " 	AND SD1.D1_COD = '" + cC6_PRODUTO + "' "
			cSQL += " 	AND SD1.D_E_L_E_T_ = ' ' "

			DbUseArea( .T., 'TOPCONN', TCGENQRY( , , cSQL ), "_TMP", .F., .T. )

			If _TMP->( !Eof() )
				nSD1Rec := _TMP->RECNOSD1
			EndIf

			_TMP->( DbCloseArea() )

			DbSelectArea("SD1")
			SD1->( DbGoTo( nSD1Rec ) )

			//nIPI  := ( nB2_CM1 * SD1->D1_IPI ) / 100
			nICMS := ( nB2_CM1 * SD1->D1_PICM ) / 100
			nImp5 := ( nB2_CM1 * SD1->D1_ALQIMP5 ) / 100
			nImp6 := ( nB2_CM1 * SD1->D1_ALQIMP6 ) / 100
		EndIf

		//-- Soma dos impostos
		nSumImp := nIPI + nICMS + nImp5 + nImp6

		If !Empty(nSumImp)
			nRet := nB2_CM1 + nSumImp
		Else
			nRet := nB2_CM1
		EndIf
	Else
		nRet := aCOLS[n,GdFieldPos('C6_PRCVEN')]
	Endif

	RestArea( aArea )
	
Return(nRet)
