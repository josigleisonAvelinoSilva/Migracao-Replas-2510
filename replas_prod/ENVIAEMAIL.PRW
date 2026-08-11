#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#INCLUDE "AP5MAIL.CH"
#Include "tbiconn.ch"
#define _CRLF CHR(13)+CHR(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ENVIAEMAILºAutor  ³Totvs          º Data ³  07/06/16        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Exp1 - Titulo do email                                      º±±
±±º          ³Exp2 - destinantarios                                       º±±
±±º          ³Exp3 - Destainatarios ocultos                               º±±
±±º          ³Exp4 - Corpo da mensagen                                    º±±
±±ºDesc.     ³Exp5 - Local do Arquivo                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function ENVIAEMAIL(_cDE,cTitulo,cDestina,cCco,cMensagem,Path)

Private oMsg, oMail, oWF 	:= TWFObj(), nInd, cBody
Private lResult   			:= .f.				// Resultado da tentativa de comunicacao com servidor de E-Mail
Private cDestin 				:= cDestina

Private cTitulo 				:= cTitulo
Private cMensagem				:= cMensagem
Private cEmailBcc    	    	:= cCco
Private cAttachment 			:=  Path
Private lAutentica    		    := .T.//GetMV("MV_RELAUTH")
Private _cHttp					:= GetNewPar("MV_WFHTTP", "http://172.16.0.16/workflow/")  //aqui deve colocar o endereço do servidor de e-mail


Private nRet         		:= .F.

If EMPTY(_cDE)
	_cDE :="seu email@seuemail.com.br"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tenta conexao com o servidor de E-Mail ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tenta conexao com o servidor de E-Mail ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CONNECT SMTP                         ;
SERVER 	 GetMV("MV_RELSERV"); 	// Nome do servidor de e-mail
ACCOUNT  GetMV("MV_RELACNT"); 	// Nome da conta a ser usada no e-mail
PASSWORD GetMV("MV_RELPSW") ; 	// Senha
RESULT   lResult             	// Resultado da tentativa de conexão


If !lResult
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Nao foi possivel estabelecer conexao com o servidor ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Help(" ",1,"ACAA170_01") 	// _cErro := MailGetErr()
	IF apMsgYesNo("Não foi possível se conectar ao servidor de emails - Deseja tentar novamente?")
		U_ENVIAEMAIL(cTitulo,cDestin,cEmailBcc,cMensagem,cAttachment)
	Else
		nRet := .F.
		
	ENDIF
Else
	
	// Verifica se o E-mail necessita de Autenticacao
	if lAutentica
		lvalida :=MailAuth(GetMV("MV_RELACNT"),GetMV("MV_RELPSW"))
		If !lvalida
			ALERT("ERRO Não foi possível conectar ao servidor SMTP. Contate o TI ! - "+ GetMV("MV_RELACNT"))
		EndIf
		
	endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Mandar mais de um arquivo em anexo                  ³
	//³ ATTACHMENT aFiles[1], aFiles[2];                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*
	//	IF SUBSTR(cNumEmp,1,2) == '01'
	SEND MAIL;
	FROM   _cDe;  // GetMV("MV_RELACNT");          //Conta do e-mail do configurador
	TO 	             cDestin;          //Destinatario
	BCC            cEmailBcc;          //Destinatario Oculto
	SUBJECT          cTitulo;          // Titulo do e-mail
	BODY 	       cMensagem;         // Mensagem
	ATTACHMENT   cAttachment;         // Arquivo em anexo
	RESULT 	lResult
	
	IF !lResult
	GET MAIL ERROR cError
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza conexao com o servidor de E-Mail ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DISCONNECT SMTP SERVER
	nRet := .F.
	ELSE
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza conexao com o servidor de E-Mail ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DISCONNECT SMTP SERVER
	nRet := .T.
	ENDIF
	
	
	
	EndIf
	Return nRet
