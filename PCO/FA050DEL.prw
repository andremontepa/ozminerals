#include "rwmake.ch"
#include "fileio.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
#include "protheus.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FA050DEL  �Autor  �Ismael Junior       � Data �  08/11/19   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ser� executado logo ap�s a confirma��o da exclus�o t�tulo. ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function FA050DEL()
Local _lRet    := .T.
Local cAno     := Alltrim(Str(Year(Date())))
Local cMes     := Month2Str(Date())
Local cCodUser := RetCodUsr() //Retorna o Codigo do Usuario
Local cNamUser := UsrRetName( cCodUser )//Retorna o nome do usuario

		cUpdate:= " UPDATE " + RetSqlName("ZW2")+" SET ZW2_VAL"+cMes+"=ZW2_VAL"+cMes+"-"+Alltrim(Str(M->E2_VALOR))+",ZW2_VLANO = ZW2_VLANO-"+Alltrim(Str(M->E2_VALOR))
		cUpdate+= " WHERE ZW2_CCUSTO = '"+Alltrim(M->E2_CCUSTO)+"' "
		cUpdate+= " AND ZW2_ITEMCO = '"+Alltrim(M->E2_ITEMCTA)+"' "
		cUpdate+= " AND ZW2_CLVL = '"+Alltrim(M->E2_CLVL)+"' "
		cUpdate+= " AND ZW2_CONTA = '"+Alltrim(M->E2_CONTAD)+"' "
		cUpdate+= " AND ZW2_ANO = '"+cAno+"' "
		cUpdate+= " AND ZW2_FILIAL = '"+xFilial("ZW2")+"' "
		cUpdate+= " AND D_E_L_E_T_ != '*' "
		nFlag := TcSqlExec(cUpdate)
		
					RecLock("ZW3",.T.)
					ZW3->ZW3_FILIAL := XFILIAL("ZW3")
					ZW3->ZW3_NUM    := GETSX8NUM("ZW3","ZW3_NUM")
					ZW3->ZW3_TIPO   := "C"
					ZW3->ZW3_CCUSTO := M->E2_CCUSTO
					ZW3->ZW3_ITEMCO := M->E2_ITEMCTA
					ZW3->ZW3_ANO    := cAno
					ZW3->ZW3_CLVL  := M->E2_CLVL
					ZW3->ZW3_CONTA  := M->E2_CONTAD
					ZW3->ZW3_DATA   := Date()
					ZW3->ZW3_VALOR  := M->E2_VALOR
					ZW3->ZW3_ORIGEM := "Contas a Pagar"
					ZW3->ZW3_USUARI := cNamUser
					ZW3->ZW3_CPNUM  := M->E2_NUM
					ZW3->ZW3_HISTOR := "Valor ref. Exclus�o do Contas a pagar: "+M->E2_NUM
					ZW3->(MsUnLock())
					ConfirmSX8()					
Return(_lRet)					
