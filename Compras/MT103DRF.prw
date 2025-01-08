/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MT103DRF �Autor  � Toni Aguiar        � Data �  27/09/16   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de Entrada utilizado na classifica��o da nota para   ���
���          � alterar Combobox da aba Impostos que informa se gera DIRF  ��� 
���          � e os c�digos de retencao                                   ���
�������������������������������������������������������������������������͹��
���Uso       � TOTVS STARSOFT                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/ 
User Function MT103DRF()
	Local nCombo := ParamixB[1] 
	Local cCodRet := ParamixB[2] 
	Local aImpRet := {}

	If SA2->A2_TIPO="J"
		nCombo  := 1 		// 1-Sim, gera DIRF
		cCodRet := "1708" 	//"1700"
		AADD(aImpRet,{"IRR",nCombo,cCodRet})

		nCombo  := 1		// 1-Sim, gera DIRF
		cCodRet := "5952" 	//"2008"
		AADD(aImpRet,{"PIS",nCombo,cCodRet}) 

		nCombo  := 1		// 1-Sim, gera DIRF
		cCodRet := "5952" 	//"2010"
		AADD(aImpRet,{"COF",nCombo,cCodRet}) 

		nCombo  := 1		// 1-Sim, gera DIRF
		cCodRet := "5952" 	//"2050"
		AADD(aImpRet,{"CSL",nCombo,cCodRet}) 
    ElseIf SA2->A2_TIPO="F"
		AADD(aImpRet,{"",2,""}) 
	Endif

	//-
	//- Lucas Costa - TOTVS STARSOFT em 17/05/2019
	//- Preenchimento da Aba Informa��es Adicionais para melhoria do registro D100 SPED.
	//- 
	
	aInfAdic[10] :=	Posicione("SA2",1,xfilial("SA2")+cA100For+cLoja,"A2_EST") // ESTADO DE ORIGEM | F1_UFORITR | 
	aInfAdic[11] :=	Posicione("SA2",1,xfilial("SA2")+cA100For+cLoja,"A2_COD_MUN") // MUNICIPIO DE ORIGEM | F1_MUORITR |	
	aInfAdic[12] :=	Posicione("SM0",1,cNumEmp,"M0_ESTENT") // ESTADO DE DESTINO | F1_UFDESTR |
	aInfAdic[13] :=	RIGHT(Posicione("SM0",1,cNumEmp,"M0_CODMUN"),5) // MUNICIPIO DE DESTINO	| F1_MUDESTR |
	
Return aImpRet