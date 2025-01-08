#Include "Rwmake.ch"
#Include "Protheus.ch"
#Include "Topconn.ch"
#include "rwmake.ch"
#include "fileio.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
User Function MT120GRV
Local cNum    := PARAMIXB[1]
//Local lInclui := PARAMIXB[2]
//Local lAltera := PARAMIXB[3]
Local lExclui := PARAMIXB[4]
Local lRet 	  := .T.
Local cAno    := Alltrim(Str(Year(Date())))
Local cMes     := Month2Str(Date()) 
Local cCodUser := RetCodUsr() //Retorna o Codigo do Usuario
Local cNamUser := UsrRetName( cCodUser )//Retorna o nome do usuario
Private aCampos:={ {"CHAV" ,"C", 38,0},;
{"BLOQ" ,"C",1,0},;
{"CCUSTO" ,"C",9,0},;
{"ITEMCO" ,"C",9,0},;
{"CLVL" ,"C",20,0},;
{"CONTA" ,"C",20,0},;
{"NVLTOT","N",14,2},;
{"NVLCON","N",14,2}}  // campos da tabela temporária

If Select("TRBGR")> 0
	TRBGR->(DbCloseArea())
Endif
cNomeArq :=CriaTrab(aCampos) // cria a tabela temporária
Use &cNomeArq Alias "TRBGR" EXCLUSIVE NEW  // nomeia o alias em modo exclusivo
IndRegua("TRBGR",cNomeArq,"CHAV",,,"Selecionando Registros...")   // criar um inidice para tabela

if lExclui
 	
	cQuery := " SELECT C7_CC,C7_ITEMCTA,C7_CLVL,C7_CONTA,C7_TOTAL "
	cQuery += " FROM "+RetSqlName("SC7")+" SC7 "
	cQuery += " WHERE C7_NUM = '"+cNum+"' "
	cQuery += " AND SC7.D_E_L_E_T_ != '*' "   
	
	If SELECT("TRA") > 0
		("TRA")->(DbCloseArea())
	Endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRA",.T.,.T.)
	dbSelectArea("TRBGR")	
	While TRA->(!EOF())
		cChave := TRA->C7_CC+TRA->C7_ITEMCTA+TRA->C7_CLVL+TRA->C7_CONTA
		TRBGR->(dbSeek(cChave))
		IF EOF()
			nVlRel := TRA->C7_TOTAL
			reclock("TRBGR",.T.)
			TRBGR->CHAV       := TRA->C7_CC+TRA->C7_ITEMCTA+TRA->C7_CLVL+TRA->C7_CONTA
			TRBGR->NVLTOT     := nVlRel
			TRBGR->CCUSTO     := TRA->C7_CC
			TRBGR->ITEMCO     := TRA->C7_ITEMCTA
			TRBGR->CLVL       := TRA->C7_CLVL 
			TRBGR->CONTA      := TRA->C7_CONTA 
		   //	TRBGR->(MsUnlock())
		ELSE
			nVlRel := TRBGR->NVLTOT + TRA->C7_TOTAL
			reclock("TRBGR",.F.)
			TRBGR->NVLTOT     := nVlRel
		   //	TRBGR->(MsUnlock())
		ENDIF
		TRA->(DbSkip())
	Enddo
	
	TRBGR->(DbGoTop())
	While TRBGR->(!EOF())
		cUpdate:= " UPDATE " + RetSqlName("ZW2")+" SET ZW2_VAL"+cMes+"=ZW2_VAL"+cMes+"+"+Alltrim(Str(TRBGR->NVLTOT))+",ZW2_VLANO = ZW2_VLANO-"+Alltrim(Str(TRBGR->NVLTOT))
		cUpdate+= " WHERE ZW2_CCUSTO = '"+Alltrim(TRBGR->CCUSTO)+"' "
		cUpdate+= " AND ZW2_ITEMCO = '"+Alltrim(TRBGR->ITEMCO)+"' "
		cUpdate+= " AND ZW2_CLVL = '"+Alltrim(TRBGR->CLVL)+"' "
		cUpdate+= " AND ZW2_CONTA = '"+Alltrim(TRBGR->CONTA)+"' "
		cUpdate+= " AND ZW2_ANO = '"+cAno+"' "
		cUpdate+= " AND ZW2_FILIAL = '"+xFilial("ZW2")+"' "
		cUpdate+= " AND D_E_L_E_T_ != '*' "
		nFlag := TcSqlExec(cUpdate)
		
					RecLock("ZW3",.T.)
					ZW3->ZW3_FILIAL := XFILIAL("ZW3")
					ZW3->ZW3_NUM    := GETSX8NUM("ZW3","ZW3_NUM")
					ZW3->ZW3_TIPO   := "C"
					ZW3->ZW3_CCUSTO := TRBGR->CCUSTO
					ZW3->ZW3_ITEMCO := TRBGR->ITEMCO
					ZW3->ZW3_ANO    := cAno
					ZW3->ZW3_CLVL   := TRBGR->CLVL
					ZW3->ZW3_CONTA  := TRBGR->CONTA
					ZW3->ZW3_DATA   := Date()
					ZW3->ZW3_VALOR  := TRBGR->NVLTOT
					ZW3->ZW3_ORIGEM := "Pedido de compra"
					ZW3->ZW3_USUARI := cNamUser
					ZW3->ZW3_NUMPED := cNum
					ZW3->ZW3_HISTOR := "Valor ref. Exclusão do pedido: "+cNum
					ZW3->(MsUnLock())
					ConfirmSX8()		
		TRBGR->(DbSkip()) 
	Enddo
	
Endif

Return lRet
