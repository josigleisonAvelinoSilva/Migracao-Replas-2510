#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³OS200GER  ³ Autor ³ Leandro Dentello      ³ Data ³03/10/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Locacao   ³ Central de Recur ³Contato ³                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Ponto de Entrada para gravacao dos dados da transportadora  ³±±
±±³          ³e redespacho da carga para integracao com GFE.              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function OS200GER()
//Variaveis Locais da Funcao
Local aArea    := GetArea()
Local aAreaDAI := DAI->(GetArea())
Local aAreaDAK := DAK->(GetArea())
Local aAreaSC5 := SC5->(GetArea())
Local aAreaSA4 := SA4->(GetArea())
Local aAreaGV4 := GV4->(GetArea())

Local aCFrete	 := {"Cif","Fob"}
Local aCFrete1	 := {"Cif","Fob"}
Local aCFrete2	 := {"Cif","Fob"}


Local oTransp
Local oNTransp

Local oRedesp1
Local oNRedesp1

Local oCdtpop //Codigo do Tipo de Operação do GFE

Private cCFrete
Private cCFrete1

Private cTransp	 := DAK->DAK_TRANSP
Private cNTransp := Posicione("SA4",1,xFilial("SA4")+DAK->DAK_TRANSP,"A4_NREDUZ")

Private cRedesp1  := Space(6)
Private cNRedesp1 := Space(15)

Private cCdtpop := Space(10)
Private nCdtpop := Space(50)

// Variaveis Private da Funcao
Private _oDlg				// Dialog Principal
Private INCLUI := .F.	// (na Enchoice) .T. Traz registro para Inclusao / .F. Traz registro para Alteracao/Visualizacao

If Msgyesno('<FONT COLOR="red" SIZE="5">Informar Dados de Redespacho?</FONT>')
	
	DEFINE MSDIALOG _oDlg TITLE OemtoAnsi("Transportadoras da Carga") STYLE DS_MODALFRAME FROM C(260),C(315) TO C(674),C(1000) PIXEL
	// STYLE DS_MODALFRAME este dado tira o X para fechamento forcado da tela.
	_oDlg:lEscClose := .F. // Impede que o ESC feche a tela sem o usuario digitar os dados.
	
	// Cria as Groups do Sistema
	@ C(007),C(003) TO C(057),C(315) LABEL "Transportadora " PIXEL OF _oDlg
	@ C(065),C(003) TO C(115),C(315) LABEL "Redespacho 1 "   PIXEL OF _oDlg
	//@ C(121),C(003) TO C(170),C(315) LABEL "Redespacho 2 "   PIXEL OF _oDlg
	@ C(121),C(003) TO C(170),C(315) LABEL "Tipo de Operação"   PIXEL OF _oDlg
	//@ C(175),C(002) TO C(200),C(200) LABEL "Agendamento "   PIXEL OF _oDlg
	
	// Cria Componentes Padroes do Sistema
	@ C(023),C(007) Say "Transportadora :."             Size C(045),C(010) COLOR CLR_BLACK PIXEL OF _oDlg
	@ C(021),C(057) MsGet oTransp  Var cTransp  F3 "SA4" When .T. Valid ExistCpo("SA4").And. AtuName(cTransp);
																	Size C(060),C(010) COLOR CLR_BLACK PIXEL OF _oDlg
	@ C(020),C(128) MsGet oNTransp Var cNTransp When .F. Size C(135),C(010) COLOR CLR_BLACK PIXEL OF _oDlg
	
	@ C(035),C(007) Say "Tipo Frete :."              Size C(032),C(010) COLOR CLR_BLACK PIXEL OF _oDlg
	@ C(036),C(057) ComboBox cCFrete Items aCFrete   Size C(050),C(010) PIXEL OF _oDlg
	
	@ C(081),C(007) Say "Redespacho 1 :. "           Size C(045),C(010) COLOR CLR_BLACK PIXEL OF _oDlg
	@ C(078),C(057) MsGet oRedesp1  Var cRedesp1 F3 "SA4" Valid (ExistCpo("SA4").And. AtuName(cRedesp1)).Or. Vazio() ;
																		Size C(060),C(010) COLOR CLR_BLACK PIXEL OF _oDlg	
	@ C(078),C(128) MsGet oNRedesp1 Var cNRedesp1 When .F. Size C(135),C(010) COLOR CLR_BLACK PIXEL OF _oDlg
	
	@ C(097),C(007) Say "Tipo Frete :."              Size C(030),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
	@ C(097),C(057) ComboBox cCFrete1 Items aCFrete1 Size C(050),C(010) PIXEL OF _oDlg

	@ C(137),C(009) Say "Tipo de Operação :. "            Size C(041),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
	@ C(136),C(057) MsGet oCdtpop Var cCdtpop F3 "GV4" Valid (ExistCpo("GV4").And. AtuName(cCdtpop)).Or.Vazio() ;
																		Size C(060),C(010) COLOR CLR_BLACK PIXEL OF _oDlg
	@ C(136),C(129) MsGet oCdtpop Var nCdtpop When .F. Size C(135),C(010) COLOR CLR_BLACK PIXEL OF _oDlg
	
	@ C(190),C(260) Button OemtoAnsi("&Ok") Size C(040),C(015) PIXEL OF _oDlg Action (GravaCarga())	
	
	ACTIVATE MSDIALOG _oDlg CENTERED

Endif  //

RestArea(aAreaGV4)
RestArea(aAreaSA4)
RestArea(aAreaSC5)
RestArea(aAreaDAK)
RestArea(aAreaDAI)
RestArea(aArea)

Return(.T.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³   C()      ³ Autor ³ Leandro Dentello      ³ Data ³03/10/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Funcao responsavel por manter o Layout independente da       ³±±
±±³           ³ resolução horizontal do Monitor do Usuario.                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function C(nTam)
Local nHRes	:=	oMainWnd:nClientWidth	//Resolucao horizontal do monitor
Do Case
	Case nHRes == 640	//Resolucao 640x480
		nTam *= 0.8
	Case nHRes == 800	//Resolucao 800x600
		nTam *= 1
	OtherWise			//Resolucao 1024x768 e acima
		nTam *= 1.28
EndCase
If "MP8" $ oApp:cVersion
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento para tema "Flat"³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (Alltrim(GetTheme()) == "FLAT").Or. SetMdiChild()
		nTam *= 0.90
	EndIf
EndIf
Return Int(nTam)                       

////////////////////////////////////////
//Funcao para gravar os dados na carga//
////////////////////////////////////////
Static Function GravaCarga()

RecLock("DAK",.F.)
	If !Empty(cTransp) .And. DAK->(FieldPos("DAK_TRANSP")) > 0
		DAK->DAK_TRANSP := cTransp
		DAK->DAK_TFRDP1 := Iif ( cCFrete == "Cif","C","F")
	EndIf
	If !Empty(cRedesp1).And.DAK->(FieldPos("DAK_RDESP1")) > 0
		DAK->DAK_RDESP1 := cRedesp1
		DAK->DAK_TFRDP1 := Iif ( cCFrete1 == "Cif","C","F")
	EndIf

	If !Empty(cCdtpop).And.DAK->(FieldPos("DAK_CDTPOP")) > 0
		DAK->DAK_CDTPOP := cCdtpop
	EndIf
DAK->(MsUnLock())
DAK->(FkCommit())

DbSelectArea("DAI")
DbSetOrder(1)
DbSeek(xFilial("DAI")+DAK->DAK_COD)

While (!Eof() .And. DAI->DAI_COD == DAK->DAK_COD )
	
	DbSelectArea("SC5")
	DbSetOrder(1)
	DbSeek(xFilial("SC5")+DAI->DAI_PEDIDO)
	
	RecLock("SC5",.F.)
	SC5->C5_TRANSP  := cTransp
	SC5->C5_TPFRETE := Iif ( cCFrete == "Cif","C","F")
	SC5->C5_REDESP  := cRedesp1
	SC5->C5_TFRDP1 := Iif ( cCFrete1 == "Cif","C","F")	
	SC5->C5_ESTRDP1 := Posicione("SA4",1,xFilial("SA4") + cRedesp1,"A4_EST")
	SC5->C5_CMURDP1:= Posicione("SA4",1,xFilial("SA4") + cRedesp1,"A4_COD_MUN")
	        
	SC5->(MsUnLock())
	
	DAI->(DbSkip())
EndDo
 _oDlg:End()
Return()
//////////////////////////////////////////////////
//Funcao para alimentar o nome da Transportadora//
//////////////////////////////////////////////////
Static Function AtuName(cCodTrans)

DbSelectArea("SA4")
DbSetOrder(1)
DbSeek(xFilial("SA4")+cCodTrans)

If ReadVar() == "CTRANSP"
	cNTransp := SA4->A4_NREDUZ
ElseIf ReadVar() == "CREDESP1"
	cNRedesp1 := SA4->A4_NREDUZ
ElseIf ReadVar() == "CCDTPOP"
	nCdtpop := GV4->GV4_DSTPOP
EndIf

Return (.T.)