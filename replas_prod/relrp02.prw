#include 'protheus.ch'
#include 'parmtype.ch'
#include "rwmake.ch"
#include "topconn.ch"
// Relação de posição de saldos

user function relrp02()

Local cquery := ""
local oReport  
local cPerg := Padr("RELRP02",10)
Local cquery := ""
local oReport        
Local aTables := {'SA1'}
Local aCampos	:= {}
Local bOk 		:= {|| .T. }
Local aPar 		:= {}
Private aRet 	:= {}

aAdd( aPar,{ 1,"Produto De "    			,Space(15)			 	,""	,""			,"SB1"		,""		,60,.F.} )
aAdd( aPar,{ 1,"Produto Até"    			,Space(15)			 	,""	,""			,"SB1"		,""		,60,.F.} )
aAdd( aPar,{ 1,"Fam. Contem	" 				,Space(200)				,""	,""			,"GRUPO"	,""		,60,.F.} )
aAdd( aPar,{ 2,"Tipo de Saldo"				,1					 	,{'Fechamento','Diário'}	,50			,"AllwaysTrue()",.F.} )
aAdd( aPar,{ 2,"Custo Méd. com Imposto"		,1				 		,{'Sim','Não'}	,50			,"AllwaysTrue()",.F.} )
aAdd( aPar,{ 1,"Filial(is) "				,Space(200) 			,"",""			,"FILIAL"	,""		,60,.F.} )
aAdd( aPar,{ 1,"Dt Fechamento "    			,CtoD(Space(8))	 		,""	,""			,""			,""		,60,.F.} )

If ParamBox( aPar, 'Relação de Posição de Saldos', @aRet, bOK, , , , , , ,  .T., .T. )
	MV_PAR01 := aRet[1]
	MV_PAR02 := aRet[2]
	MV_PAR03 := aRet[3]
	MV_PAR04 := IIF(ValType(aRet[4]) == "C" , IIF (aRet[4] == "Diário" , 2, 1),  aRet[4])
	MV_PAR05 := IIF(ValType(aRet[5]) == "C" , IIF (aRet[5] == "Não" , 2, 1),  aRet[5])
	MV_PAR06 := aRet[6]
	MV_PAR07 := aRet[7]
	oReport := RptDef()
    oReport:printDialog()	
EndIf

Return
 
Static Function RptDef(cperg)
   	
	local oReport := NIL
	Local oSection1:= Nil
	Local oSection2:= Nil
	
	Local oFunction
	local cTitulo := 'Relação de Posição de Saldos'
	
   	oReport := TReport():New('TRBSB2', cTitulo,/*cperg*/, {|oReport| ReportPrint(oReport)},'Relação de Posição de Saldos')
    oReport:SetLandscape()
    oReport:SetTotalInLine(.F.)

	oSection1 := TRSection():New(oReport,"Capa",{"SBM","SB1", "SB2", "SB9"},,.F.,.T.)
	oSection1:SetTotalInLine(.F.)  	
    oSection1:SetPageBreak  (.T.)
     	
    TRCell():New(oSection1, "B2_FILIAL"	 	, "SB2", "FILIAL"   	,PesqPict('SB2',"B2_FILIAL")  	,TamSX3("B2_FILIAL")[1]+1		,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection1, "BM_TIPGRU"	 	, "SBM", "FAMILIA"   	,PesqPict('SBM',"BM_TIPGRU")  	,TamSX3("BM_TIPGRU")[1]+1		,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection1, "X5_DESCRI"	 	, "SX5", "DESC"   		,PesqPict('SX5',"X5_DESCRI")   	,TamSX3("X5_DESCRI")[1]+1		,/*lPixel*/,/*{|| code-block de impressao }*/)
 	TRCell():New(oSection1, "B1_COD"	 	, "SB1", "PRODUTO"   	,PesqPict('SB1',"B1_COD")  		,TamSX3("B1_COD")[1]+1		,/*lPixel*/,/*{|| code-block de impressao }*/)
 	TRCell():New(oSection1, "B1_DESC"	 	, "SB1", "ITEM"		   	,PesqPict('SB1',"B1_DESC")  	,TamSX3("B1_DESC")[1]+1		,/*lPixel*/,/*{|| code-block de impressao }*/)
 	TRCell():New(oSection1, "B1_POSIPI"	 	, "SB1", "CF" 		  	,PesqPict('SB1',"B1_POSIPI")  	,TamSX3("B1_POSIPI")[1]+1		,/*lPixel*/,/*{|| code-block de impressao }*/)
 	TRCell():New(oSection1, "B1_UM"		 	, "SB1", "UNIDADE"   	,PesqPict('SB1',"B1_UM")  		,TamSX3("B1_UM")[1]+1		,/*lPixel*/,/*{|| code-block de impressao }*/)
 	TRCell():New(oSection1, "B2_QATU"	 	, "SB2", "ESTOQUE"   	,PesqPict('SB2',"B2_QATU")  	,TamSX3("B2_QATU")[1]+1		,/*lPixel*/,/*{|| code-block de impressao }*/)
 	TRCell():New(oSection1, "B2_RESERVA" 	, "SB2", "RESERVA"   	,PesqPict('SB2',"B2_RESERVA")  	,TamSX3("B2_RESERVA")[1]+1		,/*lPixel*/,/*{|| code-block de impressao }*/)
 	TRCell():New(oSection1, "DISPONIVEL" 	, "SB2", "DISPONIVEL"  	,PesqPict('SB2',"B2_RESERVA")  	,TamSX3("B2_RESERVA")[1]+1		,/*lPixel*/,/*{|| code-block de impressao }*/)
 	TRCell():New(oSection1, "B2_CM1"	 	, "SB2", "Custo Medio" 	,PesqPict('SB2',"B2_CM1")  		,TamSX3("B2_CM1")[1]+1		,/*lPixel*/,/*{|| code-block de impressao }*/)
 	TRCell():New(oSection1, "B9_VINI1"	 	, "SB9", "Custo Total" 	,PesqPict('SB9',"B9_VINI1")  	,TamSX3("B9_VINI1")[1]+1		,/*lPixel*/,/*{|| code-block de impressao }*/)
    
return (oReport)
 
Static Function ReportPrint(oReport)
	
	Local oSection1 := oReport:Section(1)
	Local cnum := ""
	Local cquery := ""
	Local oBreak
	lOCAL obreak := ""
	Local obreak2 := ""
	Local obreak3 := ''
	Local obreak4 := ''
	Local ncount := 0
	Local nsecini := 0
	local nsecfim := 0
	Local ncount1 := 0
	Local ncount2 := 0
	Local ncount3 := 0
	Local ncount4 := 0
	Local ncount5 := 0
	Local ncount6 := 0
	Local ncount7 := 0
	Local ncount8 := 0
	Local ncount9 := 0
	Local ncount10 := 0
	Local ncount11 := 0
	Local ncount12 := 0
	Local ncount13 := 0
	Local lanalit := .F.
	Local nTCust	:= 0
	Local nCust	:= 0
	Private cNat := ""
	Private cnatpai := ''
	Private cProj := ""
	Private cdesc := "" 
	Private cDescPai := ""
 		
 	oSection1:SetTotalText("Total Geral 2")
 	oBreak2 :=  TRBreak():New(oSection1,{  || oSection1:Cell("BM_TIPGRU"):uPrint},"TOTAIS POR FAMILIA",.F.)
 	oBreak1 :=  TRBreak():New(oSection1,{  || oSection1:Cell("B2_FILIAL"):uPrint},"TOTAL POR FILIAL ",.F.)
 	
 	TRFunction():New(oSection1:Cell("B2_QATU"),"Estoque" ,"SUM",oBreak2,,,,.F.,.F.)
 	TRFunction():New(oSection1:Cell("B2_RESERVA"),"Reservado" ,"SUM",oBreak2,,,,.F.,.F.)
 	TRFunction():New(oSection1:Cell("DISPONIVEL"),"Disponível" ,"SUM",oBreak2,,,,.F.,.F.)
 	TRFunction():New(oSection1:Cell("B2_CM1"),"Custo Medio" ,"AVERAGE",oBreak2,,,,.F.,.F.)
 	TRFunction():New(oSection1:Cell("B9_VINI1"),"Custo Total" ,"SUM",oBreak2,,,,.F.,.F.)
 	
 	TRFunction():New(oSection1:Cell("B2_QATU"),"Estoque" ,"SUM",oBreak1,,,,.F.,.F.)
 	TRFunction():New(oSection1:Cell("B2_RESERVA"),"Reservado" ,"SUM",oBreak1,,,,.F.,.F.)
 	TRFunction():New(oSection1:Cell("DISPONIVEL"),"Disponível" ,"SUM",oBreak1,,,,.F.,.F.)
 	TRFunction():New(oSection1:Cell("B2_CM1"),"Custo Medio" ,"AVERAGE",oBreak1,,,,.F.,.F.)
 	TRFunction():New(oSection1:Cell("B9_VINI1"),"Custo Total" ,"SUM",oBreak1,,,,.F.,.F.)
 	
 	TRFunction():New(oSection1:Cell("B2_QATU"),"Estoque" ,"SUM",,,,,.F.,.T.)
 	TRFunction():New(oSection1:Cell("B2_RESERVA"),"Reservado" ,"SUM",,,,,.F.,.T.)
 	TRFunction():New(oSection1:Cell("DISPONIVEL"),"Disponível" ,"SUM",,,,,.F.,.T.)
 	TRFunction():New(oSection1:Cell("B2_CM1"),"Custo Medio" ,"AVERAGE",,,,,.F.,.T.)
 	TRFunction():New(oSection1:Cell("B9_VINI1"),"Custo Total" ,"SUM",,,,,.F.,.T.)
 	
 	If MV_PAR04 == 2
	 	
	 	cQuery += " SELECT B2_FILIAL FILIAL, BM_TIPGRU , X5_DESCRI, B1_COD , B1_DESC,  B1_POSIPI, B1_UM, SUM(B2_QATU) AS ESTQ, " 
	 	cQuery += " SUM(B2_RESERVA) AS RESERV, SUM(B2_QATU - B2_RESERVA) AS DISPONIV, AVG(B2_CM1) AS CUSTM, SUM(B2_VFIM1) AS CUSTOT "
	 	cQuery += " FROM " + RetSqlName('SB1') + " SB1 " 
	 	cQuery += " INNER JOIN " + RetSqlName("SB2") + " SB2 "
		cQuery += " ON B2_COD = B1_COD AND SB2.D_E_L_E_T_ = ' ' "			 
	 	cQuery += " INNER JOIN " + RetSqlName("SBM") + " SBM "
		cQuery += " ON BM_FILIAL = '" + xFilial("SBM") + "' AND B1_GRUPO = BM_GRUPO AND SBM.D_E_L_E_T_ = ' ' " 
	 	cQuery += " INNER JOIN " + RetSqlName('SX5') + " SX5 "
	 	cQuery += " ON BM_TIPGRU = X5_CHAVE "  
	    cQuery += "		AND X5_TABELA = 'V0'  AND SX5.D_E_L_E_T_ = ' ' "
	   
		If !Empty(MV_PAR06)
			cQuery += "	WHERE B2_FILIAL IN ( '" + StrTran(MV_PAR06,";","','") + "' ) "
		Else
			cQuery += "	WHERE B2_FILIAL = '" + xFilial("SB2") + "' "
		EndIf
		
		cQuery += "		AND B2_QATU <> 0 "
		
		If !Empty(MV_PAR02)
			cQuery += "		AND B1_COD BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'" 
		EndIf
		
		If !Empty(MV_PAR03)
			cQuery += " 	AND BM_TIPGRU IN ( '" + StrTran(MV_PAR03,";","','") + "' ) "																		 
		EndIf

		cQuery += " 	AND SB1.D_E_L_E_T_ = ' ' "
		cQuery += " GROUP BY B2_FILIAL, BM_TIPGRU , X5_DESCRI, B1_COD , B1_DESC,  B1_POSIPI, B1_UM "		
	    cQuery += " ORDER BY B2_FILIAL, BM_TIPGRU " 
 	else
 		cQuery += " SELECT B9_FILIAL FILIAL, BM_TIPGRU, X5_DESCRI, B1_COD, B1_DESC,  B1_POSIPI, B1_UM, SUM(B9_QINI) AS ESTQ, SUM(0) AS RESERV, SUM(0) AS DISPONIV, "
 		cQuery += " AVG(B9_CM1) AS CUSTM, SUM(B9_VINI1) AS CUSTOT "
 		cQuery += " FROM " + RETSQLNAME('SB1') + " SB1 "  
 		cQuery += " INNER JOIN " + RetSqlName("SB2") + " SB2 "
		cQuery += " ON B2_COD = B1_COD AND SB2.D_E_L_E_T_ = ' ' "			 
	 	cQuery += " INNER JOIN " + RetSqlName("SBM") + " SBM "
		cQuery += " ON BM_FILIAL = '" + xFilial("SBM") + "' AND B1_GRUPO = BM_GRUPO AND SBM.D_E_L_E_T_ = ' ' " 
	 	cQuery += " INNER JOIN " + RetSqlName('SX5') + " SX5 "
	 	cQuery += " ON BM_TIPGRU = X5_CHAVE "  
	    cQuery += "		AND X5_TABELA = 'V0'  AND SX5.D_E_L_E_T_ = ' ' "
	    cQuery += " INNER JOIN " + RetSqlName("SB9") + " SB9 "
		cQuery += " ON B9_FILIAL = B2_FILIAL AND B9_COD = B1_COD AND SB9.D_E_L_E_T_ = ' ' "			 
		
		If !Empty(MV_PAR06)
			cQuery += "	WHERE B2_FILIAL IN ( '" + StrTran(MV_PAR06,";","','") + "' ) "
		Else
			cQuery += "	WHERE B2_FILIAL = '" + xFilial("SB2") + "' "
		EndIf
		
		If !Empty(MV_PAR02)
			cQuery += "		AND B1_COD BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'" 
		EndIf
		
		If !Empty(MV_PAR03)
			cQuery += " 	AND BM_TIPGRU IN ( '" + StrTran(MV_PAR03,";","','") + "' ) "																		 
		EndIf
		
		If !Empty(MV_PAR07)
			cQuery += "		AND B9_DATA = '" + iif(VAlType(MV_PAR07) == "D",DtoS(MV_PAR07),MV_PAR07) + "' "
		EndIf

		cQuery += " 	AND SB1.D_E_L_E_T_ = ' ' "
		cQuery += " GROUP BY B9_FILIAL, BM_TIPGRU, X5_DESCRI, B1_COD, B1_DESC,  B1_POSIPI, B1_UM "
 		cQuery += " ORDER BY B9_FILIAL, BM_TIPGRU " 
 	endif
   	
   	cQuery := ChangeQuery(cQuery)
   	
   	IF SELECT('TRBSB2') > 0
   		TRBSB2->(DBCLOSEAREA())
   	ENDIF
	
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),"TRBSB2",.T.,.T.)
	TRBSB2->(DBGOTOP())
	
	oSection1:Init()
	oSection1:SetHeaderSection(.T.)                           	
	DbSelectArea('TRBSB2')
	TRBSB2->(dbGoTop())
	do while TRBSB2->(!EOF())
		NCOUNT++
		TRBSB2->(DBSKIP())
	END DO
	
	oReport:SetMeter(ncount)
	oReport:IncMeter()
	TRBSB2->(DBGOTOP())
	While TRBSB2->(!EOF()) 	
 	   If oReport:Cancel()
 	   		Exit
	   EndIf
 		
		oSection1:Cell("B2_FILIAL"):SetValue(AllTrim(TRBSB2->(FILIAL)))
		oSection1:Cell("B2_FILIAL"):SetAlign("LEFT")
		
		oSection1:Cell("BM_TIPGRU"):SetValue(TRBSB2->(BM_TIPGRU))
		oSection1:Cell("BM_TIPGRU"):SetAlign("LEFT")		
		
		oSection1:Cell("X5_DESCRI"):SetValue(TRBSB2->(X5_DESCRI))
		oSection1:Cell("X5_DESCRI"):SetAlign("LEFT")
		
		oSection1:Cell("B1_COD"):SetValue(TRBSB2->(B1_COD))
		oSection1:Cell("B1_COD"):SetAlign("Right")
		
		oSection1:Cell("B1_DESC"):SetValue(TRBSB2->(B1_DESC))
		oSection1:Cell("B1_DESC"):SetAlign("Right")
		
		oSection1:Cell("B1_POSIPI"):SetValue(TRBSB2->(B1_POSIPI))
		oSection1:Cell("B1_POSIPI"):SetAlign("Right")
		
		oSection1:Cell("B1_UM"):SetValue(TRBSB2->(B1_UM))
		oSection1:Cell("B1_UM"):SetAlign("Right")
		
		oSection1:Cell("B2_QATU"):SetValue(TRBSB2->(ESTQ))
		oSection1:Cell("B2_QATU"):SetAlign("Right")
	
		oSection1:Cell("B2_RESERVA"):SetValue(TRBSB2->(RESERV))
		oSection1:Cell("B2_RESERVA"):SetAlign("Right")
		
		oSection1:Cell("DISPONIVEL"):SetValue(TRBSB2->(DISPONIV))
		oSection1:Cell("DISPONIVEL"):SetAlign("Right")
		
		If MV_PAR05 == 1
			nCust := U_getCMed(TRBSB2->B1_COD, dDatabase, TRBSB2->(CUSTM)  )
		Else 
			nCust := TRBSB2->(CUSTM)
		EndIf
		
		oSection1:Cell("B2_CM1"):SetValue( nCust )
		oSection1:Cell("B2_CM1"):SetAlign("Right")
			
		oSection1:Cell("B9_VINI1"):SetValue(nCust * TRBSB2->(ESTQ) )
		oSection1:Cell("B9_VINI1"):SetAlign("Right")
			
		oSection1:printline()
		oReport:IncMeter()
		
		TRBSB2->(DBSKIP())
	End Do
	
	OREPORT:FatLine()
//	oReport:Box(oreport:row(),010,oReport:row() + oreport:LineHeight()*5,oReport:PageWidth() )
	oSection1:Finish()
Return


*---------------------------*
//---> REMOVIDO compatibilização para versão 12.1.25.
/*Static Function ValidPerg(cperg)
*---------------------------*
Local cLAlias := Alias()
Local aRegs   := {}

Aadd(aRegs,{PADR(cPerg,10),"01","De Produto		?","","","mv_ch1","C",20								,0,0,"G",""				,"MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","SB1","","","","",""})
Aadd(aRegs,{PADR(cPerg,10),"02","Até Produto	?","","","mv_ch2","C",20								,0,0,"G",""				,"MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","SB1","","","","",""})
Aadd(aRegs,{PADR(cPerg,10),"03","Familia		?","","","mv_ch3","C",60								,0,0,"G","u_Telagrup('MV_PAR03')"	,"MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{PADR(cPerg,10),"04","Tipo de saldo  ?","","","mv_ch4","C",1									,0,0,"C",""				,"MV_PAR04","1=Saldo de fechamento","","","","","2=Saldo diário","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{PADR(cPerg,10),"05","Filial			?","","","mv_ch5","C",60								,0,0,"G","u_telafil('MV_PAR05')"	,"MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

//AADD(aRegs,{PADR(cPerg,10),"06","Dt Referencia  ?","","","mv_ch6","D",8								,0,0,"G",""							,"mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualizacao do SX1 com os parametros criados³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX1")
dbSetorder(1)
For nLoop1 := 1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[nLoop1,2])
		RecLock("SX1",.T.)
		For nLoop2 := 1 to FCount()
			FieldPut(nLoop2,aRegs[nLoop1,nLoop2])
		Next
		MsUnlock()
		dbCommit()
	Endif
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Retorna ambiente original³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cLAlias)

Return*/



/*
User Function TelaFil(cMvPar)
Local cGrupos := ''
Local lcheck := .F. 
Local _stru := {}
Local aCpoBro := {}
Local oDlgLocal 
Local cQuery := '' 
Local cFils := ''
Local cTab := 'TTM0'
Local aButtons := {}
Local cCompany := ''
Local aFil := {}
Local nI := 0
Private aCores := {}
Private lInverte := .F.
Private cMark   := GetMark()   
Private oMark


//Cria um arquivo de Apoio
AADD(_stru,{"OK"     	,"C"	,2		,0		})
AADD(_stru,{"M0_CODIGO"	,"C"	,2		,0		})
AADD(_stru,{"M0_CODFIL" ,"C"	,4		,0		})
AADD(_stru,{"M0_FILIAL"	,"C"	,40		,0		})

cArq:=Criatrab(_stru,.T.)
DBUSEAREA(.t.,,carq,"TTM0")
*/

//Alimenta o arquivo de apoio com os registros do cadastro de clientes (SA1)

//---> REMOVIDO compatibilização para versão 12.1.25.
/*DbSelectArea("SM0")
SM0->(DBGOTOP())
do While  SM0->(!Eof())
	IF SM0->(M0_CODIGO) == cempant // SOMENTE ADICIONA DA MESMA EMPRESA
		DbSelectArea("TTM0")	
		RecLock("TTM0",.T.)		
			TTM0->M0_CODIGO   	  :=  SM0->(M0_CODIGO) //código da empresa
			TTM0->M0_CODFIL    := SM0->(M0_CODFIL) //código da filial
			TTM0->M0_FILIAL    := SM0->(M0_FILIAL)	//nome da filial
		MsunLock()	
	ENDIF
	SM0->(DbSkip())
Enddo*/

//Capturar o grupo de empresas --> FWGrpCompany()
//Capturar todas as filiais    --> FwAllFilial()
//Capturar o nome das filiais  --> FwFilialName()

/*
cCompany := FWGrpCompany()
aFil := FwAllFilial(,,cCompany)
dbSelectArea("TTM0")
For nI := 1 To Len( aFil )
	RecLock("TTM0",.T.)
	TTM0->M0_CODIGO := cCompany
	TTM0->M0_CODFIL := aFil[ nI ]
	TTM0->M0_FILIAL := FwFilialName( cCompany, aFil[ nI ], 1 )
	MsunLock()
Next nI

//Define quais colunas (campos da TTRB) serao exibidas na MsSelect
aCpoBro	:= {{ "OK"			,, "Mark"           ,"@!"},;
			{ "M0_CODIGO"		,, "Empresa"        ,"@!"},;
			{ "M0_CODFIL"	,, "Filial"         ,"@!"},;
			{ "M0_FILIAL"	,, "Descrição"      ,"@1!"}}
			//Cria uma Dialog
				
DEFINE MSDIALOG oDlg TITLE "MarkBrowse c/Refresh" From 9,0 To 335,800 PIXEL
Aadd( aButtons, {"Mark", {|| u_mktodos(@cTab)}, "Marca/Desmarca todos", "Marca/Desmarca todos" , {|| .T.}} )
DbSelectArea("TTM0")
DbGotop()//Cria a MsSelect

omark := MsSelect():New("TTM0","OK","",aCpoBro,@lInverte,@cMark,{40,1,150,400},,,,,)
omark:bMark := {| | Dpfil()} //Exibe a Dialog
ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| oDlg:End()},{|| oDlg:End()},,@aButtons)

//Fecha a Area e elimina os arquivos de apoio criados em disco.

TTM0->(DBGOTOP())
DO WHILE TTM0->(!EOF())
	If Marked("OK")	
		IF EMPTY(cfils)
			cfils += alltrim(TTM0->(M0_CODFIL))
		else
			cfils += ";" + alltrim(TTM0->(M0_CODFIL)) 
		endif
	Endif
	TTM0->(DBSKIP())
END DO

TTM0->(DbCloseArea())

Iif(File(cArq + GetDBExtension()),FErase(cArq  + GetDBExtension()) ,Nil)

If FwIsInCallStack("U_RELRP02")
	MV_PAR06 := cfils
ElseiF FwIsInCallStack("U_RELRP03")
	MV_PAR01 := cfils
EndIf
	
Return .T.
*/

Static Function Dpfil()

RecLock("TTM0",.F.)

If Marked("OK")	

	TTM0->OK := cMark

Else	

TTM0->OK := ""

Endif             
			
MSUNLOCK()

omark:oBrowse:Refresh()
			

Return 	
