#include 'protheus.ch'
#include 'parmtype.ch'
#include "rwmake.ch"
#include "topconn.ch"
// Mapa de vendas por estado

user function relrp03()

Local cquery := ""
local oReport  
local cPerg := Padr("RELRP03",10)
Local cquery := ""
local oReport        
Local aTables := {'SA1'}

Local bOk 		:= {|| .T. }
Local aPar 		:= {}
Private aRet 	:= {}

aAdd( aPar,{ 1,"Filial(is) "				,Space(200) 			,"",""			,"FILIAL"	,""		,60,.F.} )
aAdd( aPar,{ 1,"Estado(s) "					,Space(200) 			,"",""			,"ESTADO"	,""		,60,.F.} )
aAdd( aPar,{ 1,"Emissao De	"    			,CtoD(Space(8))	 		,""	,""			,""			,""		,60,.F.} )
aAdd( aPar,{ 1,"Emissao Ate	"    			,CtoD(Space(8))	 		,""	,""			,""			,""		,60,.F.} )   

If !ParamBox( aPar, 'Carteira por Família', @aRet, bOK, , , , , , , .T., .T. )
	Return
EndIf

MV_PAR01 := aRet[1]
MV_PAR02 := aRet[2]
MV_PAR03 := aRet[3]
MV_PAR04 := aRet[4]

oReport := RptDef()
oReport:printDialog()

Return
 
Static Function RptDef()
   	
	local oReport := NIL
	Local oSection1:= Nil
	Local oSection2:= Nil
	
	Local oFunction
	local cTitulo := 'Mapa de vendas por estado'
	
   	oReport := TReport():New('TRBSF2', cTitulo,, {|oReport| ReportPrint(oReport)},'Mapa de vendas por estado')
    oReport:SetLandscape()
    oReport:SetTotalInLine(.F.)
	
	oSection1 := TRSection():New(oReport,"Capa",{"SB1", "SB2", "SB9"},,.F.,.T.)
	oSection1:SetTotalInLine(.F.)  	
    oSection1:SetPageBreak  (.T.)
    
   	TRCell():New(oSection1, "F2_EST"	 	, "SF2", "Estado"   		,PesqPict('SF2',"F2_EST")  		,TamSX3("F2_EST")[1]+1		,/*lPixel*/,/*{|| code-block de impressao }*/)
 	TRCell():New(oSection1, "QTDNOT"		, "SF2", "Notas faturadas"	,PesqPict('SD2',"D2_QUANT")  	,TamSX3("D2_QUANT")[1]+1		,/*lPixel*/,/*{|| code-block de impressao }*/)
 	TRCell():New(oSection1, "QTPROD"	 	, "SD2", "Quantidade"	 	,PesqPict('SD2',"D2_QUANT")  	,TamSX3("D2_QUANT")[1]+1		,/*lPixel*/,/*{|| code-block de impressao }*/)
 	TRCell():New(oSection1, "F2_VALBRUT"	, "SF2", "Total Faturado R$",PesqPict('SF2',"F2_VALBRUT")	,TamSX3("F2_VALBRUT")[1]+1		,/*lPixel*/,/*{|| code-block de impressao }*/)
 	TRCell():New(oSection1, "UNITMED"	 	, "SF2", "Unitário médio"	,PesqPict('SF2',"F2_VALBRUT")  	,TamSX3("F2_VALBRUT")[1]+1		,/*lPixel*/,/*{|| code-block de impressao }*/)
 	TRCell():New(oSection1, "QTDDEVO" 		, "SF2", "Qtd Devolvida"	,PesqPict('SD2',"D2_QUANT")  	,TamSX3("D2_QUANT")[1]+1		,/*lPixel*/,/*{|| code-block de impressao }*/)
 	TRCell():New(oSection1, "VALDEV" 		, "SF2", "Devolução"  		,PesqPict('SF2',"F2_VALBRUT")  	,TamSX3("F2_VALBRUT")[1]+1		,/*lPixel*/,/*{|| code-block de impressao }*/)
 	TRCell():New(oSection1, "PART"	 		, "SF2", "% Participação"	,PesqPict('SF2',"F2_VALBRUT")  	,TamSX3("F2_VALBRUT")[1]+1		,/*lPixel*/,/*{|| code-block de impressao }*/)
    
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
	//Local lnatureza := iif(MV_PAR16 == 1, .T.,.F.)
	//Local lnatSint := iif(MV_PAR17 == 1, .T.,.F.)
	Local ncount := 0
	Local nsecini := 0
	local nsecfim := 0
	//Local cnat := ''
	
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
	Local nTot := 0
	Local nDias := 0
	Local cVar := 'CVAR CVAR'
	Private cNat := ""
	Private cnatpai := ''
	Private cProj := ""
	Private cdesc := "" 
	Private cDescPai := ""
 	
 	oSection1:SetTotalText("Total Geral")
 	TRFunction():New(oSection1:Cell("F2_VALBRUT"),"Faturamento Total" ,"SUM",,,,,.F.,.T.)
 	
	cQuery += " SELECT F2_EST, COUNT(*)  AS CONT, SUM(F2_VALBRUT) AS VALBRUT,AVG(D2_PRCVEN) AS PRMED, "
	cQuery += " 		(SELECT COUNT(DISTINCT(DDEV.D2_DOC)) "
	cQuery += " 				FROM " + RetSqlName('SD2') + " DDEV "
	cQuery += " 				WHERE DDEV.D_E_L_E_T_ = ' ' "
	cQuery += " 					AND (D2_TES = '70' OR D2_TES = '81' OR D2_TES = '82') AND F2.F2_EST = DDEV.D2_EST ) AS QTDEV,  "
	cQuery += " 		 (SELECT SUM(DVAL.D2_TOTAL) 
	cQuery += " 				FROM " + RETSQLNAME('SD2') + " DVAL "
	cQuery += " 				WHERE DVAL.D_E_L_E_T_ = ' ' AND (D2_TES = '70' OR D2_TES = '81' OR D2_TES = '82') "
	cQuery += " 					AND F2.F2_EST = DVAL.D2_EST ) AS VALDEV, " 
	cQuery += " 		SUM(F2.F2_VALBRUT)/
	cQuery += " 		(SELECT SUM(DPART.F2_VALBRUT) "
	cQuery += "	 			FROM "	+ RETSQLNAME('SF2') + " DPART "
	cQuery += "				WHERE DPART.D_E_L_E_T_ = ' ') * 100 AS VALPART "
	
	cQuery += " FROM " + RETSQLNAME('SF2') + " F2 "
	cQuery += " INNER JOIN " + RETSQLNAME('SD2') + " D2 "
	cQuery += " ON F2_FILIAL = D2_FILIAL AND "
	cQuery += " 	F2_DOC = D2_DOC AND "
	cQuery += " 	F2_SERIE = D2_SERIE AND "
	cQuery += " 	F2_CLIENTE = D2_CLIENTE AND "
	cQuery += " 	F2_LOJA = D2_LOJA "
	
	cQuery += " WHERE F2.D_E_L_E_T_ = ' ' AND D2.D_E_L_E_T_ = ' ' AND "
	
	If Empty(MV_PAR01)
		cQuery += " F2.F2_FILIAL = '" + xFilial("SF2") + "' AND "
	Else
		cQuery += " F2.F2_FILIAL IN ( '" + StrTran(MV_PAR01,";","','") + "' ) AND "
	EndIf
	
	If !Empty(MV_PAR02)
		cQuery += " F2.F2_EST IN ( '" + StrTran(MV_PAR02,";","','") + "' ) AND "
	EndIf
	
	If !Empty(MV_PAR04)
		cQuery += " F2.F2_EMISSAO BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "' AND "
	EndIf
	
	cQuery += " D2.D2_TES NOT IN ('70','81','82') "
	
	cQuery += " GROUP BY F2_EST" 
	cQuery += " ORDER BY VALPART DESC"
   	
   	cQuery := ChangeQuery(cQuery)
   	
   	IF SELECT('TRBSF2') > 0
   		TRBSF2->(DBCLOSEAREA())
   	ENDIF
	
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),"TRBSF2",.T.,.T.)
   	
 	
	TRBSF2->(DBGOTOP())
	
	oSection1:Init()
	oSection1:SetHeaderSection(.T.)                           	
	DbSelectArea('TRBSF2')
	TRBSF2->(dbGoTop())
	do while TRBSF2->(!EOF())
		NCOUNT++
		TRBSF2->(DBSKIP())
	END DO
	
	oReport:SetMeter(ncount)
	oReport:IncMeter()
	TRBSF2->(DBGOTOP())
	do while TRBSF2->(!EOF()) 	
 	   If oReport:Cancel()
 	   		Exit
	   EndIf
 
	
		/*oSection1:Cell("BM_TIPGRU"):SetValue(TRBSF2->(BM_TIPGRU))
		oSection1:Cell("BM_TIPGRU"):SetAlign("LEFT")		
		
		oSection1:cell("X5_DESCRI"):SetValue(TRBSF2->(X5_DESCRI))
		oSection1:Cell("X5_DESCRI"):SetAlign("LEFT")*/
		
		oSection1:cell("F2_EST"):SetValue(TRBSF2->(F2_EST))
		oSection1:Cell("F2_EST"):SetAlign("Right")
		
		oSection1:cell("QTDNOT"):SetValue(TRBSF2->(cont))
		oSection1:Cell("QTDNOT"):SetAlign("Right")
		
		oSection1:cell("QTPROD"):SetValue(TRBSF2->(cont))
		oSection1:Cell("QTPROD"):SetAlign("Right")
		
		oSection1:cell("F2_VALBRUT"):SetValue(TRBSF2->(valbrut))
		oSection1:Cell("F2_VALBRUT"):SetAlign("Right")
		
		oSection1:cell("UNITMED"):SetValue(TRBSF2->(PRMED))
		oSection1:Cell("UNITMED"):SetAlign("Right")
		
		oSection1:cell("QTDDEVO"):SetValue(TRBSF2->(QTDEV))
		oSection1:Cell("QTDDEVO"):SetAlign("Right")
		
		oSection1:cell("VALDEV"):SetValue(TRBSF2->(VALDEV))
		oSection1:Cell("VALDEV"):SetAlign("Right")
		
		oSection1:cell("PART"):SetValue(VALPART)
		oSection1:Cell("PART"):SetAlign("Right")
		

		nTot += TRBSF2->(valbrut)
		
		oSection1:printline()
		oReport:IncMeter()
		
		TRBSF2->(DBSKIP())
	END DO
	
	oSection1:Finish()
	OREPORT:FatLine()
	oReport:Box(oreport:row(),010,oReport:row() + oreport:LineHeight()*5,oReport:PageWidth() )
	OREPORT:FatLine()
	nDias := DateDiffDay(MV_PAR04,MV_PAR03)
	oreport:printtext('Faturamento médio diário: ' +  transform(nTot / nDias, '@E 999,999,999,999.99'), oreport:row(),oReport:line()) 
	oreport:printtext('Período de: ' +  DTOC(MV_PAR03) + ' a ' + DTOC(MV_PAR04) + ', total de ' + alltrim(str(DateDiffDay(MV_PAR04,MV_PAR03))) + ' dias.' , oreport:row(),oReport:line()) 
	//msginfo("SEGUNDOS CALCULADOS: CONTADOR 1 E 2 =" + STR(NCOUNT2 - NCOUNT1) + CRLF + "CONTADOR 3 E 4 =" + STR(NCOUNT4 - NCOUNT3) + CRLF +"CONTADOR 5 E 6 =" + STR(NCOUNT6 - NCOUNT5) + CRLF + "CONTADOR 7 E 8 =" + STR(NCOUNT8 - NCOUNT7) + CRLF + "CONTADOR 9 E 10 =" + STR(NCOUNT10 - NCOUNT9) + CRLF + "Tempo TOTAL (em segundos) :" + STR(ncount10 - ncount1))
Return


*---------------------------*
//---> REMOVIDO compatibilização para versão 12.1.25.
/*Static Function ValidPerg(cperg)
*---------------------------*
Local cLAlias := Alias()
Local aRegs   := {}

Aadd(aRegs,{PADR(cPerg,10),"01","Filial			?","","","mv_ch1","C",60							,0,0,"G","u_telafil('MV_PAR01')"	,"mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{PADR(cPerg,10),"02","Estado			?","","","mv_ch2","C",60							,0,0,"G","u_telaest('MV_PAR02')"	,"mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{PADR(cPerg,10),"03","Dt Inicial     ?","","","mv_ch3","D",8								,0,0,"G",""							,"mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{PADR(cPerg,10),"04","Dt Final       ?","","","mv_ch4","D",8								,0,0,"G",""							,"mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
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
User Function TelaEst(cmvpar)
Local cGrupos := ''
Local lcheck := .F. 
Local _stru := {}
Local aCpoBro := {}
Local oDlgLocal 
Local cQuery := '' 
Local cEst := ''
Local ctab := 'TTEST'
Local aButtons := {}
Private aCores := {}
Private lInverte := .F.
Private cMark   := GetMark()   
Private oMark
*/

//IF EMPTY(&(cmvpar))
	//Cria um arquivo de Apoio
/*	
	AADD(_stru,{"OK"    ,"C"	,2		,0		})
	AADD(_stru,{"Estado","C"	,2		,0		})
	AADD(_stru,{"Desc" 	,"C"	,30		,0		})
	
	cArq:=Criatrab(_stru,.T.)
	DBUSEAREA(.t.,,carq,"TTEST")
	//Alimenta o arquivo de apoio com os registros do cadastro de clientes (SA1)
	cQuery := "SELECT * from SX5010 WHERE X5_TABELA = '12' and D_E_L_E_T_ = ' ' order by X5_CHAVE "
	
	IF Select('TRBEST') > 1
		TRBEST->(DBCLOSEAREA())
	ENDIF
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRBEST',.F.,.T.)
	TRBEST->(DbGotop())
	
	do While  TRBEST->(!Eof())
		
			DbSelectArea("TRBEST")	
			RecLock("TTEST",.T.)		
				TTEST->Estado  	:= TRBEST->(X5_CHAVE)		
				TTEST->DESC 	:= TRBEST->(X5_DESCRI)					
			MsunLock()	
		
		TRBEST->(DbSkip())
	Enddo
	
	//Define quais colunas (campos da TTRB) serao exibidas na MsSelect
	aCpoBro	:= {{ "OK"			,, "Mark"           ,"@!"},;
				{ "Estado"		,, "Estado"        ,"@!"},;
				{ "Desc"		,, "Descricao"         ,"@!"}}
				//Cria uma Dialog
				
	DEFINE MSDIALOG oDlg TITLE "MarkBrowse c/Refresh" From 9,0 To 315,800 PIXEL
	Aadd( aButtons, {"Mark", {|| u_mktodos(@cTab)}, "Marca/Desmarca todos", "Marca/Desmarca todos" , {|| .T.}} )
	DbSelectArea("TTEST")
	DbGotop()//Cria a MsSelect
	
	omark := MsSelect():New("TTEST","OK","",aCpoBro,@lInverte,@cMark,{17,1,150,400},,,,,)
	omark:bMark := {| | DPEST()} //Exibe a Dialog
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| oDlg:End()},{|| oDlg:End()},,@aButtons)
	
	//Fecha a Area e elimina os arquivos de apoio criados em disco.
	
	TTEST->(DBGOTOP())
	DO WHILE TTEST->(!EOF())
		If Marked("OK")	
			IF EMPTY(cEst)
				cEst +=  alltrim(TTEST->(Estado)) 
			else
				cEst += ";" + alltrim(TTEST->(Estado)) 
			endif
		Endif
		TTEST->(DBSKIP())
	END DO
	
	TTEST->(DbCloseArea())

	Iif(File(cArq + GetDBExtension()),FErase(cArq  + GetDBExtension()) ,Nil)
	
	MV_PAR02 := cEst
	
//ENDIF

Return .T.
*/

/*
Static Function DPEST()

RecLock("TTEST",.F.)

If Marked("OK")	

	TTEST->OK := cMark

Else	

TTEST->OK := ""

Endif             
			
MSUNLOCK()

omark:oBrowse:Refresh()
			

Return 	
*/
