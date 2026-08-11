#Include "Protheus.ch"

/*/{Protheus.doc} M410LIOK
(long_description) Ponto de entrada para validação da linha (item) da rotina de
pedido de venda. Executado no momento em que sai da linha e antes da confirmação do pedido.
@type Validação para liberar o Pedido sem que o Parametro Sugere Liber Pedido esteja habilitado.
@author Eduardo Augusto
@since 18/09/2017
@version 1.0
@return ${return}, ${return_description}
@example 
MATA410 (Pedidos de Venda)
@see (links_or_references)
/*/

User Function M410LIOK()

Local lOk		:= .T.
Local i		:= 0
Local aArea	:= GetArea()
Local nQtde		:= aScan(aHeader,{|x| AllTrim(x[02]) == "C6_QTDVEN"})
Local nQtdeLib	:= aScan(aHeader,{|x| AllTrim(x[02]) == "C6_QTDLIB"})
//Local nProd		:= aScan(aHeader,{|x| AllTrim(x[02]) == "C6_PRODUTO"})
//Local nPrVend		:= aScan(aHeader,{|x| AllTrim(x[02]) == "C6_PRCVEN"})
//Local cBloquei	:= aScan(aHeader,{|x| AllTrim(x[02]) == "C6_BLOQUEI"})
//Local lBlqReg		:= .T.

If IsInCallStack("U_REESTA02")
	For i := 1 to Len(aCols)
		If QtdComp(aCols[i,nQtde]) != QtdComp(aCols[i][nQtdeLib])
			aCols[i,nQtdeLib] := aCols[i,nQtde]
		EndIf
	Next
	Return lOk
EndIf

If !IsinCallStack("U_XRLSMOTOR")
	For i := 1 to Len(aCols)
		If aCols[i][nQtdeLib] = 0
			aCols[i,nQtdeLib] := aCols[i,nQtde]
		EndIf
	Next
EndIf

RestArea(aArea)

Return (lOk)
