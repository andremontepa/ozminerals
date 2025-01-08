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

/*/{Protheus.doc} API97A01
Cadastro de Querys
@type function 
@author Ricardo Tavares Ferreira
@return object, Objeto do Browse.
@since 28/03/2021
@history 28/03/2021, Ricardo Tavares Ferreira, Construção Inicial.
@version 12.1.27
/*/
//=============================================================================================================================
    User Function API97A01()
//=============================================================================================================================
  
	Local oBrowse 		:= Nil
	Local aCampos		:= Nil
	Local nX			:= 0
	Private cCamposZR5	:= ""		
	Private cTitulo		:= OemtoAnsi("Cadastro de Querys")
	
	DbSelectArea("ZR5")
	
	aCampos := ZR5->(DbStruct())
	
	For nX := 2 To Len(aCampos)
		cCamposZR5 += aCampos[nX][1]
		cCamposZR5 += iif((nX) < Len(aCampos),";","")
	Next
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZR5")
	oBrowse:AddLegend("ZR5_STATUS == '1' "	, "BR_VERDE" 	, "Query Ativa")
    oBrowse:AddLegend("ZR5_STATUS == '2' "	, "BR_VERMELHO" , "Query Inativa")
	oBrowse:SetDescription(cTitulo)
	oBrowse:SetMenuDef("API97A01")
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
	Local oStrZR5	:= Nil
	
	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New("ZR5MOD",/*{|oModel| PreValida(oModel)}*/,/*{|oModel| PosValida(oModel)}*/,/*{|oModel| GravaDados( oModel )}*/) 
	
	// Cria o Objeto da Estrutura dos Campos da tabela
	oStrZR5 := FWFormStruct(1,"ZR5",{|cCampo| ( Alltrim(cCampo) $ cCamposZR5 )})	
	
	// Adiciona ao modelo um componente de formulario
	oModel:AddFields("M_ZR5",/*cOwner*/,oStrZR5) 
	 
	 // Seta a chave primaria que sera utilizada na gravacao dos dados na tabela 
	oModel:SetPrimaryKey({"ZR5_NUM"})

    oStrZR5:SetProperty("ZR5_STATUS", MODEL_FIELD_INIT,{|| cValToChar(1)})

    oModel:SetVldActivate({|oModel| ValAlt(oModel,oModel:GetOperation())})
	
	// Seta a descricao do modelo de dados no cabecalho
	oModel:getModel("M_ZR5"):SetDescription(OemToAnsi(cTitulo))
		
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
	Local oModel	:= FWLoadModel("API97A01") // Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
	Local oStrZR5	:= Nil		
   
	//Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
	oStrZR5 := FWFormStruct(2,"ZR5",{|cCampo| ( Alltrim(cCampo) $ cCamposZR5 )})
	
	// Cria o objeto de View
	oView := FWFormView():New()
	
	// Define qual o Modelo de dados sera utilizado na View
	oView:SetModel(oModel)	
	
	// Adiciona no nosso View um controle do tipo formulario
	oView:AddField("V_ZR5",oStrZR5,"M_ZR5",/*{|oModel| PreValida(oModel)}*/,/*{|oView| PosValida(oView)}*/)
	
	// Cria um "box" horizontal para receber cada elemento da view Pai
	oView:CreateHorizontalBox("V_SUP",100)

	// Relaciona o identificador (ID) da View com o "box" para exibicao Pai
	oView:SetOwnerView("V_ZR5","V_SUP")
	
	// Seta o Titulo no cabecalho do cadastro
	oView:EnableTitleView("V_ZR5",OemtoAnsi(cTitulo))
	
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
	
	ADD OPTION aRotina Title "Visualizar"		ACTION "VIEWDEF.API97A01" OPERATION MODEL_OPERATION_VIEW		ACCESS 0
	ADD OPTION aRotina Title "Incluir" 			ACTION "VIEWDEF.API97A01" OPERATION MODEL_OPERATION_INSERT		ACCESS 0
	ADD OPTION aRotina Title "Alterar" 			ACTION "VIEWDEF.API97A01" OPERATION MODEL_OPERATION_UPDATE		ACCESS 0
	ADD OPTION aRotina Title "Excluir" 			ACTION "VIEWDEF.API97A01" OPERATION MODEL_OPERATION_DELETE 		ACCESS 0
	ADD OPTION aRotina Title "Imprimir" 		ACTION "VIEWDEF.API97A01" OPERATION MODEL_OPERATION_IMPR		ACCESS 0
	ADD OPTION aRotina Title "Copiar" 			ACTION "VIEWDEF.API97A01" OPERATION MODEL_OPERATION_COPY	 	ACCESS 0
    ADD OPTION aRotina Title "Inativar/Ativar"	ACTION "StaticCall(API97A01,AltReg)"    OPERATION 9			 	ACCESS 0

Return aRotina    

/*/{Protheus.doc} AltReg
Funcao tipo botao para inativar o registro.
@type function 
@author Ricardo Tavares Ferreira
@since 28/03/2021
@history 28/03/2021, Ricardo Tavares Ferreira, Construção Inicial.
@version 12.1.27
/*/
//==========================================================================================================
	Static Function AltReg()
//==========================================================================================================
	
	Local cCod  := ZR5->ZR5_NUM
	
    DbSelectArea("ZR5")
    ZR5->(DBSetOrder(1))

	If DbSeek(FWXFilial("ZR5")+cCod)
		RecLock("ZR5",.F.)
			If ZR5->ZR5_STATUS == "1"
				ZR5->ZR5_STATUS := "2"
			Else
				ZR5->ZR5_STATUS := "1"
			EndIF
		ZR5->(MsUnlock())
    EndIf
Return

/*/{Protheus.doc} AltReg
Função que valida se o usuario pode alterar o registro.
@type function 
@author Ricardo Tavares Ferreira
@since 28/03/2021
@param oModel, object, Objeto do Modelo.
@param nOperation, numeric, Numero da Operação Executada.
@return logical, Retorna Verdadeiro caso o registro possa ser alterado.
@history 28/03/2021, Ricardo Tavares Ferreira, Construção Inicial.
@version 12.1.27
/*/
//==========================================================================================================
	Static Function ValAlt(oModel,nOperation)
//==========================================================================================================
	
	Local nOpc 		:= oModel:GetOperation()

	If nOpc == MODEL_OPERATION_UPDATE
		If ZR5->ZR5_STATUS == "2"
        	Help(Nil,Nil,"API97A01",Nil,"O cadastro <b>"+Alltrim(ZR5->ZR5_NUM)+" - "+Alltrim(ZR5->ZR5_DESC)+"</b> não pode ser alterado pois está inativo.",1,0,Nil,Nil,Nil,Nil,Nil,{"Ative o cadastro para que seja possivel realizar a sua alteração."})
			Return .F.
		EndIf
	EndIf
Return .T.