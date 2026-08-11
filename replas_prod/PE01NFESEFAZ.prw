#include 'protheus.ch'
#include 'parmtype.ch'

user function PE01NFESEFAZ()
	Local aNota 	:= paramixb[5]
	Local cMensCli	:= paramixb[2]
	Local cMensRet  := ""
	Local aArea		:= GetArea()
	Local cTfrdp1	:= ""
	Local nI		:= 0
	Local aSubLote	:= {}
	Local aProd		:= {}

	//(TSM - David 09/10/2017) //Verifica a mensagem de cliente e redespacho
	SF2->(DbSetOrder(1))
	If 	SF2->(DbSeek(xFilial("SF2")+aNota[2]+aNota[1])) 
		
		If !Alltrim(SF2->F2_MENNOTA) $ cMensCli
			cMensRet += " "+Alltrim(SF2->F2_MENNOTA)
		EndIf
		
		If !Empty(SF2->F2_REDESP)
			cMensRet += " Redespacho: "+Alltrim(Posicione("SA4",1,xFilial("SA4")+SF2->F2_REDESP, "A4_NOME"))
			//(TSM - Leandro Dentello 08/03/2018) //Verifica e imprime o Tipo de Frete do redespacho
			If !Empty(SF2->F2_TFRDP1)
			    If SF2->F2_TFRDP1 = 'C'
			    	cTfrdp1 := " Frete Redesp.: CIF"
			    ElseIf SF2->F2_TFRDP1 = 'F' 
	 		    	cTfrdp1 := " Frete Redesp.: FOB"
	 		    EndIf	
				cMensRet += cTfrdp1
			EndIf
			//(TSM - David 21/06/2018) //Imprime endereço transportadora redespacho
			cMensRet += " End. Redesp.: "+Alltrim(SA4->A4_END)+"-"+Alltrim(SA4->A4_MUN)+"-"+Alltrim(SA4->A4_BAIRRO)
		EndIf
		
	EndIf
	
	If !Empty(cMensRet)
		paramixb[2] += cMensRet
	EndIf

	//adiciona na tag com informações do sublote
	If aNota[4] == "1" // Somente para nota de saída
		SA1->(DbSetOrder(1))
		If SA1->(DbSeek(xFilial()+SF2->F2_CLIENTE+SF2->F2_LOJA))
			If SA1->A1_XSUBL == "S"
				If xFilial("SF2") == Alltrim(GETMV("RE_FILORIG"))
					aProd := PARAMIXB[1]
					paramixb[20] := {}
					For nI := 1 to Len(aProd)
						//aSubLote := GetSLote(strzero(aProd[nI][1],2),aNota[1],aNota[2],aProd[nI][38],aProd[nI][39],@paramixb[20])
						aSubLote := GetSLote(strzero(aProd[nI][1],2),aNota[1],aNota[2],aProd[nI][38],aProd[nI][39])
						aAdd(paramixb[20], aSubLote)
					Next
				EndIf
			EndIf	
		EndIf	
	EndIf	
	RestArea(aArea)

return(paramixb)

/*/{Protheus.doc} GetLote
Preenche o sublote 
@type function
@author Fernando B.Muta
@since 25/01/2026
@param cItem, character, Item da Nota
@param cSerie, character, Serie da Nota
@param cDoc, character, Documento
@param cPedido, character, Pedido
@param cItemPV, character, Item do Pedido
@return variant, Descricao
/*///para nota fiscais de venda
Static Function GetSLote(cItem,cSerie,cDoc,cPedido,cItemPV)
	Local aArea		:= GetArea()
	Local aRet		:= {}
	Local cQuery	:= ""
	
	cQuery := " SELECT "
	cQuery += " ZH.ZH_LOTECTL, "
	cQuery += " ZH.ZH_NUMLOTE, "
	cQuery += " ZH.ZH_QTDORI, "
	cQuery += " ZH.ZH_FABLOT, "
	cQuery += " ZH.ZH_VLDLOTE "
	cQuery += " FROM "+RetSqlName("SD2")+" SD2 "
	cQuery += " INNER JOIN "+RetSqlName("SA1")+" SA1 "
	cQuery += " ON SA1.A1_FILIAL IN ('"+xFilial("SA1")+"','  ') "
	cQuery += " AND SA1.A1_COD = SD2.D2_CLIENTE "
	cQuery += " AND SA1.A1_LOJA = SD2.D2_LOJA "
	cQuery += " AND SA1.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN "+RetSqlName("SC5")+" SC5 "
	cQuery += " ON SC5.C5_FILIAL = SD2.D2_FILIAL "
	cQuery += " AND SC5.C5_NUM = SD2.D2_PEDIDO "
	cQuery += " AND SC5.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN "+RetSqlName("SZG")+" SZG "
	cQuery += " ON SZG.ZG_FILIAL = SD2.D2_FILIAL "
	cQuery += " AND SZG.ZG_PEDIDO = SD2.D2_PEDIDO "
	cQuery += " AND SZG.ZG_ITEMPV = SD2.D2_ITEMPV "
	cQuery += " AND SZG.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN "+RetSqlName("SZH")+" ZH "
	cQuery += " ON ZH.ZH_FILIAL = SZG.ZG_FILIAL "
	cQuery += " AND ZH.ZH_VOLUME = SZG.ZG_VOLUME "
	cQuery += " AND ZH.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE SD2.D2_FILIAL = '"+xFilial("SD2")+"' "
	cQuery += " AND SD2.D2_DOC = '"+ALLTRIM(cDoc)+"' "
	cQuery += " AND SD2.D2_SERIE = '"+ALLTRIM(cSerie)+"' "
	cQuery += " AND SD2.D2_PEDIDO = '"+cPedido+"' "
	cQuery += " AND SD2.D2_ITEMPV = '"+cItemPV+"' "
	cQuery += " AND SA1.A1_XSUBL = 'S' "
	cQuery += " AND SD2.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY SD2.D2_ITEM "

	If Select("TMPSLOT") > 0
		TMPSLOT->(DbCloseArea())
	EndIF

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TMPSLOT", .F., .T.)

	TMPSLOT->(DbGotop())
	While !TMPSLOT->(Eof())
		aadd(aRet,   {TMPSLOT->ZH_LOTECTL,TMPSLOT->ZH_QTDORI,STOD(TMPSLOT->ZH_FABLOT),STOD(TMPSLOT->ZH_VLDLOTE),TMPSLOT->ZH_NUMLOTE, "CUSTOM"})
		TMPSLOT->(DbSkip())
	EndDo

	TMPSLOT->(DbCloseArea())

	RestArea(aArea)

Return aRet

 