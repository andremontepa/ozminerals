#Include "rwmake.ch"
#Include "Protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AXSZ4     º Autor ³ Toni Aguiar        º Data ³  08/12/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Apontamento das produções                                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAATF                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

//-- Estrutura do array aCmp  = { Campo , valor do campo }
//-- Elemento 1 - Nome do campo
//-- Elemento 2 - Valor do campo 

User Function AXSZ4(lExecAuto,aCmp,nOpcao)
	Local   lExec     := If(lExecAuto==Nil, .F., .T.)			// identifica se vem atravez de ExecAuto ou não.
	Private cFilSZ3   := If(lExecAuto, aCmp[01][02], xFilial("SZ3"))
	Private cFilSZ4   := If(lExecAuto, aCmp[01][02], xFilial("SZ4"))
	Private cCadastro := "Apontamento das produções"
	Private aCores := { {'Z4_MVTO=="1"', 'ENABLE'   },;	    // Produção
	{'Z4_MVTO=="2"', 'BR_AZUL'   },;	// Ampliação
	{'Z4_MVTO=="3"', 'BR_VERMELHO'} }	// Redução
	Private aLegenda :={ {"ENABLE"     , "Apontamento de produção" },;
		{"BR_AZUL"    , "Apontamento de uma nova medição de Ampliação"},;
		{"BR_VERMELHO", "Apontamento de uma nova medição de Redução"  } }
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

	If lExec .And. nOpcao==3		// Inclusão automática
		U_AxIncSZ4(,,,aCmp)
	ElseIf lExec .And. nOpcao==5 	// Exclusão automática
		U_AxDelSZ4(,,,aCmp)
	Else
		mBrowse( 6,1,22,75,cAlias,,,,,,aCores)
	Endif
Return

//--
//-- Função de inclusão do registro das movimentações
User Function AxIncSZ4(cAlias,nReg,cOpc,aCmp)
	Local nInclui
	Local lExecAuto:=If(ValType(aCmp)=="A", .T., .F.)
	Local _i
	If !lExecAuto

		nInclui:=AxInclui("SZ4",nReg,cOpc,,,,"u_AxVldSZ4()")
		If nInclui==1
			//Atualiza o período
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
//-- Função de validação da inclusão do registro de Movimentação
User Function AxVldSZ4(lAuto)
	Local cMesAno:=Left(DTOS(SuperGetMv("MV_ULTDEPR")),6)
	Local cMes   :=Substr(DTOS(SuperGetMv("MV_ULTDEPR")),5,2)
	Local cAno   :=Left(DTOS(SuperGetMv("MV_ULTDEPR")),4)

	lAuto:=If(lAuto=Nil, .F., lAuto)
	cAno:=If(cMes="12", Str(Val(cAno)+1, 4), cAno)
	cMes:=If(cMes="12", "01", Strzero(Val(cMes)+1,2))
	cFilSZ3:=If(!lAuto, xFilial("SZ3"), cFilSZ3)

	If !lAuto				// Se não foi chamado por uma execauto
		If M->Z4_MVTO=="1"   // Valida o apontamento de produção.
			Alert("Esta opção só é permitida através da rotina de apontamento de produção. (AATF001)")
			Return .F.
		Endif
	Endif

	dbSelectArea("SZ3")
	SZ3->(dbSetOrder(1))
	If SZ3->(dbSeek(cFilSZ3+M->Z4_COD))
		If !Empty(SZ3->Z3_STATUS)
			MsgBox("Esta operação não poderá ser concluída, pois esta classificação estimada já foi finalizada.")
			Return .F.
		Endif
		//-
		//- Documentado por Toni Aguiar - TOTVS STARSOFT
		//- Em 06/05/2020
		//If M->Z4_PROD > SZ3->Z3_SALDO
		//   Alert("Impossível efetuar esta operação, pois a unidade produzida é maior que o saldo estimado!")
		//   Return .F.
		//Endif
		If (cAno+cMes)<>M->Z4_MEANO
			Alert("Período Inválido, o último fechamento foi em "+DTOC(SuperGetMv("MV_ULTDEPR"))+" e o apontamento só poderá ser feito em: "+cMes+"/"+cAno+". ")
			Return .F.
		Endif

		// Atualiza a tabela de CLASSIFICAÇÃO ESTIMADA
		RecLock("SZ3",.F.)
		If M->Z4_MVTO$"1" // Apontamento de produção
			SZ3->Z3_ACM  := SZ3->Z3_ACM + M->Z4_PROD
		ElseIf M->Z4_MVTO$"2"	// Apontamento de ampliação
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
//-- Deleta os registros de movimentação
User Function AxDelSZ4(cAlias,nReg,cOpc,aCmp)
	Local lExecAuto:=If(ValType(aCmp)=="A", .T., .F.)
	Local _i

//--
//-- Se a exclusão for automática
	If lExecAuto
		// Cria as variaveis na memória
		For _i:=1 To Len(aCmp)
			&("M->"+aCmp[_i][1]) := aCmp[_i][2]
		Next

		dbSelectArea("SZ4")
		SZ4->(dbSetOrder(1))
		If SZ4->(dbSeek(cFilSZ4+M->(Z4_COD+Z4_MEANO+Z4_MVTO)))
			dbSelectArea("SZ3")
			SZ3->(dbSetOrder(1))
			If SZ3->(dbSeek(cFilSZ3+SZ4->Z4_COD))

				// Atualiza a tabela das classificações estimadas de produção
				RecLock("SZ3",.F.)
				SZ3->Z3_ACM   := SZ3->Z3_ACM - SZ4->Z4_PROD
				SZ3->Z3_SALDO := SZ3->((Z3_ESTIMA+Z3_AMPLIA) - (Z3_ACM+Z3_REDUCAO))
				If SZ3->Z3_SALDO>0
					SZ3->Z3_STATUS:=""
				Endif
				SZ3->(MsUnLock())
			Endif

			// Exclui a operação
			RecLock("SZ4",.F.)
			SZ4->(dbDelete())
			SZ4->(MsUnLock())
		Else
			Alert("O lançamento de movimento para estono da produção, não foi encontrado."+Chr(13)+;
				"Tabela: SZ4, Classificação Estimada: "+M->Z4_COD+", Mes e Ano: "+Right(M->Z4_MEANO,2)+"/"+Left(M->Z4_MEANO,4)+". "+Chr(13)+;
				"Informe ao administrador do sistema.")
		Endif
	Else

		If SZ4->Z4_MVTO=="1"	// aprontamento de produção
			Alert("Esta opção só é permitida através da rotina de apontamento de produção. (AATF001)")
			Return
		Endif

		If MsgYesNo("Confirma a exclusão desta operação?")
			dbSelectArea("SZ3")
			SZ3->(dbSetOrder(1))
			If SZ3->(dbSeek(SZ4->Z4_FILIAL+SZ4->Z4_COD))

				// Atualiza a tabela das classificações estimadas de produção
				RecLock("SZ3",.F.)
				If SZ4->Z4_MVTO$"2"	// apontamento de ampliação
					SZ3->Z3_AMPLIA:= SZ3->Z3_AMPLIA - SZ4->Z4_PROD
				ElseIf SZ4->Z4_MVTO$"3"// apontamento de redução
					SZ3->Z3_REDUCAO:= SZ3->Z3_REDUCAO - SZ4->Z4_PROD
				Endif
				SZ3->Z3_SALDO := SZ3->((Z3_ESTIMA+Z3_AMPLIA) - (Z3_ACM+Z3_REDUCAO))
				If SZ3->Z3_SALDO>0
					SZ3->Z3_STATUS:=""
				Endif
				SZ3->(MsUnLock())
			Endif

			// Exclui a operação
			RecLock("SZ4",.F.)
			SZ4->(dbDelete())
			SZ4->(MsUnLock())
		Endif
	Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Programa ³ VerLege    ³ Autor ³ Toni Aguiar      ³ Data ³ 01/06/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Funcao   ³ Exibicao da legenda correspondente as cores disponiveis   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function VerLege(cCadastro, aLegenda)
	BrwLegenda(cCadastro,"Legenda",aLegenda)
Return
