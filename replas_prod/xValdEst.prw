#Include "Protheus.Ch"
#Define cEnter  Chr(13) + Chr(10)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ xValdEst  ºAutor  ³Eduardo Augusto      Data ³  12/09/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Programa para Validar a Quantidade em Estoque e se a TES   º±±
±±º          ³ Movimenta Estoque (Sim ou Não).                            º±±
±±º          ³ Essa Função é chamada via Gatilho ao digitar a TES.        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Replas                                                     º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function xValdEst(cOrig)
Local cCodFil	:= FWCodFil()	// Retorna o Código da Filial (M0_CODFIL)
Local nProd		:= aScan(aHeader,{|x|AllTrim(x[2]) == "C6_PRODUTO"})
Local nLoc		:= aScan(aHeader,{|x|AllTrim(x[2]) == "C6_LOCAL"})
Local nQtde		:= aScan(aHeader,{|x|AllTrim(x[2]) == "C6_QTDVEN"})
Local nTes 		:= aScan(aHeader,{|x|AllTrim(x[2]) == "C6_TES"})
Local cXVldEst	:= GetNewPar("MV_XVLDEST","1")
Local _Ret 		:= Nil
Local lVldEst 	:= .T.
Local nSldB2	:= 0
Local lMsg 		:= .T.
Local cFilResev := GetMv( "RE_FILRSV", .F., "0101/0102/0103/0302/" ) //-- Filiais que teram a inclusao de Reservas. by Dener Lemos

Default cOrig	:= "2" // Origem da chamada da Função --- 1 = Valid de Campos / 2 = Gatilho ---- David Sobrinho

If !IsinCallStack("XRLSMOTOR") .And. cCodFil $ cFilResev .and. cXVldEst == "1"
	cGrupo	 := Posicione("SB1", 1, xFilial("SB1") + aCols[n,nProd], "B1_XGRUPO")
	If cGrupo $ "2/3" 
		// Posicionando na Tabela de Saldo Fisico do Produto
		DbSelectArea("SB2")
		SB2->(DbSetOrder(1))	// B2_FILIAL + B2_COD + B2_LOCAL
		If SB2->(DbSeek(xFilial("SB2") + aCols[n][nProd] + aCols[n][nLoc] ) )
			nSldB2 := SaldoSB2()
			// Em caso de alteração do pedido considera a diferenca para compor o saldo da SB2
			If Type("Altera") == "L" .And. Altera
				/*cReser := aCols[n][nReser]
			 	If !Empty(cReser)
			 		If SC6->C6_QTDVEN > aCols[n][nQtde]
						nSldB2 :=  nSldB2 + ( SC6->C6_QTDVEN - aCols[n][nQtde] )
					Else
						nSldB2 :=  nSldB2 + ( aCols[n][nQtde] - SC6->C6_QTDVEN )
					EndIf
				EndIf*/
				SC0->(DbSetOrder(1))
				If SC0->(DbSeek(xFilial("SC0")+M->C5_NUM+aCols[n][nProd]))
					nSldB2 := nSldB2 + SC0->C0_QTDORIG
				EndIf
	        EndIf
			If aCols[n][nQtde] > nSldB2
				SF4->(DbSetOrder(1))	// F4_FILIAL + F4_CODIGO
				If SF4->(DbSeek(xFilial("SF4") + aCols[n][nTes] ))  
					If SF4->F4_ESTOQUE == "S"
						lVldEst := .F.				
					EndIf
				EndIf
			EndIf
		Else
			lVldEst := .F.
		EndIf
	EndIf
EndIf
// Senão tiver Saldo 
If !lVldEst .And. lMsg
	MsgAlert("Produto: ( " + Alltrim(aCols[n][nProd]) + " ) " + cEnter + ;
			 "Armazém: ( " + aCols[n][nLoc] + " ) " + cEnter + ;
			 "Quantidade a ser Vendida: ( " + Str(aCols[n][nQtde]) + " ) " + cEnter + ;
			 'Quantidade disponível em Estoque insuficiente: ( ' + Str(nSldB2) + ' ) ' + cEnter + cEnter + ;
			 'Por favor, avalie o Estoque do Produto, pois, '+cEnter+' NÃO podemos seguir com a gravação do pedido.','Consulta Estoque')
EndIf
// (David Sobrinho 04/10/17) Valida retorno da Função de acordo origem da chamada
If cOrig == '1'
	_Ret := lVldEst
EndIf
If cOrig == '2'
	_Ret := aCols[n][nTes]
EndIf
Return(_Ret)
