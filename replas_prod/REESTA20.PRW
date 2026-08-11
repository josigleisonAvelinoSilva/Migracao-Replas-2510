#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWEDITPANEL.CH"
#INCLUDE "TOPCONN.CH"


#DEFINE cFolderA "FOLDER5"
#DEFINE cFolderF "FOLDER6"


//--
User Function REESTA20()
    Local oBrowse := Nil

    oBrowse := FWMBrowse():new()
    oBrowse:setAlias("ZZE")
    oBrowse:setDescription("Plano de Corte")
    oBrowse:setMenuDef("REESTA20")
    //oBrowse:setFilterDefault("@B1_FILIAL = '" + xFIlial("ZZE") + "' AND B1_TIPO IN ('PA','PI') AND B1_MODELO <> ' '")
    //oBrowse:setTotalDefault("B1_COD", "COUNT", "Total de Códigos")
    //oBrowse:setOnlyFields({"B1_COD", "B1_MODELO", "B1_DESC", "B1_TIPO", "B1_UM", "B1_LOCPAD", "B1_POSIPI", "B1_XDCRE", "B1_XDTINC", "B1_XUSRINC"})
    //oBrowse:setParam({|| })
    //oBrowse:setDoubleClick({|| __SXBCdNNI := NNI->NNI_CODIGO, oDlg:End()})
    oBrowse:disableDetails()
    oBrowse:disableReport()
    oBrowse:activate()

Return


//--
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.REESTA20" OPERATION OP_INCLUIR    ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.REESTA20" OPERATION OP_VISUALIZAR ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.REESTA20" OPERATION OP_ALTERAR    ACCESS 0
	ADD OPTION aRotina TITLE "Excluir" 	  ACTION "VIEWDEF.REESTA20" OPERATION OP_EXCLUIR    ACCESS 0

Return aRotina


//--
Static Function ModelDef()
    Local oModel    := Nil
	Local oStruPlan := FWFormStruct(1, "ZZE") //-- Plano de Corte
	Local oStruDem  := FWFormStruct(1, "ZZF") //-- Demanda do Plano de Corte
    Local oStruEst  := FWFormStruct(1, "ZZG") //-- Estoque do Plano de Corte
    Local oStruRLay := FWFormStruct(1, "ZZH", {|cCampo| AllTrim(cCampo)+"," $ "ZZH_FILIAL,ZZH_COD,ZZH_LAYOUT,ZZH_REPET,ZZH_LARGES,"}) //-- Resultado do Plano de Corte - Layout
    Local oStruRCor := FWFormStruct(1, "ZZH") //-- Resultado do Plano de Corte - Corte
    Local bLoadLay  := {|oLayModel| LoadLay(oLayModel)}

	oModel := MPFormModel():New("XREESTA20", /*bPre*/, /*bPos*/, /*bCommit*/, /*bCancel*/)

	oModel:addFields("M_PLAN", /*cOwner*/, oStruPlan)
    oModel:getModel("M_PLAN"):setDescription("Plano de Corte")

	oModel:addGrid("M_DEM", "M_PLAN", oStruDem, /*bLinePre*/, /*bLinePost*/, /*bPre - Grid Inteiro*/, /*bPos - Grid Inteiro*/, /*bLoad - Carga do modelo manualmente*/)
    oModel:getModel("M_DEM"):setDescription("Demanda do Plano de Corte")
    oModel:setRelation("M_DEM", {{"ZZF_FILIAL", "xFilial('ZZF')"}, {"ZZF_COD", "ZZE_COD"}}, ZZF->(IndexKey(1)))

    oModel:addGrid("M_EST", "M_PLAN", oStruEst, /*bLinePre*/, /*bLinePost*/, /*bPre - Grid Inteiro*/, /*bPos - Grid Inteiro*/, /*bLoad - Carga do modelo manualmente*/)
    oModel:getModel("M_EST"):setDescription("Estoque do Plano de Corte")
    oModel:setRelation("M_EST", {{"ZZG_FILIAL", "xFilial('ZZG')"}, {"ZZG_COD", "ZZE_COD"}}, ZZG->(IndexKey(1)))

    oModel:addGrid("M_RLAY", "M_PLAN", oStruRLay, /*bLinePre*/, /*bLinePost*/, /*bPre - Grid Inteiro*/, /*bPos - Grid Inteiro*/, bLoadLay /*Carga do modelo manualmente*/)
    oModel:getModel("M_RLAY"):setDescription("Resultado do Plano de Corte - Layout")
    oModel:setRelation("M_RLAY", {{"ZZH_FILIAL", "xFilial('ZZH')"}, {"ZZH_COD", "ZZE_COD"}}, ZZH->(IndexKey(1)))

    oModel:addGrid("M_RCOR", "M_RLAY", oStruRCor, /*bLinePre*/, /*bLinePost*/, /*bPre - Grid Inteiro*/, /*bPos - Grid Inteiro*/, /*bLoad - Carga do modelo manualmente*/)
    oModel:getModel("M_RCOR"):setDescription("Resultado do Plano de Corte - Corte")
    oModel:setRelation("M_RCOR", {{"ZZH_FILIAL", "xFilial('ZZH')"}, {"ZZH_COD", "ZZE_COD"}, {"ZZH_COD", "ZZH_COD"}, {"ZZH_LAYOUT", "ZZH_LAYOUT"}}, ZZH->(IndexKey(1)))

    //-- Resultado Totalizadores
    oModel:addCalc("RLAY_TOTAIS", "M_PLAN", "M_RLAY", "ZZH_LAYOUT", "XX_LAYOUT", "COUNT", {|| .T.},, "Layout ID")
    oModel:addCalc("RLAY_TOTAIS", "M_PLAN", "M_RLAY", "ZZH_REPET", "XX_REPET", "SUM", {|| .T.},, "Repeticao")
    oModel:addCalc("RCOR_TOTAIS", "M_RLAY", "M_RCOR", "ZZH_LARGCO", "XX_LARGCOR", "FORMULA",,, "Largura Corte (mm)", {|oModel,nTotalAtual,xValor,lSomando| SumLargCor(oModel,nTotalAtual,xValor,lSomando)})
    oModel:addCalc("RCOR_TOTAIS", "M_RLAY", "M_RCOR", "ZZH_QTDCOR", "XX_QTDCORT", "SUM", {|| .T.},, "Qtde. Corte")
    oModel:addCalc("RCOR_TOTAIS", "M_RLAY", "M_RCOR", "ZZH_LARGCO", "XX_RLARGEST", "FORMULA",,, "Resto (mm)", {|oModel,nTotalAtual,xValor,lSomando| RestoLargEst(oModel,nTotalAtual,xValor,lSomando)})

	oModel:setPrimaryKey({})

Return oModel


//--
Static Function ViewDef()
	Local oView       := Nil
    Local oModel      := ModelDef()
	Local oStruPlan   := FWFormStruct(2, "ZZE", {|cCampo| !AllTrim(cCampo)+"," $ "ZZE_SOLUC, ZZE_DATA, ZZE_HORA,"})
	Local oStruDem    := FWFormStruct(2, "ZZF", {|cCampo| !AllTrim(cCampo)+"," $ "ZZF_COD,"})
    Local oStruEst    := FWFormStruct(2, "ZZG", {|cCampo| !AllTrim(cCampo)+"," $ "ZZG_COD,"})    
    Local oStruRLay   := FWFormStruct(2, "ZZH", {|cCampo| AllTrim(cCampo)+"," $ "ZZH_LAYOUT, ZZH_REPET, ZZH_LARGES,"}) //-- Resultado do Plano de Corte - Layout
    Local oStruRCor   := FWFormStruct(2, "ZZH", {|cCampo| AllTrim(cCampo)+"," $ "ZZH_ITCORT, ZZH_LARGCO, ZZH_QTDCOR, ZZH_LABEL,"}) //-- Resultado do Plano de Corte - Corte
    Local oStrTotRLay := FWCalcStruct(oModel:getModel("RLAY_TOTAIS"))
    Local oStrTotRCor := FWCalcStruct(oModel:getModel("RCOR_TOTAIS"))

	oView := FWFormView():new()
	oView:setModel(oModel)

	oView:addField("V_PLAN", oStruPlan, "M_PLAN")
	oView:addGrid("V_DEM", oStruDem, "M_DEM")
    oView:addGrid("V_EST", oStruEst, "M_EST")
    oView:addGrid("V_RLAY", oStruRLay, "M_RLAY")
    oView:addGrid("V_RCOR", oStruRCor, "M_RCOR")
    oView:addField("RLAY_TOT_VIEW", oStrTotRLay, "RLAY_TOTAIS")
    oView:addField("RCOR_TOT_VIEW", oStrTotRCor, "RCOR_TOTAIS")

	oView:createHorizontalBox("PLANO", 15)
	oView:createHorizontalBox("DADOS", 85)

	oView:createFolder("ABAS", "DADOS")
	oView:addSheet("ABAS", "ABA_DEM", "&DEMANDA")
    oView:addSheet("ABAS", "ABA_EST", "&ESTOQUE")
    oView:addSheet("ABAS", "ABA_RES", "&RESULTADO")

	oView:createHorizontalBox("DEMANDA", 100,,, "ABAS", "ABA_DEM")
	oView:createHorizontalBox("ESTOQUE", 100,,, "ABAS", "ABA_EST")
    oView:createHorizontalBox("RESULTADO", 80,,, "ABAS", "ABA_RES")
    oView:createHorizontalBox("RES_BOX_TOTAL", 20,,, "ABAS", "ABA_RES")

	oView:createVerticalBox("RES_ESQ", 35, "RESULTADO",, "ABAS", "ABA_RES")
	oView:createVerticalBox("RES_DIR", 65, "RESULTADO",, "ABAS", "ABA_RES")
	oView:createVerticalBox("RES_ESQ_TOT", 35, "RES_BOX_TOTAL",, "ABAS", "ABA_RES")
	oView:createVerticalBox("RES_DIR_TOT", 65, "RES_BOX_TOTAL",, "ABAS", "ABA_RES")
    
	oView:setOwnerView("V_PLAN", "PLANO")
	oView:setOwnerView("V_DEM", "DEMANDA")
    oView:setOwnerView("V_EST", "ESTOQUE")
    oView:setOwnerView("V_RLAY", "RES_ESQ")
    oView:setOwnerView("V_RCOR", "RES_DIR")
    oView:setOwnerView("RLAY_TOT_VIEW", "RES_ESQ_TOT")
    oView:setOwnerView("RCOR_TOT_VIEW", "RES_DIR_TOT")

    oView:addIncrementField("V_DEM", "ZZF_ITEM")
	oView:addIncrementField("V_EST", "ZZG_ITEM")
    oView:addIncrementField("V_RCOR", "ZZH_ITCORT")

	oView:setProgressBar(.T.)
    oView:setViewProperty("*", "GRIDNOORDER")

    //-- Desabilitar o botao "Salvar e Criar Novo"
    oView:setCloseOnOK({|| .T.})

	//-- Eventos de ativacao da View
	oView:setAfterViewActivate({|oView| AfterView(oView)})

    //-- Botao para Otimizacao de Corte
    oView:addUserButton("Otimizar [F6]", "", {|oView| Otimizar(oView)}, "Executa Otmização de Corte (https://www.opticutter.com/)",, {MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE}, .T.)

	oStruDem:setProperty("ZZF_ITEM", MVC_VIEW_TITULO, "#")
    oStruDem:setProperty("ZZF_PRODUT", MVC_VIEW_TITULO, "Produto Demanda")
    oStruDem:setProperty("ZZF_DIAMIN", MVC_VIEW_TITULO, "Ø Interno (in)")
    oStruDem:setProperty("ZZF_DIAMEX", MVC_VIEW_TITULO, "Ø Externo (mm)")
    oStruDem:setProperty("ZZF_LARG", MVC_VIEW_TITULO, "Largura (mm)")
    oStruDem:setProperty("ZZF_QTDDEM", MVC_VIEW_TITULO, "Qtd. Demanda (Kg)")
    oStruDem:setProperty("ZZF_PESOUN", MVC_VIEW_TITULO, "Peso Unitario (Kg)")

    oStruEst:setProperty("ZZG_ITEM", MVC_VIEW_TITULO, "#")
    oStruEst:setProperty("ZZG_PRODUT", MVC_VIEW_TITULO, "Produto Estoque")
    oStruEst:setProperty("ZZG_DIAMIN", MVC_VIEW_TITULO, "Ø Interno (in)")
    oStruEst:setProperty("ZZG_DIAMEX", MVC_VIEW_TITULO, "Ø Externo (mm)")
    oStruEst:setProperty("ZZG_LARG", MVC_VIEW_TITULO, "Largura (mm)")

    oStruRLay:setProperty("ZZH_LARGES", MVC_VIEW_TITULO, "Largura Estoque (mm)")

    oStruRCor:setProperty("ZZH_ITCORT", MVC_VIEW_TITULO, "#")
    oStruRCor:setProperty("ZZH_LARGCO", MVC_VIEW_TITULO, "Largura Corte (mm)")

Return oView


//--
Static Function LoadLay(oLayModel)
	Local aAreaAnt  := GetArea()
	Local aFields   := oLayModel:oFormModelStruct:aFields
    Local aLoad     := {}
	Local aDadAux   := {}
    Local cQuery    := ""
	Local cAliasQry := ""
    Local nZ        := 0

    cQuery := "SELECT ZZH_FILIAL,ZZH_COD,ZZH_LAYOUT,ZZH_REPET,ZZH_LARGES"
    cQuery += "FROM " + RetSQLName("ZZH") + ""
    cQuery += "WHERE ZZH_FILIAL = '" + xFilial("ZZH") + "'"
    cQuery += "AND ZZH_COD = '" + ZZE->ZZE_COD + "'"
    cQuery += "AND D_E_L_E_T_ = ' '"
    cQuery += "GROUP BY ZZH_FILIAL,ZZH_COD,ZZH_LAYOUT,ZZH_REPET,ZZH_LARGES"
    cQuery += "ORDER BY ZZH_FILIAL,ZZH_COD,ZZH_LAYOUT"

    cQuery := ChangeQuery(cQuery)

    //-- Executa query
    cAliasQry := MPSysOpenQuery(cQuery)

    //-- Laco de carga dos dados
    While (cAliasQry)->(!EoF())
        aDadAux := {}

        //-- Carrega os campos dinamicamente
        For nZ := 1 To Len(aFields)
            aAdd(aDadAux, &("(cAliasQry)->" + aFields[nZ, 03]))
        Next nZ

        //-- Carrega os dados
        aAdd(aLoad, {0, aClone(aDadAux)})

        (cAliasQry)->(dbSkip())
    EndDo

	(cAliasQry)->(dbCloseArea())

	RestArea(aAreaAnt)

Return aLoad


//--
Static Function SumLargCor(oModel,nTotalAtual,xValor,lSomando)
    Local oModelCor := oModel:getModel("M_RCOR")

    nTotalAtual += (xValor * oModelCor:getValue("ZZH_QTDCOR"))

Return nTotalAtual


//--
Static Function RestoLargEst(oModel,nTotalAtual,xValor,lSomando)
    Local oModelCor   := oModel:getModel("M_RCOR")
    Local oModelTot   := oModel:getModel("RCOR_TOTAIS")
    Local nLargCorAtu := oModelTot:getValue("XX_LARGCOR")

    nTotalAtual := (oModelCor:getValue("ZZH_LARGES") - nLargCorAtu)

Return nTotalAtual


/*/{Protheus.doc} afterView
Rotina executada apos a ativacao da view
@type function
@version 1.0  
@author DO THINK - Dener Lemos
@since 14/10/2024
@param oView, object, View
/*/
Static Function afterView(oView)
	SetKey(VK_F6, {|| Otimizar(oView)})
Return


//--
Static Function Otimizar(oView)
    Local oModel := oView:GetModel()

    If VldOtimiz()
        //-- API de Otimizacao de Corte do site "https://www.opticutter.com/"
        MsgRun("Otimizando Corte...", "", {|| U_REESTA21(oModel, oView)})
    EndIf

Return


//--
Static Function VldOtimiz()


Return .T.
