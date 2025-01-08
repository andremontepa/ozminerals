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

/*/{Protheus.doc} API97A02
Rotina em MVC que realiza o cadastro Regras de Acesso a API.
@type function 
@author Ricardo Tavares Ferreira
@return object, Objeto do Browse.
@since 28/03/2021
@history 28/03/2021, Ricardo Tavares Ferreira, Construção Inicial.
@version 12.1.27
/*/
//=============================================================================================================================
    User Function API97A02()
//=============================================================================================================================
 
	Local oBrowse 		:= Nil
	Local aCampos		:= Nil
	Local nX			:= 0
	Private cCamposZR0	:= ""		
	Private cTitulo		:= OemtoAnsi("Regras de Acesso - API Integração")
	
	DbSelectArea("ZR0")
	
	aCampos := ZR0->(DbStruct())
	
	For nX := 2 To Len(aCampos)
		cCamposZR0 += aCampos[nX][1]
		cCamposZR0 += iif((nX) < Len(aCampos),";","")
	Next
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZR0")
	oBrowse:SetDescription(cTitulo)
	oBrowse:SetMenuDef("API97A02")
	oBrowse:Activate()
Return oBrowse

/*/{Protheus.doc} ModelDef
Funcao que cria o modelo de dados da rotina.
@type function 
@author Ricardo Tavares Ferreira
@return object, Objeto do Modelo.
@since 28/03/2021
@history 28/03/2021, Ricardo Tavares Ferreira, Construção Inicial.
@version 12.1.27
/*/
//==========================================================================================================
	Static Function ModelDef()
//==========================================================================================================

	Local oModel	:= Nil
	Local oStrZR0	:= Nil
	
	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New("ST5MODA1",/*{|oModel| PreValida(oModel)}*/,/*{|oModel| PosValida(oModel)}*/,/*{|oModel| GravaDados( oModel )}*/) 
	
	// Cria o Objeto da Estrutura dos Campos da tabela
	oStrZR0 := FWFormStruct(1,"ZR0",{|cCampo| ( Alltrim(cCampo) $ cCamposZR0 )})	
	
	// Adiciona ao modelo um componente de formulario
	oModel:AddFields("M_ZR0",/*cOwner*/,oStrZR0) 
	 
	 // Seta a chave primaria que sera utilizada na gravacao dos dados na tabela 
	oModel:SetPrimaryKey({"ZR0_USER","ZR0_SERV"})
	
	// Seta a descricao do modelo de dados no cabecalho
	oModel:getModel("M_ZR0"):SetDescription(OemToAnsi(cTitulo))
Return oModel

/*/{Protheus.doc} ViewDef
Funcao que cria a tela de visualizacao do modelo de dados da rotina.
@type function 
@author Ricardo Tavares Ferreira
@return object, Objeto da View.
@since 28/03/2021
@history 28/03/2021, Ricardo Tavares Ferreira, Construção Inicial.
@version 12.1.27
/*/
//==========================================================================================================
	Static Function ViewDef()
//==========================================================================================================

	Local oView		:= Nil
	Local oModel	:= FWLoadModel("API97A02") // Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
	Local oStrZR0	:= Nil		
   
	//Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
	oStrZR0 := FWFormStruct(2,"ZR0",{|cCampo| ( Alltrim(cCampo) $ cCamposZR0 )})
	
	// Cria o objeto de View
	oView := FWFormView():New()
	
	// Define qual o Modelo de dados sera utilizado na View
	oView:SetModel(oModel)	
	
	// Adiciona no nosso View um controle do tipo formulario
	oView:AddField("V_ZR0",oStrZR0,"M_ZR0",/*{|oModel| PreValida(oModel)}*/,/*{|oView| PosValida(oView)}*/)
	
	// Cria um "box" horizontal para receber cada elemento da view Pai
	oView:CreateHorizontalBox("V_SUP",100)

	// Relaciona o identificador (ID) da View com o "box" para exibicao Pai
	oView:SetOwnerView("V_ZR0","V_SUP")
	
	// Seta o Titulo no cabecalho do cadastro
	oView:EnableTitleView("V_ZR0",OemtoAnsi(cTitulo))
Return oView

/*/{Protheus.doc} MenuDef
Funcao que cria o menu principal do Browse da rotina.
@type function 
@author Ricardo Tavares Ferreira
@return array, Array do Menu padrão.
@since 28/03/2021
@history 28/03/2021, Ricardo Tavares Ferreira, Construção Inicial.
@version 12.1.27
/*/
//==========================================================================================================
	Static Function MenuDef()
//==========================================================================================================
	
	Local aRotina	:= {}
	
	ADD OPTION aRotina Title "Visualizar"		ACTION "VIEWDEF.API97A02" OPERATION MODEL_OPERATION_VIEW		ACCESS 0
	ADD OPTION aRotina Title "Incluir" 			ACTION "VIEWDEF.API97A02" OPERATION MODEL_OPERATION_INSERT		ACCESS 0
	ADD OPTION aRotina Title "Alterar" 			ACTION "VIEWDEF.API97A02" OPERATION MODEL_OPERATION_UPDATE		ACCESS 0
	ADD OPTION aRotina Title "Excluir" 			ACTION "VIEWDEF.API97A02" OPERATION MODEL_OPERATION_DELETE 		ACCESS 0
	ADD OPTION aRotina Title "Imprimir" 		ACTION "VIEWDEF.API97A02" OPERATION MODEL_OPERATION_IMPR		ACCESS 0
	ADD OPTION aRotina Title "Copiar" 			ACTION "VIEWDEF.API97A02" OPERATION MODEL_OPERATION_COPY	 	ACCESS 0
Return aRotina    