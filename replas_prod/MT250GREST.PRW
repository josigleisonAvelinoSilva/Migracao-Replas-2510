#INCLUDE "PROTHEUS.CH"


/*/{Protheus.doc} mt250grest
Permite realizar gravacoes e/ou exclusoes em tabelas e/ou campos especificos do usuario apos realizar o Estorno
No Estorno, Verificar também se já não foi dado Entrada do Produto/Lote/Sub-Lote no Destino
Caso verdadeiro, impossibilitar o Estorno antes de efetuar o Cancelamento da Entrada
@type function
@version 1.0 
@author Marcos P.Aversa
@since 30/01/2023
/*/
User Function mt250grest()
    Local aArea     := GetArea()
    Local aAreaSZ9  := SZ9->( GetArea() )
    Local aAreaSB8  := SB8->( GetArea() )
    Local lAtivaSZ9 := GetMv("RE_ATIVSZ9",,.T.)  //Ativa Verif. da Tabela SZ9 -Auxiliar de MPs
    Local cFilDest := GetMV( "RE_FILDEST", .F., "0201" )

    SZ9->( dbSetOrder( 1 ))  // --Z9_FILIAL + Z9_OP
    SB8->( dbSetOrder( 3 ))  // --B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL+B8_NUMLOTE+DTOS(B8_DTVALID)

    If lAtivaSZ9 .AND. xFilial( "SZ9") == cFilDest   .AND.  Empty(SC2->C2_DATRF)
        If SZ9->( dbSeek( xFilial( "SZ9") + SD3->D3_OP ))
            While SZ9->( !Eof() ) .AND. ;
                SZ9->Z9_FILIAL + SZ9->Z9_OP == xFilial( "SZ9") + SD3->D3_OP
                SZ9->( RecLock( "SZ9",.F. ))
                SZ9->( dbDelete() )
                SZ9->( MsUnLock() )
                SZ9->( dbSkip() )
            Enddo
        Endif
        //--Verifica se Existe Registro Correspondente no Controle Motor SZ8
        //--Caso Positivo Exclui 
        nRecSD3 := SD3->( Recno())
        fDelSZ8( nRecSD3 )
                
    Endif

    RestArea( aAreaSB8)
    RestArea( aAreaSZ9 ) 
    RestArea( aArea )
    
Return


Static Function fDelSZ8( nRecSD3 )
    local aArea    := GetArea()
    local aAreaSZ8 := SZ8->( GetArea() )
    local aAreaSZA := SZA->( GetArea() )
    local cQuery   := ""

    SZ8->( dbSetOrder(1))
    SZA->( dbSetOrder(1))    

    cQuery := " SELECT Z8_FILIAL,Z8_COD " + CRLF
    cQuery += " FROM " + RetSqlName("SZ8") + " Z8 " + CRLF
    cQuery += " WHERE Z8.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += " AND Z8_SD3REC =  " + AllTrim(Str(nRecSD3)) + " " + CRLF

    DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "XSZ8", .F., .T. )

    If XSZ8->( !Eof())
       If SZ8->( dbSeek( XSZ8->Z8_FILIAL + XSZ8->Z8_COD ) )
          SZ8->( RecLock("SZ8", .F. ))
          SZ8->( dbDelete() )
          SZ8->( MsUnLock() )
          If SZA->( dbSeek( XSZ8->Z8_FILIAL + XSZ8->Z8_COD ) )
             While SZA->( !Eof() ) .AND.;
                SZA->ZA_FILIAL + SZA->ZA_COD == XSZ8->Z8_FILIAL + XSZ8->Z8_COD
                SZA->( RecLock("SZA", .F. ))
                SZA->( dbDelete() )
                SZA->( MsUnLock() )             
                SZA->( dbSkip())
             Enddo   
          Endif
       Endif
    Endif 

    XSZ8->( dbCloseArea() )

    RestArea( aAreaSZA )
    RestArea( aAreaSZ8 )
    RestArea( aArea )
Return
