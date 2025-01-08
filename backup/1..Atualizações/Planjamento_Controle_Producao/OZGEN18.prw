#include "totvs.ch"
#include "tryexception.ch"
#include "ozminerals.ch"

/*/{Protheus.doc} OZGEN18

	Rotina Genérica para Apresentação de Mensagens no Log do Protheus,
	adicionando informações complementares

@type function
@author Fabio Santos - CRM Service
@since 08/10/2023
@version P12
@database MSSQL

@param uMsg, variant, Mensagem para apresentação no Log
@param [lDate], logical, Indica se irá imprimir a Data na mensagem como prefixo - Padrão: .T.
@param [lTime], logical, Indica se irá imprimir a Hora na mensagem como prefixo - Padrão: .T.
@param [lCompany], logical, Indica se irá imprimir a Empresa na mensagem como prefixo - Padrão: .T.
@param [lUser], logical, Indica se irá imprimir o Usuário na mensagem como prefixo - Padrão: .T.
@param [lEnvironment], logical, Indica se irá imprimir o Ambiente/IP na mensagem como prefixo - Padrão: .T.
@param [lRoutine], logical, Indica se irá imprimir o Nome da Rotina na mensagem como prefixo - Padrão: .T.
@param [nRoutines], numeric, Indica o nº de rotinas a ser apresentada no Log - Padrão: 5
@param [lLineRoutine], logical, Indica se irá imprimir a Linha da Rotina na mensagem como prefixo - Padrão: .T.

@see http://tdn.totvs.com/display/framework/FwLogMsg
@see u_showLogInConsole()

@nested-tags:Frameworks/libOzminerals
/*/ 
User Function OZGEN18(uMsg,lDate,lTime,lCompany,lUser,lEnvironment,lRoutine,nRoutines,lLineRoutine)	
	Local cUser				:= ""
	Local cRoutine			:= ""
	Local cRoutines			:= ""
	Local cMsgInf 			:= ""
	Local cMsg				:= ""

	Private lAmbPreparado	:= ( Select("SX6") > 0 )
	Private lActiveLogs		:= Iif( lAmbPreparado, GetNewPar("OZ_LOGS", .T.), .T.)
	Private lDetailLogs		:= Iif( lAmbPreparado, GetNewPar("OZ_DETLOGS", .F.), .T.)
	Private lIsInJOB		:= ( isInJob() ) //!( SrvDisplay() )
	Private cUsaFwMsgLog	:= GetSrvProfString("FWLOGMSG_DEBUG","0")

	Default uMsg			:= ""
	Default lDate			:= .T.
	Default lTime			:= .T.
	Default lCompany 		:= .T.
	Default lUser			:= .T.
	Default lRoutine		:= .T.
	Default nRoutines		:= Iif(Select("SX6")>0,GetNewPar("OZ_NROUTI",3),3)
	Default lLineRoutine	:= .T.

    If ( lActiveLogs )
		If ( cUsaFwMsgLog == "1" )
			addLog(uMsg)
		Else
			cMsgInf := AllTrim(AllToChar(uMsg))	
			If ( !Empty(cMsgInf) )
			
				If ( lAmbPreparado )
				
					If !( lDetailLogs )
						lDate 			:= .F.
						lTime 			:= .F.
						lEnvironment	:= .F.
						lRoutine		:= .F.
					Endif
				
					If ( lDetailLogs )
						cMsg  += "[" + ProcName() + "]"
					Endif
					If ( lDate )
						cMsg += "[" + DtoC(Date()) + "]"
					Endif
					If ( lTime )
						cMsg += "[" + Time() + "]"
					Endif
					If ( lCompany )
						cMsg += "[" + FwGrpCompany() + "/" + FwCodFil() + "]"
					Endif		
					If ( lUser )
						If ( isInJob() .Or. Type("cUserName") <> "C" )
							cUser := "JOB"
						Else
							cUser := AllTrim(Upper(cUserName))
						Endif
						cMsg += "[" + cUser + "]"
					Endif
					If ( lEnvironment )
						cMsg += "[" + GetEnvServer() + "|" + GetServerIP() + "]"			
					Endif
					If ( lRoutine )
						TRY EXCEPTION
							cRoutines 	:= "[" + getRoutinesInExecution(nRoutines,lLineRoutine) + "]"
							cMsg 		+= cRoutines
						CATCH EXCEPTION
							//Nada Faz
						END EXCEPTION					 	
					Endif
				Endif			
				
				cMsg += Space(01) + cMsgInf
				cMsg := OEMToAnsi(cMsg)
				cMsg := StrTran(cMsg,Space(02),Space(01))
				
				If ( !Empty(cMsg) )
					cRoutine := "CON"
					cRoutine += "OUT"
					cRoutine += "(cMsg)"

					&(cRoutine)
				EndIf
			Endif
		EndIf	
	Endif
		
Return

/*
	Checa se está sendo executado em JOB
*/
Static Function isInJob()
	Local lRet := .F.
	
	lRet := libOzminerals.u_isInJob()
	
Return lRet

/*
	Rotinas em Execução
*/
Static Function getRoutinesInExecution(nMaxRoutines,lLineRoutine)
	Local nCont				:= 0
	Local cRoutines			:= ""
	
	Default nMaxRoutines	:= 3

	nMaxRoutines += 2 //Despreza as Rotinas Atuais do CMGEN13       
	For nCont:=3 to nMaxRoutines
		
		cNameRoutine := ProcName(nCont)
		
		If !Empty(cNameRoutine)
			If !Empty(cRoutines)
				cRoutines += "|"
			Endif
			
			cRoutines += cNameRoutine
			If lLineRoutine
				cRoutines += "(" + AllTrim(AllToChar(ProcLine(nCont))) + ")"
			Endif
		Endif		
	Next nCont

Return cRoutines

/*
	Rotina Genérica para chamada do Log em Console
	Unificando o que era feito nas rotinas diretamente	
*/
User Function showLogInConsole(cMessage,lActive,cPrefixe,cRoutine,lVldImpExpData)
	
	Default cMessage 		:= ""
	Default cRoutine		:= ""
	Default lActive			:= IIF( Select("SX6") > 0 , GetNewPar("OZ_LOGS",.T.) ,.T. )
	Default cPrefixe		:= IIF(!Empty(cRoutine),"[" + cRoutine + "]","[" + ProcName(1) + "]") + "[" + DtoC(DDATABASE) + "][" + Time() + "] "
	Default lVldImpExpData	:= .F.
	
	If ( lActive )
		u_OZGEN18(cPrefixe + OEMToAnsi(cMessage),lDate:=.F.,lTime:=.F.,lCompany:=.T.,lUser:=.T.,lEnvironment:=.T.,lRoutine:=.F.,nRoutines:=0,lLineRoutine:=.F.)
	Endif
	
Return

/*
	Rotina para Apresentar Mensagens no Log do Console do Protheus
	Arquivo console.log no AppServer
	
	@param cMessage, character, Mensagem do Log
	@param cSeverity, character, Tipo de Severidade do Log, podendo ser INFO,WARN,ERROR,FATAL,DEBUG - Padrão: INFO
	@param cGroup, character, Grupo da Mensagem
	@param cCategory, character, Categoria da Mensagem
	@param cTransactionId, character, ID da Transação/Operação
	@param cStep, character, Passo da Transação/Operação
	@param cMsgId, character, ID da Mensagem
	@param nElapseTime, numeric, Tempo Decorrido
	@param aMessage, array, Mensagem em Vetor
	
	addLog(<cSeverity >, [ cTransactionId ], <cGroup >, <cCategory >, <cStep >, <cMsgId >, <cMessage >, <nMensure >, <nElapseTime >, <aMessage >)-> NIL

	Esta API refere-se a padronização da linha Microsiga Protheus sobre a 
	implementação da API LogMsg da Virtual Machine.

	1) O Id do agrupador da mensagem é um código padronizado entre todas as linhas de produto TOTVS e visa indentificar um agrupamento de mensagem relacionadas
	2) O Id da categoria da mensagem é uma sub-divisão do Id do agrupador da mensagem e é padronizado entre todas as linhas de produto TOTVS.
	3) O Id do passo da mensagem, indica uma etapa de avança de terminada transação que é monitorada. Pode ser ou não padronizada nas linhas de produto.
	4) O Id do código do mensagem é padronizado dentro da linha TOTVS
	5) A mensagem de log é livre, mas deve ser clara e simples
	6) A unidade de medida da mensagem é padronizada entre as linhas de produto TOTVS e visa fornecer um balanço de comparativo de tempo
	7) O tempo decorrido visa fornecer um parametro de desempenho do sistema em determinadas operações. Em alguns casos é padronizado.
*/
Static Function addLog(cMessage,cSeverity,cGroup,cCategory,cTransactionId,cStep,cMsgId,nElapseTime,aMessage)
	Default cMessage		:= ""	
	Default cSeverity		:= "INFO"	
	Default cGroup			:= "PERSONALIZACOES"
	Default cCategory		:= "01" //FunName()
	Default cTransactionId	:= FWUUIDV1() //"01"
	Default cStep			:= ""
	Default cMsgId			:= ""
	Default nMensure		:= 0
	Default nElapseTime		:= 0
	Default aMessage		:= {}

	FwLogMsg(cSeverity, cTransactionId, cGroup, cCategory, cStep, cMsgId, cMessage, nMensure, nElapseTime, aMessage)

Return
