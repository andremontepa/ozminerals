#INCLUDE "Topconn.ch"
#INCLUDE "Protheus.ch"
//#INCLUDE "report.ch"
#define DMPAPER_A4 9

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³XRELAVAL     º Autor ³ Charles Lima     º Data ³  10/09/20  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ RELATORIO DE AVALIAÇÕES DE CONTRATOS                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso   ³ SIGAGCT >                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


User Function XRELAVAL

	Private cPerg   := "CNTA180"
	//AjustaSx1(cPerg)
	Private oReport

	//If !Pergunte(cPerg, .F.)
	//Return
	//EndIf

	oReport := ReportDef()
	oReport:PrintDialog()

Return

/*
CRIAÇÃO DO OBJETO DE IMPRESSÃO DO RELATÓRIO
*/
Static Function ReportDef()

	Local oReport
	Local oSec1

	oReport := TReport():New("XRELAVAL","Relatório de Avaliações de Contrato",cPerg,{|oReport| PrintReport(oReport)},"Impressão de Avaliações de Contratos")
	oReport:SetLandscape(.T.)

	//oSec1 := TRSection():New(oReport,"Notas Fiscais")

	oSec1 := TRSection():New( oReport , "Avaliações", {"TRB"} )

	//Pergunte(cPerg,.F.)

	//TRCell():New(oSection1,/*Celula*/ ,/*Tabela*/,/*Titulo da Celula*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco de código }*/)
	TRCell():New(oSec1, "COA_FILIAL"  , "TRB",,PesqPict('COA',"COA_FILIAL"),TamSX3("COA_FILIAL")[1],,,,,,,,.F.)
	TRCell():New(oSec1, "COA_CONTRA"  , "TRB","Nr.Contrato",PesqPict('COA',"COA_CONTRA") ,TamSX3("COA_CONTRA")[1],,,,,,,,.F.)
	TRCell():new(oSec1, "COA_REVISA"  , "TRB",,PesqPict('COA',"COA_REVISA"),TamSX3("COA_REVISA")[1],,,,,,,,.F.)
	TRCell():new(oSec1, "COA_AVALIA"  , "TRB","Cod.Avaliação",PesqPict('COA',"COA_AVALIA") ,TamSX3("COA_AVALIA")[1],,,,,,,,.F.)
	//TRCell():New(oSec1, "COA_USUARI", "TRB",,PesqPict('COA',"COA_USUARI") ,TamSX3("COA_USUARI")[1],,,,,,,,.F.)
	TRCell():new(oSec1, "Nome Avaliador", "TRB",,"@!"                       ,30,,,,,,,,.F.)
	TRCell():new(oSec1, "COA_DTAVAL"  , "TRB",,PesqPict('COA',"COA_DTAVAL") ,TamSX3("COA_DTAVAL")[1],,,,,,,,.F.)
	//TRCell():new(oSec1, "COA_PLANIL", "TRB",,PesqPict('COA',"COA_PLANIL") ,TamSX3("COA_PLANIL")[1],,,,,,,,.F.)
	TRCell():new(oSec1, "COA_ITEM"    , "TRB","Item",PesqPict('COA',"COA_ITEM"),TamSX3("COA_ITEM")[1],,,,,,,,.F.)
	TRCell():new(oSec1, "COA_PRODUT"  , "TRB","Cod.Produto",PesqPict('COA',"COA_PRODUT") ,TamSX3("COA_PRODUT")[1],,,,,,,,.F.)
	TRCell():new(oSec1, "Desc.Produto", "TRB",,PesqPict('SB1',"B1_DESC")    ,TamSX3("B1_DESC")[1]+10,,,,,,,,.F.)
	TRCell():new(oSec1, "COA_CONCEI"  , "TRB",,"@!"                         ,15,,,,,,,,.F.)
	//TRCell():new(oSec1, "COA_OCORRE", "TRB",,PesqPict('COA',"COA_OCORRE") ,TamSX3("COA_OCORRE")[1],,,,,,,,.F.)
	TRCell():new(oSec1, "COB_DESCRI"  , "TRB","Desc.Ocorrência",PesqPict('COB',"COB_DESCRI") ,TamSX3("COB_DESCRI")[1]+10,,,,,,,,.F.)
	//TRCell():new(oSec1, "CNB_CONTA" , "TRB",,PesqPict('CNB',"CNB_CONTA")  ,TamSX3("CNB_CONTA")[1],,,,,,,,.F.) 
	//TRCell():new(oSec1, "CNB_ITEMCT"  , "TRB","Item Ctb",PesqPict('CNB',"CNB_ITEMCT"),TamSX3("CNB_ITEMCT")[1],,,,,,,,.F.) 
	//TRCell():new(oSec1, "CNB_CC"      , "TRB","C.Custo",PesqPict('CNB',"CNB_CC")     ,TamSX3("CNB_CC")[1],,,,,,,,.F.) 
	//TRCell():new(oSec1, "CNB_CLVL"    , "TRB","Classe Vlr",PesqPict('CNB',"CNB_CLVL"),TamSX3("CNB_CLVL")[1],,,,,,,,.F.)
	TRCell():new(oSec1, "COA_OBSERV"  , "TRB","Observações","@!"                     ,60,,,,,,,,.F.)

	//TRFunction():New(/*Cell*/             ,/*cId*/,/*Function*/,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,/*lEndReport*/,/*lEndPage*/,/*Section*/)
	//TRFunction():New(oSec1:Cell("F3_NFISCAL"),/*cId*/,"COUNT"     ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F.           ,.T.           ,.F.        ,oSec1)


Return oReport

/*******************************
-> Impressão do relatório
*******************************/
Static Function PrintReport(oReport)

	Local oSec1  := oReport:Section(1)
	Local cQuery := ""
	//Local cQry   := ""
	Local cQry2  := ""
	Local cObs   := ""

	Pergunte(cPerg,.F.)

	cQuery := "SELECT COA_FILIAL, COA_CONTRA, COA_REVISA, COA_AVALIA, COA_USUARI, COA_DTAVAL, COA_PLANIL, COA_ITEM, COA_PRODUT, "
	cQuery += "COA_CONCEI, COA_OCORRE, COB_DESCRI, COA_CODOBS FROM "+RetSQLName("COA")+" COA "
	cQuery += "INNER JOIN "+RetSQLName("COB")+" COB ON COB_OCORRE = COA_OCORRE "
	cQuery += "WHERE COA.D_E_L_E_T_ <> '*' AND COB.D_E_L_E_T_ <> '*' AND COA_FILIAL >= '"+MV_PAR10+"' AND COA_FILIAL <= '"+MV_PAR11+"' AND "
	cQuery += "COA_CONTRA >= '"+MV_PAR01+"' AND COA_CONTRA <= '"+MV_PAR02+"' AND COA_OCORRE >= '"+MV_PAR03+"' AND COA_OCORRE <= '"+MV_PAR04+"' AND "
	cQuery += "COA_AVALIA >= '"+MV_PAR05+"' AND COA_AVALIA <= '"+MV_PAR06+"' AND COA_DTAVAL >= '"+DtoS(MV_PAR07)+"' AND COA_DTAVAL <= '"+DtoS(MV_PAR08)+"' AND "
	If MV_PAR09 = "1"
		cQuery += "COA_ITEM = '' "
	Else
		cQuery += "COA_ITEM <> '' "
	Endif
	cQuery += "ORDER BY COA_CONTRA, COA_REVISA, COA_USUARI, COA_DTAVAL "
	cQuery := ChangeQuery(cQuery)

	DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), "TRB", .T., .T.)
	dbSelectArea("TRB")
	TRB->(dbgotop())

	oSec1:Init()
	//oSec1:Cell("CONTROLE"):Disable()
	oReport:SetMeter(RecCount())

	Do While TRB->(!Eof())
		oSec1:Cell("COA_FILIAL"):SetValue(TRB->COA_FILIAL)
		oSec1:Cell("COA_CONTRA"):SetValue(TRB->COA_CONTRA)
		oSec1:Cell("COA_REVISA"):SetValue(TRB->COA_REVISA)
		oSec1:Cell("COA_AVALIA"):SetValue(TRB->COA_AVALIA)
		//oSec1:Cell("COA_USUARI"):SetValue(TRB->COA_USUARI)
		oSec1:Cell("Nome Avaliador"):SetValue(UsrRetName(TRB->COA_USUARI))
		oSec1:Cell("COA_DTAVAL"):SetValue(StoD(TRB->COA_DTAVAL))
		If MV_PAR09 = "2"
			//oSec1:Cell("COA_PLANIL"):SetValue(TRB->COA_PLANIL)
			oSec1:Cell("COA_ITEM"):SetValue(TRB->COA_ITEM)
			oSec1:Cell("COA_PRODUT"):SetValue(TRB->COA_PRODUT)
			oSec1:Cell("Desc.Produto"):SetValue(Posicione("SB1",1,xFilial("SB1")+TRB->COA_PRODUT, "B1_DESC"))
		Else
			//oSec1:Cell("COA_PLANIL"):disable()
			oSec1:Cell("COA_ITEM"):disable()
			oSec1:Cell("COA_PRODUT"):disable()
			oSec1:Cell("Desc.Produto"):disable()	
		Endif

		If TRB->COA_CONCEI = "1"
			oSec1:Cell("COA_CONCEI"):SetValue("1-Otimo")
		Elseif TRB->COA_CONCEI = "2"
			oSec1:Cell("COA_CONCEI"):SetValue("2-Bom")
		Elseif TRB->COA_CONCEI = "3"
			oSec1:Cell("COA_CONCEI"):SetValue("3-Regular")
		Elseif TRB->COA_CONCEI = "4"
			oSec1:Cell("COA_CONCEI"):SetValue("4-Pessimo")
		Endif
		//oSec1:Cell("COA_OCORRE"):SetValue(TRB->COA_OCORRE)
		oSec1:Cell("COB_DESCRI"):SetValue(TRB->COB_DESCRI)

		/*If MV_PAR09 = "2"
		cQry := "SELECT CNB_CONTA, CNB_ITEMCT, CNB_CC, CNB_CLVL FROM "+RetSQLName("CNB")+" CNB "
		cQry += "WHERE CNB.D_E_L_E_T_ <> '*' AND CNB_FILIAL = '"+TRB->COA_FILIAL+"' AND CNB_CONTRA = '"+TRB->COA_CONTRA+"' AND "
		cQry += "CNB_REVISA = '"+TRB->COA_REVISA+"' AND CNB_NUMERO = '"+TRB->COA_PLANIL+"' AND CNB_ITEM = '"+TRB->COA_ITEM+"' AND "
		cQrY += "CNB_PRODUT = '"+TRB->COA_PRODUT+"' "
		cQry := ChangeQuery(cQry)

		DbUseArea(.T., "TOPCONN", TcGenQry(,,cQry), "TRC", .T., .T.)
		dbSelectArea("TRC")
		TRC->(dbgotop())  

		//oSec1:Cell("CNB_CONTA"):SetValue(TRC->CNB_CONTA)
		oSec1:Cell("CNB_ITEMCT"):SetValue(TRC->CNB_ITEMCT)
		oSec1:Cell("CNB_CC"):SetValue(TRC->CNB_CC)
		oSec1:Cell("CNB_CLVL"):SetValue(TRC->CNB_CLVL)

		TRC->(DbCloseArea())
		Else
		//oSec1:Cell("CNB_CONTA"):disable()
		oSec1:Cell("CNB_ITEMCT"):disable()
		oSec1:Cell("CNB_CC"):disable()
		oSec1:Cell("CNB_CLVL"):disable()
		Endif*/

		If !Empty(TRB->COA_CODOBS)
			cQry2 := "SELECT YP_CHAVE, YP_SEQ, YP_TEXTO, YP_CAMPO FROM "+RetSQLName("SYP")+" SYP "
			cQry2 += "WHERE SYP.D_E_L_E_T_ <> '*' AND YP_CHAVE = '"+TRB->COA_CODOBS+"' " 
			cQry2 += "ORDER BY YP_CHAVE, YP_SEQ"

			DbUseArea(.T., "TOPCONN", TcGenQry(,,cQry2), "TRD", .T., .T.)
			dbSelectArea("TRD")
			TRD->(dbgotop()) 

			Do While TRD->(!Eof())
				cObs += Alltrim(TRD->YP_TEXTO)
				TRD->(DbSkip())
			Enddo
			TRD->(DbCloseArea())
			oSec1:Cell("COA_OBSERV"):SetValue(cObs)
			cObs := ""
		Endif

		oSec1:PrintLine()
		oReport:SkipLine(1)
		oReport:IncMeter()

		TRB->(DbSkip())
	Enddo

	oSec1:Finish()
	TRB->(DbCloseArea())
Return

