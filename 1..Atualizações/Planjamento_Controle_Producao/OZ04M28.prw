#include "protheus.ch"
#include "Totvs.ch"
#include "Tbiconn.ch"
#include "ozminerals.ch"

#define GRP_GROUP_NAME              "OZMinerals" 

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

/*/{Protheus.doc} OZ04M28

	Rotina Realiza o  retorno do back-up do lote 008840 
	Será gravado os dados da tabela PAV para CT2
    
@type function
@author Fabio Santos - CRM Service
@since 30/10/2023
@version P12
@database SQL SERVER 

@Obs 

	Patametro OZ_LOTECTB 
		Contem o numero do lote que será realizado o back-up
		Deve ser preenchido o parametro seguido de barra ("/")
		Exemplo de uso := 008840/008850

    Tratamento das Queries: 

		GetQryLoteContabil : Retorna dados da tabela PAV do lote 008840 para gravar a tabela (CT2)

@see OZGENSQL
@see OZGEN18

@nested-tags:Frameworks/OZminerals
/*/
User Function OZ04M28()
	Local aSays        		      := {}  as array
	Local aButtons     		      := {}  as array
	Local nOpca        		      := 0   as numeric
	Local cTitoDlg     		      := ""  as character

	Private lFiltrado             := .F. as logical
	Private lPrevDtEnt            := .T. as Logical
	Private cSintaxeRotina        := ""  as character

	cSintaxeRotina                := ProcName(0)

	cTitoDlg    	              := "Restaura o Lote (008840) Contabil do custeio!"
	cDataFechamento               := GetNewPar("MV_ULMES","20230930")
	cDtUltFechamento  	          := Substr(Dtos(cDataFechamento),7,2)
	cDtUltFechamento  	          += "/" + Substr(Dtos(cDataFechamento),5,2)
	cDtUltFechamento   	          += "/" + Substr(Dtos(cDataFechamento),1,4)

	aAdd(aSays, "Esta rotina tem por objetivo retornar o back-up do lote (008840) da tabela (PAV)!")
	aAdd(aSays, "Somente deve ser executada se tiver certeza que o lote (008840) foi deletado!")
	aAdd(aSays, "A responsabilidade desta restauração e do Executor, analisar antes de executar!")
	aAdd(aSays, "Não será autorizado executar anterior ao Ultimo fechamento que foi em "+cDtUltFechamento+"!")

	aAdd(aButtons,{STATUS_RECORD   , .T., {|o| nOpca := STATUS_RECORD   , FechaBatch()}})
	aAdd(aButtons,{STATUS_NO_RECORD, .T., {|o| nOpca := STATUS_NO_RECORD, FechaBatch()}})

	FormBatch(cTitoDlg, aSays, aButtons)

	If ( nOpca == STATUS_RECORD )

		lFiltrado := PerguntaParametro()

		If lFiltrado
			If ( DtoS(MV_PAR03) < DtoS(cDataFechamento))
				FWAlertWarning("Atenção! Data informada no parametro e inferior a data do ultimo fechamento "+cDtUltFechamento+"!")
			Else
				FWMsgRun(,{|| RestauraLoteContabilDoCusteio() } ,"Processando a Restauração do lote Contabil (008840) do Custeio ...","Aguarde")
				FWAlertWarning("Atenção! Favor executar a rotina reprocessamento de Saldo Contabil, para composição dos saldos e extração do balancete!")
			EndIf
		Else
			Return
		Endif
	EndIf

Return

/*
    Função que checa a restauração da tabela CT2 do lote 008840
*/
Static Function RestauraLoteContabilDoCusteio()
	Local aArea             := {} as array
	Local aCodigoLote       := {} as array
	Local cAlias	        := ""  as character
	Local cQuery	        := ""  as character

	Private cSintaxeRotina  := ""  as character
	Private cLoteContabil   := ""  as character

	cSintaxeRotina          := ProcName(0)

	cLoteContabil           := AllTrim(GetNewPar("OZ_LOTECTB" ,"008840"))

	aArea  		     := Lj7GetArea({"CT2", "CTT", "CTH", "CTD", "SB8", "SBF", "SB9",;
									"SB2", "SB1", "SBJ", "SBK", "SD3", "SD4", "SDQ",;
									"SD5", "SD2", "SD1", "SDB", "SDA", "SDC", "NNR",;
									"SBE","SBZ"})
	If ( !Empty(cAlias) )
		dbSelectArea(cAlias)
		(cAlias)->(dbCloseArea())
	EndIf

	cQuery               := GetQryLoteContabil()
	cAlias               := MpSysOpenQuery(cQuery)

	If ( !Empty(cAlias) )

		DbSelectArea(cAlias)

		If ( (cAlias)->(!EOF()) )

			While (cAlias)->(!EOF())

				If ( Alltrim( (cAlias)->PAV_LOTE) $ Alltrim(cLoteContabil))

					aAdd(aCodigoLote,{AllTrim((cAlias)->PAV_LOTE)})
					Exit 
				EndIf

				(cAlias)->(dbSkip())
			Enddo

			(cAlias)->(DbCloseArea())
		EndIf
	EndIf

	If Len(aCodigoLote) > 0
		GeraGravacaoLoteContabil()
	EndIf 

	Lj7RestArea(aArea)

Return

/*
    Função que processa a gravação na tabela CT2
*/
Static Function GeraGravacaoLoteContabil()
	Local aArea                   := {}  as array
	Local cAlias	     		  := ""  as character
	Local cQuery	              := ""  as character
	Local lReckLock               := .T. as logical  

	aArea  		                  := Lj7GetArea({"CT2", "CTT", "CTH", "CTD", "SB8", "SBF", "SB9",;
												 "SB2", "SB1", "SBJ", "SBK", "SD3", "SD4", "SDQ",;
												 "SD5", "SD2", "SD1", "SDB", "SDA", "SDC", "NNR",;
												 "SBE","SBZ"})
	If ( !Empty(cAlias) )
		dbSelectArea(cAlias)
		(cAlias)->(dbCloseArea())
	EndIf

	cQuery               := GetQryLoteContabil()
	cAlias               := MpSysOpenQuery(cQuery)

	If ( !Empty(cAlias) )

		dbSelectArea(cAlias)

		If ( (cAlias)->(!EOF()) )

			While ((cAlias)->(!EOF()))

					lReckLock := .F.	

					dbSelectArea("PAV")
					PAV->(dbSetOrder(1))
					If ( PAV->(dbSeek(  (cAlias)->PAV_FILIAL + (cAlias)->PAV_DATA   + ;
										(cAlias)->PAV_LOTE   + (cAlias)->PAV_SBLOTE + ;
										(cAlias)->PAV_DOC    + (cAlias)->PAV_LINHA  + ;
										(cAlias)->PAV_TPSALD + (cAlias)->PAV_EMPORI + ;
										(cAlias)->PAV_FILORI + (cAlias)->PAV_MOEDLC )))  

						dbSelectArea("CT2")
						CT2->(dbSetOrder(1))
						If ( CT2->(dbSeek(  (cAlias)->PAV_FILIAL + (cAlias)->PAV_DATA   + ;
											(cAlias)->PAV_LOTE   + (cAlias)->PAV_SBLOTE + ;
											(cAlias)->PAV_DOC    + (cAlias)->PAV_LINHA  + ;
											(cAlias)->PAV_TPSALD + (cAlias)->PAV_EMPORI + ;
											(cAlias)->PAV_FILORI + (cAlias)->PAV_MOEDLC )))  
							lReckLock := .F.	
						else
							lReckLock := .T.	
						EndIf 

						If ( lReckLock)

							Begin Transaction
								CT2->(RecLock("CT2",lReckLock))
									CT2->CT2_FILIAL	:=	(cAlias)->PAV_FILIAL 
									CT2->CT2_AGLUT 	:=	(cAlias)->PAV_AGLUT  
									CT2->CT2_AT01CR	:=	(cAlias)->PAV_AT01CR 
									CT2->CT2_AT01DB	:=	(cAlias)->PAV_AT01DB 
									CT2->CT2_AT02CR	:=	(cAlias)->PAV_AT02CR 
									CT2->CT2_AT02DB	:=	(cAlias)->PAV_AT02DB 
									CT2->CT2_AT03CR	:=	(cAlias)->PAV_AT03CR 
									CT2->CT2_AT03DB	:=	(cAlias)->PAV_AT03DB 
									CT2->CT2_AT04CR	:=	(cAlias)->PAV_AT04CR 
									CT2->CT2_AT04DB	:=	(cAlias)->PAV_AT04DB 
									CT2->CT2_ATIVCR	:=	(cAlias)->PAV_ATIVCR 
									CT2->CT2_ATIVDE	:=	(cAlias)->PAV_ATIVDE 
									CT2->CT2_CCC   	:=	(cAlias)->PAV_CCC    
									CT2->CT2_CCD   	:=	(cAlias)->PAV_CCD    
									CT2->CT2_CLVLCR	:=	(cAlias)->PAV_CLVLCR 
									CT2->CT2_CLVLDB	:=	(cAlias)->PAV_CLVLDB 
									CT2->CT2_CODCLI	:=	(cAlias)->PAV_CODCLI 
									CT2->CT2_CODFOR	:=	(cAlias)->PAV_CODFOR 
									CT2->CT2_CODPAR	:=	(cAlias)->PAV_CODPAR 
									CT2->CT2_CONFST	:=	(cAlias)->PAV_CONFST 
									CT2->CT2_CRCONV	:=	(cAlias)->PAV_CRCONV 
									CT2->CT2_CREDIT	:=	(cAlias)->PAV_CREDIT 
									CT2->CT2_CRITER	:=	(cAlias)->PAV_CRITER 
									CT2->CT2_CTLSLD	:=	(cAlias)->PAV_CTLSLD 
									CT2->CT2_CTRLSD	:=	(cAlias)->PAV_CTRLSD 
									CT2->CT2_DATA  	:=	StOD((cAlias)->PAV_DATA)   
									CT2->CT2_DATATX	:=	StOD((cAlias)->PAV_DATATX) 
									CT2->CT2_DC    	:=	(cAlias)->PAV_DC     
									CT2->CT2_DCC   	:=	(cAlias)->PAV_DCC    
									CT2->CT2_DCD   	:=	(cAlias)->PAV_DCD    
									CT2->CT2_DEBITO	:=	(cAlias)->PAV_DEBITO 
									CT2->CT2_DIACTB	:=	(cAlias)->PAV_DIACTB 
									CT2->CT2_DOC   	:=	(cAlias)->PAV_DOC    
									CT2->CT2_DTCONF	:=	StOD((cAlias)->PAV_DTCONF) 
									CT2->CT2_DTCV3 	:=	StOD((cAlias)->PAV_DTCV3)  
									CT2->CT2_DTLP  	:=	StOD((cAlias)->PAV_DTLP)   
									CT2->CT2_DTVENC	:=	StOD((cAlias)->PAV_DTVENC) 
									CT2->CT2_EMPORI	:=	(cAlias)->PAV_EMPORI 
									CT2->CT2_ESTCAN	:=	(cAlias)->PAV_ESTCAN 
									CT2->CT2_FILORI	:=	(cAlias)->PAV_FILORI 
									CT2->CT2_GRPDIA	:=	(cAlias)->PAV_GRPDIA 
									CT2->CT2_HIST  	:=	(cAlias)->PAV_HIST   
									CT2->CT2_HP    	:=	(cAlias)->PAV_HP     
									CT2->CT2_LOTE  	:=	(cAlias)->PAV_LOTE   
									CT2->CT2_SBLOTE	:=	(cAlias)->PAV_SBLOTE 
									CT2->CT2_LINHA 	:=	(cAlias)->PAV_LINHA  
									CT2->CT2_MOEDLC	:=	(cAlias)->PAV_MOEDLC 
									CT2->CT2_VALOR 	:=	(cAlias)->PAV_VALOR  
									CT2->CT2_MOEDAS	:=	(cAlias)->PAV_MOEDAS 
									CT2->CT2_ITEMD 	:=	(cAlias)->PAV_ITEMD  
									CT2->CT2_ITEMC 	:=	(cAlias)->PAV_ITEMC  
									CT2->CT2_INTERC	:=	(cAlias)->PAV_INTERC 
									CT2->CT2_IDENTC	:=	(cAlias)->PAV_IDENTC 
									CT2->CT2_TPSALD	:=	(cAlias)->PAV_TPSALD 
									CT2->CT2_SEQUEN	:=	(cAlias)->PAV_SEQUEN 
									CT2->CT2_MANUAL	:=	(cAlias)->PAV_MANUAL 
									CT2->CT2_ORIGEM	:=	(cAlias)->PAV_ORIGEM 
									CT2->CT2_ROTINA	:=	(cAlias)->PAV_ROTINA 
									CT2->CT2_LP    	:=	(cAlias)->PAV_LP     
									CT2->CT2_SEQHIS	:=	(cAlias)->PAV_SEQHIS 
									CT2->CT2_SEQLAN	:=	(cAlias)->PAV_SEQLAN 
									CT2->CT2_SLBASE	:=	(cAlias)->PAV_SLBASE 
									CT2->CT2_TAXA  	:=	(cAlias)->PAV_TAXA   
									CT2->CT2_VLR01 	:=	(cAlias)->PAV_VLR01  
									CT2->CT2_VLR02 	:=	(cAlias)->PAV_VLR02  
									CT2->CT2_VLR03 	:=	(cAlias)->PAV_VLR03  
									CT2->CT2_VLR04 	:=	(cAlias)->PAV_VLR04  
									CT2->CT2_VLR05 	:=	(cAlias)->PAV_VLR05  
									CT2->CT2_KEY   	:=	(cAlias)->PAV_KEY    
									CT2->CT2_SEGOFI	:=	(cAlias)->PAV_SEGOFI 
									CT2->CT2_SEQIDX	:=	(cAlias)->PAV_SEQIDX 
									CT2->CT2_OBSCNF	:=	(cAlias)->PAV_OBSCNF 
									CT2->CT2_USRCNF	:=	(cAlias)->PAV_USRCNF 
									CT2->CT2_HRCONF	:=	(cAlias)->PAV_HRCONF 
									CT2->CT2_MLTSLD	:=	(cAlias)->PAV_MLTSLD 
									CT2->CT2_NODIA 	:=	(cAlias)->PAV_NODIA  
									CT2->CT2_MOEFDB	:=	(cAlias)->PAV_MOEFDB 
									CT2->CT2_MOEFCR	:=	(cAlias)->PAV_MOEFCR 
									CT2->CT2_LANCSU	:=	(cAlias)->PAV_LANCSU 
									CT2->CT2_LANC  	:=	(cAlias)->PAV_LANC   
									CT2->CT2_IDCONC	:=	(cAlias)->PAV_IDCONC 
									CT2->CT2_INCONS	:=	(cAlias)->PAV_INCONS 
									CT2->CT2_PROCES	:=	(cAlias)->PAV_PROCES 
								CT2->(MsUnlock())

							End Transaction
						EndIf 
					EndIf

				(cAlias)->(dbSkip())
			EndDo

			(cAlias)->(dbCloseArea())
		EndIf
	Else
		ShowLogInConsole("Informações não Localizadas na base de Dados")
	Endif

	Lj7RestArea(aArea)

Return

/*
    retorna o codigo da movimentação da ordem de produção  
*/
Static Function GetQryLoteContabil()
	Local cQuery           := "" as character

	cQuery := "SELECT   " + CRLF
	cQuery += "			PAV_FILIAL	AS	PAV_FILIAL, " + CRLF
	cQuery += "			PAV_AGLUT 	AS	PAV_AGLUT,  " + CRLF
	cQuery += "			PAV_AT01CR	AS	PAV_AT01CR, " + CRLF
	cQuery += "			PAV_AT01DB	AS	PAV_AT01DB, " + CRLF
	cQuery += "			PAV_AT02CR	AS	PAV_AT02CR, " + CRLF
	cQuery += "			PAV_AT02DB	AS	PAV_AT02DB, " + CRLF
	cQuery += "			PAV_AT03CR	AS	PAV_AT03CR, " + CRLF
	cQuery += "			PAV_AT03DB	AS	PAV_AT03DB, " + CRLF
	cQuery += "			PAV_AT04CR	AS	PAV_AT04CR, " + CRLF
	cQuery += "			PAV_AT04DB	AS	PAV_AT04DB, " + CRLF
	cQuery += "			PAV_ATIVCR	AS	PAV_ATIVCR, " + CRLF
	cQuery += "			PAV_ATIVDE	AS	PAV_ATIVDE, " + CRLF
	cQuery += "			PAV_CCC   	AS	PAV_CCC,    " + CRLF
	cQuery += "			PAV_CCD   	AS	PAV_CCD,    " + CRLF
	cQuery += "			PAV_CLVLCR	AS	PAV_CLVLCR, " + CRLF
	cQuery += "			PAV_CLVLDB	AS	PAV_CLVLDB, " + CRLF
	cQuery += "			PAV_CODCLI	AS	PAV_CODCLI, " + CRLF
	cQuery += "			PAV_CODFOR	AS	PAV_CODFOR, " + CRLF
	cQuery += "			PAV_CODPAR	AS	PAV_CODPAR, " + CRLF
	cQuery += "			PAV_CONFST	AS	PAV_CONFST, " + CRLF
	cQuery += "			PAV_CRCONV	AS	PAV_CRCONV, " + CRLF
	cQuery += "			PAV_CREDIT	AS	PAV_CREDIT, " + CRLF
	cQuery += "			PAV_CRITER	AS	PAV_CRITER, " + CRLF
	cQuery += "			PAV_CTLSLD	AS	PAV_CTLSLD, " + CRLF
	cQuery += "			PAV_CTRLSD	AS	PAV_CTRLSD, " + CRLF
	cQuery += "			PAV_DATA  	AS	PAV_DATA,   " + CRLF
	cQuery += "			PAV_DATATX	AS	PAV_DATATX, " + CRLF
	cQuery += "			PAV_DC    	AS	PAV_DC,     " + CRLF
	cQuery += "			PAV_DCC   	AS	PAV_DCC,    " + CRLF
	cQuery += "			PAV_DCD   	AS	PAV_DCD,    " + CRLF
	cQuery += "			PAV_DEBITO	AS	PAV_DEBITO, " + CRLF
	cQuery += "			PAV_DIACTB	AS	PAV_DIACTB, " + CRLF
	cQuery += "			PAV_DOC   	AS	PAV_DOC,    " + CRLF
	cQuery += "			PAV_DTCONF	AS	PAV_DTCONF, " + CRLF
	cQuery += "			PAV_DTCV3 	AS	PAV_DTCV3,  " + CRLF
	cQuery += "			PAV_DTLP  	AS	PAV_DTLP,   " + CRLF
	cQuery += "			PAV_DTVENC	AS	PAV_DTVENC, " + CRLF
	cQuery += "			PAV_EMPORI	AS	PAV_EMPORI, " + CRLF
	cQuery += "			PAV_ESTCAN	AS	PAV_ESTCAN, " + CRLF
	cQuery += "			PAV_FILORI	AS	PAV_FILORI, " + CRLF
	cQuery += "			PAV_GRPDIA	AS	PAV_GRPDIA, " + CRLF
	cQuery += "			PAV_HIST  	AS	PAV_HIST,   " + CRLF
	cQuery += "			PAV_HP    	AS	PAV_HP,     " + CRLF
	cQuery += "			PAV_LOTE  	AS	PAV_LOTE,   " + CRLF
	cQuery += "			PAV_SBLOTE	AS	PAV_SBLOTE, " + CRLF
	cQuery += "			PAV_LINHA 	AS	PAV_LINHA,  " + CRLF
	cQuery += "			PAV_MOEDLC	AS	PAV_MOEDLC, " + CRLF
	cQuery += "			PAV_VALOR 	AS	PAV_VALOR,  " + CRLF
	cQuery += "			PAV_MOEDAS	AS	PAV_MOEDAS, " + CRLF
	cQuery += "			PAV_ITEMD 	AS	PAV_ITEMD,  " + CRLF
	cQuery += "			PAV_ITEMC 	AS	PAV_ITEMC,  " + CRLF
	cQuery += "			PAV_INTERC	AS	PAV_INTERC, " + CRLF
	cQuery += "			PAV_IDENTC	AS	PAV_IDENTC, " + CRLF
	cQuery += "			PAV_TPSALD	AS	PAV_TPSALD, " + CRLF
	cQuery += "			PAV_SEQUEN	AS	PAV_SEQUEN, " + CRLF
	cQuery += "			PAV_MANUAL	AS	PAV_MANUAL, " + CRLF
	cQuery += "			PAV_ORIGEM	AS	PAV_ORIGEM, " + CRLF
	cQuery += "			PAV_ROTINA	AS	PAV_ROTINA, " + CRLF
	cQuery += "			PAV_LP    	AS	PAV_LP,     " + CRLF
	cQuery += "			PAV_SEQHIS	AS	PAV_SEQHIS, " + CRLF
	cQuery += "			PAV_SEQLAN	AS	PAV_SEQLAN, " + CRLF
	cQuery += "			PAV_SLBASE	AS	PAV_SLBASE, " + CRLF
	cQuery += "			PAV_TAXA  	AS	PAV_TAXA,   " + CRLF
	cQuery += "			PAV_VLR01 	AS	PAV_VLR01,  " + CRLF
	cQuery += "			PAV_VLR02 	AS	PAV_VLR02,  " + CRLF
	cQuery += "			PAV_VLR03 	AS	PAV_VLR03,  " + CRLF
	cQuery += "			PAV_VLR04 	AS	PAV_VLR04,  " + CRLF
	cQuery += "			PAV_VLR05 	AS	PAV_VLR05,  " + CRLF
	cQuery += "			PAV_KEY   	AS	PAV_KEY,    " + CRLF
	cQuery += "			PAV_SEGOFI	AS	PAV_SEGOFI, " + CRLF
	cQuery += "			PAV_SEQIDX	AS	PAV_SEQIDX, " + CRLF
	cQuery += "			PAV_OBSCNF	AS	PAV_OBSCNF, " + CRLF
	cQuery += "			PAV_USRCNF	AS	PAV_USRCNF, " + CRLF
	cQuery += "			PAV_HRCONF	AS	PAV_HRCONF, " + CRLF
	cQuery += "			PAV_MLTSLD	AS	PAV_MLTSLD, " + CRLF
	cQuery += "			PAV_NODIA 	AS	PAV_NODIA,  " + CRLF
	cQuery += "			PAV_MOEFDB	AS	PAV_MOEFDB, " + CRLF
	cQuery += "			PAV_MOEFCR	AS	PAV_MOEFCR, " + CRLF
	cQuery += "			PAV_LANCSU	AS	PAV_LANCSU, " + CRLF
	cQuery += "			PAV_LANC  	AS	PAV_LANC,   " + CRLF
	cQuery += "			PAV_IDCONC	AS	PAV_IDCONC, " + CRLF
	cQuery += "			PAV_INCONS	AS	PAV_INCONS, " + CRLF
	cQuery += "			PAV_PROCES	AS	PAV_PROCES  " + CRLF
	cQuery += "FROM     " + RetSqlTab("PAV") + " (NOLOCK)  " + CRLF
	cQuery += "			WHERE 1=1               " + CRLF
	cQuery += "			AND PAV_FILIAL BETWEEN " + ValToSql(MV_PAR01) + "      AND " + ValToSql(MV_PAR02) + "  " + CRLF
	cQuery += "     	AND PAV_DATA   BETWEEN " + ValToSql(Dtos(MV_PAR03)) + " AND " + ValToSql(Dtos(MV_PAR04)) + "  " + CRLF
	cQuery += "			AND PAV_LOTE   IN " + FormatIn(cLoteContabil, "/") + " " + CRLF
	cQuery += "      	AND " + RetSqlDel("PAV") + CRLF

	u_ChangeQuery("\sql\RestauraLoteContabilDoCusteio_GetQryLoteContabil.sql",@cQuery)

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
	Local   cCodFilDe   := ""  as character
	Local   cCodFilAte  := ""  as character

	dDataDe     		:= dDataBase
	dDataAte    		:= dDataBase
	cCodFilDe           := Space(TamSx3("CT2_FILIAL")[1])
	cCodFilAte          := Replicate("Z",TamSx3("CT2_FILIAL")[1])

	aAdd( aPergunta , { 1, "Filial De:          " , cCodFilDe    , PesqPict("SM0","M0_CODFIL")     , ".T.", "SM0" , ".T.", 50    , .F. } )
	aAdd( aPergunta , { 1, "Filial Ate:         " , cCodFilAte   , PesqPict("SM0","M0_CODFIL")     , ".T.", "SM0" , ".T.", 50    , .T. } )
	aAdd( aPergunta , { 1, "Data De:            " , dDataDe      , "@ 99/99/9999"                  , ".T.",       , ".T.", 50    , .T. } )
	aAdd( aPergunta , { 1, "Data Ate:           " , dDataAte     , "@ 99/99/9999"                  , ".T.",       , ".T.", 50    , .T. } )

	If ( ParamBox(aPergunta ,"Parametros ",aRetorno, /*4*/, /*5*/, /*6*/, /*7*/, /*8*/, /*9*/, /*10*/, .F.))

		Mv_Par01 := aRetorno[01]
		Mv_Par02 := aRetorno[02]

		If ( ValType(aRetorno[03]) != "D" )
			Mv_Par03 := CtoD(aRetorno[01])
		EndIf

		If ( ValType(aRetorno[04]) != "D" )
			Mv_Par04 := CtoD(aRetorno[02])
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

