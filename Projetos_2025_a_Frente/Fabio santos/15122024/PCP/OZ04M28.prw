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
@since 07/07/2024
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

	aAdd(aSays, "Esta rotina tem por objetivo realizar o back-up do lote (008840) da tabela (PAV)!")
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
				If ( FindFunction("estoque.Producao.Custeio.u_GravaLoteContabilDoCusteio") )
					FWMsgRun(,{|| estoque.Producao.Custeio.u_GravaLoteContabilDoCusteio(MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04)} ,"Processando a Back-up do lote Contabil (008840) do Custeio ...","Aguarde")
				EndIf
				FWAlertWarning("Atenção! Favor executar a rotina reprocessamento de Saldo Contabil, para composição dos saldos e extração do balancete!")
			EndIf
		Else
			Return
		Endif
	EndIf

Return

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

