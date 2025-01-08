#INCLUDE "rwmake.ch" 
#INCLUDE "Topconn.ch"

#DEFINE cAtualiza "2"		// 1 - Atualiza modo SPED PIS/COFINS, 2 - Atualiza ativo fixo implanta��o/Unidade Produtiva 

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � ATFM001  � Autor � Toni Aguiar        � Data �  19/12/16   ���
�������������������������������������������������������������������������͹��
���Descricao � Efetua atualiza��o das tabelas SN1,SN3,SN4,SN5,FNA.        ���
���          � Fase da implanta��o do ATF                                 ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function ATFM001()
Private oGera
Private cString := "SN1"

dbSelectArea("SN1")
SN1->(dbSetOrder(1))

@ 200,1 TO 380,380 DIALOG oGera TITLE OemToAnsi("Atualiza��o SN1 (Implanta��o)")
@ 02,10 TO 080,190
@ 10,018 Say " Este programa ir� fazer atualiza��es em v�rias tab�las do ATF."
@ 18,018 Say " Esta rotina s� deve ser rodada at� o per�odo de implanta��o.  "
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
                                    
cQuery := "  SELECT * FROM SN12016 " 
cQuery += "   WHERE N1_CBASENV<>'' AND "
cQuery += "         N1_GRUPO<>'' AND "
cQuery += "         N_N1_VLATF<>0 AND "
cQuery += "         SN12016.D_E_L_E_T_<>'*' "
cQuery += "ORDER BY N1_FILIAL, N1_CBASENV, N1_CODBASE, N1_ITEM "   
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRB",.F.,.T.)

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
Local cBase
Local cFil
Local _i := 0     
Local dDepr      
Local cIdMov  
Local lSeInclui
Local cConta
Local nVOrigBem:=0
Local nQtd:=1
Local cReg 
Local lPesq
Local lNovo
Local cItem   
Local nRecno:=0       
//---------------------
//-- Documentado por Toni Aguiar - TOTVS STARSOFT - Em 30/03/2017
// Linha documentada para testar o tipo 01 para o caso do SPED PIS/COFINS, mas o correo � 10 mesmo
// voltaremos a linha assim que argumetar com a totvs.
Local cTipo    := If(cAtualiza=="1", "01", "10")  // 01 - Deprecia��o fiscal, 10 - Deprecia��o Gerencial/cont�bil
Local cTipoDepr:= If(cAtualiza=="1", "1" , "4" )  //  1 - Linear            ,  4 - Unidade produtiva

dbSelectArea("TRB")
dbGoTop()

Begin Transaction

ProcRegua(RecCount()) 
Do While !EOF()

    IncProc(TRB->N1_CODBASE+"/"+TRB->N1_CBASENV)

    cFil  := TRB->N1_FILIAL
    cBase := TRB->N1_CBASENV
    _i:=1    

    //If Alltrim(TRB->N1_CBASENV)=="8530"
    //  _i:=_i
    //Endif
    
    Do While !Eof() .And. (cFil+cBase==TRB->N1_FILIAL+TRB->N1_CBASENV) 
       
       // Verifica se j� existe um bem com o c�digo novo + item novo
       // para evitar erro de duplicidade na inclus�o do banco.
       If SN1->(dbSeek(TRB->(N1_FILIAL+N1_CBASENV+Strzero(_i,4))))     
          _i++
          Loop
       Endif

       //-- Define datas
       nMes  := If(Month(SN1->N1_AQUISIC)<12, Month(SN1->N1_AQUISIC)+1, 1)
       nAno  := If(Month(SN1->N1_AQUISIC)<12, Year(SN1->N1_AQUISIC), Year(SN1->N1_AQUISIC)+1)
          
       //-- Define a data do in�cio de deprecia��o
       //-- todo bem, s� ser� depreciado no m�s seguinte a sua data de aquisi��o
       dInDepr := Ctod("01/"+Strzero(nMes,2)+"/"+Str(nAno,4))
       dInDepr := If(dInDepr<Ctod("01/04/2016"), Ctod("01/04/2016"), dInDepr)

       //-- Atualiza os dados novos no BEM                                                
       //If SN1->(dbSeek(TRB->(N1_FILIAL+N1_CODBASE+N1_ITEM))) .And. SN1->N1_STATUS<>"1"
       lPesq   := SN1->(dbSeek(TRB->(N1_FILIAL+N1_CODBASE+N1_ITEM))) 
       lNovo   := If(lPesq.And.SN1->N1_STATUS=="1", .F., .T.)						// Se � uma nova Classifica��o
       cItem   := If(!lNovo, SN1->N1_ITEM, Strzero(_i,4)) 
       
       // Faz uma rechecagem verificando se j� existe um bem com o item novamente
       nRecno  := SN1->(Recno())
       Do While .T.
          If SN1->(dbSeek(TRB->(N1_FILIAL+N1_CBASENV+cItem)))
             _i++
             cItem:=Strzero(_i,4)
             Loop
          Endif
          SN1->(dbGoto(nRecno))
          Exit
       Enddo
       
       If lPesq
          // Atualiza o cadastro de bens 
          RecLock("SN1",.F.) 
          SN1->N1_CBASE  := TRB->N1_CBASENV
          SN1->N1_ITEM   := cItem
          SN1->N1_GRUPO  := TRB->N1_GRUPO
          SN1->N1_xCest  := TRB->N1_CLASS                                  
          SN1->N1_CHAPA  := Alltrim(TRB->N1_CODBASE)+cItem
          SN1->N1_XLOCA  := TRB->N1_LOCALIZ
          SN1->N1_XPACOTE:= TRB->N1_PACOTE
          SN1->N1_XCCFFA := TRB->N1_CCFFA    
          SN1->N1_DTCLASS:= dInDepr
          SN1->N1_STATUS := "1"				// Bem classificado
          SN1->(MsUnLock()) 
          
          cConta:= Posicione("SNG",1,xFilial("SNG")+SN1->N1_GRUPO,"NG_CCONTAB")                           
          
          //-- Pesquisa a nota fiscal relacionada no cadastro do bem.
          //-- Faremos uma atualiza��o no valor do bem.
          dbSelectArea("SD1")
          SD1->(dbSetOrder(1))
          If SD1->(dbSeek(SN1->(N1_FILIAL+N1_NFISCAL+N1_NSERIE+N1_FORNEC+N1_LOJA+N1_PRODUTO+N1_NFITEM)))
             dbSelectArea("SF4")
             SF4->(dbSetOrder(1))
             SF4->(dbSeek(xFilial("SF4")+SD1->D1_TES))
             
             If SF4->F4_BENSATF='1'	// 1-Sim
                nVOrigBem:=NoRound( &(SuperGetMv("MV_VLRATF")) / SD1->D1_QUANT ,2)  
                nQtd:=SD1->D1_QUANT
             Else                   // 2-N�o
                nVOrigBem:=&(SuperGetMv("MV_VLRATF"))
                nQtd:=1
             Endif   
             
             //-- Dados Fiscais para gerar os cr�ditos de PIS/COFINS no SPED de contribui��es
             If SF4->F4_PISCRED="1"  
                RecLock("SN1",.F.)
                SN1->N1_CALCPIS:="1"
                SN1->N1_DETPATR:="04"
                SN1->N1_UTIPATR:="9 "
                SN1->N1_ORIGCRD:="0"
                SN1->N1_CSTPIS :="52"  
                SN1->N1_ALIQPIS:=1.65
                SN1->N1_CSTCOFI:="52"
                SN1->N1_ALIQCOF:=7.60
                SN1->N1_CODBCC :="10"
                SN1->N1_CBCPIS :="1" 
                SN1->N1_MESCPIS:=0
                SN1->(MsUnLock())
             Endif
          Else
              nVOrigBem:=TRB->N_N1_VLRUN	// TRB->N1_VLRUNIT
          Endif          
          
          //-- Documentado por Toni Aguiar - TOTVS STARSOFT - Em 30/03/2017
          //-- Ficou definido com Sergio Braz que o valor do bem, n�s vamos buscar na planilha
          //-- fornecida pelo Sergio, pois esta est� conciliada.
          nVOrigBem:=TRB->N_N1_VLATF 	// TRB->N1_VLATF
          
          //-- Tabela de saldos
          //-- Exclui para reclassifica-lo
          dbSelectArea("SN3")
          SN3->(dbSetOrder(1))
          If SN3->(dbSeek(cFil+TRB->(N1_CODBASE+N1_ITEM)+"01"+"0"+"001")) .And. Empty(SN3->N3_XORIGEM)// filial+cbase+item+tipo+baixa+sequencia 
             cReg:=cFil+TRB->(N1_CODBASE+N1_ITEM)+"01"+"0"+"001"
             Do While cReg==cFil+TRB->(N1_CODBASE+N1_ITEM)+"01"+"0"+"001" .And. !SN3->(Eof())
                RecLock("SN3",.F.)
                SN3->(dbDelete())
                SN3->(MsUnLock())
                SN3->(dbSkip())
             Enddo
          Endif
          cOrigem:=SN3->N3_XORIGEM
          
          If Empty(SN3->N3_XORIGEM)       
	          //-- Tabela de saldos
	          //-- Exclui para reclassifica-lo
	          dbSelectArea("SN3")
	          SN3->(dbSetOrder(1))
	          If SN3->(dbSeek(cFil+TRB->(N1_CBASENV+cItem+"10"+"0"+"001"))) .And. Empty(SN3->N3_XORIGEM) // filial+cbase+item+tipo+baixa+sequencia 
	             cReg:=cFil+TRB->(N1_CBASENV+cItem+"10"+"0"+"001")
	             Do While cReg==cFil+TRB->(N1_CBASENV+cItem+"10"+"0"+"001") .And. !SN3->(Eof())
	                RecLock("SN3",.F.)
	                SN3->(dbDelete())
	                SN3->(MsUnLock())
	                SN3->(dbSkip())
	             Enddo
	          Endif
	
	          //-- Tabela de movimento
	          //-- Exclui para reclassifica-lo
	          dbSelectArea("SN4")
	          SN4->(dbSetOrder(1))
	          If SN4->(dbSeek(cFil+TRB->(N1_CODBASE+N1_ITEM)+"01")) // filial+cbase+item+tipo+baixa+sequencia 
	             RecLock("SN4",.F.)
	             SN4->(dbDelete())
	             SN4->(MsUnLock())
	          Endif
	          
	          //-- Tabela de movimento
	          //-- Exclui para reclassifica-lo
	          dbSelectArea("SN4")
	          SN4->(dbSetOrder(1))
	          If SN4->(dbSeek(cFil+TRB->(N1_CBASENV+cItem+"10"))) // filial+cbase+item+tipo+baixa+sequencia 
	             RecLock("SN4",.F.)
	             SN4->(dbDelete())
	             SN4->(MsUnLock())            
	          Endif                           
	          
	          //-- Tabela de apontamento de produ��o
	          //-- Exclui para reclassifica-lo.
	          dbSelectArea("FNA")
	          FNA->(dbSetOrder(2))
	          If FNA->(dbSeek(cFil+SN1->N1_CBASE+SN1->N1_ITEM))
	             RecLock("FNA",.F.)
	             FNA->(dbDelete())
	             FNA->(MsUnLock())
	          Endif
	      Endif
          
          //-- Tabela de saldos
          //-- Efetua a inclus�o de um novo saldo com base no novo c�digo do bem
          If !SN3->(dbSeek(cFil+SN1->(N1_CBASE+N1_ITEM)+cTipo+"0"+"001")) // filial+cbase+item+tipo+baixa+sequencia
             RecLock("SN3",.T.)
             SN3->N3_FILIAL := cFil
             SN3->N3_CBASE  := SN1->N1_CBASE
             SN3->N3_ITEM   := SN1->N1_ITEM
             SN3->N3_TIPO   := cTipo					// 1-Deprecia��o fiscal ou 10-Gerencial/Cont�bil
             SN3->N3_TPDEPR := cTipoDepr				// Linear ou unidade produzida            
             SN3->N3_BAIXA  := "0"
             SN3->N3_HISTOR := "DEPRECIACAO POR UNIDADE DE PRODUCAO"
             SN3->N3_TPSALDO:= "1" 
             SN3->N3_CCONTAB:= cConta     														// Conta cont�bil associada ao bem
             SN3->N3_CDEPREC:= Posicione("SNG",1,xFilial("SNG")+SN1->N1_GRUPO,"NG_CDEPREC")     // Conta ao qual ser� d�bito mensalmente o valor da despesa de deprecia��o
             SN3->N3_CCDEPR := Posicione("SNG",1,xFilial("SNG")+SN1->N1_GRUPO,"NG_CCDEPR")      // Conta na qual ser� cr�ditada o valor da deprecia��o acumulada
             SN3->N3_CUSTBEM:= Posicione("SNG",1,xFilial("SNG")+SN1->N1_GRUPO,"NG_CUSTBEM")     // Centro de custo referente a conta do bem cadastrado.
             SN3->N3_CCUSTO := Posicione("SNG",1,xFilial("SNG")+SN1->N1_GRUPO,"NG_CCDESP")      // Centro de custo da despesa de deprecia��o
             //-- Data de in�cio de deprecia��o vai ser sempre o m�s seguite a data de aquisi��o do bem.   
             SN3->N3_DINDEPR:= dInDepr                                                                  
             //-- Valor original do bem � convertido na moeda 2 conforme a data de in�cio de deprecia��o.
             SN3->N3_VORIG1 := nVOrigBem
             SN3->N3_VORIG2 := NoRound( nVOrigBem/RecMoeda(dInDepr,2) ,2)                                     
             //-- Puxa o saldo residual do per�odo igual ao per�odo de in�cio de deprecia��o.
             SN3->N3_PRODANO:= Posicione("SZ4",1,xFilial("SZ4")+SN1->N1_XCEST+Str(nAno,4)+Strzero(nMes,2),"Z4_SANT")  
             //--     
             SN3->N3_AQUISIC:= SN1->N1_AQUISIC
             SN3->N3_SEQ    := "001"
             SN3->N3_SEQREAV:= "01"
             SN3->N3_FILORIG:= TRB->N1_FILIAL
             SN3->N3_RATEIO := "2"
             SN3->N3_ATFCPR := "2"
             SN3->N3_INTP   := "2"     
             SN3->N3_XORIGEM:= "ATFM001"
             SN3->(MsUnLock())

             // Atualiza SN5 - Saldos cont�beis
             lSeInclui:=!SN5->(dbSeek(cFil+cConta+If(cAtualiza="1", DTOS(SN1->N1_AQUISIC), DTOS(dInDepr))))
             
             RecLock("SN5",lSeInclui)                      
             SN5->N5_FILIAL := cFil
             SN5->N5_CONTA  := Posicione("SNG",1,xFilial("SNG")+SN1->N1_GRUPO,"NG_CCONTAB")
             SN5->N5_DATA   := If(cAtualiza="1", SN1->N1_AQUISIC, dInDepr)			
             SN5->N5_TIPO   := "1"
             SN5->N5_VALOR1 := If(lSeInclui, nVOrigBem, SN5->N5_VALOR1+nVOrigBem)
             SN5->N5_VALOR2 := If(lSeInclui, NoRound( nVOrigBem/RecMoeda(dInDepr,2) ,2), SN5->N5_VALOR2 + NoRound( nVOrigBem/RecMoeda(dInDepr,2) ,2)  )  
             SN5->N5_TPSALDO:= "1"
             SN5->N5_TPBEM  := cTipo  			// 10 - Deprecia��o gerencial
             SN5->(MsUnLock())

             // SN4 - Saldo inicial para movimenta��o mensal do ativo fixo
             cIdMov:=GetSXENum("SN4","N4_IDMOV")
             
             RecLock("SN4",.T.)
             SN4->N4_FILIAL := cFil
             SN4->N4_CBASE  := SN1->N1_CBASE
             SN4->N4_ITEM   := SN1->N1_ITEM
             SN4->N4_TIPO   := cTipo			
             SN4->N4_OCORR  := "05"				// Saldo de implanta��o 
             SN4->N4_DATA   := If(cAtualiza="1", SN1->N1_AQUISIC, dInDepr)   
             SN4->N4_TIPOCNT:= "1"              // Tipo de conta - [1]-Conta do bem.
             SN4->N4_CONTA  := Posicione("SNG",1,xFilial("SNG")+SN1->N1_GRUPO,"NG_CCONTAB")
             SN4->N4_QUANTD := SN1->N1_QUANTD
             SN4->N4_VLROC1 := nVOrigBem
             SN4->N4_VLROC2 := NoRound( nVOrigBem/RecMoeda(dInDepr,2) ,2)
             SN4->N4_SEQ    := "001"
             SN4->N4_SEQREAV:= "01"
             SN4->N4_IDMOV  := cIdMov
             SN4->N4_CALCPIS:= "2"
             SN4->N4_LA     := ""
             SN4->N4_ORIGEM := "ATFM001"
             SN4->N4_LP     := "804"
             SN4->N4_TPSALDO:= "1"
             SN4->N4_SERIE  := SN1->N1_NSERIE
             SN4->N4_SDOC   := SN1->N1_NSERIE
             SN4->N4_NOTA   := SN1->N1_NFISCAL
             SN4->N4_CALCPIS:= SN1->N1_CALCPIS
             SN4->(MsUnLock())
             ConfirmSX8()
             
             // FNA - Apontamento de produ��o - Saldo Inicial
             cIdMov := GetSXENum("FNA", "FNA_IDMOV")
             
             RecLock("FNA",.T.)    
             FNA->FNA_FILIAL := cFil
             FNA->FNA_IDMOV  := cIdMov
             FNA->FNA_ITMOV  := '000001'
             FNA->FNA_CBASE  := SN1->N1_CBASE
             FNA->FNA_ITEM   := SN1->N1_ITEM
             FNA->FNA_TIPO   := cTipo			
             FNA->FNA_SEQ    := '001'
             FNA->FNA_SEQREA := '01'
             FNA->FNA_TPSALDO:= '1'
             FNA->FNA_TPDEPR := cTipoDepr
             FNA->FNA_DATA   := dInDepr
             FNA->FNA_OCORR  := 'P0'			// Saldo inicial
             FNA->FNA_DTPERI := dInDepr
             //-- Puxa o saldo residual do per�odo igual ao per�odo de in�cio de deprecia��o.
             FNA->FNA_QUANTD := Posicione("SZ4",1,xFilial("SZ4")+SN1->N1_XCEST+Str(nAno,4)+Strzero(nMes,2),"Z4_SANT")  
             FNA->FNA_ESTORN := "2"
             FNA->(MsUnLock())
             ConfirmSX8()
          Endif
          
          // soma o proximo item
          If lNovo
             _i++
          Else
             _i:=Val(cItem)+1
          Endif

       Endif
       
       dbSelectArea("TRB")
       dbSkip()
    Enddo
EndDo
AtuSN1()
End Transaction
TRB->(dbCloseArea())
Alert("Processamento finalizado com sucesso!")
Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AtuSN1    �Autor  � Toni Aguiar        � Data �  04/04/17   ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o que atualiza todos os campos da aba fiscal do       ���
���          � do cadastro do bem do ativo conforme a nota fiscal         ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function AtuSN1() 
dbSelectArea("SN1")
SN1->(dbSetOrder(1))
SN1->(dbGoTop())
ProcRegua(SN1->(RecCount()))   
Do While !SN1->(Eof())
   
   IncProc("Atualizando situa��es fiscais no cadastro dos bens!")
   dbSelectArea("SD1")
   SD1->(dbSetOrder(1))
   If SD1->(dbSeek(SN1->(N1_FILIAL+N1_NFISCAL+N1_NSERIE+N1_FORNEC+N1_LOJA+N1_PRODUTO+N1_NFITEM)))
      dbSelectArea("SF4")
      SF4->(dbSetOrder(1))
      SF4->(dbSeek(xFilial("SF4")+SD1->D1_TES))
             
      //-- Atualiza os dados fiscais no ativo conforme nota fiscal de origem
      If SF4->F4_PISCRED="1"  
         RecLock("SN1",.F.)
         SN1->N1_CALCPIS:="1"
         SN1->N1_DETPATR:="04"
         SN1->N1_UTIPATR:="9 "
         SN1->N1_ORIGCRD:="0"
         SN1->N1_CSTPIS :="52"  
         SN1->N1_ALIQPIS:=1.65
         SN1->N1_CSTCOFI:="52"
         SN1->N1_ALIQCOF:=7.60
         SN1->N1_CODBCC :="10"
         SN1->N1_CBCPIS :="1" 
         SN1->N1_MESCPIS:=0
         SN1->(MsUnLock())
      Endif
   Endif
   
   SN1->(dbSkip())
Enddo
Return