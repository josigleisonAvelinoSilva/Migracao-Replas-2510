#Include "TOTVS.CH"
#Include "FWMVCDEF.CH"
#Include "TOPCONN.CH"


Static cTitulo := "Importação de Nota Fiscal"


/*/{Protheus.doc} REESTA03
Rotina de importacao de Nota Fiscal da MM da Amazonia na Replas
@type function
@version 1.0
@author DO THINK - ERIKE YURI
@since 28/01/2023
/*/
User Function REESTA03()
	Local aArea   := GetArea()
	Local oBrowse := Nil
    local cINNOVA := GetMV("RE_FINNOVA", .F.,  "042297610001")  	

	Private aRotina := MenuDef()
   	Private cForIN  := "" 	//--Cod.Fornecedor Innova 
    Private cLjIN   := ""     //--Loja Forneceor Innova

    cForIN := LEFT( cINNOVA, 8 )
    cLjIN  := RIGHT( cINNOVA, 4 )	

	//-- Instanciando FWMBrowse - Somente com dicionario de dados
	oBrowse := FWMBrowse():New()

	//-- Setando a tabela de cadastro de Aprovadores
	oBrowse:SetAlias("SZB")

	//-- Setando a descricao da rotina
	oBrowse:SetDescription(cTitulo)

	//-- Legendas
	oBrowse:AddLegend( "SZB->ZB_STATUS = 'I'", "YELLOW", "Importado sem pre-nota"	)
	oBrowse:AddLegend( "SZB->ZB_STATUS = 'P'", "GREEN", "Pre-nota gerada"	)
	oBrowse:AddLegend( "SZB->ZB_STATUS = 'E'", "ORANGE", "Item sem produto amarrado Replas"	)

	oBrowse:DisableReport()
	oBrowse:DisableDetails()

    //-- Ordenacao do botoes na tela
    oBrowse:lOptionConfig := .F.
    aAdd(oBrowse:aButtonsOrder, "Importar NF - MM")
    aAdd(oBrowse:aButtonsOrder, "Importar NF - INNOVA")
	aAdd(oBrowse:aButtonsOrder, "Importar NF - OUTROS")
    aAdd(oBrowse:aButtonsOrder, "Gerar Pre-Nota")
	aAdd(oBrowse:aButtonsOrder, "Alterar")

	//-- Ativa a Browse
	oBrowse:Activate()

	RestArea(aArea)

Return


/*/{Protheus.doc} MenuDef
MenuDef
@type function
@version 1.0
@author DO THINK - ERIKE YURI
@since 28/01/2023
@return array, Array do MenuDef
/*/ 
Static Function MenuDef()
	Local aRot := {}

	ADD OPTION aRot TITLE "Importar NF - MM"     ACTION "u_resta03I"       OPERATION MODEL_OPERATION_INSERT ACCESS 0	
	ADD OPTION aRot TITLE "Importar NF - INNOVA" ACTION "u_resta03Y(1)"    OPERATION MODEL_OPERATION_INSERT ACCESS 0
	ADD OPTION aRot TITLE "Importar NF - OUTROS" ACTION "u_resta03Y(2)"    OPERATION MODEL_OPERATION_INSERT ACCESS 0		
	ADD OPTION aRot TITLE "Gerar Pre-Nota"       ACTION "u_resta03G"       OPERATION 4                      ACCESS 0 //-- Gerar Pre-Nota	
	ADD OPTION aRot TITLE "Visualizar"           ACTION "VIEWDEF.reesta03" OPERATION MODEL_OPERATION_VIEW   ACCESS 0
	ADD OPTION aRot TITLE "Alterar"              ACTION "VIEWDEF.reesta03" OPERATION MODEL_OPERATION_UPDATE ACCESS 0
	ADD OPTION aRot TITLE "Excluir"              ACTION "VIEWDEF.reesta03" OPERATION MODEL_OPERATION_DELETE ACCESS 0
	ADD OPTION aRot TITLE "Legenda"              ACTION "u_resta03Leg"     OPERATION 6                      ACCESS 0

Return aRot


/*/{Protheus.doc} ModelDef
ModelDef
@type function
@version 1.0
@author DO THINK - ERIKE YURI
@since 28/01/2023
@return object, Objeto do ModelDef
/*/ 
Static Function ModelDef()
	Local oModel	:= Nil
	Local oStPai	:= FWFormStruct(1, 'SZB')
	Local oStFilho	:= FWFormStruct(1, 'SZC')
	Local aSZCRel	:= {}

    //Local bLinePre  := {|oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue| fAtuLinhas(oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue)}	
       
	//-- Criando o modelo e os relacionamentos
	oModel := MPFormModel():New('resta03M')
	oModel:AddFields('SZBMASTER',/*cOwner*/, oStPai)

    //oModel:AddGrid('SZCDETAIL', 'SZBMASTER', oStFilho, bLinePre, /*bLinePost*/, /*bPre - Grid Inteiro*/, /*bPos - Grid Inteiro*/, /*bLoad - Carga do modelo manualmente*/)  //cOwner e para quem pertence
	oModel:AddGrid('SZCDETAIL', 'SZBMASTER', oStFilho, /*bLinePre*/, {|oMdl| ESTA03LIOK( oModel ) } , /*bPre - Grid Inteiro*/, /*bPos - Grid Inteiro*/, /*bLoad - Carga do modelo manualmente*/)  //cOwner e para quem pertence

	//-- Fazendo o relacionamento entre o Pai e Filho
	aAdd(aSZCRel, {'ZC_FILIAL', 'ZB_FILIAL'})
	aAdd(aSZCRel, {'ZC_DOC'   , 'ZB_DOC'   })
	aAdd(aSZCRel, {'ZC_SERIE' , 'ZB_SERIE' })
	aAdd(aSZCRel, {'ZC_FORNEC', 'ZB_FORNEC'})
	aAdd(aSZCRel, {'ZC_LOJA'  , 'ZB_LOJA'  })

	oModel:SetRelation('SZCDETAIL', aSZCRel, SZC->(IndexKey(1))) //IndexKey -> quero a ordenacao e depois filtrado
	oModel:GetModel('SZCDETAIL'):SetUniqueLine({"ZC_FILIAL", "ZC_DOC", "ZC_SERIE", "ZC_FORNEC", "ZC_LOJA", "ZC_ITEM"})    //Nao repetir informacies ou combinacoes {"CAMPO1","CAMPO2","CAMPOX"}
	//oModel:GetModel('SZCDETAIL'):SetUniqueLine({"ZC_FILIAL", "ZC_DOC"})
	oModel:SetPrimaryKey({})

	//-- Setando as descricoes
	oModel:SetDescription( cTitulo )
	oModel:GetModel('SZBMASTER'):SetDescription('Cabeçalho')
	oModel:GetModel('SZCDETAIL'):SetDescription('Itens')

	oModel:GetModel('SZCDETAIL'):SetNoInsertLine(.T.)

	oStFilho:AddTrigger("ZC_VUNIT", "ZC_TOTAL", {||.T.}, {|oModel| fGatilho( oModel ) })
    oStFilho:SetProperty( "ZC_VUNIT"  , MODEL_FIELD_WHEN  , {|| WhenTotal( oModel )} )

	oModel:SetVldActivate( { |oModel| REESTA03Activ( oModel ) } )	

Return oModel


/*/{Protheus.doc} ESTA03LIOK
Linha OK - Verificacao de Replicacao de Preços unitarios
@type function
@version 1.0 
@author Dothink - Marcos P.Aversa
@since 07/2023
/*/
Static Function ESTA03LIOK(oModel)
	Local lRetorno		:= .T.
	Local aSaveLines	:= FWSaveRows()
	Local oModelZ   	:= oModel:GetModel("SZCDETAIL")
	Local nCntFor 		:= 0
	Local lExiste       := .F. 
	Local oView  		:= FwViewActive()

	nPosPrc := aScan( oModelZ:aHeader,{|x| AllTrim(x[2]) == "ZC_VUNIT" })	
	nPosPrd := aScan( oModelZ:aHeader,{|x| AllTrim(x[2]) == "ZC_COD" })	
	cCod	:= oModelZ:aDataModel[oModelZ:nLine][1][1][nPosPrd]
	nPrc    := oModelZ:aDataModel[oModelZ:nLine][1][1][nPosPrc]

	nReg    := oModelZ:nLine

	//-- Verifica se Existem Precos com valor Zero para o Produto Editado
	For nCntFor := 1 To oModelZ:Length()
		If nCntFor <> oModelZ:nLine
		If oModelZ:aDataModel[nCntFor][1][1][nPosPrd] == cCod .AND. Round(oModelZ:aDataModel[nCntFor][1][1][nPosPrc], 1) <> Round(nPrc, 1)
			lExiste := .T.
			Exit
		Endif  
		Endif
	Next nCntFor

	If lExiste
		If FWAlertYesNo("Deseja replicar o valor unitário para os outros itens deste produto <b>"+AllTrim(cCod)+"</b>?", "Replicar Vlr.Unitario?")
			For nCntFor := 1 To oModelZ:Length()
				If nCntFor <> oModelZ:nLine
					If oModelZ:aDataModel[nCntFor][1][1][nPosPrd] == cCod .AND. Round(oModelZ:aDataModel[nCntFor][1][1][nPosPrc], 1) <> Round(nPrc, 1)
						oModelZ:GoLine(nCntFor)
						oModelZ:SetValue("ZC_VUNIT", nPrc)
					Endif  
				Endif
			Next nCntFor
			oModelZ:GoLine( nReg )
			oView:Refresh()
		Endif
	Endif

	FwRestRows(aSaveLines)

Return(lRetorno)


/*/{Protheus.doc} fAtuLinhas
Replica Preco unitario para Fornecedor Especifico ( INNOVA )
@type function
@version 1.0
@author Dothink - Marcos P.Aversa
@since 06/2023
@return variant, nil
/*/
Static Function fAtuLinhas( oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue )
	local lRet := .T.
	local IX   := 1

    nPosPrd := aScan( oGridModel:aHeader,{|x| AllTrim(x[2]) == "ZC_COD" })	
	cCod	:= oGridModel:aDataModel[nLine][1][1][nPosPrd]

	If cAction == "SETVALUE" 
		If cIDField == "ZC_VUNIT" .AND.;
			!Empty( cCod ) .AND.;
			xValue != 0 .AND.;
			xCurrentValue == 0 .AND.;		   
			!oGridModel:IsDeleted()
			nNumLine := oGridModel:nLine
			nQtdLin  := oGridModel:GetQtdLine()
			If  FWAlertYesNo("Repete valor unitário Digitado para este Código ?", "Repete Valor unitário")	
				For IX := 1 to nQtdLin
					If IX <> nNumLine  .And.;
						!oGridModel:IsDeleted() .And.; 
					    oGridModel:aDataModel[IX][1][1][nPosPrd] == cCod
						oGridModel:GoLine( IX )
						oGridModel:SetValue("ZC_VUNIT",xValue )
					Endif
				Next
				oGridModel:GoLine( nLine )
			Endif
		EndIf
	EndIf

Return lRet 


/*/{Protheus.doc} REESTA03Activ
Validacao de Exclusao e Alteracao
@type function
@version 1.0
@author Dothink - Marcos P.Aversa
@since 06/2023
@return variant,Objeto do ModelDef
/*/
Static Function REESTA03Activ( oModel )
	local aArea := GetArea()
	local lRet  := .T.

	Do Case
		Case oModel:GetOperation() == MODEL_OPERATION_UPDATE
			If SZB->ZB_STATUS == "P" .And. ExistDocEntr()
				Help(Nil, Nil, "Pré-Nota", Nil, "Pré-Nota [<b>" + AllTrim(SZB->ZB_DOC) + "/"+ AllTrim(SZB->ZB_SERIE) + "</b>] já gerada.", 1, 0, Nil, Nil, Nil, Nil, Nil, {"Não é permitido <b>alterar</b> uma importação com Pré-Nota gerada."})
				lRet  := .F.
			EndIf
		Case oModel:GetOperation() == MODEL_OPERATION_DELETE
			If SZB->ZB_STATUS == "P" .And. ExistDocEntr()
				Help(Nil, Nil, "Pré-Nota", Nil, "Pré-Nota [<b>" + AllTrim(SZB->ZB_DOC) + "/"+ AllTrim(SZB->ZB_SERIE) + "</b>] já gerada.", 1, 0, Nil, Nil, Nil, Nil, Nil, {"Não é permitido <b>excluir</b> uma importação com Pré-Nota gerada."})
				lRet  := .F.
			EndIf
	End Case

	RestArea( aArea)

Return lRet 


/*/{Protheus.doc} WhenTotal
Permite edicao do Prc.Unit. para Fornecedor Especifico ( INNOVA )
@type function
@version 1.0
@author Dothink - Marcos P.Aversa
@since 06/2023
@return logical, logico
/*/
Static Function WhenTotal( oModel )
	local lEdit := .F.

    IF SZB->ZB_FORNEC ==  cForIN
	   lEdit := .T.	
    Endif

Return lEdit


/*/{Protheus.doc} fGatilho
Atualiza valor Total p/ Fornecedor Especifico ( INNNOVA )
@type function
@version 1.0
@author Dothink - Marcos P.Aversa
@since 06/2023
@return numeric, valor total
/*/
Static Function fGatilho( oModel )
	local nTotal := oModel:GetValue("ZC_TOTAL") 

	IF SZB->ZB_FORNEC ==  cForIN
       nTotal := oModel:GetValue("ZC_VUNIT") * oModel:GetValue("ZC_QUANT")	   
	Endif

Return nTotal


/*/{Protheus.doc} ViewDef
ViewDef
@type function
@version 1.0
@author DO THINK - ERIKE YURI
@since 28/01/2023
@return object, Objeto da ViewDef
/*/
Static Function ViewDef()
	Local oView		:= Nil
	Local oModel	:= FWLoadModel('reesta03')
	Local oStPai	:= FWFormStruct(2, 'SZB')
	Local oStFilho	:= FWFormStruct(2, 'SZC')

	//-- Criando a View
	oView := FWFormView():New()
	oView:SetModel(oModel)

	//-- Adicionando os campos do cabecalho e o grid dos filhos
	oView:AddField('VIEW_SZB', oStPai, 'SZBMASTER')
	oView:AddGrid('VIEW_SZC', oStFilho, 'SZCDETAIL')

	oView:GetViewStruct('SZCDETAIL'):RemoveField("ZC_DOC")
	oView:GetViewStruct('SZCDETAIL'):RemoveField("ZC_SERIE")
	oView:GetViewStruct('SZCDETAIL'):RemoveField("ZC_FORNEC")
	oView:GetViewStruct('SZCDETAIL'):RemoveField("ZC_LOJA")

	//-- Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('CABEC', 30)
	oView:CreateHorizontalBox('GRID', 70)

	//-- Amarrando a view com as box
	oView:SetOwnerView('VIEW_SZB', 'CABEC')
	oView:SetOwnerView('VIEW_SZC', 'GRID')

	//-- Habilitando titulo
	oView:EnableTitleView('VIEW_SZB', 'Cabeçalho')
	oView:EnableTitleView('VIEW_SZC', 'Itens')

Return oView


/*/{Protheus.doc} resta03Leg
Rotina qe criacao da legenda do cadastro
@type function
@version 1.0
@author DO THINK - ERIKE YURI
@since 28/01/2023
/*/
User Function resta03Leg()
	Local aLegenda := {}

	//-- Monta as cores
	AADD(aLegenda, {"BR_AMARELO", "Importado sem pre-nota"})
	AADD(aLegenda, {"BR_VERDE"  , "Pre-nota gerada"})
	AADD(aLegenda, {"BR_LARANJA", "Item sem produto amarrado Replas"})

	BrwLegenda("Status", "Integração", aLegenda)

Return


/*/{Protheus.doc} resta03I
Rotina que monta um parambox para usuario digitar nota e serie que sera importada
@type function
@version 1.0
@author DO THINK - ERIKE YURI
@since 28/01/2023
/*/
User Function resta03I()
	Local aPergs   := {}
	Local cNumDoc  := Space(TamSX3("F1_DOC")[1])
	Local cSerie   := Space(TamSX3("F1_SERIE")[1])
	//Local cNomeArq := Space(300)
	//Local cJSON	   := ""
	Local aNFE		:= {}
	Local cFilOrig := GetMV("RE_FILORIG", .F., "0302")


	If cFilAnt # cFilOrig
		FWAlertError("Somente é permitido realizar a <b>" + cTitulo + "</b> na Filial [<b>" + cFilOrig + "</b>].", "Não Permitido!")
		Return
	EndIf

	//-- Perguntas principais da tela
	aAdd(aPergs, {1, "Nota Fiscal", cNumDoc , "@!", "", ".T.", , 70, .T.})
	aAdd(aPergs, {1, "Série"      , cSerie  , "@!", "", ".T.", , 40, .T.})

	If ParamBox(aPergs, "Informe Nota e Série - MM da Amazônia")
		cNumDoc	:= AllTrim(MV_PAR01)
		cSerie	:= AllTrim(MV_PAR02)
		aNFE	:= GetANota(cNumDoc, cSerie)
		/*
		If Empty(cJSON)
			aPergs := {}
			
			//-- Perguntas secundaria em caso de erro da integracao
			aAdd(aPergs, {6, "Buscar arquivo", cNomeArq, "", "", "", 80, .F., "Todos os arquivos (*.*) |*.*"})

			If ParamBox(aPergs, "Informe Arquivo JSON - MM da Amazônia")
				cNomeArq := AllTrim(MV_PAR01)

				If File(cNomeArq)
					cJSON := MemoRead(cNomeArq)
					If Empty(At("F2_CHVNFE", cJSON))
						cJSON := ""
						FWAlertError("O arquivo informado é inválido para a " + cTitulo, "Arquivo Inválido!")
					EndIf
				EndIf
			EndIf
		EndIf
		*/
		If !Empty(aNFE[1,1])
			GrvNota(aNFE[1], aNFE[2] )
		EndIf
	EndIf

Return


/*/{Protheus.doc} GetJNota
Rorina que faz o consumo do web service da MM da Amazonia
@type function
@version 1.0
@author DO THINK - ERIKE YURI
@since 28/01/2023
@param cNumDoc, character, Numero da nota
@param cNumSerie, character, Serie da nota
@param nPage, numeric, Pagina de retorno
@return character, JSON com os dados
/*/
Static Function GetJNota(cNumDoc, cNumSerie, nPage)
	Local aHeader	:= GetHeader()
	Local cPath		:= "/mmamazoninvoice"
	Local cJSON		:= ""
	//Local cHost   := GetMv("PO_URLMM", .F. ,"http://192.168.1.12:33583/rest_tst") //"http://189.2.128.242:33583/rest_tst"
	Local cHost   := GetMv("RE_URLMM", .F. , "http://189.2.128.242:33583/rest")
	//Local cHost   := GetMv("RE_URLMM", .F. , "http://186.201.95.234:8999/rest")
	Local oRest   := Nil

	If Empty(cNumDoc)
		FWAlertWarning("A Nota Fiscal não foi informado, informe um número de nota fiscal válido para contiuar.", "Não Permitido!")
		Return cJSON
	EndIf

	//-- Construtor da classe Rest
	oRest := FWRest():New(cHost)

	//-- Path onde sera feito a requisicao
	cPath += "?numdoc=" + cNumDoc + "&numserie=" + cNumSerie + "&page=" +CVALTOCHAR( nPage )
	oRest:setPath(cPath)

	//-- Consumo
	If oRest:Get(aHeader)
		cJSON := decodeUtf8(oRest:getResult())
	Else
		FWAlertError("Ocorreu o seguinte erro [<b>" + oRest:getLastError() + "</b>] ao tentar realizar a " + cTitulo, "Erro MM da Amazônia!")
	EndIf

	FreeObj(oRest)

Return cJSON


Static Function GetANota(cNumDoc, cNumSerie)
	local aRet 		:= {{"","","","","",""},{}}
	local cJSON		:= ""
	local oJson		:= JSonObject():New()
	Local cErr		:= ""
	Local aItens    := {}
	Local nI        := 0
	Local lhasNext	:= .T.
	Local nPage		:= 0

	While lhasNext
		nPage++
		cJSON := GetJNota(cNumDoc, cNumSerie, nPage)
		cErr  := oJSon:fromJson(cJSON)

		If !Empty(cErr)
			MsgStop(cErr, "JSON PARSE ERROR")
			FreeObj(oJson)
			Return {{"","","","","",""},{}}
		Endif	
		
		If Empty(aRet[1][1])
			aRet[1][1]	:= oJson:GetJSonObject('F2_DOC')
			aRet[1][2]  := oJson:GetJSonObject('F2_SERIE')
			aRet[1][3]	:= oJson:GetJSonObject('F2_CLIENTE')
			aRet[1][4]	:= oJson:GetJSonObject('F2_LOJA')
			aRet[1][5]	:= oJson:GetJSonObject('F2_EMISSAO')
			aRet[1][6]	:= oJson:GetJSonObject('F2_CHVNFE')
		EndIf

		lhasNext:= oJson:GetJSonObject('hasNext')
		aItens	:= oJson:GetJSonObject("ITENS")

		If !Empty(aItens)

			For nI:=1 To Len(aItens)
				Aadd(aRet[2],; 
					{	aItens[nI]["D2_ITEM"]	,; //-- 01
						aItens[nI]["D2_COD"]	,; //-- 02
						aItens[nI]["B1_DESC"]	,; //-- 03
						aItens[nI]["D2_QUANT"]	,; //-- 04
						aItens[nI]["D2_PRCVEN"]	,; //-- 05
						aItens[nI]["D2_TOTAL"]	,; //-- 06
						aItens[nI]["D2_LOTECTL"],; //-- 07
						aItens[nI]["D2_NUMLOTE"] ; //-- 08
					})
			Next nI
		EndIf				
	End

Return aRet


/*/{Protheus.doc} GrvNota
Rotina que realiza a gravacao dos dados retornados na tabela SZB e SZC de controle interno
@type function
@version 1.0
@author DO THINK - ERIKE YURI
@since 28/01/2023
@param aCab, array, Cabecalho da NF
@param aItens, array, Itens da NF
/*/
Static Function GrvNota(aCab, aItens)
	Local cDoc       := ""
	Local cSerie     := ""
	Local cCliente   := ""
	Local cLoja      := ""
	Local cChvNfe    := ""
	Local cEmissao   := ""
	Local cCodCliMM  := GetMv("RE_CLIMM", .F., "000086|")
	Local cCodForMM	 := "21338912" //-- A2_COD da MM DA AMAZONIA INDUSTRIA
	Local cLojaForMM := "0001"
	Local nI         := 0
	Local lPrdRps    := .T.

	If Empty(aCab[1])
		FWAlertError("A Nota Fiscal informada não localizada na <b>MM da Amazonia</b>.", "Não Permitido!")
		Return
	EndIf


	cDoc     := aCab[1] //-- F2_DOC
	cSerie   := aCab[2] //-- F2_SERIE
	cCliente := aCab[3] //-- F2_CLIENTE
	cLoja    := aCab[4] //-- F2_LOJA
	cEmissao := aCab[5] //-- F2_EMISSAO
	cChvNfe  := aCab[6] //-- F2_CHVNFE

	If !(AllTrim(cCliente) $ cCodCliMM)
		FWAlertError("A Nota Fiscal informada não pertece a <b>Replas</b>.", "Não Permitido!")
		Return
	EndIf


	If Empty(cSerie)
		FWAlertError("A Série informada veio sem dados da <b>MM da Amazônia</b>", "Sem Dados!")
		Return
	EndIf

	If Empty(aItens)
		FWAlertError("Os Itens da Nota Fical informada vieram sem dados da <b>MM da Amazônia</b>", "Sem Dados!")
		Return
	EndIf

	DbSelectArea("SZB")
	SZB->(DbSetOrder(1))
	If SZB->(DbSeek(xFilial() + cDoc + cSerie + cCodForMM + cLojaForMM))
		FWAlertWarning("A Nota Fiscal/Série [<b>" + cDoc + "/"+ cSerie + "</b>], já existe na " + cTitulo +".", "Nota Fiscal Já Existe!")
		Return
	EndIf

	//-- Inclusao do cabecalho
	RecLock("SZB", .T.)
		SZB->ZB_FILIAL	:= xFilial("SZB")
		SZB->ZB_DOC		:= cDoc
		SZB->ZB_SERIE	:= cSerie
		SZB->ZB_FORNEC	:= cCodForMM
		SZB->ZB_LOJA	:= cLojaForMM
		SZB->ZB_EMISSAO	:= STOD(cEmissao)
		SZB->ZB_CHVNFE	:= cChvNfe
		SZB->ZB_DTINT	:= Date()
		SZB->ZB_HRINT	:= Time()
		SZB->ZB_USER	:= __cUserId
		SZB->ZB_STATUS	:= 'I'
	SZB->( MsUnlock() )

	//-- Inclusao dos itens
	For nI:=1 To Len(aItens)
		RecLock("SZC", .T.)
			SZC->ZC_FILIAL	:= xFilial("SZC")
			SZC->ZC_DOC		:= cDoc
			SZC->ZC_SERIE	:= cSerie
			SZC->ZC_FORNEC	:= cCodForMM
			SZC->ZC_LOJA	:= cLojaForMM
			SZC->ZC_ITEM	:= aItens[nI][1]
			SZC->ZC_CODFOR	:= aItens[nI][2]
			SZC->ZC_DESCFOR := aItens[nI][3]
			SZC->ZC_COD		:= GetProdRps(aItens[nI][2])
			SZC->ZC_QUANT	:= aItens[nI][4]
			SZC->ZC_VUNIT	:= aItens[nI][5]
			SZC->ZC_TOTAL	:= aItens[nI][6]
			SZC->ZC_LOTECTL	:= aItens[nI][7]
			SZC->ZC_NUMLOTE	:= aItens[nI][8]
		SZC->( MsUnlock() )

		If lPrdRps .And. Empty(SZC->ZC_COD)
			lPrdRps := .F.
		EndIf
	Next nI

	If !lPrdRps
		Reclock("SZB", .F.)
			SZB->ZB_STATUS := 'E'
		SZB->( MsUnlock() )
	EndIf

Return


/*/{Protheus.doc} GetHeader
Funcao que retorna o Header
@type function
@version 1.0
@author DO THINK - ERIKE YURI
@since 28/01/2023
@return array, Array do header
/*/
Static Function GetHeader()
	Local aHeader := {}
	//Local cToken  := GetMv("DT_WSKEY" , .F., "857c07a6d5aa995444743f277c8a5ededb95fc32") //-- Authorization
	//Local cDtkey  := DTOS( Date() )
    //Local cUsrAPI  := GetMv("RE_USRAPI", .F., "USERAPI")
    //Local cPswAPI  := GetMv("RE_PSWAPI", .F., "MM@2025")
	Local cToken  := GetMv("DT_WSKEY" , .F., "VVNFUkFQSTpNTUAyMDI1") //-- Authorization

	aAdd(aHeader, "Content-Type: application/json")
	//aAdd(aHeader, "Authorization: " + cToken + cDtkey)
	aAdd(aHeader, "Authorization: Basic " + cToken)
	aAdd(aHeader, "If-Match: *") //-- Foi colocado esse cabecalho para nao retornar o erro "428 Precondition Required", do web service

Return aHeader


/*/{Protheus.doc} GeraPre
Rotina que gera a pre-nota de entrada na Replas com base nos dados importados da MM da Amazonia
@type function
@version 1.0
@author DO THINK - ERIKE YURI
@since 28/01/2023
@param cDoc, character, Numero da nota
@param cSerie, character, Serie da nota
@param cCodForMM, character, Codigo fornecedor
@param cLojaForMM, character, Loja fornecedor
@return logical, Retorno logico
/*/
Static Function GeraPre(cDoc, cSerie, cCodForMM, cLojaForMM,cArmzn)
	Local nItem    := 0
	Local aCabec   := {}
	Local aItens   := {}
	Local aLinha   := {}
	Local lRet	   := .F.
	Local lxRet    := .T.
	Local cINNOVA  := GetMV("RE_FINNOVA", .F.,  "042297610001")  
	Private cForIN := ""     //--Cod.Fornecedor Innova 
    Private cLjIN  := ""     //--Loja Forneceor Innova 

	//--Verifica digitagco de Pregos unitarios para Bobinas do Fornecedor INNOVA
    cForIN := LEFT( cINNOVA, 8 )
    cLjIN  := RIGHT( cINNOVA, 4 )
	If cCodForMM == cForIN .AND. cLojaForMM == cLjIN
	   lxRet := fVerPrcUnit( cDoc, cSerie, cCodForMM, cLojaForMM  )
	   If !lxRet
			FWAlertWarning("Existe(m) Produto(s) com Vlr.Unitario zerado. Nota Fiscal/Serie [<b>" + cDoc + "/"+ cSerie + "</b>].", "Não Permitido!")
			Return lRet
	   Endif
	Endif
     
	DbSelectArea("SF1")
	SF1->( DbSetorder(1)) //-- F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
	If SF1->(DbSeek(xFilial() + cDoc + cSerie + cCodForMM + cLojaForMM))
		FWAlertWarning("Já existe no sistema uma Pré-Nota gerada para esse número de Nota Fiscal/Série [<b>" + cDoc + "/"+ cSerie + "</b>].", "Não Permitido!")
		Return lRet
	EndIf

	DbSelectArea("SZB")
	SZB->( DbSetOrder(1) )
	If !SZB->(DbSeek(xFilial() + cDoc + cSerie + cCodForMM + cLojaForMM))
		FWAlertHelp("A Nota Fiscal/Série [<b>" + cDoc + "/"+ cSerie + "</b>] não existe na " + cTitulo +".", "Inclua primeiro a " + cTitulo + "!")
		Return lRet
	EndIf

	If SZB->ZB_STATUS == "E"
		FWAlertHelp("A Nota Fiscal/Série [<b>" + cDoc + "/"+ cSerie + "</b>] possui itens com produtos ainda não amarrados.", "Inclua primeiro a amarração na " + cTitulo + "!")
		Return lRet
	EndIf

	//-- Cabecalho da nota fiscal de entrada
	aAdd( aCabec, { "F1_TIPO"   , "N" } )
	aAdd( aCabec, { "F1_FORMUL" , "N" } )
	aAdd( aCabec, { "F1_DOC"    , cDoc } )
	aAdd( aCabec, { "F1_SERIE"  , cSerie } )
	aAdd( aCabec, { "F1_EMISSAO", dDataBase } )
	aAdd( aCabec, { "F1_FORNECE", cCodForMM } )
	aAdd( aCabec, { "F1_LOJA"   , cLojaForMM } )

	cChavSA2 := cCodForMM + cLojaForMM

	aAdd( aCabec, { "F1_ESPECIE", "SPED" } )

	SA2->( DbSetOrder(1) )
	If SA2->( DbSeek( xFilial("SA2") + cChavSA2 ) )
		aAdd( aCabec, { "F1_COND", SA2->A2_COND } )
		aAdd( aCabec, { "F1_EST", SA2->A2_EST } )
	Endif

	//-- Carrega dados do Cliente de Origem da Nota Fiscal - UPDEST09
	//aAdd( aCabec, { "F1_FILORIG", SD2->D2_FILIAL } )
	//aAdd( aCabec, { "F1_CLIORI" , SD2->D2_CLIENTE } )
	//aAdd( aCabec, { "F1_LOJAORI", SD2->D2_LOJA } )
	//aAdd( aCabec, { "F1_TPFRETE", SF2->F2_TPFRETE } )
	DbSelectArea("SB1")
	SB1->( DbSetOrder(1) )

	DbSelectArea("SZC")
	SZC->( DbSetOrder(1))
	SZC->( DbSeek( xFilial() + cDoc + cSerie + cCodForMM + cLojaForMM ) )
	//-- Itens da nota fiscal de entrada
	aItens   := {}
	While SZC->( !Eof() .And. ZC_FILIAL+ZC_DOC + ZC_SERIE + ZC_FORNEC + ZC_LOJA == xFilial() + cDoc + cSerie + cCodForMM + cLojaForMM )
		//-- Incrementa regua de processamento
		MsProcTxt( "Processando item [ " + SZC->ZC_ITEM + " ]..." )

		aLinha      := {}
		//nPosDAux    := 0

		nItem ++

		SB1->( DbSeek(xFilial() + SZC->ZC_COD) )

		//aAdd( aLinha, { "D1_ITEM"	, Strzero( Val( SZC->ZC_ITEM ), nTamIt ), Nil } )
		aAdd( aLinha, { "D1_ITEM"	, SZC->ZC_ITEM , Nil } )
		aAdd( aLinha, { "D1_COD"  	, SZC->ZC_COD, Nil } )
		aAdd( aLinha, { "D1_LOCAL"	, cArmzn, Nil } )
		aAdd( aLinha, { "D1_UM"     , SB1->B1_UM, Nil } )
		aAdd( aLinha, { "D1_QUANT"	, SZC->ZC_QUANT, Nil } )
		aAdd( aLinha, { "D1_VUNIT"  , SZC->ZC_VUNIT, Nil } )
		aAdd( aLinha, { "D1_TOTAL"  , SZC->ZC_TOTAL, Nil } )

		/*
		If aParam310[14] == 2
			//-- Nota Classificada
			aAdd( aLinha, { "D1_TES", aDadosTransf[IIf( nItem > Len( aDadosTransf ), Len( aDadosTransf ), nItem ), 24], Nil } )
		ElseIf aParam310[14] == 1
			//-- Nota a classificar
			aAdd( aLinha, { "D1_TESACLA", SubStr( aDadosTransf[IIf( nItem > Len( aDadosTransf ), Len( aDadosTransf ), nItem ), 24], 1, Len( "D1_TESACLA" ) ), Nil } )
		Endif
		*/

		//-- Checa se utiliza rastreabilidade
		If Rastro( SZC->ZC_COD )
			aAdd( aLinha, { "D1_LOTECTL", SZC->ZC_LOTECTL, Nil } )

			If Rastro( SZC->ZC_COD, "S" )
				aAdd( aLinha, { "D1_NUMLOTE", SZC->ZC_NUMLOTE, Nil } )
			EndIf

			aAdd( aLinha, { "D1_DTVALID", STOD("20491231"), Nil } )
			//aAdd( aLinha, { "D1_DFABRIC", SD2->D2_DFABRIC, Nil } )
		EndIf

		aAdd( aLinha, { "D1_LOTEFOR", SZC->ZC_LOTEFOR, Nil } )

		//If cPaisLoc == "BRA"
		//	aAdd( aLinha, { "D1_FCICOD", SD2->D2_FCICOD, Nil } )
		//EndIf

		// Tratamento para gravacao dos campos D1_BASNDES e D1_ICMNDES.
		// Mesmo tratamento feito no NFESEFAZ para impressao nas infos. complementares.
		//cFilAnt := aDadosTransf[nx, 01]

		//aAdd( aLinha, { "D1_CLASFIS", SD2->D2_CLASFIS, Nil } )
		//aAdd( aLinha, { "D1_POTENCI", SD2->D2_POTENCI, Nil } )
		aadd( aItens, aLinha )
		SZC->( DbSkip() )
	End

	//-- Classifica o aitens por item da SD2
	aSort( aItens, , , {|x,y| x[1,2] < y[1,2] } )

	//-- Caso tenha itens e cabecalho definidos
	If Len( aItens ) > 0 .And. Len( aCabec ) > 0
		//-- Atualiza para a filial destino
		//cFilAnt := aDadosTransf[ni-1, 06]

		//-- Reinicializa ambiente para o fiscal
		If MaFisFound()
			MaFisEnd()
		EndIf
		
		lMsErroAuto := .F.
		MsExecAuto( { |x, y, z| MATA140( x, y, z ) }, aCabec, aItens, 3 )

		//-- Checa erro de rotina automatica
		If lMsErroAuto
			lMostraErro	:=.T.
		EndIf

		If lMsErroAuto
			MostraErro()
			lRet := .F.
		Else
			lRet := .T.
			Reclock("SZB", .F.)
			SZB->ZB_STATUS	:= 'P'
			SZB->( MsUnlock() )
        	FWAlertSuccess("Sucesso ao gerar Pré-Nota.", "Sucesso Geração!")						
		EndIf

	EndIf

Return lRet


/*/{Protheus.doc} GetProdRps
Rotina que busca o codigo da Replas na Tabela de traducao de codigos DE/PARA
@type function
@version 1.0
@author DO THINK - DENER LEMOS
@since 30/03/2023
@param cProdMM, character, Produto da MM da Amazonia
@return character, Produto da Replas
/*/
Static Function GetProdRps(cProdMM)
	Local aAreaAnt := GetArea()
	Local cRet     := ""

	//-- Tabela de traducao de codigos DE/PARA
	DbSelectArea("SZ5")
	SZ5->(DbSetOrder(1))

	If SZ5->(DbSeek(xFilial("SZ5") + PadR(cProdMM, Len(SZ5->Z5_CODFOR))))
		cRet := SZ5->Z5_CODPRD
	EndIf

	If !Empty(cRet)
		DbSelectArea("SB1")
		SB1->(DbSetOrder(1))

		If !SB1->(DbSeek(xFilial("SB1") + PadR(cRet, Len(SB1->B1_COD))))
			cRet := ""
		EndIf
	EndIf

	RestArea(aAreaAnt)

Return cRet


//--
User Function resta03G()

	Local aPergs  := {}
	Local cArmzn  := Space(TamSX3("NNR_CODIGO")[1])

	aAdd(aPergs, {1, "Informe o Armazém", cArmzn , "@!", "", ".T.", , 10, .T.})

	If !ParamBox(aPergs, "Informe o Armazém para a Pré-Nota")
		Return
	EndIf

	cArmzn := AllTrim(MV_PAR01)

	If SZB->ZB_STATUS == "P"
		FWAlertWarning("Pré-Nota [<b>" + AllTrim(SZB->ZB_DOC) + "/"+ AllTrim(SZB->ZB_SERIE) + "</b>] já gerada.", "Já gerada!")
		Return	
	EndIf

	If SZB->ZB_STATUS == "E"
		FWAlertWarning("Existem itens sem amarração de produto da Replas, verifique essas amarrações antes de prosseguir.", "Não Permitido!")
		Return	
	EndIf

	//-- Faz a geracao da Pre-Nota
	If SZB->ZB_STATUS == "I"
		MsAguarde( { |lRet| lRet := GeraPre(SZB->ZB_DOC, SZB->ZB_SERIE, SZB->ZB_FORNEC, SZB->ZB_LOJA,cArmzn) }, "Aguarde...", "Gerando Pré-Nota...")
	EndIf

Return


/*/{Protheus.doc} resta03Y
Rotina que monta um parambox para usuario digitar nota e serie que sera importada
@type function
@version 1.0
@author Do Think - Marcos
@since 13/02/2024
@return variant, NIL
/*/
User Function resta03Y(nOpc)
	Local aPergs   := {}
	Local cFilOrig := GetMV("RE_FILORIG", .F., "0302")
	
	Private cNumDoc  := Space(TamSX3("F1_DOC")[1])
	Private cSerie   := Space(TamSX3("F1_SERIE")[1])	    	

	If cFilAnt # cFilOrig
		FWAlertError("Somente é permitido realizar a <b>" + cTitulo + "</b> na Filial [<b>" + cFilOrig + "</b>].", "Não Permitido!")
		Return
	EndIf

	If nOpc == 2
		cForIN := Space(TamSX3("F1_FORNECE")[1])
		cLjIN  := Space(TamSX3("F1_LOJA")[1])
	EndIf

	//aAdd(aPergs, {1, "Pedido", cPedido,  ""     , "Vazio() .or. existcpo('SC5')"        , "SC5", ".T.", 80,  .T.})

	//-- Perguntas principais da tela
	aAdd(aPergs, {1, "Nota Fiscal", cNumDoc , "@!", "AllwaysTrue()", ""   , ".T.", 70, .T.})
	aAdd(aPergs, {1, "Serie"      , cSerie  , "@!", "AllwaysTrue()", ""   , ".T.", 40, .T.})
	aAdd(aPergs, {1, "Fornecedor" , cForIN  , "@!", "AllwaysTrue()", "SA2", ".T.", 70, .T.}) 
	aAdd(aPergs, {1, "Loja"       , cLjIN   , "@!", "AllwaysTrue()", ""   , ".T.", 40, .T.})

	If ParamBox(aPergs, "Informe Nota e Serie")
		cNumDoc	:= AllTrim(MV_PAR01) + Space( TamSX3("F1_DOC")[1] - Len( AllTrim( MV_PAR01) ) )
		cSerie	:= AllTrim(MV_PAR02) + Space( TamSX3("F1_SERIE")[1] - Len( AllTrim( MV_PAR02) ) )
		cForIN	:= AllTrim(MV_PAR03) + Space( TamSX3("F1_FORNECE")[1] - Len( AllTrim( MV_PAR03) ) )
		cLjIN	:= AllTrim(MV_PAR04) + Space( TamSX3("F1_LOJA")[1] - Len( AllTrim( MV_PAR04) ) )

		If Empty( cNumDoc  ) .OR. Empty( cSerie  ) 
			FWAlertError( "Favor informar Documento e Serie !!!","Documento Invalido!" )		
		Else
			If SZB->( dbSeek( xFilial("SZB") + cNumDoc + cSerie + cForIN + cLjIN )) 
			   FWAlertError( "Ja Existe Registro na Base para Geracao da Pre-Nota para o Documento : " + cNumDoc + " - Serie : " + cSerie + " - Fornecedor : "+cForIN +"/"+ cLjIN +".","Documento Invalido!" )
			Else  
			   fGeraMKBW( cNumDoc, cSerie, cForIN, cLjIN, nOpc  )  
			Endif
        Endif
	EndIf

Return


Static Function fGeraMKBW( cNumDoc, cSerie, cForIN, cLjIN, nOpc  ) 
	local aArea     := GetArea()
	local oxDlg     := NIL
	local aColsMark := {}
	local aFldConj  := {}
    local cAlias    := GetNextAlias()
	local cQuery    := ""  
	local lRet      := .F.
	Local aRotBack  := {}

	aRotBack := aClone( aRotina )
	aRotina  := {}	  

	cTipProd 	 := GetSX3Cache("ZD_COD"  , "X3_TIPO")
	cPicProd     := GetSX3Cache("ZD_COD"  , "X3_PICTURE")
	nTamProd     := GetSX3Cache("ZD_COD"  , "X3_TAMANHO")
	nDecProd     := GetSX3Cache("ZD_COD"  , "X3_DECIMAL")	

	cTipDesc 	 := GetSX3Cache("B1_DESC"  , "X3_TIPO")
	cPicDesc     := GetSX3Cache("B1_DESC"  , "X3_PICTURE")
	nTamDesc     := GetSX3Cache("B1_DESC"  , "X3_TAMANHO")
	nDecDesc     := GetSX3Cache("B1_DESC"  , "X3_DECIMAL")	

	cTipCodF 	 := GetSX3Cache("Z5_CODFOR"  , "X3_TIPO")
	cPicCodF     := GetSX3Cache("Z5_CODFOR"  , "X3_PICTURE")
	nTamCodF     := GetSX3Cache("Z5_CODFOR"  , "X3_TAMANHO")
	nDecCodF     := GetSX3Cache("Z5_CODFOR"  , "X3_DECIMAL")

	cTipLtFo 	 := GetSX3Cache("ZD_LOTE"  , "X3_TIPO")
	cPicLtFo     := GetSX3Cache("ZD_LOTE"  , "X3_PICTURE")
	nTamLtFo     := GetSX3Cache("ZD_LOTE"  , "X3_TAMANHO")
	nDecLtFo     := GetSX3Cache("ZD_LOTE"  , "X3_DECIMAL")

	cTipQtd 	 := GetSX3Cache("ZD_QTD"  , "X3_TIPO")
	cPicQtd      := GetSX3Cache("ZD_QTD"  , "X3_PICTURE")
	nTamQtd      := GetSX3Cache("ZD_QTD"  , "X3_TAMANHO")
	nDecQtd      := GetSX3Cache("ZD_QTD"  , "X3_DECIMAL")		

  	//-- Tabela temporaria -- Campos da temporaria
    aAdd(aFldConj, {"OK"         , "C"        , 2         , 0        })
    aAdd(aFldConj, {"ZD_COD"     , cTipProd   , nTamProd  , nDecProd })
	aAdd(aFldConj, {"B1_DESC"    , cTipDesc   , nTamDesc  , nDecDesc })
    aAdd(aFldConj, {"Z5_CODFOR"  , cTipCodF   , nTamCodF  , nDecCodF })
 	aAdd(aFldConj, {"ZD_LOTE"    , cTipLtFo   , nTamLtFo  , nDecLtFo })
    aAdd(aFldConj, {"ZD_QTD"     , cTipQtd    , nTamQtd   , nDecQtd  })

    oTmpTable := FWTemporaryTable():New(cAlias)
    oTmptable:setFields(aFldConj)
    oTmpTable:addIndex("01", {"ZD_COD"})    
    oTmpTable:create()  

    //-- Tabela temporaria de conjugacao 
    dbSelectArea(cAlias)
    (cAlias)->(dbSetOrder(1))
    (cAlias)->(dbGoTop())	

	//-- Filtro para Selegco  
	If nOpc == 1
		cQuery := "SELECT B1_DESC,ZD.* " + CRLF
		cQuery += "FROM " + RetSqlName("SZD") + " ZD " + CRLF
		cQuery += "JOIN " + RetSqlName("SB1") + " B1 " + CRLF
		cQuery += "   ON B1.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "  AND B1.B1_COD = ZD.ZD_COD " + CRLF	
	Else
		cQuery := "SELECT ZD.* " + CRLF
		cQuery += "FROM " + RetSqlName("SZD") + " ZD " + CRLF
	EndIf
	cQuery += "WHERE ZD.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "AND ZD.ZD_FILIAL = '" + xFilial( "SZD" ) + "' " + CRLF
	cQuery += "AND ZD.ZD_DOC = ' ' " + CRLF
	cQuery += "AND ZD.ZD_SERIE = ' ' " + CRLF
	cQuery += "AND ZD.ZD_DFIM != ' ' " + CRLF	
	cQuery += "ORDER BY ZD_FILIAL,ZD_LOTE " + CRLF	

	cQuery := ChangeQuery(cQuery)
	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPSZD", .F., .T. )	

	If TMPSZD->( !Eof() )
       While TMPSZD->( !Eof() )
            RecLock( cAlias,  .T.)
				(cAlias)->ZD_COD     := TMPSZD->ZD_COD
				If nOpc == 1
					(cAlias)->B1_DESC    := TMPSZD->B1_DESC
				EndIf
				(cAlias)->Z5_CODFOR  := TMPSZD->ZD_CODINN
				(cAlias)->ZD_LOTE    := TMPSZD->ZD_LOTE
				(cAlias)->ZD_QTD     := TMPSZD->ZD_QTD
			(cAlias)->(MsUnlock())

			TMPSZD->( dbSkip() )	      
	   Enddo 
	Endif 
	TMPSZD->( dbCloseArea() )

	If (cAlias)->( !Eof())
		//-- Tabela temporaria construcao estrutura das colunas do FWMarkBrowse
		aColsMark    := axCols()

		oxDlg := FWDialogModal():New()
		oxDlg:setBackground(.T.)
		oxDlg:setEscClose(.F.)
		oxDlg:setSize(220, 520)
		oxDlg:setTitle("Importação de Bobinas - NF "+ AllTrim(cNumDoc) + "/" + AllTrim(cSerie))
		oxDlg:setSubTitle("Selecione as bobinas que deverão ser importadas")
		oxDlg:enableFormBar(.T.)
		oxDlg:createDialog()
		oxDlg:addButton("Continuar", {|| lRet := fGrvSZD(cAlias) , Iif(lRet, oxDlg:deactivate(), oxDlg)}, "Continuar",,.T.,.F.,.T.)
		oxDlg:setEscClose(.T.)
		oPnlGrid := oxDlg:getPanelMain()

		//-- MarkBrowse
		oMark := FWMarkBrowse():New()
		oMark:setAlias(cAlias)
		oMark:setFieldMark("OK")
		oMark:setTemporary(.T.)
		oMark:setColumns(aColsMark)
		oMark:setOwner(oPnlGrid)

		//oMark:disableFilter()
		oMark:disableConfig()
		oMark:disableReport()
		oMark:disableSeek()
		oMark:disableSaveConfig()
		oMark:SetMenuDef("")

		oMark:Activate()
		
		oxDlg:Activate()
	Else
	    FWAlertInfo( "Nenhum Registro disponivel para Importacao !!!", "Voltar")	
	Endif

	aRotina := aClone( aRotBack )
	RestArea( aArea )

Return


Static Function fGrvSZD( cAlias )
	local nAtual   := 0
	local cZC_ITEM := Strzero( 0, TamSX3( "ZC_ITEM" )[1] )
	local lFirst   := .T.
	local lxRet    := .T.
	//ZD_FILIAL +   ZD_CODINN +   ZD_LOTE  
	SZD->( dbSetOrder( 4 ))

    Begin Transaction

		(cAlias)->(dbGoTop())
		While (cAlias)->(!Eof())
			If !Empty((cAlias)->OK) 
				If lFirst 
					//-- Inclusao do cabecalho
					RecLock("SZB", .T.)
						SZB->ZB_FILIAL	:= xFilial( "SZD")
						SZB->ZB_DOC		:= cNumDoc
						SZB->ZB_SERIE	:= cSerie
						SZB->ZB_FORNEC	:= cForIN
						SZB->ZB_LOJA	:= cLjIN
						SZB->ZB_EMISSAO	:= Date()
						SZB->ZB_CHVNFE	:= "" //--cChvNfe
						SZB->ZB_DTINT	:= Date()
						SZB->ZB_HRINT	:= Time()
						SZB->ZB_USER	:= __cUserId
						SZB->ZB_STATUS	:= 'I'
					SZB->( MsUnlock() )
					lFirst := .F.
				Endif
				nAtual ++
				cZC_ITEM := Soma1( cZC_ITEM )
				RecLock("SZC", .T.)
					SZC->ZC_FILIAL	:= xFilial("SZD")
					SZC->ZC_DOC		:= cNumDoc
					SZC->ZC_SERIE	:= cSerie
					SZC->ZC_FORNEC	:= cForIN
					SZC->ZC_LOJA	:= cLjIN
					SZC->ZC_ITEM	:= cZC_ITEM
					SZC->ZC_CODFOR	:= (cAlias)->Z5_CODFOR
					SZC->ZC_COD		:= (cAlias)->ZD_COD
					SZC->ZC_QUANT	:= (cAlias)->ZD_QTD
					SZC->ZC_LOTECTL	:= (cAlias)->ZD_LOTE
					SZC->ZC_LOTEFOR	:= (cAlias)->ZD_LOTE
				SZC->( MsUnlock() )
				// Grava SZD
				nTamCODINN := GetSX3Cache("ZD_CODINN"  , "X3_TAMANHO")
                cxCodFor   := Alltrim((cAlias)->Z5_CODFOR) + Space( nTamCODINN - Len( Alltrim((cAlias)->Z5_CODFOR) ) )
				If SZD->( dbSeek( xFilial( "SZD") + cxCodFor + (cAlias)->ZD_LOTE  ) ) .AND. ;
					Empty( SZD->ZD_DOC ) .AND.  Empty( SZD->ZD_SERIE )
					RecLock("SZD", .F.)
						SZD->ZD_DOC   := cNumDoc
						SZD->ZD_SERIE := cSerie
					SZD->( MsUnlock() )
				Endif
			Endif	
			(cAlias)->( dbSkip() )
		Enddo

    End Transaction

	cMsgFim := ""
	If nAtual <> 0
		cMsgFim := "TOTAL DE REGISTROS PROCESSADOS = " + cValToChar(nAtual)  + CRLF
        FWAlertSuccess(cMsgFim, "Sucesso!")	
	Else 
	    FWAlertInfo( "Nenhum Registro Selecionado", "Voltar")					
	Endif

Return lxRet   


Static Function axCols()
    Local aConjCols := {}
    Local aStruct   := {}
    Local nX

    //-- Campos da temporaria de conjugacao do browse
    aAdd(aStruct, {"OK"        , ""               , "C"      , ""       , 2          , 0        })
    aAdd(aStruct, {"ZD_COD"    , "Csdigo"         , cTipProd , cPicProd , nTamProd   , nDecProd })
    aAdd(aStruct, {"B1_DESC"   , "Descricao"      , cTipDesc , cPicDesc , nTamDesc   , nDecDesc })
    aAdd(aStruct, {"Z5_CODFOR" , "Cod.Fornec"     , cTipCodF , cPicCodF  , nTamCodF  , nDecCodF })
    aAdd(aStruct, {"ZD_LOTE"   , "Lote Fornec"    , cTipLtFo , cPicLtFo  , nTamLtFo  , nDecLtFo })
    aAdd(aStruct, {"ZD_QTD"    , "Peso da Bobina" , cTipQtd  , cPicQtd   , nTamQtd   , nDecQtd })	

    For nX := 2 To Len(aStruct)    
        aAdd(aConjCols, FWBrwColumn():New())
        aConjCols[Len(aConjCols)]:setData(&("{||"+aStruct[nX,01]+"}"))
        aConjCols[Len(aConjCols)]:setTitle(aStruct[nX,02])
        aConjCols[Len(aConjCols)]:setType(aStruct[nX,03])
        aConjCols[Len(aConjCols)]:setPicture(aStruct[nX,04])
        aConjCols[Len(aConjCols)]:setSize(aStruct[nX,05])
        aConjCols[Len(aConjCols)]:setDecimal(aStruct[nX,06])
        aConjCols[Len(aConjCols)]:setAlign(Iif(aStruct[nX,03]=="N",CONTROL_ALIGN_RIGHT,CONTROL_ALIGN_LEFT))
    Next nX

Return aConjCols


/*/{Protheus.doc} resta03X
Rotina que monta um parambox para usuario digitar nota e serie que sera importada
@type function
@version 1.0
@author DO THINK - Marcos
@since 19/06/2023
/*/
User Function resta03X()
	Local aPergs   := {}
	Local cNumDoc  := Space(TamSX3("F1_DOC")[1])
	Local cSerie   := Space(TamSX3("F1_SERIE")[1])
	local cFilOrig := GetMV("RE_FILORIG", .F., "0302")    	

	If cFilAnt # cFilOrig
		FWAlertError("Somente é permitido realizar a <b>" + cTitulo + "</b> na Filial [<b>" + cFilOrig + "</b>].", "Não Permitido!")
		Return
	EndIf

	//-- Perguntas principais da tela
	aAdd(aPergs, {1, "Nota Fiscal", cNumDoc , "@!", "", ".T.", , 70, .T.})
	aAdd(aPergs, {1, "Série"      , cSerie  , "@!", "", ".T.", , 40, .T.})

	If ParamBox(aPergs, "Informe Nota e Série - INNOVA")
		cNumDoc	:= AllTrim(MV_PAR01) + Space( TamSX3("F1_DOC")[1] - Len( AllTrim( MV_PAR01) ) )
		cSerie	:= AllTrim(MV_PAR02) + Space( TamSX3("F1_SERIE")[1] - Len( AllTrim( MV_PAR02) ) )

		If Empty( cNumDoc  ) .OR. Empty( cSerie  ) 
		   FWAlertError( "Favor informar Documento e Serie !!!","Documento Inválido!" )		
		Else
			If SZB->( dbSeek( xFilial("SZB") + cNumDoc + cSerie + cForIN + cLjIN )) 
			   FWAlertError( "Ja Existe Registro na Base para Geracao da Pre-Nota para o Documento : " + cNumDoc + " - Serie : " + cSerie + " - Fornecedor : "+cForIN +"/"+ cLjIN +".","Documento Inválido!" )
			Else  
			   fGrvINNOVA( cNumDoc, cSerie, cForIN, cLjIN  )  
			Endif
        Endif
	EndIf

Return


Static Function fGrvINNOVA( cNumDoc, cSerie, cForIN, cLjIN  )  
	local aArea    := GetArea()
	local aAreaSZD := SZD->( GetArea() )
	local cZC_ITEM := Strzero( 0, TamSX3( "ZC_ITEM" )[1] )
	local nRegGrv  := 0

	SZD->( dbSetOrder( 1 ))  //--ZD_FILIAL + ZD_DOC + ZD_SERIE + ZD_CODBAR

	If SZD->( dbSeek( xFilial( "SZD") + cNumDoc + cSerie ))
		If Empty( SZD->ZD_DFIM )
			FWAlertInfo( "Recebimento nao Finalizado, Favor verificar !!!","Recebimento ")
			Return		   
		Endif

		//-- Inclusao do cabecalho
		RecLock("SZB", .T.)
		SZB->ZB_FILIAL	:= xFilial( "SZD")
		SZB->ZB_DOC		:= cNumDoc
		SZB->ZB_SERIE	:= cSerie
		SZB->ZB_FORNEC	:= cForIN
		SZB->ZB_LOJA	:= cLjIN
		SZB->ZB_EMISSAO	:= Date()
		SZB->ZB_CHVNFE	:= "" //--cChvNfe
		SZB->ZB_DTINT	:= Date()
		SZB->ZB_HRINT	:= Time()
		SZB->ZB_USER	:= __cUserId
		SZB->ZB_STATUS	:= 'I'
		SZB->( MsUnlock() )

		//-- Inclusao dos itens
		While SZD->( !Eof() ) .AND.;
			xFilial( "SZD") + cNumDoc + cSerie == SZD->ZD_FILIAL + SZD->ZD_DOC + SZD->ZD_SERIE
			nRegGrv ++
            cZC_ITEM := Soma1( cZC_ITEM )

			RecLock("SZC", .T.)
			SZC->ZC_FILIAL	:= xFilial("SZD")
			SZC->ZC_DOC		:= cNumDoc
			SZC->ZC_SERIE	:= cSerie
			SZC->ZC_FORNEC	:= cForIN
			SZC->ZC_LOJA	:= cLjIN
			SZC->ZC_ITEM	:= cZC_ITEM
			SZC->ZC_CODFOR	:= SZD->ZD_CODINN
		    SZC->ZC_COD		:= SZD->ZD_COD
			SZC->ZC_QUANT	:= SZD->ZD_QTD
			SZC->ZC_LOTECTL	:= SZD->ZD_LOTE
			SZC->( MsUnlock() )

			SZD->( dbSkip() )
		Enddo

		If nRegGrv > 0
			FWAlertSuccess( "Foram atualizados : "+alltrim(str(nRegGrv))+" registros.", "Sucesso na Inclusao !")		
		Endif

	Else
		FWAlertError( "Nao existe Registro na Base para Importacao do Documento : " + cNumDoc + " - Serie : " + cSerie + " - Fornecedor : "+cForIN +"/"+ cLjIN +".","Documento Inválido!" )	 
	EndIf

	RestArea( aAreaSZD )
	RestArea( aArea )

Return


Static Function IMPNFPostPreGrid(oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue)
    Local aArea    := GetArea()
 	Local lRet     := .T.
	//Local oViewAct := Nil
	//Local oMdlNF   := Nil
	Local nPosPrd  := 0 
	Local cCod	   := ""

    nPosPrd := aScan( oGridModel:aHeader,{|x| AllTrim(x[2]) == "ZC_COD" })	
	cCod	:= oGridModel:aDataModel[nLine][1][1][nPosPrd]

	If cAction == "SETVALUE" 
		If cIDField == "ZC_VUNIT" .AND. !IsInCallStack('SetaPrcUnit')
			//oViewAct := FwViewActive()
			//oMdlNF   := oViewAct:GetModel():GetModel("SZCDETAIL")
			SetaPrcUnit(oGridModel, xValue, "SZCDETAIL", nLine, cIDField )
		EndIf
	EndIf

    RestArea( aArea )

Return lRet


Static Function SetaPrcUnit( oGridModel, xValue, cModel, nLine, cIDField )
	local nX      := 1
	local nPosPrd := 0 
	local cCod	  := ""
	local lRet    := .T.
    local aSaveLine := {}	
	
    nPosPrd := aScan( oGridModel:aHeader,{|x| AllTrim(x[2]) == "ZC_COD" })	
	cCod	:= oGridModel:aDataModel[nLine][1][1][nPosPrd]

	If !Empty( cCod ) .And. xValue != 0 
	    If  FWAlertYesNo("Repete valor unitário Digitado para este Código ?", "Repete Valor unitário")
			For nx:= 1 TO oGridModel:Length()
				If oGridModel:aDataModel[nx][1][1][nPosPrd] == cCod
					oGridModel:SetValue("ZC_VUNIT",xValue )
				Endif
			Next nx 
		Endif	
		oGridModel:GoLine( nLine )
	Endif

	FwRestRows( aSaveLine )	

Return lRet


Static Function fVerPrcUnit( cDoc, cSerie, cCodFor, cLojaFor  )
	local lxRet := .T.
	local cQuery := ""

	cQuery := " SELECT ZC_VUNIT " + CRLF
	cQuery += " FROM " + RetSqlName("SZC") + " ZC " + CRLF
	cQuery += " WHERE ZC.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += " AND ZC.ZC_FILIAL = '" + xFilial("SZC") + "' " + CRLF
	cQuery += " AND ZC.ZC_DOC = '" + cDoc + "' " + CRLF
	cQuery += " AND ZC.ZC_SERIE = '" + cSerie + "' " + CRLF
	cQuery += " AND ZC.ZC_FORNEC = '" + cCodFor + "' " + CRLF
	cQuery += " AND ZC.ZC_LOJA = '" + cLojaFor + "' " + CRLF
	cQuery += " AND ZC.ZC_VUNIT = 0 " + CRLF

	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPSZC", .F., .T. )

	If 	TMPSZC->( !Eof() )
		lxRet := .F.	  
	Endif

    TMPSZC->( dbCloseArea() )

Return lxRet 


//--
User Function resta03M()
	Local aParam     := PARAMIXB
	Local xRet       := .T.
	Local oObj       := ''
	Local cIdPonto   := ''
	Local cIdModel   := ''
	Local cMsg       := ''

	If aParam <> Nil
		oObj     := aParam[1]
		cIdPonto := aParam[2]
		cIdModel := aParam[3]

		If cIdPonto == 'MODELPOS'
			cMsg := 'Chamada na validação total do modelo (MODELPOS). ID ' + cIdModel + CRLF
			
		ElseIf cIdPonto == 'FORMPOS'
			cMsg := 'Chamada na validação total do formulário (FORMPOS). ID ' + cIdModel + CRLF
			
		ElseIf cIdPonto == 'FORMLINEPRE'
			If oObj:getOperation() == MODEL_OPERATION_DELETE
				cMsg := 'Chamada na pre validação da linha do formulário (FORMLINEPRE).' + CRLF
			EndIf
		ElseIf cIdPonto == 'FORMLINEPOS'
			cMsg := 'Chamada na validação da linha do formulário (FORMLINEPOS).' + 'ID ' + cIdModel + CRLF

		ElseIf cIdPonto == 'MODELCOMMITTTS'
			cMsg := 'Chamada apos a gravação total do modelo e dentro da transação (MODELCOMMITTTS).' + CRLF + 'ID ' + cIdModel

			If oObj:getOperation() == MODEL_OPERATION_DELETE
				If tcsqlexec("UPDATE " + RetSqlName("SZD") + " SET ZD_DOC = ' ', ZD_SERIE = ' ' WHERE ZD_DOC = '"+oObj:getModel("SZBMASTER"):getValue("ZB_DOC")+"' AND D_E_L_E_T_ = ' '") < 0
					ShowLog(tcsqlerror())
					xRet := .F.
				EndIf
			EndIf
		ElseIf cIdPonto == 'MODELCOMMITNTTS'
			cMsg := 'Chamada apos a gravação total do modelo e fora da transação (MODELCOMMITNTTS).' + CRLF + 'ID ' + cIdModel
				
		ElseIf cIdPonto == 'FORMCOMMITTTSPRE'
			cMsg := 'Pré validações do Commit'
				
		ElseIf cIdPonto == 'FORMCOMMITTTSPOS'
			cMsg := 'Chamada apos a gravação da tabela do formulário (FORMCOMMITTTSPOS).' + CRLF + 'ID ' + cIdModel
				
		ElseIf cIdPonto == 'MODELCANCEL'
			cMsg := 'Chamada no Botão Cancelar (MODELCANCEL).' + CRLF + 'Deseja Realmente Sair ?'
				
		ElseIf cIdPonto == 'BUTTONBAR'
			cMsg := 'Adicionando Botao na Barra de Botoes (BUTTONBAR).' + CRLF + 'ID ' + cIdModel
				
		EndIf
	EndIf

Return xRet


//--
Static Function ExistDocEntr()
    Local cFilOrig := GetMV("RE_FILORIG", .F., "0302")
	//Local cFilDest := GetMV("RE_FILDEST", .F., "0201")
    Local cQuery   := ""
	Local lRet     := .F.

    If Select("_QRY") > 0
        _QRY->(dbCloseArea())
    EndIf

	cQuery := " SELECT COUNT(1) QTD "
	cQuery += " FROM " + RetSQLName("SF1") + " SF1 "
	cQuery += " WHERE SF1.F1_FILIAL = '" + cFilOrig + "' "
	cQuery += " AND SF1.F1_DOC = '" + SZB->ZB_DOC + "' "
	cQuery += " AND SF1.F1_SERIE = '" + SZB->ZB_SERIE + "' "
	cQuery += " AND SF1.F1_FORNECE = '" + SZB->ZB_FORNEC + "' "
	cQuery += " AND SF1.F1_LOJA = '" + SZB->ZB_LOJA + "' "
	cQuery += " AND SF1.D_E_L_E_T_ = ' ' "

    cQuery := ChangeQuery(cQuery)
    TCQUERY cQuery New Alias "_QRY"

    _QRY->(dbGoTop())
    lRet := _QRY->(!EoF()) .And. _QRY->QTD > 0

    If Select("_QRY") > 0
        _QRY->(dbCloseArea())
    EndIf

Return lRet
