#INCLUDE "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � COMM002  � Autor � Toni Aguiar        � Data �  17/08/17   ���
�������������������������������������������������������������������������͹��
���Descricao � Gera amarra��o do produto x fornecedor com base na SD1     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function COMM002
Private oGeraTxt

dbSelectArea("SD1")
dbSetOrder(2)

@ 200,1 TO 380,380 DIALOG oGeraTxt TITLE OemToAnsi("Gera��o de Arquivo Texto")
@ 02,10 TO 080,190
@ 10,018 Say " Este programa ira gerar a amarra��o do produto x fornecedor   "
@ 18,018 Say "                                                               "
@ 26,018 Say "                                                            "

@ 70,128 BMPBUTTON TYPE 01 ACTION OkGeraTxt()
@ 70,158 BMPBUTTON TYPE 02 ACTION Close(oGeraTxt)

Activate Dialog oGeraTxt Centered

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    � OKGERATXT� Autor � AP5 IDE            � Data �  17/08/17   ���
�������������������������������������������������������������������������͹��
���Descri��o � Funcao chamada pelo botao OK na tela inicial de processamen���
���          � to. Executa a geracao do arquivo texto.                    ���
�������������������������������������������������������������������������͹��
���Uso       � Programa principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function OkGeraTxt

Processa({|| RunCont() },"Processando...")
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    � RUNCONT  � Autor � AP5 IDE            � Data �  17/08/17   ���
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

dbSelectArea("SD1")
SD1->(dbGoTop())
//SD1->(dbSeek(xFilial()))                                                   �
SD1->(ProcRegua(RecCount())) // Numero de registros a processar
do while SD1->(!EOF()) .And. xFilial() == SD1->D1_FILIAL                           
             
    IncProc()
    
    dbSelectArea("SA5")
    SA5->(dbSetOrder(2))
    If !SA5->(dbSeek(xFilial("SA5")+SD1->(D1_COD))) //+D1_FORNECE+D1_LOJA)))
       RecLock("SA5",.T.)
       SA5->A5_FORNECE:=SD1->D1_FORNECE
       SA5->A5_LOJA   :=SD1->D1_LOJA
       SA5->A5_NOMEFOR:=POSICIONE("SA2",1,xFilial("SA2")+SD1->(D1_FORNECE+D1_LOJA),"A2_NOME")
       SA5->A5_PRODUTO:=SD1->D1_COD  
       SA5->A5_NOMPROD:=POSICIONE("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_DESC")  
       SA5->(MsUnLock())
    Endif

    SD1->(dbSkip())
EndDo

Return
