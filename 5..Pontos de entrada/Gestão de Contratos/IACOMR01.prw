#include 'protheus.ch'
#include 'parmtype.ch'
#include 'totvs.ch'
#INCLUDE 'topconn.ch'
#INCLUDE 'prtopdef.ch'

#define cEndLin Chr(13) + Chr(10)
//-------------------------------------------------------------------------------
/* {Protheus.doc} IACOMR01
Programa - Relatorio de Medicoes de Contratos Globais
Copyright I AGE© - Inteligência Andrews
@type function
@author Felipe Andrews de Almeida
@since 01/2021
@version Lobo Guara v.12.1.23
*/
//-------------------------------------------------------------------------------
User Function IACOMR01()
	/* Variaveis criadas para classes TReport */
	Private oReport, oSection, oSection2
	Private cTitRel := "Relatório de Mediçoes de Contratos Globais" /* Titulo do Relatório */
	Private cNomPro := "IACOMR01" /* Nome do Programa do Relatório */
	Private cRelPrg := "IACOMR01" /* Nome do Grupo de Perguntas do Relatório */

	/* Variáveis representantes de parâmetros */
	Private cConIni := Space(TamSX3("CN9_NUMERO")[01]) /* Contrato Inicial */
	Private cConFin := Space(TamSX3("CN9_NUMERO")[01]) /* Contrato Final */
	Private cRevIni := Space(TamSX3("CN9_REVISA")[01]) /* Revisao Inicial */
	Private cRevFin := Space(TamSX3("CN9_REVISA")[01]) /* Revisao Final */
	Private cDtaIni := Space(TamSX3("CND_DTINIC")[01]) /* Data Inicial */
	Private cDtaFin := Space(TamSX3("CND_DTINIC")[01]) /* Data Final */
	Private oTabTemp	:= Nil 

	/* fGerPrg(). Chamada de Função para Criar as Perguntas. */
	Processa({||fGerPrg()},"Aguarde...","Gerando Parâmetros...")

	/* Chama a função CriaStru para Criar a estrutura XLS do relatór. */
	Processa({||fGerStr()},"Aguarde...","Gerando Estrutura...")

	/* Chama a função fTReport para Criar o relatório no Padrão TRep. */
	If Pergunte(cRelPrg,.T.)
		Processa({||fTReport()},"Aguarde...","Gerando Relatório...")
		oReport:PrintDialog()
	EndIf
	oTabTemp:Delete()
Return

/*/{Protheus.doc} CRIA_PAR
Cria os parametros das perguntas na tabela SX1.
@type function
@author Ricardo Tavares Ferreira
@since 17/08/2021
@version 12.1.25
@history 17/08/2021, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//====================================================================================================
   Static Function fGerPrg()
//====================================================================================================

    Local aPergs	    := {}
    Local aRet		    := {}
    Local lRet		    := .T.
    Private cCadastro   := "Perguntas"

	aadd( aPergs , { 1 , "Contrato De"	, Space(TamSx3("CN9_NUMERO")[1])	, "" , "" , "CN9" , "" , 50	, .F. } ) //MV_PAR01
	aadd( aPergs , { 1 , "Contrato Até"	, Space(TamSx3("CN9_NUMERO")[1])	, "" , "" , "CN9" , "" , 50	, .T. } ) //MV_PAR02
	aadd( aPergs , { 1 , "Revisao De"	, Space(TamSx3("CN9_REVISA")[1])	, "" , "" , "" , "" , 50	, .F. } ) //MV_PAR03
	aadd( aPergs , { 1 , "Revisao Ate"	, Space(TamSx3("CN9_REVISA")[1])	, "" , "" , "" , "" , 50	, .T. } ) //MV_PAR04
	aadd( aPergs , { 1 , "Data de"		, DdataBase					        , "" , "" , ""	  , "" , 50	, .T. } ) //MV_PAR05
	aadd( aPergs , { 1 , "Data Ate"		, DdataBase					        , "" , "" , ""	  , "" , 50	, .T. } ) //MV_PAR06
  
	If .not. ParamBox(aPergs,"Relatorio de Medicoes de Contratos Globais",aRet,/*bValid*/,/*aButtons*/,.T.,/*nPosX*/,/*nPosY*/,/*oDialog*/,"IACOMR01",.T.,.T.)
		lRet := .F.
	EndIf 
Return lRet

Static Function fGerStr()
	Local aStrXls := {} /* Strutura de Arquivo de trabalho XLS */

	/* Variáveis que receberão os valores do layout necessitado no relatório */
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

	oTabTemp := FWTemporaryTable():New("XLS", aStrXls)
	oTabTemp:AddIndex("01","CN9_FILIAL+CN9_NUMERO+CN9_REVISA")
	oTabTemp:Create()

Return

Static Function fTReport()

	/* A classe TReport permite que o usuário personalize as informações que serão apresentadas 
	   no relatório, alterando fonte (tipo, tamanho, etc), cor, tipo de linhas, cabeçalho, rodapé, etc.*/
   
   // ALTEAÇÃO MARIO 20/12 oReport := TReport():New(cNomPro,cTitRel,/*cRelPrg*/,{|oReport| fGerTmp()},"Este relatório irá imprimir o Faturamento de Cliente")
	oReport := TReport():New(cNomPro,cTitRel,cRelPrg,{|oReport| fGerTmp()},"Este relatório irá imprimir a Relação de Contratos Globais e suas mediçoes")
	Pergunte(cRelPrg,.F.)
	oReport:SetPortrait()
	oReport:SetTotalInLine(.F.)

	/* A classe TRSection pode ser entendida como um layout do relatório, por conter 
	   células, quebras e totalizadores que darão um formato para sua impressão. */
	//TRSection():New ( < oParent > , [ cTitle ] , [ uTable ] , [ aOrder ] , [ lLoadCells ] , [ lLoadOrder ] ) --> TRSection
	oSection := TRSection():New(oReport,"Relatório de Contratos",{"XLS"},{"Contrato"})
	//oSection2 := TRSection():New(oSection,"Contratos",{"XL2","Contratos"})

	/*Se o nome da célula informada pelo parametro for encontrado no Dicionário de
	Campos (SX3), as informações do campo serão carregadas para a célula, respeitando
	os parametros de título, picture e tamanho. Dessa forma o relatório sempre estará
	atualizado com as informações do Dicionário de Campos (SX3).*/
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

//	TRCell():New(oSection2,"TMP_CODCO2","XL2","CONTRATO","",TamSX3("Z1_NUM")[01]) //Código do Pedido de Venda
//	TRCell():New(oSection2,"TMP_CLIENT","XL2","CLIENTE","",50) //Cliente

	/* neste caso verifica o arquivo de trabalho gerado e faz a exclusão
	dos dados e da tabela temporária */
	fCloseArea("IATRB")

Return

Static Function fGerTmp()
	Local cQrySql := "" //Variavel na qual é armazenado a query de consulta ao banco

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

	/* Chama a função fProTmp para processar temporario e gravar. */
	Processa({||fProTmp()},"Aguarde...","Gravando Informações...")

	/* Chama a função fImpRel para Imprimir informações do Relatorio */
	fImpRel()

Return  

Static Function fProTmp()
	Local nTotReg := 0 /* Quantidade total de Registros */
	Local nRegLid := 0 /* Quantidade de Registros lidos */
	Private nTotMed := 0 /* Total das Médias */

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

		/* Chama a função fGrvTmp para Gravar o Tmp. no Arq. Trab. XLS. */
		fGrvTmp()

		/* seleciono o arquivo de trabalho gerado pela query e coloco no inicio */
		dbSelectArea("IATRB")
		/* avança para proximo registro */
		IATRB->(dbSkip())
		/* atualiza contador da régua */
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
	
	//Inicializa a Seção
	oSection:Init()

	Do While !XLS->(Eof())
		//Verifica se Cancelou
		If oReport:Cancel()
			Exit
		EndIf

		/*Processa as informações da tabela principal ou 
		da query definida pelo Embedded SQL com os métodos BeginQuery e EndQuery*/
		oSection:PrintLine()

		/*Incrementa a régua da tela de processamento do relatório*/
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
