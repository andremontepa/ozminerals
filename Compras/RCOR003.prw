#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWCOMMAND.CH"
#Include "TopConn.Ch"
#define DMPAPER_A4 9

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RCOR003    º Autor ³ Ismael junior      º Data ³  05/04/17  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatório Orçado x realizado                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACOM  -- >  Relatórios/Rel. Orçado x realizado         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function RCOR003()
Local oReport := nil
Local cPerg:= PadR("RCOR003", Len(SX1->X1_GRUPO))

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
oReport := TReport():New(cNome,"Relatório Orçado x Realizado ",cNome,{|oReport| ReportPrint(oReport)},"Orçado x Realizado ")
oReport:SetLandscape() //SetPortrait()
oReport:SetTotalInLine(.F.)

oSection1:= TRSection():New(oReport, "Centro de Custo e Item", {"TMP"}, , .F., .T.)
//ZW3_NUM,ZW3_TIPO,ZW3_DATA,ZW3_CCUSTO,CTT_DESC01,ZW3_ITEMCO,CTD_DESC01,ZW3_CONTA,CT1_DESC01,ZW3_ANO,ZW3_VALOR,ZW3_HISTOR
TRCell():new(oSection1, "CCUSTO"   ,"TMP","CENTRO DE CUSTO"	 ,,TAMSX3("ZW5_CCUSTO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection1, "ITEMCO"   ,"TMP","ITEM CONTABIL" ,,TAMSX3("ZW2_ITEMCO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection1, "CONTA"    ,"TMP","CONTA" ,,TAMSX3("ZW2_CONTA")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection1, "ANO" 	   ,"TMP","ANO"  ,,TAMSX3("ZW3_ANO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)

TRCell():new(oSection1, "ORCJAN"    ,"TMP","Orc. JANEIRO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection1, "RELJAN"    ,"TMP","Rel. JANEIRO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection1, "VLJAN"     ,"TMP","Saldo JANEIRO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)

TRCell():new(oSection1, "ORCFEV"    ,"TMP","Orc. FEVEREIRO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection1, "RELFEV"    ,"TMP","Rel. FEVEREIRO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection1, "VLFEV"     ,"TMP","Saldo FEVEREIRO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)

TRCell():new(oSection1, "ORCMAR"    ,"TMP","Orc. MARÇO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection1, "RELMAR"    ,"TMP","Rel. MARÇO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection1, "VLMAR"     ,"TMP","Saldo MARÇO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)

TRCell():new(oSection1, "ORCABR"    ,"TMP","Orc. ABRIL"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection1, "RELABR"    ,"TMP","Rel. ABRIL"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection1, "VLABR"     ,"TMP","Saldo ABRIL"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)

TRCell():new(oSection1, "ORCMAI"    ,"TMP","Orc. MAIO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection1, "RELMAI"    ,"TMP","Rel. MAIO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection1, "VLMAI"     ,"TMP","Saldo MAIO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)

TRCell():new(oSection1, "ORCJUN"    ,"TMP","Orc. JUNHO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection1, "RELJUN"    ,"TMP","Rel. JUNHO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection1, "VLJUN"     ,"TMP","Saldo JUNHO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)

TRCell():new(oSection1, "ORCJUL"    ,"TMP","Orc. JULHO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection1, "RELJUL"    ,"TMP","Rel. JULHO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection1, "VLJUL"     ,"TMP","Saldo JULHO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)

TRCell():new(oSection1, "ORCAGO"    ,"TMP","Orc. AGOSTO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection1, "RELAGO"    ,"TMP","Rel. AGOSTO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection1, "VLAGO"     ,"TMP","Saldo AGOSTO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)

TRCell():new(oSection1, "ORCSET"    ,"TMP","Orc. SETEMBRO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection1, "RELSET"    ,"TMP","Rel. SETEMBRO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection1, "VLSET"     ,"TMP","Saldo SETEMBRO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)

TRCell():new(oSection1, "ORCOUT"    ,"TMP","Orc. OUTUBRO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection1, "RELOUT"    ,"TMP","Rel. OUTUBRO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection1, "VLOUT"     ,"TMP","Saldo OUTUBRO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)

TRCell():new(oSection1, "ORCNOV"    ,"TMP","Orc. NOVEMBRO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection1, "RELNOV"    ,"TMP","Rel. NOVEMBRO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection1, "VLNOV"     ,"TMP","Saldo NOVEMBRO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)

TRCell():new(oSection1, "ORCDEZ"    ,"TMP","Orc. DEZEMBRO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection1, "RELDEZ"    ,"TMP","Rel. DEZEMBRO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection1, "VLDEZ"     ,"TMP","Saldo DEZEMBRO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)

TRCell():new(oSection1, "ORCTOT"    ,"TMP","Orc. TOTAL ANO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection1, "RELTOT"    ,"TMP","Rel. Total ANO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection1, "VLTOT"     ,"TMP","Saldo TOTAL ANO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)

//oBreak := TRBreak():New(oSection1,{||oSection1:Cell("ITEMCON"):UPRINT},"SUB-TOTAL",.F.)
//TRFunction():New(oSection1:Cell("ITEMCON"),NIL,"COUNT",oBreak,,,,.F.,.T.)
TRFunction():New(oSection1:Cell("ORCJAN"),NIL,"SUM",,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection1:Cell("ORCFEV"),NIL,"SUM",,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection1:Cell("ORCMAR"),NIL,"SUM",,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection1:Cell("ORCABR"),NIL,"SUM",,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection1:Cell("ORCMAI"),NIL,"SUM",,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection1:Cell("ORCJUN"),NIL,"SUM",,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection1:Cell("ORCJUL"),NIL,"SUM",,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection1:Cell("ORCSET"),NIL,"SUM",,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection1:Cell("ORCAGO"),NIL,"SUM",,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection1:Cell("ORCOUT"),NIL,"SUM",,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection1:Cell("ORCNOV"),NIL,"SUM",,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection1:Cell("ORCDEZ"),NIL,"SUM",,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection1:Cell("ORCTOT"),NIL,"SUM",,"@E 999,999,999.99",,,.F.,.T.)

TRFunction():New(oSection1:Cell("RELJAN"),NIL,"SUM",,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection1:Cell("RELFEV"),NIL,"SUM",,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection1:Cell("RELMAR"),NIL,"SUM",,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection1:Cell("RELABR"),NIL,"SUM",,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection1:Cell("RELMAI"),NIL,"SUM",,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection1:Cell("RELJUN"),NIL,"SUM",,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection1:Cell("RELJUL"),NIL,"SUM",,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection1:Cell("RELSET"),NIL,"SUM",,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection1:Cell("RELAGO"),NIL,"SUM",,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection1:Cell("RELOUT"),NIL,"SUM",,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection1:Cell("RELNOV"),NIL,"SUM",,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection1:Cell("RELDEZ"),NIL,"SUM",,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection1:Cell("RELTOT"),NIL,"SUM",,"@E 999,999,999.99",,,.F.,.T.)

TRFunction():New(oSection1:Cell("VLJAN"),NIL,"SUM",,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection1:Cell("VLFEV"),NIL,"SUM",,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection1:Cell("VLMAR"),NIL,"SUM",,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection1:Cell("VLABR"),NIL,"SUM",,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection1:Cell("VLMAI"),NIL,"SUM",,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection1:Cell("VLJUN"),NIL,"SUM",,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection1:Cell("VLJUL"),NIL,"SUM",,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection1:Cell("VLSET"),NIL,"SUM",,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection1:Cell("VLAGO"),NIL,"SUM",,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection1:Cell("VLOUT"),NIL,"SUM",,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection1:Cell("VLNOV"),NIL,"SUM",,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection1:Cell("VLDEZ"),NIL,"SUM",,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection1:Cell("VLTOT"),NIL,"SUM",,"@E 999,999,999.99",,,.F.,.T.)
oReport:SetTotalInLine(.F.)

//Aqui, farei uma quebra  por seção
//	oSection1:SetPageBreak(.T.)
//	oSection1:SetTotalText(" teste teste")
Return(oReport)

Static Function ReportPrint(oReport)
Local oSection1  := oReport:Section(1)
Local nValor     := 0
Local cCusto     := ""
Local cItemco    := ""
Local cConta     := ""
Local cQuery     := ""
//Monto minha consulta conforme parametros passado

cQuery := "SELECT ZW2_CCUSTO,ZW2_ITEMCO,ZW2_CONTA,ZW2_ANO, "
cQuery += "ZW2_VAL01,ZW2_VAL02,ZW2_VAL03,ZW2_VAL04,ZW2_VAL05,ZW2_VAL06,ZW2_VAL07,ZW2_VAL08,ZW2_VAL09,ZW2_VAL10,ZW2_VAL11,ZW2_VAL12,ZW2_VLANO, "
cQuery += "ZW2_REL01,ZW2_REL02,ZW2_REL03,ZW2_REL04,ZW2_REL05,ZW2_REL06,ZW2_REL07,ZW2_REL08,ZW2_REL09,ZW2_REL10,ZW2_REL11,ZW2_REL12,ZW2_RELANO "
cQuery += "FROM " +RetSqlName("ZW2")+" ZW2 "
cQuery += "WHERE ZW2_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
cQuery += "AND ZW2_CCUSTO BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
cQuery += "AND ZW2_ITEMCO BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "
cQuery += "AND ZW2_CONTA BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' "
cQuery += "AND ZW2_ANO BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "' "
cQuery += "AND ZW2.D_E_L_E_T_ != '*' "
cQuery += "ORDER BY ZW2_FILIAL,ZW2_ANO,ZW2_CCUSTO,ZW2_ITEMCO,ZW2_CONTA "

//Se o alias estiver aberto, irei fechar, isso ajuda a evitar erros
IF Select("TMP") <> 0
	TMP->(DbCloseArea())
ENDIF

//Tratando a query para o AdvPL

//crio o novo alias
TCQUERY cQuery NEW ALIAS "TMP"

dbSelectArea("TMP")
TMP->(dbGoTop())

oReport:SetMeter(TMP->(LastRec()))

//Irei percorrer todos os meus registros
While TMP->(!Eof())
	If oReport:Cancel()
		Exit
	EndIf
	dbSelectArea("TMP")
	//inicializo a primeira seção
	oSection1:Init()
	
	oReport:IncMeter()
	
	IncProc("Imprimindo Centro de Custo "+alltrim(TMP->ZW2_CCUSTO))
	oSection1:Cell("CCUSTO"):SetValue(TMP->ZW2_CCUSTO)
	oSection1:Cell("ITEMCO"):SetValue(TMP->ZW2_ITEMCO)		
	oSection1:Cell("CONTA"):SetValue(TMP->ZW2_CONTA)
	oSection1:Cell("ANO"):SetValue(TMP->ZW2_ANO)
		
		nVlJan := TMP->ZW2_VAL01 - TMP->ZW2_REL01
		nVlFev := TMP->ZW2_VAL02 - TMP->ZW2_REL02
		nVlMar := TMP->ZW2_VAL03 - TMP->ZW2_REL03
		nVlApr := TMP->ZW2_VAL04 - TMP->ZW2_REL04
		nVlMai := TMP->ZW2_VAL05 - TMP->ZW2_REL05
		nVlJun := TMP->ZW2_VAL06 - TMP->ZW2_REL06
		nVlJul := TMP->ZW2_VAL07 - TMP->ZW2_REL07
		nVlAgo := TMP->ZW2_VAL08 - TMP->ZW2_REL08
		nVlSet := TMP->ZW2_VAL09 - TMP->ZW2_REL09
		nVlOut := TMP->ZW2_VAL10 - TMP->ZW2_REL10
		nVlNov := TMP->ZW2_VAL11 - TMP->ZW2_REL11
		nVlDez := TMP->ZW2_VAL12 - TMP->ZW2_REL12
		nVlTot := TMP->ZW2_VLANO - TMP->ZW2_RELANO

		oSection1:Cell("ORCJAN"):SetValue(TMP->ZW2_VAL01)
		oSection1:Cell("ORCFEV"):SetValue(TMP->ZW2_VAL02)
		oSection1:Cell("ORCMAR"):SetValue(TMP->ZW2_VAL03)
		oSection1:Cell("ORCABR"):SetValue(TMP->ZW2_VAL04)
		oSection1:Cell("ORCMAI"):SetValue(TMP->ZW2_VAL05)
		oSection1:Cell("ORCJUN"):SetValue(TMP->ZW2_VAL06)
		oSection1:Cell("ORCJUL"):SetValue(TMP->ZW2_VAL07)
		oSection1:Cell("ORCAGO"):SetValue(TMP->ZW2_VAL08)
		oSection1:Cell("ORCSET"):SetValue(TMP->ZW2_VAL09)
		oSection1:Cell("ORCOUT"):SetValue(TMP->ZW2_VAL10)
		oSection1:Cell("ORCNOV"):SetValue(TMP->ZW2_VAL11)
		oSection1:Cell("ORCDEZ"):SetValue(TMP->ZW2_VAL12)
		oSection1:Cell("ORCTOT"):SetValue(TMP->ZW2_VLANO)
		
		oSection1:Cell("RELJAN"):SetValue(TMP->ZW2_REL01)
		oSection1:Cell("RELFEV"):SetValue(TMP->ZW2_REL02)
		oSection1:Cell("RELMAR"):SetValue(TMP->ZW2_REL03)
		oSection1:Cell("RELABR"):SetValue(TMP->ZW2_REL04)
		oSection1:Cell("RELMAI"):SetValue(TMP->ZW2_REL05)
		oSection1:Cell("RELJUN"):SetValue(TMP->ZW2_REL06)
		oSection1:Cell("RELJUL"):SetValue(TMP->ZW2_REL07)
		oSection1:Cell("RELAGO"):SetValue(TMP->ZW2_REL08)
		oSection1:Cell("RELSET"):SetValue(TMP->ZW2_REL09)
		oSection1:Cell("RELOUT"):SetValue(TMP->ZW2_REL10)
		oSection1:Cell("RELNOV"):SetValue(TMP->ZW2_REL11)
		oSection1:Cell("RELDEZ"):SetValue(TMP->ZW2_REL12)
		oSection1:Cell("RELTOT"):SetValue(TMP->ZW2_RELANO)				

		oSection1:Cell("VLJAN"):SetValue(nVlJan)
		oSection1:Cell("VLFEV"):SetValue(nVlFev)
		oSection1:Cell("VLMAR"):SetValue(nVlMar)
		oSection1:Cell("VLABR"):SetValue(nVlApr)
		oSection1:Cell("VLMAI"):SetValue(nVlMai)
		oSection1:Cell("VLJUN"):SetValue(nVlJun)
		oSection1:Cell("VLJUL"):SetValue(nVlJul)
		oSection1:Cell("VLAGO"):SetValue(nVlAgo)
		oSection1:Cell("VLSET"):SetValue(nVlSet)
		oSection1:Cell("VLOUT"):SetValue(nVlOut)
		oSection1:Cell("VLNOV"):SetValue(nVlNov)
		oSection1:Cell("VLDEZ"):SetValue(nVlDez)
		oSection1:Cell("VLTOT"):SetValue(nVlTot)
		
		oSection1:Printline()
		//cItemco 	:= TMP->ZW2_ITEMCO
		TMP->(dbSkip())
	EndDo

	//imprimo uma linha para separar uma NCM de outra
   //	oReport:ThinLine()
	//finalizo a primeira seção
	oSection1:Finish()
TMP->(DbCloseArea())
Return
