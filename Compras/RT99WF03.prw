#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWBROWSE.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'RWMAKE.CH'

/*/{Protheus.doc} RT99WF03
Realiza a aprovação da solicitação de compras.

@author 	Ricardo Tavares Ferreira
@since 		31/08/2018
@version 	12.1.17
@param 		xFil, char, Filial da solicitação
@param 		cNumSC, char, Número da solicitação
@param 		cObserv, char, Observação do aprovador
@param 		cRecnoSCR, int, Recno da SCR
@Return 	Nulo
@obs 		Ricardo Tavares - Construcao Inicial
/*/
//=======================================================================================
	User Function RT99WF03(xFil,cNumSC,cObserv,nRecnoSCR)	
//=======================================================================================

	Local aAreaC1 		:= SC1->( GetArea() )
	Local aAreaCR 		:= SCR->( GetArea() )
	Local lResult 		:= .F.
	Local cCodUsr 		:= ""
	Local cCodComp		:= ""
	Local cFunc			:= "RT99WF03"

	Default xFil 		:= ""
	Default cNumSC 		:= ""
	Default cObserv 	:= ""
	Default nRecnoSCR 	:= 0
	
	U_CONSOLE("Executando o processo de aprovacao...",cFunc)

	// posiciona no registro de alçada da solicitação
	DBSelectArea("SCR")
	SCR->(DbSetOrder(1))
	SCR->(DbGoTO(nRecnoSCR))

	U_CONSOLE("Valor do R_E_C_N_O_ (SCR)....: "+ cValToChar(nRecnoSCR),cFunc)

	// posiciona na solicitação reprovada
	SC1->( DbSetOrder(1) )
	If SC1->( DbSeek(xFil + cNumSC) )

		U_CONSOLE("Executando a aprovacao do aprovador " + SCR->CR_APROV + "...",cFunc)
		cCodUsr := SC1->C1_USER
		lResult := MaAlcDoc({SCR->CR_NUM,SCR->CR_TIPO,SCR->CR_TOTAL,SCR->CR_APROV,,SC1->C1_XGRPAPR,,,,,cObserv},date(),4)
		
		// se liberou todas as alçadas
		If lResult
			cCodComp := Posicione("SY1",1,FWXFilial("SY1")+SC1->C1_CODCOMP,"Y1_USER")	
			U_CONSOLE("Todos os niveis liberados. Atualiza a solicitacao...",cFunc)

			// atualizando o registro da SC 
			While SC1->( .not. eof() .and. C1_FILIAL + C1_NUM == xFil + cNumSC )
				
				U_CONSOLE("Atualizando status da Solicitacao de Compras...",cFunc)

				// Atualiza status da SC
				RecLock("SC1",.F.)
					SC1->C1_APROV := "L"
				SC1->(MsUnLock())
				SC1->(DbSkip())
			EndDo
			
			U_CONSOLE("Notificando o usuario da aprovacao total da solicitacao...",cFunc)
			U_SIWKFD01("A",xFil,cNumSC,cCodUsr,cObserv,cCodComp)
			
		Else
			U_CONSOLE("Envia a solicitacao para aprovacao em proximo nivel...",cFunc)
			U_RT99WF02(xFil,cNumSC)
		EndIf
	EndIf

	// restaura posicionamento das tabelas
	RestArea(aAreaCR)
	RestArea(aAreaC1)

Return 