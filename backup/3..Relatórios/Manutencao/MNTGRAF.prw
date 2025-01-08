#Include "Protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMNTGRAF บAutor  ณSTARSOFT              บ Data ณ  25/11/2021 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Impressใo Grแfica Manuten็ใo de Ativos                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function Planta()
                Local cSql := ""
                
                cSql := "Select SUM(CASE "
                cSql += "When TF_UNENMAN = 'D' AND CAST((TF_DTULTMA + CAST(TF_TEENMAN AS DATETIME)) AS DATETIME) < CONVERT(DATETIME, CONVERT(INT, GETDATE())) THEN 1"
                cSql += "When TF_UNENMAN = 'S' AND CAST((TF_DTULTMA + CAST(TF_TEENMAN * 7 AS DATETIME)) AS DATETIME) < CONVERT(DATETIME, CONVERT(INT, GETDATE())) THEN 1"
                cSql += "When TF_UNENMAN = 'M' AND CAST((TF_DTULTMA + CAST(TF_TEENMAN * 30 AS DATETIME)) AS DATETIME) < CONVERT(DATETIME, CONVERT(INT, GETDATE())) THEN 1"
                cSql += " Else 0"
                cSql += " End) TOTAL "
                cSql += " From " + RetSqlName("STF")
                cSql += " Where TF_Filial = " + ValToSql(xFilial("STF"))
                cSql += "     And TF_TIPACOM = 'T'"
                cSql += "     And TF_TIPLUB <> 'S'"
                cSql += "     And TF_CODBEM = " + ValToSql(cCodigo)      
                cSql += "     And D_E_L_E_T_ = ''"              
                
Return cSql
