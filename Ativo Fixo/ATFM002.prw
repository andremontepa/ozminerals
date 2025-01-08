#INCLUDE "rwmake.ch" 
#INCLUDE "Topconn.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � ATFM002  � Autor � Toni Aguiar        � Data �  19/12/16   ���
�������������������������������������������������������������������������͹��
���Descricao � Efetua atualiza��o das datas de inicio de deprecia��o      ���
���          � Fase da implanta��o do ATF                                 ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function ATFM002
Private oGera
Private cString := "SN3"

dbSelectArea("SN3")
SN1->(dbSetOrder(1))

@ 200,1 TO 380,380 DIALOG oGera TITLE OemToAnsi("Atualiza��o SN1 (Implanta��o)")
@ 02,10 TO 080,190
@ 10,018 Say " Este programa ir� fazer atualiza��es da datas de inicio de    "
@ 18,018 Say " deprecia��o.                                                  "
@ 26,018 Say "                                                               "

@ 70,128 BMPBUTTON TYPE 01 ACTION OkGera()
@ 70,158 BMPBUTTON TYPE 02 ACTION Close(oGera)

Activate Dialog oGera Centered

Return                                                                     

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    � OKGERA   � Autor � Toni Aguiar        � Data �  19/12/16   ���
�������������������������������������������������������������������������͹��
���Descri��o � Funcao chamada pelo botao OK na tela inicial de processamen���
���          � to. Executa o processamento de atualiza��o.                ���
�������������������������������������������������������������������������͹��
���Uso       � Programa principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function OkGera

Processa({|| RunCont() },"Processando...")
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    � RUNCONT  � Autor � Toni Aguiar        � Data �  19/12/16   ���
�������������������������������������������������������������������������͹��
���Descri��o � Funcao auxiliar chamada pela PROCESSA.  A funcao PROCESSA  ���
���          � monta a janela com a regua de processamento.               ���
�������������������������������������������������������������������������͹��
���Uso       � Programa principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function RunCont
Local nMes
Local nAno
Local dInDepr

dbSelectArea("SN3")
SN3->(dbSetOrder(1))
SN3->(dbGoTop())   

Begin Transaction

ProcRegua(RecCount())
Do While !SN3->(Eof())
   
   IncProc(SN3->N3_CBASE+"/"+SN3->N3_ITEM)
   nMes  := If(Month(SN3->N3_AQUISIC)<12, Month(SN3->N3_AQUISIC)+1, 1)
   nAno  := If(Month(SN3->N3_AQUISIC)<12, Year(SN3->N3_AQUISIC), Year(SN3->N3_AQUISIC)+1)
          
   //-- Define a data do in�cio de deprecia��o
   //-- todo bens, s� ser� depreciado no m�s seguinte a sua data de aquisi��o
   dInDepr := Ctod("01/"+Strzero(nMes,2)+"/"+Str(nAno,4))
   dInDepr := If(dInDepr<Ctod("01/04/2016"), Ctod("01/04/2016"), dInDepr)
 
   RecLock("SN3",.F.)
   SN3->N3_DINDEPR:=dInDepr
   SN3->(MsUnLock())
   
   SN3->(dbSkip())
Enddo

End Transaction 

SN3->(dbCloseArea())
Return  