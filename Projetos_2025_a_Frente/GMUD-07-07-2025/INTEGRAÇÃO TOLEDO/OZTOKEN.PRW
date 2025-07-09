/*/{Protheus.doc} tstRestBear
 
@author Caio.Lima
@since 17/02/2023
/*/
User Function tstRestBear()
    Local oRest := nil
    Local cLogin:= "admin"
    Local cPass := "****"
    Local cUrlBase := "http://10.106.10.24:8400/rest"
    Local jBToken := jsonObject():New()
 
    // Definindo a URL de autenticação e a URL da API com Bearer
    cUrlToken := "/api/oauth2/v1/token?grant_type=password&username=user1&password=1234"
    cUrlApi := "/shiftf6/"
 
    // Criando o objeto FWRest
    oRest := FWRest():new(cUrlBase)
 
    // Definindo os parâmetros de cabeçalho para a autenticação
    aHeaders := {}
    Aadd(aHeaders,  "Accept: application/json" )
 
    // Fazendo a requisição POST para obter o access_token
    oRest:setPath(cUrlToken)
    lRet := oRest:Post(aHeaders)
 
    // Verificando se a requisição foi bem-sucedida
    IF lRet
        //------------------------------------------------
        // Retorno do WS
        //------------------------------------------------
        jBToken:FromJson(oRest:GetResult())
 
        // Extraindo o access_token da resposta JSON
        cAccessToken := jBToken["access_token"]
 
        IF !Empty(cAccessToken)
            // Definindo os cabeçalhos para autenticação Bearer
            aHeaders := {}
            Aadd(aHeaders,  "Accept: application/json" )
            Aadd(aHeaders,  "Authorization: Bearer " + cAccessToken )
 
            // Fazendo a requisição GET para a API que precisa de autenticação
            oRest:setPath(cUrlApi)
            lRet := oRest:Get(aHeaders)        
 
            // Exibindo a resposta da API
            IF lRet
                ConOut("Resposta da API: " + oRest:GetResult())
            ELSE
                ConOut("Erro ao acessar a API com Bearer Token." + oRest:GetLastError())
            ENDIF
        ELSE
            ConOut("Erro: O access_token não foi encontrado na resposta.")
        ENDIF
    ELSE
        //------------------------------------------------
        // Pegar o erro
        //------------------------------------------------
        ConOut(oRest:GetLastError())
    ENDIF
 
Return
