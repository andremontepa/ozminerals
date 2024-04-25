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

/*/{Protheus.doc} API97A04
Cadastro de Serviços de API.
@type function 
@author Ricardo Tavares Ferreira
@return object, Objeto do Browse.
@since 06/04/2021
@history 06/04/2021, Ricardo Tavares Ferreira, Construção Inicial.
@version 12.1.27
/*/
//=============================================================================================================================
    User Function API97A04()
//=============================================================================================================================
  
	Local oBrowse 		:= Nil
	Local aCampos		:= Nil
	Local nX			:= 0
	Private cCamposZR6	:= ""		
	Private cTitulo		:= OemtoAnsi("Cadastro de Serviços de API")
	
	DbSelectArea("ZR6")
	
	aCampos := ZR6->(DbStruct())
	
	For nX := 2 To Len(aCampos)
		cCamposZR6 += aCampos[nX][1]
		cCamposZR6 += iif((nX) < Len(aCampos),";","")
	Next
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZR6")
	oBrowse:SetDescription(cTitulo)
	oBrowse:SetMenuDef("API97A04")
	oBrowse:Activate()
Return oBrowse

/*/{Protheus.doc} ModelDef
Funcao que cria o modelo de dados da rotina.
@type function 
@author Ricardo Tavares Ferreira
@return object, Objeto do Modelo.
@since 06/04/2021
@history 06/04/2021, Ricardo Tavares Ferreira, Construção Inicial.
@version 12.1.27
/*/
//==========================================================================================================
	Static Function ModelDef()
//==========================================================================================================

	Local oModel	:= Nil
	Local oStrZR6	:= Nil
	
	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New("ZR6MOD",/*{|oModel| PreValida(oModel)}*/,/*{|oModel| PosValida(oModel)}*/,/*{|oModel| GravaDados( oModel )}*/) 
	
	// Cria o Objeto da Estrutura dos Campos da tabela
	oStrZR6 := FWFormStruct(1,"ZR6",{|cCampo| ( Alltrim(cCampo) $ cCamposZR6 )})	
	
	// Adiciona ao modelo um componente de formulario
	oModel:AddFields("M_ZR6",/*cOwner*/,oStrZR6) 
	 
	 // Seta a chave primaria que sera utilizada na gravacao dos dados na tabela 
	oModel:SetPrimaryKey({"ZR6_CODIGO","ZR6_ITEM","ZR6_TABELA"})
	
	// Seta a descricao do modelo de dados no cabecalho
	oModel:getModel("M_ZR6"):SetDescription(OemToAnsi(cTitulo))
Return oModel

/*/{Protheus.doc} ViewDef
Funcao que cria a tela de visualizacao do modelo de dados da rotina.
@type function 
@author Ricardo Tavares Ferreira
@return object, Objeto da View.
@since 06/04/2021
@history 06/04/2021, Ricardo Tavares Ferreira, Construção Inicial.
@version 12.1.27
/*/
//==========================================================================================================
	Static Function ViewDef()
//==========================================================================================================

	Local oView		:= Nil
	Local oModel	:= FWLoadModel("API97A04") // Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
	Local oStrZR6	:= Nil		
   
	//Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
	oStrZR6 := FWFormStruct(2,"ZR6",{|cCampo| ( Alltrim(cCampo) $ cCamposZR6 )})
	
	// Cria o objeto de View
	oView := FWFormView():New()
	
	// Define qual o Modelo de dados sera utilizado na View
	oView:SetModel(oModel)	
	
	// Adiciona no nosso View um controle do tipo formulario
	oView:AddField("V_ZR6",oStrZR6,"M_ZR6",/*{|oModel| PreValida(oModel)}*/,/*{|oView| PosValida(oView)}*/)
	
	// Cria um "box" horizontal para receber cada elemento da view Pai
	oView:CreateHorizontalBox("V_SUP",100)

	// Relaciona o identificador (ID) da View com o "box" para exibicao Pai
	oView:SetOwnerView("V_ZR6","V_SUP")
	
	// Seta o Titulo no cabecalho do cadastro
	oView:EnableTitleView("V_ZR6",OemtoAnsi(cTitulo))
Return oView

/*/{Protheus.doc} MenuDef
Funcao que cria o menu principal do Browse da rotina.
@type function 
@author Ricardo Tavares Ferreira
@return array, Array do Menu padrão.
@since 06/04/2021
@history 06/04/2021, Ricardo Tavares Ferreira, Construção Inicial.
@version 12.1.27
/*/
//==========================================================================================================
	Static Function MenuDef()
//==========================================================================================================
	
	Local aRotina	:= {}
	
	ADD OPTION aRotina Title "Visualizar"		ACTION "VIEWDEF.API97A04" OPERATION MODEL_OPERATION_VIEW		ACCESS 0
	ADD OPTION aRotina Title "Incluir" 			ACTION "VIEWDEF.API97A04" OPERATION MODEL_OPERATION_INSERT		ACCESS 0
	ADD OPTION aRotina Title "Alterar" 			ACTION "VIEWDEF.API97A04" OPERATION MODEL_OPERATION_UPDATE		ACCESS 0
	ADD OPTION aRotina Title "Excluir" 			ACTION "VIEWDEF.API97A04" OPERATION MODEL_OPERATION_DELETE 		ACCESS 0
	ADD OPTION aRotina Title "Imprimir" 		ACTION "VIEWDEF.API97A04" OPERATION MODEL_OPERATION_IMPR		ACCESS 0
	ADD OPTION aRotina Title "Copiar" 			ACTION "VIEWDEF.API97A04" OPERATION MODEL_OPERATION_COPY	 	ACCESS 0
Return aRotina    
