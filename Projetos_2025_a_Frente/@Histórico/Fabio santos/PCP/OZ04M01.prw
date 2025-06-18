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

#define TIPO_PR0   					"PR0"
#define TIPO_PR1   					"PR1"

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

#define GRAVA_FLAG  				"1"

#define OP_MANUTENCAO				"OS"
  
#define STATUS_RECORD    		     1
#define STATUS_NO_RECORD 		     2

/*/{Protheus.doc} OZ04M01

	Rotina para enderecamento via execauto MATA265

@type Function
@author Fabio Santos - CRM Service
@since 08/10/2023
@version P12
@database MSSQL

@Obs

    Tratamento das Queries : 

		GetQryEnderecamento : Carrega os endereçamentos com saldo a distribuir

@see MATA265
@see OZGENSQL
@see OZGEN18

@nested-tags:Frameworks/OZminerals
/*/
User Function OZ04M01()
	Local aSays        		 := {}  as array
	Local aButtons     		 := {}  as array
	Local nOpca        		 := 0   as numeric
	Local cTitoDlg     		 := ""  as character

	Private cSintaxeRotina   := ""  as character

	cSintaxeRotina           := ProcName(0)
	cTitoDlg    	         := "Manutenção Endereços - OzMinerals"

	aAdd(aSays, "Esta rotina tem por objetivo endereçar produtos com saldo a distribuir")
	aAdd(aSays, "Somente é permitido informar um Armazen padrão e um Endereço Padrão!")
	aAdd(aSays, "Após Utilizar esta rotina, verificar os endereçamentos realizados!")
	
	aAdd(aButtons,{STATUS_RECORD   , .T., {|o| nOpca := STATUS_RECORD   , FechaBatch()}})
	aAdd(aButtons,{STATUS_NO_RECORD, .T., {|o| nOpca := STATUS_NO_RECORD, FechaBatch()}})

	FormBatch(cTitoDlg, aSays, aButtons)

	If ( nOpca == STATUS_RECORD )

		lFiltrado := PerguntaParametro()

		If lFiltrado
            FWMsgRun(,{|| ManutencaoEnderecamentoEstoque() } ,"Processando Endereçamento ...","Aguarde")
			FWAlertWarning("Atenção! Favor executar a recalculo do custo medio novamente, e caso já tenha feito a contabilização, será necessario executar novamente!")
		Endif
	EndIf

Return

/*
   Executa o endereçamento pela rotina MATA265 - via Execauto
*/
Static Function ManutencaoEnderecamentoEstoque()
	Local aCabecalho        := {}  as array
	Local aItens            := {}  as array
	Local aLogAuto          := {}  as array
	Local nQuantidade       := 0   as integer
	Local nAuxiliar			:= 0   as integer
	Local lGravaTabela      := .T. as logical
	Local cAlias	        := ""  as character
	Local cQuery	        := ""  as character
	Local cCodigoProduto    := ""  as character
	Local cLog              := ""  as character
	Local cNumSequencial    := ""  as character
	Local cNumDocumento     := ""  as character
	Local cLocalEstoque     := ""  as character

	Private lMsErroAuto     := .F. as logical

	aArea       	        := Lj7GetArea({"CT2", "CTT", "CTH", "CTD", "SB8", "SBF", "SB9",;
										   "SB2", "SB1", "SBJ", "SBK", "SD3", "SD4", "SDQ",;
										   "SD5", "SD2", "SD1", "SDB", "SDA", "SDC", "NNR",;
										   "SBE", "SBZ"})

	cQuery                  := GetQryEnderecamento()
	cAlias                  := MpSysOpenQuery(cQuery)

	If ( !Empty(cAlias) )

		DbSelectArea(cAlias)

		If ( (cAlias)->(!EOF()) )

			While (cAlias)->(!EOF())

				lGravaTabela      := .F.
				aCabecalho        := {}
				aItens            := {}
				cCodigoProduto    := (cAlias)->DA_PRODUTO
				cNumSequencial    := (cAlias)->DA_NUMSEQ
				cNUmDocumento     := (cAlias)->DA_DOC
				cLocalEstoque     := (cAlias)->DA_LOCAL
				nQuantidade       := (cAlias)->DA_SALDO

				If ( AllTrim(Posicione("SB1",1,xFilial("SB1")+cCodigoProduto,"B1_COD")) == AllTrim(cCodigoProduto) )
					lGravaTabela   := .T.
				Else
					lGravaTabela   := .F.
					cLog           := "Codigo de Produto Não Localizado"
				EndIf

				If ( lGravaTabela )
					If ( AllTrim(Posicione("SB1",1,xFilial("SB1")+cCodigoProduto,"B1_LOCALIZ")) $ AllTrim(ENDERECO) )
						lGravaTabela   := .T.
					Else
						lGravaTabela   := .F.
						cLog           := "Este Produto não controla Endereço, Não será Incluido"
					EndIf
				EndIf

				If ( lGravaTabela )
					If ( AllTrim(Posicione("NNR",1,xFilial("NNR")+cLocalEstoque,"NNR_CODIGO")) == AllTrim(cLocalEstoque) )
						lGravaTabela   := .T.
					Else
						lGravaTabela   := .F.
						cLog           := "Armazen Não Localizado"
					EndIf
				EndIf

				If ( lGravaTabela )

					lMsErroAuto := .F.

					dbSelectArea("SB1")
					SB1->(dbSetOrder(1))
					If ( SB1->(dbSeek(xFilial("SB1") + cCodigoProduto )) )

						DbSelectArea("SDA")
						DbSelectArea("SDB")

						ProcRegua(0)
						IncProc("Endereçando o produto " + Alltrim(SB1->B1_COD) + "...")

						aCabecalho  := { {"DA_PRODUTO"	  ,cCodigoProduto    , Nil},;
										 {"DA_NUMSEQ"     ,cNumSequencial 	 , Nil},;
										 {"DA_DOC"        ,cNUmDocumento 	 , Nil}}

						aAdd( aItens ,{	{"DB_ITEM"	    ,"0001"     			, Nil},;
										{"DB_LOCAL"   	, AllTrim(MV_PAR05)  	, Nil},;
										{"DB_LOCALIZ"	, AllTrim(MV_PAR06)	    , Nil},;
										{"DB_QUANT"   	, nQuantidade   	    , Nil},;
										{"DB_DATA"    	, dDATABASE			    , Nil},;
										{"DB_LOTECTL"   , ""                    , Nil}})

						MATA265( aCabecalho, aItens, 3)

						If ( lMSErroAuto )

							DisarmTransaction()

							aLogAuto := GetAutoGRLog()
					
							For nAuxiliar := 1 To Len(aLogAuto)
								cLog += aLogAuto[nAux] + CRLF
							Next nAuxiliar

							ShowLogInConsole(cLog)	
							Aviso("Atenção - ExecAuto(MATA265) !!!" ,cLog,{"OK"})

						Else 	
							cLog := "Produto " + cCodigoProduto + " Endereçado com sucesso"
							ShowLogInConsole(cLog)
						EndIf

					EndIf

				EndIf

				(cAlias)->(dbSkip())
			EndDo

			(cAlias)->(dbCloseArea())
		Else
			ShowLogInConsole("Informações não Localizadas na base de dadaos")
		EndIf

	EndIf

	Lj7RestArea(aArea)

Return

/*
     Carrega os endereçamentos com saldo a distribuir
*/
Static Function GetQryEnderecamento()
	Local cQuery       := "" as character

	cQuery := "SELECT " + CRLF
	cQuery += "      DA_FILIAL  AS DA_FILIAL,  " + CRLF
	cQuery += "      DA_PRODUTO AS DA_PRODUTO, " + CRLF
	cQuery += "      DA_QTDORI  AS DA_QTDORI,  " + CRLF
	cQuery += "      DA_SALDO   AS DA_SALDO,   " + CRLF
	cQuery += "      DA_LOCAL   AS DA_LOCAL,   " + CRLF
	cQuery += "      DA_NUMSEQ  AS DA_NUMSEQ,  " + CRLF
	cQuery += "      DA_DATA    AS DA_DATA,    " + CRLF
	cQuery += "      DA_DOC     AS DA_DOC,     " + CRLF
	cQuery += "      B1_TIPO    AS B1_TIPO,    " + CRLF
	cQuery += "      B1_DESC    AS B1_DESC     " + CRLF
	cQuery += "FROM  " + RetSqlTab("SDA") + " (NOLOCK)  " + CRLF
	cQuery += "      INNER JOIN " + RetSqlTab("SB1") + " ON 1=1  " + CRLF
	cQuery += "      			AND DA_PRODUTO = B1_COD " + CRLF
	cQuery += "     	 		AND " + RetSqlDel("SB1") + CRLF
	cQuery += "WHERE 1=1  " + CRLF
	cQuery += "      AND "+RetSqlFil("SDA")+" " + CRLF
	cQuery += "      AND DA_SALDO  <>  0 " + CRLF
	cQuery += "      AND DA_DATA    BETWEEN " + ValToSql(DtoS(MV_PAR01)) + " AND " + ValToSql(DtoS(MV_PAR02)) + " " + CRLF
	cQuery += "      AND DA_PRODUTO BETWEEN " + ValToSql(MV_PAR03) + " AND " + ValToSql(MV_PAR04) + " " + CRLF
	cQuery += "      AND DA_LOCAL   = 		" + ValToSql(MV_PAR05) + " " + CRLF
	cQuery += "      AND " + RetSqlDel("SDA") + CRLF

	u_ChangeQuery("\sql\OZESTEND_GetQryEnderecamento.sql",@cQuery)

Return cQuery
/*
    Carrega perguntas da rotina PARAMBOX
*/
Static Function PerguntaParametro() As Logical
	Local   lRet         := .F. as logical
	Local   aPergunta    := {}  as array
	Local   aRetorno     := {}  as array
	Local   dDataDe      := ""  as character
	Local   dDataAte     := ""  as character
	Local   cOrdProdDe   := ""  as Character
	Local   cOrdProdAte  := ""  as Character
	Local   cOrdArmazen  := ""  as Character
	Local   cOrdEndereco := ""  as Character

	dDataDe     		:= dDataBase
	dDataAte    		:= dDataBase
	cOrdProdDe  		:= Space(TamSx3("B1_COD")[1])
	cOrdProdAte 		:= Replicate("Z",TamSx3("D3_OP")[1])
	cOrdArmazen  		:= Space(TamSx3("NNR_CODIGO")[1])
	cOrdEndereco        := Space(TamSx3("BE_LOCALIZ")[1])

	aAdd( aPergunta , { 1, "Data De:            " , dDataDe     , "@ 99/99/9999"               , ".T.",       , ".T.", 50    , .T. } )
	aAdd( aPergunta , { 1, "Data Ate:           " , dDataAte    , "@ 99/99/9999"               , ".T.",       , ".T.", 50    , .T. } )
	aAdd( aPergunta , { 1, "Produto De:         " , cOrdProdDe  , PesqPict("SB1","B1_COD")     , ".T.", "SB1" , ".T.", 50    , .F. } )
	aAdd( aPergunta , { 1, "Produto Ate:        " , cOrdProdAte , PesqPict("SB1","B1_COD")     , ".T.", "SB1" , ".T.", 50    , .T. } )
	aAdd( aPergunta , { 1, "Armazen Padrão:     " , cOrdArmazen , PesqPict("NNR","NNR_CODIGO") , ".T.", "NNR" , ".T.", 50    , .T. } )
	aAdd( aPergunta , { 1, "Endereço Padrão:    " , cOrdEndereco, PesqPict("SBE","BE_LOCALIZ") , ".T.", "SBE" , ".T.", 50    , .T. } )

	If ( ParamBox(aPergunta ,"Parametros ",aRetorno, /*4*/, /*5*/, /*6*/, /*7*/, /*8*/, /*9*/, /*10*/, .F.))

		If ( ValType(aRetorno[01]) != "D" )
			Mv_Par01 := CtoD(aRetorno[01])
		EndIf

		If ( ValType(aRetorno[02]) != "D" )
			Mv_Par02 := CtoD(aRetorno[02])
		EndIf

		Mv_Par03 := aRetorno[03]
		Mv_Par04 := aRetorno[04]
		Mv_Par05 := aRetorno[05]
		Mv_Par06 := aRetorno[06]

		lRet := .T.
	EndIf

Return lRet

/*
	Apresenta a Mensagem no Console do Protheus
*/
Static Function showLogInConsole(cMsg)

	libOzminerals.u_showLogInConsole(cMsg,cSintaxeRotina)

Return
