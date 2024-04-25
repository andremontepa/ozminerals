#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWCOMMAND.CH"
#Include "TopConn.Ch"
#define DMPAPER_A4 9

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RCOR005    º Autor ³ Ismael junior      º Data ³  30/01/18  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatório de saldos por C. Custo, item contabil e conta    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACOM  -- >  Relatórios/#Rel. Saldo p/ C. custos         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function RCOR005()
Local oReport := nil
Local cPerg:= "RCOR005"

//gero a pergunta de modo oculto, ficando disponível no botão ações relacionadas
Pergunte(cPerg,.F.)

oReport := RptDef(cPerg)
oReport:PrintDialog()
Return

Static Function RptDef(cNome)
Local oReport := Nil
Local oSection1:= Nil
Local oSection2:= Nil
Local oBreak := Nil
//Local oFunction

/*Sintaxe: TReport():New(cNome,cTitulo,cPerguntas,bBlocoCodigo,cDescricao)*/
oReport := TReport():New(cNome,"Relatório Saldo por Classe de valor ",cNome,{|oReport| ReportPrint(oReport)},"Saldo por Classe de valor ")
oReport:SetLandscape() //SetPortrait()
oReport:SetTotalInLine(.F.)

oSection1:= TRSection():New(oReport, "Centro de Custo e Item", {"TRB"}, , .F., .T.)
//ZW3_NUM,ZW3_TIPO,ZW3_DATA,ZW3_CCUSTO,CTT_DESC01,ZW3_ITEMCO,CTD_DESC01,ZW3_CONTA,CT1_DESC01,ZW3_ANO,ZW3_VALOR,ZW3_HISTOR
TRCell():new(oSection1, "CCUSTO"   ,"TRB","CENTRO DE CUSTO"	 ,,TAMSX3("ZW5_CCUSTO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection1, "NOMECCU"  ,"TRB","Descrição C. de Custo",,TAMSX3("CTT_DESC01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection1, "ITEMCO"   ,"TRB","ITEM CONTABIL" ,,TAMSX3("ZW2_ITEMCO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection1, "NOMEICO"  ,"TRB","Descrição I. Contabil",,TAMSX3("CTD_DESC01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection1, "CLVL"     ,"TRB","Classe de Valor" ,,TAMSX3("ZW2_CLVL")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection1, "ANO" 	   ,"TRB","ANO"  ,,TAMSX3("ZW3_ANO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)

oSection2:= TRSection():New(oReport, "Classe", {"TRB"}, NIL, .F., .T.)
TRCell():new(oSection2, "ITEMCON"   ,"TRB","ITEM CONTABIL" ,,TAMSX3("ZW2_ITEMCO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection2, "CONTA"	   ,"TRB","CLASSE" ,,TAMSX3("ZW2_CONTA")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
//TRCell():new(oSection2, "NOMECON"  ,"TRB","Descrição da Classe" ,,TAMSX3("CTH_DESC01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection2, "VLTOT"    ,"TRB","TOTAL ANO"  ,"@E 999,999,999.99",TAMSX3("ZW2_PREANO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)

oBreak := TRBreak():New(oSection2,{||oSection2:Cell("ITEMCON"):UPRINT},"SUB-TOTAL",.F.)
TRFunction():New(oSection2:Cell("ITEMCON"),NIL,"COUNT",oBreak,,,,.F.,.T.)
TRFunction():New(oSection2:Cell("VLTOT"),NIL,"SUM",oBreak,"@E 999,999,999.99",,,.F.,.T.)
oReport:SetTotalInLine(.F.)

//Aqui, farei uma quebra  por seção
//	oSection1:SetPageBreak(.T.)
//	oSection1:SetTotalText(" teste teste")
Return(oReport)

Static Function ReportPrint(oReport)
Local oSection1  := oReport:Section(1)
Local oSection2  := oReport:Section(2)
Local nValor     := 0
Local cCusto     := ""
Local cItemco    := ""
Local cConta     := ""
Local cQuery     := ""
//Monto minha consulta conforme parametros passado

cQuery := "SELECT ZW1_CCUSTO,CTT_DESC01,ZW2_ITEMCO,CTD_DESC01,ZW2_CONTA,ZW2_CLVL,ZW2_ANO,ZW2_VLANO,ZW2_RELANO,ZW2_PREANO "
cQuery += "FROM " +RetSqlName("ZW1")+" ZW1 "
cQuery += "INNER JOIN " +RetSqlName("ZW2")+" ZW2 ON ZW2_CCUSTO = ZW1_CCUSTO AND ZW2_ITEMCO = ZW1_ITEMCO AND ZW2_CLVL = ZW1_CLVL AND ZW2_ANO = ZW1_ANO AND ZW2.D_E_L_E_T_ != '*' 
cQuery += "INNER JOIN " +RetSqlName("CTT")+" CTT ON CTT_CUSTO = ZW2_CCUSTO AND CTT.D_E_L_E_T_ != '*' "
cQuery += "INNER JOIN " +RetSqlName("CTD")+" CTD ON CTD_ITEM = ZW2_ITEMCO AND CTD.D_E_L_E_T_ != '*' "
cQuery += "WHERE ZW1_CCUSTO BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
cQuery += "AND ZW1_ITEMCO BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
cQuery += "AND ZW1_CLVL = '" + MV_PAR05 + "' "
cQuery += "AND ZW1_ANO = '" + MV_PAR06 + "' "
cQuery += "AND ZW1.D_E_L_E_T_ != '*' "
cQuery += "ORDER BY ZW1_ANO,ZW1_CCUSTO,ZW1_ITEMCO "

//Se o alias estiver aberto, irei fechar, isso ajuda a evitar erros
IF Select("TRB") <> 0
	TRB->(DbCloseArea())
ENDIF

//Tratando a query para o AdvPL

//crio o novo alias
TCQUERY cQuery NEW ALIAS "TRB"

dbSelectArea("TRB")
TRB->(dbGoTop())

oReport:SetMeter(TRB->(LastRec()))

//Irei percorrer todos os meus registros
While TRB->(!Eof())
	If oReport:Cancel()
		Exit
	EndIf
	dbSelectArea("TRB")
	//inicializo a primeira seção
	oSection1:Init()
	
	oReport:IncMeter()
	
	IncProc("Imprimindo Centro de Custo "+alltrim(TRB->ZW1_CCUSTO))
	oSection1:Cell("CCUSTO"):SetValue(TRB->ZW1_CCUSTO)
	oSection1:Cell("NOMECCU"):SetValue(TRB->CTT_DESC01)
	oSection1:Cell("ITEMCO"):SetValue(TRB->ZW2_ITEMCO)
	oSection1:Cell("NOMEICO"):SetValue(TRB->CTD_DESC01)
	oSection1:Cell("CLVL"):SetValue(TRB->ZW2_CLVL)
	oSection1:Cell("ANO"):SetValue(TRB->ZW2_ANO)
	//imprimo a primeira seção
	oSection1:Printline()
	
   //	oSection2:Printline()
	cItemco 	:= TRB->ZW2_ITEMCO
	cCusto  	:= TRB->ZW1_CCUSTO
	//inicializo a segunda seção
	oSection2:init()
	While TRB->ZW2_ITEMCO = cItemco .and. TRB->ZW1_CCUSTO = cCusto
		oReport:IncMeter()
		nVlTot := TRB->ZW2_PREANO - (TRB->ZW2_VLANO + TRB->ZW2_RELANO)
		IncProc("Imprimindo Classe de valor "+alltrim(TRB->ZW2_CONTA))
		
		oSection2:Cell("ITEMCON"):SetValue(TRB->ZW2_ITEMCO)
		oSection2:Cell("CONTA"):SetValue(TRB->ZW2_CONTA)
		//oSection2:Cell("NOMECON"):SetValue(TRB->CTH_DESC01)
		oSection2:Cell("VLTOT"):SetValue(nVlTot)
		
		oSection2:Printline()
		cItemco 	:= TRB->ZW2_ITEMCO
		cCusto  	:= TRB->ZW1_CCUSTO
		TRB->(dbSkip())
	EndDo
	//finalizo a segunda seção para que seja reiniciada para o proximo registro
	oSection2:Finish()
	//imprimo uma linha para separar uma NCM de outra
	oReport:ThinLine()
	//finalizo a primeira seção
	oSection1:Finish()
Enddo
TRB->(DbCloseArea())
Return
