#include "rwmake.ch"
#include "fileio.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
#include "protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINA080   ºAutor  ³Ismael Junior       º Data ³  08/11/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada será executado antes da contabilizacão    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function FINA080()
Local cAno     := Alltrim(Str(Year(Date())))
Local cMes     := Month2Str(Date())
DbSelectArea("ZW3")
ZW3->(DbSetOrder(4))
If ZW3->(DbSeek(xfilial("ZW3")+SE2->E2_NUM+SE2->E2_CCUSTO+SE2->E2_ITEMCTA+SE2->E2_CLVL+SE2->E2_CONTAD+cAno))
	cQuery := " SELECT E5_NUMERO FROM " + RetSqlName("SE5")+" WHERE E5_NUMERO = '"+SE2->E2_NUM+"' AND E5_SITUACA <> 'C' AND D_E_L_E_T_ != '*' "		
	If SELECT("TRA") > 0
		("TRA")->(DbCloseArea())
	Endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRA",.T.,.T.)
	dbSelectArea("TRA")
	If !EMPTY(TRA->E5_NUMERO)
		cUpdate:= " UPDATE " + RetSqlName("ZW2")+" SET ZW2_REL"+cMes+"=ZW2_REL"+cMes+"+"+Alltrim(Str(SE2->E2_VALOR))+",ZW2_RELANO = ZW2_RELANO+"+Alltrim(Str(SE2->E2_VALOR))
		cUpdate+= " WHERE ZW2_CCUSTO = '"+Alltrim(SE2->E2_CCUSTO)+"' "
		cUpdate+= " AND ZW2_ITEMCO = '"+Alltrim(SE2->E2_ITEMCTA)+"' "
		cUpdate+= " AND ZW2_CLVL = '"+Alltrim(SE2->E2_CLVL)+"' "
		cUpdate+= " AND ZW2_CONTA = '"+Alltrim(SE2->E2_CONTAD)+"' "
		cUpdate+= " AND ZW2_ANO = '"+cAno+"' " 
		cUpdate+= " AND ZW2_FILIAL = '"+xFilial("ZW2")+"' "
		cUpdate+= " AND D_E_L_E_T_ != '*' "
		nFlag := TcSqlExec(cUpdate)
	Else
		cUpdate:= " UPDATE " + RetSqlName("ZW2")+" SET ZW2_REL"+cMes+"=ZW2_REL"+cMes+"-"+Alltrim(Str(SE2->E2_VALOR))+",ZW2_RELANO = ZW2_RELANO-"+Alltrim(Str(SE2->E2_VALOR))
		cUpdate+= " WHERE ZW2_CCUSTO = '"+Alltrim(SE2->E2_CCUSTO)+"' "
		cUpdate+= " AND ZW2_ITEMCO = '"+Alltrim(SE2->E2_ITEMCTA)+"' "
		cUpdate+= " AND ZW2_CLVL = '"+Alltrim(SE2->E2_CLVL)+"' "
		cUpdate+= " AND ZW2_CONTA = '"+Alltrim(SE2->E2_CONTAD)+"' "
		cUpdate+= " AND ZW2_ANO = '"+cAno+"' " 
		cUpdate+= " AND ZW2_FILIAL = '"+xFilial("ZW2")+"' "
		cUpdate+= " AND D_E_L_E_T_ != '*' "
		nFlag := TcSqlExec(cUpdate)		 
   	Endif
Endif   		
Return()
