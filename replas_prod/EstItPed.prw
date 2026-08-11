#Include "Protheus.ch"
#Include "TbiConn.ch"
#Include "Totvs.ch"
#Include "TopConn.ch"

#Define Enter Chr(13) + Chr(10)

/*/{Protheus.doc} EstItPed
(long_description) Estorno de Liberação do PV por Item.
@type function
@author Eduardo Augusto
@since 18/09/2017
@version 1.0
@return Nil
@example
(examples)
@see (links_or_references)
/*/

User Function EstItPed()
Local nDias		:= 0
Local nDiaPar	:= GetMv("MV_XDIAPAR")
Local aLocal    := {}
Local cQuery	:= ""
Private aPedVen	:= {}
Private cXEmail	:= Alltrim(GetMv("MV_XEMAILS"))
Private cPedido := ""
// Filtra os Pedidos Liberados não Faturados 
If Select("TMP") > 0
	TMP->(DbCloseArea())
EndIf
cQuery := " SELECT C9_PEDIDO, C9_CLIENTE, R_E_C_N_O_ AS SC9REC FROM " + RetSqlName("SC9") + Enter
cQuery += " WHERE D_E_L_E_T_ <> '*' "	+ Enter
cQuery += " 	AND C9_FILIAL = '" + xFilial("SC9") + "' "	+ Enter
cQuery += " 	AND C9_NFISCAL = '' "	+ Enter
cQuery += " 	AND C9_PEDIDO IN ('001437','001432') "	+ Enter
cQuery += " 	AND C9_BLEST <> '10' "	+ Enter
cQuery += " 	AND C9_BLCRED <> '10' "	+ Enter
cQuery += " ORDER BY C9_PEDIDO "
TcQuery cQuery New Alias "TMP"
cPedido := ''	// TMP->C9_PEDIDO
While TMP->(!Eof()) .And. cPedido <> TMP->C9_PEDIDO
	// Posiciona na Tabela SC5
	DbSelectArea("SC5")
	SC5->(DbSetOrder(1)) // C5_FILIAL + C5_NUM
	If SC5->(DbSeek(xFilial("SC5") + TMP->C9_PEDIDO))
		// Se a Database - Emissao do Pedido = Resultado nDias
		nDias := dDatabase - SC5->C5_EMISSAO
		If (nDias - nDiaPar) <= 1	// nDias - nDiaPar Dias Informado no Parametro for menor ou igual a 1
			If cPedido <> TMP->C9_PEDIDO	// Se o Pedido for diferente 1ª passada
				// Alimenta o Array aPedVen
				If (nPosVnd := ASCan(aPedVen, {|x|, x[01] == SC5->C5_VEND1 })) > 0 // Vendedor ja tem
					If (nPosCli := ASCan(aPedVen[nPosVnd,02], {|y|, y[1] == TMP->C9_CLIENTE })) > 0 // Cliente ja tem
						If (nPosPed := ASCan(aPedVen[nPosVnd,02], {|y|, y[2] == TMP->C9_PEDIDO })) == 0 // Pedido ainda nao tem
							aAdd(aPedVen[nPosVnd,02], { TMP->C9_CLIENTE, TMP->C9_PEDIDO }) 
						EndIf
					Else
						aAdd(aPedVen[nPosVnd], { TMP->C9_CLIENTE, TMP->C9_PEDIDO })
					EndIf
					cPedido := TMP->C9_PEDIDO
				Else // Cria toda a matriz
					aAdd(aPedVen, { SC5->C5_VEND1, { { TMP->C9_CLIENTE, TMP->C9_PEDIDO } } })
				EndIf
			EndIf
			//Estorna os Itens do Pedido
			//TMP->(a460Estorna(.T.))
			//DbSkip()
		EndIf
	//Else
		//DbSkip()
	EndIf
	TMP->(DbSkip())
End
If Len(aPedVen) > 0
   EnviaLog(aPedVen)
EndIf
If Len(aPedVen) > 0
	MsgRun("Os E-mails com os Nº dos Pedidos foram enviados com sucesso.",,{|| Sleep(3000) })
EndIf
Return
	
/*/{Protheus.doc} EnviaLog
(long_description) Rotina para o Envio de E-mails.
@type function
@author Eduardo Augusto
@since 18/09/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

Static Function EnviaLog( aPedVen )	// EnviaLog( cEmailTo, cAssunto, cMensagem, cAttach )
Local cAccount	:= Alltrim( GetMv( "MV_RELACNT" ) )
Local cPassword	:= Alltrim( GetMv( "MV_RELPSW"  ) )
Local cServer	:= Alltrim( GetMv( "MV_RELSERV" ) )
Local cUserAut	:= Alltrim( GetMv( "MV_RELAUSR" ) )
Local cPassAut	:= Alltrim( GetMv( "MV_RELAPSW" ) )
Local cUser		:= ""
Local nAt		:= 0
Local i			:= 0
Local j			:= 0
Local lSendMail	:= .F.
Local lConect	:= .F.
Local cError   	:= ""
Local cMail		:= ""
Local cAttach	:= ""
// Posiciono Cadastro de Vendedor
DbSelectArea("SA3")
DbSetOrder(1)	// A3_FILIAL + A3_COD
For i := 1 to Len(aPedVen)
	DbSeek(xFilial("SA3") + aPedVen[i,1] )
	cPara := "eduardo.apereira@totvs.com.br;carlos.dasilva@totvs.com.br"	//SA3->A3_EMAIL	// Posicione("SA3", 1, xFilial("SA3") + SC5->C5_VEND1, "A3_EMAIL")
	cCc	  := cXEmail
	If Empty(cPara)
		MsgInfo('Informe um e-mail de destino válido.' + Chr(13) + Chr(10) + 'Campo: E-mail','Atenção')
		Return
	EndIf
	cAssunto := 'Estorno de Liberação do Item do Pedido de Venda'
	cAttach := ""
	// Mensagem antes da Montagem da Grid do Cabeçalho e Item
	cMail := ' <html xmlns="http://www.w3.org/1999/xhtml"> '
	cMail += ' 	<body> '
	cMail += ' 		<p> '
	cMail += ' 			Prezado(a) Sr. ' + Alltrim(SA3->A3_NOME) + ' o Prazo de Reserva dos Pedidos abaixo estão encerrados, os Pedidos serão mantidos em abertos porem sem os empenhos dos itens dos Pedidos de Vendas. '
	cMail += ' 		</p> '
	cMail += ' 		<br /> '
	cMail += ' 	</body> '
	// Monta Cabeçalho da Grid
	cMail += ' 	<table width="1090" border="1"> '
	cMail += ' 		<tr> '
	cMail += ' 			<td bgcolor="#FFFF00"><strong>Cliente</strong></td> '
	cMail += ' 			<td bgcolor="#FFFF00"><strong>Nº Pedido</strong></td> '
	cMail += ' 		</tr> ' 
	cMail += ' 		<tr> '
    For j := 1 to Len(aPedVen[i,02])
		// Monta a Grid dos Itens
		cMail += ' 			<td bgcolor="#FFFFFF"><span class="style2"> ' + Posicione("SA1", 1, xFilial("SA1") + aPedVen[i,02,j,01], "A1_NREDUZ") + ' </span></td> '
		cMail += ' 			<td bgcolor="#FFFFFF"><span class="style2"> ' + aPedVen[i,02,j,02] + ' </span></td> '
		cMail += ' 		</tr> '
	Next
	cMail += ' 		</tr> '
	cMail += ' 	</table> '
	cMail += ' </html> '
	// Envia o e-mail para a lista selecionada. Envia como BCC para que a pessoa pense que somente ela recebeu aquele email, tornando o email mais personalizado.
	Connect Smtp Server cServer Account cAccount Password cPassword Result lConect
	// Erro na conexao com o Servidor SMTP. Enviar mensagem ao console do servidor
	If !lConect
		ConOut( "ERRO: Não foi possível conexão com o Servidor SMPT. O Email não foi enviado..." )
		Return( Nil )
	EndIf
	// Verifica se o Servidor de Email necessita de Autenticacao
	If GetMv( "MV_RELAUTH" )
		If !Mailauth( cUserAut, cPassAut )
			// Tenta novamente efetuar a autenticacao no servidor, porem, agora so com o nome do usuario.
			// Ex: 1a. Tentativa - usuario "usuario@provedor.com.br"
			//     2a. Tentativa - usuario "usuario"
			nAt 	:= At( "@", cUserAut )
			cUser 	:= If( nAt > 0, Subs( cUserAut, 1, nAt-1 ), cUserAut )
			If !Mailauth( cUser, cPassAut )
				MsgInfo("ERRO: Não foi possível efetuar a autenticação do usuário no Servidor STMP. O Email não foi enviado...")
				//ConOut( "ERRO: Não foi possível efetuar a autenticação do usuário no Servidor STMP. O Email não foi enviado..." )
				Return( Nil )
			EndIf
		EndIf
	EndIf
	// Envia o email
	If Empty(cAttach)
		Send Mail From cAccount To cPara Subject cAssunto Body cMail Result lSendMail
	Else
		Send Mail From cAccount To cPara Subject cAssunto Body cMail Attachment cAttach Result lSendMail
	EndIf
	// Erro no envio do email.
	If !lSendMail
		Get Mail Error cError
		ConOut( "Nao foi possivel efetuar o envio do Email. ERRO: " + cError )
		Return( Nil )
	EndIf
	// Email enviado com sucesso. Sai do servidor e atualiza mensagem no console
	Disconnect Smtp Server
Next
Return