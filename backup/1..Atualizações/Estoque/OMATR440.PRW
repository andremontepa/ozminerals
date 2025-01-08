#INCLUDE "MATR440.CH"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATRa440  ³ Autor ³ Alexandre Inacio Lemes³ Data ³02/06/2006³±±
                                   S GEDOLINT TEC                12/2021
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Lista os itens que atingiram o ponto de pedido.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MATR440(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³        ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Eduardo Fern³24.07.06³XXXXXX³Inclusao mv_par19 (Seleciona Filiais ?)   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
user Function OMATR440()
Local oReport

oReport := ReportDef()
If Isblind()
     oReport:nfontbody:=5
EndIf
oReport:PrintDialog()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ ReportDef³Autor  ³Alexandre Inacio Lemes ³Data  ³02/06/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Lista os itens que atingiram o ponto de pedido.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nExp01: nReg = Registro posicionado do SC3 apartir Browse  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ oExpO1: Objeto do relatorio                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()

Local oReport
Local oSection1
Local cAliasSB1 := GetNextAlias()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01             // Produto de                           ³
//³ mv_par02             // Produto ate                          ³
//³ mv_par03             // Grupo de                             ³
//³ mv_par04             // Grupo ate                            ³
//³ mv_par05             // Tipo de                              ³
//³ mv_par06             // Tipo ate                             ³
//³ mv_par07             // Local de                             ³
//³ mv_par08             // Local ate                            ³
//³ mv_par09             // Considera Necess Bruta   1 - Sim     ³ Pto Pedido
//³ mv_par10             // Saldo Neg Considera      1 - Sim     ³ Lote Economico
//³ mv_par11             // Considera C.Q.           1 - Sim     ³
//³ mv_par12             // Cons.Qtd. De 3os.? Sim / Nao         ³
//³ mv_par13             // Cons.Qtd. Em 3os.? Sim / Nao         ³
//³ mv_par14             // Qtd. PV nao Liberado ?" Subtr/Ignora ³
//³ mv_par15             // Descricao completa do produto?       ³
//³ mv_par16             // Considera Saldo Armazem de           ³
//³ mv_par17             // Considera Saldo Armazem ate          ³
//³ mv_par18             // Data limite p/ empenhos              ³
//³ mv_par19             // Seleciona Filiais ? (Sim/Nao)        ³
//³ mv_par20    		 // Considera Est. Seguranca ?  (Sim/Nao)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte("MTR440",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³                                                                        ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport := TReport():New("MTR440",STR0005,"MTR440",{|oReport| ReportPrint(oReport,cAliasSB1)},STR0001+" "+STR0002) //"Emite uma relacao com os itens em estoque que atingiram o Ponto de Pedido ,sugerindo a quantidade a comprar."
oReport:SetTotalInLine(.F.)
oReport:SetTotalText(STR0010) // "TOTAL GERAL A COMPRAR"
oReport:SetLandscape()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da secao utilizada pelo relatorio                               ³
//³                                                                        ³
//³TRSection():New                                                         ³
//³ExpO1 : Objeto TReport que a secao pertence                             ³
//³ExpC2 : Descricao da seçao                                              ³
//³ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   ³
//³        sera considerada como principal para a seção.                   ³
//³ExpA4 : Array com as Ordens do relatório                                ³
//³ExpL5 : Carrega campos do SX3 como celulas                              ³
//³        Default : False                                                 ³
//³ExpL6 : Carrega ordens do Sindex                                        ³
//³        Default : False                                                 ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da celulas da secao do relatorio                                ³
//³                                                                        ³
//³TRCell():New                                                            ³
//³ExpO1 : Objeto TSection que a secao pertence                            ³
//³ExpC2 : Nome da celula do relatório. O SX3 será consultado              ³
//³ExpC3 : Nome da tabela de referencia da celula                          ³
//³ExpC4 : Titulo da celula                                                ³
//³        Default : X3Titulo()                                            ³
//³ExpC5 : Picture                                                         ³
//³        Default : X3_PICTURE                                            ³
//³ExpC6 : Tamanho                                                         ³
//³        Default : X3_TAMANHO                                            ³
//³ExpL7 : Informe se o tamanho esta em pixel                              ³
//³        Default : False                                                 ³
//³ExpB8 : Bloco de código para impressao.                                 ³
//³        Default : ExpC2                                                 ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1:= TRSection():New(oReport,STR0030,{"SB1"},/*aOrdem*/) // "Produtos"
oSection1:SetHeaderPage()

TRCell():New(oSection1,"B1_COD"  ,"SB1",/*Titulo*/	,/*Picture*/						,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"B1_DESC" ,"SB1",/*Titulo*/	,/*Picture*/						,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"B1_TIPO" ,"SB1",STR0042		,/*Picture*/						,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"B1_GRUPO","SB1",/*Titulo*/	,/*Picture*/						,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"B1_UM"   ,"SB1",STR0043		,/*Picture*/						,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"SLDPRV"  ,"   ",STR0019		,PesqPictQt("B1_LE",12)				,TamSX3("B2_QATU")[1],/*lPixel*/,{|| nEstoque })
TRCell():New(oSection1,"PREVIS"  ,"   ","Qt. SC/PC"	,PesqPict("SB2","B2_SALPEDI",12)	,TamSX3("B2_SALPEDI")[1],/*lPixel*/,{|| nPrevis },,,"RIGHT") //"Entrada "##"Prevista"
TRCell():New(oSection1,"QTDESA"  ,"   ","Qt. SA"	,PesqPict("SB2","B2_QEMPSA",12)		,TamSX3("B2_QEMPSA")[1],/*lPixel*/,{|| nQtdeSA },,,"RIGHT") //"Entrada "##"Prevista"
TRCell():New(oSection1,"B1_EMIN" ,"SB1","Estoq Minimo" /*Titulo*/	,/*Picture*/						,/*Tamanho*/,/*lPixel*/,{|| RetFldProd((cAliasSB1)->B1_COD,"B1_EMIN",cAliasSB1)},,,"RIGHT")
//TRCell():New(oSection1,"ESTSEG"  ,"   ",STR0021+CRLF+STR0031,PesqPictQt("B1_ESTSEG",12)			,TamSX3("B1_ESTSEG")[1],/*lPixel*/,{|| nESTSEG },,,"RIGHT") //"Estoque"##"de Seguranca"
TRCell():New(oSection1,"B1_LE"   ,"SB1","Estoq Máximo" /*Titulo*/	,PesqPictQt("B1_LE",12)				,/*Tamanho*/,/*lPixel*/,{|| RetFldProd((cAliasSB1)->B1_COD,"B1_EMAX",cAliasSB1)},,,"RIGHT")
//TRCell():New(oSection1,"B1_QE"   ,"SB1",STR0040+CRLF+STR0041,PesqPictQt("B1_LE",12)				,/*Tamanho*/,/*lPixel*/,{|| RetFldProd((cAliasSB1)->B1_COD,"B1_QE",cAliasSB1)},,,"RIGHT") //"Qtde. por "##"Embalagem"
TRCell():New(oSection1,"QUANT"   ,"   ",STR0023+CRLF+STR0024,PesqPictQt("B1_LE",12)				,TamSX3("C1_QUANT")[1],/*lPixel*/,{|| nQuant },,,"RIGHT") //"Quantidade"##" a Comprar"
TRCell():New(oSection1,"VALOR"   ,"   ",STR0032+CRLF+STR0033,TM(0,16)							,TamSX3("B2_VATU1")[1],/*lPixel*/,{|| (nQuant) * IIf( RetFldProd((cAliasSB1)->B1_COD,"B1_UCOM",cAliasSB1) < (cAliasSB1)->B1_DATREF , RetFldProd((cAliasSB1)->B1_COD,"B1_CUSTD",cAliasSB1) ,RetFldProd((cAliasSB1)->B1_COD,"B1_UPRC",cAliasSB1)) },,,"RIGHT") //"Vlr.Estimado"##" da Compra"
TRCell():New(oSection1,"TIPOVAL" ,"   ",STR0025	,/*Picture*/						,4,/*lPixel*/,{|| cTipoVal := IIf( RetFldProd((cAliasSB1)->B1_COD,"B1_UCOM",cAliasSB1) < (cAliasSB1)->B1_DATREF , "STD" , "U.CO" ) })
TRCell():New(oSection1,"DATA"    ,"   ",STR0026+CRLF+STR0036,/*Picture*/						,TamSX3("C1_DATPRF")[1],/*lPixel*/,{|| dData := IIf( RetFldProd((cAliasSB1)->B1_COD,"B1_UCOM",cAliasSB1) < (cAliasSB1)->B1_DATREF,(cAliasSB1)->B1_DATREF, RetFldProd((cAliasSB1)->B1_COD,"B1_UCOM",cAliasSB1)) },,,"CENTER") //"Data de "##"Referencia"
TRCell():New(oSection1,"VALUNIT" ,"   ",STR0027+CRLF+STR0028,TM(0,14)							,TamSX3("B2_VATU1")[1],/*lPixel*/,{|| nValUnit := IIf( RetFldProd((cAliasSB1)->B1_COD,"B1_UCOM",cAliasSB1) < (cAliasSB1)->B1_DATREF , RetFldProd((cAliasSB1)->B1_COD,"B1_CUSTD",cAliasSB1) ,RetFldProd((cAliasSB1)->B1_COD,"B1_UPRC",cAliasSB1)) },,,"RIGHT") //"Vlr.Unitario"##" da Compra"
TRCell():New(oSection1,"PRAZO"   ,"   ",STR0034+CRLF+STR0044+CRLF+STR0045,/*Picture*/						,TamSX3("B1_PE")[1],/*lPixel*/,{|| nPrazo := CalcPrazo((cAliasSB1)->B1_COD,nQuant)},,,"RIGHT") // "Prazo Entrega"##" em Dias"

TRFunction():New(oSection1:Cell("VALOR"),NIL,"SUM",/*oBreak*/,,/*cPicture*/,/*uFormula*/,.F.,.T.) //"TOTAL GERAL A COMPRAR"

Return(oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrin³ Autor ³Alexandre Inacio Lemes ³Data  ³05/06/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Lista os itens que atingiram o ponto de pedido.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatório                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPrint(oReport,cAliasSB1)

Local oSection1 := oReport:Section(1)
Local cLocCQ    := GetMvNNR('MV_CQ','98')
Local nNeces    := 0
Local nAuxQuant := 0
Local nSaldAux	:= 0

//Local nX        := 0
Local lValidSB1 := .T.
//Local lQtdPrev  := SuperGetMV('MV_QTDPREV')
Local lArqSBZ   := AllTrim(SuperGetMV("MV_ARQPROD",.F.,"SB1")) == "SBZ"

Local lMR440QTD := ExistBlock( "MR440QTD" )
Local lMT170SB1 := ExistBlock( "MT170SB1" )
Local lMT170Sld := ExistBlock( "MT170SLD" )

Local lMT170QRY := ExistBlock( "MT170QRY" )
Local cSelect 	:= ""
Local cSelectPE := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Tratamento da impressao por Filiais³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aFilsCalc :={}
Local nForFilial:= 0
Local cFilBack  := cFilAnt


Private cTipoVal := ""
Private nQuant   := 0
Private nSaldo   := 0
Private nEstoque := 0 
Private nQtdeSA	 := 0 
Private nQtdePCS := 0 
Private nValUnit := 0
Private nValor   := 0
Private nPrazo   := 0
Private nToler   := 0
Private nEstSeg  := 0
Private nPrevis  := 0
Private cFilSB2  := ""
Private cLocSB2  := ""

// Funcao para a escolha de filiais
If !IsBlind()
	aFilsCalc:= MatFilCalc( mv_par19 == 1 )
EndIf

If !Empty( aFilsCalc ) .OR. IsBlind()

	If IsBlind()
		dbSelectArea("SM0")
		dbSeek(cEmpAnt+cFilAnt)
		aFilsCalc := {{.T.,SM0->M0_CODFIL,SM0->M0_FILIAL,SM0->M0_CGC}}
	Endif

	For nForFilial := 1 to Len(aFilsCalc)

		If aFilsCalc[nForFilial,1]

			// Altera filial corrente
			cFilAnt := aFilsCalc[nForFilial,2]

			oReport:SetTitle( STR0005 + " - " + aFilsCalc[ nForFilial, 3 ] ) //Titulo do Relatorio

			oReport:EndPage() // Reinicia Paginas

			dbSelectArea("SB1")
			dbSetOrder(1)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Filtragem do relatório                                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MakeSqlExpr(oReport:uParam)

			cSelect := "SB1.* FROM " + RetSqlName("SB1")+" SB1 "
			If lArqSBZ
				cSelect += "LEFT JOIN "  + RetSqlName("SBZ")+" SBZ ON SBZ.BZ_FILIAL = '"+xFilial("SBZ")+"'  AND	"
				cSelect += "SB1.B1_COD = SBZ.BZ_COD AND  SBZ.D_E_L_E_T_ = ' ' "
			EndIf
			cSelect += "WHERE SB1.B1_FILIAL ='"+xFilial("SB1")+"' AND "
			cSelect += "SB1.B1_COD    >='" +mv_Par01+"' AND SB1.B1_COD <='"   +mv_Par02+"' AND "
			cSelect += "SB1.B1_GRUPO  >='" +mv_Par03+"' AND SB1.B1_GRUPO <='" +mv_Par04+"' AND "
			cSelect += "SB1.B1_TIPO   >='" +mv_Par05+"' AND SB1.B1_TIPO <='"  +mv_Par06+"' AND "
			If !lArqSBZ
				cSelect += "SB1.B1_LOCPAD >='" +mv_Par07+"' AND SB1.B1_LOCPAD <='"+mv_Par08+"' AND "
			Else
				cSelect += "((SB1.B1_LOCPAD >='" +mv_Par07+"' AND SB1.B1_LOCPAD <= '"+mv_Par08+"' ) OR "
				cSelect += "(SBZ.BZ_LOCPAD >='" +mv_Par07+"' AND SBZ.BZ_LOCPAD <= '"+mv_Par08+"' )) AND "
				If SBZ->(FieldPos("BZ_MSBLQL")) > 0
					cSelect += " "+MATIsNull()+"(SBZ.BZ_MSBLQL,SB1.B1_MSBLQL) <>'1' AND "
				Else
					cSelect += "SB1.B1_MSBLQL <>'1' AND " 
				EndIf
			EndIf

			cSelect += "SB1.B1_MSBLQL <>'1' AND "
			cSelect += "SB1.B1_CONTRAT <> 'S' AND SB1.B1_TIPO <> 'BN' AND "
			cSelect += "SB1.D_E_L_E_T_ = ' ' "
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ MT170QRY - Ponto de Entrada p/ manipulacao da Query - filtro em SB1	 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lMT170QRY
				cSelectPE := Execblock('MT170QRY', .F., .F., {"SELECT "+cSelect})
				If ValType(cSelectPE)=='C' .And. AT("SELECT ",cSelectPE) > 0
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Devido Embedded SQL, retira-se o SELECT da expressao da query         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cSelect := Substr(cSelectPE,AT("SELECT ",cSelectPE)+7,Len(cSelectPE)-7)
				EndIf
			Endif
			cSelect := "%"+cSelect+"%"

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Query do relatório da secao 1                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oReport:Section(1):BeginQuery()

			BeginSql Alias cAliasSB1

			    SELECT %Exp:cSelect%

				ORDER BY %Order:SB1%

			EndSql
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Metodo EndQuery ( Classe TRSection )                                    ³
			//³                                                                        ³
			//³Prepara o relatório para executar o Embedded SQL.                       ³
			//³                                                                        ³
			//³ExpA1 : Array com os parametros do tipo Range                           ³
			//³                                                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)


			oReport:SetMeter(SB1->(LastRec()))
			oSection1:Init()

			dbSelectArea(cAliasSB1)
			While !oReport:Cancel() .And. !(cAliasSB1)->(Eof())

				oReport:IncMeter()

				If oReport:Cancel()
					Exit
				EndIf

				If IsProdMod((cAliasSB1)->B1_COD)
					(cAliasSB1)->(dbSkip())
					Loop
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ MT170SB1 - Ponto de entrada para validar o produto        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lMT170SB1
					lValidSB1 := ExecBlock("MT170SB1",.F.,.F.,{cAliasSB1})
					If ValType( lValidSB1 ) == "L" .And. !lValidSB1
						(cAliasSB1)->(dbSkip())
						Loop
					EndIf
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Calcula o saldo atual de todos os almoxarifados ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SB2")
				dbSetOrder(1)
				dbSeek( xFilial("SB2") + (cAliasSB1)->(B1_COD) )
				While !Eof() .And. SB2->(B2_FILIAL + B2_COD) == (cAliasSB1)->(ZD_FILIAL+B1_COD)

			        If ( SB2->B2_LOCAL >= mv_par16 .And. SB2->B2_LOCAL <= mv_par17 ) .And. !( SB2->B2_LOCAL == cLocCQ .And. mv_par11 == 2 )
						nEstoque += SB2->B2_QATU //(SaldoSB2(Nil,Nil,If(Empty(mv_par18),dDataBase,mv_par18),mv_par12==1,mv_par13==1)+SB2->B2_SALPEDI+SB2->B2_QACLASS+IIF(lQtdPrev="S",B2_SALPPRE,0))
						//If mv_par14 == 1
						//	nSaldo -= SB2->B2_QPEDVEN
						//EndIf

						nPrevis += SB2->B2_SALPEDI
						nQtdeSA += SB2->B2_QEMPSA

						cFilSB2  := SB2->B2_FILIAL
						cLocSB2  := SB2->B2_LOCAL
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ MT170SLD - Ponto de Entrada p/ manipulacao do saldo do produto    	 ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lMT170Sld
							nSaldAux := ExecBlock("MT170SLD",.F.,.F.,{nEstoque,SB2->B2_COD,SB2->B2_LOCAL})
							If ValType(nSaldAux) == 'N'
								nEstoque := nSaldAux
							EndIf
						Endif

			        EndIf

					dbSelectArea("SB2")
					dbSkip()
				EndDo

				//nEstSeg := CalcEstSeg( RetFldProd((cAliasSB1)->B1_COD,"B1_ESTFOR",cAliasSB1),cAliasSB1 )

				//If mv_par20 == 1
				//	nSaldo -= nEstSeg
				//EndIf

				nSaldo := nEstoque - nQtdeSA + nPrevis

//				If (Round(nSaldo,4) <> 0) .Or. (mv_par09 == 1)
//					Do Case
//						Case ( RetFldProd((cAliasSB1)->B1_COD,"B1_EMIN",cAliasSB1) != 0 .And. MV_PAR09 == 1 )

							/*
							If ( mv_par10 == 2 .And. nSaldo < 0 )
								nSaldo -= RetFldProd((cAliasSB1)->B1_COD,"B1_LE",cAliasSB1)
							EndIf

							nNeces := If((nSaldo < 0),Abs(nSaldo)+RetFldProd((cAliasSB1)->B1_COD,"B1_EMIN",cAliasSB1),;
									(If(QtdComp(nSaldo)==QtdComp(RetFldProd((cAliasSB1)->B1_COD,"B1_EMIN",cAliasSB1)),1,0);
									+RetFldProd((cAliasSB1)->B1_COD,"B1_EMIN",cAliasSB1)-nSaldo))

						    //-- Soma 1 na quantidade da necessidade:
						    //-- Ex: Ponto Pedido = 10 e Estoque = 9, ao inves de gerar 2 SCs de 1 pc ira gera 1 SC de 2 pcs (para sair do ponto de pedido)
							If nSaldo <  QtdComp(RetFldProd((cAliasSB1)->B1_COD,"B1_EMIN",cAliasSB1)) //-- Se o Saldo for menor que o Ponto do Pedido
								nNeces += 1
							EndIf
							*/
							if abs(nSaldo) >= (cAliasSB1)->B1_EMIN .AND. abs(nSaldo) <= (cAliasSB1)->B1_EMAX

								nNeces:= 0

							else
								if abs(nSaldo) < (cAliasSB1)->B1_EMIN

									nNeces := (cAliasSB1)->B1_EMAX - abs(nSaldo)

								else
									nNeces := 0 //para caso o Estoque atual for > extoque máximo 

								Endif
							Endif

							nQuant := nNeces

/*						Case ( RetFldProd((cAliasSB1)->B1_COD,"B1_EMIN",cAliasSB1) != 0 .And. MV_PAR09 == 2 )

							If ( mv_par10 == 2 .And. nSaldo < 0 )
								nSaldo -= RetFldProd((cAliasSB1)->B1_COD,"B1_LE",cAliasSB1)
							EndIf

							nNeces := If((nSaldo < 0),Abs(nSaldo),;
										(If(QtdComp(nSaldo) ==  QtdComp(RetFldProd((cAliasSB1)->B1_COD,"B1_EMIN",cAliasSB1)),1,0);
										+RetFldProd((cAliasSB1)->B1_COD,"B1_EMIN",cAliasSB1)-nSaldo))

						    //-- Soma 1 na quantidade da necessidade:
						    //-- Ex: Ponto Pedido = 10 e Estoque = 9, ao inves de gerar 2 SCs de 1 pc ira gera 1 SC de 2 pcs (para sair do ponto de pedido)
							If nSaldo <  QtdComp(RetFldProd((cAliasSB1)->B1_COD,"B1_EMIN",cAliasSB1)) //-- Se o Saldo for menor que o Ponto do Pedido
								nNeces += 1
							EndIf

						Case ( RetFldProd((cAliasSB1)->B1_COD,"B1_LE",cAliasSB1) != 0 .And. (nSaldo < 0  .or. mv_par09 == 2) )

							If ( mv_par10 == 2 .And. nSaldo < 0 )
								nNeces := Abs(nSaldo)+RetFldProd((cAliasSB1)->B1_COD,"B1_LE",cAliasSB1)
							Else
								nNeces := If( Abs(nSaldo)<RetFldProd((cAliasSB1)->B1_COD,"B1_LE",cAliasSB1),RetFldProd((cAliasSB1)->B1_COD,"B1_LE",cAliasSB1),if(nSaldo<0,Abs(nSaldo),0))
							EndIf

						OtherWise

							nNeces := IF(mv_par09 == 1,IIf(nSaldo<0,Abs(nSaldo)+1,0),0)
					EndCase
				Else
					If RetFldProd((cAliasSB1)->B1_COD,"B1_EMIN",cAliasSB1) != 0
						nNeces := ( RetFldProd((cAliasSB1)->B1_COD,"B1_EMIN",cAliasSB1) )
						nNeces += 1
					Else
						nNeces := 0
					EndIf
				EndIf

				If nNeces > 0
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica se o produto tem estrutura                       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea("SG1")
					If dbSeek( xFilial("SG1")+(cAliasSB1)->B1_COD )
						aQtdes := CalcLote((cAliasSB1)->B1_COD,nNeces,"F")
					Else
						aQtdes := CalcLote((cAliasSB1)->B1_COD,nNeces,"C")
					Endif
					For nX := 1 to Len(aQtdes)
						nQuant += aQtdes[nX]
					Next
				EndIf
*/
				dbSelectArea(cAliasSB1)
				dbSetOrder(oSection1:GetIdxOrder())

				If lMR440QTD
					nAuxQuant := Execblock("MR440QTD",.f.,.f.,NQUANT)
					If ValType(nAuxQuant) == "N"
						nQuant := nAuxQuant
					EndIf
				EndIf

				If nQuant > 0
					oSection1:PrintLine()
				EndIf

				nSaldo := 0
				nQuant := 0
				nPrevis:= 0
				nNeces := 0
				nQtdeSA:= 0 
				nEstoque := 0

				dbSelectArea(cAliasSB1)
				dbSkip()

			EndDo

		EndIf

	Next nForFilial

	oSection1:Finish()

EndIf

// Restaura filial original apos processamento
cFilAnt:=cFilBack

Return NIL
