#include "totvs.ch"
#include "topconn.ch"
#include "fwmvcdef.ch"
#include "tryexception.ch"
#include "fweditpanel.ch"
#include "ozminerals.ch"

#DEFINE ROTINA_FILE				"OZ04M05.prw"
#DEFINE VERSAO_ROTINA			"V" + Trim(AllToChar(GetAPOInfo(ROTINA_FILE)[04])) + "-" + Trim(AllToChar(GetAPOInfo(ROTINA_FILE)[05])) + "[" + Trim(AllToChar(GetAPOInfo(ROTINA_FILE)[03])) + "]"

#DEFINE ALIAS_FORM0 			"PAX"
#DEFINE ALIAS_GRID0 			"PAY"
#DEFINE MODELO					"OZ04M05"
#DEFINE ID_MODEL				"MZ04M05"
#DEFINE TITULO_MODEL			"Gestão de Custeio Automatico - OZMinerals " 
#DEFINE TITULO_VIEW				TITULO_MODEL
#DEFINE ID_MODEL_FORM0			ALIAS_FORM0+"FORM0"
#DEFINE ID_MODEL_GRID0			ALIAS_GRID0+"GRID0"
#DEFINE ID_VIEW_FORM0			"VIEW_FORM0"
#DEFINE ID_VIEW_GRID0			"VIEW_GRID0"
#DEFINE PREFIXO_ALIAS_FORM0		Right(ALIAS_FORM0,03)
#DEFINE PREFIXO_ALIAS_GRID0		Right(ALIAS_GRID0,03)

#DEFINE  AGUARDANDO             "1"
#DEFINE  GERADO_SUCESSO         "2"
#DEFINE  NAO_APLICAVEL          "3"

#DEFINE STATUS_NAO_INTEGRADO	"1"
#DEFINE STATUS_INTEGRADO    	"2"

#DEFINE  PRODUCAO               "1"
#DEFINE  TRANSFERENCIA          "2"
#DEFINE  BAIXA_REQUISICAO       "3"
#DEFINE  VENDA_CPV              "4"

/*/{Protheus.doc} OZ04M05 - Gestão Automatica de Producação 

	Função responsável que contem as regras para executar abertura de ordem de produção, 
	Apontamento de produção, Transferencias, Baixa de Requisição e venda para o CPV.

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
User Function OZ04M05(aAutoCab,aAutoItens,nOperacao)
	Local oFwMBrowse		:= Nil
	Local cAliasForm		:= ALIAS_FORM0
	Local cModelo			:= MODELO
	Local cTitulo			:= TITULO_VIEW
	Local bKeyCTRL_X		:= {|| }
	Local bFecharEdicao		:= {|| ( oView := FwViewActive(), Iif( Type("oView") == "O" , oView:ButtonCancelAction() , .F. ) ) }	

	Private cSintaxeRotina  := ""  as character

	cSintaxeRotina          := ProcName(0)

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
			
			oFwMBrowse:AddLegend( cAliasForm + "_STATUS == '" + AGUARDANDO     + "'" , "RED"	, "Aguardando Executar Movimentação" )
			oFwMBrowse:AddLegend( cAliasForm + "_STATUS == '" + GERADO_SUCESSO + "'" , "GREEN"	, "Movimentação Realizada Com Sucesso" )
		
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
	Local bLinePre				:= {|oModelGrid,  nLine,  cAction, cField| LinePreValid(oModelGrid,  nLine,  cAction, cField)}
	
	Local cPrefForm				:= PREFIXO_ALIAS_FORM0
	Local cPrefGrid				:= PREFIXO_ALIAS_GRID0
	Local cCpoFFilial			:= cPrefForm+"_FILIAL"
	Local cCpoFDocumento    	:= cPrefForm+"_DOC"
	Local cCpoGFilial			:= cPrefGrid+"_FILIAL"
	Local cCpoGDocumento	    := cPrefGrid+"_DOC"
	Local cCpoGCodProduto		:= cPrefGrid+"_COD"
	Local cCpoGFilOrigem   		:= cPrefGrid+"_FILMOV"
	Local cCpoGLocal    		:= cPrefGrid+"_LOCAL"
	Local cCpoGTpMov    		:= cPrefGrid+"_TPMOV"

	oStructForm		:= FWFormStruct( 1, cAliasForm )
	oStructGrid 	:= FWFormStruct( 1, cAliasGrid )

	oModel	:= MPFormModel():New(cIdModel,bpreValidacao,bposValidacao,bCommit,bCancel)
	
	oModel:AddFields( cIDModelForm, /*cOwner*/, oStructForm,/*bpreValidacao*/,/*bposValidacao*/,/*bCarga*/)
	
	oStructGrid:AddField( 	;
	AllTrim('') 	      , ;  // [01] C Titulo do campo
	AllTrim('') 		  , ;  // [02] C ToolTip do campo
	'PAY_LEGEND'		  , ;  // [03] C identificador (ID) do Field
	'C' 				  , ;  // [04] C Tipo do campo
	50 					  , ;  // [05] N Tamanho do campo
	0 					  , ;  // [06] N Decimal do campo
	NIL 				  , ;  // [07] B Code-block de validação do campo
	NIL					  , ;  // [08] B Code-block de validação When do campo
	NIL 				  , ;  // [09] A Lista de valores permitido do campo
	NIL 				  , ;  // [10] L Indica se o campo tem preenchimento obrigatório
	{ || LegendaIntes() } , ;  // [11] B Code-block de inicializacao do campo
	NIL 				  , ;  // [12] L Indica se trata de um campo chave
	NIL 				  , ;  // [13] L Indica se o campo pode receber valor em uma operação de update.
	.T. )                      // [14] L Indica se o campo é virtual

	oModel:AddGrid(cIDModelGrid,cIDModelForm,oStructGrid,bLinePre,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,/*bLoad*/)
	oModel:GetModel(cIDModelGrid):SetUniqueLine( { cCpoGCodProduto, cCpoGFilOrigem, cCpoGLocal, cCpoGTpMov } )
	oModel:SetRelation(cIDModelGrid,{{cCpoGFilial,'xFilial("'+cAliasForm+'")'},{cCpoGDocumento,cCpoFDocumento}},(cAliasGrid)->(IndexKey(1)))	
	
	oModel:SetPrimaryKey( { cCpoFFilial, cCpoFDocumento } )
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
	Local cCpoGDocumento		:= cPrefGrid+"_DOC"
	Local cCpoGItemProduto		:= cPrefGrid+"_ITEM"
	Local cCposToHide			:= cCpoGDocumento+"|"

	oModel 			:= FWLoadModel( cModelo )
	
	oStructForm		:= FWFormStruct( 2, cAliasForm )
	oStructGrid	 	:= FWFormStruct( 2, cAliasGrid , {|cCampo| !( AllTrim(cCampo)+"|" $ cCposToHide) })	

	oStructGrid:AddField( ;                  // Ord. Tipo Desc.
	'PAY_LEGEND'                     , ;     // [01] C   Nome do Campo
	"00"                             , ;     // [02] C   Ordem
	AllTrim( ''    )		         , ;     // [03] C   Titulo do campo
	AllTrim( '' )       			 , ;     // [04] C   Descricao do campo
	{ 'Legenda' }           		 , ;     // [05] A   Array com Help
	'C'                              , ;     // [06] C   Tipo do campo
	'@BMP'               			 , ;     // [07] C   Picture
	NIL                              , ;     // [08] B   Bloco de Picture Var
	''                               , ;     // [09] C   Consulta F3
	.F.                              , ;     // [10] L   Indica se o campo é alteravel
	NIL                              , ;     // [11] C   Pasta do campo
	NIL                              , ;     // [12] C   Agrupamento do campo
	NIL                              , ;     // [13] A   Lista de valores permitido do campo (Combo)
	NIL                              , ;     // [14] N   Tamanho maximo da maior opção do combo
	NIL                              , ;     // [15] C   Inicializador de Browse
	.T.                              , ;     // [16] L   Indica se o campo é virtual
	NIL                              , ;     // [17] C   Picture Variavel
	NIL                             )        // [18] L   Indica pulo de linha após o campo

	oStructGrid:RemoveField(cCpoGDocumento)

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
	
	oView:AddUserButton("Pre Carga"	,"",{|| PerguntaParametro(oModel)},"Pre Cadastro",,,.T.)

	oView:EnableTitleView(cIDViewForm, "Dados da Movimentação")
	oView:EnableTitleView(cIDViewGrid, "Lista de Itens da Movimentação")
	
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
	Local aRotina 		:= {} as Array
	
	ADD OPTION aRotina TITLE "Visualizar"	          ACTION "u_Z04M5Manutencao(" + cValToChar(MODEL_OPERATION_VIEW) + ")" 	  OPERATION 2   ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"		          ACTION "u_Z04M5Manutencao(" + cValToChar(MODEL_OPERATION_INSERT) + ")"  OPERATION 3   ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"		          ACTION "u_Z04M5Manutencao(" + cValToChar(MODEL_OPERATION_UPDATE) + ")"  OPERATION 4   ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"		          ACTION "u_Z04M5Manutencao(" + cValToChar(MODEL_OPERATION_DELETE) + ")"  OPERATION 5   ACCESS 0
	ADD OPTION aRotina TITLE "Copiar"		          ACTION "u_Z04M5Manutencao(" + cValToChar(MODEL_OPERATION_COPY) + ")" 	  OPERATION 9   ACCESS 0	
	ADD OPTION aRotina TITLE "Cria Ordem Produção"    ACTION "estoque.Producao.Custeio.u_CriaOrdemProducao(PAX->PAX_DOC,PAX->PAX_STATUS,PAX->PAX_CRIAOP)"       OPERATION 10  ACCESS 0
	ADD OPTION aRotina TITLE "Aponta Ordem Produção"  ACTION "estoque.Producao.Custeio.u_ApontaOrdemProducao(PAX->PAX_DOC,PAX->PAX_STATUS,PAX->PAX_APTOOP)"     OPERATION 10  ACCESS 0
	ADD OPTION aRotina TITLE "Transferencia Armazens" ACTION "estoque.Producao.Custeio.u_GeraTransferenciaEntreArmazens(PAX->PAX_DOC,PAX->PAX_STATUS,PAX->PAX_TRANSF)" OPERATION 10  ACCESS 0
	ADD OPTION aRotina TITLE "Requisição de Baixa "   ACTION "estoque.Producao.Custeio.u_GeraRequisicaoInterna(PAX->PAX_DOC,PAX->PAX_STATUS,PAX->PAX_REQUIS)"   OPERATION 10  ACCESS 0
	ADD OPTION aRotina TITLE "Gera Pedido de Vendas"  ACTION "estoque.Producao.Custeio.u_GeraPedidoVendaPorto(PAX->PAX_DOC,PAX->PAX_STATUS,PAX->PAX_PVENDA)"    OPERATION 10  ACCESS 0
	ADD OPTION aRotina TITLE "Gera Documento CPV"     ACTION "estoque.Producao.Custeio.u_GeraDocumentoVendaPorto(PAX->PAX_DOC,PAX->PAX_STATUS,PAX->PAX_GERNF)" OPERATION 10  ACCESS 0

Return aRotina

/*
	Rotina para Manutenção do Registro
*/
User Function Z04M5Manutencao(nOperation)
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
	Local cAliasForm	:= ALIAS_FORM0
	Local nOperation	:= oModel:GetOperation()		
	Local cIDModelForm	:= ID_MODEL_FORM0	
	Local oModelForm	:= oModel:GetModel(cIDModelForm)	
	Local cPrefForm		:= PREFIXO_ALIAS_FORM0
	Local cCpoDtAlt		:= cPrefForm+"_DATA"
	Local cCpoHoraAlt	:= cPrefForm+"_HORA"
	Local cCpoUsrAlt	:= cPrefForm+"_USER"	
	Local cCpoFDoc 	    := cPrefForm+"_DOC"
	Local cFilForm	     := xFilial(cAliasForm)
	Local cDocumento 	 := oModel:GetValue(cIDModelForm,cCpoFDoc )
	Local lRet			:= .T.

	If ( nOperation == MODEL_OPERATION_INSERT ) .Or. ( nOperation == MODEL_OPERATION_UPDATE )
		oModelForm:LoadValue(cCpoDtAlt,DDATABASE)
		oModelForm:LoadValue(cCpoHoraAlt,Time())
		oModelForm:LoadValue(cCpoUsrAlt,cUserName)
	EndIf

 	If ( nOperation == MODEL_OPERATION_DELETE )	
		Begin Sequence
			dbSelectArea(cAliasForm)
			(cAliasForm)->(dbSetOrder(1))
			If (cAliasForm)->(dbSeek(cFilForm+cDocumento))

				lRet := VerificaStatus(cDocumento)

				If ( lRet ) 
					cMsg := "Atenção! O Documento informado '" + AllTrim(cDocumento) + "' Encontra-se com Integração, não será possivel Excluir para esta filial."
					lRet := .F.
					Break
				Else 
					lRet := .T.
				EndIf
			EndIf
		End Sequence
	EndIf

	If !( lRet )
		addLogs(cMsg)
	EndIf

Return lRet

/*
	Função para Validar os Dados Antes da Confirmação da Linha da Grid
*/
Static Function LinePreValid(oModelGrid, nLinha, cAcao, cCampo)
	Local oModel		:= oModelGrid:GetModel()
	Local cPrefGrid		:= PREFIXO_ALIAS_GRID0
	Local cCpoAStatus 	:= cPrefGrid+"_STATUS"
	Local nOperation	:= oModel:GetOperation()
	Local cStatus		:= ""  as character 
	Local lRet			:= .T. as logical 
	Local aArea			:= {}  as array

	aArea			    := getArea()		
	
	If ( nOperation == MODEL_OPERATION_UPDATE )	

		If ( cAcao == "SETVALUE")  
			If ( !oModelGrid:IsDeleted() )
				oModelGrid:GoLine(nLinha)
				cStatus     := oModelGrid:GetValue(cCpoAStatus)
				If (cStatus $ GERADO_SUCESSO)
					lRet :=  .F.
					Help(,,"LinepreValid",,"Atenção! Registro gerado com sucesso, não é permitido alteração!",1,0)
					EndIf
				EndIf
			EndIf
		EndIf
	
	RestArea(aArea)		

Return lRet

/*
	Função para Validar os Dados Após Confirmação da Tela de Cadastro - Verifica se pode incluir
*/
Static Function posValid(oModel)
	Local cAliasForm			:= ALIAS_FORM0
	Local cIDModelForm			:= ID_MODEL_FORM0
	Local cIDModelGrid			:= ID_MODEL_GRID0
	Local nOperation			:= oModel:GetOperation()
	Local oModelGrid			:= oModel:GetModel(cIDModelGrid)
	Local oModelForm	        := oModel:GetModel(cIDModelForm)	
	Local cPrefForm				:= PREFIXO_ALIAS_FORM0
	Local cPrefGrid				:= PREFIXO_ALIAS_GRID0
	Local cCpoFDoc 			    := cPrefForm+"_DOC"
	Local cCpoAStatus 	        := cPrefForm+"_STATUS"
	Local cCpoCriaOp 	        := cPrefForm+"_CRIAOP"
	Local cCpoAptoOp 	        := cPrefForm+"_APTOOP"
	Local cCpoRequis 	        := cPrefForm+"_REQUIS"
	Local cCpoTransf 	        := cPrefForm+"_TRANSF"
	Local cCpoPVEnda 	        := cPrefForm+"_PVENDA"
	Local cCpoGerNf 	        := cPrefForm+"_GERNF"
	Local cCpoCodProduto		:= cPrefGrid+"_COD"
	Local nCpoQuantidade        := cPrefGrid+"_QTD"
	Local cCpoGTpMov            := cPrefGrid+"_TPMOV"
	Local cFilForm				:= xFilial(cAliasForm)
	Local cDocumento 		    := oModel:GetValue(cIDModelForm,cCpoFDoc )
	Local cStatus  		        := oModel:GetValue(cIDModelForm,cCpoAStatus )
	Local aSaveLines			:= {}  as array 
	Local nRecord				:= 0   as integer
	Local nRecnoPAY				:= 0   as integer
	Local nQuantidade           := 0   as integer
	Local cCodProduto			:= ""  as character
	Local cCriaOrdem            := ""  as character
	Local cAptoOrdem            := ""  as character
	Local cTransfer             := ""  as character 
	Local cRequisicao           := ""  as character 
	Local cPedidoVenda          := ""  as character 
	Local cGeraNotaFiscal       := ""  as character 
	Local cMsg					:= ""  as character	
	Local lFail 				:= .F. as logical
	Local lCopia				:= .F. as logical
	Local lRet					:= .T. as logical
	
 	If ( nOperation == MODEL_OPERATION_INSERT )	
		Begin Sequence
			dbSelectArea(cAliasForm)
			(cAliasForm)->(dbSetOrder(1))
			If (cAliasForm)->(dbSeek(cFilForm+cDocumento))
				cMsg := "Atenção! O Documento informado '" + AllTrim(cDocumento) + "' não pode ser utilizada pois já existe na base de dados para esta filial."
				lRet := .F.
				Break
			Else 
				lRet := .T.
			EndIf
		End Sequence
	EndIf

 	If ( nOperation == MODEL_OPERATION_DELETE )	
		Begin Sequence
			dbSelectArea(cAliasForm)
			(cAliasForm)->(dbSetOrder(1))
			If (cAliasForm)->(dbSeek(cFilForm+cDocumento))
				lRet := VerificaStatus(cDocumento)
				If ( lRet ) 
					cMsg := "Atenção! O Documento '" + AllTrim(cDocumento) + "' informado Encontra-se com Integração finalizada, não será possivel Excluir para esta filial."
					lRet := .F.
					Break
				Else 
					lRet := .T.
				EndIf
			EndIf	
		End Sequence
	EndIf

 	If ( nOperation == MODEL_OPERATION_UPDATE )	
		Begin Sequence
			dbSelectArea(cAliasForm)
			(cAliasForm)->(dbSetOrder(1))
			If (cAliasForm)->(dbSeek(cFilForm+cDocumento))
				If ( cStatus $ STATUS_INTEGRADO) 
					cMsg := "Atenção! O Documento informado '" + AllTrim(cDocumento) + "' Encontra-se Integrado, não será possivel fazer alteração!"
					cMsg += "Caso necessite fazer a alteração, será necessario estornar todos os processos e refazer novamente!"
					Break
					lRet := .F.
				Else 
					lRet := .T.
				EndIf
			EndIf
		End Sequence
	EndIf

	If ( Type("COPIA") == "L" )
		lCopia := COPIA
	Else
		lCopia := .F.
	EndIf	
			
	If ( nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE .Or. lCopia )	
		
		Begin Sequence
		
			lRet := .F.
		
			If ( nOperation == MODEL_OPERATION_UPDATE )
				nRecnoPAY := PAY->(Recno())
			EndIf
					
			aSaveLines := FWSaveRows()			
			For nRecord:=1 To oModelGrid:Length()
				oModelGrid:GoLine(nRecord)
				If !( oModelGrid:IsDeleted() )
					
					nQuantidade    := oModelGrid:GetValue(nCpoQuantidade)
					cCodProduto	   := oModelGrid:GetValue(cCpoCodProduto)
					cTipoMovimento := oModelGrid:GetValue(cCpoGTpMov)  // 1=Produção;2=Transferencia;3=Baixa Requisicao;4=Venda CPV

					If (cTipoMovimento $ PRODUCAO) 
						cCriaOrdem := oModel:GetValue(cIDModelForm,cCpoCriaOp )
						If (cCriaOrdem $ AGUARDANDO .Or. cCriaOrdem $ GERADO_SUCESSO )
							oModelForm:LoadValue(cCpoCriaOp,cCriaOrdem)
						Else 
							oModelForm:LoadValue(cCpoCriaOp,AGUARDANDO)
						EndIf  

						cAptoOrdem := oModel:GetValue(cIDModelForm,cCpoAptoOp )
						If (cAptoOrdem $ AGUARDANDO .Or. cAptoOrdem $ GERADO_SUCESSO )
							oModelForm:LoadValue(cCpoAptoOp,cAptoOrdem)
						Else 
							oModelForm:LoadValue(cCpoAptoOp,AGUARDANDO)
						EndIf  
					EndIf 

					If (cTipoMovimento $ TRANSFERENCIA) 			
						cTransfer := oModel:GetValue(cIDModelForm,cCpoTransf )
						If (cTransfer $ AGUARDANDO .Or. cTransfer $ GERADO_SUCESSO )
							oModelForm:LoadValue(cCpoTransf,cTransfer)
						Else 
							oModelForm:LoadValue(cCpoTransf,AGUARDANDO)
						EndIf  
					EndIf 

					If (cTipoMovimento $ BAIXA_REQUISICAO) 			
						cRequisicao := oModel:GetValue(cIDModelForm,cCpoRequis )
						If (cRequisicao $ AGUARDANDO .Or. cRequisicao $ GERADO_SUCESSO )
							oModelForm:LoadValue(cCpoRequis,cRequisicao)
						Else 
							oModelForm:LoadValue(cCpoRequis,AGUARDANDO)
						EndIf  
					EndIf

					If (cTipoMovimento $ VENDA_CPV) 			
						cPedidoVenda := oModel:GetValue(cIDModelForm,cCpoPVEnda )
						If (cPedidoVenda $ AGUARDANDO .Or. cPedidoVenda $ GERADO_SUCESSO )
							oModelForm:LoadValue(cCpoPVEnda,cPedidoVenda)
						Else 
							oModelForm:LoadValue(cCpoPVEnda,AGUARDANDO)
						EndIf  

						cGeraNotaFiscal := oModel:GetValue(cIDModelForm,cCpoGerNf)
						If (cGeraNotaFiscal $ AGUARDANDO .Or. cGeraNotaFiscal $ GERADO_SUCESSO )
							oModelForm:LoadValue(cCpoGerNf,cPedidoVenda)
						Else 
							oModelForm:LoadValue(cCpoGerNf,AGUARDANDO)
						EndIf  
					EndIf
					
					If ( nQuantidade <= 0 )
						cMsg := "Atenção! Informar a Quantidade do Produto '" + AllTrim(cCodProduto) + "'"
						lFail := .T.
						Exit
					EndIf
				EndIf
			Next nRecord
			FWRestRows( aSaveLines )
			
			If ( lFail )
				lRet := .F.
				Break
			EndIf
			
			lRet := .T.
			
		End Sequence
	EndIf
	
	If !( lRet )
		addLogs(cMsg)
	EndIf

Return lRet

/*
	Função de Validação executada na Ativação do Modelo
*/
Static Function activeForm(oModel)
	Local lRet				:= .T.

Return lRet

/*
 	Retorna o codigo de Operação 
*/
Static Function RetornaCodigoTabela(cPesqTabela,oModel)
	Local aArea           := {}  as array
	Local aPreCadastro    := {}  as array
	Local cAlias	      := ""  as character
	Local cQuery	      := ""  as character

	aArea      	          := Lj7GetArea({"PA1", "PA0", "PAY", "PAX"})

	If ( !Empty(cAlias) )
		dbSelectArea(cAlias)
		(cAlias)->(dbCloseArea())
	EndIf

	cQuery               := GetQryPreCadastro(cPesqTabela)
	cAlias               := MpSysOpenQuery(cQuery)

	If ( !Empty(cAlias) )

		DbSelectArea(cAlias)

		If ( (cAlias)->(!EOF()) )

			While (cAlias)->(!EOF())

				dbSelectArea("PA1")
				PA1->(dbSetOrder(1))
				If ( PA1->(dbSeek(xFilial("PA1") + (cAlias)->PA0_TAB )) )

					aAdd(aPreCadastro, { (cAlias)->PA0_TAB,; 
									     (cAlias)->PA1_ITEM,;  
										 (cAlias)->PA1_COD,;   
										 (cAlias)->PA1_DESC,;  
										 (cAlias)->PA1_TIPO,; 
										 (cAlias)->PA1_TMMOV,; 
										 (cAlias)->PA1_TMORIG,;
										 (cAlias)->PA1_TES,;   
										 (cAlias)->PA1_FILDES,;
										 (cAlias)->PA1_LOCDES}) 

				EndIf

				(cAlias)->(dbSkip())
			Enddo

			(cAlias)->(DbCloseArea())
		EndIf
	EndIf

	If len(aPreCadastro) > 0
		processaDados(aPreCadastro,oModel)
	EndIf 

	Lj7RestArea(aArea)

Return 

/*
    Carrega perguntas da rotina PARAMBOX
*/
Static Function PerguntaParametro(oModel) 
	Local   lRet         := .F. as logical
	Local   aPergunta    := {}  as array
	Local   aRetorno     := {}  as array
	Local   cPreCadastro := ""  as Character
	Local   cMsg	 	 := ""  as Character
	Local   nOperation	 := oModel:GetOperation()

	cPreCadastro  		:= Space(TamSx3("PA0_TAB")[1])

	aAdd( aPergunta , { 1, "Tabela Pre Cadstro " , cPreCadastro  , PesqPict("PA0","PA0_TAB")     , ".T.", "PA0" , ".T.", 50    , .F. } )

	If ( ParamBox(aPergunta ,"Parametros ",aRetorno, /*4*/, /*5*/, /*6*/, /*7*/, /*8*/, /*9*/, /*10*/, .F.))

		Mv_Par01 := aRetorno[01]

		lRet := .T.

		If ( nOperation == MODEL_OPERATION_INSERT )	
			If lRet
				FWMsgRun(,{ || RetornaCodigoTabela(Mv_Par01,oModel) } ,"Processando dados...","Aguarde")
			Endif
		Else 
			cMsg := "Atenção! Somente é permitido para Inclusão de Registro!"
			addLogs(cMsg)
			lRet := .F.
		EndIf
	EndIf

Return lRet

/*
	Processa os dados retornado da query e abastece a grid
*/
Static Function processaDados(aPreCadastro,oModel)
	Local nLinha			:= 0   as integer 
	Local lPermiteExecutar  := .T. as logical
	Local cIDModelGrid		:= ID_MODEL_GRID0
	Local oModelGrid		:= oModel:GetModel(cIDModelGrid)
	Local nOperation        := oModel:GetOperation()
	Local cUnidadeMedida    := "" as character

	If ( nOperation == MODEL_OPERATION_INSERT )

		If ( lPermiteExecutar )
			If ( ValType(oModelGrid) == "O" )
				If ( len(aPreCadastro) > 0 )
					For nLinha:=1 to len(aPreCadastro)

						cUnidadeMedida := Posicione("SB1",1,XFilial("SB1") + aPreCadastro[nLinha][03],"B1_UM") 

						If (oModelGrid:AddLine(.T.)==nLinha)
							oModelGrid:GoLine(nLinha)
							oModelGrid:SetValue("PAY_ITEM "     ,aPreCadastro[nLinha][02]) 
							oModelGrid:SetValue("PAY_COD"       ,aPreCadastro[nLinha][03])    
							oModelGrid:SetValue("PAY_DESC"      ,aPreCadastro[nLinha][04])   
							oModelGrid:SetValue("PAY_TIPO"      ,aPreCadastro[nLinha][05])   
							oModelGrid:SetValue("PAY_TPMOV"     ,aPreCadastro[nLinha][06])  
							oModelGrid:SetValue("PAY_UM"        ,cUnidadeMedida          )     
							oModelGrid:SetValue("PAY_TM"        ,aPreCadastro[nLinha][07])     
							oModelGrid:SetValue("PAY_TES"       ,aPreCadastro[nLinha][08])    
							oModelGrid:SetValue("PAY_FILMOV"    ,aPreCadastro[nLinha][09]) 
							oModelGrid:SetValue("PAY_LOCAL"     ,aPreCadastro[nLinha][10])  
						Endif
					Next nLinha
				EndIf
			EndIf
		EndIf
	EndIf
	oModelGrid:GoLine(1)
	oView := FwViewActive()

Return

/*
    retorna o codigo da movimentação da ordem de produção  
*/
Static Function GetQryPreCadastro(cPesqTabela)
	Local cQuery           := "" as character

	cQuery := "SELECT " + CRLF
	cQuery += "        PA0_TAB    AS PA0_TAB,    " + CRLF
	cQuery += "        PA1_ITEM   AS PA1_ITEM,   " + CRLF
	cQuery += "        PA1_COD    AS PA1_COD,    " + CRLF
	cQuery += "        PA1_DESC   AS PA1_DESC,   " + CRLF 
	cQuery += "        PA1_TIPO   AS PA1_TIPO,   " + CRLF
	cQuery += "        PA1_TMMOV  AS PA1_TMMOV,  " + CRLF 
	cQuery += "        PA1_TMORIG AS PA1_TMORIG, " + CRLF
	cQuery += "        PA1_TES    AS PA1_TES,    " + CRLF
	cQuery += "        PA1_FILDES AS PA1_FILDES, " + CRLF
	cQuery += "        PA1_LOCDES AS PA1_LOCDES  " + CRLF
	cQuery += "FROM  " + RetSqlTab("PA1") + CRLF
	cQuery += " 	   INNER JOIN " + CRLF
	cQuery += " 	              " + RetSQLTab("PA0") +  CRLF
	cQuery += " 	              ON 1=1 " + CRLF
	cQuery += "                   AND PA1_FILIAL     = PA0_FILIAL " + CRLF
	cQuery += "                   AND PA1_TAB        = PA0_TAB    " + CRLF
	cQuery += "                   AND " + RetSqlDel("PA0") + CRLF
	cQuery += "WHERE   1=1 " + CRLF
	cQuery += "        AND PA1_TAB = " + ValToSql(cPesqTabela) + " " + CRLF
	cQuery += "        AND " + RetSqlDel("PA1")  + CRLF
	cQuery += "ORDER BY  PA1_ITEM  "  + CRLF

	u_ChangeQuery("\sql\OZ04M05_GetQryPreCadastro.sql",@cQuery)

Return cQuery

/*
 	Verificar Status para Poder Cancelar Documento 
*/
Static Function VerificaStatus(cDocumento)
	Local aArea                 := {}  as array
	Local lRetorno              := .T. as logcical
	Local cAlias	            := ""  as character
	Local cQuery	            := ""  as character
	Local cLog                  := ""  as character

	aArea       	            := GetArea()
	
	If ( !Empty(cAlias) )
		dbSelectArea(cAlias)
		(cAlias)->(dbCloseArea())
	EndIf

	cQuery               := getQryVerificaStatus(cDocumento)
	cAlias               := MpSysOpenQuery(cQuery)

	If ( !Empty(cAlias) )

		dbSelectArea(cAlias)

		If ( (cAlias)->(!EOF()) )

			While ((cAlias)->(!EOF()))

				lRetorno := .F.

				If ( AllTrim((cAlias)->PAY_DOC) $ AllTrim(cDocumento) )

					If ( (cAlias)->PAY_STATUS $ GERADO_SUCESSO ) 

						lRetorno := .T.
						Exit
					EndIf
				EndIf 

				(cAlias)->(dbSkip())
			EndDo
		EndIf 

		(cAlias)->(dbCloseArea())
	Else

		cLog += " - Filial: " + cFilAnt + " - Não Localizada"
	EndIf

	If ( !Empty(cLog) )
		showLogInConsole(StrTran(cLog,CRLF,", ") )
	Endif

	RestArea( aArea )

Return lRetorno 

/*
	Monta a Query para carregar dados - Busca na PAY
*/
Static Function getQryVerificaStatus(cDocumento)
	Local cQuery 	    := ""  as character

	cQuery := " SELECT " + CRLF
	cQuery += "		   PAY_FILIAL AS PAY_FILIAL, " + CRLF
	cQuery += "		   PAY_DOC    AS PAY_DOC,    " + CRLF
	cQuery += "		   PAY_ITEM   AS PAY_ITEM,   " + CRLF 
	cQuery += "		   PAY_COD    AS PAY_COD,    " + CRLF
	cQuery += "		   PAY_DESC   AS PAY_DESC,   " + CRLF
	cQuery += "		   PAY_TIPO   AS PAY_TIPO,   " + CRLF 
	cQuery += "		   PAY_UM     AS PAY_UM,     " + CRLF
	cQuery += "		   PAY_TM     AS PAY_TM,     " + CRLF
	cQuery += "		   PAY_TES    AS PAY_TES,    " + CRLF
	cQuery += "		   PAY_TPMOV  AS PAY_TPMOV,  " + CRLF
	cQuery += "		   PAY_FILMOV AS PAY_FILMOV, " + CRLF 
	cQuery += "		   PAY_LOCAL  AS PAY_LOCAL,  " + CRLF
	cQuery += "		   PAY_QTD    AS PAY_QTD,    " + CRLF
	cQuery += "		   PAY_COMP   AS PAY_COMP,   " + CRLF
	cQuery += "		   PAY_DSCEMP AS PAY_DSCEMP, " + CRLF
	cQuery += "		   PAY_QTDEMP AS PAY_QTDEMP, " + CRLF
	cQuery += "		   PAY_STATUS AS PAY_STATUS, " + CRLF
	cQuery += "		   PAY_AVANCO AS PAY_AVANCO, " + CRLF
	cQuery += "		   PAY_OP     AS PAY_OP,     " + CRLF
	cQuery += "		   PAX_DATA   AS PAX_DATA,   " + CRLF
	cQuery += "		   PAX_HORA   AS PAX_HORA,   " + CRLF
	cQuery += "		   PAX_USER   AS PAX_USER    " + CRLF 
	cQuery += " FROM   " + CRLF
	cQuery += " 	   " + RetSQLTab("PAY") + CRLF
	cQuery += " 	   INNER JOIN " + CRLF
	cQuery += " 	              "+ RetSQLTab("SB1") +  CRLF
	cQuery += " 	              ON 1=1 " + CRLF
	cQuery += " 				  AND PAY_COD  = B1_COD    " + CRLF
	cQuery += "     			  AND " + RetSqlDel("SB1")   + CRLF
	cQuery += " 	   INNER JOIN " + CRLF
	cQuery += " 	              "+ RetSQLTab("PAX") +  CRLF
	cQuery += " 	              ON 1=1 " + CRLF
	cQuery += " 				  AND PAY_FILIAL  = PAX_FILIAL " + CRLF
	cQuery += " 				  AND PAY_DOC     = PAX_DOC    " + CRLF
	cQuery += "     			  AND " + RetSqlDel("PAX") + CRLF
	cQuery += " WHERE  1 = 1 " + CRLF
	cQuery += "   	   AND PAY_FILIAL = " + ValToSql(XFilial("PAY")) + "  " + CRLF
	cQuery += "   	   AND PAY_DOC    = " + ValToSql(cDocumento)     + "  " + CRLF
	cQuery += "   	   AND " + RetSqlDel("PAY") + CRLF
	cQuery += " ORDER BY PAY_ITEM " + CRLF

	u_ChangeQuery("\sql\OZ04M05_getQryVerificaStatus.sql", @cQuery)

Return cQuery

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
		If Type("oOZ04M05") == "O"
			oClassMVCAuto:setObjectModel(oOZ04M05)
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
	Tratamento da Legenda 
*/
Static function LegendaIntes(cStatus)
	Local cLegenda := ""

	Default cStatus := PAY->PAY_STATUS

	If ( cStatus == AGUARDANDO )
		cLegenda := "BR_AZUL"
	ElseIf ( cStatus == GERADO_SUCESSO )
		cLegenda := "BR_VERDE"
	EndIf

Return cLegenda

/*
	Atualiza a legenda do GRID após alteração.
*/
Static Function AtualizaLegendaGrid(cIDModel0Grid)
	Local oModel		:= FWModelActive()
	Local oView   		:= FwViewActive()
	Local oModelPAX		:= Nil
	Local cStatus		:= ""

	oModelPAX := oModel:GetModel(oModelPAX)

	aArea	:= GetArea()

	aLinhas := FWSaveRows()

	cStatus := oModel:GetValue(cIDModel0Grid,'PAY_STATUS')
	oModelPAX:SetValue(cIDModel0Grid, 'PAY_LEGEND' , LegendaIntes(cStatus))

	FWRestRows(aLinhas)

	oview:Refresh()

	RestArea(aArea)

Return

/*
	Apresenta a Mensagem no Console do Protheus
*/
Static Function showLogInConsole(cMsg)
	
	libOzminerals.u_showLogInConsole(cMsg,cSintaxeRotina)
	
Return
