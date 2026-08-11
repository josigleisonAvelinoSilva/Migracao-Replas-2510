#Include 'Protheus.ch'
//-------------------------------------------------------------------
/*/{Protheus.doc} SF1100I
Processo de DI

@author TOTVS Serra do Mar [JOSE CARLOS]
@since 30/06/2016
@version P12
/*/
//-------------------------------------------------------------------
User Function SF1100I()
Local aArray	:= U_GetAcols103()
Local __aHeader	:= aClone( aArray[1] )
Local __aCols	:= aClone( aArray[2] )   
Local aArea		:= GetArea()
Local aCampos	:= {"F1_XPROCES","F1_XQTDDOL","F1_XTXDOLA"} 
Local nPos		:= 0
Local nX		:= 0
Local nDespAdc  := IIf(FindFunction("u_xF1DespAdc"), u_xF1DespAdc(), 0)

For nX:=1 To len(aCampos)
	If (nPos:= Ascan(__aHeader,{|x| Alltrim(x[2]) == Alltrim(aCampos[nX]) } ) ) > 0
		RecLock('SF1',.F.)            
			SF1->&(Alltrim(aCampos[nX])):= __aCols[1][nPos]
		MsUnlock()
	EndIf
Next

RestArea( aArea )

/* ZERAR AS VARIAVEIS */
U_SetAcols103()      

//-- Preenchimento de despesas adicionais do campo "F1_XDESPE2"
If !Empty(nDespAdc)
	RecLock("SF1", .F.)
		SF1->F1_XDESPE2 := nDespAdc
	SF1->(MsUnLock())
EndIf

Return
