#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} MT120CPE
Processo de DI

@author TOTVS Serra do Mar [JOSE CARLOS]
@since 30/06/2016
@version P12
/*/
//-------------------------------------------------------------------
User Function MT120CPE()

Public cProcDI		:= Iif(INCLUI,CriaVar('C7_XPROCES'),SC7->C7_XPROCES)
Public nTxDolar		:= Iif(INCLUI,CriaVar('C7_XTXDOLA'),SC7->C7_XTXDOLA) 
Public nQtdeDolar	:= Iif(INCLUI,CriaVar('C7_XQTDDOL'),SC7->C7_XQTDDOL)
	
Return

