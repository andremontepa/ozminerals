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
±±ºDescricao ³ Relatorio Extrato conta                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACOM  -- >  Relatórios/#Rel. Extrato conta              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function RCOR002()
Local oReport := nil
Local cPerg:= "RCOR992"

//gero a pergunta de modo oculto, ficando disponível no botão ações relacionadas
Pergunte(cPerg,.F.)

oReport := RptDef(cPerg)
oReport:PrintDialog()
Return

Static Function RptDef(cNome)
Local oReport := Nil
Local oSection1:= Nil
Local oSection2:= Nil  
Local oBreak 
Local oBreak1
Local oBreak2
//Local oFunction

/*Sintaxe: TReport():New(cNome,cTitulo,cPerguntas,bBlocoCodigo,cDescricao)*/
oReport := TReport():New(cNome,"Relatorio Extrato conta ",cNome,{|oReport| ReportPrint(oReport)},"Extrato conta ")
oReport:SetPortrait() //SetLandscape()
oReport:SetTotalInLine(.F.)

oSection1:= TRSection():New(oReport, "Centro de Custo", {"TRB"}, , .F., .T.)
//ZW3_NUM,ZW3_TIPO,ZW3_DATA,ZW3_CCUSTO,CTT_DESC01,ZW3_ITEMCO,CTD_DESC01,ZW3_CONTA,CT1_DESC01,ZW3_ANO,ZW3_VALOR,ZW3_HISTOR
TRCell():new(oSection1, "CCUSTO"   ,"TRB","CENTRO DE CUSTO"	 ,,TAMSX3("ZW3_CCUSTO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection1, "NOMECCU"  , ,"Descrição C. de Custo",,TAMSX3("CTT_DESC01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection1, "ITEMCO"   ,"TRB","ITEM CONTABIL" ,,TAMSX3("ZW3_ITEMCO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection1, "NOMEICO"  ,"TRB","Descrição I. Contabil",,TAMSX3("CTD_DESC01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection1, "CLVL"     ,"TRB","Classe de Valor",,TAMSX3("ZW3_CLVL")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection1, "ANO" 	   ,"TRB","ANO"  ,,TAMSX3("ZW3_ANO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)

oSection2:= TRSection():New(oReport, "Conta", {"TRB"}, NIL, .F., .T.)
TRCell():New(oSection2, "NUMERO"   ,"TRB","DOCUMENTO",,TAMSX3("ZW3_NUM")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection2, "TIPO"	   ,"TRB","TIPO"  ,,,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection2, "DATA"     ,"TRB","DT EMISSAO",,TAMSX3("ZW3_DATA")[1]+2,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection2, "CONTA"	   ,"TRB","CONTA" ,,TAMSX3("ZW3_CONTA")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
//TRCell():new(oSection2, "NOMECON"  ,"TRB","Descrição da Conta" ,,TAMSX3("CTH_DESC01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection2, "VALOR"    ,"TRB","VALOR DA TRASAÇÃO"  ,"@E 999,999,999.99",TAMSX3("ZW3_VALOR")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection2, "HISTOR"   ,"TRB","HISTORICO"  ,,TAMSX3("ZW3_HISTOR")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)


//TRCell():new(oSection2, "VALCOMTOT"   , ,"Vl Com. Total","@E 999,999.99",,/*lPixel*/,/*{|| code-block de impressao }*/)

//oBreak := TRBreak():New(oSection1,{||oSection1:Cell("CCUSTO"):UPRINT},"SUB-TOTAL",.F.)
//TRFunction():New(oSection1:Cell("CCUSTO"),NIL,"COUNT",oBreak,,,,.F.,.T.)

//oBreak1 := TRBreak():New(oSection2,{||oSection2:Cell("ITEMCO"):UPRINT},"SUB-TOTAL",.F.)
//TRFunction():New(oSection2:Cell("ITEMCO"),NIL,"COUNT",oBreak1,,,,.F.,.T.)

oBreak2 := TRBreak():New(oSection2,{||oSection2:Cell("CONTA"):UPRINT},"SUB-TOTAL",.F.)
TRFunction():New(oSection2:Cell("NUMERO"),NIL,"COUNT",oBreak2,,,,.F.,.T.)
TRFunction():New(oSection2:Cell("VALOR"),NIL,"SUM",oBreak2,"@E 999,999,999.99",,,.F.,.T.)
oReport:SetTotalInLine(.F.)

//Aqui, farei uma quebra  por seção
//	oSection1:SetPageBreak(.T.)
//	oSection1:SetTotalText(" teste teste")
Return(oReport)

Static Function ReportPrint(oReport)
Local oSection1  := oReport:Section(1)
Local oSection2  := oReport:Section(2)
//Local oSection2  := oReport:Section(3)
Local nValor     := 0
Local cCusto     := ""
Local cItemco    := ""
Local cConta     := ""
Local cQuery     := ""
//Monto minha consulta conforme parametros passado
cQuery := "SELECT "
cQuery += "ZW3_NUM,ZW3_TIPO,ZW3_DATA,ZW3_CCUSTO,CTT_DESC01,ZW3_ITEMCO,CTD_DESC01,ZW3_CONTA,ZW3_CLVL,CTH_DESC01,ZW3_ANO,ZW3_VALOR,ZW3_HISTOR "
cQuery += "FROM " +RetSqlName("ZW3")+" ZW3 "
cQuery += "INNER JOIN " +RetSqlName("CTT")+" CTT ON CTT_CUSTO = ZW3_CCUSTO AND CTT.D_E_L_E_T_ != '*' "
cQuery += "INNER JOIN " +RetSqlName("CTD")+" CTD ON CTD_ITEM = ZW3_ITEMCO AND CTD.D_E_L_E_T_ != '*' "
cQuery += "INNER JOIN " +RetSqlName("CTH")+" CTH ON CTH_CLVL = ZW3_CLVL AND CTH.D_E_L_E_T_ != '*' "
cQuery += " WHERE ZW3_CCUSTO = '" + MV_PAR01 + "' "
cQuery += " AND ZW3_ITEMCO = '" + MV_PAR02 + "' "
cQuery += " AND ZW3_CLVL = '" + MV_PAR03 + "' "  
cQuery += " AND ZW3_DATA BETWEEN '" + DTOS(MV_PAR04) + "' AND '" + DTOS(MV_PAR05) + "' " 
//cQuery += " AND ZW3_FILIAL = '"+xFilial("ZW3")+"' "
cQuery += "AND ZW3.D_E_L_E_T_ != '*' "
cQuery += "ORDER BY ZW3_ANO,ZW3_CCUSTO,ZW3_ITEMCO,ZW3_CONTA,ZW3_DATA "

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
	
	IncProc("Imprimindo Centro de Custo "+alltrim(TRB->ZW3_CCUSTO))
	oSection1:Cell("CCUSTO"):SetValue(TRB->ZW3_CCUSTO)
	oSection1:Cell("NOMECCU"):SetValue(TRB->CTT_DESC01)
	oSection1:Cell("ITEMCO"):SetValue(TRB->ZW3_ITEMCO)
	oSection1:Cell("NOMEICO"):SetValue(TRB->CTD_DESC01)	
	oSection1:Cell("CLVL"):SetValue(TRB->ZW3_CLVL)	
	oSection1:Cell("ANO"):SetValue(TRB->ZW3_ANO)
	
	//imprimo a primeira seção
	oSection1:Printline()		
	//While TRB->ZW3_ITEMCO = cItemco .AND. TRB->ZW3_CCUSTO = cCusto 

	   //	cCcusto := TRB->ZW3_CCUSTO
	   //	cItemco 	:= TRB->ZW3_ITEMCO
		//inicializo a segunda seção
		oSection2:init()
		While TRB->(!Eof())
			oReport:IncMeter()
			IncProc("Imprimindo Conta "+alltrim(TRB->ZW3_CONTA))
			nValor := TRB->ZW3_VALOR
			If TRB->ZW3_TIPO = 'D'			
			nValor := TRB->ZW3_VALOR * -1
			Endif
			oSection2:Cell("NUMERO"):SetValue(TRB->ZW3_NUM)
			oSection2:Cell("TIPO"):SetValue(TRB->ZW3_TIPO)
			oSection2:Cell("DATA"):SetValue(STOD(TRB->ZW3_DATA))
			oSection2:Cell("CONTA"):SetValue(TRB->ZW3_CONTA)
			//oSection2:Cell("NOMECON"):SetValue(TRB->CTH_DESC01)
			oSection2:Cell("VALOR"):SetValue(nValor)
			oSection2:Cell("HISTOR"):SetValue(TRB->ZW3_HISTOR)
			
			oSection2:Printline()
			TRB->(dbSkip())
		EndDo
   //	EndDo 
	//finalizo a segunda seção para que seja reiniciada para o proximo registro
	oSection2:Finish()
	//imprimo uma linha para separar uma NCM de outra
	oReport:ThinLine()
	//finalizo a primeira seção
	oSection1:Finish()
EndDo	
TRB->(DbCloseArea())
Return
