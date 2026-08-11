#INCLUDE "PROTHEUS.CH"


/*/{Protheus.doc} REFATA01
Rotina para inclusao/alteracao/exclusao de Pedidos de Venda que tem integracao com a Industria MM SP
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 10/05/2022
@obs Projeto Novo PCP
/*/
User Function REFATA01( aParamX )
    Local cCodEmp  := aParamX[01] //-- Codigo Empresa
    Local cFilOrig := aParamX[02] //-- Filial Origem
    Local cPVOrig  := aParamX[03] //-- Pedido Origem
    Local cFilDest := aParamX[04] //-- Filial Destino
    Local cPVDest  := aParamX[05] //-- Pedido Destino
    Local nOper    := aParamX[06] //-- Operacao do AutoExec para o PV Inclusao/Alteracao/Exclusao

	Do Case
		Case nOper == 3
			//-- Faz a inclusao
			IncluiPV( cCodEmp, cFilOrig, cPVOrig, cFilDest, cPVDest, nOper )
		Case nOper == 4 .Or. nOper == 5
			//-- Faz a alteracao e a exclusao
			AlteraPV( cCodEmp, cFilOrig, cPVOrig, cFilDest, cPVDest, nOper )
	End Case

Return


/*/{Protheus.doc} IncluiPV
Funcao que faz a inclusao do pedido na filial 0201
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 17/05/2022
@param cCodEmp, character, Codigo Empresa
@param cFilOrig, character, Filial Origem
@param cPVOrig, character, Pedido Origem
@param cFilDest, character, Filial Destino
@param cPVDest, character, Pedido Destino
@param nOper, numeric, Operacao do AutoExec
/*/
Static Function IncluiPV( cCodEmp, cFilOrig, cPVOrig, cFilDest, cPVDest, nOper )
    Local aArea     := GetArea()
    Local aAreaSB1  := SB1->( GetArea() )
    Local aAreaSB2  := SB2->( GetArea() )
    Local aAreaSC5	:= SC5->( GetArea() )
    Local aAreaSC6	:= SC6->( GetArea() )
    Local aCpoSC5   := {}
    Local aCpoSC6   := {}
    Local aCabecPV  := {}
    Local aItensPV  := {}
    Local aItem     := {}
	Local aCliDest  := {}
    Local cCondPag  := GetMv( "RE_CPAGDES", .F., "002" )
    Local cTSRemS   := GetMV( "RE_TSREMS" , .F., "533" ) //-- Tipo de Saida para Remessa para Industrializacao do SERVICO
    Local cCodServ  := GetMV( "RP_CODSERV", .F., "" )
	Local cFilAtual := cFilAnt //-- Backup da variavel "cFilAnt"
    Local cFileLog  := ""
    Local cMsg      := ""
    Local nI        := 0
	Local nPrcVen   := 0
    Local xConteudo := Nil

    Private lMsErroAuto := .F.

	//-- Retorna dados do Cliente Destino - Codigo, Loja e Nome
	aCliDest := GetCliDest( cCodEmp, cFilOrig )

	//-- Utiliza dados da Filial de Destino na variavel padrao "cFilAnt"
	cFilAnt := cFilDest

    //-- Retorna os campos da tabela SC5
    GetCpoSC5( aCpoSC5 )

    //-- Retorna os campos da tabela SC6
    GetCpoSC6( aCpoSC6 )

	//-- Realiza a inclusao de pedido de vendas destino
	If nOper == 3
        DbSelectArea( "SB1" )
        SB1->( DbSetOrder(1) )
		
        DbSelectArea( "SC5" )
		SC5->( DbSetOrder(1) )

		DbSelectArea( "SC6" )
		SC6->( DbSetOrder(1) )

		//-- Cabecalho SC5, Campos e Conteudos
		If !Empty( aCpoSC5 ) .And. SC5->( DbSeek( cFilOrig + cPVOrig ) )
			cCliOrig := SC5->C5_XDESCLI

			For nI := 1 to Len( aCpoSC5 )
				If ( aCpoSC5[nI, 02] == "C" .And. !Empty( SC5->&(aCpoSC5[nI, 01]) ) ) .Or.;
                   ( aCpoSC5[nI, 02] == "N" .And. SC5->&( aCpoSC5[nI, 01] ) # 0 ) .Or.;
                   ( aCpoSC5[nI, 02] == "D" .And. SC5->&( aCpoSC5[nI, 01] ) # CToD("  /  /  ") )

					aAdd( aCabecPV, { AllTrim( aCpoSC5[nI, 01] ), SC5->&( aCpoSC5[nI, 01] ) , Nil } )
				EndIf
			Next nI

			//-- Grava Campos referencia do pedido destino
			aAdd( aCabecPV, { "C5_CLIENTE", aCliDest[01], Nil } )
			aAdd( aCabecPV, { "C5_LOJACLI", aCliDest[02], Nil } )
			aAdd( aCabecPV, { "C5_CONDPAG", cCondPag    , Nil } )
			aAdd( aCabecPV, { "C5_TPFRETE", "C"         , Nil } )
			aAdd( aCabecPV, { "C5_XFILORI", cFilOrig    , Nil } )
			aAdd( aCabecPV, { "C5_XPVORIG", cPVOrig	    , Nil } )
			aAdd( aCabecPV, { "C5_XCLIORI", cCliOrig    , Nil } )
			//aAdd( aCabecPV, { "C5_TIPLIB" , "1"         , Nil } )
		EndIf

		//-- Itens SC6, Campos e Conteudos
		If !Empty( aCpoSC6 ) .And. SC6->( DbSeek( cFilOrig + cPVOrig ) )
			While SC6->( !Eof()  ) .And. ( SC6->C6_FILIAL + SC6->C6_NUM == cFilOrig + cPVOrig )
				//-- So duplica produtos que sao fabricados na industria MM, filial 0201 
				If SB1->( DbSeek( xFilial("SB1") + SC6->C6_PRODUTO ) ) .And. SB1->B1_TIPO # "PA" .And. SB1->B1_XGRUPO # "1"
					SC6->( DbSkip() )
					Loop
				EndIf

				aItem := {}
				For nI := 1 To Len( aCpoSC6 )
					If AllTrim( aCpoSC6[nI, 01] ) $ "C6_PRODUTO"
						xConteudo := GetProd( SC6->&( aCpoSC6[nI, 01] ) )
					ElseIf AllTrim( aCpoSC6[nI, 01] ) $ "C6_TES"
						xConteudo := cTSRemS
					ElseIf AllTrim( aCpoSC6[nI, 01] ) $ "C6_PRUNIT/C6_PRCVEN"
						//-- Busca Custo
						nPrcVen := 0
						If SB1->( DbSeek( xFilial("SB1") + "SV-" + SC6->C6_PRODUTO ) )
							nPrcVen := SB1->B1_PRV1
						EndIf

						If Empty( nPrcVen ) .And. SB1->( DbSeek( xFilial("SB1") + cCodServ ) )
							nPrcVen := SB1->B1_PRV1
						EndIf

						If !Empty( nPrcVen )
							xConteudo := nPrcVen
						Else
							xConteudo := 1
						EndIf
					ElseIf AllTrim( aCpoSC6[nI, 01] ) $ "C6_VALOR"
						xConteudo := Round( SB1->B1_PRV1 * SC6->C6_QTDVEN, 2 )
					Else
						xConteudo := SC6->&( aCpoSC6[nI, 01] )
					EndIf

					aAdd( aItem, { AllTrim( aCpoSC6[nI, 01] ), xConteudo, Nil } )
				Next nI

				aAdd( aItensPV, aItem )

				SC6->( DbSkip() )
			EndDo
		EndIf

        //-- Grava pedido de venda destino
		If !Empty( aCabecPV ) .And. !Empty( aItensPV )
			//-- Reliza a gravacao do pedido destino 
			MsExecAuto( { |x, y, z| Mata410( x, y, z ) }, aCabecPV, aItensPV, nOper )
		
			If lMsErroAuto
                //MostraErro()
				ConOut( "##### Inicio erro rotina IncluiPV() no programa U_REFATA01() #####" )
				cFileLog := NomeAutoLog()
				cMsg     := MemoRead( cFileLog )
				If !Empty( cMsg )
					ConOut( cMsg )
				Endif
				ConOut( "##### Fim erro rotina IncluiPV() no programa U_REFATA01() #####" )
			Else
				If Empty( cPVDest )
					//-- Caso inclusao, grava dados do Destino na Origem
					cPVDest := SC5->C5_NUM
					If SC5->( DbSeek( cFilOrig + cPVOrig) )
						//-- Grava a filial e o pedido destino no pedido origem
						RecLock( "SC5", .F. )
						SC5->C5_XFILDES := cFilDest
						SC5->C5_XPVDEST := cPVDest
						SC5->( MsUnLock() )
					EndIf
				EndIf
			EndIf
		EndIf
    EndIf

	//-- Restaura filial da valiavel "cFilAnt"
	cFilAnt := cFilAtual 
    Restarea( aAreaSC6 )
    Restarea( aAreaSC5 ) 
    Restarea( aAreaSB2 )
    Restarea( aAreaSB1 )
	RestArea( aArea )

Return


/*/{Protheus.doc} AlteraPV
Funcaoq que faz a alteracao/exclusao de pedidos nos dois sentidos
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 17/05/2022
@param cCodEmp, character, Codigo Empresa
@param cFilOrig, character, Filial Origem
@param cPVOrig, character, Pedido Origem
@param cFilDest, character, Filial Destino
@param cPVDest, character, Pedido Destino
@param nOper, numeric, Operacao do AutoExec
/*/
Static Function AlteraPV( cCodEmp, cFilOrig, cPVOrig, cFilDest, cPVDest, nOper )
    Local aArea     := GetArea()
    Local aAreaSB1  := SB1->( GetArea() )
    Local aAreaSB2  := SB2->( GetArea() )
    Local aAreaSC5  := SC5->( GetArea() )
    Local aAreaSC6  := SC6->( GetArea() )
	Local aAreaSC9  := SC9->( GetArea() )
    Local aCpoSC5   := {}
	Local aXCpoSC5  := {}
    Local aCpoSC6   := {}
    Local aCabecPV  := {}
    Local aItensPV  := {}
    Local aItem     := {}
	Local cCliDest  := ""
	Local cLojaDest := ""
	Local cFilAtual := cFilAnt //-- Backup da variavel "cFilAnt"
	Local cTSRemS   := GetMV( "RE_TSREMS" , .F., "533" ) //-- Tipo de Saida para Remessa para Industrializacao do SERVICO
	Local cCodServ  := GetMV( "RP_CODSERV", .F., "" )
    Local cFileLog  := ""
    Local cMsg      := ""
	Local nI        := 0
	Local xConteudo := Nil

	Private lMsErroAuto := .F.

    //-- Retorna os campos da tabela SC5
    GetCpoSC5( aCpoSC5 )

    //-- Retorna os campos da tabela SC6
    GetCpoSC6( aCpoSC6 )

	If nOper == 4 .Or. nOper == 5
        DbSelectArea( "SB1" )
        SB1->( DbSetOrder(1) )

		DbSelectArea( "SB2" )
        SB2->( DbSetOrder(1) )	
	
        DbSelectArea( "SC5" )
		SC5->( DbSetOrder(1) )

		DbSelectArea( "SC6" )
		SC6->( DbSetOrder(1) )

		DbSelectArea( "SC9" )
		SC9->( DbSetOrder(1) )

		//-- Posiciona no Pedido Destino
		SC5->( DbSeek( cFilDest + cPVDest ) )
		cCliDest  := SC5->C5_CLIENTE
		cLojaDest := SC5->C5_LOJACLI

		//-- Posiciona no Pedido Origem
		If nOper == 4
			SC5->( DbSeek( cFilOrig + cPVOrig ) )
		EndIf

		//-- Cabecalho SC5, Campos e Conteudos
		If !Empty( aCpoSC5 ) .And. SC5->( Found() )
			aXCpoSC5 := {}
			For nI := 1 to Len( aCpoSC5 )
				If ( aCpoSC5[nI, 02] == "C" .And. !Empty( SC5->&(aCpoSC5[nI, 01]) ) ) .Or.;
				   ( aCpoSC5[nI, 02] == "N" .And. SC5->&( aCpoSC5[nI, 01]) # 0 ) .Or.;
				   ( aCpoSC5[nI, 02] == "D" .And. SC5->&( aCpoSC5[nI, 01]) # CToD("  /  /  ") )

					If !AllTrim( aCpoSC5[nI, 01] ) $ "C5_FILIAL/C5_NUM/C5_CLIENTE/C5_LOJACLI/"
						aAdd( aXCpoSC5, { AllTrim( aCpoSC5[nI, 01] ) } )
					Endif
				Endif
			Next nI

			aAdd( aCabecPV, { "C5_FILIAL"  , cFilDest , Nil } )
			aAdd( aCabecPV, { "C5_NUM"     , cPVDest  , Nil } )
			aAdd( aCabecPV, { "C5_CLIENTE" , cCliDest , Nil } )
			aAdd( aCabecPV, { "C5_LOJACLI" , cLojaDest, Nil } )
			//aAdd( aCabecPV, { "C5_TIPLIB"  , "1"      , Nil } )

			For nI := 1 To Len( aXCpoSC5 )
				cCampo    := Alltrim( aXCpoSC5[nI, 01] )
				xConteudo := SC5->&(cCampo)
				aAdd( aCabecPV, { cCampo, xConteudo, Nil } )
			Next
		Endif

		//-- Caso seja exclusao
		If nOper == 5
		    //--Posiciona no Pedido Destino
			dbSelectArea("SC5")  
			If SC5->( DbSeek( cFilDest + cPVDest )) .AND. SC6->( DbSeek( cFilDest + cPVDest ))
                cFilAnt := cFilDest			
				While SC6->( !Eof() .and. SC6->C6_FILIAL + SC6->C6_NUM == cFilDest + cPVDest )
					//-- Se algum item ja foi faturado ou produzido, nao exclui o pedido destino
					If !Empty(SC6->C6_NOTA) .Or. SC6->C6_XJAPROD == "1"
						aItensPV := {}
						Exit
					EndIf

					aItem := {}
					If SC6->C6_QTDEMP > 0
                        dbSelectArea("SC9")												
						SC9->(dbSetOrder(1))
						If SC9->( DbSeek( SC6->C6_FILIAL + SC6->C6_NUM + SC6->C6_ITEM ) )
							//Begin Transaction
								RecLock("SC9", .F.)
								SC9->(a460Estorna(.T.))   // Estorna o que estava liberado no sdc e sc9
								SC9->(MsUnlock())
							//End Transaction
							//SC9->( a460Estorna() )
						EndIf
					EndIf

					For nI := 1 To Len( aCpoSC6 )
						aAdd( aItem, { AllTrim( aCpoSC6[nI, 01] ), SC6->&(aCpoSC6[nI, 01]), Nil } )
					Next
					aAdd( aItensPV, aItem )

					SC6->( DbSkip() )
				EndDo
			EndIf
		ElseIf nOper == 4
			//-- Itens SC6, Campos e Conteudos
			If !Empty( aCpoSC6 ) .And. SC6->( DbSeek( cFilOrig + cPVOrig ))
				While SC6->( !Eof() .And. SC6->C6_FILIAL + SC6->C6_NUM == cFilOrig + cPVOrig )
					//-- So altera produtos que sao fabricados na industria MM, filial 0201 
					SB1->( DbSetOrder(1) )
					If SB1->( DbSeek( xFilial("SB1") + SC6->C6_PRODUTO ) ) .And. SB1->B1_TIPO # "PA" .And. SB1->B1_XGRUPO # "1"
						SC6->( DbSkip() )
						Loop
					EndIf

					//-- Se o item ja foi faturado ou produzido, pula ele
					If !Empty(SC6->C6_NOTA) .Or. SC6->C6_XJAPROD == "1"
						SC6->( DbSkip() )
						Loop
					EndIf

					aItem := {}
					For nI := 1 To Len( aCpoSC6 )
						If AllTrim( aCpoSC6[nI, 01] ) $ "C6_PRODUTO"
							xConteudo := GetProd( SC6->&( aCpoSC6[nI, 01] ) )
						ElseIf AllTrim( aCpoSC6[nI, 01] ) == "C6_TES"
							xConteudo := cTSRemS
						Elseif AllTrim( aCpoSC6[nI, 01] ) $ "C6_PRUNIT/C6_PRCVEN"
							//-- Busca Custo
							nPrcVen := 0
							If SB1->( DbSeek( xFilial("SB1") + "SV-" + SC6->C6_PRODUTO ) )
								nPrcVen := SB1->B1_PRV1
							EndIf

							If Empty( nPrcVen ) .And. SB1->( DbSeek( xFilial("SB1") + cCodServ ) )
								nPrcVen := SB1->B1_PRV1
							EndIf

							If !Empty( nPrcVen )
								xConteudo := nPrcVen
							Else
								xConteudo := 1
							EndIf
						ElseIf AllTrim( aCpoSC6[nI, 01] ) $ "C6_VALOR"
							xConteudo := Round( SB1->B1_PRV1 * SC6->C6_QTDVEN, 2 )
						Else
							xConteudo := SC6->&( aCpoSC6[nI, 01] )
						EndIf

						aAdd( aItem, { AllTrim( aCpoSC6[nI, 01] ), xConteudo , Nil } )
					Next nI

					aAdd( aItensPV, aItem )

					SC6->( DbSkip() )
				EndDo
			EndIf
		EndIf

		cFilAnt := cFilDest

		//-- Grava Alteracao ou Exclusao do Pedido
		If !Empty( aCabecPV ) .And. !Empty( aItensPV )
		    //--Em razco de Erro de ExecAuto - Insert Duplicate
			//--Quantidades de Itens Diferentes Origem/Destino
			//--Exemplo Pedido Origem  0302 - 000397 - 10 Itens
			//                 Destino 0201 - 046134 - 10 Itens
			//Deletando os 2 primeiros itens o Erro mencionado i Apresentado
            azItens := aClone( aItensPV )			
            If nOper == 4
				fDelDestino( aCabecPV, azItens, cFilDest, cPVDest, cFilOrig, cPVOrig, aCpoSC6 )
			Endif		    
		    
			//-- Realiza a gravacao 
			MsExecAuto( { |x,y,z| Mata410( x, y, z) }, aCabecPV, aItensPV, nOper )

			If lMsErroAuto
				//MostraErro()
				ConOut( "##### Inicio erro rotina AlteraPV() no programa U_REFATA01() #####" )
				cFileLog := NomeAutoLog()
				cMsg     := MemoRead( cFileLog )
				If !Empty( cMsg )
					ConOut( cMsg )
				Endif
				ConOut( "##### Fim erro rotina AlteraPV() no programa U_REFATA01() #####" )
			EndIf
		EndIf
	EndIf

	//-- Restaura filial da valiavel "cFilAnt"
	cFilAnt := cFilAtual 
	RestArea( aAreaSC9 )
    Restarea( aAreaSC6 )
    Restarea( aAreaSC5 ) 
    Restarea( aAreaSB2 )
    Restarea( aAreaSB1 )
	RestArea( aArea )

Return


/*/{Protheus.doc} GetCliDest
Retorna Cliente - Codigo, Loja e Nome
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 10/05/2022
@param cEmp, character, Codigo da empresa
@param cFil, character, Codigo da filial
@return array, Array com dados da empresa destino
/*/
Static Function GetCliDest( cEmp, cFil )
	Local aArea    := GetArea()
    Local aAreaSA1 := SA1->( GetArea("SA1") )
	Local aAreaSM0 := SM0->( GetArea("SM0") )
	Local aRet     := {}
	Local cCGC     := ""
	Local cEst     := ""
	
    Default cEmp := cEmpAnt
	Default cFil := GetMV( "RE_FILDEST", .F., "0201" )

	DbSelectArea("SA1")
	SA1->( DbSetOrder(3) )

    DbSelectArea("SM0")
	SM0->( DbSetOrder(1) )

	If SM0->( DbSeek( cEmp + cFil ) )
		cCGC := SM0->M0_CGC
		cEst := SM0->M0_ESTENT
	Endif

	If SA1->( DbSeek( xFilial("SA1") + cCGC ) )
		While SA1->( !Eof() .And. xFilial("SA1") + cCGC  == xFilial("SA1") + A1_CGC )
			If SA1->A1_EST == cEst
				aAdd( aRet, SA1->A1_COD  )
				aAdd( aRet, SA1->A1_LOJA )
				aAdd( aRet, SA1->A1_NOME )
				Exit
			Endif

			SA1->( DbSkip() )
		Enddo
	Else
		aAdd( aRet, "" )
		aAdd( aRet, "" )
		aAdd( aRet, "" )
	Endif

	RestArea( aAreaSM0 )
    RestArea( aAreaSA1 )
	RestArea( aArea )

Return aClone( aRet )


/*/{Protheus.doc} GetCpoSC5
Retorna os campos da tabela SC5
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 10/05/2022
@param aCpoSC5, array, Campos da SC5, retorna por referencia
/*/
Static Function GetCpoSC5( aCpoSC5 )
    Local aArea     := GetArea()
    Local aAreaSX3  := SX3->( GetArea("SX3") )
    Local cNaoCampo := "C5_NUM/C5_LOJAENT/C5_XFILORI/C5_XPVORIG/C5_CONDPAG/C5_TPFRETE/C5_MENPAD/C5_XFILDES/C5_XPVDEST/C5_CLIENTE/C5_LOJACLI/C5_XCLIORI/C5_XDESCLI/C5_XAGENCI/C5_XDVAGE/C5_XNUMCON/C5_XDVCTA"

	DbSelectArea("SX3")
	SX3->( DbSetOrder(1) )

	//-- Carrega campos do cabecalho do pedido de vendas (SC5)
	SX3->( DbSeek( "SC5" ) )
	While SX3->( !Eof() ) .And. SX3->X3_ARQUIVO == "SC5"
		If X3Uso( SX3->X3_USADO ) .And.  ( SX3->X3_TIPO $ "C/N/D" ) .And.;
		  ( SX3->X3_CONTEXT # "V" ) .And.  !( AllTrim( SX3->X3_CAMPO ) $ cNaoCampo )

			aAdd( aCpoSC5, { SX3->X3_CAMPO, SX3->X3_TIPO } )
		Endif

		SX3->( DbSkip() )
	Enddo

    RestArea( aAreaSX3 )
	RestArea( aArea )

Return


/*/{Protheus.doc} GetCpoSC6
Retorna os campos da tabela SC6
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 10/05/2022
@param aCpoSC6, array, Campos da SC6, retorna por referencia
/*/
Static Function GetCpoSC6( aCpoSC6 )
    Local aArea     := GetArea()
    Local aAreaSX3  := SX3->( GetArea("SX3") )
    Local cIncCampo := "C6_ITEM/C6_PRODUTO/C6_PRUNIT/C6_PRCVEN/C6_TES/C6_QTDVEN"

	DbSelectArea("SX3")
	SX3->( DbSetOrder(1) )

	//-- Carrega campos dos itens do pedido de vendas (SC6)
	SX3->( DbSeek( "SC6" ) )
	While SX3->( !Eof() ) .And. SX3->X3_ARQUIVO == "SC6"
	    If AllTrim( SX3->X3_CAMPO ) == "C6_TES"
		   SX3->( DbSkip() )
		   loop
		Endif  

		If X3Uso( SX3->X3_USADO ) .And. ( SX3->X3_TIPO $ "C/N/D" ) .And. ( SX3->X3_CONTEXT # "V" ) .And.;
		  ( ( AllTrim( SX3->X3_CAMPO ) $ cIncCampo ) .Or. X3Obrigat( SX3->X3_CAMPO ) ) .And. ( SX3->X3_NIVEL <= 1 )

			aAdd( aCpoSC6, { SX3->X3_CAMPO, SX3->X3_TIPO } )
		Endif

		SX3->( DbSkip() )
	Enddo
    //-- Ocorreu nco conformidades na Gravagco do CFOP para NF de Servigo 
	//-- Por esta razco o TES sera o Ultimo Campo Obrigatsrio no Acols
	//-- 27/02/2023
    aAdd( aCpoSC6, { "C6_TES   ", "C" } )	

    RestArea( aAreaSX3 )
	RestArea( aArea )

Return


/*/{Protheus.doc} GetProd
Retorna o codigo do produto de servico
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 28/06/2022
@param cProdRef, character, Codigo de servico
@return character, Codigo do produto
/*/
Static Function GetProd(cProdRef)
    Local cCodServ := GetMV( "RP_CODSERV", .F., "" )
    Local cGetProd := ""

	/*Cadastro o novo codigo de servico iniciado com "SV-" e terminado com o codigo 
	do PA para ser usado no novo processo de producao na industria.*/
	//cGetProd := "SV-" + AllTrim( cProdRef )
	cGetProd := Padr( "SV-" + AllTrim( cProdRef ), Len( SB1->B1_COD ) )
	
	//-- Rotina para cadastro de produtos
	U_REPCPA02( cCodServ, cGetProd )

Return cGetProd

/*/{Protheus.doc} fDelDestino
Verifica a Necessidade de Exclusco de Itens Destino antes da Alteragco dos mesmos
@type function
@version 1.0 
@author Dothink - Marcos Aversa
@since 17/03/2023
@param aCabecPV, array, Cabegalho
@param axItensPV, array, Itens
@param cFilDest, character, Filial Destino
@param cPVDest, character, Pedido Destino
@param cFilOrig, character, Filial Origem
@param cPVOrig, character, Pedido Origem
/*/
Static Function fDelDestino( aCabecPV, axItensPV, cFilDest, cPVDest, cFilOrig, cPVOrig, aCpoSC6  )
Local aArea     := GetArea()
Local aAreaSB1  := SB1->( GetArea() )
Local aAreaSB2  := SB2->( GetArea() )
Local aAreaSC5  := SC5->( GetArea() )
Local aAreaSC6  := SC6->( GetArea() )
Local aAreaSC9  := SC9->( GetArea() )
Local nQtdItens := 0
Local nI := 1
Local aItem     := {}
Local cxItem    := ""
Local lExclui   := .T.

Default axItensPV := {}

dbSelectArea("SC6")
nRegSC6 := SC6->(Recno())
If Len( axItensPV ) > 0
   If SC6->( DbSeek( cFilDest + cPVDest ))
      bAcao:= {|| nQtdItens ++ } 
      dbEval(bAcao,,{|| SC6->(!Eof()) .and. SC6->C6_FILIAL + SC6->C6_NUM == cFilDest + cPVDest },,,.T.) 
   Endif 
Endif
dbGoto(nRegSC6)

If Len( axItensPV ) > 0  .AND.   Len( axItensPV ) < nQtdItens  .AND. nQtdItens <> 0
    axItensPV := {}
	//--Posiciona no Pedido Destino
	dbSelectArea("SC5")  
	If SC5->( DbSeek( cFilDest + cPVDest )) .AND. SC6->( DbSeek( cFilDest + cPVDest ))
		While SC6->( !Eof() .and. SC6->C6_FILIAL + SC6->C6_NUM == cFilDest + cPVDest )
			//-- Se algum item ja foi faturado ou produzido, nao exclui o pedido destino
			If !Empty(SC6->C6_NOTA) .Or. SC6->C6_XJAPROD == "1"
				axItensPV := {}
				Exit
			EndIf
		    //--Guarda Recno Atual da SC6
			cxItem  := SC6->C6_ITEM
            nRegSC6 := SC6->(Recno())	
			//--Pesquisa no Item SC6 - Origem se Existe
			//--Se Existir nco sera necessario tratamento nessa Rotina, caso contrario, efetuaremos a exclusco
			//--do item.
			If SC6->( dbSeek( cFilOrig + cPVOrig + cxItem  ))	
			   lExclui := .F.
			Else    
			   lExclui := .T.			
		    Endif
			SC6->( Dbgoto( nRegSC6 ))

			aItem := {}
			If SC6->C6_QTDEMP > 0
    	        dbSelectArea("SC9")												
				SC9->(dbSetOrder(1))
				If SC9->( DbSeek( SC6->C6_FILIAL + SC6->C6_NUM + SC6->C6_ITEM ) )
    	            RecLock("SC9", .F.)
        	        SC9->(a460Estorna(.T.))   // Estorna o que estava liberado no sdc e sc9
            	    SC9->(MsUnlock())
    			EndIf
			EndIf
			For nI := 1 To Len( aCpoSC6 )
				aAdd( aItem, { AllTrim( aCpoSC6[nI, 01] ), SC6->&(aCpoSC6[nI, 01]), Nil } )
			Next
			If lExclui
               aadd( aItem ,{"AUTDELETA","S",Nil})		
			Else
               aadd( aItem ,{"AUTDELETA","N",Nil})					
			Endif	
			aAdd( axItensPV, aItem )
			SC6->( DbSkip() )
		EndDo
		//-- Grava Alteracao/Exclusao do Pedido
		If !Empty( aCabecPV ) .And. !Empty( axItensPV )
			//-- Realiza a gravacao 
			MsExecAuto( { |x,y,z| Mata410( x, y, z) }, aCabecPV, axItensPV, 4 )
			If lMsErroAuto
				//MostraErro()
				ConOut( "##### Inicio erro rotina AlteraPV() no programa U_REFATA01() #####" )
				cFileLog := NomeAutoLog()
				cMsg     := MemoRead( cFileLog )
				If !Empty( cMsg )
					ConOut( cMsg )
				Endif
				ConOut( "##### Fim erro rotina AlteraPV() no programa U_REFATA01() #####" )
			EndIf
		Endif    
	Endif
Endif

RestArea( aAreaSC9 )
Restarea( aAreaSC6 )
Restarea( aAreaSC5 ) 
Restarea( aAreaSB2 )
Restarea( aAreaSB1 )
RestArea( aArea )
Return
