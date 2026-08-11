#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} REPCPA12
Consulta MPs. Auxiliares
@type function
@version 1.0  
@author MARCO
@since 08/02/2023
/*/
User Function REPCPA12()
    Local aCores      :={}
	Private aRotina   :=MenuDef()
	Private cCadastro :="Consulta MPs Auxiliares"
	Private aParam    :={}
	Private aRet      :={}                  
	Private nOpc      :=0

    AADD(aCores,{"SZ9->Z9_STATUS = 'S' ","BR_VERMELHO"  ,"Transferido"})
    AADD(aCores,{"SZ9->Z9_STATUS <> 'S' ","BR_VERDE"    ,"Não Transferido"})	

	DbSelectArea("SZ9")
	DbSetOrder(1)

	oMBrowse := mBrowse( 6, 1,22,75     ,"SZ9",,,,,,aCores)

Return


Static Function MenuDef()
Local aRotina :={	{"Pesquisar      ","AxPesqui"	  ,0 , 1},;
 					{"Visualizar     ","AxVisual"	  ,0 , 2},;
 					{"Legenda"        ,"U_XREPCP12",0 , 6}}

Return( aRotina )

User Function XREPCP12()

	Local _aLegenda := {}

	AADD(_aLegenda, {"BR_VERMELHO","Transferido"})
	AADD(_aLegenda, {"BR_VERDE"   ,"Não Transferido"})

	BrwLegenda(cCadastro,'Legenda',_aLegenda)

Return()

