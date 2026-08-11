#INCLUDE "PROTHEUS.CH"


#DEFINE OP_EFE "011" //-- Efetivar


/*/{Protheus.doc} REESTA02
Rotina que Processa as transferencias entre filiais da Replas
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 08/06/2022
@param aDadosTransf, array, Array com dados para transferencia 
@param aParam310, array, Array com as perguntas selecionadas
@param aSeries, array, Series
@param aNotasTransf, array, Notas
@return logical, Retorno logico
@obs Projeto Novo PCP
/*/
User Function REESTA02(aDadosTransf, aParam310, aSeries, aNotasTransf) //-- A310Proc
	Local cFilOri     := cFilAnt //-- Variavel com a filial origem
	Local aParam460   := Array(30) //- Array com os parametros do programa
	Local cPedido     := ""
	Local cWhile      := ""
	Local cSerie      := ""
	Local cNotaFeita  := ""
	Local cPedidos    := ""
	Local cChavSA2    := ""
	Local aCabec      := {}
	Local aItens      := {}
	Local aPvlNfs     := {}
	Local aBloqueio   := { { "", "", "", "", "", "", "", "" } }
	Local aNotas      := {}
	Local aDadosAux   := {}
	Local nItemNf     := 0
	Local nSaveSX8    := 0
	Local nAchoSerie  := 0
	Local nPrcVen     := 0
	Local nPosDAux    := 0
	Local nBloqueio   := 0
	Local ni          := 1
	Local nx          := 1
	Local nW		  := 1
	Local nW1		  := 1
	Local nOpc        := 0
    //Local aSeries   :={}
	Local nTamSD2	  := TamSX3( "D2_DOC" )[1]
	Local lREESTA01   := IsInCallStack( "U_REESTA01" ) .Or. ( Type("cOpId311") == "C" .And. cOpId311 == OP_EFE ) //-- Verifica se veio da rotina de registro de transferencia
	Local lContinua   := .T.
	Local lMT460A     := .F.
	Local lRet        := .T.
	Local aNotaFeita  := {} //-- Array com notas geradas
	Local lMostraErro := .F. //-- Variaveis para rotina automatica
	Local aColsAux    := {}
	Local nItGrd      := 0
	Local c311FilDes  := ""
	Local aDadosTRF   := {}
	Local nLenDados   := 0
	Local l311NumPed  := NNT->(FieldPos('NNT_NUMPED')) > 0 .And. "5" $ GetSX3Cache("NNS_STATUS","X3_VALID") .And. Type('l311GerPed') == "L"
	Local cErro		  := ""
    Local cFileLog    := ""
    Local cMsg        := ""
	Local cMsgNFRet   := ""
	Local nPrcVenAdc  := GetMV("RE_PRCVENA", .F., 0.1) //-- Parametro usado para incluir um preco de venda adicional no pedido que venda que e gerado automaticamente. Esse parametro foi criado devido a necessidade de migracao de empresas da Replas. Solicitacado pelo Silcio dia 14/06/2024 

	Private lMsErroAuto  := .F.
	Private cNumero      := ""
	Private lMudouNum    := .F. // Variavel utilizada para verificar se o numero da nota foi alterado pelo usuario (notas de saida e entrada com formulario proprio).
	Private lPODER3      := aParam310[19] == 1 //-- Variavel utilizada para tratamento especifico para poder de terceiros
	Private c310FilMov   := ""
    Private cXFilPedFilm := GetMV( "RE_FILORIG", .F., "0302" ) //-- Indica a Filial onde o PV do Cliente e incluido. Somente para produtos do tipo "Filme" (Replas)
    Private cXFilPrdFilm := GetMV( "RE_FILDEST", .F., "0201" ) //-- Indica a Filial onde o PV de Producao e incluido. Somente para produtos do tipo "Filme" - (Industria MM SP)
	Private cXFilArmFilm := GetMV( "RE_FILARM", .F., "0104" )  //-- Indica a Filial de armazenagem de produtos do tipo "Filme" - (Armazem Fechado)

    //-- Array com notas geradas e filial destino
	Default aNotasTransf := {}
	Default aSeries      := {}

    //-- Verifica se o array esta vazio
	If Empty( aDadosTransf )
		Help( Nil, Nil, "TRFSEMDADOS", Nil, "Não existe nenhuma tranferencia de materiais pendente a ser executada.", 1, 0 )
		lContinua := .F.
	EndIf

	//-- Se Destino for a Filial 03/02 - Buscar ultimas NFs de Saida
	If aDadosTransf[ 1, 06] == cXFilPedFilm
	   cMsgNFRet := fBusUltNfs(  aDadosTransf  )
	Endif   

    //-- Varre array para efetuar gravacoes
	If lContinua .And. Empty( aSeries )
		For nx := 1 To Len( aDadosTransf )
			lNSelSerie := .F.

			If nx == 1 .Or. ( aDadosTransf[nx, 01] # aDadosTransf[nx-1, 01] )
				//-- Atualiza para a filial origem
				cFilAnt := aDadosTransf[nx, 01]

				//-- Obtem serie para as notas desta filial
				cSerie    := ""
				cNumero   := ""
				lContinua := SX5NumNota( @cSerie, GetMv( "MV_TPNRNFS" ), cFilAnt )

				//-- Caso tenha selecionado numero
				If !lContinua .or. Empty( cNumero )
					//-- A filial XX nao teve uma serie de nota fiscal de saida selecionada para geracao
					//-- Help(" ",1,"A310SERERR",,cFilAnt,1,10)
					lContinua :=.F.
					
					If Empty( cNumero )
						lNSelSerie := .T.
					EndIf
					Exit
				Else
					aAdd( aSeries, { cFilAnt, cSerie, cNumero } )
				EndIf
			EndIf
		Next nx
	EndIf

    //-- Utilizado para visualizar ou nao o grupo de perguntas MT460A
	If !lMT460A
		Pergunte( "MT460A", .F. )
	EndIf

    // Processamento das Transferencias
	If lContinua .And. If( lMT460A, Pergunte( "MT460A", .T. ), .T. )
		//-- Monta regua de processamento
		ProcRegua( Len( aDadosTransf ) * 2 )

		//-- Processa geracao de documentos de saida
		//-- Carrega parametros do programa
		For nx := 1 to 30
			aParam460[nx] := &( "mv_par" + StrZero( nx, 2 ) )
		Next nx

		//-- Sorteia array para aglutinar por filial origem e destino
		aSort( aDadosTransf, , , {|x,y| x[1]+x[6]+x[2]+x[3] < y[1]+y[6]+y[2]+y[3] } )

		//-- Varre array para efetuar gravacoes
		While ( ni <= Len( aDadosTransf ) )
			//-- Variavel para rotina automatica
			lMsErroAuto := .F.

			//-- Array auxiliar
			aDadosAux := {}

			//-- Atualiza para a filial origem
			cFilAnt := aDadosTransf[ni, 01]

			//-- Armazena o codigo da filial destino
			c311FilDes := aDadosTransf[ni, 06]

			//-- Array para geracao de notas
			aNotas := {}

			//-- Arrays com itens e bloqueios
			aPvlNfs   := {}
			aBloqueio := {}
			nOpc 	  := 2

			//-- Array do Cabecalho do pedido
			aCabec := {}

			//-- Array dos Itens do pedido
			aItens := {}

			//-- Variavel que controla numeracao
			nSaveSX8 := GetSX8Len()

			//-- Variavel para processamento
			cWhile := aDadosTransf[ni, 01] + aDadosTransf[ni, 06]

			//-- Obtem serie para as notas desta filial
			nAchoSerie := aScan( aSeries, {|x| x[1] == cFilAnt } )

			//-- Caso tenha selecionado serie para esta filial
			If nAchoSerie > 0
				//-- Atualiza para a filial destino
				cFilAnt := aDadosTransf[ni, 06]

				//-- Verifica se Numero e serie ja foram cadastrados
				DbSelectArea("SF1")
				SF1->( DbSetOrder(1) )
				If SF1->( DbSeek( xFilial("SF1") + aSeries[nAchoSerie, 03] + aSeries[nAchoSerie, 02] + aDadosTransf[ni, 10] + aDadosTransf[ni, 11] ) )
					Help( Nil, Nil, "TRFNUMNOTA", Nil, "A numeração informada para esta transferencia já possui um documento registrado com a mesma numeração, favor informar uma nova numeração.", 1, 0 )
					Exit
				EndIf

				//-- Atualiza para a filial origem
				cFilAnt := aDadosTransf[ni, 01]

				//-- Serie para geracao da nota
				cSerie := aSeries[nAchoSerie, 02]

				//-- Cabecalho do pedido
				cPedido := GetSxeNum( "SC5", "C5_NUM" )
				RollBackSX8()

				aAdd( aCabec, { "C5_NUM", cPedido, Nil } )
			
				If aDadosTransf[ni, 01] + aDadosTransf[ni, 06] == cXFilPedFilm + cXFilPrdFilm
					aAdd( aCabec, { "C5_TIPO", "B", Nil } )
				Else
					aAdd( aCabec, { "C5_TIPO", "N", Nil } )
				EndIf
				
				aAdd( aCabec, { "C5_CLIENTE", aDadosTransf[ni, 08], Nil } )
				aAdd( aCabec, { "C5_LOJACLI", aDadosTransf[ni, 09], Nil } )
				aAdd( aCabec, { "C5_LOJAENT", aDadosTransf[ni, 09], Nil } )
				aAdd( aCabec, { "C5_FECENT" , dDataBase           , Nil } )
				aAdd( aCabec, { "C5_TABELA" , Space(3)            , Nil } )
				aAdd( aCabec, { "C5_MENNOTA", cMsgNFRet			  , Nil } )	

				//-- 
				If lREESTA01
					If Empty(aDadosTransf[ni, 27])
						SA1->( DbSetOrder(1) )
						If SA1->( DbSeek( xFilial("SA1") + aDadosTransf[ni, 08] + aDadosTransf[ni, 09] ) )
							aAdd( aCabec, { "C5_CONDPAG", SA1->A1_COND, Nil } )
						Endif
					Else
						aAdd( aCabec, { "C5_CONDPAG", aDadosTransf[ni, 27], Nil } )
					EndIf
				Else
					aAdd( aCabec, { "C5_CONDPAG", aParam310[16], Nil } )
				Endif

				//-- Transportadora
				If lREESTA01 .And. !Empty(aDadosTransf[ni, 28])
					aAdd( aCabec, { "C5_TRANSP", aDadosTransf[ni, 28], Nil } )
				EndIf

				//-- Tipo Frete
				If lREESTA01 .And. !Empty(aDadosTransf[ni, 29])
					aAdd( aCabec, { "C5_TPFRETE", aDadosTransf[ni, 29], Nil } )
				EndIf

				//-- Contador dos itens
				cC6_ITEM := Strzero( 0, TamSX3( "C6_ITEM" )[01] )

				//-- ATENCAO - VARIAVEL CRIADAS POR CAUSA DA QUEBRA NO FATURAMENTO
				aNotaFeita := {}

				While ( ni <= Len( aDadosTransf ) ) .And. ( aDadosTransf[ni, 01] + aDadosTransf[ni, 06] + aDadosTransf[ni, 15] + aDadosTransf[ni, 16] == cWhile )
					//-- Incrementa regua de processamento
					IncProc()

					aLinha := {}

					If lREESTA01 .And. aDadosTransf[ni, 30] > 0
						nPrcVen := aDadosTransf[ni, 30]
					Else
						//-- Quando FILIAL for INDUSTRIA ou ARMAZEM obtem preco de venda da nota de remessa/entrada
						//If ( aDadosTransf[ni, 01] + aDadosTransf[ni, 06] == cXFilArmFilm + cXFilPedFilm ) .Or.;
						//   ( aDadosTransf[ni, 01] + aDadosTransf[ni, 06] == cXFilPrdFilm + cXFilPedFilm )

							//-- Pega o preco de venda na entrada do produto na INDUSTRIA ou ARMAZEM
						//	nPrcVen := GetPrcVen( aDadosTransf[ni, 02], aDadosTransf[ni, 17], aDadosTransf[ni, 18], aDadosTransf[ni, 08], aDadosTransf[ni, 09] )
						//Else
							//-- Obtem preco de venda do produto
						If aParam310[17] == 1 
							SA1->( DbSetOrder(1) )
							SA1->( DbSeek( xFilial("SA1") + aDadosTransf[ni, 08] + aDadosTransf[ni, 09] ) )
							nPrcVen := MaTabPrVen( SA1->A1_TABELA, aDadosTransf[ni, 02], aDadosTransf[ni, 04], aDadosTransf[ni, 08], aDadosTransf[ni, 09], 1, dDataBase )
							
						ElseIf aParam310[17] == 2
							//-- Obtem preco - custo standard
							If RetArqProd( aDadosTransf[ni, 02] )
								nPrcVen := Posicione( "SB1", 1, xFilial("SB1") + aDadosTransf[ni, 02], "B1_CUSTD" )
							Else
								SB1->( DbSetOrder(1) )
								SB1->( DbSeek( xFilial("SB1") + aDadosTransf[ni, 02] ) )
								nPrcVen := RetFldProd( SB1->B1_COD, "B1_CUSTD" )
							EndIf
						ElseIf aParam310[17] == 3
							//-- Obtem preco - ultimo preco de compra
							If RetArqProd( aDadosTransf[ni, 02] )
								nPrcVen := Posicione( "SB1", 1, xFilial("SB1") + aDadosTransf[ni, 02], "B1_UPRC" )
							Else
								SB1->( DbSetOrder(1) )
								SB1->( DbSeek( xFilial("SB1") + aDadosTransf[ni, 02] ) )
								nPrcVen := RetFldProd( SB1->B1_COD, "B1_UPRC" )
							EndIf
						ElseIf aParam310[17] == 4
							//-- Obtem preco - custo medio unitario do armazem
							SB2->( DbSetOrder(1) )
							If SB2->( DbSeek( xFilial("SB2") + aDadosTransf[ni, 02] + aDadosTransf[ni, 03] ) )
								nPrcVen := SB2->B2_CM1
							EndIf
						EndIf
						//EndIf
					EndIf

					//-- Senao encontrou nenhum valor assume 1
					If QtdComp( nPrcVen, .T. ) == QtdComp( 0, .T. )
						nPrcVen := 1
					EndIf

					nLenDados := Len( aDadosTransf[ni] )
					aDadosTRF := Array( 1, nLenDados + 2 )

					For nW  := 1 To 1
						For nW1 := 1 To nLenDados
							aDadosTRF[nW, nW1] := aDadosTransf[ni, nW1]
						Next nW1
					Next nW

					If aParam310[17] <= 4
						aDadosTRF[1, nLenDados + 1] := (nPrcVen + nPrcVenAdc)
						aDadosTRF[1, nLenDados + 2] := aDadosTransf[ni, 04]
					EndIf

					For nW := 1 To Len( aDadosTRF )
						aLinha := {}

						//-- Controle dos Itens
						cC6_ITEM := Soma1( cC6_ITEM )

						aAdd( aLinha, { "C6_ITEM"   , cC6_ITEM								, Nil } )
						aAdd( aLinha, { "C6_PRODUTO", aDadosTRF[nW, 02]						, Nil } )
						aAdd( aLinha, { "C6_LOCAL"  , aDadosTRF[nW, 03]						, Nil } )
						aAdd( aLinha, { "C6_QTDVEN" , aDadosTRF[nW, nLenDados + 2]			, Nil } )
						aAdd( aLinha, { "C6_PRCVEN" , A410Arred( aDadosTRF[nW, nLenDados + 1], "C6_PRCVEN" ), Nil } )
						aAdd( aLinha, { "C6_PRUNIT" , A410Arred( aDadosTRF[nW, nLenDados + 1], "C6_PRUNIT"), Nil } )
						aAdd( aLinha, { "C6_VALOR"  , A410Arred( aDadosTRF[nW, nLenDados + 2] * aTail( aLinha )[2], "C6_VALOR" ), Nil } )
						aAdd( aLinha, { "C6_TES"    , aDadosTRF[nW, 23], Nil } )

						//-- Checa se utiliza rastreabilidade por lote
						If Rastro( aDadosTRF[nW, 02], "L" )
							aAdd( aLinha, { "C6_LOTECTL", aDadosTRF[nW, 17], Nil } )
							aAdd( aLinha, { "C6_DTVALID", aDadosTRF[nW, 19], Nil } )
						EndIf

						//-- Checa se utiliza rastreabilidade por sublote
						If Rastro( aDadosTRF[nW, 02], "S" )
							aAdd( aLinha, { "C6_LOTECTL", aDadosTRF[nW, 17], Nil } )
							aAdd( aLinha, { "C6_NUMLOTE", aDadosTRF[nW, 18], Nil } )
							aAdd( aLinha, { "C6_DTVALID", aDadosTRF[nW, 19], Nil } )
						EndIf

						//-- Checa se utiliza localização
						If Localiza( aDadosTRF[nW, 02] )
							aAdd( aLinha, { "C6_NUMSERI", aDadosTRF[nW, 21], Nil } )
							aAdd( aLinha, { "C6_LOCALIZ", aDadosTRF[nW, 20], Nil } )
						EndIf

						aAdd( aItens, aLinha )
						aAdd( aDadosAux, { cPedido, cC6_ITEM, aDadosTRF[nW, 07], aDadosTRF[nW, 25] } )
					Next nw

					ni++
				EndDo

				If !IsBlind() .And. !IsInCallStack("U_REFATA06")
					MsProcTxt( "Gerando PV na Filial Origem [" + cFilAnt + "]..." )
				EndIf

				//-- Reliza a gravacao do pedido destino 
				MsExecAuto( { |x, y, z| Mata410( x, y, z ) }, aCabec, aItens, 3 )

				//-- Checa erro de rotina automatica
				If lMsErroAuto
					lMostraErro	:=.T.
				Else
					//-- Confirma SX8
					While ( GetSx8Len() > nSaveSX8 )
						ConfirmSX8()
					EndDo
					
					//-- Liberacao de pedido
					Ma410LbNfs( 2, @aPvlNfs, @aBloqueio )
					
					//-- Checa itens liberados
					Ma410LbNfs( 1, @aPvlNfs, @aBloqueio )
					
					//-- Caso tenha itens liberados manda faturar
					If Empty( aBloqueio ) .And. !Empty( aPvlNfs )
						nItemNf := a460NumIt( cSerie )
						aAdd( aNotas, {} )

						//-- Efetua as quebras de acordo com o numero de itens
						For nX := 1 To Len( aPvlNfs )
							If Len( aNotas[Len( aNotas )] ) >= nItemNf
								aAdd( aNotas, {} )
							EndIf

							aAdd( aNotas[Len( aNotas )], aClone( aPvlNfs[nX] ) )
						Next nX

						//-- Gera as notas de acordo com a quebra
						For nX := 1 To Len( aNotas )
							If !IsBlind() .And. !IsInCallStack("U_REFATA06")
								MsProcTxt( "Gerando Doc. Saida na Filial Origem [" + cFilAnt + "]..." )
							EndIf

							cNotaFeita := MaPvlNfs( aNotas[nX], cSerie, aParam460[01] == 1, aParam460[02] == 1, aParam460[03] == 1, aParam460[04] == 1, aParam460[05] == 1, aParam460[07], aParam460[08], aParam460[15] == 1, aParam460[16] == 2 )
							
							aAdd( aNotaFeita, PadR( cNotaFeita, nTamSD2 ) )

							//-- Transmissao da Nota para o SEFAZ
							/*
							If !U_REFATA07(cNotaFeita, cSerie, @cErro)
								Help( Nil, Nil, "ERROR", Nil, cErro, 1, 0 )
								lRet := .F.
								Exit
							EndIf
							*/
							
						Next nX

						If !Empty(cErro) .And. IsInCallStack("U_REFATA06")
							cErrComm += cErro
						EndIf

						If lRet
							//-- Varre notas fiscais de saida geradas para gerar notas fiscais de entrada
							For nx := 1 To Len( aNotaFeita )
								aColsAux := {}
								nItem	 := 0
								nItGrd	 := 0

								DbSelectArea("SD2")
								SD2->( DbSetOrder(3) )
								If SD2->( DbSeek( xFilial("SD2") + PadR( aNotaFeita[nx], TamSX3( "D2_DOC" )[1] ) + cSerie + aDadosTransf[ni-1, 08] + aDadosTransf[ni-1, 09] ) )
									aAdd( aNotasTransf, { aDadosTransf[ni-1, 06], aNotaFeita[nX], cSerie, cPedido } )

									//-- Cabecalho da nota fiscal de entrada
									aCabec := {}

									aAdd( aCabec, { "F1_TIPO"   , "N" } )
									aAdd( aCabec, { "F1_FORMUL" , "N" } )
									aAdd( aCabec, { "F1_DOC"    , aNotaFeita[nx] } )
									aAdd( aCabec, { "F1_SERIE"  , cSerie } )
									aAdd( aCabec, { "F1_EMISSAO", dDataBase } )
									aAdd( aCabec, { "F1_FORNECE", aDadosTransf[ni-1, 10] } )
									aAdd( aCabec, { "F1_LOJA"   , aDadosTransf[ni-1, 11] } )
									
									cChavSA2 := aDadosTransf[ni-1, 10]+aDadosTransf[ni-1, 11]

									aAdd( aCabec, { "F1_ESPECIE", aParam310[20] } )

									If lREESTA01
										If Empty(aDadosTransf[ni-1, 27])
											SA2->( DbSetOrder(1) )
											If SA2->( DbSeek( xFilial("SA2") + cChavSA2 ) )
												aAdd( aCabec, { "F1_COND", SA2->A2_COND } )
											Endif
										Else
											aAdd(aCabec, {"F1_COND", aDadosTransf[ni-1, 27]})
										EndIf
									Else
										aAdd( aCabec, { "F1_COND", aParam310[16] } )
									Endif

									aAdd( aCabec, {"F1_EST", GetUF( aDadosTransf[ni-1], lPODER3 ) } )
									
									//-- Carrega dados do Cliente de Origem da Nota Fiscal - UPDEST09
									aAdd( aCabec, { "F1_FILORIG", SD2->D2_FILIAL } )
									aAdd( aCabec, { "F1_CLIORI" , SD2->D2_CLIENTE } )
									aAdd( aCabec, { "F1_LOJAORI", SD2->D2_LOJA } )
									aAdd( aCabec, { "F1_TPFRETE", SF2->F2_TPFRETE } )

									//-- Itens da nota fiscal de entrada
									aItens   := {}
									While SD2->( !Eof() ) .And. xFilial("SD2") + aNotaFeita[nx] + cSerie + aDadosTransf[ni-1, 08] + aDadosTransf[ni-1, 09] == SD2->( D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA )
										//-- Incrementa regua de processamento
										IncProc()

										aLinha      := {}
										nPosDAux    := 0

										nItem ++

										//-- Variavel para buscar dados do destino (já que variavel ni e consequentemente array aDadosTransf não estão posicionados)
										nPosDAux := aScan( aDadosAux, {|x| x[1] + x[2] == SD2->( D2_PEDIDO + D2_ITEMPV ) } )

										aAdd( aLinha, { "D1_ITEM", Strzero( Val( SD2->D2_ITEM ), 4 ), Nil } )
										
										If nPosDAux > 0
											aAdd( aLinha, { "D1_COD"  , aDadosAux[nPosDAux, 04], Nil } )
											aAdd( aLinha, { "D1_LOCAL", aDadosAux[nPosDAux, 03], Nil } )
										Else
											//-- Item adicionado pelo PE M310ITENS (nao tem detalhes do destino no aDadosAux)
											aAdd( aLinha, { "D1_COD"  , SD2->D2_COD, Nil } )
											aAdd( aLinha, { "D1_LOCAL", aDadosTransf[ni-1, 07], Nil } )
										EndIf

										aAdd( aLinha, { "D1_UM"     , SD2->D2_UM, Nil } )
										aAdd( aLinha, { "D1_QUANT"	, SD2->D2_QUANT, Nil } )
										aAdd( aLinha, { "D1_VUNIT"  , SD2->D2_PRCVEN, Nil } )
										aAdd( aLinha, { "D1_TOTAL"  , SD2->D2_TOTAL, Nil } )

										//-- Altera para filial destino
										cFilAnt := aDadosTransf[nx, 06]

										If aParam310[14] == 2
											//-- Nota Classificada
											aAdd( aLinha, { "D1_TES", aDadosTransf[IIf( nItem > Len( aDadosTransf ), Len( aDadosTransf ), nItem ), 24], Nil } )
										ElseIf aParam310[14] == 1
											//-- Nota a classificar
											aAdd( aLinha, { "D1_TESACLA", SubStr( aDadosTransf[IIf( nItem > Len( aDadosTransf ), Len( aDadosTransf ), nItem ), 24], 1, Len( "D1_TESACLA" ) ), Nil } )
										Endif
										
										//-- Checa se utiliza rastreabilidade
										If Rastro( SD2->D2_COD )
											aAdd( aLinha, { "D1_LOTECTL", SD2->D2_LOTECTL, Nil } )

											If Rastro( SD2->D2_COD, "S" )
												aAdd( aLinha, { "D1_NUMLOTE", SD2->D2_NUMLOTE, Nil } )
											EndIf
											
											aAdd( aLinha, { "D1_DTVALID", SD2->D2_DTVALID, Nil } )
											aAdd( aLinha, { "D1_DFABRIC", SD2->D2_DFABRIC, Nil } )
										EndIf

										If cPaisLoc == "BRA"
											aAdd( aLinha, { "D1_FCICOD", SD2->D2_FCICOD, Nil } )
										EndIf

										// Tratamento para gravacao dos campos D1_BASNDES e D1_ICMNDES.
										// Mesmo tratamento feito no NFESEFAZ para impressao nas infos. complementares.
										cFilAnt := aDadosTransf[nx, 01]

										aAdd( aLinha, { "D1_CLASFIS", SD2->D2_CLASFIS, Nil } )
										aAdd( aLinha, { "D1_POTENCI", SD2->D2_POTENCI, Nil } )
										aadd( aItens, aLinha )

										DbSelectArea("SD2")
										SD2->( DbSkip() )
									EndDo

									//-- Classifica o aitens por item da SD2
									aSort( aItens, , , {|x,y| x[1,2] < y[1,2] } )
									
									//-- Caso tenha itens e cabecalho definidos
									If Len( aItens ) > 0 .And. Len( aCabec ) > 0
										//-- Atualiza para a filial destino
										cFilAnt := aDadosTransf[ni-1, 06]

										//-- Reinicializa ambiente para o fiscal
										If MaFisFound()
											MaFisEnd()
										EndIf

										//-- Rotina para salvar o arrary de itens do pedido de vendas 
										U_REESTA05( aItens )

										If !IsBlind() .And. !IsInCallStack("U_REFATA06")
											MsProcTxt( "Gerando Doc. Entrada na Filial Destino [" + cFilAnt + "]..." )
										EndIf

										//-- Checa geracao de documento
										If aParam310[14] == 2
											//-- Inclui nota de entrada
											MsExecAuto( { |x, y, z| MATA103( x, y, z ) }, aCabec, aItens, 3 )
										ElseIf aParam310[14] == 1
											//-- Inclui pre-nota
											MsExecAuto( { |x, y, z| MATA140( x, y, z ) }, aCabec, aItens, 3 )
										EndIf

										//-- Checa erro de rotina automatica
										If lMsErroAuto
											lMostraErro	:=.T.
										EndIf

										//-- Atualiza para a filial origem
										cFilAnt := aDadosTransf[ni-1, 01]

										//-- Carrega dados do Fornecedor de Destino da Nota Fiscal - UPDEST09 //
										DbSelectArea("SF2")
										SF2->( DbSetOrder(1) )
										If SF2->( DbSeek( xFilial("SF2") + PadR( aNotaFeita[nx], TamSX3( "D2_DOC" )[1]) + cSerie + aDadosTransf[ni-1, 08] + aDadosTransf[ni-1, 09] ) )
											RecLock( "SF2", .F. )
											SF2->F2_FILDEST := aDadosTransf[ni-1, 06]
											SF2->F2_FORDES  := aDadosTransf[ni-1, IIf( lPODER3, 08, 10 )]
											SF2->F2_LOJADES := aDadosTransf[ni-1, IIf( lPODER3, 09, 11 )]
											SF2->F2_FORMDES := "N"
											SF2->( MsUnlock() )
										EndIf
									EndIf
								EndIf
							Next nx
						EndIf					
					Elseif lREESTA01 .And. l311NumPed
						For nBloqueio := 1 To Len( aBloqueio )
							aAdd( aBloqueio[nBloqueio], c311FilDes )
							aAdd( a311Bloq, aBloqueio[nBloqueio] )
						Next nBloqueio
					Else
						cPedidos := ""
						For nBloqueio := 1 To Len( aBloqueio )
							If nBloqueio # 1 .And. aBloqueio[nBloqueio, 01] == aBloqueio[nBloqueio-1, 01]
								Loop
							EndIf

							cPedidos += aBloqueio[nBloqueio, 01] + "/"
						Next nBloqueio
						
						Help( Nil, Nil, "PV BLOQUEADO", Nil, "O(s) Pedido de Venda(s) Nro(s) " + SubStr( cPedidos, 1, Len( cPedidos ) - 1 ) + " foram bloqueados, por este motivo o processo de Transferencia de Materiais foi cancelado. Para maiores detalhes verificar os pedidos de vendas bloqueados atraves do modulo de Faturamento.", 1, 0 )
					EndIf
				EndIf
			Else
				Help( Nil, Nil, "TRFSERERR", Nil, "A filial [" + cFilAnt + "] nao teve uma serie de nota fiscal de saida selecionada para geracao.", 1, 0 )

				//-- Variavel para processamento
				cWhile := aDadosTransf[ni, 01]

				//-- Varre todos os itens com esta filial origem
				While ( ni <= Len( aDadosTransf ) ) .And. aDadosTransf[ni, 01] == cWhile
					//-- Incrementa regua de processamento
					IncProc()
					ni++
				EndDo
			EndIf
		EndDo

		If lREESTA01 .And. Len(a311Bloq) > 0
			//-- Obtem o numero dos pedidos de venda gerados na transferencia
			cPedidos := ""
			
			For nBloqueio := 1 To Len( a311Bloq )
				If nBloqueio # 1 .And. a311Bloq[nBloqueio, 01] == a311Bloq[nBloqueio-1, 01]
					Loop
				EndIf

				cPedidos += a311Bloq[nBloqueio, 01] + "/"
			Next nBloqueio

			//-- Apresenta a tela de bloqueio
			Do while nOpc == 2
				nOpc := Aviso("PV Bloqueado","Os Pedidos de Venda " + SubStr(cPedidos,1,Len(cPedidos)-1) + " foram bloqueados. Clique em Visualizar para consultar os itens com bloqueio. Para prosseguir com a efetivação, clique em Continuar." + Space(200) + "Ao continuar, a solcitação de transferência será encerrada e o pedido gerado bloqueado. As notas fiscais NÃO serão geradas automaticamente.",{"Cancelar","Visualizar","Continuar"})
				
				If nOpc == 2
					MA311Tela( a311Bloq )
				Endif
			EndDo

			//-- Continua com a gravação caso o usuário escolha continuar com o processo
			If nOpc == 3
				lRet := MsgYesNo( "Deseja confirmar a geração do pedido de venda?", "PV Bloqueado" )
				IIF( lRet, l311GerPed := .T., )
			Else
				lRet := .F.
			EndIf
		EndIf
	Else
		lRet := .F.
	EndIf

    //-- Limpa conteudo da variavel usada no MATA103
	c310FilMov := ""
    
	//-- Restaura filial original
	cFilAnt := cFilOri
    
	//-- Mostra erro em rotina automatica
	If lMostraErro
		If IsBlind()
			cFileLog := NomeAutoLog()
            cMsg     := MemoRead( cFileLog )
			cErrComm := cMsg
            If !Empty( cMsg )
                ConOut( cMsg )
            Endif
		Else
			MostraErro()
		EndIf
		lRet := .F.
	EndIf

Return lRet


/*/{Protheus.doc} GetUF
Retorna a UF do Fornecedor da Filial Destino 
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 10/06/2022
@param aDadosTransf, array, Dados da Transferencia
@param lTerceiros, logical, Indica terceiros
@return character, Retorno UF
/*/
Static Function GetUF(aDadosTransf, lTerceiros) //-- M310GetUF
	Local aArea		:= GetArea()
	Local aAreaSA2	:= SA2->(GetArea())
	Local cFilAux	:= cFilAnt
	Local cUF		:= ""

	cFilAnt := aDadosTransf[06]

	If lTerceiros
		DbSelectArea("SA1")
		SA1->( DbSetOrder(1) )
		If SA1->( DbSeek( xFilial("SA1") + aDadosTransf[08] + aDadosTransf[09] ) )
			cUF := SA1->A1_EST
		EndIf
	Else
		DbSelectArea("SA2")
		SA2->( DbSetOrder(1) )
		If SA2->( DbSeek( xFilial("SA2") + aDadosTransf[10] + aDadosTransf[11] ) )
			cUF := SA2->A2_EST
		EndIf
	EndIf

	cFilAnt := cFilAux

	RestArea(aAreaSA2)
	RestArea(aArea)

Return cUF


//-- Pega o preco de venda na entrada do material na INDUSTRIA ou ARMAZEM
Static Function GetPrcVen(cProduto, cLoteCTL, cNumLote, cCliFor, cLjCliFor)
	Local aAreaAnt  := GetArea()
	Local aAreaSD1  := SD1->( GetArea() )
	Local cQuery    := ""
	Local cNNTDoc   := ""   
	Local cNNTSerie := ""
	Local nPrcVen   := 0

	//-- Acha a nota e serie no resgistro de solicitacao de transferencias
    cQuery := " SELECT " + CRLF
    cQuery += "     MAX(NNT.NNT_DOC) AS DOC, MAX(NNT.NNT_SERIE) AS SERIE " + CRLF
    cQuery += " FROM " + CRLF
    cQuery += "     " + RetSqlName("NNT") + " NNT " + CRLF
    cQuery += " WHERE " + CRLF
    cQuery += "     NNT.NNT_FILIAL = '" + cXFilPedFilm + "' " + CRLF
	cQuery += "     AND NNT.NNT_PROD = '" + cProduto + "' " + CRLF
    cQuery += "     AND NNT.NNT_LOTECT = '" + cLoteCTL + "' " + CRLF
	cQuery += "     AND NNT.NNT_NUMLOT = '" + cNumLote + "' " + CRLF
    cQuery += "     AND NNT.D_E_L_E_T_ = ' ' " + CRLF

	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "_TMPNNT", .F., .T. )

	If _TMPNNT->( !Eof() )
		cNNTDoc   := _TMPNNT->DOC
		cNNTSerie := _TMPNNT->SERIE
	EndIf
    
	_TMPNNT->( DbCloseArea() )

	If !Empty( cNNTDoc + cNNTSerie )
		cQuery := " SELECT " + CRLF
		cQuery += " 	SD1.D1_VUNIT " + CRLF
		cQuery += " FROM " + CRLF
		cQuery += " 	" + RetSqlName("SD1") + " SD1 " + CRLF
		cQuery += " WHERE " + CRLF
		cQuery += " 	SD1.D1_FILIAL = '" + xFilial("SD1") + "' " + CRLF 
		cQuery += " 	AND SD1.D1_DOC = '" + cNNTDoc + "' " + CRLF
		cQuery += " 	AND SD1.D1_SERIE = '" + cNNTSerie + "' " + CRLF
		cQuery += " 	AND SD1.D1_FORNECE = '" + cCliFor + "' " + CRLF
		cQuery += " 	AND SD1.D1_LOJA = '" + cLjCliFor + "' " + CRLF
		cQuery += " 	AND SD1.D1_LOTECTL = '" + cLoteCTL + "' " + CRLF
		cQuery += " 	AND SD1.D1_NUMLOTE = '" + cNumLote + "' " + CRLF
		cQuery += " 	AND SD1.D_E_L_E_T_ = ' ' " + CRLF

		DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "_TMPSD1", .F., .T. )

		If _TMPSD1->( !Eof() )
			nPrcVen := _TMPSD1->D1_VUNIT
		EndIf

		_TMPSD1->( DbCloseArea() )
	EndIf

	RestArea( aAreaSD1 )
	RestArea( aAreaAnt )

Return nPrcVen

/*/{Protheus.doc} fBusUltNfs
Retorno Ultimas NFS e Serie dos Produtos a serem Retornados
@type function
@version  1.0
@author Marcos P.Aversa
@since 08/02/2023
@param aDadosTransf, array, Dados do Pedido
@return character, Numero de Nfs e Series dos Produtos Retornados
/*/
Static Function fBusUltNfs(  aDTransf  )
    local aArea     := GetArea()
	local IX        := 1
	local cxFilOrig := ""
	local cProd     := ""
    Private cRetNFS := ""
	Private aNFs    := {}

	//-- Sorteia array para Ordenar por Produto
	aSort( aDTransf, , , {|x,y| x[2] < y[2] } )
	

	FOR IX := 1 TO Len( aDTransf )
		IF IX == 1
			cxFilOrig := aDTransf[ IX, 06]
			cProd     := aDTransf[ IX, 02]
			cRetNFS   := cRetNFS + fVerULTNF( IX, cxFilOrig, cProd  )
		Else    
			IF cProd <>  aDTransf[ IX, 02]
				cxFilOrig := aDTransf[ IX, 06]
				cProd     := aDTransf[ IX, 02]
				cRetNFS   := cRetNFS + fVerULTNF( IX, cxFilOrig, cProd  )
			Endif
		Endif
	NEXT IX

	RestArea( aArea )
Return cRetNFS


Static Function  fVerULTNF( nItem, cFilOrig, cProd  )
	local cQuery := ""
	local cRet   := ""

	cQuery  := "   SELECT DISTINCT D2.D2_DOC,D2.D2_SERIE "+ CRLF  
	cQuery  += " 	FROM( "+ CRLF  
	cQuery  += "       SELECT MAX(D2_EMISSAO) DIGIT "+ CRLF   
	cQuery  += "       FROM " + RetSqlName("SD2") + " XD2 "+ CRLF  	
	cQuery  += " 	   WHERE XD2.D_E_L_E_T_ = ' ' "+ CRLF   
	cQuery  += "       AND XD2.D2_FILIAL = '" + cFilOrig + "' "+ CRLF  	
	cQuery  += "       AND XD2.D2_COD = '" + cProd + "' "+ CRLF  	
	cQuery  += "       ) XX "+ CRLF   
	cQuery  += "     JOIN " + RetSqlName("SD2") + " D2 "+ CRLF  
	cQuery  += " 	   ON  D2.D_E_L_E_T_ = ' ' "+ CRLF  
	cQuery  += "        AND D2.D2_FILIAL = '" + cFilOrig + "' "+ CRLF  		
	cQuery  += " 	    AND D2.D2_EMISSAO = XX.DIGIT "+ CRLF 
	cQuery  += "        AND D2.D2_COD = '" + cProd + "' "+ CRLF 
	cQuery  += "   ORDER BY  D2_DOC DESC,D2_SERIE "+ CRLF 	 	  

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "XTEMP", .F., .T.)

	If XTEMP->( !EOF())
		If aScan( aNFs,{|x| x[1]==XTEMP->D2_DOC+"/"+Alltrim(XTEMP->D2_SERIE)	 }) == 0
		   AADD( aNFs  ,{ XTEMP->D2_DOC+"/"+Alltrim(XTEMP->D2_SERIE) } )
           cRet := If( Empty( cRetNFS ), "Retorno Ref. NF(s) : "+ XTEMP->D2_DOC+"/"+Alltrim(XTEMP->D2_SERIE), " - "+XTEMP->D2_DOC+"/"+Alltrim( XTEMP->D2_SERIE ) ) 		   
		Endif                   	
    Endif

    XTEMP->( dbCloseArea() )

Return cRet


//-- Funcao responsavel por apresentar a tela na efetivacao da transferencia
Static Function MA311Tela(aBloqueio)
	Local oDlg, oQual

	DEFINE MSDIALOG oDlg TITLE "Itens Bloqueados" From 09,0 To 27.5,85 OF oMainWnd
	@ 0.5,0.5 LISTBOX oQual VAR cVar Fields HEADER "Pedido","Item","Produto","Quantidade","Bloqueio" SIZE 280,130
	oQual:SetArray(aBloqueio)
	oQual:bLine := {|| {aBloqueio[oQual:nAT][1],aBloqueio[oQual:nAT][2],AllTrim(aBloqueio[oQual:nAT][4]),aBloqueio[oQual:nAT][5],;
	If(!Empty(aBloqueio[oQual:nAT][6]),"Credito","") + If(!Empty(aBloqueio[oQual:nAT][7]),If(!Empty(aBloqueio[oQual:nAT][6]),"/" + "Estoque","Estoque"),"") +;
	If(!Empty(aBloqueio[oQual:nAT][8]),If(!Empty(aBloqueio[oQual:nAT][6]) .Or. !Empty(aBloqueio[oQual:nAT][7]),"/" + "STR0120","STR0120"),"")}}
	oQual:lHScroll := .F.
	@ 045,295 BUTTON "Voltar" SIZE 030, 012 PIXEL OF oDlg ACTION (oDlg:End())
	@ 065,295 BUTTON "Estoque" SIZE 030, 012 PIXEL OF oDlg ACTION MaViewSB2(aBloqueio[oQual:nAT][4])
	@ 085,295 BUTTON "Pedido" SIZE 030, 012 PIXEL OF oDlg ACTION MA311VPed(aBloqueio[oQual:nAT][1])
	ACTIVATE MSDIALOG oDlg

Return NIL


//--
Static Function MA311VPed(cPedido)
	Local aAreaAnt := GetArea()
	Local aAreaSC5 := SC5->(GetArea())

	//Desabilita a função F4 para não apresentar erro na visualização do pedido
	SetKey( VK_F4, Nil)	 

	//Posiciona no pedido de venda
	DbSelectArea("SC5")
	DbSetOrder(1)
	DbSeek(xFilial("SC5")+cPedido)

	MATA410(,,,,"A410Visual")

	//Restaura a consulta F4.
	SetKey(VK_F4,{|| A311SetKey() })

	RestArea(aAreaSC5)
	RestArea(aAreaAnt)

Return
