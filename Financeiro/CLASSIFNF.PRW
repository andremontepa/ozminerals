#include 'protheus.ch'
#include 'parmtype.ch'
#include "TbiConn.ch"

user function Classif1()

	Local aCab := {}
	Local aItem := {}
	Local aItens := {}
//	Local aItensRat := {}
//	Local aCodRet := {}
	Local nOpc := 4
//	Local cNum := ""
//	Local nI := 0
//	Local nX := 0
//	Local nReg := 1
//	Local _cReg := ""
	Local _nRec
	Local _cNaturez := ""

	Conout("Inicio: " + Time())

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.
	Private aDados      := {}
	Private _cDoc       := ""
	Private _cSerie     := ""
	Private _cFornece   := ""
	Private _cFilial    := ""

	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "02" MODULO "COM"

	_cQyery:= "select R_E_C_N_O_ AS RECNO, * from "+RetSqlName("SF1")+" where F1_STATUS = ' ' and F1_APROV <> ' ' and F1_TIPO = 'N' and F1_CLASFIS = ' ' and  D_E_L_E_T_ <> '*'"
	dbUseArea(.T.,'TOPCONN',TCGenQry(,,_cQyery),'SQ1',.T.)
	
	//_cfilbak:=xfilial("SF1")   //Guarda filial logada 
	_cfilbak:=cFilAnt   //Guarda filial logada 
	
	conout("Filial logada:"+_cfilbak)

	conout(_cQyery)

	dbselectarea("SQ1")
	SQ1->(dbGoTop())
	Do while !SQ1->(eof())
	
	    cfilant   :=SQ1->F1_FILIAL    //Seta filial do registro    
		_cDoc     := SQ1->F1_DOC
		_cSerie   := SQ1->F1_SERIE
		_cFornece := SQ1->F1_FORNECE
		_cFilial  := SQ1->F1_FILIAL
		_cLoja    := SQ1->F1_LOJA
		//_nRec     := SQ1->(RECNO())
		_nRec     := SQ1->RECNO
		aCab      := {}
		aItem     := {}
		aItens    := {}

		conout(_cDoc); conout(_cSerie);	conout(_cFornece)

		_cExe:= " SELECT * FROM "+RetSqlName("ZB1")+" WHERE ZB1_FILIAL = '"+_cFilial+"' AND ZB1_NOTA = '"+_cDoc+"' "
		_cExe+= " AND ZB1_SERIE = '"+_cSerie+"'  AND  ZB1_FORNEC ='"+_cFornece+"'  AND  D_E_L_E_T_ <> '*'  "
		dbUseArea(.T.,'TOPCONN',TCGenQry(,,_cExe),'TRN',.T.)
		dbselectarea("TRN")
		TRN->(dbGoTop())
		Do While !TRN->(eof())
			_cNaturez:= TRN->ZB1_NATURE
			TRN->(dbskip())
		EndDo
		TRN->(dbclosearea())

		conout("Natureza:"+_cNaturez)

		//Cabeçalho
		aadd(aCab,{"F1_TIPO" ,"N" ,NIL})
		aadd(aCab,{"F1_FILIAL" ,cfilant ,NIL})
		aadd(aCab,{"F1_FORMUL" ,"N" ,NIL})
		aadd(aCab,{"F1_DOC" ,SQ1->F1_DOC ,NIL})
		aadd(aCab,{"F1_SERIE" ,SQ1->F1_SERIE ,NIL})
		aadd(aCab,{"F1_EMISSAO" ,SQ1->F1_EMISSAO ,NIL})
		aadd(aCab,{"F1_DTDIGIT" ,SQ1->F1_DTDIGIT ,NIL})
		aadd(aCab,{"F1_FORNECE" ,SQ1->F1_FORNECE ,NIL})
		aadd(aCab,{"F1_LOJA" ,SQ1->F1_LOJA ,NIL})
		aadd(aCab,{"F1_ESPECIE" ,SQ1->F1_ESPECIE ,NIL})
		aadd(aCab,{"F1_COND" ,SQ1->F1_COND ,NIL})
		aadd(aCab,{"F1_DESPESA" ,SQ1->F1_DESPESA ,NIL})
		aadd(aCab,{"F1_DESCONT" ,SQ1->F1_DESCONT ,Nil})
		aadd(aCab,{"F1_SEGURO" , SQ1->F1_SEGURO ,Nil})
		aadd(aCab,{"F1_FRETE" , SQ1->F1_FRETE ,Nil})
		aadd(aCab,{"F1_MOEDA" , SQ1->F1_MOEDA ,Nil})
		aadd(aCab,{"F1_TXMOEDA" , SQ1->F1_TXMOEDA ,Nil})
		aadd(aCab,{"E2_NATUREZ" , _cNaturez ,Nil})
		aadd(aCab,{"F1_STATUS" , SQ1->F1_STATUS ,Nil})
		aadd(aCab,{"F1_BRICMS" , SQ1->F1_BRICMS ,Nil})
		aadd(aCab,{"F1_ICMSRET" , SQ1->F1_ICMSRET ,Nil})
		aadd(aCab,{"F1_BASIMP5" , SQ1->F1_BASIMP5 ,Nil})
		aadd(aCab,{"F1_BASIMP6" , SQ1->F1_BASIMP6 ,Nil})
		aadd(aCab,{"F1_VALIMP5" , SQ1->F1_VALIMP5 ,Nil})
		aadd(aCab,{"F1_VALIMP6" , SQ1->F1_VALIMP6 ,Nil})
		aadd(aCab,{"F1_VALPIS" , SQ1->F1_VALPIS ,Nil})
		aadd(aCab,{"F1_VALCOFI" , SQ1->F1_VALCOFI ,Nil})
		aadd(aCab,{"F1_VALCSLL" , SQ1->F1_VALCSLL ,Nil})
		aadd(aCab,{"F1_BASCSLL" , SQ1->F1_BASCSLL ,Nil})
		aadd(aCab,{"F1_BASPIS" , SQ1->F1_BASPIS ,Nil})
		aadd(aCab,{"F1_BASCOFI" , SQ1->F1_BASCOFI ,Nil})
		
		//cQuery:= "select * from "+RetSqlName("SD1")+" where D1_DOC = '"+SQ1->F1_DOC+"' and  D1_SERIE = '"+SQ1->F1_SERIE+"' and  D1_FORNECE = '"+SQ1->F1_FORNECE+"' and D1_LOJA = '"+SQ1->F1_LOJA+"' and  D_E_L_E_T_ <> '*' order by D1_ITEM "
		cQuery:= "select * from "+RetSqlName("SD1")+" where D1_FILIAL = '"+SQ1->F1_FILIAL+"' AND D1_DOC = '"+SQ1->F1_DOC+"' and  D1_SERIE = '"+SQ1->F1_SERIE+"' and  D1_FORNECE = '"+SQ1->F1_FORNECE+"' and D1_LOJA = '"+SQ1->F1_LOJA+"' and  D_E_L_E_T_ <> '*' order by D1_ITEM "
		dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQuery),'TRD',.T.)

		dbselectarea("TRD")
		TRD->(dbGoTop())
		Do While !TRD->(eof())
			conout("Filial " + cFilAnt)
			conout("item " + TRD->D1_ITEM)
			conout("produto " + TRD->D1_COD)

			aadd(aItem,{"D1_ITEM" ,TRD->D1_ITEM ,NIL})
			aadd(aItem,{"D1_FILIAL" ,cfilant ,NIL})
			aadd(aItem,{"D1_COD" ,TRD->D1_COD ,NIL})
			aadd(aItem,{"D1_UM" ,TRD->D1_UM ,NIL})
			aadd(aItem,{"D1_LOCAL" ,TRD->D1_LOCAL ,NIL})
			aadd(aItem,{"D1_QUANT" ,TRD->D1_QUANT ,NIL})
			aadd(aItem,{"D1_VUNIT" ,TRD->D1_VUNIT ,NIL})
			aadd(aItem,{"D1_TOTAL" ,TRD->D1_TOTAL ,NIL})
			aadd(aItem,{"D1_ITEMCTA" ,TRD->D1_ITEMCTA ,NIL})
			aadd(aItem,{"D1_CC" ,TRD->D1_CC ,NIL})
			aadd(aItem,{"D1_CONTA" ,TRD->D1_CONTA ,NIL})
			aadd(aItem,{"D1_CLVL" ,TRD->D1_CLVL ,NIL})
			aadd(aItem,{"D1_RATEIO" ,TRD->D1_RATEIO ,NIL})
			aAdd(aItens,aItem)
			TRD->(dbskip())
		EndDo
		TRD->(dbclosearea())

		//3-Inclusão / 4-Classificação / 5-Exclusão
		MSExecAuto({|x,y,z,a,b| MATA103(x,y,z,,,,,a,,,b)},aCab,aItens,nOpc,,)

		If !lMsErroAuto
			ConOut(" Incluido NF: " + _cDoc)

			//Atualiza SF1 informando que apovação ja foi processada
			//nStatus := TCSqlExec("update "+RetSqlName("SF1")+" set F1_CLASFIS = 'S' where F1_DOC = '"+_cDoc+"' and  F1_SERIE = '"+_cSerie+"' and  F1_FORNECE = '"+_cFornece+"' and F1_LOJA = '"+_cLoja+"' and D_E_L_E_T_ <> '*'  ")
			nStatus := TCSqlExec("update "+RetSqlName("SF1")+" set F1_CLASFIS = 'S' where R_E_C_N_O_ = "+cValToChar(_nRec))

			if (nStatus < 0)
				conout("TCSQLError() " + TCSQLError())
			endif
		Else
			cErrLog :=  MostraErro("\logs\")
			ConOut("Erro na inclusao da  NF - "+_cDoc)
			ConOut(cErrLog)
		EndIf
        
        cfilant:=_cfilbak   //Apos contabilizar retorna filial logado 
        //SQ1->(DbGoTop(_nRec))
		SQ1->(dbskip())
	Enddo

	SQ1->(dbclosearea())

	ConOut("Fim: " + Time())

	RESET ENVIRONMENT

return

user function Classif2()

	Local aCab := {}
	Local aItem := {}
	Local aItens := {}
//	Local aItensRat := {}
//	Local aCodRet := {}
	Local nOpc := 4
//	Local cNum := ""
//	Local nI := 0
//	Local nX := 0
//	Local nReg := 1
//	Local _cReg:= ""
	Local _nRec
	Local _cNaturez:= ""

	Conout("Inicio: " + Time())

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.
	Private aDados      := {}
	Private _cDoc       := ""
	Private _cSerie     := ""
	Private _cFornece   := ""
	Private _cFilial    := ""

	PREPARE ENVIRONMENT EMPRESA "03" FILIAL "02" MODULO "COM"

	_cQyery:= "select R_E_C_N_O_ AS RECNO, * from "+RetSqlName("SF1")+" where F1_STATUS = ' ' and F1_APROV <> ' ' and F1_TIPO = 'N' and F1_CLASFIS = ' ' and  D_E_L_E_T_ <> '*'"
	dbUseArea(.T.,'TOPCONN',TCGenQry(,,_cQyery),'SQ1',.T.)
	
	//_cfilbak:=xfilial("SF1")   //Guarda filial logada 
	_cfilbak:=cFilAnt   //Guarda filial logada 
	
	conout("Filial logada:"+_cfilbak)

	conout(_cQyery)

	dbselectarea("SQ1")
	SQ1->(dbGoTop())
	Do while !SQ1->(eof())
	
	    cfilant   :=SQ1->F1_FILIAL    //Seta filial do registro    
		_cDoc     := SQ1->F1_DOC
		_cSerie   := SQ1->F1_SERIE
		_cFornece := SQ1->F1_FORNECE
		_cFilial  := SQ1->F1_FILIAL
		_cLoja    := SQ1->F1_LOJA
		//_nRec     := SQ1->(RECNO())
		_nRec     := SQ1->RECNO
		aCab      := {}
		aItem     := {}
		aItens    := {}

		conout(_cDoc); conout(_cSerie);	conout(_cFornece)

		_cExe:= " SELECT * FROM "+RetSqlName("ZB1")+" WHERE ZB1_FILIAL = '"+_cFilial+"' AND ZB1_NOTA = '"+_cDoc+"' "
		_cExe+= " AND ZB1_SERIE = '"+_cSerie+"'  AND  ZB1_FORNEC ='"+_cFornece+"'  AND  D_E_L_E_T_ <> '*'  "
		dbUseArea(.T.,'TOPCONN',TCGenQry(,,_cExe),'TRN',.T.)
		dbselectarea("TRN")
		TRN->(dbGoTop())
		Do While !TRN->(eof())
			_cNaturez:= TRN->ZB1_NATURE
			TRN->(dbskip())
		EndDo
		TRN->(dbclosearea())

		conout("Natureza:"+_cNaturez)

		//Cabeçalho
		aadd(aCab,{"F1_TIPO" ,"N" ,NIL})
		aadd(aCab,{"F1_FILIAL" ,cfilant ,NIL})
		aadd(aCab,{"F1_FORMUL" ,"N" ,NIL})
		aadd(aCab,{"F1_DOC" ,SQ1->F1_DOC ,NIL})
		aadd(aCab,{"F1_SERIE" ,SQ1->F1_SERIE ,NIL})
		aadd(aCab,{"F1_EMISSAO" ,SQ1->F1_EMISSAO ,NIL})
		aadd(aCab,{"F1_DTDIGIT" ,SQ1->F1_DTDIGIT ,NIL})
		aadd(aCab,{"F1_FORNECE" ,SQ1->F1_FORNECE ,NIL})
		aadd(aCab,{"F1_LOJA" ,SQ1->F1_LOJA ,NIL})
		aadd(aCab,{"F1_ESPECIE" ,SQ1->F1_ESPECIE ,NIL})
		aadd(aCab,{"F1_COND" ,SQ1->F1_COND ,NIL})
		aadd(aCab,{"F1_DESPESA" ,SQ1->F1_DESPESA ,NIL})
		aadd(aCab,{"F1_DESCONT" ,SQ1->F1_DESCONT ,Nil})
		aadd(aCab,{"F1_SEGURO" , SQ1->F1_SEGURO ,Nil})
		aadd(aCab,{"F1_FRETE" , SQ1->F1_FRETE ,Nil})
		aadd(aCab,{"F1_MOEDA" , SQ1->F1_MOEDA ,Nil})
		aadd(aCab,{"F1_TXMOEDA" , SQ1->F1_TXMOEDA ,Nil})
		aadd(aCab,{"E2_NATUREZ" , _cNaturez ,Nil})
		aadd(aCab,{"F1_STATUS" , SQ1->F1_STATUS ,Nil})
		aadd(aCab,{"F1_BRICMS" , SQ1->F1_BRICMS ,Nil})
		aadd(aCab,{"F1_ICMSRET" , SQ1->F1_ICMSRET ,Nil})
		aadd(aCab,{"F1_BASIMP5" , SQ1->F1_BASIMP5 ,Nil})
		aadd(aCab,{"F1_BASIMP6" , SQ1->F1_BASIMP6 ,Nil})
		aadd(aCab,{"F1_VALIMP5" , SQ1->F1_VALIMP5 ,Nil})
		aadd(aCab,{"F1_VALIMP6" , SQ1->F1_VALIMP6 ,Nil})
		aadd(aCab,{"F1_VALPIS" , SQ1->F1_VALPIS ,Nil})
		aadd(aCab,{"F1_VALCOFI" , SQ1->F1_VALCOFI ,Nil})
		aadd(aCab,{"F1_VALCSLL" , SQ1->F1_VALCSLL ,Nil})
		aadd(aCab,{"F1_BASCSLL" , SQ1->F1_BASCSLL ,Nil})
		aadd(aCab,{"F1_BASPIS" , SQ1->F1_BASPIS ,Nil})
		aadd(aCab,{"F1_BASCOFI" , SQ1->F1_BASCOFI ,Nil})

		//cQuery:= "select * from "+RetSqlName("SD1")+" where D1_DOC = '"+SQ1->F1_DOC+"' and  D1_SERIE = '"+SQ1->F1_SERIE+"' and  D1_FORNECE = '"+SQ1->F1_FORNECE+"' and D1_LOJA = '"+SQ1->F1_LOJA+"' and  D_E_L_E_T_ <> '*' order by D1_ITEM "
		cQuery:= "select * from "+RetSqlName("SD1")+" where D1_FILIAL = '"+SQ1->F1_FILIAL+"' AND D1_DOC = '"+SQ1->F1_DOC+"' and  D1_SERIE = '"+SQ1->F1_SERIE+"' and  D1_FORNECE = '"+SQ1->F1_FORNECE+"' and D1_LOJA = '"+SQ1->F1_LOJA+"' and  D_E_L_E_T_ <> '*' order by D1_ITEM "
		dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQuery),'TRD',.T.)

		dbselectarea("TRD")
		TRD->(dbGoTop())
		Do While !TRD->(eof())

			aadd(aItem,{"D1_ITEM" ,TRD->D1_ITEM ,NIL})
			aadd(aItem,{"D1_FILIAL" ,cfilant ,NIL})
			aadd(aItem,{"D1_COD" ,TRD->D1_COD ,NIL})
			aadd(aItem,{"D1_UM" ,TRD->D1_UM ,NIL})
			aadd(aItem,{"D1_LOCAL" ,TRD->D1_LOCAL ,NIL})
			aadd(aItem,{"D1_QUANT" ,TRD->D1_QUANT ,NIL})
			aadd(aItem,{"D1_VUNIT" ,TRD->D1_VUNIT ,NIL})
			aadd(aItem,{"D1_TOTAL" ,TRD->D1_TOTAL ,NIL})
			aadd(aItem,{"D1_ITEMCTA" ,TRD->D1_ITEMCTA ,NIL})
			aadd(aItem,{"D1_CC" ,TRD->D1_CC ,NIL})
			aadd(aItem,{"D1_CONTA" ,TRD->D1_CONTA ,NIL})
			aadd(aItem,{"D1_CLVL" ,TRD->D1_CLVL ,NIL})
			aadd(aItem,{"D1_RATEIO" ,TRD->D1_RATEIO ,NIL})
			aAdd(aItens,aItem)
			TRD->(dbskip())
		enddo
		TRD->(dbclosearea())

		//3-Inclusão / 4-Classificação / 5-Exclusão
		MSExecAuto({|x,y,z,a,b| MATA103(x,y,z,,,,,a,,,b)},aCab,aItens,nOpc,,)

		If !lMsErroAuto
			ConOut(" Incluido NF: " + _cDoc)

			//Atualiza SF1 informando que apovação ja foi processada
			//nStatus := TCSqlExec("update "+RetSqlName("SF1")+" set F1_CLASFIS = 'S' where F1_DOC = '"+_cDoc+"' and  F1_SERIE = '"+_cSerie+"' and  F1_FORNECE = '"+_cFornece+"' and F1_LOJA = '"+_cLoja+"' and D_E_L_E_T_ <> '*'  ")
			nStatus := TCSqlExec("update "+RetSqlName("SF1")+" set F1_CLASFIS = 'S' where R_E_C_N_O_ = "+cValToChar(_nRec))

			if (nStatus < 0)
				conout("TCSQLError() " + TCSQLError())
			endif
		Else
			MostraErro()
			ConOut("Erro na inclusao da  NF - "+_cDoc)
		EndIf
        
        cfilant:=_cfilbak   //Apos contabilizar retorna filial logado 
        //SQ1->(DbGoTop(_nRec))
		SQ1->(dbskip())
	Enddo

	SQ1->(dbclosearea())

	ConOut("Fim: " + Time())

	RESET ENVIRONMENT

return

user function Classif3()

	Local aCab := {}
	Local aItem := {}
	Local aItens := {}
//	Local aItensRat := {}
//	Local aCodRet := {}
	Local nOpc := 4
//	Local cNum := ""
//	Local nI := 0
//	Local nX := 0
//	Local nReg := 1
//	Local _cReg:= ""
	Local _nRec := 0
	Local _cNaturez:= ""

	Conout("Inicio: " + Time())

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.
	Private aDados      := {}
	Private _cDoc       := ""
	Private _cSerie     := ""
	Private _cFornece   := ""
	Private _cFilial    := ""

	PREPARE ENVIRONMENT EMPRESA "04" FILIAL "01" MODULO "COM"

	_cQyery:= "select R_E_C_N_O_ AS RECNO, * from "+RetSqlName("SF1")+" where F1_STATUS = ' ' and F1_APROV <> ' ' and F1_TIPO = 'N' and F1_CLASFIS = ' ' and  D_E_L_E_T_ <> '*'"
	dbUseArea(.T.,'TOPCONN',TCGenQry(,,_cQyery),'SQ1',.T.)
	
	//_cfilbak:=xfilial("SF1")   //Guarda filial logada 
	_cfilbak:=cFilAnt   //Guarda filial logada 
	
	conout("Filial logada:"+_cfilbak)

	conout(_cQyery)

	dbselectarea("SQ1")
	SQ1->(dbGoTop())
	Do while !SQ1->(eof())
	
	    cfilant   :=SQ1->F1_FILIAL    //Seta filial do registro    
		_cDoc     := SQ1->F1_DOC
		_cSerie   := SQ1->F1_SERIE
		_cFornece := SQ1->F1_FORNECE
		_cFilial  := SQ1->F1_FILIAL
		_cLoja    := SQ1->F1_LOJA
		//_nRec     := SQ1->(RECNO())
		_nRec     := SQ1->RECNO
		aCab      := {}
		aItem     := {}
		aItens    := {}

		conout(_cDoc); conout(_cSerie);	conout(_cFornece)

		_cExe:= " SELECT * FROM "+RetSqlName("ZB1")+" WHERE ZB1_FILIAL = '"+_cFilial+"' AND ZB1_NOTA = '"+_cDoc+"' "
		_cExe+= " AND ZB1_SERIE = '"+_cSerie+"'  AND  ZB1_FORNEC ='"+_cFornece+"'  AND  D_E_L_E_T_ <> '*'  "
		dbUseArea(.T.,'TOPCONN',TCGenQry(,,_cExe),'TRN',.T.)
		dbselectarea("TRN")
		TRN->(dbGoTop())
		Do While !TRN->(eof())
			_cNaturez:= TRN->ZB1_NATURE
			TRN->(dbskip())
		enddo
		TRN->(dbclosearea())

		conout("Natureza:"+_cNaturez)

		//Cabeçalho
		aadd(aCab,{"F1_TIPO" ,"N" ,NIL})
		aadd(aCab,{"F1_FILIAL" ,cfilant ,NIL})
		aadd(aCab,{"F1_FORMUL" ,"N" ,NIL})
		aadd(aCab,{"F1_DOC" ,SQ1->F1_DOC ,NIL})
		aadd(aCab,{"F1_SERIE" ,SQ1->F1_SERIE ,NIL})
		aadd(aCab,{"F1_EMISSAO" ,SQ1->F1_EMISSAO ,NIL})
		aadd(aCab,{"F1_DTDIGIT" ,SQ1->F1_DTDIGIT ,NIL})
		aadd(aCab,{"F1_FORNECE" ,SQ1->F1_FORNECE ,NIL})
		aadd(aCab,{"F1_LOJA" ,SQ1->F1_LOJA ,NIL})
		aadd(aCab,{"F1_ESPECIE" ,SQ1->F1_ESPECIE ,NIL})
		aadd(aCab,{"F1_COND" ,SQ1->F1_COND ,NIL})
		aadd(aCab,{"F1_DESPESA" ,SQ1->F1_DESPESA ,NIL})
		aadd(aCab,{"F1_DESCONT" ,SQ1->F1_DESCONT ,Nil})
		aadd(aCab,{"F1_SEGURO" , SQ1->F1_SEGURO ,Nil})
		aadd(aCab,{"F1_FRETE" , SQ1->F1_FRETE ,Nil})
		aadd(aCab,{"F1_MOEDA" , SQ1->F1_MOEDA ,Nil})
		aadd(aCab,{"F1_TXMOEDA" , SQ1->F1_TXMOEDA ,Nil})
		aadd(aCab,{"E2_NATUREZ" , _cNaturez ,Nil})
		aadd(aCab,{"F1_STATUS" , SQ1->F1_STATUS ,Nil})
		aadd(aCab,{"F1_BRICMS" , SQ1->F1_BRICMS ,Nil})
		aadd(aCab,{"F1_ICMSRET" , SQ1->F1_ICMSRET ,Nil})
		aadd(aCab,{"F1_BASIMP5" , SQ1->F1_BASIMP5 ,Nil})
		aadd(aCab,{"F1_BASIMP6" , SQ1->F1_BASIMP6 ,Nil})
		aadd(aCab,{"F1_VALIMP5" , SQ1->F1_VALIMP5 ,Nil})
		aadd(aCab,{"F1_VALIMP6" , SQ1->F1_VALIMP6 ,Nil})
		aadd(aCab,{"F1_VALPIS" , SQ1->F1_VALPIS ,Nil})
		aadd(aCab,{"F1_VALCOFI" , SQ1->F1_VALCOFI ,Nil})
		aadd(aCab,{"F1_VALCSLL" , SQ1->F1_VALCSLL ,Nil})
		aadd(aCab,{"F1_BASCSLL" , SQ1->F1_BASCSLL ,Nil})
		aadd(aCab,{"F1_BASPIS" , SQ1->F1_BASPIS ,Nil})
		aadd(aCab,{"F1_BASCOFI" , SQ1->F1_BASCOFI ,Nil})

		//cQuery:= "select * from "+RetSqlName("SD1")+" where D1_DOC = '"+SQ1->F1_DOC+"' and  D1_SERIE = '"+SQ1->F1_SERIE+"' and  D1_FORNECE = '"+SQ1->F1_FORNECE+"' and D1_LOJA = '"+SQ1->F1_LOJA+"' and  D_E_L_E_T_ <> '*' order by D1_ITEM "
		cQuery:= "select * from "+RetSqlName("SD1")+" where D1_FILIAL = '"+SQ1->F1_FILIAL+"' AND D1_DOC = '"+SQ1->F1_DOC+"' and  D1_SERIE = '"+SQ1->F1_SERIE+"' and  D1_FORNECE = '"+SQ1->F1_FORNECE+"' and D1_LOJA = '"+SQ1->F1_LOJA+"' and  D_E_L_E_T_ <> '*' order by D1_ITEM "
		dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQuery),'TRD',.T.)

		dbselectarea("TRD")
		TRD->(dbGoTop())
		Do While !TRD->(eof())

			aadd(aItem,{"D1_ITEM" ,TRD->D1_ITEM ,NIL})
			aadd(aItem,{"D1_FILIAL" ,cfilant ,NIL})
			aadd(aItem,{"D1_COD" ,TRD->D1_COD ,NIL})
			aadd(aItem,{"D1_UM" ,TRD->D1_UM ,NIL})
			aadd(aItem,{"D1_LOCAL" ,TRD->D1_LOCAL ,NIL})
			aadd(aItem,{"D1_QUANT" ,TRD->D1_QUANT ,NIL})
			aadd(aItem,{"D1_VUNIT" ,TRD->D1_VUNIT ,NIL})
			aadd(aItem,{"D1_TOTAL" ,TRD->D1_TOTAL ,NIL})
			aadd(aItem,{"D1_ITEMCTA" ,TRD->D1_ITEMCTA ,NIL})
			aadd(aItem,{"D1_CC" ,TRD->D1_CC ,NIL})
			aadd(aItem,{"D1_CONTA" ,TRD->D1_CONTA ,NIL})
			aadd(aItem,{"D1_CLVL" ,TRD->D1_CLVL ,NIL})
			aadd(aItem,{"D1_RATEIO" ,TRD->D1_RATEIO ,NIL})
			aAdd(aItens,aItem)
			TRD->(dbskip())
		enddo
		TRD->(dbclosearea())

		//3-Inclusão / 4-Classificação / 5-Exclusão
		MSExecAuto({|x,y,z,a,b| MATA103(x,y,z,,,,,a,,,b)},aCab,aItens,nOpc,,)

		If !lMsErroAuto
			ConOut(" Incluido NF: " + _cDoc)

			//Atualiza SF1 informando que apovação ja foi processada
			//nStatus := TCSqlExec("update "+RetSqlName("SF1")+" set F1_CLASFIS = 'S' where F1_DOC = '"+_cDoc+"' and  F1_SERIE = '"+_cSerie+"' and  F1_FORNECE = '"+_cFornece+"' and F1_LOJA = '"+_cLoja+"' and D_E_L_E_T_ <> '*'  ")
			nStatus := TCSqlExec("update "+RetSqlName("SF1")+" set F1_CLASFIS = 'S' where R_E_C_N_O_ = "+cValToChar(_nRec))

			if (nStatus < 0)
				conout("TCSQLError() " + TCSQLError())
			endif
		Else
			MostraErro()
			ConOut("Erro na inclusao da  NF - "+_cDoc)
		EndIf
        
        cfilant:=_cfilbak   //Apos contabilizar retorna filial logado 
        //SQ1->(DbGoTop(_nRec))
		SQ1->(dbskip())
	Enddo

	SQ1->(dbclosearea())

	ConOut("Fim: " + Time())

	RESET ENVIRONMENT

return
