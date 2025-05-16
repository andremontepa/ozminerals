#include "totvs.ch"
#include "Protheus.Ch"
#include "TbiConn.Ch"
#Include "TopConn.ch"
#include "Ap5Mail.ch"
#Include "Rwmake.ch"
#include "ozminerals.ch"

/*/{Protheus.doc} OZ06A01D

  Rotina que responsavle para enviar e-mail´s 

@type Function
@author Fabio Santos - CRM Service
@since 15/08/2024
@version P12
@database MSSQL

@See WSARGO

/*/
User Function OZ06A01D(cRecebe,cCopia,cAssunto,cMensagem,cFile,lDisplay)
	Local cRem       := "" as character
	Local cError     := "" as character
	Local cPassa     := "" as character
	Local cServer    := "" as character
	Local cAccount   := "" as character
	Local cEnvia     := "" as character
	Local cPassword  := "" as character

	cServer    		 := GetNewPar("OZ_RELSERV" ,"smtp.office365.com:587")
	cAccount   		 := GetNewPar("OZ_RELACNT" ,"protheus@anastacio.com")
	cEnvia     		 := GetNewPar("OZ_RELACNT" ,"protheus@anastacio.com")
	cPassword  		 := GetNewPar("OZ_RELPSW"  ,"Sistema10Anastacio$$")

	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lConectou

	If ( lConectou )
		MAILAUTH(cAccount,cPassword)     
	Else
		cError := ""
		GET MAIL ERROR cError
		If lDisplay
			Alert(cError+" no Servidor SMTP")
		Endif
	Endif

	cNomeUsr := UsrRetName(RetCodUsr())
	PswOrder(2) // Ordem de nome
	PswSeek(cNomeUsr,.T.)
	aRetUser := PswRet(1)
	Email  	:= alltrim(aRetUser[1,14])
	
	If (!Empty(Email))
		cRem   := "OZmineral´s - Integração Do Processo Argo x Protheus"/*AllTrim(cNomeUsr)*/+" <"+cEnvia+">"
	Else
		cRem   := "OZmineral´s - Integração Do Processo Argo x Protheus"/*AllTrim(cNomeUsr)*/+" <"+GetMV("MV_RELFROM")+">"
	EndIF
	
	If ( !Empty(cRem))
		cEnvia := cRem
	EndIf

	If ( !Empty(cFile) )
		SEND MAIL FROM cEnvia;
				  TO cRecebe;
				     CC cCopia ;
					 SUBJECT cAssunto;
					 BODY cMensagem;
					 ATTACHMENT cFile;
					 FORMAT TEXT;
					 RESULT lEnviado
	Else
		SEND MAIL FROM cEnvia;
				  TO cRecebe;
					 CC cCopia ;
					 SUBJECT cAssunto;
					 BODY cMensagem;
					 FORMAT TEXT;
					 RESULT lEnviado
	Endif

	If (lEnviado)
		If lDisplay
			cPassa := "Enviado"
		Endif
	Else
		GET MAIL ERROR cMensagem
			If ( lDisplay )
				Alert(cMensagem+":"+cAssunto)
			Endif
		Return .F.
	Endif

	DISCONNECT SMTP SERVER Result lDisConectou

	If ( lDisConectou )
		If lDisplay
			cPassa := "Desconectado"
		Endif
	Endif

Return .T.


