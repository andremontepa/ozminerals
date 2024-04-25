#include "rwmake.ch"
#include "protheus.ch"
#define DMPAPER_A4 9
#define cAtualiza  "2"        // 1 - Atualiza modo SPED PIS/COFINS, 2 - Atualiza ativo fixo implantação 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ATFR001    º Autor ³ Toni Aguiar      º Data ³  13/02/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Imprime os bens com a formulação de valores - MV_VLRATF    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Relatórios>#Form.Valoriz.Bem                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function ATFR001()
	local oReport
	Private cPerg := "ATFR001"

    CriaSX1() 
	oReport := reportDef()
	oReport:printDialog()
Return
 
Static Function ReportDef()
	local oReport
	Local oSection1
	local cTitulo := 'Formulação do valor do bem'
	Private _cPosicao:=""
 
	oReport := TReport():New('ATFR001', cTitulo,cPerg, {|oReport| PrintReport(oReport)},"Verifica se os valores estão de acordo com o par. MV_VLRATF x NF ")
	oReport:SetPortrait()
	oReport:SetTotalInLine(.F.)
	oReport:ShowHeader()
 
	oSection1 := TRSection():New(oReport,"Notas",{"SN1","SD1"})
	oSection1:SetTotalInLine(.F.)

    //TRCell():New(oSection1,/*Celula*/ ,/*Tabela*/,/*Titulo da Celula*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco de código }*/)	
 	TRCell():New(oSection1, "N1_FILIAL"	, "SN1",,PesqPict('SN1',"N1_FILIAL")  ,TamSX3("N1_FILIAL")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
 	TRCell():New(oSection1, "N1_XCEST"	, "SN1",,PesqPict('SN1',"N1_XCEST")  ,TamSX3("N1_XCEST")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
 	TRCell():New(oSection1, "N1_CBASE"	, "SN1",,PesqPict('SN1',"N1_CBASE")  ,TamSX3("N1_CBASE")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "N1_ITEM"	, "SN1",,PesqPict('SN1',"N1_ITEM")   ,TamSX3("N1_ITEM")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "N1_DESCRIC", "SN1",,PesqPict('SN1',"N1_DESCRIC") ,TamSX3("N1_DESCRIC")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "N1_GRUPO"  , "SN1",,PesqPict('SN1',"N1_GRUPO") ,TamSX3("N1_GRUPO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "N1_AQUISIC", "SN1",,PesqPict('SN1',"N1_AQUISIC") ,TamSX3("N1_AQUISIC")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "N3_DINDEPR", "SN3",,PesqPict('SN3',"N3_DINDEPR") ,TamSX3("N3_DINDEPR")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "D1_NOTA"	, "SD1",,PesqPict('SD1',"D1_DOC")	 ,TamSX3("D1_DOC")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "D1_SERIE"	, "SD1",,PesqPict('SD1',"D1_SERIE")	 ,TamSX3("D1_SERIE")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "D1_FORNECE", "SD1",,PesqPict('SD1',"D1_FORNECE")	 ,TamSX3("D1_FORNECE")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "D1_TOTAL"	, "SD1",,PesqPict('SD1',"D1_TOTAL")	 ,TamSX3("D1_TOTAL")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "D1_VALDESC", "SD1",,PesqPict('SD1',"D1_VALDESC"),TamSX3("D1_VALDESC")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "D1_VALIPI"	, "SD1",,PesqPict('SD1',"D1_VALIPI") ,TamSX3("D1_VALIPI")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "D1_VALICM"	, "SD1",,PesqPict('SD1',"D1_VALICM") ,TamSX3("D1_VALICM")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "D1_VDESAG"	,,"Deságio",PesqPict('SD1',"D1_VALICM") ,TamSX3("D1_VALICM")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "D1_VALCOF"	, "SD1",,PesqPict('SD1',"D1_VALIMP5") ,TamSX3("D1_VALIMP5")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "D1_VALPIS"	, "SD1",,PesqPict('SD1',"D1_VALIMP6") ,TamSX3("D1_VALIMP6")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "N1_VALBEM"	,,"Vlr. Bem",PesqPict('SD1',"D1_TOTAL"),TamSX3("D1_TOTAL")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "D1_VNOTA"	,,"Vlr. NF",PesqPict('SD1',"D1_TOTAL"),TamSX3("D1_TOTAL")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)

 
	//oBreak := TRBreak():New(oSection1,oSection1:Cell("B1_FILIAL"),,.F.)
 
	//TRFunction():New(oSection1:Cell("D2_TOTAL"),,"SUM",/*oBreak*/,,PesqPict('SD2',"D2_TOTAL"),.F.,.T.,.F.)
 
	//TRFunction():New(oSection1:Cell("B1_FILIAL"),"TOTAL GERAL" ,"COUNT",,,"@E 999999",,.F.,.T.)	
 
Return (oReport)
 
Static Function PrintReport(oReport)        
Local cIndex1 := CriaTrab(Nil,.F.)  
Local cKey
Local cFilter
Local oSection1 := oReport:Section(1)               
Local nVOrigBem:={0,0} 							//Elemento 1 - Valor do bem, Elemento 2 - Valor encontrado na nota
Local nQtd:=1   
Local cTipo:=If(cAtualiza="1", "01", "10")		// Se 1-Depreciação Fiscal ou 2-Depreciação Gerencial/Unidade de produção
Local nDesagio:=0
Local nValRat := SuperGetMv("MV_VLRATF")

oSection1:Init()
oSection1:SetHeaderSection(.T.)

dbSelectArea("SN1")

pergunte(cPerg,.F.)
cKey     :="N1_FILIAL+N1_CBASE+N1_ITEM"
cFilter	:="N1_FILIAL>='"+MV_PAR01+"' .AND. N1_FILIAL<='"+MV_PAR02+"' .AND. N1_STATUS='1' "

IndRegua("SN1",cIndex1,cKey,,cFilter,"Selecionando....")
dbGoTop()             

DbSelectArea('SN1')
dbGoTop()
oReport:SetMeter(SN1->(RecCount()))
Do While SN1->(!Eof())
   If oReport:Cancel()
   	   Exit
   EndIf
 
   oReport:IncMeter()

   oSection1:Cell("N1_FILIAL"):SetValue(SN1->N1_FILIAL)

   oSection1:Cell("N1_XCEST"):SetValue(SN1->N1_XCEST)

   oSection1:Cell("N1_CBASE"):SetValue(SN1->N1_CBASE)
   //oSection1:Cell("B1_FILIAL"):SetAlign("CENTER")
 
   oSection1:Cell("N1_ITEM"):SetValue(SN1->N1_ITEM)
   //oSection1:Cell("B1_CODMES"):SetAlign("CENTER")
 
   oSection1:Cell("N1_DESCRIC"):SetValue(SN1->N1_DESCRIC)
   //oSection1:Cell("B1_SUFIXO"):SetAlign("CENTER")  

   oSection1:Cell("N1_GRUPO"):SetValue(SN1->N1_GRUPO)
   
   dbSelectArea("SN3")
   SN3->(dbSetOrder(1))
   SN3->(dbSeek(SN1->(N1_FILIAL+N1_CBASE+N1_ITEM)+cTipo+"0"+"001")) // filial+cbase+item+tipo+baixa+sequencia 
   nVOrigBem[01]:=SN3->N3_VORIG1
   
   
   dbSelectArea("SD1")
   SD1->(dbSetOrder(1))
   SD1->(dbSeek(SN1->(N1_FILIAL+N1_NFISCAL+N1_NSERIE+N1_FORNEC+N1_LOJA+N1_PRODUTO+N1_NFITEM)))

   oSection1:Cell("N1_AQUISIC"):SetValue(SN1->N1_AQUISIC)
   oSection1:Cell("N3_DINDEPR"):SetValue(SN3->N3_DINDEPR)
   oSection1:Cell("D1_NOTA"):SetValue(SD1->D1_DOC)
   oSection1:Cell("D1_SERIE"):SetValue(SD1->D1_SERIE)
   //oSection1:Cell("B1_SUFIXO"):SetAlign("CENTER")  
   
   dbSelectArea("SF4")
   SF4->(dbSetOrder(1))
   SF4->(dbSeek(xFilial("SF4")+SD1->D1_TES))
   
   If SF4->F4_BENSATF=='1'          
      nVOrigBem[02] := Round( &(nValRat) / SD1->D1_QUANT ,2) 
      nQtd:=SD1->D1_QUANT
   Else
      nVOrigBem[02] := Round( &(nValRat) ,2) 
      nQtd:=1
   Endif
 
   oSection1:Cell("D1_TOTAL"):SetValue(NoRound( SD1->D1_TOTAL / nQtd,2))
   oSection1:Cell("D1_VALDESC"):SetValue(NoRound( SD1->D1_VALDESC / nQtd,2))
   If SF4->F4_CREDIPI=='S'
      oSection1:Cell("D1_VALIPI"):SetValue(0)
   Else
      oSection1:Cell("D1_VALIPI"):SetValue(NoRound( SD1->D1_VALIPI / nQtd,2))
   Endif
   If SF4->F4_CREDICM=='S'
      oSection1:Cell("D1_VALICM"):SetValue(NoRound( SD1->D1_VALICM / nQtd,2))

      // Informar o desagio
      nDesagio:=Round( (Round( SD1->D1_VALICM / nQtd,2) * 35)/100, 2)
      oSection1:Cell("D1_VDESAG"):SetValue(nDesagio)                   
      nVOrigBem[02]+=nDesagio  
   Else                                                                
      nDesagio:=0
      oSection1:Cell("D1_VALICM"):SetValue(0)    
      oSection1:Cell("D1_VDESAG"):SetValue(0)
   Endif                                         
   
   If SF4->F4_PISCRED=='1'
      oSection1:Cell("D1_VALCOF"):SetValue(NoRound( SD1->D1_VALIMP5 / nQtd,2))
      oSection1:Cell("D1_VALPIS"):SetValue(NoRound( SD1->D1_VALIMP6 / nQtd,2))
   Else
      oSection1:Cell("D1_VALCOF"):SetValue(0)
      oSection1:Cell("D1_VALPIS"):SetValue(0) 
   Endif
   oSection1:Cell("N1_VALBEM"):SetValue(nVOrigBem[01])
   
   If nVOrigBem[01]<>nVOrigBem[02]
      oSection1:Cell("D1_VNOTA"):SetValue(nVOrigBem[02])
   Else
      oSection1:Cell("D1_VNOTA"):SetValue(0)
   Endif
   oSection1:PrintLine()
 
   dbSelectArea("SN1")
   SN1->(dbSkip())
EndDo
oSection1:Finish()
Return

Static Function CriaSX1()
Local _aHelpPor
   _aHelpPor	:= {}
   Aadd(_aHelpPor, "Informe a faixa de datas" )
   PutSx1(cPerg,"01","Filial de","Filial de","Filial de","mv_ch1","C",02,0,0,"G","","SM0","","","mv_par01","","","","","","","","","","","","","","","","",_aHelpPor)
   PutSx1(cPerg,"02","Filial até","Filial até","Filial até","mv_ch2","C",02,0,0,"G","","SM0","","","mv_par02","","","","","","","","","","","","","","","","",_aHelpPor)
Return
