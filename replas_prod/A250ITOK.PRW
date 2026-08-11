#INCLUDE "TOTVS.CH"


/*/{Protheus.doc} A250ITOK
Ponto de Entrada que permite executar qualquer customizacao 
antes da gravacao de um apontamento de producao
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 28/01/2023
/*/
User Function A250ITOK()
	Local aAreaAnt    := GetArea()
    Local aAreaSC2    := {}
	Local aErros	  := {}
	Local aSaldo	  := {}
	Local aReqsOk	  := {}
	Local aNewSal	  := {}
	Local cFilDest    := GetMV( "RE_FILDEST", .F., "0201" )
    Local cLinha      := ""
    Local cColuna     := ""
    Local cParcTot    := ""
	Local cQuery      := ""
	Local cAliasQry   := ""
    Local cMens       := ""
    Local cQuant      := ""
    Local cESTNEG	  := GetMv("MV_ESTNEG" )
    Local cIndNeg	  := SuperGetMv("MV_INDNEG",.F.,'E')
    Local cLOCPROC	  := SuperGetMv("MV_LOCPROC",.F.,'99')
    Local cPicB2QATU  := PesqPictQT("B2_QATU")
    Local cMascara	  := GetMv("MV_MASCGRD")
    Local nQtdGanho   := 0
	Local nQtdMaior   := 0
    Local nPercPrM	  := 0
    Local nLinha      := 0
	Local nColuna     := 0
    Local nAux        := 1
	Local nPerda      := 0
	Local nQuant      := 0
	Local nTamRef	  := Val(Substr(cMascara,1,2))
	Local nTamLin	  := Val(Substr(cMascara,4,2))
	Local nTamCol	  := Val(Substr(cMascara,7,2))
    Local nIndice	  := 1
	Local nIndex      := 0
	Local nTamB1_COD  := TamSX3("B1_COD")[1]
    Local ni          := 1
    Local nX          := 1
	Local lAtuEmp     := ParamIXB
	Local lAptPerda   := GetMv( "RE_APTPRD", .F., .T. )
	Local lIntIndMM   := GetMV( "RE_INTIND", .F., .T. )
    Local lRet		  := .T.
    Local lReferencia := MatGrdPrrf(M->D3_COD)
    Local lAchou	  := .F.
    Local lErrInvent  := .F.
    Local lErrLote	  := .F.
	Local lErrSaldo	  := .F.
    Local lSemSaldo	  := .F.
    Local lErrBlqMov  := .F.
    Local lErrSld	  := .F.

	If !lAtuEmp .And. lIntIndMM .And. lAptPerda .And. cFilAnt == cFilDest .And. !IsInCallStack( "U_REFATA06" )
		aSaldo  := {}
		aNewSal := {}
		aErros  := {}
		aReqsOk := {}

		If !l250Auto
			//Verifica a necessidade de prorporcionalização dos empenhos SD4  //Everton
			lRet := a250Maior(M->D3_OP, M->D3_QUANT, M->D3_PERDA, @nQtdGanho, @nQtdMaior, @nPercPrM, "SD3")
			M->D3_QTMAIOR := nQtdMaior
			M->D3_QTGANHO := nQtdGanho
		Else
			lExistePM := .F.
			If l250Auto
				If M->D3_QTMAIOR > 0
					lRet := a250Maior(M->D3_OP, M->D3_QUANT, M->D3_PERDA, @nQtdGanho, @nQtdMaior, @nPercPrM, "SD3")
					lExistePM := .T.
				EndIf
			EndIf
		EndIf
		If !lProdAut
			SF5->(dbSetOrder(1))
			If SF5->(dbSeek(xFilial("SF5")+M->D3_TM)) //.And. SF5->F5_ATUEMP == "S"
				If !lReferencia
					if lRet = .T.
						A250Estoq(M->D3_QUANT+If(lPerdInf,0,M->D3_PERDA) - nQtdGanho,M->D3_PARCTOT,M->D3_COD,Alltrim(M->D3_OP),@aSaldo,@aReqsOK, , ,nPercPrM)
					endif
				Else
					dbSelectArea("SC2")
					dbSetOrder(1)
					dbSeek(xFilial("SC2")+Alltrim(M->D3_OP))

					Do While !Eof() .And. C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN == xFilial("SC2")+Alltrim(M->D3_OP)
						If !Empty(SC2->C2_DATRF)
							dbSkip()
							Loop
						EndIf
						lAchou := .F.

						If IsAtNewGrd()
							cLinha	:= Substr(SC2->C2_PRODUTO,oGrade:TamRef()+1,oGrade:TamLin())
							cColuna	:= Substr(SC2->C2_PRODUTO,oGrade:TamRef()+oGrade:TamLin()+1,oGrade:TamCol())

							For nLinha := 1  To Len(oGrade:aColsGrade[nAux])
								For nColuna := 2 To Len(oGrade:aHeadGrade[nAux])
									If oGrade:GetNameLinha(nLinha)==cLinha .And. oGrade:GetNameColuna(nColuna) == cColuna .And.;
											!Empty(oGrade:aColsFieldByName("D3_QUANT",nAux,nLinha,nColuna))
										lAchou		:= .T.
										aAreaSC2	:= SC2->(GetArea())
										nPerda		:= oGrade:aColsFieldByName("D3_PERDA"	,nAux,nLinha,nColuna)
										nQuant		:= oGrade:aColsFieldByName("D3_QUANT"	,nAux,nLinha,nColuna)
										cParcTot	:= oGrade:aColsFieldByName("D3_PARCTOT"	,nAux,nLinha,nColuna)
										A250Estoq(nQuant+If(lPerdInf,0,nPerda),cParcTot,SC2->C2_PRODUTO,(SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+SC2->C2_ITEMGRD),@aSaldo,@aReqsOK)
										RestArea(aAreaSC2)
										Exit
									EndIf
								Next nColuna
								If lAchou
									Exit
								EndIf
							Next nLinha
						Else
							For nLinha := 1  To Len(aColsGrade[nAux])
								For nColuna := 2 To Len(aHeader)
									If aColsGrade[nAux][nLinha][1]==Substr(SC2->C2_PRODUTO,nTamRef+1,nTamLin) .And. aHeadGrade[nAux][nColuna][1]== Substr(SC2->C2_PRODUTO,nTamRef+nTamLin+1,nTamCol) .And.;
											aColsGrade[nAux][nLinha][nColuna][1] != 0
										lAchou := .T.
										aAreaSC2 := SC2->(GetArea())
										nPerda := If(Len(aQtdPerda)>0, aQtdPerda[nLinha][nColuna], 0)
										nQuant := aColsGrade[nAux][nLinha][nColuna][1]
										cParcTot := aColsPT[nLinha][nColuna]
										A250Estoq(nQuant+If(lPerdInf,0,nPerda),cParcTot,SC2->C2_PRODUTO,(SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+SC2->C2_ITEMGRD),@aSaldo,@aReqsOK)
										RestArea(aAreaSC2)
										Exit
									EndIf
								Next nColuna
								If lAchou
									Exit
								EndIf
							Next nLinha
						EndIf
						dbSelectArea("SC2")
						dbSkip()
					EndDo
				EndIf
			EndIf
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Proporcionaliza de acordo com a qtde da OP Pai     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !lReferencia
				If M->D3_PARCTOT == "P" .And. cBxProp == "S"
					nIndice := Min(1,(M->D3_QUANT + M->D3_PERDA) / (SC2->C2_QUANT - SC2->C2_QUJE))
				EndIf
				aNeed := {}
				A250CalInd(M->D3_OP,nIndice)
				LotesSD4(nIndice,Alltrim(M->D3_OP),0,NIL,.T.,@aSaldo,@aReqsOk,NIL, NIL, nPercPrM)
			Else
				dbSelectArea("SC2")
				dbSetOrder(1)
				dbSeek(xFilial("SC2")+Alltrim(M->D3_OP))
				aArea := GetArea()
				Do While !Eof() .And. C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN == xFilial("SC2")+Alltrim(M->D3_OP)
					If !Empty(SC2->C2_DATRF)
						dbSkip()
						Loop
					EndIf

					lAchou := .F.
					If IsAtNewGrd()
						cLinha	:= Substr(SC2->C2_PRODUTO,oGrade:TamRef()+1,oGrade:TamLin())
						cColuna	:= Substr(SC2->C2_PRODUTO,oGrade:TamRef()+oGrade:TamLin()+1,oGrade:TamCol())

						For nLinha := 1  To Len(oGrade:aColsGrade[nAux])
							For nColuna := 2 To Len(oGrade:aHeadGrade[nAux])
								If oGrade:GetNameLinha(nLinha)==cLinha .And. oGrade:GetNameColuna(nColuna) == cColuna .And.;
										!Empty(oGrade:aColsFieldByName("D3_QUANT",nAux,nLinha,nColuna))
									aAreaSC2:= SC2->(GetArea())
									nPerda	:= oGrade:aColsFieldByName("D3_PERDA"	,nAux,nLinha,nColuna)
									nQuant	:= oGrade:aColsFieldByName("D3_QUANT"	,nAux,nLinha,nColuna)
									cParcTot:= oGrade:aColsFieldByName("D3_PARCTOT"	,nAux,nLinha,nColuna)
									If cParcTot == "P" .And. cBxProp == "S"
										If lPerdInf
											nIndice := Min(1,nQuant / (SC2->C2_QUANT - SC2->C2_QUJE))
										Else
											nIndice := Min(1,(nQuant + nPerda) / (SC2->C2_QUANT - SC2->C2_QUJE))
										EndIf
									Else
										nIndice := 1
									EndIf
									aNeed := {}
									A250CalInd(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD,nIndice)
									LotesSD4(nIndice,C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD,0,NIL,.T.,@aSaldo,@aReqsOk,nQuant,cParcTot)
									RestArea(aAreaSC2)
									Exit
								EndIf
							Next nColuna
							If lAchou
								Exit
							EndIf
						Next nLinha
					Else
						For nLinha := 1  To Len(aColsGrade[nAux])
							For nColuna := 2 To Len(aHeader)
								If aColsGrade[nAux][nLinha][1]==Substr(SC2->C2_PRODUTO,nTamRef+1,nTamLin) .And. aHeadGrade[nAux][nColuna][1]== Substr(SC2->C2_PRODUTO,nTamRef+nTamLin+1,nTamCol) .And.;
										aColsGrade[nAux][nLinha][nColuna][1] != 0
									aAreaSC2 := SC2->(GetArea())
									nPerda := If(Len(aQtdPerda)>0, aQtdPerda[nLinha][nColuna], 0)
									nQuant := aColsGrade[nAux][nLinha][nColuna][1]
									cParcTot := aColsPT[nLinha][nColuna]
									If aColsPT[nLinha][nColuna]== "P" .And. cBxProp == "S"
										If lPerdInf
											nIndice := Min(1,nQuant / (SC2->C2_QUANT - SC2->C2_QUJE))
										Else
											nIndice := Min(1,(nQuant + nPerda)/ (SC2->C2_QUANT - SC2->C2_QUJE))
										EndIf
									Else
										nIndice := 1
									EndIf
									aNeed := {}
									A250CalInd(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD,nIndice)
									LotesSD4(nIndice,C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD,0,NIL,.T.,@aSaldo,@aReqsOk,nQuant,cParcTot)
									RestArea(aAreaSC2)
									Exit
								EndIf
							Next nColuna
							If lAchou
								Exit
							EndIf
						Next nLinha
					EndIf
					dbSelectArea("SC2")
					dbSkip()
				EndDo
				RestArea(aArea)
			EndIf
		EndIf

		//validações de numero de serie.
		For nIndex := 1 To Len(aReqsOk)
			If Localiza(aReqsOk[nIndex][1])

				lVldEndereco := .T.
				cSolucao := ""

				cAliasQry  := GetNextAlias()

				cQuery := " SELECT D4_OP, D4_PRODUTO, D4_LOCAL, DC_PRODUTO, SUM(DC_QUANT) ENDERECADO, DC_NUMSERI "
				cQuery += " FROM " + RetSqlName("SD4") + " SD4 "
				cQuery += " LEFT JOIN " + RetSqlName("SDC") + " SDC "
				cQuery += "                     ON (SDC.DC_FILIAL = SD4.D4_FILIAL AND"
				cQuery += "							SDC.DC_OP = SD4.D4_OP AND"
				cQuery += "							SDC.DC_PRODUTO = SD4.D4_COD AND"
				cQuery += "							SDC.DC_LOCAL = SD4.D4_LOCAL AND"
				cQuery += "							SDC.DC_LOTECTL = SD4.D4_LOTECTL AND"
				cQuery += "							SDC.D_E_L_E_T_ = ' ')"
				cQuery += " WHERE SD4.D4_OP = '" + SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN + "' AND "
				cQuery += " SD4.D4_FILIAL = '" + xFilial('SD4') + "' AND "
				cQuery += " SD4.D4_COD = '" + aReqsOk[nIndex][1] + "' AND "
				cQuery += " SD4.D4_LOCAL = '" + aReqsOk[nIndex][2] + "' AND "
				cQuery += " (SDC.DC_PRODUTO <> '' OR SDC.DC_PRODUTO IS NOT NULL) AND "
				cQuery += " SD4.D_E_L_E_T_ = ' ' "
				cQuery += " GROUP BY D4_OP, D4_PRODUTO, D4_LOCAL,   DC_PRODUTO, DC_NUMSERI"

				dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cAliasQry, .T., .F. )

				While (cAliasQry)->(!Eof())
					//valida se o fifo de endereço é automatico
					Do Case
					Case !lFifoEnd

						Do case
							//impede quantidade fracionada na requisição de produto com controle de endereço
						Case (Int((cAliasQry)->(ENDERECADO)) - (cAliasQry)->(ENDERECADO) ) <> 0 .AND. !Empty((cAliasQry)->(DC_NUMSERI))
							//Quando parametro MV_FIFOEND estiver desativado (.F.), quantidade empenhada de ## deve ser um numero inteiro."
							cSolucao := "Quando parametro MV_FIFOEND estiver desativado (.F.), quantidade empenhada de"+ cValToChar((cAliasQry)->(ENDERECADO)) +"deve ser um numero inteiro."
							lVldEndereco := .F.
							Exit
							//impede quantidade empenhada diferente da quantidade requisitada.
						Case ((cAliasQry)->(ENDERECADO) <> QtdComp(aReqsOk[nIndex][3]))
							//"Informar o endereço para o empenho da Ordem de Produção."
							cSolucao := "Informar o endereço para o empenho da Ordem de Produção."+ SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN
							lVldEndereco := .F.
							Exit
						EndCase

						//impede quantidade fracionada na requisição de produto com controle de endereço
					Case (Int(QtdComp(aReqsOk[nIndex][3])) - QtdComp(aReqsOk[nIndex][3])) <> 0 .AND. !Empty((cAliasQry)->(DC_NUMSERI))
						//"Quantidade da Requisição deve ser numero inteiro, favor verificar o campo Tipo Dec. OP no cadastro de Produto."
						cSolucao := "Quantidade da Requisição deve ser numero inteiro, favor verificar o campo Tipo Dec. OP no cadastro de Produto."
						lVldEndereco := .F.
						Exit
					EndCase
					(cAliasQry)->(DbSkip())
				EndDo

				//fecho a tabela
				(cAliasQry)->(DbCloseArea())

				//verifica se validou
				If !lVldEndereco
					//"Não é possivel realizar a requisição automática. O produto : ##  possui controle de endereçamento com numero de serie e não atende os requisitos para essa operação."
					HELP(' ',1,"ATENCÃO",, "Não é possivel realizar a requisição automática. O produto : "+aReqsOk[nIndex][1]+" possui controle de endereçamento com numero de serie e não atende os requisitos para essa operação.",2, 0,,,,,, {cSolucao})
					Return .F.
				EndIf
			EndIf
		Next nIndex

		If Len(aSaldo) > 0
			If cIndNeg == "E"
				cIndNeg := cEstNeg
			EndIf

			lSemSaldo := .F.
			aErros := {}
			For ni := 1 to Len(aSaldo)
				If BlqInvent(aSaldo[ni,1],aSaldo[ni,2])
					cMens:=OemToAnsi("Bloqueado p/ Inventario")	//"Bloqueado p/ Invent rio"
					cQuant:=Transform(aSaldo[ni][4],cPicB2QATU)
					lErrInvent:=.T.
					AADD(aErros,{aSaldo[ni][1],aSaldo[ni][2],cQuant,cMens,aSaldo[ni][7],aSaldo[ni][8]})
				ElseIf AvalBlqLoc(aSaldo[ni,1],aSaldo[ni,2],Nil,.F.,,,,,,M->D3_OP)
					cMens:=OemToAnsi("Bloqueado p/ Armazem")	// "Bloqueado p/ Armazem"
					cQuant:=Transform(aSaldo[ni][4],cPicB2QATU)
					lErrBlqMov:=.T.
					AADD(aErros,{aSaldo[ni][1],aSaldo[ni][2],cQuant,cMens,aSaldo[ni][7],aSaldo[ni][8]})
				ElseIf ( (QtdComp(aSaldo[ni][3],.T.) < QtdComp(0,.T.) .Or. QtdComp(aSaldo[ni][4],.T.) < QtdComp(0,.T.);
							.Or. QtdComp(aSaldo[ni][5],.T.) < QtdComp(0,.T.));
						.And. (cESTNEG = "N" .Or. Rastro(aSaldo[ni][1]) .Or. Localiza(aSaldo[ni][1])))
					//(!(aSaldo[ni][3] >= Abs(aSaldo[ni][4])) .And. !lGanhoProd .And. lProdMaior) // permite apontar producao A maior para produtos com controle de lote
					If QtdComp(aSaldo[ni][3]) != QtdComp(aSaldo[ni][4]) .And. Rastro(aSaldo[ni][1])
						cMens:=OemToAnsi("Dif. Saldo em Estoque/Lote")	//"Dif. Saldo em Estoque/Lote"
						If QtdCOmp(aSaldo[ni][3]) < QtdComp(aSaldo[ni][4])
							cQuant:=Transform(aSaldo[ni][3],cPicB2QATU)
						Else
							cQuant:=Transform(aSaldo[ni][4],cPicB2QATU)
						EndIf
						lErrLote:=.T.;lErrSaldo:=.T.
					ElseIf QtdComp(aSaldo[ni][5],.T.) < QtdComp(0,.T.)
						cMens:=OemToAnsi("Sem Saldo por Localizacao")	//"Sem Saldo por Localizacao"
						cQuant:=Transform(aSaldo[ni][5],cPicB2QATU)
						lErrLocaliz:=.T.
					ElseIf QtdComp(aSaldo[ni][4],.T.) < QtdComp(0,.T.)
						cMens:=OemToAnsi("Sem Saldo por Lote")	//"Sem Saldo por Lote"
						cQuant:=Transform(aSaldo[ni][4],cPicB2QATU)
						lErrLote:=.T.
					ElseIf QtdComp(aSaldo[ni][3],.T.) < QtdComp(0,.T.)
						cMens:=OemToAnsi("Sem Saldo em Estoque")	//"Sem Saldo em Estoque"
						cQuant:=Transform(aSaldo[ni][3],cPicB2QATU)
						lErrSaldo:=.T.
					EndIf
					lSemSaldo := .T.
					AADD(aErros,{aSaldo[ni][1],aSaldo[ni][2],cQuant,cMens,aSaldo[ni][7],aSaldo[ni][8]})

				ElseIf ( (QtdComp(aSaldo[ni][3],.T.) < QtdComp(0,.T.) .Or. QtdComp(aSaldo[ni][4],.T.) < QtdComp(0,.T.) .Or. QtdComp(aSaldo[ni][5],.T.) < QtdComp(0,.T.));
					 .And. A260ApropI(aSaldo[ni][1]) .And. aSaldo[ni][2] == cLOCPROC;
					 .And. (cIndNeg = "N" .Or. Rastro(aSaldo[ni][1]) .Or. Localiza(aSaldo[ni][1])))

				If QtdComp(aSaldo[ni][3]) != QtdComp(aSaldo[ni][4]) .And. Rastro(aSaldo[ni][1])
					cMens:=OemToAnsi("Dif. Saldo em Estoque/Lote")	//"Dif. Saldo em Estoque/Lote"
					If QtdCOmp(aSaldo[ni][3]) < QtdComp(aSaldo[ni][4])
						cQuant:=Transform(aSaldo[ni][3],cPicB2QATU)
					Else
						cQuant:=Transform(aSaldo[ni][4],cPicB2QATU)
					EndIf
					lErrLote:=.T.;lErrSaldo:=.T.
					ElseIf QtdComp(aSaldo[ni][5],.T.) < QtdComp(0,.T.)
						cMens:=OemToAnsi("Sem Saldo por Localizacao")	//"Sem Saldo por Localizacao"
						cQuant:=Transform(aSaldo[ni][5],cPicB2QATU)
						lErrLocaliz:=.T.
					ElseIf QtdComp(aSaldo[ni][4],.T.) < QtdComp(0,.T.)
						cMens:=OemToAnsi("Sem Saldo por Lote")	//"Sem Saldo por Lote"
						cQuant:=Transform(aSaldo[ni][4],cPicB2QATU)
						lErrLote:=.T.
					ElseIf QtdComp(aSaldo[ni][3],.T.) < QtdComp(0,.T.)
						cMens:=OemToAnsi("Sem Saldo em Estoque")	//"Sem Saldo em Estoque"
						cQuant:=Transform(aSaldo[ni][3],cPicB2QATU)
						lErrSaldo:=.T.
					EndIf

					lSemSaldo := .T.
					AADD(aErros,{aSaldo[ni][1],aSaldo[ni][2],cQuant,cMens,aSaldo[ni][7],aSaldo[ni][8]})

				Endif

				If !SldBlqSB2(aSaldo[ni,1],aSaldo[ni,2],,.F.)
					cMens     := OemToAnsi("Saldo Indisponivel Neste Armazem")	//"Saldo Indisponivel Neste Armazem"
					cQuant    := Transform(SB2->B2_QATU,cPicB2QATU)
					lErrSld   := .T.
					lSemSaldo := .T.
					AADD(aErros,{aSaldo[ni][1],aSaldo[ni][2],cQuant,cMens,aSaldo[ni][7],aSaldo[ni][8]})
				EndIf

			Next

			If lSemSaldo .Or. lErrInvent .Or. lErrBlqMov
				If lErrInvent
					Help(" ",1,"MA250INVENT")
				EndIf
				If lErrLote
					Help(" ",1,"MA240NEGLT")
				EndIf
				If lErrSaldo
					Help(" ",1,"MA240NEGAT")
				EndIf
				If lErrSld
					Help(" ",1,"SLDBLQSB2")
				EndIf
				If (Type("l250Auto")<>"L" .or. !l250Auto)
					MTA250TELA(aErros)
				Else
					autogrlog("Itens Sem Sld / Bloqs. / Empenhos Pendentes") //"Itens Sem Sld / Bloqs. / Empenhos Pendentes"
					autogrlog(	PadR(OemToAnsi("Produto"),nTamB1_COD)+" "+;  //Produto
								PadR(OemToAnsi("Armazem"),07)+" "+;          //Armazem
								PadL(OemToAnsi("Saldo"),20)+" "+;            //Saldo
								OemToAnsi("Ocorrencia"))                     //Ocorrencia
					For nX:= 1 to len(aErros)
						autogrlog(PadR(aErros[nx,1],nTamB1_COD)+" "+;
								  PadR(aErros[nx,2],07)+" "+;
								  Transform(aErros[nx,3],cPicB2QATU)+" "+;
								  aErros[nx,4])
					Next
				EndIf
				lRet := .F.
			EndIf
		EndIf
    EndIf

    //-- Indica se a verificacao de saldo esta com tudo ok para a inclusao do apontamento
    RecLock("SC2", .F.)
        SC2->C2_XITOK := lRet
    SC2->(MsUnlock())
    
    RestArea(aAreaAnt)

Return


/*/{Protheus.doc} MTA250TELA
Funcao que Chamada da listbox para caso de Erro
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 28/01/2023
@param aErros, array, Parametros
/*/
Static Function MTA250TELA(aErros)
	Local oDlg, oQual
	Local cCadastro := OemToAnsi("Itens Sem Sld / Bloqs. / Empenhos Pendentes")	//"Itens Sem Sld / Bloqs. / Empenhos Pendentes"
	Local lM250Erro := ExistBlock("M250ERRO")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ M250TELA - Ponto de entrada utilizado para customizacao da   ³
	//|            janela de Itens sem Saldo / bloqueados.           |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("M250TELA")
		ExecBlock("M250TELA",.F.,.F.,{aErros})
	Else
		DEFINE MSDIALOG oDlg TITLE cCadastro From 09,0 To 30.5,74 OF oMainWnd
		@ 0.5,0.5 LISTBOX oQual VAR cVar Fields HEADER OemToAnsi("Produto"),OemToAnsi("Local"),OemToAnsi("Saldo"),OemToAnsi("Ocorrência") SIZE 250,150    //"Produto"###"Local"###"Saldo"###"Ocorrˆncia"
		oQual:SetArray(aErros)
		oQual:bLine := {|| {aErros[oQual:nAT][1],aErros[oQual:nAT][2],aErros[oQual:nAT][3],aErros[oQual:nAT][4]}}
		oQual:lHScroll := .F.
		DEFINE SBUTTON FROM 50 ,260  TYPE 1 ACTION (oDlg:End()) ENABLE OF oDlg
		DEFINE SBUTTON FROM 65 ,260  TYPE 6 ACTION (If(lM250Erro,ExecBlock("M250ERRO",.F.,.F.,{aErros}),A250ERRO(aErros)) ) ENABLE OF oDlg
		If aErros[1][5] # Nil
			DEFINE SBUTTON FROM 80 ,260  TYPE 15 ACTION (A250BLQLOT(aErros[oQual:nAT][2],aErros[oQual:nAT][1],aErros[oQual:nAT][5],aErros[oQual:nAT][6])) ENABLE OF oDlg
		EndIf
		ACTIVATE MSDIALOG oDlg
	EndIf
Return NIL
