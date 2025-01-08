#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'RESTFUL.CH'

/*/{Protheus.doc} APISC701
Webservice Responsavel por realizar a busca dos dados de Pedidos de Compra.
@type method 
@author Ricardo Tavares Ferreira
@since 03/04/2021
@history 03/04/2021, Ricardo Tavares Ferreira, Construção Inicial.
@history 08/04/2021, Ricardo Tavares Ferreira, Tratamento no filtro pela pk do registro.
@return object, Objeto do WebService.
@version 12.1.27
/*/
//=============================================================================================================================
    WSRestFul PedCompras Description "Busca os dados de Pedidos de Compra no sistema"
//=============================================================================================================================

    WsData startindex   as Integer Optional
    WsData count        as Integer Optional 
    WsData Empresa      as String
    WsData Filial       as String
    WsData Filter       as String Optional
    WsData pk           as String Optional

    WsMethod GET    Description "Busca os dados de Pedidos de Compra no sistema." WsSyntax "/PedCompras"
    WsMethod POST   Description "Cria um novo regiStro de Pedido de Compras no sistema." WsSyntax "/PedCompras"
    WsMethod PUT    Description "Altera um regitro de Pedido de Compras no sistema." WsSyntax "/PedCompras"
    WsMethod DELETE Description "Deleta um regitro de Pedido de Compras no sistema." WsSyntax "/PedCompras"
End WSRestFul

/*/{Protheus.doc} DELETE - PedCompras
Metodo DELETE que apaga os registros da base .
@type method 
@author Ricardo Tavares Ferreira
@since 03/04/2021
@history 03/04/2021, Ricardo Tavares Ferreira, Construção Inicial.
@return logical, Retorna verdadeiro para a apresentação dos dados.
@version 12.1.27
/*/
//=============================================================================================================================
    WsMethod DELETE WsReceive Empresa, Filial WsRest PedCompras
//=============================================================================================================================

    Local cBody   := ""
    Local oApiExc := Nil
    Local cJson   := ""

    ::SetContentType("application/json")

    oApiExc := APIExeJS():New("oRestSC7","001",RetCodUsr(),"DELETE",::Empresa,::Filial,{"SC7"})

    If .not. oApiExc:Valida()
        SetRestFault(oApiExc:nCode,oApiExc:cMsgRet)
        FWFreeObj(oApiExc)
        Return .F. 
    EndIf

    cBody := ::GetContent()
    cJson := oApiExc:ProcessaOperacaoSC7(cBody)

    If .not. Empty(cJson)
        ::SetResponse(cJson) 
    Else 
        SetRestFault(oApiExc:nCode,oApiExc:cMsgRet)
        FWFreeObj(oApiExc)
        Return .F. 
    EndIf
    FWFreeObj(oApiExc)
Return .T.

/*/{Protheus.doc} PUT - PedCompras
Metodo PUT que busca os dados .
@type method 
@author Ricardo Tavares Ferreira
@since 03/04/2021
@history 03/04/2021, Ricardo Tavares Ferreira, Construção Inicial.
@return logical, Retorna verdadeiro para a apresentação dos dados.
@version 12.1.27
/*/
//=============================================================================================================================
    WsMethod PUT WsReceive Empresa, Filial WsRest PedCompras
//=============================================================================================================================

    Local cBody   := ""
    Local oApiExc := Nil
    Local cJson   := ""

    ::SetContentType("application/json")

    oApiExc := APIExeJS():New("oRestSC7","001",RetCodUsr(),"PUT",::Empresa,::Filial,{"SC7"})

    If .not. oApiExc:Valida()
        SetRestFault(oApiExc:nCode,oApiExc:cMsgRet)
        FWFreeObj(oApiExc)
        Return .F. 
    EndIf

    cBody := ::GetContent()
    cJson := oApiExc:ProcessaOperacaoSC7(cBody)

    If .not. Empty(cJson)
        ::SetResponse(cJson) 
    Else 
        SetRestFault(oApiExc:nCode,oApiExc:cMsgRet)
        FWFreeObj(oApiExc)
        Return .F. 
    EndIf
    FWFreeObj(oApiExc)
Return .T.

/*/{Protheus.doc} GET - PedCompras
Metodo GET que busca os dados .
@type method 
@author Ricardo Tavares Ferreira
@since 03/04/2021
@history 03/04/2021, Ricardo Tavares Ferreira, Construção Inicial.
@return logical, Retorna verdadeiro para a apresentação dos dados.
@version 12.1.27
/*/
//=============================================================================================================================
    WsMethod POST WsReceive Empresa, Filial WsRest PedCompras
//=============================================================================================================================

    Local cBody   := ""
    Local oApiExc := Nil
    Local cJson   := ""

    ::SetContentType("application/json")

    oApiExc := APIExeJS():New("oRestSC7","001",RetCodUsr(),"POST",::Empresa,::Filial,{"SC7"})

    If .not. oApiExc:Valida()
        SetRestFault(oApiExc:nCode,oApiExc:cMsgRet)
        FWFreeObj(oApiExc)
        Return .F. 
    EndIf

    cBody := ::GetContent()
    cJson := oApiExc:ProcessaOperacaoSC7(cBody)

    If .not. Empty(cJson)
        ::SetResponse(cJson) 
    Else 
        SetRestFault(oApiExc:nCode,oApiExc:cMsgRet)
        FWFreeObj(oApiExc)
        Return .F. 
    EndIf
    FWFreeObj(oApiExc)
Return .T.

/*/{Protheus.doc} GET - PedCompras
Metodo GET que busca os dados .
@type method 
@author Ricardo Tavares Ferreira
@since 03/04/2021
@history 03/04/2021, Ricardo Tavares Ferreira, Construção Inicial.
@history 08/04/2021, Ricardo Tavares Ferreira, Tratamento no filtro pela pk do registro.
@return logical, Retorna verdadeiro para a apresentação dos dados.
@version 12.1.27
/*/
//=============================================================================================================================
    WsMethod GET WsReceive startindex, count, Empresa, Filial, Filter, pk WsRest PedCompras
//=============================================================================================================================

    Local oApiExc   := Nil
    Local cJson     := ""

    oApiExc := APIExeJS():New("oRestSC7","001",RetCodUsr(),"GET",::Empresa,::Filial,{"SC7"},::pk)

    ::SetContentType("application/json")
    
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
