#INCLUDE "PROTHEUS.CH"
#INCLUDE "tbiconn.CH"

USER FUNCTION TESTE03()
    Local  nI
    Private aTab := {}
    Private oTempTable

    PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01"

    oTempTable := FWTemporaryTable():New( "PCOX" )

    aTab := FWSX3Util():GetListFieldsStruct( "AK2" , .t. )

    oTemptable:SetFields( aTab )
    oTempTable:AddIndex("indice1", {"AK2_CO"} )

    oTempTable:Create()

    BEGINSQL ALIAS "TRB1"
        %noparser%

        
        SELECT CONTAORC
        FROM PCO2024 P
        LEFT JOIN CTT010 CTT ON CTT.D_E_L_E_T_ = '' AND CTT_CUSTO = CCUSTO
        LEFT JOIN CTH010 CTH ON CTH.D_E_L_E_T_ = '' AND CTH_CLVL = CLVL
        LEFT JOIN CTD010 CTD ON CTD.D_E_L_E_T_ = '' AND CTD_ITEM = ITEMCTB
        WHERE P.D_E_L_E_T_ = ''
        GROUP BY CONTAORC 
        ORDER BY 1
        
    ENDSQL

    dbselectarea("TRB1")
    dbgotop()


    while TRB1->(!EOF())

        IF SELECT("TRB2") <> 0
            DBSELECTAREA("TRB2")
            TRB2->(dbclosearea())
        ENDIF

        BEGINSQL ALIAS "TRB2"
            %noparser%
    
            SELECT CTT_BLOQ, CTD_BLOQ, CTH_BLOQ, P.*, ISNULL(AK5_DESCRI,'X') DESCRI
            FROM PCO2024 P
            LEFT JOIN CTT010 CTT ON CTT.D_E_L_E_T_ = '' AND CTT_CUSTO = CCUSTO
            LEFT JOIN CTH010 CTH ON CTH.D_E_L_E_T_ = '' AND CTH_CLVL = CLVL
            LEFT JOIN CTD010 CTD ON CTD.D_E_L_E_T_ = '' AND CTD_ITEM = ITEMCTB
            LEFT JOIN AK5010 AK5 ON AK5.D_E_L_E_T_ = '' AND AK5_CODIGO = CONTAORC
            WHERE P.D_E_L_E_T_ = ''
            AND CONTAORC= %EXP:ALLTRIM(TRB1->CONTAORC)%

        ENDSQL

        nItem := 0

        dbselectarea("TRB2")
        dbgotop()
        while TRB2->(!EOF())
            nItem++

            For nI := 1 to 12

                DO CASE
                CASE nI == 1
                   NVALOR  := TRB2->JANEIRO
                   DPERIOD := STOD("20240101")
                   DDATAI  := DPERIOD
                   DDATAF  := LastDate(DPERIOD) 
                CASE nI == 2
                   NVALOR  := TRB2->FEVEREIRO
                   DPERIOD := STOD("20240201")
                   DDATAI  := DPERIOD
                   DDATAF  := LastDate(DPERIOD) 
                CASE nI == 3
                   NVALOR  := TRB2->MARCO
                   DPERIOD := STOD("20240301")
                   DDATAI  := DPERIOD
                   DDATAF  := LastDate(DPERIOD) 
                CASE nI == 4
                   NVALOR  := TRB2->ABRIL
                   DPERIOD := STOD("20240401")
                   DDATAI  := DPERIOD
                   DDATAF  := LastDate(DPERIOD) 
                CASE nI == 5
                   NVALOR  := TRB2->MAIO
                   DPERIOD := STOD("20240501")
                   DDATAI  := DPERIOD
                   DDATAF  := LastDate(DPERIOD) 
                CASE nI == 6
                   NVALOR  := TRB2->JUNHO
                   DPERIOD := STOD("20240601")
                   DDATAI  := DPERIOD
                   DDATAF  := LastDate(DPERIOD) 
                CASE nI == 7
                   NVALOR  := TRB2->JULHO
                   DPERIOD := STOD("20230701")
                   DDATAI  := DPERIOD
                   DDATAF  := LastDate(DPERIOD) 
                CASE nI == 8
                   NVALOR  := TRB2->AGOSTO
                   DPERIOD := STOD("20230801")
                   DDATAI  := DPERIOD
                   DDATAF  := LastDate(DPERIOD) 
                CASE nI == 9
                   NVALOR  := TRB2->SETEMBRO
                   DPERIOD := STOD("20230901")
                   DDATAI  := DPERIOD
                   DDATAF  := LastDate(DPERIOD) 
                CASE nI == 10
                   NVALOR  := TRB2->OUTUBRO
                   DPERIOD := STOD("20231001")
                   DDATAI  := DPERIOD
                   DDATAF  := LastDate(DPERIOD) 
                CASE nI == 11
                   NVALOR  := TRB2->NOVEMBRO
                   DPERIOD := STOD("20231101")
                   DDATAI  := DPERIOD
                   DDATAF  := LastDate(DPERIOD) 
                CASE nI == 12
                   NVALOR  := TRB2->DEZEMBRO
                   DPERIOD := STOD("20231201")
                   DDATAI  := DPERIOD
                   DDATAF  := LastDate(DPERIOD) 
                ENDCASE


                RECLOCK("PCOX",.T.)
                PCOX->AK2_FILIAL := XFILIAL("AK2")
                PCOX->AK2_ID     := STRZERO(nItem,4)
                PCOX->AK2_ORCAME := "ORC20232024"
                PCOX->AK2_VERSAO := "0001"
                PCOX->AK2_CO     := ALLTRIM(TRB2->CONTAORC)
                PCOX->AK2_CC     := ALLTRIM(TRB2->CCUSTO)
                PCOX->AK2_ITCTB  := ALLTRIM(TRB2->ITEMCTB)
                PCOX->AK2_CLVLR  := ALLTRIM(TRB2->CLVL)
                PCOX->AK2_CLASSE := ALLTRIM(TRB2->CLASSEORC)
                PCOX->AK2_MOEDA  := 1
                PCOX->AK2_VALOR  := NVALOR
                PCOX->AK2_PERIOD := DPERIOD
                PCOX->AK2_DATAI  := DDATAI
                PCOX->AK2_DATAF  := DDATAF
                PCOX->AK2_DESCRI := UPPER(TRB2->DESCRI)
                MSUNLOCK()
                COMMIT
            Next


            TRB2->(DBSKIP())
        ENDDO

        TRB1->( dbskip() )
    enddo


    cNameDB := oTempTable:GetRealName()

    TCDELFILE("PCOV02")

    cQRY := "SELECT * INTO PCOV02 FROM "+cNameDB
    IF TCSQLEXEC(cQRY) < 0
        cError := TCSQLERROR()
        MsgAlert(cError)
    ELSE
        MsgInfo("TabELA trbprice criada")
    ENDIF

/*


    nID := 0

    while TRBX->(!EOF())
        nID++
        for nI := 1 to 12
            DO CASE
            CASE nI == 1
                dData  := STOD("20240101")
                nValor := TRBX->janeiro
            CASE nI == 2
                dData  := STOD("20240201")
                nValor := TRBX->fevereiro
            CASE nI == 3
                dData  := STOD("20240301")
                nValor := TRBX->marco
            CASE nI == 4
                dData  := STOD("20240401")
                nValor := TRBX->abril
            CASE nI == 5
                dData  := STOD("20240501")
                nValor := TRBX->maio
            CASE nI == 6
                dData  := STOD("20240601")
                nValor := TRBX->val12
            CASE nI == 7
                dData  := STOD("20230701")
                nValor := TRBX->julho
            CASE nI == 8
                dData  := STOD("20230801")
                nValor := TRBX->agosto
            CASE nI == 9
                dData  := STOD("20230901")
                nValor := TRBX->setembro
            CASE nI == 10
                dData  := STOD("20231001")
                nValor := TRBX->outubro
            CASE nI == 11
                dData  := STOD("20231101")
                nValor := TRBX->novembro
            CASE nI == 12
                dData  := STOD("20231201")
                nValor := TRBX->dezembro
            ENDCASE

            RECLOCK("PCOX",.T.)
            PCOX->AMJ_FILIAL := "01"
            PCOX->AMJ_LOTE   := "062023"
            PCOX->AMJ_ID     := STRZERO(nID,4)
            PCOX->AMJ_PROCES := "062023"
            PCOX->AMJ_ITEM   := "01"
            PCOX->AMJ_SEQ    := "01"
            PCOX->AMJ_CHAVE  := ""
            PCOX->AMJ_DATA   := dData
            PCOX->AMJ_CO     := TRBX->conta
            PCOX->AMJ_CLASSE := TRBX->classe
            PCOX->AMJ_OPER   := "000001"
            PCOX->AMJ_CC     := TRBX->ccusto
            PCOX->AMJ_ITCTB  := TRBX->itct
            PCOX->AMJ_CLVLR  := TRBX->clvl
            PCOX->AMJ_VALOR1 := nValor
            PCOX->AMJ_DATPLA := date()
            MSUNLOCK()
            COMMIT
        NEXT
        TRBX->( dbskip() )
    enddo

    cNameDB := oTempTable:GetRealName()

    TCDELFILE("PCOV02")

    cQRY := "SELECT * INTO PCOV02 FROM "+cNameDB
    IF TCSQLEXEC(cQRY) < 0
        cError := TCSQLERROR()
        MsgAlert(cError)
    ELSE
        MsgInfo("TabELA trbprice criada")
    ENDIF
*/
RETURN

USER FUNCTION TESTE()

    LOcal cFile := "C:\TEMP\PRICEB2023.CSV"
    Local aFile := {}
    Local nFile := FT_FUSE(cFile)
    Private cAlias
    Private oTempTable
    Private cNameDB

    PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01"

    oTempTable := FWTemporaryTable():New( "PCOX" )

    IF nFile < 0
        MSGALERT("ERRO ABERTURA:"+cFile)

    ENDIF


    AADD(aFile,{"LINHA"  ,"C",010,00})
    AADD(aFile,{"PRODUTO","C",050,00})
    //AADD(aFile,{"DESCRIC","C",200,00})
    AADD(aFile,{"VALOR01","N",016,04})
    AADD(aFile,{"VALOR02","N",016,04})
    AADD(aFile,{"VALOR03","N",016,04})

    oTemptable:SetFields( aFile )
    oTempTable:AddIndex("INDICE1", {"LINHA"} )
    oTempTable:Create()

    FT_FGOTOP()
    nLin := 0
    WHILE !FT_FEOF()
        nLin++
        CONOUT("LINHA: "+STRZERO(nLin,10))
        IF nLin == 1
            FT_FSKIP()
            LOOP
        ENDIF

        cLin := FT_FREADLN()
        CONOUT("LINHA: "+STRZERO(nLin,10)+" CONTEUDO: "+cLin)
        aLin := StrTokArr2( cLin, ";" , .t.)
        nV01 := IIF(LEN(aLin) > 1 , val(STRTRAN(STRTRAN(STRTRAN(STRTRAN(alltrim(aLin[2]),"USD",""),"-",""),".",""),",",".")) , 0 )
        nV02 := IIF(LEN(aLin) > 2 , val(STRTRAN(STRTRAN(STRTRAN(STRTRAN(alltrim(aLin[3]),"USD",""),"-",""),".",""),",",".")) , 0 )
        nV03 := IIF(LEN(aLin) > 3 , val(STRTRAN(STRTRAN(STRTRAN(STRTRAN(alltrim(aLin[4]),"USD",""),"-",""),".",""),",",".")) , 0 )

        RECLOCK("TRBX",.T.)
        TRBX->LINHA   := STRZERO(nLin,10)
        TRBX->PRODUTO := alltrim(aLin[1])
        //TRBX->DESCRIC := alltrim(aLin[2])
        TRBX->VALOR01 := nV01
        TRBX->VALOR02 := nV02
        TRBX->VALOR03 := nV03

        MSUNLOCK()
        COMMIT
        FT_FSKIP()
    ENDDO

    cNameDB := oTempTable:GetRealName()

    TCDELFILE("TRBPRICE")

    cQRY := "SELECT * INTO TRBPRICE FROM "+cNameDB
    IF TCSQLEXEC(cQRY) < 0
        cError := TCSQLERROR()
        MsgAlert(cError)
    ELSE
        MsgInfo("TabELA trbprice criada")
    ENDIF


RETURN



/*
/*

SELECT tipo, conta, clvl, ccusto, itct, classe,oper
  , sum(julho) M2307 , sum(agosto) M2308, sum(setembro) M2309, sum(outubro) M2310
  , sum(novembro) M2311, sum(dezembro) M2312
  , sum(janeiro) M2401, sum(fevereiro) M2402, sum(marco) M2403, sum(abril) M2404
  , sum(maio) M2405, sum(val12) M2406
FROM teste01
where replace(conta,'.','') = '610104999' 
group by tipo, conta, clvl, ccusto, itct, classe,oper 

*/



/*
select conta, clvl, ccusto, itct, classe, count(*) t
from teste01

group by conta, clvl, ccusto, itct, classe


SELECT * --amj_co, amj_classe, amj_oper, amj_cc, amj_itctb, amj_clvlr, count(*) qtdreg
FROM pcov02
where d_e_l_e_t_ = ''
order by amj_co, amj_classe, amj_oper, amj_cc, amj_itctb, amj_clvlr
*/

