#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "PRTOPDEF.CH"

/*/{Protheus.doc} OZ34M002
Rotina de Ajuste de contabilização da moeda 02
@type function           
@author Ricardo Tavares Ferreira
@since 06/11/2022
@version 12.1.33
@history 06/11/2022, Ricardo Tavares Ferreira, Construção Inicial
/*/
//=============================================================================================================================
    User Function OZ34M002(xEmp,xFil)
//=============================================================================================================================

    Local lConfirm      := .F. 

    Private oSay        := Nil 
    Private QbLinha	    := chr(13)+chr(10)
    Private cDtExec     := ""
    Private lExecJOB    := IsBlind()
    Private cAliasALL   := GetNextAlias()
    Private aFina430    := {}
    Private cUsrAtu     := ""
    Private nStart      := 0

    Default xEmp        := "99"
    Default xFil        := "01"

    If lExecJOB
        RpcClearEnv()
        RpcSetType(3)
        RpcSetEnv(xEmp,xFil,,,,GetEnvServer(),{"CT2"})
        cUsrAtu := RetCodUsr()
        ProcReg(oSay)
        CTBA193()
    Else 
        While .T.
            If GetPerg()
                lConfirm := .T.
                Exit
            Else
                If MsgNoYes("Foi detectado o cancelamento do preechimento dos parametros. Deseja realmente sair da Importação dos Dados (Sim / Não)?","Atenção !!!")
                    Return Nil
                EndIf
            EndIf
        End

        cUsrAtu := RetCodUsr()
        //If .not. CtbStatus("01",Stod(MV_PAR01+"01"),Stod(MV_PAR01+"30"),.T.)// .or. .not. CtbStatus("02",Stod(MV_PAR01+"01"),Stod(MV_PAR01+"30"),.T.)
        If .not. CtbStatus("01",FirstDate(Stod(MV_PAR01+"01")),LastDate(Stod(MV_PAR01+"01")),.T.)
            lConfirm := .F.
        EndIf  
        If lConfirm 
            DeletaCTA(MV_PAR01)
            FWMsgRun(,{|oSay| ProcReg(oSay)},"Processamento de Lançamentos","Processando Registros da Moeda 02...") 
            CTBA190(.F.,Date(),Date(),cFilAnt,cFilAnt,"1",.T.,"02")
        EndIf 
    EndIf 
Return Nil

/*/{Protheus.doc} DeletaCTA
Deleta o CTA Incluido
@type function           
@author Ricardo Tavares Ferreira
@since 20/11/2022
@version 12.1.33
@history 06/11/2022, Ricardo Tavares Ferreira, Construção Inicial
/*/
//=============================================================================================================================
    Static Function DeletaCTA(cPeriodo)
//=============================================================================================================================

    Local cDelete := ""

	cDelete := " DELETE FROM " + RetSqlName("CT2") +QbLinha 
    cDelete += " WHERE " +QbLinha  
    cDelete += " D_E_L_E_T_ = ' '" +QbLinha  
    cDelete += " AND CT2_ROTINA = 'OZ34M002'" +QbLinha 
    cDelete += " AND SUBSTRING(CT2_DATA,1,6) = '"+cPeriodo+"'" +QbLinha  

    If TCSQLExec(cDelete) < 0
    	FwLogMsg("OZ34M002", /*cTransactionId*/, "DeletaCTA", FunName(), "", "01", "Erro ao Deletar os Dados da Tabela CT2 " + TCSQLError(), 0, (nStart - Seconds()), {})
    EndIf 
Return Nil 

/*/{Protheus.doc} ProcReg
Rotina de Ajuste de contabilização da moeda 02
@type function           
@author Ricardo Tavares Ferreira
@since 06/11/2022
@version 12.1.33
@history 06/11/2022, Ricardo Tavares Ferreira, Construção Inicial
/*/
//=============================================================================================================================
    Static Function ProcReg(oSay)
//=============================================================================================================================

    Local nValDebito    := 0 
    Local nValCredit    := 0 
    Local xFil          := ""
    Local xData         := ""
    Local xLote         := ""
    Local xSbLote       := ""
    Local xDoc          := ""
    Local nLin          := ""
    Local nValFim       := 0
    Local lDebito       := .F.
    Local lCredit       := .F.
    Local cContCTA1     := SuperGetMV("OZ_CTA_01",.F.,"860190997") 
    Local cContCTA2     := SuperGetMV("OZ_CTA_02",.F.,"850190997") 
    Local lExistGRP     := .F.
    Local cHistCTA      := ""
    Local cKeyCTA       := ""
    Local aDadosRet     := {}
    Local nX            := 0

    If IsBlind()
        cDtExec := Substr(Dtos(Date()),1,6)
    Else 
        cDtExec := MV_PAR01
    EndIf 

    If GetDadosGerais()
        While .not. (cAliasALL)->(Eof())
            xFil    := (cAliasALL)->CT2_FILIAL
            xData   := (cAliasALL)->CT2_DATA
            xLote   := (cAliasALL)->CT2_LOTE
            xSbLote := (cAliasALL)->CT2_SBLOTE
            xDoc    := (cAliasALL)->CT2_DOC

            If .not. lExistCTA(xFil,xData,xLote,xSbLote,xDoc)
                If ExistFina430(xFil,xData,xLote,xSbLote,xDoc)
                    aadd(aFina430,{xFil,xData,xLote,xSbLote,xDoc})
                    //(cAliasALL)->(DbSkip())
                Else 
                    aDadosRet   := GetHistCTA(xFil,xData,xLote,xSbLote,xDoc)
                    cHistCTA    := aDadosRet[1]
                    cKeyCTA     := aDadosRet[2]
                    lExistGRP   := VerificaGrupo(xFil,xData,xLote,xSbLote,xDoc)
                    nValDebito  := GetDadosDebito(xFil,xData,xLote,xSbLote,xDoc)
                    nValCredit  := GetDadosCredit(xFil,xData,xLote,xSbLote,xDoc)
                    nLin        := GetLinhaAtu(xFil,xData,xLote,xSbLote,xDoc)

                    If nValDebito > nValCredit
                        nValFim := nValDebito - nValCredit
                        lCredit := .T. 
                    Else 
                        nValFim := nValCredit - nValDebito
                        lDebito := .T.
                    EndIf 

                    If nValFim > 0
                        RecLock("CT2",.T.)
                            CT2->CT2_FILIAL := xFil
                            CT2->CT2_DATA   := Stod(xData)
                            CT2->CT2_LOTE   := xLote
                            CT2->CT2_SBLOTE := xSbLote
                            CT2->CT2_DOC    := xDoc
                            CT2->CT2_VALOR  := nValFim
                            CT2->CT2_LINHA  := nLin
                            CT2->CT2_MOEDLC := "02"
                            CT2->CT2_HIST   := "CONVERSAO CTA - " + cHistCTA
                            CT2->CT2_EMPORI := "01"
                            CT2->CT2_FILORI := xFil
                            CT2->CT2_TPSALD := "1"
                            CT2->CT2_MANUAL := "1"
                            CT2->CT2_ORIGEM := "CONVERSAO CTA - USUARIO: "+Iif(Empty(cUsrAtu),"JOB",AllTrim(Upper(UsrRetName(cUsrAtu))))
                            CT2->CT2_ROTINA := "OZ34M002"
                            CT2->CT2_AGLUT  := "2"
                            CT2->CT2_SEQHIS := "001"
                            CT2->CT2_SEQLAN := nLin
                            CT2->CT2_DTCV3  := Date()
                            CT2->CT2_CTRLSD := "2"
                            CT2->CT2_KEY    := cKeyCTA

                            If lDebito
                                CT2->CT2_DEBITO := Iif(lExistGRP,cContCTA2,cContCTA1)
                                CT2->CT2_DC     := "1"
                            Endif 

                            If lCredit
                                CT2->CT2_CREDIT := Iif(lExistGRP,cContCTA2,cContCTA1)
                                CT2->CT2_DC     := "2"
                            EndIf 
                        CT2->(MsUnlock())
                    EndIf 
                EndIf 
                lDebito := .F.
                lCredit := .F.
                (cAliasALL)->(DbSkip())
            EndIf 
        End
        If Len(aFina430) > 0
            For nX := 1 To Len(aFina430)
                ProcFina430(aFina430[nX])
            Next nX 
        EndIf 
    Else 
        If lExecJOB
            APIUtil():ConsoleLog("OZ34M002|ProcReg","Não há dados para processamento no seguinte periodo : "+cValToChar(Day(Date()))+"/"+cValToChar(Year(Date())),3)
        Else 
            APMsgInfo("Não há dados para processamento no seguinte periodo : "+cValToChar(Day(Date()))+"/"+cValToChar(Year(Date()))+".","OZ34M002")
        EndIf 
    EndIf 
    (cAliasALL)->(DbCloseArea())
Return 

/*/{Protheus.doc} ProcFina430
Processa os registros encontrdos do fina430
@type function           
@author Ricardo Tavares Ferreira
@since 07/12/2022
@version 12.1.33
@history 07/12/2022, Ricardo Tavares Ferreira, Construção Inicial
/*/
//=============================================================================================================================
    Static Function ProcFina430(aDados)
//=============================================================================================================================

    Local nQtdReg       := 0
    Local cAliasCTA     := GetNextAlias()
    Local xFil          := "" 
    Local xData         := ""
    Local xLote         := ""
    Local xSbLote       := ""
    Local xDoc          := ""
    Local aKeys         := {}
    Local nX            := 0
    Local lDebito       := .F.
    Local lCredit       := .F.
    Local cFil          := "" 
    Local cData         := "" 
    Local cLote         := "" 
    Local cSbLote       := "" 
    Local cDoc          := "" 
    Local cChave        := "" 
    Local aDadosRet     := {}
    Local cHistCTA      := ""
    Local cKeyCTA       := ""
    Local lExistGRP     := .F.
    Local nValDebito    := 0
    Local nValCredit    := 0
    Local nLin          := ""
    Local nValFim       := 0
    Local cContCTA1     := SuperGetMV("OZ_CTA_01",.F.,"860190997") 
    Local cContCTA2     := SuperGetMV("OZ_CTA_02",.F.,"850190997") 

    xFil    := aDados[1]
    xData   := aDados[2]
    xLote   := aDados[3]
    xSbLote := aDados[4]
    xDoc    := aDados[5]

    cQuery := " SELECT "+QbLinha 
    cQuery += " CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_KEY "+QbLinha 
	cQuery += " FROM "
	cQuery +=   RetSqlName("CT2") + " CT2 "+QbLinha
    cQuery += " WHERE "+QbLinha
    cQuery += " CT2.D_E_L_E_T_ = ' ' "+QbLinha 
    cQuery += " AND CT2_MOEDLC = '02' "+QbLinha
    cQuery += " AND CT2_TPSALD = '1' "+QbLinha
    cQuery += " AND CT2_FILIAL = '"+xFil+"' "+QbLinha
    cQuery += " AND CT2_DATA   = '"+xData+"' "+QbLinha
    cQuery += " AND CT2_LOTE   = '"+xLote+"' "+QbLinha
    cQuery += " AND CT2_SBLOTE = '"+xSbLote+"' "+QbLinha
    cQuery += " AND CT2_DOC    = '"+xDoc+"' "+QbLinha
    cQuery += " AND CT2_KEY <> ' ' "+QbLinha
    cQuery += " GROUP BY CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_KEY "+QbLinha
    cQuery += " HAVING COUNT(CT2_KEY) > 1 "+QbLinha

	APIUtil():ConsoleLog("OZ34M002|ProcFina430_01","Query Executada "+Alltrim(cQuery),1)	
    MemoWrite("C:/ricardo/OZ34M002_ProcFina430_01.sql",cQuery)

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasCTA,.F.,.T.)
		
	DbSelectArea(cAliasCTA)
	(cAliasCTA)->(DbGoTop())
	Count To nQtdReg
	(cAliasCTA)->(DbGoTop())
		
	If nQtdReg > 0
        While .not. (cAliasCTA)->(Eof())
            aadd(aKeys,{(cAliasCTA)->CT2_FILIAL,(cAliasCTA)->CT2_DATA,(cAliasCTA)->CT2_LOTE,(cAliasCTA)->CT2_SBLOTE,(cAliasCTA)->CT2_DOC,(cAliasCTA)->CT2_KEY})
            (cAliasCTA)->(DbSkip())
        End 
    EndIf   
    (cAliasCTA)->(DbCloseArea())

    For nX := 1 To Len(aKeys)
        cFil    := aKeys[nX][1]
        cData   := aKeys[nX][2]
        cLote   := aKeys[nX][3]
        cSbLote := aKeys[nX][4]
        cDoc    := aKeys[nX][5]
        cChave  := aKeys[nX][6]

        aDadosRet   := GetHistCTA(cFil,cData,cLote,cSbLote,cDoc,cChave)
        cHistCTA    := aDadosRet[1]
        cKeyCTA     := aDadosRet[2]
        lExistGRP   := VerificaGrupo(cFil,cData,cLote,cSbLote,cDoc,cChave)
        nValDebito  := GetDadosDebito(cFil,cData,cLote,cSbLote,cDoc,cChave)
        nValCredit  := GetDadosCredit(cFil,cData,cLote,cSbLote,cDoc,cChave)
        nLin        := GetLinhaAtu(cFil,cData,cLote,cSbLote,cDoc)

        If nValDebito > nValCredit
            nValFim := nValDebito - nValCredit
            lCredit := .T. 
        Else 
            nValFim := nValCredit - nValDebito
            lDebito := .T.
        EndIf 

        If nValFim > 0
            RecLock("CT2",.T.)
                CT2->CT2_FILIAL := cFil
                CT2->CT2_DATA   := Stod(cData)
                CT2->CT2_LOTE   := cLote
                CT2->CT2_SBLOTE := cSbLote
                CT2->CT2_DOC    := cDoc
                CT2->CT2_VALOR  := nValFim
                CT2->CT2_LINHA  := nLin
                CT2->CT2_MOEDLC := "02"
                CT2->CT2_HIST   := "CONVERSAO CTA - " + cHistCTA
                CT2->CT2_EMPORI := "01"
                CT2->CT2_FILORI := cFil
                CT2->CT2_TPSALD := "1"
                CT2->CT2_MANUAL := "1"
                CT2->CT2_ORIGEM := "CONVERSAO CTA - USUARIO: "+Iif(Empty(cUsrAtu),"JOB",AllTrim(Upper(UsrRetName(cUsrAtu))))
                CT2->CT2_ROTINA := "OZ34M002"
                CT2->CT2_AGLUT  := "2"
                CT2->CT2_SEQHIS := "001"
                CT2->CT2_SEQLAN := nLin
                CT2->CT2_DTCV3  := Date()
                CT2->CT2_CTRLSD := "2"
                CT2->CT2_KEY    := cChave

                If lDebito
                    CT2->CT2_DEBITO := Iif(lExistGRP,cContCTA2,cContCTA1)
                    CT2->CT2_DC     := "1"
                Endif

                If lCredit
                    CT2->CT2_CREDIT := Iif(lExistGRP,cContCTA2,cContCTA1)
                    CT2->CT2_DC     := "2"
                EndIf

            CT2->(MsUnlock())
        EndIf 
        lDebito := .F.
        lCredit := .F.
    Next nX 

    aDadosRet   := GetHistCTA(xFil,xData,xLote,xSbLote,xDoc)
    cHistCTA    := aDadosRet[1]
    cKeyCTA     := aDadosRet[2]
    lExistGRP   := VerificaGrupo(xFil,xData,xLote,xSbLote,xDoc)
    nValDebito  := GetDadosDebito(xFil,xData,xLote,xSbLote,xDoc)
    nValCredit  := GetDadosCredit(xFil,xData,xLote,xSbLote,xDoc)
    nLin        := GetLinhaAtu(xFil,xData,xLote,xSbLote,xDoc)

    If nValDebito > nValCredit
        nValFim := nValDebito - nValCredit
        lCredit := .T. 
    Else 
        nValFim := nValCredit - nValDebito
        lDebito := .T.
    EndIf 

    If nValFim > 0
        RecLock("CT2",.T.)
            CT2->CT2_FILIAL := xFil
            CT2->CT2_DATA   := Stod(xData)
            CT2->CT2_LOTE   := xLote
            CT2->CT2_SBLOTE := xSbLote
            CT2->CT2_DOC    := xDoc
            CT2->CT2_VALOR  := nValFim
            CT2->CT2_LINHA  := nLin
            CT2->CT2_MOEDLC := "02"
            CT2->CT2_HIST   := "CONVERSAO CTA - CT2_KEY EM BRANCO"
            CT2->CT2_EMPORI := "01"
            CT2->CT2_FILORI := xFil
            CT2->CT2_TPSALD := "1"
            CT2->CT2_MANUAL := "1"
            CT2->CT2_ORIGEM := "CONVERSAO CTA - USUARIO: "+Iif(Empty(cUsrAtu),"JOB",AllTrim(Upper(UsrRetName(cUsrAtu))))
            CT2->CT2_ROTINA := "OZ34M002"
            CT2->CT2_AGLUT  := "2"
            CT2->CT2_SEQHIS := "001"
            CT2->CT2_SEQLAN := nLin
            CT2->CT2_DTCV3  := Date()
            CT2->CT2_CTRLSD := "2"
            CT2->CT2_KEY    := cKeyCTA

            If lDebito
                CT2->CT2_DEBITO := Iif(lExistGRP,cContCTA2,cContCTA1)
                CT2->CT2_DC     := "1"
            Endif

            If lCredit
                CT2->CT2_CREDIT := Iif(lExistGRP,cContCTA2,cContCTA1)
                CT2->CT2_DC     := "2"
            EndIf

        CT2->(MsUnlock())
    EndIf 
    lDebito := .F.
    lCredit := .F.
Return Nil

/*/{Protheus.doc} ExistFina430
Verifica se Existe Fina430 para o registro passado como parametro
@type function           
@author Ricardo Tavares Ferreira
@since 07/12/2022
@version 12.1.33
@history 07/12/2022, Ricardo Tavares Ferreira, Construção Inicial
/*/
//=============================================================================================================================
    Static Function ExistFina430(xFil,xData,xLote,xSbLote,xDoc)
//=============================================================================================================================

    Local nQtdReg   := 0
    Local lRet      := .F.
    Local cAliasCTA := GetNextAlias()

    cQuery := " SELECT "+QbLinha 
    cQuery += " TOP 1 CT2_HIST, CT2_KEY "+QbLinha
	cQuery += " FROM "
	cQuery +=   RetSqlName("CT2") + " CT2 "+QbLinha
    cQuery += " WHERE "+QbLinha
    cQuery += " CT2.D_E_L_E_T_ = ' ' "+QbLinha 
    cQuery += " AND CT2_MOEDLC = '02' "+QbLinha
    cQuery += " AND CT2_TPSALD = '1' "+QbLinha
    cQuery += " AND CT2_FILIAL = '"+xFil+"' "+QbLinha
    cQuery += " AND CT2_DATA   = '"+xData+"' "+QbLinha
    cQuery += " AND CT2_LOTE   = '"+xLote+"' "+QbLinha
    cQuery += " AND CT2_SBLOTE = '"+xSbLote+"' "+QbLinha
    cQuery += " AND CT2_DOC    = '"+xDoc+"' "+QbLinha
    cQuery += " AND CT2_ROTINA = 'FINA430' "+QbLinha
    cQuery += " ORDER BY CT2_LINHA "+QbLinha

	APIUtil():ConsoleLog("OZ34M002|ExistFina430","Query Executada "+Alltrim(cQuery),1)	
    MemoWrite("C:/ricardo/OZ34M002_ExistFina430.sql",cQuery)

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasCTA,.F.,.T.)
		
	DbSelectArea(cAliasCTA)
	(cAliasCTA)->(DbGoTop())
	Count To nQtdReg
	(cAliasCTA)->(DbGoTop())
		
	If nQtdReg > 0
        lRet := .T.
    EndIf   
    (cAliasCTA)->(DbCloseArea())
Return lRet

/*/{Protheus.doc} GetHistCTA
Verifica grupo de contas
@type function           
@author Ricardo Tavares Ferreira
@since 07/12/2022
@version 12.1.33
@history 07/12/2022, Ricardo Tavares Ferreira, Construção Inicial
/*/
//=============================================================================================================================
    Static Function GetHistCTA(xFil,xData,xLote,xSbLote,xDoc,cKey)
//=============================================================================================================================

    Local nQtdReg   := 0
    Local cHist     := ""
    Local cAliasCTA := GetNextAlias()

    Default cKey    := ""

    cQuery := " SELECT "+QbLinha 
    cQuery += " TOP 1 CT2_HIST, CT2_KEY "+QbLinha
	cQuery += " FROM "
	cQuery +=   RetSqlName("CT2") + " CT2 "+QbLinha
    cQuery += " WHERE "+QbLinha
    cQuery += " CT2.D_E_L_E_T_ = ' ' "+QbLinha 
    cQuery += " AND CT2_MOEDLC = '02' "+QbLinha
    cQuery += " AND CT2_TPSALD = '1' "+QbLinha
    cQuery += " AND CT2_FILIAL = '"+xFil+"' "+QbLinha
    cQuery += " AND CT2_DATA   = '"+xData+"' "+QbLinha
    cQuery += " AND CT2_LOTE   = '"+xLote+"' "+QbLinha
    cQuery += " AND CT2_SBLOTE = '"+xSbLote+"' "+QbLinha
    cQuery += " AND CT2_DOC    = '"+xDoc+"' "+QbLinha

    If .not. Empty(cKey)
        cQuery += " AND CT2_KEY    = '"+cKey+"' "+QbLinha
    EndIf 

    cQuery += " ORDER BY CT2_LINHA "+QbLinha

	APIUtil():ConsoleLog("OZ34M002|GetHistCTA","Query Executada "+Alltrim(cQuery),1)	
    MemoWrite("C:/ricardo/OZ34M002_GetHistCTA.sql",cQuery)

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasCTA,.F.,.T.)
		
	DbSelectArea(cAliasCTA)
	(cAliasCTA)->(DbGoTop())
	Count To nQtdReg
	(cAliasCTA)->(DbGoTop())
		
	If nQtdReg > 0
        cHist   := Alltrim((cAliasCTA)->CT2_HIST)
        cKeyCTA := (cAliasCTA)->CT2_KEY
    EndIf   
    (cAliasCTA)->(DbCloseArea())
Return {cHist, cKeyCTA}

/*/{Protheus.doc} VerificaGrupo
Verifica grupo de contas
@type function           
@author Ricardo Tavares Ferreira
@since 07/12/2022
@version 12.1.33
@history 07/12/2022, Ricardo Tavares Ferreira, Construção Inicial
/*/
//=============================================================================================================================
    Static Function VerificaGrupo(xFil,xData,xLote,xSbLote,xDoc,cKey)
//=============================================================================================================================

    Local nQtdReg       := 0
	Local lRet 		    := .F.
    Local cAliasCTA     := GetNextAlias()
    Local cGrupoCTA     := FormatIn(SuperGetMV("OZ_GRPCTA",.F.,"110101|110102|110103|110104"),"|")

    Default cKey        := ""

    cQuery := " SELECT "+QbLinha 
    cQuery += " CT2_ORIGEM CT2_ORIGEM"+QbLinha
	cQuery += " FROM "
	cQuery +=   RetSqlName("CT2") + " CT2 "+QbLinha
    cQuery += " WHERE "+QbLinha
    cQuery += " CT2.D_E_L_E_T_ = ' ' "+QbLinha 
    cQuery += " AND CT2_MOEDLC = '02' "+QbLinha
    cQuery += " AND CT2_TPSALD = '1' "+QbLinha
    cQuery += " AND CT2_FILIAL = '"+xFil+"' "+QbLinha
    cQuery += " AND CT2_DATA   = '"+xData+"' "+QbLinha
    cQuery += " AND CT2_LOTE   = '"+xLote+"' "+QbLinha
    cQuery += " AND CT2_SBLOTE = '"+xSbLote+"' "+QbLinha
    cQuery += " AND CT2_DOC    = '"+xDoc+"' "+QbLinha
    cQuery += " AND (SUBSTRING(CT2_DEBITO,1,6) IN "+cGrupoCTA+" OR SUBSTRING(CT2_CREDIT,1,6) IN "+cGrupoCTA+") "+QbLinha

    If .not. Empty(cKey)
        cQuery += " AND CT2_KEY    = '"+cKey+"' "+QbLinha
    EndIf 

	APIUtil():ConsoleLog("OZ34M002|VerificaGrupo","Query Executada "+Alltrim(cQuery),1)	
    MemoWrite("C:/ricardo/OZ34M002_VerificaGrupo.sql",cQuery)

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasCTA,.F.,.T.)
		
	DbSelectArea(cAliasCTA)
	(cAliasCTA)->(DbGoTop())
	Count To nQtdReg
	(cAliasCTA)->(DbGoTop())
		
	If nQtdReg > 0
		lRet := .T.
    EndIf   
    (cAliasCTA)->(DbCloseArea())
Return lRet

/*/{Protheus.doc} GetLinhaAtu
Busca a ultima linha do bloco avalidado
@type function           
@author Ricardo Tavares Ferreira
@since 06/11/2022
@version 12.1.33
@history 06/11/2022, Ricardo Tavares Ferreira, Construção Inicial
/*/
//=============================================================================================================================
    Static Function GetLinhaAtu(xFil,xData,xLote,xSbLote,xDoc)
//=============================================================================================================================

    Local nQtdReg       := 0
    Local cAliasCRE     := GetNextAlias()
    Local nLin          := 0

    cQuery := " SELECT MAX(CT2_LINHA) CT2_LINHA"+QbLinha
	cQuery += " FROM "
	cQuery +=   RetSqlName("CT2") + " CT2 "+QbLinha
    cQuery += " WHERE "+QbLinha
    cQuery += " CT2.D_E_L_E_T_ = ' ' "+QbLinha 
    cQuery += " AND CT2_MOEDLC = '02' "+QbLinha
    cQuery += " AND CT2_TPSALD = '1' "+QbLinha
    cQuery += " AND CT2_FILIAL = '"+xFil+"' "+QbLinha
    cQuery += " AND CT2_DATA   = '"+xData+"' "+QbLinha
    cQuery += " AND CT2_LOTE   = '"+xLote+"' "+QbLinha
    cQuery += " AND CT2_SBLOTE = '"+xSbLote+"' "+QbLinha
    cQuery += " AND CT2_DOC    = '"+xDoc+"' "+QbLinha

	APIUtil():ConsoleLog("OZ34M002|GetLinhaAtu","Query Executada "+Alltrim(cQuery),1)
    MemoWrite("C:/ricardo/OZ34M002_GetLinhaAtu.sql",cQuery)	

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasCRE,.F.,.T.)
		
	DbSelectArea(cAliasCRE)
	(cAliasCRE)->(DbGoTop())
	Count To nQtdReg
	(cAliasCRE)->(DbGoTop())
		
	If nQtdReg > 0
		nLin := Soma1((cAliasCRE)->CT2_LINHA)
    EndIf   
    (cAliasCRE)->(DbCloseArea())
Return nLin

/*/{Protheus.doc} GetDadosCredit
Busca os dados de Credito do bloco avalidado
@type function           
@author Ricardo Tavares Ferreira
@since 06/11/2022
@version 12.1.33
@history 06/11/2022, Ricardo Tavares Ferreira, Construção Inicial
/*/
//=============================================================================================================================
    Static Function GetDadosCredit(xFil,xData,xLote,xSbLote,xDoc,cKey)
//=============================================================================================================================

    Local nQtdReg       := 0
	Local nValCre 		:= 0
    Local cAliasCRE     := GetNextAlias()

    Default cKey        := ""

    cQuery := " SELECT "+QbLinha 
    cQuery += " SUM(CT2_VALOR) CT2_VALOR "+QbLinha
	cQuery += " FROM "
	cQuery +=   RetSqlName("CT2") + " CT2 "+QbLinha
    cQuery += " WHERE "+QbLinha
    cQuery += " CT2.D_E_L_E_T_ = ' ' "+QbLinha 
    cQuery += " AND CT2_MOEDLC = '02' "+QbLinha
    cQuery += " AND CT2_TPSALD = '1' "+QbLinha
    cQuery += " AND CT2_FILIAL = '"+xFil+"' "+QbLinha
    cQuery += " AND CT2_DATA   = '"+xData+"' "+QbLinha
    cQuery += " AND CT2_LOTE   = '"+xLote+"' "+QbLinha
    cQuery += " AND CT2_SBLOTE = '"+xSbLote+"' "+QbLinha
    cQuery += " AND CT2_DOC    = '"+xDoc+"' "+QbLinha
    cQuery += " AND CT2_DC     = '2' "+QbLinha

    If .not. Empty(cKey)
        cQuery += " AND CT2_KEY    = '"+cKey+"' "+QbLinha
    EndIf 

	APIUtil():ConsoleLog("OZ34M002|GetDadosCredito","Query Executada "+Alltrim(cQuery),1)	
    MemoWrite("C:/ricardo/OZ34M002_GetDadosCredit.sql",cQuery)

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasCRE,.F.,.T.)
		
	DbSelectArea(cAliasCRE)
	(cAliasCRE)->(DbGoTop())
	Count To nQtdReg
	(cAliasCRE)->(DbGoTop())
		
	If nQtdReg > 0
		nValCre := (cAliasCRE)->CT2_VALOR
    EndIf   
    (cAliasCRE)->(DbCloseArea())
Return nValCre

/*/{Protheus.doc} GetDadosDebito
Busca os dados de debito do bloco avalidado
@type function           
@author Ricardo Tavares Ferreira
@since 06/11/2022
@version 12.1.33
@history 06/11/2022, Ricardo Tavares Ferreira, Construção Inicial
/*/
//=============================================================================================================================
    Static Function GetDadosDebito(xFil,xData,xLote,xSbLote,xDoc,cKey)
//=============================================================================================================================

    Local nQtdReg       := 0
	Local nValDeb 		:= 0
    Local cAliasDEB     := GetNextAlias()
    
    Default cKey        := ""

    cQuery := " SELECT "+QbLinha 
    cQuery += " SUM(CT2_VALOR) CT2_VALOR "+QbLinha
	cQuery += " FROM "
	cQuery +=   RetSqlName("CT2") + " CT2 "+QbLinha
    cQuery += " WHERE "+QbLinha
    cQuery += " CT2.D_E_L_E_T_ = ' ' "+QbLinha 
    cQuery += " AND CT2_MOEDLC = '02' "+QbLinha
    cQuery += " AND CT2_TPSALD = '1' "+QbLinha
    cQuery += " AND CT2_FILIAL = '"+xFil+"' "+QbLinha
    cQuery += " AND CT2_DATA   = '"+xData+"' "+QbLinha
    cQuery += " AND CT2_LOTE   = '"+xLote+"' "+QbLinha
    cQuery += " AND CT2_SBLOTE = '"+xSbLote+"' "+QbLinha
    cQuery += " AND CT2_DOC    = '"+xDoc+"' "+QbLinha
    cQuery += " AND CT2_DC     = '1' "+QbLinha

    If .not. Empty(cKey)
        cQuery += " AND CT2_KEY    = '"+cKey+"' "+QbLinha
    EndIf 

	APIUtil():ConsoleLog("OZ34M002|GetDadosDebito","Query Executada "+Alltrim(cQuery),1)	
    MemoWrite("C:/ricardo/OZ34M002_GetDadosDebito.sql",cQuery)	

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasDEB,.F.,.T.)
		
	DbSelectArea(cAliasDEB)
	(cAliasDEB)->(DbGoTop())
	Count To nQtdReg
	(cAliasDEB)->(DbGoTop())
		
	If nQtdReg > 0
		nValDeb := (cAliasDEB)->CT2_VALOR
    EndIf   
    (cAliasDEB)->(DbCloseArea())
Return nValDeb

/*/{Protheus.doc} lExistCTA
Verifica se existe a linha do CTA
@type function           
@author Ricardo Tavares Ferreira
@since 06/11/2022
@version 12.1.33
@history 06/11/2022, Ricardo Tavares Ferreira, Construção Inicial
/*/
//=============================================================================================================================
    Static Function lExistCTA(xFil,xData,xLote,xSbLote,xDoc)
//=============================================================================================================================

    Local nQtdReg       := 0
	Local lRet 		    := .F.
    Local cAliasCTA     := GetNextAlias()

    cQuery := " SELECT "+QbLinha 
    cQuery += " CT2_ORIGEM, CT2_HIST, CT2_LINHA"+QbLinha
	cQuery += " FROM "
	cQuery +=   RetSqlName("CT2") + " CT2 "+QbLinha
    cQuery += " WHERE "+QbLinha
    cQuery += " CT2.D_E_L_E_T_ = ' ' "+QbLinha 
    cQuery += " AND CT2_MOEDLC = '02' "+QbLinha
    cQuery += " AND CT2_TPSALD = '1' "+QbLinha
    cQuery += " AND CT2_ROTINA = 'OZ34M002' "+QbLinha
    cQuery += " AND CT2_FILIAL = '"+xFil+"' "+QbLinha
    cQuery += " AND CT2_DATA   = '"+xData+"' "+QbLinha
    cQuery += " AND CT2_LOTE   = '"+xLote+"' "+QbLinha
    cQuery += " AND CT2_SBLOTE = '"+xSbLote+"' "+QbLinha
    cQuery += " AND CT2_DOC    = '"+xDoc+"' "+QbLinha
    cQuery += " ORDER BY CT2_LINHA DESC "+QbLinha

	APIUtil():ConsoleLog("OZ34M002|lExistCTA","Query Executada "+Alltrim(cQuery),1)	
    MemoWrite("C:/ricardo/OZ34M002_lExistCTA.sql",cQuery)	

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasCTA,.F.,.T.)
		
	DbSelectArea(cAliasCTA)
	(cAliasCTA)->(DbGoTop())
	Count To nQtdReg
	(cAliasCTA)->(DbGoTop())
		
	If nQtdReg > 0
		lRet  := .T.
    EndIf   
    (cAliasCTA)->(DbCloseArea())
Return lRet

/*/{Protheus.doc} GetDadosGerais
Busca dos dados gerais para processamento
@type function           
@author Ricardo Tavares Ferreira
@since 06/11/2022
@version 12.1.33
@history 06/11/2022, Ricardo Tavares Ferreira, Construção Inicial
/*/
//=============================================================================================================================
    Static Function GetDadosGerais()
//=============================================================================================================================

    Local nQtdReg   := 0
	Local lRet 		:= .F.

    cQuery := " SELECT "+QbLinha 
    cQuery += " CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC "+QbLinha 
	cQuery += " FROM "
	cQuery +=   RetSqlName("CT2") + " CT2 "+QbLinha
    cQuery += " WHERE "+QbLinha
    cQuery += " CT2.D_E_L_E_T_ = ' ' "+QbLinha 
    cQuery += " AND CT2_MOEDLC = '02' "+QbLinha
    cQuery += " AND CT2_TPSALD = '1' "+QbLinha
    cQuery += " AND SUBSTRING(CT2_DATA,1,6) = '"+cDtExec+"' "+QbLinha
    cQuery += " GROUP BY CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC "+QbLinha
    cQuery += " ORDER BY CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC "+QbLinha

	APIUtil():ConsoleLog("OZ34M002|GetDadosGerais","Query Executada "+Alltrim(cQuery),1)	
    MemoWrite("C:/ricardo/OZ34M002_GetDadosGerais.sql",cQuery)	

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasALL,.F.,.T.)
		
	DbSelectArea(cAliasALL)
	(cAliasALL)->(DbGoTop())
	Count To nQtdReg
	(cAliasALL)->(DbGoTop())
		
	If nQtdReg > 0
		lRet := .T.
    EndIf   
Return lRet

/*/{Protheus.doc} GetPerg
Criacao das Perguntas da Rotina tipo Parambox. 
@type function
@author Ricardo Tavares Ferreira
@since 27/04/2022
@version 12.1.27
@return logical, Retorna logico se confirmou os paramtros.
@history 27/04/2022, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//====================================================================================================
	Static Function GetPerg()
//====================================================================================================

    Local aPergs	    := {}
    Local aRet		    := {}
    Local lRet		    := .T.
    //Local aTpExec       := {"Processamento","Estorno"} 
    Private cCadastro   := "Perguntas"

 	aAdd(aPergs,{1,"Periodo (AAAAMM)" ,Padr("",6),"","","","",50,.T.}) //MV_PAR01
    //aadd(aPergs,{3,"Tipo de Execução"	, 1         ,aTpExec,65,"",.T.,}) //MV_PAR01
    //aadd(aPergs,{6,"Local do Arquivo",Padr("",300),"",".T.","",80,.T.,""/*"Arquivos CSV |*.csv"*/,"",GETF_LOCALHARD+GETF_NETWORKDRIVE}) // MV_PAR02

	If .not. ParamBox(aPergs,"Processamento de Lançamentos",aRet,/*bValid*/,/*aButtons*/,.T.,/*nPosX*/,/*nPosY*/,/*oDialog*/,"OZ34M001",.T.,.T.)
		lRet := .F.
	EndIf 
Return lRet
