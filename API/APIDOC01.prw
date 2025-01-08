#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'RESTFUL.CH'

/*/{Protheus.doc} APIDOC01
Webservice Responsavel por realizar a busca dos documentos no sistema.
@type method 
@author Ricardo Tavares Ferreira
@since 13/04/2021
@history 13/04/2021, Ricardo Tavares Ferreira, Constru��o Inicial.
@return object, Objeto do WebService.
@version 12.1.27
/*/
//=============================================================================================================================
    WSRestFul Documentos Description "Busca os documentos cadastrados no sistema"
//=============================================================================================================================

    WsData startindex   as Integer Optional
    WsData count        as Integer Optional 
    WsData Empresa      as String
    WsData Filial       as String
    WsData Filter       as String Optional
    WsData pk           as String Optional

    WsMethod GET Description "Busca os documentos cadastrados no sistema." WsSyntax "/Documentos"
End WSRestFul

/*/{Protheus.doc} GET - Documentos
Metodo GET que busca os dados .
@type method 
@author Ricardo Tavares Ferreira
@since 13/04/2021
@history 13/04/2021, Ricardo Tavares Ferreira, Constru��o Inicial.
@version 12.1.27
/*/
//=============================================================================================================================
    WsMethod GET WsReceive startindex, count, Empresa, Filial, Filter, pk WsRest Documentos
//=============================================================================================================================

    Local cFile := ""// VALORES RETORNADOS NA LEITURA
    Local oFile := FwFileReader():New("/dirdoc/co99/shared/�gua.pdf") // CAMINHO ABAIXO DO ROOTPATH

    // SE FOR POSS�VEL ABRIR O ARQUIVO, LEIA-O
    // SE N�O, EXIBA O ERRO DE ABERTURA
    If (oFile:Open())
        cFile := oFile:FullRead() // EFETUA A LEITURA DO ARQUIVO

        // RETORNA O ARQUIVO PARA DOWNLOAD
        //Self:SetHeader("Content-Disposition", "attachment; filename=�gua.pdf")
        //Self:SetResponse(cFile)

        Self:SetHeader("Content-Disposition", "inline; filename=\�gua.pdf\" )
        Self:SetContentType("application/pdf") 
        Self:SetResponse(cFile)
    Else
        SetRestFault(002, "can't load file") // GERA MENSAGEM DE ERRO CUSTOMIZADA

        Return .F.
    EndIf

    /*
        Local lRet := .F.
    Local cTexto := ""
    Local aFiles := {} // O array receber� os nomes dos arquivos e do diret�rio
    Local aSizes := {} // O array receber� os tamanhos dos arquivos e do diretorio
    
     ADir("/dirdoc/co99/shared/�gua.pdf", aFiles, aSizes)//Verifica o tamanho do arquivo, par�metro exigido na FRead.

    nHandle := fopen('/dirdoc/co99/shared/�gua.pdf' , FO_READWRITE + FO_SHARED )
    cString := ""
    FRead( nHandle, cString, aSizes[1] ) //Carrega na vari�vel cString, a string ASCII do arquivo.

    cTexto := Encode64(cString) //Converte o arquivo para BASE64

    fclose(nHandle)

    //Cria uma c�pia do arquivo utilizando cTexto em um processo inverso(Decode64) para validar a convers�o.    
    nHandle := fcreate("/dirdoc/co99/shared/�gua.pdf")
    FWrite(nHandle, Decode64(cTexto))
    fclose(nHandle)

    */
Return .T.
