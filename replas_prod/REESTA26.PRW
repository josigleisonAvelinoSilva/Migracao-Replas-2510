#include "totvs.ch"
#include "fwmvcdef.ch"
#include "fwmbrowse.ch"
#include "fweditpanel.ch"
#include "topconn.ch"


#define STRUCT_MODEL 1
#define STRUCT_VIEW 2
#define TABLE_SZ7 "SZ7"
#define TABLE_SB7 "SB7"
#define ID_CABEC_SZ7 "SZ7MASTER"
#define ID_GRID_SZ7 "SZ7DETAIL"
#define ID_GRID_SB7 "SB7DETAIL"
#define MVC_TITLE "Inventário Filmes"
#define MVC_VIEWDEF_NAME "VIEWDEF.REESTA26"
#define OP_INC "INC"   //-- Incluir
#define OP_ALT "ALT"   //-- Alterar
#define OP_FIM "FIM"   //-- Finalizar
#define OP_PROC "PROC" //-- Processar


//--
User Function REESTA26()
	Local oBrowse := Nil

	oBrowse := FWmBrowse():new()
	oBrowse:setAlias(TABLE_SZ7)
	oBrowse:setMenuDef("REESTA26")
	oBrowse:setDescription(MVC_TITLE)
	oBrowse:setTotalDefault("Z7_DOCINV","COUNT","Total de Registros")
	oBrowse:addLegend("Alltrim(SZ7->Z7_STATUS)=='1'", "BR_LARANJA" , "Contado")
	oBrowse:addLegend("Alltrim(SZ7->Z7_STATUS)=='2'", "BR_AZUL"    , "Finalizado")
	oBrowse:addLegend("Alltrim(SZ7->Z7_STATUS)=='3'", "BR_VERMELHO", "Processado")
    oBrowse:addLegend("Alltrim(SZ7->Z7_STATUS)=='4'", "BR_CINZA", "Realizado Carga Inicial")
    //oBrowse:setTimer({|| oBrowse:Refresh(.T.)}, 60000 * 5) //-- Tempo de atulizacao do browse do "5 minutos"
	oBrowse:disableDetails()
	//oBrowse:disableReport()

    //-- Ordenacao do botoes na tela
    oBrowse:lOptionConfig := .F.
    //aAdd(oBrowse:aButtonsOrder, "Incluir")
    aAdd(oBrowse:aButtonsOrder, "Alterar")
    aAdd(oBrowse:aButtonsOrder, "Visualizar")
    aAdd(oBrowse:aButtonsOrder, "Excluir")
    aAdd(oBrowse:aButtonsOrder, "Finalizar Contagem")
    aAdd(oBrowse:aButtonsOrder, "Processar Inventário (SB7)")
    
	oBrowse:activate()

Return


//--
Static Function MenuDef()
	Local aRotina := {}

	//ADD OPTION aRotina TITLE "Incluir"                    ACTION "U_RESTA26I" OPERATION MODEL_OPERATION_INSERT ACCESS 0 ID OP_INC
    ADD OPTION aRotina TITLE "Alterar"                    ACTION "U_RESTA26A" OPERATION MODEL_OPERATION_UPDATE ACCESS 0 ID OP_ALT
	ADD OPTION aRotina TITLE "Visualizar"                 ACTION MVC_VIEWDEF_NAME OPERATION MODEL_OPERATION_VIEW ACCESS 0
	ADD OPTION aRotina TITLE "Excluir" 	                  ACTION "U_RESTA26E" OPERATION MODEL_OPERATION_DELETE ACCESS 0
    ADD OPTION aRotina TITLE "Finalizar Contagem"         ACTION "U_RESTA26F" OPERATION 7 ACCESS 0 ID OP_FIM
    ADD OPTION aRotina TITLE "Processar Inventário (SB7)" ACTION "U_RESTA26P" OPERATION 7 ACCESS 0 ID OP_PROC
    Add Option aRotina TITLE "Carga Inicial"              Action "U_RESTA26W()" OPERATION MODEL_OPERATION_INSERT ACCESS 0
    //ADD OPTION aRotina TITLE "Validar não Contados" 	  ACTION "U_RESTA26V" OPERATION MODEL_OPERATION_UPDATE ACCESS 0
    
Return aRotina


//--
Static Function ModelDef()
    Local oStruTMP  := Nil
	Local oStruSZ7  := FWFormStruct(STRUCT_MODEL, TABLE_SZ7)
    Local oStruSB7  := FWFormStruct(STRUCT_MODEL, TABLE_SB7)
	Local oModel    := Nil
	Local lObrigat  := .T.
	Local lVirtual  := .F.
	Local lNoUpd    := .F.
	Local lKey      := .F.
	Local bCommit   := {|oModel| Commit(@oModel)}
    Local bPosValid := {|oModel| ActiveMod(oModel, 1)}
	Local bLoad     := {|oModel, lCopy| LoadHead(@oModel, lCopy)}
    Local lIncInv   := Type("cOpIdInc" )=="C" .And. cOpIdInc == OP_INC
    Local lAltInv   := Type("cOpIdAlt" )=="C" .And. cOpIdAlt == OP_ALT
    Local lProcInv  := Type("cOpIdProc" )=="C" .And. cOpIdProc == OP_PROC

	//-- Criando estrutura fake de field para o cabecalho
	oStruTMP := FWFormModelStruct():new()
	oStruTMP:addTable("", {"C_STRING1"}, MVC_TITLE, {|| ""})

	oStruTMP:addField(  Alltrim(GetSx3Cache("Z7_FILIAL","X3_TITULO")),;
                        Alltrim(GetSx3Cache("Z7_FILIAL","X3_DESCRIC")),;
                        Alltrim(GetSx3Cache("Z7_FILIAL","X3_CAMPO")),;
                        Alltrim(GetSx3Cache("Z7_FILIAL","X3_TIPO")),;
                        GetSx3Cache("Z7_FILIAL","X3_TAMANHO"),;
                        GetSx3Cache("Z7_FILIAL","X3_DECIMAL"),;
                        FWBuildFeature(STRUCT_FEATURE_VALID, GetSx3Cache("Z7_FILIAL","X3_VALID")),;
                        FWBuildFeature(STRUCT_FEATURE_WHEN, GetSx3Cache("Z7_FILIAL","X3_WHEN")),;
                        {},;
                        lObrigat,;
                        FWBuildFeature(STRUCT_FEATURE_INIPAD, GetSx3Cache("Z7_FILIAL","X3_RELACAO") ),;
                        lKey,;
                        lNoUpd,;
                        lVirtual )

	oStruTMP:addField(  Alltrim(GetSx3Cache("Z7_DOCINV","X3_TITULO")),;
                        Alltrim(GetSx3Cache("Z7_DOCINV","X3_DESCRIC")),;
                        Alltrim(GetSx3Cache("Z7_DOCINV","X3_CAMPO")),;
                        Alltrim(GetSx3Cache("Z7_DOCINV","X3_TIPO")),;
                        GetSx3Cache("Z7_DOCINV","X3_TAMANHO"),;
                        GetSx3Cache("Z7_DOCINV","X3_DECIMAL"),;
                        FWBuildFeature(STRUCT_FEATURE_VALID, GetSx3Cache("Z7_DOCINV","X3_VALID")),;
                        FWBuildFeature(STRUCT_FEATURE_WHEN, GetSx3Cache("Z7_DOCINV","X3_WHEN")),;
                        {},;
                        lObrigat,;
                        FWBuildFeature(STRUCT_FEATURE_INIPAD, GetSx3Cache("Z7_DOCINV","X3_RELACAO") ),;
                        lKey,;
                        lNoUpd,;
                        lVirtual )

	oStruTMP:addField(  Alltrim(GetSx3Cache("Z7_DTINV","X3_TITULO" )),;
                        Alltrim(GetSx3Cache("Z7_DTINV","X3_DESCRIC")),;
                        Alltrim(GetSx3Cache("Z7_DTINV","X3_CAMPO"  )),;
                        Alltrim(GetSx3Cache("Z7_DTINV","X3_TIPO"   )),;
                        GetSx3Cache("Z7_DTINV","X3_TAMANHO"),;
                        GetSx3Cache("Z7_DTINV","X3_DECIMAL"),;
                        FWBuildFeature(STRUCT_FEATURE_VALID, GetSx3Cache("Z7_DTINV","X3_VALID") ),;
                        FWBuildFeature(STRUCT_FEATURE_WHEN, GetSx3Cache("Z7_DTINV","X3_WHEN" ) ),;
                        {},;
                        lObrigat,;
                        FWBuildFeature(STRUCT_FEATURE_INIPAD, GetSx3Cache("Z7_DTINV","X3_RELACAO") ),;
                        lKey,;
                        lNoUpd,;
                        lVirtual )

    //-- Inicializador padrao dos campos na Grid
    oStruSZ7:addTrigger("Z7_COD",;
                          "Z7_LOCAL",;
                          Nil,;
                          {|| Posicione("SB2",1,xFilial("SB2")+FwFldGet("Z7_COD"),"B2_LOCAL")})

	oStruSZ7:setProperty("Z7_DOCINV", MODEL_FIELD_INIT, {|| "*"})
	oStruSZ7:setProperty("Z7_DTINV", MODEL_FIELD_INIT, {|| dDataBase})

    //-- Alteracao especifica do modelo de dados
    AltStruMdl(@oStruSZ7)

	oModel := MPFormModel():new("XREESTA26", /*bPreValidacao*/, bPosValid, bCommit, /*bCancel*/)

	oModel:addFields(ID_CABEC_SZ7, /*cOwner*/, oStruTMP, /*bPre*/, /*bPost*/, bLoad)

    //-- Grid SZ7
	oModel:addGrid(ID_GRID_SZ7, ID_CABEC_SZ7, oStruSZ7, /*bLinePre*/, /*bLinePos*/, /*bPreVal*/, /*bPosVal*/)
	oModel:getModel(ID_GRID_SZ7):setUniqueLine({"Z7_COD", "Z7_LOCAL", "Z7_LOTECTL", "Z7_NUMLOTE"})
	oModel:setRelation(ID_GRID_SZ7, {{"Z7_FILIAL", "Z7_FILIAL"}, {"Z7_DOCINV", "Z7_DOCINV"}, {"Z7_DTINV", "Z7_DTINV"}}, SZ7->(IndexKey(1)))

    //-- Totalizadores SZ7
    oModel:addCalc("CONT_TOTAIS", ID_CABEC_SZ7, ID_GRID_SZ7, "Z7_COD", "XX_CODSZ7", "COUNT", {|| .T.},, "Total de Registros - SZ7")
    oModel:addCalc("CONT_TOTAIS", ID_CABEC_SZ7, ID_GRID_SZ7, "Z7_QUANT", "XX_QTD1SZ7", "COUNT", {|oMld| VldQtdReg(oMld, ID_GRID_SZ7, "XX_QTD1SZ7")},, "Reg. Contados")
    oModel:addCalc("CONT_TOTAIS", ID_CABEC_SZ7, ID_GRID_SZ7, "Z7_QUANT", "XX_QTD2SZ7", "COUNT", {|oMld| VldQtdReg(oMld, ID_GRID_SZ7, "XX_QTD2SZ7")},, "Reg. Zerados")
    oModel:addCalc("CONT_TOTAIS", ID_CABEC_SZ7, ID_GRID_SZ7, "Z7_STATUS", "XX_STSZ7", "COUNT", {|oMld| VldQtdProc(oMld, ID_GRID_SZ7, "XX_STSZ7")},, "Reg. Processados")

    If !lIncInv .And. !lAltInv .And. !lProcInv
        //-- Grid SB7
        // oModel:addGrid(ID_GRID_SB7, ID_CABEC_SZ7, oStruSB7, /*bLinePre*/, /*bLinePos*/, /*bPreVal*/, /*bPosVal*/)

        oModel:addGrid(ID_GRID_SB7, ID_GRID_SZ7, oStruSB7, /*bLinePre*/, /*bLinePos*/, /*bPreVal*/, /*bPosVal*/)

        oModel:setRelation(ID_GRID_SB7, {{"B7_FILIAL", "Z7_FILIAL"}, {"B7_DOC", "Z7_DOCINV"}, {"B7_DATA", "Z7_DTINV"},{"B7_COD","Z7_COD"}}, SB7->(IndexKey(1)))
        oModel:getModel(ID_GRID_SB7):setOnlyQuery(.T.)
        
        //-- Totalizadores SB7
        oModel:addCalc("INV_TOTAIS", ID_GRID_SZ7, ID_GRID_SB7, "B7_COD", "XX_CODSB7", "COUNT", {|| .T.},, "Total de Registros - SB7")
        oModel:addCalc("INV_TOTAIS", ID_GRID_SZ7, ID_GRID_SB7, "B7_QUANT", "XX_QTD1SB7", "COUNT", {|oMld| VldQtdReg(oMld, ID_GRID_SB7, "XX_QTD1SB7")},, "Reg. Contados")
        oModel:addCalc("INV_TOTAIS", ID_GRID_SZ7, ID_GRID_SB7, "B7_QUANT", "XX_QTD2SB7", "COUNT", {|oMld| VldQtdReg(oMld, ID_GRID_SB7, "XX_QTD2SB7")},, "Reg. Zerados")
        oModel:addCalc("INV_TOTAIS", ID_GRID_SZ7, ID_GRID_SB7, "B7_STATUS", "XX_STSB7", "COUNT", {|oMld| VldQtdProc(oMld, ID_GRID_SB7, "XX_STSB7")},, "Reg. Processados")
    EndIf

	oModel:setPrimaryKey({})

	oModel:setDescription(MVC_TITLE)

	oModel:setActivate({|oModel| ActiveMod(oModel, 2)})

Return oModel


//--
Static Function ViewDef()
    Local oStruTMP := Nil
	Local oStruSZ7 := FWFormStruct(STRUCT_VIEW, TABLE_SZ7)
    Local oStruSB7 := FWFormStruct(STRUCT_VIEW, TABLE_SB7)
	Local oModel   := FWLoadModel("REESTA26")
	Local oView    := FWFormView():new()
    Local oTotCont := Nil
    Local oTotInv  := Nil
    Local lIncInv  := Type("cOpIdInc" )=="C" .And. cOpIdInc == OP_INC
    Local lAltInv  := Type("cOpIdAlt" )=="C" .And. cOpIdAlt == OP_ALT
    Local lProcInv := Type("cOpIdProc" )=="C" .And. cOpIdProc == OP_PROC

	//-- Estrutura Fake de Field
	oStruTMP := FWFormViewStruct():new()

	oStruTMP:addField(  Alltrim(GetSX3Cache("Z7_FILIAL","X3_CAMPO")),;
                        "01",;
                        GetSX3Cache("Z7_FILIAL","X3_TITULO"),;
                        GetSX3Cache("Z7_FILIAL","X3_DESCRIC"),;
                        GetHlpSoluc("Z7_FILIAL"),;
                        GetSX3Cache("Z7_FILIAL","X3_TIPO"))

	oStruTMP:addField(  Alltrim(GetSX3Cache("Z7_DOCINV","X3_CAMPO")),;
                        "02",;
                        GetSX3Cache("Z7_DOCINV","X3_TITULO"),;
                        GetSX3Cache("Z7_DOCINV","X3_DESCRIC"),;
                        GetHlpSoluc("Z7_DOCINV"),;
                        GetSX3Cache("Z7_DOCINV","X3_TIPO"))

	oStruTMP:addField(  Alltrim(GetSX3Cache("Z7_DTINV","X3_CAMPO")),;
                        "03",;
                        GetSX3Cache("Z7_DTINV","X3_TITULO"),;
                        GetSX3Cache("Z7_DTINV","X3_DESCRIC"),;
                        GetHlpSoluc("Z7_DTINV"),;
                        GetSX3Cache("Z7_DTINV","X3_TIPO"))

    //-- Estrutura de Grid
    oStruSZ7:removeField("Z7_DOCINV")
    //oStruSZ7:removeField("Z7_QTDORI")
    oStruSZ7:removeField("Z7_DATA")
    oStruSZ7:removeField("Z7_DFABRIC")
    oStruSZ7:removeField("Z7_LOTEFOR")

    //-- Alteracao especifica da view
    AltStruView(@oStruSZ7)

    oTotCont := FWCalcStruct(oModel:getModel("CONT_TOTAIS"))

	oView:setModel(oModel)
	oView:addField("VIEW_MASTER", oStruTMP, ID_CABEC_SZ7)
	oView:addGrid("VIEW_DETAIL_SZ7", oStruSZ7, ID_GRID_SZ7)
    oView:addField("CONT_TOT_VIEW", oTotCont, "CONT_TOTAIS")

	oView:createHorizontalBox("SUPERIOR", 20)
	oView:createHorizontalBox("INFERIOR", 80)

	oView:createFolder("FOLDER", "INFERIOR")
	oView:addSheet("FOLDER", "ABA_SZ7", "&Registros de Contagens")

    oView:createHorizontalBox("REG_SZ7", 80,,,"FOLDER","ABA_SZ7")
    oView:createHorizontalBox("BOX_TOTAL_SZ7", 20,,, "FOLDER", "ABA_SZ7")

    oView:setOwnerView("VIEW_MASTER", "SUPERIOR")
    oView:setOwnerView("VIEW_DETAIL_SZ7", "REG_SZ7")
    oView:setOwnerView("CONT_TOT_VIEW", "BOX_TOTAL_SZ7")

    oView:setViewProperty("VIEW_DETAIL_SZ7", "GRIDNOORDER")

    If !lIncInv .And. !lAltInv .And. !lProcInv
        oStruSB7:removeField("B7_DOC")
        oStruSB7:removeField("B7_QTSEGUM")
        oStruSB7:removeField("B7_LOCALIZ")
        oStruSB7:removeField("B7_NUMSERI")
        oStruSB7:removeField("B7_CODGRP")
        oStruSB7:removeField("B7_CODITE")
        oStruSB7:removeField("B7_TPESTR")
        oStruSB7:removeField("B7_OK")
        oStruSB7:removeField("B7_NUMDOC")
        oStruSB7:removeField("B7_SERIE")
        oStruSB7:removeField("B7_FORNECE")
        oStruSB7:removeField("B7_LOJA")
        oStruSB7:removeField("B7_SDOC")
        oStruSB7:removeField("B7_CODUNI")
        oStruSB7:removeField("B7_SLDTERC")
        oStruSB7:removeField("B7_IDUNIT")

        oStruSB7:setProperty("B7_STATUS", MVC_VIEW_ORDEM, "00")
        oStruSB7:setProperty("B7_COD", MVC_VIEW_ORDEM, "01")
        oStruSB7:setProperty("B7_DESC", MVC_VIEW_ORDEM, "02") 
        oStruSB7:setProperty("B7_LOCAL", MVC_VIEW_ORDEM, "03")
        oStruSB7:setProperty("B7_QUANT", MVC_VIEW_ORDEM, "04")
        oStruSB7:setProperty("B7_LOTECTL", MVC_VIEW_ORDEM, "05")
        oStruSB7:setProperty("B7_NUMLOTE", MVC_VIEW_ORDEM, "06")
        oStruSB7:setProperty("B7_DTVALID", MVC_VIEW_ORDEM, "07")
        oStruSB7:setProperty("B7_DATA", MVC_VIEW_ORDEM, "08")
        oStruSB7:setProperty("B7_CONTAGE", MVC_VIEW_ORDEM, "09")
        oStruSB7:setProperty("B7_ORIGEM", MVC_VIEW_ORDEM, "10")

        oTotInv := FWCalcStruct(oModel:getModel("INV_TOTAIS"))

        oView:addGrid("VIEW_DETAIL_SB7", oStruSB7, ID_GRID_SB7)
        oView:addField("INV_TOT_VIEW", oTotInv, "INV_TOTAIS")

        oView:addSheet("FOLDER", "ABA_SB7", "&Registros de Inventário (SB7)")

        oView:createHorizontalBox("REG_SB7", 80,,,"FOLDER","ABA_SB7")
        oView:createHorizontalBox("BOX_TOTAL_SB7", 20,,, "FOLDER", "ABA_SB7")

        oView:setOwnerView("VIEW_DETAIL_SB7", "REG_SB7")
        oView:setOwnerView("INV_TOT_VIEW", "BOX_TOTAL_SB7")

        oView:setViewProperty("VIEW_DETAIL_SB7", "GRIDNOORDER")
    EndIf

	oView:enableTitleView("VIEW_MASTER", "Documento")

	//-- Habilita barra de progresso para abertura da tela
	oView:setProgressBar(.T.)

	//-- Desabilitar o botao "Salvar e Criar Novo"
	oView:setCloseOnOK({|| .T.})

Return oView


/*/{Protheus.doc} AltStruMdl
Rotina que alterar a estrutura da model
@type function
@version 1.0
@author DO THINK - DENER LEMOS
@since 21/04/2025
@param oStruSZ7, object, Objeto da model
/*/
Static Function AltStruMdl(oStruSZ7)
    Local aTrig  := {}
    // Local bRelac := {|| Iif(SZ7->Z7_STATUS == "1", "BR_LARANJA", Iif(SZ7->Z7_STATUS == "2", "BR_AZUL", "BR_VERMELHO"))}
    Local bRelac := {|| ;
    Iif(SZ7->Z7_STATUS == "1", "BR_LARANJA",Iif(SZ7->Z7_STATUS == "2", "BR_AZUL",Iif(SZ7->Z7_STATUS == "3", "BR_VERMELHO",Iif(SZ7->Z7_STATUS == "4", "BR_CINZA","BR_CINZA"))))}

	oStruSZ7:addField( AllTrim(""),; //-- [01] Titulo do campo
					   AllTrim(""),; //-- [02] ToolTip do campo
					   "Z7_LEGEND",; //-- [03] Id do Field
					   "C"        ,; //-- [04] Tipo do campo
					   50         ,; //-- [05] Tamanho do campo
					   0          ,; //-- [06] Decimal do campo
					   Nil        ,; //-- [07] Code-block de validacao do campo
					   Nil        ,; //-- [08] Code-block de validacao When do campo
					   Nil        ,; //-- [09] Lista de valores permitido do campo
					   Nil        ,; //-- [10] Indica se o campo tem preenchimento obrigatório
					   bRelac     ,; //-- [11] Code-block de inicializacao do campo
					   Nil        ,; //-- [12] Indica se trata-se de um campo chave
					   Nil        ,; //-- [13] Indica se o campo pode receber valor em uma operacao de update.
					   .T.         ) //-- [14] Indica se o campo e virtual

	//-- Adiciona gatilho no modelo
	aTrig := FWStruTrigger( "Z7_STATUS"                                                                                 ,; //-- Campo dominio
                            "Z7_LEGEND"                                                                                 ,; //-- Campo de contradominio 
                            "Iif(M->Z7_STATUS == '1', 'BR_LARANJA', Iif(M->Z7_STATUS == '2', 'BR_AZUL', Iif(M->Z7_STATUS == '3', 'BR_VERMELHO', Iif(M->Z7_STATUS == '4', 'BR_CINZA', 'BR_VERMELHO'))))",;
                            .F.                                                                                         ,; //-- Se posicionara ou nao antes da execucao do gatilhos
                            ""                                                                                          ,; //-- Alias da tabela a ser posicionada
                            1                                                                                           ,; //-- Ordem da tabela a ser posicionada
                            ""                                                                                          ,; //-- Chave de busca da tabela a ser posicionada
                            ""                                                                                           ) //-- Condicao para execucao do gatilho

	oStruSZ7:addTrigger(aTrig[1], aTrig[2], aTrig[3], aTrig[4])

Return


/*/{Protheus.doc} AltStruView
Rotina que alterar a estrutura da view
@type function
@version 1.0
@author DO THINK - DENER LEMOS
@since 21/04/2025
@param oStruSZ7, object, Objeto da view
/*/
Static Function AltStruView(oStruSZ7)

	oStruSZ7:AddField( "Z7_LEGEND" ,; //-- [01] Campo
					   "00"        ,; //-- [02] Ordem 
					   AllTrim("") ,; //-- [03] Titulo
					   AllTrim("") ,; //-- [04] Descricao
					   {"Legenda"} ,; //-- [05] Help
					   "C"         ,; //-- [06] Tipo do campo (COMBO","GET","CHECK")
					   "@BMP"      ,; //-- [07] Picture
					   Nil         ,; //-- [08] PictVar
					   ""          ,; //-- [09] F3
					   .F.    	   ,; //-- [10] Editavel
					   ""          ,; //-- [11] Folder
					   ""          ,; //-- [12] Group
					   Nil         ,; //-- [13] Lista Combo
					   Nil         ,; //-- [14] Tam Max Combo
					   ""          ,; //-- [15] Inic. Browse
					   .T.     	    ) //-- [16] Virtual

Return


//--
Static Function Commit(oModel)
    Local oMaster   := oModel:getModel()
	//Local oModelCab := oMaster:getModel(ID_CABEC_SZ7)
	Local oMdlGrdZ7 := oMaster:getModel(ID_GRID_SZ7)
    //Local oMdlGrdB7 := oMaster:getModel(ID_GRID_SB7)
    Local lProcInv := Type("cOpIdProc" )=="C" .And. cOpIdProc == OP_PROC
    Local lRet      := .T.
    Local nZ        := 0

	Do Case
		Case oModel:getOperation() == MODEL_OPERATION_UPDATE
			 //-- Processamento do inventario
			If lProcInv
				//-- Libera modelo para alteracao
				oMdlGrdZ7:setNoUpdateLine(.F.)

                //MsAguarde( {|| lRet := AcertoInv(oModel)}, "Aguarde...", "Processando inventário..." )
                lRet := AcertoInv(oModel)

				If lRet
                    For nZ := 1 To oMdlGrdZ7:length()
                        oMdlGrdZ7:goLine(nZ)
                        oMdlGrdZ7:LoadValue("Z7_STATUS", "3")
                    Next nZ
				Endif

				//-- Bloqueia novamente o modelo
				oMdlGrdZ7:setNoUpdateLine(.T.)
			Endif
		Case oModel:GetOperation() == MODEL_OPERATION_DELETE
			//-- funcao de tratamento para exclusao aqui
	EndCase

	If lRet
		FWFormCommit(oModel)
	Else
		If lProcInv
			oModel:setErrorMessage("REESTA26", ID_GRID_SZ7, "REESTA26", ID_GRID_SZ7,, "INVERROR")
		EndIf
	EndIf

	FreeUsedCode(.T.)

Return lRet


//--
Static Function ActiveMod(oModel, nOpcX)
    Local oMaster   := oModel:getModel()
	Local oModelCab := oMaster:getModel(ID_CABEC_SZ7)
	Local oMdlGrdZ7 := oMaster:getModel(ID_GRID_SZ7)
    Local oMdlGrdB7 := Nil
    Local lIncInv   := Type("cOpIdInc" )=="C" .And. cOpIdInc == OP_INC
    Local lAltInv   := Type("cOpIdAlt" )=="C" .And. cOpIdAlt == OP_ALT
    Local lProcInv  := Type("cOpIdProc" )=="C" .And. cOpIdProc == OP_PROC

    Default nOpcX := 1

    If nOpcX == 2
        If lProcInv
            //-- Simula alteracao do campo MVC
            dDataInv := oModelCab:getValue("Z7_DTINV")
            oModelCab:setValue("Z7_DTINV", dDataInv)

            oMdlGrdZ7:setNoInsertLine(.T.)
            oMdlGrdZ7:setNoDeleteLine(.T.)
            oMdlGrdZ7:setNoUpdateLine(.T.)

            If !lIncInv .And. !lAltInv .And. !lProcInv
                oMdlGrdB7 := oMaster:getModel(ID_GRID_SB7)
                oMdlGrdB7:setNoInsertLine(.T.)
                oMdlGrdB7:setNoDeleteLine(.T.)
                oMdlGrdB7:setNoUpdateLine(.T.)
            EndIf
        ElseIf lAltInv
            oMdlGrdZ7:setNoInsertLine(.T.)

            If !lIncInv .And. !lAltInv .And. !lProcInv
                oMdlGrdB7 := oMaster:getModel(ID_GRID_SB7)
                oMdlGrdB7:setNoInsertLine(.T.)
                oMdlGrdB7:setNoDeleteLine(.T.)
                oMdlGrdB7:setNoUpdateLine(.T.)
            EndIf
        EndIf
    EndIf

Return .T.


//--
Static Function LoadHead(oModel, lCopy)
	Local aLoad := {(TABLE_SZ7)->Z7_FILIAL, (TABLE_SZ7)->Z7_DOCINV, (TABLE_SZ7)->Z7_DTINV}
Return aLoad


//--
Static Function AcertoInv(oModel)
    Local aAreaAnt  := GetArea()
    Local aAreaSB7  := SB7->(GetArea())
    Local oMaster   := oModel:getModel()
	Local oMdlGrdZ7 := oMaster:getModel(ID_GRID_SZ7)
    //Local oMdlGrdB7 := oMaster:getModel(ID_GRID_SB7)
    Local cProduto  := ""
    Local cArmazem  := ""
    Local cDocInv   := SZ7->Z7_DOCINV
    Local dDataInv  := Nil
    Local nQuant    := 0
    Local cLote     := ""
    Local cSLote    := ""
    Local dDtValid  := Nil
    Local nZ        := 0
    Local lRet      := .F.

    Private lModelo1  := GetMV("MV_CBINVMD") =="1"
    Private lUsaCB001 := UsaCB0("01")

    SB7->(dbSetOrder(3))
    If !SB7->(dbSeek(xFilial("SB7") + cDocInv))
        Begin Transaction
            For nZ := 1 To oMdlGrdZ7:length()
                oMdlGrdZ7:goLine(nZ)

                If !oMdlGrdZ7:isDeleted()
                    cProduto := oMdlGrdZ7:getValue("Z7_COD")
                    cArmazem := oMdlGrdZ7:getValue("Z7_LOCAL")
                    cDocInv  := oMdlGrdZ7:getValue("Z7_DOCINV")
                    dDataInv := oMdlGrdZ7:getValue("Z7_DTINV")
                    nQuant   := oMdlGrdZ7:getValue("Z7_QUANT")
                    cLote    := oMdlGrdZ7:getValue("Z7_LOTECTL")
                    cSLote   := oMdlGrdZ7:getValue("Z7_NUMLOTE")
                    dDtValid := oMdlGrdZ7:getValue("Z7_DTVALID")

                    lRet := GravaSB7(cProduto, cArmazem, cDocInv, dDataInv, nQuant, cLote, cSLote, dDtValid)

                    If !lRet
                        Exit
                    EndIf
                Endif
            Next nZ

            If !lRet
                DisarmTransaction()
            Endif
        End Transaction
    Else
        lRet := .T.
    EndIf

    If lRet
        SB7->(dbSetOrder(3))
        If SB7->(dbSeek(xFilial("SB7") + cDocInv))
            MATA340(.T., cDocInv, .F.)
        EndIf
    EndIf

    RestArea(aAreaAnt)
    RestArea(aAreaSB7)

Return lRet


//--
Static Function GravaSB7(cProduto, cArmazem, cDocInv, dDataInv, nQuant, cLote, cSLote, dDtValid)
    Local aVetor := {}
    Local cCont	 := "001"

    Private lMsErroAuto	:= .F.
    Private lMsHelpAuto	:= .T.

    aVetor:= {	{"B7_COD",		cProduto, Nil},;
                {"B7_LOCAL",	cArmazem, Nil},;
                {"B7_LOCALIZ",	"",       Nil},;
                {"B7_DOC",		cDocInv,  Nil},;
                {"B7_DATA",		dDataInv, Nil},;
                {"B7_QUANT",	nQuant,   Nil},;
                {"B7_NUMLOTE",	cSLote,   Nil},;
                {"B7_LOTECTL",	cLote,    Nil},;
                {"B7_CONTAGE",	cCont,    Nil}}

    If !Empty(dDtValid)
        aadd(aVetor, {"B7_DTVALID", dDtValid, Nil})
    EndIf

    MsExecAuto({|x| Mata270(x)}, aVetor)

    If lMsErroAuto
        MostraErro()
        Return .F.
    Endif

Return .T.


//-- Rotina que valida se a contagem sera totalizado
Static Function VldQtdReg(oModel, cMdlFil, cCampo)
	Local nQuant := 0

    If cMdlFil == ID_GRID_SZ7
        nQuant := oModel:getValue(cMdlFil, "Z7_QUANT")

        If cCampo == "XX_QTD1SZ7"
            If nQuant > 0
                Return .T.
            Else
                Return .F.
            EndIf
        Else
            If nQuant == 0
                Return .T.
            Else
                Return .F.
            EndIf
        EndIf
    Else
        nQuant := oModel:getValue(cMdlFil, "B7_QUANT")

        If cCampo == "XX_QTD1SB7"
            If nQuant > 0
                Return .T.
            Else
                Return .F.
            EndIf
        Else
            If nQuant == 0
                Return .T.
            Else
                Return .F.
            EndIf
        EndIf
    EndIf

Return .F.


//--
Static Function VldQtdProc(oModel, cMdlFil, cCampo)
    Local cStatus := ""

    If cMdlFil == ID_GRID_SZ7
        cStatus := oModel:getValue(cMdlFil, "Z7_STATUS")

        If cCampo == "XX_STSZ7"
            If cStatus == "3"
                Return .T.
            Else
                Return .F.
            EndIf
        EndIf
    Else
        cStatus := oModel:getValue(cMdlFil, "B7_STATUS")

        If cCampo == "XX_STSB7"
            If cStatus == "2"
                Return .T.
            Else
                Return .F.
            EndIf
        EndIf
    EndIf

Return .F.


//--
User Function RESTA26I()
	Local cView := "REESTA26"
	
	cOpIdInc := OP_INC

    FWExecView(Upper("Incluir"), cView, MODEL_OPERATION_INSERT,, {|| .T.})

Return


//--
User Function RESTA26A()
    Local cStatus := SZ7->Z7_STATUS
	Local cView   := "REESTA26"
	
	cOpIdAlt := OP_ALT

	If cStatus == "1" .Or. cStatus == "2" .Or. cStatus == "4"
		FWExecView(Upper("Alterar"), cView, MODEL_OPERATION_UPDATE,, {|| .T.})
	Else
		Help( Nil, Nil, "INVNAOALTERA", Nil, "Não é possível alterar um inventário já processado.", 1, 0 )
	Endif

Return


//--
User Function RESTA26E()
    Local cStatus := SZ7->Z7_STATUS
	Local cView   := "REESTA26"
	
	cOpIdAlt := OP_ALT

	If cStatus == "1"
		FWExecView(Upper("Excluir"), cView, MODEL_OPERATION_DELETE,, {|| .T.})
	Else
		Help( Nil, Nil, "INVNAOEXCLUI", Nil, "Não é possível excluir um inventário inventário finalizado ou já processado.", 1, 0 )
	Endif

Return


//--
User Function RESTA26F()
    Local cDocInv   := AllTrim(SZ7->Z7_DOCINV)
	Local cStatus   := SZ7->Z7_STATUS
    Local lImpNCont := .F.
    Local cFilInv   := SZ7->Z7_FILIAL
    Local cCodProd  := SZ7->Z7_COD
    Local cLocal    := SZ7->Z7_LOCAL
    Local dDataInv  := SZ7->Z7_DTINV

    cOpIdFim := OP_FIM

	If cStatus == "1"
        //SetMVValue("RESTA26F", "MV_PAR01", 2) //-- Importa Bobina nao Contada ?
        While .T.
            If !Pergunte("RESTA26F", .T., "Finalizar Contagem - " + cDocInv)
                Return 
            EndIf

            If PergTOk()
                Exit
            EndIf
        EndDo

        lImpNCont := IIF(ValType(MV_PAR01) == "N", MV_PAR01==1, MV_PAR01=="1")
        cLocal    := MV_PAR02

        If FWAlertYesNo("Confirma finalização da contagem do inventário <strong>" + cDocInv + "</strong>" + IIF(lImpNCont, " com <strong>importação ZERADA</strong> das bobinas não contadas", "") + "?", "Finalizar Contagem?")
            MsAguarde( {|| SetFimContagem(lImpNCont, cFilInv, cDocInv, cCodProd, cLocal, dDataInv)}, "Aguarde...", "Finalizando contagem..." )
        EndIf
	Else
		Help( Nil, Nil, "INVNAOFINALIZA", Nil, "Não é possível finalizar uma contagem de um inventário finalizado ou já processado.", 1, 0 )
	EndIf

Return


//-- Rotina de validacoes de usuario ao clicar em "ok"
Static Function PergTOk()

    If IIF(ValType(MV_PAR01) == "N", MV_PAR01==1, MV_PAR01=="1")
        If Empty(MV_PAR02)
            Aviso("Atenção!", "O armazém não pode estar vazio!", {"Ok"})
            Return .F.
        EndIf
    EndIf

Return .T.


//--
Static Function SetFimContagem(lImpNCont, cFilInv, cDocInv, cCodProd, cLocal, dDataInv)
    Local aAreaAnt := GetArea()
    Local aAreaSZ7 := SZ7->(GetArea())
    Local cQuery   := ""

    Default lImpNCont := .F.
    Default cFilInv   := ""
    Default cDocInv   := ""
    Default cCodProd  := ""
    Default cLocal    := ""
    Default dDataInv  := CTOD("//")

    If Select("_QRYFIM") > 0
        _QRYFIM->(dbCloseArea())
    EndIf

    //--
    cQuery := " SELECT 'SZ7' TABELA, Z7_FILIAL FILIAL, Z7_COD PRODUTO, Z7_LOCAL ARMAZEM, Z7_QUANT QUANT, 0 SALDO, Z7_LOTECTL LOTECTL, Z7_NUMLOTE NUMLOTE, Z7_DTVALID DTVALID, '' OBS, SZ7.R_E_C_N_O_ RECNO "
    cQuery += " FROM " + RetSQLName("SZ7") + " SZ7 "
    cQuery += " WHERE Z7_FILIAL = '" + cFilInv + "' "
    cQuery += " AND Z7_DOCINV = '" + cDocInv + "' "
    cQuery += " AND SZ7.D_E_L_E_T_ = ' ' "
    If lImpNCont
        cQuery += " UNION "
        cQuery += " SELECT 'SB8' TABELA, B8_FILIAL FILIAL, B8_PRODUTO PRODUTO, B8_LOCAL ARMAZEM, 0 QUANT, B8_SALDO SALDO, B8_LOTECTL LOTECTL, B8_NUMLOTE NUMLOTE, B8_DTVALID DTVALID, 'BOBINA NAO CONTADA - QUANTIDADE ZERADA' OBS, 0 RECNO "
        cQuery += " FROM " + RetSQLName("SB8") + " SB8 "
        cQuery += " WHERE B8_FILIAL = '" + cFilInv + "' "
        cQuery += " AND B8_PRODUTO = '" + cCodProd + "' "
        cQuery += " AND B8_LOCAL = '" + cLocal + "' "
        cQuery += " AND B8_SALDO > 0 "
        cQuery += " AND NOT EXISTS (SELECT * FROM " + RetSQLName("SZ7") + " SZ7 "
        cQuery += "                 WHERE  Z7_FILIAL = B8_FILIAL "
        cQuery += "                 AND Z7_COD = B8_PRODUTO "
        cQuery += "                 AND Z7_LOCAL = B8_LOCAL "
        cQuery += "                 AND Z7_LOTECTL = B8_LOTECTL "
        cQuery += "                 AND Z7_NUMLOTE = B8_NUMLOTE "
        cQuery += "                 AND SZ7.D_E_L_E_T_ = ' ') "
        cQuery += " AND SB8.D_E_L_E_T_ = ' ' "
    EndIf

    cQuery := ChangeQuery(cQuery)
    TCQUERY cQuery New Alias "_QRYFIM"

    _QRYFIM->(dbGoTop())
    While _QRYFIM->(!EoF())
        If _QRYFIM->TABELA == "SZ7"
            SZ7->(dbGoTo(_QRYFIM->RECNO))
            RecLock("SZ7", .F.)
                SZ7->Z7_STATUS  := "2" //-- 1=Contado;2=Finalizado;3=Processado
            SZ7->( MsUnLock() )
        Else
            RecLock("SZ7", .T.)
                SZ7->Z7_FILIAL  := _QRYFIM->FILIAL
                SZ7->Z7_DOCINV  := cDocInv
                SZ7->Z7_COD     := _QRYFIM->PRODUTO
                SZ7->Z7_LOCAL   := _QRYFIM->ARMAZEM
                SZ7->Z7_QUANT   := _QRYFIM->QUANT
                SZ7->Z7_QTDORI  := _QRYFIM->SALDO
                SZ7->Z7_LOTECTL := _QRYFIM->LOTECTL
                SZ7->Z7_NUMLOTE := _QRYFIM->NUMLOTE
                SZ7->Z7_DTVALID := STOD(_QRYFIM->DTVALID)
                SZ7->Z7_DATA    := Date()
                SZ7->Z7_DTINV   := dDataInv
                SZ7->Z7_HRINV   := SubStr(Time(),1,5)
                SZ7->Z7_USER    := cUserName
                SZ7->Z7_TIPO    := GetAdvFVal("SB1", "B1_TIPO", xFilial("SB1") + PadR(_QRYFIM->PRODUTO, Len(SB1->B1_COD)), 1, " ")
                SZ7->Z7_GRUPO   := GetAdvFVal("SB1", "B1_GRUPO", xFilial("SB1") + PadR(_QRYFIM->PRODUTO, Len(SB1->B1_COD)), 1, " ")
                SZ7->Z7_STATUS  := "2" //-- 1=Contado;2=Finalizado;3=Processado
                SZ7->Z7_OBS     := _QRYFIM->OBS
            SZ7->(MsUnLock())
        EndIf

        _QRYFIM->(dbSkip())
    EndDo

    If Select("_QRYFIM") > 0
        _QRYFIM->(dbCloseArea())
    EndIf

    RestArea(aAreaSZ7)
    RestArea(aAreaAnt)

Return


//--
User Function RESTA26P()
	Local cStatus := SZ7->Z7_STATUS
    Local cView   := "REESTA26"

    cOpIdProc := OP_PROC

	If cStatus == "2"
		FWExecView(Upper("Processar Inventário (SB7)"), cView, MODEL_OPERATION_UPDATE,, {|| .T.})
	Else
		Help( Nil, Nil, "INVNAOPROCESSA", Nil, "Não é possível processar um inventario contado ou já processado.", 1, 0 )
	EndIf

Return


//-- Rotina que serve para validar filmes nao contados no processo de inventario, tendo a possiblidade de zerar a contagem dos produtos nao bipados
User Function RESTA26V()
    Local cQuery  := ""
    Local aList   := {}
    Local cFilAtu := FWCodFil()
    Local lOk     := .F.
    Local oDlg    := Nil
    Local oOK     := LoadBitmap(GetResources(),'LBOK')
	Local oNO     := LoadBitmap(GetResources(),'LBNO')
    
    SetMVValue("RESTA26V", "MV_PAR01", cFilAtu)
    If !Pergunte("RESTA26V", .T., "Validar não Contados")
        Return 
    EndIf

    If !Empty(MV_PAR01)
        cFilAtu := MV_PAR01
    EndIf

    If Select("_QRYVLD") > 0
        _QRYVLD->(dbCloseArea())
    EndIf

    cQuery := " SELECT 'SB8' TABELA, B8_FILIAL FILIAL, B8_PRODUTO PRODUTO, B8_LOCAL ARMAZEM, 0 QUANT, B8_SALDO SALDO, B8_EMPENHO EMPENHO, B8_LOTECTL LOTECTL, B8_NUMLOTE NUMLOTE, B8_DTVALID DTVALID, 'BOBINA NAO CONTADA - QUANTIDADE ZERADA' OBS, 0 RECNO "
    cQuery += " FROM " + RetSQLName("SB8") + " SB8 "
    cQuery += " WHERE B8_FILIAL = '" + cFilAtu + "' "
    cQuery += " AND B8_SALDO > 0 "
    cQuery += " AND NOT EXISTS (SELECT * FROM " + RetSQLName("SZ7") + " SZ7 "
    cQuery += "                 WHERE  Z7_FILIAL = B8_FILIAL "
    cQuery += "                 AND Z7_COD = B8_PRODUTO "
    cQuery += "                 AND Z7_LOCAL = B8_LOCAL "
    cQuery += "                 AND Z7_LOTECTL = B8_LOTECTL "
    cQuery += "                 AND Z7_NUMLOTE = B8_NUMLOTE "
    cQuery += "                 AND SZ7.D_E_L_E_T_ = ' ') "
    cQuery += " AND SB8.D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY B8_FILIAL, B8_PRODUTO, B8_LOCAL, B8_LOTECTL, B8_NUMLOTE "

    cQuery := ChangeQuery(cQuery)
    TCQUERY cQuery New Alias "_QRYVLD"

    _QRYVLD->(dbGoTop())
    While _QRYVLD->(!EoF())

            aAdd( aList, {   .F.               ,; //-- 01 - Marca/Desmarca
                            _QRYVLD->FILIAL    ,; //-- 02 - Filial
                            _QRYVLD->PRODUTO   ,; //-- 03 - Codigo do produto
                            _QRYVLD->ARMAZEM   ,; //-- 04 - Armazem
                            _QRYVLD->SALDO     ,; //-- 05 - Saldo
                            _QRYVLD->EMPENHO   ,; //-- 06 - Empenho
                            _QRYVLD->LOTECTL   ,; //-- 07 - Lote
                            _QRYVLD->NUMLOTE   ,; //-- 08 - Sub-Lote
                            _QRYVLD->DTVALID   ,; //-- 09 - Data de validade
                            _QRYVLD->OBS       } )//-- 10 - Observacao

        _QRYVLD->(dbSkip())
    EndDo

    If Select("_QRYVLD") > 0
        _QRYVLD->(dbCloseArea())
    EndIf

    If !Empty(aList)
        //-- Telinha para selecao dos lotes de vinculo para visualizacao na etiqueta do PA
        DEFINE MSDIALOG oDlg TITLE OemToAnsi("Validar não Contados") FROM 001, 002 TO 300, 600 PIXEL 
            oBar := tPanel():New(01, 01, "", oDlg, ,.T., , , ,120,25)
            oBar:Align := CONTROL_ALIGN_BOTTOM
            
            oList := TCBrowse():New( 000,000,302,125,,{"", "Filial", "Produto", "Local", "Saldo", "Empenho", "Lote", "Sub-Lote"},{15, 25, 75, 25, 25, 25, 55, 45},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, ) 
            oList:SetArray(aList) 
            oList:bLine := { || { If( aList[oList:nAt,01], oOK, oNO ), aList[oList:nAt,02], aList[oList:nAt,03], aList[oList:nAt,04], aList[oList:nAt,05], aList[oList:nAt,06], aList[oList:nAt,07], aList[oList:nAt,08] } } 
            oList:bLDblClick := { || aList[oList:nAt][1] := !aList[oList:nAt][1],oList:DrawSelect() }

            TButton():New( 004,245,"&Zerar",oBar,{|| lOk := VldSelect(aList), If(lOk,oDlg:End(),oDlg) },40,18,,,.F.,.T.,.F.,,.F.,,,.F. )
        ACTIVATE MSDIALOG oDlg CENTERED

        If lOk
            /*
            For nI := 1 To Len(aList)
                If aList[nI, 01]
                    MV_PAR06 := aList[nI, 02]
                    MV_PAR07 := aList[nI, 03]
                EndIf
            Next nI
            */
        EndIf
    EndIf

Return


//--
Static Function VldSelect(aLista)
    Local nI     := 0
    Local cCount := 0
    Local lRet   := .T.

    For nI := 1 To Len(aLista)
        If aLista[nI, 01]
            cCount++
        EndIf
    Next nI

    If Empty(cCount)
        MsgAlert("Selecione pelo menos um Lote/Sub-Lote para zerar!", "Seleção")
        lRet := .F.
    EndIf

Return lRet


User Function RESTA26W()

    Local lResp := .F.

    lResp := MsgYesNo("Deseja realmente realizar a carga inicial?")

    If !lResp
        Return
    EndIf

    FWMsgRun(NIL, {|| ProcRESTA26W()}, "Realizando carga inicial, aguarde...")

Return

Static Function ProcRESTA26W()

    Local xFilial   := FWxFilial("SB8")
    Local cQuery    := ""
    Local aArea     := GetArea()
    Local nReg      := 0
    Local cDocInv   := ""
    Local cProdAnt  := ""

    cQuery := ""
    cQuery += " SELECT "
    cQuery += " SB8.B8_FILIAL, "
    cQuery += " SB8.B8_PRODUTO, "
    cQuery += " SB8.B8_LOCAL, "
    cQuery += " SB8.B8_LOTECTL, "
    cQuery += " SB8.B8_NUMLOTE, "
    cQuery += " SB8.B8_DTVALID, "
    cQuery += " SB8.B8_SALDO, "
    cQuery += " SB1.B1_TIPO, "
    cQuery += " SB1.B1_GRUPO "
    cQuery += " FROM " + RetSQLName("SB8") + " SB8 "
    cQuery += " LEFT JOIN " + RetSQLName("SB1") + " SB1 "
    cQuery += " ON SB1.B1_FILIAL = ' ' "
    cQuery += " AND SB1.B1_COD = SB8.B8_PRODUTO "
    cQuery += " AND SB1.D_E_L_E_T_ = ' ' "
    cQuery += " WHERE SB8.B8_FILIAL = '" + xFilial + "' "
    cQuery += " AND SB8.B8_SALDO > 0 "
    cQuery += " AND SB8.D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY SB8.B8_PRODUTO "

    TCQUERY cQuery NEW ALIAS "_QSB8"

    If _QSB8->(Eof())
        MsgStop("Nenhum registro encontrado para a filial " + xFilial + "!")
        _QSB8->(DbCloseArea())
        RestArea(aArea)
        Return
    EndIf

    DbSelectArea("SZ7")

    While !_QSB8->(Eof())

        If cProdAnt != _QSB8->B8_PRODUTO
            cDocInv  := GetSX8Num("SB7","B7_DOC")
            cProdAnt := _QSB8->B8_PRODUTO
        EndIf

        If RecLock("SZ7", .T.)

            SZ7->Z7_FILIAL  := _QSB8->B8_FILIAL
            SZ7->Z7_DOCINV  := cDocInv
            SZ7->Z7_COD     := _QSB8->B8_PRODUTO
            SZ7->Z7_LOCAL   := _QSB8->B8_LOCAL
            SZ7->Z7_QTDORI  := _QSB8->B8_SALDO
            SZ7->Z7_LOTECTL := _QSB8->B8_LOTECTL
            SZ7->Z7_NUMLOTE := _QSB8->B8_NUMLOTE
            SZ7->Z7_DTVALID := StoD(_QSB8->B8_DTVALID)
            SZ7->Z7_TIPO    := _QSB8->B1_TIPO
            SZ7->Z7_GRUPO   := _QSB8->B1_GRUPO
            SZ7->Z7_STATUS  := "4"
            SZ7->Z7_DTCARG  := dDataBase
            SZ7->Z7_HRCARG  := Time()
            SZ7->Z7_USCARG  := cUserName //RetCodUsr() 

            SZ7->(MsUnlock())
            nReg++

        EndIf

        _QSB8->(DbSkip())

    EndDo

    ConfirmSX8()

    _QSB8->(DbCloseArea())
    DbCommit()
    RestArea(aArea)

    MsgInfo("Carga inicial realizada da filial " + xFilial + ;
            " com total de " + AllTrim(Str(nReg)) + ;
            " registros.")

Return
