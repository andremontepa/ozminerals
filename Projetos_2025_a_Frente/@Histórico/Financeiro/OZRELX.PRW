#include "totvs.ch"
#Include "Protheus.ch"
#Include "Fileio.ch"
#include "rwmake.ch"
#include "topconn.ch"
#Include 'TBICONN.CH'
#Include "ApWebSrv.Ch"
#INCLUDE "FWMVCDEF.CH"


User Function OZRELX()

	Local oReport as Object
	Local oSection as ObjectS
	Local aParamBox    := {}
	Local aParamRet    := {}
	Local lRet		   := .T.

	
	aAdd(aParamBox,{1,"Data Base "       	  ,CToD(""),"@D" ,"","","",50,.F.}) //Data Base


	While .T.
		lRet:= .T.
		If ParamBox(aParamBox,"Parametros",@aParamRet,,,,,,,,,.T.)
			
			if AllTrim(DToC(MV_PAR01)) == "/  /"
				MsgAlert("A Data Base está em branco, Favor digitar uma data válida.","Atenção")
			Else
				Exit
			Endif
			
		Else
			MsgAlert("Não foi possível encontrar os parâmetros.","Atenção.")
			Exit
		Endif	
	EndDo


//Classe TREPORT
oReport := TReport():New('Relatorio',"Relatorio Aging",/*cPerg*/,{|oReport|ReportPrint(oReport,oSection)})

//Seção 1 
oSection := TRSection():New(oReport,'Clientes')

//Definição das colunas de impressão da seção 1
TRCell():New(oSection, "FILIAL"      , "TRB", "Filial"        , /*Picture*/         , 8   , , /*{|| code-block de impressao }*/)
TRCell():New(oSection, "PREFIXO"     , "TRB", "Prefixo"       , /*Picture*/         , 9   , , /*{|| code-block de impressao }*/)
TRCell():New(oSection, "NUMDOC"      , "TRB", "NumDoc"        , /*Picture*/         , 13  , , /*{|| code-block de impressao }*/)
TRCell():New(oSection, "TIPO"        , "TRB", "Tipo"          , /*Picture*/         , 6   , , /*{|| code-block de impressao }*/)
TRCell():New(oSection, "CODNATUREZA" , "TRB", "Cod Natureza"  , /*Picture*/         , 16  , , /*{|| code-block de impressao }*/)
TRCell():New(oSection, "NATUREZA"    , "TRB", "Natureza"      , /*Picture*/         , 51  , , /*{|| code-block de impressao }*/)
TRCell():New(oSection, "CODFORNEC"   , "TRB", "Cod Fornecedor", /*Picture*/         , 11  , , /*{|| code-block de impressao }*/)
TRCell():New(oSection, "RAZAOSOCIAL" , "TRB", "Razão Social"  , /*Picture*/         , 63  , , /*{|| code-block de impressao }*/)
TRCell():New(oSection, "CTACONTABIL" , "TRB", "CTA Contabil"  , /*Picture*/         , 13  , , /*{|| code-block de impressao }*/)
TRCell():New(oSection, "DTENTRADA"   , "TRB", "DT Entrada"    , "@R 99/99/9999"     , 14  , , /*{|| code-block de impressao }*/)
TRCell():New(oSection, "DTEMISSAO"   , "TRB", "DT Emissão"    , "@R 99/99/9999"     , 14  , , /*{|| code-block de impressao }*/)
TRCell():New(oSection, "DTVENCIMENTO", "TRB", "DT Vencimento" , "@R 99/99/9999"     , 15  , , /*{|| code-block de impressao }*/)
TRCell():New(oSection, "VALOR"       , "TRB", "Valor"         , "@E 999,999,999.99" , 14  , , /*{|| code-block de impressao }*/)
TRCell():New(oSection, "VLRISS"      , "TRB", "VLRISS"        , "@E 999,999,999.99" , 14  , , /*{|| code-block de impressao }*/)
TRCell():New(oSection, "VLRIRRF"     , "TRB", "VLRIRRF"       , "@E 999,999,999.99" , 14  , , /*{|| code-block de impressao }*/)
TRCell():New(oSection, "VLRDESC"     , "TRB", "VLRDESC"       , "@E 999,999,999.99" , 14  , , /*{|| code-block de impressao }*/)
TRCell():New(oSection, "VLRDECRESC"  , "TRB", "VLRDECRESC"    , "@E 999,999,999.99" , 14  , , /*{|| code-block de impressao }*/)
TRCell():New(oSection, "VLRMULTA"    , "TRB", "VLRMULTA"      , "@E 999,999,999.99" , 14  , , /*{|| code-block de impressao }*/)
TRCell():New(oSection, "VLRJUROS"    , "TRB", "VLRJUROS"      , "@E 999,999,999.99" , 14  , , /*{|| code-block de impressao }*/)
TRCell():New(oSection, "VLRCORREC"   , "TRB", "VLRCORREC"     , "@E 999,999,999.99" , 14  , , /*{|| code-block de impressao }*/)
TRCell():New(oSection, "VLRACRESC"   , "TRB", "VLRACRESC"     , "@E 999,999,999.99" , 14  , , /*{|| code-block de impressao }*/)
TRCell():New(oSection, "VLRINSS"     , "TRB", "VLRINSS"       , "@E 999,999,999.99" , 14  , , /*{|| code-block de impressao }*/)
TRCell():New(oSection, "VLRPIS"      , "TRB", "VLRPIS"        , "@E 999,999,999.99" , 14  , , /*{|| code-block de impressao }*/)
TRCell():New(oSection, "VLRCOFINS"   , "TRB", "VLRCOFINS"     , "@E 999,999,999.99" , 14  , , /*{|| code-block de impressao }*/)
TRCell():New(oSection, "VLRCSLL"     , "TRB", "VLRCSLL"       , "@E 999,999,999.99" , 14  , , /*{|| code-block de impressao }*/)
TRCell():New(oSection, "VLRSALDO"    , "TRB", "VLRSALDO"      , "@E 999,999,999.99" , 14  , , /*{|| code-block de impressao }*/)
TRCell():New(oSection, "DTBAIXA"     , "TRB", "DTBAIXA"       , "@R 99/99/9999"     , 14  , , /*{|| code-block de impressao }*/)
TRCell():New(oSection, "HISTORICO"   , "TRB", "HISTORICO"     , /*Picture*/         , 58  , , /*{|| code-block de impressao }*/)
TRCell():New(oSection, "ITEMCTA"     , "TRB", "ITEMCTA"       , /*Picture*/         , 13  , , /*{|| code-block de impressao }*/)
TRCell():New(oSection, "TIT_ORIGEM"  , "TRB", "TIT_ORIGEM"    , /*Picture*/         , 16  , , /*{|| code-block de impressao }*/)
TRCell():New(oSection, "ORIGEM"      , "TRB", "ORIGEM"        , /*Picture*/         , 10  , , /*{|| code-block de impressao }*/)
TRCell():New(oSection, "ANOMES_ENT"  , "TRB", "ANOMES_ENT"    , "@R 9999/99"        , 12  , , /*{|| code-block de impressao }*/)
TRCell():New(oSection, "ANOMES_EMIS" , "TRB", "ANOMES_EMIS"   , "@R 9999/99"        , 12  , , /*{|| code-block de impressao }*/)
TRCell():New(oSection, "ANOMES_VENC" , "TRB", "ANOMES_VENC"   , "@R 9999/99"        , 12  , , /*{|| code-block de impressao }*/)
TRCell():New(oSection, "R_E_C_N_O_"  , "TRB", "R_E_C_N_O_"    , /*Picture*/         , 13  , , /*{|| code-block de impressao }*/)


oReport:PrintDialog()

Return

Static Function ReportPrint(oReport,oSection)

#IFDEF TOP

    Local cAlias := "TRB"

    BEGIN REPORT QUERY oSection

        BeginSql alias cAlias

			SELECT W.FILIAL, W.PREFIXO, W.NUMDOC, W.TIPO, W.CODNATUREZA, W.NATUREZA, W.CODFORNEC, W.RAZAOSOCIAL, W.CTACONTABIL, W.DTENTRADA, W.DTEMISSAO,
			W.DTVENCIMENTO,
			CASE
				WHEN W.VALOR = -0 THEN 0
				ELSE W.VALOR
			END AS VALOR, W.VLRISS, W.VLRIRRF, W.VLRDESC, W.VLRDECRESC, W.VLRMULTA, W.VLRJUROS, W.VLRCORREC,
			W.VLRACRESC, W.VLRINSS, W.VLRPIS, W.VLRCOFINS, W.VLRCSLL, W.VLRSALDO, W.DTBAIXA, W.HISTORICO, W.ITEMCTA, W.TIT_ORIGEM, W.ORIGEM,
			RIGHT('0000'+CAST(DATEPART(YEAR, W.DTENTRADA) AS VARCHAR(4)), 4)+RIGHT('00'+CAST(DATEPART(MONTH, W.DTENTRADA) AS VARCHAR(2)), 2) ANOMES_ENT,
			RIGHT('0000'+CAST(DATEPART(YEAR, W.DTEMISSAO) AS VARCHAR(4)), 4)+RIGHT('00'+CAST(DATEPART(MONTH, W.DTEMISSAO) AS VARCHAR(2)), 2) ANOMES_EMIS,
			RIGHT('0000'+CAST(DATEPART(YEAR, W.DTVENCIMENTO) AS VARCHAR(4)), 4)+RIGHT('00'+CAST(DATEPART(MONTH, W.DTVENCIMENTO) AS VARCHAR(2)), 2) ANOMES_VENC,
			W.R_E_C_N_O_
			FROM (
			SELECT X.FILIAL, X.PREFIXO, X.NUMDOC, X.TIPO, X.CODNATUREZA, X.NATUREZA, X.CODFORNEC, X.RAZAOSOCIAL, X.CTACONTABIL, X.DTENTRADA, X.DTEMISSAO,
			X.DTVENCIMENTO,
			CASE
				WHEN X.DTBAIXA <=  %Exp:DTOS(MV_PAR01)% AND X.VLRSALDO = 0 THEN 0
				ELSE X.VALOR-(X.VLRPABX+X.VLRBX+X.VLRBXDEV+X.VLRBXFAT+X.VLRLIQUIDACAO)
			END AS VALOR, X.VLRISS, X.VLRIRRF, X.VLRDESC, X.VLRDECRESC, X.VLRMULTA,
			X.VLRJUROS, X.VLRCORREC, X.VLRACRESC, X.VLRINSS, X.VLRPIS, X.VLRCOFINS, X.VLRCSLL, X.VLRSALDO, X.DTBAIXA, X.HISTORICO, X.ITEMCTA,
			X.TIT_ORIGEM, X.ORIGEM, X.R_E_C_N_O_
			FROM (
			SELECT A.E2_FILIAL FILIAL, A.E2_PREFIXO PREFIXO, A.E2_NUM NUMDOC, A.E2_TIPO TIPO, A.E2_NATUREZ CODNATUREZA, B.ED_DESCRIC NATUREZA,
			A.E2_FORNECE CODFORNEC, C.A2_NOME RAZAOSOCIAL, C.A2_CONTA CTACONTABIL, CONVERT(DATETIME,A.E2_EMIS1,103) DTENTRADA,
			CONVERT(DATETIME,A.E2_EMISSAO,103) DTEMISSAO,
			CONVERT(DATETIME,A.E2_VENCTO,103) DTVENCIMENTO, A.E2_VALOR VALOR,
			ISNULL((SELECT SUM(ISNULL(Z.E5_VALOR,0)) FROM %table:SE5%  (NOLOCK) Z
			WHERE Z.D_E_L_E_T_ <> '*'
			AND   Z.E5_CLIFOR  = A.E2_FORNECE
			AND   Z.E5_PREFIXO = A.E2_PREFIXO
			AND   Z.E5_TIPO    = A.E2_TIPO
			AND   Z.E5_NUMERO  = A.E2_NUM
			AND   Z.E5_PARCELA = A.E2_PARCELA
			AND   Z.E5_LOJA    = A.E2_LOJA
			AND   Z.E5_TIPODOC IN ('CP')
			AND   Z.E5_SITUACA <> 'C'
			AND   Z.E5_DATA    <= %Exp:DTOS(MV_PAR01)%
			),0) -
			ISNULL((SELECT SUM(ISNULL(Y.E5_VALOR,0)) FROM %table:SE5% (NOLOCK) Y
			WHERE Y.D_E_L_E_T_ <> '*'
			AND   Y.E5_CLIFOR  = A.E2_FORNECE
			AND   Y.E5_PREFIXO = A.E2_PREFIXO
			AND   Y.E5_TIPO    = A.E2_TIPO
			AND   Y.E5_NUMERO  = A.E2_NUM
			AND   Y.E5_PARCELA = A.E2_PARCELA
			AND   Y.E5_LOJA    = A.E2_LOJA
			AND   Y.E5_TIPODOC = 'ES'
			AND   Y.E5_SITUACA <> 'C'
			AND   Y.E5_HISTOR  = 'Cancel. de Compensacao                  '
			AND   Y.E5_DATA    <= %Exp:DTOS(MV_PAR01)%
			),0) VLRPABX,
			ISNULL((SELECT (SUM(ISNULL(S.E5_VALOR,0))+SUM(ISNULL(S.E5_VRETPIS,0))+SUM(ISNULL(S.E5_VRETCOF,0))+SUM(ISNULL(S.E5_VRETCSL,0))+SUM(ISNULL(S.E5_VLDESCO,0)))-(SUM(ISNULL(S.E5_VLJUROS,0))+SUM(ISNULL(S.E5_VLMULTA,0))+SUM(ISNULL(S.E5_VLCORRE,0))) FROM %table:SE5% (NOLOCK) S
			WHERE S.D_E_L_E_T_ <> '*'
			AND   S.E5_FILIAL  = A.E2_FILIAL
			AND   S.E5_CLIFOR  = A.E2_FORNECE
			AND   S.E5_PREFIXO = A.E2_PREFIXO
			AND   S.E5_TIPO    = A.E2_TIPO
			AND   S.E5_NUMERO  = A.E2_NUM
			AND   S.E5_PARCELA = A.E2_PARCELA
			AND   S.E5_LOJA    = A.E2_LOJA
			AND   S.E5_TIPODOC = 'BA'
			AND   S.E5_SITUACA <> 'C'
			AND   S.E5_TIPO NOT IN ('PR','GRF','ISS')
			AND   S.E5_MOTBX   = 'DEV'
			AND   S.E5_DATA    <= %Exp:DTOS(MV_PAR01)%
			),0) VLRBXDEV,
			ISNULL((SELECT (SUM(ISNULL(R.E5_VALOR,0))+SUM(ISNULL(R.E5_VRETPIS,0))+SUM(ISNULL(R.E5_VRETCOF,0))+SUM(ISNULL(R.E5_VRETCSL,0))+SUM(ISNULL(R.E5_VLDESCO,0)))-(SUM(ISNULL(R.E5_VLJUROS,0))+SUM(ISNULL(R.E5_VLMULTA,0))+SUM(ISNULL(R.E5_VLCORRE,0))) FROM %table:SE5% (NOLOCK) R
			WHERE R.D_E_L_E_T_ <> '*'
			AND   R.E5_FILIAL  = A.E2_FILIAL
			AND   R.E5_CLIFOR  = A.E2_FORNECE
			AND   R.E5_PREFIXO = A.E2_PREFIXO
			AND   R.E5_TIPO    = A.E2_TIPO
			AND   R.E5_NUMERO  = A.E2_NUM
			AND   R.E5_PARCELA = A.E2_PARCELA
			AND   R.E5_LOJA    = A.E2_LOJA
			AND   R.E5_TIPODOC = 'BA'
			AND   R.E5_SITUACA <> 'C'
			AND   R.E5_TIPO NOT IN ('PR','GRF','ISS')
			AND   R.E5_MOTBX   IN ('FAT','DAC')
			AND   R.E5_DATA    <= %Exp:DTOS(MV_PAR01)%
			),0) VLRBXFAT,
			ISNULL((SELECT (SUM(ISNULL(V.E5_VALOR,0))+SUM(ISNULL(V.E5_VRETPIS,0))+SUM(ISNULL(V.E5_VRETCOF,0))+SUM(ISNULL(V.E5_VRETCSL,0))+SUM(ISNULL(V.E5_VLDESCO,0)))-(SUM(ISNULL(V.E5_VLJUROS,0))+SUM(ISNULL(V.E5_VLMULTA,0))+SUM(ISNULL(V.E5_VLCORRE,0))) FROM %table:SE5% (NOLOCK) V
			WHERE V.D_E_L_E_T_ <> '*'
			AND   V.E5_FILIAL  = A.E2_FILIAL
			AND   V.E5_CLIFOR  = A.E2_FORNECE
			AND   V.E5_PREFIXO = A.E2_PREFIXO
			AND   V.E5_TIPO    = A.E2_TIPO
			AND   V.E5_NUMERO  = A.E2_NUM
			AND   V.E5_PARCELA = A.E2_PARCELA
			AND   V.E5_LOJA    = A.E2_LOJA
			AND   V.E5_TIPODOC = 'VL'
			AND   V.E5_SITUACA <> 'C'
			AND   V.E5_TIPO NOT IN ('PR','GRF','ISS')
			AND   V.E5_DATA    <= %Exp:DTOS(MV_PAR01)%
			),0) -
			ISNULL((SELECT (SUM(ISNULL(U.E5_VALOR,0))+SUM(ISNULL(U.E5_VRETPIS,0))+SUM(ISNULL(U.E5_VRETCOF,0))+SUM(ISNULL(U.E5_VRETCSL,0))+SUM(ISNULL(U.E5_VLDESCO,0)))-(SUM(ISNULL(U.E5_VLJUROS,0))+SUM(ISNULL(U.E5_VLMULTA,0))+SUM(ISNULL(U.E5_VLCORRE,0))) FROM %table:SE5% (NOLOCK) U
			WHERE U.D_E_L_E_T_ <> '*'
			AND   U.E5_FILIAL  = A.E2_FILIAL
			AND   U.E5_CLIFOR  = A.E2_FORNECE
			AND   U.E5_PREFIXO = A.E2_PREFIXO
			AND   U.E5_TIPO    = A.E2_TIPO
			AND   U.E5_NUMERO  = A.E2_NUM
			AND   U.E5_PARCELA = A.E2_PARCELA
			AND   U.E5_LOJA    = A.E2_LOJA
			AND   U.E5_TIPODOC = 'ES'
			AND   U.E5_SITUACA <> 'C'
			AND   U.E5_TIPO NOT IN ('PR','GRF','ISS')
			AND   U.E5_HISTOR  = 'Cancelamento de Baixa                   '
			AND   U.E5_DATA    <= %Exp:DTOS(MV_PAR01)%
			),0) VLRBX,
			ISNULL((SELECT K.E2_VALOR FROM %table:SE2% K
			WHERE K.D_E_L_E_T_ = ''
			AND   K.E2_TIPOLIQ = 'FT'
			AND   K.E2_BAIXA <=  %Exp:DTOS(MV_PAR01)%
			AND   K.R_E_C_N_O_ = A.R_E_C_N_O_
			),0) VLRLIQUIDACAO,
			A.E2_ISS VLRISS, A.E2_IRRF VLRIRRF, A.E2_DESCONT VLRDESC, A.E2_DECRESC VLRDECRESC, A.E2_MULTA VLRMULTA, A.E2_JUROS VLRJUROS, A.E2_CORREC VLRCORREC,
			A.E2_ACRESC VLRACRESC, A.E2_INSS VLRINSS, A.E2_PIS VLRPIS, A.E2_COFINS VLRCOFINS, A.E2_CSLL VLRCSLL, A.E2_SALDO VLRSALDO,
			CASE
				WHEN A.E2_BAIXA =  '' THEN NULL
				ELSE CONVERT(DATETIME,A.E2_BAIXA,103)
			END AS DTBAIXA,
			A.E2_HIST HISTORICO, A.E2_ITEMD ITEMCTA, A.E2_TITPAI TIT_ORIGEM, A.E2_ORIGEM ORIGEM, A.R_E_C_N_O_
			
			FROM %table:SE2% (NOLOCK) A, %table:SED% (NOLOCK) B, %table:SA2% (NOLOCK) C
			WHERE C.A2_COD      =  A.E2_FORNECE
			///AND A.E2_FORNECE = '001916' // COMENTAR DEPOIS
			AND   C.A2_LOJA     =  A.E2_LOJA
			AND   C.D_E_L_E_T_  <> '*'
			AND   B.ED_CODIGO   =  A.E2_NATUREZ
			AND   B.D_E_L_E_T_  <> '*'
			AND   B.ED_FILIAL   = ' '
			AND   A.D_E_L_E_T_  <> '*'
					AND   A.E2_EMIS1    <= %Exp:DTOS(MV_PAR01)%
			AND   (A.E2_PREFIXO+A.E2_PARCELA) NOT IN ('FT  ')
			AND   C.A2_CONTA IN ('210101001','210101002','210101003','210102002')
			AND   A.E2_PREFIXO <> 'PA'
			AND   A.E2_TIPO NOT IN ('PR','GRF','ISS')
								
			) X
			) W
			WHERE W.VALOR > 0.01
			AND   (W.NUMDOC+W.CODFORNEC) NOT IN ('000000007000140')

        EndSql

        MEMOWRITE("C:\TEMP\OZRELX.sql",GETLASTQUERY()[2])

    END REPORT QUERY oSection 
	
	
    oSection:Print()

#ENDIF

Return
