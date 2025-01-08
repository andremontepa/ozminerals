#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWCOMMAND.CH"
#Include "TopConn.Ch"
#define DMPAPER_A4 9

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RCOR001    º Autor ³ Ismael junior      º Data ³  05/04/17  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatório Saldo da conta                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACOM  -- >  Relatórios/#Rel. saldo da conta             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function RCOR001()
Local oReport := nil
Local cPerg:= PadR("RCOR001", Len(SX1->X1_GRUPO))

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
oReport := TReport():New(cNome,"Relatório Saldo por Conta ",cNome,{|oReport| ReportPrint(oReport)},"Saldo por Conta ")
oReport:SetLandscape() //SetPortrait()
oReport:SetTotalInLine(.F.)

oSection1:= TRSection():New(oReport, "Centro de Custo e Item", {"TMP"}, , .F., .T.)
//ZW3_NUM,ZW3_TIPO,ZW3_DATA,ZW3_CCUSTO,CTT_DESC01,ZW3_ITEMCO,CTD_DESC01,ZW3_CONTA,CT1_DESC01,ZW3_ANO,ZW3_VALOR,ZW3_HISTOR
TRCell():new(oSection1, "CCUSTO"   ,"TMP","CENTRO DE CUSTO"	 ,,TAMSX3("ZW5_CCUSTO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection1, "NOMECCU"  ,"TMP","Descrição C. de Custo",,TAMSX3("CTT_DESC01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection1, "ITEMCO"   ,"TMP","ITEM CONTABIL" ,,TAMSX3("ZW2_ITEMCO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection1, "NOMEICO"  ,"TMP","Descrição I. Contabil",,TAMSX3("CTD_DESC01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection1, "ANO" 	   ,"TMP","ANO"  ,,TAMSX3("ZW3_ANO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)

oSection2:= TRSection():New(oReport, "Conta", {"TMP"}, NIL, .F., .T.)
TRCell():new(oSection2, "ITEMCON"   ,"TMP","ITEM CONTABIL" ,,TAMSX3("ZW2_ITEMCO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection2, "CONTA"	   ,"TMP","CONTA" ,,TAMSX3("ZW2_CONTA")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection2, "NOMECON"  ,"TMP","Descrição da Conta" ,,TAMSX3("CT1_DESC01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection2, "VLJAN"    ,"TMP","JANEIRO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection2, "VLFEV"    ,"TMP","FEVEREIRO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection2, "VLMAR"    ,"TMP","MARÇO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection2, "VLABR"    ,"TMP","ABRIL"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection2, "VLMAI"    ,"TMP","MAIO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection2, "VLJUN"    ,"TMP","JUNHO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection2, "VLJUL"    ,"TMP","JULHO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection2, "VLAGO"    ,"TMP","AGOSTO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection2, "VLSET"    ,"TMP","SETEMBRO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection2, "VLOUT"    ,"TMP","OUTUBRO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection2, "VLNOV"    ,"TMP","NOVEMBRO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection2, "VLDEZ"    ,"TMP","DEZEMBRO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection2, "VLTOT"    ,"TMP","TOTAL ANO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)

oBreak := TRBreak():New(oSection2,{||oSection2:Cell("ITEMCON"):UPRINT},"SUB-TOTAL",.F.)
TRFunction():New(oSection2:Cell("ITEMCON"),NIL,"COUNT",oBreak,,,,.F.,.T.)
TRFunction():New(oSection2:Cell("VLJAN"),NIL,"SUM",oBreak,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection2:Cell("VLFEV"),NIL,"SUM",oBreak,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection2:Cell("VLMAR"),NIL,"SUM",oBreak,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection2:Cell("VLABR"),NIL,"SUM",oBreak,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection2:Cell("VLMAI"),NIL,"SUM",oBreak,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection2:Cell("VLJUN"),NIL,"SUM",oBreak,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection2:Cell("VLJUL"),NIL,"SUM",oBreak,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection2:Cell("VLSET"),NIL,"SUM",oBreak,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection2:Cell("VLAGO"),NIL,"SUM",oBreak,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection2:Cell("VLOUT"),NIL,"SUM",oBreak,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection2:Cell("VLNOV"),NIL,"SUM",oBreak,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection2:Cell("VLDEZ"),NIL,"SUM",oBreak,"@E 999,999,999.99",,,.F.,.T.)
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

cQuery := "SELECT ZW4_COD,ZW5_CCUSTO,CTT_DESC01,ZW2_ITEMCO,CTD_DESC01,ZW2_CONTA,CTH_DESC01,ZW2_ANO, "
cQuery += "ZW2_VAL01,ZW2_VAL02,ZW2_VAL03,ZW2_VAL04,ZW2_VAL05,ZW2_VAL06,ZW2_VAL07,ZW2_VAL08,ZW2_VAL09,ZW2_VAL10,ZW2_VAL11,ZW2_VAL12,ZW2_VLANO, "
cQuery += "ZW2_REL01,ZW2_REL02,ZW2_REL03,ZW2_REL04,ZW2_REL05,ZW2_REL06,ZW2_REL07,ZW2_REL08,ZW2_REL09,ZW2_REL10,ZW2_REL11,ZW2_REL12,ZW2_RELANO "
cQuery += "FROM " +RetSqlName("ZW4")+" ZW4 "
cQuery += "INNER JOIN " +RetSqlName("ZW5")+" ZW5 ON ZW5_NUM = ZW4_NUM AND ZW5.D_E_L_E_T_ != '*' "
cQuery += "INNER JOIN " +RetSqlName("ZW2")+" ZW2 ON ZW2_CCUSTO = ZW5_CCUSTO AND ZW2.D_E_L_E_T_ != '*' "
cQuery += "INNER JOIN " +RetSqlName("CTT")+" CTT ON CTT_CUSTO = ZW2_CCUSTO AND CTT.D_E_L_E_T_ != '*' "
cQuery += "INNER JOIN " +RetSqlName("CTD")+" CTD ON CTD_ITEM = ZW2_ITEMCO AND CTD.D_E_L_E_T_ != '*' "
cQuery += "INNER JOIN " +RetSqlName("CTH")+" CTH ON CTH_CLVL = ZW2_CONTA AND CTH.D_E_L_E_T_ != '*' "
cQuery += "WHERE ZW4_FILIAL = '"+XFILIAL("ZW4")+"' "
cQuery += "AND ZW4_COD = '"+MV_PAR01+"' "
cQuery += "AND ZW5_CCUSTO BETWEEN '" + MV_PAR02 + "' AND '" + MV_PAR03 + "' "
cQuery += "AND ZW2_ITEMCO BETWEEN '" + MV_PAR04 + "' AND '" + MV_PAR05 + "' "
cQuery += "AND ZW2_CONTA BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR07 + "' "
cQuery += "AND ZW2_ANO BETWEEN '" + MV_PAR08 + "' AND '" + MV_PAR09 + "' "
cQuery += "AND ZW4.D_E_L_E_T_ != '*' "
cQuery += "ORDER BY ZW2_ANO,ZW5_CCUSTO,ZW2_ITEMCO,ZW2_CONTA "

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
	
	IncProc("Imprimindo Centro de Custo "+alltrim(TMP->ZW5_CCUSTO))
	oSection1:Cell("CCUSTO"):SetValue(TMP->ZW5_CCUSTO)
	oSection1:Cell("NOMECCU"):SetValue(TMP->CTT_DESC01)
	oSection1:Cell("ITEMCO"):SetValue(TMP->ZW2_ITEMCO)
	oSection1:Cell("NOMEICO"):SetValue(TMP->CTD_DESC01)
	oSection1:Cell("ANO"):SetValue(TMP->ZW2_ANO)
	//imprimo a primeira seção
	oSection1:Printline()
	
   //	oSection2:Printline()
	cItemco 	:= TMP->ZW2_ITEMCO
	//inicializo a segunda seção
	oSection2:init()
	While TMP->ZW2_ITEMCO = cItemco
		oReport:IncMeter()
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
		IncProc("Imprimindo Conta "+alltrim(TMP->ZW2_CONTA))
		
		oSection2:Cell("ITEMCON"):SetValue(TMP->ZW2_ITEMCO)
		oSection2:Cell("CONTA"):SetValue(TMP->ZW2_CONTA)
		oSection2:Cell("NOMECON"):SetValue(TMP->CT1_DESC01)
		oSection2:Cell("VLJAN"):SetValue(nVlJan)
		oSection2:Cell("VLFEV"):SetValue(nVlFev)
		oSection2:Cell("VLMAR"):SetValue(nVlMar)
		oSection2:Cell("VLABR"):SetValue(nVlApr)
		oSection2:Cell("VLMAI"):SetValue(nVlMai)
		oSection2:Cell("VLJUN"):SetValue(nVlJun)
		oSection2:Cell("VLJUL"):SetValue(nVlJul)
		oSection2:Cell("VLAGO"):SetValue(nVlAgo)
		oSection2:Cell("VLSET"):SetValue(nVlSet)
		oSection2:Cell("VLOUT"):SetValue(nVlOut)
		oSection2:Cell("VLNOV"):SetValue(nVlNov)
		oSection2:Cell("VLDEZ"):SetValue(nVlDez)
		oSection2:Cell("VLTOT"):SetValue(nVlTot)
		
		oSection2:Printline()
		cItemco 	:= TMP->ZW2_ITEMCO
		TMP->(dbSkip())
	EndDo
	//finalizo a segunda seção para que seja reiniciada para o proximo registro
	oSection2:Finish()
	//imprimo uma linha para separar uma NCM de outra
	oReport:ThinLine()
	//finalizo a primeira seção
	oSection1:Finish()
Enddo
TMP->(DbCloseArea())
Return
