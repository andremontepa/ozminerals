#include 'protheus.ch'
#include 'parmtype.ch'
#include 'totvs.ch'
#INCLUDE 'topconn.ch'
#INCLUDE 'prtopdef.ch'

#define cEndLin Chr(13) + Chr(10)
//-------------------------------------------------------------------------------
/* {Protheus.doc} IACOMR01
Programa - Relatorio de Medicoes de Contratos Globais
Copyright I AGE� - Intelig�ncia Andrews
@author Felipe Andrews de Almeida
@since 01/2021
@version Lobo Guara v.12.1.23
*/
//-------------------------------------------------------------------------------
User Function IACOMR01()
	/* Variaveis criadas para classes TReport */
	Private oReport, oSection, oSection2
	Private cTitRel := "Relat�rio de Medi�oes de Contratos Globais" /* Titulo do Relat�rio */
	Private cNomPro := "IACOMR01" /* Nome do Programa do Relat�rio */
	Private cRelPrg := "IACOMR01" /* Nome do Grupo de Perguntas do Relat�rio */

	/* Vari�veis representantes de par�metros */
	Private cConIni := Space(TamSX3("CN9_NUMERO")[01]) /* Contrato Inicial */
	Private cConFin := Space(TamSX3("CN9_NUMERO")[01]) /* Contrato Final */
	Private cRevIni := Space(TamSX3("CN9_REVISA")[01]) /* Revisao Inicial */
	Private cRevFin := Space(TamSX3("CN9_REVISA")[01]) /* Revisao Final */
	Private cDtaIni := Space(TamSX3("CND_DTINIC")[01]) /* Data Inicial */
	Private cDtaFin := Space(TamSX3("CND_DTINIC")[01]) /* Data Final */

	/* fGerPrg(). Chamada de Fun��o para Criar as Perguntas. */
	Processa({||fGerPrg()},"Aguarde...","Gerando Par�metros...")

	/* Chama a fun��o CriaStru para Criar a estrutura XLS do relat�r. */
	Processa({||fGerStr()},"Aguarde...","Gerando Estrutura...")

	/* Chama a fun��o fTReport para Criar o relat�rio no Padr�o TRep. */
	If Pergunte(cRelPrg,.T.)
		Processa({||fTReport()},"Aguarde...","Gerando Relat�rio...")
		oReport:PrintDialog()
	EndIf

Return

Static Function fGerPrg()
	/* Ajusta SX1 segundo novos parametros */
	/* criacao de algumas variaveis para a inclusao das perguntas no sistema */
	Local nXi,nXj
	Local aSX1Reg := {}
	Local nTotReg := 0 /* Quantidade total de Registros */
	Local nRegLid := 0 /* Quantidade de Registros lidos */

	/* seleciona a tabela de perguntas SX1 */
	dbSelectArea("SX1")
	/* Determina ordena��o 01 do �ndice de pesquisa */
	SX1->(dbSetOrder(01))

	//perguntas a serem criadas com seus respectivos parametros
	aAdd(aSX1Reg,{cRelPrg,"01","Contrato De:  ","","","mv_ch1","C",TamSX3("CN9_NUMERO")[01],0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","CN9","","",".IACOMR0101."})
	aAdd(aSX1Reg,{cRelPrg,"02","Contrato At�: ","","","mv_ch2","C",TamSX3("CN9_NUMERO")[01],0,0,"G","!Empty(mv_par02) .And. (mv_par02>=mv_par01)","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","CN9","","",".IACOMR0102."})
	aAdd(aSX1Reg,{cRelPrg,"03","Revisao De:   ","","","mv_ch3","C",TamSX3("CN9_REVISA")[01],0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","","",".IACOMR0103."})
	aAdd(aSX1Reg,{cRelPrg,"04","Revisao At�:  ","","","mv_ch4","C",TamSX3("CN9_REVISA")[01],0,0,"G","!Empty(mv_par04) .And. (mv_par04>=mv_par03)","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","","",".IACOMR0104."})
	aAdd(aSX1Reg,{cRelPrg,"05","Data de:      ","","","mv_ch5","D",TamSX3("CND_DTINIC")[01],0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","","","",".IACOMR0105."})
	aAdd(aSX1Reg,{cRelPrg,"06","Data At�:     ","","","mv_ch6","D",TamSX3("CND_DTINIC")[01],0,0,"G","!Empty(mv_par06) .And. (mv_par06>=mv_par05)","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","","","",".IACOMR0106."})
   
		/* Verifica a quantidade de perguntas */
	nTotReg := Len(aSX1Reg)

	/* Funcao para regua de processos */
	ProcRegua(nTotReg)

	/* laco for para fazer a inclusao das perguntas */
	For nXi := 01 to Len(aSX1Reg)
	   /* funcao da regua de processos incrementando */
		IncProc("Aguarde... Processando Registro " + Alltrim(Str(nRegLid)) + " de " + Alltrim(Str(nTotReg)))
		If !SX1->(dbSeek(cRelPrg+Space(Len(SX1->X1_GRUPO)-Len(cRelPrg))+aSX1Reg[nXi,2]))
			RecLock("SX1",.T.)
			For nXj := 01 to FCount()
				If nXj <= Len(aSX1Reg[nXi])
					FieldPut(nXj,aSX1Reg[nXi,nXj])
				Endif
			Next
			MsUnlock()
		EndIf
		nRegLid++
	Next nXi

	fSX1Hlp("P.IACOMR0101.","","C�digo inicial de contrato para filtro","")
	fSX1Hlp("P.IACOMR0102.","","C�digo final de contrato para filtro","")
	fSX1Hlp("P.IACOMR0103.","","C�digo inicial de revisao para filtro","")
	fSX1Hlp("P.IACOMR0104.","","C�digo final de revisao para filtro","")
	fSX1Hlp("P.IACOMR0105.","","Data de medicao inicial para filtro","")
	fSX1Hlp("P.IACOMR0106.","","Data de medicao final para filtro","")
	
Return

Static Function fSX1Hlp(pKeyPrg,pIn1Hlp,pPt1Hlp,pEs1Hlp)
	Local nXi := 0 /* Contador */
	Local nNumLin := 0  /* Quantidade de caracteres por linha */
	Local aIngHlp := {} /* Help da Pergunta em ingl�s */
	Local aPorHlp := {} /* Help da Pergunta em portugu�s */
	Local aEspHlp := {} /* Help da Pergunta em espanhol */

	/* Montagem da estrutura de help de perguntas do parametro informado
	 * sendo neste momento feita para a lingua Portugu�s */
	If !Empty(Alltrim(pPt1Hlp))
		nNumLin := Mlcount(pPt1Hlp,40)
		For nXi := 01 To nNumLin
			If !Empty(Memoline(pPt1Hlp,40,nXi))
				aAdd(aPorHlp,OemToAnsi(Memoline(pPt1Hlp,40,nXi)))
			Endif
		Next nXi
	Else
		aAdd(aPorHlp,"") /* Grava vazio na primeira e segunda linha */
		aAdd(aPorHlp,"") /* Grava vazio na primeira e segunda linha */
    EndIf

	/* Montagem do estrutura de help de perguntas do parametro informado
	 * sendo neste momento feita para a lingua Ingl�s */
	If !Empty(Alltrim(pIn1Hlp))
		nNumLin := Mlcount(pIn1Hlp,40)
		For nXi := 01 To nNumLin
			If !Empty(Memoline(pIn1Hlp,40,nXi))
				aAdd(aIngHlp,OemToAnsi(Memoline(pIn1Hlp,40,nXi)))
			Endif
		Next nXi
	Else
		aIngHlp := aPorHlp /* Recebe mesmo conteudo da lingua portugu�s */
    EndIf

	/* Montagem do estrutura de help de perguntas do parametro informado
	 * sendo neste momento feita para a lingua Espanhol */
	If !Empty(Alltrim(pEs1Hlp))
		nNumLin := Mlcount(pEs1Hlp,40)
		For nXi := 01 To nNumLin
			If !Empty(Memoline(pEs1Hlp,40,nXi))
				aAdd(aEspHlp,OemToAnsi(Memoline(pEs1Hlp,40,nXi)))
			Endif
		Next nXi
	Else
		aEspHlp := aPorHlp /* Recebe mesmo conteudo da lingua portugu�s */
    EndIf

	/* Fun��o utilizada para cadastro de helps no Protheus. */
	PutSX1Help(pKeyPrg,aPorHlp,aIngHlp,aEspHlp)

Return

Static Function fGerStr()
	Local cArqTrb := "" /* Arquivo de trabalho */
	Local aStrXls := {} /* Strutura de Arquivo de trabalho XLS */
	Local cChkInd := "" /* Valida��o de �ndice */

	/* Vari�veis que receber�o os valores do layout necessitado no relat�rio */
	aAdd(aStrXls,{"CN9_FILIAL","C",TamSX3("CN9_FILIAL")[01],00})
	aAdd(aStrXls,{"CN9_NUMERO","C",TamSX3("CN9_NUMERO")[01],00})
	aAdd(aStrXls,{"CN9_REVISA","C",TamSX3("CN9_REVISA")[01],00})
	aAdd(aStrXls,{"CN9_DTINIC","D",TamSX3("CN9_DTINIC")[01],00})
	aAdd(aStrXls,{"CN9_DTFIM","D",TamSX3("CN9_DTFIM")[01],00})
	aAdd(aStrXls,{"CN9_VLATU","N",TamSX3("CN9_VLATU")[01],TamSX3("CN9_VLATU")[02]})
	aAdd(aStrXls,{"CN9_SALDO","N",TamSX3("CN9_SALDO")[01],TamSX3("CN9_SALDO")[02]})
	aAdd(aStrXls,{"CND_XEMPRE","C",TamSX3("CND_XEMPRE")[01],00})
	aAdd(aStrXls,{"CND_XFILIA","C",TamSX3("CND_XFILIA")[01],00})
	aAdd(aStrXls,{"CND_NUMMED","C",TamSX3("CND_NUMMED")[01],00})
	aAdd(aStrXls,{"CND_VLTOT","N",TamSX3("CN9_SALDO")[01],TamSX3("CND_VLTOT")[02]})
	aAdd(aStrXls,{"CND_DTINIC","D",TamSX3("CND_DTINIC")[01],00})
	aAdd(aStrXls,{"CND_PEDIDO","C",TamSX3("CND_PEDIDO")[01],00})

	//SELECT E FECHA O ARQ. DE TRAB.
	fCloseArea("XLS")

	cArqTrb := CriaTrab(aStrXls,.T.)
	dbUseArea(.T.,,cArqTrb,"XLS")

Return

Static Function fTReport()

	/* A classe TReport permite que o usu�rio personalize as informa��es que ser�o apresentadas 
	   no relat�rio, alterando fonte (tipo, tamanho, etc), cor, tipo de linhas, cabe�alho, rodap�, etc.*/
   
   // ALTEA��O MARIO 20/12 oReport := TReport():New(cNomPro,cTitRel,/*cRelPrg*/,{|oReport| fGerTmp()},"Este relat�rio ir� imprimir o Faturamento de Cliente")
	oReport := TReport():New(cNomPro,cTitRel,cRelPrg,{|oReport| fGerTmp()},"Este relat�rio ir� imprimir a Rela��o de Contratos Globais e suas medi�oes")
	Pergunte(cRelPrg,.F.)
	oReport:SetPortrait()
	oReport:SetTotalInLine(.F.)

	/* A classe TRSection pode ser entendida como um layout do relat�rio, por conter 
	   c�lulas, quebras e totalizadores que dar�o um formato para sua impress�o. */
	//TRSection():New ( < oParent > , [ cTitle ] , [ uTable ] , [ aOrder ] , [ lLoadCells ] , [ lLoadOrder ] ) --> TRSection
	oSection := TRSection():New(oReport,"Relat�rio de Contratos",{"XLS"},{"Contrato"})
	//oSection2 := TRSection():New(oSection,"Contratos",{"XL2","Contratos"})

	/*Se o nome da c�lula informada pelo parametro for encontrado no Dicion�rio de
	Campos (SX3), as informa��es do campo ser�o carregadas para a c�lula, respeitando
	os parametros de t�tulo, picture e tamanho. Dessa forma o relat�rio sempre estar�
	atualizado com as informa��es do Dicion�rio de Campos (SX3).*/
	//TRCell():New(/*OBJETO*/,/*CAMPO*/,/*ARQ.TRAB.*/,/*TITULO*/,/*PICTURE*/,/*TAMANHO*/,/*lPixel*/,/*{|| codblock de impressao }*/
	TRCell():New(oSection,"CN9_FILIAL","XLS","Filial",,TamSX3("CN9_FILIAL")[01])
	TRCell():New(oSection,"CN9_NUMERO","XLS","Contrato",,TamSX3("CN9_NUMERO")[01])
	TRCell():New(oSection,"CN9_REVISA","XLS","Revisao",,TamSX3("CN9_REVISA")[01])
	TRCell():New(oSection,"CN9_DTINIC","XLS","Dt.Inicial",,TamSX3("CN9_DTINIC")[01])
	TRCell():New(oSection,"CN9_DTFIM","XLS","Dt.Final",,TamSX3("CN9_DTFIM")[01])
	TRCell():New(oSection,"CN9_VLATU","XLS","Valor Atual","@E 999,999,999.99",14)
	TRCell():New(oSection,"CN9_SALDO","XLS","Saldo","@E 999,999,999.99",14)
	TRCell():New(oSection,"CND_XEMPRE","XLS","Empresa",,TamSX3("CND_XEMPRE")[01])
	TRCell():New(oSection,"CND_XFILIA","XLS","Filial",,TamSX3("CND_XFILIA")[01])
	TRCell():New(oSection,"CND_NUMMED","XLS","Medicao",,TamSX3("CND_NUMMED")[01])
	TRCell():New(oSection,"CND_VLTOT","XLS","Valor Total","@E 999,999,999.99",14)
	TRCell():New(oSection,"CND_DTINIC","XLS","Dt.Medicao",,TamSX3("CND_DTINIC")[01])
	TRCell():New(oSection,"CND_PEDIDO","XLS","Pedido",,TamSX3("CND_NUMMED")[01])

//	TRCell():New(oSection2,"TMP_CODCO2","XL2","CONTRATO","",TamSX3("Z1_NUM")[01]) //C�digo do Pedido de Venda
//	TRCell():New(oSection2,"TMP_CLIENT","XL2","CLIENTE","",50) //Cliente

	/* neste caso verifica o arquivo de trabalho gerado e faz a exclus�o
	dos dados e da tabela tempor�ria */
	fCloseArea("IATRB")

Return

Static Function fGerTmp()
	Local cQrySql := "" //Variavel na qual � armazenado a query de consulta ao banco

	cConIni := MV_PAR01 /* Contrato Inicial */
	cConFin := MV_PAR02 /* Contrato Final */
	cRevIni := MV_PAR03 /* Revisao Inicial */
	cRevFin := MV_PAR04 /* Revisao Final */
	cDtaIni := Dtos(MV_PAR05) /* Data Inicial */
	cDtaFin := Dtos(MV_PAR06) /* Data Final */

	cQrySql += " SELECT CN9.CN9_FILIAL, CN9.CN9_NUMERO, CN9.CN9_REVISA, CN9.CN9_DTINIC, CN9.CN9_DTFIM, CN9.CN9_VLATU, CN9.CN9_SALDO, "
	cQrySql += "        CND.CND_XEMPRE, CND.CND_XFILIA, CND.CND_NUMMED, CND.CND_VLTOT, CND.CND_DTINIC, CND.CND_PEDIDO "
	cQrySql += " FROM " + RetSqlName("CN9") + " CN9 "
	cQrySql += " INNER JOIN " + RetSqlName("CND") + " CND "
	cQrySql += " ON ( CND.CND_FILIAL = CN9.CN9_FILIAL "
	cQrySql += " AND  LTRIM(RTRIM(CND.CND_CONTRA)) = LTRIM(RTRIM(CN9.CN9_NUMERO)) "
	cQrySql += " AND  CND.CND_REVISA = CN9.CN9_REVISA "
	cQrySql += " AND  CND.CND_DTINIC >= '" + cDtaIni + "' "
	cQrySql += " AND  CND.CND_DTINIC <= '" + cDtaFin + "' "
	cQrySql += " AND  CND.D_E_L_E_T_ <> '*' ) "
	cQrySql += " WHERE CN9.CN9_XGLOBA = 'N' "
	cQrySql += " AND   CN9.CN9_NUMERO >= '" + cConIni + "' "
	cQrySql += " AND   CN9.CN9_NUMERO <= '" + cConFin + "' "
	cQrySql += " AND   CN9.CN9_REVISA >= '" + cRevIni + "' "
	cQrySql += " AND   CN9.CN9_REVISA <= '" + cRevFin + "' "
	cQrySql += " AND   CN9.D_E_L_E_T_ <> '*' "

	fCloseArea("IATRB")
	dbUseArea(.T., "TOPCONN",TCGenQry(,,cQrySql),"IATRB",.T., .T.)

	/* Chama a fun��o fProTmp para processar temporario e gravar. */
	Processa({||fProTmp()},"Aguarde...","Gravando Informa��es...")

	/* Chama a fun��o fImpRel para Imprimir informa��es do Relatorio */
	fImpRel()

Return  

Static Function fProTmp()
	Local nTotReg := 0 /* Quantidade total de Registros */
	Local nRegLid := 0 /* Quantidade de Registros lidos */
	Private nTotMed := 0 /* Total das M�dias */

	/* seleciono o arquivo de trabalho gerado pela query e coloco no inicio */
	dbSelectArea("IATRB")
	/* Totaliza os registros da tabela */
	IATRB->(dbEval({||nTotReg++}))
	/* Posiciona no primeiro registro */
	IATRB->(dbGoTop())

	/* Funcao para regua de processos */
	ProcRegua(nTotReg)

	Do While !IATRB->(Eof())
		/* funcao da regua de processos incrementando */
		IncProc("Aguarde... Processando Registro " + Alltrim(Str(nRegLid)) + " de " + Alltrim(Str(nTotReg)))

		/* Chama a fun��o fGrvTmp para Gravar o Tmp. no Arq. Trab. XLS. */
		fGrvTmp()

		/* seleciono o arquivo de trabalho gerado pela query e coloco no inicio */
		dbSelectArea("IATRB")
		/* avan�a para proximo registro */
		IATRB->(dbSkip())
		/* atualiza contador da r�gua */
		nRegLid++
	EndDo

Return

Static Function fGrvTmp()	

	dbSelectArea("XLS")
 	If XLS->(RecLock("XLS",.T.)) 
		XLS->CN9_FILIAL := IATRB->CN9_FILIAL
		XLS->CN9_NUMERO := IATRB->CN9_NUMERO
		XLS->CN9_REVISA := IATRB->CN9_REVISA
		XLS->CN9_DTINIC := SToD(IATRB->CN9_DTINIC)
		XLS->CN9_DTFIM  := SToD(IATRB->CN9_DTFIM)
		XLS->CN9_VLATU  := IATRB->CN9_VLATU
		XLS->CN9_SALDO  := IATRB->CN9_SALDO
		XLS->CND_XEMPRE := IATRB->CND_XEMPRE
		XLS->CND_XFILIA := IATRB->CND_XFILIA
		XLS->CND_NUMMED := IATRB->CND_NUMMED
		XLS->CND_VLTOT  := IATRB->CN9_SALDO
		XLS->CND_DTINIC := SToD(IATRB->CND_DTINIC)
		XLS->CND_PEDIDO := IATRB->CND_PEDIDO
	    XLS->(MsUnlock())
     EndIf
Return

Static Function fImpRel()
	//seleciono o arquivo de trabalho gerado pela query e coloco no inicio
	dbSelectArea("XLS")
	XLS->(dbGoTop())

	//Seta o contador da regua
	oReport:SetMeter(XLS->(RecCount()))	

	//Posiciona no primeiro registro
	dbSelectArea("XLS")
	XLS->(dbGoTop())
	
	//Inicializa a Se��o
	oSection:Init()

	Do While !XLS->(Eof())
		//Verifica se Cancelou
		If oReport:Cancel()
			Exit
		EndIf

		/*Processa as informa��es da tabela principal ou 
		da query definida pelo Embedded SQL com os m�todos BeginQuery e EndQuery*/
		oSection:PrintLine()

		/*Incrementa a r�gua da tela de processamento do relat�rio*/
		oReport:IncMeter()

		dbSelectArea("XLS")
		XLS->(dbSkip())
	EndDo

	oSection:Finish()

Return

Static Function fCloseArea(pCodTab)

	If (Select(pCodTab)!= 0)
		dbSelectArea(pCodTab)
		dbCloseArea()
		If File(pCodTab+GetDBExtension())
			FErase(pCodTab+GetDBExtension())
		EndIf
	EndIf

Return