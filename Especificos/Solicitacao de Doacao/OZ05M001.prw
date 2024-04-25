#INCLUDE "TOTVS.CH"
#INCLUDE "FWEDITPANEL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} OZ05M001
Rotina que apresenta uma tela em MVC com os dados da aprovação
@type function           
@author Ricardo Tavares Ferreira
@since 31/01/2022
@version 12.1.27
@history 31/01/2022, Ricardo Tavares Ferreira, Construção Inicial
@return object, Retorna o objeto do Browse.
/*/
//=============================================================================================================================
    User Function OZ05M001()
//=============================================================================================================================

    //Desabilita todos botoes do outras ações e chama a tela do acompanhamento
    Local aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,"Salvar"},{.T.,"Fechar"},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
    
    Private cFilPrivate     := ""
    Private cNumPrivate     := ""
    Private cTipoPrivate    := ""    
    Private cSolicPrivate   := ""
    Private cAliasSCR       := GetNextAlias()

    if Empty(SZE->ZE_FILIAL) .or. Empty(SZE->ZE_CODIGO) 
        return MsgInfo("Dados insuficientes para pesquisa","Verifique como chamar a consulta")
    EndIF

    cFilPrivate   := AllTrim(SZE->ZE_FILIAL)
    cNumPrivate   := AllTrim(SZE->ZE_CODIGO)   
    cTipoPrivate  := "SD"  
    cSolicPrivate := AllTrim(SZE->ZE_SOLICIT)

    If GetSCR(cFilPrivate,cNumPrivate,cTipoPrivate)
        FWExecView("Acompanhamento da Aprovação de Doações","OZ05M001",MODEL_OPERATION_VIEW,,{|| .T.},,75,aButtons)
    Else 
        MsgInfo("Dados da Aprovação não Encontrados", "Atenção")
    EndIf 
Return

/*/{Protheus.doc} ModelDef
Funcao que cria o modelo de dados da rotina.
@type function
@author Ricardo Tavares Ferreira
@since 31/01/2022
@version 12.1.17
@history 31/01/2022, Ricardo Tavares Ferreira, Construção Inicial
@return object, Retorna o Objeto do Modelo.
/*/
//==========================================================================================================
	Static Function ModelDef()
//==========================================================================================================

    Local oModel
    Local oStrMst := getMstModelStruct()
    Local oStrDet := getDetModelStruct()

    // oModel := MPFormModel():New("SITUASRC",,,{|oModel| Commit(oModel) })        
    oModel := FWFormModel():New("SITUASRC", , { |oMdl| COMP011POS( oMdl ) }, {|oModel| commit()},{|oModel| cancel()})
    oModel:SetDescription("Exemplo Modelo sem SXs")
        
    oModel:AddFields("CABEC",/*cOwner*/,oStrMst,,,{|| LoadMaster() })
    oModel:AddGrid("CRGRID","CABEC",oStrDet,,,,,{|| LoadDetail() })
    oModel:SetRelation("CRGRID",{{"CR_FILIAL","CR_FILIAL"},{"CR_NUM","CR_NUM"}})

    oModel:getModel("CABEC"):SetDescription("DADOS")
    oModel:getModel("CRGRID"):SetDescription("DEDOS")
    oModel:SetPrimaryKey({1})
Return oModel

/*/{Protheus.doc} ViewDef
Define tela padrao do modelo.
@type function
@author Ricardo Tavares Ferreira
@since 31/01/2022
@version 12.1.17
@history 31/01/2022, Ricardo Tavares Ferreira, Construção Inicial
@return object, Retorna o Objeto do Modelo.
/*/
//==========================================================================================================
	Static Function ViewDef()
//==========================================================================================================

    Local oView
    Local oModel  := ModelDef() //Modelo construido neste fonte
    Local oStrMst := getMstViewStruct()
    Local oStrDet := getDetViewStruct()

	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	oView:AddField("CABEC" , oStrMst)
    oView:CreateHorizontalBox( "BOXFORM1", 40)
	oView:SetOwnerView("CABEC","BOXFORM1")
	//oView:SetViewProperty("CABEC" , "SETLAYOUT" , {LAYOUT_VERT_DESCR_LEFT ,2} ) 
    oView:SetViewProperty("CABEC", "ONLYVIEW")          
	oView:EnableTitleView("CABEC" , "Dados da Solicitação de Doação" ) 

    oView:AddGrid("CRGRID" , oStrDet)
	oView:CreateHorizontalBox( "BOXGRID", 60)
	oView:SetOwnerView("CRGRID","BOXGRID")
    oView:EnableTitleView("CRGRID" , "Dados dos Aprovadores da Solicitação de Doação" ) 
    oView:SetViewProperty("CRGRID", "ONLYVIEW")      
    // oView:SetViewProperty( "CRGRID", "ENABLEDGRIDDETAIL", { 25 } )
    
    oStrMst:RemoveField("XR_SOLCIT") 
    
    oStrDet:RemoveField("CR_FILIAL") // A estrutura inicial é igual para salvar os dados? e depois só retiro o que nao vai aparecer?
    oStrDet:RemoveField("CR_NUM") 
    //oStrDet:RemoveField("CR_USERLIB") 
    oStrDet:RemoveField("CR_USERORI") 
    oStrDet:RemoveField("CR_APRORI") 
    oStrDet:RemoveField("CR_APROV") 
    oStrDet:RemoveField("CR_OBS") 

Return oView

/*/{Protheus.doc} getMstModelStruct
Define estrutura do modelo de dados sem o dicionario - Detalhes da SCR.
@type function
@author Ricardo Tavares Ferreira
@since 31/01/2022
@version 12.1.17
@obs FWFORMMODELSTRUCT():AddField(<cTitulo >, <cTooltip >, <cIdField >, <cTipo >, <nTamanho >, [ nDecimal ], [ bValid ], [ bWhen ], [ aValues ], [ lObrigat ], [ bInit ], <lKey >, [ lNoUpd ], [ lVirtual ], [ cValid ])-> NIL
oStruct:AddField("Arquivo Origem","Arquivo Origem" , "ARQ", "C", 50, 0, , , {}, .T., , .F., .F., .F., , )
@link https://tdn.totvs.com/display/framework/FWFormModelStruct
@link https://github.com/julianeventeu/Dominando-MVC-AdvPL/blob/master/cadastros/CMVC_08.prw
@history 31/01/2022, Ricardo Tavares Ferreira, Construção Inicial
@return object, Retorna o Objeto do Modelo.
/*/
//==========================================================================================================
	Static Function  getMstModelStruct()
//==========================================================================================================

    Local oStruct   := FWFormModelStruct():New()
    Local lObrigat  := .T. // Campo Obrigatorio
    Local lKey      := .T. // Campo chave de indice
    Local lNoUpd    := .T. // Campo não recebe atualização
    Local cField    := ""  // Usar para montar tela baseada em um campo da X3
	
	cField := "XR_SITUAC"
    oStruct:AddField("Situação","Situação" , cField, "C", 30, 0, , , {}, !lObrigat, , , !lKey, lNoUpd, , )		
	cField := "CR_NUM"
    oStruct:AddField(TRIM(X3Titulo(cField)),TRIM(X3Titulo(cField)) , cField, FWSX3Util():GetFieldType( cField ), 10, TamSX3(cField)[2], , , {}, !lObrigat, , , !lKey, lNoUpd, , )
    cField := "CR_FILIAL"
    oStruct:AddField(TRIM(X3Titulo(cField)),TRIM(X3Titulo(cField)) , cField, FWSX3Util():GetFieldType( cField ), TamSX3(cField)[1], TamSX3(cField)[2], , , {}, !lObrigat, , , !lKey, lNoUpd, , )
	cField := "XR_SOLCIT"
    oStruct:AddField("Solicitante","Solicitante" , cField, "C", 30, 0, , , {}, !lObrigat, , , !lKey, lNoUpd, , )
	
return oStruct

/*/{Protheus.doc} getDetModelStruct
Define estrutura do modelo de dados sem o dicionario - Detalhes da SCR.
@type function
@author Ricardo Tavares Ferreira
@since 31/01/2022
@version 12.1.17
@obs FWFORMMODELSTRUCT():AddField(<cTitulo >, <cTooltip >, <cIdField >, <cTipo >, <nTamanho >, [ nDecimal ], [ bValid ], [ bWhen ], [ aValues ], [ lObrigat ], [ bInit ], <lKey >, [ lNoUpd ], [ lVirtual ], [ cValid ])-> NIL
oStruct:AddField("Arquivo Origem","Arquivo Origem" , "ARQ", "C", 50, 0, , , {}, .T., , .F., .F., .F., , )
@link https://tdn.totvs.com/display/framework/FWFormModelStruct
@link https://github.com/julianeventeu/Dominando-MVC-AdvPL/blob/master/cadastros/CMVC_08.prw
@history 31/01/2022, Ricardo Tavares Ferreira, Construção Inicial
@return object, Retorna o Objeto do Modelo.
/*/
//==========================================================================================================
	Static Function  getDetModelStruct()
//==========================================================================================================

    Local oStruct   := FWFormModelStruct():New()
    Local lObrigat  := .T. // Campo Obrigatorio
    Local lKey      := .T. // Campo chave de indice
    Local lNoUpd    := .T. // Campo não recebe atualização
    Local cField    := ""  // Usar para montar tela baseada em um campo da X3
	
    cField := "CR_FILIAL"
    oStruct:AddField(TRIM(X3Titulo(cField)),TRIM(X3Titulo(cField)) , cField, FWSX3Util():GetFieldType( cField ), TamSX3(cField)[1], TamSX3(cField)[2], , , {}, !lObrigat, , , !lKey, lNoUpd, , )
    cField := "CR_NUM"
    oStruct:AddField(TRIM(X3Titulo(cField)),TRIM(X3Titulo(cField)) , cField, FWSX3Util():GetFieldType( cField ), TamSX3(cField)[1], TamSX3(cField)[2], , , {}, !lObrigat, , , !lKey, lNoUpd, , )
	cField := "CR_NIVEL"
    oStruct:AddField("Nível","Nível" , cField, FWSX3Util():GetFieldType( cField ), TamSX3(cField)[1], TamSX3(cField)[2], , , {}, !lObrigat, , , !lKey, lNoUpd, , )
	cField := "CR_STATUS"
    oStruct:AddField("Situação","Situação" , cField, FWSX3Util():GetFieldType( cField ), 25, 0, , , {}, !lObrigat, , , !lKey, lNoUpd, , )
	cField := "CR_USERLIB"
    oStruct:AddField("Aprovador","Aprovador" , cField, FWSX3Util():GetFieldType( cField ), 25, 0, , , {}, !lObrigat, , , !lKey, lNoUpd, , )
	cField := "CR_DATALIB"
    oStruct:AddField(TRIM(X3Titulo(cField)),TRIM(X3Titulo(cField)) , cField, FWSX3Util():GetFieldType( cField ), TamSX3(cField)[1], TamSX3(cField)[2], , , {}, !lObrigat, , , !lKey, lNoUpd, , )
	cField := "CR_USER"
    oStruct:AddField(TRIM(X3Titulo(cField)),TRIM(X3Titulo(cField)) , cField, FWSX3Util():GetFieldType( cField ), TamSX3(cField)[1], TamSX3(cField)[2], , , {}, !lObrigat, , , !lKey, lNoUpd, , )
	cField := "CR_OBS"
    oStruct:AddField(TRIM(X3Titulo(cField)),TRIM(X3Titulo(cField)) , cField, FWSX3Util():GetFieldType( cField ), TamSX3(cField)[1], TamSX3(cField)[2], , , {}, !lObrigat, , , !lKey, lNoUpd, , )
	cField := "CR_USERORI"
    oStruct:AddField(TRIM(X3Titulo(cField)),TRIM(X3Titulo(cField)) , cField, FWSX3Util():GetFieldType( cField ), TamSX3(cField)[1], TamSX3(cField)[2], , , {}, !lObrigat, , , !lKey, lNoUpd, , )
	cField := "CR_APRORI"
    oStruct:AddField(TRIM(X3Titulo(cField)),TRIM(X3Titulo(cField)) , cField, FWSX3Util():GetFieldType( cField ), TamSX3(cField)[1], TamSX3(cField)[2], , , {}, !lObrigat, , , !lKey, lNoUpd, , )
	cField := "CR_APROV"
    oStruct:AddField(TRIM(X3Titulo(cField)),TRIM(X3Titulo(cField)) , cField, FWSX3Util():GetFieldType( cField ), TamSX3(cField)[1], TamSX3(cField)[2], , , {}, !lObrigat, , , !lKey, lNoUpd, , )
	
return oStruct

/*/{Protheus.doc} getMstViewStruct
Define estrutura do modelo de dados sem o dicionario - Detalhes da SCR.
@type function
@author Ricardo Tavares Ferreira
@since 31/01/2022
@version 12.1.17
@obs FWFORMVIEW():AddField(< cViewID >, < oStruct >, [ cSubModelID ])-> NIL
    
    oStMaster:AddField(;
    "AMJ_LOTE",;                // [01]  C   Nome do Campo
    "01",;                      // [02]  C   Ordem
    "Lote",;                    // [03]  C   Titulo do campo
    X3Descric("AMJ_LOTE"),;     // [04]  C   Descricao do campo
    Nil,;                       // [05]  A   Array com Help
    "C",;                       // [06]  C   Tipo do campo
    X3Picture("AMJ_LOTE"),;     // [07]  C   Picture
    Nil,;                       // [08]  B   Bloco de PictTre Var
    Nil,;                       // [09]  C   Consulta F3
    Iif(INCLUI, .T., .F.),;     // [10]  L   Indica se o campo é alteravel
    Nil,;                       // [11]  C   Pasta do campo
    Nil,;                       // [12]  C   Agrupamento do campo
    Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
    Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
    Nil,;                       // [15]  C   Inicializador de Browse
    Nil,;                       // [16]  L   Indica se o campo é virtual
    Nil,;                       // [17]  C   Picture Variavel
    Nil)                        // [18]  L   Indica pulo de linha após o campo                                                                                     
        
    oStMaster:AddField("AMJ_XARQUI" , "01","Arquivo",X3Descric("AMJ_XARQUI"),Nil,"D",X3Picture("AMJ_XARQUI"),Nil,Nil,Iif(INCLUI, .T., .F.), Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil)
@link https://tdn.totvs.com/display/public/PROT/FWFormViewStruct
@link https://github.com/julianeventeu/Dominando-MVC-AdvPL/blob/master/cadastros/CMVC_08.prw
@history 31/01/2022, Ricardo Tavares Ferreira, Construção Inicial
@return object, Retorna o Objeto da View.
/*/
//==========================================================================================================
	Static Function  getMstViewStruct()
//==========================================================================================================

    Local oStruct := FWFormViewStruct():New()
    Local lAltera := .T.
    Local nQtdFields := 0   //Facilitador das posições -> daqui a pouco crio uma função
    
    cField := "XR_SITUAC"
    nQtdFields++
    oStruct:AddField( cField,cValToChar(nQtdFields),"Situação","Situação",, "C" /*Get?*/ ,,,,!lAltera,,,,,,,, )	

	cField := "CR_NUM"
    nQtdFields++
    oStruct:AddField( cField,cValToChar(nQtdFields),FWSX3Util():GetDescription( cField ),TRIM(X3Descric(cField)),, FWSX3Util():GetFieldType( cField ) /*Get?*/ ,,,,!lAltera,,,,,,,, )

	cField := "CR_FILIAL"    
    nQtdFields++
    oStruct:AddField( cField,cValToChar(nQtdFields),FWSX3Util():GetDescription( cField ),TRIM(X3Descric(cField)),, FWSX3Util():GetFieldType( cField ) /*Get?*/ ,,,,!lAltera,,,,,,,, )

    cField := "XR_SOLCIT"
    nQtdFields++
    oStruct:AddField( cField,cValToChar(nQtdFields),"Solicitante","Solicitante",, "C" /*Get?*/ ,,,,!lAltera,,,,,,,, )
	
return oStruct

/*/{Protheus.doc} getDetViewStruct
Define estrutura do modelo de dados sem o dicionario - Detalhes da SCR.
@type function
@author Ricardo Tavares Ferreira
@since 31/01/2022
@version 12.1.17
@obs FWFORMVIEW():AddField(< cViewID >, < oStruct >, [ cSubModelID ])-> NIL 
@link https://tdn.totvs.com/display/public/PROT/FWFormViewStruct
@link https://github.com/julianeventeu/Dominando-MVC-AdvPL/blob/master/cadastros/CMVC_08.prw
@history 31/01/2022, Ricardo Tavares Ferreira, Construção Inicial
@return object, Retorna o Objeto da View.
/*/
//==========================================================================================================
	Static Function  getDetViewStruct()
//==========================================================================================================

    Local oStruct    := FWFormViewStruct():New()
    Local lAltera    := .T.
    Local nQtdFields := 0   //Facilitador das posições -> daqui a pouco crio uma função
	
    cField      := "CR_FILIAL"
    nQtdFields++
    oStruct:AddField( cField,cValToChar(nQtdFields),FWSX3Util():GetDescription( cField ),TRIM(X3Descric(cField)),, FWSX3Util():GetFieldType( cField ) /*Get?*/ ,,,,!lAltera,,,,,,,, )
    
    cField := "CR_NUM"    
    nQtdFields++
    oStruct:AddField( cField,cValToChar(nQtdFields),FWSX3Util():GetDescription( cField ),TRIM(X3Descric(cField)),, FWSX3Util():GetFieldType( cField ) /*Get?*/ ,,,,!lAltera,,,,,,,, )
    
    cField := "CR_NIVEL"
    nQtdFields++
    oStruct:AddField( cField,cValToChar(nQtdFields),"Nível",TRIM(X3Descric(cField)),, FWSX3Util():GetFieldType( cField ) /*Get?*/ ,,,,!lAltera,,,,,,,, )
	
    cField := "CR_STATUS"
    nQtdFields++
    oStruct:AddField( cField,cValToChar(nQtdFields),"Status de Aprovação",TRIM(X3Descric(cField)),, FWSX3Util():GetFieldType( cField ) /*Get?*/ ,,,,!lAltera,,,,,,,, )
	
    cField := "CR_USERLIB"
    nQtdFields++
    oStruct:AddField( cField,cValToChar(nQtdFields),"Aprovador",TRIM(X3Descric(cField)),, FWSX3Util():GetFieldType( cField ) /*Get?*/ ,,,,!lAltera,,,,,,,, )
	
    cField := "CR_DATALIB"
    nQtdFields++
    oStruct:AddField( cField,cValToChar(nQtdFields),FWSX3Util():GetDescription( cField ),TRIM(X3Descric(cField)),, FWSX3Util():GetFieldType( cField ) /*Get?*/ ,,,,!lAltera,,,,,,,, )
	
    cField := "CR_USER"    
    nQtdFields++
    oStruct:AddField( cField,cValToChar(nQtdFields),FWSX3Util():GetDescription( cField ),TRIM(X3Descric(cField)),, FWSX3Util():GetFieldType( cField ) /*Get?*/ ,,,,!lAltera,,,,,,,, )
    
    cField := "CR_OBS"
    nQtdFields++
    oStruct:AddField( cField,cValToChar(nQtdFields),FWSX3Util():GetDescription( cField ),TRIM(X3Descric(cField)),, FWSX3Util():GetFieldType( cField ) /*Get?*/ ,,,,!lAltera,,,,,,,, )
	
    cField := "CR_USERORI"
    nQtdFields++
    oStruct:AddField( cField,cValToChar(nQtdFields),FWSX3Util():GetDescription( cField ),TRIM(X3Descric(cField)),, FWSX3Util():GetFieldType( cField ) /*Get?*/ ,,,,!lAltera,,,,,,,, )
	
    cField := "CR_APRORI"
    nQtdFields++
    oStruct:AddField( cField,cValToChar(nQtdFields),FWSX3Util():GetDescription( cField ),TRIM(X3Descric(cField)),, FWSX3Util():GetFieldType( cField ) /*Get?*/ ,,,,!lAltera,,,,,,,, )
	
    cField := "CR_APROV"
    nQtdFields++
    oStruct:AddField( cField,cValToChar(nQtdFields),FWSX3Util():GetDescription( cField ),TRIM(X3Descric(cField)),, FWSX3Util():GetFieldType( cField ) /*Get?*/ ,,,,!lAltera,,,,,,,, )
	
return oStruct

/*/{Protheus.doc} LoadMaster
Carrega dados do modelo - necessário já que a tela nao vem do dicionario - logo nao tem um recno para posicionar e carregar o padrao.
@type function
@author Ricardo Tavares Ferreira
@since 31/01/2022
@version 12.1.17
@history 31/01/2022, Ricardo Tavares Ferreira, Construção Inicial
@return array, Retorna um array contendo os dados do cabeçalho da tela.
/*/
//==========================================================================================================
	Static Function  LoadMaster()
//==========================================================================================================

    Local aLoad     := {}
    Local cStatus   := ""

    If SZE->ZE_STATUS == "1"
        cStatus := "Solicitação Pendente de Aprovação"
    ElseIf SZE->ZE_STATUS == "2"
        cStatus := "Solicitação Reprovada"
    ElseIf SZE->ZE_STATUS == "3"
        cStatus := "Solicitação Em Aprovação"
    ElseIf SZE->ZE_STATUS == "4"
        cStatus := "Solicitação Aprovada"
    ElseIf SZE->ZE_STATUS == "5"
        cStatus := "Solicitação Finalizada"
    EndIf

    aadd(aLoad,{cStatus,cNumPrivate,cFilPrivate,cSolicPrivate}) 
    aadd(aLoad,0) // Recno

Return aLoad

/*/{Protheus.doc} LoadDetail
Carrega dados do modelo - necessário já que a tela nao vem do dicionario - logo nao tem um recno para posicionar e carregar o padrao.
@type function
@author Ricardo Tavares Ferreira
@since 31/01/2022
@version 12.1.17
@history 31/01/2022, Ricardo Tavares Ferreira, Construção Inicial
@return array, Retorna um array contendo os dados dos Itens da tela.
/*/
//==========================================================================================================
	Static Function LoadDetail()
//==========================================================================================================

    Local aLoad     := {}
    Local nItSCR    := 0
    Local cStatus   := ""

    DbSelectArea("SCR")
    
    While .not. (cAliasSCR)->(Eof())
        SCR->(DbGoTo((cAliasSCR)->IDSCR))

        If Alltrim((cAliasSCR)->CR_STATUS) == "01" 
            cStatus := "Pendente em Níveis Anteriores"
        ElseIf Alltrim((cAliasSCR)->CR_STATUS) == "02" 
            cStatus := "Pendente no Nível Atual"
        ElseIf Alltrim((cAliasSCR)->CR_STATUS) == "03"  
            cStatus := "Nível Aprovado"
        ElseIf Alltrim((cAliasSCR)->CR_STATUS) == "04"  
            cStatus := "Bloqueado"
        ElseIf Alltrim((cAliasSCR)->CR_STATUS) == "05"  
            cStatus := "Aprovado / Rejeitado pelo Nível"
        ElseIf Alltrim((cAliasSCR)->CR_STATUS) == "06"  
            cStatus := "Rejeitado"
        EndIf

        aadd(aLoad,{nItSCR,{ Alltrim((cAliasSCR)->CR_FILIAL),;
                             Alltrim((cAliasSCR)->CR_NUM),;
                             Alltrim((cAliasSCR)->CR_NIVEL),;
                             Alltrim(cStatus),;
                             Alltrim(&("UsrFullName((cAliasSCR)->CR_USER)")),;
                             Stod(Alltrim((cAliasSCR)->CR_DATALIB)),;
                             Alltrim((cAliasSCR)->CR_USER),;
                             Alltrim(SCR->CR_OBS),;
                             Alltrim((cAliasSCR)->CR_USERORI),;
                             Alltrim((cAliasSCR)->CR_APRORI),;
                             Alltrim((cAliasSCR)->CR_APROV)}}) 
        nItSCR++
        (cAliasSCR)->(DbSkip())
    End
    (cAliasSCR)->(DbCloseArea())           
return aLoad

/*/{Protheus.doc} GetSCR
Busca os dados da tabela SCR.
@type function
@author Ricardo Tavares Ferreira
@since 01/02/2022
@version 12.1.17
@history 01/02/2022, Ricardo Tavares Ferreira, Construção Inicial
@return logical, Retorna verdadeiro se os dados existirem.
/*/
//==========================================================================================================
	Static Function GetSCR(cFilPrivate,cNumPrivate,cTipoPrivate)
//==========================================================================================================

	Local cQuery  	:= ""
	Local QbLinha 	:= chr(13)+chr(10)
    Local nQtdReg 	:= 0

	cQuery := " SELECT SCR.R_E_C_N_O_ IDSCR, SCR.* "+QbLinha
    cQuery += " FROM "
    cQuery +=   RetSqlName("SCR") + " SCR "+QbLinha
	cQuery += " WHERE SCR.D_E_L_E_T_ = ' ' "+QbLinha
	cQuery += " AND CR_FILIAL = '"+AllTrim(cFilPrivate)+"' "+QbLinha 
	cQuery += " AND CR_NUM = '"+AllTrim(cNumPrivate)+"' "+QbLinha 
	cQuery += " AND CR_TIPO = '"+AllTrim(cTipoPrivate)+"' "+QbLinha 

	MemoWrite("C:/ricardo/OZ05M001_GetSCR.sql",cQuery)			     
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSCR,.F.,.T.)
		
	DbSelectArea(cAliasSCR)
	(cAliasSCR)->(DbGoTop())
	Count To nQtdReg
	(cAliasSCR)->(DbGoTop())
		
	If nQtdReg <= 0
		(cAliasSCR)->(DbCloseArea())
        Return .F.
    EndIf
Return .T.
