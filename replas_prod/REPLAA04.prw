#include 'protheus.ch'
#include 'parmtype.ch'


//-- U_REPLAA04()
User Function REPLAA04()
	Local aInteface := FWGetDialogSize(oMainWnd)
	
	Private cFilEst   := GetNewPar("MV_XFILEST", "0102,0103,0302,0201")
	Private cQry      := GetQry()
	Private cAliasQry := GetNextAlias()
    Private cUltOrdem := ""
    Private lDescend  := .F.
	Private oDlgWA    := Nil
	Private oBrw      := Nil

	//-- Criando teclas de atalhos
	SetKey(VK_F5, {|| AtuTela()})

	oBrw := FWBrowse():new()

    oDlgWA := MSDialog():new(aInteface[1], aInteface[2], aInteface[3], aInteface[4], "Consulta Estoque Resinas",,,, nOr(WS_VISIBLE, WS_POPUP),,,,, .T.,,,, .F.)

		//-- Chama a carga dos dados
		FwMsgRun(, {|| LoadBrw()}, , "Consultando Estoque Resinas, aguarde...")

	oDlgWA:activate(,,,,,, {|| })

	oBrw:deActivate()

	SetKey(VK_F5, {||})

Return


//--
Static Function LoadBrw()
	Local aSeek     := {}
	Local aFields   := {}
	Local aIndex    := {}
	Local aColsBrw  := GetColsBrw()
	Local nZ
	
	aAdd(aSeek, {'Código'   , {{"", "C", TamSX3("B1_COD")[1] , 0, 'Código',,}}})
	aAdd(aSeek, {'Descrição', {{"", "C", TamSX3("B1_DESC")[1], 0, 'Descrição',,}}})

	aAdd(aFields, {"B1_COD"    , "Código"    , "C", TamSX3("B1_COD")[1]    , 0, PesqPict("SB1", "B1_COD")})
	aAdd(aFields, {"B1_DESC"   , "Descrição" , "C", TamSX3("B1_DESC")[1]   , 0, PesqPict("SB1", "B1_DESC")})
	aAdd(aFields, {"NNR_CODIGO", "Local"     , "C", TamSX3("NNR_CODIGO")[1], 0, PesqPict("NNR", "NNR_CODIGO")})
	aAdd(aFields, {"B1_GRUPO"  , "Grupo"     , "C", TamSX3("B1_GRUPO")[1]  , 0, PesqPict("SB1", "B1_GRUPO")})
	aAdd(aFields, {"B1_FABRIC" , "Fabricante", "C", TamSX3("B1_FABRIC")[1] , 0, PesqPict("SB1", "B1_FABRIC")})

	For nZ := 1 To Len(aColsBrw)
		aAdd(aIndex, aColsBrw[nZ]:CID)
	Next nZ

	oBrw:setDataQuery(.T.)
	oBrw:setAlias(cAliasQry)
	oBrw:setQuery(cQry)
	oBrw:setColumns(aColsBrw)
	oBrw:setOwner(oDlgWA)
	oBrw:setLocate()
	oBrw:setSeek(, aSeek) 	
	oBrw:setFieldFilter(aFields)
	oBrw:setUseFilter()
	oBrw:setQueryIndex(aIndex)
	oBrw:setDescription("Consulta Estoque <b><u>Resinas</u></b>")
	oBrw:lHeaderClick := .T.
	oBrw:setItemHeaderClick(aIndex)
	oBrw:addFilter("Nacional", "B1_XGRUPO=='2'")
	oBrw:addFilter("Importada", "B1_XGRUPO=='3'")
	oBrw:activate()
	oBrw:refresh()

Return


//--
Static Function GetQry()
	Local aFilEst := StrToKarr(AllTrim(cFilEst), ";")
	Local cRet    := ""
	Local nZ

	cRet := " SELECT B1_COD, B1_DESC, NNR_CODIGO, B1_GRUPO, "
	For nZ := 1 To Len(aFilEst)
		cRet += "EST_" + aFilEst[nZ] + ", "
	Next nZ
	cRet += " B1_XINDFLU, B1_FABRIC, B1_XGRUPO "
	cRet += " FROM ( "
	cRet += " SELECT "
	cRet += " B1_COD, "
	cRet += " B1_DESC, "
	cRet += " B1_GRUPO, "
	cRet += " B1_MSBLQL, " 
	cRet += " NNR_CODIGO, "
	For nZ := 1 To Len(aFilEst)
		cRet += " SB2"+ aFilEst[nZ] +".B2_QATU-SB2"+ aFilEst[nZ] +".B2_RESERVA-SB2"+ aFilEst[nZ] +".B2_QEMP EST_"+ aFilEst[nZ] +", "
	Next nZ
	cRet += " B1_XINDFLU, "
	cRet += " B1_FABRIC, "
	cRet += " B1_XGRUPO "
	cRet += " FROM SB1010 SB1 "
	cRet += " INNER JOIN NNR010 NNR ON NNR.D_E_L_E_T_ = ' ' "
	For nZ := 1 To Len(aFilEst)
		cRet += " LEFT JOIN SB2010 SB2"+ aFilEst[nZ] +" ON SB2"+ aFilEst[nZ] +".B2_FILIAL = '"+ aFilEst[nZ] +"' AND SB2"+ aFilEst[nZ] +".B2_COD=B1_COD AND SB2"+ aFilEst[nZ] +".B2_LOCAL = NNR_CODIGO AND SB2"+ aFilEst[nZ] +".D_E_L_E_T_ = ' ' "
	Next nZ
	cRet += " WHERE SB1.D_E_L_E_T_ = ' ' "
	cRet += " AND SB1.B1_XGRUPO IN ('2','3') " //-- Resinas
	cRet += " ) TRB "
	cRet += " WHERE "
	For nZ := 1 To Len(aFilEst)
		cRet += Iif(nZ==1, "", " OR") + " EST_" + aFilEst[nZ] + " > 0 "
	Next nZ
	cRet += " ORDER BY B1_COD "

	cRet := ChangeQuery(cRet)

Return cRet


/*/{Protheus.doc} AtuTela
Rotina para atualizacao da tela (Refresh)
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 27/05/2023
/*/
Static Function AtuTela()
Return FwMsgRun(, {|| oBrw:cleanFilter(), oBrw:setQuery(cQry), oBrw:refresh()}, , "Consultando Estoque Resinas, aguarde...")


//-- 
Static Function GetColsBrw()
	Local aStruct  := {}
    Local aColumns := {}
	Local aCombo   := {}
	Local aFilEst  := StrToKarr(AllTrim(cFilEst), ";")
	Local cCpoAux  := ""
    Local nZ

	//-- Campos da estrutura do browse
	cCpoAux := "B1_COD"
	aAdd(aStruct, {cCpoAux, "Código", GetSX3Cache(cCpoAux, "X3_TIPO"), GetSX3Cache(cCpoAux, "X3_PICTURE"), GetSX3Cache(cCpoAux, "X3_TAMANHO"), GetSX3Cache(cCpoAux, "X3_DECIMAL"), "", 150})
	
	cCpoAux := "B1_DESC"
	aAdd(aStruct, {cCpoAux, "Descrição", GetSX3Cache(cCpoAux, "X3_TIPO"), GetSX3Cache(cCpoAux, "X3_PICTURE"), GetSX3Cache(cCpoAux, "X3_TAMANHO"), GetSX3Cache(cCpoAux, "X3_DECIMAL"), "", 200})
	
	cCpoAux := "NNR_CODIGO"
	aAdd(aStruct, {cCpoAux, "Local", GetSX3Cache(cCpoAux, "X3_TIPO"), GetSX3Cache(cCpoAux, "X3_PICTURE"), GetSX3Cache(cCpoAux, "X3_TAMANHO"), GetSX3Cache(cCpoAux, "X3_DECIMAL"), "", 40})
	
	cCpoAux := "B1_GRUPO"
	aAdd(aStruct, {cCpoAux, "Grupo", GetSX3Cache(cCpoAux, "X3_TIPO"), GetSX3Cache(cCpoAux, "X3_PICTURE"), GetSX3Cache(cCpoAux, "X3_TAMANHO"), GetSX3Cache(cCpoAux, "X3_DECIMAL"), "", 50})
	
	cCpoAux := "B2_QATU"
	For nZ := 1 To Len(aFilEst)
		aSM0Data := FWSM0Util():getSM0Data(FWCodEmp(), aFilEst[nZ], {"M0_FILIAL"})
	
		//-- Carrega as colunas das filiais
		aAdd(aStruct, {"EST_" + aFilEst[nZ], AllTrim(aSM0Data[01, 02]), GetSX3Cache(cCpoAux, "X3_TIPO"), GetSX3Cache(cCpoAux, "X3_PICTURE"), GetSX3Cache(cCpoAux, "X3_TAMANHO"), GetSX3Cache(cCpoAux, "X3_DECIMAL"), "", 210})
	Next nZ

	cCpoAux := "B1_XINDFLU"
	aAdd(aStruct, {cCpoAux, "IF", GetSX3Cache(cCpoAux, "X3_TIPO"), GetSX3Cache(cCpoAux, "X3_PICTURE"), GetSX3Cache(cCpoAux, "X3_TAMANHO"), GetSX3Cache(cCpoAux, "X3_DECIMAL"), "", 50})
	
	cCpoAux := "B1_FABRIC"
	aAdd(aStruct, {cCpoAux, "Fabricante", GetSX3Cache(cCpoAux, "X3_TIPO"), GetSX3Cache(cCpoAux, "X3_PICTURE"), GetSX3Cache(cCpoAux, "X3_TAMANHO"), GetSX3Cache(cCpoAux, "X3_DECIMAL"), "", 150})
	
	cCpoAux := "B1_XGRUPO"
	aAdd(aStruct, {cCpoAux, "Grp Prod", GetSX3Cache(cCpoAux, "X3_TIPO"), GetSX3Cache(cCpoAux, "X3_PICTURE"), GetSX3Cache(cCpoAux, "X3_TAMANHO"), GetSX3Cache(cCpoAux, "X3_DECIMAL"), GetSX3Cache(cCpoAux, "X3_CBOX"), 150})

	For nZ := 1 To Len(aStruct)    
		aAdd(aColumns, FWBrwColumn():new())
		aColumns[Len(aColumns)]:setData(&("{|| " + aStruct[nZ, 01] + "}"))
		aColumns[Len(aColumns)]:setTitle(aStruct[nZ, 02])
		aColumns[Len(aColumns)]:setType(aStruct[nZ, 03])
		aColumns[Len(aColumns)]:setAlign(Iif(aStruct[nZ, 03]=="N",CONTROL_ALIGN_RIGHT,CONTROL_ALIGN_LEFT))
		aColumns[Len(aColumns)]:setPicture(aStruct[nZ, 04])
		aColumns[Len(aColumns)]:setSize(aStruct[nZ, 05])
		aColumns[Len(aColumns)]:setDecimal(aStruct[nZ, 06])
		aColumns[Len(aColumns)]:setID(aStruct[nZ, 01])
		aColumns[Len(aColumns)]:setReadVar("M->" + aStruct[nZ, 01])

		//-- Campo combobox
        If !Empty(aStruct[nZ, 07])
            aCombo := StrToKarr(AllTrim(aStruct[nZ, 07]), ";")
            aColumns[Len(aColumns)]:setOptions(aCombo)
        EndIf

		//-- Tamanho da coluna
		If aStruct[nZ, 08] > 0
			aColumns[Len(aColumns)]:nSize := aStruct[nZ, 08]
			aColumns[Len(aColumns)]:lAutoSize := .F.
		EndIf
	Next nZ

Return aColumns
