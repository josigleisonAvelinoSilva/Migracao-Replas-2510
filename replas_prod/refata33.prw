#INCLUDE "TOPCONN.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "APVT100.CH"


/*/{Protheus.doc} refata33
Inicia Paletização
@type function
@version 1.0 
@author Marcos P.Aversa
@since 08/12/2022
/*/
User Function refata33()
local aTela     := VtSave()
local cFilOrig  := GetMV("RE_FILORIG", .F., "0302")
local lContinua := .T. 

Private cPedido := Space(TamSX3("C5_NUM")[1]) 
Private cItemPv := Space(TamSX3("C6_ITEM")[1]) 
Private cVolume := ""

If FWCodFil() # cFilOrig
    VtBeep(2)
    VtAlert("Paletizacao permitida somente na filial " + cFilOrig, "Aviso", .T., 4000)
    Return
EndIf

While .T.
    lContinua := .T.
    //cPedido := Space(TamSX3("C5_NUM")[1]) 
    VtClear()
    DLVTCabec("Informe PV Origem", .F., .F., .T.)
    @ 2,0 VtSay "Pedido:"
    @ 2,9 VtGet cPedido Picture "@!" Valid VldSC5(cPedido)
    @ 4,0 VtSay "Item:"
    @ 4,9 VtGet cItemPv Picture "@!" Valid VldSC6(cPedido, cItemPv)
    VtRead
    If VtLastKey() == 27
        Return .f.
    EndIf

    //****** Outras validacoes **********    
    /*If SZG->(DbSeek(xFilial()+cPedido+cItemPv+"A"))
        If !SZG->ZG_STATUS $ "A/I" 
            VTAlert("Somente e possivel adicionar lote em pallet aberto", "Aviso",.T.,4000)        
            lContinua := .F.
        EndIf    
    EndIf*/
    /*SZG->(DbSetOrder(3))
    If SZG->(DbSeek(xFilial()+cPedido))    
        If SZG->ZG_STATUS == "F"
            VTAlert("Pallet ja foi fechado", "Aviso",.T.,4000)        
            lContinua := .F.
        EndIf    
    EndIf*/
    //************************************************
    If lContinua
        cVolume := cPedido+cItemPv+GetPallet()
        refata33a(cPedido) // Contabiliza Volumes
        If VtLastKey() == 27
            refata33b(cPedido) // Fecha o Pallet
        EndIf    
    EndIf    
End
VtRestore(,,,,aTela)
Return

Static Function refata33a(cPedido)
local cLote   := Space(TamSX3("ZH_LOTECTL")[1]) 
local cSLote  := Space(TamSX3("ZH_NUMLOTE")[1])
local dFabric := CTOD("//") 
local dValid  := CTOD("//")  
local cProduto:= Space(TamSX3("B1_COD")[1])  
local cCodBar := ""
local lCodBar := !alltrim(lower(cUserName)) == 'fernando.muta'
local cMPReplas := ""

SZH->( dbSetOrder(1))
VtClear()
While .T.
    SZG->(DbSetorder(1))
    If SZG->(DbSeek(xFilial()+cVolume))
        If !SZG->ZG_STATUS $ "A/I" 
            VTAlert("Somente e possivel adicionar lote em pallet aberto", "Aviso",.T.,4000)        
            exit
        EndIf    
    Endif    
    cMsgZH :=""
    cStZH  := "1"
    cLote  := Space(TamSX3("ZH_LOTECTL")[1]) 
    cSLote := Space(TamSX3("ZH_NUMLOTE")[1])
    nQtde  := 0 
    VtClear()
    DLVTCabec("Paletizacao", .F., .F., .T.)
    @ 2,0 VtSay "Pedido:" + cPedido + "-" + cItemPv
    @ 4,0 VtSay Substr(SC5->C5_XDESCLI,1,18)
    cProduto := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(80) )    
    If lCodBar
        @ 5,0 VtSay "Produto "
        @ 6,0 VtGet cProduto Picture "@!"
    Else
        @ 5,0 VtSay "Prod:"
        @ 5,8 VtGet cProduto Picture "@!"
        @ 6,0 VtSay "Lote"
        @ 6,8 VtGet cLote Picture "@!"
        @ 7,0 VtSay "Sub.Lt"
        @ 7,8 VtGet cSLote Picture "@!"
        @ 8,0 VtSay "Qtde"
        @ 8,8 VtGet nQtde Picture "@E 999.99"
    EndIf
    VtRead
    cCodBar := cProduto
    If lCodBar
        If VtLastKey() == 27
            Return 
        EndIf

        If Empty(cProduto)
            Loop
        EndIf
        
        If ! CBLoad128(@cProduto)
            cProduto  := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(80) )
            VTKeyboard(chr(20))
            Loop
        EndIf
        
        cTipId:=CBRetTipo(cProduto)
        If ! cTipId $ "EAN8OU13-EAN14-EAN128"
            VTALERT("Etiqueta invalida.","Aviso",.T.,4000,3)
            cProduto  := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(80) )
            VTKeyboard(chr(20))
            Loop
        EndIf
        
        If ExistBlock("CBRETEAN")
            //-- Retorno devera ser um array conforme abaixo:
            //-- {codigo do produto, quantidade, lote, data de validade, numero de serie, sub-lote}
            aEtiqueta := ExecBlock("CBRETEAN",,,{cProduto})
        EndIf	
        
        If Empty(aEtiqueta) .or. Empty(aEtiqueta[2])
            VTALERT("Etiqueta invalida.","Aviso",.T.,4000,3)
            cProduto := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(80) )
            VTKeyboard(chr(20))
            Loop
        EndIf

        cProduto := IIf(!Empty(aEtiqueta[1]), aEtiqueta[1], cProduto)
        nQtde    := IIf(!Empty(aEtiqueta[2]), aEtiqueta[2], nQtde)
        cLote    := IIf(!Empty(aEtiqueta[3]), aEtiqueta[3], cLote)
        cSLote   := IIf(!Empty(aEtiqueta[6]), aEtiqueta[6], cSLote)
        dFabric  := CTOD("//")
        dValid   := CTOD("//")

        If !FilmRastro(cProduto, @cLote, @cSLote, @dFabric, @dValid, .T.)
            VTKeyboard(chr(20))
            Loop
        EndIf

        //-- Tratamento para etiquetas da Replas e MM da Amazonia
        cMPReplas := U_REESTA7C(PadR(U_CbGetReadN()[09], Len(SB1->B1_COD)), "21338912000148")

        If !Empty(cMPReplas) .And. Rastro(cMPReplas, "S")
            dbSelectArea("SB8")
            SB8->(dbSetOrder(2)) //-- B8_FILIAL+B8_NUMLOTE+B8_LOTECTL+B8_PRODUTO+B8_LOCAL+DTOS(B8_DTVALID)
            If !SB8->(dbSeek(xFilial("SB8") + cSLote + cLote + cMPReplas))
                If !VTYesNo("Bobina [" + Alltrim(cLote) + "-" + Alltrim(cSLote) + "] nao existe, deseja continuar?", "Aviso" , .T.) 
                    cProduto := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(80) )
                    VTKeyboard(chr(20))
                    Loop
                EndIf
            EndIf
        EndIf
    EndIf

    /*        
    cSubLote := Space(TamSX3("ZH_NUMLOTE")[1]) 
    @ 0,0 VtSay "Lote     : " + cLote    
    @ 1,0 VtSay "Sub-Lote : "
    @ 2,1 VtGet cSubLote  Picture "@!"    
    VtRead
    */

    If VtLastKey() == 27
        Exit
    EndIf

    Begin Transaction
    SZH->(DbSetOrder(2))
    If SZH->( dbSeek( xFilial("SZH") + PadR(cProduto, Len(SZH->ZH_PROD)) + PadR(cLote, Len(SZH->ZH_LOTECTL)) + PadR(cSLote, Len(SZH->ZH_NUMLOTE)) ))
        If cVolume == SZH->ZH_VOLUME
            cStZH := "3"
            cMsgZH:= "Etiqueta ja lida"
        Else
            cStZH := "2"
            cMsgZH:= "Bobina em outro palete " + Alltrim(Transform(SZH->ZH_VOLUME, "@R 999999-99-9999"))
        EndIf
    Endif
    
        SC6->(DbSetOrder(1))
        If !SC6->(DbSeek(xFilial()+cPedido+cItemPv+cProduto))
            //cStZH := "4" // Nao pertence ao volume
            cStZH := "4" // Nao pertence ao volume
            cMsgZH+= IIF(Empty(cMsgZH),""," - ")
            cMsgZH+= "Produto "+Alltrim(cProduto)+" nao pertence ao pedido" 
        EndIf

        SZG->(DbSetorder(1))
        If cStZH == "1"
            If !SZG->(DbSeek(xFilial()+cVolume))
                RecLock("SZG",.T.)
                SZG->ZG_FILIAL := SZG->(xFilial())
                SZG->ZG_VOLUME := cVolume
                SZG->ZG_PEDIDO := cPedido
                SZG->ZG_ITEMPV := cItemPv
                SZG->ZG_STATUS := "A"
                SZG->ZG_DATAPAL:= Date()
                SZG->ZG_HORAPAL:= Time()
                SZG->ZG_USER   := cUserName
                SZG->ZG_PALLET := SubStr(cVolume,9,4)
                SZG->(MsUnlock())
                /*
                SZG->ZG_PBRUTO 
                SZG->ZG_PLIQUI 
                SZG->ZG_CODIPAL */
            EndIf

            If !cStZH == "1"
                //RecLock("SZG",.F.)
                //SZG->ZG_STATUS := "I"
                //SZG->(MsUnlock())
            Else
                SZH->( RecLock("SZH" ,.T. ) )
                SZH->ZH_FILIAL  := xFilial("SZH")
                SZH->ZH_VOLUME  := cVolume
                SZH->ZH_PROD    := cProduto
                SZH->ZH_LOTECTL := cLote
                SZH->ZH_NUMLOTE := cSLote
                SZH->ZH_QTDORI  := nQtde
                SZH->ZH_DATA    := Date()
                SZH->ZH_HORA    := Time()
                SZH->ZH_PEDIDO  := cPedido
                SZH->ZH_ITEMPV  := cItemPv
                SZH->ZH_STATUS  := cStZH
                SZH->ZH_OBSERV  := cMsgZH
                SZH->ZH_CODBAR  := cCodBar
                SZH->ZH_USER    := cUserName
                SZH->ZH_FABLOT  := dFabric
                SZH->ZH_VLDLOTE := dValid
                SZH->( MsUnLock())
            EndIf
        EndIf    
    End Transaction

    If !Empty(cMsgZH)
        VtBeep(2)
        VTAlert(cMsgZH, "Aviso", .T., 4000)
    EndIf
Enddo

Return .T.

Static Function refata33b(cPedido)
local nPesoPallet := 0
SZG->(DbSetOrder(1))
lAchouSZG := SZG->(DbSeek(xFilial()+cVolume)) 
If lAchouSZG .AND. !Empty(cPedido) 
    If SZG->ZG_STATUS $ "A/I"
        If VTYesNo("Confirma fechamento do volume? ","Aviso" ,.T.) 
            While .T.
                VtClear()
                nPesoPallet := 0
                DLVTCabec("Peso do Pallet", .F., .F., .T.)
                @ 1,0 VtSay "Pedido:" + cPedido
                @ 3,0 VtGet nPesoPallet Picture "@E 9.999.99"            
                VtRead
                If VtLastKey() == 27
                    Return .f.
                EndIf
                nPesoLiq := GetPesoLiq() 
                If nPesoPallet < GetPesoLiq()
                    VTAlert("Peso bruto nao pode ser menor que peso liquido: " + transform(nPesoLiq,"@E 9,999.99"), "Aviso",.T.,4000)        
                Else
                    If VTYesNo("Confirma peso do pallet "+transform(nPesoPallet,"@E 9,999.99"),"Aviso" ,.T.) 
                        Exit
                    EndIf
                EndIf
            End
            If nPesoPallet > 0
                RecLock("SZG",.F.)
                SZG->ZG_STATUS = 'F'
                SZG->ZG_DATAPAL:= Date()
                SZG->ZG_HORAPAL:= Time()
                SZG->ZG_PESOPAL:=nPesoPallet
                SZG->(MsUnlock())
            EndIf    
        EndIf
    Else 
        If VTYesNo("Pallet inconsistente, deseja refazer?","Aviso" ,.T.) 
            Begin Transaction
            SZH->(DbSetOrder(1))
            If SZH->(DbSeek(xFilial()+SZG->ZG_VOLUME))
                While SZG->ZG_FILIAL==SZH->ZH_FILIAL .AND. SZG->ZG_VOLUME=SZH->ZH_VOLUME
                    RecLock("SZH",.F.)
                    SZH->(DbDelete())
                    SZH->(MsUnlock())
                    SZH->(DbSkip())
                End
            EndIf
            RecLock("SZG",.F.)
            SZG->ZG_STATUS = 'C' // Cancelado
            SZG->ZG_DATAPAL:= Date()
            SZG->ZG_HORAPAL:= Time()
            SZG->(DbDelete())
            SZG->(MsUnlock())
            SZH->(DbSetOrder(1))
            End Transaction
        EndIf
    EndIf
EndIf

Return

Static Function GetPallet()
cQry := "SELECT MAX(ZG_PALLET) PALLET "
cQry += " FROM " + RetSqlName("SZG") + " SZG "
cQry += " Where ZG_FILIAL = '" + xFilial("SZG") + "' "
cQry += " AND   ZG_PEDIDO = '" + cPedido +"' "
cQry += " AND   ZG_ITEMPV   = '" + cItemPv +"' "
cQry += " AND   ZG_STATUS = 'A' "
cQry += " AND  D_E_L_E_T_ = ' ' "
If Select("TRBPL") > 0
    TRBPL->(DbCloseArea())
EndIf    
TCQUERY cQry New Alias "TRBPL"
If !Empty(TRBPL->PALLET)
    cRet := TRBPL->PALLET
Else
    cQry := "SELECT MAX(ZG_PALLET) PALLET "
    cQry += " FROM " + RetSqlName("SZG") + " SZG "
    cQry += " Where ZG_FILIAL = '" + xFilial("SZG") + "' "
    cQry += " AND   ZG_PEDIDO = '" + cPedido +"' "
    cQry += " AND   ZG_ITEMPV   = '" + cItemPv +"' "
    cQry += " AND  D_E_L_E_T_ = ' ' "
    If Select("TRBPL") > 0
        TRBPL->(DbCloseArea())
    EndIf    
    TCQUERY cQry New Alias "TRBPL"
    cRet := STRZERO(VAL(TRBPL->PALLET)+1,4)
EndIf
TRBPL->(DbCloseArea())

return(cRet)

Static Function GetPesoLiq()
local nRet := 0
cQry := "SELECT SUM(ZH_QTDORI) PESOPAL "
cQry += " FROM " + RetSqlName("SZH") + " SZH "
cQry += " Where ZH_FILIAL = '" + SZH->ZH_FILIAL + "' "
cQry += " AND   ZH_VOLUME = '"+ SZH->ZH_VOLUME +" ' "
cQry += " AND  D_E_L_E_T_ = ' ' "
TCQUERY cQry New Alias "TRBPL"

nRet := TRBPL->PESOPAL
TRBPL->(DbCloseArea())

return(nRet)


//--
Static Function VldSC5(cPedido)
    Local aAreaAnt := GetArea()

    SC5->(DbSetOrder(1))
    If !SC5->(DbSeek(xFilial()+cPedido))
        VTBeep(2)
        VTAlert("Pedido invalido", "Aviso", .T., 4000)
		VTKeyboard(chr(20)) 
        Return .F.
    EndIf    

    RestArea(aAreaAnt)

Return .T.


//--
Static Function VldSC6(cPedido, cItemPv)
    Local aAreaAnt := GetArea()

    SC6->(DbSetOrder(1))
    If !SC6->(DbSeek(xFilial()+cPedido+cItemPv)) 
        VTBeep(2)
        VTAlert("Item do Pedido invalido", "Aviso", .T., 4000)
		VTKeyboard(chr(20)) 
        Return .F.
    EndIf    

    RestArea(aAreaAnt)

Return .T.


//--
Static Function FilmRastro(cProduto,cLote,cSubLote,dFabric,dValid,lEmpty)
    Local aSave := VTSave()

    Default lEmpty := .F.

    If VTModelo()=="RF"
        VTClear
        @ 0,0 VTSay "Produto com rastro"
        @ 2,0 VtSay "Lote"
        @ 3,0 VtGet cLote /*pict '@!'*/  valid If(lEmpty,.t.,!Empty(cLote)) when Empty(cLote)
        If cSubLote <> Nil
            @ 5,0 VtSay "Sub-Lote"
            @ 6,0 VtGet cSubLote pict '@!' valid If(lEmpty,.t.,!Empty(cSubLote)) .And. VldSubLote(@cSubLote)
        EndIf
        VTREAD
		If dValid <> Nil .And. dFabric <> Nil
            VTClear()
			@ 0,0 VtSay "Fabricacao"
			@ 1,0 VtGet dFabric pict '@D' valid If(lEmpty,.t.,!Empty(dFabric))
			@ 3,0 VtSay "Validade"
			@ 4,0 VtGet dValid pict '@D' valid If(lEmpty,.t.,!Empty(dValid))
			VTREAD
		EndIf
    EndIf

    VtRestore(,,,,aSave)

    If VTLastKey() == 27
        VTAlert("Lote invalido","Aviso",.t.,3000)
        Return .F.
    EndIf

Return .T.


//--
Static Function VldSubLote(cSubLote)

    If !(ValType(cSubLote) == "C") .Or. !IsNumeric(cSubLote)
        VTBeep(2)
        VTAlert("Sub-Lote invalido.", "ATENCAO", .T., 4000, 3)
        VTKeyboard(chr(20))
        Return .F.
    EndIf

Return .T.
