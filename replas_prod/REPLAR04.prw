#Include 'Protheus.ch'
#Include "REPORT.CH"
#Include "totvswin.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} REPLAR04
Relatório Material em transito

@author TOTVS Serra do Mar [JOSE CARLOS]
@since 04/10/2016
@version P12
/*/
//-------------------------------------------------------------------
User Function REPLAR04()
Local oReport
Local cPerg	:= Padr("REPLAR04",10)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//---> REMOVIDO compatibilização para versão 12.1.25.
//AjustaSx1(cPerg)
pergunte(cPerg,.F.)
	
oReport:= ReportDef()
oReport:SetLandScape()
oReport:PrintDialog()
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AjustaSX1
Função de criação de perguntas

@author TOTVS Serra do Mar [JOSE CARLOS]
@since 04/10/2016
@version P12
/*/
//-------------------------------------------------------------------
//---> REMOVIDO compatibilização para versão 12.1.25.
/*Static Function AjustaSX1(cPerg) 
		
PutSx1(cPerg,"01","Dt. Pré Nota Inicial"  	,"","" ,"mv_ch1" ,"D",08,0,0 ,"G","" 	,"" 	,"","","mv_par01",,,,,,,,,,,,,,,,,{},{},{})
PutSx1(cPerg,"02","Dt. Pré Nota Final" 		,"","" ,"mv_ch2" ,"D",08,0,0 ,"G","" 	,"" 	,"","","mv_par02",,,,,,,,,,,,,,,,,{},{},{})

Return()*/

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Função de definição de seções do relatório

@author TOTVS Serra do Mar [JOSE CARLOS]
@since 04/10/2016
@version P12
/*/
//-------------------------------------------------------------------
Static Function ReportDef()
Local oReport
Local oSecao1
Local oBreakCom
Local oTotCom
Local cAliasQry	:= GetNextAlias()
Local aOrd		:= {}

DEFINE REPORT oReport NAME "REPLAR04" TITLE "Relatorio de Material em Transito" PARAMETER "REPLAR04" ACTION {|oReport| ReportPrint( oReport, cAliasQry )} DESCRIPTION "Possibilitar a consulta e extração de Relatório"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define a secao do relatorio, informando que o arquivo principal  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE SECTION oSection1 OF oReport TITLE "Relatório" TABLES "SD1" ORDERS aOrd
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define as celulas que irao aparecer na secao1³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
DEFINE CELL NAME "D1_FILIAL"	OF oSection1 TITLE "Filial"				//BLOCK{||(cAliasQry)->COD_OPERADOR}
DEFINE CELL NAME "D1_DOC"		OF oSection1 TITLE "Nota"				//BLOCK{||(cAliasQry)->LOJA_OPERADOR}
DEFINE CELL NAME "D1_SERIE"		OF oSection1 TITLE "Serie"				//BLOCK{||(cAliasQry)->LOJA_OPERADOR}
DEFINE CELL NAME "D1_FORNECE"	OF oSection1 TITLE "Codigo"				//BLOCK{||(cAliasQry)->LOJA_OPERADOR}
DEFINE CELL NAME "D1_LOJA"		OF oSection1 TITLE "Loja"				//BLOCK{||(cAliasQry)->LOJA_OPERADOR}
DEFINE CELL NAME "A2_NOME"		OF oSection1 TITLE "Nome Fornecedor"	//BLOCK{||(cAliasQry)->LOJA_OPERADOR}
DEFINE CELL NAME "D1_COD"		OF oSection1 TITLE "Cod.Produto"		//BLOCK{||(cAliasQry)->LOJA_OPERADOR}
DEFINE CELL NAME "B1_DESC"		OF oSection1 TITLE "Descrição"			//BLOCK{||(cAliasQry)->LOJA_OPERADOR}
DEFINE CELL NAME "D1_QUANT"		OF oSection1 TITLE "Quantidade"			//BLOCK{||(cAliasQry)->LOJA_OPERADOR}

Return( oReport )

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
Função de definição de query do relatório

@author TOTVS Serra do Mar [JOSE CARLOS]
@since 27/09/2016
@version P12
/*/
//-------------------------------------------------------------------
Static Function ReportPrint( oReport, cAliasQry )
Local oSection	:= oReport:Section(1)
Local cMv_Par01	:= Dtos(Mv_Par01)
Local cMv_Par02	:= Dtos(Mv_Par02)

Begin REPORT QUERY oSection

	BeginSql Alias cAliasQry
	
		COLUMN  D1_QUANT    AS NUMERIC(14,2)
		
		SELECT  SD1.D1_FILIAL,
		        SD1.D1_DOC,
		        SD1.D1_SERIE,
		        SD1.D1_FORNECE,
		        SD1.D1_LOJA,
		        SA2.A2_NOME,
		        SD1.D1_COD,
		        SB1.B1_DESC,		        
		        SD1.D1_QUANT
		FROM %table:SD1% SD1 
		INNER JOIN %table:SA2% SA2  
				 ON SA2.A2_FILIAL = %xFilial:SA2%
				AND SA2.A2_COD = SD1.D1_FORNECE
				AND SA2.A2_LOJA = SD1.D1_LOJA
				AND SA2.%NotDel%
		INNER JOIN %table:SB1% SB1 
				ON SB1.B1_FILIAL = %xFilial:SB1%
			   AND SB1.B1_COD = SD1.D1_COD
			   AND SB1.%NotDel%
		WHERE SD1.D1_FILIAL = %xFilial:SD1%
		  AND SD1.D1_EMISSAO BETWEEN %exp:cMv_Par01% AND %exp:cMv_Par02%
		  AND SD1.D1_TES = ' '
		  AND SD1.%NotDel%
		ORDER BY D1_FILIAL,D1_DOC,D1_SERIE
	EndSql

END	 REPORT QUERY oSection

oSection:Print()

Return()

