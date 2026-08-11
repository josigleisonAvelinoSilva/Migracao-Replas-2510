#include 'protheus.ch'
#include 'parmtype.ch'
#include "topconn.ch"
#include "Ap5Mail.ch"
#include 'tbiconn.ch'
#Include "FWPrintSetup.ch"
#Include "TbiConn.ch"
#Include "RptDef.ch"

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ?RPFAT001 ?Autor ?Joao Gonçalves de Oliveira ?Data ?10/01/19      ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ?Relatório de Faturamento x Compras                               ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ?U_RPFAT001()                     		   					       ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parâmetros?Nenhum														   ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±³ Retorno   ?Nenhum														   ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

/*
User Function RPFAT001()

	Local aParamBox := {}
	Local bConfGrav := {|| .T.}
	Local aButtPara := {}
	Local lCentPara := .T.
	Local cTituRoti := "[ Faturamento x Compras ]"
	Local nPosiHori
	Local nPosiVert
	Local cLoadPerg := "RPFAT001"
	Local lSalvPara := .T.
	Local lUserSave := .T.
	Local nContItem := 0
	Local dEmisInic := CTOD("  /  /  ")
	Local dEmisFina := CTOD("  /  /  ")  
	Local cGrupInic := "" 
	Local cGrupFina := ""  
	Local cListFami := "" 
	Local cEstaRela := "" 
	Local nTipoRela := 1
	Local cDireGrav := "" 
	Local cFiliInic := "" 
	Local cFiliFina := "" 
	Local nTipoAgru := 1
	Local nGeraDeta := 1
	Local nGeraDcto := 1

	Static aPergReto := {}

	aAdd(aParamBox,{1,"Emissao De"    ,CtoD(Space(8)),""							,"",""		 ,"",60,.T.} )
	aAdd(aParamBox,{1,"Emissao Ate"   ,CtoD(Space(8)),""							,"",""		 ,"",60,.T.} )
	aAdd(aParamBox,{1,"Grupo De"      ,Space(4)      ,""	                        ,"","XGRUPO" ,"",60,.F.} )
	aAdd(aParamBox,{1,"Grupo Ate"     ,Space(4)      ,""	                        ,"","XGRUPO" ,"",60,.F.} )
	aAdd(aParamBox,{1,"Famílias"      ,Space(200)	 ,""							,"","GRUPO2" ,"",60,.F.})
	aAdd(aParamBox,{1,"Estado"        ,Space(200)    ,""	                        ,"","XUF001" ,"",60,.F.} )
	aAdd(aParamBox,{2,"Custo Médio"   ,1             ,{'Com Imposto','Sem Imposto'},50,"AllwaysTrue()",.F.} )
	aAdd(aParamBox,{6,"Diretório de gravação",Padr("",150),"","","",90,.T.,,"",GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE+GETF_RETDIRECTORY})
	aAdd(aParamBox,{1,"Filial De"     ,Space(4)      ,""	                        ,"","SM0"    ,"",60,.T.} )
	aAdd(aParamBox,{1,"Filial Ate"    ,Space(4)      ,""	                        ,"","SM0"    ,"",60,.T.} )
	aAdd(aParamBox,{2,"Tipo Agrupamento" ,1             ,{'Estado+Grupo','Estado+Família','Familia+Estado'},50,"AllwaysTrue()",.F.} )
	aAdd(aParamBox,{2,"Gera Detalhamento",2             ,{'Sim','Não'},50,"AllwaysTrue()",.F.} )
	aAdd(aParamBox,{2,"Imprime Documento",2             ,{'Sim','Não'},50,"AllwaysTrue()",.F.} )
	
	If ParamBox(aParamBox, cTituRoti, @aPergReto, bConfGrav, aButtPara, lCentPara, nPosiHori,nPosiVert,, cLoadPerg, lSalvPara, lUserSave)
		For nContItem := 1 to Len(aParamBox)
			If aParamBox[nContItem,1] == 2 .And. ValType(&("mv_par"+StrZero(nContItem,2))) <> "N"
				&("mv_par"+StrZero(nContItem,2)) := aScan(aParamBox[nContItem,4],&("mv_par"+StrZero(nContItem,2)))
			EndIf
		Next

		dEmisInic := mv_par01 
		dEmisFina := mv_par02 
		cGrupInic := mv_par03
		cGrupFina := mv_par04 
		cListFami := mv_par05
		cEstaRela := mv_par06
		nTipoRela := mv_par07
		cDireGrav := mv_par08
		cFiliInic := mv_par09
		cFiliFina := mv_par10
		nTipoAgru := mv_par11
		nGeraDeta := mv_par12
		nGeraDcto := mv_par13

		RPFAT01E() // Exclui views anteriormente geradas

		Processa( {|| RPFAT01A(dEmisInic,dEmisFina,cGrupInic,cGrupFina,cListFami,cEstaRela,nTipoRela,cDireGrav,cFiliInic,cFiliFina,nTipoAgru,nGeraDeta,nGeraDcto) }) // ,"Gerando Dados do Relatório")
		
		RPFAT01E() // Exclui views anteriormente geradas
	EndIf
Return
*/

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ?RPFAT01A ?Autor ?Joao Goncalves de Oliveira ?Data ?10/01/19      ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ?Gera Planilha do Relatório com Base nos Dados                    ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ?RPFAT01A(ExpD1,ExpD2,ExpC3,ExpC4,ExpC5,ExpC6,,ExpC7,ExpC8)	   ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros?ExpD1 - Data de emissão inicial 								   ³±?
±±?         ?ExpD2 - Data de emissão final 	 							       ³±?
±±?         ?ExpC3 - Grupo inicial 									           ³±?
±±?         ?ExpC4 - Grupo final  									           ³±?
±±?         ?ExpC5 - Lista com famílias 								       ³±?
±±?         ?ExpC6 - Estado 		 									       ³±?
±±?         ?ExpN7 - Tipo de relatório 								           ³±?
±±?         ?ExpC8 - Diretório de gravaçào 							           ³±?
±±?         ?ExpC9 - Filial inicial 									       ³±?
±±?         ?ExpCA - Filial final 									           ³±?
±±?         ?ExpCA - Tipo de agrupamento 								       ³±?
±±?         ?ExpCB - Gera detalhamento 								           ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±³ Retorno   ?Nenhum                                                           ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RPFAT01A(dEmisInic,dEmisFina,cGrupInic,cGrupFina,cListFami,cEstaRela,nTipoRela,cDireGrav,cFiliInic,cFiliFina,nTipoAgru,nGeraDeta,nGeraDcto)

	Local cTituRela := ""
	Local cTituPlan := ""
	Local cQuryRela := ""
	Local cViewProd := "RPFAT01A" + GetNextAlias()
	Local cViewPrd1 := "RPFAT01A" + GetNextAlias()
	Local cViewPrd2 := "RPFAT01A" + GetNextAlias()
	Local cViewPrd3 := "RPFAT01A" + GetNextAlias()
	Local cViewPrd4 := "RPFAT01A" + GetNextAlias()
	Local cViewPrd5 := "RPFAT01A" + GetNextAlias()
	Local cViewPrd6 := "RPFAT01A" + GetNextAlias()
	Local cViewPrd7 := "RPFAT01A" + GetNextAlias()
	Local cViewGera := "RPFAT01A" + GetNextAlias()
	Local aListGera := {}

	// Busca produções
	cQuryRela := " CREATE VIEW " + cViewProd + " AS ("
	cQuryRela += " SELECT B1_COD PRODUTO, B1_DESC DESC_PRODU"
	cQuryRela += " , B1_GRUPO GRUPO, BM_DESC DESC_GRUPO"
	cQuryRela += " , BM_TIPGRU FAMILIA, X5_DESCRI DESC_FAMIL"
	cQuryRela += " , D3_QUANT QUANTIDADE"
	cQuryRela += " , D3_TM TIPO_OPERA" 
	cQuryRela += " , D3_CUSTO1 CUSTO"
	cQuryRela += " , 0 TOTAL, 0 PIS, 0 COFINS"
	cQuryRela += " , 0 IPI, 0 ICMS"
	cQuryRela += " , 'PRODUCAO' TIPO_MOVTO"
	cQuryRela += " , D3_OP DOCUMENTO"
	cQuryRela += " FROM " + RetSqlName("SD3") + " SD3A"
	cQuryRela += " INNER JOIN " + RetSqlName("SB1")
	cQuryRela += " ON B1_FILIAL = '" + xfilial("SB1") + "'"
	cQuryRela += " AND B1_COD = SD3A.D3_COD"
	If ! Empty(cGrupInic) .Or. ! Empty(cGrupFina)
		cQuryRela += " AND B1_GRUPO >= '" + cGrupInic + "'"
		cQuryRela += " AND B1_GRUPO <= '" + cGrupFina + "'"
	EndIf
	cQuryRela += " AND " + RetSqlName("SB1") + ".D_E_L_E_T_ = ' '"
	cQuryRela += " INNER JOIN " + RetSqlName("SBM")
	cQuryRela += " ON BM_FILIAL = '" + xfilial("SBM") + "'"
	cQuryRela += " AND BM_GRUPO = B1_GRUPO"
	If !Empty(cListFami)
		cQuryRela += " 	AND BM_TIPGRU IN ('" + StrTran(cListFami,";","','") + "')"																		
	EndIf
	cQuryRela += " AND " + RetSqlName("SBM") + ".D_E_L_E_T_ = ' '"
	cQuryRela += " INNER JOIN " + RetSqlName("SX5") + " SX5"
	cQuryRela += " ON X5_FILIAL = '" + xFilial("SX5") + "' AND X5_TABELA = 'V0'"
	cQuryRela += " AND X5_CHAVE = BM_TIPGRU"
	cQuryRela += " WHERE SD3A.R_E_C_N_O_ "
	cQuryRela += " IN ( "
	cQuryRela += " 	SELECT SD3B.R_E_C_N_O_"
	cQuryRela += " 	FROM " + RetSqlName("SD3") + " SD3B"
	cQuryRela += " 	INNER JOIN " + RetSqlName("SF5")
	cQuryRela += " 	ON	F5_FILIAL = '"+ xfilial("SF5") + "'"
	cQuryRela += " 	AND F5_CODIGO = SD3B.D3_TM"
	cQuryRela += " 	AND F5_TIPO = 'P'"
	cQuryRela += " 	WHERE D3_FILIAL >= '" + cFiliInic + "'"
	cQuryRela += "	AND D3_FILIAL <= '" + cFiliFina + "'"
	cQuryRela += " 	AND D3_EMISSAO < '" + DTOS(dEmisFina) + "'"
	cQuryRela += "	AND D3_COD = B1_COD"
	cQuryRela += "	AND D3_OP = ("
	cQuryRela += "		SELECT MAX(SD3C.D3_OP)"
	cQuryRela += "		FROM " + RetSqlName("SD3") + " SD3C"
	cQuryRela += " 		INNER JOIN " + RetSqlName("SF5")
	cQuryRela += " 		ON	F5_FILIAL = '"+ xfilial("SF5") + "'"
	cQuryRela += " 		AND F5_CODIGO = SD3C.D3_TM"
	cQuryRela += " 		AND F5_TIPO = 'P'"
	cQuryRela += "		WHERE SD3C.D3_FILIAL = SD3B.D3_FILIAL"
	cQuryRela += "  	AND SD3C.D3_COD = B1_COD"
	cQuryRela += " 		AND SD3C.D3_EMISSAO <= '" + DTOS(dEmisFina) + "')"
	cQuryRela += " 	AND SD3B.D_E_L_E_T_ = ' ')"
	cQuryRela += ")"

	MemoWrite("cViewProd.SQL",cQuryRela)

	TcSqlExec( cQuryRela)
	
	// Soma quantidade e custo dos insumos nas ordens de produção 
	cQuryRela := " CREATE VIEW " + cViewPrd1 + " AS ("
	cQuryRela += " SELECT D3_COD PRODUTO, B1_DESC DESC_PRODU"
	cQuryRela += " , B1_GRUPO GRUPO, BM_DESC DESC_GRUPO"
	cQuryRela += " , BM_TIPGRU FAMILIA, X5_DESCRI DESC_FAMIL"
	cQuryRela += " , D3_QUANT QUANTIDADE"
	cQuryRela += " , D3_TM TIPO_OPERA, D3_CUSTO1 CUSTO, 0 TOTAL"
	cQuryRela += " , 0 PIS, 0 COFINS"
	cQuryRela += " , 0 IPI, 0 ICMS"
	cQuryRela += " , 'REQUISICOES_PRODUCAO' TIPO_MOVTO"
	cQuryRela += " , D3_OP DOCUMENTO"
	cQuryRela += " , '  ' ESTADO"
	cQuryRela += " FROM " + RetSqlName("SD3")	
	cQuryRela += " INNER JOIN " + RetSqlName("SB1")
	cQuryRela += " ON B1_FILIAL = '" + xfilial("SB1") + "'"
	cQuryRela += " AND B1_COD = D3_COD"
	cQuryRela += " AND " + RetSqlName("SB1") + ".D_E_L_E_T_ = ' '"
	cQuryRela += " INNER JOIN " + RetSqlName("SBM")
	cQuryRela += " ON BM_FILIAL = '" + xfilial("SBM") + "'"
	cQuryRela += " AND BM_GRUPO = B1_GRUPO"
	cQuryRela += " AND " + RetSqlName("SBM") + ".D_E_L_E_T_ = ' '"
	cQuryRela += " INNER JOIN " + RetSqlName("SX5") + " SX5"
	cQuryRela += " ON X5_FILIAL = '" + xFilial("SX5") + "' AND X5_TABELA = 'V0'"
	cQuryRela += " AND X5_CHAVE = BM_TIPGRU"
	
	// MV_PAR07  ==> Custo médio? 1=Com impostos; 2=Sem impostos.
	// B1_XGRUPO ==> 0=Outros; 1=Filme; 2=Resina nacional; 3=Resina importada.
	// Nestes casos o custo do produto MP deve ser o da última NF de compra.
	// Criei a [Static Function lastCost] para saber o valor correto do produto, 
	// logo implementei aqui como left outer join.
	/*
	If MV_PAR07 == 2
		cQuryRela += "	LEFT OUTER JOIN " + RetSqlName("SD1") + " SD1_B "
		cQuryRela += "		  ON  SD1_B.R_E_C_N_O_ = ( "
		cQuryRela += "		  SELECT Max(SD1_A.R_E_C_N_O_) AS D1_RECNO "
		cQuryRela += "		  FROM   " + RetSqlName("SD1") + " SD1_A "
		cQuryRela += "		  WHERE  SD1_A.D1_FILIAL = D3_FILIAL "
		cQuryRela += "					AND SD1_A.D1_TES = '040' "
		cQuryRela += "					AND SD1_A.D_E_L_E_T_ = ' ' "
		cQuryRela += "					AND SD1_A.D1_COD = ( "
		cQuryRela += "					SELECT SD3_B.D3_COD "
		cQuryRela += "					FROM   " + RetSqlName("SD3") + " SD3_B "
		cQuryRela += "							 INNER JOIN " + RetSqlName("SB1") + " SB1 "
		cQuryRela += "										ON B1_FILIAL = ' ' "
		cQuryRela += "											AND B1_COD = SD3_B.D3_COD "
		cQuryRela += "											AND B1_TIPO = 'MP' "
		cQuryRela += "											AND B1_XGRUPO = '1' "
		cQuryRela += "											AND SB1.D_E_L_E_T_ = ' ' "
		cQuryRela += "					WHERE SD3_B.D3_FILIAL = D3_FILIAL "
		cQuryRela += "							AND SD3_B.D3_OP = ( "
		cQuryRela += "							SELECT Max(SD3_A.D3_OP) D3_OP "
		cQuryRela += "							FROM   " + RetSqlName("SD3") + " SD3_A "
		cQuryRela += "							WHERE  SD3_A.D3_FILIAL = D3_FILIAL "
		cQuryRela += "							AND SD3_A.D_E_L_E_T_ = ' '))) "
	Endif
	*/
	cQuryRela += " WHERE D3_FILIAL >= '" + cFiliInic + "'"
	cQuryRela += " AND D3_FILIAL <= '" + cFiliFina + "'"
	cQuryRela += " AND D3_CF IN ('RE1','RE0')"
	cQuryRela += " AND D3_OP"
	cQuryRela += " IN ("
	cQuryRela += "	SELECT DOCUMENTO"
	cQuryRela += "		FROM " + cViewProd + ")"
	cQuryRela += " AND " + RetSqlName("SD3") + ".D_E_L_E_T_ = ' ' "
	cQuryRela += ")"
	
	MemoWrite("cViewPrd1.SQL",cQuryRela)
	TcSqlExec( cQuryRela)

	// Busca compras dos produtos utilizados na produção
	cQuryRela := " CREATE VIEW " + cViewPrd2 + " AS ("
	cQuryRela += " SELECT B1_COD PRODUTO, B1_DESC DESC_PRODU"
	cQuryRela += " , B1_GRUPO GRUPO, BM_DESC DESC_GRUPO"
	cQuryRela += " , BM_TIPGRU FAMILIA, X5_DESCRI DESC_FAMIL"
	cQuryRela += " , D1_QUANT QUANTIDADE"
	cQuryRela += " , D1_TES TIPO_OPERA, D1_CUSTO CUSTO, D1_TOTAL TOTAL"
	cQuryRela += " , D1_VALIMP5 PIS, D1_VALIMP6 COFINS"
	cQuryRela += " , D1_VALIPI IPI, D1_VALICM ICMS"
	cQuryRela += " , 'COMPRA_PRODUCAO' TIPO_MOVTO"
	cQuryRela += " , D1_DOC DOCUMENTO"
	cQuryRela += " , '  ' ESTADO"
	cQuryRela += " FROM " + RetSqlName("SD1") + " SD1A"
	cQuryRela += " INNER JOIN " + RetSqlName("SB1")
	cQuryRela += " ON B1_FILIAL = '" + xfilial("SB1") + "'"
	cQuryRela += " AND B1_COD IN ( "
	cQuryRela += " SELECT PRODUTO FROM " + cViewPrd1 + ")"
	cQuryRela += " AND " + RetSqlName("SB1") + ".D_E_L_E_T_ = ' '"
	cQuryRela += " INNER JOIN " + RetSqlName("SBM")
	cQuryRela += " ON BM_FILIAL = '" + xfilial("SBM") + "'"
	cQuryRela += " AND BM_GRUPO = B1_GRUPO"
	If !Empty(cListFami)
		cQuryRela += " 	AND BM_TIPGRU IN ('" + StrTran(cListFami,";","','") + "')"																		
	EndIf
	cQuryRela += " AND " + RetSqlName("SBM") + ".D_E_L_E_T_ = ' '"
	cQuryRela += " INNER JOIN " + RetSqlName("SX5") + " SX5"
	cQuryRela += " ON X5_FILIAL = '" + xFilial("SX5") + "' AND X5_TABELA = 'V0'"
	cQuryRela += " AND X5_CHAVE = BM_TIPGRU"
	cQuryRela += " WHERE SD1A.R_E_C_N_O_"
	cQuryRela += " 	IN ( "
	cQuryRela += " 		SELECT SD1B.R_E_C_N_O_"
	cQuryRela += " 		FROM " + RetSqlName("SD1") + " SD1B"
	cQuryRela += " 		INNER JOIN " + RetSqlName("SF4")
	cQuryRela += " 		ON F4_FILIAL = '" + xfilial("SF4") + "'"
	cQuryRela += "		AND F4_CODIGO = SD1A.D1_TES"
	cQuryRela += " 		AND F4_UPRC = 'S'"
	cQuryRela += "		AND " + RetSqlName("SF4") + ".D_E_L_E_T_= ' '"
	cQuryRela += " 		WHERE SD1B.D1_FILIAL >= '"  + cFiliInic + "'"
	cQuryRela += "		AND SD1B.D1_FILIAL <= '" + cFiliFina + "'"
	cQuryRela += "		AND SD1B.D1_DTDIGIT = ("
	cQuryRela += " 									SELECT MAX(SD1C.D1_DTDIGIT) FROM " + RetSqlName("SD1") + " SD1C"
	cQuryRela += "									WHERE SD1C.D1_FILIAL >= '" + cFiliInic + "'"
	cQuryRela += "									AND SD1C.D1_FILIAL <= '" + cFiliFina + "'"
	cQuryRela += "									AND SD1C.D1_TES = F4_CODIGO"
	cQuryRela += " 									AND SD1C.D1_COD = SD1A.D1_COD"
	cQuryRela += " 									AND SD1C.D1_DTDIGIT <= '" + DTOS(dEmisFina) + "'"
	cQuryRela += " 									AND SD1C.D_E_L_E_T_ = ' '))"
	cQuryRela += " 		AND SD1A.D_E_L_E_T_ = ' ')"
	MemoWrite("cViewPrd2.SQL",cQuryRela)
	TcSqlExec( cQuryRela)

	// Aninha compras da produção por produto 
	cQuryRela := " CREATE VIEW " + cViewPrd3 + " AS ("
	cQuryRela += " SELECT PRODUTO"
	cQuryRela += " , SUM(QUANTIDADE) QUANTIDADE"
	cQuryRela += " , SUM(CUSTO) CUSTO, SUM(TOTAL) TOTAL"
	cQuryRela += " , SUM(PIS) PIS, SUM(COFINS) COFINS"
	cQuryRela += " , SUM(IPI) IPI, SUM(ICMS) ICMS"
	cQuryRela += " FROM " + cViewPrd2
	cQuryRela += " GROUP BY PRODUTO)"
	MemoWrite("cViewPrd3.SQL",cQuryRela)
	TcSqlExec( cQuryRela)
	
	//  Soma valores dos insumos das ordens de producao 
	cQuryRela := " CREATE VIEW " + cViewPrd4 + " AS("
	cQuryRela += " SELECT REQUIS.PRODUTO, REQUIS.QUANTIDADE, REQUIS.CUSTO CUSTO"
	cQuryRela += " , ISNULL(COMPRA.QUANTIDADE,0) QTDE_COMPR, ISNULL(COMPRA.CUSTO,0) CUST_COMPR"
	cQuryRela += " , ISNULL(COMPRA.TOTAL,0) TOTL_COMPR, ISNULL(COMPRA.PIS,0) PIS__COMPR"
	cQuryRela += " , ISNULL(COMPRA.COFINS,0) COFI_COMPR, ISNULL(COMPRA.IPI,0) IPI__COMPR"
	cQuryRela += " , ISNULL(COMPRA.ICMS,0) ICMS_COMPR, REQUIS.DOCUMENTO"
	cQuryRela += " FROM " + cViewPrd1 + " REQUIS"
	cQuryRela += " LEFT OUTER JOIN " + cViewPrd3 + " COMPRA"
	cQuryRela += " ON COMPRA.PRODUTO = REQUIS.PRODUTO)"
	MemoWrite("cViewPrd4.SQL",cQuryRela)
	TcSqlExec( cQuryRela)
	
	// Proporcionaliza os impostos para as requisicoes das ordens de producao
	cQuryRela := " CREATE VIEW " + cViewPrd5 + " AS ("
	cQuryRela += " SELECT PRODUTO, QUANTIDADE"
	cQuryRela += " , CUSTO"
	cQuryRela += " , CASE WHEN TOTL_COMPR = 0 THEN CUSTO"
	cQuryRela += "        ELSE CUSTO"
	cQuryRela += "           + (PIS__COMPR / QTDE_COMPR * QUANTIDADE)" 
	cQuryRela += "           + (COFI_COMPR / QTDE_COMPR * QUANTIDADE)"
	cQuryRela += "           + (ICMS_COMPR / QTDE_COMPR * QUANTIDADE) END TOTAL"
	cQuryRela += " , CASE WHEN TOTL_COMPR = 0 THEN 0"
	cQuryRela += "        ELSE (PIS__COMPR / QTDE_COMPR * QUANTIDADE) END PIS"
	cQuryRela += " , CASE WHEN TOTL_COMPR = 0 THEN 0 "
	cQuryRela += "        ELSE (COFI_COMPR / QTDE_COMPR * QUANTIDADE) END COFINS"
	cQuryRela += " , CASE WHEN TOTL_COMPR = 0 THEN 0 "
	cQuryRela += "        ELSE (IPI__COMPR / QTDE_COMPR * QUANTIDADE) END IPI"
	cQuryRela += " , CASE WHEN TOTL_COMPR = 0 THEN 0 "
	cQuryRela += "        ELSE (ICMS_COMPR / QTDE_COMPR * QUANTIDADE) END ICMS"
	cQuryRela += " , DOCUMENTO"
	cQuryRela += " FROM " + cViewPrd4 + " REQUI)"
	MemoWrite("cViewPrd5.SQL",cQuryRela)
	TcSqlExec( cQuryRela)

	// Soma valores das requisiçoes da ordem de producao 
	cQuryRela := " CREATE VIEW " + cViewPrd6 + " AS ("
	cQuryRela += " SELECT DOCUMENTO"
	cQuryRela += " , SUM(CUSTO) CUST_REQUI"
	cQuryRela += " , SUM(PIS) PIS"
	cQuryRela += " , SUM(COFINS) COFINS"
	cQuryRela += " , SUM(IPI) IPI"
	cQuryRela += " , SUM(ICMS) ICMS"  
	cQuryRela += " FROM " + cViewPrd5 
	cQuryRela += " GROUP BY DOCUMENTO )"
	MemoWrite("cViewPrd6.SQL",cQuryRela)
	TcSqlExec( cQuryRela)
	
	// Soma os valores da producao e das requisicoes considerando os impostos proporcionais 
	cQuryRela := " CREATE VIEW " + cViewPrd7 + " AS ("
	cQuryRela += " SELECT PRD.PRODUTO, PRD.DESC_PRODU"
	cQuryRela += " , PRD.GRUPO, PRD.DESC_GRUPO"
	cQuryRela += " , PRD.FAMILIA, PRD.DESC_FAMIL"
	cQuryRela += " , PRD.QUANTIDADE"
	cQuryRela += " , PRD.TIPO_OPERA, PRD.CUSTO CUSTO"
	cQuryRela += " , PRD.CUSTO TOTAL"
	cQuryRela += " , REQ.PIS PIS"
	cQuryRela += " , REQ.COFINS  COFINS"
	cQuryRela += " , REQ.IPI IPI" 
	cQuryRela += " , REQ.ICMS ICMS"
	cQuryRela += " , 'PRODUCAO' TIPO_MOVTO"
	cQuryRela += " , PRD.DOCUMENTO, '  ' ESTADO"
	cQuryRela += " FROM " + cViewProd + " PRD"
	cQuryRela += " INNER JOIN " + cViewPrd6 + " REQ"
	cQuryRela += " ON REQ.DOCUMENTO = PRD.DOCUMENTO)"
	MemoWrite("cViewPrd7.SQL",cQuryRela)
	TcSqlExec( cQuryRela)	

	// Consolida todas as informações
	//Produções
	cQuryRela := " CREATE VIEW " + cViewGera + " AS ("
	cQuryRela += " SELECT * FROM " + cViewPrd7 
	// Devoluções de Vendas
	cQuryRela += " UNION ALL "
	cQuryRela += " SELECT B1_COD PRODUTO, B1_DESC DESC_PRODU"
	cQuryRela += " , B1_GRUPO GRUPO, BM_DESC DESC_GRUPO"
	cQuryRela += " , BM_TIPGRU FAMILIA, X5_DESCRI DESC_FAMIL"
	cQuryRela += " , D1_QUANT QUANTIDADE"
	cQuryRela += " , D1_TES TIPO_OPERA, D1_CUSTO CUSTO, D1_TOTAL TOTAL"
	cQuryRela += " , D1_VALIMP5 PIS, D1_VALIMP6 COFINS"
	cQuryRela += " , D1_VALIPI IPI, D1_VALICM ICMS, 'DEVOLUCAO' TIPO_MOVTO"
	cQuryRela += " , D1_DOC DOCUMENTO, F1_EST ESTADO"
	cQuryRela += " FROM " + RetSqlName("SD1")
	cQuryRela += " INNER JOIN " + RetSqlName("SF1")
	cQuryRela += " ON F1_FILIAL = D1_FILIAL"
	cQuryRela += " AND F1_DOC = D1_DOC"
	cQuryRela += " AND F1_SERIE = D1_SERIE"
	cQuryRela += " AND F1_FORNECE = D1_FORNECE"
	cQuryRela += " AND F1_LOJA = D1_LOJA"
	//If ! Empty(cEstaRela)
	//	cQuryRela += " AND F1_EST IN ('" + StrTran(cEstaRela,";","','") + "')"
	//EndIf
	cQuryRela += " AND " + RetSqlName("SF1") + ".D_E_L_E_T_ = ' '"
	cQuryRela += " INNER JOIN " + RetSqlName("SB1")
	cQuryRela += " ON B1_FILIAL = '" + xfilial("SB1") + "'"
	cQuryRela += " AND B1_COD = D1_COD"
	//If ! Empty(cGrupInic) .Or. ! Empty(cGrupFina)
	//	cQuryRela += " AND B1_GRUPO >= '" + cGrupInic + "'"
	//	cQuryRela += " AND B1_GRUPO <= '" + cGrupFina + "'"
	//EndIf
	cQuryRela += " AND " + RetSqlName("SB1") + ".D_E_L_E_T_ = ' '"
	cQuryRela += " INNER JOIN " + RetSqlName("SBM")
	cQuryRela += " ON BM_FILIAL = '" + xfilial("SBM") + "'"
	cQuryRela += " AND BM_GRUPO = B1_GRUPO"
	//If !Empty(cListFami)
	//	cQuryRela += " 	AND BM_TIPGRU IN ('" + StrTran(cListFami,";","','") + "')"																		
	//EndIf
	cQuryRela += " AND " + RetSqlName("SBM") + ".D_E_L_E_T_ = ' '"
	cQuryRela += " INNER JOIN " + RetSqlName("SX5") + " SX5"
	cQuryRela += " ON X5_FILIAL = '" + xFilial("SX5") + "' AND X5_TABELA = 'V0'"
	cQuryRela += " AND X5_CHAVE = BM_TIPGRU"
	cQuryRela += " INNER JOIN " + RetSqlName("SF4")
	cQuryRela += " ON F4_FILIAL = '" + xFilial("SF4") + "' "
	cQuryRela += " AND F4_CODIGO = D1_TES"
	cQuryRela += " AND F4_DUPLIC = 'S'"
	cQuryRela += " AND " + RetSqlName("SF4")  + ".D_E_L_E_T_  = ' '"
	cQuryRela += " WHERE D1_FILIAL >= '" + cFiliInic + "'"
	cQuryRela += " AND D1_FILIAL <= '" + cFiliFina + "'"
	cQuryRela += " AND D1_DTDIGIT >= '" + DTOS(dEmisInic) + "'"
	cQuryRela += " AND D1_DTDIGIT <= '" + DTOS(dEmisFina) + "'"
	cQuryRela += " AND D1_TIPO = 'D'"
	cQuryRela += " AND D1_SERIE <> '3'"
	cQuryRela += " AND " + RetSqlName("SD1") + ".D_E_L_E_T_ = ' '"
	// Vendas
	cQuryRela += " UNION ALL "
	cQuryRela += " SELECT B1_COD PRODUTO, B1_DESC DESC_PRODU"
	cQuryRela += " , B1_GRUPO GRUPO, BM_DESC DESC_GRUPO"
	cQuryRela += " , BM_TIPGRU FAMILIA, X5_DESCRI DESC_FAMIL"
	cQuryRela += " , D2_QUANT QUANTIDADE"
	cQuryRela += " , D2_TES TIPO_OPERA, ISNULL(D3_CUSTO1,D2_CUSTO1) CUSTO, D2_TOTAL TOTAL"
	cQuryRela += " , D2_VALIMP5 PIS, D2_VALIMP6 COFINS"
	cQuryRela += " , D2_VALIPI IPI, D2_VALICM ICMS, 'VENDA' TIPO_MOVTO"
	cQuryRela += " , D2_DOC DOCUMENTO, D2_EST ESTADO"
	cQuryRela += " FROM " + RetSqlName("SD2")
	cQuryRela += " LEFT OUTER JOIN " + RetSqlName("SC2")
	cQuryRela += " ON C2_FILIAL = D2_FILIAL"
	cQuryRela += " AND C2_PEDIDO = D2_PEDIDO"
	cQuryRela += " AND C2_ITEMPV = D2_ITEMPV"
	cQuryRela += " AND " + RetSqlName("SC2") + ".D_E_L_E_T_ = ' '"
	cQuryRela += " LEFT OUTER JOIN " + RetSqlName("SD3")
	cQuryRela += " ON C2_FILIAL = D3_FILIAL"
	cQuryRela += " AND C2_NUM + C2_ITEM + C2_SEQUEN = D3_OP"
	cQuryRela += " AND SUBSTRING(D3_CF,1,2) = 'PR'"
	cQuryRela += " AND " + RetSqlName("SD3") + ".D_E_L_E_T_ = ' '"
	cQuryRela += " INNER JOIN " + RetSqlName("SB1")
	cQuryRela += " ON B1_FILIAL = '" + xfilial("SB1") + "'"
	cQuryRela += " AND B1_COD = D2_COD"
	//If ! Empty(cGrupInic) .Or. ! Empty(cGrupFina)
	//	cQuryRela += " AND B1_GRUPO >= '" + cGrupInic + "'"
	//	cQuryRela += " AND B1_GRUPO <= '" + cGrupFina + "'"
	//EndIf
	cQuryRela += " AND " + RetSqlName("SB1") + ".D_E_L_E_T_ = ' '"
	cQuryRela += " INNER JOIN " + RetSqlName("SBM")
	cQuryRela += " ON BM_FILIAL = '" + xfilial("SBM") + "'"
	cQuryRela += " AND BM_GRUPO = B1_GRUPO"
	//If !Empty(cListFami)
	//	cQuryRela += " 	AND BM_TIPGRU IN ('" + StrTran(cListFami,";","','") + "')"																		
	//EndIf
	cQuryRela += " AND " + RetSqlName("SBM") + ".D_E_L_E_T_ = ' '"
	cQuryRela += " INNER JOIN " + RetSqlName("SX5") + " SX5"
	cQuryRela += " ON X5_FILIAL = '" + xFilial("SX5") + "' AND X5_TABELA = 'V0'"
	cQuryRela += " AND X5_CHAVE = BM_TIPGRU"
	cQuryRela += " INNER JOIN " + RetSqlName("SF4")
	cQuryRela += " ON F4_FILIAL = '" + xFilial("SF4") + "'"
	cQuryRela += " AND F4_CODIGO = D2_TES"
	cQuryRela += " AND F4_DUPLIC = 'S'"
	cQuryRela += " AND " + RetSqlName("SF4")  + ".D_E_L_E_T_  = ' '"
	cQuryRela += " WHERE D2_FILIAL >= '" + cFiliInic + "'"
	cQuryRela += " AND D2_FILIAL <= '" + cFiliFina + "'"
	cQuryRela += " AND D2_EMISSAO >= '" + DTOS(dEmisInic) + "'"
	cQuryRela += " AND D2_EMISSAO <= '" + DTOS(dEmisFina) + "'"
	//If ! Empty(cEstaRela)
	//	cQuryRela += " AND D2_EST IN ('" + StrTran(cEstaRela,";","','") + "')"
	//EndIf
	cQuryRela += " AND " + RetSqlName("SD2") + ".D_E_L_E_T_ = ' '"
	// Compras
	cQuryRela += " UNION ALL"
	cQuryRela += " SELECT B1_COD PRODUTO, B1_DESC DESC_PRODU"
	cQuryRela += " , B1_GRUPO GRUPO, BM_DESC DESC_GRUPO"
	cQuryRela += " , BM_TIPGRU FAMILIA, X5_DESCRI DESC_FAMIL"
	cQuryRela += " , D1_QUANT QUANTIDADE"
	cQuryRela += " , D1_TES TIPO_OPERA, D1_CUSTO CUSTO, D1_TOTAL TOTAL"
	cQuryRela += " , D1_VALIMP5 PIS, D1_VALIMP6 COFINS"
	cQuryRela += " , D1_VALIPI IPI, D1_VALICM ICMS, 'COMPRA' TIPO_MOVTO"
	cQuryRela += " , D1_DOC DOCUMENTO, '  ' ESTADO"
	cQuryRela += " FROM " + RetSqlName("SD1") + " SD1A"
	cQuryRela += " INNER JOIN " + RetSqlName("SB1")
	cQuryRela += " ON B1_FILIAL = '" + xfilial("SB1") + "'"
	cQuryRela += " AND B1_COD = D1_COD"
	//If ! Empty(cGrupInic) .Or. ! Empty(cGrupFina)
	//	cQuryRela += " AND B1_GRUPO >= '" + cGrupInic + "'"
	//	cQuryRela += " AND B1_GRUPO <= '" + cGrupFina + "'"
	//EndIf
	cQuryRela += " AND " + RetSqlName("SB1") + ".D_E_L_E_T_ = ' '"
	cQuryRela += " INNER JOIN " + RetSqlName("SBM")
	cQuryRela += " ON BM_FILIAL = '" + xfilial("SBM") + "'"
	cQuryRela += " AND BM_GRUPO = B1_GRUPO"
	//If !Empty(cListFami)
	//	cQuryRela += " 	AND BM_TIPGRU IN ('" + StrTran(cListFami,";","','") + "')"																		
	//EndIf
	cQuryRela += " AND " + RetSqlName("SBM") + ".D_E_L_E_T_ = ' '"
	cQuryRela += " INNER JOIN " + RetSqlName("SX5") + " SX5"
	cQuryRela += " ON X5_FILIAL = '" + xFilial("SX5") + "' AND X5_TABELA = 'V0'"
	cQuryRela += " AND X5_CHAVE = BM_TIPGRU"
	cQuryRela += " WHERE SD1A.R_E_C_N_O_"
	cQuryRela += " 	IN ("
	cQuryRela += " 		SELECT SD1B.R_E_C_N_O_"
	cQuryRela += " 		FROM " + RetSqlName("SD1") + " SD1B"
	cQuryRela += " 		INNER JOIN " + RetSqlName("SF4")
	cQuryRela += " 		ON F4_FILIAL = '" + xfilial("SF4") + "'"
	cQuryRela += "		AND F4_CODIGO = SD1A.D1_TES"
	cQuryRela += " 		AND F4_UPRC = 'S'"
	cQuryRela += "		AND " + RetSqlName("SF4") + ".D_E_L_E_T_= ' '"
	cQuryRela += " 		WHERE SD1B.D1_FILIAL >= '"  + cFiliInic + "'"
	cQuryRela += "		AND SD1B.D1_FILIAL <= '" + cFiliFina + "'"
	cQuryRela += "		AND SD1B.D1_DTDIGIT = ("
	cQuryRela += " 									SELECT MAX(SD1C.D1_DTDIGIT) FROM " + RetSqlName("SD1") + " SD1C"
	cQuryRela += "									WHERE SD1C.D1_FILIAL >= '" + cFiliInic + "'"
	cQuryRela += "									AND SD1C.D1_FILIAL <= '" + cFiliFina + "'"
	cQuryRela += "									AND SD1C.D1_TES = F4_CODIGO"
	cQuryRela += " 									AND SD1C.D1_COD = SD1A.D1_COD"
	cQuryRela += "                                  AND SD1C.D1_DTDIGIT >= '20180601'"
	cQuryRela += " 									AND SD1C.D1_DTDIGIT < '" + DTOS(dEmisFina) + "'"
	cQuryRela += " 									AND SD1C.D_E_L_E_T_ = ' '))"
	cQuryRela += " 		AND SD1A.D_E_L_E_T_ = ' ')"
	MemoWrite("cViewGera.SQL",cQuryRela)
	TcSqlExec( cQuryRela)

	cQuryRela := " SELECT * FROM " + cViewGera 
	MemoWrite("cRelaView.SQL",cQuryRela)
	dbUseArea(.T., "TOPCONN", TCGenQry(NIL,NIL,cQuryRela), "TRB_001" ,.F., .T. )

	TRB_001->(dbGoTop())
	nContRegi := TRB_001->(RecCount())
	nContRela := 0
	ProcRegua(nContRegi)

	cQuryRela := " SELECT * FROM " + cViewPrd1 
	MemoWrite("cRelaVie2.SQL",cQuryRela)
	dbUseArea(.T., "TOPCONN", TCGenQry(NIL,NIL,cQuryRela), "TRB_002" ,.F., .T. )

	cQuryRela := " SELECT * FROM " + cViewPrd2 
	MemoWrite("cRelaVie3.SQL",cQuryRela)
	dbUseArea(.T., "TOPCONN", TCGenQry(NIL,NIL,cQuryRela), "TRB_003" ,.F., .T. )

	If nGeraDeta == 1
		TRB_001->(dbGoTop())
		aListGera := {}
		cTituRela := "Detalhamento Faturamento x Compras "
		cTituPlan := cTituRela + IIf(nTipoRela == 1,"com Impostos","sem Impostos")

		While ! TRB_001->(Eof())
			aAdd(aListGera,{TRB_001->PRODUTO,;
			                AnsiToOem(FwNoAccent(TRB_001->DESC_PRODU)),;
			                TRB_001->GRUPO,;
								 AnsiToOem(FwNoAccent(TRB_001->DESC_GRUPO)),;
								 TRB_001->FAMILIA,;
			                AnsiToOem(FwNoAccent(TRB_001->DESC_FAMIL)),;
								 TRB_001->QUANTIDADE,;
								 TRB_001->TIPO_OPERA,;
			                TRB_001->CUSTO,;
								 TRB_001->TOTAL,;
								 TRB_001->PIS,;
								 TRB_001->COFINS,;
								 TRB_001->IPI,;
			                TRB_001->ICMS,;
								 TRB_001->TIPO_MOVTO,;
								 TRB_001->DOCUMENTO,;
								 TRB_001->ESTADO})
			IncProc("Gerando Relatório " + LTrim(Str(nContRela ++)))
			TRB_001->(dbSkip())
		End
		TRB_002->(dbGoTop())
		nContRegi := TRB_002->(RecCount())
		nContRela := 0
		ProcRegua(nContRegi)
		
		While ! TRB_002->(Eof())
			aAdd(aListGera,{TRB_002->PRODUTO,;
			                AnsiToOem(FwNoAccent(TRB_002->DESC_PRODU)),;
			                TRB_002->GRUPO,;
								 AnsiToOem(FwNoAccent(TRB_002->DESC_GRUPO)),;
								 TRB_002->FAMILIA,;
			                AnsiToOem(FwNoAccent(TRB_002->DESC_FAMIL)),;
								 TRB_002->QUANTIDADE,;
								 TRB_002->TIPO_OPERA,;
			                TRB_002->CUSTO,;
								 TRB_002->TOTAL,;
								 TRB_002->PIS,;
								 TRB_002->COFINS,;
								 TRB_002->IPI,;
			                TRB_002->ICMS,;
								 TRB_002->TIPO_MOVTO,;
								 TRB_002->DOCUMENTO,;
								 TRB_002->ESTADO})
			IncProc("Gerando Relatório " + LTrim(Str(nContRela ++)))
			TRB_002->(dbSkip())
		End

		TRB_003->(dbGoTop())
		nContRegi := TRB_003->(RecCount())
		nContRela := 0
		ProcRegua(nContRegi)
		
		While ! TRB_003->(Eof())
			aAdd(aListGera,{TRB_003->PRODUTO,;
			                AnsiToOem(FwNoAccent(TRB_003->DESC_PRODU)),;
			                TRB_003->GRUPO,;
								 AnsiToOem(FwNoAccent(TRB_003->DESC_GRUPO)),;
								 TRB_003->FAMILIA,;
			                AnsiToOem(FwNoAccent(TRB_003->DESC_FAMIL)),;
								 TRB_003->QUANTIDADE,;
								 TRB_003->TIPO_OPERA,;
			                TRB_003->CUSTO,;
								 TRB_003->TOTAL,;
								 TRB_003->PIS,;
								 TRB_003->COFINS,;
								 TRB_003->IPI,;
			                TRB_003->ICMS,;
								 TRB_003->TIPO_MOVTO,;
								 TRB_003->DOCUMENTO,;
								 TRB_003->ESTADO})
			IncProc("Gerando Relatório " + LTrim(Str(nContRela ++)))
			TRB_003->(dbSkip())
		End
		
		RPFAT01B(cTituRela,cTituPlan,cDireGrav,aListGera)
	EndIf
	TRB_001->(dbCloseArea())
	TRB_002->(dbCloseArea())
	TRB_003->(dbCloseArea())
	
	RPFAT01C(cDireGrav,dEmisinic,dEmisFina,nTipoAgru,nTipoRela,cViewGera,nGeraDcto,cGrupInic,cGrupFina,cListFami,cEstaRela,cFiliInic,cFiliFina)
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ?RPFAT01B ?Autor ?Joao Goncalves de Oliveira ?Data ?   25/01/18    ³±
?±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ?Gera planilha de detalhamento                                    ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ?SDFAT19B(ExpC1,ExpC2,ExpC3,ExpA4,ExpC5)  		                   ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros?ExpC1 - Titulo Arquivo 									       ³±?
±±?         ?ExpC2 - Titulo Planilha									       ³±?
±±?         ?ExpC3 - Pasta de gravação do arquivo xml 				           ³±?
±±?         ?ExpA4 - Vetor com dados a serem gravados 				           ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±³ Retorno   ?Nenhum 													       ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RPFAT01B(cTituRela,cTituPlan,cDireGrav,aListGera)

	Local cDirTmp   := GetTempPath()
	Local oListCham := FWMsExcelEx():New()
	Local oExcelApp := MsExcel():New()
	Local cArquGera := ""

	oListCham:AddworkSheet(cTituRela)
	oListCham:AddTable (cTituRela,cTituPlan)
	oListCham:AddColumn(cTituRela,cTituPlan,"Produto",1,1,.F.)
	oListCham:AddColumn(cTituRela,cTituPlan,"Descricao Produto",1,1,.F.)
	oListCham:AddColumn(cTituRela,cTituPlan,"Grupo",1,1,.F.)
	oListCham:AddColumn(cTituRela,cTituPlan,"Descricao Grupo",1,1,.F.)
	oListCham:AddColumn(cTituRela,cTituPlan,"Familia",1,1,.F.)
	oListCham:AddColumn(cTituRela,cTituPlan,"Descricao Familia",1,1,.F.)
	oListCham:AddColumn(cTituRela,cTituPlan,"Quantidade",3,2,.F.)
	oListCham:AddColumn(cTituRela,cTituPlan,"Tipo Operacao",1,1,.F.)
	oListCham:AddColumn(cTituRela,cTituPlan,"Custo",3,2,.F.)
	oListCham:AddColumn(cTituRela,cTituPlan,"Total",3,2,.F.)
	oListCham:AddColumn(cTituRela,cTituPlan,"PIS",3,2,.F.)
	oListCham:AddColumn(cTituRela,cTituPlan,"Cofins",3,2,.F.)
	oListCham:AddColumn(cTituRela,cTituPlan,"IPI",3,2,.F.)
	oListCham:AddColumn(cTituRela,cTituPlan,"ICMS",3,2,.F.)
	oListCham:AddColumn(cTituRela,cTituPlan,"Tipo Movimento",1,1,.F.)
	oListCham:AddColumn(cTituRela,cTituPlan,"Documento",1,1,.F.)
	oListCham:AddColumn(cTituRela,cTituPlan,"Estado",1,1,.F.)
	aEval(aListGera,{|x| oListCham:AddRow(cTituRela,cTituPlan,x)})

	oListCham:Activate()
	cArquGera := AllTrim(cDireGrav) + "RPFAT001.XML"
	oListCham:GetXMLFile(cArquGera)
	If ApOleClient("MsExcel")
		If __CopyFile(cArquGera, cDirTmp + "RPFAT001.XML")
			oExcelApp := MsExcel():New()
			oExcelApp:WorkBooks:Open( cDirTmp + "RPFAT001.XML")
			oExcelApp:SetVisible(.T.)
		Else
			MsgInfo( "Arquivo não copiado para temporário do usuário.","Atenção" )
		Endif
	Else
		MsgInfo("MsExcel não instalado","Atenção")
	EndIf

Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ?RPFAT01C ?Autor ?Joao Goncalves de Oliveira ?Data ?10/01/19      ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ?Gera relatório com resumo das informações                        ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ?RPFAT01C(ExpC1,ExpC2,ExpC3,ExpA4,ExpC5,ExpC6) 	               ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros?ExpC1 - Diretório de Gravação 					   	           ³±?
±±?         ?ExpD2 - Data de Emissão Inicial 							       ³±?
±±?         ?ExpD3 - Data de Emissão Final 								       ³±?
±±?         ?ExpN4 - Tipo de Agrupamento 								       ³±?
±±?         ?ExpN5 - Tipo de Relatório 									       ³±?
±±?         ?ExpC6 - Nome da View com dados 								   ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±³ Retorno   ?Nenhum 														   ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RPFAT01C(cDireGrav,dEmisinic,dEmisFina,nTipoAgru,nTipoRela,cViewGera,nGeraDcto,cGrupInic,cGrupFina,cListFami,cEstaRela,cFiliInic,cFiliFina)

	Local oPrint
	Local cQuryRela := ""
	Local cViewFin1 := "RPFAT01A" + GetNextAlias()
	Local cViewFin2 := "RPFAT01A" + GetNextAlias()
	Local cViewFin3 := "RPFAT01A" + GetNextAlias()
	Local cViewFin4 := "RPFAT01A" + GetNextAlias()
	Local cViewFin5 := "RPFAT01A" + GetNextAlias()
	Local cViewFin6 := "RPFAT01A" + GetNextAlias()

	Local nTotaQtde := 0
	Local nTotaRece := 0
	Local nTotaCust := 0
	Local nPrVeMedi := 0
	Local nMargVend := 0
	Local nPercPart := 0
	Local nUltiComp := 0
	Local nQtdeGera := 0 
	Local nCustGera := 0 
	Local nReceGera := 0 
	Local nQtdeDevo := 0
	Local nCustDevo := 0
	Local nValoDevo := 0 
	Local cNomeArqu := "Relatório_Compras_x_Faturamento" + IIf(nTipoRela == 1,"_com_Impostos","_sem_Impostos") + ".PDF" 
	Local nContRela := 0
	Local nQtdeRegi := 0
	Local cGru1Inic := ""
	Local cGru2Inic := ""
	Local cGru1Atua := ""
	Local cGru2Atua := ""
	Local nValoRece := 0
	Local aSX5 := {}
	
	Private cTitulo := "Relatório de Faturamento x Compra com impostos (PIS, Cofins, IPI e ICMS)"
	Private nLin		:= 501
	Private nMaxLin		:= 500
	Private nCol		:= 50
	Private nColFim		:= 825
	Private cBitmap	:= "\system\Replas.jpg"

	Private oFont07  := TFont():New( "Arial",,07,,.F.,,,,,.F. )
	Private oFont08  := TFont():New( "Arial",,08,,.F.,,,,,.F. )
	Private oFont09B := TFont():New( "Arial",,09,,.T.,,,,,.F. )
	Private oFont10B := TFont():New( "Arial",,10,,.T.,,,,,.F. )
	Private oFont11  := TFont():New( "Arial",,11,,.F.,,,,,.F. )
	Private oFont12B := TFont():New( "Arial",,12,,.T.,,,,,.F. )
	Private oFont14B := TFont():New( "Arial",,14,,.T.,,,,,.F. )
	
	Private oBrush2 := TBrush():New(,CLR_HGRAY)		// Cinza Claro
	Private nClrAzul	:= RGB(032,038,119)
	Private nClrVerm	:= RGB(237,028,036)
	Private nPagina		:= 1
	
	oPrint := FWMSPrinter():New(cNomeArqu,IMP_PDF,.F.,"\SPOOL\",.T.,,,,.F.,.T.,,.T.,)

	oPrint:SetResolution(72)			// Default
	oPrint:SetLandscape() 				// SetLandscape() ou SetPortrait()
	oPrint:SetPaperSize(9)				// A4 210mm x 297mm  620 x 876
	oPrint:SetMargin(10,10,10,10)		// < nLeft>, < nTop>, < nRight>, < nBottom>
	oPrint:cPathPDF:= AllTrim(cDireGrav)
	oPrint:StartPage()   	// Inicia uma nova página
	oBrush2 := TBrush():New(,CLR_HGRAY)		// Cinza Claro

	cQuryRela := " CREATE VIEW " + cViewFin1 + " AS ("
	cQuryRela += " SELECT PRODUTO, DESC_PRODU"
	cQuryRela += " , GRUPO, DESC_GRUPO"
	cQuryRela += " , FAMILIA, DESC_FAMIL"
	cQuryRela += " , DOCUMENTO"
	cQuryRela += " , CASE WHEN TIPO_MOVTO = 'VENDA'     THEN ESTADO     ELSE ' ' END ESTA_VENDA"
	cQuryRela += " , CASE WHEN TIPO_MOVTO = 'DEVOLUCAO' THEN ESTADO     ELSE ' ' END ESTA_DEVOL"
	cQuryRela += " , CASE WHEN TIPO_MOVTO = 'COMPRA'    THEN QUANTIDADE ELSE 0 END QTDE_COMPR"
	cQuryRela += " , CASE WHEN TIPO_MOVTO = 'VENDA'     THEN QUANTIDADE ELSE 0 END QTDE_VENDA"
	cQuryRela += " , CASE WHEN TIPO_MOVTO = 'PRODUCAO'  THEN QUANTIDADE ELSE 0 END QTDE_PRODU"
	cQuryRela += " , CASE WHEN TIPO_MOVTO = 'DEVOLUCAO' THEN QUANTIDADE ELSE 0 END QTDE_DEVOL"
	cQuryRela += " , CASE WHEN TIPO_MOVTO = 'COMPRA'    THEN CUSTO      ELSE 0 END CUST_COMPR"
	cQuryRela += " , CASE WHEN TIPO_MOVTO = 'VENDA'     THEN CUSTO      ELSE 0 END CUST_VENDA"
	cQuryRela += " , CASE WHEN TIPO_MOVTO = 'PRODUCAO'  THEN CUSTO      ELSE 0 END CUST_PRODU"
	cQuryRela += " , CASE WHEN TIPO_MOVTO = 'DEVOLUCAO' THEN CUSTO      ELSE 0 END CUST_DEVOL"
	cQuryRela += " , CASE WHEN TIPO_MOVTO = 'COMPRA'    THEN TOTAL      ELSE 0 END TOTL_COMPR"
	cQuryRela += " , CASE WHEN TIPO_MOVTO = 'VENDA'     THEN TOTAL      ELSE 0 END TOTL_VENDA"
	cQuryRela += " , CASE WHEN TIPO_MOVTO = 'PRODUCAO'  THEN TOTAL      ELSE 0 END TOTL_PRODU"
	cQuryRela += " , CASE WHEN TIPO_MOVTO = 'DEVOLUCAO' THEN TOTAL      ELSE 0 END TOTL_DEVOL"
	cQuryRela += " , CASE WHEN TIPO_MOVTO = 'COMPRA'    THEN PIS        ELSE 0 END PIS__COMPR"
	cQuryRela += " , CASE WHEN TIPO_MOVTO = 'VENDA'     THEN PIS        ELSE 0 END PIS__VENDA"
	cQuryRela += " , CASE WHEN TIPO_MOVTO = 'PRODUCAO'  THEN PIS        ELSE 0 END PIS__PRODU"
	cQuryRela += " , CASE WHEN TIPO_MOVTO = 'DEVOLUCAO' THEN PIS        ELSE 0 END PIS__DEVOL"
	cQuryRela += " , CASE WHEN TIPO_MOVTO = 'COMPRA'    THEN COFINS     ELSE 0 END COFI_COMPR"
	cQuryRela += " , CASE WHEN TIPO_MOVTO = 'VENDA'     THEN COFINS     ELSE 0 END COFI_VENDA"
	cQuryRela += " , CASE WHEN TIPO_MOVTO = 'PRODUCAO'  THEN COFINS     ELSE 0 END COFI_PRODU"
	cQuryRela += " , CASE WHEN TIPO_MOVTO = 'DEVOLUCAO' THEN COFINS     ELSE 0 END COFI_DEVOL"
	cQuryRela += " , CASE WHEN TIPO_MOVTO = 'COMPRA'    THEN IPI        ELSE 0 END IPI__COMPR"
	cQuryRela += " , CASE WHEN TIPO_MOVTO = 'VENDA'     THEN IPI        ELSE 0 END IPI__VENDA"
	cQuryRela += " , CASE WHEN TIPO_MOVTO = 'PRODUCAO'  THEN IPI        ELSE 0 END IPI__PRODU"
	cQuryRela += " , CASE WHEN TIPO_MOVTO = 'DEVOLUCAO' THEN IPI        ELSE 0 END IPI__DEVOL"
	cQuryRela += " , CASE WHEN TIPO_MOVTO = 'COMPRA'    THEN ICMS       ELSE 0 END ICMS_COMPR"
	cQuryRela += " , CASE WHEN TIPO_MOVTO = 'VENDA'     THEN ICMS       ELSE 0 END ICMS_VENDA"
	cQuryRela += " , CASE WHEN TIPO_MOVTO = 'PRODUCAO'  THEN ICMS       ELSE 0 END ICMS_PRODU"
	cQuryRela += " , CASE WHEN TIPO_MOVTO = 'DEVOLUCAO' THEN ICMS       ELSE 0 END ICMS_DEVOL"
	cQuryRela += " FROM " + cViewGera + ")"
	MemoWrite("cViewFin1.SQL",cQuryRela)
	TcSqlExec( cQuryRela)


// Agrupa Vendas e Devoluções
	cQuryRela := " CREATE VIEW " + cViewFin2 + " AS ("
	cQuryRela += " SELECT PRODUTO, DESC_PRODU"
	cQuryRela += " , GRUPO, DESC_GRUPO"
	cQuryRela += " , FAMILIA, DESC_FAMIL"
	cQuryRela += " , CASE WHEN ESTA_VENDA <> '  ' THEN ESTA_VENDA ELSE ESTA_DEVOL END ESTADO"
	cQuryRela += " , QTDE_VENDA, QTDE_DEVOL"
	cQuryRela += " , CUST_VENDA, CUST_DEVOL"
	cQuryRela += " , TOTL_VENDA, TOTL_DEVOL"
	cQuryRela += " , PIS__VENDA, PIS__DEVOL"
	cQuryRela += " , COFI_VENDA, COFI_DEVOL"
	cQuryRela += " , IPI__VENDA, IPI__DEVOL"
	cQuryRela += " , ICMS_VENDA, ICMS_DEVOL, DOCUMENTO"
	cQuryRela += " FROM " + cViewFin1
	cQuryRela += " WHERE QTDE_VENDA > 0 OR QTDE_DEVOL > 0"
	cQuryRela += ")"
	MemoWrite("cViewFin2.SQL",cQuryRela)
	TcSqlExec( cQuryRela)

	cQuryRela := " CREATE VIEW " + cViewFin3 + " AS ("
	cQuryRela += " SELECT PRODUTO, DESC_PRODU"
	cQuryRela += " , GRUPO, DESC_GRUPO"
	cQuryRela += " , FAMILIA, DESC_FAMIL"
	cQuryRela += " , ESTADO, DOCUMENTO"
	cQuryRela += " , SUM(QTDE_VENDA) QTDE_VENDA, SUM(QTDE_DEVOL) QTDE_DEVOL"
	cQuryRela += " , SUM(CUST_VENDA) CUST_VENDA, SUM(CUST_DEVOL) CUST_DEVOL"
	cQuryRela += " , SUM(TOTL_VENDA) TOTL_VENDA, SUM(TOTL_DEVOL) TOTL_DEVOL"
	cQuryRela += " , SUM(PIS__VENDA) PIS__VENDA, SUM(PIS__DEVOL) PIS__DEVOL"
	cQuryRela += " , SUM(COFI_VENDA) COFI_VENDA, SUM(COFI_DEVOL) COFI_DEVOL"
	cQuryRela += " , SUM(IPI__VENDA) IPI__VENDA, SUM(IPI__DEVOL) IPI__DEVOL"
	cQuryRela += " , SUM(ICMS_VENDA) ICMS_VENDA, SUM(ICMS_DEVOL) ICMS_DEVOL"
	cQuryRela += " FROM " + cViewFin2
	cQuryRela += " GROUP BY PRODUTO, DESC_PRODU, GRUPO, DESC_GRUPO"
	cQuryRela += " , FAMILIA, DESC_FAMIL, ESTADO, DOCUMENTO"
	cQuryRela += ")"
	MemoWrite("cViewFin3.SQL",cQuryRela)
	TcSqlExec( cQuryRela)

// Agrupa Compras e Producões
	cQuryRela := " CREATE VIEW " + cViewFin4 + " AS ("
	cQuryRela += " SELECT PRODUTO"
	cQuryRela += " , SUM(QTDE_COMPR) QTDE_COMPR, SUM(QTDE_PRODU) QTDE_PRODU"
	cQuryRela += " , SUM(CUST_COMPR) CUST_COMPR, SUM(CUST_PRODU) CUST_PRODU"
	cQuryRela += " , SUM(TOTL_COMPR) TOTL_COMPR, SUM(TOTL_PRODU) TOTL_PRODU"
	cQuryRela += " , SUM(PIS__COMPR) PIS__COMPR, SUM(PIS__PRODU) PIS__PRODU"
	cQuryRela += " , SUM(COFI_COMPR) COFI_COMPR, SUM(COFI_PRODU) COFI_PRODU"
	cQuryRela += " , SUM(IPI__COMPR) IPI__COMPR, SUM(IPI__PRODU) IPI__PRODU"
	cQuryRela += " , SUM(ICMS_COMPR) ICMS_COMPR, SUM(ICMS_PRODU) ICMS_PRODU"
	cQuryRela += " FROM " + cViewFin1
	cQuryRela += " WHERE QTDE_COMPR> 0 OR QTDE_PRODU > 0"
	cQuryRela += " GROUP BY PRODUTO, DESC_PRODU"
	cQuryRela += " , GRUPO, DESC_GRUPO"
	cQuryRela += " , FAMILIA, DESC_FAMIL"
	cQuryRela += ")"
	MemoWrite("cViewFin4.SQL",cQuryRela)
	TcSqlExec( cQuryRela)

	// Busca compras de cada produto
	cQuryRela := " CREATE VIEW " + cViewFin5 + " AS ("
	cQuryRela += " SELECT VIEW_VENDA.PRODUTO, DESC_PRODU"
	cQuryRela += " , GRUPO, DESC_GRUPO"
	cQuryRela += " , FAMILIA, DESC_FAMIL"
	cQuryRela += " , ESTADO, DOCUMENTO"
	cQuryRela += " , QTDE_VENDA, QTDE_DEVOL"
	cQuryRela += " , CUST_VENDA, CUST_DEVOL"
	cQuryRela += " , TOTL_VENDA, TOTL_DEVOL"
	cQuryRela += " , PIS__VENDA, PIS__DEVOL"
	cQuryRela += " , COFI_VENDA, COFI_DEVOL"
	cQuryRela += " , IPI__VENDA, IPI__DEVOL"
	cQuryRela += " , ICMS_VENDA, ICMS_DEVOL"
	cQuryRela += " , ISNULL(QTDE_COMPR,0) QTDE_COMPR"
	cQuryRela += " , ISNULL(QTDE_PRODU,0) QTDE_PRODU"
	cQuryRela += " , ISNULL(CUST_COMPR,0) CUST_COMPR"
	cQuryRela += " , ISNULL(CUST_PRODU,0) CUST_PRODU"
	cQuryRela += " , ISNULL(TOTL_COMPR,0) TOTL_COMPR"
	cQuryRela += " , ISNULL(TOTL_PRODU,0) TOTL_PRODU"
	cQuryRela += " , ISNULL(PIS__COMPR,0) PIS__COMPR"
	cQuryRela += " , ISNULL(PIS__PRODU,0) PIS__PRODU"
	cQuryRela += " , ISNULL(COFI_COMPR,0) COFI_COMPR"
	cQuryRela += " , ISNULL(COFI_PRODU,0) COFI_PRODU"
	cQuryRela += " , ISNULL(IPI__COMPR,0) IPI__COMPR"
	cQuryRela += " , ISNULL(IPI__PRODU,0) IPI__PRODU"
	cQuryRela += " , ISNULL(ICMS_COMPR,0) ICMS_COMPR"
	cQuryRela += " , ISNULL(ICMS_PRODU,0) ICMS_PRODU"
	cQuryRela += " FROM " + cViewFin3 + " VIEW_VENDA "
	cQuryRela += " LEFT OUTER JOIN " + cViewFin4 + " VIEW_COMPRA"
	cQuryRela += " ON VIEW_VENDA.PRODUTO = VIEW_COMPRA.PRODUTO"
	cQuryRela += ")"
	MemoWrite("cViewFin5.SQL",cQuryRela)
	TcSqlExec( cQuryRela)


	cQuryRela := " CREATE VIEW " + cViewFin6 + " AS ("
	cQuryRela += " SELECT PRODUTO, DESC_PRODU"
	cQuryRela += " , GRUPO, DESC_GRUPO"
	cQuryRela += " , FAMILIA, DESC_FAMIL, ESTADO, DOCUMENTO"
	cQuryRela += " , SUM(QTDE_COMPR) QTDE_COMPR"
	cQuryRela += " , SUM(QTDE_VENDA) QTDE_VENDA"
	cQuryRela += " , SUM(QTDE_PRODU) QTDE_PRODU"
	cQuryRela += " , SUM(QTDE_DEVOL) QTDE_DEVOL"
	cQuryRela += " , SUM(CUST_COMPR) CUST_COMPR"
	cQuryRela += " , SUM(CUST_VENDA) CUST_VENDA"
	cQuryRela += " , SUM(CUST_PRODU) CUST_PRODU"
	cQuryRela += " , SUM(CUST_DEVOL) CUST_DEVOL"
	cQuryRela += " , SUM(TOTL_COMPR) TOTL_COMPR"
	cQuryRela += " , SUM(TOTL_VENDA) TOTL_VENDA"
	cQuryRela += " , SUM(TOTL_PRODU) TOTL_PRODU"
	cQuryRela += " , SUM(TOTL_DEVOL) TOTL_DEVOL"
	cQuryRela += " , SUM(PIS__COMPR) PIS__COMPR"
	cQuryRela += " , SUM(PIS__VENDA) PIS__VENDA"
	cQuryRela += " , SUM(PIS__PRODU) PIS__PRODU"
	cQuryRela += " , SUM(PIS__DEVOL) PIS__DEVOL"
	cQuryRela += " , SUM(COFI_COMPR) COFI_COMPR"
	cQuryRela += " , SUM(COFI_VENDA) COFI_VENDA"
	cQuryRela += " , SUM(COFI_PRODU) COFI_PRODU"
	cQuryRela += " , SUM(COFI_DEVOL) COFI_DEVOL"
	cQuryRela += " , SUM(IPI__COMPR) IPI__COMPR"
	cQuryRela += " , SUM(IPI__VENDA) IPI__VENDA"
	cQuryRela += " , SUM(IPI__PRODU) IPI__PRODU"
	cQuryRela += " , SUM(IPI__DEVOL) IPI__DEVOL"
	cQuryRela += " , SUM(ICMS_COMPR) ICMS_COMPR"
	cQuryRela += " , SUM(ICMS_VENDA) ICMS_VENDA"
	cQuryRela += " , SUM(ICMS_PRODU) ICMS_PRODU"
	cQuryRela += " , SUM(ICMS_DEVOL) ICMS_DEVOL"
	cQuryRela += " , B1_XGRUPO"
	cQuryRela += " FROM " + cViewFin5
	cQuryRela += " INNER JOIN " + RetSqlName("SB1")
	cQuryRela += " ON B1_FILIAL = '" + xfilial("SB1") + "'"
	cQuryRela += " AND B1_COD = PRODUTO"
	cQuryRela += " AND " + RetSqlName("SB1") + ".D_E_L_E_T_ = ' '"
	cQuryRela += " GROUP BY PRODUTO, DESC_PRODU"
	cQuryRela += " , GRUPO, DESC_GRUPO"
	cQuryRela += " , FAMILIA, DESC_FAMIL, ESTADO, DOCUMENTO, B1_XGRUPO"
	cQuryRela += ")"
	MemoWrite("cViewFin6.SQL",cQuryRela)
	TcSqlExec( cQuryRela)
	
	cQuryRela := " SELECT * FROM " + cViewFin6
	cQuryRela += " WHERE QTDE_VENDA > 0 OR QTDE_DEVOL > 0"
	/*
	If ! Empty(cGrupInic) .Or. ! Empty(cGrupFina)
		cQuryRela += " AND GRUPO >= '" + cGrupInic + "'"
		cQuryRela += " AND GRUPO <= '" + cGrupFina + "'"
	EndIf
	If !Empty(cListFami)
		cQuryRela += " 	AND FAMILIA IN ('" + StrTran(cListFami,";","','") + "')"																		
	EndIf
	If ! Empty(cEstaRela)
		cQuryRela += " AND ESTADO IN ('" + StrTran(cEstaRela,";","','") + "')"
	EndIf
	*/
	Do Case
		Case nTipoAgru == 1
		cQuryRela += " ORDER BY ESTADO + GRUPO + DOCUMENTO"
		Case nTipoAgru == 2
		cQuryRela += " ORDER BY ESTADO + FAMILIA + DOCUMENTO"
		Case nTipoAgru == 3
		cQuryRela += " ORDER BY FAMILIA + ESTADO + DOCUMENTO"
	EndCase
	
	MemoWrite("cRelaFina.SQL",cQuryRela)
	dbUseArea(.T., "TOPCONN", TCGenQry(NIL,NIL,cQuryRela), "TRB_001" ,.F., .T. )
	
	TRB_001->(dbGoTop())
	DbEval( {|x| nQtdeRegi ++ },,{ || ! Eof() })
	DbGotop()
	ProcRegua(nQtdeRegi)

	cGru1Inic := ""
	cGru2Inic := ""

	If nTipoRela <> 1
		cTitulo := "Relatório de Faturamento x Compra sem impostos (PIS, Cofins, IPI e ICMS)" 
	EndIf

	TRB_001->(dbGoTop())
	While ! TRB_001->(Eof())
		If nLin > nMaxLin
			If nPagina > 1
				oPrint:EndPage()
				oPrint:StartPage()
			EndIf
			RPFAT01D(oPrint,dEmisInic,dEmisFina,nGeraDcto)
			nLin := 0140
		EndIf

		Do Case
			Case nTipoAgru == 1
				cGru1Atua := TRB_001->ESTADO
				//---> REMOVIDO compatibiliza??o para vers?o 12.1.25.
				//cDes1Atua := Posicione("SX5",1,xfilial("SX5") + "12" + TRB_001->ESTADO,"X5_DESCRI")
				aSX5 := FWGetSX5( '12', PadR( RTrim( TRB_001->ESTADO ), 6 ) )
				cDes1Atua := aSX5[1,4]
				cTex1Atua := "Estado"
				cGru2Atua := TRB_001->GRUPO
				cDes2Atua := TRB_001->DESC_GRUPO
				cTex2Atua := "Grupo"
			Case nTipoAgru == 2
				cGru1Atua := TRB_001->ESTADO
				//---> REMOVIDO compatibiliza??o para vers?o 12.1.25.
				//cDes1Atua := Posicione("SX5",1,xfilial("SX5") + "12" + TRB_001->ESTADO,"X5_DESCRI")
				aSX5 := FWGetSX5( '12', PadR( RTrim( TRB_001->ESTADO ), 6 ) )
				cDes1Atua := aSX5[1,4]				
				cTex1Atua := "Estado"
				cGru2Atua := TRB_001->FAMILIA
				cDes2Atua := TRB_001->DESC_FAMIL
				cTex2Atua := "Família"
			Case nTipoAgru == 3
				cGru1Atua := TRB_001->FAMILIA
				cDes1Atua := TRB_001->DESC_FAMIL
				cTex1Atua := "Família"
				cGru2Atua := TRB_001->ESTADO
				//---> REMOVIDO compatibiliza??o para vers?o 12.1.25.
				//cDes2Atua := Posicione("SX5",1,xfilial("SX5") + "12" + TRB_001->ESTADO,"X5_DESCRI")
				aSX5 := FWGetSX5( '12', PadR( RTrim( TRB_001->ESTADO ), 6 ) )
				cDes2Atua := aSX5[1,4]
				cTex2Atua := "Estado"
		EndCase
	
		If cGru1Inic <> cGru1Atua .Or. cGru2Inic <> cGru2Atua
			If nTotaQtde > 0
				RPFAT01I (oPrint, nLin,nCol - 0020,nLin + 0015,nColFim)
				nLin += 0010
				oPrint:Say (nLin, 0040,"Total" ,oFont10B)	// Total
				oPrint:Say (nLin, 0280,RPFAT01J(Alltrim(Transform(nTotaQtde,"@E 9,999,999,999.99")))	,oFont09B)	// Quantidade Total
				oPrint:Say (nLin, 0410,RPFAT01J(Alltrim(Transform(nTotaCust,"@E 9,999,999,999.99")))	,oFont09B)	// Custo Total
				oPrint:Say (nLin, 0510,Alltrim(Transform(nTotaCust / nTotaQtde,"@E 999.99")) 						,oFont09B)	// Custo Medio Total
				oPrint:Say (nLin, 0565,RPFAT01J(Alltrim(Transform(nTotaRece,"@E 9,999,999,999.99")))	,oFont09B)	// Receita Total
				oPrint:Say (nLin, 0660,Alltrim(Transform(nTotaRece / nTotaQtde,"@E 999.99"))			 			,oFont09B)	// PV Medio Total
				oPrint:Say (nLin, 0710,RPFAT01J(Alltrim(Transform((nTotaRece - nTotaCust) ,"@E 9,999,999,999.99"))) 	,oFont09B)	// Margem Total
				oPrint:Say (nLin, 0790,Alltrim(Transform((nTotaRece - nTotaCust) * 100 / nTotaCust,"@E 999.99")) + " %"				,oFont09B)	// Percentual Total
				nTotaQtde := nTotaCust := nTotaRece := 0
				nLin += 0020
			EndIf
			
			If cGru1Inic <> cGru1Atua
				// Box 1a. Quebra
				RPFAT01I(oPrint, nLin,nCol - 0040,nLin + 0015,nColFim - 0440)
				oPrint:FillRect({nLin + 0001,nCol - 0039,nLin + 0014,nColFim - 0441 },oBrush2)	// Pinta o Box do Cabecalho da Cor Cinza Claro
				nLin += 0010
				oPrint:Say (nLin, 0020,cTex1Atua,oFont10B)
				oPrint:Say (nLin, 0100,cGru1Atua + " - " + AllTrim(cDes1Atua),oFont08)
				nLin += 0020
				cGru1Inic := cGru1Atua	
			EndIf

			// Box 2a. Quebra
			RPFAT01I (oPrint, nLin,nCol - 0040,nLin + 0015,nColFim - 0440)
			nLin += 0010
			oPrint:Say (nLin, 0020,cTex2Atua,oFont10B)
			oPrint:Say (nLin, 0100,cGru2Atua + " - " + Alltrim(cDes2Atua),oFont08)
			nLin += 0020
			cGru2Inic := cGru2Atua

		EndIf

		If TRB_001->QTDE_VENDA > 0
			nCustVend := IIf(TRB_001->B1_XGRUPO == "1",LastCost(cFiliInic,cFiliFina,TRB_001->PRODUTO,nTipoRela) * TRB_001->QTDE_VENDA,TRB_001->CUST_VENDA)
			oPrint:Say (nLin, 0010,TRB_001->PRODUTO ,oFont07)
			If nGeraDcto == 1
				oPrint:Say (nLin, 0070,Substr(Alltrim(TRB_001->DESC_PRODU),1,20),oFont07)
				oPrint:Say (nLin, 0200,TRB_001->DOCUMENTO,oFont07)
			Else
				oPrint:Say (nLin, 0070,Substr(Alltrim(TRB_001->DESC_PRODU),1,30) ,oFont07)
			EndIf
			If nTipoRela == 1 //com impostos
				nValoRece := TRB_001->TOTL_VENDA + TRB_001->IPI__VENDA
				If TRB_001->B1_XGRUPO <> "1"
					If TRB_001->IPI__PRODU > 0
						nValoIIPI := 0 
					Else
						nValoIIPI := nCustVend * (TRB_001->IPI__COMPR / TRB_001->TOTL_COMPR)
					EndIf	
					If TRB_001->ICMS_PRODU > 0
						nValoICMS := 0 
					Else	
						nValoICMS := nCustVend * (TRB_001->ICMS_COMPR / TRB_001->TOTL_COMPR)
					EndIf
					If TRB_001->PIS__PRODU > 0
						nValoPPIS := 0 
					Else	
						nValoPPIS := nCustVend * (TRB_001->PIS__COMPR / TRB_001->TOTL_COMPR)
					EndIf
					If TRB_001->COFI_PRODU > 0	 
						nValoCofi := 0 
					Else	
						nValoCofi := nCustVend * (TRB_001->COFI_COMPR / TRB_001->TOTL_COMPR)
					EndIf	
					nCustVend += (nValoIIPI + nValoICMS + nValoPPIS + nValoCofi)
				EndIf
			Else
				nValoRece := TRB_001->TOTL_VENDA - TRB_001->ICMS_VENDA - TRB_001->PIS__VENDA - TRB_001->COFI_VENDA
			EndIf
	
			nPrVeMedi := nValoRece / TRB_001->QTDE_VENDA
			nMargVend := nValoRece - nCustVend
			nPercPart := nMargVend * 100 / TRB_001->CUST_VENDA
			If nTipoRela == 1
				nUltiComp := (TRB_001->TOTL_COMPR + TRB_001->IPI__COMPR) / TRB_001->QTDE_COMPR
			Else
				nUltiComp := (TRB_001->TOTL_COMPR - TRB_001->ICMS_COMPR - TRB_001->PIS__COMPR - TRB_001->COFI_COMPR) / TRB_001->QTDE_COMPR
			EndIf	
	
			oPrint:Say (nLin, 0280,RPFAT01J(Alltrim(Transform(TRB_001->QTDE_VENDA ,"@E 9,999,999,999.99")))	,oFont07)	// Quantidade
			oPrint:Say (nLin, 0330,IIF(nUltiComp <> 0, RPFAT01J(Alltrim(Transform(nUltiComp ,"@E 9,999,999,999.99"))), Space(15)+"N/A")		,oFont07)	// Ult. Compra
			oPrint:Say (nLin, 0410,RPFAT01J(Alltrim(Transform(nCustVend,"@E 9,999,999,999.99")))		,oFont07)	// Custo Total
			oPrint:Say (nLin, 0510,Alltrim(Transform(nCustVend / TRB_001->QTDE_VENDA ,"@E 999.99"))	 						,oFont07)	// Custo Médio
			oPrint:Say (nLin, 0565,RPFAT01J(Alltrim(Transform(nValoRece,"@E 9,999,999,999.99")))		,oFont07)	// Receita Total
			oPrint:Say (nLin, 0660,Alltrim(Transform(nPrVeMedi,"@E 999.99"))							,oFont07)	// PV Médio
			oPrint:Say (nLin, 0710,RPFAT01J(Alltrim(Transform(nMargVend,"@E 9,999,999,999.99")))		,oFont07)	// Margem
			oPrint:Say (nLin, 0790,Alltrim(Transform(nPercPart,"@E 999.99")) + " %"						,oFont07)	// (%)
			nLin += 0020
		EndIf
		
		//Totalizadores para a 2a. Quebra
		nTotaQtde += TRB_001->QTDE_VENDA
		nTotaCust += nCustVend
		nTotaRece += nValoRece
		
		// Variaveis Totalizadoras 
		nQtdeGera += TRB_001->QTDE_VENDA
		nCustGera += nCustVend
		nReceGera += nValoRece
		nQtdeDevo += TRB_001->QTDE_DEVOL
		nCustDevo += TRB_001->CUST_DEVOL
		nValoDevo += TRB_001->TOTL_DEVOL

		
		TRB_001->(DbSkip())
		IncProc("Gerando Relatório " + LTrim(Str(nContRela ++)))
	End
	TRB_001->(dbCloseArea())
	
	If nTotaQtde > 0 
		RPFAT01I (oPrint, nLin,nCol - 0020,nLin + 0015,nColFim)
		nLin += 0010
		oPrint:Say (nLin, 0040,"Total" ,oFont10B)	
		oPrint:Say (nLin, 0280,RPFAT01J(Alltrim(Transform(nTotaQtde,"@E 9,999,999,999.99")))	,oFont09B)	// Quantidade Total
		oPrint:Say (nLin, 0410,RPFAT01J(Alltrim(Transform(nTotaCust,"@E 9,999,999,999.99")))	,oFont09B)	// Custo Total
		oPrint:Say (nLin, 0510,Alltrim(Transform(nTotaCust / nTotaQtde,"@E 999.99")) 						,oFont09B)	// Custo Medio Total
		oPrint:Say (nLin, 0565,RPFAT01J(Alltrim(Transform(nTotaRece,"@E 9,999,999,999.99")))	,oFont09B)	// Receita Total
		oPrint:Say (nLin, 0660,Alltrim(Transform(nTotaRece / nTotaQtde,"@E 999.99"))			 			,oFont09B)	// PV Medio Total
		oPrint:Say (nLin, 0710,RPFAT01J(Alltrim(Transform((nTotaRece - nTotaCust) ,"@E 9,999,999,999.99"))) 	,oFont09B)	// Margem Total
		oPrint:Say (nLin, 0790,Alltrim(Transform((nTotaRece - nTotaCust) * 100 / nTotaCust,"@E 999.99")) + " %"				,oFont09B)	// Percentual Total
		nLin += 0030
	EndIf

	If nQtdeGera > 0

		// Box
		RPFAT01I (oPrint, nLin,nCol - 0020,nLin + 0045,nColFim)
		oPrint:FillRect({nLin + 0001,nCol - 0019,nLin + 0044,nColFim - 0001 },oBrush2)	// Pinta o Box do Cabecalho da Cor Cinza Claro
	
		// Total por Período
		nLin += 0010
		oPrint:Say (nLin, 0040,"Total do Período" ,oFont10B)
		oPrint:Say (nLin, 0280,"(+)" + RPFAT01J(Alltrim(Transform(nQtdeGera,"@E 9,999,999,999.99")))	,oFont10B)
		oPrint:Say (nLin, 0410,"(+)" + RPFAT01J(Alltrim(Transform(nCustGera,"@E 9,999,999,999.99")))	,oFont10B)
		oPrint:Say (nLin, 0510, Alltrim(Transform(nCustGera / nQTdeGera,"@E 999.99"))									,oFont10B)
		oPrint:Say (nLin, 0565,"(+)" + RPFAT01J(Alltrim(Transform(nReceGera,"@E 9,999,999,999.99")))	,oFont10B)
		oPrint:Say (nLin, 0660,Alltrim(Transform(nReceGera / nQtdeGera,"@E 999.99"))									,oFont10B)
		oPrint:Say (nLin, 0710,RPFAT01J(Alltrim(Transform(nReceGera - nCustGera,"@E 9,999,999,999.99")))		,oFont10B)
		oPrint:Say (nLin, 0790,Alltrim(Transform((nReceGera - nCustGera) * 100 / nCustGera,"@E 999.99")) + " %"								,oFont10B)

		nLin += 0025
	
		//Devoluções
		oPrint:Say (nLin, 0040,"Devoluções" ,oFont10B)
		oPrint:Say (nLin, 0280,"(-)  " + RPFAT01J(Alltrim(Transform(nQtdeDevo,"@E 9,999,999,999.99")))	,oFont10B)
		oPrint:Say (nLin, 0410,"(-)  " + RPFAT01J(Alltrim(Transform(nCustDevo,"@E 9,999,999,999.99")))	,oFont10B)
		oPrint:Say (nLin, 0510,Alltrim(Transform(nCustDevo / nQtdeDevo,"@E 999.99"))												,oFont10B)
		oPrint:Say (nLin, 0565,"(-)  " + RPFAT01J(Alltrim(Transform(nValoDevo ,"@E 9,999,999,999.99")))	,oFont10B)
		oPrint:Say (nLin, 0660,Alltrim(Transform(nValoDevo / nQtdeDevo,"@E 999.99"))					,oFont10B)
		oPrint:Say (nLin, 0710,RPFAT01J(Alltrim(Transform((nValoDevo - nCustDevo),"@E 9,999,999,999.99")))						,oFont10B)
		//oPrint:Say (nLin, 0790,"  "+Alltrim(Transform(0 ,"@E 999.99")) + " %"												,oFont10B)
		nLin += 0025
	
		// Resultado
		oPrint:Say (nLin, 0040,"Resultado" ,oFont10B)
		oPrint:Say (nLin, 0280,"(=)" + RPFAT01J(Alltrim(Transform(nQtdeGera - nQtdeDevo,"@E 9,999,999,999.99"))),oFont10B)
		oPrint:Say (nLin, 0410,"(=)" + RPFAT01J(Alltrim(Transform(nCustGera - nCustDevo,"@E 9,999,999,999.99"))),oFont10B)
		oPrint:Say (nLin, 0510,Alltrim(Transform((nCustGera - nCustDevo) / (nQtdeGera - nQtdeDevo),"@E 999.99")),oFont10B)
		oPrint:Say (nLin, 0565,"(=)"+ RPFAT01J(Alltrim(Transform(nReceGera - nValoDevo,"@E 9,999,999,999.99")))	,oFont10B)
		oPrint:Say (nLin, 0660,Alltrim(Transform((nReceGera - nValoDevo) / (nQtdeGera - nQtdeDevo),"@E 999.99")),oFont10B)
		oPrint:Say (nLin, 0710,RPFAT01J(Alltrim(Transform((nReceGera - nValoDevo)  -  (nCustGera - nCustDevo) ,"@E 9,999,999,999.99"))),oFont10B)
		oPrint:Say (nLin, 0790,Alltrim(Transform(((nReceGera - nValoDevo)  - (nCustGera - nCustDevo))  * 100 / (nCustGera - nCustDevo),"@E 999.99")) + " %"														,oFont10B)
		oPrint:EndPage()
		oPrint:Preview()
	EndIf
Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ?RPFAT01D ?Autor ?Joao Goncalves de Oliveira ?Data ?10/01/19 ³±?±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ?Imprime cabeçalho do relatório resumo		 				   ³±?±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ?RPFAT01D(ExpO1)												   ³±?±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros?ExpO1 - Objeto de impressão 									   ³±?±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±³ Retorno   ?Nenhum 														   ³±?±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RPFAT01D(oPrint,dEmisInic,dEmisFina,nGeraDcto)

	// < nRow>, < nCol>, < nBottom>, < nRight>, [ cPixel]
	oPrint:SayAlign  (0030,0060,cTitulo,oFont14B,480,14,CLR_RED,2,2)
	oPrint:SayBitmap (0017,0010, cBitmap,0120,0060)	// < nRow>, < nCol>, < cBitmap>, [ nWidth], [ nHeight]

	oPrint:Say (0070, 0200,"Período de " + DtoC(dEmisInic) + " a " + DtoC(dEmisFina) ,oFont11,,nClrAzul)
	// Página
	oPrint:Say (0070, 0500,"Página: " ,oFont12B,,nClrVerm)
	oPrint:Say (0070, 0540,PadL(Alltrim(Str(nPagina++)),3,"0"),oFont12B,,nClrVerm)
	oPrint:Line(0080, 0010, 0080, 0580)	// 1?Linha Horizontal do Cabeçalho
	oPrint:Line(0085, 0010, 0085, 0580)	// 2?Linha Horizontal do Cabeçalho
	oPrint:Say (0100, 0010,"Replas Indústria e Comércio de Resinas Plásticas Ltda" ,oFont10B,,nClrAzul)

	nLin := 0110

	// Box Cabeçalho Principal
	oPrint:FillRect({nLin,nCol - 0040,nLin + 0015,nColFim },oBrush2)	// Pinta o Box do Cabecalho da Cor Cinza Claro
	RPFAT01I (oPrint, nLin,nCol - 0040,nLin + 0015,nColFim)
	
	nLin += 0010
	If nGeraDcto == 1
	
		oPrint:Say (nLin, 0010,"Produto",oFont10B)
		oPrint:Say (nLin, 0070,"Descrição",oFont10B)
		oPrint:Say (nLin, 0205,"Documento",oFont10B)

	EndIf
	oPrint:Say (nLin, 0285,"Quantidade" ,oFont10B)
	oPrint:Say (nLin, 0335,"Última Compra" ,oFont10B)
	oPrint:Say (nLin, 0410,"Custo Total" ,oFont10B)
	oPrint:Say (nLin, 0490,"Custo Médio" ,oFont10B)
	oPrint:Say (nLin, 0570,"Receita Total" ,oFont10B)
	oPrint:Say (nLin, 0650,"PV Médio" ,oFont10B)
	oPrint:Say (nLin, 0725,"Margem" ,oFont10B)
	oPrint:Say (nLin, 0795,"(%)" ,oFont10B)

	nLin += 0020

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ?RPFAT01E ?Autor ?Joao Goncalves de Oliveira ?Data ?10/01/19 ³±?±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ?Exclui views criadas anteriormente 				   	           ³±?±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ?RPFAT01E()								  		               ³±?±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros?Nenhum 														   ³±?±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±³ Retorno   ?Nenhum 														   ³±?±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RPFAT01E()
	Local aArea := GetArea()
	Local cQuryList := ""
	Local cRefeInic := "RPFAT01A"
	Local i := 0
	Local aView := {}
	Local cExpr := ''

	cQuryList := "SELECT name FROM sysobjects where Substring(name,1,"
	cQuryList += Str(Len(cRefeInic)) + ") IN ('" + cRefeInic + "') and type = 'V'"

	TcQuery cQuryList NEW ALIAS "TRB_001A"

	dbSelectArea("TRB_001A")
	While !EOF()
		AAdd(aView,RTrim(TRB_001A->name))
		dbSkip()
	End
	dbCloseArea()

	For i:=1 To Len(aView)
		cExpr := 'DROP VIEW '+aView[i]
		TcSqlExec(cExpr)
		//lRet := TCDelFile(aView[i])
	Next i
	
	RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Programa  ?RPFAT01F   ³Autor ?João Gonçalves de Oliveira?Data ?9/01/2018  ³±?±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Descricao ?Executa Funcao para Seleção das Famílias 		 				  ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Sintaxe	 ?U_RPFAT01F()									 		 			 ³±?±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Parametros?ExpN1 - 1 = Inicializador Padrao; 2 = Validacao 					 ³±?±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Retorno   ?ExpL1 - Verdadeiro Caso tenha sido selecionada família 			 ³±?±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*
User Function RPFAT01F(nOpcaGrav)

Local cArquTrab := "" 
Local cListGrup := ""
Local aEstrCons := {}
Local aCmpoBrow := {}
Local oDlgLocal 
Local cQuryCons := '' 
Local aButtons  := {}
Local cMvPar := "" 


Private lInverte := .F.
Private cMarkBrow := GetMark()   
Private oMarkBrow

	aAdd( aButtons, {"Mark", {|| U_RPFAT01H()}, "Marca/Desmarca todos", "Marca/Desmarca todos" , {|| .T.}} )   

	aAdd(aEstrCons,{"OK"  ,"C",02,0})
	aAdd(aEstrCons,{"COD" ,"C",06,0})
	aAdd(aEstrCons,{"DESC","C",40,0})
	
	cArquTrab := Criatrab(aEstrCons,.T.)
	dbUseARea(.t.,,cArquTrab,"TRB_002")
	
	cQuryCons := " SELECT * FROM " + RetSqlName("SX5")
	cQuryCons += " WHERE X5_TABELA = 'V0' AND D_E_L_E_T_ = ' '"
	cQuryCons += " ORDER BY X5_CHAVE"
	
	IF Select('TRB_003') > 1
		TRB_003->(dbCloseArea())
	ENDIF
	
	TcQuery cQuryCons NEW ALIAS "TRB_003"
	TRB_003->(dbGotop())
	
	While ! TRB_003->(Eof())	
		RecLock("TRB_002",.T.)		
		TRB_002->COD     :=  TRB_003->X5_CHAVE		
		TRB_002->DESC    :=  TRB_003->X5_DESCRI			
		MsunLock()	
		TRB_003->(DbSkip())
	Enddo
	
	//Define quais colunas (campos da TRB_002) serao exibidas na MsSelect
	aCmpoBrow := {{"OK"	 ,,"Mark"     ,"@!"},;
				  {"COD" ,,"Codigo"   ,"@!"},;
				  {"DESC",,"Descrição","@1!"}}

	//Cria uma Dialog
	DEFINE MSDIALOG oDlgLocal TITLE "Seleção de Famílias" From 9,0 To 315,800 PIXEL
	TRB_002->(dbGotop())
	
	oMarkBrow := MsSelect():New("TRB_002","OK","",aCmpoBrow,@lInverte,@cMarkBrow,{37,5,150,400},,,,,)
	oMarkBrow:bMark := {| | RPFAT01G()} //Exibe a Dialog
	ACTIVATE MSDIALOG oDlgLocal CENTERED ON INIT EnchoiceBar(oDlgLocal,{|| oDlgLocal:End()},{|| oDlgLocal:End()},, @aButtons)
	
	TRB_002->(dbGoTop())
	While ! TRB_002->(EOF())
		If Marked("OK")	
			cListGrup += AllTrim(TRB_002->COD) + ";" 
		Endif
		TRB_002->(DBSKIP())
	End
	cListGrup := Substr(cListGrup,1,Len(cListGrup) - 1)
	TRB_002->(DbCloseArea())
	TRB_003->(dbCloseArea())
	
	Iif(File(cArquTrab + GetDBExtension()),FErase(cArquTrab  + GetDBExtension()) ,Nil)
	
	mv_par05 := cMvPar := cListGrup
Return(IIf(nOpcaGrav == 2,.T.,cListGrup))
*/

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Programa  ?RPFAT01G   ³Autor ?João Gonçalves de Oliveira?Data ?9/01/2018  ³±?±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Descricao ?Executa Marcação de um registro 					 				  ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Sintaxe	 ?U_RPFAT01G()									 		 			 ³±?±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Parametros?Nenhum 															 ³±?±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Retorno   ?Nenhum 	 														 ³±?±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*
Static Function RPFAT01G()

RecLock("TRB_002",.F.)
If Marked("OK")	
	TRB_002->OK := cMarkBrow
Else	
	TRB_002->OK := ""
Endif             
MsUnlock()
oMarkBrow:oBrowse:Refresh()

Return 
*/
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Programa  ?RPFAT01H   ³Autor ?João Gonçalves de Oliveira?Data ?9/01/2018      ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Descricao ?Executa Marcação de todos os registros			 				  ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Sintaxe	 ?U_RPFAT01H()									 		 			 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Parametros?Nenhum 															 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Retorno   ?Nenhum 	 														 ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function RPFAT01H()

TRB_002->(dbGoTop())
While ! TRB_002->(Eof())
	RecLock("TRB_002",.F.)
	If Marked("OK")	
		TRB_002->OK := ""
	Else	
		TRB_002->OK := cMarkBrow
	Endif
	MsUnlock()
	TRB_002->(Dbskip())             
End			

TRB_002->(dbGoTop())
oMarkBrow:oBrowse:Refresh()

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Programa  ?RPFAT01I   ³Autor ?João Gonçalves de Oliveira?Data ?5/02/2018      ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Descricao ?Desenha um box sem preenchimento 				 				      ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Sintaxe	 ?U_RPFAT01I(ExpO1,ExpN2,ExpN3,ExpN4,ExpN5)	 		 			     ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Parametros?ExpO1 - Objeto de impressão 										 ³±?
±±?          ?ExpN2 - Linha inicial 											     ³±?
±±?		     ?ExpN3 - Coluna inicial 											     ³±?
±±?		     ?ExpN4 - Linha final  											         ³±?
±±?          ?ExpN5 - Coluna final  											     ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Retorno   ?Nenhum 	 														 ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RPFAT01I(oPrint,nLinhInic,nColuInic,nLinhFina,nColuFina) 

	oPrint:Line(nLinhInic,nColuInic,nLinhInic,nColuFina)
	oPrint:Line(nLinhFina,nColuInic,nLinhFina,nColuFina)
	oPrint:Line(nLinhInic,nColuInic,nLinhFina,nColuInic)
	oPrint:Line(nLinhInic,nColuFina,nLinhFina,nColuFina)

Return



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Programa  ?RPFAT01J   ³Autor ?João Gonçalves de Oliveira?Data ?5/02/2018      ³±? 
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Descricao ?Alinha campo valor para impressão 								  ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Sintaxe	 ?U_RPFAT01J(ExpC1	 		 										 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Parametros?ExpC1 - Valor a ser alinhado 									     ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Retorno   ?ExpC2 - Valor alinhado 											 ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RPFAT01J(cValor)

	Local cValor2	:= AllTrim(cValor)
	cValor2	:= Replicate(" ",20 - (Len(cValor2) * 2)) + cValor2
	If Len(AllTrim(cValor2)) >= 8
		cValor2	:= " " + cValor2
	EndIf

	Return cValor2

/*
+------------------------------------------------------------------+
| Rotina | SelectUF | Autor | Robson Gonçalves | Data | 28/01/2020 |
+------------------------------------------------------------------+
| Descr. | Rotina para mostrar os estados brasileiros e permitir   |
|        | o usuário fazer a seleção dos estados que deseja        |
|        | processar.                                              |
+------------------------------------------------------------------+
| Uso    | Replas                                                  |
+------------------------------------------------------------------+
*/
User Function SelectUF(nOpcaGrav)
	Local cArquTrab := "" 
	Local cListUF := ""
	Local aEstrCons := {}
	Local aCmpoBrow := {}
	Local oDlgLocal 
	Local cQuryCons := '' 
	Local aButtons  := {}

	Private lInverte := .F.
	Private cMarkBrow := GetMark()   
	Private oMarkBrow

	aAdd( aButtons, {"Mark", {|| markAll()}, "Marca/Desmarca todos", "Marca/Desmarca todos" , {|| .T.}} )   

	aAdd(aEstrCons,{"OK"    ,"C",02,0})
	aAdd(aEstrCons,{"UF"    ,"C",02,0})
	aAdd(aEstrCons,{"ESTADO","C",40,0})
	
	//cArquTrab := Criatrab(aEstrCons,.T.)
	//dbUseARea(.t.,,cArquTrab,"TRB2")

	// MIGRACAO BD - NOVA ESTRUTURA DE TABELA TEMPORÁRIA
	_cArq      := "TRB2"
	_cChaveInd := GETNEXTALIAS()
	oTable := FwTemporaryTable():New( _cArq)
	oTable:SetFields(aEstrCons)
	oTable:Create()
	DbSelectArea(_cArq)	
	
	cQuryCons := " SELECT * FROM " + RetSqlName("SX5")
	cQuryCons += " WHERE X5_TABELA = '12' AND D_E_L_E_T_ = ' '"
	cQuryCons += " ORDER BY X5_CHAVE"
	
	IF Select('TRB3') > 1
		TRB3->(dbCloseArea())
	ENDIF
	
	TcQuery cQuryCons NEW ALIAS "TRB3"
	TRB3->(dbGotop())
	
	While ! TRB3->(Eof())	
		RecLock("TRB2",.T.)
		TRB2->UF     := TRB3->X5_CHAVE
		TRB2->ESTADO := TRB3->X5_DESCRI
		MsUnLock()
		TRB3->(DbSkip())
	Enddo
	
	//Define quais colunas (campos da TRB_002) serao exibidas na MsSelect
	aCmpoBrow := {{"OK"	  ,,"Mark"  ,"@!"},;
					  {"UF"    ,,"UF"    ,"@!"},;
					  {"ESTADO",,"Estado","@!"}}

	//Cria uma Dialog
	DEFINE MSDIALOG oDlgLocal TITLE "Seleção de Estados" From 9,0 To 315,800 PIXEL
	TRB2->(dbGotop())
	
	oMarkBrow := MsSelect():New("TRB2","OK","",aCmpoBrow,@lInverte,@cMarkBrow,{37,5,150,400},,,,,)
	oMarkBrow:bMark := {| | markOnOff()} //Exibe a Dialog
	ACTIVATE MSDIALOG oDlgLocal CENTERED ON INIT EnchoiceBar(oDlgLocal,{|| oDlgLocal:End()},{|| oDlgLocal:End()},, @aButtons)
	
	TRB2->(dbGoTop())
	While ! TRB2->(EOF())
		If Marked("OK")	
			cListUF += AllTrim(TRB2->UF) + ";" 
		Endif
		TRB2->(DBSKIP())
	End
	cListUF := Substr(cListUF,1,Len(cListUF) - 1)
	TRB2->(DbCloseArea())
	TRB3->(dbCloseArea())
	
	Iif(File(cArquTrab + GetDBExtension()),FErase(cArquTrab  + GetDBExtension()) ,Nil)
	
	mv_par06 := cListUF
Return(IIf(nOpcaGrav == 2,.T.,cListUF))

/*
+------------------------------------------------------------------+
| Rotina | markAll  | Autor | Robson Gonçalves | Data | 28/01/2020 |
+------------------------------------------------------------------+
| Descr. | Rotina que permite o usuário marcar ou desmarcar todos  |
|        | registros em uma única vez.                             |
|        |                                                         |
+------------------------------------------------------------------+
| Uso    | Replas                                                  |
+------------------------------------------------------------------+
*/
Static Function markAll()
	TRB2->(dbGoTop())
	While ! TRB2->(Eof())
		RecLock("TRB2",.F.)
		If Marked("OK")
			TRB2->OK := ""
		Else
			TRB2->OK := cMarkBrow
		Endif
		MsUnlock()
		TRB2->(Dbskip())
	End
	TRB2->(dbGoTop())
	oMarkBrow:oBrowse:Refresh()
Return

/*
+------------------------------------------------------------------+
| Rotina | markOnOff| Autor | Robson Gonçalves | Data | 28/01/2020 |
+------------------------------------------------------------------+
| Descr. | Rotina que permite o usuário marcar ou desmarcar os     |
|        | registros que deseja.                                   |
|        |                                                         |
+------------------------------------------------------------------+
| Uso    | Replas                                                  |
+------------------------------------------------------------------+
*/
Static Function markOnOff()
	RecLock("TRB2",.F.)
	If Marked("OK")	
		TRB2->OK := cMarkBrow
	Else	
		TRB2->OK := ""
	Endif
	MsUnlock()
	oMarkBrow:oBrowse:Refresh()
Return 

/*
+------------------------------------------------------------------+
| Rotina | lastCost | Autor | Robson Gonçalves | Data | 30/01/2020 |
+------------------------------------------------------------------+
| Descr. | Rotina que busca o último custo da matéria prima.       |
|        |                                                         |
|        |                                                         |
+------------------------------------------------------------------+
| Uso    | Replas                                                  |
+------------------------------------------------------------------+
*/
Static Function lastCost(cFiliInic,cFiliFina,cProduto,nTipoRela)
	Local nUltCusto := 0
	Local nQtdCusto := 0
	Local cQry := ''
	Local cTRB := ''
	
	// Buscar a última OP do produto em questão para localizar a MP.
	// Com esta MP em mãos, buscar a sua última NF, 
	// não importa a data e considerar este como último custo.
	
	cQry := " SELECT D1_QUANT, D1_CUSTO, D1_VALIPI, D1_VALICM, D1_VALIMP5, D1_VALIMP6"
	cQry += " FROM " + RetSqlName("SD1") + " SD1_B "
	cQry += " WHERE SD1_B.D1_FILIAL >= '0101'"
	cQry += " AND SD1_B.D1_FILIAL <= '0103'"
	cQry += " AND SD1_B.D1_TES = '040'"
	cQry += " AND SD1_B.D_E_L_E_T_ = ' '"
	cQry += " AND SD1_B.D1_COD IN ("
	cQry += "              SELECT D3_COD"
	cQry += "                     FROM   "+RetSqlName("SD3") + " SD3_B "
	cQry += "                           INNER JOIN " + RetSqlName("SB1")+" SB1 "
	cQry += "                                   ON B1_FILIAL = '"+ xFilial("SB1") +"'"
	cQry += "                                      AND B1_COD = SD3_B.D3_COD "
	cQry += "                                      AND B1_TIPO = 'MP' "
	cQry += "                                      AND SB1.D_E_L_E_T_ = ' ' "
	cQry += "                     WHERE SD3_B.D3_FILIAL >= '    '"
	cQry += "                           AND SD3_B.D3_FILIAL <= 'ZZZZ'"
	cQry += "                           AND SD3_B.D3_OP = ("
	cQry += "                           SELECT Max(SD3_A.D3_OP) D3_OP"
	cQry += "                           FROM   " + RetSqlName("SD3") + " SD3_A "
	cQry += "                           WHERE  SD3_A.D3_FILIAL >= '0101'"
	cQry += "                           	   AND SD3_A.D3_FILIAL <= '0103'"
	cQry += "                                  AND SD3_A.D3_COD = '" + cProduto + "'"
	cQry += "                                  AND SD3_A.D_E_L_E_T_ = ' ') )"

	cTRB := GetNextAlias()
	dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQry),cTRB,.F.,.T.)
	While ! (cTRB)->(Eof())
		nQtdCusto += (cTRB)->D1_QUANT
		If nTipoRela == 1
			nUltCusto += (cTRB)->D1_CUSTO + (cTRB)->D1_VALIPI;
			 + (cTRB)->D1_VALICM + (cTRB)->D1_VALIMP5 + (cTRB)->D1_VALIMP6
		Else	
			nUltCusto += (cTRB)->D1_CUSTO
		EndIf	
		(cTRB)->(dbSkip())
	End
	nCustUnit := nUltCusto / nQtdCusto
	(cTRB)->( dbCloseArea() )

	/*
	If AllTrim(cProduto) == "MS17E066500420" .And. nCustUnit == 0  
		Copytoclipboard(cqry)
		// Mudar a query do padrão MsSQLQuery para AnsiQquery quando necessário.
		MsgAlert(cQry)
	EndIf
	*/	
		
	// Caso não encontre nota fiscal de entrada da matéria prima busca do saldo em esotque	
	If nCustUnit == 0
		cQry := " SELECT 1 D1_QUANT, B2_CM1 D1_CUSTO"
		cQry += " FROM " + RetSqlName("SB2") + " SB2 "
		cQry += " WHERE SB2.B2_FILIAL >= '" + cFiliInic + "'"
		cQry += " AND SB2.B2_FILIAL <= '" + cFiliFina + "'"
		cQry += " AND SB2.D_E_L_E_T_ = ' '"
		cQry += " AND SB2.B2_COD IN ("
		cQry += "              SELECT D3_COD"
		cQry += "                     FROM   "+RetSqlName("SD3") + " SD3_B "
		cQry += "                           INNER JOIN " + RetSqlName("SB1")+" SB1 "
		cQry += "                                   ON B1_FILIAL = '"+ xFilial("SB1") +"'"
		cQry += "                                      AND B1_COD = SD3_B.D3_COD "
		cQry += "                                      AND B1_TIPO = 'MP' "
		cQry += "                                      AND SB1.D_E_L_E_T_ = ' ' "
		cQry += "                     WHERE SD3_B.D3_FILIAL >= '    '"
		cQry += "                           AND SD3_B.D3_FILIAL <= 'ZZZZ'"
		cQry += "                           AND SD3_B.D3_OP = ("
		cQry += "                           SELECT Max(SD3_A.D3_OP) D3_OP"
		cQry += "                           FROM   " + RetSqlName("SD3") + " SD3_A "
		cQry += "                           WHERE  SD3_A.D3_FILIAL >= '0101'"
		cQry += "                           	   AND SD3_A.D3_FILIAL <= '0103'"
		cQry += "                                  AND SD3_A.D3_COD = '" + cProduto + "'"
		cQry += "                                  AND SD3_A.D_E_L_E_T_ = ' ') )"
	
		//Copytoclipboard(cqry)
		// Mudar a query do padrão MsSQLQuery para AnsiQquery quando necessário.
		//MsgAlert(cQry)
		cQry := ChangeQuery( cQry )
		cTRB := GetNextAlias()
		dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQry),cTRB,.F.,.T.)
		While ! (cTRB)->(Eof())
			nQtdCusto += (cTRB)->D1_QUANT
			If nTipoRela == 1
				nUltCusto += (cTRB)->D1_CUSTO; 
				 + (cTRB)->D1_CUSTO * 0.12 + (cTRB)->D1_CUSTO * 0.0460; 
				 + (cTRB)->D1_CUSTO * 0.01 
			Else	
				nUltCusto += (cTRB)->D1_CUSTO
			EndIf	
			(cTRB)->(dbSkip())
		End
		nCustUnit := nUltCusto / nQtdCusto
		(cTRB)->( dbCloseArea() )
	EndIF	
	
	// Caso não encontre saldo em estoque busca do custo standard do PA
	If nCustUnit == 0 
		cQry := " SELECT 1 D1_QUANT, B1_CUSTD D1_CUSTO"
		cQry += " FROM " + RetSqlName("SB1")
		cQry += " WHERE B1_FILIAL = '"+ xFilial("SB1") +"'"
		cQry += " AND B1_COD = '" + cProduto + "'"
		cQry += " AND D_E_L_E_T_ = ' '"
	
		cQry := ChangeQuery( cQry )
		cTRB := GetNextAlias()
		dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQry),cTRB,.F.,.T.)
		While ! (cTRB)->(Eof())
			nQtdCusto += (cTRB)->D1_QUANT
			If nTipoRela == 1
				nUltCusto += (cTRB)->D1_CUSTO; 
				 + (cTRB)->D1_CUSTO * 0.12 + (cTRB)->D1_CUSTO * 0.0460; 
				 + (cTRB)->D1_CUSTO * 0.01 
			Else	
				nUltCusto += (cTRB)->D1_CUSTO
			EndIf	
			(cTRB)->(dbSkip())
		End
		nCustUnit := nUltCusto / nQtdCusto
		(cTRB)->( dbCloseArea() )
	EndIf
Return(nCustUnit)
