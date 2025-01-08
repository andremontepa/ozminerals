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

/*/{Protheus.doc} RT34A001
Rotina em MVC que realiza a amarracao entre os cadastros de Centro de Custo x Itens Contabeis x Classe Valor 
@author 	Ricardo Tavares Ferreira
@since 		13/08/2018
@version 	12.1.17
@return 	oBrowse
@Obs 		Ricardo Tavares - Construcao Inicial
/*/
//==========================================================================================================
	User Function RT34A001()
//==========================================================================================================

	Local oBrowse 		:= Nil
	Local aCampos		:= Nil
	Private cCamposSZ5	:= ""	
	Private cCamposSZ6	:= ""	
	Private cCamposSZ7	:= ""	
	Private cTitulo		:= OemtoAnsi("Centro Custo x Item Contábil x Classe Valor")
	
	DbSelectArea("SZ5")
	DbSelectArea("SZ6")
	DbSelectArea("SZ7")
	
	DbSelectArea("CTT")
	CTT->(DbSetOrder(1))
	
	DbSelectArea("CTD")
	CTD->(DbSetOrder(1))
	
	DbSelectArea("CTH")
	CTH->(DbSetOrder(1))
	
	aCampos := SZ5->(DBSTRUCT())
	
	For n := 2 To Len(aCampos)
		cCamposSZ5 += aCampos[n][1]
		cCamposSZ5 += iif((n) < Len(aCampos),";","")
	Next
	
	aCampos	:= Nil
	aCampos := SZ6->(DBSTRUCT())
	
	For n := 2 To Len(aCampos)
		cCamposSZ6 += aCampos[n][1]
		cCamposSZ6 += iif((n) < Len(aCampos),";","")
	Next
	
	aCampos	:= Nil
	aCampos := SZ7->(DBSTRUCT())
	
	For n := 2 To Len(aCampos)
		cCamposSZ7 += aCampos[n][1]
		cCamposSZ7 += iif((n) < Len(aCampos),";","")
	Next
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("SZ5")
	oBrowse:AddLegend("Z5_STATUS == '1' "	, "GREEN" , "Ativo" )
	oBrowse:AddLegend("Z5_STATUS == '2' "	, "RED"   , "Inativo" )
	oBrowse:SetDescription(cTitulo)
	oBrowse:SetMenuDef("RT34A001")
	oBrowse:Activate()
	
Return oBrowse

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

	Local oModel		:= Nil
	Local oEst_M_SZ5	:= Nil
	Local oEst_M_SZ6	:= Nil
	Local oEst_M_SZ7	:= Nil
	
	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New("RT34AMOD",{|oModel| PreValida(oModel)},/*{|oModel| PosValida(oModel)}*/,/*{|oModel| GravaDados( oModel )}*/) 
	
	// Cria o Objeto da Estrutura dos Campos da tabela
	oEst_M_SZ5 := FWFormStruct(1,"SZ5",{|cCampo| ( Alltrim(cCampo) $ cCamposSZ5 )})
	oEst_M_SZ6 := FWFormStruct(1,"SZ6",{|cCampo| ( Alltrim(cCampo) $ cCamposSZ6 )})
	oEst_M_SZ7 := FWFormStruct(1,"SZ7",{|cCampo| ( Alltrim(cCampo) $ cCamposSZ7 )})
	
	// Funcao que executa o gatilho de preenchimento da descricao dos campos
	oEst_M_SZ5:AddTrigger("Z5_CCUSTO","Z5_DESCCC",{ || .T. },{|| oModel := FwModelActive(),Posicione("CTT",1,xFilial("CTT")+oModel:GetModel("M_SZ5"):GetValue("Z5_CCUSTO"),"CTT_DESC01")})
	
	oEst_M_SZ6:AddTrigger("Z6_CODITEM","Z6_DESCITE",{ || .T. },{|| oModel := FwModelActive(),Posicione("CTD",1,xFilial("CTD")+oModel:GetModel("M_SZ6"):GetValue("Z6_CODITEM"),"CTD_DESC01")})
	oEst_M_SZ6:AddTrigger("Z6_CODITEM","Z6_CCUSTO",{ || .T. },{|| oModel := FwModelActive(),oModel:GetModel("M_SZ5"):GetValue("Z5_CCUSTO")})
	oEst_M_SZ6:AddTrigger("Z6_CODITEM","Z6_COD",{ || .T. },{|| oModel := FwModelActive(),oModel:GetModel("M_SZ5"):GetValue("Z5_COD")})
	oEst_M_SZ6:AddTrigger("Z6_CODITEM","Z6_STATUS",{ || .T. },{|| oModel := FwModelActive(),oModel:GetModel("M_SZ5"):GetValue("Z5_STATUS")})
	
	oEst_M_SZ7:AddTrigger("Z7_CODCVL","Z7_DESCCVL",{ || .T. },{|| oModel := FwModelActive(),Posicione("CTH",1,xFilial("CTH")+oModel:GetModel("M_SZ7"):GetValue("Z7_CODCVL"),"CTH_DESC01")})
	oEst_M_SZ7:AddTrigger("Z7_CODCVL","Z7_CCUSTO",{ || .T. },{|| oModel := FwModelActive(),oModel:GetModel("M_SZ6"):GetValue("Z6_CCUSTO")})
	oEst_M_SZ7:AddTrigger("Z7_CODCVL","Z7_CODITEM",{ || .T. },{|| oModel := FwModelActive(),oModel:GetModel("M_SZ6"):GetValue("Z6_CODITEM")})
	oEst_M_SZ7:AddTrigger("Z7_CODCVL","Z7_COD",{ || .T. },{|| oModel := FwModelActive(),oModel:GetModel("M_SZ6"):GetValue("Z6_COD")})
	oEst_M_SZ7:AddTrigger("Z7_CODCVL","Z7_STATUS",{ || .T. },{|| oModel := FwModelActive(),oModel:GetModel("M_SZ6"):GetValue("Z6_STATUS")})
	
	
	// Adiciona ao modelo um componente de formulario
	oModel:AddFields("M_SZ5",/*cOwner*/,oEst_M_SZ5) 
	
	oModel:AddGrid("M_SZ6","M_SZ5",oEst_M_SZ6,{|oModel| PreValGrid1(oModel)})
	oModel:SetRelation("M_SZ6",;
	{{"Z6_FILIAL","xFilial('SZ6')"},;
	{"Z6_COD","Z5_COD"},;
	{"Z6_CCUSTO","Z5_CCUSTO"}},;
	SZ6->(IndexKey(1)))// Faz relacionamento entre os componentes do model
	
	oModel:AddGrid("M_SZ7","M_SZ6",oEst_M_SZ7,{|oModel| PrVlGd2(oModel)},/*{|oModel| PosValGrid2(oModel)}*/)
	oModel:SetRelation("M_SZ7",;
	{{"Z7_FILIAL","xFilial('SZ7')"},;
	{"Z7_COD","Z6_COD"},;
	{"Z7_CCUSTO","Z6_CCUSTO"},;
	{"Z7_CODITEM","Z6_CODITEM"}},;
	SZ7->(IndexKey(2)))// Faz relacionamento entre os componentes do model
	
	// Defino se a Grid Terá seu preenchimento obrigatorio.
	oModel:GetModel("M_SZ7"):SetOptional(.T.)
	 
	 // Seta a chave primaria que sera utilizada na gravacao dos dados na tabela 
	oModel:SetPrimaryKey({"Z5_FILIAL","Z5_COD","Z5_CCUSTO"})
	
	// Seta a descricao do modelo de dados no cabecalho
	oModel:getModel("M_SZ5"):SetDescription(OemToAnsi("Centro de Custo"))
	
	// Seta a descricao do modelo de dados no cabecalho
	oModel:getModel("M_SZ6"):SetDescription(OemtoAnsi("Itens Contábeis"))
	
	// Seta a descricao do modelo de dados no cabecalho
	oModel:getModel("M_SZ7"):SetDescription(OemtoAnsi("Classes Valor"))
	
	// Seto o Conteudo no campo para colocar o registro inicialmente como Ativo
	oEst_M_SZ5:SetProperty("Z5_STATUS",MODEL_FIELD_INIT,{||cValToChar(1)})
	//oEst_M_SZ5:SetProperty("Z5_CCUSTO",MODEL_FIELD_WHEN,"INCLUI")
	
	// Coloco uma regra para nao duplicar os itens contabeis na inclusao
	oModel:getModel("M_SZ6"):SetUniqueLine({"Z6_CODITEM"})
	
	// Coloco uma regra para nao duplicar os itens contabeis na inclusao
	oModel:getModel("M_SZ7"):SetUniqueLine({"Z7_CODCVL"})
	
	// Seto o Conteudo no campo 
	//oEst_M_SZ6:SetProperty("Z6_CCUSTO",MODEL_FIELD_INIT,{||oModel:GetModel("M_SZ5"):GetValue("Z5_CCUSTO")})
	
	// Seto o Conteudo no campo
	//oEst_M_SZ7:SetProperty("Z7_CCUSTO",MODEL_FIELD_INIT,{||oModel:GetModel("M_SZ6"):GetValue("Z6_CCUSTO")})
	//oEst_M_SZ7:SetProperty("Z7_CODITEM",MODEL_FIELD_INIT,{||oModel:GetModel("M_SZ6"):GetValue("Z6_CODITEM")})
	
	// Regras de Dependencia
	//oModel:AddRules("M_SZ6","Z6_CCUSTO","M_SZ5","Z5_CCUSTO",1)
		
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

	Local oView			:= Nil
	Local oModel		:= FWLoadModel("RT34A001") // Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
	Local oEst_V_SZ5	:= Nil		
	Local oEst_V_SZ6	:= Nil	
	Local oEst_V_SZ7	:= Nil	      
	
	//Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
	oEst_V_SZ5 := FWFormStruct(2,"SZ5",{|cCampo| ( Alltrim(cCampo) $ cCamposSZ5 )})
	oEst_V_SZ6 := FWFormStruct(2,"SZ6",{|cCampo| ( Alltrim(cCampo) $ cCamposSZ6 )})
	oEst_V_SZ7 := FWFormStruct(2,"SZ7",{|cCampo| ( Alltrim(cCampo) $ cCamposSZ7 )})
	
	// Cria o objeto de View
	oView := FWFormView():New()
	
	// Define qual o Modelo de dados sera utilizado na View
	oView:SetModel(oModel)	
	
	// Adiciona no nosso View um controle do tipo formulario
	oView:AddField("V_SZ5",oEst_V_SZ5,"M_SZ5",/*{|oModel| PreValida(oModel)}*/,/*{|oView| PosValida(oView)}*/)
	
	//Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
	oView:AddGrid("V_SZ6",oEst_V_SZ6,"M_SZ6",/*{|oModel| PreValida(oModel)}*/,/*{|oView| PosValida(oView)}*/)
	
	//Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
	oView:AddGrid("V_SZ7",oEst_V_SZ7,"M_SZ7",/*{|oModel| PreValida(oModel)}*/,/*{|oView| PosValida(oView)}*/)
	
	// Cria um "box" horizontal para receber cada elemento da view Pai
	oView:CreateHorizontalBox("V_SUP",30)
	oView:CreateHorizontalBox("V_MEIO",35)
	oView:CreateHorizontalBox("V_INF",35)
	
	// Relaciona o identificador (ID) da View com o "box" para exibicao Pai
	oView:SetOwnerView("V_SZ5","V_SUP")
	oView:SetOwnerView("V_SZ6","V_MEIO")
	oView:SetOwnerView("V_SZ7","V_INF")
	
	// Seta o Titulo no cabecalho do cadastro
	oView:EnableTitleView("V_SZ5",OemtoAnsi("Centro de Custo"))
	oView:EnableTitleView("V_SZ6",OemtoAnsi("Itens Contábeis"))
	oView:EnableTitleView("V_SZ7",OemtoAnsi("Classes Valor"))
	
	// Aplico o autoincremento no campo de itens da grid
	//oView:AddIncrementField("V_SZ6","Z6_ITEM")      
	
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
	
	ADD OPTION aRotina Title "Visualizar"		ACTION "VIEWDEF.RT34A001" OPERATION MODEL_OPERATION_VIEW		ACCESS 0
	ADD OPTION aRotina Title "Incluir" 			ACTION "VIEWDEF.RT34A001" OPERATION MODEL_OPERATION_INSERT		ACCESS 0
	ADD OPTION aRotina Title "Alterar" 			ACTION "VIEWDEF.RT34A001" OPERATION MODEL_OPERATION_UPDATE		ACCESS 0
	
	//If cCodGru == "000000" 
		ADD OPTION aRotina Title "Excluir" 		ACTION "VIEWDEF.RT34A001" OPERATION MODEL_OPERATION_DELETE 		ACCESS 0
	//EndIf
	
	ADD OPTION aRotina Title "Imprimir" 		ACTION "VIEWDEF.RT34A001" OPERATION MODEL_OPERATION_IMPR		ACCESS 0
	ADD OPTION aRotina Title "Copiar" 			ACTION "VIEWDEF.RT34A001" OPERATION MODEL_OPERATION_COPY	 	ACCESS 0
	ADD OPTION aRotina Title "Inativar/Ativar"	ACTION "StaticCall(RT34A001,RT34A001A)" OPERATION 9			 	ACCESS 0

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
	
	Local lRet 	:= .T.
	
Return lRet

/*/{Protheus.doc} PreValGrid1
Funcao tipo botao para inativar o registro.
@author 	Ricardo Tavares Ferreira
@since 		13/08/2018
@version 	12.1.17
@return 	Nil
@Obs 		Ricardo Tavares - Construcao Inicial
/*/
//==========================================================================================================
	Static Function PreValGrid1(oModel)
//==========================================================================================================

	Local lRet := .T.
	
	If Empty(M->Z5_CCUSTO)
		ShowHelpDlg('RT34A001',{'O Campo Centro de Custo não foi preenchido.'},,{'Preencha o campo centro de custo primeiro para depois prosseguir com a inclusão do cadastro.'},)
		lRet := .F.
	EndIF
	
Return lRet

/*/{Protheus.doc} PreValGrid2
Funcao tipo botao para inativar o registro.
@author 	Ricardo Tavares Ferreira
@since 		13/08/2018
@version 	12.1.17
@return 	Nil
@Obs 		Ricardo Tavares - Construcao Inicial
/*/
//==========================================================================================================
	Static Function PrVlGd2(oModel)
//==========================================================================================================

	Local lRet := .T.
	
	If Empty(M->Z5_CCUSTO) 
		ShowHelpDlg('RT34A001',{'O Campo Centro de Custo não foi preenchido.'},,{'Preencha o campo Centro de Custo no cabeçalho, para depois prosseguir com a inclusão do cadastro.'},)
		lRet := .F.     
	EndIF
	
Return lRet

/*/{Protheus.doc} RT34A001A
Funcao tipo botao para inativar o registro.
@author 	Ricardo Tavares Ferreira
@since 		13/08/2018
@version 	12.1.17
@return 	Nil
@Obs 		Ricardo Tavares - Construcao Inicial
/*/
//==========================================================================================================
	Static Function RT34A001A()
//==========================================================================================================
	
	Local cCodCC 	:= SZ5->Z5_CCUSTO
	Local cCod   	:= SZ5->Z5_COD
	Local cQuery   	:= ""
	Local QbLinha	:= chr(13)+chr(10)
	Local NQTREG	:= 0
	Local NQTREG1	:= 0
		
	If DbSeek(xFilial("SZ5")+cCod+cCodCC)
		
		RecLock("SZ5",.F.)
			If SZ5->Z5_STATUS == "1"
				SZ5->Z5_STATUS := "2"
			Else
				SZ5->Z5_STATUS := "1"
			EndIF
		MsUnlock()
			
		cQuery := "SELECT Z6_COD COD, Z6_CODITEM ITEM , Z6_CCUSTO CCUSTO, Z6_STATUS STATUS, SZ6.R_E_C_N_O_ ID"+QbLinha
		cQuery += "FROM "+RetSqlName("SZ6")+" SZ6 "+QbLinha
		cQuery += "WHERE SZ6.D_E_L_E_T_ = ' '"+QbLinha 
		cQuery += "AND Z6_COD = '"+cCod+"'"+QbLinha
		
		cQuery := CHANGEQUERY(cQuery)
		DBUSEAREA(.T., 'TOPCONN', TCGENQRY(,,cQuery), "QRYSZ6", .F., .T.)

		DBSELECTAREA("QRYSZ6")
		QRYSZ6->(DBGOTOP())
		COUNT TO NQTREG
		QRYSZ6->(DBGOTOP())

		IF NQTREG <= 0 
			QRYSZ6->(DBCLOSEAREA())
		Else
			SZ6->(DbSetOrder(2))
			
			While !QRYSZ6->(EoF())
				SZ6->(DbGoTo(QRYSZ6->ID))
				If QRYSZ6->STATUS == "1"
					RecLock("SZ6",.F.)
						SZ6->Z6_STATUS := "2"
					MsUnlock()
				Else
					RecLock("SZ6",.F.)
						SZ6->Z6_STATUS := "1"
					MsUnlock()
				EndIf
				QRYSZ6->(DbSkip())
			End
			QRYSZ6->(DBCLOSEAREA())
		EndIf
		
		cQuery := "SELECT Z7_COD COD, Z7_CODITEM ITEM , Z7_CCUSTO CCUSTO, Z7_CODCVL CODCVL, Z7_STATUS STATUS, SZ7.R_E_C_N_O_ ID "+QbLinha
		cQuery += "FROM "+RetSqlName("SZ7")+" SZ7 "+QbLinha
		cQuery += "WHERE SZ7.D_E_L_E_T_ = ' '"+QbLinha 
		cQuery += "AND Z7_COD = '"+cCod+"'"+QbLinha
			
		cQuery := CHANGEQUERY(cQuery)
		DBUSEAREA(.T., 'TOPCONN', TCGENQRY(,,cQuery), "QRYSZ7", .F., .T.)

		DBSELECTAREA("QRYSZ7")
		QRYSZ7->(DBGOTOP())
		COUNT TO NQTREG1
		QRYSZ7->(DBGOTOP())

		IF NQTREG1 <= 0 
			QRYSZ7->(DBCLOSEAREA())
		Else
			SZ7->(DbSetOrder(3))
			While !QRYSZ7->(EoF())
				SZ7->(DbGoTo(QRYSZ7->ID))
				If QRYSZ7->STATUS == "1"
					RecLock("SZ7",.F.)
						SZ7->Z7_STATUS := "2"
					MsUnlock()
				Else
					RecLock("SZ7",.F.)
						SZ7->Z7_STATUS := "1"
					MsUnlock()
				EndIf
				QRYSZ7->(DbSkip())
			End
			QRYSZ7->(DBCLOSEAREA())
		EndIf	
	EndIf
Return	          