#INCLUDE "protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch" 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCN120ENCMD บAutor ณ Ismael Junior - STARSOFT em 22/03/2019  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto de entrada para tratamento de campos especํficos     บฑฑ
ฑฑบ          ณ na gera็ใo do pedido de compras.                           บฑฑ
ฑฑบA็ใo:     ณ Grava na Array dos itens a gerar o pedido de compras, a    บฑฑ
ฑฑบ          ณ observa็ใo da medi็ใo dos contratos                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGCT>Atualiza็๕es>Movimentos>Medi็๕es/Entregas>CNTA120  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿    
*/           
User function CN120ENCMD() 
//Processa rotinas especificas apos o encerramento da medicao
//*********************************************************** em 22/03/2019//
//Ajusta tabelas ap๓s bloqueio do pedido de compra
/*
cSql := " UPDATE " + RetSqlName("SAL")+ " SET AL_DOCPC = 'F',AL_DOCIP = 'F',AL_DOCCT = 'F',AL_DOCGA = 'F' WHERE AL_DOCGA = 'T' AND AL_DOCMD = 'T' AND D_E_L_E_T_ != '*' " 
nStatus := TcSQLExec(cSql)   
  if (nStatus < 0)
    conout("TCSQLError() " + TCSQLError())
  endif 
*/
//************************************************************ em 03/04/2019//
//Carregas os documentos da medi็ใo para pedido de compra
	cQuery := "	SELECT AC9_CODOBJ FROM " + RetSqlName("AC9")+ " AC9 WHERE AC9_ENTIDA = 'CND' AND AC9_CODENT = '"+xFilial( "CND" ) + CND->CND_CONTRA + CND->CND_REVISA + CND->CND_NUMMED+"' AND D_E_L_E_T_ != '*' "
	If SELECT("TRBAC9") > 0
		TRBAC9->(DbCloseArea())
	Endif
    dbUseArea(.T.,"TOPCONN", TcGenQry(,,cQuery),"TRBAC9",.T.,.T.)
	DbSelectArea("TRBAC9")
	TRBAC9->(dbGoTop())		    
			Do While TRBAC9->(!Eof())
				RecLock( "AC9", .T. ) 		
				AC9->AC9_FILIAL := xFilial( "AC9" )
				AC9->AC9_FILENT := xFilial( "SC7" )
				AC9->AC9_ENTIDA := "SC7"
				AC9->AC9_CODENT := xFilial( "SC7" ) + CND->CND_PEDIDO + "0001"
				AC9->AC9_CODOBJ := TRBAC9->AC9_CODOBJ	
				AC9->(MsUnLock()) // Confirma e finaliza a opera็ใo  		
			dbSelectArea("TRBAC9")
			TRBAC9->(dbSkip())
			EndDo 	  
Return
