#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "MSOLE.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE ENTER Chr(13) + Chr(10)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณPROCESS3  บAutor  ณ Eduardo Augusto    บ Data ณ  25/03/2015 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo para mostrar o processamento da tela de gera็ใo de  บฑฑ
ฑฑบ          ณ boletos.                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Replas                                                     บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function Process3(aVetor,_cBanco,_cAgencia,_cConta,_cSubcta,_Tipo,_EmisIni,_EmisFim,_cTitulo)

Private oObj
Default  _cBanco		:= ""
Default  _cAgencia		:= ""
Default  _cConta		:= ""
Default  _cSubcta		:= ""
Default  _Tipo			:= ""
Default  _EmisIni		:= CtoD("  /  /  ")
Default  _EmisFim		:= CtoD("  /  /  ")
Default  _cTitulo		:= ""
oObj := MsNewProcess():New({|lEnd| BolItSaf(aVetor,_cBanco,_cAgencia,_cConta,_cSubcta,_Tipo,_EmisIni,_EmisFim,_cTitulo) },"Processando","Gerando Boletos...",.T.)	//Processamento da gera็ใo de boletos
oObj:Activate()	
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบ Programa      ณ BolItSaf                         บ Data ณ 19/08/2014  บฑฑ
ฑฑฬอออออออออออออออุออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricao     ณ Programa para Geracao de Boleto Grafico Safra / Itau  บฑฑ
ฑฑบ				  ณ	utilizando o Objeto FWMSPTRINTER.					  บฑฑ
ฑฑฬอออออออออออออออุออออออออออออออออออออออหอออออออออัออออออออออออออออออออออนฑฑ
ฑฑบ Desenvolvedor ณ Eduardo Augusto      บ Empresa ณ Totvs Serra do Mar   บฑฑ
ฑฑฬอออออออออออออออุออออออออออออหออออออออัสออออออหออฯออออออออออออออออออออออนฑฑ
ฑฑบ Linguagem     ณ Advpl      บ Versao ณ 11    บ Sistema ณ Microsiga     บฑฑ
ฑฑฬอออออออออออออออุออออออออออออสออออออออฯอออออออสอออออออออออออออออออออออออนฑฑ
ฑฑบ Modulo(s)     ณ SIGAFIN                                               บฑฑ
ฑฑฬอออออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Tabela(s)     ณ SM0 / SE1 / SEE / SA6                                 บฑฑ
ฑฑฬอออออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Observacao    ณ  Alterado Dia 21/11/2016                              บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function BolItSaf(aVetor,_cBanco,_cAgencia,_cConta,_cSubcta,_Tipo,_EmisIni,_EmisFim,_cTitulo)

Local cPath     := GetSrvProfString("StartPath","")
Local aEmail    := {}
Local aError    := {}
Local nCont     := 0
Local nQtd		:= 0
Local i
Local lRet		:=	.T.

Local cFileName := ''
Local nL := 0

Private oPrint   := Nil
Private oFont18N,oFont18,oFont16N,oFont16,oFont14N,oFont12N,oFont10N,oFont14,oFont12,oFont10,oFont08N
Private _limpr	 := .T.
Private oFontTit	:= oFont08N
Private lAdjustToLegacy := .F.
Private lDisableSetup   := .T.
Private _aBoletos  := {}
Private _cBcoAnt	:= ""	
Default  _cBanco	:= ""
Default  _cAgencia	:= ""
Default  _cConta	:= ""
Default  _cSubcta	:= ""
Default  _Tipo		:= ""
Default  _EmisIni	:= CtoD("  /  /  ")
Default  _EmisFim	:= CtoD("  /  /  ")
Default  _cTitulo	:= ""
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
If !ExistDir("C:\Boleto422\")
	MontaDir("C:\Boleto422\")
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
		oObj:IncRegua2("Gerando o boleto... Titulo: " + aVetor[i,3] + " " + aVetor[i,4])
		nCont++
		//IncProc("Processando...: " + aVetor[i,3])
		DbSelectArea("SE1")
		SE1->(DbSetOrder(1))
		SE1->(DbSeek(aVetor[i,19] + aVetor[i,2] + aVetor[i,3] + aVetor[i,4] + aVetor[i,12]))
		If AllTrim(_cBanco) == "341"
			_cBcoAnt	:= "341"
			_cBanco		:= "422"
			_cAgencia	:= Mv_Par02
			_cConta		:= Mv_Par03
		EndIf
		
		DbSelectArea("SEE")
		SEE->(DbSetOrder(1))	// EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA
		If SEE->(DbSeek(xFilial("SEE") + _cBanco + _cAgencia + _cConta + _cSubcta ))
			_cDvAge		:= SEE->EE_DVAGE
			_cDvCta		:= SEE->EE_DVCTA
			_cCart		:= SEE->EE_CODCART
			_nxJuros	:= SEE->EE_XJUROS
			_nxMulta	:= SEE->EE_XMULTA
			_cProtesto	:= SEE->EE_DIASPRT
			_cCodEmp	:= SEE->EE_CODEMP
			_cAgeOfi	:= SEE->EE_XAGECOR
			_cCtaOfi	:= SEE->EE_XCONCOR
			_cDvCtaOfi	:= SEE->EE_XDVCTCO
	    EndIf
		aAdd(_aBoletos,{SE1->(Recno()), SE1->E1_NUM, SE1->E1_TIPO, SC5->(Recno()), SC5->C5_NUM, "",'',Ctod(''),''})
		If AllTrim(_cBanco) == "422"
			_cBcoAnt	:= "422"
			//_cBanco		:= "341"
			_cAgencia	:= _cAgeOfi
			_cConta		:= _cCtaOfi
			_cDvCta		:= _cDvCtaOfi
		EndIf
		lRet	:=	CalcItSf(_aBoletos,_cBanco,_cAgencia,_cConta,_cSubcta,_Tipo,_EmisIni,_EmisFim,_cTitulo)
		// Em caso de nosso numero nใo preenchido aborta impressใo 
		If !lRet
			Return
		EndIf	
		_cArquivo := AllTrim(SE1->E1_FILIAL) + "_" + AllTrim(SE1->E1_NUM) + "_" + Alltrim(SE1->E1_PARCELA) + "_341" + ".pdf"
		cFileName := "C:\Boleto422\" + _cArquivo
		// Impressao
		oPrint := FWMSPrinter():New(_cArquivo, IMP_PDF, lAdjustToLegacy,, lDisableSetup,,,,,,,.F.,)// Ordem obrigแtoria de configura็ใo do relat๓rio
		oPrint:SetResolution(72)			// Default
		oPrint:SetPortrait() 				// SetLandscape() ou SetPortrait()
		oPrint:SetPaperSize(9)				// A4 210mm x 297mm  620 x 876
		oPrint:SetMargin(10,10,10,10)		// < nLeft>, < nTop>, < nRight>, < nBottom>
		oPrint:cPathPDF := "C:\Boleto422\"
		//oPrint:SetViewPdf(_limpr)
		oPrint:StartPage()   	// Inicia uma nova pแgina
		dbSelectArea("SA1")
		SA1->(DbSetOrder(1))
		SA1->(DbSeek(xFilial("SA1") + SE1->(E1_CLIENTE + E1_LOJA ),.F.))
		
		nL := Len( _aBoletos )
		_aBoletos[ nL, 7 ] := RTrim(SA1->A1_EMAIL)
		_aBoletos[ nL, 8 ] := SE1->E1_VENCTO
		_aBoletos[ nL, 9 ] := cFileName
		
		//	Montagem do Box + Dados
		// < nRow>, < nCol>, < nBottom>, < nRight>, [ cPixel]
		// 1ฐ Parte
		_cBcoLogo	:= ""
		_cDigBanco	:= ""
		If _cBanco $ "341/422"
			aBcos := {{"341","7","Logo341.jpg"}}
		EndIf
		_lContinua := .T.
		_cBanco		:= aBcos[1][1]
		_cDigBanco	:= aBcos[1][2]
		_cBcoLogo	:= aBcos[1][3]
		If _cBanco $ "341/422"
			oPrint:Say (0036, 0028,"Banco Ita๚ S/A",oFont10N )
		EndIf
		If _cBanco $ "341/422"
			oPrint:Say(0036,0110, "|" + _cBanco + "-" + _cDigBanco + "|" ,oFont18N,100)	// C๓digo do Banco + Dํgito
		EndIf
		cCgcSM0 := SM0->M0_CGC
		oPrint:Say (0036, 0448,"Comprovante de Entrega",oFont12N )	// Comprovante de Entrega
		BuzzBox  (0040,0025,0065,0320)	// Box Beneficiแrio + Cnpj
		oPrint:Say (0046, 0026,"Beneficiแrio",oFont06N )
		oPrint:Say (0056, 0026,"BANCO SAFRA S/A" + " / " + Alltrim(SM0->M0_NOMECOM),oFont05 )
		BuzzBox  (0040,0320,0065,0410)	// Box Agencia / Codigo do Cedente
		oPrint:Say (0046, 0321,"Ag๊ncia/C๓digo do Beneficiแrio",oFont06N )
		If _cBanco == "341"
			oPrint:Say (0056, 0331,Substr(Alltrim(_cAgencia),1,4) + "/" + Substr(Alltrim(_cConta),1,5) + "-" + Alltrim(_cDvCta),oFont06,100)
		ElseIf _cBanco == "422"
			oPrint:Say (0056, 0331,Substr(Alltrim(_cAgeOfi),1,4) + "/" + Substr(Alltrim(_cCtaOfi),1,5) + "-" + Alltrim(_cDvCtaOfi),oFont06,100)
		EndIf
		BuzzBox  (0040,0410,0065,0480)	// Nฐ do Documento
		oPrint:Say (0046, 0411,"Nฐ do Documento",oFont06N )
		oPrint:Say (0056, 0411,SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA,oFont06 )
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
		oPrint:Say (0081, 0026,Upper(SA1->A1_NOME),oFont06 )
		BuzzBox  (0065,0250,0090,0350)	// Box do Vencimento
		oPrint:Say (0071, 0251,"Vencimento",oFont06N )
		oPrint:Say (0081, 0301,Substr( DtoS(SE1->E1_VENCREA),7,2 ) + "/" + Substr( DtoS(SE1->E1_VENCREA),5,2 ) + "/" + Substr( DtoS(SE1->E1_VENCREA),1,4 ),oFont06 )
		BuzzBox  (0065,0350,0090,0480)	// Box do Valor do Documento
		oPrint:Say (0071, 0351,"Valor do Documento",oFont06N )
		aValImps:= RetImp()//nValor,nValIR,nValCF,nValPI,nValCS,nValINS,nValISS
		oPrint:Say (0081, 0401,AllTrim(Transform(Iif(SE1->E1_PREFIXO <> "RPS",SE1->E1_SALDO + SE1->E1_ACRESC,(SE1->E1_SALDO + SE1->E1_ACRESC)- (aValImps[5] + aValImps[3] + aValImps[4] + aValImps[7] + aValImps[2] + aValImps[6])),"@E 999,999,999.99")),oFont06 )		
		BuzzBox  (0090,0025,0140,0250)	// Box Recebi(emos) o Bloqueto / Titulo com as caracteristicas acima
		oPrint:Say (0107, 0026,"Box Recebi(emos) o Bloqueto / Titulo",oFont08N )
		oPrint:Say (0117, 0026,"com as caracteristicas acima",oFont08N )
		BuzzBox  (0090,0250,0115,0330)	// Box de Data
		oPrint:Say (0096, 0251,"Data",oFont06N )
		BuzzBox  (0090,0330,0115,0480)	// Box de Assinatura
		oPrint:Say (0096, 0331,"Assinatura",oFont06N )
		BuzzBox  (0115,0250,0140,0330)	// Box de Data
		oPrint:Say (0121, 0251,"Data",oFont06N )
		BuzzBox  (0115,0330,0140,0480)	// Box de Entregador
		oPrint:Say (0121, 0331,"Entregador",oFont06N )
		// 2ฐ Parte
		If _cBanco $ "341/422"
			oPrint:Say (0176, 0028,"Banco Ita๚ S/A",oFont10N )
		EndIf
		If _cBanco $ "341/422"
			oPrint:Say(0176,0110, "|" + _cBanco + "-" + _cDigBanco + "|" ,oFont18N,100)	// C๓digo do Banco + Dํgito
		EndIf
		oPrint:Say (0176, 0470,"Recibo do Pagador",oFont12N )	// Recibo do Pagador
		BuzzBox  (0180,0025,0205,0425)	// Local de Pagamento
		oPrint:Say (0186, 0026,"Local de Pagamento",oFont06N )
		If _cBanco $ "341/422"
			oPrint:Say  (0195, 0096,"ATษ O VENCIMENTO PAGมVEL EM QUALQUER BANCO",oFont06N )
		EndIf
		BuzzBox  (0180,0425,0205,0560)	// Vencimento
		oPrint:Say (0186, 0426,"Vencimento",oFont06N )
		oPrint:Say (0196, 0476,Substr( DtoS(SE1->E1_VENCREA),7,2 ) + "/" + Substr( DtoS(SE1->E1_VENCREA),5,2 ) + "/" + Substr( DtoS(SE1->E1_VENCREA),1,4 ),oFont06 )
		BuzzBox  (0205,0025,0230,0425)	// Beneficiario
		oPrint:Say (0211, 0026,"Beneficiแrio",oFont06N )
		oPrint:Say (0221, 0026,"BANCO SAFRA S/A" + " / " + Alltrim(SM0->M0_NOMECOM),oFont06 )
		BuzzBox  (0205,0425,0230,0560)	// Agencia 	/ Codigo do Cedente
		oPrint:Say (0211, 0426,"Ag๊ncia/C๓digo de Beneficiแrio",oFont06N )
		If _cBanco == "341"
			oPrint:Say (0221, 0436,Substr(Alltrim(_cAgencia),1,4) + "/" + Substr(Alltrim(_cConta),1,5) + "-" + Alltrim(_cDvCta),oFont06,100)
		ElseIf _cBanco == "422"
			oPrint:Say (0221, 0436,Substr(Alltrim(_cAgeOfi),1,4) + "/" + Substr(Alltrim(_cCtaOfi),1,5) + "-" + Alltrim(_cDvCtaOfi),oFont06,100)
		EndIf
		BuzzBox  (0230,0025,0255,0100)	// Data do Documento
		oPrint:Say (0236, 0026,"Data do Documento",oFont06N )
		oPrint:Say (0246, 0056,Substr( DtoS(SE1->E1_EMISSAO),7,2 ) + "/" + Substr( DtoS(SE1->E1_EMISSAO),5,2 ) + "/" + Substr( DtoS(SE1->E1_EMISSAO),1,4 ),oFont06 )
		BuzzBox  (0230,0100,0255,0225)	// Nro. Documento + Parcela
		oPrint:Say (0236, 0101,"Nฐ do Documento",oFont06N )
		oPrint:Say (0246, 0111,SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA,oFont06 )
		BuzzBox  (0230,0225,0255,0275)	// Especie Doc.
		oPrint:Say (0236, 0226,"Especie Doc.",oFont06N )
		If _cBanco == "341"
			oPrint:Say (0246, 0246,"DM",oFont06 )
		EndIf
		BuzzBox  (0230,0275,0255,0325)	// Aceite
		oPrint:Say (0236, 0276,"Aceite",oFont06N )
		oPrint:Say (0246, 0306,"N",oFont06 )
		BuzzBox  (0230,0325,0255,0425)	// Data do Processamento
		oPrint:Say (0236, 0326,"Data do Processamento",oFont06N )
		oPrint:Say (0246, 0356,Substr( DtoS(SE1->E1_EMISSAO),7,2 ) + "/" + Substr( DtoS(SE1->E1_EMISSAO),5,2 ) + "/" + Substr( DtoS(SE1->E1_EMISSAO),1,4 ),oFont06 )
		BuzzBox  (0230,0425,0255,0560)	// Nosso Numero
		oPrint:Say (0236, 0426,"Nosso Numero",oFont06N )
		If _cBanco $ "341/422"
			oPrint:Say (0246, 0476,"109" + "/" + Substr(SE1->E1_NUMBCO,1,Len(Alltrim(SE1->E1_NUMBCO))-1) + "-" + Right(AllTrim(SE1->E1_NUMBCO),1),oFont06 )
		EndIf
		BuzzBox  (0255,0025,0280,0100)	// Uso do Banco
		oPrint:Say (0261, 0026,"Uso do Banco",oFont06N )
		BuzzBox  (0255,0100,0280,0165)	// Carteira
		oPrint:Say (0261, 0101,"Carteira",oFont06N )
		If _cBanco $ "341/422"
			oPrint:Say (0271, 0131,_cCart,oFont06 )
		EndIf
		BuzzBox  (0255,0165,0280,0225)	// Especie
		oPrint:Say (0261, 0166,"Especie",oFont06N )
		If _cBanco $ "341/422"
			oPrint:Say (0271, 0186,"R$",oFont06N )
		EndIf
		BuzzBox  (0255,0225,0280,0325)	// Quantidade
		oPrint:Say (0261, 0226,"Quantidade",oFont06N )
		BuzzBox  (0255,0325,0280,0425)	// Valor
		oPrint:Say (0261, 0326,"Valor",oFont06N )
		BuzzBox  (0255,0425,0280,0560)	// Valor do Documento
		oPrint:Say (0261, 0426,"Valor do Documento",oFont06N )
		oPrint:Say (0271, 0476,AllTrim(Transform(IIf(SE1->E1_PREFIXO <> "RPS",SE1->E1_SALDO + SE1->E1_ACRESC,(SE1->E1_SALDO + SE1->E1_ACRESC) - (aValImps[5] + aValImps[3] + aValImps[4] + aValImps[7] + aValImps[2] + aValImps[6])),"@E 999,999,999.99")),oFont06N )
		BuzzBox  (0280,0025,0380,0425)	// Instru็๕es (Todas as Informa็๕es deste Bloqueto sใo de Exclusiva Responsabilidade do Cedente)
		oPrint:Say  (0286, 0026,"Instru็๕es (Todas as Informa็๕es deste Bloqueto sใo de Exclusiva Responsabilidade do Sacador/Avalista)",oFont06N )
		oPrint:Say  (0306, 0026,"ESTE BOLETO REPRESENTA DUPLICATA CEDIDA FIDUCIARIAMENTE AO BANCO SAFRA S/A, FICANDO VEDADO O PAGAMENTO DE QUALQUER ",oFont06N )
		oPrint:Say  (0316, 0026,"OUTRA FORMA QUE NรO ATRAVษS DO PRESENTE BOLETO.",oFont06N )
		oPrint:Say  (0336,0026,"Ap๓s vencimento cobrar mora de R$ ..... " + Alltrim(Transform(((Iif(SE1->E1_PREFIXO<>"RPS",SE1->E1_SALDO,SE1->E1_SALDO - (aValImps[5] + aValImps[3] + aValImps[4] + aValImps[7] + aValImps[2] + aValImps[6]))* _nxJuros)/100)/30,"@E 99,999,999.99"))+ " ao dia", oFont08,100)
		//oPrint:Say  (0326,0026,"Multa por atraso de " + Alltrim(Transform(_nxMulta,"@E 99,999,999.99")) + " % ao m๊s.", oFont08,100)
		If !Empty(SE1->E1_DECRESC)
			oPrint:Say  (0346,0026,"Conceder Desconto de R$ ..... " + AllTrim(Transform((SE1->E1_DECRESC),"@E 99,999,999.99")), oFont08,100)
		EndIf
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
		oPrint:Say  (0396,0106,Upper(SA1->A1_NOME),oFont06 ,100)
		oPrint:Say  (0406,0106,SA1->(If(Empty(A1_ENDCOB),A1_END,A1_ENDCOB) + " " + If(Empty(SA1->A1_BAIRROC),SA1->A1_BAIRRO,SA1->A1_BAIRROC)),oFont08 ,100)
		oPrint:Say  (0416,0106,SA1->(If(Empty(SA1->A1_CEPC),SA1->A1_CEP,SA1->A1_CEPC) + " " + If(Empty(SA1->A1_MUNC),SA1->A1_MUN,SA1->A1_MUNC) + " " + If(Empty(SA1->A1_ESTC),SA1->A1_EST,SA1->A1_ESTC)),oFont08 ,100)
		oPrint:Say  (0426,0106,SA1->(Transform(Alltrim(SA1->A1_CGC),PesqPict("SA1","A1_CGC")) + "               " + A1_INSCR),oFont08 ,100)
		oPrint:Say (0448, 0026,"Sacador Avalista ",oFont08N )
		oPrint:Say (0448, 0106,Alltrim(SM0->M0_NOMECOM) + Space(05) + Transform(cCgcSM0,"@R 99.999.999/9999-99"),oFont08N )
		oPrint:Say  (0455,0360,"Autentica็ใo Mecโnica",oFont06,100)
		// 3ฐ Parte
		If _cBanco $ "341/422"
			oPrint:Say (0496, 0028,"Banco Ita๚ S/A",oFont10N )
		EndIf
		_cCodBar := Alltrim(SE1->E1_CODBAR)
		_cNumBol := Alltrim(SE1->E1_CODDIG)
		If _cBanco $ "341/422"
			_cCodBarLit := Left(_cNumBol,5) + "." + Substr(_cNumBol,6,5) + "   " +;
			Substr(_cNumBol,11,5) + "." + Substr(_cNumBol,16,6) + "   " +;
			Substr(_cNumBol,22,5) + "." + Substr(_cNumBol,27,6) + "   " +;
			Substr(_cNumBol,33,1) + "   " + Substr(_cNumBol,34)
		EndIf
		oPrint:Say(0496,0200,_cCodBarLit,oFont14N,100)
		If _cBanco $ "341/422"
			oPrint:Say(0496,0110, "|" + _cBanco + "-" + _cDigBanco + "|" ,oFont18N,100)	// C๓digo do Banco + Dํgito
		EndIf
		BuzzBox  (0500,0025,0525,0425)	// Local de Pagamento
		oPrint:Say (0506, 0026,"Local de Pagamento",oFont06N )
		If _cBanco $ "341/422"
			oPrint:Say  (0511, 0096,"ATษ O VENCIMENTO PAGมVEL EM QUALQUER BANCO",oFont06N )
		EndIf
		BuzzBox  (0500,0425,0525,0560)	// Vencimento
		oPrint:Say (0506, 0426,"Vencimento",oFont06N )
		oPrint:Say (0516, 0476,Substr( DtoS(SE1->E1_VENCREA),7,2 ) + "/" + Substr( DtoS(SE1->E1_VENCREA),5,2 ) + "/" + Substr( DtoS(SE1->E1_VENCREA),1,4 ),oFont06 )
		BuzzBox  (0525,0025,0550,0425)	// Beneficiario
		oPrint:Say (0531, 0026,"Beneficiแrio",oFont06N )
		oPrint:Say (0541, 0026,"BANCO SAFRA S/A" + " / " + Alltrim(SM0->M0_NOMECOM),oFont06 )
		BuzzBox  (0525,0425,0550,0560)	// Agencia / Codigo do Cedente
		oPrint:Say (0531, 0426,"Ag๊ncia/C๓digo do Beneficiแrio",oFont06N )
		If _cBanco == "341"
			oPrint:Say (0541, 0436,Substr(Alltrim(_cAgencia),1,4) + "/" + Substr(Alltrim(_cConta),1,5) + "-" + Alltrim(_cDvCta),oFont06,100)
		ElseIf _cBanco == "422"
			oPrint:Say (0541, 0436,Substr(Alltrim(_cAgeOfi),1,4) + "/" + Substr(Alltrim(_cCtaOfi),1,5) + "-" + Alltrim(_cDvCtaOfi),oFont06,100)
		EndIf
		BuzzBox  (0550,0025,0575,0100)	// Data do Documento
		oPrint:Say (0556, 0026,"Data do Documento",oFont06N )
		oPrint:Say (0566, 0046,Substr( DtoS(SE1->E1_EMISSAO),7,2 ) + "/" + Substr( DtoS(SE1->E1_EMISSAO),5,2 ) + "/" + Substr( DtoS(SE1->E1_EMISSAO),1,4 ),oFont06 )
		BuzzBox  (0550,0100,0575,0225)	// Nro. Documento + Parcela
		oPrint:Say (0556, 0101,"Nฐ do Documento",oFont06N )
		oPrint:Say (0566, 0111,SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA,oFont06 )
		BuzzBox  (0550,0225,0575,0275)	// Especie Doc.
		oPrint:Say (0556, 0226,"Especie Doc.",oFont06N )
		If _cBanco $ "341/422"
			oPrint:Say (0566, 0246,"DM",oFont06 )
		EndIf
		BuzzBox  (0550,0275,0575,0325)	// Aceite
		oPrint:Say (0556, 0276,"Aceite",oFont06N )
		oPrint:Say (0566, 0296,"N",oFont06 )
		BuzzBox  (0550,0325,0575,0425)	// Data do Processamento
		oPrint:Say (0556, 0326,"Data do Processamento",oFont06N )
		oPrint:Say (0566, 0356,Substr( DtoS(SE1->E1_EMISSAO),7,2 ) + "/" + Substr( DtoS(SE1->E1_EMISSAO),5,2 ) + "/" + Substr( DtoS(SE1->E1_EMISSAO),1,4 ),oFont06 )
		BuzzBox  (0550,0425,0575,0560)	// Nosso Numero
		oPrint:Say (0556, 0426,"Nosso Numero",oFont06N )
		If _cBanco $ "341/422"
			oPrint:Say (0566, 0476,"109" + "/" + Substr(SE1->E1_NUMBCO,1,Len(Alltrim(SE1->E1_NUMBCO))-1) + "-" + Right(AllTrim(SE1->E1_NUMBCO),1),oFont06 )
		EndIf
		BuzzBox  (0575,0025,0600,0100)	// Uso do Banco
		oPrint:Say (0581, 0026,"Uso do Banco",oFont06N )
		BuzzBox  (0575,0100,0600,0165)	// Carteira
		oPrint:Say (0581, 0101,"Carteira",oFont06N )
		If _cBanco $ "341/422"
			oPrint:Say (0591, 0131,_cCart,oFont06 )
		EndIf
		BuzzBox  (0575,0165,0600,0225)	// Especie
		oPrint:Say (0581, 0166,"Especie",oFont06N )
		If _cBanco $ "341/422"
			oPrint:Say (0591, 0186,"R$",oFont06N )
		EndIf
		BuzzBox  (0575,0225,0600,0325)	// Quantidade
		oPrint:Say (0581, 0226,"Quantidade",oFont06N )
		BuzzBox  (0575,0325,0600,0425)	// Valor
		oPrint:Say (0581, 0326,"Valor",oFont06N )
		BuzzBox  (0575,0425,0600,0560)	// Valor do Documento
		oPrint:Say (0581, 0426,"Valor do Documento",oFont06N )
		oPrint:Say (0591, 0476,AllTrim(Transform(IIf(SE1->E1_PREFIXO <> "RPS",SE1->E1_SALDO + SE1->E1_ACRESC,(SE1->E1_SALDO + SE1->E1_ACRESC)- (aValImps[5] + aValImps[3] + aValImps[4] + aValImps[7] + aValImps[2] + aValImps[6])),"@E 999,999,999.99")),oFont06N )
		BuzzBox  (0600,0025,0700,0425)	// Instru็๕es (Todas as Informa็๕es deste Bloqueto sใo de Exclusiva Responsabilidade do Cedente)
		oPrint:Say  (0606, 0026,"Instru็๕es (Todas as Informa็๕es deste Bloqueto sใo de Exclusiva Responsabilidade do Sacador/Avalista)",oFont06N )
		oPrint:Say  (0626, 0026,"ESTE BOLETO REPRESENTA DUPLICATA CEDIDA FIDUCIARIAMENTE AO BANCO SAFRA S/A, FICANDO VEDADO O PAGAMENTO DE QUALQUER ",oFont06N )
		oPrint:Say  (0636, 0026,"OUTRA FORMA QUE NรO ATRAVษS DO PRESENTE BOLETO.",oFont06N )
		oPrint:Say  (0656,0026,"Ap๓s vencimento cobrar mora de R$ ..... " + Alltrim(Transform(((Iif(SE1->E1_PREFIXO <> "RPS",SE1->E1_SALDO,SE1->E1_SALDO - (aValImps[5] + aValImps[3] + aValImps[4] + aValImps[7] + aValImps[2] + aValImps[6]))* _nxJuros)/100)/30,"@E 99,999,999.99"))+ " ao dia", oFont08,100)
		//oPrint:Say  (0636,0026,"Multa por atraso de " + Alltrim(Transform(_nxMulta,"@E 99,999,999.99")) + " % ao m๊s.", oFont08,100)
		If !Empty(SE1->E1_DECRESC)
			oPrint:Say  (0666,0026,"Conceder Desconto de R$ ..... " + AllTrim(Transform((SE1->E1_DECRESC),"@E 99,999,999.99")), oFont08,100)
		EndIf
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
		oPrint:Say(0768, 0026,"Sacador Avalista",oFont06N )
		oPrint:Say (0768, 0106,Alltrim(SM0->M0_NOMECOM) + Space(05) + Transform(cCgcSM0,"@R 99.999.999/9999-99"),oFont08 )
		oPrint:Say(0775,0350,"Autentica็ใo Mecโnica - Ficha de Compensa็ใo",oFont06,100)
		oPrint:FWMSBAR("INT25",66.2,2.0,_cCodBar,oPrint,.F.,,,,1.0,,,,.F.)  //28.0
		oPrint:EndPage()
		oPrint:Print()
		oObj:IncRegua2("Gerando os Boletos dos Titulos..." + Alltrim(SE1->E1_NUM) + " " + Alltrim(SE1->E1_PARCELA) )
	EndIf
Next

//--> Gerar HTML, enviar e-mail e gravar arquivo de protocolo.
ProcessaDoc( {|| RPENVMAI( _aBoletos ) }, 'Enviar boleto por e-mail' ,'Processando, aguarde...' )

MsgInfo("Foram Salvos " + AllTrim(Str(nCont)) + " Boletos no Diret๓rio C:\Boleto422\")
WinExec( "Explorer.exe C:\Boleto422"  )

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

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma ณ Tr4         บAutorณ Eduardo Augusto		         บ Data ณ 24/04/2013 บฑฑ
ฑฑฬอออออออออุอออออออออออออออออสอออออฯออออออออออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricaoณ Alinhar os Valores a Direta	                                         บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function Tr4(cValor)

Local cValor2 := AllTrim(cValor)
cValor2	:= Replicate(" ",20 - (Len(cValor2) * 2)) + cValor2
If Len(AllTrim(cValor2)) >= 8
	cValor2	:= " " + cValor2
EndIf

Return cValor2

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณRetImp   บAutor  ณEduardo Augusto      บ Data ณ  27/02/2015 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao criada para Reter os Impostos conforme os Valores   บฑฑ
ฑฑบ          ณ das Parcelas.                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Replas			                                          บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function RetImp()

Local nValor	:= 0
Local nValIR	:= 0
Local nValCF	:= 0
Local nValPI	:= 0
Local nValCS	:= 0
Local nValINS	:= 0
Local nValISS	:= 0  
Local cQuery	:= ""   
If Select("TRB") > 0
   DbSelectArea("TRB")
   DbCloseArea()
EndIf                  
cQuery := " SELECT E1_TIPO,E1_VALOR "
cQuery += " FROM " + RetSqlName("SE1")
cQuery += " WHERE E1_FILIAL		= '" + xfilial('SE1') + "' "  
cQuery += " 	AND E1_PREFIXO  = '" + SE1->E1_PREFIXO + "' "
cQuery += " 	AND E1_NUM      = '" + SE1->E1_NUM + "' "
cQuery += " 	AND E1_PARCELA  = '" + SE1->E1_PARCELA + "' "
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
ฑฑบPrograma  ณCalcItau  บ Autor ณ EduarDo Augusto    บ Data ณ  17/02/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Fonte p/ Tratamento Do Nosso Numero, Digitos VerIficaDores บฑฑ
ฑฑบ          ณ Montagem da Linha Digitavel e Codigo de Barras.            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes		                                              บฑฑ
ฑฑฬออออออออออุออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ Replas                                                     บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function CalcItSf(_aBoletos,_cBanco,_cAgencia,_cConta,_cSubcta,_Tipo,_EmisIni,_EmisFim,_cTitulo)

Local _aArea   	:= 	Getarea()
Local _aImpBol 	:= 	{}
Local _nxx		:=	0
Local lRet		:=	.T.
Default  _cBanco	:= ""
Default  _cAgencia	:= ""
Default  _cConta	:= ""
Default  _cSubcta	:= ""
Default  _Tipo		:= ""
Default  _EmisIni	:= CtoD("  /  /  ")
Default  _EmisFim	:= CtoD("  /  /  ")
Default  _cTitulo	:= ""
For _nXx := 1 To Len(_aBoletos)
	If Empty(_aBoletos[_nXx][6])
		SF2->(DbGoTo(_aBoletos[_nXx][1]))
		SC5->(DbGoTo(_aBoletos[_nXx][4]))
		lRet := CodBco422(_aBoletos[_nXx,2],_aBoletos[_nXx,3],_cBanco,_cAgencia,_cConta,_cSubcta,_Tipo,_EmisIni,_EmisFim,_cTitulo)
		If !lRet
			RestArea(_aArea)
			Return lRet
		EndIf
		_aBoletos[_nXx][6] := "Ok"
		aAdd(_aImpBol,{_aBoletos[_nXx,3],_aBoletos[_nXx,2]}) //Serie/Doc
	EndIf
Next _nXx
RestArea(_aArea)

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณCodBco341 บ Autor ณ EduarDo Augusto    บ Data ณ  17/02/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Fonte p/ Tratamento Do Nosso Numero, Digitos VerIficaDores บฑฑ
ฑฑบ          ณ Montagem da Linha Digitavel e Codigo de Barras.            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes		                                              บฑฑ
ฑฑฬออออออออออุออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ Replas                                                     บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function CodBco422(_cNumeIni,cInull,_cBanco,_cAgencia,_cConta,_cSubcta,_Tipo,_EmisIni,_EmisFim,_cTitulo)

Local _vAmbSa1		:= SA1->(GetArea())
Local _cNumBar		:= ""
Local _cNossoNum	:= ""
Local cQuery		:= ""
Local lRet			:=	.T.
private _cDigBar	:= ""
Private _cDigCor	:= ""
Private _nDigtc3	:= 0
Private _cDig1bar	:= 0
Default  _cBanco	:= ""
Default  _cAgencia	:= ""
Default  _cConta	:= ""
Default  _cSubcta	:= ""
Default  _Tipo		:= ""
Default  _EmisIni	:= CtoD("  /  /  ")
Default  _EmisFim	:= CtoD("  /  /  ")
Default  _cTitulo	:= ""
Default	cInull		:= ""
cSelect	:= " SELECT * " + ENTER
cFrom	:= " FROM " + RetSqlName("SEE") + " SEE " + ENTER
cWhere	:= " WHERE SEE.EE_FILIAL = '" +  xFilial("SEE") + "' " + ENTER
cWhere	+= " AND SEE.D_E_L_E_T_  = ' '" + ENTER
cWhere	+= " AND SEE.EE_CODIGO = '" + _cBanco + "' " + ENTER
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
	_cNossoNum	:= Nosso341(_cBanco,_cAgencia,_cConta,_cSubcta,_Tipo,_EmisIni,_EmisFim,_cTitulo)
EndIf

// Tratando em caso de nosso numero vir vazio
If Empty(_cNossoNum)
	MsgInfo("Nosso n๚mero nใo preenchido, verifique se a tabela de parametros para o banco informado esta preenchida (SEE).")
	lRet := .F.
	Return lRet
EndIf
aValImps := U_RetImp()//nValor,nValIR,nValCF,nValPI,nValCS,nValINS,nValISS
If _cBanco $ "341"
	_cNossoNum	:= Alltrim(_cNossoNum)
	_cNossoDig	:= Right(_cNossoNum,1)
	_cNossoNum	:= Left(_cNossoNum,Len(_cNossoNum)-1)
	_cDigBar	:= ""
	_cNumBar	:= _fNumBar(_cBanco,_cAgencia,_cConta,_cNossoNum,@_cDigBar,_cNossoDig)
	_cNumBol	:= _fNumBol(_cBanco,_cAgencia,_cConta,_cNossoNum,_cNumBar)
EndIf
If !Empty(_cNossoNum) .Or. !Empty(_cNumBar) .Or. !Empty(_cNumbol)
	If SE1->(Reclock(Alias(),.F.))
		If _cBanco == "341"
			SE1->E1_NUMBCO  :=_cNossoNum + _cNossoDig
		Else
			SE1->E1_NUMBCO  :=_cNossoNum + _cNossoDig
			If Empty(SE1->E1_NUMBCO)
				SE1->E1_NUMBCO  := _cNossoNum + _cNossoDig
			Else
				SE1->E1_NUMBCO  := SE1->E1_NUMBCO
			EndIf
		EndIf
		SE1->E1_CODBAR  := _cNumBar
		SE1->E1_CODDIG  := _cNumBol
		If Empty(SE1->E1_XNUMBCO) // Vazio
			SE1->E1_XNUMBCO := SE1->E1_NUMBCO + _cNossoDig
		Else // Ja gravado
			If Mv_Par05 == 2 .And. !Empty(SE1->E1_XNUMBCO)
				SE1->E1_NUMBCO := SE1->E1_XNUMBCO // Usa o original
			Else
				_cNossoNum := SE1->E1_XNUMBCO
			EndIf
		EndIf
		SE1->(MsUnLock())
	EndIf
EndIf
RetIndex("SA1")

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ_fNumBol  บAutor  ณEduardo Augusto     บ Data ณ  06/23/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Programa para Montagem da Linha Digitavel.				  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Replas                                                     บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function _fNumBol(_cBanco,_cAgencia,_cConta,_cNossoNum,_cNumBar)

Local _cNumBol,_cNossoNu1:=_cNossoNum,_nVez
Local w
Local nFatVenc
For _nVez:=1 To Len(_cNossoNum)
	If Substr(_cNossoNum,_nVez,1) == "0"
		_cNossoNu1	:=	Right(_cNossoNu1,Len(_cNossoNu1)-1)
	Else
		Exit
	EndIf
Next
Do Case
	Case _cBanco == "341" // Banco Itau
		_cCampo1 := "341" + "9" + "109" + Left(_cNossoNum,2)
		_cDig1	 := _fDigVer(_cCampo1,_cBanco)
		_cCampo2 := Substr(_cNossoNum,3) + _cNossoDig + Left(_cAgencia,3)
		_cDig2	 := _fDigVer(_cCampo2,_cBanco)
		_cCampo3 := Substr(_cAgencia,4,1) + Strzero(Val(Alltrim(_cConta)),5) + Alltrim(_cDvCta) + "000"
		_cDig3	 := _fDigVer(_cCampo3,_cBanco)
		_cCampo4 := _cDigBar
		//-- Novo calculo do Fator de Vencimento que passou a valer para boletos com vencimento ate 21/02/2025
		nFatVenc := SE1->E1_VENCTO - CToD("07/10/1997")
		If nFatVenc > 9999
			nFatVenc := nFatVenc - 9000
		EndIf
		_cCampo5 := Strzero(nFatVenc,4) + Strzero((IIf(SE1->E1_PREFIXO <> "RPS",SE1->E1_SALDO + SE1->E1_ACRESC,(SE1->E1_SALDO + SE1->E1_ACRESC) - (aValImps[5] + aValImps[3] + aValImps[4] + aValImps[7] + aValImps[2] + aValImps[6])))*100,10)
		_cNumBol := _cCampo1 + _cDig1 + _cCampo2 + _cDig2 + _cCampo3 + _cDig3 + _cCampo4 + _cCampo5
EndCase

Return _cNumBol

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ_fNumBar  บAutor  ณEduardo Augusto     บ Data ณ  06/23/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Programa para Montagem do C๓digo de Barras.				  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Replas                                                     บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function _fNumBar(_cBanco,_cAgencia,_cConta,_cNossoNum,_cDigBar,_cNossoDig)

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
	Case _cBanco == "341" // Banco Itau
		//-- Novo calculo do Fator de Vencimento que passou a valer para boletos com vencimento ate 21/02/2025
		nFatVenc := SE1->E1_VENCREA - CToD("07/10/1997")
		If nFatVenc > 9999
			nFatVenc := nFatVenc - 9000
		EndIf
		_cCampo1 := "341" + "9" + Strzero(nFatVenc,4) + Strzero((Iif(SE1->E1_PREFIXO <> "RPS",SE1->E1_SALDO + SE1->E1_ACRESC,(SE1->E1_SALDO + SE1->E1_ACRESC) - (aValImps[5] + aValImps[3] + aValImps[4] + aValImps[7] + aValImps[2] + aValImps[6])))*100,10) + "109" + _cNossoNum + _cNossoDig + Strzero(Val(Alltrim(_cAgencia)),4) + Strzero(Val(Alltrim(_cConta)),5) + Alltrim(_cDvCta) + "000"
		_cNumBar := Left(_cCampo1,4) + (_cDigBar:=_fDigBar(_cCampo1,_cBanco)) + Substr(_cCampo1,5)
EndCase

Return _cNumBar

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ_fDigVer  บAutor  ณEduardo Augusto     บ Data ณ  06/23/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Programa para calcular os Digitos Verificadores dos campos บฑฑ
ฑฑบ          ณ 1, 2 e 3.                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Replas                                                     บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function _fDigVer(_cCampo,_cBanco)

Local _nVez,_nVez1,_nFator,_nPeso,_nReturn,_nResult,_cResult
If _cBanco $ "341" // Banco Itau
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

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ_fDigBar  บAutor  ณEduardo Augusto     บ Data ณ  06/23/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Programa para calcular o Digito Verificador Centralizador. บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Replas                                                     บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function _fDigBar(_cCampo,_cBanco)

Local _nVez,_nPeso,_nFator,_nResto
Local w
If _cBanco $ "341" // Itau
	_nPeso	:= 2
	_nFator	:= 0
	_nResto	:= 0
	For _nVez := Len(_cCampo) to 1 Step -1
		_nFator += Val(Substr(_cCampo,_nVez,1)) * _nPeso
		_nPeso := If(_nPeso < 9,_nPeso+1,2)
	Next
	_nResto := Mod(_nFator,11)
	If _nResto == 0 .Or. _nResto == 1 .Or. _nResto == 10 .Or. _nResto == 11
		_nResto := 1
	Else
		_nResto := 11 - _nResto
	EndIf
EndIf
SEE->(DbCloseArea())

Return Str(_nResto,1)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณNosso341  บAutor  ณEduardo Augusto     บ Data ณ  06/23/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Programa para calcular o digito do Nosso Numero.			  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Replas                                                     บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function Nosso341(_cBanco,_cAgencia,_cConta,_cSubcta,_Tipo,_EmisIni,_EmisFim,_cTitulo)

Local _xDvcta     := ""
Local _xConta     := ""
Local _xAgencia   := ""
Local _xCart      := ""
Local _xNosso_num := ""
Local _xVariavel  := ""
Local _nPeso      := 2
Local _nResult    := 0
Local _cResult    := ""
Local _nFator     := 0
Local _nReturn    := 0
Local _nVez
Default  _cBanco	:= ""
Default  _cAgencia	:= ""
Default  _cConta	:= ""
Default  _cSubcta	:= ""
Default  _Tipo		:= ""
Default  _EmisIni	:= CtoD("  /  /  ")
Default  _EmisFim	:= CtoD("  /  /  ")
Default  _cTitulo	:= ""
If Empty(SE1->E1_NUMBCO)
	If AllTrim(_cBanco) <> "341"
		_cBcoAnt	:= "422"
		//_cBanco := "341"
		_cAgencia := _cAgeOfi
		_cConta := _cCtaOfi
		_cDvCta := _cDvCtaOfi
	EndIf
	
	_nReg := LOCALSEE(_cBanco,_cAgencia,_cConta,_cDvCta)
	DbSelectArea("SEE")
	DbGoTo(_nReg)
	If _nReg > 0
		RecLock("SEE",.F.)
			SEE->EE_FAXATU := Soma1(SEE->EE_FAXATU,8)
		MsUnlock()
		_xConta   	:= Alltrim(_cConta)
		_xAgencia 	:= Left(_cAgencia,4)
		_xCart    	:= "109"
		_xNosso_num := Right(SEE->EE_FAXATU,8)
		_xVariavel	:= _xAgencia + _xConta + _xCart + _xNosso_num
		For _nVez := Len(Alltrim(_xVariavel)) to 1 Step -1
			_nResult := Val(Substr(_xVariavel,_nVez,1)) * _nPeso
			_cResult := Strzero(_nResult,2)
			_nFator  += Val(Substr(_cResult,1,1))
			_nFator  += Val(Substr(_cResult,2,1))
			_nPeso   := If(_nPeso == 2,1,2)
		Next
		_nReturn := Mod(_nFator,10)
		If _nReturn > 0
			_nReturn := 10 - _nReturn
		EndIf
		_cRet := _xNosso_num + Str(_nReturn,1)
	Else
		Conout("Nใo existe configura็ใo para o banco informado SEE, favor preencher.")
		MsgInfo("Nใo existe configura็ใo para o banco informado SEE, favor preencher.")
	EndIf
Else
	_cRet := SE1->E1_NUMBCO
EndIf

Return(_cRet)

Static Function LOCALSEE(_cBanco,_cAgencia,_cConta,_cDvCta)
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local nReg 		:= 0
	
	If Select("TRBSEE") > 0
		TRBSEE->(DbCloseArea())
	EndIf
	
	cQuery := " SELECT R_E_C_N_O_ NREG FROM " + RetSqlName("SEE") + " SEE "	+ ENTER
	cQuery += " WHERE SEE.D_E_L_E_T_ = '' "									+ ENTER
	cQuery += " 	AND SEE.EE_FILIAL = '" + xFilial("SEE") + "' "			+ ENTER
	cQuery += " 	AND SEE.EE_XBCOCOR = '" + _cBanco + "' "				+ ENTER
	cQuery += " 	AND SEE.EE_XAGECOR = '" + _cAgencia + "' "				+ ENTER
	cQuery += " 	AND SEE.EE_XCONCOR = '" + _cConta + "' "				+ ENTER
	cQuery += " 	AND SEE.EE_XDVCTCO = '" + _cDvCta + "' "				+ ENTER
	
	TcQuery cQuery New Alias "TRBSEE"
	
	nReg := TRBSEE->NREG
	
	msgalert( cquery )

	If Select("TRBSEE") > 0
		TRBSEE->(DbCloseArea())
	EndIf
	
	RestArea(aArea)
Return nReg

/*/{Protheus.doc} RPENVMAI
//Rotina para gerar HTML, enviar e-mail com o boleto em anexo e gerar log de processamento.
@author rleg
@since 23/11/2019
@version 1.0
@return ${return}, ${return_description}
@param aBoletos, array, descricao
@type function
/*/
STATIC STARTJOB := Select( 'SX6' ) <= 0
STATIC USERCODE := Iif( STARTJOB, 'JOB', RetCodUsr() )
STATIC USERNAME := Iif( STARTJOB, 'JOB PROTHEUS', Upper( RTrim( UsrFullName( USERCODE ) ) ) )

Static Function RPENVMAI( aBoletos )
	Local cAssunto := ''
	Local cAttach := ''
	Local cB := ''
	Local cEMail := ''
	Local cFile := ''
	Local cFileHTML := ''
	Local cFileLOG  := ''
	Local cHTML := ''
	Local cLog := ''
	Local cNumBoleto := ''
	Local cProtocolo := ''
	Local cVencBoleto := ''
	Local nB := Len( aBoletos )
	Local nL := 0
	
	RegProcDoc( nB )
	
	cB := LTrim( Str( nB ) )
	
	For nL := 1 To nB
		IncProcDoc( 'Processando, ' + LTrim( Str( nL ) ) + '/' + cB + ' boletos...' )
		cAttach := aBoletos[ nL, 9 ]
		If File( cAttach )
			cEMail      := aBoletos[ nL, 7 ]
			cNumBoleto  := aBoletos[ nL, 2 ]
			cVencBoleto := Dtoc( aBoletos[ nL, 8 ] )
			cProtocolo  := CriaTrab( NIL , .F. )
			cAssunto    := '[REPLAS] Seu boleto Nบ ' + cNumBoleto
			cAttach     := aBoletos[ nL, 9 ]
			cFile       := SubStr( cAttach, 1, RAt( '.', cAttach )-1 )
			cFileHTML   := cFile + '.html'
			cFileLOG    := cFile + '.log'
			
			cHTML := '<html><head><title>Editor HTML Online</title></head><body><table align="center" border="0" cellpadding="0" cellspacing="1" style="width: 600px">'
			cHTML += '<tbody><tr><td><table align="center" border="0" cellpadding="0" cellspacing="1" style="width: 600px"><tbody><tr><td>'
			cHTML += '<img alt="" src="http://www.replas.com.br/templates/replas/images/replas-logo.png" style="width: 299px; height: 89px;" /></td></tr></tbody></table><hr />'
			cHTML += '<table border="0" cellpadding="0" cellspacing="1" style="width: 599px"><tbody><tr><td><p style="text-align: justify;">'
			cHTML += '<span style="color:#696969;"><span style="font-size:14px;"><span style="font-family:tahoma,geneva,sans-serif;">Prezado cliente,</span></span></span></p><p style="text-align: justify;">'
			cHTML += '<span style="color:#696969;"><span style="font-size:14px;"><span style="font-family:tahoma,geneva,sans-serif;">Para sua comodidade estamos disponibilizando seu boleto '+cNumBoleto+' no arquivo anexo com vencimento em '+cVencBoleto+'.</span></span></span></p><p style="text-align: justify;">'
			cHTML += '<span style="color:#696969;"><span style="font-size:14px;"><span style="font-family:tahoma,geneva,sans-serif;">Caso tenha alguma d&uacute;vida, estamos inteiramente a disposi&ccedil;&atilde;o para ajud&aacute;-lo.</span></span></span></p>'
			cHTML += '<table align="center" border="0" cellpadding="0" cellspacing="0" style="width: 599px"><tbody><tr><td style="width: 120px;">'
			cHTML += '<img alt="" src="http://www.replas.com.br/images/replas-mais-brasil.jpg" style="width: 115px; height: 48px;" /></td><td>'
			cHTML += '<span style="color:#696969;"><span style="font-family: tahoma, geneva, sans-serif;"><span style="font-size:16px;">REPLAS</span></span><br style="font-family: tahoma, geneva, sans-serif;" />'
			cHTML += '<span style="font-size:12px;"><span style="font-family: tahoma, geneva, sans-serif;">Fone: 11 2067-2222 | 3198-9230</span><br style="font-family: tahoma, geneva, sans-serif;" /><span style="font-family: tahoma, geneva, sans-serif;">contato@replas.com.br</span></span></span></td>'
			cHTML += '</tr><tr><td colspan="2" style="width: 120px;"><hr /><table align="center" border="0" cellpadding="0" cellspacing="0" style="width: 599px">'
			cHTML += '<tbody><tr><td style="width: 298px; text-align: left; vertical-align: middle; background-color: rgb(255, 255, 255);">'
			cHTML += '<span style="color: rgb(105, 105, 105); font-size: 10px;"><span style="font-family: tahoma, geneva, sans-serif;">A&nbsp;<strong>REPLAS</strong>&nbsp;garante sigilo dos seus dados.&nbsp;</span></span>'
			cHTML += '<span style="color: rgb(105, 105, 105); font-family: tahoma, geneva, sans-serif; font-size: 10px;">Caso haja d&uacute;vidas sobre a autenticidade desta mensagem, entre em contato conosco.&nbsp;Esta mensagem &eacute; eletr&ocirc;nica e confidencial. Sua utiliza&ccedil;&atilde;o, c&oacute;pia, distribui&ccedil;&atilde;o ou divulga&ccedil;&atilde;o s&atilde;o expressamente proibidas.&nbsp;Protocolo deste E-mail n&ordm; '+cProtocolo+'.</span></td>'
			cHTML += '<td style="width: 3px; text-align: left; vertical-align: middle;">&nbsp;</td><td style="text-align: left; width: 298px; vertical-align: middle; background-color: rgb(255, 255, 255);">'
			cHTML += '<div><div><span style="color: rgb(105, 105, 105);"><strong><span style="font-size: 11px;"><span style="font-family: tahoma, geneva, sans-serif;">Adobe Reader</span></span></strong></span></div>'
			cHTML += '<div><span style="color: rgb(105, 105, 105);"><span style="font-size: 10px;"><span style="font-family: tahoma, geneva, sans-serif;">Para visualizar sua boleto &eacute; preciso ter o programa de software Adobe Acrobat Reader instalado. Caso n&atilde;o tenha, acesse o site da Adobe e fa&ccedil;a o download gratuitamente.</span></span></span></div>'
			cHTML += '</div></td></tr></tbody></table><hr /><p>&nbsp;</p></td></tr></tbody></table></td></tr></tbody></table></td></tr></tbody></table><p>&nbsp;</p></body></html>'
			
			nHdl := FCreate( cFileHTML )
			FWrite( nHdl, cHTML + CRLF )
			FClose( nHdl )
			Sleep( 500 )

			cLog := 'Arquivo PDF.......... [' + cAttach + ']'
			cLog += 'Enviado para o e-mail [' + cEMail + ']'
			cLog += 'Data do envio........ [' + Dtoc( MsDate() ) + ']'
			cLog += 'Hora do envio........ [' + Time() + ']'
			cLog += 'HTML do e-mail....... [' + cFileHTML + ']'
			cLog += 'Usuแrio.............. [' + USERCODE + ' ' + USERNAME + ']'
			cLog += 'Situa็ใo............. ['
			
			If FSSendMail( cEMail, cAssunto, cHTML, cAttach )
				cLog += 'E-MAIL ENVIADO COM SUCESSO]'
			Else
				cLog += 'FALHOU O ENVIO DO E-MAIL (Verfique o e-mail do cliente e/ou a conexao com o servidor)]'
			Endif
			
			nHdl := FCreate( cFileLOG )
			FWrite( nHdl, cLog + CRLF )
			FClose( nHdl )
			Sleep( 500 )
		Endif
	Next nL
Return
