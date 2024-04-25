#INCLUDE "rwmake.ch" 
#INCLUDE "Topconn.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � ATFM003  � Autor � Toni Aguiar        � Data �  01/05/21   ���
�������������������������������������������������������������������������͹��
���Descricao � Efetua atualiza��o da deprecia��o mensal e acumulada na    ���
���          � moeda 2 desde o in�cio da planta em 04/2016                ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function ATFM003()
Private oGera
Private cString := "SN3"

dbSelectArea("SN3")
SN3->(dbSetOrder(1))

@ 200,1 TO 380,380 DIALOG oGera TITLE OemToAnsi("PROJETO DE DOLARIZA��O - 2021, Implanta��o da 2a. Moeda - D�LAR")
@ 02,10 TO 080,190
@ 10,018 Say " Este programa ir� fazer atualizar a 2a. moeda desde a implanta��o "
@ 18,018 Say " At� o per�odo de 30/06/2021 - Implanta��o da Moeda 2 - PROJETO DE "
@ 26,018 Say " DOLARIZA��O, de abril/2016 � junho/2021.                           "

@ 70,128 BMPBUTTON TYPE 01 ACTION OkGera()
@ 70,158 BMPBUTTON TYPE 02 ACTION Close(oGera)

Activate Dialog oGera Centered

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    � OKGERA   � Autor � Toni Aguiar        � Data �  01/05/21   ���
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
Local cQuery

If !Pergunte("ATFM003",.T.)
   Return
Endif

cQuery:="   SELECT * FROM "+RetSqlName("SN3")+" SN3 " 
cQuery+="INNER JOIN "+RetSqlName("SN1")+" SN1 ON SN3.N3_FILIAL = SN1.N1_FILIAL AND SN3.N3_CBASE=SN1.N1_CBASE AND SN3.N3_ITEM = SN1.N1_ITEM AND SN1.D_E_L_E_T_<>'*' " 
cQuery+=" LEFT JOIN "+RetSqlName("SM2")+" SM2 ON SN1.N1_AQUISIC = SM2.M2_DATA AND SM2.D_E_L_E_T_<>'*' " 
//cQuery+="    WHERE SN3.N3_CBASE='"+MV_PAR01+"' AND SN3.N3_ITEM='"+MV_PAR02+"' AND SN3.N3_DINDEPR <= '"+DTOS(dDataBase)+"' AND SN3.N3_TIPO='"+If(MV_PAR03=1, '01', '10')+"' AND SN3.D_E_L_E_T_<>'*' "
cQuery+="    WHERE SN3.N3_DINDEPR <= '"+DTOS(dDataBase)+"' AND SN3.N3_TIPO='"+If(MV_PAR03=1, '01', '10')+"' AND SN3.D_E_L_E_T_<>'*' "
cQuery+=" ORDER BY N3_FILIAL, N3_CBASE, N3_ITEM"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRB",.F.,.T.)

Processa({|| RunCont() },"Processando...")
Close(oGera)
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    � RUNCONT  � Autor � Toni Aguiar        � Data �  01/05/2021 ���
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
Local cPath:="\DATA\"
Local nVrdAcm2:=0
Local nVrdmes2:=0
Local nSaldo  :=0
Local cOcorr  := ""
dbSelectArea("TRB")
dbGoTop()

Begin Transaction

ProcRegua(TRB->(RecCount())) 
Do While !EOF()

   IncProc("Bens: "+TRB->N3_CBASE+"/"+TRB->N3_ITEM)

   cFil  := TRB->N3_FILIAL
   cBase := TRB->N3_CBASE

   If SN3->(dbSeek(cFil+cBase+TRB->N3_ITEM+If(MV_PAR03=1, '01', '10'))) // filial+cbase+item+tipo+baixa+sequencia
      RecLock("SN3",.F.)
      SN3->N3_VORIG2 := SN3->N3_VORIG1/TRB->M2_MOEDA2
      If MV_PAR03=1
         SN3->N3_TXDEPR2:=SN3->N3_TXDEPR1
      Endif
      SN3->(MsUnLock())
   Else
      Memowrit(cPath+(cFil+Alltrim(cBase)+"_"+TRB->N3_ITEM+"_SN3"), cFil+" - "+cBase+"/"+TRB->N3_ITEM+"- N�o encontrado.")
   Endif

   // Atualiza os lan�amentos da SN4 - Movimenta��o
   dbSelectArea("SN4")
   SN4->(dbSetOrder(4))

   If SN4->(dbSeek(TRB->(N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO)))
      nVrdAcm2:=0 ; nVrdMes2:=0
      nSaldo  := SN3->N3_VORIG2

      If SN3->N3_TIPO='10' .And. SN3->N3_TPDEPR='4'
         cOcorr='06'
      ElseIf SN3->N3_TIPO='10' .And. SN3->N3_TPDEPR='1'
         cOcorr='20'
      Else
         cOcorr='06'
      Endif

      Do While SN4->(N4_FILIAL+N4_CBASE+N4_ITEM+N4_TIPO)==TRB->(N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO) .And. !SN4->(Eof())
         If SN4->N4_OCORR='05' .And. SN4->N4_TIPOCNT='1'
            RecLock('SN4',.F.)
            SN4->N4_VLROC2 := SN3->N3_VORIG2
            SN4->(MsUnLock())                 
         Else 
            If SN4->N4_OCORR=cOcorr                                         // 06 ou 20
               nVrdMes2:=IIf(SN4->N4_VLROC1>0, nSaldo * SN4->N4_TXDEPR, 0)  // Deprecia��o do m�s
               If SN4->N4_TIPOCNT="3"
                  nVrdAcm2+=nVrdMes2                                        // Deprecia��o acumulada

                  // Se deprecia��o por unidade produzida, deduz a deprecia��o do m�s do saldo
                  // pois neste caso o c�lculo tem de ser sobe o valor de saldo residual do bem.
                  If MV_PAR03=2
                     nSaldo-=nVrdMes2
                  Endif
               Endif

               RecLock('SN4',.F.)
               SN4->N4_VLROC2 := nVrdMes2
               SN4->(MsUnLock())                                  
            Endif
         Endif
         SN4->(dbSkip())
      Enddo
      // Atualiza a depreia��o do m�s e acumulada - moeda 2
      If nVrdAcm2>0
         RecLock("SN3",.F.)
         SN3->N3_VRDBAL2 := If(SN3->N3_TIPO='01', nVrdAcm2, 0)
         SN3->N3_VRDACM2 := nVrdAcm2
         SN3->N3_VRDMES2 := nVrdMes2
         SN3->(MsUnLock())
      Endif
   Else
      Memowrit(cPath+(cFil+Alltrim(cBase)+"_"+SN4->N4_ITEM+"_SN4"), cFil+" - "+cBase+"/"+SN4->N4_ITEM+"- N�o encontrado.")
   Endif

   // Processsa a tabela de apontamentos por unidade produzida
   If MV_PAR03=2
      cQuery:="SELECT * FROM "+RetSqlName("FNA")+" WHERE FNA_FILIAL='"+SN3->N3_FILIAL+"' AND FNA_CBASE='"+SN3->N3_CBASE+"' AND FNA_ITEM='"+SN3->N3_ITEM+"' AND FNA_TIPO='10'  AND FNA_MOEDA='2' AND D_E_L_E_T_<>'*' "
      cQuery+="   AND FNA_OCORR='P2' AND FNA_ESTORN='2' "
      cQuery := ChangeQuery(cQuery)
      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"FNA1",.F.,.T.)
      FNA1->(dbGoTop())

      dbSelectArea("FNA")
      FNA->(dbSetOrder(1))
      nSaldo:=SN3->N3_VORIG2
      Do While !FNA1->(Eof())
         If FNA->(dbSeek(FNA1->(FNA_FILIAL+FNA_IDMOV+FNA_ITMOV+FNA_MOEDA+FNA_OCORR)))
            RecLock("FNA",.F.)
            FNA->FNA_VALOR := nSaldo * FNA->FNA_COEFIC
            FNA->(MsUnLock())
         Endif
        
         nSaldo-=FNA->FNA_VALOR
         FNA1->(dbSkip())
      EndDo
      FNA1->(dbCloseArea())       
   Endif

   dbSelectArea("TRB")
   dbSkip()
EndDo
End Transaction
TRB->(dbCloseArea())
Alert("Processamento finalizado com sucesso!")
Return
