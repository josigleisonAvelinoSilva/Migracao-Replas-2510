#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

//----------------------------------------------------------------
/*/{Protheus.doc} REFATX01
Tela de pesquisa customizada pesquisa pedidos por vendedor

@author Rafael Domingues
@since 05.02.2018
/*/
//----------------------------------------------------------------

User Function REFATX01()

	Local oButton1
	Local oButton2
	Local oButton3
	Local oGet1
	Local cGet1 := Space(08)
	Local oSay1

	Static oDlg

	DEFINE MSDIALOG oDlg TITLE "Consulta Pedido Vendas" FROM 000, 000  TO 400, 540 COLORS 0, 16777215 PIXEL

	@ 008, 004 SAY oSay1 PROMPT "Codigo" SIZE 021, 011 OF oDlg COLORS 0, 16777215 PIXEL
	@ 008, 028 MSGET oGet1 VAR cGet1 SIZE 179, 010 OF oDlg COLORS 0, 16777215 PIXEL
	@ 008, 212 BUTTON oButton1 PROMPT "Pesquisar" SIZE 049, 009 OF oDlg ACTION (REFATX1C(cGet1)) PIXEL
	REFATX1A()
	@ 160, 006 BUTTON oButton2 PROMPT "Ok" SIZE 055, 024 OF oDlg ACTION (U_REFATX1D(),oDlg:End()) PIXEL
	@ 160, 066 BUTTON oButton3 PROMPT "Cancela" SIZE 055, 024 OF oDlg ACTION (oDlg:End()) PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED

Return(.T.)

//----------------------------------------------------------------
/*/{Protheus.doc} REFATX1A
Tela de pesquisa customizada pesquisa pedidos por vendedor

@author Rafael Domingues
@since 05.02.2018
/*/
//----------------------------------------------------------------

Static Function REFATX1A()

	Local nX
	Local aHeaderEx 	:= {}
	Local aColsEx 		:= {}
	Local aFieldFill 	:= {}
	Local aFields 		:= {"C5_FILIAL","C5_NUM","C5_CLIENTE","C5_LOJACLI"}
	Local aAlterFields 	:= {}
	Local cVend 		:= RetCodUsr()
	Local _cUsers 	 	:= ""
	Local aCpo := {}
	Local nI := 0
	
	Static oMSNewGe1
	
	//---> REMOVIDO compatibilização para versão 12.1.25.
	/*If !GetMv("MV_XFATUSR", .T.)
		CriarSX6("MV_XFATUSR", 'C', 'CODIGO DE USUARIO LIBERADOS PARA CONSULTA DE PEDIDOS. REFATC01.prw', '000000;000012;000078')
	Endif*/

	_cUsers := GetMv("MV_XFATUSR", .F.)

	If AllTrim(cVend) $ AllTrim(_cUsers)
		cVend := ""
	Else
		DbSelectArea("AO3")
		DbSetOrder(1)
		If DbSeek(xFilial("AO3") + cVend)
			cVend := AO3->AO3_VEND
		EndIf
	EndIf

	// Define field properties
	//---> REMOVIDO compatibilização para versão 12.1.25.
	/*DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	For nX := 1 to Len(aFields)
		If SX3->(DbSeek(aFields[nX]))
			Aadd(aHeaderEx, {	AllTrim(X3Titulo()),;
										SX3->X3_CAMPO,;
										SX3->X3_PICTURE,;
										SX3->X3_TAMANHO,;
										SX3->X3_DECIMAL,;
										SX3->X3_VALID,;
										SX3->X3_USADO,;
										SX3->X3_TIPO,;
										SX3->X3_F3,;
										SX3->X3_CONTEXT,;
										SX3->X3_CBOX,;
										SX3->X3_RELACAO})
		Endif
	Next nX
	// Define field values
	For nX := 1 to Len(aFields)
		If DbSeek(aFields[nX])
			Aadd(aFieldFill, CriaVar(SX3->X3_CAMPO))
		Endif
	Next nX*/
	
	aCpo := FwSx3Util():GetAllFields('SF1')
	
	For nI := 1 To Len( aCpo )
		If AScan( aFields, {|e| e == RTrim( aCpo[ nI, 2 ] ) } ) > 0
			AAdd( aHeaderEx,{ FwX3Titulo( aCpo[ nI ] ),;
			GetSx3Cache( aCpo[ nI ] ,'X3_CAMPO ') ,;
			GetSx3Cache( aCpo[ nI ] ,'X3_PICTURE') ,;
			GetSx3Cache( aCpo[ nI ] ,'X3_TAMANHO') ,;
			GetSx3Cache( aCpo[ nI ] ,'X3_DECIMAL') ,;
			GetSx3Cache( aCpo[ nI ] ,'X3_VALID') ,;
			GetSx3Cache( aCpo[ nI ] ,'X3_USADO') ,;
			GetSx3Cache( aCpo[ nI ] ,'X3_TIPO') ,;
			GetSx3Cache( aCpo[ nI ] ,'X3_ARQUIVO') ,;
			GetSx3Cache( aCpo[ nI ] ,'X3_CONTEXT') })
			
			AAdd( aFieldFill, CriaVar( GetSx3Cache( aCpo[ nI ] ,'X3_CAMPO ') ))
		Endif
	Next nI
	
	Aadd(aFieldFill, .F.)
	Aadd(aColsEx, aFieldFill)

	aColsEx := {}

	cQuery := " SELECT C5_FILIAL,C5_NUM,C5_CLIENTE,C5_LOJACLI FROM "+RetSqlName("SC5")
	cQuery += " WHERE D_E_L_E_T_ = '' "
	If !Empty(cVend)
		cQuery += " AND C5_VEND1 = '"+cVend+"' "
	EndIf
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TMP', .T., .F.)

	DbSelectArea("TMP")
	DbGoTop()

	While !Eof()

		aAdd(aColsEx, {	TMP->C5_FILIAL, TMP->C5_NUM, TMP->C5_CLIENTE, TMP->C5_LOJACLI, .F.	})

		DbSelectArea("TMP")
		DbSkip()

	End

	DbSelectArea("TMP")
	DbCloseArea()

	oMSNewGe1 := MsNewGetDados():New( 023, 005, 155, 260, GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)

Return

//----------------------------------------------------------------
/*/{Protheus.doc} REFATX1C
Tela de pesquisa customizada pesquisa pedidos por vendedor

@author Rafael Domingues
@since 05.02.2018
/*/
//----------------------------------------------------------------

Static Function REFATX1C(cBusca)

	Local i := 0

	If !Empty(cBusca)
		For i := 1 to len(oMSNewGe1:ACOLS)
			//Aqui busco o texto exato
			If Alltrim(oMSNewGe1:ACOLS[i,2]) == Alltrim(cBusca)
				//Se encontrar, posiciono no grid e saio do "For"
				oMSNewGe1:GoTo(i)
				Exit
			Endif
		Next
	Endif

Return

//----------------------------------------------------------------
/*/{Protheus.doc} REFATX1D
Tela de pesquisa customizada pesquisa pedidos por vendedor

@author Rafael Domingues
@since 05.02.2018
/*/
//----------------------------------------------------------------

User Function REFATX1D()

	&("M->C5_NUM") := oMSNewGe1:ACOLS[oMSNewGe1:NAT][2] //Uso desta forma para campos como tGet por exemplo.

Return(oMSNewGe1:ACOLS[oMSNewGe1:NAT][2])
