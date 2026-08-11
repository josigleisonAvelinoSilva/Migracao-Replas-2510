#Include 'Protheus.ch'


/*/{Protheus.doc} A410CONS
Ponto de entrada na rotina de Pedido de Venda para inclusão de novos botoes em "Ações relacionadas"
@type function
@version 1.0  
@author TOTVS Serra do Mar [JOSE CARLOS]
@since 27/06/2016
@return array, Array com botoes
/*/
User Function A410CONS()
	Local aButtons := {}
	Local cFilOrig := GetMV("RE_FILORIG", .F., "0302")

	If cFilAnt == cFilOrig .And. (INCLUI .Or. ALTERA)
		aAdd(aButtons , {'OMSDIVIDE', {|| U_REPLAA07()}, "*Produto Inteligente - Filme"})

		//-- Rotina que faz o auto preenchimento dos itens da grid com base em solicitacao de transferecia
		aAdd(aButtons, {"", {|| U_REFATA09()}, "*Auto Preenchimento", "*Auto Preenchimento dos Itens"})
	EndIf

Return aButtons
