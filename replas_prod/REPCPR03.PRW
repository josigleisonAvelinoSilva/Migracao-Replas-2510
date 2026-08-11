#INCLUDE "PROTHEUS.CH"


/*/{Protheus.doc} REPCPR03
Imprime etiqueta de Produto Acabado
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 21/05/2022
@obs Projeto Novo PCP (Etiquetas)
/*/
User Function REPCPR03()
    Local aParam   := {}
    Local aPergAux := {}
    Local cRotina  := "REPCPR03 "
    Local cPerg    := If( IsTelNet(), "VTPERGUNTE", "PERGUNTE" )

    If !IsTelNet()
        SetKey( VK_F4, {|| ShowF4() } )
    EndIf
  
    While .T.
        aPergAux := {}
        Pergunte( cRotina, .F., /*cTitle*/, /*lOnlyView*/, /*oDlg*/, /*lUseProf*/, @aPergAux )

        MV_PAR01 := Space( TamSX3("B8_PRODUTO")[1] )
        MV_PAR02 := 0
        MV_PAR03 := 0
        MV_PAR04 := dDataBase //CtoD( "//" )
        MV_PAR05 := Space(6)
        MV_PAR06 := Space(15)
        MV_PAR07 := Space(6)
        MV_PAR08 := 1
        __SaveParam( cRotina, aPergAux )

        If !&(cPerg)(cRotina, .T.)
            Return
        EndIf  

        If TudoOK()
            aParam := { MV_PAR01,; //-- 01 - Produto
                        MV_PAR02,; //-- 02 - Peso Liquido
                        MV_PAR03,; //-- 03 - Peso Bruto
                        MV_PAR04,; //-- 04 - Data de fabricacao
                        MV_PAR05,; //-- 05 - Pedido de Venda destino
                        MV_PAR06,; //-- 06 - Lote
                        MV_PAR07,; //-- 07 - SubLote
                        MV_PAR08,; //-- 08 - Qtde. Etiqueta
                        MV_PAR09 } //-- 09 - Local de impressao

            //-- Inicia a Impressao das etiquetas
            U_REPCPR3A(aParam)
        EndIf
    EndDo

    If !IsTelNet()
        SetKey( VK_F4, {|| } )
    EndIf

Return


/*/{Protheus.doc} ShowF4
Carrega a telinha de selecao de lote/sub-lote informativo para a etiqueta do PA
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 26/05/2022
/*/
Static Function ShowF4()
    Local aMPs     := {}
    Local aList    := {}
    Local aListAux := {}
    Local cVar     := AllTrim( ReadVar() )
    Local cProdPA  := AllTrim( MV_PAR01 )
    Local cPedDest := AllTrim( MV_PAR05 )
    Local cQuery   := ""
    Local cEoL     := chr(13) + chr(10)
    Local nI       := 0
    Local lOk      := .F.
    Local oOK      := LoadBitmap(GetResources(),'LBOK')
	Local oNO      := LoadBitmap(GetResources(),'LBNO')
    Local oDlg
    Local oBar
    Local oList

    cVar := Upper(cVar)
    If !Empty(cProdPA) .And. !Empty(cPedDest) .And. (cVar == "MV_PAR06" .Or. cVar == "MV_PAR07")
        //-- Query que pega os lotes/sub-lotes de MP
        cQuery := " SELECT " + cEoL
        cQuery += "     * " + cEoL
        cQuery += " FROM " + cEoL
        cQuery += "     " + RetSQLName("SD4") + " SD4 " + cEoL
        cQuery += " WHERE " + cEoL
        cQuery += "     SD4.D4_FILIAL = '" + xFilial("SD4") + "' " + cEoL
        cQuery += "     AND SD4.D4_PRODUTO LIKE '%" + cProdPA + "' " + cEoL
        cQuery += "     AND SD4.D4_OP LIKE '" + cPedDest + "%' " + cEoL
        cQuery += "     AND SD4.D4_COD LIKE 'MP%' " + cEoL
        cQuery += "     AND SD4.D_E_L_E_T_ = ' ' " + cEoL

        DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "_TMP", .F., .T. )

        While _TMP->( !Eof() )
            aAdd( aMPs, { _TMP->D4_COD    ,; //-- 01 - Codigo do produto
                        _TMP->D4_LOTECTL  ,; //-- 02 - Lote
                        _TMP->D4_NUMLOTE } ) //-- 03 - Sub-lote

            _TMP->( DbSkip() )
        EndDo

        _TMP->( DbCloseArea() )

        If !Empty(aMPs)
            //-- Inicio do tratamento para a tela de selecao da MP para etiqueta do PA
            For nI := 1 To Len(aMPs) 
                aListAux := { .F., aMPs[nI, 02], aMPs[nI, 03], aMPs[nI, 01] } 
                aAdd(aList, aListAux) 
            Next nI

            //-- Telinha para selecao dos lotes de vinculo para visualizacao na etiqueta do PA
            DEFINE MSDIALOG oDlg TITLE "LOTE / SUB-LOTE INFORMATIVO" FROM 001, 002 TO 300, 550 PIXEL 
                oBar := tPanel():New(01, 01, "", oDlg, ,.T., , , ,100,25)
                oBar:Align := CONTROL_ALIGN_BOTTOM
                
                oList := TCBrowse():New( 000,000,277,125,,{"", "Lote", "Sub-lote", "Materia Prima"},{015, 070, 060, 100},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, ) 
                oList:SetArray(aList) 
                oList:bLine := { || { If( aList[oList:nAt,01], oOK, oNO ), aList[oList:nAt,02], aList[oList:nAt,03], aList[oList:nAt,04] } } 
                oList:bLDblClick := { || aList[oList:nAt][1] := !aList[oList:nAt][1],oList:DrawSelect() }

                TButton():New( 004,225,"&Ok",oBar,{|| lOk := VldSelect(aList), If(lOk,oDlg:End(),oDlg) },40,18,,,.F.,.T.,.F.,,.F.,,,.F. )
            ACTIVATE MSDIALOG oDlg CENTERED

            If lOk
                For nI := 1 To Len(aList)
                    If aList[nI, 01]
                        MV_PAR06 := aList[nI, 02]
                        MV_PAR07 := aList[nI, 03]
                    EndIf
                Next nI
            EndIf
        EndIf
    EndIf

Return 


/*/{Protheus.doc} VldSelect
Valida a selecao na telinha
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 26/05/2022
@param aLista, array, Array com os lotes
@return logical, Retorno logico
/*/
Static Function VldSelect(aLista)
    Local nI     := 0
    Local cCount := 0
    Local lRet   := .T.

    For nI := 1 To Len(aLista)
        If aLista[nI, 01]
            cCount++
        EndIf
    Next nI

    If cCount > 1
        MsgAlert("É permitido selecionar apenas um lote/sub-lote!", "Seleção")
        lRet := .F.
    ElseIf Empty(cCount)
        MsgAlert("Selecione um lote/sub-lote!", "Seleção")
        lRet := .F.
    EndIf

Return lRet


/*/{Protheus.doc} TudoOK
Validacao geral do pergunte
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 21/05/2022
@return logical, indica se existe algum parametro informado incorreto
/*/
Static Function TudoOK()
    Local lRet := .T.

    If Empty(MV_PAR01)
        CBAlert( "Informe o codigo de um produto!", "Parametro Vazio", .T., 3000 ) 
        lRet := .F.
    EndIf

    If lRet .And. Empty(MV_PAR02)
        CBAlert( "Informe o peso liquido!", "Parametro Vazio", .T., 3000 ) 
        lRet := .F.
    EndIf

    If lRet .And. Empty(MV_PAR03)
        CBAlert( "Informe o peso bruto!", "Parametro Vazio", .T., 3000 ) 
        lRet := .F.
    EndIf    

    If lRet .And. Empty(MV_PAR04)
        CBAlert( "Informe a data de fabricacao.", "Parametro Vazio", .T., 3000 ) 
        lRet := .F.
    EndIf

    If Empty(MV_PAR08)
        MV_PAR08 := 1
    EndIf

Return lRet


/*/{Protheus.doc} REPCPR3A
Imprime etiqueta conforme parametros
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 21/05/2022
@param aParam, array, Parametros que serao impressos na etiqueta
/*/
User Function REPCPR3A(aParam)
    Local aDimenPA    := {}
    Local aCodeBar    := {}
    Local aEndereco   := {}
    Local aDadosPVOri := {}
    Local cCodPrd     := ""
    Local cLotePrd    := ""
    Local cSLotPrd    := ""
    Local cDscPrd     := ""
    Local cPrinter    := aParam[09]
    Local cDiamIntPA  := ""
    Local cDiamExtPA  := ""
    Local cLarguraPA  := ""  
    Local nX          := 0

	If IsTelNet()
		VtMsg( "Imprimindo..." )
	EndIf

    If !CB5SetImp(cPrinter)
        CBAlert( "Local de impressao nao localizado!", "Impressora!", .T., 3000 ) 
        Return
    EndIf

    //-- Pega as dimensoes do produto
    aDimenPA   := GetDimen( aParam[01] )
    cDiamIntPA := aDimenPA[01]
    cDiamExtPA := aDimenPA[02]
    cLarguraPA := aDimenPA[03]

    cCodPrd     := Trim( aParam[01] )
    cDscPrd     := GetAdvFVal( "SB1", "B1_DESC", xFilial("SB1") + cCodPrd, 1, " " )
    cLotePrd    := Trim(aParam[06])
    cSLotPrd    := Trim(aParam[07])

    //cDtProd     := Substr( DToS(aParam[04]), 3 )
    cPesoLiq    := StrZero( (aParam[02] * 10), 6 )
    //cPesoBrt    := StrZero( (aParam[03] * 10), 6 )
    aDadosPVOri := GetAdvFVal( "SC5", {"C5_XPVORIG","C5_XCLIORI","C5_MENNOTA"}, xFilial("SC5") + aParam[05], 1, " " )

    //-- Pega o endereco da Replas
    aEndereco := GetEnd()

    //-- Dados CodeBar 2D - Datamatrix
    aAdd( aCodeBar, { "(92)"  , cCodPrd  } ) //-- Informacao interna da companhia (codigo do produto)
    //aAdd( aCodeBar, { "(11)"  , cDtProd  } ) //-- Data de producao, 6 digitos numericos no formato AAMMDD
    aAdd( aCodeBar, { "(3101)", cPesoLiq } ) //-- Peso liquido (em kg), 6 digitos
    //aAdd( aCodeBar, { "(3301)", cPesoBrt } ) //-- Peso bruto (em kg), 6 digitos
    aAdd( aCodeBar, { "(10)" , cLotePrd } ) //-- Lote Projeto: 0000000001
    aAdd( aCodeBar, { "(240)", cSLotPrd } ) //-- SubLote
    cCodBar2D := RetAiMan(aCodeBar)

    For nX := 1 To aParam[08]
        MsCbBegin( 1, 3 )       
        MsCbWrite( " ^XA " )
        MsCbWrite( " ^MMT " )
        MsCbWrite( " ^PW759 " )
        MsCbWrite( " ^LL1039 " )
        MsCbWrite( " ^LS0 " )
        MsCbWrite( " ^FO651,24^GFA,1277,3084,12,:Z64:eJytVj1rG0EQnb2PxgfKCbyNK5dCCa6F1Vwg6k9w938OXDpYfZqoFDIYQRohNSZFWv+FSyf0C1SkyMzs7uyePgIBjxAenufm3s68mRXAv61wzgCgdX4FqnT+CGDlcRA8NK21+NnjQyN4XUv+3tOTx1MfH+HH2eeyyp3f7v4MrKumdVU5/8d6c38Gh/ZwGIH8Yyp5oljyp1pPJonxZ7Pvb29fTXTNxn78uN0+P38z+ATRiX1B1Hv69dOlxzxKSN/eymuRv/D5vfvz6QL/0Rkc4HAQV5W+PnEUi68naeH8D7NZI7iufXz2IH6e+v6OLvd37vHz/X1/i5Zs7Jv6m0LEW7IN+2mAY/ye41UOSqmpUlIhZH+Df7jhyP46wK8u4DfOD/HWx1N1XP44iE+D+B7iPRuvA3yM02IFqmqPR7uWZ4x0k049ns1H3AOSZV1U3AOyOwpecHpVQ+0aFq8xebxybHSRGjxq4aodNlwf1EjqBi/mklr2XGrfg7uFPao9QdeKY8Ce6Th6vJF4FYx7tHyZs5PzGpAHxvNobbwKzwsi/2ELQ87f71PZpLurEWTG+6LKCkT/8wFEjcmvymvB4+YGv+gkZZUWGpTFowZ7+8r5VYqVUBIfN4qIJlg0zOLjUSf2ABhdunnB3CtSBCXAd5ZB/CCi/NDvI155PnBv+OT0iPb84apHuCpzzO335xrijfPxuL4+qCAw+bHrSvCsMTQxf0AfrYHG0M+DYX9/02Z5cuPN8G639OI0wHnY98sd4djfvp7qqXv+no5szaufR2Vo3XAa6bCZwwuQvlPtWQ8qp/oHejBfrENJWNAvMAXKaS6kRLRrWQ9QGDyMbw3/EPfx5p1hvNFnFxc+aZmE/Hn72Pp0zru22yQpik59hrwdjOnSD2S2+sh0EhqWYB5hv2c6NL+dLRAZ9sqn7lqen8ePFkTDxvnT8D51+xz1ebTP0RYmf87WzZ5AcvatSh0BUeDXwRmWLw3HY+Jw/8Sb7dydK6wb7s6dpKGVa21k64+NoqELdcjzC6e3RWzxUIesh1eLQ1cPrB8Fp3pj/FSfjCdn4tvz+c3+KU75ME+zHrTFVcC/o8Odm8e8Wx+ZX9rz7jZC6y2GC4srtwfA6sHVJ8BZD42pA62IPvyHhcFODgnz9Hz2cLUTPiC/l/A+HfP1mPB96vk0sJD5xe2fnux/qrMK939r9kMOnfsCFSH9LcL7hT4uvy5c/eN51mSEJ6S3GmSA93t7P3I9Qeo/XgP/nKSm6+rSrW3sLys3DUo=:F994 " )
        MsCbWrite( " ^FO629,24^GB0,991,4^FS " )
        MsCbWrite( " ^FO533,24^GB0,719,4^FS " )
        MsCbWrite( " ^FO453,24^GB0,991,4^FS " )
        MsCbWrite( " ^FO183,741^GB448,0,4^FS " )
        MsCbWrite( " ^FO182,24^GB0,991,4^FS " )
        MsCbWrite( " ^FT598,24^A0R,25,25^FH\^CI28^FDPRODUTO:^FS^CI27 " )
        If Empty(aParam[07])
            MsCbWrite( " ^FT598,751^A0R,25,25^FH\^CI28^FDLOTE:^FS^CI27 " )
        Else
            MsCbWrite( " ^FT598,751^A0R,25,25^FH\^CI28^FDLOTE / SUB-LOTE:^FS^CI27 " )
        EndIf
        MsCbWrite( " ^FT518,751^A0R,25,25^FH\^CI28^FDDATA FABRICACAO:^FS^CI27 " )
        MsCbWrite( " ^FT502,24^A0R,25,25^FH\^CI28^FDDESCRICAO:^FS^CI27' " )
        MsCbWrite( " ^FT406,24^A0R,25,25^FH\^CI28^FDLARGURA (mm):^FS^CI27 " )
        MsCbWrite( " ^FT358,24^A0R,25,25^FH\^CI28^FDDIAM. INTERNO (Pol.):^FS^CI27 " )
        MsCbWrite( " ^FT310,24^A0R,25,25^FH\^CI28^FDDIAM. EXTERNO (mm):^FS^CI27 " )
        MsCbWrite( " ^FT262,24^A0R,25,25^FH\^CI28^FDPESO LIQUIDO (Kg):^FS^CI27 " )
        MsCbWrite( " ^FT215,24^A0R,25,25^FH\^CI28^FDPESO BRUTO (Kg):^FS^CI27 " )
        MsCbWrite( " ^FT151,24^A0R,25,25^FH\^CI28^FDINFORMACOES COMPLEMENTARES:^FS^CI27 " )
        MsCbWrite( " ^FT111,24^A0R,25,25^FH\^CI28^FDPedido Venda:^FS^CI27 " )
        MsCbWrite( " ^FT79,24^A0R,25,25^FH\^CI28^FDCliente:^FS^CI27 " )
        MsCbWrite( " ^FT47,24^A0R,25,25^FH\^CI28^FDObs.:^FS^CI27 " )
        //-- Dados
        MsCbWrite( " ^FT710,312^A0R,25,25^FH\^CI28^FD" + aEndereco[01] + "^FS^CI27 " )
        MsCbWrite( " ^FT678,312^A0R,25,25^FH\^CI28^FD" + aEndereco[02] + "^FS^CI27 " )
        MsCbWrite( " ^FT646,312^A0R,25,25^FH\^CI28^FD" + aEndereco[03] + "^FS^CI27 " )
        MsCbWrite( " ^FT548,24^A0R,51,51^FH\^CI28^FD" + cCodPrd + "^FS^CI27 " )
        If Empty(aParam[07])
            MsCbWrite( " ^FT560,751^A0R,31,30^FH\^CI28^FD" + AllTrim(aParam[06]) + "^FS^CI27 " )
        Else
            MsCbWrite( " ^FT560,751^A0R,31,30^FH\^CI28^FD" + AllTrim(aParam[06]) + " / " + AllTrim(aParam[07]) + "^FS^CI27 " )
        EndIf
        MsCbWrite( " ^FT480,751^A0R,31,30^FH\^CI28^FD" + DtoC( aParam[04] ) + "^FS^CI27 " )
        MsCbWrite( " ^FT464,24^A0R,31,30^FH\^CI28^FD" + cDscPrd + "^FS^CI27 " )
        MsCbWrite( " ^FT404,424^A0R,31,30^FH\^CI28^FD" + cLarguraPA + "^FS^CI27 " )
        MsCbWrite( " ^FT356,424^A0R,31,30^FH\^CI28^FD" + cDiamIntPA + "^FS^CI27 " )
        MsCbWrite( " ^FT308,424^A0R,31,30^FH\^CI28^FD" + cDiamExtPA + "^FS^CI27 " )
        MsCbWrite( " ^FT260,424^A0R,31,30^FH\^CI28^FD" + AllTrim( Transform( Round(aParam[02], 01), "@E 99999.9" ) ) + "^FS^CI27 " )
        MsCbWrite( " ^FT213,424^A0R,31,30^FH\^CI28^FD" + AllTrim( Transform( Round(aParam[03], 01), "@E 99999.9" ) ) + "^FS^CI27 " )
        MsCbWrite( " ^FT111,192^A0R,25,25^FH\^CI28^FD" + AllTrim( aDadosPVOri[01] ) + "^FS^CI27 " )
        MsCbWrite( " ^FT79,120^A0R,25,25^FH\^CI28^FD" + AllTrim( aDadosPVOri[02] ) + "^FS^CI27 " )
        MsCbWrite( " ^FT47,88^A0R,25,25^FH\^CI28^FD" + AllTrim( aDadosPVOri[03] ) + "^FS^CI27 " )
        //-- Data Matrix 2D
        MsCbWrite( " ^FT245,798^BXR,7,200,0,0,1,_,1 " )
        MsCbWrite( " ^FH\^FD" + cCodBar2D + "^FS " )
        MsCbWrite( " ^PQ1,0,1,Y " )
        MsCbEnd()
    Next nX

    MsCbClosePrinter()

Return


/*/{Protheus.doc} RetAiMan
Retorna string com codigo de barras GS1 Application Identifier (AI)
@type function
@version 1.0
@author Do Think
@since 08/05/2022
@param aConteudo, array, contendo AI e conteudo
@return variant, codigo de barras no formato string
/*/
Static Function RetAiMan(aConteudo)
    Local cRet := "]d2"
    Local nI   := 0

    For nI := 1 To Len(aConteudo)
        cRet += AllTrim( aConteudo[nI, 01] )
        cRet += AllTrim( aConteudo[nI, 02] )
    Next nI

Return cRet


/*/{Protheus.doc} GetDimen
Funcao que retorna as dimensoes do codigo/produto
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 29/04/2022
@param cCod, character, Codigo do produto
@param cRetType, character, Tipo de retorno
@return array, Array com as dimensoes
/*/
Static Function GetDimen(cCod, cRetType)
    Local aRet    := {}
    Local nI      := 0
    Local cAllDim := ""

    Default cRetType := "C"

    cAllDim := Right( AllTrim( cCod ), IIf( u_xIsOff(cCod), 10, 09 ) )

    aAdd(aRet, SubStr( cAllDim, 01, 02 ) ) //-- Diametro interno do tubo da bobina (Polegadas)
    aAdd(aRet, SubStr( cAllDim, 03, 03 ) ) //-- Diametro externo da bobina (mm)
    aAdd(aRet, SubStr( cAllDim, 06, 04 ) ) //-- Largura da bobina (mm)

    If cRetType == "N"
        For nI := 1 To Len(aRet)
            aRet[nI] := Val(aRet[nI])
        Next nI
    EndIf

Return aClone(aRet)


/*/{Protheus.doc} GetEnd
Retorna o endereco da Replas
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 21/05/2022
@return array, Array com enredeco da Replas SP
/*/
Static Function GetEnd()
    Local aArea     := GetArea()
    Local aCpoSM0   := { "M0_CODIGO" ,;
                         "M0_CODFIL" ,;
                         "M0_NOMECOM",;
                         "M0_CGC"    ,;
                         "M0_INSCM"  ,;
                         "M0_CIDENT" ,;
                         "M0_ESTENT" ,;
                         "M0_ENDENT" ,;
                         "M0_BAIRENT",;
                         "M0_CEPENT" ,;
                         "M0_COMPENT",;
                         "M0_TEL"     }    
    Local aSM0      := {}
    Local aRet      := {}
    Local cFilOrig  := GetMV( "RE_FILORIG", .F., "0302" )
    Local cEndLin01 := ""
    Local cEndLin02 := ""
    Local cEndLin03 := ""

    aSM0 := FWSM0Util():GetSM0Data( , cFilOrig, aCpoSM0 )
    If !Empty(aSM0)
        cEndLin01 := Upper( AllTrim(aSM0[08, 02]) )
        cEndLin02 := Upper( AllTrim(aSM0[09, 02]) + " - CEP: " + Transform( aSM0[10, 02], "@R 99999-999" ) + " - " + AllTrim(aSM0[06, 02])  + " - " + aSM0[07, 02] )  
        cEndLin03 := "CNPJ: " + Transform( aSM0[04, 02], "@R 99.999.999/9999-99" )

        aAdd( aRet, cEndLin01 )
        aAdd( aRet, cEndLin02 )
        aAdd( aRet, cEndLin03 )
    EndIf

    RestArea( aArea )

Return aClone( aRet )


/*/{Protheus.doc} REPCPR3V
Funcao que realiza validacoes dos parametros
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 26/05/2022
@return logical, Retorno logico
/*/
User Function REPCPR3V()
    Local lRet := .T.

    If lRet .And. !U_REFATA02( 1, MV_PAR01 )
        CBAlert( "Informe um produto que seja filme!", "Parametro invalido", .T., 3000 ) 
        lRet := .F.
    EndIf

    If lRet .And. !U_REFATA02( 3, MV_PAR01 )
        CBAlert( "Informe um produto do tipo PA!", "Parametro invalido", .T., 3000 ) 
        lRet := .F.
    EndIf

Return lRet



