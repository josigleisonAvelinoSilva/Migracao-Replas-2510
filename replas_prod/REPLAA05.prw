#include 'protheus.ch'
#include 'parmtype.ch'

User Function REPLAA05()
	Local cEmpFil    := GetNewPar("MV_XFILEST","0102,0103,0302,0201")
	Local cXB1_GRUPO := "%" + FormatIn(GetNewPar("MV_XB1GRUP","2,3"),",") + "%"
	
	Local aEmpresas := FWLoadSM0(.T.,.F.)
	Local aDados	:= {}
	Local aAux		:= {}
	Local aInteface := FWGetDialogSize( oMainWnd ) 	// Array com tamanho da janela.
	Local aSeek		:= {}
	
	Local oDlg      := Nil
	Local oBrw		:= FWBrowse():New()
	
	Local nI,nJ,nP	:= 0
	Local nPosFil	:= 0
	Local nQtdFil   := 0
	Local nPos
	
	Aadd( aSeek, { 'Código',    {{"","C",TamSX3("B1_COD")[1],0,'Código',,}} } )	// "Código" ### "Código"
	Aadd( aSeek, { 'Descrição', {{"","C",TamSX3("B1_DESC")[1],0,'Descrição',,}}}) // "Descrição" ### "Descrição"
	
	aFields := {}
	AAdd(aFields,{'Código','Código','C',TamSX3("B1_COD")[1],0,pesqPict("SB1","B1_COD")})
	AAdd(aFields,{'Descrição','Descrição','C',TamSX3("B1_DESC")[1],0,pesqPict("SB1","B1_DESC")})
	AAdd(aFields,{"Local","Local",'C',TamSX3("B2_LOCAL")[1],0,pesqPict("SB2","B2_LOCAL")})
	AAdd(aFields,{"Grupo","Grupo",'C',TamSX3("B1_GRUPO")[1],0,pesqPict("SB1","B1_GRUPO")})
	AAdd(aFields,{"Fabricante","Fabricante",'C',TamSX3("B1_FABRIC")[1],0,pesqPict("SB1","B1_FABRIC")})
	
	oBrw:addColumn({"Código"                , {|| aDados[oBrw:nAt,01]}, "C", pesqPict("SB1","B1_COD")    , 1, tamSx3("B1_COD")[1]/2    ,                            , .T. , , .F.,, "xB1_COD",, .F., .T.,                                    , "xB1_COD"    })
	oBrw:addColumn({"Descrição"                , {||aDados[oBrw:nAt,02]}, "C", pesqPict("SB1","B1_DESC")    , 1, tamSx3("B1_DESC")[1]/2    ,                            , .T. , , .F.,, "xB1_DESC",, .F., .T.,                                    , "xB1_DESC"    })
	oBrw:addColumn({"Local"                , {||aDados[oBrw:nAt,03]}, "C", pesqPict("SB2","B2_LOCAL")    , 1, tamSx3("B2_LOCAL")[1]/2    ,                            , .T. , , .F.,, "xB2_LOCAL",, .F., .T.,                                    , "xB2_LOCAL"    })
	oBrw:addColumn({"Grupo"                , {||aDados[oBrw:nAt,04]}, "C", pesqPict("SB1","B1_GRUPO")    , 1, tamSx3("B1_GRUPO")[1]/2    ,                            , .T. , , .F.,, "xB1_GRUPO",, .F., .T.,                                    , "xB1_GRUPO"    })
	
	nPosFil := 4
	nQtdFil := 0
	
	For nI:=1 to len(aEmpresas)
		If Alltrim(aEmpresas[nI,2]) $ cEmpFil
			nPosFil++
			aadd(aAux,aEmpresas[nI,7]) // Qtd Saldo Filial
			oBrw:addColumn({Alltrim(aEmpresas[nI,7])                , &("{||aDados[oBrw:nAt,"+Alltrim(Str(nPosFil))+"]}") , "C", nil/*pesqPict("SB2","B2_QATU")*/    , 2, tamSx3("B2_QATU")[1]/2    ,  nil/*tamSx3("B2_QATU")[2]*/                          , .F. , , .F.,, "x"+aEmpresas[nI,2],, .F., .T.,                                    , "x"+aEmpresas[nI,2]    })
		EndIf
	Next
	
	//B1_XINDFLU campo IF
	nPosFil++
	oBrw:addColumn({"IF"                ,  &("{||aDados[oBrw:nAt,"+Alltrim(Str(nPosFil))+"]}"), "C", pesqPict("SB1","B1_XINDFLU")    , 1, tamSx3("B1_XINDFLU")[1]/2    ,                            , .T. , , .F.,, "xB1_XINDFLU",, .F., .T.,                                    , "xB1_XINDFLU"    })
	nPosFil++
	oBrw:addColumn({"Fabricante"                ,  &("{||aDados[oBrw:nAt,"+Alltrim(Str(nPosFil))+"]}"), "C", pesqPict("SB1","B1_FABRIC")    , 1, tamSx3("B1_FABRIC")[1]/2    ,                            , .T. , , .F.,, "xB1_FABRIC",, .F., .T.,                                    , "xB1_FABRIC"    })
	nPosFil++
	oBrw:addColumn({"Grp Prod"                ,  &("{||aDados[oBrw:nAt,"+Alltrim(Str(nPosFil))+"]}"), "C", pesqPict("SB1","B1_XGRUPO")    , 1, tamSx3("B1_XGRUPO")[1]/2    ,                            , .T. , , .F.,, "xB1_XGRUPO",, .F., .T.,{'0=Outros', '1=Filme', '2=Resina Nacional','3=Resina Importada'}, "xB1_XGRUPO"    })
	
	FwMsgRun(, {|| aDados:=  RetDaD(aEmpresas,cEmpFil,cXB1_GRUPO)  }, , 'Consultando Estoque, aguarde...')
	
	FwMsgRun(, {||  aSort(aDados,,,{|x,y| x[1]+x[2] < y[1]+y[2]} ) },  'Ordenando registros, aguarde...')
	
	DEFINE DIALOG oDlg TITLE 'Estoque REPLAS (Resinas)' FROM aInteface[1],aInteface[2] TO aInteface[3],aInteface[4] PIXEL  
		oBrw:setDataArray()
		oBrw:setArray( aDados )
		oBrw:setOwner( oDlg )
		oBrw:SetLocate() // Habilita a Localização de registros
		oBrw:SetSeek(,aSeek) 	
		oBrw:SetFieldFilter(aFields)
		oBrw:SetUseFilter()
		oBrw:Activate()
	ACTIVATE DIALOG oDlg CENTERED	
	
	oBrw:DeActivate()
return

Static Function RetDaD(aEmpresas,cEmpFil,cXB1_GRUPO)
	Local aDados := {}
	Local aLin   := {}
	
	Local nI, nJ := 0
	Local nPos   := 0
	Local nCount := 0
	
	For nI:=1 to len(aEmpresas)
		If Alltrim(aEmpresas[nI,2]) $ cEmpFil
			If Select('TRBESTOQ') > 0
				TRBESTOQ->(DbCloseArea())
			EndIf
			
			BeginSQL Alias 'TRBESTOQ'
				SELECT
					B2_COD,
					B2_LOCAL,
					SUM(B2_QATU - B2_RESERVA) DISPONIVEL
				FROM
					%Table:SB2% SB2
				   INNER JOIN %Table:SB1% SB1
				           ON B1_COD = B2_COD
				          AND B1_XGRUPO IN %Exp:cXB1_GRUPO%
				WHERE
					B2_FILIAL = %Exp:aEmpresas[nI,2]% 
					AND SB2.%NotDel%
				GROUP BY
					B2_COD,
					B2_LOCAL
			EndSQL
			
			If !TRBESTOQ->(EoF())
				SB1->(DbSetOrder(1))
				While !TRBESTOQ->(EoF())
					aLin := {}
					If SB1->(DbSeek(xFilial("SB1")+TRBESTOQ->B2_COD))
						If Len(aDados) == 0 
						 	nPos := 0
						Else
							nPos := Ascan(aDados,{|x| x[1] == SB1->B1_COD .and. x[3] == TRBESTOQ->B2_LOCAL  })
						Endif
						
						If nPos == 0
							aadd(aLin, SB1->B1_COD)
							aadd(aLin, SB1->B1_DESC)
							aadd(aLin, TRBESTOQ->B2_LOCAL)
							aadd(aLin, SB1->B1_GRUPO)
							
							For nJ:=1 to len(aEmpresas)
								If Alltrim(aEmpresas[nJ,2]) $ cEmpFil
									If aEmpresas[nI,2] == aEmpresas[nJ,2] 
										aadd(aLin, Transform(TRBESTOQ->DISPONIVEL,pesqPict("SB2","B2_QATU")))
									Else
										aadd(aLin, Transform(0,pesqPict("SB2","B2_QATU")))
									EndIf
								EndIf
							Next
							
							aadd(aLin, SB1->B1_XINDFLU)
							aadd(aLin, SB1->B1_FABRIC)
							aadd(aLin, SB1->B1_XGRUPO)
							
							aadd(aDados, aLin)
						Else
							nCount := 0
							For nJ:=1 to len(aEmpresas)
								If Alltrim(aEmpresas[nJ,2]) $ cEmpFil
									nCount++
									If aEmpresas[nI,2] == aEmpresas[nJ,2] 
										aDados[nPos,nCount+4] :=  Transform(TRBESTOQ->DISPONIVEL,pesqPict("SB2","B2_QATU"))
									EndIf
								EndIf
							Next
						EndIf
					EndIf
					TRBESTOQ->(DbSkip())
				End
			EndIf
			
			TRBESTOQ->(DbCloseArea())
		EndIf
	Next
Return(aDados)
