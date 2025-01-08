#Include "rwmake.ch"
#Include "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AXSZ3     � Autor � Toni Aguiar        � Data �  08/12/2016 ���
�������������������������������������������������������������������������͹��
���Descricao � Controle de estimativa de produ��o                         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAATF                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function AXSZ3()
Private cCadastro := "Classifica��o estimada"
Private aRotina   := { {"Pesquisar","AxPesqui",0,1} ,;
                       {"Visualizar","AxVisual",0,2} ,;
                       {"Incluir","U_AxIncSZ3",0,3} ,;
                       {"Alterar","AxAltera",0,4} ,;
                       {"Excluir","U_AxDelSZ3",0,5} }
Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock
Private cAlias := "SZ3"    
Private cCampo  := "Z3_STATUS"

dbSelectArea("SZ3")
dbSetOrder(1)
mBrowse( 6,1,22,75,cAlias,,cCampo)

Return 

//-
// Fun��o de inclus�o 
//-
User Function AxIncSZ3(cAlias,nReg,cOpc)
AxInclui("SZ3",nReg,cOpc)
If Empty(SZ3->Z3_STATUS) .And. SZ3->Z3_SALDO=0
   RecLock("SZ3",.F.)
   SZ3->Z3_SALDO := SZ3->Z3_ESTIMA
   SZ3->(MsUnLock())
Endif
Return

//-
// Fun��o para exclus�o da aplica��o
//-
User Function AxDelSZ7(cAlias,nReg,cOpc)
If SZ3->Z3_ACM=0
   If MsgYesNo("Confirma a exclus�o desta classifica��o?")
      RecLock("SZ3",.F.)
      SZ3->(dbDelete())
      SZ3->(MsUnLock())                           
   Endif
Else
   Alert("Exclus�o n�o permitida, pois h� movimenta��es nesta classifica��o.")
Endif
Return

