#Include "Rwmake.ch"
#Include "Protheus.ch"
#Include "Topconn.ch"
#include "rwmake.ch"
#include "fileio.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
#include "protheus.ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT103FIM ºAutor  ³Ismael Junior        º Data ³  15/03/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  P.E. após a gravacao do documento de entrada              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MT103FIM()
	Local nOpcao := PARAMIXB[1]   // Opção Escolhida pelo usuario no aRotina
	Local nConfirma := PARAMIXB[2]   // Se o usuario confirmou a operação de gravação da NFE
	Local cAno     := Alltrim(Str(Year(Date())))
	//Local _cCusto  := _cItemco := _cConta  := _cClvl := ""
	Local cMes     := Month2Str(Date())
	Local nVlRel   := 0
	Local _n       := 0
	Local _nFim    := 7
	Local aGetAre := GetArea()
	Local aZB1Are := ZB1->(GetArea())
	Local oTabTemp	:= Nil

	Private aCampos:={ {"CHAV" ,"C", 38,0},;
		{"CCUSTO" ,"C",9,0},;
		{"ITEMCO" ,"C",9,0},;
		{"CLVL" ,"C",20,0},;
		{"CONTA" ,"C",20,0},;
		{"NVLTOT","N",14,2}}  // campos da tabela temporária

	conOut("MT103FIM - INICIO PROCESSAMENTO")
	If Select("TRB")> 0
		TRB->(DbCloseArea())
	Endif

	oTabTemp := FWTemporaryTable():New("TRB", aCampos)
	oTabTemp:AddIndex("01",{"CHAV","CCUSTO","ITEMCO"})
	oTabTemp:Create()

	if nConfirma == 1 .and. nOpcao == 3	.or. nOpcao == 4 // 3 - Inclusão // 4 - Classificação
		/*
		cQuery := " SELECT C7_CC,C7_ITEMCTA,C7_CONTA,C7_TOTAL "
		cQuery += " FROM "+RetSqlName("SC7")+" SC7 "
		cQuery += " WHERE C7_NUM = '"+SD1->D1_PEDIDO+"' "
		cQuery += " AND SC7.D_E_L_E_T_ = ' ' "   */

		cQuery := " SELECT D1_CC,D1_ITEMCTA,D1_CLVL,D1_CONTA,D1_TOTAL "
		cQuery += " FROM "+RetSqlName("SD1")+" SD1 "
		cQuery += " WHERE D1_FILIAL = '"+XFILIAL("SD1")+"' "
		cQuery += " AND D1_PEDIDO = '"+SD1->D1_PEDIDO+"' "
		cQuery += " AND D1_DOC = '"+SD1->D1_DOC+"' "
		cQuery += " AND SD1.D_E_L_E_T_ = ' ' "

		If SELECT("TRA") > 0
			("TRA")->(DbCloseArea())
		Endif
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRA",.T.,.T.)
		dbSelectArea("TRB")
		While TRA->(!EOF())
			cChave := TRA->D1_CC+TRA->D1_ITEMCTA+TRA->D1_CLVL+TRA->D1_CONTA
			TRB->(dbSeek(cChave))
			IF EOF()
				nVlRel := TRA->D1_TOTAL
				reclock("TRB",.T.)
				TRB->CHAV       := TRA->D1_CC+TRA->D1_ITEMCTA+TRA->D1_CLVL+TRA->D1_CONTA
				TRB->NVLTOT     := nVlRel
				TRB->CCUSTO     := TRA->D1_CC
				TRB->ITEMCO     := TRA->D1_ITEMCTA
				TRB->CLVL       := TRA->D1_CLVL
				TRB->CONTA      := TRA->D1_CONTA
			ELSE
				nVlRel := TRB->NVLTOT + TRA->D1_TOTAL
				reclock("TRB",.F.)
				TRB->NVLTOT     := nVlRel
			ENDIF
			TRA->(DbSkip())
		Enddo

		TRB->(DbGoTop())
		While TRB->(!EOF())
			cUpdate:= " UPDATE " + RetSqlName("ZW2")+" SET ZW2_REL"+cMes+"=ZW2_REL"+cMes+"+"+Alltrim(Str(TRB->NVLTOT))+",ZW2_RELANO = ZW2_RELANO+"+Alltrim(Str(TRB->NVLTOT))
			cUpdate+= " WHERE ZW2_CCUSTO = '"+Alltrim(TRB->CCUSTO)+"' "
			cUpdate+= " AND ZW2_ITEMCO = '"+Alltrim(TRB->ITEMCO)+"' "
			cUpdate+= " AND ZW2_CLVL = '"+Alltrim(TRB->CLVL)+"' "
			cUpdate+= " AND ZW2_CONTA = '"+Alltrim(TRB->CONTA)+"' "
			cUpdate+= " AND ZW2_ANO = '"+cAno+"' "
			cUpdate+= " AND ZW2_FILIAL = '"+xFilial("ZW2")+"' "
			cUpdate+= " AND D_E_L_E_T_ = ' ' "
			nFlag := TcSqlExec(cUpdate)
			TRB->(DbSkip())
		Enddo

		//********Ajusta vencimento do título para próximo dia de pagamento Terça ou Quinta *****************

		cQuery:="SELECT E2_VENCTO,E2_VENCREA,E2_FILIAL,E2_NUM,E2_PREFIXO,E2_FORNECE,E2_LOJA,E2_PARCELA,E2_TIPO "
		cQuery+="FROM " + RetSqlName("SE2")+" SE2 "
		cQuery+="WHERE E2_FILIAL = '" + SF1->F1_FILIAL + "' "
		cQuery+="AND E2_NUM = '" + SF1->F1_DOC + "' "
		cQuery+="AND E2_PREFIXO = '" + SF1->F1_SERIE + "' "
		cQuery+="AND E2_FORNECE = '" + SF1->F1_FORNECE + "' "
		cQuery+="AND E2_LOJA = '" + SF1->F1_LOJA + "' "
		cQuery+="AND SE2.D_E_L_E_T_ = ' ' "
		If SELECT("SE2TB") > 0
			SE2TB->(DbCloseArea())
		Endif
		conOut(cQuery)

		ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SE2TB",.T.,.T.)

		dbSelectArea("SE2")
		SE2->(dbSetOrder(06))
		Do While SE2TB->(!Eof())
			_dData := stod(SE2TB->E2_VENCREA)
			conOut("MT103FIM - DATA ORIGINAL"+SE2TB->E2_VENCREA) //Stephen
			_nRet  := Dow(_dData)
			conOut("MT103FIM - DIA DA SEMANA ORIGINAL: "+cValtoChar(_nRet)) //Stephen
			If !Alltrim(Str(_nRet)) $ "3#5" // 3 terça e 5 quinta
				/*	If _nRet >= 6
				_nRet := 1
				Endif  */
				conOut("MT103FIM - ENTRE NO SE, SIGNIFICA QUE CAIU FORA")
				for _n := 1 to _nFim
					//Stephen Noel - Equilibrito T.I. Caso seja uma sexta feira, tratamos somando
					If Alltrim(Str(_nRet)) == "2" //Caso caia na segunda subtraimos 4 dias
						_dData := DaySub(_dData, 4)
						conOut("MT103FIM - DEU NA SEGUNDA - NOVA DATA: " + dtos(_dData))
					Else
						_dData := DaySub(_dData, 1) //DaySum(_dData, 1)
						conOut("MT103FIM - NAO DEU NA SEGUNDA NOVA DATA: " + dtos(_dData))
					EndIf
					_nRet := Dow(_dData)
					conOut("MT103FIM - NOVO DIA DO VENCIMENTO: "+cValtoChAr(_nRet)) //Stephen
					If Alltrim(Str(_nRet)) $ "3#5" // 3 terça e 5 quinta
						If SE2->(dbSeek(SE2TB->E2_FILIAL + SE2TB->E2_FORNECE + SE2TB->E2_LOJA + SE2TB->E2_PREFIXO + SE2TB->E2_NUM + SE2TB->E2_PARCELA + SE2TB->E2_TIPO ))
							conOut("MT103FIM - ALTERANDO TITULO: "+SE2TB->E2_NUM+ " DE "+dtos(SE2->E2_VENCREA)+ "PARA "+dtos(_dData)) //Stephen
							SE2->(RecLock("SE2",.F.))
							SE2->E2_VENCTO := _dData
							SE2->E2_VENCREA := _dData
							SE2->(MsUnlock())
							Exit

						EndIf

					Endif
				Next _n
			Else
				conOut("MT103FIM - NEM ENTREI NO SE")
			Endif
			SE2TB->(dbSkip())
		EndDo
	Endif

	if nConfirma == 1 .and. nOpcao == 5	// Exclusão
		
	cQuery := " SELECT C7_CC,C7_ITEMCTA,C7_CONTA,C7_TOTAL "
	cQuery += " FROM "+RetSqlName("SC7")+" SC7 "
	cQuery += " WHERE C7_NUM = '"+SD1->D1_PEDIDO+"' "
		cQuery += " AND SC7.D_E_L_E_T_ = ' ' " 

		cQuery := " SELECT D1_CC,D1_ITEMCTA,D1_CLVL,D1_CONTA,D1_TOTAL "
		cQuery += " FROM "+RetSqlName("SD1")+" SD1 "
		cQuery += " WHERE D1_FILIAL = '"+XFILIAL("SD1")+"' "
		cQuery += " AND D1_PEDIDO = '"+SD1->D1_PEDIDO+"' "
		cQuery += " AND D1_DOC = '"+SD1->D1_DOC+"' "

		If SELECT("TRA") > 0
			("TRA")->(DbCloseArea())
		Endif
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRA",.T.,.T.)
		dbSelectArea("TRB")
		While TRA->(!EOF())
			cChave := TRA->D1_CC+TRA->D1_ITEMCTA+TRA->D1_CLVL+TRA->D1_CONTA
			TRB->(dbSeek(cChave))
			IF EOF()
				nVlRel := TRA->D1_TOTAL
				reclock("TRB",.T.)
				TRB->CHAV       := TRA->D1_CC+TRA->D1_ITEMCTA+TRA->D1_CLVL+TRA->D1_CONTA
				TRB->NVLTOT     := nVlRel
				TRB->CCUSTO     := TRA->D1_CC
				TRB->ITEMCO     := TRA->D1_ITEMCTA
				TRB->CLVL       := TRA->D1_CLVL
				TRB->CONTA      := TRA->D1_CONTA
			ELSE
				nVlRel := TRB->NVLTOT + TRA->D1_TOTAL
				reclock("TRB",.F.)
				TRB->NVLTOT     := nVlRel
			ENDIF
			TRA->(DbSkip())
		Enddo

		TRB->(DbGoTop())
		While TRB->(!EOF())
			cUpdate:= " UPDATE " + RetSqlName("ZW2")+" SET ZW2_REL"+cMes+"=ZW2_REL"+cMes+"-"+Alltrim(Str(TRB->NVLTOT))+", ZW2_RELANO = ZW2_RELANO-"+Alltrim(Str(TRB->NVLTOT))
			cUpdate+= " WHERE ZW2_CCUSTO = '"+Alltrim(TRB->CCUSTO)+"' "
			cUpdate+= " AND ZW2_ITEMCO = '"+Alltrim(TRB->ITEMCO)+"' "
			cUpdate+= " AND ZW2_CLVL = '"+Alltrim(TRB->CLVL)+"' "
			cUpdate+= " AND ZW2_CONTA = '"+Alltrim(TRB->CONTA)+"' "
			cUpdate+= " AND ZW2_ANO = '"+cAno+"' "
			cUpdate+= " AND ZW2_FILIAL = '"+xFilial("ZW2")+"' "
			cUpdate+= " AND D_E_L_E_T_ = ' ' "
			nFlag := TcSqlExec(cUpdate)
			TRB->(DbSkip())
		Enddo

	Endif 

	//-- Felipe Andrew
	//-- Recupera dados gravados na ZB1 para atualizar na SE2
	//-- Atualizaçao devido a clasificação de notas executado pelo robô de classificação automática.
	/*
dbSelectArea("ZB1")
ZB1->(dbSetOrder(1))
If ZB1->(dbSeek(xFilial("ZB1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA))   // ZB1_FILIAL+ZB1_NOTA+ZB1_SERIE+ZB1_FORNEC+ZB1_NATURE
   If !FWIsInCallStack("U_Classif1")
      conout("entrou zb1 MT103FIM")
 	  //conOut("Acessou ZB1 POS GRAVACAO")
      If ZB1->(RecLock("ZB1",.F.))
         ZB1->ZB1_BRICMS := SF1->F1_BRICMS
         ZB1->ZB1_ICMSRE := SF1->F1_ICMSRET
         ZB1->ZB1_BASIM5 := SF1->F1_BASIMP5
         ZB1->ZB1_BASIM6 := SF1->F1_BASIMP6
         ZB1->ZB1_VALIM5 := SF1->F1_VALIMP5
         ZB1->ZB1_VALIM6 := SF1->F1_VALIMP6
         ZB1->ZB1_VALPIS := SF1->F1_VALPIS
         ZB1->ZB1_VALCOF := SF1->F1_VALCOFI
         ZB1->ZB1_VALCSL := SF1->F1_VALCSLL
         ZB1->ZB1_BASCSL := SF1->F1_BASCSLL
         ZB1->ZB1_BASPIS := SF1->F1_BASPIS
         ZB1->ZB1_BASCOF := SF1->F1_BASCOFI
         ZB1->(MsUnlock())
      EndIf
   EndIf
   dbSelectArea("SE2")
   SE2->(dbSetOrder(06))
   If SE2->(dbSeek(xFilial("SE2") + SF1->F1_FORNECE + SF1->F1_LOJA + SF1->F1_SERIE + SF1->F1_DOC))
      If SE2->(RecLock("SE2",.F.))
         SE2->E2_VENCTO := ZB1->ZB1_VENCTO
         SE2->E2_EMIS1  := SE2->E2_EMISSAO
         SE2->(MsUnlock())
      EndIf
   EndIf
	EndIf*/

	// Controle de títulos a liberar via workflow - TOTVS STARSOFT - Toni Aguair em 01/11/2021.
	If Empty(SD1->D1_PEDIDO)
		if nConfirma == 1 .and. nOpcao == 3	//Inclusão
			fControlTitu()
		Endif
	else
		dbSelectArea("SE2")
		SE2->(dbSetOrder(06))
		If SE2->(dbSeek(xFilial("SE2") + SF1->F1_FORNECE + SF1->F1_LOJA + SF1->F1_SERIE + SF1->F1_DOC))
			If SE2->(RecLock("SE2",.F.))
				SE2->E2_DATALIB := dDataBase
				SE2->(MsUnlock())
			EndIf
		EndIf
	Endif

	oTabTemp:Delete()

	RestArea(aZB1Are)
	RestArea(aGetAre)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FCONTROLTITU ºAutor  ³ Toni Aguiar     º Data ³  01/01/21   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gera o controle de títulos, bloqueando-os para liberar     º±±
±±º          ³ através de workflow                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function fControlTitu()
	// Gerenciamento do bloqueio na inclusão do contas a pagar
	// Envio de workflow solicitando aprovação
	cGrupoAp := GETMV("MV_XNFAPRO")
	cQuery:="SELECT AL_USER,AL_NIVEL,AL_COD "
	cQuery+="FROM "+RetSqlName("SAL")+" SAL "
	cQuery+="WHERE AL_FILIAL='"+xFilial("SAL")+"'
	cQuery+="AND AL_COD = '" + cGrupoAp + "' "
	cQuery+="AND SAL.D_E_L_E_T_ = ' ' "
	If SELECT("SALTB") > 0
		SALTB->(DbCloseArea())
	Endif
	ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SALTB",.T.,.T.)

	DbSelectArea("SZC")
	SZC->(DbSetOrder(1))
	Do While SALTB->(!Eof())
		RecLock("SZC",.T.)
		SZC->ZC_FILIAL   := XFILIAL("SZC")
		SZC->ZC_PREFIXO  := SE2->E2_PREFIXO
		SZC->ZC_NUM      := SE2->E2_NUM
		SZC->ZC_PARCELA  := SE2->E2_PARCELA
		SZC->ZC_TIPO     := SE2->E2_TIPO
		SZC->ZC_FORNECE  := SE2->E2_FORNECE
		SZC->ZC_LOJA     := SE2->E2_LOJA
		SZC->ZC_APROVA   := SALTB->AL_USER
		SZC->ZC_GRUPO    := SALTB->AL_COD
		SZC->ZC_NIVEL    := SALTB->AL_NIVEL
		SZC->(MsUnLock())
		SALTB->(dbSkip())
	EndDo
	//Envio do workflow
	//Inicio o Processo, enviando o e-mail.
	dbSelectArea("SE2")
	SE2->(dbSetOrder(06))
	If SE2->(dbSeek(xFilial("SE2") + SF1->F1_FORNECE + SF1->F1_LOJA + SF1->F1_SERIE + SF1->F1_DOC))
		u_WF050INC( , , SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_FORNECE,SE2->E2_LOJA )
	Endif
	// Pesquisa tipo TX -
	cUpdate := "UPDATE " + RetSqlName("SE2") + " SET E2_DATALIB = '" + DTOS(date()) + "' "
	cUpdate += "WHERE E2_FILIAL = '" + SE2->E2_FILIAL + "' ""
	cUpdate += "AND E2_PREFIXO = '" + SE2->E2_PREFIXO + "' "
	cUpdate += "AND E2_NUM = '" + SE2->E2_NUM + "' "
	cUpdate += "AND E2_TIPO IN ('TX','INS','ISS') "
	//cUpdate += "AND E2_FORNECE = 'UNIAO' "
	//cUpdate += "AND E2_LOJA = '00' "
	cUpdate += "AND D_E_L_E_T_ = ' ' "
	nFlag := TcSqlExec(cUpdate)
Return nil
