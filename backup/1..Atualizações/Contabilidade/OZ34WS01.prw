#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'RESTFUL.CH'

/*/{Protheus.doc} OZ34WS01
Webservice Responsavel por Buscar os dados dos Lançamentos Contabeis Integrados.
@type method 
@author Ricardo Tavares Ferreira
@since 02/04/2021
@history 02/04/2021, Ricardo Tavares Ferreira, Construção Inicial.
@history 08/04/2021, Ricardo Tavares Ferreira, Tratamento no filtro pela pk do registro.
@return object, Objeto do WebService.
@version 12.1.27
/*/
//=============================================================================================================================
    WSRestFul OZ34WS01 Description "API de Integração Protheus para dados de Lançamentos Contabeis advindos de outros Sistemas."
//=============================================================================================================================
    
    WsData Empresa      as String
    WsData Filial       as String
    WsData Filtro       as String Optional

    WsMethod GET    Description "Busca os dados dos Lançamentos Contabeis Integrados."       WsSyntax "/LancContabil"
    WsMethod POST   Description "Cria um novo registro de Lançamentos Contabeis no sistema." WsSyntax "/LancContabil"
    WsMethod PUT    Description "Altera um registro de Lançamentos Contabeis no sistema."    WsSyntax "/LancContabil"
    WsMethod DELETE Description "Deleta um registro de Lançamentos Contabeis no sistema."    WsSyntax "/LancContabil"
End WSRestFul

/*/{Protheus.doc} DELETE - Lançamentos Contabeis
Metodo DELETE que Deleta os dados no sistema .
@type method 
@author Ricardo Tavares Ferreira
@since 03/12/2021
@history 03/12/2021, Ricardo Tavares Ferreira, Construção Inicial.
@return logical, Retorna 200 quando executado com sucesso e 500 quando executado com erro.
@version 12.1.27
/*/
//=============================================================================================================================
    WsMethod DELETE WsReceive Empresa, Filial WsRest OZ34WS01
//=============================================================================================================================

    Local cBody     := ""
    Local aEmpSM0   := {}
    Local nX        := 0
    Local lEmp      := .F. 
    Local lFil      := .F. 
    Local oJsRet    := Nil 
    Local cError    := ""
    Local xDoc      := ""
    Local xLote     := ""
    Local xSbLote   := ""
    Local xItens    := ""
    Local aDel      := ""
    Local nRecno    := 0
    Local lOK       := .T.
    Local cMsg      := ""
    Local cUpdate   := ""
    Local QbLinha	:= chr(13)+chr(10)
    Local aItens    := {}

    Private nStart  := 0

    aEmpSM0 := CarregaEmpresas()

    RpcClearEnv()
    RpcSetType(3)
    RpcSetEnv(::Empresa,::Filial,,,,GetEnvServer(),{"ZR7","ZR8"})

    If Len(aEmpSM0) > 0
        For nX := 1 To Len(aEmpSM0)
            If Alltrim(aEmpSM0[nX][1]) == Alltrim(::Empresa)
                lEmp := .T.
            EndIf

            If Alltrim(aEmpSM0[nX][2]) == Alltrim(::Filial)
                lFil := .T.
            EndIf
        Next nX
        If .not. lEmp .or. .not. lFil
            If .not. lEmp
                SetRestFault(500,EncodeUTF8("Empresa passada como paramentro é inválida ou não foi encontrada."))
                Return .F.
            EndIf
            If .not. lFil
                SetRestFault(500,EncodeUTF8("Filial passada como paramentro é inválida ou não foi encontrada."))
                Return .F.
            EndIf
        EndIf
    Else 
        SetRestFault(500,EncodeUTF8("Falha ao carregar as empresas da tabela SM0."))
        Return .F.
    EndIf

    cBody := ::GetContent()

    If Empty(cBody)
        SetRestFault(500,EncodeUTF8("Não é possivel excluir lancamentos sem o envio da requisição."))
        Return .F.
    EndIf 

    oJsRet  := JSonObject():New()
    cError  := oJsRet:fromJson(cBody)

    If .not. Empty(cError)
        SetRestFault(500,EncodeUTF8("Falha ao transformar o Json enviado em Objeto para ser utilizado."))
        Return .F.
    EndIf  

    aDel := oJsRet:GetNames()

    For nX := 1 To Len(aDel)
        If aDel[nX] == "ZR7_DOC"
            xDoc := oJsRet:GetJSonObject(aDel[nX])
        ElseIf aDel[nX] == "ZR7_LOTE"
            xLote := oJsRet:GetJSonObject(aDel[nX])
        ElseIf aDel[nX] == "ZR7_SBLOTE"
            xSbLote := oJsRet:GetJSonObject(aDel[nX])
        //ElseIf aDel[nX] == "ITENS"
        //    xItens := oJsRet:GetJSonObject(aDel[nX])
        EndIf 
    Next nX 

    cChave := Alltrim(cFilAnt)+Alltrim(xDoc)+Alltrim(xLote)+Alltrim(xSbLote)
    nRecno := RetRec(cChave,"ZR7","")

    If nRecno > 0
        If Empty(xItens)
            ZR7->(DbGoTO(nRecno))
            If Alltrim(ZR7->ZR7_STATUS) == "F"
                cMsg := "Este lote não pode ser excluido pois encontra se finalizado. Chave: "+cChave
                lOK := .F.
            Else
                cUpdate := " UPDATE " +RetSqlName("ZR7")+QbLinha
                cUpdate += " SET D_E_L_E_T_ = '*' "+QbLinha
                cUpdate += " WHERE "+QbLinha 
                cUpdate += " D_E_L_E_T_ = ' ' "+QbLinha
                cUpdate += " AND ZR7_FILIAL = '"+cFilAnt+"' "+QbLinha
                cUpdate += " AND ZR7_DOC = '"+xDoc+"' "+QbLinha
                cUpdate += " AND ZR7_LOTE = '"+xLote+"' "+QbLinha
                cUpdate += " AND ZR7_SBLOTE = '"+xSbLote+"' "+QbLinha

                If TCSQLExec(cUpdate) < 0
                    cMsg := "Erro ao Excluir os dados da tabela ZR7. Chave: "+cChave
    	            FwLogMsg("OZ34WS01", /*cTransactionId*/, "OZ34WS01", FunName(), "", "01", "Erro ao Deletar os Dados da Tabela ZR7 " + TCSQLError(), 0, (nStart - Seconds()), {})
                    lOK := .F.
                EndIf 

                cUpdate := " UPDATE " +RetSqlName("ZR8")+QbLinha
                cUpdate += " SET D_E_L_E_T_ = '*' "+QbLinha
                cUpdate += " WHERE "+QbLinha 
                cUpdate += " D_E_L_E_T_ = ' ' "+QbLinha
                cUpdate += " AND ZR8_FILIAL = '"+cFilAnt+"' "+QbLinha
                cUpdate += " AND ZR8_DOCZR7 = '"+xDoc+"' "+QbLinha
                cUpdate += " AND ZR8_LTZR7 = '"+xLote+"' "+QbLinha
                cUpdate += " AND ZR8_SBLZR7 = '"+xSbLote+"' "+QbLinha

                If TCSQLExec(cUpdate) < 0
                    cMsg := "Erro ao Excluir os dados da tabela ZR7. Chave: "+cChave
    	            FwLogMsg("OZ34WS01", /*cTransactionId*/, "OZ34WS01", FunName(), "", "01", "Erro ao alterar os Dados da Tabela ZR8 " + TCSQLError(), 0, (nStart - Seconds()), {})
                    lOK := .F.
                EndIf 
            EndIf 
        Else 
            aItens := StrTokArr(xItens,"/")

            For nX := 1 To Len(aItens)
                cUpdate := " UPDATE " +RetSqlName("ZR8")+QbLinha
                cUpdate += " SET D_E_L_E_T_ = '*' "+QbLinha
                cUpdate += " WHERE "+QbLinha 
                cUpdate += " D_E_L_E_T_ = ' ' "+QbLinha
                cUpdate += " AND ZR8_FILIAL = '"+cFilAnt+"' "+QbLinha
                cUpdate += " AND ZR8_DOCZR7 = '"+xDoc+"' "+QbLinha
                cUpdate += " AND ZR8_LTZR7 = '"+xLote+"' "+QbLinha
                cUpdate += " AND ZR8_SBLZR7 = '"+xSbLote+"' "+QbLinha
                cUpdate += " AND ZR8_ITEM = '"+aItens[nX]+"' "+QbLinha

                If TCSQLExec(cUpdate) < 0
                    cMsg := "Erro ao Excluir os dados da tabela ZR8. Chave: "+cChave+aItens[nX]
    	            FwLogMsg("OZ34WS01", /*cTransactionId*/, "OZ34WS01", FunName(), "", "01", "Erro ao alterar os Dados da Tabela ZR8 " + TCSQLError(), 0, (nStart - Seconds()), {})
                    lOK := .F.
                EndIf 
            Next nX 
        EndIf 
    Else 
        cMsg := "Lote não encontrado para ser deletado. Chave: "+cChave
        lOK := .F.
    EndIf

    If lOK 
        ::SetResponse('{"code": 200, "message":"Registro deletado com sucesso."}') 
    Else 
        SetRestFault(500,EncodeUTF8(cMsg))
        Return .F.
    EndIf 
Return .T.

/*/{Protheus.doc} PUT - Lançamentos Contabeis
Metodo PUT que Altera os dados no sistema .
@type method 
@author Ricardo Tavares Ferreira
@since 03/12/2021
@history 03/12/2021, Ricardo Tavares Ferreira, Construção Inicial.
@return logical, Retorna 200 quando executado com sucesso e 500 quando executado com erro.
@version 12.1.27
/*/
//=============================================================================================================================
    WsMethod PUT WsReceive Empresa, Filial WsRest OZ34WS01
//=============================================================================================================================

    Local cBody     := ""
    Local aEmpSM0   := {}
    Local nX        := 0
    Local nY        := 0
    Local nZ        := 0
    Local nW        := 0
    Local lEmp      := .F. 
    Local lFil      := .F. 
    Local oJsRet    := Nil 
    Local oJsLanc   := Nil 
    Local oJsItens  := Nil
    Local cError    := ""
    Local aCpoIte   := {}
    Local xValor    := Nil
    Local aZR7      := {}
    Local aZR8      := {}
    Local aLinZR8   := {}
    Local aLanc     := {}
    Local aDados    := {} 
    Local xFil      := ""
    Local xDoc      := ""
    Local xLote     := ""
    Local xSbLote   := ""
    Local cChave    := ""
    Local lOK       := .T.
    Local cMsg      := ""

    aEmpSM0 := CarregaEmpresas()

    RpcClearEnv()
    RpcSetType(3)
    RpcSetEnv(::Empresa,::Filial,,,,GetEnvServer(),{"ZR7","ZR8"})

    If Len(aEmpSM0) > 0
        For nX := 1 To Len(aEmpSM0)
            If Alltrim(aEmpSM0[nX][1]) == Alltrim(::Empresa)
                lEmp := .T.
            EndIf

            If Alltrim(aEmpSM0[nX][2]) == Alltrim(::Filial)
                lFil := .T.
            EndIf
        Next nX
        If .not. lEmp .or. .not. lFil
            If .not. lEmp
                SetRestFault(500,EncodeUTF8("Empresa passada como paramentro é inválida ou não foi encontrada."))
                Return .F.
            EndIf
            If .not. lFil
                SetRestFault(500,EncodeUTF8("Filial passada como paramentro é inválida ou não foi encontrada."))
                Return .F.
            EndIf
        EndIf
    Else 
        SetRestFault(500,EncodeUTF8("Falha ao carregar as empresas da tabela SM0."))
        Return .F.
    EndIf

    cBody := ::GetContent()

    If Empty(cBody)
        SetRestFault(500,EncodeUTF8("Não é possivel alterar lançamentos sem o envio da requisição."))
        Return .F.
    EndIf 

    oJsRet  := JSonObject():New()
    cError  := oJsRet:fromJson(cBody)

    If .not. Empty(cError)
        SetRestFault(500,EncodeUTF8("Falha ao transformar o Json enviado em Objeto para ser utilizado."))
        Return .F.
    EndIf  

    oJsLanc := oJsRet:GetJSonObject("lancamentos")

    For nX := 1 To Len(oJsLanc)
        aLanc := oJsLanc[nX]:GetNames()
        For nY := 1 To Len(aLanc)
            If aLanc[nY] <> "itens"
                If TamSX3(aLanc[nY])[3] == "D"
                    xValor := cTod(oJsLanc[nX]:GetJSonObject(aLanc[nY]))
                ElseIf TamSX3(aLanc[nY])[3] == "N"
                    xValor := Val(oJsLanc[nX]:GetJSonObject(aLanc[nY]))
                Else 
                    xValor := oJsLanc[nX]:GetJSonObject(aLanc[nY])
                EndIf 
                If aLanc[nY] == "ZR7_FILIAL"
                    xFil := xValor
                ElseIf aLanc[nY] == "ZR7_DOC"
                    xDoc := xValor
                ElseIf aLanc[nY] == "ZR7_LOTE"
                    xLote := xValor
                ElseIf aLanc[nY] == "ZR7_SBLOTE"
                    xSbLote := xValor
                EndIf 
                aadd(aZR7,{aLanc[nY] , xValor})
            Else 
                oJsItens := oJsLanc[nX]:GetJSonObject("itens")
                For nZ := 1 To Len(oJsItens)
                    aCpoIte := oJsItens[nZ]:GetNames()
                    For nW := 1 To Len(aCpoIte)
                        If TamSX3(aCpoIte[nW])[3] == "D"
                            xValor := cTod(oJsItens[nZ]:GetJSonObject(aCpoIte[nW]))
                        ElseIf TamSX3(aCpoIte[nW])[3] == "N"
                            xValor := Val(oJsItens[nZ]:GetJSonObject(aCpoIte[nW]))
                        Else 
                            xValor := oJsItens[nZ]:GetJSonObject(aCpoIte[nW])
                        EndIf 
                        aadd(aLinZR8,{aCpoIte[nW] , xValor})
                    Next nW
                    aadd(aZR8,aLinZR8)
                    aLinZR8 := {}
                Next nZ
            EndIf
        Next nY 
        aadd(aZR7,{"CHAVE",Alltrim(xFil)+Alltrim(xDoc)+Alltrim(xLote)+Alltrim(xSbLote)})
        aadd(aDados,{aZR7,aZR8})
        aZR7 := {}
        aZR8 := {}
    Next nX 

    For nX := 1 To Len(aDados)
        nRecno := RetRec(aDados[nX][1][6][2],"ZR7","")
        cChave := aDados[nX][1][6][2]
        If nRecno > 0
            ZR7->(DbGoto(nRecno))
            If Alltrim(ZR7->ZR7_STATUS) == "F"
                cMsg := "Este lote não pode ser alterado pois encontra se finalizado. Chave: "+cChave+" ."
                lOK := .F.
                Exit
            EndIf 
            RecLock("ZR7", .F.)
                For nZ := 1 To Len(aDados[nX][1])
                    If aDados[nX][1][nZ][1] <> "CHAVE"
                        &("ZR7->"+aDados[nX][1][nZ][1]) := aDados[nX][1][nZ][2]
                    EndIf
                Next nZ 
            ZR7->(MsUnlock())

            For nY := 1 To Len(aDados[nX][2])
                nRecno := RetRec(cChave,"ZR8",aDados[nX][2][nY][7][2])
                If nRecno > 0
                    ZR8->(DbGoto(nRecno))
                    RecLock("ZR8", .F.)
                        For nW := 1 To Len(aDados[nX][2][nY])
                            &("ZR8->"+aDados[nX][2][nY][nW][1]) := aDados[nX][2][nY][nW][2]
                        Next nW
                    ZR8->(MsUnlock())
                EndIf
            Next nY 
        Else
            cMsg := "O Lote contabil nao foi alterado porque não foi encontrado Chave: "+cChave+" ."
            lOK := .F.
            Exit
        EndIf 
    Next nX 
    
    If lOK 
        ::SetResponse('{"code": 200, "message":"Registro alterado com sucesso."}')
    Else 
       SetRestFault(500,EncodeUTF8(cMsg))
       Return .F.
    EndIf  

Return .T.

/*/{Protheus.doc} POST - Lançamentos Contabeis
Metodo POST que inclui os dados no sistema .
@type method 
@author Ricardo Tavares Ferreira
@since 03/12/2021
@history 03/12/2021, Ricardo Tavares Ferreira, Construção Inicial.
@return logical, Retorna 200 quando executado com sucesso e 500 quando executado com erro.
@version 12.1.27
/*/
//=============================================================================================================================
    WsMethod POST WsReceive Empresa, Filial WsRest OZ34WS01
//=============================================================================================================================

    Local cBody     := ""
    Local aEmpSM0   := {}
    Local nX        := 0
    Local nY        := 0
    Local nZ        := 0
    Local lEmp      := .F. 
    Local lFil      := .F. 
    Local oJsRet    := Nil 
    Local cError    := ""
    Local aCpo      := {}
    Local oCpoIte   := Nil 
    Local aCpoIte   := {}
    Local xValor    := Nil
    Local cNumDoc   := ""
    Local cNumLote  := ""
    Local aZR7      := {}
    Local aZR8      := {}
    Local aLinZR8   := {}

    aEmpSM0 := CarregaEmpresas()

    RpcClearEnv()
    RpcSetType(3)
    RpcSetEnv(::Empresa,::Filial,,,,GetEnvServer(),{"ZR7","ZR8"})

    If Len(aEmpSM0) > 0
        For nX := 1 To Len(aEmpSM0)
            If Alltrim(aEmpSM0[nX][1]) == Alltrim(::Empresa)
                lEmp := .T.
            EndIf

            If Alltrim(aEmpSM0[nX][2]) == Alltrim(::Filial)
                lFil := .T.
            EndIf
        Next nX
        If .not. lEmp .or. .not. lFil
            If .not. lEmp
                SetRestFault(500,EncodeUTF8("Empresa passada como paramentro é inválida ou não foi encontrada."))
                Return .F.
            EndIf
            If .not. lFil
                SetRestFault(500,EncodeUTF8("Filial passada como paramentro é inválida ou não foi encontrada."))
                Return .F.
            EndIf
        EndIf
    Else 
        SetRestFault(500,EncodeUTF8("Falha ao carregar as empresas da tabela SM0."))
        Return .F.
    EndIf

    cBody := ::GetContent()

    If Empty(cBody)
        SetRestFault(500,EncodeUTF8("Não é possivel incluir lancamentos sem o envio da requisição."))
        Return .F.
    EndIf 

    oJsRet  := JSonObject():New()
    cError  := oJsRet:fromJson(cBody)

    If .not. Empty(cError)
        SetRestFault(500,EncodeUTF8("Falha ao transformar o Json enviado em Objeto para ser utilizado."))
        Return .F.
    EndIf  

    aCpo := oJsRet:GetNames()

    aadd(aZR7,{"ZR7_FILIAL" , cFilAnt}) 
    aadd(aZR7,{"ZR7_STATUS" , "A"}) 
    aadd(aZR7,{"ZR7_SBLOTE" , "001"}) 

    For nX := 1 To Len(aCpo)
        If aCpo[nX] <> "itens"
            If TamSX3(aCpo[nX])[3] == "D"
                xValor := Ctod(oJsRet:GetJSonObject(aCpo[nX]))
            ElseIf TamSX3(aCpo[nX])[3] == "N"
                xValor := Val(oJsRet:GetJSonObject(aCpo[nX]))
            Else 
                xValor := Alltrim(oJsRet:GetJSonObject(aCpo[nX]))
            EndIf 
            aadd(aZR7,{aCpo[nX] , xValor})

            If aCpo[nX] == "ZR7_DOC"
                cNumDoc := xValor
            ElseIf aCpo[nX] == "ZR7_LOTE"
                cNumLote := xValor
            EndIf
        Else 
            oCpoIte := oJsRet:GetJSonObject("itens")
            For nY := 1  To Len(oCpoIte)
                aCpoIte := oCpoIte[nY]:GetNames()
                For nZ := 1 To Len(aCpoIte)
                    If TamSX3(aCpoIte[nZ])[3] == "D"
                        xValor := cTod(oCpoIte[nY]:GetJSonObject(aCpoIte[nZ]))
                    ElseIf TamSX3(aCpoIte[nZ])[3] == "N"
                        xValor := Val(oCpoIte[nY]:GetJSonObject(aCpoIte[nZ]))
                    Else 
                        xValor := Alltrim(oCpoIte[nY]:GetJSonObject(aCpoIte[nZ]))
                    EndIf 
                    aadd(aLinZR8,{aCpoIte[nZ] , xValor})
                Next nZ 
                aadd(aLinZR8,{"ZR8_DOCZR7",cNumDoc})
                aadd(aLinZR8,{"ZR8_LTZR7" ,cNumLote})
                aadd(aLinZR8,{"ZR8_SBLZR7","001"})
                aadd(aLinZR8,{"ZR8_FILIAL",cFilAnt})

                aadd(aZR8,aLinZR8)
                aLinZR8 := {}
            Next nY
        EndIf 
    Next nX 

    RecLock("ZR7", .T.)
        For nX := 1 To Len(aZR7)
            &("ZR7->"+aZR7[nX][1]) := aZR7[nX][2]
        Next nX 
    ZR7->(MsUnlock())

    For nX := 1 To Len(aZR8)
        RecLock("ZR8", .T.)
        For nY := 1 To Len(aZR8[nX])
            If aZR8[nX][nY][1] == "ZR8_LTZR7"
                &("ZR8->"+aZR8[nX][nY][1]) := cNumLote
            Else 
                &("ZR8->"+aZR8[nX][nY][1]) := aZR8[nX][nY][2]
            EndIf
        Next nY
        ZR8->(MsUnlock())
    Next nX 
    
    ::SetResponse('{"code": 201, "message":"Registro incluido com sucesso."}') 
Return .T.

/*/{Protheus.doc} GET - Lançamentos Contabeis
Metodo GET que busca os dados .
@type method 
@author Ricardo Tavares Ferreira
@since 03/12/2021
@history 03/12/2021, Ricardo Tavares Ferreira, Construção Inicial.
@return logical, Retorna 200 quando executado com sucesso e 500 quando executado com erro.
@version 12.1.27
/*/
//=============================================================================================================================
    WsMethod GET WsReceive Empresa, Filial, Filtro WsRest OZ34WS01
//=============================================================================================================================

    Local cJson     := ""
    Local aEmpSM0   := {}
    Local nX        := 0
    Local lEmp      := .F. 
    Local lFil      := .F. 
    Local cFiltro   := ""

    ::SetContentType("application/json")

    aEmpSM0 := CarregaEmpresas()

    If Len(aEmpSM0) > 0
        For nX := 1 To Len(aEmpSM0)
            If Alltrim(aEmpSM0[nX][1]) == Alltrim(::Empresa)
                lEmp := .T.
            EndIf

            If Alltrim(aEmpSM0[nX][2]) == Alltrim(::Filial)
                lFil := .T.
            EndIf
        Next nX
        If .not. lEmp .or. .not. lFil
            If .not. lEmp
                SetRestFault(500,EncodeUTF8("Empresa passada como paramentro é inválida ou não foi encontrada."))
                Return .F.
            EndIf
            If .not. lFil
                SetRestFault(500,EncodeUTF8("Filial passada como paramentro é inválida ou não foi encontrada."))
                Return .F.
            EndIf
        EndIf
    Else 
        SetRestFault(500,EncodeUTF8("Falha ao carregar as empresas da tabela SM0."))
        Return .F.
    EndIf

    If ValType(self:Filtro) == "U"
        cFiltro := ""
    Else 
        cFiltro := ::Filtro
    EndIf 
    cJson := BuscaJson(cFiltro)

    If .not. Empty(cJson)
        ::SetResponse(cJson) 
    Else 
        SetRestFault(500,EncodeUTF8("Falha ao Montar o Json de Retorno."))
        Return .F. 
    EndIf
Return .T.

/*/{Protheus.doc} RetRec
Retorna o Recno do Registro buscado.
@type function
@author Ricardo Tavares Ferreira
@since 04/12/2021
@return numeric, Retorna o Recno do registro.
@history 04/12/2021, Ricardo Tavares Ferreira , Construção Inicial.
/*/
//===============================================================================================================
    Static Function RetRec(cChave,cTab,cItem)
//===============================================================================================================

    Local nRecno    := 0 
    Local cQuery	:= ""
	Local QbLinha	:= chr(13)+chr(10)
	Local nQtdReg	:= 0
    Local cAliasREC := GetNextAlias()

    If cTab == "ZR7"
        cQuery := " SELECT ZR7.R_E_C_N_O_ IDREG "+QbLinha 
        cQuery += " FROM "
        cQuery +=   RetSqlName("ZR7") + " ZR7 "+QbLinha 
        cQuery += " WHERE ZR7.D_E_L_E_T_ = ' ' "+QbLinha
        cQuery += " AND RTRIM(LTRIM(ZR7_FILIAL))+RTRIM(LTRIM(ZR7_DOC))+RTRIM(LTRIM(ZR7_LOTE))+RTRIM(LTRIM(ZR7_SBLOTE)) = '"+cChave+"' "+QbLinha
    Else 
        cQuery := " SELECT ZR8.R_E_C_N_O_ IDREG "+QbLinha 
        cQuery += " FROM "
        cQuery +=   RetSqlName("ZR8") + " ZR8 "+QbLinha 
        cQuery += " WHERE ZR8.D_E_L_E_T_ = ' ' "+QbLinha 
        cQuery += " AND RTRIM(LTRIM(ZR8_FILIAL))+RTRIM(LTRIM(ZR8_DOCZR7))+RTRIM(LTRIM(ZR8_LTZR7))+RTRIM(LTRIM(ZR8_SBLZR7))+RTRIM(LTRIM(ZR8_ITEM)) = '"+cChave+cItem+"' "+QbLinha
    EndIf 

    MemoWrite("C:/ricardo/OZ34WS01_RetRec.sql",cQuery)			        
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasREC,.F.,.T.)
		
	DbSelectArea(cAliasREC)
	(cAliasREC)->(DbGoTop())
	Count TO nQtdReg
	(cAliasREC)->(DbGoTop())
		
	If nQtdReg <= 0
        (cAliasREC)->(DbCloseArea())
		Return nRecno
    Else 
        While ! (cAliasREC)->(Eof())
            nRecno := (cAliasREC)->IDREG
            (cAliasREC)->(DbSkip())
        End 
        (cAliasREC)->(DbCloseArea())
    EndIf
Return nRecno

/*/{Protheus.doc} BuscaJson
Retorna o Json buscado no banco.
@type function
@author Ricardo Tavares Ferreira
@since 31/03/2021
@return array, Array contendo todas as empresas ativas do sistema.
@history 31/03/2021, Ricardo Tavares Ferreira , Construção Inicial.
/*/
//===============================================================================================================
    Static Function BuscaJson(cFiltro)
//===============================================================================================================

    Local cJson     := ""
    Local cQuery	:= ""
	Local QbLinha	:= chr(13)+chr(10)
	Local nQtdReg	:= 0
    Local cAliasZR  := GetNextAlias()
    Local cChavePsq := ""
    Local oJsItens  := Nil 
    Local oJsConta  := Nil
    Local aItensCt  := {}
    Local oJsFull   := Nil 
    Local aLanc     := {}
    
    cQuery += " SELECT "+QbLinha 
    cQuery += " ZR7_FILIAL "+QbLinha 
    cQuery += " , ZR7_DOC "+QbLinha 
    cQuery += " , ZR7_LOTE "+QbLinha 
    cQuery += " , ZR7_SBLOTE "+QbLinha 
    cQuery += " , ZR7_EMISSA "+QbLinha
    cQuery += " , ZR7_STATUS "+QbLinha
    cQuery += " , ZR8_FILIAL "+QbLinha 
    cQuery += " , ZR8_ITEM "+QbLinha 
    cQuery += " , ZR8_MOEDLC "+QbLinha 
    cQuery += " , ZR8_TPLC"+QbLinha 
    cQuery += " , ZR8_CREDIT"+QbLinha 
    cQuery += " , ZR8_DEBITO"+QbLinha
    cQuery += " , ZR8_VALOR "+QbLinha
    cQuery += " , ZR8_HIST"+QbLinha 
    cQuery += " , ZR8_CCC"+QbLinha
    cQuery += " , ZR8_CCD "+QbLinha
    cQuery += " , ZR8_ITEMC"+QbLinha 
    cQuery += " , ZR8_ITEMD"+QbLinha 
    cQuery += " , ZR8_CLVLC"+QbLinha 
    cQuery += " , ZR8_CLVLD"+QbLinha 

    cQuery += " FROM "
	cQuery +=   RetSqlName("ZR7") + " ZR7 "+QbLinha 

    cQuery += " INNER JOIN "
	cQuery +=   RetSqlName("ZR8") + " ZR8 "+QbLinha  
    cQuery += " ON ZR7_FILIAL = ZR8_FILIAL"+QbLinha
    cQuery += " AND ZR7_DOC = ZR8_DOCZR7"+QbLinha 
    cQuery += " AND ZR7_LOTE = ZR8_LTZR7"+QbLinha
    cQuery += " AND ZR7_SBLOTE = ZR8_SBLZR7"+QbLinha 
    cQuery += " AND ZR8.D_E_L_E_T_ = ' '"+QbLinha 

    cQuery += " WHERE"+QbLinha 
    cQuery += " ZR7.D_E_L_E_T_ = ' '"+QbLinha 

    If .not. Empty(cFiltro)
        cQuery += " AND "+cFiltro+QbLinha 
    EndIf 

    cQuery += " ORDER BY ZR7_FILIAL, ZR7_DOC, ZR7_LOTE, ZR7_SBLOTE, ZR8_ITEM "+QbLinha 

    MemoWrite("C:/ricardo/OZ34WS01_BuscaJson.sql",cQuery)			        
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasZR,.F.,.T.)
		
	DbSelectArea(cAliasZR)
	(cAliasZR)->(DbGoTop())
	Count TO nQtdReg
	(cAliasZR)->(DbGoTop())
		
	If nQtdReg <= 0
        (cAliasZR)->(DbCloseArea())
		Return cJson
    Else 
        oJsFull := JSonObject():New()
        While ! (cAliasZR)->(Eof())
            cChavePsq := Alltrim((cAliasZR)->ZR7_FILIAL)+Alltrim((cAliasZR)->ZR7_DOC)+Alltrim((cAliasZR)->ZR7_LOTE)+Alltrim((cAliasZR)->ZR7_SBLOTE)

            oJsConta := JSonObject():New()

            oJsConta["ZR7_FILIAL"]  := Alltrim((cAliasZR)->ZR7_FILIAL)
            oJsConta["ZR7_DOC"]     := Alltrim((cAliasZR)->ZR7_DOC)
            oJsConta["ZR7_LOTE"]    := Alltrim((cAliasZR)->ZR7_LOTE)
            oJsConta["ZR7_SBLOTE"]  := Alltrim((cAliasZR)->ZR7_SBLOTE)
            oJsConta["ZR7_EMISSA"]  := Dtoc(Stod((cAliasZR)->ZR7_EMISSA))
            oJsConta["ZR7_STATUS"]  := Alltrim((cAliasZR)->ZR7_STATUS)

            While cChavePsq == Alltrim((cAliasZR)->ZR7_FILIAL)+Alltrim((cAliasZR)->ZR7_DOC)+Alltrim((cAliasZR)->ZR7_LOTE)+Alltrim((cAliasZR)->ZR7_SBLOTE) .and. ! (cAliasZR)->(Eof())
           	    
                oJsItens := JSonObject():New()

                oJsItens["ZR8_ITEM"]    := Alltrim((cAliasZR)->ZR8_ITEM)
                oJsItens["ZR8_MOEDLC"]  := Alltrim((cAliasZR)->ZR8_MOEDLC)
                oJsItens["ZR8_TPLC"]    := Alltrim((cAliasZR)->ZR8_TPLC)
                oJsItens["ZR8_CREDIT"]  := Alltrim((cAliasZR)->ZR8_CREDIT)
                oJsItens["ZR8_DEBITO"]  := Alltrim((cAliasZR)->ZR8_DEBITO)
                oJsItens["ZR8_VALOR"]   := Alltrim(Transform((cAliasZR)->ZR8_VALOR,Alltrim(X3Picture("CT2_VALOR"))))
                oJsItens["ZR8_HIST"]    := Alltrim((cAliasZR)->ZR8_HIST)
                oJsItens["ZR8_CCC"]     := Alltrim((cAliasZR)->ZR8_CCC)
                oJsItens["ZR8_CCD"]     := Alltrim((cAliasZR)->ZR8_CCD)
                oJsItens["ZR8_ITEMC"]   := Alltrim((cAliasZR)->ZR8_ITEMC)
                oJsItens["ZR8_ITEMD"]   := Alltrim((cAliasZR)->ZR8_ITEMD)
                oJsItens["ZR8_CLVLC"]   := Alltrim((cAliasZR)->ZR8_CLVLC)
                oJsItens["ZR8_CLVLD"]   := Alltrim((cAliasZR)->ZR8_CLVLD)

                aadd(aItensCt,oJsItens)

                oJsItens := Nil 
                (cAliasZR)->(DbSkip())
            End
            oJsConta["itens"]  := aItensCt
            aItensCt := {}

            aadd(aLanc,oJsConta)
            oJsConta := Nil 
        End 
        oJsFull["lancamentos"] := aLanc
        (cAliasZR)->(DbCloseArea())
    EndIf
    cJson := EncodeUtf8(oJsFull:ToJson())
Return cJson

/*/{Protheus.doc} CarregaEmpresas
Metodo responsável carregar e retornar um array contendo as empresas ativas no sistema.
@type function
@author Ricardo Tavares Ferreira
@since 31/03/2021
@return array, Array contendo todas as empresas ativas do sistema.
@history 31/03/2021, Ricardo Tavares Ferreira , Construção Inicial.
/*/
//===============================================================================================================
    Static Function CarregaEmpresas()
//===============================================================================================================

	Local aArea			:= SM0->(GetArea())
	Local aAux			:= {}
	Local aRetSM0		:= {}
	Local lFWLoadSM0	:= FindFunction("FWLoadSM0")
	Local lFWCodFilSM0 	:= FindFunction("FWCodFil")
	Local nX			:= 0
	
	If lFWLoadSM0
		aRetSM0	:= FWLoadSM0()
		For nX := 1 To Len(aRetSM0) 
			aAdd(aAux,aRetSM0[nX])
		Next nX
		aRetSM0 := aClone(aAux)
	Else
		DbSelectArea("SM0")
		SM0->(DbGoTop())
		While SM0->(!Eof())
			aAux := {SM0->M0_CODIGO,;
					 IIf(lFWCodFilSM0,FWGETCODFILIAL,SM0->M0_CODFIL),;
					 "",;
					 "",;
					 "",;
					 SM0->M0_NOME,;
					 SM0->M0_FILIAL}
			aAdd(aRetSM0,aClone(aAux))
			SM0->(DbSkip())
		End
	EndIf
	RestArea(aArea)
Return aRetSM0
