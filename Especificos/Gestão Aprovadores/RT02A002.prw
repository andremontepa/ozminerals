#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "PRTOPDEF.CH"

#DEFINE MODEL_OPERATION_VIEW    2
#DEFINE MODEL_OPERATION_INSERT  3
#DEFINE MODEL_OPERATION_UPDATE  4
#DEFINE MODEL_OPERATION_DELETE  5
#DEFINE MODEL_OPERATION_COPY    9
#DEFINE MODEL_OPERATION_IMPR    8

#DEFINE cTitulo OemtoAnsi("Manutenção de Aprovadores")

/*/{Protheus.doc} RT02A002
Rotina em MVC do cadastro de Manutenção de Aprovadores. 
@type function
@author Ricardo Tavares Ferreira
@since 18/08/2021
@version 12.1.27
@history 18/08/2021, Ricardo Tavares Ferreira, Construção Inicial.
@return object, Retorna o Objeto do Browse.
/*/
//====================================================================================================
    User Function RT02A002()
//====================================================================================================

    DbSelectArea("ZZY")

    oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZZY")
	oBrowse:AddLegend("ZZY_STATUS  == 'AA' "	, "BR_VERDE"    	, "Regra Ativa (Execução Automática)")
	oBrowse:AddLegend("ZZY_STATUS  == 'AP' "	, "BR_AMARELO"  	, "Regra Programada (Execução Automática)")
    oBrowse:AddLegend("ZZY_STATUS  == 'AF' "	, "BR_VERMELHO" 	, "Regra Finalizada (Execução Automática)")

	oBrowse:AddLegend("ZZY_STATUS  == 'MA' "	, "BR_VERDE_ESCURO" , "Regra Aberta (Execução Manual)")
	oBrowse:AddLegend("ZZY_STATUS  == 'MP' "	, "BR_LARANJA" 		, "Regra Programada (Execução Manual)")
	oBrowse:AddLegend("ZZY_STATUS  == 'MF' "	, "BR_PRETO" 		, "Regra Finalizada (Execução Manual)")

	oBrowse:SetDescription(cTitulo)
	oBrowse:SetMenuDef("RT02A002")

	oBrowse:Activate()
Return oBrowse

/*/{Protheus.doc} ModelDef
Funcao que cria o modelo de dados da rotina.
@type function
@author Ricardo Tavares Ferreira
@since 18/08/2021
@version 12.1.27
@history 18/08/2021, Ricardo Tavares Ferreira, Construção Inicial.
@return object, Retorna o Objeto do Modelo de Dados.
/*/
//==========================================================================================================
	Static Function ModelDef()
//==========================================================================================================

	Local oModel	:= Nil
	Local oStrZZY	:= Nil
    Local aCampos   := {}
    Local nX        := 0
    Local cCampoZZY := ""

    aCampos := ZZY->(DbStruct())
	
	For nX := 2 To Len(aCampos)
		cCampoZZY += aCampos[nX][1]
		cCampoZZY += Iif((nX) < Len(aCampos),";","")
	Next

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New("RT02A02",{|oModel| PreValida()},{|oModel| PosValida(oModel)},/*{|oModel| GravaDados( oModel )}*/) 
	
	// Cria o Objeto da Estrutura dos Campos da tabela
	oStrZZY := FWFormStruct(1,"ZZY",{|cCampo| ( Alltrim(cCampo) $ cCampoZZY )})	

	// Adiciona ao modelo um componente de formulario
	oModel:AddFields("M_ZZY",/*cOwner*/,oStrZZY) 

	// Seta a chave primaria que sera utilizada na gravacao dos dados na tabela 
	oModel:SetPrimaryKey({"ZZY_CODIGO"})

    // Valida a Alteração dos Registros
    oModel:SetVldActivate({|oModel| ValAlt(oModel,oModel:GetOperation())})

	// Seta a descricao do modelo de dados no cabecalho
	oModel:getModel("M_ZZY"):SetDescription(OemToAnsi(cTitulo))

    // Seto o Conteudo no campo 
    oStrZZY:SetProperty("ZZY_STATUS" , MODEL_FIELD_INIT  , {|| Alltrim("AA")})
	oStrZZY:SetProperty("ZZY_SUBTMP" , MODEL_FIELD_WHEN  , {|| Iif(oModel:GetModel("M_ZZY"):GetValue("ZZY_TPEXEC") == "A",.F.,.T.)})
	oStrZZY:SetProperty("ZZY_DTFIM"  , MODEL_FIELD_WHEN  , {|| Iif(oModel:GetModel("M_ZZY"):GetValue("ZZY_TPEXEC") == "A",.T.,.F.)})
//	oStrZZY:SetProperty("ZZY_SUBST"  , MODEL_FIELD_WHEN  , {|| Iif(Empty(oModel:GetModel("M_ZZY"):GetValue("ZZY_SUBTMP")),.T.,.F.)})
	oStrZZY:SetProperty("ZZY_TPEXEC" , MODEL_FIELD_VALID , {|| ValidaTipo(oModel)})
	oStrZZY:SetProperty("ZZY_APROV"  , MODEL_FIELD_VALID , {|| GatilhoGen(oModel,"1")})
	oStrZZY:SetProperty("ZZY_SUBST"  , MODEL_FIELD_VALID , {|| GatilhoGen(oModel,"2")})
	oStrZZY:SetProperty("ZZY_SUBTMP" , MODEL_FIELD_VALID , {|| GatilhoGen(oModel,"3")})

Return oModel

/*/{Protheus.doc} ViewDef
Funcao que cria a tela de visualiZLcao do modelo de dados da rotina.
@type function
@author Ricardo Tavares Ferreira
@since 12/06/2021
@version 12.1.27
@history 12/06/2021, Ricardo Tavares Ferreira, Construção Inicial.
@return object, Retorna o modelo de visualizaçao da tela.
/*/
//==========================================================================================================
	Static Function ViewDef()
//==========================================================================================================

	Local oView		:= Nil
	Local oModel	:= FWLoadModel("RT02A002") // Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
	Local oStrZZY	:= Nil
    Local aCampos   := {}
    Local nX        := 0
    Local cCampoZZY := ""

    aCampos := ZZY->(DbStruct())
	
	For nX := 2 To Len(aCampos)
		cCampoZZY += aCampos[nX][1]
		cCampoZZY += Iif((nX) < Len(aCampos),";","")
	Next

	//Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
	oStrZZY := FWFormStruct(2,"ZZY",{|cCampo| ( Alltrim(cCampo) $ cCampoZZY )})

	// Cria o objeto de View
	oView := FWFormView():New()
	
	// Define qual o Modelo de dados sera utilizado na View
	oView:SetModel(oModel)	
	
	// Adiciona no nosso View um controle do tipo formulario
	oView:AddField("V_ZZY",oStrZZY,"M_ZZY",/*{|oModel| PreValida(oModel)}*/,/*{|oView| PosValida(oView)}*/)
	
	// Cria um "box" horizontal para receber cada elemento da view Pai
	oView:CreateHorizontalBox("V_SUP",100)

	// Relaciona o identificador (ID) da View com o "box" para exibicao Pai
	oView:SetOwnerView("V_ZZY","V_SUP")

	// Seta o Titulo no cabecalho do cadastro
	oView:EnableTitleView("V_ZZY",OemtoAnsi(cTitulo))
 
Return oView

/*/{Protheus.doc} MenuDef
Funcao que cria o menu principal do Browse da rotina.
@type function
@author Ricardo Tavares Ferreira
@since 12/06/2021
@version 12.1.27
@history 12/06/2021, Ricardo Tavares Ferreira, Construção Inicial.
@return array, Retorna um array contedo os menus da tela.
/*/
//====================================================================================================
    Static Function PreValida(oModel)
//====================================================================================================
Return .T.

/*/{Protheus.doc} PosValida
Função de Validação dos Dados na Confirmação de Inclusao/Alteração
@type function
@author Ricardo Tavares Ferreira
@since 12/06/2021
@version 12.1.27
@history 12/06/2021, Ricardo Tavares Ferreira, Construção Inicial.
@return logical, Retorna verdadeiro se puder executar a função.
/*/
//====================================================================================================
    Static Function PosValida(oModel)
//====================================================================================================
 
	Local oStrZZY := oModel:GetModel("M_ZZY")
	Local nOpc    := oModel:GetOperation()

	If nOpc == MODEL_OPERATION_INSERT
		If oStrZZY:GetValue("ZZY_TPEXEC") == "A"
			oStrZZY:LoadValue("ZZY_STATUS","AA")
		EndIf

		If oStrZZY:GetValue("ZZY_TPEXEC") == "M"
			oStrZZY:LoadValue("ZZY_STATUS","MA")
		EndIf
	EndIf 
Return .T.

/*/{Protheus.doc} MenuDef
Funcao que cria o menu principal do Browse da rotina.
@type function
@author Ricardo Tavares Ferreira
@since 12/06/2021
@version 12.1.27
@history 12/06/2021, Ricardo Tavares Ferreira, Construção Inicial.
@return array, Retorna um array contedo os menus da tela.
/*/
//==========================================================================================================
	Static Function MenuDef()
//==========================================================================================================
	
	Local aRotina	:= {}
	//Local cCodGru	:= PswRet()[1][1]
	
	ADD OPTION aRotina Title "Visualizar"			ACTION "VIEWDEF.RT02A002"               OPERATION MODEL_OPERATION_VIEW		ACCESS 0
	ADD OPTION aRotina Title "Incluir" 				ACTION "VIEWDEF.RT02A002"               OPERATION MODEL_OPERATION_INSERT	ACCESS 0
	ADD OPTION aRotina Title "Alterar" 				ACTION "VIEWDEF.RT02A002"               OPERATION MODEL_OPERATION_UPDATE	ACCESS 0
	
	//If cCodGru == "000000" 
		ADD OPTION aRotina Title "Excluir" 			ACTION "VIEWDEF.RT02A002"               OPERATION MODEL_OPERATION_DELETE 	ACCESS 0
	//EndIf
	
	ADD OPTION aRotina Title "Imprimir" 			ACTION "VIEWDEF.RT02A002"               OPERATION MODEL_OPERATION_IMPR		ACCESS 0
	ADD OPTION aRotina Title "Copiar" 				ACTION "VIEWDEF.RT02A002"               OPERATION MODEL_OPERATION_COPY	 	ACCESS 0	
    ADD OPTION aRotina Title "Executar Regra"	    ACTION "StaticCall(RT02A002,ExcManual)" OPERATION 9			 	            ACCESS 0

Return aRotina

/*/{Protheus.doc} ValAlt
Função que valida se o usuario pode alterar o registro.
@type function
@author Ricardo Tavares Ferreira
@since 12/06/2021
@version 12.1.27
@history 12/06/2021, Ricardo Tavares Ferreira, Construção Inicial.
@param oModel, object, Objeto do Modelo de Dados.
@param nOperation, numeric, Numero da Operação Executada no momento atual.
@return logical, Retorna verdadeiro se puder executar a alteração.
/*/
//==========================================================================================================
	Static Function ValAlt(oModel,nOperation)
//==========================================================================================================
	
	Local nOpc := oModel:GetOperation()

	If nOpc == MODEL_OPERATION_UPDATE
        If ZZY->ZZY_STATUS $ "AF/MF"
        	Help(Nil,Nil,"RT02A002",Nil,"A Regra selecionada ja está Finalizada.",1,0,Nil,Nil,Nil,Nil,Nil,{"Não é Possivel fazer a alteração dessa regra. Se for preciso inclua uma nova com novos parametros."})
			Return .F.
		EndIf
	EndIf
Return .T.

/*/{Protheus.doc} ExcManual
Botao para executar a rotina de preenchimento manual.
@type function
@author Ricardo Tavares Ferreira
@since 12/06/2021
@version 12.1.27
@history 12/06/2021, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//==========================================================================================================
	Static Function ExcManual()
//==========================================================================================================
	
	If ZZY->ZZY_STATUS $ "MA/MP"
		If ZZY->ZZY_STATUS == "MP" .and. Empty(ZZY->ZZY_SUBST)
			MsgInfo("Para Executar a regra é necessario preencher o campo do Aprovador Subst. Definitivo.","Atenção")
		Else 
			U_RT02JB01()
		EndIf 
	Else 
		MsgInfo("Esta Regra no pode ser executada pois está finalizada","Atenção")
	EndIf
Return

/*/{Protheus.doc} ValidaTipo
Função que valida o campo tipo.
@type function
@author Ricardo Tavares Ferreira
@since 12/06/2021
@version 12.1.27
@history 12/06/2021, Ricardo Tavares Ferreira, Construção Inicial.
@param oModel, object, Objeto do Modelo de Dados.
@return logical, Retorna verdadeiro se puder executar a alteração.
/*/
//==========================================================================================================
	Static Function ValidaTipo(oModel)
//==========================================================================================================
	
	Local oStrZZY := oModel:GetModel("M_ZZY")

	If oStrZZY:GetValue("ZZY_TPEXEC") == "A"
		oStrZZY:LoadValue("ZZY_SUBTMP","")
	Else 
		oStrZZY:LoadValue("ZZY_DTFIM",cTod(""))
	EndIf
Return .T.

/*/{Protheus.doc} GatilhoGen
Função que preenche os dados na grid com o produto escolhido
@type function
@author Ricardo Tavares Ferreira
@since 12/06/2021
@version 12.1.27
@history 12/06/2021, Ricardo Tavares Ferreira, Construção Inicial.
@param oModel, object, Objeto do Modelo de Dados.
@param nOperation, numeric, Numero da Operação Executada no momento atual.
@return logical, Retorna verdadeiro se puder executar a alteração.
/*/
//==========================================================================================================
	Static Function GatilhoGen(oModel,cTipo)
//==========================================================================================================
	
	Local oStrZZY := oModel:GetModel("M_ZZY")

	If cTipo == "1"
		oStrZZY:SetValue("ZZY_NOME"  , Alltrim(Posicione("SAK",1,FWXFilial("SAK")+oStrZZY:GetValue("ZZY_APROV"),"AK_NOME")))
	ElseIf cTipo == "2"
		oStrZZY:SetValue("ZZY_NOMSUB", Alltrim(Posicione("SAK",1,FWXFilial("SAK")+oStrZZY:GetValue("ZZY_SUBST"),"AK_NOME")))
	ElseIf cTipo == "3"
		oStrZZY:SetValue("ZZY_NSUBTM", Alltrim(Posicione("SAK",1,FWXFilial("SAK")+oStrZZY:GetValue("ZZY_SUBTMP"),"AK_NOME")))
	EndIf 
Return .T.
