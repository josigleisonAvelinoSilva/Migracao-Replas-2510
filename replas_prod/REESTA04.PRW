#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TBICONN.CH"

// /*/{Protheus.doc} REESTA04
// Rotina para inclusao de Solicitacao de Tranferencia Replas automaticamente
// @type function
// @version 1.0  
// @author Dener Lemos - DOTHINK
// @since 23/06/2022
// @param aItens, array, Array com os dados
// @param cNumST, character, Numero da ST
// @param cMsg, character, Mensagem do historico
// @return logical, Retorno logico
// /*/
User Function REESTA04(aItens, cNumST, cMsg)
	Local aLog      := {}
	Local cPerg     := "REESTA04"
	Local cMensLog  := ""
	Local cFilOri   := ""
	Local cFilDes   := ""
	Local cArmOri   := ""
	Local cArmDes   := ""
	Local cTSaida   := ""
	Local cTEntra   := ""
	Local nX        := 0
	Local nQtdLGrd  := 1
	Local lREFATA06 := FWIsInCallStack( "U_REFATA06" )
	Local lREESTA18 := FWIsInCallStack( "U_REESTA18" )
	Local lIncluiST := .T.
	Local lRet      := .T.
	Local oModel    := Nil
	Local dDtValid  := ctod("  /  /  ")
	Local aContrSB2 := {}
	Local cKeySB2	:= ""
	Local cCodUsr	:= RetCodUsr()

	Default cNumST   := ""
	Default cMsg     := ""

	If !lREFATA06 .And. !lREESTA18
		lIncluiST := FWAlertYesNo( "Deseja incluir uma <b>Solicitação de Transferencia</b> para os produtos do tipo <b style='color:red;'>Filme</b> ?", "Incluir Solicitação Transferência?" )
		
		If lIncluiST
			Pergunte( cPerg, .T. )
			cFilDes := MV_PAR01
			cTSaida := MV_PAR02
			cTEntra := MV_PAR03
		EndIf
	EndIf

	If lIncluiST
		If lREESTA18
			VTMsg("Incluindo ST...")
		EndIf

		oModel := FWLoadModel( "REESTA01" ) //-- Carrega o modelo
		oModel:SetOperation( MODEL_OPERATION_INSERT ) //-- Seta operacao de inclusao
		oModel:Activate() //-- Ativa o Modelo

		//-- Cabecalho da solicitacao
		oModel:SetValue( "NNSMASTER", "NNS_CLASS", "2" )
		oModel:SetValue( "NNSMASTER", "NNS_ESPECI", " " )
		If lREFATA06
			oModel:SetValue( "NNSMASTER", "NNS_SOLICT", cCodUsr )
			oModel:SetValue( "NNSMASTER", "NNS_XNOMST", UsrFullName( cCodUsr ) )
			oModel:SetValue( "NNSMASTER", "NNS_XOP"   , aREFATA06[01] )
		EndIf

		For nX := 1 To Len( aItens )
			If lREESTA18
				cFilOri := AllTrim(aItens[nX, 07])
				cFilDes := AllTrim(aItens[nX, 08])
				cArmOri := AllTrim(aItens[nX, 09])
				cArmDes := AllTrim(aItens[nX, 10])
				cTSaida := AllTrim(aItens[nX, 11])
				cTEntra := AllTrim(aItens[nX, 12])
			Else
				cFilOri := cFilAnt
				cFilDes := Iif(Empty(aItens[nX, 07]), AllTrim(cFilDes), AllTrim(aItens[nX, 07]))
				cArmOri := AllTrim(aItens[nX, 02])
				cArmDes := AllTrim(aItens[nX, 02])
				cTSaida := Iif(Empty(aItens[nX, 08]), AllTrim(cTSaida), AllTrim(aItens[nX, 08]))
				cTEntra := Iif(Empty(aItens[nX, 09]), AllTrim(cTEntra), AllTrim(aItens[nX, 09]))
			EndIf

		    //-- 07/03/2023
		    //--Grava SB8 com Quant.Original e Saldo Zero para que na Entrada da NF
			//--todos os Saldos sejam incluídos no SB8
		    If lREFATA06 .AND. !Empty( aItens[nX, 04] ) .AND. !Empty( aItens[nX, 05] )
			    //--       Fil.Ori    Produto            Local           Lote          Sub-Lote      Fil.Des
				U_CriaSB8( cFilOri, aItens[nX, 01], cArmOri, aItens[nX, 04], aItens[nX, 05], cFilDes )
			Endif

		    dDtValid := GetAdvFVal("SB8", "B8_DTVALID", xFilial("SB8") + aItens[nX, 01] + cArmOri + aItens[nX, 04] + aItens[nX, 05], 3, CTOD("  /  /  "))

			cKeySB2 := AvKey(cFilOri, "B2_FILIAL") + AvKey(aItens[nX,01], "B2_COD") + AvKey(cArmOri, "B2_LOCAL")
			If aScan(aContrSB2, {|x| x == cKeySB2}) == 0
				SB2->(DbSetOrder(1))
				If !SB2->(DbSeek(cKeySB2))
					CriaSB2(aItens[nX,01], cArmOri, cFilOri)
				EndIf

				aAdd(aContrSB2, cKeySB2)
			EndIf

			cKeySB2 := AvKey(cFilDes, "B2_FILIAL") + AvKey(aItens[nX,01], "B2_COD") + AvKey(cArmDes, "B2_LOCAL")
			If aScan(aContrSB2, {|x| x == cKeySB2}) == 0
				SB2->(DbSetOrder(1))
				If !SB2->(DbSeek(cKeySB2))
					CriaSB2(aItens[nX,01], cArmDes, cFilDes)
				EndIf

				aAdd(aContrSB2, cKeySB2)
			EndIf

			If nX > 1
				nQtdLGrd := oModel:GetModel( "NNTDETAIL" ):AddLine()
			EndIf

			//-- Itens da solicitacao, origem
			oModel:SetValue( "NNTDETAIL", "NNT_FILORI", cFilOri )
			oModel:SetValue( "NNTDETAIL", "NNT_PROD", aItens[nX, 01] )
			oModel:SetValue( "NNTDETAIL", "NNT_LOCAL", cArmOri )
			oModel:SetValue( "NNTDETAIL", "NNT_QUANT", aItens[nX, 03] )
			
			//-- Checa se utiliza rastreabilidade por lote
			If Rastro( aItens[nX, 01], "L" )
				oModel:SetValue( "NNTDETAIL", "NNT_LOTECT", aItens[nX, 04] )
				oModel:SetValue( "NNTDETAIL", "NNT_DTVALI", dDtValid )
			EndIf

			//-- Checa se utiliza rastreabilidade por sub-lote
			If Rastro( aItens[nX, 01], "S" )
				oModel:SetValue( "NNTDETAIL", "NNT_LOTECT", aItens[nX, 04] )
				oModel:SetValue( "NNTDETAIL", "NNT_NUMLOT", aItens[nX, 05] )
				oModel:SetValue( "NNTDETAIL", "NNT_DTVALI",  dDtValid )
			EndIf

			If Rastro( aItens[nX, 01], "N" )
				oModel:SetValue( "NNTDETAIL", "NNT_LOTECT", " " )
				oModel:SetValue( "NNTDETAIL", "NNT_NUMLOT", " " )
				oModel:SetValue( "NNTDETAIL", "NNT_DTVALI", CTOD("  /  /  ") )
			EndIf

			//-- Itens da solicitacao, destino
			oModel:SetValue( "NNTDETAIL", "NNT_FILDES", cFilDes)
			oModel:SetValue( "NNTDETAIL", "NNT_PRODD", aItens[nX, 01] )
			oModel:SetValue( "NNTDETAIL", "NNT_LOCLD", cArmDes )
			oModel:SetValue( "NNTDETAIL", "NNT_TS", cTSaida)
			oModel:SetValue( "NNTDETAIL", "NNT_TE", cTEntra)
		Next nX
	
		//-- Validacao do modelo
		If oModel:VldData()
			//-- Gravacao do Modelo
			oModel:CommitData()
		
			cNumST := oModel:aAllSubModels[01]:aDataModel[01][02][02]
			If !lREFATA06 .And. !lREESTA18
				//-- Mostra uma mensagem de sucesso na operacao de inclusao da solicitacao de transferencia
				FWAlertSuccess( "Solicitação de Transferência <b>" + cNumST + "</b> incluida com sucesso!", "Solicitação Transferência!" )
			EndIf
			cMsg += "#" + DToC(Date()) + " - " + Time() + Chr(13) + Chr(10)
			cMsg += "Sucesso ao incluir Solicit. Transf. Replas [" + cNumST + "]" + Chr(13) + Chr(10) + Chr(13) + Chr(10)
		Else
			aLog     := oModel:GetErrorMessage() //-- Recupera o erro do model quando nao passou no VldData
			cMensLog := ""

			//-- Laco para gravar em string cLog conteudo do array aLog
			For nX := 1 To Len( aLog )
				If !Empty( aLog[nX] )
					cMensLog += Alltrim( aLog[nX] ) + Chr(13) + Chr(10)
				EndIf
			Next nX

			/*lMsErroAuto := .T.  //-- Seta variavel Private como erro
			AutoGRLog( cMensLog ) //-- Grava log para exibir com funcao MostraErro()
			MostraErro()*/

			If !lREFATA06 .And. !lREESTA18
				//-- Mostra uma mensagem de erro na operacao de inclusao da solicitacao de transferencia
				FWAlertError( cMensLog, "Solicitação Transferência!" )
			Else
				ConOut( cMensLog )
			EndIf
			cMsg += "#" + DToC(Date()) + " - " + Time() + Chr(13) + Chr(10)
			cMsg += "Erro ao incluir Solicit. Transf. Replas [" + cNumST + "]" + Chr(13) + Chr(10)
			cMsg += cMensLog + Chr(13) + Chr(10) + Chr(13) + Chr(10)

			lRet := .F.
		EndIf

		oModel:DeActivate() //-- Desativa modelo
	EndIf

Return lRet

 