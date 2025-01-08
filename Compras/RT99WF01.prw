#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWBROWSE.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'RWMAKE.CH'

/*/{Protheus.doc} RT99WF01
Função chamada no ponto de entrada que envia o Workflow da SC para aprovacao
@author 	Ricardo Tavares Ferreira
@since 		31/08/2018
@version 	12.1.17
@return 	Nulo
@obs 		Ricardo Tavares - Construcao Inicial
/*/
//=======================================================================================
	User Function RT99WF01(xFil,cNumSC)
//=======================================================================================

	Local aArea 	:= GetArea()
	Local cKeySol 	:= ""

	Private cFunc	:= "RT99WF01"
	Private oSay	:= Nil

	Default xFil 	:= ""
	Default cNumSC 	:= ""
	//Default lCopSC 	:= ""

	cKeySol := xFil+cNumSC

	SC1->(DbSetOrder(1))

	If SC1->(DbSeek(cKeySol)) //.and. .not. lCopSC
		If SC1->C1_APROV == "L" // verifica se ja foi liberado
			MsgInfo("Atenção",Capital("Esta solicitação já foi liberada, para reenviar é necessário bloquear a solicitação novamente!"))
			Return
		EndIf
	/*	If SC1->C1_WFE // verifica se o e-mail já foi enviado
			If Aviso("Atenção",Capital("Esta SC já foi Enviada Para aprovação, deseja enviar novamente ?"),{"Sim","Não"}) <> 1
				Return
			EndIf
		EndIf */
	EndIf

	U_CONSOLE("Enviando SC para Aprovacao...: "+Alltrim(cFilAnt)+"|"+Alltrim(cNumSC),cFunc)
	FWMsgRun(, {|oSay| U_RT99WF02(xFil,cNumSC,oSay)}, "Solicitação de Compras (Aprovação)", "Enviando SC para Aprovação...")

	RestArea(aArea)

Return 