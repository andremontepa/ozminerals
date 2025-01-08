#Include "PROTHEUS.CH"
#Include "XMLXFUN.CH"
#Include "APWEBSRV.CH"
#Include "topconn.ch"
#Include "RWMAKE.CH"
#Include "TBICONN.CH"
#Include "ERROR.CH"


/*/{Protheus.doc} Contabilizacoes
Funcao que monta as estruturas do array do WebService de Contabilizacao
@author Ricardo Tavares Ferreira
@since 24/09/2019
@version 12.1.17
@return .T.
@obs Ricardo Tavares - Construcao Inicial
/*/
//====================================================================================================
    WsStruct Registros
//====================================================================================================

    WSDATA Contabilizacoes as Array of ItensContabilizados

EndWsStruct

/*/{Protheus.doc} Contabilizacoes
Funcao que monta as estruturas do array do WebService de Contabilizacao
@author Ricardo Tavares Ferreira
@since 24/09/2019
@version 12.1.17
@return .T.
@obs Ricardo Tavares - Construcao Inicial
/*/
//====================================================================================================
    WsStruct ItensContabilizados
//====================================================================================================

    WsData Empresa     as String
    WsData Filial      as String
    WsData DataLanc    as String
    WsData Lote        as String 
    WsData SubLote     as String 
    WsData Documento   as String 
    WsData TotalGeral  as Float
    WSDATA Itens       as Array of Linha	
EndWsStruct

/*/{Protheus.doc} Item
Funcao que monta as estruturas do array do WebService de Itens da Contabilizacao
@author Ricardo Tavares Ferreira
@since 24/09/2019
@version 12.1.17
@return .T.
@obs Ricardo Tavares - Construcao Inicial
/*/
//====================================================================================================
    WsStruct Linha
//====================================================================================================
    
    WsData Linha            as String
    WsData Moeda            as String 
    WsData TipoLanc         as String 
    WsData ContaDebito      as String
    WsData ContaCredito     as String
    WsData CCustoDebito     as String
    WsData CCustoCredito    as String 
    WsData ItemDebito       as String
    WsData ItemCredito      as String     
    WsData ClasseDebito     as String
    WsData ClasseCredito    as String   
    WsData Valor            as Float
    WsData Origem           as String
    WsData Historico        as String

EndWsStruct

/*/{Protheus.doc} WsPagamentos
Funcao que cria o WebService de Pagamentos
@author Ricardo Tavares Ferreira
@since 29/08/2019
@version 12.1.17
@return .T.
@obs Ricardo Tavares - Construcao Inicial
/*/
//==============================================================================================================================================================================================================================
    WsService WsContabilizacao Description "Busca e Insere os dados da Contabilização no Modulo Contabilidade Gerencial"
//==============================================================================================================================================================================================================================

    WsData Empresa              as String
    WsData FilialInicial        as String 
    WsData FilialFinal          as String 
    WsData DataInicial          as String 
    WsData DataFinal            as String 
    WsData DocInicial           as String 
    WsData DocFinal             as String
    WsData cRetContabiliza      as String 

   	WsData PostContabilizaLote  as Registros
    WsData GetContabilizaLote   as Registros

	WsMethod GetContabilizacao 	Description "Retorna os Registros contabilizados por meio da Integração."
	WsMethod PostContabilizacao	Description "Insere os Registros para Contabilização no Sistema por meio de Integração."
EndWsService

/*/{Protheus.doc} PostContabilizacao
Funcao que contabiliza os registros enviados
@author Ricardo Tavares Ferreira
@since 29/08/2019
@version 12.1.17
@return .T.
@obs Ricardo Tavares - Construcao Inicial
/*/
//===============================================================================================================
    WsMethod PostContabilizacao WsReceive PostContabilizaLote WsSend cRetContabiliza WsService WsContabilizacao
//===============================================================================================================

    Local aArea         := GetArea()
    Local nX            := 0
    Local nY            := 0
    Local nZ            := 0
    Local aCabec        := {}
    Local aItens        := {}
    Local aLogAuto      := {}
    Local cFilAt        := cFilant
    Local cEmpBck       := cEmpAnt
    Local aTables       := {"SA2","SE2","SED"}  
    Local cError        := ""
    Local nValor        := 0 
    Private lMsErroAuto := .F.
    Private lMsHelpAuto	:= .T. 

    RPCSetType(3)
	RpcSetEnv("99","01",Nil,Nil,"FIN",Nil,aTables)

    If Len(POSTCONTABILIZALOTE:CONTABILIZACOES) > 0
        For nX := 1 To Len(POSTCONTABILIZALOTE:CONTABILIZACOES)
            cEmpAnt := Alltrim(POSTCONTABILIZALOTE:CONTABILIZACOES[nX]:EMPRESA)
            cFilAnt := Alltrim(POSTCONTABILIZALOTE:CONTABILIZACOES[nX]:FILIAL)
            
            aCabec := {{ "DDATALANC"   , Stod(POSTCONTABILIZALOTE:CONTABILIZACOES[nX]:DATALANC)    ,NIL},;
                       { "CLOTE"       , Alltrim(POSTCONTABILIZALOTE:CONTABILIZACOES[nX]:LOTE)     ,NIL},;
                       { "CSUBLOTE"    , Alltrim(POSTCONTABILIZALOTE:CONTABILIZACOES[nX]:SUBLOTE)  ,NIL},;
                       { "CDOC"        , Alltrim(POSTCONTABILIZALOTE:CONTABILIZACOES[nX]:DOCUMENTO),NIL},;
                       { "CPADRAO"     , ""                                                        ,NIL},;
                       { "NTOTINF"     , 0                                                         ,NIL},;
                       { "NTOTINFLOT"  , 0                                                         ,NIL} }
        
            For nY := 1 To Len(POSTCONTABILIZALOTE:CONTABILIZACOES[nX]:ITENS)

                nValor := GetTaxa(cFilAnt,POSTCONTABILIZALOTE:CONTABILIZACOES[nX]:ITENS[nY]:VALOR,POSTCONTABILIZALOTE:CONTABILIZACOES[nX]:DATALANC) 

                aadd(aItens,{{ "CT2_FILIAL" , Alltrim(POSTCONTABILIZALOTE:CONTABILIZACOES[nX]:FILIAL)                           , NIL},;
                             { "CT2_LINHA"  , Alltrim(POSTCONTABILIZALOTE:CONTABILIZACOES[nX]:ITENS[nY]:LINHA)                  , NIL},;
                             { "CT2_MOEDLC" , Alltrim(POSTCONTABILIZALOTE:CONTABILIZACOES[nX]:ITENS[nY]:MOEDA)                  , NIL},;
                             { "CT2_DC"     , Alltrim(POSTCONTABILIZALOTE:CONTABILIZACOES[nX]:ITENS[nY]:TIPOLANC)               , NIL},;
                             { "CT2_DEBITO" , Alltrim(POSTCONTABILIZALOTE:CONTABILIZACOES[nX]:ITENS[nY]:CONTADEBITO)            , NIL},;
                             { "CT2_CREDIT" , Alltrim(POSTCONTABILIZALOTE:CONTABILIZACOES[nX]:ITENS[nY]:CONTACREDITO)           , NIL},;
                             { "CT2_VALOR"  , nValor                                                                            , NIL},;
                             { "CT2_CCD"    , Alltrim(POSTCONTABILIZALOTE:CONTABILIZACOES[nX]:ITENS[nY]:CCUSTODEBITO)           , NIL},;
                             { "CT2_CCC"    , Alltrim(POSTCONTABILIZALOTE:CONTABILIZACOES[nX]:ITENS[nY]:CCUSTOCREDITO)          , NIL},;
                             { "CT2_CLVLDB" , Alltrim(POSTCONTABILIZALOTE:CONTABILIZACOES[nX]:ITENS[nY]:CLASSEDEBITO)           , NIL},;
                             { "CT2_CLVLCR" , Alltrim(POSTCONTABILIZALOTE:CONTABILIZACOES[nX]:ITENS[nY]:CLASSECREDITO)          , NIL},;
                             { "CT2_ITEMC"  , Alltrim(POSTCONTABILIZALOTE:CONTABILIZACOES[nX]:ITENS[nY]:ITEMCREDITO)            , NIL},;
                             { "CT2_ITEMD"  , Alltrim(POSTCONTABILIZALOTE:CONTABILIZACOES[nX]:ITENS[nY]:ITEMDEBITO)             , NIL},;
                             { "CT2_ORIGEM" , Alltrim(POSTCONTABILIZALOTE:CONTABILIZACOES[nX]:ITENS[nY]:ORIGEM)                 , NIL},;
                             { "CT2_HP"     , ""                                                                                , NIL},;
                             { "CT2_HIST"   , SubStr(Alltrim(POSTCONTABILIZALOTE:CONTABILIZACOES[nX]:ITENS[nY]:HISTORICO),1,80) , NIL}})
                                            
            Next nY

            MSExecAuto( {|X,Y,Z| CTBA102(X,Y,Z)},aCabec,aItens,3)

            If lMsErroAuto
                //cError :=  MostraErro()
                aLogAuto := GetAutoGRLog()
                For nZ := 1 To Len(aLogAuto)
                    cError += aLogAuto[nZ] + chr(13)+chr(10)
                Next nZ
                SetSoapFault("404 ",cError)
                Return .F.                       
            Endif
            aCabec := {}
            aItens := {}
            cError := ""
        Next nX
    Else 
        SetSoapFault("404 ","Dados nao Encontrados.")
        Return .F.    
    EndIf
    RestArea(aArea)
    cEmpAnt := cEmpBck
    cFilant := cFilAt
    ::cRetContabiliza := "201 Registros Incluidos com Sucesso."
Return .T.

/*/{Protheus.doc} GetContabilizacao
Funcao que busca os dados Contabilizados
@author Ricardo Tavares Ferreira
@since 29/08/2019
@version 12.1.17
@return .T.
@obs Ricardo Tavares - Construcao Inicial
/*/
//==============================================================================================================================================================================================================================
    WsMethod GetContabilizacao WsReceive Empresa, FilialInicial, FilialFinal, DataInicial, DataFinal, DocInicial, DocFinal WsSend GetContabilizaLote WsService WsContabilizacao
//==============================================================================================================================================================================================================================

    Local cQuery        := ""
	Local QbLinha	    := chr(13)+chr(10)
    Local nQtdReg       := 0
    Local aTables       := {"CT2","CTA","CTT"}
    Local cAliasCont    := ""
    Local cEmpBck       := cEmpAnt
    Local xFil          := "" 
    Local xLote         := "" 
    Local xSubLote      := "" 
    Local xDoc          := "" 
    Local nX            := 1
    Local nY            := 1

    RPCSetType(3)
	RpcSetEnv("99","01",Nil,Nil,"CTB",Nil,aTables)

    cEmpAnt   := Empresa
    cAliasCont := GetNextAlias()

    cQuery := " SELECT "+QbLinha 
    cQuery += " CT2_FILIAL FILIAL "+QbLinha 
    cQuery += " , SUBSTRING(CT2_DATA,7,2)+'/'+SUBSTRING(CT2_DATA,5,2)+'/'+SUBSTRING(CT2_DATA,1,4) DATALANC 
    cQuery += " , CT2_LOTE LOTE "+QbLinha 
    cQuery += " , CT2_SBLOTE SUBLOTE "+QbLinha
    cQuery += " , CT2_DOC DOC "+QbLinha 
    cQuery += " , CT2_LINHA LINHA "+QbLinha 
    cQuery += " , CASE "+QbLinha 
    cQuery += "     WHEN CT2_MOEDLC = '01' THEN '01-REAL' "+QbLinha
    cQuery += "     WHEN CT2_MOEDLC = '02' THEN '02-DOLAR' "+QbLinha
    cQuery += "     ELSE '00-OUTRA' "+QbLinha
    cQuery += "     END MOEDA "+QbLinha 
    cQuery += " , CASE "+QbLinha 
    cQuery += "     WHEN CT2_DC = '1' THEN '1-DEBITO' "+QbLinha
    cQuery += "     WHEN CT2_DC = '2' THEN '2-CREDITO' "+QbLinha
    cQuery += "     WHEN CT2_DC = '3' THEN '3-PARTIDA DOBRADA' "+QbLinha
    cQuery += "     WHEN CT2_DC = '4' THEN '4-CONT. HISTORICO' "+QbLinha
    cQuery += "     WHEN CT2_DC = '5' THEN '5-RATEIO' "+QbLinha
    cQuery += "     WHEN CT2_DC = '6' THEN '6-LANCTO. PADRAO' "+QbLinha
    cQuery += "     ELSE '0-OUTROS' "+QbLinha
    cQuery += "     END TIPOLANC "+QbLinha
    cQuery += " , CT2_DEBITO CONTADEB "+QbLinha 
    cQuery += " , CT2_CREDIT CONTACRED "+QbLinha
    cQuery += " , CT2_CCD CUSTODEB "+QbLinha 
    cQuery += " , CT2_CCC CUSTOCRED "+QbLinha
    cQuery += " , CT2_ITEMD ITEMDEB "+QbLinha
    cQuery += " , CT2_ITEMC ITEMCRED "+QbLinha
    cQuery += " , CT2_CLVLDB CLASSEDEB "+QbLinha
    cQuery += " , CT2_CLVLCR CLASSECRED "+QbLinha
    cQuery += " , CT2_VALOR VALOR "+QbLinha
    cQuery += " , CT2_ROTINA ORIGEM "+QbLinha
    cQuery += " , CT2_HIST HISTORICO "+QbLinha
    cQuery += " FROM "
    cQuery +=   RetSqlName("CT2") + " CT2 "+QbLinha
    cQuery += " WHERE CT2.D_E_L_E_T_ = ' ' "+QbLinha
    cQuery += " AND CT2_FILIAL BETWEEN '"+FilialInicial+"' AND '"+FilialFinal+"' "+QbLinha
    cQuery += " AND CT2_DATA BETWEEN '"+DataInicial+"' AND '"+DataFinal+"' "+QbLinha
    cQuery += " AND CT2_DOC BETWEEN '"+DocInicial+"' AND '"+DocFinal+"' "+QbLinha

    MemoWrite("C:/ricardo/GetContabiliza.sql",cQuery)			     
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasCont,.F.,.T.)
		
	DbSelectArea(cAliasCont)
	(cAliasCont)->(DbGoTop())
	Count To nQtdReg
	(cAliasCont)->(DbGoTop())
		
	If nQtdReg <= 0
		(cAliasCont)->(DbCloseArea())
        SetSoapFault( "406", "Dados nao Encontrados." )
        Return .F.
    Else
        xFil     := (cAliasCont)->FILIAL   
        xLote    := (cAliasCont)->LOTE 
        xSubLote := (cAliasCont)->SUBLOTE 
        xDoc     := (cAliasCont)->DOC 

        While .not. (cAliasCont)->(Eof())
            xFil     := (cAliasCont)->FILIAL   
            xLote    := (cAliasCont)->LOTE 
            xSubLote := (cAliasCont)->SUBLOTE 
            xDoc     := (cAliasCont)->DOC

            aadd(GetContabilizaLote:Contabilizacoes,WSCLASSNEW("ItensContabilizados"))
 
            GetContabilizaLote:Contabilizacoes[nY]:DataLanc   := (cAliasCont)->DATALANC
            GetContabilizaLote:Contabilizacoes[nY]:Empresa    := Alltrim(cEmpAnt)
            GetContabilizaLote:Contabilizacoes[nY]:Documento  := xDoc
            GetContabilizaLote:Contabilizacoes[nY]:Filial     := xFil
            GetContabilizaLote:Contabilizacoes[nY]:Lote       := xLote
            GetContabilizaLote:Contabilizacoes[nY]:SubLote    := xSubLote
            GetContabilizaLote:Contabilizacoes[nY]:TotalGeral := GetToTal(xFil,xLote,xSubLote,xDoc)
            GetContabilizaLote:Contabilizacoes[nY]:Itens      := {}

            While .not. (cAliasCont)->(Eof()) .and. (cAliasCont)->FILIAL == xFil .and. (cAliasCont)->LOTE == xLote .and. (cAliasCont)->SUBLOTE == xSubLote .and. (cAliasCont)->DOC == xDoc
                aadd(GetContabilizaLote:Contabilizacoes[nY]:Itens,WSCLASSNEW("Linha"))

                GetContabilizaLote:Contabilizacoes[nY]:Itens[nX]:Linha        :=  Alltrim((cAliasCont)->(LINHA)) 
                GetContabilizaLote:Contabilizacoes[nY]:Itens[nX]:Moeda        :=  Alltrim((cAliasCont)->(MOEDA))   
                GetContabilizaLote:Contabilizacoes[nY]:Itens[nX]:TipoLanc     :=  Alltrim((cAliasCont)->(TIPOLANC))
                GetContabilizaLote:Contabilizacoes[nY]:Itens[nX]:ContaDebito  :=  Alltrim((cAliasCont)->(CONTADEB))
                GetContabilizaLote:Contabilizacoes[nY]:Itens[nX]:ContaCredito :=  Alltrim((cAliasCont)->(CONTACRED))
                GetContabilizaLote:Contabilizacoes[nY]:Itens[nX]:CCustoDebito :=  Alltrim((cAliasCont)->(CUSTODEB))
                GetContabilizaLote:Contabilizacoes[nY]:Itens[nX]:CCustoCredito:=  Alltrim((cAliasCont)->(CUSTOCRED))
                GetContabilizaLote:Contabilizacoes[nY]:Itens[nX]:ItemDebito   :=  Alltrim((cAliasCont)->(ITEMDEB))
                GetContabilizaLote:Contabilizacoes[nY]:Itens[nX]:ItemCredito  :=  Alltrim((cAliasCont)->(ITEMCRED))
                GetContabilizaLote:Contabilizacoes[nY]:Itens[nX]:ClasseDebito :=  Alltrim((cAliasCont)->(CLASSEDEB))
                GetContabilizaLote:Contabilizacoes[nY]:Itens[nX]:ClasseCredito:=  Alltrim((cAliasCont)->(CLASSECRED))
                GetContabilizaLote:Contabilizacoes[nY]:Itens[nX]:Valor        :=  (cAliasCont)->(VALOR)
                GetContabilizaLote:Contabilizacoes[nY]:Itens[nX]:Origem       :=  Alltrim((cAliasCont)->(ORIGEM))
                GetContabilizaLote:Contabilizacoes[nY]:Itens[nX]:Historico    :=  Alltrim((cAliasCont)->(HISTORICO))

                nX += 1
                (cAliasCont)->(DbSkip())
            End
            nX := 1
            nY += 1
        End
        nY := 1
        (cAliasCont)->(DbCloseArea())
    EndIf
    cEmpAnt := cEmpBck
Return .T.

/*/{Protheus.doc} GetTaxa
Funcao que o valor convertido em real.
@author Ricardo Tavares Ferreira
@since 29/08/2019
@version 12.1.17
@return .T.
@obs Ricardo Tavares - Construcao Inicial
/*/
//===============================================================================================================
    Static Function GetTaxa(xFil,nVal,xDtLanc)
//===============================================================================================================
   
    Local nValor        := 0 
    Local cQuery        := ""
	Local QbLinha	    := chr(13)+chr(10)
    Local cAliasTaxa    := GetNextAlias()

    cQuery := " SELECT CTP_TAXA TAXA "+QbLinha 
    cQuery += " FROM "
    cQuery +=   RetSqlName("CTP") + " CTP "+QbLinha
    cQuery += " WHERE CTP.D_E_L_E_T_ = ' ' "+QbLinha 
    cQuery += " AND CTP_MOEDA = '02' "+QbLinha
    cQuery += " AND CTP_BLOQ = '2' "+QbLinha
    cQuery += " AND CTP_FILIAL = '"+xFil+"' "+QbLinha
    cQuery += " AND CTP_DATA = '"+xDtLanc+"' "+QbLinha

    MemoWrite("C:/ricardo/GetContabiliza_GetTaxa.sql",cQuery)			     
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasTaxa,.F.,.T.)
		
	DbSelectArea(cAliasTaxa)
	(cAliasTaxa)->(DbGoTop())
	Count To nQtdReg
	(cAliasTaxa)->(DbGoTop())
		
	If nQtdReg <= 0
		(cAliasTaxa)->(DbCloseArea())
    Else
        nValor := (nVal * (cAliasTaxa)->(TAXA))
        (cAliasTaxa)->(DbCloseArea())
    EndIf

Return nValor 

/*/{Protheus.doc} GetToTal
Funcao que busca o total da contabilização
@author Ricardo Tavares Ferreira
@since 29/08/2019
@version 12.1.17
@return .T.
@obs Ricardo Tavares - Construcao Inicial
/*/
//===============================================================================================================
    Static Function GetToTal(xFil,xLote,xSubLote,xDoc)
//===============================================================================================================
    
    Local nTotal        := 0
    Local cQuery        := ""
	Local QbLinha	    := chr(13)+chr(10)
    Local cAliasTotal   := GetNextAlias()
    Local nQtdReg       := 0

    cQuery := " SELECT "+QbLinha
    cQuery += " CT2_FILIAL FILIAL "+QbLinha
    cQuery += " , CT2_DATA DATAEMI "+QbLinha
    cQuery += " , CT2_LOTE LOTE "+QbLinha 
    cQuery += " , CT2_SBLOTE SUBLOTE "+QbLinha
    cQuery += " , CT2_DOC DOC "+QbLinha 
    cQuery += " , SUM(CT2_VALOR) VALOR "+QbLinha
    cQuery += " FROM "
    cQuery +=   RetSqlName("CT2") + " CT2 "+QbLinha
    cQuery += " WHERE CT2.D_E_L_E_T_ = ' ' "+QbLinha 
    cQuery += " AND CT2_FILIAL = '"+xFil+"' "+QbLinha
    cQuery += " AND CT2_LOTE = '"+xLote+"' "+QbLinha
    cQuery += " AND CT2_SBLOTE = '"+xSubLote+"' "+QbLinha
    cQuery += " AND CT2_DOC = '"+xDoc+"' "+QbLinha
    cQuery += " GROUP BY CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC "+QbLinha  

    MemoWrite("C:/ricardo/GetContabiliza_GetToTal.sql",cQuery)			     
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasTotal,.F.,.T.)
		
	DbSelectArea(cAliasTotal)
	(cAliasTotal)->(DbGoTop())
	Count To nQtdReg
	(cAliasTotal)->(DbGoTop())
		
	If nQtdReg <= 0
		(cAliasTotal)->(DbCloseArea())
    Else
        nTotal := (cAliasTotal)->(VALOR)
        (cAliasTotal)->(DbCloseArea())
    EndIf
Return nTotal