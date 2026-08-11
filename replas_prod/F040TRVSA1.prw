/*/{Protheus.doc} F040TRVSA1
//Permitir gravar os dados de indicadores do cliente no ato da geração da NF. 
@author Robson Gonçalves - Rleg.
@since 09/03/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function F040TRVSA1()
    Local cMV_TRVSA1 := 'MV_TRVSA1'
    Local lAtualiza := .T.

    If GetMv( cMV_TRVSA1, .T. )
        cMV_TRVSA1 := GetMv( cMV_TRVSA1, .F. )
        If .NOT. Empty( cMV_TRVSA1 )
            If ( SE1->E1_CLIENTE + SE1->E1_LOJA ) $ ( cMV_TRVSA1 )
                lAtualiza := .F.
            Endif
        Endif
    Endif
Return( lAtualiza )
