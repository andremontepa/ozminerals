#include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFUN_NUMBX บAutor   ณLeonardo/Sangelles บ Data ณ  28/10/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/



user function fun_Numbx
  	
  	cSql := "SELECT "
  	cSql += " CASE "
  	cSql += " WHEN LEN(NUMBX) = 1 THEN 'BX000000'+CAST(NUMBX AS CHAR(1)) "
 	cSql += " WHEN LEN(NUMBX) = 2 THEN 'BX00000'+CAST(NUMBX AS CHAR(2)) "  	
  	cSql += " WHEN LEN(NUMBX) = 3 THEN 'BX0000'+CAST(NUMBX AS CHAR(3)) "
  	cSql += " WHEN LEN(NUMBX) = 4 THEN 'BX000'+CAST(NUMBX AS CHAR(4)) "
  	cSql += " WHEN LEN(NUMBX) = 5 THEN 'BX00'+CAST(NUMBX AS CHAR(5)) "
  	cSql += " WHEN LEN(NUMBX) = 6 THEN 'BX0'+CAST(NUMBX AS CHAR(6)) "
  	cSql += " WHEN LEN(NUMBX) = 7 THEN 'BX'+CAST(NUMBX AS CHAR(7)) "
  	cSql += " END AS NUM_BX "
  	cSql += " FROM( "
  	cSql += " SELECT SUBSTRING(MAX(D3_DOC),3,7)+1 NUMBX FROM "+RetSqlName("SD3")
  	cSql += " WHERE D_E_L_E_T_ <> '*' "
  	cSql += " AND D3_DOC LIKE 'BX%' "
  	cSql += " AND D3_DOC NOT LIKE '%USO%' "
  	cSql += " AND LEN(D3_DOC) = 9 	AND ISNUMERIC(SUBSTRING(D3_DOC,3,7)) = 1 "
  	cSql += " ) X "
	           
 /*	MemowRite("C:\TEMP\EXEMPLO1.TXT",cSql)*/

	If Select("TMP") > 0
	 TMP->(DbCloseArea())
	Endif

	TCQUERY cSql NEW ALIAS "TMP" 
	
	cCod := ALLTRIM(TMP->NUM_BX)
	
	if empty(cCod)
		cCod := "BX0000001"
	endif
	
return cCod