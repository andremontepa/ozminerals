#include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFUN_MATRICULA บAutor ณLeonardo/Sangelles บ Data ณ  02/11/16 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMATRICULA DOS FUNCIONARIOS                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/



user function fun_matricula
  	
  	cSql := " SELECT MAX(RA_MAT)+1 RA_MAT "
  	cSql += " FROM "+RetSqlName("SRA")
  	cSql += " WHERE D_E_L_E_T_ <> '*' "
  	cSql += " AND RA_FILIAL = '"+xFilial("SRA")+"' "
  	
  	if funname() == "GPEA011" .or. funname() == "GPEA010"  //Nome das duas rotinas que cadastra funcionario
	  	cSql += " AND RA_CATFUNC = 'M' AND RA_MAT NOT LIKE '3%' AND RA_MAT NOT LIKE '08%' "
  	elseif funname() == "GPEA265" //Nome da Rotina que cadastra Autonomo
  		cSql += " AND RA_CATFUNC = 'A' "
  	endif
  	
If Select("TMP") > 0
 TMP->(DbCloseArea())
Endif

TCQUERY cSql NEW ALIAS "TMP" 

cCod := PADL(ALLTRIM(STR(TMP->RA_MAT)),6,"0") 

if empty(cCod) .or. cCod == "000000"
	if funname() == "GPEA011" .or. funname() == "GPEA010"  
		cCod := "000001"                                       
	else
		cCod := "080001"
	endif
endif

return cCod