#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWBROWSE.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'RWMAKE.CH'

/*/{Protheus.doc} RT99WF04
Realiza a reprova��o da solicita��o de compras e envia uma notIfica��o para o solicitante original. 
A regra � que basta um aprovador reprovar a solicita��o para todas as al�adas ca�rem.

@author 	Ricardo Tavares Ferreira
@since 		31/08/2018
@version 	12.1.17
@param 		xFil, char, Filial da solicita��o
@param 		cNumSC, char, N�mero da solicita��o
@param 		cObserv, char, Observa��o do aprovador
@param 		nRecnoSCR, int, Recno da SCR
@Return 	Nulo
@obs 		Ricardo Tavares - Construcao Inicial
/*/
//=======================================================================================
	User Function RT99WF04(xFil,cNumSC,cObserv,nRecnoSCR)	
//=======================================================================================

	Local aAreaC1 	:= SC1->(GetArea())
	Local aAreaCR 	:= SCR->(GetArea())
	Local cCodUsr 	:= ""
	Local cCodComp	:= ""
	Local cFunc		:= "RT99WF04"

	Default xFil 		:= ""
	Default cNumSC 		:= ""
	Default cObserv 	:= ""
	Default nRecnoSCR 	:= 0

	U_CONSOLE("Executando o processo de reprovacao de solicitacao...",cFunc)

	// posiciona no registro de al�ada da solicita��o
	DBSelectArea("SCR")
	SCR->(DbSetOrder(1))
	SCR->(DbGoTO(nRecnoSCR))

	U_CONSOLE("Valor do R_E_C_N_O_ (SCR)....: "+ cValToChar(nRecnoSCR),cFunc)
	
	// posiciona na solicita��o reprovada
	SC1->(DbSetOrder(1))

	If SC1->(DbSeek(xFil+cNumSC))

		cCodComp := Posicione("SY1",1,FWXFilial("SY1")+SC1->C1_CODCOMP,"Y1_USER")
		U_CONSOLE("Executando a reprovacao do aprovador " + SCR->CR_APROV + "...",cFunc)

		// indicando a reprova��o na al�ada
		MaAlcDoc({SCR->CR_NUM,SCR->CR_TIPO,SCR->CR_TOTAL,SCR->CR_APROV,,SC1->C1_XGRPAPR,,,,,cObserv},date(),6)
		
		// atualizando o registro da SC 
		cCodUsr := SC1->C1_USER
		While SC1->( .not. eof() .and. C1_FILIAL+C1_NUM == xFil+cNumSC)
			RecLock("SC1",.F.)
				SC1->C1_APROV := "R"
			SC1->(MsUnLock())
			SC1->(DbSkip())
		EndDo

		U_CONSOLE("NotIficando o usuario da reprovacao da solicitacao...",cFunc)
	
		// notIficando o usu�rio que abriu a solicita��o
		U_SIWKFD01("R",xFil,cNumSC,cCodUsr,cObserv,cCodComp)
		
	EndIf

	// restaura posicionamento das tabelas
	RestArea(aAreaCR)
	RestArea(aAreaC1)
Return