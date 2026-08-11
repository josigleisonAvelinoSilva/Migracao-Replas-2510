#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEDITPANEL.CH"

/*/{Protheus.doc} REPCPA01
Rotina de apontamento de perda, Retorno para Estoque e Sucata
@type function
@version 2.0 
@author Dener Lemos - DOTHINK
@since 10/01/2022
@param aDados, array, Array com os produtos que terao perdas apontadas
@return logical, Retorno logico
@obs Projeto Novo PCP (Retorno para Estoque e Sucata)
/*/
User Function REPCPA01(aDados)
    Local cPrograma    := "REPCPA01"
    Local nOperation   := MODEL_OPERATION_INSERT
    Local oDlg         := Nil
    Local bCloseOnOK   := {|| .T.}
    Local bOk          := {|| .T.}
    //Local nPercReducao := 20
    Local aButtons     := {}
    Local bCancel      := {|| .T.}
    Private cOP        
	Private cCodPai    
	Private cDescPai 	
    IF  IsInCallStack("U_XAPRETOR")
		cOP        := SD3->D3_OP
		cCodPai    := SD3->D3_COD
		cDescPai   := Posicione('SB1',1,xFilial('SB1')+SD3->D3_COD, 'B1_DESC')
	    aCols      := aHeader := {} 		
	Else
		cOP        := M->D3_OP
		cCodPai    := M->D3_COD
		cDescPai   := Posicione('SB1',1,xFilial('SB1')+M->D3_COD, 'B1_DESC')
	Endif
	Private aCodMPs	   := aClone(aDados)
	Private lREPCPA01  := .F.
	Private	nPosLote   := 0
	Private	nPosLotCtl := 0
	Private	nPosDValid := 0

	aButtons 	:= {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},;
                    {.F.,Nil},{.T.,"Confirmar"},{.T.,"Cancelar"},{.F.,Nil},;
                    {.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}

	FWExecView(cCodPai, cPrograma, nOperation, oDlg, bCloseOnOk, bOk, /*nPercReducao*/, aButtons, bCancel)

Return lREPCPA01


/*/{Protheus.doc} ModelDef
Definicao do Model
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 06/10/2021
@return object, Modelo de datos
/*/
Static Function ModelDef()
	Local oModel   := Nil
	Local oStruCab := FWFormStruct(1,"SBC", {|| .F.}) //-- Cabecalho, com a OP(Ordem de Producao) e a MP(Materia Prima)
	Local oStruDev := FWFormStruct(1,"SBC", {|| .F.}) //-- Devolucao para estoque
	Local oStruSuc := FWFormStruct(1,"SBC", {|| .F.}) //-- Sucata

	Local bPosTOk := {|oTOkModel| TudoOk(oTOkModel)}

	//-- Pre-validacao do cabecalho, devolucao e sucata
	//Local bPreVldCab := {|oFieldModel, cAction, cIDField, xValue| PreVldCab(oFieldModel, cAction, cIDField, xValue)}
	Local bLinePreDev := {|oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue| DevLinePreGrid(oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue, oModel )}
	Local bLinePreSuc := {|oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue| SucLinePreGrid(oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue, oModel )}

	//-- Pos-validacao do cabecalho, devolucao e sucata
	//Local bPosVldCab := {|oFieldModel| PosVldCab(oFieldModel)}
	Local bLinePostDev := {|oGridModel, nLine| DevLinePostGrid(oGridModel, nLine)}
	Local bLinePostSuc := {|oGridModel, nLine| SucLinePostGrid(oGridModel, nLine)}

	Local bLoadActiv := {|oModel| LoadActiv(oModel)}

	AltStruMdl(@oStruCab, @oStruDev, @oStruSuc)

	//-- Criando o modelo e os relacionamentos
	oModel := MPFormModel():New("AREPCP01",/*bPre*/,bPosTOk,/*bCommit*/,/*bCancel*/)
	oModel:SetDescription("Apontamento da Perda")

	//-- Modelo do cabecalho, para exibir as informacoes principais como OP e MP
	oModel:AddFields("MASTERSTRU",,oStruCab,/*bPreVldCab*/,/*bPosVldCab*/,/*bLoad*/)
	oModel:GetModel("MASTERSTRU"):SetDescription("Cabeçalho OP/MP")
	oModel:GetModel("MASTERSTRU"):SetOnlyQuery(.T.)
	
	//-- Modelo da devolucao, para exibir as informacoes da devolucao de materiais
	oModel:AddGrid("DEVSTRU","MASTERSTRU",oStruDev,bLinePreDev,bLinePostDev,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:GetModel("DEVSTRU"):SetDescription("Devolução")
	oModel:GetModel("DEVSTRU"):SetOnlyQuery(.T.)
	//-- Definindo que usara a grid no formato antigo
    oModel:GetModel('DEVSTRU'):SetUseOldGrid(.T.)
	oModel:SetOptional("DEVSTRU", .T. )

	//-- Modelo da sucata, para exibir as informacoes da sucata de materiais
	oModel:AddGrid("SUCSTRU","MASTERSTRU",oStruSuc,bLinePreSuc,bLinePostSuc,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:GetModel("SUCSTRU"):SetDescription("Sucata")
	oModel:GetModel("SUCSTRU"):SetOnlyQuery(.T.)
	//-- Definindo que usara a grid no formato antigo
	oModel:GetModel('SUCSTRU'):SetUseOldGrid(.T.)
	oModel:SetOptional("SUCSTRU", .T. )

	oModel:SetActivate(bLoadActiv)
	oModel:SetPrimaryKey({})
	
Return oModel


/*/{Protheus.doc} ViewDef
Definicao da View
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 06/10/2021
@return object, oView
/*/
Static Function ViewDef()
	Local oView		:= Nil
	Local oModel	:= ModelDef()
	Local oStruCab	:= FWFormStruct(2,"SBC", {|| .F.}) //-- Cabecalho, com a OP(Ordem de Producao) e a MP(Materia Prima)
	Local oStruDev	:= FWFormStruct(2,"SBC", {|| .F.}) //-- Devolucao para estoque
	Local oStruSuc	:= FWFormStruct(2,"SBC", {|| .F.}) //-- Sucata

	AltStruView(@oStruCab, @oStruDev, @oStruSuc)

	//-- Criando a View
	oView := FWFormView():New()
	oView:SetModel(oModel)

	//-- Adiciona o FIELDS para exibir as informacoes principais como OP e MP
	oView:AddField("VIEW_CAB", oStruCab, "MASTERSTRU")

	//-- Adiciona o GRID para exibir as informacoes da RETORNO de materiais
	oView:AddGrid( "VIEW_DEV", oStruDev, "DEVSTRU" )
	//-- Adiciona o GRID para exibir as informacoes da SUCATA de materiais
	oView:AddGrid( "VIEW_SUC", oStruSuc, "SUCSTRU" )

	//-- Setando o dimensionamento de tamanho da parte do cabecalho
	oView:CreateHorizontalBox( "CABECALHO", 35 )
	//-- Setando o dimensionamento de tamanho da parte de RETORNO E SUCATA
	oView:CreateHorizontalBox( "DETAIL" , 65 )

	oView:CreateFolder("IDFOLDER","DETAIL")
	//-- No dia 13/10/2021, Jose e Ricardo pediram para mudar o nome de: "Devolucao" para: "Retorno para Estoque"
	oView:AddSheet("IDFOLDER","IDSHEET01","&RETORNO PARA ESTOQUE")
	oView:AddSheet("IDFOLDER","IDSHEET02","&SUCATA")

	oView:CreateHorizontalBox( "DEVOLUCAO", 100,,,"IDFOLDER","IDSHEET01" )
	oView:CreateHorizontalBox( "SUCATA"   , 100,,,"IDFOLDER","IDSHEET02" )

	//-- Amarrando a view com o box
	oView:SetOwnerView("VIEW_CAB", "CABECALHO")
	oView:SetOwnerView("VIEW_DEV", "DEVOLUCAO")
	oView:SetOwnerView("VIEW_SUC", "SUCATA")

	//-- Eventos de ativacao da View
	oView:SetAfterViewActivate({|oView| afterView(oView)})

	/*oView:SetViewProperty("VIEW_CAB", "SETLAYOUT", {FF_LAYOUT_HORZ_DESCR_TOP, 1})
	oView:SetViewProperty("VIEW_DEV", "SETLAYOUT", {FF_LAYOUT_HORZ_DESCR_TOP, 1})
	oView:SetViewProperty("VIEW_SUC", "SETLAYOUT", {FF_LAYOUT_HORZ_DESCR_TOP, 1})*/

	//-- Altera a descricao do objeto da View na tela 
	oView:oModel:cDescription := "Retorno para Estoque/Sucata"

	//oView:AddUserButton("&Calculo Auto.", "", {|| AutoCalc(oModel)}, , , , .T.)
	oView:AddUserButton("&Param. Etiqueta", "", {|| ParEtiq(oModel)}, , , , .T.)

Return oView


/*/{Protheus.doc} AltStruMdl
Funcao que carrega os campos da especificos da Estrutura do Modelo de dados
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 10/01/2022
@param oStruCab, object, Sub-modelo do Cabecalho
@param oStruDev, object, Sub-modelo do retorno para estoque
@param oStruSuc, object, Sub-modelo da Sucata
/*/
Static Function AltStruMdl(oStruCab, oStruDev, oStruSuc)
	Local aArea    := GetArea()
	Local aAreaSX3 := SX3->(GetArea())
    Local aCpoCab  := {"BC_TIPO", "BC_MOTIVO", "BC_DESCRI"}
    Local aCpoDet  := {"BC_LOCORIG", "BC_LOTECTL", "BC_NUMLOTE", "BC_DTVALID", "BC_QUANT", "BC_CODDEST", "BC_LOCAL"}
	Local aGatilho := {}
	Local nI	   := 0
	Local bValid   := {|| }
	Local bWhen    := {|| }
	Local bRelac   := {|| }

	//########################################################################
	//-- CABECALHO | OP/MP
	//########################################################################

	oStruCab:AddField( "Ord. Producao"    ,; //-- [01] Titulo do campo
					   "Ordem de Producao",; //-- [02] ToolTip do campo
					   "XX_OP"            ,; //-- [03] Id do Field
					   "C"                ,; //-- [04] Tipo do campo
					   14                 ,; //-- [05] Tamanho do campo
					   0                  ,; //-- [06] Decimal do campo
					   Nil                ,; //-- [07] Code-block de validacao do campo
					   {|| .T.}           ,; //-- [08] Code-block de validacao When do campo
					   Nil                ,; //-- [09] Lista de valores permitido do campo
					   .F.                ,; //-- [10] Indica se o campo tem preenchimento obrigatório
					   Nil                ,; //-- [11] Code-block de inicializacao do campo
					   Nil                ,; //-- [12] Indica se trata-se de um campo chave
					   Nil            	  ,; //-- [13] Indica se o campo pode receber valor em uma operacao de update.
					   .F.             	   ) //-- [14] Indica se o campo e virtual
				
	oStruCab:AddField( "Produto Acabado"     ,; //-- [01] Titulo do campo
					   "Cod. Produto Acabado",; //-- [02] ToolTip do campo
					   "XX_CODPAI"        	 ,; //-- [03] Id do Field
					   "C"                	 ,; //-- [04] Tipo do campo
					   20                 	 ,; //-- [05] Tamanho do campo /*Tamanho do Campo alterado de 15 para 20, de acordo com ambiente da Replas*/
					   0                  	 ,; //-- [06] Decimal do campo
					   Nil                	 ,; //-- [07] Code-block de validacao do campo
					   {|| .T.}           	 ,; //-- [08] Code-block de validacao When do campo
					   Nil                	 ,; //-- [09] Lista de valores permitido do campo
					   .F.                	 ,; //-- [10] Indica se o campo tem preenchimento obrigatório
					   Nil                	 ,; //-- [11] Code-block de inicializacao do campo
					   Nil                	 ,; //-- [12] Indica se trata-se de um campo chave
					   Nil                	 ,; //-- [13] Indica se o campo pode receber valor em uma operacao de update.
					   .F.                 	  ) //-- [14] Indica se o campo e virtual

	oStruCab:AddField( "Descr. Produto Acabado",; //-- [01] Titulo do campo
					   "Descricao PA"          ,; //-- [02] ToolTip do campo
					   "XX_DESCPAI"       	   ,; //-- [03] Id do Field
					   "C"                	   ,; //-- [04] Tipo do campo
					   30                 	   ,; //-- [05] Tamanho do campo
					   0                  	   ,; //-- [06] Decimal do campo
					   Nil                	   ,; //-- [07] Code-block de validacao do campo
					   {|| .T.}           	   ,; //-- [08] Code-block de validacao When do campo
					   Nil                	   ,; //-- [09] Lista de valores permitido do campo
					   .F.                	   ,; //-- [10] Indica se o campo tem preenchimento obrigatório
					   Nil                	   ,; //-- [11] Code-block de inicializacao do campo
					   Nil                	   ,; //-- [12] Indica se trata-se de um campo chave
					   Nil                	   ,; //-- [13] Indica se o campo pode receber valor em uma operacao de update.
					   .F.                 	    ) //-- [14] Indica se o campo e virtual

	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	For nI := 1 To Len(aCpoCab)
		If SX3->(DbSeek(aCpoCab[nI]))

			bValid := IIf(aCpoCab[nI] $ "BC_LOCALIZ|BC_NUMSERI", Nil, FwBuildFeature( 1, SX3->X3_VALID ))	
			bWhen  := FwBuildFeature( 2, SX3->X3_WHEN )
			bRelac := FwBuildFeature( 3, SX3->X3_RELACAO )

			oStruCab:AddField( AllTrim( X3Titulo() )         	    ,; //-- [01] Titulo do campo
							   AllTrim( X3Descric() )         	    ,; //-- [02] ToolTip do campo
							   AllTrim( SX3->X3_CAMPO )       	    ,; //-- [03] Id do Field
							   SX3->X3_TIPO                         ,; //-- [04] Tipo do campo
							   SX3->X3_TAMANHO                      ,; //-- [05] Tamanho do campo
							   SX3->X3_DECIMAL                      ,; //-- [06] Decimal do campo
							   bValid              			        ,; //-- [07] Code-block de validacao do campo
							   bWhen                                ,; //-- [08] Code-block de validacao When do campo
							   StrTokArr( AllTrim( X3CBox() ), ';' ),; //-- [09] Lista de valores permitido do campo
							   X3Obrigat( SX3->X3_CAMPO )     	    ,; //-- [10] Indica se o campo tem preenchimento obrigatório
							   bRelac                               ,; //-- [11] Code-block de inicializacao do campo
							   Nil                                  ,; //-- [12] Indica se trata-se de um campo chave
							   Nil                                  ,; //-- [13] Indica se o campo pode receber valor em uma operacao de update.
							   SX3->X3_CONTEXT == "V"     	         ) //-- [14] Indica se o campo e virtual
		EndIf
	Next nI
	
	//-- Adiciona gatilho no modelo do cabecalho
	aGatilho := FwStruTrigger( "BC_MOTIVO"                                        ,; //-- Campo dominio
							   "BC_DESCRI"                                        ,; //-- Campo de contradominio 
							   "IF(EMPTY(ALLTRIM(M->BC_MOTIVO)),'',CYO->CYO_DSRF)",; //-- Regra de preenchimento  
							   .T.                                                ,; //-- Se posicionara ou nao antes da execucao do gatilhos
							   "CYO"                                              ,; //-- Alias da tabela a ser posicionada
							   1                                                  ,; //-- Ordem da tabela a ser posicionada
							   "xFilial('CYO')+M->BC_MOTIVO"                      ,; //-- Chave de busca da tabela a ser posicionada
							   ""                                                  ) //-- Condicao para execucao do gatilho
	oStruCab:AddTrigger(aGatilho[1], aGatilho[2], aGatilho[3], aGatilho[4])
	
	//########################################################################
	//-- DEVOLUCAO - RETORNO PARA ESTOQUE
	//########################################################################

	oStruDev:AddField( "Materia Prima Orig"                  ,; //-- [01] Titulo do campo
					   "Materia Prima Orig"                  ,; //-- [02] ToolTip do campo
					   "XX_PRODUTO"                          ,; //-- [03] Id do Field
					   "C"                                   ,; //-- [04] Tipo do campo
					   20                                    ,; //-- [05] Tamanho do campo //-- Tamanho do Campo alterado de 15 para 20, de acordo com ambiente da Replas
					   0                                     ,; //-- [06] Decimal do campo
					   FwBuildFeature( 1, "ExistCpo('SB1')" ),; //-- [07] Code-block de validacao do campo
					   {|| .T.}                              ,; //-- [08] Code-block de validacao When do campo
					   Nil                                   ,; //-- [09] Lista de valores permitido do campo
					   .F.                                   ,; //-- [10] Indica se o campo tem preenchimento obrigatório
					   Nil                                   ,; //-- [11] Code-block de inicializacao do campo
					   Nil                                   ,; //-- [12] Indica se trata-se de um campo chave
					   Nil                                   ,; //-- [13] Indica se o campo pode receber valor em uma operacao de update.
					   .F.                                    ) //-- [14] Indica se o campo e virtual

	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	For nI := 1 To 5
		If SX3->(DbSeek(aCpoDet[nI]))

			bValid := IIf(aCpoDet[nI] $ "BC_QUANT|BC_LOTECTL|BC_NUMLOTE", Nil, FwBuildFeature( 1, SX3->X3_VALID ))
			bWhen  := FwBuildFeature( 2, SX3->X3_WHEN )
			bRelac := FwBuildFeature( 3, SX3->X3_RELACAO )

			oStruDev:AddField( AllTrim( X3Titulo() )         	    ,; //-- [01] Titulo do campo
							   AllTrim( X3Descric() )         	    ,; //-- [02] ToolTip do campo
							   AllTrim( SX3->X3_CAMPO )       	    ,; //-- [03] Id do Field
							   SX3->X3_TIPO                         ,; //-- [04] Tipo do campo
							   SX3->X3_TAMANHO                      ,; //-- [05] Tamanho do campo
							   SX3->X3_DECIMAL                      ,; //-- [06] Decimal do campo
							   bValid              			        ,; //-- [07] Code-block de validacao do campo
							   bWhen                                ,; //-- [08] Code-block de validacao When do campo
							   StrTokArr( AllTrim( X3CBox() ), ';' ),; //-- [09] Lista de valores permitido do campo
							   X3Obrigat( SX3->X3_CAMPO )     	    ,; //-- [10] Indica se o campo tem preenchimento obrigatório
							   bRelac                               ,; //-- [11] Code-block de inicializacao do campo
							   Nil                                  ,; //-- [12] Indica se trata-se de um campo chave
							   Nil                                  ,; //-- [13] Indica se o campo pode receber valor em uma operacao de update.
							   SX3->X3_CONTEXT == 'V'    	         ) //-- [14] Indica se o campo e virtual
		EndIf
	Next nI

	oStruDev:AddField( 'Peso Bruto'          ,; //-- [01] Titulo do campo
					   'Peso Bruto'          ,; //-- [02] ToolTip do campo
					   "XX_PESOBRT"          ,; //-- [03] Id do Field
					   "N"                   ,; //-- [04] Tipo do campo
					   18                    ,; //-- [05] Tamanho do campo
					   7                     ,; //-- [06] Decimal do campo
					   Nil                   ,; //-- [07] Code-block de validacao do campo
					   Nil                   ,; //-- [08] Code-block de validacao When do campo
					   Nil                   ,; //-- [09] Lista de valores permitido do campo
					   .F.                   ,; //-- [10] Indica se o campo tem preenchimento obrigatório
					   Nil                   ,; //-- [11] Code-block de inicializacao do campo
					   Nil                   ,; //-- [12] Indica se trata-se de um campo chave
					   Nil                   ,; //-- [13] Indica se o campo pode receber valor em uma operacao de update.
					   .F.                    ) //-- [14] Indica se o campo e virtual

	oStruDev:AddField( 'Ø Interno (")'       ,; //-- [01] Titulo do campo
					   'Diametro Interno (")',; //-- [02] ToolTip do campo
					   "XX_DIAMINT"          ,; //-- [03] Id do Field
					   "N"                   ,; //-- [04] Tipo do campo
					   2                     ,; //-- [05] Tamanho do campo
					   0                     ,; //-- [06] Decimal do campo
					   Nil                   ,; //-- [07] Code-block de validacao do campo
					   Nil                   ,; //-- [08] Code-block de validacao When do campo
					   Nil                   ,; //-- [09] Lista de valores permitido do campo
					   .F.                   ,; //-- [10] Indica se o campo tem preenchimento obrigatório
					   Nil                   ,; //-- [11] Code-block de inicializacao do campo
					   Nil                   ,; //-- [12] Indica se trata-se de um campo chave
					   Nil                   ,; //-- [13] Indica se o campo pode receber valor em uma operacao de update.
					   .F.                    ) //-- [14] Indica se o campo e virtual

	oStruDev:AddField( "Ø Externo (mm)"       ,; //-- [01] Titulo do campo
					   "Diametro Externo (mm)",; //-- [02] ToolTip do campo
					   "XX_DIAMEXT"           ,; //-- [03] Id do Field
					   "N"                    ,; //-- [04] Tipo do campo
					   3                      ,; //-- [05] Tamanho do campo
					   0                      ,; //-- [06] Decimal do campo
					   Nil                    ,; //-- [07] Code-block de validacao do campo
					   Nil                    ,; //-- [08] Code-block de validacao When do campo
					   Nil                    ,; //-- [09] Lista de valores permitido do campo
					   .F.                    ,; //-- [10] Indica se o campo tem preenchimento obrigatório
					   Nil                    ,; //-- [11] Code-block de inicializacao do campo
					   Nil                    ,; //-- [12] Indica se trata-se de um campo chave
					   Nil                    ,; //-- [13] Indica se o campo pode receber valor em uma operacao de update.
					   .F.                     ) //-- [14] Indica se o campo e virtual

	oStruDev:AddField( "Largura (mm)",; //-- [01] Titulo do campo
					   "Largura (mm)",; //-- [02] ToolTip do campo
					   "XX_LARG"     ,; //-- [03] Id do Field
					   "N"           ,; //-- [04] Tipo do campo
					   4             ,; //-- [05] Tamanho do campo
					   0             ,; //-- [06] Decimal do campo
					   Nil           ,; //-- [07] Code-block de validacao do campo
					   Nil           ,; //-- [08] Code-block de validacao When do campo
					   Nil           ,; //-- [09] Lista de valores permitido do campo
					   .F.           ,; //-- [10] Indica se o campo tem preenchimento obrigatório
					   Nil           ,; //-- [11] Code-block de inicializacao do campo
					   Nil           ,; //-- [12] Indica se trata-se de um campo chave
					   Nil           ,; //-- [13] Indica se o campo pode receber valor em uma operacao de update.
					   .F.            ) //-- [14] Indica se o campo e virtual

	oStruDev:AddField( "Produto Novo?",; //-- [01] Titulo do campo
					   "Produto Novo?",; //-- [02] ToolTip do campo
					   "XX_NPROD"     ,; //-- [03] Id do Field
					   "C"            ,; //-- [04] Tipo do campo
					   5              ,; //-- [05] Tamanho do campo
					   0              ,; //-- [06] Decimal do campo
					   Nil            ,; //-- [07] Code-block de validacao do campo
					   {|| .T.}       ,; //-- [08] Code-block de validacao When do campo
					   Nil            ,; //-- [09] Lista de valores permitido do campo
					   .F.            ,; //-- [10] Indica se o campo tem preenchimento obrigatório
					   Nil            ,; //-- [11] Code-block de inicializacao do campo
					   Nil            ,; //-- [12] Indica se trata-se de um campo chave
					   Nil            ,; //-- [13] Indica se o campo pode receber valor em uma operacao de update.
					   .F.             ) //-- [14] Indica se o campo e virtual

	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	For nI := 6 To 7
		If SX3->(DbSeek(aCpoDet[nI]))

			bValid := IIf(aCpoDet[nI] $ "BC_CODDEST|BC_LOCDEST|BC_NSEDEST", Nil, FwBuildFeature( 1, SX3->X3_VALID ))
			bWhen  := FwBuildFeature( 2, SX3->X3_WHEN )
			bRelac := FwBuildFeature( 3, SX3->X3_RELACAO )

			oStruDev:AddField( AllTrim( X3Titulo() )         	    ,; //-- [01] Titulo do campo
							   AllTrim( X3Descric() )         	    ,; //-- [02] ToolTip do campo
							   AllTrim( SX3->X3_CAMPO )       	    ,; //-- [03] Id do Field
							   SX3->X3_TIPO                         ,; //-- [04] Tipo do campo
							   SX3->X3_TAMANHO                      ,; //-- [05] Tamanho do campo
							   SX3->X3_DECIMAL                      ,; //-- [06] Decimal do campo
							   bValid              			        ,; //-- [07] Code-block de validacao do campo
							   bWhen                                ,; //-- [08] Code-block de validacao When do campo
							   StrTokArr( AllTrim( X3CBox() ), ';' ),; //-- [09] Lista de valores permitido do campo
							   X3Obrigat( SX3->X3_CAMPO )     	    ,; //-- [10] Indica se o campo tem preenchimento obrigatório
							   bRelac                               ,; //-- [11] Code-block de inicializacao do campo
							   Nil                                  ,; //-- [12] Indica se trata-se de um campo chave
							   Nil                                  ,; //-- [13] Indica se o campo pode receber valor em uma operacao de update.
							   SX3->X3_CONTEXT == 'V'     	         ) //-- [14] Indica se o campo e virtual
		EndIf
	Next nI
	
	//########################################################################
	//-- SUCATA
	//########################################################################

	oStruSuc:AddField( "Materia Prima Orig"                  ,; //-- [01] Titulo do campo
					   "Materia Prima Orig"                  ,; //-- [02] ToolTip do campo
					   "XX_PRODUTO"                          ,; //-- [03] Id do Field
					   "C"                                   ,; //-- [04] Tipo do campo
					   20                                    ,; //-- [05] Tamanho do campo //-- Tamanho do Campo alterado de 15 para 20, de acordo com ambiente da Replas
					   0                                     ,; //-- [06] Decimal do campo
					   FwBuildFeature( 1, "ExistCpo('SB1')" ),; //-- [07] Code-block de validacao do campo
					   {|| .T.}                              ,; //-- [08] Code-block de validacao When do campo
					   Nil                                   ,; //-- [09] Lista de valores permitido do campo
					   .F.                                   ,; //-- [10] Indica se o campo tem preenchimento obrigatório
					   Nil                                   ,; //-- [11] Code-block de inicializacao do campo
					   Nil                                   ,; //-- [12] Indica se trata-se de um campo chave
					   Nil                                   ,; //-- [13] Indica se o campo pode receber valor em uma operacao de update.
					   .F.                                    ) //-- [14] Indica se o campo e virtual

	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	For nI := 1 To 5
		If SX3->(DbSeek(aCpoDet[nI]))

			bValid := IIf(aCpoDet[nI] $ "BC_QUANT|BC_LOTECTL|BC_NUMLOTE", Nil, FwBuildFeature( 1, SX3->X3_VALID ))
			bWhen  := FwBuildFeature( 2, SX3->X3_WHEN )
			bRelac := FwBuildFeature( 3, SX3->X3_RELACAO )

			oStruSuc:AddField( AllTrim( X3Titulo() )         	    ,; //-- [01] Titulo do campo
							   AllTrim( X3Descric() )         	    ,; //-- [02] ToolTip do campo
							   AllTrim( SX3->X3_CAMPO )       	    ,; //-- [03] Id do Field
							   SX3->X3_TIPO                         ,; //-- [04] Tipo do campo
							   SX3->X3_TAMANHO                      ,; //-- [05] Tamanho do campo
							   SX3->X3_DECIMAL                      ,; //-- [06] Decimal do campo
							   bValid              			        ,; //-- [07] Code-block de validacao do campo
							   bWhen                                ,; //-- [08] Code-block de validacao When do campo
							   StrTokArr( AllTrim( X3CBox() ), ';' ),; //-- [09] Lista de valores permitido do campo
							   X3Obrigat( SX3->X3_CAMPO )     	    ,; //-- [10] Indica se o campo tem preenchimento obrigatório
							   bRelac                               ,; //-- [11] Code-block de inicializacao do campo
							   Nil                                  ,; //-- [12] Indica se trata-se de um campo chave
							   Nil                                  ,; //-- [13] Indica se o campo pode receber valor em uma operacao de update.
							   SX3->X3_CONTEXT == 'V'     	         ) //-- [14] Indica se o campo e virtual
		EndIf
	Next nI
    /*
	oStruSuc:AddField( 'Ø Interno (")'       ,; //-- [01] Titulo do campo
					   'Diametro Interno (")',; //-- [02] ToolTip do campo
					   "XX_DIAMINT"          ,; //-- [03] Id do Field
					   "N"                   ,; //-- [04] Tipo do campo
					   2                     ,; //-- [05] Tamanho do campo
					   0                     ,; //-- [06] Decimal do campo
					   Nil                   ,; //-- [07] Code-block de validacao do campo
					   Nil                   ,; //-- [08] Code-block de validacao When do campo
					   Nil                   ,; //-- [09] Lista de valores permitido do campo
					   .F.                   ,; //-- [10] Indica se o campo tem preenchimento obrigatório
					   Nil                   ,; //-- [11] Code-block de inicializacao do campo
					   Nil                   ,; //-- [12] Indica se trata-se de um campo chave
					   Nil                   ,; //-- [13] Indica se o campo pode receber valor em uma operacao de update.
					   .F.                    ) //-- [14] Indica se o campo e virtual

	oStruSuc:AddField( "Ø Externo (mm)"       ,; //-- [01] Titulo do campo
					   "Diametro Externo (mm)",; //-- [02] ToolTip do campo
					   "XX_DIAMEXT"           ,; //-- [03] Id do Field
					   "N"                    ,; //-- [04] Tipo do campo
					   3                      ,; //-- [05] Tamanho do campo
					   0                      ,; //-- [06] Decimal do campo
					   Nil                    ,; //-- [07] Code-block de validacao do campo
					   Nil                    ,; //-- [08] Code-block de validacao When do campo
					   Nil                    ,; //-- [09] Lista de valores permitido do campo
					   .F.                    ,; //-- [10] Indica se o campo tem preenchimento obrigatório
					   Nil                    ,; //-- [11] Code-block de inicializacao do campo
					   Nil                    ,; //-- [12] Indica se trata-se de um campo chave
					   Nil                    ,; //-- [13] Indica se o campo pode receber valor em uma operacao de update.
					   .F.                     ) //-- [14] Indica se o campo e virtual

	oStruSuc:AddField( "Largura (mm)",; //-- [01] Titulo do campo
					   "Largura (mm)",; //-- [02] ToolTip do campo
					   "XX_LARG"     ,; //-- [03] Id do Field
					   "N"           ,; //-- [04] Tipo do campo
					   4             ,; //-- [05] Tamanho do campo
					   0             ,; //-- [06] Decimal do campo
					   Nil           ,; //-- [07] Code-block de validacao do campo
					   Nil           ,; //-- [08] Code-block de validacao When do campo
				  	   Nil           ,; //-- [09] Lista de valores permitido do campo
					   .F.           ,; //-- [10] Indica se o campo tem preenchimento obrigatório
					   Nil           ,; //-- [11] Code-block de inicializacao do campo
					   Nil           ,; //-- [12] Indica se trata-se de um campo chave
					   Nil           ,; //-- [13] Indica se o campo pode receber valor em uma operacao de update.
					   .F.            ) //-- [14] Indica se o campo e virtual
    			
	oStruSuc:AddField( "Produto Novo?",; //-- [01] Titulo do campo
					   "Produto Novo?",; //-- [02] ToolTip do campo
					   "XX_NPROD"     ,; //-- [03] Id do Field
					   "C"            ,; //-- [04] Tipo do campo
					   5              ,; //-- [05] Tamanho do campo
					   0              ,; //-- [06] Decimal do campo
					   Nil            ,; //-- [07] Code-block de validacao do campo
					   Nil            ,; //-- [08] Code-block de validacao When do campo
				  	   Nil            ,; //-- [09] Lista de valores permitido do campo
					   .F.            ,; //-- [10] Indica se o campo tem preenchimento obrigatório
					   Nil            ,; //-- [11] Code-block de inicializacao do campo
					   Nil            ,; //-- [12] Indica se trata-se de um campo chave
					   Nil            ,; //-- [13] Indica se o campo pode receber valor em uma operacao de update.
					   .F.             ) //-- [14] Indica se o campo e virtual
    */
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	For nI := 6 To 7
		If SX3->(DbSeek(aCpoDet[nI]))

			bValid := IIf(aCpoDet[nI] $ "BC_CODDEST|BC_LOCDEST", Nil, FwBuildFeature( 1, SX3->X3_VALID ))
			bWhen  := FwBuildFeature( 2, SX3->X3_WHEN )
			bRelac := FwBuildFeature( 3, SX3->X3_RELACAO )

			//If Alltrim( aCpoDet[nI] ) == "BC_CODDEST"
			//   bValid := FwBuildFeature( 1, "ExistCpo('SB1')" )
			//Endif


			oStruSuc:AddField( AllTrim( X3Titulo() )         	    ,; //-- [01] Titulo do campo
							   AllTrim( X3Descric() )         	    ,; //-- [02] ToolTip do campo
							   AllTrim( SX3->X3_CAMPO )       	    ,; //-- [03] Id do Field
							   SX3->X3_TIPO                         ,; //-- [04] Tipo do campo
							   SX3->X3_TAMANHO                      ,; //-- [05] Tamanho do campo
							   SX3->X3_DECIMAL                      ,; //-- [06] Decimal do campo
							   bValid              			        ,; //-- [07] Code-block de validacao do campo
							   bWhen                                ,; //-- [08] Code-block de validacao When do campo
							   StrTokArr( AllTrim( X3CBox() ), ';' ),; //-- [09] Lista de valores permitido do campo
							   X3Obrigat( SX3->X3_CAMPO )     	    ,; //-- [10] Indica se o campo tem preenchimento obrigatório
							   bRelac                               ,; //-- [11] Code-block de inicializacao do campo
							   Nil                                  ,; //-- [12] Indica se trata-se de um campo chave
							   Nil                                  ,; //-- [13] Indica se o campo pode receber valor em uma operacao de update.
							   SX3->X3_CONTEXT == 'V'     	         ) //-- [14] Indica se o campo e virtual
		EndIf
	Next nI

	oStruCab:SetProperty("BC_TIPO", MODEL_FIELD_OBRIGAT, .T.)
	oStruCab:SetProperty("BC_MOTIVO", MODEL_FIELD_OBRIGAT, .T.)

	oStruSuc:SetProperty("BC_CODDEST", MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID,"ExistCpo('SB1') .AND.  'SUC' $ FwFldGet('BC_CODDEST')  " ) )
 	//oStruSuc:SetProperty('BC_LOTECTL', MODEL_FIELD_VALUES , TamSx3("BC_LOTECTL")[01]  )
	//oStruSuc:SetProperty('BC_NUMLOTE', MODEL_FIELD_VALUES , TamSx3("BC_NUMLOTE")[01] )

	RestArea(aAreaSX3)
	RestArea(aArea)

Return


/*/{Protheus.doc} AltStruView
Funcao que carrega os campos da especificos da Estrutura da View
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 10/01/2022
@param oStruCab, object, Sub-modelo do Cabecalho
@param oStruDev, object, Sub-modelo do retorno para estoque
@param oStruSuc, object, Sub-modelo da Sucata
/*/
Static Function AltStruView(oStruCab, oStruDev, oStruSuc)
	Local aArea     := GetArea()
	Local aAreaSX3  := SX3->(GetArea())
    Local aCpoCab   := {"BC_TIPO", "BC_MOTIVO", "BC_DESCRI"}
    Local aCpoDet   := {"BC_LOCORIG", "BC_LOTECTL", "BC_NUMLOTE", "BC_DTVALID", "BC_QUANT", "BC_CODDEST", "BC_LOCAL"}
	Local aCombo    := {}
	Local aAux      := {}
    Local cGSC      := ""
	Local nOrdem	:= 0
	Local nInitCBox := 0
	Local nMaxLenCb := 0
	Local nI,nX		:= 0
	Local lEdit     := .T.

	//########################################################################
	//-- CABECALHO | OP/MP
	//########################################################################
	
	oStruCab:AddField( "XX_OP"            	 ,; //-- [01] Campo
					   StrZero( nOrdem++, 2 ),; //-- [02] Ordem 
					   "Ord. Producao"    	 ,; //-- [03] Titulo
					   "Ordem de Producao"	 ,; //-- [04] Descricao
					   Nil                	 ,; //-- [05] Help
					   "GET"              	 ,; //-- [06] Tipo do campo (COMBO","GET","CHECK")
					   "@9"               	 ,; //-- [07] Picture
					   Nil                	 ,; //-- [08] PictVar
					   "SC2"              	 ,; //-- [09] F3
					   .F.    	 	     	 ,; //-- [10] Editavel
					   ""                 	 ,; //-- [11] Folder
					   ""                 	 ,; //-- [12] Group
					   Nil                	 ,; //-- [13] Lista Combo
					   Nil                	 ,; //-- [14] Tam Max Combo
					   ""                 	 ,; //-- [15] Inic. Browse
					   .F.     	          	  ) //-- [16] Virtual
	
	oStruCab:AddField( "XX_CODPAI"        	 ,; //-- [01] Campo
					   StrZero( nOrdem++, 2 ),; //-- [02] Ordem 
					   "Produto Acabado"     ,; //-- [03] Titulo
					   "Cod. Produto Acabado",; //-- [04] Descricao
					   Nil                	 ,; //-- [05] Help
					   "GET"              	 ,; //-- [06] Tipo do campo (COMBO","GET","CHECK")
					   "@!"               	 ,; //-- [07] Picture
					   Nil                	 ,; //-- [08] PictVar
					   "SB1"              	 ,; //-- [09] F3
					   .F.   	 	     	 ,; //-- [10] Editavel
					   ""                 	 ,; //-- [11] Folder
					   ""                 	 ,; //-- [12] Group
					   Nil                	 ,; //-- [13] Lista Combo
					   Nil                	 ,; //-- [14] Tam Max Combo
					   ""                 	 ,; //-- [15] Inic. Browse
					   .F.     	          	  ) //-- [16] Virtual

	oStruCab:AddField( "XX_DESCPAI"       	   ,; //-- [01] Campo
					   StrZero( nOrdem++, 2 )  ,; //-- [02] Ordem 
					   "Descr. Produto Acabado",; //-- [03] Titulo
					   "Descricao PA" 	       ,; //-- [04] Descricao
					   Nil                	   ,; //-- [05] Help
					   "GET"              	   ,; //-- [06] Tipo do campo (COMBO","GET","CHECK")
					   "@!"               	   ,; //-- [07] Picture
					   Nil                	   ,; //-- [08] PictVar
					   ""                 	   ,; //-- [09] F3
					   .F.   	 	     	   ,; //-- [10] Editavel
					   ""                 	   ,; //-- [11] Folder
					   ""                 	   ,; //-- [12] Group
					   Nil                	   ,; //-- [13] Lista Combo
					   Nil                	   ,; //-- [14] Tam Max Combo
					   ""                 	   ,; //-- [15] Inic. Browse
					   .F.     	          	    ) //-- [16] Virtual

	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	For nI := 1 To Len(aCpoCab)
		If SX3->(DbSeek(aCpoCab[nI]))

			aCombo := {}

			If !Empty(X3Cbox())
				nInitCBox := 0
				nMaxLenCb := 0
				aAux      := RetSX3Box(X3Cbox(), @nInitCBox, @nMaxLenCb, SX3->X3_TAMANHO)

				For nX := 1 To Len(aAux)
					aAdd(aCombo, aAux[nX][1])
				Next nX
			EndIf

			bPictVar := FwBuildFeature(4, SX3->X3_PICTVAR)		
			cGSC     := IIf(Empty(X3Cbox()), IIf(SX3->X3_TIPO == 'L', 'CHECK', 'GET'), 'COMBO')		

			oStruCab:AddField( AllTrim( SX3->X3_CAMPO ),; //-- [01] Campo
							   StrZero( nOrdem++, 2 )  ,; //-- [02] Ordem
							   AllTrim( X3Titulo() )   ,; //-- [03] Titulo
							   AllTrim( X3Descric() )  ,; //-- [04] Descricao
							   Nil                     ,; //-- [05] Help
							   cGSC                    ,; //-- [06] Tipo do campo   COMBO, Get ou CHECK
							   SX3->X3_PICTURE         ,; //-- [07] Picture
							   bPictVar                ,; //-- [08] PictVar
							   SX3->X3_F3              ,; //-- [09] F3
							   SX3->X3_VISUAL <> 'V'   ,; //-- [10] Editavel
							   SX3->X3_FOLDER          ,; //-- [11] Folder
							   SX3->X3_FOLDER          ,; //-- [12] Group
							   aCombo                  ,; //-- [13] Lista Combo
							   nMaxLenCb               ,; //-- [14] Tam Max Combo
							   SX3->X3_INIBRW          ,; //-- [15] Inic. Browse
							   SX3->X3_CONTEXT == 'V'   ) //-- [16] Virtual	
		EndIf
	Next nI

	//########################################################################
	//-- DEVOLUCAO - RETORNO PARA ESTOQUE
	//########################################################################

	oStruDev:AddField( "XX_PRODUTO"          ,; //-- [01] Campo
					   StrZero( nOrdem++, 2 ),; //-- [02] Ordem 
					   "Materia Prima Orig"  ,; //-- [03] Titulo
					   "Materia Prima Orig"  ,; //-- [04] Descricao
					   Nil                   ,; //-- [05] Help
					   "GET"                 ,; //-- [06] Tipo do campo (COMBO","GET","CHECK")
					   "@!"                  ,; //-- [07] Picture
					   Nil                   ,; //-- [08] PictVar
					   "SB1"                 ,; //-- [09] F3
					   .T.   	 	         ,; //-- [10] Editavel
					   ""                    ,; //-- [11] Folder
					   ""                    ,; //-- [12] Group
					   Nil                   ,; //-- [13] Lista Combo
					   Nil                   ,; //-- [14] Tam Max Combo
					   "0"                   ,; //-- [15] Inic. Browse
					   .F.     	              ) //-- [16] Virtual

	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	For nI := 1 To 5
		If SX3->(DbSeek(aCpoDet[nI]))

			aCombo := {}

			If !Empty(X3Cbox())
				nInitCBox := 0
				nMaxLenCb := 0
				aAux      := RetSX3Box(X3Cbox(), @nInitCBox, @nMaxLenCb, SX3->X3_TAMANHO)

				For nX := 1 To Len(aAux)
					aAdd(aCombo, aAux[nX][1])
				Next nX
			EndIf

			bPictVar := FwBuildFeature(4, SX3->X3_PICTVAR)		
			cGSC     := IIf(Empty(X3Cbox()), IIf(SX3->X3_TIPO == 'L', 'CHECK', 'GET'), 'COMBO')		

			oStruDev:AddField( AllTrim( SX3->X3_CAMPO ),; //-- [01] Campo
							   StrZero( nOrdem++, 2 )  ,; //-- [02] Ordem
							   AllTrim( X3Titulo() )   ,; //-- [03] Titulo
							   AllTrim( X3Descric() )  ,; //-- [04] Descricao
							   Nil                     ,; //-- [05] Help
							   cGSC                    ,; //-- [06] Tipo do campo   COMBO, Get ou CHECK
							   SX3->X3_PICTURE         ,; //-- [07] Picture
							   bPictVar                ,; //-- [08] PictVar
							   SX3->X3_F3              ,; //-- [09] F3
							   SX3->X3_VISUAL <> 'V'   ,; //-- [10] Editavel
							   SX3->X3_FOLDER          ,; //-- [11] Folder
							   SX3->X3_FOLDER          ,; //-- [12] Group
							   aCombo                  ,; //-- [13] Lista Combo
							   nMaxLenCb               ,; //-- [14] Tam Max Combo
							   SX3->X3_INIBRW          ,; //-- [15] Inic. Browse
							   SX3->X3_CONTEXT == 'V'   ) //-- [16] Virtual	
		EndIf
	Next nI

	oStruDev:AddField( "XX_PESOBRT"              ,; //-- [01] Campo
					   StrZero( nOrdem++, 2 )    ,; //-- [02] Ordem 
					   'Peso Bruto'              ,; //-- [03] Titulo
					   'Peso Bruto'              ,; //-- [04] Descricao
					   Nil                       ,; //-- [05] Help
					   "GET"                     ,; //-- [06] Tipo do campo (COMBO","GET","CHECK")
					   "@E 9,999,999,999.9999999",; //-- [07] Picture
					   Nil                       ,; //-- [08] PictVar
					   ""                        ,; //-- [09] F3
					   .T.   	 	             ,; //-- [10] Editavel
					   ""                        ,; //-- [11] Folder
					   ""                        ,; //-- [12] Group
					   Nil                       ,; //-- [13] Lista Combo
					   Nil                       ,; //-- [14] Tam Max Combo
					   "0"                       ,; //-- [15] Inic. Browse
					   .F.     	                  ) //-- [16] Virtual

	oStruDev:AddField( "XX_DIAMINT"          ,; //-- [01] Campo
					   StrZero( nOrdem++, 2 ),; //-- [02] Ordem 
					   'Ø Interno (")'       ,; //-- [03] Titulo
					   'Diametro Interno (")',; //-- [04] Descricao
					   Nil                   ,; //-- [05] Help
					   "GET"                 ,; //-- [06] Tipo do campo (COMBO","GET","CHECK")
					   "99"                  ,; //-- [07] Picture
					   Nil                   ,; //-- [08] PictVar
					   ""                    ,; //-- [09] F3
					   .T.   	 	         ,; //-- [10] Editavel
					   ""                    ,; //-- [11] Folder
					   ""                    ,; //-- [12] Group
					   Nil                   ,; //-- [13] Lista Combo
					   Nil                   ,; //-- [14] Tam Max Combo
					   "0"                   ,; //-- [15] Inic. Browse
					   .F.     	              ) //-- [16] Virtual

	oStruDev:AddField( "XX_DIAMEXT"           ,; //-- [01] Campo
					   StrZero( nOrdem++, 2 ) ,; //-- [02] Ordem 
					   "Ø Externo (mm)"       ,; //-- [03] Titulo
					   "Diametro Externo (mm)",; //-- [04] Descricao
					   Nil                    ,; //-- [05] Help
					   "GET"                  ,; //-- [06] Tipo do campo (COMBO","GET","CHECK")
					   "999"                  ,; //-- [07] Picture
					   Nil                    ,; //-- [08] PictVar
					   ""                     ,; //-- [09] F3
					   .T.   	 	          ,; //-- [10] Editavel
					   ""                     ,; //-- [11] Folder
					   ""                     ,; //-- [12] Group
					   Nil                    ,; //-- [13] Lista Combo
					   Nil                    ,; //-- [14] Tam Max Combo
					   "0"                    ,; //-- [15] Inic. Browse
					   .F.     	               ) //-- [16] Virtual

	oStruDev:AddField( "XX_LARG"             ,; //-- [01] Campo
					   StrZero( nOrdem++, 2 ),; //-- [02] Ordem 
					   "Largura (mm)"        ,; //-- [03] Titulo
					   "Largura (mm)"        ,; //-- [04] Descricao
					   Nil                   ,; //-- [05] Help
					   "GET"                 ,; //-- [06] Tipo do campo (COMBO","GET","CHECK")
					   "9999"                ,; //-- [07] Picture
					   Nil                   ,; //-- [08] PictVar
					   ""                    ,; //-- [09] F3
					   .T.   	 	         ,; //-- [10] Editavel
					   ""                    ,; //-- [11] Folder
					   ""                    ,; //-- [12] Group
					   Nil                   ,; //-- [13] Lista Combo
					   Nil                   ,; //-- [14] Tam Max Combo
					   "0"                   ,; //-- [15] Inic. Browse
					   .F.     	              ) //-- [16] Virtual

	oStruDev:AddField( "XX_NPROD"            ,; //-- [01] Campo
					   StrZero( nOrdem++, 2 ),; //-- [02] Ordem 
					   "Produto Novo?"       ,; //-- [03] Titulo
					   "Produto Novo?"       ,; //-- [04] Descricao
					   Nil                   ,; //-- [05] Help
					   "GET"                 ,; //-- [06] Tipo do campo (COMBO","GET","CHECK")
					   "@!"                  ,; //-- [07] Picture
					   Nil                   ,; //-- [08] PictVar
					   ""                    ,; //-- [09] F3
					   .F.   	 	         ,; //-- [10] Editavel
					   ""                    ,; //-- [11] Folder
					   ""                    ,; //-- [12] Group
					   Nil                   ,; //-- [13] Lista Combo
					   Nil                   ,; //-- [14] Tam Max Combo
					   ""                    ,; //-- [15] Inic. Browse
					   .F.     	              ) //-- [16] Virtual

	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	For nI := 6 To 7
		If SX3->(DbSeek(aCpoDet[nI]))

			aCombo := {}

			If !Empty(X3Cbox())
				nInitCBox := 0
				nMaxLenCb := 0
				aAux      := RetSX3Box(X3Cbox(), @nInitCBox, @nMaxLenCb, SX3->X3_TAMANHO)

				For nX := 1 To Len(aAux)
					aAdd(aCombo, aAux[nX][1])
				Next nX
			EndIf

			bPictVar := FwBuildFeature(4, SX3->X3_PICTVAR)		
			cGSC     := IIf(Empty(X3Cbox()), IIf(SX3->X3_TIPO == 'L', 'CHECK', 'GET'), 'COMBO')		

			oStruDev:AddField( AllTrim( SX3->X3_CAMPO ),; //-- [01] Campo
							   StrZero( nOrdem++, 2 )  ,; //-- [02] Ordem
							   AllTrim( X3Titulo() )   ,; //-- [03] Titulo
							   AllTrim( X3Descric() )  ,; //-- [04] Descricao
							   Nil                     ,; //-- [05] Help
							   cGSC                    ,; //-- [06] Tipo do campo   COMBO, Get ou CHECK
							   SX3->X3_PICTURE         ,; //-- [07] Picture
							   bPictVar                ,; //-- [08] PictVar
							   SX3->X3_F3              ,; //-- [09] F3
							   SX3->X3_VISUAL <> 'V'   ,; //-- [10] Editavel
							   SX3->X3_FOLDER          ,; //-- [11] Folder
							   SX3->X3_FOLDER          ,; //-- [12] Group
							   aCombo                  ,; //-- [13] Lista Combo
							   nMaxLenCb               ,; //-- [14] Tam Max Combo
							   SX3->X3_INIBRW          ,; //-- [15] Inic. Browse
							   SX3->X3_CONTEXT == 'V'   ) //-- [16] Virtual	
		EndIf
	Next nI
	
	//########################################################################
	//-- SUCATA
	//########################################################################

	oStruSuc:AddField( "XX_PRODUTO"          ,; //-- [01] Campo
					   StrZero( nOrdem++, 2 ),; //-- [02] Ordem 
					   "Materia Prima Orig"  ,; //-- [03] Titulo
					   "Materia Prima Orig"  ,; //-- [04] Descricao
					   Nil                   ,; //-- [05] Help
					   "GET"                 ,; //-- [06] Tipo do campo (COMBO","GET","CHECK")
					   "@!"                  ,; //-- [07] Picture
					   Nil                   ,; //-- [08] PictVar
					   "SB1"                 ,; //-- [09] F3
					   .T.   	 	         ,; //-- [10] Editavel
					   ""                    ,; //-- [11] Folder
					   ""                    ,; //-- [12] Group
					   Nil                   ,; //-- [13] Lista Combo
					   Nil                   ,; //-- [14] Tam Max Combo
					   "0"                   ,; //-- [15] Inic. Browse
					   .F.     	             )  //-- [16] Virtual

	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	For nI := 1 To 5
		If SX3->(DbSeek(aCpoDet[nI]))

			aCombo := {}

			If !Empty(X3Cbox())
				nInitCBox := 0
				nMaxLenCb := 0
				aAux      := RetSX3Box(X3Cbox(), @nInitCBox, @nMaxLenCb, SX3->X3_TAMANHO)

				For nX := 1 To Len(aAux)
					aAdd(aCombo, aAux[nX][1])
				Next nX
			EndIf

			bPictVar := FwBuildFeature(4, SX3->X3_PICTVAR)		
			cGSC     := IIf(Empty(X3Cbox()), IIf(SX3->X3_TIPO == 'L', 'CHECK', 'GET'), 'COMBO')		

			oStruSuc:AddField( AllTrim( SX3->X3_CAMPO ),; //-- [01] Campo
							   StrZero( nOrdem++, 2 )  ,; //-- [02] Ordem
							   AllTrim( X3Titulo() )   ,; //-- [03] Titulo
							   AllTrim( X3Descric() )  ,; //-- [04] Descricao
							   Nil                     ,; //-- [05] Help
							   cGSC                    ,; //-- [06] Tipo do campo   COMBO, Get ou CHECK
							   SX3->X3_PICTURE         ,; //-- [07] Picture
							   bPictVar                ,; //-- [08] PictVar
							   SX3->X3_F3              ,; //-- [09] F3
							   SX3->X3_VISUAL <> 'V'   ,; //-- [10] Editavel
							   SX3->X3_FOLDER          ,; //-- [11] Folder
							   SX3->X3_FOLDER          ,; //-- [12] Group
							   aCombo                  ,; //-- [13] Lista Combo
							   nMaxLenCb               ,; //-- [14] Tam Max Combo
							   SX3->X3_INIBRW          ,; //-- [15] Inic. Browse
							   SX3->X3_CONTEXT == 'V'   ) //-- [16] Virtual	
		EndIf
	Next nI
    /*
	oStruSuc:AddField( "XX_DIAMINT"          ,; //-- [01] Campo
					   StrZero( nOrdem++, 2 ),; //-- [02] Ordem 
					   'Ø Interno (")'       ,; //-- [03] Titulo
					   'Diametro Interno (")',; //-- [04] Descricao
					   Nil                   ,; //-- [05] Help
					   "GET"                 ,; //-- [06] Tipo do campo (COMBO","GET","CHECK")
					   "99"                  ,; //-- [07] Picture
					   Nil                   ,; //-- [08] PictVar
					   ""                    ,; //-- [09] F3
					   .T.   	 	         ,; //-- [10] Editavel
					   ""                    ,; //-- [11] Folder
					   ""                    ,; //-- [12] Group
					   Nil                   ,; //-- [13] Lista Combo
					   Nil                   ,; //-- [14] Tam Max Combo
					   "0"                   ,; //-- [15] Inic. Browse
					   .F.     	              ) //-- [16] Virtual

	oStruSuc:AddField( "XX_DIAMEXT"           ,; //-- [01] Campo
					   StrZero( nOrdem++, 2 ) ,; //-- [02] Ordem 
					   "Ø Externo (mm)"       ,; //-- [03] Titulo
					   "Diametro Externo (mm)",; //-- [04] Descricao
					   Nil                    ,; //-- [05] Help
					   "GET"                  ,; //-- [06] Tipo do campo (COMBO","GET","CHECK")
					   "999"                  ,; //-- [07] Picture
					   Nil                    ,; //-- [08] PictVar
					   ""                     ,; //-- [09] F3
					   .T.   	 	          ,; //-- [10] Editavel
					   ""                     ,; //-- [11] Folder
					   ""                     ,; //-- [12] Group
					   Nil                    ,; //-- [13] Lista Combo
					   Nil                    ,; //-- [14] Tam Max Combo
					   "0"                    ,; //-- [15] Inic. Browse
					   .F.     	               ) //-- [16] Virtual

	oStruSuc:AddField( "XX_LARG"             ,; //-- [01] Campo
					   StrZero( nOrdem++, 2 ),; //-- [02] Ordem 
					   "Largura (mm)"        ,; //-- [03] Titulo
					   "Largura (mm)"        ,; //-- [04] Descricao
					   Nil                   ,; //-- [05] Help
					   "GET"                 ,; //-- [06] Tipo do campo (COMBO","GET","CHECK")
					   "9999"                ,; //-- [07] Picture
					   Nil                   ,; //-- [08] PictVar
					   ""                    ,; //-- [09] F3
					   .T.   	 	         ,; //-- [10] Editavel
					   ""                    ,; //-- [11] Folder
					   ""                    ,; //-- [12] Group
					   Nil                   ,; //-- [13] Lista Combo
					   Nil                   ,; //-- [14] Tam Max Combo
					   "0"                   ,; //-- [15] Inic. Browse
					   .F.     	              ) //-- [16] Virtual
 
	oStruSuc:AddField( "XX_NPROD"            ,; //-- [01] Campo
					   StrZero( nOrdem++, 2 ),; //-- [02] Ordem 
					   "Produto Novo?"       ,; //-- [03] Titulo
					   "Produto Novo?"       ,; //-- [04] Descricao
					   Nil                   ,; //-- [05] Help
					   "GET"                 ,; //-- [06] Tipo do campo (COMBO","GET","CHECK")
					   "@!"                  ,; //-- [07] Picture
					   Nil                   ,; //-- [08] PictVar
					   ""                    ,; //-- [09] F3
					   .F.   	 	         ,; //-- [10] Editavel
					   ""                    ,; //-- [11] Folder
					   ""                    ,; //-- [12] Group
					   Nil                   ,; //-- [13] Lista Combo
					   Nil                   ,; //-- [14] Tam Max Combo
					   ""                    ,; //-- [15] Inic. Browse
					   .F.     	              ) //-- [16] Virtual
    */
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	For nI := 6 To 7
		If SX3->(DbSeek(aCpoDet[nI]))

			aCombo := {}

			If !Empty(X3Cbox())
				nInitCBox := 0
				nMaxLenCb := 0
				aAux      := RetSX3Box(X3Cbox(), @nInitCBox, @nMaxLenCb, SX3->X3_TAMANHO)

				For nX := 1 To Len(aAux)
					aAdd(aCombo, aAux[nX][1])
				Next nX
			EndIf

			If AllTrim(aCpoDet[nI]) == "BC_LOCAL"
				lEdit := .F.
			Else
				lEdit := .T.			
			Endif

			bPictVar := FwBuildFeature(4, SX3->X3_PICTVAR)		
			cGSC     := IIf(Empty(X3Cbox()), IIf(SX3->X3_TIPO == 'L', 'CHECK', 'GET'), 'COMBO')		
			/*
			oStruSuc:AddField( AllTrim( SX3->X3_CAMPO ),; //-- [01] Campo
							   StrZero( nOrdem++,2)    ,; //-- [02] Ordem
							   AllTrim( X3Titulo() )   ,; //-- [03] Titulo
							   AllTrim( X3Descric() )  ,; //-- [04] Descricao
							   Nil                     ,; //-- [05] Help
							   cGSC                    ,; //-- [06] Tipo do campo   COMBO, Get ou CHECK
							   SX3->X3_PICTURE         ,; //-- [07] Picture
							   bPictVar                ,; //-- [08] PictVar
							   SX3->X3_F3              ,; //-- [09] F3
							   SX3->X3_VISUAL <> 'V'   ,; //-- [10] Editavel
							   SX3->X3_FOLDER          ,; //-- [11] Folder
							   SX3->X3_FOLDER          ,; //-- [12] Group
							   aCombo                  ,; //-- [13] Lista Combo
							   nMaxLenCb               ,; //-- [14] Tam Max Combo
							   SX3->X3_INIBRW          ,; //-- [15] Inic. Browse
							   SX3->X3_CONTEXT == 'V'   ) //-- [16] Virtual	
             */
			oStruSuc:AddField( AllTrim( SX3->X3_CAMPO ),; //-- [01] Campo
							   StrZero( nOrdem++,2)    ,; //-- [02] Ordem
							   AllTrim( X3Titulo() )   ,; //-- [03] Titulo
							   AllTrim( X3Descric() )  ,; //-- [04] Descricao
							   Nil                     ,; //-- [05] Help
							   cGSC                    ,; //-- [06] Tipo do campo   COMBO, Get ou CHECK
							   SX3->X3_PICTURE         ,; //-- [07] Picture
							   bPictVar                ,; //-- [08] PictVar
							   SX3->X3_F3              ,; //-- [09] F3
							   lEdit                   ,; //-- [10] Editavel
							   SX3->X3_FOLDER          ,; //-- [11] Folder
							   SX3->X3_FOLDER          ,; //-- [12] Group
							   aCombo                  ,; //-- [13] Lista Combo
							   nMaxLenCb               ,; //-- [14] Tam Max Combo
							   SX3->X3_INIBRW          ,; //-- [15] Inic. Browse
							   SX3->X3_CONTEXT == 'V'   ) //-- [16] Virtual	

		EndIf
	Next nI

	oStruDev:SetProperty("BC_CODDEST", MVC_VIEW_CANCHANGE, .F.)
	oStruDev:SetProperty("BC_CODDEST", MVC_VIEW_TITULO, "Materia Prima Dest")
	oStruDev:SetProperty("BC_QUANT", MVC_VIEW_TITULO, "Peso Liquido")

	//oStruSuc:SetProperty("BC_CODDEST", MVC_VIEW_CANCHANGE, .F.)
	oStruSuc:SetProperty("BC_CODDEST", MVC_VIEW_TITULO, "Materia Prima Dest")
	oStruSuc:SetProperty("BC_QUANT", MVC_VIEW_TITULO, "Peso Liquido")

	RestArea(aAreaSX3)
	RestArea(aArea)

Return


/*/{Protheus.doc} LoadActiv
Funcao que carrega os principais dados do cabecalho da tela
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 10/01/2022
@param oModel, object, Modelo da dados
@return logical, Retorno logico
/*/
Static Function LoadActiv(oModel)
	Local aDimenMP   := {}
	Local nDiamIntMP := 0
	Local nDiamExtMP := 0
	Local nLarguraMP := 0
	Local nOperation := oModel:GetOperation()
	Local nX		 := 0
	Local lRet		 := .T.
	Local lInicio    := .T.
	Local oMdlDevol  := oModel:GetModel("DEVSTRU")
	Local oMdlSucat  := oModel:GetModel("SUCSTRU")

	If nOperation == MODEL_OPERATION_INSERT
		oModel:SetValue( "MASTERSTRU", "XX_OP"     , cOP )
		oModel:SetValue( "MASTERSTRU", "XX_CODPAI" , cCodPai )
		oModel:SetValue( "MASTERSTRU", "XX_DESCPAI", cDescPai )
		oModel:SetValue( "MASTERSTRU", "BC_TIPO"   , "S" )
		oModel:SetValue( "MASTERSTRU", "BC_MOTIVO" , "00" ) 

		For nX := 1 To Len(aCodMPs)
			If !lInicio
				oMdlDevol:AddLine()
				oMdlSucat:AddLine()
			EndIf

			aDimenMP   := u_xGetDimen(aCodMPs[nX, 01], "N")
			nDiamIntMP := aDimenMP[01]
			nDiamExtMP := aDimenMP[02]
			nLarguraMP := aDimenMP[03]

			//-- Preenche os LOTES na ABA do Retorno para Estoque
			oMdlDevol:SetValue( "XX_PRODUTO", aCodMPs[nX, 01] )
			oMdlDevol:SetValue( "BC_LOCORIG", aCodMPs[nX, 03] )
			oMdlDevol:SetValue( "BC_LOTECTL", aCodMPs[nX, 04] )
			oMdlDevol:SetValue( "BC_NUMLOTE", aCodMPs[nX, 05] )
			oMdlDevol:SetValue( "BC_DTVALID", SToD(aCodMPs[nX, 06]) )
			oMdlDevol:SetValue( "XX_DIAMINT", nDiamIntMP )
			oMdlDevol:SetValue( "XX_DIAMEXT", nDiamExtMP )
			//oMdlDevol:SetValue( "XX_LARG"   , nLarguraMP )

			//-- Preenche os LOTES na ABA da Sucata
			oMdlSucat:SetValue( "XX_PRODUTO", aCodMPs[nX, 01] )
			oMdlSucat:SetValue( "BC_LOCORIG", aCodMPs[nX, 03] )
			oMdlSucat:SetValue( "BC_LOTECTL", aCodMPs[nX, 04] )
			oMdlSucat:SetValue( "BC_NUMLOTE", aCodMPs[nX, 05] )
			oMdlSucat:SetValue( "BC_DTVALID", SToD(aCodMPs[nX, 06]) )
			//oMdlSucat:SetValue( "XX_DIAMINT", nDiamIntMP )
			//oMdlSucat:SetValue( "XX_DIAMEXT", nDiamExtMP )
			//oMdlSucat:SetValue( "XX_LARG"   , nLarguraMP )

			If lInicio
				lInicio := .F.
			EndIf
		Next nX
	EndIf

Return lRet


/*/{Protheus.doc} DevLinePreGrid
Pre-validacao do sub-modelo de Devolucao - Retorno para Estoque
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 10/01/2022
@param oGridModel, object, Sub-modelo de retorno para estoque
@param nLine, numeric, Linha
@param cAction, character, Acao
@param cIDField, character, Nome do campo
@param xValue, variant, Valor
@param xCurrentValue, variant, VAlor correte
@return logical, Retorno logico
/*/
Static Function DevLinePreGrid(oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue, oModel )
    Local aArea    := GetArea()
    Local aAreaSB8 := SB8->( GetArea() )
	Local cCodMP   := ""
	Local cLotCtl  := ""
	Local cNumLote := ""
	Local lRet     := .T.
	Local oViewAct := Nil
	Local oMdlSuc  := Nil
	Local nQtdSuc  := 0
	Local nSumJApt := 0

	Local nLinhaAtu := 0
	Local nQtdEmp   := 0
	Local nQtdBrw   := 0
	Local nX        := 1
	Local nPosProd  := Ascan( aHeader ,  { |x| AllTrim(x[2]) == "XX_PRODUTO" })
	Local nPosLocal := Ascan( aHeader ,  { |x| AllTrim(x[2]) == "BC_LOCORIG" })
	Local nPosLote  := Ascan( aHeader ,  { |x| AllTrim(x[2]) == "BC_LOTECTL" })
	Local nPosSbLt  := Ascan( aHeader ,  { |x| AllTrim(x[2]) == "BC_NUMLOTE" })
	Local nPosQtd   := Ascan( aHeader ,  { |x| AllTrim(x[2]) == "BC_QUANT" })
	Local nPosDtVl  := Ascan( aHeader ,  { |x| Alltrim(x[2]) == "BC_DTVALID"})
	Local cProd     := ""
	Local cLocal    := ""
	Local cLoteCtl  := ""
	Local cNumLt    := ""

	Local nsPosProd  := 0
	Local nsPosLocal := 0
	Local nsPosLote  := 0
	Local nsPosSbLt  := 0
	Local nsPosQtd   := 0

	Local oMdlCab  := oModel:GetModel( "MASTERSTRU" )
	
	cProd     := oGridModel:aCols[ nLine, nPosProd ]
	cLocal    := oGridModel:aCols[ nLine, nPosLocal]
	cLoteCtl  := oGridModel:aCols[ nLine, nPosLote ]
	cNumLt    := oGridModel:aCols[ nLine, nPosSbLt ]
	cOp       := oMdlCab:GetValue( "XX_OP" )
	
	oViewAct := FwViewActive()
	oMdlSuc  := oViewAct:GetModel():GetModel("SUCSTRU")

    nsPosProd  := Ascan( oMdlSuc:aHeader ,  { |x| AllTrim(x[2]) == "XX_PRODUTO" })
	nsPosLocal := Ascan( oMdlSuc:aHeader ,  { |x| AllTrim(x[2]) == "BC_LOCORIG" })
	nsPosLote  := Ascan( oMdlSuc:aHeader ,  { |x| AllTrim(x[2]) == "BC_LOTECTL" })
	nsPosSbLt  := Ascan( oMdlSuc:aHeader ,  { |x| AllTrim(x[2]) == "BC_NUMLOTE" })
	nsPosQtd   := Ascan( oMdlSuc:aHeader ,  { |x| AllTrim(x[2]) == "BC_QUANT" })
	
	If cAction == "SETVALUE" .And. !IsInCallStack("LoadActiv")
		If cIDField == "BC_QUANT"
			//oViewAct := FwViewActive()
			//oMdlSuc  := oViewAct:GetModel():GetModel("SUCSTRU")
			nLinhaAtu := oGridModel:GetLine()
			//nQtdSuc  := IIF(  Len(oMdlSuc:ADATAMODEL) < nLine, 0,  oMdlSuc:ADATAMODEL[nLine,1,1,6] )
			nQtdSuc := fQtdOutraGrid( oMdlSuc:aCols, cProd, cLocal, cLoteCtl, cNumLt,  nsPosProd, nsPosLocal, nsPosLote, nsPosSbLt, nsPosQtd  ) 
			For nX := 1 To oGridModel:Length()
			    //-- Percorre Grid para verificar se 
				//-- chave atual já foi Incluida na Grid e Soma 
		        If !oGridModel:IsDeleted()				
					If nLinhaAtu <> nX .AND.;
						oGridModel:aCols[ nX, nPosProd ] == cProd .AND.;
						oGridModel:aCols[ nX, nPosLocal] == cLocal .AND.;
						oGridModel:aCols[ nX, nPosLote ] == cLoteCtl .AND.;
						oGridModel:aCols[ nX, nPosSbLt ] == cNumLt
						nQtdBrw   += oGridModel:aCols[ nX, nPosQtd ]
					Endif
				Endif   
			Next nX
			oGridModel:GoLine( nLine )
			nSumJApt := xValue + nQtdSuc + nQtdBrw
			nQtdEmp  := fRetQtdEmp( cOp, cProd, cLocal, cLoteCtl, cNumLt )  //-- Qtd. do Empenho será o Limite 

		EndIf

		If cIDField $ "BC_LOTECTL" .Or. cIDField $ "BC_NUMLOTE"
			DbSelectArea("SB8")
			SB8->( DbSetOrder(2) ) //-- B8_FILIAL+B8_NUMLOTE+B8_LOTECTL+B8_PRODUTO+B8_LOCAL+DTOS(B8_DTVALID)

			cCodMP := oGridModel:aCols[nLine, 01]
			cLocal := oGridModel:aCols[nLine, 02]

			Do Case
				Case cIDField == "BC_LOTECTL"
					cNumLote := oGridModel:aCols[nLine, 04]
					cLotCtl  := xValue
				Case cIDField == "BC_NUMLOTE"
					cNumLote := xValue
					cLotCtl  := oGridModel:aCols[nLine, 03]
			End Case
            
			If !Empty(  cNumLote ) .AND.    !Empty(  cLotCtl )
				If !SB8->( DbSeek( xFilial("SB8") + cNumLote + cLotCtl + cCodMP + cLocal ) )
					oGridModel:GetModel():SetErrorMessage("DEVSTRU", cIDField , "DEVSTRU" , cIDField , "Erro", "Lote/Sub-Lote informado não existe.", "Informe um Lote/Sub-Lote que exista.", xValue)
					lRet := .F.
				Else	
					If Empty( oGridModel:aCols[nLine, nPosDtVl] )
						oGridModel:aCols[nLine, nPosDtVl] := SB8->B8_DTVALID
						oViewAct:Refresh()
						oGridModel:GoLine( nLine )
					Endif
				EndIf
			Endif

		ElseIf cIDField == "BC_QUANT" .And. nSumJApt >= nQtdEmp 
		//ElseIf cIDField == "BC_QUANT" //.And. nSumJApt >= IF( Len(oMdlSuc:ADATAMODEL) < nLine, 0, aCodMPs[nLine,8] )
			oGridModel:GetModel():SetErrorMessage("DEVSTRU", "BC_QUANT" , "DEVSTRU" , "BC_QUANT" , "Erro", "Peso maior.", "O peso total informado " + AllTrim(Transform( nSumJApt, "@E 999,999.99" )) + ",  não pode ser maior ou igual ao peso do empenho " + AllTrim(Transform( nQtdEmp, "@E 999,999.99" )), xValue)
			lRet := .F.
		ElseIf (cIDField == "XX_PESOBRT" .And. xValue < 0) .Or. (cIDField == "XX_PESOBRT" .And. xValue <= oGridModel:aCols[nLine, 06])
			oGridModel:GetModel():SetErrorMessage("DEVSTRU", "XX_PESOBRT" , "DEVSTRU" , "XX_PESOBRT" , "Erro", "Peso bruto digitado não está dentro do limite.", "O peso bruto deve ser maior que o peso liquido e/ou maior que zero.", xValue)
			lRet := .F.
		ElseIf (cIDField == "XX_DIAMINT" .And. xValue <= 0) .Or. (cIDField == "XX_DIAMINT" .And. (xValue # 3 .And. xValue # 6))  
			oGridModel:GetModel():SetErrorMessage("DEVSTRU", "XX_DIAMINT" , "DEVSTRU" , "XX_DIAMINT" , "Erro", "Diametro digitado não está dentro do limite.", 'O diametro interno deve ser 3" ou 6".', xValue)
			lRet := .F.
		ElseIf (cIDField == "XX_DIAMEXT" .And. xValue <= 0) .Or. (cIDField == "XX_DIAMEXT" .And. xValue > u_xGetDimen( oGridModel:aCols[nLine, 01], "N" )[02])
			oGridModel:GetModel():SetErrorMessage("DEVSTRU", "XX_DIAMEXT" , "DEVSTRU" , "XX_DIAMEXT" , "Erro", "Diametro digitado não está dentro do limite.", "O diametro externo deve ser menor que o diametro atual.", xValue)
			lRet := .F.
		ElseIf (cIDField == "XX_LARG" .And. xValue < 0) .Or. (cIDField == "XX_LARG" .And. xValue > u_xGetDimen( oGridModel:aCols[nLine, 01], "N" )[03])
			oGridModel:GetModel():SetErrorMessage("DEVSTRU", "XX_LARG" , "DEVSTRU" , "XX_LARG" , "Erro", "Largura digitada não está dentro do limite.", "A largura deve ser menor que a largura atual.", xValue)
			lRet := .F.
		ElseIf ( cIDField == "XX_DIAMINT" .And. !Empty( oGridModel:aCols[nLine, 09] ) ) .Or.;
			   ( cIDField == "XX_DIAMEXT" .And. !Empty( oGridModel:aCols[nLine, 09] ) ) .Or.;
			   cIDField == "XX_LARG"

			SetCodigo(oGridModel, xValue, "DEVSTRU", nLine, cIDField)

			If cIDField == "XX_LARG"
				nPos := aScan(aCodMPs, {|x| x[1]+x[4]+x[5] == cProd + cLoteCtl + cNumLt})
				If nPos > 0
					//-- Calcula a o peso da bobina que que sera um RETORNO PARA ESTOQUE
					nLargMP  := u_xGetDimen(cProd, "N")[03]
					nNewPeso := Round(((xValue / nLargMP) * aCodMPs[nPos, 07]), 1)
					oGridModel:getModel("DEVSTRU"):setValue("DEVSTRU", "BC_QUANT", nNewPeso)
				EndIf
			EndIf
		EndIf

	EndIf

    RestArea( aAreaSB8 )
    RestArea( aArea )

Return lRet


/*/{Protheus.doc} SucLinePreGrid
Pre-validacao do sub-modelo de Sucata
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 10/01/2022
@param oGridModel, object, Sub-modelo da sucata
@param nLine, numeric, Linha
@param cAction, character, Acao
@param cIDField, character, Nome do campo
@param xValue, variant, Valor
@param xCurrentValue, variant, VAlor correte
@return logical, Retorno logico
/*/
Static Function SucLinePreGrid(oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue, oModel)
    Local aArea    := GetArea()
    Local aAreaSB8 := SB8->( GetArea() )
	Local cCodMP   := ""
	Local cLocal   := ""
	Local cLotCtl  := ""
	Local cNumLote := ""
	Local lRet     := .T.
	Local oViewAct := Nil
	Local oMdlDev  := Nil
	Local nQtdDev  := 0
	Local nSumJApt := 0

	Local nLinhaAtu := 0
	Local nQtdEmp   := 0
	Local nQtdBrw   := 0
	Local nX        := 1	
	Local nPosProd  := Ascan( aHeader ,  { |x| AllTrim(x[2]) == "XX_PRODUTO" })
	Local nPosLocal := Ascan( aHeader ,  { |x| AllTrim(x[2]) == "BC_LOCORIG" })
	Local nPosLote  := Ascan( aHeader ,  { |x| AllTrim(x[2]) == "BC_LOTECTL" })
	Local nPosSbLt  := Ascan( aHeader ,  { |x| AllTrim(x[2]) == "BC_NUMLOTE" })

	Local oMdlCab  := oModel:GetModel( "MASTERSTRU" )

	Local nsPosProd  := 0
	Local nsPosLocal := 0
	Local nsPosLote  := 0
	Local nsPosSbLt  := 0
	Local nsPosQtd   := 0
	
	cProd     := oGridModel:aCols[ nLine, nPosProd ]
	cLocal    := oGridModel:aCols[ nLine, nPosLocal]
	cLoteCtl  := oGridModel:aCols[ nLine, nPosLote ]
	cNumLt    := oGridModel:aCols[ nLine, nPosSbLt ]
	cOp       := oMdlCab:GetValue( "XX_OP" )	
	
	oViewAct := FwViewActive()
	oMdlDev  := oViewAct:GetModel():GetModel("DEVSTRU")

	nsPosProd  := Ascan( oMdlDev:aHeader ,  { |x| AllTrim(x[2]) == "XX_PRODUTO" })
	nsPosLocal := Ascan( oMdlDev:aHeader ,  { |x| AllTrim(x[2]) == "BC_LOCORIG" })
	nsPosLote  := Ascan( oMdlDev:aHeader ,  { |x| AllTrim(x[2]) == "BC_LOTECTL" })
	nsPosSbLt  := Ascan( oMdlDev:aHeader ,  { |x| AllTrim(x[2]) == "BC_NUMLOTE" })
	nsPosQtd   := Ascan( oMdlDev:aHeader ,  { |x| AllTrim(x[2]) == "BC_QUANT" })

	If cAction == "SETVALUE" .And. !IsInCallStack("LoadActiv")
		If cIDField == "BC_QUANT"
			//oViewAct := FwViewActive()
			//oMdlDev  := oViewAct:GetModel():GetModel("DEVSTRU")
			//nQtdDev  := oMdlDev:ADATAMODEL[nLine,1,1,6]
		    nLinhaAtu := oGridModel:GetLine()			
			nQtdDev  := fQtdOutraGrid( oMdlDev:aCols, cProd, cLocal, cLoteCtl, cNumLt,  nsPosProd, nsPosLocal, nsPosLote, nsPosSbLt, nsPosQtd  ) 
			//nQtdDev  := IIF( Len(oMdlDev:ADATAMODEL) < nLine, 0,  oMdlDev:ADATAMODEL[nLine,1,1,6] ) 
			//nSumJApt := xValue + nQtdDev
			For nX := 1 To oGridModel:Length()
			    //-- Percorre Grid para verificar se 
				//-- chave atual já foi Incluida na Grid e Soma 
		        If !oGridModel:IsDeleted()				
					If nLinhaAtu <> nX .AND.;
						oGridModel:aCols[ nX, nPosProd ] == cProd .AND.;
						oGridModel:aCols[ nX, nPosLocal] == cLocal .AND.;
						oGridModel:aCols[ nX, nPosLote ] == cLoteCtl .AND.;
						oGridModel:aCols[ nX, nPosSbLt ] == cNumLt
						nQtdBrw   += oGridModel:aCols[ nX, nPosQtd ]
					Endif
				Endif   
			Next nX
			oGridModel:GoLine( nLine )
			nSumJApt := xValue + nQtdDev + nQtdBrw
			nQtdEmp  := fRetQtdEmp( cOp, cProd, cLocal, cLoteCtl, cNumLt )  //-- Qtd. do Empenho será o Limite 

		EndIf

		If cIDField $ "BC_LOTECTL" .Or. cIDField $ "BC_NUMLOTE"
			DbSelectArea("SB8")
			SB8->( DbSetOrder(2) ) //-- B8_FILIAL+B8_NUMLOTE+B8_LOTECTL+B8_PRODUTO+B8_LOCAL+DTOS(B8_DTVALID)

			cCodMP := oGridModel:aCols[nLine, 01]
			cLocal := oGridModel:aCols[nLine, 02]

			Do Case
				Case cIDField == "BC_LOTECTL"
					cNumLote := oGridModel:aCols[nLine, 03]
					cLotCtl  := xValue
				Case cIDField == "BC_NUMLOTE"
					cNumLote := xValue
					cLotCtl  := oGridModel:aCols[nLine, 04]
			End Case

			If !Empty(  cNumLote ) .AND.    !Empty(  cLotCtl )
				If !SB8->( DbSeek( xFilial("SB8") + cNumLote + cLotCtl + cCodMP + cLocal ) )
					oGridModel:GetModel():SetErrorMessage("SUCSTRU", cIDField , "SUCSTRU" , cIDField , "Erro", "Lote/Sub-Lote informado não existe.", "Informe um Lote/Sub-Lote que exista.", xValue)
					lRet := .F.
				EndIf
			Endif

		ElseIf cIDField == "BC_QUANT" .And. xValue < 0
			oGridModel:GetModel():SetErrorMessage("SUCSTRU", "BC_QUANT" , "SUCSTRU" , "BC_QUANT" , "Erro", "Valor negativo.", "O valor informado não pode ser negativo.", xValue)
			lRet := .F.
		ElseIf cIDField == "BC_QUANT" .And. nSumJApt >= nQtdEmp 
			oGridModel:GetModel():SetErrorMessage("SUCSTRU", "BC_QUANT" , "DEVSTRU" , "BC_QUANT" , "Erro", "Valor maior.", "Peso maior.", "O peso total informado " + AllTrim(Transform( nSumJApt, "@E 999,999.99" )) + ",  não pode ser maior ou igual ao peso do empenho " + AllTrim(Transform( nQtdEmp, "@E 999,999.99" )), xValue)	
	        lRet := .F.					
	    //ElseIf cIDField == "BC_QUANT" //.And. nSumJApt >= IF( Len(oMdlDev:ADATAMODEL) < nLine, 0, aCodMPs[nLine,8] )
			//oGridModel:GetModel():SetErrorMessage("SUCSTRU", "BC_QUANT" , "SUCSTRU" , "BC_QUANT" , "Erro", "Valor maior.", "O valor informado não pode ser maior que o peso original da bobina/empenho.", xValue)
			//lRet := .F.		
		ElseIf (cIDField == "XX_DIAMINT" .And. xValue <= 0) .Or. (cIDField == "XX_DIAMINT" .And. (xValue # 3 .And. xValue # 6))  
			oGridModel:GetModel():SetErrorMessage("SUCSTRU", "XX_DIAMINT" , "SUCSTRU" , "XX_DIAMINT" , "Erro", "Diametro digitado não está dentro do limite.", 'O diametro interno deve ser 3" ou 6".', xValue)
			lRet := .F.
		ElseIf (cIDField == "XX_DIAMEXT" .And. xValue <= 0) .Or. (cIDField == "XX_DIAMEXT" .And. xValue > u_xGetDimen( oGridModel:aCols[nLine, 01], "N" )[02])
			oGridModel:GetModel():SetErrorMessage("SUCSTRU", "XX_DIAMEXT" , "SUCSTRU" , "XX_DIAMEXT" , "Erro", "Diametro digitado não está dentro do limite.", "O diametro externo deve ser menor que o diametro atual.", xValue)
			lRet := .F.
		ElseIf (cIDField == "XX_LARG" .And. xValue < 0) .Or. (cIDField == "XX_LARG" .And. xValue > u_xGetDimen( oGridModel:aCols[nLine, 01], "N" )[03])
			oGridModel:GetModel():SetErrorMessage("SUCSTRU", "XX_LARG" , "SUCSTRU" , "XX_LARG" , "Erro", "Largura digitada não está dentro do limite.", "A largura deve ser menor que a largura atual.", xValue)
			lRet := .F.
		ElseIf ( cIDField == "XX_DIAMINT" .And. !Empty( oGridModel:aCols[nLine, 09] ) ) .Or.;
			   ( cIDField == "XX_DIAMEXT" .And. !Empty( oGridModel:aCols[nLine, 09] ) ) .Or.;
			   cIDField == "XX_LARG"

			SetCodigo(oGridModel, xValue, "SUCSTRU", nLine, cIDField)
		EndIf

	EndIf

    RestArea( aAreaSB8 )
    RestArea( aArea )

Return lRet


/*/{Protheus.doc} DevLinePostGrid
Pos-validacao do sub-modelo de Devolucao - Retorno para Estoque
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 10/01/2022
@param oGridModel, object, Modelo de dados
@param nLine, numeric, Linha
@return logical, Retorno logico
/*/
Static Function DevLinePostGrid(oGridModel, nLine)
	Local nI        := 0
	Local lRet      := .T.
	Local xContQtde := 0
	Local xContLarg := 0
	Local xLoteCtl  := ""
	Local xNumLote  := ""


	If !IsInCallStack("LoadActiv")
		For nI := 1 To Len(oGridModel:AHEADER)
			If oGridModel:AHEADER[nI, 2] == "BC_QUANT"
				xContQtde := oGridModel:GetValue(oGridModel:AHEADER[nI,2])
				cCpoQtde  := oGridModel:AHEADER[nI, 2]	
			EndIf

			If oGridModel:AHEADER[nI,2] == "XX_LARG"
				xContLarg := oGridModel:GetValue(oGridModel:AHEADER[nI,2])
				cCpoLarg  := oGridModel:AHEADER[nI, 2]
			EndIf

			If oGridModel:AHEADER[nI, 2] == "BC_LOTECTL"
				xLoteCtl := oGridModel:GetValue(oGridModel:AHEADER[nI,2])
				cCpoLtCt := oGridModel:AHEADER[nI, 2]
			Endif

			If oGridModel:AHEADER[nI, 2] == "BC_NUMLOTE"
				xNumLote  := oGridModel:GetValue(oGridModel:AHEADER[nI,2])
				cCpoNumLT := oGridModel:AHEADER[nI, 2]
			Endif

		Next nI

		If Empty(xContQtde) .And. !Empty(xContLarg)		
			oGridModel:GetModel():SetErrorMessage("DEVSTRU", cCpoQtde, "DEVSTRU" , cCpoQtde, "RETORNO P/ ESTOQUE", "Campo obrigatório não preenchido."+Chr(10)+"["+cCpoQtde+"]", "Informe os valores nos campos obrigatórios para prosseguir.")
			lRet := .F.
		EndIf

		If Empty(xLoteCtl) .And. !Empty(xContLarg)		
			oGridModel:GetModel():SetErrorMessage("DEVSTRU", cCpoLtCt, "DEVSTRU" , cCpoLtCt, "RETORNO P/ ESTOQUE", "Campo obrigatório não preenchido."+Chr(10)+"["+cCpoLtCt+"]", "Informe os valores nos campos obrigatórios para prosseguir.")
			lRet := .F.
		EndIf

		If Empty(xNumLote) .And. !Empty(xContLarg)		
			oGridModel:GetModel():SetErrorMessage("DEVSTRU", cCpoNumLT, "DEVSTRU" , cCpoNumLT, "RETORNO P/ ESTOQUE", "Campo obrigatório não preenchido."+Chr(10)+"["+cCpoNumLT+"]", "Informe os valores nos campos obrigatórios para prosseguir.")
			lRet := .F.
		EndIf

		If !Empty(xContQtde) .And. Empty(xContLarg)	
			oGridModel:GetModel():SetErrorMessage("DEVSTRU", cCpoLarg, "DEVSTRU" , cCpoLarg, "RETORNO P/ ESTOQUE", "Campo obrigatório não preenchido."+Chr(10)+"["+cCpoLarg+"]", "Informe os valores nos campos obrigatórios para prosseguir.")
			lRet := .F.
		EndIf
		
	EndIf

Return lRet


/*/{Protheus.doc} SucLinePostGrid
Pos-validacao do sub-modelo de Sucata
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 10/01/2022
@param oGridModel, object, Modelo de dados
@param nLine, numeric, Linha
@return logical, Retorno logico
/*/
Static Function SucLinePostGrid(oGridModel, nLine)
	Local nI        := 0
	Local lRet      := .T.
	Local xContQtde := 0
	//Local xContLarg := 0

	If !IsInCallStack("LoadActiv")
		For nI := 1 To Len(oGridModel:AHEADER)
			If oGridModel:AHEADER[nI, 2] == "BC_QUANT"
				xContQtde := oGridModel:GetValue(oGridModel:AHEADER[nI,2])
				cCpoQtde  := oGridModel:AHEADER[nI, 2]	
			EndIf
            /*
			If oGridModel:AHEADER[nI,2] == "XX_LARG"
				xContLarg := oGridModel:GetValue(oGridModel:AHEADER[nI,2])
				cCpoLarg  := oGridModel:AHEADER[nI, 2]
			EndIf
			*/
		Next nI
        /*
		If Empty(xContQtde) .And. !Empty(xContLarg)		
			oGridModel:GetModel():SetErrorMessage("SUCSTRU", cCpoQtde, "SUCSTRU" , cCpoQtde, "SUCATA", "Campo obrigatório não preenchido."+Chr(10)+"["+cCpoQtde+"]", "Informe os valores nos campos obrigatórios para prosseguir.")
			lRet := .F.
		EndIf
     
		If !Empty(xContQtde) .And. Empty(xContLarg)	
			oGridModel:GetModel():SetErrorMessage("SUCSTRU", cCpoLarg, "SUCSTRU" , cCpoLarg, "SUCATA", "Campo obrigatório não preenchido."+Chr(10)+"["+cCpoLarg+"]", "Informe os valores nos campos obrigatórios para prosseguir.")
			lRet := .F.
		EndIf
        */

	EndIf

Return lRet


/*/{Protheus.doc} SetCodigo
Funcao que trata, verifica a existencia e preenche novo codigo na tela
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 10/01/2022
@param oGridMdl, object, Modelo de dados
@param xValue, variant, Valor
@param cModel, character, Nome do modelo
@param nLine, numeric, Linha posicionada
@param cIDField, character, Nome do campo
/*/
Static Function SetCodigo(oGridMdl, xValue, cModel, nLine, cIDField)
	Local aArea      := GetArea()
	Local aAreaSB1   := SB1->(GetArea())
	Local cCodMP     := ""
	Local cFamCodMP  := ""
	Local cNvDiamInt := "" 
	Local cNvDiamExt := ""
	Local cNvLargura := ""
	Local cNvCodMP   := ""
	Local cLocDest   := ""
	Local cExist     := ""
	Local oMdl 	     := oGridMdl:GetModel(cModel)
	Local lIsOff     := .F.

	If !Empty(xValue)
		//-- Codigo da materia prima atual
		cCodMP := AllTRim( oGridMdl:aCols[nLine, 01] )

		/*
		Existe dois tipos de produto:
		Prime -> Codigo normal
		Off   -> Codigo normal + letra "R" no final do codigo, apos a Largura.
		Produtos do tipo 'Off' tem um identificador particurar, todos produtos 
		desse tipo tem seu codigo terminado com a letra "R".
		Informacao passada pelo Jose dia 13/10/2021
		*/
		lIsOff := u_xIsOff(cCodMP)

	    //-- Pega a Familia da MP (MATERIAL)
    	cFamCodMP  := SubStr( cCodMP, 01, ( Len( cCodMP ) - IIf( lIsOff, 10, 09 ) ) )   

		//-- Pega dimensoes da MP
		Do Case
			Case cIDField == "XX_DIAMINT"
				If cModel == "DEVSTRU"
					cNvDiamInt := StrZero( xValue, 2 )
					cNvDiamExt := StrZero( oGridMdl:aCols[nLine, 09], 3 )
					cNvLargura := StrZero( oGridMdl:aCols[nLine, 10], 4 )
				Else
					cNvDiamInt := StrZero( xValue, 2 )
					cNvDiamExt := StrZero( oGridMdl:aCols[nLine, 08], 3 )
					cNvLargura := StrZero( oGridMdl:aCols[nLine, 09], 4 )
				EndIf
			Case cIDField == "XX_DIAMEXT"
				If cModel == "DEVSTRU"
					cNvDiamInt := StrZero( oGridMdl:aCols[nLine, 08], 2 )
					cNvDiamExt := StrZero( xValue, 3 )
					cNvLargura := StrZero( oGridMdl:aCols[nLine, 10], 4 )
				Else
					cNvDiamInt := StrZero( oGridMdl:aCols[nLine, 07], 2 )
					cNvDiamExt := StrZero( xValue, 3 )
					cNvLargura := StrZero( oGridMdl:aCols[nLine, 09], 4 )
				EndIf
			Case cIDField == "XX_LARG"
				If cModel == "DEVSTRU"
					cNvDiamInt := StrZero( oGridMdl:aCols[nLine, 08], 2 )
					cNvDiamExt := StrZero( oGridMdl:aCols[nLine, 09], 3 )
					cNvLargura := StrZero( xValue, 4 )
				Else
					cNvDiamInt := StrZero( oGridMdl:aCols[nLine, 07], 2 )
					cNvDiamExt := StrZero( oGridMdl:aCols[nLine, 08], 3 )
					cNvLargura := StrZero( xValue, 4 )
				EndIf
		End Case

		//-- Fomacao do novo codigo da MP
		cNvCodMP := cFamCodMP + cNvDiamInt + cNvDiamExt + cNvLargura + IIf(lIsOff, "R", "")

		//-- Estoque destino e o mesmo que o estoque origem para devolucoes
		cLocDest := oGridMdl:aCols[nLine, 02]

		If cModel == "SUCSTRU"
			cLocDest := GetMv("RE_ARMSUC", .F., "09") //-- Define o armazem de sucata
		EndIf

		SB1->( DbSetOrder(1) )
		If !SB1->( DbSeek( xFilial("SB1") + PadR( cNvCodMP, TamSx3("B1_COD")[01] ) ) )
			cExist := "SIM"
		Else
			cExist := "NÃO"
		EndIf
	EndIf
	
	//-- Preencheos dados no campo
	oMdl:SetValue(cModel, "XX_NPROD"  , cExist)
	oMdl:SetValue(cModel, "BC_CODDEST", cNvCodMP)
	oMdl:SetValue(cModel, "BC_LOCAL"  , cLocDest)
	
	RestArea(aAreaSB1)
	RestArea(aArea)

Return


/*/{Protheus.doc} TudoOk
Funcao responsavel pela validacao final do Tudo ok da Tela, antes da gravacao
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 10/01/2022
@param oTOkModel, object, Modelo de dados
@return logical, Retorno logico
/*/
Static Function TudoOk(oTOkModel)
	Local oMdlMast  := oTOkModel:GetModel("MASTERSTRU")
	Local oMdlDevol := oTOkModel:GetModel("DEVSTRU")
	Local oMdlSucat := oTOkModel:GetModel("SUCSTRU")
	Local aCpMast   := oMdlMast:GetStruct():GetFields()
	Local aCpDevol  := oMdlDevol:GetStruct():GetFields()
	Local aCpSucat  := oMdlSucat:GetStruct():GetFields()
	Local cCampo 	:= ""
	Local nI 		:= 0
	Local lRet 		:= .T.
	Local lDevol    := .F.
	Local lSucat    := .F.

	//###################################################################################
	// INICIO DAS VALICACOES DE TUDOOK
	//###################################################################################

	//-- DEVOLUCOES
	oMdlDevol := oTOkModel:GetModel( "DEVSTRU" )
	nLineaUX := oMdlDevol:nLine
	For nI := 1 To oMdlDevol:GetQtdLine()
		oMdlDevol:GoLine( nI )
	
		If !oMdlDevol:IsDeleted() .And.;
		   !Empty( oMdlDevol:GetValue( oMdlDevol:AHEADER[06, 02] ) ) .And.;
		   !Empty( oMdlDevol:GetValue( oMdlDevol:AHEADER[09, 02] ) )  

			lDevol := .T.
			Exit		
		EndIf
	Next nI
	oMdlDevol:GoLine( nLineaUX )

	//-- SUCATAS
	oMdlSucat := oTOkModel:GetModel( "SUCSTRU" )
	nLineaUX := oMdlSucat:nLine
	For nI := 1 To oMdlSucat:GetQtdLine()
		oMdlSucat:GoLine( nI )
	
		If !oMdlSucat:IsDeleted() .And.;
		   !Empty( oMdlSucat:GetValue( oMdlSucat:AHEADER[06, 02] ) ) //.And.;
		   //!Empty( oMdlSucat:GetValue( oMdlSucat:AHEADER[09, 02] ) )

			lSucat := .T.
			Exit		
		EndIf
	Next nI
	oMdlSucat:GoLine( nLineaUX )

	//###################################################################################
	// INICIO DAS GRAVACOES, SENDO CADASTRO DE PRODUTOS E APONTAMENTO DAS PERDAS
	//###################################################################################

	If lDevol .Or. lSucat
		//-- Inicia processamento que e responsavel pelos cadastros e o apontamento da perda
		Processa({|| lRet := RunProc(oMdlMast, aCpMast, oMdlDevol, aCpDevol, oMdlSucat, aCpSucat) }, "Aguarde", "Processando...", .T.)

		//-- Seta o Retorno na variavel de ok para o ponto de entrada, se essa varial tiver como .T. a OP sera apontada
		lREPCPA01 := lRet

		//-- Impressao das etiquetas
		If lREPCPA01
			Pergunte("REPCPA1P", .F.)

			If MV_PAR01 == 1 .And. FWAlertYesNo("Deseja imprimir as etiquetas de <b>Retorno para Estoque</b>?", "Impressão Etiquetas?")
				//Etiqueta()
				U_EtiqSZ9( cOp )
			EndIf
		EndIf
	Else
		cCampo := aCpDevol[1, 1]			
		oMdlDevol:GetModel():SetErrorMessage("DEVSTRU", cCampo , "DEVSTRU" , cCampo , "VAZIO", "Retorno para Estoque ou Sucata não informados.", "Para prosseguir informe no minimo um tipo de perda corretamente.")
		lRet := .F.
	EndIf

Return lRet


/*/{Protheus.doc} RunProc
Inicia processamento que e responsavel pelos cadastros e o apontamento da perda
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 10/01/2022
@param oMdlMast, object, Modelo de dados cabecalho
@param aCpMast, array, Array com campos do cabecalho
@param oMdlDevol, object, Modelo de dados retorno
@param aCpDevol, array, Array com campos do retorno
@param oMdlSucat, object, Modelo de dados da sucata
@param aCpSucat, array, Array com campos da sucata
@return logical, Retorno logico
/*/
Static Function RunProc(oMdlMast, aCpMast, oMdlDevol, aCpDevol, oMdlSucat, aCpSucat)
	Local aCadastro  := {} //-- Produtos que serao cadastrados
	Local aAptPerda  := {} //-- Produtos que terao perdas apontadas  
	Local cProdAtual := ""
	Local cProdNovo  := ""
	Local cCadErros  := ""
	Local cArmOrig 	 := ""
	Local cTipo   	 := oMdlMast:GetValue(aCpMast[04, MODEL_FIELD_IDFIELD])
	Local cMotivo 	 := oMdlMast:GetValue(aCpMast[05, MODEL_FIELD_IDFIELD])
	Local cArmDest	 := ""
	Local cErro		 := ""
	Local nQuant     := 0
	Local nI         := 0
	Local lRet       := .T.
	Local cLoteCTL	 := ""
	Local cNumLote	 := ""
	Local dDtValid   := CTOD("//")
	Local nPesoBrt   := 0
	Local nPosLcSuc  := aScan( oMdlSucat:aHeader,{|x| AllTrim(x[2]) == "BC_LOCAL" })
	Local nPosPrSuc  := aScan( oMdlSucat:aHeader,{|x| AllTrim(x[2]) == "BC_CODDEST" })

	cMotivo := AllTrim(cMotivo)

	//-- DEVOLUCOES
	nLineaUX := oMdlDevol:nLine
	For nI := 1 To oMdlDevol:GetQtdLine()
		oMdlDevol:GoLine( nI )
	
		If !oMdlDevol:IsDeleted() //.And. !Empty(oMdlDevol:GetValue(aCpDevol[01, MODEL_FIELD_IDFIELD]))
			//-- Pega novo produto da Devolucao para cadastrar
			cProdNovo := oMdlDevol:GetValue(aCpDevol[12, MODEL_FIELD_IDFIELD])

			If Empty(cProdNovo)
				Loop
			EndIf

			//-- Pega produto atual
			cProdAtual := oMdlDevol:GetValue(aCpDevol[01, MODEL_FIELD_IDFIELD])

			//-- Pega armazem origem
			cArmOrig := oMdlDevol:GetValue(aCpDevol[02, MODEL_FIELD_IDFIELD])

			//-- Melhoria apos testes do Ricardo Stanquevis. 12/05/2022, by Dener
			//If AllTrim( oMdlDevol:GetValue(aCpDevol[11, MODEL_FIELD_IDFIELD]) ) == "SIM"
			If AllTrim( oMdlDevol:GetValue(aCpDevol[11, 3 ]) ) == "SIM"
				aAdd(aCadastro, {cProdAtual, cProdNovo, "Devolução"})
			EndIf

			//-- Pega informacoes da Devolucao para apontar perda
			nQuant   := oMdlDevol:GetValue(aCpDevol[06, MODEL_FIELD_IDFIELD])
			nPesoBrt := oMdlDevol:GetValue(aCpDevol[07, MODEL_FIELD_IDFIELD])
			If Empty(nQuant)
				Loop
			EndIf
			cArmDest := oMdlDevol:GetValue(aCpDevol[13, MODEL_FIELD_IDFIELD])
			cLoteCTL := oMdlDevol:GetValue(aCpDevol[03, MODEL_FIELD_IDFIELD])
			cNumLote := oMdlDevol:GetValue(aCpDevol[04, MODEL_FIELD_IDFIELD])
			dDtValid := oMdlDevol:GetValue(aCpDevol[05, MODEL_FIELD_IDFIELD])

			cMotivo := ProxMotivo(cMotivo)

			aAdd(aAptPerda, {cOP, cProdAtual, cArmOrig, cTipo, cMotivo, nQuant, cProdNovo, cArmDest, cLoteCTL, cNumLote, dDtValid, nPesoBrt})
		EndIf
	Next nI
	oMdlDevol:GoLine( nLineaUX )

	//-- SUCATAS
	nLineaUX := oMdlSucat:nLine
	For nI := 1 To oMdlSucat:GetQtdLine()
		oMdlSucat:GoLine( nI )
	
		If !oMdlSucat:IsDeleted() //.And. !Empty(oMdlSucat:GetValue(aCpSucat[01, MODEL_FIELD_IDFIELD]))
			//-- Pega novo produto da Sucata para cadastrar
	   
			//cProdNovo := oMdlSucat:GetValue(aCpSucat[11, MODEL_FIELD_IDFIELD])
			cProdNovo := oMdlSucat:GetValue(aCpSucat[ nPosPrSuc, MODEL_FIELD_IDFIELD])
			If Empty(cProdNovo)
				Loop
			EndIf
			//-- Pega produto atual
			cProdAtual := oMdlSucat:GetValue(aCpSucat[01, MODEL_FIELD_IDFIELD])

			//-- Pega armazem origem
			cArmOrig := oMdlSucat:GetValue(aCpSucat[02, MODEL_FIELD_IDFIELD])

			//-- Pega informacoes da Sucata para apontar perda
			nQuant := oMdlSucat:GetValue(aCpSucat[06, MODEL_FIELD_IDFIELD])
			If Empty(nQuant)
				Loop
			EndIf
			cArmDest := oMdlSucat:GetValue(aCpSucat[ nPosLcSuc, MODEL_FIELD_IDFIELD])
			//cArmDest := oMdlSucat:GetValue(aCpSucat[12, MODEL_FIELD_IDFIELD])
			cLoteCTL := oMdlSucat:GetValue(aCpSucat[03, MODEL_FIELD_IDFIELD])
			cNumLote := oMdlSucat:GetValue(aCpSucat[04, MODEL_FIELD_IDFIELD])
			dDtValid := oMdlSucat:GetValue(aCpSucat[05, MODEL_FIELD_IDFIELD])

			cMotivo := ProxMotivo(cMotivo)

			aAdd(aAptPerda, {cOP, cProdAtual, cArmOrig, cTipo, cMotivo, nQuant, cProdNovo, cArmDest, cLoteCTL, cNumLote, dDtValid, 0})
		EndIf
	Next nI
	oMdlSucat:GoLine( nLineaUX )

	//###################################################################################
	//-- Realizacao dos cadastros
	//###################################################################################
	
	ProcRegua(7)

	For nI := 1 To Len(aCadastro)
		IncProc("Incluindo produto [" + AllTrim(aCadastro[nI,2]) + "]...")

		//-- USER FUNCTION que grava a inclusao dos novos produtos
		lRet := U_REPCPA02(aCadastro[nI,1], aCadastro[nI,2])
	
		If !lRet
			//cCadErros += IIf(Empty(cCadErros), aCadastro[nI,3], +" e/ou "+aCadastro[nI,3])

			//-- Melhoria na mensagem de erro do cadastro automatico apos testes do Ricardo Stanquevis. 12/05/2022, by Dener
			If Empty( cCadErros )
				cCadErros += aCadastro[nI,3]
			ElseIf !( aCadastro[nI,3] $ cCadErros )
				cCadErros += " e " + aCadastro[nI,3]
			EndIf 
		EndIf 
	Next nI

	If !Empty(cCadErros)
		oMdlMast:GetModel():SetErrorMessage(oMdlMast:CID, oMdlMast:ADATAMODEL[1,5,1], oMdlMast:CID, oMdlMast:ADATAMODEL[1,5,1], "CADASTRO", "Erro na inclusão automatica dos produtos da "+cCadErros+".", "Faça a inclusão dos produtos manualmente antes do apontamento da perda.")
	EndIf

	//###################################################################################
	//-- Realizacao da gravacao das perdas
	//###################################################################################

	If lRet .And. Empty(cCadErros)
		IncProc("Apontando Retorno para Estoque e Sucata...")
	
		//-- USER FUNCTION que grava as perdas
		//lRet := U_REPCPA03(aAptPerda, @cErro)
		lRet := U_REPCPA09(aAptPerda, @cErro)

		If !lRet .And. !Empty(cErro)
			oMdlMast:GetModel():SetErrorMessage(oMdlMast:CID, oMdlMast:ADATAMODEL[1,5,1], oMdlMast:CID, oMdlMast:ADATAMODEL[1,5,1], "PERDA", cErro, "Faça o apontamento de Retorno para Estoque e/ou Sucata manualmente.")
		EndIf

	EndIf
	
Return lRet


/*/{Protheus.doc} afterView
Funcao que habilita o F4
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 10/01/2022
@param oView, object, View
/*/
Static Function afterView(oView)
	SetKey( VK_F4, { || ShowF4() } )
Return


/*/{Protheus.doc} ShowF4
Funcao que mostra a diolag do F4 pra selacao dos LOTES
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 10/01/2022
/*/
Static Function ShowF4()
	Local cCampo     := ReadVar()
	Local oViewActiv := Nil
	Local oModel     := Nil
	Local oMdlDev    := Nil
	Local oMdlSuc    := Nil
	Local nNBackup   := n //-- Backup da linha posicionada

	If cCampo $ "M->BC_LOTECTL" .Or. cCampo $ "M->BC_NUMLOTE"
		oViewActiv := FwViewActive()
		oModel     := oViewActiv:GetModel()

		If oViewActiv:ACURRENTSELECT[1] == "VIEW_DEV" .Or. oViewActiv:ACURRENTSELECT[1] == "DEVSTRU"
			oMdlDev := oModel:GetModel("DEVSTRU")

			aHeader := oMdlDev:aHeader
			aCols	:= oMdlDev:aCols
			n       := oMdlDev:nLine
		ElseIf oViewActiv:ACURRENTSELECT[1] == "VIEW_SUC" .Or. oViewActiv:ACURRENTSELECT[1] == "SUCSTRU"
			oMdlSuc := oModel:GetModel("SUCSTRU")

			aHeader := oMdlSuc:aHeader
			aCols	:= oMdlSuc:aCols
			n       := oMdlSuc:nLine
		EndIf

		nPosLote   := Ascan(aHeader,{|x| AllTrim(x[2])=="BC_NUMLOTE"})
		nPosLotCtl := Ascan(aHeader,{|x| AllTrim(x[2])=="BC_LOTECTL"})
		nPosDValid := Ascan(aHeader,{|x| AllTrim(x[2])=="BC_DTVALID"})

		If oViewActiv:ACURRENTSELECT[1] == "VIEW_DEV" .Or. oViewActiv:ACURRENTSELECT[1] == "DEVSTRU"
			F4Lote( ,,, "A685", oMdlDev:aCols[n, 01], oMdlDev:aCols[n, 02],,,, cOP,,, )
		ElseIf oViewActiv:ACURRENTSELECT[1] == "VIEW_SUC" .Or. oViewActiv:ACURRENTSELECT[1] == "SUCSTRU"
			F4Lote( ,,, "A685", oMdlSuc:aCols[n, 01], oMdlSuc:aCols[n, 02],,,, cOP,,, )
		EndIf

		oViewActiv:Refresh(oViewActiv:ACURRENTSELECT[1])

		aHeader := {}
		aCols   := {}
	EndIf
	n := nNBackup

Return


/*/{Protheus.doc} ProxMotivo
Retorna o proximo codigo de motivo de perda, 
pois no apontamento nao pode ter motivos iguais 
para o mesmo produto que esta sendo apontado como perda
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 24/01/2022
@param cMotivo, character, Codigo do motivo de perda atual
@return character, Retorna o proximo codigo de motivo de perda
/*/
Static Function ProxMotivo(cMotivo)
    Local cRet := Soma1(cMotivo)

    DbSelectArea("CYO")
    CYO->(DbSetOrder(1)) //-- CYO_FILIAL+CYO_CDRF
    If !CYO->(DbSeek(xFilial()+cRet))
		RecLock("CYO", .T.)
			CYO->CYO_FILIAL := xFilial("CYO")
			CYO->CYO_CDRF   := cRet
			CYO->CYO_DSRF   := Padr("CORTE BOBINA", TamSX3("CYO_DSRF")[1])
			CYO->CYO_LGRFMP := .T.
			CYO->CYO_LGRT   := .F.
		CYO->(MsUnLock())
    EndIf

Return cRet


/*/{Protheus.doc} AutoCalc
Funcao que realiza o calculo das quantidades de sobras das bobinas
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 04/02/2022
@param oModel, object, Modelo de dados
/*/
Static Function AutoCalc(oModel)
    Local aParamBox  := {}
    Local cWhen      := ".F."
    Local lCanSave   := .F.
	Local lUserSave  := .F.
	Local cCodMP     := ""
	Local nLargMP    := ""
	Local cCadBak	 := cCadastro
	Local lCalcula	 := Nil
	Local oMdlDevol  := oModel:GetModel("DEVSTRU")
	Local oMdlSucat  := oModel:GetModel("SUCSTRU")
	Local oViewActiv := FwViewActive()
	Local nI
	Local nValue
	Local nPos

	cCadastro := "Calculo Automatico"
	
	If oViewActiv:ACURRENTSELECT[01] == "VIEW_DEV" .Or. oViewActiv:ACURRENTSELECT[01] == "DEVSTRU"
		cCodMP := oMdlDevol:aCols[oMdlDevol:nLine, 01]
	ElseIf oViewActiv:ACURRENTSELECT[01] == "VIEW_SUC" .Or. oViewActiv:ACURRENTSELECT[01] == "SUCSTRU"
		cCodMP := oMdlSucat:aCols[oMdlSucat:nLine, 01]
	EndIf
	
	//-- Parametros
	aAdd(aParamBox, {1, "Produto Acabado"             , cCodPai     , "",             "", "", cWhen, 70, .T.})
	aAdd(aParamBox, {1, "Materia Prima"               , cCodMP      , "",             "", "", cWhen, 70, .T.})
	aAdd(aParamBox, {1, "Largura Retorno para Estoque", PadR("0", 4), "", "U_REPCPA1V()", "", ""   , 30, .F.})
	aAdd(aParamBox, {1, "Largura Sucata"              , PadR("0", 4), "", "U_REPCPA1V()", "", ""   , 30, .F.})

	If !ParamBox(aParamBox, "", {}, {|| lCalcula := ClickOK()}, , , , , , , lCanSave, lUserSave)   
		Return
	EndIf

	If lCalcula
		nLargMP := u_xGetDimen(MV_PAR02, "N")[03]

		//-- RETORNO PARA ESTOQUE
		nLineaUX := oMdlDevol:nLine
		For nI := 1 To oMdlDevol:GetQtdLine()
			oMdlDevol:GoLine(nI)

			nPos := aScan( aCodMPs, { |x| x[1]+x[4]+x[5] = oMdlDevol:GetValue(oMdlDevol:AHEADER[01, 02]) + oMdlDevol:GetValue(oMdlDevol:AHEADER[03, 02]) + oMdlDevol:GetValue(oMdlDevol:AHEADER[04, 02]) } )
			If nPos > 0 .And. oMdlDevol:GetValue(oMdlDevol:AHEADER[01, 02]) == cCodMP
				nValue := ( ( Val(MV_PAR03) / nLargMP ) * aCodMPs[nPos, 07] )
				oMdlDevol:SetValue( "BC_QUANT", Round(nValue, 1) )
				oMdlDevol:SetValue( "XX_LARG" , Val(MV_PAR03) )
			EndIf
		Next nI
		oMdlDevol:GoLine(nLineaUX)

		//-- SUCATA
		nLineaUX := oMdlSucat:nLine
		For nI := 1 To oMdlSucat:GetQtdLine()
			oMdlSucat:GoLine(nI)

			nPos := aScan( aCodMPs, { |x| x[1]+x[4]+x[5] = oMdlSucat:GetValue(oMdlSucat:AHEADER[01, 02]) + oMdlSucat:GetValue(oMdlSucat:AHEADER[03, 02]) + oMdlSucat:GetValue(oMdlSucat:AHEADER[04, 02]) } )
			If nPos > 0 .And. oMdlSucat:GetValue(oMdlSucat:AHEADER[01, 02]) == cCodMP
				nValue := ( ( Val(MV_PAR04) / nLargMP ) * aCodMPs[nPos, 07] )
				oMdlSucat:SetValue("BC_QUANT", Round(nValue, 1) )
				oMdlSucat:SetValue("XX_LARG" , Val(MV_PAR04) )
			EndIf
		Next nI
		oMdlSucat:GoLine(nLineaUX)
		
	EndIf
	cCadastro := cCadBak

Return


/*/{Protheus.doc} REPCPA1V
Validacoes gerais do parametros da funcao de Auto Calculo
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 04/02/2022
@return logical, Retorno logico
/*/
User Function REPCPA1V()
    Local cVar    := ReadVar()
	Local nLargPA := u_xGetDimen(MV_PAR01, "N")[03]
	Local nLargMP := u_xGetDimen(MV_PAR02, "N")[03]
	Local nSobra  := nLargMP - nLargPA
	Local lRet    := .T.

	If cVar == "MV_PAR03" 
		If !Empty(Val(MV_PAR03))
			If Val(MV_PAR03) > nSobra
				MsgInfo("A <b>Lagura do Retorno para Estoque</B> não pode ser maior que <b>"+cValToChar(nSobra)+"mm</b>.", "Atenção!")
				lRet := .F.
			Else
				MV_PAR04 := PadR( cValToChar( nSobra - Val(MV_PAR03) ), 4 )
			EndIf
		EndIf
	ElseIf cVar == "MV_PAR04"
		If !Empty(Val(MV_PAR04))
			If Val(MV_PAR04) > nSobra
				MsgInfo("A <b>Lagura da Sucata</B> não pode ser maior que <b>"+cValToChar(nSobra)+"mm</b>.", "Atenção!")
				lRet := .F.
			Else
				MV_PAR03 := PadR( cValToChar( nSobra - Val(MV_PAR04) ), 4 )
			EndIf
		EndIf
	EndIf

Return lRet


/*/{Protheus.doc} ClickOK
Validacao de Tudo ok da funcao de Auto Calculo
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 04/02/2022
@return logical, Retorno logico
/*/
Static Function ClickOK()
	Local lRet := .T.

	If Empty(Val(MV_PAR03)) .And. Empty(Val(MV_PAR04))
		MsgInfo("Para realizar do calculo automaticamente a largura do Retorno para Estoque e/ou Sucata devem estar preenchidas.", "Atenção!")
		lRet := .F.
	EndIf

Return lRet


/*/{Protheus.doc} REPCPA7P
Funcao que carrega os parametros da impressao de etiquetas
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 03/08/2022
/*/
Static Function ParEtiq(oModel)
	Pergunte("REPCPA1P", .T.)
Return


/*/{Protheus.doc} Etiqueta
Funcao de impressao das etiquetas apos a confirmacao
do apontamento de retorno para estoque
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 04/08/2022
/*/
Static Function Etiqueta()
    Local aAreaAnt := GetArea()
    Local aAreaSBC := SBC->(GetArea())
    Local aAreaSD3 := SD3->(GetArea())
    Local aParam   := {}
	Local aInfo    := {}
    Local cOrdProd := Padr(cOP, TamSX3("BC_OP")[1])
	Local nI       := 0

    DbSelectArea("SBC")
    DbSelectArea("SD3")

    SBC->(DbSetOrder(1))
    SD3->(DbSetOrder(4))

    If SBC->(DbSeek(xFilial() + cOrdProd))
        While SBC->(!Eof()) .And. SBC->(BC_FILIAL + BC_OP) == xFilial() + cOrdProd
            aInfo := {}

            If SD3->(DbSeek(xFilial() + SBC->BC_SEQSD3))
                aAdd(aInfo, SD3->D3_COD)     //-- 01 - Produto
                aAdd(aInfo, SD3->D3_LOCAL)   //-- 02 - Armazem
                aAdd(aInfo, SD3->D3_QUANT)   //-- 03 - Peso Liquido
                aAdd(aInfo, SBC->BC_XPESBRT) //-- 04 - Peso Bruto (Tabela SBC)
                aAdd(aInfo, SD3->D3_LOTECTL) //-- 05 - Lote
                aAdd(aInfo, SD3->D3_NUMLOTE) //-- 06 - SubLote
                aAdd(aInfo, SD3->D3_DTVALID) //-- 07 - Data de validade
                aAdd(aInfo, dDataBase)       //-- 08 - Data de fabricacao
                aAdd(aInfo, MV_PAR02)        //-- 09 - Quantidade de etiquetas
                aAdd(aInfo, MV_PAR03)        //-- 10 - Local de impressao
            EndIf

			aAdd(aParam, aInfo)

            SBC->(DbSkip())
        EndDo
    EndIf

	//-- Imprime as etiquetas
	For nI := 1 To Len(aParam)
		U_REPCPR1A(aParam[nI])
	Next Ni

    RestArea(aAreaSD3)
    RestArea(aAreaSBC)
    RestArea(aAreaAnt)

Return


/*/{Protheus.doc} EtiqSZ9
Busca dados para Impressao de Etiqueta - Tabela SZ9
@type function
@version 1.0
@author Marcos P.Aversa
@since 02/02/2023
/*/
User Function EtiqSZ9( cOP )
    Local aAreaAnt := GetArea()
    Local aAreaSZ9 := SZ9->(GetArea())
    Local aParam   := {}
	Local aInfo    := {}
    Local cOrdProd := Padr(cOP, TamSX3("BC_OP")[1])
	Local nI       := 0
    Local cLocSuc  := GetMv("RE_ARMSUC", .F., "09") //-- Define o armazem de sucata


    DbSelectArea("SZ9")
    SZ9->(DbSetOrder(1))

    If SZ9->(DbSeek( xFilial("SZ9") + cOrdProd))
        While SZ9->(!Eof()) .And. SZ9->(Z9_FILIAL + Z9_OP) == xFilial("SZ9") + cOrdProd
			//-- Não Imprimir Etiquetas p/Sucata
		    If SZ9->Z9_LOCDES == cLocSuc
	            SZ9->(DbSkip())
				Loop			
			Endif

            aInfo := {}
            aAdd(aInfo, SZ9->Z9_PRODDES ) //-- 01 - Produto
            aAdd(aInfo, SZ9->Z9_LOCDES )  //-- 02 - Armazem
            aAdd(aInfo, SZ9->Z9_QTDDES )  //-- 03 - Peso Liquido
            aAdd(aInfo, SZ9->Z9_QTDBDES)  //-- 04 - Peso Bruto 
            aAdd(aInfo, SZ9->Z9_LOTDES )  //-- 05 - Lote
            aAdd(aInfo, SZ9->Z9_SBLTDES ) //-- 06 - SubLote
            aAdd(aInfo, SZ9->Z9_DVLDES ) //-- 07 - Data de validade
            aAdd(aInfo, dDataBase)       //-- 08 - Data de fabricacao
            aAdd(aInfo, MV_PAR02)        //-- 09 - Quantidade de etiquetas
            aAdd(aInfo, MV_PAR03)        //-- 10 - Local de impressao

			aAdd(aParam, aInfo)

            SZ9->(DbSkip())
        EndDo
    EndIf

	//-- Imprime as etiquetas
	For nI := 1 To Len(aParam)
		U_REPCPR1A(aParam[nI])
	Next Ni

    RestArea(aAreaSZ9)
    RestArea(aAreaAnt)

Return

/*/{Protheus.doc} fRetQtdEmp
Retorna a Qtd. Empenhado do Lote/Sub Lote
@type function
@version 1.0
@author Marcos Aversa - Dothink
@since 08/2023
@param cOp, character, Numero da OP
@param cProd, character, Código do Produto
@param cLocal, character, Local
@param cLoteCtl, character, Lote
@param cNumLt, character, Sub-Lote
@return variant, NIL
/*/
Static Function fRetQtdEmp( cOp, cProd, cLocal, cLoteCtl, cNumLt )  
	local aArea  := GetArea()
	local nxEmp  := 0
	local cQuery := ""

	cQuery  := " SELECT D4_QUANT "+ CRLF
	cQuery  += " FROM " + RetSqlName("SD4") + " D4 "+ CRLF
	cQuery  += " WHERE D4.D_E_L_E_T_ = ' ' "+ CRLF
	cQuery  += " AND D4_FILIAL = '"+ xFilial("SD4") + "' "+ CRLF
	cQuery  += " AND D4_OP = '" + cOp + "' "+ CRLF
	cQuery  += " AND D4_COD = '" + cProd + "' "+ CRLF
	cQuery  += " AND D4_LOCAL = '" + cLocal +"' "+ CRLF
	cQuery  += " AND D4_LOTECTL = '"+ cLoteCtl + "' "+ CRLF
	cQuery  += " AND D4_NUMLOTE = '" + cNumLt + "' "+ CRLF
	cQuery  += " AND D4_QUANT <> 0 "+ CRLF

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "XDEV", .F., .T.)
	If XDEV->( !Eof() )
	   nxEmp := XDEV->D4_QUANT
	Endif
    XDEV->(dbCloseArea() )

	RestArea( aArea )
Return nxEmp


/*/{Protheus.doc} fQtdOutraGrid
Percorre aCols e Retorna Quantidade Informada para Chave Passada
@type function
@version 1.0 
@author Marcos Aversa - Dothink
@since 05/09/2023
@param asCols, array, aCols
@param cProd, character, Produto Origem - Chave Pesquisa
@param cLocal, character, Local Origem - Chave Pesquisa
@param cLoteCtl, character, Lote Origem - Chave Pesquisa
@param cNumLt, character, Sub-Lote  Origem - Chave Pesquisa
@param nsPosProd, numeric, Posicao Destino
@param nsPosLocal, numeric, Local Destino
@param nsPosLote, numeric, Lote Destino
@param nsPosSbLt, numeric, Sub Lote Destino
@param nsPosQtd, numeric, Quantidade Destino
@return numeric, Quantidades informadas
/*/
Static Function fQtdOutraGrid( asCols, cProd, cLocal, cLoteCtl, cNumLt,  nsPosProd, nsPosLocal, nsPosLote, nsPosSbLt, nsPosQtd  )
	local nsQtd := 0 
	local nX	   := 1
	//Verifica se Linha esta Deletada
	local nPosDel  := Len( asCols[1])
	local cChave   := " "

	cChave := cProd + cLocal + cLoteCtl + cNumLt 

	For nX := 1 to Len( asCols )
		If !asCols[ nX, nPosDel ] .AND.  asCols[ nx, nsPosQtd ] != 0
			If cChave == asCols[ nx, nsPosProd ] + ;
						 asCols[ nx, nsPosLocal] + ;
					     asCols[ nx, nsPosLote ] + ;
					     asCols[ nx, nsPosSbLt ]
				nsQtd += asCols[ nx, nsPosQtd ]  						 
			Endif
		Endif
	Next nx
	
Return nsQtd
