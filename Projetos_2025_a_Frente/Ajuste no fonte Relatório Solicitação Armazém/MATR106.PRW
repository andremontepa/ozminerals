
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

/*/{Protheus.doc} matr106
description
@type function
@version  
@author rsimi
@since 2/18/2025
@return variant, return_description
/*/
User Function matr106()
	Local aArea             := GetArea()
	Local oReport
	Local lEmail            := .F.
	Local cPara             := ""
	Local _nI
	Local aParamBox         := {}
	Local aParam            := {}
	Local ni
	Local nNewLin           := 0
	local nx
	Local cArquivo          := ""
	Local nLinAux           := 0
	Private cAlias          := GetNextAlias()
	Private cCRLF           := CRLF
	Private nMudaPag        := 0
	Private nLin            := 05
	Private nColItem        := 0
	Private nColProd        := 0
	Private nColLoc         := 0
	Private nColsDes        := 0
	Private nColun          := 0
	Private nColsQtdEnt     := 0
	Private nColqtdSol      := 0
	Private nColsSld        := 0
	Private nColiNVE        := 0
	Private nColdTnEC       := 0
	Private nColssol        := 0
	Private nColST          := 0
	Private NCOLIPI         := 0
	Private nColent         := 0
	Private nVlTot          := 0
	Private nVlToti         := 0
	Private cPqto           := ""
	Private cTransp         := ""
	Private cOpera          := ""
	Private nPage           := 1
	Private nLay
	Private nCol01          := 5
	Private nCol02          := 55
	Private nCol03          := 380
	Private nCol04          := 450
	Private nCol05          := 560
	Private nCol06          := 585
	Private nCol07          := 210
	Private nCol08          := 030
	Private nCol09          := 226
	Private nCol10          := 270
	Private nCol11          := 590
	Private nColFim         := 615
	Private nColC1          := 417
	Private nColC2          := 250
	Private cObs            := ""
	Private cObsb           := ""
	Private cObsc           := ""
	Private cNumReq         := ''
	Private lAdjustToLegacy := .F.
	Private lDisableSetup   := .F.
	Private nFlags          := PD_ISTOTVSPRINTER + PD_DISABLEPAPERSIZE + PD_DISABLEMARGIN
	Private cPerg           := ""
	Private oPrinter        := nil
	Private _cPerg          := 'MTR105'
	Private aSt             := {}
	Private aIpI            := {}
	Private aAliqIpi        := {}
	Private aDIFAL          := {}
	Private aAliqIcm        := {}
	Private aTes            := {}
	Private oFont06         := nil
	Private oFont06n        := nil
	Private oFont08         := nil
	Private oFont08n        := nil
	Private oFont09         := nil
	Private oFont09n        := nil
	Private oFont10         := nil
	Private oFont10n        := nil
	Private oFont12N        := nil

	aadd(aParamBox, {1, "Sa de"    , Space(TamSx3( "CP_NUM" )[1]), "", "", "SCP"   , "", 50, .F.}) //8
	aadd(aParamBox, {1, "Sa Até"    , Space(TamSx3( "CP_NUM" )[1]), "", "", "SCP"   , "", 50, .F.}) //8
	aadd(aParamBox, {1, "Emissao De "    , Ctod(Space(8))                  , "", "", ""      , "", 50, .F.})
	aadd(aParamBox, {1, "Emissao Ate "   , Ctod(Space(8))                  , "", "", ""      , "", 50, .F.})

	if 	!ParamBox(aParamBox, "Parâmetros ",@aParam,,,,,,,"RECOM",.T.,.T.)
		return()
	endif


	For _nI := 1 To Len( aParam )
		&("MV_PAR" + StrZero(_nI, 2, 0)) := aParam[_nI]
	Next _nI

	cArquivo := GetNextAlias()+ "_" + cEmpAnt + "_" + cFilAnt + "_" + DToS(Date()) + "_" + StrTran(Time(),":","")

oPrinter := FWMSPrinter():New(cArquivo + ".rel", IMP_PDF, .F.,GetTempPath() , .T.)// Ordem obrigátoria de configuração do relatório
oPrinter:SetResolution(78)
oPrinter:SetPortrait()
oPrinter:SetPaperSize(DMPAPER_A4) 
oPrinter:SetMargin(60,60,60,60) // nEsquerda, nSuperior, nDireita, nInferior 
oPrinter:cPathPDF := GetTempPath() // Caso seja utilizada impressão em IMP_PDF


	oFont06         := TFontEx():New(oPrinter,"Arial",06,06,.F.,.T.,.F.)// 2
	oFont06n        := TFontEx():New(oPrinter,"Arial",06,06,.t.,.T.,.F.)// 3
	oFont08         := TFontEx():New(oPrinter,"Arial",08,08,.F.,.T.,.F.)// 2
	oFont08n        := TFontEx():New(oPrinter,"Arial",08,08,.f.,.T.,.F.)// 3
	oFont09         := TFontEx():New(oPrinter,"Arial",08,08,.f.,.T.,.F.)// 3
	oFont09n        := TFontEx():New(oPrinter,"Arial",08,08,.f.,.T.,.F.)// 3
	oFont10         := TFontEx():New(oPrinter,"Arial",10,10,.F.,.T.,.F.)// 2
	oFont10n        := TFontEx():New(oPrinter,"Arial",10,10,.t.,.T.,.F.)// 3
	oFont12N        := TFontEx():New(oPrinter,"Arial",12,12,.T.,.T.,.F.)// 1
	nLay := oPrinter:GetOrientation()


	If nLay == 2
		nColFim := 830
		nCol01  := 05
		nCol02  := 55
		nCol03  := 510
		nCol04  := 600
		nCol05  := 740
		nCol06  := 765
		nCol07  := 310
		nCol08  := 030
		nCol09  := 326
		nCol10  := 270
		nCol11  := 780
		nCol12  := 622
		nColC1  := nCol04
		nColC2  := 350
		oFont06     := TFontEx():New(oPrinter,"Arial",08,08,.F.,.T.,.F.)// 2
		oFont06n    := TFontEx():New(oPrinter,"Arial",08,08,.t.,.T.,.F.)// 3
	EndIf

	If BuscaDados()
		MsgInfo("Sem dados para exibir!","Isotron")
	EndIf

	(cAlias)->(DbGoTop())
	cNumReq:=(cAlias)->CP_NUM
	Cabecalho(.f.,.t.)
	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))
	DbSelectArea("SBF")
	SBF->(DbSetOrder(3))
	DbSelectArea("SB2")
	DbSetOrder(1)

	nMudaPag := 500
	
	While !(cAlias)->(EOF())

		SB1->(MsSeek(FWxFilial("SB1") + (cAlias)->CP_PRODUTO))
		cLocaliz:=''
		nSaldo:=0
		IF empty((cAlias)->BF_LOCALIZ)
			nSaldo :=  (cAlias)->B2_QATU
		else
			cLocaliz :=(cAlias)->BF_LOCALIZ
			nSaldo := (cAlias)->BF_QUANT
		EndIf
		GeraGrid()
	
		oPrinter:Say(nLin , nColItem+5 ,  (cAlias)->CP_ITEM , oFont06:oFont,,)

		If LEN(cLocaliz) > 15
			nQuebra := 0

			For ni := 15 To 1 STEP -1
				If Substr(cLocaliz,ni,1)==' '
					nQuebra:=ni
					Exit
				EndIf

			Next

			oPrinter:Say(nLin - 2   , nColLoc + 6  , Substr(cLocaliz,1,nQuebra)   , oFont06:oFont)
			nNewLin := nLin + 07
			oPrinter:Say(nNewLin    , nColLoc + 6  , Substr(cLocaliz,nQuebra+1,45), oFont06:oFont)

		Else
			nLinAux := 0
			oPrinter:Say(nLin , nColLoc+5 ,  	cLocaliz, oFont06:oFont,,)

		EndIf

		oPrinter:Say(nLin , nColProd+5 ,  (cAlias)->CP_PRODUTO , oFont06:oFont,,)
		cDesc   := Alltrim((cAlias)->CP_DESCRI)

		If LEN(cDesc) > 28
			nQuebra := 0

			For ni := 25 To 1 STEP -1
				If Substr(cDesc,ni,1)==' '
					nQuebra:=ni
					Exit
				EndIf

			Next

			oPrinter:Say(nLin - 2   , nColsDes + 6  , Substr(cDesc,1,nQuebra)   , oFont06:oFont)
			nNewLin := nLin + 07
			oPrinter:Say(nNewLin    , nColsDes + 6  , Substr(cDesc,nQuebra+1,45), oFont06:oFont)

		Else
			nLinAux := 0
			oPrinter:Say(nLin , nColsDes+5 ,  (cAlias)->CP_DESCRI , oFont06:oFont,,)

		EndIf

		oPrinter:Say(nLin , nColun+5 , SB1->B1_UM , oFont06:oFont,,)
		oPrinter:SayAlign(nLin,nColun-30  , Alltrim(TransForm( (cAlias)-> CP_QUANT,"@E 999,999.99"))  , oFont06:oFont,100,200, CLR_BLACK,1,1 )
		oPrinter:SayAlign(nLin,nColqtdSol+5  ,IF((cAlias)->CP_QUJE>0,Alltrim(TransForm(  (cAlias)->CP_QUJE ,"@E 999,999.99")),'')  , oFont06:oFont,100,200, CLR_BLACK,1,1 )
		oPrinter:SayAlign(nLin,nColsQtdEnt+5  , Alltrim(TransForm(nSaldo,"@E 999,999.99")) , oFont06:oFont,100,200, CLR_BLACK,1,1 )
		oPrinter:SayAlign(nLin,nColsSld+5  ,  ''  , oFont06:oFont,100,200, CLR_BLACK,1,1 )
		oPrinter:Say(nLin , nColdTnEC+5  , dtoc(stod( (cAlias)->CP_EMISSAO))    , oFont06:oFont,,)
	
		nLin        += 18

		(cAlias)->(DBSkip())
		oPrinter:Line( nlin-9, 0, nlin-9                   , nColFim)

		if cNumReq<>(cAlias)->CP_NUM  .and. !Empty((cAlias)->CP_NUM )
			MudaPag(.f.,.t.)
			nLin:=0
			Cabecalho(.F.,.T.)
			cNumReq:=(cAlias)->CP_NUM
		ELSEIF  nLin > nMudaPag
			nLin:=0
			MudaPag(.f.,.t.)
			Cabecalho(.F.,.T.)
		EndIf
		IF Empty((cAlias)->CP_NUM )
			MudaPag(.t.)
		ENDIF

	EndDo

	oPrinter:Line( nlin-9, 0, nlin-9                   , nColFim)
	oPrinter:Preview()
Return()

/*/{Protheus.doc} MudaPag
Informações de roda pe 
@type function
@version  
@author Rubens_
@since 21/03/2025
@param lFim, logical, param_description
@param lIni, logical, param_description
@return variant, return_description
/*/
Static Function MudaPag(lFim,lIni)
	Local lRet      := .f.
	Default lFim    := .f.
	Default lIni    := .f.

	If nLin > nMudaPag  .or.  cNumReq<>(cAlias)->CP_NUM
		nLin        += 30

		oPrinter:Box(nLin,000,nLin+240,nColFim)
		oPrinter:Line( nlin, nColun+10, nLin+240, nColun+10,CLR_BLACK,,) //linha vertical separando cx
		oPrinter:Say(nlin+20, nColun+15, "(  ) Atendimento total", oFont08n:oFont,,CLR_BLACK)
		oPrinter:Say(nlin+50, nColun+15, "(  ) Atendimento Parcial", oFont08n:oFont,,CLR_BLACK)
		oPrinter:Say(nlin+50, nColun+150, "Nº Da baixa:____________________", oFont08n:oFont,,CLR_BLACK)
		oPrinter:Say(nlin+80, nColun+15, "(  ) Baixa total", oFont08n:oFont,,CLR_BLACK)
		oPrinter:Say(nlin+80, nColun+150, "Data da baixa:    ___/___/______", oFont08n:oFont,,CLR_BLACK)
		oPrinter:Say(nlin+110, nColun+15, "(  ) Baixa Parcial", oFont08n:oFont,,CLR_BLACK)

		oPrinter:Say(nlin+20, nCol01, "Aprovador por:", oFont08n:oFont,,CLR_BLACK)
		oPrinter:Say(nlin+45, nCol02-50, "_________________________                   _______________  ", oFont08n:oFont,,CLR_BLACK)
		oPrinter:Say(nlin+55, nCol02,  "Nome Legível                                       Matricula", oFont08n:oFont,,CLR_BLACK)
		oPrinter:Line( nlin+65, 000, nlin+65, nColun+10,CLR_BLACK,,) 
	
		nLin   +=70
	
		oPrinter:Say(nlin+75, nColun+15, "Oservação :", oFont08n:oFont,,CLR_BLACK)
		oPrinter:Say(nlin+10, nCol01, "Retirado por:", oFont08n:oFont,,CLR_BLACK)
		oPrinter:Say(nlin+35, nCol02-50, "_________________________                   _______________  ", oFont08n:oFont,,CLR_BLACK)
		oPrinter:Say(nlin+45, nCol02, "Nome Legível                                       Matricula", oFont08n:oFont,,CLR_BLACK)

		nLin   +=70
	
		oPrinter:Say(nlin+10, nCol01, "Atendido por:", oFont08n:oFont,,CLR_BLACK)
		oPrinter:Say(nlin+35, nCol02-50, "_________________________                   _______________  ", oFont08n:oFont,,CLR_BLACK)
		oPrinter:Say(nlin+45, nCol02, "Nome Legível                                       Matricula", oFont08n:oFont,,CLR_BLACK)
        cLogoD	:= GetSrvProfString("Startpath","") +"RODAPE.BMP"
	    oPrinter:SayBitmap(nlin+60,nCol01-4,cLogoD,295,40)
		oPrinter:EndPage()

	EndIf

Return(lRet)


/*/{Protheus.doc} Cabecalho
Gera Cabeçalho do relatorio 
@type function
@version  
@author Rubens_
@since 21/03/2025
@param lFim, logical, param_description
@param lIni, logical, param_description
@return variant, return_description
/*/
Static Function Cabecalho(lFim,lIni)
	Local cImpCtr :=''
	DEFAULT lFim:=.f.
	DEFAULT lIni:=.f.

	If oPrinter:Canceled()
		Return
	EndIf

	oPrinter:StartPage()
	If lIni
		cImpCtr:=IF(Empty((cAlias)->CP_XCTLIMP),'000',soma1((cAlias)->CP_XCTLIMP))
		CQUERY:= " update "+RetsqlName('SCP')+" set  CP_XCTLIMP='"+cImpCtr+"' "
		CQUERY+= " where CP_NUM='"+(cAlias)->CP_NUM+"' AND  D_E_L_E_T_=''  AND CP_FILIAL ='"+XfILIAL('SCP')+"'"
		TCSQLEXEC(CQUERY)
	EndIf
	cLogoD	:= GetSrvProfString("Startpath","") +"OZ.BMP"
	oPrinter:SayBitmap(000,000,cLogoD,130,50)

	oPrinter:Say(20, nCol05-70, "Data Emissao :"+DTOC(date()), oFont08:oFont,,)
	oPrinter:Say(30, nCol05-70, "Solicitante :"+substr(alltrim((cAlias)->CP_SOLICIT),1,20) , oFont08:oFont,,)
	oPrinter:Say(40, nCol05-70, "Controle de Impressão :"+cImpCtr , oFont08:oFont,,)
	oPrinter:Say(10, nCol07+60, " SA ", oFont12N:oFont,,CLR_BLACK)
	oPrinter:Say(25, nCol07, "SOLICITAÇÃO AO ARMAZEM", oFont12N:oFont,,CLR_BLACK)
	oPrinter:Say(40, nCol07+50, 'Nº SA:' +(cAlias)->CP_NUM , oFont12N:oFont,,CLR_BLACK)

	nLin    := 60

	If !lFim
          oBrush1 := TBrush():New( , CLR_WHITE)
		oPrinter:Fillrect( {nLin, 000, nLin+25, nColFim }, oBrush1, "-2")

		GeraGrid(.t.)

		nLin+=10
		oPrinter:Say(nLin 		, nColItem+5 	, "ITEM" 				, oFont09n:oFont,,CLR_BLACK)
		oPrinter:Say(nLin 		, nColLoc+5 	, "LOCALIZACAO" 		, oFont09n:oFont,,CLR_BLACK)
		oPrinter:Say(nLin 		, nColProd+5 	, "COD" 				, oFont09n:oFont,,CLR_BLACK)
		oPrinter:Say(nLin 		, nColsDes+5 	, "DESCRICAO ESPECIFICA" , oFont09n:oFont,,CLR_BLACK)
		oPrinter:Say(nLin 		, nColun+5 		, "UN" 					, oFont09n:oFont,,CLR_BLACK)
		oPrinter:Say(nLin 		, nColqtdSol+5 	, "QTDE " 				, oFont09n:oFont,,CLR_BLACK)
		oPrinter:Say(nLin+10 	, nColqtdSol+5  , "SOLICITADA"     		, oFont09n:oFont,,CLR_BLACK)
		oPrinter:Say(nLin 		, nColsQtdEnt+5 , "QTD" 				, oFont09n:oFont,,CLR_BLACK)
		oPrinter:Say(nLin+10 	, nColsQtdEnt+5 , "ENTREGUE"     		, oFont09n:oFont,,CLR_BLACK)
		oPrinter:Say(nLin 		, nColsSld+5  	, "SALDO EM"            , oFont09n:oFont,,CLR_BLACK)
		oPrinter:Say(nLin+10 	, nColsSld+5  	, "ESTOQUE"     		, oFont09n:oFont,,CLR_BLACK)
		oPrinter:Say(nLin 		, nColiNVE+5  	, "INVENTARIO"     		, oFont09n:oFont,,CLR_BLACK)
		oPrinter:Say(nLin 		, nColdTnEC+5  	, "DATA DA "     		, oFont09n:oFont,,CLR_BLACK)
		oPrinter:Say(nLin+10 	, nColdTnEC+5  	, "NECESSIDADE"     	, oFont09n:oFont,,CLR_BLACK)
		nLin+=25
	EndIf
Return nLin

/*/{Protheus.doc} BuscaDados
filtra dados par ao relatorio 
@type function
@version  
@author rsimi
@since 3/11/2025
@return variant, return_description
/*/


Static Function BuscaDados()
    Local cSql := ""
    Local cAlias := GetNextAlias()

    cSql := " SELECT SCP.CP_PRODUTO, SCP.CP_LOCAL, SCP.CP_QUANT, SCP.CP_QUJE, SCP.CP_XCTLIMP, SCP.CP_NUM, "
    cSql += " (SELECT STRING_AGG(RTRIM(LTRIM(BF_LOCALIZ)), ',') "
    cSql += " FROM " + RetSqlName('SBF') + " SBF1 "
    cSql += " WHERE SBF1.BF_PRODUTO = SCP.CP_PRODUTO "
    cSql += " AND SBF1.BF_FILIAL = '" + xFilial('SBF') + "' "
    cSql += " AND SBF1.D_E_L_E_T_ = ' ' "
    cSql += " GROUP BY SBF1.BF_PRODUTO) AS BF_LOCALIZ, "
    
    cSql += " (SELECT SUM(BF_QUANT) "
    cSql += " FROM " + RetSqlName('SBF') + " SBF1 "
    cSql += " WHERE SBF1.BF_PRODUTO = SCP.CP_PRODUTO "
    cSql += " AND SBF1.BF_FILIAL = '" + xFilial('SBF') + "' "
    cSql += " AND SBF1.D_E_L_E_T_ = ' ') AS BF_QUANT, "
    
    cSql += " SCP.CP_SOLICIT, SCP.CP_EMISSAO, SCP.CP_ITEM, SCP.CP_DESCRI, SB2.B2_QATU "
    cSql += " FROM " + RetSqlName('SCP') + " SCP "
    cSql += " LEFT JOIN " + RetSqlName('SB2') + " SB2 ON "
    cSql += " SB2.B2_FILIAL = '" + xFilial('SB2') + "' "
    cSql += " AND SB2.B2_COD = SCP.CP_PRODUTO "
    cSql += " AND SB2.B2_LOCAL = SCP.CP_LOCAL "
    cSql += " AND SB2.D_E_L_E_T_ = ' ' "
    cSql += " WHERE SCP.CP_FILIAL = '" + xFilial('SCP') + "' "
    cSql += " AND SCP.CP_NUM >= '" + mv_par01 + "' "
    cSql += " AND SCP.CP_NUM <= '" + mv_par02 + "' "
    cSql += " AND SCP.CP_EMISSAO >= '" + DToS(mv_par03) + "' "
    cSql += " AND SCP.CP_EMISSAO <= '" + DToS(mv_par04) + "' "
    cSql += " AND SCP.D_E_L_E_T_ = ' ' "
    cSql += " ORDER BY SCP.CP_NUM "
    
    cSql := ChangeQuery(cSql)
    DbUseArea(.T., "TOPCONN", TCGenQry(,,cSql), cAlias, .F., .T.)

    Return((cAlias)->(EOF()))

/*/{Protheus.doc} GeraGrid
cria o grid linha a linha 
@type function
@version  
@author Rubens_
@since 21/03/2025
@param lCor, logical, param_description
@return variant, return_description
/*/
static Function  GeraGrid(lCor)
	 
	if !lCor
		oPrinter:Line( nlin-9, 0, nlin-9                   , nColFim)


		nInVert:=10
		nFimVert:=10
	else
		oPrinter:Line( nlin, 0, nlin                   , nColFim)
		nInVert:=0
		nFimVert:=25
	ENDIF
	nCol:=0
	nColItem:=0
	oPrinter:Line( nlin-nInVert, nColItem, nlin+nFimVert, nColItem,if (lCor, CLR_BLACK,CLR_BLACK),,)
	oPrinter:Line( nlin-nInVert, nColItem+30, nlin+nFimVert, nColItem+30,if (lCor, CLR_BLACK,CLR_BLACK),,)
	nCol+=30
	nColLoc:=nCol
	oPrinter:Line( nlin-nInVert, nColLoc+If(nlay==1,68,68), nlin+nFimVert, nColLoc+If(nlay==1,68,68), if (lCor, CLR_BLACK,CLR_BLACK),,)
	nCol+=68
	nColProd:=nCol
	oPrinter:Line( nlin-nInVert, nColProd+If(nlay==1,60,80), nlin+nFimVert, nColProd+If(nlay==1,60,80), if (lCor, CLR_BLACK,CLR_BLACK),,)
	nCol+=60
	nColsDes:=nCol
	oPrinter:Line( nlin-nInVert, nColsDes+If(nlay==1,130,130), nlin+nFimVert, nColsDes+If(nlay==1,130,130), if (lCor, CLR_BLACK,CLR_BLACK),,)
	nCol+=130
	nColun:=nCol
	oPrinter:Line( nlin-nInVert, nColun+If(nlay==1,20,20), nlin+nFimVert, nColun+If(nlay==1,20,20), if (lCor, CLR_BLACK,CLR_BLACK),,)
	nCol+=20
	nColqtdSol:=nCol
	oPrinter:Line( nlin-nInVert, nColqtdSol+60, nlin+nFimVert, nColqtdSol+60, if (lCor, CLR_BLACK,CLR_BLACK),,)
	nCol+=60
	nColsQtdEnt:=nCol
	oPrinter:Line( nlin-nInVert, nColsQtdEnt+If(nlay==1,70,70), nlin+nFimVert, nColsQtdEnt+If(nlay==1,70,70), if (lCor, CLR_BLACK,CLR_BLACK),,)
	nCol+=70
	nColsSld:=nCol
	oPrinter:Line( nlin-nInVert, nColsSld+If(nlay==1,55,55), nlin+nFimVert, nColsSld+If(nlay==1,55,55), if (lCor, CLR_BLACK,CLR_BLACK),,)
	nCol+=55
	nColiNVE:=       nCol
	oPrinter:Line( nlin-nInVert, nColiNVE+If(nlay==1,60,100), nlin+nFimVert, nColiNVE+If(nlay==1,60,40), if (lCor, CLR_BLACK,CLR_BLACK),,)
	nCol+=60
	nColdTnEC:=nCol
	oPrinter:Line( nlin-nInVert, nColFim, nlin+nFimVert, nColFim,if (lCor, CLR_BLACK,CLR_BLACK),,)


return()
