#INCLUDE "PROTHEUS.CH"
#INCLUDE "APVT100.CH"


/*/{Protheus.doc} REESTA08
Rotina especifica e temporaria de gravacao do INVETARIO REPLAS 
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 17/07/2022
@obs Projeto Novo PCP - 1º INVENTARIO PARA AJUSTES E GERACAO DOS SALDOS
/*/
User Function REESTA08()
    Local aKey     := Array(3)
    Local nQtdPEtq := GetMV( "RE_QTDPETQ", .F., 2 )  //-- Quantidade padrao de etiquetas a serem impressas no inventario Replas

    Private cArm       := Space( TamSX3("B2_LOCAL")[1] )
    Private cImp       := Space( TamSX3("CB5_CODIGO")[1] )
    Private cCodEtiq   := ""
    Private cCodReplas := ""
    Private cLoteForn  := ""
    Private nQtdEtq    := nQtdPEtq
    Private nQtdBob    := 0
    Private lPortatil  := .F. //-- Indica se a impressora e do tipo portatil
    Private lSetOff    := .F.

    aKey[01] := VTSetKey( 18, { || Registros() }, "Registros" )    //-- CTRL + R - Registros de produtos ja contados
    akey[02] := VTSetKey( 24, { || Exclui() }   , "Exclui Reg." )  //-- CTRL + X - Exclui registro contado
    akey[03] := VTSetKey( 15, { || SetOff() }   , "Habilita Off" ) //-- CTRL + O - Atalho para setar produtos do tido OFF (Segunda Linha)

    While .T.
        VTClear()                        
        @ 0,0 VtSay Padc("**INVENTARIO**", VTMaxCol())
        @ 2,0 VtSay "Armazem" //-- Armazem onde o inventario sera realizado
        @ 3,0 VtGet cArm  Pict "@!" Valid VldArm() F3 "NNR"
        @ 4,0 VtSay "Impressora" //-- Local de impressao onde as etiquetas serao impressas
        @ 5,0 VtGet cImp  Pict "@!" Valid VldImp() F3 "CB5"
        VTRead

        If VtLastKey() == 27
            If VtYesNo( "Deseja sair do Inventario?", "ATENCAO" )
                Exit 
            EndIf
        EndIf

        VTClear()

        While .T. .And. !Empty(cArm) .And. !Empty(cImp)
            cCodEtiq   := Space( 75 )
            cCodReplas := Space( TamSX3("B1_COD")[1] )
            cLoteForn  := ""
            nQtdEtq    := nQtdPEtq
            nQtdBob    := 0

            VTClear()
            @ 0,0 VtSay Padc("**INVENTARIO**", VTMaxCol())
            @ 2,0 VtSay "Qtd. Etiqueta"
            @ 3,0 VtGet nQtdEtq Pict "999" Valid VldQtdEtq() When VTLastKey() == 5
            @ 4,0 VtSay "Quantidade (Kg)"
            @ 5,0 VtGet nQtdBob Pict "@E 99,999.9" //Valid nQtdBob > 0
            @ 6,0 VtSay "Produto"
            @ 7,0 VtGet cCodEtiq Pict "@!" Valid VldProd()
            VTRead

            If VtLastKey() == 27
                Exit
            EndIf
        EndDo
    EndDo

    VTSetKey( 18, aKey[01] )
    VTSetKey( 24, aKey[02] )
    VTSetKey( 15, aKey[03] )

Return


/*/{Protheus.doc} VldArm
Valida armazem
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 17/07/2022
@return logical, Retorno logico
/*/
Static Function VldArm()
    If Empty(cArm)
        Return .F.
    EndIf	                 

    DbSelectArea("NNR")
    NNR->( DbSetOrder(1) )
    If !NNR->( DbSeek( xFilial("NNR") + cArm ) ) 
		VtBeep(2)
		VtAlert( "Armazem nao encontrado.", "ATENCAO", .T., 3000 )
        Return .F.
    EndIf

Return .T.


/*/{Protheus.doc} VldImp
Valida local de impressao das etiquetas
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 17/07/2022
@return logical, Retorno logico
/*/
Static Function VldImp()
    Local lCB5

    lPortatil := .F.

    If Empty(cImp)
        Return .F.
    EndIf

    DbSelectArea("CB5")
    CB5->( DbSetOrder(1) )
    lCB5 := CB5->( DbSeek( xFilial("CB5") + cImp ) )

    If "PORTATIL" $ UPPER(AllTrim(CB5->CB5_DESCRI))
        lPortatil := .T.
    EndIf

    If !lCB5
		VtBeep(2)
		VtAlert( "Local de impressao nao encontrado.", "ATENCAO", .T., 3000 )
        Return .F.
    EndIf

Return .T.


/*/{Protheus.doc} VldQtdEtq
Valida quantidade de etiquetas a serem impressas
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 01/08/2022
@return logical, Retorno logico
/*/
Static Function VldQtdEtq()
    Local nQtdMaxEtq := GetMV( "RE_QTDMAXE", .F., 6 )  //-- Quantidade maxima de etiquetas por bobina a serem impressas no inventario Replas

    If nQtdEtq < 1
        Return .F.
    EndIf

    If nQtdEtq > nQtdMaxEtq
		VtBeep(2)
		VtAlert( "Quantidade maxima " + CValToChar(nQtdMaxEtq) + " etiquetas por bobina.", "ATENCAO", .T., 3000 )
        Return .F.
    EndIf

Return .T.


/*/{Protheus.doc} VldProd
Valida produto e chama a inclusao de contagens
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 17/07/2022
@param cProd, character, Produto
@return logical, Retorno logico
/*/
Static Function VldProd()
    Local aEtiqueta := {}
    Local cTipId    := ""
    Local lRet      := .F.

    If Empty(cCodEtiq)
        Return lRet
    EndIf

	cTipId := CBRetTipo(cCodEtiq)
	If !(cTipId $ "EAN8OU13-EAN14-EAN128")
        VtBeep(2)
		VtAlert( "Etiqueta invalida.", "Aviso", .T., 3000 )
		VTKeyboard(chr(20))
		Return lRet
	EndIf

    If SubStr( cCodEtiq, 01, 02 ) == "MP"
        //-- Produto digitado
        cCodReplas := cCodEtiq
        cLoteForn  := ""

        If Empty(cCodReplas)
            VtBeep(2)
            VtAlert( "Codigo Replas nao localizado.", "ATENCAO", .T., 3000 )
        Else
            //-- Inclui a contagem
            IncContagem()

            lRet := .T.
        EndIf

		VTKeyboard(chr(20))
		Return lRet
    EndIf

    If cTipId == "EAN8OU13"
        //-- Retorna o codigo do produto da REPLAS com base na etiqueta lida da Industria MM Manaus
        cCodReplas := U_REESTA7C( cCodEtiq, "21338912000148" )
        cLoteForn  := ""

        If Empty(cCodReplas)
            VtBeep(2)
            VtAlert( "Codigo Replas nao localizado.", "ATENCAO", .T., 3000 )
        Else
            //-- Inclui a contagem
            IncContagem()

            lRet := .T.
        EndIf

		VTKeyboard(chr(20))
		Return lRet
    EndIf

    If cTipId == "EAN128" .And. Len(AllTrim(cCodEtiq)) < 45
        //-- Retorna o codigo do produto da REPLAS com base na etiqueta lida da Innova Manaus
        cCodReplas := U_REESTA7B( cCodEtiq )
        cLoteForn  := SubStr( cCodEtiq, 01, 10 )

        If Empty(cCodReplas)
            VtBeep(2)
            VtAlert( "Codigo Replas nao localizado.", "ATENCAO", .T., 3000 )
        Else
            //-- Inclui a contagem
            IncContagem()

            lRet := .T.
        EndIf

		VTKeyboard(chr(20))
		Return lRet
    EndIf

	//aEtiqueta := CBRetEtiEAN(cCodEtiq)

	If ExistBlock("CBRETEAN")
		//-- Retorno devera ser um array conforme abaixo:
		//-- {codigo do produto,quantidade,lote,data de validade, numero de serie,sub-lote}
		aEtiqueta := ExecBlock("CBRETEAN",,,{cCodEtiq})
	EndIf	

	If Empty(aEtiqueta) .Or. Empty(aEtiqueta[2])
        VtBeep(2)
		VtAlert( "Etiqueta invalida.", "Aviso", .T., 3000 )
		VTKeyboard(chr(20))
		Return lRet
    Else
        cCodReplas := aEtiqueta[01]
        cLoteForn  := ""

        If Empty(cCodReplas)
            VtBeep(2)
            VtAlert( "Codigo Replas nao localizado.", "ATENCAO", .T., 3000 )
        Else
            //-- Nova etiqueta da MM AMAZONIA - Feita pela DOTHINK
            If "(91)" $ cCodEtiq
                DbSelectArea("SZ7")
                SZ7->(DbSetOrder(2))
                If SZ7->(DbSeek(xFilial("SZ7") + aEtiqueta[06] + aEtiqueta[03]))
                    VtBeep(2)
                    VtAlert( "Produto ja contado.", "ATENCAO", .T., 3000 )
                    VTKeyboard(chr(20))
                    Return lRet
                EndIf

                IncContagem(aEtiqueta)

                lRet := .T.
            Else
                If VtYesNo( "Deseja re-imprimir etiqueta?", "ATENCAO" )
                    IncContagem(aEtiqueta)

                    lRet := .T.
                EndIf
            EndIf
        EndIf

		VTKeyboard(chr(20))
		Return lRet
	EndIf

Return .T.


/*/{Protheus.doc} IncContagem
Relializa tratamento para incluisao de contagem
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 01/08/2022
/*/
Static Function IncContagem(aEtiq)
    Local aXParam   := {}
    Local cLoteCtl  := ""
    Local cNumLote  := ""
    Local nPrazoBob := GetMV( "RE_PRZBOB", .F., 360 ) //-- Prazo padrao de validade padrao para as bobinas (Filmes)
    Local dDtValid  := CToD("//")
    Local dDtFabric := CToD("//")
    Local lIncCont  := .T.

    Default aEtiq := {}

    If lSetOff
        //-- Habilita a contagem de produtos do tipo OFF (Segunda linha)
        cCodReplas := PadR( AllTrim(cCodReplas) + "R", TamSX3("B1_COD")[01] )
        lSetOff    := .F.
    Else
        cCodReplas := PadR( cCodReplas, TamSX3("B1_COD")[01] )
    EndIf

    If !Empty(aEtiq)
        nQtdBob   := aEtiq[02]
        cLoteCtl  := aEtiq[03]
        cNumLote  := aEtiq[06]

        //-- Nova etiqueta da MM AMAZONIA - Feita pela DOTHINK
        If "(91)" $ cCodEtiq
            dDtValid  := dDataBase + nPrazoBob
            dDtFabric := dDataBase
        Else
            DbSelectArea("SZ7")
            SZ7->(DbSetOrder(2))
            SZ7->(DbSeek(xFilial("SZ7") + cNumLote + cLoteCtl))
            dDtFabric := SZ7->Z7_DFABRIC

            lIncCont  := .F.
        EndIf
    Else
        //-- Descobre o Sub-lote
        cNumLote := NextLote( cCodReplas, "S" )

        //-- Descobre o Lote
        cLoteCtl := NextLote( cCodReplas, "L", cNumLote )

        //-- Calcula a data de validade
        DbSelectArea("SB1")
        SB1->( DbSetOrder(1) )
        SB1->( DbSeek( xFilial("SB1") + cCodReplas ) )

        dDtValid  := dDataBase + If( !Empty(SB1->B1_PRVALID), SB1->B1_PRVALID, nPrazoBob ) 
        dDtFabric := dDataBase
    EndIf

    If Empty(nQtdBob)
        VtBeep(2)
        VtAlert( "Informe uma Quantidade (Kg).", "ATENCAO", .T., 3000 )
        Return
    EndIf

    //-- Parametros para contagem e impressao da etiqueta
    aXParam := {}
    aAdd( aXParam, cCodReplas ) //-- [01] - Codigo do Produto da REPLAS
    aAdd( aXParam, cArm       ) //-- [02] - Armazem
    aAdd( aXParam, nQtdBob    ) //-- [03] - Quantidade (Peso Liquido)
    aAdd( aXParam, 0          ) //-- [04] - (Peso Bruto), nao usado
    aAdd( aXParam, cLoteCtl   ) //-- [05] - Lote
    aAdd( aXParam, cNumLote   ) //-- [06] - Sub-Lote
    aAdd( aXParam, dDtValid   ) //-- [07] - Data de validade
    aAdd( aXParam, dDtFabric  ) //-- [08] - Data de fabricacao
    aAdd( aXParam, nQtdEtq    ) //-- [09] - Qtd. de etiquetas
    aAdd( aXParam, cImp       ) //-- [10] - Local de impressao
    aAdd( aXParam, cLoteForn  ) //-- [11] - Lote do Fornecedor
    aAdd( aXParam, cCodEtiq   ) //-- [12] - Conteudo da etiqueta lida

    If lIncCont
        //-- Inclui registro
        IncRegistro(aXParam)
    EndIf

    If !("(91)" $ cCodEtiq)
        //-- Impressao das etiquetas
        U_REESTA8B(aXParam)
    EndIf

Return


/*/{Protheus.doc} IncRegistro
Funcao que inclui os registros da contagem 
na tabela temporario do inventario e imprimi 
as etiquetas
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 17/07/2022
@param aXParam, array, Parametros
/*/
Static Function IncRegistro(aXParam)
    Local cCodProd  := aXParam[01]
    Local cLocal    := aXParam[02]
    Local nQuant    := aXParam[03]
    Local cLoteCtl  := aXParam[05]
    Local cNumLote  := aXParam[06]
    Local dDtValid  := aXParam[07]
    Local dDtFabric := aXParam[08]
    Local cLoteForn := aXParam[11]
    Local cCodEtiq  := aXParam[12]

    DbSelectArea("SZ7")
    RecLock( "SZ7", .T. )
        SZ7->Z7_FILIAL  := xFilial("SZ7")
        SZ7->Z7_COD     := cCodProd
        SZ7->Z7_LOCAL   := cLocal
        SZ7->Z7_QUANT   := nQuant
        SZ7->Z7_QTDORI  := nQuant
        SZ7->Z7_LOTECTL := cLoteCtl
        SZ7->Z7_NUMLOTE := cNumLote
        SZ7->Z7_DTVALID := dDtValid
        SZ7->Z7_DFABRIC := dDtFabric
        SZ7->Z7_LOTEFOR := cLoteForn
        SZ7->Z7_STATUS  := "1" //-- 1=Nao processado;2=Processado
        SZ7->Z7_DTINV   := dDataBase
        SZ7->Z7_HRINV   := SubStr( Time(), 1, 5 )
        SZ7->Z7_CODUSR  := RetCodUsr()
        SZ7->Z7_CODETI  := cCodEtiq
        SZ7->Z7_GRUPO   := GetAdvFVal("SB1", "B1_GRUPO", xFilial("SB1") + PadR(cCodProd, Len(SB1->B1_COD)), 1, " ")
    SZ7->( MsUnLock() )

Return


/*/{Protheus.doc} REESTA8B
Imprime etiqueta conforme parametros
@type function
@version 1.0
@author Do Think
@since 07/05/2022
@param aParam, array, Parametros que serao impressos na etiqueta
/*/
User Function REESTA8B(aParam)
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
	EndIf

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
        If lPortatil
            //-- Usada somente para a impressora Zebra portatil RW 420
            MsCbWrite( " ^XA " )
            MsCbWrite( " ^MMT " )
            MsCbWrite( " ^PW759 " )
            MsCbWrite( " ^LL1039 " )
            MsCbWrite( " ^LS0 " )
            MsCbWrite( " ^FT88,1039^A0B,64,137^FH\^CI28^FDMATERIA PRIMA^FS^CI27 " )
            MsCbWrite( " ^LRY^FO24,81^GB0,958,80^FS^LRN " )
            MsCbWrite( " ^FO112,301^GB176,0,4^FS " )
            MsCbWrite( " ^FO288,742^GB96,0,4^FS " )
            MsCbWrite( " ^FO110,78^GB0,961,4^FS " )
            MsCbWrite( " ^FO206,302^GB0,737,4^FS " )
            MsCbWrite( " ^FO286,78^GB0,961,4^FS " )
            MsCbWrite( " ^FO382,78^GB0,961,4^FS " )
            MsCbWrite( " ^FO288,425^GB96,0,4^FS " )
            MsCbWrite( " ^FO478,78^GB0,961,4^FS " )
            MsCbWrite( " ^FO382,580^GB96,0,4^FS " )
            MsCbWrite( " ^FO382,301^GB96,0,4^FS " )
            MsCbWrite( " ^FO480,742^GB240,0,4^FS " )
            MsCbWrite( " ^FO480,425^GB240,0,4^FS " )
            MsCbWrite( " ^FT145,1039^A0B,25,25^FH\^CI28^FDPRODUTO:^FS^CI27 " )
            MsCbWrite( " ^FT145,289^A0B,25,25^FH\^CI28^FDLOCALIZACAO:^FS^CI27 " )
            MsCbWrite( " ^FT241,1039^A0B,25,25^FH\^CI28^FDDESCRICAO:^FS^CI27 " )
            MsCbWrite( " ^FT321,1039^A0B,25,25^FH\^CI28^FDLARGURA (mm):^FS^CI27 " )
            MsCbWrite( " ^FT321,737^A0B,25,25^FH\^CI28^FDDIAM. INTERNO (Pol.):^FS^CI27 " )
            MsCbWrite( " ^FT321,419^A0B,25,25^FH\^CI28^FDDIAM. EXTERNO (mm):^FS^CI27 " )
            MsCbWrite( " ^FT417,1039^A0B,25,25^FH\^CI28^FDLOTE:^FS^CI27 " )
            MsCbWrite( " ^FT417,574^A0B,25,25^FH\^CI28^FDSUB-LOTE:^FS^CI27 " )
            MsCbWrite( " ^FT417,295^A0B,25,25^FH\^CI28^FDDATA FABRIC.^FS^CI27 " )
            MsCbWrite( " ^FT513,737^A0B,25,25^FH\^CI28^FDPESO LIQUIDO (KG):^FS^CI27 " )
            MsCbWrite( " ^FT513,419^A0B,25,25^FH\^CI28^FDPESO BRUTO (KG):^FS^CI27 " )
            //-- Dados
            MsCbWrite( " ^FT195,1039^A0B,51,48^FH\^CI28^FD" + cCodPrd + "^FS^CI27 " )
            MsCbWrite( " ^FT279,1039^A0B,31,30^FH\^CI28^FD" + cDscPrd + "20^FS^CI27 " )
            MsCbWrite( " ^FT371,1039^A0B,51,48^FH\^CI28^FD" + cLarguraMP + "^FS^CI27 " )
            MsCbWrite( " ^FT371,737^A0B,51,48^FH\^CI28^FD" + cDiamIntMP + "^FS^CI27 " )
            MsCbWrite( " ^FT371,419^A0B,51,48^FH\^CI28^FD" + cDiamExtMP + "^FS^CI27 " )
            MsCbWrite( " ^FT467,1039^A0B,51,48^FH\^CI28^FD" + aParam[05] + "^FS^CI27 " )
            MsCbWrite( " ^FT467,574^A0B,51,48^FH\^CI28^FD" + aParam[06] + "^FS^CI27 " )
            MsCbWrite( " ^FT467,295^A0B,51,48^FH\^CI28^FD" + DtoC( aParam[08] ) + "^FS^CI27 " )
            MsCbWrite( " ^FT662,729^A0B,102,99^FH\^CI28^FD" + AllTrim( Transform( Round(aParam[03], 01), "@E 99999.9" ) ) + "^FS^CI27 " )
            //-- Data Matrix 2D
            MsCbWrite( " ^FT684,976^BXB,6,200,0,0,1,_,1 " )
            MsCbWrite( " ^FH\^FD" + cCodBar2D + "^FS " )
            MsCbWrite( " ^PQ1,0,1,Y " )
        Else
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
            //-- Data Matrix 2D
            MsCbWrite( " ^FT75,79^BXR,6,200,0,0,1,_,1 " )
            MsCbWrite( " ^FH\^FD" + cCodBar2D + "^FS " )
            MsCbWrite( " ^PQ1,0,1,Y " )
        EndIf
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

 
/*/{Protheus.doc} REESTA8A
Tela dos registro de inventario replas para ajustes e geracao de saldos
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 17/07/2022
/*/
User Function REESTA8A()
    Local cAlias   := "SZ7"
    Local cTitulo  := "REGISTROS DE INVENTARIO REPLAS"
    Local aRotAdic := {} 

    DbSelectArea("SZ7")
    SZ7->( DbSetOrder(1) )

    //-- Essa rotina serve para apagar o arquivo "SPOOL.SEM" de semaforo do MSCBSPOOL
    aAdd(aRotAdic, { "Excluir SPOOL.SEM", "U_REESTA8D", 0 , 6 } )

    AxCadastro( cAlias, cTitulo, ".T.", ".T.", aRotAdic )

Return


/*/{Protheus.doc} Registros
Telinha de registros dos produtos contados - CTRL + R
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 17/07/2022
/*/
Static Function Registros()
    Local aCab   := { "Produto", "Qtde", "Lote", "Sub-Lote" } 
    Local aLista := {}
    Local aSize  := { 18, 07, 12, 09 }
    Local aSave  := VtSave()
    Local cQuery := ""      

    cQuery := " SELECT " + CRLF
    cQuery += "     * " + CRLF 
    cQuery += " FROM " + CRLF 
    cQuery += "     " + RetSqlName("SZ7") + " SZ7 " + CRLF
    cQuery += " WHERE " + CRLF
    cQuery += "     SZ7.Z7_FILIAL = '" + xFilial("SZ7") + "' " + CRLF
    cQuery += "     AND SZ7.Z7_QUANT > 0 " + CRLF 
    cQuery += "     AND SZ7.Z7_DTINV = '" + DToS(dDataBase) + "' " + CRLF
    cQuery += "     AND SZ7.Z7_CODUSR = '" + RetCodUsr() + "' " + CRLF
    cQuery += "     AND SZ7.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += " ORDER BY SZ7.R_E_C_N_O_ DESC " + CRLF

	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "_TMP", .F., .T. )

    While _TMP->( !Eof() )
        aAdd( aLista, { _TMP->Z7_COD, Str( _TMP->Z7_QUANT, 6, 1 ), _TMP->Z7_LOTECTL, _TMP->Z7_NUMLOTE } )

        _TMP->( DbSkip() )
    EndDo

    _TMP->( DbCloseArea() )

    VtClear()
    @ 0,0 VtSay Padc("**REGISTROS**", VTMaxCol())
    VTaBrowse( 2, 0, 7, 19, aCab, aLista, aSize )
    VtRestore( ,,,, aSave )
    
Return


/*/{Protheus.doc} Exclui
Telinha para exluir um produto que foi contado - CTRL + X
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 12/08/2022
/*/
Static Function Exclui()
    Local aSave     := VTSave()
    Local cEtiqueta := Space(75)

    VTClear()
    @ 0,0 VtSay Padc("**EXCLUI REGISTRO**", VTMaxCol())
    @ 2,0 VtSay "Etiqueta"
    @ 3,0 VtGet cEtiqueta pict "@!" Valid VldExclusao(cEtiqueta)
    VtRead

    VtRestore(,,,,aSave)

Return


/*/{Protheus.doc} VldExclusao
Valida exclusao do registro contado
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 12/08/2022
@param cEtiqueta, character, Conteudo da etiqueta
@return logical, Retorno logico
/*/
Static Function VldExclusao(cEtiqueta)
    Local aAreaAnt := GetArea()
    Local aAreaSZ7 := SZ7->(GetArea())
    Local cTipId   := ""
    Local cLoteCtl := ""
    Local cNumLote := ""

    If Empty(cEtiqueta)
        Return .F.
    EndIf

	cTipId := CBRetTipo(cEtiqueta)
	If (cTipId # "EAN128" .And. !("(91)" $ cEtiqueta)) .Or. (cTipId # "EAN128" .And. !("(92)" $ cEtiqueta))
        VtBeep(2)
		VtAlert( "Etiqueta invalida.", "Aviso", .T., 3000 )
		VTKeyboard(chr(20))
		Return .F.
	EndIf

	If ExistBlock("CBRETEAN")
		//-- Retorno devera ser um array conforme abaixo:
		//-- {codigo do produto,quantidade,lote,data de validade, numero de serie,sub-lote}
		aEtiqueta := ExecBlock("CBRETEAN",,,{cEtiqueta})
	EndIf	

	If Empty(aEtiqueta) .Or. Empty(aEtiqueta[2])
        VtBeep(2)
		VtAlert( "Etiqueta invalida.", "Aviso", .T., 3000 )
		VTKeyboard(chr(20))
		Return .F.
    EndIf

    cLoteCtl := aEtiqueta[03]
    cNumLote := aEtiqueta[06]
    
    DbSelectArea("SZ7")
    SZ7->(DbSetOrder(2))
    If !SZ7->(DbSeek(xFilial("SZ7") + cNumLote + cLoteCtl))
        VtBeep(2)
		VtAlert( "Produto nao localizado.", "Aviso", .T., 3000 )
		VTKeyboard(chr(20))
		Return .F.
    EndIf

	If VtYesNo( "Confirma exclusao?", "ATENCAO")
        //-- Exclui o registro
        RecLock("SZ7", .F.)
            DbDelete()
        SZ7->(MsUnlock())
	EndIf

    RestArea(aAreaSZ7)
    RestArea(aAreaAnt)

Return .T.


/*/{Protheus.doc} SetOff
Funcao que seta a contagem de produtos do Tipo OFF (Segunda linha)- CTRL + O
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 15/08/2022
/*/
Static Function SetOff()

    If lSetOff .And. VtYesNo( "Desabilita contagem OFF?", "ATENCAO" )
        lSetOff := .F.
    ElseIf !lSetOff .And. VtYesNo( "Habilita contagem OFF?", "ATENCAO" )
        lSetOff := .T.
    EndIf

Return


/*/{Protheus.doc} REESTA8D
Funcao para exluir o arquivo "SPOOL.SEM" de semaforo do MSCBSPOOL.
Essa funcao criada porque estava tendo o problema de quando a conexao
com o tcloud caia o arquivo de semaforo do MSCBSPOOL ficava travado e 
todas as impressoes ficavam na fila e nenhuma etiqueta saia mais na impressao.
@type function
@@version 1.0  
@author Erike Yuri - DOTHINK
@since 27/08/2022
/*/
user function REESTA8D()
    local cPath := GetMv("RE_PSEMIMP", .F., "\IMPTER\ZEBRA\RECEBIMENTO\")

    If !ExistDir(cPath)
        FWAlertWarning("O diretório [ " + cPath + " ] nao existe! " + chr(13) + chr(10) + "Verifique o parametro [RE_PSEMIMP], ou procure o administrador do sistema.", "Diretório não existe!")
        Return
    EndIf
    
    cPath += "SPOOL.SEM"
    If File(cPath)
        If FErase(cPath) == -1
            FWAlertError("Ocorreu uma falha ao tentar excluir o arquivo: " + chr(13) + chr(10) + " [ " + cPath + " ]. " + chr(13) + chr(10) + "Garanta que o programa MSCBSPOOL não esteja em execução e tente novamente, ou procure o administrador do sistema.", "Falha ao excluir arquivo!")
            Return
        Else
            FWAlertSuccess("O arquivo [SPOOL.SEM] foi excluido com sucesso!", "Arquivo excluido!")
        EndIf
    Else
        FWAlertWarning("O arquivo [SPOOL.SEM] não foi localizado ou não existe!", "Arquivo não existe!")
    EndIf

    //-- Parametro que indica se os arquivos serao manipulados apos o tratamento do semaforo
    If GetMv("RE_MAPARQI", .F., "S") == "S"
        //-- Faz a manipulacao dos arquivos, copiando, apagando e voltando para imprimir as etiquetas travadas
        U_REESTA8E()
    EndIf

return


/*/{Protheus.doc} REESTA8E
Manipulacao dos arquivos
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 30/08/2022
/*/
User Function REESTA8E()
    Local aFiles  := {}
    Local aSizes  := {}
    Local cDirSrv := GetMv("RE_PSEMIMP", .F., "\IMPTER\ZEBRA\RECEBIMENTO\")
    Local cDirUsr := GetTempPath()
    Local cArq    := ""
    Local cError  := ""
    Local nX

    If !ExistDir(cDirUsr + "mscbspool")
        If MakeDir(cDirUsr + "mscbspool") # 0
            cError += "Falha na criação do diretorio [mscbspool]" + chr(13) + chr(10)
            cError += + chr(13) + chr(10)
        EndIf
    EndIf

    If Empty(cError)
        //-- COPIA DO SERVIDOR PARA A MAQUINA LOCAL E APAGA OS ARQUIVOS
        ADir(cDirSrv + "*.*", aFiles, aSizes)
        
        For nX := 1 to Len(aFiles)
            cArq := aFiles[nX]

            If CpyS2T(cDirSrv + cArq, cDirUsr + "mscbspool")
                If FErase(cDirSrv + cArq) == -1
                    cError += "Falha ao excluir arquivo [" + cArq + "] do S2T." + chr(13) + chr(10)
                EndIf
            EndIf
        Next nX

        If Empty(cError) .And. !Empty(Len(aFiles))
            aFiles := {}
            aSizes := {}
            cArq   := ""

            //-- COPIA DA MAQUINA LOCAL PARA O SERVIDOR
            ADir(cDirUsr + "mscbspool\" + "*.*", aFiles, aSizes)

            For nX := 1 to Len(aFiles)
                cArq := aFiles[nX]

                If CpyT2S(cDirUsr + "mscbspool\" + cArq, cDirSrv, .F.)
                    If FErase(cDirUsr + "mscbspool\" + cArq) == -1
                        cError += "Falha ao excluir arquivo [" + cArq + "] do T2S." + chr(13) + chr(10)
                    EndIf
                EndIf
            Next nX
        EndIf
    EndIf

    If !Empty(cError)
        MemoWrite(cDirUsr + "mscbspool", cError)
    EndIf

Return


/*/{Protheus.doc} REESTA8F
Rotina para cadastro da Traducao de Codigos
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 25/10/2022
/*/
User Function REESTA8F()
    Local aAreaAnt := GetArea()
    Local aArrSay  := {}
    Local aArrBut  := {}
    Local aRotAdic := {}
    Local cAlias   := "SZ5"
    Local cTitle   := "Tradução de Códigos - De/Para"
    Local cDel     := ".T."
    Local cOk      := ".T."
    Local bPre     := {|| .T.}
    Local lExeFun  := .F.

    aAdd(aArrSay, "Esta rotina tem o objetivo de cadastrar a Tradução de Códigos")
    aAdd(aArrSay, "da MM da Amazônia/Innova, para os códigos da Replas.")
    aAdd(aArrSay, "Esse cadastro servirá como um [De/Para] dos produtos, sendo")
    aAdd(aArrSay, "usados principalmente no inventario customizada da Replas.")

    aAdd(aArrBut, {1, .T., {|| lExeFun := .T., FechaBatch()}})
    aAdd(aArrBut, {2, .T., {|| lExeFun := .F., FechaBatch()}})

    FormBatch("Tradução de Códigos", aArrSay, aArrBut)

    If lExeFun
        DbSelectArea("SZ5")
        SZ5->( DbSetOrder(1) )

        AxCadastro( cAlias, cTitle, cDel, cOk, aRotAdic, bPre )
    EndIf

    RestArea(aAreaAnt)

Return


/*/{Protheus.doc} REESTA8G
Rotina de preenhimento dos grupos de produtos na tabela do inventario temporario
@type function
@version 1.0 
@author DOTHINK SISTEMAS - DENER LEMOS
@since 19/01/2023
/*/
User Function REESTA8G()
    Local aAreaAnt := GetArea()
    Local aAreaSB1 := SB1->(GetArea())
    Local aAreaSZ7 := SZ7->(GetArea())

    DbSelectArea("SB1")
    SB1->(DbSetOrder(1))

    DbSelectArea("SZ7")
    SZ7->(DbSetOrder(1))

    SZ7->(DbGoTo(40))

    While SZ7->(!Eof())
        If SB1->(DbSeek(xFilial("SB1") + PadR(SZ7->Z7_COD, Len(SB1->B1_COD)))) .And. SB1->B1_GRUPO # SZ7->Z7_GRUPO
            RecLock("SZ7", .F.)
                SZ7->Z7_GRUPO := SB1->B1_GRUPO
            SZ7->(MsUnlock())
        EndIf

        SZ7->(DbSkip())
    EndDo

    RestArea(aAreaSZ7)
    RestArea(aAreaSB1)
    RestArea(aAreaAnt)

Return
