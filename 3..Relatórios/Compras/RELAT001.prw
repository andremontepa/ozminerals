#Include 'Protheus.ch'
#Include 'Protheus.ch'
#INCLUDE 'TOPCONN.CH' 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ RELAT001 บAutor ณLucas Costa       บ Data ณ    12/05/2021  บฑฑ
ฑฑฬออออออออออุออออออออออสออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Relat๓rio de Pedidos de Compras em Al็ada                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


User Function RELAT001()
	Local oReport := nil
	Local cPerg:= "PC000001"
	
	Pergunte(cPerg,.F.)	          
		
	oReport := RptDef(cPerg)
	oReport:PrintDialog()
Return

Static Function RptDef(cNome)
	Local oReport := Nil
	Local oSection1:= Nil
	Local oBreak

	
	/*Sintaxe: TReport():New(cNome,cTitulo,cPerguntas,bBlocoCodigo,cDescricao)*/
	oReport := TReport():New(cNome,"Pedidos em Al็ada",cNome,{|oReport| ReportPrint(oReport)},"Pedidos Bloqueadas")
	oReport:SetPortrait()    
	oReport:SetTotalInLine(.F.)
	
	oSection1:= TRSection():New(oReport, "Pedidos Bloqueadas", {"TRB"}, , .F., .T.)
    TRCell():new(oSection1, "CR_FILIAL" ,"TRB","Filial",PesqPict('SCR',"CR_FILIAL") ,TamSX3("CR_FILIAL")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "CR_NUM"   ,"TRB","Numero PC",PesqPict('SCR',"CR_NUM")   ,TamSX3("CR_NUM")[1]+4,/*lPixel*/,/*{|| code-block de impressao }*/) 	
    TRCell():new(oSection1, "CR_TOTAL" ,"TRB","Total",PesqPict('SCR',"CR_TOTAL") ,TamSX3("CR_TOTAL")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection1, "Razao Social"	,"TRB","Razao Social",PesqPict('SCR',"CR_NUM")  ,TamSX3("CR_NUM")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)     
    TRCell():new(oSection1, "Nome" ,"TRB","Nome"       ,PesqPict('SAK',"AK_NOME")   ,TamSX3("AK_NOME")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
  
	oReport:SetTotalInLine(.F.)
       
    //Aqui, farei uma quebra  por se็ใo
   	//oSection1:SetPageBreak(.T.)
   	TRFunction():New(oSection1:Cell("CR_NUM"),,,oBreak,,,,.F.,.T.)  	
   //	oSection1:SetTotalText(" ")				
Return(oReport)

Static Function ReportPrint(oReport)
	Local oSection1 := oReport:Section(1)	 
	Local cQuery    := "" 	
	Local cNumero     := ""        

	//Monto minha consulta conforme parametros passado 	       		
    cQuery := " SELECT C7_NUM,C7_ITEM,C7_FORNECE,C7_LOJA,CR_FILIAL,CR_TIPO,CR_NUM,CR_GRUPO,CR_APROV,CR_USER,CR_NIVEL,CR_STATUS,CR_TOTAL,CR_LIBAPRO,AK_USER,AK_COD,AK_NOME "
    cQuery += " FROM "+RETSQLNAME("SCR")+" SCR "
    cQuery += "   LEFT JOIN "+RETSQLNAME("SC7")+" SC7 ON SC7.D_E_L_E_T_ != '*' AND C7_NUM=CR_NUM AND C7_FILIAL=CR_FILIAL "
    cQuery += "   LEFT JOIN "+RETSQLNAME("SAK")+" SAK ON SAK.D_E_L_E_T_ != '*' AND AK_USER=CR_USER "
    cQuery += " WHERE SCR.D_E_L_E_T_ <> '*' "
	cQuery += "       AND CR_TIPO = 'PC' "
	cQuery += "       AND CR_STATUS = '02' "
    cQuery += "       AND C7_ITEM = '0001' "
	cQuery += "       AND CR_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'"
    cQuery += "       AND CR_EMISSAO BETWEEN '"+DtoS(MV_PAR03)+"' AND '"+DtoS(MV_PAR04)+"' "
    cQuery += " ORDER BY CR_FILIAL,CR_NUM "
		
	//Se o alias estiver aberto, irei fechar, isso ajuda a evitar erros
	IF Select("TRB") <> 0
		DbSelectArea("TRB")
		DbCloseArea()
	ENDIF	
	//crio o novo alias
	TCQUERY cQuery NEW ALIAS "TRB"		
	dbSelectArea("TRB")
	TRB->(dbGoTop()) 
	
	oReport:SetMeter(TRB->(LastRec()))	

	//Irei percorrer todos os meus registros
   	While !Eof()
		
		If oReport:Cancel()
			Exit
		EndIf
		cNumero	 := TRB->CR_NUM
		If TRB->CR_STATUS = '02'

		//Inicializo a Primeira Se็ใo
		oSection1:Init()

		oReport:IncMeter()

		IncProc("Imprimindo Pedido "+alltrim(TRB->CR_NUM))
 		
		//Imprimo a primeira se็ใo				
        oSection1:Cell("CR_FILIAL"):SetValue(TRB->CR_FILIAL)
        oSection1:Cell("CR_NUM"):SetValue(TRB->CR_NUM)
        oSection1:Cell("CR_TOTAL"):SetValue(TRB->CR_TOTAL)
        oSection1:Cell("Razao Social"):SetValue(POSICIONE("SA2",1,XFILIAL("SA2")+TRB->C7_FORNECE+TRB->C7_LOJA,"A2_NOME"))  			
		oSection1:Cell("Nome"):SetValue(TRB->AK_NOME)     			
		oSection1:Printline()
	Endif	
		//Finalizo a primeira Se็ใo
		oSection1:Finish()
		TRB->(dbSkip())
 	Enddo
     TRB->(DbCloseArea())
Return
