#INCLUDE 'TOPCONN.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWBROWSE.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'AP5MAIL.CH'
#INCLUDE 'REPORT.CH'
#INCLUDE 'PROTHEUS.CH'

#DEFINE CRLF Chr(13)+Chr(10) 

/*/{Protheus.doc} RT34R002
Relatorio de Impressao do Balancete
@author Ricardo Tavares Ferreira
@since 18/05/2020
@version 12.1.25
@return Nil
@obs Ricardo Tavares - Construcao Inicial
/*/
//====================================================================================================
    User Function RT34R002()
//====================================================================================================

	Local lConfirm      := .F.
	Local oReport 		:= Nil
	Private cPerg     	:= "RT34R002"

    While .T.
        CriaPar(cPerg)
		If Pergunte(cPerg,.T.)
            lConfirm := .T.
            Exit
		Else
			If MsgNoYes("Foi detectado o cancelamento do preechimento dos parametros. Deseja realmente sair da impressao do Relatorio ( Sim | Nao )?","A T E N C A O !!!")
				Return Nil
			EndIf
		EndIf
	End

    If lConfirm
		If MV_PAR03 == 1 .and. ! Empty(MV_PAR04)
			Processa( {|| GeraArq() }, "Aguarde...", "Gerando Arquivo do Balancete...",.F.)
        Else
            oReport := ReportDef()
    		oReport:PrintDialog()
        EndIf
    EndIf
Return Nil

/*/{Protheus.doc} GeraArq
Função que busca os dados no banco
@author Ricardo Tavares Ferreira
@since 08/01/2019
@version 12.1.17
@return Nil
@obs Ricardo Tavares - Construcao Inicial
/*/
//====================================================================================================
    Static Function GeraArq()
//====================================================================================================

    Local cAliasQry     := GetNextAlias()
    Local cEmpresa      := FWCodEmp()
    Local cFiltro       := ""
    Local cEmpQry       := "%"+ "'"+cEmpresa+"'" + "%"
	Local cDirDocs		:= MsDocPath()
	Local cArq			:= ""
 //   Local cPathTmp		:= ""
	Local nQtdReg		:= 0
	Local nHandle		:= 0
	Private QbLinha	    := chr(13)+chr(10)
 
    cFiltro += " A.EMP = '"+cEmpresa+"' AND A.ANO = '"+Alltrim(MV_PAR01)+"' AND A.MES = '"+Alltrim(MV_PAR02)+"' "
    cFiltro := "%"+ cFiltro + "%"

    BeginSql alias cAliasQry
        SELECT %Exp:cEmpQry% EMPRESA, Z.ITEMCTA CODCCUSTO, ISNULL((SELECT CASE WHEN W.CTD_DESC02 = '' THEN W.CTD_DESC01 ELSE W.CTD_DESC02 END  AS  DESCRICACAO FROM CTD010 W WHERE W.D_E_L_E_T_ = '' AND W.CTD_ITEM = Z.ITEMCTA),'') ITEMCTA, Z.CONTA CONTA, Z.DESCRICAO DESCRICAO, SUM(Z.SLDANT) SLDANT, SUM(Z.VLRDEBITO) VLRDEBITO, SUM(Z.VLRCREDITO) VLRCREDITO, SUM(Z.MOVPER) MOVPER, SUM(Z.VLRCTA) VLRCTA, SUM(Z.SLDFINAL) SLDFINAL 
        FROM
        (
            SELECT %Exp:cEmpQry% EMPRESA, CASE WHEN SUBSTRING(A.CTA1,1,1) >= '6' THEN A.CODCCUSTO ELSE '' END AS CODCCUSTO, CASE WHEN SUBSTRING(A.CTA1,1,1) >= '6' THEN A.ITEMCTA ELSE '' END AS ITEMCTA, A.CTA1 CONTA, A.DESC_CTA1 DESCRICAO, SUM(A.SALDOANT) SLDANT, SUM(A.MOVDEBITO) VLRDEBITO, SUM(A.MOVCREDITO) VLRCREDITO, SUM(A.MOVPERIODO) MOVPER, SUM(A.VLRCTA) VLRCTA, SUM(A.SALDOFINAL) SLDFINAL
            FROM BALUSD A
            WHERE %Exp:cFiltro%
            GROUP BY A.CODCCUSTO, A.ITEMCTA, A.CTA1, A.DESC_CTA1
            
            UNION ALL
            
            SELECT %Exp:cEmpQry% EMPRESA, CASE WHEN SUBSTRING(A.CTA2,1,1) >= '6' THEN A.CODCCUSTO ELSE '' END AS CODCCUSTO, CASE WHEN SUBSTRING(A.CTA2,1,1) >= '6' THEN A.ITEMCTA ELSE '' END AS ITEMCTA, A.CTA2 CONTA, A.DESC_CTA2 DESCRICAO, SUM(A.SALDOANT) SLDANT, SUM(A.MOVDEBITO) VLRDEBITO, SUM(A.MOVCREDITO) VLRCREDITO, SUM(A.MOVPERIODO) MOVPER, SUM(A.VLRCTA) VLRCTA, SUM(A.SALDOFINAL) SLDFINAL
            FROM BALUSD A
            WHERE %Exp:cFiltro%
            GROUP BY A.CODCCUSTO, A.ITEMCTA, A.CTA2, A.DESC_CTA2
            
            UNION ALL
            
            SELECT %Exp:cEmpQry% EMPRESA, CASE WHEN SUBSTRING(A.CTA3,1,1) >= '6' THEN A.CODCCUSTO ELSE '' END AS CODCCUSTO, CASE WHEN SUBSTRING(A.CTA3,1,1) >= '6' THEN A.ITEMCTA ELSE '' END AS ITEMCTA, A.CTA3 CONTA, A.DESC_CTA3 DESCRICAO, SUM(A.SALDOANT) SLDANT, SUM(A.MOVDEBITO) VLRDEBITO, SUM(A.MOVCREDITO) VLRCREDITO, SUM(A.MOVPERIODO) MOVPER, SUM(A.VLRCTA) VLRCTA, SUM(A.SALDOFINAL) SLDFINAL
            FROM BALUSD A
            WHERE %Exp:cFiltro%
            GROUP BY A.CODCCUSTO, A.ITEMCTA, A.CTA3, A.DESC_CTA3
            
            UNION ALL
            
            SELECT %Exp:cEmpQry% EMPRESA, CASE WHEN SUBSTRING(A.CTA4,1,1) >= '6' THEN A.CODCCUSTO ELSE '' END AS CODCCUSTO, CASE WHEN SUBSTRING(A.CTA4,1,1) >= '6' THEN A.ITEMCTA ELSE '' END AS ITEMCTA, A.CTA4 CONTA, A.DESC_CTA4 DESCRICAO, SUM(A.SALDOANT) SLDANT, SUM(A.MOVDEBITO) VLRDEBITO, SUM(A.MOVCREDITO) VLRCREDITO, SUM(A.MOVPERIODO) MOVPER, SUM(A.VLRCTA) VLRCTA, SUM(A.SALDOFINAL) SLDFINAL
            FROM BALUSD A
            WHERE %Exp:cFiltro%
            GROUP BY A.CODCCUSTO, A.ITEMCTA, A.CTA4, A.DESC_CTA4
            
            UNION ALL
            
            SELECT %Exp:cEmpQry% EMPRESA, CASE WHEN SUBSTRING(A.CTA5,1,1) >= '6' THEN A.CODCCUSTO ELSE '' END AS CODCCUSTO, CASE WHEN SUBSTRING(A.CTA5,1,1) >= '6' THEN A.ITEMCTA ELSE '' END AS ITEMCTA, A.CTA5 CONTA, A.DESC_CTA5 DESCRICAO, SUM(A.SALDOANT) SLDANT, SUM(A.MOVDEBITO) VLRDEBITO, SUM(A.MOVCREDITO) VLRCREDITO, SUM(A.MOVPERIODO) MOVPER, SUM(A.VLRCTA) VLRCTA, SUM(A.SALDOFINAL) SLDFINAL
            FROM BALUSD A
            WHERE %Exp:cFiltro%
            GROUP BY A.CODCCUSTO, A.ITEMCTA, A.CTA5, A.DESC_CTA5
        ) Z
        GROUP BY Z.CODCCUSTO, Z.ITEMCTA, Z.CONTA, Z.DESCRICAO
        ORDER BY Z.CONTA, Z.CODCCUSTO, Z.ITEMCTA
    EndSql
	
    MemoWrite("C:\ricardo\RT34R002_arq.sql",getLastQuery()[2])

	DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())
	Count To nQtdReg
	(cAliasQry)->(DbGoTop())

	If nQtdReg > 0
		ProcRegua(nQtdReg)

		cArq := "RT34R002.csv"
		If File(cDirDocs+"\"+cArq)
			FErase(cDirDocs+"\"+cArq)
		EndIf  
		nHandle := FCreate(cDirDocs+"\"+cArq,0) 
		If nHandle >= 0
			FWrite(nHandle,"Company;Account;Description;Cost Center;Description;Previous Balance;Debt Amount;Credit Amount;Period Movement;Account Amount;Final Balance"+QbLinha)
			While .not. (cAliasQry)->(EOF())
				IncProc()
				FWrite(nHandle,Alltrim((cAliasQry)->EMPRESA)+";"+Alltrim((cAliasQry)->CONTA)+";"+Alltrim((cAliasQry)->DESCRICAO)+";"+Alltrim((cAliasQry)->CODCCUSTO)+";"+Alltrim((cAliasQry)->ITEMCTA)+";"+Alltrim(Transform((cAliasQry)->SLDANT,PesqPict("CT2","CT2_VALOR")))+";"+Alltrim(Transform((cAliasQry)->VLRDEBITO,PesqPict("CT2","CT2_VALOR")))+";"+Alltrim(Transform((cAliasQry)->VLRCREDITO,PesqPict("CT2","CT2_VALOR")))+";"+Alltrim(Transform((cAliasQry)->MOVPER,PesqPict("CT2","CT2_VALOR")))+";"+Alltrim(Transform((cAliasQry)->VLRCTA,PesqPict("CT2","CT2_VALOR")))+";"+Alltrim(Transform((cAliasQry)->SLDFINAL,PesqPict("CT2","CT2_VALOR"))) +QbLinha)
				(cAliasQry)->(DbSkip())
			End
		EndIf
	EndIf

    (cAliasQry)->(DbCloseArea())
	FClose(nHandle)
    If File(MV_PAR04+cArq)
        FErase(MV_PAR04+cArq)
    EndIf  
    CpyS2T(cDirDocs+"\"+cArq,MV_PAR04,.t.)
Return Nil

/*/{Protheus.doc} ReportDef
Monta a Impressao do Relatorio
@author Ricardo Tavares Ferreira
@since 08/01/2019
@version 12.1.17
@return oReport
@obs Ricardo Tavares - Construcao Inicial
/*/
//====================================================================================================
    Static Function ReportDef()
//====================================================================================================

    Local oReport   := Nil
    Local cReport   := "RT34R002"
    Local cDescri   := "Balance Sheet - Period: " + Alltrim(MV_PAR02) +"/"+ Alltrim(MV_PAR01)
    Local cTitulo   := "Balance Sheet - Period: " + Alltrim(MV_PAR02) +"/"+ Alltrim(MV_PAR01)
    Local oBalanc   := Nil // Seção de conta corrente

    // cria as perguntas do relatório
	//CriaPar(cPerg)

	// força a inicialização das perguntas
	//Pergunte(cPerg,.F.)

    DEFINE REPORT oReport NAME cReport TITLE cTitulo PARAMETER cPerg ACTION {|oReport| ReportPrt(oReport)} DESCRIPTION cDescri
	
    oReport:lParamPage := .F.
    oReport:SetPortrait()

		DEFINE SECTION oBalanc OF oReport TITLE "Balance Sheet - Period: " + Alltrim(MV_PAR02) +"/"+ Alltrim(MV_PAR01) AUTO SIZE
			DEFINE CELL NAME "EMPRESA"    OF oBalanc TITLE "Company"            PICTURE PesqPict("CT2","CT2_FILIAL") SIZE 15   
			DEFINE CELL NAME "CONTA"      OF oBalanc TITLE "Account"            PICTURE PesqPict("CT1","CT1_CONTA" ) SIZE 35
			DEFINE CELL NAME "DESCRICAO"  OF oBalanc TITLE "Description"        PICTURE PesqPict("CT1","CT1_DESC02") SIZE 60
			DEFINE CELL NAME "CODCCUSTO"  OF oBalanc TITLE "Cost Centre"        PICTURE PesqPict("CT2","CT2_CCC" )   SIZE 15
            DEFINE CELL NAME "ITEMCTA"    OF oBalanc TITLE "Description"        PICTURE PesqPict("CTD","CTD_DESC02") SIZE 60
            DEFINE CELL NAME "SLDANT"     OF oBalanc TITLE "Previous Balance"   PICTURE PesqPict("CT2","CT2_VALOR" ) SIZE 40     
			DEFINE CELL NAME "VLRDEBITO"  OF oBalanc TITLE "Debt Amount"        PICTURE PesqPict("CT2","CT2_VALOR" ) SIZE 40
			DEFINE CELL NAME "VLRCREDITO" OF oBalanc TITLE "Credit Amount"      PICTURE PesqPict("CT2","CT2_VALOR" ) SIZE 40
			DEFINE CELL NAME "MOVPER"     OF oBalanc TITLE "Period Movement"    PICTURE PesqPict("CT2","CT2_VALOR" ) SIZE 40
            DEFINE CELL NAME "VLRCTA"     OF oBalanc TITLE "Account Amount"     PICTURE PesqPict("CT2","CT2_VALOR" ) SIZE 40
			DEFINE CELL NAME "SLDFINAL"   OF oBalanc TITLE "Final Balance"      PICTURE PesqPict("CT2","CT2_VALOR" ) SIZE 40                     
			
Return oReport

/*/{Protheus.doc} ReportPrt
Função que busca os dados no banco
@author Ricardo Tavares Ferreira
@since 08/01/2019
@version 12.1.17
@return Nil
@obs Ricardo Tavares - Construcao Inicial
/*/
//====================================================================================================
    Static Function ReportPrt(oReport)
//====================================================================================================

    Local cAliasQry     := GetNextAlias()
    Local oBalanc       := oReport:Section(1)
    Local cEmpresa      := FWCodEmp()
    Local cFiltro       := ""
    Local cEmpQry       := "%"+ "'"+cEmpresa+"'" + "%"
 
    oReport:HideFooter() //Oculta o rodape do relatorio

    cFiltro += " A.EMP = '"+cEmpresa+"' AND A.ANO = '"+Alltrim(MV_PAR01)+"' AND A.MES = '"+Alltrim(MV_PAR02)+"' "
    cFiltro := "%"+ cFiltro + "%"

    BeginSql alias cAliasQry
        SELECT %Exp:cEmpQry% EMPRESA, Z.ITEMCTA CODCCUSTO, ISNULL((SELECT CASE WHEN W.CTD_DESC02 = '' THEN W.CTD_DESC01 ELSE W.CTD_DESC02 END  AS  DESCRICACAO FROM CTD010 W WHERE W.D_E_L_E_T_ = '' AND W.CTD_ITEM = Z.ITEMCTA),'') ITEMCTA, Z.CONTA CONTA, Z.DESCRICAO DESCRICAO, SUM(Z.SLDANT) SLDANT, SUM(Z.VLRDEBITO) VLRDEBITO, SUM(Z.VLRCREDITO) VLRCREDITO, SUM(Z.MOVPER) MOVPER, SUM(Z.VLRCTA) VLRCTA, SUM(Z.SLDFINAL) SLDFINAL 
        FROM
        (
            SELECT %Exp:cEmpQry% EMPRESA, CASE WHEN SUBSTRING(A.CTA1,1,1) >= '6' THEN A.CODCCUSTO ELSE '' END AS CODCCUSTO, CASE WHEN SUBSTRING(A.CTA1,1,1) >= '6' THEN A.ITEMCTA ELSE '' END AS ITEMCTA, A.CTA1 CONTA, A.DESC_CTA1 DESCRICAO, SUM(A.SALDOANT) SLDANT, SUM(A.MOVDEBITO) VLRDEBITO, SUM(A.MOVCREDITO) VLRCREDITO, SUM(A.MOVPERIODO) MOVPER, SUM(A.VLRCTA) VLRCTA, SUM(A.SALDOFINAL) SLDFINAL
            FROM BALUSD A
            WHERE %Exp:cFiltro%
            GROUP BY A.CODCCUSTO, A.ITEMCTA, A.CTA1, A.DESC_CTA1
            
            UNION ALL
            
            SELECT %Exp:cEmpQry% EMPRESA, CASE WHEN SUBSTRING(A.CTA2,1,1) >= '6' THEN A.CODCCUSTO ELSE '' END AS CODCCUSTO, CASE WHEN SUBSTRING(A.CTA2,1,1) >= '6' THEN A.ITEMCTA ELSE '' END AS ITEMCTA, A.CTA2 CONTA, A.DESC_CTA2 DESCRICAO, SUM(A.SALDOANT) SLDANT, SUM(A.MOVDEBITO) VLRDEBITO, SUM(A.MOVCREDITO) VLRCREDITO, SUM(A.MOVPERIODO) MOVPER, SUM(A.VLRCTA) VLRCTA, SUM(A.SALDOFINAL) SLDFINAL
            FROM BALUSD A
            WHERE %Exp:cFiltro%
            GROUP BY A.CODCCUSTO, A.ITEMCTA, A.CTA2, A.DESC_CTA2
            
            UNION ALL
            
            SELECT %Exp:cEmpQry% EMPRESA, CASE WHEN SUBSTRING(A.CTA3,1,1) >= '6' THEN A.CODCCUSTO ELSE '' END AS CODCCUSTO, CASE WHEN SUBSTRING(A.CTA3,1,1) >= '6' THEN A.ITEMCTA ELSE '' END AS ITEMCTA, A.CTA3 CONTA, A.DESC_CTA3 DESCRICAO, SUM(A.SALDOANT) SLDANT, SUM(A.MOVDEBITO) VLRDEBITO, SUM(A.MOVCREDITO) VLRCREDITO, SUM(A.MOVPERIODO) MOVPER, SUM(A.VLRCTA) VLRCTA, SUM(A.SALDOFINAL) SLDFINAL
            FROM BALUSD A
            WHERE %Exp:cFiltro%
            GROUP BY A.CODCCUSTO, A.ITEMCTA, A.CTA3, A.DESC_CTA3
            
            UNION ALL
            
            SELECT %Exp:cEmpQry% EMPRESA, CASE WHEN SUBSTRING(A.CTA4,1,1) >= '6' THEN A.CODCCUSTO ELSE '' END AS CODCCUSTO, CASE WHEN SUBSTRING(A.CTA4,1,1) >= '6' THEN A.ITEMCTA ELSE '' END AS ITEMCTA, A.CTA4 CONTA, A.DESC_CTA4 DESCRICAO, SUM(A.SALDOANT) SLDANT, SUM(A.MOVDEBITO) VLRDEBITO, SUM(A.MOVCREDITO) VLRCREDITO, SUM(A.MOVPERIODO) MOVPER, SUM(A.VLRCTA) VLRCTA, SUM(A.SALDOFINAL) SLDFINAL
            FROM BALUSD A
            WHERE %Exp:cFiltro%
            GROUP BY A.CODCCUSTO, A.ITEMCTA, A.CTA4, A.DESC_CTA4
            
            UNION ALL
            
            SELECT %Exp:cEmpQry% EMPRESA, CASE WHEN SUBSTRING(A.CTA5,1,1) >= '6' THEN A.CODCCUSTO ELSE '' END AS CODCCUSTO, CASE WHEN SUBSTRING(A.CTA5,1,1) >= '6' THEN A.ITEMCTA ELSE '' END AS ITEMCTA, A.CTA5 CONTA, A.DESC_CTA5 DESCRICAO, SUM(A.SALDOANT) SLDANT, SUM(A.MOVDEBITO) VLRDEBITO, SUM(A.MOVCREDITO) VLRCREDITO, SUM(A.MOVPERIODO) MOVPER, SUM(A.VLRCTA) VLRCTA, SUM(A.SALDOFINAL) SLDFINAL
            FROM BALUSD A
            WHERE %Exp:cFiltro%
            GROUP BY A.CODCCUSTO, A.ITEMCTA, A.CTA5, A.DESC_CTA5
        ) Z
        GROUP BY Z.CODCCUSTO, Z.ITEMCTA, Z.CONTA, Z.DESCRICAO
        ORDER BY Z.CONTA, Z.CODCCUSTO, Z.ITEMCTA
    EndSql
        	
    MemoWrite("C:\ricardo\RT34R002.sql",getLastQuery()[2])

	oBalanc:Cell("EMPRESA"   ):SetBlock({|| Alltrim((cAliasQry)->EMPRESA)   })
    oBalanc:Cell("CONTA"     ):SetBlock({|| Alltrim((cAliasQry)->CONTA)     })
    oBalanc:Cell("DESCRICAO" ):SetBlock({|| Alltrim((cAliasQry)->DESCRICAO) })
    oBalanc:Cell("CODCCUSTO" ):SetBlock({|| Alltrim((cAliasQry)->CODCCUSTO) })
    oBalanc:Cell("ITEMCTA"   ):SetBlock({|| Alltrim((cAliasQry)->ITEMCTA)   })
	oBalanc:Cell("SLDANT"    ):SetBlock({|| (cAliasQry)->SLDANT             })   
    oBalanc:Cell("VLRDEBITO" ):SetBlock({|| (cAliasQry)->VLRDEBITO          })
    oBalanc:Cell("VLRCREDITO"):SetBlock({|| (cAliasQry)->VLRCREDITO         })
    oBalanc:Cell("MOVPER"    ):SetBlock({|| (cAliasQry)->MOVPER             })
    oBalanc:Cell("VLRCTA"    ):SetBlock({|| (cAliasQry)->VLRCTA             })
    oBalanc:Cell("SLDFINAL"  ):SetBlock({|| (cAliasQry)->SLDFINAL           })

    oBalanc:Init()
    oReport:SetMeter((cAliasQry)->(LastRec()))

    While .not. (cAliasQry)->(EOF())
        oReport:IncMeter()
        oBalanc:PrintLine()
        (cAliasQry)->(DbSkip())
    End

    oBalanc:Finish()
    (cAliasQry)->(DbCloseArea())
Return Nil

/*/{Protheus.doc} CriaPar
Ajusta os parametros das perguntas na tabela SX1.
@author Ricardo Tavares Ferreira
@since 08/01/2019
@version 12.1.17
@return Nil
@obs Ricardo Tavares - Construcao Inicial
/*/
//====================================================================================================
    static function CriaPar(cPerg)
//====================================================================================================

    Local aTam		:= {}
	Local aHelpPor	:= {}

    aTam 		:= TamSx3("R4_ANO")
	aHelpPor 	:= {}
	aAdd(aHelpPor,"Informe o Ano para filtro de geração.") 
	U_xPutSx1(cPerg,"01","Ano","","","MV_CH01",aTam[3],aTam[1],aTam[2],0,"G","","","","","MV_PAR01","","","","","","","","","","","","","","","","",aHelpPor,{},{}) 

    aTam 		:= TamSx3("R4_MES")
	aHelpPor 	:= {}
	aAdd(aHelpPor,"Informe o Mês para filtro de geração.") 
	U_xPutSx1(cPerg,"02","Mês","","","MV_CH02",aTam[3],aTam[1],aTam[2],0,"G","","","","","MV_PAR02","","","","","","","","","","","","","","","","",aHelpPor,{},{}) 

	aTam 		:= TamSX3("R4_ISNIF")
	aHelpPor 	:= {}
	aAdd(aHelpPor,"Tipo de Geração Sendo: Arquivo ou Relatório" ) 
	U_xPutSx1(cPerg,"03","Tipo de Geração" ,"","","MV_CH03","N",01,00,00,"C","","","","","MV_PAR03","Arquivo","","","","Relatório","","","","","","","","","","","",aHelpPor,{},{}) 

    aTam 		:= TamSX3("RA_LOGRDSC")
	aHelpPor 	:= {}
	aAdd(aHelpPor,"Diretorio onde será salvo o arquivo do balancete gerado" ) 
	U_xPutSx1(cPerg,"04","Diretório do Arquivo" ,"","","MV_CH04",aTam[3],aTam[1],aTam[2],0,"G","","HSSDIR","","","MV_PAR04","","","","","","","","","","","","","","","","",aHelpPor,{},{}) 

Return nil