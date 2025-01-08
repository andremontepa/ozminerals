#INCLUDE "rwmake.ch" 
#INCLUDE "Topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ COMM004  º Autor ³ Toni Aguiar        º Data ³  26/08/21   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Efetua o recalculo do custo médio de 01/01/21 à 31/08/21   º±±
±±º          ³ Rotia para correção do cálculo na 2a. moeda - DÓLAR        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ compras>miscelanea                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function COMM004
Private oGera
Private cString := "SB2"

dbSelectArea("SB2")
SN1->(dbSetOrder(1))

@ 200,1 TO 380,380 DIALOG oGera TITLE OemToAnsi("Atualização do Custo Médio  ")
@ 02,10 TO 080,190
@ 10,018 Say " Este programa irá fazer atualizações o custo médio a partir de"
@ 18,018 Say " 01/01/2021 até 31/08/2021. Esta rotina efetua correção do     "
@ 26,018 Say " custo médio apenas na moeda 2 - Dólar.                        "

@ 70,128 BMPBUTTON TYPE 01 ACTION OkGera()
@ 70,158 BMPBUTTON TYPE 02 ACTION Close(oGera)

Activate Dialog oGera Centered

Return                                                                     

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ OKGERA   º Autor ³ Toni Aguiar        º Data ³  26/08/21   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao chamada pelo botao OK na tela inicial de processamenº±±
±±º          ³ to. Executa o processamento de atualização.                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function OkGera

Processa({|| RunCont() },"Processando...")
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ RUNCONT  º Autor ³ Toni Aguiar        º Data ³  26/08/21   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela PROCESSA.  A funcao PROCESSA  º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RunCont
Local cSql1
Local cSql2               
Local cSql3
Local nSldFisico:= 0
Local nSldUsd   := 0      
Local nCM       := 0
Local nCustoMvto:= 0
Local cIndex1   := CriaTrab(Nil,.F.)
Local cKey      
Local cFilter
Local cLoca     := GetNewPar("MV_LOCADOL",'01')

dbSelectArea("SB2")
//SB2->(dbSetOrder(1))
//SB2->(dbGoTop())   
cKey    :="B2_FILIAL+B2_COD+B2_LOCAL"
//cFilter	:="B2_FILIAL='"+xFilial("SB2")+"' .AND. B2_COD='012132' .AND. B2_LOCAL='01'"
cFilter	:="B2_FILIAL='"+xFilial("SB2")+"' .AND. B2_LOCAL='"+cLoca+"'"
IndRegua("SB2",cIndex1,cKey,,cFilter,"Selecionando produtos....")
dbGoTop()

dbSelectArea("SB2")
dbGoTop()

Begin Transaction

ProcRegua(RecCount())
Do While !SB2->(Eof())
                                                            
   IncProc(SB2->B2_COD+"/"+cLoca)                                                
   // Saldos iniciais em 31/12/2020
   cSql1:="   SELECT * FROM "+RetSqlName("SB2")+" SB2 " 
   cSql1+="LEFT JOIN "+RetSqlName("SB9")+" SB9 ON SB9.B9_FILIAL=SB2.B2_FILIAL AND SB9.B9_COD=SB2.B2_COD AND SB9.B9_LOCAL=SB2.B2_LOCAL AND SB9.B9_DATA = '20201231' AND SB9.D_E_L_E_T_<>'*' "
   cSql1+="    WHERE SB2.B2_FILIAL='"+xFilial("SB2")+"' AND SB2.B2_COD='"+SB2->B2_COD+"' AND SB2.B2_LOCAL='"+cLoca+"' AND SB2.D_E_L_E_T_<>'*' "
   cSql1:=ChangeQuery(cSql1)
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql1),"SQL1",.T.,.F.)
   SQL1->(dbGoTop())                                  
   // Valores iniciais em 31/12/2020
   nSldFisico := SQL1->B9_QINI				// Saldo físico inicial
   nSldUsd    := Round(SQL1->B9_VINI2,2)	// Saldo valorizado em dolar
   nCM        := Round(SQL1->B9_CM2,4) 		// Custo médio inicial 
   cSql2:="SELECT D3_FILIAL, D3_COD,D3_EMISSAO,D3_LOCAL,D3_TM,D3_QUANT, D3_CF, D3_CUSTO1, 'SD3' AS TIPO, (CASE WHEN D3_TM<500 THEN 'ENT' ELSE 'SAI' END) AS MVTO, 0 AS USD, D3_DOC, D3_NUMSEQ, '' AS D3_SERIE, '' AS D3_ITEM, '' AS D3_FORNE, '' AS D3_LOJA FROM "+RetSqlName("SD3")+" SD3 "
   cSql2+=" WHERE SD3.D_E_L_E_T_<>'*' AND SD3.D3_FILIAL='"+xFilial("SD3")+"' AND SD3.D3_COD = '"+SB2->B2_COD+"' AND SD3.D3_LOCAL='"+cLoca+"' " 
   cSql2+="       AND SD3.D3_EMISSAO > '20201231' "
   cSql2+=" UNION " 
   cSql2+="SELECT D1_FILIAL D3_FILIAL, D1_COD D3_COD,D1_DTDIGIT D3_EMISSAO,D1_LOCAL D3_LOCAL ,D1_TES D3_TM,D1_QUANT D3_QUANT, D1_UM D3_CF, D1_CUSTO D3_CUSTO1, 'SD1' AS TIPO, (CASE WHEN D1_TES<500 THEN 'ENT' ELSE 'SAI' END) AS MVTO, M2_MOEDA2 AS USD, D1_DOC D3_DOC, "
   cSql2+="       D1_NUMSEQ D3_NUMSEQ, D1_SERIE D3_SERIE, D1_ITEM D3_ITEM, D1_FORNECE D3_FORNE, D1_LOJA D3_LOJA FROM "+RetSqlName("SD1")+" SD1 "
   cSql2+=" INNER JOIN "+RetSqlName("SM2")+" SM2 ON SM2.M2_DATA=SD1.D1_DTDIGIT AND SM2.D_E_L_E_T_<>'*' "
   cSql2+=" INNER JOIN "+RetSqlName("SF4")+" SF4 ON SF4.F4_CODIGO=SD1.D1_TES AND SF4.F4_ESTOQUE='S' AND SF4.D_E_L_E_T_<>'*' "
   cSql2+=" WHERE SD1.D_E_L_E_T_<>'*' AND SD1.D1_FILIAL='"+xFilial("SD1")+"' AND SD1.D1_COD = '"+SB2->B2_COD+"' AND SD1.D1_LOCAL='"+cLoca+"' " 
   cSql2+="       AND SD1.D1_DTDIGIT > '20201231' "
   cSql2+=" UNION 
   cSql2+="SELECT D2_FILIAL D3_FILIAL, D2_COD D3_COD,D2_EMISSAO D3_EMISSAO,D2_LOCAL D3_LOCAL ,D2_TES D3_TM,D2_QUANT D3_QUANT, D2_CLIENTE D3_CF, D2_TOTAL D3_CUSTO1, 'SD2' AS TIPO, (CASE WHEN D2_TES<500 THEN 'ENT' ELSE 'SAI' END) AS MVTO, 0 AS MOEDA, D2_DOC D3_DOC, "
   cSql2+="       D2_NUMSEQ D3_NUMSEQ, D2_SERIE D3_SERIE, D2_ITEM D3_ITEM, D2_CLIENTE D3_FORNE, D2_LOJA D3_LOJA FROM "+RetSqlName("SD2")+" SD2 "
   cSql2+=" INNER JOIN "+RetSqlName("SF4")+" SF4 ON SF4.F4_CODIGO=SD2.D2_TES AND SF4.F4_ESTOQUE='S' AND SF4.D_E_L_E_T_<>'*' "
   cSql2+=" WHERE SD2.D_E_L_E_T_<>'*' AND SD2.D2_FILIAL='"+xFilial("SD2")+"' AND SD2.D2_COD = '"+SB2->B2_COD+"' AND SD2.D2_LOCAL='"+cLoca+"' "
   cSql2+="       AND SD2.D2_EMISSAO > '20201231' "
   cSql2+="ORDER BY D3_EMISSAO, D3_NUMSEQ, D3_DOC "
   cSql2:=ChangeQuery(cSql2)
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql2),"SQL2",.T.,.F.)
   SQL2->(dbGoTop())
   Do While !SQL2->(Eof())     
   
      // Movimentação Interna
      If SQL2->TIPO="SD3"      
         nCustoMvto:=Round(SQL2->D3_QUANT*nCM,2)
         If SQL2->MVTO="SAI"
            nSldFisico-=SQL2->D3_QUANT
            nSldUsd   -=nCustoMvto
         Else
            nSldFisico+=SQL2->D3_QUANT
            nSldUsd   +=nCustoMvto
         Endif
         cSql3:="UPDATE "+RetSqlName("SD3")+" SET D3_CUSTO2="+Alltrim(Str(nCustoMvto))+" "
         cSql3+="  FROM "+RetSqlName("SD3")+" SD3 WHERE SD3.D3_FILIAL='"+SQL2->D3_FILIAL+"' AND SD3.D3_TM='"+SQL2->D3_TM+"' "
         cSql3+="   AND SD3.D3_COD='"+SQL2->D3_COD+"' AND SD3.D3_LOCAL='"+cLoca+"' AND SD3.D3_DOC='"+SQL2->D3_DOC+"' AND SD3.D3_NUMSEQ='"+SQL2->D3_NUMSEQ+"' AND SD3.D_E_L_E_T_<>'*' "
         TcSqlExec(cSql3)
         TcSqlExec("Commit")  
         
      // Documento de Entradas
      ElseIf SQL2->TIPO="SD1"      
         nCustoMvto:=Round(SQL2->D3_CUSTO1/SQL2->USD,2)
         nSldFisico+=SQL2->D3_QUANT
         nSldUsd   +=nCustoMvto
         nCM      :=Round(nSldUsd/nSldFisico,4)
         cSql3:="UPDATE "+RetSqlName("SD1")+" SET D1_CUSTO2="+Alltrim(Str(nCustoMvto))+" "
         cSql3+="  FROM "+RetSqlName("SD1")+" SD1 WHERE SD1.D1_FILIAL='"+SQL2->D3_FILIAL+"' AND SD1.D1_ITEM='"+SQL2->D3_ITEM+"' "
         cSql3+="   AND SD1.D1_COD='"+SQL2->D3_COD+"' AND SD1.D1_LOCAL='"+cLoca+"' AND SD1.D1_FORNECE='"+SQL2->D3_FORNE+"' AND SD1.D1_LOJA='"+SQL2->D3_LOJA+"' "
         cSql3+="   AND SD1.D1_DOC='"+SQL2->D3_DOC+"' AND SD1.D1_SERIE='"+SQL2->D3_SERIE+"' AND SD1.D_E_L_E_T_<>'*' "
         TcSqlExec(cSql3)
         TcSqlExec("Commit")
      
      // Documento de Saídas
      Else
         nCustoMvto:=Round(SQL2->D3_QUANT*nCM,2)
         nSldFisico-=SQL2->D3_QUANT
         nSldUsd   -=nCustoMvto

         cSql3:="UPDATE "+RetSqlName("SD2")+" SET D2_CUSTO2="+Alltrim(Str(nCustoMvto))+" "
         cSql3+="  FROM "+RetSqlName("SD2")+" SD2 WHERE SD2.D2_FILIAL='"+SQL2->D3_FILIAL+"' AND SD2.D2_ITEM='"+SQL2->D3_ITEM+"' "
         cSql3+="   AND SD2.D2_COD='"+SQL2->D3_COD+"' AND SD2.D2_LOCAL='"+cLoca+"' AND SD2.D2_CLIENTE='"+SQL2->D3_FORNE+"' AND SD2.D2_LOJA='"+SQL2->D3_LOJA+"' "
         cSql3+="   AND SD2.D2_DOC='"+SQL2->D3_DOC+"' AND SD2.D2_SERIE='"+SQL2->D3_SERIE+"' AND SD2.D_E_L_E_T_<>'*' "
         TcSqlExec(cSql3)
         TcSqlExec("Commit")
      Endif
      SQL2->(dbSkip())   
   Enddo
   SQL2->(dbCloseArea())
   SQL1->(dbCloseArea())
   
   SB2->(dbSkip())
Enddo

End Transaction 

SB2->(dbCloseArea())
Return  
