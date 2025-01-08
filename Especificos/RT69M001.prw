#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "fileio.ch"

/*/{Protheus.doc} RT69M001
Rotina que exporta os Dadospara CSV.
@type class 
@author Ricardo Tavares Ferreira
@since 23/10/2021
@version 12.1.27
@history 23/10/2021, Ricardo Tavares Ferreira, Construção Inicial
/*/
//=============================================================================================================================
    User Function RT69M001()
//=============================================================================================================================

    Local lConfirm 		:= .F. 

	Private cAliasCNB 	:= GetNextAlias()
	Private QbLinha		:= chr(13)+chr(10)

    While .T.
		If GetPerg()
			lConfirm := .T.
			Exit
		Else
			If MsgNoYes("Foi detectado o cancelamento do preechimento dos parametros. Deseja realmente sair da Exportação do Arquivo (Sim / Não)?","Atenção !!!")
				Return Nil
			EndIf
		EndIf
	End
	If lConfirm 
		FWMsgRun(,{|oSay| GeraArq(oSay)},"Geração do Arquivo (Medições)","Gerando arquivo para medição ...") 
	EndIf 
Return Nil 

/*/{Protheus.doc} GetPerg
Função que Gera o Arquivo. 
@type function
@author Ricardo Tavares Ferreira
@since 23/10/2021
@version 12.1.2
@history 23/10/2021, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//====================================================================================================
	Static Function GeraArq(oSay)
//====================================================================================================

	Local cArquivo  := Lower("Contrato_"+Alltrim((CN9->CN9_NUMERO))+".csv")
	Local nHandle	:= 0
	Local cCaminho	:= Alltrim(MV_PAR01)
	Local aCliFor	:= {}
	Local cdirdocs  := "\medicao\"
	Local cCampos	:= ""

	If Alltrim(CN9_ESPCTR) == "1"
		cCampos	:= "CN9_NUMERO;CN9_REVATU;CN9_COMPET;CNE_NUMERO;CNE_ITEM;CNE_PRODUT;CNE_DESCRI;CNE_UM;CNE_QUANT;CNE_CC;CNE_ITEMCT;CNE_CLVL;CNE_VLUNIT;CND_FORNEC;CND_LJFORN"
	Else 
		cCampos	:= "CN9_NUMERO;CN9_REVATU;CN9_COMPET;CNE_NUMERO;CNE_ITEM;CNE_PRODUT;CNE_DESCRI;CNE_UM;CNE_QUANT;CNE_CC;CNE_ITEMCT;CNE_CLVL;CNE_VLUNIT;CND_CLIENT;CND_LOJACL"
	EndIf 

	cCaminho := Iif(Right(cCaminho,1) == "\",Substr(cCaminho,1,Len(cCaminho)-1),cCaminho)

	If .not. ExistDir(cdirdocs)
		MakeDir(cdirdocs)
	EndIf 

	If File(cdirdocs+cArquivo)
		FErase(cdirdocs+cArquivo)
	Endif

	If File(Alltrim(MV_PAR01)+cArquivo)
		FErase(Alltrim(MV_PAR01)+cArquivo)
	Endif

	If BuscaCNB()
		aCliFor := BuscaCNA()
		nhandle := FCreate(cdirdocs+cArquivo,0)
		If nhandle <> -1
			FWrite(nhandle,cCampos+QbLinha)
			While .not. (cAliasCNB)->(Eof())
				FWrite(nhandle,;
								Alltrim(CN9->CN9_NUMERO)+";"+;
								Alltrim(CN9->CN9_REVISA)+";"+;
								Dtos(DDataBase)+";"+;
								Alltrim((cAliasCNB)->CNB_NUMERO)+";"+;
								Alltrim((cAliasCNB)->CNB_ITEM)+";"+;
								Alltrim((cAliasCNB)->CNB_PRODUT)+";"+;
								Alltrim((cAliasCNB)->CNB_DESCRI)+";"+;
								Alltrim((cAliasCNB)->CNB_UM)+";"+;
								CValToChar((cAliasCNB)->CNB_QUANT)+";"+;
								Alltrim((cAliasCNB)->CNB_CC)+";"+;
								Alltrim((cAliasCNB)->CNB_ITEMCT)+";"+;
								Alltrim((cAliasCNB)->CNB_CLVL)+";"+;
								cValToChar((cAliasCNB)->CNB_VLUNIT)+";"+;
								Alltrim(aCliFor[1])+";"+;
								Alltrim(aCliFor[2])+QbLinha)
				(cAliasCNB)->(DbSkip())
			End
			(cAliasCNB)->(DbCloseArea()) 
			FClose(nhandle)
			If CpyS2t(cdirdocs+cArquivo,cCaminho,.T.)
				MsgInfo("O Arquivo "+cArquivo+" foi gerado com sucesso no diretorio "+cCaminho,"Atenção")
			Else 
				MsgStop("Falha ao copiar o arquivo para a pasta selecionada : "+Alltrim(MV_PAR01),"Atenção")
			EndIf 
		Else 
			MsgStop("Erro ao criar o Arquivo -> ERRO: "+Str(Ferror()),"Atenção")
		EndIf
	Else 
		MsgStop("Não foi encontrado produtos para este contrato","Atenção")
	EndIf 
Return Nil

/*/{Protheus.doc} BuscaCNA
Busca os dados da tabela CNA. 
@type function
@author Ricardo Tavares Ferreira
@since 23/10/2021
@version 12.1.27
@return array, Array com os dados do contrato.
@history 23/10/2021, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//====================================================================================================
	Static Function BuscaCNA()
//====================================================================================================

    Local cQuery    := ""
	Local nQtdReg   := 0
	Local cAliasCNA	:= GetNextAlias()
	Local cCliFor	:= ""
	Local cLjClFor	:= ""

	cQuery := " SELECT TOP 1 CNA_FORNEC, CNA_LJFORN, CNA_CLIENT, CNA_LOJACL  " +QbLinha
	cQuery += " FROM "
    cQuery +=   RetSqlName("CNA") + " CNA " +QbLinha
	cQuery += " WHERE CNA.D_E_L_E_T_ = ' ' " +QbLinha 
	cQuery += " AND (CNA_FORNEC <> ' ' OR CNA_CLIENT <> ' ') " +QbLinha
	cQuery += " AND CNA_FILIAL = '"+FWXFilial("CNA")+"' " +QbLinha
	cQuery += " AND CNA_CONTRA = '"+Alltrim(CN9->CN9_NUMERO)+"' " +QbLinha

	MemoWrite("C:/ricardo/BuscaCNA.sql",cQuery)
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCNA,.F.,.T.)
		
	DbSelectArea(cAliasCNA)
	(cAliasCNA)->(DbGoTop())
	Count To nQtdReg
	(cAliasCNA)->(DbGoTop())
		
	If nQtdReg <= 0
		(cAliasCNA)->(DbCloseArea())
		Return {cCliFor,cLjClFor}
	Else 
		While .not. (cAliasCNA)->(Eof())
			If Empty((cAliasCNA)->CNA_FORNEC)
				cCliFor := Alltrim((cAliasCNA)->CNA_CLIENT)
				cLjClFor := Alltrim((cAliasCNA)->CNA_LOJACL)
			Else 	
				cCliFor := Alltrim((cAliasCNA)->CNA_FORNEC)
				cLjClFor := Alltrim((cAliasCNA)->CNA_LJFORN)
			EndIf 
			(cAliasCNA)->(DbSkip())
		End
	EndIf
	(cAliasCNA)->(DbCloseArea())
Return {cCliFor,cLjClFor}

/*/{Protheus.doc} BuscaCNB
Busca os dados da tabela CNB. 
@type function
@author Ricardo Tavares Ferreira
@since 23/10/2021
@version 12.1.27
@return logical, Retorna logico se confirmou os paramtros.
@history 23/10/2021, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//====================================================================================================
	Static Function BuscaCNB()
//====================================================================================================

    Local cQuery    := ""
	Local nQtdReg   := 0

	cQuery := " SELECT CNB.* "+QbLinha

	cQuery += " FROM "
    cQuery +=   RetSqlName("CNB") + " CNB " +QbLinha

	cQuery += " WHERE CNB.D_E_L_E_T_ = ' ' "+QbLinha 
	cQuery += " AND CNB_CONTRA = '"+Alltrim(CN9->CN9_NUMERO)+"' "+QbLinha
	cQuery += " AND CNB_REVISA = '"+Alltrim(CN9->CN9_REVISA)+"' "+QbLinha
	cQuery += " AND CNB_FILIAL = '"+FWXFilial("CNB")+"' "+QbLinha

	MemoWrite("C:/ricardo/BuscaCNB.sql",cQuery)
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCNB,.F.,.T.)
		
	DbSelectArea(cAliasCNB)
	(cAliasCNB)->(DbGoTop())
	Count To nQtdReg
	(cAliasCNB)->(DbGoTop())
		
	If nQtdReg <= 0
		Return .F.
	EndIf
Return .T.

/*/{Protheus.doc} GetPerg
Criacao das Perguntas da Rotina tipo Parambox. 
@type function
@author Ricardo Tavares Ferreira
@since 23/10/2021
@version 12.1.27
@return logical, Retorna logico se confirmou os paramtros.
@history 23/10/2021, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//====================================================================================================
	Static Function GetPerg()
//====================================================================================================

    Local aPergs	    := {}
    Local aRet		    := {}
    Local lRet		    := .T.
    Private cCadastro   := "Perguntas"

    aadd(aPergs,{6,"Salvar Arq. em" , Padr("",300),"",".T.","",80,.T.,"","",GETF_LOCALHARD+GETF_RETDIRECTORY}) // MV_PAR01

	If .not. ParamBox(aPergs,"Geração de Arquivo (Medição)",aRet,/*bValid*/,/*aButtons*/,.T.,/*nPosX*/,/*nPosY*/,/*oDialog*/,"IQUIVIA",.T.,.T.)
		lRet := .F.
	EndIf 
Return lRet
