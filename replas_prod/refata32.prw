#INCLUDE "TOTVS.CH"
#INCLUDE "APVT100.CH"

#DEFINE CLR_LARANJA RGB(255,128,0  )
#DEFINE CLR_BRANCA  RGB(255,255,255)

#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#include "protheus.ch"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RptDef.ch"
#include 'parmtype.ch'
#include 'topconn.ch'

User Function refata32()

Local aArea    := GetArea()
//Parâmetros do Relatório.
//Local lAdjustToLegacy := .T.
//Local lDisableSetup   := .T.
//Local _cFile          
Local cBorda          := "-2"


//Cria as fontes que serão usadas no relatório.
//TFont(): New ( [ cName], [ uPar2], [ nHeight], [ uPar4], [ lBold], [ uPar6], [ uPar7], [ uPar8], [ uPar9], [ lUnderline], [ lItalic] ) --> oObjeto


//Local oFont14AN  := TFont():New( "Arial",/*2*/,11,/*4*/,.T.,/*6*/,/*7*/,/*8*/,/*9*/,.F.,.F.) //Arial - 11 - Negrito.
//Local oFont14A   := TFont():New( "Arial",/*2*/,11,/*4*/,.F.,/*6*/,/*7*/,/*8*/,/*9*/,.F.,.F.) //Arial - 11.

Local oFont16A   := TFont():New( "Arial",/*2*/,16,/*4*/,.F.,/*6*/,/*7*/,/*8*/,/*9*/,.F.,.F.) //Arial - 16.
Local oFont16AN  := TFont():New( "Arial",/*2*/,16,/*4*/,.T.,/*6*/,/*7*/,/*8*/,/*9*/,.F.,.F.) //Arial - 16 Negrito.

//Local oFont18A   := TFont():New( "Arial",/*2*/,18,/*4*/,.F.,/*6*/,/*7*/,/*8*/,/*9*/,.F.,.F.) //Arial - 16.
//Local oFont18AN  := TFont():New( "Arial",/*2*/,18,/*4*/,.T.,/*6*/,/*7*/,/*8*/,/*9*/,.F.,.F.) //Arial - 16 Negrito.

Local oFont20AN  := TFont():New( "Arial",/*2*/,20,/*4*/,.T.,/*6*/,/*7*/,/*8*/,/*9*/,.F.,.F.) //Arial - 11 - Negrito.
Local oFont20A   := TFont():New( "Arial",/*2*/,20,/*4*/,.F.,/*6*/,/*7*/,/*8*/,/*9*/,.F.,.F.) //Arial - 11.

//Local oFont18TA   := TFont():New( "Tahoma",/*2*/,18,/*4*/,.F.,/*6*/,/*7*/,/*8*/,/*9*/,.F.,.F.) //Arial - 11.
//Local oFont18TAN  := TFont():New( "Tahoma",/*2*/,18,/*4*/,.T.,/*6*/,/*7*/,/*8*/,/*9*/,.F.,.F.) //Arial - 11.

//Local oFont20TA   := TFont():New( "Tahoma",/*2*/,20,/*4*/,.F.,/*6*/,/*7*/,/*8*/,/*9*/,.F.,.F.) //Arial - 11.
//Local oFont20TAN  := TFont():New( "Tahoma",/*2*/,20,/*4*/,.T.,/*6*/,/*7*/,/*8*/,/*9*/,.F.,.F.) //Arial - 11.

//Local oFont20TN  := TFont():New( "Times New Roman",/*2*/,20,/*4*/,.T.,/*6*/,/*7*/,/*8*/,/*9*/,.F.,.F.) //Times New Roman - 20 - Negrito.

Local oFont24TN  := TFont():New( "Times New Roman",/*2*/,24,/*4*/,.T.,/*6*/,/*7*/,/*8*/,/*9*/,.F.,.F.) //Times New Roman - 24 - Negrito.

//Local oBrush     := TBrush():New(,CLR_LARANJA)

//Variáveis usadas para as posições do relatório.
Local nLin    := 001
Local nPulLin := 035
Local nPixelX := 0
Local nPixelY := 0
Local _aTotPrd:={}
Local nHPage  := 0
Local nVPage  := 0
Local aCol        := Array(10)
Local _cQry       := ""
Local _cQuebra    := ""
Local _nTotProd   := 0
Local _lAutoImp   := IsInCallStack("U_IMPAUT")	
Local _nPagina    := 0		
Local _TotPPLiq   := 0	
Local _TotPPBrt   := 0	
Local _nPalVol    := GetQtdPallet()
Local cFilePrint := "RomCli_" + strtran(time(),":","")
Local _nQtdBTot  := 0
Local _nQtdLTot  := 0
Local _nQtdBobs  := 0
Local cObsRoman  := IIF(SZG->(FIELDPOS("ZG_OBS"))>0, AllTrim(SZG->ZG_OBS), "")
Local aAuxObs    := QbTexto(cObsRoman, 50, " ")

Default _cCarga   := Space(6)
Default _cCliente := Space(6)
Default _cLoja    := Space(2)

Pergunte("REFATA30", .F.)

_cQry := " SELECT DISTINCT C5_NOTA, C5_SERIE, ZG_PEDIDO,A1_NOME,A1_END,A1_BAIRRO,A1_MUN,A1_CEP,A1_EST ,B1_DESC, ZG_VOLUME,ZH_PROD, ZH_LOTECTL, ZH_NUMLOTE, ZG_PESOPAL, ZH_QTDORI,ZG_PALLET,ZH_VLDLOTE,C5_PBRUTO, C5_PESOL,C5_MENNOTA,ZG_ITEMPV "
_cQry += " FROM "+RetSqlName("SZG")+" SZG  "
_cQry += " INNER JOIN "+RetSqlName("SZH")+" SZH ON ZH_FILIAL=ZG_FILIAL AND ZH_VOLUME=ZG_VOLUME AND SZH.D_E_L_E_T_ = ' ' "
_cQry += " INNER JOIN "+RetSqlName("SC5")+" SC5 ON C5_FILIAL=ZG_FILIAL AND C5_NUM=ZG_PEDIDO AND SC5.D_E_L_E_T_ = ' ' "
_cQry += " INNER JOIN "+RetSqlName("SB1")+" SB1 ON  B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD=ZH_PROD AND SB1.D_E_L_E_T_ = ' ' "
_cQry += " INNER JOIN "+RetSqlName("SA1")+" SA1 ON  A1_FILIAL = '"+xFilial("SB1")+"' AND A1_COD = C5_CLIENTE AND A1_LOJA=C5_LOJACLI AND SA1.D_E_L_E_T_ = ' ' "
_cQry += " WHERE ZG_FILIAL = '"+xFilial("SZG")+"' " 
_cQry += " AND   ZG_PEDIDO = '"+SZG->ZG_PEDIDO+"' "
If MV_PAR01 == 1
	_cQry += " AND   ZG_ITEMPV = '"+SZG->ZG_ITEMPV+"' "
EndIf
_cQry += " AND   SZG.D_E_L_E_T_ = ' ' "
_cQry += " ORDER BY ZG_PEDIDO, ZG_VOLUME,ZH_PROD, ZH_LOTECTL, ZH_NUMLOTE, ZG_PESOPAL "

If Select("TRBROMCLI")>0
	TRBROMCLI->(DbCloseArea())
EndIf

TCQUERY _cQry New Alias "TRBROMCLI"

If TRBROMCLI->(Eof())
	If !_lAutoImp
		MsgInfo("Sem registros para imprimir, verifique os parametros")
	EndIf
    restArea(aArea)
	Return
EndIf	
/*
oPrn := U_FWMS(  _cFile     ;    // < cFilePrintert >
                            ,IMP_PDF  ;    // [ nDevice]
                            ,;               // [ lAdjustToLegacy]
                            ,'mcfiles\tmp\'; // [ cPathInServer]
                            ,_lAutoImp;      // [ lDisabeSetup ]
                            )               // [ nQtdCopy] )
*/
oPrn := FWMSPrinter():New(cFilePrint, IMP_PDF,,, .T.)
/*
oPrn := FWMsPrinter():New (  _cFile     ;    // < cFilePrintert >
                            ,IMP_PDF  ;    // [ nDevice]
                            ,;               // [ lAdjustToLegacy]
                            ,'mcfiles\tmp\'; // [ cPathInServer]
                            ,_lAutoImp;               // [ lDisabeSetup ]
                            ,;               // [ lTReport]
                            ,;               // [ @oPrintSetup]
                            ,;               // [ cPrinter]
                            ,;               // [ lServer]
                            ,;               // [ lPDFAsPNG]
                            ,;               // [ lRaw]
                            ,;               // [ lViewPDF]
                            ,)               // [ nQtdCopy] )
*/

If _lAutoImp
	If oSetup:GetProperty(PD_PRINTTYPE) == IMP_SPOOL
		oPrn:nDevice := IMP_SPOOL
		// ----------------------------------------------
		// Salva impressora selecionada
		// ----------------------------------------------
		fwWriteProfString(GetPrinterSession(),"DEFAULT", oSetup:aOptions[PD_VALUETYPE], .T.)
		oPrn:cPrinter := oSetup:aOptions[PD_VALUETYPE]
	ElseIf oSetup:GetProperty(PD_PRINTTYPE) == IMP_PDF
		oPrn:nDevice := IMP_PDF
		// ----------------------------------------------
		// Define para salvar o PDF
		// ----------------------------------------------
		oPrn:cPathPDF := oSetup:aOptions[PD_VALUETYPE]
	Endif
EndIf	


//oPrn := FWMSPrinter():New(_cFile, IMP_PDF,,"\mcfiles\tmp\",,,,,.F.)// Ordem obrigátoria de configuração do relatório

//oPrn:lInJob   := .F.
//oPrn:cPathPDF := "mcfiles\tmp\" // Caso seja utilizada impressão em IMP_PDF
//oPrn:cPrinter := "pdf"

oPrn:SetResolution(78)
oPrn:SetPortrait()

oPrn:SetPaperSize(DMPAPER_A4)
oPrn:SetMargin(100,100,100,100) // nEsquerda, nSuperior, nDireita, nInferior

nPixelX := oPrn:nLogPixelX()
nPixelY := oPrn:nLogPixelY()

oPrn:StartPage()

nHPage := oPrn:nHorzRes()
nVPage := oPrn:nVertRes()

nHPage := oPrn:nHorzRes()
nHPage *= (300/nPixelX)
nHPage -= 30

nVPage := oPrn:nVertRes()
nVPage *= (300/nPixelY)
nVPage -= 30


//FWMsPrinter(): SayBitmap ( < nRow>, < nCol>, < cBitmap>, [ nWidth], [ nHeight] ) -->
oPrn:SayBitmap(nLin, 001, GetSrvProfString( "Startpath", "" ) + "rpsoplogo.jpg", 1000, 260)
nLin+=nPulLin + 10
//oPrn:Say(nLin,(nHPage/2)-400,"LISTA DE EMBARQUE",oFont24TN)
oPrn:Say(nLin,1200,"LISTA DE EMBARQUE",oFont24TN)

nLin += nPulLin * 1.5
oPrn:Say(nLin,1200,"NFE:",oFont20AN)
oPrn:Say(nLin,1500,AllTrim(TRBROMCLI->C5_NOTA) + "-" + AllTrim(TRBROMCLI->C5_SERIE),oFont20A)

nLin += nPulLin * 1.5
oPrn:Say(nLin,1200,"PEDIDO:",oFont20AN)
oPrn:Say(nLin,1500,TRBROMCLI->ZG_PEDIDO,oFont20A)

If !Empty(TRBROMCLI->C5_MENNOTA)
	nLin += nPulLin * 1.5
	oPrn:Say(nLin,1200,AllTrim(TRBROMCLI->C5_MENNOTA),oFont20A)
EndIf

nLin += nPulLin * 1.5
/*
oPrn:Say(nLin,1200,"SV:" ,oFont20AN)
oPrn:Say(nLin,1500,SC5->C5_XFILDES + "-" + SC5->C5_XPVDEST ,oFont20A)
*/
nLin += nPulLin * 2
nLin+=nPulLin + 10
oPrn:Line(nLin-15,001,nLin-15,nHPage)

//FWMsPrinter(): Say ( < nRow>, < nCol>, < cText>, [ oFont], [ nWidth], [ nClrText], [ nAngle] ) -->

nLin += nPulLin

oPrn:Say(nLin,001,"Cliente:",oFont16AN)
oPrn:Say(nLin,180,SubStr(TRBROMCLI->A1_NOME,1,38),oFont16A)

/*
oPrn:Say(nLin,1200,"Carga:",oFont14AN)
oPrn:Say(nLin,1500,_cCarga,oFont14AN)

nLin += nPulLin
*/

oPrn:Say(nLin,1550,"Data/Hora:",oFont16AN)
oPrn:Say(nLin,1800,dtoc(Date()) + " - " + SubStr(Time(),1,5),oFont16A)

nLin += nPulLin +10

oPrn:Say(nLin,180,SubStr(TRBROMCLI->A1_END,1,38),oFont16A)

oPrn:Say(nLin,1550,"Bairro:",oFont16AN)
oPrn:Say(nLin,1800,TRBROMCLI->A1_BAIRRO,oFont16A)

nLin += nPulLin +10

oPrn:Say(nLin,180,RTRIM(TRBROMCLI->A1_MUN) + " - " + TRBROMCLI->A1_EST,oFont16A)

oPrn:Say(nLin,1550,"CEP:",oFont16AN)
oPrn:Say(nLin,1800,LEFT(TRBROMCLI->A1_CEP,5) + "-" + RIGHT(TRBROMCLI->A1_CEP,3),oFont16A)

/*
oPrn:Say(nLin,1200,"Pedido:",oFont16AN)
oPrn:Say(nLin,1500,TRBROMCLI->ZG_PEDIDO,oFont16A)
*/

nLin += nPulLin

oPrn:Line(nLin,001,nLin,nHPage)

//oPrn:Box( nLin,001,nLin+(nPulLin*6),nHPage,cBorda)

//FillRect ( < aRect>, [ oBrush] ) --> NIL

//Valores das colunas
aCol[1] := 0001
aCol[2] := 0230
aCol[3] := 0410
//aCol[4] := 0730
aCol[5] := 1155
aCol[6] := 1370
aCol[7] := 1900
aCol[8] := 2120


/*
For a:=1 to 4
	oPrn:Line(nLin + 1 + (nPulLin*a),aCol[1],nLin + 1 + (nPulLin*a),nHPage-1,,cBorda)
Next a
*/

//oPrn:FillRect({nLin+1,002,(nLin-1)+(nPulLin),nHPage-1},oBrush)
nLin += nPulLin*2

oPrn:Say(nLin - 10,aCol[1] + 020,"Pedido"     ,oFont16AN)
oPrn:Say(nLin - 10,aCol[2] + 020,"Pallet"     ,oFont16AN)
oPrn:Say(nLin - 10,aCol[3] + 020,"Produto"    ,oFont16AN)
//oPrn:Say(nLin - 10,aCol[4] + 020,"Descricao"  ,oFont16AN)
oPrn:Say(nLin - 10,aCol[5] + 040,"P.Liq."     ,oFont16AN)
oPrn:Say(nLin - 10,aCol[6] + 020,"Lote"       ,oFont16AN)
oPrn:Say(nLin - 10,aCol[7] + 015,"Sub-Lote"   ,oFont16AN)
If !Empty(TRBROMCLI->ZH_VLDLOTE)
	oPrn:Say(nLin - 10,aCol[8] + 020,"Validade"   ,oFont16AN)
EndIf	

/*
Volume
Pallet (1/10, 2/10, ...)
Produto (Codigo completo)
Descrição (Completo)
Peso liquido da bobina (Peso individualizado do sub-lote)
*Peso liquido do pallet (Volume)
*Peso Bruto do pallet (Volume)
Lote
Sub-lote
*Data de Validade (Campo digitado no cabeçalho)



oPrn:Say(nLin - 10,aCol[5] + 030,"VALOR DO DOCUMENTO",oFont14AN,,CLR_BRANCA)
oPrn:Say(nLin - 10,aCol[6] + 045,"VALOR CORRIGIDO"   ,oFont14AN,,CLR_BRANCA)
oPrn:Say(nLin - 10,aCol[7] + 045,"DIAS DE ATRASO"    ,oFont14AN,,CLR_BRANCA)
*/
_nQtdBTot := TRBROMCLI->ZG_PESOPAL
While !TRBROMCLI->(Eof())
	cCodProd := Alltrim(TRBROMCLI->ZH_PROD)
    nNumCar1 := u_xNCarFilm(cCodProd)  
    cFamilia := SubStr(cCodProd, 1, Len(cCodProd)-nNumCar1)
	/*aDimen   := u_xGetDimen(TRBROMCLI->B1_DESC,"N")
    cDiamI   := transform( Ceiling(aDimen[1]*25.4),"@E 9,999")
    cDiamE   := transform( Ceiling(aDimen[2]),"@E 9,999")
    cLargura := transform( Ceiling(aDimen[3]),"@E 9,999") */
	If nLin > 2700
		oPrn:EndPage()
		oPrn:StartPage()
        _nPagina++    
		//oPrn:Say(2800,1900,"Pagina: " + strzero(_nPagina,2) ,oFont16AN)
        nLin := 100
		oPrn:Say(nLin - 10,aCol[1] + 020,"Pedido"     ,oFont16AN)
		oPrn:Say(nLin - 10,aCol[2] + 020,"Pallet"     ,oFont16AN)
		oPrn:Say(nLin - 10,aCol[3] + 020,"Produto"    ,oFont16AN)
		//oPrn:Say(nLin - 10,aCol[4] + 020,"Descricao"  ,oFont16AN)
		oPrn:Say(nLin - 10,aCol[5] + 040,"P.Liq."     ,oFont16AN)
		oPrn:Say(nLin - 10,aCol[6] + 020,"Lote"       ,oFont16AN)
		oPrn:Say(nLin - 10,aCol[7] + 015,"Sub-Lote"   ,oFont16AN)
		If !Empty(TRBROMCLI->ZH_VLDLOTE)
			oPrn:Say(nLin - 10,aCol[8] + 020,"Validade"   ,oFont16AN)
		EndIf	
	EndIf
	nLin += nPulLin+20
	If _cQuebra <> TRBROMCLI->ZG_VOLUME	
		oPrn:Say(nLin - 10,aCol[1] + 15,TRBROMCLI->(ZG_PEDIDO+"-"+ZG_ITEMPV)         ,oFont16AN)
		oPrn:Say(nLin - 10,aCol[2] + 15,TRBROMCLI->ZG_PALLET                         ,oFont16AN)		
		//oPrn:Say(nLin - 10,aCol[3] + 15,cFamilia                                     ,oFont16AN)
		oPrn:Say(nLin - 10,aCol[3] + 15,cCodProd                                     ,oFont16AN)
        //oPrn:Say(nLin - 10,aCol[4] + 15,SubStr(TRBROMCLI->B1_DESC,1,25)              ,oFont16AN)
		_cQuebra := TRBROMCLI->ZG_VOLUME
	EndIf
    oPrn:Say(nLin - 10,aCol[5] + 15,TransForm(TRBROMCLI->ZH_QTDORI,"@E 999,999.99"),oFont16AN)
	_TotPPLiq   += TRBROMCLI->ZH_QTDORI
	_TotPPBrt   := TRBROMCLI->ZG_PESOPAL
	oPrn:Say(nLin - 10,aCol[6] + 15,TRBROMCLI->ZH_LOTECTL      ,oFont16AN)                
    oPrn:Say(nLin - 10,aCol[7] + 20,TRBROMCLI->ZH_NUMLOTE      ,oFont16AN)                
	If !Empty(TRBROMCLI->ZH_VLDLOTE)
		oPrn:Say(nLin - 10,aCol[8] + 15,DTOC(STOD(TRBROMCLI->ZH_VLDLOTE)),oFont16AN)
	EndIf	
    nLin += nPulLin+20
	_nTotProd++
	If ASCAN(_aTotPrd,TRBROMCLI->ZH_PROD)==0
		AADD(_aTotPrd,TRBROMCLI->ZH_PROD)
	EndIf
	_nQtdLTot += TRBROMCLI->ZH_QTDORI
	_nQtdBobs += 1
	TRBROMCLI->(DbSkip())                
	If _cQuebra <> TRBROMCLI->ZG_VOLUME	
		_nQtdBTot += TRBROMCLI->ZG_PESOPAL
		nLin += nPulLin
		oPrn:Line(nLin ,aCol[1],nLin,nHPage-1,,cBorda)	
		oPrn:Say(nLin - 10,aCol[5] - 350,"Peso Liq. Pallet:",oFont16AN)
		oPrn:Say(nLin - 10,aCol[5] + 15,TransForm(_TotPPLiq,"@E 999,999.99"),oFont16AN)
		oPrn:Say(nLin - 10,aCol[6] + 15,"Peso Bruto Pallet:  " + Alltrim(TransForm(_TotPPBrt,"@E 999,999.99")),oFont16AN)
		_TotPPLiq   := 0	
		_TotPPBrt   := 0	
	Else
		oPrn:Line(nLin ,aCol[5],nLin,nHPage-1,,cBorda)	
	EndIf

End
nLin += nPulLin+20

oPrn:Say(nLin ,aCol[1], "Observação: ",oFont16AN)
If Len(aAuxObs) >= 1 .And. !Empty(aAuxObs[1])
	oPrn:Say(nLin+(nPulLin*1)+10 ,aCol[1], aAuxObs[1],oFont16A)
EndIf
If Len(aAuxObs) >= 2 .And. !Empty(aAuxObs[2])
	oPrn:Say(nLin+(nPulLin*2)+30 ,aCol[1], aAuxObs[2],oFont16A)
EndIf
If Len(aAuxObs) >= 3 .And. !Empty(aAuxObs[3])
	oPrn:Say(nLin+(nPulLin*3)+50 ,aCol[1], aAuxObs[3],oFont16A)
EndIf
If Len(aAuxObs) >= 4 .And. !Empty(aAuxObs[4])
	oPrn:Say(nLin+(nPulLin*4)+70 ,aCol[1], aAuxObs[4],oFont16A)
EndIf

oPrn:Say(nLin ,aCol[5], " Peso Total Líquido: ",oFont16AN)
oPrn:Say(nLin ,aCol[7], TransForm(_nQtdLTot,"@E 999,999.99"),oFont16AN)
nLin += nPulLin+20
oPrn:Say(nLin ,aCol[5], " Peso Total Bruto: ",oFont16AN)
oPrn:Say(nLin ,aCol[7], TransForm(_nQtdBTot,"@E 999,999.99"),oFont16AN)
nLin += nPulLin+20
oPrn:Say(nLin ,aCol[5], " Total de Pallet(s): " ,oFont16AN)
oPrn:Say(nLin ,aCol[7]+050,  CValToChar(_nPalVol),oFont16AN)
nLin += nPulLin+20
oPrn:Say(nLin ,aCol[5], " Total de Bobina(s): " ,oFont16AN)
oPrn:Say(nLin ,aCol[7]+050,  CValToChar(_nQtdBobs),oFont16AN)

//nLin := 2800
nLin := 3000
//oPrn:Line(nLin,aCol[1],nLin,nHPage-1,,cBorda)

nLin += nPulLin

//oPrn:Say(nLin,800,AllTrim(SM0->M0_NOMECOM),oFont14A)

nLin += nPulLin

//oPrn:Say(nLin,600,AllTrim(SM0->M0_ENDCOB) + " - " + SM0->M0_ESTCOB + " CEP: " + SM0->M0_CEPCOB,oFont14A)

nLin += nPulLin

//oPrn:Say(nLin,800,"Fone: " + AllTrim(SM0->M0_TEL) + " / " + " Fax: " + AllTrim(SM0->M0_FAX),oFont14A)

nLin += nPulLin

//oPrn:Say(nLin,900,"www.replas.com.br"     ,oFont14A)


oPrn:EndPage()
oPrn:Preview() 
FreeObj(oPrn)

//oPrn:Print()


/*
FreeObj(oPrn)
oPrn := Nil
*/

restArea(aArea)
Return


Static Function GetQtdPallet()

Pergunte("REFATA30", .F.)

cQry := "SELECT COUNT(ZG_PALLET) QTDPALLET "
cQry += " FROM " + RetSqlName("SZG") + " SZG "
cQry += " Where ZG_FILIAL = '" + SZG->ZG_FILIAL + "' "
cQry += " AND   ZG_PEDIDO = '"+ SZG->ZG_PEDIDO +" ' "
If MV_PAR01 == 1
	cQry += " AND   ZG_ITEMPV = '"+SZG->ZG_ITEMPV+"' "
EndIf
cQry += " AND  D_E_L_E_T_ = ' ' "
TCQUERY cQry New Alias "TRBMP"

nRet := TRBMP->QTDPALLET
TRBMP->(DbCloseArea())

return(nRet)
