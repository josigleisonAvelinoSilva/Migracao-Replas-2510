#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"


//-- Inclusao de pedido de vendas
USER FUNCTION XMGVCPV(cJson)
	Local aArea		 := GetArea()
	Local cDoc       := ""                                                              // Número do Pedido de Vendas
	Local cC5Filial  := xFilial("SC5")
	Local cA1Cod     := "" 		                                                        // Código do Cliente
	Local cA1Loja    := ""                                                              // Loja do Cliente
	Local cA1CodEntr := ""																// Negociador - Cliente de entrega
	Local cA1LojaEntr:= ""                                                              // Loja do Negociador - Cliente de entrega	
	Local cTransp	 := ""
	Local cTpTransp  := ""
	Local cCondpag	 := ""
	Local cTabela	 := "001"
	Local cVend1	 := ""
	Local cB1Cod     := ""       						                               // Código do Produto
	Local cArmazem	 := ""
	Local cUnidade	 := ""
	Local cSegUn	 := ""
	Local nTamseg	 := 0
	Local nQuant	 := 0
	Local nQuantApr	 := 0
	Local nPrice	 := 0
	Local nTotPed 	 := 0
	Local dEntrega   := ddatabase
	Local cLogErro   := ""
	Local cMsg	     := ''
	Local cFilSA1    := ""
	Local cFilSB1    := ""
	Local cFilSE4    := ""
	Local cFilSF4    := ""
	Local nX         := 0
	Local oJson 	 := JsonObject():new()
	Local oResponse  := JSonObject():new()
	Local ret 		 := Nil
	Local nItens	 := 0
	Local aCabec     := {}
	Local aItens     := {}
	Local aLinha     := {}
	Local aErroAuto  := {}
	Local lOk        := .T.
	Local nSaveSX8
	Local cMenNota1	 := ""
	Local cMenNota2	 := ""

	Private lMsErroAuto    := .F.
	Private lAutoErrNoFile := .F.

	ret	:= oJson:fromJson(cJson)

	If ValType(ret) == "C"
		oResponse['code'] := 102
		oResponse['message'] := 'Error'
		oResponse['detailedMessage'] := 'There is a problem in the formation of the json body. Send again the json body'
		Return oResponse:toJson()
	EndIf

	varinfo("XMGVCPV_cJson", cJson)

	If (!oJson:HasProperty('items'))
		oResponse['code'] := 116
		oResponse['message'] := 'Error'
		oResponse['detailedMessage'] := 'There is no item tag. Send again the json body'
		Return oResponse:toJson()
	EndIf

	cC5Filial    := If(oJson:hasProperty("branchid")              , oJson["branchid"]              , cC5Filial)
	cA1Cod       := If(oJson:hasProperty("customercode")          , oJson["customercode"]          , cA1Cod)
	cA1Loja      := If(oJson:hasProperty("customerbranch")        , oJson["customerbranch"]        , cA1Loja)
	cA1CodEntr   := If(oJson:hasProperty("deliverycustomercode")  , oJson["deliverycustomercode"]  , cA1Cod) //-- Se o deliverycustomercode não for informado, o mesmo receberá o cA1Cod
	cA1LojaEntr  := If(oJson:hasProperty("deliverycustomerbranch"), oJson["deliverycustomerbranch"], cA1Loja) //-- Se o deliverycustomerbranch não for informado, o mesmo receberá o cA1Loja
	cTransp      := If(oJson:hasProperty("carriercode")           , oJson["carriercode"]           , cTransp)
	cTpTransp    := If(oJson:hasProperty("carriertype")           , oJson["carriertype"]           , cTpTransp)
	cCondpag     := If(oJson:hasProperty("paymentcond")           , oJson["paymentcond"]           , cCondpag)
	cVend1       := If(oJson:hasProperty("sellercode1")           , oJson["sellercode1"]           , cVend1)
	cMenNota1	 := If(oJson:hasProperty("invoicemessage1")		  , oJson["invoicemessage1"]	   , cMenNota1)
	cMenNota2	 := If(oJson:hasProperty("invoicemessage2")		  , oJson["invoicemessage2"]	   , cMenNota2)
 	
	If Empty(cC5Filial)
		oResponse['code'] := 146
		oResponse['message'] := 'Error'
		oResponse['detailedMessage'] := 'Required fields not informed -> branchid'
		Return oResponse:ToJson()	
	EndIf

	If Empty(cA1Cod)
		oResponse['code'] := 146
		oResponse['message'] := 'Error'
		oResponse['detailedMessage'] := 'Required fields not informed -> customercode'
		Return oResponse:ToJson()	
	EndIf

	If Empty(cA1Loja)
		oResponse['code'] := 146
		oResponse['message'] := 'Error'
		oResponse['detailedMessage'] := 'Required fields not informed -> customerbranch'
		Return oResponse:ToJson()	
	EndIf

	//-- VERIFICA SE EXISTE O CLIENTE E LOJA
	DbSelectArea("SA1")
	SA1->(dbSetOrder(1))
	SA1->(DbGoTop())

	IF (!SA1->(DbSeek(xFilial("SA1") + cA1Cod + cA1Loja)))
		oResponse['code'] := 103
		oResponse['message'] := 'Error'
		oResponse['detailedMessage'] := 'No customers found'
		Return oResponse:ToJson()
	EndIf

	//-- Verifica endereço de entrega (loja do negociador)
	If ((cA1Cod + cA1Loja) <> (cA1CodEntr + cA1LojaEntr))
		If (!SA1->(DbSeek(xFilial("SA1") + cA1CodEntr + cA1LojaEntr)))
			oResponse['code'] := 103
			oResponse['message'] := 'Error'
			oResponse['detailedMessage'] := 'No delivery customers found'
			Return oResponse:ToJson()
		EndIf
	EndIf

	If Empty(cVend1)
		cVend1 := SA1->A1_VEND
	EndIf

	//-- VERIFICA SE EXISTE A CONDIÇÃO DE PAGAMENTO
	DbSelectArea("SE4")
	SE4->(dbSetOrder(1))
	SE4->(DbGoTop())

	If (!Empty(cCondpag))
		If (!SE4->(DbSeek(xFilial("SE4")+cCondpag)))
			oResponse['code'] := 105	
			oResponse['message'] := 'Error'
			oResponse['detailedMessage'] := 'No payment condition found'
			Return oResponse:ToJson()
		EndIf
	EndIf

	//-- VERIFICA SE EXISTE A TRANSPORTADORA
	DbSelectArea("SA4")
	SA4->(dbSetOrder(1))
	SA4->(DbGoTop())

	If (!Empty(cTransp))
		If (!SA4->(DbSeek(xFilial("SA4")+cTransp)))
			oResponse['code'] := 106	
			oResponse['message'] := 'Error'
			oResponse['detailedMessage'] := 'No carrier found'
			Return oResponse:ToJson()
		EndIf
	EndIf

	//-- VERIFICA SE O TIPO DE FRETE ESTA CORRETO
	If (!Empty(cTpTransp))
		If (!cTpTransp$"C|F|T|R|D|S")
			oResponse['code'] := 107	
			oResponse['message'] := 'Error'
			oResponse['detailedMessage'] := 'Invalid carrier type'
			Return oResponse:ToJson()
		EndIf
	EndIf

	//-- VERIFICA SE A TABELA DE PREÇO EXISTE
	DbSelectArea("DA0")
	DA0->(dbSetOrder(1))
	DA0->(DbGoTop())

	If (!Empty(cTabela))
		If (!DA0->(DbSeek(xFilial("DA0")+cTabela)))
			oResponse['code'] := 108	
			oResponse['message'] := 'Error'
			oResponse['detailedMessage'] := 'No pricelist found'
			Return oResponse:ToJson()
		EndIf
	EndIf

	SA3->(dbSetOrder(1))
	
	If (!Empty(cVend1))
		SA3->(DbGoTop())
		
		If (!SA3->(DbSeek(xFilial("SA3")+cVend1)))
			oResponse['code'] := 109
			oResponse['message'] := 'Error'
			oResponse['detailedMessage'] := 'No mainseller found'
			Return oResponse:ToJson()
		EndIf
	EndIf

	DbSelectArea("SB1")
	SB1->(dbSetOrder(1))

	DbSelectArea("SF4")
	SF4->(dbSetOrder(1))

	cFilSA1 := xFilial("SA1")
	cFilSB1 := xFilial("SB1")
	cFilSE4 := xFilial("SE4")
	cFilSF4 := xFilial("SF4")

	If (!oJson:HasProperty('items'))
		oResponse['code'] := 114
		oResponse['message'] := 'Error'
		oResponse['detailedMessage'] := 'You must send the items tag'
		Return oResponse:ToJson()
	Else
		If (Len(oJson["items"])> 0)
			nItens	:= Len(oJson["items"])
			lOk		:= .T.
		Else
			oResponse['code'] := 115
			oResponse['message'] := 'Error'
			oResponse['detailedMessage'] := 'Bad formation in items tag'
			Return oResponse:ToJson()							
		EndIf
	EndIf	

	If lOk
		aCabec := {}
		aItens := {}

		//-- Variavel que controla numeracao
		nSaveSX8 := GetSX8Len()

		cDoc := GetSxeNum("SC5", "C5_NUM")
		RollBackSX8()

		aadd(aCabec, {"C5_NUM"		, cDoc			, Nil})
		aadd(aCabec, {"C5_TIPO"		, "N"			, Nil})
		aadd(aCabec, {"C5_EMISSAO"	, dDataBase		, Nil})
		aadd(aCabec, {"C5_CLIENTE"	, cA1Cod		, Nil})
		aadd(aCabec, {"C5_LOJACLI"	, cA1Loja		, Nil})
		aadd(aCabec, {"C5_CLIENTE"	, cA1CodEntr	, Nil})
		aadd(aCabec, {"C5_LOJAENT"	, cA1LojaEntr	, Nil})

		If (oJson["items"][1]:HasProperty('deliverydate'))
			If (Valtype(oJson["items"][1]["deliverydate"])<>"C")
				oResponse['code'] := 126
				oResponse['message'] := 'Error'
				oResponse['detailedMessage'] := 'Delivery Date must be Date'
				Return oResponse:ToJson()		
			Else		
				dEntrega := StoD(oJson["items"][1]["deliverydate"])
			EndIf			
		EndIf
		aAdd(aCabec, {"C5_FECENT"   , dEntrega     , Nil})


		If (!Empty(cTransp))
			aadd(aCabec, {"C5_TRANSP"	, cTransp		, Nil})
		EndIf		

		If (!Empty(cTpTransp))
			aadd(aCabec, {"C5_TPFRETE"	, cTpTransp		, Nil})
		EndIf				
		
		If (!Empty(cCondpag))
			aadd(aCabec, {"C5_CONDPAG"	, cCondpag		, Nil})
		EndIf						

		If (!Empty(cTabela))
			aadd(aCabec, {"C5_TABELA"	, cTabela		, Nil})
		EndIf								

		If (!Empty(cVend1))
			aadd(aCabec, {"C5_VEND1"	, cVend1		, Nil})
		EndIf

		If (!Empty(cMenNota1))
			aadd(aCabec, {"C5_MENNOTA"	, cMenNota1		, Nil})
		EndIf

		If (!Empty(cMenNota2))
			aadd(aCabec, {"C5_XMENOTA"	, cMenNota2		, Nil})
		EndIf						
																													
		For nX := 1 To nItens
			//--- Informando os dados do item do Pedido de Venda
			aLinha := {}

			cArmazem	 	:= ""
			cUnidade	 	:= ""
			cSegUn	 		:= ""		
			nTamseg	 		:= 0
			nQuant	 		:= 0
			nQuantApr	 	:= 0
			nPrice	 		:= 0
			nTotPed 	 	:= 0
			dEntrega   		:= ''

			If (oJson["items"][nX]:HasProperty('productcode'))
				cB1Cod		:= oJson["items"][nX]["productcode"]

				SB1->(DbGoTop())

				If (!Empty(cB1Cod))
					If (!SB1->(DbSeek(xFilial("SB1")+cB1Cod)))
						oResponse['code'] := 117
						oResponse['message'] := 'Error'
						oResponse['detailedMessage'] := 'Product not found'
						Return oResponse:ToJson()
					EndIf
				EndIf	
			Else
				oResponse['code'] := 132
				oResponse['message'] := 'Error'
				oResponse['detailedMessage'] := 'Product not sent'
				return oResponse:ToJson()			
			EndIf

			If (oJson["items"][nX]:HasProperty('warehousecode'))
				If (Valtype(oJson["items"][nX]["warehousecode"])=="C")
					DbSelectArea("NNR")
					NNR->(DbSetOrder(1))
					NNR->(DbGoTop())

					cArmazem := oJson["items"][nX]["warehousecode"]

					If (!Empty(cArmazem))
						If (!NNR->(DbSeek(xFilial("NNR")+cArmazem)))
							oResponse['code'] := 118
							oResponse['message'] := 'Error'
							oResponse['detailedMessage'] := 'Warehouse not found'
							Return oResponse:ToJson()
						EndIf
					EndIf				
				EndIf			
			EndIf

			If (oJson["items"][nX]:HasProperty('quantity'))
				If (Valtype(oJson["items"][nX]["quantity"])<>"N")
					oResponse['code'] := 122
					oResponse['message'] := 'Error'
					oResponse['detailedMessage'] := 'Quantity must be numerical'
					Return oResponse:ToJson()		
				Else		
					nQuant := oJson["items"][nX]["quantity"]		
				EndIf				
			EndIf

			If (oJson["items"][nX]:HasProperty('quantityapproved'))
				If (Valtype(oJson["items"][nX]["quantityapproved"])<>"N")
					oResponse['code'] := 123
					oResponse['message'] := 'Error'
					oResponse['detailedMessage'] := 'Quantity Approved must be numerical'
					Return oResponse:ToJson()		
				Else		
					nQuantApr		:= oJson["items"][nX]["quantityapproved"]		
				EndIf
			Else
				nQuantApr := nQuant
			EndIf

			/*
			Tratamento para o pedido de venda ja nascer libera, conforme solicitado
			pela Fernanda Mendonca dia 05/03/2024, pois segundo informacao passada,
			nao existe aprovacao de engenharia para os produtos Telecom.
			*/
			If Empty(nQuantApr)
				nQuantApr := nQuant
			EndIf
			
			If (oJson["items"][nX]:HasProperty('price'))
				If (Valtype(oJson["items"][nX]["price"])<>"N")
					oResponse['code'] := 124
					oResponse['message'] := 'Error'
					oResponse['detailedMessage'] := 'Price must be numerical'
					Return oResponse:ToJson()		
				Else		
					nPrice		:= oJson["items"][nX]["price"]		
				EndIf				
			EndIf
											
			If (oJson["items"][nX]:HasProperty('total'))
				If (Valtype(oJson["items"][nX]["total"])<>"N")
					oResponse['code'] := 125
					oResponse['message'] := 'Error'
					oResponse['detailedMessage'] := 'Total must be numerical'
					Return oResponse:ToJson()		
				Else
					nTotPed := oJson["items"][nX]["total"]		
				EndIf				
			EndIf

			If (oJson["items"][nX]:HasProperty('outflowtype'))
				If (Valtype(oJson["items"][nX]["outflowtype"])<>"C")
					oResponse['code'] := 125
					oResponse['message'] := 'Error'
					oResponse['detailedMessage'] := 'Tutflow Type must be character'
					Return oResponse:ToJson()		
				Else
					cTES := oJson["items"][nX]["outflowtype"]		
				EndIf				
			EndIf

			If (oJson["items"][nX]:HasProperty('deliverydate'))
				If (Valtype(oJson["items"][nX]["deliverydate"])<>"C")
					oResponse['code'] := 126
					oResponse['message'] := 'Error'
					oResponse['detailedMessage'] := 'Delivery Date must be Date'
					Return oResponse:ToJson()		
				Else		
					dEntrega := StoD(oJson["items"][nX]["deliverydate"])
				EndIf			
			EndIf
						
			aadd(aLinha,{"C6_ITEM"		, StrZero(nX,2)	, Nil})
			aadd(aLinha,{"C6_PRODUTO"	, cB1Cod		, Nil})

			If (nQuant > 0)
				aadd(aLinha,{"C6_QTDVEN"	, nQuant		, Nil})
			Else
				oResponse['code'] := 128
				oResponse['message'] := 'Error'
				oResponse['detailedMessage'] := 'Quantity must be greater than 0'
				Return oResponse:ToJson()				
			EndIf
			
			If (!Empty(cArmazem))
				aadd(aLinha,{"C6_LOCAL"		, cArmazem		, Nil})
			EndIf
			
			If (nQuantApr>0)
				aadd(aLinha,{"C6_QTDLIB"	, nQuantApr		, Nil})
			EndIf

			If (nPrice > 0)
				aadd(aLinha,{"C6_PRCVEN"	, nPrice		, Nil})
			Else
				oResponse['code'] := 129
				oResponse['message'] := 'Error'
				oResponse['detailedMessage'] := 'Price must be greater than 0'
				Return oResponse:ToJson()						
			EndIf
			
			aadd(aLinha,{"C6_PRUNIT"	, nPrice		, Nil})

			If (nTotPed > 0)
				aadd(aLinha,{"C6_VALOR"		, nTotPed		, Nil})
			Else
				oResponse['code'] := 130
				oResponse['message'] := 'Error'
				oResponse['detailedMessage'] := 'Total must be greater than 0'
				Return oResponse:ToJson()									
			EndIf

			If (!Empty(dEntrega))
				aadd(aLinha,{"C6_TES"		, cTES   		, Nil})
			EndIf	

			If (!Empty(dEntrega))
				aadd(aLinha,{"C6_ENTREG"		, dEntrega   		, Nil})
			EndIf					

			aadd(aItens, aLinha)
		Next nX

		MSExecAuto({|a, b, c, d| MATA410(a, b, c, d)}, aCabec, aItens, 3, .F.)
		
		If !lMsErroAuto
			cMsg := "Incluido com sucesso! " + cDoc

			//-- Confirma SX8
			While ( GetSx8Len() > nSaveSX8 )
				ConfirmSX8()
			EndDo

			oResponse['code'] := 142
			oResponse['message'] := 'Success'
			oResponse['detailedMessage'] := 'Sales Order created successfully: ' + cDoc
			Return oResponse:ToJson()			
		Else
			aErroAuto   := {}
			aErroAuto   := GetAutoGRLog()
			cArqErrAuto := NomeAutoLog()
			cLogErro    := Memoread(cArqErrAuto)
			cMsg        := cLogErro

			oResponse['code'] := 143
			oResponse['message'] := 'Error'
			oResponse['detailedMessage'] := 'Automatic execution failed ' + cMsg
			Return oResponse:ToJson()
		EndIf
	EndIf

	RestArea(aArea)

Return cMsg
