#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'RESTFUL.CH'

/*/{Protheus.doc} APISB201
Webservice Responsavel por realizar a busca dos dados de Saldo em Estoque (Atual).
@type method 
@author Ricardo Tavares Ferreira
@since 12/04/2021
@history 12/04/2021, Ricardo Tavares Ferreira, Construção Inicial.
@return object, Objeto do WebService.
@version 12.1.27
/*/
//=============================================================================================================================
    WSRestFul SaldoEstoque Description "Busca os dados de Saldo em Estoque (Atual) no sistema"
//=============================================================================================================================

    WsData startindex   as Integer Optional
    WsData count        as Integer Optional 
    WsData Empresa      as String
    WsData Filial       as String
    WsData Filter       as String Optional
    WsData pk           as String Optional

    WsMethod GET Description "Busca os dados de Saldo em Estoque (Atual) no sistema." WsSyntax "/SaldoEstoque"
End WSRestFul

/*/{Protheus.doc} GET - SaldoEstoque
Metodo GET que busca os dados .
@type method 
@author Ricardo Tavares Ferreira
@since 12/04/2021
@history 12/04/2021, Ricardo Tavares Ferreira, Construção Inicial.
@return logical, Retorna 200 quando executado com sucesso e 500 quando executado com erro.
@version 12.1.27
/*/
//=============================================================================================================================
    WsMethod GET WsReceive startindex, count, Empresa, Filial, Filter, pk WsRest SaldoEstoque
//=============================================================================================================================

    Local oApiExc   := Nil
    Local cJson     := ""

    ::SetContentType("application/json")

    oApiExc := APIExeJS():New("oRestSB2","001",RetCodUsr(),"GET",::Empresa,::Filial,{"SB2"},::pk)

    If .not. oApiExc:Valida()
        SetRestFault(oApiExc:nCode,oApiExc:cMsgRet)
        FWFreeObj(oApiExc)
        Return .F. 
    EndIf 
    cJson := oApiExc:GetJsonQuery(::count,::startindex,"resources",::Filter,.F.,"")
    If .not. Empty(cJson)
        ::SetResponse(cJson) 
    Else 
        SetRestFault(oApiExc:nCode,oApiExc:cMsgRet)
        FWFreeObj(oApiExc)
        Return .F. 
    EndIf
    FWFreeObj(oApiExc)
Return .T.
