#Include "PROTHEUS.CH"
#Include "XMLXFUN.CH"
#Include "APWEBSRV.CH"
#Include "topconn.ch"
#Include "RWMAKE.CH"
#Include "TBICONN.CH"
#Include "ERROR.CH"

/*/{Protheus.doc} Pagamentos
Funcao que monta as estruturas do array do WebService de Pagamentos
@author Ricardo Tavares Ferreira
@since 29/08/2019
@version 12.1.17
@return .T.
@obs Ricardo Tavares - Construcao Inicial
/*/
//====================================================================================================
    WsStruct Pagamento
//====================================================================================================

    WsData Empresa              as String
    WsData Filial               as String
    WsData Prefixo              as String
    WsData NumTitulo            as String
    WsData Parcela              as String
    WsData Tipo                 as String
    WsData Fornecedor           as String
    WsData Loja                 as String
    WsData NomeFornece          as String
    WsData Natureza             as String
    WsData CentroCusto          as String
    WsData ItemContabil         as String
    WsData DataContabil         as String
    WsData Vencimento           as String
    WsData VencReal             as String
    WsData DataEmissao          as String
    WsData Historico            as String
    WsData ValorTotal           as Float
EndWsStruct

/*/{Protheus.doc} Pagamentos
Funcao que monta o array do WebService de Pagamentos
@author Ricardo Tavares Ferreira
@since 29/08/2019
@version 12.1.17
@return .T.
@obs Ricardo Tavares - Construcao Inicial
/*/
//====================================================================================================
    WsStruct Pagamentos
//====================================================================================================
    
    WsData PagamentosLote       as Array of Pagamento
EndWsStruct

/*/{Protheus.doc} WsPagamentos
Funcao que cria o WebService de Pagamentos
@author Ricardo Tavares Ferreira
@since 29/08/2019
@version 12.1.17
@return .T.
@obs Ricardo Tavares - Construcao Inicial
/*/
//==============================================================================================================================================================================================================================
    WsService WsPagamentos Description "Busca e Insere os dados de Pagamentos no Contas a Pagar"
//==============================================================================================================================================================================================================================

    WsData Empresa              as String
    WsData FilialInicial        as String 
    WsData FilialFinal          as String 
    WsData PrefixoInicial       as String 
    WsData PrefixoFinal         as String 
    WsData TituloInicial        as String 
    WsData TituloFinal          as String 
    WsData FornecInicial        as String
    WsData FornecFinal          as String 
    WsData LojaInicial          as String 
    WsData LojaFinal            as String 
    WSData cRetPagamentos       as String 
	WsData PostPagamentosLote   as Pagamentos 
    WsData GetPagamentosLote    as Pagamentos

	WsMethod GetPagamentos 	Description "Retorna os Titulos Conforme Paramentos Passados como Referencia"
	WsMethod PostPagamentos	Description "Insere os Titulos Passados como Paramentos no Contas a Pagar Protheus"
EndWsService

/*/{Protheus.doc} GetPagamentos
Funcao que busca os titulos do financeiro
@author Ricardo Tavares Ferreira
@since 29/08/2019
@version 12.1.17
@return .T.
@obs Ricardo Tavares - Construcao Inicial
/*/
//==============================================================================================================================================================================================================================
    WsMethod GetPagamentos WsReceive Empresa, FilialInicial, FilialFinal, PrefixoInicial, PrefixoFinal, TituloInicial, TituloFinal, FornecInicial, FornecFinal, LojaInicial, LojaFinal WsSend GetPagamentosLote WsService WsPagamentos
//==============================================================================================================================================================================================================================

	Local cQuery        := ""
	Local QbLinha	    := chr(13)+chr(10)
    Local nQtdReg       := 0
    Local aTables       := {"SA2","SE2","SED"}
    Local cAliasTit     := ""
    Local oNewTitulo    := Nil
    Local cEmpBck       := ""

    RPCSetType(3)
	RpcSetEnv(Empresa,FilialInicial,Nil,Nil,"FIN",Nil,aTables)

    cEmpAnt   := Empresa
    cAliasTit := GetNextAlias()

    cQuery := " SELECT "+QbLinha 
    cQuery += " E2_FILIAL		FILIAL "+QbLinha 	
    cQuery += " , E2_PREFIXO	PREFIXO "+QbLinha
    cQuery += " , E2_NUM		TITULO "+QbLinha
    cQuery += " , E2_PARCELA	PARCELA "+QbLinha
    cQuery += " , E2_TIPO		TIPO "+QbLinha
    cQuery += " , E2_NATUREZ	NATUREZA "+QbLinha
    cQuery += " , E2_FORNECE	FORNECEDOR "+QbLinha
    cQuery += " , E2_LOJA		LOJA "+QbLinha
    cQuery += " , E2_NOMFOR		NOMEFOR "+QbLinha
    cQuery += " , E2_EMISSAO	EMISSAO "+QbLinha
    cQuery += " , E2_EMIS1		DTCONTAB "+QbLinha
    cQuery += " , E2_VENCTO		VENCIMENTO "+QbLinha
    cQuery += " , E2_VENCREA	VENCREAL "+QbLinha
    cQuery += " , E2_HIST		HISTORICO "+QbLinha
    cQuery += " , E2_VALOR		VALOR "+QbLinha
    cQuery += " , E2_ITEMD		ITEMCONTAB "+QbLinha
    cQuery += " , E2_CCUSTO		CENTROCUSTO "+QbLinha
    cQuery += " FROM "
    cQuery +=   RetSqlName("SE2") + " SE2 "+QbLinha
    cQuery += " WHERE SE2.D_E_L_E_T_ = ' ' "+QbLinha 
    cQuery += " AND E2_FILIAL BETWEEN   '"+FilialInicial+"' AND '"+FilialFinal+"' "+QbLinha
    cQuery += " AND E2_PREFIXO BETWEEN  '"+PrefixoInicial+"' AND '"+PrefixoFinal+"' "+QbLinha
    cQuery += " AND E2_NUM BETWEEN      '"+TituloInicial+"' AND '"+TituloFinal+"' "+QbLinha
    cQuery += " AND E2_FORNECE BETWEEN  '"+FornecInicial+"' AND '"+FornecFinal+"' "+QbLinha
    cQuery += " AND E2_LOJA BETWEEN     '"+LojaInicial+"' AND '"+LojaFinal+"' "+QbLinha

    MemoWrite("C:/ricardo/GetPagamentos.sql",cQuery)			     
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasTit,.F.,.T.)
		
	DbSelectArea(cAliasTit)
	(cAliasTit)->(DbGoTop())
	Count To nQtdReg
	(cAliasTit)->(DbGoTop())
		
	If nQtdReg <= 0
        ::GetPagamentosLote := WSClassNew("Pagamentos")
        ::GetPagamentosLote:PagamentosLote := {}
		(cAliasTit)->(DbCloseArea())
        SetSoapFault( "406", "Dados nao Encontrados." )
        Return .T.
    Else
        ::GetPagamentosLote := WSClassNew("Pagamentos")
        ::GetPagamentosLote:PagamentosLote := {}

        While .not. (cAliasTit)->(Eof())
            oNewTitulo := WSClassNew("Pagamento")
            oNewTitulo:Empresa      := Alltrim(cEmpAnt)  
            oNewTitulo:Filial       := Alltrim((cAliasTit)->(FILIAL))   
            oNewTitulo:Prefixo      := Alltrim((cAliasTit)->(PREFIXO))
            oNewTitulo:NumTitulo    := Alltrim((cAliasTit)->(TITULO))
            oNewTitulo:Parcela      := Alltrim((cAliasTit)->(PARCELA))
            oNewTitulo:Tipo         := Alltrim((cAliasTit)->(TIPO))
            oNewTitulo:Fornecedor   := Alltrim((cAliasTit)->(FORNECEDOR))
            oNewTitulo:Loja         := Alltrim((cAliasTit)->(LOJA))
            oNewTitulo:NomeFornece  := Alltrim((cAliasTit)->(NOMEFOR))
            oNewTitulo:Natureza     := Alltrim((cAliasTit)->(NATUREZA))
            oNewTitulo:CentroCusto  := Alltrim((cAliasTit)->(CENTROCUSTO))
            oNewTitulo:ItemContabil := Alltrim((cAliasTit)->(ITEMCONTAB))
            oNewTitulo:DataContabil := Dtoc(Stod((cAliasTit)->(DTCONTAB)))
            oNewTitulo:Vencimento   := Dtoc(Stod((cAliasTit)->(VENCIMENTO)))
            oNewTitulo:VencReal     := Dtoc(Stod((cAliasTit)->(VENCREAL)))
            oNewTitulo:DataEmissao  := Dtoc(Stod((cAliasTit)->(EMISSAO)))
            oNewTitulo:Historico    := Alltrim((cAliasTit)->(HISTORICO))
            oNewTitulo:ValorTotal   := (cAliasTit)->(VALOR)

            aadd(::GetPagamentosLote:PagamentosLote,oNewTitulo)
            oNewTitulo := Nil
            (cAliasTit)->(DbSkip())
        End
        (cAliasTit)->(DbCloseArea())
    EndIf
    cEmpAnt := cEmpBck
Return .T.

/*/{Protheus.doc} PostPagamentos
Funcao que cria os titulos do financeiro
@author Ricardo Tavares Ferreira
@since 29/08/2019
@version 12.1.17
@return .T.
@obs Ricardo Tavares - Construcao Inicial
/*/
//====================================================================================================
    WsMethod PostPagamentos WsReceive PostPagamentosLote WsSend cRetPagamentos WsService WsPagamentos
//====================================================================================================

    Local nX            := 0
    Local nY            := 0
    Local aTitulos      := {}
    Local aTables       := {"SA2","SE2","SED"}  
    Local cError        := ""
    Local nOption       := 0
    Local xEmp          := ""
    Local xFil          := ""
 
    //Variáveis de controle do ExecAuto
    Private lMSHelpAuto     := .T.
    Private lAutoErrNoFile  := .T.
    Private lMsErroAuto     := .F.

    xEmp := Alltrim(PostPagamentosLote:PAGAMENTOSLOTE[1]:EMPRESA)
    xFil := Alltrim(PostPagamentosLote:PAGAMENTOSLOTE[1]:FILIAL)

    RpcClearEnv()
    RpcSetType(3)
    RpcSetEnv(xEmp,xFil,,,,GetEnvServer(),aTables)

    DbSelectArea("SE2")
    SE2->(DbSetOrder())

    For nX := 1 To Len(PostPagamentosLote:PAGAMENTOSLOTE)
        cFilant := PostPagamentosLote:PAGAMENTOSLOTE[nX]:FILIAL

        aadd( aTitulos , { "E2_FILIAL"  , PostPagamentosLote:PAGAMENTOSLOTE[nX]:FILIAL             , Nil })
        aadd( aTitulos , { "E2_PREFIXO" , PostPagamentosLote:PAGAMENTOSLOTE[nX]:PREFIXO            , Nil })
        aadd( aTitulos , { "E2_NUM"     , PostPagamentosLote:PAGAMENTOSLOTE[nX]:NUMTITULO          , Nil })
        aadd( aTitulos , { "E2_PARCELA" , PostPagamentosLote:PAGAMENTOSLOTE[nX]:PARCELA            , Nil })
        aadd( aTitulos , { "E2_TIPO"    , PostPagamentosLote:PAGAMENTOSLOTE[nX]:TIPO               , Nil })
        aadd( aTitulos , { "E2_NATUREZ" , PostPagamentosLote:PAGAMENTOSLOTE[nX]:NATUREZA           , Nil })
        aadd( aTitulos , { "E2_FORNECE" , PostPagamentosLote:PAGAMENTOSLOTE[nX]:FORNECEDOR         , Nil })
        aadd( aTitulos , { "E2_LOJA"    , PostPagamentosLote:PAGAMENTOSLOTE[nX]:LOJA               , Nil })
        aadd( aTitulos , { "E2_NOMFOR"  , PostPagamentosLote:PAGAMENTOSLOTE[nX]:NOMEFORNECE        , Nil })
        aadd( aTitulos , { "E2_EMISSAO" , Stod(PostPagamentosLote:PAGAMENTOSLOTE[nX]:DATAEMISSAO)  , Nil })
        aadd( aTitulos , { "E2_EMIS1"   , Stod(PostPagamentosLote:PAGAMENTOSLOTE[nX]:DATACONTABIL) , Nil })
        aadd( aTitulos , { "E2_VENCTO"  , Stod(PostPagamentosLote:PAGAMENTOSLOTE[nX]:VENCIMENTO)   , Nil })
        aadd( aTitulos , { "E2_VENCREA" , Stod(PostPagamentosLote:PAGAMENTOSLOTE[nX]:VENCREAL)     , Nil })
        aadd( aTitulos , { "E2_HIST"    , PostPagamentosLote:PAGAMENTOSLOTE[nX]:HISTORICO          , Nil })
        aadd( aTitulos , { "E2_VALOR"   , PostPagamentosLote:PAGAMENTOSLOTE[nX]:VALORTOTAL         , Nil }) 
        aadd( aTitulos , { "E2_ITEMD"   , PostPagamentosLote:PAGAMENTOSLOTE[nX]:ITEMCONTABIL       , Nil })        
        aadd( aTitulos , { "E2_CCUSTO"  , PostPagamentosLote:PAGAMENTOSLOTE[nX]:CENTROCUSTO        , Nil })
        aadd( aTitulos , { "E2_DATALIB" , dDataBase                                                , Nil }) // ISMAEL 09/11/2021

        If GetTitulo(PostPagamentosLote:PAGAMENTOSLOTE[nX]:FILIAL,PostPagamentosLote:PAGAMENTOSLOTE[nX]:PREFIXO,PostPagamentosLote:PAGAMENTOSLOTE[nX]:NUMTITULO,PostPagamentosLote:PAGAMENTOSLOTE[nX]:PARCELA,PostPagamentosLote:PAGAMENTOSLOTE[nX]:TIPO,PostPagamentosLote:PAGAMENTOSLOTE[nX]:FORNECEDOR,PostPagamentosLote:PAGAMENTOSLOTE[nX]:LOJA)
            nOption := 4
        Else 
            nOption := 3
        EndIf 

        MsExecAuto({|x,y,z| FINA050(x,y,z)},aTitulos,,nOption)  // 3 - Inclusao, 4 - Alteraï¿½ï¿½o, 5 - Exclusï¿½o
                    
        If lMsErroAuto
            //cError :=  MostraErro()
            aLogError := GetAutoGRLog()        
            cError := ""
            For nY := 1 To Len(aLogError)
                cError += aLogError[nY] +CRLF
            Next nY
            ::cRetPagamentos := "404 |Titulo-"+PostPagamentosLote:PAGAMENTOSLOTE[nX]:NUMTITULO+"|Prefixo-"+PostPagamentosLote:PAGAMENTOSLOTE[nX]:PREFIXO+"|Fornecedor-"+PostPagamentosLote:PAGAMENTOSLOTE[nX]:FORNECEDOR+"|Loja-"+PostPagamentosLote:PAGAMENTOSLOTE[nX]:LOJA+"| "+cError
            Return .T.                       
        Endif
        aTitulos := {}
    Next nX
    ::cRetPagamentos := "201 Registros Incluidos com Sucesso."
Return .T.

/*/{Protheus.doc} GetTitulo
Funï¿½ï¿½o que Busca o Titulo no Financeiro
@author Ricardo Tavares Ferreira
@since 29/08/2019
@version 12.1.17
@return .T.
@obs Ricardo Tavares - Construcao Inicial
/*/
//====================================================================================================
    Static Function GetTitulo(xFil,xPref,xTitulo,xParc,xTipo,xFornec,xLoja)
//====================================================================================================

	Local cQuery        := ""
	Local QbLinha	    := chr(13)+chr(10)
    Local nQtdReg       := 0
    Local cAliasRet     := GetNextAlias()
    Default xFil        := ""
    Default xPref       := ""
    Default xTitulo     := ""
    Default xParc       := ""
    Default xTipo       := ""
    Default xFornec     := ""
    Default xLoja       := ""

    cQuery := " SELECT E2_NUM TITULO "+QbLinha
    cQuery += " FROM "
    cQuery +=   RetSqlName("SE2") + " SE2 "+QbLinha
    cQuery += " WHERE E2_FILIAL = '"+xFil+"' "+QbLinha
    cQuery += " AND E2_PREFIXO  = '"+xPref+"' "+QbLinha
    cQuery += " AND E2_NUM      = '"+xTitulo+"' "+QbLinha
    cQuery += " AND E2_PARCELA  = '"+xParc+"' "+QbLinha
    cQuery += " AND E2_TIPO     = '"+xTipo+"' "+QbLinha
    cQuery += " AND E2_FORNECE  = '"+xFornec+"' "+QbLinha
    cQuery += " AND E2_LOJA     = '"+xLoja+"' "+QbLinha

    MemoWrite("C:/ricardo/GetTitulo.sql",cQuery)			     
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasRet,.F.,.T.)
		
	DbSelectArea(cAliasRet)
	(cAliasRet)->(DbGoTop())
	Count To nQtdReg
	(cAliasRet)->(DbGoTop())
		
	If nQtdReg > 0
        Return .T.
    EndIf
    (cAliasRet)->(DbCloseArea())
Return .F.
