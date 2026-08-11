#Include "Protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "tbicode.ch"
#INCLUDE "rwmake.ch"
#Include "Xmlxfun.ch"
#INCLUDE "ap5mail.ch"

#DEFINE ENTER Chr(13)+Chr(10) 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Programa  ³ RPMONTASG1  ³ Autor ³   Meliora/Gustavo  ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ MONTAGEM DE ESTRUTUA DE PRODUTO PARA PRODUCAO              ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
*----------------------*  
User Function RPMONTASG1/*(_cAlias,_cMarca)*/
*----------------------*
Local _nJ,_nAr	
Local _aItens := {} 

Local _lRetG1 := .T.
Local _cAlias := ParamIXB[1]       
Local _cMarca := ParamIXB[2]

Local _lCont  := .F.
Local _nRecSC6 := SC6->(Recno())
//(David-TSM)Retirada o tratamento de areas em aberto que estavam
//causando desposicionamento de registros                    
Private _aArrTB:= {	{'SC6',SC6->(Recno()),SC6->(IndexOrd())},;
					{'SB1',SB1->(Recno()),SB1->(IndexOrd())},;
					{'SG1',SG1->(Recno()),SG1->(IndexOrd())},;
					{'SD4',SD4->(Recno()),SD4->(IndexOrd())} }
Private _aArea := GetArea()
Private _aArC6 := SC6->(GetArea())
Private _aArG1 := SG1->(GetArea())

_cQry := " SELECT AAA.OK, AAA.PRODUTO, AAA.RECSC6, CASE WHEN AAA.ESTRUT IS NULL THEN 'NAO_EXISTE' ELSE AAA.ESTRUT END ESTRUTURA "+ENTER
_cQry += "   FROM ( "+ENTER
_cQry += " 	SELECT C6_OK OK, C6_PRODUTO PRODUTO, SC6.R_E_C_N_O_ RECSC6,  "+ENTER
_cQry += " 		   (SELECT DISTINCT G1_COD FROM "+RetSqlName('SG1')+" SG1 (NOLOCK) WHERE SG1.D_E_L_E_T_='' AND G1_FILIAL = '"+xFilial('SG1')+"' AND G1_COD=SC6.C6_PRODUTO) ESTRUT "+ENTER
_cQry += " 	FROM "+RetSqlName('SC6')+" SC6 (NOLOCK) "+ENTER
_cQry += " 	 WHERE SC6.D_E_L_E_T_= '' "+ENTER
_cQry += " 	   AND C6_FILIAL     = '"+xFilial('SC6')+"' "+ENTER
_cQry += "        AND C6_OK      = '"+_cMarca+"' "+ENTER
_cQry += " ) AAA "+ENTER
If Select("_STR") > 0	
	_STR->(DbCloseArea())
EndIf        
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cQry),"_STR",.F.,.T.)                        	
DbSelectArea("_STR")
_STR->(DBGOTOP())

//_nRetG1 := Contar("_STR","!Eof()"); _STR->(DbGoTop())
//_lRetG1 := _nRetG1 == 0

While _STR->(!Eof())
	DbSelectArea('SG1');SG1->(DbGoTop())	
	IF !SG1->(DbSeek(xFilial('SG1')+_STR->PRODUTO))
    	aADD(_aItens, {.F., _STR->PRODUTO})
	ENDIF     
	_STR->(DbSkip())
EndDo 

For _nJ:=1 To Len(_aItens) 
	
	_lCont := .F.
	DbSelectArea('SB1');SB1->(DbGoTop());SB1->(DbSeeK(xFilial('SB1')+_aItens[_nJ][2]))	                   
	DbSelectArea('SG1');SG1->(DbSetOrder(1));SG1->(DbGoTop())                         
	
	//BEGIN TRANSACTION
		IF !SG1->(DbSeek(xFilial('SG1')+SB1->B1_COD))
			While !_lCont
				DbSelectArea('SG1');SG1->(DbGoTop())
				Pergunte('MTA200', .F.)
				Private l200Auto	:= .F.
				Private aAutoCab	:= {}
				Private aAutoItens	:= {}    
				private lExpEst     := .T.   
				Private ldbTree     := .F.
				Private aValAnt    := {}
				_nOpcG := U_xGa200Exe('SC6',SG1->(Recno()),3,_aItens[_nJ][2])
				DbSelectArea('SG1');SG1->(DbSetOrder(1));SG1->(DbGoTop())
				IF !SG1->(DbSeek(xFilial('SG1')+_aItens[_nJ][2]))
				 	_lCont := !MsgYesNo('Não foi cadastro a Estrutura de produção para a mercadoria '+SB1->B1_COD+','+ENTER+'Deseja incluir novamente ?','Atenção')
				Else
					_aItens[_nJ][1] := .T.; _lCont := .T.
				ENDIF
			EndDo
		ENDIF
	//END TRANSACTION
	
Next _nJ

IF LEn(_aItens) > 0
	_lRetG1 := (aScan(_aItens,{|s| !s[1] }) == 0)
ENDIF
//(David-TSM)Retirada o tratamento de areas em aberto que estavam
//causando desposicionamento de registros
For _nAr:=1 To Len(_aArrTB)
	DbSelectArea(_aArrTB[_nAr][1])
	(_aArrTB[_nAr][1])->(DbSetOrder(_aArrTB[_nAr][3]))
	(_aArrTB[_nAr][1])->(DbGoTo(_aArrTB[_nAr][2]))	
NExt _aAR

Pergunte("MTA650",.F.)
//(David-TSM)Retirada o tratamento de areas em aberto que estavam
//causando desposicionamento de registros
RestArea(_aArea)
RestArea(_aArC6)
RestArea(_aArG1)	

Sleep(1000)
Return(_lRetG1)
/*
*-----------------------*
Static Function Xa200Exe(cAlias,nRecno,nOpcX)
*-----------------------*
Local lTranEst := GetMv("MV_TRANEST",.F.,.T.)
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
//³ Variavel lPyme utilizada para Tratamento do Siga PyME        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lPyme:= Iif(Type("__lPyme") <> "U",__lPyme,.F.)

DEFINE FONT oFont1 NAME "Arial Black" SIZE 6,17
DEFINE FONT oFont2 NAME "Courier New" SIZE 8,20 BOLD 

Private nIndex   := 1
Private nQtdBasePai
Private cRevisao := CriaVar('B1_REVATU')
Private cRevSim  := CriaVar('B1_REVATU')

Private cProduto   := CriaVar('G1_COD')
Private cCodSim    := CriaVar('G1_COD')
Private cUm        := CriaVar('B1_UM')
Private nQtdBase   := CriaVar('B1_QB')
Private oButton1

cTitulo += OemToAnsi('Inslusao - REPLAS') // 'Inclus„o'

ARegsSGF := {}

	cUm        := ''
	cRevisao   := ''
	cProduto   := Space(TamSX3("G1_COD")[1]xGa200Exe)
	cCodAtual  := Replicate('ú', TamSX3("G1_COD")[1]xGa200Exe)
	cValComp   := Replicate('ú', TamSX3("G1_COD")[1]xGa200Exe) + 'ú'
	nQtdBasePai:= nQtdBase := 0

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
		@ 008, 033 SAY   OemToAnsi('Código') SIZE 037, 007 OF oPanel1 PIXEL // 'C¢digo:'

		cProduto := SB1->B1_COD
		//xA200Codigo(cProduto, @cUm, @cRevisao, @nQtdBase, oUm, oRevisao, oQtdBase, oDlg,oButton1)
		
		@ 006, 065 MSGET cProduto SIZE 105, 010 OF oPanel1 PIXEL PICTURE PesqPict('SG1','G1_COD') ;
			WHEN (!ldbTree .And. nOpcX==3) VALID xA200Codigo(cProduto, @cUm, @cRevisao, @nQtdBase, oUm, oRevisao, oQtdBase, oDlg) F3 'SB1'
			
		@ 006 ,190 Say OemToAnsi(ALLTRIM(UPPER(SB1->B1_DESC))) SIZE 400,20 FONT oFont2 OF oPanel1 PIXEL COLOR CLR_HRED

		//@ 008, 190 SAY   OemToAnsi('Unidade:') SIZE 040, 007 OF oPanel1 PIXEL	//
		//@ 006, 215 MSGET oUm Var cUm        SIZE 015, 010 OF oPanel1 PIXEL ;
		//	WHEN .F.

		@ 022, 033 SAY   OemToAnsi('Revisão')    SIZE 030, 007 OF oPanel1 PIXEL // 'Revis„o'
		@ 020, 065 MSGET oRevisao Var cRevisao SIZE 015, 010 OF oPanel1 PIXEL PICTURE PesqPict('SB1','B1_REVATU',3) ;
			WHEN (!ldbTree .And. nOpcX == 2 .And. lGetRevisa) .Or. (nOpcX == 4 .And. lGetRevisa) VALID xA200GetRev(@lGetRevisa, oDlg, oTree, cProduto, cRevisao, nOpcX,lRevAut,@aPaiEstru)

		@ 022, 100 SAY   OemToAnsi('Estr.Similar:')  SIZE 054, 007 OF oPanel1 PIXEL // 'Estrutura Similar:'
		@ 020, 132 MSGET oCodSim Var cCodSim SIZE 105, 010 OF oPanel1 PIXEL PICTURE PesqPict('SG1','G1_COD') ;
			WHEN (nOpcX == 3 .And. lGetRevisa) VALID xa200RevMax(cCodSim, @cRevSim) F3 'SG1'
			
		//@ 022, 170 SAY OemToAnsi('Revisão da estrutura similar')   SIZE 030, 007 OF oPanel1 PIXEL // 'Revisão da estrutura similar'
		//@ 020, 195 MSGET RevSim Var cRevSim SIZE 015, 010 OF oPanel1 PIXEL PICTURE PesqPict('SB1','B1_REVATU',3);
		//	WHEN (nOpcX == 3 .And. lGetRevisa) VALID A200CodSim(cProduto, cCodSim, @aUndo) .And. A200RevSim(@lGetRevisa, oDlg, oTree, cProduto, cCodSim, cRevSim, nOpcX,lRevAut,@aPaiEstru);

		@ 022, 250 SAY   OemToAnsi('Quantidade Base:')    SIZE 053, 007 Of oPanel1 PIXEL // 'Quantidade Base:'
		@ 020, 295 MSGET oQtdBase Var nQtdBase SIZE 071, 010 Of oPanel1 PIXEL PICTURE PesqPictQt('B1_QB',20) ;
			WHEN (nOpcX==3.Or.nOpcX==4) VALID xA200QBase(nQtdBase, nOpcX, cProduto, cCodSim, oTree, oDlg)

		@ 000,000 MSPANEL oPanel2 OF oDlg
		oTree := DbTree():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3]-25,aPosObj[2,4], oPanel2,,,.T.)
		oTree:Align := CONTROL_ALIGN_ALLCLIENT

		@ 000,000 MSPANEL oPanel3 OF oDlg

		@ 000,000 MSPANEL oPanelRight SIZE __DlgWidth(oMainWnd)/1,5 OF oPanel3
		oPanelRight:Align := CONTROL_ALIGN_RIGHT

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Defini‡„o dos Bot”es Utilizados                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//-- Operacao x Componente
		If !lPyme .And. (nOpcx == 3 .Or. nOpcx == 4)
			@ 000,000 MSPANEL oPanelB1 SIZE 90,40 OF oPanelRight
			@ 000,000 BUTTON oButton1 PROMPT "&"+A635Titulo() ACTION Ma200Oper(nOpcX, oTree:GetCargo(), oTree) SIZE 65,11 OF oPanelB1 PIXEL
            If nOpcx == 3
				oButton1:Disable()
			EndIf
		Endif
		
		//-- Inclus„o
		@ 000,000 MSPANEL oPanelB2 SIZE 30,40 OF oPanelRight		

			DEFINE SBUTTON oButton2 FROM 000,000  TYPE 4 ENABLE OF oPanelB2 ;
			 ACTION If(!ldbTree .And. nOpcX < 4, .T., xMa200Edita(nOpcX, oTree:GetCargo(), oTree, 3, @aUndo, @lMudou, @aAltEstru,, aKey, aBkey,@aPaiEstru))
			oButton2:cTOOLTIP:=OemToAnsi('Incluir-<Alt-I>')//--"Incluir-<Alt-I>"
			bkey279:={|| If(!ldbTree .And. nOpcX < 4, .T., xMa200Edita(nOpcX, oTree:GetCargo(), oTree, 3, @aUndo, @lMudou, @aAltEstru,, aKey, aBkey,@aPaiEstru))}
			AADD(aBkey, {bkey279, 279})
			SetKey(279, bkey279)			


		@ 000,000 MSPANEL oPanelB3 SIZE 30,40 OF oPanelRight
		//-- Altera‡„o
		DEFINE SBUTTON oButton3 FROM 000,000 TYPE 11 ENABLE OF oPanelB3 ;
			ACTION If(!ldbTree .And. nOpcX < 4, .T., xMa200Edita(nOpcX, oTree:GetCargo(), oTree, 4, @aUndo, @lMudou, @aAltEstru,, aKey, aBkey,@aPaiEstru))
			oButton3:cTOOLTIP:=OemToAnsi('Editar-<Alt-M>')//--"Editar-<Alt-M>"
			bKey300 := {|| xMa200Edita(nOpcX, oTree:GetCargo(), oTree, 4, @aUndo, @lMudou, @aAltEstru,, aKey, aBkey,@aPaiEstru)}
			AADD(aBkey, {bkey300, 300})
			SetKey(300, bKey300)

		@ 000,000 MSPANEL oPanelB4 SIZE 30,40 OF oPanelRight
		//-- Exclus„o
			DEFINE SBUTTON oButton4 FROM 000,000  TYPE 3 ENABLE OF oPanelB4 ;
				ACTION If(!ldbTree .And. nOpcX < 4, .T., xMa200Edita(nOpcX, oTree:GetCargo(), oTree, 5, @aUndo, @lMudou, @aAltEstru,, aKey, aBkey,@aPaiEstru))
				oButton4:cTOOLTIP:=OemToAnsi('Excluir-<Alt-E>')//--"Excluir-<Alt-E>"
				bKey274 :={|| If(!ldbTree .And. nOpcX < 4, .T., xMa200Edita(nOpcX, oTree:GetCargo(), oTree, 5, @aUndo, @lMudou, @aAltEstru,, aKey, aBkey,@aPaiEstru))}
				AADD(aBkey, {bkey274, 274})
				SetKey(274, bKey274)
	

		@ 000,000 MSPANEL oPanelB5 SIZE 30,40 OF oPanelRight
		//-- Pesquisa e Posiciona

		@ 000,000 MSPANEL oPanelB6 SIZE 30,40 OF oPanelRight

		//-- Confirma
			DEFINE SBUTTON oButton6 FROM 000,000 TYPE 1 ENABLE OF oPanelB6 ;
				ACTION (lConfirma:=.T., If(Btn200Ok(aUndo, cProduto) .And. ldbTree, xMa200Fecha(oDlg, oTree, nOpcX, lMudou, cUm, cProduto, nQtdBase, cRevisao, .T., aAltEstru, aKey, aBkey, aUndo,aPaiEstru), .T.))
				oButton6:cToolTip:=OemToAnsi("OK-<Alt-N>")//--"OK-<Alt-N>"
				bKey305:={|| (lConfirma:=.T., If(Btn200Ok(aUndo, cProduto) .And. ldbTree, xMa200Fecha(oDlg, oTree, nOpcX, lMudou, cUm, cProduto, nQtdBase, cRevisao, .T., aAltEstru, aKey, aBkey, aUndo,aPaiEstru), .T.))}
				AADD(aBkey, {bkey305, 305})
				SetKey(305, bKey305)

		@ 000,000 MSPANEL oPanelB7 SIZE 30,40 OF oPanelRight

		//-- Abandona
		DEFINE SBUTTON oButton7 FROM 000,000  TYPE 2 ENABLE OF oPanelB7 ;
			ACTION (lAbandona := .T., xMa200Undo(aUndo, nOpcx), xMa200Fecha(oDlg, oTree, nOpcX, .F., cUm, cProduto, nQtdBase, cRevisao, .F., aAltEstru, aKey, aBkey, aUndo,aPaiEstru))
			oButton7:cToolTip:=OemToAnsi("Cancela-<Alt-X>")//--
			bKey301:={|| (lAbandona := .T., xMa200Undo(aUndo, nOpcx), xMa200Fecha(oDlg, oTree, nOpcX, .F., cUm, cProduto, nQtdBase, cRevisao, .F., aAltEstru, aKey, aBkey, aUndo,aPaiEstru))}
			AADD(aBkey, {bkey301, 301})
			SetKey(301, bKey301)
 
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
			//oPanelB1:Align := CONTROL_ALIGN_RIGHT
		EndIf

		If !lPyme .And. (nOpcx == 3 .Or. nOpcx == 4)
			//oButton1:Align := CONTROL_ALIGN_RIGHT
		EndIf
		If !lExpand
			//oButton8:Align := CONTROL_ALIGN_RIGHT
		EndIf
		oButton2:Align := CONTROL_ALIGN_RIGHT
		oButton3:Align := CONTROL_ALIGN_RIGHT
		oButton4:Align := CONTROL_ALIGN_RIGHT
		//oButPosic:Align := CONTROL_ALIGN_RIGHT
		oButton6:Align := CONTROL_ALIGN_RIGHT
		oButton7:Align := CONTROL_ALIGN_RIGHT

		ACTIVATE MSDIALOG oDlg ON INIT ( Ma200Monta(oTree, oDlg, cCodAtual, cCodSim, cRevisao, nOpcX),;
			AlignObject(oDlg,{oPanel1,oPanel2,oPanel3},1,2,{070,,020}),;
			If(nOpcx==4,oRevisao:SetFocus(),NIL));
			VALID If(nOpcX>2.And.nOpcX<=5.And.!(lConfirma.Or.lAbandona), (xMa200Undo(aUndo), xMa200Fecha(,, nOpcX, .F., cUm, cProduto, nQtdBase, cRevisao, .F., aAltEstru,aKey, aBKey,aUndo,aPaiEstru)), .T.)
	EndIf

	nPos := SG1->(Recno())

	//-- Integracao Chao de Fabrica
	If lRet .And. lConfirma .And. !lAbandona .And. (nOpcX == 3 .Or. nOpcX == 4 .Or. nOpcX == 5) .And. lIntSFC
   		If nOpcX != 5
			For nX := 1 To Len(aUndo)
				SG1->(dbGoTo(aUndo[nX,1]))
				If aUndo[nX,2] == 1 .And. Empty(aScan(aSFCJaInt,{|x| x == SG1->G1_COD}))
					A200IntSFC(SG1->G1_COD,'2')
					aAdd(aSFCJaInt,SG1->G1_COD)
				EndIf
			Next nX
		Else
			SG1->(dbGoTo(aRecDel[1]))
			A200IntSFC(SG1->G1_COD,'1')
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
cValComp  := Replicate('ú', Len(SG1->G1_COD)) + 'ú'
cCodAtual := Replicate('ú', Len(SG1->G1_COD))

RestArea(aAreaAnt)

Return lRet

*-------------------------------------------------------------------------------------------*
Static Function xA200Codigo(cProduto, cUm, cRevisao, nQtdBase, oUm, oRevisao, oQtdBase, oDlg,oButton1)
*-------------------------------------------------------------------------------------------*
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

If lRet .And. !__lPyme .and. !l200Auto
	IF oButton1 # Nil
		oButton1:Enable()
	endif
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura Area de trabalho.                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aAreaSG1)
RestArea(aAreaSB1)
RestArea(aAreaAnt)
Return lRet

Static Function xA200GetRev(lGetRevisao, oDlg, oTree, cProduto, cRevisao, nOpcX, lReAuto, aPaiEstru)
Default lReAuto   := .F.
Default aPaiEstru := {}

lGetRevisao := !lGetRevisao
ldbTree	:= .T.
cCodAtual := cProduto
cValComp  := cProduto + 'ú'
Ma200Monta(oTree, oDlg, cCodAtual, '', cRevisao, nOpcX)
IF lReAuto
	SG1->(DbSetOrder(1))
	If SG1->(dbSeek(xFilial("SG1")+cCodAtual))
		If aScan(aPaiEstru, {|x| x[1]==SG1->G1_COD}) == 0
			aAdd(aPaiEstru,{cCodAtual,.F.})
		EndIf
	EndIf
EndIf
Return .T.


Static Function xA200QBase(nQtdBase, nOpcX, cProduto, cCodSim, oTree, oDlg)
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
			cValComp  := cProduto + 'ú'
			Ma200Monta(oTree, oDlg, cCodAtual, cCodSim,, nOpcX)
			oTree:TreeSeek(oTree:GetCargo())
		EndIf
	EndIf
EndIf
Return lRet

Static Function xMa200Edita(nOpcX, cCargo, oTree, nOpcY, aUndo, lMudou, aAltEstru, nQtdBase, aKey, aBKey, aPaiEstru , aAuto)
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
Private cDelFunc   := 'u_xA2TudoOk("E")'
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta do Array aAcho os campos que n„o devem aparecer       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
xa200Fields(@aAcho)
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
//³ Deleta do Array aAlter os campos que n„o devem ser alterados ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAlter := aClone(aAcho)
If lAltera .And. (nPos := aScan(aAlter, {|x| 'G1_COMP' $ Upper(x)})) > 0
	aDel(aAlter, nPos); aSize(aAlter, Len(aAlter)-1)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciona o SG1 no registro a ser editado                               ³
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
//³N„o edita o Pai                                                         ³
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
			a200Descen(@cValComp, @aDescend, oTree)
			If lInclui
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Comando utilizado para habilitar chamada do PE generico em cada chamada ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//SetStartMod(.T.)
				INCLUI := .T.
				If AxInclui(Alias(),,, aAcho,, aAlter, 'u_xA2TudoOk("I")', , ,aButtons) == 1
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
						Ma200ATree(oTree, SG1->G1_COD, SG1->G1_COD + SG1->G1_TRT + SG1->G1_COMP + StrZero(SG1->(Recno()),9) + StrZero(nIndex ++, 9) + 'CODI')  
					Else
						Ma200ATree(oTree, SG1->G1_COMP, SG1->G1_COD + SG1->G1_TRT + SG1->G1_COMP + StrZero(SG1->(Recno()),9) + StrZero(nIndex ++, 9) + 'COMP')
					EndIf
					oTree:TreeSeek(cCargoPai)
				Else
					lRet := .F.
				EndIf
				INCLUI := .F.
			ElseIf lAltera
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Guarda o Status inicial do Registro ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aCampos := {}
				If aScan(aUndo, {|x| x[1]==Recno()}) == 0
					For nX := 1 To FCount()
						aAdd(aCampos, FieldGet(nX))
					Next nX
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Comando utilizado para habilitar chamada do PE generico em cada chamada ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				SetStartMod(.T.)
				If AxAltera(Alias(), Recno(), 4, aAcho, aAlter,,, 'u_xA2TudoOk("A")', , ,aButtons) == 1

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
					cPrompt := AllTrim(A200Prompt(cPrompt,cCargo, SG1->G1_QUANT,,aOpc))
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
				xa200Desc(SG1->G1_COMP)
				nUndoRecno := Recno()
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Comando utilizado para habilitar chamada do PE generico em cada chamada ³
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
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Efetua o EndEstrut2 apos o End Transaction                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .And. Len(aEndEstrut) > 0
	For nX := 1 to Len(aEndEstrut)
		FimEstrut2(aEndEstrut[nX,1],aEndEstrut[nX,2])
	Next nX
	aEndEstrut := {}
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seta tecla de atalho		                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
xMa200StKey(aKey,aBkey)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura Area de trabalho.                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aAreaAnt)

Return lRet

Static Function xA200Fields(aAcho)
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

Static Function xA200Desc(cCod)

Local aAreaAnt := GetArea()
Local lRet     := .T.

cCod := If(cCod==Nil,M->G1_COMP,cCod)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no produto desejado e preenche descricao      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SB1->(dbSeek(xFilial('SB1')+cCod, .F.))
	M->G1_DESC := SB1->B1_DESC
Else
	Help(' ', 1, 'NOFOUNDSB1')
	lRet := .F.
EndIf

RestArea(aAreaAnt)

Return lRet

Static Function xMa200StKey(aKey,aBkey)
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

Static Function xa200RevMax(cCodSim, cRevSim)

aArea := GetArea()

dbSelectArea('SB1')
dbSeek(xFilial('SB1')+cCodSim)

cRevSim := IIf (!(EOF()),IIF(SB1->B1_REVATU == '' .or. Empty(SB1->B1_REVATU),'001',SB1->B1_REVATU),'001')

Return .T.

Static Function xMa200Undo(aUndo, nOpcX)
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

End Transaction

RestArea(aAreaAnt)

Return lRet

Static Function xMa200Fecha(oDlg, oTree, nOpcX, lMudou, cUm, cProduto, nQtdBase, cRevisao, lConfirma, aAltEstru, aKey, aBKey, aUndo,aPaiEstru)

Local lRet       := .T.
Local cLinha1    := "Cada altera‡„o em uma estrutura pode gerar uma nova revis„o para"+CHR(13)	//"Cada altera‡„o em uma estrutura pode gerar uma nova revis„o para"
Local cLinha2    := "o controle hist¢rico de altera‡”es em determinado produto."+CHR(13)	//"o controle hist¢rico de altera‡”es em determinado produto."
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
Local cConsidUM  := GetMV( "MV_CONSDUM",.F., "KG" )
Local cAliasB1BZ := If(GetMv('MV_ARQPROD')=="SBZ","SBZ","SB1")
Local lAltRev	 := GetMV("MV_ALTREV",.F.,.F.)
Local lRevAut    := GetMV("MV_REVAUT",.F.,.F.)
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
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza o campo B1_QB na Confirma‡„o da Inclus„o/Altera‡Æo³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpcX == 3 .Or. nOpcX == 4
		cAliasAnt := Alias()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Posiciona SB1 no codigo pai                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cAliasB1BZ == "SBZ"
			dbSetOrder(1)
			SB1->(MsSeek(xFilial('SB1')+cProduto))
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Posiciona SB1 ou no SBZ                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o campo B1_UREV                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
	//³ Atualiza arquivo de Operacoes x Componentes caso haja exclusao de componentes³
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
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava Revisao Estrutura caso atualize arquivo de revisoes ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpcX > 2 .And. (MV_PAR02 == 1 .Or. lRevAut)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ P.E. para Gerar ou nao uma nova revisao para a estrutura sem a apresentacao do Aviso. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
			//³ Atualiza o cadastro de revisoes da estrutura ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !lRevAut
				If Len (aUndo) > 0
			   		cRevisao := A200Revis(cProduto)
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
						cRevisao := A200Revis(aPaiEstru[nx,1],,lRevAut)
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

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Mapa de Divergencias                                      ³
	//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
	//³ lIniMap = Habilita/Desabilita o Mapa de Divergencias      ³
	//³ lIniMap == .T. - Habilita                                 ³
	//³ lIniMap == .F. - Desabilita                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ P.E. MT200MAP - Validar a rotina do Mapa de Divergencias. ³
	//³ Parametros Enviados:                                      ³
	//³ PARAMIXB[1] = Cod.Produto                                 ³
	//³ PARAMIXB[2] = Unidade de Medida                           ³
	//³ PARAMIXB[3] = Quantidade Base                             ³
	//³ PARAMIXB[4] = Revisao                                     ³
	//³ PARAMIXB[5] = Opcao Selecionada                           ³
	//³ PARAMIXB[6] = Contador                                    ³
	//³ Retorno     = Logico                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !l200Auto .And. nOpcX < 5 .And. AllTrim(Upper(cUm)) $ Upper(cConsidUM) .And. !lIniMap

		xa200IniMap(nQtdBase, oTree)

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
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Seta o parametro MV_NIVALT                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lMudou .And. (nOpcX > 2 .And. nOpcX <= 5)
			If lMudou .And. nOpcx == 4
				If a630SeekSG2(3,cProduto,xFilial("SG2")+cProduto) .And. !l200Auto
					Help(" ",1,"A200ALTROT")
				EndIf
			EndIf
			a200NivAlt()
		EndIf

		For nX := 1 to Len(aRegsSGF)
			A635VldGrava(aRegsSGF[nX, 1], aRegsSGF[nX, 2], aRegsSGF[nX, 3], aRegsSGF[nX, 4], aRegsSGF[nX, 5], .T., .F.)
		Next
	EndIf
EndIf

If lContinua
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Deleta o 5o Indice de Trabalho do arquivo dbTree                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
//³ Seta tecla de atalho                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
xMa200StKey(aKey,aBkey)

Return lRet

Static Function xA200IniMap(nQtdBase, oTree)

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
		cText := STR0031 +CHR(13) +CHR(10) //'  Produto                   Qtd. Basica'
		fWrite(nMapaHdl,cText,Len(cText))
		fSeek(nMapaHdl,0,2)
		nQtdBasePai := nQtdBase += CriaVar('B1_QB')
		cProdPai    := SG1->G1_COD
		cText := Space(2) +cProdPai + Space(19-Len(Str(nQtdBase,aTamSX3[1],aTamSX3[2]))) +Str(nQtdBase,aTamSX3[1],aTamSX3[2]) +CHR(13) +CHR(10)
		fWrite(nMapaHdl,cText,Len(cText))
		fSeek(nMapaHdl,0,2)
		cText := + CHR(13) + CHR(10) +Space(2) + STR0032 + CHR(13) + CHR(10) //'Componentes                Quantidade'
		fWrite(nMapaHdl,Replicate('=',43),43)
		fWrite(nMapaHdl,cText,Len(cText))
	Else
		If  dDataBase >= SG1->G1_INI .And. dDataBase <= SG1->G1_FIM
			nQuant := nQuantSG1
			fSeek(nMapaHdl,0,2)
			If SG1->G1_COD == cProdPai
				If nSeq > 2 .And. nQtdComp > 0
					cText := STR0013 +Space(31) +Str(nQtdComp,aTamSX3[1],aTamSX3[2]) +CHR(13) +CHR(10)
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
	cText := +CHR(13) +CHR(10) +STR0013 +Space(31) +Str(nQtdComp,aTamSX3[1],aTamSX3[2])
	fWrite(nMapaHdl,cText,Len(cText))
EndIf

RestArea(aAreaTRE)
RestArea(aAreaSG1)
RestArea(aAreaAnt)
FClose(nMapaHdl)

Return Nil

User Function xA2TudoOk(cOpc)

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

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida grupo de opcionais e item de opcionais   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (!Empty(M->G1_GROPC).And.Empty(M->G1_OPC)) .Or. (!Empty(M->G1_OPC).And.Empty(M->G1_GROPC))
		Help(' ',1,'A200OPCOBR')
		lRet := .F.
	EndIf

	If !(l200Auto)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Valida a Existencia de Similaridade na Estrutura Atual (DBTree)³
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
					If !(nRecno==Recno()) .And. !(Right(T_CARGO,4)$'CODIúNOVO') .And. ;
					   ( M->G1_TRT == SubsTr(T_CARGO, nTamCod+1, 3) .And.!Empty(M->G1_TRT) )
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
	//³ Valida a Existencia de Similaridade na Estrutura Gravada (SG1) ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet .And. ( cOpc=='I' .Or. (cOpc=='A' .And. M->G1_TRT <> SubsTr(T_CARGO, nTamCod+1, 3)) )
		dbSelectArea('SG1')
		aAreaSG1 := GetArea()
		dbSetOrder(1)
		If dbSeek(xFilial("SG1")+cCodPaiOk+M->G1_COMP+M->G1_TRT, .F.)
			If !lRevAut .Or. l200Auto .Or. (oTree:TreeSeek(cCodPai+M->G1_TRT+M->G1_COMP) .And. !(Right(oTree:GetCargo(),4)$'CODIúNOVO'))
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

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida revisao na alteracao da estrutura		³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet .And. cOpc == 'A'
		If M->G1_REVINI > cRevisao .Or. M->G1_REVFIM < cRevisao
			Aviso(OemToAnsi('Revisao invalida'),'Atencao',{"Ok"})
			lRet := .F.
		EndIf
	EndIf

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Execblock MTA200 ap¢s Conf.da InclusÆo/Altera‡„o/Dele‡„o          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If cOpc == 'E' .And. Type('lDelFunc') == 'L'
	lDelFunc := lRet
EndIf

RestArea(aAreaAnt)

Return lRet
*/
