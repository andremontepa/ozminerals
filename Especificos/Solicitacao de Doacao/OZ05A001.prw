#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "PRTOPDEF.CH"
#INCLUDE "font.ch"

#DEFINE MODEL_OPERATION_VIEW    2
#DEFINE MODEL_OPERATION_INSERT  3
#DEFINE MODEL_OPERATION_UPDATE  4
#DEFINE MODEL_OPERATION_DELETE  5
#DEFINE MODEL_OPERATION_COPY    9
#DEFINE MODEL_OPERATION_IMPR    8

#DEFINE cTitulo OemtoAnsi("Solicitação de Doação")
#DEFINE cTitItem OemtoAnsi("Itens da Solicitação de Doação")

/*/{Protheus.doc} OZ05A001
Rotina de Cadastro e aprovação das solicitações de Doações
@type function           
@author Ricardo Tavares Ferreira
@since 29/01/2022
@version 12.1.27
@history 29/01/2022, Ricardo Tavares Ferreira, Construção Inicial
@return object, Retorna o objeto do Browse.
/*/
//=============================================================================================================================
    User Function OZ05A001()
//=============================================================================================================================

	Local oBrowse := Nil
	
	DbSelectArea("SZE")
	DbSelectArea("SZF")

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("SZE")
	oBrowse:AddLegend("ZE_STATUS == '1' " , "BR_BRANCO"     , "Aberta" )
	oBrowse:AddLegend("ZE_STATUS == '2' " , "BR_VERMELHO"   , "Reprovado" )
	oBrowse:AddLegend("ZE_STATUS == '3' " , "BR_AZUL"       , "Em Aprovação" )
    oBrowse:AddLegend("ZE_STATUS == '4' " , "BR_VERDE"      , "Aprovada" )
    oBrowse:AddLegend("ZE_STATUS == '5' " , "BR_PRETO"      , "Finalizada" )
	oBrowse:SetDescription(cTitulo)
	oBrowse:SetMenuDef("OZ05A001")

	oBrowse:Activate()
Return oBrowse

/*/{Protheus.doc} ModelDef
Funcao que cria o modelo de dados da rotina.
@type function
@author Ricardo Tavares Ferreira
@since 29/01/2022
@version 12.1.17
@history 29/01/2022, Ricardo Tavares Ferreira, Construção Inicial
@return object, Retorna o Objeto do Modelo.
/*/
//==========================================================================================================
	Static Function ModelDef()
//==========================================================================================================

	Local oModel		:= Nil
	Local oStrSZE		:= Nil
	Local oStrSZF		:= Nil
	Local aCampos		:= {}
    Local nX            := 0
	Local cCamposSZE	:= ""	
	Local cCamposSZF	:= ""	

	aCampos := SZE->(DbStruct())
	
	For nX := 2 To Len(aCampos)
		cCamposSZE += aCampos[nX][1]
		cCamposSZE += Iif((nX) < Len(aCampos),";","")
	Next
	
	aCampos	:= Nil
	aCampos := SZF->(DbStruct())
	
	For nX := 2 To Len(aCampos)
		cCamposSZF += aCampos[nX][1]
		cCamposSZF += Iif((nX) < Len(aCampos),";","")
	Next 
	
	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New("OZ05A1M",/*{|oModel| PreValida(oModel)}*/,{|oModel| PosValida(oModel)},/*{|oModel| GravaDados( oModel )}*/) 
	
	// Cria o Objeto da Estrutura dos Campos da tabela
	oStrSZE := FWFormStruct(1,"SZE",{|cCampo| ( Alltrim(cCampo) $ cCamposSZE )})
	oStrSZF := FWFormStruct(1,"SZF",{|cCampo| ( Alltrim(cCampo) $ cCamposSZF )})

	oStrSZE:AddTrigger("ZE_LOJA","ZE_NOME",{ || .T. },{|| oModel := FwModelActive(),Posicione("SA1",1,FWXFilial("SA1")+oModel:GetModel("M_SZE"):GetValue("ZE_CLIENTE")+oModel:GetModel("M_SZE"):GetValue("ZE_LOJA"),"A1_NOME")})
	oStrSZE:AddTrigger("ZE_CCUSTO","ZE_GRPAPRO",{ || .T. },{|| oModel := FwModelActive(),GetGrpAprov(oModel:GetModel("M_SZE"):GetValue("ZE_CCUSTO"),oModel:GetModel("M_SZE"):GetValue("ZE_ITEMC"),oModel:GetModel("M_SZE"):GetValue("ZE_CLVL"))})
	oStrSZE:AddTrigger("ZE_ITEMC","ZE_GRPAPRO",{ || .T. },{|| oModel  := FwModelActive(),GetGrpAprov(oModel:GetModel("M_SZE"):GetValue("ZE_CCUSTO"),oModel:GetModel("M_SZE"):GetValue("ZE_ITEMC"),oModel:GetModel("M_SZE"):GetValue("ZE_CLVL"))})
	oStrSZE:AddTrigger("ZE_CLVL","ZE_GRPAPRO",{ || .T. },{|| oModel   := FwModelActive(),GetGrpAprov(oModel:GetModel("M_SZE"):GetValue("ZE_CCUSTO"),oModel:GetModel("M_SZE"):GetValue("ZE_ITEMC"),oModel:GetModel("M_SZE"):GetValue("ZE_CLVL"))})
	
	oStrSZF:AddTrigger("ZF_PRODUTO","ZF_UM",{ || .T. },{|| oModel := FwModelActive(),Posicione("SB1",1,FWXFilial("SB1")+oModel:GetModel("M_SZF"):GetValue("ZF_PRODUTO"),"B1_UM")})
	oStrSZF:AddTrigger("ZF_PRODUTO","ZF_DESC",{ || .T. },{|| oModel := FwModelActive(),Posicione("SB1",1,FWXFilial("SB1")+oModel:GetModel("M_SZF"):GetValue("ZF_PRODUTO"),"B1_DESC")})
	oStrSZF:AddTrigger("ZF_QUANT","ZF_VLTOTAL",{ || .T. },{|| oModel := FwModelActive(),oModel:GetModel("M_SZF"):GetValue("ZF_QUANT") * oModel:GetModel("M_SZF"):GetValue("ZF_VLUNIT")})
	oStrSZF:AddTrigger("ZF_VLUNIT","ZF_VLTOTAL",{ || .T. },{|| oModel := FwModelActive(),oModel:GetModel("M_SZF"):GetValue("ZF_QUANT") * oModel:GetModel("M_SZF"):GetValue("ZF_VLUNIT")})

	// Adiciona ao modelo um componente de formulario
	oModel:AddFields("M_SZE",/*cOwner*/,oStrSZE) 
	
	oModel:AddGrid("M_SZF","M_SZE",oStrSZF)
	oModel:SetRelation("M_SZF",;
	{{"ZF_FILIAL","FWXFilial('SZF')"},;
	 {"ZF_CODIGO","ZE_CODIGO"},;
     {"ZF_CLIENTE","ZE_CLIENTE"},;
	 {"ZF_LOJA","ZE_LOJA"}},;
	SZF->(IndexKey(1)))// Faz relacionamento entre os componentes do model
	 
	// Seta a chave primaria que sera utilizada na gravacao dos dados na tabela 
	oModel:SetPrimaryKey({"ZE_FILIAL","ZE_CODIGO","ZE_CLIENTE","ZE_LOJA"})
	
	// Seto o Conteudo no campo para colocar o registro inicialmente como Ativo
	oStrSZE:SetProperty("ZE_STATUS" , MODEL_FIELD_INIT , {|| AllTrim("1")})
	 //oStrSZF:SetProperty("SZF_DOCSZE" , MODEL_FIELD_INIT , {|| oModel:GetModel("M_SZE"):GetValue("SZE_DOC")})
	 //oStrSZF:SetProperty("SZF_LTSZE"  , MODEL_FIELD_INIT , {|| oModel:GetModel("M_SZE"):GetValue("SZE_LOTE")})
	 //oStrSZF:SetProperty("SZF_SBLSZE" , MODEL_FIELD_INIT , {|| oModel:GetModel("M_SZE"):GetValue("SZE_SBLOTE")})
     //oStrSZF:SetProperty("SZF_MOEDLC" , MODEL_FIELD_INIT , {|| Alltrim(MV_PAR03)})
 
	 //oStrSZF:SetProperty("SZF_DOCSZE" , MODEL_FIELD_WHEN , {|| .F.})
     //oStrSZF:SetProperty("SZF_LTSZE"  , MODEL_FIELD_WHEN , {|| .F.})
     //oStrSZF:SetProperty("SZF_SBLSZE" , MODEL_FIELD_WHEN , {|| .F.})
	
	// Coloco uma regra para nao duplicar os itens contabeis na inclusao
	oModel:getModel("M_SZF"):SetUniqueLine({"ZF_ITEM"})

	// Seta a descricao do modelo de dados no cabecalho
	oModel:getModel("M_SZE"):SetDescription(OemToAnsi(cTitulo))
	oModel:getModel("M_SZF"):SetDescription(OemtoAnsi(cTitItem))

	// Adiciona Campos de Calculo no fonte
	oModel:AddCalc("M_CALC","M_SZE","M_SZF","ZF_ITEM","ZF_ITEM","COUNT", { |oFw| AllwaysTrue() },,"Qtd. Itens")
	oModel:AddCalc("M_CALC","M_SZE","M_SZF","ZF_VLTOTAL","ZF_VLTOTAL","SUM", { |oFw| AllwaysTrue() },,"Total Geral")

	// Valida a Alteração dos Registros
    oModel:SetVldActivate({|oModel| ValAlt(oModel,oModel:GetOperation())})

Return oModel

/*/{Protheus.doc} ViewDef
Funcao que cria a tela de visualizacao do modelo de dados da rotina.
@type function
@author Ricardo Tavares Ferreira
@since 29/01/2022
@version 12.1.17
@history 29/01/2022, Ricardo Tavares Ferreira, Construção Inicial.
@return object, Retorna o Objeto da View.
/*/
//==========================================================================================================
	Static Function ViewDef()
//==========================================================================================================

	Local oView			:= Nil
	Local oModel		:= FWLoadModel("OZ05A001") // Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
	Local oStrSZE		:= Nil		
	Local oStrSZF		:= Nil	
	Local cCamposSZE	:= ""	
	Local cCamposSZF	:= ""	
	Local aCampos		:= Nil
	Local nX			:= 0
	Local oCalc			:= FWCalcStruct(oModel:GetModel("M_CALC"))

	aCampos := SZE->(DbStruct())
	
	For nX := 2 To Len(aCampos)
		cCamposSZE += aCampos[nX][1]
		cCamposSZE += Iif((nX) < Len(aCampos),";","")
	Next
	
	aCampos	:= Nil
	aCampos := SZF->(DbStruct())
	
	For nX := 2 To Len(aCampos)
		cCamposSZF += aCampos[nX][1]
		cCamposSZF += Iif((nX) < Len(aCampos),";","")
	Next 
	
	//Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
	oStrSZE := FWFormStruct(2,"SZE",{|cCampo| ( Alltrim(cCampo) $ cCamposSZE )})
	oStrSZF := FWFormStruct(2,"SZF",{|cCampo| ( Alltrim(cCampo) $ cCamposSZF )})
	
	// Cria o objeto de View
	oView := FWFormView():New()
	
	// Define qual o Modelo de dados sera utilizado na View
	oView:SetModel(oModel)	
	
	// Adiciona no nosso View um controle do tipo formulario
	oView:AddField("V_SZE",oStrSZE,"M_SZE",/*{|oModel| PreValida(oModel)}*/,/*{|oView| PosValida(oView)}*/)
	
	//Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
	oView:AddGrid("V_SZF",oStrSZF,"M_SZF",/*{|oModel| PreValida(oModel)}*/,/*{|oView| PosValida(oView)}*/)

	oView:AddField("V_CALC",oCalc,"M_CALC")
	
	// Cria um "box" horizontal para receber cada elemento da view Pai
	oView:CreateHorizontalBox("V_SUP",35)
	oView:CreateHorizontalBox("V_INF",55)
	oView:CreateHorizontalBox("V_ROD",10)
	
	// Relaciona o identificador (ID) da View com o "box" para exibicao Pai
	oView:SetOwnerView("V_SZE","V_SUP")
	oView:SetOwnerView("V_SZF","V_INF")
	oView:SetOwnerView("V_CALC","V_ROD")
	
	// Seta o Titulo no cabecalho do cadastro
	oView:EnableTitleView("V_SZE",OemtoAnsi(cTitulo))
	oView:EnableTitleView("V_SZF",OemtoAnsi(cTitItem))
	oView:EnableTitleView("V_CALC","Totais da Solicitação de Doação")
	
	// Aplico o autoincremento no campo de itens da grid
	oView:AddIncrementField("V_SZF","ZF_ITEM") 

	oStrSZF:RemoveField("ZF_CODIGO")   
	oStrSZF:RemoveField("ZF_CLIENTE") 
	oStrSZF:RemoveField("ZF_LOJA") 

Return oView

/*/{Protheus.doc} MenuDef
Funcao que cria o menu principal do Browse da rotina.
@type function
@author Ricardo Tavares Ferreira
@since 29/01/2022
@version 12.1.17
@history 29/01/2022, Ricardo Tavares Ferreira, Construção Inicial.
@return array, Retorna o Array com os menus da rotina.
/*/
//==========================================================================================================
	Static Function MenuDef()
//==========================================================================================================
	
	Local aRotina	:= {}
	Local cCodGru	:= PswRet()[1][1]

	ADD OPTION aRotina Title "Incluir" 			ACTION "VIEWDEF.OZ05A001" OPERATION MODEL_OPERATION_INSERT		ACCESS 0
	ADD OPTION aRotina Title "Visualizar"		ACTION "VIEWDEF.OZ05A001" OPERATION MODEL_OPERATION_VIEW		ACCESS 0
	ADD OPTION aRotina Title "Alterar" 			ACTION "VIEWDEF.OZ05A001" OPERATION MODEL_OPERATION_UPDATE		ACCESS 0
	
	If cCodGru == "000000" 
		ADD OPTION aRotina Title "Excluir" 		ACTION "VIEWDEF.OZ05A001" OPERATION MODEL_OPERATION_DELETE 		ACCESS 0
	EndIf
	
	ADD OPTION aRotina Title "Imprimir" 		ACTION "VIEWDEF.OZ05A001" OPERATION MODEL_OPERATION_IMPR		ACCESS 0
	ADD OPTION aRotina Title "Copiar" 			ACTION "VIEWDEF.OZ05A001" OPERATION MODEL_OPERATION_COPY	 	ACCESS 0

	ADD OPTION aRotina Title "Conhecimento"	    ACTION "StaticCall(OZ05A001,Conhecimento)" OPERATION 9			ACCESS 0
    ADD OPTION aRotina Title "Status Aprovação"	ACTION "U_OZ05M001()" OPERATION 9			 	ACCESS 0
	//ADD OPTION aRotina Title "Reprovar"	        ACTION "StaticCall(OZ05A001,Reprovar)" OPERATION 9			 	ACCESS 0

Return aRotina

/*/{Protheus.doc} PosValida
Funcao que realiza a pre validacao dos dados na confirmação dos dados.
@type function
@author Ricardo Tavares Ferreira
@since 31/01/2022
@version 12.1.17
@param oModel, object, Objeto do Modelo de Dados.
@history 31/01/2022, Ricardo Tavares Ferreira, Construção Inicial.
@return logical, Retona Verdadeiro se pode prosseguir com a gravação dos dados.
/*/
//==========================================================================================================
	Static Function PosValida(oModel)
//==========================================================================================================

	Local nOpc     	:= oModel:GetOperation()
	Local oStrSZE  	:= oModel:GetModel("M_SZE")
	Local oStrCal	:= oModel:GetModel("M_CALC")
	Local lRet 		:= .T.

	If oStrSZE:GetValue("ZE_STATUS") <> "5"
		If nOpc == MODEL_OPERATION_INSERT
			MaAlcDoc({oStrSZE:GetValue("ZE_CODIGO"),"SD",oStrCal:GetValue("ZF_VLTOTAL"),,,oStrSZE:GetValue("ZE_GRPAPRO"),,1,1,oStrSZE:GetValue("ZE_EMISSAO")},,1)  
			oStrSZE:SetValue("ZE_STATUS","3")
		ElseIf nOpc == MODEL_OPERATION_UPDATE .or. nOpc == MODEL_OPERATION_DELETE
			If nOpc == MODEL_OPERATION_DELETE
				DeletaSCR(cFilant,oStrSZE:GetValue("ZE_CODIGO"),"SD")
			Else
				DeletaSCR(cFilant,oStrSZE:GetValue("ZE_CODIGO"),"SD")
				MaAlcDoc({oStrSZE:GetValue("ZE_CODIGO"),"SD",oStrCal:GetValue("ZF_VLTOTAL"),,,oStrSZE:GetValue("ZE_GRPAPRO"),,1,1,oStrSZE:GetValue("ZE_EMISSAO")},,1) 
				oStrSZE:SetValue("ZE_STATUS","3")
			EndIf
		EndIf 
	Else 
		Help(Nil,Nil,"OZ05A001",Nil,"O Status atual da Solicitação de Doação não Permite nenhum tipo de operação.",1,0,Nil,Nil,Nil,Nil,Nil,{"Inclua, altere ou exclua outro tipo Solicitação de Doação com status diferente."})
		lRet := .F.
	EndIf 

	If Empty(oStrSZE:GetValue("ZE_GRPAPRO"))
		Help(Nil,Nil,"OZ05A001",Nil,"Não é permitido incluir Solicitação de Doação sem grupo de aprovação.",1,0,Nil,Nil,Nil,Nil,Nil,{"Por favor verifique o Centro de Custo / Item Contábil / Classe de Valor informados ou procure a Controladoria.."})
		lRet := .F.
	EndIf 
Return lRet

/*/{Protheus.doc} Conhecimento
Função em Botão que adiciona a rotina de Conhecimento (Anexo de Documentos).
@type function
@author Ricardo Tavares Ferreira
@since 31/01/2022
@version 12.1.27
@history 31/01/2022, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//==========================================================================================================
	Static Function Conhecimento()
//==========================================================================================================

	MsDocument("SZE",SZE->(Recno()),4)
Return Nil 

/*/{Protheus.doc} ValAlt
Função que valida se o usuario pode alterar o registro.
@type function
@author Ricardo Tavares Ferreira
@since 31/01/2022
@version 12.1.27
@history 31/01/2022, Ricardo Tavares Ferreira, Construção Inicial.
@param oModel, object, Objeto do Modelo de Dados.
@param nOperation, numeric, Numero da Operação Executada no momento atual.
@return logical, Retorna verdadeiro se puder executar a alteração.
/*/
//==========================================================================================================
	Static Function ValAlt(oModel,nOperation)
//==========================================================================================================
	
	Local nOpc := oModel:GetOperation()

	If nOpc == MODEL_OPERATION_UPDATE
        If SZE->ZE_STATUS == "5"
			Help(Nil,Nil,"OZ05A001",Nil,"O Status atual da Solicitação de Doação não Permite nenhum tipo de operação.",1,0,Nil,Nil,Nil,Nil,Nil,{"Inclua, altere ou exclua outro tipo Solicitação de Doação com status diferente."})
			Return .F.
		EndIf
	EndIf
Return .T.

/*/{Protheus.doc} DeletaSCR
Funcao que Deleta a SCR do Sistema.
@type function
@author Ricardo Tavares Ferreira
@since 31/01/2022
@version 12.1.17
@history 31/01/2022, Ricardo Tavares Ferreira, Construção Inicial.
@param xFil, character, Codigo da Filial.
@param xCod, character, Codigo da Solicitação de doação.
@param xTipo, character, Tipo da Aprovação.
/*/
//==========================================================================================================
	Static Function DeletaSCR(xFil,xCod,xTipo)
//==========================================================================================================

	Local cQuery  	:= ""
	Local QbLinha 	:= chr(13)+chr(10)
    Local nQtdReg 	:= 0
	Local cAliasSCR	:= GetNextAlias()

	cQuery := " SELECT SCR.R_E_C_N_O_ IDSCR "+QbLinha
    cQuery += " FROM "
    cQuery +=   RetSqlName("SCR") + " SCR "+QbLinha
	cQuery += " WHERE SCR.D_E_L_E_T_ = ' ' "+QbLinha
	cQuery += " AND CR_FILIAL = '"+AllTrim(xFil)+"' "+QbLinha 
	cQuery += " AND CR_NUM = '"+AllTrim(xCod)+"' "+QbLinha 
	cQuery += " AND CR_TIPO = '"+AllTrim(xTipo)+"' "+QbLinha 

	MemoWrite("C:/ricardo/OZ05A001_DeletaSCR.sql",cQuery)			     
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSCR,.F.,.T.)
		
	DbSelectArea(cAliasSCR)
	(cAliasSCR)->(DbGoTop())
	Count To nQtdReg
	(cAliasSCR)->(DbGoTop())
		
	If nQtdReg <= 0
		(cAliasSCR)->(DbCloseArea())
        Return Nil
	Else 
		DbSelectArea("SCR")
		While .not. (cAliasSCR)->(Eof())
			SCR->(DbGoTo((cAliasSCR)->IDSCR))
			RecLock("SCR",.F.)
				SCR->(DbDelete())
			SCR->(MsUnlock())
			(cAliasSCR)->(DbSkip())
		End 
		(cAliasSCR)->(DbCloseArea())
    EndIf
Return Nil 

/*/{Protheus.doc} GetGrpAprov
Funcao que busca o grupo de aprovação cadastrado no protheus.
@type function
@author Ricardo Tavares Ferreira
@since 31/01/2022
@version 12.1.17
@history 31/01/2022, Ricardo Tavares Ferreira, Construção Inicial.
@param cCusto, character, Codigo do Centro de Custo.
@param cItem, character, Codigo do Item Contabil.
@param cClasse, character, Codigo do Classe Valor.
@return character, Retorna o codigo do grupo de aprovação.
/*/
//==========================================================================================================
	Static Function GetGrpAprov(cCusto,cItem,cClasse)
//==========================================================================================================

	Local cGrupo 	:= ""
	Local cQuery  	:= ""
	Local QbLinha 	:= chr(13)+chr(10)
    Local nQtdReg 	:= 0
	Local cAliasDBL	:= GetNextAlias()

	Default cCusto  := ""
	Default cItem   := ""
	Default cClasse := ""

	cQuery := " SELECT "+QbLinha 
	cQuery += " DBL_GRUPO "+QbLinha
    cQuery += " FROM "
    cQuery +=   RetSqlName("DBL") + " DBL "+QbLinha
	cQuery += " WHERE "+QbLinha 
	cQuery += " DBL.D_E_L_E_T_ = ' ' "+QbLinha

	If .not. Empty(cCusto)
		cQuery += " AND DBL_CC = '"+cCusto+"' "+QbLinha
	EndIf 

	If .not. Empty(cItem)
		cQuery += " AND DBL_ITEMCT = '"+cItem+"' "+QbLinha
	EndIf 

	If .not. Empty(cClasse)
		cQuery += " AND DBL_CLVL = '"+cClasse+"' "+QbLinha
	EndIf 

    MemoWrite("C:/ricardo/OZ05A001_GetGrpAprov.sql",cQuery)			     
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasDBL,.F.,.T.)
		
	DbSelectArea(cAliasDBL)
	(cAliasDBL)->(DbGoTop())
	Count To nQtdReg
	(cAliasDBL)->(DbGoTop())
		
	If nQtdReg <= 0
		(cAliasDBL)->(DbCloseArea())
        Return cGrupo
	Else 
		cGrupo := AllTrim((cAliasDBL)->DBL_GRUPO)
		(cAliasDBL)->(DbCloseArea())
    EndIf
Return cGrupo
