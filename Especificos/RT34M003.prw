#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOTVS.CH'

/*/{Protheus.doc} RT34M003
Rotina de calculo do balancete USD.
@type Function
@author Ricardo Tavares Ferreira - rtfconsulsystem@gmail.com
@since  23/03/2021
@version 12.1.25
@history 23/03/2021, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//=============================================================================================================================
	User Function RT34M003()
//=============================================================================================================================

	Local lConfirm      := .F.
    Local oSay          := Nil"
	Local cPerg     	:= "RT34M003"
    Local cDataIni      := ""
    Local cDataFim      := ""

    While .T.
        CriaPar(cPerg)
		If Pergunte(cPerg,.T.)
            lConfirm := .T.
            Exit
		Else
			If MsgNoYes("Foi detectado o cancelamento do preechimento dos parametros. Deseja realmente sair da impressao do Relatorio ( Sim / Nao )?","A T E N C A O !!!")
				Return Nil
			EndIf
		EndIf
	End

    If lConfirm
        cDataIni := Dtos(FirstDate(Stod(Alltrim(MV_PAR01)+"01")))
        cDataFim := Dtos(LastDate(Stod(Alltrim(MV_PAR01)+"01")))

        If Val(Substr(MV_PAR01,1,4)) <= Val("2019")
            MsgInfo("O Processo so podera ser realizado a partir de janeiro de 2020. Este precesso será abortado.","Atenção")
            Return
        EndIf 

        If Val(MV_PAR01) >= Val("202001") .and. Val(MV_PAR01) <= Val("202005") 
            DelReg(Substr(MV_PAR01,5,2),Substr(MV_PAR01,1,4))
            FWMsgRun(,{|oSay| ExecQ01(cDataIni,cDataFim)},"Calculo do Balancete USD","Calculando Balancete USD Ref..: <b>("+Alltrim(MV_PAR01)+")</b>. Aguarde ...")
        ElseIf Val(MV_PAR01) == Val("202006")
            DelReg(Substr(MV_PAR01,5,2),Substr(MV_PAR01,1,4))
            FWMsgRun(,{|oSay| ExecQ02(cDataIni,cDataFim)},"Calculo do Balancete USD","Calculando Balancete USD Ref..: <b>("+Alltrim(MV_PAR01)+")</b>. Aguarde ...")
        ElseIf Val(MV_PAR01) >= Val("202007")
            DelReg(Substr(MV_PAR01,5,2),Substr(MV_PAR01,1,4))
            FWMsgRun(,{|oSay| ExecQ03(cDataIni,cDataFim)},"Calculo do Balancete USD","Calculando Balancete USD Ref..: <b>("+Alltrim(MV_PAR01)+")</b>. Aguarde ...")
        EndIf
    EndIf
Return

/*/{Protheus.doc} ExecQ01
Executa o script entre as datas de 01/2020 e 05/2020.
@type Function
@author Ricardo Tavares Ferreira - rtfconsulsystem@gmail.com
@since  23/03/2021
@version 12.1.25
@param cDataIni, character, Data inicial de referencia para a executar o delete.
@param cDataFim, character, Data Final de referencia para a executar o delete.
@history 23/03/2021, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//====================================================================================================
    Static Function ExecQ01(cDataIni,cDataFim)
//====================================================================================================

    Local cInsert := ""
    Local QbLinha := chr(13)+chr(10)

    cInsert := " INSERT INTO BALUSD (EMP, CODCCUSTO, ITEMCTA, CTA1, DESC_CTA1, CTA2, DESC_CTA2, CTA3, DESC_CTA3, CTA4, DESC_CTA4, CTA5, DESC_CTA5, ANO, MES, SALDOANT, MOVDEBITO, MOVCREDITO, MOVPERIODO, VLRCTA, SALDOFINAL) "+QbLinha 
    cInsert += " SELECT '01' EMP, "+QbLinha 
    cInsert += " 	   Z.CODCCUSTO, "+QbLinha 
    cInsert += " 	   Z.ITEMCTA, "+QbLinha 
    cInsert += " 	   Z.CTA_1, "+QbLinha 
    cInsert += " 	   RTRIM(Z.DESC_CTA1) DESC_CTA1, "+QbLinha 
    cInsert += " 	   Z.CTA_2, "+QbLinha 
    cInsert += " 	   RTRIM(Z.DESC_CTA2) DESC_CTA2, "+QbLinha 
    cInsert += " 	   Z.CTA_3, "+QbLinha 
    cInsert += " 	   RTRIM(Z.DESC_CTA3) DESC_CTA3, "+QbLinha 
    cInsert += " 	   Z.CTA_4, "+QbLinha 
    cInsert += " 	   RTRIM(Z.DESC_CTA4) DESC_CTA4, "+QbLinha 
    cInsert += " 	   RTRIM(Z.CTA_5) CTA_5, "+QbLinha 
    cInsert += " 	   RTRIM(Z.DESC_CTA5) DESC_CTA5, "+QbLinha 
    cInsert += " 	   SUBSTRING('"+cDataIni+"',1,4) ANO, "+QbLinha 
    cInsert += " 	   SUBSTRING('"+cDataIni+"',5,2) MES, "+QbLinha 
    cInsert += " 	   SUM(VLR_SALDOANT) SLD_ANTERIOR, "+QbLinha 
    cInsert += " 	   SUM(VLR_DEBITO) MOV_DEBITO, "+QbLinha 
    cInsert += " 	   SUM(VLR_CREDITO) MOV_CREDITO, "+QbLinha 
    cInsert += " 	   SUM(VLR_MOVPER) MOV_PERIODO, "+QbLinha 
    cInsert += " 	   SUM(VLR_CTA) VLR_CTA, "+QbLinha 
    cInsert += " 	   SUM(VLR_SALDOFINAL) SLD_FINAL "+QbLinha 
    cInsert += " FROM "+QbLinha 
    cInsert += " ( "+QbLinha 
    cInsert += " 	/*CALCULO SALDO ANTERIOR*/ "+QbLinha 
    cInsert += " 	SELECT  "+QbLinha 
    cInsert += " 		   A.CCUSTO CODCCUSTO, "+QbLinha 
    cInsert += " 		   A.ITEMCTA ITEMCTA, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1) CTA_1, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,1)) DESC_CTA1, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1) CTA_2, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,2)) DESC_CTA2, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1)+'.'+SUBSTRING(A.CONTA,3,1)+'.'+SUBSTRING(A.CONTA,4,1) CTA_3, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,4)) DESC_CTA3, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1)+'.'+SUBSTRING(A.CONTA,3,1)+'.'+SUBSTRING(A.CONTA,4,2)+'.'+SUBSTRING(A.CONTA,6,1) CTA_4, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,6)) DESC_CTA4, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1)+'.'+SUBSTRING(A.CONTA,3,1)+'.'+SUBSTRING(A.CONTA,4,2)+'.'+SUBSTRING(A.CONTA,6,4) CTA_5, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = A.CONTA) DESC_CTA5, "+QbLinha 
    cInsert += " 		   CASE "+QbLinha 
    cInsert += " 		   		WHEN (SELECT X.CT1_CVD02 "+QbLinha 
    cInsert += " 		   			  FROM CT1010 X (NOLOCK) "+QbLinha 
    cInsert += " 		   			  WHERE X.D_E_L_E_T_ = '' "+QbLinha 
    cInsert += " 		   			  AND X.CT1_CONTA = A.CONTA) = '3' "+QbLinha 
    cInsert += " 		   		THEN ROUND(((SELECT ISNULL(SUM(W.VALOR),0) "+QbLinha 
    cInsert += " 		   			  FROM VW_BALANCETE W (NOLOCK) "+QbLinha 
    cInsert += " 		   			  WHERE W.DATA < '"+cDataIni+"' "+QbLinha 
    cInsert += " 		   			  AND W.VARCAMBIAL <> 'S' "+QbLinha 
    cInsert += " 		   			  AND W.CONTA = A.CONTA "+QbLinha 
    cInsert += " 		   			  AND W.CCUSTO = A.CCUSTO "+QbLinha 
    cInsert += " 		   			  AND W.ITEMCTA = A.ITEMCTA)/ "+QbLinha 
    cInsert += " 		   			  (SELECT TOP 1 ISNULL(T.ZZ_TAXA,1) "+QbLinha 
    cInsert += " 					   FROM SZZ010 T (NOLOCK) "+QbLinha 
    cInsert += " 					   WHERE CONVERT(DATETIME,T.ZZ_DATA, 102) = DATEADD(DAY, -1, '"+cDataIni+"') "+QbLinha 
    cInsert += " 					   AND T.ZZ_CONTA = A.CONTA)),2) "+QbLinha 
    cInsert += " 				ELSE ROUND(SUM(A.VALOR),2) "+QbLinha 
    cInsert += " 		   END AS VLR_SALDOANT, "+QbLinha 
    cInsert += " 		   0 VLR_DEBITO, "+QbLinha 
    cInsert += " 		   0 VLR_CREDITO, "+QbLinha 
    cInsert += " 		   0 VLR_MOVPER, "+QbLinha 
    cInsert += " 		   0 VLR_CTA, "+QbLinha 
    cInsert += " 		   0 VLR_SALDOFINAL "+QbLinha 
    cInsert += " 	FROM VW_BALANCETE_USD A (NOLOCK) "+QbLinha 
    cInsert += " 	WHERE A.DATA < '"+cDataIni+"' "+QbLinha 
    cInsert += " 	GROUP BY A.CCUSTO, A.ITEMCTA, A.CONTA "+QbLinha 
    cInsert += " 	UNION ALL "+QbLinha 
    cInsert += " 	/*CALCULO MOVIMENTO A DEBITO*/ "+QbLinha 
    cInsert += " 	SELECT  "+QbLinha 
    cInsert += " 		   A.CCUSTO CODCCUSTO, "+QbLinha 
    cInsert += " 		   A.ITEMCTA ITEMCTA, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1) CTA_1, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,1)) DESC_CTA1, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1) CTA_2, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,2)) DESC_CTA2, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1)+'.'+SUBSTRING(A.CONTA,3,1)+'.'+SUBSTRING(A.CONTA,4,1) CTA_3, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,4)) DESC_CTA3, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1)+'.'+SUBSTRING(A.CONTA,3,1)+'.'+SUBSTRING(A.CONTA,4,2)+'.'+SUBSTRING(A.CONTA,6,1) CTA_4, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,6)) DESC_CTA4, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1)+'.'+SUBSTRING(A.CONTA,3,1)+'.'+SUBSTRING(A.CONTA,4,2)+'.'+SUBSTRING(A.CONTA,6,4) CTA_5, "+QbLinha 
    cInsert += " 		   A.DESC_CONTA DESC_CTA5, "+QbLinha 
    cInsert += " 		   0 VLR_SALDOANT, "+QbLinha 
    cInsert += " 		   SUM(A.VALOR) VLR_DEBITO, "+QbLinha 
    cInsert += " 		   0 VLR_CREDITO, "+QbLinha 
    cInsert += " 		   0 VLR_MOVPER, "+QbLinha 
    cInsert += " 		   0 VLR_CTA, "+QbLinha 
    cInsert += " 		   0 VLR_SALDOFINAL "+QbLinha 
    cInsert += " 	FROM VW_BALANCETE_USD A "+QbLinha 
    cInsert += " 	WHERE A.DATA >= '"+cDataIni+"' "+QbLinha 
    cInsert += " 	AND   A.DATA <= '"+cDataFim+"' "+QbLinha 
    cInsert += " 	AND   A.DB = 'D' "+QbLinha 
    cInsert += " 	GROUP BY A.CCUSTO, A.ITEMCTA, A.CONTA, A.DESC_CONTA "+QbLinha 
    cInsert += " 	UNION ALL "+QbLinha 
    cInsert += " 	/*CALCULO MOVIMENTO A CREDITO*/ "+QbLinha 
    cInsert += " 	SELECT  "+QbLinha 
    cInsert += " 		   A.CCUSTO CODCCUSTO, "+QbLinha 
    cInsert += " 		   A.ITEMCTA ITEMCTA, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1) CTA_1, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,1)) DESC_CTA1, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1) CTA_2, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,2)) DESC_CTA2, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1)+'.'+SUBSTRING(A.CONTA,3,1)+'.'+SUBSTRING(A.CONTA,4,1) CTA_3, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,4)) DESC_CTA3, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1)+'.'+SUBSTRING(A.CONTA,3,1)+'.'+SUBSTRING(A.CONTA,4,2)+'.'+SUBSTRING(A.CONTA,6,1) CTA_4, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,6)) DESC_CTA4, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1)+'.'+SUBSTRING(A.CONTA,3,1)+'.'+SUBSTRING(A.CONTA,4,2)+'.'+SUBSTRING(A.CONTA,6,4) CTA_5, "+QbLinha 
    cInsert += " 		   A.DESC_CONTA DESC_CTA5, "+QbLinha 
    cInsert += " 		   0 VLR_SALDOANT, "+QbLinha 
    cInsert += " 		   0 VLR_DEBITO, "+QbLinha 
    cInsert += " 		   SUM(A.VALOR) VLR_CREDITO, "+QbLinha 
    cInsert += " 		   0 VLR_MOVPER, "+QbLinha 
    cInsert += " 		   0 VLR_CTA, "+QbLinha 
    cInsert += " 		   0 VLR_SALDOFINAL "+QbLinha 
    cInsert += " 	FROM VW_BALANCETE_USD A "+QbLinha 
    cInsert += " 	WHERE A.DATA >= '"+cDataIni+"' "+QbLinha 
    cInsert += " 	AND   A.DATA <= '"+cDataFim+"' "+QbLinha 
    cInsert += " 	AND   A.DB = 'C' "+QbLinha 
    cInsert += " 	GROUP BY A.CCUSTO, A.ITEMCTA, A.CONTA, A.DESC_CONTA "+QbLinha 
    cInsert += " 	UNION ALL "+QbLinha 
    cInsert += " 	/*CALCULO MOVIMENTO DO PERIODO*/ "+QbLinha 
    cInsert += " 	SELECT  "+QbLinha 
    cInsert += " 		   A.CCUSTO CODCCUSTO, "+QbLinha 
    cInsert += " 		   A.ITEMCTA ITEMCTA, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1) CTA_1, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,1)) DESC_CTA1, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1) CTA_2, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,2)) DESC_CTA2, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1)+'.'+SUBSTRING(A.CONTA,3,1)+'.'+SUBSTRING(A.CONTA,4,1) CTA_3, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,4)) DESC_CTA3, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1)+'.'+SUBSTRING(A.CONTA,3,1)+'.'+SUBSTRING(A.CONTA,4,2)+'.'+SUBSTRING(A.CONTA,6,1) CTA_4, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,6)) DESC_CTA4, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1)+'.'+SUBSTRING(A.CONTA,3,1)+'.'+SUBSTRING(A.CONTA,4,2)+'.'+SUBSTRING(A.CONTA,6,4) CTA_5, "+QbLinha 
    cInsert += " 		   A.DESC_CONTA DESC_CTA5, "+QbLinha 
    cInsert += " 		   0 VLR_SALDOANT, "+QbLinha 
    cInsert += " 		   0 VLR_DEBITO, "+QbLinha 
    cInsert += " 		   0 VLR_CREDITO, "+QbLinha 
    cInsert += " 		   SUM(A.VALOR) VLR_MOVPER, "+QbLinha 
    cInsert += " 		   0 VLR_CTA, "+QbLinha 
    cInsert += " 		   0 VLR_SALDOFINAL "+QbLinha 
    cInsert += " 	FROM VW_BALANCETE_USD A "+QbLinha 
    cInsert += " 	WHERE A.DATA >= '"+cDataIni+"' "+QbLinha 
    cInsert += " 	AND   A.DATA <= '"+cDataFim+"' "+QbLinha 
    cInsert += " 	GROUP BY A.CCUSTO, A.ITEMCTA, A.CONTA, A.DESC_CONTA "+QbLinha 
    cInsert += " 	UNION ALL "+QbLinha 
    cInsert += " 	/*CALCULO VALOR COLUNA CTA*/ "+QbLinha 
    cInsert += " 		SELECT  "+QbLinha 
    cInsert += " 		   A.CCUSTO CODCCUSTO, "+QbLinha 
    cInsert += " 		   A.ITEMCTA ITEMCTA, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1) CTA_1, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,1)) DESC_CTA1, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1) CTA_2, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,2)) DESC_CTA2, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1)+'.'+SUBSTRING(A.CONTA,3,1)+'.'+SUBSTRING(A.CONTA,4,1) CTA_3, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,4)) DESC_CTA3, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1)+'.'+SUBSTRING(A.CONTA,3,1)+'.'+SUBSTRING(A.CONTA,4,2)+'.'+SUBSTRING(A.CONTA,6,1) CTA_4, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,6)) DESC_CTA4, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1)+'.'+SUBSTRING(A.CONTA,3,1)+'.'+SUBSTRING(A.CONTA,4,2)+'.'+SUBSTRING(A.CONTA,6,4) CTA_5, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = A.CONTA) DESC_CTA5, "+QbLinha 
    cInsert += " 		   0 VLR_SALDOANT, "+QbLinha 
    cInsert += " 		   0 VLR_DEBITO, "+QbLinha 
    cInsert += " 		   0 VLR_CREDITO, "+QbLinha 
    cInsert += " 		   0 VLR_MOVPER, "+QbLinha 
    cInsert += " 		   CASE "+QbLinha 
    cInsert += " 		   		WHEN (SELECT SUM(K.VALOR) "+QbLinha 
    cInsert += " 		   			  FROM VW_BALANCETE_USD K  "+QbLinha 
    cInsert += " 		   			  WHERE K.DATA >= '"+cDataIni+"'  "+QbLinha 
    cInsert += " 		   			  AND K.DATA <= '"+cDataFim+"'  "+QbLinha 
    cInsert += " 		   			  AND K.CONTA = A.CONTA) = 0 "+QbLinha 
    cInsert += " 		   		THEN 0 "+QbLinha 
    cInsert += " 		   		WHEN (SELECT X.CT1_CVD02 "+QbLinha 
    cInsert += " 		   			  FROM CT1010 X (NOLOCK) "+QbLinha 
    cInsert += " 		   			  WHERE X.D_E_L_E_T_ = '' "+QbLinha 
    cInsert += " 		   			  AND X.CT1_CONTA = A.CONTA) = '3' "+QbLinha 
    cInsert += " 		   		THEN ROUND(((SELECT ISNULL(SUM(W.VALOR),0) "+QbLinha 
    cInsert += " 		   			  FROM VW_BALANCETE W (NOLOCK) "+QbLinha 
    cInsert += " 		   			  WHERE W.DATA <= '"+cDataFim+"' "+QbLinha 
    cInsert += " 		   			  AND W.VARCAMBIAL <> 'S' "+QbLinha 
    cInsert += " 		   			  AND W.CONTA = A.CONTA "+QbLinha 
    cInsert += " 		   			  AND W.CCUSTO = A.CCUSTO "+QbLinha 
    cInsert += " 		   			  AND W.ITEMCTA = A.ITEMCTA)/ "+QbLinha 
    cInsert += " 		   			  (SELECT TOP 1 ISNULL(T.ZZ_TAXA,1) "+QbLinha 
    cInsert += " 					   FROM SZZ010 T (NOLOCK) "+QbLinha 
    cInsert += " 					   WHERE T.ZZ_DATA = '"+cDataFim+"' "+QbLinha 
    cInsert += " 					   AND T.ZZ_CONTA = A.CONTA)),2) "+QbLinha 
    cInsert += " 					   - "+QbLinha 
    cInsert += " 		   			  (ROUND(((SELECT ISNULL(SUM(W.VALOR),0) "+QbLinha 
    cInsert += " 		   			  FROM VW_BALANCETE W (NOLOCK) "+QbLinha 
    cInsert += " 		   			  WHERE W.DATA < '"+cDataIni+"' "+QbLinha 
    cInsert += " 		   			  AND W.VARCAMBIAL <> 'S' "+QbLinha 
    cInsert += " 		   			  AND W.CONTA = A.CONTA "+QbLinha 
    cInsert += " 		   			  AND W.CCUSTO = A.CCUSTO "+QbLinha 
    cInsert += " 		   			  AND W.ITEMCTA = A.ITEMCTA)/ "+QbLinha 
    cInsert += " 		   			  (SELECT TOP 1 ISNULL(T.ZZ_TAXA,1) "+QbLinha 
    cInsert += " 					   FROM SZZ010 T (NOLOCK) "+QbLinha 
    cInsert += " 					   WHERE CONVERT(DATETIME,T.ZZ_DATA, 102) = DATEADD(DAY, -1, '"+cDataIni+"') "+QbLinha 
    cInsert += " 					   AND T.ZZ_CONTA = A.CONTA)),2) "+QbLinha 
    cInsert += " 					   + "+QbLinha 
    cInsert += " 					  ROUND(ISNULL((SELECT SUM(K.VALOR) "+QbLinha 
    cInsert += " 					   		 FROM VW_BALANCETE_USD K "+QbLinha 
    cInsert += " 					  		 WHERE K.DATA >= '"+cDataIni+"' "+QbLinha 
    cInsert += " 					  		 AND   K.DATA <= '"+cDataFim+"' "+QbLinha 
    cInsert += " 					  		 AND   K.CONTA = A.CONTA "+QbLinha 
    cInsert += " 				   			 AND   K.CCUSTO =A.CCUSTO "+QbLinha 
    cInsert += " 				   			 AND   K.ITEMCTA = A.ITEMCTA),0),2)) "+QbLinha 
    cInsert += " 				ELSE 0 "+QbLinha 
    cInsert += " 		   END AS VLR_CTA, "+QbLinha 
    cInsert += " 		   0 VLR_SALDOFINAL "+QbLinha 
    cInsert += " 	FROM VW_BALANCETE_USD A (NOLOCK) "+QbLinha 
    cInsert += " 	WHERE A.DATA <= '"+cDataFim+"' "+QbLinha 
    cInsert += " 	GROUP BY A.CCUSTO, A.ITEMCTA, A.CONTA "+QbLinha 
    cInsert += " 	UNION ALL "+QbLinha 
    cInsert += " 	/*CALCULO SALDO FINAL*/ "+QbLinha 
    cInsert += " 	SELECT A.CCUSTO CODCCUSTO, "+QbLinha 
    cInsert += " 		   A.ITEMCTA ITEMCTA, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1) CTA_1, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,1)) DESC_CTA1, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1) CTA_2, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,2)) DESC_CTA2, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1)+'.'+SUBSTRING(A.CONTA,3,1)+'.'+SUBSTRING(A.CONTA,4,1) CTA_3, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,4)) DESC_CTA3, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1)+'.'+SUBSTRING(A.CONTA,3,1)+'.'+SUBSTRING(A.CONTA,4,2)+'.'+SUBSTRING(A.CONTA,6,1) CTA_4, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,6)) DESC_CTA4, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1)+'.'+SUBSTRING(A.CONTA,3,1)+'.'+SUBSTRING(A.CONTA,4,2)+'.'+SUBSTRING(A.CONTA,6,4) CTA_5, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = A.CONTA) DESC_CTA5, "+QbLinha 
    cInsert += " 		   0 VLR_SALDOANT, "+QbLinha 
    cInsert += " 		   0 VLR_DEBITO, "+QbLinha 
    cInsert += " 		   0 VLR_CREDITO, "+QbLinha 
    cInsert += " 		   0 VLR_MOVPER, "+QbLinha 
    cInsert += " 		   0 VLR_CTA, "+QbLinha 
    cInsert += " 		   CASE "+QbLinha 
    cInsert += " 		   		WHEN (SELECT X.CT1_CVD02 "+QbLinha 
    cInsert += " 		   			  FROM CT1010 X (NOLOCK) "+QbLinha 
    cInsert += " 		   			  WHERE X.D_E_L_E_T_ = '' "+QbLinha 
    cInsert += " 		   			  AND X.CT1_CONTA = A.CONTA) = '3' "+QbLinha 
    cInsert += " 		   		THEN ROUND(((SELECT ISNULL(SUM(W.VALOR),0) "+QbLinha 
    cInsert += " 		   			  FROM VW_BALANCETE W (NOLOCK) "+QbLinha 
    cInsert += " 		   			  WHERE W.DATA <= '"+cDataFim+"' "+QbLinha 
    cInsert += " 		   			  AND W.VARCAMBIAL <> 'S' "+QbLinha 
    cInsert += " 		   			  AND W.CONTA = A.CONTA "+QbLinha 
    cInsert += " 		   			  AND W.CCUSTO = A.CCUSTO "+QbLinha 
    cInsert += " 		   			  AND W.ITEMCTA = A.ITEMCTA)/ "+QbLinha 
    cInsert += " 		   			  (SELECT TOP 1 ISNULL(T.ZZ_TAXA,1) "+QbLinha 
    cInsert += " 					   FROM SZZ010 T (NOLOCK) "+QbLinha 
    cInsert += " 					   WHERE T.ZZ_DATA = '"+cDataFim+"' "+QbLinha 
    cInsert += " 					   AND T.ZZ_CONTA = A.CONTA)),2) "+QbLinha 
    cInsert += " 				ELSE ROUND(SUM(A.VALOR),2) "+QbLinha 
    cInsert += " 		   END AS VLR_SALDOFINAL "+QbLinha 
    cInsert += " 	FROM VW_BALANCETE_USD A (NOLOCK) "+QbLinha 
    cInsert += " 	WHERE A.DATA <= '"+cDataFim+"' "+QbLinha 
    cInsert += " 	GROUP BY A.CCUSTO, A.ITEMCTA, A.CONTA "+QbLinha 
    cInsert += " ) Z "+QbLinha 
    cInsert += " GROUP BY Z.CODCCUSTO, Z.ITEMCTA, Z.CTA_1, Z.DESC_CTA1, Z.CTA_2, Z.DESC_CTA2, Z.CTA_3, Z.DESC_CTA3, Z.CTA_4, Z.DESC_CTA4, Z.CTA_5, Z.DESC_CTA5 "+QbLinha 
    cInsert += " ORDER BY Z.CODCCUSTO, Z.ITEMCTA, Z.CTA_1, Z.CTA_2, Z.CTA_3, Z.CTA_4, Z.CTA_5 "+QbLinha 

    MemoWrite("C:/ricardo/ExecQ01.sql",cInsert)	

    If (TcSqlExec(cInsert) < 0)
		Aviso("RT34R002","Erro na Insercao dos Registros. Erro SQL: "+Alltrim(TCSQLError()),{"Fechar"},1)
	EndIf
Return Nil

/*/{Protheus.doc} ExecQ02
Executa o script da referencia 06/2020.
@type Function
@author Ricardo Tavares Ferreira - rtfconsulsystem@gmail.com
@since  23/03/2021
@version 12.1.25
@param cDataIni, character, Data inicial de referencia para a executar o delete.
@param cDataFim, character, Data Final de referencia para a executar o delete.
@history 23/03/2021, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//====================================================================================================
    Static Function ExecQ02(cDataIni,cDataFim)
//====================================================================================================

    Local cInsert := ""
    Local QbLinha := chr(13)+chr(10)

    cInsert := " INSERT INTO BALUSD (EMP, CODCCUSTO, ITEMCTA, CTA1, DESC_CTA1, CTA2, DESC_CTA2, CTA3, DESC_CTA3, CTA4, DESC_CTA4, CTA5, DESC_CTA5, ANO, MES, SALDOANT, MOVDEBITO, MOVCREDITO, MOVPERIODO, VLRCTA, SALDOFINAL) "+QbLinha 
    cInsert += " SELECT '01' EMP, "+QbLinha 
    cInsert += " 	   Z.CODCCUSTO, "+QbLinha 
    cInsert += " 	   Z.ITEMCTA, "+QbLinha 
    cInsert += " 	   Z.CTA_1, "+QbLinha 
    cInsert += " 	   RTRIM(Z.DESC_CTA1) DESC_CTA1, "+QbLinha 
    cInsert += " 	   Z.CTA_2, "+QbLinha 
    cInsert += " 	   RTRIM(Z.DESC_CTA2) DESC_CTA2, "+QbLinha 
    cInsert += " 	   Z.CTA_3, "+QbLinha 
    cInsert += " 	   RTRIM(Z.DESC_CTA3) DESC_CTA3, "+QbLinha 
    cInsert += " 	   Z.CTA_4, "+QbLinha 
    cInsert += " 	   RTRIM(Z.DESC_CTA4) DESC_CTA4, "+QbLinha 
    cInsert += " 	   RTRIM(Z.CTA_5) CTA_5, "+QbLinha 
    cInsert += " 	   RTRIM(Z.DESC_CTA5) DESC_CTA5, "+QbLinha 
    cInsert += " 	   SUBSTRING('"+cDataIni+"',1,4) ANO, "+QbLinha 
    cInsert += " 	   SUBSTRING('"+cDataIni+"',5,2) MES, "+QbLinha 
    cInsert += " 	   SUM(VLR_SALDOANT) SLD_ANTERIOR, "+QbLinha 
    cInsert += " 	   SUM(VLR_DEBITO) MOV_DEBITO, "+QbLinha 
    cInsert += " 	   SUM(VLR_CREDITO) MOV_CREDITO, "+QbLinha 
    cInsert += " 	   SUM(VLR_MOVPER) MOV_PERIODO, "+QbLinha 
    cInsert += " 	   SUM(VLR_CTA) VLR_CTA, "+QbLinha 
    cInsert += " 	   SUM(VLR_SALDOFINAL) SLD_FINAL "+QbLinha 
    cInsert += " FROM "+QbLinha 
    cInsert += " ( "+QbLinha 
    cInsert += " 	/*CALCULO SALDO ANTERIOR*/ "+QbLinha 
    cInsert += " 	SELECT  "+QbLinha 
    cInsert += " 		   A.CCUSTO CODCCUSTO, "+QbLinha 
    cInsert += " 		   A.ITEMCTA ITEMCTA, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1) CTA_1, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,1)) DESC_CTA1, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1) CTA_2, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,2)) DESC_CTA2, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1)+'.'+SUBSTRING(A.CONTA,3,1)+'.'+SUBSTRING(A.CONTA,4,1) CTA_3, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,4)) DESC_CTA3, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1)+'.'+SUBSTRING(A.CONTA,3,1)+'.'+SUBSTRING(A.CONTA,4,2)+'.'+SUBSTRING(A.CONTA,6,1) CTA_4, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,6)) DESC_CTA4, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1)+'.'+SUBSTRING(A.CONTA,3,1)+'.'+SUBSTRING(A.CONTA,4,2)+'.'+SUBSTRING(A.CONTA,6,4) CTA_5, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = A.CONTA) DESC_CTA5, "+QbLinha 
    cInsert += " 		   CASE "+QbLinha 
    cInsert += " 		   		WHEN (SELECT X.CT1_CVD02 "+QbLinha 
    cInsert += " 		   			  FROM CT1010 X (NOLOCK) "+QbLinha 
    cInsert += " 		   			  WHERE X.D_E_L_E_T_ = '' "+QbLinha 
    cInsert += " 		   			  AND X.CT1_CONTA = A.CONTA) = '3' "+QbLinha 
    cInsert += " 		   		THEN ROUND(((SELECT ISNULL(SUM(W.VALOR),0) "+QbLinha 
    cInsert += " 		   			  FROM VW_BALANCETE W (NOLOCK) "+QbLinha 
    cInsert += " 		   			  WHERE W.DATA < '"+cDataIni+"' "+QbLinha 
    cInsert += " 		   			  AND W.CONTA = A.CONTA "+QbLinha 
    cInsert += " 		   			  AND W.CCUSTO = A.CCUSTO "+QbLinha 
    cInsert += " 		   			  AND W.ITEMCTA = A.ITEMCTA)/ "+QbLinha 
    cInsert += " 		   			  (SELECT TOP 1 ISNULL(T.ZZ_TAXA,1) "+QbLinha 
    cInsert += " 					   FROM SZZ010 T (NOLOCK) "+QbLinha 
    cInsert += " 					   WHERE CONVERT(DATETIME,T.ZZ_DATA, 102) = DATEADD(DAY, -1, '"+cDataIni+"') "+QbLinha 
    cInsert += " 					   AND T.ZZ_CONTA = A.CONTA)),2) "+QbLinha 
    cInsert += " 				ELSE ROUND(SUM(A.VALOR),2) "+QbLinha 
    cInsert += " 		   END AS VLR_SALDOANT, "+QbLinha 
    cInsert += " 		   0 VLR_DEBITO, "+QbLinha 
    cInsert += " 		   0 VLR_CREDITO, "+QbLinha 
    cInsert += " 		   0 VLR_MOVPER, "+QbLinha 
    cInsert += " 		   0 VLR_CTA, "+QbLinha 
    cInsert += " 		   0 VLR_SALDOFINAL "+QbLinha 
    cInsert += " 	FROM VW_BALANCETE_USD A (NOLOCK) "+QbLinha 
    cInsert += " 	WHERE A.DATA < '"+cDataIni+"' "+QbLinha 
    cInsert += " 	GROUP BY A.CCUSTO, A.ITEMCTA, A.CONTA "+QbLinha 
    cInsert += " 	UNION ALL "+QbLinha 
    cInsert += " 	/*CALCULO MOVIMENTO A DEBITO*/ "+QbLinha 
    cInsert += " 	SELECT  "+QbLinha 
    cInsert += " 		   A.CCUSTO CODCCUSTO, "+QbLinha 
    cInsert += " 		   A.ITEMCTA ITEMCTA, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1) CTA_1, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,1)) DESC_CTA1, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1) CTA_2, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,2)) DESC_CTA2, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1)+'.'+SUBSTRING(A.CONTA,3,1)+'.'+SUBSTRING(A.CONTA,4,1) CTA_3, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,4)) DESC_CTA3, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1)+'.'+SUBSTRING(A.CONTA,3,1)+'.'+SUBSTRING(A.CONTA,4,2)+'.'+SUBSTRING(A.CONTA,6,1) CTA_4, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,6)) DESC_CTA4, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1)+'.'+SUBSTRING(A.CONTA,3,1)+'.'+SUBSTRING(A.CONTA,4,2)+'.'+SUBSTRING(A.CONTA,6,4) CTA_5, "+QbLinha 
    cInsert += " 		   A.DESC_CONTA DESC_CTA5, "+QbLinha 
    cInsert += " 		   0 VLR_SALDOANT, "+QbLinha 
    cInsert += " 		   SUM(A.VALOR) VLR_DEBITO, "+QbLinha 
    cInsert += " 		   0 VLR_CREDITO, "+QbLinha 
    cInsert += " 		   0 VLR_MOVPER, "+QbLinha 
    cInsert += " 		   0 VLR_CTA, "+QbLinha 
    cInsert += " 		   0 VLR_SALDOFINAL "+QbLinha 
    cInsert += " 	FROM VW_BALANCETE_USD A "+QbLinha 
    cInsert += " 	WHERE A.DATA >= '"+cDataIni+"' "+QbLinha 
    cInsert += " 	AND   A.DATA <= '"+cDataFim+"' "+QbLinha 
    cInsert += " 	AND   A.DB = 'D' "+QbLinha 
    cInsert += " 	GROUP BY A.CCUSTO, A.ITEMCTA, A.CONTA, A.DESC_CONTA "+QbLinha 
    cInsert += " 	UNION ALL "+QbLinha 
    cInsert += " 	/*CALCULO MOVIMENTO A CREDITO*/ "+QbLinha 
    cInsert += " 	SELECT  "+QbLinha 
    cInsert += " 		   A.CCUSTO CODCCUSTO, "+QbLinha 
    cInsert += " 		   A.ITEMCTA ITEMCTA, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1) CTA_1, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,1)) DESC_CTA1, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1) CTA_2, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,2)) DESC_CTA2, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1)+'.'+SUBSTRING(A.CONTA,3,1)+'.'+SUBSTRING(A.CONTA,4,1) CTA_3, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,4)) DESC_CTA3, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1)+'.'+SUBSTRING(A.CONTA,3,1)+'.'+SUBSTRING(A.CONTA,4,2)+'.'+SUBSTRING(A.CONTA,6,1) CTA_4, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,6)) DESC_CTA4, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1)+'.'+SUBSTRING(A.CONTA,3,1)+'.'+SUBSTRING(A.CONTA,4,2)+'.'+SUBSTRING(A.CONTA,6,4) CTA_5, "+QbLinha 
    cInsert += " 		   A.DESC_CONTA DESC_CTA5, "+QbLinha 
    cInsert += " 		   0 VLR_SALDOANT, "+QbLinha 
    cInsert += " 		   0 VLR_DEBITO, "+QbLinha 
    cInsert += " 		   SUM(A.VALOR) VLR_CREDITO, "+QbLinha 
    cInsert += " 		   0 VLR_MOVPER, "+QbLinha 
    cInsert += " 		   0 VLR_CTA, "+QbLinha 
    cInsert += " 		   0 VLR_SALDOFINAL "+QbLinha 
    cInsert += " 	FROM VW_BALANCETE_USD A "+QbLinha 
    cInsert += " 	WHERE A.DATA >= '"+cDataIni+"' "+QbLinha 
    cInsert += " 	AND   A.DATA <= '"+cDataFim+"' "+QbLinha 
    cInsert += " 	AND   A.DB = 'C' "+QbLinha 
    cInsert += " 	GROUP BY A.CCUSTO, A.ITEMCTA, A.CONTA, A.DESC_CONTA "+QbLinha 
    cInsert += " 	UNION ALL "+QbLinha 
    cInsert += " 	/*CALCULO MOVIMENTO DO PERIODO*/ "+QbLinha 
    cInsert += " 	SELECT  "+QbLinha 
    cInsert += " 		   A.CCUSTO CODCCUSTO, "+QbLinha 
    cInsert += " 		   A.ITEMCTA ITEMCTA, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1) CTA_1, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,1)) DESC_CTA1, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1) CTA_2, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,2)) DESC_CTA2, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1)+'.'+SUBSTRING(A.CONTA,3,1)+'.'+SUBSTRING(A.CONTA,4,1) CTA_3, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,4)) DESC_CTA3, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1)+'.'+SUBSTRING(A.CONTA,3,1)+'.'+SUBSTRING(A.CONTA,4,2)+'.'+SUBSTRING(A.CONTA,6,1) CTA_4, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,6)) DESC_CTA4, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1)+'.'+SUBSTRING(A.CONTA,3,1)+'.'+SUBSTRING(A.CONTA,4,2)+'.'+SUBSTRING(A.CONTA,6,4) CTA_5, "+QbLinha 
    cInsert += " 		   A.DESC_CONTA DESC_CTA5, "+QbLinha 
    cInsert += " 		   0 VLR_SALDOANT, "+QbLinha 
    cInsert += " 		   0 VLR_DEBITO, "+QbLinha 
    cInsert += " 		   0 VLR_CREDITO, "+QbLinha 
    cInsert += " 		   SUM(A.VALOR) VLR_MOVPER, "+QbLinha 
    cInsert += " 		   0 VLR_CTA, "+QbLinha 
    cInsert += " 		   0 VLR_SALDOFINAL "+QbLinha 
    cInsert += " 	FROM VW_BALANCETE_USD A "+QbLinha 
    cInsert += " 	WHERE A.DATA >= '"+cDataIni+"' "+QbLinha 
    cInsert += " 	AND   A.DATA <= '"+cDataFim+"' "+QbLinha 
    cInsert += " 	GROUP BY A.CCUSTO, A.ITEMCTA, A.CONTA, A.DESC_CONTA "+QbLinha 
    cInsert += " 	UNION ALL "+QbLinha 
    cInsert += " 	/*CALCULO VALOR COLUNA CTA*/ "+QbLinha 
    cInsert += " 		SELECT  "+QbLinha 
    cInsert += " 		   A.CCUSTO CODCCUSTO, "+QbLinha 
    cInsert += " 		   A.ITEMCTA ITEMCTA, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1) CTA_1, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,1)) DESC_CTA1, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1) CTA_2, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,2)) DESC_CTA2, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1)+'.'+SUBSTRING(A.CONTA,3,1)+'.'+SUBSTRING(A.CONTA,4,1) CTA_3, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,4)) DESC_CTA3, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1)+'.'+SUBSTRING(A.CONTA,3,1)+'.'+SUBSTRING(A.CONTA,4,2)+'.'+SUBSTRING(A.CONTA,6,1) CTA_4, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,6)) DESC_CTA4, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1)+'.'+SUBSTRING(A.CONTA,3,1)+'.'+SUBSTRING(A.CONTA,4,2)+'.'+SUBSTRING(A.CONTA,6,4) CTA_5, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = A.CONTA) DESC_CTA5, "+QbLinha 
    cInsert += " 		   0 VLR_SALDOANT, "+QbLinha 
    cInsert += " 		   0 VLR_DEBITO, "+QbLinha 
    cInsert += " 		   0 VLR_CREDITO, "+QbLinha 
    cInsert += " 		   0 VLR_MOVPER, "+QbLinha 
    cInsert += " 		   CASE "+QbLinha 
    cInsert += " 		   		WHEN (SELECT SUM(K.VALOR) "+QbLinha 
    cInsert += " 		   			  FROM VW_BALANCETE_USD K  "+QbLinha 
    cInsert += " 		   			  WHERE K.DATA >= '"+cDataIni+"' "+QbLinha 
    cInsert += " 		   			  AND K.DATA <= '"+cDataFim+"' "+QbLinha 
    cInsert += " 		   			  AND K.CONTA = A.CONTA) = 0 "+QbLinha 
    cInsert += " 		   		THEN 0 "+QbLinha 
    cInsert += " 		   		WHEN (SELECT X.CT1_CVD02 "+QbLinha 
    cInsert += " 		   			  FROM CT1010 X (NOLOCK) "+QbLinha 
    cInsert += " 		   			  WHERE X.D_E_L_E_T_ = '' "+QbLinha 
    cInsert += " 		   			  AND X.CT1_CONTA = A.CONTA) = '3' "+QbLinha 
    cInsert += " 		   		THEN ROUND(((SELECT ISNULL(SUM(W.VALOR),0) "+QbLinha 
    cInsert += " 		   			  FROM VW_BALANCETE W (NOLOCK) "+QbLinha 
    cInsert += " 		   			  WHERE W.DATA <= '"+cDataFim+"' "+QbLinha 
    cInsert += " 		   			  AND W.VARCAMBIAL <> 'S' "+QbLinha 
    cInsert += " 		   			  AND W.CONTA = A.CONTA "+QbLinha 
    cInsert += " 		   			  AND W.CCUSTO = A.CCUSTO "+QbLinha 
    cInsert += " 		   			  AND W.ITEMCTA = A.ITEMCTA)/ "+QbLinha 
    cInsert += " 		   			  ( "+QbLinha 
    cInsert += " 		   			   SELECT ISNULL(CTP_TAXA,1) FROM CTP010 Y (NOLOCK) "+QbLinha 
    cInsert += " 		   			   WHERE Y.D_E_L_E_T_ = '' "+QbLinha 
    cInsert += " 		   			   AND   Y.CTP_MOEDA = '02' "+QbLinha 
    cInsert += " 		   			   AND   Y.CTP_DATA = (SELECT MAX(CTP_DATA) FROM CTP010 YY (NOLOCK) "+QbLinha 
    cInsert += " 		   			   				       WHERE YY.D_E_L_E_T_ = '' "+QbLinha 
    cInsert += " 		   			   				       AND   SUBSTRING(YY.CTP_DATA,1,6) = SUBSTRING('"+cDataIni+"',1,6) "+QbLinha 
    cInsert += " 		   			   				       AND   YY.CTP_MOEDA = '02') "+QbLinha 
    cInsert += " 	   			 	  )),2) "+QbLinha 
    cInsert += " 					   - "+QbLinha 
    cInsert += " 		   			  (ROUND(((SELECT ISNULL(SUM(W.VALOR),0) "+QbLinha 
    cInsert += " 		   			  FROM VW_BALANCETE W (NOLOCK) "+QbLinha 
    cInsert += " 		   			  WHERE W.DATA < '"+cDataIni+"' "+QbLinha 
    cInsert += " 		   			  AND W.VARCAMBIAL <> 'S' "+QbLinha 
    cInsert += " 		   			  AND W.CONTA = A.CONTA "+QbLinha 
    cInsert += " 		   			  AND W.CCUSTO = A.CCUSTO "+QbLinha 
    cInsert += " 		   			  AND W.ITEMCTA = A.ITEMCTA)/ "+QbLinha 
    cInsert += " 		   			  (SELECT TOP 1 ISNULL(T.ZZ_TAXA,1) "+QbLinha 
    cInsert += " 					   FROM SZZ010 T (NOLOCK) "+QbLinha 
    cInsert += " 					   WHERE CONVERT(DATETIME,T.ZZ_DATA, 102) = DATEADD(DAY, -1, '"+cDataIni+"') "+QbLinha 
    cInsert += " 					   AND T.ZZ_CONTA = A.CONTA)),2) "+QbLinha 
    cInsert += " 					   + "+QbLinha 
    cInsert += " 					  ROUND(ISNULL((SELECT SUM(K.VALOR) "+QbLinha 
    cInsert += " 					   		 FROM VW_BALANCETE_USD K "+QbLinha 
    cInsert += " 					  		 WHERE K.DATA >= '"+cDataIni+"' "+QbLinha 
    cInsert += " 					  		 AND   K.DATA <= '"+cDataFim+"' "+QbLinha 
    cInsert += " 					  		 AND   K.CONTA = A.CONTA "+QbLinha 
    cInsert += " 				   			 AND   K.CCUSTO =A.CCUSTO "+QbLinha 
    cInsert += " 				   			 AND   K.ITEMCTA = A.ITEMCTA),0),2)) "+QbLinha 
    cInsert += " 				ELSE 0 "+QbLinha 
    cInsert += " 		   END AS VLR_CTA, "+QbLinha 
    cInsert += " 		   0 VLR_SALDOFINAL "+QbLinha 
    cInsert += " 	FROM VW_BALANCETE_USD A (NOLOCK) "+QbLinha 
    cInsert += " 	WHERE A.DATA <= '"+cDataFim+"' "+QbLinha 
    cInsert += " 	GROUP BY A.CCUSTO, A.ITEMCTA, A.CONTA "+QbLinha 
    cInsert += " 	UNION ALL "+QbLinha 
    cInsert += " 	/*CALCULO SALDO FINAL*/ "+QbLinha 
    cInsert += " 	SELECT A.CCUSTO CODCCUSTO, "+QbLinha 
    cInsert += " 		   A.ITEMCTA ITEMCTA, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1) CTA_1, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,1)) DESC_CTA1, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1) CTA_2, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,2)) DESC_CTA2, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1)+'.'+SUBSTRING(A.CONTA,3,1)+'.'+SUBSTRING(A.CONTA,4,1) CTA_3, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,4)) DESC_CTA3, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1)+'.'+SUBSTRING(A.CONTA,3,1)+'.'+SUBSTRING(A.CONTA,4,2)+'.'+SUBSTRING(A.CONTA,6,1) CTA_4, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,6)) DESC_CTA4, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1)+'.'+SUBSTRING(A.CONTA,3,1)+'.'+SUBSTRING(A.CONTA,4,2)+'.'+SUBSTRING(A.CONTA,6,4) CTA_5, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = A.CONTA) DESC_CTA5, "+QbLinha 
    cInsert += " 		   0 VLR_SALDOANT, "+QbLinha 
    cInsert += " 		   0 VLR_DEBITO, "+QbLinha 
    cInsert += " 		   0 VLR_CREDITO, "+QbLinha 
    cInsert += " 		   0 VLR_MOVPER, "+QbLinha 
    cInsert += " 		   0 VLR_CTA, "+QbLinha 
    cInsert += " 		   CASE "+QbLinha 
    cInsert += " 		   		WHEN (SELECT X.CT1_CVD02 "+QbLinha 
    cInsert += " 		   			  FROM CT1010 X (NOLOCK) "+QbLinha 
    cInsert += " 		   			  WHERE X.D_E_L_E_T_ = '' "+QbLinha 
    cInsert += " 		   			  AND X.CT1_CONTA = A.CONTA) = '3' "+QbLinha 
    cInsert += " 		   		THEN ROUND(((SELECT ISNULL(SUM(W.VALOR),0) "+QbLinha 
    cInsert += " 		   			  FROM VW_BALANCETE W (NOLOCK) "+QbLinha 
    cInsert += " 		   			  WHERE W.DATA <= '"+cDataFim+"' "+QbLinha 
    cInsert += " 		   			  AND W.VARCAMBIAL <> 'S' "+QbLinha 
    cInsert += " 		   			  AND W.CONTA = A.CONTA "+QbLinha 
    cInsert += " 		   			  AND W.CCUSTO = A.CCUSTO "+QbLinha 
    cInsert += " 		   			  AND W.ITEMCTA = A.ITEMCTA)/ "+QbLinha 
    cInsert += " 		   			  ( "+QbLinha 
    cInsert += " 		   			   SELECT ISNULL(CTP_TAXA,1) FROM CTP010 Y (NOLOCK) "+QbLinha 
    cInsert += " 		   			   WHERE Y.D_E_L_E_T_ = '' "+QbLinha 
    cInsert += " 		   			   AND   Y.CTP_MOEDA = '02' "+QbLinha 
    cInsert += " 		   			   AND   Y.CTP_DATA = (SELECT MAX(CTP_DATA) FROM CTP010 YY (NOLOCK) "+QbLinha 
    cInsert += " 		   			   				       WHERE YY.D_E_L_E_T_ = '' "+QbLinha 
    cInsert += " 		   			   				       AND   SUBSTRING(YY.CTP_DATA,1,6) = SUBSTRING('"+cDataIni+"',1,6) "+QbLinha 
    cInsert += " 		   			   				       AND   YY.CTP_MOEDA = '02') "+QbLinha 
    cInsert += " 		   			  )),2) "+QbLinha 
    cInsert += " 				ELSE ROUND(SUM(A.VALOR),2) "+QbLinha 
    cInsert += " 		   END AS VLR_SALDOFINAL "+QbLinha 
    cInsert += " 	FROM VW_BALANCETE_USD A (NOLOCK) "+QbLinha 
    cInsert += " 	WHERE A.DATA <= '"+cDataFim+"' "+QbLinha 
    cInsert += " 	GROUP BY A.CCUSTO, A.ITEMCTA, A.CONTA "+QbLinha 
    cInsert += " ) Z "+QbLinha 
    cInsert += " GROUP BY Z.CODCCUSTO, Z.ITEMCTA, Z.CTA_1, Z.DESC_CTA1, Z.CTA_2, Z.DESC_CTA2, Z.CTA_3, Z.DESC_CTA3, Z.CTA_4, Z.DESC_CTA4, Z.CTA_5, Z.DESC_CTA5 "+QbLinha 
    cInsert += " ORDER BY Z.CODCCUSTO, Z.ITEMCTA, Z.CTA_1, Z.CTA_2, Z.CTA_3, Z.CTA_4, Z.CTA_5 "+QbLinha 

    MemoWrite("C:/ricardo/ExecQ02.sql",cInsert)	

    If (TcSqlExec(cInsert) < 0)
		Aviso("RT34R002","Erro na Insercao dos Registros. Erro SQL: "+Alltrim(TCSQLError()),{"Fechar"},1)
	EndIf
Return Nil

/*/{Protheus.doc} ExecQ03
Executa o script da referencia igual ou maior que 07/2020.
@type Function
@author Ricardo Tavares Ferreira - rtfconsulsystem@gmail.com
@since  23/03/2021
@version 12.1.25
@param cDataIni, character, Data inicial de referencia para a executar o delete.
@param cDataFim, character, Data Final de referencia para a executar o delete.
@history 23/03/2021, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//====================================================================================================
    Static Function ExecQ03(cDataIni,cDataFim)
//====================================================================================================

    Local cInsert := ""
    Local QbLinha := chr(13)+chr(10)

    cInsert += " INSERT INTO BALUSD (EMP, CODCCUSTO, ITEMCTA, CTA1, DESC_CTA1, CTA2, DESC_CTA2, CTA3, DESC_CTA3, CTA4, DESC_CTA4, CTA5, DESC_CTA5, ANO, MES, SALDOANT, MOVDEBITO, MOVCREDITO, MOVPERIODO, VLRCTA, SALDOFINAL) "+QbLinha 
    cInsert += " SELECT '01' EMP, "+QbLinha 
    cInsert += " 	   Z.CODCCUSTO, "+QbLinha 
    cInsert += " 	   Z.ITEMCTA, "+QbLinha 
    cInsert += " 	   Z.CTA_1, "+QbLinha 
    cInsert += " 	   RTRIM(Z.DESC_CTA1) DESC_CTA1, "+QbLinha 
    cInsert += " 	   Z.CTA_2, "+QbLinha 
    cInsert += " 	   RTRIM(Z.DESC_CTA2) DESC_CTA2, "+QbLinha 
    cInsert += " 	   Z.CTA_3, "+QbLinha 
    cInsert += " 	   RTRIM(Z.DESC_CTA3) DESC_CTA3, "+QbLinha 
    cInsert += " 	   Z.CTA_4, "+QbLinha 
    cInsert += " 	   RTRIM(Z.DESC_CTA4) DESC_CTA4, "+QbLinha 
    cInsert += " 	   RTRIM(Z.CTA_5) CTA_5, "+QbLinha 
    cInsert += " 	   RTRIM(Z.DESC_CTA5) DESC_CTA5, "+QbLinha 
    cInsert += " 	   SUBSTRING('"+cDataIni+"',1,4) ANO, "+QbLinha 
    cInsert += " 	   SUBSTRING('"+cDataIni+"',5,2) MES, "+QbLinha 
    cInsert += " 	   SUM(VLR_SALDOANT) SLD_ANTERIOR, "+QbLinha 
    cInsert += " 	   SUM(VLR_DEBITO) MOV_DEBITO, "+QbLinha 
    cInsert += " 	   SUM(VLR_CREDITO) MOV_CREDITO, "+QbLinha 
    cInsert += " 	   SUM(VLR_MOVPER) MOV_PERIODO, "+QbLinha 
    cInsert += " 	   SUM(VLR_CTA) VLR_CTA, "+QbLinha 
    cInsert += " 	   SUM(VLR_SALDOFINAL) SLD_FINAL "+QbLinha 
    cInsert += " FROM "+QbLinha 
    cInsert += " ( "+QbLinha 
    cInsert += " 	/*CALCULO SALDO ANTERIOR*/ "+QbLinha 
    cInsert += " 	SELECT  "+QbLinha 
    cInsert += " 		   A.CCUSTO CODCCUSTO, "+QbLinha 
    cInsert += " 		   A.ITEMCTA ITEMCTA, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1) CTA_1, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,1)) DESC_CTA1, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1) CTA_2, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,2)) DESC_CTA2, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1)+'.'+SUBSTRING(A.CONTA,3,1)+'.'+SUBSTRING(A.CONTA,4,1) CTA_3, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,4)) DESC_CTA3, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1)+'.'+SUBSTRING(A.CONTA,3,1)+'.'+SUBSTRING(A.CONTA,4,2)+'.'+SUBSTRING(A.CONTA,6,1) CTA_4, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,6)) DESC_CTA4, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1)+'.'+SUBSTRING(A.CONTA,3,1)+'.'+SUBSTRING(A.CONTA,4,2)+'.'+SUBSTRING(A.CONTA,6,4) CTA_5, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = A.CONTA) DESC_CTA5, "+QbLinha 
    cInsert += " 		   CASE "+QbLinha 
    cInsert += " 		   		WHEN (SELECT X.CT1_CVD02 "+QbLinha 
    cInsert += " 		   			  FROM CT1010 X (NOLOCK) "+QbLinha 
    cInsert += " 		   			  WHERE X.D_E_L_E_T_ = '' "+QbLinha 
    cInsert += " 		   			  AND X.CT1_CONTA = A.CONTA) = '3' "+QbLinha 
    cInsert += " 		   		THEN ROUND(((SELECT ISNULL(SUM(W.VALOR),0) "+QbLinha 
    cInsert += " 		   			  FROM VW_BALANCETE W (NOLOCK) "+QbLinha 
    cInsert += " 		   			  WHERE W.DATA < '"+cDataIni+"' "+QbLinha 
    cInsert += " 		   			  AND W.CONTA = A.CONTA "+QbLinha 
    cInsert += " 		   			  AND W.CCUSTO = A.CCUSTO "+QbLinha 
    cInsert += " 		   			  AND W.ITEMCTA = A.ITEMCTA)/ "+QbLinha 
    cInsert += " 		   			  ( "+QbLinha 
    cInsert += " 		   			   SELECT ISNULL(T.CTP_TAXA,1) FROM CTP010 T "+QbLinha 
    cInsert += " 		   			   WHERE T.D_E_L_E_T_ = '' "+QbLinha 
    cInsert += " 		   			   AND   T.CTP_MOEDA = '02' "+QbLinha 
    cInsert += " 		   			   AND   T.CTP_DATA = (SELECT DATEADD(DAY, -1, (CONVERT(DATETIME,(MIN(TT.CTP_DATA)), 102))) FROM CTP010 TT "+QbLinha 
    cInsert += " 		   			   				       WHERE TT.D_E_L_E_T_ = '' "+QbLinha 
    cInsert += " 		   			   				       AND SUBSTRING(TT.CTP_DATA,1,6) = SUBSTRING('"+cDataIni+"',1,6) "+QbLinha 
    cInsert += " 		   			   				       AND TT.CTP_MOEDA = '02'))),2) "+QbLinha 
    cInsert += " 				ELSE ROUND(SUM(A.VALOR),2) "+QbLinha 
    cInsert += " 		   END AS VLR_SALDOANT, "+QbLinha 
    cInsert += " 		   0 VLR_DEBITO, "+QbLinha 
    cInsert += " 		   0 VLR_CREDITO, "+QbLinha 
    cInsert += " 		   0 VLR_MOVPER, "+QbLinha 
    cInsert += " 		   0 VLR_CTA, "+QbLinha 
    cInsert += " 		   0 VLR_SALDOFINAL "+QbLinha 
    cInsert += " 	FROM VW_BALANCETE_USD A (NOLOCK) "+QbLinha 
    cInsert += " 	WHERE A.DATA < '"+cDataIni+"' "+QbLinha 
    cInsert += " 	GROUP BY A.CCUSTO, A.ITEMCTA, A.CONTA "+QbLinha 
    cInsert += " 	UNION ALL "+QbLinha 
    cInsert += " 	/*CALCULO MOVIMENTO A DEBITO*/ "+QbLinha 
    cInsert += " 	SELECT  "+QbLinha 
    cInsert += " 		   A.CCUSTO CODCCUSTO, "+QbLinha 
    cInsert += " 		   A.ITEMCTA ITEMCTA, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1) CTA_1, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,1)) DESC_CTA1, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1) CTA_2, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,2)) DESC_CTA2, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1)+'.'+SUBSTRING(A.CONTA,3,1)+'.'+SUBSTRING(A.CONTA,4,1) CTA_3, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,4)) DESC_CTA3, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1)+'.'+SUBSTRING(A.CONTA,3,1)+'.'+SUBSTRING(A.CONTA,4,2)+'.'+SUBSTRING(A.CONTA,6,1) CTA_4, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,6)) DESC_CTA4, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1)+'.'+SUBSTRING(A.CONTA,3,1)+'.'+SUBSTRING(A.CONTA,4,2)+'.'+SUBSTRING(A.CONTA,6,4) CTA_5, "+QbLinha 
    cInsert += " 		   A.DESC_CONTA DESC_CTA5, "+QbLinha 
    cInsert += " 		   0 VLR_SALDOANT, "+QbLinha 
    cInsert += " 		   SUM(A.VALOR) VLR_DEBITO, "+QbLinha 
    cInsert += " 		   0 VLR_CREDITO, "+QbLinha 
    cInsert += " 		   0 VLR_MOVPER, "+QbLinha 
    cInsert += " 		   0 VLR_CTA, "+QbLinha 
    cInsert += " 		   0 VLR_SALDOFINAL "+QbLinha 
    cInsert += " 	FROM VW_BALANCETE_USD A "+QbLinha 
    cInsert += " 	WHERE A.DATA >= '"+cDataIni+"' "+QbLinha 
    cInsert += " 	AND   A.DATA <= '"+cDataFim+"' "+QbLinha 
    cInsert += " 	AND   A.DB = 'D' "+QbLinha 
    cInsert += " 	GROUP BY A.CCUSTO, A.ITEMCTA, A.CONTA, A.DESC_CONTA "+QbLinha 
    cInsert += " 	UNION ALL "+QbLinha 
    cInsert += " 	/*CALCULO MOVIMENTO A CREDITO*/ "+QbLinha 
    cInsert += " 	SELECT  "+QbLinha 
    cInsert += " 		   A.CCUSTO CODCCUSTO, "+QbLinha 
    cInsert += " 		   A.ITEMCTA ITEMCTA, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1) CTA_1, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,1)) DESC_CTA1, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1) CTA_2, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,2)) DESC_CTA2, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1)+'.'+SUBSTRING(A.CONTA,3,1)+'.'+SUBSTRING(A.CONTA,4,1) CTA_3, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,4)) DESC_CTA3, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1)+'.'+SUBSTRING(A.CONTA,3,1)+'.'+SUBSTRING(A.CONTA,4,2)+'.'+SUBSTRING(A.CONTA,6,1) CTA_4, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,6)) DESC_CTA4, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1)+'.'+SUBSTRING(A.CONTA,3,1)+'.'+SUBSTRING(A.CONTA,4,2)+'.'+SUBSTRING(A.CONTA,6,4) CTA_5, "+QbLinha 
    cInsert += " 		   A.DESC_CONTA DESC_CTA5, "+QbLinha 
    cInsert += " 		   0 VLR_SALDOANT, "+QbLinha 
    cInsert += " 		   0 VLR_DEBITO, "+QbLinha 
    cInsert += " 		   SUM(A.VALOR) VLR_CREDITO, "+QbLinha 
    cInsert += " 		   0 VLR_MOVPER, "+QbLinha 
    cInsert += " 		   0 VLR_CTA, "+QbLinha 
    cInsert += " 		   0 VLR_SALDOFINAL "+QbLinha 
    cInsert += " 	FROM VW_BALANCETE_USD A "+QbLinha 
    cInsert += " 	WHERE A.DATA >= '"+cDataIni+"' "+QbLinha 
    cInsert += " 	AND   A.DATA <= '"+cDataFim+"' "+QbLinha 
    cInsert += " 	AND   A.DB = 'C' "+QbLinha 
    cInsert += " 	GROUP BY A.CCUSTO, A.ITEMCTA, A.CONTA, A.DESC_CONTA "+QbLinha 
    cInsert += " 	UNION ALL "+QbLinha 
    cInsert += " 	/*CALCULO MOVIMENTO DO PERIODO*/ "+QbLinha 
    cInsert += " 	SELECT  "+QbLinha 
    cInsert += " 		   A.CCUSTO CODCCUSTO, "+QbLinha 
    cInsert += " 		   A.ITEMCTA ITEMCTA, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1) CTA_1, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,1)) DESC_CTA1, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1) CTA_2, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,2)) DESC_CTA2, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1)+'.'+SUBSTRING(A.CONTA,3,1)+'.'+SUBSTRING(A.CONTA,4,1) CTA_3, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,4)) DESC_CTA3, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1)+'.'+SUBSTRING(A.CONTA,3,1)+'.'+SUBSTRING(A.CONTA,4,2)+'.'+SUBSTRING(A.CONTA,6,1) CTA_4, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,6)) DESC_CTA4, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1)+'.'+SUBSTRING(A.CONTA,3,1)+'.'+SUBSTRING(A.CONTA,4,2)+'.'+SUBSTRING(A.CONTA,6,4) CTA_5, "+QbLinha 
    cInsert += " 		   A.DESC_CONTA DESC_CTA5, "+QbLinha 
    cInsert += " 		   0 VLR_SALDOANT, "+QbLinha 
    cInsert += " 		   0 VLR_DEBITO, "+QbLinha 
    cInsert += " 		   0 VLR_CREDITO, "+QbLinha 
    cInsert += " 		   SUM(A.VALOR) VLR_MOVPER, "+QbLinha 
    cInsert += " 		   0 VLR_CTA, "+QbLinha 
    cInsert += " 		   0 VLR_SALDOFINAL "+QbLinha 
    cInsert += " 	FROM VW_BALANCETE_USD A "+QbLinha 
    cInsert += " 	WHERE A.DATA >= '"+cDataIni+"' "+QbLinha 
    cInsert += " 	AND   A.DATA <= '"+cDataFim+"' "+QbLinha 
    cInsert += " 	GROUP BY A.CCUSTO, A.ITEMCTA, A.CONTA, A.DESC_CONTA "+QbLinha 
    cInsert += " 	UNION ALL "+QbLinha 
    cInsert += " 	/*CALCULO VALOR COLUNA CTA*/ "+QbLinha 
    cInsert += " 		SELECT  "+QbLinha 
    cInsert += " 		   A.CCUSTO CODCCUSTO, "+QbLinha 
    cInsert += " 		   A.ITEMCTA ITEMCTA, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1) CTA_1, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,1)) DESC_CTA1, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1) CTA_2, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,2)) DESC_CTA2, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1)+'.'+SUBSTRING(A.CONTA,3,1)+'.'+SUBSTRING(A.CONTA,4,1) CTA_3, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,4)) DESC_CTA3, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1)+'.'+SUBSTRING(A.CONTA,3,1)+'.'+SUBSTRING(A.CONTA,4,2)+'.'+SUBSTRING(A.CONTA,6,1) CTA_4, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,6)) DESC_CTA4, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1)+'.'+SUBSTRING(A.CONTA,3,1)+'.'+SUBSTRING(A.CONTA,4,2)+'.'+SUBSTRING(A.CONTA,6,4) CTA_5, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = A.CONTA) DESC_CTA5, "+QbLinha 
    cInsert += " 		   0 VLR_SALDOANT, "+QbLinha 
    cInsert += " 		   0 VLR_DEBITO, "+QbLinha 
    cInsert += " 		   0 VLR_CREDITO, "+QbLinha 
    cInsert += " 		   0 VLR_MOVPER, "+QbLinha 
    cInsert += " 		   CASE "+QbLinha 
    cInsert += " 		   		/*WHEN (SELECT SUM(K.VALOR) "+QbLinha 
    cInsert += " 		   			  FROM VW_BALANCETE_USD K  "+QbLinha 
    cInsert += " 		   			  WHERE K.DATA >= '"+cDataIni+"' "+QbLinha 
    cInsert += " 		   			  AND K.DATA <= '"+cDataFim+"' "+QbLinha 
    cInsert += " 		   			  AND K.CONTA = A.CONTA) = 0 "+QbLinha 
    cInsert += " 		   		THEN 0*/ "+QbLinha 
    cInsert += " 		   		WHEN (SELECT X.CT1_CVD02 "+QbLinha 
    cInsert += " 		   			  FROM CT1010 X (NOLOCK) "+QbLinha 
    cInsert += " 		   			  WHERE X.D_E_L_E_T_ = '' "+QbLinha 
    cInsert += " 		   			  AND X.CT1_CONTA = A.CONTA) = '3' "+QbLinha 
    cInsert += " 		   		THEN ROUND(((SELECT ISNULL(SUM(W.VALOR),0) "+QbLinha 
    cInsert += " 		   			  FROM VW_BALANCETE W (NOLOCK) "+QbLinha 
    cInsert += " 		   			  WHERE W.DATA <= '"+cDataFim+"' "+QbLinha 
    cInsert += " 		   			  AND W.VARCAMBIAL <> 'S' "+QbLinha 
    cInsert += " 		   			  AND W.CONTA = A.CONTA "+QbLinha 
    cInsert += " 		   			  AND W.CCUSTO = A.CCUSTO "+QbLinha 
    cInsert += " 		   			  AND W.ITEMCTA = A.ITEMCTA)/ "+QbLinha 
    cInsert += " 		   			  ( "+QbLinha 
    cInsert += " 		   			   SELECT ISNULL(CTP_TAXA,1) FROM CTP010 Y (NOLOCK) "+QbLinha 
    cInsert += " 		   			   WHERE Y.D_E_L_E_T_ = '' "+QbLinha 
    cInsert += " 		   			   AND   Y.CTP_MOEDA = '02' "+QbLinha 
    cInsert += " 		   			   AND   Y.CTP_DATA = (SELECT MAX(CTP_DATA) FROM CTP010 YY (NOLOCK) "+QbLinha 
    cInsert += " 		   			   				       WHERE YY.D_E_L_E_T_ = '' "+QbLinha 
    cInsert += " 		   			   				       AND   SUBSTRING(YY.CTP_DATA,1,6) = SUBSTRING('"+cDataIni+"',1,6) "+QbLinha 
    cInsert += " 		   			   				       AND   YY.CTP_MOEDA = '02') "+QbLinha 
    cInsert += " 	   			 	  )),2) "+QbLinha 
    cInsert += " 					   - "+QbLinha 
    cInsert += " 		   			  (ROUND(((SELECT ISNULL(SUM(W.VALOR),0) "+QbLinha 
    cInsert += " 		   			  FROM VW_BALANCETE W (NOLOCK) "+QbLinha 
    cInsert += " 		   			  WHERE W.DATA < '"+cDataIni+"' "+QbLinha 
    cInsert += " 		   			  AND W.CONTA = A.CONTA "+QbLinha 
    cInsert += " 		   			  AND W.CCUSTO = A.CCUSTO "+QbLinha 
    cInsert += " 		   			  AND W.ITEMCTA = A.ITEMCTA)/ "+QbLinha 
    cInsert += " 		   			  ( "+QbLinha 
    cInsert += " 		   			   SELECT ISNULL(T.CTP_TAXA,1) FROM CTP010 T "+QbLinha 
    cInsert += " 		   			   WHERE T.D_E_L_E_T_ = '' "+QbLinha 
    cInsert += " 		   			   AND   T.CTP_MOEDA = '02' "+QbLinha 
    cInsert += " 		   			   AND   T.CTP_DATA = (SELECT DATEADD(DAY, -1, (CONVERT(DATETIME,(MIN(TT.CTP_DATA)), 102))) FROM CTP010 TT "+QbLinha 
    cInsert += " 		   			   				       WHERE TT.D_E_L_E_T_ = '' "+QbLinha 
    cInsert += " 		   			   				       AND SUBSTRING(TT.CTP_DATA,1,6) = SUBSTRING('"+cDataIni+"',1,6) "+QbLinha 
    cInsert += " 		   			   				       AND TT.CTP_MOEDA = '02') "+QbLinha 
    cInsert += " 		   			   )),2) "+QbLinha 
    cInsert += " 					   + "+QbLinha 
    cInsert += " 					  ROUND(ISNULL((SELECT SUM(K.VALOR) "+QbLinha 
    cInsert += " 					   		 FROM VW_BALANCETE_USD K "+QbLinha 
    cInsert += " 					  		 WHERE K.DATA >= '"+cDataIni+"' "+QbLinha 
    cInsert += " 					  		 AND   K.DATA <= '"+cDataFim+"' "+QbLinha 
    cInsert += " 					  		 AND   K.CONTA = A.CONTA "+QbLinha 
    cInsert += " 				   			 AND   K.CCUSTO = A.CCUSTO "+QbLinha 
    cInsert += " 				   			 AND   K.ITEMCTA = A.ITEMCTA),0),2)) "+QbLinha 
    cInsert += " 				ELSE 0 "+QbLinha 
    cInsert += " 		   END AS VLR_CTA, "+QbLinha 
    cInsert += " 		   0 VLR_SALDOFINAL "+QbLinha 
    cInsert += " 	FROM VW_BALANCETE_USD A (NOLOCK) "+QbLinha 
    cInsert += " 	WHERE A.DATA <= '"+cDataFim+"' "+QbLinha 
    cInsert += " 	GROUP BY A.CCUSTO, A.ITEMCTA, A.CONTA "+QbLinha 
    cInsert += " 	UNION ALL "+QbLinha 
    cInsert += " 	/*CALCULO SALDO FINAL*/ "+QbLinha 
    cInsert += " 	SELECT A.CCUSTO CODCCUSTO, "+QbLinha 
    cInsert += " 		   A.ITEMCTA ITEMCTA, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1) CTA_1, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,1)) DESC_CTA1, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1) CTA_2, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,2)) DESC_CTA2, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1)+'.'+SUBSTRING(A.CONTA,3,1)+'.'+SUBSTRING(A.CONTA,4,1) CTA_3, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,4)) DESC_CTA3, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1)+'.'+SUBSTRING(A.CONTA,3,1)+'.'+SUBSTRING(A.CONTA,4,2)+'.'+SUBSTRING(A.CONTA,6,1) CTA_4, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = SUBSTRING(A.CONTA,1,6)) DESC_CTA4, "+QbLinha 
    cInsert += " 		   SUBSTRING(A.CONTA,1,1)+'.'+SUBSTRING(A.CONTA,2,1)+'.'+SUBSTRING(A.CONTA,3,1)+'.'+SUBSTRING(A.CONTA,4,2)+'.'+SUBSTRING(A.CONTA,6,4) CTA_5, "+QbLinha 
    cInsert += " 		   (SELECT X.CT1_DESC01 FROM CT1010 X (NOLOCK) WHERE X.D_E_L_E_T_ = '' AND X.CT1_CONTA = A.CONTA) DESC_CTA5, "+QbLinha 
    cInsert += " 		   0 VLR_SALDOANT, "+QbLinha 
    cInsert += " 		   0 VLR_DEBITO, "+QbLinha 
    cInsert += " 		   0 VLR_CREDITO, "+QbLinha 
    cInsert += " 		   0 VLR_MOVPER, "+QbLinha 
    cInsert += " 		   0 VLR_CTA, "+QbLinha 
    cInsert += " 		   CASE "+QbLinha 
    cInsert += " 		   		WHEN (SELECT X.CT1_CVD02 "+QbLinha 
    cInsert += " 		   			  FROM CT1010 X (NOLOCK) "+QbLinha 
    cInsert += " 		   			  WHERE X.D_E_L_E_T_ = '' "+QbLinha 
    cInsert += " 		   			  AND X.CT1_CONTA = A.CONTA) = '3' "+QbLinha 
    cInsert += " 		   		THEN ROUND(((SELECT ISNULL(SUM(W.VALOR),0) "+QbLinha 
    cInsert += " 		   			  FROM VW_BALANCETE W (NOLOCK) "+QbLinha 
    cInsert += " 		   			  WHERE W.DATA <= '"+cDataFim+"' "+QbLinha 
    cInsert += " 		   			  AND W.VARCAMBIAL <> 'S' "+QbLinha 
    cInsert += " 		   			  AND W.CONTA = A.CONTA "+QbLinha 
    cInsert += " 		   			  AND W.CCUSTO = A.CCUSTO "+QbLinha 
    cInsert += " 		   			  AND W.ITEMCTA = A.ITEMCTA)/ "+QbLinha 
    cInsert += " 		   			  ( "+QbLinha 
    cInsert += " 		   			   SELECT ISNULL(CTP_TAXA,1) FROM CTP010 Y (NOLOCK) "+QbLinha 
    cInsert += " 		   			   WHERE Y.D_E_L_E_T_ = '' "+QbLinha 
    cInsert += " 		   			   AND   Y.CTP_MOEDA = '02' "+QbLinha 
    cInsert += " 		   			   AND   Y.CTP_DATA = (SELECT MAX(CTP_DATA) FROM CTP010 YY (NOLOCK) "+QbLinha 
    cInsert += " 		   			   				       WHERE YY.D_E_L_E_T_ = '' "+QbLinha 
    cInsert += " 		   			   				       AND   SUBSTRING(YY.CTP_DATA,1,6) = SUBSTRING('"+cDataIni+"',1,6) "+QbLinha 
    cInsert += " 		   			   				       AND   YY.CTP_MOEDA = '02') "+QbLinha 
    cInsert += " 		   			  )),2) "+QbLinha 
    cInsert += " 				ELSE ROUND(SUM(A.VALOR),2) "+QbLinha 
    cInsert += " 		   END AS VLR_SALDOFINAL "+QbLinha 
    cInsert += " 	FROM VW_BALANCETE_USD A (NOLOCK) "+QbLinha 
    cInsert += " 	WHERE A.DATA <= '"+cDataFim+"' "+QbLinha 
    cInsert += " 	GROUP BY A.CCUSTO, A.ITEMCTA, A.CONTA "+QbLinha 
    cInsert += " ) Z "+QbLinha 
    cInsert += " GROUP BY Z.CODCCUSTO, Z.ITEMCTA, Z.CTA_1, Z.DESC_CTA1, Z.CTA_2, Z.DESC_CTA2, Z.CTA_3, Z.DESC_CTA3, Z.CTA_4, Z.DESC_CTA4, Z.CTA_5, Z.DESC_CTA5 "+QbLinha 
    cInsert += " ORDER BY Z.CODCCUSTO, Z.ITEMCTA, Z.CTA_1, Z.CTA_2, Z.CTA_3, Z.CTA_4, Z.CTA_5 "+QbLinha

    MemoWrite("C:/ricardo/ExecQ03.sql",cInsert)	

    If (TcSqlExec(cInsert) < 0)
		Aviso("RT34R002","Erro na Insercao dos Registros. Erro SQL: "+Alltrim(TCSQLError()),{"Fechar"},1)
	EndIf
Return Nil

/*/{Protheus.doc} DelReg
Deleta os registros da tabela antes de incluir novamente.
@type Function
@author Ricardo Tavares Ferreira - rtfconsulsystem@gmail.com
@since  23/03/2021
@version 12.1.25
@param cMes, character, Mes de referencia para a executar o delete.
@param cAno, character, Ano de referencia para a executar o delete.
@history 23/03/2021, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//====================================================================================================
    Static Function DelReg(cMes,cAno)
//====================================================================================================

    Local cDel      := ""
    Local QbLinha	:= chr(13)+chr(10)

    cDel := " DELETE FROM BALUSD "+QbLinha
    cDel += " WHERE ANO = '"+cAno+"' "+QbLinha
    cDel += " AND MES = '"+cMes+"' "+QbLinha

    If (TcSqlExec(cDel) < 0)
		Aviso("RT34R002","Erro na Delecao dos Registros. Erro SQL: "+Alltrim(TCSQLError()),{"Fechar"},1)
	EndIf
Return 

/*/{Protheus.doc} CriaPar
Ajusta os parametros das perguntas na tabela SX1.
@type Function
@author Ricardo Tavares Ferreira - rtfconsulsystem@gmail.com
@since  23/03/2021
@version 12.1.25
@param cPerg, character, Código do grupo de perguntas cadastradas na tabela SX1.
@history 23/03/2021, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//====================================================================================================
    Static Function CriaPar(cPerg)
//====================================================================================================

    Local aTam		:= {}
	Local aHelpPor	:= {}

    aTam 		:= TamSX3("CR_APROV")
	aHelpPor 	:= {}
	aAdd(aHelpPor,"Informe a referencia para execucao." ) 
    aAdd(aHelpPor,"Devera ser informado no formato AAAAMM" ) 
	U_xPutSx1(cPerg,"01","Data Inicial" ,"","","MV_CH1",aTam[3],aTam[1],aTam[2],0,"G","","","","","MV_PAR01","","","","","","","","","","","","","","","","",aHelpPor,{},{}) 

Return nil
