#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "MSOLE.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE ENTER Chr(13) + Chr(10)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณPROCESS6  บAutor  ณ Eduardo Augusto    บ Data ณ  25/03/2015 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo para mostrar o processamento da tela de gera็ใo de  บฑฑ
ฑฑบ          ณ boletos.                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑPAGADOR
ฑฑบUso       ณ Rentank                                                    บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

User Function Process9(aVetor,_cBanco,_cAgencia,_cConta,_cSubcta,_Tipo,_EmisIni,_EmisFim,_cTitulo)

Private oObj
Default  _cBanco	:= ""
Default  _cAgencia	:= ""
Default  _cConta	:= ""
Default  _cSubcta	:= ""
Default  _Tipo		:= ""
Default  _EmisIni	:= CtoD("  /  /  ")
Default  _EmisFim	:= CtoD("  /  /  ")
Default  _cTitulo	:= ""
oObj := MsNewProcess():New({|lEnd| BolBtg(aVetor,_cBanco,_cAgencia,_cConta,_cSubcta,_Tipo,_EmisIni,_EmisFim,_cTitulo) },"Processando","Gerando Boletos...",.T.)	//Processamento da gera็ใo de boletos
oObj:Activate()	

Return
 
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบ Programa      ณ BOLETOS                          บ Data ณ 19/08/2014  บฑฑ
ฑฑฬอออออออออออออออุออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricao     ณ Programa para Geracao de Boleto Grafico BTG         บฑฑ
ฑฑบ				  ณ	utilizando o Objeto FWMSPTRINTER.				 บฑฑ
ฑฑฬอออออออออออออออุออออออออออออออออออออออหอออออออออัออออออออออออออออออออออนฑฑ
ฑฑบ Desenvolvedor ณ Flแvio     บ Empresa ณ TSM 							  บฑฑ
ฑฑฬอออออออออออออออุออออออออออออหออออออออัสออออออหออฯออออออออออออออออออออออนฑฑ
ฑฑบ Linguagem     ณ Advpl      บ Versao ณ 12    บ Sistema ณ Microsiga     บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function BolBtg(aVetor,_cBanco,_cAgencia,_cConta,_cSubcta,_Tipo,_EmisIni,_EmisFim,_cTitulo)

Local nCont     := 0
Local nQtd		:= 0
Local i
Local lRet		:=	.T.
Private oPrint	:= Nil
Private oFont18N,oFont18,oFont16N,oFont16,oFont14N,oFont12N,oFont10N,oFont14,oFont12,oFont10,oFont08N
Private _limpr	:= .T.
Private oFontTit	:= oFont08N
Private lAdjustToLegacy := .F.
Private lDisableSetup   := .T.
Private _aBoletos 	:= {}
Default  _cBanco	:= ""
Default  _cAgencia	:= ""
Default  _cConta	:= ""
Default  _cSubcta	:= ""
Default  _Tipo		:= ""
Default  _EmisIni	:= CtoD("  /  /  ")
Default  _EmisFim	:= CtoD("  /  /  ")
Default  _cTitulo	:= ""

SM0->( dbSetOrder( 1 ) )
SM0->( MsSeek( cEmpAnt + cFilAnt ))

oFont18N := TFont():New("Arial",18,18,,.T.,,,,.T.,.F.)
oFont18  := TFont():New("Arial",18,18,,.F.,,,,.T.,.F.)
oFont16N := TFont():New("Arial",16,16,,.T.,,,,.T.,.F.)
oFont16  := TFont():New("Arial",16,16,,.F.,,,,.T.,.F.)
oFont14N := TFont():New("Arial",14,14,,.T.,,,,.T.,.F.)
oFont14  := TFont():New("Arial",14,14,,.F.,,,,.T.,.F.)
oFont12	 := TFont():New("Arial",12,12,,.F.,,,,.T.,.F.)
oFont12N := TFont():New("Arial",12,12,,.T.,,,,.T.,.F.)
oFont10	 := TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
oFont10N := TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
oFont08	 := TFont():New("Arial",07,07,,.T.,,,,.T.,.F.)
oFont08N := TFont():New("Arial",08,08,,.T.,,,,.T.,.F.)
oFont06N := TFont():New("Arial",06,06,,.T.,,,,.T.,.F.)
oFont06	 := TFont():New("Arial",06,06,,.T.,,,,.T.,.F.)
oFont05	 := TFont():New("Arial",06,06,,.T.,,,,.T.,.F.)

If !ExistDir("C:\Boleto208\")
	MontaDir("C:\Boleto208\")
EndIf    
nReq := 0
nReq := Len(aVetor)
If oObj != Nil
	oObj:SetRegua1(nReq)
	oObj:SetRegua2(nReq)
	TBP->(DbGoTop())
EndIf   
For i := 1 to Len(aVetor)
	oObj:IncRegua1("Processando, Analisando os Boletos... " )
	If aVetor[i,1] == .T.
		nCont++
		//IncProc("Processando...: " + aVetor[i,3])
		DbSelectArea("SE1")
		SE1->(DbSetOrder(1))
		SE1->(DbSeek(aVetor[i,19] + aVetor[i,2] + aVetor[i,3] + aVetor[i,4] + aVetor[i,12]))
		DbSelectArea("SEE")
		SEE->(DbSetOrder(1))	// EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA
		SEE->(DbSeek(xFilial("SEE") + _cBanco + _cAgencia + _cConta + _cSubcta ))
		_cDvAge		:= SEE->EE_DVAGE
		_cDvCta		:= SEE->EE_DVCTA
		_cCart		:= SEE->EE_CODCART
		_nxJuros	:= SEE->EE_XJUROS
		_nxMulta	:= SEE->EE_XMULTA
		_cProtesto	:= SEE->EE_DIASPRT
		_cCodEmp	:= SEE->EE_CODEMP
		aAdd(_aBoletos,{SE1->(Recno()), SE1->E1_NUM, SE1->E1_TIPO, SC5->(Recno()), SC5->C5_NUM, ""})
		lRet	:=	U_CalcBtg(_aBoletos,_cBanco,_cAgencia,_cConta,_cSubcta,_Tipo,_EmisIni,_EmisFim,_cTitulo)
		// Caso de nosso numero nใo preenchido aborta impressใo 
		If !lRet
			Return
		EndIf	
		_cArquivo := AllTrim(SE1->E1_FILIAL) + "_" + AllTrim(SE1->E1_NUM) + "_" + Alltrim(SE1->E1_PARCELA) + "_208" + ".pdf"
		cFileName := "C:\Boleto208\" + _cArquivo

		//----------
		// Impressao
		//----------
		oPrint := FWMSPrinter():New(_cArquivo, IMP_PDF, lAdjustToLegacy,, lDisableSetup,,,,,,,.F.,)// Ordem obrigแtoria de configura็ใo do relat๓rio
		oPrint:SetResolution(72)			// Default
		oPrint:SetPortrait() 				// SetLandscape() ou SetPortrait()
		oPrint:SetPaperSize(9)				// A4 210mm x 297mm  620 x 876
		oPrint:SetMargin(10,10,10,10)		// < nLeft>, < nTop>, < nRight>, < nBottom>
		oPrint:cPathPDF := "C:\Boleto208\"
		//oPrint:SetViewPdf(_limpr)
		oPrint:StartPage()   	// Inicia uma nova pแgina

		dbSelectArea("SA1")
		SA1->(DbSetOrder(1))
		SA1->(DbSeek(xFilial("SA1") + SE1->(E1_CLIENTE + E1_LOJA ),.F.))
		//	Montagem do Box + Dados
		// < nRow>, < nCol>, < nBottom>, < nRight>, [ cPixel]
		// 1ฐ Parte
		_cBcoLogo:=""
		_cDigBanco:=""
		aBcos := { {"208","1", "Logo208.jpg" } }
		nF := ASCan(aBcos ,{|x|, x[1] == _cBanco })
		If nF == 0
			MsgBox(Iif(Empty(_cBanco),"O numero do banco nao foi informado","Nao ha layout previsto para o banco " + _cBanco))
		Else
			_lContinua := .T.
			_cDigBanco := aBcos[nF,2]
			_cBcoLogo  := aBcos[nF,3]
		EndIf
		
		//--------------------------------
		// Se็ใo - comprovante de entrega.
		//--------------------------------
		If _cBanco = "208"
			oPrint:SayBitmap(0020,0025,_cBcoLogo,0085,0020)
		EndIf
		If _cBanco = "208"
			oPrint:Say(0036,0110, "|" + _cBanco + "-" + _cDigBanco + "|" ,oFont18N,100)	// C๓digo do Banco + Dํgito
		EndIf
		cCgcSM0 := SM0->M0_CGC
		oPrint:Say (0036, 0448,"Comprovante de Entrega",oFont12N )	// Comprovante de Entrega
		BuzzBox  (0041,0025,0065,0320)	// Box Beneficiแrio + Cnpj
		oPrint:Say (0046, 0026,"Beneficiแrio",oFont06N )
		If _cSubcta == "RVL"
			oPrint:Say (0056, 0026,Alltrim(Substr(SEE->EE_XNOMEVL,1,30)),oFont05 )	// "VIDEOLAR INNOVA S/A"
		Else
			oPrint:Say (0056, 0026,"Replas Ind. e Comercio de Resinas",oFont05 )	// Alltrim(Substr(SM0->M0_NOMECOM,1,30))
		EndIf
		If _cBanco == "208"
			oPrint:Say (0046, 0130,"Endere็o",oFont06N )
			oPrint:Say (0053, 0130,Alltrim(Substr(SM0->M0_ENDCOB,1,32)) + " - " + Upper(Alltrim(SM0->M0_BAIRCOB)),oFont05 )
			oPrint:Say (0060, 0130,"CEP: " + Alltrim(Substr(SM0->M0_CEPCOB,1,5)) + "-" + Alltrim(Substr(SM0->M0_CEPCOB,6,3)) + " - " + Alltrim(SM0->M0_CIDCOB) + " / " + Alltrim(SM0->M0_ESTCOB),oFont05 )
		EndIf
		oPrint:Say (0058,0265,"CNPJ" ,oFont06N,100)	// 
		If _cSubcta == "RVL" 
			oPrint:Say (0064,0265,Transform(SEE->EE_XCNPJVL,"@R 99.999.999/9999-99"),oFont05) //Cnpj do Beneficiแrio -- "04.229.761/0001-70"
		Else
			//oPrint:Say (0056,0265,"14.555.032/0001-68",oFont05) //Cnpj do Beneficiแrio Transform(cCgcSM0,"@R 99.999.999/9999-99")
			oPrint:Say (0064,0265,Transform(cCgcSM0,"@R 99.999.999/9999-99"),oFont05) //Cnpj do Beneficiแrio 
		EndIf
		BuzzBox  (0040,0320,0065,0410)	// Box Agencia / Codigo do Cedente
		oPrint:Say (0046, 0321,"Ag๊ncia/C๓digo do Beneficiแrio",oFont06N )
		If _cBanco == "208"
			oPrint:Say(0056,2081,Substr(Alltrim(_cAgencia),1,4) + " / " + Iif(_cSubCta == "RVL",Substr(Alltrim(_cCodEmp),9,7),Substr(Alltrim(_cCodEmp),6,7)),oFont08,100)
		EndIf
		BuzzBox  (0040,0410,0065,0480)	// Nฐ do Documento
		oPrint:Say (0046, 0411,"Nฐ do Documento",oFont06N )
		oPrint:Say (0056, 0411,SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA,oFont08 )
		BuzzBox  (0040,0480,0140,0560)	// Box de Selecao
		oPrint:Say (0050, 0481,"(  )Mudou-se"               ,oFont06N,100)
		oPrint:Say (0060, 0481,"(  )Ausente"                ,oFont06N,100)
		oPrint:Say (0070, 0481,"(  )Nใo existe nบ indicado"	,oFont06N,100)
		oPrint:Say (0080, 0481,"(  )Recusado"               ,oFont06N,100)
		oPrint:Say (0090, 0481,"(  )Nใo procurado"          ,oFont06N,100)
		oPrint:Say (0100, 0481,"(  )Endere็o insuficiente"  ,oFont06N,100)
		oPrint:Say (0110, 0481,"(  )Desconhecido"           ,oFont06N,100)
		oPrint:Say (0120, 0481,"(  )Falecido"               ,oFont06N,100)
		oPrint:Say (0130, 0481,"(  )Outros(anotar no verso)",oFont06N,100)
		BuzzBox  (0065,0025,0090,0250)	// Box do Pagador
		oPrint:Say (0071, 0026,"Pagador",oFont06N )
		oPrint:Say (0081, 0026,Upper(SA1->A1_NOME),oFont08 )
		BuzzBox  (0065,0250,0090,0350)	// Box do Vencimento
		oPrint:Say (0071, 0251,"Vencimento",oFont06N )
		oPrint:Say (0081, 0301,Substr( DtoS(SE1->E1_VENCTO),7,2 ) + "/" + Substr( DtoS(SE1->E1_VENCTO),5,2 ) + "/" + Substr( DtoS(SE1->E1_VENCTO),1,4 ),oFont08 )
		BuzzBox  (0065,0350,0090,0480)	// Box do Valor do Documento
		oPrint:Say (0071, 0351,"Valor do Documento",oFont06N )
		aValImps:= RetImp()//nValor,nValIR,nValCF,nValPI,nValCS,nValINS,nValISS
		oPrint:Say (0081, 0401,AllTrim(Transform(IIf(SE1->E1_PREFIXO<>"RPS",SE1->E1_SALDO+SE1->E1_ACRESC,(SE1->E1_SALDO+SE1->E1_ACRESC)- (aValImps[5] + aValImps[3]+aValImps[4]+aValImps[7]+aValImps[2] + aValImps[6])),"@E 999,999,999.99")),oFont08 )		
		BuzzBox  (0090,0025,0140,0250)	// Box Recebi(emos) o Bloqueto / Titulo com as caracteristicas acima
		oPrint:Say (0107, 0026,"Box Recebi(emos) o Bloqueto / Titulo",oFont08N )
		oPrint:Say (0117, 0026,"com as caracteristicas acima",oFont08N )
		BuzzBox  (0090,0250,0115,2080)	// Box de Data
		oPrint:Say (0096, 0251,"Data",oFont06N )
		BuzzBox  (0090,2080,0115,0480)	// Box de Assinatura
		oPrint:Say (0096, 2081,"Assinatura",oFont06N )
		BuzzBox  (0115,0250,0140,2080)	// Box de Data
		oPrint:Say (0121, 0251,"Data",oFont06N )
		BuzzBox  (0115,2080,0140,0480)	// Box de Entregador
		oPrint:Say (0121, 2081,"Entregador",oFont06N )

		//------------------
		// Recibo do pagador
		// 2ฐ Parte
		//------------------
		If _cBanco = "208"
			oPrint:SayBitmap(0160,0025,_cBcoLogo,0085,0020)
		EndIf
		If _cBanco = "208"
			oPrint:Say(0176,0110, "|" + _cBanco + "-" + _cDigBanco + "|" ,oFont18N,100)	// C๓digo do Banco + Dํgito
		EndIf
		oPrint:Say (0176, 0470,"Recibo do Pagador",oFont12N )	// Recibo do Pagador
		BuzzBox  (0180,0025,0205,0425)	// Local de Pagamento
		oPrint:Say (0186, 0026,"Local de Pagamento",oFont06N )
		If _cBanco = "208"
			oPrint:Say  (0190, 0096,"PAGAVEL EM QUALQUER BANCO ATE O VENCIMENTO",oFont06N )
		EndIf
		BuzzBox  (0180,0425,0205,0560)	// Vencimento
		oPrint:Say (0186, 0426,"Vencimento",oFont06N )
		oPrint:Say (0196, 0476,Substr( DtoS(SE1->E1_VENCTO),7,2 ) + "/" + Substr( DtoS(SE1->E1_VENCTO),5,2 ) + "/" + Substr( DtoS(SE1->E1_VENCTO),1,4 ),oFont08 )
		BuzzBox  (0205,0025,0230,0425)	// Beneficiario
		oPrint:Say (0211, 0026,"Beneficiแrio",oFont06N )
		If _cSubcta == "RVL"
			oPrint:Say (0221, 0026,Alltrim(Substr(SEE->EE_XNOMEVL,1,30)),oFont08 )	// "VIDEOLAR INNOVA S/A"
		Else
			//oPrint:Say (0221, 0026,"Replas Ind. e Comercio de Resinas Plasticas e BOPP Ltda",oFont08 )	// ALLTRIM(SM0->M0_NOMECOM)
			oPrint:Say (0221, 0026,ALLTRIM(SM0->M0_NOMECOM),oFont08 )	
		EndIf
		If _cBanco == "208"
			oPrint:Say (0211, 0210,"Endere็o",oFont06N )
			oPrint:Say (0218, 0210,Alltrim(Substr(SM0->M0_ENDCOB,1,32)) + " - " + UPPER(Alltrim(SM0->M0_BAIRCOB)),oFont05 )
			oPrint:Say (0225, 0210,"CEP: " + Alltrim(Substr(SM0->M0_CEPCOB,1,5)) + "-" + Alltrim(Substr(SM0->M0_CEPCOB,6,3)) + " - " + Alltrim(SM0->M0_CIDCOB) + " / " + Alltrim(SM0->M0_ESTCOB),oFont05 )
		EndIf
		oPrint:Say (0211,0360,"CNPJ" ,oFont06N,100)
		If _cSubcta == "RVL" 
			oPrint:Say (0221,0361,Transform(SEE->EE_XCNPJVL,"@R 99.999.999/9999-99"),oFont08) //Cnpj do Beneficiแrio - "04.229.761/0001-70"
		Else
			//oPrint:Say (0221,0361,"14.555.032/0001-68",oFont08) //Cnpj do Beneficiแrio Transform(cCgcSM0,"@R 99.999.999/9999-99")
			oPrint:Say (0221,0361,Transform(cCgcSM0,"@R 99.999.999/9999-99"),oFont08) //Cnpj do Beneficiแrio 
		EndIf
		BuzzBox  (0205,0425,0230,0560)	// Agencia 	/ Codigo do Cedente
		oPrint:Say (0211, 0426,"Ag๊ncia/C๓digo de Beneficiแrio",oFont08 )
		If _cBanco == "208"
			oPrint:Say(0221,0436,Substr(Alltrim(_cAgencia),1,4)+"/"+Iif(_cSubCta == "RVL",Substr(Alltrim(_cCodEmp),9,7),Substr(Alltrim(_cCodEmp),6,7)),oFont08,100)
		EndIf
		BuzzBox  (0230,0025,0255,0100)	// Data do Documento
		oPrint:Say (0236, 0026,"Data do Documento",oFont06N )
		oPrint:Say (0246, 0056,Substr( DtoS(SE1->E1_EMISSAO),7,2 ) + "/" + Substr( DtoS(SE1->E1_EMISSAO),5,2 ) + "/" + Substr( DtoS(SE1->E1_EMISSAO),1,4 ),oFont08 )
		BuzzBox  (0230,0100,0255,0225)	// Nro. Documento + Parcela
		oPrint:Say (0236, 0101,"Nฐ do Documento",oFont06N )
		oPrint:Say (0246, 0111,SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA,oFont08 )
		BuzzBox  (0230,0225,0255,0275)	// Especie Doc.
		oPrint:Say (0236, 0226,"Especie Doc.",oFont06N )
		If _cBanco == "208"
			oPrint:Say (0246, 0246,"DM",oFont06 )
		EndIf
		BuzzBox  (0230,0275,0255,0325)	// Aceite
		oPrint:Say (0236, 0276,"Aceite",oFont06N )
		oPrint:Say (0246, 0306,"N",oFont06 )
		BuzzBox  (0230,0325,0255,0425)	// Data do Processamento
		oPrint:Say (0236, 0326,"Data do Processamento",oFont06N )
		oPrint:Say (0246, 0356,Substr( DtoS(SE1->E1_EMISSAO),7,2 ) + "/" + Substr( DtoS(SE1->E1_EMISSAO),5,2 ) + "/" + Substr( DtoS(SE1->E1_EMISSAO),1,4 ),oFont08 )
		BuzzBox  (0230,0425,0255,0560)	// Nosso Numero
		oPrint:Say (0236, 0426,"Nosso Numero",oFont06N )
		If _cBanco == "208"
			oPrint:Say (0246, 0476,Substr(SE1->E1_NUMBCO,1,Len(Alltrim(SE1->E1_NUMBCO))-1) + " " + Right(AllTrim(SE1->E1_NUMBCO),1),oFont08 )
		EndIf
		BuzzBox  (0255,0025,0280,0100)	// Uso do Banco
		oPrint:Say (0261, 0026,"Uso do Banco",oFont06N )
		BuzzBox  (0255,0100,0280,0165)	// Carteira
		oPrint:Say (0261, 0101,"Carteira",oFont06N )
		If _cBanco == "208"
			oPrint:Say (0271, 0131,_cCart,oFont08 )
		EndIf
		BuzzBox  (0255,0165,0280,0225)	// Especie
		oPrint:Say (0261, 0166,"Especie",oFont06N )
		If _cBanco == "208"
			oPrint:Say (0271, 0186,"R$",oFont06N )
		EndIf
		BuzzBox  (0255,0225,0280,0325)	// Quantidade
		oPrint:Say (0261, 0226,"Quantidade",oFont06N )
		BuzzBox  (0255,0325,0280,0425)	// Valor
		oPrint:Say (0261, 0326,"Valor",oFont06N )
		BuzzBox  (0255,0425,0280,0560)	// Valor do Documento
		oPrint:Say (0261, 0426,"Valor do Documento",oFont06N )
		oPrint:Say (0271, 0476,AllTrim(Transform(Iif(SE1->E1_PREFIXO <> "RPS",SE1->E1_SALDO + SE1->E1_ACRESC,(SE1->E1_SALDO + SE1->E1_ACRESC) - (aValImps[5] + aValImps[3] + aValImps[4] + aValImps[7] + aValImps[2] + aValImps[6])),"@E 999,999,999.99")),oFont08N )
		BuzzBox  (0280,0025,0380,0425)	// Instru็๕es (Todas as Informa็๕es deste Bloqueto sใo de Exclusiva Responsabilidade do Cedente)
		oPrint:Say (0286, 0026,"Instru็๕es (Todas as Informa็๕es deste Bloqueto sใo de Exclusiva Responsabilidade do Cedente)",oFont06N )
		oPrint:Say  (0316,0026,"Ap๓s vencimento cobrar mora de R$ ..... " + Alltrim(Transform(((Iif(SE1->E1_PREFIXO <> "RPS",SE1->E1_SALDO,SE1->E1_SALDO - (aValImps[5] + aValImps[3] + aValImps[4] + aValImps[7] + aValImps[2] + aValImps[6])) * _nxJuros)/100)/30,"@E 99,999,999.99"))+ " ao dia", oFont08,100)
		//oPrint:Say  (0326,0026,"Multa por atraso de " + Alltrim(Transform(_nxMulta,"@E 99,999,999.99")) + " % ao m๊s.", oFont08,100)
		//If !Empty(SE1->E1_DECRESC)
		//	oPrint:Say  (0346,0026,"Conceder Desconto de R$ ..... " + AllTrim(Transform((SE1->E1_DECRESC),"@E 99,999,999.99")), oFont08,100)
		//EndIf
		oPrint:Say  (2086,0026,"Protestar ap๓s " + Alltrim(_cProtesto) + " dias corridos do vencimento.", oFont08,100)
		BuzzBox  (0280,0425,0300,0560)	// (-) Desconto / Abatimento
		oPrint:Say (0286, 0426,"(-) Desconto / Abatimento",oFont06N )
		BuzzBox  (0300,0425,0320,0560)	// (-) Outras Dedu็๕es
		oPrint:Say (0306, 0426,"(-) Outras Dedu็๕es",oFont06N )
		BuzzBox  (0320,0425,0340,0560)	// (+) Mora / Multa
		oPrint:Say (0326, 0426,"(+) Mora / Multa",oFont06N )
		BuzzBox  (0340,0425,0360,0560)	// (+) Outros Acrescimos
		oPrint:Say (0346, 0426,"(+) Outros Acrescimos",oFont06N )
		BuzzBox  (0360,0425,0380,0560)	// (=) Valor Cobrado
		oPrint:Say (0366, 0426,"(=) Valor Cobrado",oFont06N )
		BuzzBox  (0380,0025,0450,0560)	// Pagador / Pagador Avalista
		oPrint:Say (0386, 0026,"Pagador",oFont06N )
		oPrint:Say  (0396,0106,Upper(SA1->A1_NOME),oFont08 ,100)
		oPrint:Say  (0406,0106,SA1->(If(Empty(A1_ENDCOB),A1_END,A1_ENDCOB) + " " + If(Empty(SA1->A1_BAIRROC),SA1->A1_BAIRRO,SA1->A1_BAIRROC)),oFont08 ,100)
		oPrint:Say  (0416,0106,SA1->(If(Empty(SA1->A1_CEPC),SA1->A1_CEP,SA1->A1_CEPC) + " " + If(Empty(SA1->A1_MUNC),SA1->A1_MUN,SA1->A1_MUNC) + " " + If(Empty(SA1->A1_ESTC),SA1->A1_EST,SA1->A1_ESTC)),oFont08 ,100)
		oPrint:Say  (0426,0106,SA1->(Transform(Alltrim(SA1->A1_CGC),PesqPict("SA1","A1_CGC")) + "               " + A1_INSCR),oFont08 ,100)
		oPrint:Say  (0448, 0026,"Pagador Avalista: ",oFont08N )
		If _cSubcta == "RVL"
			oPrint:Say  (0448,0106,Alltrim(SM0->M0_NOMECOM) + "   -   CNPJ: " + Transform(cCgcSM0,"@R 99.999.999/9999-99"),oFont10 ,100)
		Endif
		oPrint:Say  (0455,0360,"Autentica็ใo Mecโnica",oFont06,100)

		//-------------
		// Via do banco
		// 3ฐ Parte
		//-------------
		If _cBanco = "208"
			oPrint:SayBitmap(0480,0025,_cBcoLogo,0085,0020)
		EndIf
		_cCodBar := Alltrim(SE1->E1_CODBAR)
		_cNumBol := Alltrim(SE1->E1_CODDIG)
		If _cBanco = "208"
			_cCodBarLit := Left(_cNumBol,5) + "." + Substr(_cNumBol,6,5) + "   " +;
						   Substr(_cNumBol,11,5) + "." + Substr(_cNumBol,16,6) + "   " +;
						   Substr(_cNumBol,22,5) + "." + Substr(_cNumBol,27,6) + "   " +;
						   Substr(_cNumBol,33,1) + "   " +;
						   Substr(_cNumBol,34)
		EndIf
		oPrint:Say(0496,0200,_cCodBarLit,oFont14N,100)
		If _cBanco = "208"
			oPrint:Say(0496,0110, "|" + _cBanco + "-" + _cDigBanco + "|" ,oFont18N,100)	// C๓digo do Banco + Dํgito
		EndIf
		BuzzBox  (0500,0025,0525,0425)	// Local de Pagamento
		oPrint:Say (0506, 0026,"Local de Pagamento",oFont06N )
		If _cBanco = "208"
			oPrint:Say  (0510, 0096,"PAGAVEL EM QUALQUER BANCO ATE O VENCIMENTO. ",oFont06N )
		EndIf
		BuzzBox  (0500,0425,0525,0560)	// Vencimento
		oPrint:Say (0506, 0426,"Vencimento",oFont06N )
		oPrint:Say (0516, 0476,Substr( DtoS(SE1->E1_VENCTO),7,2 ) + "/" + Substr( DtoS(SE1->E1_VENCTO),5,2 ) + "/" + Substr( DtoS(SE1->E1_VENCTO),1,4 ),oFont08 )
		BuzzBox  (0525,0025,0550,0425)	// Beneficiario
		oPrint:Say (0531, 0026,"Beneficiแrio",oFont06N )
		If _cSubcta == "RVL"
			oPrint:Say (0541, 0026,Alltrim(Substr(SEE->EE_XNOMEVL,1,30)),oFont08 )	// "VIDEOLAR INNOVA S/A"
		Else
			oPrint:Say (0541, 0026,"Replas Ind. e Comercio de Resinas Plasticas e BOPP Ltda",oFont08 )	// Alltrim(SM0->M0_NOMECOM)
		EndIf
		If _cBanco == "208"
			oPrint:Say (0531, 0210,"Endere็o",oFont06N )
			oPrint:Say (0538, 0210,Alltrim(Substr(SM0->M0_ENDCOB,1,32)) + " - " + Upper(Alltrim(SM0->M0_BAIRCOB)),oFont05 )
			oPrint:Say (0545, 0210,"CEP: " + Alltrim(Substr(SM0->M0_CEPCOB,1,5)) + "-" + Alltrim(Substr(SM0->M0_CEPCOB,6,3)) + " - " + Alltrim(SM0->M0_CIDCOB) + " / " + Alltrim(SM0->M0_ESTCOB),oFont05 )
		EndIf
		oPrint:Say (0531,0360,"CNPJ" ,oFont06N,100)
		If _cSubcta == "RVL" 
			oPrint:Say (0541,0361,Transform(SEE->EE_XCNPJVL,"@R 99.999.999/9999-99"),oFont08) //Cnpj do Beneficiแrio - "04.229.761/0001-70"
		Else
			//oPrint:Say (0541,0361,"14.555.032/0001-68",oFont08) //Cnpj do Beneficiแrio Transform(cCgcSM0,"@R 99.999.999/9999-99")
			oPrint:Say (0541,0361,Transform(cCgcSM0,"@R 99.999.999/9999-99"),oFont08) //Cnpj do Beneficiแrio 
		EndIf
		BuzzBox  (0525,0425,0550,0560)	// Agencia / Codigo do Cedente
		oPrint:Say (0531, 0426,"Ag๊ncia/C๓digo do Beneficiแrio",oFont06N )
		//oPrint:Say (0541, 0426,Substr(Alltrim(_cAgencia),1,4) + "-" + Alltrim(_cDvAge) + "/" + Alltrim(_cConta) + "-" + Alltrim(_cDvCta),oFont06,100)
		If _cBanco == "208"
			oPrint:Say (0541,0436,Substr(Alltrim(_cAgencia),1,4)+"/"+Iif(_cSubCta == "RVL",Substr(Alltrim(_cCodEmp),9,7),Substr(Alltrim(_cCodEmp),6,7)),oFont06,100)
		EndIf
		BuzzBox  (0550,0025,0575,0100)	// Data do Documento
		oPrint:Say (0556, 0026,"Data do Documento",oFont06N )
		oPrint:Say (0566, 0046,Substr( DtoS(SE1->E1_EMISSAO),7,2 ) + "/" + Substr( DtoS(SE1->E1_EMISSAO),5,2 ) + "/" + Substr( DtoS(SE1->E1_EMISSAO),1,4 ),oFont08 )
		BuzzBox  (0550,0100,0575,0225)	// Nro. Documento + Parcela
		oPrint:Say (0556, 0101,"Nฐ do Documento",oFont06N )
		oPrint:Say (0566, 0111,SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA,oFont08 )
		BuzzBox  (0550,0225,0575,0275)	// Especie Doc.
		oPrint:Say (0556, 0226,"Especie Doc.",oFont06N )
		If _cBanco == "208"
			oPrint:Say (0566, 0246,"DM",oFont06 )
		EndIf
		BuzzBox  (0550,0275,0575,0325)	// Aceite
		oPrint:Say (0556, 0276,"Aceite",oFont06N )
		oPrint:Say (0566, 0296,"N",oFont06 )
		BuzzBox  (0550,0325,0575,0425)	// Data do Processamento
		oPrint:Say (0556, 0326,"Data do Processamento",oFont06N )
		oPrint:Say (0566, 0356,Substr( DtoS(SE1->E1_EMISSAO),7,2 ) + "/" + Substr( DtoS(SE1->E1_EMISSAO),5,2 ) + "/" + Substr( DtoS(SE1->E1_EMISSAO),1,4 ),oFont08 )
		BuzzBox  (0550,0425,0575,0560)	// Nosso Numero
		oPrint:Say (0556, 0426,"Nosso Numero",oFont06N )
		If _cBanco=="208"
			oPrint:Say (0566, 0476,Substr(SE1->E1_NUMBCO,1,Len(Alltrim(SE1->E1_NUMBCO))-1) + " " + Right(AllTrim(SE1->E1_NUMBCO),1),oFont08 )
		EndIf
		BuzzBox  (0575,0025,0600,0100)	// Uso do Banco
		oPrint:Say (0581, 0026,"Uso do Banco",oFont06N )
		BuzzBox  (0575,0100,0600,0165)	// Carteira
		oPrint:Say (0581, 0101,"Carteira",oFont06N )
		If _cBanco == "208"
			oPrint:Say (0591, 0131,_cCart,oFont08 )
		EndIf
		BuzzBox  (0575,0165,0600,0225)	// Especie
		oPrint:Say (0581, 0166,"Especie",oFont06N )
		If _cBanco == "208"
			oPrint:Say (0591, 0186,"R$",oFont06N )
		EndIf
		BuzzBox  (0575,0225,0600,0325)	// Quantidade
		oPrint:Say (0581, 0226,"Quantidade",oFont06N )
		BuzzBox  (0575,0325,0600,0425)	// Valor
		oPrint:Say (0581, 0326,"Valor",oFont06N )
		BuzzBox  (0575,0425,0600,0560)	// Valor do Documento
		oPrint:Say (0581, 0426,"Valor do Documento",oFont06N )
		oPrint:Say (0591, 0476,AllTrim(Transform(IIf(SE1->E1_PREFIXO <> "RPS",SE1->E1_SALDO + SE1->E1_ACRESC,(SE1->E1_SALDO + SE1->E1_ACRESC)- (aValImps[5] + aValImps[3] + aValImps[4] + aValImps[7] + aValImps[2] + aValImps[6])),"@E 999,999,999.99")),oFont08N )
		BuzzBox  (0600,0025,0700,0425)	// Instru็๕es (Todas as Informa็๕es deste Bloqueto sใo de Exclusiva Responsabilidade do Cedente)
		oPrint:Say (0606, 0026,"Instru็๕es (Todas as Informa็๕es deste Bloqueto sใo de Exclusiva Responsabilidade do Cedente)",oFont06N )
		oPrint:Say  (0626,0026,"Ap๓s vencimento cobrar mora de R$ ..... " + Alltrim(Transform(((Iif(SE1->E1_PREFIXO <> "RPS",SE1->E1_SALDO,SE1->E1_SALDO - (aValImps[5] + aValImps[3] + aValImps[4] + aValImps[7] + aValImps[2] + aValImps[6])) * _nxJuros)/100)/30,"@E 99,999,999.99"))+ " ao dia", oFont08,100)
		//oPrint:Say  (0636,0026,"Multa por atraso de " + Alltrim(Transform(_nxMulta,"@E 99,999,999.99")) + " % ao m๊s.", oFont08,100)
		//If !Empty(SE1->E1_DECRESC)
		//	oPrint:Say  (0666,0026,"Conceder Desconto de R$ ..... " + AllTrim(Transform((SE1->E1_DECRESC),"@E 99,999,999.99")), oFont08,100)
		//EndIf
		oPrint:Say  (0646,0026,"Protestar ap๓s " + Alltrim(_cProtesto) + " dias corridos do vencimento.", oFont08,100)
		BuzzBox  (0600,0425,0620,0560)	// (-) Desconto / Abatimento
		oPrint:Say (0606, 0426,"(-) Desconto / Abatimento",oFont06N )
		BuzzBox  (0620,0425,0640,0560)	// (-) Outras Dedu็๕es
		oPrint:Say (0626, 0426,"(-) Outras Dedu็๕es",oFont06N )
		BuzzBox  (0640,0425,0660,0560)	// (+) Mora / Multa
		oPrint:Say (0646, 0426,"(+) Mora / Multa",oFont06N )
		BuzzBox(0660,0425,0680,0560)	// (+) Outros Acrescimos
		oPrint:Say(0666, 0426,"(+) Outros Acrescimos",oFont06N )
		BuzzBox(0680,0425,0700,0560)	// (=) Valor Cobrado
		oPrint:Say(0686, 0426,"(=) Valor Cobrado",oFont06N )
		BuzzBox(0700,0025,0770,0560)	// Pagador / Pagador Avalista
		oPrint:Say(0706, 0026,"Pagador",oFont06N )
		oPrint:Say(0716,0106,Upper(SA1->A1_NOME),oFont08 ,100)
		oPrint:Say(0726,0106,SA1->(If(Empty(A1_ENDCOB),A1_END,A1_ENDCOB) + " " + If(Empty(SA1->A1_BAIRROC),SA1->A1_BAIRRO,SA1->A1_BAIRROC)),oFont08 ,100)
		oPrint:Say(0736,0106,SA1->(If(Empty(SA1->A1_CEPC),SA1->A1_CEP,SA1->A1_CEPC) + " " + If(Empty(SA1->A1_MUNC),SA1->A1_MUN,SA1->A1_MUNC) + " " + If(Empty(SA1->A1_ESTC),SA1->A1_EST,SA1->A1_ESTC)),oFont08 ,100)
		oPrint:Say(0746,0106,SA1->(Transform(Alltrim(SA1->A1_CGC),PesqPict("SA1","A1_CGC")) + "               " + A1_INSCR),oFont08 ,100)
		oPrint:Say(0768, 0026,"Pagador Avalista:",oFont06N )
		If _cSubcta == "RVL"
			oPrint:Say(0768,0106,Alltrim(SM0->M0_NOMECOM) + "   -   CNPJ: " + Transform(cCgcSM0,"@R 99.999.999/9999-99"),oFont10 ,100)
		Endif
		oPrint:Say(0775,0350,"Autentica็ใo Mecโnica - Ficha de Compensa็ใo",oFont06,100)
		oPrint:FWMSBAR("INT25",66.2,2.0,_cCodBar,oPrint,.F.,,,,1.0,,,,.F.)  //28.0
		oPrint:EndPage()
		oPrint:Print()
		oObj:IncRegua2("Gerando os Boletos dos Titulos..." + Alltrim(SE1->E1_NUM) + " " + Alltrim(SE1->E1_PARCELA) )
	EndIf
Next
MsgInfo("Foram Salvos " + AllTrim(Str(nCont)) + " Boletos no Diret๓rio C:\Boleto208\")
WinExec( "Explorer.exe C:\Boleto208" )

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma ณ BuzzBox         บAutorณ Silvio Cazela              บ Data ณ 24/04/2013 บฑฑ
ฑฑฬอออออออออุอออออออออออออออออสอออออฯออออออออออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricaoณ Desenha um Box Sem Preenchimento                                       บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function BuzzBox(_nLinIni,_nColIni,_nLinFin,_nColFin) // < nRow>, < nCol>, < nBottom>, < nRight>

oPrint:Line( _nLinIni,_nColIni,_nLinIni,_nColFin,CLR_BLACK, "-2")
oPrint:Line( _nLinFin,_nColIni,_nLinFin,_nColFin,CLR_BLACK, "-2")
oPrint:Line( _nLinIni,_nColIni,_nLinFin,_nColIni,CLR_BLACK, "-2")
oPrint:Line( _nLinIni,_nColFin,_nLinFin,_nColFin,CLR_BLACK, "-2")

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณRetImp   บAutor  ณEduardo Augusto      บ Data ณ  27/02/2015 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao criada para Reter os Impostos conforme os Valores   บฑฑ
ฑฑบ          ณ das Parcelas.                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Totvs Na็๕es Unidas                                        บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function RetImp()

Local nValor := 0
Local nValIR := 0
Local nValCF := 0
Local nValPI := 0
Local nValCS := 0
Local nValINS := 0
Local nValISS := 0  
Local cQuery  := ""   
If Select("TRB") > 0
   DbSelectArea("TRB")
   DbCloseArea()
EndIf                  
cQuery := " SELECT E1_TIPO, E1_VALOR "
cQuery += " FROM " + RetSqlName("SE1")
cQuery += " WHERE E1_FILIAL	= '" + xfilial('SE1') + "' "  
cQuery += " 	AND E1_PREFIXO = '" + SE1->E1_PREFIXO + "' "
cQuery += " 	AND E1_NUM = '" + SE1->E1_NUM + "' "
cQuery += " 	AND E1_PARCELA = '" + SE1->E1_PARCELA + "' "
cQuery += " 	AND	D_E_L_E_T_ <> '*' "
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"TRB", .F., .T.)
DbSelectArea("TRB") 
DbGoTop("TRB")
While TRB->(!Eof())
	If TRB->E1_TIPO == "NF"
		nValor := TRB->E1_VALOR
	ElseIf TRB->E1_TIPO == "IR-"
		nValIR := TRB->E1_VALOR
	ElseIf TRB->E1_TIPO == "CF-" 
		nValCF := TRB->E1_VALOR
	ElseIf TRB->E1_TIPO == "PI-" 
		nValPI := TRB->E1_VALOR
	ElseIf TRB->E1_TIPO == "CS-" 
		nValCS := TRB->E1_VALOR
	ElseIf TRB->E1_TIPO == "INS" 
		nValINS := TRB->E1_VALOR 
	ElseIf TRB->E1_TIPO == "IS-" 
		nValISS := TRB->E1_VALOR 
	EndIf
	TRB->(DbSkip())		
End
If Select("TRB") > 0
   DbSelectArea("TRB")
   DbCloseArea()
EndIf             

Return ({nValor,nValIR,nValCF,nValPI,nValCS,nValINS,nValISS})

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณMTBCO     บ Autor ณ EduarDo Augusto    บ Data ณ  17/02/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Fonte p/ Tratamento Do Nosso Numero, Digitos VerIficaDores บฑฑ
ฑฑบ          ณ Montagem da Linha Digitavel e Codigo de Barras.            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Rentank		                                              บฑฑ
ฑฑฬออออออออออุออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ							                                              บฑฑ
ฑฑฬออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ                                                                       บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

User Function CalcBtg(_aBoletos,_cBanco,_cAgencia,_cConta,_cSubcta,_Tipo,_EmisIni,_EmisFim,_cTitulo)

Local _aArea   	:= Getarea()
Local _aImpBol 	:= {}
Local _nXx		:= 0
Local lRet		:= .T.
Default  _cBanco	:= ""
Default  _cAgencia	:= ""
Default  _cConta	:= ""
Default  _cSubcta	:= ""
Default  _Tipo		:= ""
Default  _EmisIni	:= CtoD("  /  /  ")
Default  _EmisFim	:= CtoD("  /  /  ")
Default  _cTitulo	:= ""
For _nXx:=1 To Len(_aBoletos)
	If Empty(_aBoletos[_nXx][6])
		SF2->(DbGoTo(_aBoletos[_nXx][1]))
		SC5->(DbGoTo(_aBoletos[_nXx][4]))
		lRet := U_CodBco208(_aBoletos[_nXx,2],_aBoletos[_nXx,3],_cBanco,_cAgencia,_cConta,_cSubcta,_Tipo,_EmisIni,_EmisFim,_cTitulo)
		If !lRet
			RestArea(_aArea)
			Return lRet
		EndIf
		_aBoletos[_nXx][6] := "Ok"
		aAdd(_aImpBol,{_aBoletos[_nXx,3],_aBoletos[_nXx,2]}) // Serie/Doc
	EndIf
Next _nXx
RestArea(_aArea)

Return lRet

User Function CodBco208(_cNumeIni,cInull,_cBanco,_cAgencia,_cConta,_cSubcta,_Tipo,_EmisIni,_EmisFim,_cTitulo)

Local _vAmbSa1    := SA1->(GetArea())
Local _cNumBar    := ""
Local _cNossoNum  := ""
Local cQuery	  := ""
Local lRet	:=	.T.
private _cDigBar  := ""
Private _cDigCor  := ""
Private _nDigtc3  := 0
Private _cDig1bar := 0
Default  _cBanco	:= ""
Default  _cAgencia	:= ""
Default  _cConta	:= ""
Default  _cSubcta	:= ""
Default  _Tipo		:= ""
Default  _EmisIni	:= CtoD("  /  /  ")
Default  _EmisFim	:= CtoD("  /  /  ")
Default  _cTitulo	:= ""
Default		cInull	:= ""
cSelect	:= " SELECT * " + ENTER
cFrom	:= " FROM " + RetSqlName("SEE") + " SEE " + ENTER
cWhere	:= " WHERE SEE.EE_FILIAL = '" + xFilial("SEE") + "' " + ENTER
cWhere	+= " 	AND SEE.D_E_L_E_T_ = ' '" + ENTER
cWhere	+= " 	AND SEE.EE_CODIGO = '" + _cBanco + "' " + ENTER
cQuery := cSelect + cFrom + cWhere
If Select( "TMP" ) > 0
	DbSelectArea( "TMP" )
	DbCloseArea()
EndIf
MemoWrite( "rfatr01b.sql" , cQuery )
TcQuery cQuery New Alias "TMP"
_cParcIni	:= SE1->E1_PARCELA
_cPrefixo	:= SE1->E1_PREFIXO
_cNum    	:= SE1->E1_NUM
_cParcFim	:= SE1->E1_PARCELA
If Empty(_cBanco)
	If Len(TMP) > 0
		_cBanco   := TMP->EE_CODIGO
		_cAgencia := TMP->EE_AGENCIA
		_cConta   := TMP->EE_CONTA
		_cDvCta   := TMP->EE_DVCTA
	EndIf
EndIf
_cNossoNum	:= ""
If Mv_Par05 == 2 .And. !Empty(SE1->E1_XNUMBCO)
	_cNossoNum := SE1->E1_XNUMBCO
Else
	Do Case
		Case _cBanco == "208"
			_cNossoNum	:= Nosso208(_cBanco,_cAgencia,_cConta,_cSubcta,_Tipo,_EmisIni,_EmisFim,_cTitulo)
	EndCase
EndIf
// Tratando em caso de nosso numero vir vazio
If Empty(_cNossoNum)
	Msginfo("Nosso n๚mero nใo preenchido, verifique se a tabela de parametros para o banco informado esta preenchida (SEE).")
	lRet:=.F.
	Return lRet
EndIf
aValImps:= RetImp()//nValor,nValIR,nValCF,nValPI,nValCS,nValINS,nValISS
If _cBanco == "208"
	_cNossoNum	:= Alltrim(_cNossoNum)
	_cNossoDig	:= Right(_cNossoNum,1)
	_cDigBar	:= ""
	_cNumBar	:= _fNumBar(_cBanco,_cAgencia,_cConta,_cNossoNum,@_cDigBar,_cNossoDig)
	_cNumBol	:= _fNumBol(_cBanco,_cAgencia,_cConta,_cNossoNum,_cNumBar)
EndIf
If !Empty(_cNossoNum) .Or. !Empty(_cNumBar) .Or. !Empty(_cNumbol)
	If SE1->(Reclock(Alias(),.F.))
		If _cBanco == "208"
			SE1->E1_NUMBCO	:= _cNossoNum
			If Empty(SE1->E1_NUMBCO)
				SE1->E1_NUMBCO  := _cNossoNum + _cNossoDig
			Else
				SE1->E1_NUMBCO  := SE1->E1_NUMBCO
			EndIf
		EndIf
		SE1->E1_PORTADO	:= _cBanco
		SE1->E1_AGEDEP	:= _cAgencia
		SE1->E1_CONTA	:= _cConta
		SE1->E1_CODBAR  := _cNumBar
		SE1->E1_CODDIG  := _cNumBol
		If Empty(SE1->E1_XNUMBCO) // Vazio
			SE1->E1_XNUMBCO := SE1->E1_NUMBCO
		Else // Ja gravaDo
			If Mv_Par05 == 2 .And. !Empty(SE1->E1_XNUMBCO)
				SE1->E1_NUMBCO := SE1->E1_XNUMBCO // Usa o original
			Else
				_cNossoNum := SE1->E1_XNUMBCO
			EndIf
		EndIf
		SE1->(msunlock())
	EndIf
EndIf
RetIndex("SA1")

Return lRet

Static Function _fNumBol(_cBanco,_cAgencia,_cConta,_cNossoNum,_cNumBar)	// Montagem da Linha Digitavel

Local _cNumBol,_cNossoNu1:=_cNossoNum,_nVez
Local w
Local nFatVenc
For _nVez := 1 To Len(_cNossoNum)
	If Substr(_cNossoNum,_nVez,1)	==	"0"
		_cNossoNu1	:=	Right(_cNossoNu1,Len(_cNossoNu1)-1)
	Else
		Exit
	EndIf
Next
Do Case
	Case _cBanco == "208" 
		cCpo01 := _cBanco
		cCpo02 := "9" // Moeda "9"=Real
		cCpo03 := "9" // Fixo "9"
		cCpo04 := Iif(_cSubcta == "RVL",Substr(Alltrim(_cCodEmp),9,4),Substr(Alltrim(_cCodEmp),6,4)) 
		cDig_4 := _fDigVer(_cBanco + "99" + cCpo04,cCpo01)
		cCpo05 := Iif(_cSubcta == "RVL",Substr(Alltrim(_cCodEmp),13,3),Substr(Alltrim(_cCodEmp),10,3)) + Substr(_cNossoNum,1,7) // Restante Do Cod Cedente
		cDig_5 := _fDigVer2(cCpo05, _cBanco)
		cCpo06 := Substr(_cNossoNum,8,6) // Restante Do Nosso Numero
		cCpo07 := "0" // IOS
		cCpo08 := "101" // "101"=Cobranca Simples Com Registro
		cDig_8 := _fDigVer3(cCpo06 + cCpo07 + cCpo08, _cBanco)
		cDig_9 := _cDig1bar
		//-- Novo calculo do Fator de Vencimento que passou a valer para boletos com vencimento ate 21/02/2025
		nFatVenc := SE1->E1_VENCTO - CToD("07/10/1997")
		If nFatVenc > 9999
			nFatVenc := nFatVenc - 9000
		EndIf		
		cCpo10 := Strzero(nFatVenc,4) // Fator de Vencimento
		cCpo11 := Strzero((Iif(SE1->E1_PREFIXO <> "RPS",SE1->E1_SALDO + SE1->E1_ACRESC,(SE1->E1_SALDO + SE1->E1_ACRESC) - (aValImps[5] + aValImps[3] + aValImps[4] + aValImps[7] + aValImps[2] + aValImps[6])))*100,10)
		_cNumBol := cCpo01 + cCpo02 + cCpo03 + cCpo04 + cDig_4
		_cNumBol += cCpo05 + cDig_5
		_cNumBol += cCpo06 + cCpo07 + cCpo08 + cDig_8
		_cNumBol += cDig_9
		_cNumBol += cCpo10 + cCpo11
EndCase

Return _cNumBol

Static Function _fNumBar(_cBanco,_cAgencia,_cConta,_cNossoNum,_cDigBar,_cNossoDig)	// Montagem do C๓digo de Barras

Local _cNumBar,_cNossoNu1 := _cNossoNum,_nVez
Local nFatVenc
Private _cDigcor := ""
For _nVez:=1 To Len(_cNossoNum)
	If Substr(_cNossoNum,_nVez,1) == "0"
		_cNossoNu1:=Right(_cNossoNu1,Len(_cNossoNu1)-1)
	Else
		Exit
	EndIf
Next
Do Case
	Case _cBanco == "208" 
		//-- Novo calculo do Fator de Vencimento que passou a valer para boletos com vencimento ate 21/02/2025
		nFatVenc := SE1->E1_VENCTO - CToD("07/10/1997")
		If nFatVenc > 9999
			nFatVenc := nFatVenc - 9000
		EndIf	
		_cCampo1 := _cBanco + "9" + Strzero(nFatVenc,4) + Strzero((Iif(SE1->E1_PREFIXO <> "RPS",SE1->E1_SALDO + SE1->E1_ACRESC,(SE1->E1_SALDO + SE1->E1_ACRESC) - (aValImps[5] + aValImps[3] + aValImps[4] + aValImps[7] + aValImps[2] + aValImps[6])))*100,10) + "9" + Iif(_cSubcta == "RVL",Substr(Alltrim(_cCodEmp),9,7),Substr(Alltrim(_cCodEmp),6,7)) + _cNossoNum + "0" + "101"
		_cDig1bar := _fDigBar(_cCampo1,_cBanco)
		_cCampo2 :=_cBanco + "9" + _cDig1bar + Strzero(nFatVenc,4) + Strzero((Iif(SE1->E1_PREFIXO<>"RPS",SE1->E1_SALDO + SE1->E1_ACRESC,(SE1->E1_SALDO + SE1->E1_ACRESC) - (aValImps[5] + aValImps[3] + aValImps[4] + aValImps[7] + aValImps[2] + aValImps[6])))*100,10) + "9" + Iif(_cSubcta == "RVL",Substr(Alltrim(_cCodEmp),9,7),Substr(Alltrim(_cCodEmp),6,7)) + _cNossoNum + "0" + "101"
		_cNumBar := _cCampo2
EndCase

Return _cNumBar

Static Function _fDigVer(_cCampo,_cBanco)

Local _nVez,_nVez1,_nFator,_nPeso,_nReturn,_nResult,_cResult
If _cBanco == "208" 
	_nFator := 0
	_nPeso	:= 2
	_nReturn:= 0
	For _nVez := Len(_cCampo) To 1 Step - 1
		_nResult := Val(Substr(_cCampo,_nVez,1)) * _nPeso
		_cResult := Strzero(_nResult,2)
		_nFator += Val(Substr(_cResult,1,1))
		_nFator += Val(Substr(_cResult,2,1))
		_nPeso := If(_nPeso == 2,1,2)
	Next
	_nReturn := Mod(_nFator,10)
	If _nReturn > 0
		_nReturn := 10 - _nReturn
	EndIf
EndIf
SEE->(DbCloseArea())

Return Str(_nReturn,1)

Static Function _fDigBar(_cCampo,_cBanco)

Local _nVez,_nPeso,_nFator,_nResto
Local w
If _cBanco == "208" 
	_nPeso := 2
	_nFator_ := 0
	_nFator := 0
	_nFatorAux := 0
	_nResto := 0
	_nVez := 1
	nSoma := 0
	nPeso := 2
	For w := Len(_cCampo) To 1 Step -1
		nCalc := Val(Substr(_cCampo,w,1)) * nPeso
		nSoma += nCalc
		nPeso := IIf(nPeso == 9, 2, ++nPeso)
	Next
	nSoma *= 10
	_nResto := Mod(nSoma,11)
	If _nResto == 0 .Or. _nResto == 1 .Or. _nResto == 10
		_nResto := 1
	EndIf
EndIf
SEE->(DbCloseArea())

Return Str(_nResto,1)

Static Function Nosso208(_cBanco,_cAgencia,_cConta,_cSubcta,_Tipo,_EmisIni,_EmisFim,_cTitulo)

Private cNumero	:= Space(12)
Private cDig	:= Space(01)
Default  _cBanco	:= ""
Default  _cAgencia	:= ""
Default  _cConta	:= ""
Default  _cSubcta	:= ""
Default  _Tipo		:= ""
Default  _EmisIni	:= CtoD("  /  /  ")
Default  _EmisFim	:= CtoD("  /  /  ")
Default  _cTitulo	:= ""
If Empty(SE1->E1_NUMBCO)
	DbSelectArea("SEE")
	DbSetOrder(1)
	If DbSEEk(xFilial("SEE") + _cBanco + _cAgencia + _cConta + Mv_Par04,.T.)
		cNumero:= Strzero(Val(Strzero(Val(SEE->EE_FAXATU),Len(SEE->EE_FAXATU))),12)
		cDig	:= NnumPlas(cNumero)
		cNumero2:= cNumero + cDig
		If RecLock("SEE",.f.)
			Replace EE_FAXATU With Soma1(cNumero,Len(SEE->EE_FAXATU))
			SEE->( MsUnlock() )
		EndIf
		_cRet := cNumero2
	Else
		Conout("Nใo existe configura็ใo para o banco informado SEE, favor preencher.")
		Msginfo("Nใo existe configura็ใo para o banco informado SEE, favor preencher.")
	EndIf
Else
	_cRet := SE1->E1_NUMBCO
EndIf

Return(_cRet)

Static Function NnumPlas(_cCampo)	

Local _nCnt   := 0
Local _nPeso  := 2
Local _nJ     := 1
Local _nResto := 0
For _nJ := Len(_cCampo) To 1 Step -1
	_nCnt  := _nCnt + Val(Substr(_cCampo,_nJ,1)) * _nPeso
	_nPeso :=_nPeso+1
	If _nPeso > 9
		_nPeso := 2
	EndIf
Next _nJ
_nResto := (_nCnt%11)
If _nResto == 0 .or. _nResto==1
	_nDig := '0'
ElseIf _nResto == 10
	_nDig := '1'
Else
	_nResto := 11 - _nResto
	_nDig := Str(_nResto,1)
EndIf

Return(_nDig)

Static Function _fDigVer2(_cCampo2,_cBanco) //Calculo do 2ฐ Digito Verificador

Local _nVez,_nVez1,_nFator,_nPeso,_nReturn,_nResult,_cResult
If _cBanco == "208" 
	_nFator := 0
	_nPeso := 2
	_nReturn := 0
	_cCampo := _cCampo2
	For _nVez := Len(_cCampo) to 1 Step -1
		_nResult := Val(Substr(_cCampo,_nVez,1)) * _nPeso
		_cResult := Strzero(_nResult,2)
		_nFator += Val(Substr(_cResult,1,1))
		_nFator += Val(Substr(_cResult,2,1))
		_nPeso := If(_nPeso == 2,1,2)
	Next
	_nReturn := Mod(_nFator,10)
	If _nReturn > 0
		_nReturn := 10 - _nReturn
	Else
		_nReturn := 0
	EndIf
EndIf

Return Str(_nReturn,1)

Static Function _fDigVer3(_ccampo3,_cBanco) // Calculo do 3ฐ Digito Verificador

Local _nVez,_nVez1,_nFator,_nPeso,_nReturn,_nResult,_cResult
If _cBanco == "208" 
	_nFator := 0
	_nPeso := 2
	_nReturn := 0
	_cCampo := _ccampo3
	For _nVez:=Len(_cCampo) to 1 Step -1
		_nResult := Val(Substr(_cCampo,_nVez,1)) * _nPeso
		_cResult := Strzero(_nResult,2)
		_nFator += Val(Substr(_cResult,1,1))
		_nFator += Val(Substr(_cResult,2,1))
		_nPeso := If(_nPeso == 2,1,2)
	Next
	_nReturn := Mod(_nFator,10)
	If _nReturn > 0
		_nReturn := 10 - _nReturn
	EndIf
EndIf

Return Str(_nReturn,1)
