#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FILEIO.CH"

/*/{Protheus.doc} MT110TOK
MT110TOK - Responsável pela validação da GetDados da Solicitação de Compras .
@type function 
@author Ricardo Tavares Ferreira
@return object, Objeto do Browse.
@since 05/04/2021
@history 05/04/2021, Ricardo Tavares Ferreira, Construção Inicial.
@link https://tdn.totvs.com/display/public/PROT/MT110TOK
@obs LOCALIZAÇÃO : Function A110TudOk() responsável pela validação da GetDados da Solicitação de Compras .
EM QUE PONTO : O ponto se encontra no final da função e deve ser utilizado para validações especificas do usuario onde será 
controlada pelo retorno do ponto de entrada o qual se for .F. o processo será interrompido e se .T. será validado.
@return logical, Retorna Verdadeiro para prosseguimento da alteração executada pelo ponto de entrada
@version 12.1.27
/*/
//=============================================================================================================================
    User Function MT110TOK()
//=============================================================================================================================

    Local aArea     := GetArea()
    Local nX        := 1 
    Local aDados    := {}
    Local cDataGrv  := Date()
    Local cHoraGrv  := Time()
    Local cTab      := "SC1"
    Local xCusto    := Alltrim(GdFieldGet("C1_CC"))
    Local xItemC    := Alltrim(GdFieldGet("C1_ITEMCTA"))
    Local xClass    := Alltrim(GdFieldGet("C1_CLVL"))

    If Empty(xCusto) .or. Empty(xItemC) .or. Empty(xClass)
        xCusto := Alltrim(ACPISCX[1][2][1][3])
        xItemC := Alltrim(ACPISCX[1][2][1][5])
        xClass := Alltrim(ACPISCX[1][2][1][6])
    EndIf

    If .not. AVBUtil():ValidaGrupoAprovacao(cTab,xCusto,xItemC,xClass)[1]
        MsgStop("Não é possivel incluir uma SC sem Entidades contabeis amarradas para aprovação.","MT110TOK")
        Return .F. 
    EndIf 

    If Altera 
        For nX := 1 To Len(aCols)
            If GdDeleted(nX)
                If SC1->(DbSeek(FWXFilial("SC1")+CA110NUM+GdFieldGet("C1_ITEM",nX)+GdFieldGet("C1_ITEMGRD",nX)))
                    aAdd(aDados,{FWXFilial("SC1"),cTab,Alltrim(CA110NUM),Alltrim(GdFieldGet("C1_ITEM",nX)),cDataGrv,cHoraGrv,cValToChar(SC1->(Recno()))})
                Else 
                    APIUtil():ConsoleLog("MT110TOK","Falha ao posicionar na tabela SC1 no Registro "+Alltrim(GdFieldGet("C1_NUM",nX))+"-"+Alltrim(GdFieldGet("C1_ITEM",nX))+"para a busca dos Recno.",4)
                EndIf
            EndIf
        Next nX
    EndIf

    APIUtil():GravaDadosZR4(cTab,aDados)
    RestArea(aArea)
Return .T.
