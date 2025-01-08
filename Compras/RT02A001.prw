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

/*/{Protheus.doc} RT02A001
Rotina em MVC que realiza a inclusao e manutenção do cadastro de SC x Grupo de Aprovação 
@author 	Ricardo Tavares Ferreira
@since 		16/05/2018
@version 	12.1.17
@return 	oBrowse
@Obs 		Ricardo Tavares - Construcao Inicial
/*/
//==========================================================================================================
	User Function RT02A001()
//==========================================================================================================

	Local oBrowse 		:= Nil
	Local aCampos		:= Nil
	Local nX			:= 0
	Private cCamposCOJ	:= ""		
	Private cTitulo		:= OemtoAnsi("SC x Grupo de Aprovação ")
	
	DbSelectArea("COJ")
	
	aCampos := COJ->(DBSTRUCT())
	
	For nX := 2 To Len(aCampos)
		cCamposCOJ += aCampos[nX][1]
		cCamposCOJ += iif((nX) < Len(aCampos),";","")
	Next
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("COJ")
	oBrowse:SetDescription(cTitulo)
	oBrowse:SetMenuDef("RT02A001")
	oBrowse:Activate()
	
Return oBrowse

/*/{Protheus.doc} ModelDef
Funcao que cria o modelo de dados da rotina.
@author 	Ricardo Tavares Ferreira
@since 		16/05/2018
@version 	12.1.17
@return 	oModel
@Obs 		Ricardo Tavares - Construcao Inicial
/*/
//==========================================================================================================
	Static Function ModelDef()
//==========================================================================================================

	Local oModel	:= Nil
	Local oStrCOJ	:= Nil
	
	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New("SI0231MD",/*{|oModel| PreValida(oModel)}*/,/*{|oModel| PosValida(oModel)}*/,/*{|oModel| GravaDados( oModel )}*/) 
	
	// Cria o Objeto da Estrutura dos Campos da tabela
	oStrCOJ := FWFormStruct(1,"COJ",{|cCampo| ( Alltrim(cCampo) $ cCamposCOJ )})	
	
	// Adiciona ao modelo um componente de formulario
	oModel:AddFields("M_COJ",/*cOwner*/,oStrCOJ) 
	 
	 // Seta a chave primaria que sera utilizada na gravacao dos dados na tabela 
	oModel:SetPrimaryKey({"COJ_FILIAL","COJ_CUSTO","COJ_PREFIX","COJ_CODIGO"})
	
	// Seta a descricao do modelo de dados no cabecalho
	oModel:getModel("M_COJ"):SetDescription(OemToAnsi(cTitulo))
		
Return oModel

/*/{Protheus.doc} ViewDef
Funcao que cria a tela de visualizacao do modelo de dados da rotina.
@author 	Ricardo Tavares Ferreira
@since 		13/08/2018
@version 	12.1.17
@return 	oView
@Obs 		Ricardo Tavares - Construcao Inicial
/*/
//==========================================================================================================
	Static Function ViewDef()
//==========================================================================================================

	Local oView		:= Nil
	Local oModel	:= FWLoadModel("RT02A001") // Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
	Local oStrCOJ	:= Nil		
   
	//Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
	oStrCOJ := FWFormStruct(2,"COJ",{|cCampo| ( Alltrim(cCampo) $ cCamposCOJ )})
	
	// Cria o objeto de View
	oView := FWFormView():New()
	
	// Define qual o Modelo de dados sera utilizado na View
	oView:SetModel(oModel)	
	
	// Adiciona no nosso View um controle do tipo formulario
	oView:AddField("V_COJ",oStrCOJ,"M_COJ",/*{|oModel| PreValida(oModel)}*/,/*{|oView| PosValida(oView)}*/)
	
	// Cria um "box" horizontal para receber cada elemento da view Pai
	oView:CreateHorizontalBox("V_SUP",100)

	// Relaciona o identificador (ID) da View com o "box" para exibicao Pai
	oView:SetOwnerView("V_COJ","V_SUP")
	
	// Seta o Titulo no cabecalho do cadastro
	oView:EnableTitleView("V_COJ",OemtoAnsi(cTitulo))
	
Return oView

/*/{Protheus.doc} MenuDef
Funcao que cria o menu principal do Browse da rotina.
@author 	Ricardo Tavares Ferreira
@since 		13/08/2018
@version 	12.1.17
@return 	aRotina
@Obs 		Ricardo Tavares - Construcao Inicial
/*/
//==========================================================================================================
	Static Function MenuDef()
//==========================================================================================================
	
	Local aRotina	:= {}
	
	ADD OPTION aRotina Title "Visualizar"		ACTION "VIEWDEF.RT02A001" OPERATION MODEL_OPERATION_VIEW		ACCESS 0
	ADD OPTION aRotina Title "Incluir" 			ACTION "VIEWDEF.RT02A001" OPERATION MODEL_OPERATION_INSERT		ACCESS 0
	ADD OPTION aRotina Title "Alterar" 			ACTION "VIEWDEF.RT02A001" OPERATION MODEL_OPERATION_UPDATE		ACCESS 0
	ADD OPTION aRotina Title "Excluir" 			ACTION "VIEWDEF.RT02A001" OPERATION MODEL_OPERATION_DELETE 		ACCESS 0
	ADD OPTION aRotina Title "Imprimir" 		ACTION "VIEWDEF.RT02A001" OPERATION MODEL_OPERATION_IMPR		ACCESS 0
	ADD OPTION aRotina Title "Copiar" 			ACTION "VIEWDEF.RT02A001" OPERATION MODEL_OPERATION_COPY	 	ACCESS 0

Return aRotina    