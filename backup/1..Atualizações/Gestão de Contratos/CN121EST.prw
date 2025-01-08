#INCLUDE "Protheus.ch"
 
/*{Protheus.doc} CN121EST()
    Possibilita ao desenvolvedor realizar opera��es ap�s o estorno da medi��o que tenha ocorrido com sucesso.
*/
User Function CN121EST()
    Local aDocuments:= PARAMIXB[1] //Listagem de documentos estornados pela medi��o.
    Local lInTrans  := PARAMIXB[2] //Verdadeiro caso seja dentro da transa��o, Falso fora da transa��o
    Local nX        := 0
    Local cTipo     := ""
    Local cIdDoc    := ""
    Local xTemp     := Nil
    Local cMensagem := ""
 
    If lInTrans
        MsgInfo("Chamada dentro da transa��o."  ,"U_CN121EST")
    Else
        MsgInfo("Chamada fora da transa��o."    ,"U_CN121EST")
    EndIf
 
    for nX := 1 to Len(aDocuments)
        cMensagem := ""
        cTipo := aDocuments[nX, 1]
        cIdDoc:= aDocuments[nX, 2]
        xTemp := aDocuments[nX, 3]//Para pedidos, guarda a filial da medi��o. Para t�tulos, o RecNo da CND.
 
        Do Case
            Case(cTipo == "1")//Pedido de Compra
                cMensagem += "Pedido de Compra:"+cIdDoc
                cMensagem += ". Filial Medicao := "+ xTemp
            Case(cTipo == "2")//Pedido de Venda
                cMensagem += "Pedido de Venda:"+cIdDoc
                cMensagem += ". Filial Medicao := "+ xTemp
            Case(cTipo == "3")//Titulo a Pagar - SE2
                cMensagem += "Titulo a Pagar:"+cIdDoc
                cMensagem += ". RecNo Medicao := "+ cValToChar(xTemp)
            Case(cTipo == "4")//Titulo a Receber - SE1
                cMensagem += "Titulo a Receber:"+cIdDoc
                cMensagem += ". RecNo Medicao := "+ cValToChar(xTemp)
        EndCase
 
        MsgInfo(cMensagem , "U_CN121EST")
    next nX
Return
