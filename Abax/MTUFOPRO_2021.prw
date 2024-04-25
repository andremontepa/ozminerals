#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"    
#INCLUDE 'TOTVS.CH'   
#Define CRLF  CHR(13)+CHR(10)
//usuario abax 
//Senha abax2019
//STATIC __cFilePath  := '\UFO_NFE\'
//STATIC __cLogsPath	:= 'log\'

//------------------------------------------------------------------- 
/*/{Protheus.doc} MTUFOPRO

	Programa utilizado para realizar a integraÃ§Ã£o entre os sistemas
	UFO X Protheus. IntegraÃ§Ã£o serÃ¡ realizada atraves da tabela ZNF
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
Local aTables := {"SA1","SA2","SF1","SD1","SF2","SD2","CTT","ZNF", "SF4","SB6","SB1","CT1","SE2",'SX6'}//seta as tabelas que serÃ£o abertas no rpcsetenv
Local nI := 0
Local nAbax := 0      
Private nStart := 0 
default cEmpAbx := '01'
default cFilAbx := '01'
default cIdAbx  := ''

cError      := "" // Tratamento para erros nÃ£o amigaveis finalizar a tela.
oLastError := ErrorBlock({|e| cError := e:Description + e:ErrorStack})
   	
If Empty(cIdAbx)

	aInfo := GetUserInfoArray()
	nI	  := 1
	For nI := 1 to Len(aInfo)
   		If aInfo[nI][5] == "U_MTUFOPRO" .And. aInfo[nI][3] <> Threadid()                                              
   		
	   		FwLogMsg("INFO-ABAX", /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01", "FunÃ§Ã£o MTUFOPRO sendo Utilizada.", 0, (nStart - Seconds()), {})

       		Return      
   		EndIf
	Next nI
	   
   lthread := .T. 
  
    RpcSetEnv( '01','01', " ", " ", "COM", "MATA103", aTables, , , ,  )/****** COMANDOS *************/	
    cUsuSm := Space(1) 
    cSenSm := Space(1) 

	FwLogMsg("INICIO IMPORTAÃ‡ÃƒO SMARTNFE - FONTE MTUFOPRO.", /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01", "INICIO IMPORTAÃ‡ÃƒO SMARTNFE - FONTE MTUFOPRO.", 0, (nStart - Seconds()), {})	

	//Criar ZNF no primeiro acesso
	//dbSelectArea('ZNF')
	//Fun��o busca as Filiais cadastradas no sigamat.emp Leo Viana 26/10/2015           
	OpenSM0()
	dbSelectarea('SM0')
	SM0->(dbGotop())
	      	
	Do While SM0->(!Eof())	
					
		Aadd(aEmpSmar,{SM0->M0_CODIGO,SM0->M0_CODFIL})		  			
		SM0->(dbSkip())			
				
    Enddo		
				
	RpcClearEnv()
	RESET ENVIRONMENT
		   	   	
	//Asort(aEmpSmar,,,{| x,y | x[2] > y[2]})
	
	cEmpABax := aEmpSmar[1][1]     
	RpcSetEnv( aEmpSmar[1][1],aEmpSmar[1][2]," " ," " , "COM", "MATA103", aTables, , , ,  )
	
    nAbax:=1 	
	For nAbax:=1 to Len(aEmpSmar)
			
		If cEmpABax = aEmpSmar[nAbax][1]
			cFilAnt := aEmpSmar[nAbax][2]
			cEmpABax := aEmpSmar[nAbax][1]
	  	Else
			RpcClearEnv() 
			cEmpABax := aEmpSmar[nAbax][1]
		   RpcSetEnv( aEmpSmar[nAbax][1],aEmpSmar[nAbax][2]," " ," ", "COM", "MATA103", aTables, , , ,  )/****** COMANDOS *************/					  
		Endif

		If CHKFILE("ZNF", .F.) 
			FwLogMsg("ACHOU ZNF - FONTE MTUFOPRO.", /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01", "INICIO IMPORTAÃ‡ÃƒO SMARTNFE - FONTE MTUFOPRO.", 0, (nStart - Seconds()), {})	
			U_MImpNFs(aEmpSmar[nAbax][1],aEmpSmar[nAbax][2],cUsuSm,cSenSm)			   			   			
		Else            
			FwLogMsg('EMPRESA SEM ZNF' , /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01",'EMPRESA SEM ZNF' + aEmpSmar[nAbax][1], 0, (nStart - Seconds()), {})
		Endif
		
	Next	
	
	FwLogMsg("INFO-ABAX", /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01",'FIM IMPORTAÃ‡ÃƒO SMARTNFE - FONTE MTUFOPRO', 0, (nStart - Seconds()), {})
	RpcClearEnv()  
	
Else	
   RpcSetEnv( cEmpAbx,cFilAbx," " ," ", "COM", "MATA103", aTables, , , ,  ) 
   cUsuSm :=  Space(1)
	cSenSm := Space(1) 
 	U_MImpNFs(cEmpAbx,cFilAbx,cUsuSm,cSenSm)			   			   
 	RpcClearEnv()
Endif

U_MTCTEPRO() // Execu��o de importa��o de CTE pela rotina MATA116 Voltar Leo Viana 20170419

Return

User Function MImpNFs(cEmpMa,cFilMa,cUsusm,cSenSm)
******************************************************************************
* FunÃ§Ã£o para importar  notas para o Protheus. Foi desmembrado a funÃ§Ã£o devido
* a empresas que possuem muitas empresas e filiais.
******************************************************************************
 
	FwLogMsg("MImpNFs-ABAX", /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01",'PROCESSO IMPORTAÃ‡ÃƒO SMARTNFE - FONTE MTUFOPRO - Empresa ' +cEmpMa + ' Filial '+cFilMa, 0, (nStart - Seconds()), {})
	FwLogMsg("MImpNFs2-ABAX", /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01",'SIGAMAT.EMP ' + SM0->M0_CODIGO+'-'+SM0->M0_CODFIL, 0, (nStart - Seconds()), {})
	 
 	u_FSBusDados(cFilMa)
		
 	dbSelectArea('ZNFTEMP')
 	ZNFTEMP->(dbGoTop()) 
 
 	If !Empty(ZNFTEMP->ZNF_DOC+ZNFTEMP->ZNF_SERIE+ZNFTEMP->ZNF_FORNEC+ZNFTEMP->ZNF_LOJA)
		/* Fun��o Gera NF de Entrada dentro do sistema Protheus*/
		U_FSGeraNFE()
		FwLogMsg("FIM PROCESSO IMPORTAÃ‡ÃƒO - ABAX", /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01",'FIM PROCESSO IMPORTAÃ‡ÃƒO SMARTNFE - FONTE MTUFOPRO - Empresa ' +cEmpMa + ' Filial '+cFilMa, 0, (nStart - Seconds()), {})

 	Else
 	
		FwLogMsg("FIM PROCESSO SEM MOVIMENTO - ABAX", /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01",'FIM PROCESSO SEM MOVIMENTO - FONTE MTUFOPRO - Empresa ' +cEmpMa + ' Filial '+cFilMa, 0, (nStart - Seconds()), {})

 	Endif		 				  						 					
 	
 	If Select('ZNFTEMP') > 0
	 	dbSelectArea('ZNFTEMP')
	 	dbCloseArea()
	Endif
	 	
Return    
	

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSBusDados

	Fun��o responsavel por buscar os dados a serem integrados
	Informa��es originadas diretamente do Sistema UFO
	@author 	Helder Santos
	@since		31.03.2014
	@Return		cPrefix - Alias carregado com as informaÃ§Ãµes
	@version	P11

---------------------------------------------------------------------
Programador		Data		Motivo
---------------------------------------------------------------------
/*/

User Function FSBusDados(cFilImp)

	Local cPreWMS := GetNextAlias()                                                                        
	Local cQryExc := ''                                                                   
	Local cFilWms, cDocWMS, cSerWMS, cForWMS,cLojWMS,cCodWms,cTesWms, cNatWMS := ''
	Local nRecWMS	
	FwLogMsg("FSBusDados 1 -ABAX", /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01",'SIGAMAT.EMP ' + SM0->M0_CODIGO+'-'+SM0->M0_CODFIL, 0, (nStart - Seconds()), {})
   /*----------------------------------------------------------------------------------------------
   Tratamento para igualar ZNF com SD1
   ------------------------------------------------------------------------------------------------*/
	cQryExc := CRLF +" SELECT  * "   	
	cQryExc += CRLF +" FROM " + RetSQLName('ZNF') + " ZNF " 
	cQryExc += CRLF +" WHERE ZNF_FILIAL = '" + Alltrim(cFilImp) +"' and "    
	cQryExc += CRLF +" ZNF_TPLANC = 'W' "	
	cQryExc += CRLF +" AND ZNF_STATUS <> '2' "                                             
	cQryExc += CRLF +" AND D_E_L_E_T_ <> '*' "
	cQryExc += CRLF +" ORDER BY ZNF_FILIAL, ZNF_DOC, ZNF_SERIE, ZNF_FORNEC,ZNF_TOTAL DESC "      
	cPreWMS := MPSysOpenQuery(cQryExc, 'cPreWMS')
	FwLogMsg("FSBusDados 2 -ABAX" + cPreWMS, /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01",'SIGAMAT.EMP ' + SM0->M0_CODIGO+'-'+SM0->M0_CODFIL + ' Query ' +cQryExc, 0, (nStart - Seconds()), {})
	dbSelectArea(cPreWMS)
	   
	If !Empty(Alltrim(cPreWMS->ZNF_DOC))
		
		cIteSD1 := ' '//nTotItem := (cPreWMS)->ZNF_QUANT                            
		
		Do While !Eof()
	   		   
	  		cFilWms := (cPreWM)->ZNF_FILIAL
			cDocWMS := (cPreWMS)->ZNF_DOC 
			cSerWMS := (cPreWMS)->ZNF_SERIE
			cForWMS := (cPreWMS)->ZNF_FORNEC
			cLojWMS := (cPreWMS)->ZNF_LOJA
			cCodWms := (cPreWMS)->ZNF_COD
			nRecWMS := (cPreWMS)->R_E_C_N_O_
			cTesWms := (cPreWMS)->ZNF_TES 
			cNatWMS := (cPreWMS)->ZNF_NATUR
			cDtWMS  := (cPreWMS)->ZNF_DTDIGI
		   cUseWMS := (cPreWMS)->ZNF_USERLG
			cStWMS  := (cPreWMS)->ZNF_STATUS
			cConWMS := (cPreWMS)->ZNF_COND
			cChvWMS := (cPreWMS)->ZNF_CHVNFE
		   cEspWMS := (cPreWMS)->ZNF_ESPEC
			nPBrWMS := (cPreWMS)->ZNF_PBRUTO
			nPLWMS  := (cPreWMS)->ZNF_PLIQUI
			dReWMS  := (cPreWMS)->ZNF_RECBMT      
			nVolWMS := (cPreWMS)->ZNF_VOLUME
			nVBWMS  := (cPreWMS)->ZNF_VLBRUT
			cTPWMS  := (cPreWMS)->ZNF_TPLANC
	  		
	  		dbSelectArea('SD1')
	  		dbsetOrder(11)
	  		dbSeek(xFilial('SD1')+(cPreWMS)->ZNF_DOC+(cPreWMS)->ZNF_SERIE+(cPreWMS)->ZNF_FORNEC+(cPreWMS)->ZNF_LOJA+Alltrim((cPreWMS)->ZNF_COD)) // Chave Indice //
						
			Do While !eof() .and. ( SD1->D1_FILIAL == cFilWms .and. SD1->D1_DOC == cDocWMS .and. SD1->D1_SERIE == cSerWMS .and. SD1->D1_FORNECE == cForWMS .and. SD1->D1_LOJA == cLojWMS .and. Alltrim(SD1->D1_COD) == Alltrim(cCodWMS) )                                                                                                         
	         
	         If !SD1->D1_ITEM $ cIteSD1        		  			
		  			dbSelectArea('ZNF')
		  			RecLock('ZNF',.T.)	
					ZNF_FILIAL	:=	SD1->D1_FILIAL 
					ZNF_ITEM    :=	SD1->D1_ITEM      
					ZNF_COD		:=	SD1->D1_COD       
					ZNF_PEDIDO	:=	SD1->D1_PEDIDO    
					ZNF_ITEMPC 	:=	SD1->D1_ITEMPC    
					ZNF_QUANT   :=	SD1->D1_QUANT     
					ZNF_VUNIT   :=	SD1->D1_VUNIT     
					ZNF_TOTAL   :=	SD1->D1_TOTAL 
					ZNF_TPLANC  := cTPWMS
					ZNF_TES     :=	cTesWms       
					ZNF_DTDIGI := Stod(cDtWMS)
					ZNF_USERLG  := cUseWMS
					ZNF_STATUS  := cStWMS
					ZNF_COND    := cConWMS
					ZNF_CHVNFE  := cChvWMS
					ZNF_ESPEC	:= cEspWMS
					ZNF_PBRUTO  := nPBrWMS
					ZNF_PLIQUI  := nPLWMS					
					ZNF_VOLUME  := nVolWMS
					ZNF_VLBRUT	:= nVBWMS
					ZNF_LOTEFO	:=	SD1->D1_LOTEFOR     
					ZNF_LOTECT	:=	SD1->D1_LOTECTL     
					ZNF_DTVALI	:=	SD1->D1_DTVALID     
					ZNF_DFABRI	:=	SD1->D1_DFABRIC     					
					ZNF_SERIE 	:=	SD1->D1_SERIORI 
					ZNF_LOCAL 	:=	SD1->D1_LOCAL   
					ZNF_FORNEC  :=	SD1->D1_FORNECE   
					ZNF_LOJA    :=	SD1->D1_LOJA      
					ZNF_DOC     :=	SD1->D1_DOC       
					ZNF_EMISSA	:=	SD1->D1_EMISSAO   
					ZNF_SERIE   :=	SD1->D1_SERIE     
					ZNF_TIPO    :=	SD1->D1_TIPO      
					ZNF_VALDES	:=	SD1->D1_VALDESC 
					ZNF_VALICM  :=	SD1->D1_VALICM  
					ZNF_PICM    :=	SD1->D1_PICM   
					ZNF_BSICM   :=	SD1->D1_BASEICM   
					ZNF_ICMSCO  :=	SD1->D1_ICMSCOM   
					ZNF_BSIPI 	:=	SD1->D1_BASEIPI   
					ZNF_PIPI	:=	SD1->D1_IPI  
					ZNF_VALIPI  :=	SD1->D1_VALIPI  
					ZNF_ALQPIS	:=	SD1->D1_ALQPIS  
					ZNF_ALQCOF	:=	SD1->D1_ALQCOF  
					ZNF_ALQCSL	:=	SD1->D1_ALQCSL  
					ZNF_VALPIS	:=	SD1->D1_VALPIS  
					ZNF_VALCSL	:=	SD1->D1_VALCSL  
					ZNF_VALCOF	:=	SD1->D1_VALCOF  
					ZNF_BASPIS	:=	SD1->D1_BASEPIS 
					ZNF_BASCOF	:=	SD1->D1_BASECOF 
					ZNF_BASCSL	:=	SD1->D1_BASECSL 
					ZNF_BASIRR	:=	SD1->D1_BASEIRR 
					ZNF_ALIIRR	:=	SD1->D1_ALIQIRR 
					ZNF_VALIRR	:=	SD1->D1_VALIRR  
					ZNF_BASISS	:=	SD1->D1_BASEISS 
					ZNF_BRICMS	:=	SD1->D1_BRICMS  
					ZNF_ALISOL	:=	SD1->D1_ALIQSOL   
					ZNF_ICMRET	:=	SD1->D1_ICMSRET  
					ZNF_CONTA	:=	SD1->D1_CONTA  
					ZNF_ABATMA  :=	SD1->D1_ABATMAT   
					ZNF_BASEIN  :=	SD1->D1_BASEINS   
					ZNF_ALIQIN  :=	SD1->D1_ALIQINS   
					ZNF_VALIN   :=	SD1->D1_VALINS   
					ZNF_ALIISS	:=	SD1->D1_ALIQISS 
					ZNF_VALISS  :=	SD1->D1_VALISS  
					ZNF_CFOP 	:=	SD1->D1_CF  
					ZNF_CC	   :=	SD1->D1_CC  
					ZNF_NATUR   := cNatWMS
		      	MsUnlock()
		      Endif	
	      	cIteSD1 += '_'+SD1->D1_ITEM
	      	dbSelectArea('SD1')
				DBskip()
				
			Enddo
	      
			
	        cQryDel := " UPDATE "+RetSqlName("ZNF") 
			cQryDel += " SET ZNF_STATUS = '2' WHERE R_E_C_N_O_  = '"+Alltrim(STR(nRecWMS))+"' "
	         
			If (TCSQLExec(cQryDel) < 0)
				FwLogMsg("INFO-ABAX", /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01","NÃƒO AJUSTOU ZNF - ERRO AJUSTES WMS - TCSQLError() " + TCSQLError(), 0, (nStart - Seconds()), {})
			EndIf
				
			dbSelectArea(cPreWMS)
	      dbSkip()
	      
			cFilWms := (cPreWMS)->ZNF_FILIAL
			cDocWMS := (cPreWMS)->ZNF_DOC 
			cSerWMS := (cPreWMS)->ZNF_SERIE
			cForWMS := (cPreWMS)->ZNF_FORNEC
			cLojWMS := (cPreWMS)->ZNF_LOJA
			cCodWms := (cPreWMS)->ZNF_COD
			nRecWMS := (cPreWMS)->R_E_C_N_O_
			cTesWms := (cPreWMS)->ZNF_TES 
			cNatWMS := (cPreWMS)->ZNF_NATUR
				
		Enddo
	   
	   dbSelectArea(cPreWMS)
	   dbCloseArea()
   Else
	   dbSelectArea(cPreWMS)
	   dbCloseArea()   
   Endif
   
	cQryExc	:= '' 
	
	cQryExc := CRLF +" SELECT * "   	
	cQryExc += CRLF +" FROM " + RetSQLName('ZNF') + " "
	cQryExc += CRLF +" WHERE ZNF_FILIAL = '" + Alltrim(cFilImp) +"' and "    
	//Leonardo Viana - Inclu��o do filtro para escolher somente notas que deverÃ£o ser inseridas pela rotina MATA103 - ZNF_TPLANC <> 2 - 	TPLANC = VAZIO NOTA FISCAL MATA103; 	TPLANC = P PRÃ‰ NOTA MATA103; TPLANC = 2 CTE COM NF VINCULADA MATA116
	cQryExc += CRLF +" ZNF_TPLANC <> '2' "	 
	cQryExc += CRLF +" AND ZNF_STATUS <> '2' "                                                                 
	cQryExc += CRLF +" AND D_E_L_E_T_ <> '*' "
	cQryExc += CRLF +" ORDER BY ZNF_FILIAL, ZNF_DOC, ZNF_SERIE, ZNF_FORNEC "    
	ZNFTEMP := MPSysOpenQuery(cQryExc, 'ZNFTEMP')	 

	FwLogMsg("FSBusDados 2- ZNFTEMP -ABAX" + cPreWMS, /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01",'SIGAMAT.EMP ' + SM0->M0_CODIGO+'-'+SM0->M0_CODFIL + ' Query ' +cQryExc, 0, (nStart - Seconds()), {})
	
Return(ZNFTEMP)   


//------------------------------------------------------------------- 
/*/{Protheus.doc} FSGeraNFE

	FunÃ§Ã£o responsavel pela geraÃ§Ã£o da NFE dentro do sistema Protheus
	@author 	Helder Santos
	@since		31.03.2014
	@Parm1		cPrefix - Alias com as informaÃ§oes da NFE		
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
	Local cLocSC7	:= ''  //Declara��o VariÃ¡vel.
	Private aCabec     := {} // ALTERADO DE LUGAR
	Private  cTpLanc   := ''
	Private _aCabSF1   		:= {}  
	Private _aLinha	   	:= {}   
	Private _aItensSD1		:= {}	
	Private aCodRet	 		:= {} //código de retenção IR
	Private lMsErroAuto		:= .F.    
	Private lAutoErrNoFile  := .T. //<= para nao gerar arquivo e pegar o erro com a funcao GETAUTOGRLOG()
	Private nTotItem		:= 1 // 20/08/2015 -Criado vÃ¡riÃ¡vel nTotItem para contar quantos itens a Nota Possui  
	Private nFretAbax		:= 0     //09/12/2016 - Criado para totalizar o frete do Pedido de Compra.
	Private nVBrtAbax		:= 0        //Valor Bruto Nota Fiscal
	Private cCondAbax    := Space(3) //Condicao de pagamento   
	Private dDtVAbax		:= dDatabase
	Private cMAVenc		:= Space(250) //String com dados do vencimento.
	Private cRecIss	   := Space(1) 
	Private cSerDES		:= Space(1) //06/10/2017 - Campo par fazer De Para da DESBH 
	Private nBolAbax		:= 1			// 27/09/2017 - Leonardo Vasco - Melhoria Oncoclinicas -   
	Private aBolAbax 		:= {}       // 27/09/2017 - Leonardo Vasco - Melhoria Oncoclinicas - Campo utilizado para gravar os cÃ³digos de barras dos boletos 
	Private nToItem      := 0 //Leonardo Viana 09/01/2018 - Total de Itens a serem importados. Melhoria para sÃ³ importar quando todos os itens forem enviados para a ZNF.
	Private nTotAbax     := 0  //Leonardo Viana 09/01/2018 - Total de Itens a serem importados. Melhoria para sÃ³ importar quando todos os itens forem enviados para a ZNF.
	Private lErroAba     := .F. //Leonardo Viana 09/01/2018 - Total de Itens a serem importados. Tratamento para nÃ£o executar Execauto caso ocorra problema de exportaÃ§Ã£o para a ZNF.	
	Private cBancAba     := '' //InformaÃ§Ãµes referentes aos dados bancÃ¡rios. 
	Private cAgenAba     := '' // Estas variÃ¡veis poderÃ£o ser utilizadas nos pontos de entradas 
    Private cContAba     := ''	// no momento de gerar os tÃ­tulos a pagar.  
    Private cTipFret     := '' //Tipo do Frete
	Private lDtVAbax     := .F.//Variaveis novas Dic no banco
	Private lLOCSB6		 := .F. //Variaveis novas Dic no banco
	Private cSitTrib     := ''  // situação tributária da TES
	Private nBTotIPI     := 0 //Base total do IPI
	Private nVTotIPI     := 0 //Valor Total do IPI
	Private nPIPI        := 0 //Percentual de IPI
	Private aAutoImp     := {} //Array de envio de Impostos IPI
	
 	Private cDiaIss := Alltrim(GetMV("MV_DIAISS"))       
	Private cAltPrcc := Alltrim(GetMV("MV_ALTPRCC"))       
 
	PutMV("MV_ALTPRCC","0") //Desabilitar parâmetro que obriga o valor da nota fiscal ser igual ao valor do pedido de compra. Não tem relação com margem de tolerância.
 
	FwLogMsg("DENTRO FSGeraNFE 1 - ABAX", /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01",'FIM PROCESSO IMPORTAÃ‡ÃƒO SMARTNFE - FONTE MTUFOPRO - Empresa ' , 0, (nStart - Seconds()), {})
	nZ:=1          
	dbSelectArea('ZNFTEMP')

	ZNFTEMP->(dbGoTop())		
	FwLogMsg("DENTRO FSGeraNFE 2 - ABAX" + ZNFTEMP->ZNF_DOC  , /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01",'FIM PROCESSO IMPORTAÃ‡ÃƒO SMARTNFE - FONTE MTUFOPRO - Empresa ', 0, (nStart - Seconds()), {})
	FwLogMsg("DENTRO FSGeraNFE 3 - ABAX" + ZNFTEMP->ZNF_SERIE, /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01",'FIM PROCESSO IMPORTAÃ‡ÃƒO SMARTNFE - FONTE MTUFOPRO - Empresa ' , 0, (nStart - Seconds()), {})
	FwLogMsg("DENTRO FSGeraNFE 4 - ABAX" + ZNFTEMP->ZNF_FORNEC, /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01",'FIM PROCESSO IMPORTAÃ‡ÃƒO SMARTNFE - FONTE MTUFOPRO - Empresa ' , 0, (nStart - Seconds()), {})
	FwLogMsg("DENTRO FSGeraNFE 5 - ABAX" + ZNFTEMP->ZNF_LOJA  , /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01",'FIM PROCESSO IMPORTAÃ‡ÃƒO SMARTNFE - FONTE MTUFOPRO - Empresa ' , 0, (nStart - Seconds()), {})	
	//Altera�� devido a build Lobo Guar� Protheus - Dicionario no Banco
	//Caso parametro n�o exista, ser� considerado .T. e pega� a data de emissÃ£o da nota fiscal.
	//Data: 06/05/2020
	//Autor: Leonardo Viana
	if SuperGetMV('MA_VENABAX',.F.,.T.)  //Se .T. ira considerar data de emissao		
		lDtVAbax := .T.			
	Endif	

	If SuperGetMV('MA_LOCSB6',.F.,.T.)	     
		lLOCSB6 := .T.	
	Endif

	Do While ZNFTEMP->(!Eof())
	
		cFilAnt	:= ZNFTEMP->ZNF_FILIAL     
					
		nToItem++ //Leonardo Viana 09/01/2018 - Total de Itens a serem importados. Melhoria para sÃ³ importar quando todos os itens forem enviados para a ZNF.
		
		__cSeekNF:=ZNFTEMP->ZNF_DOC+ZNFTEMP->ZNF_SERIE+ZNFTEMP->ZNF_FORNEC+ZNFTEMP->ZNF_LOJA
		
		cDocSMA := 	ZNFTEMP->ZNF_DOC
		cSerSMA :=  ZNFTEMP->ZNF_SERIE
		cForSMA := ZNFTEMP->ZNF_FORNEC			
		cLojSMA := ZNFTEMP->ZNF_LOJA			  

    	If ZNFTEMP->ZNF_TIPO $ 'N_I_P_C'		
			SA2->(dbSetorder(01))    //Alltrim(ZNFTEMP->ZNF_FORNEC)
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
		D = DevoluÃ§Ã£o
		I = NF Compl. ICMS
		P = NF Compl. IPI
		C = Complemento
		B = Beneficiamento.*/
		
		
		///Melhoria para tratar Pedidos de Filiais Diferentes - 
	  	dbSelectArea('SC7')  
	  	SC7->(dbSetOrder(01))
		If Empty(ZNFTEMP->ZNF_EMP)
			SC7->(dbSeek(xFilial('SC7')+ZNFTEMP->ZNF_PEDIDO+Alltrim(ZNFTEMP->ZNF_ITEMPC)))
		Else
			SC7->(dbSeek(ZNFTEMP->ZNF_EMP+ZNFTEMP->ZNF_PEDIDO+Alltrim(ZNFTEMP->ZNF_ITEMPC)))
		Endif
	  	//Leonardo Viana - Pegar Lote do SC7 para as situa��o onde n�o existe Lote na ZNF
		cLocSC7 := SC7->C7_LOCAL	
		cCCSC7  := SC7->C7_CC //Vari�vel para pegar Centro de Custo do Produto	
				
		If !lImport		                                 
         //Trocado Log para mostrar s�o uma vez no console.log, da forma antiga a nota era grava para cada item da mesma.          //Leonardo Vasco Viana 21/07/2017
			
			FwLogMsg("INFO-ABAX", /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01",'MTUFOPRO - IMPORTANDO NOTA  '+ ZNFTEMP->ZNF_DOC+'-'+ ZNFTEMP->ZNF_SERIE+'-'+ZNFTEMP->ZNF_FORNEC+'-'+ZNFTEMP->ZNF_LOJA, 0, (nStart - Seconds()), {})
			
			If ZNFTEMP->ZNF_ESPEC == 'NFE' 
				cEspecie	:= 'SPED' 
			Else 
				cEspecie	:= ZNFTEMP->ZNF_ESPEC			
			Endif
			
			nTotItem    := 1  
			nValFreA     := ZNFTEMP->ZNF_FRETE	 //Valor total do Frete
			/* Carrega informa��es do cabe�alho da Nota Fiscal*/
			Aadd(_aCabSF1,{"F1_FILIAL"   ,cFilAnt									,Nil}) 
			Aadd(_aCabSF1,{"F1_DOC"      ,ZNFTEMP->ZNF_DOC    			   			,Nil})
			Aadd(_aCabSF1,{"F1_SERIE"    ,ZNFTEMP->ZNF_SERIE  			   			,Nil})
			Aadd(_aCabSF1,{"F1_FORNECE"  ,ZNFTEMP->ZNF_FORNEC			  			,Nil})	//SA2->A2_COD	    	
			Aadd(_aCabSF1,{"F1_LOJA"     ,Alltrim(ZNFTEMP->ZNF_LOJA)  			 	,Nil})	//SA2->A2_LOJA    		,Nil})              
			If cTpLanc <> 'P'
				Aadd(_aCabSF1,{"F1_COND"     ,cConPAba 			  			 		  	,Nil})  // Caso o campo ZNF_COND esteja vazio, pegarÃ¡ essa informaÃ§Ã£o do cadastro do Cliente/Fornecedor
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
			Aadd(_aCabSF1,{"F1_EMISSAO"  ,Stod(ZNFTEMP->ZNF_EMISSA) 	  				,Nil})
			Aadd(_aCabSF1,{"F1_EST"      ,cEstSM			    						,Nil})  //Estado do Cliente ou do Fornecedor     
			Aadd(_aCabSF1,{"F1_TIPO"     ,ZNFTEMP->ZNF_TIPO				  				,Nil}) 	// SerÃ¡ buscado o tipo da ZNF e nÃ£o mais como N
			
			if !Empty(ZNFTEMP->ZNF_DTDIGI)
				DDATABASE:=Stod(ZNFTEMP->ZNF_DTDIGI)
			Endif
			
			Aadd(_aCabSF1,{"F1_DTDIGIT"  ,DDATABASE			,Nil})    	 
			
			Aadd(_aCabSF1,{"F1_FORMUL"   ,"N" 		  								,Nil})
			Aadd(_aCabSF1,{"F1_ESPECIE"  ,Alltrim(cEspecie)							,Nil})
  			Aadd(_aCabSF1,{"F1_CHVNFE"   ,ZNFTEMP->ZNF_CHVNFE   		   			,Nil})
			Aadd(_aCabSF1,{"F1_VOLUME1"  ,ZNFTEMP->ZNF_VOLUME  		   			,Nil}) 	
                              
			dbSelectArea('SF1')  
			If FieldPos("F1_USUSMAR") > 0
				Aadd(_aCabSF1,{"F1_USUSMAR"  ,ZNFTEMP->ZNF_USERLG			   		,Nil})                 
			Endif
         			
			If FieldPos("F1_ZUSER") > 0 
		  		Aadd(_aCabSF1,{"F1_ZUSER"    ,Substr(ZNFTEMP->ZNF_USERLG,1,25)		,Nil})    
			Endif
		
			If FieldPos("F1_XMODNF") > 0 
				Aadd(_aCabSF1,{"F1_XMODNF"    ,Alltrim(ZNFTEMP->ZNF_MODNF)		 	,Nil}) 	//DESBH       
			Endif
			
			If FieldPos("F1_MODNF") > 0 
				Aadd(_aCabSF1,{"F1_MODNF"    ,Alltrim(ZNFTEMP->ZNF_MODNF)		 	,Nil}) 	//DESBH       
			Endif
			
			
			If Alltrim(cEspecie) = 'CTE'  
				
				Aadd(_aCabSF1,{"F1_TPCTE"    ,ZNFTEMP->ZNF_TIPO		   			,Nil}) 	//
												
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

			If Empty(ZNFTEMP->ZNF_CHVNFE)                                                      
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
			
			If ZNFTEMP->ZNF_DESPES > 0
				Aadd(_aCabSF1,{"F1_DESPESA"  ,ZNFTEMP->ZNF_DESPES			   		,Nil})
			Endif
						
	       If ZNFTEMP->ZNF_PBRUTO > 0
		      Aadd(_aCabSF1,{"F1_PBRUTO"   ,ZNFTEMP->ZNF_PBRUTO						,Nil})
		   Endif   
		   
		   If ZNFTEMP->ZNF_PLIQUI > 0
	   	      Aadd(_aCabSF1,{"F1_PLIQUI"   ,ZNFTEMP->ZNF_PLIQUI						,Nil})
	   	   Endif         
	   	
   	  	   Aadd(_aCabSF1,{"F1_RECBMTO"  ,Stod(ZNFTEMP->ZNF_RECBMT)	   			    ,Nil})
   	 	   
		   If cTpLanc <> 'P'
				Aadd(_aCabSF1,{"F1_INCISS"   ,ZNFTEMP->ZNF_INCISS				   		,Nil})  //Código do Municipio IBGE
   	       Endif
		   
		   Aadd(_aCabSF1,{"F1_ESTPRES"  ,ZNFTEMP->ZNF_ESTPRE				   		,Nil})  //Estado do Municipio 	   			              
   	  
		   dbSelectArea('ZNFTEMP')
		   
		    If Alltrim(cEspecie) = 'CTE'  
				If FieldPos("ZNF_MODAL") > 0  
					Aadd(_aCabSF1,{"F1_MODAL"    ,ZNFTEMP->ZNF_MODAL				,Nil})    
      	        Endif 
			Endif
		   
		   If FieldPos("ZNF_SEGUR") > 0 //!Empty(cUsaCampo)
			  cBancAba  := Alltrim(ZNFTEMP->ZNF_SEGUR)
			  Aadd(_aCabSF1,{"F1_SEGURO"  ,ZNFTEMP->ZNF_SEGUR				   		,Nil})  //Se a Nota Fiscal Tiver o campo seguro preenchido serÃ¡ enviado ao ERP. 	   			              
		   Endif
	  
				
			If cTpLanc <> 'P'
		
			   cRecIss := ZNFTEMP->ZNF_RECISS
			   If !empty(ZNFTEMP->ZNF_RECISS)
					Aadd(_aCabSF1,{"F1_RECISS"   ,ZNFTEMP->ZNF_RECISS						,Nil})  	   			              
			   Endif
			   
			   If !Empty(Alltrim(ZNFTEMP->ZNF_DIRF))
							   
					Aadd(_aCabSF1,{"E2_DIRF"    ,'1'										,Nil})
					Aadd(_aCabSF1,{"E2_CODRET"  ,Alltrim(ZNFTEMP->ZNF_DIRF)				    ,Nil})
					
					//Array contendo a informação se gera DIRF e os códigos de retenção por imposto
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
			nVBrtAbax	:=	ZNFTEMP->ZNF_VLBRUT  		//Valor Bruto Nota Fiscal
			cCondAbax   := ZNFTEMP->ZNF_COND    			//Condicao de pagamento			
			cMAVenc	   :=  Alltrim(ZNFTEMP->ZNF_MAVENC)  //String com alteraÃ§Ãµes do vencimento.                                                                    

			//Caso parametro nÃ£o exista, serÃ¡ considerado .T. e pegarÃ¡ a data de emissÃ£o da nota fiscal.
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
						Aadd(_aCabSF1,{"E2_NATUREZ"  ,ZNFTEMP->ZNF_NATUR  ,Nil})  // IncluÃ­do tratamento Natureza Financeira 292 04/09/2015
					EndIf
				Endif

			Endif	                                                                                                                  						
			If (ZNFTEMP->ZNF_ESPEC = 'NFSE' .or. ZNFTEMP->ZNF_ESPEC = 'NFPS') .and. cTpLanc <> 'P' // IncluÃ­do tratamento de Fornecedor de ISS e Loja ISS

				cMesIss := alltrim(str(Month(dDataBase)+ 1))
				cAnoIss := alltrim(str(Year(dDataBase)))       
				 
				If !Empty(cDiaIss)
					dDatISS := Ctod(cDiaIss+'/'+cMesIss+'/'+cAnoIss) 
				Else	                                             
					dDatISS := Ctod('10/'+cMesIss+'/'+cAnoIss) 
				Endif
				Aadd(_aCabSF1,{"E2_FORNISS"  ,ZNFTEMP->ZNF_FORISS  ,Nil})
				Aadd(_aCabSF1,{"E2_LOJISS"   ,ZNFTEMP->ZNF_LOJISS  ,Nil})
				Aadd(_aCabSF1,{"E2_VENISS"   ,dDatISS			   ,Nil})
			
			Endif
	
			dbSelectArea('ZNFTEMP')
			If FieldPos("ZNF_SEGUR") > 0 //!Empty(cUsaCampo)
				cBancAba  := Alltrim(ZNFTEMP->ZNF_SEGUR)
			Endif
			
			If FieldPos("ZNF_BANCO") > 0 //!Empty(cUsaCampo)
				cBancAba  := Alltrim(ZNFTEMP->ZNF_BANCO)
			Endif			
			
			If FieldPos("ZNF_AGENC") > 0  //!Empty(cUsaCampo)
				cAgenAba	:= Alltrim(ZNFTEMP->ZNF_AGENC)
			Endif			                                 
			
			If FieldPos("ZNF_CONTAB") > 0 //!Empty(cUsaCampo)
				cContAba := Alltrim(ZNFTEMP->ZNF_CONTAB)				                       
			Endif			
			//       
			If FieldPos("ZNF_BOLETO") > 0 //!Empty(Alltrim((cPrefix)->ZNF_BOLETO))
				aBolAbax := Strtokarr(Alltrim(ZNFTEMP->ZNF_BOLETO),'|')      
			Endif
			
			//Campos novos para notas fiscais de servi�o
			//29/04/2021 - Leonardo Viana
			If FieldPos("ZNF_EMINFE") > 0
				if !Empty(Alltrim(ZNFTEMP->ZNF_EMINFE))
					Aadd(_aCabSF1,{"F1_EMINFE"  ,Stod(ZNFTEMP->ZNF_EMINFE)   			,Nil})
				Endif
			Endif

			//Campos novos para notas fiscais de servi�o
			//29/04/2021 - Leonardo Viana
			If FieldPos("ZNF_NFELET") > 0
				if !Empty(Alltrim(ZNFTEMP->ZNF_NFELET))
					Aadd(_aCabSF1,{"F1_NFELETR"  ,Alltrim(ZNFTEMP->ZNF_NFELET)  			,Nil})
				Endif
			Endif

			//Campos novos para notas fiscais de servi�o
			//29/04/2021 - Leonardo Viana
			If FieldPos("ZNF_CODNFE") > 0
				if !Empty(Alltrim(ZNFTEMP->ZNF_CODNFE))
					Aadd(_aCabSF1,{"F1_CODNFE"  ,Alltrim(ZNFTEMP->ZNF_CODNFE)   			,Nil})
				Endif
			Endif

			//Campos novos para notas fiscais de servi�o
			//29/04/2021 - Leonardo Viana
			If FieldPos("ZNF_HORNFE") > 0
				if !Empty(Alltrim(ZNFTEMP->ZNF_HORNFE))
					Aadd(_aCabSF1,{"F1_HORNFE"  ,Alltrim(ZNFTEMP->ZNF_HORNFE)   			,Nil})
				Endif
			Endif			
			
			//campo para enviar o nome do arquivo PDF gravado na pasta do Protheuss
			//01/07/2021 - Leonardo Viana
			If FieldPos("ZNF_HASH") > 0
				Aadd(_aCabSF1,{"F1_ZNUMECB"  ,Alltrim(ZNFTEMP->ZNF_HASH)   			,Nil})
			Endif	
			
			aAdd(_aCabSF1, {"VLDAMNFE"       ,       "N"                            ,Nil})
			
			lImport:=.T.                                                                                                                
			
		EndIf		    
		_aLinha:={}
		 
		dbSelectArea('SB1')
		SB1->(dbSetOrder(01))
		SB1->(dbSeek(xFilial('SB1')+ZNFTEMP->ZNF_COD))	    	    
	   	    	    	    
	   /* Inicio informa��es Itens da Nota Fiscal */           
		Aadd(_aLinha,{"D1_FILIAL"	,cFilAnt     						 ,Nil})
		Aadd(_aLinha,{"D1_ITEM"     ,STRZERO(nTotItem++,4)  		 ,Nil}) //	
		Aadd(_aLinha,{"D1_COD"      ,Alltrim(SB1->B1_COD)		    ,Nil}) //Alltrim((cPrefix)->ZNF_COD tIREI PEDIDOS DA LINHA DE BAIXO 
		
		dbSelectArea("SD1")
		If FieldPos("D1_XOPER") > 0  
			If Empty(ZNFTEMP->ZNF_PEDIDO)
				Aadd(_aLinha,{"D1_XOPER" 	 ,ZNFTEMP->ZNF_XOPER  	,Nil}) 
			Endif	                                                        
		Endif	
		
		//Se n�oo for Beneficiamento
		If !(ZNFTEMP->ZNF_TIPO $ 'B/D')
			// Tratamento para verficiar se existe nota de origem
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
					//B6_FILIAL+B6_PRODUTO+B6_CLIFOR+B6_LOJA+B6_IDENT                                                                                                                 
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
		  		/////SD2->(dbSeek(xFilial('SD2')+ALLTRIM(ZNFTEMP->ZNF_NFORI)+SUBSTR(ZNFTEMP->ZNF_SERORI,1,3)+SA1->A1_COD+SA1->A1_LOJA+ZNFTEMP->ZNF_COD+ZNFTEMP->ZNF_ITEORI))
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
				//B6_FILIAL+B6_PRODUTO+B6_CLIFOR+B6_LOJA+B6_IDENT   
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
		cCCSC7       := SC7->C7_CC //Vari�vel para pegar Centro de Custo do Produto	
		
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

		If cTpLanc <> 'P'
			
			dbSelectArea('SF4')
			dbSetOrder(1)
			SF4->(dbSeek(xFilial('SF4')+ZNFTEMP->ZNF_TES))	    	    
			Aadd(_aLinha,{"D1_TES"      ,ZNFTEMP->ZNF_TES     		,Nil})
			
			cSitTrib := SF4->F4_SITTRIB
			
		Endif                                            

		dbSelectArea('ZNFTEMP')
		
		If FieldPos("ZNF_CODIS") > 0 
			If !Empty(ZNFTEMP->ZNF_CODIS)
				Aadd(_aLinha,{"D1_CODISS" 	 ,ALLTRIM(ZNFTEMP->ZNF_CODIS)	,Nil}) 
			Endif	                                                        
		Endif							   
		If FieldPos("ZNF_FCICOD") > 0 
			If !Empty(ZNFTEMP->ZNF_FCICOD)
				Aadd(_aLinha,{"D1_FCICOD" 	 ,ZNFTEMP->ZNF_FCICOD 	,Nil}) 
			Endif	                                                        
		Endif				
			   
		If FieldPos("ZNF_ORIG") > 0   
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
		                                        
		If !Empty(ZNFTEMP->ZNF_LOCAL)
			Aadd(_aLinha,{"D1_LOCAL"  ,ZNFTEMP->ZNF_LOCAL 	 								,Nil})
		Else
			If !Empty(cLocSB6)
			    If lLOCSB6 				
					Aadd(_aLinha,{"D1_LOCAL"  ,cLocSB6 						 					,Nil})		
				Endif	
			Endif	
		Endif
		
		Aadd(_aLinha,{"D1_FORNECE"  ,ZNFTEMP->ZNF_FORNEC		 						,Nil})
		Aadd(_aLinha,{"D1_LOJA"     ,Alltrim(ZNFTEMP->ZNF_LOJA)						,Nil})				
		Aadd(_aLinha,{"D1_DOC"      ,ZNFTEMP->ZNF_DOC      							,Nil})
		Aadd(_aLinha,{"D1_EMISSAO"  ,Stod(ZNFTEMP->ZNF_EMISSA)						,Nil})		
		
		
		Aadd(_aLinha,{"D1_SERIE"    ,ZNFTEMP->ZNF_SERIE     							,Nil})										
		Aadd(_aLinha,{"D1_TIPO"     ,ZNFTEMP->ZNF_TIPO      							,Nil}) 		

		//If ZNFTEMP->ZNF_VALDES > 0
			Aadd(_aLinha,{"D1_VALDESC"	,ZNFTEMP->ZNF_VALDES								,Nil}) 
		//Endif
	   	
		//Somente para clientes que desejam escriturar os impostos da mesma forma que est�o na nota fiscal.		
		//Caso contr�rio, campos abaixo dever�o ser comentados.		
		If ZNFTEMP->ZNF_PICM > 0
			
			If ZNFTEMP->ZNF_VALICM > 0
				Aadd(_aLinha,{"D1_VALICM" ,ZNFTEMP->ZNF_VALICM   ,Nil})
			Endif
						
			If ZNFTEMP->ZNF_PICM > 0
				Aadd(_aLinha,{"D1_PICM"  ,ZNFTEMP->ZNF_PICM     ,Nil})
			Endif
						
			If ZNFTEMP->ZNF_BSICM > 0
				Aadd(_aLinha,{"D1_BASEICM"  ,ZNFTEMP->ZNF_BSICM    ,Nil})
			Endif	 
			
			If ZNFTEMP->ZNF_ICMSCO > 0		
				Aadd(_aLinha,{"D1_ICMSCOM"  ,ZNFTEMP->ZNF_ICMSCO   					,Nil})	//ICMS COMPLEMENTAR
			Endif
			
			If ZNFTEMP->ZNF_ALISOL > 0
				Aadd(_aLinha,{"D1_ALIQSOL" 	,ZNFTEMP->ZNF_ALISOL						,Nil})
			Endif
			
			//ICMS retido BASE - D1_BRICMS
			//ICMS ALIQ - D1_ALIQCMP
			//VALOR D1_ICMSRET - Valor do ICMS
			If ZNFTEMP->ZNF_ICMRET > 0
				Aadd(_aLinha,{"D1_BRICMS" 	,ZNFTEMP->ZNF_BRICMS							,Nil})
				Aadd(_aLinha,{"D1_ICMSRET" 	,ZNFTEMP->ZNF_ICMRET						,Nil})
			elseif ZNFTEMP->ZNF_VALST > 0
				Aadd(_aLinha,{"D1_ICMSRET" 	,ZNFTEMP->ZNF_VALST						  ,Nil})
				Aadd(_aLinha,{"D1_BRICMS" 	,ZNFTEMP->ZNF_BRICMS							,Nil})
			Endif 
		
		Endif
						
		If ZNFTEMP->ZNF_BSIPI > 0	
		    nBTotIPI += ZNFTEMP->ZNF_BSIPI 
			nVTotIPI += ZNFTEMP->ZNF_VALIPI
			nPIPI    = ZNFTEMP->ZNF_PIPI

			aAdd(aAutoImp, {'IT_BASEIPI', ZNFTEMP->ZNF_BSIPI ,   nTotItem}) //Base
			aAdd(aAutoImp, {'IT_ALIQIPI',  ZNFTEMP->ZNF_PIPI,   nTotItem}) //Porcentagem Imposto
			aAdd(aAutoImp, {'IT_VALIPI' ,  ZNFTEMP->ZNF_VALIPI,   nTotItem}) //Valor imposto 
			
			Aadd(_aLinha,{"D1_BASEIPI"   ,ZNFTEMP->ZNF_BSIPI 	 						,Nil})	//BASE DE CALCULO 242
			Aadd(_aLinha,{"D1_IPI" 		 ,ZNFTEMP->ZNF_PIPI	 							,Nil})	//Valor do IPI - ALIQUOTA 
			Aadd(_aLinha,{"D1_VALIPI" 	 ,ZNFTEMP->ZNF_VALIPI  							,Nil})	//- VALOR IPI 244
						
        Endif    
      				 				
		If  !Empty(Alltrim(ZNFTEMP->ZNF_CONTA)) // > 0 //- Conta ContÃ¡bil
			Aadd(_aLinha,{"D1_CONTA" 	,ZNFTEMP->ZNF_CONTA		,Nil})
		Endif		
        
		If !Empty(SC7->C7_ITEMCTA)
			Aadd(_aLinha,{"D1_ITEMCTA" 	,SC7->C7_ITEMCTA		,Nil})
		Endif               
    
	   If ZNFTEMP->ZNF_ABATMA > 0 //- N - 14 - 2 - Abatimento ISS material  
     		Aadd(_aLinha,{"D1_ABATMAT"  ,ZNFTEMP->ZNF_ABATMA  ,Nil})
  		Endif
  		              
		If ZNFTEMP->ZNF_BASISS > 0	.AND. ZNFTEMP->ZNF_ALIISS > 0 
		
			aAdd(aAutoImp, {'NF_RECISS' ,ZNFTEMP->ZNF_RECISS,   nTotItem})
		
			aAdd(aAutoImp, {'IT_BASEISS',  ZNFTEMP->ZNF_BASISS,   nTotItem}) //Base
			aAdd(aAutoImp, {'IT_ALIQISS',  ZNFTEMP->ZNF_ALIISS,   nTotItem}) //Porcentagem Imposto
			aAdd(aAutoImp, {'IT_VALISS' ,  ZNFTEMP->ZNF_VALISS,   nTotItem}) //Valor imposto 
					
			Aadd(_aLinha,{"D1_BASEISS"	,  ZNFTEMP->ZNF_BASISS,Nil})
			Aadd(_aLinha,{"D1_ALIQISS"	,  ZNFTEMP->ZNF_ALIISS,Nil})
			Aadd(_aLinha,{"D1_VALISS" 	,  ZNFTEMP->ZNF_VALISS,Nil})
			
		Endif


		  If FieldPos("ZNF_ABATIS") > 0
				If ZNFTEMP->ZNF_ABATIS > 0
					
					aAdd(aAutoImp, {'IT_ABVLISS',  ZNFTEMP->ZNF_ABATIS,   nTotItem})				
					
					Aadd(_aLinha,{"D1_ABATISS" 	, ZNFTEMP->ZNF_ABATIS , Nil})
					
				Endif
		  Endif
      	
		If FieldPos("ZNF_ABATIN") > 0 
			If ZNFTEMP->ZNF_ABATIN > 0
			
				aAdd(aAutoImp, {'IT_ABVLINSS',  ZNFTEMP->ZNF_ABATIN,   nTotItem})
			
				Aadd(_aLinha,{"D1_ABATINS" 	, ZNFTEMP->ZNF_ABATIN , Nil})
				
			Endif
         Endif	
		
		If FieldPos("ZNF_ABATAL") > 0  
			If ZNFTEMP->ZNF_ABATAL > 0
						
				Aadd(_aLinha,{"D1_ABATALM" 	, ZNFTEMP->ZNF_ABATAL , Nil})
				
			Endif
		Endif	 
	    		
		dbSelectArea("SD1")
		//Campo especifico para a Orguel.
		If FieldPos("D1_NATUREZ") > 0
		
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
		If FieldPos("ZNF_BASNDE") > 0 
			Aadd(_aLinha,{"D1_BASNDES" 	, ZNFTEMP->ZNF_BASNDE ,Nil})
		Endif

		If FieldPos("ZNF_ALQNDE") > 0 
			Aadd(_aLinha,{"D1_ALQNDES" 	, ZNFTEMP->ZNF_ALQNDE ,Nil})
		Endif
		
		If FieldPos("ZNF_ICMNDE") > 0 
			Aadd(_aLinha,{"D1_ICMNDES" 	, ZNFTEMP->ZNF_ICMNDE ,Nil})
		Endif
		
		If !Empty(Alltrim(ZNFTEMP->ZNF_CC))			
	  		dbSelectArea('CTT')
			CTT->(dbSetOrder(01))
			CTT->(dbSeek(xFilial('CTT')+Alltrim(ZNFTEMP->ZNF_CC)))
			If !Eof()
				Aadd(_aLinha,{"D1_CC" 		,Alltrim(ZNFTEMP->ZNF_CC),Nil})
			Else     
				FwLogMsg("INFO-ABAX", /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01",'MTUFOPRO -NÃƒO ACHOU O CENTRO DE CUSTOS DA ZNF', 0, (nStart - Seconds()), {})
			Endif	
		Else  
			If !Empty(Alltrim(SC7->C7_CC))
				Aadd(_aLinha,{"D1_CC" 		,SC7->C7_CC,Nil})
			Else
				Aadd(_aLinha,{"D1_CC" 		,SB1->B1_CC,Nil})   		
			Endif	
		Endif

		If FieldPos("ZNF_MOTDEV") > 0    
		
			If !Empty(ZNFTEMP->ZNF_MOTDEV)// Campo especifico Urbano.
				Aadd(_aLinha,{"D1_MOTDEV" 	 ,Alltrim(ZNFTEMP->ZNF_MOTDEV) 	,Nil})
			Endif     
			
			If !Empty(ZNFTEMP->ZNF_DESDEV)// Campo especifico Urbano.
				Aadd(_aLinha,{"D1_DESDEV" 	 ,Alltrim(ZNFTEMP->ZNF_DESDEV)   	,Nil})
			Endif      
			
			If !Empty(ZNFTEMP->ZNF_LOTEDE)// Campo especifico Urbano.
				Aadd(_aLinha,{"D1_LOTEDEV" 	 ,Alltrim(ZNFTEMP->ZNF_LOTEDE) 	,Nil})
			Endif     
			
			If !Empty(Alltrim(ZNFTEMP->ZNF_UNPROD))// Campo especifico Urbano.
				Aadd(_aLinha,{"D1_UNPROD" 	 ,Alltrim(ZNFTEMP->ZNF_UNPROD) 	,Nil})
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
		ZNFTEMP->(dbSkip())
		
		If __cSeekNF != ZNFTEMP->ZNF_DOC+ZNFTEMP->ZNF_SERIE+ZNFTEMP->ZNF_FORNEC+ZNFTEMP->ZNF_LOJA		
			
			if nBTotIPI > 0
               
			   Aadd(_aCabSF1,{"F1_BASEIPI"   ,nBTotIPI					,Nil}) 
			   Aadd(_aCabSF1,{"F1_VALIPI"    ,nVTotIPI					,Nil}) 

			Endif 

			If nTotAbax > 0
			   If nTotAbax <> nToItem   
			       lErroAba:= .T.  
				   cError += ' Problema na Exportação da Nota Fiscal para a ZNF, favor exportar a Nota Fiscal Novamente. Quantidade de linhas não bate com a quantidade de itens exportados. Campo ZNF_ITEM.'
				Endif				
			Endif	  
			nToItem := 0
			nBTotIPI := 0
			nVTotIPI := 0
			nPIPI    := 0

			if u_NotaJaErp(cFilAnt, cDocSMA, cSerSMA, cForSMA, cLojSMA)	
				lErroAba:= .T.
				cError += ' Erro: Nota est� na ZNF mas foi registrada manualmente no Protheus. Este procedimento poder� comprometer o bom funcionamento do integrador.'
			Endif

		  	lMsErroAuto:=.F.						
			
			If !lErroAba
				Begin transaction 
				
					If cTpLanc = 'P'                                            
						//InclusÃ£o de PrÃ©-Nota
						MSExecAuto({|x,y,z|Mata140(x,y,z)},_aCabSF1,_aItensSD1,3)				
					ElseIf cTpLanc = 'W'	
					  	//ClassificaÃ§Ã£o de PrÃ© Nota
						MSExecAuto({|x,y,z| MATA103(x,y,z)},_aCabSF1,_aItensSD1,4)         			
					ElseIf  cTpLanc = 'E' 
					   //ExclusÃ£o de Nota Fiscal                                                        
						MSExecAuto({|x,y,z| MATA103(x,y,z)},_aCabSF1,_aItensSD1,4)         			
					Else                        
					    //InclusÃ£o de Nota Fiscal
						//MSExecAuto({|x,y,z,a,b  | MATA103(x,y,z,,,,,a,,,b)} ,_aCabSF1   ,_aItensSD1,3         ,aAutoImp ,aCodRet) 
						  MSExecAuto({|x,y,z,k,a,b| MATA103(x,y,z,,,,k,a,,,b)},_aCabSF1   ,_aItensSD1,3         ,aAutoImp,,aCodRet)
						//MSExecAuto({|x,y,z,k,a,b| MATA103(x,y,z,,,,k,a,,,b)},aCab       ,aItens    ,nOpc      ,aParamAux,aItensRat,aCodRet)
						//MSExecAuto({|x,y,z,a,b| MATA103(x,y,z,,,,,a,,,b)},aCab    ,aItens    ,nOpc     ,aItensRat,aCodRet)
					Endif
					
	        	End Transaction 
			Endif
			lErroAba:= .F.           
			cDataX  := DtoC(Date()) 
			cTimeX  := Time() 
		
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
				/* FunÃ§Ã£o utilizada para atualizar campo status da Nota, impossibilitando que a mesma seja importada novamente */				
				u_FAtuaStat(cDocSMA,cSerSMA,cForSMA, cLojSMA,.T.,'Processado com Sucesso.'+'- Data ' + cDataX+'- Hora '+cTimeX+ '-' +Alltrim(__cLogMsg) )		
			Endif  
	
		    /* Atualizar variaveis que sÃ£o utilizada na definiÃ§Ã£o para gerar a Nota na base */
		   _aCabSF1	:= {}
			_aItensSD1	:={}
			lImport		:=.F.
			nVBrtAbax   := 0
			
		Endif
		nZ++				
	EndDo
	/* Restaura Area de todas as tabelas envolvidas */	 
	FwLogMsg("INFO-ABAX", /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01",'TOTAL DE NOTAS PROCESSADAS ' + str(nZ), 0, (nStart - Seconds()), {})		
	
	PutMV("MV_ALTPRCC",cAltPrcc) //Volta aio original o parâmetro que obriga o valor da nota fiscal ser igual ao valor do pedido de compra. Não tem relação com margem de tolerância.

	dbSelectArea("ZNFTEMP")
	dbCloseArea()
	
	RestArea(aAreaSB1)
	RestArea(aAreaSF1)
	RestArea(aAreaSD1)
	RestArea(aAreaSF4)
	
Return(lMsErroAuto) //Nil


//------------------------------------------------------------------- 
/*/{Protheus.doc} FAtuaStat

   FunÃ§Ã£o utilizada para atualizar status das Notas apos importaÃ§Ã£o
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
	Local cDbase   := Alltrim(TCGetDB()) //Verificar qual Ã© o Banco de Dados do cliente.
	Local cRetZNF :=  GetNextAlias()
	Local aAreaZ   := GetArea()  
   
   If lOk
   	cStatus := '2'
   Else	              
    	cStatus := '3'
   Endif   	
   //Leonardo Vasco Viana de Oliveira
   //03/08/2017
   //AlteraÃ§Ã£o para alterar modo de gravaÃ§Ã£o na ZNF, de Update direto no banco para Replace seguindo o padrÃ£o do Protheus
   FwLogMsg("DENTRO FAtuaStat 2 - ABAX" + cCodNota  , /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01",'FIM PROCESSO IMPORTAÃ‡ÃƒO SMARTNFE - FONTE MTUFOPRO - Empresa '  , 0, (nStart - Seconds()), {})
	FwLogMsg("DENTRO FAtuaStat 3 - ABAX" + cCodSer, /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01",'FIM PROCESSO IMPORTAÃ‡ÃƒO SMARTNFE - FONTE MTUFOPRO - Empresa '  , 0, (nStart - Seconds()), {})
	FwLogMsg("DENTRO FAtuaStat 4 - ABAX" + cCodFor, /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01",'FIM PROCESSO IMPORTAÃ‡ÃƒO SMARTNFE - FONTE MTUFOPRO - Empresa '  , 0, (nStart - Seconds()), {})
	FwLogMsg("DENTRO FAtuaStat 5 - ABAX" + cLojFor  , /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01",'FIM PROCESSO IMPORTAÃ‡ÃƒO SMARTNFE - FONTE MTUFOPRO - Empresa '  , 0, (nStart - Seconds()), {})	

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
*FunÃ§Ã£o que gera CTE atravÃ©s da rotina MATA116
**********************************************************************************

Local aEmpSmar 	:= {}
Local aInfo   	:= {}
Local aTables 	:= {"SA1","SA2","SF1","SD1","SF2","SD2","CTT","ZNF", "SF4","SB6","SB1","CT1",'SX6'}//seta as tabelas que serÃ£o abertas no rpcsetenv
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

		FwLogMsg("MTCTEPRO 1", /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01",'FunÃ§Ã£o MTCTEPRO sendo Utilizada! ', 0, (nStart - Seconds()), {})		
       	Return      
   	EndIf
 	Next nI
   
	lthread := .T. 

  	RpcClearEnv()                  
  	RpcSetEnv( '01',"01", " ", " ", "COM", "MATA116", aTables, , , ,  )/****** COMANDOS *************/

	cUsuSm := Space(1)
	cSenSm := Space(1)
	
	FwLogMsg("MTCTEPRO 2", /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01",'INICIO IMPORTAÃ‡ÃƒO Ã�BAX - FONTE MTCTEPRO', 0, (nStart - Seconds()), {})		

	dbSelectarea('SM0')
	SM0->(dbGotop())
	      	
	Do While SM0->(!Eof())
		    		
		Aadd(aEmpSmar,{SM0->M0_CODIGO,SM0->M0_CODFIL})		  					
		SM0->(dbSkip())			
	
	Enddo		

	RpcClearEnv() 
	   	
	cEmpABax := aEmpSmar[1][1]     

	RpcSetEnv( aEmpSmar[1][1],aEmpSmar[1][2]," " ," " , "COM", "MATA116", aTables, , , ,  )/****** COMANDOS *************/         

	n:=1
	For n:=1 to Len(aEmpSmar)
 		If cEmpABax = aEmpSmar[n][1]
			cFilAnt := aEmpSmar[n][2]
			cEmpABax := aEmpSmar[n][1]
		Else
		   RpcClearEnv() 
		   cEmpABax := aEmpSmar[n][1]
		   RpcSetEnv( aEmpSmar[n][1],aEmpSmar[n][2]," " ," ", "COM", "MATA116", aTables, , , ,  )/****** COMANDOS *************/			

		Endif
		
		If CHKFILE("ZNF", .F.)
			FwLogMsg("MTCTEPRO 4 - EMPRESA com ZNF", /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01",'EMPRESA SEM ZNF' + aEmpSmar[n][1] , 0, (nStart - Seconds()), {})		
			U_MImpCTE(aEmpSmar[n][1],aEmpSmar[n][2],cUsuSm,cSenSm)			   
		Else     
			FwLogMsg("MTCTEPRO 3 - EMPRESA SEM ZNF", /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01",'EMPRESA SEM ZNF' + aEmpSmar[n][1] , 0, (nStart - Seconds()), {})		
		Endif
	Next	
               
	FwLogMsg("MTCTEPRO 5", /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01",'FIM IMPORTAÃ‡ÃƒO SMARTNFE - FONTE MTCTEPRO', 0, (nStart - Seconds()), {})		
	
	RpcClearEnv()
Else	
	RpcSetEnv( cEmpAbx,cFilAbx," " ," ", "COM", "MATA116", aTables, , , ,  ) 
	cUsuSm := Space(1)//Alltrim(SuperGetMV("MA_USUSMA"))
	cSenSm := Space(1)//Alltrim(SuperGetMV("MA_PASSMA"))  
	U_MImpCTE(cEmpAbx,cFilAbx,cUsuSm,cSenSm)			   
Endif

Return 

User Function MImpCTE(cEmpMa,cFilMa,cUsusm,cSenSm)
******************************************************************************
* FunÃ§Ã£o para importar  notas para o Protheus. Foi desmembrado a funÃ§Ã£o devido
* a empresas que possuem muitas empresas e filiais.
******************************************************************************
 
FwLogMsg("INFO-ABAX", /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01",'PROCESSO IMPORTAÃ‡ÃƒO SMARTNFE - FONTE MTCTEPRO - Empresa ' +cEmpMa + ' Filial '+cFilMa, 0, (nStart - Seconds()), {})		

Private cPedAbax	 
private cFilImp := alltrim(cFilMa)
u_FSBusCTE()
		
dbSelectArea("ZNFCTE")
ZNFCTE->(dbGoTop()) 

If !Empty(ZNFCTE->ZNF_DOC) //+(cAlias)->ZNF_SERIE+(cAlias)->ZNF_FORNEC+  (cAlias)->ZNF_LOJA)
	u_FSGeraCTE()

   FwLogMsg("INFO-ABAX", /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01",'FIM PROCESSO IMPORTAÃ‡ÃƒO SMARTNFE - FONTE MTUFOPRO - Empresa ' +cEmpMa + ' Filial '+cFilMa , 0, (nStart - Seconds()), {})		
Else
   FwLogMsg("INFO-ABAX", /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01",'FIM PROCESSO IMPORTAÃ‡ÃƒO SMARTNFE - FONTE MTUFOPRO - Empresa ' +cEmpMa + ' Filial '+cFilMa , 0, (nStart - Seconds()), {})		
Endif		 				  						 					
                 
dbCloseArea()

Return    

                
//--------------------------------------------------------------------------------------- 
/*/{Protheus.doc} FSGeraCTE

	FunÃ§Ã£o responsavel pela geraÃ§Ã£o do CTE pela rotina MATA116.
	@author 	Leonardo Vasco Viana de Oliveira
	@since	22.03.2017
	@Parm1	cPrefix - Alias com as informaÃ§oes da CTE
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
	
	FwLogMsg("FSGeraCTE 1", /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01",'FIM IMPORTAÃ‡ÃƒO SMARTNFE - FONTE MTCTEPRO', 0, (nStart - Seconds()), {})		
	
	dbSelectArea("ZNFCTE")
	ZNFCTE->(dbGoTop())		
	
	FwLogMsg("FSGeraCTE 2 "+ZNFCTE->ZNF_DOCCTE, /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01",'FIM IMPORTAÃ‡ÃƒO SMARTNFE - FONTE MTCTEPRO', 0, (nStart - Seconds()), {})		
	FwLogMsg("FSGeraCTE 3 "+ZNFCTE->ZNF_SERCTE, /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01",'FIM IMPORTAÃ‡ÃƒO SMARTNFE - FONTE MTCTEPRO', 0, (nStart - Seconds()), {})		
	FwLogMsg("FSGeraCTE 4 "+ZNFCTE->ZNF_FORCTE, /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01",'FIM IMPORTAÃ‡ÃƒO SMARTNFE - FONTE MTCTEPRO', 0, (nStart - Seconds()), {})		
	FwLogMsg("FSGeraCTE 5 "+ZNFCTE->ZNF_LOJCTE, /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01",'FIM IMPORTAÃ‡ÃƒO SMARTNFE - FONTE MTCTEPRO', 0, (nStart - Seconds()), {})		
	
	
	Do While ZNFCTE->(!Eof())
		
		__cSeekCT := ZNFCTE->ZNF_DOCCTE+ZNFCTE->ZNF_SERCTE+ZNFCTE->ZNF_FORCTE+ZNFCTE->ZNF_LOJCTE 
		
		cDocSMA := ZNFCTE->ZNF_DOCCTE
		cSerSMA := ZNFCTE->ZNF_SERCTE
		cForSMA := ZNFCTE->ZNF_FORCTE			
		cLojSMA := ZNFCTE->ZNF_LOJCTE			  
	    
		cCHVCTE  := ZNFCTE->ZNF_CHVNFE
		cTipCTE  := ZNFCTE->ZNF_TPCTE
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
		     
	      /*dbSelectArea("SA2")
	        dbSetOrder(1)
	        SA2->(dbSeek(xFilial('SA2')+ZNFCTE->ZNF_FORCTE+ZNFCTE->ZNF_LOJCTE))			
	      
	        dbSelectArea("SA2")
	        dbSetOrder(1)
	        SA2->(dbSeek(xFilial('SA2')+ZNFCTE->ZNF_FORNEC+ZNFCTE->ZNF_LOJA ))*/			
			
	
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
			aadd(aCabec,{"F1_FORMUL"   ,1})        	            // 10 FormulÃ¡ri/o
			aadd(aCabec,{"F1_DOC"		,ZNFCTE->ZNF_DOCCTE})// 11 Numero da NF de Conhecimento de Frete        
			aadd(aCabec,{"F1_SERIE"		,ZNFCTE->ZNF_SERCTE})// 12 Serie da NF do Conhecimento deFrete        
			aadd(aCabec,{"F1_FORNECE"	,ZNFCTE->ZNF_FORCTE})             // 13 Fornecedor do Frete
			aadd(aCabec,{"F1_LOJA"		,ZNFCTE->ZNF_LOJCTE})                // 14 Loja do Frete
			aadd(aCabec,{""				,ZNFCTE->ZNF_TES})   // 15 TES         '' 
			aadd(aCabec,{"F1_BASERET"	,0})                    // 16 Base Ret
			aadd(aCabec,{"F1_ICMRET"	,0})                    // 17 ICMS Retido
			//AlteraÃ§Ã£o para buscar condiÃ§Ã£o de pagamento do cadastro de fornecedor, caso nÃ£o seja informado no Ã�bax.
			If !Empty(ZNFCTE->ZNF_COND)
				aadd(aCabec,{"F1_COND"		,ZNFCTE->ZNF_COND})  // 18 CondiÃ§Ã£o dePagametno     
			elseif cCondFor <> ''
				aadd(aCabec,{"F1_COND"		,cCondFor})  // 18 CondiÃ§Ã£o dePagametno     
			Endif
			
			aadd(aCabec,{"F1_EMISSAO"	,Stod(ZNFCTE->ZNF_EMISSA)}) // 19 Emissao       
			aadd(aCabec,{"F1_ESPECIE"	,ZNFCTE->ZNF_ESPEC})//19 Especie        
			aadd(aCabec,{"E2_NATUREZ"	,ZNFCTE->ZNF_NATUR}) //20 Natureza       
			aadd(aCabec,{"F1_DESCONTO"	,0							})                    //21 Desconto       
			Aadd(aCabec,{"F1_DESPESA"	,ZNFCTE->ZNF_DESPES				})  // 22 Despesas

			AAdd(aCabec, {"F1_UFORITR",    ZNFCTE->ZNF_UFORIT}) // 24 Estado Origem do Transporte			
			AAdd(aCabec, {"F1_MUORITR",    ZNFCTE->ZNF_MUORIT}) // 25 MunicÃ­pio Origem do Transporte			
			AAdd(aCabec, {"F1_UFDESTR",    ZNFCTE->ZNF_UFDEST}) // 26 Estado Destino do Transporte		
			AAdd(aCabec, {"F1_MUDESTR",    ZNFCTE->ZNF_MUDEST}) // 27 MunicÃ­pio Destino do Transporte
			
			dbSelectArea("ZNFCTE")

			If FieldPos("ZNF_MODAL") > 0//!Empty(cUsaCampo)
				Aadd(aCabec,{"F1_MODAL",	Alltrim(ZNFCTE->ZNF_MODAL)})  //Modal do Transporte.  
				cModal := Alltrim(ZNFCTE->ZNF_MODAL)
    		Endif    		
			
			If FieldPos("ZNF_TPFRET") > 0//!Empty(cUsaCampo) 
				Aadd(aCabec,{"F1_TPFRETE"    ,Alltrim(ZNFCTE->ZNF_TPFRET)		   			,Nil})     //Enviar tipo de Frete para o ERP.     				
				cTipFret   := ZNFCTE->ZNF_TPFRET
			Endif 
			
			If FieldPos("ZNF_HASH") > 0
				Aadd(aCabec,{"F1_ZNUMECB"  ,Alltrim(ZNFTEMP->ZNF_HASH)   			       ,Nil})
				cHash := Alltrim(ZNFTEMP->ZNF_HASH)
			Endif	
					      
	  		lImport  := .F.
		
		Endif
		   
		dbSelectArea("ZNFCTE")		   
		ZNFCTE->(dbSkip())

		If (__cSeekCT != ZNFCTE->ZNF_DOCCTE+ZNFCTE->ZNF_SERCTE+ZNFCTE->ZNF_FORCTE+ZNFCTE->ZNF_LOJCTE )
	      	//Tratamento para nÃ£o aparecer erro de nota duplicada Leonardo Vasco 20170505
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
				   		__cLogMsg := 'ERRO EXECAUTO ' + aLog[0]
					Endif
				Endif
				
				u_FAtuaCTE(cDocSMA,cSerSMA,cForSMA, cLojSMA,.F., __cLogMsg+'- Data ' + cDataX+'- Hora '+cTimeX)
			Else                     			
				u_FAtuaCTE(cDocSMA,cSerSMA,cForSMA, cLojSMA,.T.,'Processado com Sucesso.'+'- Data ' + cDataX+'- Hora '+cTimeX+ '-' +Alltrim(__cLogMsg) )		
			Endif  
	  
		    // Atualizar variaveis que sÃ£o utilizada na definiÃ§Ã£o para gerar a Nota na base 
			aCabec	:= {}
			aIteAbax	:= {}
			lImport	:= .F.	   	
	 	      
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
*FunÃ§Ã£o que busca todas as Notas Fiscais que estÃ£o relacionadas para cada CTe
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
	cQryExc += CRLF +" ZNF_STATUS <> '2' and "                                             
	cQryExc += CRLF +" ZNF_TPLANC = '2' and " // P-PRÃ‰-NOTA | VAZIO-MATA103 | 2-MATA116
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
		    FwLogMsg("INFO-ABAX", /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01","Cadastrar produto: " +(cBusCTE)->ZNF_COD , 0, (nStart - Seconds()), {})		
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
	
	aEval(aAreaAll,{|x| RestArea(x)}) // Restaurar tabelas.
               
Return(aItens116)


User Function FSBusCTE()
********************************************************************************
*
********************************************************************************

	Local cQryExc	:= '' 

	if Select("ZNFCTE") > 0
		dbCloseArea()
	Endif

	if Type(cPrefix) <> "U"
		if Select(cPrefix) > 0
			dbCloseArea()
		Endif
	Endif

	cQryExc += CRLF +" SELECT * "   	
	cQryExc += CRLF +" FROM " + RetSQLName('ZNF') + " "
	cQryExc += CRLF +" WHERE ZNF_FILIAL = '" + cFilImp +" ' and "
	cQryExc += CRLF +" ZNF_STATUS <> '2' "
	cQryExc += CRLF +" AND ZNF_TPLANC = '2' " // P-PRÃ‰-NOTA | VAZIO-MATA103 | 2-MATA116
	cQryExc += CRLF +" AND D_E_L_E_T_ <> '*' "
	cQryExc += CRLF +" ORDER BY ZNF_FILIAL, ZNF_DOC, ZNF_SERIE, ZNF_FORNEC "      
	TCQUERY (cQryExc) ALIAS cPrefix NEW
	ZNFCTE := MPSysOpenQuery(cQryExc,"ZNFCTE")
	
Return()

User Function FAtuaCTE(cCodNota, cCodSer, cCodFor, cLojFor,lOkAbax,cMsg)
********************************************************************************
*
********************************************************************************

	Local cQryExc	:= ''  
	Local cDbase   := Alltrim(TCGetDB()) //Verificar qual Ã© o Banco de Dados do cliente.
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
		
		    FwLogMsg("ABAX FAtuaCTE - linha 1788", /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01","TCSQLError() " + cQryExc + ' ' + TCSQLError() , 0, (nStart - Seconds()), {})		

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
		    FwLogMsg("ABAX FAtuaCTE - linha 1821", /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01","TCSQLError() " + TCSQLError() , 0, (nStart - Seconds()), {})		
		EndIf
	      
		If (TCSQLExec('commit') < 0)           
		    FwLogMsg("ABAX FAtuaCTE - linha 1825", /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01","TCSQLError() " + TCSQLError() , 0, (nStart - Seconds()), {})		
		endif
		
		If cStatus = '2' 
			cQryExc :="UPDATE "+RetSqlName("SF1")+""+CHR(13)+CHR(10)             			
		 	dbSelectArea("SF1")
	     	 	
		 	If FieldPos("D1_XOPER") > 0  
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
				    FwLogMsg(" ABAX FAtuaCTE - linha 1856", /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01"," Erro Update F1_USUSMAR MATA116 ZUSER- TCSQLError() " + TCSQLError() , 0, (nStart - Seconds()), {})		
				Endif				
			EndIf
				      
			If (TCSQLExec('commit') < 0)           
			    FwLogMsg(" ABAX FAtuaCTE - linha 1861", /*cTransactionId*/, "INTEGRADOR_ABAX", FunName(), "", "01","  Erro Update F1_USER MATA116 - TCSQLError() " + TCSQLError() , 0, (nStart - Seconds()), {})		
			Endif
		Endif
		/* Tratamento para gravar o campo F1_ZUSER ou F1_USUSMAR quando a origem for CTe Vinculados - Mata116, com isso a atualizaÃ§Ã£o serÃ¡ feita por UPDATE.
		Data: 11/05/2017
		Desenvolvedor: Leonardo Vasco e Leonardo Perrella.
		*/		
	Endif		              

	RestArea(aAreaZ)
Return(Nil)	

User Function  NotaJaErp(cFilImp, cDocNFe, cSerNFe, cForNFe, cLojNFe)
/********************************************************************************************
*Fun��o para verificar se nota j� est� no ERP, pois o Protheus est� travando quando a nota 
*est� na ZNF e a nota j� est� registrada no Protheus
**********************************************************************************************/
	
	Local aAreaAll := {SB1->(GetArea()),ZNF->(GetArea()),SF1->(GetArea()),GetArea()} //Get Areas 
	Local cQryExc := ''
	Local lReturn := .F.
	cBusNFE := GetNextAlias()
	
	cQryExc += CRLF +" SELECT F1_FILIAL, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA "   	
	cQryExc += CRLF +" FROM " + RetSQLName('SF1') + " "
	cQryExc += CRLF +" WHERE F1_FILIAL = '" + cFilImp +" ' and "    
	cQryExc += CRLF +" F1_DOC = '"+cDocCTe+" ' and "    
	cQryExc += CRLF +" F1_SERIE = '"+cSerCTe+" ' and "    
	cQryExc += CRLF +" F1_FORNECE = '"+cForCTe+" ' and "    
	cQryExc += CRLF +" F1_LOJA = '"+cLojCTe+" ' and "    
	cQryExc += CRLF +" D_E_L_E_T_ <> '*' "
	cQryExc += CRLF +" ORDER BY F1_FILIAL, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA "      
	
	cBusNFE := MPSysOpenQuery(cQryExc, cBusNFE)

	dbSelectArea(cBusNFE)

	If !EOF() 
	    lReturn  := .T.                  	 
	EndIf
   
	dbSelectArea(cBusNFE)
	dbCloseArea()
	
	aEval(aAreaAll,{|x| RestArea(x)}) // Restaurar tabelas.
               
Return(lReturn)
