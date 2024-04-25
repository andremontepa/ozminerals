#INCLUDE "PROTHEUS.CH"

USER FUNCTION F240CONF()

	Local lRetorno := .T.

	If !MsgYesNo('Confirma a Geracao do Bordero?','Criacao de Bordero')
		lRetorno := .F.
	EndIf

RETURN lRetorno
