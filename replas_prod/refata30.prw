#Include "TOTVS.CH"
#Include "FWMVCDEF.CH"
#Include "TOPCONN.CH"
#Include "TbiConn.ch"
#Include "PRTOPDEF.CH"

#Define cTitulo "Monitor Paletização"

/*/{Protheus.doc} refata30
Rotina de Monitoramento de Paletizacao e que possibilita 
@type function
@version 1.0 
@author Marcos P.Aversa
@since 12/2022
/*/
User Function refata30()
	Local cFilOrig := GetMV("RE_FILORIG", .F., "0302")
	Local bLeg     := {|| fLegenda()}

	Private oBrowseSZG := Nil

	If !(cFilAnt == cFilOrig)
		FWAlertError("Somente é permitido acessar o <b>" + cTitulo + "</b> na Filial [<b>" + cFilOrig + "</b>].", "Não Permitido!")
		Return
	EndIf

	oBrowseSZG := FWmBrowse():New()

	oBrowseSZG:SetAlias("SZG")

	oBrowseSZG:AddLegend("ZG_STATUS=='A'", "BLUE", "Pallet Aberto")
	oBrowseSZG:AddLegend("ZG_STATUS=='I'", "RED" , "Pallet Inconsistente")
	oBrowseSZG:AddLegend("ZG_STATUS=='F'", "GREEN","Pallet Fechado")

	oBrowseSZG:AddButton("Legenda", bLeg)

	oBrowseSZG:SetDescription(cTitulo)
	oBrowseSZG:SetTotalDefault('ZG_FILIAL','COUNT', 'Total de Registros')
	oBrowseSZG:DisableReport()
	oBrowseSZG:DisableDetails()
	//oBrowseSZG:SetTimer({|| RefreshBrw() }, 300000)
	oBrowseSZG:SetParam({|| Pergunte("REFATA30", .T.)})

	//-- Ordenacao do botoes na tela
	oBrowseSZG:lOptionConfig := .F.
	aAdd(oBrowseSZG:aButtonsOrder, "Imprimir Rótulo")
	aAdd(oBrowseSZG:aButtonsOrder, "Imprimir Romaneio")
	aAdd(oBrowseSZG:aButtonsOrder, "Visualizar")
	aAdd(oBrowseSZG:aButtonsOrder, "Alterar")

	oBrowseSZG:Activate()

Return


/*/{Protheus.doc} MenuDef
MenuDef
@type function
@version 1.0 
@author DO THINK - DENER LEMOS
@since 13/06/2023
@return array, MenuDef
/*/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE 'Visualizar'        ACTION 'VIEWDEF.refata30'     OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE 'Alterar'           ACTION 'VIEWDEF.refata30'     OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Excluir'           ACTION 'VIEWDEF.refata30'     OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE 'Imprimir Rótulo'   ACTION 'u_refata31()'     	   OPERATION 6 ACCESS 0
	ADD OPTION aRotina TITLE 'Imprimir Romaneio' ACTION 'u_refata32()'         OPERATION 6 ACCESS 0
	ADD OPTION aRotina TITLE 'Tipo Montagem'     ACTION 'u_rfata30a()'         OPERATION 6 ACCESS 0
	ADD OPTION aRotina TITLE 'Transf. PV'        ACTION 'u_rfata30b()' 		   OPERATION 7 ACCESS 0

Return aRotina


/*/{Protheus.doc} ModelDef
Modelo ModelDef 
@type function
@version 1.0 
@author Marcos P.Aversa
@since 13/12/2022
/*/
Static Function ModelDef()
	Local oModel := Nil
	Local oStSZG := FWFormStruct(1, "SZG")
	Local oStSZH := FWFormStruct(1, "SZH")

	// Quando ZG_PALLET mudar, a função fAltPallet será disparada para atualizar o ZG_VOLUME
	oStSZG:AddTrigger("ZG_PALLET", "ZG_VOLUME", {|| .T. }, {|oModel| fAltPallet(oModel)})

	//Quando o usuário alterar o ZG_PALLET inserir os Zeros a esquerda do campo, disparando o gatilho e chamando a função 
	oStSZG:AddTrigger("ZG_PALLET","ZG_PALLET",{|| .T. },{|oModel| NPALLET(oModel)})

	oModel := MPFormModel():New('Palete', /*{ |oModel| PreVld(oModel) }*/ , /*{ |oModel| PosVld(oModel) }*/ ,/* { |oModel| Gravacao(oModel) } */ )
	oModel:AddFields( "MODEL_PALETE", /*cOwner*/, oStSZG)
	oModel:AddGrid( 'MODEL_DET', 'MODEL_PALETE', oStSZH )// Adiciona ao modelo uma componente de grid
	oModel:SetRelation( 'MODEL_DET', { { 'ZH_FILIAL', 'ZG_FILIAL' }, { 'ZH_VOLUME', 'ZG_VOLUME' }} , SZH->( IndexKey( 1 ) ) )
	oModel:SetPrimaryKey( { 'ZG_FILIAL', 'ZG_VOLUME' } )
	oModel:SetDescription("Palete")
	oModel:GetModel( "MODEL_PALETE" ):SetDescription( "Palete/Volume" )
	oModel:GetModel("MODEL_DET"):SetNoInsertLine(.T.)
	
Return oModel


/*/{Protheus.doc} ViewDef
Modelo ViewDef
@type function
@version 1.0 
@author Marcos P.Aversa
@since 13/12/2022
/*/
Static Function ViewDef()
	Local oModel     := ModelDef()
	Local oStructSZG := FWFormStruct(2, "SZG")
	Local oStructSZH := FWFormStruct(2, "SZH")
	Local oViewDef   := FWFormView():New()

	oStructSZH:RemoveField( 'ZH_VOLUME' )
	oStructSZH:RemoveField( 'ZH_STATUS' )
	oStructSZH:RemoveField( 'ZH_PEDIDO' )
	oStructSZH:RemoveField( 'ZH_ITEMPV' )

	//Criando oView
	oViewDef:SetModel(oModel)
	oViewDef:AddField("VIEW_SZG", oStructSZG, "MODEL_PALETE")

	oViewDef:AddGrid("VIEW_SZH", oStructSZH, "MODEL_DET")


	oViewDef:CreateHorizontalBox( 'SUPERIOR', 35 )
	oViewDef:CreateHorizontalBox( 'INFERIOR', 65 )

	oViewDef:SetOwnerView( 'VIEW_SZG', 'SUPERIOR' )
	oViewDef:SetOwnerView( 'VIEW_SZH', 'INFERIOR' )

	//Criando um container com nome tela com 100%
	//oViewDef :CreateHorizontalBox("TELA",100)

	//oViewDef:EnableTitleView('VIEW_SZG', 'Cabeçalho do Volume')
	//oViewDef:EnableTitleView('VIEW_SZH', 'Bobinas do Volume')

	oViewDef:SetCloseOnOk({||.T.})
	oViewDef:SetViewProperty("VIEW_SZH", "GRIDNOORDER")

	//oViewDef:AddUserButton( "Busca Peso", 'SDUSEEK', {|oViewDef| fAtuPBruto()} )
	// Acrescenta um objeto externo ao View do MVC
	//oViewDef:AddOtherObject("VIEW_SZG", {|oViewDef| fAtuF5()} )

Return oViewDef


/*/{Protheus.doc} fAltPallet
Rotina para quando o usuário alterar o numero do pallet ser refletido a alterção no campo volume
@type function
@version 1.0 
@author DO THINK - JOSIGLEISON SILVA
@since 16/12/2025
@return logical, Retorno logico
/*/
Static Function fAltPallet(oModel)
	Local oModelSZG := NIL
	Local oModelSZH := NIL
	Local oModelPad := NIL
	Local cPedido   := ""
	Local cItem     := ""
	Local cPallet   := ""
	Local cNovoVol  := ""
	Local nI        := 0
	If oModel:GetId() == "MODEL_PALETE"
		oModelPad  := oModel:GetModel()
		oModelSZG  := oModel
	Else
		oModelPad  := oModel
		oModelSZG  := oModel:GetModel("MODEL_PALETE")
	EndIf

	oModelSZH := oModelPad:GetModel("MODEL_DET")
	cPedido := oModelSZG:GetValue("ZG_PEDIDO")
	cItem   := oModelSZG:GetValue("ZG_ITEMPV")
	cPallet := oModelSZG:GetValue("ZG_PALLET")
	cNovoVol := PadL(AllTrim(cPedido), 6, "0") + ;
		PadL(AllTrim(cItem), 2, "0")   + ;
		PadL(AllTrim(cPallet), 4, "0")

	If oModelPad:GetOperation() == 4
		For nI := 1 To oModelSZH:Length()
			oModelSZH:GoLine(nI)
			If !oModelSZH:IsDeleted()
				oModelSZH:SetValue("ZH_PEDIDO", cPedido)
				oModelSZH:SetValue("ZH_ITEMPV", cItem)
				oModelSZH:SetValue("ZH_VOLUME", cNovoVol)
			EndIf
		Next nI
	EndIf

Return cNovoVol


/*/{Protheus.doc} fLegenda
Apresenta a Legenda
@type function
@version 1.0 
@author Marcos P.Aversa
@since 13/12/2022
/*/
Static Function fLegenda()
	Local aLegenda   := {}
	Local cxCadastro := "Peso Bruto"

	Aadd( aLegenda, {"BR_AZUL"    ,"Pallet Aberto","ZG_STATUS=='A'"})
	Aadd( aLegenda, {"BR_VERMELHO","Pallet Inconsistente","ZG_STATUS=='I'"})
	Aadd( aLegenda, {"BR_VERDE"   ,"Pallet Fechado","ZG_STATUS=='F'"})

	BrwLegenda(cxCadastro, "Legenda", aLegenda)

Return

/*/{Protheus.doc} RefreshBrw
Rotina para atualizacao automatica da tela
@type function
@version 1.0 
@author DO THINK - DENER LEMOS
@since 14/06/2023
@return logical, Retorno logico
/*/
Static Function RefreshBrw()

	oBrowseSZG:Refresh(.F.)
	oBrowseSZG:GoBottom()

Return .T.


/*/{Protheus.doc} TudoOk
Rotina para validacao geral do pergunte
@type function
@version 1.0 
@author DO THINK - DENER LEMOS
@since 14/06/2023
@return logical, Retorno logico
/*/
Static Function TudoOk()
	Local aAreaAnt := GetArea()
	Local lRet     := .T.

	If Empty(MV_PAR01)
		FWAlertWarning("Informe o <b>Lote</b> para prosseguir.", "Lote não Informado!")
		lRet := .F.
	EndIf

	If lRet .And. Empty(MV_PAR02)
		FWAlertWarning("Informe o <b>Sub-Lote</b> para prosseguir.", "Sub-Lote não Informado!")
		lRet := .F.
	EndIf

	If lRet
		DbSelectArea("SB8")
		SB8->(DbSetOrder(2))
		If !SB8->(DbSeek(xFilial("SB8") + PadR(MV_PAR02, TamSX3("B8_NUMLOTE")[1]) + PadR(MV_PAR01, TamSX3("B8_LOTECTL")[1])))
			FWAlertError("O <b>Lote</b> e <b>Sub-Lote</b> informados não foram localizados ou não existem.", "Não Localizado!")
			lRet := .F.
		EndIf
	EndIf

	RestArea(aAreaAnt)

Return lRet

/*/{Protheus.doc} rfata30a
Função Criada para que na tela Monitor de paletização abra um pop up com a pesquisa do cliente para o operador verificar o tipo de paletização do cliente selecionado,
com base no campo "A1_XTPMONT.
@type function
@version  1.0
@author josigleison.silva@dothink.com.br
@since 11/13/2025
/*/

User Function rfata30a()
	local cCliente
	local cLoja
	local cTpMont

	SetMVValue("RFATA30A", "MV_PAR01", Space(len(SA1->A1_COD)))
	SetMVValue("RFATA30A", "MV_PAR02", Space(len(SA1->A1_LOJA)))

	// Pergunta o cliente e loja antes de abrir o popup
	If Pergunte("RFATA30A", .T., "Cliente")

		cCliente := MV_PAR01
		cLoja    := MV_PAR02

		dbSelectArea("SA1")
		SA1->(dbSetOrder(1))

		//  Verifica se o cliente existe
		If SA1->(dbSeek(xFilial("SA1") + cCliente + cLoja))
			cTpMont  := SA1->A1_XTPMONT

			AtShowLog(cTpMont, "Tipo de montagem do Cliente",,,,)
			if Empty(cTpMont) 
				Alert("Cliente não possui tipo de montagem no cadastro!")
			endif
			
			else
			MsgStop("Cliente não encontrado!", "Atenção")
		EndIf
		
	EndIf

Return

/*/{Protheus.doc} rfata30a
Função Criada para que na tela Monitor de paletização abra um pop up com pedido e item origem e transfira os itens para o pedido destino.
@type function
@version  1.0
@author josigleison.silva@dothink.com.br
@since 16/12/2025
/*/
User Function rfata30b()

	Local lOk             := .F.
	Local cPedDestPadded  := ""
	Local cItemDestPadded := ""
	Local cNovoVolume     := ""
	Local cVolOrig        := ""
	Local oDlg            := NIL
	Local nRecSZG         := SZG->(RecNo())
	Local nOrdemOld       := SZG->(IndexOrd())

	Local cPedOrigAtu     := PadL(AllTrim(SZG->ZG_PEDIDO), 6, '0')
	Local cItemOrigAtu    := PadL(AllTrim(SZG->ZG_ITEMPV), 2, '0')

	Local aRecsSZG        := {}
	Local aRecsSZH        := {}
	Local aDadosSZH       := {}
	Local aDadosSZG       := {}

	Local nX := 0
	Local nY := 0
	Local nI := 0

	Local cPedOrig  := SZG->ZG_PEDIDO
	Local cItemOrig := SZG->ZG_ITEMPV
	Local cPalOrig  := SZG->ZG_PALLET
	Local cFilOrig := SZG->ZG_FILIAL
	Local cPalGrava := ""

	Local cPedDest  := Space(6)
	Local cItemDest := Space(2)
	Local cPalDest  := Space(4)
	local cFilDest  := GetMV( "RE_FILORIG")
	Local oGetFil := NIL


	// Criar esse parâmetro no sistema para ligar ou desligar a rotina de transf. de itens PV.
	Local lAtivo := GetMV("RP_TRANSF", .T., .F.)

	If !lAtivo
		MsgStop("Transferência de itens desativada pelo parâmetro RP_TRANSF.", "Atenção")
		Return .F.
	EndIf

	DEFINE DIALOG oDlg TITLE "Transferência de Itens" FROM 0,0 TO 28, 60

	@ 0.5, 0.5 GROUP oGroup1 TO 6.5, 29 LABEL " Dados de Origem " OF oDlg

	@ 1.5, 2 SAY "Filial Origem:" OF oDlg
	@ 1.5, 16 MSGET cFilOrig PICTURE "@!" SIZE 20, 10 OF oDlg WHEN .F.

	@ 2.5, 2 SAY "Pedido Origem:" OF oDlg
	@ 2.5, 16 MSGET cPedOrig PICTURE "@!" SIZE 40, 10 OF oDlg WHEN .F.

	@ 3.5, 2 SAY "Item Origem:" OF oDlg
	@ 3.5, 16 MSGET cItemOrig PICTURE "@!" SIZE 20, 10 OF oDlg WHEN .F.

	@ 4.5, 2 SAY "Pallet Origem:" OF oDlg
	@ 4.5, 16 MSGET cPalOrig PICTURE "@!" SIZE 30, 10 OF oDlg WHEN .F.

	@ 6.8, 0.5 GROUP oGroup2 TO 14.5, 29 LABEL " Dados de Destino " OF oDlg

	@ 8.5, 2 SAY "Filial Destino:" OF oDlg
	@ 8.5, 16 MSGET oGetFil VAR cFilDest PICTURE "@!" SIZE 20, 10 OF oDlg VALID VldFilDest(cFilDest)

	@ 9.5, 2 SAY "Pedido Destino:" OF oDlg
	@ 9.5, 16 MSGET cPedDest PICTURE "@!" SIZE 40, 10 OF oDlg VALID VldPedDest(cFilDest,cPedDest)

	@ 10.5, 2 SAY "Item Destino:" OF oDlg
	@ 10.5, 16 MSGET cItemDest PICTURE "@!" SIZE 20, 10 OF oDlg

	@ 11.5, 2 SAY "Pallet Destino (opcional):" OF oDlg
	@ 11.5, 16 MSGET cPalDest PICTURE "@!" SIZE 30, 10 OF oDlg

	@ 17, 12 BUTTON oBtnOk PROMPT "OK" SIZE 40, 12 OF oDlg ACTION ( ;
		Iif( Empty(AllTrim(cPedDest)) .Or. Empty(AllTrim(cItemDest)), ;
		MsgStop("Pedido e Item obrigatórios!", "Atenção"), ;
		( lOk := .T., oDlg:End() ) ) )

	@ 17, 36 BUTTON oBtnCancel PROMPT "Cancelar" SIZE 40, 12 OF oDlg ACTION ( oDlg:End() )

	ACTIVATE DIALOG oDlg CENTERED  ON INIT ( cFilDest := GetMV("RE_FILORIG"), oGetFil:Refresh() )

	If !lOk
		Return .F.
	EndIf

	cPedDestPadded  := PadL(AllTrim(cPedDest), 6, '0')
	cItemDestPadded := PadL(AllTrim(cItemDest), 2, '0')

	SZG->(DbSetOrder(1))

		//BLOQUEIA TRANSFERÊNCIA PARA ELE MESMO		 
		If cPedDestPadded == cPedOrigAtu .And. ;
		cItemDestPadded == cItemOrigAtu

			MsgStop("Não é permitido transferir para o mesmo Pedido/Item!", "Atenção")

			SZG->(DbSetOrder(nOrdemOld))
			SZG->(DbGoTo(nRecSZG))
			Return .F.

		EndIf

		If !Empty(AllTrim(cPalDest))

			SZG->(DbSetOrder(1))

			If SZG->(DbSeek(xFilial("SZG") + cPedDestPadded + cItemDestPadded))

				While !SZG->(Eof()) .And. ;
					SZG->ZG_PEDIDO == cPedDestPadded .And. ;
					SZG->ZG_ITEMPV == cItemDestPadded .And.;
					SZG->ZG_FILIAL == cFilDest

					If AllTrim(SZG->ZG_PALLET) == PadL(AllTrim(cPalDest),4,'0')

						MsgStop("Este Pallet e Item já existe no Pedido destino!", "Atenção")

						SZG->(DbSetOrder(nOrdemOld))
						SZG->(DbGoTo(nRecSZG))
						Return .F.

					EndIf

					SZG->(DbSkip())
				EndDo

			EndIf

		EndIf
	If Empty(AllTrim(cPalDest))

		If !MsgYesNo("Transferir TODAS as linhas do Pedido " + ;
				cPedOrigAtu + " Item " + cItemOrigAtu + " ?", "Confirmação")
			Return .F.
		EndIf

		SZG->(DbSeek(xFilial("SZG") + cPedOrigAtu + cItemOrigAtu))
		While !SZG->(Eof()) .And. ;
				SZG->ZG_PEDIDO == cPedOrigAtu .And. ;
				SZG->ZG_ITEMPV == cItemOrigAtu

			AAdd(aRecsSZG, SZG->(RecNo()))
			SZG->(DbSkip())
		EndDo
	Else

		AAdd(aRecsSZG, nRecSZG)
	EndIf

		For nX := 1 To Len(aRecsSZG)

			SZG->(DbGoTo(aRecsSZG[nX]))

			cVolOrig := SZG->ZG_VOLUME

			If Empty(AllTrim(cPalDest))
				cPalGrava := SZG->ZG_PALLET
			Else
				cPalGrava := cPalDest
			EndIf

			cNovoVolume := cPedDestPadded + ;
				cItemDestPadded + ;
				PadL(AllTrim(cPalGrava), 4, '0')

			aDadosSZG := {}
			For nI := 1 To SZG->(FCount())
				AAdd(aDadosSZG, SZG->(FieldGet(nI)))
			Next

			If SZG->(RecLock("SZG", .T.))
				For nI := 1 To SZG->(FCount())
					SZG->(FieldPut(nI, aDadosSZG[nI]))
				Next

				SZG->ZG_FILIAL := cFilDest
				SZG->ZG_PEDIDO := cPedDestPadded
				SZG->ZG_ITEMPV := cItemDestPadded
				SZG->ZG_PALLET := cPalGrava
				SZG->ZG_VOLUME := cNovoVolume

				// GUARDA O VOLUME DE ORIGEM 
				SZG->ZG_VOLORI := cVolOrig

				SZG->(MsUnlock())
			EndIf

			aRecsSZH := {}
			SZH->(DbSetOrder(1))

			If SZH->(DbSeek(xFilial("SZH") + cVolOrig))
				While !SZH->(Eof()) .And. SZH->ZH_VOLUME == cVolOrig
					AAdd(aRecsSZH, SZH->(RecNo()))
					SZH->(DbSkip())
				EndDo
			EndIf

			For nY := 1 To Len(aRecsSZH)

				SZH->(DbGoTo(aRecsSZH[nY]))

				aDadosSZH := {}
				For nI := 1 To SZH->(FCount())
					AAdd(aDadosSZH, SZH->(FieldGet(nI)))
				Next

				If SZH->(RecLock("SZH", .T.))
					For nI := 1 To SZH->(FCount())
						SZH->(FieldPut(nI, aDadosSZH[nI]))
					Next

					SZH->ZH_FILIAL := cFilDest
					SZH->ZH_PEDIDO := cPedDestPadded
					SZH->ZH_ITEMPV := cItemDestPadded
					SZH->ZH_VOLUME := cNovoVolume
					
					SZH->(MsUnlock())
				EndIf

				SZH->(DbGoTo(aRecsSZH[nY]))
				If SZH->(RecLock("SZH", .F.))
					SZH->(DbDelete())
					SZH->(MsUnlock())
				EndIf

			Next nY

			SZG->(DbGoTo(aRecsSZG[nX]))
			If SZG->(RecLock("SZG", .F.))
				SZG->(DbDelete())
				SZG->(MsUnlock())
			EndIf

		Next nX

		

	SZG->(DbSetOrder(nOrdemOld))
	SZG->(DbGoTo(nRecSZG))

	MsgInfo("Transferência realizada com sucesso.", "SUCESSO")

Return .T.


/*/{Protheus.doc} 
Rotina para validar se existe a filial digitada.
@type function
@version 1.0 
@author DO THINK - Josigleison Silva
@since 28/05/2026
@return logical, Retorno logico
/*/
Static Function VldFilDest(cFilDest)

    Local aArea      := FWGetArea()
    Local aCampos    := {"M0_CODFIL"}
    Local aEncontrou := {}

    cFilDest := AllTrim(cFilDest)

    If Empty(cFilDest)

        FWRestArea(aArea)

        MsgStop("Informe a Filial Destino!")

        Return .F.

    EndIf

    aEncontrou := FWSM0Util():GetSM0Data(, cFilDest, aCampos)

    FWRestArea(aArea)

    If Len(aEncontrou) == 0

        MsgStop("Filial não encontrada!", "Atenção")

        Return .F.

    EndIf

Return .T.



/*/{Protheus.doc} 
Rotina para validar se o pedido existe na filial destino quando realizar a transferencia de itens.
@type function
@version 1.0 
@author DO THINK - Josigleison Silva
@since 28/05/2026
@return logical, Retorno logico
/*/
Static Function VldPedDest(cFilDest,cPedDest)

    Local cPedido := PadL(AllTrim(cPedDest),6,"0")

    DbSelectArea("SC5")
    SC5->(DbSetOrder(1))

    If !SC5->(DbSeek(cFilDest + cPedido))

        MsgStop("Pedido não existe na filial " + cFilDest + " !","Atenção")
        Return .F.

    EndIf

Return .T.


/*/{Protheus.doc} 
Rotina para validacao validação do campo ZG_PALLET da tabela SZG para que quando o usuário alterar o campo inserir em tela os "Zeros",
a esquerda.
@type function
@version 1.0 
@author DO THINK - Josigleison Silva
@since 26/02/2026
@return logical, Retorno logico
/*/
Static Function Npallet(oModel)

    Local nTamanho  := TamSX3("ZG_PALLET")[1]
    Local cNupallet := oModel:GetValue("ZG_PALLET")

    If !Empty(cNupallet)

        cNupallet := PadL(AllTrim(cNupallet), nTamanho, "0")
        oModel:SetValue("ZG_PALLET", cNupallet, .F.)

    EndIf

Return .T.



/*/{Protheus.doc} 
Gatilho para que quando o usuario informar ou só digitar o código do cliente gatilhar a loja, conforme a função rfata30a()
@type function
@version 1.0 
@author DO THINK - Josigleison Silva
@since 07/05/2026
@return logical, Retorno logico
/*/
User Function RFATAGAT()

	Local lRet := .T.
	Local cPar := ReadVar()

	If Select("SA1") == 0
		DbUseArea(.T., "TOPCONN", RetSqlName("SA1"), "SA1", .F., .T.)
	EndIf

	DbSelectArea("SA1")

	// Quando alterar o CLIENTE
	If cPar == "MV_PAR01"

		SA1->(DbSetOrder(1))

		If SA1->(DbSeek(xFilial("SA1") + ;
			PadR(MV_PAR01, TamSX3("A1_COD")[1])))

			// Preenche a loja automaticamente
			MV_PAR02 := SA1->A1_LOJA

		Else
			CBAlert("Cliente nao localizado", "Nao existe", .T., 3000)
			lRet := .F.
		EndIf

	EndIf

Return lRet
