#Include "Protheus.ch"
#Include "Font.ch"
#Include "Colors.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} REPLAA02
Tela de Alteração dos Dados Bancários no Pedido de Venda

@author TOTVS Serra do Mar [JOSE CARLOS]
@since 27/06/2016
@version P12
/*/
//-------------------------------------------------------------------

User Function REPLAA02()
Local cPerg		:= PadR('REPLAA02',10)
Local nOpcA		:= 0
Private cCadastro 	:= "Dados bancários de cobrança"
Private aSay 		:= {}
Private aButton 	:= {}
Private oProcess  	:= Nil
Private cMarca   	:= GetMark()
Private lInverte 	
//---> REMOVIDO compatibilização para versão 12.1.25.
//CriaSX1(cPerg)
Pergunte(cPerg,.F.)
aAdd( aSay, "Rotina de alteração dos dados bancários no Pedido de Venda" ) 
aAdd( aButton, { 5,.T.,{|| Pergunte(cPerg,.T.)}})
aAdd( aButton, { 1,.T.,{|| nOpca := 1 ,FechaBatch()}})
aAdd( aButton, { 2,.T.,{|| FechaBatch() }} )
FormBatch( cCadastro, aSay, aButton )
If nOpcA == 1 
	MsgRun( "Processando","Selecionando registros.", {|| Rep02Processa() } )
EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Rep02Processa
Função inicio de Processamento

@author TOTVS Serra do Mar [JOSE CARLOS]
@since 27/06/2016
@version P12
/*/
//-------------------------------------------------------------------

Static Function Rep02Processa() 
Local oFnt		:= Nil
Local aSize 		:= MsAdvSize()
Local oDlg1		:= Nil
Local aStru		:= {} 
Local cFileWork	:= ""
Local cQuery		:= ""
Local cAliasQry	:= GetNextAlias()
Local nHeight		:= 0
Local nWidth		:= 0
Local aCoors 		:= {}
Local nValor		:= 0
Local oValor		:= Nil
Local nQtdTit		:= 0
Local oQtda		:= Nil
Local oMark		:= Nil
Local aCampos		:= {}
Local oPanel		:= Nil
Local nOpca		:= 0
Define Font oFnt Name "Arial" Size 12,14 Bold
aAdd(aStru,{"C5_OK"		,"C",2,0})
aAdd(aStru,{"C5_FILIAL"	,"C",TamSx3('C5_FILIAL')[1],0})
aAdd(aStru,{"C5_NUM"		,"C",TamSx3('C5_NUM')[1],0})
aAdd(aStru,{"C5_CLIENTE"	,"C",TamSx3('C5_CLIENTE')[1],0})
aAdd(aStru,{"C5_LOJACLI"	,"C",TamSx3('C5_LOJACLI')[1],0})
aAdd(aStru,{"A1_NOME"		,"C",TamSx3('A1_NOME')[1],0})
aAdd(aStru,{"C5_BANCO"		,"C",TamSx3('C5_BANCO')[1],0})
aAdd(aStru,{"C5_XAGENCI"	,"C",TamSx3('C5_XAGENCI')[1],0})
aAdd(aStru,{"C5_XDVAGE"	,"C",TamSx3('C5_XDVAGE')[1],0})
aAdd(aStru,{"C5_XNUMCON"	,"C",TamSx3('C5_XNUMCON')[1],0})
aAdd(aStru,{"C5_XDVCTA"	,"C",TamSx3('C5_XDVCTA')[1],0})
aAdd(aStru,{"C5_VALOR"		,"N",14,2})
aAdd(aStru,{"C5_CONDPAG"	,"C",15,0})
aAdd(aStru,{"C5_FECENT"	,"D",TamSx3('C5_FECENT')[1],0})
aAdd( aCampos, { "C5_OK" 		, "", " [X]"			, "" } )	
aAdd( aCampos, { "C5_FILIAL"	, "", "Filial"		, "" } )
aAdd( aCampos, { "C5_NUM" 		, "", "Num.Ped."		, "" } )
aAdd( aCampos, { "C5_CLIENTE" 	, "", "Cod.Cliente"	, "" } )
aAdd( aCampos, { "C5_LOJACLI" 	, "", "Loja"			, "" } )
aAdd( aCampos, { "A1_NOME" 		, "", "Nome"			, "" } )
aAdd( aCampos, { "C5_BANCO" 	, "", "Banco"			, "" } )
aAdd( aCampos, { "C5_XAGENCI" 	, "", "Agencia"		, "" } )
aAdd( aCampos, { "C5_XDVAGE" 	, "", "DV Ag."		, "" } )
aAdd( aCampos, { "C5_XNUMCON" 	, "", "Nr.Conta"		, "" } )
aAdd( aCampos, { "C5_XDVCTA" 	, "", "DV Conta"		, "" } )
aAdd( aCampos, { "C5_VALOR" 	, "", "Total Ped."	, "@E 999,999,999.99" } )
aAdd( aCampos, { "C5_CONDPAG" 	, "", "Cond. Pagto"		, "" } )
aAdd( aCampos, { "C5_FECENT" 	, "", "Dt. Entrega"		, "" } )
//cFileWork := CriaTrab(aStru,.T.)
// Certifico de que o TRB esta fechado.
If (Select("TRB") <> 0)     
	DbSelectArea("TRB")
	DbCloseArea()
EndIf

// MIGRACAO BD - NOVA ESTRUTURA DE TABELA TEMPORÁRIA
_cArq      := "TRB"
_cChaveInd := GETNEXTALIAS()
oTable := FwTemporaryTable():New( _cArq)
oTable:SetFields(aStru)
//oTable:AddIndex(_cChaveInd, {"C5_FILIAL","DtoS(C5_FECENT)"}) 
oTable:AddIndex(_cChaveInd, {"C5_FILIAL","C5_FECENT"}) 
oTable:Create()
DbSelectArea(_cArq)

//Use &cFileWork Alias TRB Exclusive New
//IndRegua("TRB",cFileWork,"C5_FILIAL + DtoS(C5_FECENT)",,,OemToAnsi("Selecionando Registros..."))  

// Query da Tabela SC5
cQuery := " SELECT C5_FILIAL, C5_NUM, C5_CLIENTE, C5_LOJACLI, C5_BANCO, C5_XAGENCI, C5_XDVAGE, C5_XNUMCON, C5_XDVCTA, A1_NOME, C5_CONDPAG, C5_FECENT "
cQuery += " FROM " + RetSqlName('SC5') + " SC5," + RetSqlName('SA1') +" SA1 " 
cQuery += " WHERE C5_FILIAL = '" + xFilial('SC5') + "' "
cQuery += " 	AND C5_NUM BETWEEN '" + Mv_Par06 + "' AND '" + Mv_Par07 + "' "
If Empty(Mv_Par19) .Or. Empty(Mv_Par20)
	cQuery += " 	AND C5_EMISSAO BETWEEN '" + DtoS(Mv_Par08) + "' AND '" + DtoS(Mv_Par09) + "' "
EndIf
cQuery += " 	AND C5_CLIENTE BETWEEN '" + Mv_Par10 + "' AND '" + Mv_Par12 + "' "
cQuery += " 	AND C5_LOJACLI BETWEEN '" + Mv_Par11 + "' AND '" + Mv_Par13 + "' "
cQuery += "     AND C5_BANCO   = '"+Mv_Par14+"'  "
cQuery += "     AND C5_XAGENCI = '"+Mv_Par15+"'  "
cQuery += "     AND C5_XDVAGE   = '"+Mv_Par16+"'  "
cQuery += "     AND C5_XNUMCON   = '"+Mv_Par17+"'  "
cQuery += "     AND C5_XDVCTA   = '"+Mv_Par18+"'  "
cQuery += "     AND C5_FECENT BETWEEN '"+DtoS(Mv_Par19)+"' AND '"+DtoS(Mv_Par20)+"' "
cQuery += " 	AND A1_FILIAL = '" + xFilial('SA1') + "' AND A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI "
cQuery += " 	AND C5_CONDPAG <> '001' "
cQuery += " 	AND C5_NOTA = '' "
cQuery += " 	AND SA1.D_E_L_E_T_ <> '*' "
cQuery += " 	AND SC5.D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY C5_FECENT "
cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)
While (cAliasQry)->(!Eof())
	DbSelectArea("TRB")
	RecLock("TRB",.T.)
	TRB->C5_FILIAL	:= (cAliasQry)->C5_FILIAL
	TRB->C5_NUM		:= (cAliasQry)->C5_NUM
	TRB->C5_CLIENTE	:= (cAliasQry)->C5_CLIENTE
	TRB->C5_LOJACLI	:= (cAliasQry)->C5_LOJACLI
	TRB->A1_NOME		:= (cAliasQry)->A1_NOME
	TRB->C5_BANCO		:= (cAliasQry)->C5_BANCO
	TRB->C5_XAGENCI	:= (cAliasQry)->C5_XAGENCI
	TRB->C5_XDVAGE	:= (cAliasQry)->C5_XDVAGE
	TRB->C5_XNUMCON	:= (cAliasQry)->C5_XNUMCON
	TRB->C5_XDVCTA	:= (cAliasQry)->C5_XDVCTA
	TRB->C5_VALOR		:= CalcIPI((cAliasQry)->C5_FILIAL,(cAliasQry)->C5_NUM)
	TRB->C5_CONDPAG	:= Posicione("SE4", 1, xFilial("SE4") + (cAliasQry)->C5_CONDPAG, "E4_DESCRI")
	TRB->C5_FECENT	:= StoD((cAliasQry)->C5_FECENT)
	MsUnLock()
	(cAliasQry)->(DbSkip())
EndDo 
DbSelectArea("TRB")
DbGotop()
If Bof() .And. Eof()
	Help(" ",1,"RECNO")
	Return()
EndIf 
// Montagem da Tela
Define MsDialog oDlg1 Title OemToAnsi("Pedido de Venda") From aSize[7],0 To aSize[6],aSize[5] Of oMainWnd Pixel	
oDlg1:lMaximized := .T.
oPanel := TPanel():New(0,0,'',oDlg1,, .T., .T.,, ,315,20,.T.,.T. )
oPanel:Align := CONTROL_ALIGN_TOP // Somente Interface MDI
@ 0.8,.8 Say OemToAnsi('Valor Total:') Of oPanel  // "Valor Total:"
@ 0.8, 7 Say oValor Var nValor Picture "@E 99,999,999.99" Size 60,8 Of oPanel
@ 0.8,21 Say OemToAnsi("Quantidade:") Of oPanel // "Quantidade:"
@ 0.8,28 Say oQtda Var nQtdTit Picture "@E 99999" Size 50,8 Of oPanel
If FlatMode()   
	aCoors 	:= GetScreenRes()
	nHeight	:= aCoors[2]
	nWidth	:= aCoors[1]
Else
	nHeight	:= 143
	nWidth	:= 315
EndIf
// Mark Browse	
oMark := MsSelect():New("TRB","C5_OK","",aCampos,@lInverte,@cMarca,{35,1,nHeight,nWidth})
oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT // Somente Interface MDI
oMark:bMark := {|| Ra02disp(cMarca,lInverte,oValor,oQtda,@nQtdTit,@nValor)}
oMark:oBrowse:lhasMark = .T.
oMark:oBrowse:lCanAllmark := .T.
oMark:bAval := {|| Ra02Inverte(cMarca,oValor,oQtda,@nQtdTit,@nValor,.F.),oMark:oBrowse:Refresh(.T.)}
oMark:oBrowse:bAllMark := {|| Ra02Inverte(cMarca,oValor,oQtda,@nQtdTit,@nValor,.T.) }
// Mark Browse
Activate MsDialog oDlg1 On Init EnchoiceBar(oDlg1,	{|| nOpca := 1,oDlg1:End()}, {|| nOpca := 2,oDlg1:End()},,{})
If nOpca == 1
	DbSelectArea("SC5")
	DbSetOrder(1)	// C5_FILIAL + C5_NUM
	DbSelectArea('TRB')
	TRB->(DbGoTop())
	While TRB->(!Eof())
		If TRB->C5_OK == cMarca .And. !Empty(Mv_Par01)
			If SC5->(DbSeek(TRB->C5_FILIAL + TRB->C5_NUM))
				RecLock("SC5",.F.)
				SC5->C5_BANCO 	:= Mv_Par01
				SC5->C5_XAGENCI	:= Mv_par02
				SC5->C5_XDVAGE	:= Mv_Par03
				SC5->C5_XNUMCON	:= Mv_Par04
				SC5->C5_XDVCTA	:= Mv_Par05
				MsUnLock()
			EndIf
		EndIf
		TRB->(DbSkip())
	EndDo
EndIf
DbSelectArea("TRB")
DbCloseArea()
Ferase(cFileWork + GetDBExtension())
Ferase(cFileWork + OrdBagExt())
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Ra02disp
Display Marque browse

@author TOTVS Serra do Mar [JOSE CARLOS]
@since 27/06/2016
@version P12
/*/
//-------------------------------------------------------------------

Static Function Ra02disp(cMarca,lInverte,oValor,oQtda,nQtdTit,nValor)
If IsMark("C5_OK",cMarca,lInverte)
	nValor += TRB->C5_VALOR
	nQtdTit++
Else
	nValor -= TRB->C5_VALOR
	nValor := Iif(nValor < 0, 0, nValor)
	nQtdTit--
	nQtdTit:= Iif(nQtdTit < 0, 0, nQtdTit)
Endif
oValor:Refresh()
oQtda:Refresh()
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Ra02Inverte
Inverte Marcação

@author TOTVS Serra do Mar [JOSE CARLOS]
@since 27/06/2016
@version P12
/*/
//-------------------------------------------------------------------
Static Function Ra02Inverte(cMarca,oValor,oQtda,nQtdTit,nValor,lTodos)
Local nReg		:= TRB->(Recno())
Local lMarcado	:= Nil
If lTodos
	DbSelectArea('TRB')
	TRB->(DbGoTop())
EndIf
While !lTodos .Or. TRB->(!Eof())
	RecLock("TRB", .F.)
	(lMarcado := IsMark("C5_OK", cMarca, lInverte))
	If lMarcado .Or. lInverte
		TRB->C5_OK := Space(2)
		nValor -= TRB->C5_VALOR
		nValor := Iif(nValor < 0,0,nValor)
		nQtdTit--
		nQtdTit:= Iif(nQtdTit < 0,0,nQtdTit)		
	Else
		TRB->C5_OK := cMarca
		nValor += TRB->C5_VALOR
		nQtdTit++				
	EndIf
	MsUnlock()
	If lTodos
		TRB->(DbSkip())
	Else
		Exit	
	EndIf	
EndDo
TRB->(DbGoTo(nReg))
oValor:Refresh()
oQtda:Refresh()
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CalcIPI
Calcula valor da mercadoria com o valor do IPI

@author TOTVS Serra do Mar [JOSE CARLOS]
@since 27/06/2016
@version P12
/*/
//-------------------------------------------------------------------

Static Function CalcIPI(cFilPed,cNumPed)
Local aAreaAtu	:= GetArea()
Local nTotal		:= 0
Local nVlrMerc	:= 0
//Local nVlrIPI		:= 0
Local nAliqIPI	:= 0
SB1->(DbSelectArea("SB1"))
SB1->(DbSetOrder(1))	// B1_FILIAL + B1_COD
SC6->(DbSelectArea("SC6"))
SC6->(DbSetOrder(1))	// C6_FILIAL + C6_NUM + C6_ITEM + C6_PRODUTO
If SC6->(DbSeek(cFilPed + cNumPed))
	While SC6->(!Eof()) .And. SC6->C6_FILIAL == cFilPed .And. SC6->C6_NUM == cNumPed
		nVlrMerc	:= SC6->C6_VALOR
		If SB1->(DbSeek(xFilial("SB1") + SC6->C6_PRODUTO))
			nAliqIPI := SB1->B1_IPI
		EndIf
		If SF4->(DbSeek(xFilial('SF4') + SC6->C6_TES))
			If SF4->F4_IPI == 'S'
				nTotal +=  nVlrMerc + ((nVlrMerc * nAliqIPI ) / 100)
			Else
				nTotal += nVlrMerc			
			EndIf		
		EndIf
		SC6->(DbSkip())
	EndDo
EndIf
RestArea( aAreaAtu )
Return(nTotal)

//-------------------------------------------------------------------
/*/{Protheus.doc} CriaSX1
Função de criação de Perguntas

@author TOTVS Serra do Mar [JOSE CARLOS]
@since 27/06/2016
@version P12
/*/
//-------------------------------------------------------------------

//---> REMOVIDO compatibilização para versão 12.1.25.
/*Static Function CriaSX1(cPerg) 
Local aHlpPor := {}
Local aHlpEng := {}
Local aHlpSpa := {}
PutSx1(cPerg,"01","Banco Destino"  	,"Banco Destino"  	,"Banco Destino" 	,"mv_ch1","C",TamSX3("A6_COD")[1]		,0,0,"G","","SA6DV","","","MV_PAR01","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
PutSx1(cPerg,"02","Agencia Destino" ,"Agencia Destino"  ,"Agencia Destino" 	,"mv_ch2","C",TamSX3("A6_AGENCIA")[1]	,0,0,"G","",""   ,"","","MV_PAR02","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
PutSx1(cPerg,"03","DV Ag. Destino"  ,"DV Ag. Destino"  	,"DV Ag. Destino" 	,"mv_ch3","C",TamSX3("A6_DVAGE")[1]		,0,0,"G","",""   ,"","","MV_PAR03","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
PutSx1(cPerg,"04","Conta Destino" 	,"Conta Destino"  	,"Conta Destino" 	,"mv_ch4","C",TamSX3("A6_NUMCON")[1]	,0,0,"G","",""   ,"","","MV_PAR04","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
PutSx1(cPerg,"05","DV Conta Destino","DV Conta Destino" ,"DV Conta Destino" ,"mv_ch5","C",TamSX3("A6_DVCTA")[1]		,0,0,"G","",""   ,"","","MV_PAR05","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
PutSx1(cPerg,"06","Pedido De" 		,"Pedido De"  		,"Pedido De" 		,"mv_ch6","C",TamSX3("C5_NUM")[1]		,0,0,"G","",""   ,"","","MV_PAR06","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
PutSx1(cPerg,"07","Pedido Ate"	 	,"Pedido Ate"  		,"Pedido Ate" 		,"mv_ch7","C",TamSX3("C5_NUM")[1]		,0,0,"G","",""   ,"","","MV_PAR07","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
PutSx1(cPerg,"08","Dt. Pedido De" 	,"Dt. Pedido De"  	,"Dt. Pedido De" 	,"mv_ch8","D",8							,0,0,"G","",""   ,"","","MV_PAR08","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
PutSx1(cPerg,"09","Dt. Pedido Ate" 	,"Dt. Pedido Ate"  	,"Dt. Pedido Ate" 	,"mv_ch9","D",8							,0,0,"G","",""   ,"","","MV_PAR09","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
PutSx1(cPerg,"10","Cliente De" 		,"Cliente De"  		,"Cliente De" 		,"mv_chA","C",TamSX3("A1_COD")[1]		,0,0,"G","",""   ,"","","MV_PAR10","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
PutSx1(cPerg,"11","Loja De" 		,"Loja De"  		,"Loja De" 			,"mv_chB","C",TamSX3("A1_LOJA")[1]		,0,0,"G","",""   ,"","","MV_PAR11","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
PutSx1(cPerg,"12","Cliente Ate" 	,"Cliente Ate"  	,"Cliente Ate" 		,"mv_chC","C",TamSX3("A1_COD")[1]		,0,0,"G","",""   ,"","","MV_PAR12","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
PutSx1(cPerg,"13","Loja Ate" 		,"Loja Ate"  		,"Loja Ate" 		,"mv_chD","C",TamSX3("A1_LOJA")[1]		,0,0,"G","",""   ,"","","MV_PAR13","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
PutSx1(cPerg,"14","Banco Origem"  	,"Banco Destino"  	,"Banco Destino" 	,"mv_chE","C",TamSX3("A6_COD")[1]		,0,0,"G","","SA6DV","","","MV_PAR14","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
PutSx1(cPerg,"15","Agencia Origem" ,"Agencia Destino"  ,"Agencia Destino" 	,"mv_chF","C",TamSX3("A6_AGENCIA")[1]	,0,0,"G","",""   ,"","","MV_PAR15","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
PutSx1(cPerg,"16","DV Ag. Origem"  ,"DV Ag. Destino"  	,"DV Ag. Destino" 	,"mv_chG","C",TamSX3("A6_DVAGE")[1]		,0,0,"G","",""   ,"","","MV_PAR16","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
PutSx1(cPerg,"17","Conta Origem" 	,"Conta Destino"  	,"Conta Destino" 	,"mv_chH","C",TamSX3("A6_NUMCON")[1]	,0,0,"G","",""   ,"","","MV_PAR17","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
PutSx1(cPerg,"18","DV Conta Origem","DV Conta Destino" ,"DV Conta Destino" ,"mv_chI","C",TamSX3("A6_DVCTA")[1]		,0,0,"G","",""   ,"","","MV_PAR18","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
PutSx1(cPerg,"19","Dt. Entrega De" 	,"Dt. Entrega De"  	,"Dt. Entrega De" 	,"mv_chJ","D",8							,0,0,"G","",""   ,"","","MV_PAR19","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
PutSx1(cPerg,"20","Dt. Entrega Ate" ,"Dt. Entrega Ate" 	,"Dt. Entrega Ate" 	,"mv_chK","D",8							,0,0,"G","",""   ,"","","MV_PAR20","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)

Return*/
