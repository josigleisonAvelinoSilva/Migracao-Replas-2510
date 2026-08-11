// |------------------------------------------------------------
// | Rotina | REPLA900 | Autor | Robson Gonçalves | 10/02/2020 |
// |------------------------------------------------------------
// | Descr. | Rotina para cadastrar o saldo consolidado do     |
// |        | banco e data. O uso desta tabela será alimentando|
// |        | manualmente e os serviços de BI irão consultar   |
// |        | estes dados.                                     |
// |------------------------------------------------------------
// | Uso    | Replas                                           |
// |------------------------------------------------------------

#Include 'Protheus.ch'
#Include 'FwMVCDef.ch'

#DEFINE cTituloRotina '® Consolidação de saldo bancário'
 
User Function REPLA900()
	Local lTeste := .F.
	Local oBrowse
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias( 'SZ3' )
	oBrowse:SetDescription( cTituloRotina )
	oBrowse:SetTotalDefault('Z3_BANCO','COUNT','Total de Registros')
	oBrowse:Activate()
	
	/* Este bloco de instrução é para não haver "warnning" de compilação. */
	If lTeste
		MenuDef()
		ViewDef()
		ModelDef()
	Endif
Return

Static Function MenuDef()
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE "Pesquisar"  ACTION 'AxPesqui'         OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar" ACTION 'VIEWDEF.REPLA900' OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"    ACTION 'VIEWDEF.REPLA900' OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"    ACTION 'VIEWDEF.REPLA900' OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"    ACTION 'VIEWDEF.REPLA900' OPERATION 5 ACCESS 0 
Return aRotina

Static Function ModelDef()
	Local oStruct := FWFormStruct( 1 ,"SZ3" , /*bAvalCampo*/ , /*lViewUsado*/ )
	Local oModel
	oModel := MPFormModel():New( "A900MODEL" , /*bPre*/ , { | oModel | U_A900TudOk( oModel ) } /*bPost*/ , /*bCommit*/ , /*bCancel*/ )
	oModel:AddFields( "SZ3MASTER" , NIL, oStruct , /*bPre*/ , /*bPost*/ , /*bLoad*/ )
	oModel:SetDescription( '® Cadastre o saldo consolidado do banco em questão' /*cDescricao*/ )
	oModel:GetModel( "SZ3MASTER" ):SetDescription( '® Consolidação do saldo' )
Return oModel

Static Function ViewDef()
	Local oModel := FWLoadModel( "REPLA900" )
	Local oStruct := FWFormStruct( 2 , "SZ3" , /*bAvalCampo*/ , /*lViewUsado*/ )
	Local oView
	
	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( "VIEW_SZ3" , oStruct, "SZ3MASTER" )
	oView:EnableTitleView( "VIEW_SZ3" , '® Informe os dados abaixo' )
	oView:CreateHorizontalBox( "TELASZ3" , 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
	oView:SetOwnerView( "VIEW_SZ3" , "TELASZ3" )
Return oView

User Function A900TudOk( oModel )
	Local lRet := .T.
	Local oMdl
	
	If oModel:GetOperation() == MODEL_OPERATION_INSERT
		oMdl := oModel:GetModel('SZ3MASTER')
		dbSelectArea( 'SZ3' )
		dbSetOrder( 1 )
		If SZ3->( MsSeek( xFilial( 'SZ3' ) + oMdl:GetValue('Z3_BANCO') + Dtos( oMdl:GetValue('Z3_DATA') ) ) )
			lRet := .F.
			Help(,,cTituloRotina,,'O código deste banco na data informada já está cadastrado.',1,0,,,,,,{"Informe outra data ou outro código de banco."})
		Endif
	Endif
Return( lRet )