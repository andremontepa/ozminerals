#include "rwmake.ch"
#include "protheus.ch"
#define DMPAPER_A4 9

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ATFR001    º Autor ³ Toni Aguiar      º Data ³  07/04/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatório de depreciação mensal                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Relatórios>#Depreciação                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function ATFR002()
	local oReport
	Private cPerg := "ATFR002"

    CriaSX1() 
	oReport := reportDef()
	oReport:printDialog()
Return
 
Static Function ReportDef()
	local oReport
	Local oSection1
	local cTitulo := 'Relatório de deprecição mensal'
 
	oReport := TReport():New('ATFR002', cTitulo,cPerg, {|oReport| PrintReport(oReport)},"Depreciação Mensal")
	oReport:SetPortrait()
	oReport:SetTotalInLine(.F.)
	oReport:ShowHeader()
 
	oSection1 := TRSection():New(oReport,"Bens",{"SN1","SN4"})
	oSection1:SetTotalInLine(.F.)

    //TRCell():New(oSection1,/*Celula*/ ,/*Tabela*/,/*Titulo da Celula*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco de código }*/)	
 	TRCell():New(oSection1, "N1_FILIAL"	, "SN1",,PesqPict('SN1',"N1_FILIAL")  ,TamSX3("N1_FILIAL")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
 	TRCell():New(oSection1, "N1_CBASE"	, "SN1",,PesqPict('SN1',"N1_CBASE")   ,TamSX3("N1_CBASE")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "N1_ITEM"	, "SN1",,PesqPict('SN1',"N1_ITEM")    ,TamSX3("N1_ITEM")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "N1_GRUPO"  , "SN1",,PesqPict('SN1',"N1_GRUPO")   ,TamSX3("N1_GRUPO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "N1_DESCRIC", "SN1",,PesqPict('SN1',"N1_DESCRIC") ,TamSX3("N1_DESCRIC")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "N1_HIST"	,,"Histórico",PesqPict('SN1',"N1_DESCRIC"),TamSX3("N1_DESCRIC")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "N4_DATA"   , "SN4",,PesqPict('SN4',"N4_DATA")    ,TamSX3("N4_DATA")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "N4_VLROC1"	, "SN4",,PesqPict('SN4',"N4_VLROC1")  ,TamSX3("N4_VLROC1")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "N4_TXDEPR"	, "SN4",,PesqPict('SN4',"N4_TXDEPR")  ,TamSX3("N4_TXDEPR")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "N4_QUANTPR", "SN4",,PesqPict('SN4',"N4_QUANTPR") ,TamSX3("N4_QUANTPR")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "N1_XCEST"  , "SN1",,PesqPict('SN1',"N1_XCEST")   ,TamSX3("N1_XCEST")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)

Return (oReport)
 
Static Function PrintReport(oReport)        
Local cIndex1 := CriaTrab(Nil,.F.)  
Local cKey
Local cFilter
Local lRet
Local oSection1 := oReport:Section(1)               
Local nRecno   
Local nCnt:=0

oSection1:Init()
oSection1:SetHeaderSection(.T.)

dbSelectArea("SN4")
pergunte(cPerg,.F.)
cKey     :="N4_FILIAL+N4_CBASE+N4_ITEM+DTOS(N4_DATA)+N4_TIPO+N4_OCORR"
cFilter	 :="N4_FILIAL>='"+MV_PAR01+"' .AND. N4_FILIAL<='"+MV_PAR02+"' .AND. "+;  
           "N4_CBASE>='"+MV_PAR03+"' .AND. N4_CBASE<='"+MV_PAR04+"' .AND. "+;
           "N4_TIPO='"+If(MV_PAR08=1, "01", "10")+"' .AND. "+;
           "DTOS(N4_DATA)>='"+DTOS(MV_PAR05)+"' .AND. DTOS(N4_DATA)<='"+DTOS(MV_PAR06)+"' "
                                                                          

IndRegua("SN4",cIndex1,cKey,,cFilter,"Selecionando....")
dbGoTop()             

DbSelectArea('SN4')
dbGoTop()
oReport:SetMeter(SN4->(RecCount()))
Do While SN4->(!Eof())
   If oReport:Cancel()
   	   Exit
   EndIf
 
   oReport:IncMeter()
   
   dbSelectArea("SN1")
   SN1->(dbSetOrder(1))
   If SN1->(dbSeek(SN4->(N4_FILIAL+N4_CBASE+N4_ITEM))) .And. SN1->N1_STATUS=="1"
   
      nRecno:=SN4->(Recno())
      cReg:=SN4->(N4_FILIAL+N4_CBASE+N4_ITEM); nCnt:=0
      Do While cReg==SN4->(N4_FILIAL+N4_CBASE+N4_ITEM) .And. !SN4->(Eof())
         If SN4->N4_OCORR<>'05'
            nCnt++
         Endif
         dbSelectArea("SN4")
         dbSkip()
      Enddo
      If nCnt<>0
         SN4->(dbGoTo(nRecno))
      Endif
      
      Do While cReg==SN4->(N4_FILIAL+N4_CBASE+N4_ITEM) .And. !SN4->(Eof())
      
         If SN1->N1_XCEST<>MV_PAR07 .Or. !SN4->N4_TIPOCNT$"14"
            SN4->(dbSkip())
            Loop
         Endif
         
         oSection1:Cell("N1_FILIAL"):SetValue(SN1->N1_FILIAL)                     
         oSection1:Cell("N1_CBASE"):SetValue(SN1->N1_CBASE)
         oSection1:Cell("N1_ITEM"):SetValue(SN1->N1_ITEM)
         oSection1:Cell("N1_GRUPO"):SetValue(SN1->N1_GRUPO)
         oSection1:Cell("N1_DESCRIC"):SetValue(SN1->N1_DESCRIC)
         oSection1:Cell("N1_HIST"):SetValue(If(SN4->N4_OCORR="05", "Implantação", "Depreciação do mês"))
         oSection1:Cell("N4_DATA"):SetValue(SN4->N4_DATA)
         oSection1:Cell("N4_VLROC1"):SetValue(SN4->N4_VLROC1)
         oSection1:Cell("N4_TXDEPR"):SetValue(SN4->N4_TXDEPR)
         oSection1:Cell("N4_QUANTPR"):SetValue(SN4->N4_QUANTPR)
         oSection1:Cell("N1_XCEST"):SetValue(SN1->N1_XCEST)
         //oSection1:Cell("B1_SUFIXO"):SetAlign("CENTER")  
         oSection1:PrintLine()
      
         dbSelectArea("SN4")
         dbSkip()
      Enddo
   Else
      oSection1:Cell("N1_FILIAL"):SetValue("")
      oSection1:Cell("N1_CBASE"):SetValue("")
      oSection1:Cell("N1_ITEM"):SetValue("")
      oSection1:Cell("N1_GRUPO"):SetValue("")
      oSection1:Cell("N1_DESCRIC"):SetValue("")
      oSection1:Cell("N4_DATA"):SetValue(0)
      oSection1:Cell("N4_VLROC1"):SetValue("")
      oSection1:Cell("N4_TXDEPR"):SetValue(0)
      oSection1:Cell("N4_QUANTPR"):SetValue(0)
      oSection1:Cell("N1_XCEST"):SetValue("")
      dbSelectArea("SN4")
      dbSkip()
   Endif
EndDo
oSection1:Finish()
Return

Static Function CriaSX1()
Local _aHelpPor
   _aHelpPor	:= {}
   Aadd(_aHelpPor, "Informe a faixa de datas" )
   PutSx1(cPerg,"01","Filial de" ,"Filial de","Filial de","mv_ch1","C",02,0,0,"G","","SM0","","","mv_par01","","","","","","","","","","","","","","","","",_aHelpPor)
   PutSx1(cPerg,"02","Filial até","Filial até","Filial até","mv_ch2","C",02,0,0,"G","","SM0","","","mv_par02","","","","","","","","","","","","","","","","",_aHelpPor)
   PutSx1(cPerg,"03","Bem de"    ,"","","mv_ch3","C",10,0,0,"G","","SN1","","","mv_par03","","","","","","","","","","","","","","","","",_aHelpPor)
   PutSx1(cPerg,"04","Bem até"   ,"","","mv_ch4","C",10,0,0,"G","","SN1","","","mv_par04","","","","","","","","","","","","","","","","",_aHelpPor)
   PutSx1(cPerg,"05","Período de"   ,"","","mv_ch5","D",8,0,0,"G","","","","","mv_par05","","","","","","","","","","","","","","","","",_aHelpPor)
   PutSx1(cPerg,"06","Período até"   ,"","","mv_ch6","D",8,0,0,"G","","","","","mv_par06","","","","","","","","","","","","","","","","",_aHelpPor)
   PutSx1(cPerg,"07","Classif. Estimada","","","mv_ch7","C",4,0,0,"G","","SZ4","","","mv_par07","","","","","","","","","","","","","","","","",_aHelpPor) 
   PutSx1(cPerg,"08","Tipo","","","mv_ch8","N",1,0,0,"C","","","","","mv_par08","01-Fiscal","","","","10-Gerencial","","","","","","","","","","","",_aHelpPor) 

Return
