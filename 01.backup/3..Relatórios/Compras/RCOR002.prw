#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWCOMMAND.CH"
#Include "TopConn.Ch"
#define DMPAPER_A4 9

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RCOR002    º Autor ³ Ismael junior      º Data ³  05/04/17  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatório de comissão por faturamento                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACOM  -- >  Relatórios/#Rel. Extrato conta              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function RCOR002()
Local oReport := nil
Local cPerg:= PadR("RCOR002", Len(SX1->X1_GRUPO))

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
Local oBreak 
Local oBreak1
Local oBreak2
//Local oFunction

/*Sintaxe: TReport():New(cNome,cTitulo,cPerguntas,bBlocoCodigo,cDescricao)*/
oReport := TReport():New(cNome,"Relatorio Extrato conta ",cNome,{|oReport| ReportPrint(oReport)},"Extrato conta ")
oReport:SetPortrait() //SetLandscape()
oReport:SetTotalInLine(.F.)

oSection1:= TRSection():New(oReport, "Centro de Custo", {"TMP"}, , .F., .T.)
//ZW3_NUM,ZW3_TIPO,ZW3_DATA,ZW3_CCUSTO,CTT_DESC01,ZW3_ITEMCO,CTD_DESC01,ZW3_CONTA,CT1_DESC01,ZW3_ANO,ZW3_VALOR,ZW3_HISTOR
TRCell():new(oSection1, "CCUSTO"   ,"TMP","CENTRO DE CUSTO"	 ,,TAMSX3("ZW3_CCUSTO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection1, "NOMECCU"  , ,"Descrição C. de Custo",,TAMSX3("CTT_DESC01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection1, "ANO" 	   ,"TMP","ANO"  ,,TAMSX3("ZW3_ANO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)

oSection2:= TRSection():New(oReport, "Item Contabil", {"TMP"}, NIL, .F., .T.)
TRCell():new(oSection2, "ITEMCO"   ,"TMP","ITEM CONTABIL" ,,TAMSX3("ZW3_ITEMCO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection2, "NOMEICO"  ,"TMP","Descrição I. Contabil",,TAMSX3("CTD_DESC01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)

oSection3:= TRSection():New(oReport, "Conta", {"TMP"}, NIL, .F., .T.)
TRCell():New(oSection3, "NUMERO"   ,"TMP","DOCUMENTO",,TAMSX3("ZW3_NUM")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection3, "TIPO"	   ,"TMP","TIPO"  ,,,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection3, "DATA"     ,"TMP","DT EMISSAO",,TAMSX3("ZW3_DATA")[1]+2,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection3, "CONTA"	   ,"TMP","CONTA" ,,TAMSX3("ZW3_CONTA")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection3, "NOMECON"  ,"TMP","Descrição da Conta" ,,TAMSX3("CTH_DESC01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection3, "VALOR"    ,"TMP","VALOR DA TRASAÇÃO"  ,"@E 999,999,999.99",TAMSX3("ZW3_VALOR")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection3, "HISTOR"   ,"TMP","HISTORICO"  ,,TAMSX3("ZW3_HISTOR")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)


//TRCell():new(oSection2, "VALCOMTOT"   , ,"Vl Com. Total","@E 999,999.99",,/*lPixel*/,/*{|| code-block de impressao }*/)

//oBreak := TRBreak():New(oSection1,{||oSection1:Cell("CCUSTO"):UPRINT},"SUB-TOTAL",.F.)
//TRFunction():New(oSection1:Cell("CCUSTO"),NIL,"COUNT",oBreak,,,,.F.,.T.)

//oBreak1 := TRBreak():New(oSection2,{||oSection2:Cell("ITEMCO"):UPRINT},"SUB-TOTAL",.F.)
//TRFunction():New(oSection2:Cell("ITEMCO"),NIL,"COUNT",oBreak1,,,,.F.,.T.)

oBreak2 := TRBreak():New(oSection3,{||oSection3:Cell("CONTA"):UPRINT},"SUB-TOTAL",.F.)
TRFunction():New(oSection3:Cell("NUMERO"),NIL,"COUNT",oBreak2,,,,.F.,.T.)
TRFunction():New(oSection3:Cell("VALOR"),NIL,"SUM",oBreak2,"@E 999,999,999.99",,,.F.,.T.)
oReport:SetTotalInLine(.F.)

//Aqui, farei uma quebra  por seção
//	oSection1:SetPageBreak(.T.)
//	oSection1:SetTotalText(" teste teste")
Return(oReport)

Static Function ReportPrint(oReport)
Local oSection1  := oReport:Section(1)
Local oSection2  := oReport:Section(2)
Local oSection3  := oReport:Section(3)
Local nValor     := 0
Local cCusto     := ""
Local cItemco    := ""
Local cConta     := ""
Local cQuery     := ""
//Monto minha consulta conforme parametros passado
cQuery := "SELECT "
cQuery += "ZW3_NUM,ZW3_TIPO,ZW3_DATA,ZW3_CCUSTO,CTT_DESC01,ZW3_ITEMCO,CTD_DESC01,ZW3_CONTA,CTH_DESC01,ZW3_ANO,ZW3_VALOR,ZW3_HISTOR "
cQuery += "FROM " +RetSqlName("ZW3")+" ZW3 "
cQuery += "INNER JOIN " +RetSqlName("CTT")+" CTT ON CTT_CUSTO = ZW3_CCUSTO AND CTT.D_E_L_E_T_ != '*' "
cQuery += "INNER JOIN " +RetSqlName("CTD")+" CTD ON CTD_ITEM = ZW3_ITEMCO AND CTD.D_E_L_E_T_ != '*' "
cQuery += "INNER JOIN " +RetSqlName("CTH")+" CTH ON CTH_CLVL = ZW3_CONTA AND CTH.D_E_L_E_T_ != '*' "
cQuery += " WHERE ZW3_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' " 
cQuery += " AND ZW3_CCUSTO BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
cQuery += " AND ZW3_ITEMCO BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "
cQuery += " AND ZW3_CONTA BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' "  
cQuery += " AND ZW3_ANO BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "' "
cQuery += " AND ZW3_DATA BETWEEN '" + DTOS(MV_PAR11) + "' AND '" + DTOS(MV_PAR12) + "' " 
cQuery += "AND ZW3.D_E_L_E_T_ != '*' "
cQuery += "ORDER BY ZW3_ANO,ZW3_CCUSTO,ZW3_ITEMCO,ZW3_CONTA,ZW3_DATA "

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
	
	IncProc("Imprimindo Centro de Custo "+alltrim(TMP->ZW3_CCUSTO))
	oSection1:Cell("CCUSTO"):SetValue(TMP->ZW3_CCUSTO)
	oSection1:Cell("NOMECCU"):SetValue(TMP->CTT_DESC01)
	oSection1:Cell("ANO"):SetValue(TMP->ZW3_ANO)
	
	//imprimo a primeira seção
	oSection1:Printline()
	
	//inicializo a segunda seção
	oSection2:init()
	cCcusto := TMP->ZW3_CCUSTO
	cItemco := TMP->ZW3_ITEMCO
	While TMP->ZW3_ITEMCO = cItemco .AND. TMP->ZW3_CCUSTO = cCcusto 
		oReport:IncMeter()
		IncProc("Imprimindo Item contabil "+alltrim(TMP->ZW3_ITEMCO))
		oSection2:Cell("ITEMCO"):SetValue(TMP->ZW3_ITEMCO)
		oSection2:Cell("NOMEICO"):SetValue(TMP->CTD_DESC01)
		
		oSection2:Printline()
		cCcusto := TMP->ZW3_CCUSTO
		cItemco 	:= TMP->ZW3_ITEMCO
		//inicializo a segunda seção
		oSection3:init()
		cConta := TMP->ZW3_CONTA
		While TMP->ZW3_CONTA = cConta
			oReport:IncMeter()
			IncProc("Imprimindo Conta "+alltrim(TMP->ZW3_CONTA))
nValor := TMP->ZW3_VALOR
If TMP->ZW3_TIPO = 'D'			
nValor := TMP->ZW3_VALOR * -1
Endif
			oSection3:Cell("NUMERO"):SetValue(TMP->ZW3_NUM)
			oSection3:Cell("TIPO"):SetValue(TMP->ZW3_TIPO)
			oSection3:Cell("DATA"):SetValue(STOD(TMP->ZW3_DATA))
			oSection3:Cell("CONTA"):SetValue(TMP->ZW3_CONTA)
			oSection3:Cell("NOMECON"):SetValue(TMP->CTH_DESC01)
			oSection3:Cell("VALOR"):SetValue(nValor)
			oSection3:Cell("HISTOR"):SetValue(TMP->ZW3_HISTOR)
			
			oSection3:Printline()
			cConta 	:= TMP->ZW3_CONTA
			TMP->(dbSkip())
		EndDo
	EndDo 
	oSection3:Finish()	
	//finalizo a segunda seção para que seja reiniciada para o proximo registro
	oSection2:Finish()
	//imprimo uma linha para separar uma NCM de outra
	oReport:ThinLine()
	//finalizo a primeira seção
	oSection1:Finish()
Enddo
TMP->(DbCloseArea())
Return
