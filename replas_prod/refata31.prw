#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "MSOLE.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} REFATA31
Impressão REPLAS A4 com layout proporcional final
@type function
@version 3.0
@author Fernando
@since 2025-06-28
/*/
User Function REFATA31()
Local cFilePrint := "folha_" + strtran(time(),":","")
Local cProduto   := "-"
Local cLargura   := "-"
Local cDiamI     := "-"
Local cDiamE     := "-"
Local cPesoLiq   := "-"
Local cPesoBru   := "-"
Local cPalet     := "-"
Local aAuxCli    := {} 
// Private cBitmap    := GetSrvProfString( "Startpath", "" ) + "rpsoplogo.jpg"
// Fontes ajustadas

Local oFont18B := TFont():New("Arial", ,18, , .T.)
Local oFont22B := TFont():New("Arial", ,22, , .T.)
Local oFont32B := TFont():New("Arial", ,32, , .T.)
Local oFont42B := TFont():New("Arial", ,42, , .T.)
Local oFont50B := TFont():New("Arial", ,50, , .T.)

Local nTop := 20
Local nLeft := 60
Local nWidth := 2300
Local nBase := nTop
//Local oPrint := FWMSPrinter():New(cFilePrint, IMP_SPOOL,,, .F.)
Local oPrint := FWMSPrinter():New(cFilePrint, IMP_PDF,,, .T.)
Local aDimen
Local bOk 		:= {|| .T. }
Local aPar 		:= {}
Local cUpd      := ""
Local _cDesc    := 0
//Local cFilOrig  := GetMV( "RE_FILORIG", .F., "0302" )

Private aRet 	:= {}

/*If !(FWCodFil() == cFilOrig)
    MsgInfo("Impressao nao permitida nesta filial")
    return
EndIf*/

SZH->(DbSetOrder(1))
SZH->(DbSeek(SZG->ZG_FILIAL+SZG->ZG_VOLUME))
aAdd(aPar, {1, "Código Cliente" , SZH->ZH_CODCLI , "@!"      , "", "", "", 60, .F.})
aAdd(aPar, {1, "Gramatura"      , SZH->ZH_GRAM   , "@E 999"  , "", "", "", 60, .F.})
aAdd(aPar, {1, "Dt. Fabricação" , SZH->ZH_FABLOT , "dd/mm/yy", "", "", "", 60, .T.})
aAdd(aPar, {1, "Dt. Vencimento" , SZH->ZH_VLDLOTE, "dd/mm/yy", "", "", "", 60, .T.})

If !ParamBox( aPar, 'Parametros de impressao', @aRet, bOk, , , , , , , .F., .F. )
	Return
EndIf

cUpd := " UPDATE " + RetSqlName("SZH") + " SET " 
cUpd += " ZH_CODCLI  = '" + aRet[1] + "', " 
cUpd += " ZH_GRAM    =  " + Alltrim(Str(aRet[2])) + ", " 
cUpd += " ZH_FABLOT  =  '" + DTOS(aRet[3]) + "', " 
cUpd += " ZH_VLDLOTE = '" + DTOS(aRet[4]) + "' " 
cUpd += " WHERE ZH_FILIAL = '"+SZG->ZG_FILIAL+"' "
cUpd += " AND   ZH_VOLUME = '"+SZG->ZG_VOLUME+"' "
cUpd += " AND   D_E_L_E_T_ = ' ' "

If TCSQLEXEC(cUpd)<0
    Alert(TCSQLERROR())
EndIf    
TCREFRESH(RetSqlName("SZH"))
cProduto := AllTrim(SZH->ZH_PROD)
nNumCar1 := u_xNCarFilm(cProduto)  
cFamilia := SubStr(cProduto, 1, Len(cProduto)-nNumCar1)
aDimen   := u_xGetDimen(cProduto,"N")
cDiamI   := transform( Ceiling(aDimen[1]*25.4),"@E 9999")
cDiamE   := transform( Ceiling(aDimen[2]),"@E 9999")
cLargura := transform( Ceiling(aDimen[3]),"@E 9999")
cPesoLiq := GetPesoLiq()
cPesoBru := TRANSFORM(SZG->ZG_PESOPAL,"@E 99999.9")
cPalet   := SZG->ZG_PALLET

SC5->(DbSetOrder(1))
If SC5->(DbSeek(xFilial()+SZG->ZG_PEDIDO))
    SA1->(DbSetOrder(1))
    If SA1->(DbSeek(xFilial()+SC5->C5_CLIENTE+SC5->C5_LOJACLI))
        //cCliente := AllTrim(SA1->A1_NOME)
        aAuxCli := QbTexto(AllTrim(SA1->A1_NOME), 20, " ")
    EndIf
EndIf        

SB1->(DbSetOrder(1))
If SB1->(DbSeek(xFilial()+SZH->ZH_PROD))
    _cDesc := SB1->B1_DESC
EndIf    

// Funcao para retornar quantidade de caracteres da familia
//xNCarFilm
// Funcao para retornar as dimensoes DI, DE LARG
//xGetDimen(cCod, cRetType)
//nNumCar1 := u_xNCarFilm(cProd1)
//cFam1 := SubStr(cProd1, 1, Len(cProd1)-nNumCar1)
oPrint:SetResolution(78)
oPrint:SetPortrait()
oPrint:SetPaperSize(DMPAPER_A4)
oPrint:SetMargin(20,20,20,20)
oPrint:StartPage()

// CAIXA GERAL
oPrint:Box(nTop, nLeft, nTop+3050, nLeft+nWidth)

// LOGO
//oPrint:SayBitmap(nBase, nLeft+(nWidth-1000)/2, GetSrvProfString("StartPath","") + "folharosto1.jpg", 1000, 260)
nBase += 50
oPrint:Line(nTop, nLeft+1100, nTop+400, nLeft+1100)
oPrint:SayBitmap(nBase, nLeft+20, GetSrvProfString( "Startpath", "" ) + "rpsoplogo.jpg", 1000, 260)
oPrint:Say(nBase+070, nLeft+1150 , "Pedido:", oFont42B)
oPrint:Say(nBase+070, nLeft+1650, SZG->ZG_PEDIDO + "-" + SZG->ZG_ITEMPV, oFont32B)
oPrint:Say(nBase+210, nLeft+1150 , "Pallet:", oFont42B)
oPrint:Say(nBase+210, nLeft+1650, SZG->ZG_PALLET /*+ "/" + GetMaxPallet()*/, oFont32B)
oPrint:Say(nBase+270, nLeft+1150 , "SV:  " +  SC5->C5_XFILDES + "-" + SC5->C5_XPVDEST, oFont18B)

nBase += 300

// PRODUTO
oPrint:Box(nBase    , nLeft+20  , nBase+400     , nLeft+nWidth-20)
oPrint:Line(nBase   , nLeft+1300, nBase+400     , nLeft+1300)
oPrint:Say(nBase+150, nLeft+100 , _cDesc  , oFont22B)
oPrint:Say(nBase+350, nLeft+100 , Alltrim(aRet[1]), oFont42B)
oPrint:Say(nBase+150, nLeft+1320 , cFamilia , oFont42B)
If !Empty(aRet[2])
    oPrint:Say(nBase+350, nLeft+1320 , Alltrim(Str(aRet[2])) + " GRAMAS", oFont42B)
EndIf
nBase += 420

// DIMENSOES - TITULOS
oPrint:Box(nBase, nLeft+20, nBase+260, nLeft+nWidth-20)
oPrint:Line(nBase, nLeft+800, nBase+260, nLeft+800)
oPrint:Line(nBase, nLeft+1600, nBase+260, nLeft+1600)
oPrint:Say(nBase+120, nLeft+100,  "Largura",    oFont42B)
oPrint:Say(nBase+210, nLeft+300,  "(mm) ",    oFont22B)
oPrint:Say(nBase+120, nLeft+900,  "Ø Interno", oFont42B)
oPrint:Say(nBase+210, nLeft+1100,  "(mm)", oFont22B)
oPrint:Say(nBase+120, nLeft+1600, "Ø Externo", oFont42B)
oPrint:Say(nBase+210, nLeft+1800, "(mm)", oFont22B)
nBase += 280

// DIMENSOES - VALORES
oPrint:Box(nBase, nLeft+20, nBase+260, nLeft+nWidth-20)
oPrint:Line(nBase, nLeft+800, nBase+260, nLeft+800)
oPrint:Line(nBase, nLeft+1600, nBase+260, nLeft+1600)
oPrint:Say(nBase+180, nLeft+160,  cLargura, oFont50B)
oPrint:Say(nBase+180, nLeft+920,  cDiamI,   oFont50B)
oPrint:Say(nBase+180, nLeft+1720, cDiamE,   oFont50B)
nBase += 280

// PESOS - TITULOS
oPrint:Box(nBase, nLeft+20, nBase+260, nLeft+nWidth-20)
oPrint:Line(nBase, nLeft+1150, nBase+260, nLeft+1150)
oPrint:Say(nBase+120, nLeft+300, "Peso Líquido", oFont42B)
oPrint:Say(nBase+210, nLeft+600, "(kg)", oFont22B)
oPrint:Say(nBase+120, nLeft+1250,"Peso Bruto",   oFont42B)
oPrint:Say(nBase+210, nLeft+1550,"(kg)",   oFont22B)
nBase += 280

// PESOS - VALORES
oPrint:Box(nBase, nLeft+20, nBase+260, nLeft+nWidth-20)
oPrint:Line(nBase, nLeft+1150, nBase+260, nLeft+1150)
oPrint:Say(nBase+180, nLeft+400,  cPesoLiq, oFont50B)
oPrint:Say(nBase+180, nLeft+1320, cPesoBru, oFont50B)
nBase += 280

// Bobinas
oPrint:Box(nBase, nLeft+20  , nBase+360, nLeft+nWidth-20)
//oPrint:Say(nBase+150, nLeft+100,  "CLIENTE:", oFont32B)
//oPrint:Say(nBase+150, nLeft+600, Alltrim(cCliente),   oFont50B)
oPrint:Say(nBase+150, nLeft+100, aAuxCli[1],   oFont50B)
If Len(aAuxCli) > 1
oPrint:Say(nBase+300, nLeft+100, aAuxCli[2],   oFont50B)
EndIf
nBase += 380
oPrint:Box(nBase, nLeft+20  , nBase+400 , nLeft+nWidth-20)

nBase += 050
SZH->(DbSetOrder(1))
SZH->(DbSeek(SZG->ZG_FILIAL+SZG->ZG_VOLUME))
nPulLin := 0
WHILE SZH->ZH_FILIAL==SZG->ZG_FILIAL .AND. SZH->ZH_VOLUME==SZG->ZG_VOLUME .AND. nPulLin <= 250
    oPrint:Say(nBase+nPulLin, nLeft+100,  "Lote: " + SZH->ZH_LOTECTL + " Sub-Lote: "+ SZH->ZH_NUMLOTE + " Fabricação: "+ DTOC(SZH->ZH_FABLOT)+ "  Vencimento: "+ DTOC(SZH->ZH_VLDLOTE)  ,   oFont18B)
    SZH->(DbSkip())
    nPulLin += 50
END
If SZH->ZH_FILIAL==SZG->ZG_FILIAL .AND. SZH->ZH_VOLUME==SZG->ZG_VOLUME
    oPrint:Say(nBase+nPulLin, nLeft+100,  "Existem mais bobinas" ,   oFont18B)
EndIf

oPrint:SayBitmap(2800, nLeft+2010, GetSrvProfString("StartPath","") + "manaus.jpg", 250, 250)    
oPrint:Say(3000, nLeft+20, "Obs.: "+ SC5->C5_MENNOTA,   oFont18B)


/*
oPrint:Line(nBase, nLeft+850, nBase+280, nLeft+850)
If !Empty(SZH->ZH_LOTECTL)
    oPrint:Say(nBase+70, nLeft+100,  "Lote:",   oFont22B)
    oPrint:Say(nBase+70, nLeft+500,  SZH->ZH_LOTECTL,   oFont22B)
EndIf
If !Empty(SZH->ZH_FABLOT)
    oPrint:Say(nBase+150, nLeft+100,  "Fabricação:",   oFont22B)
    oPrint:Say(nBase+150, nLeft+500,  DTOC(SZH->ZH_FABLOT),   oFont22B)
EndIf
If !Empty(SZH->ZH_VLDLOTE)
    oPrint:Say(nBase+230, nLeft+100,  "Vencimento:",   oFont22B)
    oPrint:Say(nBase+230, nLeft+500,  DTOC(SZH->ZH_VLDLOTE),   oFont22B)
EndIf*/

oPrint:EndPage()
oPrint:Print()
FreeObj(oPrint)
Return


Static Function GetPesoLiq()
cQry := "SELECT SUM(ZH_QTDORI) PESOPAL "
cQry += " FROM " + RetSqlName("SZH") + " SZH "
cQry += " Where ZH_FILIAL = '" + SZH->ZH_FILIAL + "' "
cQry += " AND   ZH_VOLUME = '"+ SZH->ZH_VOLUME +" ' "
cQry += " AND  D_E_L_E_T_ = ' ' "
TCQUERY cQry New Alias "TRBPL"

cRet := transform(TRBPL->PESOPAL,"@E 99999.9")
TRBPL->(DbCloseArea())

return(cRet)


Static Function GetMaxPallet()
cQry := "SELECT MAX(ZG_PALLET) MAXPALLET "
cQry += " FROM " + RetSqlName("SZG") + " SZG "
cQry += " Where ZG_FILIAL = '" + SZG->ZG_FILIAL + "' "
cQry += " AND   ZG_PEDIDO = '"+ SZG->ZG_PEDIDO +" ' "
cQry += " AND  D_E_L_E_T_ = ' ' "
TCQUERY cQry New Alias "TRBMP"

cRet := TRBMP->MAXPALLET
TRBMP->(DbCloseArea())

return(cRet)
