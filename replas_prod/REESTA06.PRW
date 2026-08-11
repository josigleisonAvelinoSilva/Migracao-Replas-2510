#INCLUDE "PROTHEUS.CH"


/*/{Protheus.doc} REESTA06
Rotina para inclusao de entrutura na filial da Industria MM SP
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 27/06/2022
@obs Projeto Novo PCP
/*/
User Function REESTA06()
    Local aAreaAnt   := GetArea()
    Local aAreaSG1   := SG1->( GetArea() )
    Local aCab       := {}
    Local aItens     := {}
    Local aGets      := {}
    //Local cFilOrig   := GetMV( "RE_FILORIG", .F., "0302" )
    Local cFilDest   := GetMV( "RE_FILDEST", .F., "0201" )
    Local cCodServ   := GetMV( "RP_CODSERV", .F., "" )
    Local cNewProd   := "SV-" + AllTrim( cProduto )
    Local cBkpFilAnt := cFilAnt
    Local lExistSG1  := .F.
    Local cFileLog   := ""
    Local cMsg       := ""

    Private lMsErroAuto := .F.

    DbSelectArea("SG1")
    SG1->( DbSetOrder(1) )

    //-- Realiza o cadastro do produto de servico se o mesmo nao existir
    If U_REPCPA02( cCodServ, cNewProd ) .And. SG1->( DbSeek( xFilial("SG1") + cProduto ) )
        cNewProd := Padr( cNewProd, TamSX3("G1_COD")[1] )

        //-- Prepara Cabecalho 
        aAdd( aCab, { "G1_COD"  , cNewProd, Nil } )
        aAdd( aCab, { "G1_QUANT", 1       , Nil } )
        aAdd( aCab, { "NIVALT"  , "S"     , Nil } ) //-- A variavel NIVALT eh utilizada pra recalcular ou nao a estrutura

        //-- Prepara Itens 
        While SG1->( !Eof() ) .And. SG1->( G1_FILIAL + G1_COD ) == xFilial("SG1") + cProduto
            If AllTrim( SG1->G1_COMP ) # AllTrim( cNewProd ) .And.;
               AllTrim( SG1->G1_COMP ) # AllTrim( cCodServ ) .And.;
               !( "SV-" $ AllTrim( SG1->G1_COMP ) )

                aGets := {}
                aAdd( aGets, { "G1_COD"   , cNewProd      , Nil } )
                aAdd( aGets, { "G1_COMP"  , SG1->G1_COMP  , Nil } ) 
                aAdd( aGets, { "G1_TRT"   , SG1->G1_TRT   , Nil } ) 
                aAdd( aGets, { "G1_QUANT" , SG1->G1_QUANT , Nil } ) 
                aAdd( aGets, { "G1_PERDA" , SG1->G1_PERDA , Nil } ) 
                aAdd( aGets, { "G1_INI"   , SG1->G1_INI   , Nil } ) 
                aAdd( aGets, { "G1_FIM"   , SG1->G1_FIM   , Nil } ) 
                aAdd( aGets, { "G1_FIXVAR", SG1->G1_FIXVAR, Nil } ) 

                aAdd( aItens, aGets ) 
            EndIf

            SG1->( DbSkip() )
        EndDo

        //-- Altera "cFilAnt" para a filial destino
        cFilAnt   := cFilDest
        lExistSG1 := SG1->( DbSeek( xFilial("SG1") + cNewProd ) )

        MSExecAuto( { |x, y, z| PCPA200(x, y, z) }, aCab, aItens, Iif( lExistSG1, 4, 3 ) ) 

        If lMsErroAuto
            ConOut( "##### Inicio erro rotina U_REESTA06 #####" )
            cFileLog := NomeAutoLog()
            cMsg     := MemoRead( cFileLog )
            If !Empty( cMsg )
                ConOut( cMsg )
            Endif
            ConOut( "##### Fim erro rotina U_REESTA06 #####" )
        EndIf 

        //-- Altera "cFilAnt" para a filial origem
        cFilAnt := cBkpFilAnt
    EndIf
    
    RestArea( aAreaSG1 )
    RestArea( aAreaAnt )

Return
