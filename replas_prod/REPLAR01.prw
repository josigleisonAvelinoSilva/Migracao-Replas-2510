#include 'protheus.ch'
#include 'parmtype.ch'
#include 'FWBROWSE.CH'
#include "FWCOMMAND.CH"
#Include "MSOLE.CH"
#INCLUDE 'FWMVCDEF.CH'


//-------------------------------------------------------------------
/*/{Protheus.doc} REPLAR01
Carta de Transferencia (Video Lar)

@author TOTVS Serra do Mar [JOSE CARLOS]
@since 30/06/2016
@version P12
/*/
//-------------------------------------------------------------------
User Function REPLAR01()
Local cPerg			:= Padr('REPLAR01',10)
Local nOpcA			:= 0

Private cCadastro 	:= "Carta de Transferência"
Private aSay 		:= {}
Private aButton 	:= {}
Private oProcess  	:= Nil
Private cMarca   	:= GetMark()
Private lInverte 	

//---> REMOVIDO compatibilização para versão 12.1.25.
//CriaSX1(cPerg)
Pergunte(cPerg,.F.)

aAdd( aSay, "Impressão Carta de Transferência." ) 

aAdd( aButton, { 5,.T.,{|| Pergunte(cPerg,.T.)}})
aAdd( aButton, { 1,.T.,{|| nOpca := 1 ,FechaBatch()}})
aAdd( aButton, { 2,.T.,{|| FechaBatch() }} )

FormBatch( cCadastro, aSay, aButton )

If nOpcA == 1 
	MsgRun( "Processando","Selecionando registros.", {|| RepR01Processa() } )
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Rep02Processa
Função inicio de Processamento

@author TOTVS Serra do Mar [JOSE CARLOS]
@since 27/06/2016
@version P12
/*/
//-------------------------------------------------------------------
Static Function RepR01Processa() 
Local oFnt		:= Nil
Local aSize 	:= MSADVSIZE()
Local oDlg1		:= Nil
Local aStru		:= {} 
Local cFileWork := ""
Local cQuery	:= ""
Local cAliasQry	:= GetNextAlias()
Local nHeight	:= 0
Local nWidth	:= 0
Local aCoors 	:= {}
//Local nValor	:= 0
//Local oValor	:= Nil
//Local nQtdTit	:= 0
//Local oQtda		:= Nil
Local oMark		:= Nil
Local aCampos	:= {}
Local oPanel	:= Nil
Local nOpca		:= 0

DEFINE FONT oFnt NAME "Arial" SIZE 12,14 BOLD

AADD(aStru,{"E1_OK"			,"C",2,0})
AADD(aStru,{"E1_FILIAL"		,"C",TamSx3('E1_FILIAL')[1],0})
AADD(aStru,{"E1_PREFIXO"	,"C",TamSx3('E1_PREFIXO')[1],0})
AADD(aStru,{"E1_NUM"		,"C",TamSx3('E1_NUM')[1],0})
AADD(aStru,{"E1_CLIENTE"	,"C",TamSx3('E1_CLIENTE')[1],0})
AADD(aStru,{"E1_LOJA"		,"C",TamSx3('E1_LOJA')[1],0})
AADD(aStru,{"A1_NOME"		,"C",TamSx3('A1_NOME')[1],0})
AADD(aStru,{"E1_EMISSAO"	,"D",8,0})

Aadd( aCampos, { "E1_OK" 		, "", " [X]"		, "" } )	
Aadd( aCampos, { "E1_FILIAL"	, "", "Filial"		, "" } )
Aadd( aCampos, { "E1_PREFIXO" 	, "", "PRF"			, "" } )
Aadd( aCampos, { "E1_NUM" 		, "", "Número"		, "" } )
Aadd( aCampos, { "E1_CLIENTE" 	, "", "Cod.Cliente"	, "" } )
Aadd( aCampos, { "E1_LOJA" 		, "", "Loja"		, "" } )
Aadd( aCampos, { "A1_NOME" 		, "", "Nome"		, "" } )
Aadd( aCampos, { "E1_EMISSAO" 	, "", "Emissao"		, "" } )

//cFileWork := CriaTrab(aStru,.T.)
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Certifico de que o TRB esta fechado.                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (Select("TRBREL") <> 0)     
	dbSelectArea("TRBREL")
	dbCloseArea()
Endif

// MIGRACAO BD - NOVA ESTRUTURA DE TABELA TEMPORÁRIA
_cArq      := "TRBREL"
_cChaveInd := GETNEXTALIAS()

oTable := FwTemporaryTable():New( _cArq)
oTable:SetFields(aStru)
oTable:AddIndex(_cChaveInd, {"E1_FILIAL","E1_PREFIXO","E1_NUM","E1_CLIENTE","E1_LOJA"}) 
oTable:Create()

DbSelectArea(_cArq)

//USE &cFileWork ALIAS TRBREL EXCLUSIVE NEW
//IndRegua("TRBREL",cFileWork,"E1_FILIAL+E1_PREFIXO+E1_NUM+E1_CLIENTE+E1_LOJA",,,OemToAnsi("Selecionando Registros..."))  

cQuery := "SELECT DISTINCT E1_FILIAL,E1_PREFIXO,E1_NUM,E1_CLIENTE,E1_LOJA,A1_NOME,E1_EMISSAO "
cQuery += "FROM "+RetSqlName('SE1')+ " SE1, " + RetSqlName('SC5')+ " SC5, " + RetSqlName('SA1')+ " SA1, "
cQuery += "WHERE E1_FILIAL = '"+xFilial('SE1')+"' "
cQuery += "AND E1_EMISSAO BETWEEN '"+DtoS(Mv_Par01)+"' AND '"+DtoS(Mv_Par02) +"' "
cQuery += "AND C5_FILIAL = '"+xFilial('SC5')+"' AND E1_PEDIDO <> ' ' AND C5_NUM = E1_PEDIDO "
cQuery += "AND C5_BANCO = '"+Mv_Par03+"' "
cQuery += "AND C5_XAGENCI = '"+Mv_Par04+"' "
cQuery += "AND C5_XDVAGE = '"+Mv_Par05+"' "
cQuery += "AND C5_XNUMCON = '"+Mv_Par06+"' "
cQuery += "AND C5_XDVCTA = '"+Mv_Par07+"' "
cQuery += "AND A1_FILIAL = '"+xFilial('SA1')+"' "
cQuery += "AND E1_CLIENTE = A1_COD "
cQuery += "AND E1_LOJA = A1_LOJA "
cQuery += "AND SE1.D_E_L_E_T_ <> '*' "
cQuery += "AND SA1.D_E_L_E_T_ <> '*' "
cQuery += "AND SC5.D_E_L_E_T_ <> '*' "

cQuery := ChangeQuery(cQuery)
	
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)

While (cAliasQry)->(!Eof())
	dbSelectArea("TRBREL")
	RecLock("TRBREL",.T.)
		TRBREL->E1_FILIAL	:= (cAliasQry)->E1_FILIAL
		TRBREL->E1_PREFIXO	:= (cAliasQry)->E1_PREFIXO
		TRBREL->E1_NUM		:= (cAliasQry)->E1_NUM
		TRBREL->E1_CLIENTE	:= (cAliasQry)->E1_CLIENTE
		TRBREL->E1_LOJA		:= (cAliasQry)->E1_LOJA
		TRBREL->A1_NOME		:= (cAliasQry)->A1_NOME
		TRBREL->E1_EMISSAO	:= Stod((cAliasQry)->E1_EMISSAO)
	MsUnLock()
	(cAliasQry)->(DbSkip())
EndDo 

dbSelectArea("TRBREL")
dbGotop()
If BOF() .And. EOF()
	Help(" ",1,"RECNO")
	Return()
EndIf 

DEFINE MSDIALOG oDlg1 TITLE OemToAnsi("Notas Emitidas") From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL	
oDlg1:lMaximized := .T.

	oPanel := TPanel():New(0,0,'',oDlg1,, .T., .T.,, ,315,20,.T.,.T. )
	oPanel:Align := CONTROL_ALIGN_TOP // Somente Interface MDI
		
//	@ 0.1 , 00.8 SAY OemToAnsi(STR0023) FONT oDlg1:oFont OF oPanel // "Border“ N§"
//	@ 0.1 , 08   Say cNumbor				Picture "@!" FONT oFnt COLOR CLR_HBLUE OF oPanel
//	@ 0.8,.8 Say OemToAnsi('Valor Total:') OF oPanel  // "Valor Total:"
//	@ 0.8, 7 Say oValor VAR nValor Picture "@E 99,999,999.99" SIZE 60,8 OF oPanel
//	@ 0.8,21 Say OemToAnsi("Quantidade:") OF oPanel // "Quantidade:"
//	@ 0.8,32 Say oQtda VAR nQtdTit Picture "@E 99999" SIZE 50,8 OF oPanel
 
 	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If FlatMode()   
		aCoors := GetScreenRes()
		nHeight	:= aCoors[2]
		nWidth	:= aCoors[1]
	Else
		nHeight	:= 143
		nWidth	:= 315
	Endif

//////////////
// Mark Browse	
	oMark := MsSelect():New("TRBREL","E1_OK","",aCampos,@lInverte,@cMarca,{35,1,nHeight,nWidth})
	oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT // Somente Interface MDI
	
	oMark:oBrowse:lhasMark = .t.
	oMark:oBrowse:lCanAllmark := .t.
	oMark:bAval	:=            {|| ra01Inverte(cMarca,.F.),oMark:oBrowse:Refresh(.t.)}
	oMark:oBrowse:bAllMark := {|| ra01Inverte(cMarca,.t.) }
// Mark Browse
////////////// 	
ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1,	{|| nOpca := 1,oDlg1:End()},;
													{|| nOpca := 2,oDlg1:End()},,{})
													
If nOpca == 1
	ImpriCarta()
EndIf

dbSelectArea("TRBREL")
dbCloseArea()
Ferase(cFileWork+GetDBExtension())
Ferase(cFileWork+OrdBagExt())

Return()


//-------------------------------------------------------------------
/*/{Protheus.doc} ra01Inverte
Inverte Marcação

@author TOTVS Serra do Mar [JOSE CARLOS]
@since 27/06/2016
@version P12
/*/
//-------------------------------------------------------------------
Static Function ra01Inverte(cMarca,lTodos)
Local nReg		:= TRBREL->(Recno())
Local lMarcado	:= Nil

If lTodos
	DbSelectArea('TRBREL')
	TRBREL->(DbGoTop())
EndIf

While !lTodos .Or. TRBREL->(!Eof())

	RecLock("TRBREL", .F.)
	(lMarcado := IsMark("E1_OK", cMarca, lInverte))
	If lMarcado .Or. lInverte
		TRBREL->E1_OK:=  Space(2)
	Else
		TRBREL->E1_OK := cMarca
	EndIf
	MsUnlock()
	
	If lTodos
		TRBREL->(DbSkip())
	Else
		Exit	
	Endif	
	
EndDo

TRBREL->(DbGoTo(nReg))

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} ImpriCarta
Integração com Word

@author TOTVS Serra do Mar [JOSE CARLOS]
@since 27/06/2016
@version P12
/*/
//-------------------------------------------------------------------
Static Function ImpriCarta()
Local oWord
Local cFileOpen
Local cPathEst	:= Alltrim(GetTempPath())
Local cOnError	:= ""
Local cModelo	:= "Transf_Videolar.dotm"
Local nTabelas	:= 1
Local cTabela	:= "01"
Local cLinha	:= "001"
Local cColuna	:= "001"
Local cDataExt	:= "São Paulo, " + cValToChar( Day(dDataBase) ) + " de " + MesExtenso( dDataBase ) + " de " + cValTochar( Year(dDatabase) )
Local cNomeCli	:= ""
Local aDupl		:= {}
Local nLinha	:= 0
Local nX		:= 0
//Local cOrigem	:= 'C:\Template\'+cModelo

//Verifica a integração com Word
oWord := OLE_CreateLink(,@cOnError)

If ValType(oWord) <> "C" .Or. oWord == "-1"
	ApMsgInfo('Erro de integração Word ' + cOnError)
Else
	cFileOpen	:= "\DOTS\"+cModelo
	
//	IF !File('\DOTS')
//		MakeDir('\DOTS')
//		If !CPYT2S ( cOrigem , "\DOTS\")
//			ApMsgInfo('Error copiando arquivo.')
//		EndIf		
//	EndIF
	
	If !File(cFileOpen)
		ApMsgInfo('Arquivo Word '+cFileOpen+'não localizado.')
	Else
		// Exibe ou oculta a aplicacao Word.
		//OLE_SetProperty( oWord, oleWdWindowState, '1' )
		//OLE_SetProperty( oWord, oleWdPrintBack, .F.)
		//OLE_SetProperty( oWord, oleWdVisible, .F.)
		If !CpyS2T(cFileOpen,cPathEst,.T.,.T.)
			ApMsgInfo('Erro ao copiar arquivo modelo do servidor')
		Else
		
			DbSelectArea('SE1')
			DbSetOrder(2)
			
			cFileOpen := cPathEst + cModelo
			
			DbSelectArea('TRBREL')
			TRBREL->(DbGoTop())
			While TRBREL->(!Eof())
				If TRBREL->E1_OK == cMarca
				
					If SE1->( DbSeek(xFilial('SE1') + TRBREL->E1_CLIENTE + TRBREL->E1_LOJA + TRBREL->E1_PREFIXO + TRBREL->E1_NUM ) )
						aDupl := {}
						While SE1->(!Eof())	.And. SE1->E1_FILIAL == xFilial('SE1') .And. SE1->E1_CLIENTE == TRBREL->E1_CLIENTE .And. SE1->E1_LOJA == TRBREL->E1_LOJA ;
													.And. TRBREL->E1_PREFIXO == SE1->E1_PREFIXO .And. TRBREL->E1_NUM == SE1->E1_NUM
							Aadd( aDupl, {Alltrim(SE1->E1_PREFIXO)+"/"+Alltrim(SE1->E1_NUM)+"/"+Alltrim(SE1->E1_PARCELA),SE1->E1_VENCREA,SE1->E1_VALOR} )						  
						
							SE1->(DbSkip())
						EndDo			
					EndIf
					
					// Inicia com novo arquivo 
					OLE_NewFile(oWord, cFileOpen)
					// Executa a macro que posiciona na data 
					OLE_ExecuteMacro(oWord, "GODATA" )
					// Atualiza a variavel	
					OLE_SetDocumentVar(oWord, "DATAEXTENSO", cDataExt)
					
					cNomeCli	:= "Á " + Alltrim(TRBREL->A1_NOME)
						
					// Executa a macro que posiciona na nome do cliente 
					OLE_ExecuteMacro(oWord, "GOCLIENTE" )
					// Atualiza a variavel	
					OLE_SetDocumentVar(oWord, "NOMECLIENTE", cNomeCli)
					
					OLE_SetDocumentVar(oWord, "_TABELAS_", nTabelas)
					// Para todas as tabelas, seta a quantidade de linhas e colunas
					For nX := 1 To nTabelas
						OLE_SetDocumentVar(oWord, cTabela+"_LINHASTAB", Len(aDupl)+1/*2*/)
						OLE_SetDocumentVar(oWord, cTabela+"_COLUNASTAB",3)
					Next
		
					// Executa a macro que cria as variáveis 
					OLE_ExecuteMacro(oWord, "Tabelas" )	

					cTabela:= "01"
					cLinha := "001"
					cColuna:= "001"	
					//TABELA_01_LINHA_001_COLUNA_001
					OLE_SetDocumentVar(oWord, "TABELA_" + cTabela + "_LINHA_"+cLinha+"_COLUNA_"+cColuna, "TÍTULO")
					cTabela:= "01"
					cLinha := "001"
					cColuna:= "002"	
					//TABELA_01_LINHA_001_COLUNA_002
					OLE_SetDocumentVar(oWord, "TABELA_" + cTabela + "_LINHA_"+cLinha+"_COLUNA_"+cColuna, "VENCIMENTO")
					cTabela:= "01"
					cLinha := "001"
					cColuna:= "003"	
					//TABELA_01_LINHA_001_COLUNA_003
					OLE_SetDocumentVar(oWord, "TABELA_" + cTabela + "_LINHA_"+cLinha+"_COLUNA_"+cColuna, "VALOR")
					nLinha := 1
					
					//VarInfo('aDupl',aDupl)
					
					For nX:= 1 To Len( aDupl )
						nLinha ++
						cLinha := StrZero(nLinha,3) 
						OLE_SetDocumentVar(oWord, "TABELA_" + cTabela + "_LINHA_"+cLinha+"_COLUNA_001", aDupl[nX][1])
						OLE_SetDocumentVar(oWord, "TABELA_" + cTabela + "_LINHA_"+cLinha+"_COLUNA_002", aDupl[nX][2])
						OLE_SetDocumentVar(oWord, "TABELA_" + cTabela + "_LINHA_"+cLinha+"_COLUNA_003", Transform(aDupl[nX][3],"@E 999,999,999,999.99"))						
					Next nX
				
					//Atualiza as variáveis do word
					OLE_UpdateFields(oWord)
					
					OLE_PrintFile(oWord,'ALL')
					Sleep(2000)
					OLE_CloseLink(oWord)
					
				EndIF
				
				TRBREL->(DbSkip())
				
			EndDo
			
//			If ApMsgYesNo('Finaliza Integração com o Word?')
//				OLE_CloseLink(oWord)
//			EndIf
			
		EndIf
	EndIf

EndIF

Return()

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

PutSx1(cPerg,"01","Faturdados De" 	,"Faturdados De"  	,"Faturdados De" 	,"mv_ch1","D",8							,0,0,"G","",""   ,"","","MV_PAR01","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
PutSx1(cPerg,"02","Faturdados Ate" 	,"Faturdados Ate" 	,"Faturdados Ate" 	,"mv_ch2","D",8							,0,0,"G","",""   ,"","","MV_PAR02","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
PutSx1(cPerg,"03","Banco"  			,"Banco"  			,"Banco" 			,"mv_ch3","C",TamSX3("A6_COD")[1]		,0,0,"G","","SA6DV","","","MV_PAR03","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
PutSx1(cPerg,"04","Agencia" 		,"Agencia"  		,"Agencia" 			,"mv_ch4","C",TamSX3("A6_AGENCIA")[1]	,0,0,"G","",""   ,"","","MV_PAR04","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
PutSx1(cPerg,"05","DV Ag."  		,"DV"  				,"DV" 				,"mv_ch5","C",TamSX3("A6_DVAGE")[1]		,0,0,"G","",""   ,"","","MV_PAR05","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
PutSx1(cPerg,"06","Conta" 			,"Conta"  			,"Conta" 			,"mv_ch6","C",TamSX3("A6_NUMCON")[1]	,0,0,"G","",""   ,"","","MV_PAR06","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
PutSx1(cPerg,"07","DV Conta"		,"DV Conta"			,"DV Conta" 		,"mv_ch7","C",TamSX3("A6_DVCTA")[1]		,0,0,"G","",""   ,"","","MV_PAR07","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
PutSx1(cPerg,"08","Imp.já emitidos"	,"Imp.já emitidos" 	,"Imp.já emitidos" 	,"mv_ch8","N",1							,0,0,"C","",""   ,"","","MV_PAR08","Sim","Sim","Sim","","Não","Não","Não","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)

Return*/
