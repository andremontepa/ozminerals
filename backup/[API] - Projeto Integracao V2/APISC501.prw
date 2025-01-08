#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'RESTFUL.CH'

/*/{Protheus.doc} APISC501
Webservice Responsavel por realizar a busca dos dados do Pedido de Venda.
@type method 
@author Ricardo Tavares Ferreira
@since 10/04/2021
@history 10/04/2021, Ricardo Tavares Ferreira, Construção Inicial.
@return object, Web Service RestFull.
@version 12.1.27
/*/
//=============================================================================================================================
    WSRestFul PedVendas Description "Busca os dados de Pedidos de Venda no sistema"
//=============================================================================================================================

    WsData startindex   as Integer Optional
    WsData count        as Integer Optional 
    WsData Empresa      as String
    WsData Filial       as String
    WsData Filter       as String Optional
    WsData pk           as String Optional

    WsMethod GET Description "Busca os dados de Pedidos de Venda no sistema." WsSyntax "/PedVendas"
End WSRestFul

/*/{Protheus.doc} GET - Pedidos de Venda
Metodo GET que busca os dados.
@type method 
@author Ricardo Tavares Ferreira
@since 10/04/2021
@history 10/04/2021, Ricardo Tavares Ferreira, Construção Inicial.
@return logical, Retorna 200 quando executado com sucesso e 500 quando executado com erro.
@version 12.1.27
/*/
//=============================================================================================================================
    WsMethod GET WsReceive startindex, count, Empresa, Filial, Filter, pk WsRest PedVendas
//=============================================================================================================================

    Local oApiExc       := Nil
    Local cJson         := ""
    Local cInnerJoin    := ""
    Local QbLinha	    := chr(13)+chr(10)

    ::SetContentType("application/json")

    cInnerJoin := " INNER JOIN "
    cInnerJoin +=   RetSqlName("SC6") + " SC6 "+QbLinha
    cInnerJoin += " ON SC5.C5_FILIAL = SC6.C6_FILIAL "+QbLinha
    cInnerJoin += " AND SC5.C5_NUM = SC6.C6_NUM "+QbLinha
    cInnerJoin += " AND SC5.C5_CLIENTE = SC6.C6_CLI "+QbLinha
    cInnerJoin += " AND SC5.C5_LOJACLI = SC6.C6_LOJA "+QbLinha
    cInnerJoin += " AND SC5.C5_NOTA = SC6.C6_NOTA "+QbLinha
    cInnerJoin += " AND SC5.C5_SERIE = SC6.C6_SERIE "+QbLinha
    cInnerJoin += " AND SC6.D_E_L_E_T_ = ' ' "+QbLinha

    oApiExc := APIExeJS():New("oRestSC5","001",RetCodUsr(),"GET",::Empresa,::Filial,{"SC5","SC6"},::pk)

    If .not. oApiExc:Valida()
        SetRestFault(oApiExc:nCode,oApiExc:cMsgRet)
        FWFreeObj(oApiExc)
        Return .F. 
    EndIf 
    cJson := oApiExc:GetJsonQuery(::count,::startindex,"resources",::Filter,.T.,cInnerJoin)
    If .not. Empty(cJson)
        ::SetResponse(cJson) 
    Else 
        SetRestFault(oApiExc:nCode,oApiExc:cMsgRet)
        FWFreeObj(oApiExc)
        Return .F. 
    EndIf
    FWFreeObj(oApiExc)
Return .T.
