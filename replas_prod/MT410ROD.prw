#include 'protheus.ch'
#include 'parmtype.ch'

user function MT410ROD()
	Local aArea		:=  GetArea()
	Local cCargo	:= paramixb[1]
	Local cCliente	:= paramixb[2]
	Local nTotLiq	:= paramixb[3]       //nTotPed+nTotDes
	Local nTotDes	:= paramixb[4]
	Local nTotPed	:= paramixb[5]
	Local nI		:= 0
	Local cUser		:= RetCodUsr()
	Local aGrpUsr	:= UsrRetGrp(cUser)
	Local cGrpBlq	:= GetNewPar("MV_XGRPALT","000001")
	Local cCpoAlt	:= GetNewPar("MV_XCPOALT","C5_XMENOTA,C5_MENNOTA,C5_CONDPAG")
	Local nPosGrp	:= 0
	
	nPosGrp := Ascan(aGrpUsr, {|x| Alltrim(x) == Alltrim(cGrpBlq) })
	
	If Altera .and. !IsinCallStack("U_XRLSMOTOR") .and. nPosGrp > 0
		cCpoAlt := StrTran(cCpoAlt,"C5_","M->C5_")
		//Desabilita todos os campos menos os permitidos alterar pelos Vendedores
		For nI:=1 to Len(oGetPV:aEntryCtrls)
			If !Alltrim(oGetPV:aEntryCtrls[nI]:cReadVar) $ cCpoAlt
				oGetPV:aEntryCtrls[nI]:lReadOnly := .T.
			EndIf 
		Next
		oGetDad:lActive := .f.
		oGetDad:oBrowse:Refresh()
	Endif
	
	
	Eval(cCargo,SubStr(cCliente,1,40),IIF(nTotDes!=0,nTotLiq,nTotPed),nTotDes,nTotPed)
	
	RestArea(aArea)
return