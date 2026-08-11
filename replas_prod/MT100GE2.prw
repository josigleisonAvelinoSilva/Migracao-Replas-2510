#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} MT100GE2
Processo de DI

@author TOTVS Serra do Mar [JOSE CARLOS]
@since 30/06/2016
@version P12
/*/
//-------------------------------------------------------------------
User Function MT100GE2()
Local aArray	:= U_GetAcols103()
Local __aHeader	:= aClone( aArray[1] )
Local __aCols	:= aClone( aArray[2] )   
Local aArea		:= GetArea()
Local aCampos	:= {"F1_XPROCES","F1_XQTDDOL","F1_XTXDOLA"}
Local aCpos2	:= {"E2_XPROCES","E2_XQTDDOL","E2_XTXDOLA"}  
Local nPos		:= 0
Local nX		:= 0

For nX:=1 To len(aCampos)
	If (nPos:= Ascan(__aHeader,{|x| Alltrim(x[2]) == Alltrim(aCampos[nX]) } ) ) > 0
		SE2->&(Alltrim(aCpos2[nX])):= __aCols[1][nPos]
	EndIf
Next

Return

