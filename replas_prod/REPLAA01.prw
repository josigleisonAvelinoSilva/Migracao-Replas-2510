#Include 'Protheus.ch'
//-------------------------------------------------------------------
/*/{Protheus.doc} REPLAA01
Cadastro Produto Inteligente

@author TOTVS Serra do Mar [JOSE CARLOS]
@since 27/06/2016
@version P12
/*/
//-------------------------------------------------------------------

User Function REPLAA01()
Local oDlg			:= Nil
Local cEstrutura	:= GetMv("FS_MASCBOP",.F.,"5234")
Local lOk			:= .F.
Local cNewCod		:= ""

Private cMatPrima	:= Space( Val(Substr(cEstrutura,1,1)) )
Private cDiaInter	:= Space( Val(Substr(cEstrutura,2,1)) )
Private cDiaExter	:= Space( Val(Substr(cEstrutura,3,1)) )
Private cLargura	:= Space( Val(Substr(cEstrutura,4,1)) )
Private oDescri		:= Nil
Private cDescri		:= Space( TamSx3('B1_DESC')[1])
Private aDiaExter	:= {}
Private aLargura	:= {}

If INCLUI .OR. ALTERA

	// Verifica se o conteudo do acols esta preenchido.
	If (IsInCallStack('MATA410') .And. !Empty( GDFieldGet( 'C6_PRODUTO', n , .F. , aHeader, aCols ) ) ) .Or. ;
		(IsInCallStack('MATA415') .And. !Empty( GDFieldGet( 'CJ_PRODUTO', n , .F. , aHeader, aCols ) ) )
		
		ApMsgInfo('Produto na linha do pedido está preenchido.'+CRLF+'Para um novo produto deixe o código do produto na linha em branco.')	 

	Else
		DEFINE MSDIALOG oDlg FROM 25,1 TO 250,400 TITLE "Cadastro Produto Inteligente" PIXEL 
			
			@ 10,06 SAY "Matéria Prima" SIZE 50, 09 OF oDlg PIXEL
			@ 10,60	MSGET cMatPrima	  	Picture "@!" Valid ValidCpos(cEstrutura,@oDlg) SIZE 46, 09 OF oDlg PIXEL
		
			@ 25,06 SAY "Diam. Interno" SIZE 50, 09 OF oDlg PIXEL
			@ 25,60	MSGET cDiaInter	  	Picture Replicate('9',Len(cDiaInter)) Valid ValidCpos(cEstrutura) SIZE 46, 09 OF oDlg PIXEL
		
			@ 40,06 SAY "Diam. Externo" SIZE 50, 09 OF oDlg PIXEL
			@ 40,60	MSGET cDiaExter	  	Picture Replicate('9',Len(cDiaExter)) Valid ValidCpos(cEstrutura) SIZE 46, 09 OF oDlg PIXEL
		
			@ 55,06 SAY "Largura" 		SIZE 50, 09 OF oDlg PIXEL
			@ 55,60	MSGET cLargura	  	Picture Replicate('9',Len(cLargura)) Valid ValidCpos(cEstrutura) SIZE 46, 09 OF oDlg PIXEL
		
			@ 70,06 SAY "Descrição"		SIZE 50, 09 OF oDlg PIXEL
			@ 70,60	MSGET cDescri	  	Picture "@!" When .F. SIZE 100,09 OF oDlg PIXEL
		
			DEFINE SBUTTON FROM 90,120 TYPE 1 ENABLE OF oDlg ACTION Iif(lOK:=IncluiSB1(@cNewCod),oDlg:End(),Nil)
			DEFINE SBUTTON FROM 90,150 TYPE 2 ENABLE OF oDlg ACTION oDlg:End() 
		
		ACTIVATE MSDIALOG oDlg CENTERED
	EndIF
	
Else
	ApMsgInfo('Rotina disponível apenas nas opções de INCLUIR ou ALTERAR.')
EndIf

If lOK

	//If IsInCallStack('MATA410')

		DbSelectArea('SB1') 
		DbSetOrder(1)
		DbSeek( xFilial('SB1') + cNewCod )

		GdFieldPut("C6_PRODUTO"	,SB1->B1_COD,N)
		GdFieldPut("C6_UM"		,SB1->B1_UM,N)
		GdFieldPut("C6_SEGUM"	,SB1->B1_SEGUM,N)				
 		GdFieldPut("C6_DESCRI"	,SB1->B1_DESC,N)
 		GdFieldPut("C6_LOCAL"	,SB1->B1_LOCPAD,N)
 		GdFieldPut("C6_TES"		,SB1->B1_TS,N)

//		A410Produto(cNewCod,.f.)
		
		// Utilizado para o gatilho
		__readvar		:= 'C6_PRODUTO'
		M->C6_PRODUTO	:= cNewCod	
		M->C6_UM		:= SB1->B1_UM
		M->C6_SEGUM		:= SB1->B1_SEGUM				
 		M->C6_DESCRI	:= SB1->B1_DESC
 		M->C6_LOCAL		:= SB1->B1_LOCPAD
 		M->C6_TES		:= SB1->B1_TS	
 		RunTrigger(2,n,Nil,,'C6_PRODUTO')

     	GETDREFRESH()
     	SetFocus(oGetDad:oBrowse:hWnd) // Atualizacao por linha
     	oGetDad:Refresh()
     	//A410LinOk(oGetDad)
 				
 	//EndIf
	
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidCpos
Validação de Campos

@author TOTVS Serra do Mar [JOSE CARLOS]
@since 27/06/2016
@version P12
/*/
//-------------------------------------------------------------------
Static Function ValidCpos(cEstrutura,oDlg)
Local lRet		:= .t.
Local cLimiteDia:= ""
Local cPosicao	:= ""
Local nPos1		:= 0	// Posicao Diametro Externo no codigo do produto
Local nPos2		:= 0	// Posicao Largura no codigo do produto
Local nPos3		:= 0	// Posicao Diametro Interno no codigo do produto
Local cPos1		:= ""
Local cPos2		:= ""
Local cPos3		:= ""
Local nTam		:= 0
Local cTipoGrp	:= ""
Local cParGrupo	:= ""
Local nX		:= 0

Default cEstrutura	:= ""

If __readvar == 'cDiaInter'
	
	cLimiteDia:= GetMv("FS_DIAMINT",.F.,"03/06")
	
	If !(cDiaInter) $ cLimiteDia
		Help(" ",1,"ValidCpos",,"Diametro digitado não está dentro do limite." ,1,0)
		lRet := .f.
	Else

		DbSelectArea('SB1')
		SB1->(DbSetOrder(1))
		If SB1->(DbSeek(xFilial('SB1') + cMatPrima + cDiaInter , .f. ) )

			nTam 	:= Val(Substr( cEstrutura,1,1 ))	// Materia Prima
			
			For nX:=1 To Len( cEstrutura )
				If nX <= 1
					nPos3 += Val(Substr( cEstrutura,nX,1 ))
				EndIf	
				If nX <= 2
					nPos1 += Val(Substr( cEstrutura,nX,1 ))
				EndIf	
				If nX <= 3
					nPos2 += Val(Substr( cEstrutura,nX,1 ))
				EndIf			
			Next nX
			// Posicao no codigo do produto
			nPos1 ++
			nPos2 ++
			nPos3 ++
			// Posicao inicial do codigo do produto
			cPos1 := Substr( SB1->B1_COD,nPos1,Val(Substr(cEstrutura,3,1)))
			cPos2 := Substr( SB1->B1_COD,nPos2,Val(Substr(cEstrutura,4,1)))
			
			Aadd( aDiaExter, cPos1 )
			Aadd( aLargura , cPos2 )
			
			While SB1->(!Eof()) .And. SB1->B1_FILIAL == xFilial('SB1') .And. Substr(SB1->B1_COD,1,nTam) == cMatPrima
				cPos3 := Substr( SB1->B1_COD,nPos3,Val(Substr(cEstrutura,2,1)))
				If cPos3 == cDiaInter
					cPos1 := Substr( SB1->B1_COD,nPos1,Val(Substr(cEstrutura,3,1)))
					cPos2 := Substr( SB1->B1_COD,nPos2,Val(Substr(cEstrutura,4,1)))
				EndIf	
				SB1->(DbSkip())
			EndDo

			//oDlg:Refresh()
			Aadd( aDiaExter, cPos1 )
			Aadd( aLargura , cPos2 )
			
		EndIf
		
	EndIf
ElseIf __readvar == 'cMatPrima'

	DbSelectArea('SB1')
	SB1->(DbSetOrder(1))
	If SB1->(DbSeek(xFilial('SB1') + cMatPrima , .f. ) )
	
		// Verifica se o grupo do produto faz parte FILME/BOPP
		cTipoGrp	:= GetAdvFval("SBM","BM_TIPGRU",xFilial('SBM')+SB1->B1_GRUPO,1)
		cParGrupo	:= GetMv("FS_GRPBOPP",.F.,"FS/BO")
		
		If Alltrim(cTipoGrp) $ cParGrupo
	
			cDescri 	:= SB1->B1_DESC

			oDlg:Refresh()
			
		Else
			Help(" ",1,"NOBOPP",,"Matéria prima não parametrizado como FILMES/BOPP." ,1,0)
			lRet := .F.
		EndIF
		
	Else
		Help(" ",1,"NOLOCALIZ",,"Matéria prima não cadastrado na tabela de produtos." ,1,0)
		lRet	:= .F.
	EndIf
ElseIf __readvar == 'cDiaExter'
	If Len( aDiaExter ) > 1
		If cDiaExter >= aDiaExter[1] .And. cDiaExter <= aDiaExter[2]
			lRet := .T.
		Else
			Help(" ",1,"cDiaExter",,"Diametro externo digitado não está dentro do limite." ,1,0)
			lRet := .F.
		EndIF
	Else
		Help(" ",1,"cDiaExter",,"Diametro externo não definido limite." ,1,0)
		lRet := .F.	
	EndIf
ElseIf __readvar == 'cLargura'
	If Len( aLargura ) > 1
		If cLargura >= aLargura[1] .And. cLargura <= aLargura[2]
			lRet := .T.
		Else
			Help(" ",1,"cLargura",,"Largura digitada não está dentro do limite." ,1,0)
			lRet := .F.
		EndIF
	Else
		Help(" ",1,"cDiaExter",,"Largura não definido limite." ,1,0)
		lRet := .F.	
	EndIf		
EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} IncluiSB1
Rotina de inclusão de Produtos

@author TOTVS Serra do Mar [JOSE CARLOS]
@since 27/06/2016
@version P12
/*/
//-------------------------------------------------------------------
Static Function IncluiSB1( cNewCod )
Local lRetorno	:= .T.
Local cCodigo	:= 	cMatPrima + cDiaInter + cDiaExter + cLargura
Local aAreaAtu	:= GetArea()
Local nX		:= 0
Local aProduto	:= {}
Local nOpcao	:= 3
Local cCampo	:= ""

Private lMsHelpAuto := .F.
Private lMsErroAuto := .F.

DbSelectArea('SB1')
SB1->(DbSetOrder(1))
If SB1->(DbSeek(xFilial('SB1') + cCodigo ) )
	Help(" ",1,"IncluiSB1",,"Código do Produto já existe." ,1,0)
	lRetorno := .F.
Else
	//Posiciona no primeiro da tabela de produto 
	IF SB1->(DbSeek(xFilial('SB1') + cMatPrima ) )
	
		lMsErroAuto := .F.
		lMsHelpAuto := .t.
		aProduto:={}    
		aadd(aProduto,{'B1_COD'		,cCodigo		,nil})
		aadd(aProduto,{'B1_DESC'	,cDescri		,nil})
		aadd(aProduto,{'B1_TIPO'	,SB1->B1_TIPO	,nil})
		aadd(aProduto,{'B1_UM'		,SB1->B1_UM		,nil})
		aadd(aProduto,{'B1_LOCPAD'	,SB1->B1_LOCPAD	,nil})
		aadd(aProduto,{'B1_GRUPO'	,SB1->B1_GRUPO	,nil})
		aadd(aProduto,{'B1_TE'		,SB1->B1_TE		,nil})
		aadd(aProduto,{'B1_TS'		,SB1->B1_TS		,nil})
		aadd(aProduto,{'B1_ORIGEM'	,SB1->B1_ORIGEM	,nil})
		aadd(aProduto,{'B1_CONV'	,SB1->B1_CONV	,nil})
		aadd(aProduto,{'B1_TIPCONV'	,SB1->B1_TIPCONV,nil})
		aadd(aProduto,{'B1_PESO'	,SB1->B1_PESO   ,nil})
		aadd(aProduto,{'B1_PESBRU'	,SB1->B1_PESBRU ,nil})
		aadd(aProduto,{'B1_POSIPI'	,SB1->B1_POSIPI ,nil})
		aadd(aProduto,{'B1_IPI'	    ,SB1->B1_IPI    ,nil})
	    aadd(aProduto,{'B1_XGRUPO'	,SB1->B1_XGRUPO ,nil})
	    aadd(aProduto,{'B1_PROC'	,SB1->B1_PROC   ,nil})   			
		aadd(aProduto,{'B1_RASTRO'	,'N'			,nil})
		aadd(aProduto,{'B1_LOCALIZ'	,'N'			,nil})
				
		MSExecAuto({|x,y| Mata010(x,y)},aProduto,nOpcao) 
		
		If lMsErroAuto
		   mostraerro() // tela
		   lRetorno := .F.
		Else
			cNewCod	:= cCodigo   
		Endif
		
	EndIf
EndIF

RestArea( aAreaAtu )	
Return( lRetorno )

