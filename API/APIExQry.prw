#Include "protheus.ch"
#Include "topconn.ch"

/*/{Protheus.doc} APIExQry
Classe responsavel por ler a query e retornar os dados.
@type Class 
@author Ricardo Tavares Ferreira
@return object, Objeto do Browse.
@since 28/03/2021
@history 28/03/2021, Ricardo Tavares Ferreira, Construção Inicial.
@history 07/04/2021, Ricardo Tavares Ferreira, Solução para retornar no arquivo e log o nome da tabela enviada pela requisição da API.
@version 12.1.27
/*/
//=============================================================================================================================
    Class APIExQry From LongNameClass
//=============================================================================================================================
  
    Data aResult    
    Data cQuery     
    Data cFormula     
    Data aFilters   
    Data cAliasQ      
    Data aHeader    
    Data aColumn    
    Data lHasHead   
    Data oJsResult  
    Data lPreparedSt
    Data oPrepS     
    Data cAliasJs   
    Method New(lPreparedSt) Constructor
    Method SetQuery(cQuery)
    Method SetFormula(cFormul)
    Method SetHasHead(lHasHead)
    Method AddFilter(cParam,cFilter)
    Method BuildQuery()
    Method ApplyFilters()
    Method OpenConn()
    Method LoadHeader()
    Method LoadColumn()
    Method CloseConn()
    Method Execute()
    Method ResulToJsObject()
    Method RESTExec()
    Method ExecPreparedSt()
    Method ExecTCSQL()
    Method RunTCSQL() 
    Method SetError()
    Method ExcScalr()
    Method SetNameJs(cAliasJs)
EndClass

/*/{Protheus.doc} New
Metodo New construtor da Classe.
@type Method 
@author Ricardo Tavares Ferreira
@since 28/03/2021
@version 12.1.27
@return object, Retorna o Objeto da Classe
@history 28/03/2021, Ricardo Tavares Ferreira, Construção Inicial.
@history 07/04/2021, Ricardo Tavares Ferreira, Solução para retornar no arquivo e log o nome da tabela enviada pela requisição da API.
/*/
//=============================================================================================================================
    Method New(lPreparedSt) Class APIExQry
//=============================================================================================================================
  
    Default lPreparedSt := .F.
    ::aResult       := {}
    ::aHeader       := {}
    ::cQuery        := ""
    ::cFormula      := ""
    ::aFilters      := {}
    ::lHasHead      := .F.
    ::lPreparedSt   := lPreparedSt
    ::cAliasJs      :=  ""
Return Self

/*/{Protheus.doc} SetQuery
Metodo para Setar o alias do arquivo quando a consulta vier de requisição.
@type Method 
@author Ricardo Tavares Ferreira
@since 07/04/2021
@version 12.1.27
@history 07/04/2021, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//=============================================================================================================================
    Method SetNameJs(cAliasJs) Class APIExQry
//=============================================================================================================================
  
    ::cAliasJs   := cAliasJs
Return Nil

/*/{Protheus.doc} SetQuery
Seta na variavel query a consulta buscada na tabela ZR5.
@type Method 
@author Ricardo Tavares Ferreira
@since 28/03/2021
@version 12.1.27
@history 28/03/2021, Ricardo Tavares Ferreira, Construção Inicial
/*/
//=============================================================================================================================
    Method SetQuery(cQuery) Class APIExQry
//=============================================================================================================================
  
    ::cQuery   := cQuery
    ::cFormula := ""
Return Nil

/*/{Protheus.doc} SetQuery
Seta o codigo da formula da tabela ZR5.
@type Method 
@author Ricardo Tavares Ferreira
@since 28/03/2021
@version 12.1.27
@history 28/03/2021, Ricardo Tavares Ferreira, Construção Inicial
/*/
//=============================================================================================================================
    Method SetFormula(cFormula) Class APIExQry
//=============================================================================================================================
 
    ::cQuery   := ""
    ::cFormula := cFormula
Return Nil

/*/{Protheus.doc} SetHasHead
Verifica se será retornado o cabeçalho da query.
@type Method 
@author Ricardo Tavares Ferreira
@since 28/03/2021
@version 12.1.27
@history 28/03/2021, Ricardo Tavares Ferreira, Construção Inicial
/*/
//=============================================================================================================================
    Method SetHasHead(lHasHead) Class APIExQry
//=============================================================================================================================
 
    ::lHasHead := lHasHead
Return Nil

/*/{Protheus.doc} AddFilter
Adiciona um filtro a query
@type Method 
@author Ricardo Tavares Ferreira
@since 28/03/2021
@version 12.1.27
@history 28/03/2021, Ricardo Tavares Ferreira, Construção Inicial
/*/
//=============================================================================================================================
    Method AddFilter(cParam,cFilter) Class APIExQry
//=============================================================================================================================
 
    Aadd(::aFilters, {cParam,cFilter}) 
Return Nil

/*/{Protheus.doc} BuildQuery
Carrega a consulta cadastrada na tabela ZR5.
@type Method 
@author Ricardo Tavares Ferreira
@since 28/03/2021
@return logical, Retorna se a query foi carregada com sucesso.
@version 12.1.27
@history 28/03/2021, Ricardo Tavares Ferreira, Construção Inicial
/*/
//=============================================================================================================================
    Method BuildQuery() Class APIExQry
//=============================================================================================================================

    If .not. Empty(::cQuery)
        APIUtil():ConsoleLog("APIExQry|BuildQuery","Query ja carregada --> "+Alltrim(::cQuery),1)
        Return .T.
    EndIf 

    If Empty(::cQuery) .and. .not. Empty(::cFormula)
        DbSelectArea("ZR5")
        ZR5->(DbSetOrder(1))
        If ZR5->(DbSeek(FWXFilial("ZR5")+::cFormula))
            If ZR5->ZR5_STATUS == "1"
                ::cQuery := ZR5->ZR5_QUERY
                If ::lPreparedSt
                    ::oPrepS := FWPreparedStatement():New(::cQuery)
                EndIf
                Return .T.
            EndIf
        EndIf
    Else 
        If Empty(::cQuery)
            cMensagem := "Variavel ::cQuery nao preenchida."
            APIUtil():ConsoleLog("APIExQry|BuildQuery",cMensagem,3)
        EndIf 
        If Empty(::cFormula)
            cMensagem := "Variavel ::cFormula nao preenchida."
            APIUtil():ConsoleLog("APIExQry|BuildQuery",cMensagem,3)
        EndIf
    EndIf
Return .F.

/*/{Protheus.doc} ApplyFilters
Aplica filtros passados na query.
@type Method 
@author Ricardo Tavares Ferreira
@since 28/03/2021
@version 12.1.27
@history 28/03/2021, Ricardo Tavares Ferreira, Construção Inicial
/*/
//=============================================================================================================================
    Method ApplyFilters() Class APIExQry
//=============================================================================================================================

    Local nPosFil := 0
    
    For nPosFil := 1 To Len(::aFilters)
        ::cQuery := StrTran(::cQuery,::aFilters[nPosFil][1],::aFilters[nPosFil][2])
    Next nPosFil
Return Nil

/*/{Protheus.doc} OpenConn
Abre a conexao com o banco de dados e retorna os dados da query.
@type Method 
@author Ricardo Tavares Ferreira
@since 28/03/2021
@version 12.1.27
@history 28/03/2021, Ricardo Tavares Ferreira, Construção Inicial.
@history 07/04/2021, Ricardo Tavares Ferreira, Solução para retornar no arquivo e log o nome da tabela enviada pela requisição da API.
/*/
//=============================================================================================================================
    Method OpenConn() Class APIExQry
//=============================================================================================================================

    Local cAliasArq := ""
    Local cPath     := ""
    Local cNomeArq  := ""
    Local nQtdReg   := 0

    If ::cFormula == ""
        cAliasArq := ::cAliasJs
    Else 
        cAliasArq := ::cFormula
    EndIf

    cPath     := SuperGetMV("AP_DIRGRVA",.F.,"\sql_api") 
    cNomeArq  := Lower(ProcName(2)+"_"+cAliasArq+".sql")

    ::cAliasQ := GetNextAlias()

    if !.not. ("WITH " $ ::cQuery)
        ::cQuery := ChangeQuery(::cQuery)
    EndIf

    ::cQuery := StrTran(::cQuery,"[DBO]","[dbo]")
    ::cQuery := StrTran(::cQuery,"DBO.","dbo.")

    DbUseArea(.T.,"TOPCONN",TcGenQry(,,::cQuery),::cAliasQ,.F.,.T.)
    DbSelectArea(::cAliasQ)
    (::cAliasQ)->(DbGoTop())
    Count To nQtdReg
    (::cAliasQ)->(DbGoTop())

    APIUtil():ConsoleLog("OpenConn|APIExQry","Quantidade de Registros retornados ("+cAliasArq+")..: "+cValToChar(nQtdReg),1)

    If .not. APIUtil():CriaDirArquivo(cPath,cNomeArq,::cQuery)
		APIUtil():ConsoleLog("OpenConn|APIExQry","Não foi possivel salvar o aquivo SQL no diretorio "+ cPath + ", porque ele nao existe e nao foi possivel criar.",3)
    EndIf
Return Nil

/*/{Protheus.doc} LoadHeader
Carrega os dados da query carregada no objeto.
@type Method 
@author Ricardo Tavares Ferreira
@since 28/03/2021
@version 12.1.27
@history 28/03/2021, Ricardo Tavares Ferreira, Construção Inicial
/*/
//=============================================================================================================================
    Method LoadHeader() Class APIExQry
//=============================================================================================================================

    Local aStruct := (::cAliasQ)->(DbStruct())
    Local nPosStr := 0
    
    For nPosStr := 1 To Len(aStruct)
        Aadd(::aHeader,aStruct[nPosStr][1])
    Next nPosStr
    
    If ::lHasHead
        Aadd(::aResult,::aHeader)
    EndIf
Return Nil

/*/{Protheus.doc} LoadColumn
Carrega os cabecalhos da query carregada no objeto.
@type Method 
@author Ricardo Tavares Ferreira
@since 28/03/2021
@version 12.1.27
@history 28/03/2021, Ricardo Tavares Ferreira, Construção Inicial
/*/
//=============================================================================================================================
    Method LoadColumn() Class APIExQry
//=============================================================================================================================

    Local nPosCol := 0
    Local aAuxCol := {}
    
    While (::cAliasQ)->(.not. Eof())
        aAuxCol := {}
        For nPosCol := 1 To Len(::aHeader)
            Aadd(aAuxCol,{::aHeader[nPosCol],&(::aHeader[nPosCol])})
        Next
        Aadd(::aResult,aAuxCol)
        (::cAliasQ)->(DbSkip())
    End
Return Nil

/*/{Protheus.doc} CloseConn
Fecha a conexão com o banco de dados aberto anteriormente.
@type Method 
@author Ricardo Tavares Ferreira
@since 28/03/2021
@version 12.1.27
@history 28/03/2021, Ricardo Tavares Ferreira, Construção Inicial
/*/
//=============================================================================================================================
    Method CloseConn() Class APIExQry
//=============================================================================================================================

    If Select(::cAliasQ) <> 0
        (::cAliasQ)->(DbCloseArea())
    EndIf  

    ZR5->(DBCloseArea())  

    If ::lPreparedSt
        ::oPrepS:Destroy()
    EndIf
Return Nil

/*/{Protheus.doc} Execute
Metodo centralizador que executa e retorna os dados encontrados.
@type Method 
@author Ricardo Tavares Ferreira
@since 28/03/2021
@version 12.1.27
@return logical, Retorna se a carregou com sucesso os dados.
@history 28/03/2021, Ricardo Tavares Ferreira, Construção Inicial
/*/
//=============================================================================================================================
    Method Execute() Class APIExQry
//=============================================================================================================================

    Local aArea := GetArea()

    If ::BuildQuery()
        ::ApplyFilters()
        ::OpenConn()
        ::LoadHeader()
        ::LoadColumn()
        ::CloseConn()
    EndIf
    RestArea(aArea)
return ::aResult

/*/{Protheus.doc} ExecPreparedSt
Metodo centralizador que executa e retorna os dados encontrados com o tratamento de Prepared Statment.
@type Method 
@author Ricardo Tavares Ferreira
@since 28/03/2021
@version 12.1.27
@return array, Retorna os dados em formato de array.
@history 28/03/2021, Ricardo Tavares Ferreira, Construção Inicial.
@history 12/04/2021, Ricardo Tavares Ferreira, Tratamento no retorno da tabela conforme a empresa posicionada.
/*/
//=============================================================================================================================
    Method ExecPreparedSt() Class APIExQry
//=============================================================================================================================

    If ::lPreparedSt
        ::cQuery := ::oPrepS:GetFixQuery()
        ::ApplyFilters()
        ::OpenConn()
        ::LoadHeader()
        ::LoadColumn()
        ::CloseConn()
    EndIf
Return ::aResult

/*/{Protheus.doc} ExecTCSQL
Carrega uma Consulta SQL do Tipo INSERT/UPDATE/DELETE
@type Method 
@author Ricardo Tavares Ferreira
@since 28/03/2021
@version 12.1.27
@return logical, Retorna se executou com sucesso a instrução SQL.
@history 28/03/2021, Ricardo Tavares Ferreira, Construção Inicial
/*/
//=============================================================================================================================
    Method ExecTCSQL() Class APIExQry
//=============================================================================================================================

    Local lSucesso := .T.

    If .not. ::BuildQuery()
        APIUtil():ConsoleLog("APIExQry|RunTCSQL","!::buildQuery() - nao buildou a query - deve estar vazio ou bloqueada",3)   
        Return .not. lSucesso    
    EndIf

    ::ApplyFilters()

    lSucesso := ::RunTCSQL()
Return lSucesso

/*/{Protheus.doc} RunTCSQL
Centralizar uso do TcSqlExec de comando cadastrados na ZR5
@type Method 
@author Ricardo Tavares Ferreira
@since 28/03/2021
@version 12.1.27
@return logical, Retorna se executou com sucesso a instrução SQL.
@history 28/03/2021, Ricardo Tavares Ferreira, Construção Inicial
/*/
//=============================================================================================================================
    Method RunTCSQL() Class APIExQry
//=============================================================================================================================

    Local lSucesso := .T.
    
    If TcSqlExec(self:cQuery) < 0
        APIUtil():ConsoleLog("APIExQry|RunTCSQL","Erro no TCSql "+TcSqlError(),3)    
        Return !lSucesso
    Endif
Return lSucesso

/*/{Protheus.doc} SetError
Seta o erro e retorna o mesmo em formato Json.
@type Method 
@author Ricardo Tavares Ferreira
@since 28/03/2021
@version 12.1.27
@history 28/03/2021, Ricardo Tavares Ferreira, Construção Inicial
/*/
//=============================================================================================================================
    Method SetError() Class APIExQry
//=============================================================================================================================

    ::oJsResult := JsonObject():new()
    ::oJsResult["RetError"] := cError
Return 	

/*/{Protheus.doc} ExcScalr
Executa uma query em forma escalar.
@type Method 
@author Ricardo Tavares Ferreira
@since 28/03/2021
@version 12.1.27
@return character, Retorna qualquer tipo dependendo a consulta passada.
@history 28/03/2021, Ricardo Tavares Ferreira, Construção Inicial
/*/
//=============================================================================================================================
    Method ExcScalr(cField) Class APIExQry
//=============================================================================================================================

    Local xReturn

	xReturn := MpSysExecScalar(::cQuery,cField)
return xReturn
