//Bibliotecas
#Include "Totvs.ch"
#Include "FWMVCDef.ch"

//Variveis Estaticas
Static cTitulo    := "Cadastro dos indices KG/MM"
Static cCamposChv := "ZI_ID     ;"
Static cTabPai    := "SZI"

/*/{Protheus.doc} User Function dtpla01
Cadastro dos indices KG/MM - Filmes
@author ERIKE YURI DA SILVA
@since 21/11/2024
@version 1.0
@type function
/*/

User Function REESTA23()
	Local aArea   := FWGetArea()
	Local oBrowse
	//Private aRotina := {}

	//Definicao do menu
	//aRotina := MenuDef()

	//Instanciando o browse
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias(cTabPai)
	oBrowse:SetDescription(cTitulo)
    oBrowse:setMenuDef("REESTA23")

	//Ativa a Browse
	oBrowse:Activate()

	FWRestArea(aArea)


    oBrowse := FWMBrowse():new()
    oBrowse:setAlias("ZZE")
    oBrowse:setDescription("Plano de Corte")
    oBrowse:setMenuDef("REESTA23")
    oBrowse:disableDetails()
    oBrowse:disableReport()
    oBrowse:activate()

Return Nil

/*/{Protheus.doc} MenuDef
Menu de opcoes na funcao REESTA23
@author ERIKE YURI DA SILVA
@since 21/11/2024
@version 1.0
@type function
/*/

Static Function MenuDef()
	Local aRotina := {}

	//Adicionando opcoes do menu
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.REESTA23" OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir" ACTION "VIEWDEF.REESTA23" OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar" ACTION "VIEWDEF.REESTA23" OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir" ACTION "VIEWDEF.REESTA23" OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE "Copiar" ACTION "VIEWDEF.REESTA23" OPERATION 9 ACCESS 0

Return aRotina

/*/{Protheus.doc} ModelDef
Modelo de dados na funcao REESTA23
@author ERIKE YURI DA SILVA
@since 21/11/2024
@version 1.0
@type function
/*/

Static Function ModelDef()
	Local oStruPai   := FWFormStruct(1, cTabPai, {|cCampo| Alltrim(cCampo) $ cCamposChv})
	Local oStruFilho := FWFormStruct(1, cTabPai)
	Local aRelation := {}
	Local oModel
	Local bPre := Nil
	Local bPos := Nil
	Local bCancel := Nil


	//Cria o modelo de dados para cadastro
	oModel := MPFormModel():New("REESTA23M", bPre, bPos, /*bCommit*/, bCancel)
	oModel:AddFields("ZZIMASTER", /*cOwner*/, oStruPai)
	oModel:AddGrid("ZZIDETAIL","ZZIMASTER",oStruFilho,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)
	oModel:SetDescription("Modelo de dados - " + cTitulo)
	oModel:GetModel("ZZIMASTER"):SetDescription( "Dados de - " + cTitulo)
	oModel:GetModel("ZZIDETAIL"):SetDescription( "Grid de - " + cTitulo)
	oModel:SetPrimaryKey({})

	//Fazendo o relacionamento
	aAdd(aRelation, {"ZZI_FILIAL", "FWxFilial('ZZI')"} )
	aAdd(aRelation, {"ZZI_ID", "ZI_ID"})
	oModel:SetRelation("ZZIDETAIL", aRelation, SZI->(IndexKey(1)))
	
	//Definindo campos unicos da linha
	oModel:GetModel("ZZIDETAIL"):SetUniqueLine({'ZZI_AGRUP', 'ZZI_DIAM', 'ZZI_POL', 'ZZI_VALOR'})

Return oModel

/*/{Protheus.doc} ViewDef
Visualizacao de dados na funcao dtpla01
@author ERIKE YURI DA SILVA
@since 21/11/2024
@version 1.0
@type function
/*/

Static Function ViewDef()
	Local oModel     := FWLoadModel("REESTA23")
	Local oStruPai   := FWFormStruct(2, cTabPai, {|cCampo| Alltrim(cCampo) $ cCamposChv})
	Local oStruFilho := FWFormStruct(2, cTabPai, {|cCampo| ! Alltrim(cCampo) $ cCamposChv})
	Local oView

	//Cria a visualizacao do cadastro
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("VIEW_ZZI", oStruPai, "ZZIMASTER")
	oView:AddGrid("GRID_ZZI",  oStruFilho,  "ZZIDETAIL")

	//Partes da tela
	oView:CreateHorizontalBox("CABEC", 30)
	oView:CreateHorizontalBox("GRID", 70)
	oView:SetOwnerView("VIEW_ZZI", "CABEC")
	oView:SetOwnerView("GRID_ZZI", "GRID")

	//Titulos
	oView:EnableTitleView("VIEW_ZZI", "Cabecalho - ZZI")
	oView:EnableTitleView("GRID_ZZI", "Grid - ZZI")

Return oView
