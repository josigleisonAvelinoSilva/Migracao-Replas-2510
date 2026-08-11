#include "Protheus.ch"
#Include "rwmake.ch"
#Include "Topconn.ch"
#INCLUDE "AP5MAIL.CH"

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºPrograma  ³ MTA440C9 ºAutor  ³                            ³ 03/05/2016º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºDesc.   Envia email                                                    ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±CSE30E010200200±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
User Function MTA440C9()

Local _nI :=0
Local cMailDe   := ''
Local cAssunto  := ''
Local cMailPara := ''
Local _cCCo     := ''
Local cCorpo    := ''
Local _cAnexo   :=''
Local lIntIndMM  := GetMV( "RE_INTIND", .F., .T. ) //-- Parametro geral que indica se a integracao de pedidos com a industria mm (Filial 0201) esta ativa

If funname()<>'MATA440'
Return
endIf

If lIntIndMM .And. U_REFATA02( 1, SC9->C9_PRODUTO )
	Return
EndIf

_aArea := GetArea()
dbSelectArea("SC9")
_nPosPrazo:= Ascan(aHeader,{|x| Alltrim(x[2]) == "C9_DATENT" })
_nPosItem := Ascan(aHeader,{|x| Alltrim(x[2]) == "C9_ITEM" })
_nPosPreco:= Ascan(aHeader,{|x| Alltrim(x[2]) == "C9_PRCVEND" })
_nPosProd := Ascan(aHeader,{|x| Alltrim(x[2]) == "C9_PRODUTO" })

_aArea := GetArea()
dbSelectArea("SC5")
_nPosCond := Ascan(aHeader,{|x| Alltrim(x[2]) == "C5_CONDPAG" })
_nPosVend := Ascan(aHeader,{|x| Alltrim(x[2]) == "C5_VEND1" })  

//_nPC       :=
// Campos que serao usados para envio de e_mail
_cTitulo   := ""
_cDestino  := ""
_cCco      := ""
_cMsg      := ""
_cMsgCorpo := ""
_cAnexo    := ""
_cForn     := ALLTRIM(SC9->C9_CLIENTE) 
_Loja      := ALLTRIM(SC9->C9_LOJA) 
_cPgto     := ALLTRIM(SC5->C5_CONDPAG)
_cItem     := ALLTRIM(SC9->C9_ITEM)
_cProd     := ALLTRIM(SC9->C9_PRODUTO)
_vQtde     := STR(SC9->C9_QTDLIB,14,4)
_cUser     := Alltrim(UsrRetName(RetCodUsr()))
nCont      := 0
_nPC       := ALLTRIM(SC9->C9_PEDIDO) 
_aviso     :="Analisar o credito do Cliente"  
_bL01      :="(01)BLOQUEADO P/ CRÉDITO"//01
_bL02      :="(04)LIMITE DE CRÉDITO VENCIDO" //04
_bL03      :="(09)REJEITADO"//09 
_CodBl     :=ALLTRIM(SC9->C9_BLCRED)
_Vend      :=ALLTRIM(SC5->C5_VEND1)
_cDE       := "workflow@replas.com.br"  //criar MV
 //colocar a query
If  SC9->C9_BLCRED $ '01,04,09'	
	_cMsg  := "ANALISE DE CREDITO "+CHR(13)+CHR(10)
	_cMsg  += CHR(13)+CHR(10)
	_cMsg  := "PEDIDO DE VENDAS "+CHR(13)+CHR(10)
	_cMsg  += CHR(13)+CHR(10)
	_cMsg  += "PEDIDO: " + _nPC + " - USUÁRIO(A): "+ _cUser + CHR(13)+CHR(10)
	_cMsg  += CHR(13)+CHR(10)  
	_cMsg  += "CONDIÇÃO DE PGTO:" +_cPgto + CHR(06)
	_cMsg  += CHR(13)+CHR(10) 
	_cMsg  += "CODIGO VENDEDOR:" +_Vend + CHR(06) 
	_cMsg  += CHR(13)+CHR(10)
	_cMsg  += "CLIENTE:" +_cForn + CHR(06)
	_cMsg  += CHR(13)+CHR(10) 
	_cMsg  += "LOJA:" +_Loja + CHR(04)
	_cMsg  += CHR(13)+CHR(10) 
	_cMsg  += "DESCRIÇÃO DO BLOQUEIO:" +_bL01 + CHR(13)+_bL02 + CHR(13)+_bL03 + CHR(13)
	_cMsg  += CHR(13)+CHR(10) 
	_cMsg  += "CODIGO DO BLOQUEIO:" +_CodBl + CHR(02)
	
	//_cMsg  += CHR(13)+CHR(10)
	//_cMsg  += "ITEM:" +_cItem + CHR(03)
	//_cMsg  += CHR(13)+CHR(10)
	//_cMsg  += "PRODUTO:" + _cProd +"-"+_cDesc + CHR(20)+CHR(30)+"."
	//_cMsg  += CHR(13)+CHR(10)
	//_cMsg  += "QTDE:" + _vQtde
	_cMsg  += CHR(13)+CHR(10)
	_cMsg  += "OBSERVAÇÃO:" + _aviso
	
   	cMailDe   :="workflow@replas.com.br" 
	
//   	cMailPara :="marli.moraes@totvs.com.br" 
	cMailPara :=GetMV("MV_MAILPV")
	cAssunto  :="PEDIDO DE VENDAS"
	cCorpo    :=_cMsg
Endif

IF !Empty(cMailDe)
	Processa({ || u_EnviaEmail(cMailDe,cAssunto,cMailPara,_cCCo,cCorpo,_cAnexo)},"Aguarde... Enviando email")   
endif

Return(_cMsg)
RestArea(_aArea)
Return .T.
