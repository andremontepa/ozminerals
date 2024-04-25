#include "protheus.ch"
#include "Totvs.ch"
#include "Tbiconn.ch"
#include "ozminerals.ch"

#define STATUS_NAO_ENVIADO      	"0"
#define STATUS_PROCESSANDO  		"1"
#define STATUS_FINALIZADO      		"2"
#define STATUS_PENDENCIA            "3"

#define RASTRO      				"L"
#define ENDERECO   			        "S"
#define LOCALIZACAO			        "N"
#define ORIGEM_PRODUTO				"0"
#define CONTROLE_WMS				"2"
#define IMPOSTO_CSLL  				"2"
#define CUSTO_MOEDA 				"1"
#define TIPO_CQ    				    "M"

#define TIPO_PR0   					"PR0/PR1"
#define TIPO_TRF   					"RE4/DE4"

#define TP_R4   					"R4"
#define TP_D4   					"D4"
#define TP_R0   					"R"
#define TP_D0   					"D"

#define TIPO_PA						"PA"
#define TIPO_PI						"PI"

#define INCLUI_EST  				 3

#define REGISTRO_ATUALIZADO         "Registro Atualizado"
#define REGISTRO_NAO_ATUALIZADO     "Registro Não Atualizado"

#define MOEDA_01    				"01"
#define MOEDA_02    				"02"
#define MOEDA_03   					"03"
#define MOEDA_04    				"04"
#define MOEDA_05    				"05"

#define TIPO_CX      				"CX"
#define TIPO_DP     				"DP"

#define GRAVA_FLAG  				"1"

#define OP_MANUTENCAO				"OS"

#define STATUS_RECORD    		     1
#define STATUS_NO_RECORD 		     2

/*/{Protheus.doc} OZ04M04

	Rotina para ajustar informações contabeis na ordem de produção de forma manual

	Rotina tem a mesma função que o ponto de entrada SD3250I.
	Caso ocorra alguma falha na execuação do ponto de entrada, 
	deve ser executado esta rotina para garantir integridade referencial na contabilidade.

@type Function
@author Fabio Santos - CRM Service
@since 08/10/2023
@version P12
@database MSSQL

@Obs

    Tratamento das Queries : 

		GetQryMovimentoEstoque : Retorna movimentação do Estoque tabela SD3 - Ordem de Produção
		GetQryCodigoOpercao    : Retorna o codigo da Operação Contabil para validar na tabela SF5

@see OZGENSQL
@see OZGEN18

@nested-tags:Frameworks/OZminerals
/*/
User Function OZ04M04()
	Local aSays        		      := {}  as array
	Local aButtons     		      := {}  as array
	Local nOpca        		      := 0   as numeric
	Local cTitoDlg     		      := ""  as character

	Private lFiltrado             := .F. as logical
	Private lPrevDtEnt            := .T. as Logical
	Private cDataFechamento       := ""  as character
	Private cDtUltFechamento      := ""  as character
	Private cNegaMovimentoEstoque := ""  as character
	Private	cPermiteFilial        := ""  as character
	Private cSintaxeRotina        := ""  as character
	Private cTipoProduto          := ""  as character

	cNegaMovimentoEstoque         := AllTrim(GetNewPar("OZ_TIPOCF","RE3/DE3/RE5/DE5"))
	cPermiteFilial                := AllTrim(GetNewPar("OZ_LIBFIL","02/06"))
	cTipoProduto                  := AllTrim(GetNewPar("OZ_TPMVPT","CX/DP/PI/PA"))
	cDataFechamento               := GetNewPar("MV_ULMES","20230930")
	cSintaxeRotina                := ProcName(0)

	cTitoDlg    	              := "Ajusta informação contabil na Ordem de Produção"
	cDataFechamento               := GetNewPar("MV_ULMES","20230930")
	cDtUltFechamento  	          := Substr(Dtos(cDataFechamento),7,2)
	cDtUltFechamento  	          += "/" + Substr(Dtos(cDataFechamento),5,2)
	cDtUltFechamento   	          += "/" + Substr(Dtos(cDataFechamento),1,4)

	aAdd(aSays, "Esta rotina tem por objetivo gerar ajustar conta contabil patrimonio, centro de custo,")
	aAdd(aSays, "Item contabil, Conta contabil caixa, conta contabil depreciação")
	aAdd(aSays, "nas movimentações de origem, para facilitar a conferencia e a contabilização!")
	aAdd(aSays, "A data do Ultimo fechamento de estoque foi em "+cDtUltFechamento+"!")


	aAdd(aButtons,{STATUS_RECORD   , .T., {|o| nOpca := STATUS_RECORD   , FechaBatch()}})
	aAdd(aButtons,{STATUS_NO_RECORD, .T., {|o| nOpca := STATUS_NO_RECORD, FechaBatch()}})

	FormBatch(cTitoDlg, aSays, aButtons)

	If ( nOpca == STATUS_RECORD )

		lFiltrado := PerguntaParametro()

		If lFiltrado
			If ( DtoS(MV_PAR01) < DtoS(cDataFechamento))
				FWAlertWarning("Atenção! Data informada no parametro e inferior a data do ultimo fechamento "+cDtUltFechamento+"!")
			Else
				FWMsgRun(,{|| AjustaMovimentoProducaoContabil() } ,"Processando Ordens de Producão e Movimentos do Estoque ...","Aguarde")
			EndIf
		Else
			Return
		Endif
	EndIf

Return

/*
    Função que processa o ajuste contabil na tabela SD3
*/
Static Function AjustaMovimentoProducaoContabil()
	Local aArea                   := {}  as array
	Local aCarrega                := {}  as array
	Local cAlias	     		  := ""  as character
	Local cQuery	              := ""  as character
	Local cCodOperacao            := ""  as character
	Local cTipoMovmento           := ""  as character
	Local cCodFilial    		  := ""  as character
	Local cProduto      		  := ""  as character
	Local cNumSequencia 		  := ""  as character
	Local cOrdemProducao          := ""  as character

	Private cSintaxeRotina        := ""  as character
	Private cDtUltFechamento      := ""  as character

	cSintaxeRotina                := ProcName(0)
	cDataFechamento               := GetNewPar("MV_ULMES","20230930")
	aArea  		                  := Lj7GetArea({"CT2", "CTT", "CTH", "CTD", "SB8", "SBF", "SB9",;
												 "SB2", "SB1", "SBJ", "SBK", "SD3", "SD4", "SDQ",;
												 "SD5", "SD2", "SD1", "SDB", "SDA", "SDC", "NNR",;
												 "SBE","SBZ"})
	If ( !Empty(cAlias) )
		dbSelectArea(cAlias)
		(cAlias)->(dbCloseArea())
	EndIf

	cQuery               := GetQryMovimentoEstoque()
	cAlias               := MpSysOpenQuery(cQuery)

	If ( !Empty(cAlias) )

		dbSelectArea(cAlias)

		If ( (cAlias)->(!EOF()) )

			While ((cAlias)->(!EOF()))

				cCodOperacao := RetornaCodigoOperacao((cAlias)->D3_NUMSEQ)
				
				dbSelectArea("SB1")
				SB1->(dbSetOrder(1))
				If ( SB1->(dbSeek(xFilial("SB1") + (cAlias)->D3_COD )) )

					cCodFilial     := (cAlias)->D3_FILIAL
					cProduto       := (cAlias)->D3_COD
					cNumSequencia  := (cAlias)->D3_NUMSEQ
					cTipoMovmento  := (cAlias)->D3_CF
					cOrdemProducao := (cAlias)->D3_OP

					dbSelectArea("SBZ")
					SBZ->(dbSetOrder(1))
					If ( SBZ->(dbSeek((cAlias)->D3_FILIAL + (cAlias)->D3_COD )) )

						dbSelectArea("SD3")
						SD3->(dbSetOrder(3)) 
						If ( SD3->(dbSeek((cAlias)->D3_FILIAL + (cAlias)->D3_COD + ;
								(cAlias)->D3_LOCAL + (cAlias)->D3_NUMSEQ + (cAlias)->D3_CF )) )

							If ( AllTrim((cAlias)->D3_CF) $ AllTrim(TIPO_TRF) )

								cCodOperacao := If(Substr(AllTrim((cAlias)->D3_CF),1,1) $ TP_R0, TP_R4, TP_D4)
							
							EndIf

							Begin Transaction
								SD3->(RecLock("SD3",.F.))
									SD3->D3_CONTA    := Alltrim(SB1->B1_CONTA)
									SD3->D3_CC       := Alltrim(SB1->B1_CC)
									SD3->D3_ITEMCTA  := Alltrim(SB1->B1_ITEMCC)
									SD3->D3_TIPO     := Alltrim(SB1->B1_TIPO)
									SD3->D3_XCCCUST  := Alltrim(SB1->B1_CCCUSTO)
									SD3->D3_CLVL     := Alltrim(SB1->B1_CLVL)
									SD3->D3_XOPER    := Alltrim(cCodOperacao)
								SD3->(MsUnlock())
							End Transaction
						EndIf
					Else

						ShowLogInConsole("Informações não Localizadas na tabela SDZ")
					EndIf
				EndIf 

				(cAlias)->(dbSkip())
			EndDo

			(cAlias)->(dbCloseArea())
		EndIf

		If ( len(aCarrega) > 0 )

			GeraTransferenciaEntreFiliais(aCarrega)
		EndIf
	Else
		ShowLogInConsole("Informações não Localizadas na base de Dados")
	Endif

	Lj7RestArea(aArea)

Return

/*
 	Retorna o codigo de Operação 
*/
Static Function RetornaCodigoOperacao(cPesqNumeroSequencial)
	Local aArea           := {}  as array
	Local cCodigoOperacao := ""  as character
	Local cAlias	      := ""  as character
	Local cQuery	      := ""  as character

	aArea      	          := Lj7GetArea({"CT2", "CTT", "CTH", "CTD", "SB8", "SBF", "SB9",;
										 "SB2", "SB1", "SBJ", "SBK", "SD3", "SD4", "SDQ",;
										 "SD5", "SD2", "SD1", "SDB", "SDA", "SDC", "NNR",;
										 "SBE","SBZ"})
	If ( !Empty(cAlias) )
		dbSelectArea(cAlias)
		(cAlias)->(dbCloseArea())
	EndIf

	cQuery               := GetQryOperacaoEstoque(cPesqNumeroSequencial)
	cAlias               := MpSysOpenQuery(cQuery)

	If ( !Empty(cAlias) )

		DbSelectArea(cAlias)

		If ( (cAlias)->(!EOF()) )

			While (cAlias)->(!EOF())

				dbSelectArea("SF5")
				SF5->(dbSetOrder(1))
				If ( SF5->(dbSeek(xFilial("SF5") + (cAlias)->D3_TM )) )

					cCodigoOperacao  := AllTrim(SF5->F5_XOPER)

				EndIf

				(cAlias)->(dbSkip())
			Enddo

			(cAlias)->(DbCloseArea())
		EndIf
	EndIf

	Lj7RestArea(aArea)

Return cCodigoOperacao

/*
    retorna o codigo da movimentação da ordem de produção  
*/
Static Function GetQryMovimentoEstoque(cPesqSequencia)
	Local cQuery           := "" as character

	cQuery := "SELECT " + CRLF
	cQuery += "      D3_FILIAL  AS D3_FILIAL,  " + CRLF
	cQuery += "      D3_COD     AS D3_COD,     " + CRLF
	cQuery += "      D3_CF      AS D3_CF,      " + CRLF
	cQuery += "      D3_OP      AS D3_OP,      " + CRLF
	cQuery += "      D3_LOCAL   AS D3_LOCAL,   " + CRLF
	cQuery += "      D3_NUMSEQ  AS D3_NUMSEQ,  " + CRLF
	cQuery += "      D3_TM      AS D3_TM,      " + CRLF
	cQuery += "      D3_UM      AS D3_UM,      " + CRLF
	cQuery += "      D3_XOPER   AS D3_XOPER,   " + CRLF
	cQuery += "      D3_QUANT   AS D3_QUANT,   " + CRLF
	cQuery += "      B1_TIPO    AS B1_TIPO,    " + CRLF
	cQuery += "      B1_DESC    AS B1_DESC,     " + CRLF
	cQuery += "      D3_CUSTO1  AS D3_CUSTO1,   " + CRLF
	cQuery += "      D3_CUSTO2  AS D3_CUSTO2   " + CRLF
	cQuery += "FROM  " + RetSqlTab("SD3") + CRLF
	cQuery += " 	   INNER JOIN " + CRLF
	cQuery += " 	              "+ RetSQLTab("SBZ") +  CRLF
	cQuery += " 	              ON 1=1 " + CRLF
	cQuery += " 				  AND D3_FILIAL = BZ_FILIAL " + CRLF
	cQuery += " 				  AND D3_COD    = BZ_COD    " + CRLF
	cQuery += "     			  AND " + RetSqlDel("SBZ")    + CRLF
	cQuery += " 	   INNER JOIN " + CRLF
	cQuery += " 	              "+ RetSQLTab("SB1") +  CRLF
	cQuery += " 	              ON 1=1 " + CRLF
	cQuery += "      			  AND D3_COD = B1_COD " + CRLF
	cQuery += "      			  AND " + RetSqlDel("SB1") + CRLF
	cQuery += "WHERE     1=1  " + CRLF
	cQuery += "          AND D3_FILIAL IN " + FormatIn(cPermiteFilial, "/") + " " + CRLF
	cQuery += "	         AND D3_TIPO   IN " + FormatIn(cTipoProduto, "/")    + " " + CRLF
	cQuery += "          AND D3_ESTORNO = ' '     " + CRLF
	cQuery += "          AND D3_EMISSAO BETWEEN " + ValToSql(DtoS(MV_PAR01)) + " AND " + ValToSql(DtoS(MV_PAR02)) + " " + CRLF
	cQuery += "		     AND NOT D3_CF  IN " + FormatIn(cNegaMovimentoEstoque, "/") + " " + CRLF
	cQuery += "          AND SUBSTRING(D3_OP,7,2) <> " + ValToSql(OP_MANUTENCAO) + " " + CRLF
	cQuery += "          AND " + RetSqlDel("SD3") + CRLF
	cQuery += "ORDER BY  B1_TIPO, D3_CF  DESC  " + CRLF

	u_ChangeQuery("\sql\AjustaMovimentoProducaoContabil_GetQryMovimentoEstoque.sql",@cQuery)

Return cQuery

/*
    retorna o codigo da movimentação da ordem de produção  
*/
Static Function GetQryOperacaoEstoque(cPesqNumeroSequencial)
	Local cQuery       := "" as character

	cQuery := "SELECT " + CRLF
	cQuery += "      D3_FILIAL  AS D3_FILIAL,  " + CRLF
	cQuery += "      D3_COD     AS D3_COD,     " + CRLF
	cQuery += "      D3_CF      AS D3_CF,      " + CRLF
	cQuery += "      D3_OP      AS D3_OP,      " + CRLF
	cQuery += "      D3_LOCAL   AS D3_LOCAL,   " + CRLF
	cQuery += "      D3_NUMSEQ  AS D3_NUMSEQ,  " + CRLF
	cQuery += "      D3_TM      AS D3_TM,      " + CRLF
	cQuery += "      D3_XOPER   AS D3_XOPER    " + CRLF
	cQuery += "FROM  " + RetSqlTab("SD3") +  CRLF
	cQuery += " 	   INNER JOIN " + CRLF
	cQuery += " 	              "+ RetSQLTab("SBZ") +  CRLF
	cQuery += " 	              ON 1=1 " + CRLF
	cQuery += " 				  AND D3_FILIAL = BZ_FILIAL " + CRLF
	cQuery += " 				  AND D3_COD    = BZ_COD    " + CRLF
	cQuery += "     			  AND " + RetSqlDel("SBZ")    + CRLF
	cQuery += " 	   INNER JOIN " + CRLF
	cQuery += " 	              "+ RetSQLTab("SB1") +  CRLF
	cQuery += " 	              ON 1=1 " + CRLF
	cQuery += "      			  AND D3_COD = B1_COD " + CRLF
	cQuery += "      			  AND " + RetSqlDel("SB1") + CRLF
	cQuery += "WHERE   1=1  " + CRLF
	cQuery += "        AND D3_FILIAL IN " + FormatIn(cPermiteFilial, "/") + " " + CRLF
	cQuery += "        AND D3_ESTORNO = ' ' " + CRLF
	cQuery += "        AND D3_NUMSEQ  = " + ValToSql(cPesqNumeroSequencial) + " " + CRLF
	cQuery += "		   AND NOT D3_CF  IN " + FormatIn(cNegaMovimentoEstoque, "/") + " " + CRLF
	cQuery += "        AND SUBSTRING(D3_OP,7,2) <> " + ValToSql(OP_MANUTENCAO) + " " + CRLF
	cQuery += "        AND " + RetSqlDel("SD3") + CRLF

	u_ChangeQuery("\sql\AjustaMovimentoProducaoContabil_GetQryOperacaoEstoque.sql",@cQuery)

Return cQuery

/*
    Carrega perguntas da rotina PARAMBOX
*/
Static Function PerguntaParametro() As Logical
	Local   lRet        := .F. as logical
	Local   aPergunta   := {}  as array
	Local   aRetorno    := {}  as array
	Local   dDataDe     := ""  as character
	Local   dDataAte    := ""  as character

	dDataDe     		:= dDataBase
	dDataAte    		:= dDataBase

	aAdd( aPergunta , { 1, "Data De:            " , dDataDe     , "@ 99/99/9999"          , ".T.",       , ".T.", 50    , .T. } )
	aAdd( aPergunta , { 1, "Data Ate:           " , dDataAte    , "@ 99/99/9999"          , ".T.",       , ".T.", 50    , .T. } )

	If ( ParamBox(aPergunta ,"Parametros ",aRetorno, /*4*/, /*5*/, /*6*/, /*7*/, /*8*/, /*9*/, /*10*/, .F.))

		If ( ValType(aRetorno[01]) != "D" )
			Mv_Par01 := CtoD(aRetorno[01])
		EndIf

		If ( ValType(aRetorno[02]) != "D" )
			Mv_Par02 := CtoD(aRetorno[02])
		EndIf

		lRet := .T.
	EndIf

Return lRet

/*
	Apresenta a Mensagem no Console do Protheus
*/
Static Function showLogInConsole(cMsg)

	libOzminerals.u_showLogInConsole(cMsg,cSintaxeRotina)

Return

