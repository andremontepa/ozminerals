#Include "Protheus.ch"
#Include "FWMVCDef.ch"

/*---------------------------------------------------------------------------------------------------------------------------*
 | P.E.:  CNTA300                                                                                                            |
 | Autor: Ismael Junior                                                                                                      |
 | Data:  06/04/2019                                                                                                         |
 | Desc:  Ponto de entrada MVC na rotina manutenção contratos                                                                |
 *---------------------------------------------------------------------------------------------------------------------------*/

User Function CNTA300()
	Local aParam     := PARAMIXB
	Local xRet       := .T.
	Local oObj       := Nil
	Local cIdPonto   := ''
	Local cIdModel   := ''
	Local nOper      := 0
	Local nValor	 := 0
	Local cTipo      := ""
	Local cCodCtr	 := ""
	//Local dDtEmis  := CN9->CN9_DTASSI
	//Local dLimite  := GetNewPar("MV_DTNEWGR",CTOD("13/04/2021"))    // Novos grupos a partir desta data 
	//Local cTipo    := If(dDtEmis<dLimite,"A","B")	
	//-
	//- Toni Aguiar - TOTVS STARSOFT em 10/04/2021
	//- Nova condição: A partir de 13/04/2021, as seguintes regras foram 
	//- aplicadas para seleção de grupos de aprovação automática:
	//- . Antes de 13/04/2021 a regra era classificar o grupo relacionado com CC x It.Cont x Clas.Vl.
	//- . A partir de 13/04/2021, se a Classe de Valor for OPX o grupo será um, e se for CPX será outro.
	//- . Conforme variável cGrupo
	//-
	Private cGrupo  := ""
		
	//Se tiver parâmetros
	If aParam <> NIL
		ConOut("> "+aParam[2])
		//Pega informações dos parâmetros
		oObj     := aParam[1]
		cIdPonto := aParam[2]
		cIdModel := aParam[3]

		//Valida a abertura da tela
		If cIdPonto == "MODELVLDACTIVE"
			nOper := oObj:nOperation
			
			//Se for inclusão, define o ini padrão
			If nOper == 3
				If FunName() == "MATA161"
					//Preenchimento automatico do campo CN9_CONDPG				   
					CN9MASTER := oObj:GetModel( 'CN9MASTER' ):GetStruct()
					CN9MASTER:SetProperty( 'CN9_CONDPG', MODEL_FIELD_INIT, FwBuildFeature( STRUCT_FEATURE_INIPAD, 'SC8->C8_COND' ) ) 
						//Passo para preenchimento do campo CN9_APROV
						cQry1 := " SELECT C1_CC,C1_ITEMCTA,C1_CLVL FROM " + RetSqlName("SC1")+ " SC1 WHERE C1_COTACAO = '"+SC8->C8_NUM+"' AND C1_FILIAL = '"+xFilial("SC1")+"' AND SC1.D_E_L_E_T_ != '*'  "
						If SELECT("TRASC1") > 0
							TRASC1->(DbCloseArea())
						Endif
						dbUseArea(.T.,"TOPCONN", TcGenQry(,,cQry1),"TRASC1",.T.,.T.)
						DbSelectArea("TRASC1")
						TRASC1->(dbGoTop())

						//If Alltrim(TRASC1->C1_CLVL)="OPX" 
						cGrupo:=GetNewPar("MV_GRUPOPX","AVB990")
						//Else
						//cGrupo:=GetNewPar("MV_GRUPCPX","AVB991")
						//Endif
						
						CN9MASTER:SetProperty( 'CN9_XAPROV', MODEL_FIELD_INIT, FwBuildFeature( STRUCT_FEATURE_INIPAD, If(cGrupo="AVB990", 'GetNewPar("MV_GRUPOPX","AVB990")', 'GetNewPar("MV_GRUPCPX","AVB991")') ) ) 
					
				Endif 

			//Se for Exclusão, não permite abrir a tela
			ElseIf nOper == 5

			EndIf
		
		//Pré configurações do Modelo de Dados
		ElseIf cIdPonto == "MODELPRE"
		
		//Pré configurações do Formulário de Dados
		ElseIf cIdPonto == "FORMPRE"
		
		//Adição de opções no Ações Relacionadas dentro da tela
		ElseIf cIdPonto == 'BUTTONBAR'
			xRet := {}
			aAdd(xRet, {"#Cotação", "", {|| u_MAT161AUX(CN9_NUMCOT,CN9_FILIAL)}, "Tooltip 1"})   
			aAdd(xRet, {"#Aprovadores", "", {|| U_MAAPROV(CN9_NUMERO,2,"CT")}, "Tooltip 1"}) 
			aAdd(xRet, {"#Carregar Itens Revisão", "", {|| U_OZ69A001()}, "Tooltip 1"})
		
		//Pós configurações do Formulário
		ElseIf cIdPonto == 'FORMPOS'
			//xRet := .T.
		
		//Validação ao clicar no Botão Confirmar
		ElseIf cIdPonto == 'MODELPOS'

		
		//Pré validações do Commit
		ElseIf cIdPonto == 'FORMCOMMITTTSPRE'
			If Empty(CN9->CN9_REVISA)
				cChvSCR := CN9->CN9_FILIAL + "CT" + CN9->CN9_NUMERO
			Else
				cChvSCR := CN9->CN9_FILIAL + "RV" + CN9->CN9_NUMERO + CN9->CN9_REVISA
			EndIf
			
			aGetAre := GetArea()
			aSCRAre := SCR->(GetArea())

			dbSelectArea("SCR")
			SCR->(dbSetOrder(01))
			If SCR->(dbSeek(Alltrim(cChvSCR)))
				Do While !SCR->(Eof()) .And. ;
					Alltrim(SCR->CR_FILIAL + SCR->CR_TIPO + SCR->CR_NUM) == Alltrim(cChvSCR)
					dbSelectArea("SCR")
					If SCR->(Reclock("SCR",.F.))
						SCR->CR_XDTINIC := CN9->CN9_DTINIC
						SCR->CR_XREVISA := CN9->CN9_REVISA
						SCR->CR_XDTFIM  := CN9->CN9_DTFIM
						SCR->CR_XDTREV  := CN9->CN9_DTREV
						SCR->CR_XSALDO  := CN9->CN9_SALDO
						SCR->CR_XVLINI  := CN9->CN9_VLINI
						SCR->CR_XVLATU  := CN9->CN9_VLATU
						SCR->CR_XVLADIT := CN9->CN9_VLADIT
						SCR->CR_XCODOBJ := Msmm(CN9->CN9_CODOBJ)
						SCR->CR_XCODCLA := Msmm(CN9->CN9_CODCLA)
						SCR->CR_XCODJUS	:= Msmm(CN9->CN9_CODJUS)	
						SCR->CR_XGLOBA	:= CN9->CN9_XGLOBA	
						SCR->(MsUnlock())
					EndIf
					SCR->(dbSkip())
				EndDo
			EndIf

			RestArea(aSCRAre)
			RestArea(aGetAre) 

		//Pós validações do Commit
		ElseIf cIdPonto == 'FORMCOMMITTTSPOS'
			
		//Commit das operações (antes da gravação)
		ElseIf cIdPonto == 'MODELCOMMITTTS'
			If !(Alltrim(cIdPonto) $ ("FORMPRE|MODELPRE"))
			//	Alert(cIdPonto)
			EndIf	
						
		//Commit das operações (após a gravação)
		ElseIf cIdPonto == 'MODELCOMMITNTTS'
			//If Empty(CN9->CN9_APROV) .or. Empty(CN9->CN9_XAPROV)
			If .not. Empty(CN9->CN9_TIPREV)
				//nValor := CN9->CN9_VLADIT
				cTipo  := "RV"
				cCodCtr := CN9->CN9_NUMERO+CN9->CN9_REVISA
				//If nValor == 0
				nValor := CN9->CN9_VLATU
				//EndIf
			Else
				nValor := CN9->CN9_VLATU
				cTipo  := "CT"
				cCodCtr := Alltrim(CN9->CN9_NUMERO)
			EndIf

			If nValor == 0
				nValor := 1
			EndIf
			
			If .not. FWIsInCallStack("MATA094")
				//AVBUtil():DeletaGrupoAprovacao(FWXFilial("CN9"),cCodCtr,cTipo)
				AVBUtil():DeletaGrupoAprovacao(CN9->CN9_FILIAL,cCodCtr,cTipo)
				AVBUtil():TrocaGrupoAprovacao("CN9",CN9->CN9_NUMERO,Alltrim(CNB->CNB_CLVL),,nValor,,CN9->CN9_REVISA)
			EndIf 
/*
			//Passo para preenchimento do campo CN9_APROV
			If !Empty(CN9->CN9_REVISA)
				
				cQry1 := " SELECT CNB_CC,CNB_ITEMCT,CNB_CLVL FROM " + RetSqlName("CNB")+ " CNB WHERE CNB_CONTRA = '"+ CN9->CN9_NUMERO +"' AND CNB_FILIAL = '" + CN9->CN9_FILIAL + "' AND CNB_REVISA = '" + CN9->CN9_REVISA + "' AND CNB.D_E_L_E_T_ != '*' "
				If SELECT("TRACNB") > 0
					TRACNB->(DbCloseArea())
				Endif
				dbUseArea(.T.,"TOPCONN", TcGenQry(,,cQry1),"TRACNB",.T.,.T.)
				DbSelectArea("TRACNB")
				TRACNB->(dbGoTop())
				cQuery := "	SELECT DBL_GRUPO FROM " + RetSqlName("DBL")+ " DBL "
				cQuery += " WHERE DBL_CC = '"+TRACNB->CNB_CC+"' "
				cQuery += " AND DBL_ITEMCT = '"+TRACNB->CNB_ITEMCT+"' "
				cQuery += " AND DBL_CLVL = '"+TRACNB->CNB_CLVL+"' "
				cQuery += " AND DBL_XTIPO = '"+cTipo+"'"
				cQuery += " AND DBL.D_E_L_E_T_ <> '*' "
				If SELECT("TRADBL") > 0
					TRADBL->(DbCloseArea())
				Endif	
				dbUseArea(.T.,"TOPCONN", TcGenQry(,,cQuery),"TRADBL",.T.,.T.)
				DbSelectArea("TRADBL")
				TRADBL->(dbGoTop())
				Do While TRADBL->(!Eof())
					cQry := " SELECT AL_COD FROM " + RetSqlName("SAL")+ " SAL " 
					cQry += " WHERE AL_COD = '"+TRADBL->DBL_GRUPO+"' "
					cQry += " AND AL_DOCCT = 'T' "
					cQry += " AND SAL.D_E_L_E_T_ <> '*' "                      
					If SELECT("TRBSAL") > 0
						TRBSAL->(DbCloseArea())
					Endif		
					dbUseArea(.T.,"TOPCONN", TcGenQry(,,cQry),"TRBSAL",.T.,.T.)													
					iF Empty(TRBSAL->AL_COD)
						If Alltrim(TRACNB->CNB_CLVL)="OPX" 
						cGrupo:=GetNewPar("MV_GRUPOPX","AVB990")
						Else
						cGrupo:=GetNewPar("MV_GRUPCPX","AVB991")
						Endif
					Else
						cGrupo:=TRBSAL->AL_COD	
					Endif
					Reclock("CN9",.F.)
						CN9->CN9_APROV := cGrupo
					CN9->(MsUnLock())
					TRADBL->(dbSkip())
				EndDo
				cGrupo:=GetNewPar("MV_GRUPOPX","AVB990")	
				Reclock("CN9",.F.)
					CN9->CN9_APROV := cGrupo
				CN9->(MsUnLock())*/
			//Endif		
			nOper := oObj:nOperation
			If !(Alltrim(cIdPonto) $ ("FORMPRE|MODELPRE"))
			//	Alert(cIdPonto)
			EndIf	
			//Se for inclusão, mostra mensagem de sucesso
		//	If nOper == 3
			//	Aviso('Atenção', 'criado com sucesso!', {'OK'}, 03)
		//	EndIf

		EndIf
	EndIf
Return xRet
