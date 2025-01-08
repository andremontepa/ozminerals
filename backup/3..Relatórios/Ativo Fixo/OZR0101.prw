#Include "Totvs.ch"
  
/*/{Protheus.doc} User Function OZR0101
Produtos
@author André Mendes -CRM
@since 14/11/2023
@version 1.0
@type function

@Obs: Relatorio depreciação acelarada

/*/
  
User Function OZR0101()
    Local aArea := FWGetArea()
    Local oReport
    Local aPergs   := {}
    Local xPar0 := FirstDate(dDataBase)
    Local xPar1 := lastDate(dDataBase)
	Local xPar2 := Stod("20230101")
	Local xPar3 := lastDate(dDataBase)
	Local xPar4 := ""


      
    //Adicionando os parametros do ParamBox
    aAdd(aPergs, {1, "Data de:", xPar0,  ""	, ".T.", "", ".T.", 80,  .F.})
	aAdd(aPergs, {1, "Data até:", xPar1,  "", ".T.", "", ".T.", 80,  .F.})
    aAdd(aPergs, {1, "Acumulado de", xPar2,  "", ".T.", "", ".T.", 80,  .F.})
	aAdd(aPergs, {1, "Acumulado até", xPar3,  "", ".T.", "", ".T.", 80,  .F.})
	aAdd(aPergs, {1, "Codigo do bem", xPar4,  "", ".T.", "SN1", ".T.", 6,  .F.})
      
  
    If ParamBox(aPergs, "Informe os parametros", , , , , , , , , .F., .F.)
        oReport := fReportDef()
        oReport:SetTotalInLine(.F.)      
        oReport:PrintDialog() 
        
    EndIf
      
    FWRestArea(aArea)
Return
  
/*/{Protheus.doc} fReportDef
Definicoes do relatorio OZR0101
@author André Mendes - CRM
@since 14/11/2022
@version 1.0
/*/
  
Static Function fReportDef()
    Local oReport
    Local oSection := Nil
      
    //Criacao do componente de impressao
    oReport := TReport():New( "Rel_Depreciacao",;
        "Rel. Depreciação",;
        ,;
        {|oReport| fRepPrint(oReport),};
        )
    oReport:SetTotalInLine(.F.)
    oReport:lParamPage := .F.
    oReport:oPage:SetPaperSize(9)
      
    //Orientacao do Relatorio
    oReport:SetPortrait()
      
    //Criando a secao de dados
    oSection := TRSection():New( oReport,;
        "Dados",;
        {"QRY_REP"})
    oSection:SetTotalInLine(.F.)
      
    //Colunas do relatorio
    TRCell():New(oSection, "N4_FILIAL", "QRY_REP", "Filial", /*cPicture*/, 4, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New(oSection, "N4_CBASE", "QRY_REP", "Codigo Bem", /*cPicture*/, 8, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New(oSection, "N4_ITEM", "QRY_REP", "Item", /*cPicture*/, 3, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New(oSection, "N1_DESCRIC", "QRY_REP", "Descrição", /*cPicture*/, 50, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.) 
	TRCell():New(oSection, "ACELARADO", "QRY_REP", "Vlr. acelerado", /*cPicture*/, 20, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New(oSection, "CONTABIL", "QRY_REP", "Vlr. contabil", /*cPicture*/, 20, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New(oSection, "AC_ACELERADO", "QRY_REP", "Acumulado acelerado", /*cPicture*/, 20, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New(oSection, "AC_CONTABIL", "QRY_REP", "Acumulado Contabil", /*cPicture*/, 20, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)   
Return oReport
  
/*/{Protheus.doc} fRepPrint
Impressao do relatorio OZR0101
@author André Mendes - CRM
@since 14/11/2023
@version 1.0
/*/
  
Static Function fRepPrint(oReport)
    Local aArea    := FWGetArea()
    Local cQryReport  := ""
    Local oSectDad := Nil
    Local nAtual   := 0
    Local nTotal   := 0
      
  
    oSectDad := oReport:Section(1)
    
   	cQryReport:= "SELECT  DISTINCT "                        + CRLF
	cQryReport+= "N4_FILIAL,"                        		+ CRLF
	cQryReport+= "N4_CBASE,"                        		+ CRLF
	cQryReport+= "N4_ITEM,"                        			+ CRLF
	cQryReport+= "N1_DESCRIC,"                        		+ CRLF
	cQryReport+= "N4_VLROC1 AS 'ACELARADO',"                + CRLF
	cQryReport+= "(SELECT MAX(N4_VLROC1) FROM SN4010 SN4B WHERE SN4B.N4_CBASE = SN4.N4_CBASE AND SN4B.N4_ITEM = SN4.N4_ITEM AND SN4B.N4_DATA BETWEEN '" + dTos(MV_PAR01) + "' AND '" + dTos(MV_PAR02) + "' AND SN4B.N4_TIPO = '10' AND SN4B.N4_FILIAL = SN4.N4_FILIAL AND  SN4B.D_E_L_E_T_= '') AS 'CONTABIL', "    + CRLF
	cQryReport+= "(SELECT SUM(N4_VLROC1) FROM SN4010 SN4C WHERE SN4C.N4_DATA BETWEEN '" + dTos(MV_PAR03) + "' AND '" + dTos(MV_PAR04) + "' AND   SN4C.N4_CBASE = SN4.N4_CBASE AND SN4C.N4_ITEM = SN4.N4_ITEM AND SN4C.N4_TIPO = '07' AND  SN4C.N4_FILIAL = SN4.N4_FILIAL AND  SN4C.D_E_L_E_T_= '') AS 'AC_ACELERADO', "                        + CRLF
	cQryReport+= "(SELECT SUM(N4_VLROC1) FROM SN4010 SN4D WHERE SN4D.N4_DATA BETWEEN '" + dTos(MV_PAR03) + "' AND '" + dTos(MV_PAR04) + "' AND 	 SN4D.N4_CBASE = SN4.N4_CBASE AND SN4D.N4_ITEM = SN4.N4_ITEM AND SN4D.N4_TIPO = '10' AND SN4D.N4_FILIAL = SN4.N4_FILIAL AND SN4D.N4_TIPOCNT ='4' AND  SN4D.D_E_L_E_T_= '') AS 'AC_CONTABIL' "                        	 + CRLF


	cQryReport+= "FROM SN4010 SN4 "                        + CRLF
	cQryReport+= "INNER JOIN SN1010 SN1 ON N1_CBASE = N4_CBASE AND N1_ITEM = N4_ITEM AND SN1.D_E_L_E_T_= '' "                     + CRLF
	cQryReport+= "INNER JOIN SN3010 SN3 ON N3_CBASE = N4_CBASE AND  N3_ITEM = N4_ITEM AND N3_TIPO = '07' "                        + CRLF

	cQryReport+= "WHERE "                        		+ CRLF
	cQryReport+= "SN4.N4_DATA BETWEEN '" + dTos(MV_PAR01) + "' AND '" + dTos(MV_PAR02) + "' "    	+ CRLF
	cQryReport+= "AND SN4.N4_TIPO  = '07' "       		+ CRLF
	cQryReport+= "AND SN4.N4_FILIAL ='" + FWxFilial('SN4') + "'"       + CRLF
	cQryReport+= "AND SN4.D_E_L_E_T_= '' "       + CRLF	

	IF MV_PAR05 <> ''
	cQryReport+= "AND SN1.N1_CBASE '" + dTos(MV_PAR05) + "'  "       + CRLF	
	END IF

      
   
    PlsQuery(cQryReport, "QRY_REP")
    DbSelectArea("QRY_REP")
    Count to nTotal
    oReport:SetMeter(nTotal)
      
 
    oSectDad:Init()
    QRY_REP->(DbGoTop())
    While ! QRY_REP->(Eof())
      
     
        nAtual++
        oReport:SetMsgPrint("Imprimindo registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")
        oReport:IncMeter()
          
        //Imprimindo a linha atual
        oSectDad:PrintLine()
          
        QRY_REP->(DbSkip())
    EndDo
    oSectDad:Finish()
    QRY_REP->(DbCloseArea())
      
    FWRestArea(aArea)
Return
