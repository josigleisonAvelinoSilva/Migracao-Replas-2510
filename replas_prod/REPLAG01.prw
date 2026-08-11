#Include 'Protheus.ch'
//-------------------------------------------------------------------
/*/{Protheus.doc} REPLAG01
Atualiza valor da comissão com base na tabela
Cadastro Amarração Comissão Vs Grupo de Produtos
Acionado por gatilho item do pedido de venda (codigo do produto).

@author TOTVS Serra do Mar [JOSE CARLOS]
@since 27/06/2016
@version P12
/*/
//-------------------------------------------------------------------
User Function REPLAG01()
Local aAreaAtu	:= GetArea()
Local nRetorno	:= 0
Local cProduto	:= &(__readvar)
Local cGrupProd	:= GetAdvFval("SB1","B1_GRUPO",xFilial('SB1')+cProduto,1)
Local cCodVend	:= M->C5_VEND1

DbSelectArea('SZ1')
SZ1->(DbSetOrder(1))
If SZ1->( DbSeek(xFilial('SZ1')+cCodVend+cGrupProd) )
	nRetorno	:= SZ1->Z1_PERC
EndIf

GdFieldPut("C6_COMIS2",0,N)
GdFieldPut("C6_COMIS3",0,N)
GdFieldPut("C6_COMIS4",0,N)
GdFieldPut("C6_COMIS5",0,N)

RestArea( aAreaAtu )
Return( nRetorno )

