#Include "Totvs.ch"

/*/{Protheus.doc} User Function OZ04R99
Relatorio Conferencia pós inventario
@author Antonio NUNES
@since 09/07/2024
@version 1.0
@type function
/*/

User Function OZ04R99()
	Local aArea := FWGetArea()
	Local aPergs   := {}
	Local xPar0 := Space(10)
	Local xPar1 := Space(10)
	Local xPar2 := sToD("")
	Local xPar3 := sToD("")
	Local xPar4 := Space(TamSx3("B2_FILIAL")[1])
	Local xPar5 := Space(TamSx3("B2_FILIAL")[1])
	Local xPar6 := Space(TamSx3("B2_LOCAL")[1])
	Local xPar7 := Space(TamSx3("B2_LOCAL")[1])

	aAdd(aPergs, {1, "Produto de", xPar0,  "", ".T.", "SB1", ".T.", 80,  .F.})
	aAdd(aPergs, {1, "Produto ate", xPar1,  "", ".T.", "SB1", ".T.", 80,  .F.})
	aAdd(aPergs, {1, "Data de", xPar2,  "", ".T.", "", ".T.", 80,  .F.})
	aAdd(aPergs, {1, "Data ate", xPar3,  "", ".T.", "", ".T.", 80,  .F.})
	
	aAdd(aPergs, {1, "Filial de", xPar4,  "", ".T.", "SM0", ".T.", 10,  .F.})
	aAdd(aPergs, {1, "Filial ate", xPar5,  "", ".T.", "SM0", ".T.", 10,  .F.})
	aAdd(aPergs, {1, "Armazem de", xPar6,  "", ".T.", "NNR", ".T.", 10,  .F.})
	aAdd(aPergs, {1, "Armazem ate", xPar7,  "", ".T.", "NNR", ".T.", 10,  .F.})
	
	If ParamBox(aPergs, 'Informe os parâmetros', /*aRet*/, /*bOk*/, /*aButtons*/, /*lCentered*/, /*nPosx*/, /*nPosy*/, /*oDlgWizard*/, /*cLoad*/, .F., .F.)
		Processa({|| fGeraExcel()})
	EndIf
	
	FWRestArea(aArea)
Return

/*/{Protheus.doc} fGeraExcel
Criacao do arquivo Excel na funcao OZ04R99
@author Antonio NUNES
@since 09/07/2024
@version 1.0
@type function
/*/

Static Function fGeraExcel()
	Local aArea       := FWGetArea()
	Local oPrintXlsx
	Local dData       := Date()
	Local cHora       := Time()
	Local cArquivo    := GetTempPath() + 'OZ04R99' + dToS(dData) + '_' + StrTran(cHora, ':', '-') + '.rel'
	Local cQryDad     := ''
	Local nAtual      := 0
	Local nTotal      := 0
	Local aColunas    := {}
	Local oExcel
	Local cFonte      := FwPrinterFont():Arial()
	Local nTamFonte   := 12
	Local lItalico    := .F.
	Local lNegrito    := .T.
	Local lSublinhado := .F.
	Local nCpoAtual   := 0
	Local oCellHoriz  := FwXlsxCellAlignment():Horizontal()
	Local oCellVerti  := FwXlsxCellAlignment():Vertical()
	Local cHorAlinha  := ''
	Local cVerAlinha  := ''
	Local lQuebrLin   := .F.
	Local nRotation   := 0
	Local cCustForma  := ''
	Local cCampoAtu   := ''
	Local cTipo       := ''
	Local cCorFundo   := ''
	Local cCorPreto   := '000000'
	Local cCorBranco  := 'FFFFFF'
	Local cCorTxtCab  := '5D9CD5'
	Local cCorFunPad  := 'DDEBF7'
	
	cQryDad += " SELECT DISTINCT '02' AS TIPO, " + CRLF
	cQryDad += " SBF.BF_FILIAL, 		" + CRLF
	cQryDad += " SBF.BF_PRODUTO, 		" + CRLF
	cQryDad += " SBF.BF_LOCALIZ, 		" + CRLF
	cQryDad += " SBF.BF_QUANT, 			" + CRLF
	cQryDad += " 0 AS D1_QUANT,  		" + CRLF
	cQryDad += " B1_COD, 				" + CRLF
	cQryDad += " B1_UM, 				" + CRLF
	cQryDad += " B1_DESC, 				" + CRLF
	cQryDad += " B1_MSBLQL, 			" + CRLF
	cQryDad += " B1_LOCALIZ,  		    " + CRLF
	cQryDad += " B2_FILIAL,				" + CRLF 
	cQryDad += " B2_LOCAL, 				" + CRLF
	cQryDad += " B2_QEMP, 				" + CRLF
	cQryDad += " B2_QATU, 				" + CRLF
	cQryDad += " (B2_QATU - B2_QEMP) ESTOQUEDI, " + CRLF
	cQryDad += " SB2.B2_CM1 AS CUSTOM,   " + CRLF
	cQryDad += " SB2.B2_VATU1 AS VALEST, " + CRLF
	cQryDad += " (SB2.B2_QEMP * SB2.B2_VATU1) AS VALEMP, " + CRLF
	cQryDad += " SB2.B2_USAI AS ULTCOM, " + CRLF
	cQryDad += " SB2.B2_LOCALIZ AS ENDERECO, " + CRLF
	cQryDad += " SBF.BF_QUANT AS SALDEN,  " + CRLF
	cQryDad += "    CASE  "		                                        + CRLF
	cQryDad += "         WHEN SB1.B1_MSBLQL = 1 THEN 'INATIVO'  "	    + CRLF
	cQryDad += "         WHEN SB1.B1_MSBLQL = 2 THEN 'ATIVO'  "		    + CRLF
	cQryDad += "     END AS STATUS,  "		                            + CRLF
	cQryDad += "    CASE  "		                                        + CRLF
	cQryDad += "         WHEN SB1.B1_APROPRI = 'D' THEN 'DIRETA'  "	    + CRLF
	cQryDad += "         WHEN SB1.B1_APROPRI = ' ' THEN 'INDIRETA'  "   + CRLF
	cQryDad += "     END AS APROPR, "		                            + CRLF
	cQryDad += "    CASE  "		                                        + CRLF
	cQryDad += "         WHEN SB1.B1_LOCALIZ = 'S' THEN 'CONTROLA'  "	    + CRLF
	cQryDad += "         WHEN SB1.B1_LOCALIZ = 'N' THEN 'NAO_CONTROLA'  "	+ CRLF
	cQryDad += "     END AS CONTEN  "		                    + CRLF
	cQryDad += " FROM " + RetSQLName('SBF') + " SBF  "	                + CRLF
	cQryDad += " INNER JOIN " + RetSQLName('SB1') + " SB1 ON 1=1  "		    + CRLF
	cQryDad += "     AND SB1.B1_COD = SBF.BF_PRODUTO  "		                + CRLF
	cQryDad += "     AND SB1.B1_COD BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' " + CRLF
	cQryDad += "     AND SB1.D_E_L_E_T_ = ' '  "		                    + CRLF
	cQryDad += " INNER JOIN " + RetSQLName('SB2') + " SB2 ON 1=1 "	    + CRLF
	cQryDad += "     AND SB2.B2_FILIAL = SBF.BF_FILIAL  "		            + CRLF
	cQryDad += "     AND SB2.B2_COD = SBF.BF_PRODUTO  "		                + CRLF
	cQryDad += "     AND SB2.B2_LOCAL = SBF.BF_LOCAL  "		                + CRLF  
	cQryDad += "     AND SB2.D_E_L_E_T_ = ' '  "		                    + CRLF
	cQryDad += " LEFT JOIN " + RetSQLName('SDB') + " SDB ON 1=1 "		    + CRLF
	cQryDad += "     AND SDB.DB_FILIAL = SBF.BF_FILIAL  "		            + CRLF
	cQryDad += "     AND SDB.DB_PRODUTO = SBF.BF_PRODUTO  "		            + CRLF
	cQryDad += "     AND SDB.DB_LOCAL = SBF.BF_LOCAL  "		                + CRLF
	cQryDad += "     AND SDB.DB_LOCALIZ = SBF.BF_LOCALIZ  "		            + CRLF
	cQryDad += "     AND SDB.D_E_L_E_T_ = ' '  "		                    + CRLF
	cQryDad += " WHERE 1=1  "		                                        + CRLF
	cQryDad += "     AND SB2.B2_FILIAL BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' " + CRLF
	cQryDad += "     AND SB2.B2_LOCAL BETWEEN  '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' " + CRLF
	cQryDad += "     AND SB1.B1_LOCALIZ = 'S'  "		                    + CRLF
	cQryDad += " 	 AND SB2.B2_USAI BETWEEN '" + dToS(MV_PAR03) + "' AND '" + dToS(MV_PAR04) + "' "	+ CRLF
	cQryDad += "  ORDER BY SBF.BF_FILIAL, SBF.BF_PRODUTO,  SB2.B2_LOCAL   "	+ CRLF
		
	u_ChangeQuery("\sql\RelatorioInvetario.sql", @cQryDad)

	PlsQuery(cQryDad, "QRY_DAD")
	DbSelectArea("QRY_DAD")
	
	If ! QRY_DAD->(EoF())

		Count To nTotal
		ProcRegua(nTotal)
		QRY_DAD->(DbGoTop())

		aAdd(aColunas, { 'TIPO'  , 'C'  , 'TIPO'  , Len(QRY_DAD->TIPO) * 1.5  , 0  , ''  })
		aAdd(aColunas, { 'B1_COD'  , 'C'  , 'CODIGO'  , Len(QRY_DAD->B1_COD) * 1.5  , 0  , ''  })
		aAdd(aColunas, { 'B1_DESC'  , 'C'  , 'DESCRICAO'  , Len(QRY_DAD->B1_DESC) * 1.5  , 0  , ''  })
		aAdd(aColunas, { 'B1_UM'  , 'C'  , 'U.M.'  , Len(QRY_DAD->B1_UM) * 1.5  , 0  , ''  })
		aAdd(aColunas, { 'B2_FILIAL'  , 'C'  , 'FILIAL'  , Len(QRY_DAD->B2_FILIAL) * 1.5  , 0  , ''  })
		aAdd(aColunas, { 'B2_LOCAL'  , 'C'  , 'ARMAZÉM'  , Len(QRY_DAD->B2_LOCAL) * 1.5  , 0  , ''  })
		aAdd(aColunas, { 'B2_QATU'  , 'N'  , 'SALDO EM ESTOQUE'  , 18  , 0  , '@E 999,999,999,999'  })
		aAdd(aColunas, { 'B2_QEMP'  , 'N'  , 'EMPENHO PARA REQ/PV/'  , 18  , 0  , '@E 999,999,999,999'  })
		aAdd(aColunas, { 'ESTOQUEDI'  , 'N'  , 'ESTOQUE DISPONIVEL'  , 18  , 0  , '@E 999,999,999,999'  })
		aAdd(aColunas, { 'CUSTOM'  , 'N'  , 'CUSTO MÉDIO UNITÁRIO'  , 18  , 0  , '@E 999,999,999,999.99'  })
		aAdd(aColunas, { 'VALEST'  , 'N'  , 'VALOR EM ESTOQUE'  , 18  , 0  , '@E 999,999,999,999.99'  })
		aAdd(aColunas, { 'VALEMP'  , 'N'  , 'VALOR EMPENHADO'  , 18  , 0  , '@E 999,999,999,999.99'  })
		aAdd(aColunas, { 'ULTCOM'  , 'C'  , 'ULT. COMPRA'  , 15  , 0, ''  })
		aAdd(aColunas, { 'ENDERECO'  , 'C'  , 'ENDEREÇO'  , Len(QRY_DAD->ENDERECO) * 1.5  , 0  , ''  })
		aAdd(aColunas, { 'SALDEN'  , 'N'  , 'SALDO NO ENDEREÇO'  , 18  , 0  , '@E 999,999,999,999'  })
		aAdd(aColunas, { 'STATUS'  , 'C'  , 'STATUS'  , Len(QRY_DAD->STATUS) * 1.5  , 0  , ''  })
		aAdd(aColunas, { 'APROPR'  , 'C'  , 'APROPRIAÇÃO'  , Len(QRY_DAD->APROPR) * 1.5  , 0  , ''  })
		aAdd(aColunas, { 'CONTEN'  , 'C'  , 'CONTROLE ENDEREÇO'  , Len(QRY_DAD->CONTEN) * 1.5  , 0  , ''  })
	
		oPrintXlsx := FwPrinterXlsx():New()
		If oPrintXlsx:Activate(cArquivo)

			oPrintXlsx:AddSheet('Inventario')

			nTamFonte := 10
			lNegrito  := .F.
			oPrintXlsx:SetFont(cFonte, nTamFonte, lItalico, lNegrito, lSublinhado)
			
			cHorAlinha  := oCellHoriz:Center()
			cVerAlinha  := oCellVerti:Center()
			oPrintXlsx:SetCellsFormat(cHorAlinha, cVerAlinha, lQuebrLin, nRotation, cCorTxtCab, cCorBranco, cCustForma)

			nLinExcel := 1
			For nAtual := 1 To Len(aColunas)
				oPrintXlsx:SetColumnsWidth(nAtual, nAtual, aColunas[nAtual][4])
				oPrintXlsx:SetText(nLinExcel, nAtual, aColunas[nAtual][3])
			Next

			oPrintXlsx:ApplyAutoFilter(nLinExcel, 1, nLinExcel, Len(aColunas))
			
			nAtual := 0
			While !(QRY_DAD->(EoF()))
				
				nAtual++
				IncProc('Adicionando registro ' + cValToChar(nAtual) + ' de ' + cValToChar(nTotal) + '...')

				If nAtual % 2 != 0
					cCorFundo := cCorFunPad
				Else
					cCorFundo := cCorBranco
				EndIf

				nLinExcel++

				For nCpoAtual := 1 To Len(aColunas)
					cCampoAtu := aColunas[nCpoAtual][1]
					cTipo     := aColunas[nCpoAtual][2]
					xConteud  := &('QRY_DAD->' + cCampoAtu)

					If cTipo == 'D'
						xConteud := dToC(xConteud)

					ElseIf cTipo == 'N'
						If ! Empty(aColunas[nCpoAtual][6])
							xConteud := Alltrim(Transform(xConteud, aColunas[nCpoAtual][6]))

						Else
							xConteud := cValToChar(xConteud)
						EndIf

					Else
						xConteud := Alltrim(xConteud)
					EndIf

					If aColunas[nCpoAtual][5] == 1
						cHorAlinha := oCellHoriz:Right()

					ElseIf aColunas[nCpoAtual][5] == 2
						cHorAlinha := oCellHoriz:Center()

					Else
						cHorAlinha := oCellHoriz:Left()
					EndIf

					oPrintXlsx:ResetCellsFormat()

					oPrintXlsx:SetCellsFormat(cHorAlinha, cVerAlinha, lQuebrLin, nRotation, cCorPreto, cCorFundo, cCustForma)
					
					oPrintXlsx:SetText(nLinExcel, nCpoAtual, xConteud)
				Next
				
				QRY_DAD->(DbSkip())
			EndDo

			oPrintXlsx:ToXlsx()
			oPrintXlsx:DeActivate()

			cArquivo := ChgFileExt(cArquivo, '.xlsx')
			If File(cArquivo)
				oExcel := MsExcel():New()
				oExcel:WorkBooks:Open(cArquivo)
				oExcel:SetVisible(.T.)
				oExcel:Destroy()
			EndIf
		EndIf

	Else
		FWAlertError('Não foi encontrado registros com os filtros informados!', 'Falha')
	EndIf
	QRY_DAD->(DbCloseArea())
	
	FWRestArea(aArea)
Return
