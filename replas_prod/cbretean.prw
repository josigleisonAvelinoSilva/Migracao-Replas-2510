#Include 'Protheus.ch'            
#Include 'APVT100.CH'      


//-- Etiqueta lida agora
Static aEtiqReadN := {} 


//--
User Function CBRETEAN()
	Local lEAN128    := .F.
	Local aRet       := {}
	Local aArea      := GetArea()
	Local cCodBar    := AllTrim(PARAMIXB[1])
	Local cLote      := ""
	Local cSubLote   := ""
	Local dDtProd    := nil
	Local dDtValid   := nil
	Local cDL        := ""
	Local nPesoL     := 0
	Local nPesoB     := 0
	
	Local nIndice    := 1
	Local cPrefBar   := "xxxxxxx" //"7892912" //-- Prefixo contratado junto a GS1 Brasil
	Local cCodReplas := ""

	Private aEan128   := {}
	Private nPos      := 0
	Private lREESTA25 := IsInCallStack("U_REESTA25")
	Private lrefata33 := IsInCallStack("u_refata33")

	//-- Reinicializa a variavel
	aEtiqReadN := {}

	Conout("----------------------------")
    Conout("cCodBar =>" + cCodBar)
 
	aEan128 := RetAis(cCodBar)

	If ! Empty(aEan128)
		// Conout("Entrou em aEAN128")
		// zArrToTxt(aEan128, .t., "aEan128.txt")
		lEAN128 := .T.

		//-- Lote
		nPos := Ascan(aEan128, {|x| x[1] == "10"})
		If nPos > 0
			cLote := aEan128[nPos, 2]
			// cLote := Padr(aEan128[nPos, 2], Len(SB8->B8_LOTECTL) )
		EndIf
		
		//-- Sub-Lote
		nPos := Ascan(aEan128, {|x| x[1] == "240"})
		If nPos > 0
			//cSubLote := aEan128[nPos, 2]
			cSubLote := Padr(aEan128[nPos, 2], Len(SB8->B8_NUMLOTE) )
		EndIf

		//-- Data da Producao
		nPos := Ascan(aEan128, {|x| x[1] == "11"})
		If nPos > 0 .and. Len(aEan128[nPos, 2]) == 6
			dDtProd := CTOD( Right(aEan128[nPos, 2], 2) + "/" + SubStr(aEan128[nPos, 2], 3, 2) + "/" + Left(aEan128[nPos, 2],2) )
		EndIf
		
		//-- Data de validade
		nPos := Ascan(aEan128, {|x| x[1] == "17"})  
		If nPos > 0 .and. Len(aEan128[nPos, 2]) == 6
			dDtValid := CTOD( Right(aEan128[nPos, 2], 2) + "/" + SubStr(aEan128[nPos, 2], 3, 2) + "/" + Left(aEan128[nPos, 2],2) )
		EndIf

		//-- Peso liquido (em kg), 6 digitos com 1 decimal
		nPos := Ascan(aEan128, {|x| x[1] == "3101"})
		If nPos > 0 .and. Len(aEan128[nPos, 2]) == 6
			nPesoL := Val(aEan128[nPos, 2]) * 0.1
		EndIf		

		//-- Peso bruto (em kg), 6 digitos com 1 decimal
		nPos := Ascan(aEan128, {|x| x[1] == "3301"})
		If nPos > 0 .and. Len(aEan128[nPos, 2]) == 6
			nPesoB := Val(aEan128[nPos, 2]) * 0.1
		EndIf

		//-- Set tiver um codigo GS1
		nPos := Ascan(aEan128, {|x| x[1] == "01"})
		If nPos > 0
			cCodBar:= Subst(aEan128[nPos,2], 2, 12)
			cDL := Left(aEan128[nPos, 2], 1)
		EndIf			

		//-- Codigo de Controle Interno (INDUSTRIA MM AMAZONIA)
		nPos := Ascan(aEan128,{|x| x[1] == "91"})
		If nPos > 0
			//-- Se for inventario temporario
			If IsInCallStack("U_REESTA08") .Or. IsInCallStack("ACDV030") .Or. IsInCallStack("ACDV035") .Or. IsInCallStack("U_REESTA18") .Or. lREESTA25 .Or. lrefata33
				//-- Retorna o codigo do produto da REPLAS com base na etiqueta lida da Industria MM Manaus
				cCodReplas := U_REESTA7C( Padr(aEan128[nPos, 2], Len(SB1->B1_COD) ), "21338912000148", iif(lrefata33, 2, 1))
				cCodBar    := Padr(cCodReplas, Len(SB1->B1_COD) )
			Else
				If Substr(aEan128[nPos,2], 1, 7) == cPrefBar
					cCodBar := aEan128[nPos,2]
					nIndice := 5
				Else
					cCodBar := Padr(aEan128[nPos, 2], Len(SB1->B1_COD) )
				EndIf
			EndIf

			aRet := RetProduto(nIndice, cCodBar, cLote, cSubLote, dDtValid, dDtProd, nPesoL, nPesoB)
		EndIf

		//-- Codigo de Controle Interno (REPLAS SP)
		nPos := Ascan(aEan128,{|x| x[1] == "92"})
		If nPos > 0
			If Substr(aEan128[nPos,2], 1, 7) == cPrefBar
				cCodBar := aEan128[nPos,2]
				nIndice := 5
			Else
				cCodBar := Padr(aEan128[nPos, 2], Len(SB1->B1_COD) )
			EndIf

			aRet := RetProduto(nIndice, cCodBar, cLote, cSubLote, dDtValid, dDtProd, nPesoL, nPesoB)
		EndIf
	Elseif Len(AllTrim(cCodBar)) > 6 .and.  Substr(cCodBar, 1, 7) == cPrefBar  
		nIndice := 5
		aRet	:= RetProduto(nIndice, cCodBar, cLote)
	Else
		Conout("Codigo do Produto")
		aRet	:= RetProduto(nIndice, cCodBar, cLote )
	EndIf

	If Len(aRet) > 0 
		Conout("Produto => "+aRet[1])
		Conout("Quantidade => "+ Str(aRet[2]))
		Conout("Lote => "+ aRet[3])
	EndIf

	zArrToTxt(aRet, .t., "aRet.txt")
	RestArea(aArea)

Return aRet 


//--
User Function CbGetReadN()
Return aEtiqReadN


//--
Static Function RetProduto(nIndice, cCodBar, cLote, cSubLote, dDtValid, dDtProd, nPesoL, nPesoB)
	Local aRet	:= {}
	Local nQuant:= Iif(Empty(nPesoL), 1, nPesoL)

	//-- Se for inventario temporario (Precisa desse taratamento pois no inventario terao produtos que ainda nao tem no SB1)
	If IsInCallStack("U_REESTA08") .Or. lREESTA25
		AAdd(aRet, cCodBar)
		AAdd(aRet, nQuant)
		AAdd(aRet, cLote)
		AAdd(aRet, dDtValid)
		AAdd(aRet, )
		AAdd(aRet, cSubLote)
	Else
		SB1->( DbSetOrder(nIndice) )
		If SB1->( DBSeek(xFilial("SB1") + cCodBar ) )
			//-- Trabamento para os dados do lote
			cLote    := Iif(Empty(cLote), Space(TamSX3("B8_LOTECTL")[1]), cLote)
			cSubLote := Iif(Empty(cSubLote), Space(TamSX3("B8_NUMLOTE")[1]), cSubLote)
			dDtValid := Iif(Empty(dDtValid), CTOD("  /  /  "), dDtProd)

			//-- Preenche a variavel estatica com os dados da etiqueta lida
			aEtiqReadN	:= {SB1->B1_COD, nQuant, cLote, cSubLote, dDtValid, dDtProd, nPesoL, nPesoB, ""}

			If nPos > 0 .And. !Empty(aEan128[nPos, 2])
				aEtiqReadN[9] := aEan128[nPos, 2]
			EndIf

			//-- Dados que sera retornados
			AAdd(aRet, SB1->B1_COD)
			AAdd(aRet, nQuant)
			AAdd(aRet, cLote)
			AAdd(aRet, dDtValid)
			AAdd(aRet, "")
			AAdd(aRet, cSubLote)
			AAdd(aRet, )
			AAdd(aRet, )
			AAdd(aRet, )
			AAdd(aRet, )
			AAdd(aRet, )
			AAdd(aRet, )
			AAdd(aRet, )
			AAdd(aRet, )
			AAdd(aRet, )
			AAdd(aRet, )
			AAdd(aRet, )
		EndIf
	EndIf

Return aClone(aRet)


//--
Static Function zArrToTxt(aAuxiliar, lQuebr, cArqGera)
    Local cTextoAux    := ""
    Local nLimite        := 63000 //Forçando o tamanho máximo a 63.000 bytes
    Local nLinha        := 0
    Local nNivel        := 0
    Default aAuxiliar    := {}
    Default lQuebr    := .T.
    Default cArqGera    := ""
     
    //Se tiver linhas para serem processadas
    If Len(aAuxiliar) > 0
        //Percorrendo o Array
        For nLinha := 1 To Len(aAuxiliar)
            fImprArray(aAuxiliar[nLinha], @cTextoAux, nNivel, lQuebr, nLimite, nLinha)
        Next
         
        //Se não tiver em branco, gera o arquivo
        If !Empty(cArqGera)
			conout(cTextoAux)
            MemoWrite(cArqGera, cTextoAux)
        EndIf
    EndIf

Return cTextoAux


/*---------------------------------------------------------------------*
 | Func:  fImprArray                                                   |
 | Autor: Daniel Atilio                                                |
 | Data:  21/08/2015                                                   |
 | Desc:  Função que gera a linha do arquivo (recursivamente)          |
 *---------------------------------------------------------------------*/
Static Function fImprArray(xDadAtu, cTextoAux, nNivel, lQuebr, nLimite, nPosicao)
    Local cEspac := Space(nNivel)
    Local nColuna := 0
     
    //Finaliza o laço
    If Len(cTextoAux) >= nLimite
        Return
    EndIf
     
    //Se o tipo for numérico
    If ValType(xDadAtu) == "N"
        cTextoAux += cEspac+"["+StrZero(nPosicao, 4)+"][Type:N] "+cValToChar(xDadAtu) + Iif(lQuebr, Chr(13)+Chr(10), '')
     
    //Se for Data
    ElseIf ValType(xDadAtu) == "D"
        cTextoAux += cEspac+"["+StrZero(nPosicao, 4)+"][Type:D] "+dToC(xDadAtu) + Iif(lQuebr, Chr(13)+Chr(10), '')
         
    //Se for Array
    ElseIf ValType(xDadAtu) == "A"
        cTextoAux += cEspac+"["+StrZero(nPosicao, 4)+"][Type:A]" + Iif(lQuebr, Chr(13)+Chr(10), '')
        nNivel++
        //Percorrendo o Array
        For nColuna := 1 To Len(xDadAtu)
            fImprArray(xDadAtu[nColuna], @cTextoAux, nNivel, lQuebr, nLimite, nColuna)
        Next
     
    //Se for Lógico
    ElseIf ValType(xDadAtu) == "L"
        cTextoAux += cEspac+"["+StrZero(nPosicao, 4)+"][Type:L] "+cValToChar(xDadAtu) + Iif(lQuebr, Chr(13)+Chr(10), '')
     
    //Senão, apenas mostra o conteúdo (Memo, Char, etc)
    Else
        cTextoAux += cEspac+"["+StrZero(nPosicao, 4)+"][Type:"+ValType(xDadAtu)+"] "+AllTrim(xDadAtu) + Iif(lQuebr, Chr(13)+Chr(10), '')
    EndIf

Return


/*/{Protheus.doc} RetAis
Retorna Ais 
@type function
@version 1.0
@author erike
@since 11/05/2022
@param cId, character, codigo de barras
@return variant, array com ais e conteudo do codigo de barras
/*/
Static Function RetAis(cId)
	local aRet := {}

	If (Upper(left(cId,3)) == "]D2" .Or. Upper(left(cId,3)) == "[D2") .And. At("(", cId) > 0
		aRet := HBar2Ais(cId)
	Else
		aRet := CBAnalisa128(cId)
	Endif

Return aRet


//--
User Function cbean1tst()
	//local cId	:= "]d2(91)MPCS20E067002100(11)220401(10)AUTO000164(21)000161(3101)000123(3301)000124"
	local cId := "[d2(91)515.8.010.007(10)2207080(240)03014(3101)003105"
	local aRet := {} // HBar2Ais(cId)

	If	ExistBlock("CBRETEAN")
		// Retorno devera ser um array conforme abaixo:
		// {codigo do produto,quantidade,lote,data de validade, numero de serie}
		aRet := ExecBlock("CBRETEAN",,,{cID})
	EndIf
	zArrToTxt(aRet, .t., "_Ais.txt")
Return


/*/{Protheus.doc} HBar2Ais
Verifica se existem AI no formato humano
@type function
@version  1.0
@author erike
@since 11/05/2022
@param cId, character, codigo de barras 1d ou 2d
@return variant, Vazio se nao localizar AIs, ou se
/*/
Static Function HBar2Ais(cId)
	Local cAi    := ""
	Local aRet   := {}
	Local aAis   := {}
	Local lErro  := .f.
	Local cAuxB  := ""
	Local cByte  := ""
	Local nI, nX
	Local nPos

	If At("(", cId) == 0
		Return aRet
	Endif

	aAis := MsCbTabEan()

	For nI := 1 To Len(aAis)
		cAi := "(" + aAis[nI,1] + ")"
		nPos := at(cAi, cId)
		If nPos == 0
			loop
		Endif
		cAuxB := ""
		For nX := nPos + len(cAi) To len(cId)
			cByte := SubStr(cId, nX, 1)
			If cByte == "("
				Exit
			Endif
			cAuxB += cByte
		Next nX

		If Empty(cAuxB)
			lErro := .t.
			Exit
		Endif

		aadd(aRet,{aAis[nI, 1], cAuxB, aAis[nI,5]})
	Next nI

	If lErro
		aRet := {}
	Endif

Return aRet
