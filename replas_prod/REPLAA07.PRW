#INCLUDE "RWMAKE2.CH"
#include "tbiconn.ch"
#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"             


/*/{Protheus.doc} REPLAA07
Produto Automatico 
@type function
@version 1.0 
@author DO THINK - FERNANDO MUTA
@since 19/01/2025
/*/
User Function REPLAA07()
Local lRet

Private _cFamilia := Space(TamSX3("ZE_FAMILIA")[1])
Private _cCodPrd1 := Space(TamSX3("B1_COD")[1])
Private _nDiamInt := 0
Private _nDiamExt := 0
Private _nLargura := 0
Private oGetFamilia
Private oGetDExt
Private oGetDInt
Private oGetLargura
Private oGetNovoProd
Private oBmpCopy
Private OdlProd
Private OFONT12N  := TFont():New( "Arial",14,20,,.T.,,,,,.F. )

@ 000,000 to 300,330 dialog OdlProd title OemToAnsi("Produto Inteligente - Filme")

@ 005,010 say OemToAnsi("Familia") size 90,15 pixel FONT OFONT12N
@ 005,100 get _cFamilia Object  oGetFamilia Picture "@!"  
oGetFamilia:oFont   := OFONT12N
oGetFamilia:nWidth  := 110
oGetFamilia:nHeight := 25
oGetFamilia:bValid  := {|| VldFamilia()}
oGetFamilia:cF3     := "SZE"

@ 025,010 say OemToAnsi("Ø Interno (in)") size 90,15 pixel FONT OFONT12N
@ 025,100 get _nDiamInt Object  oGetDInt Picture "@E 9"  
oGetDInt:oFont   := OFONT12N
oGetDInt:nWidth  := 110
oGetDInt:nHeight := 25
oGetDInt:bValid  := {|| VldDiaInt()}

@ 045,010 say OemToAnsi("Ø Externo (mm)") size 90,15 pixel FONT OFONT12N
@ 045,100 get _nDiamExt Object  oGetDExt Picture "@E 999"  
oGetDExt:oFont   := OFONT12N
oGetDExt:nWidth  := 110
oGetDExt:nHeight := 25
oGetDExt:bValid  := {|| VldDiaExt() }

@ 065,010 say OemToAnsi("Largura (mm)") size 90,15 pixel FONT OFONT12N
@ 065,100 get _nLargura Object  oGetLargura Picture "@E 9,999"  
oGetLargura:oFont   := OFONT12N
oGetLargura:nWidth  := 110
oGetLargura:nHeight := 25
oGetLargura:bValid  := {|| VldLargura()}

@ 090,010 say OemToAnsi("Código") size 90,15 pixel FONT OFONT12N
@ 090,060 get _cCodPrd1 Object  oGetNovoProd Picture "@E!" When .F.  
oGetNovoProd:oFont   := OFONT12N
oGetNovoProd:nWidth  := 190
oGetNovoProd:nHeight := 25

@ 120,030 BUTTON "Confirma"   SIZE 50,12 ACTION lRet := OkProc() OF OdlProd PIXEL
@ 120,090 BUTTON "Cancela "   SIZE 50,12 ACTION Close(OdlProd) PIXEL

activate dialog OdlProd centered

If lRet
    FWAlertSuccess("Sucesso ao cadastrar [PA, MP, SV e Estrutura] do código <strong>" + AllTrim(_cCodPrd1) + "</strong>.", "Sucesso Cadastro!")
EndIf

Return _cCodPrd1


/*/{Protheus.doc} VldFamilia
Validacao da Familia
@type function
@version 1.0 
@author DO THINK - FERNANDO MUTA
@since 23/01/2025
/*/
Static Function VldFamilia()
local aArea := GetArea()
local lRet  := .F.

_cFamilia := AllTrim(_cFamilia)

SZE->(DbSetOrder(1))
lRet := SZE->(DbSeek(xFilial()+PadR(_cFamilia, Len(SZE->ZE_FAMILIA))))
If !lRet .AND. !Empty(_cFamilia)
    Aviso("Familia!", "Familia " + _cFamilia + " não existe.", {"Ok"})
EndIf
If Empty(_cFamilia)
    lRet := .T.
EndIf    
AtuBrowse()
RestArea(aArea)
Return lRet

/*/{Protheus.doc} VldDiaInt
Validacao do Diametro Interno
@type function
@version 1.0 
@author DO THINK - FERNANDO MUTA
@since 23/01/2025
/*/
Static Function VldDiaInt()
local aArea := GetArea()
local lRet  := .F.
lRet := _nDiamInt == 3 .OR. _nDiamInt == 6 .OR. _nDiamInt == 0
If !lRet
    Aviso("Diâmetro Interno!", "Diâmetro interno deve ser 3 in ou 6 in.", {"Ok"})
EndIf
AtuBrowse()
RestArea(aArea)
Return lRet

/*/{Protheus.doc} VldDiaExt
Validacao do Diametro Externo
@type function
@version 1.0 
@author DO THINK - FERNANDO MUTA
@since 23/01/2025
/*/
Static Function VldDiaExt()
local aArea := GetArea()
local lRet  := .F.
SZE->(DbSetOrder(1))
If !SZE->(DbSeek(xFilial()+PadR(_cFamilia, Len(SZE->ZE_FAMILIA))))
    Aviso("Erro", "Familia!" + _cFamilia + " nao cadastrada", {"Ok"})
EndIf

lRet := _nDiamExt >= SZE->ZE_DEXTMIN .AND. _nDiamExt <= SZE->ZE_DEXTMAX
If _nDiamExt == 0
    lRet := .T.
EndIf    
If !lRet 
    Aviso("Diâmetro Externo!", "Diâmetro externo deve estar entre " + AllTrim(transform(SZE->ZE_DEXTMIN,"@E 99,999")) + " mm e " + AllTrim(transform(SZE->ZE_DEXTMAX,"@E 99,999")) + " mm.", {"Ok"})
EndIf
AtuBrowse()
RestArea(aArea)
Return lRet


/*/{Protheus.doc} VldLargura
Validacao do Diametro Externo
@type function
@version 1.0 
@author DO THINK - FERNANDO MUTA
@since 23/01/2025
/*/
Static Function VldLargura()
local aArea := GetArea()
local lRet  := .F.
SZE->(DbSetOrder(1))
If !SZE->(DbSeek(xFilial()+PadR(_cFamilia, Len(SZE->ZE_FAMILIA))))
    Aviso("Erro", "Familia!" + AllTrim(_cFamilia) + " nao cadastrada.", {"Ok"})
EndIf

lRet := _nLargura >= SZE->ZE_LARGMIN .AND. _nLargura <= SZE->ZE_LARGMAX 
If _nLargura == 0
    lRet := .T.
EndIf 
If !lRet
    Aviso("Largura!", "Largura deve estar entre " + AllTrim(transform(SZE->ZE_LARGMIN,"@E 99,999")) + " mm e " + AllTrim(transform(SZE->ZE_LARGMAX,"@E 99,999")) + " mm.", {"Ok"})
EndIf
AtuBrowse()
RestArea(aArea)
Return lRet


/*/{Protheus.doc} AtuBrowse
Retorna Codigo do Produto
@type function
@version 1.0 
@author DO THINK - FERNANDO MUTA
@since 23/01/2025
/*/
Static Function AtuBrowse()
If !Empty(_cFamilia) .AND. _nDiamInt <> 0 .AND. _nDiamExt <> 0 .AND. _nLargura <> 0
    _cCodPrd1 := _cFamilia + strzero(_nDiamInt,2) + strzero(_nDiamExt,3) + strzero(_nLargura,4)
Else
    _cCodPrd1 := Space(TamSX3("B1_COD")[1])
EndIf    
oGetNovoProd:CTEXT := _cCodPrd1
oGetNovoProd:Refresh()
OdlProd:Refresh()
Return


//--
Static Function OkProc()
    Local lGrava

    If Empty(_cFamilia)
        Aviso("Familia!", "Familia nao informada", {"Ok"})
        Return
    ElseIf Empty(_nDiamInt)
        Aviso("Diâmetro Interno!", "Diâmetro interno nao informado", {"Ok"})
        Return
    ElseIf Empty(_nDiamExt)
        Aviso("Diâmetro Externo!", "Diâmetro externo nao informado", {"Ok"})
        Return
    ElseIf Empty(_nLargura)
        Aviso("Largura!", "Largura nao informada", {"Ok"})
        Return
    EndIf

    Processa( { || lGrava := GravaProd() }, 'Cadastrando...' )

Return lGrava


/*/{Protheus.doc} GravaProd
Tratamento para gravação do produto
@type function
@version 1.0 
@author DO THINK - FERNANDO MUTA
@since 23/01/2025
/*/
Static Function GravaProd()
local aArea      := GetArea()
local aProduto   := {}
local cNewProd   := ""
local cCodBase   := ""
local i          := 0
local aTpPrd     := {}   /* aTpPrd[1]=Prefixo do Codigo   aTpPrd[2]=Tipo do Produto  */
local aItensStru := {}
local aCabSG1    := {}
local aGetsSG1   := {}
local aItemSG1   := {}

_cCodPrd1 := PADR(_cCodPrd1,TamSx3("B1_COD")[1])

aadd(aTpPrd,{""   ,"PA"})
aadd(aTpPrd,{"MP" ,"MP"})
aadd(aTpPrd,{"SV-","II"})
procregua(4)
// **********************  Análise do cadastro de produto para inclusão do pedido de vendas *******************************
SB1->(DbSetOrder(1))
for i:=1 to len(aTpPrd)
    cNewProd := PADR(aTpPrd[i][1]+_cCodPrd1,TamSx3("B1_COD")[1])
    If aTpPrd[i][2] <> "PA"
        AADD(aItensStru,{cNewProd})
    EndIf

    IncProc("Produto: " + AllTrim(cNewProd))

    SB1->(DbSetOrder(1))
    If !SB1->(DbSeek(xFilial()+cNewProd)) // Caso não encontre o código de produto formado, inclui um novo
        If SB1->(DbSeek(xFilial()+_cFamilia)) // Grava mesmas informações do produto já existente da mesma familia
            cCodBase := SB1->B1_COD
            aProduto := {}
            aAdd( aProduto, { "B1_COD"    , cNewProd       , Nil } )
            aAdd( aProduto, { "B1_DESC"   , SB1->B1_DESC   , Nil } )
            aAdd( aProduto, { "B1_TIPO"   , aTpPrd[i][2]   , Nil } )
            aAdd( aProduto, { "B1_UM"     , SB1->B1_UM     , Nil } )
            aAdd( aProduto, { "B1_LOCPAD" , SB1->B1_LOCPAD , Nil } )
            aAdd( aProduto, { "B1_CUSTD"  , SB1->B1_CUSTD  , Nil } )
            aAdd( aProduto, { "B1_GRUPO"  , SB1->B1_GRUPO  , Nil } )
            aAdd( aProduto, { "B1_TE"     , SB1->B1_TE     , Nil } )
            aAdd( aProduto, { "B1_TS"     , SB1->B1_TS     , Nil } )
            aAdd( aProduto, { "B1_ORIGEM" , SB1->B1_ORIGEM , Nil } )
            aAdd( aProduto, { "B1_CONV"	  , SB1->B1_CONV   , Nil } )
            aAdd( aProduto, { "B1_TIPCONV", SB1->B1_TIPCONV, Nil } )
            aAdd( aProduto, { "B1_PESO"	  , SB1->B1_PESO   , Nil } )
            aAdd( aProduto, { "B1_PESBRU" , SB1->B1_PESBRU , Nil } )
            aAdd( aProduto, { "B1_POSIPI" , SB1->B1_POSIPI , Nil } )
            aAdd( aProduto, { "B1_IPI"	  , SB1->B1_IPI    , Nil } )
            aAdd( aProduto, { "B1_XGRUPO" , "1"            , Nil } ) //-- Filme
            aAdd( aProduto, { "B1_PROC"   , SB1->B1_PROC   , Nil } )
            If aTpPrd[i][1] == "MP"
                aAdd( aProduto, { "B1_RASTRO" , "S"            , Nil } )
            Else
                aAdd( aProduto, { "B1_RASTRO" , "N"            , Nil } )
            EndIf
            aAdd( aProduto, { "B1_LOCALIZ", SB1->B1_LOCALIZ, Nil } )
            aAdd( aProduto, { "B1_GARANT" , SB1->B1_GARANT , Nil } )
            aAdd( aProduto, { "B1_PRVALID", SB1->B1_PRVALID, Nil } )
            //-- Executa a gravacao do novo produto
            lMsErroAuto := .F.
            MSExecAuto( { |x, y| Mata010(x, y) }, aProduto, 3 )     
            If lMsErroAuto
                MostraErro()
                return .F.
            Else
                conout("Produto cadastrado:" + cNewProd + " base: " + cCodBase)    
            EndIf    
        EndIf    
    EndIf
next

// **********************  Análise do cadastro de estrutura de produto para inclusão do pedido de vendas *******************************
SG1->(DbSetOrder(1))
If SG1->(DbSeek(xFilial()+_cCodPrd1))
    Aviso("Estrutura", "Estrutura do produto "+ AllTrim(_cCodPrd1) + " já cadastrada", {"Ok"})
    Return .F.
EndIf

// Coleta o codigo do produto base
SZE->(DbSetOrder(1))
If !SZE->(DbSeek(xFilial()+PadR(_cFamilia, Len(SZE->ZE_FAMILIA))))
    Aviso("Validacao da Familia", "Familia "+ _cFamilia + " não cadastrada", {"Ok"})
    return .F.
EndIf

If Alltrim(SZE->ZE_TIPOFIL) == "BOPP"
    AADD(aItensStru,{padr("BASE-ESTR-BOPP",TamSx3("B1_COD")[1])})
ElseIf Alltrim(SZE->ZE_TIPOFIL) $ "PP/PE"
    AADD(aItensStru,{padr("BASE-ESTR-PP/PE",TamSx3("B1_COD")[1])})
Else
    Aviso("Tipo de Familia", "Tipo de familia "+SZE->ZE_TIPOFIL+" invalido para familia "+ _cFamilia +".", {"Ok"})
    return .F.
EndIf

// Adicionar Tubete na estrutura
AADD(aItensStru,{padr("TUBETE"+strzero(_nDiamInt,2)+"P",TamSx3("B1_COD")[1])})
aAdd(aCabSG1, {"G1_COD"   , _cCodPrd1, Nil}) //-- Codigo do produto PA/PI
aAdd(aCabSG1, {"G1_QUANT" , 1        , Nil}) //-- Quantidade base do produto PA/PI, sempre 100, isso significa 100% no processo da MM da Amazonia
aAdd(aCabSG1, {"NIVALT"   , "S"      , Nil}) //-- A variavel NIVALT e utilizada para recalcular ou nao os niveis da estrutura
For i := 1 To len(aItensStru)
    If u_xIsTub(aItensStru[i][1])
        nQtdStru := u_xGetDimen(_cCodPrd1,"N")[3]+5 // 5mm é a largura adicional padrão
        aAdd(aGetsSG1, {"G1_FIXVAR" , "F" , Nil})
    Else     
        nQtdStru := 1
    EndIf        
    //-- Carrega componentes para a SG1
    aAdd(aGetsSG1, {"G1_COD"   , _cCodPrd1    , Nil})
    aAdd(aGetsSG1, {"G1_COMP"  , aItensStru[i][1] , Nil})
    aAdd(aGetsSG1, {"G1_QUANT" , nQtdStru , Nil})
    //-- Carreda item/componente
    aAdd(aItemSG1, aGetsSG1)
    //-- Reinicializa variais
    aGetsSG1 := {}
Next
lMsErroAuto := .F.

IncProc("Estrutura: " + AllTrim(_cCodPrd1))

MSExecAuto({|x, y, z| PCPA200(x, y, z)}, aCabSG1, aItemSG1, 3)

If lMsErroAuto
    MostraErro()
    return .F.
EndIf    
Close(OdlProd)
RestArea(aArea)
return .T.
