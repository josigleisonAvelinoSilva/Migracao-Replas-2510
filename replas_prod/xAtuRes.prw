#include 'protheus.ch'
#include 'parmtype.ch'

user function xAtuRes(cProdDe,cProdAt,cLocProc,cGrpRps)
	Local _aParamINI:= {}
	Local _aRetIni 	:= {}
	Local lMsg		:= .F.
	local cOpc      := ""
	
	Default cProdDe := ""
	Default cProdAt := ""
	Default cLocProc := ""
	Default cGrpRps  := ""

	If IsInCallStack("U_REESTA02")
		Return
	EndIf
	
	If Empty(cProdDe+cProdAt+cLocProc)
		aAdd(_aParamINI,{9,"Recalculo de Reservas - Parametros",150,7,.T.})
		aAdd(_aParamINI,{1,"Produto De"  ,Space(TamSx3("B1_COD")[1])   ,"","","SB1","",100,.F.}) 
		aAdd(_aParamINI,{1,"Produto Ate" ,Space(TamSx3("B1_COD")[1])   ,"","","SB1","",100,.T.})
		aAdd(_aParamINI,{1,"Local"       ,Space(TamSx3("B1_LOCPAD")[1]),"","","NNR","",050,.F.})
		aAdd(_aParamINI,{2,"Grupo Produt",cOpc, {"0=Outros","1=Filme","2=Resina Nacional","3=Resina Importada"}, 100, ".T.", .T.})
		
		If !ParamBox(_aParamINI,"Configuração",@_aRetIni)
		   	Return
		EndIf
		
		MV_PAR01 := _aRetIni[2]
		MV_PAR02 := _aRetIni[3]
		MV_PAR03 := _aRetIni[4]
		MV_PAR04 := _aRetIni[5]
		lMsg 	 := .T.
	Else
		MV_PAR01 := cProdDe
		MV_PAR02 := cProdAt
		MV_PAR03 := cLocProc
		MV_PAR04 := cGrpRps
		lMsg 	 := .F.
	Endif
	
	FWMsgRun(, {|| xAtu() },'Recalculo Reservas','Processando, aguarde...')
	
	If lMsg
		MsgAlert("Recálculo Finalizado")
	Endif
return

Static Function xAtu()
	Local cGrpReser :=  GetNewPar("MV_XGRPRES","2,3") 
	Local cQuery    := ""

	//Para todos os produtos identificados recalcula reserva
	If Select("QRYSB1") > 0
		QRYSB1->(DbCloseArea())
	EndIf
	
    cQuery := " SELECT " + CRLF
    cQuery += "     SB1.B1_COD, SB1.B1_XGRUPO " + CRLF
    cQuery += " FROM " + CRLF
    cQuery += "     " + RetSQLName("SB1") + " SB1 " + CRLF
    cQuery += " WHERE " + CRLF
    cQuery += "     " + RetSQLCond("SB1") + CRLF
    cQuery += "     AND SB1.B1_COD BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' " + CRLF
	If !Empty(MV_PAR04)
		cQuery += "     AND SB1.B1_XGRUPO = '" + MV_PAR04 + "' " + CRLF
	EndIf

    cQuery := ChangeQuery(cQuery)
    dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), "QRYSB1")

	SB2->(DbSetOrder(1))
	While !QRYSB1->(EoF())
		
		If  !QRYSB1->B1_XGRUPO $ cGrpReser
			QRYSB1->(DbSkip())
			Loop
		EndIf
		
		//Para todos os produtos identificados recalcula reserva
		If Select("QRYSC6") > 0
			QRYSC6->(DbCloseArea())
		EndIf
			
		BeginSql Alias "QRYSC6"
			SELECT
				C6_PRODUTO,
				C6_LOCAL,
				SUM(C6_QTDVEN) QTDVEN
			FROM %table:SC6% SC6
			WHERE
				C6_FILIAL = %xFilial:SC6% AND
				C6_PRODUTO = %Exp:QRYSB1->B1_COD% AND 
				C6_LOCAL = %Exp:MV_PAR03% AND
				C6_NOTA = ' ' AND
				C6_XRESERV <> ' ' AND
				C6_BLQ <> 'R' AND
				SC6.D_E_L_E_T_ = ' '
			GROUP BY
				C6_PRODUTO,
				C6_LOCAL
		EndSql
			
		If !QRYSC6->(EoF())
			While !QRYSC6->(EoF())
				If SB2->(DbSeek(xFilial("SB2")+QRYSC6->(C6_PRODUTO+C6_LOCAL))) .and. (QRYSC6->QTDVEN <> SB2->B2_RESERVA .or. QRYSC6->QTDVEN <> SB2->B2_QPEDVEN)
					RecLock("SB2",.F.)
						SB2->B2_RESERVA := QRYSC6->QTDVEN
						SB2->B2_QPEDVEN := QRYSC6->QTDVEN
					SB2->(MsUnlock())
				EndIf
				QRYSC6->(DbSkip())
			End
		Else
			If SB2->(DbSeek(xFilial("SB2")+QRYSB1->B1_COD+MV_PAR03)) .AND. (SB2->B2_RESERVA <> 0 .or. SB2->B2_QPEDVEN <> 0)
				RecLock("SB2",.F.)
					SB2->B2_RESERVA := 0
					SB2->B2_QPEDVEN := 0
				SB2->(MsUnlock())
			Endif
		EndIf
		QRYSB1->(DbSkip())
	End
	
	//Para todos os produtos identificados recalcula reserva
	If Select("QRYSB1") > 0
		QRYSB1->(DbCloseArea())
	EndIf	
	
Return
