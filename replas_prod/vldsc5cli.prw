#include 'protheus.ch'
#include 'parmtype.ch'

user function vldc5cli(_cCliente,_cLoja)
	local cUserSis		:= RetCodUsr()
	Local lret			:= .T.
	
	Default _cCliente	:= ""
	Default _cLoja		:= ""

	If M->C5_TIPO == "N" .and. !Empty(_cCliente+_cLoja)
		SA1->(DbSetOrder(1))
		If SA1->(DbSeek(xFilial("SA1")+_cCliente+_cLoja))
			AO4->(DbSetOrder(1))
			If AO4->(DbSeek(xFilial("AO4")+"SA1"+Padr(SA1->(A1_FILIAL+A1_COD+A1_LOJA),TAMSX3("AO4_CHVREG")[01])+cUserSis))
				lret := .T.
			else
				lret := .F.
			EndIf
		EndIf
	EndIf
	
	If !lret
		M->C5_CLIENTE := Space(TAMSX3("C5_CLIENTE")[01])
	Endif
	
return(lret)