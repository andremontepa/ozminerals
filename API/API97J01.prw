#include "protheus.ch"
#include "topconn.ch"
#include "rwmake.ch"
#include 'parmtype.ch'

/*/{Protheus.doc} API97J01
JOB que busca os dados dos usuarios no arquivo SIGAPSS.spf e salva na tabela ZR3.
@type function 
@author Ricardo Tavares Ferreira
@since 29/03/2021
@history 29/03/2021, Ricardo Tavares Ferreira, Construção Inicial.
@version 12.1.27
/*/
//=============================================================================================================================
    User Function API97J01()
//=============================================================================================================================

    Local lRet := .F.

    If IsBlind()
        RpcSetType(3)
        RpcSetEnv("01","01",,,,GetEnvServer(),{"ZR3"})

        If PutDados()
            APIUtil():ConsoleLog("API97J01","Dados Executados com Sucesso ...",1)
        Else
            APIUtil():ConsoleLog("API97J01","Erro ao Gravar os dados na tabela ZR3 ...",3)
        EndIf 
        RpcClearEnv()
    Else 
        FWMsgRun(,{|oSay| lRet := PutDados()},"Cadastro de Usuário","Gerando Cadastro de Usuários ...")

        If lRet 
            MsgInfo("Tabela de usuarios (ZR3) populada com sucesso.","API97J01")
            APIUtil():ConsoleLog("API97J01","Tabela de usuarios (ZR3) populada com sucesso.",1)
        Else 
            Alert("Falha ao popular os dados da tabela de usuarios (ZR3).","API97J01")
        EndIf
    EndIf
 Return Nil

/*/{Protheus.doc} PutDados
Função que Grava os dados na tabela ZR3.
@type Function
@author Ricardo Tavares Ferreira - rtfconsulsystem@gmail.com
@since  11/12/2020
@version 12.1.25
@return logical, verifica se os dados de usuario foram gravados.
@history 11/12/2020, Ricardo Tavares Ferreira, Construção Inicial.
@history 13/03/2021, Ricardo Tavares Ferreira, Alteração realizada para incluir o tipo de usuario sendo C=Comprador,S=Solicitante.
@history 13/03/2021, Ricardo Tavares Ferreira, Adequação do Cabeçalho para tratamento do Protheus Doc.
@history 22/03/2021, Ricardo Tavares Ferreira, Inclusão do campo de codigo do comprador no cadastro de usuario.
@history 29/03/2021, Ricardo Tavares Ferreira, Aproveitamento da funcao para a versao 2 do projeto de API.
@history 28/04/2021, Ricardo Tavares Ferreira, Tratamento na busca das informações, Antes estava filtrando os usuarios que nao possuiam grupos.
/*/
//=============================================================================================================================
	Static Function PutDados()
//=============================================================================================================================

    Local aUsers     := {}
    Local nX         := 0
    Local aDados     := {}
    Local lChave     := .F.
    Local cTipoUsr   := "S"
    Local cCodComp   := ""
    Local lRet       := .T.
    Local cTime      := ""
    Local cHora      := ""
    Local cMinutos   := ""
    Local cSegundos  := ""

    cTime            := TIME()
    cHora            := SUBSTR(cTime, 1, 2)
    cMinutos         := SUBSTR(cTime, 4, 2)
    cSegundos        := SUBSTR(cTime, 7, 2)

    If DeletaTudo()
        If MPDicInDB()
            aUsers := FWSFALLUSERS()

            For nX := 1 To Len(aUsers)
                Aadd(aDados,{Alltrim(aUsers[nX][2]),Alltrim(aUsers[nX][3]),Alltrim(aUsers[nX][4]),Alltrim(aUsers[nX][5])})
            Next nX 
        Else 
            aUsers := AllUsers(.F.,.F.)

            For nX := 1 To Len(aUsers)
                AADD(aDados,{Alltrim(aUsers[nX][1][1]),Alltrim(aUsers[nX][1][2]),Alltrim(aUsers[nX][1][4]),Alltrim(aUsers[nX][1][14])})
            Next nX
        EndIf

        DbSelectArea("ZR3")
        ZR3->(DbSetOrder(1))
        ZR3->(DbCloseArea())

        If Len(aDados) > 0
            DbSelectArea("ZR3")
            ZR3->(DbSetOrder(1))

            For nX := 1 To Len(aDados)
                APIUtil():ConsoleLog("API97J01|PutDados","Processando "+cValToChar(nX)+" de "+cValToChar(Len(aDados))+" ...",1)      
                lChave := ZR3->(DbSeek(FWXFilial("ZR3")+Alltrim(aDados[nX][1])))                
                cCodComp := GetComprador(Alltrim(aDados[nX][1]))
            
                If .not. Empty(cCodComp)
                    cTipoUsr := "C"
                EndIf
                If lChave 
                    RecLock("ZR3",.F.)
                    APIUtil():ConsoleLog("API97J01|PutDados","Registro ...: "+Alltrim(aDados[nX][1])+" / "+Alltrim(aDados[nX][2])+" - Alterado ...",1)
                Else
                    RecLock("ZR3",.T.)
                    APIUtil():ConsoleLog("API97J01|PutDados","Registro ...: "+Alltrim(aDados[nX][1])+" / "+Alltrim(aDados[nX][2])+" - Incluido ...",1)
                EndIf
                    ZR3->ZR3_FILIAL := FWXFilial("ZR3")
                    ZR3->ZR3_COD    := Alltrim(aDados[nX][1])
                    ZR3->ZR3_LOGIN  := Alltrim(aDados[nX][2])
                    ZR3->ZR3_NOME   := Alltrim(aDados[nX][3])
                    ZR3->ZR3_EMAIL  := Alltrim(aDados[nX][4])
                    ZR3->ZR3_TIPO   := cTipoUsr  
                    ZR3->ZR3_CODCOM := cCodComp
                    ZR3->ZR3_XDTALT := Date()
                    ZR3->ZR3_XHRALT := cHora+cMinutos+cSegundos
                ZR3->(MsUnlock())
                cTipoUsr := "S"
            Next nX
        Else
            APIUtil():ConsoleLog("API97J01|PutDados","Nao foi carregar os dados do arquivo SIGAPSS.spf ...",3)
            lRet := .F.
        EndIf
    Else 
        lRet := .F.
    EndIf
Return lRet

/*/{Protheus.doc} GetComprador
Verifica se o usuario passado como parametro é um comprador.
@type Function
@author Ricardo Tavares Ferreira - rtfconsulsystem@gmail.com
@since  13/03/2021
@version 12.1.25
@return character, Retorna o codigo do comprador.
@param cCodUser	, character	, Código de Usuario cadastrado no protheus.
@history 13/03/2021, Ricardo Tavares Ferreira, Construção Inicial.
@history 22/03/2021, Ricardo Tavares Ferreira, Mudança no retorno da função retornando o codigo do comprador.
@history 29/03/2021, Ricardo Tavares Ferreira, Aproveitamento da funcao para a versao 2 do projeto de API.
@history 12/04/2021, Ricardo Tavares Ferreira, Tratamento no retorno da tabela conforme a empresa posicionada.
/*/
//=============================================================================================================================
	Static Function GetComprador(cCodUser)
//=============================================================================================================================

    Local oQuery    := Nil
    Local cCodQry 	:= "SY1"
    Local aRet      := {}
    Local cCodComp  := ""
    Local nX        := 0
    Local nY        := 0

    Default cCodUser := ""

    oQuery := APIExQry():New(.T.)
    oQuery:SetFormula(cCodQry)
    oQuery:SetHasHead(.F.)
    oQuery:AddFilter("TAB1", RetSqlName("SY1"))

    If .not. oQuery:BuildQuery()
        APIUtil():ConsoleLog("API97J01|GetComprador","Nao foi possivel carregar a query passada como parametro "+cCodQry,3)
        Return cCodComp
    Else 
        oQuery:oPrepS:SetString(01,cCodUser)
        oQuery:oPrepS:SetString(02,FWXFilial(cCodQry))

        aRet := oQuery:ExecPreparedSt()
        If Len(aRet) > 0
            For nX := 1 To Len(aRet)
                For nY := 1 To Len(aRet[nX])
                    If Alltrim(aRet[nX][nY][1]) == "Y1_COD"
                        cCodComp := Alltrim(aRet[nX][nY][2])
                    EndIf
                Next nY
            Next nX
        Else 
            APIUtil():ConsoleLog("API97J01|GetComprador","Registro nao encontrado pela query executada. "+cCodQry,3)
        EndIf
    EndIf
    FWFreeObj(oQuery)
Return cCodComp

/*/{Protheus.doc} DeletaTudo
Deleta os Dados Antes de Inserir novamente
@type Function
@author Ricardo Tavares Ferreira - rtfconsulsystem@gmail.com
@since  13/03/2021
@version 12.1.25
@history 13/03/2021, Ricardo Tavares Ferreira, Construção Inicial.
@history 29/03/2021, Ricardo Tavares Ferreira, Aproveitamento da funcao para a versao 2 do projeto de API.
@history 12/04/2021, Ricardo Tavares Ferreira, Tratamento no retorno da tabela conforme a empresa posicionada.
/*/
//=============================================================================================================================
	Static Function DeletaTudo()
//=============================================================================================================================

    Local oQuery    := Nil
    Local cCodQry 	:= "001"
    Local lRet      := .T.

    oQuery := APIExQry():New()
    oQuery:SetFormula(cCodQry)
    oQuery:AddFilter("TAB1", RetSqlName("ZR3"))

    If .not. oQuery:ExecTCSQL()
        APIUtil():ConsoleLog("API97J01|DeletaTudo","Falha ao Executar o DELETE na tabela ZR3.",3)
        lRet := .F.
    EndIf
    FWFreeObj(oQuery)
Return lRet
