#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "RPTDEF.CH"    	
#INCLUDE "APWIZARD.CH"
#DEFINE  MODEL_OPERATION_VIEW 2
#DEFINE  MODEL_OPERATION_INSERT 3
#DEFINE  MODEL_OPERATION_UPDATE 4
#DEFINE  MODEL_OPERATION_DELETE 5
#DEFINE  MODEL_OPERATION_COPY 9
#DEFINE  MODEL_OPERATION_IMPR 8

#DEFINE CSSBOTAO	"QPushButton { color: #024670; "+;
	"    border-radius: 10px;"+;
	"    border-color: black; "+;
	"    border-left-width: 3px; "+;
	"    border-right-width: 3px; "+;
	"    border-bottom-width: 3px }"+;
	"QPushButton:pressed {	color: #FFFFFF; "+;
	"    border-image: url(rpo:fwstd_btn_prd.png) 3 3 3 3 stretch; "+;
	"    border-top-width: 3px; "+;
	"    border-left-width: 3px; "+;
	"    border-right-width: 3px; "+;
	"    border-bottom-width: 3px }"

STATIC aParBal		:= Nil
STATIC oBrowse		:= Nil

/*/{Protheus.doc} RT05A002
Rotina em MVC para Execução da Ordem de Carregamento
@author 	Ricardo Tavares Ferreira
@since 		09/06/2018
@version 	12.1.17
@return 	oBrowse
@Obs 		Ricardo Tavares - Construcao Inicial
/*/
//==========================================================================================================
	User Function RT05A002()
//==========================================================================================================

	Local aCampos		:= Nil
	Local n				:= 0
	Private cPerg		:= "RT05A002"
	//Private bTeclaF11 	:= SetKey(VK_F11,{|| CRIA_PAR(cPerg)})
	//Private bTeclaF12	:= SetKey(VK_F12,{|| aParBal:= AGRX003E(.T.,"OGA050001")})
	Private cCamposSZA	:= ""	
	Private cCamposSZB	:= ""	
	Private cTitulo		:= OemtoAnsi("Ordem de Carregamento / Pesagem")
	Private oSay		:= Nil
	
	DbSelectArea("SZA")
	DbSelectArea("SZB")
		
	aCampos := SZA->(DBSTRUCT())
	
	For n := 2 To Len(aCampos)
		cCamposSZA += aCampos[n][1]
		cCamposSZA += iif((n) < Len(aCampos),";","")
	Next
	
	aCampos	:= Nil
	aCampos := SZB->(DBSTRUCT())
	
	For n := 2 To Len(aCampos)
		cCamposSZB += aCampos[n][1]
		cCamposSZB += iif((n) < Len(aCampos),";","")
	Next
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("SZA")
	oBrowse:AddLegend("ZA_STATUS == '1' "	, "BR_VERDE" 		, "Ordem Aberta")
	oBrowse:AddLegend("ZA_STATUS == '2' "	, "BR_AZUL_CLARO"   , "1° Pesagem")
	oBrowse:AddLegend("ZA_STATUS == '3' "	, "BR_AZUL"   		, "2° Pesagem")
	oBrowse:AddLegend("ZA_STATUS == '4' "	, "BR_AMARELO"   	, "Ordem Faturada")
	oBrowse:AddLegend("ZA_STATUS == '5' "	, "BR_VERMELHO"   	, "Ordem Finalizada")
	oBrowse:SetDescription(cTitulo)
	oBrowse:SetMenuDef("RT05A002")
	
	SetKey(VK_F11,{|| CRIA_PAR(cPerg)})
	SetKey(VK_F12,{|| aParBal:= AGRX003E(.T.,"OGA050001")})
	
	oBrowse:Activate()
	//SetKey(VK_F11,bTeclaF11)
	//SetKey(VK_F12,bTeclaF12)
	//oBrowse:DeActivate()
	
Return 

/*/{Protheus.doc} ModelDef
Funcao que cria o modelo de dados da rotina.
@author 	Ricardo Tavares Ferreira
@since 		13/08/2018
@version 	12.1.17
@return 	oModel
@Obs 		Ricardo Tavares - Construcao Inicial
/*/
//==========================================================================================================
	Static Function ModelDef()
//==========================================================================================================

	Local oModel	:= Nil
	Local oStrSZA	:= Nil
	Local oStrSZB	:= Nil
	
	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New("RT052MOD",{|oModel| PreValida(oModel)},{|oModel| PosValida(oModel)},/*{|oModel| GravaDados( oModel )}*/) 
	
	oModel:SetVldActivate({|oModel| PreValida(oModel)})
	
	// Cria o Objeto da Estrutura dos Campos da tabela
	oStrSZA := FWFormStruct(1,"SZA",{|cCampo| ( Alltrim(cCampo) $ cCamposSZA )})
	oStrSZB := FWFormStruct(1,"SZB",{|cCampo| ( Alltrim(cCampo) $ cCamposSZB )})
	
	// Funcao que executa o gatilho de preenchimento da descricao dos campos
	oStrSZA:AddTrigger("ZA_CONT","ZA_DESCCT"	,{ || .T. },{|| oModel := FwModelActive(),Posicione("SZ8",2,xFilial("SZ8")+oModel:GetModel("M_SZA"):GetValue("ZA_CONT"),"Z8_TAG")})
	oStrSZA:AddTrigger("ZA_CONT","ZA_TARACON"	,{ || .T. },{|| oModel := FwModelActive(),Posicione("SZ8",2,xFilial("SZ8")+oModel:GetModel("M_SZA"):GetValue("ZA_CONT"),"Z8_PSOTARA")})
	oStrSZA:AddTrigger("ZA_CONDPAG","ZA_DESCOND",{ || .T. },{|| oModel := FwModelActive(),Posicione("SE4",1,xFilial("SE4")+oModel:GetModel("M_SZA"):GetValue("ZA_CONDPAG"),"E4_DESCRI")})
	oStrSZA:AddTrigger("ZA_TRANSP","ZA_DESCTRP"	,{ || .T. },{|| oModel := FwModelActive(),Posicione("SA4",1,xFilial("SA4")+oModel:GetModel("M_SZA"):GetValue("ZA_TRANSP"),"A4_NOME")})
	oStrSZA:AddTrigger("ZA_MOTORI","ZA_NOMEMT"	,{ || .T. },{|| oModel := FwModelActive(),Posicione("DHB",1,xFilial("DHB")+oModel:GetModel("M_SZA"):GetValue("ZA_MOTORI"),"DHB_NOMMOT")})
	oStrSZA:AddTrigger("ZA_VEICULO","ZA_DESCVEI",{ || .T. },{|| oModel := FwModelActive(),Posicione("DA3",1,xFilial("DA3")+oModel:GetModel("M_SZA"):GetValue("ZA_VEICULO"),"DA3_DESC")})
	oStrSZA:AddTrigger("ZA_CARRETA","ZA_DCARRET",{ || .T. },{|| oModel := FwModelActive(),Posicione("DA3",1,xFilial("DA3")+oModel:GetModel("M_SZA"):GetValue("ZA_CARRETA"),"DA3_DESC")})
	
	oStrSZB:AddTrigger("ZB_PRODUTO","ZB_DESC"	,{ || .T. },{|| oModel := FwModelActive(),Posicione("SB1",1,xFilial("SB1")+oModel:GetModel("M_SZB"):GetValue("ZB_PRODUTO"),"B1_DESC")})
	oStrSZB:AddTrigger("ZB_PRODUTO","ZB_UM"		,{ || .T. },{|| oModel := FwModelActive(),Posicione("SB1",1,xFilial("SB1")+oModel:GetModel("M_SZB"):GetValue("ZB_PRODUTO"),"B1_UM")})
	oStrSZB:AddTrigger("ZB_PRODUTO","ZB_COD"	,{ || .T. },{|| oModel := FwModelActive(),oModel:GetModel("M_SZA"):GetValue("ZA_COD")})
	oStrSZB:AddTrigger("ZB_PRODUTO","ZB_CLIENTE",{ || .T. },{|| oModel := FwModelActive(),oModel:GetModel("M_SZA"):GetValue("ZA_CLIENTE")})
	oStrSZB:AddTrigger("ZB_PRODUTO","ZB_LOJA"	,{ || .T. },{|| oModel := FwModelActive(),oModel:GetModel("M_SZA"):GetValue("ZA_LOJA")})	
	oStrSZB:AddTrigger("ZB_VUNIT"  ,"ZB_TOTAL"	,{ || .T. },{|| oModel := FwModelActive(),(oModel:GetModel("M_SZB"):GetValue("ZB_QUANT") * oModel:GetModel("M_SZB"):GetValue("ZB_VUNIT"))})	
	oStrSZB:AddTrigger("ZB_QUANT"  ,"ZB_CLIENTE",{ || .T. },{|| oModel := FwModelActive(),oModel:GetModel("M_SZA"):GetValue("ZA_CLIENTE")})	
	oStrSZB:AddTrigger("ZB_QUANT"  ,"ZB_LOJA"	,{ || .T. },{|| oModel := FwModelActive(),oModel:GetModel("M_SZA"):GetValue("ZA_LOJA")})	
	
	// Adiciona ao modelo um componente de formulario
	oModel:AddFields("M_SZA",/*cOwner*/,oStrSZA) 
	
	oModel:AddGrid("M_SZB","M_SZA",oStrSZB)
	oModel:SetRelation("M_SZB",;
	{{"ZB_FILIAL","xFilial('SZB')"},;
	{"ZB_COD","ZA_COD"},;
	{"ZB_CLIENTE","ZA_CLIENTE"},;
	{"ZB_LOJA","ZA_LOJA"}},;
	SZB->(IndexKey(2)))// Faz relacionamento entre os componentes do model
			 
	 // Seta a chave primaria que sera utilizada na gravacao dos dados na tabela 
	oModel:SetPrimaryKey({"ZA_FILIAL","ZA_COD","ZA_CLIENTE","ZA_LOJA"})
	
	// Seta a descricao do modelo de dados no cabecalho
	oModel:getModel("M_SZA"):SetDescription(OemToAnsi("Cabeçalho da Ordem de Carregamento / Pesagem"))
	
	// Seta a descricao do modelo de dados no cabecalho
	oModel:getModel("M_SZB"):SetDescription(OemtoAnsi("Itens da Ordem de Carregamento / Pesagem"))
		
	// Seto o Conteudo no campo para colocar o registro inicialmente como Ativo
	oStrSZA:SetProperty("ZA_STATUS",MODEL_FIELD_INIT,{||cValToChar(1)})
	//oStrSZA:SetProperty("Z5_CCUSTO",MODEL_FIELD_WHEN,"INCLUI")
	
	// Coloco uma regra para nao duplicar os itens contabeis na inclusao
	oModel:getModel("M_SZB"):SetUniqueLine({"ZB_ITEM"})
		
	// Seto o Conteudo no campo 
	//oStrSZB:SetProperty("ZB_COD"	,MODEL_FIELD_INIT,{||oModel:GetModel("M_SZA"):GetValue("ZA_COD")})
	//oStrSZB:SetProperty("ZB_CLIENTE",MODEL_FIELD_INIT,{||oModel:GetModel("M_SZA"):GetValue("ZA_CLIENTE")})
	//oStrSZB:SetProperty("ZB_LOJA"	,MODEL_FIELD_INIT,{||oModel:GetModel("M_SZA"):GetValue("ZA_LOJA")})
	
	// Regras de Dependencia
	//oModel:AddRules("M_SZB","ZB_PRODUTO"	,"M_SZA","ZA_COD"		,1)
	//oModel:AddRules("M_SZB","ZB_PRODUTO"	,"M_SZA","ZA_CLIENTE"	,1)
	//oModel:AddRules("M_SZB","ZB_PRODUTO"	,"M_SZA","ZA_LOJA"		,1)
	//oModel:AddRules("M_SZB","ZB_QUANT"	,"M_SZA","ZA_COD"		,1)
	//oModel:AddRules("M_SZB","ZB_QUANT"	,"M_SZA","ZA_CLIENTE"	,1)
	//oModel:AddRules("M_SZB","ZB_QUANT"	,"M_SZA","ZA_LOJA"		,1)
	//oModel:AddRules("M_SZB","ZB_VUNIT"	,"M_SZA","ZA_COD"		,1)
	//oModel:AddRules("M_SZB","ZB_VUNIT"	,"M_SZA","ZA_CLIENTE"	,1)
	//oModel:AddRules("M_SZB","ZB_VUNIT"	,"M_SZA","ZA_LOJA"		,1)
	
	oModel:SetActivate({|oModel| RT05A002A(oModel,oModel:GetOperation())})
		
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
	Local oModel	:= FWLoadModel("RT05A002") // Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
	Local oStrSZA	:= Nil		
	Local oStrSZB	:= Nil	
		
	//Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
	oStrSZA := FWFormStruct(2,"SZA",{|cCampo| ( Alltrim(cCampo) $ cCamposSZA )})
	oStrSZB := FWFormStruct(2,"SZB",{|cCampo| ( Alltrim(cCampo) $ cCamposSZB )})
	
	// Cria o objeto de View
	oView := FWFormView():New()
	
	// Define qual o Modelo de dados sera utilizado na View
	oView:SetModel(oModel)	
	
	// Adiciona no nosso View um controle do tipo formulario
	oView:AddField("V_SZA",oStrSZA,"M_SZA",/*{|oModel| PreValida(oModel)}*/,/*{|oView| PosValida(oView)}*/)
	
	//Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
	oView:AddGrid("V_SZB",oStrSZB,"M_SZB",/*{|oModel| PreValida(oModel)}*/,/*{|oView| PosValida(oView)}*/)
	
	// Cria um "box" horizontal para receber cada elemento da view Pai
	oView:CreateHorizontalBox("V_SUP",70)
	oView:CreateHorizontalBox("V_MEIO",30)

	// Relaciona o identificador (ID) da View com o "box" para exibicao Pai
	oView:SetOwnerView("V_SZA","V_SUP")
	oView:SetOwnerView("V_SZB","V_MEIO")
	
	// Seta o Titulo no cabecalho do cadastro
	oView:EnableTitleView("V_SZA",OemtoAnsi("Cabeçalho da Ordem de Carregamento / Pesagem"))
	oView:EnableTitleView("V_SZB",OemtoAnsi("Itens da Ordem de Carregamento / Pesagem"))
	
	// Aplico o autoincremento no campo de itens da grid
	oView:AddIncrementField("V_SZB","ZB_ITEM")   
	
	// Adiciona um novo botao a tela de Inclusao
	oView:AddUserButton("2° Pesagem", "CLIPS", {|x| RT05A002C(oModel,"VIEW")}) //"Pesagem"    
	
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
	Local cCodGru	:= PswRet()[1][1]
	
	ADD OPTION aRotina Title "Visualizar"			ACTION "VIEWDEF.RT05A002" OPERATION MODEL_OPERATION_VIEW		ACCESS 0
	ADD OPTION aRotina Title "Incluir" 				ACTION "VIEWDEF.RT05A002" OPERATION MODEL_OPERATION_INSERT		ACCESS 0
	ADD OPTION aRotina Title "Alterar" 				ACTION "VIEWDEF.RT05A002" OPERATION MODEL_OPERATION_UPDATE		ACCESS 0
	
	If cCodGru == "000000" 
		ADD OPTION aRotina Title "Excluir" 			ACTION "VIEWDEF.RT05A002" OPERATION MODEL_OPERATION_DELETE 		ACCESS 0
	EndIf
	
	ADD OPTION aRotina Title "Imprimir" 			ACTION "VIEWDEF.RT05A002" OPERATION MODEL_OPERATION_IMPR		ACCESS 0
	ADD OPTION aRotina Title "Copiar" 				ACTION "VIEWDEF.RT05A002" OPERATION MODEL_OPERATION_COPY	 	ACCESS 0
	ADD OPTION aRotina Title "1° Pesagem" 			ACTION "StaticCall(RT05A002,RT05A002B)" OPERATION 9			 	ACCESS 0
	ADD OPTION aRotina Title "2° Pesagem" 			ACTION "StaticCall(RT05A002,RT05A002F)" OPERATION 9			 	ACCESS 0
	ADD OPTION aRotina Title "Ticket de Pesagem"	ACTION "StaticCall(RT05A002,RT05A002G)" OPERATION 9			 	ACCESS 0
	ADD OPTION aRotina Title "Confirmar Ordem" 		ACTION "StaticCall(RT05A002,RT05A002D)" OPERATION 9			 	ACCESS 0
	ADD OPTION aRotina Title "Nfe Sefaz" 			ACTION "SPEDNFE" 						OPERATION 9			 	ACCESS 0
	ADD OPTION aRotina Title "Reabrir Ordem" 		ACTION "StaticCall(RT05A002,RT05A002E)" OPERATION 9			 	ACCESS 0
	ADD OPTION aRotina Title "Consultar Num. NF" 	ACTION "StaticCall(RT05A002,RT05A002H)" OPERATION 9			 	ACCESS 0

Return aRotina

/*/{Protheus.doc} PreValida
Funcao que realiza a pre validacao dos dados antes de aparecer a tela de inclusao ou alteracao dos dados a serem cadastrados.
@author 	Ricardo Tavares Ferreira
@since 		14/08/2018
@version 	12.1.17
@return 	Logico
@Obs 		Ricardo Tavares - Construcao Inicial
/*/
//==========================================================================================================
	Static Function PreValida(oModel)
//==========================================================================================================
	
	Local nOpc := oModel:GetOperation()
	Local lRet := .T.
	
Return lRet

/*/{Protheus.doc} PosValida
Funcao que realiza a pre validacao dos dados na confirmação dos dados.
@author 	Ricardo Tavares Ferreira
@since 		14/08/2018
@version 	12.1.17
@return 	Logico
@Obs 		Ricardo Tavares - Construcao Inicial
/*/
//==========================================================================================================
	Static Function PosValida(oModel)
//==========================================================================================================
	
	Local lRet     := .T.
	Local cTipoCli := ""
	Local nOpc     := oModel:GetOperation()
	Local oStrSZA  := oModel:GetModel("M_SZA")
	
	DbSelectArea("SZ8")
	SZ8->(DbSetOrder(2))

	If nOpc == MODEL_OPERATION_INSERT .or. nOpc == MODEL_OPERATION_UPDATE

		cTipoCli := Posicione("SA1",1,FWXFilial("SA1")+oStrSZA:GetValue("ZA_CLIENTE")+oStrSZA:GetValue("ZA_LOJA"),"A1_TIPO")

		If Alltrim(cTipoCli) == "X"
			If Empty(oStrSZA:GetValue("ZA_ESTEMB")) .and. lRet
				Help(Nil,Nil,"RT05A002",Nil,"Esta Ordem de Carregamento não pode ser salva pois o campo ("+ AllTrim(RetTitle("ZA_ESTEMB")) +"), precisa ser preenchido para clientes do tipo Exterior.",1,0,Nil,Nil,Nil,Nil,Nil,{"Preencha o campo solicitado para que a Ordem de Carregamento possa ser incluida."})
				lRet := .F.
			EndIf 
			If Empty(oStrSZA:GetValue("ZA_LCEMB")) .and. lRet
				Help(Nil,Nil,"RT05A002",Nil,"Esta Ordem de Carregamento não pode ser salva pois o campo ("+ AllTrim(RetTitle("ZA_LCEMB")) +"), precisa ser preenchido para clientes do tipo Exterior.",1,0,Nil,Nil,Nil,Nil,Nil,{"Preencha o campo solicitado para que a Ordem de Carregamento possa ser incluida."})
				lRet := .F.
			EndIf 
		EndIf
		
		If lRet	
			If SZ8->(DbSeek(FWXFilial("SZ8")+oStrSZA:GetValue("ZA_CONT")))
				RecLock("SZ8",.F.)
					SZ8->Z8_STATUS := "2"
				SZ8->(MsUnlock())
			EndIf
		EndIf
	EndIf

	If nOpc == MODEL_OPERATION_DELETE
		If lRet
			If SZ8->(DbSeek(FWXFilial("SZ8")+oStrSZA:GetValue("ZA_CONT")))
				RecLock("SZ8",.F.)
					SZ8->Z8_STATUS := "1"
				SZ8->(MsUnlock())
			EndIf
		EndIf
	EndIF
	
Return lRet

/*/{Protheus.doc} RT05A002A
Funçao que popula os campos conforme informaçoes de parametros pre selecionados.
@author 	Ricardo Tavares Ferreira
@since 		20/07/2018
@version 	12.1.17
@return 	Nulo
@Obs 		Ricardo Tavares - Construcao Inicial
/*/
//==========================================================================================================
	Static Function RT05A002A(oModel,nOperation)
//==========================================================================================================
	
	Local oView		:= FwViewActive()
	Local nOpc 		:= oModel:GetOperation()
	Local oStrSZA 	:= oModel:GetModel("M_SZA")
	
	IF aParBal == Nil     // Para Ser Inicializado Somente Qdo ainda não foi 
		aParBal := AGRX003E(.F.,"OGA050001")
	EndIF
	
	If nOpc == MODEL_OPERATION_INSERT .or. nOpc == MODEL_OPERATION_UPDATE
		If !Empty(aParBal[1])
			oStrSZA:SetValue("ZA_TPBAL",AllTrim(Posicione("DX5",1,FWXFilial("DX5")+Alltrim(aParBal[1]),"DX5_XTPBAL")))
		EndIf
	EndIf
	
	If nOpc == MODEL_OPERATION_INSERT
		Pergunte(cPerg,.F.)
		If !Empty(MV_PAR01)
			FwFldPut("ZA_CONDPAG",Alltrim(MV_PAR01)) //Condicao de Pagamento
		Endif
		If !Empty(MV_PAR02)
			FwFldPut("ZA_TRANSP",Alltrim(MV_PAR02)) //Transportadora
		Endif
		If !Empty(MV_PAR03)
			FwFldPut("ZB_PRODUTO",AllTrim(MV_PAR03)) //Produto
		Endif
		If !Empty(MV_PAR04)
			FwFldPut("ZA_CLIENTE",AllTrim(MV_PAR04)) //Cliente
			FwFldPut("ZB_CLIENTE",AllTrim(MV_PAR04)) //Cliente
		Endif
		If !Empty(MV_PAR05)
			FwFldPut("ZA_LOJA",AllTrim(MV_PAR05)) //Loja
			FwFldPut("ZB_LOJA",AllTrim(MV_PAR05)) //Loja
		Endif
		If !Empty(MV_PAR04) .and. !Empty(MV_PAR05)
			FwFldPut("ZA_NOMCLI",AllTrim(Posicione("SA1",1,FWXFilial("SA1")+AllTrim(MV_PAR04)+AllTrim(MV_PAR05),"A1_NOME"))) // Nome Cliente
		Endif
		If !Empty(MV_PAR06)
			FwFldPut("ZA_NATUR",AllTrim(MV_PAR06)) //Natureza
		Endif
		If !Empty(MV_PAR07)
			FwFldPut("ZB_TES",AllTrim(MV_PAR07)) //Tipo de Entrada / Saida
		Endif

	EndIf 
	
Return .T.

/*/{Protheus.doc} RT05A002B
Funçao que realiza a Primeira pesagem do produto no browse.
@author 	Ricardo Tavares Ferreira
@since 		20/07/2018
@version 	12.1.17
@return 	Nulo
@Obs 		Ricardo Tavares - Construcao Inicial
/*/
//==========================================================================================================
	Static Function RT05A002B()
//==========================================================================================================
	
	Local oView		:= FwViewActive()
	Local oModel	:= FWModelActive()
	Local aArea		:= GetArea()
	Local lRet		:= .T.
	Local cTipoBal	:= ""
	Local nPesoLiq	:= 0
	Local nPesoBru	:= 0
	Local nPercUmi	:= 0
	
	DbSelectArea("SZA")
	SZA->(DbSetOrder(1))
	
	If SZA->(DbSeek(FWXFilial("SZA")+SZA->ZA_COD))
		
		If Empty(MV_PAR08)
			Pergunte(cPerg,.F.)
		EndIf
		
		nPercUmi := MV_PAR08
		
		IF aParBal == Nil     // Para Ser Inicializado Somente Qdo ainda não foi 
			aParBal := AGRX003E(.F.,"OGA050001")
		EndIF	
		
		cTipoBal  := Posicione("DX5",1,FWXFilial("DX5")+Alltrim(aParBal[1]),"DX5_XTPBAL")
		
		If cTipoBal == "1"
			MsgInfo("Como o Tipo de Balança Escolhida foi a Fixa, O Valor da Tara do Container Será o Valor da 1° Pesagem.","Atenção")
			If SZA->ZA_PESO2 > 0 
				nPesoBru :=  (SZA->ZA_PESO2 - SZA->ZA_TARACON)
				nPesoLiq :=  (SZA->ZA_PESO2 - SZA->ZA_TARACON) - (SZA->ZA_PESO2 - SZA->ZA_TARACON) * (nPercUmi / 100)
			EndIf
			
			RecLock("SZA",.F.)
				SZA->ZA_PESO1 := SZA->ZA_TARACON
				SZA->ZA_DTPESO1 := Date()
				SZA->ZA_HRPESO1 := Time()
				SZA->ZA_USRPSO1	:= UsrFullName(RetCodUsr())
				If nPesoBru > 0 .and. nPesoLiq > 0 
					SZA->ZA_PESOLIQ := nPesoLiq
					SZA->ZA_PESOBUT := nPesoBru
				EndIf
				If SZA->ZA_PESO2 <= 0
					SZA->ZA_STATUS := "2"
				EndIf
			SZA->(MsUnlock())
		Else
			oModel := FWLoadModel("RT05A002")
			oModel:SetOperation(MODEL_OPERATION_UPDATE)
			oModel:Activate()
			RT05A002C(oModel,"BROW")
			oModel:DeActivate()
		EndIf
		
	Else
		lRet:= .F.
		Help(Nil,Nil,"RT05A002",Nil,"Ordem de Carregamento não Encontrada",1,0,Nil,Nil,Nil,Nil,Nil,{"Selecione uma Ordem de Carregamento Cadastrada."})
	EndIf
	
	RestArea(aArea)
	
Return lRet

/*/{Protheus.doc} RT05A002C
Funçao que realiza a pesagem.
@author 	Ricardo Tavares Ferreira
@since 		21/07/2018
@version 	12.1.17
@return 	Nulo
@Obs 		Ricardo Tavares - Construcao Inicial
/*/
//==========================================================================================================
	Static Function RT05A002C(oModel,cOrigem)
//==========================================================================================================
	
	Local oView			:= FWViewActive()
	Local nSZARecno 	:= 0
	Local nOperation	:= oModel:GetOperation()
	Local oStrSZA 		:= oModel:GetModel("M_SZA")
	Local oStrSZB 		:= oModel:GetModel("M_SZB")

	Local nPeso1 		:= 0
	Local nPeso2 		:= 0
	Local nPesoLiq		:= 0
	Local nPesoBru		:= 0
	Local nPercUmi		:= 0
	Local cTipoBal		:= ""
	Local lPeso1 		:= .F.
	Local lPeso2		:= .F.
	Local lPeso3		:= .F.

	Local nItem			:= 1
	Local nPeso			:= 0
	Local lPesagManu	:= .F.
	
	Default oModel		:= Nil
	Default cOrigem		:= ""
	
	If cOrigem == "BROW" .or. cOrigem == "BROW2"	
		nSZARecno 	:= SZA->(Recno())
		If SZA->ZA_STATUS $ "4|5"
			Help(Nil,Nil,"RT05A002",Nil,"A Ordem de Carregamento ..:("+Alltrim(SZA->ZA_COD)+"), não permite alteração na Pesagem.",1,0,Nil,Nil,Nil,Nil,Nil,{"Selecione uma Ordem de Carregamento que esteja em condições de Pesagem."})
			Return .F.
		EndIf
	Else
		If oStrSZA:GetValue("ZA_PESO1") <= 0 .or. nOperation == MODEL_OPERATION_VIEW
			Help(Nil,Nil,"RT05A002",Nil,"Não é Possivel Realizar a 2° Pesagem.",1,0,Nil,Nil,Nil,Nil,Nil,{"Faça a 1° Pesagem , para que a segunda possa ser feita."})
			Return .F.
		EndIf
		If oStrSZA:GetValue("ZA_STATUS") $ "4|5" .or. nOperation == MODEL_OPERATION_VIEW		
			Help(Nil,Nil,"RT05A002",Nil,"A Ordem de Carregamento ..:("+Alltrim(oStrSZA:GetValue("ZA_COD"))+"), não permite alteração na Pesagem.",1,0,Nil,Nil,Nil,Nil,Nil,{"Selecione uma Ordem de Carregamento que esteja em condições de Pesagem."})
			Return .F.
		EndIf
	Endif
	
	If Empty(MV_PAR08)
		Pergunte(cPerg,.F.)
	EndIf
		
	nPercUmi := MV_PAR08

	IF aParBal == Nil     // Para Ser Inicializado Somente Qdo ainda não foi 
		aParBal := AGRX003E(.F.,"OGA050001")
	EndIF	   

	If cOrigem == "BROW" .or. cOrigem == "BROW2" 	
		nPeso1   := SZA->ZA_PESO1
		nPeso2 	 := SZA->ZA_PESO2
	Else
		nPeso1   := oStrSZA:GetValue("ZA_PESO1")
		nPeso2   := oStrSZA:GetValue("ZA_PESO2")
	EndIf

	cTipoBal  := Posicione("DX5",1,FWXFilial("DX5")+Alltrim(aParBal[1]),"DX5_XTPBAL")
		
	lPeso1 	:= (nPeso1 == 0)
	lPeso2	:= (nPeso2 == 0)
	lPeso3	:= (nPeso1 > 0 .And. nPeso2 > 0)

	If (nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == 4)

		If lPeso3 .And. .Not. aParBal[4]
			
			If cOrigem == "BROW"
				If MsgYesNo("Deseja Refazer a 1° Pesagem ?","Atenção")
					nItem := 1
				Else
					Return
				EndIf
			ElseIf cOrigem == "BROW2"
				If MsgYesNo("Deseja Refazer a 2° Pesagem ?","Atenção")
					nItem := 2
				Else
					Return
				EndIf
			ElseIF cOrigem == "VIEW"
				If MsgYesNo("Deseja Refazer a 2° Pesagem ?","Atenção")
					nItem := 2
				Else
					Return
				EndIf
			EndIf

			If nItem == 1
				lPeso1 := .T.
				lPeso2 := .F.
			ElseIf nItem == 2
				lPeso1 := .F.
				lPeso2 := .T.
			EndIf
		EndIf
		
		// Abre a tela para pesagem
		AGRX003A(@nPeso,.T.,aParBal,/*cMask*/,@lPesagManu)
		
		// Se o peso lido for maior que zero
		If nPeso > 0	
			/** Executa primeira pesagem ou repesagem do primeiro peso **/
			If lPeso1
				If nPeso <> nPeso2 // Consistência para não permitir 2 pesos iguais

					If cOrigem == "VIEW"	
						oStrSZA:SetValue("ZA_PESO2" ,nPeso)	
						oStrSZA:SetValue("ZA_STATUS",IIf(lPeso3,"3","3"))
						oStrSZA:SetValue("ZA_DTPESO1",Date())
						oStrSZA:SetValue("ZA_HRPESO1",Time())	
						oStrSZA:SetValue("ZA_USRPSO1",UsrFullName(RetCodUsr()))
						
						If cTipoBal == "2"
							If oStrSZA:GetValue("ZA_PESO1") > 0 .and. oStrSZA:GetValue("ZA_PESO2") > 0
								nPesoBru :=  (oStrSZA:GetValue("ZA_PESO2") - (oStrSZA:GetValue("ZA_PESO1") + oStrSZA:GetValue("ZA_TARACON")))
								nPesoLiq :=  (nPesoBru - (nPesoBru * (nPercUmi / 100)))
							EndIf
						EndIf	
						
						If nPesoBru > 0 .and. nPesoLiq > 0 
							oStrSZA:SetValue("ZA_PESOLIQ",nPesoLiq)
							oStrSZA:SetValue("ZA_PESOBUT",nPesoBru)
							oStrSZA:SetValue("ZA_TPBAL",cTipoBal)
							oStrSZB:SetValue("ZB_QUANT",nPesoLiq)
							oStrSZB:SetValue("ZB_TOTAL",nPesoLiq * oStrSZB:GetValue("ZB_VUNIT"))
						EndIf				
					Else
						DbSelectArea("SZA")
						If RecLock("SZA",.F.)
							If cOrigem == "BROW"
								SZA->ZA_PESO1 := nPeso
							Else
								SZA->ZA_PESO2 := nPeso
							EndIf
							SZA->ZA_STATUS  := IIf( lPeso3, "3", "2" ) 
							SZA->ZA_DTPESO1 := Date()
							SZA->ZA_HRPESO1 := Time()
							SZA->ZA_USRPSO1	:= UsrFullName(RetCodUsr())
							SZA->(MsUnLock())
						End	
						
						If cTipoBal == "2"
							If SZA->ZA_PESO1 > 0 .and. SZA->ZA_PESO2 > 0 
								nPesoBru := (SZA->ZA_PESO2 - (SZA->ZA_PESO1 + SZA->ZA_TARACON))
								nPesoLiq := (nPesoBru - (nPesoBru * (nPercUmi / 100)))
							EndIf
						EndIf
						
						If nPesoBru > 0 .and. nPesoLiq > 0 
							RecLock("SZA",.F.)
								SZA->ZA_PESOLIQ := nPesoLiq
								SZA->ZA_PESOBUT := nPesoBru
								SZA->ZA_TPBAL   := cTipoBal
							SZA->(MsUnLock())
							
							DbSelectArea("SZB")
							SZB->(DbSetOrder(1))
							
							If SZB->(DbSeek(FWXFilial("SZB")+SZA->ZA_COD))
								RecLock("SZB",.F.)
									SZB->ZB_QUANT := nPesoLiq
									SZB->ZB_TOTAL := (SZB->ZB_QUANT * SZB->ZB_VUNIT)
								SZB->(MsUnLock())
							EndIf 
						EndIf
					Endif
				Else
					Help(Nil,Nil,"RT05A002",Nil,"Pesagem com Valores Iguais.",1,0,Nil,Nil,Nil,Nil,Nil,{"Os Valores das pesagens tem que ser diferentes."})
					Return
				Endif			
			Else
				/** Executa segunda pesagem ou repesagem do segundo peso **/
				If lPeso2
					If nPeso <> nPeso1 // Consistência para não permitir 2 pesos iguais
						
						If cOrigem == "VIEW"	
							oStrSZA:SetValue("ZA_PESO2" ,nPeso)	
							oStrSZA:SetValue("ZA_STATUS",IIf(lPeso3,"3","3"))	
							oStrSZA:SetValue("ZA_DTPESO2",Date())
							oStrSZA:SetValue("ZA_HRPESO2",Time())
							oStrSZA:SetValue("ZA_USRPSO2",UsrFullName(RetCodUsr()))
							
							If cTipoBal == "1"
								If oStrSZA:GetValue("ZA_PESO1") > 0 .and. oStrSZA:GetValue("ZA_PESO2") > 0
									nPesoBru :=  (oStrSZA:GetValue("ZA_PESO2") - oStrSZA:GetValue("ZA_TARACON"))
									nPesoLiq :=  (oStrSZA:GetValue("ZA_PESO2") - oStrSZA:GetValue("ZA_TARACON")) - (oStrSZA:GetValue("ZA_PESO2") - oStrSZA:GetValue("ZA_TARACON")) * (nPercUmi / 100)
								EndIf
							ElseIf cTipoBal == "2"
								If oStrSZA:GetValue("ZA_PESO1") > 0 .and. oStrSZA:GetValue("ZA_PESO2") > 0
									nPesoBru :=  (oStrSZA:GetValue("ZA_PESO2") - (oStrSZA:GetValue("ZA_PESO1") + oStrSZA:GetValue("ZA_TARACON")))
									nPesoLiq :=  (nPesoBru - (nPesoBru * (nPercUmi / 100)))
								EndIf
							EndIf
							
							If nPesoBru > 0 .and. nPesoLiq > 0 
								oStrSZA:SetValue("ZA_PESOLIQ",nPesoLiq)
								oStrSZA:SetValue("ZA_PESOBUT",nPesoBru)
								oStrSZA:SetValue("ZA_TPBAL",cTipoBal)						
								oStrSZB:SetValue("ZB_QUANT",nPesoLiq)
								oStrSZB:SetValue("ZB_TOTAL",nPesoLiq * oStrSZB:GetValue("ZB_VUNIT"))
							EndIf
						Else
							DbSelectArea("SZA")
							RecLock("SZA",.F.)
								If cOrigem == "BROW"
									SZA->ZA_PESO1  := nPeso
								Else
									SZA->ZA_PESO2  := nPeso
								EndIf
								SZA->ZA_STATUS  := IIf( lPeso3, "3", "3" ) 
								SZA->ZA_DTPESO2 := Date()
								SZA->ZA_HRPESO2 := Time()	
								SZA->ZA_USRPSO2	:= UsrFullName(RetCodUsr())
							SZA->(MsUnLock())
						
							If cTipoBal == "1"
								If SZA->ZA_PESO1 > 0 .and. SZA->ZA_PESO2 > 0 
									nPesoBru :=  (SZA->ZA_PESO2 - SZA->ZA_TARACON)
									nPesoLiq :=  (SZA->ZA_PESO2 - SZA->ZA_TARACON) - (SZA->ZA_PESO2 - SZA->ZA_TARACON) * (nPercUmi / 100)
								EndIf
							ElseIf cTipoBal == "2"
								If SZA->ZA_PESO1 > 0 .and. SZA->ZA_PESO2 > 0 
									nPesoBru := (SZA->ZA_PESO2 - (SZA->ZA_PESO1 + SZA->ZA_TARACON))
									nPesoLiq := (nPesoBru - (nPesoBru * (nPercUmi / 100)))
								EndIf
							EndIf
							
							If nPesoBru > 0 .and. nPesoLiq > 0 
								RecLock("SZA",.F.)
									SZA->ZA_PESOLIQ := nPesoLiq
									SZA->ZA_PESOBUT := nPesoBru
									SZA->ZA_TPBAL   := cTipoBal
								SZA->(MsUnLock())
								
								DbSelectArea("SZB")
								SZB->(DbSetOrder(1))
								
								If SZB->(DbSeek(FWXFilial("SZB")+SZA->ZA_COD))
									RecLock("SZB",.F.)
										SZB->ZB_QUANT := nPesoLiq
										SZB->ZB_TOTAL := (SZB->ZB_QUANT * SZB->ZB_VUNIT)
									SZB->(MsUnLock())
								EndIf 
							EndIf
						EndIf
					Else
						Help(Nil,Nil,"RT05A002",Nil,"Pesagem com Valores Iguais.",1,0,Nil,Nil,Nil,Nil,Nil,{"Os Valores das pesagens tem que ser diferentes."})
						Return
					Endif
				EndIf		
			EndIf
		EndIf
	EndIf

	If cOrigem == "VIEW"
		oView:Refresh()
	Else
		SZA->(DbGoTo(nSZARecno))
		oBrowse:Refresh()
	Endif
	
Return .T.

/*/{Protheus.doc} RT05A002D
Funçao que realiza a Confirmação da Ordem de Carregamento.
@author 	Ricardo Tavares Ferreira
@since 		21/07/2018
@version 	12.1.17
@return 	Nulo
@Obs 		Ricardo Tavares - Construcao Inicial
/*/
//==========================================================================================================
	Static Function RT05A002D()
//==========================================================================================================
	
	Local cQuery	:= ""
	Local QBLINHA	:= chr(13)+chr(10)
	Local NQTREG	:= 0
	Local nCont 	:= 1
	Local nRecSZA	:= 0
	Local cOrdem	:= ""
	Local cVendPad	:= SuperGetMv("MV_VENDPAD",.F.,"000001")
	Local cArmz		:= ""
	Local aArea    	:= GetArea()
	Local aAreaSB1 	:= SB1->(GetArea())
	Local aAreaSZA 	:= SZA->(GetArea())
	Local aAreaSC5 	:= SC5->(GetArea())
	Local aAreaSC6 	:= SC6->(GetArea())
	Local aAreaSD2 	:= SD2->(GetArea())
	Local aAreaSF2 	:= SF2->(GetArea())
	Local cDirSrv	:= "\msgnf\"
	Local cFile 	:= ""
	Local cMsg		:= ""
	Local cJson		:= ""
	Local oObj 		:= Nil
	Local oDados	:= Nil
	Local nX		:= 0
	Local lOpen		:= .F.
	Local cValDolar	:= 0
	Local cLacreArm := ""
	Local cPlacaCam := ""
	Local cPlacaCar := ""
	Local cDoc		:= ""

	Private lMsErroAuto := .F.  
	Private aCabec 		:= {}
	Private aItens 		:= {}  
	Private aLinha		:= {}

	DbSelectarea("SZB")
	SZB->(DbSetOrder(1))
	SZB->(DbSeek(FWXFilial("SZB")+SZA->ZA_COD))

	cValDolar := (SZB->ZB_TOTAL / SZA->ZA_TXDOLAR)
	cLacreArm := Posicione("SZ8",2,FWXFilial("SZ8")+SZA->ZA_CONT,"Z8_LACRE")
	cPlacaCam := Posicione("DA3",1,FWXFilial("DA3")+SZA->ZA_VEICULO,"DA3_PLACA")
	cPlacaCar := Posicione("DA3",1,FWXFilial("DA3")+SZA->ZA_CARRETA,"DA3_PLACA")

	cFile := cDirSrv+cEmpAnt+cFilAnt+".txt"
	oFile := FWFileReader():New(cFile)
	
	If oFile:Open()
		While oFile:hasLine()
			cJson += oFile:GetLine()
      	End
      	oFile:Close()
      	lOpen := .T.
    Else
    	MsgInfo(oFile:error():message)
    	Return .F.
    EndIf
    
    If lOpen
	    If FWJsonDeserialize(cJson,@oObj)
	    	oDados := @oObj
	    	For nX := 1 To Len(oDados:MSG)
	    		cMsg += oDados:MSG[nX]
	    	Next nX

	    	cMsg := Upper(StrTran(cMsg,"<PESOL>"	,Transform(SZA->ZA_PESOLIQ,PesqPict("SZA","ZA_PESOLIQ"))))
			cMsg := Upper(StrTran(cMsg,"<DOLAR>"	,Transform(cValDolar,PesqPict("SZA","ZA_PESOLIQ"))))
			cMsg := Upper(StrTran(cMsg,"<TAXA>"		,Transform(SZA->ZA_TXDOLAR,PesqPict("SZA","ZA_TXDOLAR"))))
			cMsg := Upper(StrTran(cMsg,"<CONT>"		,Alltrim(SZA->ZA_DESCCT)))
			cMsg := Upper(StrTran(cMsg,"<TCONT>"	,Alltrim(Transform(SZA->ZA_TARACON,PesqPict("SZA","ZA_TARACON")))))
			cMsg := Upper(StrTran(cMsg,"<LARMAD>"	,Alltrim(cLacreArm)))
			cMsg := Upper(StrTran(cMsg,"<LAVANCO>"	,Alltrim(SZA->ZA_LCAVANC)))
			cMsg := Upper(StrTran(cMsg,"<PCAMINHAO>",Transform(cPlacaCam,"@R AAA-9999")))
			cMsg := Upper(StrTran(cMsg,"<CIDADE>"	,AllTrim(Posicione("DA3",1,FWXFilial("DA3")+SZA->ZA_VEICULO,"DA3_MUNPLA"))))
			cMsg := Upper(StrTran(cMsg,"<ESTADO>"	,AllTrim(Posicione("DA3",1,FWXFilial("DA3")+SZA->ZA_VEICULO,"DA3_ESTPLA"))))
			cMsg := Upper(StrTran(cMsg,"<KM>"		,AllTrim(SZA->ZA_KMVEIC)))
			cMsg := Upper(StrTran(cMsg,"<PCARRETA>"	,Transform(cPlacaCar,"@R AAA-9999")))
			cMsg := Upper(StrTran(cMsg,"<CIDCAR>"	,AllTrim(Posicione("DA3",1,FWXFilial("DA3")+SZA->ZA_CARRETA,"DA3_MUNPLA"))))
			cMsg := Upper(StrTran(cMsg,"<ESTCAR>"	,AllTrim(Posicione("DA3",1,FWXFilial("DA3")+SZA->ZA_CARRETA,"DA3_ESTPLA"))))
			cMsg := Upper(StrTran(cMsg,"<MOTORISTA>",AllTrim(SZA->ZA_NOMEMT)))
			cMsg := Upper(StrTran(cMsg,"<CPF>"		,Transform(SZA->ZA_MOTORI,"@R 999.999.999-99")))

	    Endif
	EndIf
	
	If .not. Empty(SZA->ZA_PEDIDO) .or. .not. Empty(SZA->ZA_NF) .or. .not. Empty(SZA->ZA_SERIE)
		Help(Nil,Nil,"RT05A002",Nil,"Esta Ordem de Carregamento já foi confirmada.",1,0,Nil,Nil,Nil,Nil,Nil,{"Acesse a opção <b>NFe Sefaz</b> para verificar o status da NF: "+Alltrim(SZA->ZA_NF)+"/"+Alltrim(SZA->ZA_SERIE)+" referente a esta ordem de carregamento."})
		Return .F.
	EndIf
	
	If SZA->ZA_PESO1 <= 0 
		Help(Nil,Nil,"RT05A002",Nil,"A Confirmação não pôde ser feita.A Ordem de Carregamento Escolhida nao foi Pesada.",1,0,Nil,Nil,Nil,Nil,Nil,{"Realize a 1° Pesagem da Ordem de Carregamento, para que seja possivel confirmar a mesma."})
		Return .F.
	EndIf
	
	If SZA->ZA_PESO2 <= 0
		Help(Nil,Nil,"RT05A002",Nil,"A Confirmação não pôde ser feita.A Ordem de Carregamento Escolhida nao foi Pesada.",1,0,Nil,Nil,Nil,Nil,Nil,{"Realize a 2° Pesagem da Ordem de Carregamento, para que seja possivel confirmar a mesma."})
		Return .F.
	EndIf
	
	If SZA->ZA_STATUS == "4" .and. .not. Empty(SZA->ZA_PEDIDO)
		Help(Nil,Nil,"RT05A002",Nil,"Esta Ordem de Carregamento já foi confirmada.",1,0,Nil,Nil,Nil,Nil,Nil,{"Selecione uma Ordem de Carregamento apta a ser Confirmada."})
		Return .F.
	EndIf
	
	If SZA->ZA_STATUS == "5" .and. .not. Empty(SZA->ZA_PEDIDO) .and. .not. Empty(SZA->ZA_NF) .and. .not. Empty(SZA->ZA_SERIE)
		Help(Nil,Nil,"RT05A002",Nil,"Esta Ordem de Carregamento já foi Encerrada.",1,0,Nil,Nil,Nil,Nil,Nil,{"Selecione uma Ordem de Carregamento apta a ser Confirmada."})
		Return .F.
	EndIf

	If Empty(SZA->ZA_TRANSP)
		Help(Nil,Nil,"RT05A002",Nil,"Não foi possivel imprimir o Ticket de Pesagem neste Momento.",1,0,Nil,Nil,Nil,Nil,Nil,{"Preencha o campo ("+Alltrim(RetTitle("ZA_TRANSP"))+"), para depois imprimir o Ticket de Pesagem."})
		Return .F.
	EndIf
	
	If Empty(SZA->ZA_MOTORI)
		Help(Nil,Nil,"RT05A002",Nil,"Não foi possivel imprimir o Ticket de Pesagem neste Momento.",1,0,Nil,Nil,Nil,Nil,Nil,{"Preencha o campo ("+Alltrim(RetTitle("ZA_MOTORI"))+"), para depois imprimir o Ticket de Pesagem."})
		Return .F.
	EndIf
	
	If Empty(SZA->ZA_VEICULO)
		Help(Nil,Nil,"RT05A002",Nil,"Não foi possivel imprimir o Ticket de Pesagem neste Momento.",1,0,Nil,Nil,Nil,Nil,Nil,{"Preencha o campo ("+Alltrim(RetTitle("ZA_VEICULO"))+"), para depois imprimir o Ticket de Pesagem."})
		Return .F.
	EndIf
	
	If Empty(SZA->ZA_KMVEIC)
		Help(Nil,Nil,"RT05A002",Nil,"Não foi possivel imprimir o Ticket de Pesagem neste Momento.",1,0,Nil,Nil,Nil,Nil,Nil,{"Preencha o campo ("+Alltrim(RetTitle("ZA_KMVEIC"))+"), para depois imprimir o Ticket de Pesagem."})
		Return .F.
	EndIf
	
	If Empty(SZA->ZA_CARRETA)
		Help(Nil,Nil,"RT05A002",Nil,"Não foi possivel imprimir o Ticket de Pesagem neste Momento.",1,0,Nil,Nil,Nil,Nil,Nil,{"Preencha o campo ("+Alltrim(RetTitle("ZA_CARRETA"))+"), para depois imprimir o Ticket de Pesagem."})
		Return .F.
	EndIf
	
	If SZA->ZA_TXDOLAR <= 0
		Help(Nil,Nil,"RT05A002",Nil,"Não foi possivel imprimir o Ticket de Pesagem neste Momento.",1,0,Nil,Nil,Nil,Nil,Nil,{"Preencha o campo ("+Alltrim(RetTitle("ZA_TXDOLAR"))+"), para depois imprimir o Ticket de Pesagem."})
		Return .F.
	EndIf
	
	DbSelectArea("SZB")
	SZB->(DbSetOrder(1))
							
	If SZB->(DbSeek(FWXFilial("SZB")+SZA->ZA_COD))
		If SZB->ZB_QUANT <= 0
			Help(Nil,Nil,"RT05A002",Nil,"Não foi possivel Confirmar a Ordem de Carregamento neste Momento.",1,0,Nil,Nil,Nil,Nil,Nil,{"Preencha o campo ("+Alltrim(RetTitle("ZB_QUANT"))+"), para depois Confirmar a Ordem de Carregamento."})
			Return .F.
		EndIf 
		
		If SZB->ZB_VUNIT <= 0
			Help(Nil,Nil,"RT05A002",Nil,"Não foi possivel Confirmar a Ordem de Carregamento neste Momento.",1,0,Nil,Nil,Nil,Nil,Nil,{"Preencha o campo ("+Alltrim(RetTitle("ZB_VUNIT"))+"), para depois Confirmar a Ordem de Carregamento."})
			Return .F.
		EndIf 
	EndIf 
	
	cQuery := "SELECT "+QBLINHA 
	cQuery += "ZA_FILIAL FILIALZA "+QBLINHA
	cQuery += ", ZA_COD CODIGO "+QBLINHA
	cQuery += ", 'N' TIPO "+QBLINHA
	cQuery += ", ZA_CLIENTE CLIENTE "+QBLINHA
	cQuery += ", ZA_LOJA LOJA "+QBLINHA
	cQuery += ", ZA_TRANSP TRANSP "+QBLINHA
	cQuery += ", ZA_CONDPAG CONDPAG "+QBLINHA
	cQuery += ", ZA_NATUR NATUREZA "+QBLINHA
	cQuery += ", ZA_TPFRETE TPFRETE "+QBLINHA
	cQuery += ", DA3_PLACA PLACA "+QBLINHA
	cQuery += ", 1 VOLUME "+QBLINHA
	cQuery += ", 'CONTAINER' ESPECIE "+QBLINHA
	cQuery += ", ZA_MSGNOTA MSGNOTA "+QBLINHA
	cQuery += ", ZA_EMISSAO EMISSAO "+QBLINHA
	cQuery += ", ZA_PESOLIQ PESOLIQ "+QBLINHA
	cQuery += ", ZA_PESOBUT PESOBRUT "+QBLINHA
	cQuery += ", SZA.R_E_C_N_O_ IDSZA "+QBLINHA
	cQuery += ", ZB_FILIAL FILIALZB "+QBLINHA
	cQuery += ", ZB_ITEM ITEM "+QBLINHA
	cQuery += ", ZB_PRODUTO PROD "+QBLINHA
	cQuery += ", ZB_QUANT QUANT "+QBLINHA
	cQuery += ", ZB_VUNIT VUNIT "+QBLINHA
	cQuery += ", ZB_TES TES "+QBLINHA
	cQuery += ", ZB_DESC DESCPRO "+QBLINHA
	cQuery += ", ZB_UM UM "+QBLINHA
	
	cQuery += "FROM "
	cQuery +=  RetSqlName("SZA") + " SZA "+QBLINHA
	
	cQuery += "INNER JOIN  "
	cQuery +=  RetSqlName("SZB") + " SZB "+QBLINHA
	cQuery += "ON ZA_FILIAL = ZB_FILIAL "+QBLINHA
	cQuery += "AND ZA_COD = ZB_COD "+QBLINHA
	cQuery += "AND ZA_CLIENTE = ZB_CLIENTE "+QBLINHA
	cQuery += "AND ZA_LOJA = ZB_LOJA "+QBLINHA
	cQuery += "AND SZB.D_E_L_E_T_ = ' ' "+QBLINHA
	
	cQuery += "INNER JOIN  "
	cQuery +=  RetSqlName("DA3") + " DA3 "+QBLINHA
	cQuery += "ON ZA_VEICULO = DA3_COD "+QBLINHA
	cQuery += "AND DA3.D_E_L_E_T_ = ' ' "+QBLINHA 
	
	cQuery += "WHERE "+QBLINHA
	cQuery += "SZA.D_E_L_E_T_ = ' ' "+QBLINHA
	cQuery += "AND ZA_COD = '"+SZA->ZA_COD+"' "+QBLINHA
	
	If Select("TMP1") > 1 
		TMP1->(DBCloseArea())
	EndIf
	
	MEMOWRITE("C:/ricardo/RT05A002.sql",cQuery)			     
	cQuery := ChangeQuery(cQuery)
	DBUSEAREA(.T.,'TOPCONN',TcGenQry(,,cQuery),"TMP1",.F.,.T.)
		
	DBSELECTAREA("TMP1")
	TMP1->(DBGOTOP())
	COUNT To NQTREG
	TMP1->(DBGOTOP())
		
	If NQTREG <= 0
		TMP1->(DBCLOSEAREA())
		Return .F.
	Else
		While ! TMP1->(EOF())
			
			If nCont == 1
				
				cDoc 	:= GetSxeNum("SC5","C5_NUM")
				cOrdem 	:= Alltrim(TMP1->CODIGO)
				nRecSZA := TMP1->IDSZA
				
				aAdd(aCabec,{"C5_FILIAL" 	,FWXFilial("SC5")		,NIL})
				aadd(aCabec,{"C5_NUM"   	,cDoc					,Nil})
				aAdd(aCabec,{"C5_EMISSAO" 	,Date()					,NIL})
				aAdd(aCabec,{"C5_TIPO" 		,"N" 					,NIL})
				aAdd(aCabec,{"C5_CLIENTE" 	,Alltrim(TMP1->CLIENTE)	,NIL})
				aAdd(aCabec,{"C5_LOJACLI" 	,Alltrim(TMP1->LOJA) 	,NIL})
				AADD(aCabec,{"C5_TRANSP"	,Alltrim(TMP1->TRANSP) 	,Nil}) 
				aAdd(aCabec,{"C5_CONDPAG" 	,Alltrim(TMP1->CONDPAG)	,NIL})
				aAdd(aCabec,{"C5_XMENNFE" 	,Alltrim(cMsg)			,NIL})
				aAdd(aCabec,{"C5_VOLUME1" 	,TMP1->VOLUME			,NIL})
				aAdd(aCabec,{"C5_ESPECI1" 	,AllTrim(TMP1->ESPECIE)	,NIL})
				aAdd(aCabec,{"C5_VEND1" 	,AllTrim(cVendPad)		,NIL})
				AADD(aCabec,{"C5_PESOL"  	,TMP1->PESOLIQ			,Nil}) 
				AADD(aCabec,{"C5_PBRUTO" 	,TMP1->PESOBRUT			,Nil})
				AADD(aCabec,{"C5_TPCARGA"	,"2"					,Nil}) 
				AADD(aCabec,{"C5_TPFRETE"	,TMP1->TPFRETE			,Nil})
				AADD(aCabec,{"C5_NATUREZ"	,Alltrim(TMP1->NATUREZA),Nil}) 
				
			EndIf
			
			cArmz := Posicione("SB1",1,FWXFilial("SB1")+Alltrim(TMP1->PROD),"B1_LOCPAD")
			
			AADD(aLinha,{"C6_FILIAL"	,FWXFilial("SC6") 		,NIL})
			AADD(aLinha,{"C6_ITEM" 		,Alltrim(TMP1->ITEM) 	,NIL})
			AADD(aLinha,{"C6_PRODUTO" 	,Alltrim(TMP1->PROD)  	,NIL})
			AADD(aLinha,{"C6_DESCRI" 	,Alltrim(TMP1->DESCPRO)	,NIL})
			AADD(aLinha,{"C6_UM" 		,Alltrim(TMP1->UM)  	,NIL})
			AADD(aLinha,{"C6_LOCAL" 	,Alltrim(cArmz)  		,NIL})
			AADD(aLinha,{"C6_QTDVEN" 	,TMP1->QUANT			,NIL})
			AADD(aLinha,{"C6_PRCVEN" 	,TMP1->VUNIT			,NIL})
			AADD(aLinha,{"C6_TES" 		,AllTrim(TMP1->TES)		,NIL})

			AADD(aItens,aLinha)
			
			TMP1->(DbSkip())
			nCont++
		End
		TMP1->(DBCLOSEAREA())
	EndIf 
	
	If Len(aCabec) > 0 .and. Len(aItens) > 0
		FWMsgRun(,{|oSay| EXEC_FAT(oSay,cOrdem,nRecSZA)},"Faturamento da Ordem de Carregamento", "Gerando Pedido de Venda...")
	Else
		MsgAlert("Erro ao Buscar a Ordem de Carregamento para Faturamento.","Atenção")
		Return
	EndIf
	
	RestArea(aArea)
	RestArea(aAreaSB1)       
	RestArea(aAreaSZA)
	RestArea(aAreaSC5)
	RestArea(aAreaSC6)
	RestArea(aAreaSD2)
	RestArea(aAreaSF2)
	
Return

/*/{Protheus.doc} EXEC_FAT 
Funçao responsavel por incluir o pedido de venda e fazer seu faturamento automatico
@author 	Ricardo Tavares Ferreira
@since 		24/07/2018
@version 	12.1.17
@return 	Nulo
@Obs 		Ricardo Tavares - Construcao Inicial
/*/
//==========================================================================================================
	Static Function EXEC_FAT(oSay,cOrdem,nRecSZA)
//==========================================================================================================
	
	Local cCodPed 	:= ""
	Local lGeraNf 	:= .T.
	Local lFatAuto	:= .T.
	Local cQuery	:= ""
	Local QBLINHA	:= chr(13)+chr(10)
	Local NQTREG	:= 0
	
	Default cOrdem 	:= ""
	Default oSay	:= Nil
	Default nRecSZA	:= 0
	
	MSExecAuto({|x,y,z|Mata410(x,y,z)},aCabec,aItens,3)
	
	DbSelectarea("SC5")
	DbSelectarea("SZA")
	cCodPed := aCabec[2][2]
	
	If lMsErroAuto	
		MostraErro()
		lGeraNf := .F. //Nao gera nota fiscal automaticamente
		Return
	Endif
	
	If lGeraNf
		oSay:cCaption := ("Liberando Pedido de Venda...")
		SC5->(DbSetOrder(1))
		If SC5->(DbSeek(FWXFilial("SC5") + cCodPed))
			Reclock("SC5",.F.)
				SC5->C5_XORDCAR := cOrdem
			SC5->(MsUnlock())
		EndIf
		
		SC5->(DBSetOrder(1))
		If SC5->(MsSeek(FWXFilial("SC5") + cCodPed))
			DbSelectarea("SC6")
			SC6->(DBSetOrder(1))
			If SC6->(MsSeek(FWXFilial("SC6") + cCodPed))
				Begin Transaction
					While !SC6->(EOF()) .and. SC6->C6_NUM == cCodPed
					
						SC6->(MaLibDoFat(SC6->(RecNo()),SC6->C6_QTDVEN,.T.,.F.,.T.,.T.,.F.,.T.))
						SC6->(MaLiberOk({cCodPed},.T.))
					
						SC6->(DbSkip())
					Enddo
				End Transaction
			EndIf
		Endif

		SC6->(DbCloseArea())
		SC5->(MaLiberOk({cCodPed},.T.)) //Confirmar pedido como Aprovado se nao houver restricao por credito ou estoque								
		SC5->(DBCloseArea())	
		
		cQuery := "SELECT "+QBLINHA 
		cQuery += "C9_FILIAL "+QBLINHA
		cQuery += ", C9_PEDIDO "+QBLINHA
		cQuery += ", C9_PRODUTO "+QBLINHA
		cQuery += ", C9_CLIENTE "+QBLINHA
		cQuery += ", C9_LOJA "+QBLINHA
		cQuery += ", C9_BLEST "+QBLINHA
		cQuery += ", C9_BLCRED "+QBLINHA 

		cQuery += "FROM "
		cQuery +=  RetSqlName("SC9") + " SC9 "+QBLINHA
		
		cQuery += "WHERE "+QBLINHA    
		cQuery += "D_E_L_E_T_ = ' ' "+QBLINHA
		cQuery += "AND C9_FILIAL = '"+ FWXFilial("SC9") +"' "+QBLINHA
		cQuery += "AND C9_PEDIDO = '"+ cCodPed +"' "+QBLINHA 
		cQuery += "AND C9_BLEST  <> ' ' "+QBLINHA 
		cQuery += "AND C9_BLCRED <> ' ' "+QBLINHA
		cQuery += "ORDER BY C9_PRODUTO  "+QBLINHA
		
		If Select("TMP1") > 1								   
			TMP1->(DbCloseArea())								
		Endif

		MEMOWRITE("C:/ricardo/EXEC_FAT_SC9.sql",cQuery)			     
		cQuery := ChangeQuery(cQuery)
		DBUSEAREA(.T.,'TOPCONN',TcGenQry(,,cQuery),"TMP1",.F.,.T.)
			
		DBSELECTAREA("TMP1")
		TMP1->(DBGOTOP())
		COUNT To NQTREG
		TMP1->(DBGOTOP())
			
		If NQTREG > 0
			TMP1->(DBCLOSEAREA())
			lFatAuto := .F.
			MsgAlert("O pedido "+cCodPed+", está com restrições de estoque ou crédito, a Nota Fiscal desta ordem de carregamento não será gerado automaticamente","Atenção")
		Else
			TMP1->(DBCLOSEAREA())
		EndIf
		
		If lFatAuto
			oSay:cCaption := ("Faturando Pedido de Venda...")
			FAT_PED(oSay,cCodPed,cOrdem,nRecSZA)
		EndIf
	EndIf
	
Return

/*/{Protheus.doc} FAT_PED
Funçao que realiza o Faturamento Automatico do Pedido de Venda.
@author 	Ricardo Tavares Ferreira
@since 		26/07/2018
@version 	12.1.17
@return 	Nulo
@Obs 		Ricardo Tavares - Construcao Inicial
/*/
//==========================================================================================================
	Static Function FAT_PED(oSay,cCodPed,cOrdem,nRecSZA)
//==========================================================================================================

	Local aPvlNfs 	:= {}
	Local cFilPed  	:= ""
	Local cSerie  	:= GetMV("MV_SERIE")
	Local cQuery	:= ""
	Local QBLINHA	:= chr(13)+chr(10)
	Local NQTREG	:= 0
	Local NQTREG2	:= 0
	Local cTipoCli 	:= ""

	Default cOrdem 	:= ""
	Default oSay	:= Nil
	Default cCodPed	:= ""
	Default nRecSZA	:= 0
	
	cFilPed  := xFilial("SC5")
	
	DbSelectArea("SC5")
	SC5->( DbSetOrder(1))
	
	If SC5->(DbSeek(FWXFilial("SC5")+cCodPed))
	
		//chama evento de liberacao de regras com o SC5 posicionado
		Begin Transaction
			MaAvalSC5("SC5",9)
		End Transaction
		
		MaLiberOk({SC5->C5_NUM},.T.)
		
		DbSelectArea("SC6")
		SC6->(DbSetOrder(1))
		
		If SC6->(DbSeek(SC5->(C5_FILIAL+C5_NUM)))
			While !SC6->(Eof()) .AND. SC6->C6_NUM == SC5->C5_NUM .AND. SC5->C5_FILIAL == SC6->C6_FILIAL
				
				DbSelectArea("SC9")
				SC9->(DbSetOrder(1))
				SC9->(DbGotop())
				
				If !SC9->(DbSeek(SC6->(C6_FILIAL+C6_NUM+C6_ITEM)))  	//Array para geracao da NF (SC6,SE4,SB1,SB2,SF4) devem estar posicionados
					
					MaLibDoFat(SC6->(RecNo()),SC6->C6_QTDVEN,.T.,.T.)	     //Libera os itens do pedido para faturar
					
					DbSelectArea("SC9")
					SC9->(DbSetOrder(1))
					SC9->(DbGotop())
					
					If !SC9->(DbSeek(SC6->(C6_FILIAL+C6_NUM+C6_ITEM)))
						DisarmTransaction()
						Return .F.	
					EndIf
				EndIf
				SC6->(DbSkip())
			EndDo
		EndIf
		
		SC9->(DbSetOrder(1))
		SC9->(DbGotop())
		SC9->(DbSeek(cFilPed+cCodPed))
		
		While !Eof() .And. SC9->C9_PEDIDO == cCodPed .And. SC9->C9_FILIAL == cFilPed
	
			DbSelectArea("SC6")
			SC6->(DbSetOrder(1))
			SC6->(DbSeek(FWXFilial("SC6") + SC9->C9_PEDIDO + SC9->C9_ITEM))
			
			DbSelectArea("SB1")
			SB1->(DbSetOrder(1))
			SB1->(DbSeek(FWXFilial("SB1") + SC9->C9_PRODUTO))
			
			DbSelectArea("SF4")
			SF4->(DbSetOrder(1))
			SF4->(DbSeek(FWXFilial("SF4") + SC6->C6_TES))
			
			DbSelectArea("SB2")
			SB2->(DbSetOrder(1))
			SB2->(DbSeek(FWXFilial("SB2") + SC9->C9_PRODUTO))
			
			DbSelectArea("SC9")
			aAdd(aPvlNfs, {SC9->C9_PEDIDO,;
			 			   SC9->C9_ITEM,;
			               SC9->C9_SEQUEN,;
			               SC9->C9_QTDLIB,;
						   SC9->C9_PRCVEN,;
						   SC9->C9_PRODUTO,;
						   .F.,;
						   SC9->(RecNo()),;
						   SC5->(RecNo()),; 
						   SC6->(RecNo()),;
						   SE4->(RecNo()),;
						   SB1->(RecNo()),;
						   SB2->(RecNo()),;
						   SF4->(RecNo())})
			
			SC9->(DbSkip())
		Enddo
		
		If Len(aPvlNfs) > 0
			
			cTipoCli := Posicione("SA1",1,FWXFilial("SA1")+Alltrim(SZA->ZA_CLIENTE)+Alltrim(SZA->ZA_LOJA),"A1_TIPO") 
			cNumNF	 := Posicione("SX5",1,FWXFilial("SX5")+"01"+cSerie,"X5_DESCRI")   

			If Alltrim(cTipoCli) == "X"
				cQuery := "SELECT "+QBLINHA
				cQuery += "CDL_DOC NF "+QBLINHA
				cQuery += ", CDL_SERIE SERIE "+QBLINHA
				cQuery += ", CDL_CLIENT CLIENTE "+QBLINHA
				cQuery += ", CDL_LOJA LOJA "+QBLINHA
				cQuery += ", CDL_UFEMB UFEMB "+QBLINHA
				cQuery += ", CDL_LOCEMB LOCEMB "+QBLINHA
				cQuery += ", CDL_ITEMNF ITEMNF "+QBLINHA
				cQuery += ", CDL_PRODNF PRODUTO "+QBLINHA
				cQuery += ", CDL_SDOC SDOC "+QBLINHA
				cQuery += ", CDL.R_E_C_N_O_ IDCDL "+QBLINHA
				cQuery += "FROM "
				cQuery +=  RetSqlName("CDL") + " CDL "+QBLINHA
				cQuery += "WHERE "+QBLINHA
				cQuery += "CDL.D_E_L_E_T_ = ' ' "+QBLINHA
				cQuery += "AND CDL_FILIAL = '"+FWXFilial("CDL")+"' "+QBLINHA
				cQuery += "AND CDL_DOC = '"+Alltrim(cNumNF)+"' "+QBLINHA
				cQuery += "AND CDL_SERIE = '"+Alltrim(cSerie)+"' "+QBLINHA
				cQuery += "AND CDL_CLIENT = '"+Alltrim(SZA->ZA_CLIENTE)+"' "+QBLINHA
				cQuery += "AND CDL_LOJA = '"+Alltrim(SZA->ZA_LOJA)+"' "+QBLINHA
	
				If Select("TMP1") > 0								   
					TMP1->(DbCloseArea())								
				Endif
	
				MEMOWRITE("C:/ricardo/EXEC_CDL.sql",cQuery)			     
				cQuery := ChangeQuery(cQuery)
				DBUSEAREA(.T.,'TOPCONN',TcGenQry(,,cQuery),"TMP1",.F.,.T.)
					
				DBSELECTAREA("TMP1")
				TMP1->(DBGOTOP())
				COUNT To NQTREG
				TMP1->(DBGOTOP())
	
				DbSelectArea("CDL")
				CDL->(DbSetOrder(1))
					
				If NQTREG > 0
					While !TMP1->(EOF())
	
						CDL->(DBGOTO(TMP1->IDCDL))
	
						Reclock("CDL",.F.)
							CDL_FILIAL		:= FWXFilial("CDL")
							CDL->CDL_DOC 	:= TMP1->NF
							CDL->CDL_SERIE 	:= TMP1->SERIE
							CDL->CDL_ESPEC	:= "SPED"
							CDL->CDL_CLIENT	:= TMP1->CLIENTE
							CDL->CDL_LOJA	:= TMP1->LOJA
							CDL->CDL_UFEMB	:= TMP1->UFEMB
							CDL->CDL_LOCEMB	:= TMP1->LOCEMB
							CDL->CDL_ITEMNF	:= TMP1->ITEMNF
							CDL->CDL_PRODNF	:= TMP1->PRODUTO
							CDL->CDL_SDOC	:= TMP1->SDOC
						CDL->(MsUnlock()) 
						TMP1->(DbSkip())
					End
					TMP1->(DBCLOSEAREA())
				Else
				
					cQuery := "SELECT "+QBLINHA 
					cQuery += "ZA_FILIAL		FILIAL "+QBLINHA 	
					cQuery += ", ZA_NF 			DOC  "+QBLINHA 		
					cQuery += ", ZA_SERIE 		SERIE  "+QBLINHA 	
					cQuery += ", ZA_CLIENTE		CLIENTE "+QBLINHA 	
					cQuery += ", ZA_LOJA		LOJA "+QBLINHA 		
					cQuery += ", ZA_ESTEMB		UFEMB "+QBLINHA 	
					cQuery += ", ZA_LCEMB		LOCEMB "+QBLINHA 	
					cQuery += ", ZB_ITEM		ITEMNF "+QBLINHA 	
					cQuery += ", ZB_PRODUTO		PRODNF "+QBLINHA 	
						
					cQuery += "FROM "
					cQuery +=  RetSqlName("SZA") + " SZA "+QBLINHA
	
					cQuery += "INNER JOIN "
					cQuery +=  RetSqlName("SZB") + " SZB "+QBLINHA
					cQuery += "ON ZA_FILIAL = ZB_FILIAL "+QBLINHA 
					cQuery += "AND ZA_COD = ZB_COD "+QBLINHA 
					cQuery += "AND ZA_CLIENTE = ZB_CLIENTE "+QBLINHA 
					cQuery += "AND ZA_LOJA = ZB_LOJA "+QBLINHA 
					cQuery += "AND SZB.D_E_L_E_T_ = ' '  "+QBLINHA 
	
					cQuery += "WHERE "+QBLINHA 
					cQuery += "SZA.D_E_L_E_T_ = ' ' "+QBLINHA 
					cQuery += "AND ZA_FILIAL = '"+FWXFilial("SZA")+"' "+QBLINHA 
					cQuery += "AND ZA_COD = '"+Alltrim(SZA->ZA_COD)+"' "+QBLINHA 
					cQuery += "AND ZA_CLIENTE = '"+Alltrim(SZA->ZA_CLIENTE)+"' "+QBLINHA 
					cQuery += "AND ZA_LOJA = '"+Alltrim(SZA->ZA_LOJA)+"' "+QBLINHA 
	
					If Select("TMP2") > 0								   
						TMP2->(DbCloseArea())								
					Endif
	
					MEMOWRITE("C:/ricardo/EXEC_SZA.sql",cQuery)			     
					cQuery := ChangeQuery(cQuery)
					DBUSEAREA(.T.,'TOPCONN',TcGenQry(,,cQuery),"TMP2",.F.,.T.)
						
					DBSELECTAREA("TMP2")
					TMP2->(DBGOTOP())
					COUNT To NQTREG2
					TMP2->(DBGOTOP())
						
					If NQTREG2 > 0
	
						While !TMP2->(EOF())
							Reclock("CDL",.T.)
								CDL_FILIAL		:= FWXFilial("CDL")
								CDL->CDL_DOC 	:= cNumNF
								CDL->CDL_SERIE 	:= cSerie
								CDL->CDL_ESPEC	:= "SPED"
								CDL->CDL_CLIENT	:= TMP2->CLIENTE
								CDL->CDL_LOJA	:= TMP2->LOJA
								CDL->CDL_UFEMB	:= TMP2->UFEMB
								CDL->CDL_LOCEMB	:= TMP2->LOCEMB
								CDL->CDL_ITEMNF	:= TMP2->ITEMNF
								CDL->CDL_PRODNF	:= TMP2->PRODNF
								CDL->CDL_SDOC	:= cSerie
							CDL->(MsUnlock()) 
							TMP2->(DbSkip())
						End
						TMP2->(DBCLOSEAREA())
					EndIf
				Endif
			EndIf
		
			Pergunte("MT460A",.F.)
			MV_PAR17 := 1 //Gera Titulo ? 
			MV_PAR24 := 1 //Gera Guia ICM Compl. UF Dest ? 
			
			cNota := MaPvlNfs(aPvlNfs,cSerie ,.F.,.T.,.T.,.T.,.F.,0,0,.F.,.F.)
			
			aPvlNfs := {}
			
			If !Empty(cNota) 
				SZA->(DbSetOrder(1))
				SZA->(DbGOTO(nRecSZA))
				Reclock("SZA",.F.)
					SZA->ZA_PEDIDO 	:= cCodPed
					//SZA->ZA_STATUS 	:= "4"
					SZA->ZA_NF		:= cNota
					SZA->ZA_SERIE	:= cSerie
				SZA->(MsUnlock()) 
			Else
				MsgAlert("O pedido não foi Faturado, por este motivo a Nota Fiscal nao foi gerada.","Atenção")
			EndIf
		EndIf
	EndIf
	
	DBCOMMITALL()  	
Return

/*/{Protheus.doc} RT05A002E
Funçao que realiza a Reabertura da Ordem de Carregamento.
@author 	Ricardo Tavares Ferreira
@since 		21/07/2018
@version 	12.1.17
@return 	Nulo
@Obs 		Ricardo Tavares - Construcao Inicial
/*/
//==========================================================================================================
	Static Function RT05A002E()
//==========================================================================================================

	FWMsgRun(,{|oSay| EST_PED(oSay)},"Reabertura da Ordem de Carregamento","Reabrindo Ordem de Carregamento...")
	
Return

/*/{Protheus.doc} RT05A002E
Funçao que realiza o Estorno da Nota Fiscal de Saida e Exclusao do Pedido de Venda.
@author 	Ricardo Tavares Ferreira
@since 		21/07/2018
@version 	12.1.17
@return 	Nulo
@Obs 		Ricardo Tavares - Construcao Inicial
/*/
//==========================================================================================================
	Static Function EST_PED(oSay)
//==========================================================================================================

	Local aArea			:= GetArea()
	Local cMarca 		:= ""
	Local lExcNF		:= .F.
	Local lExcRec	 	:= .F.  
	Local cQuery		:= ""
	Local QBLINHA		:= chr(13)+chr(10)
	Local nCont			:= 1
	Local nRecSZA		:= 0
	Local nReg			:= 0
	
	Default oSay		:= Nil
	
	//If SZA->ZA_STATUS == "5" .and. .not. Empty(SZA->ZA_PEDIDO) .and. .not. Empty(SZA->ZA_NF) .and. .not. Empty(SZA->ZA_SERIE)
	//	Help(Nil,Nil,"RT05A002",Nil,"Esta Ordem de Carregamento já foi Encerrada.",1,0,Nil,Nil,Nil,Nil,Nil,{"Selecione uma Ordem de Carregamento que esteja com o Status [Ordem Faturada]."})
	//	Return .F.
	//EndIf
	
	If SZA->ZA_STATUS $ "1/2/3" 
		Help(Nil,Nil,"RT05A002",Nil,"Esta Ordem de Carregamento não pode ser Reaberta.",1,0,Nil,Nil,Nil,Nil,Nil,{"Selecione uma Ordem de Carregamento que esteja com o Status [Ordem Faturada]."})
		Return .F.
	EndIf
	
	cQuery := "SELECT SF2.R_E_C_N_O_ IDSF2 "+QBLINHA 
	cQuery += "FROM "
	cQuery +=  RetSqlName("SF2") + " SF2 "+QBLINHA
	cQuery += "WHERE "+QBLINHA
	cQuery += "SF2.D_E_L_E_T_ = ' ' "+QBLINHA 
	cQuery += "AND F2_FILIAL = '"+FWXFilial("SF2")+"' "+QBLINHA
	cQuery += "AND F2_DOC = '"+Alltrim(SZA->ZA_NF)+"' "+QBLINHA
	cQuery += "AND F2_SERIE = '"+Alltrim(SZA->ZA_SERIE)+"' "+QBLINHA
	cQuery += "AND F2_CLIENTE = '"+Alltrim(SZA->ZA_CLIENTE)+"' "+QBLINHA
	cQuery += "AND F2_LOJA = '"+Alltrim(SZA->ZA_LOJA)+"' "+QBLINHA
	
	If Select("TMP2") > 1								   
		TMP1->(DbCloseArea())								
	Endif
		
	MEMOWRITE("C:/ricardo/EST_PED.sql",cQuery)			     
	cQuery := ChangeQuery(cQuery)
	DBUSEAREA(.T.,'TOPCONN',TcGenQry(,,cQuery),"TMP2",.F.,.T.)
			
	DBSELECTAREA("TMP2")
	TMP2->(DBGOTOP())
	COUNT To nReg
	TMP2->(DBGOTOP())
			
	If nReg <= 0
		TMP2->(DBCLOSEAREA())
		Return .F.
	Else
		oSay:cCaption := ("Estornando Nota Fiscal de Saida...")
		cMarca := GetMark(.F.,"SF2","F2_OK")
		
		DbSelectArea("SF2")
		SF2->(DbSetOrder(1))
		SF2->(DbGoTo(TMP2->IDSF2))
		
		RecLock("SF2",.F.)
			SF2->F2_OK := cMarca
		SF2->(MsUnlock())
		
		lOk := MATA521A(.T.,"SF2",cMarca,1,.F.,.F.,.F.)
		
		If lOk
			lExcNF	:= .T.
		EndIf
		TMP2->(DBCLOSEAREA())
	EndIF
	
	If lExcNF
		
		cQuery := "SELECT SC9.R_E_C_N_O_ IDSC9"+QbLinha
		cQuery += "FROM "
		cQuery +=  RetSqlName("SC9") + " SC9 "+QBLINHA
		cQuery += "WHERE"+QbLinha 
		cQuery += "SC9.D_E_L_E_T_ = ' '"+QbLinha
		cQuery += "AND C9_PEDIDO = '"+SZA->ZA_PEDIDO+"'"+QbLinha
		
		If Select("TMP2") > 1								   
			TMP2->(DBCLOSEAREA())								
		Endif
		
		MEMOWRITE("C:/ricardo/RT05A002E_C9.sql",cQuery)			     
		cQuery := ChangeQuery(cQuery)
		DBUSEAREA(.T.,'TOPCONN',TcGenQry(,,cQuery),"TMP2",.F.,.T.)
			
		DBSELECTAREA("TMP2")
		TMP2->(DBGOTOP())
		COUNT To NQTREG
		TMP2->(DBGOTOP())
			
		If NQTREG <= 0
			TMP2->(DBCLOSEAREA())
		Else
			DBSELECTAREA("SC9")
			SC9->(DBSETORDER(1))
			
			While ! TMP2->(EOF())
				SC9->(DBGOTO(TMP2->IDSC9))
				RECLOCK("SC9",.F.)
					SC9->(DBDELETE())
				SC9->(MSUNLOCK())
				TMP2->(DBSKIP())
			End
			TMP2->(DBCLOSEAREA())
		EndIf
		
		cQuery := "SELECT  "+QbLinha 
	    cQuery += "SC5.R_E_C_N_O_ IDSC5 "+QbLinha
	    cQuery += ", SC6.R_E_C_N_O_ IDSC6 "+QbLinha
	    cQuery += ", SZA.R_E_C_N_O_ IDSZA "+QbLinha
	    
	    cQuery += "FROM "
		cQuery +=  RetSqlName("SC5") + " SC5 "+QBLINHA

		cQuery += "INNER JOIN "
		cQuery +=  RetSqlName("SC6") + " SC6 "+QBLINHA
	    cQuery += "ON C6_FILIAL = C5_FILIAL "+QbLinha 
	    cQuery += "AND C6_NUM = C5_NUM "+QbLinha 
	    cQuery += "AND C6_CLI = C5_CLIENTE "+QbLinha 
	    cQuery += "AND C6_LOJA = C5_LOJACLI "+QbLinha 
	    cQuery += "AND SC6.D_E_L_E_T_ = ' '  "+QbLinha 
	    
	    cQuery += "INNER JOIN "
		cQuery +=  RetSqlName("SZA") + " SZA "+QBLINHA
		cQuery += "ON ZA_PEDIDO = C5_NUM "+QbLinha
		cQuery += "AND ZA_CLIENTE = C5_CLIENTE "+QbLinha
		cQuery += "AND ZA_LOJA = C5_LOJACLI "+QbLinha
		cQuery += "AND SZA.D_E_L_E_T_ = ' ' "+QbLinha 
	    
	    cQuery += "WHERE "+QbLinha 
	    cQuery += "SC5.D_E_L_E_T_ = ' '  "+QbLinha 
	    cQuery += "AND C5_NUM = '"+SZA->ZA_PEDIDO+"' "+QbLinha 
	    
	    If Select("TMP1") > 1								   
			TMP1->(DbCloseArea())								
		Endif
		
		MEMOWRITE("C:/ricardo/RT05A002E.sql",cQuery)			     
		cQuery := ChangeQuery(cQuery)
		DBUSEAREA(.T.,'TOPCONN',TcGenQry(,,cQuery),"TMP1",.F.,.T.)
			
		DBSELECTAREA("TMP1")
		TMP1->(DBGOTOP())
		COUNT To NQTREG
		TMP1->(DBGOTOP())
			
		If NQTREG <= 0
			TMP1->(DBCLOSEAREA())
			Return .F.
		Else
			While ! TMP1->(EOF())
				
				lExcRec := .T.
				DBSELECTAREA("SC5")
				SC5->(DBSETORDER(1))
				
				DBSELECTAREA("SC6")
				SC6->(DBSETORDER(1))
				
				BEGIN TRANSACTION
				
				If nCont == 1
					nRecSZA := TMP1->IDSZA
					
					SC5->(DBGOTO(TMP1->IDSC5))
					RECLOCK("SC5",.F.)
						SC5->(DBDELETE())
					SC5->(MSUNLOCK())
				EndIf
				
				SC6->(DBGOTO(TMP1->IDSC6))
				RECLOCK("SC6",.F.)
					SC6->(DBDELETE())
				SC6->(MSUNLOCK())
					
				END TRANSACTION
				
				TMP1->(DbSkip())
				nCont++
			End
			TMP1->(DBCLOSEAREA())
		EndIf 
		
		If lExcRec
			DbSelectArea("SZA")
			SZA->(DbSetOrder(1))
			SZA->(DbGOTO(nRecSZA))
			Reclock("SZA",.F.)
				SZA->ZA_PEDIDO 	:= ""
				SZA->ZA_STATUS 	:= "3"
				SZA->ZA_NF		:= ""
				SZA->ZA_SERIE	:= ""
			SZA->(MsUnlock()) 
		Else
			MsgAlert("Erro ao Buscar os Dados do Pedido de Venda para Exclusao.","Atenção")
			Return
		EndIf
	EndIf
	
	RestArea(aArea)
	
Return .T.

/*/{Protheus.doc} RT05A002F
Funçao que cria o botao de 2° Pesagem no Browse.
@author 	Ricardo Tavares Ferreira
@since 		20/07/2018
@version 	12.1.17
@return 	Nulo
@Obs 		Ricardo Tavares - Construcao Inicial
/*/
//==========================================================================================================
	Static Function RT05A002F()
//==========================================================================================================
	
	Local oView		:= FwViewActive()
	Local oModel	:= FWModelActive()
	Local aArea		:= GetArea()
	Local lRet		:= .T.
	
	DbSelectArea("SZA")
	SZA->(DbSetOrder(1))
	
	If SZA->(DbSeek(FWXFilial("SZA")+SZA->ZA_COD))
		
		oModel := FWLoadModel("RT05A002")
		
		oModel:SetOperation(MODEL_OPERATION_UPDATE)
		oModel:Activate()
		
		RT05A002C(oModel,"BROW2")
		
		oModel:DeActivate()
	Else
		lRet:= .F.
		Help(Nil,Nil,"RT05A002",Nil,"Ordem de Carregamento não Encontrada",1,0,Nil,Nil,Nil,Nil,Nil,{"Selecione uma Ordem de Carregamento Cadastrada."})
	EndIf
	
	RestArea(aArea)
	
Return lRet

/*/{Protheus.doc} RT05A002G
Funçao que imprime o ticket de Pesagem.
@author 	Ricardo Tavares Ferreira
@since 		22/07/2018
@version 	12.1.17
@return 	Nulo
@Obs 		Ricardo Tavares - Construcao Inicial
/*/
//==========================================================================================================
	Static Function RT05A002G()
//==========================================================================================================
	
	If SZA->ZA_STATUS $ "1/2" .or. SZA->ZA_PESO1 <= 0 .or. SZA->ZA_PESO2 <= 0
		Help(Nil,Nil,"RT05A002",Nil,"Não foi possivel imprimir o Ticket de Pesagem neste Momento.",1,0,Nil,Nil,Nil,Nil,Nil,{"Realize Todas as Pesagens para que Seja Possivel Imprimir o Ticket de Pesagem."})
		Return .F.
	EndIf
	
	If Empty(SZA->ZA_TRANSP)
		Help(Nil,Nil,"RT05A002",Nil,"Não foi possivel imprimir o Ticket de Pesagem neste Momento.",1,0,Nil,Nil,Nil,Nil,Nil,{"Preencha o campo ("+Alltrim(RetTitle("ZA_TRANSP"))+"), para depois imprimir o Ticket de Pesagem."})
		Return .F.
	EndIf
	
	If Empty(SZA->ZA_MOTORI)
		Help(Nil,Nil,"RT05A002",Nil,"Não foi possivel imprimir o Ticket de Pesagem neste Momento.",1,0,Nil,Nil,Nil,Nil,Nil,{"Preencha o campo ("+Alltrim(RetTitle("ZA_MOTORI"))+"), para depois imprimir o Ticket de Pesagem."})
		Return .F.
	EndIf
	
	If Empty(SZA->ZA_VEICULO)
		Help(Nil,Nil,"RT05A002",Nil,"Não foi possivel imprimir o Ticket de Pesagem neste Momento.",1,0,Nil,Nil,Nil,Nil,Nil,{"Preencha o campo ("+Alltrim(RetTitle("ZA_VEICULO"))+"), para depois imprimir o Ticket de Pesagem."})
		Return .F.
	EndIf
	
	If Empty(SZA->ZA_KMVEIC)
		Help(Nil,Nil,"RT05A002",Nil,"Não foi possivel imprimir o Ticket de Pesagem neste Momento.",1,0,Nil,Nil,Nil,Nil,Nil,{"Preencha o campo ("+Alltrim(RetTitle("ZA_KMVEIC"))+"), para depois imprimir o Ticket de Pesagem."})
		Return .F.
	EndIf
	
	If Empty(SZA->ZA_CARRETA)
		Help(Nil,Nil,"RT05A002",Nil,"Não foi possivel imprimir o Ticket de Pesagem neste Momento.",1,0,Nil,Nil,Nil,Nil,Nil,{"Preencha o campo ("+Alltrim(RetTitle("ZA_CARRETA"))+"), para depois imprimir o Ticket de Pesagem."})
		Return .F.
	EndIf
	
	If SZA->ZA_TXDOLAR <= 0
		Help(Nil,Nil,"RT05A002",Nil,"Não foi possivel imprimir o Ticket de Pesagem neste Momento.",1,0,Nil,Nil,Nil,Nil,Nil,{"Preencha o campo ("+Alltrim(RetTitle("ZA_TXDOLAR"))+"), para depois imprimir o Ticket de Pesagem."})
		Return .F.
	EndIf
	
	DbSelectArea("SZB")
	SZB->(DbSetOrder(1))
							
	If SZB->(DbSeek(FWXFilial("SZB")+SZA->ZA_COD))
		If SZB->ZB_QUANT <= 0
			Help(Nil,Nil,"RT05A002",Nil,"Não foi possivel imprimir o Ticket de Pesagem neste Momento.",1,0,Nil,Nil,Nil,Nil,Nil,{"Preencha o campo ("+Alltrim(RetTitle("ZB_QUANT"))+"), para depois imprimir o Ticket de Pesagem."})
			Return .F.
		EndIf 
	EndIf 
	
	If GET_DADOS()
		FWMsgRun(,{|oSay| IMP_REL(oSay)},"Impressão do Ticket de Pesagem","Imprimindo Ticket de Pesagem...")
		TMP1->(DbCloseArea())
	Else
		MsgAlert("Não foi Possivel Imprimir o Relatorio de Ticket de Pesagem.","Atenção")		
	EndIf
Return

/*/{Protheus.doc} IMP_REL
Funçao que cria o Html para impressao do ticket de Pesagem.
@author 	Ricardo Tavares Ferreira
@since 		22/07/2018
@version 	12.1.17
@return 	Nulo
@Obs 		Ricardo Tavares - Construcao Inicial
/*/
//==========================================================================================================
	Static Function IMP_REL()
//==========================================================================================================
	
	Local cDirDocs	:= ""
	Local cArq		:= "RT05A002.html"
	Local nHandle	:= ''
	Local QBLINHA	:= chr(13)+chr(10)
	Local cPathTmp	:= ""
	Local cNomeEmp	:= ""
	Local cEndEmp	:= ""
	Local cCepEmp	:= ""
	Local cCidEmp	:= ""
	Local cCICEmp	:= ""
	Local cIEEmp	:= ""
	Local cCodFil	:= ""
	Local cNomeFil	:= ""
	Local cBaiEmp	:= ""
	Local cTelEmp	:= ""
	Local cEmpresa	:= Substr(CNUMEMP,1,2)
	Local cPlacaVei	:= ""
	Local cEstVei	:= ""
	Local cMunVei	:= ""
	Local cPlacaCar	:= ""
	Local cEstCar	:= ""
	Local cMunCar	:= ""
	Local cRespImp	:= ""
	Local cLacreArm	:= ""
	
	cDirDocs := MsDocPath()
	
	If File(cDirDocs+"\"+cArq)
		FErase(cDirDocs+"\"+cArq)
	EndIf    
	
	nHandle := FCreate(cDirDocs+"\"+cArq,0) 
	
	cNomeEmp	:= Alltrim(Posicione("SM0",1,cEmpresa+TMP1->FILIAL,"M0_NOMECOM"))
	cCodFil		:= Alltrim(Posicione("SM0",1,cEmpresa+TMP1->FILIAL,"M0_CODFIL"))
	cNomeFil	:= Alltrim(Posicione("SM0",1,cEmpresa+TMP1->FILIAL,"M0_FILIAL"))
	cEndEmp		:= Alltrim(Posicione("SM0",1,cEmpresa+TMP1->FILIAL,"M0_ENDCOB"))
	cCidEmp		:= Alltrim(Posicione("SM0",1,cEmpresa+TMP1->FILIAL,"M0_CIDCOB") +"/"+ Posicione("SM0",1,cEmpresa+TMP1->FILIAL,"M0_ESTCOB"))
	cCepEmp		:= Transform(Posicione("SM0",1,cEmpresa+TMP1->FILIAL,"M0_CEPCOB"),"@E 99.999-999")
	cIEEmp		:= Alltrim(Posicione("SM0",1,cEmpresa+TMP1->FILIAL,"M0_INSC"))
	cBaiEmp		:= Alltrim(Posicione("SM0",1,cEmpresa+TMP1->FILIAL,"M0_BAIRCOB"))
	cCICEmp		:= Transform(Posicione("SM0",1,cEmpresa+TMP1->FILIAL,"M0_CGC"),"@R 99.999.999/9999-99")
	cTelEmp		:= Transform(Posicione("SM0",1,cEmpresa+TMP1->FILIAL,"M0_TEL"),"@R (999) 99999-9999")
	cPlacaVei	:= Transform(Posicione("DA3",1,FWXFilial("DA3")+TMP1->VEICULO,"DA3_PLACA"),"@R AAA-9999")
	cEstVei		:= Alltrim(Posicione("DA3",1,FWXFilial("DA3")+TMP1->VEICULO,"DA3_ESTPLA"))
	cMunVei		:= Alltrim(Posicione("DA3",1,FWXFilial("DA3")+TMP1->VEICULO,"DA3_MUNPLA"))
	cPlacaCar	:= Transform(Posicione("DA3",1,FWXFilial("DA3")+TMP1->CARRETA,"DA3_PLACA"),"@R AAA-9999")
	cEstCar		:= Alltrim(Posicione("DA3",1,FWXFilial("DA3")+TMP1->CARRETA,"DA3_ESTPLA"))
	cMunCar		:= Alltrim(Posicione("DA3",1,FWXFilial("DA3")+TMP1->CARRETA,"DA3_MUNPLA"))
	cRespImp	:= Alltrim(Posicione("SZ8",2,FWXFilial("SZ8")+TMP1->CONT,"Z8_RESINSP"))
	cLacreArm 	:= Alltrim(Posicione("SZ8",2,FWXFilial("SZ8")+TMP1->CONT,"Z8_LACRE"))
	
	FWrite(nHandle,' <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">  '+QbLinha) 
	FWrite(nHandle,' <script src="/PSER/Template/JS/trim.js"></script>  '+QbLinha) 
	FWrite(nHandle,' <html>  '+QbLinha) 
	FWrite(nHandle,' 	<head>  '+QbLinha) 
	FWrite(nHandle,' 		<meta charset="UTF-8"/>  '+QbLinha) 
	FWrite(nHandle,' 	</head>  '+QbLinha) 
	FWrite(nHandle,' 	<title>Ticket de Pesagem</title>  '+QbLinha) 
	FWrite(nHandle,' 	<style type = "text/css">  '+QbLinha) 
	FWrite(nHandle,' 		*{Margin:0; Padding:0 font-family:Arial, Helvetica, sans-serif;}  '+QbLinha) 
	FWrite(nHandle,' 		@media print{@page{size:portrait;}}  '+QbLinha) 
	FWrite(nHandle,' 		form {margin:0 auto; width:auto; padding:1em; }  '+QbLinha) 
	FWrite(nHandle,'  '+QbLinha) 
	FWrite(nHandle,' 		#esq { position:relative; float:left;}  '+QbLinha) 
	FWrite(nHandle,' 		#mei { position:relative; float:center;}  '+QbLinha) 
	FWrite(nHandle,' 		#dir { position:relative; float:right; border:1px; solid #000000;}  '+QbLinha) 
	FWrite(nHandle,'  '+QbLinha) 
	FWrite(nHandle,' 		hr{border-color:#000000; box-sizing:border-box; width:100%;}  '+QbLinha) 
	FWrite(nHandle,'  '+QbLinha) 
	FWrite(nHandle,' 		.td {border:10px solid #000000; border-color:#000000; font-size:12px;}  '+QbLinha) 
	FWrite(nHandle,' 		.table{font-size:12px;}   '+QbLinha) 
	FWrite(nHandle,' 	</style>  '+QbLinha) 
	FWrite(nHandle,' 	<body> '+QbLinha) 
	FWrite(nHandle,' 		<br> '+QbLinha) 
	FWrite(nHandle,' 		<h3 id="esq"<b>TOTVS | PROTHEUS</b></h3> '+QbLinha) 
	FWrite(nHandle,' 		<h3 id="dir"><b>'+ DTOC(Date()) +' | '+ Time() +'</b></h3> '+QbLinha) 
	FWrite(nHandle,' 		<hr> '+QbLinha) 
	FWrite(nHandle,' 		<br> '+QbLinha) 
	FWrite(nHandle,' 			<table style = " width:100%; border-top:3px; solid #000000; border-button:10px double #000000;"> '+QbLinha) 
	FWrite(nHandle,' 				<tr> '+QbLinha) 
	FWrite(nHandle,' 					<td rowspan="2" ><img style = "margin-top:-15px;" width=270px height=120px src = "https://fa09ae68-a-eb1a3c69-s-sites.googlegroups.com/a/equilibrioti.com.br/equilibrioti/logoavb/logo-avanco-oz.png?attachauth=ANoY7cpq6eDO-lmMmuQE2OijS-ks_QOfAlr4nBuIglx-RGeph5eZrmCHRWGePIS0qs3Z8XelZCl54U-iJbuUZfgVIjIF6wU2GpzZgQNMMSsVCumPCD0yzeTo06RFHcDbxWKU_bjcmBstupzemYGjURRSrSefpVtAPJvUGMFSJfuKp9A46PXuPcBIsqzAhjUogS0UFWMERZEzvSFzAn_SK1uFugqlXbD-hPk0JNZbr3vwxXiRrCXWsFI%3D&attredirects=0" ></td> '+QbLinha) 
	FWrite(nHandle,' 					<td ><h1>AVB MINERA&Ccedil;&Atilde;O LTDA</h1></td> '+QbLinha) 
	FWrite(nHandle,' 				</tr> '+QbLinha) 
	FWrite(nHandle,' 				<tr> '+QbLinha) 
	FWrite(nHandle,' 					<td><h2>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Ticket de Pesagem</h2></td> '+QbLinha) 
	FWrite(nHandle,' 				</tr> '+QbLinha) 
	FWrite(nHandle,' 			</table> '+QbLinha) 
	FWrite(nHandle,' 		<br> '+QbLinha) 
	FWrite(nHandle,' 		<hr> '+QbLinha) 
	FWrite(nHandle,' 		<br> '+QbLinha) 
	FWrite(nHandle,' 		<table style = " width:100%; border-top:3px; solid #000000; border-button:10px double #000000;"> '+QbLinha) 
	FWrite(nHandle,' 			<tr> '+QbLinha) 
	FWrite(nHandle,' 				<td><b>Ordem de Carregamento : </b></td> '+QbLinha) 
	FWrite(nHandle,' 				<td>'+ Alltrim(TMP1->COD) +'</td> '+QbLinha) 
	FWrite(nHandle,' 			</tr> '+QbLinha) 
	FWrite(nHandle,' 			<tr></tr><tr></tr><tr></tr><tr></tr><tr></tr><tr></tr><tr></tr><tr></tr> '+QbLinha) 
	FWrite(nHandle,' 			<tr> '+QbLinha) 
	FWrite(nHandle,' 				<td><b>Placa do Ve&iacute;culo</b></td> '+QbLinha) 
	FWrite(nHandle,' 				<td><b>Placa da Carreta</b></td> '+QbLinha) 
	FWrite(nHandle,' 				<td><b>Tara do Container</b></td> '+QbLinha) 
	FWrite(nHandle,' 				<td><b>Data de Emiss&atilde;o</b></td> '+QbLinha) 
	FWrite(nHandle,' 			</tr> '+QbLinha) 
	FWrite(nHandle,' 			<tr> '+QbLinha) 
	FWrite(nHandle,' 				<td>' + cPlacaVei + '</td> '+QbLinha) 
	FWrite(nHandle,' 				<td>' + cPlacaCar + '</td> '+QbLinha) 
	FWrite(nHandle,' 				<td>' + TRANSFORM(TMP1->TARACON,PesqPict("SZA","ZA_TARACON")) + '</td> '+QbLinha) 
	FWrite(nHandle,' 				<td>' + SUBSTR(TMP1->EMISSAO,7,2) +'/'+ SUBSTR(TMP1->EMISSAO,5,2) +'/'+ SUBSTR(TMP1->EMISSAO,1,4) + '</td> '+QbLinha) 
	FWrite(nHandle,' 			</tr> '+QbLinha) 
	FWrite(nHandle,' 			<tr></tr><tr></tr><tr></tr><tr></tr><tr></tr><tr></tr><tr></tr><tr></tr> '+QbLinha) 
	FWrite(nHandle,' 			<tr> '+QbLinha) 
	FWrite(nHandle,' 				<td><b>Transportadora</b></td>'+QbLinha) 
	FWrite(nHandle,' 			</tr> '+QbLinha) 
	FWrite(nHandle,' 			<tr> '+QbLinha) 
	FWrite(nHandle,' 				<td colspan = "2">' + Alltrim(TMP1->TRANSP) + ' - ' + Alltrim(TMP1->DESCTRP) + '</td> '+QbLinha) 
	FWrite(nHandle,' 			</tr> '+QbLinha) 
	FWrite(nHandle,' 			<tr></tr><tr></tr><tr></tr><tr></tr><tr></tr><tr></tr><tr></tr><tr></tr> '+QbLinha) 
	FWrite(nHandle,' 			<tr> '+QbLinha) 
	FWrite(nHandle,' 				<td><b>Emissor</b></td>'+QbLinha) 
	FWrite(nHandle,' 			</tr> '+QbLinha) 
	FWrite(nHandle,' 			<tr> '+QbLinha) 
	FWrite(nHandle,' 				<td colspan = "2">' + cCodFil + ' - ' + cNomeFil + '</td> '+QbLinha) 
	FWrite(nHandle,' 			</tr> '+QbLinha) 
	FWrite(nHandle,' 		</table> '+QbLinha) 
	FWrite(nHandle,' 		<br> '+QbLinha) 
	FWrite(nHandle,' 		<hr> '+QbLinha) 
	FWrite(nHandle,' 		<h3><b><center>DADOS DA PESAGEM</center></b></h3> '+QbLinha) 
	FWrite(nHandle,' 		<hr>	 '+QbLinha) 
	FWrite(nHandle,' 		<table cellpadding="2" cellspacing="0" border="0" align = "left" bordercolor="#000000" width = 50% style = "margin:3px auto;"> '+QbLinha) 
	FWrite(nHandle,' 			<tr> '+QbLinha) 
	FWrite(nHandle,' 				<td colspan = "2"><b>1 Pesagem</b></td> '+QbLinha) 
	FWrite(nHandle,' 			</tr> '+QbLinha) 
	FWrite(nHandle,' 			<tr> '+QbLinha) 
	FWrite(nHandle,' 				<td><b>Data / Hora : </b></td> '+QbLinha) 
	FWrite(nHandle,' 				<td>' + SUBSTR(TMP1->DTPESO1,7,2) +'/'+ SUBSTR(TMP1->DTPESO1,5,2) +'/'+ SUBSTR(TMP1->DTPESO1,1,4) + Space(5) + Alltrim(TMP1->HRPESO1)+'</td> '+QbLinha) 
	FWrite(nHandle,' 			</tr> '+QbLinha) 
	FWrite(nHandle,' 			<tr> '+QbLinha) 
	FWrite(nHandle,' 				<td><b>Balan&ccedil;a : </b></td> '+QbLinha) 
	FWrite(nHandle,' 				<td>' + Alltrim(TMP1->CODBAL) + ' - ' + Alltrim(TMP1->DESCBAL) + '</td> '+QbLinha) 
	FWrite(nHandle,' 			</tr> '+QbLinha) 
	FWrite(nHandle,' 			<tr> '+QbLinha) 
	FWrite(nHandle,' 				<td><b>Peso : </b></td> '+QbLinha) 
	FWrite(nHandle,' 				<td>' + TRANSFORM(TMP1->PESO1,PesqPict("SZA","ZA_PESO1")) + ' KG</td> '+QbLinha) 
	FWrite(nHandle,' 			</tr> '+QbLinha) 
	FWrite(nHandle,' 			<tr> '+QbLinha) 
	FWrite(nHandle,' 				<td><b>Operador	: </b></td> '+QbLinha) 
	FWrite(nHandle,' 				<td>' + Alltrim(TMP1->USRPSO1) + '</td> '+QbLinha) 
	FWrite(nHandle,' 			</tr> '+QbLinha) 
	FWrite(nHandle,' 			<tr> '+QbLinha) 
	FWrite(nHandle,' 				<td><b>Peso Liquido : </b></td> '+QbLinha) 
	FWrite(nHandle,' 				<td>' + TRANSFORM(TMP1->PESOLIQ,PesqPict("SZA","ZA_PESOLIQ")) + ' KG</td> '+QbLinha) 
	FWrite(nHandle,' 			</tr> '+QbLinha) 
	FWrite(nHandle,' 		</table> '+QbLinha) 
	FWrite(nHandle,' 		<table cellpadding="2" cellspacing="0" border="0" align = "right" bordercolor="#000000" width = 50% style = "margin:3px auto;"> '+QbLinha) 
	FWrite(nHandle,' 			<tr> '+QbLinha) 
	FWrite(nHandle,' 				<td colspan = "2"><b>2 Pesagem</b></td> '+QbLinha) 
	FWrite(nHandle,' 			</tr> '+QbLinha) 
	FWrite(nHandle,' 			<tr> '+QbLinha) 
	FWrite(nHandle,' 				<td><b>Data / Hora : </b></td> '+QbLinha) 
	FWrite(nHandle,' 				<td>' + SUBSTR(TMP1->DTPESO2,7,2) +'/'+ SUBSTR(TMP1->DTPESO2,5,2) +'/'+ SUBSTR(TMP1->DTPESO2,1,4) + Space(5) + Alltrim(TMP1->HRPESO2) +'</td> '+QbLinha) 
	FWrite(nHandle,' 			</tr> '+QbLinha) 
	FWrite(nHandle,' 			<tr> '+QbLinha) 
	FWrite(nHandle,' 				<td><b>Balan&ccedil;a : </b></td> '+QbLinha) 
	FWrite(nHandle,' 				<td>' + Alltrim(TMP1->CODBAL) + ' - ' + Alltrim(TMP1->DESCBAL) + '</td> '+QbLinha) 
	FWrite(nHandle,' 			</tr> '+QbLinha) 
	FWrite(nHandle,' 			<tr> '+QbLinha) 
	FWrite(nHandle,' 				<td><b>Peso : </b></td> '+QbLinha) 
	FWrite(nHandle,' 				<td>' + TRANSFORM(TMP1->PESO2,PesqPict("SZA","ZA_PESO2")) + ' KG</td> '+QbLinha) 
	FWrite(nHandle,' 			</tr> '+QbLinha) 
	FWrite(nHandle,' 			<tr> '+QbLinha) 
	FWrite(nHandle,' 				<td><b>Operador	: </b></td> '+QbLinha) 
	FWrite(nHandle,' 				<td>' + Alltrim(TMP1->USRPSO2) + '</td> '+QbLinha) 
	FWrite(nHandle,' 			</tr> '+QbLinha) 
	FWrite(nHandle,' 			<tr> '+QbLinha) 
	FWrite(nHandle,' 				<td><b>Peso Bruto : </b></td> '+QbLinha) 
	FWrite(nHandle,' 				<td>' + TRANSFORM(TMP1->PESOBUT,PesqPict("SZA","ZA_PESOBUT")) + ' KG</td> '+QbLinha) 
	FWrite(nHandle,' 			</tr> '+QbLinha) 
	FWrite(nHandle,' 		</table> '+QbLinha) 
	FWrite(nHandle,' 		<br> '+QbLinha) 
	FWrite(nHandle,' 		<hr> '+QbLinha) 
	FWrite(nHandle,' 		<table cellpadding="2" cellspacing="0" border="0" align = "left" bordercolor="#000000" width = 100% style = "margin:3px auto;"> '+QbLinha) 
	FWrite(nHandle,' 			<tr> '+QbLinha) 
	FWrite(nHandle,' 				<td><b>Respons&agrave;vel pela Inspe&ccedil;&atilde;o : </b></td> '+QbLinha) 
	FWrite(nHandle,' 				<td>' + cRespImp + '</td> '+QbLinha) 
	FWrite(nHandle,' 			</tr> '+QbLinha) 
	FWrite(nHandle,' 		</table> '+QbLinha) 
	FWrite(nHandle,' 		<hr> '+QbLinha) 
	FWrite(nHandle,' 		<h3><b><center>OBSERVA&Ccedil;&Atilde;O</center></b></h3> '+QbLinha) 
	FWrite(nHandle,' 		<hr>	 '+QbLinha) 
	FWrite(nHandle,' 		<table cellpadding="2" cellspacing="0" border="0" align = "left" bordercolor="#000000" width = 100% style = "margin:3px auto;"> '+QbLinha) 
	FWrite(nHandle,' 			<tr> '+QbLinha) 
	FWrite(nHandle,' 				<td><b>C&oacute;digo do Container : </b></td> '+QbLinha) 
	FWrite(nHandle,' 				<td>' + Alltrim(TMP1->CONT) + '</td> '+QbLinha) 
	FWrite(nHandle,' 			</tr> '+QbLinha) 
	FWrite(nHandle,' 			<tr> '+QbLinha) 
	FWrite(nHandle,' 				<td><b>TAG do Container : </b></td> '+QbLinha) 
	FWrite(nHandle,' 				<td>' + Alltrim(TMP1->DESCCT) + '</td> '+QbLinha) 
	FWrite(nHandle,' 			</tr> '+QbLinha) 
	FWrite(nHandle,' 			<tr> '+QbLinha) 	
	FWrite(nHandle,' 				<td><b>Placa do Veiculo : </b></td> '+QbLinha) 
	FWrite(nHandle,' 				<td>'+ cPlacaVei +' '+ cMunVei +' - '+ cEstVei +'</td> '+QbLinha) 
	FWrite(nHandle,' 			</tr> '+QbLinha) 
	FWrite(nHandle,' 			<tr> '+QbLinha) 
	FWrite(nHandle,' 				<td><b>Placa da Carreta : </b></td> '+QbLinha) 
	FWrite(nHandle,' 				<td>'+ cPlacaCar +' '+ cMunCar +' - '+ cEstCar +'</td> '+QbLinha) 
	FWrite(nHandle,' 			</tr> '+QbLinha) 
	FWrite(nHandle,' 			<tr> '+QbLinha) 
	FWrite(nHandle,' 				<td><b>KM do Veiculo : </b></td> '+QbLinha) 
	FWrite(nHandle,' 				<td>' + Alltrim(TMP1->KMVEIC) + '</td> '+QbLinha) 
	FWrite(nHandle,' 			</tr> '+QbLinha) 
	FWrite(nHandle,' 			<tr> '+QbLinha) 
	FWrite(nHandle,' 				<td><b>Motorista : </b></td> '+QbLinha) 
	FWrite(nHandle,' 				<td>' + Alltrim(TMP1->NOMEMT) + '</td> '+QbLinha) 
	FWrite(nHandle,' 			</tr> '+QbLinha) 
	FWrite(nHandle,' 			<tr> '+QbLinha) 
	FWrite(nHandle,' 				<td><b>C.P.F. : </b></td> '+QbLinha) 
	FWrite(nHandle,' 				<td>'+ Transform(Alltrim(TMP1->MOTORI),"@R 999.999.999-99") +'</td> '+QbLinha) 
	FWrite(nHandle,' 			</tr> '+QbLinha) 
	FWrite(nHandle,' 			<tr> '+QbLinha) 
	FWrite(nHandle,' 				<td><b>Lacre Armador : </b></td> '+QbLinha) 
	FWrite(nHandle,' 				<td>' + cLacreArm + '</td> '+QbLinha) 
	FWrite(nHandle,' 			</tr> '+QbLinha) 
	FWrite(nHandle,' 			<tr> '+QbLinha) 
	FWrite(nHandle,' 				<td><b>Lacre Avanco : </b></td> '+QbLinha) 
	FWrite(nHandle,' 				<td>' + Alltrim(TMP1->LCAVANC) + '</td> '+QbLinha) 
	FWrite(nHandle,' 			</tr> '+QbLinha) 
	FWrite(nHandle,' 		</table> '+QbLinha) 
	FWrite(nHandle,' 		<hr> '+QbLinha) 
	FWrite(nHandle,' 		<p><i><b><center>www.avancoresources.com.br</center></b></i></p> '+QbLinha) 
	FWrite(nHandle,' 		<br> '+QbLinha) 
	FWrite(nHandle,' 		<p><i><b>'+ cEndEmp +', '+ cBaiEmp +', '+ cCidEmp +', CEP: '+ cCepEmp +'</b></i></p> '+QbLinha) 
	FWrite(nHandle,' 	</body> '+QbLinha) 
	FWrite(nHandle,' </html> '+QbLinha) 
	
	FClose(nHandle)

	cPathTmp := Alltrim(GetTempPath())  

	If File(cPathTmp+"\"+cArq)
		FErase(cPathTmp+"\"+cArq)
	EndIf  
	
	CpyS2T(cDirDocs+"\"+cArq,cPathTmp,.t.)
	ShellExecute("open",cArq,"",cPathTmp,1)

Return

/*/{Protheus.doc} GET_DADOS
Funçao que busca os dados do Relatorio de ticket de Pesagem.
@author 	Ricardo Tavares Ferreira
@since 		22/07/2018
@version 	12.1.17
@return 	Nulo
@Obs 		Ricardo Tavares - Construcao Inicial
/*/
//==========================================================================================================
	Static Function GET_DADOS()
//==========================================================================================================
	
	Local cQuery	:= ""
	Local QBLINHA	:= chr(13)+chr(10)
	Local NQTREG	:= 0
	
	cQuery := " SELECT  "+QbLinha 
    cQuery += " ZA_FILIAL		FILIAL "+QbLinha 
    cQuery += " , ZA_COD        COD "+QbLinha 
    cQuery += " , ZA_CONT       CONT "+QbLinha 
    cQuery += " , ZA_DESCCT     DESCCT "+QbLinha 
    cQuery += " , ZA_PESOLIQ    PESOLIQ "+QbLinha 
    cQuery += " , ZA_PESOBUT    PESOBUT "+QbLinha 
    cQuery += " , ZA_CLIENTE    CLIENTE "+QbLinha 
    cQuery += " , ZA_LOJA       LOJA "+QbLinha 
    cQuery += " , ZA_NOMCLI     NOMCLI "+QbLinha 
    cQuery += " , ZA_CONDPAG    CONDPAG "+QbLinha 
    cQuery += " , ZA_DESCOND    DESCOND "+QbLinha 
    cQuery += " , ZA_TRANSP     TRANSP "+QbLinha 
    cQuery += " , ZA_DESCTRP    DESCTRP "+QbLinha 
    cQuery += " , ZA_MOTORI     MOTORI "+QbLinha 
    cQuery += " , ZA_NOMEMT     NOMEMT "+QbLinha 
    cQuery += " , ZA_VEICULO    VEICULO "+QbLinha 
    cQuery += " , ZA_DESCVEI    DESCVEI "+QbLinha 
    cQuery += " , ZA_KMVEIC     KMVEIC "+QbLinha 
    cQuery += " , ZA_CARRETA    CARRETA "+QbLinha 
    cQuery += " , ZA_DCARRET    DCARRET "+QbLinha 
    cQuery += " , ZA_MSGNOTA    MSGNOTA "+QbLinha 
    cQuery += " , ZA_OBSPED     OBSPED "+QbLinha 
    cQuery += " , ZA_NATUR      NATUR "+QbLinha 
    cQuery += " , ZA_EMISSAO    EMISSAO "+QbLinha 
    cQuery += " , ZA_PESO1      PESO1 "+QbLinha 
    cQuery += " , ZA_DTPESO1    DTPESO1 "+QbLinha 
    cQuery += " , ZA_HRPESO1    HRPESO1 "+QbLinha 
    cQuery += " , ZA_USRPSO1    USRPSO1 "+QbLinha 
    cQuery += " , ZA_PESO2      PESO2 "+QbLinha 
    cQuery += " , ZA_DTPESO2    DTPESO2 "+QbLinha 
    cQuery += " , ZA_HRPESO2    HRPESO2 "+QbLinha 
    cQuery += " , ZA_USRPSO2    USRPSO2 "+QbLinha 
    cQuery += " , ZA_TPBAL      TPBAL "+QbLinha 
    cQuery += " , ZA_PEDIDO     PEDIDO "+QbLinha 
    cQuery += " , ZA_NF         NF "+QbLinha 
    cQuery += " , ZA_SERIE      SERIE "+QbLinha 
    cQuery += " , ZA_TXDOLAR    TXDOLAR "+QbLinha 
    cQuery += " , ZA_LCAVANC    LCAVANC "+QbLinha 
    cQuery += " , ZA_TPFRETE    TPFRETE "+QbLinha 
    cQuery += " , ZA_TARACON    TARACON "+QbLinha 
    cQuery += " , DX5_CODIGO	CODBAL "+QbLinha 
    cQuery += " , CASE  "+QbLinha 
    cQuery += " 	WHEN DX5_XTPBAL = '1' THEN 'FIXA' "+QbLinha 
    cQuery += " 	WHEN DX5_XTPBAL = '2' THEN 'RODOVIARIA' "+QbLinha 
    cQuery += " END DESCBAL "+QbLinha 

    cQuery += "FROM "
	cQuery +=  RetSqlName("SZA") + " SZA "+QBLINHA
  
    cQuery += "INNER JOIN "
	cQuery +=  RetSqlName("DX5") + " DX5 "+QBLINHA 
    cQuery += " ON DX5_XTPBAL = ZA_TPBAL "+QbLinha 
    cQuery += " AND DX5.D_E_L_E_T_ = ' ' "+QbLinha 
  
    cQuery += " WHERE  "+QbLinha 
    cQuery += " SZA.D_E_L_E_T_ = ' '  "+QbLinha 
    cQuery += " AND ZA_COD = '"+SZA->ZA_COD+"' "+QbLinha 
    
    If Select("TMP1") > 1								   
		TMP1->(DbCloseArea())								
	Endif
		
	MEMOWRITE("C:/ricardo/RT05A002G.sql",cQuery)			     
	cQuery := ChangeQuery(cQuery)
	DBUSEAREA(.T.,'TOPCONN',TcGenQry(,,cQuery),"TMP1",.F.,.T.)
			
	DBSELECTAREA("TMP1")
	TMP1->(DBGOTOP())
	COUNT To NQTREG
	TMP1->(DBGOTOP())
			
	If NQTREG <= 0
		TMP1->(DBCLOSEAREA())
		Return .F.
	EndIf
    
Return .T.

/*/{Protheus.doc} ENV_SEFAZ
Funçao que faz a transmissao da nota fiscal automaticamente para o SEFAZ.
@author 	Ricardo Tavares Ferreira
@since 		20/07/2018
@version 	12.1.17
@return 	Nulo
@Obs 		Ricardo Tavares - Construcao Inicial
/*/
//==========================================================================================================
	User Function ENV_SEFAZ(oSay,cSer,cNF)
//==========================================================================================================

	Local cURL	:= "" 
	Local lOk   := .F.
	Local oWs	:= Nil
	Local cAmb	:= ""

	cIdEnt := GetIdEnt()
	oWs    := WsSpedCfgNFe():New()
	cURL   := PadR(GetMv("MV_SPEDURL"),250)

	If CTIsReady()
		oWS:cUSERTOKEN 	:= "TOTVS"
		oWS:cID_ENT    	:= cIdEnt
		oWS:nAmbiente 	:= 0     
		oWS:_URL       	:= AllTrim(cURL)+"/SPEDCFGNFe.apw"
		lOk  := oWS:CFGAMBIENTE()
		cAmb := oWS:cCfgAmbienteResult
		cAmb := Substr(cAmb,1,1)

		If lOk
			oSay:cCaption := ("Transmitindo Nota Fiscal de Saida...")
			AutoNfeEnv(cEmpAnt,cEmpAnt,"0",cAmb,cSer,cNF,cNF,"S")

			oSay:cCaption := ("Aguarde, Consultando o Status da nota na SEFAZ...")
			ProcessMessages()

			If fMntNfe(cIdEnt,1,{cSer,cNF,cNF},5)//SpedNFe6Mnt(_cSerie,_cDoc,_cDoc,.T.)
				oSay:cCaption := ("Aguarde, estamos realizando a impressão da DANFE...")
				ProcessMessages()
				fImpDanfe(2,cNF,cNF,cSer,cIdEnt)
			EndIf
		Else
			MsgInfo("NF-e FORA DO AR. "+CRLF+CRLF+"Tente novamente mais tarde. Nota: "+cNF,"Atenção")
		EndIf
	Endif

Return

/*/{Protheus.doc} fImpDanfe
Funçao que realiza a impressao do danfe automatico.
@author 	Ricardo Tavares Ferreira
@since 		20/07/2018
@version 	12.1.17
@return 	Nulo
@Obs 		Ricardo Tavares - Construcao Inicial
/*/
//==========================================================================================================
	Static Function fImpDanfe(_cTipo,_cDocDe,_cDocAte,_cSerie,cIdEnt)
//==========================================================================================================

	Local cIdEnt := GetIdEnt()
	Local aIndArq   := {}
	Local oDanfe
	Local nHRes  := 0
	Local nVRes  := 0
	Local nDevice
	Local cFilePrint := "DANFE_"+cIdEnt+Dtos(MSDate())+StrTran(Time(),":","")
	Local oSetup
	Local aDevice  := {}
	Local cSession     := GetPrinterSession()
	
	Local lDisableSetup  := .T.
	Local _cDirTemp := "\system\_danfe_automaticas\"
	Local _cDirLocal := "c:\danfe_automatica\"
	
	Private _lImpDanfe := .T.
	
	AADD(aDevice,"DISCO") // 1
	AADD(aDevice,"SPOOL") // 2
	AADD(aDevice,"EMAIL") // 3
	AADD(aDevice,"EXCEL") // 4
	AADD(aDevice,"HTML" ) // 5
	AADD(aDevice,"PDF"  ) // 6
                                                                    
	nLocal       	:= 2//If(GetProfString(cSession,"LOCAL","SERVER",.T.)=="SERVER",1,2 )
	nOrientation 	:= 1//If(GetProfString(cSession,"ORIENTATION","PORTRAIT",.T.)=="PORTRAIT",1,2)
	cDevice     	:= "SPOOL"//GetProfString(cSession,"PRINTTYPE","SPOOL",.T.)
	nPrintType      := aScan(aDevice,{|x| x == cDevice })
	
	If !ExistDir(_cDirLocal)
		FWMakeDir (_cDirLocal,.T.)
	EndIf
	If !ExistDir(_cDirTemp)
		FWMakeDir (_cDirTemp,.T.)
	EndIf
	
	_cSerie	:= Padr(_cSerie,TamSX3("F2_SERIE")[01])
	_cDocDe	:= Padr(_cDocDe,TamSX3("F2_DOC")[01])
	_cDocAte:= Padr(_cDocAte,TamSX3("F2_DOC")[01])
	
	If CTIsReady()
	
		dbSelectArea("SF2")
		RetIndex("SF2")
		dbClearFilter()

		lAdjustToLegacy := .F. // Inibe legado de resolução com a TMSPrinter
		//oDanfe := FWMSPrinter():New(cFilePrint, IMP_PDF, lAdjustToLegacy, /*cPathInServer*/, .T.)
		
		oDanfe := FWMSPrinter():New(cFilePrint, IMP_PDF, lAdjustToLegacy,_cDirTemp        , lDisableSetup)//,            ,               ,            ,              ,             , .F.    , .F. )	
		oDanfe:lInJob := .F.	
		
		// ----------------------------------------------
		// Cria e exibe tela de Setup Customizavel
		// OBS: Utilizar include "FWPrintSetup.ch"
		// ----------------------------------------------
		//nFlags := PD_ISTOTVSPRINTER+ PD_DISABLEORIENTATION + PD_DISABLEPAPERSIZE + PD_DISABLEPREVIEW + PD_DISABLEMARGIN
		  nFlags := PD_ISTOTVSPRINTER + PD_DISABLEPAPERSIZE + PD_DISABLEPREVIEW + PD_DISABLEMARGIN
			
		// ----------------------------------------------
		// Pressionado botão OK na tela de Setup
		// ----------------------------------------------
		//If oSetup:Activate() == PD_OK // PD_OK =1
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Salva os Parametros no Profile             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
		fwWriteProfString( cSession, "LOCAL"      , "SERVER"    , .T. )
		fwWriteProfString( cSession, "PRINTTYPE"  , "PDF"       , .T. )
		fwWriteProfString( cSession, "ORIENTATION", "PORTRAIT"  , .T. )
	
		//If oSetup:GetProperty(PD_ORIENTATION) == 1
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Danfe Retrato DANFEII.PRW                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		Pergunte("NFSIGW",.F.)
				
		MV_PAR01 := _cDocDe
		MV_PAR02 := _cDocAte
		MV_PAR03 :=	_cSerie
		MV_PAR04 :=	2
		MV_PAR05 :=	1
		MV_PAR06 := 2	
		MV_PAR07 := cTod("20000101")
		MV_PAR08 := cTod("20490101")
		
		If U_PrtNfeSef(cIdEnt,,,oDanfe, oSetup, cFilePrint,.F.,0)
			U_RT99JB01()
		Else
			MsgInfo("Não foi possivel imprimir o DANFE.","Atenção")
		EndIf
		
	EndIf

	oDanfe := Nil
	oSetup := Nil

Return

/*/{Protheus.doc} fMntNfe
Função que cria a tela de monitoramento do status da nf no SEFAZ.
@author 	Ricardo Tavares Ferreira (ricardo.cientista2014@gmail.com)
@since 		20/09/2016
@version 	11.8
@return 	Logico
@Obs		20/09/2016 - Construcao Inicial - Casas Brasileiras
/*/
//==========================================================================================================
	Static Function fMntNfe(cIdEnt,nModelo,aParam,_nSegundo)
//==========================================================================================================

	Local _oDlgMsg
	Local _nSegCnt := 0
	Local _nColor := CLR_HBLUE
	Local _oFont := fFont(25,.T.)
	Local _lExit := .F.
	Local _cMsg := "Aguardando retorno da SEFAZ..."
	
	Private _oMsgAlert,_oTimeMsg,_oMsgCnt,_cMsgCnt
	
	Default _nSegundo := 2
	
	_nSegCnt := _nSegundo
	
	_oDlgMsg := MSDialog():New(0,0,170,450,"Status da Nota na SEFAZ",,,,nOr(WS_VISIBLE,WS_POPUP),CLR_BLACK,CLR_WHITE,,,.T.)
	
	_oTimeMsg := TTimer():New(1000,{|| _nSegCnt--, If(_lExit, If(_nSegCnt<=0,_oDlgMsg:End(),(oButOK:cCaption:="&OK ("+cValToChar(_nSegCnt)+")",oButOK:Refresh())) ,If(_nSegCnt<=0,If(fRefresh(cIdEnt,nModelo,aParam,@_cMsg),(_oMsgAlert:cCaption:=_cMsg , _cMsgCnt:="Monitoramento finalizado.", _lExit := .T., _nSegCnt := 2 ,_oMsgAlert:Refresh(),_oMsgCnt:Refresh()),(_nSegCnt:=_nSegundo,_oMsgAlert:cCaption:=_cMsg)),(_cMsgCnt:= "Próxima atualização em "+cValToChar(_nSegCnt)+" segundos."))),_oMsgAlert:Refresh(),_oMsgCnt:Refresh() },_oDlgMsg)
	_oTimeMsg:lLiveAny:=	.T.
	_oTimeMsg:Activate()
		
	@  10,0 SAY _oMsgAlert  VAR _cMsg SIZE 220,80 OF _oDlgMsg FONT _oFont PIXEL COLOR _nColor
	
	@  50,0 SAY _oMsgCnt  VAR _cMsgCnt SIZE 220,80 OF _oDlgMsg FONT fFont(16,.T.)  PIXEL
	
	@ 70, 85 Button oButOK    Prompt "&OK"  Size 62, 22 Pixel ACTION (_oDlgMsg:End()) ;
		FONT fFont(25,.T.);
		Message "OK" Of _oDlgMsg
	oButOK:SetCss(CSSBOTAO)
	
	_oDlgMsg:Activate(,,,.T.,,,)

Return _lExit

/*/{Protheus.doc} fMntNfe
Função que executa o monitoramento da nf no SEFAZ.
@author 	Ricardo Tavares Ferreira (ricardo.cientista2014@gmail.com)
@since 		20/09/2016
@version 	11.8
@return 	Logico
@Obs		20/09/2016 - Construcao Inicial - Casas Brasileiras
/*/
//==========================================================================================================
	Static Function fRefresh(cIdEnt,nModelo,aParam,_cMsg)
//==========================================================================================================

	Local _aList := {}
	Local _lRet := .F.
	Local _nI := 1

	_aList := WsNFeMnt(cIdEnt,nModelo,aParam,.F.,.F.)
	
	If Len(_aList)>0
		_cMsg := ""
		While _nI <= Len(_aList)
		
			If Len(_aList[_nI])>= 6 .and. Left(Alltrim(_aList[_nI][06]),3) == "001"
				_cMsg += Alltrim(_aList[_nI][02])+' | ' + Substr(_aList[_nI][06],7) + CRLF
				_lRet := .T.
				Exit
			Else
				_cMsg += Alltrim(_aList[_nI][02])+' | ' + Substr(_aList[_nI][06],7) + CRLF//Alltrim(aParam[01])+' '+Alltrim(aParam[02])+" | Aguardando autorização da SEFAZ..."
			EndIf
			
			_nI++
			
		EndDo
		
	EndIf
	
Return _lRet 

/*/{Protheus.doc} WsNFeMnt
Função que executa o monitoramento da nf no SEFAZ.
@author 	Ricardo Tavares Ferreira (ricardo.cientista2014@gmail.com)
@since 		20/09/2016
@version 	11.8
@return 	Array
@Obs		20/09/2016 - Construcao Inicial - Casas Brasileiras
/*/
//==========================================================================================================
	Static Function WsNFeMnt(cIdEnt,nModelo,aParam,lCTe,lMsg)
//==========================================================================================================

	Local aListBox := {}
	Local aMsg     := {}
	Local nX       := 0
	Local nY       := 0
	Local nSX3SF2  := TamSx3("F2_DOC")[1]
	Local nLastXml := 0
	Local cURL     := PadR(GetNewPar("MV_SPEDURL","http://"),250)
	Local lOk      := .T.
	Local oOk      := LoadBitMap(GetResources(), "ENABLE")
	Local oNo      := LoadBitMap(GetResources(), "DISABLE")
	Local oWS
	Local oRetorno
	Local cTextInut:= GetNewPar("MV_TXTINUT","")
	Local aXML       := {}
	Local aNotas     := {}
	Local cModalidade:= ""
	Local cChaveF3   := ""
	Local cChaveFT   := ""

	Private oXml
	Default lCTe   := .F.
	Default	lMsg   := .T.

	oWS:= WSNFeSBRA():New()
	oWS:cUSERTOKEN    := "TOTVS"
	oWS:cID_ENT       := cIdEnt
	oWS:_URL          := AllTrim(cURL)+"/NFeSBRA.apw"
	If nModelo == 1
		oWS:cIdInicial    := aParam[01]+aParam[02]
		oWS:cIdFinal      := aParam[01]+aParam[03]
		lOk := oWS:MONITORFAIXA()
		oRetorno := oWS:oWsMonitorFaixaResult
	Else
		If VALTYPE(aParam[01]) == "N"
			oWS:nIntervalo := Max((aParam[01]),60)
		Else
			oWS:nIntervalo := Max(Val(aParam[01]),60)
		EndIf
		lOk := oWS:MONITORTEMPO()
		oRetorno := oWS:oWsMonitorTempoResult
	EndIf
	If lOk
		dbSelectArea("SF3")
		dbSetOrder(5)
		For nX := 1 To Len(oRetorno:oWSMONITORNFE)
			aMsg := {}
			oXml := oRetorno:oWSMONITORNFE[nX]
			If Type("oXml:OWSERRO:OWSLOTENFE")<>"U"
				nLastRet := Len(oXml:OWSERRO:OWSLOTENFE)
				For nY := 1 To Len(	oXml:OWSERRO:OWSLOTENFE)
					If oXml:OWSERRO:OWSLOTENFE[nY]:NLOTE<>0
						aadd(aMsg,{oXml:OWSERRO:OWSLOTENFE[nY]:NLOTE,oXml:OWSERRO:OWSLOTENFE[nY]:DDATALOTE,oXml:OWSERRO:OWSLOTENFE[nY]:CHORALOTE,;
							oXml:OWSERRO:OWSLOTENFE[nY]:NRECIBOSEFAZ,;
							oXml:OWSERRO:OWSLOTENFE[nY]:CCODENVLOTE,PadR(oXml:OWSERRO:OWSLOTENFE[nY]:CMSGENVLOTE,50),;
							oXml:OWSERRO:OWSLOTENFE[nY]:CCODRETRECIBO,PadR(oXml:OWSERRO:OWSLOTENFE[nY]:CMSGRETRECIBO,50),;
							oXml:OWSERRO:OWSLOTENFE[nY]:CCODRETNFE,PadR(oXml:OWSERRO:OWSLOTENFE[nY]:CMSGRETNFE,50)})
					EndIf
					SF3->(dbSetOrder(5))
					If SF3->(MsSeek(xFilial("SF3")+oXml:Cid,.T.))
						While !SF3->(Eof()) .And. AllTrim(SF3->(F3_SERIE+F3_NFISCAL))==oXml:Cid
							If SF3->( (Left(F3_CFO,1)>="5" .Or. (Left(F3_CFO,1)<"5" .And. F3_FORMUL=="S")) .And. FieldPos("F3_CODRSEF")<>0)
								RecLock("SF3")
								SF3->F3_CODRSEF:= oXml:OWSERRO:OWSLOTENFE[nY]:CCODRETNFE
						    //SE FOR INUTILIZAÇÃO ALTERA NOS LIVROS FISCAIS
								If !Empty(cTextInut)
									If Type("oXml:OWSERRO:OWSLOTENFE["+AllTrim(Str(nY))+"]:CMSGRETNFE")<>"U" .And. ("Inutilizacao de numero homologado" $ oXml:OWSERRO:OWSLOTENFE[nY]:CMSGRETNFE .Or. "Inutilização de número homologado" $ oXml:OWSERRO:OWSLOTENFE[nY]:CMSGRETNFE)
										SF3->F3_OBSERV := ALLTRIM(cTextInut)
									EndIf
								EndIF
								MsUnlock()
							EndIf
							SF3->(dbSkip())
						End
					EndIf
				
					If ExistBlock("FISMNTNFE")
						ExecBlock("FISMNTNFE",.f.,.f.,{oXml:Cid,aMsg})
					Endif
			
				Next nY
				
				DbSelectArea("SF3")
				DbSetOrder(5)
				If SF3->(MsSeek(xFilial("SF3")+oXml:Cid,.T.))
					If (SubStr(SF3->F3_CFO,1,1)>="5" .Or. SF3->F3_FORMUL=="S")
						aNotas 	:= {}
						aXml2	:= {}
						aadd(aNotas,{})
						aadd(Atail(aNotas),.F.)
						aadd(Atail(aNotas),IIF(SF3->F3_CFO<"5","E","S"))
						aadd(Atail(aNotas),SF3->F3_ENTRADA)
						aadd(Atail(aNotas),SF3->F3_SERIE)
						aadd(Atail(aNotas),SF3->F3_NFISCAL)
						aadd(Atail(aNotas),SF3->F3_CLIEFOR)
						aadd(Atail(aNotas),SF3->F3_LOJA)
						aXml2 := fGetXMLNFE(cIdEnt,aNotas,@cModalidade)
					
						If ( Len(aXml2) > 0 )
							aAdd(aXml,aXml2[1])
						EndIf
					
						nLastXml := Len(aXml)
					Else
						nLastXml:= Len(aXml)
					EndIf
				EndIf
				
			//Nota de saida
				dbSelectArea("SF2")
				dbSetOrder(1)
				If SF2->(MsSeek(xFilial("SF2")+PadR(SUBSTR(oXml:Cid,4,Len(oXml:Cid)),nSX3SF2)+SUBSTR(oXml:Cid,1,3),.T.)) .And. nLastXml > 0 .And. !Empty(aXml)
					If SF2->(FieldPos("F2_HORA"))<>0 .And. (Empty(SF2->F2_HORA) .OR. Empty(SF2->F2_NFELETR) .Or. Empty(SF2->F2_EMINFE) .Or.Empty(SF2->F2_HORNFE) .Or. Empty(SF2->F2_CODNFE) .Or. (SF2->(FieldPos("F2_CHVNFE"))>0 .And. Empty(SF2->F2_CHVNFE)))
						RecLock("SF2")
					//SF2->F2_HORA 	:= SUBSTR(oXml:OWSERRO:OWSLOTENFE[nLastRet]:cHORALOTE,1,5)
					//SF2->F2_NFELETR := SUBSTR(oXml:Cid,4,9)
					//SF2->F2_EMINFE	:= oXml:OWSERRO:OWSLOTENFE[nLastRet]:DDATALOTE
					//SF2->F2_HORNFE	:= STRTRAN(oXml:OWSERRO:OWSLOTENFE[nLastRet]:CHORALOTE,":","")//SUBSTR(oXml:OWSERRO:OWSLOTENFE[nLastRet]:cHORALOTE,1,5) 
					//SF2->F2_CODNFE	:= IIF(!Empty(aXml[nLastXml][1]),aXml[nLastXml][1],"")
						If !Empty(aXml[nLastXml][2])
							SF2->F2_CHVNFE  := SubStr(NfeIdSPED(aXML[nLastXml][2],"Id"),4)
						EndIf
						MsUnlock()
					EndIf
			
			
			  	//Atualizo SF3
					SF3->(dbSetOrder(4))
					cChave := xFilial("SF3")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_SERIE
					If SF3->(MsSeek(xFilial("SF3")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_SERIE,.T.))
						Do While cChave == xFilial("SF3")+SF3->F3_CLIEFOR+SF3->F3_LOJA+SF3->F3_NFISCAL+SF3->F3_SERIE .And. !SF3->(Eof())
							RecLock("SF3",.F.)
						//SF3->F3_NFELETR	:= SUBSTR(oXml:Cid,4,9)
						//SF3->F3_EMINFE	:= oXml:OWSERRO:OWSLOTENFE[nLastRet]:DDATALOTE
						//SF3->F3_HORNFE	:= STRTRAN(oXml:OWSERRO:OWSLOTENFE[nLastRet]:CHORALOTE,":","")//SUBSTR(oXml:OWSERRO:OWSLOTENFE[nLastRet]:cHORALOTE,1,5) 
						//SF3->F3_CODNFE	:= IIF(!Empty(aXml[nLastXml][1]),aXml[nLastXml][1],"")
							If !Empty(aXML) .And. !Empty(aXml[nLastXml][2]) .And. !Empty(aXml[nLastXml][1]) // Inserida verificação do protocolo, antes de gravar a Chave.
								SF3->F3_CHVNFE  := SubStr(NfeIdSPED(aXML[nLastXml][2],"Id"),4)
							EndIf
							MsUnLock()
							SF3->(dbSkip())
						EndDo
					EndIf
				  	
			  	//Atualizo SFT
					SFT->(dbSetOrder(1))
					cChave := xFilial("SFT")+"S"+SF2->F2_SERIE+SF2->F2_DOC+SF2->F2_CLIENTE+SF2->F2_LOJA
					If SFT->(MsSeek(xFilial("SFT")+"S"+SF2->F2_SERIE+SF2->F2_DOC+SF2->F2_CLIENTE+SF2->F2_LOJA,.T.))
						Do While cChave == xFilial("SFT")+"S"+SFT->FT_SERIE+SFT->FT_NFISCAL+SFT->FT_CLIEFOR+SFT->FT_LOJA .And. !SFT->(Eof())
							RecLock("SFT",.F.)
						//SFT->FT_NFELETR	:= SUBSTR(oXml:Cid,4,9)
						//SFT->FT_EMINFE	:= oXml:OWSERRO:OWSLOTENFE[nLastRet]:DDATALOTE
						//SFT->FT_HORNFE	:= STRTRAN(oXml:OWSERRO:OWSLOTENFE[nLastRet]:CHORALOTE,":","")//SUBSTR(oXml:OWSERRO:OWSLOTENFE[nLastRet]:cHORALOTE,1,5) 
						//SFT->FT_CODNFE	:= IIF(!Empty(aXml[nLastXml][1]),aXml[nLastXml][1],"")
							If !Empty(aXML) .And. !Empty(aXml[nLastXml][2]).And. !Empty(aXml[nLastXml][1]) // Inserida verificação do protocolo, antes de gravar a Chave.
								SFT->FT_CHVNFE  := SubStr(NfeIdSPED(aXML[nLastXml][2],"Id"),4)
							EndIf
							MsUnLock()
							SFT->(dbSkip())
						EndDo
					EndIf
				ElseIf !Empty(SF3->F3_DTCANC) .and. SubStr(SF3->F3_CFO,1,1)>="5" //Alimenta Chave da NFe Cancelada na F3/FT ao consultar o monitorfaixa
					SF3->(dbSetOrder(4))
					cChaveF3 := xFilial("SF3")+SF3->F3_CLIEFOR+SF3->F3_LOJA+SF3->F3_NFISCAL+SF3->F3_SERIE
					cChaveFT := xFilial("SFT")+"S"+SF3->F3_SERIE+SF3->F3_NFISCAL+SF3->F3_CLIEFOR+SF3->F3_LOJA
					SF3->(dbSeek(cChaveF3,.T.))
					While !SF3->(Eof()) .And. xFilial("SF3")+SF3->F3_CLIEFOR+SF3->F3_LOJA+SF3->F3_NFISCAL+SF3->F3_SERIE == cChaveF3
						RecLock("SF3",.F.)
						If !Empty(aXML) .And. !Empty(aXml[nLastXml][2]) .And. !Empty(aXml[nLastXml][1]) // Inserida verificação do protocolo, antes de gravar a Chave.
							SF3->F3_CHVNFE  := SubStr(NfeIdSPED(aXML[nLastXml][2],"Id"),4)
						EndIf
						MsUnLock()
						SF3->(dbSkip())
					EndDo
				
					SFT->(dbSetOrder(1))
					SFT->(dbSeek(cChaveFT,.T.))
					While !SFT->(Eof()) .And. xFilial("SFT")+"S"+SFT->FT_SERIE+SFT->FT_NFISCAL+SFT->FT_CLIEFOR+SFT->FT_LOJA == cChaveFT
						RecLock("SFT",.F.)
						If !Empty(aXML) .And. !Empty(aXml[nLastXml][2]).And. !Empty(aXml[nLastXml][1]) // Inserida verificação do protocolo, antes de gravar a Chave.
							SFT->FT_CHVNFE  := SubStr(NfeIdSPED(aXML[nLastXml][2],"Id"),4)
						EndIf
						MsUnLock()
						SFT->(dbSkip())
					EndDo
				EndIf
			
			//Nota de entrada
				dbSelectArea("SF1")
				dbSetOrder(1)
				If SF1->(MsSeek(xFilial("SF1")+PadR(SUBSTR(oXml:Cid,4,Len(oXml:Cid)),nSX3SF2)+SUBSTR(oXml:Cid,1,3),.T.)) .And. nLastXml > 0 .And. !Empty(aXml)
					If SF1->(FieldPos("F1_HORA"))<>0 .And. (Empty(SF1->F1_HORA) .OR. Empty(SF1->F1_NFELETR) .Or. Empty(SF1->F1_EMINFE) .Or.Empty(SF1->F1_HORNFE) .Or. Empty(SF1->F1_CODNFE) .Or. (SF1->(FieldPos("F1_CHVNFE"))>0 .And. Empty(SF1->F1_CHVNFE)))
						RecLock("SF1")
		   			//SF1->F1_HORA	:= SUBSTR(oXml:OWSERRO:OWSLOTENFE[nLastRet]:cHORALOTE,1,5)
					//SF1->F1_NFELETR := SUBSTR(oXml:Cid,4,9)
					//SF1->F1_EMINFE	:= oXml:OWSERRO:OWSLOTENFE[nLastRet]:DDATALOTE
					//SF1->F1_HORNFE	:= STRTRAN(oXml:OWSERRO:OWSLOTENFE[nLastRet]:CHORALOTE,":","")//SUBSTR(oXml:OWSERRO:OWSLOTENFE[nLastRet]:cHORALOTE,1,5) 
					//SF1->F1_CODNFE	:= IIF(!Empty(aXml[nLastXml][1]),aXml[nLastXml][1],"")
						If !Empty(aXML) .And.!Empty(aXml[nLastXml][2]).And. !Empty(aXml[nLastXml][1]) // Inserida verificação do protocolo, antes de gravar a Chave.
							SF1->F1_CHVNFE  := SubStr(NfeIdSPED(aXML[nLastXml][2],"Id"),4)
						EndIf
						MsUnlock()
					EndIf
			
				//Atualizo SF3
					SF3->(dbSetOrder(4))
					cChave := xFilial("SF3")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE
					If SF3->(MsSeek(xFilial("SF3")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE,.T.))
						Do While cChave == xFilial("SF3")+SF3->F3_CLIEFOR+SF3->F3_LOJA+SF3->F3_NFISCAL+SF3->F3_SERIE .And. !SF3->(Eof())
							RecLock("SF3",.F.)
						//SF3->F3_NFELETR	:= SUBSTR(oXml:Cid,4,9)
						//SF3->F3_EMINFE	:= oXml:OWSERRO:OWSLOTENFE[nLastRet]:DDATALOTE
						//SF3->F3_HORNFE	:= STRTRAN(oXml:OWSERRO:OWSLOTENFE[nLastRet]:CHORALOTE,":","")//SUBSTR(oXml:OWSERRO:OWSLOTENFE[nLastRet]:cHORALOTE,1,5) 
						//SF3->F3_CODNFE	:= IIF(!Empty(aXml[nLastXml][1]),aXml[nLastXml][1],"")
							If !Empty(aXML) .And.!Empty(aXml[nLastXml][2]).And. !Empty(aXml[nLastXml][1]) // Inserida verificação do protocolo, antes de gravar a Chave.
								SF3->F3_CHVNFE  := SubStr(NfeIdSPED(aXML[nLastXml][2],"Id"),4)
							EndIf
							MsUnLock()
							SF3->(dbSkip())
						EndDo
					EndIf
				
			  	//Atualizo SFT
					SFT->(dbSetOrder(1))
					cChave := xFilial("SFT")+"E"+SF1->F1_SERIE+SF1->F1_DOC+SF1->F1_FORNECE+SF1->F1_LOJA
					If SFT->(MsSeek(xFilial("SFT")+"E"+SF1->F1_SERIE+SF1->F1_DOC+SF1->F1_FORNECE+SF1->F1_LOJA,.T.))
						Do While cChave == xFilial("SFT")+"E"+SFT->FT_SERIE+SFT->FT_NFISCAL+SFT->FT_CLIEFOR+SFT->FT_LOJA .And. !SFT->(Eof())
							RecLock("SFT",.F.)
						//SFT->FT_NFELETR	:= SUBSTR(oXml:Cid,4,9)
						//SFT->FT_EMINFE	:= oXml:OWSERRO:OWSLOTENFE[nLastRet]:DDATALOTE
						//SFT->FT_HORNFE	:= STRTRAN(oXml:OWSERRO:OWSLOTENFE[nLastRet]:CHORALOTE,":","")//SUBSTR(oXml:OWSERRO:OWSLOTENFE[nLastRet]:cHORALOTE,1,5) 
						//SFT->FT_CODNFE	:=IIF(!Empty(aXml[nLastXml][1]),aXml[nLastXml][1],"")
							If !Empty(aXML) .And.!Empty(aXml[nLastXml][2]).And. !Empty(aXml[nLastXml][1]) // Inserida verificação do protocolo, antes de gravar a Chave.
								SFT->FT_CHVNFE  := SubStr(NfeIdSPED(aXML[nLastXml][2],"Id"),4)
							EndIf
							MsUnLock()
							SFT->(dbSkip())
						EndDo
					EndIf
				ElseIf !Empty(SF3->F3_DTCANC) .and. SubStr(SF3->F3_CFO,1,1)<"5" //Alimenta Chave da NFe Cancelada na F3/FT  ao consultar o monitorfaixa
					SF3->(dbSetOrder(4))
					cChaveF3 := xFilial("SF3")+SF3->F3_CLIEFOR+SF3->F3_LOJA+SF3->F3_NFISCAL+SF3->F3_SERIE
					cChaveFT := xFilial("SFT")+"E"+SF3->F3_SERIE+SF3->F3_NFISCAL+SF3->F3_CLIEFOR+SF3->F3_LOJA
					SF3->(dbSeek(cChaveF3,.T.))
					While !SF3->(Eof()) .And. xFilial("SF3")+SF3->F3_CLIEFOR+SF3->F3_LOJA+SF3->F3_NFISCAL+SF3->F3_SERIE == cChaveF3
						RecLock("SF3",.F.)
						If !Empty(aXML) .And. !Empty(aXml[nLastXml][2]) .And. !Empty(aXml[nLastXml][1]) // Inserida verificação do protocolo, antes de gravar a Chave.
							SF3->F3_CHVNFE  := SubStr(NfeIdSPED(aXML[nLastXml][2],"Id"),4)
						EndIf
						MsUnLock()
						SF3->(dbSkip())
					EndDo
				
					SFT->(dbSetOrder(1))
					SFT->(dbSeek(cChaveFT,.T.))
					While !SFT->(Eof()) .And. xFilial("SFT")+"E"+SFT->FT_SERIE+SFT->FT_NFISCAL+SFT->FT_CLIEFOR+SFT->FT_LOJA == cChaveFT
						RecLock("SFT",.F.)
						If !Empty(aXML) .And. !Empty(aXml[nLastXml][2]).And. !Empty(aXml[nLastXml][1]) // Inserida verificação do protocolo, antes de gravar a Chave.
							SFT->FT_CHVNFE  := SubStr(NfeIdSPED(aXML[nLastXml][2],"Id"),4)
						EndIf
						MsUnLock()
						SFT->(dbSkip())
					EndDo
				EndIf
			EndIf
			aadd(aListBox,{ IIf(Empty(oXml:cPROTOCOLO),oNo,oOk),;
				oXml:cID,;
				IIf(oXml:nAMBIENTE==1,"Produção","Homologação"),; //###
			IIf(oXml:nMODALIDADE==1 .Or. oXml:nMODALIDADE==4 .Or. oXml:nModalidade==6,"Normal","Contingência"),; //###
			oXml:cPROTOCOLO,;
				PadR(oXml:cRECOMENDACAO,250),;
				oXml:cTEMPODEESPERA,;
				oXml:nTEMPOMEDIOSEF,;
				aMsg})
			
			aXml 		:= {}
			nLastXml	:= 0
		Next nX
		If Empty(aListBox) .And. lMsg .And. !lCTe
			Aviso("SPED","",{"OK"})
		EndIf
    
		
	ElseIf !lOk .And. !lCTe .And. lMsg
		Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"OK"},3)
	EndIf

Return aListBox

/*/{Protheus.doc} fGetXMLNFE
Função que busca o xml no SEFAZ.
@author 	Ricardo Tavares Ferreira (ricardo.cientista2014@gmail.com)
@since 		20/09/2016
@version 	11.8
@return 	Array
@Obs		20/09/2016 - Construcao Inicial - Casas Brasileiras
/*/
//==========================================================================================================
	Static Function fGetXMLNFE(cIdEnt,aIdNFe,cModalidade)
//==========================================================================================================

Local cURL       := PadR(GetNewPar("MV_SPEDURL","http://localhost:8080/sped"),250)
Local oWS
Local cRetorno   := ""
Local cProtocolo := ""
Local cRetDPEC   := ""
Local cProtDPEC  := ""
Local nX         := 0
Local nY         := 0
Local nL			 := 0
Local aRetorno   := {}
Local aResposta  := {}
Local aFalta     := {}
Local aExecute   := {}
Local nLenNFe
Local nLenWS
Local cDHRecbto  := ""
Local cDtHrRec   := ""
Local cDtHrRec1	 := ""
Local nDtHrRec1  := 0
Local lFlag      := .T.
Local dDtRecib	:=	CToD("")

Private oDHRecbto

If Empty(cModalidade)
	oWS := WsSpedCfgNFe():New()
	oWS:cUSERTOKEN := "TOTVS"
	oWS:cID_ENT    := cIdEnt
	oWS:nModalidade:= 0
	oWS:_URL       := AllTrim(cURL)+"/SPEDCFGNFe.apw"
	If oWS:CFGModalidade()
		cModalidade    := SubStr(oWS:cCfgModalidadeResult,1,1)
	Else
		cModalidade    := ""
	EndIf
EndIf
oWS:= WSNFeSBRA():New()
oWS:cUSERTOKEN        := "TOTVS"
oWS:cID_ENT           := cIdEnt
oWS:oWSNFEID          := NFESBRA_NFES2():New()
oWS:oWSNFEID:oWSNotas := NFESBRA_ARRAYOFNFESID2():New()
nLenNFe := Len(aIdNFe)
For nX := 1 To nLenNFe
	aadd(aRetorno,{"","",aIdNfe[nX][4]+aIdNfe[nX][5],"","","",CToD("")})
	aadd(oWS:oWSNFEID:oWSNotas:oWSNFESID2,NFESBRA_NFESID2():New())
	Atail(oWS:oWSNFEID:oWSNotas:oWSNFESID2):cID := aIdNfe[nX][4]+aIdNfe[nX][5]
Next nX
oWS:nDIASPARAEXCLUSAO := 0
oWS:_URL := AllTrim(cURL)+"/NFeSBRA.apw"

If oWS:RETORNANOTASNX()
	If Len(oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5) > 0
		For nX := 1 To Len(oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5)
			cRetorno        := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSNFE:CXML
			cProtocolo      := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSNFE:CPROTOCOLO
			cDHRecbto  		:= oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSNFE:CXMLPROT
			If ValType(oWs:OWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:OWSDPEC)=="O"
				cRetDPEC        := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSDPEC:CXML
				cProtDPEC       := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSDPEC:CPROTOCOLO
			EndIf
			//Tratamento para gravar a hora da transmissao da NFe
			If !Empty(cProtocolo)
				oDHRecbto		:= XmlParser(cDHRecbto,"","","")
				cDtHrRec		:= IIf(Type("oDHRecbto:_ProtNFE:_INFPROT:_DHRECBTO:TEXT")<>"U",oDHRecbto:_ProtNFE:_INFPROT:_DHRECBTO:TEXT,"")
				oDHRecbto		:= NIL
				nDtHrRec1		:= RAT("T",cDtHrRec)
				
				If nDtHrRec1 <> 0
					cDtHrRec1   :=	SubStr(cDtHrRec,nDtHrRec1+1)
					dDtRecib	:=	SToD(StrTran(SubStr(cDtHrRec,1,AT("T",cDtHrRec)-1),"-",""))
				EndIf
				dbSelectArea("SF2")
				dbSetOrder(1)
				If MsSeek(xFilial("SF2")+aIdNFe[nX][5]+aIdNFe[nX][4]+aIdNFe[nX][6]+aIdNFe[nX][7])
					If SF2->(FieldPos("F2_HORA"))<>0 .And. Empty(SF2->F2_HORA)
						RecLock("SF2")
						SF2->F2_HORA := cDtHrRec1
						MsUnlock()
					EndIf
				EndIf
				dbSelectArea("SF1")
				dbSetOrder(1)
				If MsSeek(xFilial("SF1")+aIdNFe[nX][5]+aIdNFe[nX][4]+aIdNFe[nX][6]+aIdNFe[nX][7])
					If SF1->(FieldPos("F1_HORA"))<>0 .And. Empty(SF1->F1_HORA)
						RecLock("SF1")
						SF1->F1_HORA := cDtHrRec1
						MsUnlock()
					EndIf
				EndIf
			EndIf
			nY := aScan(aIdNfe,{|x| x[4]+x[5] == SubStr(oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:CID,1,Len(x[4]+x[5]))})
			If nY > 0
				aRetorno[nY][1] := cProtocolo
				aRetorno[nY][2] := cRetorno
				aRetorno[nY][4] := cRetDPEC
				aRetorno[nY][5] := cProtDPEC
				aRetorno[nY][6] := cDtHrRec1
				aRetorno[nY][7] := dDtRecib
				
				aadd(aResposta,aIdNfe[nY])
			EndIf
			cRetDPEC := ""
			cProtDPEC:= ""
		Next nX
		For nX := 1 To Len(aIdNfe)
			If aScan(aResposta,{|x| x[4] == aIdNfe[nX,04] .And. x[5] == aIdNfe[nX,05] })==0
				aadd(aFalta,aIdNfe[nX])
			EndIf
		Next nX
		If Len(aFalta)>0
			aExecute := GetXMLNFE(cIdEnt,aFalta,@cModalidade)
		Else
			aExecute := {}
		EndIf
		For nX := 1 To Len(aExecute)
			nY := aScan(aRetorno,{|x| x[3] == aExecute[nX][03]})
			If nY == 0
				aadd(aRetorno,{aExecute[nX][01],aExecute[nX][02],aExecute[nX][03]})
			Else
				aRetorno[nY][01] := aExecute[nX][01]
				aRetorno[nY][02] := aExecute[nX][02]
			EndIf
		Next nX
	EndIf
Else
	Aviso("DANFE",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"OK"},3)
EndIf

Return aRetorno

/*/{Protheus.doc} GetIdEnt
Função retorna as configuraçoes da fonte utilizada.
@author 	Ricardo Tavares Ferreira (ricardo.cientista2014@gmail.com)
@since 		20/09/2016
@version 	11.8
@return 	cIdEnt
@Obs		20/09/2016 - Construcao Inicial - Casas Brasileiras
/*/
//==========================================================================================================
	Static Function fFont(nTam,lTipo,_cFont)
//==========================================================================================================

	Local oFonte	:= NIL
	Default lTipo := .F.
	Default _cFont := "Arial"
	
	oFonte:=TFont():New(_cFont,,nTam,,lTipo,,,,,.f.)
	
Return oFonte

/*/{Protheus.doc} GetIdEnt
Função que faz retorna o ID da entidade  (Codigo Interno do Sped).
@author 	Ricardo Tavares Ferreira (ricardo.cientista2014@gmail.com)
@since 		20/09/2016
@version 	11.8
@return 	cIdEnt
@Obs		20/09/2016 - Construcao Inicial - Casas Brasileiras
/*/
//==========================================================================================================
	Static Function GetIdEnt()
//==========================================================================================================

	Local aArea  := GetArea()
	Local cIdEnt := ""
	Local cURL   := PadR(GetNewPar("MV_SPEDURL","http://"),250)
	//Local cURL   := PadR(GetNewPar("MV_NFCEURL","http://"),250)
	Local oWs
	Local lUsaGesEmp	:= IIF(FindFunction("FWFilialName") .And. FindFunction("FWSizeFilial") .And. FWSizeFilial() > 2,.T.,.F.)
	Local lEnvCodEmp := GetNewPar("MV_ENVCDGE",.F.)
	
	If	FunName() == "LOJA701"
		If !Empty(GetNewPar("MV_NFCEURL",""))
			cURL := PadR(GetNewPar("MV_NFCEURL","http://"),250)
		Endif
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Obtem o codigo da entidade                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	oWS := WsSPEDAdm():New()
	oWS:cUSERTOKEN := "TOTVS"
		
	oWS:oWSEMPRESA:cCNPJ       := IIF(SM0->M0_TPINSC==2 .Or. Empty(SM0->M0_TPINSC),SM0->M0_CGC,"")	
	oWS:oWSEMPRESA:cCPF        := IIF(SM0->M0_TPINSC==3,SM0->M0_CGC,"")
	oWS:oWSEMPRESA:cIE         := SM0->M0_INSC
	oWS:oWSEMPRESA:cIM         := SM0->M0_INSCM		
	oWS:oWSEMPRESA:cNOME       := SM0->M0_NOMECOM
	oWS:oWSEMPRESA:cFANTASIA   := IIF(lUsaGesEmp,FWFilialName(),Alltrim(SM0->M0_NOME))
	oWS:oWSEMPRESA:cENDERECO   := FisGetEnd(SM0->M0_ENDENT)[1]
	oWS:oWSEMPRESA:cNUM        := FisGetEnd(SM0->M0_ENDENT)[3]
	oWS:oWSEMPRESA:cCOMPL      := FisGetEnd(SM0->M0_ENDENT)[4]
	oWS:oWSEMPRESA:cUF         := SM0->M0_ESTENT
	oWS:oWSEMPRESA:cCEP        := SM0->M0_CEPENT
	oWS:oWSEMPRESA:cCOD_MUN    := SM0->M0_CODMUN
	oWS:oWSEMPRESA:cCOD_PAIS   := "1058"
	oWS:oWSEMPRESA:cBAIRRO     := SM0->M0_BAIRENT
	oWS:oWSEMPRESA:cMUN        := SM0->M0_CIDENT
	oWS:oWSEMPRESA:cCEP_CP     := Nil
	oWS:oWSEMPRESA:cCP         := Nil
	oWS:oWSEMPRESA:cDDD        := Str(FisGetTel(SM0->M0_TEL)[2],3)
	oWS:oWSEMPRESA:cFONE       := AllTrim(Str(FisGetTel(SM0->M0_TEL)[3],15))
	oWS:oWSEMPRESA:cFAX        := AllTrim(Str(FisGetTel(SM0->M0_FAX)[3],15))
	oWS:oWSEMPRESA:cEMAIL      := UsrRetMail(RetCodUsr())
	oWS:oWSEMPRESA:cNIRE       := SM0->M0_NIRE
	oWS:oWSEMPRESA:dDTRE       := SM0->M0_DTRE
	oWS:oWSEMPRESA:cNIT        := IIF(SM0->M0_TPINSC==1,SM0->M0_CGC,"")
	oWS:oWSEMPRESA:cINDSITESP  := ""
	oWS:oWSEMPRESA:cID_MATRIZ  := ""

	If lUsaGesEmp .And. lEnvCodEmp
		oWS:oWSEMPRESA:CIDEMPRESA:= FwGrpCompany()+FwCodFil()
	EndIf

	oWS:oWSOUTRASINSCRICOES:oWSInscricao := SPEDADM_ARRAYOFSPED_GENERICSTRUCT():New()
	oWS:_URL := AllTrim(cURL)+"/SPEDADM.apw"
	If oWs:ADMEMPRESAS()
		cIdEnt  := oWs:cADMEMPRESASRESULT
	Else
		Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"Fechar"},3)
	EndIf
	
	FreeObj(oWs)
	oWs := nil
	
	RestArea(aArea)
	aArea := aSize(aArea,0)
	aArea := nil

Return cIdEnt

/*/{Protheus.doc} RT05A002H
Funçao para consultar a Numeração da Nota Fiscal de Saida tabela SX5 e SF3.
@author 	Ricardo Tavares Ferreira
@since 		12/09/2018
@version 	12.1.17
@return 	Nulo
@Obs 		Ricardo Tavares - Construcao Inicial
/*/
//==========================================================================================================
	Static Function RT05A002H()
//==========================================================================================================

	Local oBtnConf	:= Nil
	Local oBtnEdit	:= Nil
	Private Odlg 	:= Nil
	Private cSerX5	:= ""
	Private cNFSX5	:= ""
	Private cSerF3	:= ""
	Private cNFSF3	:= ""
	Private lEditC	:= .F.
	Private aNfSer  := {}
	
	aNfSer := GET_NFSER()
	
	cSerX5	:= aNfSer[4]
	cNFSX5	:= aNfSer[3]
	cSerF3	:= aNfSer[2]
	cNFSF3	:= aNfSer[1]
	
	Define MsDialog Odlg Title OemToAnsi("Consulta - Numeração de NF-e") style 128 From 000 , 000 To 180 , 280 Pixel
	
	Odlg:lEscClose := .F. 
	
	TGroup():New(003,003,030,140,"Numeração no SEFAZ",Odlg,CLR_GREEN,CLR_WHITE,.T.,.F. )
	@ 012 , 008 MsGet cSerF3	Size 25,10 	Of Odlg Pixel WHEN .F. Picture PesqPict("SF3","F3_SERIE") Valid NaoVazio()
	@ 014 , 038 Say " - "		Size 05,10 	Of Odlg Pixel 
	@ 012 , 048 MsGet cNFSF3	Size 88,10 	Of Odlg Pixel WHEN .F. Picture PesqPict("SF3","F3_NFISCAL") Valid NaoVazio()

	TGroup():New(035,003,062,140,"Próximo Número da Nota Fiscal",Odlg,CLR_GREEN,CLR_WHITE,.T.,.F. )
	@ 044 , 008 MsGet cSerX5	Size 25,10 	Of Odlg Pixel WHEN .F. Picture PesqPict("SF3","F3_SERIE") Valid NaoVazio()
	@ 046 , 038 Say " - "		Size 05,10 	Of Odlg Pixel 
	@ 044 , 048 MsGet cNFSX5	Size 88,10 	Of Odlg Pixel WHEN lEditC Picture PesqPict("SF3","F3_NFISCAL") Valid NaoVazio()
	
	@ 070 , 019 BUTTON oBtnEdit PROMPT "Editar"		Size 50,13 	OF Odlg ACTION(PUT_EDIT())  Pixel
	@ 070 , 075 BUTTON oBtnConf PROMPT "Confirmar"	Size 50,13 	OF Odlg ACTION(PUT_NUM())  Pixel
		
	Activate MsDialog Odlg Centered 

Return

/*/{Protheus.doc} PUT_EDIT
Funçao utilizada para editar o campo de numeração da SX5.
@author 	Ricardo Tavares Ferreira
@since 		12/09/2018
@version 	12.1.17
@return 	Nulo
@Obs 		Ricardo Tavares - Construcao Inicial
/*/
//==========================================================================================================
	Static Function PUT_EDIT()
//==========================================================================================================
	
	lEditC := .T.
Return 

/*/{Protheus.doc} PUT_NUM
Funçao utilizada para gravar o conteudo digitado pelo usuario no campo de numeração da SX5.
@author 	Ricardo Tavares Ferreira
@since 		12/09/2018
@version 	12.1.17
@return 	Nulo
@Obs 		Ricardo Tavares - Construcao Inicial
/*/
//==========================================================================================================
	Static Function PUT_NUM()
//==========================================================================================================
	
	DbSelectArea("SX5")
	SX5->(DbSetOrder(1))
	
	If lEditC
		If cNFSX5 <> aNfSer[3]
			If SX5->(DbSeek(FWXFilial("SX5")+"01"+cSerX5))
				Reclock("SX5",.F.)
					SX5->X5_DESCRI  := cNFSX5
					SX5->X5_DESCSPA := cNFSX5
					SX5->X5_DESCENG := cNFSX5
				SX5->(MsUnlock())
			EndIf
		EndIf
	EndIf
	Odlg:End()
Return 

/*/{Protheus.doc} GET_NFSER
Funçao utilizada para consultar a ultima numeração da nota fiscal no sistema.
@author 	Ricardo Tavares Ferreira
@since 		12/09/2018
@version 	12.1.17
@return 	Array
@Obs 		Ricardo Tavares - Construcao Inicial
/*/
//==========================================================================================================
	Static Function GET_NFSER()
//==========================================================================================================
	
	Local cQuery	:= ""
	Local QBLINHA	:= chr(13)+chr(10)
	Local cSerieF3  := ""
	Local cNumNfF3  := ""
	Local cSerieX5  := ""
	Local cNumNfX5  := ""
	Local NQTREG    := 0
	
	cQuery := "SELECT "+QBLINHA
	cQuery += "X5_CHAVE SERIE "+QBLINHA
	cQuery += ", X5_DESCRI NF "+QBLINHA
	cQuery += "FROM " 
	cQuery +=  RetSqlName("SX5") + " SX5 "+QBLINHA
	cQuery += "WHERE "+QBLINHA
	cQuery += "SX5.D_E_L_E_T_ = ' ' "+QBLINHA 
	cQuery += "AND X5_FILIAL = '"+ FWXFilial("SX5") +"' "+QBLINHA
	cQuery += "AND X5_TABELA = '01' "+QBLINHA
	cQuery += "AND X5_CHAVE = '1' "+QBLINHA
	
	If Select("TMP1") > 0 
		TMP1->(DBCLOSEAREA())
	EndIf
	
	MEMOWRITE("C:/ricardo/GET_NFSER_SX5.sql",cQuery)			     
	cQuery := ChangeQuery(cQuery)
	DBUSEAREA(.T.,'TOPCONN',TcGenQry(,,cQuery),"TMP1",.F.,.T.)
		
	DBSELECTAREA("TMP1")
	TMP1->(DBGOTOP())
	COUNT To NQTREG
	TMP1->(DBGOTOP())
		
	If NQTREG <= 0
		TMP1->(DBCLOSEAREA())
	Else
		While !TMP1->(EOF())
			cSerieX5  := TMP1->SERIE
			cNumNfX5  := TMP1->NF
			TMP1->(DBSKIP())
		End
		TMP1->(DBCLOSEAREA())
	EndIf
	
	NQTREG := 0
	
	cQuery := "SELECT TOP 1 "+QBLINHA
	cQuery += "F3_NFISCAL NF "+QBLINHA
	cQuery += ", F3_SERIE SERIE "+QBLINHA
	cQuery += "FROM " 
	cQuery +=  RetSqlName("SF3") + " SF3 "+QBLINHA
	cQuery += "WHERE "+QBLINHA 
	cQuery += "SF3.D_E_L_E_T_ = ' ' "+QBLINHA 
	cQuery += "AND F3_FILIAL = '"+FWXFilial("SF3")+"' "+QBLINHA 
	cQuery += "ORDER BY SF3.R_E_C_N_O_ DESC "+QBLINHA
	
	If Select("TMP1") > 0 
		TMP1->(DBCLOSEAREA())
	EndIf
	
	MEMOWRITE("C:/ricardo/GET_NFSER_SF3.sql",cQuery)			     
	cQuery := ChangeQuery(cQuery)
	DBUSEAREA(.T.,'TOPCONN',TcGenQry(,,cQuery),"TMP1",.F.,.T.)
		
	DBSELECTAREA("TMP1")
	TMP1->(DBGOTOP())
	COUNT To NQTREG
	TMP1->(DBGOTOP())
		
	If NQTREG <= 0
		TMP1->(DBCLOSEAREA())
	Else
		While !TMP1->(EOF())
			cSerieF3  := TMP1->SERIE
			cNumNfF3  := TMP1->NF
			TMP1->(DBSKIP())
		End
		TMP1->(DBCLOSEAREA())
	EndIf
	
Return {cNumNfF3,cSerieF3,cNumNfX5,cSerieX5}

/*/{Protheus.doc} CRIA_PAR
Funçao que cria os parametros com informações pre selecionadas.
@author 	Ricardo Tavares Ferreira
@since 		20/07/2018
@version 	12.1.17
@return 	Nulo
@Obs 		Ricardo Tavares - Construcao Inicial
/*/
//==========================================================================================================
	Static Function CRIA_PAR(cPerg)
//==========================================================================================================
	
	Local aPerg := {}
	Local aHelp := {}
	
	// Array com os help das perguntas (aHelp)
	// aHelp [1] = Ordem da pergunta
	// aHelp [2] = Help a ser exibido
	
	//AADD(aHelp,{'01',{" Condição de Pagamento Padrão de Venda Utilizada."} })
	//AADD(aHelp,{'02',{" Transportadora Padrao Utilizada para a o Carregamento do Produto."} })
	//AADD(aHelp,{'03',{" Produto Padrao de Venda utilizado na Ordem de Carregamento."} })
	//AADD(aHelp,{'04',{" Motorista Padrao utilizado na Ordem de Carregamento."} })		
	//AADD(aHelp,{'05',{" Veiculo Padrao utilizado na Ordem de Carregamento."} })		
		
	AaDd(aPerg,{'01','Cond. Pgto.'		,'','','MV_CH1','C',TamSX3("ZA_CONDPAG")[1]	,00,00,'G','Vazio() .Or. ExistCPO("SE4")','MV_PAR01','','','','','','','','','','','','','','','','','','','','','','','','','SE4','S','','','',''})
	AaDd(aPerg,{'02','Transportadora'	,'','','MV_CH2','C',TamSX3("ZA_TRANSP")[1]	,00,00,'G','Vazio() .Or. ExistCPO("SA4")','MV_PAR02','','','','','','','','','','','','','','','','','','','','','','','','','SA4','S','','','',''})
	AaDd(aPerg,{'03','Produto'			,'','','MV_CH3','C',TamSX3("ZB_PRODUTO")[1]	,00,00,'G','Vazio() .Or. ExistCPO("SB1")','MV_PAR03','','','','','','','','','','','','','','','','','','','','','','','','','SB1','S','','','',''})
	AaDd(aPerg,{'04','Cliente'			,'','','MV_CH4','C',TamSX3("ZA_CLIENTE")[1]	,00,00,'G',''							 ,'MV_PAR04','','','','','','','','','','','','','','','','','','','','','','','','','SA1','S','','','',''})
	AaDd(aPerg,{'05','Loja'				,'','','MV_CH5','C',TamSX3("ZA_LOJA")[1]	,00,00,'G',''							 ,'MV_PAR05','','','','','','','','','','','','','','','','','','','','','','','','','   ','S','','','',''})
	AaDd(aPerg,{'06','Natureza'			,'','','MV_CH6','C',TamSX3("ZA_NATUR")[1]	,00,00,'G','Vazio() .Or. ExistCPO("SED")','MV_PAR06','','','','','','','','','','','','','','','','','','','','','','','','','SED','S','','','',''})
	AaDd(aPerg,{'07','Iipo Ent./Sai.'	,'','','MV_CH7','C',TamSX3("ZB_TES")[1]		,00,00,'G','Vazio() .Or. ExistCPO("SF4")','MV_PAR07','','','','','','','','','','','','','','','','','','','','','','','','','SF4','S','','','',''})
	AaDd(aPerg,{'08','Perc. Umidade'	,'','','MV_CH8','N',04						,02,00,'G',''					 		 ,'MV_PAR08','','','','','','','','','','','','','','','','','','','','','','','','','   ','S','','','',''})

	AjustaSX1(cPerg,aPerg,aHelp)
	
	Pergunte(cPerg,.T.)
	
Return 

/*/{Protheus.doc} AjustaSX1
Funçao que cria os as perguntas na tabela SX1
@author 	Ricardo Tavares Ferreira
@since 		20/07/2018
@version 	12.1.17
@return 	Nulo
@Obs 		Ricardo Tavares - Construcao Inicial
/*/
//==========================================================================================================
	Static Function AjustaSX1( cPerg, aPerg, aHelp )
//==========================================================================================================

	Local aArea := GetArea()
	Local aCpoPerg := {}
	Local nX := 0
	Local nY := 0
	
	// DEFINE ESTRUTUA DO ARRAY DAS PERGUNTAS COM AS PRINCIPAIS INFORMACOES
	AADD( aCpoPerg, 'X1_ORDEM' )
	AADD( aCpoPerg, 'X1_PERGUNT' )
	AADD( aCpoPerg, 'X1_PERSPA' )
	AADD( aCpoPerg, 'X1_PERENG' )
	AADD( aCpoPerg, 'X1_VARIAVL' )
	AADD( aCpoPerg, 'X1_TIPO' )
	AADD( aCpoPerg, 'X1_TAMANHO' )
	AADD( aCpoPerg, 'X1_DECIMAL' )
	AADD( aCpoPerg, 'X1_PRESEL' )
	AADD( aCpoPerg, 'X1_GSC' )
	AADD( aCpoPerg, 'X1_VALID' )
	AADD( aCpoPerg, 'X1_VAR01' )
	AADD( aCpoPerg, 'X1_DEF01' )
	AADD( aCpoPerg, 'X1_DEFSPA1' )
	AADD( aCpoPerg, 'X1_DEFENG1' )
	AADD( aCpoPerg, 'X1_CNT01' )
	AADD( aCpoPerg, 'X1_VAR02' )
	AADD( aCpoPerg, 'X1_DEF02' )
	AADD( aCpoPerg, 'X1_DEFSPA2' )
	AADD( aCpoPerg, 'X1_DEFENG2' )
	AADD( aCpoPerg, 'X1_CNT02' )
	AADD( aCpoPerg, 'X1_VAR03' )
	AADD( aCpoPerg, 'X1_DEF03' )
	AADD( aCpoPerg, 'X1_DEFSPA3' )
	AADD( aCpoPerg, 'X1_DEFENG3' )
	AADD( aCpoPerg, 'X1_CNT03' )
	AADD( aCpoPerg, 'X1_VAR04' )
	AADD( aCpoPerg, 'X1_DEF04' )
	AADD( aCpoPerg, 'X1_DEFSPA4' )
	AADD( aCpoPerg, 'X1_DEFENG4' )
	AADD( aCpoPerg, 'X1_CNT04' )
	AADD( aCpoPerg, 'X1_VAR05' )
	AADD( aCpoPerg, 'X1_DEF05' )
	AADD( aCpoPerg, 'X1_DEFSPA5' )
	AADD( aCpoPerg, 'X1_DEFENG5' )
	AADD( aCpoPerg, 'X1_CNT05' )
	AADD( aCpoPerg, 'X1_F3' )
	AADD( aCpoPerg, 'X1_PYME' )
	AADD( aCpoPerg, 'X1_GRPSXG' )
	AADD( aCpoPerg, 'X1_HELP' )
	AADD( aCpoPerg, 'X1_PICTURE' )
	AADD( aCpoPerg, 'X1_IDFIL' )
	DBSelectArea( "SX1" )
	DBSetOrder( 1 )
	
	For nX := 1 To Len( aPerg )
		IF !DBSeek( PADR(cPerg,10) + aPerg[nX][1] )
			RecLock( "SX1", .T. ) // Inclui
		Else
			RecLock( "SX1", .F. ) // Altera
		Endif
		// Grava informacoes dos campos da SX1
		For nY := 1 To Len( aPerg[nX] )
			If aPerg[nX][nY] <> NIL
				If nY <> 16
					SX1->( &( aCpoPerg[nY] ) ) := aPerg[nX][nY]
				EndIf
			EndIf
		Next
		SX1->X1_GRUPO := PADR(cPerg,10)
		MsUnlock() // Libera Registro
		// Verifica se campo possui Help
		_nPosHelp := aScan(aHelp,{|x| x[1] == aPerg[nX][1]})
		IF (_nPosHelp > 0)
			cNome := "P."+TRIM(cPerg)+ aHelp[_nPosHelp][1]+"."
			PutSX1Help(cNome,aHelp[_nPosHelp][2],{},{},.T.)
		Else
			// Apaga help ja existente.
			cNome := "P."+TRIM(cPerg)+ aPerg[nX][1]+"."
			PutSX1Help(cNome,{" "},{},{},.T.)
		Endif
	Next
	
	// Apaga perguntas nao definidas no array
	DBSEEK(cPerg,.T.)
	DO WHILE SX1->(!Eof()) .And. SX1->X1_GRUPO == cPerg
		IF ASCAN(aPerg,{|Y| Y[1] == SX1->X1_ORDEM}) == 0
			Reclock("SX1", .F.)
			SX1->(DBDELETE())
			Msunlock()
		ENDIF
		SX1->(DBSKIP())
	ENDDO
	RestArea( aArea ) 
	
Return