#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FILEIO.CH"

/*/{Protheus.doc} MTA105OK
MTA105OK - Confirma a gravação da solicitação ao almoxarifado.
@type function 
@author Ricardo Tavares Ferreira
@version 12.1.27
@since 16/03/2022
@history 16/03/2022, Ricardo Tavares Ferreira, Construção Inicial.
@link https://tdn.totvs.com/pages/releaseview.action?pageId=6087792
@obs LOCALIZAÇÃO : Function A105TudOk() - Validação da TudoOk
DESCRIÇÃO : Ao confirmar a solicitação ao almoxarifado. 
Pode ser utilizado para confirmar ou nao a gravacao da Solicitacao ao Almoxarifado.
@return logical, Retorna Verdadeiro para prosseguimento da alteração executada pelo ponto de entrada
/*/
//=============================================================================================================================
    User Function MTA105OK()
//=============================================================================================================================

//    Local aArea     := GetArea()
//    Local nX        := 0
//    Local aDados    := {}
//    Local cTab      := "SCP"
//   Local xCusto    := Alltrim(GdFieldGet("CP_CC"))
//    Local xItemC    := Alltrim(GdFieldGet("CP_ITEMCTA"))
//    Local xClass    := Alltrim(GdFieldGet("CP_CLVL"))
//    Local nPosQuant := aScan(aHeader,{|x| AllTrim(x[2])=="CP_QUANT"})
//    Local nTotal    := 0
//   Local aRetGrp   := {}
/*
    aDados := aCols 

    For nX := 1 To Len(aCols)
        nTotal += aCols[nX][nPosQuant]
    Next nX 

    aRetGrp := AVBUtil():ValidaGrupoAprovacao(cTab,xCusto,xItemC,xClass)

    If .not. aRetGrp[1]
        MsgStop("Não é possivel incluir uma SA sem Entidades contabeis amarradas para aprovação.","MTA105OK")
        Return .F. 
    EndIf 

    AVBUtil():TrocaGrupoAprovacao(cTab,Alltrim(CA105NUM),,DDataBase,nTotal,aRetGrp[2])

    RestArea(aArea)
*/
//Return .T.

