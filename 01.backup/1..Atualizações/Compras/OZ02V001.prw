#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "PRTOPDEF.CH"

/*/{Protheus.doc} OZ02V001
Valida o vencimento digitado.
@type function           
@author Ricardo Tavares Ferreira
@since 15/03/2022
@version 12.1.27
@history 15/03/2022, Ricardo Tavares Ferreira, Construção Inicial
/*/
//=============================================================================================================================
    User Function OZ02V001()
//=============================================================================================================================

    Local aArea     := GetArea()
    Local dDataVenc := GdFieldGet("E2_VENCTO")
    Local nPosPed   := aScan(aHeadD1,{|x| AllTrim(x[2])=="D1_PEDIDO"})
    Local aDados    := {}
    Local nX        := 0
    Local dDataFim  := Nil
    Local cPedCom   := ""

    aDados := aColsD1

    For nX := 1 To Len(aDados)
        cPedCom := aDados[nX][nPosPed]
        If .not. Empty(cPedCom)
            Exit
        EndIf 
    Next nX 

    If Val(Dtos(dDataVenc)) < Val(Dtos(Date()))
        MsgStop("A Data Utilizada para vencimento dos titulo nao pode ser menor que a data atual ("+Dtoc(Date())+"). Data do Digitada ("+Dtoc(dDataVenc)+").","OZ02V001")
        Return .F.
    EndIf 

    If Empty(cPedCom)
        dDataFim := DaySum(Date(),7)
        If Val(Dtos(dDataVenc)) < Val(Dtos(dDataFim))
            MsgStop("Para pedidos sem vinculo com PC a data de vencimento nao pode ser menor que 7 dias da data atual ("+Dtoc(Date())+"). Data do Digitada ("+Dtoc(dDataVenc)+").","OZ02V001")
            Return .F.
        EndIf 
    EndIf 
    RestArea(aArea)
Return .T.

// E2_VENCTO - X3_VALID -> IIf(FWIsInCallStack("MATA103"),U_OZ02V001(),.T.)
