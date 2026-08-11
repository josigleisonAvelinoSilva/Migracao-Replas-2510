#include 'protheus.ch'
#include 'parmtype.ch'

/*
Ponto de entrada executado ao selecionar pedido para ser faturado
*/
user function M460MKB()
	Local cCondRet := ""
	Local cFilOrig := GetMV("RE_FILORIG", .F., "0302")
	
	//Caso não esteja no motor valida pedido
	If cFilAnt $ "0103/" + cFilOrig .and. !IsinCallStack("U_XRLSMOTOR")
		cCondRet := "u_fvldped(SC9->C9_PEDIDO)"
	EndIf
	
return(cCondRet)

/*
Rotina personalizada para validar se o pedido tem divergencias entre SC6 e SC9
*/
User Function fvldped(cPedSC9)
	Local lRet 		:= .T.
	Local aArea		:= GetArea()
	Local cMsgErr	:= ""
	Local cTipoAlert:= GetNewPar( "MV_X460MKB", "H" )
	
	If !IsinCallStack("MA461ESTOR")
		//Abre alias SC6 e SC9 para comparação
		If Select("TRBPED") > 0
			TRBPED->(DbCloseArea())
		EndIf
		
		BeginSql Alias "TRBPED"
			SELECT 
				COUNT(*) AS ITENS,
				SUM(C6_QTDVEN) AS QLIB
			FROM   %table:SC6% SC6
			WHERE  C6_FILIAL = %xFilial:SC6%
			       AND C6_NUM = %Exp:cPedSC9%
			       AND SC6.%notDel%
		EndSql
		
		If Select("TRBLIB") > 0
			TRBLIB->(DbCloseArea())
		EndIf
		
		BeginSql Alias "TRBLIB"
			SELECT 
				COUNT(*) AS ITENS,
				SUM(C9_QTDLIB) AS QLIB
			FROM   %table:SC9% SC9
			WHERE  C9_FILIAL = %xFilial:SC9%
			       AND C9_PEDIDO = %Exp:cPedSC9%
			       AND C9_BLEST = ' '
			       AND C9_BLCRED = ' '
			       AND SC9.%notDel%
		EndSql
		
		//Testa informações para mostrar mensagem
		Do Case
			Case TRBPED->(EoF()) .or. TRBLIB->(EoF()) 
				cMsgErr := "Não existe itens liberados para pedido"
				lRet := .F.
			Case TRBPED->ITENS <> TRBLIB->ITENS
				cMsgErr := "Divergência entre número de produtos liberados ("+Alltrim(Str(TRBLIB->ITENS))+") e número de produtos do pedido ("+Alltrim(Str(TRBPED->ITENS))+")"
				lRet := .F.
			Case TRBPED->QLIB <> TRBLIB->QLIB
				cMsgErr := "Divergência entre quantidade liberada e quantidade informada no pedido"
				lRet := .F.
		EndCase
		
		TRBPED->(DbCloseArea())
		TRBLIB->(DbCloseArea())
		
		If !lRet
			If Upper(cTipoAlert) == "H"
				Help( ,,"M460MKB",,"Pedido "+cPedSC9+": "+cMsgErr, 1, 0 )
			Else
				lRet := MsgYesNo("Pedido "+cPedSC9+": "+Alltrim(cMsgErr)+". Deseja Liberar?")
			EndIf
		EndIf
	EndIf
	
	RestArea(aArea)
	
Return(lRet)
