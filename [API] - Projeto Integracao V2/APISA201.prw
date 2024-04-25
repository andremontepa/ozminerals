#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'RESTFUL.CH'

/*/{Protheus.doc} APISA201
Webservice Responsavel por realizar a busca dos dados de Fornecedores.
@type method 
@author Ricardo Tavares Ferreira
@since 03/04/2021
@history 03/04/2021, Ricardo Tavares Ferreira, Construção Inicial.
@history 08/04/2021, Ricardo Tavares Ferreira, Tratamento no filtro pela pk do registro.
@return object, Objeto do WebService.
@version 12.1.27
/*/
//=============================================================================================================================
    WSRestFul Fornecedores Description "Busca os dados de Fornecedores no sistema"
//=============================================================================================================================

    WsData startindex   as Integer Optional
    WsData count        as Integer Optional 
    WsData Empresa      as String
    WsData Filial       as String
    WsData Filter       as String Optional
    WsData pk           as String Optional

    WsMethod GET Description "Busca os dados de Fornecedores no sistema." WsSyntax "/Fornecedores"
End WSRestFul

/*/{Protheus.doc} GET - Fornecedores
Metodo GET que busca os dados .
@type method 
@author Ricardo Tavares Ferreira
@since 03/04/2021
@history 03/04/2021, Ricardo Tavares Ferreira, Construção Inicial.
@history 04/04/2021, Ricardo Tavares Ferreira, Incluido o retorno content type  tipo json.
@history 08/04/2021, Ricardo Tavares Ferreira, Tratamento no filtro pela pk do registro.
@return logical, Retorna 200 quando executado com sucesso e 500 quando executado com erro.
@version 12.1.27
/*/
//=============================================================================================================================
    WsMethod GET WsReceive startindex, count, Empresa, Filial, Filter, pk WsRest Fornecedores
//=============================================================================================================================

    Local oApiExc   := Nil
    Local cJson     := ""

    ::SetContentType("application/json")

    oApiExc := APIExeJS():New("oRestSA2","001",RetCodUsr(),"GET",::Empresa,::Filial,{"SA2"},::pk)

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
