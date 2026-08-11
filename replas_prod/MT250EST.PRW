#INCLUDE "PROTHEUS.CH"


/*/{Protheus.doc} mt250est
Valida condicao especifica antes de realizar o Estorno
@type function
@version 1.0
@author Marcos P.Aversa
@since 30/01/2023
@return logical, Retorno logico
/*/
User Function mt250est()
    Local lRet      := .T.
    Local aArea     := GetArea()
    Local aAreaSZ9  := SZ9->( GetArea() )
    Local aAreaSB8  := SB8->( GetArea() )
    Local lAtivaSZ9 := GetMv("RE_ATIVSZ9",,.T.)  //Ativa Verif. da Tabela SZ9 -Auxiliar de MPs
    Local cFilOrig := GetMV( "RE_FILORIG", .F., "0302" )
    Local cFilDest := GetMV( "RE_FILDEST", .F., "0201" )
    
    If lAtivaSZ9 .AND. xFilial( "SZ9") == cFilDest
        SZ9->( dbSetOrder( 1 ))  // --Z9_FILIAL + Z9_OP
        SB8->( dbSetOrder( 3 ))  // --B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL+B8_NUMLOTE+DTOS(B8_DTVALID)
        If SZ9->( dbSeek( xFilial( "SZ9") + SD3->D3_OP )) .AND. ;
            SB8->( dbSeek( cFilOrig + SZ9->Z9_PRODDES + SZ9->Z9_LOCDES + SZ9->Z9_LOTDES + SZ9->Z9_SBLTDES ) ) .AND. ;
            SB8->B8_SALDO <> 0
            MsgInfo("Produto : "+Alltrim(SZ9->Z9_PRODDES) + " - Local : " + SZ9->Z9_LOCDES + " - Lote : " + SZ9->Z9_LOTDES + " - Sub-Lote : " +SZ9->Z9_SBLTDES + " já foi Incluído na Filial : " + cFilDes + ".Favor Verificar !!!"   , "MP - Destino")            
            lRet := .F.
        Endif
    Endif
    RestArea( aAreaSB8)
    RestArea( aAreaSZ9 ) 
    RestArea( aArea )

Return lRet
