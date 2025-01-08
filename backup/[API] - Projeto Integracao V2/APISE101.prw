#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'RESTFUL.CH'

/*/{Protheus.doc} APISE101
Webservice Responsavel por realizar a busca dos dados de Contas a Receber.
@type method 
@author Ricardo Tavares Ferreira
@since 01/05/2021
@history 01/05/2021, Ricardo Tavares Ferreira, Construção Inicial.
@return object, Web Service RestFull.
@version 12.1.27
/*/
//=============================================================================================================================
    WSRestFul ContasReceber Description "Busca os dados de Contas a Receber no sistema"
//=============================================================================================================================

    WsData startindex   as Integer Optional
    WsData count        as Integer Optional 
    WsData Empresa      as String
    WsData Filial       as String
    WsData Filter       as String Optional
    WsData pk           as String Optional

    WsMethod GET Description "Busca os dados de Contas a Receber no sistema." WsSyntax "/ContasReceber"
End WSRestFul

/*/{Protheus.doc} GET - ContasReceber
Metodo GET que busca os dados .
@type method 
@author Ricardo Tavares Ferreira
@since 01/05/2021
@history 01/05/2021, Ricardo Tavares Ferreira, Construção Inicial.
@return logical, Retorna 200 quando executado com sucesso e 500 quando executado com erro.
@version 12.1.27
/*/
//=============================================================================================================================
    WsMethod GET WsReceive startindex, count, Empresa, Filial, Filter, pk WsRest ContasReceber
//=============================================================================================================================

    Local oApiExc   := Nil
    Local cJson     := ""

    ::SetContentType("application/json")

    oApiExc := APIExeJS():New("oRestSE1","001",RetCodUsr(),"GET",::Empresa,::Filial,{"SE1"},::pk)

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
