#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWBROWSE.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'RWMAKE.CH'

/*/{Protheus.doc} RT99WF02
Função responsavel por realizar o envio do email ao solicitante.
@author 	Ricardo Tavares Ferreira
@since 		31/08/2018
@version 	12.1.17
@Return 	Nulo
@obs 		Ricardo Tavares - Construcao Inicial
/*/
//=======================================================================================
	User Function RT99WF02(xFil,cNumSC)
//=======================================================================================

	Local cKeySCR := xFil + "SC" + cNumSC
	Local aSavSCR := SCR->(GetArea())
	Local cFunc   := "RT99WF02"

	Default xFil  := ""
	Default cNumSC:= ""

	U_CONSOLE("VerIficando as alcadas de aprovacao sob a chave: "+cKeySCR,cFunc)

	SCR->(DbSetOrder(1))
	SCR->(DbSeek(cKeySCR))

	// varre todos os registros de aprovação
	While SCR->( .not. eof() .and. Alltrim(CR_FILIAL + CR_TIPO + CR_NUM) == cKeySCR )
		If SCR->CR_STATUS == "02"
			CRIA_PROC(xFil,cNumSC)
		EndIf
		SCR->(DbSkip())
	EndDo

	U_CONSOLE("Finalizando a verIficacao das alcadas de aprovacao sob a chave: "+cKeySCR,cFunc)

	RestArea(aSavSCR)
Return 

/*/{Protheus.doc} CRIA_PROC
Cria o processo de aprovação para uma determinada solicitação.
@author 	Ricardo Tavares Ferreira
@since 		31/08/2018
@version 	12.1.17
@Return 	Nulo
@obs 		Ricardo Tavares - Construcao Inicial
/*/
//=======================================================================================
	Static Function CRIA_PROC(xFil,cNumSC)
//=======================================================================================

	Local cWfKDir := GetWfDir()
	Local cAprDir := GetApDir()
	Local cHtmApr := cWfKDir+"sc-aprovacao-processo.htm"
	Local cHtmLnk := ""
	Local aAreaC1 := SC1->(GetArea())
	Local aAreaCR := SCR->(GetArea())
	Local cKeySC1 := xFil + cNumSC
	Local cKeySCR := xFil + "SC" + cNumSC
	Local oProces := nil
	Local oHtml   := nil
	Local cMailID := ""
	Local cFunc   := "CRIA_PROC"

	Default xFil  := ""
	Default cNumSC:= ""

	U_CONSOLE("Criando o processo de aprovacao para o aprovador: "+SCR->CR_APROV,cFunc)

	// posiciona no primeiro registro da SC
	SC1->(DbSetOrder(1))
	If SC1->(DbSeek(cKeySC1))

		U_CONSOLE("Iniciando a etapa 1 do processo de aprovacao...",cFunc)

		//---------------------------------------------------------------------
		// Etapa 1: Criação do html no diretório para acesso através de link
		//---------------------------------------------------------------------
		oProces := TWFProcess():New( "SOLICIT", "Solicitacao de Compras" )
		
		oProces:newTask("000001", cHtmApr)
		oProces:newVersion(.T.)
		oProces:cTo      := nil
		oProces:cSubject := "Aprovacao de Solicitacao de Compra: " + cNumSC + "/" + U_RetDesc("FILIAL",xFil,cEmpAnt)
		oProces:bReturn  := "U_SIWKFC01()"
		oProces:userSiga := SC1->C1_USER
		
		U_CONSOLE("Montando o formulario HTML de aprovacao...",cFunc)
		oHtml := oProces:oHTML
		
		oHtml:ValByName( "FILIAL"     , SC1->C1_FILIAL )
		oHtml:ValByName( "NUMSC"      , SC1->C1_NUM )
		oHtml:ValByName( "CAPROV"     , SCR->CR_USER )
		oHtml:ValByName( "APROVADOR"  , UsrFullName(SCR->CR_USER)) //UsrRetname(SCR->CR_USER)  ) - Alterado FSW
		oHtml:ValByName( "SOLICIT"    , SC1->C1_SOLICIT )
		// campos incluídos por RR - CNI
		//oHtml:ValByName( "TP_SOLICIT" , posicione("COL",1,FWXFilial("COL")+SC1->C1_XTIPOSC,"COL_DESC") )
		oHtml:ValByName( "EMISSAO"    , DToC(SC1->C1_EMISSAO) )
		oHtml:ValByName( "COD_UO"     , Alltrim(SC1->C1_CC) )
		oHtml:ValByName( "DES_UO"     , Posicione("CTT",1,FWXFilial("CTT")+SC1->C1_CC,"CTT_DESC01"))
		oHtml:ValByName( "COD_CR"     , Alltrim(SC1->C1_ITEMCTA) )
		oHtml:ValByName( "DES_CR"     , posicione("CTD", 1, FWXFilial("CTD") + SC1->C1_ITEMCTA, "CTD_DESC01") )
		//oHtml:ValByName( "JUSTIf"     , SC1->C1_XJUSTIfç )
		//oHtml:ValByName( "VL_TOTAL"   , transform( SC1->C1_ZTOTSC,'@E 999,999,999,999.99' ) )
		
		U_CONSOLE("Montando os itens do formulario HTML de aprovacao...",cFunc)

		While SC1->(.not. EOF() .and. C1_FILIAL + C1_NUM == cKeySC1 )
			aadd((oHtml:ValByName("prod.cItem"    )),SC1->C1_ITEM )
			aadd((oHtml:ValByName("prod.cCod"     )),SC1->C1_PRODUTO )
			aadd((oHtml:ValByName("prod.cDesc"    )),getDsPrd(SC1->C1_PRODUTO) )
			aadd((oHtml:ValByName("prod.cUM"      )),SC1->C1_UM )
			aadd((oHtml:ValByName("prod.nQuant"   )),transform( SC1->C1_QUANT,'@E 999,999,999.99' ) )
			//aadd((oHtml:ValByName("prod.nVrUnit"  )),transform( SC1->C1_VUNIT,'@E 999,999,999.99' ) )
			//aadd((oHtml:ValByName("prod.nVrTotal" )),transform( SC1->(C1_QUANT*C1_VUNIT),'@E 999,999,999.99' ) )
			aadd((oHtml:ValByName("prod.dEntrega" )),DToC(SC1->C1_DATPRF) )
			aadd((oHtml:ValByName("prod.cObs"     )),SC1->C1_OBS )

			SC1->(DbSkip())
		EndDo
		
		U_CONSOLE("Montando a tabela de aprovadores no formulario HTML...",cFunc)

		// salvar posicionamento antes da iteração
		aAreaCR := SCR->(GetArea())
		SCR->(DbSetOrder(1))
		SCR->(DbSeek(cKeySCR))

		While SCR->( .not. eof() .and. Alltrim(CR_FILIAL + CR_TIPO + CR_NUM) == cKeySCR )
			aadd((oHtml:ValByName("proc.nivel"   )),SCR->CR_NIVEL )
			aadd((oHtml:ValByName("proc.cApov"   )),&('UsrFullName(SCR->CR_USER)') )
			aadd((oHtml:ValByName("proc.cSit"    )),getSitApr(SCR->CR_STATUS) )
			aadd((oHtml:ValByName("proc.dDtLib"  )),dtoc(SCR->CR_DATALIB) )
			aadd((oHtml:ValByName("proc.cObs"    )),SCR->CR_OBS )
			
			SCR->( dbSkip() )
		EndDo

		// restaurar posicionamento da tabela depois da iteração
		restArea( aAreaCR )
		
		U_CONSOLE("Copiando o arquivo HTML para o diretorio " + cAprDir + "...",cFunc)

		// inicializar o processo por salvar o html na pasta de aprovsc
		cMailID := oProces:Start(cAprDir,.T.)
		
		//---------------------------------------------------------------------
		// Etapa 2: Envio do link do arquivo HTML para o aprovador
		//---------------------------------------------------------------------
		If file(cAprDir+cMailID+".htm")

			U_CONSOLE("Arquivo HTML copiado com sucesso " + cAprDir + cMailID + ".htm",cFunc)
						
			cHtmLnk := cAprDir + cMailID + ".htm"
			
			U_CONSOLE("Iniciando a etapa 2 do processo de aprovacao...",cFunc)

			oProces:NewTask("Solicitacao de Compras Nr. " + cNumSC, GetWfLnk())

			//oProces:cSubject := "Solicitação de Compras Nr. " + cNumSC
			oProces:cTo := Alltrim( usrRetMail(SCR->CR_USER))
			
			oHtml := oProces:oHTML 
			
			oHtml:ValByName("EMPRESA"	,FWEmpName(cEmpAnt))
			oHtml:ValByName("CFIL2"		,FWFilialName(,xFil))
			oHtml:ValByName("CAPROVADOR",usrFullName(SCR->CR_USER))
			oHtml:ValByName("CSOLICIT"  ,cNumSC)
			oHtml:ValByName("CFILIAL"   ,xFil)
			oHtml:ValByName("CFILDES"   ,fwFilialName(,xFil))
			oHtml:ValByName("proc_link" ,GetWfHtp() + strTran(cHtmLnk,"\","/"))
			
			U_CONSOLE("Enviando e-mail de notIficacao para o aprovador (" + SCR->CR_USER + ")...",cFunc)
			oProces:Start()

			U_CONSOLE("Atualizando dados na alcada de aprovacao...",cFunc)

			RecLock("SCR",.F.)
				SCR->CR_WF   	:= "1"      		//--Enviado
				SCR->CR_WFID 	:= cMailID 		//--Campo CR_WFID deve estar com tamanho 20
			SCR->(MsUnlock())

			U_CONSOLE("Processo de aprovacao criado com sucesso",cFunc)
		Else
			U_CONSOLE("Arquivo HTML nao copiado: " + cAprDir + cMailID + ".htm",cFunc)
		EndIf
	Else
		U_CONSOLE("Solicitacao nao encontrada",cFunc)
	EndIf

	RestArea(aAreaC1)

Return 

/*/{Protheus.doc} getSitApr
Retorna a descrição do status de aprovação conforme código do parâmetro.
Status: '01' - "Aguardando", '02' - "Em aprovação", '03' - "Aprovado",
'04' - "Bloqueado", '05' - "Nível Liberado". Caso não seja nenhum destes o retorno será vazio. 
@author 	Ricardo Tavares Ferreira
@since 		31/08/2018
@version 	12.1.17
@Return 	Caracter
@obs 		Ricardo Tavares - Construcao Inicial
/*/
//=======================================================================================
	Static Function getSitApr(cStatus)
//=======================================================================================

	Local cSituac := ""
	Default cStatus := ""

	Do Case
		Case cStatus == "01"
			cSituac := "Aguardando"
		Case cStatus == "02"
			cSituac := "Em Aprovacao"
		Case cStatus == "03"
			cSituac := "Aprovado"
		Case cStatus == "04"
			cSituac := "Bloqueado"
		Case cStatus == "05"
			cSituac := "Nível Liberado"
	End Case

Return cSituac

/*/{Protheus.doc} getDsPrd
Retorna a descrição do produto verIficando o cadastro na tabela de complemento do produto (SB5). 
Caso não tenha descrição, retornará a descrição conforme tabela de produtos (SB1).
@author 	Ricardo Tavares Ferreira
@since 		31/08/2018
@version 	12.1.17
@Return 	Caracter
@obs 		Ricardo Tavares - Construcao Inicial
/*/
//=======================================================================================
	Static Function getDsPrd(cProduto)
//=======================================================================================

	Local cDescPrd := ""
	Local cChavSB5 := FWXFilial("SB5")+cProduto
	Local cChavSB1 := FWXFilial("SB1")+cProduto

	Default cProduto := ""
	
	cDescPrd := Posicione("SB5",1,cChavSB5,"B5_CEME")

	If Empty(cDescPrd)
		cDescPrd := Posicione("SB1",1,cChavSB1,"B1_DESC")
	EndIf

Return cDescPrd

/*/{Protheus.doc} GetWfDir
Retorna o caminho parcial do diretório do workflow conforme registrado no parâmetro MV_WFDIRWF. Caso o parâmetro não esteja preenchido ou não
informado, irá assumir o diretório "\workflow". Em ambos os casos, irá retornar com o identIficador de diretório "\" como último caracter.
@author 	Ricardo Tavares Ferreira
@since 		31/08/2018
@version 	12.1.17
@Return 	Caracter
@obs 		Ricardo Tavares - Construcao Inicial
/*/
//=======================================================================================
	Static Function GetWfDir()
//=======================================================================================

	Local cRetDir := ""

	cRetDir := Alltrim(GetNewPar("MV_WFDIRWF","\workflow"))

	If Right(Rtrim(cRetDir),1) # "\"
		cRetDir := Rtrim(cRetDir) + "\"
	EndIf

Return cRetDir

/*/{Protheus.doc} GetApDir
Retorna o caminho parcial do diretório de HTML de aprovação. O caminho é constituído por: \workflow\empXXXX\aprovsc\ onde XXXX representa o grupo de
empresas atual. Realiza a verIficação da existência do diretório. Caso não exista cria o diretório.
@author 	Ricardo Tavares Ferreira
@since 		31/08/2018
@version 	12.1.17
@Return 	Caracter
@obs 		Ricardo Tavares - Construcao Inicial
/*/
//=======================================================================================
	Static Function GetApDir()
//=======================================================================================

	Local cDirAp 	:= GetWfDir() + "emp" + cEmpAnt + "\html\aprovsc\"
	Local cFunc		:= "GetApDir"
	
	// VerIfica e cria, se necessario, o diretorio para gravacao do HTML
	If .not. ExistDir(cDirAp)
		If MakeDir(cDirAp) == 0
			U_CONSOLE("Diretorio dos HTML's criado com sucesso. -> "+cDirAp,cFunc)
		Else
			U_CONSOLE("Erro na criacao do diretorio dos HTML's! -> "+cDirAp,cFunc)
			cDirAp := GetWfDir() + "emp" + cEmpAnt + "\"
		EndIf
	EndIf

Return cDirAp

/*/{Protheus.doc} GetWfLnk
Retorna o caminho parcial do arquivo de envio do link de aprovação. O caminho é constituído por: \workflow\sc-aprovacao-link..html.
@author 	Ricardo Tavares Ferreira
@since 		31/08/2018
@version 	12.1.17
@Return 	Caracter
@obs 		Ricardo Tavares - Construcao Inicial
/*/
//=======================================================================================
	Static Function GetWfLnk()
//=======================================================================================

	Local cWfDir  := GetWfDir()
	Local cReturn := cWfDir+"sc-aprovacao-link.htm"

Return cReturn

/*/{Protheus.doc} GetWfHtp
Retorna o caminho parcial do arquivo de envio do link de aprovação. O caminho é constituído por: \workflow\linksc.html 
@author 	Ricardo Tavares Ferreira
@since 		31/08/2018
@version 	12.1.17
@Return 	Caracter
@obs 		Ricardo Tavares - Construcao Inicial
/*/
//=======================================================================================
	Static Function GetWfHtp()
//=======================================================================================

	Local cReturn := Alltrim(GetNewPar("MV_XWFHTTP","http://Localhost:8181"))

	// se houver barra invertida no final, retira
	If Right(cReturn,1) == "\" 
		cReturn := Substr(cReturn,1,Len(cReturn) - 1)
	EndIf

Return cReturn

/*/{Protheus.doc} SIWKFC01
Retorno do link de aprovação remetido pela função createPr. Caso o usuário clique em REPROVAR a solicitação será bloqueada. Em caso de APROVAR, a
solicitação será aprovada e procurará a próxima alçada, se houver, para enviar uma notIficação.
@author 	Ricardo Tavares Ferreira
@since 		31/08/2018
@version 	12.1.17
@Return 	Nulo
@obs 		Ricardo Tavares - Construcao Inicial
/*/
//=======================================================================================
	User Function SIWKFC01(oProces)
//=======================================================================================

	Local cOpc    	:= Alltrim(oProces:oHtml:RetByName("OPC"   ))
	Local xFil 		:= Alltrim(oProces:oHtml:RetByName("FILIAL"))
	Local cNumSC 	:= Alltrim(oProces:oHtml:RetByName("NUMSC" ))
	Local cObserv 	:= Alltrim(oProces:oHtml:RetByName("OBS"   ))
	Local cAprov  	:= Alltrim(oProces:oHtml:RetByName("CAPROV"))
	Local aAreaCR 	:= SCR->(GetArea())
	Local cChaveSCR := xFil + "SC" + cNumSC + space(tamSx3("CR_NUM")[1] - len(cNumSC)) + cAprov
	Local cFunc		:= "SIWKFC01"
	Local nRecnoSCR := 0

	Default oProces := Nil

	U_CONSOLE("Iniciando processo de retorno de aprovacao [OPC]=>[" + cOpc + "]...",cFunc)

	// finaliza o processo independentemente do resultado
	oProces:Finish()
	
	U_CONSOLE("Procurando alcada de aprovacao " + cChaveSCR + "...",cFunc)

	// posiciona na alçada do retorno
	SCR->(DbSetOrder(2))

	If SCR->(DbSeek(cChaveSCR))
		If SCR->(Empty(CR_DATALIB) .and. CR_STATUS == "02")

			nRecnoSCR := SCR->(recno())
			U_CONSOLE("Atualizando o registro de aprovacao encontrado...",cFunc)

			// atualiza o registro de aprovação indicando a resposta
			RecLock("SCR",.F.)
				SCR->CR_WF := "2" // Status 2 - respondido
			SCR->(MsUnlock())
			
			If cOpc == "APROVAR"
				U_RT99WF03(xFil,cNumSC,cObserv,nRecnoSCR)
			Else
				U_RT99WF04(xFil,cNumSC,cObserv,nRecnoSCR)
			EndIf
		Else
			U_CONSOLE("A alcada encontrada se encontra finalizada!",cFunc)
		EndIf
	EndIf

	RestArea(aAreaCR)
	U_CONSOLE("Processo de retorno de aprovacao finalizado.",cFunc)

Return 

/*/{Protheus.doc} SIWKFD01
NotIfica ao usuário que abriu a solicitação do status atualizado de aprovação ou reprovação por parte dos aprovadores.
@author 	Ricardo Tavares Ferreira
@since 		31/08/2018
@version 	12.1.17
@param 		cStatus, char, (A)provada / (R)eprovada
@param 		xFil, char, Filial da solicitação
@param 		cNumSC, char, Número da solicitação
@param 		cUser, char, Código do requisitante
@param 		cObserv, char, Observação do aprovador
@Return 	Nulo
@obs 		Ricardo Tavares - Construcao Inicial
/*/
//=======================================================================================
	User Function SIWKFD01(cStatus,xFil,cNumSC,cUser,cObserv,cMailComp)	
//=======================================================================================
		
	Local cNotfSC  		:= GetWfDir() + "sc-aprovacao-notIf.htm"
	Local oProcess 		:= nil
	Local oHtml    		:= nil
	Local cResult  		:= ""
	Local cMailGes 		:= SUPERGETMV("MV_XUSGCOM",.F.,"000001")
	Local cFunc			:= "SIWKFD01"

	Default cStatus 	:= ""
	Default xFil 		:= ""
	Default cNumSC 		:= ""
	Default cUser 		:= ""
	Default cObserv 	:= ""
	Default cMailComp 	:= ""

	Do Case
	Case cStatus == "A" // (A)provada / (R)eprovada
		//cResult := '<span style="color: #0000FF; font-weight: bold;">Aprovada</span>'
		cResult := 'Aprovada'
	Case cStatus == "R"
		//cResult := '<span style="color: #FF0000; font-weight: bold;">Reprovada</span>'
		cResult := 'Reprovada'
	otherwise
		U_CONSOLE("Parametro de status incorreto: " + cStatus,cFunc)
		Return 
	EndCase

	oProcess := TWFProcess():New( "NOTIfSC", "NotIficacao do Workflow" )

	oProcess:NewTask( "000110", cNotfSC )
	oProcess:NewVersion(.T.)
	oProcess:cSubject := "Status de Solicitacao de Compra: " + cNumSC + "/" + U_RetDesc("FILIAL",xFil,cEmpAnt)
	oProcess:cTo      := Alltrim(UsrRetMail(cUser))
	oProcess:cCC      := Alltrim(UsrRetMail(cMailGes)) +";"+ Alltrim(UsrRetMail(cMailComp))
	oProcess:userSiga := cUser
	
	oHtml := oProcess:oHTML
	
	oHtml:ValByName("EMPRESA",FWEmpName(cEmpAnt))
	oHtml:ValByName("CFIL2",FWFilialName(,xFil))
	oHtml:ValByName("CFILDES",FWFilialName(,xFil))
	oHtml:ValByName("CNUMERO",cNumSC)
	oHtml:ValByName("CFILIAL",xFil)
	oHtml:ValByName("CUSER"  ,UsrFullName(cUser))
	oHtml:ValByName("CRESULT",cResult)
	oHtml:ValByName("COBS"   ,cObserv)

	oProcess:Start()
	oProcess:Finish()
	
Return 
