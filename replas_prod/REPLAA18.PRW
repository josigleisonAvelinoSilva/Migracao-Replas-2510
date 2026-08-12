#include "totvs.ch"
#include "topconn.ch"


//-- U_REPLAA18()
User Function REPLAA18()
    Local aAreaAnt   := GetArea()
    Local aBrowse    := {}
    Local aStruTrb   := {}
    Local cProduto   := ""
    Local nQtdVen    := 0
    Local nQtdRes    := 0
    Local nOpcA      := 0
    Local cMatPrimAv := Space(Len(SC6->C6_PRODUTO))
    Local oDlg
    Local oMark
    Local oQtdSel

    Private cAliasTRB := "TRB"
    Private cFilOrig  := GetMV("RE_FILORIG", .F., "0302")
    Private cFilDest  := GetMV("RE_FILDEST", .F., "0201")
    Private cFilArm   := GetMV("RE_FILARM", .F., "0303")
    Private nPItemPV  := aScan(aHeader, {|x| AllTrim(x[2]) == "C6_ITEM"})
    Private nPProd    := aScan(aHeader, {|x| AllTrim(x[2]) == "C6_PRODUTO"})
    Private nPQtdVen  := aScan(aHeader, {|x| AllTrim(x[2]) == "C6_QTDVEN"})

    If Type("lREPLAA18") == "U"
        lREPLAA18 := .F.
    EndIf

    //-- Indica que ja esta em execucao
    If lREPLAA18
        Return
    EndIf

    If !(INCLUI .Or. ALTERA)
        Return
    EndIf

    cProduto := AllTrim(aCols[n,nPProd])
    nQtdVen  := aCols[n,nPQtdVen]

    If !u_xIsFilme(cProduto)
        Return
    EndIf

    If Empty(nQtdVen)
        FWAlertHelp("Quantidade não informada.", "Informe quantidade no pedido antes de prosseguir com a reserva.")
        Return
    EndIf

    //--
    aAdd(aStruTrb, {"TRB_OK"    , "C", 02                     ,                      0})
    aAdd(aStruTrb, {"TRB_FILIAL", "C", TamSx3("B8_FILIAL")[1] , TamSx3("B8_FILIAL")[2]})
    aAdd(aStruTrb, {"TRB_CODMP" , "C", TamSx3("B8_PRODUTO")[1], TamSx3("B8_PRODUTO")[2]})
    aAdd(aStruTrb, {"TRB_SALDO" , "N", TamSx3("B8_SALDO")[1]  , TamSx3("B8_SALDO")[2]})
    aAdd(aStruTrb, {"TRB_LOTECT", "C", TamSx3("B8_LOTECTL")[1], TamSx3("B8_LOTECTL")[2]})
    aAdd(aStruTrb, {"TRB_NUMLOT", "C", TamSx3("B8_NUMLOTE")[1], TamSx3("B8_NUMLOTE")[2]})
    aAdd(aStruTrb, {"TRB_DTVALI", "D", TamSx3("B8_DTVALID")[1], TamSx3("B8_DTVALID")[2]})
    aAdd(aStruTrb, {"TRB_DFABRI", "D", TamSx3("B8_DFABRIC")[1], TamSx3("B8_DFABRIC")[2]})
    aAdd(aStruTrb, {"TRB_PEDIDO", "C", TamSx3("ZF_PEDIDO")[1] , TamSx3("ZF_PEDIDO")[2]})
    aAdd(aStruTrb, {"TRB_ITEMPV", "C", TamSx3("ZF_ITEMPV")[1] , TamSx3("ZF_ITEMPV")[2]})
    aAdd(aStruTrb, {"TRB_USRRES", "C", TamSx3("ZF_USRRES")[1] , TamSx3("ZF_USRRES")[2]})
    aAdd(aStruTrb, {"TRB_DTRES" , "D", TamSx3("ZF_DTRES")[1]  , TamSx3("ZF_DTRES")[2]})
    aAdd(aStruTrb, {"TRB_HRRES" , "C", TamSx3("ZF_HRRES")[1]  , TamSx3("ZF_HRRES")[2]})
    aAdd(aStruTrb, {"TRB_RECNO" , "N", 15                     ,                     0})

    //--
    aAdd(aBrowse, {"TRB_OK",, ""})
    aAdd(aBrowse, {"TRB_FILIAL",, RetTitle("B8_FILIAL")})
    aAdd(aBrowse, {"TRB_CODMP" ,, "Materia Prima"})
    aAdd(aBrowse, {"TRB_SALDO" ,, RetTitle("B8_SALDO")})
    aAdd(aBrowse, {"TRB_LOTECT",, RetTitle("B8_LOTECTL")})
    aAdd(aBrowse, {"TRB_NUMLOT",, RetTitle("B8_NUMLOTE")})
    aAdd(aBrowse, {"TRB_DTVALI",, RetTitle("B8_DTVALID")})
    aAdd(aBrowse, {"TRB_DFABRI",, RetTitle("B8_DFABRIC")})
    aAdd(aBrowse, {"TRB_PEDIDO",, RetTitle("ZF_PEDIDO")})
    aAdd(aBrowse, {"TRB_ITEMPV",, RetTitle("ZF_ITEMPV")})
    aAdd(aBrowse, {"TRB_USRRES",, RetTitle("ZF_USRRES")})
    aAdd(aBrowse, {"TRB_DTRES" ,, RetTitle("ZF_DTRES")})
    aAdd(aBrowse, {"TRB_HRRES" ,, RetTitle("ZF_HRRES")})

    If Select(cAliasTRB) > 0
        (cAliasTRB)->(dbCloseArea())
    EndIf

    oTmpTable := FWTemporaryTable():New(cAliasTRB)
    oTmpTable:SetFields(aStruTrb)
    oTmpTable:AddIndex("1", {"TRB_RECNO"})
    oTmpTable:Create()

    //--
    LoadTmpTable(1, cProduto)

    DEFINE FONT oArial12 NAME "Arial" SIZE 0, -12
    DEFINE FONT oArial12B NAME "Arial" SIZE 0, -12 BOLD
    DEFINE FONT oArial20B NAME "Arial" SIZE 0, -20 BOLD

    DEFINE MSDIALOG oDlg FROM 000,000 TO 400,1100 TITLE OemToAnsi("Reserva Filmes") PIXEL
        oFWLayer := FWLayer():new()
        oFWLayer:init(oDlg, .F.)

        oFWLayer:addLine("HEADER", 20, .F.)
        oFWLayer:addLine("BODY", 80, .F.)

        oFWLayer:addCollumn("ALL", 100, .F., "HEADER")
        oFWLayer:addCollumn("ALL", 100, .F., "BODY")

        oPnlHeader := oFWLayer:getColPanel("ALL", "HEADER")
        oPnlBody   := oFWLayer:getColPanel("ALL", "BODY")

        @ 010,(oPnlHeader:nRight*0.5)-400 GET cMatPrimAv SIZE 90,12 OF oPnlHeader PIXEL PICTURE "@!"
        @ 010,(oPnlHeader:nRight*0.5)-300 BUTTON "Buscar"          SIZE 50,12 ACTION (MsgRun("Buscando bobinas...", "", {|| LoadTmpTable(2, cMatPrimAv)}), oMark:oBrowse:refresh()) OF oPnlHeader PIXEL

        @ 010,(oPnlHeader:nRight*0.5)-180 BUTTON "Reservar"       SIZE 50,12 ACTION (nOpcA:=1,oDlg:End()) OF oPnlHeader PIXEL
        @ 010,(oPnlHeader:nRight*0.5)-120 BUTTON "Soltar Reserva" SIZE 50,12 ACTION IIF(VldSoltar(), (nOpcA:=2,oDlg:End()), oDlg) OF oPnlHeader PIXEL
        @ 010,(oPnlHeader:nRight*0.5)-060 BUTTON "Cancelar"       SIZE 50,12 ACTION (nOpcA:=3,oDlg:End()) OF oPnlHeader PIXEL

        @ 007,010 SAY OemToAnsi("Produto Acabado:") OF oPnlHeader PIXEL FONT oArial12
        @ 007,062 SAY cProduto OF oPnlHeader PIXEL FONT oArial12B

        @ 017,010 SAY OemToAnsi("Qtde. Item PV:") SIZE 80,10 OF oPnlHeader PIXEL FONT oArial12
        @ 017,062 SAY nQtdVen PICTURE PesqPictQt("C6_QTDVEN",20) SIZE 53, 7 OF oPnlHeader PIXEL FONT oArial12B

        @ 027,010 SAY OemToAnsi("Qtde. Reserva:") SIZE 80,10 OF oPnlHeader PIXEL FONT oArial12
        @ 027,062 SAY oQtdSel VAR nQtdRes Picture PesqPictQt("C6_QTDVEN",20) SIZE 53, 7 OF oPnlHeader PIXEL FONT oArial12B 

        oMark := MsSelect():New(cAliasTRB, "TRB_OK", Nil, aBrowse, .F., Nil, {0, 0, (oPnlBody:nHeight*0.5), (oPnlBody:nRight*0.5)},,, oPnlBody)
        oMark:bAval := {|| IIF(VldMark(), (lOk := nQtdRes>nQtdVen.And.!TRB->(IsMark("TRB_OK",ThisMark(),ThisInv())), TRB->TRB_OK := IIf(TRB->(IsMark("TRB_OK",ThisMark(),ThisInv())).Or.lOk,"",ThisMark()), nQtdRes := IIf(lOk,nQtdRes,IIf(TRB->(IsMark("TRB_OK",ThisMark(),ThisInv())),nQtdRes+TRB->TRB_SALDO,nQtdRes-TRB->TRB_SALDO)), oQtdSel:setText(nQtdRes)), .T.)}
        oMark:oBrowse:lHasMark    := .T.
        oMark:oBrowse:lCanAllmark := .F.
        oMark:oBrowse:setFocus()

    //ACTIVATE MSDIALOG oDlg //VALID ((nQtdRes == 0) .Or. (nQtdRes >= nQtdVen))
    ACTIVATE MSDIALOG oDlg CENTERED ON INIT lREPLAA18 := .T.

    If nOpcA == 1
        dbSelectArea(cAliasTRB)
        TRB->(dbGotop())
        While TRB->(!EoF())
            If IsMark("TRB_OK", ThisMark(), ThisInv())
                //-- Inclui
                IncSZF()
            EndIf
            dbSelectArea(cAliasTRB)
            TRB->(dbSkip())
        EndDo
    ElseIf nOpcA == 2 
        //-- Deleta
        DelSZF(TRB->TRB_PEDIDO, TRB->TRB_ITEMPV)
    EndIf

    If Select(cAliasTRB) > 0
        (cAliasTRB)->(dbCloseArea())
    EndIf

    //StartJob("U_RPLAA18A", GetEnvServer(), .F., FWCodEmp(), FWCodFil())

    RestArea(aAreaAnt)

Return


//--
Static Function VldMark()
    Local aAreaAnt := GetArea()
    Local aAreaSZF := SZF->(GetArea())
    Local cQuery   := ""

    If TRB->(TRB_PEDIDO+TRB_ITEMPV) == M->C5_NUM+aCols[n,nPItemPV]
        FWAlertHelp("Bobina já reservada para <strong>este pedido</strong> ["+TRB->TRB_PEDIDO+"-"+TRB->TRB_ITEMPV+"].", "Selecione outra bobina ou solte as reservas existentes.")
        Return .F.
    EndIf

    If !Empty(TRB->(TRB_PEDIDO+TRB_ITEMPV))
        FWAlertHelp("Bobina reservada para <strong>outro pedido</strong> ["+TRB->TRB_PEDIDO+"-"+TRB->TRB_ITEMPV+"].", "Selecione outra bobina ou solte as reservas existentes.")
        Return .F.
    EndIf

    If Select("_QRY") > 0
        _QRY->(dbCloseArea())
    EndIf

    //-- Valida se ja existe reserva para o item do pedido
    cQuery := " SELECT SUM(ZF_SALDO) ZF_SALDO "
    cQuery += " FROM " + RetSqlName("SZF")
    cQuery += " WHERE ZF_FILORIG = '" + cFilOrig + "' "
    cQuery += " AND ZF_PEDIDO = '" + M->C5_NUM + "' "
    cQuery += " AND ZF_ITEMPV = '" + aCols[n,nPItemPV] + "' "
    cQuery += " AND D_E_L_E_T_ = ' ' "

    cQuery := ChangeQuery(cQuery)

    TCQUERY cQuery New Alias "_QRY"

    If _QRY->(!EoF()) .And. _QRY->ZF_SALDO > aCols[n,nPQtdVen]
        FWAlertHelp("Ja existem <strong>"+ AllTrim(transform(_QRY->ZF_SALDO,PesqPictQt("C6_QTDVEN",20))) +" Kg</strong> reservados para <strong>este pedido</strong> ["+M->C5_NUM+"-"+aCols[n,nPItemPV]+"].", "Solte as reservas existentes.")
        RestArea(aAreaSZF)
        RestArea(aAreaAnt)
        Return .F.
    EndIf

    If Select("_QRY") > 0
        _QRY->(dbCloseArea())
    EndIf

    RestArea(aAreaSZF)
    RestArea(aAreaAnt)

Return .T.


//--
Static Function VldSoltar()
    
    If Empty(TRB->(TRB_PEDIDO+TRB_ITEMPV))
        FWAlertHelp("Não existe reserva para ser solta dessa bobina.", "Selecione outra bobina.")
        Return .F.
    EndIf
    
    If !FWAlertYesNo("Deseja soltar a reserva de todas as bobinas do pedido ["+TRB->TRB_PEDIDO+"- "+TRB->TRB_ITEMPV+"] ?", "Soltar Reserva?")
        Return .F.
    EndIf

Return .T.


//--
Static Function IncSZF()
    Local aAreaAnt := GetArea()
    Local aAreaSZF := SZF->(GetArea())

    RecLock("SZF", .T.)
        SZF->ZF_FILIAL  := TRB->TRB_FILIAL
        SZF->ZF_CODMP   := TRB->TRB_CODMP
        SZF->ZF_SALDO   := TRB->TRB_SALDO
        SZF->ZF_LOTECTL := TRB->TRB_LOTECT
        SZF->ZF_NUMLOTE := TRB->TRB_NUMLOT
        SZF->ZF_FILORIG := xFilial("SC6")
        SZF->ZF_PEDIDO  := M->C5_NUM
        SZF->ZF_ITEMPV  := aCols[n,nPItemPV]
        SZF->ZF_CODPA   := aCols[n,nPProd]
        SZF->ZF_USRRES  := cUserName
        SZF->ZF_DTRES   := dDataBase
        SZF->ZF_HRRES   := SubStr(Time(), 1, 5)
    SZF->(MsUnLock())

    RestArea(aAreaSZF)
    RestArea(aAreaAnt)

Return


//--
Static Function DelSZF(cPVDel, cItPVDel)
    Local cUpDate  := ""
    
    cUpDate := " UPDATE " + RetSqlName("SZF") + " "
    cUpDate += " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ "
    cUpDate += " WHERE ZF_FILORIG = '" + cFilOrig + "' "
    cUpDate += " AND ZF_PEDIDO = '" + cPVDel + "' "
    cUpDate += " AND ZF_ITEMPV = '" + cItPVDel + "' "
    cUpDate += " AND D_E_L_E_T_ = ' ' "

    If tcsqlexec(cUpdate)
        ConOut(tcsqlerror())
    EndIf

Return


//-- U_RPLAA18A()
User Function RPLAA18A()
    Local cQuery := ""

    wfprepenv("01", "0105")

    If Type("cFilOrig") == "U"
        cFilOrig := GetMV("RE_FILORIG", .F., "0302")
    EndIf

    If Select("_QRY") > 0
        _QRY->(dbCloseArea())
    EndIf

    cQuery := " SELECT ZF_PEDIDO, ZF_ITEMPV, ZF_CODPA, SUM(ZF_SALDO) ZF_SALDO, SC6.C6_NUM, SC6.C6_ITEM, SC6.C6_PRODUTO, SC6.C6_QTDVEN, SC6.C6_NOTA, SC6.C6_SERIE "
    cQuery += " FROM " + RetSqlName("SZF") + " SZF "
    cQuery += " LEFT JOIN " + RetSqlName("SC6") + " SC6 "
    cQuery += " ON SC6.C6_FILIAL = ZF_FILORIG "
    cQuery += " AND SC6.C6_NUM = ZF_PEDIDO "
    cQuery += " AND SC6.C6_ITEM = ZF_ITEMPV "
    cQuery += " AND SC6.D_E_L_E_T_ = ' ' "
    cQuery += " WHERE SZF.ZF_FILORIG = '" + cFilOrig + "' "
    cQuery += " AND  SZF.D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY ZF_PEDIDO, ZF_ITEMPV, ZF_CODPA, SC6.C6_NUM, SC6.C6_ITEM, SC6.C6_PRODUTO, SC6.C6_QTDVEN, SC6.C6_NOTA, SC6.C6_SERIE "
    cQuery += " ORDER BY ZF_PEDIDO, ZF_ITEMPV "

    cQuery := ChangeQuery(cQuery)

    TCQUERY cQuery New Alias "_QRY"

    While _QRY->(!EoF())
        //--
        If Empty(_QRY->C6_NUM)
            DelSZF(_QRY->ZF_PEDIDO, _QRY->ZF_ITEMPV)
        EndIf

        //--
        If !(_QRY->ZF_CODPA == _QRY->C6_PRODUTO)
            DelSZF(_QRY->ZF_PEDIDO, _QRY->ZF_ITEMPV)
        EndIf

        //--
        If !Empty(_QRY->C6_NOTA)
            DelSZF(_QRY->ZF_PEDIDO, _QRY->ZF_ITEMPV)
        EndIf

        _QRY->(dbSkip())
    EndDo

    If Select("_QRY") > 0
        _QRY->(dbCloseArea())
    EndIf

Return


//--
Static Function LoadTmpTable(nOpc, cCodProd)
    Local aSldLote := {}
    Local cQuery   := ""
    Local cFamilia := ""
    Local nLargura := 0
    Local nX       := 0

    cCodProd := AllTrim(cCodProd)

    If nOpc == 1
        cFamilia := "MP" + Left(cCodProd, Len(cCodProd)-9)
        nLargura := u_xGetDimen(cCodProd, "N")[3]
    Else
        If Left(cCodProd, 2) == "MP"
            cFamilia := cCodProd
        Else
            cFamilia := "MP" + cCodProd
        EndIf
    EndIf

    //-- Query
    cQuery := " SELECT DISTINCT * FROM vw_est_saldos_bobina_reserva "
    cQuery += " WHERE B8_FILIAL IN ('"+cFilDest+"','"+cFilArm+"') "
    cQuery += " AND B8_PRODUTO LIKE '%"+Alltrim(cFamilia)+"%' "
    If nOpc == 1
        cQuery += " AND LARGURA >= '"+strzero(nLargura,4)+"' "
    EndIf
    cQuery += " ORDER BY B8_FILIAL, B8_PRODUTO, B8_DTVALID, B8_LOTECTL, B8_NUMLOTE "

    cQuery   := ChangeQuery(cQuery)
    aSldLote := QryArray(cQuery)

    //-- Efetua um ZAP na tabela temporaria
    dbSelectArea(cAliasTRB)
    ZAP
    
    //-- Monta o arquivo de trabalho
    For nX := 1 To Len(aSldLote)
        RecLock(cAliasTRB, .T.)
            TRB->TRB_OK     := "" 
            TRB->TRB_FILIAL := aSldLote[nX][01]
            TRB->TRB_CODMP  := aSldLote[nX][02]
            TRB->TRB_SALDO  := aSldLote[nX][03]
            TRB->TRB_LOTECT := aSldLote[nX][04]
            TRB->TRB_NUMLOT := aSldLote[nX][05]
            TRB->TRB_DTVALI := STOD(aSldLote[nX][06])
            TRB->TRB_DFABRI := STOD(aSldLote[nX][07])
            TRB->TRB_PEDIDO := aSldLote[nX][08]
            TRB->TRB_ITEMPV := aSldLote[nX][09]
            TRB->TRB_USRRES := aSldLote[nX][10]
            TRB->TRB_DTRES  := STOD(aSldLote[nX][11])
            TRB->TRB_HRRES  := aSldLote[nX][12]
            TRB->TRB_RECNO  := nX
        TRB->(MsUnLock())
    Next nX
    TRB->(dbGotop())
    
Return
