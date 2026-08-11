#Include "Protheus.ch"
#Include "TopConn.ch"
#Define Enter Chr(13) + Chr(10)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ TELABOL  ºAutor  ³Eduardo Augusto     º Data ³  26/09/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Fonte para Tela de Impressão de Boletos com filtros para   º±±
±±º          ³ Seleção dos titulos da Tabela SE1 (Contas a Receber).      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Replas							                        º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function TELABOL()
Local cTitulo	:= "SELEÇÃO DE BOLETOS"
Local oOk		:= LoadBitmap(GetResources(),"LBOK")
Local oNo		:= LoadBitmap(GetResources(),"LBNO")
Local cVar
Local oDlg
Local oChk
Local oLbx
Local lChk 		:= .F.
Local lMark 		:= .F.
Local aVetor 		:= {}

Local cMsg := ''

Private _cBanco		:= ""
Private _cAgencia	:= ""
Private _cConta		:= ""
Private _cSubcta	:= ""
Private _Tipo		:= ""
Private _EmisIni	:= CtoD("  /  /  ")
Private _EmisFim	:= CtoD("  /  /  ")
Private _cTitulo	:= ""
Private cQuery 		:= ""
Private cPerg 	:= "BOLETO"
//---> REMOVIDO compatibilização para versão 12.1.25.
//ValidPerg()

If !Pergunte(cPerg,.T.)	// Selecione o Banco
	Return
EndIf

_cBanco		:= Mv_Par01
_cAgencia		:= Mv_Par02
_cConta		:= Mv_Par03
_cSubcta		:= Mv_Par04
_Tipo		:= Mv_Par05
_EmisIni		:= Mv_Par06
_EmisFim		:= Mv_Par07
_cTitulo		:= Mv_Par08
_cBordero		:= Mv_Par09
If Select("TMP") > 0
	TMP->(DbCloseArea())
EndIf
If _cBanco == "001"
	LjMsgRun("Banco do Brasil não gera Boleto, somente os outos Bancos.",,{|| Sleep(3000) })
	Return
EndIf
cQuery := " SELECT E1_PORTADO, E1_AGEDEP, E1_CONTA, E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PEDIDO, "			+ Enter
cQuery += "        E1_PARCELA, E1_CLIENTE, E1_LOJA, E1_NOMCLI, E1_EMISSAO, E1_VALOR, "					+ Enter
cQuery += "        E1_VENCTO, E1_VENCREA, E1_TIPO, E1_PORTADO, E1_NUMBOR, E1_NUMBCO, E1_XNUMBCO FROM "	+ Enter
cQuery += RetSqlName("SE1")																	+ Enter
cQuery += " WHERE D_E_L_E_T_ = '' "															+ Enter
cQuery += " 	AND E1_FILIAL = '" + xFilial("SE1") + "' "									+ Enter
If !Empty(_cTitulo) 
	cQuery += " AND E1_NUM = '" + _cTitulo + "' "											+ Enter
Else
	cQuery += " AND E1_EMISSAO BETWEEN '" + DtoS(_EmisIni) + "' AND '" + DtoS(_EmisFim) + "' "		+ Enter
EndIf
cQuery += " AND E1_SALDO <> 0 "																+ Enter
cQuery += " AND E1_TIPO IN ('NF','BOL','FT','DP','ND') "										+ Enter
If Mv_Par05 == 1	// 1ª Via 
	cQuery += " AND E1_PORTADO = '" + _cBanco + "' "											+ Enter
	cQuery += " AND E1_AGEDEP = '" + _cAgencia + "' "											+ Enter
	cQuery += " AND E1_CONTA = '" + _cConta + "' "											+ Enter
	cQuery += " AND E1_NUMBCO = '' "														+ Enter
	cQuery += " AND E1_XNUMBCO = '' "														+ Enter
	//cQuery += " AND E1_NUMBOR = '' "														+ Enter
ElseIf Mv_Par05 == 2	// 2ª Via
	cQuery += " AND E1_PORTADO = '" + _cBanco + "' "											+ Enter
	cQuery += " AND E1_AGEDEP = '" + _cAgencia + "' "											+ Enter
	cQuery += " AND E1_CONTA = '" + _cConta + "' "											+ Enter
	cQuery += " AND E1_XNUMBCO <> '' "														+ Enter
	//cQuery += " AND E1_NUMBOR = '" + _cBordero + "' "											+ Enter
ElseIf Mv_Par05 == 3	// Outros
	cQuery += " AND E1_PORTADO = '' "														+ Enter
	cQuery += " AND E1_AGEDEP = '' "														+ Enter
	cQuery += " AND E1_CONTA = '' "															+ Enter
	cQuery += " AND E1_NUMBCO = '' "														+ Enter
	cQuery += " AND E1_XNUMBCO = '' "
	//cQuery += " AND E1_PREFIXO = 'FAT' "														+ Enter
EndIf
cQuery += " ORDER BY E1_NUM "																+ Enter																
cQuery := ChangeQuery(cQuery)
memowrite("cquery.sql",cquery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TMP', .F., .T.)
TcSetField("TMP","E1_EMISSAO","D")
TcSetField("TMP","E1_VENCTO" ,"D")
TcSetField("TMP","E1_VENCREA","D")
TcSetField("TMP","E1_VALOR"  ,"N",12,2)
// Posicionando no Pedido de Venda para verificar a Condição de Pagamento tendo que ser diferente de 001 a Vista
//cCondPag := Posicione("SC5",1,xFilial("SC5") + TMP->E1_PEDIDO, "C5_CONDPAG")
// Posiciono no Primeiro registro da Query
DbSelectArea("TMP")
DbGoTop()
While !TMP->(Eof())// .And. cCondPag <> "001"
	// Posicionando no Pedido de Venda para verificar a Condição de Pagamento tendo que ser diferente de 001 a Vista
	cCondPag := Posicione("SC5",1,xFilial("SC5") + TMP->E1_PEDIDO, "C5_CONDPAG")
	If cCondPag <> "001"	// So entra se a Condicao de Pagamento for diferente de a Vista.
		aAdd(aVetor, { lMark,;				// Marca e Desmarca
					 TMP->E1_PREFIXO,;		// Prefixo
					 TMP->E1_NUM,;		// Nº do Titulo
					 TMP->E1_PARCELA,;		// Parcela
					 TMP->E1_CLIENTE,;		// Código do Cliente
					 TMP->E1_LOJA,;		// Loja
					 TMP->E1_NOMCLI,;		// Nome do Cliente
					 TMP->E1_EMISSAO,;		// Data de Emissão
					 AllTrim(Transform(TMP->E1_VALOR,"@E 999,999,999.99")),;	// Valor R$
					 TMP->E1_VENCTO,;		// Vencimento
					 TMP->E1_VENCREA,;		// Vencimento Real
					 TMP->E1_TIPO,;		// Tipo
					 TMP->E1_PORTADO,;		// Portado
					 TMP->E1_AGEDEP,;		// Agência
					 TMP->E1_CONTA,;		// Conta
					 TMP->E1_NUMBOR,;		// Borderô
					 TMP->E1_NUMBCO,;		// Nosso Nº do Sistema
					 TMP->E1_XNUMBCO,;		// Nosso Nº Backup
					 TMP->E1_FILIAL } )	// Filial
		cCondPag := ""
	EndIf
	cCondPag := ""
	TMP->(DbSkip())
Enddo
DbSelectArea("TMP")
DbCloseArea()
If Len(aVetor) == 0
	MsgAlert("Não foi Selecionado nenhum Titulo para Impressão de Boleto",cTitulo)
	Return
EndIf
Define MsDialog oDlg Title cTitulo From 0,0 To 511,1292 Pixel
@010,010 ListBox oLbx Var cVar Fields Header " ", "Prefixo", "N° Titulo", "Parcela", "Cod. Cliente", "Loja", "Nome Cliente", "Data Emissão", "Valor R$", "Vencimento", "Vencimento Real", "Tipo", "Portador", "Agencia", "Conta", "Bordero", "Nosso N° Sistema", "Nosso N° Backup", "Filial" Size 630,230 Of oDlg Pixel On DblClick(aVetor[oLbx:nAt,1] := !aVetor[oLbx:nAt,1],oLbx:Refresh())
oLbx:SetArray(aVetor)
oLbx:bLine := {|| { Iif(aVetor[oLbx:nAt,1],oOk,oNo),;	// Marca e Desmarca
					 aVetor[oLbx:nAt,2],;			// Prefixo
					 aVetor[oLbx:nAt,3],;			// Nº do Titulo
					 aVetor[oLbx:nAt,4],;			// Parcela
					 aVetor[oLbx:nAt,5],;			// Cod. Cliente
					 aVetor[oLbx:nAt,6],;			// Loja
					 aVetor[oLbx:nAt,7],;			// Nome do Cliente	 
					 aVetor[oLbx:nAt,8],;			// Data de Emissão
					 aVetor[oLbx:nAt,9],;			// Valor R$
					 aVetor[oLbx:nAt,10],;			// Vencimento
					 aVetor[oLbx:nAt,11],;			// Vencimento Real
					 aVetor[oLbx:nAt,12],;			// Tipo
					 aVetor[oLbx:nAt,13],;			// Portador
					 aVetor[oLbx:nAt,14],;			// Agência
					 aVetor[oLbx:nAt,15],;			// Conta
					 aVetor[oLbx:nAt,16],;			// Borderô
					 aVetor[oLbx:nAt,17],;			// Nosso N° Sistema
					 aVetor[oLbx:nAt,18],;			// Nosso N° Backup
					 aVetor[oLbx:nAt,19]}}			// Filial
If oChk <> Nil
	@245,010 CHECKBOX oChk VAR lChk Prompt "Marca/Desmarca" Size 60,007 Pixel Of oDlg On Click(Iif(lChk,Marca(lChk,aVetor),Marca(lChk,aVetor)))
EndIf
@245,010 CHECKBOX oChk VAR lChk Prompt "Marca/Desmarca" SIZE 60,007 Pixel Of oDlg On Click(aEval(aVetor,{|x| x[1] := lChk}),oLbx:Refresh())
@243,130 BUTTON "Cancelar Boletos Total" Size 100, 011 Font oDlg:oFont Action {CanceTot(aVetor),oDlg:End()} Of oDlg Pixel
If _cBanco == "422"
	@243,480 BUTTON "Confirmar" Size 050, 011 Font oDlg:oFont Action {U_Process3(@aVetor,_cBanco,_cAgencia,_cConta,_cSubcta,_Tipo,_EmisIni,_EmisFim,_cTitulo),oDlg:End()} Of oDlg Pixel
//ElseIf _cBanco == "001"
//	@243,480 BUTTON "Confirmar" Size 050, 011 Font oDlg:oFont Action {U_Process4(@aVetor,_cBanco,_cAgencia,_cConta,_cSubcta,_Tipo,_EmisIni,_EmisFim,_cTitulo),oDlg:End()} Of oDlg Pixel
ElseIf _cBanco == "341"
	@243,480 BUTTON "Confirmar" Size 050, 011 Font oDlg:oFont Action {U_Process5(@aVetor,_cBanco,_cAgencia,_cConta,_cSubcta,_Tipo,_EmisIni,_EmisFim,_cTitulo),oDlg:End()} Of oDlg Pixel
ElseIf _cBanco == "033"
	@243,480 BUTTON "Confirmar" Size 050, 011 Font oDlg:oFont Action {U_Process6(@aVetor,_cBanco,_cAgencia,_cConta,_cSubcta,_Tipo,_EmisIni,_EmisFim,_cTitulo),oDlg:End()} Of oDlg Pixel
ElseIf _cBanco == "208"
	@243,480 BUTTON "Confirmar" Size 050, 011 Font oDlg:oFont Action {U_Process9(@aVetor,_cBanco,_cAgencia,_cConta,_cSubcta,_Tipo,_EmisIni,_EmisFim,_cTitulo),oDlg:End()} Of oDlg Pixel	
EndIf
@243,535 BUTTON "Consulta"  Size 050, 011 Font oDlg:oFont Action VisuSE1() Of oDlg Pixel
@243,590 BUTTON "Cancela"   Size 050, 011 Font oDlg:oFont Action oDlg:End() Of oDlg Pixel
Activate MsDialog oDlg Center
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ VisuSE1  ºAutor  ³Eduardo Augusto     º Data ³  22/10/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para Chamada do mBrowse da Tela de Inlcusao do      º±±
±±º          ³ Contas a Receber (Somente Consulta)             			 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ I2I Eventos							                   º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function VisuSE1()
Local cCadastro := "Tela do Contas a Receber"
Local aRotina 	:= { {"Pesquisar","AxPesqui",0,1}, {"Visualizar","AxVisual",0,2} }
Local cDelFunc 	:= ".T."
Local cString 	:= "SE1"
DbSelectArea("SE1")
SE1->(DbSetOrder(1)) // E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
DbSelectArea(cString)
mBrowse(6,1,22,75,cString)
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³Marca     ºAutor  ³Eduardo Augusto     º Data ³  22/10/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que Marca ou Desmarca todos os Objetos.             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ I2I Eventos						                          º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function Marca(lMarca,aVetor)
Local i
For i := 1 To Len(aVetor)
	aVetor[i][1] := lMarca
Next
oLbx:Refresh()
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³CANCETOT  ºAutor  ³Eduardo Augusto     º Data ³  22/10/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para Limpar os campos da Tabela SE1 quando o Boleto º±±
±±º		    ³ sofrer cancelamento total das informações...				 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Replas												 º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function CanceTot(aVetor)
Local j
For j := 1 To Len(aVetor)
	If aVetor [j][1] == .T.
		DbSelectArea("SE1")                      
		DbSetOrder(1)	 // E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
		If DbSeek(xFilial("SE1") + aVetor[j][2] + aVetor[j][3] + aVetor[j][4] + aVetor[j][12])
			RecLock("SE1",.F.)
			SE1->E1_NUMBCO	:= ""
			SE1->E1_XNUMBCO	:= ""
			SE1->E1_CODBAR	:= ""
			SE1->E1_CODDIG	:= ""
			//If SE1->E1_PORTADO <> "422"
				SE1->E1_PORTADO	:= ""
				SE1->E1_AGEDEP	:= ""
				SE1->E1_CONTA		:= ""
			//EndIf
			MsUnLock()
		EndIf
	EndIf
Next
MsgInfo("Cancelamento de Boleto Total Finalizado com Sucesso")
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³Marca     ºAutor  ³Eduardo Augusto     º Data ³  22/10/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que Perguntas do SX1.					              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Replas							                          º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

//---> REMOVIDO compatibilização para versão 12.1.25.
/*Static Function ValidPerg()
Local i
Local j
_sAlias := Alias()
DbSelectArea("SX1")
DbSetOrder(1)
cPerg := PadR(cPerg,10)
aRegs:={}
// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
aAdd(aRegs,{cPerg,"01","Banco              :","","","mv_chB","C",03,0,0,"G","","Mv_Par01",""    ,"","",""      ,"","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Agencia            :","","","mv_chC","C",05,0,0,"G","","Mv_Par02",""    ,"","",""      ,"","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Conta              :","","","mv_chD","C",10,0,0,"G","","Mv_Par03",""    ,"","",""      ,"","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"04","SubCta             :","","","mv_chE","C",03,0,0,"G","U_VALSUBCT()","Mv_Par04",""    ,"","",""      ,"","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"05","Tipo de Impressao  :","","","mv_chF","N",01,0,0,"C","","Mv_Par05","1° Via","1° Via","1° Via","","","2° Via","2° Via","2° Via","","","Outros","Outros","Outros","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"06","Emissao de         :","","","mv_chG","D",08,0,0,"G","","Mv_Par06",""    ,"","",""      ,"","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"07","Emissao ate        :","","","mv_chH","D",08,0,0,"G","","Mv_Par07",""    ,"","",""      ,"","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"08","N° do Titulo       :","","","mv_chI","C",09,0,0,"G","","Mv_Par08",""    ,"","",""      ,"","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"09","N° do Bordero      :","","","mv_chJ","C",06,0,0,"G","","Mv_Par09",""    ,"","",""      ,"","","","","","","","","","",""})
For i := 1 to Len(aRegs)
	If !DbSeek(cPerg + aRegs[i,2])
		RecLock("SX1",.T.)
		For j := 1 to Len(aRegs[i])
			FieldPut(j,aRegs[i,j])
		Next
		MsUnlock()
	EndIf
Next
DbSkip()
DbSelectArea(_sAlias)
Return*/

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³VALSUBCT   ºAutor  ³Microsiga          º Data ³  28/08/2015 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Programa de validador da Subconta.						 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Replas												 º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function VALSUBCT()
Local lRet := .T.
DbSelectArea("SEE")
SEE->(DbSetOrder(1))	// EE_FILIAL + EE_CODIGO + EE_AGENCIA + EE_CONTA + EE_SUBCTA
lRet := SEE->(DbSeek(xFilial("SEE") + Mv_Par01 + Mv_Par02 + Mv_Par03 + Mv_Par04 ))
If !lRet
	MsgAlert("Subconta não relacionada com o Banco informado no Parâmetro, favor informar a Subconta correta!!!")
	lRet := .F.
EndIf
Return lRet
