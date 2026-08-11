#include 'protheus.ch'
#include 'parmtype.ch'

user function M410ICM()
	Local nItem 	:= paramixb[1]
	Local aArea 	:= GetArea()
	Local cAliqEst 	:= GetNewPar("MV_ESTICM","") 
	Local cEstNort 	:= GetNewPar("MV_NORTE","") 
	Local nAliqImp 	:= GetNewPar("MV_XALIQIM",4)
	Local nAliqNor 	:= GetNewPar("MV_XALIQNR",7)
	Local nAliqDem 	:= GetNewPar("MV_XALIQDM",12)
	Local cEstICM	:= ""
	Local cAliqICM	:= ""
	Local nPProduto := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
	Local cProduto	:= acols[nItem,nPProduto]
	Local cOriProd	:= ""
	Local nPos		:= 0
	Local lForaEst	:= .F.
	
	//(10/10/2017) Tratamento especifico para aliquota de ICM
	//de acordo cliente de venda e não cliente de entrega
	If M->(C5_CLIENTE+C5_LOJACLI) <> M->(C5_CLIENT+C5_LOJAENT)
		cEstICM  := GetAdvFVal("SA1","A1_EST",xFilial("SA1")+M->(C5_CLIENTE+C5_LOJACLI),1)
		cOriProd := GetAdvFVal("SB1","B1_ORIGEM",xFilial("SB1")+cProduto,1)
		lForaEst := cEstICM <> SM0->M0_ESTCOB
		
		//Produto Importado aliquota padrão
		If	lForaEst .and.;
		 	Alltrim(cOriProd) $ '1,2,3,8'
		 	
			_ALIQICM := nAliqImp
			_VALICM := _BASEICM*(_ALIQICM/100)
		Else
			If cEstICM $ cEstNort
				_ALIQICM := nAliqNor
				_VALICM := _BASEICM*(_ALIQICM/100) 
			Else
				If cEstICM == "SP"
					nPos :=  AT( cEstICM, cAliqEst )
					If nPos > 0
						_ALIQICM := Val(Substr(cAliqEst,nPos+2,2))
						_VALICM := _BASEICM*(_ALIQICM/100) 
					EndIf
				Else
					_ALIQICM := nAliqDem
					_VALICM := _BASEICM*(_ALIQICM/100)
				EndIf
			EndIf 
		EndIf
	EndIf
	
	RestArea(aArea)
return