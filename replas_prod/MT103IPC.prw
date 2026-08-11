#include 'protheus.ch'
#include 'parmtype.ch'

user function MT103IPC()
	Local aProcess := u_GetAcols103()
	Local aHeadProc:= aProcess[1]	
	Local aColsProc:= aProcess[2]
	Local _nLinha := PARAMIXB[1]
	Local nPos	  := 0
	
	If Len(aColsProc) == 0
		aadd(aColsProc,Array(4))
		aColsProc[Len(aColsProc),4] := .F.
	EndIf
	
	nPos :=  Ascan(aColsProc,{|x| x[1] == SC7->C7_XPROCES })
	If nPos == 0 
		nPos := 1
	EndIf
	
	aColsProc[nPos,1] := SC7->C7_XPROCES
	aColsProc[nPos,2] := SC7->C7_XQTDDOL
	aColsProc[nPos,3] := SC7->C7_XTXDOLA
	
	u_SetAcols103(aHeadProc,aColsProc)
	
Return(.t.)
	
