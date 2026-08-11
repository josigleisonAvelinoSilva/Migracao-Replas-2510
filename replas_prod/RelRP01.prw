#include 'protheus.ch'
#include 'parmtype.ch'
#include "rwmake.ch"
#include "topconn.ch"


// Relatório de Carteira por família

user function relrp01()

Local cquery := ""
local oReport  
local cPerg := Padr("RELRP01",10)
Local cquery := ""
local oReport        
Local aTables := {'SA1'}
Local bOk 		:= {|| .T. }
Local aPar 		:= {}
Private aRet 	:= {}

aAdd( aPar,{ 1,"Fam. Contem	" 				,Space(200)			,""	,""			,"GRUPO"	,""		,60,.F.} )
aAdd( aPar,{ 1,"Emissao De	"    			,CtoD(Space(8))	 	,""	,""			,""			,""		,60,.T.} )
aAdd( aPar,{ 1,"Emissao Ate	"    			,CtoD(Space(8))	 	,""	,""			,""			,""		,60,.T.} )
aAdd( aPar,{ 2,"ICM"	,1				 	,{'Não Desconta','Desconta'}	,50			,"AllwaysTrue()",.F.} )
aAdd( aPar,{ 1,"Entrega De	"    			,CtoD(Space(8))	 	,""	,""			,""			,""		,60,.T.} )
aAdd( aPar,{ 1,"Entrega Ate	"    			,CtoD(Space(8))	 	,""	,""			,""			,""		,60,.T.} )

If !ParamBox( aPar, 'Carteira por Família', @aRet, bOK, , , , , , , .T., .T. )
	Return
EndIf

MV_PAR01 := aRet[1]
MV_PAR02 := aRet[2]
MV_PAR03 := aRet[3]
MV_PAR04 := IIF(ValType(aRet[4]) == "C" , IIF (aRet[4] == "Desconta" , 2, 1),  aRet[4])
MV_PAR05 := aRet[5]
MV_PAR06 := aRet[6]

oReport := RptDef()
oReport:printDialog()
   
Return
 
Static Function RptDef()
   	
	local oReport := NIL
	Local oSection1:= Nil
	Local oSection2:= Nil
	
	Local oFunction
	local cTitulo := 'Carteira por Família - ' +  DtoC(MV_PAR02) + ' á ' + DtoC(MV_PAR03) +;
				 " / "+ IIF(MV_PAR04 == 2, "Desconta ICM ", "Não desconta ICM ")
	
   	oReport := TReport():New('TRBSBM', cTitulo,, {|oReport| ReportPrint(oReport)},cTitulo)
    oReport:SetLandscape()
    oReport:SetTotalInLine(.F.)
 
	oSection1 := TRSection():New(oReport,"Capa",{"SBM","SB1", "SB2"},,.F.,.T.)
	oSection1:SetTotalInLine(.F.)  	
 	
 	TRCell():New(oSection1, "BM_TIPGRU"	 	, "SBM", "FAMILIA"   	,PesqPict('SBM',"BM_TIPGRU")  	,TamSX3("BM_TIPGRU")[1]+1	,,)
    TRCell():New(oSection1, "X5_DESCRI"	 	, "SX5", "DESCRIÇÃO"	,PesqPict('SX5',"X5_DESCRI")   	,TamSX3("X5_DESCRI")[1]+1	,,)
	TRCell():New(oSection1, "QTDVEN"		, "SD2", "QTD FATURADA"   	,'@E 999,999,999,999.99'	,18						,,)
	TRCell():New(oSection1, "PRCVEN"  	 	, "SD2", "PRV FATURADO" 	,'@E 999,999,999,999.99'	,18						,,)
	TRCell():New(oSection1, "QTDAVEN"		, "SD2", "QTD A FATURAR" 	,'@E 999,999,999,999.99'	,18						,,)
	TRCell():New(oSection1, "APRCVEN"  	 	, "SD2", "PRV A FATURAR" 	,'@E 999,999,999,999.99'	,18						,,)
	TRCell():New(oSection1, "TOTQTD"		, "SD2", "QTD TOTAL" 		,'@E 999,999,999,999.99'	,18						,,)
	TRCell():New(oSection1, "TOTPRC"  	 	, "SD2", "PRV TOTAL" 		,'@E 999,999,999,999.99'	,18						,,)

	oReport:Section("Capa"):Cell("BM_TIPGRU" ):SetHeaderAlign("RIGHT")
	oReport:Section("Capa"):Cell("X5_DESCRI" ):SetHeaderAlign("LEFT")
	oReport:Section("Capa"):Cell("QTDVEN"    ):SetHeaderAlign("CENTER")
	oReport:Section("Capa"):Cell("PRCVEN"    ):SetHeaderAlign("CENTER")
	oReport:Section("Capa"):Cell("QTDAVEN"   ):SetHeaderAlign("CENTER")
	oReport:Section("Capa"):Cell("APRCVEN"   ):SetHeaderAlign("CENTER")
	oReport:Section("Capa"):Cell("TOTQTD"    ):SetHeaderAlign("CENTER")
	oReport:Section("Capa"):Cell("TOTPRC"    ):SetHeaderAlign("CENTER")
	
	oReport:SetLineHeight(40) 
	oReport:SetColSpace(1.05) 
	oReport:cFontBody := 'Courier New' 
	oReport:nFontBody := 10
	oReport:lBold := .F. 
	oReport:lUnderLine := .F. 
	
	oReport:Section("Capa"):Cell("BM_TIPGRU" ):SetBorder("LEFT",nil,nil,.T.)
	oReport:Section("Capa"):Cell("BM_TIPGRU" ):SetBorder("LEFT",nil,nil,.F.)
	
	oReport:Section("Capa"):Cell("QTDVEN" ):SetBorder("LEFT",nil,nil,.T.)
	oReport:Section("Capa"):Cell("QTDVEN" ):SetBorder("LEFT",nil,nil,.F.)
		
	oReport:Section("Capa"):Cell("QTDAVEN" ):SetBorder("LEFT",nil,nil,.T.)
	oReport:Section("Capa"):Cell("QTDAVEN" ):SetBorder("LEFT",nil,nil,.F.)
	
	oReport:Section("Capa"):Cell("TOTQTD" ):SetBorder("LEFT",nil,nil,.T.)
	oReport:Section("Capa"):Cell("TOTQTD" ):SetBorder("LEFT",nil,nil,.F.)
	
	oReport:Section("Capa"):Cell("TOTPRC" ):SetBorder("RIGHT",nil,nil,.T.)
	oReport:Section("Capa"):Cell("TOTPRC" ):SetBorder("RIGHT",nil,nil,.F.)
	
	
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
	Local aICMP	:= {}
	Local cICM		:= SuperGetMV("MV_ESTICM", .F.,"")
	Local cEst	:= ""
	Local cNum	:= ""
	Local nX	:= 1
	Private cNat := ""
	Private cnatpai := ''
	Private cProj := ""
	Private cdesc := "" 
	Private cDescPai := ""
 	
 	For nX := 1 to Len(cICM) 
 		If SubStr(cICM,nX,1) $ "0123456789"
 			cNum += SubStr(cICM,nX,1)
 		Else
 			If !Empty(cNum)
 				nPos := Ascan(aICMP, {|e| e[2] == Val(cNum) } ) 
 				If nPos > 0
 					aICMP[nPos][1] += ";" + cEst
 				Else
 					aAdd(aICMP, {cEst, Val(cNum)} )
 				EndIf
 				cEst := ""
 				cNum := ""
 			EndIf
 			cEst += SubStr(cICM,nX,1)
 		EndIf
 	Next nX
 	
 	TRFunction():New(oSection1:Cell("QTDVEN"),"Qtd.Total vendido" ,"SUM",,,,,.F.,.T.)
 	TRFunction():New(oSection1:Cell("QTDAVEN"),"Qtd.Total a vender"	 ,"SUM",,,,,.F.,.T.)
 	TRFunction():New(oSection1:Cell("TOTQTD"),"Qtd.Total" ,"SUM",,,,,.F.,.T.)
 	 	
 	cQuery += "SELECT *"
	cQuery += "FROM"
	cQuery += "		(SELECT BM_TIPGRU, X5_DESCRI,"
	cQuery += "			SUM(D2_QUANT) QTDVEN,"
	cQuery += "			AVG(D2_PRCVEN * "
	If  MV_PAR04 == 2 
		cQuery += "		(100 - D2_PICM )"
	Else
		cQuery += "		100	"
	EndIf
	cQuery += "			/ 100	) PRCVEN "
	cQuery += "		FROM "+ RetSqlName('SD2') +" SD2"
 	cQuery += "		INNER JOIN "+ RetSqlName('SF4') +" SF4 ON F4_FILIAL = ''"
	cQuery += "			AND D2_TES = F4_CODIGO"
	cQuery += "			AND F4_DUPLIC = 'S'"
	cQuery += "			AND SF4.D_E_L_E_T_ = ' '"
	cQuery += "		INNER JOIN "+ RetSqlName('SB1') +" SB1 ON B1_FILIAL = ''"
	cQuery += "			AND D2_COD = B1_COD"
	cQuery += "			AND SB1.D_E_L_E_T_ = ' '"
	cQuery += "		INNER JOIN "+ RetSqlName('SA1') +" SA1 ON A1_FILIAL = ''"
	cQuery += "			AND D2_CLIENTE = A1_COD AND D2_LOJA = A1_LOJA"
	cQuery += "			AND SA1.D_E_L_E_T_ = ' '"
 	cQuery += "		INNER JOIN "+ RetSqlName('SBM') +" SBM ON SBM.BM_FILIAL = SB1.B1_FILIAL"
	cQuery += "			AND SB1.B1_GRUPO = SBM.BM_GRUPO"
	cQuery += "			AND SBM.D_E_L_E_T_ = ' '"
	If !EMPTY(MV_PAR01)
 		cQuery += " 	AND	BM_TIPGRU IN ( '" + StrTran(MV_PAR01,";","','") + "' )  "
 	ENDIF
 	cQuery += " 	LEFT JOIN " + RetSqlName('SX5') + " SX5 "
	cQuery += " 	ON BM_TIPGRU = X5_CHAVE "  
	cQuery += "			AND X5_TABELA = 'V0'  AND SX5.D_E_L_E_T_ = ' ' "

	cQuery += "		WHERE SD2.D_E_L_E_T_ = ''"
	cQuery += "			AND D2_FILIAL = '"+xFilial("SD2")+"'"
 	IF !Empty(MV_PAR03)
 		cQuery += " 	AND D2_EMISSAO BETWEEN '"+ DTOS(MV_PAR02) + "' AND '" + DTOS(MV_PAR03) + "' "
 	EndIf
	cQuery += "		GROUP BY BM_TIPGRU, X5_DESCRI) AS VENDA"
	cQuery += " LEFT JOIN"
	cQuery += "		(SELECT BM_TIPGRU, X5_DESCRI,"
	//cQuery += "			SUM(C6_QTDVEN-C6_QTDLIB) QTDAVEN,
	cQuery += "			SUM(C6_QTDVEN-C6_QTDENT) QTDAVEN,"
	cQuery += "			AVG(C6_PRCVEN *"
	
	If  MV_PAR04 == 2 
		cQuery += " (100 - ( CASE 	WHEN A1_EST != '" +SM0->M0_ESTCOB + "' AND B1_ORIGEM IN ('1','2','3','8') THEN " + AllTrim(Str(GetNewPar("MV_XALIQIM",4))) 
		cQuery += " 	 			WHEN A1_EST IN ('" + StrTran(GetNewPar("MV_NORTE",""),"/","','") + "') 	  THEN " + AllTrim(Str(GetNewPar("MV_XALIQNR",4))) 	
		For nX := 1 to Len(aICMP)
			cQuery += " 			WHEN A1_EST IN ('" + StrTran(aICMP[nX,1],";","','") + "')				  THEN " + AllTrim(Str(aICMP[nX,2]))	
		Next nX
		cQuery += " 				ELSE " + AllTrim(Str(GetNewPar("MV_XALIQDM",12))) + "  END )) "
	Else
		cQuery += "	100 "
	EndIf
	
	cQuery += "	/ 100	) APRCVEN"
		
	cQuery += "		FROM "+ RetSqlName('SC6') +" SC6"
	cQuery += "		INNER JOIN "+ RetSqlName('SB1') +" SB1 ON B1_FILIAL = ''"
	cQuery += "			AND C6_PRODUTO = B1_COD"
	cQuery += "			AND SB1.D_E_L_E_T_ = ' '"
	cQuery += "		INNER JOIN "+ RetSqlName('SBM') +" SBM ON SBM.BM_FILIAL = SB1.B1_FILIAL"
	cQuery += "			AND SB1.B1_GRUPO = SBM.BM_GRUPO"
	cQuery += "			AND SBM.D_E_L_E_T_ = ' '"
	If !EMPTY(MV_PAR01)
 		cQuery += " 	AND	BM_TIPGRU IN ( '" + StrTran(MV_PAR01,";","','") + "' )  "
 	ENDIF

	cQuery += "		INNER JOIN "+ RetSqlName('SF4') +" SF4 ON F4_FILIAL = ''"
	cQuery += "			AND C6_TES = F4_CODIGO"
	cQuery += "			AND F4_DUPLIC = 'S'"
	cQuery += "			AND SF4.D_E_L_E_T_ = ' '"
	cQuery += "		INNER JOIN "+ RetSqlName('SC5') +" SC5 ON C5_FILIAL = C6_FILIAL"
	cQuery += "			AND C5_NUM = C6_NUM"
	cQuery += "			AND SC5.D_E_L_E_T_ = ' '"
	cQuery += "		INNER JOIN "+ RetSqlName('SA1') +" SA1 ON A1_FILIAL = ''"
	cQuery += "			AND C5_CLIENTE = A1_COD AND C5_LOJACLI = A1_LOJA"
	cQuery += "			AND SA1.D_E_L_E_T_ = ' '"
 	cQuery += " 	LEFT JOIN " + RetSqlName('SX5') + " SX5 "
	cQuery += " 	ON BM_TIPGRU = X5_CHAVE "  
	cQuery += "			AND X5_TABELA = 'V0'  AND SX5.D_E_L_E_T_ = ' ' "
	cQuery += "		WHERE SC6.D_E_L_E_T_ = ''"
	cQuery += "			AND C6_FILIAL = '"+xFilial("SD2")+"'"
 	//cQuery += "			AND (C6_QTDVEN - C6_QTDLIB) > 0
	cQuery += "			AND (C6_QTDVEN - C6_QTDENT) > 0"
 	IF !Empty(MV_PAR06)
 		cQuery += " 	AND C5_FECENT BETWEEN '"+ DTOS(MV_PAR05) + "' AND '" + DTOS(MV_PAR06) + "' "
 	EndIf
	cQuery += "		GROUP BY BM_TIPGRU, X5_DESCRI) AS PVABERTO ON VENDA.BM_TIPGRU = PVABERTO.BM_TIPGRU"
 	
   	cQuery := ChangeQuery(cQuery)

	CopyToClipBoard( cQuery )
	Alert( cQuery )
   	
   	IF SELECT('TRBSBM') > 0
   		TRBSBM->(DBCLOSEAREA())
   	ENDIF
	
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),"TRBSBM",.T.,.T.)
   	
 	
	TRBSBM->(DBGOTOP())
	
	oSection1:Init()
	oSection1:SetHeaderSection(.T.)                           	
	DbSelectArea('TRBSBM')
	TRBSBM->(dbGoTop())
	do while TRBSBM->(!EOF())
		NCOUNT++
		TRBSBM->(DBSKIP())
	END DO
	
	oReport:SetMeter(ncount)
	oReport:IncMeter()
	TRBSBM->(DBGOTOP())
	do while TRBSBM->(!EOF()) 	
 	   If oReport:Cancel()
 	   		Exit
	   EndIf
 		
 		oSection1:Cell("BM_TIPGRU"):SetValue(TRBSBM->(BM_TIPGRU))
		oSection1:cell("X5_DESCRI"):SetValue(TRBSBM->(X5_DESCRI))
		oSection1:cell("QTDVEN"):SetValue(TRBSBM->(QTDVEN))
		oSection1:cell("PRCVEN"):SetValue(TRBSBM->(PRCVEN))
		oSection1:cell("QTDAVEN"):SetValue(TRBSBM->(QTDAVEN))
		oSection1:cell("APRCVEN"):SetValue(TRBSBM->(APRCVEN))
		oSection1:cell("TOTQTD"):SetValue(TRBSBM->(QTDVEN + QTDAVEN))
		oSection1:cell("TOTPRC"):SetValue((TRBSBM->(PRCVEN + APRCVEN))/2)
	
		oSection1:Cell("BM_TIPGRU"):SetAlign("Right")
 		oSection1:Cell("X5_DESCRI"):SetAlign("Right")	
 		oSection1:Cell("QTDVEN"):SetAlign("Right")
		oSection1:Cell("PRCVEN"):SetAlign("Right")
		oSection1:Cell("QTDAVEN"):SetAlign("Right")
		oSection1:Cell("APRCVEN"):SetAlign("Right")
		oSection1:Cell("TOTQTD"):SetAlign("Right")
		oSection1:Cell("TOTPRC"):SetAlign("Right")
			
		oSection1:printline()
		oReport:IncMeter()
		
		TRBSBM->(DBSKIP())
	END DO
	//OREPORT:FatLine()
	oReport:Box(oreport:row(),010,oReport:row() + oreport:LineHeight()*5,oReport:PageWidth()-5 )
	oSection1:Finish()
		
Return


*---------------------------*
//---> REMOVIDO compatibilização para versão 12.1.25.
/*Static Function ValidPerg(cperg)
*---------------------------*
Local cLAlias := Alias()
Local aRegs   := {}

Aadd(aRegs,{PADR(cPerg,10),"01","Familia		       ?","","","mv_ch1","C",99								,0,0,"G","u_telagrup('MV_PAR01')"	,"mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{PADR(cPerg,10),"02","De Emissão            ?","","","mv_ch2","D",8								,0,0,"G",""				,"mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{PADR(cPerg,10),"03","Ate Emissão           ?","","","mv_ch3","D",8								,0,0,"G",""				,"mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{PADR(cPerg,10),"04","ICMS				   ?","","","mv_ch4","C",1								,0,0,"C",""				,"mv_par04","1=Não Desconta","","","","","2=Desconta","","","","","","","","","","","","","","","","","","","","","","","",""})
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




	
return
/*
User Function Telagrup(cMvPar)
Local cGrupos := ''
Local lcheck := .F. 
Local _stru := {}
Local aCpoBro := {}
Local oDlgLocal 
Local cQuery := '' 
Local aButtons := {}
Local cTab  := "TTRB" 
Private aCores := {}
Private lInverte := .F.
Private cMark   := GetMark()   
Private oMark

Aadd( aButtons, {"Mark", {|| u_mktodos(@cTab)}, "Marca/Desmarca todos", "Marca/Desmarca todos" , {|| .T.}} )   

//IF EMPTY(cMvPar)
	//Cria um arquivo de Apoio
	AADD(_stru,{"OK"     ,"C"	,2		,0		})
	AADD(_stru,{"COD"    ,"C"	,6		,0		})
	AADD(_stru,{"Desc"   ,"C"	,40		,0		})
	
	cArq:=Criatrab(_stru,.T.)
	DBUSEAREA(.t.,,carq,"TTRB")
	//Alimenta o arquivo de apoio com os registros do cadastro de clientes (SA1)
	//DbSelectArea("SA1")
	
	cQuery := "SELECT * from SX5010 WHERE X5_TABELA = 'V0' and D_E_L_E_T_ = ' ' order by X5_CHAVE "
	
	IF Select('TRBV0') > 1
		TRBV0->(DBCLOSEAREA())
	ENDIF
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRBV0',.F.,.T.)
	TRBV0->(DbGotop())
	
	do While  TRBV0->(!Eof())	
		DbSelectArea("TTRB")	
		RecLock("TTRB",.T.)		
			TTRB->COD     :=  TRBV0->(X5_CHAVE)		
			TTRB->DESC    :=  TRBV0->(X5_DESCRI)			
		MsunLock()	
		TRBV0->(DbSkip())
	Enddo
	
	//Define quais colunas (campos da TTRB) serao exibidas na MsSelect
	aCpoBro	:= {{ "OK"			,, "Mark"           ,"@!"},;
				{ "COD"			,, "Codigo"         ,"@!"},;
				{ "DESC"		,, "Descrição"           ,"@1!"}}
				//Cria uma Dialog
				
	DEFINE MSDIALOG oDlg TITLE "Seleção de Famílias" From 9,0 To 315,800 PIXEL
	DbSelectArea("TTRB")
	DbGotop()//Cria a MsSelect
	
	oMark := MsSelect():New("TTRB","OK","",aCpoBro,@lInverte,@cMark,{37,5,150,400},,,,,)
	oMark:bMark := {| | Disp()} //Exibe a Dialog
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| oDlg:End()},{|| oDlg:End()},, @aButtons)
	
	//Fecha a Area e elimina os arquivos de apoio criados em disco.
	
	TTRB->(DBGOTOP())
	DO WHILE TTRB->(!EOF())
		If Marked("OK")	
			IF EMPTY(cGrupos)
				cGrupos += alltrim(TTRB->(COD)) 
			else
				cGrupos += ";" + alltrim(TTRB->(COD))
			endif
		Endif
		TTRB->(DBSKIP())
	END DO
	
	TTRB->(DbCloseArea())
	
	Iif(File(cArq + GetDBExtension()),FErase(cArq  + GetDBExtension()) ,Nil)
	
	If FwIsInCallStack("U_RELFAT") .Or. FwIsInCallStack("U_FSREPR01")
		MV_PAR05 := cGrupos
	ElseIf FwIsInCallStack("U_RELRP02")
		MV_PAR03 := cGrupos
	ElseIf FwIsInCallStack("U_RELRP04")
		MV_PAR24 := cGrupos
	ElseIf FwIsInCallStack("U_RELRP01")
		MV_PAR01 := cGrupos
	EndIf

Return .T.
*/		
//Funcao executada ao Marcar/Desmarcar um registro.   
			
Static Function Disp()

RecLock("TTRB",.F.)

If Marked("OK")	

	TTRB->OK := cMark

Else	

TTRB->OK := ""

Endif             
			
MSUNLOCK()

oMark:oBrowse:Refresh()
			

Return 


//---> REMOVIDO compatibilização para versão 12.1.25.
/*Static Function CriaPar()
Local aPars := {}
aAdd(aPars, {"MV_RPR1TES", "C", "Tes para relatorio",   "'501','502'"} )
u_zCriaPar(aPars)
Return*/


/*/{Protheus.doc} zCriaPar
Função para criação de parâmetros (SX6)
@type function
@author Atilio
@since 12/11/2015
@version 1.0
    @param aPars, Array, Array com os parâmetros do sistema
    @example
    u_zCriaPar(aParametros)
    @see https://terminaldeinformacao.com
    @obs Abaixo a estrutura do array:
        [01] - Parâmetro (ex.: "MV_X_TST")
        [02] - Tipo (ex.: "C")
        [03] - Descrição (ex.: "Parâmetro Teste")
        [04] - Conteúdo (ex.: "123;456;789")
/*/
 
//---> REMOVIDO compatibilização para versão 12.1.25.
/*User Function zCriaPar(aPars)
    Local nAtual        := 0
    Local aArea        := GetArea()
    Local aAreaX6        := SX6->(GetArea())
    Default aPars        := {}
     
    DbSelectArea("SX6")
    SX6->(DbGoTop())
     
    //Percorrendo os parâmetros e gerando os registros
    For nAtual := 1 To Len(aPars)
        //Se não conseguir posicionar no parâmetro cria
        If !(SX6->(DbSeek(xFilial("SX6")+aPars[nAtual][1])))
            RecLock("SX6",.T.)
                //Geral
                X6_VAR        :=    aPars[nAtual][1]
                X6_TIPO    :=    aPars[nAtual][2]
                X6_PROPRI    :=    "U"
                //Descrição
                X6_DESCRIC    :=    aPars[nAtual][3]
                X6_DSCSPA    :=    aPars[nAtual][3]
                X6_DSCENG    :=    aPars[nAtual][3]
                //Conteúdo
                X6_CONTEUD    :=    aPars[nAtual][4]
                X6_CONTSPA    :=    aPars[nAtual][4]
                X6_CONTENG    :=    aPars[nAtual][4]
            SX6->(MsUnlock())
        EndIf
    Next
     
    RestArea(aAreaX6)
    RestArea(aArea)
Return*/


User Function MkTodos(cTab)


&(ctab)->(Dbgotop())

Do while &(ctab)->(!eof())
	RecLock(cTab,.F.)
	
	If Marked("OK")	
	
		(ctab)->OK := ""
	
	Else	
		(ctab)->OK := cMark
		
	
	Endif
	MSUNLOCK()
	&(ctab)->(Dbskip())             
end do			

&(ctab)->(Dbgotop())
//oMark:oBrowse:Refresh()
omark:oBrowse:Refresh()

Return
