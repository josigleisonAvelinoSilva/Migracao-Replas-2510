#INCLUDE "PROTHEUS.CH"


/*/{Protheus.doc} REPCPR01
Imprime etiqueta de Materia Prima
@type function
@version  1.0
@author Do Think
@since 08/05/2022
@obs Projeto Novo PCP (Etiquetas)
/*/
User Function REPCPR01()
    Local aParam   := {}
    Local aPergAux := {}
    Local cRotina  := "REPCPR01"
    Local cPerg    := If( IsTelNet(), "VTPERGUNTE", "PERGUNTE" )
  
    If !IsTelNet()
        SetKey( VK_F4, {|| ShowF4() } )
    EndIf

    While .T.
        aPergAux := {}
        Pergunte( cRotina, .F., /*cTitle*/, /*lOnlyView*/, /*oDlg*/, /*lUseProf*/, @aPergAux )

        MV_PAR01 := Space( TamSX3("B8_PRODUTO")[1] )
        //MV_PAR02 := Space( TamSX3("B8_LOCAL")[1] )
        MV_PAR03 := 0
        MV_PAR04 := 0
        MV_PAR05 := Space( TamSX3("B8_LOTECTL")[1] )
        MV_PAR06 := Space( TamSX3("B8_NUMLOTE")[1] )
        MV_PAR07 := CtoD( "//" )
        MV_PAR08 := CtoD( "//" )
        MV_PAR09 := 1
        __SaveParam( cRotina, aPergAux )

        If !&(cPerg)(cRotina, .T.)
            Return
        EndIf  

        If TudoOK()
            aParam := { MV_PAR01,; //-- 01 - Produto
                        MV_PAR02,; //-- 02 - Armazem
                        MV_PAR03,; //-- 03 - Peso Liquido
                        MV_PAR04,; //-- 04 - Peso Bruto
                        MV_PAR05,; //-- 05 - Lote
                        MV_PAR06,; //-- 06 - SubLote
                        MV_PAR07,; //-- 07 - Data de validade
                        MV_PAR08,; //-- 08 - Data de fabricacao
                        MV_PAR09,; //-- 09 - Quantidade
                        MV_PAR10 } //-- 10 - Local de impressao

            //-- Inicia a Impressao das etiquetas
            U_REPCPR1A(aParam)
        EndIf
    EndDo

    If !IsTelNet()
        SetKey( VK_F4, {|| } )
    EndIf

Return


/*/{Protheus.doc} ShowF4
Carrega a tela de saldo de lote ao clicar no F4
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 20/05/2022
/*/
Static Function ShowF4()
    Local cVar  := AllTrim(ReadVar())
    Local cProd := AllTrim(MV_PAR01)
    Local cArm  := AllTrim(MV_PAR02)
    
    If !Empty(cProd) .or. !Empty(cArm)
        cVar := Upper(cVar)
        If cVar == "MV_PAR05" .or. cVar == "MV_PAR06"
            //-- Funcao padrao que abre a tela de LOTES com o F4
            F4Lote(nil, nil, nil, "ACDI011", MV_PAR01, MV_PAR02, nil, "")

            //-- Preenche a data de Fabricacao do LOTE
            //-- B8_FILIAL+B8_NUMLOTE+B8_LOTECTL+B8_PRODUTO+B8_LOCAL+DTOS(B8_DTVALID)
            MV_PAR08 := Posicione("SB8", 2, xFilial("SB8") + MV_PAR06 + MV_PAR05 + MV_PAR01 + MV_PAR02, "B8_DFABRIC")
        EndIf
    EndIf

Return


/*/{Protheus.doc} TudoOK
Validacao geral do pergunte
@type function
@version 1.0
@author Do Think
@since 08/05/2022
@return logical, indica se existe algum parametro informado incorreto
/*/
Static Function TudoOK()
    Local lRet := .T.

    If Empty(MV_PAR01)
        CBAlert( "Informe o codigo de um produto!", "Parametro Vazio", .T., 3000 ) 
        lRet := .F.
    EndIf

    If lRet .And. Empty(MV_PAR02)
        CBAlert( "Informe o armazem!", "Parametro Vazio", .T., 3000 ) 
        lRet := .F.
    EndIf

    If lRet .And. Empty(MV_PAR03)
        CBAlert( "Informe o peso liquido!", "Parametro Vazio", .T., 3000 ) 
        lRet := .F.
    EndIf

    If lRet .And. Empty(MV_PAR04)
        CBAlert( "Informe o peso bruto!", "Parametro Vazio", .T., 3000 ) 
        lRet := .F.
    EndIf    

    If lRet 
        If Rastro(MV_PAR01)
            If Empty(MV_PAR05) .Or. Empty(MV_PAR06)
                CBAlert( "Informe o lote/sub-lote!", "Parametro Vazio", .T., 3000 ) 
                lRet := .F.
            EndIf

            If lRet .And. Empty(MV_PAR07)
                CBAlert( "Informe a validade!", "Parametro Vazio", .T., 3000 ) 
                lRet := .F.
            EndIf      

            If lRet .And. !Empty(MV_PAR08) .And. MV_PAR07 < MV_PAR08 //MV_PAR08 < MV_PAR07
                //CBAlert( "Data de producao nao pode ser menor que validade.", "Conteudo Invalido", .T., 3000 )
                CBAlert( "Data de validade nao pode ser menor que producao.", "Conteudo Invalido", .T., 3000 ) 
                lRet := .F.
            EndIf
        Else
            MV_PAR05 := Space( TamSX3("B8_LOTECTL")[1] )
            MV_PAR06 := Space( TamSX3("B8_NUMLOTE")[1] )
            MV_PAR07 := CtoD( "//" )
        EndIf
    EndIf    

    If Empty(MV_PAR09)
        MV_PAR09 := 1
    EndIf

Return lRet


/*/{Protheus.doc} REPCPR1A
Imprime etiqueta conforme parametros
@type function
@version 1.0
@author Do Think
@since 07/05/2022
@param aParam, array, Parametros que serao impressos na etiqueta
/*/
User Function REPCPR1A(aParam)
    Local aDimenMP   := {}
    Local aCodeBar   := {}
    Local cCodPrd    := ""
    Local cDscPrd    := ""
    Local cPrinter   := aParam[10]
    Local cLarguraMP := ""
    Local cDiamIntMP := ""
    Local cDiamExtMP := ""
    Local nX         := 0 

	If IsTelNet()
		VtMsg( "Imprimindo..." )
	EndIF

    If !CB5SetImp(cPrinter)
        CBAlert( "Local de impressao nao localizado!", "Impressora!", .T., 3000 ) 
        Return
    EndIf

    //-- Pega as dimensoes do produto
    aDimenMP   := GetDimen( aParam[01] )
    cDiamIntMP := aDimenMP[01]
    cDiamExtMP := aDimenMP[02]
    cLarguraMP := aDimenMP[03]

    cCodPrd  := Trim(aParam[01])
    cDscPrd  := GetAdvFVal( "SB1", "B1_DESC", xFilial("SB1") + cCodPrd, 1, " " )
    //cDtProd  := Substr(DToS(aParam[08]), 3)
    cPesoLiq := StrZero((aParam[03] * 10), 6)
    //cPesoBrt := StrZero((aParam[04] * 10), 6)

    //-- Dados CodeBar 2D - Datamatrix
    aAdd( aCodeBar, { "(92)"  , cCodPrd    } ) //-- Informacao interna da companhia (codigo do produto)
    //aAdd( aCodeBar, { "(11)"  , cDtProd    } ) //-- Data de producao, 6 digitos numericos no formato AAMMDD
    aAdd( aCodeBar, { "(10)"  , aParam[05] } ) //-- Numero Batch, de 1 a 20 digitos alfanumericos
    aAdd( aCodeBar, { "(240)" , aParam[06] } ) //-- Additional product identification assigned by the manufacturer
    aAdd( aCodeBar, { "(3101)", cPesoLiq   } ) //-- Peso liquido (em kg), 6 digitos
    //aAdd( aCodeBar, { "(3301)", cPesoBrt   } ) //-- Peso bruto (em kg), 6 digitos

    cCodBar2D := RetAiMan(aCodeBar)

    For nX := 1 To aParam[09]
        MsCbBegin( 1, 3 )        
        MsCbWrite( " ^XA " )
        MsCbWrite( " ^MMT " )
        MsCbWrite( " ^PW759 " )
        MsCbWrite( " ^LL1039 " )
        MsCbWrite( " ^LS0 " )
        MsCbWrite( " ^FT671,24^A0R,64,142^FH\^CI28^FDMATERIA PRIMA^FS^CI27 " )
        MsCbWrite( " ^LRY^FO655,24^GB0,998,80^FS^LRN " )
        MsCbWrite( " ^FO471,781^GB176,0,4^FS " )
        MsCbWrite( " ^FO375,326^GB96,0,4^FS " )
        MsCbWrite( " ^FO645,24^GB0,991,4^FS " )
        MsCbWrite( " ^FO549,24^GB0,759,4^FS " )
        MsCbWrite( " ^FO469,24^GB0,991,4^FS " )
        MsCbWrite( " ^FO373,24^GB0,991,4^FS " )
        MsCbWrite( " ^FO375,653^GB96,0,4^FS " )
        MsCbWrite( " ^FO277,24^GB0,991,4^FS " )
        MsCbWrite( " ^FO281,494^GB96,0,4^FS " )
        MsCbWrite( " ^FO281,781^GB96,0,4^FS " )
        MsCbWrite( " ^FO39,326^GB240,0,4^FS " )
        MsCbWrite( " ^FO39,653^GB240,0,4^FS " )
        MsCbWrite( " ^FT614,24^A0R,25,25^FH\^CI28^FDPRODUTO:^FS^CI27 " )
        MsCbWrite( " ^FT614,797^A0R,25,25^FH\^CI28^FDLOCALIZACAO:^FS^CI27 " )
        MsCbWrite( " ^FT518,24^A0R,25,25^FH\^CI28^FDDESCRICAO:^FS^CI27 " )
        MsCbWrite( " ^FT438,24^A0R,25,25^FH\^CI28^FDLARGURA (mm):^FS^CI27 " )
        MsCbWrite( " ^FT438,336^A0R,25,25^FH\^CI28^FDDIAM. INTERNO (Pol.):^FS^CI27 " )
        MsCbWrite( " ^FT438,663^A0R,25,25^FH\^CI28^FDDIAM. EXTERNO (mm):^FS^CI27 " )
        MsCbWrite( " ^FT342,24^A0R,25,25^FH\^CI28^FDLOTE:^FS^CI27 " )
        MsCbWrite( " ^FT342,504^A0R,25,25^FH\^CI28^FDSUB-LOTE:^FS^CI27 " )
        MsCbWrite( " ^FT342,791^A0R,25,25^FH\^CI28^FDDATA FABRIC.^FS^CI27 " )
        MsCbWrite( " ^FT246,336^A0R,25,25^FH\^CI28^FDPESO LIQUIDO (KG):^FS^CI27 " )
        MsCbWrite( " ^FT246,663^A0R,25,25^FH\^CI28^FDPESO BRUTO (KG):^FS^CI27 " )
        //-- Dados
        MsCbWrite( " ^FT564,24^A0R,51,51^FH\^CI28^FD" + cCodPrd + "^FS^CI27 " )
        MsCbWrite( " ^FT480,24^A0R,31,30^FH\^CI28^FD" + cDscPrd + "^FS^CI27 " )
        MsCbWrite( " ^FT388,24^A0R,51,51^FH\^CI28^FD" + cLarguraMP + "^FS^CI27 " )
        MsCbWrite( " ^FT388,336^A0R,51,51^FH\^CI28^FD" + cDiamIntMP + "^FS^CI27 " )
        MsCbWrite( " ^FT388,663^A0R,51,51^FH\^CI28^FD" + cDiamExtMP + "^FS^CI27 " )
        MsCbWrite( " ^FT292,24^A0R,51,51^FH\^CI28^FD" + aParam[05] + "^FS^CI27 " )
        MsCbWrite( " ^FT292,504^A0R,51,51^FH\^CI28^FD" + aParam[06] + "^FS^CI27 " )
        MsCbWrite( " ^FT292,791^A0R,51,51^FH\^CI28^FD" + DtoC( aParam[08] ) + "^FS^CI27 " )
        MsCbWrite( " ^FT97,344^A0R,102,101^FH\^CI28^FD" + AllTrim( Transform( Round(aParam[03], 01), "@E 99999.9" ) ) + "^FS^CI27 " )
        MsCbWrite( " ^FT97,671^A0R,102,101^FH\^CI28^FD" + AllTrim( Transform( Round(aParam[04], 01), "@E 99999.9" ) ) + "^FS^CI27 " )
        //-- Data Matrix 2D
        MsCbWrite( " ^FT75,79^BXR,6,200,0,0,1,_,1 " )
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


/*/{Protheus.doc} REPCPR1V
Funcao que realiza validacoes dos parametros
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 26/05/2022
@return logical, Retorno logico
/*/
User Function REPCPR1V()
    Local lRet := .T.

    If lRet .And. !U_REFATA02( 1, MV_PAR01 )
        CBAlert( "Informe um produto que seja filme!", "Parametro invalido", .T., 3000 ) 
        lRet := .F.
    EndIf
    
    If lRet .And. !U_REFATA02( 4, MV_PAR01 )
        CBAlert( "Informe um produto do tipo MP!", "Parametro invalido", .T., 3000 ) 
        lRet := .F.
    EndIf

Return lRet
