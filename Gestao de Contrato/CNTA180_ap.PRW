#include "rwmake.ch"        // incluido pelo assistente de conversao do AP6 IDE em 15/05/20
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "CNTA180.CH"
#INCLUDE 'TOPCONN.CH'

User Function CNTA180A()        // incluido pelo assistente de conversao do AP6 IDE em 15/05/20

	Local aCores := {	{ "Alltrim(CN9->CN9_SITUAC) == '01'", "BR_VERMELHO" },;		// Cancelado
	{ "Alltrim(CN9->CN9_SITUAC) == '02'", "BR_AMARELO"	 },;	// Elaboracao
	{ "Alltrim(CN9->CN9_SITUAC) == '03'", "BR_AZUL"		 },;	// Emitido
	{ "Alltrim(CN9->CN9_SITUAC) == '04'", "BR_LARANJA"	 },;	// Em Aprovacao
	{ "Alltrim(CN9->CN9_SITUAC) == '05'", "BR_VERDE"	 },;	// Vigente
	{ "Alltrim(CN9->CN9_SITUAC) == '06'", "BR_CINZA"	 },;	// Paralisado
	{ "Alltrim(CN9->CN9_SITUAC) == '07'", "BR_MARRON"	 },;	// Sol. Finalizacao
	{ "Alltrim(CN9->CN9_SITUAC) == '08'", "BR_PRETO"	 },;	// Finalizado
	{ "Alltrim(CN9->CN9_SITUAC) == '09'", "BR_PINK"		 },;	// Revisao
	{ "Alltrim(CN9->CN9_SITUAC) == '10'", "BR_BRANCO"	 }}		// Revisado

	Private cCadastro	:= STR0001 //"Avaliação de Contratos"
	Private cFiltro		:= Nil
	Private aAcho		:= {}
	Private aRotina 	:= MenuDef()
	Private	lVisAval	:= .F.

	DEFAULT nPosArotina := 0

	//Array com os campos que irao aparecer na enchoice
	AADD(aAcho, "COA_CONCEI")
	AADD(aAcho, "COA_OCORRE")
	AADD(aAcho, "COA_DESOCO")
	AADD(aAcho, "COA_DTAVAL")
	AADD(aAcho, "COA_OBSERV")

	/*If nPosArotina > 0 // Sera executada uma opcao diretamento de aRotina, sem passar pela mBrowse
	dbSelectArea("CN9")
	bBlock := &( "{ |a,b,c| " + aRotina[ nPosArotina,2 ] + "(a,b,c) }" )
	Eval( bBlock, Alias(), (Alias())->(Recno()),nPosArotina)

	Else*/
	// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	// ³Cria indice condicianal para a Localizacoes ³
	// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("CN9")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endereca a Funcao de BROWSE                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	mBrowse(6,1,22,75,"CN9",,,,,,aCores,,,,,,,,,,,,cFiltro)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Recupera a Integridade dos dados                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RetIndex("CN9")
	dbSetOrder(1)
	Set Filter to

	If nPosArotina == 0
		dbSeek(xFilial())
	Endif
	//EndIf



RETURN

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Mauricio Pequim Jr    ³ Data ³17/11/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³	  1 - Pesquisa e Posiciona em um Banco de Dados		  	  ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
// Substituido pelo assistente de conversao do AP6 IDE em 15/05/20 ==> Static Function MenuDef()
Static Function MenuDef()
	Local aRotina := {	{ STR0003 	,"AxPesqui"		, 0 , 1,,.F.},;		//"Pesquisar"
	{ STR0004	,"CN180Vis"		, 0 , 2, 0, NIL},;	//"Visualizar"
	{ STR0005	,"CN180Aval"	, 0 , 3, 0, NIL},;	//"Avaliar"
	{ 'Relatorio',"U_CNTA080R"	, 0 , 6, 0, NIL},;	//"Relatorio"
	{ 'Conhecimento',"MsDocument", 0 , 4, 0, NIL},;	//"Relatorio"
	{ STR0007	,"CN180Leg"		, 0 , 2, 0, NIL}}	//"Legenda"

Return(aRotina)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ CN180Leg  ³ Autor ³ TOTVS                 ³ Data ³06.07.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Legenda da Avaliacao de execucao de contratos			   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN180Leg()							                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTA180                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// Substituido pelo assistente de conversao do AP6 IDE em 15/05/20 ==> Function CN180Leg()
Static Function CN180Leg()

	Local aLegenda := {}

	aAdd(aLegenda,{"BR_VERMELHO",OemToAnsi(STR0008)})   //"Cancelado"
	aAdd(aLegenda,{"BR_AMARELO"	,OemToAnsi(STR0009)})   //"Elaboracao"
	aAdd(aLegenda,{"BR_AZUL"	,OemToAnsi(STR0010)})   //"Emitido"
	aAdd(aLegenda,{"BR_LARANJA"	,OemToAnsi(STR0011)})   //"Em Aprovacao"
	aAdd(aLegenda,{"BR_VERDE"	,OemToAnsi(STR0012)})   //"Vigente"
	aAdd(aLegenda,{"BR_CINZA"	,OemToAnsi(STR0013)})	//"Paralisado"
	aAdd(aLegenda,{"BR_MARRON"	,OemToAnsi(STR0014)})	//"Sol. Finalizacao"
	aAdd(aLegenda,{"BR_PRETO"	,OemToAnsi(STR0015)})   //"Finalizado"
	aAdd(aLegenda,{"BR_PINK"	,OemToAnsi(STR0016)})   //"Revisao"
	aAdd(aLegenda,{"BR_BRANCO"	,OemToAnsi(STR0017)})	//"Revisado"

	BrwLegenda(cCadastro,OemToAnsi(STR0007),aLegenda)   //"Legenda"

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN180Vis  ³ Autor ³ William Pires    ³ 	   Data ³20.08.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Executa a funcao CN180AVAL em modo de visualizacao		   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN180Vis()							                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTA180                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// Substituido pelo assistente de conversao do AP6 IDE em 15/05/20 ==> Function CN180Vis
Static Function CN180Vis()

	lVisAval := .T.

Return CN180AVAL()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN180AVAL  ³ Autor ³ Mauricio Pequim Jr    ³ Data ³06.07.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Avaliacao de execucao de contratos						   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN180AVAL()							                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTA180                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// Substituido pelo assistente de conversao do AP6 IDE em 15/05/20 ==> Function CN180AVAL()
Static Function CN180AVAL()

	Local oFWLayer		:= NIL
	Local oButtonBar
	Local oMenuPop
	Local aCoors 		:= FWGetDialogSize( oMainWnd )
	Local oRadio
	Local cTopFun		:= "'ZZZZZZZZZZZZZZZZZZZZ'"
	Local cBotFun		:= "'ZZZZZZZZZZZZZZZZZZZZ'"
	Local cCtr 			:= ''
	Local aProdCtr      := {}
	Local aCampos		:= {}
	Local aCN9			:= {}
	Local oGetDados
	Local oGetCOA
	Local oBrowse
	Local cChaveCtr
	Local cMsgAvl 		:= IIF(lVisAval,STR0064,STR0019)	//"O que deseja visualizar? ## "O que deseja avaliar?"
	Local lRet			:= .T.
	Local cGrpApr		:= GrpAprCrt(CN9->(CN9_NUMERO+CN9_REVISA))

	PRIVATE nRadio		:= 1
	Private INCLUI		:= .F.
	Private ALTERA		:= .F.
	Private EXCLUI		:= .F.
	Private oPanel1		// Tree
	Private oPanel2		// Enchoice dos dados do Contrato ou Item do contrato
	Private oPanel3		// Browse das avaliações já existentes (COA)
	Private oPanel4		// Enchoice com os dados da avaliação (COA)
	Private oTreeCtr
	Private cProdAtu	:= Space(TamSX3("COA_PRODUT")[01])

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Migra CN9_USUAVA para CNN				                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(CN9->CN9_USUAVA)
		CNMgCN9CNN(CN9->CN9_FILIAL,CN9->CN9_NUMERO,CN9->CN9_USUAVA,cGrpApr,DEF_TRAAVA)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida usuario 			                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lRet := CN240VldUsr(CN9->CN9_NUMERO,If(lVisAval,DEF_TRAAVV,DEF_TRAAVA),.T.)

	if lRet
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta o array de campos a ser utilizado                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SX3")
		dbSetOrder(1)
		dbSeek("CN9")
		While !Eof() .And. (X3_ARQUIVO == "CN9")
			If SX3->X3_CAMPO <> "CN9_CLIENT" .And. SX3->X3_CAMPO <> "CN9_LOJACL"
				AADD(aCn9,X3_CAMPO)
			Endif
			dbSkip()
		End

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Prevalidar a operacao do registro posicionado na browse ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lVisAval .AND. GetNewPar("MV_USAAEC", '2') == '2'
			Aviso("CNTA180",STR0069,{"Ok"}) //"Para realizar a avaliação de contratos é necessário habilitar o parâmetro MV_USAAEC."
			lRet := .F.
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Contrato com situacao diferente  ³
		//³ de VIGENTE / EM REVISAO		 	 ³
		//³ Visualizacao permitida		 	 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet .AND. !lVisAval .AND. !(Alltrim(CN9->CN9_SITUAC) $ "05/09")
			//Impede execucao de avaliacao
			Help(" ",1,"ONLYVIGE",,STR0022,1,1)	//"Apenas contratos vigentes poderão sofrer avaliação."
			lRet := .F.
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Contrato EM REVISAO 				  ³
		//³ Avaliacao e visualizao nao permitidas ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet .AND. Alltrim(CN9->CN9_SITUAC) == "09"
			If lVisAval
				Aviso("CN180AVAL",STR0065,{"Ok"})	//"Visualizacao nao disponivel para contratos em revisao"
				lRet := .F.
			Else
				Aviso("CN180AVAL",STR0066,{"Ok"})	//"Não é permitida a avaliação de contratos em revisao"
				lRet := .F.
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Contrato VIGENTE - Visualizao permitida	 					   	³
		//³ Avaliacao nao permitida se o contrato possuir revisao em aberto ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet .AND. !lVisAval .AND. Alltrim(CN9->CN9_SITUAC) == "05"

			cCtr := CN9->CN9_NUMERO

			//Impede avaliacao se o contrato tem revisao em aberto
			If !CN180UltRev(cCtr)
				lRet := .F.
			EndIf
		EndIf

		If lRet

			DEFINE FONT oFnt NAME "Tahoma" SIZE 11,14 BOLD

			nOpca     := 0
			cChaveCtr := xFilial('CN9')+CN9->(CN9_NUMERO+CN9_REVISA)+cProdAtu
			DEFINE MSDIALOG oDlg FROM  094,1 TO 230,293 TITLE STR0018 PIXEL	//"Avaliação de Execução de Contratos"
			@ 05,07 TO 42, 140 OF oDlg  PIXEL
			@ 10,10 SAY cMsgAvl FONT oFnt  OF oDlg  PIXEL
			@ 20,10 Radio oRadio VAR nRadio;
			ITEMS STR0020,;	//"Contrato"
			STR0021;		//"Item do Contrato"
			3D SIZE 50,10 OF oDlg PIXEL
			DEFINE SBUTTON FROM 50,085 TYPE 1 ENABLE OF oDlg ACTION (nOpca := 1, oDlg:End())
			DEFINE SBUTTON FROM 50,115 TYPE 2 ENABLE OF oDlg ACTION (nOpca := 0, oDlg:End())
			ACTIVATE MSDIALOG oDlg CENTERED

			If nOpca == 1

				If nRadio == 1
					cTopFun := "'"+xFilial('COA')+CN9->(CN9_NUMERO+CN9_REVISA)+cProdAtu+"'"
					cBotFun := "'"+xFilial('COA')+CN9->(CN9_NUMERO+CN9_REVISA)+cProdAtu+"'"
				Endif

				DEFINE DIALOG oDlg TITLE STR0018 FROM aCoors[1],aCoors[2] TO aCoors[3],aCoors[4] OF oMainWnd COLOR "W+/W" STYLE nOR(WS_VISIBLE,WS_POPUP) PIXEL		//"Avaliação de execução de Contratos"

				oDlg:lMaximized := .T.

				// Cria instancia do fwlayer
				oFWLayer := FWLayer():New()

				// Inicializa componente passa a Dialog criada,
				// o segundo parametro é para criação de um botao de fechar utilizado para Dlg sem cabeçalho
				oFWLayer:init( oDlg, .T. )

				// Adiciona coluna passando nome, porcentagem da largura, e se ela é redimensionada ou não
				// Cria windows passando, nome da coluna onde sera criada, nome da window
				// titulo da window, a porcentagem da altura da janela, se esta habilitada para click,
				// se é redimensionada em caso de minimizar outras janelas e a ação no click do split
				oFWLayer:addCollumn( "Col01", 30, .F. )
				oFWLayer:addWindow( "Col01", "Win01", STR0018, 95, .T., .F.)	//"Avaliação de execução de contratos"
				oPanel1	:= oFWLayer:getWinPanel( "Col01", "Win01" )

				// TREE
				oTreeCtr			:= XTree():New( 000, 000, 000, 000, oPanel1 )
				oTreeCtr:Align		:= CONTROL_ALIGN_ALLCLIENT
				oTreeCtr:bChange	:= {|x1,x2,x3| PosicCtr( aProdCtr, @oGetDados, @oBrowse, @oGetCOA ) }
				oTreeCtr:bValid		:= {|| !INCLUI .and. !ALTERA .and.!EXCLUI }
				oTreeCtr:bWhen		:= {|| !INCLUI .and. !ALTERA .and.!EXCLUI }
				If !lVisAval
					oTreeCtr:BrClicked	:= {|x,y,z| oMenuPop:Activate( y-40, z-185, oPanel1 ) }
				EndIf

				//Cria o primeiro nodo
				oTreeCtr:AddTree (STR0023 + CN9->CN9_NUMERO + IIf(Empty(CN9->CN9_REVISA),'',' Rev : ' + CN9->CN9_REVISA), "FOLDER5","FOLDER6", 'ID_PRINCIPAL',/*{|| MsgStop('xxx')}*/,/*bRClick*/, { || AddTreeCN9(oTreeCtr,CN9->(CN9_NUMERO+CN9_REVISA),aProdCtr)})	//"Contrato : "

				If nRadio == 2 //Item de Contrato
					ADDTREECN9(oTreeCtr,CN9->(CN9_NUMERO+CN9_REVISA),aProdCtr)
				Endif

				oTreeCtr:EndTree()

				If !lVisAval
					MENU oMenuPop POPUP
					MENUITEM STR0024 ACTION actButtons( 3, @oBrowse, @oGetCOA, aProdCtr )	RESOURCE 'BMPINCLUIR'	//"Incluir"
					MENUITEM STR0025 ACTION actButtons( 4, @oBrowse, @oGetCOA, aProdCtr )	RESOURCE 'NOTE'			//"Alterar"
					MENUITEM STR0026 ACTION actButtons( 5, @oBrowse, @oGetCOA, aProdCtr )	RESOURCE 'EXCLUIR'		//"Excluir"
					ENDMENU
				EndIf

				// BUTTONS
				oButtonBar := FWButtonBar():new()
				oButtonBar:Init( oPanel1, 015, 015, CONTROL_ALIGN_BOTTOM, .T. )

				If nRadio == 2 //Item de Contrato
					oButtonBar:addBtnImage( "PESQUISA.PNG",	STR0027,	{|| PesqTree( aProdCtr, @oGetDados, @oBrowse, @oGetCOA ) },, .T., CONTROL_ALIGN_LEFT) 	//"Pesquisa Rápida"
				Endif

				If !lVisAval
					oButtonBar:addBtnImage( "BMPINCLUIR.PNG",	STR0024, 	{|| actButtons( 3, @oBrowse, @oGetCOA, aProdCtr ) }, { || !INCLUI .AND. !ALTERA .AND. !EXCLUI }, .T., CONTROL_ALIGN_LEFT)	//"Incluir"
					oButtonBar:addBtnImage( "NOTE.PNG",			STR0025, 	{|| actButtons( 4, @oBrowse, @oGetCOA, aProdCtr ) }, { || !INCLUI .AND. !ALTERA .AND. !EXCLUI }, .T., CONTROL_ALIGN_LEFT)   //"Alterar"
					oButtonBar:addBtnImage( "EXCLUIR.PNG",		STR0026, 	{|| actButtons( 5, @oBrowse, @oGetCOA, aProdCtr ) }, { || !INCLUI .AND. !ALTERA .AND. !EXCLUI }, .T., CONTROL_ALIGN_LEFT)   //"Excluir"
				EndIf

				// Adiciona coluna passando nome, porcentagem da largura, e se ela é redimensionada ou não
				// Cria windows passando, nome da coluna onde sera criada, nome da window
				// titulo da window, a porcentagem da altura da janela, se esta habilitada para click,
				// se é redimensionada em caso de minimizar outras janelas e a ação no click do split
				oFWLayer:addCollumn( "Col02", 70, .F. )

				oFWLayer:addWindow( "Col02", "Win01", STR0020, 30, .T., .T. )	//"Contrato"
				oPanel2	:= oFWLayer:getWinPanel( "Col02", "Win01")

				oFWLayer:addWindow( "Col02", "Win02", STR0028, 30, .T., .T. )	//"Avaliações"
				oPanel3	:= oFWLayer:getWinPanel( "Col02", "Win02")

				oFWLayer:addWindow( "Col02", "Win03", STR0029, 35, .T., .T. )	//"Dados da Avaliação"
				oPanel4	:= oFWLayer:getWinPanel( "Col02", "Win03")

				// Painel 2
				///////////////////////////////////////
				//Enchoice - Dados do Contrato
				oPanel2:FreeChildren()
				RegToMemory( "CN9", .F.,,, FunName() )
				//RegToMemory( "CN9", .F.,,,)
				oGetDados				:= MsMGet():New( "CN9", CN9->( RecNo() ), 2,,,,aCN9, { 0, 0, oPanel2:nWidth*2, oPanel2:nHeight*2 },, 4,,,, oPanel2 )
				oGetDados:oBox:Align	:= CONTROL_ALIGN_ALLCLIENT

				///////////////////////////////////////
				//Browse - Avaliacoes do Contrato
				oPanel3:FreeChildren()

				//Barra de Botoes
				oButtonBar := FWButtonBar():new()
				oButtonBar:Init(oPanel3,015,015,CONTROL_ALIGN_BOTTOM,.T.,.T.)
				oButtonBar:setEnchBar(,,,,,.T.)
				oButtonBar:AddBtnImage("PMSCOLOR","Legenda",{||CN180Leg()},,.T.,CONTROL_ALIGN_LEFT)

				COA->(DbSetOrder(3))
				oBrowse := MaWndBrowse(0,0,0,0,,"COA",,,,cTopFun,cBotFun,.F.,,4,,,,.F.,,,,,,,,oPanel3,,,.F.,.F.,.F.)
				oBrowse:bChange := {|| CN180Visua("COA", COA->(Recno()), @oGetCOA)}

				///////////////////////////////////////
				//Enchoice - Dados da Avaliacao
				oPanel4:FreeChildren()
				If !COA->(Eof()) .AND. cChaveCtr == xFilial('COA')+COA->(COA_CONTRA+COA_REVISA+COA_PRODUT)
					RegToMemory( "COA", .F.,,, FunName() )
				Else
					COA->(DbGoBottom())
					COA->(DbSkip())
				Endif
				oGetCOA			   := MsMGet():New( "COA", COA->( RecNo() ), 2,,,,aAcho, { 0, 0, 10, 10 },, 4,,,, oPanel4 )
				oGetCOA:oBox:Align := CONTROL_ALIGN_ALLCLIENT

				// Posiciona a arvore no cabecalho para mostrar a tela de apresentacao
				oTreeCtr:TreeSeek( "ID_PRINCIPAL" )

				ACTIVATE DIALOG oDlg

			ElseIf nOpca == 0 //Cancelar

				If (__lSX8)
					RollBackSX8()
				EndIf

			EndIf

		EndIf
	EndIf
	lVisAval := .F.
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN180UltRev  ³ Autor ³ William Pires    ³    Data ³26.09.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Verifica se o contrato posicionado (vigente) possui 		   ³±±
±±³			 ³ registro de revisao em aberto e bloqueia a avaliacao		   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN180UltRev(cExp01,cExp02)				                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Contrato	                                       ³±±
±±³			 ³ cExp02 - Revisao Atual                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CN180AVAL                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// Substituido pelo assistente de conversao do AP6 IDE em 15/05/20 ==> Static Function CN180UltRev(cCtr)
Static Function CN180UltRev(cCtr)

	Local aArea 	:= GetArea()
	Local aAreaCN9	:= CN9->(GetArea())
	Local lRet 		:= .T.

	Default cCtr := ""

	DbSelectArea("CN9")
	CN9->(DbSetOrder(7)) //CN9_FILIAL+CN9_NUMERO+CN9_SITUAC

	If CN9->(MsSeek( xFilial("CN9") + cCtr + "09"))
		Aviso("CN180AVAL",STR0067,{"Ok"})  //"Esse contrato possui revisão em aberto. Não é permitida a avaliação de contratos nessa situação."
		lRet := .F.
	EndIf

	RestArea(aAreaCN9)
	RestArea(aArea)

Return lRet


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ADDTREECN9³ Autor ³ Totvs                 ³ Data ³ 23/11/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para inclusao de nodos no XTree                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ADDTREECN9(ExpO1,ExpC1)                              	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto xTree                                       ³±±
±±³          ³ ExpC2 = Codigo da natureza Pai							  ³±±
±±³          ³ ExpA3 = Array com os produtos do contrato     			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ 		                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
// Substituido pelo assistente de conversao do AP6 IDE em 15/05/20 ==> Function ADDTREECN9( oTree, cPai, aProdCtr )
Static Function ADDTREECN9( oTree, cPai, aProdCtr )
	Local lRet 		:= .F.
	Local cCodigo
	Local aArea 	:= GetArea()
	Local cTamPai	:= TAMSX3("CNB_CONTRA")[1] + TAMSX3("CNB_REVISA")[1]
	Local nPos

	If	aScan( oTree:aNodes, { |x| x[1] == oTree:CurrentNodeID } ) == 0
		cPai := PadR(cPai, cTamPai)

		DbSelectArea("CNB")
		DbSetOrder(1)
		If DbSeek( xFilial() + cPai )
			While !CNB->( Eof() ) .And. CNB->( CNB_FILIAL + CNB_CONTRA + CNB_REVISA ) == xFilial() + cPai

				cItem	:= AllTrim(CNB->CNB_ITEM)
				cCodigo := AllTrim(CNB->CNB_PRODUT)

				oTree:AddTree( cCodigo + ' - ' + AllTrim(CNB->CNB_DESCRI) + ' - ' + cItem, "FOLDER5", "FOLDER6" , AllTrim(CNB->(CNB_NUMERO+CNB_ITEM+CNB_PRODUT)),,,)
				oTree:EndTree()

				lRet := .T.
				nPos := Ascan(aProdCtr,{|x| x[02]+x[03]+x[04] == CNB->(CNB_NUMERO+CNB_ITEM+CNB_PRODUT)}) //Plan + Item + Cod.Prod

				If nPos == 0
					AADD(aProdCtr, {CNB->(Recno())	,;	//Recno
					CNB->CNB_NUMERO	,;	//Planilha
					CNB->CNB_ITEM	,;	//Item
					CNB->CNB_PRODUT} )	//Produto
				Endif
				DbSkip()
			EndDo
		EndIf
	Endif

	RestArea(aArea)

Return lRet


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ PesqTree ³ Autor ³ Totvs                 ³ Data ³ 23/11/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Faz a pesquisa de um codigo na àrvore e chama a funcão para³±±
±±³       	 ³ posicionar na árvore.                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ PesqTree()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array com os produtos do contrato        		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
// Substituido pelo assistente de conversao do AP6 IDE em 15/05/20 ==> Static Function PesqTree( aProdCtr, oGetDados, oBrowse, oGetCOA )
Static Function PesqTree( aProdCtr, oGetDados, oBrowse, oGetCOA )

	Local cGctProd := Space(TamSX3("CNB_NUMERO")[01]+TamSX3("CNB_ITEM")[01]+TamSX3("CNB_PRODUT")[01])
	Local nOpca := 0
	Local oDlgPesq

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza Help ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE MSDIALOG oDlgPesq FROM  094,1 TO 200,315 TITLE STR0030 PIXEL	//"Pesquisa"
	@ 05,05 SAY STR0031 OF oDlgPesq PIXEL							//"Informe o produto:"
	@ 15,05 MSGET cGctProd SIZE 155,05 F3 "CNBAVL" VALID VldProdPesq(cGctProd,aProdCtr) Of oDlgPesq HASBUTTON PIXEL  //cProd
	DEFINE SBUTTON FROM 35,052 TYPE 1 ENABLE OF oDlgPesq ACTION (nOpca := 1, oDlgPesq:End())
	DEFINE SBUTTON FROM 35,082 TYPE 2 ENABLE OF oDlgPesq ACTION (nOpca := 0, oDlgPesq:End())

	ACTIVATE MSDIALOG oDlgPesq CENTERED

	If nOpca == 1
		oTreeCtr:TreeSeek( AllTrim(cGctProd) )
		oTreeCtr:Refresh()
		PosicCtr( aProdCtr, @oGetDados, @oBrowse, @oGetCOA )
	Endif

Return


///////////////////////////////////////////////////
// Validacao do produto a ser pesquisado:
///////////////////////////////////////////////////
// Substituido pelo assistente de conversao do AP6 IDE em 15/05/20 ==> Static Function VldProdPesq(cProd,aProdCtr)
Static Function VldProdPesq(cProd,aProdCtr)

	Local nPos

	SB1->(DbSetOrder(1))
	nPos := Ascan(aProdCtr,{|cChave| AllTrim(cChave[2]+cChave[3]+cChave[4]) == AllTrim(cProd)})


	If Empty(cProd) .OR. nPos == 0 //.OR. !SB1->(DbSeek(xFilial("SB1")+aProdCtr[nPos,4]))
		MsgStop(STR0032,STR0033)	//STR0032: "Produto inválido!" - STR0033: "Atenção"
		Return .f.
	Endif

Return .t.


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³actButtons³ Autor ³ Totvs                 ³ Data ³ 23/11/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Acao dos botoes para a enchoice                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ actButtons( nOpc, oBrowse, oGetCOA )                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao da acao, inclusao, alteracao ou exclusao     ³±±
±±³          ³ ExpO1 = Objeto Painel, onde se encontra o MsmGet           ³±±
±±³          ³ ExpO2 = Objeto MsmGet (enchoice)      					  ³±±
±±³          ³ ExpO3 = Ahrvore onde vai ocorrer a busca		  	  		  ³±±
±±³          ³ ExpO4 = Objeto Painel, onde se encontra o xTree            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                     		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
// Substituido pelo assistente de conversao do AP6 IDE em 15/05/20 ==> Static Function actButtons( nOpc, oBrowse, oGetCOA, aProdCtr )
Static Function actButtons( nOpc, oBrowse, oGetCOA, aProdCtr )

	Local aDim		:= {}
	Local cTudoOK	:= 'CN180TOk()' //Valida o processo (Inclusao ou Alteracao)
	Local cTransact := 'CN180Grv()' //Complementa a gravacao dos dados da avaliacao(COA)
	Local nRecNo	:= COA->( RecNo() )
	Local nID		:= 0
	Local aRotOrig
	Local cChaveCtr
	Local cSeek
	Local cTopFun
	Local cBotFun

	//Se avaliacao por Item Contrato, não permite acao quando posicionado sobre o contrato:
	If oTreeCtr:CurrentNodeID == "0000001" .AND. nRadio == 2
		If nRadio == 2
			Help(" ",1,"INVOPC",,STR0034,1,1)	//"Opção inválida para o item posicionado!"
			Return
		EndIf
	EndIf

	If nRadio == 1
		//Compoe a chave do registro selecionado na Tree (Contrato)
		cChaveCtr := CN9->(CN9_NUMERO+CN9_REVISA)+cProdAtu
		cSeek 	  := "COA->(COA_CONTRA+COA_REVISA+COA_PRODUT)"
	Else
		//Grava o ID do produto selecionado na Tree
		nID := Val(oTreeCtr:CurrentNodeID)-1

		//Compoe a chave do registro selecionado na Tree (Item de Contrato)
		cChaveCtr := CN9->(CN9_NUMERO+CN9_REVISA)+aProdCtr[nID,2]+aProdCtr[nID,3]+aProdCtr[nID,4]
		cSeek 	  := "COA->(COA_CONTRA+COA_REVISA+COA_PLANIL+COA_ITEM+COA_PRODUT)"
	EndIf

	//Nao permite alteracao/exclusao quando nao existem registros filtrados para contrato:
	If nOpc <> 3 .AND. (COA->(Eof()) .OR. (!COA->(Eof()) .AND. cChaveCtr <> &(cSeek)))
		Help(" ",1,"INVOPC",,STR0034,1,1)	//"Opção inválida para o item posicionado!"
		Return
	EndIf

	dbSelectArea("COA")
	oPanel4:FreeChildren()
	oPanel4:ReadClientCoors(.T.,.T.)
	aDim := DLGinPANEL(oPanel4)

	//Inclusao
	If nOpc == 3
		INCLUI := .T.
		ALTERA := .F.
		RegToMemory("COA",.T.,,,FunName())
		AxInclui("COA",nRecno,nOpc,aAcho,,,cTudoOk,,cTransact,,/*aParam*/,/*aAuto*/,/*lVirtual*/,/*lMaximized*/,/*cTela*/,.F.,oPanel4, aDim,, .T. )
		//Alteracao
	ElseIf nOpc == 4
		INCLUI := .F.
		ALTERA := .T.
		RegToMemory("COA",.F.,,,FunName())
		aRotOrig := aRotina
		aRotina  := Nil
		AxAltera( "COA",nRecNo,nOpc,aAcho,,4,/*cMensagem*/,cTudoOk,cTransact,,/*aButtons*/,/*aParam*/,/*aAuto*/,/*lVirtual*/,/*lMaximized*/,/*cTela*/, .f. ,oPanel4,aDim,, .T. )
		aRotina := aRotOrig
		//Exclusao
	Else
		INCLUI := .F.
		ALTERA := .F.
		If ExcAvalCtr(aProdCtr,nID)
			//Apos exclusao, refaz o Panel3 e Panel4:
			//Browse - Avaliacoes do Contrato
			oPanel3:FreeChildren()

			//Barra de Botoes
			oButtonBar := FWButtonBar():new()
			oButtonBar:Init(oPanel3,015,015,CONTROL_ALIGN_BOTTOM,.T.,.T.)
			oButtonBar:setEnchBar(,,,,,.T.)
			oButtonBar:AddBtnImage("PMSCOLOR","Legenda",{||CN180Leg()},,.T.,CONTROL_ALIGN_LEFT)

			If nRadio == 2
				cProdAtu := aProdCtr[nID,2]+aProdCtr[nID,3]+aProdCtr[nID,4]
			Else
				COA->(DbSetOrder(3))
			Endif

			cTopFun := "'"+xFilial('COA')+CN9->(CN9_NUMERO+CN9_REVISA)+cProdAtu+"'"
			cBotFun := "'"+xFilial('COA')+CN9->(CN9_NUMERO+CN9_REVISA)+cProdAtu+"'"
			oBrowse := MaWndBrowse(0,0,0,0,,"COA",,,,cTopFun,cBotFun,.F.,,4,,,,.F.,,,,,,,,oPanel3,,,.F.,.F.,.F.)
			oBrowse:bChange := {|| CN180Visua("COA", COA->(Recno()), @oGetCOA)}
		Endif
	EndIf

	INCLUI := .F.
	ALTERA := .F.
	EXCLUI := .F.

	///////////////////////////////////////
	//Recria Enchoice - Dados da Avaliacao (Visualizacao)
	oPanel4:FreeChildren()
	If !COA->(Eof()) .AND. IIF(nRadio == 1, cChaveCtr == COA->(COA_CONTRA+COA_REVISA+COA_PRODUT), cChaveCtr == &(cSeek))
		RegToMemory( "COA", .F.,,, FunName() )
		oGetCOA			  	:= MsMGet():New( "COA", COA->( RecNo() ), 2,,,, aAcho, { 0, 0, 10, 10 },, 4,,,, oPanel4 )
		oGetCOA:oBox:Align	:= CONTROL_ALIGN_ALLCLIENT
	Endif

Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ExcAvalCtr³ Autor ³ Totvs                 ³ Data ³ 30/07/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para exlusao das avaliacoes dos contratos           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FAExcNat()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ 		                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
// Substituido pelo assistente de conversao do AP6 IDE em 15/05/20 ==> Static Function ExcAvalCtr(aProdCtr,nID)
Static Function ExcAvalCtr(aProdCtr,nID)

	Local nConfDel 	 //utilizada para o usuário confirmar ou não a deleção 1.Confirma 2.Cancela
	Local lDelOK 	 := .T.
	Local lAltProxAv := .F.
	Local cChaveCtr  := CN9->(CN9_NUMERO+CN9_REVISA)
	Local dUltAva 	 := CTOD("//")
	Local cChaveCOA  := ''
	Local cItemCNB	 := ''

	Default aProdCtr := {}
	Default nID		 := 0

	//STR0033: "Atenção"
	//STR0035: "Confirma Exclusão?"
	//STR0036: "Sim"
	//STR0037: "Nao"

	nConfDel := Aviso( STR0033, STR0035, { STR0036, STR0037 })
	If nConfDel == 1
		If AvalRecente(COA->COA_DTAVAL,aProdCtr,nID)
			MsgStop(STR0038,STR0033)	//STR0038: "Operação de exclusão inválida! Existe avaliação mais recente!"
			lDelOK := .F.
		Else
			If nRadio == 1
				If !Empty(CN9->CN9_ULTAVA) .AND. DDATABASE < CN9->CN9_ULTAVA
					MsgStop(STR0068,STR0033)//STR0068: "Operacao de exclusao invalida! A data atual é menor que a data da última avaliação."
					lDelOK := .F.
				EndIf
			Else
				If !Empty(CNB->CNB_ULTAVA) .AND. DDATABASE < CNB->CNB_ULTAVA
					MsgStop(STR0068,STR0033)//STR0068: "Operacao de exclusao invalida! A data atual é menor que a data da última avaliação."
					lDelOK := .F.
				EndIf
			EndIf

			If lDelOK

				BEGIN TRANSACTION

					RecLock("COA",.F.)
					If !FKDelete()
						Help(" ",1,"A010NAODEL")
						lDelOK := .f.
					Endif
					COA->(MsUnLock())

					COA->(DbGoTop())
					//Limpa informacao da proxima avaliacao:
					If nRadio == 1
						COA->(DbSetOrder(3)) //COA_FILIAL+COA_CONTRA+COA_REVISA+COA_PRODUT

						If COA->(DbSeek( xFilial("COA") + cChaveCtr ))
							While !COA->(Eof()) .AND. AllTrim(COA->(COA_FILIAL + COA_CONTRA + COA_REVISA)) == AllTrim(xFilial("COA") + cChaveCtr)

								If Empty(COA->COA_PRODUT)	//Verifica se registro posicionado e realmente uma avaliacao de contrato
									dUltAva    := COA->COA_DTAVAL
									lAltProxAv := .T.
								EndIf

								COA->(DbSkip())
							EndDo
						EndIf

						RecLock("CN9",.F.)
						CN9->CN9_ULTAVA := dUltAva
						If lAltProxAv
							CN9->CN9_PROXAV := DataValida(dUltAva + RetDias(CN9->CN9_PROGRA),.T.)
						Else
							CN9->CN9_PROXAV := CTOD("//")
						EndIf
						CN9->(MsUnLock())
						//avaliacao para todos os itens da planilha
						cn180GerItm("E",lAltProxAv,dUltAva)

						//Tratamento para produto
					Else
						COA->(DbSetOrder(6)) //COA_FILIAL+COA_CONTRA+COA_REVISA+COA_PLANIL+COA_ITEM+COA_PRODUT

						cChaveCOA := "COA->(COA_FILIAL+COA_CONTRA+COA_REVISA+COA_PLANIL+COA_ITEM+COA_PRODUT)"
						cItemCNB  := cChaveCtr+aProdCtr[nID,2]+aProdCtr[nID,3]+aProdCtr[nID,4]

						If COA->(DbSeek(xFilial("COA")+cItemCNB))

							While !COA->(Eof()) .AND. AllTrim(&cChaveCOA) == AllTrim(xFilial("COA")+cItemCNB)

								If !Empty(COA->COA_PRODUT) //Verifica se registro posicionado e realmente uma avaliacao de Item de contrato
									dUltAva    := COA->COA_DTAVAL
									lAltProxAv := .T.
								EndIf

								COA->(DbSkip())

							EndDo
						EndIf

						RecLock("CNB",.F.)
						CNB->CNB_ULTAVA := dUltAva
						If lAltProxAv
							CNB->CNB_PROXAV := DataValida(dUltAva + RetDias(CN9->CN9_PROGRA),.T.)
						Else
							CNB->CNB_PROXAV := CTOD("//")
						EndIf
						CNB->(MsUnLock())
					EndIf

				END TRANSACTION

			EndIf
		Endif
	Endif

Return lDelOK

////////////////////////////////////////////
// Checa se existem avaliacoes recentes:
////////////////////////////////////////////
// Substituido pelo assistente de conversao do AP6 IDE em 15/05/20 ==> Static Function AvalRecente(dAval,aProdCtr,nID)
Static Function AvalRecente(dAval,aProdCtr,nID)

	Local cAlias := "COA"
	Local cQuery := ""
	Local lAvalRecente := .f.

	Default aProdCtr := {}
	Default nID		 := 0


	cAlias  := "COATMP"
	cQuery	:= "  SELECT * FROM " + RetSqlName('COA') + " COA"
	cQuery	+= "  WHERE COA.COA_FILIAL  = '" + xFilial('COA') + "'"
	cQuery	+= "    AND COA.COA_CONTRA = '" + CN9->CN9_NUMERO + "'"
	cQuery	+= "    AND COA.COA_REVISA = '" + CN9->CN9_REVISA + "'"
	If nRadio == 1
		cQuery	+= "    AND COA.COA_PRODUT = ' '"
	Else
		If !Empty(aProdCtr) .AND. nID > 0
			cQuery	+= "  AND COA.COA_PLANIL = '" + aProdCtr[nID,2] + "'"
			cQuery	+= "  AND COA.COA_ITEM   = '" + aProdCtr[nID,3] + "'"
			cQuery	+= "  AND COA.COA_PRODUT = '" + aProdCtr[nID,4] + "'"
		Else
			cQuery	+= "  AND COA.COA_PRODUT = '" + cProdAtu + "'"
		EndIf
	EndIf
	cQuery	+= "    AND COA.COA_DTAVAL > '" + DTOS(dAval) + "'"
	cQuery	+= "    AND COA.D_E_L_E_T_ = ' '"
	cQuery	+= "  ORDER BY COA.COA_DTAVAL DESC"
	cQuery := ChangeQuery(cQuery)
	dbUseArea ( .T., "TOPCONN", TCGENQRY(,,cQuery), cAlias, .F., .T.)


	While (cAlias)->(!Eof() .and. COA_FILIAL+COA_CONTRA+COA_REVISA == xFilial("COA")+CN9->(CN9_NUMERO+CN9_REVISA))
		If (cAlias)->COA_DTAVAL > DTOS(dAval)
			If (nRadio == 1 .AND. !Empty((cAlias)->COA_PRODUT)) .OR. (nRadio == 2 .AND. (cAlias)->COA_PRODUT <> cProdAtu)
				(cAlias)->(DbSkip())
				Loop
			Endif
			lAvalRecente := .t.
			Exit
		Endif
		(cAlias)->(DbSkip())
	EndDo


	dbSelectArea(cAlias)
	(cAlias)->(dbCloseArea())


Return lAvalRecente


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CN180Visua   ³ Autor ³ TOTVS                 ³ Data ³ 22/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza a visulizacao da avaliacao posicionada                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
// Substituido pelo assistente de conversao do AP6 IDE em 15/05/20 ==> Function CN180Visua(cAliasFile, nRecno, oGetCOA )
Static Function CN180Visua(cAliasFile, nRecno, oGetCOA )

	&(cAliasFile)->(DbGoto(nRecno))
	If !COA->(Eof()) .AND. COA_CONTRA+COA_REVISA == CN9->(CN9_NUMERO+CN9_REVISA)
		RegToMemory( "COA", .F.,,, FunName() )
	Else
		COA->(DbGoBottom())
		COA->(DbSkip())
	Endif
	RegToMemory(cAliasFile, .F., .T., , , FunName())
	oGetCOA:Refresh()

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CN180TOk     ³ Autor ³ TOTVS                 ³ Data ³ 22/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida a inclusao/alteracao da avaliacao do contrato           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
// Substituido pelo assistente de conversao do AP6 IDE em 15/05/20 ==> Function CN180TOk()
Static Function CN180TOk()

	Local bValid1 := { |x| If(x == 1,CN9->CN9_ULTAVA > dDatabase,CNB->CNB_ULTAVA > dDatabase) }
	Local bValid2 := { |x| If(x == 1,CN9->CN9_PROXAV > dDatabase,CNB->CNB_PROXAV > dDatabase) }
	Local lRet    := .T.

	//Nao permite inclusao de avaliacoes com datas anteriores a ultima avaliacao:
	If Eval(bValid1,nRadio)
		Help(" ",1,"DTAVAMAI",,STR0039,1,1)		//"Data da ultima avaliação é maior que database do sistema"
		lRet := .F.
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³por Icaro Queiroz em 05 de Novembro de 2010.                                                      ³
	//³Se o parametro MV_DBLAVAL for verdadeiro sera permitido avaliacoes antes da proxima data prevista;³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !GetNewPar( 'MV_DBLAVAL', .F. )
		//Nao permite avaliacoes antes da proxima data prevista:
		If lRet .AND. INCLUI .AND. !ALTERA .AND. Eval(bValid2,nRadio)
			Help(" ",1,"DTPRXAVA",,STR0040+If(nRadio==1,DTOC(CN9->CN9_PROXAV),DTOC(CNB->CNB_PROXAV))+"."+CHR(13)+;	//"Proxima avaliacao prevista para "
			STR0041,1,1)	//"Não são permitidas avaliações em data anterior à data prevista."
			lRet := .F.
		Endif
	EndIf

Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CN180Grv     ³ Autor ³ TOTVS                 ³ Data ³ 22/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Complementa a gravacao dos dados da avaliacao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
// Substituido pelo assistente de conversao do AP6 IDE em 15/05/20 ==> Function CN180Grv()
Static Function CN180Grv()

	Local aAreaCNA := CNA->(GetArea())
	Local cCodAvl  := ''

	If INCLUI
		cCodAvl := GetSXENum('COA', 'COA_AVALIA')
	EndIf
	//Gravacao da Avaliacao do Contrato:
	RecLock("COA",.F.)
	If INCLUI
		COA->COA_AVALIA := cCodAvl
	EndIf
	COA->COA_CONTRA := CN9->CN9_NUMERO
	COA->COA_REVISA := CN9->CN9_REVISA
	COA->COA_CONDPG := CN9->CN9_CONDPG
	COA->COA_DTINI  := CN9->CN9_DTINIC
	COA->COA_DTFIM  := CN9->CN9_DTFIM
	COA->COA_VIGENC := CN9->CN9_VIGE
	COA->COA_UNDVIG := CN9->CN9_UNVIGE
	COA->COA_USUARI := RetCodUsr()
	//Grava campo MEMO de Observacao:
	MSMM(COA->COA_CODOBS,,,M->COA_OBSERV,1,,,"COA","COA_CODOBS")

	If nRadio == 2 //Item do Contrato
		COA->COA_ITEM	:= CNB->CNB_ITEM
		COA->COA_PRODUT := CNB->CNB_PRODUT

		If CNA->(DbSeek( xFilial('CNA')+CNB->(CNB_CONTRA+CNB_REVISA+CNB_NUMERO) ))
			COA->COA_PLANIL := CNA->CNA_NUMERO
			COA->COA_TPPLAN := CNA->CNA_TIPPLA
		EndIf
	EndIf
	COA->(MsUnLock())

	If INCLUI
		ConfirmSX8()

		//Gravacao das informacoes da avaliacao no Contrato/Item:
		If nRadio == 1
			RecLock("CN9",.F.)
			CN9->CN9_ULTAVA := dDatabase
			CN9->CN9_PROXAV := DataValida(dDatabase + RetDias(CN9->CN9_PROGRA),.T.)
			CN9->(MsUnLock())
			//avaliacao para todos os itens da planilha
			cn180GerItm("I")
		Else
			RecLock("CNB",.F.)
			CNB->CNB_ULTAVA := dDatabase
			CNB->CNB_PROXAV := DataValida(dDatabase + RetDias(CN9->CN9_PROGRA),.T.)
			CNB->(MsUnLock())
		Endif
	EndIf

	RestArea(aAreaCNA)

Return .t.


////////////////////////////////////////////////////////////////
// Retorno dos dias a serem considerados para proxima avaliacao:
////////////////////////////////////////////////////////////////
// Substituido pelo assistente de conversao do AP6 IDE em 15/05/20 ==> Static Function RetDias(cProgramacao)
Static Function RetDias(cProgramacao)
	Local nDias := 0
	If cProgramacao == "1"	//QUINZENAL
		nDias := 15
	Elseif cProgramacao == "2"	//MENSAL
		nDias := 30
	Elseif cProgramacao == "3"	//BIMESTRAL
		nDias := 60
	Elseif cProgramacao == "4"	//TRIMESTRAL
		nDias := 90
	Elseif cProgramacao == "5"	//SEMESTRAL
		nDias := 180
	Elseif cProgramacao == "6"	//ANUAL
		nDias := 360
	Endif
Return nDias

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PosicCtr     ³ Autor ³ TOTVS                 ³ Data ³ 22/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Posiciona informacoes do item ativo                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
// Substituido pelo assistente de conversao do AP6 IDE em 15/05/20 ==> Static Function PosicCtr( aProdCtr, oGetDados, oBrowse, oGetCOA )
Static Function PosicCtr( aProdCtr, oGetDados, oBrowse, oGetCOA )

	Local cTopFun  := ''
	Local cBotFun  := ''
	Local cAlias   := ''
	Local cPlanAtu := ''
	Local cItemAtu := ''
	Local cProdAtu := ''

	If oTreeCtr:CurrentNodeID == "0000001"  //Posicionado sobre contrato
		cAlias   := "CN9"
		cProdAtu := Space(TamSX3("COA_PRODUT")[01])
	Else  //Posicionado sobre o produto do contrato
		cAlias    := "CNB"
		CNB->(DbGoto(aProdCtr[Val(oTreeCtr:CurrentNodeID)-1,1]))	//Recno CNB
		cPlanAtu  := aProdCtr[Val(oTreeCtr:CurrentNodeID)-1,2]		//Planilha
		cItemAtu  := aProdCtr[Val(oTreeCtr:CurrentNodeID)-1,3]		//Item
		cProdAtu  := aProdCtr[Val(oTreeCtr:CurrentNodeID)-1,4]		//Produto
	Endif

	cTopFun := If(oTreeCtr:CurrentNodeID == "0000001" .AND. nRadio == 2,"'ZZZZZZZZZZZZZZZZZZZZ'","'"+xFilial('COA')+CN9->(CN9_NUMERO+CN9_REVISA)+cPlanAtu+cItemAtu+cProdAtu+"'")
	cBotFun := If(oTreeCtr:CurrentNodeID == "0000001" .AND. nRadio == 2,"'ZZZZZZZZZZZZZZZZZZZZ'","'"+xFilial('COA')+CN9->(CN9_NUMERO+CN9_REVISA)+cPlanAtu+cItemAtu+cProdAtu+"'")

	///////////////////////////////////////
	//Enchoice - Item do Contrato
	oPanel2:FreeChildren()
	RegToMemory( cAlias, .F.,,, FunName() )
	oGetDados := MsMGet():New( cAlias, &(cAlias)->( RecNo() ), 2,,,,, { 0, 0, 100, oPanel2:nHeight*2 } ,, 4,,,, oPanel2 )
	oGetDados:oBox:Align := CONTROL_ALIGN_ALLCLIENT

	///////////////////////////////////////
	//Browse - Avaliacoes do Contrato
	COA->(DbGoTop())
	COA->(DbSetOrder(6))

	oPanel3:FreeChildren()

	//Barra de Botoes
	oButtonBar := FWButtonBar():new()
	oButtonBar:Init(oPanel3,015,015,CONTROL_ALIGN_BOTTOM,.T.,.T.)
	oButtonBar:setEnchBar(,,,,,.T.)
	oButtonBar:AddBtnImage("PMSCOLOR","Legenda",{||CN180Leg()},,.T.,CONTROL_ALIGN_LEFT)

	oBrowse := MaWndBrowse(0,0,0,0,,"COA",,,,cTopFun,cBotFun,.F.,,4,,,,.F.,,,,,,,,oPanel3,,,.F.,.F.,.F.)
	oBrowse:bChange := {|| CN180Visua("COA", COA->(Recno()), @oGetCOA)}

	///////////////////////////////////////
	//Enchoice - Dados da Avaliacao
	oPanel4:FreeChildren()
	If !COA->(Eof()) .AND. If(nRadio == 1,.t.,If(COA->(COA_PLANIL+COA_ITEM+COA_PRODUT) == cPlanAtu+cItemAtu+cProdAtu,.t.,.f.))
		RegToMemory( "COA", .F.,,, FunName() )
		oGetCOA			   := MsMGet():New( "COA", COA->( RecNo() ), 2,,,, aAcho, { 0, 0, 10, 10 },, 4,,,, oPanel4 )
		oGetCOA:oBox:Align := CONTROL_ALIGN_ALLCLIENT
	Endif

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CNT180DTAV   ³ Autor ³ TOTVS                 ³ Data ³ 22/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida a implementacao da avaliacao de execucao de contratos   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CNT180DTAV(dUltDtAval)						                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPD1 = Data da ultima avaliacao                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTA180                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
// Substituido pelo assistente de conversao do AP6 IDE em 15/05/20 ==> Function CNT180DTAV(nOpc)
Static Function CNT180DTAV(nOpc)
	LOCAL dProxAv
	LOCAL dUltDtAval := If(!Empty(M->CN9_ULTAVA),M->CN9_ULTAVA,M->CN9_DTINIC)
	LOCAL lRetorna   := .T.

	DEFAULT nOpc := 0

	If nOpc == 1
		If !Empty(M->CN9_PROXAV)
			dProxAv := M->CN9_PROXAV
			If dUltDtAval >= dProxAv
				Help(" ", 1, "DTAVAULT",,STR0062,1,1)	//"Data da próxima avaliação deve ser maior que a data da última avaliação"
				lRetorna := .F.
			EndIf
		EndIf
	ElseIf nOpc == 2
		If dUltDtAval > dDatabase
			Help(" ",1,"DTAVAMAI",,STR0039,1,1)	//"Data da ultima avaliação é maior que a database do sistema"
			lRetorna := .F.
		Else
			M->CN9_PROXAV := DataValida(dUltDtAval + RetDias(M->CN9_PROGRA),.T.)
		EndIf
	EndIf

Return lRetorna

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ CN180Hist  ³ Autor ³ William Pires        ³ Data ³01.09.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Gera historico das avaliacoes de contratos				   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ 										                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTA150 (Aprovacao de Revisoes)                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// Substituido pelo assistente de conversao do AP6 IDE em 15/05/20 ==> Function CN180Hist(cContrato, cRevis)
Static Function CN180Hist(cContrato, cRevis)

	Local aArea		:= GetArea()
	Local aAvlCtr  	:= {}
	Local cRevAnt  	:= ''
	Local cAvalia	:= ''
	Local nX		:= 0
	Local lRet 	   	:= .T.

	Default cContrato := ''
	Default cRevis	  := ''

	If lRet .And. !Empty(cContrato) .And. !Empty(cRevis)

		//Verifica qual a revisao do contrato passado por parametro para setar a revisao anterior na busca de registros na COA
		If cRevis > "001"
			cRevAnt := STRZERO(VAL(cRevis)-1, 3)
		Else
			cRevAnt := Space(TamSX3("COA_REVISA")[1])
		EndIf

		//Busca registros para compor historico
		DbSelectArea("COA")
		COA->(DbSetOrder(3)) //COA_FILIAL+COA_CONTRA+COA_REVISA+COA_PRODUT

		If COA->(DbSeek( xFilial("COA") + cContrato + cRevAnt ))

			While !COA->(Eof()) .AND. COA->(COA_FILIAL + COA_CONTRA + COA_REVISA) == xFilial("COA") + cContrato + cRevAnt

				AADD(aAvlCtr,{COA->COA_FILIAL,;//01
				COA->COA_CONTRA,;//02
				COA->COA_CONDPG,;//03
				COA->COA_DTINI,; //04
				COA->COA_DTFIM,; //05
				COA->COA_VIGENC,;//06
				COA->COA_UNDVIG,;//07
				COA->COA_PLANIL,;//08
				COA->COA_TPPLAN,;//09
				COA->COA_ITEM,;  //10
				COA->COA_PRODUT,;//11
				COA->COA_DESPRO,;//12
				COA->COA_USUARI,;//13
				COA->COA_CONCEI,;//14
				COA->COA_OCORRE,;//15
				COA->COA_DTAVAL,;//16
				COA->COA_CODOBS,;//17
				COA->COA_OBSERV})//18
				COA->(DbSkip())

			EndDo

		EndIf

		//Para cada avaliacao ja existente na revisao anterior um novo registro sera copiado e sera gravado com a revisao atual
		For nX := 1 To Len(aAvlCtr)
			cAvalia := GETSXENUM('COA','COA_AVALIA')

			RecLock("COA",.T.)
			COA->COA_FILIAL	:= aAvlCtr[nX][1]
			COA->COA_AVALIA	:= cAvalia
			COA->COA_CONTRA	:= aAvlCtr[nX][2]
			COA->COA_REVISA	:= cRevis
			COA->COA_CONDPG	:= aAvlCtr[nX][3]
			COA->COA_DTINI	:= aAvlCtr[nX][4]
			COA->COA_DTFIM	:= aAvlCtr[nX][5]
			COA->COA_VIGENC	:= aAvlCtr[nX][6]
			COA->COA_UNDVIG	:= aAvlCtr[nX][7]
			COA->COA_PLANIL	:= aAvlCtr[nX][8]
			COA->COA_TPPLAN	:= aAvlCtr[nX][9]
			COA->COA_ITEM	:= aAvlCtr[nX][10]
			COA->COA_PRODUT	:= aAvlCtr[nX][11]
			COA->COA_DESPRO	:= aAvlCtr[nX][12]
			COA->COA_USUARI	:= aAvlCtr[nX][13]
			COA->COA_CONCEI	:= aAvlCtr[nX][14]
			COA->COA_OCORRE	:= aAvlCtr[nX][15]
			COA->COA_DTAVAL	:= aAvlCtr[nX][16]
			COA->COA_CODOBS	:= aAvlCtr[nX][17]
			COA->COA_OBSERV	:= aAvlCtr[nX][18]
			MsUnlock()
			ConfirmSX8()

		Next nX

	EndIf

	RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ cn180GerItm  ³ Autor ³ Aline S Damasceno     ³ Data ³ 29/05/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Gera avaliacao para todos os itens da planilha				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ cn180GerItm(cOpcao,lAltProxAv,dUltAva)   	                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 -  "I" inclusao ou "E" exclusao                          ³±±
±±³          ³ ExpL1 -  controle da proxima avaliacao                         ³±±
±±³          ³ ExpD1 -  data da ultima avaliacao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTA180                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
// Substituido pelo assistente de conversao do AP6 IDE em 15/05/20 ==> Function cn180GerItm(cOpcao,lAltProxAv,dUltAva)
Static Function cn180GerItm(cOpcao,lAltProxAv,dUltAva)
	Local aAreaCNB := CNB->(GetArea())
	Local cSeekCNB := xFilial("CNB")  + CN9->CN9_NUMERO + CN9->CN9_REVISA

	Default lAltProxAv := .F.
	Default dUltAva 	:= CTOD("//")

	If GetNewPar("MV_USAITM", '2') == '1'
		DbSelectArea("CNB")
		DbSetOrder(1)
		If DbSeek( cSeekCNB )
			While !CNB->( Eof() ) .And. CNB->( CNB_FILIAL + CNB_CONTRA + CNB_REVISA ) == cSeekCNB
				RecLock("CNB",.F.)
				If cOpcao == "I"
					CNB->CNB_ULTAVA := dDatabase
					CNB->CNB_PROXAV := DataValida(dDatabase + RetDias(CN9->CN9_PROGRA),.T.)
				Else
					CNB->CNB_ULTAVA := dUltAva

					If lAltProxAv
						CNB->CNB_PROXAV := DataValida(dUltAva + RetDias(CN9->CN9_PROGRA),.T.)
					Else
						CNB->CNB_PROXAV := CTOD("//")
					EndIf
				EndIf
				CNB->(MsUnLock())
				DbSkip()
			EndDo
		EndIf
	EndIf

	RestArea(aAreaCNB)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ CN180IMP  ³ Autor ³ TOTVS                 ³ Data ³04.08.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Relatorio de Avaliacoes           						   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN180IMP()							                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTA180                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function CNTA080R()

Local cUserRel := GetMV("MV_USRREL")
Local oReport

If !(__cUserID $ cUserRel)
	Help(" ",1,"USRREL",,STR0042,1,1)	//"Usuário sem permissão para impressão de relatórios! Verifique o parâmetro MV_USRREL."
	Return
EndIf

oReport := ReportDef()
oReport:PrintDialog()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ReportDef³ Autor ³ TOTVS                 ³ Data ³ 04/08/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Relatorio (Release 4)                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()

Local oReport
Local oSectionT
Local cTexto := ""
Local aOrdem := { STR0072, STR0073 } //"Data Avaliacao" ## "Planilha+Item+Produto"
Local cPerg  := "CNTA180"
Local cAliasCOA :=  GetNextAlias()
Local  CCONTA:= ""
Local  CCUSTO:= ""
Local  CCLASSE:= ""

oReport := TReport():New(cPerg,STR0046,cPerg, {|oReport| ReportPrint(oReport,cAliasCOA)},STR0047) //"AVALIACAO DE CONTRATOS" ## "Este relatorio ira emitir as Avaliacoes por Contrato"
oReport:SetLandscape()
oReport:DisableOrientation()
oReport:SetTotalInLine(.F.)

Pergunte(oReport:uParam,.F.)

//Este relatorio nao permite a personalizacao de exibicao de celulas
oSectionT := TRSection():New(oReport,STR0001,/*{"COA"}*/,aOrdem,/*Campos do SX3*/,/*Campos do SIX*/)	//"Avaliação de Contratos"
oSectionT:SetTotalInLine(.F.)
oSectionT:SetAutoSize(.T.)
TRCell():New(oSectionT,"COA_CONTRA"	,"COA",RetTitle("COA_CONTRA")	,PesqPict("COA","COA_CONTRA"),	TamSX3("COA_CONTRA")[1]	,/*lPixel*/,/*{|| bBlock }*/,/*cAlign*/,/*lBreakLine*/)
TRCell():New(oSectionT,"COA_REVISA"	,"COA","Rev."					,PesqPict("COA","COA_REVISA"),	TamSX3("COA_REVISA")[1]	,/*lPixel*/,/*{|| bBlock }*/,/*cAlign*/,/*lBreakLine*/)
TRCell():New(oSectionT,"COA_AVALIA"	,"COA","Cod.Aval."				,PesqPict("COA","COA_AVALIA"),	TamSX3("COA_AVALIA")[1]	,/*lPixel*/,/*{|| bBlock }*/,/*cAlign*/,/*lBreakLine*/)
TRCell():New(oSectionT,"COA_USUARI"	,"COA",STR0070					,"@!",	20	,/*lPixel*/,/*{|| bBlock }*/,/*cAlign*/,/*lBreakLine*/)	//Avaliador
TRCell():New(oSectionT,"COA_DTAVAL"	,"COA",RetTitle("COA_DTAVAL")	,PesqPict("COA","COA_DTAVAL"),	TamSX3("COA_DTAVAL")[1]	,/*lPixel*/,/*{|| bBlock }*/,/*cAlign*/,/*lBreakLine*/)
TRCell():New(oSectionT,"COA_PLANIL"	,"COA",STR0074					,PesqPict("COA","COA_PLANIL"),	TamSX3("COA_PLANIL")[1]	,/*lPixel*/,/*{|| bBlock }*/,/*cAlign*/,/*lBreakLine*/) //Planilha
TRCell():New(oSectionT,"COA_ITEM"	,"COA",STR0075					,PesqPict("COA","COA_ITEM")  ,	TamSX3("COA_ITEM"  )[1]	,/*lPixel*/,/*{|| bBlock }*/,/*cAlign*/,/*lBreakLine*/) //Item
TRCell():New(oSectionT,"COA_PRODUT"	,"COA",STR0076					,PesqPict("COA","COA_DESPRO"),	30	,/*lPixel*/,/*{|| bBlock }*/,/*cAlign*/,/*lBreakLine*/) //Produto
TRCell():New(oSectionT,"COA_CONCEI"	,"COA",RetTitle("COA_CONCEI")	,PesqPict("COA","COA_CONCEI"),	TamSX3("COA_CONCEI")[1]	,/*lPixel*/,/*{|| bBlock }*/,/*cAlign*/,/*lBreakLine*/)
TRCell():New(oSectionT,"COA_OCORRE"	,"COA","Cod.Ocor."				,PesqPict("COA","COA_OCORRE"),	TamSX3("COA_OCORRE")[1]	,/*lPixel*/,/*{|| bBlock }*/,/*cAlign*/,/*lBreakLine*/)
TRCell():New(oSectionT,"COA_DESOCO"	,"COA",RetTitle("COA_DESOCO")	,PesqPict("COA","COA_DESOCO"),	TamSX3("COA_DESOCO")[1]	,/*lPixel*/,/*{|| bBlock }*/,/*cAlign*/,/*lBreakLine*/)
TRCell():New(oSectionT,"CCONTA"    ,"    ","Conta"    ,"@!",15)
TRCell():New(oSectionT,"CCUSTO"    ,"    ","C. Custo"    ,"@!",15)
TRCell():New(oSectionT,"CCLASSE"    ,"    ","Classe Val."    ,"@!",15)
TRCell():New(oSectionT,"CTEXTO"		,"   ",STR0048					,PesqPict("COA","COA_DESPRO"),	50						,/*lPixel*/,  {|| cTexto}	,/*cAlign*/,.T.)	//"Observacao"
oReport:Section(1):SetHeaderPage(.T.)

Return(oReport)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrint³ Autor ³ TOTVS                 ³ Data ³04/08/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPrint(oReport,cAliasCOA)

Local nI := 0
Local cMemoCOA
Local nMCountCOA
Local cChave 	:= ""
Local cCondicao := ""
Local cTexto	:= ""
Local lQuery	:= .F.
Local lFirst	:= .T.

If oReport:nOrder == 1
	cChave:= "% COA_CONTRA, COA_REVISA, COA_DTAVAL, COA_AVALIA %"
Else
	cChave:= "% COA_CONTRA, COA_REVISA, COA_PLANIL, COA_ITEM, COA_PRODUT, COA_DTAVAL %"
Endif

MakeSqlExpr(oReport:uParam)
oReport:Section(1):Cell("CTEXTO"):SetBlock({|| cTexto })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtragem do relatório                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Query para SQL                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lQuery := .T.
oReport:Section(1):BeginQuery()

BeginSql Alias cAliasCOA
	SELECT COA_FILIAL,COA_CONTRA, COA_REVISA,COA_AVALIA,COA_USUARI,COA_DTAVAL,COA_PLANIL,COA_ITEM,COA_CODOBS,
	       rtrim(COA_PRODUT)+rTrim('-')+ (SELECT B1_DESC FROM %Table:SB1% WHERE B1_COD = COA_PRODUT AND D_E_L_E_T_ <> '*') PRODUTO,
		   COA_CONCEI,COA_OCORRE,CNB_CONTA,CNB_CC,CNB_CLVL,COA_OBSERV
	FROM %Table:COA% COA, %Table:CNB% CNB
	WHERE
		COA.COA_FILIAL = %Exp:xFilial( 'COA' )% AND
		COA.COA_CONTRA BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02% AND
		COA.COA_OCORRE BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04% AND
		COA.COA_AVALIA BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06% AND
		COA.COA_DTAVAL BETWEEN %Exp:MV_PAR07% AND %Exp:MV_PAR08% AND
		CNB.CNB_FILIAL = COA.COA_FILIAL  AND
		CNB.CNB_CONTRA = COA.COA_CONTRA  AND
		CNB.CNB_PRODUT = COA.COA_PRODUT  AND
		COA.%notDel%                     AND
		COA.%notDel%
	ORDER BY %Exp:cChave%
EndSql
oReport:Section(1):EndQuery()

oReport:SetMeter((cAliasCOA)->(LastRec()))
dbSelectArea(cAliasCOA)
While !oReport:Cancel() .And. !(cAliasCOA)->(Eof()) .And. (cAliasCOA)->COA_FILIAL == xFilial("COA")

	lFirst := .t.
	oReport:Section(1):Init()
	oReport:Section(1):Cell("COA_CONTRA"):SetValue((cAliasCOA)->COA_CONTRA)
	oReport:Section(1):Cell("COA_REVISA"):SetValue((cAliasCOA)->COA_REVISA)
	oReport:Section(1):Cell("COA_AVALIA"):SetValue((cAliasCOA)->COA_AVALIA)
	oReport:Section(1):Cell("COA_USUARI"):SetValue(UsrRetName((cAliasCOA)->COA_USUARI))
	oReport:Section(1):Cell("COA_DTAVAL"):SetValue((cAliasCOA)->COA_DTAVAL)
	oReport:Section(1):Cell("COA_PLANIL"):SetValue((cAliasCOA)->COA_PLANIL)
	oReport:Section(1):Cell("COA_ITEM"	):SetValue((cAliasCOA)->COA_ITEM)
	oReport:Section(1):Cell("PRODUTO")   :SetValue(Alltrim((cAliasCOA)->PRODUTO))
	oReport:Section(1):Cell("COA_CONCEI"):SetValue((cAliasCOA)->COA_CONCEI)
	oReport:Section(1):Cell("COA_OCORRE"):SetValue((cAliasCOA)->COA_OCORRE)
	oReport:Section(1):Cell("CCONTA")    :SetValue((cAliasCOA)->CNB_CONTA)
	oReport:Section(1):Cell("CCUSTO")    :SetValue((cAliasCOA)->CNB_CC)
	oReport:Section(1):Cell("CCLASSE")   :SetValue((cAliasCOA)->CNB_CLVL)

	oReport:Section(1):Cell("COA_DESOCO"):SetValue( Posicione("COB",1,xFilial("COB")+(cAliasCOA)->COA_OCORRE, "COB_DESCRI") )

	cTexto     := ""
	cMemoCOA   := MSMM(( cAliasCOA )->COA_CODOBS)
	nMCountCOA := MlCount( cMemoCOA, 50 )

	If nMCountCOA == 0
		oReport:Section(1):PrintLine()
	Else
		For nI:=1 to nMCountCOA
		 	cTexto := MemoLine( cMemoCOA, 50, nI )
		 	oReport:Section(1):Cell("CTEXTO"	):Show()
		 	If lFirst
				lFirst := .F.
		 	Else
			 	oReport:Section(1):Init()
				oReport:Section(1):Cell("COA_CONTRA"):Hide()
				oReport:Section(1):Cell("COA_REVISA"):Hide()
				oReport:Section(1):Cell("COA_AVALIA"):Hide()
				oReport:Section(1):Cell("COA_USUARI"):Hide()
				oReport:Section(1):Cell("COA_DTAVAL"):Hide()
				oReport:Section(1):Cell("COA_PLANIL"):Hide()
				oReport:Section(1):Cell("COA_ITEM"  ):Hide()
				oReport:Section(1):Cell("PRODUTO"):Hide()
				oReport:Section(1):Cell("COA_CONCEI"):Hide()
				oReport:Section(1):Cell("COA_OCORRE"):Hide()
				oReport:Section(1):Cell("COA_DESOCO"):Hide()
				oReport:Section(1):Cell("CNB_CONTA"):Hide()
				oReport:Section(1):Cell("CNB_CC")   :Hide()
				oReport:Section(1):Cell("CNB_CLVL") :Hide()

		 	Endif
		 	oReport:Section(1):PrintLine()
		Next nI
	 	oReport:Section(1):Finish()
	EndIf

	oReport:IncMeter()
	(cAliasCOA)->(dbSkip())

EndDo
oReport:Section(1):SetPageBreak(.T.)

Return