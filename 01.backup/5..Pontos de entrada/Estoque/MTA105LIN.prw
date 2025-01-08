
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMTA105LINบAutor  ณToni Aguiar          บ Data ณ  27/04/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida a SA permitindo usuแrios solicitem apenas material  บฑฑ
ฑฑบ          ณ de aplica็ใo indireta, exceto os compradores.              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function MTA105LIN 
Local cCodUsr
Local lRet :=.T.
Local nSaldo := 0
Local nPosProd := aScan(aHeader,{|x|AllTrim(x[2])=="CP_PRODUTO"}) 
Local nPosLoca := aScan(aHeader,{|x|AllTrim(x[2])=="CP_LOCAL"}) 
/*
//RETIRADA DA REGRA DE NรO PODER ABRIR SA QUANDO SALDO DO PRODUTO FIQUE NEGATIVO 24/06/2022
PswOrder(2)           
PswSeek(cUserName) 
aRet := PswRet(1)
cCodUsr := aRet[1][1]

nSaldo := u_XMAT105(aCols[n,nPosProd],aCols[n,nPosLoca])

If nSaldo <= 0
lRet:=.F.
MSGALERT("O produto nใo tem saldo disponivel","aten็ใo")
Endif
*/
/*
SY1->(DbSetOrder(3))	//filial+codusuario
If SY1->(DbSeek(xFilial("SY1")+cCodUsr))
   cRet:=.T.
Else
   If SB1->B1_APROPRI="D"
      Alert("Usuแrio autorizado a solicitar ao almoxarifado, somente produtos de aplica็ใo indireta. Para os produtos"+;
            " de aplica็ใo direta, fa็a uma solicita็ใo de compras.")
      lRet:=.F.
   Endif
Endif */

If SB1->B1_XAPROPR="D"
   Alert("Usuแrio autorizado a solicitar ao almoxarifado, somente produtos de aplica็ใo indireta. Para os produtos"+;
         " de aplica็ใo direta, fa็a uma solicita็ใo de compras.")
   lRet:=.F.
Endif

Return lRet
