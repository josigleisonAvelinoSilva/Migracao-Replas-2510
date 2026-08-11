#INCLUDE "PROTHEUS.CH"


/*/{Protheus.doc} REPCPA08
Funcao que altera os empenhos antes da abertura da OP
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 29/04/2022
@obs Projeto Novo PCP (Sugestao de Bobinas)
/*/
User Function REPCPA08()
    Private lREFATA06 := IsInCallStack("U_REFATA06")

    If !lREFATA06
        //-- Processa somente OPs amarradas a pedidos
        If Empty( SC2->(C2_PEDIDO + C2_ITEMPV) )
            Return
        EndIf
    EndIf

    //-- Deleta os empenhos das materias primas atuais, vindas da estrutura
    DelEmp()

    //-- Inclui os empenhos das materias primas sugeridas
    IncEmp()

Return


/*/{Protheus.doc} DelEmp
Deleta o empenho da Materia prima existente
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 29/04/2022
/*/
Static Function DelEmp()
    Local cCodCli  := ""
    Local cRaizCod := ""
    Local nI       := 0

    If !lREFATA06
        cCodCli := SC2->C2_PRODUTO
        
        If At("SV-", cCodCli) > 0
            cCodCli := SubStr( cCodCli, 4 )
        EndIf

        cRaizCod := "MP" + SubStr( cCodCli, 01, (Len( AllTrim(cCodCli) ) - 9) )

        For nI := 1 To Len(aCols)
            If cRaizCod $ aCols[nI, nPosCod]
                aCols[nI, Len(aCols[nI])] := .T. 
            EndIf
        Next nI
    Else
        For nI := 1 To Len(aCols)
            aCols[nI, Len(aCols[nI])] := .T. 
        Next nI
    EndIf

Return


/*/{Protheus.doc} IncEmp
Inclui as novas materias primas
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 29/04/2022
/*/
Static Function IncEmp()
    Local aArea     := GetArea()
    Local cIdUltSgt := GetMV("RE_IDSGT") //-- Pega o Id da ultima sugestao
    Local cPedItem  := SC2->(C2_PEDIDO + C2_ITEMPV)
    Local cQuery    := ""
    Local cEoL      := chr(13) + chr(10)
    Local nXTRT     := 100
    Local nI        := 0

    DbSelectArea("SB1")
    SB1->( DbSetorder(1) )

    If !lREFATA06
        //-- Query que retorna as MPs sugeridas e gravadas no historico
        cQuery := " SELECT " + cEoL
        cQuery += "     SZ4.* " + cEoL
        cQuery += " FROM " + cEoL
        cQuery += "     " + RetSQLName("SZ4") + " SZ4 " + cEoL
        cQuery += " WHERE " + cEoL
        cQuery += "     SZ4.Z4_FILIAL = '" + xFilial("SZ4") + "' " + cEoL 
        cQuery += "     AND SZ4.Z4_ID = '" + cIdUltSgt + "' " + cEoL 
        cQuery += "     AND SZ4.Z4_NUMPV + SZ4.Z4_ITEM = '" + cPedItem + "' " + cEoL

        cQuery := ChangeQuery(cQuery)
        DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), "TMP", .F., .T.)

        While TMP->( !Eof() )
            SB1->( DbSeek( xFilial("SB1") + TMP->Z4_CODMP ) )

            aAdd( aCols, Array(Len(aHeader)+1) )
            aCols[Len(aCols), nPosCod  ]      := TMP->Z4_CODMP
            aCols[Len(aCols), nPosQuant]      := TMP->Z4_EMP
            aCols[Len(aCols), nPosLocal]      := TMP->Z4_LOCAL
            aCols[Len(aCols), nPosTRT  ]      := StrZero(nXTRT, 3)
            aCols[Len(aCols), nPosLote  ]     := TMP->Z4_NUMLOTE
            aCols[Len(aCols), nPosLotCtl]     := TMP->Z4_LOTECTL
            aCols[Len(aCols), nPosdValid]     := SToD( TMP->Z4_DTVALID )
            aCols[Len(aCols), nPosPotenc]     := CriaVar("D4_POTENCI")
            aCols[Len(aCols), nPosLocLz ]     := CriaVar("DC_LOCALIZ")
            aCols[Len(aCols), nPosnSerie]     := CriaVar("DC_NUMSERI")
            aCols[Len(aCols), nPosUM     ]    := SB1->B1_UM
            aCols[Len(aCols), nPosQtSegum]    := 0
            aCols[Len(aCols), nPos2UM    ]    := SB1->B1_SEGUM
            aCols[Len(aCols), nPosDescr  ]    := SB1->B1_DESC
            aCols[Len(aCols), Len(aHeader)+1] := .F. 
            nXTRT++

            TMP->( DbSkip() ) 
        EndDo

        TMP->( DbCloseArea() )
    Else
        For nI := 1 To Len(aREFATA06[14])
            SB1->( DbSeek( xFilial("SB1") + aREFATA06[14, nI, 01] ) )

            aAdd( aCols, Array(Len(aHeader)+1) )
            aCols[Len(aCols), nPosCod  ]      := aREFATA06[14, nI, 01]
            aCols[Len(aCols), nPosQuant]      := aREFATA06[14, nI, 03]
            aCols[Len(aCols), nPosLocal]      := aREFATA06[14, nI, 02]
            aCols[Len(aCols), nPosTRT  ]      := StrZero(nI, 3)
            aCols[Len(aCols), nPosLote  ]     := aREFATA06[14, nI, 05]
            aCols[Len(aCols), nPosLotCtl]     := aREFATA06[14, nI, 04]
            aCols[Len(aCols), nPosdValid]     := aREFATA06[14, nI, 06]
            aCols[Len(aCols), nPosPotenc]     := CriaVar("D4_POTENCI")
            aCols[Len(aCols), nPosLocLz ]     := CriaVar("DC_LOCALIZ")
            aCols[Len(aCols), nPosnSerie]     := CriaVar("DC_NUMSERI")
            aCols[Len(aCols), nPosUM     ]    := SB1->B1_UM
            aCols[Len(aCols), nPosQtSegum]    := 0
            aCols[Len(aCols), nPos2UM    ]    := SB1->B1_SEGUM
            aCols[Len(aCols), nPosDescr  ]    := SB1->B1_DESC
            aCols[Len(aCols), Len(aHeader)+1] := .F.
        Next nI
    EndIf

    RestArea(aArea)

Return

