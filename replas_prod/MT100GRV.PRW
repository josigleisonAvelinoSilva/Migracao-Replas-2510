#INCLUDE "PROTHEUS.CH"


/*/{Protheus.doc} MT100GRV
Ponto de entrada anterior a gravacao do Documento de Entrada
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 28/05/2022
/*/
User Function MT100GRV()
    Local aXREESTA05 := {}
    Local nPosCod     := 0
	Local nPosLotCTL  := 0
    Local nPosLote    := 0
	Local nPosDtVld	  := 0
    Local nI          := 0
    Local lDeleta     := ParamIXB[01]
    Local lMntLote    := GetMV( "RE_MTNLOTE", .F., .T. )

    If !lDeleta .And. lMntLote .And. IsInCallStack("U_REESTA02")
        nPosCod    := aScan( aHeader, { |x| Alltrim(x[02]) == "D1_COD" } )
        nPosLotCTL := aScan( aHeader, { |x| Alltrim(x[02]) == "D1_LOTECTL" } )
        nPosLote   := aScan( aHeader, { |x| AllTrim(x[02]) == "D1_NUMLOTE" } )
        nPosDtVld  := aScan( aHeader, { |x| Alltrim(x[02]) == "D1_DTVALID" } )

        aXREESTA05 := U_GREESTA05()

        /*Varre o array "aCols" para preencher os Lotes/Sub-lotes e manter o conteudo original,
        de acordo com array "aXREESTA05", salvo na rotina REESTA05 para termos
        referencia dos lotes transferidos entre as filiais da Replas.*/
        For nI := 1 To Len(aCols)
            If Rastro( aCols[nI, nPosCod] )
                aCols[nI, nPosLotCTL] := aXREESTA05[nI, 09, 02]
                aCols[nI, nPosDtVld]  := aXREESTA05[nI, 11, 02]
                If Rastro( aCols[nI, nPosCod], "S" )  
                    aCols[nI, nPosLote] := aXREESTA05[nI, 10, 02]
                EndIf
            EndIf
        Next nI
    EndIf

Return
