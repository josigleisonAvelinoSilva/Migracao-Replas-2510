#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} REPLAR03
Relatório demonstrativo de movimentos da DI

@author TOTVS Serra do Mar [JOSE CARLOS]
@since 19/07/2016
@version P12
/*/
//-------------------------------------------------------------------

User Function REPLAR03()
Local oReport

oReport:= ReportDef()
oReport:PrintDialog()

Return

Static Function ReportDef()
Local oReport
Local oSecao1
Local oSecao11
Local cReport	:= "REPLAR03"
Local cTitulo	:= "Processos DI"
Local cDescr	:= "Este program irá imprimir movimentos."
Local aOrd		:= {}
Local cPerg		:= Padr('REPLAR03',10)

//---> REMOVIDO compatibilização para versão 12.1.25.
//CriaSX1(cPerg)

Pergunte(cPerg,.f.)

oReport	:= TReport():New(cReport,cTitulo,cPerg,{|oReport| ReportPrint(oReport)},cDescr)
oReport:SetLandscape() 

oSecao1	:= TRSection():New(oReport,"Cabeçalho",{""},aOrd)
TRCell():New( oSecao1, "C7_XPROCES"	, "SC7", 'Número do Processo'/*X3Titulo*/, /*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) 
//oSecao1:SetHeaderSection(.F.)

oSecao11 := TRSection():New( oSecao1, "Movimentos" ) // "Dados da Entidade"
TRCell():New( oSecao11, "C7_FILIAL"		, "SC7", /*X3Titulo*/, /*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) 
TRCell():New( oSecao11, "C7_NUM"		, "SC7", 'Ident'/*X3Titulo*/, /*Picture*/,15 /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) 
TRCell():New( oSecao11, "C7_FORNECE"	, "SC7", /*X3Titulo*/, /*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) 
TRCell():New( oSecao11, "C7_LOJA"		, "SC7", /*X3Titulo*/, /*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) 
TRCell():New( oSecao11, "A2_NOME"		, "SA2", /*X3Titulo*/, /*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) 
TRCell():New( oSecao11, "C7_EMISSAO"	, "SC7", /*X3Titulo*/, /*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) 
TRCell():New( oSecao11, "C7_TOTAL"		, "SC7", /*X3Titulo*/, /*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) 
TRCell():New( oSecao11, "C7_XQTDDOL"	, "SC7", /*X3Titulo*/, /*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) 
TRCell():New( oSecao11, "C7_XTXDOLA"	, "SC7", /*X3Titulo*/, /*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) 
TRCell():New( oSecao11, "E2_BAIXA"		, "SE2", /*X3Titulo*/, /*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) 
TRCell():New( oSecao11, "E2_XTXBAIX"	, "SE2", /*X3Titulo*/, /*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) 
TRCell():New( oSecao11, "E2_ACRESC"		, "SE2", 'Lucro financeiro'/*X3Titulo*/, /*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) 
TRCell():New( oSecao11, "E2_DECRESC"	, "SE2", 'Perda financeira'/*X3Titulo*/, /*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) 

Return( oReport )

Static Function ReportPrint( oReport )
Local oSecao1	 := oReport:Section(1)
Local oSecao11	 := oReport:Section(1):Section(1)
Local cAliasQry	 := GetNextAlias()
Local cCodProc	 := ""
Local nLinhas	 := 0
Local nAcresc	 := 0
Local nDecresc	 := 0

BeginSql Alias cAliasQry

	SELECT 	C7_XPROCES PROCESSO,C7_FILIAL FILIAL,'PC ' || C7_NUM IDENT,C7_FORNECE FORNECEDOR,C7_LOJA LOJA,A2_NOME NOME,C7_EMISSAO DTEMISSAO,SUM(C7_TOTAL) TOTAL,
			C7_XQTDDOL QTDEDOLAR, C7_XTXDOLA TXDOLAR,' ' DTBAIXA,0 TXBAIXA, 0 ACRESCIMO, 0 DECRESCIMO
	 FROM %table:SC7% SC7,%table:SA2% SA2
	WHERE C7_FILIAL = %xFilial:SC7% AND C7_XPROCES BETWEEN %exp:Mv_Par01% AND %exp:Mv_Par02% AND C7_XPROCES <> ' '
	  AND C7_FORNECE = A2_COD AND C7_LOJA = A2_LOJA
	  AND A2_FILIAL = %xFilial:SA2%
	  AND SC7.%notdel%
	  AND SA2.%notdel%  
	GROUP BY C7_XPROCES,C7_FILIAL,C7_NUM,C7_XQTDDOL,C7_XTXDOLA,C7_FORNECE,C7_LOJA,A2_NOME,C7_EMISSAO
	UNION ALL
	SELECT F1_XPROCES PROCESSO,F1_FILIAL FILIAL,'NF ' || F1_SERIE || '-' ||F1_DOC IDENT,F1_FORNECE FORNECEDOR,F1_LOJA LOJA,A2_NOME NOME,F1_EMISSAO DTEMISSAO,F1_VALBRUT TOTAL,
		   F1_XQTDDOL QTDEDOLAR, F1_XTXDOLA TXDOLAR,' ' as DTBAIXA,0 TXBAIXA, 0 ACRESCIMO, 0 DECRESCIMO
	FROM %table:SF1% SF1,%table:SA2% SA2
   WHERE F1_FILIAL = %xFilial:SF1% AND F1_XPROCES BETWEEN %exp:Mv_Par01% AND %exp:Mv_Par02% AND F1_XPROCES <> ' ' 
	 AND A2_FILIAL = %xFilial:SA2% AND F1_FORNECE = A2_COD AND F1_LOJA = A2_LOJA AND SF1.%notdel% AND SA2.%notdel% 
	UNION ALL
	SELECT E2_XPROCES PROCESSO,E2_FILIAL FILIAL,'TT ' || E2_PREFIXO || '-' || E2_NUM || '-' || E2_PARCELA IDENT,E2_FORNECE FORNECEDOR,E2_LOJA LOJA,A2_NOME NOME,E2_EMISSAO DTEMISSAO,E2_VALOR TOTAL,
	       E2_XQTDDOL QTDEDOLAR, E2_XTXDOLA TXDOLAR,E2_BAIXA DTBAIXA,E2_XTXBAIX TXBAIXA, E2_ACRESC ACRESCIMO, E2_DECRESC DECRESCIMO
	FROM %table:SE2% SE2,%table:SA2% SA2
   WHERE E2_XPROCES BETWEEN %exp:Mv_Par01% AND %exp:Mv_Par02% AND E2_XPROCES <> ' ' 
	 AND E2_FORNECE = A2_COD AND E2_LOJA = A2_LOJA
	 AND A2_FILIAL = %xFilial:SA2%
	 AND SE2.%notdel% AND SA2.%notdel%
	 
EndSql

(cAliasQry)->(dbSelectArea(cAliasQry))
(cAliasQry)->(dbGoTop())
While (cAliasQry)->(!Eof()) .And. !oReport:Cancel()

	nAcresc	 := 0
	nDecresc := 0

	cCodProc := (cAliasQry)->PROCESSO
	oSecao1:Init()
	oSecao1:Cell("C7_XPROCES"):SetBlock({|| (cAliasQry)->PROCESSO } )
	oSecao1:PrintLine()
	nLinhas ++
	oSecao11:Init()			
	While (cAliasQry)->(!Eof()) .AND. cCodProc == (cAliasQry)->PROCESSO .And. !oReport:Cancel()

		nAcresc	 += (cAliasQry)->ACRESCIMO
		nDecresc += (cAliasQry)->DECRESCIMO

		oSecao11:Cell("C7_FILIAL"):SetBlock({|| (cAliasQry)->FILIAL } )
		oSecao11:Cell("C7_NUM"):SetBlock({|| (cAliasQry)->IDENT } )
		oSecao11:Cell("C7_FORNECE"):SetBlock({|| (cAliasQry)->FORNECEDOR } )
		oSecao11:Cell("C7_LOJA"):SetBlock({|| (cAliasQry)->LOJA } )
		oSecao11:Cell("A2_NOME"):SetBlock({|| (cAliasQry)->NOME } )
		oSecao11:Cell("C7_EMISSAO"):SetBlock({|| Stod((cAliasQry)->DTEMISSAO) } )
		oSecao11:Cell("C7_TOTAL"):SetBlock({|| (cAliasQry)->TOTAL } )
		oSecao11:Cell("C7_XQTDDOL"):SetBlock({|| (cAliasQry)->QTDEDOLAR } )
		oSecao11:Cell("C7_XTXDOLA"):SetBlock({|| (cAliasQry)->TXDOLAR } )										
		oSecao11:Cell("E2_BAIXA"):SetBlock({|| Stod((cAliasQry)->DTBAIXA) } )
		oSecao11:Cell("E2_XTXBAIX"):SetBlock({|| (cAliasQry)->TXBAIXA } )
		oSecao11:Cell("E2_ACRESC"):SetBlock({|| (cAliasQry)->ACRESCIMO } )
		oSecao11:Cell("E2_DECRESC"):SetBlock({|| (cAliasQry)->DECRESCIMO } )

		oSecao11:PrintLine()
		nLinhas ++
		If nLinhas > 60
			oReport:EndPage()
			nLinhas := 0
		EndIf
		(cAliasQry)->(dbSkip())
	
	EndDo

	oReport:SkipLine()
	oReport:ThinLine()
	oReport:SkipLine()
		
	oSecao11:Cell("C7_FILIAL"):SetBlock({|| '' } )
	oSecao11:Cell("C7_NUM"):SetBlock({|| 'TOTAL' } )
	oSecao11:Cell("C7_FORNECE"):SetBlock({|| '' } )
	oSecao11:Cell("C7_LOJA"):SetBlock({|| '' } )
	oSecao11:Cell("A2_NOME"):SetBlock({|| '' } )
	oSecao11:Cell("C7_EMISSAO"):SetBlock({|| '' } )
	oSecao11:Cell("C7_TOTAL"):SetBlock({|| 0 } )
	oSecao11:Cell("C7_XQTDDOL"):SetBlock({|| 0 } )
	oSecao11:Cell("C7_XTXDOLA"):SetBlock({|| 0 } )										
	oSecao11:Cell("E2_BAIXA"):SetBlock({|| '' } )
	oSecao11:Cell("E2_XTXBAIX"):SetBlock({|| 0 } )
	oSecao11:Cell("E2_ACRESC"):SetBlock({|| nAcresc } )
	oSecao11:Cell("E2_DECRESC"):SetBlock({|| nDecresc } )

	oSecao11:PrintLine()
	oSecao11:Finish()
	oSecao1:Finish()

EndDo

(cAliasQry)->(dbSelectArea(cAliasQry))
(cAliasQry)->(dbCloseArea())

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

PutSx1(cPerg,"01","Processo Inicial"  	,"Processo Inicial"  	,"Processo Inicial" ,"mv_ch1","C",TamSX3("C7_XPROCES")[1]	,0,0,"G","","","","","MV_PAR01","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
PutSx1(cPerg,"02","Processo Final" 		,"Processo Final"  		,"Processo Final" 	,"mv_ch2","C",TamSX3("C7_XPROCES")[1]	,0,0,"G","","","","","MV_PAR02","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)

Return*/

