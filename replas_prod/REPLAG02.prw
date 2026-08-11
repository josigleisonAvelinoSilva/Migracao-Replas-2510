#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} REPLAG02
Atualiza dados bancarios do cadastro do cliente para o pedido de venda
Acionado por gatilho cabec. do pedido de venda (codigo do cliente).

@author TOTVS Serra do Mar [JOSE CARLOS]
@since 27/06/2016
@version P12
/*/
//-------------------------------------------------------------------
User Function REPLAG02()
Local aAreaAtu	:= GetArea()

If M->C5_TIPO == 'N' 
	SA1->(DbSelectArea('SA1'))
	SA1->(DbSetOrder(1))
	If SA1->( DbSeek(xFilial('SA1') + M->C5_CLIENTE + M->C5_LOJACLI ) )
		M->C5_XAGENCI	:= SA1->A1_XAGENCI
		M->C5_XDVAGE	:= SA1->A1_XDVAGE
		M->C5_XNUMCON	:= SA1->A1_XNUMCON
		M->C5_XDVCTA	:= SA1->A1_XDVCTA	
	EndIf
EndIF

RestArea( aAreaAtu )

Return(M->C5_CLIENTE)

