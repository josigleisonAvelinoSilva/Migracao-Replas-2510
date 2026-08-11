#Include 'Protheus.ch'
#define STR0118 "Aten??o"
#define STR0117 "Alguns itens n?o tiveram a prov?ncia alterada pois possuem impostos gravados em um mesmo campo."
#define STR0127 "SIGAGCT"
#define STR0128 "Este pedido foi vinculado a um contrato e por isto n?o pode ter este campo alterado."

Static lCrmFilEnt := Nil

User Function A410CliReplas(cA410CliV,cA410Cli,lInterface)

Local lRetorno  := .F.
Local cLoja     :=""
Local lConPadOk := .F.
Local nEndereco	:= 0
Local nX		:= 0
Local nProv		:= 0
Local oDlg
Local aArea  	:= {}
Local aArea2  := {}
Local cProxCli  := ""
Local cProvAnt	:= ""
Local cTes		:= ""
Local nPosProv  := Ascan(aHeader,{|x| Alltrim(x[2]) == "C6_PROVENT"})
Local nPosTes   := Ascan(aHeader,{|x| Alltrim(x[2]) == "C6_TES"})
Local lBloq := .F. //Vari?vel de controle para verificar se o cliente/fornecedor + loja estiver bloqueado
Local lRet := .T.

DEFAULT lInterface := .T.

If nModulo == 73
	lRet:= U_LibReplas("SA1")
	If LRet == .F.
		Return LRet
	EndIf	 
EndIf	
	
l410Auto := If (Type("l410Auto") == "U",.f.,l410Auto)
l416Auto := If (Type("l416Auto") == "U",.f.,l416Auto)

If !(l416Auto) .and. !(l410Auto) .And. lInterface
	oDlg	:=	GetWndDefault()
EndIf

cA410CliV	:=	If(cA410CliV==Nil,ReadVar(),cA410CliV)
cA410Cli		:= If(cA410Cli==Nil,&(cA410CliV),cA410Cli)

//?ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//³Se cliente/fornecedor possui o mesmo codigo em lojas diferentes, ³
//³deixa campo C5_LOJACLI vazio para usuario preencher.             ³
//?ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
dbSelectArea(IIF(M->C5_TIPO$"DB","SA2","SA1"))
If l410Auto
	nPos := aScan( aAutoCab, {|x| Alltrim( Upper( x[1] ) ) == "C5_LOJACLI" } )
	If nPos > 0
		cLoja := aAutoCab[nPos][2]
	Endif
Else	
	cLoja := IIf(M->C5_TIPO$"DB",SA2->A2_LOJA,SA1->A1_LOJA)
EndIf

If !l410Auto

	aArea	:= GetArea()
	If Empty(cLoja)
		MsSeek( xFilial()+cA410Cli,.F.)
	Else
		MsSeek( xFilial()+cA410Cli+cLoja,.F.)
	EndIf	 
	aArea2	:= GetArea()
		
	dbSkip()
	cProxCli := &(IIF(M->C5_TIPO$"DB","SA2->A2_COD","SA1->A1_COD"))
	cProxCli := IIF(cProxCli <> cA410Cli,"",cProxcli)

	MsSeek( xFilial()+cA410Cli+cLoja,.F.)
	If (Recno() == aArea2[3]) .And. !Empty(M->C5_LOJACLI)
		cProxCli := ""
	EndIf	

	RestArea(aArea2)
	If Empty(cProxCli)
		cLoja := IIf(M->C5_TIPO$"DB",SA2->A2_LOJA,SA1->A1_LOJA)
	Else
		cLoja := Space( Len(SA2->A2_LOJA) )	
		M->C5_LOJACLI := cLoja
	EndIf	
	
	RestArea(aArea)
	
EndIf

If ( !Empty(cA410Cli) )
	dbSelectArea(IIF(M->C5_TIPO$"DB","SA2","SA1"))
	dbSetOrder(1)
	//?ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Procura por Codigo + Loja                                               ³
	//?ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	If ( !MsSeek( xFilial()+cA410Cli+cLoja,.F.) )
		//?ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//³Procura por Codigo ³
		//?ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		If !MsSeek( xFilial()+cA410Cli,.F.)
			//?ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
			//³Procura pelo nome do cliente                          ³
			//?ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
			dbSetOrder(2)
			If ( !MsSeek( xFilial()+Trim(cA410Cli),.F.) )
				//?ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
				//³Procura pelo CGC                                      ³
				//?ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
				dbSetOrder(3)
				If ( MsSeek( xFilial()+Trim(cA410Cli),.F.) )
					lRetorno := .T.
				Else
					lRetorno := .F.
				EndIf
			Else
				lRetorno := .T.
			EndIf
			If lRetorno
				&(cA410CliV) := IF(M->C5_TIPO $ "DB",SA2->A2_COD,SA1->A1_COD)
			EndIf
		Else
			lRetorno := .T.
		EndIf
	Else
		lRetorno := .T.
	EndIf
EndIf
If ( lRetorno )
	If M->C5_TIPO $ "DB"
	
		If SA2->A2_MSBLQL == '1' .AND. Empty(cLoja)
			lBloq = .T.
		Else
			cLoja    := IIf(Empty(cProxcli),SA2->A2_LOJA,Space(Len(SA2->A2_LOJA)))		
		EndIf
		
		cA410Cli  := SA2->A2_COD   
		lConPadOk := .T.
		If cPaisLoc =="ARG" 
			cProvAnt	  := M->C5_PROVENT
			M->C5_PROVENT := SA2->A2_EST // Provincia de Entrega do Fornecedor
		Endif	
	Else
	
		If SA1->A1_MSBLQL == '1' .AND. Empty(cLoja)
			lBloq = .T.
		Else
			cLoja    := IIf(Empty(cProxcli),SA1->A1_LOJA,Space(Len(SA1->A1_LOJA)))		
		EndIf
	
		cA410Cli := SA1->A1_COD
		lConPadOk := .T.
		If cPaisLoc =="ARG" 
			cProvAnt	  := M->C5_PROVENT
			M->C5_PROVENT := SA1->A1_EST // Provincia de Entrega do Cliente
		Endif	
	EndIf
	If cPaisLoc == "COL" 
		If M->C5_TIPO $ "DB"
			M->C5_CODMUN := SA2->A2_COD_MUN // Municipio de Entrega do Fornecedor
		Else
			M->C5_CODMUN := SA1->A1_COD_MUN // Municipio de Entrega do Cliente
		EndIf
	Endif	
	If cPaisLoc == "ARG"
        If nPosProv > 0
   			If cProvAnt <> M->C5_PROVENT
				For nX := 1 to Len(aCols)
					cTes := aCols[nX,nPosTes]
					If VerProEnIt(M->C5_PROVENT,cTes,.F.,.F.)
						aCols[nX,nPosProv]:= M->C5_PROVENT
					Else
						nProv++
					Endif
				Next
				If nProv > 0
					MsgAlert(STR0117,STR0118) //Alguns itens n?o tiveram a prov?ncia alterada pois possuem impostos gravados em um mesmo campo.
				Endif
			Endif	
		Endif
	Endif
Else
	Help(" ",1,"A410NCLIE")
EndIf

If !Empty(M->C5_MDCONTR) .And. M->C5_CLIENTE+M->C5_LOJACLI # CNA->CNA_CLIENT+CNA->CNA_LOJACL
	Aviso(STR0127,STR0128,{"Ok"}) //SIGAGCT - Este pedido foi vinculado a um contrato e por isto n?o pode ter este campo alterado.
	lRetorno := .F.
EndIf

//?ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//³Quando for alteracao deve-se verificar se o pedido ja foi entregue, 		³
//³em caso afirmativo, nao deve-se permitir alterar o cliente.          	³
//?ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
If ( lRetorno ) .And. ALTERA .And. !Empty( cA410Cli )
	dbSelectArea("SC5")
	dbSetOrder(1)
	If ( MsSeek(xFilial("SC5")+M->C5_NUM,.F.) )
		If ( SC5->C5_CLIENTE != cA410Cli )
			dbSelectArea("SC6")
			dbSetOrder(1)
			MsSeek(xFilial("SC6")+M->C5_NUM)
			While ( !Eof() .And. xFilial("SC6") == SC6->C6_FILIAL .And.;
					SC6->C6_NUM 	== SC5->C5_NUM )
				If ( SC6->C6_QTDENT != 0 .Or. !Empty(SC6->C6_NOTA) )
					lRetorno := .F.
					Help(" ",1,"A410CLIOK")
					Exit
				EndIf
				dbSkip()
			EndDo
		EndIf
	EndIf
EndIf
//?ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//³Efetua o Acerto na Enchoice                                             ³
//?ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
If ( lConPadOk .And. lRetorno ) .And. ("C5_CLIENTE" $ cA410CliV)
	M->C5_CLIENTE := cA410Cli
	M->C5_CLIENT  := cA410Cli
	If !lBloq
		M->C5_LOJAENT := cLoja
		M->C5_LOJACLI := cLoja
		If lInterface
			nEndereco := Ascan(aGets,{ |x| Subs(x,9,10) == "C5_CLIENTE" } )
			If nEndereco > 0
				aTela[Val(Subs(aGets[nEndereco],1,2))][Val(Subs(aGets[nEndereco],3,1))*2] := cA410Cli
			EndIf
			nEndereco     := Ascan(aGets,{ |x| Subs(x,9,10) == "C5_LOJAENT" } )
			If nEndereco > 0
				aTela[Val(Subs(aGets[nEndereco],1,2))][Val(Subs(aGets[nEndereco],3,1))*2] := M->C5_LOJAENT
			EndIf
			nEndereco     := Ascan(aGets,{ |x| Subs(x,9,10) == "C5_LOJACLI" } )
			If nEndereco > 0
				aTela[Val(Subs(aGets[nEndereco],1,2))][Val(Subs(aGets[nEndereco],3,1))*2] := M->C5_LOJACLI
			EndIf
		EndIf
	EndIf
ElseIf ( lConPadOk .And. lRetorno ) .And. ("C5_CLIENT" $ cA410CliV)
	M->C5_LOJAENT := cLoja	
EndIf
//?ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//³Se o pedido estiver sendo gerado a partir de uma aprovacao de Orcamento³
//³o conteudo da READVAR sera limpo para a chamada da a410Loja()          ³
//?ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
If l416Auto
	__READVAR := ""
EndIf
                   
If !Empty(cLoja) .And.!lBloq	
	lRetorno := lRetorno .And. A410Loja(IIF("C5_CLIENTE"$cA410CliV,"C5_LOJACLI","C5_LOJAENT"),IIF("C5_CLIENTE"$cA410CliV,M->C5_LOJACLI,M->C5_LOJAENT),lInterface,Upper(AllTrim(cA410CliV)) == "M->C5_CLIENT" )
EndIf
	
//?ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//³Atualiza o Rodape                                                       ³
//?ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
If lRetorno .And. lInterface
	Ma410Rodap()
EndIf
Return ( lRetorno ) 

User Function LibReplas(cAliasEnt, cChave, nOrdem)

Local aArea		:= GetArea()
Local aAreaAO4	:= AO4->(GetArea()) 
Local cAliasAO4	:= GetNextAlias()
Local cFiltro		:= ""
Local lRetorno		:= .T.
Local cSQLLike		:= ""
Local nTam			:= 1

Default cAliasEnt 	:= ""
Default cChave    	:= ""
Default nOrdem    	:= 0

If !Empty(cAliasEnt) .And. nModulo == 73
	
	cFiltro 	:= U_CRMXFilEnt(cAliasEnt,.T.)
	
	If !Empty(cFiltro)
		
		cFiltro := "%" + cFiltro + "%"
		
		Do Case
			Case cAliasEnt == "AC3"
		 		nTam := TamSX3("AC3_CODCON")[1]
		 	Case cAliasEnt == "AC4"
		 		nTam := TamSX3("AC4_PARTNE")[1]
		 	Case cAliasEnt == "ACH"
		 		nTam := TamSX3("ACH_CODIGO")[1] + TamSX3("ACH_LOJA")[1]
			Case cAliasEnt == "AD1"
		 		nTam := TamSX3("AD1_NROPOR")[1]
		 	Case cAliasEnt == "ADY"
		 		nTam := TamSX3("ADY_PROPOS")[1] + TamSX3("ADY_PREVIS")[1]
		 	Case cAliasEnt == "AO3"
		 		nTam := TamSX3("AO3_CODUSR")[1]
		 	Case cAliasEnt == "AOC"
		 		nTam := TamSX3("AOC_CODIGO")[1]
		 	Case cAliasEnt == "SA1"
		 		nTam := TamSX3("A1_COD")[1] + TamSX3("A1_LOJA")[1]
		 	Case cAliasEnt == "SA2"
		 		nTam := TamSX3("A2_COD")[1] + TamSX3("A2_LOJA")[1]
		 	Case cAliasEnt == "SA3"
		 		nTam := TamSX3("A3_COD")[1]
		 	Case cAliasEnt == "SC5"
		 		nTam := TamSX3("C5_NUM")[1]
		 	Case cAliasEnt == "SU5"
		 		nTam := TamSX3("U5_CODCONT")[1]
		 	Case cAliasEnt == "SUO"
		 		nTam := TamSX3("UO_CODCAMP")[1]
		 	Case cAliasEnt == "SUS"
		 		nTam := TamSX3("US_COD")[1] + TamSX3("US_LOJA")[1]
		 	Case cAliasEnt == "AOH"
		 		nTam := TamSX3("AOH_CODIGO")[1]
		End Case
	
		If Empty(cChave)
			cChave := &(ReadVar())
			cChave := Left(cChave, nTam)
		EndIf
		
		DbSelectArea(cAliasEnt)
		nOrdem := If(nOrdem == 0,IndexOrd(),nOrdem)
		(cAliasEnt)->(DbSetOrder(nOrdem))
		
		DbSelectArea("AO4")		// Controle de Privilegios
		AO4->(DbSetOrder(1))		// AO4_FILIAL + AO4_ENTIDA + AO4_CHVREG + AO4_CODUSR
		
		If !Empty(cChave)
			
			If (cAliasEnt)->(MsSeek(xFilial(cAliasEnt)+cChave)) 
				
				cSQLLike := "%'%" + Alltrim( xFilial(cAliasEnt) + cChave )+ "%'%"
				
				If Select(cAliasAO4) > 0
					(cAliasAO4)->(DbCloseArea())
				EndIf
				
				BeginSql Alias cAliasAO4
					SELECT AO4.AO4_CHVREG
					FROM %Table:AO4% AO4
					WHERE AO4.AO4_FILIAL = %xFilial:AO4% AND %Exp:cFiltro% AND AO4_CHVREG LIKE %Exp:cSQLLike% AND AO4.%NotDel%
				EndSql
					
				lRetorno := !(cAliasAO4)->(Eof())
					
				(cAliasAO4)->(DbCloseArea())
				 
				If !lRetorno
					Help("",1,"CRMLIBREG")
				EndIf
				
			Else
				lRetorno := .F.
				Help("",1,"REGNOIS")
			EndIf
		
		Endif
		
	EndIf
	
EndIf

RestArea(aAreaAO4)
RestArea(aArea)

Return(lRetorno)

User Function CRMXFilEnt(cAliasEnt, lExpSql)

Local aArea			:= {}
Local cFiltro		:= ""
Local cCodUsr		:= ""
Local cIdUserPaper	:= ""
Local lChgUserPaper	:= .F.
Local aNvlEstrut	:= {}
Local aNlvEstFmt	:= {}
Local lExtEstNeg	:= .F.
Local aRetEqUd 		:= {}
Local aPEVar		:= {}
Local nLevel		:= 0
Local nLenNlvEst	:= 0
Local __aUserRole := {}
Local __aFilEntCache := {'','','',''}

Default cAliasEnt	:= ""
Default lExpSQL		:= .F.

If nModulo == 73
	aArea := GetArea()
	If !Empty( __aUserRole ) 
		cCodUsr	 	 := __aUserRole[USER_PAPER_CODUSR]
		cIdUserPaper := __aUserRole[USER_PAPER_SEQUEN] + __aUserRole[USER_PAPER_CODPAPER]
	Else
		cCodUsr := CRMXCodUser()
	EndIf 

	If ( cCodUsr <> __aFilEntCache[1] .Or. cIdUserPaper <> __aFilEntCache[2] )
		lChgUserPaper := .T.
	EndIf

	lExtEstNeg := SuperGetMv("MV_CRMESTN",.F.,.F.)
	lExtEstNeg := GetNewPar('MV_REPCRM1',.F.)

	If ( cCodUsr <> "000000" .And. !Empty(cAliasEnt) .And. lExtEstNeg .And. cAliasEnt $ CRMXCtrlEnt() )
		If  ( lChgUserPaper .Or. cAliasEnt <> __aFilEntCache[3] )
			__aFilEntCache[1] := cCodUsr
			__aFilEntCache[2] := cIdUserPaper
			__aFilEntCache[3] := cAliasEnt
			
			aNvlEstrut	:= CRMXNvlEst(cCodUsr)
			aNlvEstFmt	:= CRMXFmtNvl(aNvlEstrut[1])
			aRetEqUd 	:= CRMXVdEqUd(cCodUsr)
			
			If lExpSQL 
				If aNvlEstrut[2] == 0
					cFiltro := " ( AO4_FILIAL ='" + xFilial("AO4") + "' AND AO4_ENTIDA = '" + cAliasEnt + "' AND (" 
					If SuperGetMv("MV_CRMUAZS",, .F.)
						cFiltro += "( AO4_CODUSR = '" + cCodUsr + "' AND ( AO4_USRPAP = '" + cIdUserPaper + "' OR AO4_USRPAP = ' ' ) ) "
					Else
						cFiltro += "AO4_CODUSR = '" + cCodUsr + "' "
					EndIf
					cFiltro += " AND ( ( AO4_DTVLD >= '" + dTos(MsDate()) + "' OR AO4_DTVLD = ' ' ) OR AO4_CTRLTT = 'T' ) ) )"
				Else
					cFiltro := " ( AO4_FILIAL ='" + xFilial("AO4") + "' AND AO4_ENTIDA = '" + cAliasEnt + "' AND ("
					If SuperGetMv("MV_CRMUAZS",, .F.)
						cFiltro += " ( AO4_CODUSR = '" + cCodUsr + "' AND ( AO4_USRPAP = '" + cIdUserPaper + "' OR AO4_USRPAP = ' ' ) ) "
					Else
						cFiltro += " AO4_CODUSR = '" + cCodUsr + "'"
					EndIf
				
					If	Len(aRetEqUd) > 0
						If	!Empty(aRetEqUd[1])
							cFiltro += " OR ( AO4_CODEQP = '"+Alltrim(aRetEqUd[1])+"' ) AND ( ( AO4_DTVLD >= '" + dTos(MsDate()) + "' OR AO4_DTVLD = '"+Space(08)+"' ) OR AO4_CTRLTT = 'T' ) "
						Endif  
		
						If	!Empty(aRetEqUd[2])
							cFiltro += " OR ( AO4_CODUND = '"+Alltrim(aRetEqUd[2])+"' ) AND ( ( AO4_DTVLD >= '" + dTos(MsDate()) + "' OR AO4_DTVLD = '"+Space(08)+"' ) OR AO4_CTRLTT = 'T' ) "
						Endif					
					Endif
								
					nLenNlvEst := Len( aNlvEstFmt )
					
					For nLevel := 1 To nLenNlvEst 
						If nLevel == 1
							cFiltro += " OR ( "
						EndIf
						cFiltro += "( AO4_IDESTN LIKE '" + aNlvEstFmt[nLevel] + "%' )"
						If( nLevel < nLenNlvEst ) 
							cFiltro += " OR "
						EndIf 
						If nLevel == nLenNlvEst
							cFiltro += " )  "	
						EndIf
					Next nLevel 
				
					cFiltro += " ) "
						
					cFiltro += " AND ( AO4_CTRLTT = 'T' OR ( AO4_DTVLD >= '" + dTos(MsDate()) + "' OR AO4_DTVLD = ' ' ) )  "
					
					cFiltro += " ) " 
					
				EndIf
			Else
				If aNvlEstrut[2] == 0		
					cFiltro := "( AO4_FILIAL ='" + xFilial("AO4") + "' .AND. AO4_ENTIDA == '" + cAliasEnt + "' .AND. ("
					If SuperGetMv("MV_CRMUAZS",, .F.)
						cFiltro += "( AO4_CODUSR == '" + cCodUsr + "' .AND. ( AO4_USRPAP == '" + cIdUserPaper + "' .OR. OR AO4_USRPAP == ' ' ) ) "
					Else
						cFiltro += "AO4_CODUSR == '" + cCodUsr + "' "
					EndIf
					cFiltro += ".AND. ( ( AO4_DTVLD >= MsDate() .OR. Empty(AO4_DTVLD) ) .OR. AO4_CTRLTT ) ) )"
				Else
					cFiltro := "( AO4_FILIAL ='" + xFilial("AO4") + "' .AND. AO4_ENTIDA == '" + cAliasEnt + "' .AND. ( ( ("
				
					For nLevel := 1 To Len( aNlvEstFmt )
						cFiltro += " ( AO4_IDESTN == '" + aNlvEstFmt[nLevel] + "' OR SubStr( AO4_IDESTN, 1, " + cBIStr( Len( aNlvEstFmt[nLevel] ) ) + " ) == '" + aNlvEstFmt[nLevel] + "' ) "		
						If( nLevel < Len( aNlvEstFmt ) ) 
							cFiltro += " .OR. "
						EndIf 		
					Next nLevel
				
					cFiltro += " )  "
					If SuperGetMv("MV_CRMUAZS",, .F.)
						cFiltro += " .OR. ( AO4_CODUSR == '" + cCodUsr + "' .AND. ( AO4_USRPAP = '" + cIdUserPaper + "' .OR. OR AO4_USRPAP == ' ' ) ) " "
					Else
						cFiltro += " .OR. AO4_CODUSR == '" + cCodUsr + "' "
					EndIf
					cFiltro += ") .AND. ( ( AO4_DTVLD >= MsDate() .OR. Empty( AO4_DTVLD ) ) .OR. AO4_CTRLTT ) ) "
					 
					If	Len(aRetEqUd) > 0
						If	!Empty(aRetEqUd[1])
							cFiltro += ".OR. ( ( AO4_CODEQP == '"+Alltrim(aRetEqUd[1])+"' ) .AND. ( ( AO4_DTVLD >= MsDate() .OR. Empty(AO4_DTVLD) ) .OR. AO4_CTRLTT  ) ) "					
						Endif  
		
						If	!Empty(aRetEqUd[2])
							cFiltro += ".OR. ( ( AO4_CODUND == '"+Alltrim(aRetEqUd[2])+"' ) .AND. ( ( AO4_DTVLD >= MsDate() .OR. Empty(AO4_DTVLD) ) .OR. AO4_CTRLTT  ) ) " 							
						Endif  
					Endif
					 
					cFiltro += " )"
				EndIf
			EndIf
			
			If lCrmFilEnt == Nil
				lCrmFilEnt := ExistBlock("CRMFILENT")
			EndIf

			If lCrmFilEnt
				aPEVar	:= {cAliasEnt, lExpSql, cFiltro}
				cFilPE := ExecBlock("CRMFILENT", .F., .F.,aPEVar)
				
				If ValType(cFilPE) == "C" .And. !Empty(cFilPE)
					cFiltro := cFilPE
				EndIf 
			EndIf
			
			__aFilEntCache[4] := cFiltro
		Else
			cFiltro := __aFilEntCache[4]
		EndIf
	EndIf
	
	RestArea(aArea)
	
EndIf

Return(cFiltro)
