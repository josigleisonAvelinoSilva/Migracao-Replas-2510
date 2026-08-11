/*/{Protheus.doc} REPLA960
    Rotina responsável por elaborar a mensagem na observação da nota fiscal exigido pelo SEFAZ.
    @type  Function
    @author Robson Gonçalves
    @since 23/02/2021
    /*/

User Function REPLA960()
    Local cMsg := ''

    If cFilAnt=="0201"
        If SA1->A1_COD == '14555032' .AND. SA1->A1_LOJA == '0003'
            cMsg := "Suspenção do ICMS nos termos do Art.402 Dec.Nº45490/00 e "
            cMsg += "suspenção do IPI nos termos do Art.43.VII-Dec.7212/10 ref NF/Série:"+GetNFOrig()+" "
            cMsg += "de remessa p/ industrialização."
        Endif
    Endif
Return(cMsg)

/*/{Protheus.doc} GetNFOrig
    Rotina auxiliar para encontrar os dados da NF origem.
    @type  Function
    @author Robson Gonçalves
    @since 23/02/2021
    /*/
Static Function GetNFOrig()
    Local a960NF := {}
    Local aArea := {}
    Local cKeyNF := ''
    Local cReturn := ''
	Local nNF := 0
	
    aArea := SD2->(GetArea())
    
    dbSelectArea('SD2')
    SD2->(dbSetOrder(3))
    If SD2->(MsSeek(SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
        While SD2->(.NOT.EOF()) .AND. SD2->D2_FILIAL==SF2->F2_FILIAL .AND.;
            SD2->D2_DOC==SF2->F2_DOC .AND.;
            SD2->D2_SERIE==SF2->F2_SERIE .AND.;
            SD2->D2_CLIENTE==SF2->F2_CLIENTE .AND.;
            SD2->D2_LOJA==SF2->F2_LOJA
			
            cKeyNF := SD2->D2_NFORI+'/'+SD2->D2_SERIORI
			
			nNF := AScan(a960NF,{|e| e==cKeyNF})
			
            If .NOT. (cKeyNF $ cReturn) .AND. (nNF == 0)
				AAdd(a960NF,cKeyNF)
				
                If cReturn == ''
                    cReturn := cKeyNF
                Else
                    cReturn := cReturn + ', ' + cKeyNF
                Endif
            Endif
            SD2->(dbSkip())
        End
    Endif

    RestArea(aArea)
Return(cReturn)
