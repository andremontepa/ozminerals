#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWCOMMAND.CH"
#Include "TopConn.Ch"
#define DMPAPER_A4 9

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RCOR003    � Autor � Ismael junior      � Data �  05/04/17  ���
�������������������������������������������������������������������������͹��
���Descricao � Relat�rio Or�ado x realizado                               ���
�������������������������������������������������������������������������͹��
���Uso       � SIGACOM  -- >  Relat�rios/Rel. Or�ado x realizado         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function RCOR003()
Local oReport := nil
Local cPerg:= "RCOR003"

//gero a pergunta de modo oculto, ficando dispon�vel no bot�o a��es relacionadas
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
oReport := TReport():New(cNome,"Relat�rio Or�ado x Realizado ",cNome,{|oReport| ReportPrint(oReport)},"Or�ado x Realizado ")
oReport:SetLandscape() //SetPortrait()
oReport:SetTotalInLine(.F.)

oSection1:= TRSection():New(oReport, "Centro de Custo e Item", {"TRB"}, , .F., .T.)
//ZW3_NUM,ZW3_TIPO,ZW3_DATA,ZW3_CCUSTO,CTT_DESC01,ZW3_ITEMCO,CTD_DESC01,ZW3_CONTA,CT1_DESC01,ZW3_ANO,ZW3_VALOR,ZW3_HISTOR
TRCell():new(oSection1, "CCUSTO"   ,"TRB","CENTRO DE CUSTO"	 ,,TAMSX3("ZW5_CCUSTO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection1, "ITEMCO"   ,"TRB","ITEM CONTABIL" ,,TAMSX3("ZW2_ITEMCO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection1, "CLVL"     ,"TRB","CLASSE DE VALOR" ,,TAMSX3("ZW2_CLVL")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection1, "CONTA"    ,"TRB","CONTA" ,,TAMSX3("ZW2_CONTA")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection1, "ANO" 	   ,"TRB","ANO"  ,,TAMSX3("ZW3_ANO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)

TRCell():new(oSection1, "ORCTOT"    ,"TRB","Orc. TOTAL ANO"  ,"@E 999,999,999.99",TAMSX3("ZW2_PREANO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection1, "RELTOT"    ,"TRB","Rel. Total ANO"  ,"@E 999,999,999.99",TAMSX3("ZW2_RELANO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():new(oSection1, "VLTOT"     ,"TRB","Saldo TOTAL ANO"  ,"@E 999,999,999.99",TAMSX3("ZW2_PREANO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)

//oBreak := TRBreak():New(oSection1,{||oSection1:Cell("ITEMCON"):UPRINT},"SUB-TOTAL",.F.)
//TRFunction():New(oSection1:Cell("ITEMCON"),NIL,"COUNT",oBreak,,,,.F.,.T.)
TRFunction():New(oSection1:Cell("ORCTOT"),NIL,"SUM",,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection1:Cell("RELTOT"),NIL,"SUM",,"@E 999,999,999.99",,,.F.,.T.)
TRFunction():New(oSection1:Cell("VLTOT"),NIL,"SUM",,"@E 999,999,999.99",,,.F.,.T.)
oReport:SetTotalInLine(.F.)

//Aqui, farei uma quebra  por se��o
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

cQuery := "SELECT ZW2_CCUSTO,ZW2_ITEMCO,ZW2_CONTA,ZW2_ANO,ZW2_VLANO,ZW2_RELANO,ZW2_PREANO "
cQuery += "FROM " +RetSqlName("ZW2")+" ZW2 "
//cQuery += "WHERE ZW2_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
cQuery += "WHERE ZW2_CCUSTO BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
cQuery += "AND ZW2_ITEMCO BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "
cQuery += "AND ZW2_CLVL BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' "
cQuery += "AND ZW2_ANO BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "' "
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

//Irei percorrer todos os meus registros
While TRB->(!Eof())
	If oReport:Cancel()
		Exit
	EndIf
	dbSelectArea("TRB")
	//inicializo a primeira se��o
	oSection1:Init()
	
	oReport:IncMeter()
	
	IncProc("Imprimindo Centro de Custo "+alltrim(TRB->ZW2_CCUSTO))
	oSection1:Cell("CCUSTO"):SetValue(TRB->ZW2_CCUSTO)
	oSection1:Cell("ITEMCO"):SetValue(TRB->ZW2_ITEMCO)	
	oSection1:Cell("CLVL"):SetValue(TRB->ZW2_CLVL)	
	oSection1:Cell("CONTA"):SetValue(TRB->ZW2_CONTA)
	oSection1:Cell("ANO"):SetValue(TRB->ZW2_ANO)
		
		nVlTot := TRB->ZW2_PREANO - TRB->ZW2_RELANO

		oSection1:Cell("ORCTOT"):SetValue(TRB->ZW2_PREANO)
		oSection1:Cell("RELTOT"):SetValue(TRB->ZW2_RELANO)				
		oSection1:Cell("VLTOT"):SetValue(nVlTot)
		
		oSection1:Printline()
		//cItemco 	:= TRB->ZW2_ITEMCO
		TRB->(dbSkip())
	EndDo

	//imprimo uma linha para separar uma NCM de outra
   //	oReport:ThinLine()
	//finalizo a primeira se��o
	oSection1:Finish()
TRB->(DbCloseArea())
Return
