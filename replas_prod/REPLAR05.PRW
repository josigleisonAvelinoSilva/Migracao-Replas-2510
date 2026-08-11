#INCLUDE "PROTHEUS.CH"
/*/{Protheus.doc} REPLAR05
Gera Planilha Excel - Saldos em Estoque
@type function
@version 1.0
@author Marcos Aversa - Dothink
@since 04/01/2024
@return variant, nil
/*/
User Function REPLAR05()
    Local nOpcao    := 2
    Local aSays     := {}
    Local aButtons  := {}
    Local cCadastro := OemToAnsi("Saldos Por Lote")
    Local aDados    := {}
    Private cPerg   := PADR("REPLAR05",10)  
    Private aRegs   := {}    

    aAdd(aRegs, {cPerg, "01", "Filial De    ?","","","mv_ch1","C",04,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SM0_01","","","","",""})
    aAdd(aRegs, {cPerg, "02", "Filial Ate   ?","","","mv_ch2","C",04,0,0,"G","NaoVazio() .And. (MV_PAR02 >= MV_PAR01)","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SM0_01","","","","",""})
    aAdd(aRegs, {cPerg, "03", "Produto De   ?","","","mv_ch3","C",20,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SB1","","","","",""})
    aAdd(aRegs, {cPerg, "04", "Produto Ate  ?","","","mv_ch4","C",20,0,0,"G","NaoVazio() .And. (MV_PAR04 >= MV_PAR03)","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SB1","","","","",""})    
    aAdd(aRegs, {cPerg, "05", "Local De     ?","","","mv_ch5","C",02,0,0,"G","Vazio() .Or. ExistCPO('NNR')   ","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","NNR","","","","",""})
    aAdd(aRegs, {cPerg, "06", "Local Ate    ?","","","mv_ch6","C",02,0,0,"G","NaoVazio() .And. (MV_PAR06 >= MV_PAR05)","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","NNR","","","","",""})    
    aAdd(aRegs, {cPerg, "07", "Lote De      ?","","","mv_ch7","C",10,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})     
    aAdd(aRegs, {cPerg, "08", "Lote Ate     ?","","","mv_ch8","C",10,0,0,"G","NaoVazio() .And. (MV_PAR08 >= MV_PAR07)","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""}) 
    aAdd(aRegs, {cPerg, "09", "Sub-Lote De  ?","","","mv_ch9","C",06,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})     
    aAdd(aRegs, {cPerg, "10", "Sub-Lote Ate ?","","","mv_cha","C",06,0,0,"G","NaoVazio() .And. (MV_PAR10 >= MV_PAR09)","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})     

    aAdd(aRegs, {cPerg, "11", "Lote Forn. De  ?","","","mv_chb","C",18,0,0,"G","","mv_par11","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})     
    aAdd(aRegs, {cPerg, "12", "Lote Forn. Ate ?","","","mv_chc","C",18,0,0,"G","NaoVazio() .And. (MV_PAR12 >= MV_PAR11)","mv_par12","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})     


    //-- Verifica as Perguntas e incluindo caso não existam
	U_ValidPerg( cPerg, aRegs)      

    //-- Inicializa as perguntas caso o usuario nao selecione a opcao de parametros na tela
    Pergunte(cPerg, .T.)

    aadd(aSays,"Este programa tem como objetivo gerar em Excel a Planilha de")
    aadd(aSays,"Saldos Por Lote, acesse parametros para realizar os filtros.")
        
    aadd(aButtons, { 5, .T., { || Pergunte(cPerg, .T.) } } )
    aadd(aButtons, { 1, .T., { || nOpcao := 1, FechaBatch() } } )
    aadd(aButtons, { 2, .T., { || FechaBatch() } } )
        
    FormBatch(cCadastro, aSays, aButtons,, 180, 450)

    If nOpcao == 1
        //-- Executa a Query
        aDados := MontaQuery()

        If !Empty(aDados)
            Processa( { || LoadExcel(aDados) }, "Gerando Planilha Saldos Por Lote", OemToAnsi( "Aguarde..." ), .F. )
        Else
            MsgAlert("Nao existem registros relacionados aos parametros informados!")
        EndIf
    EndIf
Return    

Static Function MontaQuery()
    local aArea    := GetArea()
    local axDados  := {}
    local cQuery   := ""
    local cLoteFor := ""
    local cFilOrig := GetMV( "RE_FILORIG", .F., "0302" )  


    cQuery   := " SELECT B8_FILIAL,B8_PRODUTO,B1_DESC,B8_LOCAL,B8_SALDO,B8_LOTECTL,B8_NUMLOTE,B8_DTVALID,B8_LOTEFOR "+ CRLF
    cQuery   += " FROM " + RetSqlName("SB8") +" B8 "+ CRLF
    cQuery   += " JOIN " + RetSqlName("SB1") +" B1 "+ CRLF
    cQuery   += "    ON B1.D_E_L_E_T_ = ' ' "+ CRLF
    cQuery   += "    AND B1.B1_COD = B8.B8_PRODUTO "+ CRLF
    cQuery   += " WHERE B8.D_E_L_E_T_ = ' ' "+ CRLF
    cQuery   += " AND B8_FILIAL BETWEEN '" + mv_par01 +"' AND '" + mv_par02 + "' "+ CRLF
    cQuery   += " AND B8_PRODUTO BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' "+ CRLF
    cQuery   += " AND B8_LOCAL BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "' "+ CRLF
    cQuery   += " AND B8_LOTECTL BETWEEN '" + mv_par07 + "' AND '" + mv_par08 + "' "+ CRLF
    cQuery   += " AND B8_NUMLOTE BETWEEN '" + mv_par09 + "' AND '" + mv_par10 + "' "+ CRLF
    cQuery   += " AND B8_SALDO != 0 "+ CRLF
    cQuery   += " ORDER BY B8_FILIAL,B8_PRODUTO,B8_LOCAL,B8_LOTECTL,B8_NUMLOTE "+ CRLF

    dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "XSB8", .F., .T.)

    TcSetField("XSB8","B8_DTVALID","D")
    TcSetField("XSB8","B8_SALDO","N",18,7) 

    If XSB8->( !Eof())
       While XSB8->( !Eof() )
            cLoteFor := XSB8->B8_LOTEFOR
            If Empty( cLoteFor ) .AND.  XSB8->B8_FILIAL <> cFilOrig
               cLoteFor := fBusLtFor( cFilOrig, XSB8->B8_PRODUTO, XSB8->B8_LOTECTL, XSB8->B8_NUMLOTE )
            Endif

            If ( cLoteFor  <  mv_par11 )  .Or. ( cLoteFor > mv_par12 )
               XSB8->( dbSkip() )
               Loop 
            Endif 

            Aadd( axDados, { XSB8->B8_FILIAL, XSB8->B8_PRODUTO, XSB8->B1_DESC, XSB8->B8_LOCAL, XSB8->B8_SALDO, XSB8->B8_LOTECTL, XSB8->B8_NUMLOTE, XSB8->B8_DTVALID, cLoteFor })
            XSB8->( dbSkip() )       
       Enddo
    Endif    

    XSB8->( dbCloseArea() )
    RestArea( aArea )

Return axDados

Static Function fBusLtFor( cxFil, cxCod,  cxLote,  cxSub )
    local cQuery   := ""
    local cxLotFor := ""

    cQuery   := " SELECT B8_LOTEFOR "+ CRLF
    cQuery   += " FROM " + RetSqlName("SB8") + " B8 "+ CRLF
    cQuery   += " WHERE B8.D_E_L_E_T_ = ' ' "+ CRLF
    cQuery   += " AND B8.B8_FILIAL = '" + cxFil + "' "+ CRLF
    cQuery   += " AND B8.B8_PRODUTO = '" + cxCod + "' "+ CRLF
    cQuery   += " AND B8.B8_LOTECTL = '" + cxLote + "' "+ CRLF
    cQuery   += " AND B8.B8_NUMLOTE = '" + cxSub + "' "+ CRLF

    dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "ZSB8", .F., .T.)

    If ZSB8->( !Eof())
       cxLotFor := ZSB8->B8_LOTEFOR 
    Endif

    ZSB8->( dbCloseArea() )

Return cxLotFor 


Static Function LoadExcel( aDados )
    Local cTable     := "Saldos -  E S T O Q U E"
	Local cPlan      := "Saldos"
    Local cPath      := GetTempPath()
    Local cArquivo   := CriaTrab(Nil, .F.)
    Local oFWMsExcel 
    Local oExcel
    Local IX         :=1     

    //--Criando o objeto que ira gerar o conteudo do Excel
    oFWMsExcel := FWMsExcelEx():New()

    //--Aba
	oFWMsExcel:AddworkSheet( cPlan )
	oFWMsExcel:AddTable( cPlan, cTable )

    //--Colunas
    oFWMsExcel:AddColumn( cPlan, cTable, "Filial", 2, 1 )
    oFWMsExcel:AddColumn( cPlan, cTable, "Produto", 2, 1 )
    oFWMsExcel:AddColumn( cPlan, cTable, "Descricao", 2, 1 )
    oFWMsExcel:AddColumn( cPlan, cTable, "Local", 2, 1 )
    oFWMsExcel:AddColumn( cPlan, cTable, "Saldo", 2, 1 )
    oFWMsExcel:AddColumn( cPlan, cTable, "Lote", 2, 1 )
    oFWMsExcel:AddColumn( cPlan, cTable, "Sub-Lote", 2, 1 )
    oFWMsExcel:AddColumn( cPlan, cTable, "Data", 2, 4 )
    oFWMsExcel:AddColumn( cPlan, cTable, "Lote Fornecedor", 2, 1 )    

    For IX := 1 to Len( aDados  )
        //-- Carrega os dados 
        oFWMsExcel:AddRow( cPlan, cTable, {;
                                    aDados[IX,1],;
                                    aDados[IX,2],;    
                                    aDados[IX,3],;     
                                    aDados[IX,4],;     
                                    aDados[IX,5],;     
                                    aDados[IX,6],;     
                                    aDados[IX,7],;     
                                    aDados[IX,8],;     
                                    aDados[IX,9] } )    
    Next IX

    If !Empty(oFWMsExcel:aWorkSheet)
        //--Ativando o arquivo e gerando o xml
        oFWMsExcel:Activate() 
        oFWMsExcel:GetXMLFile(cArquivo)

        //-- Copia um arquivo do ambiente do servidor, para a maquina
        If CpyS2T("\SYSTEM\"+cArquivo, cPath)
            //--Abrindo o excel e abrindo o arquivo xml
            oExcel := MsExcel():New()             //--Abre uma nova conexao com Excel
            oExcel:WorkBooks:Open(cPath+cArquivo) //--Abre uma planilha
            oExcel:SetVisible(.T.)                //--Visualiza a planilha
            oExcel:Destroy()                      //--Encerra o processo do gerenciador de tarefas
        EndIf
    EndIf

Return
