#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "AP5MAIL.CH"
#include "topconn.ch"
#INCLUDE "RPTDEF.CH"  
#INCLUDE "FWPrintSetup.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±                     
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RCOM001  ºAutor ³Toni Aguiar          º Data ³  25/10/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ PEDIDO DE COMPRAS (Emissao em formato Grafico Paisagem)    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Compras                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDATA      ³ ANALISTA ³ MOTIVO                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³          ³                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

// alterar o parametro MV_PCOMPRA e colocar PEDGRF para substituir a impressão padrão.

User Function RCOM010()
Private	lEnd		:= .f.
Private	aAreaSC7	:= SC7->(GetArea())
Private aAreaSA2	:= SA2->(GetArea())
Private	aAreaSA5	:= SA5->(GetArea())
Private	aAreaSF4	:= SF4->(GetArea())
Private	cPerg		:= Padr('PEDGRF',10)
Private	cNumPed  	
Private	lImpPrc		
Private	nTitulo 	
Private	cObserv1	
Private	cObserv2	
Private	cObserv3	
Private	cObserv4	
Private	lPrintCodFor

AjustaSX1(cPerg)

		// Se a Impressão Não Vier da Tela de Pedido de Compras então Efetua Pergunta de Parâmetros
		// Caso contrário então posiciona no pedido que foi clicado a opção imprimir.

		If Upper(ProcName(2)) <> 'A120IMPRI'
           	If !Pergunte(cPerg,.t.)
           		Return
           	Endif

			cNumPed  	:= mv_par01			// Numero do Pedido de Compras
			lImpPrc		:= (mv_par02==2)	// Imprime os Precos ?
			nTitulo 	:= mv_par03			// Titulo do Relatorio ?
			cObserv1	:= mv_par04			// 1a Linha de Observacoes
			cObserv2	:= mv_par05			// 2a Linha de Observacoes
			cObserv3	:= mv_par06			// 3a Linha de Observacoes
			cObserv4	:= mv_par07			// 4a Linha de Observacoes
			lPrintCodFor:= (mv_par08==1)	// Imprime o Cvvvvvvvvvvvvvvvvvvvvvvvvvvvodigo do produto no fornecedor ?

  		Else

			cNumPed  	:= SC7->C7_NUM		// Numero do Pedido de Compras
			lImpPrc		:= .t.				// Imprime os Precos ?
			nTitulo 	:= 2				// Titulo do Relatorio ?
			cObserv1	:= ''				// 1a Linha de Observacoes
			cObserv2	:= ''				// 2a Linha de Observacoes
			cObserv3	:= ''				// 3a Linha de Observacoes
			cObserv4	:= ''				// 4a Linha de Observacoes
			lPrintCodFor:= .f.				// Imprime o Codigo do produto no fornecedor ?
  		Endif

		DbSelectArea('SC7')
		SC7->(DbSetOrder(1))
		If	( ! SC7->(DbSeek(xFilial('SC7') + cNumPed)) )
			Help('',1,'PEDGRF',,OemToAnsi('Pedido não encontrado.'),1)
			Return .f.
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Executa a rotina de impressao ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Processa({ |lEnd| xPrintRel(),OemToAnsi('Gerando o relatório.')}, OemToAnsi('Aguarde...'))
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Restaura a area anterior ao processamento. !³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RestArea(aAreaSC7)
		RestArea(aAreaSA2)
		RestArea(aAreaSA5)
	 //	RestArea(aAreaSZF)
		RestArea(aAreaSF4)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ xPrintRelºAutor ³Toni Aguiar          º Data ³  10/09/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Imprime a Duplicata...                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Funcao Principal                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDATA      ³ ANALISTA ³ MOTIVO                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³          ³                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function xPrintRel()
Local _nT
	cFileLogo := "LGRL.bmp"
	If !File(cFileLogo)
		cFileLogo := "LGMID01.bmp" //"lgrl" + cEmpAnt + cFilAnt + ".bmp"
	EndIf

Private lEmail		:= .f.
Private	lFlag		:= .t.,;	// Controla a impressao do fornecedor
		nLinha		:= 3000,;	// Controla a linha por extenso
		nLinFim		:= 0,;		// Linha final para montar a caixa dos itens
		lPrintDesTab:= .f.,;	// Imprime a Descricao da tabela (a cada nova pagina)
		cRepres		:= Space(80)

Private	_nQtdReg	:= 0,;		// Numero de registros para intruir a regua
		_nValMerc 	:= 0,;		// Valor das mercadorias
		_nValIPI	:= 0,;		// Valor do I.P.I.
		_nValDesc	:= 0,;		// Valor de Desconto
		_nTotAcr	:= 0,;		// Valor total de acrescimo
		_nTotSeg	:= 0,;		// Valor de Seguro
		_nTotFre	:= 0,;		// Valor de Frete
		_nTotIcmsRet:= 0		// Valor do ICMS Retido

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Posiciona nos arquivos necessarios. !³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea('SA2')
		SA2->(DbSetOrder(1))
		If	! SA2->(DbSeek(xFilial('SA2')+SC7->(C7_FORNECE+C7_LOJA)))
			Help('',1,'REGNOIS')
			Return .f.
		EndIf
   /*		
		If MsgYesNo("Deseja Enviar Pedido de Compra por Email ?") 
			lEmail := .t.
		Endif
   */
		lViewPDF := !lEmail
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Define que a impressao deve ser RETRATO³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lAdjustToLegacy := .T.   //.F.
		lDisableSetup  := .T.
		cFilename := Criatrab(Nil,.F.)
		oPrint := FWMSPrinter():New(cFilename, IMP_PDF, lAdjustToLegacy, , lDisableSetup,,,,,,,lViewPDF)
	//	oPrint:Setup()
		oPrint:SetResolution(78)
		oPrint:SetLandscape() //ou SetPortrait() // ou SetLandscape()
		oPrint:SetPaperSize(DMPAPER_A4) 
		oPrint:SetMargin(10,10,10,10) // nEsquerda, nSuperior, nDireita, nInferior 
		oPrint:cPathPDF := "C:\TEMP\" // Caso seja utilizada impressão em IMP_PDF 
		cDiretorio := oPrint:cPathPDF
        //oPrint		:= TMSPrinter():New(OemToAnsi('Pedido de Compras')),;
		
Private	oBrush		:= TBrush():New(,4),;
		oPen		:= TPen():New(0,5,CLR_BLACK),;
		cFileLogo	:= GetSrvProfString('Startpath','') + "LGMID01.PNG",;
		oFont07		:= TFont():New( "Arial",,07,,.t.,,,,,.f. )
		oFont08		:= TFont():New( "Arial",,08,,.f.,,,,,.f. )
		oFont08n    := TFont():New( "Arial",,08,,.t.,,,,,.f. )
		oFont09		:= TFont():New( "Arial",,09,,.f.,,,,,.f. )
		oFont10		:= TFont():New( "Arial",,10,,.f.,,,,,.f. )
		oFont10n	:= TFont():New( "Arial",,10,,.t.,,,,,.f. )
		oFont11		:= TFont():New( "Arial",,11,,.f.,,,,,.f. )
		oFont12		:= TFont():New( "Arial",,12,,.f.,,,,,.f. )
		oFont12n	:= TFont():New( "Arial",,14,,.t.,,,,,.f. )
		oFont14		:= TFont():New( "Arial",,14,,.f.,,,,,.f. )
		oFont15		:= TFont():New( "Arial",,15,,.f.,,,,,.f. )
		oFont18		:= TFont():New( "Arial",,18,,.f.,,,,,.f. )
		oFont16		:= TFont():New( "Arial",,16,,.f.,,,,,.f. )
		oFont20		:= TFont():New( "Arial",,20,,.f.,,,,,.f. )
		oFont22		:= TFont():New( "Arial",,22,,.f.,,,,,.f. )
		oFont22n	:= TFont():New( "Arial",,22,,.t.,,,,,.f. )

	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta query !³    //SC7.C7_CODPRF, 
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cSELECT :=	'SC7.C7_FILIAL, SC7.C7_NUM, SC7.C7_EMISSAO, SC7.C7_FORNECE, SC7.C7_LOJA, SC7.C7_COND, SC7.C7_CONTATO, SC7.C7_OBS, '+;
					'SC7.C7_XOBS, SC7.C7_ITEM, SC7.C7_UM, SC7.C7_PRODUTO, SC7.C7_DESCRI, SC7.C7_QUANT, '+;
					'SC7.C7_PRECO, SC7.C7_IPI, SC7.C7_TOTAL, SC7.C7_VLDESC, SC7.C7_DESPESA, '+;
					'SC7.C7_SEGURO, SC7.C7_VALFRE, SC7.C7_TES, SC7.C7_ICMSRET, SC7.C7_DATPRF, SC7.C7_USER, SC7.C7_XTPAPL '

		cFROM   :=	RetSqlName('SC7') + ' SC7 '

		cWHERE  :=	'SC7.D_E_L_E_T_ <>   '+CHR(39) + '*'            +CHR(39) + ' AND '+;
					'SC7.C7_FILIAL  =    '+CHR(39) + xFilial('SC7') +CHR(39) + ' AND '+;
					'SC7.C7_NUM     =    '+CHR(39) + cNumPed        +CHR(39) 

		cORDER  :=	'SC7.C7_FILIAL, SC7.C7_ITEM '

		cQuery  :=	' SELECT '   + cSELECT + ; 
					' FROM '     + cFROM   + ;
					' WHERE '    + cWHERE  + ;
					' ORDER BY ' + cORDER

		TCQUERY cQuery NEW ALIAS 'TRA'   
		
		TcSetField('TRA','C7_DATPRF','D')

		If	! USED()
			MsgBox(cQuery+'. Query errada','Erro!!!','STOP')
		EndIf

		DbSelectArea('TRA')
		Count to _nQtdReg
		ProcRegua(_nQtdReg)
		TRA->(DbGoTop())

		cCompr := TRA->C7_USER
		
		cTipoSC7	:= IIF((SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3),"PC","AE")
		cComprador 	:= UsrFullName(SC7->C7_USER)
		cAlter	 	:= ''
		cAprov	 	:= ''

		If !Empty(SC7->C7_GRUPCOM)
			dbSelectArea("SAJ")
			dbSetOrder(1)
			dbSeek(xFilial("SAJ")+SC7->C7_GRUPCOM)
			While !Eof() .And. SAJ->AJ_FILIAL+SAJ->AJ_GRCOM == xFilial("SAJ")+SC7->C7_GRUPCOM
				If SAJ->AJ_USER != SC7->C7_USER
					cAlter += AllTrim(UsrFullName(SAJ->AJ_USER))+"/"
				EndIf
				dbSelectArea("SAJ")
				dbSkip()
			EndDo
		EndIf

		// Aprovadores
		
		dbSelectArea("SCR")
		dbSetOrder(1)
		dbSeek(xFilial("SCR")+cTipoSC7+SC7->C7_NUM)
		While !Eof() .And. SCR->CR_FILIAL+Alltrim(SCR->CR_NUM) == xFilial("SCR")+Alltrim(SC7->C7_NUM) .And. SCR->CR_TIPO == cTipoSC7
			cAprov += AllTrim(UsrFullName(SCR->CR_USER))+" ["
			Do Case
				Case SCR->CR_STATUS=="03" //Liberado
					cAprov += "Ok"
				Case SCR->CR_STATUS=="04" //Bloqueado
					cAprov += "BLQ"
				Case SCR->CR_STATUS=="05" //Nivel Liberado
					cAprov += "##"
				OtherWise                 //Aguar.Lib
					cAprov += "??"
			EndCase
			cAprov += "] - "
			dbSelectArea("SCR")
			dbSkip()
		Enddo

      	cObServ := ''
		While 	TRA->( ! Eof() )

				xVerPag()

				If	( lFlag )
					//ÚÄÄÄÄÄÄÄÄÄÄ¿
					//³Fornecedor³
					//ÀÄÄÄÄÄÄÄÄÄÄÙ
					oPrint:Say(0530,0100,OemToAnsi('Fornecedor:'),oFont10)
					oPrint:Say(0520,0430,AllTrim(SA2->A2_NOME) + '  ('+AllTrim(SA2->A2_COD)+'/'+AllTrim(SA2->A2_LOJA)+')',oFont11)
					oPrint:Say(0580,0100,OemToAnsi('Endereço:'),oFont10)
					oPrint:Say(0580,0430,SA2->A2_END,oFont11)
					oPrint:Say(0630,0100,OemToAnsi('Município/U.F.:'),oFont10)
					oPrint:Say(0630,0430,AllTrim(SA2->A2_MUN)+'/'+AllTrim(SA2->A2_EST),oFont11)
					oPrint:Say(0630,1100,OemToAnsi('Cep:'),oFont10)
					oPrint:Say(0630,1270,TransForm(SA2->A2_CEP,'@R 99.999-999'),oFont11)
					oPrint:Say(0680,0100,OemToAnsi('Telefone:'),oFont10)
					oPrint:Say(0680,0430,SA2->A2_TEL,oFont11)
					oPrint:Say(0680,1100,OemToAnsi('CNPJ:'),oFont10)
					oPrint:Say(0680,1270,Transform(SA2->A2_CGC,'@R 99.999.999/9999-99'),oFont11)
					oPrint:Say(0730,0100,OemToAnsi('Contato:'),oFont10)
					oPrint:Say(0730,0430,SC7->C7_CONTATO,oFont11)
					oPrint:Say(0730,1100,OemToAnsi('Email:'),oFont10)
					oPrint:Say(0730,1270,SA2->A2_EMAIL,oFont11)
					
					cObserv := SC7->C7_XOBS

                     
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Numero/Emissao³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					oPrint:Box(0530,1900,0700,2250)
					oPrint:Say(0550,1960,OemToAnsi('Numero documento'),oFont10n)
					oPrint:Say(0600,2000,SC7->C7_NUM,oFont18)
					oPrint:Say(0650,2000,Dtoc(SC7->C7_EMISSAO),oFont12n)
					lFlag := .f.
				EndIf
				
				If	( lPrintDesTab )
					oPrint:Box(nLinha-30,100,nLinha+40,3150) 
					oPrint:Say(nLinha+10,0120,OemToAnsi('It'),oFont12n)
					oPrint:Say(nLinha+10,0180,OemToAnsi('Cód.'),oFont12n)
					oPrint:Say(nLinha+10,0340,OemToAnsi('Descrição Esp'),oFont12n)
					oPrint:Say(nLinha+10,1000,OemToAnsi('Un'),oFont12n)
					oPrint:Say(nLinha+10,1100,OemToAnsi('Qtde'),oFont12n)
					oPrint:Say(nLinha+10,1200,OemToAnsi('Vlr.Unit.'),oFont12n)
					oPrint:Say(nLinha+10,1500,OemToAnsi('Ipi %'),oFont12n)
					oPrint:Say(nLinha+10,1800,OemToAnsi('Vlr. Ipi'),oFont12n)
					oPrint:Say(nLinha+10,2000,OemToAnsi('Icms %'),oFont12n)
					oPrint:Say(nLinha+10,2200,OemToAnsi('Vlr. Icms'),oFont12n)
					oPrint:Say(nLinha+10,2500,OemToAnsi('Valor Total'),oFont12n)
					oPrint:Say(nLinha+10,2800,OemToAnsi('TP'),oFont12n)
					//oPrint:Say(nLinha+10,3000,OemToAnsi('Pr.Entrega'),oFont12n)
					//oPrint:Say(nLinha+10,3200,OemToAnsi('C.Custo'),oFont12n)
					lPrintDesTab := .f.
					nLinha += 70
				EndIf

				oPrint:Say(nLinha,0120,Right(TRA->C7_ITEM,2),oFont10n)
				cCodPro := ''
				If	( lPrintCodFor )
					DbSelectArea('SA5')
					SA5->(DbSetOrder(1))
					If	SA5->(DbSeek(xFilial('SA5') + SA2->A2_COD + SA2->A2_LOJA + TRA->C7_PRODUTO)) .and. ( ! Empty(SA5->A5_CODPRF) )
						cCodPro := SA5->A5_CODPRF
					Else
						cCodPro := TRA->C7_PRODUTO
					EndIf
				Else
					cCodPro := TRA->C7_PRODUTO
				EndIf	
				oPrint:Say(nLinha,1380,TRA->C7_UM,oFont10)
			   //	oPrint:Say(nLinha,1310,DtoC(TRA->C7_DATPRF),oFont10n,,,,1)
			    oPrint:Say(nLinha,1600,Alltrim(TransForm(TRA->C7_QUANT,'@E 99,999,999')),oFont10n,,,,1)

				If	( lImpPrc )
					oPrint:Say(nLinha,1700,AllTrim(TransForm(TRA->C7_PRECO,'@E 999,999.999999')),oFont10n,,,,1)
					oPrint:Say(nLinha,1950,AllTrim(TransForm(TRA->C7_IPI,'@E 99.9')),oFont10n,,,,1)
					oPrint:Say(nLinha,2150,AllTrim(TransForm(TRA->C7_TOTAL,'@E 999,999.99')),oFont10n,,,,1)
				EndIf

				SB1->(dbSetOrder(1), dbSeek(xFilial("SB1")+TRA->C7_PRODUTO))
				If !SB5->(dbSetOrder(1), dbSeek(xFilial("SB5")+TRA->C7_PRODUTO))
					cDesc := AllTrim(TRA->C7_DESCRI)//SB1->B1_DESC)
				Else
					cDesc := AllTrim(SB5->B5_CEME)
				Endif
				
				nLinCod := MlCount(cCodPro,10)

				_nLinhas := MlCount(cDesc,45)

				For _nT := 1 To Max(_nLinhas,nLinCod)
					If _nT <= nLinCod
						oPrint:Say(nLinha,0180,MemoLine(cCodPro,10,_nT),oFont10)
        			Endif
					If _nT <= _nLinhas
						oPrint:Say(nLinha,0340,Capital(MemoLine(cDesc,45,_nT)),oFont10,,0)
					Endif
					nLinha+=30

				Next _nT

				oPrint:Line(nLinha,100,nLinha,3150)

				nLinha+=30

				_nValMerc 		+= TRA->C7_TOTAL
				_nValIPI		+= (TRA->C7_TOTAL * TRA->C7_IPI) / 100
				_nValDesc		+= TRA->C7_VLDESC
				_nTotAcr		+= TRA->C7_DESPESA
				_nTotSeg		+= TRA->C7_SEGURO
				_nTotFre		+= TRA->C7_VALFRE

				If	( Empty(TRA->) )
					_nTotIcmsRet	+= TRA->C7_ICMSRET
				Else
					DbSelectArea('SF4')
					SF4->(DbSetOrder(1))
					If	SF4->(DbSeek(xFilial('SF4') + TRA->C7_TES))
						If	( AllTrim(SF4->F4_INCSOL) == 'S' )
							_nTotIcmsRet	+= TRA->C7_ICMSRET
						EndIf
					EndIf
				EndIf

				//cObserv += AllTrim(TRA->C7_OBS)+' ' 
			IncProc()
			TRA->(DbSkip())	

		End
		nLinha-=30

		xVerPag()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                            
		//³Imprime TOTAL DE MERCADORIAS³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If	( lImpPrc )
			oPrint:Line(nLinha,1390,nLinha+80,1390)
			oPrint:Line(nLinha,1900,nLinha+80,1900)
			oPrint:Line(nLinha,3150,nLinha+80,3150)
			oPrint:Say(nLinha+30,1400,'Valor Mercadorias ',oFont12)
			oPrint:Say(nLinha+30,2050,TransForm(_nValMerc,'@E 9,999,999.99'),oFont11,,,,1)
			nLinha += 80
			oPrint:Line(nLinha,1390,nLinha,3150)
		EndIf

		xVerPag()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime TOTAL DE I.P.I. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If	( lImpPrc )// .and. ( _nValIpi > 0 )
			oPrint:Line(nLinha,1390,nLinha+80,1390)
			oPrint:Line(nLinha,1900,nLinha+80,1900)
			oPrint:Line(nLinha,3150,nLinha+80,3150)
			oPrint:Say(nLinha+30,1400,'Valor de I. P. I. (+)',oFont12)
			oPrint:Say(nLinha+30,2050,TransForm(_nValIpi,'@E 9,999,999.99'),oFont11,,,,1)
			nLinha += 80
			oPrint:Line(nLinha,1390,nLinha,3150)
		EndIf

		xVerPag()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime TOTAL DE DESCONTO³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If	( lImpPrc ) .and. ( _nValDesc > 0 )
			oPrint:Line(nLinha,1390,nLinha+80,1390)
			oPrint:Line(nLinha,1900,nLinha+80,1900)
			oPrint:Line(nLinha,3150,nLinha+80,3150)
			oPrint:Say(nLinha+30,1400,'Valor de Desconto (-)',oFont12)
			oPrint:Say(nLinha+30,2050,TransForm(_nValDesc,'@E 9,999,999.99'),oFont11,,,,1)
			nLinha += 80
			oPrint:Line(nLinha,1390,nLinha,3150)
		EndIf

		xVerPag()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime TOTAL DE ACRESCIMO ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If	( lImpPrc ) .and. ( _nTotAcr > 0 )
			oPrint:Line(nLinha,1390,nLinha+80,1390)
			oPrint:Line(nLinha,1900,nLinha+80,1900)
			oPrint:Line(nLinha,3150,nLinha+80,3150)
			oPrint:Say(nLinha+30,1400,'Valor de Acresc. (+)',oFont12)
			oPrint:Say(nLinha+30,2050,TransForm(_nTotAcr,'@E 9,999,999.99'),oFont11,,,,1)
			nLinha += 80
			oPrint:Line(nLinha,1390,nLinha,3150)
		EndIf

		xVerPag()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime TOTAL DE SEGURO ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If	( lImpPrc ) .and. ( _nTotSeg > 0 )
			oPrint:Line(nLinha,1390,nLinha+80,1390)
			oPrint:Line(nLinha,1900,nLinha+80,1900)
			oPrint:Line(nLinha,3150,nLinha+80,3150)
			oPrint:Say(nLinha+30,1400,'Valor de Seguro (+)',oFont12)
			oPrint:Say(nLinha+30,2050,TransForm(_nTotSeg,'@E 9,999,999.99'),oFont11,,,,1)
			nLinha += 80
			oPrint:Line(nLinha,1390,nLinha,3150)
		EndIf

		xVerPag()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime TOTAL DE FRETE ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If	( lImpPrc ) .and. ( _nTotFre > 0 )
			oPrint:Line(nLinha,1390,nLinha+80,1390)
			oPrint:Line(nLinha,1900,nLinha+80,1900)
			oPrint:Line(nLinha,3150,nLinha+80,3150)
			oPrint:Say(nLinha+30,1400,'Valor de Frete (+)',oFont12)
			oPrint:Say(nLinha+30,2050,TransForm(_nTotFre,'@E 9,999,999.99'),oFont11,,,,1)
			nLinha += 80
			oPrint:Line(nLinha,1390,nLinha,3150)
		EndIf

		xVerPag()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime ICMS RETIDO    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If	( lImpPrc ) //.and. ( _nTotIcmsRet > 0 )
			oPrint:Line(nLinha,1390,nLinha+80,1390)
			oPrint:Line(nLinha,1900,nLinha+80,1900)
			oPrint:Line(nLinha,3150,nLinha+80,3150)
			oPrint:Say(nLinha+30,1400,'Valor de ICMS Retido',oFont12)
			oPrint:Say(nLinha+30,2050,TransForm(_nTotIcmsRet,'@E 9,999,999.99'),oFont11,,,,1)
			nLinha += 80
			oPrint:Line(nLinha,1390,nLinha,3150)
		EndIf

		xVerPag()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime o VALOR TOTAL !³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//		oPrint:FillRect({nLinha,1390,nLinha+80,3150},oBrush)
		oPrint:Line(nLinha,1390,nLinha+80,1390)
		oPrint:Line(nLinha,1900,nLinha+80,1900)
		oPrint:Line(nLinha,3150,nLinha+80,3150)
		oPrint:Say(nLinha+30,1400,'VALOR TOTAL ',oFont12)
		If	( lImpPrc )
			oPrint:Say(nLinha+30,2050,TransForm(_nValMerc + _nValIPI - _nValDesc + _nTotAcr	+ _nTotSeg + _nTotFre + _nTotIcmsRet,'@E 9,999,999.99'),oFont11,,,,1)
		EndIf
		nLinha += 80
		xVerPag()
		oPrint:Line(nLinha,1390,nLinha,3150)
		nLinha += 70

		xVerPag()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime as observacoes dos parametros. !³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		cObserv1 := Left(cObserv,70)
		cObserv2 := SubStr(cObserv,71,70)
		cObserv3 := SubStr(cObserv,141,70)
		cObserv4 := SubStr(cObserv,211,70)
		
		oPrint:Say(nLinha,0100,OemToAnsi('Observações/USO:'),oFont12)
		oPrint:Say(nLinha,0500,cObserv1,oFont12n)
		nLinha += 60
		xVerPag()
		If	( ! Empty(cObserv2) )
			oPrint:Say(nLinha,0500,cObserv2,oFont12n)
			nLinha += 60
			xVerPag()
		EndIf	
		If	( ! Empty(cObserv3) )
			oPrint:Say(nLinha,0500,cObserv3,oFont12n)
			xVerPag()
			nLinha += 60
		EndIf	
		If	( ! Empty(cObserv4) )
			oPrint:Say(nLinha,0500,cObserv4,oFont12n)
			xVerPag()
			nLinha += 60
			xVerPag()
		EndIf

		nLinha += 20
		xVerPag()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime o Representante comercial do fornecedor³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
		/*
		DbSelectArea('SZF')
		SZF->(DbSetOrder(1))
		If	SZF->(DbSeek(xFilial('SZF') + SA2->A2_COD + SA2->A2_LOJA))
			If	( ! Empty(SZF->ZF_REPRES) )
				oPrint:Say(nLinha,0100,OemToAnsi('Representante:'),oFont12)
				oPrint:Say(nLinha,0500,AllTrim(SZF->ZF_REPRES) + Space(5) + AllTrim(SZF->ZF_TELREPR) + Space(5) + AllTrim(SZF->ZF_FAXREPR),oFont12n)
				nLinha += 60
				xVerPag()
			EndIf
		EndIf	
        */
		nLinha += 20
		xVerPag()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime a linha de prazo pagamento/entrega!³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oPrint:Say(nLinha,0100,OemToAnsi('Prazo Pagamento:'),oFont12)
		If !Empty(SC7->C7_COND)
			If SE4->(dbSetOrder(1), dbSeek(xFilial("SE4")+SC7->C7_COND))
				oPrint:Say(nLinha,0500,SE4->E4_CODIGO + ' - ' + SE4->E4_DESCRI,oFont12n)
			Endif
		Else
			oPrint:Say(nLinha,0500,'_____________________',oFont12n)
		Endif
		nLinha += 60  
		oPrint:Say(nLinha,0100,'Informações para o fornecedor',oFont12n)
		nLinha += 60 //A2_BANFOR1,A2_AGFORN1,A2_CCBFOR1,A2_BANFOR2,A2_AGFORN2,A2_CCBFOR2
		//--oPrint:Say(nLinha,0100,Alltrim(SA2->A2_BANFOR1)+" | "+Alltrim(SA2->A2_AGFORN1)+" | "+Alltrim(SA2->A2_CCBFOR1),oFont12n)
		oPrint:Say(nLinha,0100,"Incluir o número da ordem de compras na nota fiscal;",oFont12)
		nLinha += 50
		oPrint:Say(nLinha,0100,"Enviar a NF-e e o boleto bancário para o e-mail:  nfe.carajas@ozminerals.com; ",oFont12)
		nLinha += 50
		oPrint:Say(nLinha,0100,"As notas fiscais, deverão ser emitidas até o dia 28 do mês. Notas fiscais emitidas após essa data, não serão aceitas.;",oFont12)
		nLinha += 50
		oPrint:Say(nLinha,0100,"Os pagamentos serão efetuados nos dias de terças e quintas-feiras.; ",oFont12)
		nLinha += 50
		oPrint:Say(nLinha,0100,"(Gentileza adequar o vencimento do seu boleto para esses dias). ",oFont12)
		nLinha += 60

		//--oPrint:Say(nLinha,0100,Alltrim(SA2->A2_BANFOR2)+" | "+Alltrim(SA2->A2_AGFORN2)+" | "+Alltrim(SA2->A2_CCBFOR2),oFont12n)
//		oPrint:Say(nLinha,1120,OemToAnsi('Prazo Entrega:'),oFont12)
//		oPrint:Say(nLinha,1500,'___________________________',oFont12n)
		nLinha += 60
  		xVerPag()

		nLinha += 20
		xVerPag()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime a linha de transportadora !³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*		oPrint:Say(nLinha,0100,OemToAnsi('Transportadora:'),oFont12)
		oPrint:Say(nLinha,0500,'____________________________________________________',oFont12n)*/
		nLinha += 60
		xVerPag()

		nLinha += 20
		xVerPag()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime o Contato.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If	( ! Empty(SA2->A2_CONTATO) )
			oPrint:Say(nLinha,0100,OemToAnsi('Contato: '),oFont12)
			oPrint:Say(nLinha,0500,SA2->A2_CONTATO,oFont12n)
			nLinha += 60
			xVerPag()
		EndIf

		oPrint:Line(nLinha,0100,nLinha,3150)
		nLinha += 10
		xVerPag()

		xRodape()

		TRA->(DbCloseArea())

		
/*		If !Empty(_nQtdReg)
			U_EPed(cNumPed,'')					
		Endif
  */		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime em Video, e finaliza a impressao. !³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		oPrint:Preview()
		
		If lEmail
			U_xPedMail()
		Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ xCabec() ºAutor ³ Toni Aguiar         º Data ³  25/10/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Imprime o Cabecalho do relatorio...                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Funcao Principal                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDATA      ³ ANALISTA ³  MOTIVO                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³          ³                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function xCabec()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime o cabecalho da empresa. !³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
		oPrint:Box(0010,0050,2300,3200)    
		oPrint:SayBitmap(050,1700,cFileLogo,1050,260)
		oPrint:Say(050,0100,AllTrim(Upper(SM0->M0_NOMECOM)),oFont16)
		oPrint:Say(135,0100,AllTrim(SM0->M0_ENDCOB),oFont11)
		oPrint:Say(180,0100,Capital(AllTrim(SM0->M0_CIDCOB))+'/'+AllTrim(SM0->M0_ESTCOB)+ '  -  ' + AllTrim(TransForm(SM0->M0_CEPCOB,'@R 99.999-999')) + '  -  ' + AllTrim(SM0->M0_TEL),oFont11)
		oPrint:Say(225,0100,AllTrim('www.avanco.com.br'),oFont11)
		oPrint:Line(265,0100,265,2270)
		oPrint:Say(300,0100,TransForm(SM0->M0_CGC,'@R 99.999.999/9999-99'),oFont12)
		oPrint:Say(300,550,SM0->M0_INSC,oFont12)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Titulo do Relatorio³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If	( nTitulo == 1 ) // Cotacao
			oPrint:Say(0400,1300,OemToAnsi('Cotação de Compras'),oFont22)
		Else
			oPrint:Say(0400,1300,OemToAnsi('Pedido de Compras'),oFont22)
		EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ xRodape()ºAutor ³Luis Henrique Robustoº Data ³  25/10/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Imprime o Rodape do Relatorio....                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Funcao Principal                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDATA      ³ ANALISTA ³  MOTIVO                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³          ³                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function xRodape()

//oPrint:Say(2910,0100,'NOTA: So aceitaremos a mercadoria se na sua Nota Fiscal constar o numero do nosso Pedido de Compras. ',oFont12n)
oPrint:Line(2950,0100,2950,3150)     
oPrint:Say(2990,0100,"Comprador Responsavel  : "+Substr(cComprador,1,60),oFont11)
oPrint:Say(3030,0100,"Comprador Alternativos : "+If( Len(cAlter) > 0 , Substr(cAlter,001,130) , " " ),oFont11)
//oPrint:Say(3070,0500,If( Len(cAlter) > 0 , Substr(cAlter,131,130) , " " ),oFont11)
oPrint:Say(3070,0100,"Aprovador(es) : "+If( Len(cAprov) > 0 , Substr(cAprov,001,140) , " " ),oFont11)
//oPrint:Say(3150,0500,If( Len(cAprov) > 0 , Substr(cAprov,141,140) , " " ),oFont11)
//	oPrint:Line(3080,0100,3080,3150)
//   oPrint:Say(3120,1050,AllTrim(SM0->M0_TEL),oFont16)
//	oPrint:Line(3200,0100,3200,3150	)
/*   oPrint:Say(3150,0100,'ENVIAR CERTIFICADO DE QUALIDADE E MENCIONAR Nº DO NOSSO PEDIDO NA NOTA FISCAL',oFont08n)
   IF SB1->B1_TIPO == 'MP'
	   oPrint:Say(3150,0100,'O PEDIDO REPRESENTA INTENÇÃO DE COMPRAS FIRME, PORÉM AS ENTREGAS OCORRERÃO RESPEITANDO O KANBAN SEMANAL. EVENTUAIS EXCESSOS SERÃO AJUSTADOS NO MÊS POSTERIOR',oFont08n)
	ENDIF
   oPrint:Say(3360,0100,'ENDEREÇO DE ENTREGA = RUA JOÃO NINCÃO, 328 CAPUAVA MAUÁ',oFont08n) 
   oPrint:Say(3390,0100,'NÃO RECEBEREMOS NOTAS COM MAIS DE 24 HORAS DA DATA DE EMISSAO',oFont08n) */
	oPrint:EndPage()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ xVerPag()ºAutor ³Toni Aguiar          º Data ³  25/10/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se deve ou nao saltar pagina...                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Funcao Principal                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDATA      ³ ANALISTA ³  MOTIVO                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³          ³                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function xVerPag()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicia a montagem da impressao.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If	( nLinha >= 2200 )

		If	( ! lFlag )
			xRodape()
			oPrint:EndPage()
			nLinha:= 600
		Else
			nLinha:= 800
		EndIf

		oPrint:StartPage()
		xCabec()

		lPrintDesTab := .t.

	EndIf
	

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AjustaSX1ºAutor ³Toni Aguiar          º Data ³  25/10/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ajusta o SX1 - Arquivo de Perguntas..                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Funcao Principal                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDATA      ³ ANALISTA ³ MOTIVO                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³          ³                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function AjustaSX1(cPerg)
Local	aRegs   := {},;
		_sAlias := Alias(),;
		nX

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Campos a serem grav. no SX1³
		//³aRegs[nx][01] - X1_GRUPO   ³
		//³aRegs[nx][02] - X1_ORDEM   ³
		//³aRegs[nx][03] - X1_PERGUNTE³
		//³aRegs[nx][04] - X1_PERSPA  ³
		//³aRegs[nx][05] - X1_PERENG  ³
		//³aRegs[nx][06] - X1_VARIAVL ³
		//³aRegs[nx][07] - X1_TIPO    ³
		//³aRegs[nx][08] - X1_TAMANHO ³
		//³aRegs[nx][09] - X1_DECIMAL ³
		//³aRegs[nx][10] - X1_PRESEL  ³
		//³aRegs[nx][11] - X1_GSC     ³
		//³aRegs[nx][12] - X1_VALID   ³
		//³aRegs[nx][13] - X1_VAR01   ³
		//³aRegs[nx][14] - X1_DEF01   ³
		//³aRegs[nx][15] - X1_DEF02   ³
		//³aRegs[nx][16] - X1_DEF03   ³
		//³aRegs[nx][17] - X1_F3      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Cria uma array, contendo todos os valores...³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAdd(aRegs,{cPerg,'01','Numero do Pedido   ?','Numero do Pedido   ?','Numero do Pedido   ?','mv_ch1','C', 6,0,0,'G','','mv_par01','','','','SC7'})
		aAdd(aRegs,{cPerg,'02','Imprime precos     ?','Imprime precos     ?','Imprime precos     ?','mv_ch2','N', 1,0,1,'C','','mv_par02',OemToAnsi('Não'),'Sim','',''})
		aAdd(aRegs,{cPerg,'03','Titulo do Relatorio?','Titulo do Relatorio?','Titulo do Relatorio?','mv_ch3','N', 1,0,1,'C','','mv_par03',OemToAnsi('Cotação'),'Pedido','',''})
		aAdd(aRegs,{cPerg,'04',OemToAnsi('Observações'),'Observações         ','Observações         ','mv_ch4','C',70,0,1,'G','','mv_par04','','','',''})
		aAdd(aRegs,{cPerg,'05','                    ','                    ','                    ','mv_ch5','C',70,0,1,'G','','mv_par05','','','',''})
		aAdd(aRegs,{cPerg,'06','                    ','                    ','                    ','mv_ch6','C',70,0,0,'G','','mv_par06','','','',''})
		aAdd(aRegs,{cPerg,'07','                    ','                    ','                    ','mv_ch7','C',70,0,0,'G','','mv_par07','','','',''})
		aAdd(aRegs,{cPerg,'08','Imp. Cod. Prod. For?','Imp. Cod. Prod. For?','Imp. Cod. Prod. For?','mv_ch8','N', 1,0,1,'C','','mv_par08',OemToAnsi('Sim'),OemToAnsi('Não'),'',''})

		DbSelectArea('SX1')
		SX1->(DbSetOrder(1))

		For nX:=1 to Len(aRegs)
			If !SX1->(DbSeek(aRegs[nx][01]+aRegs[nx][02]))
				RecLock('SX1',.t.)
				Replace SX1->X1_GRUPO		With aRegs[nx][01]
				Replace SX1->X1_ORDEM   	With aRegs[nx][02]
				Replace SX1->X1_PERGUNTE	With aRegs[nx][03]
				Replace SX1->X1_PERSPA		With aRegs[nx][04]
				Replace SX1->X1_PERENG		With aRegs[nx][05]
				Replace SX1->X1_VARIAVL		With aRegs[nx][06]
				Replace SX1->X1_TIPO		With aRegs[nx][07]
				Replace SX1->X1_TAMANHO		With aRegs[nx][08]
				Replace SX1->X1_DECIMAL		With aRegs[nx][09]
				Replace SX1->X1_PRESEL		With aRegs[nx][10]
				Replace SX1->X1_GSC			With aRegs[nx][11]
				Replace SX1->X1_VALID		With aRegs[nx][12]
				Replace SX1->X1_VAR01		With aRegs[nx][13]
				Replace SX1->X1_DEF01		With aRegs[nx][14]
				Replace SX1->X1_DEF02		With aRegs[nx][15]
				Replace SX1->X1_DEF03		With aRegs[nx][16]
				Replace SX1->X1_F3   		With aRegs[nx][17]
				MsUnlock('SX1')
			Endif
		Next nX

Return

User Function xPedMail()
Private _PedCom
Private nTarget:=0
Private cFOpen :=""
Private nOpc   := 0
Private bOk    := {||nOpc:=1,_PedCom:End()}
Private bCancel:= {||nOpc:=0,_PedCom:End()} 
Private lCheck1:=.F.
Private lCheck2:=.T.
Private lCheck3:=.f.


_cPara   :=SA2->A2_EMAIL
_cContato:=PadR(SA2->A2_CONTATO,30)

mCorpo := 'Sr.(a): ' + _cContato +Chr(13)+Chr(10)+Chr(13)+Chr(10)
mCorpo += 'Segue Anexo Pedido de Compras: ' + cNumPed +Chr(13)+Chr(10)+Chr(13)+Chr(10)
mCorpo += 'AVB MINERAÇÃO.'+Chr(13)+Chr(10)
mCorpo += 'Fone: 99-99-99999999'+Chr(13)+Chr(10)
mCorpo += 'Site: www.avanco.com.br'+Chr(13)+Chr(10)

Define MsDialog _PedCom Title "Pedido de Compras por Email" From 127,037 To 531,774 Pixel 
@ 013,006 To 053,357 Title OemToAnsi("  Dados do Pedido ") 
@ 020,010 Say "Pedido:" Color CLR_HBLUE // Size 25,8 
@ 020,040 Get cNumPed Picture "@!" When .f.
@ 020,097 Say "Email:" Color CLR_HBLUE //Size 25,8 
@ 020,125 Get _cPara Picture "@" Size 150,08
@ 030,010 Say "Fornecedor: " Color CLR_HBLUE
@ 030,042 Say SA2->A2_NOME Color CLR_HRED Object oCliente //Size 19,8 
@ 040,010 Say "Contato: " Color CLR_HBLUE //Size 25,8 
@ 040,042 Say _cContato Object oAutor
@ 040,042 Get _cContato Picture "@" Size 150,08

@ 80,010 To 182,360
@ 88,015 Get mCorpo MEMO Size 340,90

Activate MsDialog _PedCom On Init EnchoiceBar(_PedCom,bOk,bCancel,,) Centered
If nOpc == 1
	cAnexo := 'C:\TEMP\'+cFilename+'.PDF'
	EnvMail(cAnexo, cNumPed, _cPara, _cContato, mCorpo)
EndIf
Return .t.

Static Function EnvMail(cAnexo,cNumPed,cPara,cContato,mCorpo)
Private cAssunto     := 'Pedido de Compras - No. ' + cNumPed
Private nLineSize    := 60
Private nTabSize     := 3
Private lWrap        := .T. 
Private nLine        := 0
Private cTexto       := ""
Private lServErro	   := .T.
Private cServer  := Trim(GetMV("MV_RELSERV")) // smtp.tecnotron.ind.br
Private cDe 	:= Trim(GetMV("MV_RELACNT"))
Private cPass    := Trim(GetMV("MV_RELPSW"))  // 
Private lAutentic	:= GetMv("MV_RELAUTH",,.F.)
Private aTarget  :={cAnexo}
Private nTarget := 0
Private lCheck1 := .F.
Private lCheck2 := .f.

cCC := UsrRetMail(RetCodUsr())
cAnexos:=cAnexo
CPYT2S(cAnexos,GetSrvProfString("Startpath", "")+'emailanexos\',.T.)
cAnexos:=GetSrvProfString("Startpath", "")+'emailanexos\'+SubStr(AllTrim(cAnexos),RAT('\',AllTrim(cAnexos))+1)
lServERRO 	:= .F.
                    
CONNECT SMTP                         ;
SERVER 	 GetMV("MV_RELSERV"); 	// Nome do servidor de e-mail
ACCOUNT  GetMV("MV_RELACNT"); 	// Nome da conta a ser usada no e-mail
PASSWORD GetMV("MV_RELPSW") ; 	// Senha
Result lConectou    

lRet := .f.
lEnviado := .f.
If lAutentic
	lRet := Mailauth(cDe,cPass)
Endif
If lRet  
	cPara   := Rtrim(cPara)
	cCC		:= Rtrim(cCC)    
	cAssunto:= Rtrim(cAssunto)  
	
//	    	    BCC 'diretoria@metalacre.com.br;gerencia@metalacre.com.br';

	SEND MAIL 	FROM cDe ;
		 		To cPara ;
	    	    CC cCc;
		 		SUBJECT	cAssunto ; 
		 		Body mCorpo;		
		 		ATTACHMENT cAnexos;
		 		RESULT lEnviado

	DISCONNECT SMTP SERVER
Endif
If !lConectou .Or. !lEnviado
	cMensagem := ""
	GET MAIL ERROR cMensagem 
	Alert(cMensagem)
Endif          
FERASE(cAnexos)
Return                      
