#include "totvs.ch"
#include "topconn.ch"


/*/{Protheus.doc} xIsFilme
Verifica se o produto e FILME/BOPP
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 11/05/2022
@param cGrupo, character, Codigo do produto
@return logical, Retorno logico
@history 08/12/2023, DO THINK - DENER LEMOS, Alteracao da funcao de Static para User function, para ser chamada de outros locais
/*/
User Function xIsFilme(cProduto)
	Local aArea	   := GetArea()
	Local aAreaSB1 := SB1->(GetArea())
	Local lRet	   := .F.

	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))

	lRet := SB1->(dbSeek(xFilial("SB1") + cProduto)) .And. SB1->B1_XGRUPO == "1"

	Restarea(aAreaSB1)
	Restarea(aArea) 

Return lRet


/*/{Protheus.doc} xIsPA
Verifica se o produto informado e um produto acabado
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 26/05/2022
@param cProduto, character, Codigo do produto
@return logical, Retorno logico
@history 08/12/2023, DO THINK - DENER LEMOS, Alteracao da funcao de Static para User function, para ser chamada de outros locais
/*/
User Function xIsPA(cProduto)
	Local aAreaAnt := GetArea()
	Local aAreaSB1 := SB1->(GetArea())
	Local lRet	   := .F.

	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))

	lRet := SB1->(dbSeek(xFilial("SB1") + cProduto)) .And. SB1->B1_TIPO == "PA"

	Restarea(aAreaSB1)
	Restarea(aAreaAnt) 

Return lRet


/*/{Protheus.doc} xIsMP
Verifica se o produto informado e uma materia prima
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 26/05/2022
@param cProduto, character, Codigo do produto
@return logical, Retorno logico
@history 08/12/2023, DO THINK - DENER LEMOS, Alteracao da funcao de Static para User function, para ser chamada de outros locais
/*/
User Function xIsMP(cProduto)
	Local aAreaAnt := GetArea()
	Local aAreaSB1 := SB1->(GetArea())
	Local lRet	   := .F.

	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))

	lRet := SB1->(dbSeek(xFilial("SB1") + cProduto)) .And. SB1->B1_TIPO == "MP"

	Restarea(aAreaSB1)
	Restarea(aAreaAnt) 

Return lRet


/*/{Protheus.doc} xIsMP
Verifica se o produto informado e uma materia prima
@type function
@version 1.0  
@author DO THINK - FERNANDO MUTA
@since 18/01/2025
@param cProduto, character, Codigo do produto
@return logical, Retorno logico
/*/
User Function xIsTub(cProduto)
	Local aAreaAnt := GetArea()
	Local aAreaSB1 := SB1->(GetArea())
	Local lRet	   := .F.

	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))

	If SB1->(dbSeek(xFilial("SB1") + cProduto))
       lRet := "TUBETE" $ SB1->B1_COD
    EndIf
	Restarea(aAreaSB1)
	Restarea(aAreaAnt) 

Return lRet


/*/{Protheus.doc} xVldCBCCod
Rotina de validacao especifica do campo CBC_COD do inventario, usada para quando for validar o codigo. 
Foi criada mais especificamente para preencher o lote e sub-lote das bobinas de forma automatica, no entanto
para que isso funcione, deve ser feito o procedimento mencionado na area de "@obs".
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 08/12/2023
@obs Posicionar o foco sobre o campo "CBC_COD" e clicar nos botoes a seguir, nesse ordem: "ENTER (2x), ESC"
/*/
User Function xVldCBCCod()
	Local cLoteCtl := ""
	Local cNumLote := ""
	Local nLinha   := 0

	If u_xIsFilme(cProduto) .And. u_xIsMP(cProduto)
		nLinha := oGetDad:oBrowse:nAt

		//-- Descobre e preenche o Sub-lote
		cNumLote := NextLote(cProduto, "S")
		//-- Sub-lote
		aCols[nLinha, RetPosCpo("CBC_NUMLOT")] := cNumLote

		//-- Descobre e preenche o Lote
		cLoteCtl := NextLote(cProduto, "L", cNumLote)
		//-- Lote
		aCols[nLinha, RetPosCpo("CBC_LOTECT")] := cLoteCtl
	EndIf

Return


/*/{Protheus.doc} RetPosCpo
Retorna a possicao do Campo no aHeader
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 08/12/2023
@param cCpo, character, Campo
@return numeric, Retorna a possicao do Campo no aHeader
/*/
Static Function RetPosCpo(cCpo)
Return aSCan(aHeader, {|x| AllTrim(x[2]) == AllTrim(cCpo)})


/*/{Protheus.doc} IsOff
Rotina que verifica se o produto e Off (Segunda linha)
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 29/02/2024
@param cCodProd, character, Codigo do produto
@return logical, Retorno logico
/*/
User Function xIsOff(cCodProd)
Return Right(AllTrim(cCodProd), 1) == "R"


/*/{Protheus.doc} GetDimen
Rotina que retorna as dimensoes do codigo/produto do tipo filme, de PA e/ou MP
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 29/04/2022
@param cCod, character, Codigo do produto
@param cRetType, character, Tipo de retorno
@return array, Array com as dimensoes
/*/
User Function xGetDimen(cCod, cRetType)
    Local aRet    := {}
    Local nI      := 0
    Local nNumCar := 0
    Local cAllDim := ""

    Default cRetType := "C"

    nNumCar := u_xNCarFilm(cCod)
    cAllDim := Right(AllTrim(cCod), nNumCar)

    aAdd(aRet, SubStr(cAllDim, 01, 02)) //-- Diametro interno do tubo da bobina (Polegadas)
    aAdd(aRet, SubStr(cAllDim, 03, 03)) //-- Diametro externo da bobina (mm)
    aAdd(aRet, SubStr(cAllDim, 06, 04)) //-- Largura da bobina (mm)

    If cRetType == "N"
        For nI := 1 To Len(aRet)
            aRet[nI] := Val(aRet[nI])
        Next nI
    EndIf

Return aClone(aRet)


//-- Rotina que retorna o numero que caracteras das dimensoes do codigo/produto do tipo filme, de PA e/ou MP
User Function xNCarFilm(cCod)
    Local nNumCar := 0

    If u_xIsOff(cCod)
        nNumCar := 10
    ElseIf u_xIsMP(cCod) .And. Right(AllTrim(cCod), 2) == "AE"
        nNumCar := 11
    Else
        nNumCar := 9
    EndIf

Return nNumCar


//--
User Function xQry2Excel(cQryAux, cTitAux)
    Default cQryAux := ""
    Default cTitAux := "Título"
     
    Processa({|| ProcQry2Exc(cQryAux, cTitAux) }, "Processando...")

Return


//--
Static Function ProcQry2Exc(cQryAux, cTitAux)
    Local aAreaAnt    := GetArea()
    Local aAreaX3     := SX3->(GetArea())
    Local aColunas    := {}
    Local aEstrut     := {}
    Local aLinhaAux   := {}
    Local nAux        := 0
    Local cDiretorio  := GetTempPath()
    Local cArquivo    := Lower(GetNextAlias()) + ".xml"
    Local cArqFull    := cDiretorio + cArquivo
    Local cWorkSheet  := "Aba - Principal"
    Local cTable      := ""
    Local cTitulo     := ""
    Local nTotal      := 0
    Local nAtual      := 0
    Local oFWMsExcel  := Nil
    Local oExcel      := Nil

    Default cQryAux := ""
    Default cTitAux := "Título"
     
    cTable := cTitAux
     
    //-- Se tiver a consulta
    If !Empty(cQryAux)
		If Select("QRY_AUX") > 0
			QRY_AUX->(dbCloseArea())
		EndIf

		cQryAux := ChangeQuery(cQryAux)
		dbUseArea(.T., "TOPCONN", TcGenQry(,,cQryAux), "QRY_AUX")
         
        dbSelectArea("SX3")
        SX3->(dbSetOrder(2)) //-- X3_CAMPO
         
        //-- Percorrendo a estrutura
        aEstrut := QRY_AUX->(dbStruct())
        ProcRegua(Len(aEstrut))
        For nAux := 1 To Len(aEstrut)
            IncProc("Incluindo coluna "+cValToChar(nAux)+" de "+cValToChar(Len(aEstrut))+"...")
            cTitulo := ""
             
            //-- Se conseguir posicionar no campo
            If SX3->(DbSeek(aEstrut[nAux][1]))
                cTitulo := Alltrim(SX3->X3_TITULO)
                 
                //-- Se for tipo data, transforma a coluna
                If SX3->X3_TIPO == 'D'
                    TCSetField("QRY_AUX", aEstrut[nAux][1], "D")
                EndIf
            Else
                cTitulo := Capital(Alltrim(aEstrut[nAux][1]))
            EndIf
             
            //-- Adicionando nas colunas
            aAdd(aColunas, cTitulo)
        Next nAux
          
        //-- Criando o objeto que ira gerar o conteudo do Excel
        oFWMsExcel := FWMSExcel():new()
        oFWMsExcel:addworkSheet(cWorkSheet)
		oFWMsExcel:addTable(cWorkSheet, cTable)
			
		//-- Adicionando as Colunas
		For nAux := 1 To Len(aColunas)
			oFWMsExcel:addColumn(cWorkSheet, cTable, aColunas[nAux], 1, 1)
		Next nAux
			
		//-- Definindo o total da barra
		dbSelectArea("QRY_AUX")
		QRY_AUX->(dbGoTop())
		Count To nTotal
		ProcRegua(nTotal)
		nAtual := 0
			
		//-- Percorrendo os produtos
		QRY_AUX->(dbGoTop())
		While QRY_AUX->(!EoF())
			nAtual++
			IncProc("Processando registro "+cValToChar(nAtual)+" de "+cValToChar(nTotal)+"...")
			
			//-- Criando a linha
			aLinhaAux := Array(Len(aColunas))
			For nAux := 1 To Len(aEstrut)
				aLinhaAux[nAux] := &("QRY_AUX->"+aEstrut[nAux][1])
			Next
				
			//-- Adiciona a linha no Excel
			oFWMsExcel:addRow(cWorkSheet, cTable, aLinhaAux)
				
			QRY_AUX->(dbSkip())
		EndDo
              
        //-- Ativando o arquivo e gerando o xml
        oFWMsExcel:activate()
        oFWMsExcel:getXMLFile(cArqFull)
         
        //-- Se tiver o excel instalado
        If ApOleClient("msexcel")
            oExcel := MsExcel():new()
            oExcel:WorkBooks:open(cArqFull)
            oExcel:setVisible(.T.)
            oExcel:destroy()
        Else
            //-- Se existir a pasta do LibreOffice 5
            If ExistDir("C:\Program Files (x86)\LibreOffice 5")
                WaitRun('C:\Program Files (x86)\LibreOffice 5\program\scalc.exe "'+cDiretorio+cArquivo+'"', 1)
            Else
				//-- Senao, abre o XML pelo programa padrao
                ShellExecute("open", cArquivo, "", cDiretorio, 1)
            EndIf
        EndIf

		If Select("QRY_AUX") > 0
			QRY_AUX->(dbCloseArea())
		EndIf
    EndIf

    RestArea(aAreaX3)
    RestArea(aAreaAnt)

Return


/*/{Protheus.doc} x390SLot
Rotina para setar numero do Sub-Lote quando for incluida uma manutencao de lote manualmente
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 25/09/2024
@return logical, Retorno logico
/*/
User Function x390SLot()

    If INCLUI .And. Rastro(M->D5_PRODUTO, "S")
        //-- Seta valor branco
        SetMVValue("X390SLOT", "MV_PAR01", Space(Len(SD5->D5_NUMLOTE)))

        If Pergunte("X390SLOT", .T., "Informe Sub-Lote")
            //-- Sub-Lote informado pelo usuario
            M->D5_NUMLOTE := MV_PAR01
        EndIf
    EndIf

Return .T.


//-- 
User Function xDescFin(nOpc, cCGC)
    Local nValor    := 0
    Local nDias     := 0
    Local nDescFin  := 0
    Local nDesconto := 0
    Local dDtDscFin := CToD("//")
    Local cDtDscFin := ""
    Local xRet      := 0

    //-- Condicoes especiais de desconto para Cliente "CPE PLASTICOS LTDA"
    If AllTrim(cCGC) $ "11272246000481/10756910000233/52321961000100/"
        nValor := SE1->E1_VALOR
        nDias  := SE1->E1_VENCREA - dDataBase

        Do Case
            Case nDias > 1 .And. nDias <= 30
                nDescFin := 3.75
            Case nDias > 30 .And. nDias <= 60
                nDescFin := 7.64
            Case nDias > 60 .And. nDias <= 90
                nDescFin := 11.68
            Case nDias > 90 .And. nDias <= 120
                nDescFin := 15.87
            Case nDias > 120 .And. nDias <= 150
                nDescFin := 21.21
            Case nDias > 150 .And. nDias <= 180
                nDescFin := 24.72
            Case nDias > 180 .And. nDias <= 210
                nDescFin := 29.39
            Case nDias > 210 .And. nDias <= 240
                nDescFin := 34.25
            Case nDias > 240 .And. nDias <= 270
                nDescFin := 39.28
            Case nDias > 270 .And. nDias <= 300
                nDescFin := 44.50
            Case nDias > 300
                nDescFin := 49.92
        EndCase

        If nDias >= 360
            nDias := 359
        EndIf

        If nOpc == 1 .And. nDias > 0
            dDtDscFin := MonthSub(SE1->E1_VENCREA, Int(nDias/30))
            cDtDscFin := DTOS(dDtDscFin)
            xRet      := SubStr(cDtDscFin,7,2)+SubStr(cDtDscFin,5,2)+SubStr(cDtDscFin,3,2)
        ElseIf nOpc == 2 .And. nDias > 0
            If nDescFin > 0
                nDesconto := (nDescFin/100) * nValor
                xRet      := STRZERO((Round(nDesconto, 2) * 100), 13)
            EndIf
        EndIf
    EndIf

    If nOpc == 1 .And. Empty(xRet)
        xRet := STRZERO(0, 6)
    ElseIf nOpc == 2 .And. Empty(xRet)
        xRet := STRZERO(0, 13)
    EndIf

Return xRet


/*/{Protheus.doc} xNextNum
Rotina customizada que retorna o ultimo sequencial do campo de uma tabela
@type function
@version 1.0
@author DO THINK
@since 24/09/2024
@param cTable, character, Tabela
@param cField, character, Campo
@return character, Ultimo sequencial
/*/
User Function xNextNum(cTable, cField)
    Local cNexNum := ""
    Local cQry    := ""

    cTable := AllTrim(cTable)
    cField := AllTrim(cField)

    While .T.
        cNexNum := GetSX8Num(cTable, cField)

        //-- Query para consulta dos registros
        cQry := " SELECT COUNT(1) REGISTRO "
        cQry += " FROM " + RetSqlName(cTable)
        cQry += " WHERE " + IIF(LEFT(cTable, 1)=="S", SUBSTR(cTable, 2), cTable) + "_FILIAL = '" + xFilial(cTable) + "' ""
        cQry += " AND " + cField + " = '" + cNexNum + "' " 
        cQry += " AND D_E_L_E_T_ = ' ' " 

        cQry := ChangeQuery(cQry)
        TCQUERY cQry New Alias "TRB"

        If TRB->REGISTRO == 0
            TRB->(dbCloseArea())
            Exit
        EndIf

        TRB->(dbCloseArea())
    EndDo

    ConfirmSX8()    

Return cNexNum


/*/{Protheus.doc} StrFilter
Trata Filtro em body das apis
@type function
@version 1.0  
@author DOTHINK - Claudio Donizete
@since 12/04/2023
@param cFilterString, character, Filtro para tradução
@return array, Array com os filtros
/*/
User Function StrFilter(cFilterString)
	Local aRet      := {}
	Local lComplex  := "FILTER" $ Upper( cFilterString )
	Local nLen
	Local nX
	Local cAux
	Local aAux

    // filtros simples
    // a requição com: ?propriedade1=valor1&propriedade2=valor2
    // exigiria o array como
    // aUrlFilter := { ;
    //   {"propriedade1", "valor1"},;
    //   {"propriedade2", "valor2"} ;
    // }
    // self:SetUrlFilter(aUrlFilter)

    // // filtro complexos
    // // ?filter=propriedade1 eq 'valor1' and propriedade2 eq 'valor2'
    // aUrlFilter := { ;
    //   {"FILTER", "propriedade1 eq 'valor1' and propriedade2 eq 'valor2'"};
    // }
	If lComplex
		// Separa a palavra filter do resto a string de filtro. A palavra FILTER precisa ser em maiusculo.
		cAux            := Alltrim( Substr( cFilterString, 1, At("=", cFilterString) - 1 ) )
		cFilterString   := upper( cAux ) + "||" + SubStr( cFilterString, At("=", cFilterString) + 1 )
		aAux            := Separa( Strtran( cFilterString, "FILTER=", "FILTER||"), "||" )

	Else
		
        aAux := Separa( Strtran( cFilterString, "&", "=" ), "=" )
	
    EndIf
	
    Aadd(aRet, {})

	nLen := Len(aAux)
	
    For nX := 1 To nLen
		
        If Upper( Alltrim(aAux[nX]) ) == "FILTER"
			
            Aadd(aRet[1], aAux[nX])
		
        Else
		
        	Aadd(aRet[Len(aRet)], aAux[nX])
		
        	// Filtro simples, precisa adicionar uma nova linha no array de retorno
			If nX % 2 == 0 .And. nX < nLen
				Aadd(aRet, {})
			Endif
		
        Endif

	Next nX

	aSize(aAux,0)

Return aRet


//-- Rotina para incluir mensagem adicional na API
User Function AdicResp(cJSON, nCode, cMessage, cDetMessage)
	Local cRet := AllTrim(cJSON)

	cRet := Left(cRet, Len(cRet) - 1)

	cRet += ',"code":' + cValToChar(nCode) + ',"message":"' + cMessage + '","detailedMessage":"' + cDetMessage + '"}'

Return cRet

// U_XCADGEN()
User Function XCADGEN(cTabela)
    Local aAreaAnt := GetArea()

    Private cCadastro := ""
    Private aRotina   := {}

    If !Empty(cTabela)
        cCadastro := "CADASTRO GENERICO " + AllTrim(cTabela)

        //-- Array aRotina
        aAdd(aRotina, {"Visualizar", "AxVisual", 0, 2})
        aAdd(aRotina, {"Incluir", "AxInclui", 0, 3})
        aAdd(aRotina, {"Alterar", "AxAltera", 0, 4})
        aAdd(aRotina, {"Excluir", "AxDeleta", 0, 5})

        //-- Tabela
        dbSelectArea(cTabela)
        (cTabela)->(dbSetOrder(1))

        //-- Montagem do Browse
        mBrowse(6, 1, 22, 75, cTabela)
        
        //-- Encerra rotina
        (cTabela)->(dbCloseArea())
        RestArea(aAreaAnt)
    EndIf

Return

// U_XGRVCDV()
User Function XGRVCDV()
	Local aAreaAnt  := GetArea()
	Local cAliasQry	:= GetNextAlias()

	BeginSQL Alias cAliasQry
        SELECT * FROM (
                        SELECT SF2.*, CDV_FILIAL+CDV_DOC+CDV_SERIE+CDV_CLIFOR+CDV_LOJA AS CDV_ORIGEM
                        FROM vw_fat_registros_para_cdv SF2
                        LEFT JOIN %Table:CDV% CDV
                        ON CDV.CDV_FILIAL = FILIAL
                        AND CDV.CDV_DOC = DOCUMENTO
                        AND CDV.CDV_SERIE = SERIE
                        AND CDV.CDV_CLIFOR = CLI_FOR
                        AND CDV.CDV_LOJA = LOJA
                        AND CDV.CDV_NUMITE = NUM_ITEM
                    ) TRB
        WHERE CDV_ORIGEM IS NULL
        ORDER BY FILIAL, DOCUMENTO, SERIE, CLI_FOR, LOJA, NUM_ITEM
	EndSQL

	If !(cAliasQry)->(EoF())
		While !(cAliasQry)->(EoF())
			If CDV->(RecLock("CDV", .T.))
				CDV->CDV_FILIAL		:= (cAliasQry)->FILIAL
				CDV->CDV_PERIOD		:= (cAliasQry)->PERIODO
                CDV->CDV_CODAJU		:= (cAliasQry)->CODAJU
                CDV->CDV_DESCR		:= SubStr(Posicione("CDY",1, (cAliasQry)->FILIAL + (cAliasQry)->CODAJU,"CDY_DESCR"),1,254)
                CDV->CDV_VALOR		:= (cAliasQry)->VALOR
                CDV->CDV_DOC        := (cAliasQry)->DOCUMENTO
                CDV->CDV_SERIE      := (cAliasQry)->SERIE
                CDV->CDV_CLIFOR     := (cAliasQry)->CLI_FOR
                CDV->CDV_LOJA       := (cAliasQry)->LOJA
                CDV->CDV_AUTO		:= (cAliasQry)->AUTOM
                CDV->CDV_NUMITE     := (cAliasQry)->NUM_ITEM
                CDV->CDV_TPMOVI     := (cAliasQry)->TP_MOVI
                CDV->CDV_ESPECI     := (cAliasQry)->ESPECI
                CDV->CDV_FORMUL     := (cAliasQry)->FORMUL
                CDV->CDV_ID         := FWUUID("FISA140")
                CDV->CDV_NFE        := Posicione("CDY", 1, (cAliasQry)->FILIAL + (cAliasQry)->CODAJU, "CDY_NFE")
                CDV->CDV_ZERAVL     := Posicione("CDY", 1, (cAliasQry)->FILIAL + (cAliasQry)->CODAJU, "CDY_ZERAVL")
				CDV->CDV_CFOP		:= (cAliasQry)->CFOP
				CDV->(MSUnlock())
			EndIf

			(cAliasQry)->(dbSkip())
		EndDo
	EndIf

	(cAliasQry)->(dbCloseArea())

	RestArea(aAreaAnt)

Return
