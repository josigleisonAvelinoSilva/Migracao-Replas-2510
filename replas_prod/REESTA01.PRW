#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"


#DEFINE OP_EFE "011" //-- Efetivar
#DEFINE OP_ALT "004" //-- Alterar


/*/{Protheus.doc} REESTA01
Rotina especifica de Solicitacao de Transferencia Replas
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 07/06/2022
@obs Projeto Novo PCP
/*/
User Function REESTA01()
	Local oBrowse := Nil

	Private cCadastro    := "Solicitação de Transferência Replas"
	Private c311Lote     := ""
	Private c311SLote    := ""
	Private d311DtVld    := CToD( "  /  /  " )
	Private c311LocEnd   := ""
	Private c311NumSer   := ""
	Private l311Gtl      := .F.
    Private cXFilPedFilm := GetMV( "RE_FILORIG", .F., "0302" ) //-- Indica a Filial onde o PV do Cliente e incluido. Somente para produtos do tipo "Filme" (Replas)
    Private cXFilPrdFilm := GetMV( "RE_FILDEST", .F., "0201" ) //-- Indica a Filial onde o PV de Producao e incluido. Somente para produtos do tipo "Filme" - (Industria MM SP)
	Private cXFilArmFilm := GetMV( "RE_FILARM", .F., "0104" )  //-- Indica a Filial de armazenagem de produtos do tipo "Filme" - (Armazem Fechado)

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("NNS")
	oBrowse:SetDescription( "Solicitação de Transferência Replas" )
	//-- Legendas
	oBrowse:AddLegend( "NNS_STATUS == '1'", "GREEN" , "Liberado" )
	oBrowse:AddLegend( "NNS_STATUS == '2'", "RED"   , "Transferido" )
	oBrowse:AddLegend( "NNS_STATUS == '3'", "ORANGE", "Efetivado com PV Bloqueado" )

	SetKey( VK_F4, {|| ShowF4() } )

	oBrowse:Activate()

Return


/*/{Protheus.doc} MenuDef
Definicao do Menu
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 07/06/2022
@return array, Array com MenuDef
/*/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE "Incluir"        	ACTION "VIEWDEF.REESTA01" OPERATION OP_INCLUIR    ACCESS 0           //-- Incluir
	ADD OPTION aRotina TITLE "Visualizar"     	ACTION "VIEWDEF.REESTA01" OPERATION OP_VISUALIZAR ACCESS 0           //-- Visualizar
	ADD OPTION aRotina TITLE "Alterar"        	ACTION "U_REESTA1A"       OPERATION OP_ALTERAR    ACCESS 0 ID OP_ALT //-- Alterar
	ADD OPTION aRotina TITLE "Excluir" 	      	ACTION "U_REESTA1B"       OPERATION OP_EXCLUIR    ACCESS 3           //-- Excluir
	ADD OPTION aRotina TITLE "Efetivar"       	ACTION "U_REESTA1C"       OPERATION 4             ACCESS 0 ID OP_EFE //-- Efetivar
	ADD OPTION aRotina TITLE "Copiar Transf." 	ACTION "U_REESTA1D"       OPERATION OP_INCLUIR    ACCESS 0           //-- Copiar Transferencia (Copia os dados de outra transferencia ja efetivada)
	//ADD OPTION aRotina TITLE "Importar Bobinas" ACTION "U_REESTA1E"       OPERATION OP_INCLUIR    ACCESS 0   
	//ADD OPTION aRotina TITLE "Copiar Transf." ACTION "VIEWDEF.REESTA01"	OPERATION OP_COPIA 		ACCESS 0  	//'Copia'

Return aRotina

/*/{Protheus.doc} ModelDef
Definicao do Modelo de Dados
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 07/06/2022
@return object, Objeto do Modelo
/*/
Static Function ModelDef()
	Local oModel	 := Nil
	Local oStrNNS	 := FWFormStruct( 1, "NNS" )
	Local oStrNNT	 := FWFormStruct( 1, "NNT" )
	Local aNoCopy	 := { "NNS_STATUS", "NNS_SOLICT", "NNS_DATA" }
	Local aNoCopyNNT := { "NNT_DOC", "NNT_SERIE" }
	Local aUnique    := oStrNNT:GetTable()[FORM_STRUCT_TABLE_ALIAS_PK]
	Local nCodPos    := aScan( aUnique, "NNT_COD" )
	Local lNposPdVen := oStrNNT:HasField( "NNT_NUMPED" )

	oModel := MPFormModel():New( "XREESTA01", , {|oModel| ActiveMod( oModel, 1 ), PosValid( oModel )}, {|oModel| Grava( oModel )} )

	oModel:AddFields( "NNSMASTER", , oStrNNS )
	oModel:AddGrid( "NNTDETAIL", "NNSMASTER", oStrNNT, /*bPreValidacao*/, {|oModelNNT| LinhaOk(oModelNNT)} /*bPosValidacao*/, /*bCarga*/ )

	oModel:SetRelation( "NNTDETAIL", { { "NNT_FILIAL", "xFilial('NNT')" }, { "NNT_COD", "NNS_COD" } }, NNT->( IndexKey(1) ) )

	oModel:GetModel( "NNSMASTER" ):SetDescription( "Cabeçalho Transferência Replas" )
	oModel:GetModel( "NNTDETAIL" ):SetDescription( "Itens Transferência Replas" )

	//-- Inclui valid para o campo NNT_NSERIE
	oStrNNT:SetProperty( "NNT_NSERIE", MODEL_FIELD_VALID, {|| A311NSerie()} )

	oModel:SetPrimaryKey( { "NNS_FILIAL", "NNS_COD" } )

	/*A coluna NNT_COD so e preenchida no momento em que os dados do formulario sao commitados.
	Por isso, em caso de Alteração, os dados inseridos anteriormente vêem com esse campo preenchido, 
	e novas linhas não, podendo comprometer a chave única.*/
	If nCodPos > 0
		aDel( aUnique, nCodPos )
		aSize( aUnique, Len(aUnique) - 1 )
	EndIf

	oModel:GetModel( "NNTDETAIL" ):SetUniqueLine( aUnique )

	If lNposPdVen
		aAdd( aNoCopyNNT, "NNT_NUMPED" )
	EndIf

    If !IsInCallStack( "U_REESTA04" )	
		oStrNNT:AddTrigger( 'NNT_LOTECT'  , 'NNT_QUANT', {|| .T.}, {|oModel| TrigQuant(oModel)})
		oStrNNT:AddTrigger( 'NNT_NUMLOT'  , 'NNT_QUANT', {|| .T.}, {|oModel| TrigQuant(oModel)})
	Endif

	//-- Configura campos que nao serao considerados ao copiar registro
	oModel:GetModel( "NNSMASTER" ):SetFldNoCopy( aNoCopy )
	oModel:GetModel( "NNTDETAIL" ):SetFldNoCopy( aNoCopyNNT )

	oModel:SetActivate( {|oModel| ActiveMod( oModel, 2 )} )

Return oModel


/*/{Protheus.doc} ViewDef
Definicao da Interface
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 07/06/2022
@return object, Objeto da Interface
/*/
Static Function ViewDef()
	Local oView   := Nil
	Local oModel  := ModelDef()
	Local oStrNNS := FWFormStruct( 2, "NNS", {|cCampo| !AllTrim(cCampo)+"," $ "NNS_STATUS, NNS_JUSTIF, NNS_ESPECI,"} )
	Local oStrNNT := FWFormStruct( 2, "NNT", {|cCampo| !AllTrim(cCampo)+"," $ "NNT_COD, NNT_LOCALI, NNT_NSERIE, NNT_POTENC, NNT_LOCDES, NNT_LOTED, NNT_DTVALD,"} )

	oView := FWFormView():New()

	oView:SetModel(oModel)

	oView:AddField( "NNSMASTER", oStrNNS, "NNSMASTER" )
	oView:AddGrid( "NNTDETAIL", oStrNNT, "NNTDETAIL" )

	oView:CreateHorizontalBox( "BOXCIMA", 40 )
	oView:CreateHorizontalBox( "BOXBAIXO", 60 ) 

	oView:SetOwnerView( "NNSMASTER", "BOXCIMA" )
	oView:SetOwnerView( "NNTDETAIL", "BOXBAIXO" ) 

	//oView:EnableTitleView( "NNSMASTER", "Documento de Transferência" )
	oView:EnableTitleView( "NNTDETAIL", "Dados para Transferência" )

	oView:AddUserButton( "Replicar TES", "CLIPS", {||  RepTES() }, , , { MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE }, .F. )            

	//-- Altera a descricao do objeto da View na tela 
	oView:oModel:cDescription := "Solicitação de Transferência Replas"

Return oView


/*/{Protheus.doc} REESTA1A
Altera o registro de solicitacao de tranferencia
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 07/06/2022
/*/
User Function REESTA1A()
	Local cView   := "REESTA01"
	Local cStatus := NNS->NNS_STATUS

	cOpId311 := OP_ALT

	If cStatus == "1"
		FwExecView( "Alterar", cView, MODEL_OPERATION_UPDATE, , {|| .T.} )
	ElseIf cStatus == "2"
		Help( Nil, Nil, "TRFNAOALTERA", Nil, "Não é possível alterar um registro Transferido.", 1, 0 )
	Endif

Return


/*/{Protheus.doc} REESTA1B
Exclui o registro de solicitacao de tranferencia
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 07/06/2022
/*/
User Function REESTA1B()
	Local cView   := "REESTA01"
	Local cStatus := NNS->NNS_STATUS

	If cStatus == "1"
		FwExecView( "Excluir", cView, MODEL_OPERATION_DELETE, , {|| .T.} )
	Else
		Help( Nil, Nil, "TRFNAOEXCLUI", Nil, "Não é possível excluir um registro Transferido.", 1, 0 )
	Endif

Return


/*/{Protheus.doc} REESTA1C
Efetiva o registro de solicitacao de tranferencia
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 07/06/2022
/*/
User Function REESTA1C() //-- A311Efetiv
	Local cView   := "REESTA01"
	Local cStatus := NNS->NNS_STATUS

	cOpId311 := OP_EFE

	If cStatus == "1"
		FwExecView( "Efetivar", cView, MODEL_OPERATION_UPDATE, , {|| .T.} )
	Else
		Help( Nil, Nil, "TRFNAOEFETIVA", Nil, "Não é possível efetivar um registro Transferido.", 1, 0 )
	EndIf

Return


//-- Rotina para realizar a copia de outra tranferencia ja efetivada para evitar novas digitacoes
User Function REESTA1D()
	Local cView   := "REESTA01"
	Local cStatus := NNS->NNS_STATUS

	If cStatus == "2"
		FwExecView( "Copiar Transferência", cView, MODEL_OPERATION_INSERT, , {|| .T.} )
	Else
		Help( Nil, Nil, "TRFNAOCOPIA", Nil, "Não é possível copiar uma transfêrencia em aberto ou ainda não efetivada.", 1, 0 )
	EndIf

Return


/*/{Protheus.doc} LinhaOk
Rotina de linha Ok dos itens da tela, modelo NNT
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 07/06/2022
@param oModelNNT, object, Objeto do modelo NNT
@return logical, Retorno logico
/*/
Static Function LinhaOk(oModelNNT) //-- A311LinOk
	Local aAreaSB1	 := SB1->( GetArea() )
	Local aAreaSB2	 := SB2->( GetArea() )
	Local aAreaSA1	 := SA1->( GetArea() )
	Local aAreaNNT	 := NNT->( GetArea() )
	Local lRet		 := .T.
	Local lPermNegat := GetMv( "RE_ESTNEG", .F., "N" )  == "S"  //-- "MV_ESTNEG"
	Local lEmpPrev   := GetMv( "MV_QTDPREV" ) == "S"
	Local lRastroL	 := .F.
	Local lRastroS	 := .F.
	Local lLocalizO	 := .F.
	Local lLocalizD	 := .F.
	Local lSaldoSemR := Nil
	Local cFilBkp	 := FWCodFil()
	Local cCodNNT	 := oModelNNT:GetValue( "NNT_COD" )
	Local cProduto	 := oModelNNT:GetValue( "NNT_PROD" )
	Local cProdDes	 := oModelNNT:GetValue( "NNT_PRODD" )
	Local cFilDest	 := oModelNNT:GetValue( "NNT_FILDES" )
	Local cFilOrig	 := oModelNNT:GetValue( "NNT_FILORI" )
	Local cArmazem	 := oModelNNT:GetValue( "NNT_LOCAL" )
	Local cArmDest	 := oModelNNT:GetValue( "NNT_LOCLD" )
	Local cLocaliza	 := oModelNNT:GetValue( "NNT_LOCALI" )
	Local cLocalDes	 := oModelNNT:GetValue( "NNT_LOCDES" )
	Local cNumSerie	 := oModelNNT:GetValue( "NNT_NSERIE" )
	Local cLoteCtl	 := oModelNNT:GetValue( "NNT_LOTECT" )
	Local cLote		 := oModelNNT:GetValue( "NNT_NUMLOT" )
	Local nQuant	 := oModelNNT:GetValue( "NNT_QUANT" )
	Local cLoteD     := oModelNNT:GetValue( "NNT_LOTED" )
	Local dDataDest	 := oModelNNT:GetValue( "NNT_DTVALD" )
	Local cCGCDest	 := A311FilCGC( cFilDest )
	Local cCGCOri	 := A311FilCGC( cFilOrig )
	Local nQtdTotal	 := SomaGrid( oModelNNT )
	Local nQtdEst	 := 0
	Local nQtdNumLt	 := TamSx3( "B8_NUMLOTE" )[1]
	Local oModel	 := FWModelActive()
	Local oModelNNS	 := oModel:GetModel( "NNSMASTER" )
	Local dDataEmis	 := oModelNNS:GetValue( "NNS_DATA" )
	Local aSaveLines := FWSaveRows()
	Local lEfetiva	 := IsInCallStack( "U_REESTA1C" )
	Local lAltera	 := oModel:GetOperation() == MODEL_OPERATION_UPDATE
	Local lAuto311	 := Type( "cOpId311" ) == "C" .And. cOpId311 == OP_EFE .And. !Empty( oModelNNT:GetValue( "NNT_SERIE" ) )
	Local nQtdOrig	 := 0
	Local lEstoque   := .T.
	Local cTES 		 := oModelNNT:GetValue( "NNT_TS" )
	Local cGrEmp	 := FWGrpCompany()
	Local aSM0 		 := FWLoadSM0(.T., .T.)

	/*Posicao 01: Empresa Ex( T1 )
	Posicao 02: Filial  Ex( D MG 01 )
	Posicao 11: Perm. Acesso .T. / .F. Ex( .F. )*/
	If Ascan( aSM0, { | x | AllTrim( x[01] ) == AllTrim( cGrEmp ) .And. AllTrim( x[02] ) == AllTrim( cFilDest ) .And. !( x[11] ) } ) > 0
		cMsg := "O usuário " + AllTrim( UsrFullName( RetCodUsr() ) ) + " não possui permissão para utilizar a Filial " + AllTrim( cFilDest )
		Help( " ", 1, "A310PERMFIL", Nil, cMsg, 1, 0 )
		lRet := .F.
	EndIf

	If lRet
		//-- Verifica se os campos de quantidade e armazem de destido foram preenchidos
		If Empty( nQuant ) .Or. Empty( cArmDest )
			Help( " ", 1, "OBRIGAT2" )
			lRet := .F.
		EndIf

		//-- Verifica o conteudo
		If lRet
			lRet := ContIgual()
		EndIf

		//-- Inicia as validacoes de Cliente/Fornecedor, TES e outros
		If lRet
			lRastroL  := Rastro( cProduto, "L" )
			lRastroS  := Rastro( cProduto, "S" )
			lLocalizO := Localiza( cProduto )
			
			A311TrcFil( cFilDest )
			lLocalizD := Localiza( cProdDes )
			A311TrcFil( cFilBkp )

			//-- Validacaes para solicitacao de transferencia
			If cFilDest # cFilOrig
				//-- Validacao atualizacao de estoque
				SF4->( DbSetOrder(1) )
				If !( SF4->( DbSeek( xFilial("SF4") + cTES ) ) )
					Help( Nil, Nil, "TRFTESSAIDA", Nil, "A TES de Saida não foi informada ou não existe.", 1, 0, Nil, Nil, Nil, Nil, Nil, { "Informe uma TES de Saida para prosseguir." } )
					lRet := .F.
				Else
					lEstoque := SF4->F4_ESTOQUE == "S"
				EndIf

				SA1->( DbSetOrder(3) )
				If !( SA1->( DbSeek( xFilial("SA1") + cCGCDest ) ) )
					Help( Nil, Nil, "TRFFILIALDCLI", Nil, "A filial de destino não é cliente da filial de origem.", 1, 0, Nil, Nil, Nil, Nil, Nil, { "Cadastre a filial destino como cliente na filial de origem." } )
					lRet := .F.
				EndIf

				If lRet
					A311TrcFil( cFilDest )
					SA2->( DbSetOrder(3) )
					If !( SA2->( DbSeek( xFilial("SA2") + cCGCOri ) ) )
						Help( Nil, Nil, "TRFFILIALDFOR", Nil, "A filial de destino não é fornecedor da filial de origem.", 1, 0, Nil, Nil, Nil, Nil, Nil, { "Cadastre a filial destino como fornecedor na filial de origem." } )
						lRet := .F.
					EndIf
					A311TrcFil( cFilBkp )
				EndIf

				//-- Verifica se exite condicao de pagamento para a filial destino
				If lRet
					SA1->( DbSetOrder(3) )
					If SA1->( DbSeek( xFilial("SA1") + cCGCDest ) )
						If Empty( SA1->A1_COND )
							Help( Nil, Nil, "TRFFILIALDCON", Nil, "Não existe condição de pagamento cadastrada para a filial destino no cadastro de clientes.", 1, 0, Nil, Nil, Nil, Nil, Nil, { "Cadastre uma condição de pagamento para a filial destino." } )
							lRet := .F.
						Endif
					Endif
				Endif

				//-- Verifica se os produtos origem e destino sao iguais
				If lRet .And. cProduto # cProdDes
					Help( Nil, Nil, "TRFPRODUT", Nil, "Não é permitido realizar solicitacao de transferência com Produtos Diferentes.", 1, 0 )
					lRet := .F.
				EndIf
			EndIf
		EndIf

		//-- Validacoes de estoque
		If lRet .And. lEstoque
			If !lPermNegat .And. ( !(lRastroL .Or. lRastroS) .And. (!lLocalizO .And. !lLocalizD) .Or. IntDL( cProduto ) )
				//-- Verifica se deve subtrair a reserva do saldo disponivel
				If IntDL(cProduto) .And. lLocalizO .And. cProduto == cProdDes .And. cArmazem == cArmDest .And. cLocaliza # cLocalDes
					lSaldoSemR := .F.
				EndIf

				SB2->( DbSetOrder(1) )
				If SB2->( DbSeek( xFilial("SB2") + cProduto + cArmazem ) )
					//-- Deve sempre considerar o saldo disponivel (desconsiderando o empenho)
					nQtdEst := SaldoMov( Nil, .F., Nil, Nil, Nil, Nil, lSaldoSemR, dDataEmis )
				EndIf

				If oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetOperation() == MODEL_OPERATION_UPDATE
					//-- Se houver saldo e nao atende a demanda, deve bloquear
					If (nQtdEst <= 0) .Or. QtdComp( nQtdEst ) < QtdComp( nQtdTotal )
						Help( Nil, Nil, "TRFNEGAT", Nil, "Não existe quantidade [" + AllTrim(cProduto) + "] suficiente em estoque para atender esta requisição.", 1, 0 )
						lRet := .F.
					EndIf
				EndIf
			ElseIf lLocalizO
				If !Empty( cLocaliza )
					SBE->( DbSetOrder(1) )
					If SBE->( DbSeek( xFilial("SBE") + cArmazem + cLocaliza ) )
						nQtdEst := SaldoSBF( cArmazem, cLocaliza, cProduto, cNumSerie, cLoteCtl, cLote )
					EndIf

					If (oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. lAltera)
						If lAltera .Or. ( lEfetiva .Or. lAuto311 )
							If NNT->( DbSeek( xFilial("NNT") + cCodNNT + cFilOrig + cProduto + cArmazem + cLocaliza + cNumSerie + cLoteCtl + cLote + cFilDest + cProdDes + cArmDest + cLocalDes + cLoteD ) )
								nQtdOrig := NNT->NNT_QUANT
							Else
								nQtdOrig := 0
							EndIf

							//-- Se houver saldo e nao atende a demanda deve bloquear
							If (nQtdEst + nQtdOrig - nQtdTotal < 0)
								Help( Nil, Nil, "TRFSALDOLOCLZ", Nil, "O produto  não  tem  saldo  Enderecado suficiente ou o Endereço selecionado não tem saldo suficiente.", 1, 0 )
								lRet := .F.
							EndIf
						Else
							//-- Se houver saldo e nao atende a demanda deve bloquear
							If (nQtdEst <= 0) .Or. QtdComp( nQtdEst ) < QtdComp( nQtdTotal )
								Help( Nil, Nil, "TRFSALDOLOCLZ", Nil, "O produto  não  tem  saldo  Enderecado suficiente ou o Endereço selecionado não tem saldo suficiente.", 1, 0 )
								lRet := .F.
							EndIf
						EndIf
					EndIf
				Else
					Help( Nil, Nil, "TRFLOCALIZOBR", Nil, "Quando o produto utiliza controle de Endereço, deve ter preenchido no movimento o campo Endereço, Número de Série ou os dois.", 1, 0 )
					lRet:= .F.
				EndIf
			ElseIf lRastroL .Or. lRastroS
				If lRastroL
					If !Empty( cLoteCtl )
						SB8->( DbSetOrder(2) )
						If SB8->( DbSeek( xFilial("SB8") + If( lRastroS, cLote, Space(6) ) + cLoteCtl + cProduto + cArmazem ) )
							nQtdEst:= SaldoLote( cProduto, cArmazem, cLoteCtl, Nil, Nil, Nil, Nil, dDataBase, , .T. )
						EndIf

						If oModel:GetOperation() == MODEL_OPERATION_INSERT .OR. oModel:GetOperation() == MODEL_OPERATION_UPDATE
							//-- Se houver saldo e não atende a demanda, deve bloquear
							If (nQtdEst <= 0) .OR. QtdComp( nQtdEst ) < QtdComp( nQtdTotal )
								Help( Nil, Nil, "TRFNEGAT", Nil, "Não existe quantidade suficiente em estoque para atender esta requisição.", 1, 0 )
								lRet := .F.
							EndIf
						EndIf
					Else
						Help( Nil, Nil, "TRFLOTECTOBR", Nil, "Quando o produto utiliza controle de Rastro, deve ter preenchido no movimento o campo Lote do produto.", 1, 0 )
						lRet:= .F.
					EndIf

					If lRet
						SB8->( DbSetOrder(2) )
						SB8->( DbSeek( xFilial("SB8") + Space( nQtdNumLt ) + cLoteD + cProdDes + cArmDest ) )

						If !Empty(dDataDest) .And. !Empty( SB8->B8_DTVALID ) .And. (dDataDest # SB8->B8_DTVALID)
							If !lAuto311
								Help( Nil, Nil, "A240DTVALDEST", Nil, "A Data de validade do lote devera ser igual a data informada no momento da criação do lote.", 1, 0 )
							EndIf
							oModelNNT:SetValue( "NNT_DTVALD", SB8->B8_DTVALID )
						EndIf
					EndIf
				ElseIf lRastroS
					If !Empty( cLoteCtl ) .And. !Empty( cLote )
						SB8->( DbSetOrder(2) )
						If SB8->( DbSeek( xFilial("SB8") + If( lRastroS, cLote, Space(6) ) + cLoteCtl + cProduto + cArmazem ) )
							nQtdEst := SB8Saldo( IIf( INCLUI, .F., .T. ), .T., Nil, Nil, Nil, lEmpPrev, Nil, dDataBase )
						EndIf

						If oModel:GetOperation() == MODEL_OPERATION_INSERT .OR. oModel:GetOperation() == MODEL_OPERATION_UPDATE
							If (nQtdEst <= 0) .OR. QtdComp( nQtdEst ) < QtdComp( nQtdTotal )
								Help( Nil, Nil, "TRFNEGAT", Nil, "Não existe quantidade suficiente em estoque para atender esta requisição.", 1, 0 )
								lRet := .F.
							EndIf
						EndIf
					Else
						Help( Nil, Nil, "TRFNUMLOTOBR", Nil, "Quando o produto utiliza controle de Rastro por SubLote, deve ter preenchido no movimento o campo Lote e Sub Lote.", 1, 0 )
						lRet:= .F.
					EndIf
				EndIf
			EndIf
		EndIf

		//-- Verificacao de capacidade do endereco
		If lRet .And. lLocalizD
			A311TrcFil( cFilDest )
			If SBE->( DbSeek( xFilial("SBE") + cArmDest + cLocalDes ) )
				If SBE->( !Eof() ) .And. QtdComp( SBE->BE_CAPACID ) > QtdComp(0) .And. ( QtdComp( SBE->BE_CAPACID ) < QtdComp( nQuant + QuantSBF( cArmDest, cLocalDes ) ) )
					Help( Nil, Nil, "TRFCAPAC", Nil, "A capacidade do endereço no destino não comporta a ser quantidade endereçada.", 1, 0 )
					lRet := .F.
				EndIf
			EndIf
			A311TrcFil( cFilBkp )
		Endif
	EndIf

	RestArea( aAreaSB1 )
	RestArea( aAreaSB2 )
	RestArea( aAreaSA1 )
	RestArea( aAreaNNT )
	FWRestRows( aSaveLines )

Return lRet


/*/{Protheus.doc} PosValid
Rotina de pos validacao do modelo, tem a funcao do Tudo Ok
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 07/06/2022
@param oModel, object, Objeto principal do modelo
@return logical, Retorno logico
/*/
Static Function PosValid(oModel) //-- MAT311PVld
	Local oModelNNT := oModel:GetModel( "NNTDETAIL" )
	Local lRet		:= .T.
	Local nX		:= 0
	Local aFilDes	:= {}

	For nX := 1 To oModelNNT:Length()
		oModelNNT:GoLine( nX )
		If !oModelNNT:IsDeleted()
			If FWCodFil() # oModelNNT:GetValue( "NNT_FILDES" )
				aAdd( aFilDes, oModelNNT:GetValue( "NNT_FILDES" ) )

				//-- Verifica se os campos NNT_TS e NNT_TE foram preenchidos
				If Empty( oModelNNT:GetValue( "NNT_TS" ) )
					Help( Nil, Nil, "TRFFILIALOTES", Nil, "O campo NNT_TS não foi preenchido.", 1, 0, Nil, Nil, Nil, Nil, Nil, { "Preencha o campo com o código da TES de saida." } )
					lRet := .F.
				Endif

				If lRet
					If Empty( oModelNNT:GetValue( "NNT_TE" ) )
						Help( Nil, Nil, "TRFFILIALDTES", Nil, "O campo NNT_TE não foi preenchido.", 1, 0, Nil, Nil, Nil, Nil, Nil, { "Preencha o campo com o código da TES de entrada." } )
						lRet := .F.
					Endif
				Endif
			EndIf

			//-- Chamada do "LinhaOk" do model NNT para garantir saldos
			If lRet
				lRet := LinhaOk( oModelNNT )
			Else
				Exit
			Endif
		Endif
	Next nX

	//-- Verifica se existe bloqueio pelo calendario contabil ou pelo parametro MV_ATFBLQM
	If lRet .And. !Empty( aFilDes )
		lRet := Mat311BlqM( aFilDes )
	EndIf

Return lRet


/*/{Protheus.doc} Grava
Rotina que realiza a gravacao dos dados
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 07/06/2022
@param oModel, object, Objeto do modelo
@return logical, Retonro logico
/*/
Static Function Grava(oModel) //-- MAT311Grv
	Local oModelNNS	:= oModel:GetModel( "NNSMASTER" )
	Local oModelNNT	:= oModel:GetModel( "NNTDETAIL" )
	Local lOk		:= .F.
	Local lAuto311	:= Type( "cOpId311" ) == "C" .And. !Empty( oModelNNT:GetValue( "NNT_SERIE" ) )

	Private l311GerPed := .F.
	Private a311Bloq   := {}

	Do Case
		Case oModel:GetOperation() == MODEL_OPERATION_INSERT
			//-- Gera empenho para os produtos
			//MsgRun( "Aguarde, processando empenhos...", "Empenhos de Produtos", {||lOk := GravaEmp( oModel ) } )
			//MsAguarde( {|| lOk := GravaEmp( oModel ) }, "Aguarde...", "Processando empenhos..." )
			lOk := GravaEmp( oModel )
		Case oModel:GetOperation() == MODEL_OPERATION_UPDATE
			 //-- Efetivacao da transferencia
			If IsInCallStack( "U_REESTA1C" ) .Or. (Type( "cOpId311" ) == "C" .and. cOpId311 == OP_EFE)
				//-- Libera modelo para alteracao
				oModelNNT:SetNoUpdateLine(.F.)
				If lAuto311
					lOk := ExecTransf( oModel )
				Else
					//MsgRun( "Aguarde, processando transferência...", "Transferência", {|| lOk := ExecTransf( oModel ) } )
					MsAguarde( {|| lOk := ExecTransf( oModel ) }, "Aguarde...", "Processando transferência..." )
				EndIf

				If lOk .And. !l311GerPed
					oModelNNS:LoadValue( "NNS_STATUS", "2" ) //-- Transferido
				Elseif l311GerPed
					oModelNNS:LoadValue( "NNS_STATUS", "3" ) //-- Efetivado com PV Bloqueado
				Endif

				//-- Bloqueia novamente o modelo
				oModelNNT:SetNoUpdateLine(.T.)
			ElseIf IsInCallStack( "U_REESTA1A" ) .Or. (Type( "cOpId311" ) == "C" .and. cOpId311 == OP_ALT)
				lOk := GravaAlt( oModel )
			Endif
		Case oModel:GetOperation() == MODEL_OPERATION_DELETE
			lOk := EstornaEmp( oModelNNT:GetValue( "NNT_COD" ) )
	EndCase

	If lOk
		FWFormCommit( oModel )
	Else
		If IsInCallStack( "U_REESTA1C" )
			oModel:SetErrorMessage( "REESTA01", "NNTDETAIL", "REESTA01", "NNTDETAIL", , "TRFERROR" )
		EndIf
	EndIf

	FreeUsedCode(.T.)

Return lOk


/*/{Protheus.doc} GravaEmp
Atualiza empenhos e previsoes de entrada para os produtos
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 07/06/2022
@param oModel, object, Objeto do modelo
@return logical, Retorno logico
/*/
Static Function GravaEmp(oModel) //-- A311Emp
	Local aAreaSB1	:= SB1->( GetArea() )
	Local aAreaSB2	:= SB2->( GetArea() )
	Local aAreaSB8	:= SB8->( GetArea() )
	Local aAreaSBF	:= SBF->( GetArea() )
	Local oModelNNT	:= oModel:GetModel( "NNTDETAIL" )
	Local cProd		:= ""
	Local cFilDest	:= ""
	Local cAmzOri	:= ""
	Local cAmzDest	:= ""
	Local cLote		:= ""
	Local cSubLote	:= ""
	Local cNumSerie	:= ""
	Local cEndereco	:= ""
	Local nQuant	:= 0
	Local nQuant2	:= 0
	Local nX		:= 0
	Local lRet		:= .T.

	For nX := 1 To oModelNNT:Length()
		oModelNNT:GoLine( nX )
		If !oModelNNT:IsDeleted()
			cProd     := oModelNNT:GetValue( "NNT_PROD" )
			cAmzOri   := oModelNNT:GetValue( "NNT_LOCAL" )
			cAmzDest  := oModelNNT:GetValue( "NNT_LOCLD" )
			cEndereco := oModelNNT:GetValue( "NNT_LOCALI" )
			cLote     := oModelNNT:GetValue( "NNT_LOTECT" )
			cSubLote  := oModelNNT:GetValue( "NNT_NUMLOT" )
			cNumSerie := oModelNNT:GetValue( "NNT_NSERIE" )
			nQuant    := oModelNNT:GetValue( "NNT_QUANT" )
			nQuant2   := oModelNNT:GetValue( "NNT_QTSEG" )
			cFilDest  := oModelNNT:GetValue( "NNT_FILDES" )

			SB1->( DbSetorder(1) )
			If SB1->( DbSeek( xFilial("SB1") + cProd ) )
				If Localiza( cProd )
					//-- Gera empenho do produto por endereco
					SBF->( DbSetOrder(1) ) //-- BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
					If SBF->( DbSeek( xFilial("SBF") + cAmzOri + cEndereco + cProd + cNumSerie + cLote + cSubLote ) )
						GravaBFEmp( "+", nQuant, "F", , nQuant2 )
					Endif
				EndIf

				If Rastro( cProd )
					//-- Gera empenho do produto por lote ou sub-lote
					SB8->( DbSetOrder(3) )
					If SB8->( DbSeek( xFilial("SB8") + cProd + cAmzOri + cLote + cSubLote ) )
						GravaB8Emp( "+", nQuant, "F" , Nil, nQuant2 )
					Endif
				EndIf

				//-- Gera empenho do produto por armazem
				SB2->( DbSetOrder(1) )
				If SB2->( DbSeek( xFilial("SB2") + cProd + cAmzOri ) )
					GravaB2Emp( "+", nQuant, "F", Nil, nQuant2 )
				Endif

				//-- Gera previsao de Entrada na Filial de Destino
				SB2->( DbSetOrder(1) )
				If SB2->( DbSeek( xFilial("SB2", cFilDest) + cProd + cAmzDest ) )
					GravaB2Pre( "+", nQuant, "F", nQuant2 )
				Endif
			Endif
		EndIf
	Next nX

	RestArea( aAreaSBF )
	RestArea( aAreaSB8 )
	RestArea( aAreaSB2 )
	RestArea( aAreaSB1 )

Return lRet


/*/{Protheus.doc} GravaAlt
Rotina que grava alteracao de empenhos e previsoes
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 07/06/2022
@param oModel, object, Objeto do modelo
@return logical, Retorno logico
/*/
Static Function GravaAlt(oModel) //-- A311GrAlt
	Local oModelNNS	:= oModel:GetModel( "NNSMASTER" )
	Local oModelNNT	:= oModel:GetModel( "NNTDETAIL" )
	Local nX        := 0

	For nX := 1 To oModelNNT:Length()
		oModelNNT:GoLine(nX)
		If oModelNNT:IsUpdated() .Or. oModelNNT:IsDeleted() .Or. oModelNNT:IsInserted()
			EstornaEmp( oModelNNS:GetValue( "NNS_COD" ) )
			GravaEmp( oModel )
			Exit
		EndIf
	Next nX

Return .T.


/*/{Protheus.doc} EstornaEmp
Rotina que atualza os empenhos ou previsoes de entrada
dos produtos a serem tranferidos entre empresas/filiais
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 07/06/2022
@param cCod, character, Codigo produto
@return logical, Retorno logico
/*/
Static Function EstornaEmp(cCod) //-- A311Estor
	Local aAreaSB1	:= SB1->( GetArea() ) 
	Local aAreaSB2	:= SB2->( GetArea() )
	Local aAreaSB8	:= SB8->( GetArea() )
	Local aAreaSBF	:= SBF->( GetArea() )
	Local aAreaNNT	:= NNT->( GetArea() )
	Local cProd		:= ""
	Local cFilDest	:= ""
	Local cAmzOri	:= ""
	Local cAmzDest	:= ""
	Local cLote		:= ""
	Local cSubLote	:= ""
	Local cNumSerie	:= ""
	Local cEndereco	:= ""
	Local nQuant	:= 0
	Local nQuant2	:= 0
	Local lRet		:= .T.

	NNT->( DbSetOrder(1) )
	NNT->( DBSeek( xFilial("NNT") + cCod ) )

	While ( NNT->( !Eof() ) ) .And. NNT->NNT_COD == cCod
		cProd     := NNT->NNT_PROD
		cAmzOri   := NNT->NNT_LOCAL
		cAmzDest  := NNT->NNT_LOCLD
		cEndereco := NNT->NNT_LOCALI
		cLote     := NNT->NNT_LOTECT
		cSubLote  := NNT->NNT_NUMLOT
		cNumSerie := NNT->NNT_NSERIE
		nQuant    := NNT->NNT_QUANT
		nQuant2   := NNT->NNT_QTSEG
		cFilDest  := NNT->NNT_FILDES

		SB1->( DbSetorder(1) )
		If SB1->( DbSeek( xFilial("SB1") + cProd ) )
			If Localiza( cProd )
				//-- Estorna empenho do produto por endereco
				SBF->( DbSetOrder(1) )
				If SBF->( DbSeek( xFilial("SBF") + cAmzOri + cEndereco + cProd + cNumSerie + cLote + cSubLote ) )
					GravaBFEmp( "-", nQuant, "F", , nQuant2 )
				Endif
			EndIf

			If Rastro( cProd )
				//-- Estorna empenho do produto por lote ou sub-lote
				SB8->( DbSetOrder(3) )
				If SB8->( DbSeek( xFilial("SB8") + cProd + cAmzOri + cLote + cSubLote ) )
					GravaB8Emp( "-", nQuant, "F", Nil, nQuant2 )
				Endif
			EndIf

			//-- Estorna do produto por armazem
			SB2->( DbSetOrder(1) )
			If SB2->( DbSeek( xFilial("SB2") + cProd + cAmzOri ) )
				GravaB2Emp( "-", nQuant, "F", Nil, nQuant2)
			Endif

			//-- Estorna previsao de Entrada na Filial de Destino
			SB2->( DbSetOrder(1) )
			If SB2->( DbSeek( xFilial("SB2", cFilDest) + cProd + cAmzDest ) )
				GravaB2Pre( "-", nQuant, "F", nQuant2 )
			Endif
		Endif

		NNT->( DbSkip() )
	EndDo

	RestArea( aAreaNNT )
	RestArea( aAreaSBF )
	RestArea( aAreaSB8 )
	RestArea( aAreaSB2 )
	RestArea( aAreaSB1 )

Return lRet


/*/{Protheus.doc} ExecTransf
Rotina que inicia a execucao da tranferencia dos materias
entre as filiaias da Replas
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 07/06/2022
@param oModel, object, Objeto do modelo
@return logical, Retorno logico
/*/
Static Function ExecTransf(oModel) //-- A311Transf
	Local oModelNNS	:= oModel:GetModel( "NNSMASTER" )
	Local oModelNNT	:= oModel:GetModel( "NNTDETAIL" )
	Local aDadosF	:= {}
	Local aSeries	:= {}
	Local aNotas	:= {}
	Local aParam310	:= Array(30)
	Local lRet		:= .T.
	Local lTrFil	:= .F.
	Local lAuto311	:= Type( "cOpId311" ) == "C" .And. cOpId311 == OP_EFE .And. !Empty( oModelNNT:GetValue( "NNT_SERIE" ) )
	Local nX		:= 0
	Local nTpCusto	:= GetMv( "RE_TPCUSST", .F., 4 ) //-- MV_TPCUSST
	Local cSerie 	:= ""
	Local cEspecie	:= Nil
	Local cTpNrFfs	:= GetMv( "MV_TPNRNFS" )
	Local cCodFil		:= FWCodFil()

	Private cNumero	:= ""

	//-- Verifica se existem materiais a serem transferidos
	If A311QtdTrs( oModelNNT, 2 ) > 0
		lTrFil := .T.

		//-- Obtem array para chamada da rotina automatica de tranferencia
		aDadosF := ArrayFil( oModel )

		//-- Gera series para as notas
		For nX := 1 to Len( aDadosF )
			If nX == 1 .Or. ( aDadosF[nX, 01] # aDadosF[nX-1, 01] )
				//-- Obtem serie para as notas desta filial
				cSerie  := ""
				cNumero := ""

				If lAuto311
					cSerie  := oModelNNT:GetValue( "NNT_SERIE" )
					cNumero := "000001"
					//cNumero := Ma461NumNf( Nil, cSerie, cNumero ) //-- lFirst, cSerie, cNumNFs, lECF, cSerieId
				Else
					SX5NumNota( @cSerie, cTpNrFfs, cCodFil ) //-- cSerNF,cTpNrNfs,cFilTela,cTab,cAliTp,cSerieId,dDEmissao
				EndIf

				//-- Caso tenha selecionado numero
				If Empty(cNumero)
					//-- A filial XX nao teve uma serie de nota fiscal de saida selecionada para geracao
					Help( " ", 1, "A310SERERR", , cCodFil, 1, 10 )
					lRet :=.F.
					Exit
				Else
					aAdd( aSeries, { cCodFil, cSerie, cNumero } )
				EndIf
			EndIf
		Next nX
	Endif

	If lRet
		Begin Transaction
			//-- Estorna os Empenhos antes de realizar a transferência
			EstornaEmp( oModelNNS:GetValue( "NNS_COD" ) )

			If lRet
				If lTrFil
					//-- Preenche parametros necessarios
					aParam310[14] := Val( oModelNNS:Getvalue( "NNS_CLASS" ) )
					aParam310[17] := nTpCusto
					aParam310[19] := 2 //-- Poder de Terceiro
					aParam310[20] := "NFE"
					
					If lAuto311
						aParam310[16] := SA1->A1_COND
					EndIf

					If NNS->( ColumnPos( "NNS_ESPECI" ) ) > 0
						cEspecie := oModelNNS:Getvalue( "NNS_ESPECI" )
						If !Empty( cEspecie ) .And. SX5->( DbSeek( xFilial("SX5") + "42" + cEspecie ) )
							aParam310[20] := cEspecie
						Endif
					Endif

					//-- Executa de transferencia automatica
					//lRet := A310Proc( aDadosF, aParam310, aSeries, @aNotas )
					lRet := U_REESTA02( aDadosF, aParam310, aSeries, @aNotas )

					If lRet
						If !l311GerPed
							lRet := GrvDoc( oModel, aNotas )
						Elseif l311GerPed
							lRet := GrvPed( oModel, a311Bloq )
						EndIf

						If !lRet
							DisarmTransaction()
							lRet := .F.
						Endif
					Else
						DisarmTransaction()
						lRet := .F.
					Endif
					
					oModel:Activate()
				Endif
			Endif
		End Transaction
	Endif

Return lRet


/*/{Protheus.doc} ArrayFil
Rotina que monta o array com os produtos para tranferencia
entre as empresas/filiais da Replas
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 07/06/2022
@param oModel, object, Objeto do modelo
@return array, Dados para transferencia
/*/
Static Function ArrayFil(oModel) //-- A311ArrFil
	Local oModelNNS	:= oModel:GetModel( "NNSMASTER" )
	Local oModelNNT	:= oModel:GetModel( "NNTDETAIL" )
	Local aDadosRet	:= {}
	Local aDadosF	:= {}
	Local aDados	:= {}
	Local aUso		:= {}
	Local cCgc		:= ""
	Local cFilAtu	:= ""
	Local nX		:= 0
	Local nY        := 0

	For nX := 1 To oModelNNT:Length()
		oModelNNT:GoLine(nX)
		If oModelNNT:GetValue( "NNT_FILORI" ) # oModelNNT:GetValue( "NNT_FILDES" )
			aDados := {}
			
			//-- Array com dados para transferencia
			aAdd( aDados, oModelNNT:GetValue( "NNT_FILORI" ) )	//-- [01] Filial  origem
			aAdd( aDados, oModelNNT:GetValue( "NNT_PROD" ) )	//-- [02] Produto origem
			aAdd( aDados, oModelNNT:GetValue( "NNT_LOCAL" ) )	//-- [03] Armazem origem
			aAdd( aDados, oModelNNT:GetValue( "NNT_QUANT" ) )	//-- [04] Quantidade origem
			aAdd( aDados, oModelNNT:GetValue( "NNT_QTSEG" ) )	//-- [05] Quantidade origem 2a UM
			aAdd( aDados, oModelNNT:GetValue( "NNT_FILDES" ) )	//-- [06] Filial  destino
			aAdd( aDados, oModelNNT:GetValue( "NNT_LOCLD" ) )	//-- [07] Armazem destino

			//-- Localiza Cliente na origem atraves do CNPJ
			cCgc := A311FilCGC( oModelNNT:GetValue( "NNT_FILDES" ) )
			SA1->( DbSetOrder(3) )
			SA1->( DbSeek( xFilial("SA1") + cCgc ) )
			
			aAdd( aDados, SA1->A1_COD ) 						//-- [08] Cliente na Origem
			aAdd( aDados, SA1->A1_LOJA )						//-- [09] Loja na Origem

			//-- Localiza Fornecedor no destino atraves do CNPJ
			cCgc := A311FilCGC( oModelNNT:GetValue( "NNT_FILORI" ) )
			SA2->( DbSetOrder(3) )
			SA2->( DbSeek( xFilial("SA2", oModelNNT:GetValue( "NNT_FILDES" ) ) + cCgc ) )

			aAdd( aDados, SA2->A2_COD ) 	  					//-- [10] Fornecedor no destino
			aAdd( aDados, SA2->A2_LOJA ) 					    //-- [11] Loja no destino
			aAdd( aDados, "" ) 									//-- [12] Documento na origem
			aAdd( aDados, "" ) 									//-- [13] Serie do documento na origem
			aAdd( aDados, "" ) 									//-- [14] Identificados Poder 3
			aAdd( aDados, "" ) 									//-- [15] Cliente/Fornecedor Poder 3
			aAdd( aDados, "" ) 									//-- [16] Loja Poder 3
			aAdd( aDados, oModelNNT:GetValue( "NNT_LOTECT" ) )	//-- [17] Lote Origem
			aAdd( aDados, oModelNNT:GetValue( "NNT_NUMLOT" ) )	//-- [18] Sub-Lote Origem
			aAdd( aDados, oModelNNT:GetValue( "NNT_DTVALI" ) )	//-- [19] Data de Validade
			aAdd( aDados, oModelNNT:GetValue( "NNT_LOCALI" ) )	//-- [20] Endereço
			aAdd( aDados, oModelNNT:GetValue( "NNT_NSERIE" ) )	//-- [21] Numero de Serie
			aAdd( aDados, "" )								    //-- [22] NUMSEQ do CQ
			aAdd( aDados, oModelNNT:GetValue( "NNT_TS" ) )		//-- [23] TES de Saída
			aAdd( aDados, oModelNNT:GetValue( "NNT_TE" ) )		//-- [24] TES de entrada
			aAdd( aDados, oModelNNT:GetValue( "NNT_PRODD" ) )	//-- [25] Produto destino
			aAdd( aDados, oModelNNT:GetValue( "NNT_LOTED" ) )	//-- [26] Lote Destino
			aAdd( aDados, oModelNNS:GetValue( "NNS_XCNDPG" ) )	//-- [27] Condicao de pagamento
			aAdd( aDados, oModelNNS:GetValue( "NNS_XTRNS" ) )	//-- [28] Transportadora
			aAdd( aDados, oModelNNS:GetValue( "NNS_XTPFRE" ) )	//-- [29] Tipo Frete
			aAdd( aDados, oModelNNT:GetValue( "NNT_XPRCVE" ) )	//-- [30] Preco Unitario Liquido

			aAdd(aDadosF, aDados)
		Endif
	Next nX

	//-- Aglutina dados por filial destino
	For nX := 1 To Len( aDadosF )
		cFilAtu := aDadosF[nX, 06]
		If !( aScan( aUso, {|x| x == cFilAtu} ) > 0 )
			For nY := 1 To Len( aDadosF )
				If aDadosF[nY, 06] == cFilAtu
					aAdd( aDadosRet, aDadosF[nY] )
				Endif
			Next nY
			aAdd( aUso, cFilAtu )
		Endif
	Next nX

Return aDadosRet


/*/{Protheus.doc} ShowF4
Rotina que mostrar as consulta F4 na tela
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 07/06/2022
/*/
Static Function ShowF4() //-- A311SetKey
	Local cCampo 	:= AllTrim( Upper( ReadVar() ) )
	Local oModel	:= Nil
	Local oModelNNT	:= Nil
	Local cProduto	:= Nil
	Local cArmOri	:= Nil
	Local cLocali	:= Nil
	Local oView		:= FwViewActive()
	Local nHdl		:= 0

	oModel := FWModelActive()
	If oModel <> Nil
		oModelNNT := oModel:GetModel( "NNTDETAIL" )
		cProduto  := oModelNNT:GetValue( "NNT_PROD" )
		cArmOri   := oModelNNT:GetValue( "NNT_LOCAL" )
		cLocali   := oModelNNT:GetValue( "NNT_LOCALI" )

		Do Case
			Case cCampo == "M->NNT_LOCALI" .Or. cCampo == "M->NNT_NSERIE"
				nHdl := GetFocus()
				oView := FwViewActive()
				F4Localiz( , , , "A311", cProduto, cArmOri, , ReadVar(), .F., , (AllTrim( Upper( ReadVar() ) ) == "M->NNT_NSERIE") )
				SetFocus( nHdl )
			Case cCampo == "M->NNT_LOTECT" .Or. cCampo == "M->NNT_NUMLOT"
				F4Lote( , , , "A311", cProduto, cArmOri, Nil , cLocali, 2, , , .F. )
			Case cCampo == "M->NNT_QUANT"
				If !Empty( cProduto )
					MaViewSB2( cProduto, , )
				Else
					Help( Nil, Nil, "TRFPRODVAZIO", Nil, "Preencha o código do produto.", 1, 0 )
				EndIf
		EndCase
	EndIf

Return


/*/{Protheus.doc} GrvDoc
Rotina que grava os codigos de documentos gerados nos itens de transferencia
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 07/06/2022
@param oModel, object, Objeto do modelo
@param aDocs, array, Numero do documento
@return logical, Retorno logico
/*/
Static Function GrvDoc(oModel, aDocs) //-- A311GrvDoc
	Local oModelNNT	:= oModel:GetModel( "NNTDETAIL" )
	Local nX		:= 0
	Local nPos		:= 0
	Local lRet		:= .T.

	If Empty( aDocs )
		lRet := .F.
	Endif

	If lRet
		For nX := 1 To oModelNNT:Length()
			oModelNNT:GoLine(nX)
			If oModelNNT:GetValue( "NNT_FILORI" ) # oModelNNT:GetValue( "NNT_FILDES" )
				//-- Busca posicao do array de documentos que contem a filial destino
				nPos := aScan( aDocs, {|x| x[1] == oModelNNT:GetValue( "NNT_FILDES" ) } )

				If nPos > 0
					If !Empty( aDocs[nPos, 02] )
						oModelNNT:LoadValue( "NNT_DOC", aDocs[nPos, 02] )
						oModelNNT:LoadValue( "NNT_SERIE", aDocs[nPos, 03] )
						oModelNNT:LoadValue( "NNT_NUMPED", aDocs[nPos, 04] )
					Else
						lRet := .F.
						Exit
					Endif
				Endif
			Endif
		Next nX
	Endif

Return lRet


/*/{Protheus.doc} ContIgual
Rotina que verifica se os campos Filial Origem, 
Produto e Armazens sao iguais ao Filial Destino, 
Produto Destino e Armazem Destino
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 07/06/2022
@return logical, Retorno logico
/*/
Static Function ContIgual() //-- A311Igual
	Local oModel	:= FWModelActive()
	Local oModelNNT	:= oModel:GetModel( "NNTDETAIL" )
	Local cFilOri	:= oModelNNT:GetValue( "NNT_FILORI" )
	Local cProdOri	:= oModelNNT:GetValue( "NNT_PROD" )
	Local cLocalOri	:= oModelNNT:GetValue( "NNT_LOCAL" )
	Local cLocaliO	:= oModelNNT:GetValue( "NNT_LOCALI" )
	Local cLoteOri	:= oModelNNT:GetValue( "NNT_LOTECT" )
	Local cFilDes	:= oModelNNT:GetValue( "NNT_FILDES" )
	Local cProdDes	:= oModelNNT:GetValue( "NNT_PRODD" )
	Local cLocalD	:= oModelNNT:GetValue( "NNT_LOCLD" )
	Local cLocaliD	:= oModelNNT:GetValue( "NNT_LOCDES" )
	Local cLoteDes	:= oModelNNT:GetValue( "NNT_LOTED" )
	Local lRet      := .T.

	If !Empty( cFilOri ) .And. !Empty( cProdOri ) .And. !Empty( cLocalOri ) .And.;
	   !Empty( cFilDes ) .And. !Empty( cProdDes ) .And. !Empty( cLocalD ) .And.;
	   cFilOri + cProdOri + cLocalOri + cLocaliO + cLoteOri == cFilDes + cProdDes + cLocalD + cLocaliD + cLoteDes

		Help( " ", 1, "MA260IGUAL" ) //-- A origem da transferência nao pode ser igual ao destino.
		lRet:= .F.
	EndIf

Return lRet


/*/{Protheus.doc} RepTES
Rotina que replica a TES de saida e entrada
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 07/06/2022
/*/
Static Function RepTES() //-- A311RepTES
	Local oModel	 := FWModelActive()
	Local oModelNNT	 := oModel:GetModel( "NNTDETAIL" )
	Local aSaveLines := FWSaveRows()
	Local nX

	If Pergunte( "A311TES", .T. )
		For nX := 1 To oModelNNT:Length()
			oModelNNT:GoLine( nX )
			If !oModelNNT:IsDeleted()
				If FWCodFil() # oModelNNT:GetValue( "NNT_FILDES" )
					If !Empty( "MV_PAR02" )
						If Empty( MV_PAR01 )
							oModelNNT:SetValue( "NNT_TS", MV_PAR02 )
						ElseIf !Empty( MV_PAR01 ) .And. oModelNNT:GetValue( "NNT_FILDES" ) == MV_PAR01
							oModelNNT:SetValue( "NNT_TS", MV_PAR02 )
						EndIf
					EndIf

					If !Empty( "MV_PAR03" )
						If Empty( MV_PAR01 )
							oModelNNT:SetValue( "NNT_TE", MV_PAR03 )
						ElseIf !Empty( MV_PAR01 ) .And. oModelNNT:GetValue( "NNT_FILDES" ) == MV_PAR01
							oModelNNT:SetValue( "NNT_TE", MV_PAR03 )
						EndIf
					EndIf
				EndIf
			Endif
		Next nX

		Aviso( "Atencao", "Processo finalizado", {"OK"}, 1 )
	EndIf

	FWRestRows( aSaveLines )

Return


/*/{Protheus.doc} SomaGrid
Rotina que realiza soma das linhas da Grid
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 07/06/2022
@param oModelNNT, object, Objeto do modelo NNT
@return numeric, Soma da quantidade total do produto
/*/
Static Function SomaGrid(oModelNNT) //-- A311SomaDados
	Local cProduto	 := oModelNNT:GetValue( "NNT_PROD" )
	Local cArmazem	 := oModelNNT:GetValue( "NNT_LOCAL" )
	Local cLocaliza	 := oModelNNT:GetValue( "NNT_LOCALI" )
	Local cNumSerie	 := oModelNNT:GetValue( "NNT_NSERIE" )
	Local cLoteCtl	 := oModelNNT:GetValue( "NNT_LOTECT" )
	Local cLote		 := oModelNNT:GetValue( "NNT_NUMLOT" )
	Local aSaveLines := FWSaveRows()
	Local nQtdTotal	 := 0
	Local nX		 := 0

	//-- Calcula se foi informado o mesmo Produto, Armazem, Lote, SubLote, Endereco e Numero de Serie para o Produto
	For nX := 1 To oModelNNT:Length()
		oModelNNT:GoLine( nX )
		If !oModelNNT:IsDeleted()
			If oModelNNT:GetValue( "NNT_PROD" ) + oModelNNT:GetValue( "NNT_LOCAL" ) +;
			   oModelNNT:GetValue( "NNT_LOCALI" ) + oModelNNT:GetValue( "NNT_NSERIE" ) +;
			   oModelNNT:GetValue( "NNT_LOTECT" ) + oModelNNT:GetValue( "NNT_NUMLOT" ) ==;
			   cProduto + cArmazem + cLocaliza + cNumSerie + cLoteCtl + cLote

				nQtdTotal += oModelNNT:GetValue( "NNT_QUANT" )
			Endif
		Endif
	Next nX

	FWRestRows( aSaveLines )

Return nQtdTotal


/*/{Protheus.doc} ActiveMod
Rotina de ativacao do modelo de dados
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 07/06/2022
@param oModel, object, Objeto do modelo
@param nOpcx, numeric, Numedo da operacao
@return logical, Retorno logico
/*/
Static Function ActiveMod( oModel, nOpcx ) //-- A311ActMod
	Local oMaster	 := oModel:GetModel()
	Local oModelNNS	 := oMaster:GetModel( "NNSMASTER" )
	Local oModelNNT	 := oMaster:GetModel( "NNTDETAIL" )
	Local dDtEmiss	 := oModelNNS:GetValue( "NNS_DATA" )
	Local nOperation := oModel:GetOperation()
	Local lAuto311	 := Type( "cOpId311" ) == "C" .And. cOpId311 == OP_EFE .And. !Empty( oModelNNT:GetValue( "NNT_SERIE" ) )

	Default nOpcx := 1

	If nOperation # 1 .And. nOperation # 5
		If nOpcx == 2
			oModelNNS:setValue("NNS_DATA", dDataBase)
			oModelNNS:loadValue("NNS_DATA", dDtEmiss)

			//-- Opcao de Copia de Tranferencia
			If IsInCallStack("U_REESTA1D")
				//-- Limpa conteudo do parametro de armazem destino
				SetMVValue("A311TES", "MV_PAR04", Space(Len(NNT->NNT_LOCLD))) 

				If Pergunte("A311TES", .T.)
					//-- Carrega copia
					MsgRun("Carregando copia...", "", {|| LoadCopia(@oModel, @oModelNNS, @oModelNNT)})
				EndIf
			EndIf
		EndIf

		//-- Se a efetivacao esta na chamada nao permite excluir, alterar ou adicionar linha
		If IsInCallStack( "U_REESTA1C" ) .Or. lAuto311
			oModelNNT:SetNoInsertLine(.T.)
			oModelNNT:SetNoDeleteLine(.T.)
			oModelNNT:SetNoUpdateLine(.T.)
		EndIf

	EndIf

Return .T.


/*/{Protheus.doc} GrvPed
Rotina responsavel por gravar o numero do PV
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 07/06/2022
@param oModel, object, Objeto do modelo
@param aBloqueio, array, Pedio com bloqueio
@return logical, Retorno logico
/*/
Static Function GrvPed(oModel, aBloqueio) //-- A311GrvPed
	Local oModelNNT	:= oModel:GetModel( "NNTDETAIL" )
	Local nX		:= 0
	Local nPos		:= 0
	Local lRet		:= .T.

	For nX := 1 To oModelNNT:Length()
		oModelNNT:GoLine(nX)
		If oModelNNT:GetValue( "NNT_FILORI" ) # oModelNNT:GetValue( "NNT_FILDES" )
			//-- Busca posicao do array de documentos que contem a filial destino
			nPos := aScan( aBloqueio, {|x| x[9] == oModelNNT:GetValue( "NNT_FILDES")} )
			
			If nPos > 0
				If !Empty( aBloqueio[nPos, 01] )
					oModelNNT:LoadValue( "NNT_NUMPED", aBloqueio[nPos, 01] )
				Else
					lRet := .F.
					Exit
				Endif
			Endif
		Endif
	Next nX

Return lRet

/*/{Protheus.doc} TrigQuant
Atualiza Quantidade com o Saldo do Lote/Sub-Lote
@type function
@version 1.0
@author Marcos P.Aversa
@since 01/02/2023
@param oModel, object, Objeto do modelo
@return numeric, Saldo do Lote/Sub-Lote
/*/
Static Function TrigQuant(oModel)
    local cFilOri   := xFilial("NNT")
	local cProduto  := oModel:GetValue("NNT_PROD")
	local cLocal    := oModel:GetValue("NNT_LOCAL")
	local cLoteCtl  := oModel:GetValue("NNT_LOTECT")
	local cNumLote  := oModel:GetValue("NNT_NUMLOT")
	local nQtd      := 0

    nQtd  := GetAdvFVal( "SB8", "B8_SALDO", cFilOri + cProduto + cLocal + cLoteCtl + cNumLote , 3, 0 )

Return nQtd


/*/{Protheus.doc} REESTA1E
Selecão das Bobinas a Serem Transferidas
@type function
@version  1.0
@author Marcos Aversa - Dothink
@since 07/12/2023
@return variant, NIL
/*/
User Function REESTA1E()
	local aArea     := GetArea()
	local oDlg      := NIL

	local aColsMark := {}
	local aFldConj  := {}
    local cAlias    := GetNextAlias()
	local _cPerg    := "REESTA1E  "	
	local cQuery    := ""

	cTipProd 	 := GetSX3Cache("B8_PRODUTO"  , "X3_TIPO")
	cPicProd     := GetSX3Cache("B8_PRODUTO"  , "X3_PICTURE")
	nTamProd     := GetSX3Cache("B8_PRODUTO"  , "X3_TAMANHO")
	nDecProd     := GetSX3Cache("B8_PRODUTO"  , "X3_DECIMAL")

	cTipLoc 	 := GetSX3Cache("B8_LOCAL"  , "X3_TIPO")
	cPicLoc      := GetSX3Cache("B8_LOCAL"  , "X3_PICTURE")
	nTamLoc      := GetSX3Cache("B8_LOCAL"  , "X3_TAMANHO")
	nDecLoc      := GetSX3Cache("B8_LOCAL"  , "X3_DECIMAL")	

	cTipSal 	 := GetSX3Cache("B8_SALDO"  , "X3_TIPO")
	cPicSal      := GetSX3Cache("B8_SALDO"  , "X3_PICTURE")
	nTamSal      := GetSX3Cache("B8_SALDO"  , "X3_TAMANHO")
	nDecSal      := GetSX3Cache("B8_SALDO"  , "X3_DECIMAL")

	cTipLot 	 := GetSX3Cache("B8_LOTECTL"  , "X3_TIPO")
	cPicLot      := GetSX3Cache("B8_LOTECTL"  , "X3_PICTURE")
	nTamLot      := GetSX3Cache("B8_LOTECTL"  , "X3_TAMANHO")
	nDecLot      := GetSX3Cache("B8_LOTECTL"  , "X3_DECIMAL")

	cTipSub 	 := GetSX3Cache("B8_NUMLOTE"  , "X3_TIPO")
	cPicSub      := GetSX3Cache("B8_NUMLOTE"  , "X3_PICTURE")
	nTamSub      := GetSX3Cache("B8_NUMLOTE"  , "X3_TAMANHO")
	nDecSub      := GetSX3Cache("B8_NUMLOTE"  , "X3_DECIMAL")

	cTipDat		 := GetSX3Cache("B8_DTVALID"  , "X3_TIPO")
	cPicDat      := GetSX3Cache("B8_DTVALID"  , "X3_PICTURE")
	nTamDat      := GetSX3Cache("B8_DTVALID"  , "X3_TAMANHO")
	nDecDat      := GetSX3Cache("B8_DTVALID"  , "X3_DECIMAL")	

	If !Pergunte( _cPerg, .T. )
	   Return Nil
	Endif

  	//-- Tabela temporaria -- Campos da temporaria
    aAdd(aFldConj, {"OK"     , "C"       , 2         , 0         })
    aAdd(aFldConj, {"B8_PRODUTO", cTipProd  , nTamProd  , nDecProd  })
	aAdd(aFldConj, {"B8_LOCAL"  , cTipLoc   , nTamLoc  , nDecLoc })
    aAdd(aFldConj, {"B8_SALDO"  , cTipSal   , nTamSal  , nDecSal })
 	aAdd(aFldConj, {"B8_LOTECTL", cTipLot   , nTamLot  , nDecLot })
    aAdd(aFldConj, {"B8_NUMLOTE", cTipSub   , nTamSub  , nDecSub })
    aAdd(aFldConj, {"B8_DTVALID", cTipDat   , nTamDat  , nDecDat })

    oTmpTable := FWTemporaryTable():New(cAlias)
    oTmptable:setFields(aFldConj)
    oTmpTable:addIndex("01", {"B8_PRODUTO"})    
    oTmpTable:create()  

    //-- Tabela temporaria de conjugacao 
    dbSelectArea(cAlias)
    (cAlias)->(dbSetOrder(1))
    (cAlias)->(dbGoTop())	

	//-- Filtro para Seleção  
	cQuery := "SELECT B8_PRODUTO,B8_LOCAL,B8_SALDO,B8_EMPENHO,B8_LOTECTL,B8_NUMLOTE,B8_DTVALID "
	cQuery += "FROM " + RetSqlName("SB8") + " B8 "
	cQuery += "WHERE B8.D_E_L_E_T_ = ' ' "
	cQuery += "AND B8_FILIAL = '" + MV_PAR01 + "' "
	cQuery += "AND B8_SALDO <> 0 AND B8_EMPENHO = 0 "
	If !Empty( MV_PAR05 )	
		cQuery += "AND B8_PRODUTO LIKE '" + Alltrim( MV_PAR05 ) + "%' "
	Endif

	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPSB8", .F., .T. )
	TcSetField( "TMPSB8","B8_DTVALID","D")

	If TMPSB8->( !Eof() )
       While TMPSB8->( !Eof() )
            RecLock( cAlias,  .T.)
            (cAlias)->B8_PRODUTO := TMPSB8->B8_PRODUTO
            (cAlias)->B8_LOCAL   := TMPSB8->B8_LOCAL
            (cAlias)->B8_SALDO   := TMPSB8->B8_SALDO
            (cAlias)->B8_LOTECTL := TMPSB8->B8_LOTECTL
            (cAlias)->B8_NUMLOTE := TMPSB8->B8_NUMLOTE
	        (cAlias)->B8_DTVALID := TMPSB8->B8_DTVALID
			(cAlias)->(MsUnlock())	   
			TMPSB8->( dbSkip() )	      
	   Enddo 
	Endif 	
	TMPSB8->( dbCloseArea() )

    //-- Tabela temporaria construcao estrutura das colunas do FWMarkBrowse
    aColsMark    := BuildCols()

	oDlg := FWDialogModal():New()
	oDlg:setBackground(.T.)
	oDlg:setEscClose(.F.)
    oDlg:setSize(220, 520)
    oDlg:setTitle("Importação de Bobinas")
    oDlg:setSubTitle("Selecione as bobinas que deverão ser importadas")
	oDlg:enableFormBar(.T.)
	oDlg:createDialog()
	oDlg:addButton("Continuar", {|| lRet := fVldSB8( cAlias ) , Iif(lRet, oDlg:deactivate(), oDlg)}, "Continuar",,.T.,.F.,.T.)
	oDlg:setEscClose(.T.)
    oPnlGrid := oDlg:getPanelMain()

    //-- MarkBrowse
    oMark := FWMarkBrowse():New()
    oMark:setAlias(cAlias)
    oMark:setFieldMark("OK")
    oMark:setTemporary(.T.)
    oMark:setColumns(aColsMark)
    oMark:setOwner(oPnlGrid)
    oMark:disableFilter()
    oMark:disableConfig()
    oMark:disableReport()
    oMark:disableSeek()
    oMark:disableSaveConfig()
	oMark:SetMenuDef("")
    oMark:Activate()	
	oDlg:Activate()

	RestArea( aArea )
Return

Static Function fVldSB8( cAlias )
	local aArea   := GetArea()
	local nAtual  := 0
	local nTotSol := 0
	local aItens  := {}
	local axRet   := { .T., " "}
 
	local cTSaida := ""
	local cTEntra := ""
	Local cCodUsr := RetCodUsr()
	
	cTSaida  := MV_PAR03
	cTEntra  := MV_PAR04

    (cAlias)->(dbGoTop())
    While (cAlias)->(!Eof())
        If !Empty((cAlias)->OK)
        	nAtual++
			cDesc := GetAdvFVal("SB1", "B1_DESC", (cAlias)->B8_PRODUTO,1,"" )

			aAdd(aItens, { (cAlias)->B8_PRODUTO ,;  //-- 01 - Codigo do produto
						   cDesc                ,;  //-- 02 - Descricao do produto
						   (cAlias)->B8_LOCAL   ,;  //-- 03 - Armazem
						   (cAlias)->B8_LOTECTL ,;  //-- 04 - Lote
						   (cAlias)->B8_NUMLOTE ,;  //-- 05 - Sub-lote
						   (cAlias)->B8_DTVALID ,;  //-- 06 - Data de validade
						   (cAlias)->B8_SALDO   ,;  //-- 07 - Quantidade empenhada
						   (cAlias)->B8_SALDO   ,;  //-- 08 - Saldo 
						   MV_PAR01             ,;  //-- 09 - Filial de Origem 
						   MV_PAR02 }       )     //-- 10 - Filial de Destino --

			If Len(aItens) >= 99
				axRet := IncxTrasf(aItens, cCodUsr, cTSaida, cTEntra)
				aItens  := {}
				nTotSol++
			EndIf
		Endif
		(cAlias)->( dbSkip() )
    Enddo

   	If !Empty(aItens)
   	 	nTotSol++
       	axRet := IncxTrasf(aItens, cCodUsr, cTSaida, cTEntra)
   	EndIf

	cMsgFim := ""
	If nAtual <> 0
		cMsgFim := "TOTAL DE REGISTROS PROCESSADOS = " + cValToChar(nAtual)  + CRLF
		cMsgFim += "TOTAL DE SOLICITAÇÃO DE TRANSFERÊNCIAS = " + cValToChar(nTotSol)  + CRLF
		cMsgFim += "ULTIMA SOLICITAÇÃO DE TRANSFERÊNCIA INCLUIDA = "+ cValToChar( axRet[2] )  + CRLF 
        FWAlertInfo(cMsgFim, "Fim da Execução")	
	Else 
	    FWAlertInfo( "Nenhum Registro Selecionado", "Voltar")					
	Endif

RestArea( aArea )

Return .T. 

Static Function BuildCols()
    Local aConjCols := {}
    Local aStruct   := {}
    Local nX

    //-- Campos da temporaria de conjugacao do browse
    aAdd(aStruct, {"OK"     , ""             , "C"      , ""       , 2        , 0        })
    aAdd(aStruct, {"B8_PRODUTO", "Código"       , cTipProd , cPicProd , nTamProd , nDecProd })
    aAdd(aStruct, {"B8_LOCAL"  , "Armazem"      , cTipLoc  , cPicLoc  , nTamLoc  , nDecLoc })
    aAdd(aStruct, {"B8_SALDO"  , "Saldo Lote"   , cTipSal  , cPicSal  , nTamSal  , nDecSal })
    aAdd(aStruct, {"B8_LOTECTL", "Lote"         , cTipLot  , cPicLot  , nTamLot  , nDecLot })
    aAdd(aStruct, {"B8_NUMLOTE", "Sub-Lote"     , cTipSub  , cPicSub  , nTamSub  , nDecSub })
    aAdd(aStruct, {"B8_DTVALID", "Dt.Valid."    , cTipDat  , cPicDat  , nTamDat  , nDecDat })


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

Static Function IncxTrasf(aItens, cXUserID, cTSaida, cTEntra)
	Local aLog      := {}
	Local cLog      := ""
	Local nX        := 0
	Local oModel    := Nil
	Local cNumST    := "" 
	Local aRet      := { .T., " "}
    Private INCLUI  := .T.
    Private ALTERA  := .F.

    If Empty(cXUserID)
        cXUserID := "000000"
    EndIf

    oModel := FWLoadModel( "REESTA01" ) //-- Carrega o modelo
    oModel:SetOperation( MODEL_OPERATION_INSERT ) //-- Seta operacao de inclusao
    oModel:Activate() //-- Ativa o Modelo

    //-- Cabecalho da solicitacao
    oModel:SetValue( "NNSMASTER", "NNS_CLASS", "2" )
    oModel:SetValue( "NNSMASTER", "NNS_ESPECI", " " )
    oModel:SetValue( "NNSMASTER", "NNS_SOLICT", cXUserID )
    oModel:SetValue( "NNSMASTER", "NNS_XNOMST", UsrFullName( cXUserID ) )
    
    For nX := 1 To Len( aItens )
        //-- Verifica se no destino existe o armazém de destino, se não tiver cria
        If !SB2->(DbSeek( aItens[nX, 10] + aItens[nX, 01] + aItens[nX, 03]   ))
			CriaSB2( aItens[nX, 01], aItens[nX, 03] , aItens[nX, 10] )	
		EndIf

        If nX > 1
            oModel:GetModel( "NNTDETAIL" ):AddLine()
        EndIf

        //-- Itens da solicitacao, origem
        oModel:SetValue( "NNTDETAIL", "NNT_FILORI"  , FWCodFil() )
        oModel:SetValue( "NNTDETAIL", "NNT_PROD"    , aItens[nX, 01] )
        oModel:SetValue( "NNTDETAIL", "NNT_LOCAL"   , aItens[nX, 03] )
        oModel:SetValue( "NNTDETAIL", "NNT_QUANT"   , aItens[nX, 08] )

        //-- Checa se utiliza rastreabilidade por lote
        If Rastro( aItens[nX, 01], "L" )
            oModel:SetValue( "NNTDETAIL", "NNT_LOTECT", aItens[nX, 04] )
            oModel:SetValue( "NNTDETAIL", "NNT_DTVALI", aItens[nX, 06] )
        EndIf

        //-- Checa se utiliza rastreabilidade por sub-lote
        If Rastro( aItens[nX, 01], "S" )
            oModel:SetValue( "NNTDETAIL", "NNT_LOTECT", aItens[nX, 04] )
            oModel:SetValue( "NNTDETAIL", "NNT_NUMLOT", aItens[nX, 05] )
            oModel:SetValue( "NNTDETAIL", "NNT_DTVALI", aItens[nX, 06] )
        EndIf

        //-- Itens da solicitacao, destino
        oModel:SetValue( "NNTDETAIL", "NNT_FILDES"  , aItens[nX, 10] )
        oModel:SetValue( "NNTDETAIL", "NNT_PRODD"   , aItens[nX, 01] )
        oModel:SetValue( "NNTDETAIL", "NNT_LOCLD"   , aItens[nX, 03] )
        oModel:SetValue( "NNTDETAIL", "NNT_TS"      , AllTrim( cTSaida ) )
        oModel:SetValue( "NNTDETAIL", "NNT_TE"      , AllTrim( cTEntra ) )

    Next nX

    //-- Validacao do modelo
    If oModel:VldData()
        //-- Gravacao do Modelo
        oModel:CommitData()
		cNumST := oModel:aAllSubModels[01]:aDataModel[01][02][02]
		aRet :={ .T., cNumST }
    Else
        aLog     := oModel:GetErrorMessage() //-- Recupera o erro do model quando nao passou no VldData
        //-- Laco para gravar em string cLog conteudo do array aLog
        For nX := 1 To Len( aLog )
            If !Empty( aLog[nX] )
                cLog += Alltrim( aLog[nX] ) //+ Chr(13) + Chr(10)
            EndIf
        Next nX
		Help( ,,"REESTA1F",,cLog, 1, 0 )
		aRet :={ .F., cNumST }
    EndIf

    oModel:DeActivate() //-- Desativa modelo

Return aRet


//--
Static Function LoadCopia(oModel, oModelNNS, oModelNNT)
	Local aAreaAnt  := GetArea()
	Local aAreaSB8  := SB8->(GetArea())
	Local aAreaSB9  := SB9->(GetArea())
	Local aAreaNNS  := NNS->(GetArea())
	Local aAreaNNT  := NNT->(GetArea())
	Local cFilNNS   := NNS->NNS_FILIAL
	Local cCodNNS   := NNS->NNS_COD
	Local cArmDes   := ""
	Local nQtdLines := 0
	Local nAddLine  := 0
	Local lInicio   := .T.

    dbSelectArea("SB8")
    SB8->(dbSetOrder(2))

    dbSelectArea("SB9")
    SB9->(dbSetOrder(1))

	dbSelectArea("NNT")
	NNT->(dbSetOrder(1))
	NNT->(dbSeek(cFilNNS + cCodNNS))

	VarInfo("INICIO COPIA TRANSFERENCIA", cFilNNS + cCodNNS)

	While NNT->(!EoF()) .And. NNT->(NNT_FILIAL + NNT_COD) == cFilNNS + cCodNNS
		If Empty(MV_PAR04)
			cArmDes := NNT->NNT_LOCLD
		Else
			cArmDes := MV_PAR04
		EndIf

		VarInfo("ARMAZEM DESTINO", cArmDes)

		If !VldSldSB8(NNT->NNT_NUMLOT, NNT->NNT_LOTECT, NNT->NNT_PROD)
			NNT->(dbSkip())
			VarInfo("PULOU ITEM", NNT->NNT_NUMLOT+"-"+NNT->NNT_LOTECT+"-"+NNT->NNT_PROD)
			Loop
		EndIf

		If !SB9->(dbSeek(MV_PAR01 + NNT->NNT_PROD + cArmDes))
			//-- Cria saldo inicial - MATA220
			If !CriaSldIni(MV_PAR01, NNT->NNT_PROD, cArmDes)
				NNT->(dbSkip())
				VarInfo("SALDO INICIAL", MV_PAR01+"-"+NNT->NNT_PROD+"-"+cArmDes)
				Loop
			EndIf
		EndIf

		If !lInicio
			//-- Quantidade atual de linhas
			nQtdLines := oModelNNT:getQtdLine()

			//-- Quantidade de linhas apos adicionacao
			nAddLine := oModelNNT:addLine()

			If nAddLine == nQtdLines
				NNT->(dbSkip())
				VarInfo("ERRO CRIACAO DA LINHA", NNT->NNT_NUMLOT+"-"+NNT->NNT_LOTECT+"-"+NNT->NNT_PROD)
				Loop
			EndIf
		EndIf

		//oModelNNT:SetValue( "NNT_FILORI", FWCodFil() )
		oModelNNT:SetValue( "NNT_PROD", NNT->NNT_PROD )
		oModelNNT:SetValue( "NNT_LOCAL", NNT->NNT_LOCLD )

		//-- Checa se utiliza rastreabilidade por lote
		If Rastro( NNT->NNT_PROD, "L" )
			oModelNNT:SetValue( "NNT_LOTECT", NNT->NNT_LOTECT )
			oModelNNT:SetValue( "NNT_DTVALI", NNT->NNT_DTVALI )
		EndIf

		//-- Checa se utiliza rastreabilidade por sub-lote
		If Rastro( NNT->NNT_PROD, "S" )
			oModelNNT:SetValue( "NNT_LOTECT", NNT->NNT_LOTECT )
			oModelNNT:SetValue( "NNT_NUMLOT", NNT->NNT_NUMLOT )
			oModelNNT:SetValue( "NNT_DTVALI", NNT->NNT_DTVALI )
		EndIf

		//-- Checa se utiliza localizacao
		If Localiza( NNT->NNT_PROD )
			oModelNNT:SetValue( "NNT_NSERIE", NNT->NNT_NSERIE )
			oModelNNT:SetValue( "NNT_LOCALI", NNT->NNT_LOCALI )
		EndIf

		oModelNNT:SetValue( "NNT_QUANT", NNT->NNT_QUANT )
		oModelNNT:SetValue( "NNT_FILDES", AllTrim( MV_PAR01 ) )

		oModelNNT:SetValue( "NNT_LOCLD", cArmDes )
		oModelNNT:SetValue( "NNT_TS", AllTrim( MV_PAR02 ) )
		oModelNNT:SetValue( "NNT_TE", AllTrim( MV_PAR03 ) )

		If lInicio
			lInicio := .F.
		EndIf

		VarInfo("LINHA OK", NNT->NNT_NUMLOT+"-"+NNT->NNT_LOTECT+"-"+NNT->NNT_PROD)

		NNT->( DbSkip() )
	EndDo

	VarInfo("FIM COPIA TRANSFERENCIA", cFilNNS + cCodNNS)

	RestArea(aAreaNNT)
	RestArea(aAreaNNS)
	RestArea(aAreaSB9)
	RestArea(aAreaSB8)
	RestArea(aAreaAnt)

Return


//--
Static Function CriaSldIni(cFilDes, cProdDes, cArmDes)
    Local aAreaAnt := GetArea()
    Local aAreaSB9 := SB9->(GetArea())
	Local aVetor   := {}
	Local cFilBak  := FWCodFil()

	lMsErroAuto := .F.

    dbSelectArea("SB9")
    SB9->(dbSetOrder(1))

	cFilDes  := PadR(cFilDes, Len(SB9->B9_FILIAL))
	cProdDes := PadR(cProdDes, Len(SB9->B9_COD))
	cArmDes  := PadR(cArmDes, Len(SB9->B9_LOCAL))
	cFilAnt  := cFilDes

	aAdd(aVetor, {"B9_FILIAL", FWCodFil() , Nil})
	aAdd(aVetor, {"B9_COD"   , cProdDes, Nil})
	aAdd(aVetor, {"B9_LOCAL" , cArmDes, Nil})
	aAdd(aVetor, {"B9_QINI"  , 0       , Nil})

	Begin Transaction
		MSExecAuto({|x,y| MATA220(x,y)}, aVetor)
		
		If lMsErroAuto
			DisarmTransaction()
		EndIf
	End Transaction

	cFilAnt := cFilBak

    RestArea(aAreaSB9)
    RestArea(aAreaAnt)

Return !lMsErroAuto


//--
Static Function VldSldSB8(cNumLote, cLoteCTL, cCodProd)
	Local aAreaAnt := GetArea()
	Local aAreaSB8 := SB8->(GetArea())
	Local cQuery   := ""
	Local lRet     := .T.

    If Select("_QRY") > 0
        _QRY->(dbCloseArea())
    EndIf

    //-- SB8
    cQuery := " SELECT "
    cQuery += "     SB8.B8_FILIAL, SB8.B8_PRODUTO, SB8.B8_LOTECTL, SB8.B8_NUMLOTE, SB8.B8_SALDO " 
    cQuery += " FROM "
    cQuery += "     " + RetSQLName("SB8") + " SB8 " 
    cQuery += " WHERE "
    cQuery += "     " + RetSQLCond("SB8")
	cQuery += "     AND SB8.B8_NUMLOTE = '" + cNumLote + "' "
    cQuery += "     AND SB8.B8_LOTECTL = '" + cLoteCTL + "' "
	cQuery += "     AND SB8.B8_PRODUTO = '" + cCodProd + "' "
	cQuery += "     AND SB8.B8_SALDO > 0 "
	cQuery += "     AND SB8.B8_EMPENHO = 0 "

    cQuery := ChangeQuery(cQuery)
    dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), "_QRY", .F., .T.)

	lRet := _QRY->(!EoF()) .And. _QRY->B8_SALDO > 0

    If Select("_QRY") > 0
        _QRY->(dbCloseArea())
    EndIf

	RestArea(aAreaSB8)
	RestArea(aAreaAnt)

Return lRet


//-- U_REESTA1G
User Function REESTA1G()
	Local aAreaAnt  := GetArea()
	Local aAreaSB2  := SB2->(GetArea())
	Local oModel    := FWModelActive()
	Local oModelNNT := oModel:GetModel("NNTDETAIL")
	Local cProduto  := oModelNNT:getValue("NNT_PROD")
	Local cLocal    := oModelNNT:getValue("NNT_LOCAL")
	Local nQuant    := oModelNNT:getValue("NNT_QUANT")
	Local lRet      := .T.

	If !u_xIsFilme(cProduto)
		SB2->(dbSetOrder(1))
		If SB2->(dbSeek(xFilial("SB2") + cProduto + cLocal))
			If SaldoSB2() < nQuant
				Help(Nil, Nil, "ERRSALDO", Nil, "Não existe saldo suficiente.", 1, 0, Nil, Nil, Nil, Nil, Nil, {"Informe uma quantidade menor ou consulte o saldo clicando F4."})
				lRet := .F.
			Endif
		Endif
	EndIf

	RestArea(aAreaSB2)
	RestArea(aAreaAnt)

Return lRet
