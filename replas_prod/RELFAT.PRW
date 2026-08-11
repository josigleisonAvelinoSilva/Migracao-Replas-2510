#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} RELFAT
Geração de planilha Excel com a margem de contribuicao por preço medio

@author Caique

@since 15/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------  
User Function RELF()
Local oReport

If TRepInUse()	//verifica se relatorios personalizaveis esta disponivel
	oReport := ReportDef()
	oReport:SetTotalInLine(.F.)                                                              
	oReport:PrintDialog()
EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Função principal de impressão

@author Caique

@since 15/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ReportDef()
Local oReport
//Local oSection
Private cPerg    := "MARGEM"

//Pergunte(cPerg,.F.)
cTitRel :=  "FAT"
oReport := TReport():New("RELFAT",cTitRel,/*cPerg*/,{|oReport| PrintReport(oReport)},"Este relatorio ira imprimir informações do Faturamento x Compra com todos impostos.")
oSection1 := TRSection():New(oReport,OemToAnsi(cTitRel),{"FAT"})


TRCell():New(oSection1,"ESTADO"	            ,"FAT","Estado"				   			,"@!",02) 
TRCell():New(oSection1,"FAM"	            ,"FAT","Grupo"			   				,"@!",20)  
TRCell():New(oSection1,"FAMDESC"	        ,"FAT","Descrição do Grupo"	   			,"@!",40)  
TRCell():New(oSection1,"COD"	            ,"FAT","Produto"			   			,"@!",15)  
TRCell():New(oSection1,"CODDESC"	        ,"FAT","Descrição do Produto"  			,"@!",40)  
TRCell():New(oSection1,"QTD"		        ,"FAT","Quantidade"				   		,"@R 99999999999.99",14)     
TRCell():New(oSection1,"UCOM" 		       	,"FAT","Últ. Compra"		        	,"@R 999,999,999.99",14)
TRCell():New(oSection1,"CTOTAL" 	      	,"FAT","Custo Total"			    	,"@R 999,999,999.99",14)
TRCell():New(oSection1,"CMEDIO"				,"FAT","Custo Médio"					,"@R 999,999,999.99",14)
TRCell():New(oSection1,"RECTOT"		    	,"FAT","Receita Total"	    			,"@R 999,999,999.99",14)
TRCell():New(oSection1,"PVMED"				,"FAT","PV Médio"						,"@R 999,999,999.99",14)
TRCell():New(oSection1,"MARGEM"	            ,"FAT","Margem"						   	,"@R 999,999,999.99",14) 
TRCell():New(oSection1,"PERC"	    		,"FAT","%"					       		,"@R 9999.99",18)

Return oReport

//-------------------------------------------------------------------
/*/{Protheus.doc} PrintReport
Função para impressão

@author Caique

@since 15/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function PrintReport(oReport)
Local oSection1 := oReport:Section(1)

oSection1:SetTotalInLine(.F.)
oReport:OnPageBreak(,.T.)

// Selecao dos dados a Serem Impressos
MsAguarde({|| fSelDados()},"Selecionando Itens")

// Impressao da Primeira secao
DbSelectArea("FAT")
DbGoTop()

oReport:SetMeter(RecCount())
oSection1:Init()
While  !Eof()
	If oReport:Cancel()
		Exit
	EndIf
	oSection1:PrintLine()
	
	DbSelectArea("FAT")
	DbSkip()
	oReport:IncMeter()
EndDo
oSection1:Finish()

If Sele("FAT") <> 0
	FAT->(DbCloseArea())
Endif
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} fSelDados
Função que alimenta TRB com dados para impressão

@author Caique

@since 15/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function fSelDados()
Local _aStru	:= {}
Local cQuery	:= ""
// Criacao arquivo de Trabalho                                       

AADD(_aStru,{"ESTADO"	,"C",02,0}) 
AADD(_aStru,{"FAM"		,"C",20,0})
AADD(_aStru,{"FAMDESC"	,"C",40,0})
AADD(_aStru,{"COD"		,"C",15,0})
AADD(_aStru,{"CODDESC"	,"C",40,0})
AADD(_aStru,{"QTD"		,"N",14,2})
AADD(_aStru,{"UCOM"		,"N",14,2})
AADD(_aStru,{"CTOTAL"	,"N",14,2})
AADD(_aStru,{"CMEDIO"	,"N",14,2})
AADD(_aStru,{"RECTOT"	,"N",14,2})
AADD(_aStru,{"PVMED"	,"N",14,2})
AADD(_aStru,{"MARGEM"	,"N",14,2})
AADD(_aStru,{"PERC"		,"N",15,2})

/*      
_cArq     := CriaTrab(_aStru,.T.)
_cIndice  := CriaTrab(Nil,.F.)

If Sele("FAT") <> 0
	FAT->(DbCloseArea())
Endif
_cChaveInd	:= "ESTADO+FAM+COD"

dbUseArea(.T.,,_cArq,"FAT",.F.,.F.)
IndRegua("FAT",_cIndice,_cChaveInd,,,"Selecionando Registros...") 
*/

If Select("FAT") <> 0
	FAT->(DbCloseArea())
Endif

// MIGRACAO BD - NOVA ESTRUTURA DE TABELA TEMPORÁRIA
_cArq      := "FAT"
_cChaveInd := GETNEXTALIAS()
oTable := FwTemporaryTable():New(_cArq)
oTable:SetFields(_aStru)
oTable:AddIndex(_cChaveInd, {"ESTADO","FAM","COD"}) 
oTable:Create()
DbSelectArea(_cArq)

// Seleciona Os funcionários de Acordo com os parametros Selecionados
cQuery += U_xQry()
 
//* Verifica se a Query Existe, se existir fecha
If Select("TSQL1") > 0
	dbSelectArea("TSQL1")
	DbCloseArea()
EndIf

//* Cria a Query e da Um Apelido
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TSQL1",.F.,.T.)

dbSelectArea("TSQL1")
dbGotop()
Do While TSQL1->(!Eof())
	MsProcTxt("Processando ...")

	DbSelectArea("FAT")
	RecLock("FAT",.T.)
	FAT->ESTADO := TSQL1->D2_EST
	FAT->FAM	:= TSQL1->D2_GRUPO
	FAT->FAMDESC:= TSQL1->BM_DESC
	FAT->COD	:= TSQL1->D2_COD
	FAT->CODDESC:= TSQL1->B1_DESC
	FAT->QTD	:= TSQL1->D2_QUANT
	FAT->UCOM	:= U_getUPer(TSQL1->D2_COD, MV_PAR01, MV_PAR02)
	If MV_PAR07 == 1
		FAT->CMEDIO	:= U_getCMed(TSQL1->D2_COD,MV_PAR02, TSQL1->D2_CUSTO1 / TSQL1->D2_QUANT  ) 
		FAT->CTOTAL	:= FAT->CMEDIO * FAT->QTD
	Else
		FAT->CTOTAL	:= TSQL1->D2_CUSTO1
		FAT->CMEDIO	:= FAT->CTOTAL / FAT->QTD
	EndIf
	FAT->RECTOT	:= TSQL1->D2_TOTAL //OK
	FAT->PVMED	:= FAT->RECTOT / FAT->QTD //OK 
	FAT->MARGEM	:= FAT->RECTOT - FAT->CTOTAL
	FAT->PERC	:= FAT->MARGEM * 100 / FAT->CTOTAL
	MsUnlock()
		
	dbSelectArea("TSQL1")
	dbSkip()
Enddo
	
If Select("TSQL1") > 0
	dbSelectArea("TSQL1")
	DbCloseArea()
EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} RELFAT
Geração de planilha Excel com a margem de contribuicao por preço medio

@author Caique

@since 15/02/2015
@version 1.0
/*/
//-------------------------------------------------------------------  

User Function xQry()

Local cQuery		:= ""

cQuery := " SELECT D2_EST, D2_GRUPO, D2_COD, D2_QUANT, D2_TOTAL + ( CASE WHEN F4_DESTACA = 'S' THEN D2_VALIPI ELSE 0  END) D2_TOTAL, D2_VALIPI, D2_CUSTO1, D2_TES, B2_CM1, B1_DESC, BM_DESC "
cQuery += " FROM " + RetSqlName("SD2") + " SD2 "	 
cQuery += " INNER JOIN " + RetSqlName("SBM") + " SBM "
cQuery += " ON BM_FILIAL = '" + xFilial("SBM") + "' AND D2_GRUPO = BM_GRUPO AND SBM.D_E_L_E_T_ = ' ' " 
cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 "
cQuery += " ON B1_FILIAL = '" + xFilial("SB1") + "' AND B1_COD = D2_COD AND SB1.D_E_L_E_T_ = ' ' " 
cQuery += " INNER JOIN " + RetSqlName("SB2") + " SB2 "
cQuery += " ON B2_FILIAL = '" + xFilial("SB2") + "' AND B2_COD = D2_COD AND B2_LOCAL = D2_LOCAL AND SB2.D_E_L_E_T_ = ' ' "			 
cQuery += " INNER JOIN " + RetSqlName("SF4") + " SF4 "
cQuery += " ON F4_FILIAL = '" + xFilial("SF4") + "' AND D2_TES = F4_CODIGO AND F4_DUPLIC = 'S' AND SF4.D_E_L_E_T_ = ' ' "
cQuery += " WHERE SD2.D_E_L_E_T_ = ' ' "																							 
cQuery += " 	AND D2_FILIAL   = '" + xFilial("SD2") + "' "																			 
cQuery += " 	AND D2_EMISSAO >= '" + DtoS(MV_PAR01) + "' AND D2_EMISSAO <= '" + DtoS(MV_PAR02) + "' "							 

If !Empty(MV_PAR04)
	cQuery += " 	AND D2_GRUPO BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "											 
EndIf

If !Empty(MV_PAR05)
	cQuery += " 	AND BM_TIPGRU IN ( '" + StrTran(MV_PAR05,";","','") + "' ) "																		 
EndIf

If !Empty(MV_PAR06)
	cQuery += " 	AND D2_EST = '" + MV_PAR06 + "' "																					 
EndIf

cQuery += " ORDER BY D2_EST, D2_GRUPO, D2_COD "

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} RELFAT
Param

@author Caique

@since 21/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------  

User Function RELFAT

Local aCampos	:= {}
Local bOk 		:= {|| .T. }
Local aPar 		:= {}
Private aRet 	:= {}

aAdd( aPar,{ 1,"Emissao De	"    			,CtoD(Space(8))	 	,""	,""			,""			,""		,60,.T.} )
aAdd( aPar,{ 1,"Emissao Ate	"    			,CtoD(Space(8))	 	,""	,""			,""			,""		,60,.T.} )
aAdd( aPar,{ 1,"Grupo De	" 				,Space(4)			,""	,""			,"XGRUPO"	,""		,60,.F.} )
aAdd( aPar,{ 1,"Grupo Ate	"  	 			,Space(4)			,""	,""			,"XGRUPO"	,""		,60,.F.} )
aAdd( aPar,{ 1,"Fam. Contem	" 				,Space(200)			,""	,""			,"GRUPO"	,""		,60,.F.} )
aAdd( aPar,{ 1,"Sigla Estado "    			,Space(2)		 	,""	,""			,"XESTAD"	,""		,60,.F.} )
aAdd( aPar,{ 2,"Custo Méd. com Imposto"	,1				 	,{'Sim','Não'}	,50			,"AllwaysTrue()",.F.} )

If ParamBox( aPar, 'Faturamento x Compra', @aRet, bOK, , , , , , , .F., .F. )
	MV_PAR01 := aRet[1]
	MV_PAR02 := aRet[2]
	MV_PAR03 := aRet[3]
	MV_PAR04 := aRet[4]
	MV_PAR05 := aRet[5]
	MV_PAR06 := aRet[6]
	MV_PAR07 := IIF(ValType(aRet[7]) == "C" , IIF (aRet[7] == "Não" , 2, 1),  aRet[7])
	U_RELF()
EndIf

Return 
