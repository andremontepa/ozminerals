#INCLUDE "Protheus.ch"
 
/*{Protheus.doc} CN121EST()
    Possibilita ao desenvolvedor realizar operações após o estorno da medição que tenha ocorrido com sucesso.
*/
User Function CN121EST()
    Local aDocuments:= PARAMIXB[1] //Listagem de documentos estornados pela medição.
    Local lInTrans  := PARAMIXB[2] //Verdadeiro caso seja dentro da transação, Falso fora da transação
    Local nX        := 0
    Local cTipo     := ""
    Local cIdDoc    := ""
    Local xTemp     := Nil
    Local cMensagem := ""
 
    If lInTrans
        MsgInfo("Chamada dentro da transação."  ,"U_CN121EST")
    Else
        MsgInfo("Chamada fora da transação."    ,"U_CN121EST")
    EndIf
 
    for nX := 1 to Len(aDocuments)
        cMensagem := ""
        cTipo := aDocuments[nX, 1]
        cIdDoc:= aDocuments[nX, 2]
        xTemp := aDocuments[nX, 3]//Para pedidos, guarda a filial da medição. Para títulos, o RecNo da CND.
 
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
