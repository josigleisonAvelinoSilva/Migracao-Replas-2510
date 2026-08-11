#Include "Protheus.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³xSacAval()  ºAutor  ³Eduardo Augusto   º Data ³  20/03/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Programa para tratamento do Sacador Avalista que saira no  º±±
±±º          ³ Arquivo Cnab Santander de Cobranca. (Posicoes 352 A 381)   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Replas									                  º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function xSacAval(cOrig)
                                                                      `
Local _cRet		:= ""
Local _cBenef	:= ""
Local _cSacad	:= ""
Local _cCgcRep	:= ""
Local _cCgcVid	:= ""
Local _cBanco	:= SEE->EE_CODIGO
Local _cAgencia	:= SEE->EE_AGENCIA
Local _cConta	:= SEE->EE_CONTA
Local _cSubCta	:= SEE->EE_SUBCTA
Default cOrig	:= "1" // 1 = Benefeciario, 2 = Sacador / Avalista, 3 = CNPJ Replas ou CNPJ Videolar 

DbSelectArea("SEE")       
Dbsetorder(1)	// EE_FILIAL + EE_CODIGO + EE_AGENCIA + EE_CONTA + EE_SUBCTA
Dbseek(xFilial("SEE") + _cBanco + _cAgencia + _cConta + _cSubCta)

If _cSubCta == "RVL"	// Informacoes para Sacador Avalista
	_cBenef	:= Alltrim(Substr(SEE->EE_XNOMEVL,1,30))	// Posicao 352 a 381
	_cSacad := Space(30)								// Posicao 352 a 381	// Upper(Substr(SM0->M0_NOMECOM,1,30))		// Posicao 352 a 381
	_cCgcVid := PadL(Alltrim(SEE->EE_XCNPJVL),14,"0")	// Posicao 004 a 017
	If cOrig == "1"
		_cRet := _cBenef
	EndIf
	If cOrig == "2"
		_cRet := _cSacad
	EndIf
	If cOrig == "3"
		_cRet := _cCgcVid
	EndIf
Else
	_cBenef	:= Upper(Substr(SM0->M0_NOMECOM,1,30))		// Posicao 352 a 381
	_cSacad := Space(30)								// Posicao 352 a 381
	_cCgcRep := PadL(Alltrim(SM0->M0_CGC),14,"0")		// Posicao 004 a 017
	If cOrig == "1"
		_cRet := _cBenef
	EndIf
	If cOrig == "2"
		_cRet := _cSacad
	EndIf
		If cOrig == "3"
		_cRet := _cCgcRep
	EndIf
EndIf

Return _cRet