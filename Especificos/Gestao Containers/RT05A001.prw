#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FILEIO.CH"
#DEFINE  MODEL_OPERATION_VIEW 2
#DEFINE  MODEL_OPERATION_INSERT 3
#DEFINE  MODEL_OPERATION_UPDATE 4
#DEFINE  MODEL_OPERATION_DELETE 5
#DEFINE  MODEL_OPERATION_COPY 9
#DEFINE  MODEL_OPERATION_IMPR 8

/*/{Protheus.doc} RT05A001
Rotina em MVC para cadastro de Containers
@author 	Ricardo Tavares Ferreira
@since 		08/05/2018
@version 	12.1.17
@return 	oBrowse
@Obs 		Ricardo Tavares - Construcao Inicial
/*/
//==========================================================================================================
	User Function RT05A001()
//==========================================================================================================

	Local oBrowse 		:= Nil
	Local aCampos		:= Nil
	Local n				:= 0
	Private cCamposSZ8	:= ""	
	Private cTitulo		:= OemtoAnsi("Cadastro de Containers")
	
	DbSelectArea("SZ8")

	aCampos := SZ8->(DBSTRUCT())
	
	For n := 2 To Len(aCampos)
		cCamposSZ8 += aCampos[n][1]
		cCamposSZ8 += iif((n) < Len(aCampos),";","")
	Next
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("SZ8")
	oBrowse:AddLegend("Z8_STATUS == '1' ","BR_VERDE"		,"Ativo")
	oBrowse:AddLegend("Z8_STATUS == '2' ","BR_LARANJA"		,"Em Carregamento")
	oBrowse:AddLegend("Z8_STATUS == '3' ","BR_VERMELHO"		,"Inativo")
	oBrowse:AddLegend("Z8_STATUS == '4' ","BR_PRETO"		,"Container Carregado")
	oBrowse:SetDescription(cTitulo)
	oBrowse:SetMenuDef("RT05A001")
	oBrowse:Activate()
	
Return oBrowse

/*/{Protheus.doc} ModelDef
Funcao que cria o modelo de dados da rotina.
@author 	Ricardo Tavares Ferreira
@since 		14/03/2018
@version 	12.1.17
@return 	oModel
@Obs 		Ricardo Tavares - Construcao Inicial
/*/
//==========================================================================================================
	Static Function ModelDef()
//==========================================================================================================

	Local oModel	:= Nil
	Local oStrSZ8	:= Nil
	
	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New("RT5A1MOD",/*{|oModel| PreValida(oModel)}*/,/*{|oModel| PosValida(oModel)}*/,/*{|oModel| GravaDados( oModel )}*/) 
	
	// Cria o Objeto da Estrutura dos Campos da tabela
	oStrSZ8 := FWFormStruct(1,"SZ8",{|cCampo| ( Alltrim(cCampo) $ cCamposSZ8 )})
		
	// Funcao que executa o gatilho de preenchimento da descricao dos campos
	oStrSZ8:AddTrigger("Z8_DTSPORT","Z8_DTVCONT",{ || .T. },{|| oModel := FwModelActive(),DaySum(oModel:GetModel("M_SZ8"):GetValue("Z8_DTSPORT"),21)})
	//oStrSZL:AddTrigger("ZL_CLIENTE","ZL_LOJA"   ,{ || .T. },{|| oModel := FwModelActive(),Posicione("SA1",1,xFilial("SA1")+oModel:GetModel("M_SZL"):GetValue("ZL_CLIENTE"),"A1_LOJA")})
	//oStrSZL:AddTrigger("ZL_CLIENTE","ZL_NOMECLI",{ || .T. },{|| oModel := FwModelActive(),Posicione("SA1",1,xFilial("SA1")+oModel:GetModel("M_SZL"):GetValue("ZL_CLIENTE"),"A1_NOME")})
	//oStrSZL:AddTrigger("ZL_CLIENTE","ZL_MENNOTA",{ || .T. },{|| oModel := FwModelActive(),MSG_NF()})
	//oStrITM:AddTrigger("ZM_PRODUTO","ZM_DESCRI" ,{ || .T. },{|| oModel := FwModelActive(),Posicione("SB1",1,xFilial("SB1")+oModel:GetModel("M_ITM"):GetValue("ZM_PRODUTO"),"B1_DESC")})
		
	// Adiciona ao modelo um componente de formulario
	oModel:AddFields("M_SZ8",/*cOwner*/,oStrSZ8,/*Pre Valid*/,/*Pos Valid*/,/*Load Dados*/) 
	 
	 // Seta a chave primaria que sera utiliZLda na gravacao dos dados na tabela 
	oModel:SetPrimaryKey({"Z8_FILIAL","Z8_COD","Z8_TAG"})
	
	// Seta a descricao do modelo de dados no cabecalho
	oModel:GetModel("M_SZ8"):SetDescription(OemToAnsi("Cadastro de Containers"))
	
	//oModel:AddRules("M_PRD","ZM_OK"		,"M_SZL","ZL_CLIENTE",1)
	
	// Coloco uma regra para nao duplicar os itens contabeis na inclusao	
	//oModel:GetModel("M_ITM"):SetUniqueLine({"ZM_PRODUTO"})
	
	// Seto o Conteudo no campo para colocar o registro inicialmente como Ativo
	//oStrSZL:SetProperty("ZL_NUM"	,MODEL_FIELD_WHEN	,{|| .F.})
	oStrSZ8:SetProperty("Z8_STATUS"	,MODEL_FIELD_INIT	,{|| cValToChar(1)})
	//oStrSZL:SetProperty("ZL_CLIENTE",MODEL_FIELD_VALID	,{|| PreVLD(oModel,"M_SZL")})
	//oStrSZL:SetProperty("ZL_CLIENTE",MODEL_FIELD_WHEN	,{|| Iif(Inclui,.T.,.F.)})
	//oStrPSQ:SetProperty("ZL_PESQ"	,MODEL_FIELD_VALID	,{|| PreVLD(oModel,"M_PSQ")})
	//oStrPRD:SetProperty("ZM_OK"		,MODEL_FIELD_VALID	,{|| RT05A001A()})
		
Return oModel

/*/{Protheus.doc} ViewDef
Funcao que cria a tela de visualiZLcao do modelo de dados da rotina.
@author 	Ricardo Tavares Ferreira
@since 		14/03/2018
@version 	12.1.17
@return 	oView
@Obs 		Ricardo Tavares - Construcao Inicial
/*/
//==========================================================================================================
	Static Function ViewDef()
//==========================================================================================================

	Local oView			:= Nil
	Local oModel		:= FWLoadModel("RT05A001") // Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
	Local oStrSZ8		:= Nil 
																																				
	//Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
	oStrSZ8 := FWFormStruct(2,"SZ8",{|cCampo| ( Alltrim(cCampo) $ cCamposSZ8 )})
	
	// Cria o objeto de View
	oView := FWFormView():New()
	
	// Define qual o Modelo de dados sera utilizado na View
	oView:SetModel(oModel)	
	
	// Adiciona no nosso View um controle do tipo formulario
	oView:AddField("V_SZ8",oStrSZ8,"M_SZ8",/*{|oModel| PreValida(oModel)}*/,/*{|oView| PosValida(oView)}*/)
	
	// Cria um "box" horizontal para receber cada elemento da view Pai
	oView:CreateHorizontalBox("V_SUP",100)
 	
	// Relaciona o identificador (ID) da View com o "box" para exibicao Pai
	oView:SetOwnerView("V_SZ8","V_SUP")
	
	// Seta o Titulo no cabecalho do cadastro
	oView:EnableTitleView("V_SZ8",OemtoAnsi("Cadastro de Containers"))
	
Return oView

/*/{Protheus.doc} MenuDef
Funcao que cria o menu principal do Browse da rotina.
@author 	Ricardo Tavares Ferreira
@since 		14/03/2018
@version 	12.1.17
@return 	aRotina
@Obs 		Ricardo Tavares - Construcao Inicial
/*/
//==========================================================================================================
	Static Function MenuDef()
//==========================================================================================================
	
	Local aRotina	:= {}
	Local cCodGru	:= PswRet()[1][1]
	
	ADD OPTION aRotina Title "Visualizar"		ACTION "VIEWDEF.RT05A001" OPERATION MODEL_OPERATION_VIEW		ACCESS 0
	ADD OPTION aRotina Title "Incluir" 			ACTION "VIEWDEF.RT05A001" OPERATION MODEL_OPERATION_INSERT		ACCESS 0
	ADD OPTION aRotina Title "Alterar" 			ACTION "VIEWDEF.RT05A001" OPERATION MODEL_OPERATION_UPDATE		ACCESS 0
	
	If cCodGru == "000000" 
		ADD OPTION aRotina Title "Excluir" 		ACTION "VIEWDEF.RT05A001" OPERATION MODEL_OPERATION_DELETE 		ACCESS 0
	EndIf
	
	ADD OPTION aRotina Title "Imprimir" 		ACTION "VIEWDEF.RT05A001" OPERATION MODEL_OPERATION_IMPR		ACCESS 0
	ADD OPTION aRotina Title "Copiar" 			ACTION "VIEWDEF.RT05A001" OPERATION MODEL_OPERATION_COPY	 	ACCESS 0
	ADD OPTION aRotina Title "Inativar/Ativar"	ACTION "StaticCall(RT05A001,RT05A001A)" OPERATION 9			 	ACCESS 0

Return aRotina

/*/{Protheus.doc} RT05A001A
Funcao tipo botao para inativar o registro.
@author 	Ricardo Tavares Ferreira
@since 		13/08/2018
@version 	12.1.17
@return 	Nil
@Obs 		Ricardo Tavares - Construcao Inicial
/*/
//==========================================================================================================
	Static Function RT05A001A()
//==========================================================================================================
	
	Local cCod	:= SZ8->Z8_COD
	Local cTAG  := SZ8->Z8_TAG
		
	If DbSeek(xFilial("SZ8")+cCod+cTAG)
		
		RecLock("SZ8",.F.)
			If SZ8->Z8_STATUS == "1"
				SZ8->Z8_STATUS := "3"
			Else
				SZ8->Z8_STATUS := "1"
			EndIF
		MsUnlock()
		
	EndIf
Return
