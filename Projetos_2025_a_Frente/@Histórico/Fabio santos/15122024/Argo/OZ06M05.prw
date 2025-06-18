#include "protheus.ch"
#include "Totvs.ch"
#include "Tbiconn.ch"
#include "ozminerals.ch"

#define REGISTRO_ATUALIZADO         "Registro Atualizado"
#define REGISTRO_NAO_ATUALIZADO     "Registro Não Atualizado"

#define GRAVA_FLAG  				"1"
  
#define STATUS_RECORD    		     1
#define STATUS_NO_RECORD 		     2

/*/{Protheus.doc} OZ06M05

	Rotina para executar o argo de forma manual 

@type Function
@author Fabio Santos - CRM Service
@since 18/08/2024
@version P12
@database MSSQL

@see OZGENSQL
@see OZGEN18

@nested-tags:Frameworks/OZminerals
/*/
User Function OZ06M05()
	Private lFiltrado        := .F. as logical
	Private cSintaxeRotina   := ""  as character

	cSintaxeRotina           := ProcName(0)

	FWMsgRun(,{|| u_OZ34WS04() } ,"Processando Integração Pagamento Antecipado Argo...","Aguarde")
	FWMsgRun(,{|| u_OZ34WS01() } ,"Processando Integração Despesas Argo...","Aguarde")

Return

/*
	Apresenta a Mensagem no Console do Protheus
*/
Static Function showLogInConsole(cMsg)

	libOzminerals.u_showLogInConsole(cMsg,cSintaxeRotina)

Return
