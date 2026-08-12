#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

User Function REESTA12()
	Local bLeg := {|| fLegenda() }
	Private cCadastro    := "Manutenção de Romaneio"
	
    oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("SZE")
	oBrowse:SetDescription( "Manutenção de Romaneio" )
	//-- Legendas
	oBrowse:AddLegend( "ZE_STATUS == '1'", "GREEN" , "Etiq.Impressa" )
	oBrowse:AddLegend( "ZE_STATUS == '2'", "RED"   , "Etiq.Nao Impressa" )

	oBrowse:AddButton( "Legenda", bLeg )	
	oBrowse:Activate()

Return

Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE "Visualizar"      ACTION "VIEWDEF.REESTA12" OPERATION MODEL_OPERATION_VIEW   ACCESS 0
    ADD OPTION aRotina TITLE "Incluir"         ACTION "VIEWDEF.REESTA12" OPERATION MODEL_OPERATION_INSERT ACCESS 0   
	ADD OPTION aRotina TITLE "Alterar"         ACTION "VIEWDEF.REESTA12" OPERATION MODEL_OPERATION_UPDATE ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"         ACTION "VIEWDEF.REESTA12" OPERATION MODEL_OPERATION_DELETE ACCESS 0    


Return aRotina    

Static Function ModelDef()
	Local oModel 	:= NIL
	Local oStrSZE	:= FWFormStruct( 1, "SZE" )
	//Local cVldOP    := " "	
	//Local bPosTOk := {|oTOkModel| TudoOk(oTOkModel)}	
	//-- Criando o modelo e os relacionamentos
    /*
	cVldCli := "ExistCpo('SA1',M->FN8_CLIENT+RTRIM(M->FN8_LOJA),,,,!EMPTY(M->FN8_LOJA))"
	bVldCli := FWBuildFeature( STRUCT_FEATURE_VALID, cVldCli )
	oStruLote:SetProperty('FN8_CLIENT',MODEL_FIELD_VALID,bVldCli)
    */
    //cVldOP          := ExistCPO( 'SC2', M->ZE_FILIAL + M->ZE_OP + M->ZE_ITEM )

	oModel := MPFormModel():New("Romaneio",/*bPre*/,	{ |oModel| PosVld(oModel) },/*bCommit*/,/*bCancel*/)
	oModel:AddFields( "SZEMASTER", , oStrSZE )
	oModel:SetPrimaryKey( { 'ZE_FILIAL', 'ZE_OP','ZE_ITEM' } )
	oModel:SetDescription("Romaneio")
	oModel:GetModel( "SZEMASTER" ):SetDescription( "Romaneio" )

Return oModel

/*
	Ao Clicar em Confirmar - Pos validação do Modelo
*/
Static Function PosVld(oModel)
	Local lRet		:= .T.
	Local nOperation:= oModel:GetOperation()
    Local cFil      := " "  
	Local cOP       := " "
	Local cItemOP   := " "
	Local aArea     := GetArea()
	Local aAreaSC2  := SC2->( GetArea() )	

	SC2->( dbSetOrder( 1 ))

	cFil 	:=	FWCodFil()
    cOP  	:= oModel:GetModel("SZEMASTER"):GetValue("ZE_OP")
	cItemOP	:= oModel:GetModel("SZEMASTER"):GetValue("ZE_ITEM")  

	IF nOperation == MODEL_OPERATION_UPDATE .OR.;
		nOperation == MODEL_OPERATION_INSERT		
		IF !SC2->( dbSeek( cFil + cOp + cItemop ))
			Help( ,, "Help",, "Op não encontrada, Favor verificar !!!", 1, 0 )
			lRet := .F.	   
		Endif
	Endif

	IF lRet
		Do Case
		Case nOperation == MODEL_OPERATION_INSERT
					    
		Case nOperation == MODEL_OPERATION_UPDATE
		EndCase
	ENDIF

	RestArea( aAreaSC2 )
	RestArea( aArea )

Return lRet	



Static Function ViewDef()
	Local oView   := NIL
	Local oModel  := ModelDef()
	Local oStrSZE := FWFormStruct( 2, "SZE" )

	oView := FWFormView():New()

	//Criando oView 
	oView:SetModel(oModel)
    oView:AddField( "VIEW_SZE", oStrSZE, "SZEMASTER" )

  	oStrSZE:RemoveField("ZE_STATUS")	


Return oView



Static Function fLegenda()
	Local aLegenda   := {}
	Local cxCadastro := "Status"

	Aadd( aLegenda, {"BR_VERMELHO","Etiq.Nao Impressa","ZE_STATUS == '2' "}) 
	Aadd( aLegenda, {"BR_VERDE"   ,"Etiq.Impressa    ","ZE_STATUS == '1' "}) 

	BrwLegenda(cxCadastro, "Legenda", aLegenda)

Return
