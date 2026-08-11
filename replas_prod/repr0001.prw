#include 'protheus.ch'
#include 'parmtype.ch'

Static c10Cont := ''

/*/{Protheus.doc} repr0001
//TODO Relatório de fluxo de caixa personalizado com informação manual de saldo inicial
@author TOTVS
@since 14/06/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
user function repr0001()
	Local oReport
	
	oReport:= ReportDef()
	oReport:PrintDialog()
return

/*/{Protheus.doc} ReportDef
//TODO Montagem da estrutura do relatório
@author TOTVS
@since 14/06/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ReportDef()

	Local cTitle   := "Emissão de Relatório de Fluxo de Caixa"
	Local oReport
	Local oSection1
	Local oSection2
	Local oSection3
	Local oSection4
	
	//---> REMOVIDO compatibilização para versão 12.1.25.
	//CriaSX1("REPR0001")
	//CriaSXB()
	Pergunte("REPR0001",.F.)
	
	oReport:= TReport():New("REPR0001",cTitle,"REPR0001", {|oReport| ReportPrint(oReport)},"informações de Fluxo de Caixa")
	oReport:nfontbody:=7
	
	//Saldo Inicial
	oSection1:= TRSection():New(oReport,'Saldo Inicial',{}, /* <aOrder> */ ,;
								 /* <.lLoadCells.> */ , , /* <cTotalText>  */, /* !<.lTotalInCol.>  */, /* <.lHeaderPage.>  */,;
								 /* <.lHeaderBreak.> */, /* <.lPageBreak.>  */, /* <.lLineBreak.>  */, /* <nLeftMargin>  */,;
								 .T./* <.lLineStyle.>  */, /* <nColSpace>  */,.T. /*<.lAutoSize.> */, /*<cSeparator> */,;
								 /*<nLinesBefore>  */, /*<nCols>  */, /* <nClrBack> */, /* <nClrFore>  */)
	oSection1:SetReadOnly()
	TRCell():New(oSection1,"PERIODO" ,"   ",'Período'      ,/*Picture*/,49,/*lPixel*/,{|| cPeriodo })
	TRCell():New(oSection1,"SALDOINI","   ",'Saldo Inicial'      ,'@E 9,999,999,999,999.99',TamSX3("E8_SALATUA")[1],/*lPixel*/,{|| nSaldoIni })
	
	//Dados de movimentação
	oSection2:= TRSection():New(oSection1, 'Movimentação', {}, /* <aOrder> */ ,;
								 /* <.lLoadCells.> */ , , /* <cTotalText>  */, /* !<.lTotalInCol.>  */, /* <.lHeaderPage.>  */,;
								 /* <.lHeaderBreak.> */, /* <.lPageBreak.>  */, /* <.lLineBreak.>  */, /* <nLeftMargin>  */,;
								 /* <.lLineStyle.>  */, /* <nColSpace>  */, .t./*<.lAutoSize.> */, /*<cSeparator> */,;
								 /*<nLinesBefore>  */, /*<nCols>  */, /* <nClrBack> */, /* <nClrFore>  */)
	oSection2:SetReadOnly()
	TRCell():New(oSection2,"DTMOV"  ,"   ",'Data'      ,/*Picture*/,10,/*lPixel*/,{|| cDtMov })
	TRCell():New(oSection2,"VLRREC" ,"   ",'Cta a receber'      ,'@E 9,999,999,999,999.99',TamSX3("E8_SALATUA")[1],/*lPixel*/,{|| nVlrRec },,,'RIGHT')
	TRCell():New(oSection2,"VLRPAG" ,"   ",'Cta a Pagar'      ,'@E 9,999,999,999,999.99',TamSX3("E8_SALATUA")[1],/*lPixel*/,{|| nVlrPag },,,'RIGHT')
	TRCell():New(oSection2,"MOEDA2" ,"   ",'Moeda 2 a Pagar'      ,'@E 9,999,999,999,999.99',TamSX3("E8_SALATUA")[1],/*lPixel*/,{|| nMoeda2 },,,'RIGHT')
		TRCell():New(oSection2,"SALDO"  ,"   ",'Saldo'      ,'@E 9,999,999,999,999.99',TamSX3("E8_SALATUA")[1],/*lPixel*/,{|| nSaldoAtu },,,'RIGHT')
	
	//Informações de titulos atrasados
	oSection3:= TRSection():New(oSection1, 'Atrasados', {}, /* <aOrder> */ ,;
								 /* <.lLoadCells.> */ , , /* <cTotalText>  */, /* !<.lTotalInCol.>  */, /* <.lHeaderPage.>  */,;
								 /* <.lHeaderBreak.> */, /* <.lPageBreak.>  */, /* <.lLineBreak.>  */, /* <nLeftMargin>  */,;
								 .T./* <.lLineStyle.>  */, 50/* <nColSpace>  */, .t. /*<.lAutoSize.> */, /*<cSeparator> */,;
								 /*<nLinesBefore>  */, /*<nCols>  */, /* <nClrBack> */, /* <nClrFore>  */)
	oSection3:SetReadOnly()
	TRCell():New(oSection3,"ATRREC" ,"   ",'Total Atrasado a Receber__'  ,'@E 9,999,999,999,999.99',TamSX3("E8_SALATUA")[1],/*lPixel*/,{|| nVlrAtrRec })
	TRCell():New(oSection3,"ATRPAG" ,"   ",'Total Atrasado a Pagar____'  ,'@E 9,999,999,999,999.99',TamSX3("E8_SALATUA")[1],/*lPixel*/,{|| nVlrAtrPag })
	
	//Informações totalizadoras
	oSection4:= TRSection():New(oSection1, 'Totais', {}, /* <aOrder> */ ,;
								 /* <.lLoadCells.> */ , , /* <cTotalText>  */, /* !<.lTotalInCol.>  */, /* <.lHeaderPage.>  */,;
								 /* <.lHeaderBreak.> */, /* <.lPageBreak.>  */, /* <.lLineBreak.>  */, /* <nLeftMargin>  */,;
								 .T./* <.lLineStyle.>  */, 50/* <nColSpace>  */, .T./*<.lAutoSize.> */, /*<cSeparator> */,;
								 /*<nLinesBefore>  */, /*<nCols>  */, /* <nClrBack> */, /* <nClrFore>  */)
	oSection4:SetReadOnly()
	TRCell():New(oSection4,"TOTREC" ,"   ",'Total Receber Período_____' ,'@E 9,999,999,999,999.99',TamSX3("E8_SALATUA")[1],/*lPixel*/,{|| nVlrTotRec })
	TRCell():New(oSection4,"TOTPAG" ,"   ",'Total Pagar Período_______' ,'@E 9,999,999,999,999.99',TamSX3("E8_SALATUA")[1],/*lPixel*/,{|| nVlrtotPag })
	TRCell():New(oSection4,"TOTFIM" ,"   ",'Saldo Final_______________' ,'@E 9,999,999,999,999.99',TamSX3("E8_SALATUA")[1],/*lPixel*/,{|| nVlrFim })
	
Return(oReport)

/*/{Protheus.doc} ReportPrint
//TODO Impressão dos dados do relatório
@author TOTVS
@since 14/06/2019
@version 1.0
@return ${return}, ${return_description}
@param oReport, object, descricao
@type function
/*/
Static Function ReportPrint(oReport)
	Local oSection1   := oReport:Section(1)
	Local oSection2   := oReport:Section(1):Section(1)
	Local oSection3   := oReport:Section(1):Section(2)
	Local oSection4   := oReport:Section(1):Section(3)
	Local cAliasQry	  := GetNextAlias()
	Local nSaldoDia	  := 0
	Local cNotIn	  := '%' + FormatIn(MV_PAR06,";") + "%"
	Local cNotCTA	  := "%%"
	
	Private cPeriodo  := ''
	Private nSaldoIni := 0
	Private cDtMov	  := ''
	Private nVlrRec   := 0
	Private nVlrPag	  := 0
	Private nMoeda2	  := 0
	Private nSaldoAtu := 0
	Private nVlrAtrRec:= 0
	Private nVlrAtrPag:= 0
	Private nVlrTotRec:= 0
	Private nVlrtotPag:= 0
	Private nVlrFim   := 0
	
	If !Empty(MV_PAR09)
		cNotCTA	  := "% E1_PORTADO+E1_AGEDEP+E1_CONTA NOT IN " + FormatIn(MV_PAR09,"/") + " AND %"
	EndIf
	
	//Impressão dos dados de saldo inicial
	oSection1:Init()
	cPeriodo := DtoC(MV_PAR02)+"-"+DtoC(MV_PAR03)
	nSaldoIni:= MV_PAR01
	oSection1:PrintLine()
	
	oReport:SkipLine()
	
	//Impressão de dados da movimentação
	oSection2:Init()
	BeginSQL Alias cAliasQry
		SELECT 
			E1_VENCREA,
			SUM(E1_SALDO) E1_SALDO, 
			SUM(E2_SALDO) E2_SALDO,
			SUM(MOEDA2) MOEDA2
		FROM
			(
			SELECT
				E1_VENCREA, E1_SALDO, 0 E2_SALDO, 0 MOEDA2
			FROM
				%Table:SE1%
			WHERE
				E1_FILIAL BETWEEN %Exp:MV_PAR07% AND %Exp:MV_PAR08% AND
				E1_VENCREA BETWEEN %Exp:DtoS(MV_PAR02)% AND %Exp:DtoS(MV_PAR03)% AND
				%Exp:cNotCTA%
				E1_SALDO > 0 AND
				%NotDel% 
			UNION ALL
			SELECT
				E2_VENCREA, 0 E1_SALDO, E2_SALDO, 0 MOEDA2
			FROM
				%Table:SE2%
			WHERE
				E2_FILIAL BETWEEN %Exp:MV_PAR07% AND %Exp:MV_PAR08% AND
				E2_FORNECE NOT IN %Exp:cNotIn% AND
				E2_VENCREA BETWEEN %Exp:DtoS(MV_PAR02)% AND %Exp:DtoS(MV_PAR03)% AND
				E2_SALDO > 0 AND
				E2_MOEDA = 1 AND
				%NotDel% 
			UNION ALL
			SELECT
				E2_VENCREA, 0 E1_SALDO, 0 E2_SALDO,  E2_SALDO*M2_MOEDA2 MOEDA2
			FROM
				%Table:SE2% SE2 LEFT OUTER JOIN %Table:SM2% M2 ON  %Exp:DtoS(dDataBase)% = M2_DATA AND M2.%NotDel% 
			WHERE
				E2_FILIAL BETWEEN %Exp:MV_PAR07% AND %Exp:MV_PAR08% AND
				E2_FORNECE NOT IN %Exp:cNotIn% AND
				E2_VENCREA BETWEEN %Exp:DtoS(MV_PAR02)% AND %Exp:DtoS(MV_PAR03)% AND
				E2_SALDO > 0 AND
				E2_MOEDA <> 1 AND
				SE2.%NotDel%
			) AS X
		GROUP BY 
			E1_VENCREA
		ORDER BY 
			E1_VENCREA
	EndSQL
	
	nSaldoDia := MV_PAR01
	
	While !(cAliasQry)->(Eof())
		cDtMov 		:= StoD((cAliasQry)->E1_VENCREA)
		nVlrRec		:= (cAliasQry)->E1_SALDO
		nVlrPag		:= (cAliasQry)->E2_SALDO
		nMoeda2		:= (cAliasQry)->MOEDA2 
		nSaldoAtu	:= nSaldoDia+nVlrRec-nVlrPag-nMoeda2
		nSaldoDia   := nSaldoAtu
		
		oSection2:PrintLine()
		
		nVlrTotRec += nVlrRec
		nVlrtotPag += nVlrPag+nMoeda2
		
		(cAliasQry)->(DbSkip())
	End
	(cAliasQry)->(dbCloseArea())
	oSection2:Finish()
	
	oReport:SkipLine()
	
	//Impressão de informações de atrasados
	If MV_PAR04 == 2 .or. MV_PAR05 == 2
		
		oSection3:Init()
		cAliasQry	  := GetNextAlias()
		
		BeginSQL Alias cAliasQry
			SELECT 
				SUM(E1_SALDO) E1_SALDO, 
				SUM(E2_SALDO) E2_SALDO,
				SUM(MOEDA2) MOEDA2
			FROM
				(
				SELECT
					E1_VENCREA, E1_SALDO, 0 E2_SALDO, 0 MOEDA2
				FROM
					%Table:SE1%
				WHERE
					E1_FILIAL BETWEEN %Exp:MV_PAR07% AND %Exp:MV_PAR08% AND
					E1_VENCREA < %Exp:DtoS(MV_PAR02)% AND
					%Exp:cNotCTA%
					E1_SALDO > 0 AND
					%NotDel% 
				UNION ALL
				SELECT
					E2_VENCREA, 0 E1_SALDO, E2_SALDO, 0 MOEDA2
				FROM
					%Table:SE2%
				WHERE
					E2_FILIAL BETWEEN %Exp:MV_PAR07% AND %Exp:MV_PAR08% AND
					E2_FORNECE NOT IN %Exp:cNotIn% AND
					E2_VENCREA < %Exp:DtoS(MV_PAR02)% AND
					E2_SALDO > 0 AND
					E2_MOEDA = 1 AND
					%NotDel%
				UNION ALL
				SELECT
					E2_VENCREA, 0 E1_SALDO, 0 E2_SALDO, E2_SALDO*M2_MOEDA2 MOEDA2
				FROM
					%Table:SE2% SE2 LEFT OUTER JOIN %Table:SM2% M2 ON  %Exp:DtoS(dDataBase)% = M2_DATA AND M2.%NotDel% 
				WHERE
					E2_FILIAL BETWEEN %Exp:MV_PAR07% AND %Exp:MV_PAR08% AND
					E2_FORNECE NOT IN %Exp:cNotIn% AND
					E2_VENCREA < %Exp:DtoS(MV_PAR02)% AND
					E2_SALDO > 0 AND
					E2_MOEDA <> 1 AND
					SE2.%NotDel%  
				) AS X
		EndSQL
	
		If !(cAliasQry)->(Eof())
			nVlrAtrRec:= (cAliasQry)->E1_SALDO
			nVlrAtrPag:= (cAliasQry)->E2_SALDO+(cAliasQry)->MOEDA2
		EndIf
		
		If MV_PAR04 == 1
			oSection3:Cell("ATRREC"):Disable()
		EndIf
		
		If MV_PAR05 == 1
			oSection3:Cell("ATRPAG"):Disable()
		EndIf
		oSection3:PrintLine() 

		(cAliasQry)->(dbCloseArea())
		oSection3:Finish()
		
		oReport:SkipLine()
	Endif
	
	//Impressão dos dados toralizadores
	oSection4:Init()
	nVlrFim := nSaldoIni+nVlrTotRec-nVlrtotPag
	oSection4:PrintLine() 
	oSection4:Finish()
	
	If MV_PAR10 == 2
		MsAguarde({|lEnd| comporValores( cNotCTA, cNotIn )},"Fluxo de caixa","Preparando a composição dos valores",.T.)
	Endif
Return

Static Function comporValores( cNotCTA, cNotIn )
	Local aProgress := {'|','/','-','|','\'}
	Local cCondVenc := "%%"
	Local cDir := ''
	Local cDirTmp := ''
	Local cFile := ''
	Local cTable := ''
	Local cWorkSheet := ''

	Local cQry1 := ''
	Local cQry2 := ''
	Local cQry3 := ''

	Local nProgress := 1
	Local nTentar := 0

	Local oExcelApp
	Local oFwMsEx
	
	//---------------------
	// --> Contas a receber
	//---------------------
	If MV_PAR04 == 1
		cCondVenc := "% E1_VENCREA BETWEEN " + ValToSql(MV_PAR02) + " AND " + ValToSql(MV_PAR03) + " AND %"
	Else
		cCondVenc := "% E1_VENCREA < " + ValtoSql(MV_PAR02) + " AND %"
	Endif
	
	cQry1 := GetNextAlias()
	
	BeginSQL Alias cQry1
		SELECT
			E1_VENCREA, E1_SALDO, E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, 
			E1_TIPO, E1_CLIENTE, E1_LOJA, E1_NOMCLI, E1_EMISSAO, E1_VENCTO, E1_VALOR
		FROM
			%Table:SE1%
		WHERE
			E1_FILIAL BETWEEN %Exp:MV_PAR07% AND %Exp:MV_PAR08% AND
			%Exp:cCondVenc%
			E1_SALDO > 0 AND
			%Exp:cNotCTA%
			%NotDel%
		ORDER BY 
			E1_VENCREA, E1_NOMCLI
	EndSQL
	
	//-------------------
	// --> Contas a pagar
	//-------------------
	If MV_PAR05 == 1
		cCondVenc := "% E2_VENCREA BETWEEN " + ValToSql(MV_PAR02) + " AND " + ValtoSql(MV_PAR03) + " AND %"
	Else
		cCondVenc := "% E2_VENCREA < " + ValtoSql(MV_PAR02) + " AND %"
	Endif
	
	cQry2 := GetNextAlias()
	
	BeginSQL Alias cQry2
			SELECT
				E2_VENCREA, E2_SALDO, E2_MOEDA, E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, 
				E2_LOJA, E2_NOMFOR, E2_EMISSAO, E2_VENCTO, E2_VALOR
			FROM
				%Table:SE2%
			WHERE
				E2_FILIAL BETWEEN %Exp:MV_PAR07% AND %Exp:MV_PAR08% AND
				E2_FORNECE NOT IN %Exp:cNotIn% AND
				%Exp:cCondVenc%
				E2_SALDO > 0 AND
				E2_MOEDA = 1 AND
				%NotDel% 
			ORDER BY
				E2_VENCREA, E2_NOMFOR
	EndSQL
	
	//----------------------------------
	// --> Contas a pagar em outra moeda
	//----------------------------------
	cQry3 := GetNextAlias()
	
	BeginSQL Alias cQry3
			SELECT
				E2_VENCREA, (E2_SALDO*M2_MOEDA2) AS SLD_MOEDA2, E2_MOEDA, E2_FILIAL, E2_PREFIXO, E2_NUM, 
				E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, E2_NOMFOR, E2_EMISSAO, E2_VENCTO, E2_VALOR, M2_MOEDA2
			FROM
				%Table:SE2% E2
			LEFT OUTER JOIN %Table:SM2% M2 
			             ON %Exp:DtoS(dDataBase)% = M2_DATA AND M2.%NotDel% 
			WHERE
				E2_FILIAL BETWEEN %Exp:MV_PAR07% AND %Exp:MV_PAR08% AND
				E2_FORNECE NOT IN %Exp:cNotIn% AND
				%Exp:cCondVenc%
				E2_SALDO > 0 AND
				E2_MOEDA <> 1 AND
				E2.%NotDel% 
			ORDER BY
				E2_VENCREA, E2_NOMFOR
	EndSQL
	
	/////////////////////////////////////////
	cFile := CriaTrab( NIL, .F. ) + '.xls'
	oFwMsEx := FWMsExcelEx():New()
	/////////////////////////////////////////
	
	cWorkSheet := 'CTA_RECEBER'
	cTable := 'COMPOSIÇÃO DOS VALORES DO CONTAS A RECEBER'
	
	oFwMsEx:AddWorkSheet( cWorkSheet )
	oFwMsEx:AddTable( cWorkSheet, cTable )
	
	oFwMsEx:AddColumn( cWorkSheet, cTable , 'Venc Real'    , 1, 1, .F. )
	oFwMsEx:AddColumn( cWorkSheet, cTable , 'Saldo'        , 3, 3, .T. )
	oFwMsEx:AddColumn( cWorkSheet, cTable , 'Filial'       , 1, 1, .F. )
	oFwMsEx:AddColumn( cWorkSheet, cTable , 'Prefixo'      , 1, 1, .F. )
	oFwMsEx:AddColumn( cWorkSheet, cTable , 'Título'       , 1, 1, .F. )
	oFwMsEx:AddColumn( cWorkSheet, cTable , 'Parcela'      , 1, 1, .F. )
	oFwMsEx:AddColumn( cWorkSheet, cTable , 'Tipo'         , 1, 1, .F. )
	oFwMsEx:AddColumn( cWorkSheet, cTable , 'Cliente'      , 1, 1, .F. )
	oFwMsEx:AddColumn( cWorkSheet, cTable , 'Loja'         , 1, 1, .F. )
	oFwMsEx:AddColumn( cWorkSheet, cTable , 'Nome Fantasia', 1, 1, .F. )
	oFwMsEx:AddColumn( cWorkSheet, cTable , 'Emissão'      , 1, 1, .F. )
	oFwMsEx:AddColumn( cWorkSheet, cTable , 'Vencto'       , 1, 1, .F. )
	oFwMsEx:AddColumn( cWorkSheet, cTable , 'Valor Título' , 3, 3, .T. )
	
	While (cQry1)->( .NOT. EOF() )
		MsProcTxt('Processando contas a receber ' + aProgress[nProgress])
		ProcessMessage()
		oFwMsEx:AddRow( cWorkSheet, cTable, { Dtoc(Stod((cQry1)->E1_VENCREA)),;
		(cQry1)->E1_SALDO,;
		(cQry1)->E1_FILIAL,;
		(cQry1)->E1_PREFIXO,;
		(cQry1)->E1_NUM,;
		(cQry1)->E1_PARCELA,;
		(cQry1)->E1_TIPO,;
		(cQry1)->E1_CLIENTE,;
		(cQry1)->E1_LOJA,;
		(cQry1)->E1_NOMCLI,;
		Dtoc(Stod((cQry1)->E1_EMISSAO)),;
		Dtoc(Stod((cQry1)->E1_VENCTO)),;
		(cQry1)->E1_VALOR	} )

		nProgress++
		If nProgress > 5
			nProgress := 1
		Endif
		(cQry1)->( dbSkip() )
	End

	cWorkSheet := 'CTA_PAGAR'
	cTable := 'COMPOSIÇÃO DOS VALORES DO CONTAS A PAGAR (EM R$)'
	
	oFwMsEx:AddWorkSheet( cWorkSheet )
	oFwMsEx:AddTable( cWorkSheet, cTable )
	
	oFwMsEx:AddColumn( cWorkSheet, cTable , 'Venc Real'    , 1, 1, .F. )
	oFwMsEx:AddColumn( cWorkSheet, cTable , 'Saldo'        , 3, 3, .T. )
	oFwMsEx:AddColumn( cWorkSheet, cTable , 'Filial'       , 1, 1, .F. )
	oFwMsEx:AddColumn( cWorkSheet, cTable , 'Prefixo'      , 1, 1, .F. )
	oFwMsEx:AddColumn( cWorkSheet, cTable , 'Título'       , 1, 1, .F. )
	oFwMsEx:AddColumn( cWorkSheet, cTable , 'Parcela'      , 1, 1, .F. )
	oFwMsEx:AddColumn( cWorkSheet, cTable , 'Tipo'         , 1, 1, .F. )
	oFwMsEx:AddColumn( cWorkSheet, cTable , 'Fornecedor'   , 1, 1, .F. )
	oFwMsEx:AddColumn( cWorkSheet, cTable , 'Loja'         , 1, 1, .F. )
	oFwMsEx:AddColumn( cWorkSheet, cTable , 'Nome Fantasia', 1, 1, .F. )
	oFwMsEx:AddColumn( cWorkSheet, cTable , 'Emissão'      , 1, 1, .F. )
	oFwMsEx:AddColumn( cWorkSheet, cTable , 'Vencto'       , 1, 1, .F. )
	oFwMsEx:AddColumn( cWorkSheet, cTable , 'Valor Título' , 3, 3, .T. )
	
	nProgress := 1

	While (cQry2)->( .NOT. EOF() )
		MsProcTxt('Processando contas a pagar ' + aProgress[nProgress])
		ProcessMessage()
		oFwMsEx:AddRow( cWorkSheet, cTable, { Dtoc(Stod((cQry2)->E2_VENCREA)),;
		(cQry2)->E2_SALDO,;
		(cQry2)->E2_FILIAL,;
		(cQry2)->E2_PREFIXO,;
		(cQry2)->E2_NUM,;
		(cQry2)->E2_PARCELA,;
		(cQry2)->E2_TIPO,;
		(cQry2)->E2_FORNECE,;
		(cQry2)->E2_LOJA,;
		(cQry2)->E2_NOMFOR,;
		Dtoc(Stod((cQry2)->E2_EMISSAO)),;
		Dtoc(Stod((cQry2)->E2_VENCTO)),;
		(cQry2)->E2_VALOR	} )

		nProgress++
		If nProgress > 5
			nProgress := 1
		Endif
		(cQry2)->( dbSkip() )
	End

	cWorkSheet := 'CTA_PG_MOEDA2'
	cTable := 'COMPOSIÇÃO DOS VALORES DO CONTAS A PAGAR (MOEDA 2)'
	
	oFwMsEx:AddWorkSheet( cWorkSheet )
	oFwMsEx:AddTable( cWorkSheet, cTable )
	
	oFwMsEx:AddColumn( cWorkSheet, cTable , 'Venc Real'    , 1, 1, .F. )
	oFwMsEx:AddColumn( cWorkSheet, cTable , 'Saldo'        , 3, 2, .T. )
	oFwMsEx:AddColumn( cWorkSheet, cTable , 'Moeda'        , 1, 1, .F. )
	oFwMsEx:AddColumn( cWorkSheet, cTable , 'Filial'       , 1, 1, .F. )
	oFwMsEx:AddColumn( cWorkSheet, cTable , 'Prefixo'      , 1, 1, .F. )
	oFwMsEx:AddColumn( cWorkSheet, cTable , 'Título'       , 1, 1, .F. )
	oFwMsEx:AddColumn( cWorkSheet, cTable , 'Parcela'      , 1, 1, .F. )
	oFwMsEx:AddColumn( cWorkSheet, cTable , 'Tipo'         , 1, 1, .F. )
	oFwMsEx:AddColumn( cWorkSheet, cTable , 'Fornecedor'   , 1, 1, .F. )
	oFwMsEx:AddColumn( cWorkSheet, cTable , 'Loja'         , 1, 1, .F. )
	oFwMsEx:AddColumn( cWorkSheet, cTable , 'Nome Fantasia', 1, 1, .F. )
	oFwMsEx:AddColumn( cWorkSheet, cTable , 'Emissão'      , 1, 1, .F. )
	oFwMsEx:AddColumn( cWorkSheet, cTable , 'Vencto'       , 1, 1, .F. )
	oFwMsEx:AddColumn( cWorkSheet, cTable , 'Valor Título' , 3, 2, .T. )
	oFwMsEx:AddColumn( cWorkSheet, cTable , 'Câmbio'       , 3, 3, .T. )
	
	nProgress := 1
	
	While (cQry3)->( .NOT. EOF() )
		MsProcTxt('Processando contas a pagar moeda2 ' + aProgress[nProgress])
		ProcessMessage()
		oFwMsEx:AddRow( cWorkSheet, cTable, { Dtoc(Stod((cQry3)->E2_VENCREA)),;
		(cQry3)->SLD_MOEDA2,;
		(cQry3)->E2_MOEDA,;
		(cQry3)->E2_FILIAL,;
		(cQry3)->E2_PREFIXO,;
		(cQry3)->E2_NUM,;
		(cQry3)->E2_PARCELA,;
		(cQry3)->E2_TIPO,;
		(cQry3)->E2_FORNECE,;
		(cQry3)->E2_LOJA,;
		(cQry3)->E2_NOMFOR,;
		Dtoc(Stod((cQry3)->E2_EMISSAO)),;
		Dtoc(Stod((cQry3)->E2_VENCTO)),;
		(cQry3)->E2_VALOR,;
		(cQry3)->M2_MOEDA2	} )

		nProgress++
		If nProgress > 5
			nProgress := 1
		Endif
		(cQry3)->( dbSkip() )
	End
	
	(cQry1)->( dbCloseArea() )
	(cQry2)->( dbCloseArea() )
	(cQry3)->( dbCloseArea() )
	
	oFwMsEx:Activate()
	
	cDirTmp := GetTempPath()
	cDir := GetSrvProfString('Startpath','')
	LjMsgRun( 'Gerando o arquivo Ms-Excel', 'Aguarde', {|| oFwMsEx:GetXMLFile( cFile ), Sleep( 1000 ) } )
	
	If __CopyFile( cFile, cDirTmp + cFile )
		If ApOleClient( 'MsExcel' )
			While .T.
				nTentar++
				If nTentar <= 3
					oExcelApp := MsExcel():New()
					oExcelApp:WorkBooks:Open( cDirTmp + cFile )
					oExcelApp:SetVisible(.T.)
					oExcelApp:Destroy()
					If MsgYesNo( 'O Ms-Excel conseguiu abrir a planilha de dados gerado pelo ERP Protheus?'+CRLF+CRLF+;
					'[ Tentativa '+LTrim(Str(nTentar))+'/3 ]', 'Fluxo de Caixa' )
						Exit
					Endif
				Else
					MsgInfo( 'Se o Ms-Excel não conseguiu abrir a planilha de dados gerada pelo ERP Protheus, '+;
					'solicite a área de TI para buscar o arquivo no seguinte endereço: ' + cDirTmp + cFile, 'Fluxo de Caixa' )
					Exit
				Endif
			End
		Else
			MsgAlert( 'MsExcel não instalado. Para abrir o arquivo ('+cFile+'), localize-o na pasta %temp%.', 'Fluxo de Caixa' )
		Endif
	Else
		MsgInfo( 'Arquivo não copiado para temporário do usuário, por favor, tente gerar novamente.', 'Fluxo de Caixa' )
	Endif
Return

/*/{Protheus.doc} CriaSX1
//TODO Cria Perguntas do Relatório
@author TOTVS
@since 14/06/2019
@version 1.0
@return ${return}, ${return_description}
@param cPerg, characters, descricao
@type function
/*/
//---> REMOVIDO compatibilização para versão 12.1.25.
/*Static Function CriaSX1(cPerg)

	PutSx1(cPerg,"01","Saldo Inicial    ","                 ","                 ","mv_ch01","N",16,02,00,"G","",""   ,"","","MV_PAR01","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"02","Vencto De        ","Emissão De       ","Emissão De       ","mv_ch02","D",08,00,00,"G","",""   ,"","","mv_par02","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"03","Vencto Ate       ","Emissão Ate      ","Emissão Ate      ","mv_ch03","D",08,00,00,"G","",""   ,"","","mv_par03","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"04","Atrasados Receb. ","                 ","                 ","mv_ch04","N",01,00,02,"C","",""   ,"","","mv_par04","Nao","Nao","Nao","","Sim","Sim","Sim","","","","","","","","","","",)
	PutSx1(cPerg,"05","Atrasados Pagar  ","                 ","                 ","mv_ch05","N",01,00,02,"C","",""   ,"","","mv_par05","Nao","Nao","Nao","","Sim","Sim","Sim","","","","","","","","","","",)
	PutSx1(cPerg,"06","Desconsid. Fornec","                 ","                 ","mv_ch06","C",50,00,02,"G","",""   ,"","","mv_par06","","","","","","","","","","","","","","","","","",)
	PutSx1(cPerg,"07","Filial De        ","                 ","                 ","mv_ch07","C",04,00,02,"G","","SM0","","","mv_par07","","","","","","","","","","","","","","","","","",)
	PutSx1(cPerg,"08","Filial Até       ","                 ","                 ","mv_ch08","C",04,00,02,"G","","SM0","","","mv_par08","","","","","","","","","","","","","","","","","",)
	PutSx1(cPerg,"09","Descon. Ctas Rec.","                 ","                 ","mv_ch09","C",50,00,02,"G","","REPR01"   ,"","","mv_par09","","","","","","","","","","","","","","","","","",)
	
Return*/

/*/{Protheus.doc} PutSx1
//TODO Insere dados na tabela SX1
@author TOTVS
@since 14/06/2019
@version 1.0
@return ${return}, ${return_description}
@param cGrupo, characters, descricao
@param cOrdem, characters, descricao
@param cPergunt, characters, descricao
@param cPerSpa, characters, descricao
@param cPerEng, characters, descricao
@param cVar, characters, descricao
@param cTipo, characters, descricao
@param nTamanho, numeric, descricao
@param nDecimal, numeric, descricao
@param nPresel, numeric, descricao
@param cGSC, characters, descricao
@param cValid, characters, descricao
@param cF3, characters, descricao
@param cGrpSxg, characters, descricao
@param cPyme, characters, descricao
@param cVar01, characters, descricao
@param cDef01, characters, descricao
@param cDefSpa1, characters, descricao
@param cDefEng1, characters, descricao
@param cCnt01, characters, descricao
@param cDef02, characters, descricao
@param cDefSpa2, characters, descricao
@param cDefEng2, characters, descricao
@param cDef03, characters, descricao
@param cDefSpa3, characters, descricao
@param cDefEng3, characters, descricao
@param cDef04, characters, descricao
@param cDefSpa4, characters, descricao
@param cDefEng4, characters, descricao
@param cDef05, characters, descricao
@param cDefSpa5, characters, descricao
@param cDefEng5, characters, descricao
@param aHelpPor, array, descricao
@param aHelpEng, array, descricao
@param aHelpSpa, array, descricao
@param cHelp, characters, descricao
@type function
/*/
//---> REMOVIDO compatibilização para versão 12.1.25.
/*Static Function PutSx1(cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,;
	cTipo ,nTamanho,nDecimal,nPresel,cGSC,cValid,;
	cF3, cGrpSxg,cPyme,;
	cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,;
	cDef02,cDefSpa2,cDefEng2,;
	cDef03,cDefSpa3,cDefEng3,;
	cDef04,cDefSpa4,cDefEng4,;
	cDef05,cDefSpa5,cDefEng5,;
	aHelpPor,aHelpEng,aHelpSpa,cHelp)

LOCAL aArea := GetArea()
Local cKey
Local lPort := .f.
Local lSpa  := .f.
Local lIngl := .f.



	cKey  := "P." + AllTrim( cGrupo ) + AllTrim( cOrdem ) + "."

	cPyme    := Iif( cPyme 		== Nil, " ", cPyme		)
	cF3      := Iif( cF3 		== NIl, " ", cF3		)
	cGrpSxg  := Iif( cGrpSxg	== Nil, " ", cGrpSxg	)
	cCnt01   := Iif( cCnt01		== Nil, "" , cCnt01 	)
	cHelp	 := Iif( cHelp		== Nil, "" , cHelp		)

	dbSelectArea( "SX1" )
	dbSetOrder( 1 )

	// Ajusta o tamanho do grupo. Ajuste emergencial para validação dos fontes.
	// RFC - 15/03/2007
	cGrupo := PadR( cGrupo , Len( SX1->X1_GRUPO ) , " " )

	If !( DbSeek( cGrupo + cOrdem ))

	    cPergunt:= If(! "?" $ cPergunt .And. ! Empty(cPergunt),Alltrim(cPergunt)+" ?",cPergunt)
		cPerSpa	:= If(! "?" $ cPerSpa  .And. ! Empty(cPerSpa) ,Alltrim(cPerSpa) +" ?",cPerSpa)
		cPerEng	:= If(! "?" $ cPerEng  .And. ! Empty(cPerEng) ,Alltrim(cPerEng) +" ?",cPerEng)

		Reclock( "SX1" , .T. )

		Replace X1_GRUPO   With cGrupo
		Replace X1_ORDEM   With cOrdem
		Replace X1_PERGUNT With cPergunt
		Replace X1_PERSPA  With cPerSpa
		Replace X1_PERENG  With cPerEng
		Replace X1_VARIAVL With cVar
		Replace X1_TIPO    With cTipo
		Replace X1_TAMANHO With nTamanho
		Replace X1_DECIMAL With nDecimal
		Replace X1_PRESEL  With nPresel
		Replace X1_GSC     With cGSC
		Replace X1_VALID   With cValid

		Replace X1_VAR01   With cVar01

		Replace X1_F3      With cF3
		Replace X1_GRPSXG  With cGrpSxg

		If Fieldpos("X1_PYME") > 0
			If cPyme != Nil
				Replace X1_PYME With cPyme
			Endif
		Endif

		Replace X1_CNT01   With cCnt01
		If cGSC == "C"			// Mult Escolha
			Replace X1_DEF01   With cDef01
			Replace X1_DEFSPA1 With cDefSpa1
			Replace X1_DEFENG1 With cDefEng1

			Replace X1_DEF02   With cDef02
			Replace X1_DEFSPA2 With cDefSpa2
			Replace X1_DEFENG2 With cDefEng2

			Replace X1_DEF03   With cDef03
			Replace X1_DEFSPA3 With cDefSpa3
			Replace X1_DEFENG3 With cDefEng3

			Replace X1_DEF04   With cDef04
			Replace X1_DEFSPA4 With cDefSpa4
			Replace X1_DEFENG4 With cDefEng4

			Replace X1_DEF05   With cDef05
			Replace X1_DEFSPA5 With cDefSpa5
			Replace X1_DEFENG5 With cDefEng5
		Endif

		Replace X1_HELP  With cHelp

		PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)

		MsUnlock()
	Else

	   lPort := ! "?" $ X1_PERGUNT .And. ! Empty(SX1->X1_PERGUNT)
	   lSpa  := ! "?" $ X1_PERSPA  .And. ! Empty(SX1->X1_PERSPA)
	   lIngl := ! "?" $ X1_PERENG  .And. ! Empty(SX1->X1_PERENG)

	   If lPort .Or. lSpa .Or. lIngl
			RecLock("SX1",.F.)
			If lPort
	         SX1->X1_PERGUNT:= Alltrim(SX1->X1_PERGUNT)+" ?"
			EndIf
			If lSpa
				SX1->X1_PERSPA := Alltrim(SX1->X1_PERSPA) +" ?"
			EndIf
			If lIngl
				SX1->X1_PERENG := Alltrim(SX1->X1_PERENG) +" ?"
			EndIf
			SX1->(MsUnLock())
		EndIf
	Endif

	RestArea( aArea )

Return*/

/*/{Protheus.doc} CriaSXB
//Rotina de parâmetros.
@author Totvs
@since 22/05/2018
@version 20180522
@type function
/*/
//---> REMOVIDO compatibilização para versão 12.1.25.
/*Static Function CriaSXB()
	Local aPar := {}
	Local aRet := {}
	Local aSXB := {}
	
	Local cXB_ALIAS := ''
	
	cXB_ALIAS := 'REPR01'
	
	AAdd( aSXB, { cXB_ALIAS, "1", "01", "RE", "Desconsiderar Cta", "Desconsiderar Cta", "Desconsiderar Cta", "SX5"        , "" } )
	AAdd( aSXB, { cXB_ALIAS, "2", "01", "01", "Desconsiderar Cta", "Desconsiderar Cta", "Desconsiderar Cta", "U_ugetCTA()", "" } )
	AAdd( aSXB, { cXB_ALIAS, "5", "01", ""  , ""                  , ""                  , ""               , "U_uretCTA()", "" } )
	
	putSXB( cXB_ALIAS, aSXB )

Return*/

/*/{Protheus.doc} putSXB
//Rotina para gerar a configuração da consulta padrão.
@author Totvs
@since 22/05/2018
@version 20180522
@type function
/*/
//---> REMOVIDO compatibilização para versão 12.1.25.
/*Static Function putSXB( cXB_ALIAS, aSXB )
	Local nI := 0
	Local nJ := 0
	Local aCpoSXB := {}
	
	SXB->( dbSetOrder( 1 ) )
	If ! SXB->( dbSeek( cXB_ALIAS ) )
		nTamSXB := Len( SXB->XB_ALIAS )
		aCpoSXB := { "XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI","XB_DESCSPA","XB_DESCENG","XB_CONTEM","XB_WCONTEM" }
		
		SXB->( dbSetOrder( 1 ) )
		For nI := 1 To Len( aSXB )
			If ! SXB->( dbSeek( PadR( aSXB[ nI, 1 ], nTamSXB ) + aSXB[ nI,2 ] + aSXB[ nI, 3 ] + aSXB[ nI, 4 ] ) )
				SXB->( RecLock( 'SXB', .T. )) 
				For nJ := 1 To Len( aCpoSXB )
					SXB->( FieldPut( FieldPos( aCpoSXB[ nJ ] ), aSXB[ nI, nJ ] ) )
				Next nJ
				SXB->( MsUnLock() )
			Endif
		Next nI
	Endif
Return*/

/*/{Protheus.doc} getCFOP
//Rotina para buscar os CFOP.
@author Totvs
@since 22/05/2018
@version 20180522
@type function
/*/
User Function ugetCTA()
	Local oCancel
	Local oConfirm
	Local oDlg
	Local oLbx
	Local oMrk 
	Local oNoMrk
	Local oPnlAll 
	Local oPnlBot
	
	Local nI := 0
	Local nOpc := 0
	
	Local lMark := .F.
	
	Local cTitulo := 'Exceto CTA'
	Local cNomeCpo := ''
	
	Local aDados := {}
	Local aButton := {}
	
	c10Cont := ''
	cNomeCpo := ReadVar()
	c10Cont  := RTrim( &( ReadVar() ) )
	
	SA6->( dbSetOrder( 1 ) )
	While SA6->( .NOT. EOF() )
		lMark := SA6->(A6_COD+A6_AGENCIA+A6_NUMCON) $ c10Cont
				
		AAdd( aDados, { lMark, SA6->A6_COD, SA6->A6_AGENCIA, SA6->A6_NUMCON , RTrim( SA6->A6_NOME ) } )
		
		SA6->(dbSkip())
	End
	
	If Len( aDados ) > 0
		lMark := .T.
		oMrk := LoadBitmap( GetResources(), 'LBOK' )
		oNoMrk := LoadBitmap( GetResources(), 'LBNO' )
		
		DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 308,715 PIXEL
			oPnlAll := TPanel():New(0,0,'',oDlg,NIL,.F.,,,,0,14,.F.,.T.)
			oPnlAll:Align := CONTROL_ALIGN_ALLCLIENT
			
			oPnlBot := TPanel():New(0,0,'',oDlg,NIL,.F.,,,,0,14,.F.,.T.)
			oPnlBot:Align := CONTROL_ALIGN_BOTTOM
			
		   oLbx := TwBrowse():New(0,0,1000,1000,,{'X','Banco','Agencia','Conta','Descrição'},,oPnlAll,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
		   oLbx:Align := CONTROL_ALIGN_ALLCLIENT
		   oLbx:SetArray( aDados )
			oLbx:bLine := {|| {Iif(aDados[oLbx:nAt,1],oMrk,oNoMrk),aDados[oLbx:nAt,2],aDados[oLbx:nAt,3], aDados[oLbx:nAt,4], aDados[oLbx:nAt,5] }}
			oLbx:bLDblClick := {||  aDados[ oLbx:nAt, 1 ] := ! aDados[ oLbx:nAt, 1 ] }
			
			@ 1,1  	BUTTON oConfirm ;
						PROMPT 'Confirmar' ;
						SIZE 40,11 ;
						PIXEL OF oPnlBot ;
						ACTION Iif(AScan(aDados,{|e| e[1]==.T.})>0,(nOpc:=1,oDlg:End()),(MsgAlert('Necessário informar o CFOP.',cTitulo),NIL))
						
			@ 1,44 	BUTTON oCancel ;
						PROMPT 'Sair' ;
						SIZE 40,11 ;
						PIXEL OF oPnlBot ;
						ACTION (oDlg:End())
		ACTIVATE MSDIALOG oDlg CENTER
		If nOpc == 1
			c10Cont := ''
			For nI := 1 To Len( aDados )
				If aDados[ nI, 1 ]
					c10Cont +=  aDados[ nI, 2 ]+aDados[ nI, 3 ]+aDados[ nI, 4 ]  + '/'
				Endif
			Next nI
			c10Cont := Substr( c10Cont, 1, Len( c10Cont ) -1 )
			&( cNomeCpo ) := c10Cont
		Endif
	Else
		MsgAlert( 'Dados não localizados', cTitulo )
	Endif
Return( .T. )

/*/{Protheus.doc} uretCTA
//Rotina para entregar o que foi selecionado na consulta SXB.
@author Totvs
@since 22/05/2018
@version 20180522
@type function
/*/
User Function uretCTA()
Return( c10Cont )