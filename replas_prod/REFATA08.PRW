#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"


//-- Variveis Estaticas
Static cTitulo   := "Motor Mod.2 Replas"
Static cTabPai   := "SZ8"
Static cTabFilho := "SZA"


/*/{Protheus.doc} REFATA08
Rotina do Motor Mod.2 para envio dos Materias da INDUSTRIA para REPLAS
@type function
@version 1.0  
@author DOTHINK SISTEMAS - DENER LEMOS
@since 01/08/2022
@obs Projeto Novo PCP
/*/
User Function REFATA08()
    Local cFilter := ""
    //Local nTmpAtu := GetMV("RE_TATBRWM",,1) //-- Parametro que contem o tempo de atulizacao do browse do MOTOR MOD.2 em minutos
    Local bKeyF5  := SetKey(VK_F5)

    Local aCoors      AS ARRAY
    Local oPanelUp    AS OBJECT
    Local oFWLayer    AS OBJECT
    Local oPanelDown  AS OBJECT
    Local oDlgPrinc   AS OBJECT
    Local oRelation   AS OBJECT

    Private oBrowseUp AS OBJECT
    Private oBrwDown  AS OBJECT
    Private aRotina   := MenuDef()
    Private cFilOrig  := GetMV("RE_FILORIG", .F., "0302")
	Private cFilDest  := GetMV("RE_FILDEST", .F., "0201")

	If !(cFilAnt == cFilDest)
		FWAlertError("Somente é permitido acessar o <b>" + cTitulo + "</b> na Filial [<b>" + cFilDest + "</b>].", "Não Permitido!")
		Return
	EndIf

    Pergunte("REFATA08", .F.)

    //-- Pega os filtros
    cFilter := GetFilter()

    aCoors := FWGetDialogSize(oMainWnd)
    oDlgPrinc := MSDialog():new(aCoors[1], aCoors[2], aCoors[3], aCoors[4], "",,,, nOr(WS_VISIBLE, WS_POPUP),,,,, .T.,,,, .F.)
        //oDlgPrinc:lEscClose := .F.

        oFWLayer := FWLayer():New()
        oFWLayer:Init(oDlgPrinc, .F., .T.)
        
        //-- Painel Superior
        oFWLayer:AddLine("UPLINE", 65, .F. )
        oFWLayer:AddCollumn("UPCOL", 100, .T., "UPLINE")
        oPanelUp := oFWLayer:GetColPanel("UPCOL", "UPLINE")
        
        //-- Painel Inferior
        oFWLayer:AddLine("DOWNLINE", 35, .F. )
        oFWLayer:AddCollumn("DOWNCOL", 100, .T., "DOWNLINE")
        oPanelDown := oFWLayer:GetColPanel("DOWNCOL", "DOWNLINE")

        //-- FWMBrowse Superior
        oBrowseUp := FWMBrowse():New()
        oBrowseUp:SetOwner(oPanelUp)
        oBrowseUp:SetAlias(cTabPai)
        oBrowseUp:SetDescription(cTitulo)
        oBrowseUp:SetFilterDefault(cFilter)
        oBrowseUp:SetUseFilter(.T.)
        oBrowseUp:DisableReport()
        oBrowseUp:DisableDetails()
        oBrowseUp:SetParam({|| UpdParam()}) 
        oBrowseUp:AddLegend("SZ8->Z8_STATUS=='1'", "BR_VERMELHO", "A Efetivar")
        oBrowseUp:AddLegend("SZ8->Z8_STATUS=='2'", "BR_CANCEL"  , "Efetivado com erro")
        oBrowseUp:AddLegend("SZ8->Z8_STATUS=='3'", "BR_VERDE"   , "Efetivado")
        //oBrowseUp:SetTimer({|| RefreshBrw() }, 60000 * nTmpAtu)
        //oBrowseUp:SetIniWindow({|| oBrowseUp:oTimer:lActive := (MV_PAR12 < 3)})
        oBrowseUp:SetProfileID(cTabPai)
        oBrowseUp:ForceQuitButton()

        //-- Ordenacao do botoes na tela
        oBrowseUp:lOptionConfig := .F.
        aAdd(oBrowseUp:aButtonsOrder, "Efetivar")
        aAdd(oBrowseUp:aButtonsOrder, "Alterar")
        aAdd(oBrowseUp:aButtonsOrder, "Visualizar")
        aAdd(oBrowseUp:aButtonsOrder, "Traceability")
        aAdd(oBrowseUp:aButtonsOrder, "Status SEFAZ")
        aAdd(oBrowseUp:aButtonsOrder, "Parametros [F12]")

        //-- FWMBrowse Inferior
        oBrwDown := FWMBrowse():New()
        oBrwDown:SetOwner(oPanelDown)
        oBrwDown:SetDescription("Empenhos OP")
        oBrwDown:SetAlias("SD4")
        oBrwDown:SetOnlyFields({"D4_COD","D4_LOCAL","D4_QTDEORI","D4_QUANT","D4_LOTECTL","D4_NUMLOTE","D4_DTVALID"})
        oBrwDown:SetMenuDef("")
        oBrwDown:SetIgnoreARotina(.T.)
        oBrwDown:DisableDetails()
        oBrwDown:DisableConfig()
        oBrwDown:DisableReport()
        oBrwDown:DisableFilter()
        oBrwDown:SetProfileID("SD4")

        oBrowseUp:activate()
        oBrwDown:activate()
            
        oBrowseUp:SetFocus()

        //-- Relacionamento entre os browses
        oRelation := FWBrwRelation():New()
        oRelation:AddRelation(oBrowseUp, oBrwDown, {{"D4_FILIAL", "xFilial('SZ8')"}, {"D4_OP", "Z8_OP"}, {"D4_PRODUTO", "Z8_PRODUTO"}})
        oRelation:activate()

        SetKey(VK_F5 , {|| RefreshBrw()})
        
    oDlgPrinc:activate(,,,,,, {|| })

    SetKey(VK_F5 , bKeyF5)

    oBrowseUp:DeActivate()
    oBrowseUp:Destroy()
 
    oBrwDown:DeActivate()
    oBrwDown:Destroy()
 
    FreeObj(oBrowseUp)
    FreeObj(oBrwDown)
    FreeObj(oRelation)
    FreeObj(oDlgPrinc)
    FreeObj(oPanelUp)
    FreeObj(oFWLayer)
    FreeObj(oPanelDown)

Return


/*/{Protheus.doc} MenuDef
MenuDef
@type function
@version 1.0  
@author DOTHINK SISTEMAS - DENER LEMOS
@since 01/08/2022
@return array, MenuDef
/*/
Static Function MenuDef()
    Local aRotina := {}

    ADD OPTION aRotina TITLE "Efetivar"         ACTION "U_REFATA8A()"     OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Alterar"          ACTION "VIEWDEF.REFATA08" OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Visualizar"       ACTION "VIEWDEF.REFATA08" OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE "Traceability"     ACTION "U_REFATA10()"     OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE "Parametros [F12]" ACTION "U_REFATA8C()"     OPERATION 4 ACCESS 0

Return aRotina


/*/{Protheus.doc} ModelDef
ModelDef
@type function
@version 1.0  
@author DOTHINK SISTEMAS - DENER LEMOS
@since 01/08/2022
@return object, ModelDef
/*/
Static Function ModelDef()
    Local aRelation := {}
	Local oModel    := Nil
	Local oStruSZ8  := FWFormStruct(1, cTabPai)
    Local oStruSZA  := FWFormStruct(1, cTabFilho)

    //-- Alteracao especifica do modelo de dados
    AltStruMdl(@oStruSZA)

    oModel := MPFormModel():New("XREFATA08",/*bPost*/,,/*Commit*/, /*Cancel*/)
    oModel:AddFields("MASTER_SZ8", Nil, oStruSZ8)
    oModel:AddGrid("DETAIL_SZA", "MASTER_SZ8", oStruSZA, /*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)
    oModel:SetDescription(cTitulo)
    oModel:GetModel("MASTER_SZ8"):SetDescription("Cabeçalho Motor Mod.2")
    oModel:GetModel("DETAIL_SZA"):SetDescription("Processos Motor Mod.2")
    oModel:SetPrimaryKey({})
    oModel:GetModel('DETAIL_SZA'):SetNoInsertLine(.T.)
 
    //-- Fazendo o relacionamento
    aAdd(aRelation, {"ZA_FILIAL", "FWxFilial('SZA')"})
    aAdd(aRelation, {"ZA_COD", "Z8_COD"})
    oModel:SetRelation("DETAIL_SZA", aRelation, SZA->(IndexKey(1)))

Return oModel


/*/{Protheus.doc} ViewDef
ViewDef
@type function
@version 1.0  
@author DOTHINK SISTEMAS - DENER LEMOS
@since 01/08/2022
@return object, ViewDef
/*/
Static Function ViewDef()
	Local oModel   := ModelDef()
	Local oStruSZ8 := FWFormStruct(2, cTabPai)
    Local oStruSZA := FWFormStruct(2, cTabFilho)

    //-- Alteracao especifica da view
    AltStruView(@oStruSZA)

	oView := FWFormView():New()
	oView:SetModel(oModel)
    oView:AddField("VIEW_SZ8", oStruSZ8, "MASTER_SZ8")
    oView:AddGrid("VIEW_SZA", oStruSZA, "DETAIL_SZA")

    oView:CreateHorizontalBox("CABEC", 40)
    oView:CreateHorizontalBox("GRID", 60)
    oView:SetOwnerView("VIEW_SZ8", "CABEC")
    oView:SetOwnerView("VIEW_SZA", "GRID")

    oView:EnableTitleView("VIEW_SZ8", "Cabeçalho Motor Mod.2")
    oView:EnableTitleView("VIEW_SZA", "Processos Motor Mod.2")

    oStruSZ8:RemoveField("Z8_COD")
	oStruSZ8:RemoveField("Z8_OK")
    oStruSZ8:RemoveField("Z8_SD3REC")

    oStruSZA:RemoveField("ZA_COD")
    oStruSZA:RemoveField("ZA_PVDEST")
    oStruSZA:RemoveField("ZA_ITEMPV")

    oView:SetViewProperty("VIEW_SZA", "GRIDDOUBLECLICK", {{|oFormulario, cFieldName, nLineGrid, nLineModel| DbClick(oFormulario, cFieldName, nLineGrid, nLineModel)}})
    oView:SetViewProperty("VIEW_SZA", "GRIDNOORDER")
    oView:SetViewProperty("VIEW_SZA", "SETCSS", {"QTableView { selection-background-color: #1C9DBD; selection-color: #FFFFFF; }"} )

    oStruSZA:SetProperty("ZA_DSCPROC", MVC_VIEW_TITULO, "Descrição Processo")
    oStruSZA:SetProperty("ZA_OBS", MVC_VIEW_TITULO, "Observação Processo")

    //-- Desabilitar o botao "Salvar e Criar Novo"
    oView:SetCloseOnOK({|| .T.})

Return oView


/*/{Protheus.doc} REFATA8A
Rotina que trata os pedido selecionados para execucao 
do Motor Mod.2 e chama a efetivacao do Motor
@type function
@version 1.0  
@author DOTHINK SISTEMAS - DENER LEMOS
@since 01/08/2022
/*/
User Function REFATA8A()
    Local aAreaAnt := GetArea()
    Local cPVDest  := AllTrim(SZ8->Z8_PVDEST)
    Local cItemPV  := AllTrim(SZ8->Z8_ITEMPV)

    If SZ8->Z8_STATUS == "3" //-- "1=A Efetivar;2=Efetivado com erro;3=Efetivado"
        FWAlertWarning("Esse pedido-item <b>" + cPVDest + "-" + cItemPV + "</b> já foi efetivado pelo Motor Mod.2.", "Motor Mod.2 já Efetivado!")
        Return
    EndIf

    If FWAlertYesNo("Confirma a efetivação do Motor Mod.2 da empresa/filial <b>" + cFilDest + "</b> para a empresa/filial <b>" + cFilOrig + "</b>?", "Efetivar " + cPVDest + "-" + cItemPV + "?")
        //-- Habilita semafora da rotina do Motor Mod.2
        If !LockByName("REFATA06"+cEmpAnt+cFilAnt+cPVDest,.T.,.F.,.T.)
            FWAlertError("Esse pedido <b>" + cPVDest + "</b> já está sendo efetivado pelo Motor Mod.2.", "Motor Mod.2 em Execução!")
            Return
        EndIf
        
        //-- Processamento da efetivacao
        MsAguarde({|| U_REFATA06()}, "Efetivando Motor Mod.2", "Efetivando...")

        //-- Desabilita semafora da rotina do Motor Mod.2
        UnLockByName("REFATA06"+cEmpAnt+cFilAnt+cPVDest,.T.,.F.,.T.)
    EndIf

    RestArea(aAreaAnt)

Return


/*/{Protheus.doc} REFATA8B
Funcao que faz "inclusao" de Registros do Motor Mod.2
@type function
@version 1.0  
@author DOTHINK SISTEMAS - DENER LEMOS
@since 01/08/2022
/*/
User Function REFATA8B(cFilOrigem, cPVOrigem)
    Local aAreaAnt  := GetArea()
    Local aAreaSC5  := SC5->(GetArea())
    Local aAreaSZ8  := SZ8->(GetArea())
    Local aProcs    := FWGetSX5("ZP")
    Local cCodMotor := ""
    Local nZ

    Default cFilOrigem := SC2->C2_XFILORI
    Default cPVOrigem  := SC2->C2_XPVORIG

    cCodMotor := GETSX8NUM("SZ8","Z8_COD")
    SZ8->(ConfirmSX8())

    DbSelectArea("SC5")
    SC5->(DbSetOrder(1))

    DbSelectArea("SZ8")
    SZ8->(DbSetOrder(1))

    If SC5->(DbSeek(cFilOrigem + cPVOrigem))
        //-- Cabecalho do Motor Mod.2 Replas
        RecLock("SZ8", .T.)
            SZ8->Z8_FILIAL  := xFilial("SZ8")         //-- Filial do Sistema
            SZ8->Z8_COD     := cCodMotor              //-- Codigo
            SZ8->Z8_PVDEST  := SC2->C2_PEDIDO         //-- Pedido de Venda Destino  
            SZ8->Z8_ITEMPV  := SC2->C2_ITEMPV         //-- Item do Pedido de Venda
            SZ8->Z8_PRODUTO := SC2->C2_PRODUTO        //-- Produto 
            SZ8->Z8_QUANT   := SD3->D3_QUANT          //-- Quantidade Produzida
            SZ8->Z8_DTPROD  := dDataBase              //-- Data da Producao
            SZ8->Z8_HRPROD  := SubStr( Time(), 1, 5 ) //-- Hora da Producao
            SZ8->Z8_USRPROD := __cUserId              //-- Usuario da Producao
            SZ8->Z8_FILORI  := cFilOrigem             //-- Filial de Origem
            SZ8->Z8_PVORIG  := cPVOrigem              //-- Pedido de Venda Origem
            SZ8->Z8_CLIORI  := SC5->C5_CLIENTE        //-- Cliente Origem
            SZ8->Z8_LOJAORI := SC5->C5_LOJACLI        //-- Loja Origem do Cliente
            SZ8->Z8_CLINOME := SC5->C5_XDESCLI        //-- Nome do Cliente
            SZ8->Z8_DTENT   := SC5->C5_FECENT         //-- Data de Entrega
            SZ8->Z8_STATUS  := "1"                    //-- Status -> "1=A Efetivar;2=Efetivado com erro;3=Efetivado"
            SZ8->Z8_SD3REC  := SD3->(Recno())         //-- Recno do registro na SD3
            If SZ8->(FieldPos("Z8_OP")) > 0
                SZ8->Z8_OP := SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN + SC2->C2_ITEMGRD
            EndIf
        SZ8->(MsUnlock())

        //-- Processos do Motor Mod.2 Replas
        For nZ := 1 To Len(aProcs)
            RecLock("SZA", .T.)
                SZA->ZA_FILIAL  := xFilial("SZA") //-- Filial do Sistema
                SZA->ZA_COD     := cCodMotor      //-- Codigo
                SZA->ZA_PVDEST  := SC2->C2_PEDIDO //-- Pedido de Venda Destino  
                SZA->ZA_ITEMPV  := SC2->C2_ITEMPV //-- Item do Pedido de Venda
                SZA->ZA_CODPROC := aProcs[nZ, 03] //-- Codigo do Processo
                SZA->ZA_DSCPROC := aProcs[nZ, 04] //-- Descricao do Processo
                SZA->ZA_STATUS  := "1"            //-- Status -> "1=A Efetivar;2=Efetivado com erro;3=Efetivado"
            SZA->(MsUnlock())
        Next nZ
    EndIf

    RestArea(aAreaSZ8)
    RestArea(aAreaSC5)
    RestArea(aAreaAnt)

Return


/*/{Protheus.doc} RefreshBrw
Funcao que realiza o Refresh/atualizacao da tela
@type function
@version 1.0  
@author DOTHINK SISTEMAS - DENER LEMOS
@since 01/08/2022
@return logical, Retorno logico
/*/
Static Function RefreshBrw()
    Local nPos := oBrowseUp:At()

    If MV_PAR12 == 1
        oBrowseUp:Refresh(.T.)
    ElseIf MV_PAR12 == 2
        oBrowseUp:Refresh(.F.)
        oBrowseUp:GoBottom()
    Else
        oBrowseUp:Refresh(.F.)
        oBrowseUp:GoTo(nPos, .F.)
    EndIf

Return .T.


/*/{Protheus.doc} UpdParam
Funcao que permite selecionar novamente os pedidos
@type function
@version 1.0  
@author DOTHINK SISTEMAS - DENER LEMOS
@since 01/08/2022
@return logical, Retorno logico
/*/
Static Function UpdParam()
    Local cFilter := ""
    Local lRet    := .T.

    If Pergunte("REFATA08", .T.)
        //-- Pega os filtros
        cFilter := GetFilter()

        //oBrowseUp:oTimer:lActive := (MV_PAR12 < 3)
		oBrowseUp:SetFilterDefault(cFilter)
		oBrowseUp:Refresh()
    EndIf

Return lRet


/*/{Protheus.doc} AltStruMdl
Rotina que alterar a estrutura da model
@type function
@version 1.0
@author DO THINK - DENER LEMOS
@since 01/06/2023
@param oStruSZA, object, Objeto da model
/*/
Static Function AltStruMdl(oStruSZA)
    Local aTrig  := {}
    Local bRelac := {|| Iif(SZA->ZA_STATUS == "1", "BR_VERMELHO", Iif(SZA->ZA_STATUS == "2", "BR_CANCEL", "BR_VERDE"))}

	oStruSZA:AddField( AllTrim(""),; //-- [01] Titulo do campo
					   AllTrim(""),; //-- [02] ToolTip do campo
					   "ZA_LEGEND",; //-- [03] Id do Field
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
	aTrig := FwStruTrigger( "ZA_STATUS"                                                                                 ,; //-- Campo dominio
                            "ZA_LEGEND"                                                                                 ,; //-- Campo de contradominio 
                            "Iif(M->ZA_STATUS == '1', 'BR_VERMELHO', Iif(M->ZA_STATUS == '2', 'BR_CANCEL', 'BR_VERDE'))",; //-- Regra de preenchimento  
                            .F.                                                                                         ,; //-- Se posicionara ou nao antes da execucao do gatilhos
                            ""                                                                                          ,; //-- Alias da tabela a ser posicionada
                            1                                                                                           ,; //-- Ordem da tabela a ser posicionada
                            ""                                                                                          ,; //-- Chave de busca da tabela a ser posicionada
                            ""                                                                                           ) //-- Condicao para execucao do gatilho

	oStruSZA:AddTrigger(aTrig[1], aTrig[2], aTrig[3], aTrig[4])

Return


/*/{Protheus.doc} AltStruView
Rotina que alterar a estrutura da view
@type function
@version 1.0
@author DO THINK - DENER LEMOS
@since 01/06/2023
@param oStruSZA, object, Objeto da view
/*/
Static Function AltStruView(oStruSZA)

	oStruSZA:AddField( "ZA_LEGEND" ,; //-- [01] Campo
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


/*/{Protheus.doc} DbClick
Rotina que executa acao, apo duplo clique no browse dos processos
@type function
@version 1.0
@author DO THINK - DENER LEMOS
@since 01/06/2023
@param oMod, object, Objeto da model
@param cCampo, character, Campo
@param nLinGrid, numeric, Linha
@param nLinMod, numeric, Linha da model
@return logical, Retorno logico
/*/
Static Function DbClick(oMod, cCampo, nLinGrid, nLinMod)
    Local cPVDest   := ""
    Local cItemPV   := ""
    Local cCodProc  := ""
    Local cDscProc  := ""
    Local cMemoObs	:= ""
    Local cDetalhe  := ""  
    Local oDlg      := Nil
    Local oFont01   := Nil
    Local oFont02   := Nil
    Local oFont03   := Nil
    Local oModelSZA := Nil

    If !(cCampo $ "ZA_LEGEND/ZA_STATUS/")
        //-- Definicao de fontes
        oFont01 := TFont():New("Tahoma",, -13,, .T.)
        oFont02 := TFont():New("Tahoma",, -12)
        oFont03 := TFont():New("Tahoma",, -11)

        //-- Pega o modelo e dados do processo posicionado
        oModelSZA := oMod:GetModel("VIEW_SZA")
        cPVDest   := oModelSZA:GetValue("ZA_PVDEST")
        cItemPV   := oModelSZA:GetValue("ZA_ITEMPV")
        cCodProc  := oModelSZA:GetValue("ZA_CODPROC")
        cDscProc  := oModelSZA:GetValue("ZA_DSCPROC")
        cMemoObs  := oModelSZA:GetValue("ZA_OBS")

        If !Empty(cCodProc)
            //-- Pega a descricao datalhada do processo
            cDetalhe := GetDetalhe(cCodProc)

            DEFINE MSDIALOG oDlg TITLE "Motor Mod.2 - Processo " + cCodProc FROM 003, 000 TO 340, 427 PIXEL
                //-- Labels
                @ 004, 005 SAY cDscProc SIZE 200, 105 FONT oFont01 OF oDlg COLORS RGB(031,073,125) PIXEL
                @ 014, 005 SAY cDetalhe SIZE 200, 105 FONT oFont02 OF oDlg COLORS RGB(031,073,125) PIXEL

                @ 045, 005 GET oMemo VAR cMemoObs MEMO SIZE 205, 105 OF oDlg PIXEL READONLY
                oMemo:bRClicked := {|| AllwaysTrue()}
                oMemo:oFont := oFont03

                DEFINE SBUTTON FROM 153, 175 TYPE 01 ACTION oDlg:End() ENABLE OF oDlg PIXEL

            ACTIVATE MSDIALOG oDlg CENTER
        EndIf
    EndIf

Return .T.


/*/{Protheus.doc} GetDetalhe
Rotina que retorna a menssagem detalhada do proccesso 
@type function
@version 1.0
@author DO THINK - DENER LEMOS
@since 01/06/2023
@param cCodProc, character, Codigo do processo
@return character, Mensagem do processo
/*/
Static Function GetDetalhe(cCodProc)
    Local cRet := ""

    Do Case
        Case cCodProc == "01"
            cRet := "O Pedido de Venda Destino da [" + cFilDest + "] é alterado após o apontamento "
            cRet += "da produção, essa execução é feita automaticamente. A quantidade "
            cRet += "do PV Destino é igual a quantidade apontada na Ordem de Produção."
        Case cCodProc == "02"
            cRet := "O Pedido de Venda Origem da [" + cFilOrig + "] é alterado após a alteração do "
            cRet += "PV Destino da [" + cFilDest + "], essa execução é feita automaticamente. "
            cRet += "A quantidade do PV Origem é igual a quantidade do PV Destino."
        Case cCodProc == "03"
            cRet := "A Liberação de Crédito/Estoque Pedido de Venda do Serviço da [" + cFilDest + "] "
            cRet += "é feito de forma automatica pelo Motor Mod.2, essa execução é necessaria para "
            cRet += "que o PV do Serviço seja faturado."
        Case cCodProc == "04"
            cRet := "O Faturamento do Serviço da [" + cFilDest + "] para a [" + cFilOrig + "] é feito ao efetivar "
            cRet += "o Motor Mod.2, essa execução é necessaria para que haja cobrança do "
            cRet += "serviço."
        Case cCodProc == "05"
            cRet := "A Tranmissão para o SEFAZ do Pedido de Venda do Serviço da [" + cFilDest + "] "
            cRet += "é feita ao efetivar o Motor Mod.2, essa execução é necessaria "
            cRet += "para ser gerada a nota fiscal do serviço."
        Case cCodProc == "06"
            cRet := "A Geração do Documento de Entrada na [" + cFilOrig + "] é feita de forma automatica "
            cRet += "ao efetivar o Motor Mod.2, essa execução é necessaria para entrar com a nota "
            cRet += "fiscal de serviço na [" + cFilOrig + "].
        Case cCodProc == "07"
            cRet := "A Geração da ST para Retorno das MPs da [" + cFilDest + "] para a [" + cFilOrig + "] "
            cRet += "é feito ao efetivar o Motor Mod.2, essa execução é necessaria para "
            cRet += "retornar os matérias primas para a origem [" + cFilOrig + "].
        Case cCodProc == "08"
            cRet := "A Efetivação da ST para Retorno das MPs da [" + cFilDest + "] para a [" + cFilOrig + "] "
            cRet += "é feito ao efetivar o Motor Mod.2, essa execução é necessaria para "
            cRet += "retornar os matérias primas para a origem [" + cFilOrig + "].
        Case cCodProc == "09"
            cRet := "A Geração da Ordem de Produção Externa da [" + cFilOrig + "] "
            cRet += "é feita ao efetivar o Motor Mod.2, essa execução é necessaria "
            cRet += "para ser gerado o saldo do Produto Acabado na origem [" + cFilOrig + "].
        Case cCodProc == "10"
            cRet := "A Apontamento da Ordem de Produção Externa da [" + cFilOrig + "] "
            cRet += "é feita ao efetivar o Motor Mod.2, essa execução é necessaria "
            cRet += "para ser gerado o saldo do Produto Acabado na origem [" + cFilOrig + "].
        Case cCodProc == "11"
            cRet := "A Transformação dos Produtos de Retorno para Estoque/Sucata é feita "
            cRet += "ao efetivar o Motor Mod.2, essa execução é necessaria para trocar "
            cRet += "os códigos dos produtos que sobraram na produção da [" + cFilDest + "].
        Case cCodProc == "12"
            cRet := "A Geração da ST para Envio das MPs da [" + cFilOrig + "] para a [" + cFilDest + "] "
            cRet += "é feito ao efetivar o Motor Mod.2, essa execução é necessaria para "
            cRet += "enviar os matérias primas transformadas."
    End Case

Return cRet


/*/{Protheus.doc} GetFilter
Rotina que realiza a composicao do filtro padrao
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 01/06/2023
@return character, Retorna filtros
/*/
Static Function GetFilter()
    Local cRet := ""

    cRet += "Z8_FILIAL='"+xFilial("SZ8")+"'"
    cRet += ".And.Z8_PVDEST>='"+MV_PAR01+"'"
    cRet += ".And.Z8_PVDEST<='"+MV_PAR02+"'"
    cRet += ".And.Z8_CLIORI>='"+MV_PAR03+"'"
    cRet += ".And.Z8_CLIORI<='"+MV_PAR04+"'"
    cRet += ".And.Z8_LOJAORI>='"+MV_PAR05+"'"
    cRet += ".And.Z8_LOJAORI<='"+MV_PAR06+"'"
    cRet += ".And.DTos(Z8_DTPROD)>='"+DTos(MV_PAR07)+"'"
    cRet += ".And.DTos(Z8_DTPROD)<='"+DTos(MV_PAR08)+"'"
    If !Empty(MV_PAR09)
        cRet += ".And.Z8_USRPROD=='"+MV_PAR09+"'"
    EndIf
    cRet += ".And.DTos(Z8_DTENT)>='"+DTos(MV_PAR10)+"'"
    cRet += ".And.DTos(Z8_DTENT)<='"+DTos(MV_PAR11)+"'"
    If MV_PAR13 # 1
        cRet += ".And.Z8_STATUS$'1;2'"
    EndIf

Return cRet


/*/{Protheus.doc} REFATA8C
Rotina que chama a tela de parametros por um botao no browse
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 15/06/2023
@return logical, Retorto da funcao UpdParam()
/*/
User Function REFATA8C()
Return UpdParam()
