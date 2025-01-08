/*
Ponto de Entrada para retornar quantidade Zerada para os armazéns que 
estiverem configurados no campo NNR_MRP
Descrição:
LOCALIZAÇÃO   : Localizado na função de impressão dos dados

EM QUE PONTO : É executado dentro do laço onde  é feito o cálculo do saldo do produto de todos os almoxarifados.
O resultado do cálculo do saldo é guardado na variável nSaldo. O ponto de entrada é executado após a atualização 
desta variável, produto a produto (todos os almoxarifados) .

Este Ponto de Entrada tambem é executado no programa MATA170 (Gera solicitações de compras baseado no ponto de pedido )
*/

User Function MT170SLD( )
    Local nQuant    := PARAMIXB[1]      //-- Saldo calculado pelo sistema
//    Local cProd     := PARAMIXB[2]      //-- Códido do produto
    Local cLocal    := PARAMIXB[3]      //-- Armazém do produto
    Local nNewSaldo := 0                //-- Manipulação pelo usuário do saldo do produto

    if Posicione("NNR",1,XFILIAL("NNR")+cLocal,"NNR_MRP") == "1"

        nNewSaldo := nQuant

    Endif

Return (nNewSaldo)
