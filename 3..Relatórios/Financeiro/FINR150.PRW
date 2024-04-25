#INCLUDE "FINR150.CH"
#Include "PROTHEUS.Ch"
#INCLUDE "FWCOMMAND.CH"
#Include "TopConn.Ch"

#DEFINE QUEBR				1
#DEFINE FORNEC				2
#DEFINE TITUL				3
#DEFINE TIPO				4
#DEFINE NATUREZA			5
#DEFINE EMISSAO			6
#DEFINE VENCTO				7
#DEFINE VENCREA			8
#DEFINE VL_ORIG			9
#DEFINE VL_NOMINAL		10
#DEFINE VL_CORRIG			11
#DEFINE VL_VENCIDO		12
#DEFINE PORTADOR			13
#DEFINE VL_JUROS			14
#DEFINE ATRASO				15
#DEFINE HISTORICO			16
#DEFINE VL_SOMA			17
#DEFINE VL_PA			18 // ismael junior 29/06/2021

Static lFWCodFil := FindFunction("FWCodFil")

/*/
??????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??un?o    ?FIN150	?Autor ?Daniel Tadashi Batori ?Data ?07.08.06 ??
???????????????????????????????????????
??escri?o ?Posi?o dos Titulos a Pagar					              ??
???????????????????????????????????????
??intaxe e ?FINR150(void)                                              ??
???????????????????????????????????????
??arametros?                                                           ??
???????????????????????????????????????
??Uso      ?Generico                                                   ??
???????????????????????????????????????
???????????????????????????????????????
??????????????????????????????????????
*/
user Function cFINR150()

Local oReport  

Private cTitAux := ""    // Guarda o titulo do relat?io para R3 e R4 

/*
GESTAO - inicio */
Private aSelFil	:= {}
/* GESTAO - fim
 */

AjustaSx1()
 
If FindFunction("TRepInUse") .And. TRepInUse() 
	oReport := ReportDef()
	oReport:PrintDialog()
Else
	Return u_cF150R3() // Executa vers? anterior do fonte
Endif

Return

/*
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??un?o    ?ReportDef?Autor ?Daniel Batori         ?Data ?07.08.06 ??
???????????????????????????????????????
??escri?o ?Definicao do layout do Relatorio									  ??
???????????????????????????????????????
??intaxe   ?ReportDef(void)                                            ??
???????????????????????????????????????
??Uso      ?Generico                                                   ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
*/
Static Function ReportDef()
Local oReport
Local oSection1
Local cPictTit
Local nTamVal, nTamCli, nTamQueb
Local cPerg := "FIN150"
Local aOrdem := {STR0008,;	//"Por Numero"
				 STR0009,;	//"Por Natureza"
				 STR0010,;	//"Por Vencimento"
				 STR0011,;	//"Por Banco"
				 STR0012,;	//"Fornecedor"
				 STR0013,;	//"Por Emissao"
				 STR0014}	//"Por Cod.Fornec."

oReport := TReport():New("cFINR150",STR0005,"FIN150",{|oReport| ReportPrint(oReport)},STR0001+STR0002)

oReport:SetLandScape(.T.)
oReport:SetTotalInLine(.F.)		//Imprime o total em linha

/*
GESTAO - inicio */
oReport:SetUseGC(.F.)
/* GESTAO - fim
*/

//Nao retire esta chamada. Verifique antes !!!
//Ela ?necessaria para o correto funcionamento da pergunte 36 (Data Base)
PutDtBase()

dbSelectArea("SX1")

pergunte("FIN150",.F.)
//????????????????????
//?Variaveis utilizadas para parametros ?
//?mv_par01	  // do Numero 			  ?
//?mv_par02	  // at?o Numero 		  ?
//?mv_par03	  // do Prefixo			  ?
//?mv_par04	  // at?o Prefixo		  ?
//?mv_par05	  // da Natureza  	     ?
//?mv_par06	  // at?a Natureza		  ?
//?mv_par07	  // do Vencimento		  ?
//?mv_par08	  // at?o Vencimento	  ?
//?mv_par09	  // do Banco			     ?
//?mv_par10	  // at?o Banco		     ?
//?mv_par11	  // do Fornecedor		  ?
//?mv_par12	  // at?o Fornecedor	  ?
//?mv_par13	  // Da Emiss?			  ?
//?mv_par14	  // Ate a Emiss?		  ?
//?mv_par15	  // qual Moeda			  ?
//?mv_par16	  // Imprime Provis?ios  ?
//?mv_par17	  // Reajuste pelo vencto ?
//?mv_par18	  // Da data contabil	  ?
//?mv_par19	  // Ate data contabil	  ?
//?mv_par20	  // Imprime Rel anal/sint?
//?mv_par21	  // Considera  Data Base??
//?mv_par22	  // Cons filiais abaixo ??
//?mv_par23	  // Filial de            ?
//?mv_par24	  // Filial ate           ?
//?mv_par25	  // Loja de              ?
//?mv_par26	  // Loja ate             ?
//?mv_par27 	  // Considera Adiantam.? ?
//?mv_par28	  // Imprime Nome 		  ?
//?mv_par29	  // Outras Moedas 		  ?
//?mv_par30     // Imprimir os Tipos    ?
//?mv_par31     // Nao Imprimir Tipos	  ?
//?mv_par32     // Consid. Fluxo Caixa  ?
//?mv_par33     // DataBase             ?
//?mv_par34     // Tipo de Data p/Saldo ?
//?mv_par35     // Quanto a taxa		  ?
//?mv_par36     // Tit.Emissao Futura	  ?
//?mv_par37     // Seleciona filiais (GESTAO)
//?mv_par38     // Considera Tit Exclu?
//????????????????????

cPictTit := PesqPict("SE2","E2_VALOR")
If cPaisLoc == "CHI"
	cPictTit := SubStr(cPictTit,1,At(".",cPictTit)-1)
EndIf   

nTamVal	 := TamSX3("E2_VALOR")[1]
nTamCli	 := TamSX3("E2_FORNECE")[1] + TamSX3("E2_LOJA")[1] + 25
nTamTit	 := TamSX3("E2_PREFIXO")[1] + TamSX3("E2_NUM")[1] + TamSX3("E2_PARCELA")[1] + 8
nTamQueb := nTamCli + nTamTit + TamSX3("E2_TIPO")[1] + TamSX3("E2_NATUREZ")[1] + TamSX3("E2_EMISSAO")[1] +;
			TamSX3("E2_VENCTO")[1] + TamSX3("E2_VENCREA")[1] + 14
			
//???????
//? Secao 1  ?
//???????
oSection1 := TRSection():New(oReport,STR0061,{"SE2","SA2"},aOrdem)

TRCell():New(oSection1,"FORNECEDOR"	,	  ,STR0038				,,nTamCli,.F.,)  		//"Codigo-Nome do Fornecedor"
TRCell():New(oSection1,"TITULO"		,	  ,STR0039+CRLF+STR0040	,,nTamTit,.F.,)  		//"Prf-Numero" + "Parcela"
TRCell():New(oSection1,"E2_TIPO"	,"SE2",STR0041				,,,.F.,)  				//"TP"
TRCell():New(oSection1,"E2_NATUREZ"	,"SE2",STR0042				,,TamSX3("E2_NATUREZ")[1] + 5,.F.,)  				//"Natureza"
TRCell():New(oSection1,"E2_EMISSAO"	,"SE2",STR0043+CRLF+STR0044	,,,.F.,) 				//"Data de" + "Emissao"
TRCell():New(oSection1,"E2_VENCTO"	,"SE2",STR0043+CRLF+STR0045	,,,.F.,)  				//"Vencto" + "Titulo"
TRCell():New(oSection1,"E2_VENCREA"	,"SE2",STR0045+CRLF+STR0047	,,,.F.,)  				//"Vencto" + "Real"
TRCell():New(oSection1,"VAL_ORIG"	,	  ,STR0048				,cPictTit,nTamVal+3,.F.,) //"Valor Original"
TRCell():New(oSection1,"VAL_NOMI"	,	  ,STR0049+CRLF+STR0050	,cPictTit,nTamVal+3,.F.,) //"Tit Vencidos" + "Valor Nominal"
TRCell():New(oSection1,"VAL_CORR"	,	  ,STR0049+CRLF+STR0051	,cPictTit,nTamVal+3,.F.,) //"Tit Vencidos" + "Valor Corrigido"
TRCell():New(oSection1,"VAL_VENC"	,	  ,STR0052+CRLF+STR0050	,cPictTit,nTamVal+3,.F.,) //"Titulos a Vencer" + "Valor Nominal"
TRCell():New(oSection1,"E2_PORTADO"	,"SE2",STR0053+CRLF+STR0054	,,,.F.,)  				//"Porta-" + "dor"
TRCell():New(oSection1,"JUROS"		,	  ,STR0055+CRLF+STR0056	,cPictTit,nTamVal+3,.F.,) //"Vlr.juros ou" + "permanencia"
TRCell():New(oSection1,"DIA_ATR"	,	  ,STR0057+CRLF+STR0058	,,4,.F.,)  				//"Dias" + "Atraso"
TRCell():New(oSection1,"E2_HIST"	,"SE2",IIf(cPaisloc =="MEX",STR0063,STR0059) ,,35,.F.,)  			//"Historico(Vencidos+Vencer)"
TRCell():New(oSection1,"VAL_SOMA"	,	  ,STR0060				,cPictTit,nTamVal+7,.F.,) 	//"(Vencidos+Vencer)"
TRCell():New(oSection1,"VLPA"	,	  ,"Valor PA"				,cPictTit,nTamVal+7,.F.,) 

oSection1:Cell("VAL_ORIG"):SetHeaderAlign("RIGHT")
oSection1:Cell("VAL_NOMI"):SetHeaderAlign("RIGHT")             
oSection1:Cell("VAL_CORR"):SetHeaderAlign("RIGHT")
oSection1:Cell("VAL_VENC"):SetHeaderAlign("RIGHT")
oSection1:Cell("JUROS")   :SetHeaderAlign("RIGHT")  
oSection1:Cell("VAL_SOMA"):SetHeaderAlign("RIGHT") 

oSection1:SetLineBreak(.f.)		//Quebra de linha automatica

oSection2 := TRSection():New(oReport,STR0061,{"SM0"},aOrdem)

TRCell():New(oSection2,"FILIAL"		,,STR0065	,			,105) //"Total por Filial:"
TRCell():New(oSection2,"VALORORIG"	,,STR0048				,cPictTit	,nTamVal+3)//"Valor Original"
TRCell():New(oSection2,"VALORNOMI"	,,STR0049+CRLF+STR0050	,cPictTit	,nTamVal+3)//"Tit Vencidos" + "Valor Nominal"
TRCell():New(oSection2,"VALORCORR"	,,STR0049+CRLF+STR0051	,cPictTit	,nTamVal+3)//"Tit Vencidos" + "Valor Corrigido"
TRCell():New(oSection2,"VALORVENC"	,,STR0052+CRLF+STR0050	,cPictTit	,nTamVal+3)//"Titulos a Vencer" + "Valor Nominal"
TRCell():New(oSection2,"JUROS"		,,STR0055+CRLF+STR0056	,cPictTit	,nTamVal+5)//"Vlr.juros ou" + "permanencia"
TRCell():New(oSection2,"VALORSOMA"	,,STR0060				,cPictTit	,nTamVal+20)//"(Vencidos+Vencer)"


oSection2:Cell("VALORORIG"):SetHeaderAlign("RIGHT")
oSection2:Cell("VALORNOMI"):SetHeaderAlign("RIGHT")             
oSection2:Cell("VALORCORR"):SetHeaderAlign("RIGHT")
oSection2:Cell("VALORVENC"):SetHeaderAlign("RIGHT")
oSection2:Cell("JUROS")   :SetHeaderAlign("RIGHT")  
oSection2:Cell("VALORSOMA"):SetHeaderAlign("RIGHT")

oSection2:SetLineBreak(.F.)

Return oReport                                                                              

/*
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??rograma  ?eportPrint?Autor ?aniel Batori          ?Data ?8.08.06	??
???????????????????????????????????????
??escri?o ? funcao estatica ReportDef devera ser criada para todos os  ??
??         ?elatorios que poderao ser agendados pelo usuario.           ??
???????????????????????????????????????
??etorno   ?enhum                                                       ??
???????????????????????????????????????
??arametros?xpO1: Objeto Report do Relat?io                            ??
???????????????????????????????????????
??  DATA   ?Programador   ?anutencao efetuada                          ??
???????????????????????????????????????
??         ?              ?                                            ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
*/
Static Function ReportPrint(oReport)

Local oSection1	:=	oReport:Section(1) 
Local oSection2	:=	oReport:Section(2)
Local nOrdem 	:= oSection1:GetOrder()
Local oBreak
Local oBreak2

Local aDados[18]
Local cString :="SE2"
Local nRegEmp := SM0->(RecNo())
Local nRegSM0 := SM0->(Recno())
Local nAtuSM0 := SM0->(Recno())
Local dOldDtBase := dDataBase
Local dOldData := dDataBase
Local nJuros  :=0

Local nQualIndice := 0
Local lContinua := .T.
Local nTit0:=0,nTit1:=0,nTit2:=0,nTit3:=0,nTit4:=0,nTit5:=0
Local nTot0:=0,nTot1:=0,nTot2:=0,nTot3:=0,nTot4:=0,nTotTit:=0,nTotJ:=0,nTotJur:=0
LOcal nTotFil0:=0, nTotFil1:=0, nTotFil2:=0, nTotFil3:=0,nTotFil4:=0, nTotFilTit:=0, nTotFilJ:=0
Local nFil0:=0,nFil1:=0,nFil2:=0,nFil3:=0,nFil4:=0,nFilTit:=0,nFilJ:=0
Local cCond1,cCond2,cCarAnt,nSaldo:=0,nAtraso:=0
Local dDataReaj
Local dDataAnt := dDataBase , lQuebra
Local nMestit0:= nMesTit1 := nMesTit2 := nMesTit3 := nMesTit4 := nMesTTit := nMesTitj := 0
Local dDtContab
Local cIndexSe2
Local cChaveSe2
Local nIndexSE2
Local cFilDe,cFilAte
Local nTotsRec := SE2->(RecCount())
Local aTamFor := TAMSX3("E2_FORNECE")
Local nDecs := Msdecimais(mv_par15)
Local lFr150Flt := EXISTBLOCK("FR150FLT")
Local cFr150Flt := iif(lFr150Flt,ExecBlock("FR150FLT",.F.,.F.),"")
Local cMoeda := LTrim(Str(mv_par15))
Local cFilterUser
Local cFilUserSA2 := oSection1:GetADVPLExp("SA2")

Local cNomFor	:= ""
Local cNomNat	:= ""
Local cNomFil	:= ""
Local cNumBco	:= 0
Local nTotVenc	:= 0
Local nTotMes	:= 0
Local nTotGeral := 0
Local nTotTitMes:= 0
Local nTotFil	:= 0
Local dDtVenc
Local aFiliais	:= {}
Local lTemCont := .F.
Local cNomFilAnt := ""
Local cFilialSE2	:= ""
Local nInc := 0    
Local aSM0 := {}
Local cPictTit := ""
Local nGerTot := 0
Local nFilTot := 0
Local nAuxTotFil := 0
Local nRecnoSE2 := 0

Local aTotFil :={}
local lQryEmp := .F.
Local nI := 0
Local dUltBaixa	:= STOD("")
Local nCont	:= 0
Local nTamFil	:= FWSizeFilial()
Local lExistFJU := FJU->(ColumnPos("FJU_RECPAI")) > 0 .and. FindFunction("FinGrvEx")
Local cCampos := ""
Local cQueryP := ""
#IFDEF TOP
	Local aStru := SE2->(dbStruct())
#ENDIF

/*
GESTAO - inicio */
Local nFilAtu		:= 0
Local nLenSelFil	:= 0
Local nTamUnNeg		:= 0
Local nTamEmp		:= 0
Local nTotEmp		:= 0
Local nTotEmpJ		:= 0
Local nTotEmp0		:= 0
Local nTotEmp1		:= 0
Local nTotEmp2		:= 0
Local nTotEmp3		:= 0
Local nTotEmp4		:= 0
Local nTotTitEmp	:= 0
Local cNomEmp		:= ""
Local cTmpFil		:= ""
Local cQryFilSE1	:= ""
Local cQryFilSE5	:= ""
Local lTotEmp		:= .F.
Local aTmpFil		:= {}
Local oBrkFil		:= Nil
Local oBrkEmp		:= Nil
Local oBrkNat		:= Nil
Local nBx			:= 0
Local xCodMoeda		:= Nil
/* GESTAO - fim
*/

Private dBaixa := dDataBase
Private cTitulo  := ""

cPictTit := PesqPict("SE2","E2_VALOR")
If cPaisLoc == "CHI"
	cPictTit := SubStr(cPictTit,1,At(".",cPictTit)-1)
EndIf   

/*
GESTAO - inicio */
If MV_PAR37 == 1
	If Empty(aSelFil)
		If  FindFunction("AdmSelecFil")
			AdmSelecFil("FIN150",37,.F.,@aSelFil,"SE2",.F.)
		Else
			aSelFil := AdmGetFil(.F.,.F.,"SE2")
			If Empty(aSelFil)
				Aadd(aSelFil,cFilAnt)
			Endif
		Endif
	Endif
Else
	Aadd(aSelFil,cFilAnt)
Endif
nLenSelFil := Len(aSelFil)
lTotFil := (nLenSelFil > 1)
nTamEmp := Len(FWSM0LayOut(,1))
nTamUnNeg := Len(FWSM0LayOut(,2))
lTotEmp := .F.
If nLenSelFil > 1
	nX := 1 
	While nX < nLenSelFil .And. !lTotEmp
		nX++
		lTotEmp := !(Substr(aSelFil[nX-1],1,nTamEmp) == Substr(aSelFil[nX],1,nTamEmp))
	Enddo
Else
	nTotTmp := .F.
Endif
cQryFilSE2 := GetRngFil( aSelFil, "SE2", .T., @cTmpFil)
Aadd(aTmpFil,cTmpFil)
cQryFilSE5 := GetRngFil( aSelFil, "SE5", .T., @cTmpFil)
Aadd(aTmpFil,cTmpFil)
/* GESTAO - fim
*/

//*******************************************************
// Solu?o para o problema no filtro de Serie minuscula *
//*******************************************************
//mv_par04 := LOWER(mv_par04)

oSection1:Cell("FORNECEDOR"	):SetBlock( { || aDados[FORNEC] 			})
oSection1:Cell("TITULO"		):SetBlock( { || aDados[TITUL] 				})
oSection1:Cell("E2_TIPO"	):SetBlock( { || aDados[TIPO] 					})
oSection1:Cell("E2_NATUREZ"	):SetBlock( { || MascNat(aDados[NATUREZA])})
oSection1:Cell("E2_EMISSAO"	):SetBlock( { || aDados[EMISSAO] 			})
oSection1:Cell("E2_VENCTO"	):SetBlock( { || aDados[VENCTO] 			})
oSection1:Cell("E2_VENCREA"	):SetBlock( { || aDados[VENCREA] 			})
oSection1:Cell("VAL_ORIG"	):SetBlock( { || aDados[VL_ORIG] 			})
oSection1:Cell("VAL_NOMI"	):SetBlock( { || aDados[VL_NOMINAL] 		})
oSection1:Cell("VAL_CORR"	):SetBlock( { || aDados[VL_CORRIG] 		})
oSection1:Cell("VAL_VENC"	):SetBlock( { || aDados[VL_VENCIDO] 		})
oSection1:Cell("E2_PORTADO"	):SetBlock( { || aDados[PORTADOR] 			})
oSection1:Cell("JUROS"		):SetBlock( { || aDados[VL_JUROS] 			})
oSection1:Cell("DIA_ATR"	):SetBlock( { || aDados[ATRASO] 				})
oSection1:Cell("E2_HIST"	):SetBlock( { || aDados[HISTORICO] 			})
oSection1:Cell("VAL_SOMA"	):SetBlock( { || aDados[VL_SOMA] 			})
oSection1:Cell("VLPA"	):SetBlock( { || aDados[VL_PA] 			})
oSection1:Cell("VAL_SOMA"):Disable()

TRPosition():New(oSection1,"SA2",1,{|| xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA })

//????????????????????????????????
//?Define as quebras da se?o, conforme a ordem escolhida.      ?
//????????????????????????????????
If nOrdem == 2	//Natureza
	oBreak := TRBreak():New(oSection1,{|| IIf(!MV_MULNATP,SE2->E2_NATUREZ,aDados[NATUREZA]) },{|| cNomNat })
	oBrkNat := oBreak
ElseIf nOrdem == 3	.Or. nOrdem == 6	//Vencimento e por Emissao
	oBreak  := TRBreak():New(oSection1,{|| IIf(nOrdem == 3,SE2->E2_VENCREA,SE2->E2_EMISSAO) },{|| STR0026 + DtoC(dDtVenc) })	//"S U B - T O T A L ----> "
	oBreak2 := TRBreak():New(oSection1,{|| IIf(nOrdem == 3,Month(SE2->E2_VENCREA),Month(SE2->E2_EMISSAO)) },{|| STR0030 + "("+ALLTRIM(STR(nTotTitMes))+" "+IIF(nTotTitMes > 1,OemToAnsi(STR0028),OemToAnsi(STR0029))+")" })		//"T O T A L   D O  M E S ---> "
	If mv_par20 == 1	//1- Analitico  2-Sintetico
		TRFunction():New(oSection1:Cell("VAL_ORIG"),"","SUM",oBreak2,,,,.F.,.F.)
		TRFunction():New(oSection1:Cell("VAL_NOMI"),"","SUM",oBreak2,,,,.F.,.F.)
		TRFunction():New(oSection1:Cell("VAL_CORR"),"","SUM",oBreak2,,,,.F.,.F.)
		TRFunction():New(oSection1:Cell("VAL_VENC"),"","SUM",oBreak2,,,,.F.,.F.)
		TRFunction():New(oSection1:Cell("JUROS"	  ),"","SUM",oBreak2,,,,.F.,.F.)
		TRFunction():New(oSection1:Cell("E2_HIST"),"","ONPRINT",oBreak2,,Iif(cPaisLoc == "CHI",cPictTit, PesqPict("SE2","E2_VALOR")),{|lSection,lReport| If(lReport, nTotGeral, nTotMes)},.F.,.F.)
	EndIf
ElseIf nOrdem == 4	//Banco
	oBreak := TRBreak():New(oSection1,{|| SE2->E2_PORTADO },{|| STR0026 + cNumBco })	//"S U B - T O T A L ----> "
ElseIf nOrdem == 5	//Fornecedor
	oBreak := TRBreak():New(oSection1,{|| SE2->(E2_FORNECE+E2_LOJA) },{|| cNomFor })
ElseIf nOrdem == 7	//Codigo Fornecedor
	oBreak := TRBreak():New(oSection1,{|| SE2->E2_FORNECE },{|| cNomFor })	
EndIf                                                                       


//??????????????????????
//?Imprimir TOTAL por filial somente quando ?
//?houver mais do que uma filial.	         ?
//??????????????????????
If SM0->(Reccount()) > 1 .And. nLenSelFil > 1
	If nOrdem  == 3 .Or. nOrdem == 6
		oSection2:Cell("FILIAL"	)	:SetBlock( { || aTotFil[ni,1] + aTotFil[ni,9]})
		oSection2:Cell("VALORORIG")	:SetBlock( { || aTotFil[ni,2]})
		oSection2:Cell("VALORNOMI")	:SetBlock( { || aTotFil[ni,3]})
		oSection2:Cell("VALORCORR")	:SetBlock( { || aTotFil[ni,4]})
		oSection2:Cell("VALORVENC")	:SetBlock( { || aTotFil[ni,5]})
		oSection2:Cell("JUROS")		:SetBlock( { || aTotFil[ni,8]})
		oSection2:Cell("VALORSOMA")	:SetBlock( { || aTotFil[ni,4] + aTotFil[ni,5]})

		TRPosition():New(oSection2,"SM0",1,{|| xFilial("SM0")+SM0->M0_CODIGO+	SM0->M0_CODFIL })
	Else
		oBreak2 := TRBreak():New(oSection1,{|| SE2->E2_FILIAL },{|| STR0032+" "+cNomFil })	//"T O T A L   F I L I A L ----> " 
		If mv_par20 == 1	//1- Analitico  2-Sintetico
			TRFunction():New(oSection1:Cell("VAL_ORIG"),"","SUM",oBreak2,,,,.F.,.F.)
			TRFunction():New(oSection1:Cell("VAL_NOMI"),"","SUM",oBreak2,,,,.F.,.F.)
			TRFunction():New(oSection1:Cell("VAL_CORR"),"","SUM",oBreak2,,,,.F.,.F.)
			TRFunction():New(oSection1:Cell("VAL_VENC"),"","SUM",oBreak2,,,,.F.,.F.)
			TRFunction():New(oSection1:Cell("JUROS"	  ),"","SUM",oBreak2,,,,.F.,.F.)
			//nTotGeral nao estava imprimindo corretamente o totalizador por isso foi necessario o ajuste abaixo
			//embora seja estranho mas neste caso foi necessario inicializar a variavel nFilTot:=0 no break 
			//por isso salvei o conteudo na variavel nAuxTotFil antes de inicializar e depois imprimo nAuxTotFil
			TRFunction():New(oSection1:Cell("E2_HIST"),"","ONPRINT",oBreak2,,Iif(cPaisLoc == "CHI",cPictTit, PesqPict("SE2","E2_VALOR")),{|lSection,lReport| If(lReport, ( nAuxTotFil:=nFilTot,nFilTot:=0,nAuxTotFil )/*nTotGeral*/, nTotFil)},.F.,.F.)
		EndIf
	EndIf 
EndIf

/*
GESTAO - inicio */
/* quebra por empresa */
If lTotEmp .And. MV_MULNATP .And. nOrdem == 2 
	oBrkEmp := TRBreak():New(oSection1,{|| Substr(SE2->E2_FILIAL,1,nTamEmp)},{|| STR0064 + " " + cNomEmp })		//"T O T A L  E M P R E S A -->" 
	// "Salta pagina por cliente?" igual a "Sim" e a ordem eh por cliente ou codigo do cliente
/*	If mv_par35 == 1 .And. (nOrdem == 1 .Or. nOrdem == 8)
		oBrkEmp:OnPrintTotal( { || oReport:EndPage() } )	// Finaliza pagina atual
	Else
		oBrkEmp:OnPrintTotal( { || oReport:SkipLine()} )
	EndIf*/
	If mv_par20 == 1	//1- Analitico  2-Sintetico
		TRFunction():New(oSection1:Cell("VAL_ORIG"),"","SUM",oBrkEmp,,,,.F.,.F.)
		TRFunction():New(oSection1:Cell("VAL_NOMI"),"","SUM",oBrkEmp,,,,.F.,.F.)
		TRFunction():New(oSection1:Cell("VAL_CORR"),"","SUM",oBrkEmp,,,,.F.,.F.)
		TRFunction():New(oSection1:Cell("VAL_VENC"),"","SUM",oBrkEmp,,,,.F.,.F.)
		TRFunction():New(oSection1:Cell("JUROS"	  ),"","SUM",oBrkEmp,,,,.F.,.F.)
		TRFunction():New(oSection1:Cell("VAL_SOMA"),"","ONPRINT",oBrkEmp,,PesqPict("SE2","E2_VALOR"),{|lSection,lReport| If(lReport, nTotGeral, nTotEmp)},.F.,.F.)
	EndIf
Endif
/* GESTAO - fim 
*/

If mv_par20 == 1	//1- Analitico  2-Sintetico
	//Altero o texto do Total Geral
	oReport:SetTotalText({|| STR0027 + "(" + ALLTRIM(STR(nTotTit))+" "+If(nTotTit > 1,STR0028,STR0029)+")" })
	TRFunction():New(oSection1:Cell("VAL_ORIG"),"","SUM",oBreak,,,,.F.,.T.)
	TRFunction():New(oSection1:Cell("VAL_NOMI"),"","SUM",oBreak,,,,.F.,.T.)
	TRFunction():New(oSection1:Cell("VAL_CORR"),"","SUM",oBreak,,,,.F.,.T.)
	TRFunction():New(oSection1:Cell("VAL_VENC"),"","SUM",oBreak,,,,.F.,.T.)
	TRFunction():New(oSection1:Cell("JUROS"	  ),"","SUM",oBreak,,,,.F.,.T.)
	//nTotGeral nao estava imprimindo corretamente o totalizador por isso foi necessario o ajuste abaixo
	//portanto foi criado a variavel nGerTot que eh o acumulador geral da coluna
	TRFunction():New(oSection1:Cell("E2_HIST"),"","ONPRINT",oBreak,,Iif(cPaisLoc == "CHI",cPictTit, PesqPict("SE2","E2_VALOR")),{|lSection,lReport| If(lReport, nGerTot/*nTotGeral*/, nTotVenc)},.F.,.T.)
EndIf

#IFDEF TOP
	IF TcSrvType() == "AS/400" .and. Select("__SE2") == 0
		ChkFile("SE2",.f.,"__SE2")
	Endif
#ENDIF

dbSelectArea ( "SE2" )
Set Softseek On

If mv_par37 == 2
	cFilDe  := cFilAnt
	cFilAte := cFilAnt
Endif

//Acerta a database de acordo com o parametro
If mv_par21 == 1    // Considera Data Base
	dDataBase := mv_par33
Endif	

dbSelectArea("SM0")

nRegSM0 := SM0->(Recno())
nAtuSM0 := SM0->(Recno())

//Caso nao preencha o mv_par15 um erro ocorre ao procurar o parametro do sistema MV_MOEDA0.
If Val(cMoeda) == 0
	cMoeda := "1"
Endif

xCodMoeda :=  GetMv("MV_MOEDA"+cMoeda)
cTitulo := oReport:title()
cTitAux := cTitulo
            
// Cria vetor com os codigos das filiais da empresa corrente                     
aFiliais := FinRetFil()

oSection1:Init()      

aSM0	:= AdmAbreSM0()

/*
GESTAO - inicio */
If nLenSelFil == 0
	// Cria vetor com os codigos das filiais da empresa corrente
	aFiliais := FinRetFil()
	lContinua := SM0->(!Eof()) .And. SM0->M0_CODIGO == cEmpAnt .and. IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ) <= cFilAte
Else
	aFiliais := Aclone(aSelFil)
	cFilDe := aSelFil[1]
	cFilAte := aSelFil[nLenSelFil]
	nFilAtu := 1
	lContinua := nFilAtu <= nLenSelFil
	aSM0 := FWLoadSM0()
Endif
/* GESTAO - fim 
*/

nInc := 1

While nInc <= Len( aSM0 )
	
	If !Empty(cFilAte) .AND. aSM0[nInc][1] == cEmpAnt .AND. (aSM0[nInc][2] >= cFilDe .and. aSM0[nInc][2] <= cFilAte) .and. lContinua
		
		//UTILIZADO PARA VALIDAR AS FILIAIS SELECIONADAS PELO USUARIO.
		If Ascan(aSelFil,aSM0[nInc][2]) == 0
			nInc++
			Loop						
		Endif
		
		cTitulo += " " + STR0035 + xCodMoeda //"Posicao dos Titulos a Pagar" + " em "
	
		dbSelectArea("SE2")
		/*
		GESTAO - inicio */
		If nLenSelFil > 0
			nPosFil := aScan( aSM0 ,{ | sm0 | sm0[SM0_GRPEMP] + sm0[SM0_CODFIL] == aSM0[nInc][1] + aSelFil[nFilAtu] } )
			If nPosFil > 0
				SM0->( DbGoTo( aSM0[nPosFil,SM0_RECNO] ) )
			Else
				SM0->( MsSeek( cEmpAnt + aSelFil[nFilAtu] ) )
			EndIf
		EndIf
		cFilAnt := aSM0[nInc][2]
		/* GESTAO - fim
		*/ 
		
		IF cFilialSE2 == xFilial("SE2")
			Loop
		ELSE
			cFilialSE2 := xFilial("SE2")
		ENDIF
			
		#IFDEF TOP
				cFilterUser := oSection1:GetSqlExp("SE2")
				if TcSrvType() != "AS/400"
					cQueryP := ""
					cCampos := ""
					aEval(SE2->(DbStruct()),{|e| If(e[2]<> "M", cCampos += ",SE2."+AllTrim(e[1]),Nil)})
					cCampos += ",SE2.R_E_C_N_O_, SE2.R_E_C_D_E_L_, SE2.D_E_L_E_T_ " 
					cQuery := "SELECT " + SubStr(cCampos,2)
					cQuery += "  FROM "+	RetSqlName("SE2")+ " SE2"
					/*
					GESTAO - inicio 
					*/
						cQuery += " WHERE SE2.E2_FILIAL = '" + xFilial("SE2") + "' "
					/* GESTAO - fim
					*/
					cQuery += "   AND D_E_L_E_T_ = ' ' " 
					If !empty(cFilterUser)
					  	cQueryP += " AND ( "+cFilterUser + " ) "
					Endif
				endif
		#ENDIF
	
		IF nOrdem == 1
			SE2->(dbSetOrder(1))
			#IFDEF TOP
				if TcSrvType() == "AS/400"
					dbSeek(xFilial("SE2")+mv_par03+mv_par01,.T.)
				else
					cOrder := SqlOrder(indexkey())
				endif
			#ELSE
				dbSeek(xFilial("SE2")+mv_par03+mv_par01,.T.)
			#ENDIF
			cCond1 := "SE2->E2_PREFIXO <= mv_par04"
			cCond2 := "SE2->E2_PREFIXO"
			cTitulo += OemToAnsi(STR0016)  //" - Por Numero"
			nQualIndice := 1
		Elseif nOrdem == 2
			SE2->(dbSetOrder(2))
			#IFDEF TOP
				if TcSrvType() == "AS/400"
					dbSeek(xFilial("SE2")+mv_par05,.T.)
				else
					cOrder := SqlOrder(indexkey())
				endif
			#ELSE
				dbSeek(xFilial("SE2")+mv_par05,.T.)
			#ENDIF
			cCond1 := "SE2->E2_NATUREZ <= mv_par06"
			cCond2 := "SE2->E2_NATUREZ"
			cTitulo += STR0017  //" - Por Natureza"
			nQualIndice := 2
		Elseif nOrdem == 3
			SE2->(dbSetOrder(3))
			#IFDEF TOP
				if TcSrvType() == "AS/400"
					dbSeek(xFilial("SE2")+Dtos(mv_par07),.T.)
				else
					cOrder := SqlOrder(indexkey())
				endif
			#ELSE
				dbSeek(xFilial("SE2")+Dtos(mv_par07),.T.)
			#ENDIF
			cCond1 := "SE2->E2_VENCREA <= mv_par08"
			cCond2 := "SE2->E2_VENCREA"
			cTitulo += STR0018  //" - Por Vencimento"
			nQualIndice := 3
		Elseif nOrdem == 4
			SE2->(dbSetOrder(4))
			#IFDEF TOP
				if TcSrvType() == "AS/400"
					dbSeek(xFilial("SE2")+mv_par09,.T.)
				else
					cOrder := SqlOrder(indexkey())
				endif
			#ELSE
				dbSeek(xFilial("SE2")+mv_par09,.T.)
			#ENDIF
			cCond1 := "SE2->E2_PORTADO <= mv_par10"
			cCond2 := "SE2->E2_PORTADO"
			cTitulo += OemToAnsi(STR0031)  //" - Por Banco"
			nQualIndice := 4
		Elseif nOrdem == 6
			SE2->(dbSetOrder(5))
			#IFDEF TOP
				if TcSrvType() == "AS/400"
					dbSeek(xFilial("SE2")+DTOS(mv_par13),.T.)
				else
					cOrder := SqlOrder(indexkey())
				endif
			#ELSE
				dbSeek(xFilial("SE2")+DTOS(mv_par13),.T.)
			#ENDIF
			cCond1 := "SE2->E2_EMISSAO <= mv_par14"
			cCond2 := "SE2->E2_EMISSAO"
			cTitulo += STR0019 //" - Por Emissao"
			nQualIndice := 5
		Elseif nOrdem == 7
			SE2->(dbSetOrder(6))
			#IFDEF TOP
				if TcSrvType() == "AS/400"
					dbSeek(xFilial("SE2")+mv_par11,.T.)
				else
					cOrder := SqlOrder(indexkey())
				endif
			#ELSE
				dbSeek(xFilial("SE2")+mv_par11,.T.)
			#ENDIF			
			cCond1 := "SE2->E2_FORNECE <= mv_par12"
			cCond2 := "SE2->E2_FORNECE"
			cTitulo += STR0020 //" - Por Cod.Fornecedor"
			nQualIndice := 6
		Else
			cChaveSe2 := "E2_FILIAL+E2_NOMFOR+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO"
			#IFDEF TOP
				if TcSrvType() == "AS/400"
					cIndexSe2 := CriaTrab(nil,.f.)
					IndRegua("SE2",cIndexSe2,cChaveSe2,,u_Fr150IndR(),OemToAnsi(STR0021))  // //"Selecionando Registros..."
					nIndexSE2 := RetIndex("SE2")
					dbSetOrder(nIndexSe2+1)
					dbSeek(xFilial("SE2"))
				else
					cOrder := SqlOrder(cChaveSe2)
				endif
			#ELSE
				cIndexSe2 := CriaTrab(nil,.f.)
				IndRegua("SE2",cIndexSe2,cChaveSe2,,u_Fr150IndR(),OemToAnsi(STR0021))  // //"Selecionando Registros..."
				nIndexSE2 := RetIndex("SE2")
				dbSetIndex(cIndexSe2+OrdBagExt())
				dbSetOrder(nIndexSe2+1)
				dbSeek(xFilial("SE2"))
			#ENDIF
			cCond1 := "SE2->E2_FORNECE <= mv_par12"
			cCond2 := "SE2->E2_FORNECE+SE2->E2_LOJA"
			cTitulo += STR0022 //" - Por Fornecedor"
			nQualIndice := IndexOrd()
		EndIF
	
		If mv_par20 == 1	//1- Analitico  2-Sintetico	
			cTitulo += STR0023  //" - Analitico"
		Else
			cTitulo += STR0024  // " - Sintetico"
		EndIf
	
		oReport:SetTitle(cTitulo)
		cTitulo := cTitAux
		
		dbSelectArea("SE2")
	
		Set Softseek Off
	
		#IFDEF TOP
			if TcSrvType() != "AS/400"
				cQueryP += " AND SE2.E2_NUM     BETWEEN '"+ mv_par01+ "' AND '"+ mv_par02 + "'"
				cQueryP += " AND SE2.E2_PREFIXO BETWEEN '"+ mv_par03+ "' AND '"+ mv_par04 + "'"
				cQueryP += " AND (SE2.E2_MULTNAT = '1' OR (SE2.E2_NATUREZ BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'))"
				cQueryP += " AND SE2.E2_VENCREA BETWEEN '"+ DTOS(mv_par07)+ "' AND '"+ DTOS(mv_par08) + "'"
				cQueryP += " AND SE2.E2_PORTADO BETWEEN '"+ mv_par09+ "' AND '"+ mv_par10 + "'"
				cQueryP += " AND SE2.E2_FORNECE BETWEEN '"+ mv_par11+ "' AND '"+ mv_par12 + "'"
				cQueryP += " AND SE2.E2_EMISSAO BETWEEN '"+ DTOS(mv_par13)+ "' AND '"+ DTOS(mv_par14) + "'"
				cQueryP += " AND SE2.E2_LOJA    BETWEEN '"+ mv_par25 + "' AND '"+ mv_par26 + "'"
	
				//Considerar titulos cuja emissao seja maior que a database do sistema
				If mv_par36 == 2
					cQueryP += " AND SE2.E2_EMISSAO <= '" + DTOS(dDataBase) +"'"
				Endif
		
				If !Empty(mv_par30) // Deseja imprimir apenas os tipos do parametro 30
					cQueryP += " AND SE2.E2_TIPO IN "+FormatIn(mv_par30,";") 
				ElseIf !Empty(Mv_par31) // Deseja excluir os tipos do parametro 31
					cQueryP += " AND SE2.E2_TIPO NOT IN "+FormatIn(mv_par31,";")
				EndIf
				If mv_par32 == 1
					cQueryP += " AND SE2.E2_FLUXO <> 'N'"
				Endif
				
				cQueryP += " AND SE2.E2_TIPO NOT IN "+FormatIn(MVABATIM,";")
				
				If mv_par16 == 2
					cQueryP += " AND SE2.E2_TIPO NOT IN "+FormatIn(MVPROVIS,";")			
				Endif
				
				If mv_par27 == 2
					cQueryP += " AND SE2.E2_TIPO NOT IN "+FormatIn(MVPAGANT,";")			 
					cQueryP += " AND SE2.E2_TIPO NOT IN "+FormatIn(MV_CPNEG,";")			
				Endif		
				If mv_par39 == 2
					cQueryP += " AND SE2.E2_TIPO NOT IN ('PRE') "	
				endif
				cQuery += cQueryP
				If lExistFJU
					If MV_PAR38 == 1
				    	if TcSrvType() != "AS/400"
							cQuery += " AND SE2.R_E_C_N_O_ NOT IN (SELECT PAI.FJU_RECPAI FROM "+ RetSqlName("FJU")+" PAI " 
							cQuery += " WHERE PAI.D_E_L_E_T_ = ' ' AND "
							cQuery += " PAI.FJU_CART = 'P' AND "
							cQuery += " PAI.FJU_DTEXCL >= '" + DTOS(dDataBase) + "' "
							cQuery += " AND PAI.FJU_EMIS1 <= '" + DTOS(dDataBase) + "') "			    		
					       cQuery += "UNION "
							
							cQuery += "SELECT " + SubStr(cCampos,2)
							cQuery += " FROM "+ RetSqlName("SE2")+" SE2,"+ RetSqlName("FJU") +" FJU"
							cQuery += " WHERE SE2.E2_FILIAL = '" + xFilial("SE2") + "'"
							cQuery += " AND FJU.FJU_FILIAL	 = '" + xFilial("FJU") + "'"
							cQuery += " AND SE2.E2_PREFIXO 	= FJU.FJU_PREFIX "
							cQuery += " AND SE2.E2_NUM 		= FJU.FJU_NUM "
							cQuery += " AND SE2.E2_PARCELA 	= FJU.FJU_PARCEL "
							cQuery += " AND SE2.E2_TIPO 	= FJU.FJU_TIPO "
							cQuery += " AND SE2.E2_FORNECE	= FJU.FJU_CLIFOR "
							cQuery += " AND SE2.E2_LOJA 	= FJU.FJU_LOJA "
							cQuery += " AND FJU.FJU_EMIS   <= '" + DTOS(dDataBase) +"'"
							cQuery += " AND FJU.FJU_DTEXCL >= '" + DTOS(dDataBase) +"'"
							cQuery += " AND FJU.FJU_CART = 'P' "
							cQuery += " AND SE2.R_E_C_N_O_ = FJU.FJU_RECORI "
							cQuery += " AND FJU.FJU_RECORI IN ( SELECT MAX(FJU_RECORI) "
	     
							cQuery +=   "FROM "+ RetSqlName("FJU")+" LASTFJU "
							cQuery +=   "WHERE LASTFJU.FJU_FILIAL = FJU.FJU_FILIAL "
							cQuery +=   "AND LASTFJU.FJU_PREFIX = FJU.FJU_PREFIX "
							cQuery +=   "AND LASTFJU.FJU_NUM = FJU.FJU_NUM "
							cQuery +=   "AND LASTFJU.FJU_PARCEL = FJU.FJU_PARCEL "
							cQuery +=   "AND LASTFJU.FJU_TIPO = FJU.FJU_TIPO "
							cQuery +=   "AND LASTFJU.FJU_CLIFOR = FJU.FJU_CLIFOR "
							cQuery +=   "AND LASTFJU.FJU_LOJA = FJU.FJU_LOJA "	
					    	cQuery +=   "AND FJU.FJU_DTEXCL = LASTFJU.FJU_DTEXCL "
							    
							cQuery +=   "GROUP BY FJU_FILIAL "
							cQuery +=   ",FJU_PREFIX "
							cQuery +=   ",FJU_NUM "
							cQuery +=   ",FJU_PARCEL "
							cQuery +=   ",FJU_CLIFOR "
							cQuery +=   ",FJU_LOJA ) "
	      
							cQuery += " AND SE2.D_E_L_E_T_ = '*' " 
							cQuery += " AND FJU.D_E_L_E_T_ = ' ' " 
							
							cQuery += " AND " 
							cQuery += " (SELECT COUNT(*) " 
							cQuery += " FROM "+ RetSqlName("SE2")+" NOTDEL " 
							cQuery += " WHERE NOTDEL.E2_FILIAL = FJU.FJU_FILIAL "         
							cQuery += " AND NOTDEL.E2_PREFIXO = FJU.FJU_PREFIX     "      
							cQuery += " AND NOTDEL.E2_NUM = FJU.FJU_NUM            "
							cQuery += " AND NOTDEL.E2_PARCELA = FJU.FJU_PARCEL      "        
							cQuery += " AND NOTDEL.E2_TIPO = FJU.FJU_TIPO "        
							cQuery += " AND NOTDEL.E2_FORNECE = FJU.FJU_CLIFOR       "     
							cQuery += " AND NOTDEL.E2_LOJA = FJU.FJU_LOJA  	"
							cQuery += " AND FJU.FJU_RECPAI = 0 "
							cQuery += " AND NOTDEL.E2_EMIS1   <= '" + DTOS(dDataBase) +"'"
							cQuery += " AND NOTDEL.D_E_L_E_T_ = '') = 0 " 
							 
							cQuery += " AND FJU.FJU_RECORI NOT IN (SELECT PAI.FJU_RECPAI FROM "+ RetSqlName("FJU")+" PAI " 
							cQuery += " WHERE PAI.D_E_L_E_T_ = ' ' AND "
							cQuery += " PAI.FJU_CART = 'P' AND "
							cQuery += " PAI.FJU_DTEXCL >= '" + DTOS(dDataBase) + "' "
							cQuery += " AND PAI.FJU_EMIS1 <= '" + DTOS(dDataBase) + "') "			    		
							 
							cQuery += cQueryP
						Endif	
					Endif	
				Endif									
	
				cQuery += " ORDER BY "+ cOrder
	
				cQuery := ChangeQuery(cQuery)	
				dbSelectArea("SE2")
				dbCloseArea()
				dbSelectArea("SA2")
	
				dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SE2', .F., .T.)
	
				For ni := 1 to Len(aStru)
					If aStru[ni,2] != 'C'
						TCSetField('SE2', aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
					Endif
				Next
			endif
		#ELSE
			cFilterUser := oSection1:GetADVPLExp("SE2")
			
			If !Empty(cFilterUser)
				oSection1:SetFilter(cFilterUser)
			Endif	
		#ENDIF
		
		oReport:SetMeter(nTotsRec)
	
		If MV_MULNATP .And. nOrdem == 2
		/*
		GESTAO - inicio */
		If nLenSelFil == 0
			Finr155(cFr150Flt, .F., @nTot0, @nTot1, @nTot2, @nTot3, @nTotTit, @nTotJ, oReport, aDados, @cNomNat, @nTotVenc, @nTotGeral)
		Else
			cTitBkp := cTitulo
			Finr155(cFr150Flt, .F., @nTotFil0, @nTotFil1, @nTotFil2, @nTotFil3, @nTotFilTit, @nTotFilJ, oReport, aDados, @cNomNat, @nTotVenc, @nTotGeral)
			nTot0 += nTotFil0
			nTot1 += nTotFil1
			nTot2 += nTotFil2
			nTot3 += nTotFil3
			nTot4 += nTotFil4
			nTotJ += nTotFilJ
			nTotTit += nTotFilTit
			cNomFil := cFilAnt + " - " + AllTrim(SM0->M0_FILIAL)
			cNomEmp := Substr(cFilAnt,1,nTamEmp) + " - " + AllTrim(SM0->M0_NOMECOM)
			cTitulo := cTitBkp
		Endif
		/* GESTAO - fim
		*/
			#IFDEF TOP
				if TcSrvType() != "AS/400"
					dbSelectArea("SE2")
					dbCloseArea()
					ChKFile("SE2")
					dbSetOrder(1)
				endif
			#ENDIF
			/*
			GESTAO - inicio */
			If nLenSelFil == 0
				dbSelectArea("SM0")
				dbSkip()
				lContinua := SM0->(!Eof()) .And. SM0->M0_CODIGO == cEmpAnt .and. IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ) <= cFilAte
			Else
				nFilAtu++
				lContinua := (nFilAtu <= nLenSelFil)
				If lContinua
					If oBrkNat:Execute()
						oBrkNat:PrintTotal()
					Endif
					If nTotFil0 <> 0
						oBrkFil := oBreak
						If oBrkFil:Execute()
							oBrkFil:PrintTotal()
						Endif
					Endif
					Store 0 To nTotFil0,nTotFil1,nTotFil2,nTotFil3,nTotFil4,nTotFilTit,nTotFilJ
					If !(Substr(aSelFil[nFilAtu-1],1,nTamEmp) == Substr(aSelFil[nFilAtu],1,nTamEmp))
						If nTotEmp0 <> 0
							oBrkEmp:PrintTotal()
						Endif
						nTotEmp0 := 0
						nTotEmp1 := 0
						nTotEmp2 := 0
						nTotEmp3 := 0
						nTotEmp4 := 0
						nTotEmpJ := 0
						nTotTitEmp := 0
					Endif
				Endif
			Endif
			/* GESTAO - fim
			*/
			If Empty(xFilial("SE2")) .and. mv_par22 = 2
				Exit
			Endif
			Loop
		Endif  
		
		lQryEmp := Eof()
		
		While &cCond1 .and. !Eof() .and. lContinua .and. SE2->E2_FILIAL == xFilial("SE2")
		
			oReport:IncMeter()
	
			dbSelectArea("SE2")
	
			Store 0 To nTit1,nTit2,nTit3,nTit4,nTit5
	
			If nOrdem == 3 .And. Str(Month(SE2->E2_VENCREA)) <> Str(Month(dDataAnt))
				nMesTTit := 0
			Elseif nOrdem == 6 .And. Str(Month(SE2->E2_EMISSAO)) <> Str(Month(dDataAnt))
				nMesTTit := 0
			EndIf
			
			//?????????????????????
			//?Carrega data do registro para permitir ?
			//?posterior analise de quebra por mes.   ?
			//?????????????????????
			dDataAnt := Iif(nOrdem == 3, SE2->E2_VENCREA, SE2->E2_EMISSAO)
	
			cCarAnt := &cCond2
	        
			lTemCont := .F.
//			Store 0 To nFil0,nFil1,nFil2,nFil3,nFil4,nFilTit,nFilJ
			While &cCond2 == cCarAnt .and. !Eof() .and. lContinua .and. SE2->E2_FILIAL == xFilial("SE2")
				
				oReport:IncMeter()
	
				//????????????????????????????
				//?Filtro de usu?io pela tabela SA2.					 ?
				//????????????????????????????
				dbSelectArea("SA2")
				MsSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA)
				If !Empty(cFilUserSA2).And.!SA2->(&cFilUserSA2)
					SE2->(dbSkip())
					Loop
				Endif
				
				dbSelectArea("SE2")
	
				//????????????????????????????????
				//?Considera filtro do usuario no ponto de entrada.             ?
				//????????????????????????????????
				If lFr150flt
					If &cFr150flt
						DbSkip()
						Loop
					Endif
				Endif					
				
				#IFNDEF TOP			
				
				//????????????????????????????
				//?Verifica se trata-se de abatimento ou provisorio, ou ?
				//?Somente titulos emitidos ate a data base				   ?
				//????????????????????????????
				IF SE2->E2_TIPO $ MVABATIM .Or. (SE2 -> E2_EMISSAO > dDataBase .and. mv_par36 == 2)
					dbSkip()
					Loop
				EndIF
				//????????????????????????????
				//?Verifica se ser?impresso titulos provis?ios		   ?
				//????????????????????????????
				IF E2_TIPO $ MVPROVIS .and. mv_par16 == 2
					dbSkip()
					Loop
				EndIF                
				IF E2_TIPO $ 'PRE' .and. mv_par16 == 2
					dbSkip()
					Loop
				EndIF
				//????????????????????????????
				//?Verifica se ser?impresso titulos de Adiantamento	 	?
				//????????????????????????????
				IF SE2->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG .and. mv_par27 == 2
					dbSkip()
					Loop
				EndIF
	                                   
	            #ENDIF
	            
				//?????????????????????
				//?Verifica se deve imprimir outras moedas?
				//?????????????????????
				If mv_par29 == 2 // nao imprime
					if SE2->E2_MOEDA != mv_par15 //verifica moeda do campo=moeda parametro
						dbSkip()
						Loop
					endif	
				Endif  
	
				// dDtContab para casos em que o campo E2_EMIS1 esteja vazio
				// compatibilizando com a vers? 2.04 que n? gerava para titulos
				// de ISS e FunRural
	
				dDtContab := Iif(Empty(SE2->E2_EMIS1),SE2->E2_EMISSAO,SE2->E2_EMIS1)
	
				//?????????????????????
				//?Verifica se esta dentro dos parametros ?
				//?????????????????????
				IF E2_NUM < mv_par01      .OR. E2_NUM > mv_par02 .OR. ;
						E2_PREFIXO < mv_par03  .OR. E2_PREFIXO > mv_par04 .OR. ;
						E2_NATUREZ < mv_par05  .OR. E2_NATUREZ > mv_par06 .OR. ;
						E2_VENCREA < mv_par07  .OR. E2_VENCREA > mv_par08 .OR. ;
						E2_PORTADO < mv_par09  .OR. E2_PORTADO > mv_par10 .OR. ;
						E2_FORNECE < mv_par11  .OR. E2_FORNECE > mv_par12 .OR. ;
						E2_EMISSAO < mv_par13  .OR. E2_EMISSAO > mv_par14 .OR. ;
						(E2_EMISSAO > dDataBase .and. mv_par36 == 2) .OR. dDtContab  < mv_par18 .OR. ;
						E2_LOJA    < mv_par25  .OR. E2_LOJA    > mv_par26 .OR. ;
						dDtContab  > mv_par19  .Or. !&(u_fr150IndR())
	
					dbSkip()
					Loop
				Endif  
				
				
				//???????????????????????????????????
				//?Verifica se esta dentro do parametro compor pela data de digita?o ?
				//???????????????????????????????????
				IF mv_par34 == 2 .And. !Empty(E2_EMIS1) .And. !Empty(mv_par33)
					If E2_EMIS1 > mv_par33
						dbSkip()
						Loop
					Endif			
				Endif
							
	
				//????????????????????????????????
				//?Verifica se titulo, apesar do E2_SALDO = 0, deve aparecer ou ?
				//?n? no relat?io quando se considera database (mv_par21 = 1) ?
				//?ou caso n? se considere a database, se o titulo foi totalmen?
				//?te baixado.																  ?
				//????????????????????????????????
				dbSelectArea("SE2")
				IF !Empty(SE2->E2_BAIXA) .and. Iif(mv_par21 == 2 ,SE2->E2_SALDO == 0 ,SE2->E2_SALDO == 0 .and. SE2->E2_BAIXA <= dDataBase)						

					dbSkip()
					Loop
				EndIF
	            
				 // Tratamento da correcao monetaria para a Argentina
				If  cPaisLoc=="ARG" .And. mv_par15 <> 1  .And.  SE2->E2_CONVERT=='N'
					dbSkip()
					Loop
				Endif
	
				
				dbSelectArea("SA2")
				MSSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA)
				dbSelectArea("SE2")
	
				// Verifica se existe a taxa na data do vencimento do titulo, se nao existir, utiliza a taxa da database
				If SE2->E2_VENCREA < dDataBase
					If mv_par17 == 2 .And. RecMoeda(SE2->E2_VENCREA,cMoeda) > 0
						dDataReaj := SE2->E2_VENCREA
					Else
						dDataReaj := dDataBase
					EndIf	
				Else
					dDataReaj := dDataBase
				EndIf       
	
				If mv_par21 == 1
					nSaldo := SaldoTit(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_NATUREZ,"P",SE2->E2_FORNECE,mv_par15,dDataReaj,,SE2->E2_LOJA,,If(mv_par35==1,SE2->E2_TXMOEDA,Nil),IIF(mv_par34 == 2,3,1)) // 1 = DT BAIXA    3 = DT DIGIT
					//Verifica se existem compensa?es em outras filiais para descontar do saldo, pois a SaldoTit() somente
					//verifica as movimenta?es da filial corrente. Nao deve processar quando existe somente uma filial.
					If !Empty(xFilial("SE2")) .And. !Empty(xFilial("SE5"))
						nSaldo -= FRVlCompFil("P",SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_FORNECE,SE2->E2_LOJA,IIF(mv_par34 == 2,3,1),,,,mv_par15,SE2->E2_MOEDA,If(mv_par35==1,SE2->E2_TXMOEDA,Nil),dDataReaj,.T.)
					EndIf
					// Subtrai decrescimo para recompor o saldo na data escolhida.
					If Str(SE2->E2_VALOR,17,2) == Str(nSaldo,17,2) .And. SE2->E2_DECRESC > 0 .And. SE2->E2_SDDECRE == 0
						nSAldo -= SE2->E2_DECRESC
					Endif	
					// Soma Acrescimo para recompor o saldo na data escolhida.
					If Str(SE2->E2_VALOR,17,2) == Str(nSaldo,17,2) .And. SE2->E2_ACRESC > 0 .And. SE2->E2_SDACRES == 0
						nSAldo += SE2->E2_ACRESC
					Endif				
				Else
					nSaldo := xMoeda((SE2->E2_SALDO+SE2->E2_SDACRES-SE2->E2_SDDECRE),SE2->E2_MOEDA,mv_par15,dDataReaj,ndecs+1,If(mv_par35==1,SE2->E2_TXMOEDA,Nil))
				Endif
				If ! (SE2->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG) .And. ;
				   ! ( MV_PAR21 == 2 .And. nSaldo == 0 ) // nao deve olhar abatimento pois e zerado o saldo na liquidacao final do titulo
	
					//Quando considerar Titulos com emissao futura, eh necessario
					//colocar-se a database para o futuro de forma que a Somaabat()
					//considere os titulos de abatimento
					If mv_par36 == 1
						dOldData := dDataBase
						dDataBase := CTOD("31/12/40")
					Endif
	
					nSaldo-=SomaAbat(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,"P",mv_par15,dDataReaj,SE2->E2_FORNECE,SE2->E2_LOJA)
	
					If mv_par36 == 1
						dDataBase := dOldData
					Endif
				EndIf
	
				nSaldo:=Round(NoRound(nSaldo,3),2)
				//????????????????????????????
				//?Desconsidera caso saldo seja menor ou igual a zero   ?
				//????????????????????????????
				If nSaldo <= 0
					dbSkip()
					Loop
				Endif  
				//????????????????????????????
				//?Desconsidera os titulos de acordo com o parametro 
				//	considera filial e a tabela SE2 estiver compartilhada?
				//????????????????????????????				
				If MV_PAR22 == 1 .and. Empty(xFilial("SE2"))
					If !(SE2->E2_FILORIG >= mv_par23 .and. SE2->E2_FILORIG <= mv_par24) 
						dbSkip()
						Loop
					Endif			
				Endif 
	
				aDados[FORNEC] := SE2->E2_FORNECE+"-"+SE2->E2_LOJA+"-"+If(mv_par28 == 1, SA2->A2_NREDUZ, SA2->A2_NOME)
				aDados[TITUL]		:= SE2->E2_PREFIXO+"-"+SE2->E2_NUM+"-"+SE2->E2_PARCELA
				aDados[TIPO]		:= SE2->E2_TIPO
				aDados[NATUREZA]	:= SE2->E2_NATUREZ
				aDados[EMISSAO]	:= SE2->E2_EMISSAO
				aDados[VENCTO]		:= SE2->E2_VENCTO
				aDados[VENCREA]	:= SE2->E2_VENCREA
				aDados[VL_ORIG]	:= xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,mv_par15,SE2->E2_EMISSAO,ndecs+1,If(mv_par35==1,SE2->E2_TXMOEDA,Nil)) * If(SE2->E2_TIPO$MV_CPNEG+"/"+MVPAGANT, -1,1) 
	
				//Consulta pa em aberto ismael junior 29/06/2021
				cQuery := "SELECT ISNULL(SUM(E2_VALOR),0) VALORPA FROM " + RetSqlName("SE2") + " SE2 "
				cQuery += "WHERE E2_FORNECE = '" + SE2->E2_FORNECE + "' " 
				cQuery += "AND E2_LOJA = '" + SE2->E2_LOJA + "' " 
				cQuery += "AND E2_FILIAL = '" + SE2->E2_FILIAL + "' "
				cQuery += "AND E2_TIPO = 'PA' "
				cQuery += "AND E2_BAIXA = '' "
				cQuery += "AND SE2.D_E_L_E_T_ != '*' "
				//Se o alias estiver aberto, irei fechar, isso ajuda a evitar erros
				IF Select("TRB") <> 0
					TRB->(DbCloseArea())
				ENDIF
				TCQUERY cQuery NEW ALIAS "TRB"
				dbSelectArea("TRB")
				TRB->(dbGoTop())
				aDados[VL_PA]	:= TRB->VALORPA
				// Fim **********************
				#IFDEF TOP
					If TcSrvType() == "AS/400"
						dbSetOrder( nQualIndice )
					Endif
				#ELSE
					dbSetOrder( nQualIndice )
				#ENDIF
	
				If dDataBase > SE2->E2_VENCREA 		//vencidos
					aDados[VL_NOMINAL] := nSaldo * If(SE2->E2_TIPO$MV_CPNEG+"/"+MVPAGANT, -1,1) 
					nJuros := 0
					dBaixa := dDataBase
					
					// C?culo dos Juros retroativo.
					dUltBaixa := SE2->E2_BAIXA
					If MV_PAR21 == 1 // se compoem saldo retroativo verifico se houve baixas
						If !Empty(dUltBaixa) .And. dDataBase < dUltBaixa
							dUltBaixa := FR150DBX() // Ultima baixa at?DataBase
						EndIf
					EndIf
					
					dbSelectArea("SE2")
					nJuros := fa080Juros(mv_par15,nSaldo,"SE2",dUltBaixa)
			
					dbSelectArea("SE2")
					aDados[VL_CORRIG] := (nSaldo+nJuros) * If(SE2->E2_TIPO$MV_CPNEG+"/"+MVPAGANT, -1,1)
					If SE2->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG
						nTit0 -= xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,mv_par15,SE2->E2_EMISSAO,ndecs+1,If(mv_par35==1,SE2->E2_TXMOEDA,Nil))
						nTit1 -= nSaldo
						nTit2 -= nSaldo+nJuros
						nMesTit0 -= xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,mv_par15,SE2->E2_EMISSAO,ndecs+1,If(mv_par35==1,SE2->E2_TXMOEDA,Nil))
						nMesTit1 -= nSaldo
						nMesTit2 -= nSaldo+nJuros
					Else
						nTit0 += xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,mv_par15,SE2->E2_EMISSAO,ndecs+1,If(mv_par35==1,SE2->E2_TXMOEDA,Nil))
						nTit1 += nSaldo
						nTit2 += nSaldo+nJuros
						nMesTit0 += xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,mv_par15,SE2->E2_EMISSAO,ndecs+1,If(mv_par35==1,SE2->E2_TXMOEDA,Nil))
						nMesTit1 += nSaldo
						nMesTit2 += nSaldo+nJuros
					Endif
					nTotJur += (nJuros)
					nMesTitJ += (nJuros)
				Else				  //a vencer
					aDados[VL_VENCIDO] := nSaldo  * If(SE2->E2_TIPO$MV_CPNEG+"/"+MVPAGANT, -1,1) 
					If SE2->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG
						nTit0 -= xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,mv_par15,SE2->E2_EMISSAO,ndecs+1,If(mv_par35==1,SE2->E2_TXMOEDA,Nil))
						nTit3 -= nSaldo
						nTit4 -= nSaldo
						nMesTit0 -= xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,mv_par15,SE2->E2_EMISSAO,ndecs+1,If(mv_par35==1,SE2->E2_TXMOEDA,Nil))
						nMesTit3 -= nSaldo
						nMesTit4 -= nSaldo
					Else
						nTit0 += xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,mv_par15,SE2->E2_EMISSAO,ndecs+1,If(mv_par35==1,SE2->E2_TXMOEDA,Nil))
						nTit3 += nSaldo
						nTit4 += nSaldo
						nMesTit0 += xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,mv_par15,SE2->E2_EMISSAO,ndecs+1,If(mv_par35==1,SE2->E2_TXMOEDA,Nil))
						nMesTit3 += nSaldo
						nMesTit4 += nSaldo
					Endif
				Endif
	
				ADados[PORTADOR] := SE2->E2_PORTADO
	
				If nJuros > 0
					aDados[VL_JUROS] := nJuros
					nJuros := 0
				Endif
	
				IF dDataBase > SE2->E2_VENCREA
					nAtraso:=dDataBase-SE2->E2_VENCTO
					IF Dow(SE2->E2_VENCTO) == 1 .Or. Dow(SE2->E2_VENCTO) == 7
						IF Dow(dBaixa) == 2 .and. nAtraso <= 2
							nAtraso:=0
						EndIF
					EndIF
					nAtraso := If(nAtraso<0,0,nAtraso)
					IF nAtraso>0
						aDados[ATRASO] := nAtraso
					EndIF
				EndIF
				If mv_par20 == 1	//1- Analitico  2-Sintetico
					aDados[HISTORICO] := SUBSTR(SE2->E2_HIST,1,25)+If(SE2->E2_TIPO $ MVPROVIS,"*"," ")
					#IFDEF TOP					
						nRecnoSE2 := SE2->(R_E_C_N_O_)
					#ELSE
						nRecnoSE2 :=  SE2->(RECNO())
					#ENDIF
					DbChangeAlias("SE2","SE2QRY")
					DbChangeAlias("__SE2","SE2")
					SE2->(DBGoto(nRecnoSE2))
					oSection1:PrintLine()
					DbChangeAlias("SE2","__SE2")
					DbChangeAlias("SE2QRY","SE2")
					aFill(aDados,nil)
				EndIf
				cNomFil 	:= cFilAnt + " - " + AllTrim(aSM0[nInc][7])
				//?????????????????????
				//?Carrega data do registro para permitir ?
				//?posterior analise de quebra por mes.	 ?
				//?????????????????????
				dDataAnt := Iif(nOrdem == 3, SE2->E2_VENCREA, SE2->E2_EMISSAO)
	
				If nOrdem == 5		//Forncedor
					cNomFor := If(mv_par28 == 1,AllTrim(SA2->A2_NREDUZ),AllTrim(SA2->A2_NOME))+" "+Substr(SA2->A2_TEL,1,15)
	            ElseIf nOrdem == 7	//Codigo Fornecedor
					cNomFor :=	SA2->A2_COD+" "+SA2->A2_LOJA+" "+AllTrim(SA2->A2_NOME)+" "+Substr(SA2->A2_TEL,1,15)
				EndIf
				
				If nOrdem == 2		//Natureza
					dbSelectArea("SED")
					dbSetOrder(1)
					dbSeek(xFilial("SED")+SE2->E2_NATUREZ)
					cNomNat	:= MascNat(SED->ED_CODIGO)+" "+SED->ED_DESCRIC
				EndIf
				
				cNumBco	 := SE2->E2_PORTADO
				dDtVenc  := IIf(nOrdem == 3,SE2->E2_VENCREA,SE2->E2_EMISSAO)
				nTotVenc := nTit2+nTit3
				nTotMes	 := nMesTit2+nMesTit3
	
				SE2->(dbSkip())
	
				nTotTit ++
				nMesTTit ++
				nFiltit++
				nTit5 ++
				nTotTitEmp++		/* GESTAO */				
			EndDo
	
			If nTit5 > 0 .and. nOrdem != 1 .And. mv_par20 == 2	//1- Analitico  2-Sintetico	
				SubT150R(nTit0,nTit1,nTit2,nTit3,nTit4,nOrdem,cCarAnt,nTotJur,oReport,oSection1)
			EndIF
					
		   	nTotGeral  := nTotMes 
			nTotTitMes := nMesTTit
			nGerTot  += nTit2+nTit3
			nFilTot  += nTit2+nTit3
	
			If mv_par20 == 2	//1- Analitico  2-Sintetico	
				lQuebra := .F.
				If nOrdem == 3 .and. Month(SE2->E2_VENCREA) # Month(dDataAnt)
					lQuebra := .T.
				Elseif nOrdem == 6 .and. Month(SE2->E2_EMISSAO) # Month(dDataAnt)
					lQuebra := .T.
				Endif
				If lQuebra .And. nMesTTit # 0
					oReport:SkipLine()
					IMes150R(nMesTit0,nMesTit1,nMesTit2,nMesTit3,nMesTit4,nMesTTit,nMesTitJ,nTotTitMes,oReport,oSection1)
					oReport:SkipLine()
					nMesTit0 := nMesTit1 := nMesTit2 := nMesTit3 := nMesTit4 := nMesTTit := nMesTitj := 0
				Endif
			EndIf
					
			dbSelectArea("SE2")
	
			nTot0 += nTit0
			nTot1 += nTit1
			nTot2 += nTit2
			nTot3 += nTit3
			nTot4 += nTit4
			nTotJ += nTotJur
			
			/*
			GESTAO - inicio */
			nTotEmp0 += nTit0
			nTotEmp1 += nTit1
			nTotEmp2 += nTit2
			nTotEmp3 += nTit3
			nTotEmp4 += nTit4
			nTotEmpJ += nTotJur
			/* GESTAO - fim
			 */	
	
			nFil0 += nTit0
			nFil1 += nTit1
			nFil2 += nTit2
			nFil3 += nTit3
			nFil4 += nTit4
			nFilJ += nTotJur
			Store 0 To nTit0,nTit1,nTit2,nTit3,nTit4,nTit5,nTotJur
			
		Enddo					
	        
		nTotMes 	:= nTotVenc
		nTotFil 	:= nFil2 + nFil3
		nTotEmp 	+= nTotFil
		
		IF !lQryEmp .And. (nOrdem == 3 .OR. nOrdem == 6)
			aAdd(aTotFil,{aSM0[nInc][2],nFil0,nFil1,nFil2,nFil3,nFil4,nFilTit,nFilj,aSM0[nInc][7]})
		EndIf

		If mv_par20 == 2	//1- Analitico  2-Sintetico	
			if mv_par22 == 1 .and. Len(aSM0) > 1 
				oReport:SkipLine()
				IFil150R(nFil0,nFil1,nFil2,nFil3,nFil4,nFilTit,nFilj,oReport,oSection1,aSM0[nInc][7])
				Store 0 To nFil0,nFil1,nFil2,nFil3,nFil4,nFilTit,nFilJ
				oReport:SkipLine()			
			Endif	
		EndIf
		
		Store 0 To nFil0,nFil1,nFil2,nFil3,nFil4,nFilJ,nTotJur

		dbSelectArea("SE2")		// voltar para alias existente, se nao, nao funciona
		If Empty(xFilial("SE2"))
			Exit
		Endif
		#IFDEF TOP
			if TcSrvType() != "AS/400"
				dbSelectArea("SE2")
				dbCloseArea()
				ChKFile("SE2")
				dbSetOrder(1)
			endif
		#ENDIF
	
	EndIf
	nInc++
EndDo
	
SM0->(dbGoTo(nRegSM0))
cFilAnt := SM0->M0_CODFIL 


If mv_par20 == 2	//1- Analitico  2-Sintetico	
	If (nLenSelFil > 1) .Or. (mv_par22 == 1 .And. SM0->(Reccount()) > 1) 		
		oReport:ThinLine()  
		ImpT150R(nTot0,nTot1,nTot2,nTot3,nTot4,nTotTit,nTotJ,nTotTit,oReport,oSection1)
		oReport:SkipLine()
	Else
		ImpT150R(nTot0,nTot1,nTot2,nTot3,nTot4,nTotTit,nTotJ,nTotTit,oReport,oSection1)	
	EndIf
EndIf

oSection1:Finish()

IF nOrdem == 3 .OR. nOrdem == 6
	
	oSection2:Init()   
	For ni := 1 to Len(aTotFil)
		oSection2:printline()
	Next
	
	oSection2:Finish()
EndIf

#IFNDEF TOP
	dbSelectArea( "SE2" )
	dbClearFil()
	RetIndex( "SE2" )
	If !Empty(cIndexSE2)
		FErase (cIndexSE2+OrdBagExt())
	Endif
	dbSetOrder(1)
#ELSE
	if TcSrvType() != "AS/400"
		dbSelectArea("SE2")
		dbCloseArea()
		ChKFile("SE2")
		dbSetOrder(1)
		/*
		GESTAO - inicio */
		If !Empty(aTmpFil)
			For nBx := 1 To Len(aTmpFil)
				CtbTmpErase(aTmpFil[nBx])
			Next
		Endif
		/* GESTAO - fim
		*/
	else
		dbSelectArea( "SE2" )
		dbClearFil()
		RetIndex( "SE2" )
		If !Empty(cIndexSE2)
			FErase (cIndexSE2+OrdBagExt())
		Endif
		dbSetOrder(1)
	endif
#ENDIF	

//?????????????????????
//?Restaura empresa / filial original    ?
//?????????????????????
SM0->(dbGoto(nRegEmp))
cFilAnt := SM0->M0_CODFIL

//Acerta a database de acordo com a database real do sistema
If mv_par21 == 1    // Considera Data Base
	dDataBase := dOldDtBase
Endif	

Return


/*/
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??un?o	 ?ubT150R  ?Autor ?Wagner Xavier 		  ?Data ?01.06.92 ??
???????????????????????????????????????
??escri?o ?MPRIMIR SUBTOTAL DO RELATORIO 									  ??
???????????????????????????????????????
??intaxe e ?SubT150R()  															  ??
???????????????????????????????????????
??arametros?																			  ??
???????????????????????????????????????
??Uso		 ?Generico 																  ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
*/
user Function cSubT150R(nTit0,nTit1,nTit2,nTit3,nTit4,nOrdem,cCarAnt,nTotJur,oReport,oSection1)

Local cQuebra := ""

If nOrdem == 1 .Or. nOrdem == 3 .Or. nOrdem == 6
	cQuebra := STR0026 + DtoC(cCarAnt) //"S U B - T O T A L ----> "
ElseIf nOrdem == 2
	dbSelectArea("SED")
	dbSeek(xFilial("SED")+cCarAnt)
	cQuebra := cCarAnt +" "+SED->ED_DESCRIC
ElseIf nOrdem == 4
	cQuebra := STR0026 + cCarAnt //"S U B - T O T A L ----> "
Elseif nOrdem == 5
	cQuebra := If(mv_par28 == 1,SA2->A2_NREDUZ,SA2->A2_NOME)+" "+Substr(SA2->A2_TEL,1,15)
ElseIf nOrdem == 7
	cQuebra := SA2->A2_COD+" "+SA2->A2_LOJA+" "+SA2->A2_NOME+" "+Substr(SA2->A2_TEL,1,15)
Endif

HabiCel(oReport)

oSection1:Cell("FORNECEDOR"):SetBlock({|| cQuebra })
oSection1:Cell("VAL_NOMI"  ):SetBlock({|| nTit1   })
oSection1:Cell("VAL_CORR"  ):SetBlock({|| nTit2   })
oSection1:Cell("VAL_VENC"  ):SetBlock({|| nTit3   })
oSection1:Cell("JUROS"     ):SetBlock({|| nTotJur })
oSection1:Cell("VAL_SOMA"  ):SetBlock({|| nTit2+nTit3 })

oSection1:PrintLine()

Return(.T.)

/*/
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??un?o	 ?mpT150R  ?Autor ?Wagner Xavier 		  ?Data ?01.06.92 ??
???????????????????????????????????????
??escri?o ?MPRIMIR TOTAL DO RELATORIO 										  ??
???????????????????????????????????????
??intaxe e ?ImpT150R()	 															  ??
???????????????????????????????????????
??arametros?																			  ??
???????????????????????????????????????
??Uso		 ?Generico 																  ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
*/
STATIC Function ImpT150R(nTot0,nTot1,nTot2,nTot3,nTot4,nTotTit,nTotJ,nTotTit,oReport,oSection1)

HabiCel(oReport)

oSection1:Cell("FORNECEDOR"):SetBlock({|| STR0027 + "(" + ALLTRIM(STR(nTotTit))+" "+If(nTotTit > 1,STR0028,STR0029)+")" })
oSection1:Cell("VAL_NOMI"  ):SetBlock({|| nTot1 })
oSection1:Cell("VAL_CORR"  ):SetBlock({|| nTot2 })
oSection1:Cell("VAL_VENC"  ):SetBlock({|| nTot3 })
oSection1:Cell("JUROS"     ):SetBlock({|| nTotJ })
oSection1:Cell("VAL_SOMA"  ):SetBlock({|| nTot2+nTot3 })

oSection1:PrintLine()

Return(.T.)

/*/
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??un?o	 ?Mes150R  ?Autor ?Vinicius Barreira	  ?Data ?12.12.94 ??
???????????????????????????????????????
??escri?o ?MPRIMIR TOTAL DO RELATORIO - QUEBRA POR MES					  ??
???????????????????????????????????????
??intaxe e ?IMes150R()  															  ??
???????????????????????????????????????
??arametros?																			  ??
???????????????????????????????????????
??Uso		 ?Generico 																  ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
*/
STATIC Function IMes150R(nMesTit0,nMesTit1,nMesTit2,nMesTit3,nMesTit4,nMesTTit,nMesTitJ,nTotTitMes,oReport,oSection1)

HabiCel(oReport)

oSection1:Cell("FORNECEDOR"):SetBlock({|| STR0030 + "("+ALLTRIM(STR(nTotTitMes))+" "+IIF(nTotTitMes > 1,OemToAnsi(STR0028),OemToAnsi(STR0029))+")" })
oSection1:Cell("VAL_NOMI"  ):SetBlock({|| nMesTit1 })
oSection1:Cell("VAL_CORR"  ):SetBlock({|| nMesTit2 })
oSection1:Cell("VAL_VENC"  ):SetBlock({|| nMesTit3 })
oSection1:Cell("JUROS"     ):SetBlock({|| nMesTitJ })
oSection1:Cell("VAL_SOMA"  ):SetBlock({|| nMesTit2+nMesTit3 })

oSection1:PrintLine()

Return(.T.)

/*/
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??un?o	 ?IFil150R	?Autor ?Paulo Boschetti 	     ?Data ?01.06.92 ??
???????????????????????????????????????
??escri?o ?Imprimir total do relatorio										  ??
???????????????????????????????????????
??intaxe e ?IFil150R()																  ??
???????????????????????????????????????
??arametros?																			  ??
???????????????????????????????????????
??Uso      ?Generico				   									 			  ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
/*/
STATIC Function IFil150R(nFil0,nFil1,nFil2,nFil3,nFil4,nFilTit,nFilJ,oReport,oSection1,cFilSM0)

HabiCel(oReport)

oSection1:Cell("FORNECEDOR"):SetBlock({|| STR0032 + " " + cFilAnt + " - " + AllTrim(cFilSM0) })	//"T O T A L   F I L I A L ----> " 
oSection1:Cell("VAL_NOMI"  ):SetBlock({|| nFil1 })
oSection1:Cell("VAL_CORR"  ):SetBlock({|| nFil2 })
oSection1:Cell("VAL_VENC"  ):SetBlock({|| nFil3 })
oSection1:Cell("JUROS"     ):SetBlock({|| nFilJ })
oSection1:Cell("VAL_SOMA"  ):SetBlock({|| nFil2+nFil3 })

oSection1:PrintLine()

Return .T.

/*/
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??un?o	 ?abiCel	?Autor ?Daniel Tadashi Batori ?Data ?04/08/06 ??
???????????????????????????????????????
??escri?o ?abilita ou desabilita celulas para imprimir totais		  ??
???????????????????????????????????????
??intaxe e ?HabiCel()	 											  ??
???????????????????????????????????????
??arametros?															  ??
??		 ?oReport ->objeto TReport que possui as celulas 			  ??
???????????????????????????????????????
??Uso		 ?Generico 												  ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
/*/
STATIC Function HabiCel(oReport)

Local oSection1 := oReport:Section(1)

oSection1:Cell("FORNECEDOR"):SetSize(50)
oSection1:Cell("TITULO"    ):Disable()
oSection1:Cell("E2_TIPO"   ):Hide()
oSection1:Cell("E2_NATUREZ"):Hide()
oSection1:Cell("E2_EMISSAO"):Hide()
oSection1:Cell("E2_VENCTO" ):Hide()
oSection1:Cell("E2_VENCREA"):Hide()
oSection1:Cell("VAL_ORIG"  ):Hide()
oSection1:Cell("E2_PORTADO"):Hide()
oSection1:Cell("DIA_ATR"   ):Hide()
oSection1:Cell("E2_HIST"   ):Disable()
oSection1:Cell("VAL_SOMA"  ):Enable()

oSection1:Cell("FORNECEDOR"):HideHeader()
oSection1:Cell("E2_TIPO"   ):HideHeader()
oSection1:Cell("E2_NATUREZ"):HideHeader()
oSection1:Cell("E2_EMISSAO"):HideHeader()
oSection1:Cell("E2_VENCTO" ):HideHeader()
oSection1:Cell("E2_VENCREA"):HideHeader()
oSection1:Cell("VAL_ORIG"  ):HideHeader()
oSection1:Cell("E2_PORTADO"):HideHeader()
oSection1:Cell("DIA_ATR"   ):HideHeader()	

Return(.T.)



/*
---------------------------------------------------------- RELEASE 3 ---------------------------------------------
*/



/*/
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??un?o	 ?cFINR150R3?Autor ?Wagner Xavier   	     ?Data ?02.10.92 ??
???????????????????????????????????????
??escri?o ?Posi?o dos Titulos a Pagar										  ??
???????????????????????????????????????
??intaxe e ?cFINR150R3(void)														  ??
???????????????????????????????????????
??ar?etros?																			  ??
???????????????????????????????????????
??Uso		 ?Gen?ico 																  ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
*/
user Function cF150R3()
//??????????
//?Define Vari?eis ?
//??????????
Local cDesc1 :=OemToAnsi(STR0001)  //"Imprime a posi?o dos titulos a pagar relativo a data base"
Local cDesc2 :=OemToAnsi(STR0002)  //"do sistema."
LOCAL cDesc3 :=""
LOCAL cString:="SE2"
LOCAL nRegEmp := SM0->(RecNo())
Local dOldDtBase := dDataBase
Local dOldData := dDataBase
Local wnrel
Local nTamPar01,nTamPar02,nTamPar03,nTamPar04,nTamPar05,nTamPar06,nTamPar09,nTamPar10,nTamPar11,nTamPar12,nTamPar23,nTamPar24,nTamPar25,nTamPar26,nTamPar30,nTamPar31
Local i

PRIVATE cPerg    := "FIN150"
PRIVATE aReturn := { OemToAnsi(STR0003), 1,OemToAnsi(STR0004), 1, 2, 1, "",1 }  //"Zebrado"###"Administracao"
PRIVATE nomeprog:="cFINR150"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE nJuros  :=0
PRIVATE tamanho:="G"

PRIVATE titulo  := ""
PRIVATE cabec1
PRIVATE cabec2M

//??????????????
//?Definicao dos cabe?lhos ?
//??????????????
titulo := OemToAnsi(STR0005)  //"Posicao dos Titulos a Pagar"
cabec1 := IIf(cPaisloc =="MEX",OemToAnsi(STR0064),OemToAnsi(STR0006))  //"Codigo Nome do Fornecedor   PRF-Numero         Tp  Natureza    Data de  Vencto   Vencto  Banco  Valor Original |        Titulos vencidos          | Titulos a vencer | Porta-|  Vlr.juros ou   Dias   Historico     "
cabec2 := OemToAnsi(STR0007)  //"                            Parcela                            Emissao  Titulo    Real                         |  Valor nominal   Valor corrigido |   Valor nominal  | dor   |   permanencia   Atraso               "

//Nao retire esta chamada. Verifique antes !!!
//Ela ?necessaria para o correto funcionamento da pergunte 36 (Data Base)
PutDtBase()

pergunte("FIN150",.F.)
//????????????????????
//?Variaveis utilizadas para parametros ?
//?mv_par01	  // do Numero 			  ?
//?mv_par02	  // at?o Numero 		  ?
//?mv_par03	  // do Prefixo			  ?
//?mv_par04	  // at?o Prefixo		  ?
//?mv_par05	  // da Natureza  	     ?
//?mv_par06	  // at?a Natureza		  ?
//?mv_par07	  // do Vencimento		  ?
//?mv_par08	  // at?o Vencimento	  ?
//?mv_par09	  // do Banco			     ?
//?mv_par10	  // at?o Banco		     ?
//?mv_par11	  // do Fornecedor		  ?
//?mv_par12	  // at?o Fornecedor	  ?
//?mv_par13	  // Da Emiss?			  ?
//?mv_par14	  // Ate a Emiss?		  ?
//?mv_par15	  // qual Moeda			  ?
//?mv_par16	  // Imprime Provis?ios  ?
//?mv_par17	  // Reajuste pelo vencto ?
//?mv_par18	  // Da data contabil	  ?
//?mv_par19	  // Ate data contabil	  ?
//?mv_par20	  // Imprime Rel anal/sint?
//?mv_par21	  // Considera  Data Base??
//?mv_par22	  // Cons filiais abaixo ??
//?mv_par23	  // Filial de            ?
//?mv_par24	  // Filial ate           ?
//?mv_par25	  // Loja de              ?
//?mv_par26	  // Loja ate             ?
//?mv_par27 	  // Considera Adiantam.? ?
//?mv_par28	  // Imprime Nome 		  ?
//?mv_par29	  // Outras Moedas 		  ?
//?mv_par30     // Imprimir os Tipos    ?
//?mv_par31     // Nao Imprimir Tipos	  ?
//?mv_par32     // Consid. Fluxo Caixa  ?
//?mv_par33     // DataBase             ?
//?mv_par34     // Tipo de Data p/Saldo ?
//?mv_par35     // Quanto a taxa		  ?
//?mv_par36     // Tit.Emissao Futura	  ?
//????????????????????
//?????????????????????
//?Envia controle para a funcao SETPRINT ?
//?????????????????????

#IFDEF TOP
	IF TcSrvType() == "AS/400" .and. Select("__SE2") == 0
		ChkFile("SE2",.f.,"__SE2")
	Endif
#ENDIF

If IsBlind() // Guardando os tamanhos para restaurar apos pegar os valores do webspool
	nTamPar01:=len(mv_par01)
	nTamPar02:=len(mv_par02)
	nTamPar03:=len(mv_par03)
	nTamPar04:=len(mv_par04)
	nTamPar05:=len(mv_par05)
	nTamPar06:=len(mv_par06)
	nTamPar09:=len(mv_par09)
	nTamPar10:=len(mv_par10)
	nTamPar11:=len(mv_par11)
	nTamPar12:=len(mv_par12)
	nTamPar23:=len(mv_par23)
	nTamPar24:=len(mv_par24)
	nTamPar25:=len(mv_par25)
	nTamPar26:=len(mv_par26)
	nTamPar30:=len(mv_par30)
	nTamPar31:=len(mv_par31)
EndIf

wnrel := "cFINR150"            //Nome Default do relatorio em Disco
aOrd	:= {OemToAnsi(STR0008),OemToAnsi(STR0009),OemToAnsi(STR0010) ,;  //"Por Numero"###"Por Natureza"###"Por Vencimento"
	OemToAnsi(STR0011),OemToAnsi(STR0012),OemToAnsi(STR0013),OemToAnsi(STR0014) }  //"Por Banco"###"Fornecedor"###"Por Emissao"###"Por Cod.Fornec."
wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,Tamanho)

If IsBlind() // Acerto dos parametros apos chamada pelo webspool
	mv_par01:=padr(IIf(alltrim(mv_par01)='#','',mv_par01), nTamPar01)
	mv_par02:=padr(IIf(alltrim(mv_par02)='#','',mv_par02), nTamPar02)
	mv_par03:=padr(IIf(alltrim(mv_par03)='#','',mv_par03), nTamPar03)
	mv_par04:=padr(IIf(alltrim(mv_par04)='#','',mv_par04), nTamPar04)
	mv_par05:=padr(IIf(alltrim(mv_par05)='#','',mv_par05), nTamPar05)
	mv_par06:=padr(IIf(alltrim(mv_par06)='#','',mv_par06), nTamPar06)
	mv_par09:=padr(IIf(alltrim(mv_par09)='#','',mv_par09), nTamPar09)
	mv_par10:=padr(IIf(alltrim(mv_par10)='#','',mv_par10), nTamPar10)
	mv_par11:=padr(IIf(alltrim(mv_par11)='#','',mv_par11), nTamPar11)
	mv_par12:=padr(IIf(alltrim(mv_par12)='#','',mv_par12), nTamPar12)
	mv_par22:=IIf(valtype(mv_par22)='C',val(mv_par22),mv_par22)
	mv_par23:=padr(IIf(alltrim(mv_par23)='#','',mv_par23), nTamPar23)
	mv_par24:=padr(IIf(alltrim(mv_par24)='#','',mv_par24), nTamPar24)
	mv_par25:=padr(IIf(alltrim(mv_par25)='#','',mv_par25), nTamPar25)
	mv_par26:=padr(IIf(alltrim(mv_par26)='#','',mv_par26), nTamPar26)
	mv_par30:=padr(IIf(alltrim(mv_par30)='#','',mv_par30), nTamPar30)
	mv_par31:=padr(IIf(alltrim(mv_par31)='#','',mv_par31), nTamPar31)
EndIf

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

RptStatus({|lEnd| Fa150Imp(@lEnd,wnRel,cString)},Titulo)

//?????????????????????
//?Restaura empresa / filial original    ?
//?????????????????????
SM0->(dbGoto(nRegEmp))
cFilAnt := SM0->M0_CODFIL

//Acerta a database de acordo com a database real do sistema
If mv_par21 == 1    // Considera Data Base
	dDataBase := dOldDtBase
Endif	

Return

/*/
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??un?o	 ?FA150Imp ?Autor ?Wagner Xavier 		  ?Data ?02.10.92 ??
???????????????????????????????????????
??escri?o ?Posi?o dos Titulos a Pagar										  ??
???????????????????????????????????????
??intaxe e ?FA150Imp(lEnd,wnRel,cString)										  ??
???????????????????????????????????????
??arametros?lEnd	  - A?o do Codeblock										  ??
??		 ?wnRel   - T?ulo do relat?io 									  ??
??		 ?cString - Mensagem										 			  ??
???????????????????????????????????????
??Uso		 ?Gen?ico 																  ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
*/
Static Function FA150Imp(lEnd,wnRel,cString)

LOCAL CbCont
LOCAL CbTxt
LOCAL nOrdem :=0
LOCAL nQualIndice := 0
LOCAL lContinua := .T.
LOCAL nTit0:=0,nTit1:=0,nTit2:=0,nTit3:=0,nTit4:=0,nTit5:=0
LOCAL nTot0:=0,nTot1:=0,nTot2:=0,nTot3:=0,nTot4:=0,nTotTit:=0,nTotJ:=0,nTotJur:=0
LOCAL nFil0:=0,nFil1:=0,nFil2:=0,nFil3:=0,nFil4:=0,nFilTit:=0,nFilJ:=0
LOCAL cCond1,cCond2,cCarAnt,nSaldo:=0,nAtraso:=0
LOCAL dDataReaj
LOCAL dDataAnt := dDataBase , lQuebra
LOCAL nMestit0:= nMesTit1 := nMesTit2 := nMesTit3 := nMesTit4 := nMesTTit := nMesTitj := 0
LOCAL dDtContab
LOCAL	cIndexSe2
LOCAL	cChaveSe2
LOCAL	nIndexSE2
LOCAL cFilDe,cFilAte
Local nTotsRec := SE2->(RecCount())
Local cTamFor, cTamTit := ""
Local aTamFor := TAMSX3("E2_FORNECE")
Local nDecs := Msdecimais(mv_par15)
Local lFr150Flt := EXISTBLOCK("FR150FLT")
Local cFr150Flt
Local aFiliais := {}      
Local cFilialSE2	:= ""
Local nInc := 0
Local aSM0 := {} 
Local dUltBaixa	:= STOD("")
Local xCompMV  := GetMv("MV_COMP")
#IFDEF TOP
	Local nI := 0
	Local aStru := SE2->(dbStruct())
#ENDIF

Private nRegSM0 := SM0->(Recno())
Private nAtuSM0 := SM0->(Recno())
PRIVATE dBaixa := dDataBase

//*******************************************************
// Solu?o para o problema no filtro de Serie minuscula *
//*******************************************************
//mv_par04 := LOWER(mv_par04)

//????????????????????????????????
//?Ponto de entrada para Filtrar 										  ?
//????????????????????Localiza?es Argentina?
If lFr150Flt
	cFr150Flt := EXECBLOCK("Fr150FLT",.f.,.f.)
Endif

//???????????????????????????????
//?Variaveis utilizadas para Impress? do Cabe?lho e Rodap??
//???????????????????????????????
cbtxt  := OemToAnsi(STR0015)  //"* indica titulo provisorio, P indica Saldo Parcial"
cbcont := 0
li 	 := 80
m_pag  := 1

nOrdem := aReturn[8]
cMoeda := LTrim(Str(mv_par15))
//Caso nao preencha o mv_par15 um erro ocorre ao procurar o parametro do sistema MV_MOEDA0.
If Val(cMoeda) == 0
	cMoeda := "1"
Endif
Titulo += OemToAnsi(STR0035)+GetMv("MV_MOEDA"+cMoeda)  //" em "
cTitAux := Titulo

dbSelectArea ( "SE2" )
Set Softseek On

If mv_par22 == 2
	cFilDe  := cFilAnt
	cFilAte := cFilAnt
ELSE
	cFilDe := mv_par23
	cFilAte:= mv_par24
Endif

//Acerta a database de acordo com o parametro
If mv_par21 == 1    // Considera Data Base
	dDataBase := mv_par33
Endif	

// Cria vetor com os codigos das filiais da empresa corrente
aFiliais := FinRetFil()

dbSelectArea("SM0")

nRegSM0 := SM0->(Recno())
nAtuSM0 := SM0->(Recno())

aSM0	:= AdmAbreSM0()
nInc := 1
While nInc <= Len( aSM0 )
	
	If !Empty(cFilAte) .AND. aSM0[nInc][1] == cEmpAnt .AND. (aSM0[nInc][2] >= cFilDe .and. aSM0[nInc][2] <= cFilAte)
	
		dbSelectArea("SE2")
		cFilAnt := aSM0[nInc][2]
	
		IF cFilialSE2 == xFilial("SE2")
			Loop
		ELSE
			cFilialSE2 := xFilial("SE2")
		ENDIF
		
		#IFDEF TOP
			// Monta total de registros para IncRegua()
			If !Empty(mv_par07)	
				cQuery := "SELECT COUNT( R_E_C_N_O_ ) TOTREC "
				cQuery += "FROM " + RetSqlName("SE2") + " "
				cQuery += "WHERE E2_FILIAL = '" + xFilial("SE2") + "' AND "
				cQuery += "E2_VENCREA >= '" + DtoS(mv_par07) + "' AND "
				cQuery += "E2_VENCREA <= '" + DtoS(mv_par08) + "' AND "
				cQuery += "D_E_L_E_T_ = ' '"
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRB", .F., .T.)
				nTotsRec := TRB->TOTREC
			Else
				cQuery := "SELECT COUNT( R_E_C_N_O_ ) TOTREC "
				cQuery += "FROM " + RetSqlName("SE2") + " "
				cQuery += "WHERE E2_FILIAL = '" + xFilial("SE2") + "' AND "
				cQuery += "E2_EMISSAO >= '" + DtoS(mv_par13) + "' AND "
				cQuery += "E2_EMISSAO <= '" + DtoS(mv_par14) + "' AND "
				cQuery += "D_E_L_E_T_ = ' '"
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRB", .F., .T.)
				nTotsRec := TRB->TOTREC
			EndIf
	                     
			dbSelectArea("TRB")
			dbCloseArea()      
			dbSelectArea("SE2")
	
			if TcSrvType() != "AS/400"
				cQuery := "SELECT * "
				cQuery += "  FROM "+	RetSqlName("SE2")
				cQuery += " WHERE E2_FILIAL = '" + xFilial("SE2") + "'"
				cQuery += "   AND D_E_L_E_T_ = ' ' "
			endif
		#ENDIF
	
		IF nOrdem == 1
			SE2->(dbSetOrder(1))
			#IFDEF TOP
				if TcSrvType() == "AS/400"
					dbSeek(xFilial("SE2")+mv_par03+mv_par01,.T.)
				else
					cOrder := SqlOrder(indexkey())
				endif
			#ELSE
				dbSeek(xFilial("SE2")+mv_par03+mv_par01,.T.)
			#ENDIF
			cCond1 := "E2_PREFIXO <= mv_par04"
			cCond2 := "E2_PREFIXO"
			titulo += OemToAnsi(STR0016)  //" - Por Numero"
			nQualIndice := 1
		Elseif nOrdem == 2
			SE2->(dbSetOrder(2))
			#IFDEF TOP
				if TcSrvType() == "AS/400"
					dbSeek(xFilial("SE2")+mv_par05,.T.)
				else
					cOrder := SqlOrder(indexkey())
				endif
			#ELSE
				dbSeek(xFilial("SE2")+mv_par05,.T.)
			#ENDIF
			cCond1 := "E2_NATUREZ <= mv_par06"
			cCond2 := "E2_NATUREZ"
			titulo += OemToAnsi(STR0017)  //" - Por Natureza"
			nQualIndice := 2
		Elseif nOrdem == 3
			SE2->(dbSetOrder(3))
			#IFDEF TOP
				if TcSrvType() == "AS/400"
					dbSeek(xFilial("SE2")+Dtos(mv_par07),.T.)
				else
					cOrder := SqlOrder(indexkey())
				endif
			#ELSE
				dbSeek(xFilial("SE2")+Dtos(mv_par07),.T.)
			#ENDIF
			cCond1 := "E2_VENCREA <= mv_par08"
			cCond2 := "E2_VENCREA"
			titulo += OemToAnsi(STR0018)  //" - Por Vencimento"
			nQualIndice := 3
		Elseif nOrdem == 4
			SE2->(dbSetOrder(4))
			#IFDEF TOP
				if TcSrvType() == "AS/400"
					dbSeek(xFilial("SE2")+mv_par09,.T.)
				else
					cOrder := SqlOrder(indexkey())
				endif
			#ELSE
				dbSeek(xFilial("SE2")+mv_par09,.T.)
			#ENDIF
			cCond1 := "E2_PORTADO <= mv_par10"
			cCond2 := "E2_PORTADO"
			titulo += OemToAnsi(STR0031)  //" - Por Banco"
			nQualIndice := 4
		Elseif nOrdem == 6
			SE2->(dbSetOrder(5))
			#IFDEF TOP
				if TcSrvType() == "AS/400"
					dbSeek(xFilial("SE2")+DTOS(mv_par13),.T.)
				else
					cOrder := SqlOrder(indexkey())
				endif
			#ELSE
				dbSeek(xFilial("SE2")+DTOS(mv_par13),.T.)
			#ENDIF
			cCond1 := "E2_EMISSAO <= mv_par14"
			cCond2 := "E2_EMISSAO"
			titulo += OemToAnsi(STR0019)  //" - Por Emissao"
			nQualIndice := 5
		Elseif nOrdem == 7
			SE2->(dbSetOrder(6))
			#IFDEF TOP
				if TcSrvType() == "AS/400"
					dbSeek(xFilial("SE2")+mv_par11,.T.)
				else
					cOrder := SqlOrder(indexkey())
				endif
			#ELSE
				dbSeek(xFilial("SE2")+mv_par11,.T.)
			#ENDIF			
			cCond1 := "E2_FORNECE <= mv_par12"
			cCond2 := "E2_FORNECE"
			titulo += OemToAnsi(STR0020)  //" - Por Cod.Fornecedor"
			nQualIndice := 6
		Else
			cChaveSe2 := "E2_FILIAL+E2_NOMFOR+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO"
			#IFDEF TOP
				if TcSrvType() == "AS/400"
					cIndexSe2 := CriaTrab(nil,.f.)
					IndRegua("SE2",cIndexSe2,cChaveSe2,,u_Fr150IndR(),OemToAnsi(STR0021))  // //"Selecionando Registros..."
					nIndexSE2 := RetIndex("SE2")
					dbSetOrder(nIndexSe2+1)
					dbSeek(xFilial("SE2"))
				else
					cOrder := SqlOrder(cChaveSe2)
				endif
			#ELSE
				cIndexSe2 := CriaTrab(nil,.f.)
				IndRegua("SE2",cIndexSe2,cChaveSe2,,u_Fr150IndR(),OemToAnsi(STR0021))  // //"Selecionando Registros..."
				nIndexSE2 := RetIndex("SE2")
				dbSetIndex(cIndexSe2+OrdBagExt())
				dbSetOrder(nIndexSe2+1)
				dbSeek(xFilial("SE2"))
			#ENDIF
			cCond1 := "E2_FORNECE <= mv_par12"
			cCond2 := "E2_FORNECE+E2_LOJA"
			titulo += OemToAnsi(STR0022)  //" - Por Fornecedor"
			nQualIndice := IndexOrd()
		EndIF
	
		If mv_par20 == 1
			titulo += OemToAnsi(STR0023)  //" - Analitico"
		Else
			titulo += OemToAnsi(STR0024)  // " - Sintetico"
			cabec1 := OemToAnsi(STR0033)  // "                                                                                          |        Titulos vencidos         |    Titulos a vencer     |           Valor dos juros ou                       (Vencidos+Vencer)"
			cabec2 := OemToAnsi(STR0034)  // "                                                                                          | Valor nominal   Valor corrigido |      Valor nominal      |            com. permanencia                                         "
		EndIf
	
		dbSelectArea("SE2")
		cFilterUser:=aReturn[7]
	
		Set Softseek Off
	
		#IFDEF TOP
			if TcSrvType() != "AS/400"
				cQuery += " AND E2_NUM     BETWEEN '"+ mv_par01+ "' AND '"+ mv_par02 + "'"
				cQuery += " AND E2_PREFIXO BETWEEN '"+ mv_par03+ "' AND '"+ mv_par04 + "'"
				cQuery += " AND (E2_MULTNAT = '1' OR (E2_NATUREZ BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'))"
				cQuery += " AND E2_VENCREA BETWEEN '"+ DTOS(mv_par07)+ "' AND '"+ DTOS(mv_par08) + "'"
				cQuery += " AND E2_PORTADO BETWEEN '"+ mv_par09+ "' AND '"+ mv_par10 + "'"
				cQuery += " AND E2_FORNECE BETWEEN '"+ mv_par11+ "' AND '"+ mv_par12 + "'"
				cQuery += " AND E2_EMISSAO BETWEEN '"+ DTOS(mv_par13)+ "' AND '"+ DTOS(mv_par14) + "'"
				cQuery += " AND E2_LOJA    BETWEEN '"+ mv_par25 + "' AND '"+ mv_par26 + "'"
	
				//Considerar titulos cuja emissao seja maior que a database do sistema
				If mv_par36 == 2 
					cQuery += " AND E2_EMISSAO <= '" + DTOS(dDataBase) +"'"
				Endif
		
				If !Empty(mv_par30) // Deseja imprimir apenas os tipos do parametro 30
					cQuery += " AND E2_TIPO IN "+FormatIn(mv_par30,";") 
				ElseIf !Empty(Mv_par31) // Deseja excluir os tipos do parametro 31
					cQuery += " AND E2_TIPO NOT IN "+FormatIn(mv_par31,";")
				EndIf
				If mv_par32 == 1
					cQuery += " AND E2_FLUXO <> 'N'"
				Endif 
							
				cQuery += " AND E2_TIPO NOT IN "+FormatIn(MVABATIM,";")
				
				If mv_par16 == 2
					cQuery += " AND E2_TIPO NOT IN "+FormatIn(MVPROVIS,";")			
				Endif
				
				If mv_par27 == 2
					cQuery += " AND E2_TIPO NOT IN "+FormatIn(MVPAGANT,";")			 
					cQuery += " AND E2_TIPO NOT IN "+FormatIn(MV_CPNEG,";")			
				Endif							
							
				If mv_par39 == 2
					cQuery += " AND SE2.E2_TIPO NOT IN ('PRE') "	
				endif
				cQuery += " ORDER BY "+ cOrder
	
				cQuery := ChangeQuery(cQuery)
	
				dbSelectArea("SE2")
				dbCloseArea()
				dbSelectArea("SA2")
	
				dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SE2', .F., .T.)
	
				For ni := 1 to Len(aStru)
					If aStru[ni,2] != 'C'
						TCSetField('SE2', aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
					Endif
				Next
			endif
		#ENDIF
	
		SetRegua(nTotsRec)
		
		If MV_MULNATP .And. nOrdem == 2
			Finr155R3(cFr150Flt, lEnd, @nFil0, @nFil1, @nFil2, @nFil3, @nFilTit, @nFilj )
			#IFDEF TOP
				if TcSrvType() != "AS/400"
					dbSelectArea("SE2")
					dbCloseArea()
					ChKFile("SE2")
					dbSetOrder(1)
				endif
			#ENDIF
			If Empty(xFilial("SE2"))
				ImpTot150(nFil0,nFil1,nFil2,nFil3,nFil4,nFilTit,nFilJ,nDecs)
				Exit
			Endif
			dbSelectArea("SM0")
			if mv_par22 == 1 .and. Len(aSM0) > 1 
				ImpFil150(nFil0,nFil1,nFil2,nFil3,nFil3,nFilTit,nFilj,nDecs,aSM0[nInc][7])
			Endif
			
			nTot0 += nFil0
			nTot1 += nFil1
			nTot2 += nFil2
			nTot3 += nFil3
			nTot4 += nFil4
			nTotJ += nFilj
			nTotTit+=nFilTit
			Store 0 To nFil0,nFil1,nFil2,nFil3,nFil4,nFilTit,nFilj
			nInc++
			Loop
		Endif
	
		While &cCond1 .and. !Eof() .and. lContinua .and. E2_FILIAL == xFilial("SE2")
	
			IF lEnd
				@PROW()+1,001 PSAY OemToAnsi(STR0025)  //"CANCELADO PELO OPERADOR"
				Exit
			End
	
			IncRegua()
	
			dbSelectArea("SE2")
	
			Store 0 To nTit1,nTit2,nTit3,nTit4,nTit5
	
			//?????????????????????
			//?Carrega data do registro para permitir ?
			//?posterior analise de quebra por mes.	 ?
			//?????????????????????
			dDataAnt := Iif(nOrdem == 3, SE2->E2_VENCREA, SE2->E2_EMISSAO)
	
			cCarAnt := &cCond2
	
			While &cCond2 == cCarAnt .and. !Eof() .and. lContinua .and. E2_FILIAL == xFilial("SE2")
	
				IF lEnd
					@PROW()+1,001 PSAY OemToAnsi(STR0025)  //"CANCELADO PELO OPERADOR"
					Exit
				End
	
				IncRegua()
	
				dbSelectArea("SE2")
	
				//????????????????????????????????
				//?Considera filtro do usuario                                  ?
				//????????????????????????????????
				If !Empty(cFilterUser).and.!(&cFilterUser)
					dbSkip()
					Loop
				Endif
				//????????????????????????????????
				//?Considera filtro do usuario no ponto de entrada.             ?
				//????????????????????????????????
				If lFr150flt
					If &cFr150flt
						DbSkip()
						Loop
					Endif
				Endif
				
				#IFNDEF TOP						
					//????????????????????????????
					//?Verifica se trata-se de abatimento ou provisorio, ou ?
					//?Somente titulos emitidos ate a data base				   ?
					//????????????????????????????
					IF SE2->E2_TIPO $ MVABATIM .Or. (SE2 -> E2_EMISSAO > dDataBase .and. mv_par36 == 2)
						dbSkip()
						Loop
					EndIF
					//????????????????????????????
					//?Verifica se ser?impresso titulos provis?ios		   ?
					//????????????????????????????
					IF E2_TIPO $ MVPROVIS .and. mv_par16 == 2
						dbSkip()
						Loop
					EndIF	
					IF E2_TIPO $ 'PRE' .and. mv_par16 == 2
					dbSkip()
					Loop
					EndIF

					//????????????????????????????
					//?Verifica se ser?impresso titulos de Adiantamento	 ?
					//????????????????????????????
					IF SE2->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG .and. mv_par27 == 2
						dbSkip()
						Loop
					EndIF      
					         
	            #ENDIF
	            
	            //?????????????????????
				//?Verifica se deve imprimir outras moedas?
				//?????????????????????
				If mv_par29 == 2 // nao imprime
					if SE2->E2_MOEDA != mv_par15 //verifica moeda do campo=moeda parametro
						dbSkip()
						Loop
					endif	
				Endif   
				
				// dDtContab para casos em que o campo E2_EMIS1 esteja vazio
				// compatibilizando com a vers? 2.04 que n? gerava para titulos
				// de ISS e FunRural
	
				dDtContab := Iif(Empty(SE2->E2_EMIS1),SE2->E2_EMISSAO,SE2->E2_EMIS1)
	
				//?????????????????????
				//?Verifica se esta dentro dos parametros ?
				//?????????????????????
				IF E2_NUM < mv_par01      .OR. E2_NUM > mv_par02 .OR. ;
						E2_PREFIXO < mv_par03  .OR. E2_PREFIXO > mv_par04 .OR. ;
						E2_NATUREZ < mv_par05  .OR. E2_NATUREZ > mv_par06 .OR. ;
						E2_VENCREA < mv_par07  .OR. E2_VENCREA > mv_par08 .OR. ;
						E2_PORTADO < mv_par09  .OR. E2_PORTADO > mv_par10 .OR. ;
						E2_FORNECE < mv_par11  .OR. E2_FORNECE > mv_par12 .OR. ;
						E2_EMISSAO < mv_par13  .OR. E2_EMISSAO > mv_par14 .OR. ;
						(E2_EMISSAO > dDataBase .and. mv_par36 == 2) .OR. dDtContab  < mv_par18 .OR. ;
						E2_LOJA    < mv_par25  .OR. E2_LOJA    > mv_par26 .OR. ;
						dDtContab  > mv_par19  .Or. !&(u_fr150IndR())
	
					dbSkip()
					Loop
				Endif
				     
				
				//???????????????????????????????????
				//?Verifica se esta dentro do parametro compor pela data de digita?o ?
				//???????????????????????????????????
				IF mv_par34 == 2 .And. !Empty(E2_EMIS1) .And. !Empty(mv_par33)
					If E2_EMIS1 > mv_par33
						dbSkip()
						Loop
					Endif			
				Endif
				
	
				//????????????????????????????????
				//?Verifica se titulo, apesar do E2_SALDO = 0, deve aparecer ou ?
				//?n? no relat?io quando se considera database (mv_par21 = 1) ?
				//?ou caso n? se considere a database, se o titulo foi totalmen?
				//?te baixado.																  ?
				//????????????????????????????????
				IF !Empty(SE2->E2_BAIXA) .and. Iif(mv_par21 == 2 ,SE2->E2_SALDO == 0 ,SE2->E2_SALDO == 0 .and. SE2->E2_BAIXA <= dDataBase)						


					dbSkip()
					Loop
				EndIF
				
				 // Tratamento da correcao monetaria para a Argentina
				If  cPaisLoc=="ARG" .And. mv_par15 <> 1  .And.  SE2->E2_CONVERT=='N'
					dbSkip()
					Loop
				Endif
	             
				dbSelectArea("SA2")
				MSSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA)
				dbSelectArea("SE2")
	
				// Verifica se existe a taxa na data do vencimento do titulo, se nao existir, utiliza a taxa da database
				If SE2->E2_VENCREA < dDataBase
					If mv_par17 == 2 .And. RecMoeda(SE2->E2_VENCREA,cMoeda) > 0
						dDataReaj := SE2->E2_VENCREA
					Else
						dDataReaj := dDataBase
					EndIf	
				Else
					dDataReaj := dDataBase
				EndIf       
	
				If mv_par21 == 1
					nSaldo := SaldoTit(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_NATUREZ,"P",SE2->E2_FORNECE,mv_par15,dDataReaj,,SE2->E2_LOJA,,If(mv_par35==1,SE2->E2_TXMOEDA,Nil),IIF(mv_par34 == 2,3,1)) // 1 = DT BAIXA    3 = DT DIGIT
					//Verifica se existem compensa?es em outras filiais para descontar do saldo, pois a SaldoTit() somente
					//verifica as movimenta?es da filial corrente. Nao deve processar quando existe somente uma filial.
					If !Empty(xFilial("SE2")) .And. !Empty(xFilial("SE5"))
						nSaldo -= FRVlCompFil("P",SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_FORNECE,SE2->E2_LOJA,IIF(mv_par34 == 2,3,1),,,,mv_par15,SE2->E2_MOEDA,If(mv_par35==1,SE2->E2_TXMOEDA,Nil),dDataReaj,.T.)
					EndIf
					// Subtrai decrescimo para recompor o saldo na data escolhida - Checa se a SaldoTit j?considerou o Decr?cimo.					
					If Str(SE2->E2_VALOR,17,2) == Str(nSaldo,17,2) .And. SE2->E2_DECRESC > 0 .And. SE2->E2_SDDECRE == 0
						nSAldo -= SE2->E2_DECRESC
					Endif
					// Soma Acrescimo para recompor o saldo na data escolhida - Checa se a SaldoTit j?considerou o Acr?cimo.
					If Str(SE2->E2_VALOR,17,2) == Str(nSaldo,17,2) .And. SE2->E2_ACRESC > 0 .And. SE2->E2_SDACRES == 0
						nSAldo += SE2->E2_ACRESC
					Endif
				Else
					nSaldo := xMoeda((SE2->E2_SALDO+SE2->E2_SDACRES-SE2->E2_SDDECRE),SE2->E2_MOEDA,mv_par15,dDataReaj,ndecs+1,If(mv_par35==1,SE2->E2_TXMOEDA,Nil))
				Endif
				If ! (SE2->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG) .And. ;
				   ! ( MV_PAR21 == 2 .And. nSaldo == 0 ) // nao deve olhar abatimento pois e zerado o saldo na liquidacao final do titulo
	
					//Quando considerar Titulos com emissao futura, eh necessario
					//colocar-se a database para o futuro de forma que a Somaabat()
					//considere os titulos de abatimento
					If mv_par36 == 1
						dOldData := dDataBase
						dDataBase := CTOD("31/12/40")
					Endif
	
					nSaldo-=SomaAbat(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,"P",mv_par15,dDataReaj,SE2->E2_FORNECE,SE2->E2_LOJA)
	
					If mv_par36 == 1
						dDataBase := dOldData
					Endif
				EndIf
	
				nSaldo:=Round(NoRound(nSaldo,3),2)
				//????????????????????????????
				//?Desconsidera caso saldo seja menor ou igual a zero   ?
				//????????????????????????????
				If nSaldo <= 0
					dbSkip()
					Loop
				Endif  
				
				//????????????????????????????
				//?Desconsidera os titulos de acordo com o parametro 
				//	considera filial e a tabela SE2 estiver compartilhada?
				//????????????????????????????				
				If MV_PAR22 == 1 .and. Empty(xFilial("SE2"))
					If !(SE2->E2_FILORIG >= mv_par23 .and. SE2->E2_FILORIG <= mv_par24) 
						dbSkip()
						Loop
					Endif			
				Endif 
	
				IF li > 58
					SM0->(dbGoto(nRegSM0))
					cabec(titulo,cabec1,cabec2,nomeprog,tamanho,xCompMV)
				EndIF
	
				If mv_par20 == 1				
					If !(Alltrim(cPaisLoc) $ "MEX|POR")
						@li,	0 PSAY SE2->E2_FORNECE+"-"+SE2->E2_LOJA+"-"+IIF(mv_par28 == 1, SubStr(SA2->A2_NREDUZ,1,20), SubStr(SA2->A2_NOME,1,20))																												
						@li, 31 PSAY SE2->E2_PREFIXO+"-"+SE2->E2_NUM+"-"+SE2->E2_PARCELA						
	              Else				
						If Len(SE2->E2_FORNECE) > 6
							@li, 00 PSAY SubStr(SE2->E2_FORNECE+"-"+SE2->E2_LOJA,01,25)
							cTamFor  :=  SubStr(IIF(mv_par28 == 1, SA2->A2_NREDUZ, SA2->A2_NOME),01,25)
		            	Else
							@li, 00 PSAY SubStr(SE2->E2_FORNECE+"-"+SE2->E2_LOJA+"-"+IIF(mv_par28 == 1, SubStr(SA2->A2_NREDUZ,1,25), SubStr(SA2->A2_NOME,1,25)),01,25)
							cTamFor  :=  SubStr(SE2->E2_FORNECE+"-"+SE2->E2_LOJA+"-"+IIF(mv_par28 == 1, SubStr(SA2->A2_NREDUZ,1,25), SubStr(SA2->A2_NOME,1,25)),33,57)
		            	EndIf
		            
						@li, 31 PSAY SubStr(SE2->E2_PREFIXO+"-"+SE2->E2_NUM+"-"+SE2->E2_PARCELA,01,20)
						cTamTit  :=  SubStr(SE2->E2_PREFIXO+"-"+SE2->E2_NUM+"-"+SE2->E2_PARCELA,34,55)
	              Endif	
	                			
					If cPaisLoc $ "BRA|ARG"
						If aTamFor[1] > 6
							@li, 58 PSAY SE2->E2_TIPO 
							@li, 60 PSAY SE2->E2_NATUREZ
							@li, 71 PSAY SE2->E2_EMISSAO
							@Li, 82 PSAY SE2->E2_VENCTO 
							@li, 93 PSAY SE2->E2_VENCREA
							@li, 106 PSAY xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,mv_par15,SE2->E2_EMISSAO,ndecs+1,If(mv_par35==1,SE2->E2_TXMOEDA,Nil)) * If(SE2->E2_TIPO$MV_CPNEG+"/"+MVPAGANT, -1,1) Picture PesqPict("SE2","E2_VALOR",15,MV_PAR15)
						Else						
				  			@li, 49 PSAY SE2->E2_TIPO
				  			@li, 54 PSAY SE2->E2_NATUREZ	
							@li, 65 PSAY SE2->E2_EMISSAO
							@Li, 76 PSAY SE2->E2_VENCTO 
							@li, 87 PSAY SE2->E2_VENCREA
							@li, 99 PSAY xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,mv_par15,SE2->E2_EMISSAO,ndecs+1,If(mv_par35==1,SE2->E2_TXMOEDA,Nil)) * If(SE2->E2_TIPO$MV_CPNEG+"/"+MVPAGANT, -1,1) Picture PesqPict("SE2","E2_VALOR",15,MV_PAR15)
					  	Endif	
					Else    
						@li, 51 PSAY SE2->E2_TIPO
						@li, 55 PSAY SE2->E2_NATUREZ
						@li, 65 PSAY SE2->E2_EMISSAO
						@Li, 76 PSAY SE2->E2_VENCTO
						@li, 87 PSAY SE2->E2_VENCREA
						@li, 99 PSAY xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,mv_par15,SE2->E2_EMISSAO,ndecs+1,If(mv_par35==1,SE2->E2_TXMOEDA,Nil)) * If(SE2->E2_TIPO$MV_CPNEG+"/"+MVPAGANT, -1,1) Picture PesqPict("SE2","E2_VALOR",15,MV_PAR15)
					EndIf
										
				EndIf
				#IFDEF TOP
					If TcSrvType() == "AS/400"
						dbSetOrder( nQualIndice )
					Endif
				#ELSE
					dbSetOrder( nQualIndice )
				#ENDIF
	
				If dDataBase > SE2->E2_VENCREA 		//vencidos
					If mv_par20 == 1
						If aTamFor[1] >= 6
							@ li, Iif(cPaisloc $ "BRA|ARG",115,128) PSAY nSaldo  * If(SE2->E2_TIPO$MV_CPNEG+"/"+MVPAGANT, -1,1) Picture TM(nSaldo,15,nDecs)
						Else
						   @ li, Iif(cPaisloc $ "BRA|ARG",115,128) PSAY nSaldo  * If(SE2->E2_TIPO$MV_CPNEG+"/"+MVPAGANT, -1,1) Picture TM(nSaldo,15,nDecs)
						Endif						
					EndIf
					
					nJuros:=0
					dBaixa:=dDataBase
					
					// C?culo dos Juros retroativo.
					dUltBaixa := SE2->E2_BAIXA
					If MV_PAR21 == 1 // se compoem saldo retroativo verifico se houve baixas 
						If !Empty(dUltBaixa) .And. dDataBase < dUltBaixa
							dUltBaixa := FR150DBX() // Ultima baixa at?DataBase
						EndIf
					EndIf
					
					dbSelectArea("SE2")
					nJuros := fa080Juros(mv_par15,nSaldo,"SE2",dUltBaixa)
					
					dbSelectArea("SE2")
					
					If mv_par20 == 1
						If aTamFor[1] >= 6
							@li,Iif(cPaisloc $ "BRA|ARG",132,135) PSAY (nSaldo+nJuros) * If(SE2->E2_TIPO$MV_CPNEG+"/"+MVPAGANT, -1,1) Picture TM(nSaldo+nJuros,15,nDecs)
						Else
						   @li,Iif(cPaisloc $ "BRA|ARG",132,135) PSAY (nSaldo+nJuros) * If(SE2->E2_TIPO$MV_CPNEG+"/"+MVPAGANT, -1,1) Picture TM(nSaldo+nJuros,15,nDecs)
						Endif						
					EndIf
					
					If SE2->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG
						nTit0 -= xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,mv_par15,SE2->E2_EMISSAO,ndecs+1,If(mv_par35==1,SE2->E2_TXMOEDA,Nil))
						nTit1 -= nSaldo
						nTit2 -= nSaldo+nJuros
						nMesTit0 -= xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,mv_par15,SE2->E2_EMISSAO,ndecs+1,If(mv_par35==1,SE2->E2_TXMOEDA,Nil))
						nMesTit1 -= nSaldo
						nMesTit2 -= nSaldo+nJuros
					Else
						nTit0 += xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,mv_par15,SE2->E2_EMISSAO,ndecs+1,If(mv_par35==1,SE2->E2_TXMOEDA,Nil))
						nTit1 += nSaldo
						nTit2 += nSaldo+nJuros
						nMesTit0 += xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,mv_par15,SE2->E2_EMISSAO,ndecs+1,If(mv_par35==1,SE2->E2_TXMOEDA,Nil))
						nMesTit1 += nSaldo
						nMesTit2 += nSaldo+nJuros
					Endif
					
					nTotJur += (nJuros)
					nMesTitJ += (nJuros)
				Else				  //a vencer
					If mv_par20 == 1
						If aTamFor[1] >= 6
							@li,Iif(cPaisloc $ "BRA|ARG",147,148) PSAY nSaldo  * If(SE2->E2_TIPO$MV_CPNEG+"/"+MVPAGANT, -1,1) Picture TM(nSaldo,15,nDecs)
						Else
							@li,Iif(cPaisloc $ "BRA|ARG",151,148) PSAY nSaldo  * If(SE2->E2_TIPO$MV_CPNEG+"/"+MVPAGANT, -1,1) Picture TM(nSaldo,15,nDecs)  //leandro
						Endif						
					EndIf
					
					If SE2->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG
						nTit0 -= xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,mv_par15,SE2->E2_EMISSAO,ndecs+1,If(mv_par35==1,SE2->E2_TXMOEDA,Nil))
						nTit3 -= nSaldo
						nTit4 -= nSaldo
						nMesTit0 -= xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,mv_par15,SE2->E2_EMISSAO,ndecs+1,If(mv_par35==1,SE2->E2_TXMOEDA,Nil))
						nMesTit3 -= nSaldo
						nMesTit4 -= nSaldo
					Else
						nTit0 += xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,mv_par15,SE2->E2_EMISSAO,ndecs+1,If(mv_par35==1,SE2->E2_TXMOEDA,Nil))
						nTit3 += nSaldo
						nTit4 += nSaldo
						nMesTit0 += xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,mv_par15,SE2->E2_EMISSAO,ndecs+1,If(mv_par35==1,SE2->E2_TXMOEDA,Nil))
						nMesTit3 += nSaldo
						nMesTit4 += nSaldo
					Endif
				Endif
				
				If mv_par20 == 1
					If aTamFor[1] >= 6
						@Li,171 PSAY SE2->E2_PORTADO
				   Else
				    	@Li,170 PSAY SE2->E2_PORTADO
				   Endif					
				EndIf
				
				If nJuros > 0
					If mv_par20 == 1
						If aTamFor[1] >= 6
							@Li,173 PSAY nJuros Picture PesqPict("SE2","E2_JUROS",12,MV_PAR15)
				   	  	Else
				    	  	@Li,176 PSAY nJuros Picture PesqPict("SE2","E2_JUROS",12,MV_PAR15)
				   	  	Endif							
					EndIf
					
					nJuros := 0
				Endif
	
				IF dDataBase > E2_VENCREA
					nAtraso:=dDataBase-E2_VENCTO
					IF Dow(E2_VENCTO) == 1 .Or. Dow(E2_VENCTO) == 7
						IF Dow(dBaixa) == 2 .and. nAtraso <= 2
							nAtraso:=0
						EndIF
					EndIF
					
					nAtraso:=IIF(nAtraso<0,0,nAtraso)
					
					IF nAtraso>0
						If mv_par20 == 1
							If aTamFor[1] >= 6
						  		@li,190 PSAY nAtraso Picture "9999"
				   	  		Else
				    	  		@li,192 PSAY nAtraso Picture "9999"
				   	  		Endif				   	  		
						EndIf
					EndIF
				EndIF
				
				If mv_par20 == 1
					@li,197 PSAY SUBSTR(SE2->E2_HIST,1,25)+ ;
						IIF(E2_TIPO $ MVPROVIS,"*"," ")+ ;
						Iif(nSaldo - SE2->E2_ACRESC + SE2->E2_DECRESC == xMoeda(E2_VALOR,E2_MOEDA,mv_par15,dDataReaj,ndecs+1,If(mv_par35==1,SE2->E2_TXMOEDA,Nil))," ","P")
				EndIf
	            
				If Alltrim(cPaisLoc) $ "MEX|POR"
					//??????????????????????????
					//?Tratamento para imprimir restante do conte?o   ?
					//?dos campos quando maior que o permitido         ?
					//?para evitar impress? incompleta ou imperfeita. ?
					//??????????????????????????
					If mv_par20 == 1 .and. (!Empty(cTamFor) .or. !Empty(cTamTit))
						li ++
						@li, 00 PSAY cTamFor
						@li, 26 PSAY cTamTit
					EndIf
				Endif
				
				//?????????????????????
				//?Carrega data do registro para permitir ?
				//?posterior analise de quebra por mes.	 ?
				//?????????????????????
				dDataAnt := Iif(nOrdem == 3, SE2->E2_VENCREA, SE2->E2_EMISSAO)
	
				dbSkip()
				nTotTit ++
				nMesTTit ++
				nFiltit++
				nTit5 ++
				If mv_par20 == 1
					li ++
				EndIf
	
			EndDO
	
			IF nTit5 > 0 .and. nOrdem != 1
				u_SubTot150(nTit0,nTit1,nTit2,nTit3,nTit4,nOrdem,cCarAnt,nTotJur,nDecs)
				If mv_par20 == 1
					li++
				EndIf
			EndIF
	
			//?????????????????????
			//?Verifica quebra por mes					 ?
			//?????????????????????
			lQuebra := .F.
			If nOrdem == 3 .and. Month(SE2->E2_VENCREA) # Month(dDataAnt)
				lQuebra := .T.
			Elseif nOrdem == 6 .and. Month(SE2->E2_EMISSAO) # Month(dDataAnt)
				lQuebra := .T.
			Endif
			If lQuebra .and. nMesTTit # 0
				ImpMes150(nMesTit0,nMesTit1,nMesTit2,nMesTit3,nMesTit4,nMesTTit,nMesTitJ,nDecs)
				nMesTit0 := nMesTit1 := nMesTit2 := nMesTit3 := nMesTit4 := nMesTTit := nMesTitj := 0
			Endif
	
			dbSelectArea("SE2")
	
			nTot0 += nTit0
			nTot1 += nTit1
			nTot2 += nTit2
			nTot3 += nTit3
			nTot4 += nTit4
			nTotJ += nTotJur
	
			nFil0 += nTit0
			nFil1 += nTit1
			nFil2 += nTit2
			nFil3 += nTit3
			nFil4 += nTit4
			nFilJ += nTotJur
			Store 0 To nTit0,nTit1,nTit2,nTit3,nTit4,nTit5,nTotJur
		Enddo					
	
		dbSelectArea("SE2")		// voltar para alias existente, se nao, nao funciona
		//?????????????????????
		//?Imprimir TOTAL por filial somente quan-?
		//?do houver mais do que 1 filial.        ?
		//?????????????????????
		if mv_par22 == 1 .and. Len(aSM0) > 1 
			ImpFil150(nFil0,nFil1,nFil2,nFil3,nFil4,nFilTit,nFilj,nDecs,aSM0[nInc][7])
		Endif
		Store 0 To nFil0,nFil1,nFil2,nFil3,nFil4,nFilTit,nFilJ
		If Empty(xFilial("SE2"))
			Exit
		Endif
		
		Titulo := cTitAux
	
		#IFDEF TOP
			if TcSrvType() != "AS/400"
				dbSelectArea("SE2")
				dbCloseArea()
				ChKFile("SE2")
				dbSetOrder(1)
			endif
		#ENDIF
	EndIf	
	nInc++
EndDo

SM0->(dbGoTo(nRegSM0))
cFilAnt := SM0->M0_CODFIL 

IF li != 80
	If mv_par20 == 1
		li +=2
	Endif
	If ( MV_MULNATP == .F. .Or. nOrdem != 2 )
		ImpTot150(nTot0,nTot1,nTot2,nTot3,nTot4,nTotTit,nTotJ,nDecs)
	EndIf
	cbcont := 1
	roda(cbcont,cbtxt,"G")
EndIF
Set Device To Screen

#IFNDEF TOP
	dbSelectArea( "SE2" )
	dbClearFil()
	RetIndex( "SE2" )
	If !Empty(cIndexSE2)
		FErase (cIndexSE2+OrdBagExt())
	Endif
	dbSetOrder(1)
#ELSE
	if TcSrvType() != "AS/400"
		dbSelectArea("SE2")
		dbCloseArea()
		ChKFile("SE2")
		dbSetOrder(1)
	else
		dbSelectArea( "SE2" )
		dbClearFil()
		RetIndex( "SE2" )
		If !Empty(cIndexSE2)
			FErase (cIndexSE2+OrdBagExt())
		Endif
		dbSetOrder(1)
	endif
#ENDIF	

If aReturn[5] = 1
	Set Printer To
	dbCommitAll()
	ourspool(wnrel)
Endif
MS_FLUSH()

/*/
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??un?o	 ?ubTot150 ?Autor ?Wagner Xavier 		  ?Data ?01.06.92 ??
???????????????????????????????????????
??escri?o ?MPRIMIR SUBTOTAL DO RELATORIO 									  ??
???????????????????????????????????????
??intaxe e ?SubTot150() 															  ??
???????????????????????????????????????
??arametros?																			  ??
???????????????????????????????????????
??Uso		 ?Generico 																  ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
*/
user Function cSubTot150(nTit0,nTit1,nTit2,nTit3,nTit4,nOrdem,cCarAnt,nTotJur,nDecs)

DEFAULT nDecs := Msdecimais(mv_par15)

If mv_par20 == 1
	li++
EndIf

IF li > 58
	nAtuSM0 := SM0->(Recno())
	SM0->(dbGoto(nRegSM0))
	cabec(titulo,cabec1,cabec2,nomeprog,tamanho,GetMv("MV_COMP"))
	SM0->(dbGoTo(nAtuSM0))
EndIF

if nOrdem == 1 .Or. nOrdem == 3 .Or. nOrdem == 4 .Or. nOrdem == 6
	@li,000 PSAY OemToAnsi(STR0026)  //"S U B - T O T A L ----> "
	@li,028 PSAY cCarAnt
ElseIf nOrdem == 2
	dbSelectArea("SED")
	dbSeek(xFilial("SED")+cCarAnt)
	@li,000 PSAY cCarAnt +" "+SED->ED_DESCRIC
Elseif nOrdem == 5
	@Li,000 PSAY IIF(mv_par28 == 1,SA2->A2_NREDUZ,SA2->A2_NOME)+" "+Substr(SA2->A2_TEL,1,15)
ElseIf nOrdem == 7
	@li,000 PSAY SA2->A2_COD+" "+SA2->A2_LOJA+" "+SA2->A2_NOME+" "+Substr(SA2->A2_TEL,1,15)
Endif

if mv_par20 == 1
	@li,98 PSAY nTit0		 Picture TM(nTit0,14,nDecs) //toal original
endif  

If nOrdem == 2
	@li,115 PSAY nTit1		 Picture TM(nTit1,14,nDecs) //vencidos vlr nominal  
	@li,130 PSAY nTit2		 Picture TM(nTit2,14,nDecs) //vencido vlr corrigido 
	@li,148 PSAY nTit3		 Picture TM(nTit3,14,nDecs) //total a vencer nominal
else
	@li,116 PSAY nTit1		 Picture TM(nTit1,14,nDecs)  
	@li,133 PSAY nTit2		 Picture TM(nTit2,14,nDecs)  
	@li,152 PSAY nTit3		 Picture TM(nTit3,14,nDecs)	
Endif 
   
If nTotJur > 0
	If nOrdem == 2
		@li,173 PSAY nTotJur 	 Picture TM(nTotJur,12,nDecs)
	Else
		@li,176 PSAY nTotJur 	 Picture TM(nTotJur,12,nDecs)
	EndIf
Endif  
@li,197 PSAY nTit2+nTit3 Picture TM(nTit2+nTit3,16,nDecs)
li++ 
Return(.T.)

/*/
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??un?o	 ?mpTot150 ?Autor ?Wagner Xavier 		  ?Data ?01.06.92 ??
???????????????????????????????????????
??escri?o ?MPRIMIR TOTAL DO RELATORIO 										  ??
???????????????????????????????????????
??intaxe e ?ImpTot150() 															  ??
???????????????????????????????????????
??arametros?																			  ??
???????????????????????????????????????
??Uso		 ?Generico 																  ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
*/
STATIC Function ImpTot150(nTot0,nTot1,nTot2,nTot3,nTot4,nTotTit,nTotJ,nDecs)

DEFAULT nDecs := Msdecimais(mv_par15)

li++
IF li > 58
	nAtuSM0 := SM0->(Recno())
	SM0->(dbGoto(nRegSM0))
	cabec(titulo,cabec1,cabec2,nomeprog,tamanho,GetMv("MV_COMP"))
	SM0->(dbGoTo(nAtuSM0))
EndIF

@li,000 PSAY OemToAnsi(STR0027)  //"T O T A L   G E R A L ----> "
@li,035 PSAY "("+ALLTRIM(STR(nTotTit))+" "+IIF(nTotTit > 1,OemToAnsi(STR0028),OemToAnsi(STR0029))+")"  //"TITULOS"###"TITULO" //28

if mv_par20 == 1
	@li,99 PSAY nTot0		 Picture TM(nTot0,16,nDecs)	
endif

@li,117 PSAY nTot1		 Picture TM(nTot1,16,nDecs)

if mv_par20 == 1
	@li,130 PSAY nTot2		 Picture TM(nTot2,16,nDecs)	
	@li,147 PSAY nTot3		 Picture TM(nTot3,16,nDecs) 
Else
	@li,132 PSAY nTot2		 Picture TM(nTot2,16,nDecs)
	@li,150 PSAY nTot3		 Picture TM(nTot3,16,nDecs) 
endif

If aReturn[8] == 2 //ordenado por natureza.
	@li,174 PSAY nTotJ		 Picture TM(nTotJ,12,nDecs)
Else
	@li,184 PSAY nTotJ		 Picture TM(nTotJ,12,nDecs) 
EndIf

@li,204 PSAY nTot2+nTot3 Picture TM(nTot2+nTot3,17,nDecs)

li+=2
Return(.T.)

/*/
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??un?o	 ?mpMes150 ?Autor ?Vinicius Barreira	  ?Data ?12.12.94 ??
???????????????????????????????????????
??escri?o ?MPRIMIR TOTAL DO RELATORIO - QUEBRA POR MES					  ??
???????????????????????????????????????
??intaxe e ?ImpMes150() 															  ??
???????????????????????????????????????
??arametros?																			  ??
???????????????????????????????????????
??Uso		 ?Generico 																  ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
*/
STATIC Function ImpMes150(nMesTot0,nMesTot1,nMesTot2,nMesTot3,nMesTot4,nMesTTit,nMesTotJ,nDecs)

DEFAULT nDecs := Msdecimais(mv_par15)

li++
IF li > 58
	nAtuSM0 := SM0->(Recno())
	SM0->(dbGoto(nRegSM0))
	cabec(titulo,cabec1,cabec2,nomeprog,tamanho,GetMv("MV_COMP"))
	SM0->(dbGoTo(nAtuSM0))
EndIF
@li,000 PSAY OemToAnsi(STR0030)  //"T O T A L   D O  M E S ---> "
@li,028 PSAY "("+ALLTRIM(STR(nMesTTit))+" "+IIF(nMesTTit > 1,OemToAnsi(STR0028),OemToAnsi(STR0029))+")"  //"TITULOS"###"TITULO"
if mv_par20 == 1
	@li,100 PSAY nMesTot0   Picture TM(nMesTot0,14,nDecs)
endif
@li,115 PSAY nMesTot1	Picture TM(nMesTot1,14,nDecs)
@li,133 PSAY nMesTot2	Picture TM(nMesTot2,14,nDecs) 
@li,152 PSAY nMesTot3	Picture TM(nMesTot3,14,nDecs) 
@li,176 PSAY nMesTotJ	Picture TM(nMesTotJ,12,nDecs) 
@li,197 PSAY nMesTot2+nMesTot3 Picture TM(nMesTot2+nMesTot3,16,nDecs) 
li+=2
Return(.T.)

/*/
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??un?o	 ?ImpFil150?Autor ?Paulo Boschetti 	     ?Data ?01.06.92 ??
???????????????????????????????????????
??escri?o ?Imprimir total do relatorio										  ??
???????????????????????????????????????
??intaxe e ?ImpFil150()																  ??
???????????????????????????????????????
??arametros?																			  ??
???????????????????????????????????????
??Uso      ?Generico				   									 			  ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
/*/
STATIC Function ImpFil150(nFil0,nFil1,nFil2,nFil3,nFil4,nFilTit,nFilJ,nDecs,cFilSM0)

DEFAULT nDecs := Msdecimais(mv_par15)

li++
IF li > 58
	nAtuSM0 := SM0->(Recno())
	SM0->(dbGoto(nRegSM0))
	cabec(titulo,cabec1,cabec2,nomeprog,tamanho,GetMv("MV_COMP"))
	SM0->(dbGoTo(nAtuSM0))
EndIF
@li,000 PSAY OemToAnsi(STR0032)+" "+cFilAnt+" - " + AllTrim(cFilSM0)  //"T O T A L   F I L I A L ----> " 
if mv_par20 == 1
	@li,104 PSAY nFil0        Picture TM(nFil0,16,nDecs)	
endif
@li,122 PSAY nFil1        Picture TM(nFil1,16,nDecs)
@li,139 PSAY nFil2        Picture TM(nFil2,16,nDecs)
@li,158 PSAY nFil3        Picture TM(nFil3,16,nDecs)
@li,184 PSAY nFilJ		  Picture TM(nFilJ,12,nDecs)
@li,204 PSAY nFil2+nFil3 Picture TM(nFil2+nFil3,16,nDecs)
li+=2
Return .T.

/*/
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??un?o	 ?r150Indr ?Autor ?Wagner           	  ?Data ?12.12.94 ??
???????????????????????????????????????
??escri?o ?onta Indregua para impressao do relat?io						  ??
???????????????????????????????????????
??Uso		 ?Generico 																  ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
/*/
user Function fr150IndR()
Local cString
//???????????????????????????????
//?ATENCAO !!!!                                               ?
//?N? adiconar mais nada a chave do filtro pois a mesma est??
//?com 254 caracteres.                                        ?
//???????????????????????????????
cString := 'E2_FILIAL="'+xFilial()+'".And.'
cString += '(E2_MULTNAT="1" .OR. (E2_NATUREZ>="'+mv_par05+'".and.E2_NATUREZ<="'+mv_par06+'")).And.'
cString += 'E2_FORNECE>="'+mv_par11+'".and.E2_FORNECE<="'+mv_par12+'".And.'
cString += 'DTOS(E2_VENCREA)>="'+DTOS(mv_par07)+'".and.DTOS(E2_VENCREA)<="'+DTOS(mv_par08)+'".And.'
cString += 'DTOS(E2_EMISSAO)>="'+DTOS(mv_par13)+'".and.DTOS(E2_EMISSAO)<="'+DTOS(mv_par14)+'"'
If !Empty(mv_par30) // Deseja imprimir apenas os tipos do parametro 30
	cString += '.And.E2_TIPO$"'+mv_par30+'"'
ElseIf !Empty(Mv_par31) // Deseja excluir os tipos do parametro 31
	cString += '.And.!(E2_TIPO$'+'"'+mv_par31+'")'
EndIf
IF mv_par32 == 1  // Apenas titulos que estarao no fluxo de caixa
	cString += '.And.(E2_FLUXO!="N")'	
Endif
		
Return cString

/*/
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??un?o    ?PutDtBase?Autor ?Mauricio Pequim Jr    ?Data ?18/07/02 ??
???????????????????????????????????????
??escri?o ?Ajusta parametro database do relat[orio.                   ??
???????????????????????????????????????
??so       ?cFINR150.                                                   ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
/*/
Static Function PutDtBase()
Local cSql := ""
//Mantida a atualiza?o din?ica do SX1, pois o mesmo atualiza a pergunta com a database de impress? do relat?io

cSql := " UPDATE " +RetSqlName("SX1")
cSql += " SET X1_CNT01 = '"+DTOC(dDataBase)+"'"
cSql += " WHERE "
cSql += " AND X1_GRUPO = 'FIN150' "
cSql += " AND X1_ORDEM = '33' "

TcSQLExec(cSql)
Return       


/*/
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??un?o    ?dmAbreSM0?Autor ?Orizio                ?Data ?22/01/10 ??
???????????????????????????????????????
??escri?o ?etorna um array com as informacoes das filias das empresas ??
???????????????????????????????????????
??Uso      ?Generico                                                   ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
/*/

Static Function AdmAbreSM0()
	Local aArea			:= SM0->( GetArea() )
	Local aAux			:= {}
	Local aRetSM0		:= {}
	Local lFWLoadSM0	:= FindFunction( "FWLoadSM0" )
	Local lFWCodFilSM0 	:= FindFunction( "FWCodFil" )

	If lFWLoadSM0
		aRetSM0	:= FWLoadSM0()
	Else
		DbSelectArea( "SM0" )
		SM0->( DbGoTop() )
		While SM0->( !Eof() )
			aAux := { 	SM0->M0_CODIGO,;
						IIf( lFWCodFilSM0, FWGETCODFILIAL, SM0->M0_CODFIL ),;
						"",;
						"",;
						"",;
						SM0->M0_NOME,;
						SM0->M0_FILIAL }

			aAdd( aRetSM0, aClone( aAux ) )
			SM0->( DbSkip() )
		End
	EndIf

	RestArea( aArea )
Return aRetSM0

/*/
???????????????????????????????????????
???????????????????????????????????????
??un?o	 ?justaSx1  ?Autor ?Igor Nascimento   ?Data ?16/11/15 ??
???????????????????????????????????????
??escri?o ?justa SX1 - Remover somente na "12.1.008" ou superior  	  ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
/*/

/*Static Function AjustaSx1()

Local aAreasBKP := {}
Local aHelpPor  := {}
Local aHelpEng  := {}
Local aHelpSpa  := {} 
Local cPerg		:= "FIN150"
Local nTam	
Local lExistFJU := FJU->(ColumnPos("FJU_RECPAI")) >0 .and. FindFunction("FinGrvEx")
Local nTamG018  := 0
Local cGrupo    := ""
Local nI        := 0

cGrupo := If( Empty(GetSX3Cache("E1_NUM","X3_GRPSXG")),"018",GetSX3Cache("E1_NUM","X3_GRPSXG"))

dbSelectArea("SXG")	// Grupo de Campos
AAdd(aAreasBKP,GetArea())
SXG->(dbSetOrder(1))	// X1_GRUPO + X1_ORDEM
nTamG018 := If( SXG->(dbSeek(cGrupo)), &("SXG->XG_SIZE"), TAMSX3("E1_NUM")[1])

dbSelectArea("SX1")
AAdd(aAreasBKP,GetArea())
SX1->(dbSetOrder(1))

nTam := &("len(SX1->X1_GRUPO)")

If SX1->(dbSeek(PadR(cPerg,nTam)+"37"))
	If "Excl" $ &("X1_PERGUNT")
		RecLock("SX1", .F.)
		SX1->(DbDelete())
		MsUnlock()
	EndIf	
EndIf

// MV_PAR01:Do Numero ?                   
If SX1->(dbSeek(PadR(cPerg,nTam)+"01"))
	If &("X1_TAMANHO") <> nTamG018 
		RecLock("SX1", .F.)
		&("SX1->X1_TAMANHO") := nTamG018
		MsUnlock()
	EndIf	
EndIf

// MV_PAR02:Ate o Numero ?                
If SX1->(dbSeek(PadR(cPerg,nTam)+"02"))
	If &("X1_TAMANHO") <> nTamG018 
		RecLock("SX1", .F.)
		&("SX1->X1_TAMANHO") := nTamG018
		MsUnlock()
	EndIf	
EndIf

If !SX1->(dbSeek(PadR(cPerg,nTam)+"37"))
	aHelpPor := {"Informe se devem ser consideradas as ","filiais informadas abaixo. ","Esta pergunta n? ter?efeito em ","ambiente TOPCONNECT / TOTVSDBACCESS."}      
	aHelpSpa := {"Informe si deben ser consideradas las","Sucursales informadas abajo.","Esta pregunta no tendra efecto en el ","entorno TOPCONNECT / TOTVSDBACCES"}                    
	aHelpEng := {"Indicate if the branches entered below ","must be considered. ","This question does not work in ","TOPCONNECT/TOTVSDBACCESS environments."}
	
	PutSx1(cPerg,"37","Seleciona Filiais?" ,"?elecciona sucursales?" ,"Select Branches?","mv_chx","N",1,0,2,"C","","","","S","mv_par37","Sim","Si ","Yes","","Nao","No","No","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
	PutSX1Help("P."+cPerg+"37.",aHelpPor,aHelpEng,aHelpSpa,.T.)	
EndIf

If SX1->(dbSeek(PadR(cPerg,nTam)+"38"))
	If "Filiais" $ &("X1_PERGUNT")
		RecLock("SX1", .F.)
		SX1->(DbDelete())
		MsUnlock()
	EndIf	
EndIf
 
If lExistFJU .and. !SX1->(dbSeek(PadR(cPerg,nTam)+"38"))
	aHelpPor  := {}
	aHelpEng  := {}
	aHelpSpa  := {} 
	
	Aadd( aHelpPor, "Seleciona a op?o (Sim) para que" )
	Aadd( aHelpPor, "seja considerado na posi?o financeira os t?ulos")
	Aadd( aHelpPor, "exclu?os conforme DataBase." )
	Aadd( aHelpPor, " Seleciona a op?o (N?) ser?considerado " )
	Aadd( aHelpPor, "na posi?o financeira os t?ulos que n? ")
	Aadd( aHelpPor, "foram deletados conforme DataBase. " )
	Aadd( aHelpSpa, "Seleccione opci? sino ser considerados" )
	Aadd( aHelpSpa, "valores excluidos de acuerdo a DataBase" )
	Aadd( aHelpEng, "Select option but to be considered  " )
	Aadd( aHelpEng, "securities excluded as DateBase .  " )

	PutSx1(cPerg,"38","Considera Titulos Excluidos?" ,"?Considere T?ulo Excluidos?" ,"Consider Title Excluded?","mv_chy","N",1,0,2,"C","","","","S","mv_par38","Sim","Si ","Yes","","Nao","No","No","","","","","","","","","")
	PutSX1Help("P."+cPerg+"38.",aHelpPor,aHelpEng,aHelpSpa,.T.)	
	PutSx1(cPerg,"39","Imprime Previsão?" ,"?Imprime Previsão?" ,"Imprime Previsão?","mv_chz","N",1,0,2,"C","","","","S","mv_par39","Sim","Si ","Yes","","Nao","No","No","","","","","","","","","")
	
EndIf

For nI := Len(aAreasBKP) To 1 Step -1 
	RestArea(aAreasBKP[nI])
Next nI

Return */

//-------------------------------------------------------------------
/*/{Protheus.doc} FR150DBX

Busca a data da ultima baixa realizada do titulo a pagar at?a
DataBase do sistema.

@author leonardo.casilva

@since 20/05/2016
@version P1180
 
@return
/*/
//-------------------------------------------------------------------
Static Function FR150DBX()

Local dDataRet := SE2->E2_VENCREA
Local cQuery	 := "SELECT"

cQuery += " MAX(SE5.E5_DATA) DBAIXA"
cQuery += " FROM "+ RetSQLName( "SE5" ) + " SE5 "
cQuery += " WHERE SE5.E5_FILIAL IN ('" + xFilial("SE2")  + "') " 
cQuery += " AND SE5.E5_PREFIXO = '" + SE2->E2_PREFIXO	 + "'"
cQuery += " AND SE5.E5_NUMERO = '"  + SE2->E2_NUM		 + "'"
cQuery += " AND SE5.E5_PARCELA = '" + SE2->E2_PARCELA	 + "'"
cQuery += " AND SE5.E5_TIPO = '"	+ SE2->E2_TIPO	 	 + "'"
cQuery += " AND SE5.E5_CLIFOR = '"	+ SE2->E2_FORNECE	 + "'"
cQuery += " AND SE5.E5_LOJA = '"	+ SE2->E2_LOJA	 	 + "'"
cQuery += " AND SE5.E5_TIPODOC IN('BA','VL')"
cQuery += " AND SE5.E5_RECPAG  = 'P'"
cQuery += " AND SE5.E5_DATA <= '"	+ DTOS(dDataBase) + "'"
cQuery += " AND SE5.D_E_L_E_T_ = ' '"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBDATA",.T.,.T.)

If TRBDATA->(!EOF())
	If !Empty(AllTrim(TRBDATA->DBAIXA))
		dDataRet := STOD(TRBDATA->DBAIXA)
	Endif
EndIf
TRBDATA->(dbCloseArea())

Return dDataRet
