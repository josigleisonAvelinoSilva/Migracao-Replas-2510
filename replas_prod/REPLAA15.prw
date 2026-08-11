#include "fileio.ch"
#include "rwmake.ch"
#include "totvs.ch"

User Function replaa15( aDestinat , cAssunto , cMensagem , aAnexos )

	Local lRet			:= .T.
	Local cTO			:= ""
	Local cCC			:= ""
	Local cSMTPServer	:= "email-ssl.com.br"
   	Local cFrom			:= GETMV("MV_RELFROM",.F.,"")
	Local cSMTPUser 	:= GETMV("MV_RELACNT",.F.,"")
	Local cSMTPPass 	:= GETMV("MV_RELAPSW" ,.F.,"")
	Local lRelAuth 		:= GetMv("MV_RELAUTH",.F., .F.)
	Local nSMTPPort		:= 587

	Local oMail			:= Nil
	Local oMessage 		:= Nil
	Local nErro			:= 0
	Local nEmail		:= 0
	Local nX			:= 0
	Local cFileName		:= ""

	DEFAULT aDestinat	:= {}
	DEFAULT cAssunto	:= ""
	DEFAULT cMensagem	:= ""

	Private cError		:= ""
	Private lSendOk	:=	.T.

	cFrom			:= "acfontescloud@gmail.com"
	cSMTPServer	    := "smtp.gmail.com"
	cSMTPUser 	    := "acfontescloud@gmail.com"
	cSMTPPass 	    := "ooddqhgopzweatqj"
	lRelAuth 		:= .T.
	nSMTPPort		:= 587

	/*
	 * Envio de e-mail só ocorre se existirem destinatários
	 */
	If Len(aDestinat) > 0
		cTo := aDestinat[1] // Primeiro e-mail de destinatários
		/*
		 * Próximos destinatários com cópia oculta.
		 */
		For nEmail := 2 To Len(aDestinat)
			If EMPTY(cCC)
				cCC += aDestinat[nEmail]
			Else
				cCC += ", " + aDestinat[nEmail]
			EndIf
		Next nEmail

		/*
		 * Iniciando conexão com o servidor de e-mails
		 */
		oMail := TMailManager():New()
		oMail:SetUseTLS( lRelAuth )
		//Inicializando SMTP
		oMail:Init( '', cSMTPServer , cSMTPUser, cSMTPPass, 0, nSMTPPort  )

		//Setando Time-Out
		oMail:SetSmtpTimeOut( 500 )

		//Conectando com servidor...
		nErro := oMail:SmtpConnect()

		/*
		 * Autenticando o usuário no servidor de e-mails
		 */
		If lRelAuth

			//Autenticando Usuario
			nErro := oMail:SmtpAuth(cSMTPUser ,cSMTPPass)

			If nErro <> 0

				// Recupera erro ...
				cMAilError := oMail:GetErrorString(nErro)
				DEFAULT cMailError := '***UNKNOW***'
				Conout("Erro de Autenticacao "+str(nErro,4)+' ('+cMAilError+')')

				lRet := .F.
			Endif
		EndIf

		If nErro <> 0
			// Recupera erro
			cMAilError := oMail:GetErrorString(nErro)
			DEFAULT cMailError := '***UNKNOW***'

			conOut(cMAilError)
			ConOut("Erro de Conexao SMTP "+str(nErro,4))
			conOut('Desconectando do SMTP')

			oMail:SMTPDisconnect()
			lRet := .F.
		Endif

		/*
		 * Criando o objeto da mensagem do e-mail
		 */

		oMessage := TMailMessage():New()
		oMessage:Clear()
	    oMessage:cFrom			:= cFrom
	    oMessage:cTo			:= cTo
	    oMessage:cBcc			:= cCC
	    oMessage:cSubject		:= cAssunto
	    oMessage:cBody			:= cMensagem
	    oMessage:MsgBodyType( "text/html" )

		For nX := 1 To Len(aAnexos)
			// Só anexa se o arquivo existir
			If File(aAnexos[nX])

				If oMessage:AttachFile( aAnexos[nX] ) < 0
					Conout("Erro ao anexar o arquivo")
				Else
					If (nPos:= Rat('\',aAnexos[nX]) ) > 0
						cFileName := Substr(aAnexos[nX],nPos+1)
					Else
						cFileName := aAnexos[nX]
					EndIf
					oMessage:AddAtthTag( 'Content-Disposition: attachment; filename='+cFileName)
				EndIf
			EndIf
		Next nX

		//conout(oMessage:cBody)
		//Alert(oMessage:cBody)
		//conout('Enviando Mensagem para ['+cTo+'] ')
		//Alert('Enviando Mensagem para ['+cTo+'] ')
		nErro := oMessage:Send( oMail )

		If nErro <> 0
			xError := oMail:GetErrorString(nErro)
			//Conout("Erro de Envio SMTP "+str(nErro,4)+" ("+xError+")")
			//Alert("Erro de Envio SMTP "+str(nErro,4)+" ("+xError+")")
			lRet := .F.
		Endif

		conout('Desconectando do SMTP')
		//Alert('Desconectando do SMTP')
		oMail:SMTPDisconnect()
	Else
		Alert("Sem destinatários para envio do e-mail .")
		//CONOUT("Sem destinatários para envio do e-mail .")
		lRet := .F.
	EndIf

Return lRet



#include "protheus.ch"


user function tstmail()
wfprepenv("01","01")
u_docemail("fbmuta@gmail.com","TESTE EMAIL", "TESTE MAIL TIT")
return

User Function DocEMail(cAxPara, cAxBody, cAxTitulo)

Local aSMTPServer	:= StrTokArr2(GETMV("MV_RELSERV",.F.,""),":")
Local cServer       := Lower( SuperGetMv( "MV_RELSERV", .F., "" ) )
Local cUser         := Lower( SuperGetMv( "MV_RELACNT", .F., "" ) )
Local cPass         := SuperGetMv( "MV_RELAPSW" , .F., "" )
Local cFrom         := Lower( SuperGetMv( "MV_RELFROM", .F., "" ) ) 
Local nPort         := SuperGetMv( "VL_MAILPOR", .F., 587 )
Local cSubject		:= cAxTitulo
Local cErro			:= ""
Local lOk			:= .T. 
Local nErro 		:= 0
Local oMailServer	:= Nil
Local oMessage	    := Nil
Local nX
for nX := 1 to len(aSMTPServer)
	if nX == 1
		cServer := AllTrim(aSMTPServer[nX])
	endif
	if nX == 2
		nPort := Val(AllTrim(aSMTPServer[nX]))
	endif
next

	oMailServer	:= TMailManager():New()
	oMailServer:SetUseSSL( .F. ) 

	nErro := oMailServer:Init("", cServer, cUser, cPass, 0, nPort)

	If nErro != 0
		lOk := .F.
		cErro := "Não foi possível estabelecer uma conexão com o servidor: " + oMailServer:GetErrorString(nErro)
	Endif

	If lOk
		nErro := oMailServer:SetSMTPTimeOut(120)

		If nErro != 0
			lOk := .F.
			cErro := "O protocolo não pode ser configurado " + CValToChar(120) // "O protocolo não pode ser configurado ", " timeout para "
		Endif
	EndIf

	If lOk
		nErro := oMailServer:SmtpConnect()

		If nErro != 0
			lOk := .F.
			cErro := "Não foi possível estabelecer uma conexão com o servidor SMTP: " + oMailServer:GetErrorString(nErro) // "Não foi possível estabelecer uma conexão com o servidor SMTP: "
		EndIf
	EndIf


    oMessage := TMailMessage():New()
    oMessage:Clear()

    oMessage:cDate		:= DToC(Date())
    oMessage:cFrom 		:= cFrom
    oMessage:cTo 		:= cAxPara
    oMessage:cSubject	:= cSubject
    oMessage:cCC 		:= ""
    oMessage:cBCC 		:= ""

    oMessage:cBody := cAxBody
    oMessage:MsgBodyType( "text/html" )
    nErro := oMessage:Send( oMailServer )

    If nErro != 0
        lOk := .F.
        cErro := "Erro de envio:" + oMailServer:GetErrorString(nErro)
    EndIf

Return
