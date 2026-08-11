#INCLUDE "PROTHEUS.CH"


/*/{Protheus.doc} REPCPA10
Rotina que realiza a transformacao dos produtos retornados
@type function
@version 1.0 
@author DO THINK - DENER LEMOS
@since 01/06/2023
@param cOrdProd, character, Order de Producao
@param cMsg, character, Mensagem
@return logical, Retorno logico
/*/
User Function REPCPA10(cOrdProd, cMsg)
	Local aAreaAnt := GetArea()
	Local aAreaSB1 := SB1->(GetArea())
	Local aAreaSB2 := SB2->(GetArea())
	Local aAreaSZ9 := SZ9->(GetArea())
	Local aLinha   := {}
	Local cDocto   := ""
	Local cFileLog := ""
    Local cMensLog := ""
	Local nQuant   := 0
	Local nQtd2UM  := 0
	Local nCount   := 1
	Local lRet     := .T.

	Private aTransfSZ9  := {}
	Private lMsErroAuto := .F.

	//-- Altera "cFilAnt" para a INDUSTRIA MM
	cFilAnt := cFilDest

	cOrdProd := PadR(cOrdProd, Len(SZ9->Z9_OP))

	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))

	DbSelectArea("SB2")
	SB2->(DbSetOrder(1))

	DbSelectArea("SZ9")
	SZ9->(DbSetOrder(1))

	If SZ9->(DbSeek( xFilial("SZ9") + cOrdProd ) )
		cDocto := CriaVar("D3_DOC")
		If Empty(cDocto)
			cDocto := NextNumero("SD3", 2, "D3_DOC", .T.)
		EndIf

		//-- Cabecalho da tranferencia
		aAdd(aTransfSZ9, {cDocto, dDataBase})

		While SZ9->( !Eof() .And. SZ9->Z9_OP == cOrdProd )
			aLinha  := {}
			nQuant  := SZ9->Z9_QTDDES
			nQtd2UM := ConvUM(SZ9->Z9_PRODORI, nQuant, 0, 2)

			If !SB2->(DbSeek(cFilOrig + SZ9->Z9_PRODORI + SZ9->Z9_LOCORI))
				CriaSB2(SZ9->Z9_PRODORI, SZ9->Z9_LOCORI, cFilOrig)	
			EndIf

			If !SB2->(DbSeek(cFilOrig + SZ9->Z9_PRODDES + SZ9->Z9_LOCDES))
				CriaSB2(SZ9->Z9_PRODDES, SZ9->Z9_LOCDES, cFilOrig)					
			EndIf				

			//-- Origem
			SB1->(DbSeek(xFilial("SB1") + PadR(SZ9->Z9_PRODORI, Len(SD3->D3_COD))))
			aAdd(aLinha, {"ITEM"      , "00" + CValToChar(nCount), Nil})
			aAdd(aLinha, {"D3_COD"    , SZ9->Z9_PRODORI          , Nil}) //-- Cod Produto origem
			aAdd(aLinha, {"D3_DESCRI" , SB1->B1_DESC             , Nil}) //-- Descr produto origem
			aAdd(aLinha, {"D3_UM"     , SB1->B1_UM               , Nil}) //-- Unidade medida origem
			aAdd(aLinha, {"D3_LOCAL"  , SZ9->Z9_LOCORI           , Nil}) //-- Armazem origem
			aAdd(aLinha, {"D3_LOCALIZ", ""                       , Nil})

			//-- Destino
			SB1->(DbSeek(xFilial("SB1") + PadR(SZ9->Z9_PRODDES, Len(SD3->D3_COD))))
			aAdd(aLinha, {"D3_COD"    , SZ9->Z9_PRODDES, Nil}) //-- Cod produto destino
			aAdd(aLinha, {"D3_DESCRI" , SB1->B1_DESC   , Nil}) //-- Descr produto destino
			aAdd(aLinha, {"D3_UM"     , SB1->B1_UM     , Nil}) //-- Unidade medida destino
			aAdd(aLinha, {"D3_LOCAL"  , SZ9->Z9_LOCDES , Nil}) //-- Armazem destino
			aAdd(aLinha, {"D3_LOCALIZ", ""             , Nil})

			aAdd(aLinha, {"D3_NUMSERI", ""             , Nil}) //-- Numero serie
			aAdd(aLinha, {"D3_LOTECTL", SZ9->Z9_LOTORI , Nil}) //-- Lote origem
			aAdd(aLinha, {"D3_NUMLOTE", SZ9->Z9_SBLTORI, Nil}) //-- Sub-Lote origem
			aAdd(aLinha, {"D3_DTVALID", CToD("")       , Nil}) //-- Data validade origem
			aAdd(aLinha, {"D3_POTENCI", 0              , Nil}) //-- Potencia
			aAdd(aLinha, {"D3_QUANT"  , nQuant         , Nil}) //-- Quantidade
			aAdd(aLinha, {"D3_QTSEGUM", nQtd2UM        , Nil}) //-- Seg unidade medida
			aAdd(aLinha, {"D3_ESTORNO", ""             , Nil}) //-- Estorno
			aAdd(aLinha, {"D3_NUMSEQ" , ""             , Nil}) //-- Numero sequencia D3_NUMSEQ

			aAdd(aLinha, {"D3_LOTECTL", SZ9->Z9_LOTDES , Nil}) //-- Lote destino
			aAdd(aLinha, {"D3_NUMLOTE", SZ9->Z9_SBLTDES, Nil}) //-- Sublote destino
			aAdd(aLinha, {"D3_DTVALID", CToD("")       , Nil}) //-- Validade lote destino
			aAdd(aLinha, {"D3_ITEMGRD", ""             , Nil}) //-- Item Grade

			aAdd(aLinha, {"D3_CODLAN", "", Nil}) //-- cat83 prod origem
			aAdd(aLinha, {"D3_CODLAN", "", Nil}) //-- cat83 prod destino

			aAdd(aTransfSZ9, aLinha)
			nCount++

			SZ9->( DbSkip() )
		EndDo

		//-- Altera "cFilAnt" para a REPLAS
		cFilAnt := cFilOrig

		MSExecAuto({|x,y| MATA261(x,y)}, aTransfSZ9, 3)

		If lMsErroAuto
			cFileLog := NomeAutoLog()
			cMensLog := MemoRead( cFileLog )
			If !Empty( cMensLog )
				ConOut( cMensLog )
			Endif
			cMsg := "#" + DToC(Date()) + " - " + Time() + Chr(13) + Chr(10)
			cMsg += "Erro ao transformar produtos retornados/sucateados" + Chr(13) + Chr(10)
			cMsg += cMensLog + Chr(13) + Chr(10) + Chr(13) + Chr(10)

			lRet := .F.
		Else
			cMsg := "#" + DToC(Date()) + " - " + Time() + Chr(13) + Chr(10)
			cMsg += "Sucesso ao transformar produtos retornados/sucateados" + Chr(13) + Chr(10) + Chr(13) + Chr(10)
		EndIf
	EndIf

	RestArea(aAreaSZ9)
	RestArea(aAreaSB2)
	RestArea(aAreaSB1)
	RestArea(aAreaAnt)

Return lRet
