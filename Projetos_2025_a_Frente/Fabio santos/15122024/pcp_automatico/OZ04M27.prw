#include "totvs.ch"
#include "topconn.ch"
#include "fwmvcdef.ch"
#include "tryexception.ch"
#include "fweditpanel.ch"
#include "ozminerals.ch"

#DEFINE ROTINA_FILE				"OZ04M27.prw"
#DEFINE VERSAO_ROTINA			"V" + Trim(AllToChar(GetAPOInfo(ROTINA_FILE)[04])) + "-" + Trim(AllToChar(GetAPOInfo(ROTINA_FILE)[05])) + "[" + Trim(AllToChar(GetAPOInfo(ROTINA_FILE)[03])) + "]"

#DEFINE ALIAS_FORM0 			"PA0"
#DEFINE ALIAS_GRID0 			"PA1"
#DEFINE MODELO					"OZ04M27"
#DEFINE ID_MODEL				"MZ04M27"
#DEFINE TITULO_MODEL			"Pre Cadastro Dos Processos Produtivo - OZMinerals " 
#DEFINE TITULO_VIEW				TITULO_MODEL
#DEFINE ID_MODEL_FORM0			ALIAS_FORM0+"FORM0"
#DEFINE ID_MODEL_GRID0			ALIAS_GRID0+"GRID0"
#DEFINE ID_VIEW_FORM0			"VIEW_FORM0"
#DEFINE ID_VIEW_GRID0			"VIEW_GRID0"
#DEFINE PREFIXO_ALIAS_FORM0		Right(ALIAS_FORM0,03)
#DEFINE PREFIXO_ALIAS_GRID0		Right(ALIAS_GRID0,03)

#DEFINE  AGUARDANDO       "1"
#DEFINE  GERADO_SUCESSO   "2"

/*/{Protheus.doc} OZ04M27 - Gestão Automatica de Producação 

	Função responsável que contem um pre cadastro para carregar a tabela PAY

@type function
@version  1.0
@author Fábio Santos 
@since 21/11/2023

@param aAutoCab, array, Array com dados para cadastro
@param aAutoItens, array, Array com dados dos itens
@param nOperacao, numeric, Operação da ação
@return variant, sem retorno

@nested-tags:Frameworks/OZminerals
/*/ 
User Function OZ04M27(aAutoCab,aAutoItens,nOperacao)
	Local oFwMBrowse		:= Nil
	Local cAliasForm		:= ALIAS_FORM0
	Local cModelo			:= MODELO
	Local cTitulo			:= TITULO_VIEW
	Local bKeyCTRL_X		:= {|| }
	Local bFecharEdicao		:= {|| ( oView := FwViewActive(), Iif( Type("oView") == "O" , oView:ButtonCancelAction() , .F. ) ) }	

	If ValType(aAutoCab) == "A" .And. ValType(aAutoItens) == "A" 
		runAutoExecute(aAutoCab,aAutoItens,nOperacao)
	Else
		If ( FwAliasInDic(cAliasForm) )
			Private aRotina 	:= MenuDef()

			oFwMBrowse := FWMBrowse():New()
			oFwMBrowse:SetAlias(cAliasForm)		
			oFwMBrowse:SetDescription(cTitulo)
			oFwMBrowse:SetMenuDef(cModelo)
			
			oFwMBrowse:SetLocate()	
			oFwMBrowse:SetAmbiente(.F.)
			oFwMBrowse:SetWalkthru(.T.)		
			oFwMBrowse:SetDetails(.T.)
			oFwMBrowse:SetSizeDetails(60)
			oFwMBrowse:SetSizeBrowse(40)

			oFwMBrowse:SetCacheView(.T.)
			
			oFwMBrowse:AddLegend( cAliasForm + "_MSBLQL == '" + AGUARDANDO + "'"	, "RED"		, "Registro Bloqueado" )
			oFwMBrowse:AddLegend( cAliasForm + "_MSBLQL == '" + GERADO_SUCESSO  + "'"		, "GREEN"	, "Registro Desbloqueado" )
		
			oFwMBrowse:SetAttach( .T. )
			oFwMBrowse:SetOpenChart( .T. )	

			bKeyCTRL_X	:= SetKey( K_CTRL_X, bFecharEdicao )
					
			oFwMBrowse:Activate()
			
			SetKey( K_CTRL_X, bKeyCTRL_X )
		Else
			MsgStop("Atenção! Alias da Tabela '" + cAliasForm + "' não encontrado nesse grupo de empresa.",GRP_GROUP_NAME)
		EndIf
	EndIf
	
Return

/*
	Função que Define o Modelo de Dados do Cadastro
*/
Static Function ModelDef()
	Local cIDModel				:= ID_MODEL
	Local cTitulo				:= TITULO_MODEL
	Local cIDModelForm			:= ID_MODEL_FORM0
	Local cIDModelGrid			:= ID_MODEL_GRID0
	Local cAliasForm 			:= ALIAS_FORM0
	Local cAliasGrid 			:= ALIAS_GRID0
	Local oStructForm 			:= Nil
	Local oStructGrid			:= Nil
	Local oModel 				:= Nil							 
	Local bActivate				:= {|oModel| activeForm(oModel) }
	Local bCommit				:= {|oModel| saveForm(oModel)}
	Local bCancel   			:= {|oModel| cancForm(oModel)}
	Local bpreValidacao			:= {|oModel| preValid(oModel)}
	Local bposValidacao			:= {|oModel| posValid(oModel)} 
	//Local bLinePre				:= {|oModelGrid,  nLine,  cAction, cField| LinePreValid(oModelGrid,  nLine,  cAction, cField)}
	
	Local cPrefForm				:= PREFIXO_ALIAS_FORM0
	Local cPrefGrid				:= PREFIXO_ALIAS_GRID0
	Local cCpoFFilial			:= cPrefForm+"_FILIAL"
	Local cCpoFTabela       	:= cPrefForm+"_TAB"
	Local cCpoGFilial			:= cPrefGrid+"_FILIAL"
	Local cCpoGTabela    	    := cPrefGrid+"_TAB"
	Local cCpoGCodProduto		:= cPrefGrid+"_COD"
	Local cCpoGFilDestino       := cPrefGrid+"_FILDES"
	Local cCpoGLocal    		:= cPrefGrid+"_LOCDES"
	Local cCpoGTpMov    		:= cPrefGrid+"_TMMOV"

	oStructForm		:= FWFormStruct( 1, cAliasForm )
	oStructGrid 	:= FWFormStruct( 1, cAliasGrid )

	oModel	:= MPFormModel():New(cIdModel,bpreValidacao,bposValidacao,bCommit,bCancel)
	
	oModel:AddFields( cIDModelForm, /*cOwner*/, oStructForm,/*bpreValidacao*/,/*bposValidacao*/,/*bCarga*/)

	oModel:AddGrid(cIDModelGrid,cIDModelForm,oStructGrid,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,/*bLoad*/)
	oModel:GetModel(cIDModelGrid):SetUniqueLine( { cCpoGCodProduto, cCpoGFilDestino, cCpoGLocal, cCpoGTpMov } )
	oModel:SetRelation(cIDModelGrid,{{cCpoGFilial,'xFilial("'+cAliasForm+'")'},{cCpoGTabela,cCpoFTabela}},(cAliasGrid)->(IndexKey(1)))	
	
	oModel:SetPrimaryKey( { cCpoFFilial, cCpoFTabela } )
	oModel:SetActivate(bActivate)
	oModel:SetDescription(cTitulo)
	oModel:GetModel(cIDModelForm):SetDescription(cTitulo)

Return oModel

/*
	Função que Cria a Interface do Cadastro
*/
Static Function ViewDef()
	Local cModelo				:= MODELO
	Local cIDModelForm			:= ID_MODEL_FORM0
	Local cIDModelGrid			:= ID_MODEL_GRID0
	Local cIDViewForm			:= ID_VIEW_FORM0
	Local cIDViewGrid			:= ID_VIEW_GRID0
	Local cAliasForm 			:= ALIAS_FORM0
	Local cAliasGrid 			:= ALIAS_GRID0
	Local oModel 				:= Nil
	Local oStructForm			:= Nil
	Local oStructGrid			:= Nil
	Local oView					:= Nil
	
	Local cPrefGrid				:= PREFIXO_ALIAS_GRID0
	Local cCpoGTabela   		:= cPrefGrid+"_TAB"
	Local cCpoGItemProduto		:= cPrefGrid+"_ITEM"
	Local cCposToHide			:= cCpoGTabela+"|"

	oModel 			:= FWLoadModel( cModelo )
	
	oStructForm		:= FWFormStruct( 2, cAliasForm )
	oStructGrid	 	:= FWFormStruct( 2, cAliasGrid , {|cCampo| !( AllTrim(cCampo)+"|" $ cCposToHide) })	

	oStructGrid:RemoveField(cCpoGTabela)

	oView 			:= FWFormView():New()

	oView:SetModel(oModel)

	oView:AddField(cIDViewForm,oStructForm,cIDModelForm)
	oView:AddGrid(cIDViewGrid,oStructGrid,cIDModelGrid)
	
	oView:CreateHorizontalBox('SUPERIOR',40)
	oView:CreateHorizontalBox('INFERIOR',60)
	
	oView:SetOwnerView( cIDViewForm,'SUPERIOR' )
	oView:SetOwnerView( cIDViewGrid,'INFERIOR' )
	
	oView:SetViewProperty(cIDViewForm,"SETLAYOUT",{ FF_LAYOUT_VERT_DESCR_TOP , 5 } )
	
	oView:SetViewProperty(cIDViewGrid,"ENABLENEWGRID")
	oView:SetViewProperty(cIDViewGrid,"GRIDFILTER")
	oView:SetViewProperty(cIDViewGrid,"GRIDSEEK")
	
	oView:AddIncrementField( cIDViewGrid, cCpoGItemProduto )
	
	oView:EnableTitleView(cIDViewForm, "Dados da Tabela")
	oView:EnableTitleView(cIDViewGrid, "Lista de Itens da Tabela")
	
Return oView

/*
	Rotina para Exportação de Dados do Modelo Ativo para o Excel
*/
Static Function exportModeltoExcel(lUseGrid)
	Local oModel		:= FwModelActive()
	Local cIDModelForm	:= ID_MODEL_FORM0
	Local cIDModelGrid	:= ID_MODEL_GRID0
	Local oModelForm	:= oModel:GetModel(cIDModelForm)
	Local oModelGrid	:= Iif(lUseGrid,oModel:GetModel(cIDModelGrid),Nil)
	Local aFormHeader	:= {}
	Local aFormData		:= {}
	Local aGridHeader	:= {}
	Local aGridData		:= {}
	Local aExport		:= {}
	Local bAcao 		:= {|| }
	
	Default lUseGrid	:= .F.

	loadDataModel(oModelForm,@aFormHeader,@aFormData,.T.,TYPE_HEADER)
	If lUseGrid
		loadDataModel(oModelGrid,@aGridHeader,@aGridData,.T.,TYPE_ITEMS)
	EndIf

	aAdd( aExport, {"CABECALHO", oModelForm:GetDescription(), aFormHeader, aFormData } )
	If lUseGrid
		aAdd( aExport, {"GETDADOS", oModelGrid:GetDescription(), aGridHeader, aGridData } )	
	EndIf
	
	bAcao 	:= { || DlgToExcel(aExport) }
	
	FwMsgRun( ,bAcao, GRP_GROUP_NAME, "Exportando Dados para o Excel..." )
	
Return

/*
	Carrega os Dados de Estrutura do Model
*/
Static Function loadDataModel(oModel,aFields,aData,lUseTitle,nType)
	Local nRecord			:= 0
	Local nField			:= 0
	Local cField			:= ""	
	Local uContent			:= ""
	Local aRecord			:= {}
	Local oIpArraysObject	:= Nil
	
	Default lUseTitle		:= .T.

	aFields	:= {}
	aData	:= {}

	If ValType(oModel) == "O"
		If nType == TYPE_HEADER
			For nField:=1 to Len(oModel:oFormModelStruct:aFields)		
				cField 	:= oModel:oFormModelStruct:aFields[nField,03]
				
				If !Empty(cField)
					uContent	:= oModel:GetValue(cField)
					
					If lUseTitle
						cField := RetTitle(cField)
					EndIf
					aAdd( aFields, cField )
					aAdd( aData, uContent )
				EndIf
			Next nField
		Else	
			For nRecord:=1 to oModel:GetQtdLine()
				oModel:GoLine(nRecord)
				
				aRecord := {}
				For nField:=1 to Len(oModel:oFormModelStruct:aFields)				
					cField 		:= oModel:oFormModelStruct:aFields[nField,03]
					
					If !Empty(cField)
						uContent	:= oModel:GetValue(cField)			
						
						If nRecord == 1
							aAdd( aFields, cField )
						EndIf
						aAdd( aRecord, uContent )
					EndIf
				Next nField
				aAdd( aRecord, .F. )
				
				aAdd( aData , aRecord )
				
			Next nRecord
			
			oIpArraysObject := IpArraysObject():newIpArraysObject()
			aFields := oIpArraysObject:convToHeader(aFields,.T.)
			freeObj(oIpArraysObject)
		EndIf
	EndIf
	
Return

/*
	Função que Monta o Menu da Rotina do Cadastro
*/
Static Function MenuDef()
	Local aRotina 		:= {}
	
	ADD OPTION aRotina TITLE "Visualizar"	ACTION "u_Z0427Manutencao(" + cValToChar(MODEL_OPERATION_VIEW) + ")" 	OPERATION 2	ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"		ACTION "u_Z0427Manutencao(" + cValToChar(MODEL_OPERATION_INSERT) + ")" 	OPERATION 3	ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"		ACTION "u_Z0427Manutencao(" + cValToChar(MODEL_OPERATION_UPDATE) + ")" 	OPERATION 4	ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"		ACTION "u_Z0427Manutencao(" + cValToChar(MODEL_OPERATION_DELETE) + ")" 	OPERATION 5	ACCESS 0
	ADD OPTION aRotina TITLE "Copiar"		ACTION "u_Z0427Manutencao(" + cValToChar(MODEL_OPERATION_COPY) + ")" 	OPERATION 9	ACCESS 0	

Return aRotina

/*
	Rotina para Manutenção do Registro
*/
User Function Z0427Manutencao(nOperation)
	Local cModelo		:= MODELO
	Local cOperacao		:= ""
	Local bAcao			:= {|| }
	Local bCloseOnOK	:= {|| .F. }
	Local bOK			:= {|| .T. }
	Local bCancel		:= {|| .T. }
	Local lRet			:= .F.
	
	Private VISUALIZAR	:= .F.
	Private INCLUI		:= .F.
	Private ALTERA		:= .F.
	Private EXCLUI		:= .F.
	Private COPIA		:= .F.
	Private nRet		:= 0

	If ( nOperation == MODEL_OPERATION_VIEW )
		VISUALIZAR := .T.
		cOperacao 	:= "Visualizar"	
	ElseIf ( nOperation == MODEL_OPERATION_INSERT )
		INCLUI 		:= .T.
		cOperacao 	:= "Inclusão"
		bCloseOnOK	:= {|| .T. }
	ElseIf ( nOperation == MODEL_OPERATION_UPDATE )
		ALTERA 		:= .T.
		cOperacao 	:= "Alteração"
	ElseIf ( nOperation == MODEL_OPERATION_DELETE )
		EXCLUI 		:= .T.
		cOperacao 	:= "Exclusão"
		bCloseOnOK	:= {|| .T. }		
	ElseIf ( nOperation == MODEL_OPERATION_COPY )
		COPIA 		:= .T.
		cOperacao 	:= "Cópia"
		bCloseOnOK	:= {|| .T. }
	EndIf

	bAcao := {|| nRet := FWExecView(cOperacao,"VIEWDEF." + cModelo, nOperation,  , bCloseOnOK, bOK, , , bCancel ) }

	If ( SrvDisplay() .And. !IsBlind() )
		FwMsgRun(, bAcao, GRP_GROUP_NAME, "Carregando..." )
	Else
		Eval(bAcao)
	EndIf
	
	If ( nRet == 0 )
		lRet := .T.
	EndIf

Return lRet


/*
	Função para Salvar os Dados do Cadastro usando MVC
*/ 
Static Function saveForm(oModel)
	Local lRet 	:= .T.

	FWModelActive(oModel)	
	lRet := FWFormCommit(oModel)
	
Return lRet

/*
	Função executado no Cancelamento da Tela de Cadastro
*/ 
Static Function cancForm(oModel)
	Local nOperation	:= oModel:GetOperation()
	Local lRet			:= .T.

	If ( nOperation == MODEL_OPERATION_INSERT )
		RollBackSX8()
	EndIf

Return lRet

/*
	Função para Validar os Dados Antes da Confirmação da Tela do Cadastro
*/
Static Function preValid(oModel)
	Local nOperation	:= oModel:GetOperation()		
	Local cIDModelForm	:= ID_MODEL_FORM0	
	Local oModelForm	:= oModel:GetModel(cIDModelForm)	
	
	Local cPrefForm		:= PREFIXO_ALIAS_FORM0
	Local cCpoHoraAlt	:= cPrefForm+"_HORA"
	Local lRet			:= .T.

	If ( nOperation == MODEL_OPERATION_INSERT ) .Or. ( nOperation == MODEL_OPERATION_UPDATE )
		oModelForm:LoadValue(cCpoHoraAlt,Time())
	EndIf
	
Return lRet

/*
	Função para Validar os Dados Antes da Confirmação da Linha da Grid
*/
Static Function LinePreValid(oModelGrid, nLinha, cAcao, cCampo)
	Local lRet				:= .T.
	
Return lRet


/*
	Função para Validar os Dados Após Confirmação da Tela de Cadastro - Verifica se pode incluir
*/
Static Function posValid(oModel)
	Local lRet					:= .T.

Return lRet

/*
	Função de Validação executada na Ativação do Modelo
*/
Static Function activeForm(oModel)
	Local cIDModelGrid		:= ID_MODEL_GRID0
	Local oModelGrid		:= oModel:GetModel(cIDModelGrid)
	Local lRet				:= .T.

	updItensCposVirtuais(oModelGrid)

Return lRet

/*
	Atualiza os Campos Virtuais dos Itens do Contrato
*/
Static Function updItensCposVirtuais(oModelGrid)
	Local cPrefGrid			:= PREFIXO_ALIAS_GRID0
	Local cCpoProd			:= cPrefGrid+"_COD"
	Local cCpoDProd			:= cPrefGrid+"_DESC"
	Local cCodProduto		:= ""
	Local cDescProd			:= ""
	Local nRecord			:= 0
	Local nBackOperation	:= 0
	Local lNoUpdateLine		:= .F.
	
	If ValType(oModelGrid) == "O"
	
		If !( oModelGrid:CanUpdateLine() ) 
			oModelGrid:SetNoUpdateLine(.F.)
			lNoUpdateLine := .T.
		EndIf
		
		If !( oModelGrid:CanSetValue(cCpoDProd) )
			nBackOperation := oModelGrid:oFormModel:nOperation
			oModelGrid:oFormModel:nOperation := 3	
		EndIf
	
		For nRecord:=1 to oModelGrid:Length()
			oModelGrid:GoLine(nRecord)
			
			cCodProduto	:= oModelGrid:GetValue(cCpoProd)
			
			dbSelectArea("SB1")
			SB1->(dbSetOrder(1))
			If SB1->(dbSeek(xFilial("SB1")+cCodProduto))
				cDescProd 		:= Left(SB1->B1_DESC,60)
			Else
				cDescProd 		:= ""
			EndIf
					
			oModelGrid:LoadValue(cCpoDProd,cDescProd)			
		Next nRecord
		
		oModelGrid:GoLine(1)
		
		If lNoUpdateLine
			oModelGrid:SetNoUpdateLine(.T.)
		EndIf
		
		If nBackOperation > 0
			oModelGrid:oFormModel:nOperation := nBackOperation
		EndIf
		
	EndIf
	
Return

/*
	Tratamento de Logs para Rotina Automática e pela Interface com Solução
*/
Static Function addLogs(cLogs,cSolucao,lRet)
	Local aSolucao 	:= {}
	
	Default lRet	:= .F.
	
	If !( lRet )
		If !Empty(cSolucao)
			aAdd( aSolucao , cSolucao )
		EndIf
		Help(,,"HELP " + ProcName(1),,cLogs,1,0, Nil, Nil, Nil, Nil, Nil, aSolucao )
	EndIf
	showLogInConsole(cLogs)
	
Return

/*
	Executa a Rotina Automática de Gravação
*/
Static Function runAutoExecute(aAutoCab,aAutoItens,nOperacao)
	Local cModelo 		:= MODELO
	Local cAliasForm 	:= ALIAS_FORM0
	Local cAliasGrid 	:= ALIAS_GRID0
	Local cIDModelForm 	:= cAliasForm+"FORM0"
	Local cIDModelGrid 	:= cAliasGrid+"GRID0"
	Local oClassMVCAuto := ClassMVCAuto():newClassMVCAuto()	
	Local aRet			:= {}
	Local cErro			:= ""
	Local lRet 			:= .F.
	
	Default aAutoCab	:= {}
	Default aAutoItens	:= {}
	Default nOperacao	:= MODEL_OPERATION_INSERT
	
	If ( podeExecutar(aAutoCab,aAutoItens,@cErro) )

		If ( nOperacao == MODEL_OPERATION_UPDATE )
			setLinPos(@aAutoItens)
		EndIf

		//Se chamado por rotina externa - Reduz a Carga de Dados do Dicionário de Dados
		If Type("oOZ04M27") == "O"
			oClassMVCAuto:setObjectModel(oOZ04M27)
		EndIf
	
		oClassMVCAuto:setAliasForm(cAliasForm)
		oClassMVCAuto:setAliasGrid(cAliasGrid)
		oClassMVCAuto:setModelo(cModelo)
		oClassMVCAuto:setModelForm(cIDModelForm)
		oClassMVCAuto:setModelGrid(cIDModelGrid)		
		oClassMVCAuto:setAutoCab(aAutoCab)
		oClassMVCAuto:setAutoItens(aAutoItens)
		oClassMVCAuto:setOperacao(nOperacao)
		oClassMVCAuto:setUseTransaction(.T.)		
		oClassMVCAuto:setRegMemory(.F.)		
		oClassMVCAuto:lAudit := .F.
		
		aRet 	:= oClassMVCAuto:execute()	
		
		lRet	:= aRet[01]
		cErro   := aRet[02]
	EndIf
	
	If ( lRet )
		lMsErroAuto := .F.
		addLogs("Processado com Sucesso.",,.T.)
	Else
		lMsErroAuto := .T.
		addLogs(cErro)
	EndIf

Return lRet

/*
	Verifica se pode Executar
*/
Static Function podeExecutar(aAutoCab,aAutoItens,cErro)
	Local lRet	:= .F.
	
	Begin Sequence
	
		If ( Len(aAutoCab) == 0 )
			cErro := "Falha na Carga dos Dados de Cabeçalho."
			Break
		EndIf
		
		If ( Len(aAutoItens) == 0 )
			cErro := "Falha na Carga dos Dados dos Itens."
			Break
		EndIf		
		
		lRet := .T.
	
	End Sequence
	
	If !lRet
		showLogInConsole(cErro)
	EndIf
	
Return lRet

/*
	Adiciona LINPOS ao array dos itens
*/
Static Function setLinPos(aAutoItens)
	Local nContLinha	:= 0
	Local nPosItem		:= 0
	Local cPrefGrid		:= PREFIXO_ALIAS_GRID0
	Local cCpoItem		:= cPrefGrid+"_ITEM"

	For nContLinha := 1 To Len(aAutoItens)
		nPosItem := aScan(aAutoItens[nContLinha],{|Record| Alltrim(Record[1]) == Alltrim(cCpoItem)})

		If ( nPosItem <> 0 )
			aAdd(aAutoItens[nContLinha], {"LINPOS", cCpoItem, aAutoItens[nContLinha, nPosItem, 2]})
		EndIf
	Next nContLinha

Return

/*
	Apresenta a Mensagem no Console do Protheus
*/
Static Function showLogInConsole(cMsg)
	
	libOzminerals.u_showLogInConsole(cMsg,cSintaxeRotina)
	
Return
