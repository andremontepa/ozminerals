#Include "rwmake.ch"
#Include "Protheus.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AXSZ4     � Autor � Toni Aguiar        � Data �  08/12/2016 ���
�������������������������������������������������������������������������͹��
���Descricao � Apontamento das produ��es                                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAATF                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

//-- Estrutura do array aCmp  = { Campo , valor do campo }
//-- Elemento 1 - Nome do campo
//-- Elemento 2 - Valor do campo 

User Function AXSZ4(lExecAuto,aCmp,nOpcao)
	Local   lExec     := If(lExecAuto==Nil, .F., .T.)			// identifica se vem atravez de ExecAuto ou n�o.
	Private cFilSZ3   := If(lExecAuto, aCmp[01][02], xFilial("SZ3"))
	Private cFilSZ4   := If(lExecAuto, aCmp[01][02], xFilial("SZ4"))
	Private cCadastro := "Apontamento das produ��es"
	Private aCores := { {'Z4_MVTO=="1"', 'ENABLE'   },;	    // Produ��o
	{'Z4_MVTO=="2"', 'BR_AZUL'   },;	// Amplia��o
	{'Z4_MVTO=="3"', 'BR_VERMELHO'} }	// Redu��o
	Private aLegenda :={ {"ENABLE"     , "Apontamento de produ��o" },;
		{"BR_AZUL"    , "Apontamento de uma nova medi��o de Amplia��o"},;
		{"BR_VERMELHO", "Apontamento de uma nova medi��o de Redu��o"  } }
	Private aRotina   := { {"Pesquisar","AxPesqui",0,1} ,;
		{"Visualizar","AxVisual",0,2} ,;
		{"Incluir" ,"U_AxIncSZ4",0,3} ,;
		{"Alterar" ,"",0,4} ,;   				//"AxAltera",0,4} ,;
		{"Excluir" ,"U_AxDelSZ4",0,5},;
		{"&Legenda",'U_VerLege(cCadastro, aLegenda)' , 0, 3 } }

	Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock
	Private cAlias := "SZ4"

	dbSelectArea("SZ4")
	dbSetOrder(1)

	If lExec .And. nOpcao==3		// Inclus�o autom�tica
		U_AxIncSZ4(,,,aCmp)
	ElseIf lExec .And. nOpcao==5 	// Exclus�o autom�tica
		U_AxDelSZ4(,,,aCmp)
	Else
		mBrowse( 6,1,22,75,cAlias,,,,,,aCores)
	Endif
Return

//--
//-- Fun��o de inclus�o do registro das movimenta��es
User Function AxIncSZ4(cAlias,nReg,cOpc,aCmp)
	Local nInclui
	Local lExecAuto:=If(ValType(aCmp)=="A", .T., .F.)
	Local _i
	If !lExecAuto

		nInclui:=AxInclui("SZ4",nReg,cOpc,,,,"u_AxVldSZ4()")
		If nInclui==1
			//Atualiza o per�odo
			RecLock("SZ4",.F.)
			SZ4->Z4_ESTIMA := POSICIONE("SZ3",1,xFilial("SZ4")+SZ4->Z4_COD,"Z3_ESTIMA")
			If SZ4->Z4_MVTO="2"
				SZ4->Z4_SANT   := POSICIONE("SZ3",1,xFilial("SZ3")+SZ4->Z4_COD,"Z3_SALDO") - SZ4->Z4_PROD
				SZ4->Z4_SALDO  := SZ4->(Z4_SANT+Z4_PROD)
			Else
				SZ4->Z4_SANT   := POSICIONE("SZ3",1,xFilial("SZ3")+SZ4->Z4_COD,"Z3_SALDO") + SZ4->Z4_PROD
				SZ4->Z4_SALDO  := SZ4->(Z4_SANT-Z4_PROD)
			Endif
			SZ4->(MsUnLock())
		Endif
	Else
		// Valida Processos
		For _i:=1 To Len(aCmp)
			&("M->"+aCmp[_i][1]) := aCmp[_i][2]
		Next

		// Inclui o registro automaticamente
		If !SZ4->(dbSeek(cFilSZ4+M->(Z4_COD+Z4_MEANO+Z4_MVTO)))
			If !u_AxVldSZ4(.T.)
				Return
			Endif

			RecLock("SZ4",.T.)
			For _i:=1 To Len(aCmp)
				&("SZ4->"+aCmp[_i][1]) := aCmp[_i][2]
			Next
			SZ4->Z4_ESTIMA := POSICIONE("SZ3",1,cFilSZ3+SZ4->Z4_COD,"Z3_ESTIMA")
			SZ4->Z4_SANT   := POSICIONE("SZ3",1,cFilSZ3+SZ4->Z4_COD,"Z3_SALDO") + SZ4->Z4_PROD
			SZ4->Z4_SALDO  := SZ4->(Z4_SANT-Z4_PROD)
			SZ4->(MsUnLock())
		Endif
	Endif
Return

//--
//-- Fun��o de valida��o da inclus�o do registro de Movimenta��o
User Function AxVldSZ4(lAuto)
	Local cMesAno:=Left(DTOS(SuperGetMv("MV_ULTDEPR")),6)
	Local cMes   :=Substr(DTOS(SuperGetMv("MV_ULTDEPR")),5,2)
	Local cAno   :=Left(DTOS(SuperGetMv("MV_ULTDEPR")),4)

	lAuto:=If(lAuto=Nil, .F., lAuto)
	cAno:=If(cMes="12", Str(Val(cAno)+1, 4), cAno)
	cMes:=If(cMes="12", "01", Strzero(Val(cMes)+1,2))
	cFilSZ3:=If(!lAuto, xFilial("SZ3"), cFilSZ3)

	If !lAuto				// Se n�o foi chamado por uma execauto
		If M->Z4_MVTO=="1"   // Valida o apontamento de produ��o.
			Alert("Esta op��o s� � permitida atrav�s da rotina de apontamento de produ��o. (AATF001)")
			Return .F.
		Endif
	Endif

	dbSelectArea("SZ3")
	SZ3->(dbSetOrder(1))
	If SZ3->(dbSeek(cFilSZ3+M->Z4_COD))
		If !Empty(SZ3->Z3_STATUS)
			MsgBox("Esta opera��o n�o poder� ser conclu�da, pois esta classifica��o estimada j� foi finalizada.")
			Return .F.
		Endif
		//-
		//- Documentado por Toni Aguiar - TOTVS STARSOFT
		//- Em 06/05/2020
		//If M->Z4_PROD > SZ3->Z3_SALDO
		//   Alert("Imposs�vel efetuar esta opera��o, pois a unidade produzida � maior que o saldo estimado!")
		//   Return .F.
		//Endif
		If (cAno+cMes)<>M->Z4_MEANO
			Alert("Per�odo Inv�lido, o �ltimo fechamento foi em "+DTOC(SuperGetMv("MV_ULTDEPR"))+" e o apontamento s� poder� ser feito em: "+cMes+"/"+cAno+". ")
			Return .F.
		Endif

		// Atualiza a tabela de CLASSIFICA��O ESTIMADA
		RecLock("SZ3",.F.)
		If M->Z4_MVTO$"1" // Apontamento de produ��o
			SZ3->Z3_ACM  := SZ3->Z3_ACM + M->Z4_PROD
		ElseIf M->Z4_MVTO$"2"	// Apontamento de amplia��o
			SZ3->Z3_AMPLIA := SZ3->Z3_AMPLIA + M->Z4_PROD
		Else
			SZ3->Z3_REDUCAO:= SZ3->Z3_REDUCAO+ M->Z4_PROD
		Endif
		SZ3->Z3_SALDO:= SZ3->((Z3_ESTIMA+Z3_AMPLIA)-(Z3_ACM+Z3_REDUCAO))
		If SZ3->Z3_SALDO<=0
			SZ3->Z3_STATUS:="E"
		Endif
		SZ3->(MsUnLock())
	Endif
Return .T.

//--
//-- Deleta os registros de movimenta��o
User Function AxDelSZ4(cAlias,nReg,cOpc,aCmp)
	Local lExecAuto:=If(ValType(aCmp)=="A", .T., .F.)
	Local _i

//--
//-- Se a exclus�o for autom�tica
	If lExecAuto
		// Cria as variaveis na mem�ria
		For _i:=1 To Len(aCmp)
			&("M->"+aCmp[_i][1]) := aCmp[_i][2]
		Next

		dbSelectArea("SZ4")
		SZ4->(dbSetOrder(1))
		If SZ4->(dbSeek(cFilSZ4+M->(Z4_COD+Z4_MEANO+Z4_MVTO)))
			dbSelectArea("SZ3")
			SZ3->(dbSetOrder(1))
			If SZ3->(dbSeek(cFilSZ3+SZ4->Z4_COD))

				// Atualiza a tabela das classifica��es estimadas de produ��o
				RecLock("SZ3",.F.)
				SZ3->Z3_ACM   := SZ3->Z3_ACM - SZ4->Z4_PROD
				SZ3->Z3_SALDO := SZ3->((Z3_ESTIMA+Z3_AMPLIA) - (Z3_ACM+Z3_REDUCAO))
				If SZ3->Z3_SALDO>0
					SZ3->Z3_STATUS:=""
				Endif
				SZ3->(MsUnLock())
			Endif

			// Exclui a opera��o
			RecLock("SZ4",.F.)
			SZ4->(dbDelete())
			SZ4->(MsUnLock())
		Else
			Alert("O lan�amento de movimento para estono da produ��o, n�o foi encontrado."+Chr(13)+;
				"Tabela: SZ4, Classifica��o Estimada: "+M->Z4_COD+", Mes e Ano: "+Right(M->Z4_MEANO,2)+"/"+Left(M->Z4_MEANO,4)+". "+Chr(13)+;
				"Informe ao administrador do sistema.")
		Endif
	Else

		If SZ4->Z4_MVTO=="1"	// aprontamento de produ��o
			Alert("Esta op��o s� � permitida atrav�s da rotina de apontamento de produ��o. (AATF001)")
			Return
		Endif

		If MsgYesNo("Confirma a exclus�o desta opera��o?")
			dbSelectArea("SZ3")
			SZ3->(dbSetOrder(1))
			If SZ3->(dbSeek(SZ4->Z4_FILIAL+SZ4->Z4_COD))

				// Atualiza a tabela das classifica��es estimadas de produ��o
				RecLock("SZ3",.F.)
				If SZ4->Z4_MVTO$"2"	// apontamento de amplia��o
					SZ3->Z3_AMPLIA:= SZ3->Z3_AMPLIA - SZ4->Z4_PROD
				ElseIf SZ4->Z4_MVTO$"3"// apontamento de redu��o
					SZ3->Z3_REDUCAO:= SZ3->Z3_REDUCAO - SZ4->Z4_PROD
				Endif
				SZ3->Z3_SALDO := SZ3->((Z3_ESTIMA+Z3_AMPLIA) - (Z3_ACM+Z3_REDUCAO))
				If SZ3->Z3_SALDO>0
					SZ3->Z3_STATUS:=""
				Endif
				SZ3->(MsUnLock())
			Endif

			// Exclui a opera��o
			RecLock("SZ4",.F.)
			SZ4->(dbDelete())
			SZ4->(MsUnLock())
		Endif
	Endif
Return

/*
����������������������������������������������������������������������������
����������������������������������������������������������������������������
������������������������������������������������������������������������Ŀ��
��� Programa � VerLege    � Autor � Toni Aguiar      � Data � 01/06/2017 ���
������������������������������������������������������������������������Ĵ��
��� Funcao   � Exibicao da legenda correspondente as cores disponiveis   ���
�������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������
����������������������������������������������������������������������������
*/
User Function VerLege(cCadastro, aLegenda)
	BrwLegenda(cCadastro,"Legenda",aLegenda)
Return
