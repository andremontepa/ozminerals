#INCLUDE "PROTHEUS.CH"


/*/=========================================================================================
	PCOOZR01 - SOLICITACAO X PCO
==========================================================================================/*/

USER FUNCTION PCOOZR01()

IF !INPUT()
    MsgAlert("Cancelado pelo Operador")
    RETURN
ELSE
    PROCESSA({||PROCXLS()})
ENDIF

RETURN

/*/=========================================================================================
	PROCXLS - GERAXLS
==========================================================================================/*/
STATIC FUNCTION PROCXLS()

Private oExcel := FWMsExcel():New() 

PROCREGUA(0)
INCPROC(TIME()+" Aguarde...")


IF SELECT("TSC1") <> 0
    TSC1->( dbclosearea() )
ENDIF

INCPROC(TIME()+" Consultando banco")
BEGINSQL ALIAS "TSC1"
    COLUMN EMISSAO AS DATE
    COLUMN QTDE    AS NUMERIC(16,2)
    COLUMN VUNIT   AS NUMERIC(16,2)
    COLUMN TOTAL   AS NUMERIC(16,2)

    SELECT C1_EMISSAO EMISSAO,C1_NUM SOLICITACAO,C1_ITEM ITEM, C1_PRODUTO PRODUTO ,B1_DESC DESC_PROD 
    ,ISNULL(C1_CLVL,'') CLASSE_VALOR, C1_CC CENTRO_CUSTO, ISNULL(CT.CTT_DESC01,'') CC_DESC
    , C1_QUANT QTDE, C1_VUNIT VUNIT, CAST(C1_QUANT * C1_VUNIT AS NUMERIC(16,2))TOTAL
    , CASE WHEN CT.CTT_CLASCC = '1' THEN B1_CTAATIV ELSE
    CASE WHEN CT.CTT_CLASCC = '2' THEN B1_CTACUST ELSE
    CASE WHEN CT.CTT_CLASCC = '3' THEN B1_CTADESP ELSE
    CASE WHEN CT.CTT_CLASCC = '4' THEN B1_XCTAEXP ELSE ' ' END END END END CONTAORC
    , CASE WHEN CT.CTT_CLASCC = '1' THEN 'ATIVO'    ELSE
    CASE WHEN CT.CTT_CLASCC = '2' THEN 'CUSTO'    ELSE
    CASE WHEN CT.CTT_CLASCC = '3' THEN 'DESPESA' ELSE
    CASE WHEN CT.CTT_CLASCC = '4' THEN 'EXPLORACAO' ELSE ' ' END END END END TIPOCUSTO  
    , ISNULL(AKD_HIST,'') HIST_PCO
    , CASE WHEN ISNULL(AKD_STATUS,'') = '1' THEN 'APROVADO' ELSE 
    CASE WHEN ISNULL(AKD_STATUS,'') = '2' THEN 'INVALIDO' ELSE
    CASE WHEN ISNULL(AKD_STATUS,'') = '3' THEN 'ESTORNO' ELSE
    'NAO_INTEGRADO' END END END PCO_STATUS
    FROM %TABLE:SC1% C1
    LEFT JOIN %TABLE:SB1% B1 ON B1.%NOTDEL% AND B1_COD = C1_PRODUTO
    LEFT JOIN %TABLE:CTT% CT ON CT.%NOTDEL% AND CT.CTT_CUSTO = C1_CC
    LEFT JOIN %TABLE:AKD% KD ON KD.%NOTDEL% AND AKD_SC1 = C1_NUM AND AKD_ITSC1 = C1_ITEM 
                    AND KD.AKD_FILORI = C1_FILIAL AND KD.AKD_TPSALD = %EXP:ALLTRIM(MV_PAR03)% AND AKD_STATUS IN('1','2','3')
    WHERE C1.%NOTDEL%
    AND C1_EMISSAO BETWEEN %EXP:DTOS(MV_PAR01)% AND %EXP:DTOS(MV_PAR02)%
    AND C1_VUNIT > 0  
    ORDER BY C1_EMISSAO, C1_NUM, C1_ITEM

ENDSQL

MEMOWRITE("C:\TEMP\PCOOZR01.SQL",GETLASTQUERY()[2])
oExcel:AddworkSheet("PCO")
oExcel:AddTable ("PCO","SOLICITACAO")
oExcel:AddColumn("PCO","SOLICITACAO","EMISSAO",1,1)
oExcel:AddColumn("PCO","SOLICITACAO","SOLICITACAO",1,1)
oExcel:AddColumn("PCO","SOLICITACAO","ITEM",1,1)
oExcel:AddColumn("PCO","SOLICITACAO","PRODUTO",1,1)
oExcel:AddColumn("PCO","SOLICITACAO","DESC_PROD",1,1)
oExcel:AddColumn("PCO","SOLICITACAO","CLASSE_VALOR",1,1)
oExcel:AddColumn("PCO","SOLICITACAO","CENTRO_CUSTO",1,1)
oExcel:AddColumn("PCO","SOLICITACAO","CCUSTO_DESCR",1,1)
oExcel:AddColumn("PCO","SOLICITACAO","TIPO_CUSTO",1,1)
oExcel:AddColumn("PCO","SOLICITACAO","QTDADE",3,3)
oExcel:AddColumn("PCO","SOLICITACAO","VUNIT",3,3)
oExcel:AddColumn("PCO","SOLICITACAO","TOTAL",3,3)
oExcel:AddColumn("PCO","SOLICITACAO","CONTA_ORCAM",1,1)
oExcel:AddColumn("PCO","SOLICITACAO","HIST_PCO",1,1)
oExcel:AddColumn("PCO","SOLICITACAO","STATUS",1,1)


dbselectarea("TSC1")
dbgotop()
WHILE TSC1->(!EOF()) 
    INCPROC(TIME()+" Gerando...") 
    aDados := { TSC1->EMISSAO  ,;
                TSC1->SOLICITACAO ,;
                TSC1->ITEM ,;
                TSC1->PRODUTO ,;
                TSC1->DESC_PROD ,;
                TSC1->CLASSE_VALOR ,;
                TSC1->CENTRO_CUSTO ,;
                TSC1->CC_DESC ,;
                TSC1->TIPOCUSTO ,;
                TSC1->QTDE ,;
                TSC1->VUNIT,;
                TSC1->TOTAL,;
                TSC1->CONTAORC,;
                TSC1->HIST_PCO,;
                TSC1->PCO_STATUS   }
   
    oExcel:AddRow("PCO","SOLICITACAO",aDados)

    TSC1->(dbskip())
 ENDDO   

cFileXLS := "C:\TEMP\PCO_SC1_"+DTOS(MV_PAR01)+"_"+DTOS(MV_PAR02)+".XML"
oExcel:Activate()
oExcel:GetXMLFile(cFileXLS)
SLEEP(2000)

MsgAlert("Ver arquivo gerado: "+cFileXLS)



RETURN

/*/=========================================================================================
	INPUT - PARAMETROS
==========================================================================================/*/
STATIC FUNCTION INPUT()

	Local lRetP := .T.

	local aParamBox  := {}
	local aRet       := {}
	local bOk        := {|| .t.}
	local aButtons   := {}
	local lCentered  := .t.
	local nPosX      := nil
	local nPosY      := nil
	local oDlgWizard := nil
	local cLoad      := "PODTER" + ".pbx"
	local lCanSave   := .t.
	local lUserSave  := .t.
	local okPress    := .f.
	Local cTitle     := "PCO-SOLICITACAI/PCO V1.0"

	Local dPar01 := STOD("")
	Local dPar02 := STOD("")
	Local cPar03 := SPACE(2)
	
	aAdd(aParamBox, {1, "Emissao   :", dPar01, "@D", "", "", "", 050, .T.})
	aAdd(aParamBox, {1, "Emissao:  :", dPar02, "@D", "", "", "", 050, .T.})
	AADD(APARAMBOX, {1, "Tipo Saldo:", cPar03, "@!",  "", "AL2A  ", "", 050, .T.})

	okPress := paramBox(aParamBox ;		//Array: 	Array contendo as perguntas
	, cTitle ;		//Caracter:	Título da tela
	, aRet ;		//Array:	Array contendo as respostas
	, bOk ;			//Array:	Code block para validar o botão Ok
	, aButtons; 	//Array:	Array contendo definições dos botões opcionais, além dos botões de Ok e Cancel
	, lCentered ; 	//Lógico:	Indica se será centralizada a janela
	, nPosX ;		//Numérico:	Se não centralizar janela, coordenada X da janela
	, nPosY ;		//Numérico:	Se não centralizar janela, coordenada Y da janela
	, oDlgWizard ;	//Objeto: 	Objeto referente à janela ativa
	, cLoad ;		//Caracter:	Nome arquivo para gravar respostas
	, lCanSave ; 	//Lógico:	Indica se pode salvar o arquivo com respostas
	, lUserSave)	//Lógico:	Indica se salva nome do usuario no arquivo

	if !okPress
		lRetP := .f.

	endIf

  /*
	AREGS := {}
	AADD(AREGS,{cPerg,"09","Cliente/Fornec De ?","","","MV_CH9","C",09,0,0,"G","","MV_PAR09","","","","","","","","","","","","","","","","","","","","","","","","","SA2SB6","","","","",""})
	AADD(AREGS,{cPerg,"10","Cliente/Fornec Ate ?","","","MV_CHA","C",09,0,0,"G","","MV_PAR10","","","","","","","","","","","","","","","","","","","","","","","","","SA2SB6","","","","",""})
	AADD(AREGS,{cPerg,"11","Tipo          ?","","","MV_CHB","N",01,0,0,"C","","MV_PAR11","Em Terceiros","","","","","De Terceiros","","","","","Ambos","","","","","","","","","","","","","","","","","","",""})
	DBSELECTAREA("SX1")
*/


Return(lRetP)


