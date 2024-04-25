#INCLUDE "protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch" 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCN120PDM   บAutor ณ Ismael Junior - STARSOFT em 04/07/2019  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Este ponto de entrada ้ executado ap๓s gerar a rotina      บฑฑ
ฑฑบ          ณ automแtica do Pedido de Vendas ou Pedido de Compras.       บฑฑ
ฑฑบA็ใo:     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGCT>Atualiza็๕es>Movimentos>Medi็๕es/Entregas>CNTA120  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿    
*/
User Function CN120PDM()     
Local ExpL1:= PARAMIXB[1]

Private nStart      := 0
If !ExpL1  //Valida็๕es do usuแrio. 
cSql := " UPDATE " + RetSqlName("SAL")+ " SET AL_DOCPC = 'F',AL_DOCIP = 'F',AL_DOCCT = 'F',AL_DOCGA = 'F' WHERE AL_DOCGA = 'T' AND AL_DOCMD = 'T' AND D_E_L_E_T_ != '*' " 
nStatus := TcSQLExec(cSql)
// TcSQLExec("COMMIT")
   
  if (nStatus < 0)
  	FwLogMsg("CN120PDM", /*cTransactionId*/, "CN120PDM", FunName(), "", "01","TCSQLError() " + TCSQLError(), 0, (nStart - Seconds()), {})
  endif
EndIf
Return ExpL1
