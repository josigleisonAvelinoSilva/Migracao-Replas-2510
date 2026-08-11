#Include 'Protheus.ch'

Static __aHed103	:= {}
Static __aCol103	:= {} 
Static nDespAdc     := 0

/*
{Protheus.doc}	MA103BUT
Ponto de entrada documento de entrada
Inclusao de novos botoes na enchoice
@author			Jose Carlos da Rocha
@since			19/07/2016
@project 		Dados da DI    
*/
User Function MA103BUT()
Local aBotao := {}  

aAdd(aBotao, {'FASIMG32',{||u_DADOSDI_F1()},"Dados DI","Processo"}  )  
aAdd(aBotao, {"", {|| AddDespAdc()}, "Despesas Adicionais", "Desp. Adicionais"})  

Return( aBotao )                 

/*
{Protheus.doc}	DADOSDI_F1
Inicio do processo
Apresentacao de tela de digitacao dos campo especificos 
@author			Jose Carlos da Rocha
@since			19/07/2016
@project 		Dados DI   
*/
User Function DADOSDI_F1()
Local oDlgProc
Local oGetados 
Local nOpcA
Local nOpcX	:= 3                                                
Local aHAnterior:= aClone( aHeader )
Local aCAnterior:= aClone( aCols )

aHeader	:= __aHed103
aCols	:= __aCol103                 

If Empty( __aHed103 )
	MontaGetDados()
EndIf

DEFINE MSDIALOG oDlgProc TITLE "Dados Processo" Of oMainWnd PIXEL  FROM 94 ,104 TO 330,590 

oGetados:=MsGetDados():New(030,005,110,240,nOpcX,"Allwaystrue","Allwaystrue",/*[cIniCpos]*/,/*[lDeleta]*/.F.,/*[aAlter]*/,;
									/*[nFreeze]*/,/*[lEmpty]*/,/*[nMax]*/1,/*[cFieldOk]*/,/*[cSuperDel]*/,/*[uPar]*/,/*[cDelOk]*/,;
									/*[oWnd]*/oDlgProc,/*[lUseFreeze]*/,/*[cTela]*/ ) 
                         
ACTIVATE MSDIALOG oDlgProc CENTERED ON INIT EnchoiceBar(oDlgProc,{||nOpcA:=1,oDlgProc:End()},{||oDlgProc:End()}) 

aHeader:= aClone( aHAnterior )
aCols	 := aClone( aCAnterior )

Return()

/*
{Protheus.doc}	MontaGetDados
					Monta tela para digitacao
@author			Jose Carlos da Rocha
@since			19/07/2016
@project 		Dados da DI   
*/
Static Function MontaGetDados()
Local nUsado	:= 0
Local cCampos	:= "F1_XPROCES#F1_XQTDDOL#F1_XTXDOLA"
Local nX		:= 0 
Local nI := 0
Local aCpo := {}
Local nCpo := 0

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
//?Montagem do aheader                                                   ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
//---> REMOVIDO compatibilizacao para versao 12.1.25.
/*dbSelectArea("SX3")
dbSetOrder(1)
MsSeek("SF1")
While !Eof() .And. SX3->X3_ARQUIVO=="SF1"
	If Alltrim(SX3->X3_CAMPO) $ cCampos
		nUsado++
		Aadd(aHeader,{ AllTrim(X3Titulo()),;
			SX3->X3_CAMPO,;
			SX3->X3_PICTURE ,;
			SX3->X3_TAMANHO ,;
			SX3->X3_DECIMAL ,;
			SX3->X3_VALID	,;
			SX3->X3_USADO	,;
			SX3->X3_TIPO	,;
			SX3->X3_ARQUIVO ,;
			SX3->X3_CONTEXT } )
	EndIf
	dbSelectArea("SX3")
	dbSkip()
EndDo*/

aCpo := FwSx3Util():GetAllFields('SF1')

For nI := 1 To Len( aCpo )
	If RTrim( aCpo[ nI ] ) $ cCampos
		nUsado++
		AAdd( aHeader,{ FwX3Titulo( aCpo[ nI ] ),;
		GetSx3Cache( aCpo[ nI ] ,'X3_CAMPO ') ,;
		GetSx3Cache( aCpo[ nI ] ,'X3_PICTURE') ,;
		GetSx3Cache( aCpo[ nI ] ,'X3_TAMANHO') ,;
		GetSx3Cache( aCpo[ nI ] ,'X3_DECIMAL') ,;
		GetSx3Cache( aCpo[ nI ] ,'X3_VALID') ,;
		GetSx3Cache( aCpo[ nI ] ,'X3_USADO') ,;
		GetSx3Cache( aCpo[ nI ] ,'X3_TIPO') ,;
		GetSx3Cache( aCpo[ nI ] ,'X3_ARQUIVO') ,;
		GetSx3Cache( aCpo[ nI ] ,'X3_CONTEXT') })
	Endif
Next nI

If Len(aCols) == 0
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?	
	//?Montagem do acols                                                     ?	
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?	
	aadd(aCOLS,Array(nUsado+1))
	For nX := 1 To nUsado
		If INCLUI
			aCols[1][nX] := CriaVar(aHeader[nX][2])	
		Else
			aCols[1][nX] := SF1->&(Alltrim(aHeader[nX][2]))
		EndIf		
	Next nX
	aCOLS[1][nUsado+1] := .F.
EndIf

Return()

/*
{Protheus.doc}	GetAcols103
Retorna as variaveis Static __aHed103 e __aCol103
@author			Jose Carlos da Rocha
@since			19/07/2016
@project 		Dados da DI   
*/
User Function GetAcols103()
Return({__aHed103,__aCol103}) 

/*
{Protheus.doc}	SetAcols103
					Atualiza as variaveis Static __aHead103 e __aCol103
@author			Jose Carlos da Rocha
@since			19/07/2016
@project 		Dados da DI   
*/
User Function SetAcols103(aH,aC)
Default aH := {}
Default aC := {}
__aHed103 := aH
__aCol103 := Ac
Return()


/*/{Protheus.doc} AddDespAdc
Rotina para preenchimento de despesas adicionais do campo "F1_XDESPE2"
no momento da inclusao de um documento de entrada
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 17/01/2024
@Obs Preenchimento de valor de despesa adicional em um campo especifico
do cabecalho da nota fiscal de entrada, solicitado pelo Silvio 12/01/2024
/*/
Static Function AddDespAdc()
	Local aParBox := {}
	Local aRet    := {}
	Local nVlrDsp := SF1->F1_XDESPE2
	Local cPicDsp := X3Picture("F1_XDESPE2")

	aAdd(aParBox, {1, "Valor Desp. Adicional", nVlrDsp, cPicDsp, "Positivo()", "", "", 70, .T.})

	If ParamBox(aParBox, "Despesas Adicionais", @aRet, {|| .T.},,,,,,, .F., .F.)
		nDespAdc := aRet[1]
	EndIf

Return


/*/{Protheus.doc} xF1DespAdc
Rotina que retorna o valor da despesa adicional
@type function
@version 1.0  
@author DO THINK - DENER LEMOS
@since 17/01/2024
@return numeric, Despesa adicional
/*/
User Function xF1DespAdc()
Return nDespAdc
