#Include 'Protheus.ch'
#Include 'FWMVCDEF.CH'

Static lCopia := .F. 
//-------------------------------------------------------------------
/*/{Protheus.doc} REPLAA03
Cadastro Amarração Comissão Vs Grupo de Produtos

@author TOTVS Serra do Mar [JOSE CARLOS]
@since 27/06/2016
@version P12
/*/
//-------------------------------------------------------------------
User Function REPLAA03()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('SZ0')
oBrowse:SetDescription('Cadastro Amarração Comissão Vs Grupo de Produtos')
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE 'Pesquisar'  ACTION 'PesqBrw'          OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.REPLAA03' OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.REPLAA03' OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.REPLAA03' OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.REPLAA03' OPERATION 5 ACCESS 0
//ADD OPTION aRotina TITLE 'Copia'      ACTION 'VIEWDEF.REPLAA03' OPERATION 9 ACCESS 0
ADD OPTION aRotina TITLE 'Copia'      ACTION 'U_FA03COPIA()' OPERATION 7 ACCESS 0

Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruSZ0 := FWFormStruct( 1, 'SZ0', /*bAvalCampo*/,/*lViewUsado*/ )
Local oStruSZ1 := FWFormStruct( 1, 'SZ1', /*bAvalCampo*/,/*lViewUsado*/ )
//Local oStruTab1	:= FWFormStruct( 2, 'SZ1' ) 
Local oModel

Local aAux := {}
aAux := FwStruTrigger(;
'Z0_CODVEND' ,;
'Z0_CODVEND' ,;
'U_LOADSBM()',;
.F.,;
'',;
0,;
'')

oStruSZ0:AddTrigger( ;
aAux[1] , ; // [01] identificador (ID) do campo de origem
aAux[2] , ; // [02] identificador (ID) do campo de destino
aAux[3] , ; // [03] Bloco de código de validação da execução do gatilho
aAux[4] ) // [04] Bloco de código de execução do gatilho

// Altero propriedades dos campos da estrutura, no caso colocando cada campo no seu grupo
//
// SetProperty( <Campo>, <Propriedade>, <Valor> )
//
// Propriedades existentes para View (lembre-se de incluir o FWMVCDEF.CH):
//
//	MODEL_FIELD_TITULO 
//	MODEL_FIELD_TOOLTIP 
//	MODEL_FIELD_IDFIELD 
//	MODEL_FIELD_TIPO    
//	MODEL_FIELD_TAMANHO 
//	MODEL_FIELD_DECIMAL 
//	MODEL_FIELD_VALID   
//	MODEL_FIELD_WHEN    
//	MODEL_FIELD_VALUES  
//	MODEL_FIELD_OBRIGAT 
//	MODEL_FIELD_INIT    
//	MODEL_FIELD_KEY     
//	MODEL_FIELD_NOUPD   
//	MODEL_FIELD_VIRTUAL 
//
//oStruZA0:SetProperty( '*'         , MODEL_FIELD_NOUPD, .T. ) 

//oStruTab1:RemoveField( 'Z1_CODVEND' ) 
//oStruTab1:RemoveField( 'Z1_DESCVEN' )  

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('IDREPLAA03', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
//oModel := MPFormModel():New('COMP011MODEL', /*bPreValidacao*/, { |oMdl| COMP011POS( oMdl ) }, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'MODEL_CAB', /*cOwner*/, oStruSZ0, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

oModel:AddGrid('MODEL_IT','MODEL_CAB' , oStruSZ1,{||.t.}/*{|oModelGrid,nLine,cAction| BFEFDCopy( oModelGrid,nLine,cAction )}*/,,,,/*{||aGrid1}*/)
oModel:SetRelation( 'MODEL_IT', { 	{ "Z1_FILIAL", "xFilial('SZ1')" },;
									{ "Z1_CODVEND", "Z0_CODVEND" } },;
         							SZ1->( IndexKey( 1 ) ) )  

// Liga o controle de nao repeticao de linha
//oModel:GetModel('MODEL_IT'):SetUniqueLine( { 'Z1_CODGRUP' } )
oModel:GetModel( 'MODEL_IT' ):SetUniqueLine( { 'Z1_CODGRUP' } )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( 'Modelo de Dados' )

// Adiciona a descricao do Componente do Modelo de Dados
//oModel:GetModel( 'SZ1MASTER' ):SetDescription( 'Dados de Comissão' )

// Liga a validação da ativacao do Modelo de Dados
//oModel:SetVldActivate( { |oModel| COMP011ACT( oModel ) } )

oModel:SetPrimaryKey({'Z0_FILIAL','Z0_CODVEND'}) 

Return oModel


//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   	:= FWLoadModel( 'REPLAA03' )
Local oView		:= FWFormView():New()
// Cria a estrutura a ser usada na View
Local oStruTab	:= FWFormStruct( 2, 'SZ0' )	
Local oStruTab1	:= FWFormStruct( 2, 'SZ1' ) 	
//Local oStruZA0 := FWFormStruct( 2, 'ZA0', { |cCampo| COMP11STRU(cCampo) } )
Local oView

oView:SetModel( oModel )

oView:AddField('VIEW_CAB',oStruTab,'MODEL_CAB' ) 

oView:AddGrid('VIEW_IT1',oStruTab1,'MODEL_IT' ) 
                                                  
//oStruTab:RemoveField( 'Z1_CODGRUP' )  
//oStruTab:RemoveField( 'Z1_DESCGRU' ) 
//oStruTab:RemoveField( 'Z1_PERC' )

oStruTab1:RemoveField( 'Z1_CODVEND' ) 
oStruTab1:RemoveField( 'Z1_DESCVEN' )
                                     
oView:EnableTitleView('VIEW_CAB','Vendedor') 
oView:EnableTitleView('VIEW_IT1','Comissão')
                                      
oView:CreateHorizontalBox('TELA' ,25) 
oView:CreateHorizontalBox('TELA1',75) 

oView:setOwnerView('VIEW_CAB','TELA') 
oView:setOwnerView('VIEW_IT1','TELA1')

Return oView

User Function LOADSBM()
Local aAreaAtu	:= GetArea()
Local oModel	:= FWModelActive()
Local oModelIT	:= oModel:GetModel('MODEL_IT')
Local cAliasQuery	:= GetNextAlias() 
Local cCodVend	:= M->Z0_CODVEND
Local nPerc		:= 0
Local nOperation := oModel:GetOperation()

//Alert('nOperation' + cValToChar(nOperation) )
If !lCopia	// Copia
	SA3->(DbSelectArea("SA3"))
	SA3->(DbSetOrder(1))
	If SA3->( DbSeek(xFilial('SA3') + cCodVend ) )
		nPerc	:= SA3->A3_COMIS
	EndIf
	
	BeginSql Alias cAliasQuery
		SELECT BM_GRUPO,BM_DESC
		FROM 
		%table:SBM% 
		WHERE
			BM_FILIAL = %xFilial:SBM%
			AND BM_TIPGRU <> ' '
		AND %notdel%
	EndSql
	
	(cAliasQuery)->(dbSelectArea(cAliasQuery))
	(cAliasQuery)->(dbGoTop())
	
	If (cAliasQuery)->(!Eof())
		While (cAliasQuery)->(!Eof())
			oModelIT:LoadValue('Z1_CODGRUP'	,(cAliasQuery)->BM_GRUPO)
			oModelIT:LoadValue('Z1_DESCGRU',(cAliasQuery)->BM_DESC)
			oModelIT:LoadValue('Z1_PERC',nPerc) 	
			(cAliasQuery)->(DbSkip())
			If (cAliasQuery)->(!Eof())
				oModelIT:AddLine()
			EndIf
		EndDo
	EndIF
	
	(cAliasQuery)->(DbSelectArea(cAliasQuery))
	(cAliasQuery)->(dbCloseArea())
	
	oModelIT:GoLine(1)
Else
	lCopia := .F. 
EndIf
 
RestArea(aAreaAtu)
Return(M->Z0_CODVEND)

User Function FA03COPIA()

Local cTitulo		:= 'Copia'
Local nOperation 	:= 9 // Define o modo de operacao como copia
lCopia := .T.

FWExecView(cTitulo,'VIEWDEF.REPLAA03',nOperation,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,/*nPercReducao*/)

Return()