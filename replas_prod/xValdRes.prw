#include 'protheus.ch'
#include 'parmtype.ch'

user function xValdRes(cPedido)
	
	//Seleciona itens do pedido, mesmo excluidos para ajustar reserva
	If Select("QRYTRB") > 0
		QRYTRB->(DbCloseArea())
	EndIf
			
	BeginSql Alias "QRYTRB"
		SELECT
			C6_PRODUTO,
			C6_LOCAL
		FROM
			%table:SC6% SC6
		WHERE
			C6_FILIAL = %xFilial:SC6% AND
			C6_NUM = %Exp:cPedido%
	EndSql
	
	While !QRYTRB->(EoF()) 
		u_xAtuRes(QRYTRB->C6_PRODUTO,QRYTRB->C6_PRODUTO,QRYTRB->C6_LOCAL)
		
		QRYTRB->(DbSkip())
	End
return