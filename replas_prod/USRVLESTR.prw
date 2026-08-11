#include 'protheus.ch'
#include 'parmtype.ch'

//PARA QUE NA TELA DE AJUSTE DE EMPENHO DA O.P. OS ITENS NÃO VENHAM DELETADOS (EXCLUSIVIDADE A PARTIR DA 12.1.017)

user function USRVLESTR()
	Local _cCodigo		:= paramixb[1]
	Local _cComponente	:= paramixb[2]
	Local _cTRT			:= paramixb[3]
	Local _aRetPE		:= {}
	
	//(TSM-David) Força desativação da validação de opcionais
	_aRetPE := {.T.,; //Valida Componente fora das datas inicio / fim
				.F.,; //Valida Componente fora dos grupos de opcionais
				.T.} // Valida Componente fora das revisoes
	
return(_aRetPE)