#Include "Protheus.ch"
#Include "TbiConn.ch"
#Include "Totvs.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} JobEstPd
(long_description) Job para tratamento do Estorno de Liberação do PV por Item.
@type function
@author Eduardo Augusto
@since 18/09/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
/*
User Function JobEstPd()

Local aEmpresas	:= {}
Private cMensa	:= ""
Private cEmail	:= ""
If !IsinCallStack("XRLSMOTOR")
	RPCClearEnv()
	RPCSetType(3)   // Nao consome licenças.
	Conout("Preparando Ambiente")
	RPCSetEnv("01","0101")
	DbSelectArea("SM0")
	DbGotop()
	While !Eof()
		aAdd( aEmpresas, SM0->M0_CODFIL )
		DbSkip()
	Enddo
	Conout("Estornando Item ou Itens do(s) Pedido(s).")
	u_EstItPed(.T.)
EndIf
	
Return
*/