#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"


/*/{Protheus.doc} REPCPA02
Rotina para cadastro de produtos
@type function
@version 1.0 
@author Dener Lemos - DOTHINK
@since 10/01/2022
@param cOldProd, character, Codigo da MP empenhada
@param cNewProd, character, Cosigo da nova MP
@return logical, Retorno logico
@obs Projeto Novo PCP (Retorno para Estoque e Sucata)
/*/
User Function REPCPA02(cOldProd, cNewProd)
	Local aArea     := GetArea()
	Local aAreaSB1  := SB1->(GetArea())
    Local aProduto	:= {}
    Local cCodigo   := ""
    Local nCustStd  := GetMv("RE_CUSTD", .F., 1)
    Local lREPCPA02 := .T.
    Local lSB1      := .T.

    Private lMsErroAuto := .F.

    DbSelectArea("SB1")
    SB1->( DbSetOrder(1) )
    lSB1 := SB1->( DbSeek( xFilial("SB1") + Padr( cNewProd, TamSX3("B1_COD")[1] ) ) )

    If lSB1 .And. U_REFATA02( 1, SB1->B1_COD ) .And. U_REFATA02( 4, SB1->B1_COD ) .And. SB1->B1_RASTRO # "S"
        cCodigo := Padr( cNewProd, TamSX3("B1_COD")[1] )

        aAdd( aProduto, { "B1_COD"   , cCodigo, Nil } )
        aAdd( aProduto, { "B1_RASTRO", "S"    , Nil } )

        //-- Executa a gravacao do novo produto
        MSExecAuto( { |x, y| Mata010(x, y) }, aProduto, 4 ) 
        
        If lMsErroAuto
            //MostraErro()
            lREPCPA02 := .F.
        Endif
    ElseIf !lSB1 .And. SB1->( DbSeek( xFilial("SB1") + Padr( cOldProd, TamSX3("B1_COD")[1] ) ) )
        //-- Posiciona no produto que ja existe para pegar a informacoes e fazer uma copia

        //-- Codigo Cadastro novo
        cCodigo := Padr( cNewProd, TamSX3("B1_COD")[1] )
        
        If !Empty(SB1->B1_CUSTD)
            nCustStd := SB1->B1_CUSTD
        ElseIf !Empty(SB1->B1_UPRC)
            nCustStd := SB1->B1_UPRC
        EndIf

        //-- Carrega os dados
        aAdd( aProduto, { "B1_COD"    , cCodigo        , Nil } )
        aAdd( aProduto, { "B1_DESC"   , SB1->B1_DESC   , Nil } )
        aAdd( aProduto, { "B1_TIPO"   , SB1->B1_TIPO   , Nil } )
        aAdd( aProduto, { "B1_UM"     , SB1->B1_UM     , Nil } )
        aAdd( aProduto, { "B1_LOCPAD" , SB1->B1_LOCPAD , Nil } )
        aAdd( aProduto, { "B1_CUSTD"  , nCustStd       , Nil } )
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
        aAdd( aProduto, { "B1_XGRUPO" , SB1->B1_XGRUPO , Nil } ) //-- 0=Outros;1=Filme;2=Resina Nacional;3=Resina Importada
        aAdd( aProduto, { "B1_PROC"   , SB1->B1_PROC   , Nil } )
        aAdd( aProduto, { "B1_RASTRO" , SB1->B1_RASTRO , Nil } )
        aAdd( aProduto, { "B1_LOCALIZ", SB1->B1_LOCALIZ, Nil } )
        aAdd( aProduto, { "B1_GARANT" , SB1->B1_GARANT , Nil } )
        aAdd( aProduto, { "B1_PRVALID", SB1->B1_PRVALID, Nil } )
        
        //-- Executa a gravacao do novo produto
        MSExecAuto( { |x, y| Mata010(x, y) }, aProduto, 3 ) 
        
        If lMsErroAuto
            //MostraErro()
            lREPCPA02 := .F.
        Endif
    EndIf

	RestArea(aAreaSB1)
	RestArea(aArea)
    
Return lREPCPA02

