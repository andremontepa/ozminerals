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

#DEFINE cTitulo OemtoAnsi("Cabeçalho do Lançamento Contábil")
#DEFINE cTitItem OemtoAnsi("Itens do Lançamento Contábil")

/*/{Protheus.doc} OZ34A001
Rotina de Importação e Conferencia de Lançamentos Contabeis.
@type function
@author Ricardo Tavares Ferreira
@since 20/11/2021
@version 12.1.27
@history 20/11/2021, Ricardo Tavares Ferreira, Construção Inicial
@return object, Retorna o Objeto do Browse.
/*/
//=============================================================================================================================
    User Function OZ34A001()
//=============================================================================================================================

	Local oBrowse 		:= Nil
	Private cTitulo		:= OemtoAnsi("Importação de Lançamentos Contábeis")
    Private cPerg       := "OZ34A001"
    Private cAliasZR7   := GetNextAlias()
	Private cAliasCT2   := GetNextAlias()
    Private lMsErroAuto := .F.
    Private lMsHelpAuto	:= .T. 
	
	DbSelectArea("ZR7")
	DbSelectArea("ZR8")

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZR7")
	oBrowse:AddLegend("ZR7_STATUS == 'A' "	, "GREEN" , "Aberto" )
	oBrowse:AddLegend("ZR7_STATUS == 'R' "	, "RED"   , "Reprovado" )
	oBrowse:AddLegend("ZR7_STATUS == 'F' "	, "BLACK" , "Finalizado" )
	oBrowse:SetDescription(cTitulo)
	oBrowse:SetMenuDef("OZ34A001")

	oBrowse:Activate()
Return oBrowse

/*/{Protheus.doc} ModelDef
Funcao que cria o modelo de dados da rotina.
@type function
@author Ricardo Tavares Ferreira
@since 20/11/2021
@version 12.1.17
@history 20/11/2021, Ricardo Tavares Ferreira, Construção Inicial
@return object, Retorna o Objeto do Modelo.
/*/
//==========================================================================================================
	Static Function ModelDef()
//==========================================================================================================

	Local oModel		:= Nil
	Local oStrZR7		:= Nil
	Local oStrZR8		:= Nil
	Local aCampos		:= {}
    Local nX            := 0
	Local cCamposZR7	:= ""	
	Local cCamposZR8	:= ""	
	Private cPerg       := "OZ34A001"

	aCampos := ZR7->(DbStruct())
	
	For nX := 2 To Len(aCampos)
		cCamposZR7 += aCampos[nX][1]
		cCamposZR7 += Iif((nX) < Len(aCampos),";","")
	Next
	
	aCampos	:= Nil
	aCampos := ZR8->(DbStruct())
	
	For nX := 2 To Len(aCampos)
		cCamposZR8 += aCampos[nX][1]
		cCamposZR8 += Iif((nX) < Len(aCampos),";","")
	Next 
	
	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New("OZ34A1M",/*{|oModel| PreValida(oModel)}*/,/*{|oModel| PosValida(oModel)}*/,/*{|oModel| GravaDados( oModel )}*/) 
	
	// Cria o Objeto da Estrutura dos Campos da tabela
	oStrZR7 := FWFormStruct(1,"ZR7",{|cCampo| ( Alltrim(cCampo) $ cCamposZR7 )})
	oStrZR8 := FWFormStruct(1,"ZR8",{|cCampo| ( Alltrim(cCampo) $ cCamposZR8 )})

	// Adiciona ao modelo um componente de formulario
	oModel:AddFields("M_ZR7",/*cOwner*/,oStrZR7) 
	
	oModel:AddGrid("M_ZR8","M_ZR7",oStrZR8)
	oModel:SetRelation("M_ZR8",;
	{{"ZR8_FILIAL","FWXFilial('ZR8')"},;
	 {"ZR8_DOCZR7","ZR7_DOC"},;
     {"ZR8_LTZR7","ZR7_LOTE"},;
	 {"ZR8_SBLZR7","ZR7_SBLOTE"}},;
	ZR8->(IndexKey(1)))// Faz relacionamento entre os componentes do model
	 
	// Seta a chave primaria que sera utilizada na gravacao dos dados na tabela 
	oModel:SetPrimaryKey({"ZR7_FILIAL","ZR7_DOC","ZR7_LOTE","ZR7_SBLOTE"})
	
	// Seto o Conteudo no campo para colocar o registro inicialmente como Ativo
	oStrZR7:SetProperty("ZR7_STATUS" , MODEL_FIELD_INIT , {|| AllTrim("A")})
	oStrZR8:SetProperty("ZR8_DOCZR7" , MODEL_FIELD_INIT , {|| oModel:GetModel("M_ZR7"):GetValue("ZR7_DOC")})
	oStrZR8:SetProperty("ZR8_LTZR7"  , MODEL_FIELD_INIT , {|| oModel:GetModel("M_ZR7"):GetValue("ZR7_LOTE")})
	oStrZR8:SetProperty("ZR8_SBLZR7" , MODEL_FIELD_INIT , {|| oModel:GetModel("M_ZR7"):GetValue("ZR7_SBLOTE")})
    oStrZR8:SetProperty("ZR8_MOEDLC" , MODEL_FIELD_INIT , {|| Alltrim(MV_PAR03)})

	oStrZR8:SetProperty("ZR8_DOCZR7" , MODEL_FIELD_WHEN , {|| .F.})
    oStrZR8:SetProperty("ZR8_LTZR7"  , MODEL_FIELD_WHEN , {|| .F.})
    oStrZR8:SetProperty("ZR8_SBLZR7" , MODEL_FIELD_WHEN , {|| .F.})
	
	// Coloco uma regra para nao duplicar os itens contabeis na inclusao
	oModel:getModel("M_ZR8"):SetUniqueLine({"ZR8_ITEM"})

	// Seta a descricao do modelo de dados no cabecalho
	oModel:getModel("M_ZR7"):SetDescription(OemToAnsi(cTitulo))
	oModel:getModel("M_ZR8"):SetDescription(OemtoAnsi(cTitItem))

Return oModel

/*/{Protheus.doc} ViewDef
Funcao que cria a tela de visualizacao do modelo de dados da rotina.
@type function
@author Ricardo Tavares Ferreira
@since 20/11/2021
@version 12.1.17
@history 20/11/2021, Ricardo Tavares Ferreira, Construção Inicial.
@return object, Retorna o Objeto da View.
/*/
//==========================================================================================================
	Static Function ViewDef()
//==========================================================================================================

	Local oView			:= Nil
	Local oModel		:= FWLoadModel("OZ34A001") // Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
	Local oStrZR7		:= Nil		
	Local oStrZR8		:= Nil	
	Local cCamposZR7	:= ""	
	Local cCamposZR8	:= ""	
	Local aCampos		:= Nil
	Local nX			:= 0

	aCampos := ZR7->(DbStruct())
	
	For nX := 2 To Len(aCampos)
		cCamposZR7 += aCampos[nX][1]
		cCamposZR7 += Iif((nX) < Len(aCampos),";","")
	Next
	
	aCampos	:= Nil
	aCampos := ZR8->(DbStruct())
	
	For nX := 2 To Len(aCampos)
		cCamposZR8 += aCampos[nX][1]
		cCamposZR8 += Iif((nX) < Len(aCampos),";","")
	Next 
	
	//Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
	oStrZR7 := FWFormStruct(2,"ZR7",{|cCampo| ( Alltrim(cCampo) $ cCamposZR7 )})
	oStrZR8 := FWFormStruct(2,"ZR8",{|cCampo| ( Alltrim(cCampo) $ cCamposZR8 )})
	
	// Cria o objeto de View
	oView := FWFormView():New()
	
	// Define qual o Modelo de dados sera utilizado na View
	oView:SetModel(oModel)	
	
	// Adiciona no nosso View um controle do tipo formulario
	oView:AddField("V_ZR7",oStrZR7,"M_ZR7",/*{|oModel| PreValida(oModel)}*/,/*{|oView| PosValida(oView)}*/)
	
	//Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
	oView:AddGrid("V_ZR8",oStrZR8,"M_ZR8",/*{|oModel| PreValida(oModel)}*/,/*{|oView| PosValida(oView)}*/)
	
	// Cria um "box" horizontal para receber cada elemento da view Pai
	oView:CreateHorizontalBox("V_SUP",15)
	oView:CreateHorizontalBox("V_INF",85)
	
	// Relaciona o identificador (ID) da View com o "box" para exibicao Pai
	oView:SetOwnerView("V_ZR7","V_SUP")
	oView:SetOwnerView("V_ZR8","V_INF")
	
	// Seta o Titulo no cabecalho do cadastro
	oView:EnableTitleView("V_ZR7",OemtoAnsi(cTitulo))
	oView:EnableTitleView("V_ZR8",OemtoAnsi(cTitItem))
	
	// Aplico o autoincremento no campo de itens da grid
	oView:AddIncrementField("V_ZR8","ZR8_ITEM")    

Return oView

/*/{Protheus.doc} MenuDef
Funcao que cria o menu principal do Browse da rotina.
@type function
@author Ricardo Tavares Ferreira
@since 20/11/2021
@version 12.1.17
@history 20/11/2021, Ricardo Tavares Ferreira, Construção Inicial.
@return array, Retorna o Array com os menus da rotina.
/*/
//==========================================================================================================
	Static Function MenuDef()
//==========================================================================================================
	
	Local aRotina	:= {}
	Local cCodGru	:= PswRet()[1][1]

    If cCodGru == "000000" 
	    ADD OPTION aRotina Title "Incluir" 		ACTION "VIEWDEF.OZ34A001" OPERATION MODEL_OPERATION_INSERT		ACCESS 0
    EndIf

	ADD OPTION aRotina Title "Visualizar"		ACTION "VIEWDEF.OZ34A001" OPERATION MODEL_OPERATION_VIEW		ACCESS 0
	ADD OPTION aRotina Title "Alterar" 			ACTION "VIEWDEF.OZ34A001" OPERATION MODEL_OPERATION_UPDATE		ACCESS 0
	
	If cCodGru == "000000" 
		ADD OPTION aRotina Title "Excluir" 		ACTION "VIEWDEF.OZ34A001" OPERATION MODEL_OPERATION_DELETE 		ACCESS 0
	EndIf
	
	ADD OPTION aRotina Title "Imprimir" 		ACTION "VIEWDEF.OZ34A001" OPERATION MODEL_OPERATION_IMPR		ACCESS 0
	ADD OPTION aRotina Title "Copiar" 			ACTION "VIEWDEF.OZ34A001" OPERATION MODEL_OPERATION_COPY	 	ACCESS 0

	ADD OPTION aRotina Title "Contabilizar"	    ACTION "StaticCall(OZ34A001,Contabilizar)" OPERATION 9			ACCESS 0
    ADD OPTION aRotina Title "Estornar"	        ACTION "StaticCall(OZ34A001,Estornar)" OPERATION 9			 	ACCESS 0
	ADD OPTION aRotina Title "Reprovar"	        ACTION "StaticCall(OZ34A001,Reprovar)" OPERATION 9			 	ACCESS 0

Return aRotina

/*/{Protheus.doc} Reprovar
Função que Marca o lote como reprovado o lote na tabela CT2.
@type function
@author Ricardo Tavares Ferreira
@since 20/11/2021
@version 12.1.27
@history 20/11/2021, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//==========================================================================================================
	Static Function Reprovar()
//==========================================================================================================

    Reclock("ZR7",.F.)
		ZR7->ZR7_STATUS := "R"
	ZR7->(MsUnlock())
Return

/*/{Protheus.doc} Estornar
Função que Exclui o lote na tabela CT2.
@type function
@author Ricardo Tavares Ferreira
@since 20/11/2021
@version 12.1.27
@history 20/11/2021, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//==========================================================================================================
	Static Function Estornar()
//==========================================================================================================

	Local lDados := .F. 

    If Alltrim(ZR7->ZR7_STATUS) <> "F"
        MsgInfo("O Status Atual do Lote Selecionado não permite que ele seja Estornado.", "Atenção")
        Return
    EndIf 

    FWMsgRun(,{|oSay| lDados := BuscaCT2()},"Estorno","Estornando Lote - "+Alltrim(ZR7->ZR7_LOTE)) 

    If lDados 
        While .not. (cAliasCT2)->(Eof())
			CT2->(DbGoto((cAliasCT2)->R_E_C_N_O_))
			RecLock("CT2", .F.)
				CT2->(DbDelete())
			CT2->(MsUnlock())
            (cAliasCT2)->(DbSkip()) 
        End
        (cAliasCT2)->(DbCloseArea())
		RecLock("ZR7",.f.)
			ZR7->ZR7_STATUS = "A"
		ZR7->(MsUnlock())
		FWMsgRun(,{|| CTBA190(.T.,ZR7->ZR7_EMISSA,Date(),cFilAnt,cFilAnt,'1',.F.) },"Processando","Recalculando Saldo .. " )
		MsgInfo("Lote Estornado com Sucesso.","Atenção")
	Else 
		MsgAlert("Dados não Encontrados.","Atenção")
	EndIf 
Return

/*/{Protheus.doc} Contabilizar
Função que inclui o lote na tabela CT2.
@type function
@author Ricardo Tavares Ferreira
@since 20/11/2021
@version 12.1.27
@history 20/11/2021, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//==========================================================================================================
	Static Function Contabilizar()
//==========================================================================================================

    Local lDados    := .F. 
    Local aCabec    := {}
    Local aItens    := {}
    Local nLin      := 1
	Local cChave	:= ""

    If Alltrim(ZR7->ZR7_STATUS) == "F"
        MsgInfo("O Status Atual do Lote Selecionado não permite que ele seja contabilizado.", "Atenção")
        Return
    EndIf 

    FWMsgRun(,{|oSay| lDados := BuscaLote()},"Contabilização","Contabilizando Lote - "+Alltrim(ZR7->ZR7_LOTE)) 

    If lDados 
        While .not. (cAliasZR7)->(Eof())
			ZR7->(DbGoto((cAliasZR7)->R_E_C_N_O_))
			cChave := Alltrim((cAliasZR7)->ZR8_HIST)+"-"+SubStr(Dtos(Stod((cAliasZR7)->ZR7_EMISSA)),5,2)+"/"+SubStr(Dtos(Stod((cAliasZR7)->ZR7_EMISSA)),1,4)+" - "+Alltrim((cAliasZR7)->ZR7_DOC)+Alltrim((cAliasZR7)->ZR7_LOTE)+Alltrim((cAliasZR7)->ZR7_SBLOTE)
            If nLin == 1 
                aCabec := {{ "DDATALANC"   , Stod((cAliasZR7)->ZR7_EMISSA)    				, Nil },;
                           { "CLOTE"       , Alltrim((cAliasZR7)->ZR7_LOTE)   				, Nil },;
                           { "CSUBLOTE"    , Alltrim((cAliasZR7)->ZR7_SBLOTE) 				, Nil },;
                           { "CDOC"        , Alltrim((cAliasZR7)->ZR7_DOC)    				, Nil },;
                           { "CPADRAO"     , ""                               				, Nil },;
                           { "NTOTINF"     , 0                                				, Nil },;
                           { "NTOTINFLOT"  , 0                                				, Nil } }
            EndIf 

                aadd(aItens,{{ "CT2_FILIAL" , Alltrim((cAliasZR7)->ZR8_FILIAL)				, NIL },;
                             { "CT2_LINHA"  , Alltrim((cAliasZR7)->ZR8_ITEM)    			, NIL },;
                             { "CT2_MOEDLC" , Alltrim((cAliasZR7)->ZR8_MOEDLC)  			, NIL },;
                             { "CT2_DC"     , Alltrim((cAliasZR7)->ZR8_TPLC)    			, NIL },;
							 { "CT2_CREDIT" , Alltrim((cAliasZR7)->ZR8_CREDIT)  			, NIL },;
                             { "CT2_DEBITO" , Alltrim((cAliasZR7)->ZR8_DEBITO)  			, NIL },;
                             { "CT2_VALOR"  , (cAliasZR7)->ZR8_VALOR            			, NIL },;
                             { "CT2_CCC"    , Alltrim((cAliasZR7)->ZR8_CCC)     			, NIL },;
                             { "CT2_CCD"    , Alltrim((cAliasZR7)->ZR8_CCD)     			, NIL },;
                             { "CT2_ITEMC"  , Alltrim((cAliasZR7)->ZR8_ITEMC)   			, NIL },;
                             { "CT2_ITEMD"  , Alltrim((cAliasZR7)->ZR8_ITEMD)   			, NIL },;
                             { "CT2_CLVLCR" , Alltrim((cAliasZR7)->ZR8_CLVLC)   			, NIL },;
                             { "CT2_CLVLDB" , Alltrim((cAliasZR7)->ZR8_CLVLD)   			, NIL },;
                             { "CT2_ORIGEM" , "OZ34A001"                        			, NIL },;
                             { "CT2_HP"     , ""                                			, NIL },;
                             { "CT2_HIST"   , cChave + " - INT SENIOR" 						, NIL }})
                              
            nLin += 1
            (cAliasZR7)->(DbSkip()) 
        End
        (cAliasZR7)->(DbCloseArea())

		MSExecAuto( {|X,Y,Z| CTBA102(X,Y,Z)},aCabec,aItens,3)

        If lMsErroAuto
            MostraErro()
			RecLock("ZR7",.F.)
				ZR7->ZR7_STATUS := "R"
			ZR7->(MsUnlock())
		Else 
			RecLock("ZR7",.F.)
				ZR7->ZR7_STATUS := "F"
			ZR7->(MsUnlock())
			MsgInfo("Lote Contabilizado com Sucesso.","Atenção")
        Endif
    Else 
        MsgAlert("Dados não Encontrados.","Atenção")
    EndIf 
Return 

/*/{Protheus.doc} BuscaLote
Busca o lote para ser contabilizado.
@type function
@author Ricardo Tavares Ferreira
@since 07/12/2021
@version 12.1.27
@return logical, Retorna se encontrar dados.
@history 07/12/2021, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//==========================================================================================================
	Static Function BuscaLote()
//==========================================================================================================

    Local cQuery  	:= ""
	Local QbLinha 	:= chr(13)+chr(10)
    Local nQtdReg 	:= 0

    cQuery += " SELECT ZR7.*, ZR8.* "+QbLinha

    cQuery += " FROM "
    cQuery +=   RetSqlName("ZR7") + " ZR7 "+QbLinha

    cQuery += " INNER JOIN "
    cQuery +=   RetSqlName("ZR8") + " ZR8 "+QbLinha
    cQuery += " ON ZR8_FILIAL = ZR7_FILIAL "+QbLinha
    cQuery += " AND ZR8_DOCZR7 = ZR7_DOC "+QbLinha
    cQuery += " AND ZR8_LTZR7 = ZR7_LOTE "+QbLinha
    cQuery += " AND ZR8_SBLZR7 = ZR7_SBLOTE "+QbLinha
    cQuery += " AND ZR8.D_E_L_E_T_ = ' ' "+QbLinha 

    cQuery += " WHERE ZR7.D_E_L_E_T_ = ' ' "+QbLinha 
    cQuery += " AND ZR7_FILIAL = '"+FWXFilial("ZR7")+"' "+QbLinha
    cQuery += " AND ZR7_DOC = '"+Alltrim(ZR7->ZR7_DOC)+"' "+QbLinha
    cQuery += " AND ZR7_LOTE = '"+Alltrim(ZR7->ZR7_LOTE)+"' "+QbLinha
    cQuery += " AND ZR7_SBLOTE = '"+Alltrim(ZR7->ZR7_SBLOTE)+"' "+QbLinha
    cQuery += " AND ZR7_STATUS IN ('A','R') "+QbLinha

    MemoWrite("C:/ricardo/BuscaLote.sql",cQuery)			     
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasZR7,.F.,.T.)
		
	DbSelectArea(cAliasZR7)
	(cAliasZR7)->(DbGoTop())
	Count To nQtdReg
	(cAliasZR7)->(DbGoTop())
		
	If nQtdReg <= 0
		(cAliasZR7)->(DbCloseArea())
        Return .F.
    EndIf
Return .T.

/*/{Protheus.doc} BuscaCT2
Busca o lote Contabilizado para Estorno.
@type function
@author Ricardo Tavares Ferreira
@since 07/12/2021
@version 12.1.27
@return logical, Retorna se encontrar dados.
@history 07/12/2021, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//==========================================================================================================
	Static Function BuscaCT2()
//==========================================================================================================

    Local cQuery  	:= ""
	Local QbLinha 	:= chr(13)+chr(10)
    Local nQtdReg 	:= 0

 	cQuery += " SELECT CT2.* "+QbLinha 
    cQuery += " FROM "
    cQuery +=   RetSqlName("CT2") + " CT2 "+QbLinha
 	cQuery += " WHERE "+QbLinha 
 	cQuery += " CT2.D_E_L_E_T_ = ' ' "+QbLinha 
 	cQuery += " AND CT2_LOTE = '"+Alltrim(ZR7->ZR7_LOTE)+"' "+QbLinha
 	cQuery += " AND CT2_SBLOTE = '"+Alltrim(ZR7->ZR7_SBLOTE)+"' "+QbLinha
 	cQuery += " AND CT2_DOC = '"+Alltrim(ZR7->ZR7_DOC)+"' "+QbLinha

    MemoWrite("C:/ricardo/BuscaCT2.sql",cQuery)			     
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasCT2,.F.,.T.)
		
	DbSelectArea(cAliasCT2)
	(cAliasCT2)->(DbGoTop())
	Count To nQtdReg
	(cAliasCT2)->(DbGoTop())
		
	If nQtdReg <= 0
		(cAliasCT2)->(DbCloseArea())
        Return .F.
    EndIf
Return .T.
