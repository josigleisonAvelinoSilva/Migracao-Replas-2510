#INCLUDE 'DBTREE.CH'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
*-------------------------------------------*
User Function xGa200Exe(cAlias,nRecno,nOpcX,_cCodAuto)
*-------------------------------------------*
Local oDlg
Local oUm
Local oRevisao
Local oQtdBase
Local oButPosic
Local cTitulo	 	:= 'Estruturas' + ' - ' // 
Local cCodAux	 	:= Space(TamSx3("G1_COD")[1])
Local cCompAux	    := Space(TamSx3("G1_COMP")[1])
Local cTrtAux	 	:= Space(TamSx3("G1_TRT")[1])
Local cGetTrt	 	:= Space(TamSx3("G1_TRT")[1])
Local cAutTrt	 	:= Space(TamSx3("G1_TRT")[1])
Local cGetRevIni 	:= ''
Local cAutRevIni 	:= ''
Local lGetRevisa 	:= .T.
Local lRet       	:= .T.
Local lAltOpc    	:= .F.
Local lConfirma  	:= .F.
Local lAbandona  	:= .F.
Local lTransact	    := cValtoChar(nOpcX) $ '3456'
Local bKey279    	:= bkey300:= bkey274:= bkey281:= bkey305:= bkey301 :=""
Local aAreaAnt   	:= GetArea()
Local aUndo      	:= {}
Local lMudou     	:= .F.
Local aAltEstru  	:= {}
Local aPaiEstru	:= {}
Local aObjects	:= {}
Local aPosObj 	:= {}
Local aInfo	 	:= {}
Local aSize	 	:= {}
Local aValidGet	:= {}
Local aKey       	:= {279, 300, 274, 281, 305, 301, 303}
Local aBkey      	:= {}
Local aSFCJaInt  	:= {}
Local lExpand    	:= mv_par03 == 1
Local lRevAut    	:= SuperGetMv("MV_REVAUT",.F.,.F.)
Local lPriNivel  	:= If(l200Auto .And. ProcP(aAutoCab,"NIVEL1")>0,aAutoCab[ProcP(aAutoCab,"NIVEL1"),2]=="S",.F.)
Local nPosGet	 	:= 0
Local nPosAut	 	:= 0
Local nI,nJ,nPos,nX:=0
Local oPanel1
Local oPanel2
Local oPanel3
Local oPanelLeft
Local oPanelRight
Local oPanelB1
Local oPanelB2
Local oPanelB3
Local oPanelB4
Local oPanelB5
Local oPanelB6
Local oPanelB7
Local oPanelB8
Local oButton2
Local oButton3
Local oButton4
Local oButton6
Local oButton7
Local oButton8
Local oGroup
Local cPaiTree	:= ''
Local lIntSFC	:= IntegraSFC()
Local RevSim

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Variavel lPyme utilizada para Tratamento do Siga PyME        ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lPyme:= Iif(Type("__lPyme") <> "U",__lPyme,.F.)



DEFINE FONT oFont1 NAME "Arial Black" SIZE 6,17
DEFINE FONT oFont2 NAME "Courier New" SIZE 10,28 BOLD 

Private nNAlias := 0


Private cInd5	:= ''
Private nIndex   := 1
Private nQtdBasePai
Private cRevisao := CriaVar('B1_REVATU')
Private cRevSim  := CriaVar('B1_REVATU')

Private cProduto   := CriaVar('G1_COD')
Private cCodSim    := CriaVar('G1_COD')
Private cUm        := CriaVar('B1_UM')
Private nQtdBase   := CriaVar('B1_QB')
Private oButton1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Ponto de entrada para barrar a alteracao da estrutura        |
//| do produto.                                                  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("MT200ALT")
	lAltOpc := ExecBlock("MT200ALT",.F.,.F.,)
	If ValType(lAltOpc)=="L" .And. lAltOpc .And. nOpcx==4
		nOpcx := 2
	EndIf
EndIf

If nOpcX == 2
	cTitulo += OemToAnsi('Visualiza') // 'Visualisa‡„o'
ElseIf nOpcX == 3
	cTitulo += OemToAnsi('Inclusao - REPLAS') // 'Inclus„o'
ElseIf nOpcX == 4
	cTitulo += OemToAnsi('Alteracao') // 'Altera‡„o'
ElseIf nOpcX == 5
	ldbTree := .T.
	cTitulo += OemToAnsi("Exclusao") // 'Exclus„o'
EndIf

ARegsSGF := {}

If nOpcX == 3
	cUm        := ''
	cRevisao   := ''
	cProduto   := Space(TamSX3("G1_COD")[1]/*Len(SG1->G1_COD)*/)
	cCodAtual  := Replicate('?', TamSX3("G1_COD")[1]/*Len(SG1->G1_COD)*/)
	cValComp   := Replicate('?', TamSX3("G1_COD")[1]/*Len(SG1->G1_COD)*/) + '?'
	nQtdBasePai:= nQtdBase := 0
Else
	If nOpcX == 4 .And. l200Auto
		SG1->(dbSetOrder(1))
		If !SG1->(dbSeek(xFilial("SG1")+aAutoCab[ProcP(aAutoCab,"G1_COD"),2]))
			Help(" ",1,"REGNOIS")
			lRet := .F.
		EndIf
	EndIf
	SB1->(dbSetOrder(1))
	If lRet .And. !SB1->(dbSeek(xFilial('SB1')+SG1->G1_COD, .F.))
		Help('  ', 1, 'NOFOUNDSB1')
		lRet := .F.
	EndIf
	cUm         := SB1->B1_UM
	cRevisao    := SB1->B1_REVATU
	cRevSim     := ''
	cProduto    := SG1->G1_COD
	cCodAtual   := SG1->G1_COD
	cValComp    := SG1->G1_COD + '?'
	nQtdBasePai := nQtdBase := RetFldProd(SB1->B1_COD,"B1_QB")
EndIf

If lRet .And. (nOpcX == 4 .Or. nOpcX == 5) .And.;
	IsProdProt(cProduto) .And. !IsInCallStack("DPRA340INT")
	Aviso('Prot?ipos podem ser manipulados somente atrav? do m?ulo Desenvolvedor de Produtos (DPR)','Atencao',{"OK"}) //-- Prot?ipos podem ser manipulados somente atrav? do m?ulo Desenvolvedor de Produtos (DPR).
	lRet := .F.
EndIf

If lRet
	If !l200Auto
		aSize := MsAdvSize()
		aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}

		AADD(aObjects,{100,30,.T.,.F.})
		AADD(aObjects,{100,100,.T.,.T.})
		aPosObj := MsObjSize(aInfo, aObjects)

		DEFINE MSDIALOG oDlg FROM  aSize[7],0 TO aSize[6],aSize[5]  TITLE cTitulo STYLE DS_MODALFRAME PIXEL
		oDlg:lEscClose  := .F. //Nao permite sair ao se pressionar a tecla ESC.
		oDlg:lMaximized := .T.

		@ 000,000 MSPANEL oPanel1 OF oDlg

		@ 001,005 GROUP oGroup TO 40,aPosObj[2,4] OF oPanel1  PIXEL
		oGroup:Align := CONTROL_ALIGN_ALLCLIENT
		@ 008, 033 SAY   OemToAnsi('Codigo') SIZE 037, 007 OF oPanel1 PIXEL // 'C?igo:'
		
		cProduto := _cCodAuto
		@ 006, 053 MSGET cProduto           SIZE 105, 010 OF oPanel1 PIXEL PICTURE PesqPict('SG1','G1_COD') ;
			WHEN (!ldbTree .And. nOpcX==3) VALID u_xA200Codigo(cProduto, @cUm, @cRevisao, @nQtdBase, oUm, oRevisao, oQtdBase, oDlg,_cCodAuto) ;
			F3 'SB1'
			
		@ 006 ,290 Say OemToAnsi(ALLTRIM(UPPER(Posicione("SB1", 1, xFilial("SB1") + cProduto, "B1_DESC")))) SIZE 400,20 FONT oFont2 OF oPanel1 PIXEL COLOR CLR_HRED

		@ 008, 190 SAY   OemToAnsi('Unidade') SIZE 040, 007 OF oPanel1 PIXEL	//'Unidade:'
		@ 006, 215 MSGET oUm Var cUm        SIZE 015, 010 OF oPanel1 PIXEL ;
			WHEN .F.

		@ 008, 240 SAY   OemToAnsi('Revisao')    SIZE 030, 007 OF oPanel1 PIXEL // 'Revis„o'
		@ 006, 265 MSGET oRevisao Var cRevisao SIZE 015, 010 OF oPanel1 PIXEL PICTURE PesqPict('SB1','B1_REVATU',3) ;
			WHEN (!ldbTree .And. nOpcX == 2 .And. lGetRevisa) .Or. (nOpcX == 4 .And. lGetRevisa) VALID u_xA200GetRev(@lGetRevisa, oDlg, oTree, cProduto, cRevisao, nOpcX,lRevAut,@aPaiEstru)

		@ 022, 012 SAY   OemToAnsi('Estrutura Similar')  SIZE 054, 007 OF oPanel1 PIXEL // 'Estrutura Similar:'
		@ 020, 053 MSGET oCodSim Var cCodSim SIZE 105, 010 OF oPanel1 PIXEL PICTURE PesqPict('SG1','G1_COD') ;
			WHEN (nOpcX == 3 .And. lGetRevisa) VALID u_xa2RevMax(cCodSim, @cRevSim) ;					
			F3 'SG1'
			
		@ 022, 170 SAY OemToAnsi('Revis? da estrutura similar')   SIZE 070, 007 OF oPanel1 PIXEL // 'Revis? da estrutura similar'
		@ 020, 240 MSGET RevSim Var cRevSim SIZE 015, 010 OF oPanel1 PIXEL PICTURE PesqPict('SB1','B1_REVATU',3);
			WHEN (nOpcX == 3 .And. lGetRevisa) VALID A200CodSim(cProduto, cCodSim, @aUndo) .And. u_xARevSim(@lGetRevisa, oDlg, oTree, cProduto, cCodSim, cRevSim, nOpcX,lRevAut,@aPaiEstru);

		@ 022, 270 SAY   OemToAnsi('Quantidade Base:')    SIZE 053, 007 Of oPanel1 PIXEL // 'Quantidade Base:'
		@ 020, 315 MSGET oQtdBase Var nQtdBase SIZE 071, 010 Of oPanel1 PIXEL PICTURE PesqPictQt('B1_QB',20) ;
			WHEN (nOpcX==3.Or.nOpcX==4) VALID u_xA200QBase(nQtdBase, nOpcX, cProduto, cCodSim, oTree, oDlg)

		@ 000,000 MSPANEL oPanel2 OF oDlg
		oTree := DbTree():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3]-25,aPosObj[2,4], oPanel2,,,.T.)
		oTree:Align := CONTROL_ALIGN_ALLCLIENT

		@ 000,000 MSPANEL oPanel3 OF oDlg

		@ 000,000 MSPANEL oPanelRight SIZE __DlgWidth(oMainWnd)/1,5 OF oPanel3
		oPanelRight:Align := CONTROL_ALIGN_RIGHT

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//?Defini‡„o dos Bot”es Utilizados                                        ?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		//-- Operacao x Componente
		If !lPyme .And. (nOpcx == 3 .Or. nOpcx == 4)
			@ 000,000 MSPANEL oPanelB1 SIZE 90,40 OF oPanelRight
			@ 000,000 BUTTON oButton1 PROMPT "&"+A635Titulo() ACTION Ma200Oper(nOpcX, oTree:GetCargo(), oTree) SIZE 65,11 OF oPanelB1 PIXEL
            If nOpcx == 3
				oButton1:Disable()
			EndIf
		Endif
		oButton1:Hide() //[##]

		//-- Inclus„o
		@ 000,000 MSPANEL oPanelB2 SIZE 30,40 OF oPanelRight
		If nOpcX == 2 .Or. nOpcX == 5
			DEFINE SBUTTON oButton2 FROM 000,000  TYPE 4 DISABLE OF oPanelB2 //-- Desabilita Inlus„o			
		Else
			DEFINE SBUTTON oButton2 FROM 000,000  TYPE 4 ENABLE OF oPanelB2 ;
			 ACTION If(!ldbTree .And. nOpcX < 4, .T., Ma200Edita(nOpcX, oTree:GetCargo(), oTree, 3, @aUndo, @lMudou, @aAltEstru,, aKey, aBkey,@aPaiEstru))
			oButton2:cTOOLTIP:=OemToAnsi("Incluir-<Alt-I>")//--"Incluir-<Alt-I>"
			bkey279:={|| If(!ldbTree .And. nOpcX < 4, .T., Ma200Edita(nOpcX, oTree:GetCargo(), oTree, 3, @aUndo, @lMudou, @aAltEstru,, aKey, aBkey,@aPaiEstru))}
			AADD(aBkey, {bkey279, 279})
			SetKey(279, bkey279)			
		EndIf

		@ 000,000 MSPANEL oPanelB3 SIZE 30,40 OF oPanelRight
		//-- Altera‡„o
		DEFINE SBUTTON oButton3 FROM 000,000 TYPE 11 ENABLE OF oPanelB3 ;
			ACTION If(!ldbTree .And. nOpcX < 4, .T., Ma200Edita(nOpcX, oTree:GetCargo(), oTree, 4, @aUndo, @lMudou, @aAltEstru,, aKey, aBkey,@aPaiEstru))
			oButton3:cTOOLTIP:=OemToAnsi("Editar-<Alt-M>")//--"Editar-<Alt-M>"
			bKey300 := {|| Ma200Edita(nOpcX, oTree:GetCargo(), oTree, 4, @aUndo, @lMudou, @aAltEstru,, aKey, aBkey,@aPaiEstru) }
			AADD(aBkey, {bkey300, 300})
			SetKey(300, bKey300)
		//oPanelB3:Hide() //[##]
		
		@ 000,000 MSPANEL oPanelB4 SIZE 30,40 OF oPanelRight
		//-- Exclus„o
		If nOpcX == 2 .Or. nOpcX == 5
			DEFINE SBUTTON oButton4 FROM 000,000  TYPE 3 DISABLE OF oPanelB4 //-- Desabilita Exclus„o
		Else
			DEFINE SBUTTON oButton4 FROM 000,000  TYPE 3 ENABLE OF oPanelB4 ;
				ACTION If(!ldbTree .And. nOpcX < 4, .T., Ma200Edita(nOpcX, oTree:GetCargo(), oTree, 5, @aUndo, @lMudou, @aAltEstru,, aKey, aBkey,@aPaiEstru))
				oButton4:cTOOLTIP:=OemToAnsi("Excluir-<Alt-E>")//--"Excluir-<Alt-E>"
				bKey274 :={|| If(!ldbTree .And. nOpcX < 4, .T., Ma200Edita(nOpcX, oTree:GetCargo(), oTree, 5, @aUndo, @lMudou, @aAltEstru,, aKey, aBkey,@aPaiEstru))}
				AADD(aBkey, {bkey274, 274})
				SetKey(274, bKey274)
		EndIf

		@ 000,000 MSPANEL oPanelB5 SIZE 30,40 OF oPanelRight
		//-- Pesquisa e Posiciona
		DEFINE SBUTTON oButPosic FROM 000,000 TYPE 15 ENABLE OF oPanelB5 ;
			ACTION If(!ldbTree .And. nOpcX < 4, .T., u_xMaPosic(nOpcX, oTree:GetCargo(), oTree, aKey, aBkey))
			oButPosic:cToolTip:=OemToAnsi("Pesquisar-<Alt-P>") //--"Pesquisar-<Alt-P>"
			oButPosic:cTitle := OemToAnsi('Pesquisar') // 'Pesquisar'
			bKey281:={|| u_xMaPosic(nOpcX, oTree:GetCargo(), oTree, aKey, aBkey)}
			AADD(aBkey,{bkey281, 281})
			SetKey(281, bKey281)
			oPanelB5:Hide() //[##]
		@ 000,000 MSPANEL oPanelB6 SIZE 30,40 OF oPanelRight

		//-- Confirma
		If nOpcX == 5
			DEFINE SBUTTON oButton6 FROM 000,000 TYPE 1 ENABLE OF oPanelB6 ;
				ACTION(lConfirma:=.T., u_xMa200Del(cCodAtual), Ma200Fecha(oDlg, oTree, nOpcX, .T., cUm, cProduto, nQtdBase, cRevisao, .T., aAltEstru,aKey,aBkey,aUndo,aPaiEstru))
				oButton6:cToolTip:=OemToAnsi("OK-<Alt-N>")//--"OK-<Alt-N>"
				bKey305:={|| (lConfirma:=.T., u_xMa200Del(cCodAtual,aKey,aBKey), Ma200Fecha(oDlg, oTree, nOpcX, .T., cUm, cProduto, nQtdBase, cRevisao, .T., aAltEstru, aKey, aBkey, aUndo,aPaiEstru))}
				AADD(aBkey, {bkey305, 305})
				SetKey(305, bKey305)
		Else
			DEFINE SBUTTON oButton6 FROM 000,000 TYPE 1 ENABLE OF oPanelB6 ;
				ACTION (lConfirma:=.T., If(u_xBtn2Ok(aUndo, cProduto) .And. ldbTree, Ma200Fecha(oDlg, oTree, nOpcX, lMudou, cUm, cProduto, nQtdBase, cRevisao, .T., aAltEstru, aKey, aBkey, aUndo,aPaiEstru), .T.))
				oButton6:cToolTip:=OemToAnsi("OK-<Alt-N>")//--"OK-<Alt-N>"
				bKey305:={|| (lConfirma:=.T., If(u_xBtn2Ok(aUndo, cProduto) .And. ldbTree, Ma200Fecha(oDlg, oTree, nOpcX, lMudou, cUm, cProduto, nQtdBase, cRevisao, .T., aAltEstru, aKey, aBkey, aUndo,aPaiEstru), .T.))}
				AADD(aBkey, {bkey305, 305})
				SetKey(305, bKey305)
		EndIf

		@ 000,000 MSPANEL oPanelB7 SIZE 30,40 OF oPanelRight

		//-- Abandona
		DEFINE SBUTTON oButton7 FROM 000,000  TYPE 2 ENABLE OF oPanelB7 ;
			ACTION (lAbandona := .T., Ma200Undo(aUndo, nOpcx), Ma200Fecha(oDlg, oTree, nOpcX, .F., cUm, cProduto, nQtdBase, cRevisao, .F., aAltEstru, aKey, aBkey, aUndo,aPaiEstru))
			oButton7:cToolTip:=OemToAnsi("Cancela-<Alt-X>")//--"Cancela-<Alt-X>"
			bKey301:={|| (lAbandona := .T., Ma200Undo(aUndo, nOpcx), Ma200Fecha(oDlg, oTree, nOpcX, .F., cUm, cProduto, nQtdBase, cRevisao, .F., aAltEstru, aKey, aBkey, aUndo,aPaiEstru))}
			AADD(aBkey, {bkey301, 301})
			SetKey(301, bKey301)

		//-- Explode Proximo Nivel
		If !lExpand
			@ 000,000 MSPANEL oPanelB8 SIZE 30,40 OF oPanelRight
			If nOpcX <> 2 .And. nOpcX <> 4
				DEFINE SBUTTON oButton8 FROM 000,000  TYPE 19 DISABLE OF oPanelB8 //-- Desabilita Explode Nivel
			Else
				DEFINE SBUTTON oButton8 FROM 000,000  TYPE 19 ENABLE OF oPanelB8 ;
				ACTION NextNivel(nOpcX, oTree:GetCargo(), oTree, oDlg, akey, aBkey)
				oButton8:cToolTip:=OemToAnsi("Avan?r-<Alt-V>")//--"Avan?r-<Alt-V>"
				bkey303:= {|| NextNivel(nOpcX, oTree:GetCargo(), oTree, oDlg, akey, aBkey)}
				AADD(aBkey, {bkey303, 303})
				Setkey(303, bKey303)
			EndIf
		EndIf

		oPanelB7:Align := CONTROL_ALIGN_RIGHT
		oPanelB6:Align := CONTROL_ALIGN_RIGHT
		oPanelB5:Align := CONTROL_ALIGN_RIGHT
		oPanelB4:Align := CONTROL_ALIGN_RIGHT
		oPanelB3:Align := CONTROL_ALIGN_RIGHT
		oPanelB2:Align := CONTROL_ALIGN_RIGHT
		If !lExpand
			oPanelB8:Align := CONTROL_ALIGN_RIGHT
        EndIf
        If !lPyme .and. (nOpcx == 3 .Or. nOpcx == 4)
			oPanelB1:Align := CONTROL_ALIGN_RIGHT
		EndIf

		If !lPyme .And. (nOpcx == 3 .Or. nOpcx == 4)
			oButton1:Align := CONTROL_ALIGN_RIGHT
		EndIf
		If !lExpand
			oButton8:Align := CONTROL_ALIGN_RIGHT
		EndIf
		oButton2:Align := CONTROL_ALIGN_RIGHT
		oButton3:Align := CONTROL_ALIGN_RIGHT
		oButton4:Align := CONTROL_ALIGN_RIGHT
		oButPosic:Align := CONTROL_ALIGN_RIGHT
		oButton6:Align := CONTROL_ALIGN_RIGHT
		oButton7:Align := CONTROL_ALIGN_RIGHT

		If ExistBlock("MA200CAB")
			ExecBlock("MA200CAB",.F.,.F.,{cProduto,nOpcx,oPanel1,8,22,270})
		EndIf

		ACTIVATE MSDIALOG oDlg ON INIT ( xMa200Monta(oTree, oDlg, cCodAtual, cCodSim, cRevisao, nOpcX),;
			AlignObject(oDlg,{oPanel1,oPanel2,oPanel3},1,2,{070,,020}),;
			If(nOpcx==4,oRevisao:SetFocus(),NIL));
			VALID If(nOpcX>2.And.nOpcX<=5.And.!(lConfirma.Or.lAbandona), (Ma200Undo(aUndo), Ma200Fecha(,, nOpcX, .F., cUm, cProduto, nQtdBase, cRevisao, .F., aAltEstru,aKey, aBKey,aUndo,aPaiEstru)), .T.)
	Else

		lConfirma := .T.
		If Type('aEndEstrut')=="U"
			Private aEndEstrut := {}
		EndIf
		aValidGet := {}
		cProduto  := aAutoCab[ProcP(aAutoCab,"G1_COD"),2]
		If nOpcx # 4
			aAdd(aValidGet,{"cProduto"    ,cProduto+Space(Len(SG1->G1_COD)-Len(cProduto)),"u_xA200Codigo(cProduto, @cUm, @cRevisao, @nQtdBase)",.t.})
		EndIf
		If nOpcx # 5 .And. !Empty(nPos := ProcP(aAutoCab,"G1_QUANT"))
			Aadd(aValidGet,{"nQtdBase"    ,aAutoCab[nPos,2],"u_xA200QBase(nQtdBase,"+Str(nOpcX)+", cProduto)",.t.})
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//?Faz a conistencia dos gets do cabecalho.                     ?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !SG1->(MsVldGAuto(aValidGet)) // consiste os gets
			lRet := .f.
		EndIf

		Do Case
		//-- Inclusao
		Case lRet .And. nOpcx == 3
			cCodAtual	:= cProduto
			cCargo		:= cProduto + Space(TamSx3("G1_TRT")[1]) + cProduto + '000000000' + '000000000' + 'NOVO'
			For nI:=1 To Len(aAutoItens)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//?Faz a validacao dos gets dos NOs(itens)                      ?
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				lDbTree := .T. //Esta variavel somente foi setada para .T. para nao ser necessario alterar as validacoes dos gets
				aValidGet := SG1->(MSArrayXDB(aAutoItens[nI],.T.,nOpcX))
				If Empty(aValidGet) .Or. !SG1->(MsVldGAuto(aValidGet)) // consiste os gets
					lRet := .f.
					Exit
				EndIf
				lDbTree := .F. //Restaurada para false para evitar problemas de atualizacao de objetos

				// Atualiza Revisao Inicial
				nPosGet := aScan(aValidGet , {|x| Alltrim(x[1])=="G1_REVINI"})
		        If nPosGet > 0
		        	cGetRevIni := aValidGet[nPosGet,2]
		        EndIf
				nPosAut := aScan(aAutoItens[nI], {|x| Alltrim(x[1])=='G1_REVINI'})
		    	If nPosAut > 0
		    		cAutRevIni := aAutoItens[nI][nPosAut,2]
		    	EndIf
			    If cGetRevIni <> cAutRevIni
			    	aValidGet[nPosGet,2] := Trim(cAutRevIni)
			    EndIf

				// Atualiza Sequencia
				nPosGet := aScan(aValidGet , {|x| Alltrim(x[1])=="G1_TRT"})
		        If nPosGet > 0
		        	cGetTrt := aValidGet[nPosGet,2]
		        EndIf
				nPosAut := aScan(aAutoItens[nI], {|x| Alltrim(x[1])=='G1_TRT'})
		    	If nPosAut > 0
		    		cAutTrt := aAutoItens[nI][nPosAut,2]
		    	EndIf
			    If nPosGet > 0 .And. nPosAut > 0 .And. cGetTrt <> cAutTrt
			    	aValidGet[nPosGet,2] := cAutTrt
			    EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//?Cria variaveis de memoria para ser usada nas rotinas posteriores ?
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nJ:=1 To Len(aValidGet)
					If Type('M->'+aValidGet[nJ,1])=='U'
						CriaVar(aValidGet[nJ,1],.F.)
					EndIf
					&('M->'+aValidGet[nJ,1]) := aValidGet[nJ,2]
				Next
				If nI > 1
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//?Emula o possicionamento do Gargo(GetGargo)do objeto dbTree   ?
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DbSelectArea("SG1")
					DbSetOrder(1)
					If MsSeek(xFilial("SG1")+M->G1_COD)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//?Caso encontre, possiciona o NO pai, capturando o Recno()     ?
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						cCargo  := M->G1_COD + M->G1_TRT + M->G1_COMP + StrZero(SG1->(Recno()), 9) + StrZero(nIndex ++, 9) +'CODI'
					Else
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//?Se o pai nao existir informa um cargo com caracteristicas de ?
						//?um NO novo para ser usada a variavel cCodAtual como NO pai.  ?
						//?Neste caso as informacoes importantes sao: Recno Zero e stri-?
						//?ng 'NOVO', para utilizar a logica ja existente no Ma200Edita.?
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						cCargo  := M->G1_COD + M->G1_TRT + M->G1_COMP + StrZero(0, 9) + StrZero(nIndex ++, 9) +'NOVO'
					EndIf
					cCodAtual := M->G1_COD
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//?Faz a inclusao do NO na estrutura a partir do cargo informado?
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Ma200Edita(nOpcX,cCargo,NIL,nOpcX,@aUndo,@lMudou,@aAltEstru,,,,@aPaiEstru)
					lRet := .f.
					Exit
				EndIf
			Next nI
		//-- Alteracao
		Case lRet .And. nOpcx == 4
			cCodAtual := cProduto
			cCargo 	  := SG1->(G1_COD+G1_TRT+G1_COMP+StrZero(Recno(),9)+StrZero(nIndex++,9)+'CODI')

			//-- Deleta componentes nao recebidos na nova estrutura
			If !lRevAut
				A200Auto4E(SG1->G1_COD,@aUndo,@lMudou,@aAltEstru,@aPaiEstru,lPriNivel)
			EndIf

			For nI := 1 To Len(aAutoItens)
			    For nJ := 1 To Len(aAutoItens[nI])
			    	CriaVar(aAutoItens[nI,nJ,1],.F.)
			    	&('M->'+aAutoItens[nI,nJ,1]) := aAutoItens[nI,nJ,2]
				Next nJ

				//-- Para nao permitir o cadastro de itens que nao sejam da estrutura
				If cProduto # M->G1_COD .And.; //-- Verifica se o item pai neste no e o pai da estrutura
					aScan(aAutoItens,{|x| x[ProcP(aAutoItens[nI],"G1_COMP"),2] == M->G1_COD}) == 0 //-- Verifica se e componente em outro no
					Aviso("Atenção","Estrutura incosistente: produto " +AllTrim(M->G1_COD) +" sem elo.",{"OK"})
					lRet := .F.
					Exit
				EndIf

				//-- Seta nOpcx para execucao de axInclui ou axAltera
				SG1->(dbSetOrder(1))
				If SG1->(MsSeek(xFilial("SG1")+M->G1_COD+M->G1_COMP+M->G1_TRT))
					nOpcx := 4
					//-- Emula preenchimento da cCargo (ja que nao ha tree) para uso das funcoes
					cCargo  := SG1->(G1_COD+G1_TRT+G1_COMP+StrZero(Recno(),9)+StrZero(nIndex++,9)+'COMP')
					T_CARGO := SG1->(G1_COD+G1_TRT+G1_COMP+StrZero(Recno(),9)+StrZero(nIndex++,9)+'COMP')
				Else
					nOpcx := 3
					//-- Emula preenchimento da cCargo (ja que nao ha tree) para uso das funcoes
					cCargo  := M->G1_COD+M->G1_TRT+M->G1_COMP+StrZero(0,9)+StrZero(nIndex++,9)+'NOVO'
					T_CARGO := M->G1_COD+M->G1_TRT+M->G1_COMP+StrZero(0,9)+StrZero(nIndex++,9)+'NOVO'
				EndIf

				//-- Monta array com os campos da SG1 a serem validados
				aValidGet := SG1->(MSArrayXDB(aAutoItens[nI],.T.,nOpcX))

				//-- Cria variaveis de memoria para serem usadas nas rotinas posteriores
				For nJ := 1 To Len(aValidGet)
					If Type('M->'+aValidGet[nJ,1]) == 'U'
						CriaVar(aValidGet[nJ,1],.F.)
					EndIf
					&('M->'+aValidGet[nJ,1]) := aValidGet[nJ,2]
				Next nJ

				//-- Faz a validacao dos gets dos NOs(itens)
				lDbTree := .T. //Esta variavel somente foi setada para .T. para nao ser necessario alterar as validacoes dos gets
				If Empty(aValidGet) .Or. !SG1->(MsVldGAuto(aValidGet))
					lRet := .F.
					Exit
				EndIf
				lDbTree := .F. //Restaurada para false para evitar problemas de atualizacao de objetos

				cCodAtual := M->G1_COD

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//?Faz a inclusao do NO na estrutura a partir do cargo informado?
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Ma200Edita(nOpcX,cCargo,NIL,nOpcX,@aUndo,@lMudou,@aAltEstru,,,,@aPaiEstru,aAutoItens[nI])
					lRet := .f.
					Exit
				EndIf
			Next nI
		//-- Exclusao
		Case lRet .And. nOpcx == 5
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//?Exclui todos os G1_COD iguais ao cProduto (alimentado somente?
			//?pelo array do cabecalho, onde sera obrigatorio apenas passar |
			//?o codigo do Produto (G1_COD) que deseja excluir.             ?
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lRet := u_xMa200Del(cProduto)
		EndCase
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//?Se nao ocorreu nenhum erro, finaliza o processo, caso contra-?
		//?rio restaura a situacao anterior a execucao da rotina automa-|
		//?tica.                                                        ?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet
			Ma200Fecha(oDlg, oTree, nOpcX, .T. , cUm, cProduto, nQtdBase, cRevisao, .T., aAltEstru, , , aUndo,aPaiEstru)
		Else
			Ma200Undo(aUndo)
		EndIf

		If !lRet .AND. lTransact
			DisarmTransaction()
		EndIf

	EndIf

	nPos := SG1->(Recno())

	//-- Integracao Chao de Fabrica
	If lRet .And. lConfirma .And. !lAbandona .And. (nOpcX == 3 .Or. nOpcX == 4 .Or. nOpcX == 5) .And. lIntSFC
   		If nOpcX != 5
			For nX := 1 To Len(aUndo)
				SG1->(dbGoTo(aUndo[nX,1]))
				If aUndo[nX,2] == 1 .And. Empty(aScan(aSFCJaInt,{|x| x == SG1->G1_COD}))
					u_xA2IntSFC(SG1->G1_COD,'2')
					aAdd(aSFCJaInt,SG1->G1_COD)
				EndIf
			Next nX
		Else
			SG1->(dbGoTo(aRecDel[1]))
			u_xA2IntSFC(SG1->G1_COD,'1')
		EndIf
	EndIf

	SG1->(dbGoTo(nPos))
EndIf

//--Destativa teclas de atalho
For nX:=1 to Len(aKey)
	Set Key aKey[nX] To
Next nX

//-- Reinicializa Variaveis
cInd5     := ''
ldbTree   := .F.
cValComp  := Replicate('?', Len(SG1->G1_COD)) + '?'
cCodAtual := Replicate('?', Len(SG1->G1_COD))

RestArea(aAreaAnt)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±?un‡„o    ?xMa200Monta ?Autor ?ernando Joly/Eduardo?Data ?9.05.1999³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±?escri‡„o ?Montagem do Arquivo Temporario para o Tree(Func.Recurssiva)³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?intaxe   ?xMa200Monta(ExpO1,ExpO2,ExpC1,ExpC2,ExpC3,ExpN1,ExpC4,ExpC5)³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?arametros?ExpO1 = Objeto Tree                                        ³±?
±±?         ?ExpO2 = Objeto Dlg                                         ³±?
±±?         ?ExpC1 = Codigo do Produto                                  ³±?
±±?         ?ExpC2 = Codigo da estrutura similar		 (OPC)	          ³±?
±±?         ?ExpC3 = Codigo da revisao				 (OPC)	          ³±?
±±?         ?ExpN1 = Numero da Op‡„o Escolhida         (OPC)            ³±?
±±?         ?ExpC4 = Cargo do Produto no Tree          (OPC)            ³±?
±±?         ?ExpC5 = Sequencia Pai                     (OPC)            ³±?
±±?         ?ExpL1 = Zera cont. das variaves staticas  (OPC) 			  ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?etorno   ?False se o Codigo do Produto nao existir, e True em C.C.   ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?Uso      ?MATA200                                                    ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?*/
Static Function xMa200Monta(oTree, oDlg, cProduto, cCodSim, cRevisao, nOpcX, cCargo, cTRTPai, lZeraStatic, lOpc)

Local nRecAnt    := 0
Local cComp      := ''
Local cPrompt    := ''
Local cFolderA   := 'FOLDER5'
Local cFolderB   := 'FOLDER6'
Local cRevPI 	 := ""
Local nRecCargo  := 0
Local dValIni    := CtoD('  /  /  ')
Local dValFim    := CtoD('  /  /  ')
Local lRet		 := .T.
Local lContinua	 := .T.
Local nQtdeSG1   := 0
Local lExpand    := mv_par03 == 1
Local lExibeOPC  := .T.
Local lRetPE
Local lA200rvPi  := ExistBlock("A200RVPI")
Local nIndSG1	 := 1
Local lM200BMP   := ExistBlock("M200BMP")
Local uRet       := Nil
Local lRevAut    := SuperGetMv("MV_REVAUT",.F.,.F.)
Local lOpcional  := .F.
Local lOpcAux    := .T.
Local cOpc       := ""
Local aOpc       := {} 

Static nNivelTr  := 0
Static cFistCargo:= NIL

Default lOpc := .T.

// -- Atualiza nivel da estrutura
nNivelTr += 1

nOpcX := If(nOpcX==Nil,0,nOpcX)   

lExpEst := .T.

If ExistBlock("MA200ORD")
	nIndSG1 := ExecBlock("MA200ORD",.F.,.F.)
	If ValType(nIndSG1) # "N"
		nIndSG1 := 1
	EndIf
EndIf

If !ldbTree .And. nOpcX < 5
	oDlg:SetFocus()
	lRet := .F.
EndIf

If lRet       
	lExpEst := .T.
	
	//-- Posiciona no SB1
	cPrompt := cProduto + Space(400)
	SB1->(dbSetOrder(1))
	If SB1->(dbSeek(xFilial('SB1') + cProduto, .F.))
		cPrompt := AllTrim(cProduto) + " - " + SB1->B1_DESC + Space(Len(SB1->B1_COD) - Len(AllTrim(cProduto)))
	EndIf
	cPrompt += Space(Len("QTDE:")+TamSX3("G1_QUANT")[1]) //"QTDE:"
	cPrompt += Space(200)

	SG1->(dbSetOrder(nIndSG1))
	If nOpcX == 3 .And. cProduto # Replicate('?', Len(SG1->G1_COD)) .And. Empty(cCodSim)

		If lM200BMP
			uRet := Execblock("M200BMP", .F., .F., {cPrompt, cFolderA, cFolderB})
			If ValType(uRet) == "A"
				cFolderA := uRet[1]
				cFolderB := uRet[2]
			EndIf
		EndIf

		//-- Cria‡„o de uma nova estrutura
		oTree:AddTree(u_xA2Prompt(cPrompt,"",,cProduto),.T.,cFolderA,cFolderB,,,cProduto+Space(TamSx3("G1_TRT")[1])+cProduto+'000000000'+'000000000'+'NOVO')
		oTree:EndTree()
		oTree:Refresh()
		oTree:SetFocus()
		lContinua := .F.

	ElseIf !SG1->(dbSeek(xFilial('SG1') + cProduto, .F.))
		If ldbTree
			oTree:Refresh()
			oTree:SetFocus()
		Else
			oDlg:SetFocus()
		EndIf
		lRet := .F.
	EndIf

	If lRet .And. lContinua
		cTRTPai := If(cTRTPai==Nil,SG1->G1_TRT,cTRTPai)

		dValIni := SG1->G1_INI
		dValFim := SG1->G1_FIM
		If cCargo == Nil
			cCargo := SG1->G1_COD + cTRTPai + SG1->G1_COMP + StrZero(SG1->(Recno()), 9) + StrZero(nIndex ++, 9) + 'CODI'
		ElseIf (nRecCargo := Val(SubStr(cCargo,Len(SG1->G1_COD + SG1->G1_TRT + SG1->G1_COMP) + 1, 9))) > 0
			nRecAnt := SG1->(Recno())
			SG1->(dbGoto(nRecCargo))
			dValIni := SG1->G1_INI
			dValFim := SG1->G1_FIM
			nQtdeSG1 := SG1->G1_QUANT
			If GetMV("MV_SELEOPC") == "S" .And. lOpc
           cOpc := Padr(SG1->G1_GROPC, TamSX3("G1_GROPC")[1]) + Padr(SG1->G1_OPC, TamSX3("G1_OPC")[1]) + "/"
           aOpc := aClone(ListOpc(Nil,Nil,cOpc))
        EndIf
			SG1->(dbGoto(nRecAnt))
		EndIf

		//-- Define as Pastas a serem usadas
		cFolderA := 'FOLDER5'
		cFolderB := 'FOLDER6'
		If Right(cCargo, 4) == 'COMP' .And. ;
			(dDataBase < dValIni .Or. dDataBase > dValFim)
			cFolderA := 'FOLDER7'
			cFolderB := 'FOLDER8'
		EndIf

		If lM200BMP
			uRet := Execblock("M200BMP", .F., .F., {cPrompt, cFolderA, cFolderB})
			If ValType(uRet) == "A"
				cFolderA := uRet[1]
				cFolderB := uRet[2]
			EndIf
		EndIf

		//-- Adiciona o Pai na Estrutura
		oTree:AddTree(u_xA2Prompt(cPrompt,cCargo,nQtdeSG1,,aOpc),.T.,cFolderA,cFolderB,,,cCargo)

		Do While !SG1->(Eof()) .And. SG1->G1_FILIAL+SG1->G1_COD == xFilial("SG1")+cProduto
		
			lExpEst := .T.

			//-- Nao Adiciona Componentes fora da Revis„o
			If (nOpcX == 2 .Or. nOpcX == 4) .And. (cRevisao # Nil) .And. ;
				!(SG1->G1_REVINI <= cRevisao .And. (SG1->G1_REVFIM >= cRevisao .Or. SG1->G1_REVFIM = ' '))
				SG1->(dbSkip())
				Loop
			EndIf

			nRecAnt  := SG1->(Recno())
			cComp    := SG1->G1_COMP
			cCargo   := SG1->G1_COD + SG1->G1_TRT + SG1->G1_COMP + StrZero(SG1->(Recno()), 9) + StrZero(nIndex ++, 9) + 'COMP'
			nQtdeSG1 := SG1->G1_QUANT
			
			If Empty(SG1->G1_GROPC)
           lOpcAux := .F.
        Else
           lOpcAux := .T.
        EndIf
        
        If GetMV("MV_SELEOPC") == "S"
           cOpc := Padr(SG1->G1_GROPC, TamSX3("G1_GROPC")[1]) + Padr(SG1->G1_OPC, TamSX3("G1_OPC")[1]) + "/"
           aOpc := aClone(ListOpc(Nil,Nil,cOpc))
        EndIf

			If cFistCargo == NIL
				cFistCargo := cCargo
			EndIf

			//-- Define as Pastas a serem usadas
			cFolderA := 'FOLDER5'
			cFolderB := 'FOLDER6'
			If dDataBase < SG1->G1_INI .Or. dDataBase > SG1->G1_FIM
				cFolderA := 'FOLDER7'
				cFolderB := 'FOLDER8'
			EndIf

			//-- Posiciona no SB1
			cPrompt := cComp + Space(400)
			SB1->(dbSetOrder(1))
			If SB1->(dbSeek(xFilial('SB1') + cComp, .F.))
				cPrompt := AllTrim(cComp) + " - " + SB1->B1_DESC + Space(Len(SB1->B1_COD) - Len(AllTrim(cComp)))
			EndIf
			cPrompt += Space(Len("QTDE:")+TamSX3("G1_QUANT")[1]) //"QTDE:"
			cPrompt += Space(200)    
			
			lExpEst := .T.						                

   			If SG1->(dbSeek(xFilial('SG1') + SG1->G1_COMP, .F.)) .and. lExpEst
				
				cRevPi := IIf(SB1->B1_REVATU = ' ','001',SB1->B1_REVATU)
				
				If lA200rvPi
					cRevPi := Execblock ("A200RVPI",.F.,.F.,{cProduto, cRevisao, SG1->G1_COD, cRevPi})
				EndIf
				
   				If lExpand .And. lExibeOPC
					//-- Adiciona um Nivel a Estrutura
					If cComp == SG1->G1_COD .And. !lOpcAux
                lOpcional := .F.
             Else
                lOpcional := .T.
             EndIf
					xMa200Monta(oTree, oDlg, SG1->G1_COD,'',cRevPi,IIF(lRevaut,2,If(nOpcX==3,0,nOpcX)), cCargo, cTRTPai,,lOpcional)
				Else
					If lM200BMP
						uRet := Execblock("M200BMP", .F., .F., {cPrompt, cFolderA, cFolderB})
						If ValType(uRet) == "A"
							cFolderA := uRet[1]
							cFolderB := uRet[2]
						EndIf
					EndIf
					oTree:AddItem(u_xA2Prompt(cPrompt, cCargo, nQtdeSG1,,aOpc), cCargo, cFolderA, cFolderB,,, 2)
				EndIf
			Else
				//-- Adiciona um Componente a Estrutura
				If lM200BMP
					uRet := Execblock("M200BMP", .F., .F., {cPrompt, cFolderA, cFolderB})
					If ValType(uRet) == "A"
						cFolderA := uRet[1]
						cFolderB := uRet[2]
					EndIf
				EndIf

				DBADDITEM oTree PROMPT u_xA2Prompt(cPrompt, cCargo ,nQtdeSG1,,aOpc) RESOURCE cFolderA CARGO cCargo
			EndIf

			SG1->(dbGoto(nRecAnt))
			SG1->(dbSkip())
		EndDo
		oTree:EndTree()

		If ldbTree
			// --- Atualiza obj.dbtree apos processar a estrutura
			If nNivelTr == 1
				If( cFistCargo <> NIL )
					cCargo := cFistCargo
					cFirstCargo := NIL
				EndIf
				oTree:TreeSeek(cCargo)
				oTree:Refresh()
				oTree:SetFocus()
			EndIf
		Else
			oDlg:SetFocus()
		EndIf
	EndIf
EndIf
If lContinua
	// --- Atualiza nivel da estrutura
	nNivelTr -= 1
EndIf

//Zera conteudo das variaveis static, necessario para montagem do tree na rotina MATC015.
If ValType(lZeraStatic)=="L" .And. lZeraStatic
	nNivelTr  := 0
	cFistCargo:= NIL
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±?un‡„o    ?Ma200ATree ?Autor ?ernando Joly/Eduardo?Data ?9.05.1999³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±?escri‡„o ?Adiciona Componentes ao Tree existente (Func.Recursiva) 	  ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?intaxe   ?Ma200ATree(ExpO1, ExpC1, ExpC2, ExpC3)		              ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?arametros?ExpO1 = Objeto Tree                                        ³±?
±±?         ?ExpC1 = Codigo do Produto                                  ³±?
±±?         ?ExpC2 = Cargo do Produto no Tree                           ³±?
±±?         ?ExpC3 = TRT Pai (sequencia)                                ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?etorno   ?.T.                                                        ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?Uso      ?MATA200                                                    ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?*/
Static Function xMa200ATree(oTree, cProduto, cCargo, cTRTPai, aOpcPai)

Local aAreaAnt   := GetArea()
Local nRecAnt    := 0
Local cComp      := ''
Local cPrompt    := ''
Local cFolderA   := 'FOLDER5'
Local cFolderB   := 'FOLDER6'
Local dValIni    := CtoD('  /  /  ')
Local dValFim    := CtoD('  /  /  ')
Local nRecCargo  := 0
Local cCargoPai  := ''
Local nQtdeSG1   := 0
Local lM200BMP   := ExistBlock("M200BMP")
Local uRet       := Nil
Local cRevAtual  := ''
Local cOpc       := ""
Local aOpc       := {}

Default aOpcPai  := {}

cTRTPai := If(cTRTPai==Nil,SG1->G1_TRT,cTRTPai)

dValIni := SG1->G1_INI
dValFim := SG1->G1_FIM
If cCargo == Nil
	cCargo := SG1->G1_COD + cTRTPai + SG1->G1_COMP + StrZero(SG1->(Recno()), 9) + StrZero(nIndex ++, 9) + 'COMP'
ElseIf (nRecCargo := Val(SubStr(cCargo,Len(SG1->G1_COD + SG1->G1_TRT + SG1->G1_COMP) + 1, 9))) > 0
	nRecAnt := SG1->(Recno())
	SG1->(dbGoto(nRecCargo))
	dValIni  := SG1->G1_INI
	dValFim  := SG1->G1_FIM
	nQtdeSG1 := SG1->G1_QUANT
	SG1->(dbGoto(nRecAnt))
EndIf

If GetMV("MV_SELEOPC") == "S" .And. (nRecAnt != nRecCargo .Or. SG1->G1_COMP == cProduto)
   If Len(aOpcPai) > 0
      aOpc := aClone(aOpcPai)
   Else
      cOpc := Padr(SG1->G1_GROPC, TamSX3("G1_GROPC")[1]) + Padr(SG1->G1_OPC, TamSX3("G1_OPC")[1]) + "/"
      aOpc := aClone(ListOpc(Nil,Nil,cOpc))
   EndIf
EndIf

//-- Define as Pastas a serem usadas
cFolderA := 'FOLDER5'
cFolderB := 'FOLDER6'
If Right(cCargo, 4) == 'COMP' .And. ;
	(dDataBase < dValIni .Or. dDataBase > dValFim)
	cFolderA := 'FOLDER7'
	cFolderB := 'FOLDER8'
EndIf

//-- Posiciona no SB1
cPrompt := cProduto + Space(400)
SB1->(dbSetOrder(1))
If SB1->(dbSeek(xFilial('SB1') + cProduto, .F.))
	cPrompt := AllTrim(cProduto) + " - " + SB1->B1_DESC + Space(Len(SB1->B1_COD) - Len(AllTrim(cProduto)))
	cRevAtual := SB1->B1_REVATU
EndIf
cPrompt += Space(Len("QTDE:")+TamSX3("G1_QUANT")[1]) //"QTDE:"
cPrompt += Space(200)

If lM200BMP
	uRet := Execblock("M200BMP", .F., .F., {cPrompt, cFolderA, cFolderB})
	If ValType(uRet) == "A"
		cFolderA := uRet[1]
		cFolderB := uRet[2]
	EndIf
EndIf

//-- Adiciona o Componente na Estrutura
oTree:AddItem(u_xA2Prompt(cPrompt, cCargo, nQtdeSG1,,aOpc), cCargo, cFolderA, cFolderB,,, 2)
oTree:TreeSeek(cCargo)
cCargoPai := cCargo

//-- Se o Componente for Pai, Adiciona sua Estrutura
SG1->(dbSetOrder(1))
If SG1->(dbSeek(xFilial('SG1') + cProduto, .F.))
	Do While !SG1->(Eof()) .And. SG1->G1_FILIAL+SG1->G1_COD == xFilial("SG1")+cProduto .And. ;
		( Empty(cRevAtual) .Or. ( SG1->G1_REVINI <= cRevAtual .And. SG1->G1_REVFIM >= cRevAtual ) )
		nRecAnt  := SG1->(Recno())
		cComp    := SG1->G1_COMP
		cCargo   := SG1->G1_COD + SG1->G1_TRT + SG1->G1_COMP + StrZero(SG1->(Recno()), 9) + StrZero(nIndex ++, 9) + 'COMP'
		nQtdeSG1 := SG1->G1_QUANT
		
		If GetMV("MV_SELEOPC") == "S"
		   cOpc := Padr(SG1->G1_GROPC, TamSX3("G1_GROPC")[1]) + Padr(SG1->G1_OPC, TamSX3("G1_OPC")[1]) + "/"
		   aOpc := aClone(ListOpc(Nil,Nil,cOpc))
		EndIf

		//-- Define as Pastas a serem usadas
		cFolderA := 'FOLDER5'
		cFolderB := 'FOLDER6'
		If dDataBase < SG1->G1_INI .Or. dDataBase > SG1->G1_FIM
			cFolderA := 'FOLDER7'
			cFolderB := 'FOLDER8'
		EndIf

		//-- Posiciona no SB1
		cPrompt := cComp + Space(400)
		SB1->(dbSetOrder(1))
		If SB1->(dbSeek(xFilial('SB1') + cComp, .F.))
			cPrompt := AllTrim(cComp) + " - " + SB1->B1_DESC + Space(Len(SB1->B1_COD) - Len(AllTrim(cComp)))
		EndIf
		cPrompt += Space(Len("QTDE:")+TamSX3("G1_QUANT")[1]) //"QTDE:"
		cPrompt += Space(200)

		If SG1->(dbSeek(xFilial('SG1') + SG1->G1_COMP, .F.))
			//-- Adiciona um Nivel a Estrutura
			xMa200ATree(oTree, SG1->G1_COD, cCargo, , aOpc)
			oTree:TreeSeek(cCargoPai)
		Else
			If lM200BMP
				uRet := Execblock("M200BMP", .F., .F., {cPrompt, cFolderA, cFolderB})
				If ValType(uRet) == "A"
					cFolderA := uRet[1]
					cFolderB := uRet[2]
				EndIf
			EndIf
			//-- Adiciona um Componente a Estrutura
			oTree:AddItem(u_xA2Prompt(cPrompt, cCargo, nQtdeSG1,,aOpc), cCargo, cFolderA, cFolderB,,, 2)
		EndIf

		SG1->(dbGoto(nRecAnt))
		SG1->(dbSkip())
	EndDo
EndIf

oTree:Refresh()
oTree:SetFocus()

RestArea(aAreaAnt)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±?un‡„o    ?Ma200Edita ?Autor ?ernando Joly/Eduardo?Data ?9.05.1999³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±?escri‡„o ?Edi‡„o dos Itens da Estrutura                              ³±?
±±?         ?         			 		                              ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?intaxe   ?Ma200Edita(ExpN1,ExpC1,ExpO1,ExpN2,ExpA1,ExpL1,ExpA2,ExpN3,³±?
±±?		 ?ExpN4,ExpA3)											 	  ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?arametros?ExpN1 = Op‡„o da Edi‡„o                                    ³±?
±±?         ?ExpC1 = Chave do Registro                                  ³±?
±±?         ?ExpO1 = Objeto Tree                                        ³±?
±±?         ?ExpN2 = Op‡„o escolhida no Bot„o                           ³±?
±±?         ?ExpA1 = Array com os Recnos dos Componentes Incl/Excl      ³±?
±±?         ?ExpL1 = variavel logica a ser atualizada na funcao         ³±?
±±?         ?ExpA2 = Array c/ a descendˆncia dos produtos incluidos     ³±?
±±?         ?ExpN3 = qtde. basica                                       ³±?
±±?         ?ExpA3 = tecla de atalho                                    ³±?
±±?         ?ExpA4 = Array con. blo. de cod. que sera exe. pela tecla de³±?
±±?         ?atalho e tecla de atalho,Exeplo: aBkey -> aBkey[bKey][aKey]³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?etorno   ?False caso ocorra algum problema, True C.C. 				  ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?Uso      ?MATA200                                                    ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?*/
Static Function Ma200Edita(nOpcX, cCargo, oTree, nOpcY, aUndo, lMudou, aAltEstru, nQtdBase, aKey, aBKey, aPaiEstru , aAuto)
Local aAreaAnt   := GetArea()
Local aCampos    := {}
Local aAreaSG1   := SG1->(GetArea())
Local aUsrBut 	 := {}
Local aButtons	 := {}
Local nRecno	 := 0
Local nPos       := 0
Local nX         := 0
Local lInclui    := (nOpcY==3 .And. nOpcX#2)
Local lAltera    := (nOpcY==4 .And. nOpcX#2)
Local lExclui    := (nOpcY==5 .And. nOpcX#2)
Local lRet       := .T.
Local cTipo      := ''
Local nUndoRecno := 0
Local cFolderA   := 'FOLDER5'
Local cFolderB   := 'FOLDER6'
Local aDescend   := {}
Local cCargoPai  := ''
Local cPrompt    := ""
Local lM200BMP   := Existblock("M200BMP")
Local uRet       := Nil
Local lRevAut    := SuperGetMv("MV_REVAUT",.F.,.F.) 
Local nInd       := 0   
Local cOpc       := ""
Local aOpc       := {} 
Default aKey     := {}

//-- Variaveis utilizadas nos Ax's
Private aAlter     := {}
Private aAcho      := {}
Private cDelFunc   := 'u_xa200TudoOk("E")'
Private lDelFunc   := .T.
Private cCodPai    := ''                                

If Type('aEndEstrut')=="U"
	Private aEndEstrut := {}
EndIf

//--Desativa teclas de atalho
For nX := 1 to len(aKey)
	Set Key aKey[nX] to
Next nX

aUndo := If(aUndo==Nil,{},aUndo)

//-- Variaveis do Componente Tree referentes ao registro Atual
nRecno := Val(SubStr(cCargo,Len(SG1->G1_COD + SG1->G1_TRT + SG1->G1_COMP) + 1, 9))
cTipo  := Right(cCargo,4)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//?Ponto de entrada para adicionar botoes na enchoice  ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
If ExistBlock( "MA200BUT" )
	If Valtype( aUsrBut := Execblock( "MA200BUT", .f., .f. ) ) == "A"
		AEval( aUsrBut, { |x| AAdd( aButtons, x ) } )
	EndIF
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Ponto de entrada para validar manutenção da estrutura?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "MT200ALCO" )    
	lRet := Execblock( "MT200ALCO", .f., .f. )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Deleta do Array aAcho os campos que n„o devem aparecer       ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
a200Fields(@aAcho)
If (nPos := aScan(aAcho, {|x| 'G1_FILIAL' $ Upper(x)})) > 0
	aDel(aAcho, nPos); aSize(aAcho, Len(aAcho)-1)
EndIf
If (nPos := aScan(aAcho, {|x| 'G1_COD'    $ Upper(x)})) > 0
	aDel(aAcho, nPos); aSize(aAcho, Len(aAcho)-1)
EndIf
If (nPos := aScan(aAcho, {|x| 'G1_NIV'    $ Upper(x)})) > 0
	aDel(aAcho, nPos); aSize(aAcho, Len(aAcho)-1)
EndIf
If (nPos := aScan(aAcho, {|x| 'G1_NIVINV' $ Upper(x)})) > 0
	aDel(aAcho, nPos); aSize(aAcho, Len(aAcho)-1)
EndIf
If (nPos := aScan(aAcho, {|x| 'G1_OK' $ Upper(x)})) > 0
	aDel(aAcho, nPos); aSize(aAcho, Len(aAcho)-1)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Deleta do Array aAlter os campos que n„o devem ser alterados ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAlter := aClone(aAcho)
If lAltera .And. (nPos := aScan(aAlter, {|x| 'G1_COMP' $ Upper(x)})) > 0
	aDel(aAlter, nPos); aSize(aAlter, Len(aAlter)-1)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?osiciona o SG1 no registro a ser editado                               ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTipo # 'NOVO' .And. nRecno <= 0
	Help(' ', 1, 'CODNEXIST')
	lRet	:= .F.
EndIf

dbSelectArea('SG1')
dbSetOrder(1)
dbGoto(If(nRecno>0,nRecno,aAreaSG1[3]))  

If lAltera
	AADD(aValAnt,{nRecno, SG1->G1_TRT, SG1->G1_COMP, ' ', ' ', ' '}) 
	
	//Relaciona as tabelas SGF e SG1
	//SG1 ja esta no array aValAnt de 1 a 3  

	SGF->(dbSeek(xFilial("SGF")+SG1->G1_COD))
	While SGF->(!Eof()) .And. SGF->(GF_FILIAL) == xFilial("SGF") .And. SGF->GF_PRODUTO == SG1->G1_COD   
		If SGF->GF_TRT == SG1->G1_TRT 
			For nInd := 1 To Len(aValAnt)		
				If  aValAnt[nInd][2] == SGF->GF_TRT  .And.;
					aValAnt[nInd][3] == SGF->GF_COMP
					
					aValAnt[nInd][4] := SGF->(RecNo())
					aValAnt[nInd][5] := SGF->GF_TRT
					aValAnt[nInd][6] :=	SGF->GF_COMP			
				EndIf
			Next
		EndIf
		SGF->(dbSkip())
	EndDo 
	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?„o edita o Pai                                                         ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .And. !lInclui .And. (cTipo == 'CODI' .Or. cTipo == 'NOVO')
	Help(' ',1,'REGNOIS') //-- Help NAO PODE EDITAR O PAI
	lRet	:= .F.
EndIf
If lRet
	cCodPai   := If(nRecno>0,If(cTipo=='CODI',SG1->G1_COD,SG1->G1_COMP),cCodAtual)

	cCargoPai := oTree:GetCargo()
		If nOpcX == 3 .Or. nOpcX == 4	//-- Inclui ou Altera
			aDescend := {}
			u_xA2Descen(@cValComp, @aDescend, oTree)
			If lInclui
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//?omando utilizado para habilitar chamada do PE generico em cada chamada ?
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				SetStartMod(.T.)
				INCLUI := .T.
				DbSelectArea('SG1')
				If AxInclui(Alias(),,, aAcho,, aAlter, 'u_xa200TudoOK("I")', , ,aButtons) == 1
					aAdd(aDescend, G1_COMP)
					lMudou := .T.
					Begin Transaction
					RecLock('SG1', .F.)
					Replace G1_COD With cCodPai
					MsUnlock()
					End Transaction
					If aScan(aUndo, {|x| x[1]==Recno()}) == 0
						aAdd(aUndo, {Recno(), 1}) //-- 1=Reg.Incluido/2=Reg.Excluido/3=Reg.Alterado
					EndIf
					//-- Alimenta Array com a Descendˆncia dos Produtos Incluidos
					If Len(aDescend) > 0
						For nX := 1 To Len(aDescend)
							If aScan(aAltEstru, aDescend[nX]) == 0
								aAdd(aAltEstru, aDescend[nX])
							EndIf
						Next nX
					EndIf
					//-- Carrega o array para efetuar a revisao inicial e final de forma automatica
					If lRevAut
						For nX := 1 To IIF(Len(aPaiEstru)=0,1,Len(aPaiEstru))
							If aScan(aPaiEstru, {|x| x[1]==SG1->G1_COD}) == 0
								aAdd(aPaiEstru,{SG1->G1_COD,.T.})
							ElseIF aPaiEstru[nX][1] == SG1->G1_COD
								aPaiEstru[nX][2] := .T.
							EndIf
						Next nX
					EndIf
					If cTipo == 'NOVO'
						oTree:TreeSeek(cCargoPai)
						oTree:DelItem()
						xMa200ATree(oTree, SG1->G1_COD, SG1->G1_COD + SG1->G1_TRT + SG1->G1_COMP + StrZero(SG1->(Recno()),9) + StrZero(nIndex ++, 9) + 'CODI')  
					Else
						xMa200ATree(oTree, SG1->G1_COMP, SG1->G1_COD + SG1->G1_TRT + SG1->G1_COMP + StrZero(SG1->(Recno()),9) + StrZero(nIndex ++, 9) + 'COMP')
					EndIf
					oTree:TreeSeek(cCargoPai)
				Else
					lRet := .F.
				EndIf
				INCLUI := .F.
			ElseIf lAltera
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
				//?Guarda o Status inicial do Registro ?
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
				aCampos := {}
				If aScan(aUndo, {|x| x[1]==Recno()}) == 0
					For nX := 1 To FCount()
						aAdd(aCampos, FieldGet(nX))
					Next nX
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//?omando utilizado para habilitar chamada do PE generico em cada chamada ?
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				SetStartMod(.T.)
				If xAlterG1() //AxAltera(Alias(),,, aAcho, aAlter,,, 'u_xa200TudoOk("A")', , ,aButtons) == 1

					If aScan(aUndo, {|x| x[1]==Recno()}) == 0
						aAdd(aUndo, {Recno(), 3, aCampos}) //-- 1=Reg.Incluido/2=Reg.Excluido/3=Reg.Alterado
					EndIf

					//-- Alimenta Array com a Descendˆncia dos Produtos Alterados
					If Len(aDescend) > 0
						For nX := 1 to Len(aDescend)
							If aScan(aAltEstru, aDescend[nX]) == 0
								aAdd(aAltEstru, aDescend[nX])
							EndIf                         
						Next nX
					EndIf

					//-- Remonta o Prompt do Tree
					SB1->(dbSeek(xFilial("SB1")+SG1->G1_COMP))
					dbSelectArea(oTree:cArqTree)
					RecLock((oTree:cArqTree), .F.)
						Replace T_CARGO With (SG1->G1_COD+SG1->G1_TRT+SG1->G1_COMP+StrZero(SG1->(Recno()),9)+StrZero(nIndex ++, 9)+'COMP')
					MsUnlock()
					
					If GetMV("MV_SELEOPC") == "S"
		                cOpc := Padr(SG1->G1_GROPC, TamSX3("G1_GROPC")[1]) + Padr(SG1->G1_OPC, TamSX3("G1_OPC")[1]) + "/"
		                aOpc := aClone(ListOpc(Nil,Nil,cOpc))
		            EndIf
					
					cCargo  := T_CARGO
					cPrompt := AllTrim(SG1->G1_COMP) + " - " + AllTrim(SB1->B1_DESC)
					cPrompt := AllTrim(u_xA2Prompt(cPrompt,cCargo, SG1->G1_QUANT,,aOpc))
					oTree:ChangePrompt(cPrompt, cCargo)

					//-- Define as Pastas a serem usadas
					cFolderA := 'FOLDER5'
					cFolderB := 'FOLDER6'
					If Right(oTree:GetCargo(), 4) == 'COMP' .And. ;
						(dDataBase < SG1->G1_INI .Or. dDataBase > SG1->G1_FIM)
						cFolderA := 'FOLDER7'
						cFolderB := 'FOLDER8'
					EndIf

					If lM200BMP
						uRet := Execblock("M200BMP", .F., .F., {cPrompt, cFolderA, cFolderB})
						If ValType(uRet) == "A"
							cFolderA := uRet[1]
							cFolderB := uRet[2]
						EndIf
					EndIf

					oTree:ChangeBMP(cFolderA, cFolderB)
				Else
					lRet	:= .F.
				EndIf
			ElseIf lExclui
				u_xA2Desc(SG1->G1_COMP)
				nUndoRecno := Recno()
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//?omando utilizado para habilitar chamada do PE generico em cada chamada ?
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				SetStartMod(.T.)
				If lRevAut
				   IF AxVisual(Alias(), Recno(), 2, aAcho) == 1
				   		nPos:=aScan(aUndo, {|x| x[1]==nUndoRecno})
						If nPos == 0
							aAdd(aUndo, {nUndoRecno, 2}) //-- 1=Reg.Incluido/2=Reg.Excluido/3=Reg.Alterado
						Else
							aUndo[nPos,2]:=2
						EndIf
						oTree:DelItem()
						oTree:Refresh()
						For nX := 1 To Len(aPaiEstru)
							IF aPaiEstru[nX][1] == SG1->G1_COD
								aPaiEstru[nX][2] := .T.
							EndIf
						Next nX
				   EndIf
				Else
					If AxDeleta(Alias(), Recno(), 5, , , aButtons) == 2
						If lDelFunc
							lMudou := .T.
							nPos:=aScan(aUndo, {|x| x[1]==nUndoRecno})
							If nPos == 0
								aAdd(aUndo, {nUndoRecno, 2}) //-- 1=Reg.Incluido/2=Reg.Excluido/3=Reg.Alterado
							Else
								If aUndo[nPos,2] != 1
									aUndo[nPos,2]:=2
								EndIf
							EndIf
							//-- Alimenta Array com a Descendˆncia dos Produtos Alterados
							If Len(aDescend) > 0
								For nX := 1 to Len(aDescend)
									If aScan(aAltEstru, aDescend[nX]) == 0
										aAdd(aAltEstru, aDescend[nX])
									EndIf
								Next nX
							EndIf
							oTree:DelItem()
							oTree:Refresh()
							oTree:SetFocus()
						EndIf
					Else
						lRet := .F.
					EndIf
				EndIf
			EndIf
		ElseIf nOpcX == 2 .Or. nOpcX == 5 //-- Visualiza ou Exclui
			AxVisual(Alias(), Recno(), 2, aAcho)
		EndIf

EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//?Efetua o EndEstrut2 apos o End Transaction                          ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
If lRet .And. Len(aEndEstrut) > 0
	For nX := 1 to Len(aEndEstrut)
		FimEstrut2(aEndEstrut[nX,1],aEndEstrut[nX,3])
	Next nX
	aEndEstrut := {}
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Seta tecla de atalho		                                 ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Ma200StKey(aKey,aBkey)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Restaura Area de trabalho.                                   ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aAreaAnt)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±?
±±?                                                                      ³±?
±±?                                                                      ³±?
±±?                  ROTINAS DE CRITICA DE CAMPOS                        ³±?
±±?                                                                      ³±?
±±?                                                                      ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±?un‡„o    ?a200Codigo ?Autor ?ernando Joly/Eduardo?Data ?9.05.1999³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±?escri‡„o ?Valida‡„o do C?igo do Produto na Estrutura                ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?intaxe   ?A200Codigo(ExpC1,ExpC2,ExpC3,ExpN1,ExpO1,ExpO2,ExpO3,ExpO4)³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?arametros?ExpC1 = C?igo a ser Validado                              ³±?
±±?         ?ExpC2 = Unidade de Medida a ser Atualizada                 ³±?
±±?         ?ExpC3 = Numero da Revis„o a ser atualizado                 ³±?
±±?         ?ExpN1 = qtde. basica digitada		               		  ³±?
±±?         ?ExpO1 = objeto da unidade de medida 		           		  ³±?
±±?         ?ExpO2 = objeto da revisao           		           		  ³±?
±±?         ?ExpO3 = objeto da qtde. basica			           		  ³±?
±±?         ?ExpO4 = objeto Dlg                 		           		  ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?etorno   ?True para C?igos Validos e False para C?igos Inv lidos   ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?Uso      ?MATA200                                                    ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?*/
User Function xA200Codigo(cProduto, cUm, cRevisao, nQtdBase, oUm, oRevisao, oQtdBase, oDlg,_cCodAuto)

Local aAreaAnt   := GetArea()
Local aAreaSB1   := SB1->(GetArea())
Local aAreaSG1   := SG1->(GetArea())
Local lRet       := .T.
Local lRetPE
Local cQuery	 := ""
SB1->(dbSetOrder(1))
If !SB1->(dbSeek(xFilial('SB1') + cProduto, .F.))
	Help(' ',1, 'NOFOUNDSB1')
	lRet := .F.
   	if ! __lPyme .and. !l200Auto
		oButton1:Disable()
	Endif
Else
	IF _cCodAuto <> cProduto
		MsgInfo('Produto n? deve ser alterado. Montagem de estrutura '+_cCodAuto,'Atenção')
		Return(.F.)		
	ENDIF
	
	cUm         := SB1->B1_UM
	cRevisao    := SB1->B1_REVATU
	nQtdBasePai := nQtdBase := RetFldProd(SB1->B1_COD,"B1_QB")
	If oUm # Nil
		oUm:Refresh()
	EndIf
	If oRevisao # Nil
		oRevisao:Refresh()
	EndIf
	If oQtdBase # Nil
		oQtdBase:Refresh()
	EndIf
EndIf

If lRet .And. !ldbTree
	If oDlg # Nil
		oDlg:Refresh()
	EndIf
	SG1->(dbSetOrder(1))
	If SG1->(dbSeek(xFilial('SG1') + cProduto, .F.))
		Help(' ',1, 'CODEXIST')
		lRet := .F.
		if ! __lPyme .and. !l200Auto
			oButton1:Disable()
		Endif
	EndIf

	If lRet .And. !GetMV('MV_NEGESTR')
		SG1->(dbSetOrder(2))

		cQuery	:= "SELECT COUNT(*) TOTREC FROM "+RetSqlName('SG1')
		cQuery	+= " WHERE "
		cQuery	+= " G1_FILIAL = '"+xFilial("SG1")+"' AND "
		cQuery	+= " G1_COMP = '"+cProduto+"' AND "
		cQuery	+= " G1_QUANT  < 0 AND "
		cQuery	+= " D_E_L_E_T_ <> '*'"
		cQuery := ChangeQuery(cQuery)
		dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRYSG1",.F.,.T.)
	    If QRYSG1->TOTREC > 0
			Help(' ',1,'A200NAOINC')
			lRet := .F.
			if ! __lPyme .and. !l200Auto
				oButton1:Disable()
			Endif
	    EndIf
	    QRYSG1->(dbCloseArea())
	EndIf
EndIf

If lRet .And. IsProdProt(cProduto) .And. !IsInCallStack("DPRA340INT")
	Aviso('Prot?ipos podem ser manipulados somente atrav? do m?ulo Desenvolvedor de Produtos (DPR).','Atencao',{"OK"}) //-- Prot?ipos podem ser manipulados somente atrav? do m?ulo Desenvolvedor de Produtos (DPR).
	lRet := .F.
EndIf

If lRet .And. !__lPyme .and. !l200Auto
	oButton1:Enable()
EndIf

If lRet
	If ExistBlock("MT200PAI")
		lRetPE := ExecBlock("MT200PAI",.F.,.F.,cProduto)
		lRet   := IIF(ValType(lRetPE)=="L",lRetPE,lRet)
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Restaura Area de trabalho.                                   ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aAreaSG1)
RestArea(aAreaSB1)
RestArea(aAreaAnt)
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±?un‡„o    ?a200CodSim ?Autor ?ernando Joly/Eduardo?Data ?9.05.1999³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±?escri‡„o ?Valida Estrutura Similar                                   ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?intaxe   ?a200CodSim(ExpC1,ExpC2,ExpA1)                              ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?arametros?ExpC1 = C?igo do Produto                                  ³±?
±±?         ?ExpC2 = C?igo do Produto Similar                          ³±?
±±?         ?ExpA1 = Array com os recnos                                ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?etorno   ?True se a Estrutura Silinar for Validada, ou False ne n„o. ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?Uso      ?MATA200                                                    ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?*/
Static Function A200CodSim(cProduto, cCodSim, aUndo)
Local lRet		 := .T.
Local aAreaAnt   := GetArea()
Local aAreaSB1   := SB1->(GetArea())
Local aAreaSG1   := SG1->(GetArea())
Local cNomeArq   := ''
Local oTempTable := nil

Private nEstru   := 0

If !Empty(cCodSim)

	SB1->(dbSetOrder(1))
	If !SB1->(dbSeek(xFilial('SB1') + cCodSim))
		Help(' ',1,'NOFOUNDSB1')
		lRet := .F.
	EndIf

	SG1->(dbSetOrder(1))
	If lRet .And. !SG1->((dbSeek(xFilial('SG1') + cCodSim)))
		Help(' ',1,'ESTNEXIST')
		lRet := .F.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//?Verifica se o produto similar n„o contem o      ?
	//?produto principal em sua estrutura.             ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	If lRet
		cNomeArq := Estrut2(cCodSim,,,@oTempTable)
		dbSelectArea('ESTRUT')
		ESTRUT->(dbGotop())
		Do While !ESTRUT->(Eof())
			If ESTRUT->COMP == cProduto
				Help(' ',1,'SIMINVALID')
				lRet := .F.
				Exit
			EndIf
			ESTRUT->(dbSkip())
		EndDo

		If lRet
			FimEstrut2(Nil,oTempTable)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//?Restaura Area de trabalho.                                   ?
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RestArea(aAreaSG1)
			RestArea(aAreaSB1)
			RestArea(aAreaAnt)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//?Gera Registros da Estrutura Similar                          ?
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			u_xMa200GrSim(cProduto, cCodSim, @aUndo)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//?Ponto de Entrada para alteracao da Estrutura Similar         ?
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ExistBlock('MT200CSI')
				//-- Sao passados os seguintes parametros:
				//-- aParamIXB[1] = Codigo do Produto
				//-- aParamIXB[2] = Codigo do Produto Similar
				ExecBlock('MT200CSI', .F., .F., {cProduto, cCodSim})
			EndIf
		EndIf
	EndIf
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±?un‡„o    ?200GetRev  ?Autor ?ernando Joly/Eduardo?Data ?9.05.1999³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±?escri‡„o ?Indica se d  Get na revis? da estrutura ou n„o            ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?intaxe   ?A200GetRev(ExpL1,ExpO1,ExpO2,ExpC1,ExpC2,ExpN1)            ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?arametros?ExpL1 = Variavel L?ica a ser atualizada na fun‡„o         ³±?
±±?         ?ExpO1 = Objeto Dlg                                         ³±?
±±?         ?ExpO2 = Objeto Tree                                        ³±?
±±?         ?ExpC1 = codigo produto                                     ³±?
±±?         ?ExpC2 = revisao                                            ³±?
±±?         ?ExpN1 = Op‡„o Escolhida                                    ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?etorno   ?True                                                       ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?Uso      ?MATA200                                                    ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?*/
User Function xA200GetRev(lGetRevisao, oDlg, oTree, cProduto, cRevisao, nOpcX, lReAuto, aPaiEstru)
Default lReAuto   := .F.
Default aPaiEstru := {}

lGetRevisao := !lGetRevisao
ldbTree	:= .T.
cCodAtual := cProduto
cValComp  := cProduto + '?'
xMa200Monta(oTree, oDlg, cCodAtual, '', cRevisao, nOpcX)
IF lReAuto
	SG1->(DbSetOrder(1))
	If SG1->(dbSeek(xFilial("SG1")+cCodAtual))
		If aScan(aPaiEstru, {|x| x[1]==SG1->G1_COD}) == 0
			aAdd(aPaiEstru,{cCodAtual,.F.})
		EndIf
	EndIf
EndIf
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±?un‡„o    ?A200QBase  ?Autor ?ernando Joly/Eduardo?Data ?9.05.1999³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±?escri‡„o ?Consiste a Quantidade Basica da Estrutura                  ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?intaxe   ?A200QBase(ExpN1,ExpN2,ExpC1,ExpC2,ExpO1,ExpO2)             ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?arametros?ExpN1 = Quantidade Basica Digitada                         ³±?
±±?         ?ExpN2 = Op‡„o Escolhida                                    ³±?
±±?         ?ExpC1 = codigo produto                                     ³±?
±±?         ?ExpC2 = codigo produto similar                             ³±?
±±?         ?ExpO1 = Objeto Tree                                        ³±?
±±?         ?ExpO2 = Objeto Dlg                                         ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?etorno   ?True se a Quantidade Base for Maior que Zero, ou False C.C.³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?Uso      ?MATA200                                                    ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?*/
USer Function xA200QBase(nQtdBase, nOpcX, cProduto, cCodSim, oTree, oDlg)
Local lRet := .T.
If QtdComp(nQtdBase) < QtdComp(0) .And. !GetMV('MV_NEGESTR')
	Help(' ',1,'MA200QBNEG')
	lRet := .F.
EndIf

If lRet
	nQtdBasePai := M->G1_QUANT := nQtdBase

	If !ldbTree .And. !l200Auto
		ldbTree := .T.
		If nOpcX < 5
			cCodAtual := cProduto
			cValComp  := cProduto + '?'
			xMa200Monta(oTree, oDlg, cCodAtual, cCodSim,, nOpcX)
			oTree:TreeSeek(oTree:GetCargo())
		EndIf
	EndIf
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±?un‡„o    ? A200Comp  ?Autor ?ernando Joly/Eduardo?Data ?9.05.1999³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±?escri‡„o ?Valida o c?igo do componente na Estrutura                 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?intaxe   ?A200Comp()                                                 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?arametros?Nenhum                                                     ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?etorno   ?True caso o c?igo seja validado e False em caso contr rio ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?Uso      ?MATA200                                                    ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?*/
User Function xa200Comp()

Local lRet := .T.

lRet := A2ChkNod(M->G1_COMP, cValComp)
If lRet
	lRet := u_xA200Codigo(M->G1_COMP, '', 0, 0)
	If lRet
		lRet := A200OutPai(M->G1_COMP, cValComp)
	EndIf
EndIf

If lRet .And. IsProdProt(M->G1_COMP) .And. !IsInCallStack("DPRA340INT")
	Aviso('Prot?ipos podem ser manipulados somente atrav? do m?ulo Desenvolvedor de Produtos (DPR).','Atencao',{"OK"}) //-- Prot?ipos podem ser manipulados somente atrav? do m?ulo Desenvolvedor de Produtos (DPR).
	lRet := .F.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±?un‡„o    ?A2ChkNod ?Autor ?ernando Joly/Eduardo?Data ?9.05.1999³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±?escri‡„o ?Verifica existencia de um mesmo c?igo em um n?da estrutur³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?intaxe   ?A2ChkNod(ExpC1,ExpC2) 	                                  ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?arametros?ExpC1 = C?igo a ser pesquisado                            ³±?
±±?         ?ExpC2 = Lista de C?igos a ser pesquizada                  ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?etorno   ?.T. / .F.                                                  ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?Uso      ?MATA200                                                    ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?*/
Static Function A2ChkNod(cProduto, cLista)

Local aAreaAnt := GetArea()
Local aAreaSG1 := SG1->(GetArea())
Local cNomeArq := ''
Local cNomeAli := ''
Local lRet     := .T.
Local oTempTable := nil

Private nEstru := 0

If cProduto $(cLista)
	Help(' ',1,'A200NODES')
	lRet := .F.
EndIf

//-- Verifica se o Produto possui Estrutura
If lRet
	dbSelectArea('SG1')
	dbSetorder(1)
	If dbSeek(xFilial('SG1') + cProduto, .F.)
		nNAlias ++
		cNomeAli := "ES"+StrZero(nNAlias,3)
		cNomeArq := Estrut2(cProduto, 1,cNomeAli,@oTempTable)
		dbSelectArea(cNomeAli)
		dbGoTop()
		Do While !Eof() .And. lRet
			If COMP $(cLista)
				Help(' ',1,'A200NODES')
				lRet := .F.
				Exit
			EndIf
			dbSkip()
		EndDo
		If Type('aEndEstrut') == 'A'
			aAdd(aEndEstrut,{cNomeAli,cNomeArq,oTempTable})
		Else
			FimEstrut2(Nil, oTempTable)
		EndIf
	EndIf
EndIf

RestArea(aAreaSG1)
RestArea(aAreaAnt)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±?un‡„o    ?200OutPai  ?Autor ?ernando Joly/Eduardo?Data ?9.05.1999³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±?escri‡„o ?Verifica a existencia de uma mesmo c?igo em um n?da estru³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?intaxe   ?A200OutPai(ExpC1,ExpC2)		                              ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?arametros?ExpC1 = C?igo a ser pesquizado                            ³±?
±±?         ?ExpC2 = Lista de C?igos a ser pesquizada                  ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?etorno   ?False caso encontre um c?igo repetido e True em C.C.      ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?Uso      ?MATA200                                                    ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?*/
Static Function A200OutPai(cProduto, cLista)

Local cPai   := Substr(cLista,1,15)
Local nRecno := Recno()
Local nOrdem := IndexOrd()
Local lRet   := .T.

SG1->(dbSetOrder(2))
SG1->(dbSeek(xFilial('SG1')+cPai))
Do While !SG1->(Eof()) .And. SG1->G1_FILIAL == xFilial("SG1")
	If SG1->G1_COD == cProduto
		Help(' ',1,'A200NODES2',,cProduto,2,26)
		lRet := .F.
		Exit
	EndIf
	SG1->(dbSeek(xFilial('SG1')+SG1->G1_COD))
EndDo
dbSetOrder(1)

dbSetOrder(nOrdem)
dbGoto(nRecno)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±?un‡„o    ?A200Desc   ?Autor ?odrigo de A.Sartorio?Data ?9.05.1999³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±?escri‡„o ?Posiciona no produto desejado e preenche descricao		  ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?intaxe   ?A200Desc(ExpC1)                                            ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?arametros?ExpC1 = Codigo do Produto a ser pesquizado                 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?etorno   ?False caso encontre um c?igo repetido e True em C.C.      ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?Uso      ?MATA200                                                    ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?*/
User Function xA2Desc(cCod)

Local aAreaAnt := GetArea()
Local lRet     := .T.

cCod := If(cCod==Nil,M->G1_COMP,cCod)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//?Posiciona no produto desejado e preenche descricao      ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
If SB1->(dbSeek(xFilial('SB1')+cCod, .F.))
	M->G1_DESC := SB1->B1_DESC
Else
	Help(' ', 1, 'NOFOUNDSB1')
	lRet := .F.
EndIf

RestArea(aAreaAnt)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±?un‡„o    ?MA200Quant ?Autor ?ernando Joly/Eduardo?Data ?9.05.1999³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±?escri‡„o ?Valida‡„o da quantidade do Produto na Estrutura            ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?intaxe   ?Ma200Quant(ExpN1, ExpC1)                                   ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?arametros?ExpN1 = Quantidade a ser validada                          ³±?
±±?         ?ExpC1 = Codigo do Produto                                  ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?etorno   ?False caso o valor nao possa ser negativo, e True em C.C.  ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?Uso      ?MATA200                                                    ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?*/
USer Function xMA200Quant(nQuant,cCod)

Local nVar       := 0
Local lRet       := .T.
Local cAlias     := ''
Local nRecno     := 0
Local nOrder     := 0

nVar := If(nQuant==Nil,&(ReadVar()),nQuant)

If IsProdMod(cCod) .And. GetMV('MV_TPHR') == 'N'
	nVar := nVar - Int(nVar)
	If nVar > .5999999999
		HELP(' ',1,'NAOMINUTO')
		lRet := .F.
	EndIf
ElseIf QtdComp(nVar) < QtdComp(0) .And. !GetMV('MV_NEGESTR')
	Help(' ',1,'A200NAONEG')
	lRet := .F.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±?un‡„o    ?MA200Fecha ?Autor ?ernando Joly/Eduardo?Data ?9.05.1999³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±?escri‡„o ?Retorna a Integridade do Sistema apos a finaliza‡„o        ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?intaxe   ?Ma200Fecha(ExpO1,ExpO2,ExpN1,ExpL1,ExpC1,ExpC2,ExpN1 ...   ³±?
±±?         ?       ... ExpC3,ExpL2,ExpA1,ExpA2,ExpA3)                  ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?arametros?ExpO1 = Objeto Dlg                                         ³±?
±±?         ?ExpO2 = Objeto Tree                                        ³±?
±±?         ?ExpN1 = numero da opcao                                    ³±?
±±?         ?ExpL1 = indica se mudou                                    ³±?
±±?         ?ExpC1 = unidade de medida                                  ³±?
±±?         ?ExpC2 = produto                                            ³±?
±±?         ?ExpN1 = qtde. basica digitada                              ³±?
±±?         ?ExpC3 = revisao                                            ³±?
±±?         ?ExpL2 = indica se atualiza o campo B1_QB na confirmacao    ³±?
±±?         ?ExpA1 = Array c/ a descendˆncia dos produtos incluidos     ³±?
±±?         ?ExpA2 = tecla de atalho                                    ³±?
±±?         ?ExpA3 = Array con. blo. de cod. que sera exe. pela tecla de³±?
±±?         ?atalho e tecla de atalho,Exeplo: aBkey -> aBkey[bKey][aKey]³±?
±±?         ?ExpA4 = Array com os produtos alterados                    ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?etorno   ?False caso ocorra algum problema no fechamento, True C.C.  ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?Uso      ?MATA200                                                    ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?*/
Static Function Ma200Fecha(oDlg, oTree, nOpcX, lMudou, cUm, cProduto, nQtdBase, cRevisao, lConfirma, aAltEstru, aKey, aBKey, aUndo,aPaiEstru)

Local lRet       := .T.
Local cLinha1    := "Cada altera‡„o em uma estrutura pode gerar uma nova revis„o para"+CHR(13)	//"Cada altera‡„o em uma estrutura pode gerar uma nova revis„o para"
Local cLinha2    := "o controle hist?ico de altera‡”es em determinado produto."+CHR(13)	//"o controle hist?ico de altera‡”es em determinado produto."
Local cLinha3    := "A altera‡„o deve gerar uma nova revis„o para esta estrutura ?"+CHR(13)	//"A altera‡„o deve gerar uma nova revis„o para esta estrutura ?"
Local cTitulo    := "Revis„o Estrutura"	//"Revis„o Estrutura"
Local aAreaTRB   := {}
Local aAreaSB1   := {}
Local cCod       := ''
Local cCodPai    := ''
Local cTipo      := ''
Local cAliasAnt  := ''
Local aExplode   := {}
Local aPai       := {}
Local nX         := 0
Local nY         := 0
Local nPos       := 0
Local nQuant     := 0
Local nQuant1    := 0
Local nQtdNivel  := 0
Local lMap       := .F.
Local nCount     := 0
Local nBarra     := 0
Local cFile      := ''
Local cArqTrab   := ''
Local lIniMap    := .F.
Local lContinua	 := .T.
Local lRetPE     := .T.
Local cConsidUM  := SuperGetMV( "MV_CONSDUM",.F., "KG" )
Local cAliasB1BZ := If(GetMv('MV_ARQPROD')=="SBZ","SBZ","SB1")
Local lAltRev	 := GetNewPar("MV_ALTREV",.F.)
Local lRevAut    := SuperGetMv("MV_REVAUT",.F.,.F.)
Local lDadosSBZ  := .F.
Local cCargo	 := ''
Local nRecno     := 0  
Local nInd       := 0

Private lGravaRev  := .T.
Default aKey 	 :={}
Default aUndo	 := {}
Default aPaiEstru := {}
If ( Type("aRecDel") == "U" )
	PRIVATE aRecDel := {}
EndIf

//--Desativa Tecla de atalho
For nX := 1 to len(aKey)
	Set Key aKey[nX] to
Next nX

If lConfirma
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//?tualiza o campo B1_QB na Confirma‡„o da Inclus„o/Altera‡??
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	If nOpcX == 3 .Or. nOpcX == 4
		cAliasAnt := Alias()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//?osiciona SB1 no codigo pai                                ?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		If cAliasB1BZ == "SBZ"
			dbSetOrder(1)
			SB1->(MsSeek(xFilial('SB1')+cProduto))
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//?osiciona SB1 ou no SBZ                                    ?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		lDadosSBZ:=RetArqProd(cProduto)

		dbSelectArea(cAliasB1BZ)
		aAreaSB1 := SB1->(GetArea())
		dbSetOrder(1)
		MsSeek(xFilial(cAliasB1BZ) + cProduto)

		If RetFldProd(SB1->B1_COD,"B1_QB") # nQtdBase
			Begin Transaction
				If !lDadosSBZ 
					RecLock('SBZ')
					Replace SBZ->BZ_QB With nQtdBase
					MsUnlock()
				Else
					RecLock('SB1')
					Replace SB1->B1_QB With nQtdBase
					MsUnlock()
				EndIf
			End Transaction
		EndIf
		RestArea(aAreaSB1)
		dbSelectArea(cAliasAnt)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//?Atualiza o campo B1_UREV                                  ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	If mv_par01 == 1 .And. nOpcX > 2 .And. Len(aAltEstru) > 0
		Begin Transaction
			For nX := 1 to Len(aAltEstru)
				If SB1->(dBSeek(xFilial('SB1') + aAltEstru[nX], .F.))
					RecLock('SB1')
					Replace B1_UREV With dDataBase
					MsUnlock()
				EndIf
			Next nX
		End Transaction
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//?Atualiza arquivo de Operacoes x Componentes caso haja exclusao de componentes?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	
	If Len(aUndo) > 0
		For nY := 1 To Len(aUndo)
			If aUndo[nY][2] == 2
				SG1->(DbGoTo(aUndo[ny][1]))
				SGF->(dbSeek(xFilial("SGF")+SG1->G1_COD))
				While SGF->(!Eof()) .And. SGF->(GF_FILIAL) == xFilial("SGF") .And. SGF->GF_PRODUTO == SG1->G1_COD .And. SGF->GF_TRT == SG1->G1_TRT
					If SGF->GF_COMP == SG1->G1_COMP
						RecLock('SGF',.F.)
						SGF->(DbDelete())
						MsUnlock()
					EndIf
					SGF->(dbSkip())
				EndDo
			EndIf
			If aUndo[nY][2] == 3
				SG1->(DbGoTo(aUndo[ny][1]))
				SGF->(dbSeek(xFilial("SGF")+SG1->G1_COD))
				While SGF->(!Eof()) .And. SGF->(GF_FILIAL) == xFilial("SGF") .And. SGF->GF_PRODUTO == SG1->G1_COD
					If SGF->GF_COMP == SG1->G1_COMP 
						For nInd := 1 To Len(aValAnt)
							If !empty(aValAnt[nInd][4]) .And. !empty(aValAnt[nInd][1])
								If aValAnt[nInd][4] == SGF->(RecNo()) .And. aValAnt[nInd][1] == SG1->(RecNo()) 
									RecLock('SGF',.F.)
									SGF->GF_TRT := SG1->G1_TRT
									MsUnlock()
								EndIf
							EndIf
						next										
					EndIf
					SGF->(dbSkip())
				EndDo
			EndIf
		Next
	EndIf   
	
	aValAnt   := {}
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//?Grava Revisao Estrutura caso atualize arquivo de revisoes ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	If nOpcX > 2 .And. (MV_PAR02 == 1 .Or. lRevAut)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//?P.E. para Gerar ou nao uma nova revisao para a estrutura sem a apresentacao do Aviso. ?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		If ExistBlock("MT200GRE")
			lRetPE := ExecBlock("MT200GRE",.F.,.F.)
			lGravaRev := IIF(ValType(lRetPE)=="L",lRetPE,lGravaRev)
        Else
			TONE(3500,1)
			If Len (aUndo) > 0 .And. (MV_PAR02 == 1 .Or. lRevAut)
				If l200Auto .Or. lRevAut
					lGravaRev := .T.
				Else
					lGravaRev := (MsgYesNo(OemToAnsi(cLinha1+cLinha2+cLinha3),OemToAnsi(cTitulo)))
				EndIf
			EndIf
        EndIf

		If lGravaRev
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//?Atualiza o cadastro de revisoes da estrutura ?
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !lRevAut
				If Len (aUndo) > 0
			   		cRevisao := u_xA2Revis(cProduto)
			 	EndIf
				If lAltRev .And. !l200Auto .And. (nOpcX == 4 .Or. nOpcX == 3)
					If Len( aUndo ) > 0
						A200AltRev( aUndo )
					Endif
				Endif
			Else
				nRecno := SG1->(Recno())
				For nY := 1 To Len(aUndo)
					SG1->(dbGoto(aUndo[nY][1]))
					If aUndo[nY][2] == 2
						If SG1->(dbSeek(xFilial("SG1")+SG1->G1_COD))
							If aScan(aPaiEstru, {|x| x[1]==SG1->G1_COD}) == 0
								aAdd(aPaiEstru,{SG1->G1_COD,.T.})
							EndIf
						EndIf
					EndIf
				Next nY
				SG1->(dbGoto(nRecno))

				Begin Transaction
				For nX := 1 to Len(aPaiEstru)
					If aPaiEstru[nx,2]
						cRevisao := u_xA2Revis(aPaiEstru[nx,1],,lRevAut)
						SG1->(dbSetOrder(1))
						SG1->(dbSeek(xFilial("SG1")+aPaiEstru[nX,1]))
						While !SG1->(EOF()) .And. SG1->(G1_FILIAL+G1_COD) == xFilial("SG1")+aPaiEstru[nX,1]
							If !SG1->(A200RevDel(G1_COD,G1_COMP,G1_TRT,aUndo))
								If l200Auto .Or. Right(oTree:GetCargo(),4) == 'COMP' .Or. (Right(oTree:GetCargo(),4) == 'CODI' .And. oTree:Nivel() == 1)
									If (nY := aScan(aUndo,{|x| x[1] == SG1->(Recno())})) == 0 .Or. aUndo[nY,2] # 2
										RecLock('SG1',.F.)
								 		If Empty(SG1->G1_REVINI) .And. SG1->G1_REVFIM == 'ZZZ'
											Replace SG1->G1_REVINI With cRevisao
											Replace SG1->G1_REVFIM With cRevisao
										ElseIf (Val(cRevisao)-Val(SG1->G1_REVFIM)) < 2
											Replace SG1->G1_REVFIM With cRevisao
										EndIf
										SG1->(MsUnlock())
									EndIf
								Else
									If !Vazio(cCodSim) .And. !Vazio(cRevSim) .And. nOpcX == 3
										If (nY := aScan(aUndo,{|x| x[1] == SG1->(Recno())})) == 0 .Or. aUndo[nY,2] # 2
											RecLock('SG1',.F.)
											If Empty(SG1->G1_REVINI) .And. SG1->G1_REVFIM == 'ZZZ'
												Replace SG1->G1_REVINI With cRevisao
												Replace SG1->G1_REVFIM With cRevisao
											ElseIf (Val(cRevisao)-Val(SG1->G1_REVFIM)) < 2
												Replace SG1->G1_REVFIM With cRevisao
											EndIf
												SG1->(MsUnlock())
										EndIf
									EndIf
								EndIf
							ElseIf Empty(SG1->G1_REVINI) .And. SG1->G1_REVFIM == 'ZZZ'
								RecLock('SG1',.F.)
					 			SG1->(dbDelete())
								SG1->(MsUnlock())
							EndIf
							SG1->(dbSkip())
							If !l200Auto
								oTree:SetFocus()
							EndIf
						End
					EndIf
				Next nX
				End Transaction
			EndIf
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//?Mapa de Divergencias                                      ?
	//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//?lIniMap = Habilita/Desabilita o Mapa de Divergencias      ?
	//?lIniMap == .T. - Habilita                                 ?
	//?lIniMap == .F. - Desabilita                               ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//?P.E. MT200MAP - Validar a rotina do Mapa de Divergencias. ?
	//?Parametros Enviados:                                      ?
	//?PARAMIXB[1] = Cod.Produto                                 ?
	//?PARAMIXB[2] = Unidade de Medida                           ?
	//?PARAMIXB[3] = Quantidade Base                             ?
	//?PARAMIXB[4] = Revisao                                     ?
	//?PARAMIXB[5] = Opcao Selecionada                           ?
	//?PARAMIXB[6] = Contador                                    ?
	//?Retorno     = Logico                                      ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?

	If (lIniMap := ExistBlock("MT200MAP"))
		lIniMap := ExecBlock("MT200MAP",.F.,.F.,{cProduto,cUm,nQtdBase,cRevisao,nOpcx,nCount})
		If ValType(lIniMap) <> "L"
			lIniMap := .T.
		Endif
		lIniMap := !lIniMap
	EndIf

	If !l200Auto .And. nOpcX < 5 .And. AllTrim(Upper(cUm)) $ Upper(cConsidUM) .And. !lIniMap

		u_xA2IniMap(nQtdBase, oTree)

		aExplode := {}
		Explode(cProduto, @aExplode, cRevisao, @nCount, oTree)

		aPai := {}
		For nX := 1 to Len(aExplode)
			If (nPos := aScan(aPai, {|x| x[2] == aExplode[nX, 2]})) == 0
				aAdd(aPai, {1, aExplode[nX, 2]})
			ElseIf nPos > 0
				aPai[nPos, 1]++
			EndIf
		Next nX

		cCodPai   := cProduto
		nQtdNivel := CriaVar('B1_QB')
		For nX:=1 to Len(aPai)
			nQuant1 := CriaVar('B1_QB')
			If aPai[nX, 2] # cCodPai
				nPos   := aScan(aExplode,{|x| x[3] == aPai[nX, 2]})
				nQuant := If(nPos>0,aExplode[nPos, 4],0)
				For nY := 1 to Len(aExplode)
					If aExplode[nY, 2] == aPai[nX, 2]
						nQuant1 += aExplode[nY, 4]
					EndIf
				Next nY
				If nQuant1 # nQuant
					lMap := .T.
				EndIf
			Else
				For nY := 1 to Len(aExplode)
					If aExplode[nY, 2] == cCodPai
						nQuant1 += aExplode[nY, 4]
					EndIf
				Next nY
				If nQuant1 # nQtdBase
					lMap := .T.
					nQtdNivel += nQuant1
					Exit
				Else
					nQtdNivel += nQuant1
				EndIf
			EndIf
		Next nX

		If lMap
			lContinua := A200ShowMap(nQtdNivel)
			If ExistBlock("MT200DIV")
				lRetPE := ExecBlock("MT200DIV",.F.,.F.,{cProduto,@oTree})
				If ValType(lRetPE) == "L"
					lContinua := lRetPE
				EndIf
			EndIf
		EndIf
	EndIf

	If lContinua
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//?Seta o parametro MV_NIVALT                                ?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		If lMudou .And. (nOpcX > 2 .And. nOpcX <= 5)
			If lMudou .And. nOpcx == 4
				If a630SeekSG2(3,cProduto,xFilial("SG2")+cProduto) .And. !l200Auto
					Help(" ",1,"A200ALTROT")
				EndIf
			EndIf
			u_xa2NivAlt()
		EndIf

		For nX := 1 to Len(aRegsSGF)
			A635VldGrava(aRegsSGF[nX, 1], aRegsSGF[nX, 2], aRegsSGF[nX, 3], aRegsSGF[nX, 4], aRegsSGF[nX, 5], .T., .F.)
		Next

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//?Executa Ponto de Entrada na Grava‡„o da Estrutura         ?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		If ExistBlock('A200GrvE')
			Execblock('A200GrvE',.F.,.F.,{nOpcx,lMap,aRecDel,aUndo})
		EndIf
	EndIf
EndIf

If lContinua
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//?Deleta o 5o Indice de Trabalho do arquivo dbTree                    ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	If !Empty(cInd5) .And. File(cInd5+OrdBagExt()) .And. ValType(oTree)=='O'
		cArqTrab := oTree:cArqTree
		dbSelectArea(cArqTrab)
		dbClearIndex()
		fErase(cInd5+OrdBagExt())
		cInd5 := ''
		dbSetIndex(SubStr(cArqTrab,2)+'A'+OrdBagExt())
		dbSetIndex(SubStr(cArqTrab,2)+'B'+OrdBagExt())
		dbSetIndex(SubStr(cArqTrab,2)+'C'+OrdBagExt())
		dbSetIndex(SubStr(cArqTrab,2)+'D'+OrdBagExt())
		dbSetOrder(1)
	EndIf

	If oDlg # Nil .And. oTree # Nil
		Release Object oTree
		oDlg:End()
	Endif
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Seta tecla de atalho                                         ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Ma200StKey(aKey,aBkey)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±?un‡„o    ?MA200Del   ?Autor ?ernando Joly/Eduardo?Data ?9.05.1999³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±?escri‡„o ?Deleta a Estrutura Atual                                   ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?intaxe   ?Ma200Del(ExpC1, ExpN1, ExpA1)                              ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?arametros?ExpC1 = Codigo do Produto                                  ³±?
±±?         ?ExpA1 = tecla de atalho                                    ³±?
±±?         ?ExpA2 = Array con. blo. de cod. que sera exe. pela tecla de³±?
±±?         ?atalho e tecla de atalho,Exeplo: aBkey -> aBkey[bKey][aKey]³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?etorno   ?False caso ocorra algum problema na Dele‡„o, True C.C.     ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?Uso      ?MATA200                                                    ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?*/
User Function xMa200Del(cProduto, aKey, aBkey)

Local aAreaAnt   := GetArea()
Local cSeek      := xFilial('SG1')+cProduto
Local aDelet     := {}
Local nX         := 0
Local lRet       := .T.
Default aKey     := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Execblock MTA200 verif. permiss? de exclus? na browse alem do detalhe da estrutura
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock('MTA200')
	if  ExecBlock('MTA200',.F.,.F.) = .F.
   	  return .F.
	EndIf
Endif

If ( Type("aRecDel") == "U" )
	PRIVATE aRecDel := {}
EndIf

//--Desativa tecla de atalho
For nX := 1 to len(aKey)
	Set Key aKey[nX] to
Next nX

dbSelectArea('SG1')
dbSetOrder(1)
If !(lRet:=dbSeek(cSeek, .F.))
	Help(' ', 1, 'REGNOIS')
Else
	Do While !Eof() .And. G1_FILIAL+G1_COD == cSeek
		aAdd(aDelet, Recno())
		dbSkip()
	EndDo
	aRecDel:= aClone(aDelet)
	Begin Transaction
		For nX := 1 to Len(aDelet)
			dbGoto(aDelet[nX])
			RecLock('SG1', .F., .T.)
			dbDelete()
			MsUnlock()
		Next nX
  	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//?Atualiza arquivo de Operacoes x Componentes caso haja exclusao da estrura	 ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX := 1 to Len(aDelet)
			SG1->(DbGoTo(aDelet[nX]))
			SGF->(dbSeek(xFilial("SGF")+SG1->G1_COD))
			While SGF->(!Eof()) .And. SGF->(GF_FILIAL) == xFilial("SGF") .And. SGF->GF_PRODUTO == SG1->G1_COD
		   		RecLock('SGF',.F.)
				SGF->(DbDelete())
				MsUnlock()
				SGF->(dbSkip())
			EndDo
		Next
	End Transaction
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Seta tecla de Atalho                                         ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Ma200StKey(aKey,aBkey)

RestArea(aAreaAnt)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±?un‡„o    ?MA200Undo  ?Autor ?ernando Joly/Eduardo?Data ?9.05.1999³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±?escri‡„o ?Desfaz as Inclus”es/Exclus”es/Alteracoes                   ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?intaxe   ?Ma200Undo(ExpA1)                                           ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?arametros?ExpA1 = Array com os recnos                                ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?etorno   ?False caso ocorra algum problema, True em caso contrario   ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?Uso      ?MATA200                                                    ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?*/
Static Function Ma200Undo(aUndo, nOpcX)

Local lRet       := .T.
Local nX         := 0
Local nY         := 0
Local aAreaAnt   := GetArea()

Begin Transaction

	dbSelectArea('SG1')
	For nX := 1 to Len(aUndo)
		If aUndo[nX,1] > 0 .And. aUndo[nX,1] <= LastRec()
			dbGoto(aUndo[nX,1])
			If (lRet:=RecLock('SG1', .F.))
				If aUndo[nX, 2] == 1 //-- O Registro foi Incluido
					//-- Deleta o Registro
					If !Deleted()
						dbDelete()
					EndIf
				ElseIf aUndo[nX, 2] == 2 //-- O Registro foi Excluido
					//-- Restaura O REGISTRO
					If Deleted()
						dbRecall()
					ElseIf nOpcX == 3
						dbDelete()
					EndIf
				ElseIf aUndo[nX, 2] == 3 //-- O Registro foi Alterado
					//-- Restaura OS DADOS do Registro
					For nY := 1 to Len(aUndo[nX, 3])
						FieldPut(nY, aUndo[nX, 3, nY])
					Next nY
				EndIf
				MsUnlock()
			Else
				Exit
			EndIf
		EndIf

	Next nX

	If ExistBlock("A200UNDO")
		//--- Parametros passados para PARAMIXB:
		//--- PARAMIXB[nX,1] = Nro. do Registro
		//--- PARAMIXB[nX,2] = Tipo - 1. Inclusao/2. Exclusao/3. Alteracao
		//--- PARAMIXB[nX,3,nY] = Campos Alterados do componente
		ExecBlock("A200UNDO",.F.,.F.,aUndo)
	EndIf

End Transaction

RestArea(aAreaAnt)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±?un‡„o    ?A200Descen ?Autor ?ernando Joly/Eduardo?Data ?9.05.1999³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±?escri‡„o ?Preenche a Variavel cValComp com a Descendencia do Produto ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?intaxe   ?A200Descen(ExpC1,ExpA1,ExpO1)                              ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?arametros?ExpC1 = Variavel Caracter com a Descendˆncia do Produto    ³±?
±±?         ?ExpA1 = Array com a descendˆncia dos Produtos Incluidos 	  ³±?
±±?         ?ExpO1 = Objeto Tree                                        ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?etorno   ?False caso ocorra algum problema na Montagem, True C.C.    ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?Uso      ?MATA200                                                    ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?*/
User Function xA2Descen(cValComp, aDescend, oTree)

Local aAreaAnt   := GetArea()
Local aAreaTRE   := {}
Local cPai       := ''
Local cCod       := ''
Local lRet       := .T.
Local nX		 := 0

cValComp := ''
aDescend := {}

dbSelectArea(oTree:cArqTree)
aAreaTRE := GetArea()
cPai     := T_IDTREE
cCod     := If(Right(T_CARGO, 4)=='COMP',SubStr(T_CARGO, Len(SG1->G1_COD) + Len(SG1->G1_TRT) + 1, Len(SG1->G1_COD) ),Left(T_CARGO, Len(SG1->G1_COD)))
aAdd(aDescend, cCod)

Do While .T.
	dbSetOrder(3) //-- Ordem de T_IDCODE (Filho)
	If Val(cPai) # 0 .And. dbSeek(cPai, .F.)
		cCod   := If(Right(T_CARGO, 4)=='COMP',SubStr(T_CARGO, Len(SG1->G1_COD) + Len(SG1->G1_TRT) + 1, Len(SG1->G1_COD) ),Left(T_CARGO, Len(SG1->G1_COD)))
		aAdd(aDescend, cCod)
		cPai := T_IDTREE
		Loop
	Else
		Exit
	EndIf
EndDo

If Len(aDescend) > 0
	For nX := Len(aDescend) to 1 Step -1
		cValComp += aDescend[nX] + '?'
	Next nX
EndIf

//-- Restaura a Area de Trabalho
dbSetOrder(aAreaTRE[2])
dbGoto(aAreaTRE[3])
RestArea(aAreaAnt)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±?un‡„o    ?A200TudoOk ?Autor ?ernando Joly/Eduardo?Data ?9.05.1999³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±?escri‡„o ?Valida‡„o Final da Inclus„o/Altera‡„o                      ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?intaxe   ?A200TudoOk(ExpC1)                                          ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?arametros?ExpC1 = Variavel Caracter com o a Origem da Chamada (I/A/E)³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?etorno   ?False caso ocorra algum problema na Valida‡„o, True C.C.   ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?Uso      ?MATA200                                                    ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?*/
User Function xA200TudoOk(cOpc)

Local aAreaAnt   := GetArea()
Local aAreaTRE   := {}
Local aAreaSG1   := {}
Local cSeek      := ''
Local lRet       := .T.
Local lRetPE     := .T.
Local nRecno     := 0
Local nTamCod    := TamSX3("G1_COD")[1]
Local lRevAut    := SuperGetMv("MV_REVAUT",.F.,.F.)
Local cSomaTRT	 := ''
Local cCodPaiOk	 := cCodPai

cOpc := If(cOpc==Nil,Space(1),cOpc) //-- "I" = Inclus„o / "A" = Altera‡„o / "E" = Exclus„o

If !(cOpc=='E')

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//?Valida grupo de opcionais e item de opcionais   ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	If (!Empty(M->G1_GROPC).And.Empty(M->G1_OPC)) .Or. (!Empty(M->G1_OPC).And.Empty(M->G1_GROPC))
		Help(' ',1,'A200OPCOBR')
		lRet := .F.
	EndIf

	If !(l200Auto)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//?Valida a Existencia de Similaridade na Estrutura Atual (DBTree)?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet
			dbSelectArea(oTree:cArqTree)
			aAreaTRE := GetArea()
			dbSetOrder(4)
			nRecno := Recno()
			If cCodPai == M->G1_COMP
				cCodPaiOk := Left(oTree:GetCargo(), nTamCod)
			EndIf
			If cCodPaiOk <> Left(T_CARGO, nTamCod)
				// Qdo. o componente torna-se pai pela 1a.vez nao existe ainda T_CARGO com sua chave
				dbSeek(cSeek := cCodPaiOk + M->G1_TRT + M->G1_COMP, .T.)
			Else
				dbSeek(cSeek := Left(T_CARGO, nTamCod) + M->G1_TRT + M->G1_COMP, .T.)
			EndIf
			If ! Eof()
				Do While !Eof() .And. cSeek == Left(T_CARGO, Len(cSeek))
					If !(nRecno==Recno()) .And. !(Right(T_CARGO,4)$'CODI?OVO') .And. ( M->G1_TRT == SubsTr(T_CARGO, nTamCod+1, 3) .And.!Empty(M->G1_TRT) )
						Help(' ',1,'MESMASEQ')
						lRet := .F.
						Exit
					EndIf
					dbSkip()
				EndDo
			EndIf
			dbSetOrder(aAreaTRE[2])
			dbGoto(aAreaTRE[3])
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//?Valida a Existencia de Similaridade na Estrutura Gravada (SG1) ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet .And. ( cOpc=='I' .Or. (cOpc=='A' .And. M->G1_TRT <> SubsTr(T_CARGO, nTamCod+1, 3)) )
		dbSelectArea('SG1')
		aAreaSG1 := GetArea()
		dbSetOrder(1)
		If dbSeek(xFilial("SG1")+cCodPaiOk+M->G1_COMP+M->G1_TRT, .F.)
			If !lRevAut .Or. l200Auto .Or. (oTree:TreeSeek(cCodPai+M->G1_TRT+M->G1_COMP) .And. !(Right(oTree:GetCargo(),4)$'CODI?OVO'))
				Help(' ',1,'MESMASEQ')
				lRet := .F.
			EndIf
			IF lRet .And. lRevAut
				Do While !Eof() .And. SG1->G1_FILIAL+SG1->G1_COD+SG1->G1_COMP == xFilial("SG1")+cCodPai+M->G1_COMP
					cSomaTRT := SG1->G1_TRT
					SG1->(dbSkip())
				EndDo
				M->G1_TRT := Val(cSomaTRT) + 1
				M->G1_TRT := StrZero(M->G1_TRT,3)
			EndIF
		EndIf
		RestArea(aAreaSG1)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//?Valida revisao na alteracao da estrutura		?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	If lRet .And. cOpc == 'A'
		If M->G1_REVINI > cRevisao .Or. M->G1_REVFIM < cRevisao
			Aviso(OemToAnsi('Erro Revisao'),'Atencao',{"Ok"})
			lRet := .F.
		EndIf
	EndIf	

EndIf

If cOpc == 'E' .And. Type('lDelFunc') == 'L'
	lDelFunc := lRet
EndIf

RestArea(aAreaAnt)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±?un‡„o    ?Ma200GrSim ?Autor ?ernando Joly/Eduardo?Data ?9.05.1999³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±?escri‡„o ?Grava‡„o das Estruturas Similares                          ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?intaxe   ?Ma200GrSim(ExpC1,ExpC2,ExpA1)                              ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?arametros?ExpC1 = Variavel Caracter com o Codigo do Produto          ³±?
±±?         ?ExpC2 = cod.produto similar                                ³±?
±±?         ?ExpA1 = Array com os Recnos dos Componentes Incl/Excl      ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?etorno   ?False caso ocorra algum problema na Valida‡„o, True C.C.   ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?Uso      ?MATA200                                                    ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?*/
User Function xMa200GrSim(cProduto, cCodSim, aUndo)

Local lRet       := .T.
Local aAreaAnt   := GetArea()
Local aAreaTRE   := {}
Local aRecnos    := {}
Local nX         := 0
Local i          := 0
Local cRevisao   := ""
Local aCampos    := {}
Local lRevaut	 := Getnewpar("MV_REVAUT",.F.)
Local nUltRev 	 := 0
Local aAreaSB1   := SB1->(GetArea())

If !Empty(cCodSim)
	If !Empty(cRevSim)
		dbSelectArea('SG1')
		dbSetOrder(1)
		dbgotop()
		If dbSeek(xFilial('SG1') + cCodSim, .F.)
			Do While !Eof() .And. SG1->G1_FILIAL+SG1->G1_COD == xFilial("SG1")+cCodSim
				//N? adiciona componentes fora da revis?
				If (cRevSim # Nil) .And. ;
					!(SG1->G1_REVINI <= cRevSim .And. (SG1->G1_REVFIM >= cRevSim .Or. SG1->G1_REVFIM = ' '))
					SG1->(dbSkip())
					Loop
				EndIf
				
				dbSelectArea("SB1")
				dbSetOrder(1)
				If DbSeek(xFilial("SB1")+cCodSim)
					If !Empty(SB1->B1_REVATU)
						nUltRev := ExplEstr(1,SG1->G1_INI,SB1->B1_OPC,SB1->B1_REVATU)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
						//?Se nUltRev == 0, indica que o componente nao faz parte da revisao       ?
						//?atual da estrutura,logo, nao deve ser carregado.                        ?
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
						If nUltRev <> 0
							aAdd(aRecnos, SG1->(Recno()))
						EndIf
					Else
						aAdd(aRecnos, SG1->(Recno()))
					EndiF
				EndIf
				SG1->(dbSkip())
			EndDo
		EndIf
	EndIf
	
	dbSelectarea('SG1')
	If Len(aRecnos) > 0
		For nX := 1 to Len(aRecnos)
			dbGoto(aRecnos[nX])
			//-- Grava o Campo Atual
			aCampos := {}
			For i := 1 To FCount()
				aAdd(aCampos, FieldGet(i))
			Next i

			//-- Cria o Novo Registro
			Begin Transaction
				RecLock('SG1', .T.)
				For i:=1 To FCount()
					If FieldPos("G1_REVINI") == i
				 	   FieldPut(i,Space((TamSX3("G1_REVINI")[1])))
					ElseIf FieldPos("G1_REVFIM") == i
					   FieldPut(i,Replicate('Z',((TamSX3("G1_REVFIM")[1]))))
					Else
				   		FieldPut(i,aCampos[i])
				 	Endif
				Next 1
				Replace G1_COD With cProduto
				MsUnlock()
				If aScan(aUndo, {|x| x[1]==Recno()}) == 0
					aAdd(aUndo, {Recno(), 1}) //-- 1=Reg.Incluido/2=Reg.Excluido/3=Reg.Alterado
				EndIf
			End Transaction

		Next nX
	EndIf
EndIf
//-- Restaura a Area de Trabalho
RestArea(aAreaSB1)
RestArea(aAreaAnt)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±?un‡„o    ?200Revis ?Autor ?Rodrigo de A. Sartorio?Data ?05/04/99 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±?escri‡…o ?Atualiza cadastro de revisao de componentes                ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?intaxe   ?ExpC1 := A200ReVis(ExpC2)			                      ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?arametros?ExpC2 = codigo do componente		                          ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?etorno   ?ExpC1 = revisao 		 	        			       		  ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?Uso      ?MATA200                                                    ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?*/
User Function xA2Revis(cProduto,lShow,lRevAut)

Local cRevisao   := CriaVar("G1_REVINI")
Local aArea      := {}
Local aAreaSG5   := {}
Local aAreaSB1   := {}
Local aRevisoes  := {}

Default lShow	 := .T.
Default lRevAut  := .F.

aArea := GetArea()
dbSelectArea("SG5")
aAreaSG5 := GetArea()
dbSetOrder(1)
If dbSeek(xFilial("SG5")+SubStr(cProduto,1,Len(SG5->G5_PRODUTO)))
	Do While SG5->(!Eof()) .And. SG5->G5_FILIAL+SG5->G5_PRODUTO == xFilial("SG5")+SubStr(cProduto,1,Len(SG5->G5_PRODUTO))
		AADD(aRevisoes,{.F.,SG5->G5_REVISAO,DTOC(SG5->G5_DATAREV)})
		cRevisao:=SG5->G5_REVISAO
		SG5->(dbSkip())
	EndDo
EndIf

aAreaSG5 := GetArea()
cRevisao:=Soma1(cRevisao)
RecLock("SG5",.T.)
G5_FILIAL  := xFilial("SG5")
G5_PRODUTO := cProduto
G5_REVISAO := cRevisao
G5_DATAREV := dDataBase
G5_USER    := RetCodUsr()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Quando Controle de Revisao estiver ativo, grava os campos conforme ?
//?realizado na A201AtuAx() para Revisao de Estruturas                ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SuperGetMv("MV_REVPROD",.F.,.F.) .And. Posicione("SB5",1,xFilial("SB5")+cProduto,"B5_REVPROD") == "1"
	G5_STATUS := "2"
	G5_MSBLQL := "1"
EndIf

AADD(aRevisoes,{.T.,G5_REVISAO,DTOC(G5_DATAREV)})
SG5->(MsUnlock())

If ExistBlock("M200REVI")
	ExecBlock("M200REVI",.f.,.f.)
EndIf

If lShow .And. !lRevAut
	cRevisao:=A200SelRev(aRevisoes)
Endif

If !Empty(cRevisao)
	dbSelectArea("SB1")
	aAreaSB1:=GetArea()
	dbSetOrder(1)
	If dbSeek(xFilial("SB1")+cProduto)
		RecLock("SB1",.F.)
		Replace B1_REVATU With cRevisao
		MsUnlock()
	EndIf
	RestArea(aAreaSB1)
EndIf
RestArea(aAreaSG5)
RestArea(aArea)
Return cRevisao

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±?
±±?un‡…o    ?A200SelRev?Autor ?odrigo de A. Sartorio ?Data ?5/04/99 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±?
±±?escri‡…o ?Seleciona revisao atual do produto                         ³±?
±±?         ?                                                           ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?intaxe   ?ExpC1 := A200SelRev(ExpA1)			                      ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?arametros?ExpA1 = array de revisoes  		                          ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?etorno   ?ExpC1 = revisao 		 	        			       		  ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?Uso      ?MatA200                                                    ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?*/
Static Function A200SelRev(aRevisoes)

Local aPer:={},oQual,nOpca:=1,cVarQ:="   "
Local cRevisao:=CriaVar("B1_REVATU")
Local oOk := LoadBitmap( GetResources(), "LBOK")
Local oNo := LoadBitmap( GetResources(), "LBNO")
Local oDlg,cTitle:=OemToAnsi('Selecao revisao atual')	//"Sele‡„o da Revis„o Atual"
Local i:=0,nAchou:=0
If Len(aRevisoes) > 0
	If !l200Auto
		DEFINE MSDIALOG oDlg TITLE cTitle From 145,70 To 400,340 OF oMainWnd PIXEL
		@ 10,13 TO 90,122 LABEL "" OF oDlg  PIXEL
		@ 20,18 LISTBOX oQual VAR cVarQ Fields HEADER "",OemToAnsi('Revisao'),'Data'  SIZE 100,62 ON DBLCLICK (aRevisoes:=u_xMA2Troca(oQual:nAt,@aRevisoes),oQual:Refresh()) NOSCROLL OF oDlg PIXEL	//"Revis„o"###"Data"
		oQual:SetArray(aRevisoes)
		oQual:bLine := { || {If(aRevisoes[oQual:nAt,1],oOk,oNo),aRevisoes[oQual:nAt,2],aRevisoes[oQual:nAt,3]}}
		DEFINE SBUTTON FROM 110,042 TYPE 1 Action (nOpca:=2,oDlg:End()) ENABLE OF oDlg PIXEL
		DEFINE SBUTTON FROM 110,069 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg PIXEL
		ACTIVATE MSDIALOG oDlg
	ElseIf aScan(aAutoCab,{|x| x[1] == "ATUREVSB1" .And. x[2] == "S"}) > 0
		nOpca := 2
	EndIf
	If nOpca == 2
		nAchou:=ASCAN(aRevisoes,{|x| x[1] })
		If nAchou > 0
			cRevisao:=aRevisoes[nAchou,2]
		EndIf
	EndIf
EndIf
Return cRevisao

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±?un‡„o    ?MA200Troca ?Autor ?odrigo de A.Sartorio?Data ?05/04/99 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±?escri‡…o ?MarcaXDesmarca revisao utilizada                           ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?intaxe   ?ExpA1 := A200IniMap(ExpN1,ExpA2)                           ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?arametros?ExpN1 = nivel no array de revisoes                         ³±?
±±?         ?ExpA2 = array de revisoes                                  ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?etorno   ?ExpA1 = (ExpA2 atualizado)	       			              ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?so       ?MATA200                                                    ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
*/
USer Function xMA2Troca(nx,aRevisoes)
Local i:=0
aRevisoes[nx,1]:=!aRevisoes[nx,1]
For i:=1 to Len(aRevisoes)
	If nx # i
		aRevisoes[i,1] := .F.
	EndIf
Next i
Return aRevisoes

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±?un‡„o    ?A200NivAlt ?Autor ?ernando Joly/Eduardo?Data ?9.05.1999³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±?escri‡„o ?Seta o Parametro MV_NIVALT para 'S'                        ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?intaxe   ?A200NivAlt()                                               ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?arametros?Nenhum                                                     ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?etorno   ?False caso ocorra algum problema na Valida‡„o, True C.C.   ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?Uso      ?MATA200                                                    ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?*/
User Function xa2NivAlt()

Local aAreaAnt   := GetArea()
Local lRet       := .F.

//-- Seta o Parametro para Altera‡? de Niveis
If !(GetMV('MV_NIVALT')=='S')
	lRet := .T.
	PutMV('MV_NIVALT','S')
EndIf

RestArea(aAreaAnt)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±?un‡„o    ?A200Fields ?Autor ?ernando Joly/Eduardo?Data ?9.05.1999³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±?escri‡„o ?Cria um Array com os Campos do SG1                         ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?intaxe   ?A200Fields(ExpA1)                                          ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?arametros?ExpA1 = Array com os campos do SG1                         ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?etorno   ?False caso ocorra algum problema na Valida‡„o, True C.C.   ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?Uso      ?MATA200                                                    ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?*/
Static Function A200Fields(aAcho)

Local aAreaAnt   := GetArea()
Local aAreaSX3   := {}
Local lRet       := .T.

dbSelectArea('SX3')
aAreaSX3 := GetArea()
dbSetOrder(1)
If dbSeek('SG1' + '01', .F.)
	aAcho := {}
	Do While !Eof() .And. X3_ARQUIVO == 'SG1'
		If ! __lPyme .Or. (__lPyme .And. X3_PYME <> "N")
			aAdd(aAcho, X3_CAMPO)
		EndIf
		dbSkip()
	EndDo
Else
	aAcho := Array(SG1->(fCount()))
	SG1->(aFields(aAcho))
EndIf

RestArea(aAreaSX3)
RestArea(aAreaAnt)

Return lRet

/*
Rotina: A200IniMap
Monta arquivo binario para armazenar divergencias nas Qtd.
dos Componentes em relacao a Qtd. Basica do Produto.
*/

USer Function xA2IniMap(nQtdBase, oTree)

Local aAreaSG1   := SG1->(GetArea())
Local aAreaAnt   := GetArea()
Local aAreaTRE   := {}
Local cMapaFile  := ''
Local nMapaHdl   := 0
Local nQuant     := 0
Local nSeq       := 0
Local cText      := ''
Local nRecno     := 0
Local nQuantSG1  := 0
Local nQtdComp   := 0
Local cProdPai   := ""
Local aTamSX3	 := TamSX3("G1_QUANT")

cMapaFile := 'MAPA.DIV'
If File(cMapaFile)
	fErase(cMapaFile)
EndIf
nMapaHdl := MSFCREATE(cMapaFile, 0)

dbSelectArea(oTree:cArqTree)
aAreaTRE := GetArea()
dbSetOrder(1)
dbGoTop()
nSeq := 1
Do While !Eof()
	nRecno := Val(SubStr(T_CARGO,Len(SG1->G1_COD + SG1->G1_TRT + SG1->G1_COMP) + 1, 9))
	If nRecno > 0
		SG1->(dbGoto(nRecno))
		nQuantSG1 := SG1->G1_QUANT
	Else
		nQuantSG1 := 0
	EndIf
	If nSeq == 1
		fSeek(nMapaHdl,0,2)
		cText := '  Produto                   Qtd. Basica' +CHR(13) +CHR(10) //'  Produto                   Qtd. Basica'
		fWrite(nMapaHdl,cText,Len(cText))
		fSeek(nMapaHdl,0,2)
		nQtdBasePai := nQtdBase += CriaVar('B1_QB')
		cProdPai    := SG1->G1_COD
		cText := Space(2) +cProdPai + Space(19-Len(Str(nQtdBase,aTamSX3[1],aTamSX3[2]))) +Str(nQtdBase,aTamSX3[1],aTamSX3[2]) +CHR(13) +CHR(10)
		fWrite(nMapaHdl,cText,Len(cText))
		fSeek(nMapaHdl,0,2)
		cText := + CHR(13) + CHR(10) +Space(2) + 'Componentes                Quantidade' + CHR(13) + CHR(10) //'Componentes                Quantidade'
		fWrite(nMapaHdl,Replicate('=',43),43)
		fWrite(nMapaHdl,cText,Len(cText))
	Else
		If  dDataBase >= SG1->G1_INI .And. dDataBase <= SG1->G1_FIM
			nQuant := nQuantSG1
			fSeek(nMapaHdl,0,2)
			If SG1->G1_COD == cProdPai
				If nSeq > 2 .And. nQtdComp > 0
					cText := 'Descricao' +Space(31) +Str(nQtdComp,aTamSX3[1],aTamSX3[2]) +CHR(13) +CHR(10)
					fWrite(nMapaHdl,cText,Len(cText))
				ElseIf nSeq == 2
					fWrite(nMapaHdl,Replicate('=',43) +CHR(13) +CHR(10),43)
				EndIf
				cText := +CHR(13) +CHR(10) +Space(2) +SG1->G1_COMP +Space(13) +Str(nQuant,aTamSX3[1],aTamSX3[2])
				nQtdComp := 0
			Else
				cText := +CHR(13) +CHR(10) +Space(4) +SG1->G1_COMP +Space(11) +Str(nQuant,aTamSX3[1],aTamSX3[2])
				nQtdComp += nQuant
			EndIf
			fWrite(nMapaHdl,cText,Len(cText))
		Endif
	EndIf
	nSeq++
	dbSkip()
End
If nSeq > 2 .And. nQtdComp > 0
	cText := +CHR(13) +CHR(10) +'Descricao' +Space(31) +Str(nQtdComp,aTamSX3[1],aTamSX3[2])
	fWrite(nMapaHdl,cText,Len(cText))
EndIf

RestArea(aAreaTRE)
RestArea(aAreaSG1)
RestArea(aAreaAnt)
FClose(nMapaHdl)

Return Nil

/*
Rotina: 200ShowMap
Totalizar e Exibir Mapa de Divergencias nas quantidades dos ProdutoxElementos.

*/
STATIC Function A200ShowMap(nQtdNivel)

Local oGet
Local oDlg
Local oFontLoc
Local aAreaAnt   := GetArea()
Local aAreaSX2   := {}
Local cMapaFile  := ''
Local cString    := ''
Local cText      := ''
Local nNumLinhas := 0
Local cAlias     := Alias()
Local lRet       := .F.
Local aString    := {}
Local aTamSX3	 := TamSX3("G1_QUANT")

cMapaFile := 'MAPA.DIV'
If !File(cMapaFile)
	cString    := '  Nenhuma Divergencia...' // '  Nenhuma Divergencia...'
	nNumLinhas := 1
Else
	nMapaHdl := FOpen(cMapaFile,2+64)
	FSeek(nMapaHdl,0,2)
	cText := +CHR(13)+CHR(10) +'  Total' + Space(40 - Len(Str(nQtdNivel,aTamSX3[1],4))) +Str(nQtdNivel,aTamSX3[1],aTamSX3[2]) // '  Total'
	FWrite(nMapaHdl,+CHR(13)+CHR(10),43)
	FWrite(nMapaHdl,Replicate("=",43),43)
	FWrite(nMapaHdl,cText,Len(cText))
	FClose(nMapaHdl)
	cString := MEMOREAD(cMapaFile)
EndIf

oFontLoc := TFont():New('Arial',6,15)
DEFINE MSDIALOG oDlg TITLE OemToAnsi('Mapa de Divergencias') FROM 15,20 to 38,54 // 'Mapa de Divergencias'
DEFINE SBUTTON FROM 156,070 TYPE 1  ENABLE OF oDlg ACTION (lRet := .T.,oDlg:End())
DEFINE SBUTTON FROM 156,100 TYPE 2  ENABLE OF oDlg ACTION (lRet := .F.,oDlg:End())
@ 0.5,0.7  GET oGet VAR cString OF oDlg MEMO size 125,145 READONLY COLOR CLR_BLACK,CLR_HGRAY
oGet:oFont     := oFontLoc
oGet:bRClicked := {||AllwaysTrue()}
ACTIVATE MSDIALOG oDlg Centered
oFontLoc:End()

RestArea(aAreaAnt)
Return (lRet)

/*
Rotina: Explode
Faz a explosao de uma estrutura.
*/
Static Function Explode(cProduto, aExplode, cRevisao, nCount, oTree)

Local aAreaAnt   := GetArea()
Local aAreaSG1   := SG1->(GetArea())
Local aAreaTRE   := {}
Local cCod       := cProduto
Local cSeq       := ''
Local cComp      := ''
Local nRecno     := 0
Local cFilSG1    := xFilial('SG1')

nCount++
SG1->(dbSetOrder(1))

dbSelectArea(oTree:cArqTree)
aAreaTRE := GetArea()
dbSetOrder(1)
dbGoTop()
(aAreaTRE[1])->(dbSkip())// ignora o primeiro recno do arquivo temporario pois esta relacionado ao PA.
Do While !Eof()
	cCod   := Left(T_CARGO, Len(SG1->G1_COD))
	cSeq   := SubStr(T_CARGO, Len(SG1->G1_COD) + 1, Len(SG1->G1_TRT))
	cComp  := SubStr(T_CARGO, Len(SG1->G1_COD + SG1->G1_TRT) + 1, Len(SG1->G1_COMP))
	nRecno := Val(SubStr(T_CARGO,Len(SG1->G1_COD + SG1->G1_TRT + SG1->G1_COMP) + 1, 9))

    If !SG1->(DbSeek(cFilSG1+cCod+cComp+cSeq))
		(aAreaTRE[1])->(dbSkip())
		Loop
    EndIf
	If cCod # cProduto
		dbSkip()
		Loop
	EndIf

	If nRecno > 0
		SG1->(dbGoto(nRecno))
	Else
		Exit
	EndIf
	If cCod # cComp .And. SG1->G1_REVINI <= cRevisao .And. SG1->G1_REVFIM >= cRevisao
		nPos := aScan(aExplode,{|x| x[1] == nCount .And. x[2] == cCod .And. x[3] == cComp .And. x[5] == cSeq})
		If nPos == 0 .And. dDataBase >= SG1->G1_INI .And. dDataBase <= SG1->G1_FIM
			aAdd(aExplode,{nCount, cCod, cComp, SG1->G1_QUANT, cSeq, SG1->G1_REVINI, SG1->G1_REVFIM})
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//?Verifica se existe sub-estrutura                ?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		nRecno := SG1->(Recno())
		If SG1->(dbSeek(cFilSG1+cComp, .F.))
			Explode( SG1->G1_COD, @aExplode, cRevisao, @nCount, oTree)
			nCount --
		Else
			SG1->(dbGoto(nRecno))
			nPos := aScan(aExplode,{|x| x[1] == nCount .And. x[2] == cCod .And. x[3] == cComp .And. x[5] == cSeq})
			If nPos == 0 .And. dDataBase >= SG1->G1_INI .And. dDataBase <= SG1->G1_FIM
				aAdd(aExplode,{nCount, cCod, cComp, SG1->G1_QUANT, cSeq, SG1->G1_REVINI, SG1->G1_REVFIM})
			EndIf
		Endif
	EndIf
	(aAreaTRE[1])->(dbSkip())
Enddo

RestArea(aAreaTRE)
RestArea(aAreaSG1)
RestArea(aAreaAnt)

Return Nil

/*
Rotina: a200Posic
Posiciona sobre um item desejado na estrutura.
*/
User Function xMaPosic(nOpcX, cCargo, oTree, aKey, aBkey)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//?Inicializa Variaveis Locais                                         ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
Local aAreaAnt   := GetArea()
Local aAreaTRB   := ''
Local cComp      := Space(Min(TamSX3('G1_COMP')[1],15))
Local cOrdem     := ''
Local cTarget    := ''
Local cArqTrab   := oTree:cArqTree
Local nRecno     := 0
Local nX		 := 0

Private cA200ICod := AllTrim(Str(Len(SG1->G1_COD+SG1->G1_TRT)+1))
Private cA200TCod := AllTrim(Str(Len(SG1->G1_COMP)))
Default aKey     := {}

//--Desativa tecla de atalho
For nX := 1 to len(aKey)
	Set Key aKey[nX] to
Next nX

If Ma200Pesq(@cComp)
	If !Empty(cComp)
		dbSelectArea(cArqTrab)
		aAreaTRB  := GetArea()
		cOrdem    := T_IDCODE
		nRecno    := Recno()
		If cComp==cCodAtual
			dbGoto(1)
			cTarget := T_CARGO
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
			//?Cria o 5o Indice de Trabalho do arquivo dbTree                      ?
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
			If Empty(cInd5) .Or. !File(cInd5+OrdBagExt())
				cInd5 := CriaTrab('', .F.)
				IndRegua(Alias(),cInd5,'Subs(T_CARGO,'+cA200ICOD+', '+cA200TCOD+')',,,)
				dbClearIndex()
				dbSetIndex(SubStr(cArqTrab,2)+'A'+OrdBagExt())
				dbSetIndex(SubStr(cArqTrab,2)+'B'+OrdBagExt())
				dbSetIndex(SubStr(cArqTrab,2)+'C'+OrdBagExt())
				dbSetIndex(SubStr(cArqTrab,2)+'D'+OrdBagExt())
				dbSetIndex(cInd5+OrdBagExt())
			EndIf
			dbSetOrder(5)
			dbGoto(nRecno)
			If dbSeek(cComp, .F.)

				//-- Desconsidera a linha do Produto Pai
				If !(Right(T_CARGO,4)=='COMP')
					Do While !Eof() .And. Subs(T_CARGO,Len(SG1->G1_COD+SG1->G1_TRT)+1,Len(SG1->G1_COMP)) == cComp
						If	Right(T_CARGO,4)=='COMP'
							cTarget := T_CARGO
							Exit
						EndIf
						dbSkip()
					EndDo
				Else
					cTarget := T_CARGO
				EndIf

				//-- Caso J  esteja posicionado procura a Pr?ima ocorrˆncia
				If !Empty(cTarget) .And. T_IDCODE <= cOrdem
					Do While !Eof() .And. Subs(T_CARGO,Len(SG1->G1_COD+SG1->G1_TRT)+1,Len(SG1->G1_COMP)) == cComp
						If Right(T_CARGO,4) == 'COMP' .And. T_IDCODE > cOrdem
							cTarget := T_CARGO
							Exit
						EndIf
						dbSkip()
					EndDo
				EndIf

			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//?Retorna Integridade do Sistema                                      ?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		RestArea(aAreaTRB)
		RestArea(aAreaAnt)

		//-- Posiciona o dbTree sobre o Componente Encontrado
		If !Empty(cTarget)
			oTree:TreeSeek(cTarget)
		Else
			Help(' ',1, 'REGNOIS')
		EndIf
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Seta Tecla de atalho                                         ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Ma200StKey(aKey,aBkey)

Return .T.

/*
Rotina: Ma200Pesq
Pesquisa o código e o nome do componente Tree.
*/
Static Function Ma200Pesq(cComp)
Local oDlg
Local oCbx
Local oGet
Local cOrd  := 'Componente'
Local aOrd  := {'Componente','Descricao'} //###Componente ###Descricao
Local lRet  := .F.
Local lSB1  := .F.
Local aArea := SB1->(GetArea())

SB1->(dbSetOrder(3))

Define MsDialog oDlg From 0,0 To 100,490 Pixel Title OemToAnsi("Pesquisar") //"Pesquisar"
@  5, 5 ComboBox oCbx Var cOrd  Items aOrd Size 206,36 Pixel Of oDlg FONT oDlg:oFont Valid ( If(cOrd=='Componente',cComp:=Space(Len(SB1->B1_DESC)),Space(Len(cComp))) )
@ 22, 5 MsGet    oGet Var cComp Size 206,10 Pixel Valid( Ma200Descr(cOrd,@cComp,@lSB1),If(lSB1,(lRet:=.T.,oDlg:End()),.T.) )
Define SButton From  5,215 Type 1 Of oDlg Enable Action (lRet:=.T.,oDlg:End())
Define SButton From 20,215 Type 2 Of oDlg Enable Action oDlg:End()
Activate MsDialog oDlg Centered

cComp := If(lRet.And.lSB1,SB1->B1_COD,cComp)

RestArea(aArea)
Return(lRet)

/*
Rotina: Ma200Descr
Pesauisa a descrição.
*/
Static Function Ma200Descr(cOrd,cComp,lSB1)
Local aAreaAnt := GetArea()
Local lRet     := .T.
If cOrd == 'Descricao'   //Descricao
	If !SB1->(dbSeek(xFilial("SB1")+cComp,.T.))
		lSB1  := lRet := ConPad1(,,,"SB1",,, .F.)
		cComp := SB1->B1_DESC
	Else
		lSB1  := .T.
	EndIf
EndIf
RestArea(aAreaAnt)
Return(lRet)

/*
Rotina: xBtn2Ok
Função acionada no botão de confirmação da estrutura.
*/
USer Function xBtn2Ok(aUndo, c200Cod)
Local _aMODeMP   := {.F.,.F.}
Local lRet := .T.
Local aArea := {SG1->(IndexOrd()), SG1->(RecNo()), Alias()}

//VALIDA INCLUS? DE CODIGO MOD E MP 
If lRet
	dbSelectArea('SG1')
	aAreaSG1 := GetArea()
	SG1->(DbSetOrder(1));SG1->(dBgOtOP())
	If SG1->(DbSeek(xFilial("SG1")+c200Cod, .T.))
		Do While SG1->(!Eof()) .And. SG1->G1_FILIAL+SG1->G1_COD == xFilial("SG1")+c200Cod
				DbSelectArea('SB1');SB1->(DbSeek(xFilial('SB1')+SG1->G1_COMP))
				IF SB1->B1_TIPO $ 'MO|MP'
					_aMODeMP[iIF(SB1->B1_TIPO=='MO',1,2)] := .T.
				ENDIF
			SG1->(dbSkip())
		EndDo
	EndIf
	RestArea(aAreaSG1)
// INIBIDO DE ACORDO COM ALINHAMENTO. CARLOS + DAVID = 20170814
//	IF !_aMODeMP[1] .Or. !_aMODeMP[2] 
//		MsgInfo('A estrutuRa deve conter itens MOD e MP para esta produção.','Atenção')
//		lRet := .F.
//	ENDIF
	dbSelectArea('SG1'); SG1->(dbSetOrder(aArea[1])); SG1->(dbGoto(aArea[2]))
EndIf  

Return(lRet)

/*
Rotina: xA2Prompt
Acrescenta TRT ao prompt do dbtree baseado no conteúdo da propriedade 
*/
USer Function xA2Prompt(cPrompt, cCargo, nQtdeSG1,cProdAtu,aOpc)
Local cTRT       := Space(Len(SG1->G1_TRT)+3)
Local aTamQtde   := TamSX3("G1_QUANT")
Local cQuant     := ""
Local cRet       := ""
Local cM200TEXT  := ""
Local nTamCod    := TamSX3("G1_COD")[1]
Local nTamTRT    := TamSX3("G1_TRT")[1]
Local lM200TEXT  := ExistBlock("M200TEXT")
Local cOpc       := ""
Default cProdAtu := ""
Default nQtdeSG1 := 0
Default aOpc     := { }

If ! (cCargo == Nil .Or. Empty(cCargo) .Or. Right(cCargo, 4) $ "CODI,NOVO")
	If ! Empty(cTRT := SubStr(cCargo, nTamCod+1, nTamTRT))
		cTRT := " - " + cTRT
	Endif
	cQuant   := " / "+'STR0060'+Str(nQtdeSG1,aTamQtde[1],aTamQtde[2])
	If lM200TEXT
		cProdAtu := AllTrim(SubStr(cCargo, nTamCod+1+nTamTRT, nTamCod))
	EndIf
Endif

If lM200TEXT .And. Empty(cProdAtu) .And. !(Empty(cCargo)) .And. Right(cCargo, 4) $ "CODI,NOVO"
	cProdAtu := AllTrim(SubStr(cCargo, 1, nTamCod))
EndIf

If GetMV("MV_SELEOPC") == "S" .And. Len(aOpc) > 0
   cOpc := " / " +'STR0077' + AllTrim(aOpc[1][3]) + " - " + AllTrim(aOpc[1][4]) + " / " + 'STR0078' + AllTrim(aOpc[1][5]) + " - " + AllTrim(aOpc[1][6])
EndIf

if lExpEst 
	cRet := (Pad(AllTrim(cPrompt) + cTRT + cQuant + cOpc, Len(cPrompt+cTRT+cQuant+cOpc)))
else
	cRet := (Pad(AllTrim(cPrompt) + cTRT + cQuant + cOpc + '  *', Len(cPrompt+cTRT+cQuant+cOpc)))
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Ponto de entrada para manipular o texto a ser apresentado na estrutura ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lM200TEXT
	cM200TEXT := ExecBlock("M200TEXT", .F., .F., {cRet,;                                // Texto original
												  AllTrim(Substr(cCargo, 1, nTamCod)),; // Codigo do item PAI
												  SubStr(cCargo, nTamCod+1, nTamTRT),;  // TRT
												  cProdAtu,;    // Codigo do componente/item inserido na estrutura
												  nQtdeSG1})                            // Qtde. do item na estrutura
	If ValType(cM200TEXT) == "C"
		cRet := cM200TEXT
	EndIf
EndIf

Return cRet

/*
Rotina: xA2Potenc
Validacao para digitar a potencia do Lote corretamente.
*/
User Function xA2Potenc()
LOCAL lRet      := .T.
LOCAL cCod		:= M->G1_COMP
LOCAL nPotencia := &(ReadVar())
If !Rastro(cCod)
	Help(" ",1,"NAORASTRO")
	lRet:=.F.
Else
	If !PotencLote(cCod)
		Help(" ",1,"NAOCPOTENC")
		lRet:=.F.
	EndIf
EndIf
Return lRet

/*
Rotina: Ma200Oper
Seleciona e grava a operacao para o componente
*/
Static Function Ma200Oper(nOpcX, cCargo, oTree)
Local nRecno := Val(SubStr(cCargo,Len(SG1->G1_COD + SG1->G1_TRT + SG1->G1_COMP) + 1, 9))
Local lOk    := .T.
Local cTipo  := Right(cCargo,4)
Local nSeek  := 0
Local cCodPai:= CriaVar("G1_COD",.F.)

If !(cTipo == "CODI" .Or. cTipo == "NOVO")
	SG1->(dbGoto(nRecNo))

	cCodPai := A200FanInv(SG1->G1_COMP,oTree)
	If Empty(cCodPai)
		Aviso('N? foi poss?el encontrar PA v?ido para o componente posicionado. Analise o cadastro de estruturas e produtos.','Atencao',{'Fechar'}) //N? foi poss?el encontrar PA v?ido para o componente posicionado. Analise o cadastro de estruturas e produtos.
		lOk := .F.
	EndIf

	If lOk .And. !SG2->(dbSeek(xFilial("SG2")+cCodPai))
		Aviso('Atencao','N? foi poss?el encontrar PA v?ido para o componente posicionado. Analise o cadastro de estruturas e produtos.' +Trim(cCodPai) +".",{'Fechar'})
		lOk := .F.
	EndIf

	If lOk
		lOk := A635SeleOperac(cCodPai,, .F.)
	EndIf

	nSeek := aScan(aRegsSGF, {|z| z[1] + z[2] + z[4] + z[5] == cCodPai + SG2->G2_CODIGO + SG1->G1_COMP + SG1->G1_TRT})

	If nSeek > 0
		If SG2->G2_OPERAC # aRegsSGF[nSeek, 3]
			Help(" ",1,"A635OOPE",, AllTrim(RetTitle("GF_COMP")) + ": " + SG1->G1_COMP, 4, 0) //O produto ja esta definido em outra operacao para este mesmo roteiro
		Else
			Help(" ",1,"A635MOPE",, AllTrim(RetTitle("GF_COMP")) + ": " + SG1->G1_COMP, 4, 0) //O produto ja esta definido para esta operacao deste mesmo roteiro
		Endif
		lOk := .F.
	Endif

	If lOk
		SetEnch(aRotina[3, 1])
		A635VldGrava(cCodPai, SG2->G2_CODIGO, SG2->G2_OPERAC, SG1->G1_COMP, SG1->G1_TRT, .F., .T., {|aFields| Aadd(aRegsSGF, aFields)})
		SetEnch(aRotina[nOpcx, 1])
	Endif
EndIf
Return

/*
Rotina: xA200CEst
Comparacao de estruturas.
*/
User Function xA200CEst()
Local aArea:=GetArea()
Local cCodOrig:=Criavar("G1_COMP",.F.),cCodDest:=Criavar("G1_COMP",.F.)
Local cRevOrig:=Criavar("C2_REVISAO",.F.),cRevDest:=Criavar("C2_REVISAO",.F.)
Local cDescOrig:=Criavar("B1_DESC",.F.),cDescDest:=Criavar("B1_DESC",.F.)
Local cOpcOrig:=Criavar("C2_OPC",.F.),cOpcDest:=Criavar("C2_OPC",.F.)
Local dDtRefOrig:=dDataBase,dDtRefDest:=dDataBase
Local oSay,oSay2, oChk
Local lOk:=.F.
Local aInfo := {}
Local aObjects:= {}
Local aPosObj:= {}
Local oSizeW := FwDefSize():New()
Local oSizeI := Nil
Private lDif := .F.


oSizeW:AddObject('WND', 600,310, .F.,.F.)
oSizeW:Process()

aPosObj 	:= {oSizeW:GetDimension('WND','LININI'),oSizeW:GetDimension('WND','COLINI'),oSizeW:GetDimension('WND','LINEND'),oSizeW:GetDimension('WND','COLEND')}



DEFINE MSDIALOG oDlg FROM  aPosObj[1],aPosObj[2] TO aPosObj[3],aPosObj[4] TITLE OemToAnsi("Comparador de Estruturas") PIXEL //"Comparador de Estruturas"

oSizeI		:= FwDefSize():New(.T.,,,oDlg)

oSizeI:AddObject('TOP',100,45,.T.,.T.)
oSizeI:AddObject('BOT',100,45,.T.,.T.)
oSizeI:AddObject('CHK',100,10 ,.T.,.T.)

osizeI:lProp 		:= .T.
oSizeI:aMargins 	:= { 3, 3, 3, 3} 
oSizeI:Process() 	   		


DEFINE SBUTTON oBtn FROM 800,800 TYPE 5 ENABLE OF oDlg

@ oSizeI:GetDimension('TOP','LININI'),oSizeI:GetDimension('TOP','COLINI') TO oSizeI:GetDimension('TOP','LINEND'),oSizeI:GetDimension('TOP','COLEND')-5 LABEL OemToAnsi("Dados Originais") OF oDlg PIXEL //"Dados Originais"
@ oSizeI:GetDimension('BOT','LININI'),oSizeI:GetDimension('BOT','COLINI') TO oSizeI:GetDimension('BOT','LINEND'),oSizeI:GetDimension('BOT','COLEND')-5 LABEL OemToAnsi("Dados para Comparacao") OF oDlg PIXEL //"Dados para Comparacao"

@ oSizeI:GetDimension('TOP','LININI')+12,035 MSGET cCodOrig   F3 "SB1" Picture PesqPict("SG1","G1_COMP") Valid NaoVazio(cCodOrig) .And. ExistCpo("SB1",cCodOrig) SIZE 105,9 OF oDlg PIXEL
@ oSizeI:GetDimension('TOP','LININI')+12,200 MSGET cRevOrig   Picture PesqPict("SC2","C2_REVISAO") SIZE 15,09 OF oDlg PIXEL
@ oSizeI:GetDimension('TOP','LININI')+27,200 MSGET dDtRefOrig Picture PesqPict("SD3","D3_EMISSAO") Valid NaoVazio(dDtRefOrig) SIZE 40,09 OF oDlg PIXEL
@ oSizeI:GetDimension('TOP','LININI')+27,040 MSGET cOpcOrig   When .F. SIZE 93,09 OF oDlg PIXEL
@ oSizeI:GetDimension('TOP','LININI')+27,133 BUTTON "?" SIZE 06,11 Action (cOpcOrig:=SeleOpc(4,"MATA200",cCodOrig,,,,,,1,dDtRefOrig,cRevOrig)) OF oDlg FONT oDlg:oFont PIXEL

@ oSizeI:GetDimension('BOT','LININI')+12,035 MSGET cCodDest   F3 "SB1" Picture PesqPict("SG1","G1_COMP") Valid NaoVazio(cCodDest) .And. ExistCpo("SB1",cCodDest) SIZE 105,9 OF oDlg PIXEL
@ oSizeI:GetDimension('BOT','LININI')+12,200 MSGET cRevDest   Picture PesqPict("SC2","C2_REVISAO") SIZE 15,09 OF oDlg PIXEL
@ oSizeI:GetDimension('BOT','LININI')+27,200 MSGET dDtRefDest Picture PesqPict("SD3","D3_EMISSAO") Valid NaoVazio(dDtRefDest) SIZE 40,09 OF oDlg PIXEL
@ oSizeI:GetDimension('BOT','LININI')+27,040 MSGET cOpcDest   When .F. SIZE 93,09 OF oDlg PIXEL
@ oSizeI:GetDimension('BOT','LININI')+27,133 BUTTON "?" SIZE 06,11 Action (cOpcDest:=SeleOpc(4,"MATA200",cCodDest,,,,,,1,dDtRefDest,cRevDest)) OF oDlg FONT oDlg:oFont PIXEL

@ aPosObj[1]+37,030 SAY oSay Prompt cDescOrig SIZE 130,6 OF oDlg PIXEL
@ aPosObj[1]+73,030 SAY oSay2 Prompt cDescDest SIZE 130,6 OF oDlg PIXEL

@ oSizeI:GetDimension('TOP','LININI')+14,010 SAY OemtoAnsi("Produto") SIZE 25,7  OF oDlg PIXEL //"Produto"
@ oSizeI:GetDimension('TOP','LININI')+14,175 SAY OemToAnsi("Revisao") SIZE 35,13 OF oDlg PIXEL //"Revisao"
@ oSizeI:GetDimension('TOP','LININI')+29,156 SAY OemToAnsi("Data Referencia") SIZE 85,13 OF oDlg PIXEL //"Data Referencia"
@ oSizeI:GetDimension('TOP','LININI')+29,010 SAY OemtoAnsi("Opcionais") SIZE 25,7  OF oDlg PIXEL //"Opcionais"

@ oSizeI:GetDimension('BOT','LININI')+14,010 SAY OemToAnsi("Produto") SIZE 25,7  OF oDlg PIXEL //"Produto"
@ oSizeI:GetDimension('BOT','LININI')+14,175 SAY OemToAnsi("Revisao") SIZE 35,13 OF oDlg PIXEL //"Revisao"
@ oSizeI:GetDimension('BOT','LININI')+29,156 SAY OemToAnsi("Data Referencia") SIZE 85,13 OF oDlg PIXEL //"Data Referencia"
@ oSizeI:GetDimension('BOT','LININI')+29,010 SAY OemtoAnsi("Opcionais") SIZE 25,7  OF oDlg PIXEL //"Opcionais"

@ oSizeI:GetDimension('CHK','LININI'),oSizeI:GetDimension('CHK','COLINI') CHECKBOX oChk VAR lDif PROMPT OemtoAnsi("Mostra somente componentes diferentes?") SIZE 150,009 Of oDlg PIXEL //"Mostra somente componentes diferentes?"

ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{|| If(A200COk(cCodOrig,cRevOrig,dDtRefOrig,cOpcOrig,cCodDest,cRevDest,dDtRefDest,cOpcDest),(lOk:=.T.,oDlg:End()),lOk:=.F.) },{||(lOk:=.F.,oDlg:End())})

// Processa comparacao das estruturas
If lOk
	Processa({|| A200PrCom(cCodOrig,cRevOrig,dDtRefOrig,cOpcOrig,cCodDest,cRevDest,dDtRefDest,cOpcDest) })
EndIf
RestArea(aArea)
RETURN

/*
Rotina: A200COk
Valida se pode efetuar a comparacao das estruturas.
*/
Static Function A200COk(cCodOrig,cRevOrig,dDtRefOrig,cOpcOrig,cCodDest,cRevDest,dDtRefDest,cOpcDest)
Local lRet:=.T., lRetPE := .T., lExibDif := .T.
Local aEstruOrig:={},aEstruDest:={}
Private nEstru:=0
// Verifica se todas as informacoes estao iguais
If cCodOrig+cRevOrig+DTOS(dDtRefOrig)+cOpcOrig == cCodDest+cRevDest+DTOS(dDtRefDest)+cOpcDest
	Help('  ',1,'A200COMPIG')
	lRet:=.F.
EndIf
If lRet .And. cCodOrig <> cCodDest
	// Verifica se existe item dentro da outra estrutura - NAO PERMITE COMPARAR PARA EVITAR RECURSIVIDADE
	nEstru:=0;aEstruOrig:=Estrut(cCodOrig,1)
	nEstru:=0;aEstruDest:=Estrut(cCodDest,1)
	If (aScan(aEstruOrig,{|x| x[3] == cCodDest}) > 0) .Or. (aScan(aEstruDest,{|x| x[3] == cCodOrig}) > 0)
		Help('  ',1,'A200COMPES')
		lRet:=.F.
	EndIf
	// Avisa ao usuario sobre produtos diferentes
	If lRet
		If ExistBlock("MT200DIF")
			lRetPE   := ExecBlock("MT200DIF",.F.,.F.,{cCodOrig,cCodDest})
			lExibDif := IIF(ValType(lRetPE)=="L",lRetPE,lExibDif)
		EndIf
		If lExibDif
			Help('  ',1,'A200COMPDF')
		EndIf
	EndIf
EndIf
Return lRet

/*
Rotina: A200PrCom
Efetua a comparacao das estruturas.
*/
Static Function A200PrCom(cCodOrig,cRevOrig,dDtRefOrig,cOpcOrig,cCodDest,cRevDest,dDtRefDest,cOpcDest)
Local aEstruOri:={}
Local aEstruDest:={}
Local aSize    := MsAdvSize(.T.)
Local oDlg,oTree,oTree2,aObjects:={},aInfo:={},aPosObj:={},aButtons:={}
Local cDescOri	:= "",cDescDest := ""
Local l800x600	:= .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?onta a  tela com o tree da versao base e com o tree da versao?
//?esultado da comparacao.                                      ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd( aObjects, { 100, 100, .T., .T., .F. } )
aAdd( aObjects, { 100, 100, .T., .T., .F. } )
aInfo  := { aSize[1],aSize[2],aSize[3],aSize[4],3,3 }
aPosObj:= MsObjSize( aInfo, aObjects, .T.,.T. )

l800x600 := aSize[5] <= 800

If ExistBlock( "MA200BUT" )
	If Valtype( aUsrBut := Execblock( "MA200BUT", .f., .f. ) ) == "A"
		AEval( aUsrBut, { |x| AAdd( aButtons, x ) } )
	EndIF
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//?onta array com os conteudos dos tree                                ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
SG1->(dbSeek(xFilial("SG1")+cCodOrig))
M200Expl(cCodOrig,cRevOrig,dDtRefOrig,cOpcOrig,1,aEstruOri,0)
SG1->(dbSeek(xFilial("SG1")+cCodDest))
M200Expl(cCodDest,cRevDest,dDtRefDest,cOpcDest,1,aEstruDest,0)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//?guala os arrays de origem e destino da comparacao                   ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
Mt200CpAr(aEstruOri,aEstruDest,cCodOrig,cCodDest)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//?escricao do Produto Origem e Destino                                ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
If SB1->(MsSeek(xFilial("SB1")+cCodOrig))
	cDescOri:=SB1->B1_DESC
EndIf

If SB1->(MsSeek(xFilial("SB1")+cCodDest))
	cDescDest:=SB1->B1_DESC
EndIf

DEFINE MSDIALOG oDlg TITLE OemToAnsi("Dados Originais") FROM -20,-50 TO aSize[6]-50,aSize[5]-70 OF oMainWnd PIXEL
	@ aPosObj[1,1],aPosObj[1,2] TO If(l800x600,070,060),aPosObj[1,4]-7 LABEL OemToAnsi("Dados Originais") OF oDlg PIXEL //"Dados Originais"

	@ aPosObj[1,1]+10,028 MSGET cCodOrig   When .F. SIZE 105,09 OF oDlg PIXEL
	@ aPosObj[1,1]+26,158 MSGET cRevOrig   Picture PesqPict("SC2","C2_REVISAO") When .F. SIZE 15,09 OF oDlg PIXEL
	@ aPosObj[1,1]+10,194 MSGET dDtRefOrig Picture PesqPict("SD3","D3_EMISSAO") When .F. SIZE 44,09 OF oDlg PIXEL

	@ aPosObj[1,1]+12,006 SAY OemtoAnsi("Produto")  SIZE 24,7  OF oDlg PIXEL //"Produto"
	@ aPosObj[1,1]+28,135 SAY OemToAnsi("Revisao")  SIZE 32,13 OF oDlg PIXEL //"Revisao"
	@ aPosObj[1,1]+12,152 SAY OemToAnsi("Data Referencia")  SIZE 50,09 OF oDlg PIXEL //"Data Referencia"

	@ aPosObj[1,1]+26,194 MSGET cOpcOrig   When .F. SIZE 35,09 OF oDlg PIXEL
	@ aPosObj[1,1]+28,182 SAY OemtoAnsi("Opc.")   SIZE 24,7  OF oDlg PIXEL
	@ aPosObj[1,1]+28,006 SAY OemtoAnsi(cDescOri) SIZE 130,6 Color CLR_HRED OF oDlg PIXEL

	@ aPosObj[2,1], aPosObj[2,2]-8 TO If(l800x600,070,060),aPosObj[2,4]-8 LABEL OemToAnsi("Dados para Comparacao") OF oDlg PIXEL //"Dados para Comparacao"

	@ aPosObj[2,1]+10,aPosObj[2,2]+015 MSGET cCodDest   When .F. SIZE 105,9 OF oDlg PIXEL
	@ aPosObj[2,1]+26,aPosObj[2,2]+152 MSGET cRevDest   Picture PesqPict("SC2","C2_REVISAO") When .F.  SIZE 15,09 OF oDlg PIXEL
	@ aPosObj[2,1]+10,aPosObj[2,2]+190 MSGET dDtRefDest Picture PesqPict("SD3","D3_EMISSAO") When .F. SIZE 44,09 OF oDlg PIXEL

	@ aPosObj[2,1]+12,aPosObj[2,2]-006 SAY OemToAnsi("Produto")   SIZE 24,7  OF oDlg PIXEL //"Produto"
	@ aPosObj[2,1]+28,aPosObj[2,2]+130 SAY OemToAnsi("Revisao")   SIZE 32,13 OF oDlg PIXEL //"Revisao"
	@ aPosObj[2,1]+12,aPosObj[2,2]+147 SAY OemToAnsi("Data Referencia")   SIZE 50,09 OF oDlg PIXEL //"Data Referencia"

	@ aPosObj[2,1]+26,aPosObj[2,2]+190 MSGET cOpcDest   When .F. SIZE 35,09 OF oDlg PIXEL
	@ aPosObj[2,1]+28,aPosObj[2,2]+178 SAY OemtoAnsi("Opc.")    SIZE 24,7  OF oDlg PIXEL
	@ aPosObj[2,1]+28,aPosObj[2,2]-006 SAY OemtoAnsi(cDescDest) SIZE 130,6 Color CLR_HRED OF oDlg PIXEL

	oTree:= dbTree():New(aPosObj[1,1]+If(l800x600,060,050), aPosObj[1,2],aPosObj[1,3]-10,aPosObj[1,4]-10, oDlg,,,.T.)
	oTree:lShowHint := .F.
	u_xA2TreeCm(oTree,aEstruOri,NIL,NIL)
	oTree2:=dbTree():New(aPosObj[2,1]+If(l800x600,060,050), aPosObj[2,2]-10,aPosObj[2,3]-10,aPosObj[2,4]-10, oDlg,,,.T.)
	oTree:lShowHint := .F.
	u_xA2TreeCm(oTree2,aEstruDest,NIL,NIL)
	AAdd( aButtons, { "PMSSETADOWN", { || Mt200Nav(1,@oTree,@oTree2,aEstruOri,aEstruDest) },OemToAnsi("Desce")} ) //"Desce"
	AAdd( aButtons, { "PMSSETAUP"  , { || Mt200Nav(2,@oTree,@oTree2,aEstruOri,aEstruDest) },OemToAnsi("Sobe")} ) //"Sobe"
	AAdd( aButtons, { "DBG09"      , { || Mt200Inf() }, "Legenda" } ) //"Legenda"
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {||oDlg:End()} ,{||oDlg:End()},,aButtons)
Return Nil

/*
Rotina: M200Expl
Faz a explosao de uma estrutura para comparacao.
*/
STATIC Function M200Expl(cProduto,cRevisao,dDataRef,cOpcionais,nQuantPai,aEstru,nNivelEstr)
LOCAL nReg:=0,nQuantItem:=0,nHistorico:=4 // Produto ok
LOCAL nNivelBase := 999
LOCAL lExistBlock := ExistBlock("M200NIV")
LOCAL nRet

// Estrutura do array
// [1] Produto PAI
// [2] Componente
// [3] TRT
// [4] Quantidade
// [5] Historico
// [6] Nivel
// [7] Cargo = [6]+[2]+[3]
// [8] Revisao inicial
// [9] Revisao final

dbSelectArea("SB1")
dbSetOrder(1)
dbSelectArea("SG1")
dbSetOrder(1)
While !Eof() .And. G1_FILIAL+G1_COD == xFilial("SG1")+cProduto
	nReg := Recno()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//?Calcula a qtd dos componentes                   ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	nHistorico := 4
	nQuantItem := ExplEstr(nQuantPai,dDataRef,cOpcionais,cRevisao,@nHistorico)
	dbSelectArea("SG1")
	SB1->(dbSeek(xFilial("SB1")+SG1->G1_COMP))
	If QtdComp(nQuantItem) < QtdComp(0)
		nQuantItem:=If(QtdComp(RetFldProd(SB1->B1_COD,"B1_QB"))>0,RetFldProd(SB1->B1_COD,"B1_QB"),1)
	EndIf
	AADD(aEstru,{SG1->G1_COD,SG1->G1_COMP,SG1->G1_TRT,nQuantItem,nHistorico,nNivelEstr,StrZero(nNivelEstr,5,0)+SG1->G1_COMP+SG1->G1_TRT,SG1->G1_REVINI,SG1->G1_REVFIM})
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//?Verifica se existe sub-estrutura                ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	dbSelectArea("SG1")
	If dbSeek(xFilial("SG1")+SG1->G1_COMP)
		nNivelEstr++
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//?onto de entrada para definir o nivel de comparacao                     ?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lExistBlock
			nRet := (ExecBlock("M200NIV",.F.,.F.))
			If ( Valtype(nRet) == "N" )
				nNivelBase := nRet
			EndIf
		EndIf

		If nNivelEstr <= nNivelBase
			M200Expl(SG1->G1_COD,SB1->B1_REVATU,dDataRef,cOpcionais,nQuantItem,aEstru,nNivelEstr)
		EndIf
		nNivelEstr--
	EndIf
	dbGoto(nReg)
	dbSkip()
EndDo
Return(.T.)

/*
Rotina: Mt200CpAr
Compara e ajusta os arrays de origem e destino.
*/
Static Function Mt200CpAr(aEstruOri,aEstruDest,cCodOrig,cCoddest)
Local nz:=0,nw:=0,nAcho:=0
Local cProcura:="",lFirstLevel:=.F.

// Estrutura do array
// [1] Produto PAI
// [2] Componente
// [3] TRT
// [4] Quantidade
// [5] Historico
// [6] Nivel
// [7] Cargo = [6]+[2]+[3]
// [8] Revisao inicial
// [9] Revisao final

// Compara os elementos em comum do array
// Adiciona no array origem os componentes do array destino diferentes
For nz:=1 To Len(aEstruDest)
	// Verifica se esta no primeiro nivel
	If aEstruDest[nz,6]==0
		lFirstLevel:=.T.
	Else
		lFirstLevel:=.F.
	EndIf
	// Nao procura o produto pai junto
	If lFirstLevel
		cProcura:=aEstruDest[nz,2]+aEstruDest[nz,3]
	// Procura o produto pai junto
	Else
		cProcura:=aEstruDest[nz,1]+aEstruDest[nz,2]+aEstruDest[nz,3]
	EndIf
	// Efetua procura no array origem
	nAcho:=ASCAN(aEstruOri,{|x| x[6] == aEstruDest[nz,6] .And. (If(lFirstLevel,x[2]+x[3],x[1]+x[2]+x[3]) == cProcura)})
	// Caso nao achou soma componentes no array origem com a estrutura do item
	If nAcho == 0
		For nw:=nz to Len(aEstruDest)
			AADD(aEstruOri,{If(lFirstLevel,If(Len(aEstruOri)> 0,aEstruOri[1,1],cCodOrig),aEstruDest[nw,1]),aEstruDest[nw,2],aEstruDest[nw,3],aEstruDest[nw,4],5,aEstruDest[nw,6],aEstruDest[nw,7],aEstruDest[nw,8],aEstruDest[nw,9]})
			// Desliga flag de primeiro nivel
			If lFirstLevel
				lFirstLevel:=.F.
			EndIf
			If nw == Len(aEstruDest) .Or. (aEstruDest[nz,6] == aEstruDest[nw+1,6])
				nz:=nw
				Exit
			EndIf
		Next nw
	EndIf
Next nz

// Adiciona no array destino os componentes do array origem diferentes
For nz:=1 To Len(aEstruOri)
	// Verifica se esta no primeiro nivel
	If aEstruOri[nz,6]==0
		lFirstLevel:=.T.
	Else
		lFirstLevel:=.F.
	EndIf
	// Nao procura o produto pai junto
	If lFirstLevel
		cProcura:=aEstruOri[nz,2]+aEstruOri[nz,3]
	// Procura o produto pai junto
	Else
		cProcura:=aEstruOri[nz,1]+aEstruOri[nz,2]+aEstruOri[nz,3]
	EndIf
	// Efetua procura no array origem
	nAcho:=ASCAN(aEstruDest,{|x| x[6] == aEstruOri[nz,6] .And. (If(lFirstLevel,x[2]+x[3],x[1]+x[2]+x[3]) == cProcura)})
	// Caso nao achou soma componentes no array origem com a estrutura do item
	If nAcho == 0
		For nw:=nz to Len(aEstruOri)
			AADD(aEstruDest,{If(lFirstLevel,If(Len(aEstruDest)> 0,aEstruDest[1,1],cCodDest),aEstruOri[nw,1]),aEstruOri[nw,2],aEstruOri[nw,3],aEstruOri[nw,4],5,aEstruOri[nw,6],aEstruOri[nw,7],aEstruOri[nw,8],aEstruOri[nw,9]})
			// Desliga flag de primeiro nivel
			If lFirstLevel
				lFirstLevel:=.F.
			EndIf
			If nw == Len(aEstruOri) .Or. (aEstruOri[nz,6] == aEstruOri[nw+1,6])
				nz:=nw
				Exit
			EndIf
		Next nw
	EndIf
Next nz

// Ordena arrays por nivel
ASORT(aEstruOri,,,{|x,y| x[7] < y[7] })
ASORT(aEstruDest,,,{|x,y| x[7] < y[7] })
RETURN(.T.)

/*
Rotina: xA2TreeCm
Monta o objeto TREE - FUNCAO RECURSIVA
*/
USer Function xA2TreeCm(oObjTree,aEstru,cProduto,nz,aDbTree)
Local nAcho:=0
Local aOcorrencia :={}
Local cTexto:=""
Local cCargoVazio:=Space(5+Len(SG1->G1_COMP+SG1->G1_TRT))
Default nz:=1
Default cProduto:=""
Default aDbTree := {}

// Ordem de pesquisa por codigo
SB1->(dbSetOrder(1))

// Array com as ocorrencias cadastradas
AADD(aOcorrencia,"PMSTASK4") //"Componente fora das datas inicio / fim"
AADD(aOcorrencia,"PMSTASK5") //"Componente fora dos grupos de opcionais"
AADD(aOcorrencia,"PMSTASK2") //"Componente fora das revisoes"
AADD(aOcorrencia,"PMSTASK6") //"Componente ok"
AADD(aOcorrencia,"PMSTASK1") //"Componente nao existente"

// Monta tree na primeira vez
If Empty(cProduto) .And. Len(aEstru) > 0
	cProduto:=aEstru[1,1]
	oObjTree:BeginUpdate()
	oObjTree:Reset()
	oObjTree:EndUpdate()
	// Coloca titulo no TREE
	SB1->(dbSeek(xFilial("SB1")+aEstru[1,1]))
	oObjTree:AddTree(AllTrim(aEstru[1,1])+" - "+Alltrim(Substr(SB1->B1_DESC,1,30))+Space(60),.T.,,,aOcorrencia[4],aOcorrencia[4],cCargoVazio)
EndIf

While nz <= Len(aEstru)
	// Verifica se componente tem estrutura
	nAcho:=ASCAN(aEstru,{|x| x[1] == aEstru[nz,2]})
	// Monta Texto
	SB1->(dbSeek(xFilial("SB1")+aEstru[nz,2]))
	cTexto:=Alltrim(aEstru[nz,2])+" - "+AllTrim(Substr(SB1->B1_DESC,1,30))+" / "+'STR0057'+ aEstru[nz,3]+" / "+'STR0058'+aEstru[nz,8]+" - "+aEstru[nz,9]+Space(20)
	If ExistBlock("M200CPTX")
		cM200CPTX := ExecBlock("M200CPTX",.F.,.F.,{cTexto,aEstru[nz][1],aEstru[nz][2],SB1->B1_DESC,aEstru[nz][3],aEstru[nz][4],aEstru[nz][8],aEstru[nz][9]})
		If ValType(cM200CPTX) == "C"
			cTexto := cM200CPTX
		EndIf
	EndIf
	If nAcho > 0
		If Empty(AsCan(aDbTree,{|x|x[1]==cTexto .And. x[2]==aEstru[nz,1] .And. x[3]==aEstru[nz,5] .And. x[4] == aEstru[nz,7] .And. x[5]==nz})) .And. aEstru[nz,1] == cProduto
			Aadd(aDbTree,{cTexto,aEstru[nz,1],aEstru[nz,5],aEstru[nz,7],nz})
			// Coloca titulo no TREE
			oObjTree:AddTree(cTexto,.T.,,,aOcorrencia[aEstru[nz,5]],aOcorrencia[aEstru[nz,5]],aEstru[nz,7])
			// Chama funcao recursiva
			u_xA2TreeCm(oObjTree,aEstru,aEstru[nz,2],nAcho,aDbTree)
			// Encerra TREE
			oObjTree:EndTree()
		EndIf
	ElseIf aEstru[nz,1] == cProduto
		// Adiciona item no tree
		If (!lDif .Or. aEstru[nz,5] <> 4) .And. Empty(AsCan(aDbTree,{|x|x[1]==cTexto .And. x[2]==aEstru[nz,1] .And. x[3]== aEstru[nz,5] .And. x[4]==aEstru[nz,7] .And. x[5]==nz}))
			Aadd(aDbTree,{cTexto,aEstru[nz,1],aEstru[nz,5],aEstru[nz,7],nz})
			oObjTree:AddTreeItem(cTexto,aOcorrencia[aEstru[nz,5]],aOcorrencia[aEstru[nz,5]],aEstru[nz,7])
		EndIf
	EndIf
	nz++
End
RETURN(.T.)

/*
Rotina: Mt200Nav
Mantem o posicionamento das duas estruturas.
*/
Static Function Mt200Nav(nTipo,oTree,oTree2,aEstruOri,aEstruDest)
Local cCargoAtu  :=oTree2:GetCargo()
Local cCargoVazio:=Space(5+Len(SG1->G1_COMP+SG1->G1_TRT))
Local nPos       :=Ascan(aEstruDest,{|x| x[7] == cCargoAtu})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?osiciona o tree na linha de baixo                              ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nTipo == 1 .And. nPos < Len(aEstruDest)
	oTree:TreeSeek(aEstruOri[nPos+1,7])
	oTree2:TreeSeek(aEstruDest[nPos+1,7])
	oTree:Refresh()
	oTree2:Refresh()
ElseIf nTipo == 2 .And. nPos >= 1
	oTree :TreeSeek(If(nPos-1<=0,cCargoVazio,aEstruOri[nPos-1,7]))
	oTree2:TreeSeek(If(nPos-1<=0,cCargoVazio,aEstruDest[nPos-1,7]))
	oTree:Refresh()
	oTree2:Refresh()
Else
	oTree:TreeSeek(If(nPos>0,aEstruOri[nPos,7],cCargoVazio))
	oTree2:TreeSeek(If(nPos>0,aEstruDest[nPos,7],cCargoVazio))
	oTree:Refresh()
	oTree2:Refresh()
EndIf
Return(.T.)

/*
Rotina: Mt200Inf
Legenda do comparador de estruturas.
*/
Static Function Mt200Inf()
Local oDlg,oBmp1,oBmp2,oBmp3,oBmp4,oBmp5
Local oBut1
DEFINE MSDIALOG oDlg TITLE "Legenda" OF oMainWnd PIXEL FROM 0,0 TO 200,550 //"Legenda"
@ 2,3 TO 080,273 LABEL "Legenda" PIXEL //"Legenda"
@ 18,10 BITMAP oBmp1 RESNAME "PMSTASK1" SIZE 16,16 NOBORDER PIXEL
@ 18,20 SAY OemToAnsi('STR0048') OF oDlg PIXEL
@ 18,150 BITMAP oBmp2 RESNAME "PMSTASK6" SIZE 16,16 NOBORDER PIXEL
@ 18,160 SAY OemToAnsi('STR004') OF oDlg PIXEL
@ 30,10 BITMAP oBmp3 RESNAME "PMSTASK2" SIZE 16,16 NOBORDER PIXEL
@ 30,20 SAY OemToAnsi('STR0046') OF oDlg PIXEL
@ 42,10 BITMAP oBmp4 RESNAME "PMSTASK5" SIZE 16,16 NOBORDER PIXEL
@ 42,20 SAY OemToAnsi('STR0045') OF oDlg PIXEL
@ 54,10 BITMAP oBmp5 RESNAME "PMSTASK4" SIZE 16,16 NOBORDER PIXEL
@ 54,20 SAY OemToAnsi('STR0044') OF oDlg PIXEL
DEFINE SBUTTON oBut1 FROM 085,244 TYPE 1  ACTION (oDlg:End())  ENABLE of oDlg
ACTIVATE MSDIALOG oDlg CENTERED
Return(.T.)

/*
Rotina: xA200Subs
Substituicao de componentes na Estrutura.
*/
User Function xA200Subs()

Local aArea    :=GetArea()
Local cCodOrig :=Criavar("G1_COMP" ,.F.),cCodDest :=Criavar("G1_COMP" ,.F.)
Local cGrpOrig :=Criavar("G1_GROPC",.F.),cGrpDest :=Criavar("G1_GROPC",.F.)
Local cDescOrig:=Criavar("B1_DESC" ,.F.),cDescDest:=Criavar("B1_DESC" ,.F.)
Local cOpcOrig :=Criavar("G1_OPC"  ,.F.),cOpcDest :=Criavar("G1_OPC"  ,.F.)
Local oSay,oSay2
Local lOk:=.F.
Local aAreaSX3:=SX3->(GetArea())
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Variavel lPyme utilizada para Tratamento do Siga PyME        ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lPyme:= Iif(Type("__lPyme") <> "U",__lPyme,.F.)
Local oSize
Local oSize2
Local oSize3

dbSelectArea("SX3")
dbSetOrder(2)
If dbSeek("G1_OK")
	dbSelectArea("SX3")//manter provisoriamente por causa da mark browse
	dbSetOrder(1) //voltar para indice 1 do sx3
	dbSelectArea("SG1")
	DEFINE MSDIALOG oDlg FROM  140,000 TO 358,615 TITLE OemToAnsi("Substituicao de Componentes") PIXEL //"Substituicao de Componentes"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//?Calcula dimens?s Em linha                                   ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSize := FwDefSize():New(.T.,,,oDlg)
	oSize:AddObject( "LABEL1" 	,  100, 50, .T., .T. ) // Totalmente dimensionavel 
	oSize:AddObject( "LABEL2"   ,  100, 50, .T., .T. ) // Totalmente dimensionavel
	
	oSize:lProp 	:= .T. // Proporcional             
	oSize:aMargins 	:= { 6, 6, 6, 6 } // Espaco ao lado dos objetos 0, entre eles 3 

	oSize:Process() 	   // Dispara os calculos   
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//?Calcula dimens?s Em Coluna                                  ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSize2 := FwDefSize():New()
	
	oSize2:aWorkArea := oSize:GetNextCallArea( "LABEL1" ) 
	
	oSize2:AddObject( "ESQ",  100, 50, .T., .T. ) // Totalmente dimensionavel
	oSize2:AddObject( "DIR",  100, 50, .T., .T. ) // Totalmente dimensionavel
	
	oSize2:lLateral := .T. 
	oSize2:lProp 	:= .T. // Proporcional             
	oSize2:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

	oSize2:Process() 	   // Dispara os calculos   
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//?Calcula dimens?s Em Coluna                                  ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSize3 := FwDefSize():New()
	
	oSize3:aWorkArea := oSize:GetNextCallArea( "LABEL2" ) 
	
	oSize3:AddObject( "ESQ",  100, 50, .T., .T. ) // Totalmente dimensionavel
	oSize3:AddObject( "DIR",  100, 50, .T., .T. ) // Totalmente dimensionavel
	
	oSize3:lLateral := .T. 
	oSize3:lProp 	:= .T. // Proporcional             
	oSize3:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

	oSize3:Process() 	   // Dispara os calculos
	
	DEFINE SBUTTON oBtn FROM 800,800 TYPE 5 ENABLE OF oDlg
	@ oSize:GetDimension("LABEL1","LININI"), oSize:GetDimension("LABEL1","COLINI") TO oSize:GetDimension("LABEL1","LINEND"), oSize:GetDimension("LABEL1","COLEND") LABEL OemToAnsi("Componente Original") OF oDlg PIXEL //"Componente Original"
	@ oSize:GetDimension("LABEL2","LININI"), oSize:GetDimension("LABEL2","COLINI") TO oSize:GetDimension("LABEL2","LINEND"), oSize:GetDimension("LABEL2","COLEND") LABEL OemToAnsi("Novo Componente") OF oDlg PIXEL //"Novo Componente"
	@ oSize2:GetDimension("ESQ","LININI")+10, oSize2:GetDimension("ESQ","COLINI")+30 MSGET cCodOrig   F3 "SB1" Picture PesqPict("SG1","G1_COMP") Valid NaoVazio(cCodOrig) .And. ExistCpo("SB1",cCodOrig) .And. A200IniDsc(1,oSay,cCodOrig,cCodDest) SIZE 105,09 OF oDlg PIXEL

	If !lPyme
		@ oSize2:GetDimension("DIR","LININI")+10, oSize2:GetDimension("DIR","COLINI")+40 MSGET cGrpOrig   F3 "SGAPCP" Picture PesqPict("SG1","G1_GROPC") Valid Vazio(cGrpOrig) .Or. ExistCpo("SGA",cGrpOrig) SIZE 15,09 OF oDlg PIXEL
		@ oSize2:GetDimension("DIR","LININI")+10, oSize2:GetDimension("DIR","COLINI")+120 MSGET cOpcOrig   Picture PesqPict("SG1","G1_OPC") Valid IF(!Empty(cGrpOrig),NaoVazio(cOpcOrig).And.ExistCpo("SGA",cGrpOrig+cOpcOrig),Vazio(cOpcOrig)) SIZE 15,09 OF oDlg PIXEL
	EndIf

	@ oSize3:GetDimension("ESQ","LININI")+10, oSize3:GetDimension("ESQ","COLINI")+30 MSGET cCodDest   F3 "SB1" Picture PesqPict("SG1","G1_COMP") Valid NaoVazio(cCodDest) .And. ExistCpo("SB1",cCodDest)  .And. A200IniDsc(2,oSay2,cCodDest,cCodOrig) SIZE 105,9 OF oDlg PIXEL

	If !lPyme
		@ oSize3:GetDimension("DIR","LININI")+10, oSize3:GetDimension("DIR","COLINI")+40 MSGET cGrpDest   F3 "SGAPCP" Picture PesqPict("SG1","G1_GROPC") Valid Vazio(cGrpDest) .Or. ExistCpo("SGA",cGrpDest) SIZE 15,09 OF oDlg PIXEL
		@ oSize3:GetDimension("DIR","LININI")+10, oSize3:GetDimension("DIR","COLINI")+120 MSGET cOpcDest   Picture PesqPict("SG1","G1_OPC") Valid IF(!Empty(cGrpDest),NaoVazio(cOpcDest).And.ExistCpo("SGA",cGrpDest+cOpcDest),Vazio(cOpcDest)) SIZE 15,09 OF oDlg PIXEL
	EndIf

	@ oSize2:GetDimension("ESQ","LININI")+24, oSize2:GetDimension("ESQ","COLINI")+33 SAY oSay Prompt cDescOrig SIZE 130,6 OF oDlg PIXEL
	@ oSize3:GetDimension("ESQ","LININI")+24, oSize3:GetDimension("ESQ","COLINI")+33 SAY oSay2 Prompt cDescDest SIZE 130,6 OF oDlg PIXEL
	@ oSize2:GetDimension("ESQ","LININI")+12, oSize2:GetDimension("ESQ","COLINI") SAY OemtoAnsi("Produto")   SIZE 24,7  OF oDlg PIXEL //"Produto"

	If !lPyme
		@ oSize2:GetDimension("DIR","LININI")+12, oSize2:GetDimension("DIR","COLINI") SAY RetTitle("G1_GROPC") SIZE 42,13 OF oDlg PIXEL
		@ oSize2:GetDimension("DIR","LININI")+12, oSize2:GetDimension("DIR","COLINI")+85 SAY RetTitle("G1_OPC")   SIZE 30,7  OF oDlg PIXEL
	EndIf

	@ oSize3:GetDimension("ESQ","LININI")+12, oSize3:GetDimension("ESQ","COLINI") SAY OemToAnsi("Produto")   SIZE 24,7  OF oDlg PIXEL //"Produto"

	If !lPyme
		@ oSize3:GetDimension("DIR","LININI")+12, oSize3:GetDimension("DIR","COLINI") SAY RetTitle("G1_GROPC") SIZE 42,13 OF oDlg PIXEL
		@ oSize3:GetDimension("DIR","LININI")+12, oSize3:GetDimension("DIR","COLINI")+85 SAY RetTitle("G1_OPC")   SIZE 30,7  OF oDlg PIXEL
	EndIf

	ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{||Iif(u_xA2SubOK(cCodOrig,cGrpOrig,cOpcOrig,cCodDest,cGrpDest,cOpcDest),(lOk:=.T.,oDlg:End()),lOk:=.F.)},{||(lOk:=.F.,oDlg:End())})
	// Processa substituicao dos componentes
	If lOk
		Processa({|| A200PrSubs(cCodOrig,cGrpOrig,cOpcOrig,cCodDest,cGrpDest,cOpcDest) })
	EndIf
Else
	Aviso(OemToAnsi("Atencao"),OemToAnsi("Para utilizacao dessa opcao deve ser criado o campo G1_OK semelhante ao campo C9_OK."),{"Ok"}) //"Atencao"###"Para utilizacao dessa opcao deve ser criado o campo G1_OK semelhante ao campo C9_OK."
EndIf
SX3->(RestArea(aAreaSX3))
RestArea(aArea)
RETURN

/*
Rotina: A200PrSubs
Monta markbowse para selecao e substituicao dos componentes.
*/
Static Function A200PrSubs(cCodOrig,cGrpOrig,cOpcOrig,cCodDest,cGrpDest,cOpcDest)
Local cFilSG1     := ""
Local cQrySG1     := ""
Local aIndexSG1   := {}
Local aBackRotina := ACLONE(aRotina)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Variavel lPyme utilizada para Tratamento do Siga PyME        ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lPyme:= Iif(Type("__lPyme") <> "U",__lPyme,.F.)

PRIVATE aDadosDest:= {cCodDest,cGrpDest,cOpcDest}
PRIVATE cMarca200 := ThisMark()
PRIVATE cCadastro := OemToAnsi('Estrutura OP')
PRIVATE aRotina   := {  {"Substituir","u_xA200DoSub", 0 , 1}} //"Substituir"

cFilSG1 := "G1_FILIAL='"+xFilial("SG1")+"'"
cFilSG1 += ".And.G1_COMP=='"+cCodOrig+"'"

If !lPyme
	cFilSG1 += ".And.G1_GROPC=='"+cGrpOrig+"'"
	cFilSG1 += ".And.G1_OPC=='"+cOpcOrig+"'"
EndIf

If !IsProdProt(cCodOrig) .And. !IsProdProt(cCodDest)
	cFilSG1 += " .And. .T. "
Else
	cFilSG1 += " .And. .F. "
Endif	

cQrySg1 := "G1_FILIAL='"+xFilial("SG1")+"'"
cQrySg1 += " AND G1_COMP='"+cCodOrig+"'"

If !lPyme
	cQrySg1 += " AND G1_GROPC='"+cGrpOrig+"'"
	cQrySg1 += " AND G1_OPC='"+cOpcOrig+"'"
EndIf

cQrySg1 += " AND (SELECT COUNT(*) FROM " +RetSQLName("SB5") +" SB5 WHERE SB5.D_E_L_E_T_ <> '*' AND "
cQrySg1 += "SB5.B5_FILIAL = '" +xFilial("SB5") +"' AND SB5.B5_COD = G1_COD AND SB5.B5_PROTOTI = 'F') = 0"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?ealiza a Filtragem                                                     ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SG1")
dbSetOrder(1)

dbSelectArea("SG1")
If !MsSeek(xFilial("SG1"))
	HELP(" ",1,"RECNO")
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//?onta o browse para a selecao                                           ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MarkBrow("SG1","G1_OK",,,,,,,,,,,cQrySG1,,,,,cFilSG1)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?estaura condicao original                                              ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SG1")
RetIndex("SG1")
dbClearFilter()
aEval(aIndexSG1,{|x| Ferase(x[1]+OrdBagExt())})
aRotina:=ACLONE(aBackRotina)
Return Nil

/*
Rotina: xA200DoSub
Grava a substituicao dos componentes.
*/
USer Function xA200DoSub(cAlias,nRecno,nOpc,cMarca200,lInverte)
Local aRecnosSG1:= {}
Local aRecnosSGF:= {}
Local aAreaSGF	:= SGF->(GetArea())
Local lRet		:= .F.
Local nRecnoSGF
Local nz:=0

SGF->(dbSetOrder(2))
dbSelectArea("SG1")
dbSeek(xFilial("SG1"))
While !Eof() .And. G1_FILIAL == xFilial("SG1")
	// Verifica os registros marcados para substituicao
	If IsMark("G1_OK",cMarca200,lInverte)
		lRet := .T.

		// Valida SGF - Oper. x Compon.
		SGF->(dbSeek(xFilial("SGF")+SG1->G1_COD))
		While SGF->(!Eof()) .And. SGF->(GF_FILIAL) == xFilial("SGF") .And. SGF->GF_PRODUTO == SG1->G1_COD
			If SGF->GF_COMP == SG1->G1_COMP // Encontra o componente a ser substituido
				nRecnoSGF := SGF->(Recno())
				If SGF->(dbSeek(xFilial("SGF")+SG1->G1_COD+SGF->GF_ROTEIRO+aDadosDest[1]))
					Help(" ",1,"u_xA200Subs",, AllTrim(RetTitle("GF_PRODUTO"))+": "+AllTrim(SG1->G1_COD)+"   "+;
					AllTrim(RetTitle("GF_ROTEIRO"))+": "+SGF->GF_ROTEIRO+"   "+;
					AllTrim(RetTitle("GF_COMP"))+": "+AllTrim(aDadosDest[1]), 4, 0) //J?existe o componente destino para o mesmo roteiro no cad. de Operação x Componente
					lRet := .F.
					Exit
				EndIf
				SGF->(dbGoto(nRecnoSGF))
				AADD(aRecnosSGF,nRecnoSGF)
			EndIf
			SGF->(dbSkip())
		EndDo
		If !lRet
			Exit
		EndIf

		AADD(aRecnosSG1,Recno())
	EndIf
	dbSkip()
EndDo

If lRet

	// Grava a substituicao de componentes
	if Len(aRecnosSG1) < 1001  //tratamento para oracle pois tem limite de 1000 itens no "IN"
		cQuery := "UPDATE "
		cQuery += RetSqlName("SG1")+" "
		cQuery += "SET G1_COMP = '"+aDadosDest[1]+"' , G1_GROPC = '"+aDadosDest[2]+"' , G1_OPC = '"+aDadosDest[3]+"'"
		cQuery += " WHERE G1_COD <> '"+aDadosDest[1]+"' AND R_E_C_N_O_ IN ("
		For nz:=1 to Len(aRecnosSG1)
			If nz > 1
				cQuery+= ","
			EndIf
			cQuery+= "'"+Str(aRecnosSG1[nz],10,0)+"'"
		Next nz
		cQuery += ")"
		//-- NAO efetua o UPDATE, caso a estrutura ja possua o NOVO componente
		cQuery += " AND G1_COD NOT IN ( SELECT G1_COD "
		cQuery += " FROM " + RetSqlName("SG1")  + " SG12 "
	   	cQuery += " WHERE SG12.G1_FILIAL = '" + xFilial('SG1')+ "'"
		cQuery += " AND SG12.G1_COMP = '"+aDadosDest[1]+"'"
		cQuery += " AND SG12.G1_GROPC = '"+aDadosDest[2]+"'"
		cQuery += " AND SG12.G1_OPC = '"+aDadosDest[3]+"'"
		cQuery += " AND SG12.D_E_L_E_T_ = ' ' )"

		TcSqlExec(cQuery)
	Else
		For nz:=1 to Len(aRecnosSG1)
			cQuery := "UPDATE "
			cQuery += RetSqlName("SG1")+" "
			cQuery += "SET G1_COMP = '"+aDadosDest[1]+"' , G1_GROPC = '"+aDadosDest[2]+"' , G1_OPC = '"+aDadosDest[3]+"'"
			cQuery += " WHERE G1_COD <> '"+aDadosDest[1]+"' AND R_E_C_N_O_ = "
			cQuery += "'"+Str(aRecnosSG1[nz],10,0)+"'"
			cQuery += " AND G1_COD NOT IN ( SELECT G1_COD "
			cQuery += " FROM " + RetSqlName("SG1")  + " SG12 "
		   	cQuery += " WHERE SG12.G1_FILIAL = '" + xFilial('SG1')+ "'"
			cQuery += " AND SG12.G1_COMP = '"+aDadosDest[1]+"'"
			cQuery += " AND SG12.G1_GROPC = '"+aDadosDest[2]+"'"
			cQuery += " AND SG12.G1_OPC = '"+aDadosDest[3]+"'"
			cQuery += " AND SG12.D_E_L_E_T_ = ' ' )"

			TcSqlExec(cQuery)
		Next nz
	EndIF

	// Grava a substituicao de componentes na tabela SGF
	dbSelectArea("SGF")
	For nz:=1 to Len(aRecnosSGF)
		dbGoto(aRecnosSGF[NZ])
		Reclock("SGF",.F.)
		Replace GF_COMP With aDadosDest[1]
		MsUnlock()
	Next nz
	dbSelectArea("SG1")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//| M200SUB - Ponto de entrada executado apos a gravacao  |
	//|           da substituicao dos componentes             |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	If ExistBlock("M200SUB")
		ExecBlock("M200SUB",.F.,.F.,aRecnosSG1)
	EndIf

	// Altera conteudo do parametro de niveis
	If Len(aRecnosSG1) > 0
		u_xa2NivAlt()
	EndIf

EndIf
SGF->(RestArea(aAreaSGF))

Return

/*
Rotina: ProcP
Procura por uma palavra chave em um array padrao para
rotina automatica, pois na primeira coluna sempre eh infor-
mado o codigo chave de campo ou variavel.
*/
Static Function ProcP(aPilha,cCampo)
Return aScan(aPilha,{|x|Trim(x[1])== cCampo })

/*
Rotina: NextNivel
Explode o Proximo Nivel da Estrutura
*/
Static Function NextNivel(nOpcX, cCargo, oTree, oDlg, aKey,aBkey)
Local cProduto := Substr( cCargo, Len(SG1->G1_COD+SG1->G1_TRT) + 1, Len(SG1->G1_COMP))
Local cTRTPai  := ""
Local cPrompt  := ""
Local dValIni  := CtoD('  /  /  ')
Local dValFim  := CtoD('  /  /  ')
Local cFolderA, cFolderB
Local nX	   := {0}
Local lM200BMP := ExistBlock("M200BMP")
Local uRet     := Nil
Local aOpc     := {}
Local cOpc     := ""

//--Desativa Tecla de atalho
For nX := 1 to len(aKey)
	Set Key aKey[nX] to
Next nX

If Right(cCargo, 4) == 'COMP'
	SG1->(dbSetOrder(1))
	If SG1->(dbSeek(xFilial('SG1') + cProduto, .F.))

		Do While !SG1->(Eof()) .And. SG1->G1_FILIAL+SG1->G1_COD == xFilial("SG1")+cProduto

			//-- Posiciona no SB1
			SB1->(dbSetOrder(1))
			If SB1->(dbSeek(xFilial('SB1') + SG1->G1_COMP, .F.))
				cPrompt := AllTrim(SG1->G1_COMP) + " - " + SB1->B1_DESC + Space(Len(SB1->B1_COD) - Len(AllTrim(SG1->G1_COMP)))
				If cRevisao == Nil
					cRevisao := SB1->B1_REVATU
				EndIf
			EndIf

			//-- Nao Adiciona Componentes fora da Revisao
			If (nOpcX == 2 .Or. nOpcX == 4) .And. (cRevisao # Nil) .And. ;
				!(SG1->G1_REVINI <= cRevisao .And. SG1->G1_REVFIM >= cRevisao)
				SG1->(dbSkip())
				Loop
			EndIf

			cTRTPai  := If(cTRTPai==Nil,SG1->G1_TRT,cTRTPai)
			dValIni  := SG1->G1_INI
			dValFim  := SG1->G1_FIM
			nQtdeSG1 := SG1->G1_QUANT

	        //-- Define as Pastas a serem usadas
			cFolderA := 'FOLDER5'
			cFolderB := 'FOLDER6'
			If Right(cCargo, 4) == 'COMP' .And. ;
				(dDataBase < dValIni .Or. dDataBase > dValFim)
				cFolderA := 'FOLDER7'
				cFolderB := 'FOLDER8'
			EndIf

			cCargo := SG1->G1_COD + SG1->G1_TRT + SG1->G1_COMP + StrZero(SG1->(Recno()), 9) + StrZero(nIndex, 9)  + 'COMP'
			
			If GetMV("MV_SELEOPC") == "S"
           cOpc := Padr(SG1->G1_GROPC, TamSX3("G1_GROPC")[1]) + Padr(SG1->G1_OPC, TamSX3("G1_OPC")[1]) + "/"
           aOpc := aClone(ListOpc(Nil,Nil,cOpc))
        EndIf

			If lM200BMP
				uRet := Execblock("M200BMP", .F., .F., {cPrompt, cFolderA, cFolderB})
				If ValType(uRet) == "A"
					cFolderA := uRet[1]
					cFolderB := uRet[2]
				EndIf
			EndIf

			If !oTree:TreeSeek(cCargo)
				//-- Adiciona um Nivel a Estrutura
				oTree:AddItem(u_xA2Prompt(cPrompt, cCargo, nQtdeSG1,,aOpc), cCargo, cFolderA, cFolderB,,, 2)
			EndIf
			SG1->(dbSkip())
		EndDo
	Else
		Aviso("Atencao!","Componente nao possui Nivel Inferior.",{'OK'},2) //"Atencao!"##"Componente nao possui Nivel Inferior."##"Ok"
	EndIf
Else
	Aviso("Atencao!","Selecione um componente do Nivel Inferior, para explodir seu proximo Nivel.",{"Ok"},2) //"Atencao!"##"Selecione um componente do Nivel Inferior, para explodir seu proximo Nivel."##"Ok"
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Seta tecla de atalho		                                 ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Ma200StKey(aKey,aBkey)

Return

/*
Rotina: A200FanInv
Retorna um PA valido ignorando os fantasmas.
*/
Static Function A200FanInv(cComp,oTree)
Local aArea   := GetArea()
Local cRet    := CriaVar("G1_COD",.F.)
Local cPAQuebr:= ""
Local cNodeID := oTree:CurrentNodeID

While Empty(cRet) .And. Val(oTree:CurrentNodeID) > 0
	cPAQuebr := Substr(oTree:GetCargo(),1,TamSX3("G1_COD")[1])
	If SB1->(dbSeek(xFilial("SB1")+cPAQuebr)) .And. RetFldProd(SB1->B1_COD,"B1_FANTASM") # "S" // Projeto Implementeacao de campos MRP e FANTASM no SBZ
		cRet := cPAQuebr
	EndIf
	While Substr(oTree:GetCargo(),1,TamSX3("G1_COD")[1]) == cPAQuebr
		oTree:CurrentNodeID := StrZero(Val(oTree:CurrentNodeID)-1,7)
	End
End

oTree:CurrentNodeID := cNodeID
RestArea(aArea)

Return cRet

/*
Rotina: MyMATA200
Rotina de teste da rotina automatica do programa MATA200.
*/
User Function MyMATA200(nOpc)
Local aCab  :={}
Local aItem := {}
Local aGets	:= {}
Local lOK	:= .T.
Local cString
Private lMsErroAuto := .F.
Default nOpc := 3

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Abertura do ambiente                                         |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" MODULO "PCP" TABLES "SB1","SG1","SG5"
ConOut(Repl("-",80))
ConOut(PadC("Teste de rotina automatica para estrutura de produtos",80))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Verificacao do ambiente para teste                           |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SB1")
dbSetOrder(1)
If !SB1->(MsSeek(xFilial("SB1")+"PA001"))
	lOk := .F.
	ConOut("Cadastrar produto acabado: PA001")
EndIf

If !SB1->(MsSeek(xFilial("SB1")+"PI001"))
	lOk := .F.
	ConOut("Cadastrar produto intermediario: PI001")
EndIf

If !SB1->(MsSeek(xFilial("SB1")+"PI002"))
	lOk := .F.
	ConOut("Cadastrar produto intermediario: PI002")
EndIf

If !SB1->(MsSeek(xFilial("SB1")+"PI003"))
	lOk := .F.
	ConOut("Cadastrar produto intermediario: PA003")
EndIf


If !SB1->(MsSeek(xFilial("SB1")+"MP001"))
	lOk := .F.
	ConOut("Cadastrar produto materia prima: MP001")
EndIf

If !SB1->(MsSeek(xFilial("SB1")+"MP002"))
	lOk := .F.
	ConOut("Cadastrar produto materia prima: MP002")
EndIf

If !SB1->(MsSeek(xFilial("SB1")+"MP003"))
	lOk := .F.
	ConOut("Cadastrar produto materia prima: MP003")
EndIf

If !SB1->(MsSeek(xFilial("SB1")+"MP004"))
	lOk := .F.
	ConOut("Cadastrar produto materia prima: MP004")
EndIf
If nOpc==3
	aCab := {	{"G1_COD"		,"PA001"			,NIL},;
				{"G1_QUANT"		,1		     		,NIL},;
				{"NIVALT"		,"S"				,NIL}} //A variavel NIVALT eh utilizada pra recalcular ou nao a estrutura

	aGets := {}
	aadd(aGets,	{"G1_COD"		,"PA001"			,NIL})
	aadd(aGets,	{"G1_COMP"		,"PI001" 			,NIL})
	aadd(aGets,	{"G1_TRT"		,Space(3)			,NIL})
	aadd(aGets,	{"G1_QUANT"		,1					,NIL})
	aadd(aGets,	{"G1_PERDA"		,0					,NIL})
	aadd(aGets,	{"G1_INI"		,CTOD("01/01/01")	,NIL})
	aadd(aGets,	{"G1_FIM"		,CTOD("31/12/49")	,NIL})
	aadd(aItem,aGets)

	aGets := {}
	aadd(aGets,	{"G1_COD"		,"PI001" 			,NIL})
	aadd(aGets,	{"G1_COMP"		,"PI002" 			,NIL})
	aadd(aGets,	{"G1_TRT"		,Space(3)			,NIL})
	aadd(aGets,	{"G1_QUANT"		,1					,NIL})
	aadd(aGets,	{"G1_PERDA"		,0					,NIL})
	aadd(aGets,	{"G1_INI"		,CTOD("01/01/01")	,NIL})
	aadd(aGets,	{"G1_FIM"		,CTOD("31/12/49")	,NIL})
	aadd(aItem,aGets)

	aGets := {}
	aadd(aGets,	{"G1_COD"		,"PI001"			,NIL})
	aadd(aGets,	{"G1_COMP"		,"MP002"			,NIL})
	aadd(aGets,	{"G1_TRT"		,Space(3)			,NIL})
	aadd(aGets,	{"G1_QUANT"		,1					,NIL})
	aadd(aGets,	{"G1_PERDA"		,0					,NIL})
	aadd(aGets,	{"G1_INI"		,CTOD("01/01/01")	,NIL})
	aadd(aGets,	{"G1_FIM"		,CTOD("31/12/49")	,NIL})
	aadd(aItem,aGets)

	aGets := {}
	aadd(aGets,	{"G1_COD"		,"PI002"	   		,NIL})
	aadd(aGets,	{"G1_COMP"		,"MP001"			,NIL})
	aadd(aGets,	{"G1_TRT"		,Space(3)			,NIL})
	aadd(aGets,	{"G1_QUANT"		,1					,NIL})
	aadd(aGets,	{"G1_PERDA"		,0					,NIL})
	aadd(aGets,	{"G1_INI"		,CTOD("01/01/01")	,NIL})
	aadd(aGets,	{"G1_FIM"		,CTOD("31/12/49")	,NIL})
	aadd(aItem,aGets)

	aGets := {}
	aadd(aGets,	{"G1_COD"		,"PA001"			,NIL})
	aadd(aGets,	{"G1_COMP"		,"PI003" 			,NIL})
	aadd(aGets,	{"G1_TRT"		,Space(3)			,NIL})
	aadd(aGets,	{"G1_QUANT"		,1					,NIL})
	aadd(aGets,	{"G1_PERDA"		,0					,NIL})
	aadd(aGets,	{"G1_INI"		,CTOD("01/01/01")	,NIL})
	aadd(aGets,	{"G1_FIM"		,CTOD("31/12/49")	,NIL})
	aadd(aItem,aGets)

	aGets := {}
	aadd(aGets,	{"G1_COD"		,"PA001"			,NIL})
	aadd(aGets,	{"G1_COMP"		,"MP004" 			,NIL})
	aadd(aGets,	{"G1_TRT"		,Space(3)			,NIL})
	aadd(aGets,	{"G1_QUANT"		,1					,NIL})
	aadd(aGets,	{"G1_PERDA"		,0					,NIL})
	aadd(aGets,	{"G1_INI"		,CTOD("01/01/01")	,NIL})
	aadd(aGets,	{"G1_FIM"		,CTOD("31/12/49")	,NIL})
	aadd(aItem,aGets)

	aGets := {}
	aadd(aGets,	{"G1_COD"		,"PI003"			,NIL})
	aadd(aGets,	{"G1_COMP"		,"MP003" 			,NIL})
	aadd(aGets,	{"G1_TRT"		,Space(3)			,NIL})
	aadd(aGets,	{"G1_QUANT"		,1					,NIL})
	aadd(aGets,	{"G1_PERDA"		,0					,NIL})
	aadd(aGets,	{"G1_INI"		,CTOD("01/01/01")	,NIL})
	aadd(aGets,	{"G1_FIM"		,CTOD("31/12/49")	,NIL})
	aadd(aItem,aGets)
	If lOk
		ConOut("Teste de Inclusao")
		ConOut("Inicio: "+Time())
		MSExecAuto({|x,y,z| mata200(x,y,z)},aCab,aItem,3) //Inclusao
		ConOut("Fim: "+Time())
	EndIf
Else
	//--------------- Exemplo de Exclusao ------------------------------------
	If lOk
		aCab := {	{"G1_COD"		,"PA001"			,NIL},;
		            {"NIVALT"		,"S"				,NIL}} //A variavel NIVALT eh utilizada pra recalcular ou nao a estrutura
		ConOut("Teste de Exclusao do codigo PA001")
		ConOut("Inicio: "+Time())
		MSExecAuto({|x,y,z| mata200(x,y,z)},aCab,NIL,5) //Exclusao
		lOk := !lMsErroAuto
		ConOut("Fim: "+Time())
	EndIf
	If lOk
		aCab := {	{"G1_COD"		,"PI001"			,NIL},;
					{"NIVALT"		,"S"				,NIL}} //A variavel NIVALT eh utilizada pra recalcular ou nao a estrutura
		ConOut("Teste de Exclusao do codigo PI001")
		ConOut("Inicio: "+Time())
		MSExecAuto({|x,y,z| mata200(x,y,z)},aCab,NIL,5) //Exclusao
		lOk := !lMsErroAuto
		ConOut("Fim: "+Time())
	EndIf
	If lOk
		aCab := {	{"G1_COD"		,"PI002"			,NIL},;
					{"NIVALT"		,"S"				,NIL}} //A variavel NIVALT eh utilizada pra recalcular ou nao a estrutura
		ConOut("Teste de Exclusao do codigo PI002")
		ConOut("Inicio: "+Time())
		MSExecAuto({|x,y,z| mata200(x,y,z)},aCab,NIL,5) //Exclusao
		lOk := !lMsErroAuto
		ConOut("Fim: "+Time())
	EndIf
	If lOk
		aCab := {	{"G1_COD"		,"PI003"			,NIL},;
					{"NIVALT"		,"S"				,NIL}} //A variavel NIVALT eh utilizada pra recalcular ou nao a estrutura
		ConOut("Teste de Exclusao do codigo PI003")
		ConOut("Inicio: "+Time())
		MSExecAuto({|x,y,z| mata200(x,y,z)},aCab,NIL,5) //Exclusao
		ConOut("Fim: "+Time())
	EndIf
EndIf
If lMsErroAuto
	If IsBlind()
		If IsTelnet()
			VTDispFile(NomeAutoLog(),.t.)
		Else
			cString := MemoRead(NomeAutoLog())
			Aviso("Aviso de Erro:",cString)
		EndIf
	Else
		MostraErro()
	EndIf
Else
	If lOk
		Aviso("Aviso","Incluido com sucesso",{"Ok"})
	Else
		Aviso("Aviso","Fazer os devidos cadastros",{"Ok"})
	EndIf
Endif
Return

/*
Rotina: Ma200StKey
Responsael por setar as teclas de atalhos na navegacao
do Tree da estrutura.
*/
Static Function Ma200StKey(aKey,aBkey)
Local nX :=0
Local nY :=0
Default aKey := {}
Default aBkey:= {}

For nX := 1 To Len(aKey)
	For nY:=1 to Len(aBkey)
   		If aKey[nX] == aBkey[nY][2]
   		    SetKey(aKey[nX], aBkey[nY][1])
   		EndIf
    Next nY
Next nX
Return

/*
Rotina: A200IniDsc
Inicializa a descricao dos codigos digitados.
*/
Static Function A200IniDsc(nOpcao,oSay,cProduto,cProdDesOr)
Local aEstruOrig := {}
Local lRet		 := .T.

Default cProdDesOr := Criavar("G1_COMP",.F.)

Private nEstru   := 0

SB1->(MsSeek(xFilial("SB1")+cProduto))

If nOpcao == 1
	cDescOrig:=SB1->B1_DESC
	// Preenche descricao do produto
	oSay:SetText(cDescOrig)
ElseIf nOpcao == 2
	cDescDest:=SB1->B1_DESC
	// Preenche descricao do produto
	oSay:SetText(cDescDest)
EndIf
// Troca a cor do texto para vermelho
oSay:SetColor(CLR_HRED,GetSysColor(15))

If !Empty(cProdDesOr)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//?Os produtos origem e destino foram informados. Explode sempre o produto destino. ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aEstruOrig := Estrut( If(nOpcao == 2,cProduto,cProdDesOr) ,1)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//?Verifica se o produto origem ja' existe na estrutura do produto destino			 ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (aScan(aEstruOrig,{|x| x[3] == If(nOpcao == 2,cProdDesOr,cProduto) }) > 0)
		Help(' ',1,'A200NODES')
		lRet := .F.
	EndIf
EndIf

Return (lRet)

/*
Rotina: A200AltRev
Atualiza o cadastro de revisoes da estrutura de todos os
componemntes alterados.
*/
Static Function A200AltRev( aAltRev )

Local aArea		:= GetArea()
Local aAreaSG1	:= SG1->(GetArea())
Local aCampos	:= SG1->(dbStruct())
Local nPosCod	:= Ascan( aCampos, {|x| x[1] == "G1_COD"} )
Local aCod		:= {}
Local nX		:= 0

If nPosCod > 0
	For nX := 1 To Len( aAltRev )
		If aAltRev[nX,1] > 0 .And. aAltRev[nX,1] <= SG1->(LastRec())
			SG1->(dbGoto(aAltRev[nX,1]))
			If aScan(aCod, SG1->G1_COD) == 0
				AADD(aCod, SG1->G1_COD)
			Endif
		Endif
	Next nX
	For nX := 1 To Len( aCod )
		If aCod[nX] <> cProduto
			u_xA2Revis( aCod[nX], .F. )
		Endif
	Next
Endif

RestArea( aAreaSG1 )
RestArea( aArea )
Return

/*
Rotina: xA2SubOK
Validação Final da Substituicao de Estrutura.
*/
USer Function xA2SubOK(cCodOrig,cGrpOrig,cOpcOrig,cCodDest,cGrpDest,cOpcDest)
Local lRet:=.T.

Do Case
 	Case Vazio(cCodOrig) .Or. !ExistCpo("SB1",cCodOrig)
		lRet:=.F.
		Help('', 1, 'A200PRDORI')
	Case Vazio(cCodDest) .Or. !ExistCpo("SB1",cCodDest)
		lRet:=.F.
		Help('', 1, 'A200PRDDES')
EndCase

Return lRet

/*
Rotina: xA2IntSFC
Atualiza status do produto no SFC para comprado ou fabricado.
*/
USer Function xA2IntSFC(cProduto,cTipo,oModel)
Local aArea   := GetArea()
Local lRet    := .T.
Default oModel  := FWLoadModel("SFCC101")

CZ3->(dbSetOrder(1))
CZ3->(dbSeek(xFilial("CZ3")+cProduto))
oModel:SetOperation(4)

If !(	oModel:Activate() .And. ;								//-- Ativa o modelo
		oModel:SetValue("CZ3MASTER","CZ3_TPAC",cTipo) .And. ;	//-- Seta valor para o campo
		oModel:VldData() .And. ;								//-- Valida modelo
		oModel:CommitData()	)									//-- Efetiva gravacao
	A010SFCErr(oModel)
EndIf

oModel:DeActivate()

RestArea(aArea)
Return lRet

/*
Rotina: A200RevDel
*/
Static Function A200RevDel(cCod,cComp,cTrt,aUndo)
Local lRet   := .F.
Local nX	 := 0
Local nPCOD  := If(l200Auto,aScan(aAutoItens[1],{|x| AllTrim(x[1]) == "G1_COD"}),0)
Local nPTRT  := If(l200Auto,aScan(aAutoItens[1],{|x| AllTrim(x[1]) == "G1_TRT"}),0)
Local nPCOMP := If(l200Auto,aScan(aAutoItens[1],{|x| AllTrim(x[1]) == "G1_COMP"}),0)
Local nPosDel:= 0
Local aAreaSG1 := SG1->(GetArea())

aSort(aUndo, , , {|x,y|x[2] > y[2]})
nPosDel:= aScan(aUndo,{|x|x[2] == 2})

If l200Auto
	lRet := aScan(aAutoItens,{|x| x[nPCOD,2] == cCod .And. x[nPTRT,2] == cTrt .And. x[nPCOMP,2] == cComp}) == 0
Else
	If !oTree:TreeSeek(G1_COD+G1_TRT+G1_COMP)
		If nPosDel == 0
			lRet := .T.
		Else
			While nPosDel <= Len (aUndo) .And. aUndo[nPosDel][2] == 2 .And. !lRet
				SG1->(DbGoTo(aUndo[nPosDel][1]))
				If SG1->G1_COD == cCod .And. SG1->G1_COMP == cComp .And. SG1->G1_TRT == cTrt
					lRet := .T.
				Else
					nPosDel++
				 EndIf
			EndDo
		EndIf
	EndIf
EndIf

RestArea(aAreaSG1)

Return lRet

/*
Rotina: A200Auto4E
Processa exclusao de componentes nao recebidos na nova
estrutura alterada por rotina automatica.
*/
Static Function A200Auto4E(cCod,aUndo,lMudou,aAltEstru,aPaiEstru,lPriNivel)
Local nRecno := 0
Local nPCOD  := aScan(aAutoItens[1],{|x| AllTrim(x[1]) == "G1_COD"})
Local nPTRT  := aScan(aAutoItens[1],{|x| AllTrim(x[1]) == "G1_TRT"})
Local nPCOMP := aScan(aAutoItens[1],{|x| AllTrim(x[1]) == "G1_COMP"})

SG1->(dbSetOrder(1))
While !SG1->(EOF()) .And. SG1->(G1_FILIAL+G1_COD) == xFilial("SG1")+cCod
	//-- Se nao achou item no array da ExecAuto, deleta
	If Empty(aScan(aAutoItens,{|x| x[nPCOD,2] == SG1->G1_COD .And.;
											x[nPCOMP,2] == SG1->G1_COMP .And.;
											x[nPTRT,2] == SG1->G1_TRT}))
		cCargo  := SG1->(G1_COD+G1_TRT+G1_COMP+StrZero(Recno(),9)+StrZero(nIndex++,9)+'COMP')
		T_CARGO := SG1->(G1_COD+G1_TRT+G1_COMP+StrZero(Recno(),9)+StrZero(nIndex++,9)+'COMP')

		Ma200Edita(5,cCargo,NIL,5,@aUndo,@lMudou,@aAltEstru,,,,@aPaiEstru,{})
	ElseIf !lPriNivel
		nRecno := SG1->(Recno())
		If SG1->(dbSeek(xFilial("SG1")+SG1->G1_COMP))
			A200Auto4E(SG1->G1_COD,@aUndo,@lMudou,@aAltEstru,@aPaiEstru,lPriNivel)
		EndIf
		SG1->(dbGoTo(nRecno))
	EndIf
	SG1->(dbSkip())
End

Return

//------------------------------------------------------------------
/*/{Protheus.doc} A200RevSim()
 Busca estrutura similar conforme a revis? informada.
@author Lucas Pereira
@since 22/09/2014
@version 1.0
/*/
//------------------------------------------------------------------
USer Function xARevSim(lGetRevisao, oDlg, oTree, cProduto, cCodSim, cRevisao, nOpcX, lReAuto, aPaiEstru)
Default lReAuto   := .F.
Default aPaiEstru := {}

If Vazio(cCodSim)
	Return .T.
else
	If Vazio(cRevisao)
		Aviso("Aviso","Informe o campo Revis? da Estrutura Similar.",{"Ok"})
		Return .F.
	EndIf
End If

lGetRevisao := !lGetRevisao
ldbTree	:= .T.
cCodAtual := cCodSim
cValComp  := cCodSim + '?'
u_xA200Cria(oTree, oDlg, cProduto, cCodAtual, cRevisao, nOpcX)
IF lReAuto
	SG1->(DbSetOrder(1))
	If SG1->(dbSeek(xFilial("SG1")+cCodAtual))
		If aScan(aPaiEstru, {|x| x[1]==SG1->G1_COD}) == 0
			aAdd(aPaiEstru,{cProduto,.T.})
		EndIf
	EndIf
EndIf
Return .T.

//------------------------------------------------------------------
/*/{Protheus.doc} A200Cria()
Montagem do Arquivo Temporario para o Tree da Estrutura Similar
(Func.Recurssiva)
@author Lucas Pereira
@since 22/09/2014
@version 1.0
/*/
//------------------------------------------------------------------
USer Function xA200Cria(oTree, oDlg, cProduto, cCodSim, cRevisao, nOpcX, cCargo, cTRTPai, lZeraStatic)

Local nRecAnt    := 0
Local cComp      := ''
Local cPrompt    := ''
Local cFolderA   := 'FOLDER5'
Local cFolderB   := 'FOLDER6'
Local cRevPI 	 := ""
Local nRecCargo  := 0
Local dValIni    := CtoD('  /  /  ')
Local dValFim    := CtoD('  /  /  ')
Local lRet		 := .T.
Local lContinua	 := .T.
Local nQtdeSG1   := 0
Local lExpand    := mv_par03 == 1
Local lExibeOPC  := .T.
Local lRetPE
Local lA200rvPi  := ExistBlock("A200RVPI")
Local nIndSG1	 := 1
Local lM200BMP   := ExistBlock("M200BMP")
Local uRet       := Nil
Local lRevAut    := SuperGetMv("MV_REVAUT",.F.,.F.)

Static nNivelTr  := 0
Static cFistCargo:= NIL
// -- Atualiza nivel da estrutura
nNivelTr += 1

nOpcX := If(nOpcX==Nil,0,nOpcX)   

lExpEst := .T.

If ExistBlock("MA200ORD")
	nIndSG1 := ExecBlock("MA200ORD",.F.,.F.)
	If ValType(nIndSG1) # "N"
		nIndSG1 := 1
	EndIf
EndIf

If !ldbTree .And. nOpcX < 5
	oDlg:SetFocus()
	lRet := .F.
EndIf

If lRet       
	lExpEst := .T.
	
	//-- Posiciona no SB1
	cPrompt := cProduto + Space(33)
	SB1->(dbSetOrder(1))
	If SB1->(dbSeek(xFilial('SB1') + cCodSim, .F.))
		cPrompt := AllTrim(cProduto) 
		If SB1->(DbSeek(xFilial("SB1")+ cProduto, .F.))
			cPrompt += " - " + SB1->B1_DESC + Space(Len(SB1->B1_COD) - Len(AllTrim(cProduto)))
		EndIf
	EndIf
	cPrompt += Space(Len("QTDE:")+TamSX3("G1_QUANT")[1]) //"QTDE:"	

	SG1->(dbSetOrder(nIndSG1))
	If !Vazio(cProduto)
		SG1->(DbSeek(xFilial("SG1")+cProduto))
		cCodSim := cProduto
	else
		cCodSim := cProduto
	EndIf

	If lRet .And. lContinua
		cTRTPai := If(cTRTPai==Nil,SG1->G1_TRT,cTRTPai)

		dValIni := SG1->G1_INI
		dValFim := SG1->G1_FIM
		If cCargo == Nil
			cCargo := cProduto + cTRTPai + SG1->G1_COMP + StrZero(SG1->(Recno()), 9) + StrZero(nIndex ++, 9) + 'CODI'
		ElseIf (nRecCargo := Val(SubStr(cCargo,Len(SG1->G1_COD + SG1->G1_TRT + SG1->G1_COMP) + 1, 9))) > 0
			nRecAnt := SG1->(Recno())
			SG1->(dbGoto(nRecCargo))
			dValIni := SG1->G1_INI
			dValFim := SG1->G1_FIM
			nQtdeSG1 := SG1->G1_QUANT
			SG1->(dbGoto(nRecAnt))
		EndIf

		//-- Define as Pastas a serem usadas
		cFolderA := 'FOLDER5'
		cFolderB := 'FOLDER6'
		If Right(cCargo, 4) == 'COMP' .And. ;
			(dDataBase < dValIni .Or. dDataBase > dValFim)
			cFolderA := 'FOLDER7'
			cFolderB := 'FOLDER8'
		EndIf

		If lM200BMP
			uRet := Execblock("M200BMP", .F., .F., {cPrompt, cFolderA, cFolderB})
			If ValType(uRet) == "A"
				cFolderA := uRet[1]
				cFolderB := uRet[2]
			EndIf
		EndIf

		//-- Adiciona o Pai na Estrutura
		DBADDTREE oTree PROMPT u_xA2Prompt(cPrompt, cCargo, nQtdeSG1) OPENED RESOURCE cFolderA, cFolderB CARGO cCargo

		Do While !SG1->(Eof()) .And. SG1->G1_FILIAL+SG1->G1_COD == xFilial("SG1")+cCodSim
		
			lExpEst := .T.

			//-- Nao Adiciona Componentes fora da Revis„o
			If (cRevisao # Nil) .And. ;
				!(SG1->G1_REVINI <= cRevisao .And. (SG1->G1_REVFIM >= cRevisao .Or. SG1->G1_REVFIM = ' '))
				SG1->(dbSkip())
				Loop
			EndIf

			nRecAnt  := SG1->(Recno())
			cComp    := SG1->G1_COMP
			cCargo   := cProduto + SG1->G1_TRT + SG1->G1_COMP + StrZero(SG1->(Recno()), 9) + StrZero(nIndex ++, 9) + 'COMP'
			nQtdeSG1 := SG1->G1_QUANT

			If cFistCargo == NIL
				cFistCargo := cCargo
			EndIf

			//-- Define as Pastas a serem usadas
			cFolderA := 'FOLDER5'
			cFolderB := 'FOLDER6'
			If dDataBase < SG1->G1_INI .Or. dDataBase > SG1->G1_FIM
				cFolderA := 'FOLDER7'
				cFolderB := 'FOLDER8'
			EndIf

			//-- Posiciona no SB1
			cPrompt := cComp + Space(33)
			SB1->(dbSetOrder(1))
			If SB1->(dbSeek(xFilial('SB1') + cComp, .F.))
				cPrompt := AllTrim(cComp) + " - " + SB1->B1_DESC + Space(Len(SB1->B1_COD) - Len(AllTrim(cComp)))
			EndIf
			cPrompt += Space(Len("QTDE:")+TamSX3("G1_QUANT")[1]) //"QTDE:"   
			
			lExpEst := .T.			
			If ExistBlock("MT200EXP")
				lExpEst := ExecBlock("MT200EXP",.F.,.F., {cComp})
			endIf				                

   			If SG1->(dbSeek(xFilial('SG1') + SG1->G1_COMP, .F.)) .and. lExpEst
				If ExistBlock("MT200OPC")
					lRetPE := ExecBlock("MT200OPC",.F.,.F.,SG1->G1_COMP)
					lExibeOPC := IIF(ValType(lRetPE)=="L",lRetPE,lExibeOPC)
				EndIf
				
				cRevPi := IIf(SB1->B1_REVATU = ' ','001',SB1->B1_REVATU)
				
				If lA200rvPi
					cRevPi := Execblock ("A200RVPI",.F.,.F.,{cCodSim, cRevisao, SG1->G1_COD, cRevPi})
				EndIf
				
   				If lExpand .And. lExibeOPC
					//-- Adiciona um Nivel a Estrutura
					u_xA200Cria(oTree, oDlg, SG1->G1_COD,'',cRevPi,IIF(lRevaut,2,If(nOpcX==3,0,nOpcX)), cCargo, cTRTPai)
				Else
					If lM200BMP
						uRet := Execblock("M200BMP", .F., .F., {cPrompt, cFolderA, cFolderB})
						If ValType(uRet) == "A"
							cFolderA := uRet[1]
							cFolderB := uRet[2]
						EndIf
					EndIf
					oTree:AddItem(u_xA2Prompt(cPrompt, cCargo, nQtdeSG1), cCargo, cFolderA, cFolderB,,, 2)
				EndIf
			Else
				//-- Adiciona um Componente a Estrutura
				If lM200BMP
					uRet := Execblock("M200BMP", .F., .F., {cPrompt, cFolderA, cFolderB})
					If ValType(uRet) == "A"
						cFolderA := uRet[1]
						cFolderB := uRet[2]
					EndIf
				EndIf

				DBADDITEM oTree PROMPT u_xA2Prompt(cPrompt, cCargo ,nQtdeSG1) RESOURCE cFolderA CARGO cCargo
			EndIf

			SG1->(dbGoto(nRecAnt))
			SG1->(dbSkip())
		EndDo
		DBENDTREE oTree

		If ldbTree
			// --- Atualiza obj.dbtree apos processar a estrutura
			If nNivelTr == 1
				If( cFistCargo <> NIL )
					cCargo := cFistCargo
					cFirstCargo := NIL
				EndIf
				oTree:TreeSeek(cCargo)
				oTree:Refresh()
				oTree:SetFocus()
			EndIf
		Else
			oDlg:SetFocus()
		EndIf
	EndIf
EndIf
If lContinua
	// --- Atualiza nivel da estrutura
	nNivelTr -= 1
EndIf

//Zera conteudo das variaveis static, necessario para montagem do tree na rotina MATC015.
If ValType(lZeraStatic)=="L" .And. lZeraStatic
	nNivelTr  := 0
	cFistCargo:= NIL
EndIf
Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} a200RevMax()
Retorna a revis? corrente do produto
@author Ricardo Prandi	
@since 29/12/2014
@version 1.0
/*/
//------------------------------------------------------------------
USer Function xa2RevMax(cCodSim, cRevSim)
Local aArea := {}

aArea := GetArea()

dbSelectArea('SB1')
SB1->(dbSeek(xFilial('SB1')+cCodSim))

cRevSim := IIf (!(EOF()),IIF(SB1->B1_REVATU == '' .or. Empty(SB1->B1_REVATU),'001',SB1->B1_REVATU),'001')

RestArea(aArea)

Return(.T.)
/*
Static Function xMa200Edita(nOpcX, cCargo, oTree, nOpcY, aUndo, lMudou, aAltEstru, nQtdBase, aKey, aBKey, aPaiEstru , aAuto)

Return
*/
*----------------------*
Static Function xAlterG1
*----------------------* 
Local _lRetGE     := .F.
Local _aParamINI := {}
Local _aTpFluxo	 := {'V=Variavel','F=Fixa'}  //G1_FIXVAR 
Local _aRetIni   := {}	
Local _nFixVar   := iIF(SG1->G1_FIXVAR=='V',1,2)

aAdd(_aParamINI,{9,"MOTOR DE PROCESSO - Altera Estrutura de Produto",150,7,.T.})
	
aAdd(_aParamINI,{1,"Valor",SG1->G1_QUANT,"@E 9,999.99","","","",20,.T.})
	
aAdd(_aParamINI,{2,"Quant Fixa/Variavel",_nFixVar,_aTpFluxo,50,"",.T.})

If !ParamBox(_aParamINI,"Configuração",@_aRetIni)
   	Return(.F.)
ENDIF 

IF 	RecLock('SG1',.F.)
		Replace SG1->G1_QUANT  With _aRetIni[2]
		Replace SG1->G1_FIXVAR With iIF(ValType(_aRetIni[3]) == 'C', _aRetIni[3], LEFT(_aTpFluxo[_aRetIni[3]],1)) 
	SG1->(MsUnLock())
ENDIF

Return(.T.)
