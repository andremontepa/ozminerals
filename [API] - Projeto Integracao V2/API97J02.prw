#include "protheus.ch"
#include "topconn.ch"
#include "rwmake.ch"
#include 'parmtype.ch'

/*/{Protheus.doc} API97J02
JOB que busca os dados das Filiais cadastradas no Sistema.
@type function 
@author Ricardo Tavares Ferreira
@since 30/03/2021
@history 30/03/2021, Ricardo Tavares Ferreira, Consstrução Inicial.
@version 12.1.27
/*/
//=============================================================================================================================
    User Function API97J02()
//=============================================================================================================================
    
    Local lRet := .F.

    If IsBlind()
        RpcSetType(3)
        RpcSetEnv("01","01",,,,GetEnvServer(),{"ZR2"})

        If PutDados()
            APIUtil():ConsoleLog("API97J02","Dados Executados com Sucesso ...",1)
        Else
            APIUtil():ConsoleLog("API97J02","Erro ao Gravar os dados na tabela ZR2 ...",3)
        EndIf 
        RpcClearEnv()
    Else 
        FWMsgRun(,{|oSay| lRet := PutDados()},"Cadastro de Filiais","Gerando Cadastro de Filiais ...")

        If lRet 
            MsgInfo("Tabela de Filiais (ZR2) populada com sucesso.","API97J02")
            APIUtil():ConsoleLog("API97J02","Tabela de Filiais (ZR2) populada com sucesso.",1)
        Else 
            Alert("Falha ao popular os dados da tabela de Filiais (ZR2).","API97J02")
        EndIf
    EndIf
 Return

/*/{Protheus.doc} PutDados
Função que Grava os dados na tabela ZR2.
@type Function
@author Ricardo Tavares Ferreira - rtfconsulsystem@gmail.com
@since  11/12/2020
@version 12.1.25
@return logical, verifica se os dados de usuario foram gravados.
@history 11/12/2020, Ricardo Tavares Ferreira, Construção Inicial.
@history 13/03/2021, Ricardo Tavares Ferreira, Adequação do Cabeçalho para tratamento do Protheus Doc.
@history 30/03/2021, Ricardo Tavares Ferreira, Aproveitamento da funcao para a versao 2 do projeto de API.
/*/
//====================================================================================================
    Static Function PutDados()
//====================================================================================================

    Local aArea     := GetArea()
    Local aAreaSM0  := SM0->(GetArea())
    Local nX        := 0
    Local aDados    := {}
    Local lRet      := .T.

    DBSelectArea("SM0")
    SM0->(DbSetOrder(1))
    SM0->(DBGoTop())

    While ! SM0->(EoF())
        Aadd(aDados,{;
        Alltrim(SM0->M0_CODIGO),;
        Alltrim(SM0->M0_NOME),;
        Alltrim(SM0->M0_CODFIL),;
        Alltrim(SM0->M0_FILIAL),;
        Alltrim(SM0->M0_CGC),;
        Alltrim(SM0->M0_TEL),;
        Alltrim(SM0->M0_INSC),;
        Alltrim(SM0->M0_INSCM),;
        Alltrim(SM0->M0_ENDCOB),;
        Alltrim(SM0->M0_COMPCOB),;
        Alltrim(SM0->M0_CEPCOB),;
        Alltrim(SM0->M0_BAIRCOB),;
        Alltrim(SM0->M0_CODMUN),;
        Alltrim(SM0->M0_CIDCOB),;
        Alltrim(SM0->M0_ESTCOB),;
        Alltrim(SM0->M0_CNAE),;
        Alltrim(SM0->M0_DSCCNA),;
        Alltrim(SM0->M0_NATJUR)})
        SM0->(DbSkip())
    End

    DbSelectArea("ZR2")
    ZR2->(DbSetOrder(1))
    ZR2->(DbCloseArea())

    If Len(aDados) > 0
        DbSelectArea("ZR2")
        ZR2->(DbSetOrder(1))

        If DeletaTudo()
            For nX := 1 To Len(aDados)
                APIUtil():ConsoleLog("API97J02","Processando "+cValToChar(nX)+" de "+cValToChar(Len(aDados))+" ...",1)

                If ZR2->(DbSeek(FWXFilial("ZR2")+Alltrim(aDados[nX][1])+Alltrim(aDados[nX][3]))) 
                    RecLock("ZR2",.F.)
                    APIUtil():ConsoleLog("API97J02","Registro ...: "+Alltrim(aDados[nX][3])+" / "+Alltrim(aDados[nX][4])+" - Alterado ...",1)
                Else
                    RecLock("ZR2",.T.)
                    APIUtil():ConsoleLog("API97J02","Registro ...: "+Alltrim(aDados[nX][3])+" / "+Alltrim(aDados[nX][4])+" - Incluido ...",1)
                EndIf
                    ZR2->ZR2_FILIAL := FWXFilial("ZR2")
                    ZR2->ZR2_CODEMP := Upper(Alltrim(aDados[nX][1]) ) // SM0->M0_CODIGO
                    ZR2->ZR2_NOMEMP := Upper(Alltrim(aDados[nX][2]) ) // SM0->M0_NOME
                    ZR2->ZR2_CODFIL := Upper(Alltrim(aDados[nX][3]) ) // SM0->M0_CODFIL
                    ZR2->ZR2_NOMFIL := Upper(Alltrim(aDados[nX][4]) ) // SM0->M0_FILIAL
                    ZR2->ZR2_CGC    := Upper(Alltrim(aDados[nX][5]) ) // SM0->M0_CGC
                    ZR2->ZR2_TEL    := Upper(Alltrim(aDados[nX][6]) ) // SM0->M0_TEL
                    ZR2->ZR2_INSCE  := Upper(Alltrim(aDados[nX][7]) ) // SM0->M0_INSC
                    ZR2->ZR2_INSCM  := Upper(Alltrim(aDados[nX][8]) ) // SM0->M0_INSCM
                    ZR2->ZR2_ENDERE := Upper(Alltrim(aDados[nX][9]) ) // SM0->M0_ENDCOB
                    ZR2->ZR2_CPENDE := Upper(Alltrim(aDados[nX][10])) // SM0->M0_COMPCOB 
                    ZR2->ZR2_CEP    := Upper(Alltrim(aDados[nX][11])) // SM0->M0_CEPCOB
                    ZR2->ZR2_BAIRRO := Upper(Alltrim(aDados[nX][12])) // SM0->M0_BAIRCOB
                    ZR2->ZR2_CODMUN := Upper(Alltrim(aDados[nX][13])) // SM0->M0_CODMUN
                    ZR2->ZR2_MUNICI := Upper(Alltrim(aDados[nX][14])) // SM0->M0_CIDCOB
                    ZR2->ZR2_ESTADO := Upper(Alltrim(aDados[nX][15])) // SM0->M0_ESTCOB
                    ZR2->ZR2_CNAE   := Upper(Alltrim(aDados[nX][16])) // SM0->M0_CNAE
                    ZR2->ZR2_ATVECO := Upper(Alltrim(aDados[nX][17])) // SM0->M0_DSCCNA
                    ZR2->ZR2_NATJUR := Upper(Alltrim(aDados[nX][18])) // SM0->M0_NATJUR
                ZR2->(MsUnlock())
            Next nX
        Else 
            lRet := .F.
        EndIf
    Else
        APIUtil():ConsoleLog("API97J02","Nao foi carregar os dados do arquivo SIGAMAT.EMP ...",3)
        lRet := .F.
    EndIf

    RestArea(aArea)    
    RestArea(aAreaSM0) 
Return lRet

/*/{Protheus.doc} DeletaTudo
Deleta os Dados Antes de Inserir novamente
@type Function
@author Ricardo Tavares Ferreira - rtfconsulsystem@gmail.com
@since  13/03/2021
@version 12.1.25
@history 13/03/2021, Ricardo Tavares Ferreira, Construção Inicial.
@history 12/04/2021, Ricardo Tavares Ferreira, Tratamento no retorno da tabela conforme a empresa posicionada.
/*/
//=============================================================================================================================
	Static Function DeletaTudo()
//=============================================================================================================================

    Local oQuery    := Nil
    Local cCodQry 	:= "002"
    Local lRet      := .T.

    oQuery := APIExQry():New()
    oQuery:SetFormula(cCodQry)
    oQuery:AddFilter("TAB1", RetSqlName("ZR2"))

    If .not. oQuery:ExecTCSQL()
        APIUtil():ConsoleLog("API97J02|DeletaTudo","Falha ao Executar o DELETE na tabela ZR2.",3)
        lRet := .F.
    EndIf
    FWFreeObj(oQuery)
Return lRet
