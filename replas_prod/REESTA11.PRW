#INCLUDE "PROTHEUS.CH"
#INCLUDE "APVT100.CH"
/*/{Protheus.doc} REESTA11
Efetua a chamada para Impressão de Etiquetas - MP
@type function
@version 1.0
@author Marcos P.Aversa
@since 28/06/2023
@return variant, NIL
/*/
User Function REESTA11()
    Local aArea         := GetArea()
    Local aAreaSF1      := SF1->( GetArea() )  
    Local aAreaCB5      := CB5->( GetArea() )
    Local aAreaSD1      := SD1->( GetArea() )      
    Private cPerg       := PADR("REESTA11",10)
    Private aRegs       := {}

    CB5->( dbSetOrder(1))
    SD1->( dbSetOrder(1))    
    SF1->( dbSetOrder(1))

    aAdd(aRegs, {cPerg, "01", "Documento de Entrada ?","","","mv_ch1","C",9,0,0,"G","ExistCpo('SF1', mv_par01, 1) ","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SF1","","","","",""})
    aAdd(aRegs, {cPerg, "02", "Série do documento   ?","","","mv_ch2","C",3,0,0,"G","ExistCpo('SF1', mv_par01+mv_par02, 1)","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","   ","","","","",""})
    aAdd(aRegs, {cPerg, "03", "Local Impressao      ?","","","mv_ch3","C",6,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","CB5","","","","",""})       
    aAdd(aRegs, {cPerg, "04", "Lote De              ?","","","mv_ch4","C",10,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})     
    aAdd(aRegs, {cPerg, "05", "Lote Ate             ?","","","mv_ch5","C",10,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})     

    //-- Verifica as Perguntas e incluindo caso não existam
	U_ValidPerg( cPerg, aRegs)
    
    lPergunte := Pergunte( cPerg , .T. )

    If !lPergunte
        Return
    Endif

    If  FWAlertYesNo("Confirma a Emissao de Etiquetas ?", "Etiquetas")
        If !( Empty(  MV_PAR01 ) .OR.  Empty(  MV_PAR02 ) .AND.  Empty(  MV_PAR03 ) )
            IF SF1->( dbSeek( xFilial( "SF1") + MV_PAR01 + MV_PAR02 ) )
                IF CB5->( !dbSeek( xFilial( "CB5") + MV_PAR03 ) ) 
                   FWAlertError("Impressora " + MV_PAR03 + " não localizada.", "Impressora")                
                Else
                    U_XREESTA11( MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04, MV_PAR05 )  
                Endif
            Else
                FWAlertError("A Nota Fiscal informada não foi localizada.", "Não Permitido!")
            Endif
        Else 
            FWAlertError("Existe algum parâmetro com conteudo em Branco !!!", "Branco!")            
        Endif
    Endif

    RestArea( aAreaSD1 )
    RestArea( aAreaCB5 )
    RestArea( aAreaSF1 )
    RestArea( aArea )
Return

User Function XREESTA11( cDoc, cSerie, cImp, cLtDe, cLtAte )
    local cINNOVA     := GetMV("RE_FINNOVA", .F.,  "042297610001")
    local nQtdPEtq    := GetMV( "RE_QTDPETQ", .F., 2 )  //-- Quantidade padrao de etiquetas a serem impressas no inventario Replas    
    local aParam      := {}    
    Private cForIN    := ""     //--Cod.Fornecedor Innova 
    Private cLjIN     := ""     //--Loja Forneceor Innova

    cForIN := LEFT( cINNOVA, 8 )
    cLjIN  := RIGHT( cINNOVA, 4 )     

    If SD1->( dbSeek( xFilial("SD1") + cDoc + cSerie  + cForIN + cLjIN  ))
        While SD1->( !Eof() ) .And.;
             SD1->D1_FILIAL + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA == xFilial("SD1") + cDoc + cSerie  + cForIN + cLjIN
             If SD1->D1_LOTECTL >= cLtDe  .AND. SD1->D1_LOTECTL <= cLtAte
                aParam      := {}
                aParam := { SD1->D1_COD,;     //-- 01 - Produto
                            SD1->D1_LOCAL,;   //-- 02 - Armazem
                            SD1->D1_QUANT,;   //-- 03 - Peso Liquido
                            0,;               //-- 04 - Peso Bruto
                            SD1->D1_LOTECTL,; //-- 05 - Lote
                            SD1->D1_NUMLOTE,; //-- 06 - SubLote
                            SD1->D1_DTVALID,; //-- 07 - Data de validade
                            SD1->D1_DTDIGIT,; //-- 08 - Data de fabricacao
                            nQtdPEtq,; //-- 09 - Quantidade
                            cImp } //-- 10 - Local de impressao                        
                            
                //-- Inicia a Impressao das etiquetas
                U_REPCPR1A(aParam)
            Endif     
            SD1->( dbSkip() )          
        Enddo 
    Endif
 
Return

/*/{Protheus.doc} ValidPerg
Verifica as Perguntas e incluindo caso não existam
@type function
@version 1.0
@author Marcos P.Aversa
@since 16/12/2022
@param cPerg, character, Nome do Grupo de Perguntas
@param aMatriz, array, contendo as Perguntas
/*/
User Function ValidPerg(cPerg, aMatriz)
    Local _j      := 0
    Local _i      := 0
    Local _cPerg  := PadR(cPerg,10)
    Local _aRegs  := aMatriz

    DbSelectArea("SX1")
    DbSetOrder(1)

    For _i := 1 to Len(_aRegs)
        If !DbSeek( _cPerg + _aRegs[_i,2] )
            RecLock("SX1",.t.)
             For _j := 1 to FCount()
                If Fcount()-1 > _j 
                    FieldPut( _j, _aRegs[_i,_j] )
                Endif
            Next
            MsUnlock()
        EndIf 
    Next

    Return

