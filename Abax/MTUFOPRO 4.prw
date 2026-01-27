#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE 'TOTVS.CH'
#Define CRLF  CHR(13)+CHR(10)

//-------------------------------------------------------------------
/*/{Protheus.doc} MTUFOPRO

	Programa utilizado para realizar a integraÃ§Ã£o entre os sistemas
	UFO X Protheus. IntegraÃ§Ã£o serÃ¡ realizada atraves da tabela Z01
	Rotina responsavel pela geraÃ§Ã£o das Notas Fiscais de Entrada.
	@author 	Helder Santos
	@since		31.03.2014
	@version	P11

---------------------------------------------------------------------
Programador		Data		Motivo
---------------------------------------------------------------------

/*/

User Function MTUFOPRO(cEmpAbx, cFilAbx, cIdAbx)

	Local aEmpSmar := {}
	Local aInfo   := {}
	Local aTables := {"SA1","SA2","SF1","SD1","SF2","SD2","CTT","ZNF", "SF4","SB6","SB1","CT1","SE2",'SX6',}//seta as tabelas que serÃƒÂ£o abertas no rpcsetenv
	Local nI := 0
	Local nAbax := 0
	Private nStart := 0
	default cEmpAbx := '01'
	default cFilAbx := '01'
	default cIdAbx  := ''

	conout(" INICIO MTUFOPRO - ABRINDO AMBIENTES ")

	cError      := ""
	oLastError := ErrorBlock({|e| cError := e:Description + e:ErrorStack})

	If Empty(cIdAbx)


		aInfo := GetUserInfoArray()
		nI	  := 1
		For nI := 1 to Len(aInfo)
			If aInfo[nI][5] == "U_MTUFOPRO" .And. aInfo[nI][3] <> Threadid()

				FwLogMsg("INFO-ABAX", /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01", "Fun? MTUFOPRO sendo Utilizada.", 0, (nStart - Seconds()), {})

				Return
			EndIf
		Next nI

		//RpcSetEnv( '01','01', " ", " ", "COM", "MATA103", , , , ,  )
		//RpcSetEnv("01","01",,,,GetEnvServer(),{ })
		PREPARE ENVIRONMENT EMPRESA '01' FILIAL '01' MODULO "COM" FUNNAME "MATA103"

		cUsuSm := Space(1)
		cSenSm := Space(1)

		FWLogMsg(;
			"INFO",;    //cSeverity      - Informe a severidade da mensagem de log. As opï¿½ï¿½es possï¿½veis sï¿½o: INFO, WARN, ERROR, FATAL, DEBUG
			,;          //cTransactionId - Informe o Id de identificaï¿½ï¿½o da transaï¿½ï¿½o para operaï¿½ï¿½es correlatas. Informe "LAST" para o sistema assumir o mesmo id anterior
			"INTEGRADOR_ABAX",; //cGroup         - Informe o Id do agrupador de mensagem de Log
			,;          //cCategory      - Informe o Id da categoria da mensagem
			,;          //cStep          - Informe o Id do passo da mensagem
			,;          //cMsgId         - Informe o Id do cï¿½digo da mensagem
			"INICIO IMPORTAï¿½ï¿½O ï¿½BAX - FONTE MTUFOPRO - MATA103",;    //cMessage       - Informe a mensagem de log. Limitada ï¿½ 10K
			,;          //nMensure       - Informe a uma unidade de medida da mensagem
			,;          //nElapseTime    - Informe o tempo decorrido da transaï¿½ï¿½o
			;           //aMessage       - Informe a mensagem de log em formato de Array - Ex: { {"Chave" ,"Valor"} }
			)


		OpenSM0()
		dbSelectarea('SM0')
		SM0->(dbSetOrder(1))
		SM0->(dbGotop())

		Do While SM0->(!Eof())

			Aadd(aEmpSmar,{SM0->M0_CODIGO,SM0->M0_CODFIL})
			SM0->(dbSkip())

		Enddo

		RESET ENVIRONMENT

		cEmpABax := aEmpSmar[1][1]
		//RpcSetEnv( aEmpSmar[1][1],aEmpSmar[1][2],,, "COM", "MATA103", aTables, , , ,  )
		PREPARE ENVIRONMENT EMPRESA aEmpSmar[1][1] FILIAL aEmpSmar[1][2] MODULO "COM" FUNNAME "MATA103"

		nAbax:=1
		For nAbax:=1 to Len(aEmpSmar)

			If cEmpABax = aEmpSmar[nAbax][1]
				cFilAnt := aEmpSmar[nAbax][2]
				cEmpABax := aEmpSmar[nAbax][1]
			Else
				RESET ENVIRONMENT
				cEmpABax := aEmpSmar[nAbax][1]
				//RpcSetEnv( aEmpSmar[nAbax][1],aEmpSmar[nAbax][2]," " ," ", "COM", "MATA103", aTables, , , ,  )/****** COMANDOS *************/
				PREPARE ENVIRONMENT EMPRESA aEmpSmar[nAbax][1] FILIAL aEmpSmar[nAbax][2] MODULO "COM" FUNNAME "MATA103"
			Endif

			If CHKFILE("ZNF", .F.)

				FWLogMsg(;
					"INFO",;    //cSeverity      - Informe a severidade da mensagem de log. As opï¿½ï¿½es possï¿½veis sï¿½o: INFO, WARN, ERROR, FATAL, DEBUG
					,;          //cTransactionId - Informe o Id de identificaï¿½ï¿½o da transaï¿½ï¿½o para operaï¿½ï¿½es correlatas. Informe "LAST" para o sistema assumir o mesmo id anterior
					"INTEGRADOR_ABAX",; //cGroup         - Informe o Id do agrupador de mensagem de Log
					,;          //cCategory      - Informe o Id da categoria da mensagem
					,;          //cStep          - Informe o Id do passo da mensagem
					,;          //cMsgId         - Informe o Id do cï¿½digo da mensagem
					"INICIO IMPORTAï¿½ï¿½O ï¿½BAX - CHAMANDO FUNï¿½AO U_MImpNFs - MATA103",;    //cMessage       - Informe a mensagem de log. Limitada ï¿½ 10K
					,;          //nMensure       - Informe a uma unidade de medida da mensagem
					,;          //nElapseTime    - Informe o tempo decorrido da transaï¿½ï¿½o
					;           //aMessage       - Informe a mensagem de log em formato de Array - Ex: { {"Chave" ,"Valor"} }
					)


				U_MImpNFs(aEmpSmar[nAbax][1],aEmpSmar[nAbax][2],cUsuSm,cSenSm)
			Else

				FWLogMsg(;
					"ERROR",;    //cSeverity      - Informe a severidade da mensagem de log. As opï¿½ï¿½es possï¿½veis sï¿½o: INFO, WARN, ERROR, FATAL, DEBUG
					,;          //cTransactionId - Informe o Id de identificaï¿½ï¿½o da transaï¿½ï¿½o para operaï¿½ï¿½es correlatas. Informe "LAST" para o sistema assumir o mesmo id anterior
					"INTEGRADOR_ABAX",; //cGroup         - Informe o Id do agrupador de mensagem de Log
					,;          //cCategory      - Informe o Id da categoria da mensagem
					,;          //cStep          - Informe o Id do passo da mensagem
					,;          //cMsgId         - Informe o Id do cï¿½digo da mensagem
					"EMPRESA SEM TABELA ZNF CADASTRADA" + aEmpSmar[nAbax][1],;    //cMessage       - Informe a mensagem de log. Limitada ï¿½ 10K
					,;          //nMensure       - Informe a uma unidade de medida da mensagem
					,;          //nElapseTime    - Informe o tempo decorrido da transaï¿½ï¿½o
					;           //aMessage       - Informe a mensagem de log em formato de Array - Ex: { {"Chave" ,"Valor"} }
					)

			Endif

		Next

		FWLogMsg(;
			"INFO",;    //cSeverity      - Informe a severidade da mensagem de log. As opï¿½ï¿½es possï¿½veis sï¿½o: INFO, WARN, ERROR, FATAL, DEBUG
			,;          //cTransactionId - Informe o Id de identificaï¿½ï¿½o da transaï¿½ï¿½o para operaï¿½ï¿½es correlatas. Informe "LAST" para o sistema assumir o mesmo id anterior
			"INTEGRADOR_ABAX",; //cGroup         - Informe o Id do agrupador de mensagem de Log
			,;          //cCategory      - Informe o Id da categoria da mensagem
			,;          //cStep          - Informe o Id do passo da mensagem
			,;          //cMsgId         - Informe o Id do cï¿½digo da mensagem
			"FIM INTEGRAï¿½ï¿½O ï¿½BAX PROTHEUS - MATA103",;    //cMessage       - Informe a mensagem de log. Limitada ï¿½ 10K
			,;          //nMensure       - Informe a uma unidade de medida da mensagem
			,;          //nElapseTime    - Informe o tempo decorrido da transaï¿½ï¿½o
			;           //aMessage       - Informe a mensagem de log em formato de Array - Ex: { {"Chave" ,"Valor"} }
			)

		RESET ENVIRONMENT

	Else
		PREPARE ENVIRONMENT EMPRESA cEmpAbx FILIAL cFilAbx MODULO "COM"

		cUsuSm :=  Space(1)
		cSenSm := Space(1)
		U_MImpNFs(cEmpAbx,cFilAbx,cUsuSm,cSenSm)

		RESET ENVIRONMENT
	Endif

	FWLogMsg(;
		"INFO",;    //cSeverity      - Informe a severidade da mensagem de log. As opï¿½ï¿½es possï¿½veis sï¿½o: INFO, WARN, ERROR, FATAL, DEBUG
		,;          //cTransactionId - Informe o Id de identificaï¿½ï¿½o da transaï¿½ï¿½o para operaï¿½ï¿½es correlatas. Informe "LAST" para o sistema assumir o mesmo id anterior
		"INTEGRADOR_ABAX",; //cGroup         - Informe o Id do agrupador de mensagem de Log
		,;          //cCategory      - Informe o Id da categoria da mensagem
		,;          //cStep          - Informe o Id do passo da mensagem
		,;          //cMsgId         - Informe o Id do cï¿½digo da mensagem
		"INICIO INTEGRAï¿½ï¿½O ï¿½BAX PROTHEUS - MATA116",;    //cMessage       - Informe a mensagem de log. Limitada ï¿½ 10K
		,;          //nMensure       - Informe a uma unidade de medida da mensagem
		,;          //nElapseTime    - Informe o tempo decorrido da transaï¿½ï¿½o
		;           //aMessage       - Informe a mensagem de log em formato de Array - Ex: { {"Chave" ,"Valor"} }
		)

	U_MTCTEPRO() // Execu  o de importa  o de CTE pela rotina MATA116 Voltar Leo Viana 20170419

	FWLogMsg(;
		"INFO",;    //cSeverity      - Informe a severidade da mensagem de log. As opï¿½ï¿½es possï¿½veis sï¿½o: INFO, WARN, ERROR, FATAL, DEBUG
		,;          //cTransactionId - Informe o Id de identificaï¿½ï¿½o da transaï¿½ï¿½o para operaï¿½ï¿½es correlatas. Informe "LAST" para o sistema assumir o mesmo id anterior
		"INTEGRADOR_ABAX",; //cGroup         - Informe o Id do agrupador de mensagem de Log
		,;          //cCategory      - Informe o Id da categoria da mensagem
		,;          //cStep          - Informe o Id do passo da mensagem
		,;          //cMsgId         - Informe o Id do cï¿½digo da mensagem
		"FIM INTEGRAÃ‡ÃƒO Ã BAX PROTHEUS - MATA116",;    //cMessage       - Informe a mensagem de log. Limitada ï¿½ 10K
		,;          //nMensure       - Informe a uma unidade de medida da mensagem
		,;          //nElapseTime    - Informe o tempo decorrido da transaï¿½ï¿½o
		;           //aMessage       - Informe a mensagem de log em formato de Array - Ex: { {"Chave" ,"Valor"} }
		)
	RESET ENVIRONMENT

Return

User Function MImpNFs(cEmpMa,cFilMa,cUsusm,cSenSm)
	******************************************************************************
	* FunÃƒÂ§ÃƒÂ£o para importar  notas para o Protheus. Foi desmembrado a funÃƒÂ§ÃƒÂ£o devido
	* a empresas que possuem muitas empresas e filiais.
	******************************************************************************

	FwLogMsg("MImpNFs-ABAX", /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01",'PROCESSO IMPORTAÃƒâ€¡ÃƒÆ’O SMARTNFE - FONTE MTUFOPRO - Empresa ' +cEmpMa + ' Filial '+cFilMa, 0, (nStart - Seconds()), {})
	FwLogMsg("MImpNFs2-ABAX", /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01",'SIGAMAT.EMP ' + SM0->M0_CODIGO+'-'+SM0->M0_CODFIL, 0, (nStart - Seconds()), {})

	u_FSBusDados(cFilMa)

	dbSelectArea('ZNFTEMP')
	ZNFTEMP->(dbGoTop())

	If !Empty(ZNFTEMP->ZNF_DOC+ZNFTEMP->ZNF_SERIE+ZNFTEMP->ZNF_FORNEC+ZNFTEMP->ZNF_LOJA)
		/* Fun  o Gera NF de Entrada dentro do sistema Protheus*/
		U_FSGeraNFE()
		FwLogMsg("FIM PROCESSO IMPORTAÃ‡ÃƒO - ABAX", /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01",'FIM PROCESSO IMPORTAÃ‡ÃƒO SMARTNFE - FONTE MTUFOPRO - Empresa ' +cEmpMa + ' Filial '+cFilMa, 0, (nStart - Seconds()), {})
	Else
		FwLogMsg("FIM PROCESSO SEM MOVIMENTO - ABAX", /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01",'FIM PROCESSO SEM MOVIMENTO - FONTE MTUFOPRO - Empresa ' +cEmpMa + ' Filial '+cFilMa, 0, (nStart - Seconds()), {})
	Endif

	If Select('ZNFTEMP') > 0
		MPSysCloseQuery('ZNFTEMP')
		//dbSelectArea('ZNFTEMP')
		//dbCloseArea()
	Endif

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} FSBusDados

	Fun  o responsavel por buscar os dados a serem integrados
	Informa  es originadas diretamente do Sistema UFO
	@author 	Helder Santos
	@since		31.03.2014
	@Return		cPrefix - Alias carregado com as informaÃƒÂ§ÃƒÂµes
	@version	P11

---------------------------------------------------------------------
Programador		Data		Motivo
---------------------------------------------------------------------
/*/

User Function FSBusDados(cFilImp)

	Local cQryExc := ''

	FwLogMsg("FSBusDados 1 -ABAX", /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01",'SIGAMAT.EMP ' + SM0->M0_CODIGO+'-'+SM0->M0_CODFIL, 0, (nStart - Seconds()), {})

	cQryExc	:= ''

	cQryExc := CRLF +" SELECT * "
	cQryExc += CRLF +" FROM " + RetSQLName('ZNF') + " "
	cQryExc += CRLF +" WHERE ZNF_FILIAL = '" + Alltrim(cFilImp) +"' and "
	cQryExc += CRLF +" ZNF_TPLANC <> '2' "
	cQryExc += CRLF +" AND ZNF_STATUS = '1' "
	cQryExc += CRLF +" AND D_E_L_E_T_ <> '*' "
	cQryExc += CRLF +" ORDER BY ZNF_FILIAL, ZNF_DOC, ZNF_SERIE, ZNF_FORNEC "
	ZNFTEMP := MPSysOpenQuery(cQryExc, 'ZNFTEMP')


Return(ZNFTEMP)


//-------------------------------------------------------------------
/*/{Protheus.doc} FSGeraNFE

	FunÃƒÂ§ÃƒÂ£o responsavel pela geraÃƒÂ§ÃƒÂ£o da NFE dentro do sistema Protheus
	@author 	Helder Santos
	@since		31.03.2014
	@Parm1		cPrefix - Alias com as informaÃƒÂ§oes da NFE
	@version	P11

---------------------------------------------------------------------
Programador		Data		Motivo
---------------------------------------------------------------------
/*/

User Function FSGeraNFE(cPrefix)

	Local aAreaSB1	:= SB1->(GetArea())
	Local aAreaSF1	:= SF1->(GetArea())
	Local aAreaSD1	:= SD1->(GetArea())
	Local aAreaSF4	:= SF4->(GetArea())

	Local __cLogMsg	:= ''
	Local __cSeekNF	:= ''
	Local lImport	:= .F.
	Local cEspecie	:= ''
	Local lOrigem	:= .F.
	Local aLog		:= {}
	Local cLocSB6	:= ''
	Local cLocSC7	:= ''  //Declara  o VariÃƒÂ¡vel.
	Local aItensRat := {}

	Private aCabec     := {} // ALTERADO DE LUGAR
	Private  cTpLanc   := ''
	Private _aCabSF1   		:= {}
	Private _aLinha	   	:= {}
	Private _aItensSD1		:= {}
	Private aCodRet	 		:= {} //cÃ³digo de retenÃ§Ã£o IR
	Private lMsErroAuto		:= .F.
	Private lAutoErrNoFile  := .T. //<= para nao gerar arquivo e pegar o erro com a funcao GETAUTOGRLOG()
	Private nTotItem		:= 1 // 20/08/2015 -Criado vÃƒÂ¡riÃƒÂ¡vel nTotItem para contar quantos itens a Nota Possui
	Private nFretAbax		:= 0     //09/12/2016 - Criado para totalizar o frete do Pedido de Compra.
	Private nVBrtAbax		:= 0        //Valor Bruto Nota Fiscal
	Private cCondAbax    := Space(3) //Condicao de pagamento
	Private dDtVAbax		:= dDatabase
	Private cMAVenc		:= Space(250) //String com dados do vencimento.
	Private cRecIss	   := Space(1)
	Private cSerDES		:= Space(1) //06/10/2017 - Campo par fazer De Para da DESBH
	Private nBolAbax		:= 1			// 27/09/2017 - Leonardo Vasco - Melhoria Oncoclinicas -
	Private aBolAbax 		:= {}       // 27/09/2017 - Leonardo Vasco - Melhoria Oncoclinicas - Campo utilizado para gravar os cÃƒÂ³digos de barras dos boletos
	Private nToItem      := 0 //Leonardo Viana 09/01/2018 - Total de Itens a serem importados. Melhoria para sÃƒÂ³ importar quando todos os itens forem enviados para a ZNF.
	Private nTotAbax     := 0  //Leonardo Viana 09/01/2018 - Total de Itens a serem importados. Melhoria para sÃƒÂ³ importar quando todos os itens forem enviados para a ZNF.
	Private lErroAba     := .F. //Leonardo Viana 09/01/2018 - Total de Itens a serem importados. Tratamento para nÃƒÂ£o executar Execauto caso ocorra problema de exportaÃƒÂ§ÃƒÂ£o para a ZNF.
	Private cBancAba     := '' //InformaÃƒÂ§ÃƒÂµes referentes aos dados bancÃƒÂ¡rios.
	Private cAgenAba     := '' // Estas variÃƒÂ¡veis poderÃƒÂ£o ser utilizadas nos pontos de entradas
	Private cContAba     := ''	// no momento de gerar os tÃƒÂ­tulos a pagar.
	Private cTipFret     := '' //Tipo do Frete
	Private lDtVAbax     := .F.//Variaveis novas Dic no banco
	Private lLOCSB6		 := .F. //Variaveis novas Dic no banco
	Private cSitTrib     := ''  // situaÃ§Ã£o tributÃ¡ria da TES
	Private nBTotIPI     := 0 //Base total do IPI
	Private nVTotIPI     := 0 //Valor Total do IPI
	Private nPIPI        := 0 //Percentual de IPI
	Private aAutoImp     := {} //Array de envio de Impostos IPI
	Private nDescTot	 := 0  //Soma dos descontos por item, para inserir no campo F1_DESCONT

	Private cDiaIss := Alltrim(GetMV("MV_DIAISS"))
	Private cAltPrcc := Alltrim(GetMV("MV_ALTPRCC"))

	Private aNatRend     := {} //Mateus 01/11/23 - Natureza de Rendimento
	Private aItensDHR    := {}

	cError := ''

	PutMV("MV_ALTPRCC","0") //Desabilitar parÃ¢metro que obriga o valor da nota fiscal ser igual ao valor do pedido de compra. NÃ£o tem relaÃ§Ã£o com margem de tolerÃ¢ncia.

	FwLogMsg("DENTRO FSGeraNFE 1 - ABAX", /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01",'FIM PROCESSO IMPORTAÃƒâ€¡ÃƒÆ’O SMARTNFE - FONTE MTUFOPRO - Empresa ' , 0, (nStart - Seconds()), {})
	nZ:=1
	dbSelectArea('ZNFTEMP')

	ZNFTEMP->(dbGoTop())

	if SuperGetMV('MA_VENABAX',.F.,.T.)
		lDtVAbax := .T.
	Endif

	If SuperGetMV('MA_LOCSB6',.F.,.T.)
		lLOCSB6 := .T.
	Endif

	Do While ZNFTEMP->(!Eof())

		cFilAnt	:= ZNFTEMP->ZNF_FILIAL

		nToItem++

		__cSeekNF:=ZNFTEMP->ZNF_DOC+ZNFTEMP->ZNF_SERIE+ZNFTEMP->ZNF_FORNEC+ZNFTEMP->ZNF_LOJA

		cDocSMA := ZNFTEMP->ZNF_DOC
		cSerSMA := ZNFTEMP->ZNF_SERIE
		cForSMA := ZNFTEMP->ZNF_FORNEC
		cLojSMA := ZNFTEMP->ZNF_LOJA

		cTpLanc := Alltrim(ZNFTEMP->ZNF_TPLANC)

		If ZNFTEMP->ZNF_TIPO $ 'N_I_P_C'
			SA2->(dbSetorder(01))
			SA2->(dbSeek(xFilial('SA2')+(ZNFTEMP->ZNF_FORNEC)+Alltrim(ZNFTEMP->ZNF_LOJA) ))
			cEstSM := SA2->A2_EST
			If Empty(ZNFTEMP->ZNF_COND)
				cConPAba := Alltrim(SA2->A2_COND)
			Else
				cConPAba := ZNFTEMP->ZNF_COND
			Endif
		Else    //B ou D
			SA1->(dbSetorder(01))
			SA1->(dbSeek(xFilial('SA1')+ZNFTEMP->ZNF_FORNEC+ZNFTEMP->ZNF_LOJA ))
			cEstSM := SA1->A1_EST
			If Empty(ZNFTEMP->ZNF_COND)
				cConPAba := Alltrim(SA1->A1_COND)
			Else
				cConPAba := ZNFTEMP->ZNF_COND
			Endif
		Endif

		/*N = Nf Normal
		D = DevoluÃƒÂ§ÃƒÂ£o
		I = NF Compl. ICMS
		P = NF Compl. IPI
		C = Complemento
		B = Beneficiamento.*/


		dbSelectArea('SC7')
		SC7->(dbSetOrder(01))
		If Empty(ZNFTEMP->ZNF_EMP)
			SC7->(dbSeek(xFilial('SC7')+ZNFTEMP->ZNF_PEDIDO+Alltrim(ZNFTEMP->ZNF_ITEMPC)))
		Else
			SC7->(dbSeek(ZNFTEMP->ZNF_EMP+ZNFTEMP->ZNF_PEDIDO+Alltrim(ZNFTEMP->ZNF_ITEMPC)))
		Endif
		cLocSC7 := SC7->C7_LOCAL
		cCCSC7  := SC7->C7_CC //Vari vel para pegar Centro de Custo do Produto

		If !lImport

			FwLogMsg("INFO-ABAX", /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01",'MTUFOPRO - IMPORTANDO NOTA  '+ ZNFTEMP->ZNF_DOC+'-'+ ZNFTEMP->ZNF_SERIE+'-'+ZNFTEMP->ZNF_FORNEC+'-'+ZNFTEMP->ZNF_LOJA, 0, (nStart - Seconds()), {})

			If ZNFTEMP->ZNF_ESPEC == 'NFE'
				cEspecie	:= 'SPED'
			Else
				cEspecie	:= ZNFTEMP->ZNF_ESPEC
			Endif

			nTotItem    := 1
			nValFreA     := ZNFTEMP->ZNF_FRETE	 //Valor total do Frete
			/* Carrega informa  es do cabe alho da Nota Fiscal*/
			Aadd(_aCabSF1,{"F1_FILIAL"   ,cFilAnt									,Nil})
			Aadd(_aCabSF1,{"F1_FORMUL"   ,"N" 		  								,Nil})
			Aadd(_aCabSF1,{"F1_TIPO"     ,ZNFTEMP->ZNF_TIPO				  				,Nil}) 	// SerÃƒÂ¡ buscado o tipo da ZNF e nÃƒÂ£o mais como N
			Aadd(_aCabSF1,{"F1_DOC"      ,ZNFTEMP->ZNF_DOC    			   			,Nil})
			Aadd(_aCabSF1,{"F1_SERIE"    ,ZNFTEMP->ZNF_SERIE  			   			,Nil})
			Aadd(_aCabSF1,{"F1_EMISSAO"  ,Stod(ZNFTEMP->ZNF_EMISSA) 	  				,Nil})

			if !Empty(ZNFTEMP->ZNF_DTDIGI)
				DDATABASE:=Stod(ZNFTEMP->ZNF_DTDIGI)
			Endif

			Aadd(_aCabSF1,{"F1_DTDIGIT"  ,DDATABASE			,Nil})

			Aadd(_aCabSF1,{"F1_FORNECE"  ,ZNFTEMP->ZNF_FORNEC			  			,Nil})	//SA2->A2_COD
			Aadd(_aCabSF1,{"F1_LOJA"     ,Alltrim(ZNFTEMP->ZNF_LOJA)  			 	,Nil})	//SA2->A2_LOJA    		,Nil})
			Aadd(_aCabSF1,{"F1_ESPECIE"  ,Alltrim(cEspecie)							,Nil})
			Aadd(_aCabSF1,{"F1_DESPESA"  ,ZNFTEMP->ZNF_DESPES			   		,Nil})

			If cTpLanc <> 'P'
				Aadd(_aCabSF1,{"F1_COND"     ,cConPAba 			  			 		  	,Nil})  // Caso o campo ZNF_COND esteja vazio, pegarÃƒÂ¡ essa informaÃƒÂ§ÃƒÂ£o do cadastro do Cliente/Fornecedor
			Endif
			If Alltrim(cEspecie) == 'CTE'

				If Empty(Alltrim(ZNFTEMP->ZNF_TPCTE))
					Aadd(_aCabSF1,{"F1_TPCTE"    ,Alltrim(ZNFTEMP->ZNF_TIPO)   			,Nil}) 	//
				Else
					Aadd(_aCabSF1,{"F1_TPCTE"    ,ZNFTEMP->ZNF_TPCTE             	   , Nil})//  - C - 1 - Tipo do CTE - N=Normal;C=Complem.Valores;A=Anula.Valores;S=Substituto
				Endif

				dbSelectArea('SF1')

				If FieldPos("F1_TPFRETE") > 0
					Aadd(_aCabSF1,{"F1_TPFRETE"    ,Alltrim(ZNFTEMP->ZNF_TPFRET)		,Nil})     //Enviar tipo de Frete para o ERP.
				Endif

			Endif

			Aadd(_aCabSF1,{"F1_EST"      ,cEstSM			    						,Nil})  //Estado do Cliente ou do Fornecedor


			Aadd(_aCabSF1,{"F1_CHVNFE"   ,ZNFTEMP->ZNF_CHVNFE   		   			,Nil})
			Aadd(_aCabSF1,{"F1_VOLUME1"  ,ZNFTEMP->ZNF_VOLUME  		   			    ,Nil})
			Aadd(_aCabSF1,{"F1_DESCONT"  ,ZNFTEMP->ZNF_DESC	   		                ,Nil})

			dbSelectArea('SF1')
			If FieldPos("F1_USUSMAR") > 0
				Aadd(_aCabSF1,{"F1_USUSMAR"  ,ZNFTEMP->ZNF_USERLG			   		,Nil})
			Endif

			If FieldPos("F1_ZUSER") > 0
				Aadd(_aCabSF1,{"F1_ZUSER"    ,Substr(ZNFTEMP->ZNF_USERLG,1,25)		,Nil})
			Endif

			If cTpLanc <> 'P'
				If FieldPos("F1_XMODNF") > 0
					Aadd(_aCabSF1,{"F1_XMODNF"    ,Alltrim(ZNFTEMP->ZNF_MODNF)		 	,Nil}) 	//DESBH
				Endif

				If FieldPos("F1_MODNF") > 0
					Aadd(_aCabSF1,{"F1_MODNF"    ,Alltrim(ZNFTEMP->ZNF_MODNF)		 	,Nil}) 	//DESBH
				Endif
			Endif

			If Alltrim(cEspecie) = 'CTE'

				Aadd(_aCabSF1,{"F1_TPCTE"    ,ZNFTEMP->ZNF_TIPO		   		,Nil})

				Aadd(_aCabSF1,{"F1_MODAL"    ,Alltrim(ZNFTEMP->ZNF_MODAL)	,Nil})

				If FieldPos("F1_MUORITR") > 0
					Aadd(_aCabSF1,{"F1_MUORITR"    ,ZNFTEMP->ZNF_MUORIT			,Nil})
				Endif

				If FieldPos("F1_UFORITR") > 0
					Aadd(_aCabSF1,{"F1_UFORITR"    ,ZNFTEMP->ZNF_UFORIT			,Nil})
				Endif

				If FieldPos("F1_MUDESTR") > 0
					Aadd(_aCabSF1,{"F1_MUDESTR"    ,ZNFTEMP->ZNF_MUDEST			,Nil})
				Endif

				If FieldPos("F1_UFDESTR") > 0
					Aadd(_aCabSF1,{"F1_UFDESTR"    ,ZNFTEMP->ZNF_UFDEST			,Nil})
				Endif

			Endif

			If FieldPos("F1_DTCPISS") > 0
				AAdd(aCabec, {"F1_DTCPISS",    Stod(ZNFTEMP->ZNF_EMISSA) 		,Nil})
			Endif

			If Empty(ZNFTEMP->ZNF_CHVNFE)  .AND. cTpLanc <> 'P'
				Do Case
					Case Alltrim(ZNFTEMP->ZNF_SERIE) = '0'
						cSerDES = '0'
					Case Alltrim(ZNFTEMP->ZNF_SERIE) = 'U'
						cSerDES = '1'
					Case Alltrim(ZNFTEMP->ZNF_SERIE) = 'A'
						cSerDES = '2'
					Case Alltrim(ZNFTEMP->ZNF_SERIE) = 'AA'
						cSerDES = '3'
					Case Alltrim(ZNFTEMP->ZNF_SERIE) = 'B'
						cSerDES = '4'
					Case Alltrim(ZNFTEMP->ZNF_SERIE) = 'C'
						cSerDES = '5'
					Case Alltrim(ZNFTEMP->ZNF_SERIE) = 'E'
						cSerDES = '7'
				Endcase

				If FieldPos("F1_SERIEDS") > 0
					Aadd(_aCabSF1,{"F1_SERIEDS"  ,Alltrim(cSerDES)					,Nil})
				Endif

				If FieldPos("F1_XSERIED") > 0
					Aadd(_aCabSF1,{"F1_XSERIED"  ,Alltrim(cSerDES)					,Nil})
				Endif

			Endif

			If ZNFTEMP->ZNF_FRETE > 0
				Aadd(_aCabSF1,{"F1_FRETE"    ,ZNFTEMP->ZNF_FRETE					,Nil}) 	//Leonardo Viana 20161116 - Tratar Frete da Nota Fiscal.
			Endif

			If ZNFTEMP->ZNF_PBRUTO > 0
				Aadd(_aCabSF1,{"F1_PBRUTO"   ,ZNFTEMP->ZNF_PBRUTO						,Nil})
			Endif

			If ZNFTEMP->ZNF_PLIQUI > 0
				Aadd(_aCabSF1,{"F1_PLIQUI"   ,ZNFTEMP->ZNF_PLIQUI						,Nil})
			Endif

			If !Empty(ZNFTEMP->ZNF_RECBMT)
				Aadd(_aCabSF1,{"F1_RECBMTO"  ,Stod(ZNFTEMP->ZNF_RECBMT)	   			    ,Nil})
			Endif

			If cTpLanc <> 'P'
				If !Empty(ZNFTEMP->ZNF_INCISS)
					Aadd(_aCabSF1,{"F1_INCISS"   ,ZNFTEMP->ZNF_INCISS				   		,Nil})  //CÃ³digo do Municipio IBGE
				Endif
			Endif

			If !Empty(ZNFTEMP->ZNF_INCISS)
				Aadd(_aCabSF1,{"F1_ESTPRES"  ,ZNFTEMP->ZNF_ESTPRE				   		,Nil})  //Estado do Municipio
			Endif

			dbSelectArea('ZNFTEMP')

			If Alltrim(cEspecie) = 'CTE'
				If (ZNFTEMP->(FieldPos("ZNF_MODAL"))) > 0
					Aadd(_aCabSF1,{"F1_MODAL"    ,ZNFTEMP->ZNF_MODAL				,Nil})
				Endif
			Endif

			If (ZNFTEMP->(FieldPos("ZNF_SEGUR"))) > 0 //!Empty(cUsaCampo)
				cBancAba  := Alltrim(ZNFTEMP->ZNF_SEGUR)
				Aadd(_aCabSF1,{"F1_SEGURO"  ,ZNFTEMP->ZNF_SEGUR				   		,Nil})  //Se a Nota Fiscal Tiver o campo seguro preenchido serÃƒÂ¡ enviado ao ERP.
			Endif

			If (ZNFTEMP->(FieldPos("ZNF_CNPJEN"))) > 0
				Aadd(_aCabSF1,{"F1_XCNPJEN"  ,ZNFTEMP->ZNF_CNPJEN			   		,Nil})  //Se a Nota Fiscal Tiver o campo seguro preenchido serÃƒÂ¡ enviado ao ERP.
			Endif

			If cTpLanc <> 'P'

				cRecIss := ZNFTEMP->ZNF_RECISS
				If !empty(ZNFTEMP->ZNF_RECISS)
					Aadd(_aCabSF1,{"F1_RECISS"   ,ZNFTEMP->ZNF_RECISS						,Nil})
				Endif

				If !Empty(Alltrim(ZNFTEMP->ZNF_DIRF))

					Aadd(_aCabSF1,{"E2_DIRF"    ,'1'										,Nil})
					Aadd(_aCabSF1,{"E2_CODRET"  ,Alltrim(ZNFTEMP->ZNF_DIRF)				    ,Nil})

					//Array contendo a informaÃ§Ã£o se gera DIRF e os cÃ³digos de retenÃ§Ã£o por imposto
					aAdd( aCodRet, {01, Alltrim(ZNFTEMP->ZNF_DIRF), 1, "..."} )
					aAdd( aCodRet, {02, Alltrim(ZNFTEMP->ZNF_DIRF), 1, "IRR"} )
					aAdd( aCodRet, {03, "5979", 1  , "PIS"} )
					aAdd( aCodRet, {04, "5960", 1  , "COF"} )
					aAdd( aCodRet, {05, "5987", 1  , "CSL"} )
				Else
					Aadd(_aCabSF1,{"E2_DIRF"    ,'2'											,Nil})
				Endif

			Endif

			//--Variaveis publicas
			nVBrtAbax	:=	ZNFTEMP->ZNF_VLBRUT -  ZNFTEMP->ZNF_DESC		//Valor Bruto Nota Fiscal
			cCondAbax   := ZNFTEMP->ZNF_COND    			//Condicao de pagamento
			cMAVenc	   :=  Alltrim(ZNFTEMP->ZNF_MAVENC)  //String com alteraÃƒÂ§ÃƒÂµes do vencimento.

			if lDtVAbax  //Se .T. ira considerar data de emissao
				dDtVAbax := Stod(ZNFTEMP->ZNF_EMISSA)
			Else
				dDtVAbax := dDataBase //Se 2 ira considerar data base
			Endif

			cCondicao := ZNFTEMP->ZNF_COND
			If ZNFTEMP->ZNF_TIPO $ 'N_I_P_C'

				If cTpLanc <> 'P'
					If AllTrim(ZNFTEMP->ZNF_NATUR) == "000000"
						Aadd(_aCabSF1,{"E2_NATUREZ"  ,"      "  ,Nil})
					Else
						Aadd(_aCabSF1,{"E2_NATUREZ"  ,ZNFTEMP->ZNF_NATUR  ,Nil})  // IncluÃƒÂ­do tratamento Natureza Financeira 292 04/09/2015
					EndIf
				Endif

			Endif

			If (ZNFTEMP->ZNF_ESPEC = 'NFSE' .or. ZNFTEMP->ZNF_ESPEC = 'NFPS') .and. cTpLanc <> 'P' // IncluÃƒÂ­do tratamento de Fornecedor de ISS e Loja ISS

				cMesIss := alltrim(str(Month(dDataBase)+ 1))
				cAnoIss := alltrim(str(Year(dDataBase)))

				If !Empty(cDiaIss)
					dDatISS := Ctod(cDiaIss+'/'+cMesIss+'/'+cAnoIss)
				Else
					dDatISS := Ctod('10/'+cMesIss+'/'+cAnoIss)
				Endif
				If !Empty(ZNFTEMP->ZNF_FORISS)
					Aadd(_aCabSF1,{"E2_FORNISS"  ,ZNFTEMP->ZNF_FORISS  ,Nil})
					Aadd(_aCabSF1,{"E2_LOJISS"   ,ZNFTEMP->ZNF_LOJISS  ,Nil})
					Aadd(_aCabSF1,{"E2_VENISS"   ,dDatISS			   ,Nil})
				Endif

			Endif

			dbSelectArea('ZNFTEMP')
			If (ZNFTEMP->(FieldPos("ZNF_SEGUR"))) > 0 //!Empty(cUsaCampo)
				cBancAba  := Alltrim(ZNFTEMP->ZNF_SEGUR)
			Endif

			If (ZNFTEMP->(FieldPos("ZNF_BANCO"))) > 0 //!Empty(cUsaCampo)
				cBancAba  := Alltrim(ZNFTEMP->ZNF_BANCO)
			Endif

			If (ZNFTEMP->(FieldPos("ZNF_AGENC") > 0))  //!Empty(cUsaCampo)
				cAgenAba	:= Alltrim(ZNFTEMP->ZNF_AGENC)
			Endif

			If (ZNFTEMP->(FieldPos("ZNF_CONTAB"))) > 0 //!Empty(cUsaCampo)
				cContAba := Alltrim(ZNFTEMP->ZNF_CONTAB)
			Endif
			//
			If (ZNFTEMP->(FieldPos("ZNF_BOLETO"))) > 0 //!Empty(Alltrim((cPrefix)->ZNF_BOLETO))
				aBolAbax := Strtokarr(Alltrim(ZNFTEMP->ZNF_BOLETO),'|')
			Endif


			If (ZNFTEMP->(FieldPos("ZNF_EMINFE"))) > 0
				if !Empty(Alltrim(ZNFTEMP->ZNF_EMINFE))
					Aadd(_aCabSF1,{"F1_EMINFE"  ,Stod(ZNFTEMP->ZNF_EMINFE)   			,Nil})
				Endif
			Endif

			If (ZNFTEMP->(FieldPos("ZNF_NFELET"))) > 0
				if !Empty(Alltrim(ZNFTEMP->ZNF_NFELET))
					Aadd(_aCabSF1,{"F1_NFELETR"  ,Alltrim(ZNFTEMP->ZNF_NFELET)  			,Nil})
				Endif
			Endif

			If (ZNFTEMP->(FieldPos("ZNF_CODNFE"))) > 0
				if !Empty(Alltrim(ZNFTEMP->ZNF_CODNFE))
					Aadd(_aCabSF1,{"F1_CODNFE"  ,Alltrim(ZNFTEMP->ZNF_CODNFE)   			,Nil})
				Endif
			Endif

			If (ZNFTEMP->(FieldPos("ZNF_HORNFE"))) > 0
				if !Empty(Alltrim(ZNFTEMP->ZNF_HORNFE))
					Aadd(_aCabSF1,{"F1_HORNFE"  ,Alltrim(ZNFTEMP->ZNF_HORNFE)   			,Nil})
				Endif
			Endif

			If (ZNFTEMP->(FieldPos("ZNF_HASH"))) > 0
				Aadd(_aCabSF1,{"F1_ZNUMECB"  ,Alltrim(ZNFTEMP->ZNF_HASH)   			,Nil})
			Endif

			aAdd(_aCabSF1, {"VLDAMNFE"       ,       "N"                            ,Nil})

			lImport:=.T.

		EndIf

		_aLinha:={}

		dbSelectArea('SB1')
		SB1->(dbSetOrder(01))
		SB1->(dbSeek(xFilial('SB1')+ZNFTEMP->ZNF_COD))

		Aadd(_aLinha,{"D1_FILIAL"	,cFilAnt     						 ,Nil})
		Aadd(_aLinha,{"D1_ITEM"     ,STRZERO(nTotItem++,4)  		 ,Nil}) //
		Aadd(_aLinha,{"D1_COD"      ,Alltrim(SB1->B1_COD)		    ,Nil}) //Alltrim((cPrefix)->ZNF_COD tIREI PEDIDOS DA LINHA DE BAIXO

		If ZNFTEMP->ZNF_TIPO $ 'N_I_P_C'
			If !Empty(ZNFTEMP->ZNF_PEDIDO)
				Aadd(_aLinha,{"D1_PEDIDO"   ,Alltrim(ZNFTEMP->ZNF_PEDIDO) ,Nil})
				Aadd(_aLinha,{"D1_ITEMPC"   ,Alltrim(ZNFTEMP->ZNF_ITEMPC) ,Nil})
			Endif
		Endif

		If !ZNFTEMP->ZNF_TIPO $ 'I/P/C'
			Aadd(_aLinha,{"D1_QUANT"    ,ZNFTEMP->ZNF_QUANT   ,Nil})
		EndIf

		If !(ZNFTEMP->ZNF_TIPO $ 'I/P/C') .or. !ZNFTEMP->ZNF_TIPO == 'P'  .or. !ZNFTEMP->ZNF_TIPO == 'C'
			Aadd(_aLinha,{"D1_VUNIT"    ,ZNFTEMP->ZNF_VUNIT   	,Nil})
			Aadd(_aLinha,{"D1_TOTAL"    ,ZNFTEMP->ZNF_TOTAL   	,Nil})
		Else
			Aadd(_aLinha,{"D1_TOTAL"    ,ZNFTEMP->ZNF_TOTAL   		,Nil})
		EndIf

		If !(ZNFTEMP->ZNF_TIPO $ 'B/D')

			If !Empty(ZNFTEMP->ZNF_NFORI)

				If !(ZNFTEMP->ZNF_TIPO $ 'I_P_C')
					dbSelectArea('SD2')
					SD2->(dbSetOrder(03))
					SD2->(dbSeek(xFilial('SD2')+ALLTRIM(ZNFTEMP->ZNF_NFORI)+SUBSTR(ZNFTEMP->ZNF_SERORI,1,3)+SA2->A2_COD+SA2->A2_LOJA+Substr(ZNFTEMP->ZNF_COD,1,TamSX3("D2_COD")[1])+ZNFTEMP->ZNF_ITEORI))

					If !Eof()
						Aadd(_aLinha,{"D1_NFORI"  	,SD2->D2_DOC		,Nil})
						Aadd(_aLinha,{"D1_SERIORI"	,SD2->D2_SERIE		,Nil})
						Aadd(_aLinha,{"D1_ITEMORI"	,SD2->D2_ITEM		,Nil})
						Aadd(_aLinha,{"D1_LOTECTL"	,SD2->D2_LOTECTL	,Nil})
						Aadd(_aLinha,{"D1_DTVALID"	,SD2->D2_DTVALID	,Nil})
						lOrigem := .T.
					Endif

					dbSelectArea('SB6')
					SB6->(dbSetOrder(01))

					SB6->(dbSeek(xFilial('SB6')+Substr(ZNFTEMP->ZNF_COD,1,TamSX3("B6_PRODUTO")[1])+SA2->A2_COD+SA2->A2_LOJA+SD2->D2_IDENTB6))


					If !Eof()
						cLocSB6 := SB6->B6_LOCAL
						Aadd(_aLinha,{"D1_IDENTB6"  	,SB6->B6_IDENT						,Nil})
					Endif
				Else
					Aadd(_aLinha,{"D1_NFORI"  	,ALLTRIM(ZNFTEMP->ZNF_NFORI)			,Nil})
					Aadd(_aLinha,{"D1_SERIORI"	,SUBSTR(ZNFTEMP->ZNF_SERORI,1,3)		,Nil})
				Endif

			Else

				If ZNFTEMP->ZNF_TIPO == 'I' .And. Substr(Posicione("SF4",1,xFilial("SF4")+ZNFTEMP->ZNF_TES,"F4_CF"),2,3) == '602'
					Aadd(_aLinha,{"D1_NFORI"  	,"999999999"		,Nil})
					Aadd(_aLinha,{"D1_SERIORI"  ,"   "		,Nil})
				EndIf

			Endif
		Else
			If !Empty(ZNFTEMP->ZNF_NFORI)
				dbSelectArea('SD2')
				SD2->(dbSetOrder(03))

				aRet := TamSX3("D2_COD")
				nQtdAba := aRet[1]
				cCodAba := Substr(ZNFTEMP->ZNF_COD,1,	nQtdAba)

				SD2->(dbSeek(xFilial('SD2')+ALLTRIM(ZNFTEMP->ZNF_NFORI)+SUBSTR(ZNFTEMP->ZNF_SERORI,1,3)+SA1->A1_COD+SA1->A1_LOJA+cCodAba+ZNFTEMP->ZNF_ITEORI))

				If !Eof()
					Aadd(_aLinha,{"D1_NFORI"  	,SD2->D2_DOC		,Nil})
					Aadd(_aLinha,{"D1_SERIORI"	,SD2->D2_SERIE		,Nil})
					Aadd(_aLinha,{"D1_ITEMORI"	,SD2->D2_ITEM		,Nil})
					Aadd(_aLinha,{"D1_LOTECTL"	,SD2->D2_LOTECTL	,Nil})
					Aadd(_aLinha,{"D1_DTVALID"	,SD2->D2_DTVALID	,Nil})
					lOrigem := .T.
				Endif

				dbSelectArea('SB6')
				SB6->(dbSetOrder(01))

				aRet := TamSX3("B6_PRODUTO")
				nQtdAba := aRet[1]
				SB6->(dbSeek(xFilial('SB6')+Substr(ZNFTEMP->ZNF_COD,1,nQtdAba)+SA1->A1_COD+SA1->A1_LOJA+SD2->D2_IDENTB6))

				If !Eof()
					Aadd(_aLinha,{"D1_IDENTB6"  	,SB6->B6_IDENT		,Nil})
				Endif
			EndIf
		Endif

		dbSelectArea('SC7')
		SC7->(dbSetOrder(01))
		If Empty(ZNFTEMP->ZNF_EMP)
			SC7->(dbSeek(xFilial('SC7')+ZNFTEMP->ZNF_PEDIDO+Alltrim(ZNFTEMP->ZNF_ITEMPC)))
		Else
			SC7->(dbSeek(ZNFTEMP->ZNF_EMP+ZNFTEMP->ZNF_PEDIDO+Alltrim(ZNFTEMP->ZNF_ITEMPC)))
		Endif

		cLocSC7 	 := SC7->C7_LOCAL
		cCCSC7       := SC7->C7_CC

		If !Empty(ZNFTEMP->ZNF_LOCAL)
			Aadd(_aLinha,{"D1_LOCAL"  ,ZNFTEMP->ZNF_LOCAL 	 								,Nil})
		Else
			If !Empty(cLocSB6)
				If lLOCSB6
					Aadd(_aLinha,{"D1_LOCAL"  ,cLocSB6 						 					,Nil})
				Endif
			Elseif !Empty(cLocSC7)
				Aadd(_aLinha,{"D1_LOCAL"  ,cLocSC7 						 					,Nil})
			Endif
		Endif


		/*
		dbSelectArea("SD1")
		If FieldPos("D1_XOPER") > 0
			If Empty(ZNFTEMP->ZNF_PEDIDO)
				Aadd(_aLinha,{"D1_XOPER" 	 ,ZNFTEMP->ZNF_XOPER  	,Nil})
				Aadd(_aLinha,{"D1_OPER" 	 ,ZNFTEMP->ZNF_XOPER  	,Nil})
			Endif
		Endif

		*/




		dbSelectArea('SF4')
		dbSetOrder(1) // Filial + Codigo
		cXOper:=''
		// Posiciona na TES e valida se existe
		If SF4->(dbSeek(xFilial('SF4') + ZNFTEMP->ZNF_TES))


			

			// 1. Cen rio: ATUALIZA ESTOQUE (SIM)
			If SF4->F4_ESTOQUE == 'S'

				If SF4->F4_PISCRED == '1' // Credita
					cXOper := "51"
				Else // N o Credita (Qualquer valor diferente de 1)
					cXOper := "57"
				EndIf

				// 2. Cen rio: N O ATUALIZA ESTOQUE (N O)
			ElseIf SF4->F4_ESTOQUE == 'N'

				If SF4->F4_PISCRED == '1' // Credita
					cXOper := "O"
				Else // N o Credita (Qualquer valor diferente de 1)
					cXOper := "P"
				EndIf

			Endif
			Aadd(_aLinha,{"D1_XOPER" 	 ,cXOper  	,Nil})
			Aadd(_aLinha,{"D1_OPER" 	 ,cXOper  	,Nil})

		Endif




		If cTpLanc <> 'P'

			dbSelectArea('SF4')
			dbSetOrder(1)
			SF4->(dbSeek(xFilial('SF4')+ZNFTEMP->ZNF_TES))
			Aadd(_aLinha,{"D1_TES"      ,ALLTRIM(ZNFTEMP->ZNF_TES)     		,Nil})

			cSitTrib := SF4->F4_SITTRIB

		Endif

		dbSelectArea('ZNFTEMP')

		If (ZNFTEMP->(FieldPos("ZNF_CODIS"))) > 0
			If !Empty(ZNFTEMP->ZNF_CODIS)
				Aadd(_aLinha,{"D1_CODISS" 	 ,ALLTRIM(ZNFTEMP->ZNF_CODIS)	,Nil})
			Endif
		Endif
		If (ZNFTEMP->(FieldPos("ZNF_FCICOD"))) > 0
			If !Empty(ZNFTEMP->ZNF_FCICOD)
				Aadd(_aLinha,{"D1_FCICOD" 	 ,ZNFTEMP->ZNF_FCICOD 	,Nil})
			Endif
		Endif

		If (ZNFTEMP->(FieldPos("ZNF_ORIG"))) > 0
			if !Empty(Alltrim(ZNFTEMP->ZNF_ORIG))
				Aadd(_aLinha,{"D1_CLASFIS"  ,Alltrim(ZNFTEMP->ZNF_ORIG)+Alltrim(cSitTrib) ,Nil})
			Endif
		Endif

		If AllTrim(UPPER(ZNFTEMP->ZNF_LOTEFO)) != "ABAX" //.And. !lOrigem
			If !Empty(Alltrim(ZNFTEMP->ZNF_LOTEFO))
				Aadd(_aLinha,{"D1_LOTEFOR"    ,Alltrim(UPPER(ZNFTEMP->ZNF_LOTEFO))	,Nil})
			Endif
			If !Empty(Alltrim(ZNFTEMP->ZNF_LOTECT))
				Aadd(_aLinha,{"D1_LOTECTL"    ,Alltrim(UPPER(ZNFTEMP->ZNF_LOTECT))	,Nil})
			Endif
			If !Empty(Alltrim(ZNFTEMP->ZNF_DTVALI))
				Aadd(_aLinha,{"D1_DTVALID"    ,Stod(ZNFTEMP->ZNF_DTVALI)					,Nil})
			Endif
			If !Empty(Alltrim(ZNFTEMP->ZNF_DTVALI))
				Aadd(_aLinha,{"D1_DFABRIC"    ,Stod(ZNFTEMP->ZNF_DFABRI)					,Nil})
			Endif
		EndIf

		If SF4->F4_TRANFIL = 'S'
			Aadd(_aLinha,{"D1_NFORI"  	,ZNFTEMP->ZNF_DOC										,Nil})
			Aadd(_aLinha,{"D1_SERIORI"	,ZNFTEMP->ZNF_SERIE									,Nil})
		Endif

		//Aadd(_aLinha,{"D1_FORNECE"  ,ZNFTEMP->ZNF_FORNEC		 						,Nil})
		//Aadd(_aLinha,{"D1_LOJA"     ,Alltrim(ZNFTEMP->ZNF_LOJA)						,Nil})
		//Aadd(_aLinha,{"D1_DOC"      ,ZNFTEMP->ZNF_DOC      							,Nil})
		//Aadd(_aLinha,{"D1_EMISSAO"  ,Stod(ZNFTEMP->ZNF_EMISSA)						,Nil})
		//Aadd(_aLinha,{"D1_DTDIGIT"  ,DDATABASE 					,Nil})

		//Aadd(_aLinha,{"D1_SERIE"    ,ZNFTEMP->ZNF_SERIE     							,Nil})
		//Aadd(_aLinha,{"D1_TIPO"     ,ZNFTEMP->ZNF_TIPO      							,Nil})

		If (ZNFTEMP->ZNF_VALDES > 0)
			Aadd(_aLinha,{"D1_DESC"	,Round((ZNFTEMP->ZNF_VALDES/ZNF_TOTAL*100),2)							,Nil})
			Aadd(_aLinha,{"D1_VALDESC"	,ZNFTEMP->ZNF_VALDES								,Nil})
		Endif



		If ZNFTEMP->ZNF_PICM > 0

			//Somente para clientes que desejam escriturar os impostos da mesma forma que est o na nota fiscal.
			//Caso contr rio, campos abaixo dever o ser comentados.

			If ZNFTEMP->ZNF_PICM > 0
				//Aadd(_aLinha,{"D1_PICM"  ,ZNFTEMP->ZNF_PICM     ,Nil})
			Endif

			If ZNFTEMP->ZNF_BSICM > 0
				//Aadd(_aLinha,{"D1_BASEICM"  ,ZNFTEMP->ZNF_BSICM    ,Nil})
			Endif

			If ZNFTEMP->ZNF_VALICM > 0
				//Aadd(_aLinha,{"D1_VALICM" ,ZNFTEMP->ZNF_VALICM   ,Nil})
			Endif

			aAdd(aAutoImp,{'IT_BASEICM',  ZNFTEMP->ZNF_BSICM ,   nTotItem}) //Base
			aAdd(aAutoImp, {'IT_ALIQICM',  ZNFTEMP->ZNF_PICM,   nTotItem}) //Porcentagem Imposto
			aAdd(aAutoImp, {'IT_VALICM' ,  ZNFTEMP->ZNF_VALICM,   nTotItem}) //Valor imposto

			If ZNFTEMP->ZNF_ICMSCO > 0
				Aadd(_aLinha,{"D1_ICMSCOM"  ,ZNFTEMP->ZNF_ICMSCO   					,Nil})	//ICMS COMPLEMENTAR
			Endif

			If ZNFTEMP->ZNF_ALISOL > 0
				Aadd(_aLinha,{"D1_ALIQSOL" 	,ZNFTEMP->ZNF_ALISOL						,Nil})
			Endif

			//ICMS retido BASE - D1_BRICMS - ZNF_BSICM
			//ICMS ALIQ - D1_ALIQCMP - ZNF_PICM
			//VALOR D1_ICMSRET - Valor do ICMS - ZNF_VALST
			If ZNFTEMP->ZNF_VALST > 0
				Aadd(_aLinha,{"D1_PICM"  	,ZNFTEMP->ZNF_PICM     ,Nil})
				Aadd(_aLinha,{"D1_BRICMS" 	,ZNFTEMP->ZNF_BSICM	   ,Nil})
				Aadd(_aLinha,{"D1_ICMSRET" 	,ZNFTEMP->ZNF_VALST	  ,Nil})
			Endif

		Endif

		If ZNFTEMP->ZNF_PIPI > 0

			nBTotIPI += ZNFTEMP->ZNF_BSIPI
			nVTotIPI += ZNFTEMP->ZNF_VALIPI
			nPIPI    = ZNFTEMP->ZNF_PIPI

			/*aAdd(aAutoImp, {'IT_BASEIPI', ZNFTEMP->ZNF_BSIPI ,   nTotItem}) //Base
			aAdd(aAutoImp, {'IT_ALIQIPI',  ZNFTEMP->ZNF_PIPI,   nTotItem}) //Porcentagem Imposto
			aAdd(aAutoImp, {'IT_VALIPI' ,  ZNFTEMP->ZNF_VALIPI,   nTotItem}) //Valor imposto */

			Aadd(_aLinha,{"D1_BASEIPI"   ,ZNFTEMP->ZNF_BSIPI 	 						,Nil})	//BASE DE CALCULO 242
			Aadd(_aLinha,{"D1_IPI" 		 ,ZNFTEMP->ZNF_PIPI	 							,Nil})	//Valor do IPI - ALIQUOTA
			Aadd(_aLinha,{"D1_VALIPI" 	 ,ZNFTEMP->ZNF_VALIPI  							,Nil})	//- VALOR IPI 244

		Endif

		If  !Empty(Alltrim(ZNFTEMP->ZNF_CONTA)) // > 0 //- Conta ContÃƒÂ¡bil
			Aadd(_aLinha,{"D1_CONTA" 	,ZNFTEMP->ZNF_CONTA		,Nil})
		Endif

		If !Empty(SC7->C7_ITEMCTA)
			Aadd(_aLinha,{"D1_ITEMCTA" 	,SC7->C7_ITEMCTA		,Nil})
		Endif

		If ZNFTEMP->ZNF_ABATMA > 0 //- N - 14 - 2 - Abatimento ISS material
			Aadd(_aLinha,{"D1_ABATMAT"  ,ZNFTEMP->ZNF_ABATMA  ,Nil})
		Endif

		If (ZNFTEMP->(FieldPos("ZNF_ABATIS"))) > 0
			If ZNFTEMP->ZNF_ABATIS > 0
				Aadd(_aLinha,{"D1_BASEISS"	,  ZNFTEMP->ZNF_BASISS,Nil})
				Aadd(_aLinha,{"D1_ALIQISS"	,  ZNFTEMP->ZNF_ALIISS,Nil})
				Aadd(_aLinha,{"D1_ABATISS" 	, ZNFTEMP->ZNF_ABATIS ,Nil})
				Aadd(_aLinha,{"D1_VALISS" 	,  ZNFTEMP->ZNF_VALISS,Nil})
			else
				If ZNFTEMP->ZNF_BASISS > 0	.AND. ZNFTEMP->ZNF_ALIISS > 0
					Aadd(_aLinha,{"D1_BASEISS"	,  ZNFTEMP->ZNF_BASISS,Nil})
					Aadd(_aLinha,{"D1_ALIQISS"	,  ZNFTEMP->ZNF_ALIISS,Nil})
					Aadd(_aLinha,{"D1_VALISS" 	,  ZNFTEMP->ZNF_VALISS,Nil})

					aAdd(aAutoImp, {'IT_BASEISS', ZNFTEMP->ZNF_BASISS ,   nTotItem}) //Base
					aAdd(aAutoImp, {'IT_ALIQISS',  ZNFTEMP->ZNF_ALIISS,   nTotItem}) //Porcentagem Imposto
					aAdd(aAutoImp, {'IT_VALISS' ,  ZNFTEMP->ZNF_VALISS,   nTotItem}) //Valor imposto

				Endif
			Endif
		else
			If ZNFTEMP->ZNF_BASISS > 0	.AND. ZNFTEMP->ZNF_ALIISS > 0
				Aadd(_aLinha,{"D1_BASEISS"	,  ZNFTEMP->ZNF_BASISS,Nil})
				Aadd(_aLinha,{"D1_ALIQISS"	,  ZNFTEMP->ZNF_ALIISS,Nil})
				Aadd(_aLinha,{"D1_VALISS" 	,  ZNFTEMP->ZNF_VALISS,Nil})

				aAdd(aAutoImp, {'IT_BASEISS', ZNFTEMP->ZNF_BASISS ,   nTotItem}) //Base
				aAdd(aAutoImp, {'IT_ALIQISS',  ZNFTEMP->ZNF_ALIISS,   nTotItem}) //Porcentagem Imposto
				aAdd(aAutoImp, {'IT_VALISS' ,  ZNFTEMP->ZNF_VALISS,   nTotItem}) //Valor imposto
			Endif
		Endif

		If (ZNFTEMP->(FieldPos("ZNF_ABATIN"))) > 0
			If ZNFTEMP->ZNF_ABATIN > 0

				Aadd(_aLinha,{"D1_ABATINS" 	, ZNFTEMP->ZNF_ABATIN , Nil})

			Endif
		Endif

		If (ZNFTEMP->(FieldPos("ZNF_BASEIN"))) > 0
			If ZNFTEMP->ZNF_BASEIN > 0 .AND. ZNFTEMP->ZNF_ALIQIN > 0

				Aadd(_aLinha,{"D1_BASEINS" 	, ZNFTEMP->ZNF_BASEIN , Nil})
				Aadd(_aLinha,{"D1_ALIQINS" 	, ZNFTEMP->ZNF_ALIQIN , Nil})
				Aadd(_aLinha,{"D1_VALINS" 	, ZNFTEMP->ZNF_VALIN , Nil})

			Endif
		Endif

		If ZNFTEMP->ZNF_ALQPIS  > 0

			If ZNFTEMP->ZNF_BASPIS > 0
				Aadd(_aLinha,{"D1_BASEPIS"	 ,ZNFTEMP->ZNF_BASPIS		,Nil})
			Endif

			If ZNFTEMP->ZNF_ALQPIS > 0
				Aadd(_aLinha,{"D1_ALQPIS" ,ZNFTEMP->ZNF_ALQPIS	,Nil})
			Endif

			If	ZNFTEMP->ZNF_VALPIS > 0
				Aadd(_aLinha,{"D1_VALPIS" ,ZNFTEMP->ZNF_VALPIS	,Nil})
			Endif

		Endif

		If ZNFTEMP->ZNF_ALQCOF  > 0

			If ZNFTEMP->ZNF_BASCOF > 0
				Aadd(_aLinha,{"D1_BASECOF"	,ZNFTEMP->ZNF_BASCOF		,Nil})
			Endif

			If ZNFTEMP->ZNF_ALQCOF > 0
				Aadd(_aLinha,{"D1_ALQCOF" ,ZNFTEMP->ZNF_ALQCOF	,Nil})  //326 a 342 Tratamento para Impostos de ServiÃ§os
			Endif

			If ZNFTEMP->ZNF_VALCOF > 0
				Aadd(_aLinha,{"D1_VALCOF" 	 ,ZNFTEMP->ZNF_VALCOF		,Nil})
			Endif

		Endif

		If ZNFTEMP->ZNF_ALQCSL  > 0
			If ZNFTEMP->ZNF_BASCSL > 0
				Aadd(_aLinha,{"D1_BASECSL"	,ZNFTEMP->ZNF_BASCSL		,Nil})
			Endif

			If ZNFTEMP->ZNF_ALQCSL > 0
				Aadd(_aLinha,{"D1_ALQCSL" ,ZNFTEMP->ZNF_ALQCSL	,Nil})
			Endif

			If ZNFTEMP->ZNF_VALCSL > 0
				Aadd(_aLinha,{"D1_VALCSL" 	 ,ZNFTEMP->ZNF_VALCSL	,Nil})
			Endif
		Endif

		If ZNFTEMP->ZNF_BASEIN > 0 //- N - 14 - 2 - Abatimento ISS material
			Aadd(_aLinha,{"D1_BASEINS"  ,ZNFTEMP->ZNF_BASEIN  ,Nil})
		Endif

		If (ZNFTEMP->(FieldPos("ZNF_ABATAL"))) > 0
			If ZNFTEMP->ZNF_ABATAL > 0

				Aadd(_aLinha,{"D1_ABATALM" 	, ZNFTEMP->ZNF_ABATAL , Nil})

			Endif
		Endif

		dbSelectArea("SD1")

		If (SD1->(FieldPos("D1_NATUREZ"))) > 0

			If cTpLanc <> 'P'

				If ZNFTEMP->ZNF_TIPO $ 'N_I_P_C'
					If AllTrim(ZNFTEMP->ZNF_NATUR) == "000000"
						Aadd(_aLinha,{"D1_NATUREZ"  ,"      "  ,Nil})
					Else
						Aadd(_aLinha,{"D1_NATUREZ"  ,ZNFTEMP->ZNF_NATUR  ,Nil})
					EndIf
				Endif
			Endif

		Endif

		If !Empty(Alltrim(ZNFTEMP->ZNF_CFOP))
			If (cEstSM == 'SC') .and. FieldPos("D1_XOPER") > 0
				Aadd(_aLinha,{"D1_DCIPSC" 	, ZNFTEMP->ZNF_CFOP , Nil})
			Endif
		Endif

		dbSelectArea("ZNFTEMP")

		If (ZNFTEMP->(FieldPos("ZNF_BASNDE"))) > 0
			Aadd(_aLinha,{"D1_BASNDES" 	, ZNFTEMP->ZNF_BASNDE ,Nil})
		Endif

		If (ZNFTEMP->(FieldPos("ZNF_ALQNDE"))) > 0
			Aadd(_aLinha,{"D1_ALQNDES" 	, ZNFTEMP->ZNF_ALQNDE ,Nil})
		Endif

		If (ZNFTEMP->(FieldPos("ZNF_ICMNDE"))) > 0
			Aadd(_aLinha,{"D1_ICMNDES" 	, ZNFTEMP->ZNF_ICMNDE ,Nil})
		Endif

		If !Empty(Alltrim(ZNFTEMP->ZNF_CC))
			dbSelectArea('CTT')
			CTT->(dbSetOrder(01))
			CTT->(dbSeek(xFilial('CTT')+Alltrim(ZNFTEMP->ZNF_CC)))
			If !Eof()
				Aadd(_aLinha,{"D1_CC" 		,Alltrim(ZNFTEMP->ZNF_CC),Nil})
			Else
				FwLogMsg("INFO-ABAX", /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01",'MTUFOPRO -NÃƒÆ’O ACHOU O CENTRO DE CUSTOS DA ZNF', 0, (nStart - Seconds()), {})
			Endif
		Else
			If !Empty(Alltrim(SC7->C7_CC))
				Aadd(_aLinha,{"D1_CC" 		,SC7->C7_CC,Nil})
			Endif
		Endif

		If (ZNFTEMP->(FieldPos("ZNF_QRCODE"))) > 0
			If !Empty(ZNFTEMP->ZNF_QRCODE)// Campo especifico Urbano.
				Aadd(_aLinha,{"D1_ZUSERI" 	 ,ZNFTEMP->ZNF_QRCODE 	,Nil})
			Endif
		Endif

		If (ZNFTEMP->(FieldPos("ZNF_CODANV"))) > 0
			If !Empty(ZNFTEMP->ZNF_CODANV)// Campo especifico Urbano.
				Aadd(_aLinha,{"D1_ZUSERA" 	 ,Alltrim(ZNFTEMP->ZNF_CODANV) 	,Nil})
			Endif
		Endif

		If ZNFTEMP->ZNF_AVLINS > 0
			Aadd(_aLinha,{"D1_AVLINSS" 	, ZNFTEMP->ZNF_AVLINS ,Nil})
		Endif

		Aadd(_aItensSD1,_aLinha)
		dbSelectArea("ZNFTEMP")
		cTpLanc := Alltrim(ZNFTEMP->ZNF_TPLANC)
		cLocSB6 := ""

		nTotAbax := Val(ZNFTEMP->ZNF_ITEM)
		nDescTot += ZNFTEMP->ZNF_VALDES

		ZNFTEMP->(dbSkip())

		If __cSeekNF != ZNFTEMP->ZNF_DOC+ZNFTEMP->ZNF_SERIE+ZNFTEMP->ZNF_FORNEC+ZNFTEMP->ZNF_LOJA

			if nBTotIPI > 0

				Aadd(_aCabSF1,{"F1_BASEIPI"   ,nBTotIPI					,Nil})
				Aadd(_aCabSF1,{"F1_VALIPI"    ,nVTotIPI					,Nil})
				Aadd(_aCabSF1,{"F1_DESCONT"   ,nDescTot					,Nil})

			Endif

			If nTotAbax > 0
				If nTotAbax <> nToItem
					lErroAba:= .T.
					cError += ' Problema na ExportaÃ§Ã£o da Nota Fiscal para a ZNF, favor exportar a Nota Fiscal Novamente. Quantidade de linhas nÃ£o bate com a quantidade de itens exportados. Campo ZNF_ITEM.'
				Endif
			Endif
			nToItem := 0
			nBTotIPI := 0
			nVTotIPI := 0
			nPIPI    := 0
			nDescTot := 0

			lMsErroAuto:=.F.

			if (ZNFTEMP->ZNF_ESPEC <> 'NFE' .OR. ZNFTEMP->ZNF_ESPEC <> 'CTE')
				aItensDHR := FNatRend()
			Endif

			If !lErroAba
				Begin transaction

					If cTpLanc = 'P'
						//InclusÃƒÂ£o de PrÃƒÂ©-Nota
						MSExecAuto({|x,y,z|Mata140(x,y,z)},_aCabSF1,_aItensSD1,3)
					ElseIf cTpLanc = 'W'
						//ClassificaÃƒÂ§ÃƒÂ£o de PrÃƒÂ© Nota
						MSExecAuto({|x,y,z| MATA103(x,y,z)},_aCabSF1,_aItensSD1,4)
					ElseIf  cTpLanc = 'E'
						//ExclusÃƒÂ£o de Nota Fiscal
						MSExecAuto({|x,y,z| MATA103(x,y,z)},_aCabSF1,_aItensSD1,4)
					Else
						//InclusÃƒÂ£o de Nota Fiscal
						//MSExecAuto({|x,y,z,k,a,b| MATA103(x,y,z,,,,k,a,,,b)} ,_aCabSF1,_aItensSD1,3, , ,aCodRet)
						if Len(aItensDHR) == 0
							//MSExecAuto({|x,y,z,k,a,b| MATA103(x,y,z,,,,k, ,,,a,,b)},_aCabSF1 ,_aItensSD1,3, .F.,aAutoImp,,,aItensRat, , ,aCodRet)
							MSExecAuto({|x,y,z,k,a,b| MATA103(x,y,z,,,,k,a,,,b)} ,_aCabSF1,_aItensSD1,3,aAutoImp , ,aCodRet)
						Else
							MSExecAuto({|x,y,z,a    | MATA103(x,y,z,,,,,,,,,,a)}   ,_aCabSF1   ,_aItensSD1,3, .F. ,aItensDHR)
						Endif


					Endif

				End Transaction
			Endif
			lErroAba:= .F.
			cDataX  := DtoC(Date())
			cTimeX  := Time()
			cError   := ' '

			ErrorBlock(oLastError)
			__cLogMsg := Space(1)
			If !empty(cError)
				__cLogMsg := cError
			Endif

			If lMsErroAuto	.Or. !Empty(cError)
				If Len(Alltrim(__cLogMsg)) = 0
					__cLogMsg:= " "
				Endif
				aLog := {}
				aLog := GetAutoGRLog()
				cLogFile := ( 'LOG_' +  __cSeekNF + '_Dt' + DtoS( Date() ) + '_Hr' + StrTran( Time() , ':' , '' ) + '.TXT' )

				aEval(aLog,{|BUFFER| __cLogMsg += (BUFFER + CHR(13)+CHR(10)) })
				u_FAtuaStat(cDocSMA,cSerSMA,cForSMA, cLojSMA,.F., __cLogMsg+'- Data ' + cDataX+'- Hora '+cTimeX)
			Else

				u_FAtuaStat(cDocSMA,cSerSMA,cForSMA, cLojSMA,.T.,'Processado com Sucesso.'+'- Data ' + cDataX+'- Hora '+cTimeX+ '-' +Alltrim(__cLogMsg) )
			Endif

			_aCabSF1	:= {}
			_aItensSD1	:={}
			lImport		:=.F.
			nVBrtAbax   := 0

		Endif
		nZ++
	EndDo
	/* Restaura Area de todas as tabelas envolvidas */
	FwLogMsg("INFO-ABAX", /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01",'TOTAL DE NOTAS PROCESSADAS ' + str(nZ), 0, (nStart - Seconds()), {})

	PutMV("MV_ALTPRCC",cAltPrcc)
	dbSelectArea("ZNFTEMP")
	dbCloseArea()

	RestArea(aAreaSB1)
	RestArea(aAreaSF1)
	RestArea(aAreaSD1)
	RestArea(aAreaSF4)

Return(lMsErroAuto) //Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuaStat

   FunÃƒÂ§ÃƒÂ£o utilizada para atualizar status das Notas apos importaÃƒÂ§ÃƒÂ£o
   futuros problemas na UFO
	@author 	Helder Santos
	@Paramt		cCodNota - Codigo da Nota Fiscal
	@Paramt		cCodSer - Codigo da Serie
	@Paramt		cCGCFor - CNPJ do fornecedor
	@since		04.04.2014
	@version	P11

---------------------------------------------------------------------
Programador		Data		Motivo
---------------------------------------------------------------------
/*/
User Function FAtuaStat(cCodNota, cCodSer, cCodFor, cLojFor,lOk,cMsg)

	Local cQryExc	:= ''
	Local cDbase   := Alltrim(TCGetDB())
	Local cRetZNF :=  GetNextAlias()
	Local aAreaZ   := GetArea()

	If lOk
		cStatus := '2'
	Else
		cStatus := '3'
	Endif


	If cDbase <> 'ORACLE'

		cQryExc := " SELECT R_E_C_N_O_,ZNF_ESPEC FROM "+ RetSqlName("ZNF")
		cQryExc += " WHERE ZNF_DOC = '"+cCodNota+"' "
		cQryExc += " AND ZNF_SERIE = '"+cCodSer+"' "
		cQryExc += " AND ZNF_FORNEC = '"+cCodFor+"' "
		cQryExc += " AND ZNF_LOJA = '"+	cLojFor+"' "

		cRetZNF := MPSysOpenQuery(cQryExc, cRetZNF)

		dbSelectArea(cRetZNF)
		dbGotop()

		Do While !Eof()

			dbSelectArea('ZNF')
			dbGoto((cRetZNF)->R_E_C_N_O_)

			If Alltrim((cRetZNF)->ZNF_ESPEC) = 'CTE'
				cStatus := '2'
			Endif

			If !Eof()
				RecLock("ZNF",.F.)
				Replace ZNF_STATUS With Alltrim(cStatus)
				Replace ZNF_LOG    With Alltrim(cMsg)
				Replace ZNF_DATA   With dDataBase
				MsUnLock()
			EndIf

			dbSelectArea(cRetZNF)
			dbSkip()
		Enddo
		dbSelectArea(cRetZNF)
		dbCloseArea()

	Else

		cQryExc +="DECLARE"+CHR(13)+CHR(10)
		cQryExc +="LONGLITERAL RAW(32767) := UTL_RAW.CAST_TO_RAW('" +cMsg+"');"+CHR(13)+CHR(10)
		cQryExc +="BEGIN"+CHR(13)+CHR(10)
		cQryExc +="EXECUTE IMMEDIATE"+CHR(13)+CHR(10)
		cQryExc +="'UPDATE "+RetSqlName("ZNF")+""+CHR(13)+CHR(10)
		cQryExc +="SET ZNF_STATUS = "+Alltrim(cStatus)+" ,"+CHR(13)+CHR(10)
		cQryExc +="ZNF_DATA = " +DTOS(dDataBase)+","+CHR(13)+CHR(10)
		cQryExc +="ZNF_LOG = :1"+CHR(13)+CHR(10)
		cQryExc +="WHERE ZNF_DOC = "+cCodNota+""+CHR(13)+CHR(10)
		cQryExc +="AND ZNF_SERIE = ''' || '"+cCodSer+"' || '''"+CHR(13)+CHR(10)
		cQryExc +="AND ZNF_FORNEC = "+cCodFor+""+CHR(13)+CHR(10)
		cQryExc +="AND ZNF_LOJA = "+cLojFor+"'"+CHR(13)+CHR(10)
		cQryExc +="USING LONGLITERAL;"+CHR(13)+CHR(10)
		cQryExc +="COMMIT;"+CHR(13)+CHR(10)
		cQryExc +="END;"+CHR(13)+CHR(10)

		If (TCSQLExec(cQryExc) < 0)

			FwLogMsg("DENTRO FAtuaStat 6", /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01","TCSQLError() " + TCSQLError(), 0, (nStart - Seconds()), {})

		EndIf

		If (TCSQLExec('commit') < 0)
			FwLogMsg("DENTRO FAtuaStat 7", /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01","TCSQLError() " + TCSQLError(), 0, (nStart - Seconds()), {})
		endif
	Endif
	RestArea(aAreaZ)

Return(Nil)



User FUNCTION MTCTEPRO(cEmpAbx, cFilAbx, cIdAbx)
	**********************************************************************************
	*FunÃƒÂ§ÃƒÂ£o que gera CTE atravÃƒÂ©s da rotina MATA116
	**********************************************************************************

	Local aEmpSmar 	:= {}
	Local aInfo   	:= {}
	Local aTables 	:= {"SA1","SA2","SF1","SD1","SF2","SD2","CTT","ZNF", "SF4","SB6","SB1","CT1",'SX6'}//seta as tabelas que serÃƒÂ£o abertas no rpcsetenv
	Local nI := 0
	Local n := 0

	Private cCondAbax   := Space(3)
	Private dDtVAbax	:= date()
	Private cMAVenc		:= Space(250)
	Private nVBrtAbax	:= 0
	Private cUserAbx	:= Space(30)

	cError      := ""
	oLastError 	:= ErrorBlock({|e| cError := e:Description + e:ErrorStack})

	If Empty(cIdAbx)

		aInfo := GetUserInfoArray()
		nI := 1
		For nI := 1 to Len(aInfo)
			If aInfo[nI][5] == "U_MTCTEPRO" .And. aInfo[nI][3] <> Threadid()

				FwLogMsg("MTCTEPRO 1", /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01",'Fun? MTCTEPRO sendo Utilizada! ', 0, (nStart - Seconds()), {})
				Return
			EndIf
		Next nI

		PREPARE ENVIRONMENT EMPRESA '01' FILIAL '01' MODULO "COM" FUNNAME "MATA116"

		cUsuSm := Space(1)
		cSenSm := Space(1)


		dbSelectarea('SM0')
		SM0->(dbSetOrder(1))
		SM0->(dbGotop())

		Do While SM0->(!Eof())

			Aadd(aEmpSmar,{SM0->M0_CODIGO,SM0->M0_CODFIL})
			SM0->(dbSkip())

		Enddo

		RESET ENVIRONMENT

		cEmpABax := aEmpSmar[1][1]

		PREPARE ENVIRONMENT EMPRESA aEmpSmar[1][1] FILIAL aEmpSmar[1][2] MODULO "COM" FUNNAME "MATA116"

		n:=1
		For n:=1 to Len(aEmpSmar)
			If cEmpABax = aEmpSmar[n][1]
				cFilAnt := aEmpSmar[n][2]
				cEmpABax := aEmpSmar[n][1]
			Else
				RESET ENVIRONMENT
				cEmpABax := aEmpSmar[n][1]
				//RpcSetEnv( aEmpSmar[n][1],aEmpSmar[n][2]," " ," ", "COM", "MATA116", aTables, , , ,  )/****** COMANDOS *************/
				PREPARE ENVIRONMENT EMPRESA aEmpSmar[n][1] FILIAL aEmpSmar[n][2] MODULO "COM" FUNNAME "MATA116"

			Endif

			If CHKFILE("ZNF", .F.)

				FWLogMsg(;
					"INFO",;    //cSeverity      - Informe a severidade da mensagem de log. As opï¿½ï¿½es possï¿½veis sï¿½o: INFO, WARN, ERROR, FATAL, DEBUG
					,;          //cTransactionId - Informe o Id de identificaï¿½ï¿½o da transaï¿½ï¿½o para operaï¿½ï¿½es correlatas. Informe "LAST" para o sistema assumir o mesmo id anterior
					"INTEGRADOR_ABAX",; //cGroup         - Informe o Id do agrupador de mensagem de Log
					,;          //cCategory      - Informe o Id da categoria da mensagem
					,;          //cStep          - Informe o Id do passo da mensagem
					,;          //cMsgId         - Informe o Id do cï¿½digo da mensagem
					"INICIO IMPORTAï¿½ï¿½O ï¿½BAX - CHAMANDO FUNï¿½AO U_MImpCTE - MATA116",;    //cMessage       - Informe a mensagem de log. Limitada ï¿½ 10K
					,;          //nMensure       - Informe a uma unidade de medida da mensagem
					,;          //nElapseTime    - Informe o tempo decorrido da transaï¿½ï¿½o
					;           //aMessage       - Informe a mensagem de log em formato de Array - Ex: { {"Chave" ,"Valor"} }
					)



				U_MImpCTE(aEmpSmar[n][1],aEmpSmar[n][2],cUsuSm,cSenSm)
			Else
				FWLogMsg(;
					"ERROR",;    //cSeverity      - Informe a severidade da mensagem de log. As opï¿½ï¿½es possï¿½veis sï¿½o: INFO, WARN, ERROR, FATAL, DEBUG
					,;          //cTransactionId - Informe o Id de identificaï¿½ï¿½o da transaï¿½ï¿½o para operaï¿½ï¿½es correlatas. Informe "LAST" para o sistema assumir o mesmo id anterior
					"INTEGRADOR_ABAX",; //cGroup         - Informe o Id do agrupador de mensagem de Log
					,;          //cCategory      - Informe o Id da categoria da mensagem
					,;          //cStep          - Informe o Id do passo da mensagem
					,;          //cMsgId         - Informe o Id do cï¿½digo da mensagem
					"EMPRESA SEM TABELA ZNF CADASTRADA - - MATA116 - " + aEmpSmar[nAbax][1],;    //cMessage       - Informe a mensagem de log. Limitada ï¿½ 10K
					,;          //nMensure       - Informe a uma unidade de medida da mensagem
					,;          //nElapseTime    - Informe o tempo decorrido da transaï¿½ï¿½o
					;           //aMessage       - Informe a mensagem de log em formato de Array - Ex: { {"Chave" ,"Valor"} }
					)


			Endif
		Next

		FWLogMsg(;
			"INFO",;    //cSeverity      - Informe a severidade da mensagem de log. As opï¿½ï¿½es possï¿½veis sï¿½o: INFO, WARN, ERROR, FATAL, DEBUG
			,;          //cTransactionId - Informe o Id de identificaï¿½ï¿½o da transaï¿½ï¿½o para operaï¿½ï¿½es correlatas. Informe "LAST" para o sistema assumir o mesmo id anterior
			"INTEGRADOR_ABAX",; //cGroup         - Informe o Id do agrupador de mensagem de Log
			,;          //cCategory      - Informe o Id da categoria da mensagem
			,;          //cStep          - Informe o Id do passo da mensagem
			,;          //cMsgId         - Informe o Id do cï¿½digo da mensagem
			"FIM INTEGRAï¿½ï¿½O ï¿½BAX PROTHEUS - MATA116",;    //cMessage       - Informe a mensagem de log. Limitada ï¿½ 10K
			,;          //nMensure       - Informe a uma unidade de medida da mensagem
			,;          //nElapseTime    - Informe o tempo decorrido da transaï¿½ï¿½o
			;           //aMessage       - Informe a mensagem de log em formato de Array - Ex: { {"Chave" ,"Valor"} }
			)


		RESET ENVIRONMENT
	Else
		//RpcSetEnv( cEmpAbx,cFilAbx," " ," ", "COM", "MATA116", aTables, , , ,  )
		PREPARE ENVIRONMENT EMPRESA cEmpAbx FILIAL cFilAbx MODULO "COM" FUNNAME "MATA116"
		cUsuSm := Space(1)//Alltrim(SuperGetMV("MA_USUSMA"))
		cSenSm := Space(1)//Alltrim(SuperGetMV("MA_PASSMA"))
		U_MImpCTE(cEmpAbx,cFilAbx,cUsuSm,cSenSm)
	Endif

Return

User Function MImpCTE(cEmpMa,cFilMa,cUsusm,cSenSm)
	******************************************************************************
	* FunÃƒÂ§ÃƒÂ£o para importar  notas para o Protheus. Foi desmembrado a funÃƒÂ§ÃƒÂ£o devido
	* a empresas que possuem muitas empresas e filiais.
	******************************************************************************

	Private cPedAbax
	private cFilImp := alltrim(cFilMa)
	u_FSBusCTE()

	dbSelectArea("ZNFCTE")
	ZNFCTE->(dbGoTop())

	If !Empty(ZNFCTE->ZNF_DOC) //+(cAlias)->ZNF_SERIE+(cAlias)->ZNF_FORNEC+  (cAlias)->ZNF_LOJA)
		u_FSGeraCTE()
	Endif

	dbCloseArea()

Return


//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FSGeraCTE

	FunÃƒÂ§ÃƒÂ£o responsavel pela geraÃƒÂ§ÃƒÂ£o do CTE pela rotina MATA116.
	@author 	Leonardo Vasco Viana de Oliveira
	@since	22.03.2017
	@Parm1	cPrefix - Alias com as informaÃƒÂ§oes da CTE
	@version	P11

------------------------------------------------------------------------------------------
Programador		Data		Motivo
------------------------------------------------------------------------------------------
/*/
User Function FSGeraCTE(cPrefix)

	Local aAreaSB1	:= SB1->(GetArea())
	Local aAreaSF1	:= SF1->(GetArea())
	Local aAreaSD1	:= SD1->(GetArea())
	Local aAreaSF4	:= SF4->(GetArea())
	Local __cLogMsg	:= ''
	Local __cSeekCT	:= ''
	Local lImport	:= .F.

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.
	Private lAutoErrNoFile  := .T. //<= para nao gerar arquivo e pegar o erro com a funcao GETAUTOGRLOG()

	Private cFornece      := ""
	Private cLoja         := ""
	Private cCHVCTE	 	  := "" // Chave do CTE
	Private cTipCTE		  := ""// Tipo de CTe
	Private cEstSM 		  := "" //Estado da Transportadora.
	Private cDTCPiss	  := "" //
	Private cUserAbx      := "" //
	Private aCabec        := {}
	Private aIteAbax      := {}
	Private aLinAbax      := {}
	Private cDocSMA 	  := {}
	Private cSerSMA 	  := {}
	Private cForSMA 	  := {}
	Private cLojSMA 	  := {}
	Private cUsaCampo     := ""
	Private cPedAbax      := ""
	Private cDataX        := ""
	Private cTimeX        := ""
	//Private __cLogMsg     := ""
	Private cError        := ""
	//Private lMsErroAuto   := .T.
	Private aLog          := {}
	Private cLogFile      := ""
	Private cModal        := ""
	Private cTipFret  	  := "" //(cPrefix)->ZNF_TPFRET
	Private cCondFor	  := ""
	Private cHash		  := ""

	cError      := ""
	oLastError 	:= ErrorBlock({|e| cError := e:Description + e:ErrorStack})

	dbSelectArea("ZNFCTE")
	ZNFCTE->(dbGoTop())


	Do While ZNFCTE->(!Eof())

		__cSeekCT := ZNFCTE->ZNF_DOCCTE+ZNFCTE->ZNF_SERCTE+ZNFCTE->ZNF_FORCTE+ZNFCTE->ZNF_LOJCTE

		cDocSMA := ZNFCTE->ZNF_DOCCTE
		cSerSMA := ZNFCTE->ZNF_SERCTE
		cForSMA := ZNFCTE->ZNF_FORCTE
		cLojSMA := ZNFCTE->ZNF_LOJCTE

		cCHVCTE  := ZNFCTE->ZNF_CHVNFE


		If Empty(Alltrim(ZNFCTE->ZNF_TPCTE))
			cTipCTE  :=  Alltrim(ZNFCTE->ZNF_TIPO)
		Else
			cTipCTE  := Alltrim(ZNFCTE->ZNF_TPCTE)
		Endif


		cPedAbax := ZNFCTE->ZNF_PEDIDO
		cDTCPiss := Stod(ZNFCTE->ZNF_EMISSAO)
		cUserAbx := Substr(ZNFCTE->ZNF_USERLG,1,25)

		SB1->(dbSetOrder(1))
		SB1->(MsSeek(xFilial("SB1")+ZNFCTE->ZNF_COD))

		SA2->(dbSetorder(01))
		SA2->(dbSeek(xFilial('SA2')+ZNFCTE->ZNF_FORCTE+ZNFCTE->ZNF_LOJCTE ))
		cCondFor := SA2->A2_COND
		cEstSM := SA2->A2_EST

		cFornece := SA2->A2_COD
		cLoja    := SA2->A2_LOJA

		dbSelectArea('SF4')
		dbSetOrder(1)
		SF4->(dbSeek(xFilial('SF4')+ZNFCTE->ZNF_TES))


		If !lImport

			aIteAbax := U_Busca_NFs(ZNFCTE->ZNF_FILIAL,ZNFCTE->ZNF_DOCCTE,ZNFCTE->ZNF_SERCTE,ZNFCTE->ZNF_FORCTE,ZNFCTE->ZNF_LOJCTE ) // Busca Notas Fiscais


			dbSelectArea("SF1")
			dbSetOrder(1)
			dbSeek(xFilial('ZNF')+ZNFCTE->ZNF_DOC+ZNFCTE->ZNF_SERIE+ZNFCTE->ZNF_FORNEC+ZNFCTE->ZNF_LOJA)

			aadd(aCabec,{""			,dDataBase-360})       		// 1 Data Inicial
			aadd(aCabec,{""			,dDataBase})          		// 2 Data Final
			aadd(aCabec,{""			,2})                  		// 3 2-Inclusao;1=Exclusao
			aadd(aCabec,{""			,ZNFCTE->ZNF_FORNEC})  	// 4 Fornecedor do documento de Origem
			aadd(aCabec,{""			,ZNFCTE->ZNF_LOJA})    	// 5 Loja de origem
			aadd(aCabec,{""			,1})                      	// 6 Tipo da nota de origem: 1=Normal;2=Devol/Benef
			aadd(aCabec,{""			,2})                      	// 7 1=Aglutina;2=Nao aglutina
			aadd(aCabec,{"F1_EST"	   ,cEstSM})  				          // 8 Estado
			aadd(aCabec,{""			   ,ZNFCTE->ZNF_TOTAL})    // 9 Valor do conhecimento
			aadd(aCabec,{"F1_FORMUL"   ,1})        	            // 10 FormulÃƒÂ¡ri/o
			aadd(aCabec,{"F1_DOC"		,ZNFCTE->ZNF_DOCCTE})// 11 Numero da NF de Conhecimento de Frete
			aadd(aCabec,{"F1_SERIE"		,ZNFCTE->ZNF_SERCTE})// 12 Serie da NF do Conhecimento deFrete
			aadd(aCabec,{"F1_FORNECE"	,ZNFCTE->ZNF_FORCTE})             // 13 Fornecedor do Frete
			aadd(aCabec,{"F1_LOJA"		,ZNFCTE->ZNF_LOJCTE})                // 14 Loja do Frete
			aadd(aCabec,{""				,ZNFCTE->ZNF_TES})   // 15 TES         ''
			aadd(aCabec,{"F1_BASERET"	,0})                    // 16 Base Ret
			aadd(aCabec,{"F1_ICMRET"	,0})                    // 17 ICMS Retido

			If !Empty(ZNFCTE->ZNF_COND)
				aadd(aCabec,{"F1_COND"		,ZNFCTE->ZNF_COND})  // 18 CondiÃƒÂ§ÃƒÂ£o dePagametno
			elseif cCondFor <> ''
				aadd(aCabec,{"F1_COND"		,cCondFor})  // 18 CondiÃƒÂ§ÃƒÂ£o dePagametno
			Endif

			aadd(aCabec,{"F1_EMISSAO"	,Stod(ZNFCTE->ZNF_EMISSA)}) // 19 Emissao
			aadd(aCabec,{"F1_ESPECIE"	,ZNFCTE->ZNF_ESPEC})//19 Especie
			aadd(aCabec,{"E2_NATUREZ"	,ZNFCTE->ZNF_NATUR}) //20 Natureza
			//aadd(aCabec,{"F1_DESCONT"	,0							})                    //21 Desconto
			Aadd(aCabec,{"F1_DESPESA"	,ZNFCTE->ZNF_DESPES				})  // 22 Despesas

			AAdd(aCabec, {"F1_UFORITR",    ZNFCTE->ZNF_UFORIT}) // 24 Estado Origem do Transporte
			AAdd(aCabec, {"F1_MUORITR",    ZNFCTE->ZNF_MUORIT}) // 25 MunicÃƒÂ­pio Origem do Transporte
			AAdd(aCabec, {"F1_UFDESTR",    ZNFCTE->ZNF_UFDEST}) // 26 Estado Destino do Transporte
			AAdd(aCabec, {"F1_MUDESTR",    ZNFCTE->ZNF_MUDEST}) // 27 MunicÃƒÂ­pio Destino do Transporte

			dbSelectArea("ZNFCTE")

			If !Empty(cTipCTE)
				Aadd(aCabec,{"F1_TPCTE",	cTipCTE})
			Endif

			If (ZNFCTE->(FieldPos("ZNF_MODAL"))) > 0//!Empty(cUsaCampo)
				Aadd(aCabec,{"F1_MODAL",	Alltrim(ZNFCTE->ZNF_MODAL)})  //Modal do Transporte.
				cModal := Alltrim(ZNFCTE->ZNF_MODAL)
			Endif

			If (ZNFCTE->(FieldPos("ZNF_TPFRET"))) > 0//!Empty(cUsaCampo)
				Aadd(aCabec,{"F1_TPFRETE"    ,Alltrim(ZNFCTE->ZNF_TPFRET)		   			,Nil})     //Enviar tipo de Frete para o ERP.
				cTipFret   := ZNFCTE->ZNF_TPFRET
			Endif

			If (ZNFCTE->(FieldPos("ZNF_HASH"))) > 0
				Aadd(aCabec,{"F1_ZNUMECB"  ,Alltrim(ZNFTEMP->ZNF_HASH)   			       ,Nil})
				cHash := Alltrim(ZNFTEMP->ZNF_HASH)
			Endif

			lImport  := .T.

		Endif

		dbSelectArea("ZNFCTE")
		ZNFCTE->(dbSkip())

		If (__cSeekCT != ZNFCTE->ZNF_DOCCTE+ZNFCTE->ZNF_SERCTE+ZNFCTE->ZNF_FORCTE+ZNFCTE->ZNF_LOJCTE )

			If Len(aIteAbax)>0

				lMsErroAuto:=.F.
				MATA116(aCabec,aIteAbax,,,)

			Endif

			cDataX := DtoC(Date())
			cTimeX := Time()

			ErrorBlock(oLastError)
			__cLogMsg := Space(1)
			If !empty(cError)
				__cLogMsg := cError
			else
				cError := oLastError
			Endif

			If lMsErroAuto .OR. !Empty(cError)

				If Len(Alltrim(__cLogMsg)) = 0
					__cLogMsg:= " "
				Endif

				aLog := {}
				aLog := GetAutoGRLog()
				cLogFile := ( 'LOG_' +  __cSeekCT + '_Dt' + DtoS( Date() ) + '_Hr' + StrTran( Time() , ':' , '' ) + '.TXT' )
				aEval(aLog,{|BUFFER| __cLogMsg += (BUFFER + ' ') })//_CRLF) })

				IF Empty( __cLogMsg)
					If Len(aLog) > 0
						__cLogMsg := 'ERRO EXECAUTO IMPORTA  O CTE MATA116 ' + aLog[0]
					Endif
				Endif

				u_FAtuaCTE(cDocSMA,cSerSMA,cForSMA, cLojSMA,.F., __cLogMsg+'- Data ' + cDataX+'- Hora '+cTimeX)
			Else
				u_FAtuaCTE(cDocSMA,cSerSMA,cForSMA, cLojSMA,.T.,'Processado com Sucesso.'+'- Data ' + cDataX+'- Hora '+cTimeX+ '-' +Alltrim(__cLogMsg) )
			Endif

			aCabec	:= {}
			aIteAbax	:= {}
			lImport	:= .F.
			cError := ''


		EndIf

	Enddo

	dbSelectArea("ZNFCTE")
	dbCloseArea()

	RestArea(aAreaSB1)
	RestArea(aAreaSF1)
	RestArea(aAreaSD1)
	RestArea(aAreaSF4)

Return

********************************************************************************
*FunÃƒÂ§ÃƒÂ£o que busca todas as Notas Fiscais que estÃƒÂ£o relacionadas para cada CTe
*cDocCTe := Documento CTE
*cSerCTe := Serie CTE
*cForCTe := Fornecedor CTE
*cLojCTe := Loja Fornecedor CTE
********************************************************************************
User Function  Busca_NFs(cFilImp, cDocCTe, cSerCTe, cForCTe, cLojCTe)

	Local aAreaAll := {SB1->(GetArea()),ZNF->(GetArea()),SF1->(GetArea()),GetArea()} //Get Areas
	Local cQryExc := ''
	aItens116:= {}
	cBusCTE := GetNextAlias()

	cQryExc += CRLF +" SELECT * "
	cQryExc += CRLF +" FROM " + RetSQLName('ZNF') + " "
	cQryExc += CRLF +" WHERE ZNF_FILIAL = '" + cFilImp +" ' and "
	cQryExc += CRLF +" ZNF_STATUS = '1' and "
	cQryExc += CRLF +" ZNF_TPLANC = '2' and " // P-PRÃƒâ€°-NOTA | VAZIO-MATA103 | 2-MATA116
	cQryExc += CRLF +" ZNF_DOCCTE = '"+cDocCTe+" ' and "
	cQryExc += CRLF +" ZNF_SERCTE = '"+cSerCTe+" ' and "
	cQryExc += CRLF +" ZNF_FORCTE = '"+cForCTe+" ' and "
	cQryExc += CRLF +" ZNF_LOJCTE = '"+cLojCTe+" ' and "
	cQryExc += CRLF +" D_E_L_E_T_ <> '*' "
	cQryExc += CRLF +" ORDER BY ZNF_FILIAL, ZNF_DOC, ZNF_SERIE, ZNF_FORNEC "

	cBusCTE := MPSysOpenQuery(cQryExc, cBusCTE)

	dbSelectArea(cBusCTE)

	Do While !EOF()

		dbSelectArea("SB1")
		dbSetOrder(1)
		If !SB1->(MsSeek(xFilial("SB1")+(cBusCTE)->ZNF_COD))

			Help('',1,'MTUFOPRO',,'PRODUTO Nï¿½O CADASTRADO NO ERP ' + (cBusCTE)->ZNF_COD + ' - FAVOR VERIFICAR' ,1,0)

		EndIf

		dbSelectArea("SF1")
		dbSetOrder(1)
		dbSeek(xFilial('ZNF')+(cBusCTE)->ZNF_DOC+(cBusCTE)->ZNF_SERIE+(cBusCTE)->ZNF_FORNEC+(cBusCTE)->ZNF_LOJA)

		cFilSF1   	 := xFilial("SF1")
		nTamFilial   := Len(cFilSF1)
		aadd(aItens116,{{"PRIMARYKEY",AllTrim(SubStr(&(IndexKey()),nTamFilial + 1))}}) //Tratamento para Gestao Empresas

		dbSelectArea(cBusCTE)
		dbskip()
	Enddo

	dbSelectArea(cBusCTE)
	(dbCloseArea())

	aEval(aAreaAll,{|x| RestArea(x)})

Return(aItens116)


User Function FSBusCTE()
	********************************************************************************
	*
	********************************************************************************

	Local cQryExc	:= ''

	if Select("ZNFCTE") > 0
		dbCloseArea()
	Endif

	cQryExc += CRLF +" SELECT * "
	cQryExc += CRLF +" FROM " + RetSQLName('ZNF') + " "
	cQryExc += CRLF +" WHERE ZNF_FILIAL = '" + cFilImp +" ' and "
	cQryExc += CRLF +" ZNF_STATUS = '1' "
	cQryExc += CRLF +" AND ZNF_TPLANC = '2' " // P-PRÃƒâ€°-NOTA | VAZIO-MATA103 | 2-MATA116
	cQryExc += CRLF +" AND D_E_L_E_T_ <> '*' "
	cQryExc += CRLF +" ORDER BY ZNF_FILIAL, ZNF_DOCCTE, ZNF_SERCTE, ZNF_FORCTE, ZNF_LOJCTE"

	ZNFCTE := MPSysOpenQuery(cQryExc,"ZNFCTE")

Return()

User Function FAtuaCTE(cCodNota, cCodSer, cCodFor, cLojFor,lOkAbax,cMsg)
	********************************************************************************
	*
	********************************************************************************

	Local cQryExc	:= ''
	Local cDbase   := Alltrim(TCGetDB()) //Verificar qual ÃƒÂ© o Banco de Dados do cliente.
	Local aAreaZ   := GetArea()

	If lOkAbax
		cStatus := '2'
	Else
		cStatus := '3'
	Endif

	If cDbase <> 'ORACLE'


		cQryExc := " UPDATE "+RetSqlName("ZNF") +" SET ZNF_STATUS = '"+Alltrim(cStatus)+"' , ZNF_LOG = CAST('" +cMsg+"'  AS VARBINARY(8000)), ZNF_DATA = '" +DTOS(dDataBase)+"' "
		cQryExc += " WHERE ZNF_DOCCTE = '"+cCodNota+"' "
		cQryExc += " AND ZNF_SERCTE = '"+cCodSer+"' "
		cQryExc += " AND ZNF_FORCTE = '"+cCodFor+"' "
		cQryExc += " AND ZNF_LOJCTE = '"+cLojFor+"' "

		If (TCSQLExec(cQryExc) < 0)

			FWLogMsg(;
				"INFO",;    //cSeverity      - Informe a severidade da mensagem de log. As opï¿½ï¿½es possï¿½veis sï¿½o: INFO, WARN, ERROR, FATAL, DEBUG
				,;          //cTransactionId - Informe o Id de identificaï¿½ï¿½o da transaï¿½ï¿½o para operaï¿½ï¿½es correlatas. Informe "LAST" para o sistema assumir o mesmo id anterior
				"INTEGRADOR_ABAX",; //cGroup         - Informe o Id do agrupador de mensagem de Log
				,;          //cCategory      - Informe o Id da categoria da mensagem
				,;          //cStep          - Informe o Id do passo da mensagem
				,;          //cMsgId         - Informe o Id do cï¿½digo da mensagem
				"FONTE MTUFOPRO - ATUALIZAR ZNF - UPDATE ZNF COM LOG -  TCSQLError() " + TCSQLError(),;    //cMessage       - Informe a mensagem de log. Limitada ï¿½ 10K
				,;          //nMensure       - Informe a uma unidade de medida da mensagem
				,;          //nElapseTime    - Informe o tempo decorrido da transaï¿½ï¿½o
				;           //aMessage       - Informe a mensagem de log em formato de Array - Ex: { {"Chave" ,"Valor"} }
				)
		EndIf

		If cStatus = '2'

			cQryExc :="UPDATE "+RetSqlName("SF1")+""+CHR(13)+CHR(10)
			cQryExc +="SET F1_USUSMAR = '"+cUserAbx+"'"+CHR(13)+CHR(10)

			cQryExc +="WHERE F1_DOC = '"+cCodNota+"'"+CHR(13)+CHR(10)
			cQryExc +="AND F1_SERIE = '"+cCodSer+"'"+CHR(13)+CHR(10)
			cQryExc +="AND F1_FORNECE = '"+cCodFor+"'"+CHR(13)+CHR(10)
			cQryExc +="AND F1_LOJA = '"+cLojFor+"'"+CHR(13)+CHR(10)
			cQryExc +="AND D_E_L_E_T_ <> '*'"+CHR(13)+CHR(10)
			If (TCSQLExec(cQryExc) < 0)
				FwLogMsg("ABAX FAtuaCTE - linha 1808", /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01"," Erro Update F1_USUSMAR MATA116 ZUSER- TCSQLError() " + TCSQLError(), 0, (nStart - Seconds()), {})
			Endif
		Endif

	Else // Tratamento para Oracle

		cQryExc += " UPDATE "+RetSqlName("ZNF") +" SET ZNF_STATUS = '"+Alltrim(cStatus)+"' , ZNF_LOG = RAWTOHEX('" +cMsg+"'), ZNF_DATA = '" +DTOS(dDataBase)+"' "
		cQryExc += " WHERE ZNF_DOCCTE = '"+cCodNota+"' "
		cQryExc += " AND ZNF_SERCTE = '"+cCodSer+"' "
		cQryExc += " AND ZNF_FORCTE = '"+cCodFor+"' "
		cQryExc += " AND ZNF_LOJCTE = '"+cLojFor+"' "

		If (TCSQLExec(cQryExc) < 0)

			FWLogMsg(;
				"INFO",;    //cSeverity      - Informe a severidade da mensagem de log. As opï¿½ï¿½es possï¿½veis sï¿½o: INFO, WARN, ERROR, FATAL, DEBUG
				,;          //cTransactionId - Informe o Id de identificaï¿½ï¿½o da transaï¿½ï¿½o para operaï¿½ï¿½es correlatas. Informe "LAST" para o sistema assumir o mesmo id anterior
				"INTEGRADOR_ABAX",; //cGroup         - Informe o Id do agrupador de mensagem de Log
				,;          //cCategory      - Informe o Id da categoria da mensagem
				,;          //cStep          - Informe o Id do passo da mensagem
				,;          //cMsgId         - Informe o Id do cï¿½digo da mensagem
				"FONTE MTUFOPRO - ATUALIZAR ZNF COM LOG - UPDATE  TCSQLError() " + TCSQLError(),;    //cMessage       - Informe a mensagem de log. Limitada ï¿½ 10K
				,;          //nMensure       - Informe a uma unidade de medida da mensagem
				,;          //nElapseTime    - Informe o tempo decorrido da transaï¿½ï¿½o
				;           //aMessage       - Informe a mensagem de log em formato de Array - Ex: { {"Chave" ,"Valor"} }
				)
		EndIf

		If (TCSQLExec('commit') < 0)
			FWLogMsg(;
				"INFO",;    //cSeverity      - Informe a severidade da mensagem de log. As opï¿½ï¿½es possï¿½veis sï¿½o: INFO, WARN, ERROR, FATAL, DEBUG
				,;          //cTransactionId - Informe o Id de identificaï¿½ï¿½o da transaï¿½ï¿½o para operaï¿½ï¿½es correlatas. Informe "LAST" para o sistema assumir o mesmo id anterior
				"INTEGRADOR_ABAX",; //cGroup         - Informe o Id do agrupador de mensagem de Log
				,;          //cCategory      - Informe o Id da categoria da mensagem
				,;          //cStep          - Informe o Id do passo da mensagem
				,;          //cMsgId         - Informe o Id do cï¿½digo da mensagem
				"FONTE MTUFOPRO - ATUALIZAR ZNF - COMMIT - TCSQLError() " + TCSQLError(),;    //cMessage       - Informe a mensagem de log. Limitada ï¿½ 10K
				,;          //nMensure       - Informe a uma unidade de medida da mensagem
				,;          //nElapseTime    - Informe o tempo decorrido da transaï¿½ï¿½o
				;           //aMessage       - Informe a mensagem de log em formato de Array - Ex: { {"Chave" ,"Valor"} }
				)
		endif

		If cStatus = '2'
			cQryExc :="UPDATE "+RetSqlName("SF1")+""+CHR(13)+CHR(10)
			dbSelectArea("SF1")

			If FieldPos("F1_ZUSER") > 0
				cQryExc +="SET F1_ZUSER = '"+cUserAbx+"'"+CHR(13)+CHR(10)
			Else
				cQryExc +="SET F1_USUSMAR = '"+cUserAbx+"'"+CHR(13)+CHR(10)
			Endif

			cQryExc +="WHERE F1_DOC = '"+cCodNota+"'"+CHR(13)+CHR(10)
			cQryExc +="AND F1_SERIE = '"+cCodSer+"'"+CHR(13)+CHR(10)
			cQryExc +="AND F1_FORNECE = '"+cCodFor+"'"+CHR(13)+CHR(10)
			cQryExc +="AND F1_LOJA = '"+cLojFor+"'"+CHR(13)+CHR(10)
			cQryExc +="AND D_E_L_E_T_ <> '*'"+CHR(13)+CHR(10)

			If (TCSQLExec(cQryExc) < 0)
				cQryExc :="UPDATE "+RetSqlName("SF1")+""+CHR(13)+CHR(10)
				cQryExc +="SET F1_USUSMAR = '"+cUserAbx+"'"+CHR(13)+CHR(10)
				cQryExc +="WHERE F1_DOC = '"+cCodNota+"'"+CHR(13)+CHR(10)
				cQryExc +="AND F1_SERIE = '"+cCodSer+"'"+CHR(13)+CHR(10)
				cQryExc +="AND F1_FORNECE = '"+cCodFor+"'"+CHR(13)+CHR(10)
				cQryExc +="AND F1_LOJA = '"+cLojFor+"'"+CHR(13)+CHR(10)
				cQryExc +="AND D_E_L_E_T_ <> '*'"+CHR(13)+CHR(10)
				If (TCSQLExec(cQryExc) < 0)
					If (TCSQLExec('commit') < 0)
						FWLogMsg(;
							"INFO",;    //cSeverity      - Informe a severidade da mensagem de log. As opï¿½ï¿½es possï¿½veis sï¿½o: INFO, WARN, ERROR, FATAL, DEBUG
							,;          //cTransactionId - Informe o Id de identificaï¿½ï¿½o da transaï¿½ï¿½o para operaï¿½ï¿½es correlatas. Informe "LAST" para o sistema assumir o mesmo id anterior
							"INTEGRADOR_ABAX",; //cGroup         - Informe o Id do agrupador de mensagem de Log
							,;          //cCategory      - Informe o Id da categoria da mensagem
							,;          //cStep          - Informe o Id do passo da mensagem
							,;          //cMsgId         - Informe o Id do cï¿½digo da mensagem
							"FONTE MTUFOPRO - ATUALIZAR ZNF COM LOG - UPDATE SF1 COM DADOS DO CTE - TCSQLError() " + TCSQLError(),;    //cMessage       - Informe a mensagem de log. Limitada ï¿½ 10K
							,;          //nMensure       - Informe a uma unidade de medida da mensagem
							,;          //nElapseTime    - Informe o tempo decorrido da transaï¿½ï¿½o
							;           //aMessage       - Informe a mensagem de log em formato de Array - Ex: { {"Chave" ,"Valor"} }
							)
					Endif
				Endif
			EndIf

			If (TCSQLExec('commit') < 0)
				FWLogMsg(;
					"INFO",;    //cSeverity      - Informe a severidade da mensagem de log. As opï¿½ï¿½es possï¿½veis sï¿½o: INFO, WARN, ERROR, FATAL, DEBUG
					,;          //cTransactionId - Informe o Id de identificaï¿½ï¿½o da transaï¿½ï¿½o para operaï¿½ï¿½es correlatas. Informe "LAST" para o sistema assumir o mesmo id anterior
					"INTEGRADOR_ABAX",; //cGroup         - Informe o Id do agrupador de mensagem de Log
					,;          //cCategory      - Informe o Id da categoria da mensagem
					,;          //cStep          - Informe o Id do passo da mensagem
					,;          //cMsgId         - Informe o Id do cï¿½digo da mensagem
					"FONTE MTUFOPRO - ATUALIZAR ZNF COM LOG - UPDATE SF1 COM DADOS DO CTE - TCSQLError() " + TCSQLError(),;    //cMessage       - Informe a mensagem de log. Limitada ï¿½ 10K
					,;          //nMensure       - Informe a uma unidade de medida da mensagem
					,;          //nElapseTime    - Informe o tempo decorrido da transaï¿½ï¿½o
					;           //aMessage       - Informe a mensagem de log em formato de Array - Ex: { {"Chave" ,"Valor"} }
					)
			Endif
		Endif

	Endif

	RestArea(aAreaZ)

Return(Nil)


Static Function FNatRend()
	/*/{Protheus.doc} FNatRend
	Adequa  o do execauto para uso da natureza de rendimento.
	@type  Static Function
	@author Diogo Romie
	@since 28/02/2023
	@version P12
	/*/

	Local nX := 1
	Local aItem := {}
	Local aItensDHR := {}
	Local nPos := 0

	For nX := 1 to len(_aCabSF1)
		nPos := ASCAN(_aCabSF1[nX], 'E2_NATUREZ' )
		If nPos == 1
			EXIT
		EndIf
	next

	//SB5->(DbSetOrder(1))
	SED->(DbSetOrder(1)) //ED_FILIAL+ED_CODIGO
	F2Q->(DbSetOrder(1)) //F2Q_FILIAL+F2Q_PRODUT
	If nPos == 1 .And. !Empty(_aCabSF1[nX][2]) .And. SED->(MsSeek(xFilial('SED')+_aCabSF1[nX][2])) //Natureza
		for nX := 1 to len(_aItensSD1)
			//Codigo Produto
			If !Empty(_aItensSD1[nX][3][2]) .And. F2Q->(MsSeek(SubStr(_aItensSD1[nX][1][2],1,4)+Space(4)+_aItensSD1[nX][3][2])) /*SB5->(MsSeek(xFilial('SB5')+_aItensSD1[nX][3][2]))*/ .And.;
					!Empty(F2Q->F2Q_NATREN) .And.;
					(SED->ED_CALCIRF == 'S' .Or. SED->ED_CALCCSL == 'S' .Or. SED->ED_CALCCOF == 'S' .Or. SED->ED_CALCPIS == 'S')

				aAdd(aItensDHR, Array(2))
				aItensDHR[Len(aItensDHR)][1] := StrZero(nX,TamSx3("DHR_ITEM")[1])
				aItensDHR[Len(aItensDHR)][2] := {}

				aAdd(aItem, {"DHR_FILIAL"   , _aItensSD1[nX][1][2]              , Nil})
				aAdd(aItem, {"DHR_ITEM"     , StrZero(nX,TamSx3("DHR_ITEM")[1]) , Nil})
				aAdd(aItem, {"DHR_DOC"      , _aItensSD1[nX][12][2]             , Nil})
				aAdd(aItem, {"DHR_SERIE"    , _aItensSD1[nX][15][2]             , Nil})
				aAdd(aItem, {"DHR_FORNECE"  , _aItensSD1[nX][10][2]             , Nil})
				aAdd(aItem, {"DHR_LOJA"     , _aItensSD1[nX][11][2]             , Nil})
				aAdd(aItem, {"DHR_NATREN"   , F2Q->F2Q_NATREN       			, Nil})
				/*aAdd(aItem, {"DHR_NATREN"   , SB5->B5_XNATREN       			, Nil})*/  // Campo ser  exclu do da base. 07/08/20223 - Diogo Romie
				aAdd(aItem, {"DHR_PSIR"     , ""                      			, Nil})
				aAdd(aItem, {"DHR_TSIR"     , ""                                , Nil})
				aAdd(aItem, {"DHR_ISIR"     , ""                  				, Nil})
				aAdd(aItem, {"DHR_BASUIR"   , 0                              	, Nil})
				aAdd(aItem, {"DHR_PSPIS"    , ""                      			, Nil})
				aAdd(aItem, {"DHR_TSPIS"    , ""                                , Nil})
				aAdd(aItem, {"DHR_ISPIS"    , ""                  				, Nil})
				aAdd(aItem, {"DHR_BSUPIS"   , 0                              	, Nil})
				aAdd(aItem, {"DHR_PSCOF"    , ""                      			, Nil})
				aAdd(aItem, {"DHR_TSCOF"    , ""                                , Nil})
				aAdd(aItem, {"DHR_ISCOF"    , ""                  				, Nil})
				aAdd(aItem, {"DHR_BSUCOF"   , 0                              	, Nil})
				aAdd(aItem, {"DHR_PSCSL"    , ""                      			, Nil})
				aAdd(aItem, {"DHR_TSCSL"    , ""                                , Nil})
				aAdd(aItem, {"DHR_ISCSL"    , ""                  				, Nil})
				aAdd(aItem, {"DHR_BSUCSL"   , 0                              	, Nil})
				aAdd(aItensDHR[Len(aItensDHR)][2], aClone(aItem))

			EndIf
		next
	EndIf

Return aItensDHR

