#Include "Protheus.ch"
#Include "TbiConn.ch"
#Include "FwCommand.ch"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} MTA410
(long_description) Estorno de Liberação do PV por Item.
@type Validação de toda a tela no Pedido de Venda (Preenchimento do 
Controle de Reservas atraves da Rotina Automatica). 
A430Reserv(aOperacao,cNumero,cProduto,cLocal,nQuant,aLote)
@author Eduardo Augusto
@since 18/09/2017
@version 1.0
@return ${return}, ${return_description} lRet
@example
(examples)
@see (links_or_references)
/*/
//-------------------------------------------------------------------

User Function MTA410()

Local aArea		:= GetArea()
//Local cCodUser	:= RetCodUsr() // Retorna o Codigo do Usuario
//Local cNamUser	:= UsrRetName( cCodUser )	// Retorna o Nome do Usuario
Local cCodFil	:= FWCodFil()	// Retorna o Código da Filial (M0_CODFIL)
Local cXTesNRe	:= GetMv("MV_XTESNRE")	// Parametro para nao considerar a TES que estiver informada
Local cXGrpRep	:= GetMv("MV_XGRPREP")	// Parametro para nao considerar estes clientes para efeito de Reserva de Produto (Controle de Reservas)
//Local nItem		:= aScan(aHeader,{|x| AllTrim(x[02]) == "C6_ITEM"})
Local nProd		:= aScan(aHeader,{|x| AllTrim(x[02]) == "C6_PRODUTO"})
Local nLoc		:= aScan(aHeader,{|x| AllTrim(x[02]) == "C6_LOCAL"})
Local nQtde		:= aScan(aHeader,{|x| AllTrim(x[02]) == "C6_QTDVEN"})
//Local nQtdeLib	:= aScan(aHeader,{|x| AllTrim(x[02]) == "C6_QTDLIB"})
//Local nQtdeEmp	:= aScan(aHeader,{|x| AllTrim(x[02]) == "C6_QTDEMP"})
//Local nQtdeEnt	:= aScan(aHeader,{|x| AllTrim(x[02]) == "C6_QTDENT"})
Local nTes		:= aScan(aHeader,{|x| AllTrim(x[02]) == "C6_TES"})
//Local nResr		:= aScan(aHeader,{|x| AllTrim(x[02]) == "C6_RESERVA"})
Local nResrX	:= aScan(aHeader,{|x| AllTrim(x[02]) == "C6_XRESERV"})
//Local nLote		:= aScan(aHeader,{|x| AllTrim(x[02]) == "C6_LOTECTL"})
Local nCli		:= aScan(aHeader,{|x| AllTrim(x[02]) == "C6_CLI"})
Local nCf		:= aScan(aHeader,{|x| AllTrim(x[02]) == "C6_CF"})
//Local nResQtd   := aScan(aHeader,{|x| AllTrim(x[02]) == "C6_QTDRESE"})
Local nBloqC6   := aScan(aHeader,{|x| AllTrim(x[02]) == "C6_BLOQUEI"})
Local nItemNF   := aScan(aHeader,{|x| AllTrim(x[02]) == "C6_NOTA"})
//Local nQtdisp	:= 0
//Local nQtdLib	:= 0
Local lRet		:= .T.
Local cEstCliVen	:= ""
Local lForaEst	:= .F.
//Local nQtdRes	:= 0
Local i			:= 0
Local lSeekC5	:= .T.
Local lIncAnt	:= .F.
Local lAltAnt	:= .F.
Local cUser		:= RetCodUsr()
Local aGrpUsr	:= UsrRetGrp(cUser)
Local cGrpBlq	:= GetNewPar("MV_XGRPALT","000001")
Local nPosGrp	:= 0
Local cFilBlq	:= GetNewPar("MV_XFILBLQ","0101")
Local cFilResev := GetMv( "RE_FILRSV", .F., "0101/0102/0103/0302/" ) //-- Filiais que teram a inclusao de Reservas. by Dener Lemos
Local lIntIndMM := GetMV( "RE_INTIND", .F., .T. ) //-- Parametro geral que indica se a integracao de pedidos com a industria mm (Filial 0201) esta ativa

//-- Verifica se existe FILME/BOPP no pedido de venda
If ( lIntIndMM .And. U_REFATA02( 2, M->C5_NUM ) ) .Or.;
   ( lIntIndMM .And. IsInCallStack("U_REESTA02") ) .Or.;
   ( lIntIndMM .And. IsInCallStack("U_REFATA01") ) .Or.;
   ( lIntIndMM .And. IsInCallStack("U_REFATA05") )
	
	Return lRet
EndIf

nPosGrp := Ascan(aGrpUsr, {|x| Alltrim(x) == Alltrim(cGrpBlq) })

If Type("__cInternet") == "U" .OR. (__cInternet <> "AUTOMATICO")
	If RTrim( ReadVar() ) == 'M->C6_LOCAL'
		aCOLS[ n, nLoc ] := M->C6_LOCAL
	Endif
Endif

// Refaz validação de Estoque para confirmar disponibilidade e desbloqueio
If !IsinCallStack("U_XRLSMOTOR")
	For i := 1 to Len(aCols)
		If !aCols[i][Len(aHeader) + 1]
			If Altera .and. nBloqC6 > 0
				aCols[i,nBloqC6] := ""
			EndIf
			n := i
			If !u_xValdEst("1")
				lRet := .F.
				Exit
			EndIf
		EndIf
	Next
	//Verifica se grupo de vendas pode alterar o pedido em carga ou filila esta bloqueada para inclusão de vendas
	If lRet .and. nPosGrp > 0  
		If cCodFil $ cFilBlq
			MsgStop("Pedidos não podem manipulados pela Filial corrente! Por favor, utilize Filial correta.")
			lRet := .F.
		EndIf
	Endif
	
	If lRet .and. Altera .and. OmsHasCg(SC5->C5_NUM) 
		Help(" ",1,"A410CARGA")
		lRet := .F.
	EndIf
EndIf

If lRet .And. !IsInCallStack("U_REESTA02")
	//(10/10/2017) Tratamento especifico para CFOP de acordo com cliente de venda e não cliente de entrega
	If !IsinCallStack("U_XRLSMOTOR") .And. (Inclui .Or. Altera) .And. cCodFil $ cFilResev .And. nCf > 0 .And. M->(C5_CLIENTE + C5_LOJACLI) <> M->(C5_CLIENT + C5_LOJAENT)
		cEstCliVen := GetAdvFVal("SA1","A1_EST",xFilial("SA1") + M->(C5_CLIENTE + C5_LOJACLI),1)
		lForaEst 	:= cEstCliVen <> SM0->M0_ESTCOB
		For i := 1 to Len(aCols)
			If !aCols[i][Len(aHeader) + 1]
				If SubStr(aCols[i,nCf],1,1) == "6" .And. !lForaEst
					aCols[i,nCf] := "5" + SubStr(aCols[i,nCf],2) 
				ElseIf SubStr(aCols[i,nCf],1,1) == "5" .And. lForaEst
					aCols[i,nCf] := "6" + SubStr(aCols[i,nCf],2) 
				EndIf
			EndIf
		Next
	EndIf
	// Inclusão
	If !IsinCallStack("U_XRLSMOTOR")  .And. cCodFil $ cFilResev .and. (Inclui .or. Altera)
		aColsAnt   := aClone(Acols)
		aHeaderAnt := aClone(aHeader)
		lIncAnt	   := Inclui
		lAltAnt    := Altera	
		SC0->(DbSetOrder(1))
		lSeekC5 	:= SC0->(DbSeek(xFilial("SC0")+M->C5_NUM))
		oModel430 	:= FWLoadModel("MATA430")
		If Inclui
			SC5->(ConfirmSx8())
		EndIf
		If Inclui .OR. !lSeekC5  
			oModel430:SetOperation( MODEL_OPERATION_INSERT ) //Inclusao
			oModel430:Activate()
			
			oModelMaster:= oModel430:GetModel("MASTER")
			oModelGrid	:= oModel430:GetModel("SC0GRID")
			
			oModelMaster:SetValue("C0_NUM"		, M->C5_NUM )
			oModelMaster:SetValue("C0_TIPO"		, "PD" )
			oModelMaster:SetValue("C0_DOCRES"	, M->C5_NUM )
		ElseIf Altera
			
			If lSeekC5
				
				oModel430:SetOperation( MODEL_OPERATION_UPDATE ) //Alteração
				oModel430:Activate()
				
				oModelMaster:= oModel430:GetModel("MASTER")
				oModelGrid	:= oModel430:GetModel("SC0GRID")
				nQtdx := oModelGrid:Length()
				
			EndIf

		EndIf
	
		lTemItem := .F.
		// For para inclusao dos itens do Pedido de Venda no Controle de Reservas
		For i := 1 to Len(aCols)
			cTes	:= Posicione("SF4", 1, xFilial("SF4") + aCols[i,nTes], "F4_ESTOQUE")
			cGrupo	:= Posicione("SB1", 1, xFilial("SB1") + aCols[i,nProd], "B1_XGRUPO")
			
			If  cTes == "S" .And. cGrupo $ "2/3" .And. !(aCols[i,nTes] $ cXTesNRe) .And. !(aCols[i,nCli] $ cXGrpRep) .and. Empty(aCols[i,nItemNF])
				If Altera 
					lTemItem := .T.
					If oModelGrid:SeekLine({{"C0_PRODUTO",Alltrim(aCols[i,nProd]) } } ) 
						If aCols[i][Len(aHeader) + 1]
							oModelGrid:DeleteLine()
						Else
							oModelGrid:SetValue("C0_QUANT", aCols[i,nQtde] )
						EndIf
					Else
						oModelGrid:AddLine()
						oModelGrid:SetValue("C0_PRODUTO", aCols[i,nProd] )
						oModelGrid:SetValue("C0_LOCAL", aCols[i,nLoc] )
						oModelGrid:SetValue("C0_QUANT", aCols[i,nQtde] )

					Endif
				ElseIf Inclui
					lTemItem := .T.
					oModelGrid:AddLine()
					oModelGrid:SetValue("C0_PRODUTO", aCols[i,nProd] )
					oModelGrid:SetValue("C0_LOCAL", aCols[i,nLoc] )
					oModelGrid:SetValue("C0_QUANT", aCols[i,nQtde] )
				Endif
			EndIf
		Next
		
		If lTemItem
			If oModel430:VldData()
			   	oModel430:CommitData()
			Else
				lRet := .F.
			    cLog := cValToChar(oModel430:GetErrorMessage()[4]) + ' - '
			    cLog += cValToChar(oModel430:GetErrorMessage()[5]) + ' - '
			    cLog += cValToChar(oModel430:GetErrorMessage()[6])        	      
			    Help( ,,"M430VALID",,cLog, 1, 0 )
			Endif
		EndIf
		oModel430:DeActivate()
		aCols := aClone(aColsAnt)
		aHeader := aClone(aHeaderAnt)
		Inclui  := lIncAnt 
		Altera  := lAltAnt
		 
		If lTemItem .and. lRet
			For i := 1 to Len(aCols)
				If !aCols[i][Len(aHeader) + 1] .and. nResrX > 0
					aCols[i,nResrX] := M->C5_NUM
				EndIf
			Next
		Endif
	EndIf
EndIf

RestArea(aArea)
Return lRet
