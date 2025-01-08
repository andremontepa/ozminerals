#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWCOMMAND.CH"
#Include "TopConn.Ch"
#define DMPAPER_A4 9

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RCOR007    º Autor ³ Ismael junior      º Data ³  02/07/19  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatório Orçado x Comprometido                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACOM  -- >  Relatórios/Rel. Orçado x Comprometido       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function RCOR007()
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
Local oSection3:= Nil
Local oBreak := Nil
//Local oFunction

/*Sintaxe: TReport():New(cNome,cTitulo,cPerguntas,bBlocoCodigo,cDescricao)*/
oReport := TReport():New("RCOR007","Relatório Orçado x Comprometido ",cNome,{|oReport| ReportPrint(oReport)},"Orçado x Comprometido ")
oReport:SetLandscape() //SetPortrait()
oReport:SetTotalInLine(.F.)

oSection1:= TRSection():New(oReport, "Centro de Custo e Item", {"TRB"}, , .F., .T.)
//ZW3_NUM,ZW3_TIPO,ZW3_DATA,ZW3_CCUSTO,CTT_DESC01,ZW3_ITEMCO,CTD_DESC01,ZW3_CONTA,CT1_DESC01,ZW3_ANO,ZW3_VALOR,ZW3_HISTOR
TRCell():new(oSection1, "CCUSTO"   ,"TRB","CENTRO DE CUSTO"	 ,,TAMSX3("ZW5_CCUSTO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection1, "ITEMCO"   ,"TRB","ITEM CONTABIL" ,,TAMSX3("ZW2_ITEMCO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection1, "CLVL"    ,"TRB","CLASSE DE VALOR" ,,TAMSX3("ZW2_CLVL")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection1, "ANO" 	   ,"TRB","ANO"  ,,TAMSX3("ZW3_ANO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)

oSection2:= TRSection():New(oReport, , {"TRB"}, NIL, .F., .T.) //REALIZADO
TRCell():new(oSection2, "TIPO"      ,"TRB","TIPO         ."  ,,9,/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT")
TRCell():new(oSection2, "ORCJAN"    ,"TRB","...... JANEIRO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT")
TRCell():new(oSection2, "ORCFEV"    ,"TRB","...... FEVEREIRO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT")
TRCell():new(oSection2, "ORCMAR"    ,"TRB","........ MARÇO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT")
TRCell():new(oSection2, "ORCABR"    ,"TRB","........ ABRIL"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT")
TRCell():new(oSection2, "ORCMAI"    ,"TRB","......... MAIO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT")
TRCell():new(oSection2, "ORCJUN"    ,"TRB","....... JUNHO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT")
TRCell():new(oSection2, "ORCJUL"    ,"TRB","....... JULHO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT")
TRCell():new(oSection2, "ORCAGO"    ,"TRB","....... AGOSTO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT")
TRCell():new(oSection2, "ORCSET"    ,"TRB","...... SETEMBRO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT")
TRCell():new(oSection2, "ORCOUT"    ,"TRB","...... OUTUBRO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT")
TRCell():new(oSection2, "ORCNOV"    ,"TRB","...... NOVEMBRO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT")
TRCell():new(oSection2, "ORCDEZ"    ,"TRB","...... DEZEMBRO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT")
TRCell():new(oSection2, "ORCTOT"    ,"TRB",".... TOTAL ANO"  ,"@E 999,999,999.99",TAMSX3("ZW2_VAL01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT")

oBreak := TRBreak():New(oSection1,{||oSection1:Cell("ITEMCO"):UPRINT},"SUB-TOTAL",.F.)
//TRFunction():New(oSection1:Cell("ITEMCO"),NIL,"COUNT",oBreak,,,,.F.,.T.)  
TRFunction():New(oSection2:Cell("ORCJAN"),NIL,"SUM",oBreak,"@E 999,999,999.99",,,.F.,.T.) 
TRFunction():New(oSection2:Cell("ORCFEV"),NIL,"SUM",oBreak,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection2:Cell("ORCMAR"),NIL,"SUM",oBreak,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection2:Cell("ORCABR"),NIL,"SUM",oBreak,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection2:Cell("ORCMAI"),NIL,"SUM",oBreak,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection2:Cell("ORCJUN"),NIL,"SUM",oBreak,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection2:Cell("ORCJUL"),NIL,"SUM",oBreak,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection2:Cell("ORCAGO"),NIL,"SUM",oBreak,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection2:Cell("ORCSET"),NIL,"SUM",oBreak,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection2:Cell("ORCOUT"),NIL,"SUM",oBreak,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection2:Cell("ORCNOV"),NIL,"SUM",oBreak,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection2:Cell("ORCDEZ"),NIL,"SUM",oBreak,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection2:Cell("ORCTOT"),NIL,"SUM",oBreak,"@E 999,999,999.99",,,.F.,.T.)

oReport:SetTotalInLine(.F.)

//Aqui, farei uma quebra  por seção
//	oSection1:SetPageBreak(.T.)
//	oSection1:SetTotalText(" teste teste")
Return(oReport)

Static Function ReportPrint(oReport)
Local oSection1  := oReport:Section(1)
Local oSection2  := oReport:Section(2)
//Local oSection3  := oReport:Section(3)
Local nRel01 := nRel02 := nRel03 := nRel04 := nRel05 := nRel06 := nRel07 := nRel08 := nRel09 := nRel10 := nRel11 := nRel12 := nReltot := 0
Local nPre01 := nPre02 := nPre03 := nPre04 := nPre05 := nPre06 := nPre07 := nPre08 := nPre09 := nPre10 := nPre11 := nPre12 := nPretot := 0
Local nValor     := 0
Local cCusto     := ""
Local cItemco    := ""
Local cConta     := ""
Local cQuery     := ""
//Monto minha consulta conforme parametros passado

cQuery := "SELECT ZW2_CCUSTO,ZW2_ITEMCO,ZW2_CLVL,ZW2_CONTA,ZW2_ANO, "
cQuery += "ZW2_PRE01,ZW2_PRE02,ZW2_PRE03,ZW2_PRE04,ZW2_PRE05,ZW2_PRE06,ZW2_PRE07,ZW2_PRE08,ZW2_PRE09,ZW2_PRE10,ZW2_PRE11,ZW2_PRE12,ZW2_PREANO, "
cQuery += "ZW2_VAL01,ZW2_VAL02,ZW2_VAL03,ZW2_VAL04,ZW2_VAL05,ZW2_VAL06,ZW2_VAL07,ZW2_VAL08,ZW2_VAL09,ZW2_VAL10,ZW2_VAL11,ZW2_VAL12,ZW2_VLANO, "
cQuery += "ZW2_REL01,ZW2_REL02,ZW2_REL03,ZW2_REL04,ZW2_REL05,ZW2_REL06,ZW2_REL07,ZW2_REL08,ZW2_REL09,ZW2_REL10,ZW2_REL11,ZW2_REL12,ZW2_RELANO "
cQuery += "FROM " +RetSqlName("ZW2")+" ZW2 "
cQuery += "WHERE ZW2_CCUSTO BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
cQuery += "AND ZW2_ITEMCO BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
cQuery += "AND ZW2_CLVL = '" + MV_PAR05 + "' "
cQuery += "AND ZW2_ANO = '" + MV_PAR06 + "' "
cQuery += "AND ZW2.D_E_L_E_T_ != '*' "
cQuery += "ORDER BY ZW2_FILIAL,ZW2_ANO,ZW2_CCUSTO,ZW2_ITEMCO,ZW2_CONTA "

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
cCusto := cItemct := cConta := ""
//Irei percorrer todos os meus registros
While TRB->(!Eof())
	If oReport:Cancel()
		Exit
	EndIf
	dbSelectArea("TRB")
	//inicializo a primeira seção
	oSection1:Init()
	
	oReport:IncMeter()
	
	IncProc("Imprimindo Centro de Custo "+alltrim(TRB->ZW2_CCUSTO))
	oSection1:Cell("CCUSTO"):SetValue(TRB->ZW2_CCUSTO)
	oSection1:Cell("ITEMCO"):SetValue(TRB->ZW2_ITEMCO)		
	oSection1:Cell("CLVL"):SetValue(TRB->ZW2_CLVL)
	oSection1:Cell("ANO"):SetValue(TRB->ZW2_ANO)
	oSection1:Printline()
		cCusto := TRB->ZW2_CCUSTO
		cItemct:= TRB->ZW2_ITEMCO
		cConta := TRB->ZW2_CLVL		

	//Irei percorrer todos os meus registros
	While cCusto + cItemct + cConta = TRB->ZW2_CCUSTO + TRB->ZW2_ITEMCO + TRB->ZW2_CLVL 
		nPre01 := nPre01 + TRB->ZW2_PRE01
		nPre02 := nPre02 + TRB->ZW2_PRE02
		nPre03 := nPre03 + TRB->ZW2_PRE03
		nPre04 := nPre04 + TRB->ZW2_PRE04
		nPre05 := nPre05 + TRB->ZW2_PRE05
		nPre06 := nPre06 + TRB->ZW2_PRE06
		nPre07 := nPre07 + TRB->ZW2_PRE07
		nPre08 := nPre08 + TRB->ZW2_PRE08
		nPre09 := nPre09 + TRB->ZW2_PRE09
		nPre10 := nPre10 + TRB->ZW2_PRE10
		nPre11 := nPre11 + TRB->ZW2_PRE11
		nPre12 := nPre12 + TRB->ZW2_PRE12
		nPretot := nPretot + TRB->ZW2_PREANO
		
		nRel01 := nRel01 + TRB->ZW2_VAL01 - TRB->ZW2_REL01
		nRel02 := nRel02 + TRB->ZW2_VAL02 - TRB->ZW2_REL02
		nRel03 := nRel03 + TRB->ZW2_VAL03 - TRB->ZW2_REL03
		nRel04 := nRel04 + TRB->ZW2_VAL04 - TRB->ZW2_REL04
		nRel05 := nRel05 + TRB->ZW2_VAL05 - TRB->ZW2_REL05
		nRel06 := nRel06 + TRB->ZW2_VAL06 - TRB->ZW2_REL06
		nRel07 := nRel07 + TRB->ZW2_VAL07 - TRB->ZW2_REL07
		nRel08 := nRel08 + TRB->ZW2_VAL08 - TRB->ZW2_REL08
		nRel09 := nRel09 + TRB->ZW2_VAL09 - TRB->ZW2_REL09
		nRel10 := nRel10 + TRB->ZW2_VAL10 - TRB->ZW2_REL10
		nRel11 := nRel11 + TRB->ZW2_VAL11 - TRB->ZW2_REL11
		nRel12 := nRel12 + TRB->ZW2_VAL12 - TRB->ZW2_REL12 		
		nReltot := nReltot + TRB->ZW2_VLANO	- TRB->ZW2_RELANO		

		TRB->(dbSkip())
		If cCusto + cItemct + cConta <> TRB->ZW2_CCUSTO + TRB->ZW2_ITEMCO + TRB->ZW2_CLVL	
		oSection2:Init()
		oReport:IncMeter()
		oSection2:Cell("TIPO"):SetValue("ORÇADO")
		oSection2:Cell("ORCJAN"):SetValue(nPre01)
		oSection2:Cell("ORCFEV"):SetValue(nPre02)
		oSection2:Cell("ORCMAR"):SetValue(nPre03)
		oSection2:Cell("ORCABR"):SetValue(nPre04)
		oSection2:Cell("ORCMAI"):SetValue(nPre05)
		oSection2:Cell("ORCJUN"):SetValue(nPre06)
		oSection2:Cell("ORCJUL"):SetValue(nPre07)
		oSection2:Cell("ORCAGO"):SetValue(nPre08)
		oSection2:Cell("ORCSET"):SetValue(nPre09)
		oSection2:Cell("ORCOUT"):SetValue(nPre10)
		oSection2:Cell("ORCNOV"):SetValue(nPre11)
		oSection2:Cell("ORCDEZ"):SetValue(nPre12)
		oSection2:Cell("ORCTOT"):SetValue(nPretot)
		oSection2:Printline()
		
		//oSection2:Cell("TIPO"):SetValue("REALIZADO")
		oSection2:Cell("TIPO"):SetValue("COMPROMET")
		oSection2:Cell("ORCJAN"):SetValue(nRel01 * -1)
		oSection2:Cell("ORCFEV"):SetValue(nRel02 * -1)
		oSection2:Cell("ORCMAR"):SetValue(nRel03 * -1)
		oSection2:Cell("ORCABR"):SetValue(nRel04 * -1)
		oSection2:Cell("ORCMAI"):SetValue(nRel05 * -1)
		oSection2:Cell("ORCJUN"):SetValue(nRel06 * -1)
		oSection2:Cell("ORCJUL"):SetValue(nRel07 * -1)
		oSection2:Cell("ORCAGO"):SetValue(nRel08 * -1)
		oSection2:Cell("ORCSET"):SetValue(nRel09 * -1)
		oSection2:Cell("ORCOUT"):SetValue(nRel10 * -1)
		oSection2:Cell("ORCNOV"):SetValue(nRel11 * -1)
		oSection2:Cell("ORCDEZ"):SetValue(nRel12 * -1)
		oSection2:Cell("ORCTOT"):SetValue(nReltot * -1)				
		oSection2:Printline()
		nRel01 := nRel02 := nRel03 := nRel04 := nRel05 := nRel06 := nRel07 := nRel08 := nRel09 := nRel10 := nRel11 := nRel12 := nReltot := 0
		nPre01 := nPre02 := nPre03 := nPre04 := nPre05 := nPre06 := nPre07 := nPre08 := nPre09 := nPre10 := nPre11 := nPre12 := nPretot := 0
		Endif		
	EndDo 
	//oSection3:Finish()	
	oSection2:Finish()
   //	oReport:ThinLine()
	oSection1:Finish()
EndDo	
TRB->(DbCloseArea())
Return