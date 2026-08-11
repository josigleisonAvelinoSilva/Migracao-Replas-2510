#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TOPCONN.CH"

//----------------------------------------------------------------
/*/{Protheus.doc} REFATC01
Tela de pesquisa de itens dos pedidos

@author Rafael Domingues
@since 05.02.2018
/*/
//----------------------------------------------------------------

User function REFATC01()

	Local oDlgMain 		:= Nil
	Local oListBox 		:= Nil
	Local aCoordenadas 	:= MsAdvSize(.T.)
	Local nOpcClick 	:= 0
	Local lEdicao 		:= .T.
	Local aButtons 		:= {}

	Private cPedido 	:= Space(TamSX3("C5_NUM")[1])
	Private cCliente 	:= Space(TamSX3("C5_CLIENTE")[1])
	Private cProduto 	:= Space(TamSX3("C6_PRODUTO")[1])
	Private dEmissao 	:= CtoD("  /  /  ")
	Private dEntrega 	:= CtoD("  /  /  ")
	Private cCodVen		:= RetVend()
	Private aPedidos 	:= {}

	Private oVerde 		:= LoadBitmap(GetResources(),'BR_VERDE' 	) 	//Em aberto
	Private oAmarelo 	:= LoadBitmap(GetResources(),'BR_AMARELO' 	) 	//Liberado
	Private oAzul 		:= LoadBitmap(GetResources(),'BR_AZUL' 		) 	//Bloqueio por Regra
	Private oAzulClaro	:= LoadBitmap(GetResources(),'BR_AZUL_CLARO') 	//Bloqueio por Regra Condicao de Pagamento
	Private oVioleta 	:= LoadBitmap(GetResources(),'BR_VIOLETA' 	) 	//Bloqueio Credito e Estoque
	Private oBranco 	:= LoadBitmap(GetResources(),'BR_BRANCO' 	) 	//Bloqueio somente Credito
	Private oCinza 		:= LoadBitmap(GetResources(),'BR_CINZA' 	) 	//Bloqueio somente Estoque
	Private oLaranja 	:= LoadBitmap(GetResources(),'BR_LARANJA' 	) 	//Item Em Carga (Aguardando Faturamento)
	Private oPreto 		:= LoadBitmap(GetResources(),'BR_PRETO' 	) 	//Eliminado Resíduo
	Private oVermelho 	:= LoadBitmap(GetResources(),'BR_VERMELHO' 	) 	//Faturado

	AADD( aButtons, {"LEGENDA", {|| BLegenda()}, "Legenda","Legenda",{|| .T.}} )

	//Desenha a Tela
	oDlgMain := TDialog():New(aCoordenadas[7],000,aCoordenadas[6],aCoordenadas[5],OemToAnsi("Pesquisa Pedidos"),,,,,,,,oMainWnd,.T.)
	TGroup():New(034,003,140,oDlgMain:nClientWidth/2-5,"Parâmetros:",oDlgMain,,,.T.)

	TSay():New(044,017,{||"Pesquisar Pedido?"},oDlgMain,,,.F.,.F.,.F.,.T.,CLR_HBLUE,,100,009)
	@ 044,088 MsGet cPedido Of oDlgMain F3 "C5TELA" PIXEL SIZE 100,009 When lEdicao

	TSay():New(044,217,{||"Data Emissão?"},oDlgMain,,,.F.,.F.,.F.,.T.,CLR_HBLUE,,100,009)
	@ 044,288 MsGet dEmissao Of oDlgMain PIXEL SIZE 100,009 When lEdicao

	TSay():New(060,017,{||"Pesquisar Cliente?"},oDlgMain,,,.F.,.F.,.F.,.T.,CLR_HBLUE,,100,009)
	@ 060,088 MsGet cCliente Of oDlgMain F3 "SA1" PIXEL SIZE 100,009 When lEdicao

	TSay():New(060,217,{||"Data Entrega?"},oDlgMain,,,.F.,.F.,.F.,.T.,CLR_HBLUE,,100,009)
	@ 060,288 MsGet dEntrega Of oDlgMain PIXEL SIZE 100,009 When lEdicao

	TSay():New(076,017,{||"Pesquisar Produto?"},oDlgMain,,,.F.,.F.,.F.,.T.,CLR_HBLUE,,100,009)
	@ 076,088 MsGet cProduto Of oDlgMain F3 "SB1" PIXEL SIZE 100,009 When lEdicao

	TButton():New(120,008,"Buscar",oDlgMain,{|| Processa(BuscaPedidos(@oListBox,@lEdicao)) },045,011,,,,.T.,,"",,,,.F. )
	TButton():New(120,058,"Limpar",oDlgMain,{|| aPedidos := {{"","","","","","","","","","","",""}},;
												oListBox:SetArray(aPedidos),;
												oListBox:bLine := {||{ 	MudaCor(aPedidos[oListBox:nAt][1]),;
												aPedidos[oListBox:nAt][2],;
												aPedidos[oListBox:nAt][3],;
												aPedidos[oListBox:nAt][4],;
												aPedidos[oListBox:nAt][5],;
												aPedidos[oListBox:nAt][6],;
												aPedidos[oListBox:nAt][7],;
												aPedidos[oListBox:nAt][8],;
												aPedidos[oListBox:nAt][9],;
												aPedidos[oListBox:nAt][10],;
												aPedidos[oListBox:nAt][11],;
												aPedidos[oListBox:nAt][12]}},;
												lEdicao  := .T.,;
												cPedido  := Space(TamSX3("C5_NUM")[1]),;
												cCliente := Space(TamSX3("C5_CLIENTE")[1]),;
												cProduto := Space(TamSX3("C6_PRODUTO")[1]),;
												dEmissao 	:= CtoD("  /  /  "),;
												dEntrega 	:= CtoD("  /  /  ")},045,011,,,,.T.,,"",,,,.F. )

	TGroup():New(145,003,oDlgMain:nClientHeight/2-15,oDlgMain:nClientWidth/2-5,"Itens do pedido de venda",oDlgMain,,,.T.)
		aPedidos := {{"","","","","","","","","","","",""}}
		oListBox := TWBrowse():New(155,008,oDlgMain:nClientWidth/2-17,oDlgMain:nClientHeight/2-175,,{"", "Filial", "Pedido", "Item", "Produto", "Descrição", "Unidade", "Quantidade", "Preço Unitário", "Valor Total", "Armazém", "TES"},,oDlgMain,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
		oListBox:SetArray(aPedidos)
		oListBox:bLine := {||{ 	MudaCor(aPedidos[oListBox:nAt][1]),;
										aPedidos[oListBox:nAt][2],;
										aPedidos[oListBox:nAt][3],;
										aPedidos[oListBox:nAt][4],;
										aPedidos[oListBox:nAt][5],;
										aPedidos[oListBox:nAt][6],;
										aPedidos[oListBox:nAt][7],;
										aPedidos[oListBox:nAt][8],;
										aPedidos[oListBox:nAt][9],;
										aPedidos[oListBox:nAt][10],;
										aPedidos[oListBox:nAt][11],;
										aPedidos[oListBox:nAt][12]}}

	EnchoiceBar(oDlgMain,{|| nOpcClick := 1, oDlgMain:End() },{|| nOpcClick := 0, oDlgMain:End()},,@aButtons)
	oDlgMain:Activate(,,,.T.)

Return()

//----------------------------------------------------------------
/*/{Protheus.doc} BuscaPedidos
Tela de pesquisa de itens dos pedidos

@author Rafael Domingues
@since 05.02.2018
/*/
//----------------------------------------------------------------

Static Function BuscaPedidos(oListBox,lEdicao)

	aPedidos := {}

	//Monta pedidos em aberto
	FWMsgRun( , {|| REFATC1A() }, 'Processando','Consultando pedidos em aberto...' )

	//Monta pedidos liberados
	FWMsgRun( , {|| REFATC1B() }, 'Processando','Consultando pedidos liberados...' )

	//Monta pedidos faturados
	FWMsgRun( , {|| REFATC1C() }, 'Processando','Consultando pedidos faturados...' )

	//Monta pedidos eliminado residuo
	FWMsgRun( , {|| REFATC1D() }, 'Processando','Consultando pedidos eliminado residuos...' )

	//Monta pedidos item Em Carga (Aguardando Faturamento)
	FWMsgRun( , {|| REFATC1E() }, 'Processando','Consultando pedidos em carga...' )

	//Monta pedidos bloqueio credito e estoque
	FWMsgRun( , {|| REFATC1F() }, 'Processando','Consultando pedidos bloqueio de credito e estoque...' )

	//Monta pedidos bloqueio somente credito
	FWMsgRun( , {|| REFATC1G() }, 'Processando','Consultando pedidos bloqueio somente credito...' )

	//Monta pedidos bloqueio somente estoque
	FWMsgRun( , {|| REFATC1H() }, 'Processando','Consultando pedidos bloqueio somente estoque...' )

	//Monta pedidos bloqueio por regra
	FWMsgRun( , {|| REFATC1I() }, 'Processando','Consultando pedidos bloqueio por regra...' )

	//Atualiza o list de produtos
	oListBox:SetArray(aPedidos)
	oListBox:bLine := {||{ 	Iif(!Empty(aPedidos[oListBox:nAt][1]),MudaCor(aPedidos[oListBox:nAt][1]),aPedidos[oListBox:nAt][1]),;
										aPedidos[oListBox:nAt][2],;
										aPedidos[oListBox:nAt][3],;
										aPedidos[oListBox:nAt][4],;
										aPedidos[oListBox:nAt][5],;
										aPedidos[oListBox:nAt][6],;
										aPedidos[oListBox:nAt][7],;
										aPedidos[oListBox:nAt][8],;
										aPedidos[oListBox:nAt][9],;
										aPedidos[oListBox:nAt][10],;
										aPedidos[oListBox:nAt][11],;
										aPedidos[oListBox:nAt][12]}}

	oListBox:Refresh()
	lEdicao := .F.

Return(Nil)

//----------------------------------------------------------------
/*/{Protheus.doc} MudaCor
Muda cor das legendas

@author Rafael Domingues
@since 05.02.2018
/*/
//----------------------------------------------------------------

Static Function MudaCor(cOp)

	Do Case
		Case cOp == 'A'
		Return oVerde
		Case cOp == 'B'
		Return oAmarelo
		Case cOp == 'C'
		Return oVermelho
		Case cOp == 'D'
		Return oPreto
		Case cOp == 'E'
		Return oLaranja
		Case cOp == 'F'
		Return oVioleta
		Case cOp == 'G'
		Return oBranco
		Case cOp == 'H'
		Return oCinza
		Case cOp == 'I'
		Return oAzul
		Case cOp == 'P'
		Return oAzulClaro		
	End Case

Return oVerde

//----------------------------------------------------------------
/*/{Protheus.doc} BLegenda
Monta a legenda dos itens dos pedidos

@author Rafael Domingues
@since 05.02.2018
/*/
//----------------------------------------------------------------

Static Function BLegenda()

	Local aLegenda := {}

	AADD(aLegenda,{"BR_VERDE" 		,"Em aberto" 								})
	AADD(aLegenda,{"BR_AMARELO" 	,"Liberado" 								})
	AADD(aLegenda,{"BR_AZUL" 		,"Bloqueio por Regra" 						})
	AADD(aLegenda,{"BR_AZUL_CLARO" 	,"Bloqueio por Regra (Cond.Pagamento)" 		})
	AADD(aLegenda,{"BR_VIOLETA" 	,"Bloqueio Credito e Estoque"				})
	AADD(aLegenda,{"BR_BRANCO" 		,"Bloqueio somente Credito" 				})
	AADD(aLegenda,{"BR_CINZA" 		,"Bloqueio somente Estoque" 				})
	AADD(aLegenda,{"BR_LARANJA" 	,"Item Em Carga (Aguardando Faturamento)" 	})
	AADD(aLegenda,{"BR_PRETO" 		,"Eliminado Resíduo" 						})
	AADD(aLegenda,{"BR_VERMELHO" 	,"Faturado" 								})

	BrwLegenda("Legenda", "Legenda", aLegenda)

Return Nil

//----------------------------------------------------------------
/*/{Protheus.doc} RetVend
Retorna código do vendedor

@author Rafael Domingues
@since 05.02.2018
/*/
//----------------------------------------------------------------

Static Function RetVend()

	Local cVend 	:= RetCodUsr()
	Local _cUsers 	:= ""

	//---> REMOVIDO compatibilização para versão 12.1.25.
	/*If !GetMv("MV_XFATUSR", .T.)
		CriarSX6("MV_XFATUSR", 'C', 'CODIGO DE USUARIO LIBERADOS PARA CONSULTA DE PEDIDOS. REFATC01.prw', '000000;000012;000078')
	Endif*/

	_cUsers := GetMv("MV_XFATUSR", .F.)

	If AllTrim(cVend) $ AllTrim(_cUsers)
		cVend := ""
		Return(cVend)
	Else
		DbSelectArea("AO3")
		DbSetOrder(1)
		If DbSeek(xFilial("AO3") + cVend)
			cVend := AO3->AO3_VEND
		EndIf
	EndIf

Return(cVend)

//----------------------------------------------------------------
/*/{Protheus.doc} REFATC1A
Query para pedidos em aberto

@author Rafael Domingues
@since 05.02.2018
/*/
//----------------------------------------------------------------

Static Function REFATC1A()

	Local cQuery := ""

	cQuery := " SELECT * FROM "+RetSqlName("SC5")+ " SC5 "
	cQuery += " INNER JOIN "+RetSqlName("SC6")+ " SC6 ON SC6.D_E_L_E_T_ = '' AND C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM "
	cQuery += " WHERE SC5.D_E_L_E_T_ = '' "
	cQuery += " AND C5_FILIAL = '"+xFilial("SC5")+"' "
	cQuery += " AND NOT EXISTS (SELECT * 
	cQuery += "                 FROM "+RetSqlName("SC9")+ " SC9
	cQuery += "                 WHERE C9_FILIAL=C6_FILIAL 
	cQuery += "                 AND   C9_PEDIDO= C6_NUM
	cQuery += " 				AND   C9_ITEM   = C6_ITEM
	cQuery += " 				AND   C9_PRODUTO=C6_PRODUTO
	cQuery += " 				AND   SC9.D_E_L_E_T_ = ' '
	cQuery += " 				)   
	cQuery += " AND C6_BLQ = '' "
	cQuery += " AND C6_BLOQUEI = '' "

	If !Empty(cPedido)
		cQuery += " AND C6_NUM = '"+cPedido+"' " +CHR(13)+CHR(10)
	EndIf

	If !Empty(dEmissao)
		cQuery += " AND C5_EMISSAO = '"+DtoS(dEmissao)+"' " +CHR(13)+CHR(10)
	EndIf

	If !Empty(cCliente)
		cQuery += " AND C6_CLI = '"+cCliente+"' " +CHR(13)+CHR(10)
	EndIf

	If !Empty(dEntrega)
		cQuery += " AND C6_ENTREG = '"+DtoS(dEntrega)+"' " +CHR(13)+CHR(10)
	EndIf

	If !Empty(cProduto)
		cQuery += " AND C6_PRODUTO = '"+cProduto+"' " +CHR(13)+CHR(10)
	EndIf

	If !Empty(cCodVen)
		cQuery += " AND C5_VEND1 = '"+cCodVen+"' " +CHR(13)+CHR(10)
	EndIf

	cQuery += " ORDER BY C6_NUM, C6_ITEM "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TMP",.F.,.T.)

	DbSelectArea("TMP")
	DbGoTop()

	While !Eof()

		AAdd(aPedidos,{"A",TMP->C5_FILIAL,TMP->C6_NUM,TMP->C6_ITEM,TMP->C6_PRODUTO,TMP->C6_DESCRI,TMP->C6_UM,Transform(TMP->C6_QTDVEN,"@E 999,999,999.99"),Transform(TMP->C6_PRCVEN,"@E 999,999,999.99"),Transform(TMP->C6_VALOR,"@E 999,999,999.99"),TMP->C6_LOCAL,TMP->C6_TES})

		DbSelectArea("TMP")
		DbSkip()

	End

	DbSelectArea("TMP")
	DbCloseArea()

Return

//----------------------------------------------------------------
/*/{Protheus.doc} REFATC1B
Query para pedidos liberados

@author Rafael Domingues
@since 05.02.2018
/*/
//----------------------------------------------------------------

Static Function REFATC1B()

	Local cQuery := ""

	cQuery := " SELECT * FROM "+RetSqlName("SC5")+ " SC5 "
	cQuery += " INNER JOIN "+RetSqlName("SC6")+ " SC6 ON SC6.D_E_L_E_T_ = '' AND C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM "
	cQuery += " INNER JOIN "+RetSqlName("SC9")+ " SC9 ON SC9.D_E_L_E_T_ = '' AND C9_FILIAL = C6_FILIAL AND C9_PEDIDO = C6_NUM AND C9_ITEM = C6_ITEM AND C6_PRODUTO = C9_PRODUTO "
	cQuery += " WHERE SC5.D_E_L_E_T_ = '' "
	cQuery += " AND C5_FILIAL = '"+xFilial("SC5")+"' "
	cQuery += " AND C6_BLOQUEI = '' "
	cQuery += " AND C6_BLQ = '' "
	cQuery += " AND C9_CARGA = '' "
	cQuery += " AND C9_NFISCAL = '' "
	cQuery += " AND C9_SERIENF = '' "
	cQuery += " AND C9_BLCRED = '' "
	cQuery += " AND C9_BLEST = '' "

	If !Empty(cPedido)
		cQuery += " AND C6_NUM = '"+cPedido+"' " +CHR(13)+CHR(10)
	EndIf

	If !Empty(dEmissao)
		cQuery += " AND C5_EMISSAO = '"+DtoS(dEmissao)+"' " +CHR(13)+CHR(10)
	EndIf

	If !Empty(cCliente)
		cQuery += " AND C6_CLI = '"+cCliente+"' " +CHR(13)+CHR(10)
	EndIf

	If !Empty(dEntrega)
		cQuery += " AND C6_ENTREG = '"+DtoS(dEntrega)+"' " +CHR(13)+CHR(10)
	EndIf

	If !Empty(cProduto)
		cQuery += " AND C6_PRODUTO = '"+cProduto+"' " +CHR(13)+CHR(10)
	EndIf

	If !Empty(cCodVen)
		cQuery += " AND C5_VEND1 = '"+cCodVen+"' " +CHR(13)+CHR(10)
	EndIf

	cQuery += " ORDER BY C6_NUM, C6_ITEM "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TMP",.F.,.T.)

	DbSelectArea("TMP")
	DbGoTop()

	While !Eof()

		AAdd(aPedidos,{"B",TMP->C5_FILIAL,TMP->C6_NUM,TMP->C6_ITEM,TMP->C6_PRODUTO,TMP->C6_DESCRI,TMP->C6_UM,Transform(TMP->C6_QTDVEN,"@E 999,999,999.99"),Transform(TMP->C6_PRCVEN,"@E 999,999,999.99"),Transform(TMP->C6_VALOR,"@E 999,999,999.99"),TMP->C6_LOCAL,TMP->C6_TES})

		DbSelectArea("TMP")
		DbSkip()

	End

	DbSelectArea("TMP")
	DbCloseArea()

Return

//----------------------------------------------------------------
/*/{Protheus.doc} REFATC1C
Query para pedidos faturados

@author Rafael Domingues
@since 05.02.2018
/*/
//----------------------------------------------------------------

Static Function REFATC1C()

	Local cQuery := ""

	cQuery := " SELECT * FROM "+RetSqlName("SC5")+ " SC5 "
	cQuery += " INNER JOIN "+RetSqlName("SC6")+ " SC6 ON SC6.D_E_L_E_T_ = '' AND C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM "
	cQuery += " INNER JOIN "+RetSqlName("SC9")+ " SC9 ON SC9.D_E_L_E_T_ = '' AND C9_FILIAL = C6_FILIAL AND C9_PEDIDO = C6_NUM AND C9_ITEM = C6_ITEM AND C6_PRODUTO = C9_PRODUTO "
	cQuery += " WHERE SC5.D_E_L_E_T_ = '' "
	cQuery += " AND C5_FILIAL = '"+xFilial("SC5")+"' "
	cQuery += " AND C9_NFISCAL <> '' "
	cQuery += " AND C9_SERIENF <> '' "

	If !Empty(cPedido)
		cQuery += " AND C6_NUM = '"+cPedido+"' " +CHR(13)+CHR(10)
	EndIf

	If !Empty(dEmissao)
		cQuery += " AND C5_EMISSAO = '"+DtoS(dEmissao)+"' " +CHR(13)+CHR(10)
	EndIf

	If !Empty(cCliente)
		cQuery += " AND C6_CLI = '"+cCliente+"' " +CHR(13)+CHR(10)
	EndIf

	If !Empty(dEntrega)
		cQuery += " AND C6_ENTREG = '"+DtoS(dEntrega)+"' " +CHR(13)+CHR(10)
	EndIf

	If !Empty(cProduto)
		cQuery += " AND C6_PRODUTO = '"+cProduto+"' " +CHR(13)+CHR(10)
	EndIf

	If !Empty(cCodVen)
		cQuery += " AND C5_VEND1 = '"+cCodVen+"' " +CHR(13)+CHR(10)
	EndIf

	cQuery += " ORDER BY C6_NUM, C6_ITEM "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TMP",.F.,.T.)

	DbSelectArea("TMP")
	DbGoTop()

	While !Eof()

		AAdd(aPedidos,{"C",TMP->C5_FILIAL,TMP->C6_NUM,TMP->C6_ITEM,TMP->C6_PRODUTO,TMP->C6_DESCRI,TMP->C6_UM,Transform(TMP->C6_QTDVEN,"@E 999,999,999.99"),Transform(TMP->C6_PRCVEN,"@E 999,999,999.99"),Transform(TMP->C6_VALOR,"@E 999,999,999.99"),TMP->C6_LOCAL,TMP->C6_TES})

		DbSelectArea("TMP")
		DbSkip()

	End

	DbSelectArea("TMP")
	DbCloseArea()

Return

//----------------------------------------------------------------
/*/{Protheus.doc} REFATC1D
Query para pedidos eliminado residuo

@author Rafael Domingues
@since 05.02.2018
/*/
//----------------------------------------------------------------

Static Function REFATC1D()

	Local cQuery := ""

	cQuery := " SELECT * FROM "+RetSqlName("SC5")+ " SC5 "
	cQuery += " INNER JOIN "+RetSqlName("SC6")+ " SC6 ON SC6.D_E_L_E_T_ = '' AND C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM "
	cQuery += " WHERE SC5.D_E_L_E_T_ = '' "
	cQuery += " AND C5_FILIAL = '"+xFilial("SC5")+"' "
	cQuery += " AND C6_BLQ = 'R' "

	If !Empty(cPedido)
		cQuery += " AND C6_NUM = '"+cPedido+"' " +CHR(13)+CHR(10)
	EndIf

	If !Empty(dEmissao)
		cQuery += " AND C5_EMISSAO = '"+DtoS(dEmissao)+"' " +CHR(13)+CHR(10)
	EndIf

	If !Empty(cCliente)
		cQuery += " AND C6_CLI = '"+cCliente+"' " +CHR(13)+CHR(10)
	EndIf

	If !Empty(dEntrega)
		cQuery += " AND C6_ENTREG = '"+DtoS(dEntrega)+"' " +CHR(13)+CHR(10)
	EndIf

	If !Empty(cProduto)
		cQuery += " AND C6_PRODUTO = '"+cProduto+"' " +CHR(13)+CHR(10)
	EndIf

	If !Empty(cCodVen)
		cQuery += " AND C5_VEND1 = '"+cCodVen+"' " +CHR(13)+CHR(10)
	EndIf

	cQuery += " ORDER BY C6_NUM, C6_ITEM "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TMP",.F.,.T.)

	DbSelectArea("TMP")
	DbGoTop()

	While !Eof()

		AAdd(aPedidos,{"D",TMP->C5_FILIAL,TMP->C6_NUM,TMP->C6_ITEM,TMP->C6_PRODUTO,TMP->C6_DESCRI,TMP->C6_UM,Transform(TMP->C6_QTDVEN,"@E 999,999,999.99"),Transform(TMP->C6_PRCVEN,"@E 999,999,999.99"),Transform(TMP->C6_VALOR,"@E 999,999,999.99"),TMP->C6_LOCAL,TMP->C6_TES})

		DbSelectArea("TMP")
		DbSkip()

	End

	DbSelectArea("TMP")
	DbCloseArea()

Return

//----------------------------------------------------------------
/*/{Protheus.doc} REFATC1E
Query para pedidos Item Em Carga (Aguardando Faturamento)

@author Rafael Domingues
@since 05.02.2018
/*/
//----------------------------------------------------------------

Static Function REFATC1E()

	Local cQuery := ""

	cQuery := " SELECT * FROM "+RetSqlName("SC5")+ " SC5 "
	cQuery += " INNER JOIN "+RetSqlName("SC6")+ " SC6 ON SC6.D_E_L_E_T_ = '' AND C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM "
	cQuery += " INNER JOIN "+RetSqlName("SC9")+ " SC9 ON SC9.D_E_L_E_T_ = '' AND C9_FILIAL = C6_FILIAL AND C9_PEDIDO = C6_NUM AND C9_ITEM = C6_ITEM AND C6_PRODUTO = C9_PRODUTO "
	cQuery += " WHERE SC5.D_E_L_E_T_ = '' "
	cQuery += " AND C5_FILIAL = '"+xFilial("SC5")+"' "
	cQuery += " AND C9_CARGA <> '' "
	cQuery += " AND C9_NFISCAL = '' "
	cQuery += " AND C9_SERIENF = '' "

	If !Empty(cPedido)
		cQuery += " AND C6_NUM = '"+cPedido+"' " +CHR(13)+CHR(10)
	EndIf

	If !Empty(dEmissao)
		cQuery += " AND C5_EMISSAO = '"+DtoS(dEmissao)+"' " +CHR(13)+CHR(10)
	EndIf

	If !Empty(cCliente)
		cQuery += " AND C6_CLI = '"+cCliente+"' " +CHR(13)+CHR(10)
	EndIf

	If !Empty(dEntrega)
		cQuery += " AND C6_ENTREG = '"+DtoS(dEntrega)+"' " +CHR(13)+CHR(10)
	EndIf

	If !Empty(cProduto)
		cQuery += " AND C6_PRODUTO = '"+cProduto+"' " +CHR(13)+CHR(10)
	EndIf

	If !Empty(cCodVen)
		cQuery += " AND C5_VEND1 = '"+cCodVen+"' " +CHR(13)+CHR(10)
	EndIf

	cQuery += " ORDER BY C6_NUM, C6_ITEM "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TMP",.F.,.T.)

	DbSelectArea("TMP")
	DbGoTop()

	While !Eof()

		AAdd(aPedidos,{"E",TMP->C5_FILIAL,TMP->C6_NUM,TMP->C6_ITEM,TMP->C6_PRODUTO,TMP->C6_DESCRI,TMP->C6_UM,Transform(TMP->C6_QTDVEN,"@E 999,999,999.99"),Transform(TMP->C6_PRCVEN,"@E 999,999,999.99"),Transform(TMP->C6_VALOR,"@E 999,999,999.99"),TMP->C6_LOCAL,TMP->C6_TES})

		DbSelectArea("TMP")
		DbSkip()

	End

	DbSelectArea("TMP")
	DbCloseArea()

Return

//----------------------------------------------------------------
/*/{Protheus.doc} REFATC1F
Query para pedidos bloqueados por credito e estoque

@author Rafael Domingues
@since 05.02.2018
/*/
//----------------------------------------------------------------

Static Function REFATC1F()

	Local cQuery := ""

	cQuery := " SELECT * FROM "+RetSqlName("SC5")+ " SC5 "
	cQuery += " INNER JOIN "+RetSqlName("SC6")+ " SC6 ON SC6.D_E_L_E_T_ = '' AND C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM "
	cQuery += " INNER JOIN "+RetSqlName("SC9")+ " SC9 ON SC9.D_E_L_E_T_ = '' AND C9_FILIAL = C6_FILIAL AND C9_PEDIDO = C6_NUM AND C9_ITEM = C6_ITEM AND C6_PRODUTO = C9_PRODUTO "
	cQuery += " WHERE SC5.D_E_L_E_T_ = '' "
	cQuery += " AND C5_FILIAL = '"+xFilial("SC5")+"' "
	cQuery += " AND C6_BLOQUEI = '' "
	cQuery += " AND C6_BLQ = '' "
	cQuery += " AND C9_CARGA = '' "
	cQuery += " AND C9_NFISCAL = '' "
	cQuery += " AND C9_SERIENF = '' "
	cQuery += " AND C9_BLCRED = '01' "
	cQuery += " AND C9_BLEST = '02' "

	If !Empty(cPedido)
		cQuery += " AND C6_NUM = '"+cPedido+"' " +CHR(13)+CHR(10)
	EndIf

	If !Empty(dEmissao)
		cQuery += " AND C5_EMISSAO = '"+DtoS(dEmissao)+"' " +CHR(13)+CHR(10)
	EndIf

	If !Empty(cCliente)
		cQuery += " AND C6_CLI = '"+cCliente+"' " +CHR(13)+CHR(10)
	EndIf

	If !Empty(dEntrega)
		cQuery += " AND C6_ENTREG = '"+DtoS(dEntrega)+"' " +CHR(13)+CHR(10)
	EndIf

	If !Empty(cProduto)
		cQuery += " AND C6_PRODUTO = '"+cProduto+"' " +CHR(13)+CHR(10)
	EndIf

	If !Empty(cCodVen)
		cQuery += " AND C5_VEND1 = '"+cCodVen+"' " +CHR(13)+CHR(10)
	EndIf

	cQuery += " ORDER BY C6_NUM, C6_ITEM "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TMP",.F.,.T.)

	DbSelectArea("TMP")
	DbGoTop()

	While !Eof()

		AAdd(aPedidos,{"F",TMP->C5_FILIAL,TMP->C6_NUM,TMP->C6_ITEM,TMP->C6_PRODUTO,TMP->C6_DESCRI,TMP->C6_UM,Transform(TMP->C6_QTDVEN,"@E 999,999,999.99"),Transform(TMP->C6_PRCVEN,"@E 999,999,999.99"),Transform(TMP->C6_VALOR,"@E 999,999,999.99"),TMP->C6_LOCAL,TMP->C6_TES})

		DbSelectArea("TMP")
		DbSkip()

	End

	DbSelectArea("TMP")
	DbCloseArea()

Return

//----------------------------------------------------------------
/*/{Protheus.doc} REFATC1G
Query para pedidos bloqueados somente credito

@author Rafael Domingues
@since 05.02.2018
/*/
//----------------------------------------------------------------

Static Function REFATC1G()

	Local cQuery := ""

	cQuery := " SELECT * FROM "+RetSqlName("SC5")+ " SC5 "
	cQuery += " INNER JOIN "+RetSqlName("SC6")+ " SC6 ON SC6.D_E_L_E_T_ = '' AND C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM "
	cQuery += " INNER JOIN "+RetSqlName("SC9")+ " SC9 ON SC9.D_E_L_E_T_ = '' AND C9_FILIAL = C6_FILIAL AND C9_PEDIDO = C6_NUM AND C9_ITEM = C6_ITEM AND C6_PRODUTO = C9_PRODUTO "
	cQuery += " WHERE SC5.D_E_L_E_T_ = '' "
	cQuery += " AND C5_FILIAL = '"+xFilial("SC5")+"' "
	cQuery += " AND C6_BLOQUEI = '' "
	cQuery += " AND C6_BLQ = '' "
	cQuery += " AND C9_CARGA = '' "
	cQuery += " AND C9_NFISCAL = '' "
	cQuery += " AND C9_SERIENF = '' "
	cQuery += " AND C9_BLCRED = '01' "
	cQuery += " AND C9_BLEST = '' "

	If !Empty(cPedido)
		cQuery += " AND C6_NUM = '"+cPedido+"' " +CHR(13)+CHR(10)
	EndIf

	If !Empty(dEmissao)
		cQuery += " AND C5_EMISSAO = '"+DtoS(dEmissao)+"' " +CHR(13)+CHR(10)
	EndIf

	If !Empty(cCliente)
		cQuery += " AND C6_CLI = '"+cCliente+"' " +CHR(13)+CHR(10)
	EndIf

	If !Empty(dEntrega)
		cQuery += " AND C6_ENTREG = '"+DtoS(dEntrega)+"' " +CHR(13)+CHR(10)
	EndIf

	If !Empty(cProduto)
		cQuery += " AND C6_PRODUTO = '"+cProduto+"' " +CHR(13)+CHR(10)
	EndIf

	If !Empty(cCodVen)
		cQuery += " AND C5_VEND1 = '"+cCodVen+"' " +CHR(13)+CHR(10)
	EndIf

	cQuery += " ORDER BY C6_NUM, C6_ITEM "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TMP",.F.,.T.)

	DbSelectArea("TMP")
	DbGoTop()

	While !Eof()

		AAdd(aPedidos,{"G",TMP->C5_FILIAL,TMP->C6_NUM,TMP->C6_ITEM,TMP->C6_PRODUTO,TMP->C6_DESCRI,TMP->C6_UM,Transform(TMP->C6_QTDVEN,"@E 999,999,999.99"),Transform(TMP->C6_PRCVEN,"@E 999,999,999.99"),Transform(TMP->C6_VALOR,"@E 999,999,999.99"),TMP->C6_LOCAL,TMP->C6_TES})

		DbSelectArea("TMP")
		DbSkip()

	End

	DbSelectArea("TMP")
	DbCloseArea()

Return

//----------------------------------------------------------------
/*/{Protheus.doc} REFATC1H
Query para pedidos bloqueados somente estoque

@author Rafael Domingues
@since 05.02.2018
/*/
//----------------------------------------------------------------

Static Function REFATC1H()

	Local cQuery := ""

	cQuery := " SELECT * FROM "+RetSqlName("SC5")+ " SC5 "
	cQuery += " INNER JOIN "+RetSqlName("SC6")+ " SC6 ON SC6.D_E_L_E_T_ = '' AND C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM "
	cQuery += " INNER JOIN "+RetSqlName("SC9")+ " SC9 ON SC9.D_E_L_E_T_ = '' AND C9_FILIAL = C6_FILIAL AND C9_PEDIDO = C6_NUM AND C9_ITEM = C6_ITEM AND C6_PRODUTO = C9_PRODUTO "
	cQuery += " WHERE SC5.D_E_L_E_T_ = '' "
	cQuery += " AND C5_FILIAL = '"+xFilial("SC5")+"' "
	cQuery += " AND C6_BLOQUEI = '' "
	cQuery += " AND C6_BLQ = '' "
	cQuery += " AND C9_CARGA = '' "
	cQuery += " AND C9_NFISCAL = '' "
	cQuery += " AND C9_SERIENF = '' "
	cQuery += " AND C9_BLCRED = '' "
	cQuery += " AND C9_BLEST = '02' "

	If !Empty(cPedido)
		cQuery += " AND C6_NUM = '"+cPedido+"' " +CHR(13)+CHR(10)
	EndIf

	If !Empty(dEmissao)
		cQuery += " AND C5_EMISSAO = '"+DtoS(dEmissao)+"' " +CHR(13)+CHR(10)
	EndIf

	If !Empty(cCliente)
		cQuery += " AND C6_CLI = '"+cCliente+"' " +CHR(13)+CHR(10)
	EndIf

	If !Empty(dEntrega)
		cQuery += " AND C6_ENTREG = '"+DtoS(dEntrega)+"' " +CHR(13)+CHR(10)
	EndIf

	If !Empty(cProduto)
		cQuery += " AND C6_PRODUTO = '"+cProduto+"' " +CHR(13)+CHR(10)
	EndIf

	If !Empty(cCodVen)
		cQuery += " AND C5_VEND1 = '"+cCodVen+"' " +CHR(13)+CHR(10)
	EndIf

	cQuery += " ORDER BY C6_NUM, C6_ITEM "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TMP",.F.,.T.)

	DbSelectArea("TMP")
	DbGoTop()

	While !Eof()

		AAdd(aPedidos,{"H",TMP->C5_FILIAL,TMP->C6_NUM,TMP->C6_ITEM,TMP->C6_PRODUTO,TMP->C6_DESCRI,TMP->C6_UM,Transform(TMP->C6_QTDVEN,"@E 999,999,999.99"),Transform(TMP->C6_PRCVEN,"@E 999,999,999.99"),Transform(TMP->C6_VALOR,"@E 999,999,999.99"),TMP->C6_LOCAL,TMP->C6_TES})

		DbSelectArea("TMP")
		DbSkip()

	End

	DbSelectArea("TMP")
	DbCloseArea()

Return

//----------------------------------------------------------------
/*/{Protheus.doc} REFATC1I
Query para pedidos bloqueados por regra

@author Rafael Domingues
@since 05.02.2018
/*/
//----------------------------------------------------------------

Static Function REFATC1I()

	Local cQuery := ""
	Local cTpBlq := "I" //-- Tipo de Bloqueio por regra

	cQuery := " SELECT * FROM "+RetSqlName("SC5")+ " SC5 "
	cQuery += " INNER JOIN "+RetSqlName("SC6")+ " SC6 ON SC6.D_E_L_E_T_ = '' AND C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM "
	cQuery += " INNER JOIN "+RetSqlName("SC9")+ " SC9 ON SC9.D_E_L_E_T_ = '' AND C9_FILIAL = C6_FILIAL AND C9_PEDIDO = C6_NUM AND C9_ITEM = C6_ITEM AND C6_PRODUTO = C9_PRODUTO "
	cQuery += " WHERE SC5.D_E_L_E_T_ = '' "
	cQuery += " AND C5_FILIAL = '"+xFilial("SC5")+"' "
	cQuery += " AND C6_BLOQUEI = '01' "
	cQuery += " AND C9_CARGA = '' "
	cQuery += " AND C9_NFISCAL = '' "
	cQuery += " AND C9_SERIENF = '' "

	If !Empty(cPedido)
		cQuery += " AND C6_NUM = '"+cPedido+"' " +CHR(13)+CHR(10)
	EndIf

	If !Empty(dEmissao)
		cQuery += " AND C5_EMISSAO = '"+DtoS(dEmissao)+"' " +CHR(13)+CHR(10)
	EndIf

	If !Empty(cCliente)
		cQuery += " AND C6_CLI = '"+cCliente+"' " +CHR(13)+CHR(10)
	EndIf

	If !Empty(dEntrega)
		cQuery += " AND C6_ENTREG = '"+DtoS(dEntrega)+"' " +CHR(13)+CHR(10)
	EndIf

	If !Empty(cProduto)
		cQuery += " AND C6_PRODUTO = '"+cProduto+"' " +CHR(13)+CHR(10)
	EndIf

	If !Empty(cCodVen)
		cQuery += " AND C5_VEND1 = '"+cCodVen+"' " +CHR(13)+CHR(10)
	EndIf

	cQuery += " ORDER BY C6_NUM, C6_ITEM "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TMP",.F.,.T.)

	DbSelectArea("TMP")
	DbGoTop()

	While !Eof()
		//-- Verifica se foi blqueado por condicao de pagamento (P), caso contrário (I)
		cTpBlq := If( u_RFATA11B( TMP->C5_CONDPAG ),"I", "P" )
		
		AAdd(aPedidos,{cTpBlq,TMP->C5_FILIAL,TMP->C6_NUM,TMP->C6_ITEM,TMP->C6_PRODUTO,TMP->C6_DESCRI,TMP->C6_UM,Transform(TMP->C6_QTDVEN,"@E 999,999,999.99"),Transform(TMP->C6_PRCVEN,"@E 999,999,999.99"),Transform(TMP->C6_VALOR,"@E 999,999,999.99"),TMP->C6_LOCAL,TMP->C6_TES})

		DbSelectArea("TMP")
		DbSkip()

	End

	DbSelectArea("TMP")
	DbCloseArea()

Return
