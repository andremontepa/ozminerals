
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MTA105LIN�Autor  �Toni Aguiar          � Data �  27/04/17   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida a SA permitindo usu�rios solicitem apenas material  ���
���          � de aplica��o indireta, exceto os compradores.              ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function MTA105LIN 
Local cCodUsr
Local lRet :=.T.
Local nSaldo := 0
Local nPosProd := aScan(aHeader,{|x|AllTrim(x[2])=="CP_PRODUTO"}) 
Local nPosLoca := aScan(aHeader,{|x|AllTrim(x[2])=="CP_LOCAL"}) 
/*
//RETIRADA DA REGRA DE N�O PODER ABRIR SA QUANDO SALDO DO PRODUTO FIQUE NEGATIVO 24/06/2022
PswOrder(2)           
PswSeek(cUserName) 
aRet := PswRet(1)
cCodUsr := aRet[1][1]

nSaldo := u_XMAT105(aCols[n,nPosProd],aCols[n,nPosLoca])

If nSaldo <= 0
lRet:=.F.
MSGALERT("O produto n�o tem saldo disponivel","aten��o")
Endif
*/
/*
SY1->(DbSetOrder(3))	//filial+codusuario
If SY1->(DbSeek(xFilial("SY1")+cCodUsr))
   cRet:=.T.
Else
   If SB1->B1_APROPRI="D"
      Alert("Usu�rio autorizado a solicitar ao almoxarifado, somente produtos de aplica��o indireta. Para os produtos"+;
            " de aplica��o direta, fa�a uma solicita��o de compras.")
      lRet:=.F.
   Endif
Endif */

If SB1->B1_XAPROPR="D"
   Alert("Usu�rio autorizado a solicitar ao almoxarifado, somente produtos de aplica��o indireta. Para os produtos"+;
         " de aplica��o direta, fa�a uma solicita��o de compras.")
   lRet:=.F.
Endif

Return lRet
