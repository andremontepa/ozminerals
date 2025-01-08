#INCLUDE "rwmake.ch"        
#INCLUDE "TbiConn.ch"
#INCLUDE "TbiCode.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEnviEmail บAutor  ณMicrosiga           บ Data ณ  06/05/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo para Enviar E_mail                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function EnviEmail(_carq,cTitulo,cSubject,cBody,lShedule,cTo,cCC)

LOCAL cServer, cAccount, cPassword, lAutentica, cUserAut, cPassAut
LOCAL cUser,lMens:=.T.,nOp:=0
Local oDlg

DEFAULT cTitulo  := ""
DEFAULT cSubject := ""
DEFAULT cBody    := ""
DEFAULT lShedule := .F.
DEFAULT cTo      := "erp@avancoresources.com.br"
DEFAULT cCc      := "erp@avancoresources.com.br"

If Empty(_carq)
	cAttachment:=""
Else
	cAttachment:=_carq
Endif

IF EMPTY((cServer:=AllTrim(GetNewPar("MV_RELSERV",""))))
	IF !lShedule
		MSGINFO("Nome do Servidor de Envio de E-mail nao definido no 'MV_RELSERV'")
	ELSE
		ConOut("Nome do Servidor de Envio de E-mail nao definido no 'MV_RELSERV'")
	ENDIF
	RETURN .F.
ENDIF

IF EMPTY((cAccount:=AllTrim(GetNewPar("MV_RELACNT",""))))
	IF !lShedule
		MSGINFO("Conta para acesso ao Servidor de E-mail nao definida no 'MV_RELACNT'")
	ELSE
		ConOut("Conta para acesso ao Servidor de E-mail nao definida no 'MV_RELACNT'")
	ENDIF
	RETURN .F.
ENDIF

IF lShedule .AND. EMPTY(cTo)
	IF !lShedule
		ConOut("E-mail para envio, nao informado.")
	ENDIF
	RETURN .F.
ENDIF

IF ! lShedule
	cFrom:= UsrRetMail(RetCodUsr())
	cUser:= UsrRetName(RetCodUsr())
else
	cFrom:= AllTrim(GetMv("MV_RELACNT",,''))
	cUser:= AllTrim(GetMv("MV_RELAUSR",,''))
endif
cCC  := cCC //+ SPACE(200)
cTo  := cTo //+ SPACE(200)
cSubject:=cSubject+SPACE(100)

IF EMPTY(cFrom)
	IF !lShedule
		MsgInfo("E-mail do remetente nao definido no cad. do usuario: "+cUser)
	ELSE
		ConOut("E-mail do remetente nao definido no cad. do usuario: "+cUser)
	ENDIF
	RETURN .F.
ENDIF
cPassword := AllTrim(GetNewPar("MV_RELPSW"," "))
lAutentica:= GetMv("MV_RELAUTH",,.F.)         //Determina se o Servidor de Email necessita de Autentica็ใo
cUserAut  := Alltrim(GetMv("MV_RELAUSR",," "))//Usuแrio para Autentica็ใo no Servidor de Email
cPassAut  := Alltrim(GetMv("MV_RELAPSW",," "))//Senha para Autentica็ใo no Servidor de Email

/////////////////////////CONECTA NO SERVIDOR//////////////////////////////////
CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lOK
/////////////////////////CONECTA NO SERVIDOR/////////////////////////////////
If !lOK
	IF !lShedule
		MsgInfo("Falha na Conexใo com Servidor de E-Mail")
	ELSE
		ConOut("Falha na Conexใo com Servidor de E-Mail")
	ENDIF
ELSE
	If lAutentica
		If !MailAuth(cUserAut,cPassAut)
			MSGINFO("Falha na Autenticacao do Usuario")
			DISCONNECT SMTP SERVER RESULT lOk
		EndIf
	EndIf       
	
	     
			
		//****************************************************************************************************
	   //	IF EMPTY(cAttachment)
			IF !EMPTY(cCC)
				SEND MAIL FROM cFrom TO cTo CC cCC SUBJECT cSubject BODY cBody ATTACHMENT cAttachment RESULT lOK
			ELSE
				SEND MAIL FROM cFrom TO cTo SUBJECT cSubject BODY cBody ATTACHMENT cAttachment RESULT lOK
			ENDIF
	
	If !lOK
		IF !lShedule
			MsgInfo("Falha no Envio do E-Mail: "+ALLTRIM(cTo))
		ELSE
			ConOut("Falha no Envio do E-Mail: "+ALLTRIM(cTo))
		ENDIF
		alert("Email nao enviado, verifique!")
		DISCONNECT SMTP SERVER
		RETURN .F.
	Else
		IF !lShedule
			//MsgInfo("E-mail enviado com sucesso: "+ALLTRIM(cTo))
		ELSE
			ConOut("E-mail enviado com sucesso: "+ALLTRIM(cTo))
		ENDIF		
	ENDIF
	
	
ENDIF

DISCONNECT SMTP SERVER

IF lOk
	IF !lShedule
		//MsgInfo("E-mail enviado com sucesso: "+ALLTRIM(cTo))
	ELSE
		ConOut("E-mail enviado com sucesso: "+ALLTRIM(cTo))
	ENDIF
ENDIF

RETURN .T.

