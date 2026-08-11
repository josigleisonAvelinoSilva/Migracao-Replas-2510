#Include "Protheus.ch"
#Include "TbiConn.ch"
#Include "Colors.ch"
#Include "RptDef.ch"
#Include "FWPrintSetup.ch"
#Include "TopConn.ch"

#Define Enter Chr(13) + Chr(10) 

// ----------------------------------------------------------------------
/*/{Protheus.doc} FSREPR01
(long_description) Relatorio de Margem de Contribuicao por Preço Medio
@type function  Função de Processamento e Geração do Relatório
@author Eduardo                                                  

@since 25/11/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
// ----------------------------------------------------------------------

User Function FSREPR01()
	
Processa( {|lEnd| FSREPR01A() }, "Gerando Relatório...")	//Processamento da geração de boletos

Return

// ----------------------------------------------------------------------
/*/{Protheus.doc} FSREPR01
(long_description) Relatorio de Margem de Contribuicao por Preço Medio
@type function
@author Eduardo
@since 25/11/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
// ----------------------------------------------------------------------

Static Function FSREPR01A()

Local _aArea		:= GetArea()
Local cQuery		:= ""
// Variaveis do Total
Local _nTotQtd 		:= 0
Local _nTotCus 		:= 0
Local _nTotCMe		:= 0
Local _nTotRec		:= 0
Local _nTotPVM		:= 0
Local _nTotMar		:= 0
Local _nTotPer		:= 0
Local _nTotCalPV	:= 0
Local _nLasComp		:= 0

// Variaveis do Total por Período
Local _nTotalQtd 	:= 0 
Local _nTotalCus 	:= 0
Local _nTotalCMe 	:= 0
Local _nTotalRec 	:= 0
Local _nTotalPVM 	:= 0
Local _nTotalMar 	:= 0
Local _nTotalPer	:= 0
Local _Duplic		:= ""
Local lEstado		:= .F. 
Local lGrupo		:= .F.
Local lMedImp		:= .T.
Local aCampos	:= {}
Local bOk 		:= {|| .T. }
Local aPar 		:= {}
Local aRetDev	:= {}
Local aSX5 := {}
Private aRet 	:= {}
Private nLin		:= 50
Private nMaxLin		:= 500
Private nCol		:= 50
Private nColFim		:= 825
Private cTitulo	:= "Relatório de Faturamento x Compra com todos impostos"
Private cBitmap	:= "C:\Protheus12\Protheus_Data\system\Replas.jpg"
Private lAdjustToLegacy := .F.
Private lDisableSetup   := .T.
Private oPrint	:= Nil
Private nClrAzul	:= RGB(032,038,119)
Private nClrVerm	:= RGB(237,028,036)
Private nPagina		:= 1
Private cPerg	 	:= PadR("MARGEM",10)

oFont07  := TFont():New( "Arial",,07,,.F.,,,,,.F. )
oFont07B := TFont():New( "Arial",,07,,.T.,,,,,.F. )
oFont08  := TFont():New( "Arial",,08,,.F.,,,,,.F. )
oFont08B := TFont():New( "Arial",,08,,.T.,,,,,.F. )
oFont09  := TFont():New( "Arial",,09,,.F.,,,,,.F. )
oFont09B := TFont():New( "Arial",,09,,.T.,,,,,.F. )
oFont10  := TFont():New( "Arial",,10,,.F.,,,,,.F. )
oFont10B := TFont():New( "Arial",,10,,.T.,,,,,.F. )
oFont11  := TFont():New( "Arial",,11,,.F.,,,,,.F. )
oFont11B := TFont():New( "Arial",,11,,.T.,,,,,.F. )
oFont12  := TFont():New( "Arial",,12,,.F.,,,,,.F. )
oFont12B := TFont():New( "Arial",,12,,.T.,,,,,.F. )
oFont14  := TFont():New( "Arial",,14,,.F.,,,,,.F. )
oFont14B := TFont():New( "Arial",,14,,.T.,,,,,.F. )
oFont16  := TFont():New( "Arial",,16,,.F.,,,,,.F. )
oFont16B := TFont():New( "Arial",,16,,.T.,,,,,.F. )
oFont18  := TFont():New( "Arial",,16,,.F.,,,,,.F. )
oFont18B := TFont():New( "Arial",,16,,.T.,,,,,.F. )

// Função da Tela de Perguntas para filtro do Relatorio
//u_FSTSMT01()

// Perguntas
//ValidPerg()

aAdd( aPar,{ 1,"Emissao De	"    			,CtoD(Space(8))	 	,""	,""			,""			,""		,60,.T.} )
aAdd( aPar,{ 1,"Emissao Ate	"    			,CtoD(Space(8))	 	,""	,""			,""			,""		,60,.T.} )
aAdd( aPar,{ 1,"Grupo De	" 				,Space(4)			,""	,""			,"XGRUPO"	,""		,60,.F.} )
aAdd( aPar,{ 1,"Grupo Ate	"  	 			,Space(4)			,""	,""			,"XGRUPO"	,""		,60,.F.} )
aAdd( aPar,{ 1,"Fam. Contem	" 				,Space(200)			,""	,""			,"GRUPO"	,""		,60,.F.} )
aAdd( aPar,{ 1,"Sigla Estado "    			,Space(2)		 	,""	,""			,"XESTAD"	,""		,60,.F.} )
aAdd( aPar,{ 2,"Custo Méd. com Imposto"	,1				 	,{'Sim','Não'}	,50			,"AllwaysTrue()",.F.} )

If !ParamBox( aPar, 'Faturamento x Compra', @aRet, bOK, , , , , , ,  .T., .T. )
	Return
EndIf
	
MV_PAR01 := aRet[1]
MV_PAR02 := aRet[2]
MV_PAR03 := aRet[3]
MV_PAR04 := aRet[4]
MV_PAR05 := aRet[5]
MV_PAR06 := aRet[6]
MV_PAR07 := IIF(ValType(aRet[7]) == "C" , IIF (aRet[7] == "Não" , 2, 1),  aRet[7])

cEmisIni	:= Mv_Par01
cEmisFim	:= Mv_Par02
cFamiIni	:= Mv_Par03
cFamiFim	:= Mv_Par04
cContFam	:= Mv_Par05
cEstado		:= Mv_Par06
lMedImp		:= Mv_Par07 == 1

// Tratamento da Query
If Select("TDMO") > 0
   TDMO->( DbCloseArea() )
EndIf                               
cQry := xQryFilt()
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), "TDMO", .F., .T.)

// Impressao
oPrint := FWMSPrinter():New("Relatório_Compras_x_Faturamento.pdf", 6, lAdjustToLegacy,, lDisableSetup,,,,,,,.F.,)
oPrint:SetResolution(72)			// Default
oPrint:SetLandscape() 				// SetLandscape() ou SetPortrait()
oPrint:SetPaperSize(9)				// A4 210mm x 297mm  620 x 876
oPrint:SetMargin(10,10,10,10)		// < nLeft>, < nTop>, < nRight>, < nBottom>
oPrint:cPathPDF:= "C:\temp\"
//oPrint:SetViewPdf(_limpr)
oPrint:StartPage()   	// Inicia uma nova página
oBrush  := TBrush():New(,(0,0,0))
oBrush2 := TBrush():New(,CLR_HGRAY)		// Cinza Claro

nReg := 0
DbEval( {|x| nReg++ },,{ || !Eof() })
DbGotop()
ProcRegua(nReg)

_cEst	 := TDMO->D2_EST
_cGrupo	 := TDMO->D2_GRUPO

While TDMO->(!Eof())
	IncProc("Processando os Registros...")
	
	_Duplic  := Posicione("SF4", 1, xFilial("SF4") + TDMO->D2_TES, "F4_DUPLIC")
	_DestIPI := .T.//Posicione("SF4", 1, xFilial("SF4") + TDMO->D2_TES, "F4_DESTACA") == 'S' 
	
	If _Duplic <> "S"
		TDMO->(DbSkip())
		Loop
	Endif
	
	//If !Empty(cContGrup) .And. cContGrup $ TDMO->D2_GRUPO
	
	    If nLin == 0050
	       Cabec()                            
	       nLin := 0140
	    EndIf
	    If nLin > nMaxLin
			oPrint:EndPage()
			oPrint:StartPage()
			Cabec()
			nLin := 0140
		EndIf    
		//---> REMOVIDO compatibilização para versão 12.1.25.
		//_cDescUF := Posicione("SX5",1,xFilial("SX5") + "12" + TDMO->D2_EST,"X5_DESCRI")
		aSX5 := FWGetSX5( '12', PadR( RTrim( TDMO->D2_EST ), 6 ) )
		_cDescUF := aSX5[1,4]
		_cDesGrp := Posicione("SBM", 1, xFilial("SBM") + TDMO->D2_GRUPO, "BM_DESC")
		_cDesPro := Posicione("SB1", 1, xFilial("SB1") + TDMO->D2_COD, "B1_DESC") 
		//CBF- Silvio solicitou a mudança p/ ultima compra do periodo
		//_nLasComp := Posicione("SB1", 1, xFilial("SB1") + TDMO->D2_COD, "B1_UPRC")
		_nLasComp := U_getUPer(TDMO->D2_COD, cEmisIni, cEmisFim)
		If lMedImp
			_nCusMed := U_getCMed(TDMO->D2_COD,cEmisFim, U_getPRD(TDMO->D2_COD,cEmisFim, TDMO->D2_CUSTO1 / TDMO->D2_QUANT) ) 
		EndIf
		
		If _cEst == TDMO->D2_EST	// Se for o Mesmo Estado
			If lEstado == .F.
				// Box Estado
				BuzzBox (nLin,nCol - 0040,nLin + 0015,nColFim - 0440)
				oPrint:FillRect({nLin + 0001,nCol - 0039,nLin + 0014,nColFim - 0441 },oBrush2)	// Pinta o Box do Cabecalho da Cor Cinza Claro
				oPrint:Say (nLin + 0010, 0020,"Estado" ,oFont10B)
				oPrint:Say (nLin + 0010, 0100, Alltrim(_cDescUF) + " - " + TDMO->D2_EST,oFont08)
				lEstado := .T.
				nLin += 0020
			EndIf
			If _cGrupo == TDMO->D2_GRUPO 	// Se for o Mesmo Grupo Imprimi os Registros
				If lGrupo == .F.
					// Box Familia (Grupo)  
					BuzzBox (nLin,nCol - 0040,nLin + 0015,nColFim - 0440)
					oPrint:Say (nLin + 0010, 0020,"Família (Grupo)" ,oFont10B)
					oPrint:Say (nLin + 0010, 0100, TDMO->D2_GRUPO + " - " + Alltrim(_cDesGrp),oFont08)
					lGrupo := .T.
					nLin += 0020
				EndIf
				oPrint:Say (nLin + 0010, 0010,TDMO->D2_COD ,oFont07)
				oPrint:Say (nLin + 0010, 0070,Substr(Alltrim(_cDesPro),1,30) ,oFont07)
				// Variaveis para tratamento dos calculos
				If !lMedImp
					//_nCusTot := TDMO->D2_CUSTO1
					_nCusMed := U_getPRD(TDMO->D2_COD,cEmisFim, TDMO->D2_CUSTO1 / TDMO->D2_QUANT)
					_nCusTot := TDMO->D2_QUANT * _nCusMed
				Else
					_nCusTot := TDMO->D2_QUANT * _nCusMed
				EndIf
				_nRecTot := TDMO->D2_TOTAL + IIF(_DestIPI, TDMO->D2_VALIPI , 0 )
				_nPvMed  := _nRecTot / TDMO->D2_QUANT 
				_nMargem := _nRecTot - _nCusTot
				_nPerc	 := _nMargem * 100 / _nCusTot 
				
				oPrint:Say (nLin + 0010, 0280,AlinhVal(Alltrim(Transform(TDMO->D2_QUANT ,"@E 999,999,999.99")))	,oFont07)	// Quantidade
				oPrint:Say (nLin + 0010, 0330,IIF(_nLasComp <> 0, AlinhVal(Alltrim(Transform(_nLasComp ,"@E 999,999,999.99"))), Space(15)+"N/A")		,oFont07)	// Ult. Compra
				oPrint:Say (nLin + 0010, 0410,AlinhVal(Alltrim(Transform(_nCusTot ,"@E 999,999,999.99")))		,oFont07)	// Custo Total
				oPrint:Say (nLin + 0010, 0510,Alltrim(Transform(_nCusMed ,"@E 99.99"))	 						,oFont07)	// Custo Médio
				oPrint:Say (nLin + 0010, 0565,AlinhVal(Alltrim(Transform(_nRecTot ,"@E 999,999,999.99")))		,oFont07)	// Receita Total
				oPrint:Say (nLin + 0010, 0660,Alltrim(Transform(_nPvMed ,"@E 99.99"))							,oFont07)	// PV Médio
				oPrint:Say (nLin + 0010, 0710,AlinhVal(Alltrim(Transform(_nMargem ,"@E 999,999,999.99")))		,oFont07)	// Margem
				oPrint:Say (nLin + 0010, 0790,Alltrim(Transform(_nPerc ,"@E 99.99")) + " %"						,oFont07)	// (%)
				// Variaveis Totalizadoras do Total
				_nTotQtd += TDMO->D2_QUANT
				_nTotCus += _nCusTot
				_nTotCMe := _nTotCus / _nTotQtd
				_nTotRec := TDMO->D2_TOTAL + TDMO->D2_VALIPI
				_nTotCalPV += _nTotRec
				_nTotPVM := _nTotCalPV / _nTotQtd
				_nTotMar := _nTotCalPV - _nTotCus
				_nTotPer := _nTotMar * 100 / _nTotCus
				nLin += 0020
			Else	// Senao for o Mesmo Grupo Imprimi o Total por Familia
				BuzzBox (nLin,nCol - 0020,nLin + 0015,nColFim)
				oPrint:Say (nLin + 0010, 0040,"Total" ,oFont10B)	// Total
				oPrint:Say (nLin + 0010, 0280,AlinhVal(Alltrim(Transform(_nTotQtd ,"@E 999,999,999.99")))	,oFont09B)	// Quantidade Total
				
				oPrint:Say (nLin + 0010, 0410,AlinhVal(Alltrim(Transform(_nTotCus ,"@E 999,999,999.99")))	,oFont09B)	// Custo Total
				oPrint:Say (nLin + 0010, 0510,Alltrim(Transform(_nTotCMe ,"@E 99.99")) 						,oFont09B)	// Custo Medio Total
				oPrint:Say (nLin + 0010, 0565,AlinhVal(Alltrim(Transform(_nTotCalPV ,"@E 999,999,999.99")))	,oFont09B)	// Receita Total
				oPrint:Say (nLin + 0010, 0660,Alltrim(Transform(_nTotPVM ,"@E 99.99"))			 			,oFont09B)	// PV Medio Total
				oPrint:Say (nLin + 0010, 0710,AlinhVal(Alltrim(Transform(_nTotMar ,"@E 999,999,999.99"))) 	,oFont09B)	// Margem Total
				oPrint:Say (nLin + 0010, 0790,Alltrim(Transform(_nTotPer ,"@E 99.99")) + " %"				,oFont09B)	// Percentual Total
				// Variaveis Totallizadoras do Total por Período		
				_nTotalQtd += _nTotQtd
				_nTotalCus += _nTotCus
				_nTotalCMe := _nTotalCus / _nTotalQtd
				_nTotalRec += _nTotCalPV
				_nTotalPVM := _nTotalRec / _nTotalQtd
				_nTotalMar := _nTotalRec - _nTotalCus
				_nTotalPer := _nTotalMar * 100 / _nTotalCus
				nLin += 0020
	            If _cGrupo <> TDMO->D2_GRUPO	// Senao for o Mesmo Grupo Imprimi os Registros
	            	// Zero as variaveis apos a Impressao do Total
					_nTotQtd := 0
					_nTotCus := 0
					_nTotCMe := 0
					_nTotRec := 0
					_nTotCalPV := 0
					_nTotPVM := 0
					_nTotMar := 0
					_nTotPer := 0
					// Carregando a variavel com Codigo do Grupo
	       			_cGrupo := TDMO->D2_GRUPO
					// Box Familia (Grupo)  
					BuzzBox (nLin,nCol - 0040,nLin + 0015,nColFim - 0440)
					oPrint:Say (nLin + 0010, 0020,"Família (Grupo)" ,oFont10B)
					oPrint:Say (nLin + 0010, 0100, TDMO->D2_GRUPO + " - " + Alltrim(_cDesGrp),oFont08)
					lGrupo := .T.
					nLin += 0020
					oPrint:Say (nLin + 0010, 0010,TDMO->D2_COD ,oFont07)
					oPrint:Say (nLin + 0010, 0070,Substr(Alltrim(_cDesPro),1,30) ,oFont07)
					// Variaveis para tratamento dos calculos
					If !lMedImp
						_nCusMed := U_getPRD(TDMO->D2_COD,cEmisFim, TDMO->D2_CUSTO1 / TDMO->D2_QUANT)
						_nCusTot := TDMO->D2_QUANT * _nCusMed
			
					//	_nCusTot := TDMO->D2_CUSTO1
					//	_nCusMed := TDMO->D2_CUSTO1 / TDMO->D2_QUANT
					Else
						_nCusTot := TDMO->D2_QUANT * _nCusMed
					EndIf
					
					_nRecTot := TDMO->D2_TOTAL + IIF(_DestIPI, TDMO->D2_VALIPI , 0 )
					_nPvMed  := _nRecTot / TDMO->D2_QUANT 
					_nMargem := _nRecTot - _nCusTot
					_nPerc	 := _nMargem * 100 / _nCusTot 
					oPrint:Say (nLin + 0010, 0280,AlinhVal(Alltrim(Transform(TDMO->D2_QUANT ,"@E 999,999,999.99")))	,oFont07)	// Quantidade
					oPrint:Say (nLin + 0010, 0330,IIF(_nLasComp <> 0, AlinhVal(Alltrim(Transform(_nLasComp ,"@E 999,999,999.99"))), Space(15)+"N/A")		,oFont07)	// Ult. Compra
					oPrint:Say (nLin + 0010, 0410,AlinhVal(Alltrim(Transform(_nCusTot ,"@E 999,999,999.99")))		,oFont07)	// Custo Total
					oPrint:Say (nLin + 0010, 0510,Alltrim(Transform(_nCusMed ,"@E 99.99"))	 						,oFont07)	// Custo Médio
					oPrint:Say (nLin + 0010, 0565,AlinhVal(Alltrim(Transform(_nRecTot ,"@E 999,999,999.99")))		,oFont07)	// Receita Total
					oPrint:Say (nLin + 0010, 0660,Alltrim(Transform(_nPvMed ,"@E 99.99"))							,oFont07)	// PV Médio
					oPrint:Say (nLin + 0010, 0710,AlinhVal(Alltrim(Transform(_nMargem ,"@E 999,999,999.99")))		,oFont07)	// Margem
					oPrint:Say (nLin + 0010, 0790,Alltrim(Transform(_nPerc ,"@E 99.99")) + " %"						,oFont07)	// (%)
					// Variaveis Totalizadoras do Total
					_nTotQtd += TDMO->D2_QUANT
					_nTotCus += _nCusTot
					_nTotCMe := _nTotCus / _nTotQtd
					_nTotRec := TDMO->D2_TOTAL + IIF(_DestIPI, TDMO->D2_VALIPI , 0 )
					_nTotCalPV += _nTotRec
					_nTotPVM := _nTotCalPV / _nTotQtd
					_nTotMar := _nTotCalPV - _nTotCus
					_nTotPer := _nTotMar * 100 / _nTotCus
					nLin += 0020
				EndIf
			EndIf
		Else	// Senao for o Mesmo Estado Imprimi o Total por Familia
			// Box Total
			BuzzBox (nLin,nCol - 0020,nLin + 0015,nColFim)
			oPrint:Say (nLin + 0010, 0040,"Total" ,oFont10B)	// Total
			oPrint:Say (nLin + 0010, 0280,AlinhVal(Alltrim(Transform(_nTotQtd ,"@E 999,999,999.99")))	,oFont09B)	// Quantidade Total
			
			oPrint:Say (nLin + 0010, 0410,AlinhVal(Alltrim(Transform(_nTotCus ,"@E 999,999,999.99")))	,oFont09B)	// Custo Total
			oPrint:Say (nLin + 0010, 0510,Alltrim(Transform(_nTotCMe ,"@E 99.99")) 						,oFont09B)	// Custo Medio Total
			oPrint:Say (nLin + 0010, 0565,AlinhVal(Alltrim(Transform(_nTotCalPV ,"@E 999,999,999.99"))) 	,oFont09B)	// Receita Total
			oPrint:Say (nLin + 0010, 0660,Alltrim(Transform(_nTotPVM ,"@E 99.99"))			 			,oFont09B)	// PV Medio Total
			oPrint:Say (nLin + 0010, 0710,AlinhVal(Alltrim(Transform(_nTotMar ,"@E 999,999,999.99"))) 	,oFont09B)	// Margem Total
			oPrint:Say (nLin + 0010, 0790,Alltrim(Transform(_nTotPer ,"@E 99.99")) + " %"				,oFont09B)	// Percentual Total
			// Variaveis Totalizadoras do Total por Período		
			_nTotalQtd += _nTotQtd
			_nTotalCus += _nTotCus
			_nTotalCMe := _nTotalCus / _nTotalQtd
			_nTotalRec += _nTotCalPV
			_nTotalPVM := _nTotalRec / _nTotalQtd
			_nTotalMar := _nTotalRec - _nTotalCus
			_nTotalPer := _nTotalMar * 100 / _nTotalCus
			nLin += 0020
			_cEst	 := TDMO->D2_EST
			// Box Estado
			BuzzBox (nLin,nCol - 0040,nLin + 0015,nColFim - 0440)
			oPrint:FillRect({nLin + 0001,nCol - 0039,nLin + 0014,nColFim - 0441 },oBrush2)	// Pinta o Box do Cabecalho da Cor Cinza Claro
			oPrint:Say (nLin + 0010, 0020,"Estado" ,oFont10B)
			oPrint:Say (nLin + 0010, 0100, Alltrim(_cDescUF) + " - " + TDMO->D2_EST,oFont08)
			lEstado := .T.
			nLin += 0020
			If _cGrupo <> TDMO->D2_GRUPO .Or. _cEst	== TDMO->D2_EST	// Senao for o Mesmo Grupo Imprimi os Registros
	            // Zero as variaveis apos a Impressao do Total
				_nTotQtd := 0
				_nTotCus := 0
				_nTotCMe := 0
				_nTotRec := 0
				_nTotCalPV := 0
				_nTotPVM := 0
				_nTotMar := 0
				_nTotPer := 0
				// Carregando a variavel com Codigo do Grupo
	       		_cGrupo := TDMO->D2_GRUPO
				// Box Familia (Grupo)  
				BuzzBox (nLin,nCol - 0040,nLin + 0015,nColFim - 0440)
				oPrint:Say (nLin + 0010, 0020,"Família (Grupo)" ,oFont10B)
				oPrint:Say (nLin + 0010, 0100, TDMO->D2_GRUPO + " - " + Alltrim(_cDesGrp),oFont08)
				lGrupo := .T.
				nLin += 0020
				oPrint:Say (nLin + 0010, 0010,TDMO->D2_COD ,oFont07)
				oPrint:Say (nLin + 0010, 0070,Substr(Alltrim(_cDesPro),1,30) ,oFont07)
				// Variaveis para tratamento dos calculos
				If !lMedImp
					_nCusMed := U_getPRD(TDMO->D2_COD,cEmisFim, TDMO->D2_CUSTO1 / TDMO->D2_QUANT)
					_nCusTot := TDMO->D2_QUANT * _nCusMed
					
					//_nCusTot := TDMO->D2_CUSTO1
					//_nCusMed := TDMO->D2_CUSTO1 / TDMO->D2_QUANT
				Else
					_nCusTot := TDMO->D2_QUANT * _nCusMed
				EndIf
				_nRecTot := TDMO->D2_TOTAL + IIF(_DestIPI, TDMO->D2_VALIPI , 0 )
				_nPvMed  := _nRecTot / TDMO->D2_QUANT 
				_nMargem := _nRecTot - _nCusTot
				_nPerc	 := _nMargem * 100 / _nCusTot 
				oPrint:Say (nLin + 0010, 0280,AlinhVal(Alltrim(Transform(TDMO->D2_QUANT ,"@E 999,999,999.99")))	,oFont07)	// Quantidade
			
				oPrint:Say (nLin + 0010, 0410,AlinhVal(Alltrim(Transform(_nCusTot ,"@E 999,999,999.99")))		,oFont07)	// Custo Total
				oPrint:Say (nLin + 0010, 0510,Alltrim(Transform(_nCusMed ,"@E 99.99"))	 						,oFont07)	// Custo Médio
				oPrint:Say (nLin + 0010, 0565,AlinhVal(Alltrim(Transform(_nRecTot ,"@E 999,999,999.99")))		,oFont07)	// Receita Total
				oPrint:Say (nLin + 0010, 0660,Alltrim(Transform(_nPvMed ,"@E 99.99"))							,oFont07)	// PV Médio
				oPrint:Say (nLin + 0010, 0710,AlinhVal(Alltrim(Transform(_nMargem ,"@E 999,999,999.99")))		,oFont07)	// Margem
				oPrint:Say (nLin + 0010, 0790,Alltrim(Transform(_nPerc ,"@E 99.99")) + " %"						,oFont07)	// (%)
				// Variaveis Totallizadoras do Total
				_nTotQtd += TDMO->D2_QUANT
				_nTotCus += _nCusTot
				_nTotCMe := _nTotCus / _nTotQtd
				_nTotRec := TDMO->D2_TOTAL + IIF(_DestIPI, TDMO->D2_VALIPI , 0 )
				_nTotCalPV += _nTotRec
				_nTotPVM := _nTotCalPV / _nTotQtd
				_nTotMar := _nTotCalPV - _nTotCus
				_nTotPer := _nTotMar * 100 / _nTotCus
				nLin += 0020
			EndIf
		EndIf
	//EndIf
	TDMO->(DbSkip())
EndDo

// Box Total
BuzzBox (nLin,nCol - 0020,nLin + 0015,nColFim)
oPrint:Say (nLin + 0010, 0040,"Total" ,oFont10B)	// Total
oPrint:Say (nLin + 0010, 0280,AlinhVal(Alltrim(Transform(_nTotQtd ,"@E 999,999,999.99")))	,oFont09B)	// Quantidade Total

oPrint:Say (nLin + 0010, 0410,AlinhVal(Alltrim(Transform(_nTotCus ,"@E 999,999,999.99")))	,oFont09B)	// Custo Total
oPrint:Say (nLin + 0010, 0510,Alltrim(Transform(_nTotCMe ,"@E 99.99")) 						,oFont09B)	// Custo Medio Total
oPrint:Say (nLin + 0010, 0565,AlinhVal(Alltrim(Transform(_nTotCalPV ,"@E 999,999,999.99")))	,oFont09B)	// Receita Total
oPrint:Say (nLin + 0010, 0660,Alltrim(Transform(_nTotPVM ,"@E 99.99"))			 			,oFont09B)	// PV Medio Total
oPrint:Say (nLin + 0010, 0710,AlinhVal(Alltrim(Transform(_nTotMar ,"@E 999,999,999.99"))) 	,oFont09B)	// Margem Total
oPrint:Say (nLin + 0010, 0790,Alltrim(Transform(_nTotPer ,"@E 99.99")) + " %"				,oFont09B)	// Percentual Total
nLin += 0030

//Retorna dados de devolução 1-Valor 2-IPI 3-Quantidade
aRetDev	   := U_getDev(cEmisIni, cEmisFim, cFamiIni, cFamiFim, cContFam, cEstado)

// Variaveis de Totalizador para tratar o Total do Período
_nTotalQtd += _nTotQtd
_nTotalCus += _nTotCus
_nTotalCMe := _nTotalCus / _nTotalQtd
_nTotalRec += _nTotCalPV
//_nTotalRec -= 	
_nTotalPVM := _nTotalRec / _nTotalQtd
_nTotalMar := _nTotalRec - _nTotalCus
_nTotalPer := _nTotalMar * 100 / _nTotalCus

/*
_nTotalPVM := (_nTotalRec - (aRetDev[1]+aRetDev[2])) / _nTotalQtd
_nTotalMar := _nTotalRec - (aRetDev[1]+aRetDev[2]) - _nTotalCus
_nTotalPer := _nTotalMar * 100 / _nTotalCus
*/
/*/
		
/*/
// Box 			
BuzzBox (nLin,nCol - 0020,nLin + 0045,nColFim)
oPrint:FillRect({nLin + 0001,nCol - 0019,nLin + 0044,nColFim - 0001 },oBrush2)	// Pinta o Box do Cabecalho da Cor Cinza Claro

// Total por Período
oPrint:Say (nLin + 0010, 0040,"Total do Período" ,oFont10B)
oPrint:Say (nLin + 0010, 0280,"(+)"+Padl(AlinhVal(Alltrim(Transform(_nTotalQtd ,"@E 999,999,999.99"))),20)	,oFont10B)
oPrint:Say (nLin + 0010, 0410,"(+)"+Padl(AlinhVal(Alltrim(Transform(_nTotalCus ,"@E 999,999,999.99"))),20)	,oFont10B)
oPrint:Say (nLin + 0010, 0510,Alltrim(Transform(_nTotalCMe ,"@E 99.99"))									,oFont10B)
oPrint:Say (nLin + 0010, 0565,"(+)"+Padl(AlinhVal(Alltrim(Transform(_nTotalRec ,"@E 999,999,999.99"))),20)	,oFont10B)
oPrint:Say (nLin + 0010, 0660,Alltrim(Transform(_nTotalPVM ,"@E 99.99"))									,oFont10B)
oPrint:Say (nLin + 0010, 0710,Padl(AlinhVal(Alltrim(Transform(_nTotalMar ,"@E 999,999,999.99"))),20)		,oFont10B)
oPrint:Say (nLin + 0010, 0790,Alltrim(Transform(_nTotalPer ,"@E 99.99")) + " %"								,oFont10B)
nLin += 0015

//Devoluções
oPrint:Say (nLin + 0010, 0040,"Devoluções" ,oFont10B)
oPrint:Say (nLin + 0010, 0280,"(-)  "+Padl(AlinhVal(Alltrim(Transform(aRetDev[3] ,"@E 999,999,999.99"))),20)			,oFont10B)
oPrint:Say (nLin + 0010, 0410,"(-)  "+Padl(AlinhVal(Alltrim(Transform(aRetDev[3]*_nTotalCMe ,"@E 999,999,999.99"))),20)	,oFont10B)
oPrint:Say (nLin + 0010, 0510,Alltrim(Transform(_nTotalCMe ,"@E 99.99"))												,oFont10B)
oPrint:Say (nLin + 0010, 0565,"(-)  "+Padl(AlinhVal(Alltrim(Transform(aRetDev[1]+aRetDev[2] ,"@E 999,999,999.99"))),20)	,oFont10B)
oPrint:Say (nLin + 0010, 0660,Alltrim(Transform( (aRetDev[1]+aRetDev[2])/aRetDev[3] ,"@E 99.99"))						,oFont10B)
oPrint:Say (nLin + 0010, 0710,Padl(AlinhVal(Alltrim(Transform((aRetDev[1]+aRetDev[2]) - (aRetDev[3]*_nTotalCMe) ,"@E 999,999,999.99"))),20)						,oFont10B)
oPrint:Say (nLin + 0010, 0790,"  "+Alltrim(Transform(0 ,"@E 99.99")) + " %"												,oFont10B)
nLin += 0015

// Resultado
_nTotalQtd -= aRetDev[3]
_nTotalRec -= aRetDev[1] + aRetDev[2]	
_nTotalPVM := _nTotalRec / _nTotalQtd
_nTotalMar := _nTotalRec - (_nTotalCus - (aRetDev[3]*_nTotalCMe))
_nTotalPer := _nTotalMar * 100 / _nTotalCus

oPrint:Say (nLin + 0010, 0040,"Resultado" ,oFont10B)
oPrint:Say (nLin + 0010, 0280,"(=)"+Padl(AlinhVal(Alltrim(Transform(_nTotalQtd ,"@E 999,999,999.99"))),20)							,oFont10B)
oPrint:Say (nLin + 0010, 0410,"(=)"+Padl(AlinhVal(Alltrim(Transform(_nTotalCus - (aRetDev[3]*_nTotalCMe) ,"@E 999,999,999.99"))),20),oFont10B)
oPrint:Say (nLin + 0010, 0510,Alltrim(Transform(_nTotalCMe ,"@E 99.99"))															,oFont10B)
oPrint:Say (nLin + 0010, 0565,"(=)"+Padl(AlinhVal(Alltrim(Transform(_nTotalRec ,"@E 999,999,999.99"))),20)							,oFont10B)
oPrint:Say (nLin + 0010, 0660,Alltrim(Transform(_nTotalPVM ,"@E 99.99"))															,oFont10B)
oPrint:Say (nLin + 0010, 0710,Padl(AlinhVal(Alltrim(Transform(_nTotalMar ,"@E 999,999,999.99"))),20)								,oFont10B)
oPrint:Say (nLin + 0010, 0790,Alltrim(Transform(_nTotalPer ,"@E 99.99")) + " %"														,oFont10B)


oPrint:EndPage()
oPrint:Preview()
	
WinExec( "Explorer.exe C:\temp\")

Return

// ----------------------------------------------------------------------
/*/{Protheus.doc} Cabec
(long_description) Montagem do Cabeçalho
@type function
@author Eduardo
@since 30/11/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
// ----------------------------------------------------------------------

Static Function Cabec()

// < nRow>, < nCol>, < nBottom>, < nRight>, [ cPixel]
oPrint:SayAlign  (0030,0060,cTitulo,oFont14B,480,14,CLR_RED,2,2)
oPrint:SayBitmap (0017,0010, cBitmap,0120,0060)	// < nRow>, < nCol>, < cBitmap>, [ nWidth], [ nHeight]
// Romaneio de Carga
oPrint:Say (0070, 0200,"Período de " + DtoC(cEmisIni) + " a " + DtoC(cEmisFim) ,oFont11,,nClrAzul)
// Página
oPrint:Say (0070, 0500,"Página: " ,oFont12B,,nClrVerm)
oPrint:Say (0070, 0540,PadL(Alltrim(Str(nPagina++)),3,"0"),oFont12B,,nClrVerm)
oPrint:Line(0080, 0010, 0080, 0580)	// 1° Linha Horizontal do Cabeçalho
oPrint:Line(0085, 0010, 0085, 0580)	// 2° Linha Horizontal do Cabeçalho
oPrint:Say (0100, 0010,"Replas Indústria e Comércio de Resinas Plásticas Ltda" ,oFont10B,,nClrAzul)

nLin := 0110

// Box Cabeçalho Principal
oPrint:FillRect({nLin,nCol - 0040,nLin + 0015,nColFim },oBrush2)	// Pinta o Box do Cabecalho da Cor Cinza Claro
BuzzBox (nLin,nCol - 0040,nLin + 0015,nColFim)
oPrint:Say (nLin + 0010, 0285,"Quantidade" ,oFont10B)
oPrint:Say (nLin + 0010, 0335,"Últ. Compra" ,oFont10B)
oPrint:Say (nLin + 0010, 0410,"Custo Total" ,oFont10B)
oPrint:Say (nLin + 0010, 0490,"Custo Médio" ,oFont10B)
oPrint:Say (nLin + 0010, 0570,"Receita Total" ,oFont10B)
oPrint:Say (nLin + 0010, 0650,"PV Médio" ,oFont10B)
oPrint:Say (nLin + 0010, 0725,"Margem" ,oFont10B)
oPrint:Say (nLin + 0010, 0795,"(%)" ,oFont10B)

nLin += 0020

Return

// ----------------------------------------------------------------------
/*/{Protheus.doc} BuzzBox
(long_description) Desenha um Box Sem Preenchimento
@type function
@author Eduardo
@since 30/11/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
// ----------------------------------------------------------------------

Static Function BuzzBox(_nLinIni,_nColIni,_nLinFin,_nColFin) // < nRow>, < nCol>, < nBottom>, < nRight>

oPrint:Line( _nLinIni,_nColIni,_nLinIni,_nColFin)
oPrint:Line( _nLinFin,_nColIni,_nLinFin,_nColFin)
oPrint:Line( _nLinIni,_nColIni,_nLinFin,_nColIni)
oPrint:Line( _nLinIni,_nColFin,_nLinFin,_nColFin)

Return

// ----------------------------------------------------------------------
/*/{Protheus.doc} xQryFilt
(long_description) Montagem da Query
@type function
@author Eduardo
@since 25/11/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
// ----------------------------------------------------------------------

Static Function xQryFilt()

//Private cContFam	:= ""
Private cQuery		:= ""

cQuery := " SELECT D2_EST, D2_GRUPO, D2_COD, D2_QUANT, D2_TOTAL, D2_VALIPI, D2_CUSTO1, D2_TES, B2_CM1 FROM " + RetSqlName("SD2") + " SD2 "	+ Enter 
cQuery += " INNER JOIN " + RetSqlName("SB2") + " SB2 ON B2_FILIAL = D2_FILIAL AND B2_COD = D2_COD AND B2_LOCAL = D2_LOCAL "			+ Enter
cQuery += " INNER JOIN " + RetSqlName("SBM") + " SBM "
cQuery += " ON BM_FILIAL = '" + xFilial("SBM") + "' AND D2_GRUPO = BM_GRUPO AND SBM.D_E_L_E_T_ = ' ' " 
cQuery += " INNER JOIN " + RetSqlName("SF4") + " SF4 "
cQuery += " ON F4_FILIAL = '" + xFilial("SF4") + "' AND D2_TES = F4_CODIGO AND F4_DUPLIC = 'S' AND SF4.D_E_L_E_T_ = ' '"
cQuery += " WHERE SB2.D_E_L_E_T_ = ' ' "																							+ Enter
cQuery += " 	AND SD2.D_E_L_E_T_ = ' ' "																							+ Enter
cQuery += " 	AND D2_FILIAL = '" + xFilial("SD2") + "' "																			+ Enter 
cQuery += " 	AND D2_EMISSAO >= '" + DtoS(cEmisIni) + "' AND D2_EMISSAO <= '" + DtoS(cEmisFim) + "' "							+ Enter
//cQuery += " 	AND D2_TES NOT IN ('600','644','645','646','702','721') "														+ Enter	// '642'

If !Empty(cFamiFim)
	cQuery += " 	AND D2_GRUPO >= '" + cFamiIni + "' AND D2_GRUPO <= '" + cFamiFim + "' "											+ Enter
EndIf

If !Empty(cContFam)
	cQuery += " 	AND BM_TIPGRU IN ( '" + StrTran(cContFam,";","','") + "' ) "																		+ Enter
EndIf

If !Empty(cEstado)
	cQuery += " 	AND D2_EST = '" + cEstado + "' "																					+ Enter
EndIf

cQuery += " ORDER BY D2_EST "

Return cQuery

// ----------------------------------------------------------------------
/*/{Protheus.doc} AlinhVal
(long_description) Funcao para alinhar os valores
@type function
@author Eduardo
@since 30/11/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
// ----------------------------------------------------------------------

Static Function AlinhVal(cValor)

Local cValor2	:= AllTrim(cValor)
cValor2	:= Replicate(" ",20 - (Len(cValor2) * 2)) + cValor2
If Len(AllTrim(cValor2)) >= 8
	cValor2	:= " " + cValor2
EndIf

Return cValor2

// ----------------------------------------------------------------------
/*/{Protheus.doc} FSREPR01
(long_description) Funcao que Perguntas do SX1
@type function
@author Eduardo
@since 30/11/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
// ----------------------------------------------------------------------

//---> REMOVIDO compatibilização para versão 12.1.25.
/*Static Function ValidPerg()

Local i
Local j
_sAlias := Alias()
DbSelectArea("SX1")
DbSetOrder(1)
cPerg := PadR(cPerg,10)
aRegs:={}
// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
aAdd(aRegs,{cPerg,"01","Emissao De	 ","","","Mv_chA","D",08,0,0,"G","","Mv_Par01","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Emissao Ate	 ","","","Mv_chB","D",08,0,0,"G","","Mv_Par02","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Grupo De	 ","","","Mv_chC","C",04,0,0,"G","","Mv_Par03","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"04","Grupo Ate	 ","","","Mv_chD","C",04,0,0,"G","","Mv_Par04","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"05","Fam. Contem	 ","","","Mv_chE","C",99,0,0,"G","","Mv_Par05","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"06","Sigla Estado ","","","Mv_chF","C",02,0,0,"G","","Mv_Par06","","","","","","","","","","","","","","",""})
For i := 1 to Len(aRegs)
	If !DbSeek(cPerg + aRegs[i,2])
		RecLock("SX1",.T.)
		For j := 1 To Len(aRegs[i])
			FieldPut(j,aRegs[i,j])
		Next
		MsUnlock()
	EndIf
Next
DbSkip()
DbSelectArea(_sAlias)

Return*/

// ----------------------------------------------------------------------
/*/{Protheus.doc} getUPer - Ultima compra até aquele periodo

@type function
@author Caique
@since 09/02/2018

/*/
// ----------------------------------------------------------------------
User Function getUPer(cCod, dEmisIni, dEmisFim)
Local aAreaT	:= getArea()
Local cTmp		:= GetNextAlias()
Local cQuery	:= ""

Default cCod := ""
Default dEmisIni := CTOD("//")
Default dEmisFim := CTOD("//")

cQuery := " SELECT MAX(D1_VUNIT * (1 + (( CASE WHEN F4_DESTACA = 'S' THEN D1_IPI ELSE 0  END) /100)))  ULTCOM "
//cQuery := " SELECT MAX(D1_VUNIT) ULTCOM "
cQuery += " FROM " + RetSqlName("SD1")+ " SD1A "
cQuery += " INNER JOIN " + RetSqlName("SF4")+ " SF4A "
cQuery += " 	ON F4_FILIAL = '" + xFilial("SF4") + "' "
cQuery += " 	AND D1_TES = F4_CODIGO
cQuery += " 	AND F4_UPRC = 'S' "
cQuery += " 	AND SD1A.D_E_L_E_T_ = SF4A.D_E_L_E_T_ "
cQuery += " WHERE D1_FILIAL = '" + xFilial("SD1") + "' "
cQuery += " 	AND D1_COD = '" + cCod + "' " 
cQuery += " 	AND SD1A.D_E_L_E_T_ = '' "
cQuery += " 	AND D1_EMISSAO IN ( "
cQuery += " 						SELECT MAX(SD1B.D1_EMISSAO) "
cQuery += " 						FROM " + RetSqlName("SD1")+ " SD1B " 
cQuery += " 						INNER JOIN " + RetSqlName("SF4")+ " SF4B "
cQuery += " 							ON SF4B.F4_FILIAL = SF4B.F4_FILIAL "
cQuery += " 							AND SD1B.D1_TES   = SF4B.F4_CODIGO "
cQuery += " 							AND SF4B.F4_UPRC = 'S' "
cQuery += " 							AND SD1B.D_E_L_E_T_ = SF4B.D_E_L_E_T_ "
cQuery += " 						WHERE SD1B.D1_FILIAL = SD1A.D1_FILIAL "
cQuery += " 							AND SD1B.D1_COD  = SD1A.D1_COD "
cQuery += " 							AND SD1B.D1_EMISSAO BETWEEN '" +DtoS(dEmisIni)+ "' AND '" +DtoS(dEmisFim)+ "' "
cQuery += " 							AND SD1B.D_E_L_E_T_ = SD1A.D_E_L_E_T_ " 
cQuery += " 						) "

If 	Select(cTmp) > 0
	(cTmp)->(dbCloseArea())
	FErase(cTmp+GetDBExtension())
EndIf
		
cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmp,.F.,.T.)

While !(cTmp)->(EOF())
	nValor := (cTmp)->(ULTCOM)
	(cTmp)->(dbSkip())
EndDo

If 	Select(cTmp) > 0
	(cTmp)->(dbCloseArea())
	FErase(cTmp+GetDBExtension())
EndIf

RestArea(aAreaT)
Return nValor

// ----------------------------------------------------------------------
/*/{Protheus.doc} getCMed - Custo médio até o periodo

@type function
@author Caique
@since 09/02/2018

/*/
// ----------------------------------------------------------------------
User Function getCMed(cCod, dEmisFim, nValor)

Local aAreaT	:= getArea()
Local cTmp		:= GetNextAlias()
Local cTmp2		:= GetNextAlias()
Local cQuery	:= ""
Local nPImp		:= 0
Local nX		:= 0
Local aMovVal	:= {}
Local lEncEst 	:= .F.
Local cEstrut	:= ""

Default cCod := ""
Default dEmisFim := CTOD("//")
Default nValor	:= 0

DbSelectArea("SG1")
SG1->(DbSetOrder(1))
SG1->(DbGoTop())
lEncEst := SG1->(DbSeek(xFilial("SG1")+cCod))

If "CS20E066000720" == AllTrim(cCod)
	cCaique := .T.
EndIF


cQuery := " SELECT D3_EMISSAO, MAX(D3_CUSTO1) ENTVAL "
cQuery += " FROM " + RetSqlName("SD3") +" SD3 " 
cQuery += " WHERE D3_FILIAL = '"+xFilial("SD3")+"' "
cQuery += " AND D3_TM IN ('103') "
cQuery += " AND D3_COD = '"+cCod+"' "
cQuery += " AND D_E_L_E_T_ = ' ' "
cQuery += " 	AND D3_EMISSAO IN ( "
cQuery += " 						SELECT MAX(SD3.D3_EMISSAO) "
cQuery += " 						FROM " + RetSqlName("SD3")+ " SD3 " 
cQuery += " 						WHERE D3_FILIAL = '"+xFilial("SD3")+"' "
cQuery += " 							AND D3_TM IN ('103') "
cQuery += " 							AND D3_COD = '"+cCod+"' "
cQuery += " 							AND D3_EMISSAO <= '" +DtoS(dEmisFim)+ "' "
cQuery += " 							AND D_E_L_E_T_ = ' '" 
cQuery += " 						) "
cQuery += " GROUP BY D3_EMISSAO "

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmp2,.F.,.T.)

While !(cTmp2)->(EOF())
	aAdd(aMovVal , {cCod, (cTmp2)->D3_EMISSAO, (cTmp2)->(ENTVAL) , (cTmp2)->(ENTVAL) /*Custo Oficial*/ } )
	(cTmp2)->(dbSkip())
EndDo

If Empty(aMovVal)
	aAdd(aMovVal , {cCod, DtoS(cTod("01/01/2000")), 0 , 0 /*Custo Oficial*/ } )
EndIf

If 	Select(cTmp2) > 0
	(cTmp2)->(dbCloseArea())
	FErase(cTmp2+GetDBExtension())
EndIf

For nX := 1 to Len(aMovVal)
	If !lEncEst
		cQuery := " SELECT (SUM(NULLIF(D1_TOTAL,0) + (CASE WHEN F4_DESTACA = 'S' THEN D1_VALIPI ELSE 0 END) ) / SUM(NULLIF(D1_QUANT,0))) TOTAL  "
		cQuery += " FROM " + RetSqlName("SD1")+ " SD1 "
		cQuery += " INNER JOIN " + RetSqlName("SF4")+ " SF4 "
		cQuery += " 	ON F4_FILIAL = '" + xFilial("SF4") + "' "
		cQuery += " 	AND D1_TES = F4_CODIGO
		cQuery += " 	AND F4_UPRC = 'S' "
		cQuery += " 	AND SD1.D_E_L_E_T_ = SF4.D_E_L_E_T_ "
		cQuery += " WHERE D1_FILIAL = '" + xFilial("SD1") + "' "
		If lEncEst
			cEstrut := "'" + cCod + "'"
			While !SG1->(Eof()) .And. SG1->G1_COD == cCod
				If !Empty(cEstrut)
					cEstrut += ","
				EndIf
				cEstrut += "'" + SG1->G1_COMP + "'"
				SG1->(DbSkip())
			EndDo
			cQuery += " 	AND D1_COD IN ( " +  cEstrut + " ) " 
		Else
			cQuery += " 	AND D1_COD = '" + cCod + "' "
		Endif
		cQuery += " 	AND SD1.D1_EMISSAO > '" +aMovVal[nX][2]+ "' "
		cQuery += " 	AND SD1.D1_EMISSAO <= '" +DtoS(dEmisFim)+ "' "
		cQuery += " 	AND SD1.D_E_L_E_T_ = ' ' "
	Else
		cQuery := " SELECT G1_COMP, G1_QUANT, (SUM(D1_TOTAL + (CASE "
		cQuery += " 	WHEN F4_DESTACA = 'S' THEN D1_VALIPI "
		cQuery += " 	ELSE 0 "
		cQuery += " 	END)) / SUM(D1_QUANT)) TOTAL "
		cQuery += " FROM " + RetSqlName("SD1")+ " SD1 "
		cQuery += " INNER JOIN " + RetSqlName("SF4")+ " SF4  ON F4_FILIAL = '" + xFilial("SF4") + "' "
		cQuery += " INNER JOIN " + RetSqlName("SG1")+ " SG1 ON G1_FILIAL = '" + xFilial("SG1") + "' "
		cQuery += " 	AND G1_COMP = D1_COD "
		cQuery += " 	AND SD1.D_E_L_E_T_ = SF4.D_E_L_E_T_ "
		cQuery += " 	AND D1_TES = F4_CODIGO "
		cQuery += " 	AND F4_UPRC = 'S' "
		cQuery += " 	AND SD1.D_E_L_E_T_ = SF4.D_E_L_E_T_ "
		cQuery += " WHERE D1_FILIAL = '" + xFilial("SD1") + "' "
		cQuery += " 	AND G1_COD IN ('"+cCod+"') "
		cQuery += " 	AND SD1.D1_EMISSAO > '" +aMovVal[nX][2]+ "' "
		cQuery += " 	AND SD1.D1_EMISSAO <= '" +DtoS(dEmisFim)+ "' "
		cQuery += " 	AND SD1.D_E_L_E_T_ = ' ' "
		cQuery += " GROUP BY G1_COMP, G1_QUANT "	
	EndIf
		
	If Select(cTmp) > 0
		(cTmp)->(dbCloseArea())
		FErase(cTmp+GetDBExtension())
	EndIf
			
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmp,.F.,.T.)
	
	If !(cTmp)->(EOF())	
		aMovVal[nX][4] := 0
	EndIf
	
	While !(cTmp)->(EOF())	
		aMovVal[nX][4] += (cTmp)->(TOTAL) 
		(cTmp)->(dbSkip())
	EndDo
	
	If 	Select(cTmp) > 0
		(cTmp)->(dbCloseArea())
		FErase(cTmp+GetDBExtension())
	EndIf
Next nX

If !lEncEst
	For nX := 1 to Len(aMovVal)
		nPImp += aMovVal[nX][4]
	Next nX
EndIf

If nPImp > nValor
	nValor := nPImp
EndIf

RestArea(aAreaT)

Return nValor


// ----------------------------------------------------------------------
/*/{Protheus.doc} getDev - Dev. Venda

@type function
@author Caique
@since 28/02/2018

/*/
// ----------------------------------------------------------------------
User Function getDev(dEmisIni, dEmisFim, cFamiIni, cFamiFim, cContFam, cEstado)
Local aAreaT	:= getArea()
Local cTmp		:= GetNextAlias()
Local cQuery	:= ""
Local nValor	:= 0
Local nIPI		:= 0
Local nQtd		:= 0

Default dEmisIni := CTOD("//")
Default dEmisFim := CTOD("//")
Default cFamiIni := ""
Default cFamiFim := ""
Default cContFam := ""
Default cEstado := ""

cQuery := " SELECT SUM(D1_VALIPI) IPI , SUM(D1_TOTAL) TOTAL, SUM(D1_QUANT) QUANT "
cQuery += " FROM " + RetSqlName("SD1")+ " SD1  "
cQuery += " INNER JOIN " + RetSqlName("SF4")+ " SF4  "
cQuery += " 	ON F4_FILIAL = '"+xFilial("SF4")+"' AND D1_TES = F4_CODIGO AND F4_DUPLIC = 'S' AND SF4.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN " + RetSqlName("SBM")+ " SBM  "
cQuery += " 	ON BM_FILIAL = '"+xFilial("SBM")+"' AND D1_GRUPO = BM_GRUPO AND SBM.D_E_L_E_T_ = ' ' "
cQuery += " WHERE SD1.D1_FILIAL = '"+xFilial("SD1")+"' "
cQuery += " AND SD1.D1_DTDIGIT BETWEEN '"+dToS(dEmisIni)+"' AND '"+dToS(dEmisFim)+"' "

If !Empty(cFamiFim)
	cQuery += " 	AND D1_GRUPO >= '" + cFamiIni + "' AND D1_GRUPO <= '" + cFamiFim + "' "										
EndIf

If !Empty(cContFam)
	cQuery += " 	AND BM_TIPGRU IN ( '" + StrTran(cContFam,";","','") + "' ) "																	
EndIf

If !Empty(cEstado)
	cQuery += " 	AND D1_EST = '" + cEstado + "' "																				
EndIf
cQuery += " AND SD1.D1_TIPO = 'D' "
cQuery += " AND SD1.D1_SERIE <> '3' "
cQuery += " AND SD1.D_E_L_E_T_ = '' "


cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmp,.F.,.T.)

While !(cTmp)->(EOF())
	nValor += (cTmp)->(TOTAL) 
	nIPI   += (cTmp)->(IPI)
	nQtd   += (cTmp)->(QUANT)
	(cTmp)->(dbSkip())
EndDo

If 	Select(cTmp) > 0
	(cTmp)->(dbCloseArea())
	FErase(cTmp+GetDBExtension())
EndIf

Return {nValor,nIPI,nQtd}

// ----------------------------------------------------------------------
/*/{Protheus.doc} getPRD

@type function
@author Caique
@since 28/02/2018

/*/
// ----------------------------------------------------------------------
User Function getPRD(cCod, dEmisFim, nValor)

Local cTmp2		:= GetNextAlias()

DbSelectArea("SG1")
SG1->(DbSetOrder(1))
SG1->(DbGoTop())
lEncEst := SG1->(DbSeek(xFilial("SG1")+cCod))

If ! lEncEst
	Return nValor
EndIf

If "CS20E066000720" == AllTrim(cCod)
	cCaique := .T.
EndIF

cQuery := " SELECT D3_EMISSAO, MAX(D3_CUSTO1 / D3_QUANT ) ENTVAL "
cQuery += " FROM " + RetSqlName("SD3") +" SD3 " 
cQuery += " WHERE D3_FILIAL = '"+xFilial("SD3")+"' "
cQuery += " AND D3_TM = '001' "
cQuery += " AND D3_COD = '"+cCod+"' "
cQuery += " AND D_E_L_E_T_ = ' ' "
cQuery += " 	AND D3_EMISSAO IN ( "
cQuery += " 						SELECT MAX(SD3.D3_EMISSAO) "
cQuery += " 						FROM " + RetSqlName("SD3")+ " SD3 " 
cQuery += " 						WHERE D3_FILIAL = '"+xFilial("SD3")+"' "
cQuery += " 							AND D3_TM = '001' "
cQuery += " 							AND D3_COD = '"+cCod+"' "
cQuery += " 							AND D3_EMISSAO <= '" +DtoS(dEmisFim)+ "' "
cQuery += " 							AND D_E_L_E_T_ = ' '" 
cQuery += " 						) "
cQuery += " GROUP BY D3_EMISSAO "

If 	Select(cTmp2) > 0
	(cTmp2)->(dbCloseArea())
	FErase(cTmp2+GetDBExtension())
EndIf

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmp2,.F.,.T.)

While !(cTmp2)->(EOF())
	nValor := (cTmp2)->(ENTVAL)
	(cTmp2)->(DBSKIP())
Enddo

If 	Select(cTmp2) > 0
	(cTmp2)->(dbCloseArea())
	FErase(cTmp2+GetDBExtension())
EndIf

Return nValor